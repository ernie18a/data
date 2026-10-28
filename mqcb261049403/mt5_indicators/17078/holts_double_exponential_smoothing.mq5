//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, forge.mql5.io"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Holt DS"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGray,clrLimeGreen,clrSandyBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
#property indicator_label2  "Holt DS forecast"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrGray,clrLimeGreen,clrSandyBrown
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

input double   EstimatePeriod  = 14.33;     // Estimation component period
input double   TrendPeriod     = 10;        // Trend component period
input enPrices Price           = pr_close;  // Price
input int      ForecastHorizon = 25;        // Forecasted bars
input bool     AlertsOn        = false;     // Turn alerts on?
input bool     AlertsOnCurrent = true;      // Alert on current bar?
input bool     AlertsMessage   = true;      // Display messageas on alerts?
input bool     AlertsSound     = false;     // Play sound on alerts?
input bool     AlertsEmail     = false;     // Send email on alerts?
input bool     AlertsNotify    = false;     // Send push notification on alerts?

double avg[],avgc[],work[],forecast[],forecastc[];

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
   SetIndexBuffer(0,avg      ,INDICATOR_DATA);
   SetIndexBuffer(1,avgc     ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,forecast ,INDICATOR_DATA);
   SetIndexBuffer(3,forecastc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,work     ,INDICATOR_CALCULATIONS);
   IndicatorSetString(INDICATOR_SHORTNAME,"Holt's double exponential smoothing ("+(string)EstimatePeriod+","+(string)TrendPeriod+")");
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

int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
   //
   //
   //
   //
   //
      
   double alpha=2.0/(1.0+EstimatePeriod),gamma=2.0/(1.0+TrendPeriod);
      int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
      {
         double price = getPrice(Price,open,close,high,low,i,rates_total);
            avg[i]      = (i>0) ? alpha*price+(1-alpha)*(avg[i-1]+work[i-1])  : price;
            work[i]     = (i>0) ? gamma*(avg[i]-avg[i-1])+(1-gamma)*work[i-1] : 0;
            avgc[i]     = (i>0) ? (avg[i]>avg[i-1]) ? 1 : (avg[i]<avg[i-1]) ? 2 : avgc[i-1] : 0;
            forecast[i] = EMPTY_VALUE;
            
            //
            //
            //
            //
            //
            
            if (i==(rates_total-1))
            {
               forecast[i-ForecastHorizon] = avg[i];
               forecastc[i-ForecastHorizon] = (work[i]>0) ? 1 : 2;
               for (int f=ForecastHorizon-1; f>=0; f--)  
               {
                  forecast[i-f]  = avg[i]+(ForecastHorizon-f)*work[i];
                  forecastc[i-f] = (work[i]>0) ? 1 : 2;
               }                  
            }               
      }
   PlotIndexSetInteger(1,PLOT_SHIFT,ForecastHorizon); PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-ForecastHorizon-1);
   manageAlerts(time,avgc,rates_total);      
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

void manageAlerts(const datetime& time[], double& trend[], int bars)
{
   if (!AlertsOn) return;
      int whichBar = bars-1; if (!AlertsOnCurrent) whichBar = bars-2; datetime time1 = time[whichBar];
      if (trend[whichBar] != trend[whichBar-1])
      {
         if (trend[whichBar] == 1) doAlert(time1,"up");
         if (trend[whichBar] == 2) doAlert(time1,"down");
      }         
}   

//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      message = _Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" Holt's double exponential smoothing state changed to "+doWhat;
         if (AlertsMessage) Alert(message);
         if (AlertsEmail)   SendMail(_Symbol+" Holt's double exponential smoothing",message);
         if (AlertsNotify)  SendNotification(message);
         if (AlertsSound)   PlaySound("alert2.wav");
   }
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