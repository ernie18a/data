//+--------------------------------------------------------+
//|                                                        |
//|   ██████╗ ███████╗ █████╗ ██████╗                      |
//|   ██╔══██╗██╔════╝██╔══██╗██╔══██╗                     |
//|   ██████╔╝█████╗  ███████║██║  ██║                     |
//|   ██╔══██╗██╔══╝  ██╔══██║██║  ██║                     |
//|   ██║  ██║███████╗██║  ██║██████╔╝                     |
//|   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝                      |
//|                                                        |
//|   To use the >> EA WAVEMASTER OSCILLOSCOPE <<<         |
//|   FOLLOW the instructions BELOW....                    |
//|                                                        |
//+--------------------------------------------------------+

//    >>>>> DISCARD ALL THE CODE BELOW, UP TO... (scroll down)

//    >>>>> START HERE... (for delete)
//    === The code below is NOT Wavemaster oscilloscope code ==

#property copyright "Copyright©2026. Ritz EAneha"
#property link      "https://www.mql5.com/en/users/ritzfalih/seller"
#property version   "1.0"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>

input group "=== TRADE SETTINGS ==="
input double   InpLotSize       = 0.01;        // Fixed trading lot size
input ulong    InpMagicNumber   = 20260831;    // EA Magic Number
input int      InpDeviation     = 20;          // Maximum price deviation (points)

input group "=== MARKET FILTER ==="
input int      InpMaxSpread     = 200;         // Maximum entry spread (points)
input int      InpStartHour     = 2;           // Trading start hour
input int      InpEndHour       = 22;          // Trading end hour

input group "=== QUANTUM / SAR ENGINE ==="
input double   InpSarStep       = 0.02;        // Parabolic SAR step
input double   InpSarMax        = 0.2;         // Parabolic SAR maximum

input group "=== OPTIONAL PROTECTION ==="
input int      InpStopLossPoints = 0;          // Stop Loss (points, 0 = disabled)
input int      InpTakeProfitPoints = 0;        // Take Profit (points, 0 = disabled)

CTrade         trade;
CPositionInfo  posInfo;
CSymbolInfo    symInfo;

int            sarHandle = INVALID_HANDLE;
double         ExtLotSize; // Global variable for Auto-Corrected Lot Size

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!symInfo.Name(_Symbol)) return(INIT_FAILED);
   symInfo.Refresh();
   sarHandle = iSAR(_Symbol, _Period, InpSarStep, InpSarMax);
   if(sarHandle == INVALID_HANDLE) return(INIT_FAILED);
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpDeviation);
   trade.SetTypeFillingBySymbol(_Symbol);
   // Auto-Correct Lot Size
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   ExtLotSize = InpLotSize;
   if(minLot > 0 && ExtLotSize < minLot) ExtLotSize = minLot;
   if(maxLot > 0 && ExtLotSize > maxLot) ExtLotSize = maxLot;
   if(lotStep > 0) ExtLotSize = MathRound(ExtLotSize / lotStep) * lotStep;
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(sarHandle != INVALID_HANDLE) {
      IndicatorRelease(sarHandle);
      sarHandle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| Helper: Check if Free Margin is enough for the trade             |
//+------------------------------------------------------------------+
bool CheckMarginForTrade(ENUM_ORDER_TYPE order_type, double volume, double price)
{
   double margin_required = 0.0;
   // Hitung berapa margin (uang) yang dibutuhkan untuk membuka posisi ini
   if(!OrderCalcMargin(order_type, _Symbol, volume, price, margin_required)) {
      return false; // Gagal menghitung margin
   }
   // Apakah sisa uang di akun (Free Margin) cukup?
   if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) <= margin_required) {
      return false; // Tidak cukup uang, abaikan eksekusi (Mencegah log spam "Not enough money")
   }
   return true;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
// 1. CHECK BROKER OPERATING HOURS
   MqlDateTime time;
   TimeCurrent(time);
   if(time.hour < InpStartHour || time.hour >= InpEndHour)
      return;
// 2. CHECK MARKET SPREAD
   if(!symInfo.RefreshRates()) return;
   if(symInfo.Spread() > InpMaxSpread)
      return;
// 3. READ PARABOLIC SAR
   double sarArray[];
   double closeArray[];
   ArraySetAsSeries(sarArray, true);
   ArraySetAsSeries(closeArray, true);
   if(CopyBuffer(sarHandle, 0, 0, 2, sarArray) < 2) return;
   if(CopyClose(_Symbol, _Period, 0, 2, closeArray) < 2) return;
// 4. ORIGINAL QUANTUM DIRECTION LOGIC
   bool isQuantumUp = (closeArray[0] > sarArray[0]);
   bool isQuantumDn = (closeArray[0] < sarArray[0]);
// 5. CHECK CURRENT EA POSITIONS
   bool hasBuy  = false;
   bool hasSell = false;
   ulong buyTicket  = 0;
   ulong sellTicket = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      if(!posInfo.SelectByIndex(i)) continue;
      if(posInfo.Symbol() != _Symbol) continue;
      if((ulong)posInfo.Magic() != InpMagicNumber) continue;
      ENUM_POSITION_TYPE positionType = posInfo.PositionType();
      if(positionType == POSITION_TYPE_BUY) {
         hasBuy = true;
         buyTicket = posInfo.Ticket();
      } else if(positionType == POSITION_TYPE_SELL) {
         hasSell = true;
         sellTicket = posInfo.Ticket();
      }
   }
// 6. SELL / BEARISH FLOW
   if(isQuantumDn) {
      if(hasBuy) {
         if(trade.PositionClose(buyTicket)) hasBuy = false;
      }
      if(!hasSell) OpenSell();
   }
// 7. BUY / BULLISH FLOW
   else if(isQuantumUp) {
      if(hasSell) {
         if(trade.PositionClose(sellTicket)) hasSell = false;
      }
      if(!hasBuy) OpenBuy();
   }
}

//+------------------------------------------------------------------+
//| Execution: BUY                                                   |
//+------------------------------------------------------------------+
bool OpenBuy()
{
   double ask = symInfo.Ask();
   if(ask <= 0) return false;
   double sl = 0.0, tp = 0.0;
   if(InpStopLossPoints > 0) sl = ask - (InpStopLossPoints * _Point);
   if(InpTakeProfitPoints > 0) tp = ask + (InpTakeProfitPoints * _Point);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(sl > 0) sl = NormalizeDouble(sl, digits);
   if(tp > 0) tp = NormalizeDouble(tp, digits);
   // --- MQL5 VALIDATOR FIX: Cek apakah margin cukup sebelum menembak order ---
   if(!CheckMarginForTrade(ORDER_TYPE_BUY, ExtLotSize, ask))
      return false; // Jangan menyepam server jika margin kurang
   bool result = trade.Buy(ExtLotSize, _Symbol, 0.0, sl, tp, "Quantum Follower BUY");
   return result;
}

