//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "SMA with Noise Elimination Technology"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  2
#property indicator_plots    1
#property indicator_label1   "SMA"
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1   clrDeepSkyBlue,clrCoral
#property indicator_width1   2

//
//
//

input int                inpSmaPeriod = 14;          // SMA period
input int                inpNetPeriod = 5;           // NET period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price

//
//
//

double val[],valc[];
struct sGlobalStruct
{
   int    periodNet;
   int    periodSma;
   double netDenom;
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
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   
      //
      //
      //
      
         global.periodSma = MathMax(inpSmaPeriod,1);
         global.periodNet = MathMax(inpNetPeriod,2);
         global.netDenom  = 0.5 * global.periodNet * (global.periodNet - 1);

      //
      //
      //
            
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Sma (%i) with (%i) NET",global.periodSma,global.periodNet));            
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
               double sum;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit; i<rates_total; i++)
         {
            m_work[i].price  = iGetPrice(inpPrice,open,high,low,close,i);
                     if (i>global.periodSma) 
                           { m_work[i].sum = m_work[i-1].sum + m_work[i].price - m_work[i-global.periodSma].price; }
                     else  { m_work[i].sum = m_work[i].price; for (int k=1; k<global.periodSma && i>=k; k++) m_work[i].sum += m_work[i-k].price; }
            
               //
               //
               //
               
                  
               val[i] = m_work[i].sum / (double)global.periodSma;
               
               //
               //
               //
               
                  double _netNum = 0;
                  for (int k=1; k<global.periodNet && i>k; k++)
                  for (int j=0; j<k; j++)
                     {
                        double _diff    = val[i-k-1]-val[i-j-1];
                               _netNum -= (_diff>0) ? 1  : (_diff<0) ? -1 : 0;
                     }
                  double net = _netNum/global.netDenom;
                  valc[i] = (net>0) ? 0 : (net<0) ? 1 : (i>0) ? valc[i-1] : 0;
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