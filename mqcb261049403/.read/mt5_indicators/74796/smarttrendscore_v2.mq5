//+------------------------------------------------------------------+
//|                                       Smart Trend Score v2.mq5   |
//|                     Multi-Factor Confluence Engine (Non-Repaint) |
//+------------------------------------------------------------------+
#property copyright   "Rebuilt 2026"
#property link        "https://forge.mql5.io"
#property description "Multi-Factor Trend Confluence Score. Combines EMA alignment, ADX"
#property description "trend strength, RSI momentum, MACD momentum/volatility-normalized,"
#property description "confirmed price-structure (fractal swings) and volume confidence"
#property description "into a single weighted 0-100 score. NON-REPAINTING: all values are"
#property description "read from CLOSED bars only. This is a decision-support tool, not a"
#property description "guarantee of outcome — no indicator can promise 'maximum accuracy'."
#property version     "2.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Inputs
input group "=== PANEL VISUALS ==="
input int    FontSize  = 12;
input string FontName  = "Consolas";
input int    TextX     = 25;
input int    TextY     = 25;
input color  BullColor    = clrLime;   // Text color when signal is BUY
input color  BearColor    = clrRed;    // Text color when signal is SELL
input color  NeutralColor = clrGold;   // Text color when signal is NEUTRAL

input group "=== ALERTS ==="
input bool   EnablePopup = true;
input bool   EnablePush  = true;

input group "=== SIGNAL FILTER ==="
input bool   SignalOnClosedBar = true;   // Only evaluate on closed bars (recommended)
input int    MinScore           = 70;    // Minimum confluence score (0-100) to fire a signal

input group "=== FACTOR WEIGHTS (must sum to ~100) ==="
input double W_Trend     = 25.0;   // EMA alignment weight
input double W_ADX       = 20.0;   // ADX trend-strength weight
input double W_RSI       = 15.0;   // RSI momentum weight
input double W_MACD      = 20.0;   // MACD momentum (ATR-normalized) weight
input double W_Structure = 20.0;   // Confirmed swing-structure weight

input group "=== INDICATOR PERIODS ==="
input int    EMA_Fast    = 20;
input int    EMA_Medium  = 50;
input int    EMA_Slow    = 200;
input int    ADX_Period  = 14;
input int    RSI_Period  = 14;
input int    MACD_Fast   = 12;
input int    MACD_Slow   = 26;
input int    MACD_Signal = 9;
input int    ATR_Period  = 14;
input int    VolumeLookback = 20;    // Bars used for average-volume confidence check

input group "=== ADAPTIVE HISTORY (needed for Monthly/Weekly charts) ==="
input bool   AutoAdaptPeriods = true;  // Auto-scale periods down if history is too short (e.g. MN1)
input int    StructureLookback = 300;  // Bars requested for swing structure (auto-capped to what's available)
input int    MinBarsRequired   = 30;   // Absolute floor of bars before the indicator calculates anything

input group "=== RISK PARAMETERS ==="
input double ATR_Multiplier = 2.0;   // Stop distance = ATR * multiplier
input int    BufferPoints   = 10;    // Extra spread buffer in points
input double InpRRR         = 2.0;   // Reward:Risk multiplier for TP

input group "=== PERFORMANCE & STABILITY ==="
input int    MinRecalcIntervalMs = 200; // Min ms between recalculations when SignalOnClosedBar=false (CPU guard)

//--- Handles
int hEmaFast = INVALID_HANDLE, hEmaMed = INVALID_HANDLE, hEmaSlow = INVALID_HANDLE;
int hADX = INVALID_HANDLE, hRSI = INVALID_HANDLE, hMACD = INVALID_HANDLE, hATR = INVALID_HANDLE;

//--- Currently active periods (may differ from inputs when AutoAdaptPeriods scales them down)
int curEmaFast=-1, curEmaMed=-1, curEmaSlow=-1, curADX=-1, curRSI=-1, curATR=-1;
int curMacdFast=-1, curMacdSlow=-1, curMacdSignal=-1;
bool periodsAdapted = false;

//--- Effective (validated/clamped) display settings, computed once in OnInit
int effFontSize, effTextX, effTextY;

//--- UI object names
string labelLine1, labelLine2, labelLine3;

//--- Cache of last rendered text, to skip redundant ObjectSetString/ChartRedraw calls
string lastTxt1 = "", lastTxt2 = "", lastTxt3 = "";
color  lastColor = clrNONE;

