//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "deviation variation"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  1
#property indicator_plots    1
#property indicator_label1   "Deviation"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrDarkGray
#property indicator_width1   2

//
//
//

input int                inpPeriod    = 14;          // Period
input int                inpMomPeriod = 2;           // Momentum period
input ENUM_APPLIED_PRICE inpMomPrice  = PRICE_CLOSE; // Momentum price

//
//
//

double val[];
struct sGlobalStruct
{
   int period;
   int periodMomentum;
};
sGlobalStruct global;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   
      //
      //
      //

      global.period         = MathMax(inpPeriod,1);
      global.periodMomentum = MathMax(inpMomPeriod,1);
      
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Deviation variation (%i,%i)",global.period,global.periodMomentum));            
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int _limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   //
   //
   //

      struct sWorkStruct
            {
               double price;
               double momentum;
               double momentumSum;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit; i<rates_total; i++)
         {
            m_work[i].price    = iGetPrice(inpMomPrice,open[i],high[i],low[i],close[i]);
            m_work[i].momentum = (i>global.periodMomentum) ? m_work[i].price - m_work[i-global.periodMomentum].price : m_work[i].price - m_work[0].price;
            
               //
               //
               //
               
                  #define _square(_arg) (_arg*_arg)
                     if (i>global.period)
                           { m_work[i].momentumSum = m_work[i-1].momentumSum + _square(m_work[i].momentum) - _square(m_work[i-global.period].momentum);} 
                     else  { m_work[i].momentumSum = _square(m_work[i].momentum); for (int k=1; k<global.period && i>=k; k++) m_work[i].momentumSum += _square(m_work[i-k].momentum); } 
                  #undef _square                  

               //
               //
               //

            val[i]  = (m_work[i].momentumSum) ? MathSqrt(m_work[i].momentumSum/(double)global.period) : 0;
         }

   //
   //
   //

   return(rates_total);
}

//--------------------------------------------------------------------------------------------------
//                                                                  
//--------------------------------------------------------------------------------------------------
//
//
//

double iGetPrice(ENUM_APPLIED_PRICE price,double open, double high, double low, double close)
{
   switch (price)
   {
      case PRICE_CLOSE:     return(close);
      case PRICE_OPEN:      return(open);
      case PRICE_HIGH:      return(high);
      case PRICE_LOW:       return(low);
      case PRICE_MEDIAN:    return((high+low)/2.0);
      case PRICE_TYPICAL:   return((high+low+close)/3.0);
      case PRICE_WEIGHTED:  return((high+low+close+close)/4.0);
   }
   return(0);
}
