//+------------------------------------------------------------------+
//|                                           OvernightCostMeter.mq5 |
//|                       Free utility for the MQL5 CodeBase (2026)  |
//+------------------------------------------------------------------+
#property copyright   "Dmytro Polhorodnyk"
#property link        "https://www.mql5.com/en/users/boroda13"
#property version     "1.00"
#property description "Shows the REAL cost of holding positions overnight, per symbol and for your open trades:"
#property description "swap per night in account money, in % of notional and annualized - both directions."
#property description "Also prints the broker's round-trip markup: |swap long| + |swap short| never depends on"
#property description "interest rates, it is pure broker margin. Great for comparing brokers and swing costs."
#property script_show_inputs
#property strict

// The tool answers three questions most traders never check:
//  1. What does ONE night really cost me on this symbol, in money and in % a year?
//  2. How asymmetric are long vs short costs? (On indices it is often 10x+.)
//  3. How much of the swap is broker markup? |long|+|short| = 2 x markup, because the
//     underlying rate enters the two directions with opposite signs and cancels out.

input bool ScanMarketWatch   = true;  // scan visible Market Watch symbols (not only positions)
input int  MaxSymbols        = 20;    // Market Watch scan limit (keeps the report readable)
input bool ShowChartSummary  = true;  // print a short summary on the chart as well

//+------------------------------------------------------------------+
//| Swap for 1.0 lot for one regular night, in DEPOSIT currency.     |
//| Returns EMPTY_VALUE when the mode cannot be converted reliably — |
//| the note then says why (honesty beats a confident wrong number). |
//+------------------------------------------------------------------+
double SwapPerNight(const string sym, const bool isLong, string &note)
{
   note = "";
   double raw = SymbolInfoDouble(sym, isLong ? SYMBOL_SWAP_LONG : SYMBOL_SWAP_SHORT);
   long   mode = SymbolInfoInteger(sym, SYMBOL_SWAP_MODE);
   double price = SymbolInfoDouble(sym, SYMBOL_BID);
   double contract = SymbolInfoDouble(sym, SYMBOL_TRADE_CONTRACT_SIZE);

   switch((ENUM_SYMBOL_SWAP_MODE)mode)
   {
      case SYMBOL_SWAP_MODE_DISABLED:
         note = "swap-free";
         return(0.0);

      case SYMBOL_SWAP_MODE_POINTS:
      {
         // raw is in points of the symbol: convert via the value of one point
         double tickVal  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
         double tickSize = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
         double point    = SymbolInfoDouble(sym, SYMBOL_POINT);
         if(tickVal <= 0 || tickSize <= 0 || point <= 0) { note = "no tick data"; return(EMPTY_VALUE); }
         return(raw * point * tickVal / tickSize);
      }

      case SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT:
         return(raw);   // already in account currency per lot per night

      case SYMBOL_SWAP_MODE_CURRENCY_MARGIN:
      {
         string mCur = SymbolInfoString(sym, SYMBOL_CURRENCY_MARGIN);
         if(mCur == AccountInfoString(ACCOUNT_CURRENCY)) return(raw);
         note = "in " + mCur;       // printed as-is, conversion left to the reader
         return(raw);
      }
      case SYMBOL_SWAP_MODE_CURRENCY_SYMBOL:
      {
         string bCur = SymbolInfoString(sym, SYMBOL_CURRENCY_BASE);
         if(bCur == AccountInfoString(ACCOUNT_CURRENCY)) return(raw);
         note = "in " + bCur;
         return(raw);
      }

      case SYMBOL_SWAP_MODE_INTEREST_CURRENT:
      case SYMBOL_SWAP_MODE_INTEREST_OPEN:
      {
         // raw is an annual percentage applied to the notional; 360-day convention per docs
         if(price <= 0 || contract <= 0) { note = "no price"; return(EMPTY_VALUE); }
         return(price * contract * raw / 100.0 / 360.0);
      }

      default:
         note = "re-open mode, not a nightly charge";
         return(EMPTY_VALUE);
   }
}

//+------------------------------------------------------------------+
string Fmt(const double v, const string note)
{
   if(v == EMPTY_VALUE) return("   n/a");
   string s = StringFormat("%8.2f", v);
   if(note != "" && note != "swap-free") s += " (" + note + ")";
   return(s);
}

