//+------------------------------------------------------------------+
//|                                                  DriftExport.mq5 |
//|                  Copyright 2026, Cristian David Castillo Arrieta |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Cristian David Castillo Arrieta"
#property link      "https://www.mql5.com"
#property version   "1.11"
#property description "Exports closing deals to the CSV format read by EdgeDrift.mq5."
#property script_show_inputs

//--- input parameters
input string   InpFileName = "EdgeLive.csv"; // Output CSV name
input long     InpMagic    = 0;              // Magic number of the positions (0 = all)
input string   InpSymbol   = "";             // Symbol filter (empty = all)
input datetime InpFrom     = D'2025.01.01';  // First close time to export
input bool     InpCommon   = true;           // Write to the common Files folder

//--- one closing deal read from the account history
struct ClosedDeal
  {
   datetime          time;   // close time of the deal
   string            symbol; // symbol of the deal
   double            volume; // closed volume in lots
   double            net;    // net result, including the entry cost share
  };

//+------------------------------------------------------------------+
//| Index of a position ID in the cache, -1 if it is not there       |
//+------------------------------------------------------------------+
int FindPosition(const long &ids[], const long id)
  {
//--- search from the end: exits usually follow their entries closely
   for(int i = ArraySize(ids) - 1; i >= 0; i--)
      if(ids[i] == id)
         return(i);
   return(-1);
  }
//+------------------------------------------------------------------+
//| Collect closing deals in [from, to); to = 0 means no limit       |
//+------------------------------------------------------------------+
int CollectClosingDeals(const long magic, const string symbol, const datetime from,
                        const datetime to, ClosedDeal &deals[])
  {
   ArrayResize(deals, 0);
   if(!HistorySelect(0, TimeCurrent()))
      return(-1);
   int total = HistoryDealsTotal();
//--- pass 1: magic, entry cost and entry volume of every position
   long   posIds[];
   long   posMagic[];
   double posCost[];
   double posVolume[];
   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0 || HistoryDealGetInteger(ticket, DEAL_ENTRY) != DEAL_ENTRY_IN)
         continue;
      long id = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      int k = FindPosition(posIds, id);
      if(k < 0)
        {
         k = ArraySize(posIds);
         ArrayResize(posIds, k + 1, 256);
         ArrayResize(posMagic, k + 1, 256);
         ArrayResize(posCost, k + 1, 256);
         ArrayResize(posVolume, k + 1, 256);
         posIds[k] = id;
         posMagic[k] = HistoryDealGetInteger(ticket, DEAL_MAGIC);
         posCost[k] = 0.0;
         posVolume[k] = 0.0;
        }
      //--- commission and fee are often charged on the entry deal
      posCost[k] += HistoryDealGetDouble(ticket, DEAL_COMMISSION) +
                    HistoryDealGetDouble(ticket, DEAL_FEE);
      posVolume[k] += HistoryDealGetDouble(ticket, DEAL_VOLUME);
     }
//--- pass 2: one element per closing deal
   for(int i = 0; i < total; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;
      //--- trades only: balance, credit, bonus and correction rows are excluded
      long type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
         continue;
      //--- closing deals only; a partial exit is its own row, a reversal is skipped
      long entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY)
         continue;
      datetime t = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
      string sym = HistoryDealGetString(ticket, DEAL_SYMBOL);
      if(t < from || (to > 0 && t >= to) || (symbol != "" && sym != symbol))
         continue;
      //--- filter by the magic of the position, so SL, TP and manual exits stay in
      int k = FindPosition(posIds, HistoryDealGetInteger(ticket, DEAL_POSITION_ID));
      if(magic != 0 && (k < 0 || posMagic[k] != magic))
         continue;
      double volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double net = HistoryDealGetDouble(ticket, DEAL_PROFIT) +
                   HistoryDealGetDouble(ticket, DEAL_SWAP) +
                   HistoryDealGetDouble(ticket, DEAL_COMMISSION) +
                   HistoryDealGetDouble(ticket, DEAL_FEE);
      //--- add this exit's share of the entry cost, in proportion to its volume
      if(k >= 0 && posVolume[k] > 0.0)
         net += posCost[k] * volume / posVolume[k];
      int n = ArraySize(deals);
      ArrayResize(deals, n + 1, 1024);
      deals[n].time = t;
      deals[n].symbol = sym;
      deals[n].volume = volume;
      deals[n].net = net;
     }
   return(ArraySize(deals));
  }
//+------------------------------------------------------------------+
//| Write closing deals to the CSV format read by EdgeDrift.mq5      |
//+------------------------------------------------------------------+
int ExportClosingDeals(const string fileName, const long magic = 0,
                       const string symbol = "", const datetime from = 0,
                       const bool common = true)
  {
   ClosedDeal deals[];
   int n = CollectClosingDeals(magic, symbol, from, 0, deals);
   if(n < 0)
      return(-1);
   int flags = FILE_WRITE | FILE_TXT | FILE_ANSI;
   if(common)
      flags |= FILE_COMMON;
   int handle = FileOpen(fileName, flags);
   if(handle == INVALID_HANDLE)
      return(-1);
   FileWriteString(handle, "CloseTime,Symbol,Volume,NetProfit\r\n");
   for(int i = 0; i < n; i++)
      FileWriteString(handle, TimeToString(deals[i].time, TIME_DATE | TIME_SECONDS) + "," +
                      deals[i].symbol + "," + DoubleToString(deals[i].volume, 2) + "," +
                      DoubleToString(deals[i].net, 2) + "\r\n");
   FileClose(handle);
   return(n);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int rows = ExportClosingDeals(InpFileName, InpMagic, InpSymbol, InpFrom, InpCommon);
   if(rows < 0)
     {
      PrintFormat("Export failed (error %d)", GetLastError());
      return;
     }
   string folder = InpCommon ? TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files" :
                   TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files";
   PrintFormat("%d closing deals written to %s in %s", rows, InpFileName, folder);
  }
//+------------------------------------------------------------------+
