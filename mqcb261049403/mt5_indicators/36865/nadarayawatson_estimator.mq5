//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Nadaraya-Watson estimator"
#property description "Based on work published by luxAlgo"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  2
#property indicator_plots    1
#property indicator_label1   "Estimator"
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1   clrDeepSkyBlue,clrCoral
#property indicator_width1   2

//
//
//

input double             inpBandWidth       = 8;           // Band width
input ENUM_APPLIED_PRICE inpPrice           = PRICE_CLOSE; // Price
input int                inpBarsToCalculate = 500;         // Bars to calculate for estimations

//
//
//

double val[],valc[];

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
   int _limit           = (prev_calculated>0) ? prev_calculated-1 : 0;
   int _barsToCaclulate = MathMin(inpBarsToCalculate,rates_total);

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
   
      for (int i=_limit; i<rates_total; i++) m_work[i].price = iGetPrice(inpPrice,open,high,low,close,i);
      for (int i=0; i<_barsToCaclulate; i++)
         {
            double sum  = 0;
            double sumw = 0;
            for (int j=0; j<_barsToCaclulate; j++)
               {
                  double w = exp(-(pow(i-j,2)/(inpBandWidth*inpBandWidth*2.0)));
                     sum  += m_work[rates_total-j-1].price*w;
                     sumw += w;
               }            
            val[rates_total-i-1] = sum/sumw;
         }
      for (int i=rates_total-_barsToCaclulate; i<rates_total; i++) valc[i]= (i>0) ? val[i]>val[i-1] ? 0 : 1 : 0;
      
      //
      //
      //
      
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-_barsToCaclulate);      
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