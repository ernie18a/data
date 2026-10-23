//+------------------------------------------------------------------+
//|                                                    TickAudit.mq5 |
//|                                                                  |
//|   Where does your real tick history actually start, and where    |
//|   are the holes in it?                                           |
//|                                                                  |
//|   The strategy tester prints a single "History Quality" figure   |
//|   after the test has already run, and it does not say which      |
//|   months were the problem. This script asks the question first.  |
//|   For every month it reports how many days carry real ticks, how |
//|   many M1 bars exist, and whether the tester would have to       |
//|   invent ticks for that month.                                   |
//|                                                                  |
//|   A month with M1 bars but no ticks is the dangerous one. The    |
//|   tester will still run, it will still show a curve, and the     |
//|   ticks it used were generated from the bars. Grid, martingale   |
//|   and scalping strategies look far better on generated ticks     |
//|   than they do on real ones.                                     |
//|                                                                  |
//|   Attach to a chart, read the Experts tab, then choose your test |
//|   start date knowing what is behind it.                          |
//+------------------------------------------------------------------+
#property copyright "Ayaz Kakepoto"
#property link      "https://www.mql5.com/en/users/ayazkakepoto"
#property version   "1.00"
#property script_show_inputs

input int  InpMonthsBack   = 24;    // How many months back to audit
input bool InpFullScan     = false; // Check every day (slow) instead of sampling
input int  InpSampleDays   = 6;     // Days sampled per month when not a full scan
input int  InpWaitSeconds  = 60;    // How long to wait for tick history to download
input bool InpWriteCSV     = false; // Also write the month table to CSV

//--- Retrying a tick request helps while the terminal is still downloading,
//--- and wastes time on a symbol the broker holds no ticks for at all. This
//--- counts days in a row where retrying changed nothing; once it reaches
//--- the limit the script stops retrying for the rest of the run.
int       g_retryMisses = 0;
const int RETRY_GIVE_UP = 3;

//--- one month of findings
struct Month
  {
   int               year;
   int               mon;
   int               daysChecked;    // trading days we looked at
   int               daysWithTicks;  // of those, how many had at least one tick
   int               daysWithBars;   // of those, how many had M1 bars
   long              tickCount;      // ticks seen on the days we looked at
   long              barCount;       // M1 bars on the days we looked at
  };

//+------------------------------------------------------------------+
void OnStart()
  {
   if(InpMonthsBack <= 0)
     {
      Print("TickAudit: months to audit must be above zero.");
      return;
     }

   PrintFormat("TickAudit: %s - asking the terminal for tick history, please wait...", _Symbol);

//--- a symbol that is not in Market Watch answers no history request at all,
//--- and telling the user to go and add it by hand is a poor way to spend
//--- their time when the script can do it itself
   if(!SymbolSelect(_Symbol, true))
     {
      PrintFormat("TickAudit: %s is not available on this account.", _Symbol);
      return;
     }
   Sleep(1000);

//--- A history request cannot be interrupted, and when the terminal is in the
//--- middle of downloading this symbol's tick history the request waits for
//--- the download. On a symbol with a lot of ticks the first run can take
//--- several minutes; runs after that are quick because the cache is warm.
//--- Saying so beforehand is the difference between "slow" and "hung".
   Print("TickAudit: the first run on a symbol can take several minutes while the terminal");
   Print("           downloads its tick history. Later runs on the same symbol are quick.");

//--- a failed warm-up is worth reporting, but it is not worth stopping for.
//--- The recent days can be empty on a symbol that has stopped trading while
//--- the older months are complete, and those are exactly the months the
//--- caller is asking about.
   if(!WarmUp())
      Print("TickAudit: carrying on anyway - the table below is built from whatever the terminal has.");

   datetime now = TimeCurrent();
   MqlDateTime nowStruct;
   TimeToStruct(now, nowStruct);

   Month months[];
   ArrayResize(months, InpMonthsBack);

   //--- walk backwards from the current month
   int y = nowStruct.year;
   int m = nowStruct.mon;
   for(int k = 0; k < InpMonthsBack; k++)
     {
      months[k].year = y;
      months[k].mon  = m;
      AuditMonth(months[k], now);

      if(IsStopped())
         return;

      m--;
      if(m < 1)
        {
         m = 12;
         y--;
        }
     }

   Report(months);
  }

