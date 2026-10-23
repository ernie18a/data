//+------------------------------------------------------------------+
//|                                                TimeServerDST.mqh |
//|                                    Copyright (c) 2024, marketeer |
//|                                            https://forge.mql5.io |
//| rev.0.11 20 Nov 2024                                             |
//+------------------------------------------------------------------+

#include <MQL5Book/MqlError.mqh>
#include <MQL5Book/DateTime.mqh>

#define TZDST_NOW_SCAN    -1 // use as 'srvtime' parameter to skip existing cache and rebuild it

#ifndef TZDST_THRESHOLD
#define TZDST_SELFDEFINED_THRESHOLD
#define TZDST_THRESHOLD 1
// set the threshold to 2+ weeks to collect stats about consistent timezones,
// set to 0 to detect timezone change more promptly, than at default 1,
// but this can show false alerts on weeks with non-standard opening
#endif

//+------------------------------------------------------------------+
//| Server time zone and DST current information                     |
//+------------------------------------------------------------------+
struct ServerTimeZone  // according to history analysis of week opening hours
{
   int offsetGMT;      // time zone offset in seconds against UTC/GMT for current week
   short offsetDST;    // DST correction in seconds (included in offsetGMT, as per MQL5)
   bool supportDST;    // DST changes are detected in the quotes
};

//+------------------------------------------------------------------+
//| Aux struct for week opening hours stats                          |
//+------------------------------------------------------------------+
struct TimeZoneChange
{
  datetime weekstart;
  int before;
  bool DSTb;
  int after;
  bool DSTa;
};

//+------------------------------------------------------------------+
//| Aux conversion from week opening hour to UTC                     |
//+------------------------------------------------------------------+
int HourToUTC(const int current, const bool dst = false)
{
  if(current == INT_MIN) return INT_MIN;
  
  int result = current + 2 + dst; // +2 to get UTC offset
  // if DST is enabled it's shown in offsetGMT according to MT5 rules
  // NB. when DST is enabled, time is shifted forward in the time zone,
  // but for outside it is looked like the time is shifted back
  // (everything in this time zone is happened earlier for others)
  // so to get standard time of the zone we need to add DST
  result %= 24;
     
  // time zones are in the range [UTC-12,UTC+12]
  if(result > 12) result = result - 24;
  return result;
}

int UTCToHour(const int current, const bool dst = false)
{
  if(current == INT_MIN) return INT_MIN;
  const int result = (current + 24 - 2 - dst) % 24;
  return result;
}

//+------------------------------------------------------------------+
//| Analogue of TimeGMTOffset() function for trade server            |
//| Pseudo-code: TimeGMTOffset() = TimeGMT() - TimeLocal()           |
//|                      NB! Do not use in the tester, because there |
//|                  TimeGMT() is always equal to TimeTradeServer()! |
//+------------------------------------------------------------------+
int TimeServerGMTOffset()
{
  return (int)(TimeGMT() - TimeTradeServer());
}

//+------------------------------------------------------------------+
//| Estimate server time DST mode correction from H1 quotes history  |
//+------------------------------------------------------------------+
int TimeServerDaylightSavings(
  const datetime srvtime = 0,
  const int threshold = TZDST_THRESHOLD,
  const double lookupYears = 0.0,
  const string symbol = NULL)
{
  return TimeServerZone(srvtime, threshold, lookupYears, symbol).offsetDST;
}

//+------------------------------------------------------------------+
//| Estimate server time zone offset from H1 quotes history          |
//+------------------------------------------------------------------+
int TimeServerGMTOffsetHistory(
  const datetime srvtime = 0,
  const int threshold = TZDST_THRESHOLD,
  const double lookupYears = 0.0,
  const string symbol = NULL)
{
  return TimeServerZone(srvtime, threshold, lookupYears, symbol).offsetGMT;
}

