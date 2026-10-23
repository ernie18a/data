//+------------------------------------------------------------------+
//|                                               ScaleOutExport.mq5 |
//|                                          Copyright 2026, Thiabot |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Thiabot"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs

//--- input parameters
input string   InpOutputFile = "ScaleOutData.csv"; // Output CSV file name (written to MQL5\Files)
input datetime InpFrom       = 0;                  // Export deals from (0 = account history start)
input datetime InpTo         = 0;                  // Export deals up to (0 = now)

//--- per-position entry aggregate built in the first pass over the deal history
struct EntryInfo
  {
   long              position_id;                  // MT5 position identifier
   string            symbol;                       // Traded symbol
   string            direction;                    // "buy" or "sell"
   datetime          entry_time;                   // Time of the earliest IN deal seen for this position
   double            entry_price;                  // Price of the earliest IN deal seen for this position
   int               entry_count;                  // Number of IN deals seen for this position
   double            total_volume;                 // Sum of the volumes of every IN deal for this position
  };

//+------------------------------------------------------------------+
//| Find the index of a position id in the entries array, or -1      |
//+------------------------------------------------------------------+
int FindEntry(const EntryInfo &entries[], long position_id)
  {
   int total=ArraySize(entries);
   for(int k=0; k<total; k++)
      if(entries[k].position_id==position_id)
         return(k);
   return(-1);
  }

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   datetime to=(InpTo==0)   ? TimeCurrent()   : InpTo;
   datetime from=(InpFrom==0) ? D'2000.01.01' : InpFrom;
   if(!HistorySelect(from, to))
     {
      PrintFormat("ERROR: HistorySelect failed, error code %d.", GetLastError());
      return;
     }

   int total_deals=HistoryDealsTotal();
   EntryInfo entries[];
   int entry_total=0;

//--- first pass: aggregate every IN deal per position (earliest fill time and price, deal count, opened volume).
//--- deal-level granularity: a position opened in several fills is several IN deals sharing one position id
   for(int i=0; i<total_deals; i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;
      long type=HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
         continue;                   // excludes balance, credit, correction, bonus, interest
      long entry=HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_IN)
         continue;

      long     pid   = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      double   vol    = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double   price  = HistoryDealGetDouble(ticket, DEAL_PRICE);
      datetime tm     = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      string   sym    = HistoryDealGetString(ticket, DEAL_SYMBOL);
      string   dir    = (type==DEAL_TYPE_BUY) ? "buy" : "sell";

      int idx=FindEntry(entries, pid);
      if(idx==-1)
        {
         entry_total++;
         ArrayResize(entries, entry_total);
         idx=entry_total-1;
         entries[idx].position_id  = pid;
         entries[idx].symbol       = sym;
         entries[idx].direction    = dir;
         entries[idx].entry_time   = tm;
         entries[idx].entry_price  = price;
         entries[idx].entry_count  = 0;
         entries[idx].total_volume = 0.0;
        }
      entries[idx].entry_count++;
      entries[idx].total_volume+=vol;
      if(tm<entries[idx].entry_time) // keep the EARLIEST in-deal as the reported entry
        {
         entries[idx].entry_time  = tm;
         entries[idx].entry_price = price;
        }
     }

   if(entry_total==0)
     {
      Print("No BUY/SELL entry deals found in the requested range - nothing to export.");
      return;
     }

   int handle=FileOpen(InpOutputFile, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("ERROR: cannot create %s, error code %d.", InpOutputFile, GetLastError());
      return;
     }
   FileWriteString(handle, "PositionID,Symbol,Direction,EntryTime,EntryPrice,EntryCount,TotalVolume,ExitTime,ExitPrice,ExitVolume,ExitProfit,ExitCommission,ExitSwap\r\n");

   int rows_written=0;
//--- second pass: one row per closing deal (OUT or OUT_BY), referencing its position's cached entry aggregate.
//--- a position closed through several partial exits produces several rows sharing the same PositionID
   for(int i=0; i<total_deals; i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0)
         continue;
      long type=HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type!=DEAL_TYPE_BUY && type!=DEAL_TYPE_SELL)
         continue;
      long entry=HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY)
         continue;                   // this pass writes only closing legs

      long pid=HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      int idx=FindEntry(entries, pid);
      if(idx==-1)
         continue;                   // closing deal for a position opened before InpFrom

      double   xvol    = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double   xprice  = HistoryDealGetDouble(ticket, DEAL_PRICE);
      double   xprofit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
      double   xcomm   = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      double   xswap   = HistoryDealGetDouble(ticket, DEAL_SWAP);
      datetime xtime   = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);

      string line=StringFormat("%I64d,%s,%s,%s,%.5f,%d,%.2f,%s,%.5f,%.2f,%.2f,%.2f,%.2f\r\n",
                                entries[idx].position_id, entries[idx].symbol, entries[idx].direction,
                                TimeToString(entries[idx].entry_time, TIME_DATE|TIME_SECONDS), entries[idx].entry_price,
                                entries[idx].entry_count, entries[idx].total_volume,
                                TimeToString(xtime, TIME_DATE|TIME_SECONDS), xprice, xvol, xprofit, xcomm, xswap);
      FileWriteString(handle, line);
      rows_written++;
     }
   FileClose(handle);
   PrintFormat("Wrote %d closing-deal row(s) for %d position(s) to %s.", rows_written, entry_total, InpOutputFile);
   Print("Granularity note: each row is one closing deal, not one position - a position closed through several partial exits produces several rows that share the same PositionID.");
  }
//+------------------------------------------------------------------+
