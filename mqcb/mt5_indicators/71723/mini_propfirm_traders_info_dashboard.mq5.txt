//+------------------------------------------------------------------+
//|                     Mini Prop-Firm Traders Utility Dashboard.mq5 |
//|            Copyright 2003-2026, Opengates Success International. |
//|               https://www.mql5.com/en/users/opengates2012/seller |
//+------------------------------------------------------------------+
#property copyright "2003-2026, Opengates Success International Org."
#property link "https://www.mql5.com/en/users/opengates2012/seller"
#property version   "1.0"
#property description "Mini Prop-Firm Traders Utility Dashboard - This Indicator is created to show total account information for the Prop firm Traders."
#property description "This enables the trader to take caution on his/her trading to avoid excessive drawdown or breach/termination of the account."
#property description "For Full Prop-Firm Traders Utility Dashboard, visit: https://www.mql5.com/en/market/product/171896/ to check it out!"
#property indicator_plots   0
#property indicator_chart_window
#property strict
//+------------------------------------------------------------------+
#include <Trade/PositionInfo.mqh>
//================ INPUTS ================
 input int Panel_X = 5; //Distance - left/right
 input int Panel_Y = 20; //Distance - up/down
 input color Panel_BG = clrNavy;//Background Color (Optional)
 input color Text_Color = clrLightGray;//Text Color (Optional)
//================ GLOBALS ================
bool isMinimized = false;
string btn_toggle   = "RiskToggleBtn";
string panel_name   = "RiskPanel";
string min_label    = "RiskMinLabel";

//================ INIT ===================
int OnInit()
{
   CreatePanel();

   isMinimized = false;

   // Force refresh to apply visibility correctly
   ChartRedraw();

   ApplyPanelState();

   return(INIT_SUCCEEDED);
}
//================ DEINIT =================
void OnDeinit(const int reason)
{
   ObjectDelete(0, btn_toggle);
   ObjectDelete(0, panel_name);
   ObjectDelete(0, min_label);

   for(int i = 0; i < 7; i++)
   ObjectDelete(0, "RiskLabel_" + IntegerToString(i));
}

//================ CALCULATION ============
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
   double total_risk, total_reward;
   CalculateRiskReward(total_risk, total_reward);

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double pnl = equity - balance;

   double risk_pct   = (balance > 0) ? (total_risk / balance) * 100.0 : 0;
   double reward_pct = (balance > 0) ? (total_reward / balance) * 100.0 : 0;
   double rr_ratio   = (total_risk > 0) ? (total_reward / total_risk) : 0;
   
   double today_loss = GetTodayClosedLoss();
   
   int totalTrades = GetTodayTradeCount();

 if(!isMinimized)
{
   ObjectSetString(0, "RiskLabel_0", OBJPROP_TEXT, "MINI PROP FIRM UTILITY DASHBOARD");
   ObjectSetString(0, "RiskLabel_1", OBJPROP_TEXT, "* Account Balance: " + FormatMoney(balance));
   ObjectSetString(0, "RiskLabel_2", OBJPROP_TEXT, "* Equity Balance: " + FormatMoney(equity));
   ObjectSetString(0, "RiskLabel_3", OBJPROP_TEXT, "* Total Trades Today: " + IntegerToString(totalTrades));
   ObjectSetString(0, "RiskLabel_4", OBJPROP_TEXT, "* Positions (Opened Trades): " + IntegerToString(PositionsTotal()));
   ObjectSetString(0, "RiskLabel_5", OBJPROP_TEXT, "* Floating Profit/Loss: " + FormatMoney(pnl));
   ObjectSetString(0, "RiskLabel_6", OBJPROP_TEXT, "* Today's Closed Loss So Far: " + FormatMoney(today_loss));
}
   return(rates_total);
}

