//+------------------------------------------------------------------+
//| DrawdownMeter.mq5                                       v1.10    |
//| Underwater profile of your account's REALIZED trading result.    |
//| Builds the cumulative closed-trade P/L curve (deposits and       |
//| withdrawals excluded on purpose), then reports: maximum          |
//| drawdown in money (and percent, if a start balance is given),    |
//| its dates, the longest underwater period, the current drawdown   |
//| and its age, and a table of the deepest N drawdown episodes.     |
//| Read-only: opens no trades, needs no algo-trading permission.    |
//+------------------------------------------------------------------+
#property copyright "Free to use and modify"
#property version   "1.10"
#property script_show_inputs

input double InpStartBalance = 0.0;   // starting balance (0 = money-only stats)
input int    InpTopN         = 5;     // deepest episodes to list
input bool   InpExportCSV    = false; // write DrawdownEpisodes.csv

// episode storage
double eDepth[]; long ePeakT[], eTroughT[], eEndT[];

//+------------------------------------------------------------------+
void AddEpisode(const double depth, const long pt, const long tt, const long et)
  {
   int n = ArraySize(eDepth);
   ArrayResize(eDepth, n+1); eDepth[n] = depth;
   ArrayResize(ePeakT, n+1); ePeakT[n] = pt;
   ArrayResize(eTroughT, n+1); eTroughT[n] = tt;
   ArrayResize(eEndT, n+1);  eEndT[n]  = et;   // 0 = not recovered yet
  }
