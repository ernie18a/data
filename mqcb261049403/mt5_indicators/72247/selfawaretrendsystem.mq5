//+------------------------------------------------------------------+
//|                    SelfAwareTrendSystem.mq5                      |
//|                      Hammad Dilber                               |
//|                  Self-Aware Trend System v1.8.1                  |
//+------------------------------------------------------------------+
#property copyright   "Hammad Dilber"
#property version     "1.82"
#property description "Self-Aware Trend System — Adaptive SuperTrend with TQI Dashboard"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1

#property indicator_label1  "SuperTrend"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//+------------------------------------------------------------------+
//| ENUMS FOR DROPDOWNS                                               |
//+------------------------------------------------------------------+

enum ENUM_PRESET
{
   PRESET_AUTO       = 0,  // Auto
   PRESET_CUSTOM     = 1,  // Custom
   PRESET_SCALPING   = 2,  // Scalping
   PRESET_DEFAULT    = 3,  // Default
   PRESET_SWING      = 4,  // Swing
   PRESET_CRYPTO     = 5   // Crypto 24/7
};

enum ENUM_SOURCE_TYPE
{
   SRC_CLOSE  = 0,  // Close
   SRC_OPEN   = 1,  // Open
   SRC_HIGH   = 2,  // High
   SRC_LOW    = 3,  // Low
   SRC_HL2    = 4,  // HL2
   SRC_HLC3   = 5   // HLC3
};

enum ENUM_DASH_POSITION
{
   DASH_TOP_RIGHT    = 0,  // Top Right
   DASH_TOP_LEFT     = 1,  // Top Left
   DASH_BOTTOM_RIGHT = 2,  // Bottom Right
   DASH_BOTTOM_LEFT  = 3   // Bottom Left
};

//+------------------------------------------------------------------+
//| INPUT GROUPS                                                      |
//+------------------------------------------------------------------+

// ── Main ──
input group "⚙️ Main Settings"
input ENUM_PRESET      Preset          = PRESET_AUTO;    // Preset
input int              ATR_Length      = 13;             // ATR Length
input double           Base_Mult       = 2.0;            // Base Band Width (xATR)
input ENUM_SOURCE_TYPE Source_Type     = SRC_CLOSE;      // Source Price

// ── Adaptive Engine ──
input group "🧠 Adaptive Engine"
input bool     Use_Adaptive    = true;            // Enable Vol-Adaptive Bands (legacy ER)
input int      ER_Length       = 20;              // Efficiency Window
input double   Adapt_Strength  = 0.5;             // Adaptation Strength
input int      ATR_Baseline_Len= 100;             // ATR Baseline Length

// ── TQI Engine ──
input group "📐 Trend Quality Engine"
input bool     Use_TQI         = true;            // Enable Trend Quality Engine
input double   Quality_Strength= 0.4;             // Quality Influence
input double   Quality_Curve   = 1.5;             // Quality Curve Power
input bool     Mult_Smooth     = true;            // Smooth Adaptive Multipliers
input bool     Use_Asym_Bands  = true;            // Asymmetric Bands
input double   Asym_Strength   = 0.5;             // Asymmetry Strength
input bool     Use_Eff_ATR     = true;            // Efficiency-Weighted ATR
input bool     Use_Char_Flip   = true;            // Character-Flip Detection
input int      CharFlip_MinAge = 5;               // Char-Flip: Min Trend Age (default: 5)
input double   CharFlip_High   = 0.55;            // Char-Flip: High TQI
input double   CharFlip_Low    = 0.25;            // Char-Flip: Low TQI
input double   TQI_Weight_ER   = 0.35;            // Weight: Efficiency
input double   TQI_Weight_Vol  = 0.20;            // Weight: Volatility Regime
input double   TQI_Weight_Struct= 0.25;           // Weight: Structure
input double   TQI_Weight_Mom  = 0.20;            // Weight: Momentum Persist
input int      TQI_Struct_Len  = 20;              // Structure Window
input int      TQI_Mom_Len     = 10;              // Momentum Persist Window

// ── Signal Filters ──
input group "🔍 Signal Filters (Display)"
input bool     Use_Structure   = true;            // Use Structure in Score
input int      Pivot_Len       = 3;               // Pivot Strength
input bool     Use_RSI         = true;            // Use RSI in Score
input int      RSI_Len         = 14;              // RSI Length
input int      RSI_OB          = 70;              // RSI Overbought
input int      RSI_OS          = 30;              // RSI Oversold
input int      RSI_Lookback    = 20;              // RSI Memory (bars)
input bool     Use_Vol         = true;            // Use Volume in Score
input int      Vol_Len         = 20;              // Volume Z Window
input int      Min_Score       = 60;              // Min Score threshold (half used as soft floor)

// ── Risk Management ──
input group "🎯 Risk Management"
input bool     Show_Risk       = true;            // Show TP/SL Levels
input double   SL_ATR_Mult     = 1.5;             // SL Buffer (xATR)
input double   TP1_R           = 1.0;             // TP1 (R-multiple)
input double   TP2_R           = 2.0;             // TP2 (R-multiple)
input double   TP3_R           = 3.0;             // TP3 (R-multiple)
input int      Label_Offset    = 10;              // Label Offset (bars)
input bool     Show_Hits       = true;            // Mark TP Hits
input int      Trade_MaxAge    = 100;             // Trade Timeout (bars)

// ── Self-Learning ──
input group "🤖 Self-Learning"
input bool     Use_AutoCalib   = false;           // Enable Auto-Calibration (experimental)
input int      Calib_Window    = 20;              // Calibration Window
input double   Calib_BadR      = 0.0;             // Bad-Edge Threshold (R)
input double   Calib_GoodR     = 0.7;             // Good-Edge Threshold (R)
input double   Calib_StepQ     = 0.05;            // Quality Step
input int      Calib_Cooldown  = 5;               // Calibration Cooldown (signals)
input double   Calib_MinQ      = 0.1;             // Quality Floor
input double   Calib_MaxQ      = 0.9;             // Quality Ceiling

// ── Visual ──
input group "🎨 Visual"
input bool     Show_Bands      = true;            // Show SuperTrend Bands
input bool     Show_TQI_Color  = true;            // Color Line by TQI
input bool     Show_Signals    = true;            // Show Signal Labels
input bool     Show_BG         = false;           // Show Trend Background
input bool     Show_Watermark  = true;            // Show Watermark

// ── Dashboard ──
input group "📊 Dashboard"
input bool     Show_Dash         = true;          // Show Dashboard
input bool     Show_TQI_Breakdown= true;          // Show TQI Breakdown
input bool     Show_Score_Breakdown= false;       // Show Score Breakdown (legacy)
input bool     Show_Perf         = true;          // Show Performance Stats
input ENUM_DASH_POSITION Dash_Position = DASH_TOP_RIGHT; // Dashboard Position

// ── Colors ──
input group "🎨 Colors"
input color    Bull_Color      = C'0,230,118';    // Bull Color
input color    Bear_Color      = C'255,82,82';    // Bear Color
input color    SL_Color        = C'255,23,68';    // SL Color
input color    TP_Color        = C'0,230,118';    // TP Color

// ── Alerts ──
input group "🔔 Alerts"
input bool     Enable_Alerts   = true;            // Enable Alert Signals
input bool     Webhook_JSON    = false;           // Webhook JSON Format

//+------------------------------------------------------------------+
//| CONSTANTS                                                         |
//+------------------------------------------------------------------+
#define INDICATOR_VERSION    "v1.8.3"
#define WARMUP_FLOOR         50
#define MAX_HISTORY_SIGS     100
#define BYPASS_SCORE         12.0
#define MAX_SCORE_REF        102
#define ER_LOW_THRESH        0.25
#define ER_HIGH_THRESH       0.50
#define VOL_LOW_THRESH       0.7
#define VOL_HIGH_THRESH      1.3
#define EWMA_ALPHA           0.2
#define MULT_SMOOTH_ALPHA    0.15

//+------------------------------------------------------------------+
//| INDICATOR BUFFERS                                                 |
//+------------------------------------------------------------------+
double   STBuffer[];      // SuperTrend line value
double   UpperBandBuf[];
double   LowerBandBuf[];

//+------------------------------------------------------------------+
//| BUILT-IN INDICATOR HANDLES (fast, cached by MT5)                 |
//+------------------------------------------------------------------+
int      g_hATR        = INVALID_HANDLE;
int      g_hRSI        = INVALID_HANDLE;
int      g_hATRBase    = INVALID_HANDLE;  // for ATR baseline (longer period)

//+------------------------------------------------------------------+
//| GLOBAL STATE                                                      |
//+------------------------------------------------------------------+
// SuperTrend state
double   g_lowerBand       = EMPTY_VALUE;
double   g_upperBand       = EMPTY_VALUE;
int      g_stTrend         = 1;
int      g_trendStartBar   = 0;

// Multiplier smoothing
double   g_activeMultSm    = EMPTY_VALUE;
double   g_passiveMultSm   = EMPTY_VALUE;

// TQI adaptive quality strength
double   g_effectiveQStr   = 0.4;

// Trade state
int      g_tradeDir        = 0;
int      g_tradeEntryBar   = 0;
double   g_tradeEntry      = EMPTY_VALUE;
double   g_tradeSL         = EMPTY_VALUE;
double   g_tradeTp1        = EMPTY_VALUE;
double   g_tradeTp2        = EMPTY_VALUE;
double   g_tradeTp3        = EMPTY_VALUE;
bool     g_hitTp1          = false;
bool     g_hitTp2          = false;
bool     g_hitTp3          = false;
int      g_tradeCellIdx    = -1;

// Signal tracking
int      g_lastDisplaySide = 0;
int      g_lastSignalBar   = 0;
double   g_lastPivotHigh   = EMPTY_VALUE;
double   g_lastPivotLow    = EMPTY_VALUE;

// Score breakdown (last signal)
double   g_lastM=0, g_lastE=0, g_lastV=0, g_lastR=0, g_lastS=0, g_lastB=0;

