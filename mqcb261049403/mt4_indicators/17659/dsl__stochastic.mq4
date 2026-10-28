//------------------------------------------------------------------
#property copyright   "copyright© mladen"
#property description "discontinued signal lines stochastic"
#property description "made by mladen"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  clrDimGray
#property indicator_color2  clrDimGray
#property indicator_color3  clrSilver
#property indicator_color4  clrLimeGreen
#property indicator_color5  clrLimeGreen
#property indicator_color6  clrOrange
#property indicator_color7  clrOrange
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property strict

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

extern int      StochasticPeriod  = 14;       // Stochastic period
extern int      StochasticSlowing =  3;       // Stochastic slowing period
extern double   SignalPeriod      = 9;        // Signal period
extern enPrices PriceH            = pr_high;  // Price for high
extern enPrices PriceL            = pr_low;   // Price for low
extern enPrices PriceC            = pr_close; // Price for close

double val[],valua[],valub[],valda[],valdb[],levelu[],leveld[],state[];

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
   IndicatorBuffers(8);
      SetIndexBuffer(0,levelu);
      SetIndexBuffer(1,leveld);
      SetIndexBuffer(2,val);
      SetIndexBuffer(3,valua);
      SetIndexBuffer(4,valub);
      SetIndexBuffer(5,valda);
      SetIndexBuffer(6,valdb);
      SetIndexBuffer(7,state);
   IndicatorShortName("dsl stochastic ("+(string)StochasticPeriod+","+(string)StochasticSlowing+", dsl period : "+(string)SignalPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& time[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[])
{
   int limit=MathMax(rates_total-prev_calculated-1,0);

   //
   //
   //
   //
   //

   double alpha = 2.0/(1.0+SignalPeriod);
      if (state[limit]== 1) CleanPoint(limit,valua,valub);
      if (state[limit]==-1) CleanPoint(limit,valda,valdb);
      int i=limit; for(; i>=0 && !_StopFlag; i--)
      {
         double prices[3]; prices[0] = getPrice(PriceH,open,close,high,low,i,Bars);
                           prices[1] = getPrice(PriceL,open,close,high,low,i,Bars);
                           prices[2] = getPrice(PriceC,open,close,high,low,i,Bars);
                           ArraySort(prices);
         val[i]    = iStoch(prices[1],prices[2],prices[0],StochasticPeriod,StochasticSlowing,i,Bars);
         levelu[i] = (i<Bars-1) ? (val[i]>50) ? levelu[i+1]+alpha*(val[i]-levelu[i+1]) : levelu[i+1] : 0;
         leveld[i] = (i<Bars-1) ? (val[i]<50) ? leveld[i+1]+alpha*(val[i]-leveld[i+1]) : leveld[i+1] : 0;
         state[i]  = (val[i]>levelu[i]) ? 1 : (val[i]<leveld[i]) ? -1 :  0;
         valda[i]  = EMPTY_VALUE;
         valdb[i]  = EMPTY_VALUE;
         valua[i]  = EMPTY_VALUE;
         valub[i]  = EMPTY_VALUE;
            if (state[i]== 1) PlotPoint(i,valua,valub,val);
            if (state[i]==-1) PlotPoint(i,valda,valdb,val);
      }
   return(rates_total-i-1);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

#define _stochInstances     1
#define _stochInstancesSize 5
double workSto[][_stochInstances*_stochInstancesSize];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
double iStoch(double priceR, double priceH, double priceL, int period, int slowing, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workSto,0)!=bars) ArrayResize(workSto,bars); i = bars-i-1; instanceNo *= _stochInstancesSize;
   
   //
   //
   //
   //
   //
   
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
      for (int k=1; k<period && (i-k)>=0; k++)
      {
         workSto[i][_mi+instanceNo] = MathMin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
         workSto[i][_ma+instanceNo] = MathMax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
      }                   
      double sumlow  = 0.0;
      double sumhigh = 0.0;
      for(int k=0; k<slowing && (i-k)>=0; k++)
      {
         sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
         sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
      }

   //
   //
   //
   //
   //
   
   if(sumhigh!=0.0) 
         return(100.0*sumlow/sumhigh);
   else  return(0);    
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

#define _priceInstances     3
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
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

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-2) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}