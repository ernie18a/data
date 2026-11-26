//+------------------------------------------------------------------+
//|                 Trade_With_MA_ATR_Profit_Fixed.mq5               |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3

//--- Plot Properti
#property indicator_type1   DRAW_ARROW
#property indicator_color1   clrDeepSkyBlue
#property indicator_width1   3

#property indicator_type2   DRAW_ARROW
#property indicator_color2   clrOrangeRed
#property indicator_width2   3

#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3   clrDeepSkyBlue, clrOrangeRed
#property indicator_label3   "MA Open;MA High;MA Low;MA Close"

//--- Buffers
double BufferUp[], BufferDown[];
double candle_open[], candle_high[], candle_low[], candle_close[], candle_color[];

//--- Inputs
input group "=== MA SETTINGS ==="
input int PeriodMA1 = 3;
input int PeriodMA2 = 14;

input group "=== ATR TP/SL SETTINGS ==="
input int ATR_Period = 14;
input double SL_Multiplier = 1.5;
input double TP_Multiplier = 2.0;

input group "=== PIVOT & DASHBOARD ==="
input ENUM_TIMEFRAMES PivotTF = PERIOD_D1;
input int MA_Period_Dash = 14;

// Global Variables
int handleMA1, handleMA2, handleATR;
int dashHandles[9]; // Fixed: Isytihar saiz array
string tfNames[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
ENUM_TIMEFRAMES tfs[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};

//+------------------------------------------------------------------+
int OnInit() {
   // Mapping Buffers
   SetIndexBuffer(0, BufferUp, INDICATOR_DATA);
   SetIndexBuffer(1, BufferDown, INDICATOR_DATA);
   SetIndexBuffer(2, candle_open, INDICATOR_DATA);
   SetIndexBuffer(3, candle_high, INDICATOR_DATA);
   SetIndexBuffer(4, candle_low, INDICATOR_DATA);
   SetIndexBuffer(5, candle_close, INDICATOR_DATA);
   SetIndexBuffer(6, candle_color, INDICATOR_COLOR_INDEX);

   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   for(int i=0; i<3; i++) PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);

   // Initialize Handles
   handleMA1 = iMA(_Symbol, _Period, PeriodMA1, 0, MODE_SMA, PRICE_CLOSE);
   handleMA2 = iMA(_Symbol, _Period, PeriodMA2, 0, MODE_SMA, PRICE_CLOSE);
   handleATR = iATR(_Symbol, _Period, ATR_Period);
   
   for(int i=0; i<9; i++)
      dashHandles[i] = iMA(_Symbol, tfs[i], MA_Period_Dash, 0, MODE_SMA, PRICE_CLOSE);

   // UI Labels
   for(int i=0; i<9; i++) CreateLabel("TF_LBL_"+tfNames[i], 300, 60 + (i * 20), 9, clrWhite);
   
   CreateLabel("ATR_TITLE", 300, 260, 10, clrGold, "--- ATR TARGETS ---");
   CreateLabel("ATR_BUY_SL", 300, 280, 9, clrWhite);
   CreateLabel("ATR_BUY_TP", 300, 300, 9, clrWhite);
   CreateLabel("ATR_SELL_SL", 300, 325, 9, clrWhite);
   CreateLabel("ATR_SELL_TP", 300, 345, 9, clrWhite);
   
   CreateLabel("PL_TITLE", 300, 375, 10, clrGold, "--- ACCOUNT STATUS ---");
   CreateLabel("PL_VAL", 300, 395, 10, clrWhite);
   CreateLabel("PL_LOTS", 300, 415, 9, clrWhite);

   CreateLabel("SIGNAL_LBL", 300, 30, 12, clrGray, "SIGNAL: WAITING...");

   ObjectCreate(0, "PivotLine", OBJ_HLINE, 0, 0, 0);
   ObjectSetInteger(0, "PivotLine", OBJPROP_COLOR, clrGold);
   ObjectSetInteger(0, "PivotLine", OBJPROP_STYLE, STYLE_DASH);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, int size, color col, string text="") {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
   
   if(rates_total < PeriodMA2) return(0);
   double ma1[], ma2[];
   ArraySetAsSeries(ma1, true); ArraySetAsSeries(ma2, true);
   
   if(CopyBuffer(handleMA1, 0, 0, rates_total, ma1) <= 0) return(0);
   if(CopyBuffer(handleMA2, 0, 0, rates_total, ma2) <= 0) return(0);

   int limit = (prev_calculated > 0) ? prev_calculated - 1 : 0;
   
   // Tukar data candle kepada siri (indeks 0 = terkini)
   for(int i = limit; i < rates_total; i++) {
      candle_open[i] = open[i]; candle_high[i] = high[i]; 
      candle_low[i] = low[i]; candle_close[i] = close[i];
      
      // Guna i untuk data yang tak diset sebagai series
      if(close[i] > ma1[rates_total-1-i]) { 
         candle_color[i] = 0; BufferUp[i] = ma2[rates_total-1-i]; BufferDown[i] = 0.0;
      } else {
         candle_color[i] = 1; BufferDown[i] = ma2[rates_total-1-i]; BufferUp[i] = 0.0;
      }
   }

   MqlRates pRates[];
   ArraySetAsSeries(pRates, true);
   if(CopyRates(_Symbol, PivotTF, 1, 1, pRates) > 0)
      ObjectSetDouble(0, "PivotLine", OBJPROP_PRICE, (pRates[0].high + pRates[0].low + pRates[0].close) / 3.0);

   UpdateDashboard();
   return(rates_total);
}

