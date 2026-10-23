//+------------------------------------------------------------------+
//|                                               MagicScorecard.mq5 |
//|      Closed-trade statistics of the account, per magic number     |
//|                                       Muhammad Muqeem Korejo      |
//+------------------------------------------------------------------+
//
// Every Expert Advisor marks its trades with a magic number, so grouping
// the account history by magic number gives one score line per EA
// (magic 0 = manual trades). A trade is a closed position: all of its
// deals (entry and exit commission, swap, profit, fee) are added up.
// Positions that are still open, fully or partly, are left out.
// The script only reads the history and writes a CSV file.
//
#property copyright   "Muhammad Muqeem Korejo"
#property link        "https://www.mql5.com/en/users/korejo123"
#property version     "1.00"
#property description "Groups the closed trades of the account by magic number (one line per EA)"
#property description "and shows trades, win rate, profit factor, net profit, average trade and"
#property description "maximum drawdown. Writes the table to MQL5\\Files. Read-only: it never trades."
#property script_show_inputs

#include <Generic\HashMap.mqh>

input datetime InpFrom        = D'2000.01.01 00:00';  // From
input datetime InpTo          = 0;                     // To (0 = now)
input string   InpSymbol      = "";                    // Only this symbol (empty = all)
input bool     InpWriteCsv    = true;                  // Write CSV file
input string   InpFileName    = "MagicScorecard.csv";  // CSV file name (MQL5\Files)
input bool     InpShowOnChart = true;                  // Show the table on the chart

//+------------------------------------------------------------------+
//| Statistics of one magic number                                   |
//+------------------------------------------------------------------+
struct MagicRow
  {
   long              magic;
   int               trades;
   int               wins;
   int               losses;
   double            grossProfit;
   double            grossLoss;
   double            net;
   double            best;
   double            worst;
   double            cum;
   double            peak;
   double            maxDD;
   string            symbols;
  };

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   datetime to = (InpTo > 0) ? InpTo : TimeCurrent() + 86400;
   if(!HistorySelect(InpFrom, to))
     {
      Print("Magic Scorecard: history could not be selected, error ", GetLastError());
      return;
     }

   //--- 1. every position seen in the deals
   CHashMap<long, int> posIndex;
   long     posId[];
   long     posMagic[];
   bool     posHasIn[];
   bool     posClosed[];
   datetime posClose[];
   double   posPnl[];
   string   posSymbol[];
   int      count = 0;

   int dealsTotal = HistoryDealsTotal();
   for(int i = 0; i < dealsTotal; i++)
     {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0)
         continue;
      long type = HistoryDealGetInteger(deal, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
         continue;
      string symbol = HistoryDealGetString(deal, DEAL_SYMBOL);
      if(InpSymbol != "" && symbol != InpSymbol)
         continue;

      long pid = HistoryDealGetInteger(deal, DEAL_POSITION_ID);
      int  idx = -1;
      if(!posIndex.TryGetValue(pid, idx))
        {
         idx = count;
         count++;
         ArrayResize(posId, count, 1000);
         ArrayResize(posMagic, count, 1000);
         ArrayResize(posHasIn, count, 1000);
         ArrayResize(posClosed, count, 1000);
         ArrayResize(posClose, count, 1000);
         ArrayResize(posPnl, count, 1000);
         ArrayResize(posSymbol, count, 1000);
         posId[idx]     = pid;
         posMagic[idx]  = HistoryDealGetInteger(deal, DEAL_MAGIC);
         posHasIn[idx]  = false;
         posClosed[idx] = false;
         posClose[idx]  = 0;
         posPnl[idx]    = 0.0;
         posSymbol[idx] = symbol;
         posIndex.Add(pid, idx);
        }

      long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
      // the opening deal decides which EA owns the position
      if(entry == DEAL_ENTRY_IN && !posHasIn[idx])
        {
         posMagic[idx] = HistoryDealGetInteger(deal, DEAL_MAGIC);
         posHasIn[idx] = true;
        }
      posPnl[idx] += HistoryDealGetDouble(deal, DEAL_PROFIT) + HistoryDealGetDouble(deal, DEAL_SWAP)
                     + HistoryDealGetDouble(deal, DEAL_COMMISSION) + HistoryDealGetDouble(deal, DEAL_FEE);
      if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY || entry == DEAL_ENTRY_INOUT)
        {
         posClosed[idx] = true;
         posClose[idx]  = (datetime)HistoryDealGetInteger(deal, DEAL_TIME);
        }
     }

   //--- 2. closed positions, in order of closing time
   double keys[][2];
   int    trades = 0;
   for(int i = 0; i < count; i++)
     {
      if(!posClosed[i])
         continue;
      if(PositionSelectByTicket((ulong)posId[i]))
         continue;                              // still (partly) open
      ArrayResize(keys, trades + 1, 1000);
      keys[trades][0] = (double)posClose[i];
      keys[trades][1] = (double)i;
      trades++;
     }
   if(trades == 0)
     {
      Print("Magic Scorecard: no closed trades in the selected period.");
      if(InpShowOnChart)
         Comment("Magic Scorecard: no closed trades in the selected period.");
      return;
     }
   ArraySort(keys);

   //--- 3. one row per magic number
   CHashMap<long, int> rowIndex;
   MagicRow rows[];
   int      rowCount = 0;
   for(int k = 0; k < trades; k++)
     {
      int  i     = (int)keys[k][1];
      long magic = posMagic[i];
      int  r     = -1;
      if(!rowIndex.TryGetValue(magic, r))
        {
         r = rowCount;
         rowCount++;
         ArrayResize(rows, rowCount);
         rows[r].magic       = magic;
         rows[r].trades      = 0;
         rows[r].wins        = 0;
         rows[r].losses      = 0;
         rows[r].grossProfit = 0.0;
         rows[r].grossLoss   = 0.0;
         rows[r].net         = 0.0;
         rows[r].best        = 0.0;
         rows[r].worst       = 0.0;
         rows[r].cum         = 0.0;
         rows[r].peak        = 0.0;
         rows[r].maxDD       = 0.0;
         rows[r].symbols     = "";
         rowIndex.Add(magic, r);
        }

      double pnl = posPnl[i];
      rows[r].trades++;
      if(pnl > 0)
        {
         rows[r].wins++;
         rows[r].grossProfit += pnl;
        }
      else
         if(pnl < 0)
           {
            rows[r].losses++;
            rows[r].grossLoss -= pnl;
           }
      rows[r].net += pnl;
      if(rows[r].trades == 1 || pnl > rows[r].best)
         rows[r].best = pnl;
      if(rows[r].trades == 1 || pnl < rows[r].worst)
         rows[r].worst = pnl;

      // drawdown of the closed-trade equity curve of this magic
      rows[r].cum += pnl;
      if(rows[r].cum > rows[r].peak)
         rows[r].peak = rows[r].cum;
      if(rows[r].peak - rows[r].cum > rows[r].maxDD)
         rows[r].maxDD = rows[r].peak - rows[r].cum;

      if(StringFind(";" + rows[r].symbols + ";", ";" + posSymbol[i] + ";") < 0)
         rows[r].symbols += (rows[r].symbols == "" ? "" : ";") + posSymbol[i];
     }

   //--- 4. best net profit first
   int order[];
   ArrayResize(order, rowCount);
   for(int i = 0; i < rowCount; i++)
      order[i] = i;
   for(int i = 0; i < rowCount - 1; i++)
      for(int j = i + 1; j < rowCount; j++)
         if(rows[order[j]].net > rows[order[i]].net)
           {
            int tmp  = order[i];
            order[i] = order[j];
            order[j] = tmp;
           }

   //--- 5. output
   string cur   = AccountInfoString(ACCOUNT_CURRENCY);
   string range = TimeToString(InpFrom, TIME_DATE) + " - " + TimeToString(InpTo > 0 ? InpTo : TimeCurrent(), TIME_DATE);
   string head  = StringFormat("Magic Scorecard  %s  (%d trades, %s)", range, trades, cur);
   string table = head + "\n";
   Print(head);
   for(int n = 0; n < rowCount; n++)
     {
      int    r    = order[n];
      string line = StringFormat("%-14s trades %d | win %s%% | PF %s | net %s | avg %s | max DD %s | %s",
                                 MagicText(rows[r].magic), rows[r].trades,
                                 DoubleToString(100.0 * rows[r].wins / rows[r].trades, 1),
                                 ProfitFactorText(rows[r].grossProfit, rows[r].grossLoss),
                                 DoubleToString(rows[r].net, 2),
                                 DoubleToString(rows[r].net / rows[r].trades, 2),
                                 DoubleToString(rows[r].maxDD, 2),
                                 rows[r].symbols);
      Print(line);
      table += line + "\n";
     }

   if(InpWriteCsv)
      WriteCsv(rows, order, rowCount);
   if(InpShowOnChart)
      Comment(table);
   else
      Comment("");
  }

