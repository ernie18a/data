//------------------------------------------------------------------
#property copyright "© mladen, 2017"
#property link      "mladenfx@gmail.com www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4

#property indicator_label1  "vq zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'209,243,209',C'255,230,183'
#property indicator_label2  "fast average"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "slow average"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Volatility quality"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrOrange
#property indicator_width4  2
  
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
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};

input int       PriceSmoothing         = 5;        // Price smoothing period
input enMaTypes PriceSmoothingMethod   = ma_lwma;  // Price smoothing method
input int       Ma1Period              = 9;        // Fast moving average
input enMaTypes Ma1Method              = ma_sma;   // Fast moving average method
input int       Ma2Period              = 200;      // Slow moving average
input enMaTypes Ma2Method              = ma_sma;   // Slow moving average method
input double    FilterInPips           = 2.0;      // Filter (in pips)

//
//
//
//
//

double val[],valc[],fill1[],fill2[],avg1[],avg2[];

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
   SetIndexBuffer(0,fill1  ,INDICATOR_DATA);
   SetIndexBuffer(1,fill2  ,INDICATOR_DATA);
   SetIndexBuffer(2,avg1   ,INDICATOR_DATA);
   SetIndexBuffer(3,avg2   ,INDICATOR_DATA);
   SetIndexBuffer(4,val    ,INDICATOR_DATA);
   SetIndexBuffer(5,valc   ,INDICATOR_COLOR_INDEX);
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility quality Stridsman ("+(string)PriceSmoothing+","+(string)Ma1Period+")");
   return(0);
}

void OnDeinit(const int reason) { }

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

   double pipMultiplier = MathPow(10,_Digits%2);
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double cHigh  =         iCustomMa(PriceSmoothingMethod,high[i]   ,PriceSmoothing,i  ,rates_total,0);
      double cLow   =         iCustomMa(PriceSmoothingMethod,low[i]    ,PriceSmoothing,i  ,rates_total,1);
      double cOpen  =         iCustomMa(PriceSmoothingMethod,open[i]   ,PriceSmoothing,i  ,rates_total,2);
      double cClose =         iCustomMa(PriceSmoothingMethod,close[i]  ,PriceSmoothing,i  ,rates_total,3);
      double pClose = (i>0) ? iCustomMa(PriceSmoothingMethod,close[i-1],PriceSmoothing,i-1,rates_total,4) : cClose;
         
      double trueRange = MathMax(cHigh,pClose)-MathMin(cLow,pClose);
      double range     = cHigh-cLow;
      double vqi       = (range != 0 && trueRange!=0) ? ((cClose-pClose)/trueRange + (cClose-cOpen)/range)*0.5 : (i>0) ? val[i-1] : 0;

      //
      //
      //
      //
      //
         
         val[i] = (i>0) ? val[i-1]+MathAbs(vqi)*(cClose-pClose+cClose-cOpen)*0.5 : 0;
            if (FilterInPips > 0 && i>0) if (MathAbs(val[i]-val[i-1]) < FilterInPips*pipMultiplier*_Point) val[i] = val[i-1];
            avg1[i]  = iCustomMa(Ma1Method,val[i],Ma1Period,i,rates_total,5);
            avg2[i]  = iCustomMa(Ma2Method,val[i],Ma2Period,i,rates_total,6);
            valc[i]  = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
            fill1[i] =  val[i];
            fill2[i] = (val[i]>avg1[i]) ? val[i] : (val[i]<avg1[i]) ? avg1[i] : val[i];
   }
   return(rates_total);
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

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=4;
         
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

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 7
#define _maWorkBufferx1 1*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); int k;

   workSma[r][instanceNo+0] = price;  
   double avg = price; for(k=1; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
   return(avg/k);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}