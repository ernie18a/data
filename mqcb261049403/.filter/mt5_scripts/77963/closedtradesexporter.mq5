//+------------------------------------------------------------------+
//|                                         ClosedTradesExporter.mq5 |
//|                                           Copyright 2026, Osazee |
//|                           https://www.mql5.com/en/users/45266274 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Osazee"
#property link        "https://www.mql5.com/en/users/45266274"
#property version     "1.00"
#property description "Exports closed positions to a CSV file together with Maximum"
#property description "Adverse Excursion (MAE) and Maximum Favorable Excursion (MFE)"
#property description "calculated from M1 price history."
#property script_show_inputs

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int    InpDaysBack      = 90;    // Days of history to export (0 = all)
input string InpSymbolFilter  = "";    // Only this symbol (blank = all)
input long   InpMagicFilter   = -1;    // Only this magic number (-1 = all)
input bool   InpCalcExcursion = true;  // Calculate MAE/MFE from M1 history
input string InpFileName      = "";    // File name (blank = automatic)
input string InpSeparator     = ",";   // Column separator
input bool   InpCommonFolder  = false; // Save to the common Files folder

//+------------------------------------------------------------------+
//| One position rebuilt from its deals                              |
//+------------------------------------------------------------------+
struct PositionRecord
  {
   ulong             id;
   string            symbol;
   long              type;        // DEAL_TYPE_BUY or DEAL_TYPE_SELL of the opening deal
   long              magic;
   string            note;        // comment of the opening deal
   datetime          openTime;
   datetime          closeTime;
   double            inVolume;
   double            inValue;     // sum of volume * price of entry deals
   double            outVolume;
   double            outValue;    // sum of volume * price of exit deals
   double            profit;
   double            commission;
   double            swap;
   bool              reversed;    // position contains a reversal deal
  };

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(InpSeparator == "")
     {
      Print("Column separator must not be empty.");
      return;
     }

   datetime from = (InpDaysBack > 0) ? TimeCurrent() - InpDaysBack * 86400 : 0;
   if(!HistorySelect(from, D'2100.01.01'))
     {
      Print("Failed to load the trading history, error ", GetLastError());
      return;
     }

//--- rebuild positions from deals
   PositionRecord records[];
   ArrayResize(records, 0, 1000);
   CollectPositions(records);

//--- open the output file
   string file_name = OutputFileName();
   int    flags     = FILE_WRITE | FILE_TXT | FILE_ANSI;
   if(InpCommonFolder)
      flags |= FILE_COMMON;
   ResetLastError();
   int handle = FileOpen(file_name, flags);
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("Cannot create file %s, error %d", file_name, GetLastError());
      return;
     }
   FileWriteString(handle, HeaderLine() + "\r\n");

//--- write closed positions
   int total      = ArraySize(records);
   int exported   = 0;
   int incomplete = 0;
   int no_history = 0;

   for(int i = 0; i < total; i++)
     {
      if(IsStopped())
         break;
      if(InpMagicFilter >= 0 && records[i].magic != InpMagicFilter)
         continue;
      if(!IsComplete(records[i]))
        {
         incomplete++;
         continue;
        }
      bool history_ok = true;
      FileWriteString(handle, RecordLine(records[i], history_ok) + "\r\n");
      if(!history_ok)
         no_history++;
      exported++;
      if(exported % 25 == 0)
         Comment(StringFormat("Exporting trades: %d of %d", exported, total));
     }
   FileClose(handle);
   Comment("");

//--- summary
   string folder = InpCommonFolder
                   ? TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\"
                   : TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\";
   string summary = StringFormat("Exported %d closed position(s) to %s%s", exported, folder, file_name);
   if(incomplete > 0)
      summary += StringFormat("\nSkipped %d open, partially loaded or reversed position(s).", incomplete);
   if(no_history > 0)
      summary += StringFormat("\nM1 history was not available for %d position(s), MAE/MFE left blank.", no_history);
   Print(summary);
   MessageBox(summary, "Closed Trades Exporter", MB_OK | MB_ICONINFORMATION);
  }

