//+------------------------------------------------------------------+
//|                                        GMMatrixMonitor.mq5        |
//|   Read-only monitor for the GoldMartin EA matrix on one account.  |
//|   MONITOR ONLY — never sends, modifies or closes any order.       |
//+------------------------------------------------------------------+
#property copyright "QuantDev_CN"
#property link      "https://www.mql5.com/en/users/jin271327"
#property version   "1.00"
#property description "GMMatrixMonitor - read-only dashboard for the GoldMartin EA matrix: per-magic net P/L, account drawdown, daily-loss breaker progress, and freeze/liquidate threshold proximity. Does NOT trade."

//---- inputs
input string  InpMagics     = "20250001,20250937"; // magic numbers of the EAs to monitor (comma separated)
input double  InpBaseEquity = 0.0;                 // reference equity for drawdown (0 = use account balance at start)
input double  InpFreezePct  = 28.0;                // freeze-new-open at this equity drawdown %
input double  InpLiquidPct  = 30.0;               // liquidate-all at this equity drawdown %
input double  InpDailyLoss  = 100.0;              // daily-loss breaker threshold (account currency)
input int     InpRefreshMs  = 500;                // panel refresh interval (ms)
input int     InpPanelY     = 70;                 // panel top offset in pixels (avoids the EA comment block)

//---- constants
#define MAXMAG 8
#define NLABEL 20

//---- globals
long   g_magic[MAXMAG];
int    g_mcount = 0;
double g_baseEq  = 0.0;
string g_lbl[NLABEL];
string g_bg = "gmm_bg";

//+------------------------------------------------------------------+
//| helper: trim spaces (MQL5 trim funcs are void / in-place)        |
//+------------------------------------------------------------------+
string Trim(string s)
{
   StringTrimLeft(s);
   StringTrimRight(s);
   return s;
}

//+------------------------------------------------------------------+
//| helper: parse "a,b,c" into the magic array                      |
//+------------------------------------------------------------------+
void ParseMagics(string s)
{
   g_mcount = 0;
   string t = Trim(s);
   int start = 0;
   while(start < StringLen(t) && g_mcount < MAXMAG)
   {
      int p = StringFind(t, ",", start);
      string part;
      if(p < 0) { part = StringSubstr(t, start); start = StringLen(t); }
      else      { part = StringSubstr(t, start, p - start); start = p + 1; }
      part = Trim(part);
      if(StringLen(part) > 0)
         g_magic[g_mcount++] = StringToInteger(part);
   }
}

//+------------------------------------------------------------------+
//| helper: make / update one label                                  |
//+------------------------------------------------------------------+
void SetLabel(int idx, string txt, color clr)
{
   if(idx < 0 || idx >= NLABEL) return;
   ObjectSetString(0, g_lbl[idx], OBJPROP_TEXT, txt);
   ObjectSetInteger(0, g_lbl[idx], OBJPROP_COLOR, clr);
   ObjectSetInteger(0, g_lbl[idx], OBJPROP_HIDDEN, false);
}

//+------------------------------------------------------------------+
//| create the label pool                                            |
//+------------------------------------------------------------------+
void CreateLabels(void)
{
   // dark card behind the text so the panel stays readable over candles
   if(ObjectCreate(0, g_bg, OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, g_bg, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, g_bg, OBJPROP_XDISTANCE, 4);
      ObjectSetInteger(0, g_bg, OBJPROP_YDISTANCE, InpPanelY - 6);
      ObjectSetInteger(0, g_bg, OBJPROP_XSIZE, 320);
      ObjectSetInteger(0, g_bg, OBJPROP_YSIZE, 250);
      ObjectSetInteger(0, g_bg, OBJPROP_BGCOLOR, C'18,18,18');
      ObjectSetInteger(0, g_bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, g_bg, OBJPROP_COLOR, clrDimGray);
      ObjectSetInteger(0, g_bg, OBJPROP_BACK, false);
      ObjectSetInteger(0, g_bg, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_bg, OBJPROP_HIDDEN, false);
   }

   for(int i = 0; i < NLABEL; i++)
   {
      g_lbl[i] = "gmm_lbl_" + IntegerToString(i);
      if(!ObjectCreate(0, g_lbl[i], OBJ_LABEL, 0, 0, 0))
         continue;
      ObjectSetInteger(0, g_lbl[i], OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, g_lbl[i], OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, g_lbl[i], OBJPROP_YDISTANCE, InpPanelY + i * 18);
      ObjectSetInteger(0, g_lbl[i], OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, g_lbl[i], OBJPROP_FONT, "Courier New");
      ObjectSetString(0, g_lbl[i], OBJPROP_TEXT, "");
      ObjectSetInteger(0, g_lbl[i], OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, g_lbl[i], OBJPROP_BACK, false);
   }
}