//--- State
datetime lastBarTime  = 0;
int      lastSignal   = 0;
ulong    lastCalcMs    = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   // Defensive clamping: never let a bad input produce an invisible or malformed panel
   effFontSize = (int)Clamp(FontSize, 6, 72);
   effTextX    = (int)MathMax(0, TextX);
   effTextY    = (int)MathMax(0, TextY);

   labelLine1 = "STS_L1_" + _Symbol + "_" + IntegerToString(_Period) + "_" + IntegerToString(ChartID());
   labelLine2 = "STS_L2_" + _Symbol + "_" + IntegerToString(_Period) + "_" + IntegerToString(ChartID());
   labelLine3 = "STS_L3_" + _Symbol + "_" + IntegerToString(_Period) + "_" + IntegerToString(ChartID());

   if(!CreateHandles(EMA_Fast, EMA_Medium, EMA_Slow, ADX_Period, RSI_Period,
                      MACD_Fast, MACD_Slow, MACD_Signal, ATR_Period))
     {
      PrintFormat("CRITICAL ERROR: failed to create one or more indicator handles. Error=%d", GetLastError());
      return(INIT_FAILED);
     }

   if(!CreateLabel(labelLine1, effTextY) ||
      !CreateLabel(labelLine2, effTextY + effFontSize + 8) ||
      !CreateLabel(labelLine3, effTextY + 2*(effFontSize + 8)))
     {
      PrintFormat("CRITICAL ERROR: failed to create panel UI objects. Error=%d", GetLastError());
      return(INIT_FAILED);
     }

   if(MathAbs((W_Trend+W_ADX+W_RSI+W_MACD+W_Structure) - 100.0) > 0.01)
      PrintFormat("SmartTrendScore v2: factor weights sum to %.1f, not 100 — score is still normalized correctly, but consider adjusting inputs for clarity.",
                  W_Trend+W_ADX+W_RSI+W_MACD+W_Structure);

   return(INIT_SUCCEEDED);
  }

bool CreateLabel(string name, int yOffset)
  {
   ObjectDelete(0, name);
   if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0)) return false;
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, effTextX);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yOffset);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, effFontSize);
   ObjectSetString(0, name, OBJPROP_FONT, FontName);
   return true;
  }

