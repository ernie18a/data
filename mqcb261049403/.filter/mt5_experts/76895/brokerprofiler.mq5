//+------------------------------------------------------------------+
//|                                               BrokerProfiler.mq5 |
//|  Prints everything about a symbol that makes the SAME EA behave  |
//|  DIFFERENTLY on another broker: trading hours, contract size,    |
//|  tick value, spread over time, swap, and real session coverage.  |
//|                                                                  |
//|  Why this exists: an EA that works on one broker often trades    |
//|differently on another, and the usual suspects (spread, slippage) |
//|are not always the reason. Trading hours and contract size differ |
//|between brokers for the very same instrument, and every value the |
//|  EA derives from a daily bar or a lot size silently changes with |
//|  them. This utility prints those numbers side by side so you can |
//|  compare two brokers before blaming the strategy.                |
//|                                                                  |
//|  DOES NOT TRADE. Read-only: quotes, symbol properties, history.  |
//+------------------------------------------------------------------+
#property copyright "Boroda"
#property link      "https://www.mql5.com/en/users/boroda13"
#property version   "1.00"
#property strict
#property description "Profiles a symbol on THIS broker: trading hours, contract specs,"
#property description "spread statistics, swap cost and real session coverage."
#property description "Run it on two brokers and compare the printouts. Does not trade."

input int    SpreadSampleSec = 5;    // spread sampling period, seconds (0 = off)
input int    CoverageDays    = 10;   // days of M1 history to measure session coverage
input bool   WriteCsv        = true; // also write spread samples to a CSV file
input string CsvName         = "";   // CSV name ("" = profile_<symbol>_<date>.csv)

string g_csv;
int    g_n      = 0;
long   g_sum    = 0;
long   g_max    = 0;
long   g_min    = 2147483647;

//+------------------------------------------------------------------+
//| Minutes of a day, from a datetime                                 |
//+------------------------------------------------------------------+
int MinOfDay(const datetime t)
{
   MqlDateTime d;
   TimeToStruct(t, d);
   return d.hour * 60 + d.min;
}

string HHMM(const int minutes)
{
   return StringFormat("%02d:%02d", minutes / 60, minutes % 60);
}

//+------------------------------------------------------------------+
//| 1. Trading hours as the SERVER reports them                       |
//|    These differ between brokers for the same instrument, and any  |
//|    value taken from a D1 bar changes with them.                   |
//+------------------------------------------------------------------+
void PrintTradingHours()
{
   Print("---- trading hours (server time) ----");
   string names[] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
   int firstOpen = -1, lastClose = -1;

   for(int day = 0; day < 7; day++)
   {
      string line = "";
      datetime from, to;
      for(int session = 0; ; session++)
      {
         if(!SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK)day, session, from, to))
            break;
         int a = MinOfDay(from), b = MinOfDay(to);
         if(line != "") line += ", ";
         line += HHMM(a) + "-" + HHMM(b);
         if(firstOpen < 0 || a < firstOpen) firstOpen = a;
         if(b > lastClose) lastClose = b;
      }
      if(line == "") line = "closed";
      PrintFormat("  %s : %s", names[day], line);
   }

   if(firstOpen >= 0)
   {
      PrintFormat("  earliest open %s, latest close %s -> %d minutes per day",
                  HHMM(firstOpen), HHMM(lastClose), lastClose - firstOpen);
      if(firstOpen >= 8 * 60)
         Print("  NOTE: no overnight session on this broker. Any value your EA reads from a");
      else
         Print("  NOTE: this symbol has an overnight session. A daily bar here covers more");
      Print("        daily bar (range, open, ATR on D1) will differ from a broker whose");
      Print("        session starts at a different hour, even with identical price data.");
   }
}

//+------------------------------------------------------------------+
//| 2. Contract specification — what one lot actually is              |
//+------------------------------------------------------------------+
void PrintContract()
{
   Print("---- contract specification ----");
   const double contract  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   const double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   const double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   const double point     = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   const int    digits    = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   PrintFormat("  digits %d | point %.*f | tick size %.*f", digits, digits, point, digits, tickSize);
   PrintFormat("  contract size %.2f | tick value %.5f %s",
               contract, tickValue, AccountInfoString(ACCOUNT_CURRENCY));

   if(tickSize > 0)
      PrintFormat("  ONE POINT of price = %.5f %s per lot",
                  tickValue * point / tickSize, AccountInfoString(ACCOUNT_CURRENCY));

   PrintFormat("  volume: min %.2f | max %.2f | step %.2f",
               SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
               SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX),
               SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP));
   PrintFormat("  stops level %d points | freeze level %d points",
               (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL),
               (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL));
   Print("  NOTE: position size computed from a fixed % of equity depends on the value of");
   Print("        one point, not on the lot number. The same lot can mean very different");
   Print("        money on two brokers - compare the line above, not the lots.");
}

