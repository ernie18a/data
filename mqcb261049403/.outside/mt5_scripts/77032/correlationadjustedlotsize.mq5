//+------------------------------------------------------------------+
//|                                 CorrelationAdjustedLotSize.mq5   |
//|                                                                    |
//| Calculates a risk-based lot size for a new trade, then adjusts    |
//| it down based on correlated risk you already have open across     |
//| your other positions (any symbol, not just the same instrument).  |
//|                                                                    |
//| Most lot-size calculators treat every trade as isolated. This one |
//| looks at your whole basket: if you already hold a position that   |
//| is highly correlated with the symbol you're about to trade — in   |
//| the same effective direction — it counts that as risk you've      |
//| already taken, and reduces the new trade's size so your combined  |
//| correlated exposure stays under a basket risk limit you define.   |
//|                                                                    |
//| Correlation is computed live from recent price history (Pearson   |
//| correlation of bar-to-bar returns), not a hardcoded pair table,    |
//| so it works for any symbol your broker offers — majors, minors,   |
//| metals, indices, etc. Direction is taken into account too: two    |
//| positively-correlated pairs traded in opposite directions are     |
//| flagged as a natural hedge, not extra risk.                       |
//|                                                                    |
//| Usage:                                                             |
//|   1. Attach to any chart (symbol/timeframe don't matter).          |
//|   2. Set InpTargetSymbol to the symbol you're about to trade       |
//|      (leave empty to use the current chart's symbol).              |
//|   3. Set your risk %, stop loss distance in points, and the        |
//|      direction of the new trade (buy/sell).                        |
//|   4. Set InpMaxBasketRiskPercent to the max combined risk you      |
//|      allow across correlated positions.                            |
//|   5. Read the report in the Experts/Journal tab.                   |
//|                                                                    |
//| This is a read-only decision-support tool. It does not open,       |
//| modify, or close any trades.                                       |
//+------------------------------------------------------------------+
#property copyright "Article demo script"
#property version   "1.00"
#property script_show_inputs
#property strict

input string          InpTargetSymbol         = "";         // Symbol to trade (empty = current chart symbol)
input bool             InpNewTradeIsBuy        = true;        // New trade direction (true = Buy, false = Sell)
input double           InpRiskPercent          = 1.0;         // Risk % of balance for the new trade
input int              InpStopLossPoints       = 300;         // Stop loss distance for the new trade (points)
input double           InpMaxBasketRiskPercent = 3.0;         // Max combined risk allowed across correlated positions (%)
input double           InpCorrelationThreshold = 0.70;        // Correlation level treated as "same bet" (0..1)
input int              InpCorrelationBars      = 100;         // Bars used to calculate correlation
input ENUM_TIMEFRAMES  InpCorrelationTimeframe = PERIOD_H1;   // Timeframe used to calculate correlation

string g_cacheSymbol[];
double g_cacheCorr[];
bool   g_cacheOk[];

//+------------------------------------------------------------------+
double ValuePerPoint(const string symbol)
  {
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double point     = SymbolInfoDouble(symbol, SYMBOL_POINT);
   if(tickSize <= 0.0)
      return 0.0;
   return tickValue * (point / tickSize);
  }

//+------------------------------------------------------------------+
double NormalizeLot(double lot, const string symbol)
  {
   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0)
      return 0.0;

   lot = MathFloor(lot / step) * step;
   if(lot > maxLot)
      lot = maxLot;
   if(lot < minLot)
      lot = 0.0;
   return NormalizeDouble(lot, 2);
  }

