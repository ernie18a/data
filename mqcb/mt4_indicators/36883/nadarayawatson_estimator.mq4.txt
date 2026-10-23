//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Nadaraya-Watson estimator"
#property description "Based on work published by luxAlgo"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  3
#property indicator_plots    3
#property indicator_label1   "Estimator"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrDeepSkyBlue,clrCoral
#property indicator_width1   2
#property indicator_label2   "Estimator down"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrCoral
#property indicator_width2   2
#property indicator_label3   "Estimator down"
#property indicator_type3    DRAW_LINE
#property indicator_color3   clrCoral
#property indicator_width3   2
#property strict

//
//
//

input double             inpBandWidth       = 8;           // Band width
input ENUM_APPLIED_PRICE inpPrice           = PRICE_CLOSE; // Price
input int                inpBarsToCalculate = 500;         // Bars to calculate for estimations

//
//
//

double val[],valda[],valdb[],valc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   IndicatorBuffers(4);
      SetIndexBuffer(0,val  ,INDICATOR_DATA);
      SetIndexBuffer(1,valda,INDICATOR_DATA);
      SetIndexBuffer(2,valdb,INDICATOR_DATA);
      SetIndexBuffer(3,valc ,INDICATOR_CALCULATIONS);
   
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
   int _limit           = (prev_calculated>0) ? rates_total-prev_calculated : rates_total-1;
   int _barsToCaclulate = MathMin(inpBarsToCalculate,rates_total-1);

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
   
      if (_barsToCaclulate<rates_total && valc[_barsToCaclulate]==1) iCleanPoint(_barsToCaclulate,rates_total,valda,valdb);

      for (int i=_limit; i>=0; i--) m_work[rates_total-i-1].price = iGetPrice(inpPrice,open,high,low,close,i);
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
            val[i] = sum/sumw;
         }
      for (int i=_barsToCaclulate; i>=0; i--) 
         {
            valc[i]= (i<rates_total-1) ? val[i]>val[i+1] ? 0 : 1 : 0;
            if (valc[i]==1) iPlotPoint(i,rates_total,valda,valdb,val); else valda[i] = valdb[i] = EMPTY_VALUE;
         }
      
      //
      //
      //
      
      for (int i=0; i<3; i++) SetIndexDrawBegin(i,rates_total-_barsToCaclulate+1);      
   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//

template <typename T>
void iCleanPoint(int i, int bars, T& first[], T& second[])
{
   if (i>=bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i]  != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
           first[i+1] = EMPTY_VALUE;
}

template <typename T>
void iPlotPoint(int i, int bars, T& first[], T& second[], T& source[])
{
   if (i>=bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = source[i]; first[i+1]  = source[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = source[i]; second[i+1] = source[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = source[i];                            second[i] = EMPTY_VALUE; }
}

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