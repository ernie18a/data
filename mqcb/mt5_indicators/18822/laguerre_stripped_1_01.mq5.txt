//------------------------------------------------------------------
#property copyright "© mladen, 2017"
#property link      "mladenfx@gmail.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   7
#property indicator_label1  "Fill 1"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'0,205,126',C'155,0,126'
#property indicator_label2  "Fill 2"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'0,180,126',C'180,0,126'
#property indicator_label3  "Fill 3"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  C'0,155,126',C'205,0,126'
#property indicator_label4  "Laguerre 1"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_label5  "Laguerre 2"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_label6  "Laguerre 3"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGray
#property indicator_label7  "Laguerre 4"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGray

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};

input double   Gamma = 0.75;      // Gamma
input enPrices Price = pr_close;  // Price

double lagg1u[],lagg1d[],lagg2u[],lagg2d[],lagg3u[],lagg3d[],lagg1[],lagg2[],lagg3[],lagg4[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,lagg1u ,INDICATOR_DATA);
   SetIndexBuffer(1,lagg1d ,INDICATOR_DATA);
   SetIndexBuffer(2,lagg2u ,INDICATOR_DATA);
   SetIndexBuffer(3,lagg2d ,INDICATOR_DATA);
   SetIndexBuffer(4,lagg3u ,INDICATOR_DATA);
   SetIndexBuffer(5,lagg3d ,INDICATOR_DATA);
   SetIndexBuffer(6,lagg1  ,INDICATOR_DATA);
   SetIndexBuffer(7,lagg2  ,INDICATOR_DATA);
   SetIndexBuffer(8,lagg3  ,INDICATOR_DATA);
   SetIndexBuffer(9,lagg4  ,INDICATOR_DATA);
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{ 
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
   //
   //
   //
   //
   //

   int i=MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
      double laga,lagb,lagc,lagd; 
         iLaGuerre(getPrice(Price,open,close,high,low,i,rates_total),Gamma,laga,lagb,lagc,lagd,i,rates_total,0);
            lagg1[i]  = laga;
            lagg2[i]  = lagb;
            lagg3[i]  = lagc;
            lagg4[i]  = lagd;
            lagg1u[i] = laga;
            lagg1d[i] = lagb;
            lagg2u[i] = lagb;
            lagg2d[i] = lagc;
            lagg3u[i] = lagc;
            lagg3d[i] = lagd;
   }
   return(i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workLag[][4];
void iLaGuerre(double price, double gamma, double& val1, double& val2, double& val3, double& val4, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workLag,0)!=bars) ArrayResize(workLag,bars); instanceNo*=4;

   //
   //
   //
   //
   //

   gamma = MathMax(MathMin(gamma,0.99),0.01);
   if (i>0)
   {      
      workLag[i][instanceNo+0] = (1.0 - gamma)*price                                          + gamma*workLag[i-1][instanceNo+0];
	   workLag[i][instanceNo+1] = -gamma*workLag[i][instanceNo+0] + workLag[i-1][instanceNo+0] + gamma*workLag[i-1][instanceNo+1];
	   workLag[i][instanceNo+2] = -gamma*workLag[i][instanceNo+1] + workLag[i-1][instanceNo+1] + gamma*workLag[i-1][instanceNo+2];
	   workLag[i][instanceNo+3] = -gamma*workLag[i][instanceNo+2] + workLag[i-1][instanceNo+2] + gamma*workLag[i-1][instanceNo+3];
   }	   
   else for (int k=0; k<4; k++) workLag[i][instanceNo+k] = price;
   val1 = workLag[i][instanceNo+0];
   val2 = workLag[i][instanceNo+1];
   val3 = workLag[i][instanceNo+2];
   val4 = workLag[i][instanceNo+3];
}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define _pricesInstances 1
#define _pricesSize      4
double workHa[][_pricesInstances*_pricesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=_pricesSize;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}