//+------------------------------------------------------------------+
//| compute and draw                                                 |
//+------------------------------------------------------------------+
void Draw(void)
{
   double net[MAXMAG];
   for(int i = 0; i < MAXMAG; i++) net[i] = 0.0;
   double total = 0.0;
   double dailyLoss = 0.0;

   datetime todayStart = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));

   HistorySelect(0, TimeCurrent());
   for(int i = 0; i < HistoryDealsTotal(); i++)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      long m   = HistoryDealGetInteger(ticket, DEAL_MAGIC);
      double p = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      datetime tm = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      for(int j = 0; j < g_mcount; j++)
         if(m == g_magic[j]) net[j] += p;
      if(p < 0.0 && tm >= todayStart) dailyLoss += (-p);
   }

   for(int p = 0; p < PositionsTotal(); p++)
   {
      ulong pt = PositionGetTicket(p);
      if(pt == 0) continue;
      if(!PositionSelectByTicket(pt)) continue;
      long m  = PositionGetInteger(POSITION_MAGIC);
      double pf = PositionGetDouble(POSITION_PROFIT);
      for(int j = 0; j < g_mcount; j++)
         if(m == g_magic[j]) net[j] += pf;
   }

   for(int j = 0; j < g_mcount; j++) total += net[j];

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double dd = (g_baseEq > 0.0) ? (g_baseEq - equity) / g_baseEq * 100.0 : 0.0;
   if(dd < 0.0) dd = 0.0;

   string status = "NORMAL";
   color  scol   = clrLime;
   if(dd >= InpLiquidPct) { status = "LIQUIDATE"; scol = clrRed; }
   else if(dd >= InpFreezePct) { status = "FREEZE"; scol = clrOrange; }

   SetLabel(0, "GM Matrix Monitor   (read-only)", clrWhite);
   SetLabel(1, "Base eq: " + DoubleToString(g_baseEq, 2) +
                "   Equity: " + DoubleToString(equity, 2), clrLightGray);
   SetLabel(2, "Drawdown: " + DoubleToString(dd, 2) + "%   Status: " + status, scol);
   SetLabel(3, "Daily loss: " + DoubleToString(dailyLoss, 2) +
                " / " + DoubleToString(InpDailyLoss, 2),
                (dailyLoss >= InpDailyLoss) ? clrRed : clrLightGray);
   SetLabel(4, "--- per magic net ---", clrSkyBlue);

   for(int j = 0; j < g_mcount; j++)
   {
      color c = (net[j] >= 0.0) ? clrLime : clrRed;
      SetLabel(5 + j, "magic " + IntegerToString(g_magic[j]) + " : " + DoubleToString(net[j], 2), c);
   }
   SetLabel(5 + g_mcount, "Total net: " + DoubleToString(total, 2),
            (total >= 0.0) ? clrLime : clrRed);
   SetLabel(6 + g_mcount, "Freeze@" + DoubleToString(InpFreezePct, 0) +
                "%  Liquidate@" + DoubleToString(InpLiquidPct, 0) + "%", clrLightGray);

   // resize the card to the number of rows actually used
   ObjectSetInteger(0, g_bg, OBJPROP_YDISTANCE, InpPanelY - 6);
   ObjectSetInteger(0, g_bg, OBJPROP_YSIZE, (7 + g_mcount) * 18 + 12);
}

//+------------------------------------------------------------------+
//| init                                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   ParseMagics(InpMagics);
   if(g_mcount == 0)
   {
      Print("GMMatrixMonitor: no valid magic numbers parsed from InpMagics.");
      return INIT_FAILED;
   }
   g_baseEq = (InpBaseEquity > 0.0) ? InpBaseEquity : AccountInfoDouble(ACCOUNT_BALANCE);
   CreateLabels();
   Draw();
   EventSetTimer(MathMax(1, (int)(InpRefreshMs / 1000)));
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| timer                                                           |
//+------------------------------------------------------------------+
void OnTimer()
{
   Draw();
}

//+------------------------------------------------------------------+
//| deinit                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   for(int i = 0; i < NLABEL; i++)
      if(StringLen(g_lbl[i]) > 0)
         ObjectDelete(0, g_lbl[i]);
   ObjectDelete(0, g_bg);
   EventKillTimer();
}
