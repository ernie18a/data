//+------------------------------------------------------------------+
//|                                             ServerClockCheck.mq5 |
//|  Measures how far your PC clock is from the trade server's clock. |
//|                                                                   |
//|  It never opens, closes or modifies a trade.                      |
//+------------------------------------------------------------------+
#property copyright "Amul R"
#property link      "https://www.mql5.com/en/users/amul1"
#property version   "1.00"
#property description "Measures how far your PC clock is from the trade server's clock, using the server time stamped on live ticks."
#property description "A wrong PC clock shifts TimeTradeServer() and TimeLocal(): pending-order expiry, session filters and news pauses then fire early or late. Never trades."
#property script_show_inputs
#property strict

input string InpSymbol     = "";    // Symbol (empty = chart symbol; pick an active one)
input int    InpSamples    = 40;    // Fresh ticks to measure
input int    InpTimeoutSec = 90;    // Give up after this many seconds
input double InpWarnSec    = 2.0;   // Warn when the clock is off by this much (seconds)

//--- local clock in milliseconds: whole seconds from TimeLocal(), the fraction from the microsecond counter
datetime g_baseSec = 0;
ulong    g_baseUs  = 0;

bool CalibrateLocalClock()
  {
   datetime start = TimeLocal();
   ulong    t0    = GetMicrosecondCount();
   while(TimeLocal() == start)                  // wait for the second to tick over
     {
      if(IsStopped() || GetMicrosecondCount() - t0 > 2000000)
         return false;
     }
   g_baseSec = TimeLocal();
   g_baseUs  = GetMicrosecondCount();
   return true;
  }

long LocalMs()
  {
   return (long)g_baseSec * 1000 + (long)((GetMicrosecondCount() - g_baseUs) / 1000);
  }

//--- the server's time zone as the terminal sees it (TimeTradeServer = local clock + this offset)
long ServerZoneSec()
  {
   long diff = (long)(TimeTradeServer() - TimeLocal());
   return (long)MathRound(diff / 60.0) * 60;     // zones are whole minutes; drops a second-boundary straddle
  }

void SortLongs(long &a[])
  {
   int n = ArraySize(a);
   for(int i = 1; i < n; i++)
     {
      long v = a[i];
      int  j = i - 1;
      while(j >= 0 && a[j] > v)
        {
         a[j + 1] = a[j];
         j--;
        }
      a[j + 1] = v;
     }
  }

void Report(string text)
  {
   Print(text);
   Comment(text);
  }

void OnStart()
  {
   string sym = (InpSymbol == "") ? _Symbol : InpSymbol;
   if(!SymbolSelect(sym, true))
     {
      Report("ServerClockCheck: symbol " + sym + " not found in Market Watch.");
      return;
     }
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Report("ServerClockCheck: the terminal is not connected to a trade server.");
      return;
     }
   if(!CalibrateLocalClock())
      return;

   long zone   = ServerZoneSec();
   long lags[];
   ArrayResize(lags, 0, InpSamples);
   long lastMsc = 0;
   ulong t0     = GetMicrosecondCount();
   Comment("ServerClockCheck: measuring on ", sym, " ...");

   while(ArraySize(lags) < InpSamples && !IsStopped()
         && GetMicrosecondCount() - t0 < (ulong)InpTimeoutSec * 1000000)
     {
      MqlTick tick;
      if(SymbolInfoTick(sym, tick) && tick.time_msc != lastMsc)
        {
         long nowServerMs = LocalMs() + zone * 1000;          // "now" by your PC clock, in server time
         if(lastMsc != 0)                                     // the first tick may be old: skip it
           {
            int n = ArraySize(lags);
            ArrayResize(lags, n + 1, InpSamples);
            lags[n] = nowServerMs - tick.time_msc;            // arrival minus the server's stamp
           }
         lastMsc = tick.time_msc;
        }
      Sleep(2);
     }

   int n = ArraySize(lags);
   if(n < 5)
     {
      Report(StringFormat("ServerClockCheck: only %d new ticks on %s in %d s. The market is closed or the symbol is quiet. "
                          "Run it during trading hours on an active symbol (EURUSD, XAUUSD).", n, sym, InpTimeoutSec));
      return;
     }

   SortLongs(lags);
   //--- a tick can only arrive AFTER the server stamped it, so the smallest lag is the closest to the true clock error;
   //--- subtract half the ping for the trip from the server to you
   double pingMs  = TerminalInfoInteger(TERMINAL_PING_LAST) / 1000.0;
   double minLag  = (double)lags[0];
   double median  = (double)lags[n / 2];
   double errSec  = (minLag - pingMs / 2.0) / 1000.0;      // + = PC clock fast, - = PC clock slow

   string verdict;
   if(MathAbs(errSec) < InpWarnSec)
      verdict = StringFormat("OK: your PC clock is within %.1f s of the server (about %+.2f s).", InpWarnSec, errSec);
   else
      verdict = StringFormat("WARNING: your PC clock is about %.1f s %s the server.", MathAbs(errSec),
                             errSec > 0 ? "AHEAD of" : "BEHIND");

   string text = "ServerClockCheck on " + sym + "\n" + verdict + "\n"
                 + StringFormat("%d ticks: smallest lag %.0f ms, median lag %.0f ms, ping %.0f ms.\n", n, minLag, median, pingMs)
                 + StringFormat("Server time zone: GMT%+.1f h (as the terminal reports it).", (TimeTradeServer() - TimeGMT()) / 3600.0);
   if(MathAbs(errSec) >= InpWarnSec)
      text += "\nFix (Windows): Settings > Time & language > Date & time > Set time automatically ON, then Sync now."
              "\nIf Sync fails, run as administrator: sc config w32time start= auto, then net start w32time, then w32tm /resync."
              "\nThen run this script again.";
   Report(text);
  }
//+------------------------------------------------------------------+
