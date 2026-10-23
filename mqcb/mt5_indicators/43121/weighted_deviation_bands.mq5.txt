//------------------------------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2023"
#property link        "mladenfx@gmail.com"
#property description "Momentum deviation bands"
#property version     "1.00"
//------------------------------------------------------------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  3
#property indicator_plots    3
#property indicator_label1   "Upper band"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrLimeGreen
#property indicator_style1   STYLE_DASHDOTDOT
#property indicator_label2   "Average"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrDarkGray
#property indicator_label3   "Lower band"
#property indicator_type3    DRAW_LINE
#property indicator_color3   clrCoral
#property indicator_style3   STYLE_DASHDOTDOT

//
//
//

input int                inpPeriod     = 30;          // Period
input double             inpMultiplier = 2.0;         // Deviations
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price

//
//
//

double val[],bandup[],banddn[];
struct sGlobalStruct
{
   int period;
};
sGlobalStruct global;

//------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,bandup,INDICATOR_DATA);
   SetIndexBuffer(1,val   ,INDICATOR_DATA);
   SetIndexBuffer(2,banddn,INDICATOR_DATA);
   
      //
      //
      //

      global.period = MathMax(inpPeriod,1);
      
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Weighted deviation bands (%i,%.2f)",inpPeriod,inpMultiplier));
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------
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
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   //
   //
   //

      for (int i=limit; i<rates_total && !_StopFlag; i++)
         {

            double _deviation = iDeviationWeighted(iGetPrice(inpPrice,open,high,low,close,i),global.period,val[i],i,rates_total);
                     bandup[i] = val[i] + _deviation*inpMultiplier;
                     banddn[i] = val[i] - _deviation*inpMultiplier;
         }

   return(rates_total);
}

//------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------
//
//
//

double iDeviationWeighted(double value, int period, double& average, int i, int bars)
{
   struct sCalcStruct
         {
               struct sWorkStruct
                     {
                        double value;
                        double valueSum;
                        double valueWeightSum;
                     };
               sWorkStruct data[];
               int         dataSize;                     
               double      weightSum;

               //
               //
               //
               
               sCalcStruct() : dataSize(-1) {}
         };
   static sCalcStruct m_work;               
                  if (m_work.dataSize<=bars) m_work.dataSize = ArrayResize(m_work.data,bars+500,5000);
                  if (period<1) period = 1;

   //
   //
   //

      m_work.data[i].value = value;
            if (i >= period)
                     {
                        m_work.data[i].valueSum       = m_work.data[i-1].valueSum       + m_work.data[i].value - m_work.data[i-period].value;
                        m_work.data[i].valueWeightSum = m_work.data[i-1].valueWeightSum - m_work.data[i-1].valueSum + m_work.data[i].value*(double)period;
                     }
            else
                     {
                        period = i+1;
                        m_work.weightSum              = (double)period;
                        m_work.data[i].valueWeightSum = (double)period*m_work.data[i].value;
                        m_work.data[i].valueSum       =                m_work.data[i].value;
                 
                        //
                        //
                        //
                  
                        for(int k=1; k<period && i>=k; k++)
                           {
                              double weight = period-k;
                                              m_work.weightSum              +=                        weight;
                                              m_work.data[i].valueWeightSum += m_work.data[i-k].value*weight;  
                                              m_work.data[i].valueSum       += m_work.data[i-k].value;  
                           }         
                     }

               //
               //
               //
               
               double mean = average = m_work.data[i].valueWeightSum/m_work.weightSum;
               double sums = 0;

               for (int k=0, weight=period; k<period && i>=k; k++,weight--)
                     {
                        sums += (double)weight*(m_work.data[i-k].value-mean)*(m_work.data[i-k].value-mean);
                     }

   //
   //
   //
         
   return(sqrt(sums/m_work.weightSum));
}

//------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------
//
//
//

template <typename type>
double iGetPrice(ENUM_APPLIED_PRICE tprice, type& open[], type& high[], type& low[], type& close[], int i)
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