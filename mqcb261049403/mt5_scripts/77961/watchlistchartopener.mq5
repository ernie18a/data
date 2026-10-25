//+------------------------------------------------------------------+
//|                                         WatchlistChartOpener.mq5 |
//|                                           Copyright 2026, Osazee |
//|                           https://www.mql5.com/en/users/45266274 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Osazee"
#property link        "https://www.mql5.com/en/users/45266274"
#property version     "1.00"
#property description "Opens a chart for every Market Watch symbol, or for a custom"
#property description "list of symbols, on the selected timeframe and optionally"
#property description "applies a chart template to each new chart."
#property script_show_inputs

enum ENUM_SYMBOL_SOURCE
  {
   SOURCE_MARKET_WATCH = 0, // All Market Watch symbols
   SOURCE_CUSTOM_LIST  = 1  // Custom list below
  };

input ENUM_SYMBOL_SOURCE InpSource       = SOURCE_MARKET_WATCH;            // Symbols to open
input string             InpCustomList   = "EURUSD,GBPUSD,USDJPY,XAUUSD";  // Custom list (comma-separated)
input string             InpFilter       = "";                             // Only symbols containing this text (blank = all)
input ENUM_TIMEFRAMES    InpTimeframe    = PERIOD_H1;                      // Timeframe
input string             InpTemplate     = "";                             // Template name (blank = none)
input bool               InpSkipExisting = true;                           // Skip symbols already open on this timeframe
input int                InpMaxCharts    = 20;                             // Maximum charts to open

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(InpMaxCharts < 1)
     {
      Print("Maximum charts to open must be 1 or more.");
      return;
     }

   string symbols[];
   int count = CollectSymbols(symbols);
   if(count == 0)
     {
      MessageBox("No symbols match the selected source and filter.",
                 "Watchlist Chart Opener", MB_OK | MB_ICONWARNING);
      return;
     }

   ENUM_TIMEFRAMES tf       = (InpTimeframe == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : InpTimeframe;
   string          template_name = TemplateName();
   int opened  = 0;
   int skipped = 0;
   int failed  = 0;

//--- open the charts
   for(int i = 0; i < count; i++)
     {
      if(IsStopped())
         break;
      if(opened >= InpMaxCharts)
        {
         PrintFormat("Limit of %d charts reached, remaining symbols were not opened.", InpMaxCharts);
         break;
        }
      if(InpSkipExisting && ChartIsOpen(symbols[i], tf))
        {
         skipped++;
         continue;
        }

      ResetLastError();
      long chart_id = ChartOpen(symbols[i], tf);
      if(chart_id == 0)
        {
         failed++;
         PrintFormat("Could not open a chart for %s, error %d", symbols[i], GetLastError());
         continue;
        }

      if(template_name != "")
        {
         ResetLastError();
         if(!ChartApplyTemplate(chart_id, template_name))
            PrintFormat("Template %s could not be applied to %s, error %d",
                        template_name, symbols[i], GetLastError());
        }
      opened++;
      Sleep(50);
     }

//--- summary
   string summary = StringFormat("Opened %d chart(s), skipped %d already open, %d failed.",
                                 opened, skipped, failed);
   Print(summary);
   MessageBox(summary, "Watchlist Chart Opener", MB_OK | MB_ICONINFORMATION);
  }

//+------------------------------------------------------------------+
//| Build the list of symbols to open                                |
//+------------------------------------------------------------------+
int CollectSymbols(string &out[])
  {
   ArrayResize(out, 0);

   if(InpSource == SOURCE_MARKET_WATCH)
     {
      int total = SymbolsTotal(true);
      for(int i = 0; i < total; i++)
         AddSymbol(out, SymbolName(i, true));
     }
   else
     {
      string parts[];
      int n = StringSplit(InpCustomList, ',', parts);
      for(int i = 0; i < n; i++)
        {
         string sym = Trim(parts[i]);
         if(sym == "")
            continue;
         if(!SymbolSelect(sym, true))
           {
            PrintFormat("Symbol %s was not found on this server and was skipped.", sym);
            continue;
           }
         AddSymbol(out, sym);
        }
     }
   return(ArraySize(out));
  }

//+------------------------------------------------------------------+
//| Add a symbol if it passes the filter and is not a duplicate      |
//+------------------------------------------------------------------+
void AddSymbol(string &out[], const string sym)
  {
   if(InpFilter != "")
     {
      string upper_sym    = sym;
      string upper_filter = InpFilter;
      StringToUpper(upper_sym);
      StringToUpper(upper_filter);
      if(StringFind(upper_sym, upper_filter) < 0)
         return;
     }

   int n = ArraySize(out);
   for(int i = 0; i < n; i++)
      if(out[i] == sym)
         return;

   ArrayResize(out, n + 1);
   out[n] = sym;
  }

//+------------------------------------------------------------------+
//| Is a chart with this symbol and timeframe already open?          |
//+------------------------------------------------------------------+
bool ChartIsOpen(const string sym, const ENUM_TIMEFRAMES tf)
  {
   long chart_id = ChartFirst();
   int  guard    = 0;
   while(chart_id >= 0 && guard < 1000)
     {
      if(ChartSymbol(chart_id) == sym && ChartPeriod(chart_id) == tf)
         return(true);
      chart_id = ChartNext(chart_id);
      guard++;
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Template file name with the .tpl extension                       |
//+------------------------------------------------------------------+
string TemplateName()
  {
   string name = Trim(InpTemplate);
   if(name == "")
      return("");
   string lower = name;
   StringToLower(lower);
   if(StringFind(lower, ".tpl") != StringLen(lower) - 4)
      name += ".tpl";
   return(name);
  }

//+------------------------------------------------------------------+
//| Remove leading and trailing spaces                               |
//+------------------------------------------------------------------+
string Trim(const string text)
  {
   string result = text;
   StringTrimLeft(result);
   StringTrimRight(result);
   return(result);
  }
//+------------------------------------------------------------------+
