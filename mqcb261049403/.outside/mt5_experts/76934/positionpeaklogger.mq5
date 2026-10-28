//+------------------------------------------------------------------+
//|                                        PositionPeakLogger.mq5    |
//|                                          Copyright 2026, Petr K. |
//|                        https://www.mql5.com/en/users/petrkostal  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Petr Kostal"
#property link      "https://www.mql5.com/en/users/petrkostal"
#property version   "1.00"
#property description "Records how far every position actually travelled, measured in R"
#property description "(R = the distance from entry to the initial stop loss)."
#property description "Writes one CSV row per closed position: peak favourable excursion,"
#property description "worst adverse excursion, and the realised result - all in R."
#property description ""
#property description "Attach to any chart. It never opens, modifies or closes a trade."

//--- inputs
input group "=== Scope ==="
input bool   InpCurrentSymbolOnly = true;   // Track this chart's symbol only
input long   InpMagicFilter       = -1;     // Magic number to track (-1 = all)

input group "=== Output ==="
input string InpFileName          = "PositionPeaks.csv"; // CSV file (in MQL5\Files)
input bool   InpPrintToLog        = true;   // Also print each closed position to the log
input bool   InpPrintMilestones   = false;  // Print every 0.5 R milestone while open
input bool   InpShowPanel         = true;   // Show a small on-chart summary

//--- tracking table
#define MAX_TRACKED 256

struct PosTrack
{
   ulong    ticket;
   long     posId;
   string   symbol;
   bool     isLong;
   datetime openTime;
   double   openPrice;
   double   riskDist;     // |entry - initial SL| in price
   double   peakR;        // best excursion in R
   double   worstR;       // worst excursion in R (negative)
   double   loggedR;      // last milestone printed
   bool     used;
   bool     seen;
};

PosTrack g_track[MAX_TRACKED];

//--- running statistics for the panel
int    g_closedCount = 0;
double g_sumPeakR    = 0.0;
double g_sumResultR  = 0.0;
int    g_noStopCount = 0;

//+------------------------------------------------------------------+
int OnInit()
{
   for(int i = 0; i < MAX_TRACKED; i++)
   {
      g_track[i].used = false;
      g_track[i].seen = false;
   }

   if(!FileIsExist(InpFileName))
   {
      int h = FileOpen(InpFileName, FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
      if(h != INVALID_HANDLE)
      {
         FileWrite(h, "ticket", "symbol", "side", "open_time", "close_time",
                      "open_price", "risk_distance", "peak_R", "worst_R",
                      "result_R", "profit");
         FileClose(h);
      }
      else
         PrintFormat("PositionPeakLogger: cannot create %s (error %d)",
                     InpFileName, GetLastError());
   }

   EventSetTimer(1);
   Print("PositionPeakLogger started. Output file: ", InpFileName);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   Comment("");
}

//+------------------------------------------------------------------+
void OnTick()  { Scan(); }
void OnTimer() { Scan(); }

//+------------------------------------------------------------------+
//| Find the slot holding this ticket, or claim a free one.          |
//+------------------------------------------------------------------+
int SlotFor(const ulong ticket)
{
   for(int i = 0; i < MAX_TRACKED; i++)
      if(g_track[i].used && g_track[i].ticket == ticket) return i;

   for(int i = 0; i < MAX_TRACKED; i++)
      if(!g_track[i].used)
      {
         g_track[i].used     = true;
         g_track[i].ticket   = ticket;
         g_track[i].peakR    = 0.0;
         g_track[i].worstR   = 0.0;
         g_track[i].loggedR  = 0.0;
         return i;
      }
   return -1;   // table full
}

//+------------------------------------------------------------------+
//| Main pass: update open positions, then close out the missing ones|
//+------------------------------------------------------------------+
void Scan()
{
   for(int i = 0; i < MAX_TRACKED; i++) g_track[i].seen = false;

   for(int idx = PositionsTotal() - 1; idx >= 0; idx--)
   {
      ulong ticket = PositionGetTicket(idx);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      string sym = PositionGetString(POSITION_SYMBOL);
      if(InpCurrentSymbolOnly && sym != _Symbol) continue;
      if(InpMagicFilter >= 0 && PositionGetInteger(POSITION_MAGIC) != InpMagicFilter)
         continue;

      double openP = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl    = PositionGetDouble(POSITION_SL);
      double cur   = PositionGetDouble(POSITION_PRICE_CURRENT);
      bool   isBuy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);

      int s = SlotFor(ticket);
      if(s < 0) continue;
      g_track[s].seen = true;

      // First sighting: remember the initial stop distance. That distance is
      // what "1 R" means for this trade, so it must be captured before the
      // stop is trailed - afterwards the reference would drift.
      if(g_track[s].riskDist <= 0.0)
      {
         if(sl <= 0.0)
         {
            g_noStopCount++;
            g_track[s].used = false;   // no stop, no R - release the slot
            continue;
         }
         g_track[s].posId     = (long)PositionGetInteger(POSITION_IDENTIFIER);
         g_track[s].symbol    = sym;
         g_track[s].isLong    = isBuy;
         g_track[s].openTime  = (datetime)PositionGetInteger(POSITION_TIME);
         g_track[s].openPrice = openP;
         g_track[s].riskDist  = MathAbs(openP - sl);
         if(g_track[s].riskDist <= 0.0) { g_track[s].used = false; continue; }
      }

      double r = isBuy ? (cur - openP) / g_track[s].riskDist
                       : (openP - cur) / g_track[s].riskDist;

      if(r > g_track[s].peakR)  g_track[s].peakR  = r;
      if(r < g_track[s].worstR) g_track[s].worstR = r;

      if(InpPrintMilestones && g_track[s].peakR >= g_track[s].loggedR + 0.5)
      {
         g_track[s].loggedR = MathFloor(g_track[s].peakR * 2.0) / 2.0;
         PrintFormat("[Peak] #%I64u %s peak=%.2f R", ticket, sym, g_track[s].peakR);
      }
   }

   // Anything tracked but no longer open has just closed.
   for(int i = 0; i < MAX_TRACKED; i++)
      if(g_track[i].used && !g_track[i].seen)
      {
         ReportClosed(i);
         g_track[i].used     = false;
         g_track[i].riskDist = 0.0;
      }

   if(InpShowPanel) DrawPanel();
}

