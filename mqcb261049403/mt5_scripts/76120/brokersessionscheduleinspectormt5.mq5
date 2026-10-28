//+------------------------------------------------------------------+
//|                  BrokerSessionScheduleInspectorMT5.mq5           |
//| Read-only broker-native trading-session diagnostics for MT5      |
//+------------------------------------------------------------------+
#property copyright "Usamah — usamah41"
#property link      "https://www.mql5.com/en/users/usamah41"
#property version   "1.00"
#property strict
#property script_show_inputs

enum ENUM_SYMBOL_SCOPE
  {
   SCOPE_CURRENT_CHART=0,       // Inspect only the chart symbol
   SCOPE_MARKET_WATCH=1,        // Inspect every visible Market Watch symbol
   SCOPE_CUSTOM_LIST=2          // Inspect comma-separated symbols
  };

input ENUM_SYMBOL_SCOPE InpSymbolScope=SCOPE_CURRENT_CHART; // Symbol selection mode
input string InpCustomSymbols="EURUSD,XAUUSD";              // Used for custom-list mode
input bool InpExportCSV=true;                               // Save a common-folder CSV snapshot
input string InpFilePrefix="BrokerSessionSchedule";        // Safe output filename prefix
input int InpMaximumSessionsPerDay=32;                      // Defensive session enumeration limit

struct SessionWindow
  {
   datetime start_time;
   datetime end_time;
   int      weekday;
   int      index;
  };

string g_symbols[];
int    g_file=INVALID_HANDLE;

// Return a stable English weekday name for reports and CSV files.
string WeekdayName(const int weekday)
  {
   string names[7]={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
   if(weekday<0 || weekday>6)
      return("Unknown");
   return(names[weekday]);
  }

// Trim spaces without relying on side effects at the call site.
string Trimmed(string value)
  {
   StringTrimLeft(value);
   StringTrimRight(value);
   return(value);
  }

// Restrict filenames to a simple portable character set.
string SafeFilePart(const string raw)
  {
   string clean="";
   for(int i=0;i<StringLen(raw);i++)
     {
      ushort ch=StringGetCharacter(raw,i);
      bool allowed=((ch>='0' && ch<='9') || (ch>='A' && ch<='Z') ||
                    (ch>='a' && ch<='z') || ch=='_' || ch=='-');
      clean+=(allowed ? ShortToString(ch) : "_");
     }
   if(StringLen(clean)==0)
      clean="BrokerSessionSchedule";
   return(clean);
  }

bool ContainsSymbol(const string symbol)
  {
   for(int i=0;i<ArraySize(g_symbols);i++)
      if(g_symbols[i]==symbol)
         return(true);
   return(false);
  }

void AddSymbol(const string candidate)
  {
   string symbol=Trimmed(candidate);
   if(StringLen(symbol)==0 || ContainsSymbol(symbol))
      return;
   int size=ArraySize(g_symbols);
   ArrayResize(g_symbols,size+1);
   g_symbols[size]=symbol;
  }

void BuildSymbolList()
  {
   ArrayResize(g_symbols,0);
   if(InpSymbolScope==SCOPE_CURRENT_CHART)
     {
      AddSymbol(_Symbol);
      return;
     }
   if(InpSymbolScope==SCOPE_MARKET_WATCH)
     {
      int total=SymbolsTotal(true);
      for(int i=0;i<total;i++)
         AddSymbol(SymbolName(i,true));
      return;
     }
   string parts[];
   int count=StringSplit(InpCustomSymbols,',',parts);
   for(int i=0;i<count;i++)
      AddSymbol(parts[i]);
  }

// Convert the time-of-day value returned by SymbolInfoSessionTrade.
int SecondsOfDay(const datetime value)
  {
   long seconds=(long)value%86400;
   if(seconds<0)
      seconds+=86400;
   return((int)seconds);
  }

datetime DayStart(const datetime value)
  {
   MqlDateTime parts={};
   TimeToStruct(value,parts);
   parts.hour=0;
   parts.min=0;
   parts.sec=0;
   return(StructToTime(parts));
  }

// Build an absolute interval for a weekday occurrence near server time.
bool ReadAbsoluteSession(const string symbol,const datetime day_start,
                         const int weekday,const int index,SessionWindow &window)
  {
   datetime from=0,to=0;
   ResetLastError();
   if(!SymbolInfoSessionTrade(symbol,(ENUM_DAY_OF_WEEK)weekday,(uint)index,from,to))
      return(false);
   int from_sec=SecondsOfDay(from);
   int to_sec=SecondsOfDay(to);
   window.start_time=day_start+from_sec;
   window.end_time=day_start+to_sec;
   if(to_sec<=from_sec)
      window.end_time+=86400;
   window.weekday=weekday;
   window.index=index;
   return(true);
  }

string TimeLabel(const datetime value)
  {
   if(value<=0)
      return("N/A");
   return(TimeToString(value,TIME_DATE|TIME_MINUTES|TIME_SECONDS));
  }

string SessionEndLabel(const SessionWindow &window)
  {
   string label=TimeToString(window.end_time,TIME_MINUTES);
   if(DayStart(window.end_time)>DayStart(window.start_time))
      label+=" (+1d)";
   return(label);
  }

void WriteCsvRow(const string symbol,const string status,const string day,
                 const int session_index,const string start_value,const string end_value,
                 const string next_event,const string next_time,const string trade_mode,
                 const string synchronized)
  {
   if(g_file==INVALID_HANDLE)
      return;
   FileWrite(g_file,symbol,status,day,session_index,start_value,end_value,
             next_event,next_time,trade_mode,synchronized);
  }

// Inspect one symbol and return a concise summary suitable for Chart Comment.
string InspectSymbol(const string symbol,const datetime now)
  {
   bool synchronized=(bool)SymbolInfoInteger(symbol,SYMBOL_SELECT) &&
                     (bool)SymbolIsSynchronized(symbol);
   ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE);
   string mode_text=EnumToString(mode);
   datetime today=DayStart(now);
   bool has_schedule=false;
   bool is_open=false;
   datetime next_time=0;
   string next_event="NONE";
   int max_sessions=MathMax(1,MathMin(InpMaximumSessionsPerDay,128));

   // Include yesterday for sessions crossing midnight, then scan one week ahead.
   for(int day_offset=-1;day_offset<=7;day_offset++)
     {
      datetime scan_day=today+(day_offset*86400);
      MqlDateTime day_parts={};
      TimeToStruct(scan_day,day_parts);
      int weekday=day_parts.day_of_week;
      for(int index=0;index<max_sessions;index++)
        {
         SessionWindow window={};
         if(!ReadAbsoluteSession(symbol,scan_day,weekday,index,window))
            break;
         has_schedule=true;
         if(now>=window.start_time && now<window.end_time)
            is_open=true;
         if(window.start_time>now && (next_time==0 || window.start_time<next_time))
           {
            next_time=window.start_time;
            next_event="OPEN";
           }
         if(window.end_time>now && (next_time==0 || window.end_time<next_time))
           {
            next_time=window.end_time;
            next_event="CLOSE";
           }

         // Weekly schedule rows are written only once, for the current week scan.
         if(day_offset>=0 && day_offset<=6)
           {
            string row_status=(now>=window.start_time && now<window.end_time ? "ACTIVE" : "SCHEDULED");
            WriteCsvRow(symbol,row_status,WeekdayName(weekday),index,
                        TimeToString(window.start_time,TIME_MINUTES),
                        SessionEndLabel(window),"","",mode_text,
                        (synchronized ? "true" : "false"));
           }
        }
     }

   string status=(has_schedule ? (is_open ? "OPEN_BY_SCHEDULE" : "CLOSED_BY_SCHEDULE") : "SCHEDULE_UNAVAILABLE");
   string summary=StringFormat("%s | %s | mode=%s | synced=%s | next=%s %s",
                               symbol,status,mode_text,(synchronized ? "true" : "false"),
                               next_event,TimeLabel(next_time));
   Print(summary);
   if(!has_schedule)
      WriteCsvRow(symbol,status,"",-1,"","",next_event,TimeLabel(next_time),mode_text,
                  (synchronized ? "true" : "false"));
   return(summary);
  }

