//+------------------------------------------------------------------+
#property copyright   "Copyright © 2024, Nomocp."
#property link        "https://t.me/nomocp"
#property version     "1.01"
#property description "This indicator may be repainted"
// #property strict
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_color1 C'209,212,25'
#property indicator_color2 C'25,212,112'

//--- Inputs
sinput bool         inpEnableNotifyTerminal = false;   // Terminal Push Notification?
sinput bool         inpEnableNotifyMobile   = false;   // Mobile Push Notification?
input int           inpSARPeriod            = 10;      // SAR Period
input double        inpSARMaxStep           = 0.5;     // SAR Step

input int           inpADXPeriod            = 7;       // ADX Period
input double        inpADXThresHold         = 20.0;    // ADX Threshold

//--- Buffers
double bufferSignalBuy[];
double bufferSignalSell[];
double bufferSAR[];
double bufferADX[];

int handleSAR;
int handleADX;

int minInit;
bool isNotify = false;

// E37F0136AA3FFAF149B351F6A4C948E9
int OnInit() {
  if(inpSARPeriod < 2 || inpADXPeriod < 2) return INIT_FAILED;
  if(inpEnableNotifyMobile && !TERMINAL_NOTIFICATIONS_ENABLED) Alert("Please enable push notification feature at Tools > Option > Notifications");

  SetIndexBuffer(0, bufferSignalSell, INDICATOR_DATA);
  SetIndexBuffer(1, bufferSignalBuy, INDICATOR_DATA);
  SetIndexBuffer(2, bufferSAR, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, bufferADX, INDICATOR_CALCULATIONS);

  PlotIndexSetString(0, PLOT_LABEL, "SELL SIGN");
  PlotIndexSetString(1, PLOT_LABEL, "BUY SIGN");

  ArraySetAsSeries(bufferSignalBuy, true);
  ArraySetAsSeries(bufferSignalSell, true);
  ArraySetAsSeries(bufferSAR, true);
  ArraySetAsSeries(bufferADX, true);

  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
  PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);

  PlotIndexSetInteger(0, PLOT_ARROW, 234);    // sell
  PlotIndexSetInteger(1, PLOT_ARROW, 233);    // buy

  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 10);

  minInit = MathMax(inpSARPeriod, inpADXPeriod);
  PlotIndexGetInteger(0, PLOT_DRAW_BEGIN, minInit);
  PlotIndexGetInteger(1, PLOT_DRAW_BEGIN, minInit);

  for(int i = 0; i < 4; ++i) PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);

  handleSAR = iSAR(_Symbol, _Period, NormalizeDouble(1/(10*inpSARPeriod+0.00001), 3), inpSARMaxStep);
  handleADX = iADX(_Symbol, _Period, inpADXPeriod);
  return INIT_SUCCEEDED;
}


void OnDeinit(const int reason) {
  IndicatorRelease(handleSAR);
  IndicatorRelease(handleADX);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar() {
  long lastBarTime = SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
  static long lastTime = lastBarTime;
  if(lastTime == lastBarTime) return false;
  lastTime = lastBarTime;
  return true;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
  if(rates_total < minInit) return 0;

  if(isNewBar()) isNotify = false;
  int limit   = rates_total - prev_calculated;
  if(prev_calculated < 1) limit = rates_total - minInit;
  if(limit == 0) ++limit;

  ArraySetAsSeries(high, true);
  ArraySetAsSeries(low, true);
  ArraySetAsSeries(close, true);
  
  if(CopyBuffer(handleADX, MAIN_LINE, 0, limit, bufferADX) < 1 ||
     CopyBuffer(handleSAR, 0, 0, limit, bufferSAR) < 1) return prev_calculated;

  for(int bar = limit-1; bar > -1 && !IsStopped(); --bar) {
    bufferSignalSell[bar] = 0;
    bufferSignalBuy[bar]  = 0;
    if(bufferSAR[bar] > close[bar] && bufferSAR[bar+1] < close[bar+1] && bufferADX[bar] > inpADXThresHold) {
      bufferSignalSell[bar] = high[bar];
      if(!isNotify) SendMobileNotify(false);
    }
    else if(bufferSAR[bar] < close[bar] && bufferSAR[bar+1] > close[bar+1] && bufferADX[bar] > inpADXThresHold) {
      bufferSignalBuy[bar] = low[bar];
      if(!isNotify) SendMobileNotify(true);
    }
  }

  return rates_total;
}


void SendMobileNotify(bool isBuy) {
  if(!inpEnableNotifyMobile && !inpEnableNotifyTerminal) return;
  isNotify   = true;
  string pos = isBuy ? "Buy" : "Sell";
  string msg = StringFormat("[%s][%s] %s Signal Appeared!", _Symbol,
                                                            StringSubstr(EnumToString(_Period), 7, -1),
                                                            pos);
  if(inpEnableNotifyMobile)   SendNotification(msg);
  if(inpEnableNotifyTerminal) Alert(msg);
}
//+------------------------------------------------------------------+