//+------------------------------------------------------------------+
//| Write one CSV row for a position that has just disappeared.      |
//+------------------------------------------------------------------+
void ReportClosed(const int s)
{
   double   profit    = 0.0;
   datetime closeTime = TimeCurrent();

   if(HistorySelectByPosition(g_track[s].posId))
   {
      int deals = HistoryDealsTotal();
      for(int d = 0; d < deals; d++)
      {
         ulong dealTicket = HistoryDealGetTicket(d);
         if(dealTicket == 0) continue;
         profit += HistoryDealGetDouble(dealTicket, DEAL_PROFIT)
                 + HistoryDealGetDouble(dealTicket, DEAL_SWAP)
                 + HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
         datetime dt = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
         if(dt > closeTime || d == 0) closeTime = dt;
      }
   }

   // Convert the money result back into R so trades of different sizes compare.
   double resultR = 0.0;
   double tickSize  = SymbolInfoDouble(g_track[s].symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(g_track[s].symbol, SYMBOL_TRADE_TICK_VALUE);
   double volume    = 0.0;
   if(HistorySelectByPosition(g_track[s].posId) && HistoryDealsTotal() > 0)
   {
      ulong firstDeal = HistoryDealGetTicket(0);
      if(firstDeal != 0) volume = HistoryDealGetDouble(firstDeal, DEAL_VOLUME);
   }
   if(tickSize > 0 && tickValue > 0 && volume > 0)
   {
      double riskMoney = (g_track[s].riskDist / tickSize) * tickValue * volume;
      if(riskMoney > 0) resultR = profit / riskMoney;
   }

   int dg = (int)SymbolInfoInteger(g_track[s].symbol, SYMBOL_DIGITS);
   if(dg <= 0) dg = _Digits;

   int h = FileOpen(InpFileName, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
   if(h != INVALID_HANDLE)
   {
      FileSeek(h, 0, SEEK_END);
      FileWrite(h,
                (string)g_track[s].ticket,
                g_track[s].symbol,
                g_track[s].isLong ? "BUY" : "SELL",
                TimeToString(g_track[s].openTime, TIME_DATE | TIME_MINUTES),
                TimeToString(closeTime, TIME_DATE | TIME_MINUTES),
                DoubleToString(g_track[s].openPrice, dg),
                DoubleToString(g_track[s].riskDist, dg),
                DoubleToString(g_track[s].peakR, 2),
                DoubleToString(g_track[s].worstR, 2),
                DoubleToString(resultR, 2),
                DoubleToString(profit, 2));
      FileClose(h);
   }

   g_closedCount++;
   g_sumPeakR   += g_track[s].peakR;
   g_sumResultR += resultR;

   if(InpPrintToLog)
      PrintFormat("[PeakLog] #%I64u %s %s peak=%.2f R  worst=%.2f R  result=%.2f R  (%.2f)",
                  g_track[s].ticket, g_track[s].symbol,
                  g_track[s].isLong ? "BUY" : "SELL",
                  g_track[s].peakR, g_track[s].worstR, resultR, profit);
}

//+------------------------------------------------------------------+
void DrawPanel()
{
   int open = 0;
   for(int i = 0; i < MAX_TRACKED; i++) if(g_track[i].used) open++;

   string txt = "Position Peak Logger\n";
   txt += StringFormat("open tracked: %d\n", open);
   txt += StringFormat("closed logged: %d\n", g_closedCount);
   if(g_closedCount > 0)
   {
      txt += StringFormat("avg peak:   %.2f R\n", g_sumPeakR   / g_closedCount);
      txt += StringFormat("avg result: %.2f R\n", g_sumResultR / g_closedCount);
      txt += StringFormat("given back: %.2f R per trade\n",
                          (g_sumPeakR - g_sumResultR) / g_closedCount);
   }
   if(g_noStopCount > 0)
      txt += StringFormat("skipped (no stop loss): %d\n", g_noStopCount);

   Comment(txt);
}
//+------------------------------------------------------------------+
