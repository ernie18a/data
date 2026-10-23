//-----------------------------------------------------------------------|
//|                                          TimeToClose-v1.01.mq5       |
//|                                  Copyright 2025, Tautvydas Vaitkus   |
//|                                   https://www.mql5.com/en/users/tauv |
//-----------------------------------------------------------------------|
#property copyright "Copyright 2025, Tautvydas Vaitkus"
#property description "Time to Current Candle Close"
#property version   "1.01"
#property indicator_chart_window

#property indicator_plots 0;
enum ENUM_COLOR_TEXT {
   COLOR_CHART = 0, //Candle Border
   COLOR_CHART_CANDLE = 1 //Candle Body
};

string objName = "TimeToNextCandle";
bool isVisualMode = false;
input bool EnableTextInVisualBacktest = false;
input ENUM_COLOR_TEXT ColorText = COLOR_CHART;
input bool ShowTimeDate = false;
input string Font = "Arial Bold"; //Font (Arial, Arial Bold, ..)
input int FontSize = 12;
input ENUM_ANCHOR_POINT TextAnchorPoint = ANCHOR_LEFT_UPPER;
input string TextFirstSeperator = "    ¬ "; //Text Seperator Price+Time
input string TestSecondSeperator = "        "; //Text Seperator Time+TimeDate


//-----------------------------------------------------------------------|
// MAIN INIT FUNCTION
//-----------------------------------------------------------------------|
int OnInit() {
// Work only in Visual Mode, to optimize headless backtestings
   isVisualMode = IsVisualMode();

   if(isVisualMode) {
      if(!EventSetMillisecondTimer(1000)) {
         Print("Failed to set timer: ", GetLastError());
         return(INIT_FAILED);
      }
   } else {
      Print(__FILE__, ": Running in non-visual mode");
   }
   return(INIT_SUCCEEDED);
}

//-----------------------------------------------------------------------|
// EVERY 1000ms
//-----------------------------------------------------------------------|
void OnTimer() {
   UpdateTimeToNextCandle();
}

//-----------------------------------------------------------------------|
// DELETE TIME OBJECT
//-----------------------------------------------------------------------|
void OnDeinit(const int reason) {
   if(reason == REASON_REMOVE || reason == REASON_PROGRAM || reason == REASON_PARAMETERS) {
      ObjectDelete(0,objName);
   }
}

//-----------------------------------------------------------------------|
// TIMER FOR VISUAL MODE
//-----------------------------------------------------------------------|
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

   if(!isVisualMode) return(rates_total);

   double thisClose = close[rates_total-1];
   static double lastClose = close[rates_total-1];
   if(lastClose != thisClose || rates_total != prev_calculated) {
      CreateModifyTimeToNextCandlePos(open[rates_total-1], thisClose);
   }


   return(rates_total);
}

//-----------------------------------------------------------------------|
// CREATE AND/OR UPDATE POSITION FOR TIMER
//-----------------------------------------------------------------------|
void CreateModifyTimeToNextCandlePos(double open, double close) {

// Create object if missing
   if(ObjectFind(0, objName) < 0) {
      ObjectCreate(0, objName, OBJ_TEXT, 0, TimeCurrent(), close);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, FontSize);
      ObjectSetString(0, objName, OBJPROP_FONT, Font);
      ObjectSetInteger(0, objName, OBJPROP_ANCHOR, TextAnchorPoint);
      ObjectSetString(0, objName, OBJPROP_TEXT, "loading..");
   }

// Update object position
   ObjectMove(0, objName, 0, TimeCurrent(), close);

// Update object color based on candle color or candle chart color
   if(open < close) {
      ObjectSetInteger(0, objName, OBJPROP_COLOR, ChartGetInteger(0,ColorText == COLOR_CHART ? CHART_COLOR_CHART_UP : CHART_COLOR_CANDLE_BULL));
   } else if( open > close) {
      ObjectSetInteger(0, objName, OBJPROP_COLOR, ChartGetInteger(0,ColorText == COLOR_CHART ? CHART_COLOR_CHART_DOWN : CHART_COLOR_CANDLE_BEAR));
   } else {
      ObjectSetInteger(0, objName, OBJPROP_COLOR, ChartGetInteger(0,CHART_COLOR_CHART_LINE));
   }
// Update candle Time also, to avoid delays with intersecond ticks
   UpdateTimeToNextCandle();
}


//-----------------------------------------------------------------------|
// UPDATE CANDLE TIME ONLY BASED ON (_Period)
//-----------------------------------------------------------------------|
void UpdateTimeToNextCandle() {
// Time calculations
   datetime currentTime = TimeCurrent();
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   int secondsLeft = (int)(PeriodSeconds(_Period) - (currentTime - currentBarTime));

// Determine display components
   bool showDays = (_Period == PERIOD_W1) || (_Period == PERIOD_MN1);
   bool showHours = (_Period >= PERIOD_H4) || (_Period == PERIOD_D1);

// Calculate time components
   int days = 0, hours = 0, minutes = 0, seconds = 0;
   int remaining = secondsLeft;

   if(showDays) {
      days = remaining / 86400;
      remaining %= 86400;
   }
   if(showHours) {
      hours = remaining / 3600;
      remaining %= 3600;
   }
   minutes = remaining / 60;
   seconds = remaining % 60;

// Format text
   string txtTimeDate = "";
   if(ShowTimeDate) {
      txtTimeDate = TestSecondSeperator+"["+TimeToString(TimeCurrent())+"]";
   }
   string txt = TextFirstSeperator;
   if(showDays) txt += StringFormat("%dd ", days);
   if(showHours) txt += StringFormat("%02d:", hours);
   txt += StringFormat("%02d:%02d", minutes, seconds);

   ObjectSetString(0, objName, OBJPROP_TEXT, txt + txtTimeDate);
   ChartRedraw(0);
}

//-----------------------------------------------------------------------|
// VISUAL MODE DESCRIPTOR. IF BACKTESTER NON-VISUAL, RETURN FALSE.
//-----------------------------------------------------------------------|
bool IsVisualMode() {
   // Always active in normal chart mode (non-tester environment)
   if(!MQLInfoInteger(MQL_TESTER)) return true;
   
   // Active in visual backtest only when enabled by parameter
   return MQLInfoInteger(MQL_VISUAL_MODE) && EnableTextInVisualBacktest;
}
//-----------------------------------------------------------------------|
