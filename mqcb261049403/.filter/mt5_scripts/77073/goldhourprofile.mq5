//+------------------------------------------------------------------+
//|                                             GoldHourProfile.mq5  |
//|                                        Copyright 2026, Petr Kostal|
//|                                             https://www.mql5.com  |
//+------------------------------------------------------------------+
//| When does gold actually move, and when does the spread eat it?    |
//|                                                                   |
//| Every volatility-by-hour tool tells you how far a symbol travels  |
//| in each hour of the day. None of them tell you what that movement |
//| costs. On XAUUSD the spread is not a constant: it widens in the   |
//| quiet hours and at the session handover, exactly where the range  |
//| is thinnest. An hour that looks tradable on a range chart can be  |
//| the worst hour on the account.                                    |
//|                                                                   |
//| This script measures both from the same M1 history and divides    |
//| one by the other. The last column is the one that matters: how    |
//| many spreads of movement the hour actually hands you.             |
//|                                                                   |
//| It takes a list of symbols, so gold can be read next to the       |
//| majors instead of on its own. Gold is where the difference is     |
//| largest, which is why the tool is named after it, but the         |
//| measurement is the same on anything the terminal quotes.          |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Petr Kostal"
#property link      "https://www.mql5.com"
#property version   "1.10"
#property script_show_inputs
#property description "Measures movement and spread hour by hour from M1 history and reports how many spreads of range each hour actually pays. Runs over a list of symbols, so gold can be compared with the majors."

input string InpSymbols   = "";    // Symbols, comma separated (empty = chart symbol)
input int    InpDays      = 90;    // Days of M1 history to analyse
input int    InpHourShift = 0;     // Shift hours to your own timezone (server time + N)
input bool   InpWriteCSV  = true;  // Write the table to a CSV file

//--- what one symbol's profile boils down to
struct HourVerdict
{
   bool   ok;
   int    bestHour;
   double bestRatio;
   int    worstHour;
   double worstRatio;
   double dayMovement;   // points travelled over an average day
   double avgSpread;     // points, averaged over the whole sample
};

//+------------------------------------------------------------------+
//| Measure one symbol and print its table                            |
//+------------------------------------------------------------------+
HourVerdict ProfileSymbol(const string symbol, const int days,
                          const int hourShift, const int csv)
{
   HourVerdict v;
   v.ok = false;
   v.bestHour = -1; v.bestRatio = 0.0;
   v.worstHour = -1; v.worstRatio = 0.0;
   v.dayMovement = 0.0; v.avgSpread = 0.0;

   if(!SymbolSelect(symbol, true))
   {
      PrintFormat("  %s is not available on this account - skipped.", symbol);
      return v;
   }

   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(point <= 0.0)
   {
      PrintFormat("  %s reports a point size of zero - skipped.", symbol);
      return v;
   }

   datetime to   = TimeCurrent();
   datetime from = to - (datetime)days * 86400;

   MqlRates rates[];
   ArraySetAsSeries(rates, false);
   int total = CopyRates(symbol, PERIOD_M1, from, to, rates);
   if(total < 1440)
   {
      PrintFormat("  %s has only %d M1 bars - download more history first.", symbol, total);
      return v;
   }

   long   bars[24];
   double sumRange[24];
   double sumSpread[24];
   long   spreadBars[24];

   for(int h = 0; h < 24; h++)
   {
      bars[h] = 0; sumRange[h] = 0.0; sumSpread[h] = 0.0; spreadBars[h] = 0;
   }

   MqlDateTime dt;

   for(int i = 0; i < total; i++)
   {
      //--- a flat bar means the market was not really trading in that minute
      if(rates[i].high <= rates[i].low)
         continue;

      TimeToStruct(rates[i].time, dt);

      int h = (dt.hour + hourShift) % 24;
      if(h < 0) h += 24;

      bars[h]++;
      sumRange[h] += (rates[i].high - rates[i].low) / point;

      if(rates[i].spread > 0)
      {
         sumSpread[h]  += (double)rates[i].spread;
         spreadBars[h]++;
      }
   }

   //--- day total, for the share column
   double dayMovement = 0.0;
   double spreadSum   = 0.0;
   int    spreadHours = 0;

   for(int h = 0; h < 24; h++)
      if(bars[h] > 0)
      {
         dayMovement += sumRange[h] / bars[h] * 60.0;
         if(spreadBars[h] > 0)
         {
            spreadSum += sumSpread[h] / spreadBars[h];
            spreadHours++;
         }
      }

   Print("");
   PrintFormat("%s - %d M1 bars over the last %d days", symbol, total, days);
   Print("  hour    bars   movement/h    spread   spreads of   share");
   Print("                   (points)  (points)     movement   of day");
   Print("  ----------------------------------------------------------------");

   for(int h = 0; h < 24; h++)
   {
      if(bars[h] == 0)
      {
         PrintFormat("  %02d:00       0   no data", h);
         continue;
      }

      double movement = sumRange[h] / bars[h] * 60.0;
      double spread   = (spreadBars[h] > 0) ? sumSpread[h] / spreadBars[h] : 0.0;
      double ratio    = (spread > 0.0) ? movement / spread : 0.0;
      double share    = (dayMovement > 0.0) ? 100.0 * movement / dayMovement : 0.0;

      PrintFormat("  %02d:00  %6d   %10.0f  %8.1f   %10.1f   %5.1f%%",
                  h, (int)bars[h], movement, spread, ratio, share);

      if(csv != INVALID_HANDLE)
         FileWrite(csv, symbol, StringFormat("%02d:00", h),
                   IntegerToString((int)bars[h]),
                   DoubleToString(movement, 0),
                   DoubleToString(spread, 1),
                   DoubleToString(ratio, 1),
                   DoubleToString(share, 1));

      if(ratio > 0.0)
      {
         if(v.bestHour  < 0 || ratio > v.bestRatio)  { v.bestRatio  = ratio; v.bestHour  = h; }
         if(v.worstHour < 0 || ratio < v.worstRatio) { v.worstRatio = ratio; v.worstHour = h; }
      }
   }

   v.ok          = true;
   v.dayMovement = dayMovement;
   v.avgSpread   = (spreadHours > 0) ? spreadSum / spreadHours : 0.0;

   if(v.bestHour >= 0 && v.worstHour >= 0)
   {
      Print("");
      PrintFormat("  best %02d:00 (%.1f spreads)   worst %02d:00 (%.1f spreads)",
                  v.bestHour, v.bestRatio, v.worstHour, v.worstRatio);
   }

   return v;
}