//+------------------------------------------------------------------+
//| Pearson correlation of bar-to-bar returns between two symbols     |
//+------------------------------------------------------------------+
double ComputeCorrelation(const string symbolA, const string symbolB, const int bars,
                           const ENUM_TIMEFRAMES tf, bool &ok)
  {
   ok = false;
   if(symbolA == symbolB)
     {
      ok = true;
      return 1.0;
     }

   SymbolSelect(symbolA, true);
   SymbolSelect(symbolB, true);

   double closesA[], closesB[];
   ArraySetAsSeries(closesA, true);
   ArraySetAsSeries(closesB, true);

   int copiedA = CopyClose(symbolA, tf, 0, bars + 1, closesA);
   int copiedB = CopyClose(symbolB, tf, 0, bars + 1, closesB);

   if(copiedA < bars + 1 || copiedB < bars + 1)
      return 0.0;

   double retA[], retB[];
   ArrayResize(retA, bars);
   ArrayResize(retB, bars);

   for(int i = 0; i < bars; i++)
     {
      retA[i] = (closesA[i] - closesA[i + 1]) / closesA[i + 1];
      retB[i] = (closesB[i] - closesB[i + 1]) / closesB[i + 1];
     }

   double meanA = 0.0, meanB = 0.0;
   for(int i = 0; i < bars; i++)
     {
      meanA += retA[i];
      meanB += retB[i];
     }
   meanA /= bars;
   meanB /= bars;

   double cov = 0.0, varA = 0.0, varB = 0.0;
   for(int i = 0; i < bars; i++)
     {
      double da = retA[i] - meanA;
      double db = retB[i] - meanB;
      cov  += da * db;
      varA += da * da;
      varB += db * db;
     }

   if(varA <= 0.0 || varB <= 0.0)
      return 0.0;

   ok = true;
   return cov / MathSqrt(varA * varB);
  }

//+------------------------------------------------------------------+
//| Correlation lookup with per-run cache (target symbol is fixed)    |
//+------------------------------------------------------------------+
double GetCorrelationCached(const string symbolA, const string symbolB, const int bars,
                             const ENUM_TIMEFRAMES tf, bool &ok)
  {
   for(int i = 0; i < ArraySize(g_cacheSymbol); i++)
     {
      if(g_cacheSymbol[i] == symbolB)
        {
         ok = g_cacheOk[i];
         return g_cacheCorr[i];
        }
     }

   double corr = ComputeCorrelation(symbolA, symbolB, bars, tf, ok);

   int n = ArraySize(g_cacheSymbol);
   ArrayResize(g_cacheSymbol, n + 1);
   ArrayResize(g_cacheCorr, n + 1);
   ArrayResize(g_cacheOk, n + 1);
   g_cacheSymbol[n] = symbolB;
   g_cacheCorr[n]   = corr;
   g_cacheOk[n]     = ok;

   return corr;
  }