// Performance tracking
double   g_signalRBuffer[];
double   g_gridEwmR[9];
int      g_gridCount[9];
double   g_allTimeRSum     = 0.0;
int      g_allTimeCount    = 0;
double   g_allTimePeak     = 0.0;
double   g_allTimeTrough   = 0.0;
double   g_allTimeCumR     = 0.0;
int      g_curWinStreak    = 0;
int      g_curLossStreak   = 0;
int      g_maxWinStreak    = 0;
int      g_maxLossStreak   = 0;
int      g_signalsSinceCalib = 0;

// Previous TQI for char-flip
double   g_prevTqi         = 0.5;

// Preset resolved params
int      g_effectiveAtrLen   = 13;
int      g_effectiveErLen    = 20;
int      g_effectiveRsiLen   = 14;
double   g_effectiveBaseMult = 2.0;
double   g_effectiveSlMult   = 1.5;
double   g_fixedTp1R        = 1.0;
double   g_fixedTp2R        = 2.0;
double   g_fixedTp3R        = 3.0;

// Dashboard label name
string   g_dashLabelPrefix = "SATS_DASH_";
string   g_wmLabel         = "SATS_WM";
// Track dashboard object names for fast deletion (avoids full ObjectsTotal scan)
string   g_dashObjNames[];
int      g_dashObjCount    = 0;

// TP/SL line names
string   g_lineEntry = "SATS_LINE_ENTRY";
string   g_lineSL    = "SATS_LINE_SL";
string   g_lineTp1   = "SATS_LINE_TP1";
string   g_lineTp2   = "SATS_LINE_TP2";
string   g_lineTp3   = "SATS_LINE_TP3";

// Warmup
int      g_warmupBars = 50;

// Alert spam guard: true during historical full-recalc, alerts suppressed
bool     g_isHistoricalRun = false;

// ── Non-Repainting Dashboard Snapshot ──
// These are set from shift=1 (last CLOSED bar) to prevent dashboard values
// from changing on chart refresh (repainting fix)
double   g_snapTqi         = 0.5;
double   g_snapTqiEr       = 0.5;
double   g_snapTqiVol      = 0.5;
double   g_snapTqiStruct   = 0.5;
double   g_snapTqiMom      = 0.5;
double   g_snapErVal       = 0.3;
double   g_snapRsiVal      = 50.0;
double   g_snapVolZ        = 0.0;
bool     g_snapHasVol      = false;
int      g_snapStTrend     = 1;
bool     g_snapConfirmedBuy  = false;
bool     g_snapConfirmedSell = false;
double   g_snapVolRatio    = 1.0;
bool     g_snapIsWarmedUp  = false;
string   g_snapPreset      = "Default";
bool     g_snapReady       = false;  // true once shift=1 has been processed

//+------------------------------------------------------------------+
//| HELPER: Resolve preset                                            |
//+------------------------------------------------------------------+
void ResolvePreset()
{
   ENUM_PRESET resolvedPreset = Preset;
   if(Preset == PRESET_AUTO)
   {
      int tfMin = (int)PeriodSeconds(PERIOD_CURRENT) / 60;
      if(tfMin <= 5)        resolvedPreset = PRESET_SCALPING;
      else if(tfMin <= 240) resolvedPreset = PRESET_DEFAULT;
      else                  resolvedPreset = PRESET_SWING;
   }

   if(resolvedPreset == PRESET_SCALPING)      { g_effectiveAtrLen=10; g_effectiveBaseMult=1.5; g_effectiveErLen=14; g_effectiveRsiLen=9;  g_effectiveSlMult=1.0; }
   else if(resolvedPreset == PRESET_DEFAULT)  { g_effectiveAtrLen=14; g_effectiveBaseMult=2.0; g_effectiveErLen=20; g_effectiveRsiLen=14; g_effectiveSlMult=1.5; }
   else if(resolvedPreset == PRESET_SWING)    { g_effectiveAtrLen=21; g_effectiveBaseMult=2.5; g_effectiveErLen=30; g_effectiveRsiLen=21; g_effectiveSlMult=2.0; }
   else if(resolvedPreset == PRESET_CRYPTO)   { g_effectiveAtrLen=14; g_effectiveBaseMult=2.8; g_effectiveErLen=20; g_effectiveRsiLen=14; g_effectiveSlMult=2.5; }
   else { // Custom
      g_effectiveAtrLen   = ATR_Length;
      g_effectiveBaseMult = Base_Mult;
      g_effectiveErLen    = ER_Length;
      g_effectiveRsiLen   = RSI_Len;
      g_effectiveSlMult   = SL_ATR_Mult;
   }

   // TP order auto-fix
   double t1=TP1_R, t2=TP2_R, t3=TP3_R;
   g_fixedTp1R = MathMin(t1, MathMin(t2, t3));
   g_fixedTp3R = MathMax(t1, MathMax(t2, t3));
   g_fixedTp2R = t1 + t2 + t3 - g_fixedTp1R - g_fixedTp3R;
}

//+------------------------------------------------------------------+
//| HELPER: Clamp                                                     |
//+------------------------------------------------------------------+
double Clamp(double v, double lo, double hi) { return MathMax(lo, MathMin(hi, v)); }
int    ClampInt(int v, int lo, int hi)       { return MathMax(lo, MathMin(hi, v)); }

//+------------------------------------------------------------------+
//| HELPER: Safe division                                             |
//+------------------------------------------------------------------+
double SafeDiv(double num, double den, double fallback=0.0)
{
   if(den == 0.0 || den == EMPTY_VALUE || num == EMPTY_VALUE) return fallback;
   return num / den;
}

//+------------------------------------------------------------------+
//| HELPER: Map + Clamp                                               |
//+------------------------------------------------------------------+
double MapClamp(double v, double inLo, double inHi, double outLo, double outHi)
{
   double t = Clamp(SafeDiv(v - inLo, inHi - inLo, 0.0), 0.0, 1.0);
   return outLo + t * (outHi - outLo);
}

double MapClampInv(double v, double inLo, double inHi, double outHigh, double outLow)
{
   double t = Clamp(SafeDiv(v - inLo, inHi - inLo, 0.0), 0.0, 1.0);
   return outHigh - t * (outHigh - outLow);
}

//+------------------------------------------------------------------+
//| HELPER: Source price                                              |
//+------------------------------------------------------------------+
double GetSource(int shift)
{
   switch(Source_Type)
   {
      case SRC_CLOSE: return iClose(_Symbol, PERIOD_CURRENT, shift);
      case SRC_OPEN:  return iOpen (_Symbol, PERIOD_CURRENT, shift);
      case SRC_HIGH:  return iHigh (_Symbol, PERIOD_CURRENT, shift);
      case SRC_LOW:   return iLow  (_Symbol, PERIOD_CURRENT, shift);
      case SRC_HL2:   return (iHigh(_Symbol,PERIOD_CURRENT,shift)+iLow(_Symbol,PERIOD_CURRENT,shift))/2.0;
      case SRC_HLC3:  return (iHigh(_Symbol,PERIOD_CURRENT,shift)+iLow(_Symbol,PERIOD_CURRENT,shift)+iClose(_Symbol,PERIOD_CURRENT,shift))/3.0;
   }
   return iClose(_Symbol, PERIOD_CURRENT, shift);
}

//+------------------------------------------------------------------+
//| HELPER: Efficiency Ratio — CopyClose for bulk price fetch        |
//+------------------------------------------------------------------+
double CalcEfficiencyRatio(int shift, int len)
{
   double src[];
   ArraySetAsSeries(src, true);
   // Copy len+1 prices (need shift through shift+len inclusive)
   int copied = CopyClose(_Symbol, PERIOD_CURRENT, shift, len+1, src);
   if(copied < len+1) return 0.3;

   double change     = MathAbs(src[0] - src[len]);
   double volatility = 0.0;
   for(int i=0; i<len; i++)
      volatility += MathAbs(src[i] - src[i+1]);
   return SafeDiv(change, volatility, 0.0);
}

//+------------------------------------------------------------------+
//| HELPER: Volume Z-Score — bulk CopyTickVolume, single API call    |
//+------------------------------------------------------------------+
double CalcVolumeZ(int shift, int len)
{
   long vols[];
   ArraySetAsSeries(vols, true);
   int copied = CopyTickVolume(_Symbol, PERIOD_CURRENT, shift, len, vols);
   if(copied < len) return 0.0;

   double sumV=0.0, sumV2=0.0;
   for(int i=0; i<len; i++)
   {
      double v = (double)vols[i];
      sumV  += v;
      sumV2 += v*v;
   }
   double mean = sumV / len;
   double var  = (sumV2 / len) - mean*mean;
   double std  = var > 0 ? MathSqrt(var) : 0.0;
   return SafeDiv((double)vols[0] - mean, std, 0.0);
}

//+------------------------------------------------------------------+
//| HELPER: ATR — uses built-in iATR handle (fast, MT5-cached)       |
//+------------------------------------------------------------------+
double CalcATR(int shift, int len)
{
   // Use the pre-created handle that matches current len
   int handle = (len == g_effectiveAtrLen) ? g_hATR : g_hATRBase;
   if(handle == INVALID_HANDLE)
   {
      // Fallback: manual simple ATR (should not normally reach here)
      double sum = 0.0;
      for(int i=shift; i<shift+len; i++)
      {
         double hi  = iHigh (_Symbol,PERIOD_CURRENT,i);
         double lo  = iLow  (_Symbol,PERIOD_CURRENT,i);
         double clp = iClose(_Symbol,PERIOD_CURRENT,i+1);
         double tr  = MathMax(hi-lo, MathMax(MathAbs(hi-clp), MathAbs(lo-clp)));
         sum += tr;
      }
      return sum / len;
   }
   double buf[];
   ArraySetAsSeries(buf, true);
   if(CopyBuffer(handle, 0, shift, 1, buf) == 1)
      return buf[0];
   return _Point;
}

