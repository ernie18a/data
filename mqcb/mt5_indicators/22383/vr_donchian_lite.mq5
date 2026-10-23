//************************************************************************************************/
//*                                   VR Donchian Lite.mq5                                       */
//*                            Copyright 2018, Trading-go Project.                               */
//*           Author: Voldemar, Version: 12.09.2018, Site https://trading-go.ru                  */
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
//| Full version MetaTrader 4  https://www.mql5.com/ru/market/product/31831 
//| Lite version MetaTrader 4  https://www.mql5.com/ru/code/21150 
//| Full version MetaTrader 5  https://www.mql5.com/ru/market/product/31832 
//| Lite version MetaTrader 5  https://www.mql5.com/ru/code/22383
//************************************************************************************************/
//| All products of the Author https://www.mql5.com/ru/users/voldemar/seller
//************************************************************************************************/
#property copyright   "Copyright 2018, Trading-go Project."
#property link        "http://trading-go.ru"
#property version     "18.100"
#property description "A simple standard Donchian indicator"
#property strict
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
input int          Period_      = 24;         // Period Donchian
input color        UpperLine    = clrBlue;    // Color Upper Line
input color        LowerLine    = clrRed;     // Color Lower Line
input color        AverageLine  = clrGreen;   // Color Average Line 
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
double upper_line[],lower_line[],awera_line[];
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnInit()
  {
   Comment("");
   IndicatorSetString(INDICATOR_SHORTNAME,"VR Donchian Lite("+(string)Period_+")");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   SetIndexBuffer(0,upper_line,INDICATOR_DATA); ArraySetAsSeries(upper_line,true);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,UpperLine);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2);
   PlotIndexSetString(0,PLOT_LABEL,"Upper Line");

   SetIndexBuffer(1,lower_line,INDICATOR_DATA); ArraySetAsSeries(lower_line,true);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,LowerLine);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,2);
   PlotIndexSetString(1,PLOT_LABEL,"Lower Line");

   SetIndexBuffer(2,awera_line,INDICATOR_DATA); ArraySetAsSeries(awera_line,true);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,STYLE_DOT);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,AverageLine);
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,1);
   PlotIndexSetString(2,PLOT_LABEL,"Average Line");
   
   return(INIT_SUCCEEDED);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnCalculate (const int rates_total,      // the size of the input timeseries 
                 const int prev_calculated,  // bars processed at the previous call 
                 const datetime& time[],     // Time 
                 const double& open[],       // Open 
                 const double& high[],       // High 
                 const double& low[],        // Low 
                 const double& close[],      // Close 
                 const long& tick_volume[],  // Tick Volume 
                 const long& volume[],       // Real Volume 
                 const int& spread[]         // Spread 
                 )
  {
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   if(rates_total<=Period_ || Period_<=0)
      return(0);

   int limit=rates_total-prev_calculated-1;
   if(limit<0) limit=0;

   for(int i=limit;i>=0;i--)
     {
      upper_line[i]=high[iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,Period_,i)];
      lower_line[i]=low[iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,Period_,i)];
      awera_line[i]=(upper_line[i]+lower_line[i])/2;
     }

   return(rates_total);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnDeinit(const int reason)
  {

  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
