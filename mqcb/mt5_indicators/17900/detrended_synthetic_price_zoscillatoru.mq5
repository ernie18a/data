//------------------------------------------------------------------
#property copyright "© mladen, 2017"
#property link      "mladenfx@gmail.com"
#property link      "www.forex-station.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "value"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrange
#property indicator_width3  2

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
enum enColorOn
{
   chg_onZero,   // Change color on zero cross
   chg_onOuter,  // Change color on levels cross
   chg_onOuter2, // Change color on opposite levels cross
   chg_onSlope   // Change color on slope change
};

input int       DspPeriod    = 14;          // DSP period
input enPrices  DspPrice     = pr_median;   // DSP price
input double    SignalPeriod = 9;           // Signal period
input enColorOn ColorOn      = chg_onOuter; // Change color on :

double  val[],valc[],levelu[],leveld[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void OnInit()
{
   SetIndexBuffer(0,levelu,INDICATOR_DATA);
   SetIndexBuffer(1,leveld,INDICATOR_DATA);
   SetIndexBuffer(2,val   ,INDICATOR_DATA);
   SetIndexBuffer(3,valc  ,INDICATOR_COLOR_INDEX);
      IndicatorSetString(INDICATOR_SHORTNAME," (dsl) DSP oscillator  ("+(string)DspPeriod+","+(string)SignalPeriod+")");
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

   double alphas = 2.0/(1.0+SignalPeriod);
   double alpham = 2.0/(1.0+DspPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      double price = getPrice(DspPrice,open,close,high,low,i,rates_total);
         val[i]    = iEma(price,alpham,i,rates_total,0)-iEma(price,alpham/2.0,i,rates_total,1);
         levelu[i] = (i>0) ? (val[i]>0) ? levelu[i-1]+alphas*(val[i]-levelu[i-1]) : levelu[i-1] : 0;
         leveld[i] = (i>0) ? (val[i]<0) ? leveld[i-1]+alphas*(val[i]-leveld[i-1]) : leveld[i-1] : 0;
          switch(ColorOn)
          {
            case chg_onOuter  : valc[i] = (val[i]>levelu[i]) ? 1 : (val[i]<leveld[i]) ? 2 : 0;                    break;
            case chg_onOuter2 : valc[i] = (val[i]>levelu[i]) ? 1 : (val[i]<leveld[i]) ? 2 : (i>0) ? valc[i-1]: 0; break;
            case chg_onZero   : valc[i] = (val[i]>0)         ? 1 : (val[i]<0)         ? 2 : 0;                    break;
            default :           valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
          }
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

double workEma[][2];
double iEma(double price, double alpha, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
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