//+------------------------------------------------------------------+
//|                                                  DailyPnLPct.mq5 |
//|                                        Sandrine Claudine Laurain |
//+------------------------------------------------------------------+
#property copyright "Sandrine Claudine Laurain"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

input double InpLimitPct   = 5.0;     // Daily loss limit % (prop firm)
input int    InpResetHour  = 0;       // Day reset hour (server)
input color  InpColorOK    = clrLimeGreen;
input color  InpColorWarn  = clrOrange;
input color  InpColorBad   = clrTomato;
input int    InpFontSize   = 11;

datetime day_start;
double   base_balance;
string   obj = "DPP_label";

int OnInit()
{
   UpdateBaseline();
   EventSetTimer(30);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete(0, obj);
}

void UpdateBaseline()
{
   // find today's reset bar
   datetime now = TimeCurrent();
   MqlDateTime t; TimeToStruct(now, t);
   t.min = 0; t.sec = 0;
   t.hour = InpResetHour;
   datetime reset = StructToTime(t);
   if(reset > now) reset -= 86400;
   day_start = reset;
   base_balance = AccountInfoDouble(ACCOUNT_BALANCE);
}

void Draw()
{
   UpdateBaseline();
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double bal = base_balance;
   if(bal <= 0) return;
   double pnl_pct = (eq - bal) / bal * 100.0;
   double used = -pnl_pct;                       // positive when losing
   double remain = InpLimitPct - used;           // room left before breach
   color c = (used < InpLimitPct*0.5) ? InpColorOK
           : (used < InpLimitPct*0.8) ? InpColorWarn : InpColorBad;

   string txt = StringFormat("Day P&L: %+.2f%%   |   Daily loss used: %.1f%% / %.0f%%   |   Room left: %.1f%%",
                             pnl_pct, used < 0 ? 0.0 : used, InpLimitPct, remain < 0 ? 0.0 : remain);

   if(ObjectFind(0, obj) < 0)
      ObjectCreate(0, obj, OBJ_LABEL, 0, 0, 0);
   ObjectSetString (0, obj, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, obj, OBJPROP_COLOR, c);
   ObjectSetInteger(0, obj, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetString (0, obj, OBJPROP_FONT, "Consolas");
   ObjectSetInteger(0, obj, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, obj, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, obj, OBJPROP_YDISTANCE, 30);
   ChartRedraw();
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   Draw();
   return(rates_total);
}

void OnTimer() { Draw(); }
//+------------------------------------------------------------------+
