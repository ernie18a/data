//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Triple Exponential Average using double smoothed Wilder's EMA"
#property description "With an addition of floating levels"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
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
#property indicator_label4  "RMO"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2

//
//
//

input int                inpPeriod     = 32;          // TRIX period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on outer levels cross
   cchange_onZero    // Change color on middle level cross
};
input int                inpFlPeriod    = 25;               // Floating levels period
input double             inpFlLevelUp   = 90;               // Floating levels up %
input double             inpFlLevelDn   = 10;               // Floating levels down %
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//---
//

double val[],valc[],levu[],levd[],levm[],prices[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,levu  ,INDICATOR_DATA);
         SetIndexBuffer(1,levm  ,INDICATOR_DATA);
         SetIndexBuffer(2,levd  ,INDICATOR_DATA);
         SetIndexBuffer(3,val   ,INDICATOR_DATA);
         SetIndexBuffer(4,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,prices,INDICATOR_CALCULATIONS);
            iTrix.init(inpPeriod);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"TRIX (ds Wilder's ema)("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

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
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         val[i] =  iTrix.calculate(prices[i],i,rates_total);
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpFlPeriod+1; if (start<0) start=0;
                prev_max = val[ArrayMaximum(val,start,inpFlPeriod-1)];
                prev_min = val[ArrayMinimum(val,start,inpFlPeriod-1)];
         }
         double max = (val[i] > prev_max) ? val[i] : prev_max;
         double min = (val[i] < prev_min) ? val[i]  : prev_min;
         double range = (max-min)/100.0;
            levu[i] = min+inpFlLevelUp*range;
            levd[i] = min+inpFlLevelDn*range;
            levm[i] = (levu[i]+levd[i])/2;
         
         //
         //
         //
         
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class CTrixDsWilders
{
   private :
      double m_period;
      double m_alpha;
      int    m_arraySize;
      struct sTrixDsWildersStruct
      {
         double price;
         double ema10;
         double ema11;
         double ema20;
         double ema21;
         double ema30;
         double ema31;
      };
      sTrixDsWildersStruct m_array[];
   
   public :
      CTrixDsWilders() : m_arraySize(-1), m_alpha(1) {}
     ~CTrixDsWilders() { ArrayFree(m_array); };
      
      //
      //
      //
      
      bool init(int period)
      {
         m_period = (period>1) ? period : 1;
         m_alpha  = 2.0/(1.0+MathSqrt(m_period));
            return(true);
      }
      
      double calculate(double price, int i, int bars)
      {
          if (m_arraySize<bars)
            { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

         //
         //---
         //
      
         if (i>0)
         {
            m_array[i].ema10 = m_array[i-1].ema10 + m_alpha*(price           -m_array[i-1].ema10);
            m_array[i].ema11 = m_array[i-1].ema11 + m_alpha*(m_array[i].ema10-m_array[i-1].ema11);
            m_array[i].ema20 = m_array[i-1].ema20 + m_alpha*(m_array[i].ema11-m_array[i-1].ema20);
            m_array[i].ema21 = m_array[i-1].ema21 + m_alpha*(m_array[i].ema20-m_array[i-1].ema21);
            m_array[i].ema30 = m_array[i-1].ema30 + m_alpha*(m_array[i].ema21-m_array[i-1].ema30);
            m_array[i].ema31 = m_array[i-1].ema31 + m_alpha*(m_array[i].ema30-m_array[i-1].ema31);
               return((m_array[i].ema31-m_array[i-1].ema31)/m_array[i].ema31);
         }
         else m_array[i].ema10 = m_array[i].ema11 = m_array[i].ema20 = m_array[i].ema21 = m_array[i].ema30 = m_array[i].ema31 = price;
               return(0);
      }
};
CTrixDsWilders iTrix;