//+------------------------------------------------------------------+
//| 3. Swap — the cost of holding, expressed in a comparable way      |
//+------------------------------------------------------------------+
void PrintSwap()
{
   Print("---- swap (cost of holding overnight) ----");
   const long   mode = SymbolInfoInteger(_Symbol, SYMBOL_SWAP_MODE);
   const double sl   = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   const double ss   = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);
   PrintFormat("  swap mode %d | long %.4f | short %.4f | 3-day rollover on %s",
               (int)mode, sl, ss,
               (SymbolInfoInteger(_Symbol, SYMBOL_SWAP_ROLLOVER3DAYS) == WEDNESDAY) ? "Wednesday" : "another weekday");

   const double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(mode == SYMBOL_SWAP_MODE_POINTS && bid > 0 && point > 0)
   {
      // points -> price -> share of price, so two brokers can be compared directly
      PrintFormat("  as %% of price per night: long %.5f%% | short %.5f%%",
                  sl * point / bid * 100.0, ss * point / bid * 100.0);
      PrintFormat("  annualised (x365): long %.2f%% | short %.2f%%",
                  sl * point / bid * 100.0 * 365.0, ss * point / bid * 100.0 * 365.0);
   }
   Print("  NOTE: |long| + |short| is roughly twice the broker markup and does not depend");
   Print("        on the interest rate - it is what you pay for holding, either direction.");
}

//+------------------------------------------------------------------+
//| 4. Session coverage — how much of the day really has quotes       |
//|    A gap-ridden feed silently changes anything measured per day.  |
//+------------------------------------------------------------------+
void PrintCoverage()
{
   PrintFormat("---- session coverage, last %d days of M1 ----", CoverageDays);
   MqlRates r[];
   const int need = CoverageDays * 24 * 60;
   const int got  = CopyRates(_Symbol, PERIOD_M1, 0, need, r);
   if(got <= 0)
   {
      Print("  no M1 history available - open the symbol chart first");
      return;
   }

   int    dayMinutes[32];
   int    dayFirst[32], dayLast[32];
   int    days = 0, prevDay = -1;
   ArrayInitialize(dayMinutes, 0);
   ArrayInitialize(dayFirst, 9999);
   ArrayInitialize(dayLast, -1);

   for(int i = 0; i < got && days < 31; i++)
   {
      MqlDateTime d;
      TimeToStruct(r[i].time, d);
      if(d.day != prevDay) { prevDay = d.day; days++; }
      const int idx = days - 1;
      if(idx < 0 || idx >= 31) continue;
      dayMinutes[idx]++;
      const int m = d.hour * 60 + d.min;
      if(m < dayFirst[idx]) dayFirst[idx] = m;
      if(m > dayLast[idx])  dayLast[idx]  = m;
   }

   int    counted = 0;
   double sumCov  = 0;
   for(int i = 0; i < days; i++)
   {
      if(dayLast[i] < 0 || dayMinutes[i] < 30) continue;   // weekend / holiday
      const int span = dayLast[i] - dayFirst[i] + 1;
      if(span <= 0) continue;
      sumCov += 100.0 * dayMinutes[i] / span;
      counted++;
   }
   if(counted > 0)
      PrintFormat("  %d trading days | average coverage %.0f%% of the traded span",
                  counted, sumCov / counted);
   Print("  NOTE: coverage well below 100% means gaps inside the session. Anything your EA");
   Print("        measures per day (range, average movement) is understated on such a feed.");
}

//+------------------------------------------------------------------+
int OnInit()
{
   Print("=====================================================");
   PrintFormat("BrokerProfiler on %s | server %s | account currency %s",
               _Symbol, AccountInfoString(ACCOUNT_SERVER), AccountInfoString(ACCOUNT_CURRENCY));
   PrintFormat("server time %s | local time %s",
               TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
               TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS));
   PrintFormat("server-local offset %d hours (this shifts every session boundary you code)",
               (int)MathRound((TimeCurrent() - TimeLocal()) / 3600.0));
   Print("=====================================================");

   PrintTradingHours();
   PrintContract();
   PrintSwap();
   PrintCoverage();

   if(WriteCsv)
   {
      g_csv = CsvName;
      if(g_csv == "")
      {
         MqlDateTime d; TimeToStruct(TimeCurrent(), d);
         g_csv = StringFormat("profile_%s_%04d%02d%02d.csv", _Symbol, d.year, d.mon, d.day);
      }
      if(!FileIsExist(g_csv, FILE_COMMON))
      {
         const int h = FileOpen(g_csv, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI, ',');
         if(h != INVALID_HANDLE)
         {
            FileWrite(h, "time", "bid", "ask", "spread_points");
            FileClose(h);
         }
      }
   }

   if(SpreadSampleSec > 0)
   {
      EventSetTimer(SpreadSampleSec);
      PrintFormat("---- sampling spread every %d s. Remove the EA to see the summary. ----",
                  SpreadSampleSec);
   }
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnTimer()
{
   const long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread <= 0) return;

   g_n++;
   g_sum += spread;
   if(spread > g_max) g_max = spread;
   if(spread < g_min) g_min = spread;

   if(WriteCsv && g_csv != "")
   {
      const int h = FileOpen(g_csv, FILE_READ | FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI, ',');
      if(h != INVALID_HANDLE)
      {
         FileSeek(h, 0, SEEK_END);
         FileWrite(h,
                   TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
                   DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits),
                   DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits),
                   (string)spread);
         FileClose(h);
      }
   }
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   if(g_n > 0)
   {
      Print("---- spread summary ----");
      PrintFormat("  %d samples | min %d | average %.1f | max %d points",
                  g_n, (int)g_min, (double)g_sum / g_n, (int)g_max);
      const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      PrintFormat("  average in price terms: %.*f", _Digits, (double)g_sum / g_n * point);
      if(WriteCsv && g_csv != "")
         PrintFormat("  samples written to Common\\Files\\%s", g_csv);
      Print("  NOTE: compare the AVERAGE, not the current value - the current spread depends");
      Print("        on the minute you happened to look at it.");
   }
}

void OnTick() { }
//+------------------------------------------------------------------+
