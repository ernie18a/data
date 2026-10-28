//+------------------------------------------------------------------+
//| MagicNumberInventory.mq5                                v1.10    |
//| "Who is trading on my account?"                                  |
//| Read-only audit script: groups the account's closed-trade        |
//| history by magic number and prints, per magic: trade count,      |
//| net P/L (incl. swap+commission), win rate, profit factor,        |
//| average win/loss, first and last trade dates, symbols traded,    |
//| plus currently open positions and pending orders.                |
//| Magic 0 = manual trades or EAs that do not set a magic number.   |
//| v1.10: one POSITION is one trade. Deals are aggregated by        |
//| DEAL_POSITION_ID, so a partial close is a single round turn and  |
//| entry commission is included in its net P/L.                     |
//+------------------------------------------------------------------+
#property copyright "Free to use and modify"
#property version   "1.10"
#property script_show_inputs

input bool InpExportCSV = true;   // write MagicInventory.csv to MQL5\Files

//--- one aggregated position = one round turn -----------------------
long   p_id[];          // DEAL_POSITION_ID
long   p_magic[];
double p_net[];         // profit+swap+commission over ALL deals of the position
double p_volIn[], p_volOut[];
long   p_first[], p_last[];
string p_sym[];
bool   p_hasOut[];

long   g_magic[];
int    g_cnt[];
double g_net[], g_grossP[], g_grossL[];
int    g_win[];
long   g_first[], g_last[];
string g_syms[];
int    g_openPos[];  double g_openVol[];
int    g_pend[];

//+------------------------------------------------------------------+
//| Find the collector slot of a position id, appending if new.       |
//+------------------------------------------------------------------+
int FindOrAddPos(const long pid)
  {
   int n = ArraySize(p_id);
   for(int i = 0; i < n; i++) if(p_id[i] == pid) return i;
   ArrayResize(p_id, n+1);     p_id[n] = pid;
   ArrayResize(p_magic, n+1);  p_magic[n] = 0;
   ArrayResize(p_net, n+1);    p_net[n] = 0.0;
   ArrayResize(p_volIn, n+1);  p_volIn[n] = 0.0;
   ArrayResize(p_volOut, n+1); p_volOut[n] = 0.0;
   ArrayResize(p_first, n+1);  p_first[n] = 0;
   ArrayResize(p_last, n+1);   p_last[n] = 0;
   ArrayResize(p_sym, n+1);    p_sym[n] = "";
   ArrayResize(p_hasOut, n+1); p_hasOut[n] = false;
   return n;
  }
//+------------------------------------------------------------------+
int FindOrAdd(const long mg)
  {
   int n = ArraySize(g_magic);
   for(int i = 0; i < n; i++) if(g_magic[i] == mg) return i;
   ArrayResize(g_magic, n+1);  g_magic[n] = mg;
   ArrayResize(g_cnt, n+1);    g_cnt[n] = 0;
   ArrayResize(g_net, n+1);    g_net[n] = 0.0;
   ArrayResize(g_grossP, n+1); g_grossP[n] = 0.0;
   ArrayResize(g_grossL, n+1); g_grossL[n] = 0.0;
   ArrayResize(g_win, n+1);    g_win[n] = 0;
   ArrayResize(g_first, n+1);  g_first[n] = 0;
   ArrayResize(g_last, n+1);   g_last[n] = 0;
   ArrayResize(g_syms, n+1);   g_syms[n] = "";
   ArrayResize(g_openPos, n+1);g_openPos[n] = 0;
   ArrayResize(g_openVol, n+1);g_openVol[n] = 0.0;
   ArrayResize(g_pend, n+1);   g_pend[n] = 0;
   return n;
  }
