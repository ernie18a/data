//------------------------------------------------------------------
#property copyright   "© mladen, 2023"
#property link        "mladenfx@gmail.com"
#property description "Hurst exponent"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "Hurst exponent"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_width1  2

//
//
//

input int                inpHurstPeriod    =  30;         // Hurst exponent period
input ENUM_APPLIED_PRICE inpPrice          = PRICE_CLOSE; // Price 

//
//
//

double val[];
struct sGlobalStruct
   {
      int    period;
      double x[];
      double y[];
      double logDivisor;
   };
sGlobalStruct global;
#define koef 1.253314

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);

      //
      //
      //
      
         global.period     = MathMax(inpHurstPeriod,1);
         global.logDivisor = MathLog(global.period);
         
            ArrayResize(global.x,global.period); ArrayInitialize(global.x,0); ArraySetAsSeries(global.x,true);
            ArrayResize(global.y,global.period); ArrayInitialize(global.y,0); ArraySetAsSeries(global.y,true);

      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,"Hurst exponent ("+(string)inpHurstPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;
   
   //
   //
   //

         struct sWorkStruct
               {
                  double value;
                  double valueSum;
               };
         static sWorkStruct m_work[];
         static int         m_workSize = -1;
                        if (m_workSize < rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

   //
   //
   //

   for(int i=limit; i<rates_total && !_StopFlag; i++)
     {
         m_work[i].value = getPrice(inpPrice,open,high,low,close,i);
         
               if (i>=global.period)
                     { m_work[i].valueSum = m_work[i-1].valueSum + m_work[i].value - m_work[i-global.period].value; }
               else  { m_work[i].valueSum = m_work[i].value; for (int k=1; k<global.period && i>=k; k++) m_work[i].valueSum += m_work[i-k].value; }
      
         
         double mean = m_work[i].valueSum/(double)global.period;
         double sums = 0;
         double maxY = 0;
         double minY = 0;

               for(int k=0; k<global.period && i>=k; k++)
                     {
                        global.x[k] = m_work[i-k].value-mean;  sums+=global.x[k]*global.x[k];
                        if (k>0)
                              {
                                 global.y[k] = global.y[k-1] + global.x[k];
                                    if (maxY<global.y[k]) maxY = global.y[k];
                                    if (minY>global.y[k]) minY = global.y[k];
                              }
                        else  {  maxY = minY = global.y[k] = global.x[k]; }                           
                     }
      
         double iValue = (sums!=0) ? (maxY - minY)/(koef * MathSqrt(sums/(double)global.period)) : 0;
         
         //
         //
         //
         
         val[i] = (iValue > 0) ? MathLog(iValue)/ global.logDivisor : 0;
     }
   
   //
   //
   //

   return (rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

double getPrice(ENUM_APPLIED_PRICE tprice, const double &open[], const double &high[], const double &low[], const double &close[], int i)
{
   switch(tprice)
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