//+------------------------------------------------------------------+
//| One report line per symbol                                       |
//+------------------------------------------------------------------+
void ReportSymbol(const string sym, string &worstLine, double &worstAnnual)
{
   string nL = "", nS = "";
   double swL = SwapPerNight(sym, true, nL);
   double swS = SwapPerNight(sym, false, nS);
   if(swL == EMPTY_VALUE && swS == EMPTY_VALUE) return;

   double price = SymbolInfoDouble(sym, SYMBOL_BID);
   double contract = SymbolInfoDouble(sym, SYMBOL_TRADE_CONTRACT_SIZE);
   double notional = price * contract;

   // % of notional per night and annualized (360-day convention, stated openly)
   double pctL = (notional > 0 && swL != EMPTY_VALUE) ? swL / notional * 100.0 : EMPTY_VALUE;
   double pctS = (notional > 0 && swS != EMPTY_VALUE) ? swS / notional * 100.0 : EMPTY_VALUE;
   double annL = (pctL != EMPTY_VALUE) ? pctL * 360.0 : EMPTY_VALUE;
   double annS = (pctS != EMPTY_VALUE) ? pctS * 360.0 : EMPTY_VALUE;

   // broker round-trip markup: rate cancels between directions, this never does
   string markup = "n/a";
   if(swL != EMPTY_VALUE && swS != EMPTY_VALUE && notional > 0)
      markup = StringFormat("%.2f%%/y", (MathAbs(swL) + MathAbs(swS)) / notional * 100.0 * 360.0 / 2.0);

   int day3 = (int)SymbolInfoInteger(sym, SYMBOL_SWAP_ROLLOVER3DAYS);
   string days[] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
   string d3 = (day3 >= 0 && day3 < 7) ? days[day3] : "?";

   PrintFormat("%-12s | long/night %s | short/night %s | annual L %s / S %s | markup/side %s | 3x %s",
               sym, Fmt(swL, nL), Fmt(swS, nS),
               (annL == EMPTY_VALUE ? "n/a" : StringFormat("%+.2f%%", annL)),
               (annS == EMPTY_VALUE ? "n/a" : StringFormat("%+.2f%%", annS)),
               markup, d3);

   double worstHere = 0;
   if(annL != EMPTY_VALUE) worstHere = MathMax(worstHere, MathAbs(annL));
   if(annS != EMPTY_VALUE) worstHere = MathMax(worstHere, MathAbs(annS));
   if(worstHere > worstAnnual)
   {
      worstAnnual = worstHere;
      worstLine = StringFormat("%s: worst side costs %.1f%% a year to hold", sym, worstHere);
   }
}

//+------------------------------------------------------------------+
void OnStart()
{
   string accCur = AccountInfoString(ACCOUNT_CURRENCY);
   Print("=== OVERNIGHT COST METER === account currency: ", accCur,
         " | per 1.0 lot, one regular night | annual = night% x 360");

   string worstLine = ""; double worstAnnual = 0;
   string seen[]; int nSeen = 0;

   // 1) symbols of open positions first — that is where the money bleeds tonight
   double totalNight = 0; int nPos = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong tk = PositionGetTicket(i);
      if(tk == 0 || !PositionSelectByTicket(tk)) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      bool isBuy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      double lots = PositionGetDouble(POSITION_VOLUME);
      string note = "";
      double perLot = SwapPerNight(sym, isBuy, note);
      double nights = (double)(TimeCurrent() - (datetime)PositionGetInteger(POSITION_TIME)) / 86400.0;
      if(perLot != EMPTY_VALUE)
      {
         double tonight = perLot * lots;
         totalNight += (note == "" ? tonight : 0);
         PrintFormat("POSITION #%I64u %-10s %s %.2f lots | tonight %s %s | paid so far %.2f | held %.1f days",
                     tk, sym, (isBuy ? "LONG " : "SHORT"), lots,
                     StringFormat("%+.2f", tonight), (note == "" ? accCur : note),
                     PositionGetDouble(POSITION_SWAP), nights);
      }
      nPos++;
      bool dup = false;
      for(int k = 0; k < nSeen; k++) if(seen[k] == sym) { dup = true; break; }
      if(!dup) { ArrayResize(seen, nSeen+1); seen[nSeen++] = sym; }
   }
   if(nPos == 0) Print("No open positions - showing symbol table only.");
   else PrintFormat("TOTAL for tonight (convertible part): %+.2f %s", totalNight, accCur);
   Print("---");

   // 2) per-symbol table: position symbols + Market Watch
   for(int k = 0; k < nSeen; k++) ReportSymbol(seen[k], worstLine, worstAnnual);
   if(ScanMarketWatch)
   {
      int total = SymbolsTotal(true);
      int shown = 0;
      for(int i = 0; i < total && shown < MaxSymbols; i++)
      {
         string sym = SymbolName(i, true);
         bool dup = false;
         for(int k2 = 0; k2 < nSeen; k2++) if(seen[k2] == sym) { dup = true; break; }
         if(dup) continue;
         ReportSymbol(sym, worstLine, worstAnnual);
         shown++;
      }
      if(total > MaxSymbols + nSeen)
         PrintFormat("(%d more symbols in Market Watch - raise MaxSymbols to see them)", total - MaxSymbols - nSeen);
   }

   Print("=== Notes: values are what YOUR broker reports right now; 'markup/side' is the half-sum");
   Print("of both absolute swaps - the rate-independent part you pay whichever direction you trade.");
   Print("Triple swap is charged on the day shown in the '3x' column. Verify against broker specs.");

   if(ShowChartSummary)
   {
      string cmt = "OVERNIGHT COST METER\n";
      if(nPos > 0) cmt += StringFormat("Open positions tonight: %+.2f %s\n", totalNight, accCur);
      if(worstLine != "") cmt += worstLine + "\n";
      cmt += "Full table -> Experts log";
      Comment(cmt);
   }
}
//+------------------------------------------------------------------+
