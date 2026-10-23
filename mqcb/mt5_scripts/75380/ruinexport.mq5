//+------------------------------------------------------------------+
//|                                                   RuinExport.mq5 |
//|                             History-to-CSV helper for the Hidden |
//|                           Risk-of-Ruin Auditor (RuinAuditor.mq5) |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Community contribution, MQL5.com"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Reconstructs closed POSITIONS (not raw deals) from this"
#property description "account's trade history and writes them to a CSV file in"
#property description "the exact format RuinAuditor.mq5 expects. Run this first,"
#property description "then point RuinAuditor.mq5 at the file it writes."
#property script_show_inputs

//--- input parameters -------------------------------------------------
input string   InpOutputFileName = "RuinAuditorSample.csv"; // CSV file written to MQL5\Files, ready for RuinAuditor.mq5
input datetime InpFromDate       = D'2000.01.01';           // export closed positions opened on/after this date
input datetime InpToDate         = D'2038.01.01';           // export closed positions opened on/before this date

//--- one position under reconstruction from its deals -----------------
//--- MetaTrader 5 history is deal-level: every partial fill of an entry
//--- or an exit is its own deal, and all deals of one position share the
//--- same DEAL_POSITION_ID. This struct accumulates those deals into a
//--- single row; close_volume is bookkeeping only, used to detect that a
//--- position is fully (not just partially) closed before it is exported.
struct ExportPosition
  {
   long              position_id;                           // MetaTrader's POSITION_IDENTIFIER, shared by every deal of one position
   datetime          open_time;                             // time of the first entry deal
   datetime          close_time;                            // time of the last exit deal (0 while the position is still open)
   string            symbol;                                // traded symbol
   bool              is_buy;                                // true = long, false = short (direction of the opening deal)
   double            volume;                                // volume-weighted running total of entry fills
   double            close_volume;                          // running total of exit fills, used only to confirm full closure
   double            open_price;                            // volume-weighted average entry price
   double            close_price;                           // volume-weighted average exit price
   double            profit;                                // sum of profit + swap + commission across every deal of the position
  };

//+------------------------------------------------------------------+
//| Find the row for this position id, creating a zero-initialized    |
//| one on first sight.                                                |
//+------------------------------------------------------------------+
int FindOrCreateRow(ExportPosition &rows[], const long pos_id, const string symbol)
  {
   int n = ArraySize(rows);
   for(int i=0; i<n; i++)
      if(rows[i].position_id==pos_id)
         return(i);

   ArrayResize(rows, n+1);
   rows[n].position_id  = pos_id;
   rows[n].symbol       = symbol;
   rows[n].open_time    = 0;
   rows[n].close_time   = 0;
   rows[n].is_buy        = true;
   rows[n].volume        = 0.0;
   rows[n].close_volume  = 0.0;
   rows[n].open_price    = 0.0;
   rows[n].close_price   = 0.0;
   rows[n].profit        = 0.0;
   return(n);
  }

//+------------------------------------------------------------------+
//| Fold one entry (DEAL_ENTRY_IN) deal into position rows[idx]:       |
//| running volume-weighted average entry price, direction, and        |
//| earliest open time across every entry fill. Takes the array plus a |
//| row index, rather than a reference to one element, so the update   |
//| is written straight back into the caller's array.                  |
//+------------------------------------------------------------------+
void ApplyEntryDeal(ExportPosition &rows[], const int idx, const double price, const double vol,
                     const bool is_buy, const datetime dtime)
  {
   double prev_vol = rows[idx].volume;
   double new_vol  = prev_vol+vol;
   rows[idx].open_price = (new_vol>0.0) ? (prev_vol*rows[idx].open_price+vol*price)/new_vol : price;
   rows[idx].volume     = new_vol;
   rows[idx].is_buy     = is_buy;
   if(rows[idx].open_time==0 || dtime<rows[idx].open_time)
      rows[idx].open_time = dtime;
  }