//+------------------------------------------------------------------+
//| Group buy/sell deals by position ID                              |
//+------------------------------------------------------------------+
void CollectPositions(PositionRecord &records[])
  {
   int deals = HistoryDealsTotal();
   for(int i = 0; i < deals; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0)
         continue;

      long deal_type = HistoryDealGetInteger(ticket, DEAL_TYPE);
      if(deal_type != DEAL_TYPE_BUY && deal_type != DEAL_TYPE_SELL)
         continue;

      string symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
      if(InpSymbolFilter != "" && symbol != InpSymbolFilter)
         continue;

      ulong position_id = (ulong)HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
      int   k           = FindRecord(records, position_id);
      if(k < 0)
        {
         k = ArraySize(records);
         ArrayResize(records, k + 1, 1000);
         InitRecord(records[k], position_id, symbol);
        }

      long     entry  = HistoryDealGetInteger(ticket, DEAL_ENTRY);
      double   volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
      double   price  = HistoryDealGetDouble(ticket, DEAL_PRICE);
      datetime time   = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);

      records[k].profit     += HistoryDealGetDouble(ticket, DEAL_PROFIT);
      records[k].commission += HistoryDealGetDouble(ticket, DEAL_COMMISSION)
                               + HistoryDealGetDouble(ticket, DEAL_FEE);
      records[k].swap       += HistoryDealGetDouble(ticket, DEAL_SWAP);

      if(entry == DEAL_ENTRY_IN)
        {
         if(records[k].inVolume == 0.0)
           {
            records[k].openTime = time;
            records[k].type     = deal_type;
            records[k].magic    = HistoryDealGetInteger(ticket, DEAL_MAGIC);
            records[k].note     = HistoryDealGetString(ticket, DEAL_COMMENT);
           }
         records[k].inVolume += volume;
         records[k].inValue  += volume * price;
        }
      else
         if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
           {
            records[k].outVolume += volume;
            records[k].outValue  += volume * price;
            if(time > records[k].closeTime)
               records[k].closeTime = time;
           }
         else
            if(entry == DEAL_ENTRY_INOUT)
               records[k].reversed = true;
     }
  }

//+------------------------------------------------------------------+
//| Find a record by position ID (searching from the newest)         |
//+------------------------------------------------------------------+
int FindRecord(const PositionRecord &records[], const ulong position_id)
  {
   for(int i = ArraySize(records) - 1; i >= 0; i--)
      if(records[i].id == position_id)
         return(i);
   return(-1);
  }

//+------------------------------------------------------------------+
//| Set every field of a new record                                  |
//+------------------------------------------------------------------+
void InitRecord(PositionRecord &rec, const ulong position_id, const string symbol)
  {
   rec.id         = position_id;
   rec.symbol     = symbol;
   rec.type       = -1;
   rec.magic      = 0;
   rec.note       = "";
   rec.openTime   = 0;
   rec.closeTime  = 0;
   rec.inVolume   = 0.0;
   rec.inValue    = 0.0;
   rec.outVolume  = 0.0;
   rec.outValue   = 0.0;
   rec.profit     = 0.0;
   rec.commission = 0.0;
   rec.swap       = 0.0;
   rec.reversed   = false;
  }

//+------------------------------------------------------------------+
//| Fully closed position with both entry and exit inside the range  |
//+------------------------------------------------------------------+
bool IsComplete(const PositionRecord &rec)
  {
   if(rec.reversed || rec.inVolume <= 0.0 || rec.outVolume <= 0.0)
      return(false);
   return(rec.outVolume >= rec.inVolume - 1e-8);
  }

//+------------------------------------------------------------------+
//| CSV header                                                       |
//+------------------------------------------------------------------+
string HeaderLine()
  {
   string cols[] = {"PositionID", "Symbol", "Type", "Volume", "OpenTime", "OpenPrice",
                    "CloseTime", "ClosePrice", "DurationMin", "Profit", "Commission",
                    "Swap", "NetProfit", "ResultPoints", "MAEPoints", "MFEPoints",
                    "MAEMoney", "MFEMoney", "CapturedPct", "Magic", "Comment"
                   };
   return(JoinColumns(cols));
  }