//+------------------------------------------------------------------+
//| The first call for tick history often returns nothing while the   |
//| terminal fetches it from the server. Ask, wait, ask again.        |
//+------------------------------------------------------------------+
bool WarmUp()
  {
   MqlTick  probe[];
   MqlRates bars[];
   datetime to   = TimeCurrent();
   datetime from = to - 86400 * 3;

//--- Two different silences look the same from here. If nothing at all comes
//--- back, the terminal is still connecting or downloading, and waiting is the
//--- right thing to do. If bars come back and ticks do not, the server has
//--- answered, and the answer is that there are no ticks: waiting any longer
//--- only makes a tickless symbol take minutes to audit instead of seconds.
//--- The wait is measured in seconds on the clock, not in attempts. A single
//--- history call can block for several seconds on a symbol the terminal is
//--- still fetching, and counting attempts turned a sixty second wait into
//--- four silent minutes on BTCUSD before this was changed.
   int  barsSeen = 0;
   uint started  = GetTickCount();
   uint lastNote = started;
   uint budget   = (uint)InpWaitSeconds * 1000;

   while(GetTickCount() - started < budget)
     {
      if(IsStopped())
         return(false);

      int got = CopyTicksRange(_Symbol, probe, COPY_TICKS_ALL,
                               (ulong)from * 1000, (ulong)to * 1000);
      if(got > 0)
         return(true);

      int err = GetLastError();
      ResetLastError();

      if(CopyRates(_Symbol, PERIOD_M1, from, to, bars) > 0)
        {
         barsSeen++;
         if(barsSeen >= 3)
           {
            PrintFormat("TickAudit: %s returns bars but no ticks for the last three days (error %d). "
                        "The broker is answering and holds no recent tick history for this symbol.",
                        _Symbol, err);
            return(false);
           }
        }

      //--- say something every ten seconds, so a slow symbol does not look like a hang
      if(GetTickCount() - lastNote >= 10000)
        {
         PrintFormat("TickAudit: still waiting for %s history, %d s so far...",
                     _Symbol, (int)((GetTickCount() - started) / 1000));
         lastNote = GetTickCount();
        }
      Sleep(1000);
     }

   PrintFormat("TickAudit: nothing arrived for %s in %d seconds, neither bars nor ticks. "
               "Check the connection and that the symbol is offered on this account.",
               _Symbol, InpWaitSeconds);
   return(false);
  }

