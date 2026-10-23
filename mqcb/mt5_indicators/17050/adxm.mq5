//------------------------------------------------------------------
#property copyright   "© mladen, 2016, MetaQuotes Software Corp."
#property link        "www.forex-tsd.com, forge.mql5.io"
#property version     "1.00"
#property description "original mt4 version was made by ANG3110"
#property description "this version made by Mladen"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "ADXm"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGray,clrDodgerBlue,clrSandyBrown
#property indicator_width1  3
#property indicator_label2  "ADXm DI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT

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
input int      AdxmPeriod  = 14;        // ADXm period
input enPrices AdxmPriceC  = pr_close;  // Price to use for close
input enPrices AdxmPriceH  = pr_high;   // Price to use for high
input enPrices AdxmPriceL  = pr_low;    // Price to use for low
input double   AdxmLevels  = 25;        // Levels

double val[],valc[],di[];
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
   SetIndexBuffer(0,val ,INDICATOR_DATA); 
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(2,di  ,INDICATOR_DATA); 
      IndicatorSetInteger(INDICATOR_LEVELS,2); 
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,-AdxmLevels);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1, AdxmLevels);
   IndicatorSetString(INDICATOR_SHORTNAME,"ADXm ("+(string)AdxmPeriod+")");
   return(0);
}

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
   if (Bars(_Symbol,_Period)<rates_total) return(0);
   int i; for (i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double _prices[3],_di=0,_adx=0;
             _prices[0] = getPrice(AdxmPriceC,open,close,high,low,i,rates_total,0);
             _prices[1] = getPrice(AdxmPriceH,open,close,high,low,i,rates_total,1);
             _prices[2] = getPrice(AdxmPriceL,open,close,high,low,i,rates_total,2);
               ArraySort(_prices);
                   iAdxm(_prices[1],_prices[2],_prices[0],AdxmPeriod,_adx,_di,i,rates_total);
      di[i]   = _di;
      val[i]  = _adx;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }   
   return(i);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define _adxmInstances     1
#define _adxmInstancesSize 8
double  _adxmWork[][_adxmInstances*_adxmInstancesSize];
#define _adxmSdh   0
#define _adxmSdl   1
#define _adxmSdx   2
#define _adxmClose 3
#define _adxmHigh  4
#define _adxmLow   5
#define _adxmDi    6
#define _adxmAdx   7

void iAdxm(double _close, double _high, double _low, double _period, double& _adx, double& _di, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(_adxmWork,0)!=bars) ArrayResize(_adxmWork,bars); instanceNo*=_adxmInstancesSize;

      _adxmWork[i][instanceNo+_adxmClose]=_close;
      _adxmWork[i][instanceNo+_adxmHigh] =_high;
      _adxmWork[i][instanceNo+_adxmLow]  =_low;
         
         //
         //
         //
         //
         //
         
         double hc = _adxmWork[i][instanceNo+_adxmHigh];
         double lc = _adxmWork[i][instanceNo+_adxmLow ];
         double cp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmClose] : _adxmWork[i][instanceNo+_adxmClose];
         double hp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmHigh ] : _adxmWork[i][instanceNo+_adxmHigh ];
         double lp = (i>0) ? _adxmWork[i-1][instanceNo+_adxmLow  ] : _adxmWork[i][instanceNo+_adxmLow  ];
         double dh = MathMax(hc-hp,0);
         double dl = MathMax(lp-lc,0);

            if(dh==dl) {dh=0; dl=0;} else if(dh<dl) dh=0; else if(dl<dh) dl=0;
            
         double tr    = MathMax(hc,cp)-MathMin(lc,cp);
         double dhk   = (tr!=0) ? 100.0*dh/tr : 0;
         double dlk   = (tr!=0) ? 100.0*dl/tr : 0;
         double alpha = 2.0/(_period+1.0);

            _adxmWork[i][instanceNo+_adxmSdh] = (i>0) ? _adxmWork[i-1][instanceNo+_adxmSdh] + alpha*(dhk-_adxmWork[i-1][instanceNo+_adxmSdh]) : dhk;
            _adxmWork[i][instanceNo+_adxmSdl] = (i>0) ? _adxmWork[i-1][instanceNo+_adxmSdl] + alpha*(dlk-_adxmWork[i-1][instanceNo+_adxmSdl]) : dlk;
            _adxmWork[i][instanceNo+_adxmDi]  = _adxmWork[i][instanceNo+_adxmSdh] - _adxmWork[i][instanceNo+_adxmSdl];

         double div  = MathAbs(_adxmWork[i][instanceNo+_adxmSdh] + _adxmWork[i][instanceNo+_adxmSdl]);
         double temp = (div!=0.0) ? 100*_adxmWork[i][instanceNo+_adxmDi]/div : 0; 
 
             _adxmWork[i][instanceNo+_adxmAdx] = (i>0) ? _adxmWork[i-1][instanceNo+_adxmAdx]+alpha*(temp-_adxmWork[i-1][instanceNo+_adxmAdx]) : 0;
      _adx = _adxmWork[i][instanceNo+_adxmAdx];
      _di  = _adxmWork[i][instanceNo+_adxmDi];
   return;
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

#define _pricesInstances 3
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