//+------------------------------------------------------------------+
//| Fold one exit (DEAL_ENTRY_OUT / DEAL_ENTRY_OUT_BY) deal into       |
//| position rows[idx]: running volume-weighted average exit price,    |
//| and the latest close time across every exit fill.                  |
//+------------------------------------------------------------------+
void ApplyExitDeal(ExportPosition &rows[], const int idx, const double price, const double vol, const datetime dtime)
  {
   double prev_cvol = rows[idx].close_volume;
   double new_cvol  = prev_cvol+vol;
   rows[idx].close_price  = (new_cvol>0.0) ? (prev_cvol*rows[idx].close_price+vol*price)/new_cvol : price;
   rows[idx].close_volume = new_cvol;
   if(dtime>rows[idx].close_time)
      rows[idx].close_time = dtime;
  }

//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!HistorySelect(InpFromDate, InpToDate))
     {
      PrintFormat("RuinExport: HistorySelect failed, error %d", GetLastError());
      return;
     }

   int total_deals = HistoryDealsTotal();
   ExportPosition rows[];

   //--- fold every real trade fill into its position row; balance, credit
   //--- and correction entries are not trade fills and are skipped, and
   //--- only DEAL_ENTRY_IN / DEAL_ENTRY_OUT / DEAL_ENTRY_OUT_BY are
   //--- meaningful for reconstructing a position's entry and exit sides
   for(int i=0; i<total_deals; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket==0) continue;

      long dtype = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(dtype!=DEAL_TYPE_BUY && dtype!=DEAL_TYPE_SELL)
         continue; // skip balance/credit/correction/interest entries

      long     entry  = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      long     pos_id = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      string   symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
      double   price  = HistoryDealGetDouble(ticket, DEAL_PRICE);
      double   vol    = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double   profit = HistoryDealGetDouble(ticket, DEAL_PROFIT)
                       +HistoryDealGetDouble(ticket, DEAL_SWAP)
                       +HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      datetime dtime  = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);

      int row = FindOrCreateRow(rows, pos_id, symbol);
      rows[row].profit += profit;

      if(entry==DEAL_ENTRY_IN)
         ApplyEntryDeal(rows, row, price, vol, (dtype==DEAL_TYPE_BUY), dtime);
      else if(entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_OUT_BY)
         ApplyExitDeal(rows, row, price, vol, dtime);
      // other entry types (rare partial-netting adjustments) are left out of
      // the entry/exit reconstruction on purpose to keep this exporter simple
     }

   int handle = FileOpen(InpOutputFileName, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("RuinExport: could not create %s, error %d", InpOutputFileName, GetLastError());
      return;
     }
   FileWrite(handle, "OpenTime,CloseTime,Symbol,Type,Volume,OpenPrice,ClosePrice,Profit");

   int n = ArraySize(rows);
   int written = 0;
   int skipped_open = 0;
   for(int i=0; i<n; i++)
     {
      //--- export only FULLY closed positions: close_time must be set, and
      //--- the closed volume must match the opened volume (a partially
      //--- closed position is still open and would contaminate the audit)
      bool fully_closed = (rows[i].close_time>0) && (MathAbs(rows[i].volume-rows[i].close_volume)<0.0000001);
      if(!fully_closed)
        {
         skipped_open++;
         continue;
        }

      int digits = (int)SymbolInfoInteger(rows[i].symbol, SYMBOL_DIGITS);
      if(digits<=0) digits = 5;

      FileWrite(handle,
                TimeToString(rows[i].open_time,  TIME_DATE|TIME_SECONDS),
                TimeToString(rows[i].close_time, TIME_DATE|TIME_SECONDS),
                rows[i].symbol,
                rows[i].is_buy ? "buy" : "sell",
                DoubleToString(rows[i].volume, 2),
                DoubleToString(rows[i].open_price, digits),
                DoubleToString(rows[i].close_price, digits),
                DoubleToString(rows[i].profit, 2));
      written++;
     }
   FileClose(handle);

   PrintFormat("RuinExport: wrote %d closed position(s) to %s (MQL5\\Files); %d still-open/partial position(s) were excluded.",
               written, InpOutputFileName, skipped_open);
   PrintFormat("RuinExport: run RuinAuditor.mq5 with InpCsvFileName=\"%s\" to analyze this file.", InpOutputFileName);
  }
//+------------------------------------------------------------------+