//+------------------------------------------------------------------+
void AuditMonth(Month &out, const datetime now)
  {
   out.daysChecked   = 0;
   out.daysWithTicks = 0;
   out.daysWithBars  = 0;
   out.tickCount     = 0;
   out.barCount      = 0;

   int lastDay = DaysInMonth(out.year, out.mon);

   //--- when sampling, spread the sample days evenly through the month
   int step = 1;
   if(!InpFullScan && InpSampleDays > 0 && InpSampleDays < lastDay)
      step = lastDay / InpSampleDays;
   if(step < 1)
      step = 1;

   for(int day = 1; day <= lastDay; day += step)
     {
      datetime dayStart = MakeTime(out.year, out.mon, day);
      if(dayStart > now)
         break;

      datetime dayEnd = dayStart + 86399;

      //--- a removed script should stop at the next day, not at the end of the audit
      if(IsStopped())
         return;

      //--- a heartbeat every fifteen seconds; a slow symbol should never look hung
      static uint lastBeat = 0;
      if(lastBeat == 0)
         lastBeat = GetTickCount();
      if(GetTickCount() - lastBeat >= 15000)
        {
         PrintFormat("TickAudit: still working, now on %04d.%02d ...", out.year, out.mon);
         lastBeat = GetTickCount();
        }

      MqlRates bars[];
      int gotBars = CopyRates(_Symbol, PERIOD_M1, dayStart, dayEnd, bars);

      //--- The first request for a day's ticks often returns nothing because
      //--- the terminal is still fetching them from the server. One ask is not
      //--- an answer. Where bars prove the day traded, ask again a few times
      //--- before writing the day down as tickless; where there are no bars
      //--- either, one ask is plenty, the day is empty.
      MqlTick ticks[];
      int gotTicks = 0;
      int tries    = (gotBars > 0 && g_retryMisses < RETRY_GIVE_UP) ? 4 : 1;
      for(int t = 0; t < tries; t++)
        {
         gotTicks = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL,
                                   (ulong)dayStart * 1000, (ulong)dayEnd * 1000);
         if(gotTicks > 0)
            break;
         if(t < tries - 1)
            Sleep(750);
        }
      if(gotTicks > 0)
         g_retryMisses = 0;          // downloads are arriving, keep retrying elsewhere
      else if(tries > 1)
         g_retryMisses++;            // retried and got nothing, one strike

      //--- A day with neither bars nor ticks was not a trading day, so it does
      //--- not belong in the count. Deciding that from the data rather than
      //--- from the calendar is what lets this work on crypto, where Saturday
      //--- and Sunday trade normally, and on symbols with their own holidays.
      if(gotTicks <= 0 && gotBars <= 0)
         continue;

      out.daysChecked++;
      if(gotTicks > 0)
        {
         out.daysWithTicks++;
         out.tickCount += gotTicks;
        }
      if(gotBars > 0)
        {
         out.daysWithBars++;
         out.barCount += gotBars;
        }
     }
  }

//+------------------------------------------------------------------+
//| A month where bars exist but ticks do not is the one that quietly |
//| ruins a backtest, so it gets its own wording.                     |
//+------------------------------------------------------------------+
string Verdict(const Month &mo)
  {
   if(mo.daysChecked == 0)
      return("nothing on this terminal");
   if(mo.daysWithTicks == 0 && mo.daysWithBars == 0)
      return("nothing at all");
   if(mo.daysWithTicks == 0)
      return("GENERATED TICKS - bars only");
   if(mo.daysWithTicks < mo.daysChecked)
      return("partial - holes in the ticks");
   return("real ticks");
  }

