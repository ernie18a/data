//+------------------------------------------------------------------+
//| BrokerSpecInspector.mq5                                 v1.10    |
//| "Why was my order rejected?"                                     |
//| Read-only script that prints, per symbol, the contract limits    |
//| that silently reject orders: stops level, freeze level, min /    |
//| step / max lot, tick size and value, spread, execution mode,     |
//| swaps, and the margin required for the minimum lot. It then      |
//| checks a hypothetical stop/pending distance against the          |
//| effective no-go band  max(stops, freeze) + 1 point  and tells    |
//| you whether such an order would be accepted right now.           |
//| v1.10: the band rule lives in MinStopDistance(), and             |
//| LegalStopLoss() turns it into a stop level you can actually      |
//| send. Both are meant to be copied into your own EA.              |
//+------------------------------------------------------------------+
#property copyright "Free to use and modify"
#property version   "1.10"
#property script_show_inputs

input string InpSymbols            = "";    // comma list; empty = Market Watch selection
input double InpTestDistancePoints = 100;   // hypothetical SL/pending distance to check
input int    InpMaxSymbols         = 20;    // cap when reading from Market Watch
input bool   InpExportCSV          = true;  // write BrokerSpecs.csv to MQL5\Files

//+------------------------------------------------------------------+
//| Smallest distance from price the server accepts, in PRICE units. |
//| Both limits matter: some servers leave freeze at 0 and enforce   |
//| stops, others do the opposite - so the band is the larger of the |
//| two, plus one point, because a level sitting exactly on the edge |
//| is still refused by many servers.                                |
//+------------------------------------------------------------------+
double MinStopDistance(const string sym)
  {
   long stops  = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   long freeze = SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL);
   long band   = (stops > freeze ? stops : freeze) + 1;
   return band * SymbolInfoDouble(sym, SYMBOL_POINT);
  }
//+------------------------------------------------------------------+
//| Push a stop loss out to the nearest level the server accepts,    |
//| keeping it on the correct side of price. A level that is already |
//| legal is returned unchanged.                                     |
//+------------------------------------------------------------------+
double LegalStopLoss(const string sym, const bool isBuy,
                     const double price, const double wanted)
  {
   double dist   = MinStopDistance(sym);
   int    digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   double sl     = wanted;
   if(isBuy) { if(price - sl < dist) sl = price - dist; }
   else      { if(sl - price < dist) sl = price + dist; }
   return NormalizeDouble(sl, digits);
  }