//+------------------------------------------------------------------+
//| Estimate if server is DST-enabled from H1 quotes history         |
//+------------------------------------------------------------------+
bool TimeServerDaylightSavingsSupported(
  const datetime srvtime = 0,
  const int threshold = TZDST_THRESHOLD,
  const double lookupYears = 0.0,
  const string symbol = NULL)
{
  return TimeServerZone(srvtime, threshold, lookupYears, symbol).supportDST;
}

#define WRAPAROUND(LIMIT, VALUE) ((VALUE + LIMIT) % LIMIT)
#define WRAP24(V) WRAPAROUND(24, V)
#define SYMBOLNULL(S) ((S) != NULL ? (S) : _Symbol)

//+------------------------------------------------------------------+
//| Estimate server time zone and DST mode from H1 quotes history    |
//+------------------------------------------------------------------+
ServerTimeZone TimeServerZone(
  const datetime srvtime = 0,     // by default, current time, but can specify a moment in the past
  const int threshold = TZDST_THRESHOLD,
  const double lookupYears = 0.0, // by default, all available bars from srvtime, 3 year looks enough
  const string symbol = NULL)     // can use symbol in services
{
  const int year = 365 * 24 * 60 * 60;
  const int hour = 3600;
  
  // result variables
  static ServerTimeZone st = {};
  ServerTimeZone empty = {INT_MIN, SHORT_MIN, false};
  int utc = INT_MIN;
  bool DST = false;
  
  datetime array[];
  
  static TimeZoneChange changes[];
  static int hours[24] = {};
  static datetime cacheTime;
  static string cacheSymbol;
  static int cacheThreshold;
  static int lastindex = -1;
  static datetime lastrequest = LONG_MAX;

  ResetLastError();

  datetime curtime = srvtime;
  if(curtime <= 0 || curtime > fmax(TimeCurrent(), TimeTradeServer()))
  {
     curtime = fmax(TimeCurrent(), TimeTradeServer());
  }
  
  curtime = fmin(curtime, (datetime)SeriesInfoInteger(symbol, PERIOD_H1, SERIES_LASTBAR_DATE));
  
  // cache validation and building
  
  if(srvtime < 0 || WeekIndex(curtime) > WeekIndex(cacheTime)
     || cacheSymbol != SYMBOLNULL(symbol)
     || cacheThreshold != threshold)
  {
     #ifdef PRINT_DST_DETAILS
     if(ArraySize(changes))
     {
        Print("TZ/DST cache is dropped");
     }
     #endif
     cacheTime = 0;       // drop cache if exists
     ArrayFree(changes);
     ArrayInitialize(hours, 0);
     st = empty;
     lastindex = -1;
     lastrequest = LONG_MAX;
     
     // if the symbol is not a major Forex pair or Metal, then calculations may go wrong
     #ifdef PRINT_DST_DETAILS
     if((SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE) != SYMBOL_CALC_MODE_FOREX
     && SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE) != SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE
     && SymbolInfoInteger(symbol, SYMBOL_INDUSTRY) != INDUSTRY_COMMODITIES_PRECIOUS)
     || !(SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE) == "USD" || SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT) == "USD"))
     {
        Print("It's recommended to apply TimeServerZone function to a major Forex currency pair or precious Metal");
     }
     #endif
   
     const bool metal = SymbolInfoInteger(symbol, SYMBOL_INDUSTRY) == INDUSTRY_COMMODITIES_PRECIOUS ||
        StringFind(SymbolInfoString(symbol, SYMBOL_DESCRIPTION), "Gold") == 0;
   
     if((lookupYears &&
        CopyTime(symbol, PERIOD_H1, (datetime)((long)curtime - (long)(lookupYears * year)), curtime + 48 * hour, array) > 0)
     || CopyTime(symbol, PERIOD_H1, 0, Bars(symbol, PERIOD_H1), array) > 0)
     {
        // approx. 6000 bars per year should be acquired here
        const int n = ArraySize(array);
        #ifdef PRINT_DST_DETAILS
        PrintFormat("Got %d H1 bars, ~%d days from %s to %s", n, n / 24, (string)array[0], (string)array[n - 1]);
        #endif
   
        bool dst[24] = {};
        int current = INT_MIN, previous = INT_MIN;
        for(int i = 1; i < n; ++i)
        {
           // wait for a gap of more than 1 day, fast-forward to a new day after weekend or holidays
           if(array[i] - array[i - 1] <= 24 * hour) continue;
        
           ENUM_DAY_OF_WEEK weekday = TimeDayOfWeek(array[i]);
           // skip all days except Sunday and Monday
           if(weekday > MONDAY) continue;
           // lets analyze the first H1 bar of the trading week
           // find out an hour for the first bar after weekend
           previous = current;
           current = _TimeHour();
           
           // if US DST switched on, eliminate it so that 'current' hour is in STD time always
           if(_TimeMonth() >= 3 && _TimeMonth() <= 11)
           {
             int iYear = _TimeYear();
             // use magical formulae from https://www.webexhibits.org/daylightsaving/i.html
             MqlDateTime dt1 = {iYear, 03, (14 - (1 + 5 * iYear / 4) % 7)};  // the second Sunday of March for the US switch
             MqlDateTime dt2 = {iYear, 11, (07 - (1 + 5 * iYear / 4) % 7)};  // the first Sunday of November for the US switch
   
             datetime dst_begin = StructToTime(dt1);
             datetime dst_end   = StructToTime(dt2);
   
             if(array[i] >= dst_begin && array[i] < dst_end)
             {
               current = WRAP24(current + 1); // compensate the effect of US switch on a server time, with +1 hour it's now STD all year round
             }
           }
   
           // As a rule of thumb, metals start trading week 1 hour later than Forex pairs (UTC STD - 23:00 instead of 22:00)
           // since the algo should normally work on a Forex pair, subtract 1 hour, as suggested by @amrali
           if(metal)
           {
             current = WRAP24(current - 1);
           }
           
           if(previous != current) // keep track of TZ changes
           {
             TimeZoneChange change[1] =
             {{
                array[i],
                HourToUTC(previous/*, it's STD */),
                WRAP24(previous - 1) == current,  // before
                HourToUTC(current/*, it's STD */),
                previous == WRAP24(current - 1),  // after
             }};
             ArrayInsert(changes, change, ArraySize(changes)); // caching
           }
           
           // collect stats for opening hours
           hours[current]++;
           
           // now skip 2 days to check next week
           i += 48;
        }
        
        #ifdef PRINT_DST_DETAILS
        Print("Week opening hours stats:");
        ArrayPrint(hours);
        Print("Time Zone changes (UTC±X before/after weekstart):");
        ArrayPrint(changes);
        #endif
        
        int tz = 0, tzdst = 0;
        for(int i = 0; i < 24; ++i)
        {
          if(hours[i] > threshold)
          {
            tz++;
            if(hours[WRAP24(i - 1)] > threshold)
            {
              dst[i] = true;
              st.supportDST = true; // DST is most likely supported (or broker changed time zone many times)
              tzdst++;
            }
          }
        }
        
        #ifdef PRINT_DST_DETAILS
        PrintFormat("%d different timezones detected in quotes, %d DST candidates", tz, tzdst);
        #endif
        
        cacheTime = array[n - 1];
        cacheSymbol = SYMBOLNULL(symbol);
        cacheThreshold = threshold;
        #ifdef PRINT_DST_DETAILS
        PrintFormat("TZ/DST cached on %s till %s, t=%d", cacheSymbol, (string)cacheTime, cacheThreshold);
        #endif
     }
     else
     {
        PrintFormat("Can't read quotes for %s, error: %d %s", (string)curtime, _LastError, E2S(_LastError));
        return empty;
     }
  }
  
  // cache reading
  
  if(cacheTime && ArraySize(changes))
  {
     if(curtime <= changes[0].weekstart)
     {
        SetUserError(2); // not found, too early date requested
        return empty;
     }
  
     int i;
     
     for(i = (curtime >= lastrequest ? lastindex : 0); i < ArraySize(changes); i++)
     {
        if(WeekStart(changes[i].weekstart) > curtime && hours[UTCToHour(changes[i].before)] > threshold)
        {
           utc = changes[i].before;
           DST = changes[i].DSTb;
           break;
        }
     }
     if(i == ArraySize(changes))
     {
        i = ArraySize(changes) - 1;
        utc = changes[i].after;
        DST = changes[i].DSTa;
     }

     #ifdef PRINT_DST_DETAILS
     PrintFormat("Server time offset: UTC%+d %s", utc, DST ? "DST" : "STD");
     #endif
     
     lastrequest = curtime;
     lastindex = i;
  }
  
  // if called for online time, we can check against built-in functions for refinement
  if(WeekIndex(TimeTradeServer()) == WeekIndex(curtime)
  && TerminalInfoInteger(TERMINAL_CONNECTED) && !MQLInfoInteger(MQL_TESTER))
  {
     if(DST && TimeServerGMTOffset() == (utc - 1) * -hour)
     {
        utc -= 1;
        DST = false;
        #ifdef PRINT_DST_DETAILS
        PrintFormat("Online time zone change: UTC%+d STD", utc);
        #endif
     }
     else
     if(!DST && TimeServerGMTOffset() == (utc + 1) * -hour)
     {
        utc += 1;
        DST = true;
        #ifdef PRINT_DST_DETAILS
        PrintFormat("Online time zone change: UTC%+d DST", utc);
        #endif
     }
  }
  
  st.offsetGMT = -utc * hour;
  st.offsetDST = (short)(-DST * hour);
  // keep st.supportDST as is, filled during cache building
  return st;
}

