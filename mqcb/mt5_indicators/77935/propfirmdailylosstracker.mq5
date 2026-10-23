//+------------------------------------------------------------------+
//| Prop Firm Daily Loss Tracker                                     |
//| Shows today's result against the daily and max loss limits.      |
//| Monitor only: no signals, no orders, no profit claims.           |
//+------------------------------------------------------------------+
#property version   "1.00"
#property description "Daily loss limit monitor for funded / prop firm accounts."
#property description "It only reads the account and draws on the chart. It gives no signals and places no orders."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

input group "Account"
input double AccountSize      = 100000.0;  // Account size (starting balance)
input double DailyLossPercent = 5.0;       // Daily loss limit (%)
input double MaxLossPercent   = 10.0;      // Max total loss limit (%)

input group "Day reset"
input int    DayStartHour     = 0;         // Server hour when the trading day starts (0-23)

input group "Alerts"
input double WarnPercent      = 70.0;      // Warning level (% of daily limit used)
input bool   UseAlert         = true;      // Popup alert
input bool   UsePush          = false;     // Push notification to mobile

input group "Display"
input ENUM_BASE_CORNER Corner = CORNER_RIGHT_LOWER; // Panel corner
input int              FontSize = 9;                // Font size
input color            TextColor = clrGray;         // Text color

string   g_prefix   = "PFDL_";
datetime g_dayKey   = 0;
bool     g_warned   = false;
bool     g_limitHit = false;
ulong    g_lastRun  = 0;

//+------------------------------------------------------------------+
void SetRow(const int index, const int total, const string text, const color clr)
{
   string name = g_prefix + IntegerToString(index);
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   }

   bool lower = (Corner == CORNER_LEFT_LOWER || Corner == CORNER_RIGHT_LOWER);
   bool right = (Corner == CORNER_RIGHT_UPPER || Corner == CORNER_RIGHT_LOWER);
   int lineH = FontSize + 8;
   int baseY = lower ? 35 : 10;
   int y = baseY + (lower ? (total - 1 - index) : index) * lineH;

   ENUM_ANCHOR_POINT anchor;
   if(right)
      anchor = lower ? ANCHOR_RIGHT_LOWER : ANCHOR_RIGHT_UPPER;
   else
      anchor = lower ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER;

   ObjectSetInteger(0, name, OBJPROP_CORNER, Corner);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}

//+------------------------------------------------------------------+
void Notify(const string msg)
{
   Print(msg);
   if(UseAlert)
      Alert(msg);
   if(UsePush)
      SendNotification(msg);
}

//+------------------------------------------------------------------+
void Update()
{
   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);

   datetime now = TimeCurrent();
   MqlDateTime t;
   TimeToStruct(now, t);
   t.hour = DayStartHour;
   t.min  = 0;
   t.sec  = 0;
   datetime dayStart = StructToTime(t);
   if(dayStart > now)
      dayStart -= 86400;

   // Closed result of the current day and balance operations (deposits, withdrawals)
   double closedSum  = 0.0;
   double balanceOps = 0.0;
   if(HistorySelect(dayStart, now))
   {
      int n = HistoryDealsTotal();
      for(int i = 0; i < n; i++)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket == 0)
            continue;
         long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
         double v = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                  + HistoryDealGetDouble(ticket, DEAL_SWAP)
                  + HistoryDealGetDouble(ticket, DEAL_COMMISSION)
                  + HistoryDealGetDouble(ticket, DEAL_FEE);
         if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
            closedSum += v;
         else
            balanceOps += v;
      }
   }

   double startBalance = balance - closedSum - balanceOps;
   double dayPnL       = closedSum + (equity - balance);   // closed + floating
   double dailyLimit   = AccountSize * DailyLossPercent / 100.0;
   double maxFloor     = AccountSize * (1.0 - MaxLossPercent / 100.0);
   double dailyLoss    = (dayPnL < 0.0) ? -dayPnL : 0.0;
   double usedPct      = (dailyLimit > 0.0) ? dailyLoss / dailyLimit * 100.0 : 0.0;
   double remDaily     = dailyLimit - dailyLoss;
   double remMax       = equity - maxFloor;

   string status;
   color  statusClr;
   if(usedPct >= 100.0 || remMax <= 0.0)
   {
      status    = "LIMIT REACHED";
      statusClr = clrRed;
   }
   else if(usedPct >= WarnPercent)
   {
      status    = "WARNING";
      statusClr = clrOrange;
   }
   else
   {
      status    = "OK";
      statusClr = clrLimeGreen;
   }

   // Alerts: once per level, reset when a new day starts
   if(g_dayKey != dayStart)
   {
      g_dayKey   = dayStart;
      g_warned   = false;
      g_limitHit = false;
   }
   if(usedPct >= 100.0 && !g_limitHit)
   {
      g_limitHit = true;
      g_warned   = true;
      Notify("Daily loss limit reached: " + DoubleToString(dailyLoss, 2) + " " + cur + " (" + DoubleToString(usedPct, 1) + "% of the limit).");
   }
   else if(usedPct >= WarnPercent && !g_warned)
   {
      g_warned = true;
      Notify("Daily loss warning: " + DoubleToString(usedPct, 1) + "% of the daily limit used.");
   }

   color pnlClr = (dayPnL < 0.0) ? clrOrange : TextColor;

   int total = 8;
   SetRow(0, total, "Prop Firm Daily Loss Tracker", TextColor);
   SetRow(1, total, "Day result: " + DoubleToString(dayPnL, 2) + " " + cur, pnlClr);
   SetRow(2, total, "Day start balance: " + DoubleToString(startBalance, 2) + " " + cur, TextColor);
   SetRow(3, total, "Daily limit used: " + DoubleToString(usedPct, 1) + "% of " + DoubleToString(dailyLimit, 2) + " " + cur, TextColor);
   SetRow(4, total, "Room left today: " + DoubleToString(remDaily, 2) + " " + cur, TextColor);
   SetRow(5, total, "Equity: " + DoubleToString(equity, 2) + " " + cur, TextColor);
   SetRow(6, total, "Room to max loss: " + DoubleToString(remMax, 2) + " " + cur, TextColor);
   SetRow(7, total, "Status: " + status, statusClr);
   ChartRedraw();
}

//+------------------------------------------------------------------+
int OnInit()
{
   if(AccountSize <= 0.0)
   {
      Print("Account size must be greater than zero.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(DailyLossPercent <= 0.0 || DailyLossPercent > 100.0 ||
      MaxLossPercent <= 0.0 || MaxLossPercent > 100.0)
   {
      Print("Loss limits must be between 0 and 100 percent.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(DayStartHour < 0 || DayStartHour > 23)
   {
      Print("Day start hour must be between 0 and 23.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(WarnPercent <= 0.0 || WarnPercent > 100.0)
   {
      Print("Warning level must be between 0 and 100 percent.");
      return(INIT_PARAMETERS_INCORRECT);
   }
   IndicatorSetString(INDICATOR_SHORTNAME, "Prop Firm Daily Loss Tracker");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, g_prefix);
   ChartRedraw();
}

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
   ulong nowMs = GetTickCount64();
   if(nowMs - g_lastRun >= 500)
   {
      g_lastRun = nowMs;
      Update();
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
