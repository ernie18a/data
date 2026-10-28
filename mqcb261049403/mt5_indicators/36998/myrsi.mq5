//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "MyRsi"
#property description "Based on work published by John Ehlers"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  1
#property indicator_plots    1
#property indicator_label1   "MyRsi"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrDeepSkyBlue

//
//
//

input int                inpRsiPeriod = 14;          // MyRsi period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price

//
//
//

double val[];
struct sGlobalStruct
{
   int periodRsi;
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
   SetIndexBuffer(0,val,INDICATOR_DATA);
   
      //
      //
      //
      
      global.periodRsi = MathMax(inpRsiPeriod,1);

      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("MyRsi (%i)",global.periodRsi));            
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
               double diffUp;
               double diffDn;
               double diffUpSum;
               double diffDnSum;
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
            
               //
               //
               //
               
                  double _diff = (i>0) ? (m_work[i].price-m_work[i-1].price) : 0;
                     m_work[i].diffUp = (_diff>0) ?  _diff : 0;
                     m_work[i].diffDn = (_diff<0) ? -_diff : 0;
                  
                     if (i>global.periodRsi) 
                        {
                              m_work[i].diffUpSum = m_work[i-1].diffUpSum + m_work[i].diffUp - m_work[i-global.periodRsi].diffUp;
                              m_work[i].diffDnSum = m_work[i-1].diffDnSum + m_work[i].diffDn - m_work[i-global.periodRsi].diffDn;
                        }
                     else
                        {
                              m_work[i].diffUpSum = m_work[i].diffUp;
                              m_work[i].diffDnSum = m_work[i].diffDn;
                                 for (int k=1; k<global.periodRsi && i>=k; k++)
                                    {
                                       m_work[i].diffUpSum += m_work[i-k].diffUp;
                                       m_work[i].diffDnSum += m_work[i-k].diffDn;
                                    }
                        }      
                  
                  double _diffSum = m_work[i].diffUpSum + m_work[i].diffDnSum;
                     val[i] = (_diffSum) ? (m_work[i].diffUpSum - m_work[i].diffDnSum)/_diffSum : 0;
               
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