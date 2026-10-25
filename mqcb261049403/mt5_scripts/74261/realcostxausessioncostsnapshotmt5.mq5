//+------------------------------------------------------------------+
//|                            RealCostXauSessionCostSnapshotMT5.mq5 |
//|                    Open source symbol-condition snapshot for MT5 |
//|                                                                  |
//| Reads the current chart symbol's trading properties and writes a |
//| compact report to the Experts log and optional local CSV file.   |
//| It does not trade and does not provide signals.                  |
//+------------------------------------------------------------------+
#property copyright "RealCost"
#property link      ""
#property version   "1.00"
#property strict
#property script_show_inputs
#property description "Open source MT5 symbol-condition snapshot for XAUUSD/GOLD testing."
#property description "Reads spread, tick value, contract size, volume step, stop/freeze levels and account context."
#property description "This educational utility does not open, modify or close trades."

input bool   InpWriteCsv             = true;                              // Write local CSV snapshot
input bool   InpUseCommonFilesFolder = false;                             // Write to common terminal files folder
input string InpFilePrefix           = "RealCostXauSessionCostSnapshot";  // CSV file prefix
input bool   InpShowMessageBox       = true;                              // Show summary message box

#define RCCS_NO_VALUE 1.7e+308

//+------------------------------------------------------------------+
//| Script entry point                                                |
//+------------------------------------------------------------------+
void OnStart()
  {
   string report = "";
   AddLine(report,"RealCost XAU Session Cost Snapshot MT5");
   AddLine(report,"This script reads symbol settings only. It does not trade.");
   AddLine(report,"");

   MqlTick tick;
   bool has_tick = SymbolInfoTick(_Symbol,tick);

   double point          = SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   int    digits         = (int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   long   spread_raw     = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   double spread_points  = GetSpreadPoints(tick,has_tick,point,spread_raw);
   double tick_size      = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tick_value     = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double contract_size  = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   double volume_min     = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double volume_max     = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double volume_step    = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   long   stop_level     = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   long   freeze_level   = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   double swap_long      = SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG);
   double swap_short     = SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT);
   long   trade_mode     = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   long   filling_mode   = SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
   long   order_mode     = SymbolInfoInteger(_Symbol,SYMBOL_ORDER_MODE);
   string currency_base  = SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE);
   string currency_profit= SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT);
   string currency_margin= SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN);

   double balance        = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity         = AccountInfoDouble(ACCOUNT_EQUITY);
   string account_ccy    = AccountInfoString(ACCOUNT_CURRENCY);
   long   leverage       = AccountInfoInteger(ACCOUNT_LEVERAGE);

   AddKey(report,"Time local",TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS));
   AddKey(report,"Time server",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   AddKey(report,"Symbol",_Symbol);
   AddKey(report,"Bid",DoubleToString(has_tick ? tick.bid : 0.0,digits));
   AddKey(report,"Ask",DoubleToString(has_tick ? tick.ask : 0.0,digits));
   AddKey(report,"Spread points",FormatDouble(spread_points,2));
   AddKey(report,"Digits",(string)digits);
   AddKey(report,"Point",DoubleToString(point,10));
   AddKey(report,"Tick size",DoubleToString(tick_size,10));
   AddKey(report,"Tick value",DoubleToString(tick_value,4));
   AddKey(report,"Contract size",DoubleToString(contract_size,2));
   AddKey(report,"Volume min",DoubleToString(volume_min,2));
   AddKey(report,"Volume max",DoubleToString(volume_max,2));
   AddKey(report,"Volume step",DoubleToString(volume_step,2));
   AddKey(report,"Stop level points",(string)stop_level);
   AddKey(report,"Freeze level points",(string)freeze_level);
   AddKey(report,"Swap long",DoubleToString(swap_long,4));
   AddKey(report,"Swap short",DoubleToString(swap_short,4));
   AddKey(report,"Trade mode",TradeModeText(trade_mode));
   AddKey(report,"Filling mode",FillingModeText(filling_mode));
   AddKey(report,"Order mode",OrderModeText(order_mode));
   AddKey(report,"Base currency",currency_base);
   AddKey(report,"Profit currency",currency_profit);
   AddKey(report,"Margin currency",currency_margin);
   AddKey(report,"Account balance",DoubleToString(balance,2));
   AddKey(report,"Account equity",DoubleToString(equity,2));
   AddKey(report,"Account currency",account_ccy);
   AddKey(report,"Account leverage",(string)leverage);

   Print(report);

   string csv_file = "";
   if(InpWriteCsv)
     {
      csv_file = WriteCsv(tick,has_tick,point,spread_points,digits,tick_size,tick_value,
                          contract_size,volume_min,volume_max,volume_step,stop_level,
                          freeze_level,swap_long,swap_short,trade_mode,filling_mode,
                          order_mode,currency_base,currency_profit,currency_margin,
                          balance,equity,account_ccy,leverage);
      if(csv_file != "")
         Print("RealCost snapshot CSV written: ",csv_file);
     }

   if(InpShowMessageBox)
     {
      string summary = StringFormat("%s\nSpread: %s points\nTick value: %s\nContract: %s\nVolume step: %s\nStop/freeze: %d/%d points",
                                    _Symbol,
                                    FormatDouble(spread_points,2),
                                    DoubleToString(tick_value,4),
                                    DoubleToString(contract_size,2),
                                    DoubleToString(volume_step,2),
                                    stop_level,
                                    freeze_level);
      if(csv_file != "")
         summary += "\nCSV: " + csv_file;
      MessageBox(summary,"RealCost Symbol Snapshot",MB_OK|MB_ICONINFORMATION);
     }
  }

