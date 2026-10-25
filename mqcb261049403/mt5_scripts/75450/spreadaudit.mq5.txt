//+------------------------------------------------------------------+
//|                                                  SpreadAudit.mq5 |
//|          Real per-bar spread statistics for honest backtesting   |
//+------------------------------------------------------------------+
#property copyright   "tei050599"
#property link        "https://forge.mql5.io"
#property version     "1.10"
#property description "Collects the broker's stored per-bar spread over the last N days"
#property description "and prints median / p90 / p99 and a by-hour table, in points and"
#property description "as a fraction of ATR. NOTE: MT5 stores the MINIMUM spread of the"
#property description "bar, so these numbers are a LOWER BOUND of the real tick spread."
#property description "If even this lower bound eats your backtest edge, the strategy"
#property description "is dead on a live account. Saves a CSV report (server time)."
#property script_show_inputs

input int    InpDays      = 60;     // Days of M1 history to audit (1..3650)
input int    InpAtrPeriod = 24;     // ATR period on H1 for normalization
input bool   InpSaveCSV   = true;   // Save per-hour table to CSV (MQL5/Files)

//+------------------------------------------------------------------+
//| p-й перцентиль; массив должен быть ЗАРАНЕЕ отсортирован           |
//+------------------------------------------------------------------+
double PercentileSorted(const double &sorted[], const double p)
  {
   int n = ArraySize(sorted);
   if(n == 0) return(0.0);
   int i = (int)MathFloor(p * (n - 1));
   return(sorted[i]);
  }

//+------------------------------------------------------------------+
void OnStart()
  {
   if(InpDays < 1 || InpDays > 3650)
     { Print("SpreadAudit: InpDays must be 1..3650"); return; }
   if(InpAtrPeriod < 1)
     { Print("SpreadAudit: InpAtrPeriod must be >= 1"); return; }

   datetime to = TimeCurrent();
   datetime from = to - (datetime)InpDays * 86400;

   // история может подкачиваться асинхронно — пробуем несколько раз
   MqlRates rates[];
   int n = -1;
   for(int attempt = 0; attempt < 10; attempt++)
     {
      ResetLastError();
      n = CopyRates(_Symbol, PERIOD_M1, from, to, rates);
      if(n > 0) break;
      Sleep(500);
     }
   if(n <= 0)
     {
      Print("SpreadAudit: failed to load M1 history, error ", GetLastError(),
            " (open the M1 chart once to force history download, then rerun)");
      return;
     }

   // ATR: индикатор считается асинхронно — ждём готовности
   double atr = 0.0;
   int hATR = iATR(_Symbol, PERIOD_H1, InpAtrPeriod);
   if(hATR != INVALID_HANDLE)
     {
      double atrBuf[];
      for(int attempt = 0; attempt < 20; attempt++)
        {
         if(BarsCalculated(hATR) > 0 && CopyBuffer(hATR, 0, 1, 1, atrBuf) == 1)
           { atr = atrBuf[0]; break; }
         Sleep(250);
        }
      IndicatorRelease(hATR);
     }

   double pt = _Point;
   double all[];  ArrayResize(all, n);
   double sumH[24], maxH[24];
   int    cntH[24];
   ArrayInitialize(sumH, 0.0); ArrayInitialize(maxH, 0.0); ArrayInitialize(cntH, 0);

   int m = 0, zeros = 0;
   for(int i = 0; i < n; i++)
     {
      if(rates[i].spread <= 0) { zeros++; continue; }   // не заполнен брокером
      double sp = rates[i].spread * pt;
      all[m++] = sp;
      MqlDateTime dt;
      TimeToStruct(rates[i].time, dt);
      sumH[dt.hour] += sp;
      cntH[dt.hour] += 1;
      if(sp > maxH[dt.hour]) maxH[dt.hour] = sp;
     }
   ArrayResize(all, m);
   if(m < 100)
     {
      PrintFormat("SpreadAudit: only %d of %d bars carry a stored spread. Your "
                  "broker does not fill the spread field in M1 history (or the "
                  "history is too short) - per-bar audit is not possible here.",
                  m, n);
      return;
     }

   ArraySort(all);
   double med = PercentileSorted(all, 0.50);
   double p90 = PercentileSorted(all, 0.90);
   double p99 = PercentileSorted(all, 0.99);

   PrintFormat("=== SpreadAudit: %s | actual range %s ... %s | %d bars (%d without spread) ===",
               _Symbol, TimeToString(rates[0].time, TIME_DATE),
               TimeToString(rates[n - 1].time, TIME_DATE), n, zeros);
   PrintFormat("median bar spread: %s (%.1f pts)", DoubleToString(med, _Digits), med / pt);
   PrintFormat("p90    bar spread: %s (%.1f pts)", DoubleToString(p90, _Digits), p90 / pt);
   PrintFormat("p99    bar spread: %s (%.1f pts)", DoubleToString(p99, _Digits), p99 / pt);
   if(atr > 0)
      PrintFormat("H1 ATR(%d) = %s -> median spread = %.3f ATR, p90 = %.3f ATR",
                  InpAtrPeriod, DoubleToString(atr, _Digits), med / atr, p90 / atr);
   Print("Reminder: MT5 stores the bar's MINIMUM spread - treat these numbers");
   Print("as an optimistic lower bound of what you actually pay per trade.");

   if(InpSaveCSV)
     {
      // подчистка имени символа для файловой системы (Exness-style 'XAU/USD')
      string sym = _Symbol;
      StringReplace(sym, "/", "_"); StringReplace(sym, "\\", "_");
      StringReplace(sym, ":", "_"); StringReplace(sym, "*", "_");
      string fname = "SpreadAudit_" + sym + ".csv";
      ResetLastError();
      int fh = FileOpen(fname, FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
      if(fh == INVALID_HANDLE)
        {
         Print("SpreadAudit: cannot open ", fname, " for writing, error ",
               GetLastError(), " (is the file open in another program?)");
         return;
        }
      FileWrite(fh, "hour_server_time", "avg_spread", "max_spread", "bars");
      for(int h = 0; h < 24; h++)
         FileWrite(fh, h,
                   cntH[h] > 0 ? DoubleToString(sumH[h] / cntH[h], _Digits) : "",
                   cntH[h] > 0 ? DoubleToString(maxH[h], _Digits) : "",
                   cntH[h]);
      FileClose(fh);
      Print("SpreadAudit: by-hour table (server time) saved to MQL5\\Files\\", fname);
     }
  }
//+------------------------------------------------------------------+
