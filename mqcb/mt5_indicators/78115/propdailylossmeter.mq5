//+------------------------------------------------------------------+
//| PropDailyLossMeter.mq5                                           |
//| Shows on the chart how much of the daily loss limit of a prop    |
//| firm account is already used. Read-only: it never trades.        |
//+------------------------------------------------------------------+
#property copyright "Amedeo Nustriani"
#property version   "1.00"
#property description "Prop Daily Loss Meter: balance at the start of the day, equity level of the"
#property description "daily loss limit, loss used so far and what is left before the limit."
#property description "Optional warning popup and optional maximum loss line. Read-only: no trading."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

input group "Rules of your prop firm"
input double InpDailyLossPct  = 5.0;    // Daily loss limit (% of the balance at the start of the day)
input double InpMaxLossPct    = 10.0;   // Maximum loss limit (% of the initial balance)
input double InpInitialBalance= 0.0;    // Initial balance of the challenge (0 = do not show max loss)
input int    InpDayStartHour  = 0;      // Hour (server time) when your firm's day starts

input group "Warning"
input bool   InpWarn          = true;   // Popup when the loss used reaches the level below
input double InpWarnPct       = 80.0;   // Warning level (% of the daily limit used)

input group "Panel"
input int    InpX             = 15;     // Distance from the left border (pixels)
input int    InpY             = 25;     // Distance from the top border (pixels)
input int    InpFontSize      = 10;     // Font size

const string PFX    = "PDLM_";
const int    LINES  = 8;
datetime     g_warnDay = 0;

//+------------------------------------------------------------------+
string Money(const double v)
{
   return DoubleToString(v, 2);
}

datetime DayStart()
{
   datetime now = TimeCurrent();
   MqlDateTime d;
   TimeToStruct(now, d);
   d.hour = InpDayStartHour;
   d.min  = 0;
   d.sec  = 0;
   datetime ds = StructToTime(d);
   if(ds > now) ds -= 86400;
   return ds;
}

// balance at the start of the day = balance now - everything booked since then
double DayStartBalance(const datetime ds)
{
   double sum = 0.0;
   if(HistorySelect(ds, TimeCurrent() + 60))
   {
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
      {
         ulong t = HistoryDealGetTicket(i);
         if(t == 0) continue;
         sum += HistoryDealGetDouble(t, DEAL_PROFIT)
              + HistoryDealGetDouble(t, DEAL_SWAP)
              + HistoryDealGetDouble(t, DEAL_COMMISSION)
              + HistoryDealGetDouble(t, DEAL_FEE);
      }
   }
   return AccountInfoDouble(ACCOUNT_BALANCE) - sum;
}

void SetLine(const int idx, const string text, const color c)
{
   string n = PFX + (string)idx;
   if(ObjectFind(0, n) < 0)
   {
      if(!ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0)) return;
      ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, n, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, n, OBJPROP_XDISTANCE, InpX);
      ObjectSetInteger(0, n, OBJPROP_YDISTANCE, InpY + idx * (InpFontSize * 2));
      ObjectSetInteger(0, n, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetString(0, n, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   }
   ObjectSetString(0, n, OBJPROP_TEXT, text);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
}

void Update()
{
   color  neutral = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   string cur     = AccountInfoString(ACCOUNT_CURRENCY);

   datetime ds     = DayStart();
   double   b0     = DayStartBalance(ds);
   double   equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double   limit  = b0 * (1.0 - InpDailyLossPct / 100.0);
   double   budget = b0 - limit;                       // money you may lose in the day
   double   used   = MathMax(0.0, b0 - equity);
   double   left   = equity - limit;
   double   usedPc = (budget > 0.0) ? 100.0 * used / budget : 0.0;

   color cs = clrLimeGreen;
   if(usedPc >= 50.0) cs = clrOrange;
   if(usedPc >= InpWarnPct) cs = clrTomato;

   SetLine(0, "Prop Daily Loss Meter", neutral);
   SetLine(1, "Balance at day start: " + Money(b0) + " " + cur, neutral);
   SetLine(2, "Daily limit " + DoubleToString(InpDailyLossPct, 1) + "%: equity " + Money(limit), neutral);
   SetLine(3, "Equity now: " + Money(equity) + " " + cur, neutral);
   SetLine(4, "Used today: " + Money(used) + " " + cur + " (" + DoubleToString(usedPc, 0) + "% of the limit)", cs);
   SetLine(5, "Left before the limit: " + Money(MathMax(0.0, left)) + " " + cur, cs);

   if(InpInitialBalance > 0.0)
   {
      double maxLevel = InpInitialBalance * (1.0 - InpMaxLossPct / 100.0);
      double maxLeft  = equity - maxLevel;
      color  cm = (maxLeft <= InpInitialBalance * 0.02) ? clrTomato : neutral;
      SetLine(6, "Max loss " + DoubleToString(InpMaxLossPct, 1) + "%: equity " + Money(maxLevel)
                 + ", left " + Money(MathMax(0.0, maxLeft)) + " " + cur, cm);
   }
   else
      SetLine(6, "Max loss: not set (fill the initial balance)", neutral);

   SetLine(7, "Reference only. The rules of your firm decide.", neutral);

   if(InpWarn && usedPc >= InpWarnPct && g_warnDay != ds)
   {
      g_warnDay = ds;
      Alert(_Symbol + ": " + DoubleToString(usedPc, 0) + "% of the daily loss limit is used. Left: "
            + Money(MathMax(0.0, left)) + " " + cur);
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
int OnInit()
{
   if(InpDailyLossPct <= 0.0 || InpDailyLossPct >= 100.0 || InpDayStartHour < 0 || InpDayStartHour > 23)
   {
      Print("Check the inputs: daily loss between 0 and 100, day start hour between 0 and 23.");
      return INIT_PARAMETERS_INCORRECT;
   }
   IndicatorSetString(INDICATOR_SHORTNAME, "Prop Daily Loss Meter");
   EventSetTimer(1);
   Update();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
}

void OnTimer()
{
   Update();
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   return rates_total;
}
//+------------------------------------------------------------------+
