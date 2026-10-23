//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   8
#property indicator_label8  "Trix"
#property indicator_type8   DRAW_COLOR_LINE
#property indicator_color8  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width8  2

//
//---
//

enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m2  = PERIOD_M2,      // 2 minutes
   tf_m3  = PERIOD_M3,      // 3 minutes
   tf_m4  = PERIOD_M4,      // 4 minutes
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m6  = PERIOD_M6,      // 6 minutes
   tf_m10 = PERIOD_M10,     // 10 minutes
   tf_m12 = PERIOD_M12,     // 12 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m20 = PERIOD_M20,     // 20 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h2  = PERIOD_H2,      // 2 hours
   tf_h3  = PERIOD_H3,      // 3 hours
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_h6  = PERIOD_H6,      // 6 hours
   tf_h8  = PERIOD_H8,      // 8 hours
   tf_h12 = PERIOD_H12,     // 12 hours
   tf_d1  = PERIOD_D1,      // daily
   tf_w1  = PERIOD_W1,      // weekly
   tf_mn  = PERIOD_MN1,     // monthly
   tf_cp1 = -1,             // Next higher time frame
   tf_cp2 = -2,             // Second higher time frame
   tf_cp3 = -3              // Third higher time frame
};
input enTimeFrames       inpTimeFrame = tf_h4;             // Time frame
input int                inpPeriod    = 32;                // Period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE;       // Price
input color              inpColorSup  = clrOrangeRed;      // Support color
input color              inpColorRes  = clrMediumSeaGreen; // Resistance color
input color              inpColorPiv  = clrGray;           // Resistance color
enum enDisplayType
{
   type_1=0, // Display pivot only
   type_2=1, // Display pivot + SR 1
   type_3=2, // Display pivot + SR 1,2
   type_4=3, // Display pivot + SR 1,2,3
};
input enDisplayType inpDisplayType = type_3; // Display type

//
//---
//

double val[],valc[],sup1[],sup2[],sup3[],res1[],res2[],res3[],piv[],positive[];
ENUM_TIMEFRAMES _pivotsTimeFrame;

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------
//
//---
//

int OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,sup3,INDICATOR_DATA);
         SetIndexBuffer(1,sup2,INDICATOR_DATA);
         SetIndexBuffer(2,sup1,INDICATOR_DATA);
         SetIndexBuffer(3,piv ,INDICATOR_DATA);
         SetIndexBuffer(4,res1,INDICATOR_DATA);
         SetIndexBuffer(5,res2,INDICATOR_DATA);
         SetIndexBuffer(6,res3,INDICATOR_DATA);
         SetIndexBuffer(7,val ,INDICATOR_DATA);
         SetIndexBuffer(8,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(9,positive,INDICATOR_CALCULATIONS);
            for (int i=0; i<7; i++)
            {
               switch (i)
               {
                  case 0 : 
                  case 1 : 
                  case 2 : PlotIndexSetInteger(i,PLOT_LINE_COLOR,inpColorSup); break;
                  case 3 : PlotIndexSetInteger(i,PLOT_LINE_COLOR,inpColorPiv); break;
                  case 4 : 
                  case 5 : 
                  case 6 : PlotIndexSetInteger(i,PLOT_LINE_COLOR,inpColorRes); break;
               }
               PlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_LINE);                
               PlotIndexSetInteger(i,PLOT_LINE_STYLE,STYLE_DOT);
               PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
            }
            
            iTrix.init(inpPeriod);
            _pivotsTimeFrame = MathMax(_Period,timeFrameGet(inpTimeFrame));
   //            
   //----
   //
 
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(_pivotsTimeFrame)+" Trix ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _shiftBy 100000.0
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
   static int    prev_i=-1;
   static double prev_max=0,prev_min=0,prev_close=0;

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = iTrix.calculate(_price,i,rates_total); positive[i] = val[i]+_shiftBy;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
      sup1[i] = sup2[i] = sup3[i] = res1[i] = res2[i] = res3[i] = EMPTY_VALUE;
      
      //
      //
      //
      
         if (prev_i!=i)
         {
            prev_i = i; 
               datetime _startTime = iTime(_Symbol,_pivotsTimeFrame,iBarShift(_Symbol,_pivotsTimeFrame,time[i])+1);
               datetime _endTime   = iTime(_Symbol,_pivotsTimeFrame,iBarShift(_Symbol,_pivotsTimeFrame,time[i]));
               int      _startBar  = iBarShift(_Symbol,_Period,_startTime);
               int      _endBar    = iBarShift(_Symbol,_Period,_endTime);
               if (_endBar < _startBar) 
               {
                  int _period = _startBar-_endBar;
                  int _start  = rates_total-_startBar-1; if (_start<0) _start=0;
                     prev_max = positive[ArrayMaximum(positive,_start,_period)];
                     prev_min = positive[ArrayMinimum(positive,_start,_period)];
               }         
               prev_close = (_endBar>0) ? positive[rates_total-_endBar-1] : positive[i];
         }
         
         //
         //---
         //
         
            double range = (prev_max-prev_min);
            double pivot = (prev_max+prev_min+prev_close)/3.0;
            switch (inpDisplayType)
            {
               case 3 : 
                        res3[i] = pivot*2.0+prev_max-prev_min*2.0-_shiftBy;
                        sup3[i] = pivot*2.0+prev_min-prev_max*2.0-_shiftBy;
               case 2 :                         
                        res2[i] = pivot    +range-_shiftBy;
                        sup2[i] = pivot    -range-_shiftBy;
               case 1 :                         
                        res1[i] = pivot*2.0-prev_min-_shiftBy;
                        sup1[i] = pivot*2.0-prev_max-_shiftBy;
               case 0 : piv[i]  = pivot             -_shiftBy;
            }               
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CTrix
{
   private :
      double m_period;
      double m_alpha;
      int    m_arraySize;
      struct sTrixStruct
      {
         double price;
         double ema1;
         double ema2;
         double ema3;
      };
      sTrixStruct m_array[];
   
   public :
      CTrix() : m_arraySize(-1), m_alpha(1) {}
     ~CTrix() { ArrayFree(m_array); };
      
      //
      //
      //
      
      bool init(int period)
      {
         m_period = (period>1) ? period : 1;
         m_alpha  = (2.0/(2.0+(m_period-1.0)/2.0));
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
            m_array[i].ema1 = m_array[i-1].ema1 + m_alpha*(price          -m_array[i-1].ema1);
            m_array[i].ema2 = m_array[i-1].ema2 + m_alpha*(m_array[i].ema1-m_array[i-1].ema2);
            m_array[i].ema3 = m_array[i-1].ema3 + m_alpha*(m_array[i].ema2-m_array[i-1].ema3);
               return((m_array[i].ema3-m_array[i-1].ema3)/m_array[i].ema3);
         }
         else m_array[i].ema1 = m_array[i].ema2 = m_array[i].ema3 = price;
               return(0);
      }
};
CTrix iTrix;
//
//---
//

ENUM_TIMEFRAMES _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string          _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};

//
//---
//

string timeFrameToString(int period)
{
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
}

//
//---
//

ENUM_TIMEFRAMES timeFrameGet(int period)
{
   int _shift = (period<0 ? MathAbs(period) : 0); if (period<=0) period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
      return(_tfsPer[(int)MathMin(i+_shift,ArraySize(_tfsPer)-1)]);
}
//------------------------------------------------------------------