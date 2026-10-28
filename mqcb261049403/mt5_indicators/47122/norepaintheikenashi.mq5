//+------------------------------------------------------------------+
#property copyright "Copyright © 2023, Nomocp."
#property link      "https://t.me/nomocp"
#property version   "1.1"
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrOldLace, clrDimGray
#property indicator_label1  "Heiken Ashi Open;Heiken Ashi High;Heiken Ashi Low;Heiken Ashi Close"

//--- Inputs
sinput bool inpRepaintMode = false;   // Enable Repaint Mode
sinput bool inpFasterMode  = true;    // Enable Faster Mode

//--- indicator buffers
double bufferOpen[];
double bufferHigh[];
double bufferLow[];
double bufferClose[];
double bufferColor[];

int count = inpRepaintMode ? 0 : 1;
int start;
int countCandle = 1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit() {
  SetIndexBuffer(0, bufferOpen, INDICATOR_DATA);
  SetIndexBuffer(1, bufferHigh, INDICATOR_DATA);
  SetIndexBuffer(2, bufferLow, INDICATOR_DATA);
  SetIndexBuffer(3, bufferClose, INDICATOR_DATA);
  SetIndexBuffer(4, bufferColor, INDICATOR_COLOR_INDEX);

  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  IndicatorSetString(INDICATOR_SHORTNAME, "Heiken Ashi");
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
}
//+------------------------------------------------------------------+
//| Heiken Ashi                                                      |
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
                const int &spread[]) {
//--- preliminary calculations
  if(prev_calculated == 0) {
    bufferLow[0]   = low[0];
    bufferHigh[0]  = high[0];
    bufferOpen[0]  = open[0];
    bufferClose[0] = close[0];
    countCandle    = open[0] < close[0] ? -1 : 1;
    bufferColor[0] = open[0] < close[0] ? 0 : 1;
    start = 1;
  }
  else start = prev_calculated-1;

//--- the main loop of calculations
  if(inpFasterMode) HeikenAshiFasterCalculate(open, high, low, close, rates_total);
  else              HeikenAshiNormalCalculate(open, high, low, close, rates_total);
//---
  return(rates_total);
}

//--- Normal Mode
void HeikenAshiNormalCalculate(const double &open[],
                               const double &high[],
                               const double &low[],
                               const double &close[],
                               int rates) {
  for(int i = start; i < rates && !IsStopped(); ++i) {
    int pos         = i - count;
    double ha_open  = (bufferOpen[i-1] + bufferClose[i-1]) / 2;
    double ha_close = (open[pos] + high[pos] + low[pos] + close[pos]) / 4;
    double ha_high  = MathMax(high[pos], MathMax(ha_open, ha_close));
    double ha_low   = MathMin(low[pos], MathMin(ha_open, ha_close));

    bufferLow[i]    = ha_low;
    bufferHigh[i]   = ha_high;
    bufferOpen[i]   = ha_open;
    bufferClose[i]  = ha_close;

    //--- set candle color
    bufferColor[i]  = (ha_open < ha_close) ? 0 : 1;
  }
}

//--- Faster Mode
void HeikenAshiFasterCalculate(const double &open[],
                               const double &high[],
                               const double &low[],
                               const double &close[],
                               int rates) {
  for(int i = start; i < rates && !IsStopped(); ++i) {
    int pos         = i - count;
    double ha_open  = (bufferOpen[i-1] + bufferClose[i-1]) / 2;
    double ha_close = (2*open[i] + high[pos] + low[pos]) / 4;
    ha_close        = AddWeight(ha_close, countCandle, (countCandle > 0) ? high[pos] : low[pos]);

    double ha_high  = MathMax(high[pos], MathMax(ha_open, ha_close));
    double ha_low   = MathMin(low[pos], MathMin(ha_open, ha_close));

    bufferLow[i]    = ha_low;
    bufferHigh[i]   = ha_high;
    bufferOpen[i]   = ha_open;
    bufferClose[i]  = ha_close;

    //--- set candle color
    bufferColor[i] = (ha_open < ha_close) ? 0 : 1;

    //--- set weight
    if(!HasNewCandle() && start != 1) continue;
    if(ha_open < ha_close) { // Up candle
      if(bufferColor[i-1] == 1) countCandle = -1;
      else --countCandle;
    }
    else {                   // Down candle
      if(bufferColor[i-1] == 0) countCandle = 1;
      else ++countCandle;
    }
  }
}

double AddWeight(double closePrice, double weight, double extremePrice) {
  return (closePrice + extremePrice * MathAbs(weight))/(MathAbs(weight)+1);
}

bool HasNewCandle() {
  //--- current time
  long lastBarTime = SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);
  //--- memorize the time of opening of the last bar in the static variable
  static long lastTime = lastBarTime;

  //--- still not have new candle
  if(lastTime == lastBarTime) return false;
  
  //--- if the time differs
  lastTime = lastBarTime;
  return true;
}
//+------------------------------------------------------------------+