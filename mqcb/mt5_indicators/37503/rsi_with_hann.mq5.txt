//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Rsi with Hann windowing"
#property description "Based on work published by John Ehlers"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  2
#property indicator_plots    1
#property indicator_label1   "RsiH"
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1   clrDodgerBlue,clrCoral
#property indicator_width1   2

//
//
//

input int                inpRsiPeriod = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price

//
//
//

double val[],valc[];
struct sGlobalStruct
{
   int    periodRsi;
   double coeffs[];
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
      
         global.periodRsi = MathMax(inpRsiPeriod,1);
            ArrayResize(global.coeffs,global.periodRsi);
            for (int i=0; i<global.periodRsi; i++)
                  {
                     double _coeff = 1.0 - MathCos((2.0*M_PI*(i+1))/(global.periodRsi+1.0));
                           global.coeffs[i]  = _coeff;
                  }

      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Rsi with Hann (%i)",global.periodRsi));            
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
               double diff;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit; i<rates_total; i++)
         {
            m_work[i].price = iGetPrice(inpPrice,open,high,low,close,i);
            m_work[i].diff  = (i>0) ? (m_work[i].price-m_work[i-1].price) : 0;
                  

                  //
                  //
                  //
                  
                  double _cu = 0;
                  double _cd = 0;
                        for (int k=0; k<global.periodRsi && i>=k; k++)
                           {
                              if (m_work[i-k].diff>0) _cu +=  m_work[i-k].diff*global.coeffs[k];
                              if (m_work[i-k].diff<0) _cd += -m_work[i-k].diff*global.coeffs[k];
                           }      
            val[i]  = (_cu+_cd!=0) ? (_cu-_cd)/(_cu+_cd) : 0;
            valc[i] = (i>0) ? (val[i]<val[i-1]) ? 1 : (val[i]>val[i-1]) ? 0 : valc[i-1] : 0;
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