//+------------------------------------------------------------------+
//|                                              CalendarExport.mq5  |
//|                        Economic calendar -> CSV, for MT5         |
//+------------------------------------------------------------------+
#property copyright "CalendarExport"
#property version   "1.00"
#property description "Exports MetaTrader 5's built-in economic calendar to a CSV file, so"
#property description "external tools can read it. MT5's calendar is available to MQL5 but NOT"
#property description "to the Python bridge, to Excel, or to anything outside the terminal -"
#property description "this utility is that missing bridge."
#property description ""
#property description "Strictly read-only: it never opens, closes or modifies any position."
#property strict

//+------------------------------------------------------------------+
//| WHY THIS EXISTS                                                   |
//|                                                                   |
//| MetaTrader 5 ships a full economic calendar and MQL5 can read it  |
//| through CalendarValueHistory(). Nothing else can. The Python      |
//| package "MetaTrader5" exposes prices, symbols, orders, positions  |
//| and history - but no calendar function. So any research script,   |
//| dashboard, bot or spreadsheet that needs to know when the next    |
//| high-impact release lands has no way to ask the terminal.         |
//|                                                                   |
//| This Expert Advisor sits on any chart and periodically writes the |
//| calendar to a CSV file inside MQL5\Files. Whatever lives outside  |
//| the terminal reads that file.                                     |
//|                                                                   |
//| FOUR THINGS IT DOES THAT A QUICK VERSION WOULD GET WRONG          |
//|                                                                   |
//| 1. IT WRITES UTF-8, NOT THE LOCAL CODEPAGE. Event names come      |
//|    localised in the terminal's language, so on a non-English MT5  |
//|    they contain accented or non-Latin characters. Written with    |
//|    FILE_ANSI they become bytes that are not valid UTF-8, and any  |
//|    consumer that assumes UTF-8 - which is most of them - either   |
//|    throws or silently mangles the name. Measured on an Italian    |
//|    terminal: the file could not be parsed at all without knowing  |
//|    the codepage in advance.                                       |
//|                                                                   |
//| 2. IT SORTS BY TIME. The calendar is queried once per currency,   |
//|    so the natural output is grouped by currency and jumps back    |
//|    and forth in time. A consumer asking "what is the next event"  |
//|    would have to sort it first, or read the wrong row.            |
//|                                                                   |
//| 3. IT WRITES THE WHOLE FILE IN ONE CALL. The file is built in     |
//|    memory and written once. A reader that opens it while it is    |
//|    being appended to would see a truncated list and believe it.   |
//|    The first line carries a timestamp and an event count, so a    |
//|    consumer can tell a fresh file from a stale one - and notice   |
//|    that this EA was detached, instead of showing an old calendar  |
//|    as if it were current.                                         |
//|                                                                   |
//| 4. IT DECODES HTML ENTITIES IN EVENT NAMES. The terminal stores   |
//|    them escaped: "CFTC S&P 500 ..." comes back as "S&amp;P".      |
//|    Written through unchanged, every consumer receives it wrong.   |
//|                                                                   |
//| NOTE ON LANGUAGE: event names are returned in the TERMINAL's      |
//| language and there is no way to ask for another. If you need a    |
//| key that is stable across languages and installations, use the    |
//| event_id column - that is why it is there.                        |
//+------------------------------------------------------------------+

input group "--- What to include ---"
input string InpCurrencies   = "USD,EUR";  // Currencies, comma separated (empty = all)
input int    InpHoursAhead   = 48;         // How many hours ahead to look
input int    InpHoursBack    = 3;          // How many hours back (to catch just-released data)
input int    InpMinImportance = 2;         // Minimum importance: 0=none 1=low 2=medium 3=high

input group "--- Output ---"
input string InpFile         = "calendar_export.csv";  // Written to this terminal's MQL5\Files
input int    InpRefreshSec   = 300;        // How often the file is rewritten (min 30)
input bool   InpUtf8         = true;       // UTF-8 (recommended). false = terminal codepage

//--- One row of the output, kept so the whole set can be sorted by time.
struct Event
{
   datetime time;
   string   currency;
   string   importance;
   string   name;
   string   forecast;
   string   previous;
   string   actual;
   long     event_id;
};

//--- Currencies belong to the COUNTRY, not to the event: MqlCalendarEvent
//--- exposes country_id and the currency has to be looked up separately.
//--- Cached because thousands of values share a handful of countries and
//--- every lookup is a call into the terminal.
long   g_countryIds[];
string g_currencies[];

