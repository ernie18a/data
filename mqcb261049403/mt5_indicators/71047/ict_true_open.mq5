//+------------------------------------------------------------------+
//|                                            ICT_True_Open_PO3.mq5 |
//|                                         Copyright 2026, Amanda V |
//+------------------------------------------------------------------+
#property copyright "Amanda V"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

input group "=== Toggles ==="
input bool   Show_Daily_Open   = true;
input bool   Show_Weekly_Open  = true;
input bool   Show_Monthly_Open = true;

input group "=== Colors & Styles ==="
input color  Color_Daily       = clrBlue;
input color  Color_Weekly      = clrRed;
input color  Color_Monthly     = clrGreen;
input ENUM_LINE_STYLE Style_Lines = STYLE_DASHDOT;

string prefix = "ICT_PO3_";

int OnInit() {
   Print("ICT True Open PO3 Initialized.");
   EventSetTimer(1); // Atualiza as linhas a cada 1 segundo (Zero CPU lag)
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectsDeleteAll(0, prefix);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[]) {
   // Ignora o loop do OnCalculate para evitar "Tester takes too long time"
   return(rates_total);
}

void OnTimer() {
   if(Show_Daily_Open)   DrawOpenLine(PERIOD_D1, "Daily_Open", Color_Daily);
   if(Show_Weekly_Open)  DrawOpenLine(PERIOD_W1, "Weekly_Open", Color_Weekly);
   if(Show_Monthly_Open) DrawOpenLine(PERIOD_MN1, "Monthly_Open", Color_Monthly);
}

void DrawOpenLine(ENUM_TIMEFRAMES tf, string name_suffix, color c) {
   double open_price = iOpen(_Symbol, tf, 0);
   datetime start_time = iTime(_Symbol, tf, 0);
   if(open_price == 0 || start_time == 0) return;
   
   string obj_name = prefix + name_suffix;
   
   if(ObjectFind(0, obj_name) < 0) {
      ObjectCreate(0, obj_name, OBJ_TREND, 0, start_time, open_price, TimeCurrent() + PeriodSeconds(PERIOD_D1), open_price);
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR, c);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE, Style_Lines);
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, obj_name, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, true);
      
      // Texto da Linha
      string text_name = obj_name + "_lbl";
      ObjectCreate(0, text_name, OBJ_TEXT, 0, start_time, open_price);
      ObjectSetString(0, text_name, OBJPROP_TEXT, " " + name_suffix);
      ObjectSetInteger(0, text_name, OBJPROP_COLOR, c);
      ObjectSetInteger(0, text_name, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   } else {
      // Atualiza a posição se o dia/semana virar
      ObjectSetInteger(0, obj_name, OBJPROP_TIME, 0, start_time);
      ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 0, open_price);
      ObjectSetInteger(0, obj_name, OBJPROP_TIME, 1, TimeCurrent() + PeriodSeconds(PERIOD_D1));
      ObjectSetDouble(0, obj_name, OBJPROP_PRICE, 1, open_price);
      
      string text_name = obj_name + "_lbl";
      ObjectSetInteger(0, text_name, OBJPROP_TIME, 0, start_time);
      ObjectSetDouble(0, text_name, OBJPROP_PRICE, 0, open_price);
   }
}
//+------------------------------------------------------------------+