//+------------------------------------------------------------------+
//| Execution: SELL                                                  |
//+------------------------------------------------------------------+
bool OpenSell()
{
   double bid = symInfo.Bid();
   if(bid <= 0) return false;
   double sl = 0.0, tp = 0.0;
   if(InpStopLossPoints > 0) sl = bid + (InpStopLossPoints * _Point);
   if(InpTakeProfitPoints > 0) tp = bid - (InpTakeProfitPoints * _Point);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(sl > 0) sl = NormalizeDouble(sl, digits);
   if(tp > 0) tp = NormalizeDouble(tp, digits);
   // --- MQL5 VALIDATOR FIX: Cek apakah margin cukup sebelum menembak order ---
   if(!CheckMarginForTrade(ORDER_TYPE_SELL, ExtLotSize, bid))
      return false; // Jangan menyepam server jika margin kurang
   bool result = trade.Sell(ExtLotSize, _Symbol, 0.0, sl, tp, "Quantum Follower SELL");
   return result;
}


// >>>>>>>>>>> UP TO THIS POINT... (end delete)






//       >>>>>>  UNBLOCK ALL THE CODES BELOW <<<<<<<
//       (highlight or Ctrl+A) or (Ctrl+: (Control + colon))
//       Then Compile

//       ====== THE CODE BELOW IS THE WAVEMASTER OSCILLOSCOPE EA. =====

// start unblock comment here

