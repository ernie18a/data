//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Moving Average Bands Width"
#property description "Based on work published by Vitali Apirine"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  3
#property indicator_plots    2
#property indicator_label1   "Minimum"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrSilver
#property indicator_label2   "Bands width"
#property indicator_type2    DRAW_COLOR_LINE
#property indicator_color2   clrDarkGray,clrRed
#property indicator_width2   2

//
//
//

input double             inpPeriodSlow      = 50;          // Slow/minimums period
input double             inpPeriodFast      = 10;          // Fast period
input double             inpBandMultiplier  = 1.0;         // Bands multiplier
input ENUM_APPLIED_PRICE inpPrice           = PRICE_CLOSE; // Price

//
//
//

double val[],valc[],min[];
struct sGlobalStruct
{
   int    periodSum;
   int    periodMin;
   double periodDiv;
   double alphaFast;
   double alphaSlow;
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
   SetIndexBuffer(0,min ,INDICATOR_DATA);
   SetIndexBuffer(1,val ,INDICATOR_DATA);
   SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
   
      //
      //
      //
      
      double _fast = MathMin(inpPeriodFast,inpPeriodSlow);
      double _slow = MathMax(inpPeriodFast,inpPeriodSlow);
               global.alphaFast = 2.0 / (1.0 + MathMax(_fast,1));
               global.alphaSlow = 2.0 / (1.0 + MathMax(_slow,1));
               global.periodMin = (int)MathMax(_slow,1);
               global.periodSum = (int)MathMax(_fast,1);
               global.periodDiv =      MathMax(_fast,1);

      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("MABV (%.1f,%.1f multiplier %.2f)",_slow,_fast,inpBandMultiplier));
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
               double emaFast;
               double emaSlow;
               double emaDiff;
               double sumDiff;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit; i<rates_total; i++)
         {
            double _price = iGetPrice(inpPrice,open,high,low,close,i);
               m_work[i].emaFast = (i>0) ? m_work[i-1].emaFast + global.alphaFast*(_price-m_work[i-1].emaFast) : _price;
               m_work[i].emaSlow = (i>0) ? m_work[i-1].emaSlow + global.alphaSlow*(_price-m_work[i-1].emaSlow) : _price;
               m_work[i].emaDiff = (m_work[i].emaFast-m_work[i].emaSlow)*(m_work[i].emaFast-m_work[i].emaSlow);
               if (i>global.periodSum)
                     { m_work[i].sumDiff = m_work[i-1].sumDiff + m_work[i].emaDiff - m_work[i-global.periodSum].emaDiff; }
               else  { m_work[i].sumDiff = m_work[i].emaDiff; for (int k=1; k<global.periodSum && i>=k; k++) m_work[i].sumDiff += m_work[i-k].emaDiff; }

            //
            //
            //

            double _dv         = m_work[i].sumDiff/global.periodDiv;
            double _deviation  = (_dv) ? MathSqrt(_dv) * inpBandMultiplier : 0;
            
            //
            //
            //
            
               int _start = i-global.periodMin+1; if (_start<0) _start = 0;
                  val[i]  = 2.0*_deviation/m_work[i].emaSlow;
                  min[i]  = val[ArrayMinimum(val,_start,global.periodMin)];
                  valc[i] = (val[i]==min[i]) ? 1 : 0;
         }

   //
   //
   //

   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//

double iGetPrice(ENUM_APPLIED_PRICE price,const double& open[], const double& high[], const double& low[], const double& close[], int i)
{
   switch (price)
   {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
}