//+------------------------------------------------------------------+
//| Returns the zero-based absolute week number since 1 Jan 1970     |
//+------------------------------------------------------------------+
int WeekIndex(const datetime _t)
{
  return (int)((_t + 345600) / 604800); // adding duration of 4 days to get weeks aligned by Sundays
}

//+------------------------------------------------------------------+
//| Returns start of the week (Sunday) containing the specified time |
//+------------------------------------------------------------------+
datetime WeekStart(const datetime _t)
{
  return(_t - (_t + 345600) % 604800);
}

#undef SYMBOLNULL
#undef WRAP24
#undef WRAPAROUND
#ifdef TZDST_SELFDEFINED_THRESHOLD
   #undef TZDST_SELFDEFINED_THRESHOLD
   #undef TZDST_THRESHOLD
#endif

//+------------------------------------------------------------------+
/*
  example code:
  
   #define PRINT_DST_DETAILS
   #define TZDST_THRESHOLD 0
   #include "TimeServerDST.mqh"
    
   void OnStart()
   {
     PRTF(TimeServerDaylightSavings());
   }
  
  example output:
   
   Got 20503 H1 bars, ~854 days from 2021.05.21 08:00:00 to 2024.11.05 20:00:00
   Week opening hours stats:
    62 115   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0
   Time Zone changes (UTC±X before/after weekstart):
               [weekstart]    [before] [DSTb] [after] [DSTa]
   [0] 2021.05.24 01:00:00 -2147483648  false       3  false
   [1] 2021.11.01 00:00:00           3   true       2  false
   [2] 2022.03.28 01:00:00           2  false       3   true
   [3] 2022.10.31 00:00:00           3   true       2  false
   [4] 2023.03.27 01:00:00           2  false       3   true
   [5] 2023.10.30 00:00:00           3   true       2  false
   [6] 2024.04.01 01:00:00           2  false       3   true
   [7] 2024.10.28 00:00:00           3   true       2  false
   2 different timezones detected in quotes, 1 DST candidates
   Server time offset: UTC+2 STD
   TZ/DST cached on XAUUSD till 2024.11.05 20:00:00
   TimeServerDaylightSavings()=0 / ok

*/
//+------------------------------------------------------------------+
