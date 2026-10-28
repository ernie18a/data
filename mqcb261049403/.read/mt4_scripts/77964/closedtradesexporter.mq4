//+------------------------------------------------------------------+
//|                                         ClosedTradesExporter.mq4 |
//|                                           Copyright 2026, Osazee |
//|                           https://www.mql5.com/en/users/45266274 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Osazee"
#property link        "https://www.mql5.com/en/users/45266274"
#property version     "1.00"
#property description "Exports closed orders to a CSV file together with Maximum"
#property description "Adverse Excursion (MAE) and Maximum Favorable Excursion (MFE)"
#property description "calculated from M1 price history."
#property strict
#property script_show_inputs

input int    InpDaysBack      = 90;    // Days of history to export (0 = all)
input string InpSymbolFilter  = "";    // Only this symbol (blank = all)
input int    InpMagicFilter   = -1;    // Only this magic number (-1 = all)
input bool   InpCalcExcursion = true;  // Calculate MAE/MFE from M1 history
input string InpFileName      = "";    // File name (blank = automatic)
input string InpSeparator     = ",";   // Column separator
input bool   InpCommonFolder  = false; // Save to the common Files folder

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

//--- write closed market orders
   int total      = OrdersHistoryTotal();
   int exported   = 0;
   int no_history = 0;

   for(int i = 0; i < total; i++)
     {
      if(IsStopped())
         break;
      if(!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         continue;

      int type = OrderType();
      if(type != OP_BUY && type != OP_SELL)
         continue;
      if(OrderCloseTime() == 0 || (from > 0 && OrderCloseTime() < from))
         continue;
      if(InpSymbolFilter != "" && OrderSymbol() != InpSymbolFilter)
         continue;
      if(InpMagicFilter >= 0 && OrderMagicNumber() != InpMagicFilter)
         continue;

      bool history_ok = true;
      FileWriteString(handle, OrderLine(history_ok) + "\r\n");
      if(!history_ok)
         no_history++;
      exported++;
      if(exported % 25 == 0)
         Comment(StringFormat("Exporting trades: %d", exported));
     }
   FileClose(handle);
   Comment("");

//--- summary
   string folder = InpCommonFolder
                   ? TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\"
                   : TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Files\\";
   string summary = StringFormat("Exported %d closed order(s) to %s%s", exported, folder, file_name);
   if(no_history > 0)
      summary += StringFormat("\nM1 history was not available for %d order(s), MAE/MFE left blank.", no_history);
   if(exported == 0)
      summary += "\nIf you expected trades, set the Account History tab to show the full period.";
   Print(summary);
   MessageBox(summary, "Closed Trades Exporter", MB_OK | MB_ICONINFORMATION);
  }

//+------------------------------------------------------------------+
//| CSV header                                                       |
//+------------------------------------------------------------------+
string HeaderLine()
  {
   string cols[] = {"Ticket", "Symbol", "Type", "Volume", "OpenTime", "OpenPrice",
                    "CloseTime", "ClosePrice", "DurationMin", "Profit", "Commission",
                    "Swap", "NetProfit", "ResultPoints", "MAEPoints", "MFEPoints",
                    "MAEMoney", "MFEMoney", "CapturedPct", "Magic", "Comment"
                   };
   return(JoinColumns(cols));
  }

//+------------------------------------------------------------------+
//| One CSV line for the selected history order                      |
//+------------------------------------------------------------------+
string OrderLine(bool &history_ok)
  {
   string   sym         = OrderSymbol();
   int      digits      = SymbolDigits(sym);
   double   point       = SymbolInfoDouble(sym, SYMBOL_POINT);
   bool     is_buy      = (OrderType() == OP_BUY);
   double   open_price  = OrderOpenPrice();
   double   close_price = OrderClosePrice();
   datetime open_time   = OrderOpenTime();
   datetime close_time  = OrderCloseTime();
   double   volume      = OrderLots();
   double   net         = OrderProfit() + OrderCommission() + OrderSwap();

   string result_pts = "", mae_pts = "", mfe_pts = "", mae_money = "", mfe_money = "", captured = "";

   if(point > 0.0)
     {
      double result = (is_buy ? close_price - open_price : open_price - close_price) / point;
      result_pts = DoubleToString(result, 1);

      if(InpCalcExcursion)
        {
         double mae = 0.0, mfe = 0.0;
         if(GetExcursion(sym, is_buy, open_time, close_time, open_price, mae, mfe))
           {
            mae_pts   = DoubleToString(mae / point, 1);
            mfe_pts   = DoubleToString(mfe / point, 1);
            mae_money = MoneyString(sym, mae, volume);
            mfe_money = MoneyString(sym, mfe, volume);
            if(mfe > 0.0)
               captured = DoubleToString(100.0 * result / (mfe / point), 1);
           }
         else
            history_ok = false;
        }
     }

   string note = OrderComment();
   StringReplace(note, InpSeparator, " ");
   StringReplace(note, "\"", "'");

   string cols[21];
   cols[0]  = IntegerToString(OrderTicket());
   cols[1]  = sym;
   cols[2]  = is_buy ? "Buy" : "Sell";
   cols[3]  = DoubleToString(volume, 2);
   cols[4]  = TimeToString(open_time, TIME_DATE | TIME_SECONDS);
   cols[5]  = DoubleToString(open_price, digits);
   cols[6]  = TimeToString(close_time, TIME_DATE | TIME_SECONDS);
   cols[7]  = DoubleToString(close_price, digits);
   cols[8]  = IntegerToString((long)(close_time - open_time) / 60);
   cols[9]  = DoubleToString(OrderProfit(), 2);
   cols[10] = DoubleToString(OrderCommission(), 2);
   cols[11] = DoubleToString(OrderSwap(), 2);
   cols[12] = DoubleToString(net, 2);
   cols[13] = result_pts;
   cols[14] = mae_pts;
   cols[15] = mfe_pts;
   cols[16] = mae_money;
   cols[17] = mfe_money;
   cols[18] = captured;
   cols[19] = IntegerToString(OrderMagicNumber());
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
      if(rates[i].high > highest) highest = rates[i].high;
      if(rates[i].low  < lowest)  lowest  = rates[i].low;
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
