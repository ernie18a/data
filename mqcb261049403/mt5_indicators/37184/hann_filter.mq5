//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Hann windowing filter"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  2
#property indicator_plots    1
#property indicator_label1   "Hann average"
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1   clrDarkGray,clrDeepSkyBlue,clrCoral
#property indicator_width1   2

//
//
//

input int                inpPeriod  = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price
input double             inpSpeedUp = 0.0;         // Spped up factor

//
//
//

double val[],valc[];
struct sGlobalStruct
{
   int    period;
   double coeffs[];
   double coeffsSum;
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

            global.period    = MathMax(inpPeriod,1);
            global.coeffsSum = 0;
               double _speedUp = 1;
               ArrayResize(global.coeffs,global.period);
               for (int i=0; i<global.period; i++)
                  {
                     double _coeff = 1.0 - MathCos((2.0*M_PI*(i+1))/(global.period+1.0));
                           global.coeffs[i]  = _coeff/_speedUp;
                           global.coeffsSum += _coeff/_speedUp;
                                                      _speedUp += MathMax(0,inpSpeedUp);
                  }

      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Hann average (%i)",global.period));            
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
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit; i<rates_total; i++)
         {
            m_work[i].price = iGetPrice(inpPrice,open[i],high[i],low[i],close[i]);

               double dSum = 0; for (int k=0; k<global.period && i>=k; k++) dSum += m_work[i-k].price*global.coeffs[k];
            
            val[i]  = (global.coeffsSum!=0) ? dSum/global.coeffsSum : 0;
            valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
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