////+------------------------------------------------------------------+
////|                                            WaveMaster_Pro_EA.mq5 |
////|                                      Copyright 2026, Ritz EAneha |
////|                          https://www.mql5.com/en/users/ritzfalih |
////+------------------------------------------------------------------+
//#property copyright "Copyright©2026. Ritz EAneha"
//#property link      "https://www.mql5.com/en/users/ritzfalih"
//#property version   "1.0"
//#property description "WaveMaster Pro EA — reads signal buffer from WaveMaster_Oscilloscope."
//#property description "Auto-detects indicator install location (Market or manual)."
//#property description "Full trading with risk management, trailing stop, and break-even."
//
//#include <Trade\Trade.mqh>
//#include <Trade\SymbolInfo.mqh>
//
////+------------------------------------------------------------------+
////| Enums                                                            |
////+------------------------------------------------------------------+
//enum ENUM_LOT_MODE {
//   LOT_FIXED = 0,   // Fixed lot size
//   LOT_RISK  = 1    // Risk % of account balance
//};
//
//enum ENUM_SLTP_MODE {
//   SLTP_FIXED = 0,  // Fixed points
//   SLTP_ATR   = 1   // ATR-based (dynamic)
//};
//
///*    // NOTE .......................
//
//      If you change the timeframe while the EA is installed, you must repeat the process by:
//      1. Removing the EA
//      2. Removing the indicator
//      then:
//      1. Re-applying the EA to your chosen timeframe
//
//*/    // END NOTE ...................
//
////+------------------------------------------------------------------+
////| Inputs — Indicator Connection                                    |
////+------------------------------------------------------------------+
//input group "=== Indicator Connection ==="
//input string         InpIndiFileName    = "WaveMaster Oscilloscope"; // Indicator file name (trig)
////The indicator name must be correct; you can download it from the market:
////
//input int            InpIndiOsciPeriod  = 14;       // Oscilloscope period (must match indicator)
//input double         InpIndiAnomalyThr  = 2.0;      // Anomaly threshold
//input double         InpIndiProbeMin    = 80.0;     // Probe threshold for signal
//input bool           InpIndiMLFilter    = false;    // Require ML confirmation
//input group "#### Disable for becktest | Enable for Live ####"
//input bool           InpAutoAttach      = true;     // Auto-attach indicator to chart if missing
//input bool           InpShowIndicatorVisual = true; // Show indicator visual (false = headless only)
//
////+------------------------------------------------------------------+
////| Inputs — Signal Filtering (additional, from buffers)             |
////+------------------------------------------------------------------+
//input group "=== Signal Filtering (EA-side) ==="
//input bool           InpUseScoreFilter  = false;    // Require min Signal Score
//input double         InpMinScore        = 60.0;     // Min Signal Score (0..100)
//input bool           InpUseAnomalyFilter= true;     // Require anomaly threshold (from indicator)
//input bool           InpUseMLFilter     = false;    // Require ML probability confirmation
//input double         InpMLMinProb       = 0.55;     // ML bullish prob (for BUY); bearish = 1 - this
//input int            InpCooldownSecs    = 30;       // Min seconds between trades
//
////+------------------------------------------------------------------+
////| Inputs — Trading                                                 |
////+------------------------------------------------------------------+
//input group "=== Trading & Money Management ==="
//input bool           InpAutoTrade       = true;     // Enable auto trading (initial state)
//input ulong          InpMagicNumber     = 20260101; // Magic number
//input ENUM_LOT_MODE  InpLotMode         = LOT_FIXED;// Lot sizing mode
//input double         InpFixedLot        = 0.01;     // Fixed lot size
//input double         InpRiskPercent     = 2.0;      // Risk % per trade
//input int            InpMaxPositions    = 1;        // Max concurrent positions
//
//input group "=== SL / TP (Check Symbol Points) ==="
//input ENUM_SLTP_MODE InpSLTPMode        = SLTP_FIXED; // SL/TP calculation mode
//input int            InpSLPoints        = 150;      // SL (points) - if FIXED mode
//input int            InpTPPoints        = 300;      // TP (points) - if FIXED mode
//input double         InpSLatrMult       = 1.5;      // SL = ATR × this - if ATR mode
//input double         InpTPatrMult       = 3.0;      // TP = ATR × this - if ATR mode
//input int            InpMinSLPoints     = 0;        // Min SL (points), 0 = auto
//input int            InpMinTPPoints     = 0;        // Min TP (points), 0 = auto
//
//input group "=== Trailing Stop (Check Symbol Points) ==="
//input bool           InpUseTrailing     = true;     // Enable trailing stop
//input int            InpTrailStart      = 100;      // Start trailing after profit (points)
//input int            InpTrailStep       = 50;       // Trail distance (points)
//
//input group "=== Break-Even (Check Symbol Points) ==="
//input bool           InpUseBreakEven    = true;     // Enable break-even
//input int            InpBEStart         = 150;      // Move SL to BE after profit (points)
//input int            InpBEBuffer        = 20;       // BE buffer (points above/below entry)
//
////+------------------------------------------------------------------+
////| Inputs — Filters                                                 |
////+------------------------------------------------------------------+
//input group "=== Filters ==="
//input int            InpMaxSpread       = 600;      // Max spread (Check Symbol Points)
//input bool           InpUseTimeFilter   = false;    // Enable time filter
//input int            InpStartHour       = 8;        // Start hour (server time)
//input int            InpEndHour         = 22;       // End hour (server time)
//input int            InpMaxDailyTrades  = 20;       // Max trades per day (0 = unlimited)
//input double         InpMaxDailyLossPct = 5.0;      // Max daily loss % (0 = unlimited)
//
////+------------------------------------------------------------------+
////| Inputs — Alerts                                                  |
////+------------------------------------------------------------------+
//input group "=== Alerts ==="
//input bool           InpAlertPopup      = true;     // Popup alerts
//input bool           InpAlertPush       = false;    // Push notifications
//input bool           InpAlertSound      = true;     // Sound
//input bool           InpAlertEmail      = false;    // Email alerts
//
////+------------------------------------------------------------------+
////| Inputs — Display                                                 |
////+------------------------------------------------------------------+
//input group "=== Display ==="
//input group "#### Disable for becktest | Enable for Live ####"
//input bool           InpShowPanel       = true;     // Show EA control panel
//input int            InpPanelX          = 600;       // Panel X (top-right offset)
//input int            InpPanelY          = 320;       // Panel Y
//
////+------------------------------------------------------------------+
////| Constants                                                        |
////+------------------------------------------------------------------+
//#define EA_TAG        "WaveMaster Pro EA"
//#define BTN_AUTO      "WMP_EA_BtnAuto"
//#define BTN_CLOSEALL  "WMP_EA_BtnCloseAll"
//#define PANEL_BG      "WMP_EA_PanelBG"
//#define PANEL_TITLE   "WMP_EA_PanelTitle"
//#define PANEL_STATUS  "WMP_EA_PanelStatus"
//
//
//// Buffer indices (must match indicator)
//#define BUF_PROBE       0
//#define BUF_ANOMALY     1
//#define BUF_RSI         2
//#define BUF_MOMENTUM    3
//#define BUF_DIVERGENCE  4
//#define BUF_FFT_FREQ    5
//#define BUF_FFT_MAG     6
//#define BUF_ML_PROB     7
//#define BUF_ADAPT_THR   8
//#define BUF_SCORE       9
//#define BUF_ML_READY    10
//#define BUF_SIGNAL      11
//
////+------------------------------------------------------------------+
////| Globals                                                          |
////+------------------------------------------------------------------+
//CTrade         gTrade;
//CSymbolInfo    gSymbol;
//
//int            gIndiHandle     = INVALID_HANDLE;
//string         gIndiPath       = "";
//bool           gIndiAttached   = false;
//string         InpSoundFile    = "alert.wav";
//bool           gAutoTrade      = true;
//datetime       gLastTradeTime  = 0;
//int            gDailyTrades    = 0;
//datetime       gDailyResetDate = 0;
//double         gDailyStartBal  = 0.0;
//bool           gDailyLimitHit  = false;
//double  gLastSignalPrev = 0.0;    // for edge detection
//// Cached buffer values
//double         gLastSignal     = 0.0;
//double         gLastMLProb     = 0.5;
//double         gLastScore      = 50.0;
//double         gLastAnomaly    = 0.0;
//double         gLastAdaptThr   = 2.0;
//
//
//// Display state
//int            gPanelX         = 20;
//int            gPanelY         = 20;
//
//
////+------------------------------------------------------------------+
////| Expert initialization                                            |
////+------------------------------------------------------------------+
//int OnInit()
//{
////--- Validate inputs
//   if(InpIndiOsciPeriod < 1) {
//      Print(EA_TAG, ": ERROR — InpIndiOsciPeriod must be >= 1");
//      return INIT_PARAMETERS_INCORRECT;
//   }
//   if(InpFixedLot <= 0.0) {
//      Print(EA_TAG, ": ERROR — InpFixedLot must be > 0");
//      return INIT_PARAMETERS_INCORRECT;
//   }
////--- Configure symbol
//   if(!gSymbol.Name(_Symbol)) {
//      Print(EA_TAG, ": ERROR — Symbol.Name failed");
//      return INIT_FAILED;
//   }
//   gSymbol.RefreshRates();
////--- Configure trade object
//   gTrade.SetExpertMagicNumber(InpMagicNumber);
//   gTrade.SetTypeFillingBySymbol(_Symbol);
//   gTrade.SetDeviationInPoints(30);
//   gTrade.SetAsyncMode(false);
////--- Initialize daily tracking
//   ResetDailyCounters();
////--- Locate & attach indicator
//   if(!InitializeIndicator()) {
//      Print(EA_TAG, ": FATAL — could not load indicator. EA cannot continue.");
//      return INIT_FAILED;
//   }
////--- Tester: warn if indicator warm-up needed
//   if(IsStrategyTester()) {
//      Print(EA_TAG, ": tester will warm up indicator over next few ticks");
//   }
////--- Initialize display
//   gPanelX = InpPanelX;
//   gPanelY = InpPanelY;
//   if(InpShowPanel) {
//      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
//      CreatePanel();
//   }
////--- Welcome log
//   PrintFormat("%s initialized | symbol=%s tf=%s | indicator=%s | attached=%s | magic=%I64u",
//               EA_TAG, _Symbol, EnumToString((ENUM_TIMEFRAMES)_Period),
//               gIndiPath, gIndiAttached ? "yes" : "no(headless)", InpMagicNumber);
//   return INIT_SUCCEEDED;
//}
//
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//void OnDeinit(const int reason)
//{
//   bool isFinalRemoval = (reason == REASON_REMOVE || reason == REASON_RECOMPILE);
////--- Only delete indicator & panel on FINAL removal (not on reinit)
//   if(isFinalRemoval) {
//      if(gIndiAttached && gIndiHandle != INVALID_HANDLE) {
//         ChartIndicatorDelete(0, 0, gIndiPath);
//         gIndiAttached = false;
//      }
//      DeletePanel();
//      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, false);
//   }
////--- Always release our handle (safe on any reason)
//   if(gIndiHandle != INVALID_HANDLE) {
//      IndicatorRelease(gIndiHandle);
//      gIndiHandle = INVALID_HANDLE;
//   }
//   ChartRedraw(0);
//}
//
////+------------------------------------------------------------------+
////| Expert tick function                                             |
////+------------------------------------------------------------------+
//void OnTick()
//{
////--- Refresh symbol
//   if(!gSymbol.RefreshRates()) return;
////--- Check daily reset
//   CheckDailyReset();
////--- Read indicator buffers
//   if(!ReadBuffers()) return;
////--- Manage existing positions (trailing/BE)
//   ManageOpenPositions();
////--- Trading gate
//   if(!gAutoTrade) return;
//   if(gDailyLimitHit) return;
//   if(!IsTradingAllowed()) return;
////--- Process signal
//   ProcessSignal();
//}
//
////+------------------------------------------------------------------+
////| Chart event handler                                              |
////+------------------------------------------------------------------+
//void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
//{
//   if(id == CHARTEVENT_OBJECT_CLICK) {
//      if(sparam == BTN_AUTO) {
//         gAutoTrade = !gAutoTrade;
//         UpdatePanel();
//         ChartRedraw();
//         PrintFormat("%s: AutoTrade > %s", EA_TAG, gAutoTrade ? "ON" : "OFF");
//         return;
//      }
//      if(sparam == BTN_CLOSEALL) {
//         CloseAllPositions("manual");
//         return;
//      }
//      return;
//   }
//   if(id == CHARTEVENT_MOUSE_MOVE && InpShowPanel) {
//      int mx = (int)lparam;
//      int my = (int)dparam;
//      bool pressed = ((int)StringToInteger(sparam) & 1) == 1;
//      //--- Drag handling
//      static bool dragging = false;
//      static int  dragOffX = 0, dragOffY = 0;
//      int titleX = gPanelX;
//      int titleY = gPanelY;
//      int titleW = 220;
//      int titleH = 26;
//      bool onTitle = (mx >= titleX && mx <= titleX + titleW &&
//                      my >= titleY && my <= titleY + titleH);
//      if(pressed) {
//         if(onTitle && !dragging) {
//            dragging = true;
//            dragOffX = mx - gPanelX;
//            dragOffY = my - gPanelY;
//            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
//         }
//         if(dragging) {
//            gPanelX = mx - dragOffX;
//            gPanelY = my - dragOffY;
//            if(gPanelX < 0) gPanelX = 0;
//            if(gPanelY < 0) gPanelY = 0;
//            UpdatePanelPositions();
//            ChartRedraw();
//         }
//      } else if(dragging) {
//         dragging = false;
//         ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
//      }
//   }
//}
//
////+------------------------------------------------------------------+
////| Detect if running inside Strategy Tester                         |
////+------------------------------------------------------------------+
//bool IsStrategyTester()
//{
//   return (bool)MQLInfoInteger(MQL_TESTER);
//}
//
////+------------------------------------------------------------------+
////| Initialize indicator (tester-aware, buffer-agnostic)             |
////+------------------------------------------------------------------+
//bool InitializeIndicator()
//{
//   string baseName = InpIndiFileName;
//   bool isTester = IsStrategyTester();
////--- Clean path candidates
//   string candidates[6];
//   int    nCand = 0;
//   if(isTester) {
//      candidates[nCand++] = baseName;
//      candidates[nCand++] = "\\Indicators\\" + baseName;
//   } else {
//      //--- LIVE: try plain name FIRST — MT5 auto-searches Indicators\ and Indicators\Market\
//      candidates[nCand++] = baseName;                             // ← covers both
//      candidates[nCand++] = "\\Indicators\\" + baseName;          // manual install (abs)
//      candidates[nCand++] = "Indicators\\" + baseName;            // manual install (rel)
//      candidates[nCand++] = "\\Indicators\\Market\\" + baseName;  // Market install (abs)
//      candidates[nCand++] = "Market\\" + baseName;                // Market install (rel)
//      candidates[nCand++] = "Indicators\\Market\\" + baseName;    // Market install (fallback)
//   }
////--- Try each candidate — accept FIRST valid handle
//   for(int i = 0; i < nCand; i++) {
//      ResetLastError();
//      int h = iCustom(_Symbol, _Period, candidates[i],
//                      InpIndiOsciPeriod, InpIndiAnomalyThr,
//                      InpIndiProbeMin, InpIndiMLFilter);
//      if(h != INVALID_HANDLE) {
//         gIndiPath   = candidates[i];
//         gIndiHandle = h;
//         PrintFormat("%s: indicator handle obtained from '%s'", EA_TAG, gIndiPath);
//         break;
//      }
//      int err = GetLastError();
//      //--- Silence expected "not found" during path probing
//      if(err == 4802 || err == 557 || err == 5001) {
//         // Silent — just try next candidate
//      } else {
//         PrintFormat("%s: X '%s' failed (err=%d)", EA_TAG, candidates[i], err);
//      }
//   }
//   if(gIndiHandle == INVALID_HANDLE) {
//      Print(EA_TAG, ": X indicator not found in any known path");
//      Print(EA_TAG, ": ensure '", baseName, ".ex5' is compiled in MQL5\\Indicators\\");
//      return false;
//   }
////--- TESTER: skip visual attach (not supported)
//   if(isTester) {
//      gIndiAttached = false;
//      Print(EA_TAG, ": tester mode — running headless");
//      return true;
//   }
//   //--- LIVE: handle visual attach
//   if(InpShowIndicatorVisual && InpAutoAttach) {
//      int existing = ChartIndicatorGet(0, 0, baseName);
//      if(existing != INVALID_HANDLE) {
//         //--- Indicator already attached (e.g., user added manually)
//         IndicatorRelease(gIndiHandle);
//         gIndiHandle   = existing;
//         gIndiAttached = false;
//         PrintFormat("%s: using existing attached instance (handle re-bound)", EA_TAG);
//      } else {
//         //--- Not attached — need to add via ChartIndicatorAdd
//         if(ChartIndicatorAdd(0, 0, gIndiHandle)) {
//            gIndiAttached = true;
//            //=== CRITICAL FIX ===
//            // ChartIndicatorAdd INVALIDATES the passed handle.
//            // We MUST re-fetch it via ChartIndicatorGet.
//            int newH = ChartIndicatorGet(0, 0, baseName);
//            if(newH == INVALID_HANDLE) {
//               PrintFormat("%s: X attached but failed to re-acquire handle (err=%d)",
//                           EA_TAG, GetLastError());
//               return false;
//            }
//            gIndiHandle = newH;
//            PrintFormat("%s: indicator attached visibly (handle re-acquired)", EA_TAG);
//         } else {
//            gIndiAttached = false;
//            PrintFormat("%s: visible attach failed (err=%d), running headless",
//                        EA_TAG, GetLastError());
//            //--- Fallback: keep original iCustom handle (still valid in headless mode)
//         }
//      }
//   } else {
//      PrintFormat("%s: headless mode (visual attach disabled)", EA_TAG);
//   }
//   return (gIndiHandle != INVALID_HANDLE);
//}
//
////+------------------------------------------------------------------+
////| Read indicator buffers — with handle recovery watchdog           |
////+------------------------------------------------------------------+
//bool ReadBuffers()
//{
//   if(gIndiHandle == INVALID_HANDLE) return false;
//   int calculated = BarsCalculated(gIndiHandle);
//   //--- Watchdog: -1 = handle invalidated
//   if(calculated == -1) {
//      //--- Try recovery with shortname first, then file base name
//      int recovered = ChartIndicatorGet(0, 0, InpIndiFileName);
//      if(recovered == INVALID_HANDLE) {
//         //--- Fallback: search indicator by any attached name
//         int totalIndi = ChartIndicatorsTotal(0, 0);
//         for(int k = 0; k < totalIndi; k++) {
//            string indiName = ChartIndicatorName(0, 0, k);
//            if(StringFind(indiName, InpIndiFileName) >= 0) {
//               recovered = ChartIndicatorGet(0, 0, indiName);
//               if(recovered != INVALID_HANDLE) break;
//            }
//         }
//      }
//      if(recovered != INVALID_HANDLE) {
//         gIndiHandle = recovered;
//         calculated  = BarsCalculated(gIndiHandle);
//         PrintFormat("%s: handle recovered via ChartIndicatorGet (calc=%d)",
//                     EA_TAG, calculated);
//      }
//      //--- If still invalid, log ONCE per 30s
//      if(calculated == -1) {
//         static uint lastHandleWarn = 0;
//         if(GetTickCount() - lastHandleWarn > 30000) {
//            PrintFormat("%s: X indicator handle invalid - waiting for recovery", EA_TAG);
//            lastHandleWarn = GetTickCount();
//         }
//         return false;
//      }
//   }
//   //--- Warm-up: indicator calculating but not ready yet
//   int needed = InpIndiOsciPeriod + 2;
//   if(calculated < needed) {
//      // Log ONCE per 30s (was 5s before — too spammy)
//      static uint lastWarmWarn = 0;
//      if(GetTickCount() - lastWarmWarn > 30000) {
//         PrintFormat("%s: warming up - %d/%d bars calculated (will auto-retry)",
//                     EA_TAG, calculated, needed);
//         lastWarmWarn = GetTickCount();
//      }
//      return false;
//   }
//   //--- Read buffers
//   double buf[1];
//   int okCount = 0;
//   if(CopyBuffer(gIndiHandle, BUF_SIGNAL, 0, 1, buf) == 1) {
//      gLastSignal = buf[0];
//      okCount++;
//   }
//   if(CopyBuffer(gIndiHandle, BUF_ML_PROB, 0, 1, buf) == 1) {
//      gLastMLProb = buf[0];
//      okCount++;
//   }
//   if(CopyBuffer(gIndiHandle, BUF_SCORE, 0, 1, buf) == 1) {
//      gLastScore = buf[0];
//      okCount++;
//   }
//   if(CopyBuffer(gIndiHandle, BUF_ANOMALY, 0, 1, buf) == 1) {
//      gLastAnomaly = buf[0];
//      okCount++;
//   }
//   if(CopyBuffer(gIndiHandle, BUF_ADAPT_THR, 0, 1, buf) == 1) {
//      gLastAdaptThr = buf[0];
//      okCount++;
//   }
//   //--- Minimum 3 of 5 buffers must succeed
//   return (okCount >= 3);
//}
//
////+------------------------------------------------------------------+
////| Process signal — with rising-edge detection                      |
////+------------------------------------------------------------------+
//void ProcessSignal()
//{
//   double signalCur = gLastSignal;
//   //--- Rising edge detection (only act on NEW signal)
//   bool isFreshSignal = (signalCur != 0.0 && signalCur != gLastSignalPrev);
//   //--- Update prev AFTER detecting edge (so next tick sees the new "prev")
//   gLastSignalPrev = signalCur;
//   //--- No signal or not fresh → skip
//   if(!isFreshSignal) return;
//   //--- Additional filters
//   if(InpUseScoreFilter && gLastScore < InpMinScore) return;
//   if(InpUseAnomalyFilter && gLastAnomaly < gLastAdaptThr) return;
//   if(InpUseMLFilter) {
//      if(signalCur > 0 && gLastMLProb < InpMLMinProb) return;
//      if(signalCur < 0 && gLastMLProb > (1.0 - InpMLMinProb)) return;
//   }
//   //--- Cooldown
//   if(TimeCurrent() - gLastTradeTime < InpCooldownSecs) return;
//   //--- Max positions
//   if(CountOwnPositions() >= InpMaxPositions) return;
//   //--- Spread check
//   long spread = (long)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
//   if(spread > InpMaxSpread) {
//      PrintFormat("%s: spread %d pts > max %d — skipped", EA_TAG, (int)spread, InpMaxSpread);
//      return;
//   }
//   //--- Time filter
//   if(InpUseTimeFilter && !IsInTradingHours()) return;
//   //--- Daily trade limit
//   if(InpMaxDailyTrades > 0 && gDailyTrades >= InpMaxDailyTrades) {
//      PrintFormat("%s: daily trade limit reached (%d)", EA_TAG, gDailyTrades);
//      return;
//   }
//   //--- Execute on FRESH signal only
//   if(signalCur > 0)
//      ExecuteTrade(true);
//   else if(signalCur < 0)
//      ExecuteTrade(false);
//}
//
////+------------------------------------------------------------------+
////| Execute trade — SL/TP first, then lot from ACTUAL SL distance    |
////+------------------------------------------------------------------+
//bool ExecuteTrade(bool isBuy)
//{
//   //--- 1) Calculate SL/TP first (may use ATR or fixed)
//   double sl, tp;
//   if(!CalculateSLTP(isBuy, sl, tp)) {
//      PrintFormat("%s: SL/TP calculation failed", EA_TAG);
//      return false;
//   }
//   //--- 2) Compute ACTUAL SL distance in points
//   double point = gSymbol.Point();
//   double ask   = gSymbol.Ask();
//   double bid   = gSymbol.Bid();
//   double entry = isBuy ? ask : bid;
//   double slDistPrice = MathAbs(entry - sl);
//   int    slDistPts   = (int)MathRound(slDistPrice / point);
//   if(slDistPts < 1) slDistPts = 1;
//   //--- 3) Calculate lot from ACTUAL SL distance
//   double lot = CalculateLot(slDistPts);
//   if(lot <= 0.0) {
//      PrintFormat("%s: lot calculation failed → %.4f (slPts=%d)",
//                  EA_TAG, lot, slDistPts);
//      return false;
//   }
//   //--- 4) Execute
//   bool ok = false;
//   if(isBuy) {
//      ok = gTrade.Buy(lot, _Symbol, ask, sl, tp, "WMPro_BUY");
//   } else {
//      ok = gTrade.Sell(lot, _Symbol, bid, sl, tp, "WMPro_SELL");
//   }
//   //--- 5) Log result
//   if(ok) {
//      gLastTradeTime = TimeCurrent();
//      gDailyTrades++;
//      PrintFormat("%s: %s OPENED | lot=%.2f entry=%.5f sl=%.5f tp=%.5f (slPts=%d) | sig=%.1f ml=%.2f score=%.1f",
//                  EA_TAG, isBuy ? "BUY" : "SELL", lot, entry, sl, tp, slDistPts,
//                  gLastSignal, gLastMLProb, gLastScore);
//      SendAlert(StringFormat("[%s] %s SIGNAL | lot=%.2f sl=%dpts", _Symbol, isBuy ? "BUY" : "SELL", lot, slDistPts));
//      UpdatePanel();
//   } else {
//      PrintFormat("%s: X %s FAILED | retcode=%d (%s) err=%d | lot=%.2f sl=%.5f tp=%.5f",
//                  EA_TAG, isBuy ? "BUY" : "SELL",
//                  gTrade.ResultRetcode(), gTrade.ResultRetcodeDescription(),
//                  GetLastError(), lot, sl, tp);
//   }
//   return ok;
//}
//
////+------------------------------------------------------------------+
////| Calculate SL / TP prices                                         |
////+------------------------------------------------------------------+
//bool CalculateSLTP(bool isBuy, double &sl, double &tp)
//{
//   double ask = gSymbol.Ask();
//   double bid = gSymbol.Bid();
//   double point = gSymbol.Point();
//   double slDist = 0.0;
//   double tpDist = 0.0;
//   if(InpSLTPMode == SLTP_FIXED) {
//      slDist = InpSLPoints * point;
//      tpDist = InpTPPoints * point;
//   } else {
//      // ATR-based
//      double atr = GetAtrValue();
//      if(atr <= 0.0) {
//         PrintFormat("%s: ATR value = 0, fallback to fixed", EA_TAG);
//         slDist = InpSLPoints * point;
//         tpDist = InpTPPoints * point;
//      } else {
//         slDist = atr * InpSLatrMult;
//         tpDist = atr * InpTPatrMult;
//      }
//   }
////--- Min distances
//   long spread = (long)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
//   double minSL = (InpMinSLPoints > 0) ? InpMinSLPoints * point
//                  : (spread + 10) * point;
//   double minTP = (InpMinTPPoints > 0) ? InpMinTPPoints * point
//                  : (spread * 2 + 10) * point;
//   if(slDist < minSL) slDist = minSL;
//   if(tpDist < minTP) tpDist = minTP;
////--- Broker stops level
//   long stopsLevelPts = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
//   double stopsLevel = stopsLevelPts * point;
//   if(stopsLevel > 0) {
//      if(slDist < stopsLevel) slDist = stopsLevel;
//      if(tpDist < stopsLevel) tpDist = stopsLevel;
//   }
////--- Compute prices
//   if(isBuy) {
//      sl = NormalizeDouble(bid - slDist, gSymbol.Digits());
//      tp = NormalizeDouble(ask + tpDist, gSymbol.Digits());
//   } else {
//      sl = NormalizeDouble(ask + slDist, gSymbol.Digits());
//      tp = NormalizeDouble(bid - tpDist, gSymbol.Digits());
//   }
//   return true;
//}
//
////+------------------------------------------------------------------+
////| Get ATR value from indicator's adaptive threshold                |
////| (ATR = adaptive_thr / base_multiplier is impossible to reverse)  |
////| Use indicator's BufAnomaly/Thr or fall back to iATR directly     |
////+------------------------------------------------------------------+
//double GetAtrValue()
//{
//// Reuse the indicator's data — but we can also compute our own ATR
//   static int atrH = INVALID_HANDLE;
//   if(atrH == INVALID_HANDLE)
//      atrH = iATR(_Symbol, _Period, 14);
//   if(atrH == INVALID_HANDLE) return 0.0;
//   double atr[];
//   ArraySetAsSeries(atr, true);
//   if(CopyBuffer(atrH, 0, 0, 2, atr) < 1) return 0.0;
//   return atr[0];
//}
//
////+------------------------------------------------------------------+
////| Position management — trailing stop & break-even                 |
////+------------------------------------------------------------------+
//void ManageOpenPositions()
//{
//   if(CountOwnPositions() == 0) return;
//   for(int i = PositionsTotal() - 1; i >= 0; i--) {
//      ulong ticket = PositionGetTicket(i);
//      if(ticket == 0) continue;
//      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
//      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;
//      long    type    = PositionGetInteger(POSITION_TYPE);
//      double  openPr  = PositionGetDouble(POSITION_PRICE_OPEN);
//      double  curSL   = PositionGetDouble(POSITION_SL);
//      double  curTP   = PositionGetDouble(POSITION_TP);
//      double  bid     = gSymbol.Bid();
//      double  ask     = gSymbol.Ask();
//      double  point   = gSymbol.Point();
//      bool    isBuy   = (type == POSITION_TYPE_BUY);
//      double curProfit = isBuy ? (bid - openPr) : (openPr - ask);
//      double profitPts = curProfit / point;
//      //--- Break-even
//      if(InpUseBreakEven && profitPts >= InpBEStart) {
//         double newSL = isBuy
//                        ? openPr + InpBEBuffer * point
//                        : openPr - InpBEBuffer * point;
//         newSL = NormalizeDouble(newSL, gSymbol.Digits());
//         bool beNeeded = isBuy ? (curSL < newSL) : (curSL > newSL || curSL == 0);
//         if(beNeeded) {
//            if(gTrade.PositionModify(ticket, newSL, curTP)) {
//               PrintFormat("%s: break-even moved | ticket=%I64u newSL=%.5f",
//                           EA_TAG, ticket, newSL);
//            }
//         }
//      }
//      //--- Trailing stop
//      if(InpUseTrailing && profitPts >= InpTrailStart) {
//         double trailDist = InpTrailStep * point;
//         double newSL = isBuy
//                        ? NormalizeDouble(bid - trailDist, gSymbol.Digits())
//                        : NormalizeDouble(ask + trailDist, gSymbol.Digits());
//         bool trailNeeded = isBuy ? (newSL > curSL) : (newSL < curSL || curSL == 0);
//         if(trailNeeded) {
//            // Ensure it's after BE (don't go backward)
//            bool pastBE = isBuy
//                          ? (newSL > openPr)
//                          : (newSL < openPr);
//            if(pastBE && gTrade.PositionModify(ticket, newSL, curTP)) {
//               PrintFormat("%s: trailing SL moved | ticket=%I64u newSL=%.5f",
//                           EA_TAG, ticket, newSL);
//            }
//         }
//      }
//   }
//}
//
////+------------------------------------------------------------------+
////| Close all EA positions                                           |
////+------------------------------------------------------------------+
//void CloseAllPositions(string reason)
//{
//   int closed = 0;
//   for(int i = PositionsTotal() - 1; i >= 0; i--) {
//      ulong ticket = PositionGetTicket(i);
//      if(ticket == 0) continue;
//      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
//      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;
//      if(gTrade.PositionClose(ticket)) closed++;
//   }
//   PrintFormat("%s: closed %d positions (reason=%s)", EA_TAG, closed, reason);
//   UpdatePanel();
//}
//
////+------------------------------------------------------------------+
////| Count own positions                                              |
////+------------------------------------------------------------------+
//int CountOwnPositions()
//{
//   int count = 0;
//   for(int i = PositionsTotal() - 1; i >= 0; i--) {
//      ulong ticket = PositionGetTicket(i);
//      if(ticket == 0) continue;
//      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
//      if(PositionGetInteger(POSITION_MAGIC) != (long)InpMagicNumber) continue;
//      count++;
//   }
//   return count;
//}
//
////+------------------------------------------------------------------+
////| Calculate lot size                                               |
////+------------------------------------------------------------------+
//double CalculateLot(int slPoints)
//{
//   double lot = InpFixedLot;
//   if(InpLotMode == LOT_RISK) {
//      double balance   = AccountInfoDouble(ACCOUNT_BALANCE);
//      double riskAmt   = balance * (InpRiskPercent / 100.0);
//      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
//      double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
//      if(tickSize > 0 && tickValue > 0 && slPoints > 0) {
//         double lossPerLot = (slPoints * _Point / tickSize) * tickValue;
//         if(lossPerLot > 0) lot = riskAmt / lossPerLot;
//      }
//   }
////--- Normalize
//   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
//   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
//   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
//   if(stepLot <= 0) stepLot = 0.01;
//   lot = MathRound(lot / stepLot) * stepLot;
//   if(lot < minLot) lot = minLot;
//   if(lot > maxLot) lot = maxLot;
//   return lot;
//}
//
////+------------------------------------------------------------------+
////| Trading permission check                                         |
////+------------------------------------------------------------------+
//bool IsTradingAllowed()
//{
//   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return false;
//   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) return false;
//   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) return false;
//   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) return false;
//   long mode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
//   if(mode != SYMBOL_TRADE_MODE_FULL) return false;
//   return true;
//}
//
////+------------------------------------------------------------------+
////| Time filter                                                      |
////+------------------------------------------------------------------+
//bool IsInTradingHours()
//{
//   MqlDateTime dt;
//   TimeToStruct(TimeCurrent(), dt);
//   int h = dt.hour;
//   if(InpStartHour <= InpEndHour)
//      return (h >= InpStartHour && h < InpEndHour);
//   else
//      return (h >= InpStartHour || h < InpEndHour);
//}
//
////+------------------------------------------------------------------+
////| Daily counters                                                   |
////+------------------------------------------------------------------+
//void ResetDailyCounters()
//{
//   gDailyTrades   = 0;
//   gDailyStartBal = AccountInfoDouble(ACCOUNT_BALANCE);
//   gDailyLimitHit = false;
//   MqlDateTime dt;
//   TimeToStruct(TimeCurrent(), dt);
//   dt.hour = 0;
//   dt.min = 0;
//   dt.sec = 0;
//   gDailyResetDate = StructToTime(dt);
//}
//
////+------------------------------------------------------------------+
////| Daily Reset                                                      |
////+------------------------------------------------------------------+
//void CheckDailyReset()
//{
//   MqlDateTime dt;
//   TimeToStruct(TimeCurrent(), dt);
//   dt.hour = 0;
//   dt.min = 0;
//   dt.sec = 0;
//   datetime today = StructToTime(dt);
//   if(today != gDailyResetDate) {
//      ResetDailyCounters();
//   }
////--- Check daily loss limit
//   if(InpMaxDailyLossPct > 0.0 && !gDailyLimitHit) {
//      double eq = AccountInfoDouble(ACCOUNT_EQUITY);
//      double drawdown = (gDailyStartBal - eq) / gDailyStartBal * 100.0;
//      if(drawdown >= InpMaxDailyLossPct) {
//         gDailyLimitHit = true;
//         PrintFormat("%s: daily loss limit hit (%.2f%% ≥ %.2f%%) - trading paused until next day",
//                     EA_TAG, drawdown, InpMaxDailyLossPct);
//         SendAlert("Daily loss limit reached — trading paused");
//      }
//   }
//}
//
////+------------------------------------------------------------------+
////| Alert dispatcher                                                 |
////+------------------------------------------------------------------+
//void SendAlert(const string message)
//{
//   string full = EA_TAG + " " + message;
//   if(InpAlertPopup) Alert(full);
//   if(InpAlertPush)  SendNotification(full);
//   if(InpAlertSound) PlaySound(InpSoundFile);
//   if(InpAlertEmail) SendMail(EA_TAG, full);
//   Print(full);
//}
//
////+------------------------------------------------------------------+
////| EA Panel — Creation                                              |
////+------------------------------------------------------------------+
//void CreatePanel()
//{
//// Background
//   if(ObjectFind(0, PANEL_BG) < 0) {
//      ObjectCreate(0, PANEL_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_CORNER, CORNER_LEFT_UPPER);
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_XSIZE, 230);
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_YSIZE, 140);
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_BGCOLOR, C'20,22,28');
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_BORDER_TYPE, BORDER_FLAT);
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_COLOR, C'70,70,70');
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_BACK, false);
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_SELECTABLE, false);
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_HIDDEN, true);
//      ObjectSetInteger(0, PANEL_BG, OBJPROP_ZORDER, 900);
//   }
//// Title bar
//   if(ObjectFind(0, PANEL_TITLE) < 0) {
//      ObjectCreate(0, PANEL_TITLE, OBJ_RECTANGLE_LABEL, 0, 0, 0);
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_CORNER, CORNER_LEFT_UPPER);
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_XSIZE, 230);
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_YSIZE, 26);
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_BGCOLOR, C'45,48,54');
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_BORDER_TYPE, BORDER_FLAT);
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_COLOR, C'70,70,70');
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_BACK, false);
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_SELECTABLE, false);
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_HIDDEN, true);
//      ObjectSetInteger(0, PANEL_TITLE, OBJPROP_ZORDER, 901);
//   }
//// Status label
//   if(ObjectFind(0, PANEL_STATUS) < 0) {
//      ObjectCreate(0, PANEL_STATUS, OBJ_LABEL, 0, 0, 0);
//      ObjectSetInteger(0, PANEL_STATUS, OBJPROP_CORNER, CORNER_LEFT_UPPER);
//      ObjectSetString(0, PANEL_STATUS, OBJPROP_FONT, "Segoe UI Semibold");
//      ObjectSetInteger(0, PANEL_STATUS, OBJPROP_FONTSIZE, 9);
//      ObjectSetInteger(0, PANEL_STATUS, OBJPROP_COLOR, clrWhite);
//      ObjectSetInteger(0, PANEL_STATUS, OBJPROP_SELECTABLE, false);
//      ObjectSetInteger(0, PANEL_STATUS, OBJPROP_HIDDEN, true);
//      ObjectSetInteger(0, PANEL_STATUS, OBJPROP_ZORDER, 950);
//   }
//// AutoTrade button
//   if(ObjectFind(0, BTN_AUTO) < 0) {
//      ObjectCreate(0, BTN_AUTO, OBJ_BUTTON, 0, 0, 0);
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_CORNER, CORNER_LEFT_UPPER);
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_XSIZE, 210);
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_YSIZE, 26);
//      ObjectSetString(0, BTN_AUTO, OBJPROP_FONT, "Segoe UI Semibold");
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_FONTSIZE, 10);
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_SELECTABLE, false);
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_HIDDEN, true);
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_ZORDER, 950);
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_BORDER_TYPE, BORDER_FLAT);
//   }
//// CloseAll button
//   if(ObjectFind(0, BTN_CLOSEALL) < 0) {
//      ObjectCreate(0, BTN_CLOSEALL, OBJ_BUTTON, 0, 0, 0);
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_CORNER, CORNER_LEFT_UPPER);
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_XSIZE, 210);
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_YSIZE, 26);
//      ObjectSetString(0, BTN_CLOSEALL, OBJPROP_FONT, "Segoe UI Semibold");
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_FONTSIZE, 10);
//      ObjectSetString(0, BTN_CLOSEALL, OBJPROP_TEXT, "Close All");
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_BGCOLOR, C'120,40,40');
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_COLOR, clrWhite);
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_SELECTABLE, false);
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_HIDDEN, true);
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_ZORDER, 950);
//      ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_BORDER_TYPE, BORDER_FLAT);
//   }
//   UpdatePanel();
//}
//
////+------------------------------------------------------------------+
////| EA Panel — Update positions                                      |
////+------------------------------------------------------------------+
//void UpdatePanelPositions()
//{
//   if(!InpShowPanel) return;
//   ObjectSetInteger(0, PANEL_TITLE, OBJPROP_XDISTANCE, gPanelX);
//   ObjectSetInteger(0, PANEL_TITLE, OBJPROP_YDISTANCE, gPanelY);
//   ObjectSetInteger(0, PANEL_BG, OBJPROP_XDISTANCE, gPanelX);
//   ObjectSetInteger(0, PANEL_BG, OBJPROP_YDISTANCE, gPanelY);
//   ObjectSetInteger(0, PANEL_STATUS, OBJPROP_XDISTANCE, gPanelX + 8);
//   ObjectSetInteger(0, PANEL_STATUS, OBJPROP_YDISTANCE, gPanelY + 7);
//   ObjectSetInteger(0, BTN_AUTO, OBJPROP_XDISTANCE, gPanelX + 10);
//   ObjectSetInteger(0, BTN_AUTO, OBJPROP_YDISTANCE, gPanelY + 40);
//   ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_XDISTANCE, gPanelX + 10);
//   ObjectSetInteger(0, BTN_CLOSEALL, OBJPROP_YDISTANCE, gPanelY + 74);
//}
//
////+------------------------------------------------------------------+
////| EA Panel — Update content                                        |
////+------------------------------------------------------------------+
//void UpdatePanel()
//{
//   if(!InpShowPanel) return;
////--- Title text
//   ObjectSetString(0, PANEL_STATUS, OBJPROP_TEXT, "WaveMaster Pro EA");
////--- AutoTrade button
//   ObjectSetString(0, BTN_AUTO, OBJPROP_TEXT,
//                   gAutoTrade ? "AutoTrade : ON" : "AutoTrade : OFF");
//   if(gAutoTrade) {
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_BGCOLOR, C'30,120,60');
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_BORDER_COLOR, clrLime);
//   } else {
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_BGCOLOR, C'150,45,45');
//      ObjectSetInteger(0, BTN_AUTO, OBJPROP_BORDER_COLOR, clrMaroon);
//   }
//   ObjectSetInteger(0, BTN_AUTO, OBJPROP_COLOR, clrWhite);
//   UpdatePanelPositions();
//   ChartRedraw(0);
//}
//
////+------------------------------------------------------------------+
////| EA Panel — Delete                                                |
////+------------------------------------------------------------------+
//void DeletePanel()
//{
//   ObjectDelete(0, PANEL_BG);
//   ObjectDelete(0, PANEL_TITLE);
//   ObjectDelete(0, PANEL_STATUS);
//   ObjectDelete(0, BTN_AUTO);
//   ObjectDelete(0, BTN_CLOSEALL);
//}
////+------------------------------------------------------------------+
////+------------------------------------------------------------------+
//
///*
//
//            How the EA Reads Signals:
//            
//            When you build the EA, the code to read the signal looks like this:
//            
//            // --- In the EA (not in the indicator) ---
//            int h = iCustom(_Symbol, _Period, "WaveMaster_Pro_v9_Indicator",
//            // input order matches the indicator's input declarations //
//            14, 2.0,               // Oscilloscope
//            80.0, false,           // Signal Export
//            true, false, true, false, // Alerts
//            true, true, 1.00, true, true, // Display
//            true, 30, 2, true, 64, true,  // v6
//            true, 50, 0.6, 2.5,   // v7 Adaptive
//            true, "EURUSD,...", 800, // v7 Scanner
//            true, 0.05, 3,        // v7 ML
//            true, "RITZ_ML", 20,  // v8 Persistence
//            true, 0.35, 0.30, 0.20, 0.15, // v8 Score
//            true, 500, 20, 0.10, 0.68, 0.0, C'0,200,0', C'0,110,0', C'200,0,0', C'110,0,0', // v8.2 Vol
//            false, "DISCORD", "", "", "", 30, true, true, true); // v8 Webhook
//            
//            // Read signal
//            double sig[]; 
//            if(CopyBuffer(h, 11, 0, 1, sig) == 1) {
//            int signal = (int)sig[0]; // +1 BUY / -1 SELL / 0 NONE
//            if(signal != 0) { // execute trade // }
//            }
//            
//            // Read supporting data for filtering
//            double mlProb[], score[], thr[]; 
//            CopyBuffer(h, 7, 0, 1, mlProb); 
//            CopyBuffer(h, 9, 0, 1, score); 
//            CopyBuffer(h, 8, 0, 1, thr); 
//            
//            
//            Note: The input order in iCustom() MUST match exactly the input declarations in the indicator file. If the order is incorrect, the result will be INVALID_HANDLE. 
//            
//            Buffer Summary (iCustom Index)
//            Index	Name	Value	EA Usage
//            0	BufProbe	−100..+100	Directional bias
//            1	BufAnomaly	0..∞	Signal strength
//            2	BufRsi	0..100	Overbought/oversold
//            3	BufMomentum	−5..+5 %	Trend confirmation
//            4	BufDivergence	−1/0/+1	Reversal hint
//            5	BufFftFreq	0..0.5	Dominant cycle
//            6	BufFftMag	0..∞	Cycle strength
//            7	BufMLProb	0..1	ML bullish prob
//            8	BufAdaptiveThr	0.6..5.0	Dynamic threshold
//            9	BufSignalScore	0..100	Combined score
//            10	BufMLReady	0/1	Cold-start flag
//            11	BufSignal	+1/0/−1	TRIGGER TRADE
//
//
//
//*/

// end unblock comment here..