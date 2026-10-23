//+------------------------------------------------------------------+
//|                                                   ExportBars.mq5 |
//|                                      Copyright 2026, Bohdan Klok |
//|                            https://www.mql5.com/en/users/kbposht |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Bohdan Klok"
#property link      "https://www.mql5.com/en/users/kbposht"
#property version   "1.10"
#property description "Exports bars to a CSV file that loads without extra settings:"
#property description "ISO 8601 timestamps, prices at the symbol's own digits,"
#property description "single-byte encoding."
#property description ""
#property description "Two modes: the last N bars or a date range."
#property description "The separator is switchable: a semicolon is needed where"
#property description "Excel is configured with a comma as the decimal mark."
#property description ""
#property description "The file is written to MQL5\\Files (or to the common folder"
#property description "of all terminals if the corresponding input is enabled)."
#property script_show_inputs
//+------------------------------------------------------------------+
//| Export mode                                                      |
//+------------------------------------------------------------------+
enum ENUM_EXPORT_MODE
  {
   EXPORT_LAST_N=0,   // Last N bars
   EXPORT_RANGE=1     // Date range
  };
//+------------------------------------------------------------------+
//| Field separator                                                  |
//+------------------------------------------------------------------+
enum ENUM_CSV_SEP
  {
   SEP_COMMA=0,       // Comma  ,
   SEP_SEMICOLON=1,   // Semicolon  ;
   SEP_TAB=2          // Tab
  };
//--- input parameters
input string           InpSymbol="";                  // Symbol (empty = current chart symbol)
input ENUM_TIMEFRAMES  InpTimeframe=PERIOD_CURRENT;   // Timeframe
input ENUM_EXPORT_MODE InpMode=EXPORT_LAST_N;         // Export mode
input int              InpBars=5000;                  // Bars (for the "Last N bars" mode)
input datetime         InpFrom=D'2025.01.01';         // From (for the "Date range" mode)
input datetime         InpTo=D'2026.01.01';           // To (for the "Date range" mode)
input ENUM_CSV_SEP     InpSeparator=SEP_COMMA;        // Separator
input bool             InpCommonDir=false;            // Write to the common folder of all terminals
input string           InpFileName="";                // File name (empty = Symbol_Timeframe.csv)
//+------------------------------------------------------------------+
//| "H1" instead of "PERIOD_H1"; PERIOD_CURRENT becomes the real one |
//+------------------------------------------------------------------+
string TimeframeName(const ENUM_TIMEFRAMES tf)
  {
   string s=EnumToString(tf==PERIOD_CURRENT ? (ENUM_TIMEFRAMES)Period() : tf);
   StringReplace(s,"PERIOD_","");
   return(s);
  }
//+------------------------------------------------------------------+
//| Time in ISO 8601. TimeToString gives "2026.10.02 10:00" - dots   |
//| and no seconds - which has to be parsed by hand in pandas        |
//+------------------------------------------------------------------+
string TimeToIso(const datetime t)
  {
   MqlDateTime d;
   TimeToStruct(t,d);
   return(StringFormat("%04d-%02d-%02d %02d:%02d:%02d",
                       d.year,d.mon,d.day,d.hour,d.min,d.sec));
  }
//+------------------------------------------------------------------+
//| Price at the symbol's own digits, never in scientific notation   |
//+------------------------------------------------------------------+
string PriceToString(const string symbol,const double price)
  {
   return(DoubleToString(price,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)));
  }
//+------------------------------------------------------------------+
//| Separator character for the selected option                      |
//+------------------------------------------------------------------+
short SeparatorChar(const ENUM_CSV_SEP s)
  {
   switch(s)
     {
      case SEP_SEMICOLON:
         return(';');
      case SEP_TAB:
         return('\t');
      default:
         return(',');
     }
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   const string symbol=(InpSymbol=="" ? _Symbol : InpSymbol);
//--- the symbol must be in Market Watch for its history to be available
   if(!SymbolSelect(symbol,true))
     {
      PrintFormat("ExportBars: symbol %s is not available, error=%d",symbol,GetLastError());
      return;
     }
//--- chronological order: index 0 is the oldest bar, so the rows of the
//--- file follow the chart from left to right
   MqlRates rates[];
   ArraySetAsSeries(rates,false);
//--- copy the bars
   int copied=0;
   if(InpMode==EXPORT_LAST_N)
     {
      if(InpBars<1)
        {
         Print("ExportBars: InpBars must be >= 1");
         return;
        }
      copied=CopyRates(symbol,InpTimeframe,0,InpBars,rates);
     }
   else
     {
      if(InpFrom>=InpTo)
        {
         Print("ExportBars: InpFrom must be earlier than InpTo");
         return;
        }
      copied=CopyRates(symbol,InpTimeframe,InpFrom,InpTo,rates);
     }
//--- nothing to write
   if(copied<=0)
     {
      PrintFormat("ExportBars: CopyRates(%s %s) returned no data, error=%d - "
                  "the history is not loaded or the range lies outside of it",
                  symbol,TimeframeName(InpTimeframe),GetLastError());
      return;
     }
   if(InpMode==EXPORT_LAST_N && copied<InpBars)
      PrintFormat("ExportBars: %d bars requested, %d available",InpBars,copied);
//--- file name
   string file=InpFileName;
   if(file=="")
      file=StringFormat("%s_%s.csv",symbol,TimeframeName(InpTimeframe));
//--- FILE_ANSI gives single-byte text. Without it MQL5 writes UTF-16 and
//--- read_csv fails until the encoding is passed explicitly
   int flags=FILE_WRITE|FILE_CSV|FILE_ANSI;
   if(InpCommonDir)
      flags|=FILE_COMMON;
//--- open the file
   const int handle=FileOpen(file,flags,SeparatorChar(InpSeparator));
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("ExportBars: FileOpen('%s') failed, error=%d",file,GetLastError());
      return;
     }
//--- header
   FileWrite(handle,"time","open","high","low","close",
             "tick_volume","spread","real_volume");
//--- rows, oldest bar first
   for(int i=0; i<copied; ++i)
      FileWrite(handle,
                TimeToIso(rates[i].time),
                PriceToString(symbol,rates[i].open),
                PriceToString(symbol,rates[i].high),
                PriceToString(symbol,rates[i].low),
                PriceToString(symbol,rates[i].close),
                (string)rates[i].tick_volume,
                (string)rates[i].spread,
                (string)rates[i].real_volume);
//---
   FileClose(handle);
//--- report
   PrintFormat("ExportBars: %s %s - %d bars, %s .. %s -> %s\\%s",
               symbol,TimeframeName(InpTimeframe),copied,
               TimeToIso(rates[0].time),TimeToIso(rates[copied-1].time),
               (InpCommonDir ? "Common\\Files" : "MQL5\\Files"),file);
  }
//+------------------------------------------------------------------+