//+------------------------------------------------------------------+
void Report(const Month &months[])
  {
   int n = ArraySize(months);

   Print("------------------------------------------------------------------");
   PrintFormat("TickAudit  %s", _Symbol);
//--- Both of these come back as zero when the terminal has no answer, and
//--- zero formats as 1970.01.01, which reads like a bug rather than a blank.
   datetime firstLocal  = (datetime)SeriesInfoInteger(_Symbol, PERIOD_M1, SERIES_FIRSTDATE);
   datetime firstServer = (datetime)SeriesInfoInteger(_Symbol, PERIOD_M1, SERIES_SERVER_FIRSTDATE);
   PrintFormat("  bar history on this terminal starts  %s",
               firstLocal  > 0 ? TimeToString(firstLocal,  TIME_DATE) : "unknown");
   PrintFormat("  the server says it holds bars from   %s",
               firstServer > 0 ? TimeToString(firstServer, TIME_DATE) : "unknown");
   PrintFormat("  mode: %s", InpFullScan ? "every trading day" :
               StringFormat("sampling about %d days per month", InpSampleDays));
   Print("------------------------------------------------------------------");
   Print("  month     days  with ticks  with bars       ticks   verdict");

//--- an empty table with no explanation is the least useful thing this could print
   int monthsWithData = 0;
   for(int k = 0; k < n; k++)
      if(months[k].daysChecked > 0)
         monthsWithData++;

   if(monthsWithData == 0)
     {
      Print("  Nothing found. Not a single day in this range carried bars or ticks.");
      Print("  Either the symbol is not served by this account, or the range is older");
      Print("  than anything the broker keeps. Try a smaller value for months back.");
      Print("------------------------------------------------------------------");
      return;
     }

   //--- Oldest first reads more naturally than newest first. Months with
   //--- nothing in them are printed rather than skipped: a gap in the table
   //--- reads as an oversight, while a stated "nothing on this terminal"
   //--- tells the reader the history simply was not downloaded.
   for(int k = n - 1; k >= 0; k--)
     {
      PrintFormat("  %04d.%02d  %5d  %10d  %9d  %10d   %s",
                  months[k].year, months[k].mon,
                  months[k].daysChecked, months[k].daysWithTicks, months[k].daysWithBars,
                  (int)months[k].tickCount, Verdict(months[k]));
     }

   Print("------------------------------------------------------------------");

   //--- the one line most people came for
   int firstRealIndex = -1;
   for(int k = n - 1; k >= 0; k--)
     {
      if(months[k].daysChecked > 0 && months[k].daysWithTicks == months[k].daysChecked)
        {
         firstRealIndex = k;
         break;
        }
     }

   if(firstRealIndex < 0)
      Print("  No month in this range had real ticks on every day checked.");
   else
      PrintFormat("  Unbroken real ticks begin in %04d.%02d. Starting a real-tick test before "
                  "that date means the tester invents the missing ticks.",
                  months[firstRealIndex].year, months[firstRealIndex].mon);

   int badMonths = 0;
   for(int k = 0; k < n; k++)
      if(months[k].daysChecked > 0 && months[k].daysWithTicks == 0 && months[k].daysWithBars > 0)
         badMonths++;

   if(badMonths > 0)
      PrintFormat("  %d month(s) have bars but no ticks. A test covering them will still produce "
                  "a curve, and that curve is built on generated ticks.", badMonths);

   Print("  Sampling shows whether ticks exist, not that every minute is complete.");
   if(!InpFullScan)
      Print("  Set 'Check every day' to true for the thorough pass.");
   Print("------------------------------------------------------------------");

   if(InpWriteCSV)
      WriteCSV(months);
  }

//+------------------------------------------------------------------+
void WriteCSV(const Month &months[])
  {
   string name = StringFormat("TickAudit_%s.csv", _Symbol);

   int h = FileOpen(name, FILE_WRITE | FILE_CSV | FILE_ANSI, ',');
   if(h == INVALID_HANDLE)
     {
      PrintFormat("  cannot create %s (error %d)", name, GetLastError());
      return;
     }

   FileWrite(h, "year", "month", "days_checked", "days_with_ticks", "days_with_bars",
             "ticks", "m1_bars", "verdict");

   for(int k = ArraySize(months) - 1; k >= 0; k--)
      FileWrite(h, months[k].year, months[k].mon, months[k].daysChecked,
                months[k].daysWithTicks, months[k].daysWithBars,
                months[k].tickCount, months[k].barCount, Verdict(months[k]));

   FileClose(h);
   PrintFormat("  month table written to MQL5\\Files\\%s", name);
  }

//+------------------------------------------------------------------+
int DaysInMonth(const int year, const int mon)
  {
   int len[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
   if(mon < 1 || mon > 12)
      return(30);
   if(mon == 2 && (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)))
      return(29);
   return(len[mon - 1]);
  }

//+------------------------------------------------------------------+
datetime MakeTime(const int year, const int mon, const int day)
  {
   MqlDateTime dt;
   dt.year = year;
   dt.mon  = mon;
   dt.day  = day;
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;
   return(StructToTime(dt));
  }
//+------------------------------------------------------------------+
