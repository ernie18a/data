//+------------------------------------------------------------------+
//|                                                   AgentGuard.mq5 |
//|                                          Copyright 2026, kouaAlgo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Abdelhakim Kouachi"
#property link      "https://www.mql5.com/en/users/kouaAlgo"
#property version   "1.00"
#property description "AgentGuard: an independent risk layer for AI-driven trading."
#property description "Watches every open position on a timer and enforces hard limits:"
#property description "max total volume, max position count, mandatory stop-loss,"
#property description "and a daily-loss circuit breaker that closes everything"
#property description "when the day goes wrong. Works alongside any EA or AI agent."

#include <Trade\Trade.mqh>

//--- inputs: exposure limits
input group "Exposure limits"
input double InpMaxTotalVolume = 5.0;   // Max total open volume (lots)
input int    InpMaxPositions   = 10;    // Max open positions (all symbols)

//--- inputs: daily circuit breaker
input group "Daily circuit breaker"
input double InpDailyLossPct   = 3.0;   // Daily loss limit (% of day-start equity)

//--- inputs: stop-loss discipline
input group "Stop-loss discipline"
input bool   InpRequireSL      = true;  // Every position must carry a stop-loss

//--- inputs: behavior
input group "Behavior"
input bool   InpCloseViolators = true;  // Close violating positions (off = alert only)
input int    InpCheckSec       = 5;      // Check interval (seconds)
input long   InpMagicFilter    = -1;     // Magic-number filter (-1 = all positions)
input bool   InpShowPanel      = true;   // Show on-chart status panel

//--- globals
CTrade   g_trade;
double   g_dayEquity = 0.0;             // equity anchor taken at day start
int      g_dayId     = -1;              // server-day identifier of the anchor
bool     g_breached  = false;           // latched until the next day
string   g_closeError = "";             // last close failure (shown on panel)
string   G_PFX       = "AG_";           // object-name prefix

//+------------------------------------------------------------------+
//| Small helpers                                                    |
//+------------------------------------------------------------------+
string DS(double v) { return DoubleToString(v, 2); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Describe(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket))
      return StringFormat("#%I64u (gone)", ticket);
   string sym = PositionGetString(POSITION_SYMBOL);
   double vol = PositionGetDouble(POSITION_VOLUME);
   long   dir = PositionGetInteger(POSITION_TYPE);
   return StringFormat("#%I64u %s %s %.2f lots",
                       ticket, sym, (dir == POSITION_TYPE_BUY ? "BUY" : "SELL"), vol);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Watched()
  {
   if(InpMagicFilter < 0)
      return true;
   return PositionGetInteger(POSITION_MAGIC) == InpMagicFilter;
  }

//+------------------------------------------------------------------+
//| Day anchor: capture equity once per server day                   |
//+------------------------------------------------------------------+
void AnchorDay(bool force)
  {
   MqlDateTime st;
   TimeToStruct(TimeTradeServer(), st);
   int id = st.year * 1000 + st.day_of_year;
   if(force || id != g_dayId)
     {
      g_dayId     = id;
      g_dayEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_breached  = false;
      Print("AgentGuard: new day anchor, equity = ", DS(g_dayEquity));
     }
  }

//+------------------------------------------------------------------+
//| Closing primitives                                               |
//+------------------------------------------------------------------+
bool CloseTicket(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket))
      return false;
   string sym = PositionGetString(POSITION_SYMBOL);
   g_trade.SetTypeFillingBySymbol(sym);
   bool ok = g_trade.PositionClose(ticket);
   if(!ok)
     {
      g_closeError = "rc=" + IntegerToString(g_trade.ResultRetcode());
      Print("AgentGuard: FAILED to close ", Describe(ticket),
            " retcode=", g_trade.ResultRetcode());
     }
   return ok;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0 || !Watched())
         continue;
      CloseTicket(tk);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong NewestTicket()
  {
   ulong    best = 0;
   datetime tmax = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0 || !Watched())
         continue;
      datetime t = (datetime)PositionGetInteger(POSITION_TIME);
      if(t >= tmax)
        {
         tmax = t;
         best = tk;
        }
     }
   return best;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong LargestTicket()
  {
   ulong  best = 0;
   double vmax = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0 || !Watched())
         continue;
      double v = PositionGetDouble(POSITION_VOLUME);
      if(v >= vmax)
        {
         vmax = v;
         best = tk;
        }
     }
   return best;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalVolume()
  {
   double v = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0 || !Watched())
         continue;
      v += PositionGetDouble(POSITION_VOLUME);
     }
   return v;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WatchedCount()
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0 || !Watched())
         continue;
      n++;
     }
   return n;
  }

