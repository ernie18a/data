//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "CoG"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2
#property indicator_label2  "CoG trigger"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_style2  STYLE_DOT

//
//---
//

input int                inpPeriod = 32;           // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price

//
//---
//

double val[],valc[],valt[];

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

void OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,valt,INDICATOR_DATA);
   //            
   //----
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Center of gravity ("+(string)inpPeriod+")");
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

//
//---
//


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = iCg.Calculate(_price,inpPeriod,i);
      valt[i] = (i>0) ? val[i-1] : val[i];
      valc[i] = (val[i]>valt[i]) ? 1 : (val[i]<valt[i]) ? 2 : (i>0) ? valc[i-1] : 0;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cCg
{
   int    originalPeriod;
   int    period;
   int    arraySize;
   double sump[];
   double sumw[];
   double prices[];

   public :
      cCg() { originalPeriod=-1; return; }
     ~cCg() { ArrayFree(sump); ArrayFree(sumw); ArrayFree(prices); return; }
     
     //
     //---
     //
     
     double Calculate(double price, int calcPeriod, int i)
     {
        if (originalPeriod!=calcPeriod)
        {
           #define _ringSize 32
           
               originalPeriod =  calcPeriod;
               period         = (calcPeriod>1) ? calcPeriod : 1;
               arraySize      = period+_ringSize;
                     ArrayResize(sump  ,arraySize); ArrayInitialize(sump  ,0);
                     ArrayResize(sumw  ,arraySize); ArrayInitialize(sumw  ,0);
                     ArrayResize(prices,arraySize); ArrayInitialize(prices,0);
            #undef _ringSize
         }

         int _indC = (i) % arraySize; prices[_indC] = price;
            
         //
         //
         //
               
         if (i>period)
         {
            int _indP = _indC-1;      if (_indP<0) _indP += arraySize;
            int _indF = _indC-period; if (_indF<0) _indF += arraySize;
               sump[_indC] = sump[_indP]+prices[_indC]-prices[_indF];
               sumw[_indC] = sumw[_indP]+sump[_indC]  -prices[_indF]*period;
         }         
         else
         {
               sump[_indC] =
               sumw[_indC] = prices[_indC];
               for(int k=1,_indP=_indC-1; k<period; k++,_indP--)
               {
                  if (_indP<0) _indP += arraySize;
                     sump[_indC] += prices[_indP];
                     sumw[_indC] += prices[_indP]*(k+1);
               }
         }
         return(-sumw[_indC]/sump[_indC]);
     }
};
cCg iCg;

//------------------------------------------------------------------