//+------------------------------------------------------------------+
//| Report helpers                                                    |
//+------------------------------------------------------------------+
void AddLine(string &text,const string line)
  {
   text += line + "\n";
  }

void AddKey(string &text,const string key,const string value)
  {
   text += StringFormat("%-24s : %s\n",key,value);
  }

string FormatDouble(const double value,const int digits)
  {
   if(value == RCCS_NO_VALUE)
      return "n/a";
   return DoubleToString(value,digits);
  }

double GetSpreadPoints(const MqlTick &tick,const bool has_tick,const double point,const long raw_spread)
  {
   if(point > 0.0 && has_tick && tick.ask > 0.0 && tick.bid > 0.0)
      return (tick.ask - tick.bid) / point;
   if(raw_spread >= 0)
      return (double)raw_spread;
   return RCCS_NO_VALUE;
  }

string TradeModeText(const long mode)
  {
   switch((int)mode)
     {
      case SYMBOL_TRADE_MODE_DISABLED:
         return "disabled";
      case SYMBOL_TRADE_MODE_LONGONLY:
         return "long only";
      case SYMBOL_TRADE_MODE_SHORTONLY:
         return "short only";
      case SYMBOL_TRADE_MODE_CLOSEONLY:
         return "close only";
      case SYMBOL_TRADE_MODE_FULL:
         return "full";
     }
   return "unknown(" + (string)mode + ")";
  }