//+------------------------------------------------------------------+
int OnInit()
{
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
      Print("CalendarExport: terminal not connected yet - the calendar may be empty ",
            "until it is. The file will refresh on the next timer.");

   EventSetTimer(InpRefreshSec > 30 ? InpRefreshSec : 30);
   Write();                                  // immediately, without waiting for the timer
   Print("CalendarExport: running. Currencies=",
         (InpCurrencies == "" ? "(all)" : InpCurrencies),
         ", window -", InpHoursBack, "h/+", InpHoursAhead, "h, refresh every ",
         (InpRefreshSec > 30 ? InpRefreshSec : 30), "s -> ", InpFile);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason) { EventKillTimer(); }
void OnTick() {}
void OnTimer() { Write(); }

//+------------------------------------------------------------------+
//| Currency of a country, cached.                                    |
//+------------------------------------------------------------------+
string CurrencyOf(const long countryId)
{
   for(int i = 0; i < ArraySize(g_countryIds); i++)
      if(g_countryIds[i] == countryId)
         return g_currencies[i];

   MqlCalendarCountry c;
   string cur = CalendarCountryById(countryId, c) ? c.currency : "";
   int n = ArraySize(g_countryIds);
   ArrayResize(g_countryIds, n + 1);
   ArrayResize(g_currencies, n + 1);
   g_countryIds[n] = countryId;
   g_currencies[n] = cur;
   return cur;
}

//+------------------------------------------------------------------+
//| Importance as a word. EnumToString would emit                     |
//| CALENDAR_IMPORTANCE_HIGH, which every consumer then has to strip. |
//+------------------------------------------------------------------+
string ImportanceWord(const ENUM_CALENDAR_EVENT_IMPORTANCE imp)
{
   switch(imp)
   {
      case CALENDAR_IMPORTANCE_LOW:      return "LOW";
      case CALENDAR_IMPORTANCE_MODERATE: return "MEDIUM";
      case CALENDAR_IMPORTANCE_HIGH:     return "HIGH";
   }
   return "NONE";
}

//+------------------------------------------------------------------+
//| MT5 stores calendar event names HTML-ESCAPED. Measured on a live  |
//| terminal: "CFTC S&P 500 Non-Commercial Net Positions" comes back  |
//| as "CFTC S&amp;P 500 ...". Written straight to CSV that ampersand |
//| reaches every consumer wrong, and a consumer that unescapes it    |
//| itself would then also unescape names that legitimately contain   |
//| the sequence. Decoding here, once, at the only place that knows   |
//| the data came from the calendar, is the correct level.            |
//|                                                                   |
//| "&amp;" is decoded LAST on purpose: doing it first would turn a   |
//| literal "&amp;lt;" into "<" - the classic double-decoding bug.    |
//+------------------------------------------------------------------+
string Unescape(string s)
{
   // Some names arrive from the terminal with trailing spaces ("Fed Governor Waller
   // Speaks "). In a CSV field that is a nuisance for whoever reads it, and no consumer
   // expects to have to strip it.
   StringTrimLeft(s);
   StringTrimRight(s);
   StringReplace(s, "&nbsp;", " ");
   StringReplace(s, "&quot;", "\"");
   StringReplace(s, "&apos;", "'");
   StringReplace(s, "&#39;",  "'");
   StringReplace(s, "&lt;",   "<");
   StringReplace(s, "&gt;",   ">");
   StringReplace(s, "&amp;",  "&");
   return s;
}

//+------------------------------------------------------------------+
//| Proper CSV quoting. The naive fix - replacing commas with         |
//| semicolons - silently alters the event name; quoting preserves it.|
//+------------------------------------------------------------------+
string Csv(string s)
{
   if(StringFind(s, ",") < 0 && StringFind(s, "\"") < 0 && StringFind(s, "\n") < 0)
      return s;
   StringReplace(s, "\"", "\"\"");
   return "\"" + s + "\"";
}