//+------------------------------------------------------------------+
//| HELPER: RSI — uses built-in iRSI handle (Wilder smoothing, fast) |
//+------------------------------------------------------------------+
double CalcRSI(int shift, int len)
{
   if(g_hRSI == INVALID_HANDLE)
   {
      // Fallback: simple average RSI (used only if handle creation failed)
      double gainSum=0.0, lossSum=0.0;
      for(int i=shift; i<shift+len; i++)
      {
         double diff = iClose(_Symbol,PERIOD_CURRENT,i) - iClose(_Symbol,PERIOD_CURRENT,i+1);
         if(diff > 0) gainSum += diff;
         else         lossSum -= diff;
      }
      double avgGain = gainSum / len;
      double avgLoss = lossSum / len;
      if(avgLoss == 0) return 100.0;
      double rs = SafeDiv(avgGain, avgLoss, 0.0);
      return 100.0 - (100.0 / (1.0 + rs));
   }
   double buf[];
   ArraySetAsSeries(buf, true);
   if(CopyBuffer(g_hRSI, 0, shift, 1, buf) == 1)
      return buf[0];
   return 50.0;
}

//+------------------------------------------------------------------+
//| HELPER: ATR Baseline Average — single CopyBuffer call, O(n)     |
//+------------------------------------------------------------------+
double CalcATRBaseline(int shift, int len)
{
   // Pull 'len' ATR values in one call from the baseline handle
   int handle = g_hATRBase;
   if(handle != INVALID_HANDLE)
   {
      double buf[];
      ArraySetAsSeries(buf, true);
      int copied = CopyBuffer(handle, 0, shift, len, buf);
      if(copied > 0)
      {
         double sum = 0.0;
         for(int i=0; i<copied; i++) sum += buf[i];
         return sum / copied;
      }
   }
   // Fallback: single ATR value
   return CalcATR(shift, g_effectiveAtrLen);
}

//+------------------------------------------------------------------+
//| HELPER: Highest/Lowest                                            |
//+------------------------------------------------------------------+
double CalcHighest(int shift, int len)
{
   double mx = iHigh(_Symbol,PERIOD_CURRENT,shift);
   for(int i=shift+1; i<shift+len; i++)
      mx = MathMax(mx, iHigh(_Symbol,PERIOD_CURRENT,i));
   return mx;
}
double CalcLowest(int shift, int len)
{
   double mn = iLow(_Symbol,PERIOD_CURRENT,shift);
   for(int i=shift+1; i<shift+len; i++)
      mn = MathMin(mn, iLow(_Symbol,PERIOD_CURRENT,i));
   return mn;
}

//+------------------------------------------------------------------+
//| HELPER: Pivot High / Low detection                                |
//+------------------------------------------------------------------+
bool IsPivotHigh(int shift, int pLen)
{
   double center = iHigh(_Symbol,PERIOD_CURRENT,shift);
   for(int i=1; i<=pLen; i++)
   {
      if(iHigh(_Symbol,PERIOD_CURRENT,shift-i) >= center) return false;
      if(iHigh(_Symbol,PERIOD_CURRENT,shift+i) >= center) return false;
   }
   return true;
}
bool IsPivotLow(int shift, int pLen)
{
   double center = iLow(_Symbol,PERIOD_CURRENT,shift);
   for(int i=1; i<=pLen; i++)
   {
      if(iLow(_Symbol,PERIOD_CURRENT,shift-i) <= center) return false;
      if(iLow(_Symbol,PERIOD_CURRENT,shift+i) <= center) return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| HELPER: Grid cell index                                           |
//+------------------------------------------------------------------+
int ErBin(double er)   { return er < ER_LOW_THRESH ? 0 : (er < ER_HIGH_THRESH ? 1 : 2); }
int VolBin(double vr)  { return vr < VOL_LOW_THRESH ? 0 : (vr < VOL_HIGH_THRESH ? 1 : 2); }
int CellIdx(int eb, int vb) { return eb*3 + vb; }

//+------------------------------------------------------------------+
//| HELPER: Update grid cell (EWMA)                                   |
//+------------------------------------------------------------------+
void UpdateGridCell(int idx, double r)
{
   if(idx < 0 || idx > 8) return;
   g_gridCount[idx]++;
   g_gridEwmR[idx] = g_gridCount[idx] == 1 ? r : g_gridEwmR[idx]*(1.0-EWMA_ALPHA) + r*EWMA_ALPHA;
}

//+------------------------------------------------------------------+
//| HELPER: Realized R                                                |
//+------------------------------------------------------------------+
double CalcRealizedR(bool slHit, bool tp1H, bool tp2H, bool tp3H, double tp1R, double tp2R, double tp3R)
{
   // 1/3 position closed at each TP level
   double taken     = 0.0;
   double remaining = 1.0;

   if(tp1H) { taken += (1.0/3.0) * tp1R; remaining -= 1.0/3.0; }
   if(tp2H) { taken += (1.0/3.0) * tp2R; remaining -= 1.0/3.0; }
   if(tp3H) { taken += (1.0/3.0) * tp3R; remaining -= 1.0/3.0; }

   if(slHit)
      return taken + remaining * (-1.0);  // remaining position stopped out at -1R

   // No SL hit — return what was taken (TP3 full exit or partial)
   return taken;
}

double CalcTimeoutR(bool tp1H, bool tp2H, bool tp3H, double tp1R, double tp2R, double tp3R)
{
   // 1/3 position per TP level
   double taken = 0.0;
   if(tp1H) taken += (1.0/3.0) * tp1R;
   if(tp2H) taken += (1.0/3.0) * tp2R;
   if(tp3H) taken += (1.0/3.0) * tp3R;
   return taken;
}

//+------------------------------------------------------------------+
//| HELPER: Rolling stats                                             |
//+------------------------------------------------------------------+
void CalcRollingStats(int window, double &winRate, double &avgR, double &minRun)
{
   int n = ArraySize(g_signalRBuffer);
   winRate = 0.0; avgR = 0.0; minRun = 0.0;
   if(n == 0) return;
   int startIdx = MathMax(0, n - window);
   double sumR=0.0, runR=0.0;
   int wins=0;
   for(int i=startIdx; i<n; i++)
   {
      double r = g_signalRBuffer[i];
      sumR += r;
      if(r > 0) wins++;
      runR += r;
      if(runR < minRun) minRun = runR;
   }
   int cnt = n - startIdx;
   winRate = cnt > 0 ? (double)wins / cnt : 0.0;
   avgR    = cnt > 0 ? sumR / cnt : 0.0;
}

//+------------------------------------------------------------------+
//| HELPER: Score breakdown                                           |
//+------------------------------------------------------------------+
void CalcScoreBreakdown(bool isBuy, int shift,
                         double atrVal, double erVal, double rsiVal, double volZ, bool hasVol,
                         double upperBandPrev, double lowerBandPrev,
                         double &mScore, double &eScore, double &vScore,
                         double &rScore, double &sScore, double &bScore)
{
   // dirMove: positive = price moved in signal direction over last 3 bars
   // For buy:  present close > past close  => positive momentum
   // For sell: past close > present close  => positive momentum
   double dirMove = isBuy ? (iClose(_Symbol,PERIOD_CURRENT,shift) - iClose(_Symbol,PERIOD_CURRENT,shift+3))
                          : (iClose(_Symbol,PERIOD_CURRENT,shift+3) - iClose(_Symbol,PERIOD_CURRENT,shift));
   mScore = MapClamp(SafeDiv(dirMove, atrVal, 0.0), 0.3, 2.0, 0.0, 17.0);
   eScore = MapClamp(erVal, 0.15, 0.7, 0.0, 17.0);
   vScore = (Use_Vol && hasVol) ? MapClamp(volZ, 0.0, 3.0, 0.0, 17.0) : BYPASS_SCORE;

   // RSI depth — compute range from already-copied RSI buffer (single CopyBuffer, not 20x CalcRSI)
   double rsiLow = rsiVal, rsiHigh = rsiVal;
   if(Use_RSI && g_hRSI != INVALID_HANDLE)
   {
      double rsiBuf[];
      ArraySetAsSeries(rsiBuf, true);
      int rsiCopied = CopyBuffer(g_hRSI, 0, shift, RSI_Lookback, rsiBuf);
      for(int i=0; i<rsiCopied; i++)
      {
         rsiLow  = MathMin(rsiLow,  rsiBuf[i]);
         rsiHigh = MathMax(rsiHigh, rsiBuf[i]);
      }
   }
   else
   {
      for(int i=shift; i<shift+RSI_Lookback; i++)
      {
         double r = CalcRSI(i, g_effectiveRsiLen);
         rsiLow  = MathMin(rsiLow,  r);
         rsiHigh = MathMax(rsiHigh, r);
      }
   }
   double rsiDepth = isBuy ? MathMax(0.0, RSI_OS - rsiLow) : MathMax(0.0, rsiHigh - RSI_OB);
   rScore = Use_RSI ? MapClamp(rsiDepth, 0.0, 15.0, 0.0, 17.0) : BYPASS_SCORE;

   // Structure
   double pivDist = 0.0;
   if(isBuy && g_lastPivotLow  != EMPTY_VALUE) pivDist = MathAbs(iClose(_Symbol,PERIOD_CURRENT,shift) - g_lastPivotLow);
   if(!isBuy && g_lastPivotHigh!= EMPTY_VALUE) pivDist = MathAbs(g_lastPivotHigh - iClose(_Symbol,PERIOD_CURRENT,shift));
   sScore = Use_Structure ? MapClampInv(SafeDiv(pivDist, atrVal, 0.0), 0.0, 1.5, 16.0, 6.0) : BYPASS_SCORE;

   // Break depth
   double breakDepth = isBuy ? MathMax(0.0, upperBandPrev - iClose(_Symbol,PERIOD_CURRENT,shift+1))
                              : MathMax(0.0, iClose(_Symbol,PERIOD_CURRENT,shift+1) - lowerBandPrev);
   bScore = MapClamp(SafeDiv(breakDepth, atrVal, 0.0), 0.0, 1.0, 0.0, 16.0);
}

double CalcSignalScore(bool isBuy, int shift,
                        double atrVal, double erVal, double rsiVal, double volZ, bool hasVol,
                        double upperBandPrev, double lowerBandPrev)
{
   double m,e,v,r,s,b;
   CalcScoreBreakdown(isBuy,shift,atrVal,erVal,rsiVal,volZ,hasVol,upperBandPrev,lowerBandPrev,m,e,v,r,s,b);
   return m+e+v+r+s+b;
}

//+------------------------------------------------------------------+
//| DELETE old TP/SL lines                                            |
//+------------------------------------------------------------------+
void DeleteTPSLObjects()
{
   ObjectDelete(0, g_lineEntry);
   ObjectDelete(0, g_lineSL);
   ObjectDelete(0, g_lineTp1);
   ObjectDelete(0, g_lineTp2);
   ObjectDelete(0, g_lineTp3);
   ObjectDelete(0, g_lineEntry+"_LBL");
   ObjectDelete(0, g_lineSL   +"_LBL");
   ObjectDelete(0, g_lineTp1  +"_LBL");
   ObjectDelete(0, g_lineTp2  +"_LBL");
   ObjectDelete(0, g_lineTp3  +"_LBL");
}

//+------------------------------------------------------------------+
//| HELPER: Draw a single horizontal trend line + text label          |
//+------------------------------------------------------------------+
void DrawHLine(string name, double price, color clr, ENUM_LINE_STYLE lstyle, int width,
               string labelText, datetime t1, datetime t2)
{
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE,      lstyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,      width);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT,  false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);

   string lbl = name + "_LBL";
   if(ObjectFind(0, lbl) >= 0) ObjectDelete(0, lbl);
   ObjectCreate(0, lbl, OBJ_TEXT, 0, t2, price);
   ObjectSetString (0, lbl, OBJPROP_TEXT,       labelText + " " + DoubleToString(price, _Digits));
   ObjectSetInteger(0, lbl, OBJPROP_COLOR,      clr);
   ObjectSetInteger(0, lbl, OBJPROP_FONTSIZE,   8);
   ObjectSetInteger(0, lbl, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| DRAW TP/SL lines                                                  |
//+------------------------------------------------------------------+
void DrawTPSLLines(int barIdx)
{
   datetime t1 = iTime(_Symbol, PERIOD_CURRENT, barIdx);
   datetime t2 = iTime(_Symbol, PERIOD_CURRENT, MathMax(0, barIdx - Label_Offset));

   DrawHLine(g_lineEntry, g_tradeEntry, clrGray,  STYLE_SOLID, 2, "ENTRY", t1, t2);
   DrawHLine(g_lineSL,    g_tradeSL,    SL_Color, STYLE_SOLID, 2, "SL",    t1, t2);
   DrawHLine(g_lineTp1,   g_tradeTp1,   TP_Color, STYLE_DASH,  1, "TP1",   t1, t2);
   DrawHLine(g_lineTp2,   g_tradeTp2,   TP_Color, STYLE_DASH,  1, "TP2",   t1, t2);
   DrawHLine(g_lineTp3,   g_tradeTp3,   TP_Color, STYLE_DASH,  2, "TP3",   t1, t2);
}

//+------------------------------------------------------------------+
//| EXTEND TP/SL lines to current bar                                 |
//+------------------------------------------------------------------+
void ExtendTPSLLines(int barIdx)
{
   if(g_tradeDir == 0) return;
   datetime t2 = iTime(_Symbol,PERIOD_CURRENT, MathMax(0, barIdx - Label_Offset));
   string names[] = {g_lineEntry, g_lineSL, g_lineTp1, g_lineTp2, g_lineTp3};
   for(int i=0; i<5; i++)
   {
      if(ObjectFind(0,names[i])>=0)
         ObjectSetInteger(0,names[i],OBJPROP_TIME,1,t2);
      string lbl = names[i]+"_LBL";
      if(ObjectFind(0,lbl)>=0)
         ObjectSetInteger(0,lbl,OBJPROP_TIME,0,t2);
   }
}

//+------------------------------------------------------------------+
//| MARK TP HIT                                                       |
//+------------------------------------------------------------------+
void MarkTPHit(string lineName, string labelText, double price)
{
   color hitColor = C'64,224,208'; // turquoise
   if(ObjectFind(0,lineName)>=0)
   {
      ObjectSetInteger(0,lineName,OBJPROP_COLOR,hitColor);
      ObjectSetInteger(0,lineName,OBJPROP_STYLE,STYLE_SOLID);
   }
   string lbl = lineName+"_LBL";
   if(ObjectFind(0,lbl)>=0)
   {
      ObjectSetString (0,lbl,OBJPROP_TEXT, labelText+" ✓ "+DoubleToString(price,_Digits));
      ObjectSetInteger(0,lbl,OBJPROP_COLOR,hitColor);
   }
}

//+------------------------------------------------------------------+
//| DASHBOARD: Delete all labels — uses tracked names, no full scan  |
//+------------------------------------------------------------------+
void DeleteDashboard()
{
   // Delete only the objects we created (tracked in g_dashObjNames)
   for(int i=0; i<g_dashObjCount; i++)
      ObjectDelete(0, g_dashObjNames[i]);
   g_dashObjCount = 0;
   ArrayResize(g_dashObjNames, 0);
   ObjectDelete(0, g_wmLabel);
   ObjectDelete(0, g_dashLabelPrefix+"BG");
}

// Internal helper: create or update an object and track its name
void DashEnsureObj(string name, ENUM_OBJECT type)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, type, 0, 0, 0);
      // Track it for fast deletion
      ArrayResize(g_dashObjNames, g_dashObjCount+1);
      g_dashObjNames[g_dashObjCount] = name;
      g_dashObjCount++;
   }
}