//+------------------------------------------------------------------+
//| The enforcement pass — runs on every timer tick                  |
//+------------------------------------------------------------------+
void Enforce()
  {
   g_closeError = "";   // reset each pass; set again if a close fails
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

//--- 1. daily circuit breaker (checked first: nothing else matters)
   if(g_dayEquity > 0.0 && !g_breached)
     {
      double pnl   = equity - g_dayEquity;
      double limit = g_dayEquity * InpDailyLossPct / 100.0;
      if(pnl <= -limit)
        {
         g_breached = true;
         string msg = StringFormat(
                         "AgentGuard BREACH: daily P/L %s (limit -%s). Closing all positions.",
                         DS(pnl), DS(limit));
         Print(msg);
         Alert(msg);
         if(InpCloseViolators)
            CloseAllPositions();
         return;
        }
     }
   if(g_breached)
      return;   // latched until the next server day

//--- 2. scan: count, volume, positions missing a stop-loss
   int   count = 0;
   ulong noSL[];
   ArrayResize(noSL, 0);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0 || !Watched())
         continue;
      count++;
      if(InpRequireSL && PositionGetDouble(POSITION_SL) == 0.0)
        {
         int n = ArraySize(noSL);
         ArrayResize(noSL, n + 1);
         noSL[n] = tk;
        }
     }

//--- 3. mandatory stop-loss
   for(int k = 0; k < ArraySize(noSL); k++)
     {
      string msg = "AgentGuard: no stop-loss on " + Describe(noSL[k]);
      Print(msg);
      if(InpCloseViolators)
        {
         Alert(msg);
         CloseTicket(noSL[k]);
        }
     }

//--- 4. max open positions → trim the newest first
   while(count > InpMaxPositions)
     {
      ulong tk = NewestTicket();
      if(tk == 0)
         break;
      Print("AgentGuard: position-count breach, closing newest: ", Describe(tk));
      if(InpCloseViolators)
         Alert("AgentGuard: too many positions, closing ", Describe(tk));
      else
         break;
      if(CloseTicket(tk))
         count--;
      else
         break;
     }

//--- 5. max total volume → trim the largest first
   while(TotalVolume() > InpMaxTotalVolume)
     {
      ulong tk = LargestTicket();
      if(tk == 0)
         break;
      Print("AgentGuard: volume breach (", DS(TotalVolume()),
            " lots), closing largest: ", Describe(tk));
      if(!InpCloseViolators)
         break;
      if(!CloseTicket(tk))
         break;
     }
  }

//+------------------------------------------------------------------+
//| Status panel                                                     |
//+------------------------------------------------------------------+
void BuildPanel()
  {
   ObjectCreate(0, G_PFX + "BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_XDISTANCE, 240);   // 230 width + 10 margin from right edge
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_XSIZE, 230);
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_YSIZE, 96);
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_BGCOLOR, C'25,25,30');
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_BACK, false);
   ObjectSetInteger(0, G_PFX + "BG", OBJPROP_SELECTABLE, false);

   string names[4] = {"TITLE", "STATUS", "PNL", "POS"};
   int    ys[4]    = {36, 54, 72, 90};
   for(int i = 0; i < 4; i++)
     {
      string nm = G_PFX + names[i];
      ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, 18);
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, ys[i]);
      ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, nm, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);  // text grows leftward
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 10 : 9);
      ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false);
     }
   ObjectSetString(0, G_PFX + "TITLE", OBJPROP_TEXT, "AgentGuard  v1.00");
   ObjectSetInteger(0, G_PFX + "TITLE", OBJPROP_COLOR, clrWhite);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RefreshPanel()
  {
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double pnl    = equity - g_dayEquity;
   int    cnt    = WatchedCount();
   double vol    = TotalVolume();

   color stColor = g_breached ? clrRed : clrLimeGreen;
   string stText = g_breached ? "BREACHED — latched till next day" : "ARMED";
   if(g_closeError != "" && !g_breached)
     {
      stText  = "ARMED — CLOSE FAILED " + g_closeError;
      stColor = clrOrange;   // close rejected: check Algo Trading permission
     }

   ObjectSetString(0, G_PFX + "STATUS", OBJPROP_TEXT, "Status: " + stText);
   ObjectSetInteger(0, G_PFX + "STATUS", OBJPROP_COLOR, stColor);
   ObjectSetString(0, G_PFX + "PNL", OBJPROP_TEXT,
                   StringFormat("Daily P/L: %s  (limit -%.2f%%)", DS(pnl), InpDailyLossPct));
   ObjectSetInteger(0, G_PFX + "PNL", OBJPROP_COLOR, pnl < 0 ? clrOrange : clrLightGray);
   ObjectSetString(0, G_PFX + "POS", OBJPROP_TEXT,
                   StringFormat("Positions: %d / %d   Vol: %s / %s lots",
                                cnt, InpMaxPositions, DS(vol), DS(InpMaxTotalVolume)));
   ObjectSetInteger(0, G_PFX + "POS", OBJPROP_COLOR, clrLightGray);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Entry points                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_trade.SetDeviationInPoints(30);
   AnchorDay(true);
   EventSetTimer(InpCheckSec);
   if(InpShowPanel)
      BuildPanel();
   Print("AgentGuard v1.00 started on ", _Symbol,
         " | maxVol=", DS(InpMaxTotalVolume),
         " maxPos=", InpMaxPositions,
         " dailyLoss=", DS(InpDailyLossPct), "%",
         " requireSL=", (InpRequireSL ? "yes" : "no"));
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, G_PFX);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   AnchorDay(false);   // catch day rollover even between timer ticks
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   AnchorDay(false);
   Enforce();
   if(InpShowPanel)
      RefreshPanel();
  }
//+------------------------------------------------------------------+