//+------------------------------------------------------------------+
//| (Re)create all indicator handles with the given periods.         |
//| Only called at init, and later if AutoAdaptPeriods needs to      |
//| shrink periods to fit whatever history is actually available     |
//| on the current timeframe (e.g. Monthly charts with short history)|
//+------------------------------------------------------------------+
bool CreateHandles(int pEmaFast, int pEmaMed, int pEmaSlow, int pADX, int pRSI,
                    int pMacdFast, int pMacdSlow, int pMacdSignal, int pATR)
  {
   int newEmaFast = iMA(_Symbol, _Period, pEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   int newEmaMed  = iMA(_Symbol, _Period, pEmaMed,  0, MODE_EMA, PRICE_CLOSE);
   int newEmaSlow = iMA(_Symbol, _Period, pEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   int newADX     = iADX(_Symbol, _Period, pADX);
   int newRSI     = iRSI(_Symbol, _Period, pRSI, PRICE_CLOSE);
   int newMACD    = iMACD(_Symbol, _Period, pMacdFast, pMacdSlow, pMacdSignal, PRICE_CLOSE);
   int newATR     = iATR(_Symbol, _Period, pATR);

   if(newEmaFast==INVALID_HANDLE || newEmaMed==INVALID_HANDLE || newEmaSlow==INVALID_HANDLE ||
      newADX==INVALID_HANDLE || newRSI==INVALID_HANDLE || newMACD==INVALID_HANDLE || newATR==INVALID_HANDLE)
     {
      PrintFormat("ERROR creating handles (EmaF=%d EmaM=%d EmaS=%d ADX=%d RSI=%d MACD=%d/%d/%d ATR=%d) Error=%d",
                  pEmaFast, pEmaMed, pEmaSlow, pADX, pRSI, pMacdFast, pMacdSlow, pMacdSignal, pATR, GetLastError());
      if(newEmaFast!=INVALID_HANDLE) IndicatorRelease(newEmaFast);
      if(newEmaMed!=INVALID_HANDLE)  IndicatorRelease(newEmaMed);
      if(newEmaSlow!=INVALID_HANDLE) IndicatorRelease(newEmaSlow);
      if(newADX!=INVALID_HANDLE)     IndicatorRelease(newADX);
      if(newRSI!=INVALID_HANDLE)     IndicatorRelease(newRSI);
      if(newMACD!=INVALID_HANDLE)    IndicatorRelease(newMACD);
      if(newATR!=INVALID_HANDLE)     IndicatorRelease(newATR);
      return false;
     }

   if(hEmaFast!=INVALID_HANDLE) IndicatorRelease(hEmaFast);
   if(hEmaMed!=INVALID_HANDLE)  IndicatorRelease(hEmaMed);
   if(hEmaSlow!=INVALID_HANDLE) IndicatorRelease(hEmaSlow);
   if(hADX!=INVALID_HANDLE)     IndicatorRelease(hADX);
   if(hRSI!=INVALID_HANDLE)     IndicatorRelease(hRSI);
   if(hMACD!=INVALID_HANDLE)    IndicatorRelease(hMACD);
   if(hATR!=INVALID_HANDLE)     IndicatorRelease(hATR);

   hEmaFast = newEmaFast; hEmaMed = newEmaMed; hEmaSlow = newEmaSlow;
   hADX = newADX; hRSI = newRSI; hMACD = newMACD; hATR = newATR;

   curEmaFast = pEmaFast; curEmaMed = pEmaMed; curEmaSlow = pEmaSlow;
   curADX = pADX; curRSI = pRSI; curATR = pATR;
   curMacdFast = pMacdFast; curMacdSlow = pMacdSlow; curMacdSignal = pMacdSignal;

   return true;
  }

//+------------------------------------------------------------------+
//| Helper: clamp a double between lo and hi                         |
//+------------------------------------------------------------------+
double Clamp(double v, double lo, double hi)
  {
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
  }

//+------------------------------------------------------------------+
//| Find last 2 CONFIRMED fractal highs/lows (5-bar, closed only)    |
//| Series-indexed arrays: index 0 = most recent (possibly forming)  |
//+------------------------------------------------------------------+
bool FindConfirmedStructure(int shift, int lookback, double &lastHigh, double &prevHigh,
                             double &lastLow, double &prevLow)
  {
   if(lookback < 20) return false; // not enough bars for a meaningful swing scan
   double hi[], lo[];
   ArraySetAsSeries(hi, true);
   ArraySetAsSeries(lo, true);
   if(CopyHigh(_Symbol, _Period, 0, lookback, hi) < lookback) return false;
   if(CopyLow(_Symbol, _Period, 0, lookback, lo)  < lookback) return false;

   int highsFound = 0, lowsFound = 0;
   double highVals[2], lowVals[2];

   // A fractal at index i needs i-2 and i+2 both available and CLOSED
   // (i.e. i-2 must be >= shift so we never touch the forming bar)
   for(int i = shift + 2; i <= lookback - 3 && (highsFound < 2 || lowsFound < 2); i++)
     {
      if(highsFound < 2)
        {
         bool isHigh = true;
         for(int k = i-2; k <= i+2; k++)
            if(k != i && hi[k] >= hi[i]) { isHigh = false; break; }
         if(isHigh) { highVals[highsFound] = hi[i]; highsFound++; }
        }
      if(lowsFound < 2)
        {
         bool isLow = true;
         for(int k = i-2; k <= i+2; k++)
            if(k != i && lo[k] <= lo[i]) { isLow = false; break; }
         if(isLow) { lowVals[lowsFound] = lo[i]; lowsFound++; }
        }
     }

   if(highsFound < 2 || lowsFound < 2) return false;

   lastHigh = highVals[0]; prevHigh = highVals[1];
   lastLow  = lowVals[0];  prevLow  = lowVals[1];
   return true;
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < MinBarsRequired) return(0); // absolute floor, not a fixed 250

   // CPU guard: when reacting to every tick (SignalOnClosedBar=false), don't
   // recompute more often than MinRecalcIntervalMs. Keeps the chart fluid
   // on fast-ticking symbols instead of recalculating hundreds of times/sec.
   if(!SignalOnClosedBar)
     {
      ulong nowMs = GetTickCount();
      if(lastCalcMs != 0 && (nowMs - lastCalcMs) < (ulong)MathMax(0, MinRecalcIntervalMs))
         return(rates_total);
      lastCalcMs = nowMs;
     }

   datetime currentTime[];
   ArraySetAsSeries(currentTime, true);
   if(CopyTime(_Symbol, _Period, 0, 1, currentTime) < 1) return(0);

   if(SignalOnClosedBar && currentTime[0] == lastBarTime && prev_calculated > 0)
      return(rates_total);
   lastBarTime = currentTime[0];

   int shift = SignalOnClosedBar ? 1 : 0;

   //--- Adaptive period scaling: on timeframes with short history (typically
   //--- Monthly/Weekly), the requested EMA_Slow/etc. periods may exceed what's
   //--- actually available. Scale everything down proportionally so the
   //--- indicator still produces a real reading instead of staying blank.
   int usableBars = rates_total - shift - 5;
   if(usableBars < 15) return(0);

   int targetEmaFast = EMA_Fast, targetEmaMed = EMA_Medium, targetEmaSlow = EMA_Slow;
   int targetADX = ADX_Period, targetRSI = RSI_Period, targetATR = ATR_Period;
   int targetMacdFast = MACD_Fast, targetMacdSlow = MACD_Slow, targetMacdSignal = MACD_Signal;
   bool adaptedNow = false;

   if(AutoAdaptPeriods && usableBars < EMA_Slow)
     {
      double scale = Clamp((double)usableBars / (double)EMA_Slow, 0.05, 1.0);
      targetEmaSlow    = (int)MathMax(10, MathRound(EMA_Slow    * scale));
      targetEmaMed     = (int)MathMax(5,  MathRound(EMA_Medium  * scale));
      targetEmaFast    = (int)MathMax(3,  MathRound(EMA_Fast    * scale));
      targetADX        = (int)MathMax(5,  MathRound(ADX_Period  * scale));
      targetRSI        = (int)MathMax(5,  MathRound(RSI_Period  * scale));
      targetATR        = (int)MathMax(5,  MathRound(ATR_Period  * scale));
      targetMacdSlow   = (int)MathMax(6,  MathRound(MACD_Slow   * scale));
      targetMacdFast   = (int)MathMax(3,  MathRound(MACD_Fast   * scale));
      if(targetMacdFast >= targetMacdSlow) targetMacdFast = (int)MathMax(3, targetMacdSlow - 2);
      targetMacdSignal = (int)MathMax(3,  MathRound(MACD_Signal * scale));
      adaptedNow = true;
     }

   if(targetEmaFast!=curEmaFast || targetEmaMed!=curEmaMed || targetEmaSlow!=curEmaSlow ||
      targetADX!=curADX || targetRSI!=curRSI || targetATR!=curATR ||
      targetMacdFast!=curMacdFast || targetMacdSlow!=curMacdSlow || targetMacdSignal!=curMacdSignal)
     {
      if(!CreateHandles(targetEmaFast, targetEmaMed, targetEmaSlow, targetADX, targetRSI,
                         targetMacdFast, targetMacdSlow, targetMacdSignal, targetATR))
         return(0);
     }
   periodsAdapted = adaptedNow;

   // Safety: freshly (re)created handles need a moment to compute their own
   // history. Reading them before they're ready would give stale/partial
   // values, so we bail out gracefully and simply retry on the next tick.
   int needBars = shift + 2;
   if(BarsCalculated(hEmaFast)<needBars || BarsCalculated(hEmaMed)<needBars || BarsCalculated(hEmaSlow)<needBars ||
      BarsCalculated(hADX)<needBars || BarsCalculated(hRSI)<needBars || BarsCalculated(hMACD)<needBars ||
      BarsCalculated(hATR)<needBars)
      return(0);

   //--- Pull all buffers at the evaluation shift (closed bar if SignalOnClosedBar)
   double emaFastB[], emaMedB[], emaSlowB[], adxB[], diPlusB[], diMinusB[], rsiB[], macdB[], sigB[], atrB[];
   ArraySetAsSeries(emaFastB,true); ArraySetAsSeries(emaMedB,true); ArraySetAsSeries(emaSlowB,true);
   ArraySetAsSeries(adxB,true); ArraySetAsSeries(diPlusB,true); ArraySetAsSeries(diMinusB,true);
   ArraySetAsSeries(rsiB,true); ArraySetAsSeries(macdB,true); ArraySetAsSeries(sigB,true); ArraySetAsSeries(atrB,true);

   if(CopyBuffer(hEmaFast, 0, shift, 1, emaFastB) < 1) return(0);
   if(CopyBuffer(hEmaMed,  0, shift, 1, emaMedB)  < 1) return(0);
   if(CopyBuffer(hEmaSlow, 0, shift, 1, emaSlowB) < 1) return(0);
   if(CopyBuffer(hADX, 0, shift, 1, adxB)     < 1) return(0);
   if(CopyBuffer(hADX, 1, shift, 1, diPlusB)  < 1) return(0);
   if(CopyBuffer(hADX, 2, shift, 1, diMinusB) < 1) return(0);
   if(CopyBuffer(hRSI, 0, shift, 1, rsiB) < 1) return(0);
   if(CopyBuffer(hMACD, 0, shift, 1, macdB) < 1) return(0);
   if(CopyBuffer(hMACD, 1, shift, 1, sigB)  < 1) return(0);
   if(CopyBuffer(hATR, 0, shift, 1, atrB) < 1 || atrB[0] <= 0) return(0);

   //--- 1) Trend component: EMA fast/medium/slow alignment -> [-1,+1]
   double trendComp;
   bool fastAboveMed = emaFastB[0] > emaMedB[0];
   bool medAboveSlow = emaMedB[0]  > emaSlowB[0];
   trendComp = ((fastAboveMed ? 1.0 : -1.0) + (medAboveSlow ? 1.0 : -1.0)) / 2.0;

   //--- 2) ADX component: direction from DI+/DI-, strength scaled by ADX value -> [-1,+1]
   double adxStrength = Clamp(adxB[0] / 50.0, 0.0, 1.0); // ADX>=50 = max strength
   double adxDir = (diPlusB[0] > diMinusB[0]) ? 1.0 : -1.0;
   double adxComp = adxDir * adxStrength;

   //--- 3) RSI component: distance from 50, normalized -> [-1,+1]
   double rsiComp = Clamp((rsiB[0] - 50.0) / 50.0, -1.0, 1.0);

   //--- 4) MACD component: histogram normalized by ATR (volatility-adjusted) -> [-1,+1]
   double hist = macdB[0] - sigB[0];
   double macdComp = Clamp(hist / atrB[0], -1.0, 1.0);

   //--- 5) Structure component: confirmed swing highs/lows (HH+HL vs LH+LL) -> {-1,0,+1}
   double lastHigh, prevHigh, lastLow, prevLow;
   double structComp = 0.0;
   int effectiveLookback = (int)MathMin((double)StructureLookback, (double)usableBars);
   bool haveStructure = FindConfirmedStructure(shift, effectiveLookback, lastHigh, prevHigh, lastLow, prevLow);
   if(haveStructure)
     {
      if(lastHigh > prevHigh && lastLow > prevLow) structComp = 1.0;   // Higher High + Higher Low
      else if(lastHigh < prevHigh && lastLow < prevLow) structComp = -1.0; // Lower High + Lower Low
      else structComp = 0.0; // mixed structure, no clean trend confirmation
     }

   //--- Weighted signed score in [-100,+100]
   double totalW = W_Trend + W_ADX + W_RSI + W_MACD + W_Structure;
   if(totalW <= 0.0) totalW = 100.0; // safety: never divide by zero on a bad weight config
   double signedScore = (W_Trend*trendComp + W_ADX*adxComp + W_RSI*rsiComp +
                          W_MACD*macdComp + W_Structure*structComp) / (totalW/100.0);

   //--- Volume confidence multiplier: is current closed-bar volume above/below average?
   long volBuf[];
   ArraySetAsSeries(volBuf, true);
   double volMultiplier = 1.0;
   int volLookback = (int)MathMax(2, VolumeLookback); // need at least 2 bars to average anything
   if(CopyTickVolume(_Symbol, _Period, shift, volLookback, volBuf) == volLookback)
     {
      double avgVol = 0;
      for(int i = 1; i < volLookback; i++) avgVol += (double)volBuf[i]; // exclude eval bar itself
      avgVol /= (volLookback - 1);
      if(avgVol > 0)
        {
         double ratio = (double)volBuf[0] / avgVol;
         volMultiplier = Clamp(0.85 + (ratio - 1.0) * 0.15, 0.85, 1.15);
        }
     }

   double finalScore = Clamp(MathAbs(signedScore) * volMultiplier, 0.0, 100.0);
   int direction = (signedScore > 0) ? 1 : (signedScore < 0 ? -1 : 0);

   int currentSignal = (finalScore >= MinScore) ? direction : 0;

   //--- Risk levels
   double entry = iClose(_Symbol, _Period, shift);
   if(entry <= 0) return(0);
   double slDistance = (atrB[0] * ATR_Multiplier) + (BufferPoints * _Point);
   double sl = 0.0, tp = 0.0;
   if(currentSignal == 1) { sl = entry - slDistance; tp = entry + slDistance * InpRRR; }
   else if(currentSignal == -1) { sl = entry + slDistance; tp = entry - slDistance * InpRRR; }

   //--- UI
   string txtLine1, txtLine2, txtLine3;
   color panelColor;

   if(currentSignal == 0)
     {
      txtLine1 = StringFormat("SIGNAL: NEUTRAL  [ SCORE: %.0f%% ]", finalScore);
      panelColor = NeutralColor;
      txtLine3 = "ENTRY: -  |  SL: -  |  TP: -";
     }
   else
     {
      string sigStr = (currentSignal == 1) ? "BUY " : "SELL";
      panelColor = (currentSignal == 1) ? BullColor : BearColor;
      txtLine1 = "SIGNAL: " + sigStr + "  [ SCORE: " + DoubleToString(finalScore,0) + "% ]";
      txtLine3 = "ENTRY: " + DoubleToString(entry,_Digits) +
                 "  |  SL: " + DoubleToString(sl,_Digits) +
                 "  |  TP: " + DoubleToString(tp,_Digits);
     }

   txtLine2 = StringFormat("T:%+.0f  ADX:%+.0f  RSI:%+.0f  MACD:%+.0f  STR:%+.0f  VOL x%.2f%s",
                            trendComp*100, adxComp*100, rsiComp*100, macdComp*100, structComp*100, volMultiplier,
                            periodsAdapted ? "  [ADAPTIVE PERIODS]" : "");

   // Only touch chart objects (and redraw) when the visible content actually
   // changed. Avoids needless GUI work on every tick, keeping the terminal
   // responsive even on fast-moving symbols or weaker PCs.
   bool changed = (txtLine1 != lastTxt1) || (txtLine2 != lastTxt2) || (txtLine3 != lastTxt3) || (panelColor != lastColor);
   if(changed)
     {
      ObjectSetString(0, labelLine1, OBJPROP_TEXT, txtLine1);
      ObjectSetInteger(0, labelLine1, OBJPROP_COLOR, panelColor);
      ObjectSetString(0, labelLine2, OBJPROP_TEXT, txtLine2);
      ObjectSetInteger(0, labelLine2, OBJPROP_COLOR, panelColor);
      ObjectSetString(0, labelLine3, OBJPROP_TEXT, txtLine3);
      ObjectSetInteger(0, labelLine3, OBJPROP_COLOR, panelColor);
      ChartRedraw(0);

      lastTxt1 = txtLine1; lastTxt2 = txtLine2; lastTxt3 = txtLine3; lastColor = panelColor;
     }

   //--- Alerts, only on new confirmed signal change
   if(currentSignal != 0 && currentSignal != lastSignal)
     {
      string sigStr = (currentSignal == 1) ? "BUY" : "SELL";
      string msg = StringFormat("[SmartTrendScore v2] %s %s | Score:%.0f%% | Entry:%s SL:%s TP:%s",
                                 sigStr, _Symbol, finalScore,
                                 DoubleToString(entry,_Digits), DoubleToString(sl,_Digits), DoubleToString(tp,_Digits));
      if(EnablePopup) Alert(msg);
      if(EnablePush)  SendNotification(msg);
      lastSignal = currentSignal;
     }
   else if(currentSignal == 0)
     {
      lastSignal = 0;
     }

   return(rates_total);
  }

void OnDeinit(const int reason)
  {
   ObjectDelete(0, labelLine1);
   ObjectDelete(0, labelLine2);
   ObjectDelete(0, labelLine3);
   if(hEmaFast != INVALID_HANDLE) IndicatorRelease(hEmaFast);
   if(hEmaMed  != INVALID_HANDLE) IndicatorRelease(hEmaMed);
   if(hEmaSlow != INVALID_HANDLE) IndicatorRelease(hEmaSlow);
   if(hADX     != INVALID_HANDLE) IndicatorRelease(hADX);
   if(hRSI     != INVALID_HANDLE) IndicatorRelease(hRSI);
   if(hMACD    != INVALID_HANDLE) IndicatorRelease(hMACD);
   if(hATR     != INVALID_HANDLE) IndicatorRelease(hATR);
  }
