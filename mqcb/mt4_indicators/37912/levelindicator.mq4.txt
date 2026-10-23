//+------------------------------------------------------------------+
//|                                               LevelIndicator.mq4 |
//|                                       Copyright 2022, © Cyberdev |
//|                    https://www.mql5.com/en/users/cyberdev/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, © Cyberdev"
#property link      "https://www.mql5.com/en/users/cyberdev/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

#include <ChartObjects\ChartObjectsLines.mqh>

input bool alert = true; // use alert
input bool notification = true; // use push notifications
input double trigLv = 0.0; // actuation level
input int deviation = 30; // deviation from trigLv in points
input int lineWidth = 1; // line width
input ENUM_LINE_STYLE lineStyle = STYLE_SOLID; // line style
input color lineColor = clrMediumSpringGreen; // line color
input color inactivityColor = clrLightGray; // inactivity color

CChartObjectHLine lv, dvH, dvL; 

bool equal(double _v1, double _v2, double _epsilon) { return fabs(_v1 - _v2) <= fabs(_epsilon); }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  string name;
  double dv;
  color color_;
  name = "alert.lv-";
  dv = deviation * SymbolInfoDouble(NULL, SYMBOL_POINT);
  color_ = (alert || notification) ? lineColor : inactivityColor;
  for (int n = 0; n <= INT_MAX && !IsStopped(); n++) {
    if (ObjectFind(0, name + (string)n) != 0) {
      if (!lv.Create(0, name + (string)n, 0, trigLv))
        return INIT_FAILED;
      lv.Width(lineWidth);
      lv.Style(lineStyle);
      lv.Color(color_);
      dvH.Create(0, "alert.dvH-" + (string)n, 0, trigLv + dv);
      dvH.Width(1);
      dvH.Style(STYLE_DOT);
      dvH.Color(color_);
      dvL.Create(0, "alert.dvL-" + (string)n, 0, trigLv - dv);
      dvL.Width(1);
      dvL.Style(STYLE_DOT);
      dvL.Color(color_);
      break;
    }
  }
  if (!alert && !notification) 
    Print("Level Indicator. Level ", lv.Price(0), " is inactive!");
  if (trigLv == 0.0)
    Alert("Level Indicator. Set parameter \"trigLv\" to the desired value!");
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  //lv.Delete();
  //dvH.Delete();
  //dvL.Delete();
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
                const int &spread[]
) {
  static bool triggered = false;
  static datetime time_ = 0;
  if (!alert && !notification)
    return rates_total;
  if (equal(lv.Price(0), close[0], deviation * SymbolInfoDouble(NULL, SYMBOL_POINT))) { 
    if (time_ != time[0])
      time_ = time[0];
    else
      return rates_total;
    if (!triggered) {
      if (alert)
        Alert("Level Indicator. Level ", NormalizeDouble(lv.Price(0), (int)SymbolInfoInteger(NULL, SYMBOL_DIGITS)), " triggered!");
      if (notification)
        SendNotification("Level Indicator. Level " + (string)NormalizeDouble(lv.Price(0), (int)SymbolInfoInteger(NULL, SYMBOL_DIGITS)) + " triggered!");
    }
    triggered = true;
  }
  else
    triggered = false;
    
  return(rates_total);
}
//+------------------------------------------------------------------+
