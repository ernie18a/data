//+------------------------------------------------------------------+
//|                                     QuantumAlgo_Premium_V3.mq5   |
//|                                  High-End UI & Auto-Sessions     |
//+------------------------------------------------------------------+
#property copyright "QuantumAlgo"
#property version   "3.00"
#property indicator_chart_window

//--- INPUTS
input group "==== PREMIUM UI SETTINGS ===="
input int    xOffset      = 25;             
input int    yOffset      = 65;             
input color  dashBG       = C'250,250,250'; // Ultra Light Grey
input int    opacity      = 220;            // 0 to 255 (Transparency)

input group "==== SESSION TIMINGS (Broker Time) ===="
input bool   showSessions = true;
input string LonTime      = "09:00-17:00";  // London
input string NYTime       = "14:00-21:00";  // New York
input color  LonColor     = C'220,235,255'; // Soft Blue
input color  NYColor      = C'255,245,225'; // Soft Gold

//--- GLOBALS
int ema50_handle;

//+------------------------------------------------------------------+
int OnInit() {
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite);
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, C'0,165,80');
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, C'220,20,60');
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack);
   
   ema50_handle = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectsDeleteAll(0, "QA_");
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[]) {
   
   DrawDailyLevels();
   if(showSessions) {
      MarkSession("QA_LonBox", LonTime, LonColor);
      MarkSession("QA_NYBox", NYTime, NYColor);
   }
   UpdatePremiumUI();
   return(rates_total);
}

void OnTimer() { UpdatePremiumUI(); }

//+------------------------------------------------------------------+
//| SESSION BOX LOGIC (PREMIUM LOOK)                                 |
//+------------------------------------------------------------------+
void MarkSession(string name, string range, color clr) {
   string parts[]; StringSplit(range, '-', parts);
   MqlDateTime dt; TimeCurrent(dt);
   string datePrefix = StringFormat("%d.%02d.%02d ", dt.year, dt.mon, dt.day);
   
   datetime start = StringToTime(datePrefix + parts[0]);
   datetime end   = StringToTime(datePrefix + parts[1]);
   
   if(TimeCurrent() < start) return; // Session start nahi hui

   double highVal = iHigh(_Symbol, _Period, iBarShift(_Symbol, _Period, start));
   double lowVal  = iLow(_Symbol, _Period, iBarShift(_Symbol, _Period, start));

   // Create Session Box
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, start, highVal, end, lowVal);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   }
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, start);
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, end);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}

//+------------------------------------------------------------------+
//| PREMIUM UI UPDATE                                                |
//+------------------------------------------------------------------+
void UpdatePremiumUI() {
   datetime lastBar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   int sec = (int)(lastBar + PeriodSeconds() - TimeCurrent());
   string timer = StringFormat("%02d:%02d", (sec<0?0:sec)/60, (sec<0?0:sec)%60);
   
   double emaVal[1]; CopyBuffer(ema50_handle, 0, 0, 1, emaVal);
   string trend = (SymbolInfoDouble(_Symbol, SYMBOL_BID) > emaVal[0]) ? "BULLISH" : "BEARISH";
   color trendColor = (trend == "BULLISH") ? C'0,120,0' : C'180,0,0';

   // 1. Shadow/Glow Effect for Box
   CreateBox("QA_Shadow", 192, 112, xOffset-1, yOffset-1, clrSilver); 
   CreateBox("QA_MainBG", 190, 110, xOffset, yOffset, dashBG);

   // 2. Data Rows (Pixel Perfect Alignment)
   DrawRow("QA_Row1", "SYMBOL", _Symbol, xOffset, yOffset+15, clrSlateGray, clrBlack);
   DrawRow("QA_Row2", "SPREAD", (string)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), xOffset, yOffset+35, clrSlateGray, clrBlack);
   DrawRow("QA_Row3", "TIMER", timer, xOffset, yOffset+55, clrSlateGray, clrBlack);
   DrawRow("QA_Row4", "TREND", trend, xOffset, yOffset+75, clrSlateGray, trendColor);

   ChartRedraw();
}

void DrawRow(string name, string lbl, string val, int x, int y, color c1, color c2) {
   string lblName = name + "_L";
   string valName = name + "_V";
   
   if(ObjectFind(0, lblName) < 0) ObjectCreate(0, lblName, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, lblName, OBJPROP_TEXT, lbl);
   ObjectSetInteger(0, lblName, OBJPROP_XDISTANCE, x + 15);
   ObjectSetInteger(0, lblName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, lblName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, lblName, OBJPROP_COLOR, c1);
   ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, lblName, OBJPROP_FONT, "Verdana");

   if(ObjectFind(0, valName) < 0) ObjectCreate(0, valName, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, valName, OBJPROP_TEXT, val);
   ObjectSetInteger(0, valName, OBJPROP_XDISTANCE, x + 175); // Fixed Right Alignment
   ObjectSetInteger(0, valName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, valName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, valName, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, valName, OBJPROP_COLOR, c2);
   ObjectSetInteger(0, valName, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, valName, OBJPROP_FONT, "Verdana Bold");
}

void CreateBox(string name, int w, int h, int x, int y, color bg) {
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
}

void DrawDailyLevels() {
   double pdh = iHigh(_Symbol, PERIOD_D1, 1);
   double pdl = iLow(_Symbol, PERIOD_D1, 1);
   CreateHLine("QA_PDH", pdh, clrDodgerBlue, "PDH");
   CreateHLine("QA_PDL", pdl, clrOrangeRed, "PDL");
}

void CreateHLine(string name, double price, color clr, string txt) {
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
}