//================ RISK LOGIC ============
void CalculateRiskReward(double &total_risk, double &total_reward)
{
   total_risk = 0;
   total_reward = 0;

   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      string symbol = PositionGetString(POSITION_SYMBOL);

      double sl     = PositionGetDouble(POSITION_SL);
      double tp     = PositionGetDouble(POSITION_TP);
      double price  = PositionGetDouble(POSITION_PRICE_OPEN);
      double volume = PositionGetDouble(POSITION_VOLUME);
      long   type   = PositionGetInteger(POSITION_TYPE);

      double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double tick_size  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);

      if(tick_size <= 0)
         continue;

      // ---------- SL RISK ----------
      if(sl != 0.0)
      {
         double diff = (type == POSITION_TYPE_BUY) ? (price - sl) : (sl - price);

         if(diff > 0)
         {
            double ticks = diff / tick_size;
            total_risk += ticks * tick_value * volume;
         }
      }

      // ---------- TP REWARD ----------
      if(tp != 0.0)
      {
         double diff = (type == POSITION_TYPE_BUY) ? (tp - price) : (price - tp);

         if(diff > 0)
         {
            double ticks = diff / tick_size;
            total_reward += ticks * tick_value * volume;
         }
      }
   }
}
//+------------------------------------------------------------------+
  string FormatMoney(double value)
{
   string sign = "";

   if(value < 0)
   {
      sign = "-";
      value = MathAbs(value);
   }

   string str = DoubleToString(value, 2);

   int dot_pos = StringFind(str, ".");
   string int_part = (dot_pos >= 0) ? StringSubstr(str, 0, dot_pos) : str;
   string dec_part = (dot_pos >= 0) ? StringSubstr(str, dot_pos) : "";

   string result = "";
   int len = StringLen(int_part);
   int count = 0;

   for(int i = len - 1; i >= 0; i--)
   {
      result = StringSubstr(int_part, i, 1) + result;
      count++;

      if(count % 3 == 0 && i != 0)
         result = "," + result;
   }

   return sign + "$" + result + dec_part;
}
//+------------------------------------------------------------------+
// === FUNCTION: Get start of today ===
datetime GetStartOfDay()
{
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(), timeStruct);

   timeStruct.hour = 0;
   timeStruct.min  = 0;
   timeStruct.sec  = 0;

   return StructToTime(timeStruct);
}
//+------------------------------------------------------------------+
// === FUNCTION: Count today's trades (open + closed) ===
int GetTodayTradeCount()
{
   int count = 0;
   datetime start = GetStartOfDay();
   datetime now   = TimeCurrent();

   // --- Count CLOSED trades (Deals) ---
   HistorySelect(start, now);

   int deals = HistoryDealsTotal();

   for(int i = 0; i < deals; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);

      if(ticket == 0) continue;

// Count only ENTRY deals (actual trades opened)
      if(HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_IN)
         count++;
   }

   return count;
}
//+------------------------------------------------------------------+
double GetTodayClosedLoss()
{
   datetime today_start = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));

   if(!HistorySelect(today_start, TimeCurrent()))
      return 0;

   double total_loss = 0;

   int deals = HistoryDealsTotal();

   for(int i = 0; i < deals; i++)
   {
      ulong ticket = HistoryDealGetTicket(i);

      if(ticket == 0)
         continue;

      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);

      // Only count LOSSES (negative profit)
      if(profit < 0)
         total_loss += profit;
   }

   return total_loss;
}
//================ PANEL CREATION =========
void CreatePanel()
{
   // PANEL BACKGROUND
   ObjectCreate(0, panel_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, panel_name, OBJPROP_XDISTANCE, Panel_X);
   ObjectSetInteger(0, panel_name, OBJPROP_YDISTANCE, Panel_Y);
   ObjectSetInteger(0, panel_name, OBJPROP_XSIZE, 300);
   ObjectSetInteger(0, panel_name, OBJPROP_BGCOLOR, Panel_BG);
   ObjectSetInteger(0, panel_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, panel_name, OBJPROP_SELECTABLE, true);

   // TOGGLE BUTTON
   ObjectCreate(0, btn_toggle, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, btn_toggle, OBJPROP_XDISTANCE, Panel_X + 265);
   ObjectSetInteger(0, btn_toggle, OBJPROP_YDISTANCE, Panel_Y + 8);
   ObjectSetInteger(0, btn_toggle, OBJPROP_XSIZE, 23);
   ObjectSetInteger(0, btn_toggle, OBJPROP_YSIZE, 20);
   ObjectSetString(0, btn_toggle, OBJPROP_TEXT, "-");

   // FULL LABELS
   for(int i = 0; i < 7; i++)
   {
      string name = "RiskLabel_" + IntegerToString(i);

      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, Panel_X + 10);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, Panel_Y + 10 + (i * 18));
      ObjectSetInteger(0, name, OBJPROP_COLOR, Text_Color);  
      ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   }

   // MINIMIZED LABEL
   ObjectCreate(0, min_label, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, min_label, OBJPROP_XDISTANCE, Panel_X + 10);
   ObjectSetInteger(0, min_label, OBJPROP_YDISTANCE, Panel_Y + 10);
   ObjectSetInteger(0, min_label, OBJPROP_COLOR, Text_Color); 
   ObjectSetString(0, min_label, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, min_label, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, min_label, OBJPROP_TEXT, "MINI PROP FIRM UTILITY DASHBOARD");
}