//+------------------------------------------------------------------+
void OnStart()
{
   int days = InpDays;
   if(days < 1)   days = 1;
   if(days > 365) days = 365;

   //--- the symbol list
   string list = InpSymbols;
   StringTrimLeft(list);
   StringTrimRight(list);
   if(list == "")
      list = _Symbol;

   string symbols[];
   int count = StringSplit(list, ',', symbols);
   if(count <= 0)
   {
      Print("No symbols to analyse.");
      return;
   }

   int csv = INVALID_HANDLE;
   if(InpWriteCSV)
   {
      csv = FileOpen("GoldHourProfile.csv", FILE_WRITE | FILE_CSV | FILE_ANSI, ';');
      if(csv != INVALID_HANDLE)
         FileWrite(csv, "symbol", "hour", "m1_bars", "movement_points_per_hour",
                        "avg_spread_points", "spreads_of_movement", "share_of_day_pct");
   }

   Print("------------------------------------------------------------------");
   PrintFormat("Gold Hour Profile - %d symbol(s), the last %d days", count, days);
   if(InpHourShift == 0)
      Print("Hours are broker server time.");
   else
      PrintFormat("Hours are broker server time shifted by %+d.", InpHourShift);
   Print("------------------------------------------------------------------");

   HourVerdict verdicts[];
   ArrayResize(verdicts, count);

   for(int s = 0; s < count; s++)
   {
      string sym = symbols[s];
      StringTrimLeft(sym);
      StringTrimRight(sym);
      if(sym == "") continue;

      verdicts[s] = ProfileSymbol(sym, days, InpHourShift, csv);
   }

   if(csv != INVALID_HANDLE)
   {
      FileClose(csv);
      Print("");
      Print("  (the whole table is also in MQL5\\Files\\GoldHourProfile.csv)");
   }

   //--- the comparison, which is the point of passing more than one symbol
   if(count > 1)
   {
      Print("");
      Print("------------------------------------------------------------------");
      Print("Side by side");
      Print("");
      Print("  symbol         day movement   avg spread   best hour   worst hour");
      Print("                     (points)     (points)");
      Print("  ----------------------------------------------------------------");

      for(int s = 0; s < count; s++)
      {
         if(!verdicts[s].ok) continue;

         string sym = symbols[s];
         StringTrimLeft(sym);
         StringTrimRight(sym);

         PrintFormat("  %-12s %12.0f %12.1f    %02d:00 %4.0f   %02d:00 %4.0f",
                     sym,
                     verdicts[s].dayMovement,
                     verdicts[s].avgSpread,
                     verdicts[s].bestHour,  verdicts[s].bestRatio,
                     verdicts[s].worstHour, verdicts[s].worstRatio);
      }
   }

   Print("");
   Print("------------------------------------------------------------------");
   Print("Read the movement and the spread together. An hour with a big range");
   Print("and a wide spread is not a good hour, it is an expensive one. A");
   Print("scalper whose target is a few spreads wide can only work where that");
   Print("ratio is high; a swing trader can ignore it. The spread figures come");
   Print("from the spread recorded on each M1 bar by this broker, so the table");
   Print("describes YOUR account rather than an average of somebody else's.");
   Print("------------------------------------------------------------------");
}
//+------------------------------------------------------------------+