//+------------------------------------------------------------------+
//| DASHBOARD: Draw                                                   |
//+------------------------------------------------------------------+
void DrawDashboard(int shift,
                   double tqi, double tqiEr, double tqiVol, double tqiStruct, double tqiMom,
                   double erVal, double rsiVal, double volZ, bool hasVol,
                   int stTrend, bool confirmedBuy, bool confirmedSell,
                   double volRatio, bool isWarmedUp,
                   double dashWinRate, double dashAvgR, double dashWindowDD,
                   string resolvedPreset)
{
   // Fixed: Top Left corner
   ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER;
   int panelOffX = 6;
   int panelOffY = 30;

   // Colors
   color textMuted = C'158,158,158';
   color textColor = C'224,224,224';
   color headerBg  = C'41,98,255';
   color headerTxt = clrWhite;
   color neutralYellow = C'255,235,59';

   color trendCol = stTrend == 1 ? Bull_Color : Bear_Color;
   string trendStr = stTrend == 1 ? "Bullish ▲" : "Bearish ▼";

   string signalStr = confirmedBuy ? "BUY" : (confirmedSell ? "SELL" : "—");
   color  signalCol = confirmedBuy ? Bull_Color : (confirmedSell ? Bear_Color : textMuted);

   string regimeStr = erVal >= ER_HIGH_THRESH ? "Trending" : (erVal >= ER_LOW_THRESH ? "Mixed" : "Choppy");
   color  regimeCol = erVal >= ER_HIGH_THRESH ? Bull_Color : (erVal >= ER_LOW_THRESH ? neutralYellow : Bear_Color);
   string volRegStr = volRatio < VOL_LOW_THRESH ? "Low Vol" : (volRatio < VOL_HIGH_THRESH ? "Norm Vol" : "High Vol");

   string tqiStr  = Use_TQI ? DoubleToString(tqi, 2) : "off";
   color  tqiCol  = Use_TQI ? (tqi > 0.6 ? Bull_Color : (tqi > 0.35 ? neutralYellow : Bear_Color)) : textMuted;

   string erStr   = DoubleToString(erVal, 2);
   string rsiStr  = DoubleToString(rsiVal, 1);
   string volStr  = hasVol ? DoubleToString(volZ, 2) + "s" : "n/a";
   string warmStr = isWarmedUp ? "Ready" : IntegerToString(g_warmupBars - (int)shift) + " bars";

   int    sigCount  = ArraySize(g_signalRBuffer);
   string winRateStr= sigCount == 0 ? "—" : DoubleToString(dashWinRate*100.0, 1) + "%";
   string avgRStr   = sigCount == 0 ? "—" : DoubleToString(dashAvgR, 2) + "R";
   string winDDStr  = sigCount == 0 ? "—" : DoubleToString(dashWindowDD, 2) + "R";
   string allDDStr  = g_allTimeCount == 0 ? "—" : DoubleToString(g_allTimeTrough, 2) + "R";
   string streakStr = g_allTimeCount == 0 ? "—" : "W:"+IntegerToString(g_curWinStreak)+"/"+IntegerToString(g_maxWinStreak)+" L:"+IntegerToString(g_curLossStreak)+"/"+IntegerToString(g_maxLossStreak);
   string sampleStr = IntegerToString(sigCount)+"/"+IntegerToString(MAX_HISTORY_SIGS);

   int curCellIdx = CellIdx(ErBin(erVal), VolBin(volRatio));
   string regimeEdgeStr = g_gridCount[curCellIdx] == 0 ? "—" : DoubleToString(g_gridEwmR[curCellIdx],2)+"R("+IntegerToString(g_gridCount[curCellIdx])+")";
   color  regEdgeCol = g_gridCount[curCellIdx] < 5 ? textMuted : (g_gridEwmR[curCellIdx] > 0 ? Bull_Color : Bear_Color);

   // Build rows array
   struct DashRow { string label; string value; color valColor; bool altRow; };
   DashRow rows[];
   int rowCount = 0;

   #define ADD_ROW(lbl,val,col,alt) \
      ArrayResize(rows, rowCount+1); \
      rows[rowCount].label=lbl; rows[rowCount].value=val; rows[rowCount].valColor=col; rows[rowCount].altRow=alt; \
      rowCount++;

   ADD_ROW("Preset",    resolvedPreset,  textColor,   true)
   ADD_ROW("Trend",     trendStr,        trendCol,    false)
   ADD_ROW("TQI",       tqiStr,          tqiCol,      true)
   ADD_ROW("Q.Strength",DoubleToString(g_effectiveQStr,2), textColor, false)
   ADD_ROW("Signal",    signalStr,       signalCol,   true)
   ADD_ROW("Regime",    regimeStr+"/"+volRegStr, regimeCol, false)
   ADD_ROW("ER",        erStr,           textColor,   true)
   ADD_ROW("RSI",       rsiStr,          textColor,   false)
   ADD_ROW("Vol Z",     volStr,          textColor,   true)
   ADD_ROW("Status",    warmStr,         isWarmedUp?Bull_Color:neutralYellow, false)
   ADD_ROW("Version",   INDICATOR_VERSION, textMuted, true)

   if(Show_TQI_Breakdown && Use_TQI)
   {
      ADD_ROW("── TQI Components ──", "", headerTxt, false)
      ADD_ROW("Efficiency",  DoubleToString(tqiEr,    2), textColor, false)
      ADD_ROW("Volatility",  DoubleToString(tqiVol,   2), textColor, true)
      ADD_ROW("Structure",   DoubleToString(tqiStruct,2), textColor, false)
      ADD_ROW("Mom Persist", DoubleToString(tqiMom,   2), textColor, true)
   }

   if(Show_Perf)
   {
      ADD_ROW("── Performance ──", "", headerTxt, false)
      ADD_ROW("Signals",    sampleStr,     textMuted, true)
      ADD_ROW("Win Rate",   winRateStr,    sigCount<5?textMuted:(dashWinRate>=0.5?Bull_Color:Bear_Color), false)
      ADD_ROW("Avg R",      avgRStr,       sigCount<5?textMuted:(dashAvgR>0?Bull_Color:Bear_Color), true)
      ADD_ROW("Window DD",  winDDStr,      sigCount<5?textMuted:Bear_Color, false)
      ADD_ROW("All-Time DD",allDDStr,      g_allTimeCount==0?textMuted:Bear_Color, true)
      ADD_ROW("Streak W/L", streakStr,     textColor, false)
      ADD_ROW("Regime Edge",regimeEdgeStr, regEdgeCol, true)
   }

   // Layout constants
   int xPad      = 8;    // left padding inside panel
   int yStart    = 8;    // top padding inside panel
   int rowH      = 16;
   int colW      = 110;  // label column width
   int panelW    = 240;  // total panel width (wider to fit section headers)

   int totalRows  = rowCount + 1; // +1 for header
   int panelH     = yStart + totalRows * rowH + 8;

   // ── Black background rectangle ──
   string bgName = g_dashLabelPrefix + "BG";
   if(ObjectFind(0, bgName) < 0)
   {
      ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ArrayResize(g_dashObjNames, g_dashObjCount+1);
      g_dashObjNames[g_dashObjCount] = bgName;
      g_dashObjCount++;
   }
   ObjectSetInteger(0, bgName, OBJPROP_CORNER,     corner);
   ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE,  panelOffX);
   ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE,  panelOffY);
   ObjectSetInteger(0, bgName, OBJPROP_XSIZE,      panelW);
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE,      panelH);
   ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR,    clrBlack);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgName, OBJPROP_COLOR,      C'30,30,30');
   ObjectSetInteger(0, bgName, OBJPROP_BACK,       false);
   ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bgName, OBJPROP_ZORDER,     0);

   // ── Header ──
   string hName = g_dashLabelPrefix+"H0";
   DashEnsureObj(hName, OBJ_LABEL);
   ObjectSetInteger(0,hName,OBJPROP_CORNER,    corner);
   ObjectSetInteger(0,hName,OBJPROP_XDISTANCE, panelOffX + xPad);
   ObjectSetInteger(0,hName,OBJPROP_YDISTANCE, panelOffY + yStart);
   ObjectSetString (0,hName,OBJPROP_TEXT,      "● SATS " + INDICATOR_VERSION);
   ObjectSetInteger(0,hName,OBJPROP_COLOR,     headerTxt);
   ObjectSetInteger(0,hName,OBJPROP_FONTSIZE,  9);
   ObjectSetInteger(0,hName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,hName,OBJPROP_ZORDER,    1);

   // ── Rows ──
   for(int i=0; i<rowCount; i++)
   {
      int yPos = panelOffY + yStart + (i+1)*rowH;
      bool isHeader = (rows[i].value == "");

      // Row background (black for all rows, slightly lighter for alt rows)
      string rbName = g_dashLabelPrefix+"RB"+IntegerToString(i);
      DashEnsureObj(rbName, OBJ_RECTANGLE_LABEL);
      ObjectSetInteger(0,rbName,OBJPROP_CORNER,    corner);
      ObjectSetInteger(0,rbName,OBJPROP_XDISTANCE, panelOffX);
      ObjectSetInteger(0,rbName,OBJPROP_YDISTANCE, yPos - 2);
      ObjectSetInteger(0,rbName,OBJPROP_XSIZE,     panelW);
      ObjectSetInteger(0,rbName,OBJPROP_YSIZE,     rowH);
      ObjectSetInteger(0,rbName,OBJPROP_BGCOLOR,   rows[i].altRow ? C'18,18,18' : clrBlack);
      ObjectSetInteger(0,rbName,OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0,rbName,OBJPROP_COLOR,     rows[i].altRow ? C'18,18,18' : clrBlack);
      ObjectSetInteger(0,rbName,OBJPROP_BACK,      false);
      ObjectSetInteger(0,rbName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,rbName,OBJPROP_ZORDER,    0);

      // Label column (left side)
      string lName = g_dashLabelPrefix+"L"+IntegerToString(i);
      DashEnsureObj(lName, OBJ_LABEL);
      ObjectSetInteger(0,lName,OBJPROP_CORNER,    corner);
      ObjectSetInteger(0,lName,OBJPROP_XDISTANCE, panelOffX + xPad);
      ObjectSetInteger(0,lName,OBJPROP_YDISTANCE, yPos);
      ObjectSetString (0,lName,OBJPROP_TEXT,      rows[i].label);
      ObjectSetInteger(0,lName,OBJPROP_COLOR,     isHeader ? rows[i].valColor : textMuted);
      ObjectSetInteger(0,lName,OBJPROP_FONTSIZE,  8);
      ObjectSetInteger(0,lName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,lName,OBJPROP_ZORDER,    1);

      // Value column (right side) — skip for header rows
      string vName = g_dashLabelPrefix+"V"+IntegerToString(i);
      DashEnsureObj(vName, OBJ_LABEL);
      ObjectSetInteger(0,vName,OBJPROP_CORNER,    corner);
      ObjectSetInteger(0,vName,OBJPROP_XDISTANCE, panelOffX + xPad + colW);
      ObjectSetInteger(0,vName,OBJPROP_YDISTANCE, yPos);
      ObjectSetString (0,vName,OBJPROP_TEXT,      isHeader ? " " : rows[i].value);
      ObjectSetInteger(0,vName,OBJPROP_COLOR,     rows[i].valColor);
      ObjectSetInteger(0,vName,OBJPROP_FONTSIZE,  8);
      ObjectSetInteger(0,vName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,vName,OBJPROP_ZORDER,    1);
   }

   // ── Watermark ──
   if(Show_Watermark)
   {
      if(ObjectFind(0,g_wmLabel)<0)
      {
         ObjectCreate(0,g_wmLabel,OBJ_LABEL,0,0,0);
         ArrayResize(g_dashObjNames, g_dashObjCount+1);
         g_dashObjNames[g_dashObjCount] = g_wmLabel;
         g_dashObjCount++;
      }
      ObjectSetInteger(0,g_wmLabel,OBJPROP_CORNER,   CORNER_LEFT_LOWER);
      ObjectSetInteger(0,g_wmLabel,OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,g_wmLabel,OBJPROP_YDISTANCE,20);
      ObjectSetString (0,g_wmLabel,OBJPROP_TEXT,     "Hammad Dilber");
      ObjectSetInteger(0,g_wmLabel,OBJPROP_COLOR,    C'80,80,80');
      ObjectSetInteger(0,g_wmLabel,OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0,g_wmLabel,OBJPROP_SELECTABLE,false);
   }

   ChartRedraw(0);
   #undef ADD_ROW
}