//================ STATE CONTROL ==========
void ApplyPanelState()
{
   if(isMinimized)
   {
      for(int i = 0; i < 7; i++)
      {
         string name = "RiskLabel_" + IntegerToString(i);

         // USE SPACE INSTEAD OF EMPTY STRING (CRITICAL FIX)
         ObjectSetString(0, name, OBJPROP_TEXT, " ");
         ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      }

      ObjectSetString(0, min_label, OBJPROP_TEXT, "MINI PROP FIRM UTILITY DASHBOARD");
      ObjectSetInteger(0, min_label, OBJPROP_HIDDEN, false);

      ObjectSetInteger(0, panel_name, OBJPROP_YSIZE, 40);
   }
   else
   {
      for(int i = 0; i < 7; i++)
      {
         ObjectSetInteger(0, "RiskLabel_" + IntegerToString(i), OBJPROP_HIDDEN, false);
      }

      // ALSO CLEAR MIN LABEL TEXT SAFELY
      ObjectSetString(0, min_label, OBJPROP_TEXT, " ");
      ObjectSetInteger(0, min_label, OBJPROP_HIDDEN, true);

      ObjectSetInteger(0, panel_name, OBJPROP_YSIZE, 145);//125);
   }
}
//================ EVENTS =================
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == btn_toggle)
      {
         isMinimized = !isMinimized;

         ObjectSetString(0, btn_toggle, OBJPROP_TEXT, isMinimized ? "+" : "-");

         ApplyPanelState();
      }
   }

   if(id == CHARTEVENT_OBJECT_DRAG && sparam == panel_name)
   {
      int x = (int)ObjectGetInteger(0, panel_name, OBJPROP_XDISTANCE);
      int y = (int)ObjectGetInteger(0, panel_name, OBJPROP_YDISTANCE);

      MoveAllObjects(x, y);
   }
}

//================ MOVE SYSTEM =====================
void MoveAllObjects(int x, int y)
{
   ObjectSetInteger(0, panel_name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, panel_name, OBJPROP_YDISTANCE, y);

   for(int i = 0; i < 12; i++)
   {
      ObjectSetInteger(0, "RiskLabel_" + IntegerToString(i),
                       OBJPROP_XDISTANCE, x + 10);
      ObjectSetInteger(0, "RiskLabel_" + IntegerToString(i),
                       OBJPROP_YDISTANCE, y + 10 + (i * 18));
   }

   ObjectSetInteger(0, min_label, OBJPROP_XDISTANCE, x + 10);
   ObjectSetInteger(0, min_label, OBJPROP_YDISTANCE, y + 10);

   ObjectSetInteger(0, btn_toggle, OBJPROP_XDISTANCE, x + 300);//205);
   ObjectSetInteger(0, btn_toggle, OBJPROP_YDISTANCE, y + 5);
}
//+------------------------------------------------------------------+