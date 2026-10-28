//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "nema"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGray,clrDodgerBlue,clrSandyBrown
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
input double   NemaPeriod  = 14;       // NEMA period
input int      NemaDepth   = 1;        // NEMA depth
input enPrices NemaPrice   = pr_close; // Price

double nema[],nemac[];

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
   SetIndexBuffer(0,nema ,INDICATOR_DATA); 
   SetIndexBuffer(1,nemac,INDICATOR_COLOR_INDEX); 
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

double x[],xp[],xf[];
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
   if (Bars(_Symbol,_Period)<rates_total) return(0);
      int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
      {
         nema[i]  = iNema(getPrice(NemaPrice,open,close,high,low,i,rates_total),NemaPeriod,NemaDepth,i,rates_total); 
         nemac[i] = (i>0) ? (nema[i]>nema[i-1]) ? 1 : (nema[i]<nema[i-1]) ? 2 : nemac[i-1] : 0;
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

#define _nemaInstances     1
#define _nemaInstancesSize 51
#define _nemcInstancesSize 51
#define _nema              50
double  _workNema[][_nemaInstances*_nemaInstancesSize];
double  _workNemc[][               _nemcInstancesSize];

double iNema(double value, double period, int depth, int i, int bars, int instanceNo=0)
{
   depth = MathMax(MathMin(depth,_nemcInstancesSize-1),1); 
      int cInstance = instanceNo; instanceNo *= _nemaInstancesSize;
         if (ArrayRange(_workNema,0) != bars)         ArrayResize(_workNema,bars);         
         if (ArrayRange(_workNemc,0) < cInstance+1) { ArrayResize(_workNemc,cInstance+1); _workNemc[cInstance][0]=-1; }
         if (_workNemc[cInstance][0] != depth)
            {_workNemc[cInstance][0]  = depth; for(int k=1; k<=depth; k++) _workNemc[cInstance][k] = factorial(depth)/(factorial(depth-k)*factorial(k)); }
      
   //
   //
   //
   //
   //

   _workNema[i][instanceNo+_nema] = value;
      if (period>1)
      {
         double alpha = 2.0/(1.0+period), sign=1; _workNema[i][instanceNo+_nema] = 0;
         for (int k=0; k<depth; k++, sign *= -1)
         {
            _workNema[i][instanceNo+k    ]  = (i>0) ? _workNema[i-1][instanceNo+k]+alpha*(value-_workNema[i-1][instanceNo+k]) : value; value = _workNema[i][instanceNo+k];
            _workNema[i][instanceNo+_nema] += value*sign*_workNemc[cInstance][k+1];
         }  
      }     
   return(_workNema[i][instanceNo+_nema]);
}
double factorial(int n) { double a=1; for(int i=1; i<=n; i++) a*=i; return(a); }

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