//+------------------------------------------------------------------+
//| BUY/SELL signal arrow objects                                     |
//+------------------------------------------------------------------+
void DrawSignalArrow(bool isBuy, int shift, double score, double tqi, double erVal, double rsiVal, double volZ)
{
   string name = "SATS_SIG_"+(isBuy?"B":"S")+"_"+IntegerToString(shift);
   if(ObjectFind(0,name)>=0) return;

   datetime t = iTime(_Symbol,PERIOD_CURRENT,shift);
   double price = isBuy ? iLow(_Symbol,PERIOD_CURRENT,shift) - 2*_Point*10
                        : iHigh(_Symbol,PERIOD_CURRENT,shift) + 2*_Point*10;

   ObjectCreate(0, name, isBuy ? OBJ_ARROW_BUY : OBJ_ARROW_SELL, 0, t, price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,     isBuy?Bull_Color:Bear_Color);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,     2);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetString (0,name,OBJPROP_TOOLTIP,
      (isBuy?"▲ BUY":"▼ SELL")+" | Score:"+DoubleToString(score,0)+
      " | TQI:"+DoubleToString(tqi,2)+
      " | ER:"+DoubleToString(erVal,2)+
      " | RSI:"+DoubleToString(rsiVal,1)+
      " | VolZ:"+DoubleToString(volZ,2));
}