//+------------------------------------------------------------------+
//| Script entry point                                                |
//+------------------------------------------------------------------+
void OnStart()
  {
   string targetSymbol = (InpTargetSymbol == "") ? _Symbol : InpTargetSymbol;

   if(!SymbolSelect(targetSymbol, true))
     {
      PrintFormat("Symbol '%s' not found/could not be selected.", targetSymbol);
      return;
     }
   if(InpRiskPercent <= 0.0 || InpStopLossPoints <= 0 || InpMaxBasketRiskPercent <= 0.0)
     {
      Print("InpRiskPercent, InpStopLossPoints and InpMaxBasketRiskPercent must all be greater than 0.");
      return;
     }
   if(InpCorrelationBars < 10)
     {
      Print("InpCorrelationBars should be at least 10 for a meaningful correlation estimate.");
      return;
     }

   double balance             = AccountInfoDouble(ACCOUNT_BALANCE);
   double valuePerPointTarget = ValuePerPoint(targetSymbol);
   if(valuePerPointTarget <= 0.0)
     {
      PrintFormat("Could not read tick value/size for '%s'.", targetSymbol);
      return;
     }

   double riskAmount   = balance * InpRiskPercent / 100.0;
   double slLossPerLot = InpStopLossPoints * valuePerPointTarget;
   double baseLot      = NormalizeLot(riskAmount / slLossPerLot, targetSymbol);

   double correlatedRiskSum       = 0.0;
   int    compoundingCount        = 0;
   int    hedgingCount            = 0;
   bool   unknownRiskFound        = false;
   bool   unknownCorrelationFound = false;

   Print("========== CORRELATION-ADJUSTED LOT SIZE REPORT ==========");
   PrintFormat("Target symbol         : %s (%s)", targetSymbol, InpNewTradeIsBuy ? "BUY" : "SELL");
   PrintFormat("Account balance       : %.2f", balance);
   PrintFormat("Desired risk          : %.2f%% (%.2f)", InpRiskPercent, riskAmount);
   PrintFormat("Base lot (no basket)  : %.2f", baseLot);
   Print("---- Scanning open positions for correlated exposure ----");

   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;

      string            posSymbol = PositionGetString(POSITION_SYMBOL);
      double            posVolume = PositionGetDouble(POSITION_VOLUME);
      double            posSL     = PositionGetDouble(POSITION_SL);
      double            posOpen   = PositionGetDouble(POSITION_PRICE_OPEN);
      ENUM_POSITION_TYPE posType  = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      bool              posIsBuy  = (posType == POSITION_TYPE_BUY);

      bool   ok   = false;
      double corr = GetCorrelationCached(targetSymbol, posSymbol, InpCorrelationBars, InpCorrelationTimeframe, ok);

      if(!ok)
        {
         unknownCorrelationFound = true;
         PrintFormat("%-10s vol %.2f  correlation UNKNOWN (insufficient history) - please check manually",
                     posSymbol, posVolume);
         continue;
        }

      bool   sameDirection = (posIsBuy == InpNewTradeIsBuy);
      double effectiveCorr = sameDirection ? corr : -corr;

      if(effectiveCorr >= InpCorrelationThreshold)
        {
         double posRisk   = 0.0;
         bool   riskKnown = false;
         if(posSL != 0.0)
           {
            double posPoint         = SymbolInfoDouble(posSymbol, SYMBOL_POINT);
            double posValuePerPoint = ValuePerPoint(posSymbol);
            if(posPoint > 0.0 && posValuePerPoint > 0.0)
              {
               double slDistPoints = MathAbs(posOpen - posSL) / posPoint;
               posRisk   = slDistPoints * posValuePerPoint * posVolume;
               riskKnown = true;
              }
           }

         if(riskKnown)
            correlatedRiskSum += posRisk;
         else
            unknownRiskFound = true;

         compoundingCount++;
         PrintFormat("%-10s vol %.2f  corr %.2f  %s, %s -> COMPOUNDS RISK  (risk %s)",
                     posSymbol, posVolume, corr, posIsBuy ? "BUY" : "SELL",
                     sameDirection ? "same direction" : "opposite direction",
                     riskKnown ? DoubleToString(posRisk, 2) : "unknown - no SL set");
        }
      else
         if(effectiveCorr <= -InpCorrelationThreshold)
           {
            hedgingCount++;
            PrintFormat("%-10s vol %.2f  corr %.2f  %s, %s -> NATURAL HEDGE (not counted against basket risk)",
                        posSymbol, posVolume, corr, posIsBuy ? "BUY" : "SELL",
                        sameDirection ? "same direction" : "opposite direction");
           }
     }

   if(compoundingCount == 0 && hedgingCount == 0 && !unknownCorrelationFound)
      Print("No open positions found, or none significantly correlated with the target symbol.");

   double maxBasketRiskAmount = balance * InpMaxBasketRiskPercent / 100.0;
   double remainingBudget     = maxBasketRiskAmount - correlatedRiskSum;
   double recommendedLot;

   if(remainingBudget <= 0.0)
      recommendedLot = 0.0;
   else
     {
      double cappedRiskAmount = MathMin(riskAmount, remainingBudget);
      recommendedLot = NormalizeLot(cappedRiskAmount / slLossPerLot, targetSymbol);
     }

   Print("---------------------------------------------------");
   PrintFormat("Already-committed correlated risk : %.2f", correlatedRiskSum);
   PrintFormat("Max basket risk allowed (%.2f%%)   : %.2f", InpMaxBasketRiskPercent, maxBasketRiskAmount);
   PrintFormat("Remaining risk budget              : %.2f", MathMax(remainingBudget, 0.0));
   PrintFormat("RECOMMENDED LOT SIZE                : %.2f", recommendedLot);

   if(recommendedLot <= 0.0)
      Print("-> Basket risk limit already reached. Consider skipping this trade or closing correlated exposure first.");
   else
      if(recommendedLot < baseLot)
         Print("-> Lot size reduced below your normal risk % because of existing correlated exposure.");

   if(unknownRiskFound)
      Print("NOTE: one or more correlated positions have no stop loss set, so actual basket risk may be higher than shown.");
   if(unknownCorrelationFound)
      Print("NOTE: correlation could not be computed for one or more symbols (insufficient price history).");

   Print("Correlation is based on recent historical price behaviour and is not guaranteed to hold going forward.");
   Print("====================================================");
  }
//+------------------------------------------------------------------+