//+------------------------------------------------------------------+
//| Write the table to a CSV file in MQL5\Files                      |
//+------------------------------------------------------------------+
void WriteCsv(const MagicRow &rows[], const int &order[], const int rowCount)
  {
   ResetLastError();
   int handle = FileOpen(InpFileName, FILE_WRITE | FILE_CSV | FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
     {
      Print("Magic Scorecard: could not create ", InpFileName, ", error ", GetLastError());
      return;
     }
   FileWrite(handle, "Magic", "Trades", "Wins", "Losses", "WinRatePct", "GrossProfit", "GrossLoss",
             "NetProfit", "ProfitFactor", "AvgTrade", "BestTrade", "WorstTrade", "MaxDrawdown", "Symbols");
   for(int n = 0; n < rowCount; n++)
     {
      int r = order[n];
      FileWrite(handle,
                IntegerToString(rows[r].magic),
                IntegerToString(rows[r].trades),
                IntegerToString(rows[r].wins),
                IntegerToString(rows[r].losses),
                DoubleToString(100.0 * rows[r].wins / rows[r].trades, 1),
                DoubleToString(rows[r].grossProfit, 2),
                DoubleToString(rows[r].grossLoss, 2),
                DoubleToString(rows[r].net, 2),
                ProfitFactorText(rows[r].grossProfit, rows[r].grossLoss),
                DoubleToString(rows[r].net / rows[r].trades, 2),
                DoubleToString(rows[r].best, 2),
                DoubleToString(rows[r].worst, 2),
                DoubleToString(rows[r].maxDD, 2),
                rows[r].symbols);
     }
   FileClose(handle);
   Print("Magic Scorecard: saved ", TerminalInfoString(TERMINAL_DATA_PATH), "\\MQL5\\Files\\", InpFileName);
  }

//+------------------------------------------------------------------+
//| Magic number as text (0 = manual)                                |
//+------------------------------------------------------------------+
string MagicText(const long magic)
  {
   if(magic == 0)
      return "0 (manual)";
   return IntegerToString(magic);
  }

//+------------------------------------------------------------------+
//| Profit factor as text                                            |
//+------------------------------------------------------------------+
string ProfitFactorText(const double grossProfit, const double grossLoss)
  {
   if(grossLoss > 0)
      return DoubleToString(grossProfit / grossLoss, 2);
   return (grossProfit > 0) ? "no losses" : "-";
  }
//+------------------------------------------------------------------+
