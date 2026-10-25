//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Stochastic of choosable price - extended with floating levels"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   5
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Stochastic"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2
#property indicator_label5  "Signal"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_DOT
#include <MovingAverages.mqh>

//
//--- input parameters
//

enum enPrices
{
   pr_close   =PRICE_CLOSE,    // Close
   pr_open    =PRICE_OPEN,     // Open
   pr_high    =PRICE_HIGH,     // High
   pr_low     =PRICE_LOW,      // Low
   pr_median  =PRICE_MEDIAN,   // Median
   pr_typical =PRICE_TYPICAL,  // Typical
   pr_weighted=PRICE_WEIGHTED, // Wighted
   pr_highlow =-99             // High/Low
};
input int                inpStoPeriod  = 32;          // Stochastic period
input int                inpStoSlowing =  5;          // Stochastic slowing
input int                inpStoSignal  =  5;          // Stochastic signal period
input ENUM_MA_METHOD     inpStoMethod  = MODE_EMA;    // Stochastic signal method
input enPrices           inpPrice      = pr_close;    // Price 
input int                inpFlPeriod   = 25;          // Floating levels period
input double             inpFlLevelUp  = 90;          // Floating levels up %
input double             inpFlLevelDn  = 10;          // Floating levels down %

//
//--- buffers declarations
//

double sto[],stoc[],sig[],levu[],levd[],levm[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,levu,INDICATOR_DATA);
         SetIndexBuffer(1,levm,INDICATOR_DATA);
         SetIndexBuffer(2,levd,INDICATOR_DATA);
         SetIndexBuffer(3,sto ,INDICATOR_DATA);
         SetIndexBuffer(4,stoc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,sig ,INDICATOR_DATA);
         
         //
         //---
         //

         string _priceType = StringSubstr(EnumToString(inpPrice),3);
                _priceType = (_priceType!="highlow") ? _priceType+"/"+_priceType : "low/high";
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic "+_priceType+" ("+(string)inpStoPeriod+","+(string)inpStoSlowing+","+(string)inpStoSignal+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int start= prev_calculated-1; if (start<0) start=0; for (int i=start; i<rates_total && !_StopFlag; i++)
   {
      double _price,_priceh,_pricel; 
      switch(inpPrice) 
      { 
         case pr_close:    _price = _priceh = _pricel = close[i];                               break; 
         case pr_open:     _price = _priceh = _pricel = open[i];                                break; 
         case pr_high:     _price = _priceh = _pricel = high[i];                                break; 
         case pr_low:      _price = _priceh = _pricel = low[i];                                 break; 
         case pr_median:   _price = _priceh = _pricel = (high[i]+low[i])/2.0;                   break; 
         case pr_typical:  _price = _priceh = _pricel = (high[i]+low[i]+close[i])/3.0;          break; 
         case pr_weighted: _price = _priceh = _pricel = (high[i]+low[i]+close[i]+close[i])/4.0; break; 
         default :         _price  = close[i];
                           _priceh = high[i];
                           _pricel = low[i];
      }
      sto[i] = iStoch.calculate(_price,_priceh,_pricel,inpStoPeriod,inpStoSlowing,i);
         double _min,_max; _levelsMinMax.calculate(sto[i],sto[i],inpFlPeriod,_min,_max,i);
         double range = (_max-_min)/100.0;
         levu[i] = _min+inpFlLevelUp*range;
         levd[i] = _min+inpFlLevelDn*range;
         levm[i] = (levu[i]+levd[i])/2;
   }
   int weightsum=0;
   switch (inpStoMethod)
   {
      case MODE_SMA  : SimpleMAOnBuffer(rates_total,prev_calculated,0,inpStoSignal,sto,sig); break;
      case MODE_EMA  : ExponentialMAOnBuffer(rates_total,prev_calculated,0,inpStoSignal,sto,sig); break;
      case MODE_SMMA : SmoothedMAOnBuffer(rates_total,prev_calculated,0,inpStoSignal,sto,sig); break;
      default        : LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,inpStoSignal,sto,sig,weightsum);
   }
   for (int i=start; i<rates_total && !_StopFlag; i++) stoc[i] = (sto[i]>levu[i]) ? 1 : (sto[i]<levd[i]) ? 2 : 0;
   return (rates_total);
}