//+------------------------------------------------------------------+
void InspectSymbol(const string sym, const int csvHandle)
  {
   if(!SymbolSelect(sym, true))
     { PrintFormat("%s: not found on this server", sym); return; }
   MqlTick tk;
   if(!SymbolInfoTick(sym, tk))
     { PrintFormat("%s: no tick data yet (open its chart once and rerun)", sym); return; }

   int    digits   = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   double point    = SymbolInfoDouble(sym, SYMBOL_POINT);
   long   stops    = SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   long   freeze   = SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL);
   double vmin     = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double vstep    = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double vmax     = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double tsize    = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   double tval     = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   double csize    = SymbolInfoDouble(sym, SYMBOL_TRADE_CONTRACT_SIZE);
   long   spr      = SymbolInfoInteger(sym, SYMBOL_SPREAD);
   bool   sprFloat = (bool)SymbolInfoInteger(sym, SYMBOL_SPREAD_FLOAT);
   double swapL    = SymbolInfoDouble(sym, SYMBOL_SWAP_LONG);
   double swapS    = SymbolInfoDouble(sym, SYMBOL_SWAP_SHORT);
   ENUM_SYMBOL_TRADE_EXECUTION ex =
      (ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(sym, SYMBOL_TRADE_EXEMODE);

   //--- one source for the rule: points value is derived from it
   double minDist = MinStopDistance(sym);
   long   effGap  = (long)MathRound(minDist / point);
   bool   distOk  = (long)InpTestDistancePoints >= effGap;

   //--- what your requested distance actually becomes on this symbol
   double wantBuy  = tk.ask - InpTestDistancePoints * point;
   double legalBuy = LegalStopLoss(sym, true, tk.ask, wantBuy);

   double needMin = 0.0;
   bool   marginOk = OrderCalcMargin(ORDER_TYPE_BUY, sym, vmin, tk.ask, needMin);
   double freeM = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

   PrintFormat("--- %s  (bid %.*f / ask %.*f) ---------------------", sym, digits, tk.bid, digits, tk.ask);
   PrintFormat("digits %d | point %g | tick size %g | tick value %.2f | contract %.0f",
               digits, point, tsize, tval, csize);
   PrintFormat("lots: min %g step %g max %g | spread %I64d pts (%s)",
               vmin, vstep, vmax, spr, sprFloat ? "floating" : "fixed");
   PrintFormat("stops level %I64d pts | freeze level %I64d pts | EFFECTIVE band %I64d pts",
               stops, freeze, effGap);
   PrintFormat("execution %s | swap long %.2f / short %.2f",
               EnumToString(ex), swapL, swapS);
   if(marginOk)
      PrintFormat("margin for min lot: %.2f (free margin now: %.2f) -> %s",
                  needMin, freeM, needMin <= freeM ? "affordable" : "NOT affordable");
   PrintFormat("VERDICT: a stop/pending placed %.0f pts from price would be %s (band is %I64d pts)",
               InpTestDistancePoints, distOk ? "ACCEPTED" : "REJECTED as 'Invalid price'", effGap);
   PrintFormat("  buy at ask %.*f: you asked SL %.*f -> nearest legal SL %.*f%s",
               digits, tk.ask, digits, wantBuy, digits, legalBuy,
               distOk ? "" : "  (moved out)");

   if(csvHandle != INVALID_HANDLE)
      FileWrite(csvHandle, StringFormat("%s;%d;%g;%I64d;%I64d;%I64d;%.*f;%g;%g;%g;%.2f;%I64d;%s;%.2f;%.2f;%.2f;%.*f;%s",
                sym, digits, point, stops, freeze, effGap, digits, minDist,
                vmin, vstep, vmax, tval, spr,
                sprFloat ? "floating" : "fixed", swapL, swapS, needMin,
                digits, legalBuy, distOk ? "OK" : "REJECT"));
  }
//+------------------------------------------------------------------+
void OnStart()
  {
   string list[];
   int n = 0;
   if(InpSymbols != "")
     {
      n = StringSplit(InpSymbols, ',', list);
      for(int i = 0; i < n; i++)
        {
         StringTrimLeft(list[i]);
         StringTrimRight(list[i]);
        }
     }
   else
     {
      int tot = SymbolsTotal(true);
      if(tot > InpMaxSymbols) tot = InpMaxSymbols;
      ArrayResize(list, tot);
      for(int i = 0; i < tot; i++) list[i] = SymbolName(i, true);
      n = tot;
     }
   if(n == 0) { Print("No symbols to inspect."); return; }

   int h = INVALID_HANDLE;
   if(InpExportCSV)
     {
      h = FileOpen("BrokerSpecs.csv", FILE_WRITE|FILE_CSV|FILE_ANSI, ';');
      if(h != INVALID_HANDLE)
         FileWrite(h, "symbol;digits;point;stopsLevel;freezeLevel;effectiveBandPts;minStopDistance;volMin;volStep;volMax;tickValue;spreadPts;spreadType;swapLong;swapShort;marginMinLot;nearestLegalBuySL;testDistanceVerdict");
     }
   Print("=== Broker Spec Inspector ==============================");
   PrintFormat("Symbols: %d | test distance: %.0f pts | effective band rule: max(stops, freeze) + 1",
               n, InpTestDistancePoints);
   for(int i = 0; i < n; i++) InspectSymbol(list[i], h);
   if(h != INVALID_HANDLE) { FileClose(h); Print("Exported MQL5\\Files\\BrokerSpecs.csv"); }
   Print("Note: some servers enforce the stops distance even when freeze = 0;");
   Print("that is exactly why the effective band uses the larger of the two.");
   Print("=== done ===============================================");
  }
//+------------------------------------------------------------------+
