//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "rsi"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrLimeGreen,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

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
input int      RsxPeriod  = 32;       // RSX period
input int      MomPeriod  =  4;       // Momentum period (1 for original rsx)
input enPrices RsxPrice   = pr_close; // Price

double rsi[],rsic[];

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
   SetIndexBuffer(0,rsi  ,INDICATOR_DATA); 
   SetIndexBuffer(1,rsic ,INDICATOR_COLOR_INDEX); 
      IndicatorSetString(INDICATOR_SHORTNAME,"RSX variation ("+(string)RsxPeriod+","+(string)MomPeriod+")");
      
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

double wrkBuffer[][13];
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
   if (ArrayRange(wrkBuffer,0)!=rates_total) ArrayResize(wrkBuffer,rates_total);

   //
   //
   //
   //
   //

   double Kg = (3.0)/(2.0+RsxPeriod), Hg = 1.0-Kg;
   int momPeriod = MathMax(MomPeriod,1);
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      for (int c=0; c<12; c++) wrkBuffer[i][c] = 0; wrkBuffer[i][12] = getPrice(RsxPrice,open,close,high,low,i,rates_total);

      //
      //
      //
      //
      //
      
      double roc = (i>momPeriod) ? wrkBuffer[i][12]-wrkBuffer[i-momPeriod][12] : 0;
      double roa = MathAbs(roc);
      if (i>0) for (int k=0; k<3; k++)
      {
         int kk = k*2;
            wrkBuffer[i][kk+0] = Kg*roc                + Hg*wrkBuffer[i-1][kk+0];
            wrkBuffer[i][kk+1] = Kg*wrkBuffer[i][kk+0] + Hg*wrkBuffer[i-1][kk+1]; roc = 1.5*wrkBuffer[i][kk+0] - 0.5 * wrkBuffer[i][kk+1];
            wrkBuffer[i][kk+6] = Kg*roa                + Hg*wrkBuffer[i-1][kk+6];
            wrkBuffer[i][kk+7] = Kg*wrkBuffer[i][kk+6] + Hg*wrkBuffer[i-1][kk+7]; roa = 1.5*wrkBuffer[i][kk+6] - 0.5 * wrkBuffer[i][kk+7];
      }
      rsi[i]  = (roa!=0) ? MathMax(MathMin((roc/roa+1.0)*50.0,100.00),0.00) : 0; 
      rsic[i] = (i>0)    ? (rsi[i]>rsi[i-1]) ? 1 : (rsi[i]<rsi[i-1]) ? 2 : rsic[i-1] : 0;
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