void OpenCsv(const datetime now)
  {
   if(!InpExportCSV)
      return;
   string stamp=TimeToString(now,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   StringReplace(stamp,".","");
   StringReplace(stamp,":","");
   StringReplace(stamp," ","_");
   string filename=SafeFilePart(InpFilePrefix)+"_"+stamp+".csv";
   g_file=FileOpen(filename,FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON,';');
   if(g_file==INVALID_HANDLE)
     {
      PrintFormat("CSV export unavailable: %s error=%d",filename,GetLastError());
      return;
     }
   FileWrite(g_file,"Symbol","Status","Weekday","SessionIndex","StartServerTime",
             "EndServerTime","NextEvent","NextEventServerTime","TradeMode","Synchronized");
   PrintFormat("CSV snapshot: Common\\Files\\%s",filename);
  }

void OnStart()
  {
   datetime now=TimeTradeServer();
   if(now<=0)
      now=TimeCurrent();
   BuildSymbolList();
   if(ArraySize(g_symbols)==0)
     {
      Print("No symbols selected. Nothing was inspected.");
      return;
     }
   OpenCsv(now);
   string chart_summary="Broker Session Schedule Inspector (server time)\n"+TimeLabel(now)+"\n";
   for(int i=0;i<ArraySize(g_symbols);i++)
     {
      string summary=InspectSymbol(g_symbols[i],now);
      if(i<8)
         chart_summary+=summary+"\n";
     }
   if(ArraySize(g_symbols)>8)
      chart_summary+=StringFormat("... plus %d more symbols in Experts/CSV\n",ArraySize(g_symbols)-8);
   Comment(chart_summary);
   if(g_file!=INVALID_HANDLE)
     {
      FileFlush(g_file);
      FileClose(g_file);
      g_file=INVALID_HANDLE;
     }
   PrintFormat("Broker session inspection complete: symbols=%d read_only=true",ArraySize(g_symbols));
  }
