//+------------------------------------------------------------------+
//|                                           TW_SymbolSpecExport.mq5 |
//|                                        Copyright 2026, Twelora   |
//|                                            https://twelora.com   |
//+------------------------------------------------------------------+
#property copyright "Twelora"
#property link      "https://twelora.com"
#property version   "1.02"
#property description "Writes the trading specification of every symbol to a CSV file:"
#property description "digits, point, volume min/max/step, stops and freeze level,"
#property description "filling modes, contract size, margin and swaps."
#property description ""
#property description "These are the values at which most Expert Advisors fail when"
#property description "they are moved to a different broker or instrument. Export the"
#property description "file once and you can see at a glance what will break."
#property description ""
#property description "This is a script. It reads symbol data and writes a file."

#property script_show_inputs

//--- inputs
input bool   InpMarketWatchOnly = true;   // Market Watch symbols only
input bool   InpCommonFolder    = false;  // Write into the common Files folder
input string InpFileName        = "";     // File name (empty = auto)

//+------------------------------------------------------------------+
//| Makes a text field safe for a semicolon separated file            |
//+------------------------------------------------------------------+
string CsvSafe(string text)
  {
   // Some brokers return descriptions that contain a semicolon - either
   // directly or as part of an HTML entity such as "&amp;". Written
   // unchanged, that semicolon would split the field and shift every
   // following column of that row by one.
   StringReplace(text, "&amp;", "&");
   StringReplace(text, ";", ",");
   StringReplace(text, "\r", " ");
   StringReplace(text, "\n", " ");
   return text;
  }

//+------------------------------------------------------------------+
//| Readable list of the allowed filling modes                       |
//+------------------------------------------------------------------+
string FillingText(const string symbol)
  {
   int    modes = (int)SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
   string out   = "";

   if((modes & SYMBOL_FILLING_FOK) != 0)
      out += "FOK ";
   if((modes & SYMBOL_FILLING_IOC) != 0)
      out += "IOC ";

   if(StringLen(out) == 0)
      out = "RETURN only";

   StringTrimRight(out);
   return(out);
  }

//+------------------------------------------------------------------+
//| Readable execution mode                                          |
//+------------------------------------------------------------------+
string ExecutionText(const string symbol)
  {
   switch((ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(symbol, SYMBOL_TRADE_EXEMODE))
     {
      case SYMBOL_TRADE_EXECUTION_REQUEST:  return("Request");
      case SYMBOL_TRADE_EXECUTION_INSTANT:  return("Instant");
      case SYMBOL_TRADE_EXECUTION_MARKET:   return("Market");
      case SYMBOL_TRADE_EXECUTION_EXCHANGE: return("Exchange");
     }
   return("unknown");
  }

//+------------------------------------------------------------------+
//| Readable trade mode                                              |
//+------------------------------------------------------------------+
string TradeModeText(const string symbol)
  {
   switch((ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE))
     {
      case SYMBOL_TRADE_MODE_DISABLED:  return("disabled");
      case SYMBOL_TRADE_MODE_LONGONLY:  return("long only");
      case SYMBOL_TRADE_MODE_SHORTONLY: return("short only");
      case SYMBOL_TRADE_MODE_CLOSEONLY: return("close only");
      case SYMBOL_TRADE_MODE_FULL:      return("full");
     }
   return("unknown");
  }

//+------------------------------------------------------------------+
//| Script entry point                                               |
//+------------------------------------------------------------------+
void OnStart()
  {
   string file = InpFileName;
   if(StringLen(file) == 0)
     {
      // TimeLocal, not TimeCurrent: TimeCurrent returns the time of the last
      // tick the terminal received, which on a closed market or an idle demo
      // feed can be days old. The file name is meant to say when the export
      // was made, so the computer clock is the correct source.
      MqlDateTime dt;
      TimeToStruct(TimeLocal(), dt);
      file = StringFormat("SymbolSpecs_%04d%02d%02d.csv", dt.year, dt.mon, dt.day);
     }

   int flags = FILE_WRITE | FILE_CSV | FILE_ANSI;
   if(InpCommonFolder)
      flags |= FILE_COMMON;

   int handle = FileOpen(file, flags, ';');
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("TW_SymbolSpecExport: could not open '%s'. Error %d.", file, GetLastError());
      return;
     }

   FileWrite(handle,
             "Symbol", "Description", "Digits", "Point", "TickSize", "TickValue",
             "VolumeMin", "VolumeMax", "VolumeStep", "ContractSize",
             "StopsLevel", "FreezeLevel", "Spread", "SpreadFloat",
             "Filling", "Execution", "TradeMode",
             "MarginInitial", "SwapLong", "SwapShort", "CurrencyProfit");

   int total   = SymbolsTotal(InpMarketWatchOnly);
   int written = 0;

   for(int i = 0; i < total; i++)
     {
      string symbol = SymbolName(i, InpMarketWatchOnly);
      if(StringLen(symbol) == 0)
         continue;

      //--- data for symbols outside the Market Watch is only available
      //--- once they have been selected
      bool selectedHere = false;
      if(!SymbolInfoInteger(symbol, SYMBOL_SELECT))
        {
         if(!SymbolSelect(symbol, true))
            continue;
         selectedHere = true;
        }

      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      FileWrite(handle,
                symbol,
                CsvSafe(SymbolInfoString(symbol, SYMBOL_DESCRIPTION)),
                IntegerToString(digits),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_POINT), 8),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), 8),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE), 5),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN), 2),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX), 2),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP), 2),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE), 2),
                IntegerToString(SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL)),
                IntegerToString(SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL)),
                IntegerToString(SymbolInfoInteger(symbol, SYMBOL_SPREAD)),
                (SymbolInfoInteger(symbol, SYMBOL_SPREAD_FLOAT) ? "yes" : "no"),
                FillingText(symbol),
                ExecutionText(symbol),
                TradeModeText(symbol),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL), 2),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG), 4),
                DoubleToString(SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT), 4),
                SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT));

      written++;

      //--- leave the Market Watch the way we found it
      if(selectedHere)
         SymbolSelect(symbol, false);
     }

   FileClose(handle);

   PrintFormat("TW_SymbolSpecExport: %d of %d symbols written to '%s'%s.",
               written, total, file, (InpCommonFolder ? " (common folder)" : ""));
  }
//+------------------------------------------------------------------+
