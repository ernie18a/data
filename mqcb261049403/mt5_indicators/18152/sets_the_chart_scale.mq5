//+------------------------------------------------------------------+
//|                                         Sets the chart scale.mq5 |
//|                                                  Alexey Viktorov |
//|                     https://www.mql5.com/ru/users/alexeyvik/news |
//+------------------------------------------------------------------+
#property copyright "Alexey Viktorov"
#property link      "https://www.mql5.com/ru/users/alexeyvik/news"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots   0

double half=0;
int chartScale;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   chartScale=(int)ChartGetInteger(0,CHART_SCALE);
   half=NormalizeDouble(ChartGetDouble(0,CHART_PRICE_MAX)-(ChartGetDouble(0,CHART_PRICE_MAX)+ChartGetDouble(0,CHART_PRICE_MIN))/2,_Digits);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   double chartMax = ChartGetDouble(0, CHART_PRICE_MAX);
   double chartMin = ChartGetDouble(0, CHART_PRICE_MIN);
   double chartMid = NormalizeDouble((chartMax+chartMin)/2, _Digits);
   int firstVisibleBar=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR);
   int visibleBars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   int ratesBar=rates_total-firstVisibleBar-3+visibleBars;
   ChartSetInteger(0,CHART_SCALEFIX,true);
   ChartSetDouble(0,CHART_FIXED_MAX,(open[ratesBar]+close[ratesBar])/2+half);
   ChartSetDouble(0,CHART_FIXED_MIN,(open[ratesBar]+close[ratesBar])/2-half);
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ChartSetInteger(0,CHART_SCALEFIX,false);
  }
//+------------------------------------------------------------------+