//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cMinMax
{
   private :
      int    originalPeriod;
      int    period;
      int    prevbar;
      double currmin;
      double currmax;
      double prevmax;
      double prevmin;
      double minArray[];
      double maxArray[];
         
   public :
      cMinMax() { originalPeriod = prevbar = INT_MIN;       return; }
     ~cMinMax() { ArrayFree(minArray); ArrayFree(maxArray); return; }
     
      //
      //
      //
     
      void calculate(double valueMin, double valueMax, int forPeriod, double& min, double& max, int i)
      {
         if (prevbar!=i)
         {
            prevbar = i;
               if (originalPeriod!=forPeriod)
               {
                     originalPeriod =  forPeriod;
                     period         = (forPeriod>0) ? forPeriod : 1;
                     prevmin        = valueMin;
                     prevmax        = valueMax;
                     currmin        = valueMin;
                     currmax        = valueMax;
                           ArrayResize(minArray,period-1); ArrayInitialize(minArray,valueMin);
                           ArrayResize(maxArray,period-1); ArrayInitialize(maxArray,valueMax);
               }
               if (period>1)
               {
                  int _pos = (i) % (period-1);
                     minArray[_pos] = currmin;
                     maxArray[_pos] = currmax;
                     prevmin        = minArray[ArrayMinimum(minArray)];
                     prevmax        = maxArray[ArrayMaximum(maxArray)];
               }
               else  { prevmin = valueMin; prevmax = valueMax; }
         }

         //
         //
         //
            
         currmin = valueMin;
         currmax = valueMax;
            max = (prevmax>valueMax) ? prevmax : valueMax;
            min = (prevmin<valueMin) ? prevmin : valueMin;
         return;
     }
};
cMinMax _levelsMinMax;

//
//---
//

class cStochastic
{
   private :
      int      originalPeriod;
      int      period;
      int      slowing;
      int      slowingSize;
      double   diffh[];
      double   diffl[];
      double   sumh[];
      double   suml[];
      cMinMax* minMax;
         
    public :
      cStochastic() { minMax = new cMinMax; originalPeriod=-1; return; }
     ~cStochastic() { if (CheckPointer(minMax)==POINTER_DYNAMIC) delete(minMax); ArrayFree(diffh); ArrayFree(diffl); ArrayFree(sumh); ArrayFree(suml); return; }
     
     //
     //
     //
     
     double calculate(double price, double priceHigh, double priceLow, int forPeriod, int forSlowing, int i)
     {
         #define _ringSize 32
         if (originalPeriod!=forPeriod)
         {
            originalPeriod =  forPeriod;
            period         = (forPeriod>0) ? forPeriod : 1;
            slowing        = (forSlowing>0) ? forSlowing : 1;
            slowingSize    = slowing+_ringSize;
                  ArrayResize(diffh,slowingSize); ArrayInitialize(diffh,0);
                  ArrayResize(diffl,slowingSize); ArrayInitialize(diffl,0);
                  ArrayResize(sumh ,slowingSize); ArrayInitialize(sumh ,0);
                  ArrayResize(suml ,slowingSize); ArrayInitialize(suml ,0);
         }
         #undef _ringSize
      
         //
         //---
         //
      
         double min,max; minMax.calculate(priceLow,priceHigh,period,min,max,i);
         int _pos = (i) % slowingSize;
               diffh[_pos] = max  -min;
               diffl[_pos] = price-min;

               //
               //---
               //
                       
               if (i>slowing)
               {
                  int _posp = (i-1      ) % slowingSize;
                  int _posf = (i-slowing) % slowingSize;
                     sumh[_pos] = sumh[_posp]+diffh[_pos]-diffh[_posf];
                     suml[_pos] = suml[_posp]+diffl[_pos]-diffl[_posf];
               }
               else
               {
                  sumh[_pos] = diffh[_pos];
                  suml[_pos] = diffl[_pos];
                  for (int k=1, _posp=_pos-1; k<slowing; k++, _posp--)
                  {
                     if (_posp<0) _posp += slowingSize; 
                        sumh[_pos] += diffh[_posp];
                        suml[_pos] += diffl[_posp];
                  }
               }
         return((sumh[_pos]!=0.0)? 100.0*suml[_pos]/sumh[_pos]:0);
      }
};
cStochastic iStoch;
//------------------------------------------------------------------