//+------------------------------------------------------------------+
//| OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, STBuffer,    INDICATOR_DATA);
   SetIndexBuffer(1, UpperBandBuf,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, LowerBandBuf,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(STBuffer,    true);
   ArraySetAsSeries(UpperBandBuf,true);
   ArraySetAsSeries(LowerBandBuf,true);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "SuperTrend");

   ResolvePreset();

   g_effectiveQStr = Quality_Strength;

   // ── Create built-in indicator handles (fast MT5-cached computation) ──
   g_hATR     = iATR(_Symbol, PERIOD_CURRENT, g_effectiveAtrLen);
   g_hRSI     = iRSI(_Symbol, PERIOD_CURRENT, g_effectiveRsiLen, PRICE_CLOSE);
   g_hATRBase = iATR(_Symbol, PERIOD_CURRENT, ATR_Baseline_Len);

   if(g_hATR == INVALID_HANDLE || g_hRSI == INVALID_HANDLE || g_hATRBase == INVALID_HANDLE)
   {
      Print("SATS: Warning — built-in handle creation failed, falling back to manual calc");
   }

   // Init grid
   ArrayInitialize(g_gridEwmR,  0.0);
   ArrayInitialize(g_gridCount, 0);

   // Warmup bars
   g_warmupBars = MathMax(WARMUP_FLOOR,
      MathMax(g_effectiveAtrLen,
      MathMax(g_effectiveErLen,
      MathMax(g_effectiveRsiLen,
      MathMax(Vol_Len,
      MathMax(Pivot_Len*2+1,
      MathMax(TQI_Mom_Len, TQI_Struct_Len)))))) + 10);

   // Reset state
   g_lowerBand     = EMPTY_VALUE;
   g_upperBand     = EMPTY_VALUE;
   g_stTrend       = 1;
   g_trendStartBar = 0;
   g_activeMultSm  = EMPTY_VALUE;
   g_passiveMultSm = EMPTY_VALUE;
   g_tradeDir      = 0;
   g_lastPivotHigh = EMPTY_VALUE;
   g_lastPivotLow  = EMPTY_VALUE;
   g_prevTqi       = 0.5;
   ArrayResize(g_signalRBuffer, 0);
   g_snapReady     = false;

   IndicatorSetString(INDICATOR_SHORTNAME, "SATS " + INDICATOR_VERSION);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release built-in handles
   if(g_hATR     != INVALID_HANDLE) { IndicatorRelease(g_hATR);     g_hATR     = INVALID_HANDLE; }
   if(g_hRSI     != INVALID_HANDLE) { IndicatorRelease(g_hRSI);     g_hRSI     = INVALID_HANDLE; }
   if(g_hATRBase != INVALID_HANDLE) { IndicatorRelease(g_hATRBase); g_hATRBase = INVALID_HANDLE; }

   DeleteDashboard();
   DeleteTPSLObjects();
   // Remove signal arrows
   int total = ObjectsTotal(0);
   for(int i=total-1; i>=0; i--)
   {
      string name = ObjectName(0,i);
      if(StringFind(name,"SATS_SIG_")==0) ObjectDelete(0,name);
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| OnCalculate — main loop                                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   if(rates_total < g_warmupBars + 10) return 0;

   // Calculate from oldest unprocessed bar to bar 0
   // shift=0 is the newest bar (current), shift=rates_total-1 is oldest
   int startBar = (prev_calculated == 0) ? rates_total - g_warmupBars - 2 : 1;
   if(startBar < 1) startBar = 1;

   // We need to recalc from the beginning on first run to build state
   // On full recalc, process from oldest to newest (high shift to low shift)
   if(prev_calculated == 0)
   {
      // Reset all state for full recalc
      g_lowerBand     = EMPTY_VALUE;
      g_upperBand     = EMPTY_VALUE;
      g_stTrend       = 1;
      g_trendStartBar = 0;
      g_activeMultSm  = EMPTY_VALUE;
      g_passiveMultSm = EMPTY_VALUE;
      g_tradeDir      = 0;
      g_tradeEntryBar = 0;
      g_tradeEntry    = EMPTY_VALUE;
      g_tradeSL       = EMPTY_VALUE;
      g_tradeTp1      = EMPTY_VALUE;
      g_tradeTp2      = EMPTY_VALUE;
      g_tradeTp3      = EMPTY_VALUE;
      g_hitTp1        = false;
      g_hitTp2        = false;
      g_hitTp3        = false;
      g_tradeCellIdx  = -1;
      g_lastPivotHigh = EMPTY_VALUE;
      g_lastPivotLow  = EMPTY_VALUE;
      g_lastDisplaySide = 0;
      g_lastSignalBar   = 0;
      g_prevTqi         = 0.5;
      g_effectiveQStr   = Quality_Strength;
      ArrayResize(g_signalRBuffer, 0);
      g_allTimeRSum   = 0.0;
      g_allTimeCount  = 0;
      g_allTimePeak   = 0.0;
      g_allTimeTrough = 0.0;
      g_allTimeCumR   = 0.0;
      g_curWinStreak  = 0;
      g_curLossStreak = 0;
      g_maxWinStreak  = 0;
      g_maxLossStreak = 0;
      g_signalsSinceCalib = 0;
      ArrayInitialize(g_gridEwmR,  0.0);
      ArrayInitialize(g_gridCount, 0);

      ArrayInitialize(STBuffer,     EMPTY_VALUE);
      ArrayInitialize(UpperBandBuf, EMPTY_VALUE);
      ArrayInitialize(LowerBandBuf, EMPTY_VALUE);

      // Process from oldest bar to newest (full history) — suppress alerts during historical replay
      g_isHistoricalRun = true;
      for(int shift = rates_total - 2; shift >= 0; shift--)
         ProcessBar(shift, rates_total, (shift == 0));
      g_isHistoricalRun = false;
      // After full recalc, force snapshot from bar 1 (most recent closed bar)
      // so dashboard has valid values on first load without waiting for next tick
      if(rates_total >= 2)
         ProcessBar(1, rates_total, false);  // re-process bar 1 with g_isHistoricalRun=false to capture snapshot
   }
   else
   {
      // Process bar 1 (just-closed bar) for confirmed signals, then bar 0 (live)
      if(rates_total > prev_calculated)
         ProcessBar(1, rates_total, false);
      ProcessBar(0, rates_total, true);
   }

   return rates_total;
}