//+------------------------------------------------------------------+
//| One CSV line for a closed position                               |
//+------------------------------------------------------------------+
string RecordLine(const PositionRecord &rec, bool &history_ok)
  {
   string sym         = rec.symbol;
   int    digits      = SymbolDigits(sym);
   double point       = SymbolInfoDouble(sym, SYMBOL_POINT);
   bool   is_buy      = (rec.type == DEAL_TYPE_BUY);
   double open_price  = rec.inValue / rec.inVolume;
   double close_price = rec.outValue / rec.outVolume;
   double net         = rec.profit + rec.commission + rec.swap;

   string result_pts = "", mae_pts = "", mfe_pts = "", mae_money = "", mfe_money = "", captured = "";

   if(point > 0.0)
     {
      double result = (is_buy ? close_price - open_price : open_price - close_price) / point;
      result_pts = DoubleToString(result, 1);

      if(InpCalcExcursion)
        {
         double mae = 0.0, mfe = 0.0;
         if(GetExcursion(sym, is_buy, rec.openTime, rec.closeTime, open_price, mae, mfe))
           {
            mae_pts   = DoubleToString(mae / point, 1);
            mfe_pts   = DoubleToString(mfe / point, 1);
            mae_money = MoneyString(sym, mae, rec.inVolume);
            mfe_money = MoneyString(sym, mfe, rec.inVolume);
            if(mfe > 0.0)
               captured = DoubleToString(100.0 * result / (mfe / point), 1);
           }
         else
            history_ok = false;
        }
     }

   string note = rec.note;
   StringReplace(note, InpSeparator, " ");
   StringReplace(note, "\"", "'");

   string cols[21];
   cols[0]  = IntegerToString((long)rec.id);
   cols[1]  = sym;
   cols[2]  = is_buy ? "Buy" : "Sell";
   cols[3]  = DoubleToString(rec.inVolume, 2);
   cols[4]  = TimeToString(rec.openTime, TIME_DATE | TIME_SECONDS);
   cols[5]  = DoubleToString(open_price, digits);
   cols[6]  = TimeToString(rec.closeTime, TIME_DATE | TIME_SECONDS);
   cols[7]  = DoubleToString(close_price, digits);
   cols[8]  = IntegerToString((long)(rec.closeTime - rec.openTime) / 60);
   cols[9]  = DoubleToString(rec.profit, 2);
   cols[10] = DoubleToString(rec.commission, 2);
   cols[11] = DoubleToString(rec.swap, 2);
   cols[12] = DoubleToString(net, 2);
   cols[13] = result_pts;
   cols[14] = mae_pts;
   cols[15] = mfe_pts;
   cols[16] = mae_money;
   cols[17] = mfe_money;
   cols[18] = captured;
   cols[19] = IntegerToString(rec.magic);
   cols[20] = note;
   return(JoinColumns(cols));
  }

//+------------------------------------------------------------------+
//| MAE and MFE (price distance) from M1 bars of the trade's life    |
//+------------------------------------------------------------------+
bool GetExcursion(const string sym, const bool is_buy, const datetime open_time,
                  const datetime close_time, const double open_price,
                  double &mae, double &mfe)
  {
   MqlRates rates[];
   datetime start  = (datetime)((long)open_time - (long)open_time % 60);
   int      copied = -1;

   for(int attempt = 0; attempt < 3 && copied <= 0; attempt++)
     {
      copied = CopyRates(sym, PERIOD_M1, start, close_time, rates);
      if(copied <= 0)
         Sleep(300);
     }
   if(copied <= 0)
      return(false);

   double highest = rates[0].high;
   double lowest  = rates[0].low;
   for(int i = 1; i < copied; i++)
     {
      if(rates[i].high > highest)
         highest = rates[i].high;
      if(rates[i].low  < lowest)
         lowest  = rates[i].low;
     }

   if(is_buy)
     {
      mfe = MathMax(0.0, highest - open_price);
      mae = MathMax(0.0, open_price - lowest);
     }
   else
     {
      mfe = MathMax(0.0, open_price - lowest);
      mae = MathMax(0.0, highest - open_price);
     }
   return(true);
  }

//+------------------------------------------------------------------+
//| Convert a price distance to account currency                     |
//+------------------------------------------------------------------+
string MoneyString(const string sym, const double distance, const double volume)
  {
   double tick_size  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   if(tick_size <= 0.0 || tick_value <= 0.0)
      return("");
   return(DoubleToString(distance / tick_size * tick_value * volume, 2));
  }

//+------------------------------------------------------------------+
//| Symbol digits with a fallback for symbols no longer available    |
//+------------------------------------------------------------------+
int SymbolDigits(const string sym)
  {
   ResetLastError();
   long digits = SymbolInfoInteger(sym, SYMBOL_DIGITS);
   if(GetLastError() != 0)
      return(5);
   return((int)digits);
  }

//+------------------------------------------------------------------+
//| Join columns with the selected separator                         |
//+------------------------------------------------------------------+
string JoinColumns(const string &cols[])
  {
   string line = "";
   int    n    = ArraySize(cols);
   for(int i = 0; i < n; i++)
     {
      if(i > 0)
         line += InpSeparator;
      line += cols[i];
     }
   return(line);
  }

//+------------------------------------------------------------------+
//| Output file name                                                 |
//+------------------------------------------------------------------+
string OutputFileName()
  {
   if(InpFileName != "")
     {
      string name  = InpFileName;
      string lower = name;
      StringToLower(lower);
      if(StringFind(lower, ".csv") != StringLen(lower) - 4)
         name += ".csv";
      return(name);
     }
   string stamp = TimeToString(TimeLocal(), TIME_DATE | TIME_MINUTES);
   StringReplace(stamp, ".", "");
   StringReplace(stamp, ":", "");
   StringReplace(stamp, " ", "_");
   return("ClosedTrades_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "_" + stamp + ".csv");
  }
//+------------------------------------------------------------------+