//+------------------------------------------------------------------+
void UpdateDashboard() {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double atr_buf[];
   int upCount = 0, downCount = 0;

   // 1. Profit/Loss Logic dengan Penambahan SIMBOL
   double total_pl = 0, total_lots = 0;
   string accCurrency = AccountInfoString(ACCOUNT_CURRENCY);
   string currentPair = _Symbol; // Mengambil nama pair semasa
   
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(PositionGetSymbol(i) == _Symbol) {
         total_pl += PositionGetDouble(POSITION_PROFIT);
         total_lots += PositionGetDouble(POSITION_VOLUME);
      }
   }
   
   string plIcon = (total_pl > 0) ? "📈 " : (total_pl < 0 ? "📉 " : "💰 ");
   
   // Paparan baru: [PAIR NAME] P/L: [ICON] [VALUE] [CURRENCY]
   ObjectSetString(0, "PL_TITLE", OBJPROP_TEXT, "--- STATUS: " + currentPair + " ---");
   ObjectSetString(0, "PL_VAL", OBJPROP_TEXT, "P/L: " + plIcon + DoubleToString(total_pl, 2) + " " + accCurrency);
   ObjectSetInteger(0, "PL_VAL", OBJPROP_COLOR, (total_pl >= 0 ? clrDeepSkyBlue : clrOrangeRed));
   ObjectSetString(0, "PL_LOTS", OBJPROP_TEXT, "Lots Active: 📦 " + DoubleToString(total_lots, 2));

     // 2. Dashboard Logic
   for(int i=0; i<9; i++) {
      double maArr[1]; // Sediakan array dengan saiz 1
      if(CopyBuffer(dashHandles[i], 0, 0, 1, maArr) > 0) {
         bool up = (bid > maArr[0]); // Akses indeks [0]
         if(up) upCount++; else downCount++;
         ObjectSetString(0, "TF_LBL_"+tfNames[i], OBJPROP_TEXT, tfNames[i] + (up ? ": UP ▲" : ": DN ▼"));
         ObjectSetInteger(0, "TF_LBL_"+tfNames[i], OBJPROP_COLOR, (up ? clrDeepSkyBlue : clrOrangeRed));
      }
   }

   // 3. Signal Logic (Kekal sama)
   string signal = "WAITING..."; color sigCol = clrGray;
   if(upCount == 9) { signal = "🚀 STRONG BUY"; sigCol = clrDeepSkyBlue; }
   if(downCount == 9) { signal = "🔥 STRONG SELL"; sigCol = clrOrangeRed; }
   ObjectSetString(0, "SIGNAL_LBL", OBJPROP_TEXT, "SIGNAL: " + signal);
   ObjectSetInteger(0, "SIGNAL_LBL", OBJPROP_COLOR, sigCol);

   // 4. ATR Targets (Kekal sama)
   if(CopyBuffer(handleATR, 0, 0, 1, atr_buf) > 0) {
      ObjectSetString(0, "ATR_BUY_SL", OBJPROP_TEXT, "BUY SL: 🛑 " + DoubleToString(bid - (atr_buf[0] * SL_Multiplier), _Digits));
      ObjectSetString(0, "ATR_BUY_TP", OBJPROP_TEXT, "BUY TP: 🎯 " + DoubleToString(bid + (atr_buf[0] * TP_Multiplier), _Digits));
      ObjectSetString(0, "ATR_SELL_SL", OBJPROP_TEXT, "SELL SL: 🛑 " + DoubleToString(ask + (atr_buf[0] * SL_Multiplier), _Digits));
      ObjectSetString(0, "ATR_SELL_TP", OBJPROP_TEXT, "SELL TP: 🎯 " + DoubleToString(ask - (atr_buf[0] * TP_Multiplier), _Digits));
   }
   ChartRedraw();
}


//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, "TF_LBL_");
   ObjectsDeleteAll(0, "ATR_");
   ObjectsDeleteAll(0, "SIGNAL_");
   ObjectsDeleteAll(0, "PL_");
   ObjectDelete(0, "PivotLine");
}