//+------------------------------------------------------------------+
//| ProcessBar: core logic for each bar                               |
//+------------------------------------------------------------------+
void ProcessBar(int shift, int rates_total, bool isLastBar)
{
   bool isConfirmed = (shift > 0); // bar is closed if shift > 0; shift=0 = current open bar
   int  barIndexFromOld = rates_total - 1 - shift; // bar index counting from oldest

   // ── Base Calculations ──
   double rawAtr = CalcATR(shift, g_effectiveAtrLen);
   if(rawAtr <= 0) rawAtr = _Point;

   // ATR Baseline (SMA of ATR)
   double atrBaseline = CalcATRBaseline(shift, MathMin(ATR_Baseline_Len, barIndexFromOld > 0 ? barIndexFromOld : 1));
   if(atrBaseline <= 0) atrBaseline = rawAtr;
   double volRatio = SafeDiv(rawAtr, atrBaseline, 1.0);

   // Efficiency Ratio
   int erLen = MathMin(g_effectiveErLen, barIndexFromOld);
   double erVal = (erLen > 1) ? CalcEfficiencyRatio(shift, erLen) : 0.3;

   // Efficiency-weighted ATR
   double effAtr = Use_Eff_ATR ? rawAtr * (0.5 + 0.5*erVal) : rawAtr;
   double atrVal = effAtr;

   // ── TQI Factors ──
   double tqiEr = Clamp(erVal, 0.0, 1.0);

   // Volume — volZ must be set before TQI calculation so TQI uses correct value
   bool hasVol = (long)iVolume(_Symbol,PERIOD_CURRENT,shift) > 0;
   double volZRaw = hasVol ? CalcVolumeZ(shift, Vol_Len) : 0.0;
   double volZ = hasVol ? volZRaw : 0.0;   // FIX: assign immediately, not after RSI
   double tqiVol = hasVol ? MapClamp(volZRaw, -1.0, 2.0, 0.0, 1.0)
                           : MapClamp(volRatio, 0.6, 1.8, 0.0, 1.0);

   // Structure: price position in recent range
   double structHi = CalcHighest(shift, TQI_Struct_Len);
   double structLo = CalcLowest (shift, TQI_Struct_Len);
   double structRange = structHi - structLo;
   double src0 = GetSource(shift);
   double pricePos = SafeDiv(src0 - structLo, structRange, 0.5);
   double tqiStruct = Clamp(MathAbs(pricePos - 0.5) * 2.0, 0.0, 1.0);

   // Momentum persistence
   double windowChange = GetSource(shift) - GetSource(shift + TQI_Mom_Len);
   int alignedBars = 0;
   for(int i=0; i<TQI_Mom_Len; i++)
   {
      double barChange = GetSource(shift+i) - GetSource(shift+i+1);
      if((windowChange > 0 && barChange > 0) || (windowChange < 0 && barChange < 0))
         alignedBars++;
   }
   double tqiMom = SafeDiv(alignedBars, TQI_Mom_Len, 0.5);

   // Weighted TQI
   double tqiWeightSum = TQI_Weight_ER + TQI_Weight_Vol + TQI_Weight_Struct + TQI_Weight_Mom;
   double tqiDenom = tqiWeightSum > 0 ? tqiWeightSum : 1.0;
   double tqiRaw = Use_TQI
      ? (tqiEr*TQI_Weight_ER + tqiVol*TQI_Weight_Vol + tqiStruct*TQI_Weight_Struct + tqiMom*TQI_Weight_Mom) / tqiDenom
      : 0.5;
   double tqi = Clamp(tqiRaw, 0.0, 1.0);

   // ── Adaptive Multipliers ──
   double legacyAdapt = Use_Adaptive ? (1.0 + Adapt_Strength*(0.5 - erVal)) : 1.0;
   double qualityDeviation = Use_TQI ? MathPow(1.0 - tqi, Quality_Curve) : 0.5;
   double tqiMult = 1.0 - g_effectiveQStr + g_effectiveQStr*(0.6 + 0.8*qualityDeviation);
   double symMult = g_effectiveBaseMult * legacyAdapt * tqiMult;

   int prevTrend = g_stTrend;

   // Asymmetric
   double activeMultRaw  = symMult;
   double passiveMultRaw = symMult;
   if(Use_TQI && Use_Asym_Bands)
   {
      double asymTighten = 1.0 - Asym_Strength*tqi*0.3;
      double asymWiden   = 1.0 + Asym_Strength*tqi*0.4;
      activeMultRaw  = symMult * asymTighten;
      passiveMultRaw = symMult * asymWiden;
   }

   // EMA smooth multipliers
   if(g_activeMultSm == EMPTY_VALUE)  g_activeMultSm  = activeMultRaw;
   if(g_passiveMultSm == EMPTY_VALUE) g_passiveMultSm = passiveMultRaw;
   g_activeMultSm  = Mult_Smooth ? g_activeMultSm *(1.0-MULT_SMOOTH_ALPHA) + activeMultRaw *MULT_SMOOTH_ALPHA : activeMultRaw;
   g_passiveMultSm = Mult_Smooth ? g_passiveMultSm*(1.0-MULT_SMOOTH_ALPHA) + passiveMultRaw*MULT_SMOOTH_ALPHA : passiveMultRaw;

   double lowerMult = prevTrend == 1 ? g_activeMultSm  : g_passiveMultSm;
   double upperMult = prevTrend == 1 ? g_passiveMultSm : g_activeMultSm;

   // ── SuperTrend Bands ──
   double lowerBandRaw = src0 - lowerMult*atrVal;
   double upperBandRaw = src0 + upperMult*atrVal;

   double prevClose = iClose(_Symbol,PERIOD_CURRENT,shift+1);

   // Save previous band values BEFORE they are updated (needed for score calc later)
   double prevUpperBand = (g_upperBand == EMPTY_VALUE) ? upperBandRaw : g_upperBand;
   double prevLowerBand = (g_lowerBand == EMPTY_VALUE) ? lowerBandRaw : g_lowerBand;

   if(g_lowerBand == EMPTY_VALUE) g_lowerBand = lowerBandRaw;
   else g_lowerBand = (prevClose > g_lowerBand) ? MathMax(lowerBandRaw, g_lowerBand) : lowerBandRaw;

   if(g_upperBand == EMPTY_VALUE) g_upperBand = upperBandRaw;
   else g_upperBand = (prevClose < g_upperBand) ? MathMin(upperBandRaw, g_upperBand) : upperBandRaw;

   double curClose = iClose(_Symbol,PERIOD_CURRENT,shift);
   double curHigh  = iHigh (_Symbol,PERIOD_CURRENT,shift);
   double curLow   = iLow  (_Symbol,PERIOD_CURRENT,shift);

   // Price-based flip
   bool priceFlipUp   = prevTrend == -1 && curClose > g_upperBand;
   bool priceFlipDown = prevTrend ==  1 && curClose < g_lowerBand;

   // Trend age
   int trendAge = barIndexFromOld - g_trendStartBar;

   // Character flip
   bool charFlipCondBase = Use_Char_Flip && Use_TQI && g_prevTqi > CharFlip_High && tqi < CharFlip_Low && trendAge >= CharFlip_MinAge;
   bool charFlipDown = charFlipCondBase && prevTrend ==  1 && curClose < src0;
   bool charFlipUp   = charFlipCondBase && prevTrend == -1 && curClose > src0;

   bool finalFlipUp   = priceFlipUp   || charFlipUp;
   bool finalFlipDown = priceFlipDown || charFlipDown;

   int newTrend = finalFlipUp ? 1 : (finalFlipDown ? -1 : prevTrend);
   if(newTrend != g_stTrend) g_trendStartBar = barIndexFromOld;
   g_stTrend = newTrend;

   double stLine = g_stTrend == 1 ? g_lowerBand : g_upperBand;

   bool isWarmedUp = barIndexFromOld >= g_warmupBars;

   // Store to buffer — show line on all warmed-up bars (including live bar shift=0)
   if(isWarmedUp)
   {
      color stColor = g_stTrend == 1 ? Bull_Color : Bear_Color;
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, stColor);
      // FIX: Show_Bands controls band visual only — SuperTrend line always shown when warmed up
      STBuffer[shift] = stLine;
   }
   else
      STBuffer[shift] = EMPTY_VALUE;

   bool flipUp   = (g_stTrend ==  1 && prevTrend == -1);
   bool flipDown = (g_stTrend == -1 && prevTrend ==  1);

   // ── RSI ──
   double rsiVal = (barIndexFromOld >= g_effectiveRsiLen) ? CalcRSI(shift, g_effectiveRsiLen) : 50.0;
   // volZ already set correctly before TQI calculation above — no reassignment needed

   // ── Pivot update ──
   if(barIndexFromOld >= Pivot_Len*2+1)
   {
      if(IsPivotHigh(shift+Pivot_Len, Pivot_Len)) g_lastPivotHigh = iHigh(_Symbol,PERIOD_CURRENT,shift+Pivot_Len);
      if(IsPivotLow (shift+Pivot_Len, Pivot_Len)) g_lastPivotLow  = iLow (_Symbol,PERIOD_CURRENT,shift+Pivot_Len);
   }

   // ── Signal Logic — confirmedBuy/Sell only, no extra quality filter ──
   // confirmedBuy = flipUp and barstate.isconfirmed and isWarmedUp
   // No TQI/ER/score gate — all SuperTrend flips become signals
   bool confirmedBuy  = flipUp   && isConfirmed && isWarmedUp;
   bool confirmedSell = flipDown && isConfirmed && isWarmedUp;

   // Score calculated for display/label only (not used as gate)
   double buyScore  = confirmedBuy  ? CalcSignalScore(true,  shift, atrVal, erVal, rsiVal, volZ, hasVol, prevUpperBand, prevLowerBand) : 0.0;
   double sellScore = confirmedSell ? CalcSignalScore(false, shift, atrVal, erVal, rsiVal, volZ, hasVol, prevUpperBand, prevLowerBand) : 0.0;

   // Signal arrows — all confirmed flips shown
   if(Show_Signals && confirmedBuy)
      DrawSignalArrow(true,  shift, buyScore,  tqi, erVal, rsiVal, volZ);
   if(Show_Signals && confirmedSell)
      DrawSignalArrow(false, shift, sellScore, tqi, erVal, rsiVal, volZ);

   // ── Trade State Update — all confirmed signals enter trade ──

   if(confirmedBuy)
   {
      double tEntry = curClose;
      double slBase = (g_lastPivotLow != EMPTY_VALUE) ? g_lastPivotLow : curLow;
      double rawSl  = slBase - g_effectiveSlMult * atrVal;
      double minSl  = tEntry - g_effectiveSlMult * atrVal;
      double tSl    = MathMin(rawSl, minSl);  // FIX: MathMin for BUY — SL must be BELOW entry; pick the lower (safer) level
      double risk   = tEntry - tSl;
      if(risk <= 0) risk = atrVal;

      if(Show_Risk) DeleteTPSLObjects();

      g_tradeDir      = 1;
      g_tradeEntryBar = barIndexFromOld;
      g_tradeEntry    = tEntry;
      g_tradeSL       = tSl;
      g_tradeTp1      = tEntry + risk*g_fixedTp1R;
      g_tradeTp2      = tEntry + risk*g_fixedTp2R;
      g_tradeTp3      = tEntry + risk*g_fixedTp3R;
      g_hitTp1        = false;
      g_hitTp2        = false;
      g_hitTp3        = false;
      g_tradeCellIdx  = CellIdx(ErBin(erVal), VolBin(volRatio));

      if(Show_Score_Breakdown)
         CalcScoreBreakdown(true,shift,atrVal,erVal,rsiVal,volZ,hasVol,g_upperBand,g_lowerBand,
                            g_lastM,g_lastE,g_lastV,g_lastR,g_lastS,g_lastB);
      g_lastDisplaySide = 1;
      g_lastSignalBar   = barIndexFromOld;

      if(Show_Risk) DrawTPSLLines(shift);

      // Alert
      if(Enable_Alerts && isConfirmed && !g_isHistoricalRun)
      {
         double score = CalcSignalScore(true,shift,atrVal,erVal,rsiVal,volZ,hasVol,prevUpperBand,prevLowerBand);  // FIX: use prevUpperBand/prevLowerBand (consistent with signal filter)
         if(Webhook_JSON)
         {
            string msg = StringFormat("{\"action\":\"buy\",\"ticker\":\"%s\",\"tf\":\"%s\",\"price\":%.5f,\"sl\":%.5f,\"tp1\":%.5f,\"tp2\":%.5f,\"tp3\":%.5f,\"score\":%.0f,\"tqi\":%.2f}",
               _Symbol, EnumToString(PERIOD_CURRENT), curClose, g_tradeSL, g_tradeTp1, g_tradeTp2, g_tradeTp3, score, tqi);
            Alert(msg);
         }
         else
         {
            string msg = StringFormat("🟢 BUY | %s | Price: %.5f | TQI: %.2f | Score: %.0f | SL: %.5f | TP1: %.5f | TP2: %.5f | TP3: %.5f",
               _Symbol, curClose, tqi, score, g_tradeSL, g_tradeTp1, g_tradeTp2, g_tradeTp3);
            Alert(msg);
         }
      }
   }

   if(confirmedSell)
   {
      double tEntry = curClose;
      double slBase = (g_lastPivotHigh != EMPTY_VALUE) ? g_lastPivotHigh : curHigh;
      double rawSl  = slBase + g_effectiveSlMult * atrVal;
      double minSl  = tEntry + g_effectiveSlMult * atrVal;
      double tSl    = MathMax(rawSl, minSl);  // SELL: SL must be ABOVE entry; MathMax picks the higher (safer) level
      double risk   = tSl - tEntry;
      if(risk <= 0) risk = atrVal;

      if(Show_Risk) DeleteTPSLObjects();

      g_tradeDir      = -1;
      g_tradeEntryBar = barIndexFromOld;
      g_tradeEntry    = tEntry;
      g_tradeSL       = tSl;
      g_tradeTp1      = tEntry - risk*g_fixedTp1R;
      g_tradeTp2      = tEntry - risk*g_fixedTp2R;
      g_tradeTp3      = tEntry - risk*g_fixedTp3R;
      g_hitTp1        = false;
      g_hitTp2        = false;
      g_hitTp3        = false;
      g_tradeCellIdx  = CellIdx(ErBin(erVal), VolBin(volRatio));

      if(Show_Score_Breakdown)
         CalcScoreBreakdown(false,shift,atrVal,erVal,rsiVal,volZ,hasVol,g_upperBand,g_lowerBand,
                            g_lastM,g_lastE,g_lastV,g_lastR,g_lastS,g_lastB);
      g_lastDisplaySide = -1;
      g_lastSignalBar   = barIndexFromOld;

      if(Show_Risk) DrawTPSLLines(shift);

      if(Enable_Alerts && isConfirmed && !g_isHistoricalRun)
      {
         double score = CalcSignalScore(false,shift,atrVal,erVal,rsiVal,volZ,hasVol,prevUpperBand,prevLowerBand);  // FIX: use prevUpperBand/prevLowerBand (consistent with signal filter)
         if(Webhook_JSON)
         {
            string msg = StringFormat("{\"action\":\"sell\",\"ticker\":\"%s\",\"tf\":\"%s\",\"price\":%.5f,\"sl\":%.5f,\"tp1\":%.5f,\"tp2\":%.5f,\"tp3\":%.5f,\"score\":%.0f,\"tqi\":%.2f}",
               _Symbol, EnumToString(PERIOD_CURRENT), curClose, g_tradeSL, g_tradeTp1, g_tradeTp2, g_tradeTp3, score, tqi);
            Alert(msg);
         }
         else
         {
            string msg = StringFormat("🔴 SELL | %s | Price: %.5f | TQI: %.2f | Score: %.0f | SL: %.5f | TP1: %.5f | TP2: %.5f | TP3: %.5f",
               _Symbol, curClose, tqi, score, g_tradeSL, g_tradeTp1, g_tradeTp2, g_tradeTp3);
            Alert(msg);
         }
      }
   }

   // ── TP/SL Hit Detection ──
   if(g_tradeDir != 0 && isConfirmed && g_tradeEntry != EMPTY_VALUE && barIndexFromOld > g_tradeEntryBar)
   {
      bool tp1Reached = g_tradeDir==1 ? curHigh >= g_tradeTp1 : curLow <= g_tradeTp1;
      bool tp2Reached = g_tradeDir==1 ? curHigh >= g_tradeTp2 : curLow <= g_tradeTp2;
      bool tp3Reached = g_tradeDir==1 ? curHigh >= g_tradeTp3 : curLow <= g_tradeTp3;
      bool slHit      = g_tradeDir==1 ? curLow  <= g_tradeSL  : curHigh >= g_tradeSL;
      int  tradeAge2  = barIndexFromOld - g_tradeEntryBar;
      bool timeoutHit = tradeAge2 >= Trade_MaxAge;

      if(Show_Risk) ExtendTPSLLines(shift);

      if(tp1Reached && !g_hitTp1) { g_hitTp1=true; if(Show_Hits&&Show_Risk) MarkTPHit(g_lineTp1,"TP1",g_tradeTp1); }
      if(tp2Reached && !g_hitTp2) { g_hitTp2=true; if(Show_Hits&&Show_Risk) MarkTPHit(g_lineTp2,"TP2",g_tradeTp2); }
      if(tp3Reached && !g_hitTp3) { g_hitTp3=true; if(Show_Hits&&Show_Risk) MarkTPHit(g_lineTp3,"TP3",g_tradeTp3); }

      if(g_hitTp3 || slHit || timeoutHit)
      {
         double realizedR = 0.0;
         if(g_hitTp3 || slHit)
            realizedR = CalcRealizedR(slHit, g_hitTp1, g_hitTp2, g_hitTp3, g_fixedTp1R, g_fixedTp2R, g_fixedTp3R);
         else
            realizedR = CalcTimeoutR(g_hitTp1, g_hitTp2, g_hitTp3, g_fixedTp1R, g_fixedTp2R, g_fixedTp3R);
         realizedR = Clamp(realizedR, -1.0, g_fixedTp3R);

         int n = ArraySize(g_signalRBuffer);
         ArrayResize(g_signalRBuffer, n+1);
         g_signalRBuffer[n] = realizedR;
         // Trim to MAX_HISTORY_SIGS — single shift, no loop needed
         if(ArraySize(g_signalRBuffer) > MAX_HISTORY_SIGS)
         {
            int sz = ArraySize(g_signalRBuffer);
            ArrayCopy(g_signalRBuffer, g_signalRBuffer, 0, 1, sz - 1);
            ArrayResize(g_signalRBuffer, sz - 1);
         }

         g_allTimeRSum  += realizedR;
         g_allTimeCount++;
         g_allTimeCumR  += realizedR;
         if(g_allTimeCumR > g_allTimePeak) g_allTimePeak = g_allTimeCumR;
         double curDD = g_allTimeCumR - g_allTimePeak;
         if(curDD < g_allTimeTrough) g_allTimeTrough = curDD;

         if(realizedR > 0) { g_curWinStreak++; g_curLossStreak=0; if(g_curWinStreak>g_maxWinStreak) g_maxWinStreak=g_curWinStreak; }
         else              { g_curLossStreak++; g_curWinStreak=0; if(g_curLossStreak>g_maxLossStreak) g_maxLossStreak=g_curLossStreak; }

         UpdateGridCell(g_tradeCellIdx, realizedR);

         // Auto-calibration
         g_signalsSinceCalib++;
         if(Use_AutoCalib && ArraySize(g_signalRBuffer)>=Calib_Window && g_signalsSinceCalib>=Calib_Cooldown)
         {
            int ns = ArraySize(g_signalRBuffer);
            int startI = MathMax(0, ns - Calib_Window);
            double sumR2=0.0;
            for(int i=startI;i<ns;i++) sumR2 += g_signalRBuffer[i];
            double postAvgR = sumR2 / (ns - startI);
            if(postAvgR < Calib_BadR)
            {
               double drift = g_effectiveQStr > Quality_Strength ? -Calib_StepQ : Calib_StepQ;
               g_effectiveQStr = Clamp(g_effectiveQStr + drift, Calib_MinQ, Calib_MaxQ);
               g_signalsSinceCalib = 0;
            }
            else if(postAvgR > Calib_GoodR)
               g_signalsSinceCalib = 0;
         }

         if(!Use_AutoCalib) g_effectiveQStr = Quality_Strength;

         g_tradeDir     = 0;
         g_tradeCellIdx = -1;
      }
   }

   // ── Non-Repainting Snapshot: capture confirmed bar (shift=1) values ──
   // This prevents dashboard from changing on chart refresh/recalculation
   if(shift == 1 && !g_isHistoricalRun)
   {
      g_snapTqi          = tqi;
      g_snapTqiEr        = tqiEr;
      g_snapTqiVol       = tqiVol;
      g_snapTqiStruct    = tqiStruct;
      g_snapTqiMom       = tqiMom;
      g_snapErVal        = erVal;
      g_snapRsiVal       = rsiVal;
      g_snapVolZ         = volZ;
      g_snapHasVol       = hasVol;
      g_snapStTrend      = g_stTrend;
      g_snapConfirmedBuy = confirmedBuy;
      g_snapConfirmedSell= confirmedSell;
      g_snapVolRatio     = volRatio;
      g_snapIsWarmedUp   = isWarmedUp;
      g_snapReady        = true;

      ENUM_PRESET rp2 = Preset;
      if(Preset == PRESET_AUTO)
      {
         int tfMin2 = (int)PeriodSeconds(PERIOD_CURRENT) / 60;
         if(tfMin2 <= 5)        rp2 = PRESET_SCALPING;
         else if(tfMin2 <= 240) rp2 = PRESET_DEFAULT;
         else                   rp2 = PRESET_SWING;
      }
      string rp2str = "";
      switch(rp2)
      {
         case PRESET_SCALPING: rp2str = "Scalping";   break;
         case PRESET_DEFAULT:  rp2str = "Default";    break;
         case PRESET_SWING:    rp2str = "Swing";      break;
         case PRESET_CRYPTO:   rp2str = "Crypto 24/7";break;
         case PRESET_CUSTOM:   rp2str = "Custom";     break;
         default:              rp2str = "Auto";       break;
      }
      g_snapPreset = rp2str;
   }

   // ── Dashboard (only on last bar, using CLOSED bar snapshot to prevent repainting) ──
   if(Show_Dash && isLastBar && g_snapReady)
   {
      double dashWinRate, dashAvgR, dashWindowDD;
      CalcRollingStats(Calib_Window, dashWinRate, dashAvgR, dashWindowDD);

      DrawDashboard(shift, g_snapTqi, g_snapTqiEr, g_snapTqiVol, g_snapTqiStruct, g_snapTqiMom,
                    g_snapErVal, g_snapRsiVal, g_snapVolZ, g_snapHasVol,
                    g_snapStTrend, g_snapConfirmedBuy, g_snapConfirmedSell,
                    g_snapVolRatio, g_snapIsWarmedUp,
                    dashWinRate, dashAvgR, dashWindowDD,
                    g_snapPreset);
   }

   // Background color (optional)
   if(Show_BG && isWarmedUp)
   {
      // MQL5 background color per bar not straightforward in indicator mode
      // Skipped for simplicity — can be added via OBJ_RECTANGLE_LABEL if needed
   }

   g_prevTqi = tqi;
}
//+------------------------------------------------------------------+