//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Adaptive Moving Average - generalized version"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "AMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//
//

input int                inpPeriod     = 14;          // Period
input int                inpFastPeriod =  2;          // Fast end period
input int                inpSlowPeriod = 30;          // Slow end period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price

//
//---
//

double val[],valc[],prices[];

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
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
            iAma.init(inpPeriod,inpFastPeriod,inpSlowPeriod);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"AMA ("+(string)inpPeriod+","+(string)inpFastPeriod+","+(string)inpSlowPeriod+")");
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
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         iAma.calculate(prices[i],val,prices,prices,i);
         valc[i]=(i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class CAma
{
   private :
      int    m_period;
      int    m_prev_i;
      double m_fastEnd;
      double m_slowEnd;
      double m_multiplier;
      double m_prev_max;
      double m_prev_min;
      

   public :
      CAma(void) { init(1,2,30); return; }
     ~CAma(void) {               return; }
    
      //
      //
      //

      bool init(int period, double fastEnd, double slowEnd)
      {
         m_period    = (period>1) ? period+1 : 2;
         m_fastEnd   = (2.0 /(fastEnd + 1.0));
         m_slowEnd   = (2.0 /(slowEnd + 1.0));
         return(true);
      }
      
      template <typename T1, typename T2, typename T3>
      void calculate(double value, T1 &target[], T2 &arrayMax[], T3 &arrayMin[], int i) 
      {       
         if (m_prev_i!=i)
         {
            m_prev_i = i; 
            int start    = i-m_period+1; if (start<0) start=0;
                m_prev_max = arrayMax[ArrayMaximum(arrayMax,start,m_period-1)];
                m_prev_min = arrayMin[ArrayMinimum(arrayMin,start,m_period-1)];
         }
         double max = (arrayMax[i] > m_prev_max) ? arrayMax[i] : m_prev_max;
         double min = (arrayMin[i] < m_prev_min) ? arrayMin[i] : m_prev_min;

         //
         //---
         //

         double mltp = (max!=min) ? ((value-min)-(max-value))/(max-min) : 1; if (mltp<0) mltp *= -1;
         double ssc  = mltp * ( m_fastEnd-m_slowEnd) + m_slowEnd;	
                target[i] = (i>0) ? target[i-1]+(ssc*ssc)*(value-target[i-1]) : value;
      }
};
CAma iAma;