//+------------------------------------------------------------------+
void AddSymbol(const int idx, const string sym)
  {
   if(StringFind(g_syms[idx], sym) >= 0) return;
   if(g_syms[idx] == "") { g_syms[idx] = sym; return; }
   int commas = 0;
   for(int i = 0; i < StringLen(g_syms[idx]); i++)
      if(StringGetCharacter(g_syms[idx], i) == ',') commas++;
   if(commas < 2) g_syms[idx] += "," + sym;
   else if(StringFind(g_syms[idx], "+") < 0) g_syms[idx] += ",+";
  }
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!HistorySelect(0, TimeCurrent()))
     { Print("HistorySelect failed"); return; }

   //--- pass 1: aggregate EVERY market deal into its position ---------
   //--- Entry deals are kept on purpose: on most commission brokers half
   //--- of the round-turn commission sits on the entry deal with
   //--- DEAL_PROFIT = 0. Skipping them understates cost and overstates
   //--- net P/L for every magic in the table.
   int total = HistoryDealsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong tk = HistoryDealGetTicket(i);
      if(tk == 0) continue;
      long dtype = HistoryDealGetInteger(tk, DEAL_TYPE);
      if(dtype != DEAL_TYPE_BUY && dtype != DEAL_TYPE_SELL) continue;
      long pid = HistoryDealGetInteger(tk, DEAL_POSITION_ID);
      if(pid <= 0) continue;

      int p = FindOrAddPos(pid);
      p_net[p] += HistoryDealGetDouble(tk, DEAL_PROFIT)
                + HistoryDealGetDouble(tk, DEAL_SWAP)
                + HistoryDealGetDouble(tk, DEAL_COMMISSION);

      long   entry = HistoryDealGetInteger(tk, DEAL_ENTRY);
      double vol   = HistoryDealGetDouble(tk, DEAL_VOLUME);
      long   t     = HistoryDealGetInteger(tk, DEAL_TIME);
      if(entry == DEAL_ENTRY_IN)
        {
         p_volIn[p]  += vol;
         p_magic[p]   = HistoryDealGetInteger(tk, DEAL_MAGIC);
         if(p_first[p] == 0 || t < p_first[p]) p_first[p] = t;
        }
      else
        {
         p_volOut[p] += vol;
         p_hasOut[p]  = true;
         if(t > p_last[p]) p_last[p] = t;
        }
      if(p_sym[p] == "") p_sym[p] = HistoryDealGetString(tk, DEAL_SYMBOL);
     }

   //--- pass 2: one FULLY CLOSED position = one trade -----------------
   //--- A partial close produces two or more exit deals. Counting deals
   //--- would inflate the trade count and split a single round turn into
   //--- a "win" and a "loss", corrupting win rate and profit factor.
   int nP = ArraySize(p_id);
   for(int p = 0; p < nP; p++)
     {
      if(!p_hasOut[p]) continue;                                   // still open
      if(MathAbs(p_volIn[p] - p_volOut[p]) > 0.0000001) continue;  // open remainder
      int idx = FindOrAdd(p_magic[p]);
      double pr = p_net[p];
      g_cnt[idx]++;
      g_net[idx] += pr;
      if(pr > 0) { g_win[idx]++; g_grossP[idx] += pr; }
      else         g_grossL[idx] += -pr;
      long tf = (p_first[p] != 0 ? p_first[p] : p_last[p]);
      if(g_first[idx] == 0 || tf < g_first[idx]) g_first[idx] = tf;
      if(p_last[p] > g_last[idx]) g_last[idx] = p_last[p];
      AddSymbol(idx, p_sym[p]);
     }

   //--- open positions and pendings per magic
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong pt = PositionGetTicket(i);
      if(pt == 0) continue;
      int idx = FindOrAdd((long)PositionGetInteger(POSITION_MAGIC));
      g_openPos[idx]++;
      g_openVol[idx] += PositionGetDouble(POSITION_VOLUME);
     }
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ulong ot = OrderGetTicket(i);
      if(ot == 0) continue;
      int idx = FindOrAdd((long)OrderGetInteger(ORDER_MAGIC));
      g_pend[idx]++;
     }

   int nM = ArraySize(g_magic);
   if(nM == 0) { Print("No trade history found. Load 'All history' in the History tab and rerun."); return; }

   //--- sort by net P/L descending (selection sort, small n)
   int ord[]; ArrayResize(ord, nM);
   for(int i = 0; i < nM; i++) ord[i] = i;
   for(int a = 0; a < nM-1; a++)
     {
      int bmax = a;
      for(int b = a+1; b < nM; b++) if(g_net[ord[b]] > g_net[ord[bmax]]) bmax = b;
      int tmp = ord[a]; ord[a] = ord[bmax]; ord[bmax] = tmp;
     }

   Print("=== Magic Number Inventory =============================");
   Print("magic        trades  net P/L    win%   PF    avgWin  avgLoss  open(vol)  pend  first..last        symbols");
   double totNet = 0.0; int totCnt = 0;
   int h = INVALID_HANDLE;
   if(InpExportCSV)
     {
      h = FileOpen("MagicInventory.csv", FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
      if(h != INVALID_HANDLE)
         FileWrite(h, "magic;trades;netPL;winRate;profitFactor;avgWin;avgLoss;openPositions;openVolume;pendings;firstTrade;lastTrade;symbols");
     }
   for(int a = 0; a < nM; a++)
     {
      int i = ord[a];
      double wr  = g_cnt[i] > 0 ? 100.0*g_win[i]/g_cnt[i] : 0.0;
      double pf  = g_grossL[i] > 0 ? g_grossP[i]/g_grossL[i] : 0.0;
      double aw  = g_win[i] > 0 ? g_grossP[i]/g_win[i] : 0.0;
      int    nl  = g_cnt[i] - g_win[i];
      double al  = nl > 0 ? g_grossL[i]/nl : 0.0;
      string rng = (g_cnt[i] > 0)
                 ? TimeToString((datetime)g_first[i], TIME_DATE) + ".." + TimeToString((datetime)g_last[i], TIME_DATE)
                 : "(no closed trades)";
      PrintFormat("%-12I64d %-6d %9.2f  %5.1f  %4.2f  %7.2f  %7.2f  %d(%.2f)  %-4d  %s  %s",
                  g_magic[i], g_cnt[i], g_net[i], wr, pf, aw, al,
                  g_openPos[i], g_openVol[i], g_pend[i], rng, g_syms[i]);
      totNet += g_net[i]; totCnt += g_cnt[i];
      if(h != INVALID_HANDLE)
         FileWrite(h, StringFormat("%I64d;%d;%.2f;%.1f;%.2f;%.2f;%.2f;%d;%.2f;%d;%s;%s;%s",
                    g_magic[i], g_cnt[i], g_net[i], wr, pf, aw, al,
                    g_openPos[i], g_openVol[i], g_pend[i],
                    TimeToString((datetime)g_first[i], TIME_DATE),
                    TimeToString((datetime)g_last[i], TIME_DATE), g_syms[i]));
     }
   Print("--------------------------------------------------------");
   PrintFormat("TOTAL: %d magics | %d closed trades | net %.2f %s",
               nM, totCnt, totNet, AccountInfoString(ACCOUNT_CURRENCY));
   Print("Note: magic 0 = manual trades or EAs without a magic number.");
   Print("Note: one position = one trade; partial closes are not double-counted.");
   if(h != INVALID_HANDLE) { FileClose(h); Print("Exported MQL5\\Files\\MagicInventory.csv"); }
   Print("=== done ===============================================");
  }
//+------------------------------------------------------------------+