//+------------------------------------------------------------------+
void Collect(const string currency, const datetime from, const datetime to,
             Event &out[])
{
   MqlCalendarValue values[];
   int n = CalendarValueHistory(values, from, to, NULL,
                                (currency == "" ? NULL : currency));
   for(int i = 0; i < n; i++)
   {
      MqlCalendarEvent ev;
      if(!CalendarEventById(values[i].event_id, ev))
         continue;
      if((int)ev.importance < InpMinImportance)
         continue;

      int k = ArraySize(out);
      ArrayResize(out, k + 1);
      out[k].time       = values[i].time;
      out[k].currency   = CurrencyOf(ev.country_id);
      out[k].importance = ImportanceWord(ev.importance);
      out[k].name       = Unescape(ev.name);
      out[k].event_id   = (long)values[i].event_id;
      out[k].forecast   = values[i].HasForecastValue()
                          ? DoubleToString(values[i].GetForecastValue(), 3) : "";
      out[k].previous   = values[i].HasPreviousValue()
                          ? DoubleToString(values[i].GetPreviousValue(), 3) : "";
      out[k].actual     = values[i].HasActualValue()
                          ? DoubleToString(values[i].GetActualValue(), 3) : "";
   }
}

//+------------------------------------------------------------------+
//| Insertion sort by time. A few hundred rows at most, and it keeps  |
//| equal timestamps in the order the terminal returned them.         |
//+------------------------------------------------------------------+
void SortByTime(Event &a[])
{
   for(int i = 1; i < ArraySize(a); i++)
   {
      Event key = a[i];
      int j = i - 1;
      while(j >= 0 && a[j].time > key.time)
      {
         a[j + 1] = a[j];
         j--;
      }
      a[j + 1] = key;
   }
}

//+------------------------------------------------------------------+
//| UTF-8 needs FILE_BIN: FILE_TXT writes either the local codepage   |
//| (FILE_ANSI) or UTF-16 (FILE_UNICODE), and neither is what a       |
//| Python, Excel or JavaScript consumer expects by default.          |
//+------------------------------------------------------------------+
bool WriteFile(const string text)
{
   if(!InpUtf8)
   {
      int t = FileOpen(InpFile, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(t == INVALID_HANDLE)
         return false;
      FileWriteString(t, text);
      FileClose(t);
      return true;
   }

   int h = FileOpen(InpFile, FILE_WRITE | FILE_BIN);
   if(h == INVALID_HANDLE)
      return false;
   uchar bytes[];
   int n = StringToCharArray(text, bytes, 0, -1, CP_UTF8);
   if(n > 0)
      n--;                                   // drop the terminating null
   if(n > 0)
      FileWriteArray(h, bytes, 0, n);
   FileClose(h);
   return true;
}

//+------------------------------------------------------------------+
void Write()
{
   // Server clock here too, not the last tick: with the market closed the window would
   // slide backwards along with the frozen clock, and the file would stop containing
   // Monday's events.
   datetime now  = TimeTradeServer();
   datetime from = now - (datetime)InpHoursBack * 3600;
   datetime to   = now + (datetime)InpHoursAhead * 3600;

   Event rows[];
   string list[];
   int nc = StringSplit(InpCurrencies, ',', list);
   if(nc <= 0)
      Collect("", from, to, rows);            // empty input = every currency
   else
      for(int c = 0; c < nc; c++)
      {
         string cur = list[c];
         StringTrimLeft(cur);
         StringTrimRight(cur);
         if(cur != "")
            Collect(cur, from, to, rows);
      }

   SortByTime(rows);

   // Built in memory and written in one call: a consumer that reads the file while it is
   // being appended to would see a truncated list and have no way of knowing.
   string text = "# CalendarExport  updated=" +
                 TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) +
                 "  server_utc_offset_hours=" +
                 IntegerToString((int)((TimeCurrent() - TimeGMT()) / 3600)) +
                 "  events=" + IntegerToString(ArraySize(rows)) + "\r\n";
   text += "time_server,currency,importance,event,forecast,previous,actual,event_id\r\n";

   for(int i = 0; i < ArraySize(rows); i++)
      text += TimeToString(rows[i].time, TIME_DATE | TIME_MINUTES)
              + "," + Csv(rows[i].currency)
              + "," + rows[i].importance
              + "," + Csv(rows[i].name)
              + "," + rows[i].forecast
              + "," + rows[i].previous
              + "," + rows[i].actual
              + "," + IntegerToString(rows[i].event_id) + "\r\n";

   if(!WriteFile(text))
      Print("CalendarExport: cannot write ", InpFile, " - error ", GetLastError());
}
//+------------------------------------------------------------------+