string FillingModeText(const long mode)
  {
   string text = "";
   if((mode & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
      text += "FOK ";
   if((mode & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
      text += "IOC ";
   if((mode & SYMBOL_FILLING_BOC) == SYMBOL_FILLING_BOC)
      text += "BOC ";
   StringTrimRight(text);
   if(text == "")
      text = "unknown(" + (string)mode + ")";
   return text;
  }

string OrderModeText(const long mode)
  {
   string text = "";
   if((mode & SYMBOL_ORDER_MARKET) == SYMBOL_ORDER_MARKET)
      text += "market ";
   if((mode & SYMBOL_ORDER_LIMIT) == SYMBOL_ORDER_LIMIT)
      text += "limit ";
   if((mode & SYMBOL_ORDER_STOP) == SYMBOL_ORDER_STOP)
      text += "stop ";
   if((mode & SYMBOL_ORDER_STOP_LIMIT) == SYMBOL_ORDER_STOP_LIMIT)
      text += "stop-limit ";
   if((mode & SYMBOL_ORDER_SL) == SYMBOL_ORDER_SL)
      text += "sl ";
   if((mode & SYMBOL_ORDER_TP) == SYMBOL_ORDER_TP)
      text += "tp ";
   if((mode & SYMBOL_ORDER_CLOSEBY) == SYMBOL_ORDER_CLOSEBY)
      text += "close-by ";
   StringTrimRight(text);
   if(text == "")
      text = "unknown(" + (string)mode + ")";
   return text;
  }

string SafeFilePart(string value)
  {
   StringReplace(value,"\\","_");
   StringReplace(value,"/","_");
   StringReplace(value,":","_");
   StringReplace(value,"*","_");
   StringReplace(value,"?","_");
   StringReplace(value,"\"","_");
   StringReplace(value,"<","_");
   StringReplace(value,">","_");
   StringReplace(value,"|","_");
   StringReplace(value," ","_");
   return value;
  }

string WriteCsv(const MqlTick &tick,
                const bool has_tick,
                const double point,
                const double spread_points,
                const int digits,
                const double tick_size,
                const double tick_value,
                const double contract_size,
                const double volume_min,
                const double volume_max,
                const double volume_step,
                const long stop_level,
                const long freeze_level,
                const double swap_long,
                const double swap_short,
                const long trade_mode,
                const long filling_mode,
                const long order_mode,
                const string currency_base,
                const string currency_profit,
                const string currency_margin,
                const double balance,
                const double equity,
                const string account_ccy,
                const long leverage)
  {
   string stamp = TimeToString(TimeLocal(),TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   stamp = SafeFilePart(stamp);
   string file_name = InpFilePrefix + "_" + SafeFilePart(_Symbol) + "_" + stamp + ".csv";

   int flags = FILE_WRITE|FILE_CSV|FILE_ANSI;
   if(InpUseCommonFilesFolder)
      flags |= FILE_COMMON;

   int handle = FileOpen(file_name,flags);
   if(handle == INVALID_HANDLE)
     {
      Print("RealCost snapshot: could not open CSV file. Error ",GetLastError());
      return "";
     }

   FileWrite(handle,"field","value");
   FileWrite(handle,"time_local",TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS));
   FileWrite(handle,"time_server",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   FileWrite(handle,"symbol",_Symbol);
   FileWrite(handle,"bid",DoubleToString(has_tick ? tick.bid : 0.0,digits));
   FileWrite(handle,"ask",DoubleToString(has_tick ? tick.ask : 0.0,digits));
   FileWrite(handle,"spread_points",FormatDouble(spread_points,2));
   FileWrite(handle,"digits",(string)digits);
   FileWrite(handle,"point",DoubleToString(point,10));
   FileWrite(handle,"tick_size",DoubleToString(tick_size,10));
   FileWrite(handle,"tick_value",DoubleToString(tick_value,4));
   FileWrite(handle,"contract_size",DoubleToString(contract_size,2));
   FileWrite(handle,"volume_min",DoubleToString(volume_min,2));
   FileWrite(handle,"volume_max",DoubleToString(volume_max,2));
   FileWrite(handle,"volume_step",DoubleToString(volume_step,2));
   FileWrite(handle,"stop_level_points",(string)stop_level);
   FileWrite(handle,"freeze_level_points",(string)freeze_level);
   FileWrite(handle,"swap_long",DoubleToString(swap_long,4));
   FileWrite(handle,"swap_short",DoubleToString(swap_short,4));
   FileWrite(handle,"trade_mode",TradeModeText(trade_mode));
   FileWrite(handle,"filling_mode",FillingModeText(filling_mode));
   FileWrite(handle,"order_mode",OrderModeText(order_mode));
   FileWrite(handle,"base_currency",currency_base);
   FileWrite(handle,"profit_currency",currency_profit);
   FileWrite(handle,"margin_currency",currency_margin);
   FileWrite(handle,"account_balance",DoubleToString(balance,2));
   FileWrite(handle,"account_equity",DoubleToString(equity,2));
   FileWrite(handle,"account_currency",account_ccy);
   FileWrite(handle,"account_leverage",(string)leverage);

   FileFlush(handle);
   FileClose(handle);
   return file_name;
  }