//+------------------------------------------------------------------+
string D(const long t) { return t > 0 ? TimeToString((datetime)t, TIME_DATE) : "-"; }
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!HistorySelect(0, TimeCurrent()))
     { Print("HistorySelect failed"); return; }

   int total = HistoryDealsTotal();
   double cum = 0.0, peak = 0.0;
   long   peakT = 0, troughT = 0;
   double curDepth = 0.0;
   bool   inDD = false;
   double maxDepth = 0.0; long mPeakT = 0, mTroughT = 0, mEndT = 0;
   long   firstT = 0, lastT = 0;
   int    trades = 0;              // closed ROUND TURNS, not deals
   long   posSeen[];               // exit-side position ids already counted
   long   longestUW = 0;

   for(int i = 0; i < total; i++)   // deals arrive in chronological order
     {
      ulong tk = HistoryDealGetTicket(i);
      if(tk == 0) continue;
      long dtype = HistoryDealGetInteger(tk, DEAL_TYPE);
      if(dtype != DEAL_TYPE_BUY && dtype != DEAL_TYPE_SELL) continue;
      //--- EVERY market deal moves the account, entries included. Most
      //--- brokers charge half of the round-turn commission on the entry
      //--- deal, where DEAL_PROFIT is zero. Skipping those deals builds a
      //--- curve that never paid full costs - and a drawdown tool that
      //--- understates the very number it exists to measure.
      long entry = HistoryDealGetInteger(tk, DEAL_ENTRY);
      double pr = HistoryDealGetDouble(tk, DEAL_PROFIT)
                + HistoryDealGetDouble(tk, DEAL_SWAP)
                + HistoryDealGetDouble(tk, DEAL_COMMISSION);
      bool isExit = (entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_INOUT
                     || entry == DEAL_ENTRY_OUT_BY);
      long t = HistoryDealGetInteger(tk, DEAL_TIME);
      if(firstT == 0) { firstT = t; peakT = t; }
      lastT = t;
      //--- one POSITION is one round turn: a partial close fires several
      //--- exit deals but must not be counted several times.
      if(isExit)
        {
         long pid = HistoryDealGetInteger(tk, DEAL_POSITION_ID);
         if(pid > 0)
           {
            bool seen = false;
            for(int q = ArraySize(posSeen) - 1; q >= 0; q--)
               if(posSeen[q] == pid) { seen = true; break; }
            if(!seen)
              {
               int ns = ArraySize(posSeen);
               ArrayResize(posSeen, ns + 1);
               posSeen[ns] = pid;
               trades++;
              }
           }
         else
            trades++;             // very old history without a position id
        }
      cum += pr;
      if(cum >= peak)
        {
         if(inDD)
           {
            AddEpisode(curDepth, peakT, troughT, t);
            long uw = t - peakT; if(uw > longestUW) longestUW = uw;
            if(curDepth > maxDepth) { maxDepth = curDepth; mPeakT = peakT; mTroughT = troughT; mEndT = t; }
            inDD = false; curDepth = 0.0;
           }
         peak = cum; peakT = t;
        }
      else
        {
         double d = peak - cum;
         if(!inDD) { inDD = true; curDepth = d; troughT = t; }
         else if(d > curDepth) { curDepth = d; troughT = t; }
        }
     }
   if(trades == 0)
     { Print("No closed trades found. Load 'All history' in the History tab and rerun."); return; }
   if(inDD)  // still-open episode
     {
      AddEpisode(curDepth, peakT, troughT, 0);
      long uw = lastT - peakT; if(uw > longestUW) longestUW = uw;
      if(curDepth > maxDepth) { maxDepth = curDepth; mPeakT = peakT; mTroughT = troughT; mEndT = 0; }
     }

   string cur = AccountInfoString(ACCOUNT_CURRENCY);
   Print("=== Drawdown Meter =====================================");
   PrintFormat("Window: %s .. %s | closed round turns: %d | net realized P/L: %.2f %s",
               D(firstT), D(lastT), trades, cum, cur);
   if(InpStartBalance > 0)
     {
      double peakEq = InpStartBalance + peak;
      PrintFormat("Max drawdown: %.2f %s (%.2f%% of the equity peak %.2f)",
                  maxDepth, cur, peakEq > 0 ? 100.0*maxDepth/peakEq : 0.0, peakEq);
     }
   else
      PrintFormat("Max drawdown: %.2f %s (set InpStartBalance for percent figures)", maxDepth, cur);
   PrintFormat("  peak %s -> trough %s -> recovered %s", D(mPeakT), D(mTroughT), mEndT > 0 ? D(mEndT) : "NOT YET");
   PrintFormat("Longest underwater period: %.0f days", (double)longestUW/86400.0);
   if(inDD)
      PrintFormat("CURRENT status: %.2f %s below the last peak, underwater for %.0f days",
                  curDepth, cur, (double)(lastT - peakT)/86400.0);
   else
      Print("CURRENT status: at a new equity peak (no open drawdown)");

   //--- deepest N episodes
   int nE = ArraySize(eDepth);
   int topN = InpTopN < nE ? InpTopN : nE;
   Print("--- deepest episodes -----------------------------------");
   Print("depth      peak        trough      recovered   length(d)");
   int used[]; ArrayResize(used, nE); ArrayInitialize(used, 0);
   int h = INVALID_HANDLE;
   if(InpExportCSV)
     {
      h = FileOpen("DrawdownEpisodes.csv", FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
      if(h != INVALID_HANDLE) FileWrite(h, "depth;peakDate;troughDate;recoveredDate;lengthDays");
     }
   for(int r = 0; r < topN; r++)
     {
      int bi = -1; double bd = -1.0;
      for(int i = 0; i < nE; i++)
         if(used[i] == 0 && eDepth[i] > bd) { bd = eDepth[i]; bi = i; }
      if(bi < 0) break;
      used[bi] = 1;
      long endRef = eEndT[bi] > 0 ? eEndT[bi] : lastT;
      double lenD = (double)(endRef - ePeakT[bi])/86400.0;
      PrintFormat("%9.2f  %s  %s  %-10s  %6.0f",
                  eDepth[bi], D(ePeakT[bi]), D(eTroughT[bi]),
                  eEndT[bi] > 0 ? D(eEndT[bi]) : "OPEN", lenD);
      if(h != INVALID_HANDLE)
         FileWrite(h, StringFormat("%.2f;%s;%s;%s;%.0f", eDepth[bi], D(ePeakT[bi]), D(eTroughT[bi]),
                    eEndT[bi] > 0 ? D(eEndT[bi]) : "OPEN", lenD));
     }
   if(h != INVALID_HANDLE) { FileClose(h); Print("Exported MQL5\\Files\\DrawdownEpisodes.csv"); }
   Print("Note: entry commissions are included, so the curve carries full");
   Print("cost; a partial close counts as one round turn, not several.");
   Print("Note: deposits/withdrawals are excluded - this is the drawdown of");
   Print("your TRADING, not of your balance line. Percent figures use the");
   Print("realized-P/L curve; intraday floating excursions are not visible.");
   Print("=== done ===============================================");
  }
//+------------------------------------------------------------------+
