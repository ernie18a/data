//+====================================================================================================================+
//|                                                                                                     V1N1 LONNY.mq5 |
//|                                                              Copyright (c) 2016-2026, Vinicius Pereira De Oliveira |
//|                                                                          https://www.mql5.com/en/users/vinicius-fx |
//+====================================================================================================================+
#property copyright   "Copyright (c) 2016-2026, Vinicius Pereira De Oliveira"
#property description "Asian Range Breakout day-trading EA. Multi-symbol, M15/M30/H1. Places"
#property description "pending stop orders during the London session outside the pre-London"
#property description "Asian range, using PSAR + MACD + Stochastic signals, with automatic"
#property description "London/NY DST handling, structural stops, trailing and break-even."
#property link        "https://www.mql5.com/en/users/vinicius-fx"
#property version     "7.300"
#property strict

#include <Trade\Trade.mqh>

//+====================================================================================================================+
//| GLOBAL CONSTANTS
//+====================================================================================================================+

//--- Identification
#define EA_COMMENT                   "[LONNY]"

//--- Indicator Settings
#define MAX_ATR_VARIATION            0.618
#define STOCHASTIC_FACTOR            0.618
#define STOCHASTIC_RANGE_MIN         38.20
#define STOCHASTIC_RANGE_MAX         61.80
#define MACD_FAST_FACTOR             1.333     // MACD multiplier: Fast derived from Signal
#define MACD_SLOW_FACTOR             2.889     // MACD multiplier: Slow derived from Signal
#define PSAR_MAX                     0.200     // PSAR Maximum acceleration step

//--- Trading & Management Settings
#define MIN_MARGIN_LEVEL             200.0
#define MARGIN_SAFETY_BUFFER         0.050     // % extra margin buffer when validating new orders
#define MIN_STOP_PERCENT             0.618     // Stop Loss limit: min (% of ADR)
#define MAX_STOP_PERCENT             1.382     // Stop Loss limit: max (% of ADR)
#define TAKE_PROFIT_FACTOR           1.618     // TP distance = SL distance * factor
#define SL_BUFFER_PERCENT            0.236     // Stop Loss buffer beyond the opposite PSAR swing (% of ADR)
#define BREAKOUT_BUFFER_ATR          0.146     // Entry buffer beyond the PSAR swing (% of ATR)
#define TRAILING_START_PERCENT       0.090     // When trailing starts (% of SL distance)
#define BREAKEVEN_PERCENT            0.618     // Break-even level (% of SL distance)
#define DISTANCE_PERCENT             0.146     // Minimum distance between orders/positions of the same symbol/timeframe (% of ADR)
#define ASIAN_RANGE_MIN_PERCENT      0.236     // Asian range size filter (% of ADR): trade only when MIN <= range
#define ASIAN_RANGE_MAX_PERCENT      0.764     // Asian range size filter (% of ADR): trade only when range <= MAX 
#define MAX_SPREAD_PERCENT           0.090
#define SLIPPAGE_POINTS              100
#define MAX_SYMBOLS                  22

//--- Closing Reasons
#define CLOSE_REASON_NONE            0
#define CLOSE_REASON_PROFIT          1
#define CLOSE_REASON_LOSS            2
#define CLOSE_REASON_END_SESSION     3

//--- Time Settings
#define NEW_CANDLE_TOLERANCE         60
#define TIMER_PERIOD_SECONDS         1
#define CLOSE_BEFORE_SESSION         1870

//--- History Loading Constants
#define HISTORY_LOAD_OK              0
#define HISTORY_LOAD_CACHED          1
#define HISTORY_LOAD_BUILT           2
#define HISTORY_ERR_UNKNOWN_SYMBOL  -1
#define HISTORY_ERR_MAX_BARS        -2
#define HISTORY_ERR_STOPPED         -3
#define HISTORY_ERR_LOAD_FAILED     -4

//+====================================================================================================================+
//| DEFAULT PER-SYMBOL VALUES | DEFAULT SYMBOL LIST
//+====================================================================================================================+
//--- Default Per-Symbol Values
#define DEFAULT_ADR_PERIOD           ADR_PERIOD_42  // ADR/ATR lookback in days
#define DEFAULT_PERIOD_H1            PERIOD_H1_14
#define DEFAULT_STEP_SAR             STEP_SAR_002 / 100.0
#define DEFAULT_MACD_SIGNAL_H1       MACD_SIGNAL_14
#define DEFAULT_ASIAN_RANGE_BARS_H1  ASIAN_RANGE_BARS_8
//--- Trading Symbols
#define DEFAULT_SYMBOL_LIST          ".US30Cash,.US500Cash,.USTECHCash,AUDJPY,AUDUSD,CADJPY,EURJPY,EURUSD,GBPJPY,NZDJPY,USDCAD,USDJPY,XAGUSD,XAUUSD,BTCUSD"

//+====================================================================================================================+
//| ENUMERATIONS
//+====================================================================================================================+
enum ENUM_RISK_MODE
  {
   RISK_MODE_PERCENTAGE   = 1,     // Percentage
   RISK_MODE_FIXED_LOT    = 2,     // Fixed Lot
   RISK_MODE_FIXED_AMOUNT = 3      // Amount
  };
enum ENUM_TF_INDEX
  {
   TF_INDEX_M15   = 0,
   TF_INDEX_M30   = 1,
   TF_INDEX_H1    = 2,
   TF_INDEX_COUNT = 3
  };
enum ENUM_DST_MODE
  {
   DST_NONE     = 0,               // Server does NOT follow DST
   DST_USA      = 1,               // Server follows USA DST
   DST_EUROPE   = 2                // Server follows European DST
  };
//--- Per-Symbol Parameter Optimization
enum ENUM_ADR_PERIOD
  {
   ADR_PERIOD_6  = 6,
   ADR_PERIOD_12 = 12,
   ADR_PERIOD_24 = 24,
   ADR_PERIOD_42 = 42,
   ADR_PERIOD_60 = 60
  };
enum ENUM_PERIOD_H1
  {
   PERIOD_H1_D  = 0,
   PERIOD_H1_6  = 6,
   PERIOD_H1_14 = 14,
   PERIOD_H1_22 = 22
  };
enum ENUM_STEP_SAR
  {
   STEP_SAR_002 = 2,
   STEP_SAR_009 = 9,
   STEP_SAR_016 = 16
  };
enum ENUM_MACD_SIGNAL
  {
   MACD_SIGNAL_9  = 9,
   MACD_SIGNAL_14 = 14,
   MACD_SIGNAL_21 = 21
  };
enum ENUM_ASIAN_RANGE_BARS
  {
   ASIAN_RANGE_BARS_6  = 6,
   ASIAN_RANGE_BARS_8  = 8,
   ASIAN_RANGE_BARS_10 = 10
  };
//+====================================================================================================================+
//| STRUCTURES
//+====================================================================================================================+
struct SymbolParamsMap
  {
   string            pattern;
   int               adrPeriod;
   int               periodH1;
   double            stepSAR;
   int               macdSignalH1;
   int               asianRangeBarsH1;
  };
struct SymbolParams
  {
   string            symbol;
   int               adrPeriod;
   int               periodH1;
   double            stepSAR;
   int               macdSignalH1;
   int               asianRangeBarsH1;
  };
struct AsianRange
  {
   double            high;
   double            low;
   double            size;
   bool              isValid;
  };
struct MarketData
  {
   double            adr;
   double            atr;
   double            atrVariation;
   double            stochastic;
   double            psarPrev;
   double            psarPrev2;
   double            macdPrev;
   double            macdPrev2;
   double            macdSignalPrev;
   double            macdSignalPrev2;
   bool              isValid;
  };
struct SymbolCache
  {
   string            symbol;
   double            bid;
   double            ask;
   double            point;
   long              digits;
   long              spread;
   long              stopsLevel;
   long              freezeLevel;
   double            tickSize;
   double            tickValue;
   double            volumeMin;
   double            volumeMax;
   double            volumeStep;
   double            volumeLimit;
   bool              isValid;
  };
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
//| INPUTS USED FOR PERIODIC OPTIMIZATION OF THE PER-SYMBOL
//| PARAMETERS FROM THE InitSymbolParamsTable() FUNCTION.
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
/*
input group                 "OPTIMIZATION SETTINGS"
input ENUM_ADR_PERIOD       OPT_PARAM_ADR_PERIOD          = DEFAULT_ADR_PERIOD;
input ENUM_PERIOD_H1        OPT_PARAM_PERIOD_H1           = DEFAULT_PERIOD_H1;
input ENUM_STEP_SAR         OPT_PARAM_STEP_SAR            = STEP_SAR_002;
input ENUM_MACD_SIGNAL      OPT_PARAM_MACD_SIGNAL_H1      = DEFAULT_MACD_SIGNAL_H1;
input ENUM_ASIAN_RANGE_BARS OPT_PARAM_ASIAN_RANGE_BARS_H1 = DEFAULT_ASIAN_RANGE_BARS_H1;

double optParamStepSAR = OPT_PARAM_STEP_SAR / 100.0;
*/
//+====================================================================================================================+
//| INPUT PARAMETERS
//+====================================================================================================================+
input group           "TRADING SYMBOLS (separated by commas)"
input string          InpSymbolList       = DEFAULT_SYMBOL_LIST;   // Symbol List (empty = current symbol)
//
input group           "TRADING SESSIONS"
input int             InpServerGMTOffset  = 2;                     // Server GMT Offset in hours
input ENUM_DST_MODE   InpServerDST        = DST_EUROPE;            // Server DST Convention
//
input group           "RISK MANAGEMENT"
input ENUM_RISK_MODE  InpRiskMode         = RISK_MODE_PERCENTAGE;  // Risk Mode
input double          InpRiskSize         = 0.50;                  // Risk Size (depends on Risk Mode)
//
input group           "DAILY CONTROLS (0 = Disabled)"
input double          InpDailyProfit      = 11.00;                 // Daily Profit Limit (%)
input double          InpDailyLoss        = 5.00;                  // Daily Loss Limit (%)
//+====================================================================================================================+
//| GLOBAL VARIABLES
//+====================================================================================================================+
//--- Symbols to trade
SymbolParams    g_symbols[];
int             g_symbolCount = 0;

//--- Symbol parameters mapping table
SymbolParamsMap g_symbolParamsTable[];

//--- Symbol cache for the symbol currently being processed
SymbolCache     g_cache;

//--- Indicator handles (per symbol / per timeframe)
int             g_handleADR[MAX_SYMBOLS];                       // ADR on D1 (single fixed period)
int             g_handleATR[MAX_SYMBOLS][TF_INDEX_COUNT];       // ATR on trading TF
int             g_handleATRfast[MAX_SYMBOLS][TF_INDEX_COUNT];   // 1x ATR (for ATR variation)
int             g_handleADRfast[MAX_SYMBOLS];                   // 1-period ADR on D1 (for ATR variation)
int             g_handleStochastic[MAX_SYMBOLS][TF_INDEX_COUNT];
int             g_handlePSAR[MAX_SYMBOLS][TF_INDEX_COUNT];
int             g_handleMACD[MAX_SYMBOLS][TF_INDEX_COUNT];

//--- Limiters of the indicator periods
const int       g_maxIndPeriods[TF_INDEX_COUNT] = {96, 48, 24};
const int       g_minIndPeriods[TF_INDEX_COUNT] = { 8,  4,  2};

//--- New-candle processing control
datetime        g_lastCandleTime[TF_INDEX_COUNT];

//--- Trading class
CTrade          g_trade;

//+====================================================================================================================+
//| SYMBOL PARAMETERS TABLE
//+====================================================================================================================+
void InitSymbolParamsTable()
  {
   ArrayResize(g_symbolParamsTable, 19);
   int i = 0;

//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
//| === FOR USE IN PERIODIC OPTIMIZATIONS ===
//| Copy and paste the following list, replacing the respective per-symbol parameters in the SetSymbolParams() call:
//| OPT_PARAM_ADR_PERIOD, OPT_PARAM_PERIOD_H1, optParamStepSAR, OPT_PARAM_MACD_SIGNAL_H1, OPT_PARAM_ASIAN_RANGE_BARS_H1
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +

// Indices
   SetSymbolParams(i++, "US30",   12, 6,  0.09, 9,  6);
   SetSymbolParams(i++, "US500",  12, 22, 0.16, 9,  6);
   SetSymbolParams(i++, "USTEC",  6,  6,  0.16, 9,  8);
   SetSymbolParams(i++, "US100",  6,  6,  0.16, 9,  8);
   SetSymbolParams(i++, "NAS100", 6,  6,  0.16, 9,  8);

// Forex
   SetSymbolParams(i++, "AUDJPY", 12, 22, 0.16, 14, 10);
   SetSymbolParams(i++, "AUDUSD", 12, 22, 0.02, 14, 8);
   SetSymbolParams(i++, "CADJPY", 42, 14, 0.09, 21, 10);
   SetSymbolParams(i++, "EURJPY", 42, 14, 0.16, 9,  6);
   SetSymbolParams(i++, "EURUSD", 60, 6,  0.16, 14, 6);
   SetSymbolParams(i++, "GBPJPY", 24, 14, 0.02, 14, 6);
   SetSymbolParams(i++, "NZDJPY", 42, 6,  0.09, 9,  10);
   SetSymbolParams(i++, "USDCAD", 24, 14, 0.02, 14, 8);
   SetSymbolParams(i++, "USDJPY", 12, 22, 0.02, 14, 6);

// Metals
   SetSymbolParams(i++, "XAGUSD", 6,  0,  0.02, 21, 6);
   SetSymbolParams(i++, "SILVER", 6,  0,  0.02, 21, 6);
   SetSymbolParams(i++, "XAUUSD", 60, 14, 0.16, 21, 10);
   SetSymbolParams(i++, "GOLD",   60, 14, 0.16, 21, 10);

// Crypto
   SetSymbolParams(i++, "BTCUSD", 24, 6,  0.09, 21, 10);

   ArrayResize(g_symbolParamsTable, i);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Set a symbol parameters mapping entry
//+--------------------------------------------------------------------------------------------------------------------+
void SetSymbolParams(int idx, string pattern, int adrPeriod, int periodH1, double stepSAR, int macdSignalH1, int asianRangeBarsH1)
  {
   if(idx >= ArraySize(g_symbolParamsTable))
      return;
   g_symbolParamsTable[idx].pattern          = pattern;
   g_symbolParamsTable[idx].adrPeriod        = adrPeriod;
   g_symbolParamsTable[idx].periodH1         = periodH1;
   g_symbolParamsTable[idx].stepSAR          = stepSAR;
   g_symbolParamsTable[idx].macdSignalH1     = macdSignalH1;
   g_symbolParamsTable[idx].asianRangeBarsH1 = asianRangeBarsH1;
  }
//+====================================================================================================================+
//| EXPERT LIFECYCLE
//+====================================================================================================================+
int OnInit()
  {
   if(!ValidateInputs())
      return INIT_PARAMETERS_INCORRECT;

   InitSymbolParamsTable();

   if(!InitializeSymbols())
      return INIT_PARAMETERS_INCORRECT;

   for(int i = 0; i < TF_INDEX_COUNT; i++)
      g_lastCandleTime[i] = 0;

   g_trade.SetDeviationInPoints(SLIPPAGE_POINTS);
   g_trade.LogLevel(LOG_LEVEL_ERRORS);
   g_trade.SetMarginMode();

   TesterHideIndicators(true);

   if(!InitializeAllIndicators())
      return INIT_FAILED;

   if(!EventSetTimer(TIMER_PERIOD_SECONDS))
     {
      Print("<", __FUNCTION__, "> Error setting timer: ", GetLastError());
      return INIT_FAILED;
     }

   Print("<", __FUNCTION__, "> EA initialized with ", g_symbolCount, " symbols");
   return INIT_SUCCEEDED;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Expert deinitialization
//+--------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ReleaseAllIndicators();
   Comment("");
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Timer function
//+--------------------------------------------------------------------------------------------------------------------+
void OnTimer()
  {
   if(!IsTradingAllowed())
     {
      Comment("Trade is not allowed");
      return;
     }

   Comment("");

   for(int tfIndex = 0; tfIndex < TF_INDEX_COUNT && !IsStopped(); tfIndex++)
      ProcessTimeframe(tfIndex);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Tester fitness function
//+--------------------------------------------------------------------------------------------------------------------+
double OnTester()
  {
   double profit       = MathMax(0.01, TesterStatistics(STAT_PROFIT));
   double profitFactor = MathMax(0.01, TesterStatistics(STAT_PROFIT_FACTOR));
   double drawdown     = MathMax(0.01, TesterStatistics(STAT_EQUITY_DDREL_PERCENT));
   double trades       = MathMax(2.00, TesterStatistics(STAT_TRADES));
   double sharpe       = MathMax(0.01, TesterStatistics(STAT_SHARPE_RATIO));
   double recovery     = MathMax(0.01, TesterStatistics(STAT_RECOVERY_FACTOR));

   const double WEIGHT_PROFIT        = 0.25;
   const double WEIGHT_PROFIT_FACTOR = 0.20;
   const double WEIGHT_DRAWDOWN      = 0.20;
   const double WEIGHT_TRADES        = 0.15;
   const double WEIGHT_SHARPE        = 0.10;
   const double WEIGHT_RECOVERY      = 0.10;

   double profitComponent   = MathPow(profit, WEIGHT_PROFIT);
   double pfComponent       = MathPow(profitFactor, WEIGHT_PROFIT_FACTOR);
   double ddComponent       = MathPow(drawdown, WEIGHT_DRAWDOWN);
   double recoveryComponent = MathPow(recovery, WEIGHT_RECOVERY);
   double sharpeComponent   = MathPow(sharpe, WEIGHT_SHARPE);
   double tradesComponent   = MathPow(MathLog10(trades), WEIGHT_TRADES);

   double numerator = profitComponent * pfComponent * tradesComponent *
                      sharpeComponent * recoveryComponent;

   return numerator / ddComponent;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Validate input parameters
//+--------------------------------------------------------------------------------------------------------------------+
bool ValidateInputs()
  {
   if(InpRiskSize <= 0.0)
     {
      Alert("Risk Size must be greater than zero");
      return false;
     }
   if(InpDailyProfit < 0.0)
     {
      Alert("Daily Profit Limit cannot be negative");
      return false;
     }
   if(InpDailyLoss < 0.0)
     {
      Alert("Daily Loss Limit cannot be negative");
      return false;
     }
   if(InpServerGMTOffset < -12 || InpServerGMTOffset > 14)
     {
      Alert("Server GMT Offset must be between -12 and 14");
      return false;
     }
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Check trading permissions
//+--------------------------------------------------------------------------------------------------------------------+
bool IsTradingAllowed()
  {
   return TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) &&
          MQLInfoInteger(MQL_TRADE_ALLOWED) &&
          AccountInfoInteger(ACCOUNT_TRADE_EXPERT) &&
          AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
  }
//+====================================================================================================================+
//| TIMEFRAME & SYMBOL PROCESSING
//+====================================================================================================================+
void ProcessTimeframe(int tfIndex)
  {
   ENUM_TIMEFRAMES tf  = IndexToTimeframe(tfIndex);
   datetime candleTime = GetCandleOpenTime(tf);

// New-candle check
   if(candleTime == g_lastCandleTime[tfIndex])
      return;

// Time-tolerance check
   if(TimeCurrent() >= candleTime + NEW_CANDLE_TOLERANCE)
      return;

   for(int symIndex = 0; symIndex < g_symbolCount && !IsStopped(); symIndex++)
      ProcessSymbol(symIndex, tf, tfIndex);

   g_lastCandleTime[tfIndex] = candleTime;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Get current candle open time
//+--------------------------------------------------------------------------------------------------------------------+
datetime GetCandleOpenTime(ENUM_TIMEFRAMES tf)
  {
   int periodSec = PeriodSeconds(tf);
   return (datetime)(periodSec * (TimeCurrent() / periodSec));
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Process a symbol
//+--------------------------------------------------------------------------------------------------------------------+
void ProcessSymbol(int symIndex, ENUM_TIMEFRAMES tf, int tfIndex)
  {
   string symbol = g_symbols[symIndex].symbol;

   if(!IsSymbolAvailable(symbol))
      return;

   if(!IsWithinTradingHours(symbol, TimeCurrent()))
      return;

   if(!UpdateSymbolCache(symbol))
     {
      Print("<", __FUNCTION__, "> Failed to update cache: ", symbol);
      return;
     }

   ExecuteTradingLogic(symbol, symIndex, tf, tfIndex);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Execute the trading logic for one symbol/timeframe
//+--------------------------------------------------------------------------------------------------------------------+
void ExecuteTradingLogic(string symbol, int symIndex, ENUM_TIMEFRAMES tf, int tfIndex)
  {
   long magic = GetMagicNumber(tf);

   g_trade.SetExpertMagicNumber(magic);
   g_trade.SetTypeFillingBySymbol(symbol);

// Daily limits: close everything if a limit was hit
   int closeReason = CheckDailyLimits(symbol);
   if(closeReason != CLOSE_REASON_NONE)
     {
      CancelPendingOrders(symbol, magic);
      CloseSymbolPositions(symbol, magic, closeReason);
      return;
     }

// End-of-day flattening: near NY close OR near the symbol session close, whichever comes first.
   bool afterTradingEnd = IsAfterTradingHours();
   bool nearSessionEnd  = IsNearSymbolSessionClose(symbol, TimeCurrent());

   if(afterTradingEnd || nearSessionEnd)
     {
      CancelPendingOrders(symbol, magic);
      CloseSymbolPositions(symbol, magic, CLOSE_REASON_END_SESSION);
      return;
     }

// Trading period (bars) for this timeframe, derived from periodH1
   int tradingPeriod = GetTradingPeriod(symbol, tf, symIndex, tfIndex);
   if(tradingPeriod <= 0)
      return;

// History check
   int barsRequired = g_symbols[symIndex].adrPeriod * tradingPeriod + 2;
   if(!CheckHistoricalData(symbol, tf, barsRequired, g_symbols[symIndex].adrPeriod))
      return;

// Market data (ADR/ATR/Stochastic/PSAR/MACD)
   MarketData data;
   if(!CalculateMarketData(symbol, symIndex, tf, tfIndex, tradingPeriod, data))
      return;

// ATR filter: skip new-entry analysis on low-volatility candles (keeps performance and avoids noise),
// but ALWAYS manage open positions first so trailing/break-even/MACD-exit keep working.
   ManageOpenPositions(symbol, symIndex, tf, magic, data);

   double lastHigh = iHigh(symbol, tf, 1);
   double lastLow  = iLow(symbol, tf, 1);
   if(lastHigh - lastLow <= data.atr || MathAbs(data.atrVariation) > MAX_ATR_VARIATION)
      return;

// Pending orders may only be PLACED while inside the placement window
// (from London open until London close).
   if(!IsWithinPlacementWindow())
      return;

// Asian range (measured in real H1 bars)
   AsianRange asianRange;
   if(!CalculateAsianRange(symbol, g_symbols[symIndex].asianRangeBarsH1, asianRange))
      return;

// Analyze signals and try to place pending orders
   AnalyzeSignals(symbol, symIndex, tf, tfIndex, magic, tradingPeriod, data, asianRange);
  }
//+====================================================================================================================+
//| MARKET DATA (single fixed ADR/ATR period; PSAR + MACD + Stochastic via handles)
//+====================================================================================================================+
bool CalculateMarketData(string symbol, int symIndex, ENUM_TIMEFRAMES tf, int tfIndex, int tradingPeriod, MarketData &data)
  {
   data.adr             = 0.0;
   data.atr             = 0.0;
   data.atrVariation    = 0.0;
   data.stochastic      = 50.0;
   data.psarPrev        = 0.0;
   data.psarPrev2       = 0.0;
   data.macdPrev        = 0.0;
   data.macdPrev2       = 0.0;
   data.macdSignalPrev  = 0.0;
   data.macdSignalPrev2 = 0.0;
   data.isValid         = false;

   double buffer[];

// --- ADR (D1, single fixed period) and ATR (trading TF, period x tradingPeriod) ---
   if(CopyBuffer(g_handleADR[symIndex], 0, 1, 1, buffer) < 1)
      return false;
   data.adr = buffer[0];

   if(CopyBuffer(g_handleATR[symIndex][tfIndex], 0, 1, 1, buffer) < 1)
      return false;
   data.atr = buffer[0];

   if(data.adr <= 0.0 || data.atr <= 0.0)
     {
      Print("<", __FUNCTION__, "> Invalid ATR/ADR: ", symbol);
      return false;
     }

// --- ATR variation: compares the most recent 1-period reading against the reference ---
   double adrFast = 0.0, atrFast = 0.0;
   if(CopyBuffer(g_handleADRfast[symIndex], 0, 1, 1, buffer) < 1)
      return false;
   adrFast = buffer[0];

   if(CopyBuffer(g_handleATRfast[symIndex][tfIndex], 0, 1, 1, buffer) < 1)
      return false;
   atrFast = buffer[0];

   data.atrVariation = (adrFast / data.adr - 1.0) * 0.5 + (atrFast / data.atr - 1.0) * 0.5;

// --- Stochastic ---
   if(CopyBuffer(g_handleStochastic[symIndex][tfIndex], MAIN_LINE, 1, 1, buffer) < 1)
      return false;
   data.stochastic = buffer[0];
   if(data.stochastic <= 0.0)
      data.stochastic = 50.0;

// --- PSAR (shift 1 most recent, shift 2 older) ---
   if(CopyBuffer(g_handlePSAR[symIndex][tfIndex], 0, 1, 2, buffer) < 2)
      return false;
   data.psarPrev  = buffer[1];   // shift 1
   data.psarPrev2 = buffer[0];   // shift 2

// --- MACD main + signal (shifts 1 and 2) ---
   if(CopyBuffer(g_handleMACD[symIndex][tfIndex], MAIN_LINE, 1, 2, buffer) < 2)
      return false;
   data.macdPrev  = buffer[1];   // shift 1
   data.macdPrev2 = buffer[0];   // shift 2

   if(CopyBuffer(g_handleMACD[symIndex][tfIndex], SIGNAL_LINE, 1, 2, buffer) < 2)
      return false;
   data.macdSignalPrev  = buffer[1];   // shift 1
   data.macdSignalPrev2 = buffer[0];   // shift 2

   data.isValid = true;
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Convert a value expressed in H1 bars (hours) to the equivalent number of bars on the given timeframe
//+--------------------------------------------------------------------------------------------------------------------+
int ConvertHoursToBars(int valueH1, ENUM_TIMEFRAMES tf)
  {
   int tfMinutes = PeriodSeconds(tf) / 60;
   if(tfMinutes <= 0)
      tfMinutes = 1;
   int barsPerHour = 60 / tfMinutes;
   if(barsPerHour < 1)
      barsPerHour = 1;
   return valueH1 * barsPerHour;
  }
//+====================================================================================================================+
//| ASIAN RANGE CALCULATION (measured in real H1 bars, before London open)
//+====================================================================================================================+
bool CalculateAsianRange(string symbol, int barCountH1, AsianRange &range)
  {
   range.high    = 0.0;
   range.low     = 0.0;
   range.size    = 0.0;
   range.isValid = false;

   if(barCountH1 <= 0)
      return false;

// London open adjusted for DST (server time)
   datetime londonStart = GetLondonStartTime();
   if(londonStart == 0)
      return false;

// H1 bar at the London open
   int shiftStart = iBarShift(symbol, PERIOD_H1, londonStart, false);
   if(shiftStart < 0)
      return false;

// High/Low of the 'barCountH1' real H1 bars BEFORE the London open
   int highestBar = iHighest(symbol, PERIOD_H1, MODE_HIGH, barCountH1, shiftStart + 1);
   int lowestBar  = iLowest(symbol,  PERIOD_H1, MODE_LOW,  barCountH1, shiftStart + 1);

   if(highestBar < 0 || lowestBar < 0)
      return false;

   range.high = iHigh(symbol, PERIOD_H1, highestBar);
   range.low  = iLow(symbol,  PERIOD_H1, lowestBar);

   if(range.high <= 0.0 || range.low <= 0.0 || range.high <= range.low)
      return false;

   range.size    = range.high - range.low;
   range.isValid = true;
   return true;
  }
//+====================================================================================================================+
//| SIGNAL ANALYSIS - PSAR + MACD + Stochastic
//+====================================================================================================================+
void AnalyzeSignals(string symbol, int symIndex, ENUM_TIMEFRAMES tf, int tfIndex, long magic,
                    int tradingPeriod, const MarketData &data, const AsianRange &asianRange)
  {
   if(!asianRange.isValid)
      return;

// Asian range size filter: trade only when the range is neither too tight nor too wide vs ADR
   double rangeMin = ASIAN_RANGE_MIN_PERCENT * data.adr;
   double rangeMax = ASIAN_RANGE_MAX_PERCENT * data.adr;
   if(asianRange.size < rangeMin || asianRange.size > rangeMax)
      return;

// Spread check
   double maxSpreadPrice = MAX_SPREAD_PERCENT * data.adr;
   double currentSpread  = (double)g_cache.spread * g_cache.point;
   if(currentSpread > maxSpreadPrice)
     {
      Print("<", __FUNCTION__, "> Spread exceeded: ", symbol, " spread=", currentSpread, " max=", maxSpreadPrice);
      return;
     }

   double close1 = iClose(symbol, tf, 1);
   double close2 = iClose(symbol, tf, 2);
   if(close1 <= 0.0 || close2 <= 0.0)
      return;

// MACD direction on the last closed bar (used to align entries with the exit logic)
   bool macdBullish = (data.macdPrev > data.macdSignalPrev);
   bool macdBearish = (data.macdPrev < data.macdSignalPrev);

// === BUY signal: PSAR crossed below price + MACD bullish + Stochastic not overbought ===
   bool psarBullCross = (data.psarPrev < close2 && data.psarPrev2 > close1);
   if(psarBullCross && macdBullish && data.stochastic <= STOCHASTIC_RANGE_MAX)
     {
      TryPlacePendingOrder(symbol, symIndex, tf, tfIndex, magic, true, tradingPeriod, data, asianRange);
      return;
     }

// === SELL signal: PSAR crossed above price + MACD bearish + Stochastic not oversold ===
   bool psarBearCross = (data.psarPrev > close2 && data.psarPrev2 < close1);
   if(psarBearCross && macdBearish && data.stochastic >= STOCHASTIC_RANGE_MIN)
     {
      TryPlacePendingOrder(symbol, symIndex, tf, tfIndex, magic, false, tradingPeriod, data, asianRange);
     }
  }
//+====================================================================================================================+
//| FIND PSAR SWINGS - locates the most recent swing TOP and swing BOTTOM in a single pass
//+====================================================================================================================+
//| Scans back up to searchBars looking for PSAR flips relative to price:
//|  - swing TOP    (high): PSAR is ABOVE price now and was BELOW just before it (resistance).
//|  - swing BOTTOM (low) : PSAR is BELOW price now and was ABOVE just before it (support).
//| Captures the MOST RECENT of each type (first found while scanning back). Returns true only when
//| BOTH swings were found, writing them to 'high' and 'low'.
//+--------------------------------------------------------------------------------------------------------------------+
bool FindPSAR(string symbol, ENUM_TIMEFRAMES tf, int handle, int searchBars, double &low, double &high)
  {
   low  = -1.0;
   high = -1.0;
   bool foundHigh = false;
   bool foundLow  = false;

   double psar[];
   for(int cnt = 1; cnt <= searchBars && !IsStopped(); cnt++)
     {
      // Two PSAR values starting at shift 'cnt': psar[0] = older (cnt+1), psar[1] = recent (cnt)
      if(CopyBuffer(handle, 0, cnt, 2, psar) < 2)
         return false;

      double closeCnt   = iClose(symbol, tf, cnt);
      double closeCnt1  = iClose(symbol, tf, cnt + 1);
      if(closeCnt <= 0.0 || closeCnt1 <= 0.0)
         continue;

      // psar[1] is value at shift cnt, psar[0] is value at shift cnt+1
      if(!foundHigh && psar[1] > closeCnt && psar[0] < closeCnt1)
        {
         high = psar[1];
         foundHigh = true;
        }
      if(!foundLow && psar[1] < closeCnt && psar[0] > closeCnt1)
        {
         low = psar[1];
         foundLow = true;
        }

      if(foundHigh && foundLow)
         return true;
     }

   return (foundHigh && foundLow);
  }
//+====================================================================================================================+
//| TRY PLACE PENDING ORDER - entry at PSAR swing, structural SL at opposite PSAR swing
//+====================================================================================================================+
void TryPlacePendingOrder(string symbol, int symIndex, ENUM_TIMEFRAMES tf, int tfIndex, long magic, bool isBuy,
                          int tradingPeriod, const MarketData &data, const AsianRange &asianRange)
  {
   if(!asianRange.isValid)
      return;

// PSAR search range derived from the trading period (with a sane floor)
   int searchBars = MathMax(20, tradingPeriod * 2);
   int psarHandle = g_handlePSAR[symIndex][tfIndex];

// Single pass: get both PSAR swings (low = support, high = resistance)
   double psarLow, psarHigh;
   if(!FindPSAR(symbol, tf, psarHandle, searchBars, psarLow, psarHigh))
      return;

// Entry anchor = swing on the trade side; SL anchor = swing on the opposite side
   double entryAnchor = isBuy ? psarHigh : psarLow;
   double slAnchor    = isBuy ? psarLow  : psarHigh;

   if(entryAnchor <= 0.0 || slAnchor <= 0.0)
      return;

// Entry price = PSAR swing +/- breakout buffer (% of ATR)
   double buffer = BREAKOUT_BUFFER_ATR * data.atr;
   double entryPrice = isBuy ? (entryAnchor + buffer) : (entryAnchor - buffer);
   NormalizePrice(symbol, entryPrice);

// Asian range is a NO-TRADE zone: BuyStop only ABOVE the range high, SellStop only BELOW the range low
   if(isBuy && entryPrice <= asianRange.high)
      return;
   if(!isBuy && entryPrice >= asianRange.low)
      return;

// A stop pending order must sit far enough from the current market price:
// BuyStop at least the required gap above Ask; SellStop at least the required gap below Bid.
   if(!CheckPendingDistance(isBuy, entryPrice))
      return;

// Structural SL: opposite PSAR swing +/- buffer (% of ADR)
   double slBuffer = SL_BUFFER_PERCENT * data.adr;
   double slPrice  = isBuy ? (slAnchor - slBuffer) : (slAnchor + slBuffer);
   NormalizePrice(symbol, slPrice);

// SL must be on the correct side of the entry
   if(isBuy && slPrice >= entryPrice)
      return;
   if(!isBuy && slPrice <= entryPrice)
      return;

// SL distance is CLAMPED into [MIN_STOP, MAX_STOP] of ADR (does NOT block the trade).
// If the structural SL is too far/too close, the SL price is recomputed from the entry
// at the clamped distance, and the TP is derived from that clamped distance.
   double slDistance = MathAbs(entryPrice - slPrice);
   double minStop    = MIN_STOP_PERCENT * data.adr;
   double maxStop    = MAX_STOP_PERCENT * data.adr;

   double clampedDistance = slDistance;
   if(clampedDistance > maxStop)
      clampedDistance = maxStop;
   if(clampedDistance < minStop)
      clampedDistance = minStop;

// Recompute the SL price from the entry using the clamped distance
   if(clampedDistance != slDistance)
     {
      slPrice = isBuy ? (entryPrice - clampedDistance) : (entryPrice + clampedDistance);
      NormalizePrice(symbol, slPrice);
     }

// Minimum distance vs existing pendings AND positions of the same symbol/magic
   if(!IsFarEnoughFromExisting(symbol, magic, entryPrice, data.adr))
      return;

// TP = clamped SL distance x factor
   double tpDistance = clampedDistance * TAKE_PROFIT_FACTOR;
   double tpPrice    = isBuy ? (entryPrice + tpDistance) : (entryPrice - tpDistance);
   NormalizePrice(symbol, tpPrice);

// Volume from risk
   ENUM_ORDER_TYPE pendingType = isBuy ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
   double lots;
   if(!CalculateVolume(symbol, pendingType, entryPrice, slPrice, lots))
      return;

// Stops level
   if(!CheckStopsLevel(symbol, pendingType, entryPrice, slPrice, tpPrice))
      return;

// Pending orders count limit (account restriction)
   if(!IsNewOrderAllowed())
     {
      Print("<", __FUNCTION__, "> Pending orders limit reached: ", symbol);
      return;
     }

// Margin level
   if(!HasEnoughMargin())
     {
      Print("<", __FUNCTION__, "> Insufficient margin for ", symbol);
      return;
     }

// Sufficient free margin for the new order
   if(!HasSufficientFunds(symbol, pendingType, entryPrice, lots))
     {
      Print("<", __FUNCTION__, "> Insufficient funds for ", symbol);
      return;
     }

// Volume limit: new lots + already open/pending volume of this symbol must not exceed the cap
   if(g_cache.volumeLimit > 0.0)
     {
      double currentVol = GetSymbolVolume(symbol);
      if(lots + currentVol > g_cache.volumeLimit)
        {
         Print("<", __FUNCTION__, "> Volume limit exceeded: ", symbol,
               " | new=", DoubleToString(lots, 2), " current=", DoubleToString(currentVol, 2),
               " limit=", DoubleToString(g_cache.volumeLimit, 2));
         return;
        }
     }

// Send the pending order
   string comment = EA_COMMENT + TimeframeName(tf);
   bool success;
   if(isBuy)
      success = g_trade.BuyStop(lots, entryPrice, symbol, slPrice, tpPrice, ORDER_TIME_GTC, 0, comment);
   else
      success = g_trade.SellStop(lots, entryPrice, symbol, slPrice, tpPrice, ORDER_TIME_GTC, 0, comment);

   if(!success)
     {
      Print("<", __FUNCTION__, "> Pending order failed: ", symbol,
            " | retcode=", g_trade.ResultRetcode(), " | ", g_trade.ResultRetcodeDescription());
      return;
     }

   Print("<", __FUNCTION__, "> Pending ", (isBuy ? "BuyStop" : "SellStop"), " placed: ", symbol,
         " entry=", DoubleToString(entryPrice, (int)g_cache.digits),
         " SL=", DoubleToString(slPrice, (int)g_cache.digits),
         " TP=", DoubleToString(tpPrice, (int)g_cache.digits));
  }
//+====================================================================================================================+
//| MANAGE OPEN POSITIONS - MACD exit + trailing stop + break-even (fixed values)
//+====================================================================================================================+
void ManageOpenPositions(string symbol, int symIndex, ENUM_TIMEFRAMES tf, long magic, const MarketData &data)
  {
   for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != magic)
         continue;

      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl        = PositionGetDouble(POSITION_SL);
      double tp        = PositionGetDouble(POSITION_TP);

      // === MACD reversal exit ===
      bool exitByMACD = false;
      if(posType == POSITION_TYPE_BUY)
        {
         // MACD main crossed below the signal line
         if(data.macdPrev2 > data.macdSignalPrev2 && data.macdPrev < data.macdSignalPrev)
            exitByMACD = true;
        }
      else // POSITION_TYPE_SELL
        {
         if(data.macdPrev2 < data.macdSignalPrev2 && data.macdPrev > data.macdSignalPrev)
            exitByMACD = true;
        }

      if(exitByMACD)
        {
         // Skip if inside the freeze zone (server forbids closing it there); retry on a later tick
         if(IsPositionFrozen(posType, sl, tp))
            continue;
         if(g_trade.PositionClose(ticket))
            Print("<", __FUNCTION__, "> Position closed by MACD signal: ", symbol);
         else
            Print("<", __FUNCTION__, "> Error closing position: ", g_trade.ResultRetcodeDescription());
         continue;
        }

      // === Trailing stop + break-even ===
      if(tp <= 0.0)
         continue;

      if(posType == POSITION_TYPE_BUY)
         UpdateBuyTrailing(ticket, symbol, openPrice, sl, tp);
      else
         UpdateSellTrailing(ticket, symbol, openPrice, sl, tp);
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Update BUY trailing / break-even (fixed percentages)
//+--------------------------------------------------------------------------------------------------------------------+
void UpdateBuyTrailing(ulong ticket, string symbol, double openPrice, double sl, double tp)
  {
   double tpDistance = tp - openPrice;
   double trailLevel = openPrice + tpDistance * (1.0 / TAKE_PROFIT_FACTOR) * TRAILING_START_PERCENT;
   double bid = g_cache.bid;

   if(bid >= trailLevel)
     {
      // Break-even based stop first
      double newSL = bid - tpDistance * (1.0 / TAKE_PROFIT_FACTOR) * BREAKEVEN_PERCENT;
      NormalizePrice(symbol, newSL);

      if(newSL < openPrice)
        {
         newSL = bid - tpDistance * (1.0 / TAKE_PROFIT_FACTOR);
         NormalizePrice(symbol, newSL);
        }

      if(newSL > sl && CheckStopsLevel(symbol, ORDER_TYPE_BUY, openPrice, newSL, tp))
         if(!g_trade.PositionModify(ticket, newSL, tp))
            Print("<", __FUNCTION__, "> PositionModify failed: ", g_trade.ResultRetcodeDescription(), " - ", symbol);
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Update SELL trailing / break-even (fixed percentages)
//+--------------------------------------------------------------------------------------------------------------------+
void UpdateSellTrailing(ulong ticket, string symbol, double openPrice, double sl, double tp)
  {
   double tpDistance = openPrice - tp;
   double trailLevel = openPrice - tpDistance * (1.0 / TAKE_PROFIT_FACTOR) * TRAILING_START_PERCENT;
   double ask = g_cache.ask;

   if(ask <= trailLevel)
     {
      double newSL = ask + tpDistance * (1.0 / TAKE_PROFIT_FACTOR) * BREAKEVEN_PERCENT;
      NormalizePrice(symbol, newSL);

      if(newSL > openPrice)
        {
         newSL = ask + tpDistance * (1.0 / TAKE_PROFIT_FACTOR);
         NormalizePrice(symbol, newSL);
        }

      if(newSL > 0.0 && (newSL < sl || sl == 0.0) && CheckStopsLevel(symbol, ORDER_TYPE_SELL, openPrice, newSL, tp))
         if(!g_trade.PositionModify(ticket, newSL, tp))
            Print("<", __FUNCTION__, "> PositionModify failed: ", g_trade.ResultRetcodeDescription(), " - ", symbol);
     }
  }
//+====================================================================================================================+
//| CANCEL PENDING ORDERS - only pendings of this symbol/magic (open positions remain)
//+====================================================================================================================+
void CancelPendingOrders(string symbol, long magic)
  {
   for(int i = OrdersTotal() - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != symbol)
         continue;
      if(OrderGetInteger(ORDER_MAGIC) != magic)
         continue;

      ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(type != ORDER_TYPE_BUY_STOP && type != ORDER_TYPE_SELL_STOP &&
         type != ORDER_TYPE_BUY_LIMIT && type != ORDER_TYPE_SELL_LIMIT)
         continue;

      // Skip if the pending is inside the freeze zone (server forbids delete/modify there)
      double triggerPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      if(IsPendingFrozen(triggerPrice))
         continue;

      if(!g_trade.OrderDelete(ticket))
         Print("<", __FUNCTION__, "> OrderDelete failed: ", g_trade.ResultRetcodeDescription(), " - ", symbol);
     }
  }
//+====================================================================================================================+
//| CLOSE ALL POSITIONS of a symbol/magic
//+====================================================================================================================+
void CloseSymbolPositions(string symbol, long magic, int reason)
  {
   string reasonStr;
   switch(reason)
     {
      case CLOSE_REASON_PROFIT:
         reasonStr = "Daily profit target reached";
         break;
      case CLOSE_REASON_LOSS:
         reasonStr = "Daily loss limit reached";
         break;
      case CLOSE_REASON_END_SESSION:
         reasonStr = "End of trading session";
         break;
      default:
         reasonStr = "Unknown";
         break;
     }

   for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != magic)
         continue;

      // Skip if the position is inside the freeze zone (server forbids closing it there)
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double posSL = PositionGetDouble(POSITION_SL);
      double posTP = PositionGetDouble(POSITION_TP);
      if(IsPositionFrozen(posType, posSL, posTP))
         continue;

      if(g_trade.PositionClose(ticket))
         Print("<", __FUNCTION__, "> Position closed: ", reasonStr, " - ", symbol);
     }
  }
//+====================================================================================================================+
//| DISTANCE FILTER - checks pendings AND positions of the same symbol/magic
//+====================================================================================================================+
bool IsFarEnoughFromExisting(string symbol, long magic, double newPrice, double adr)
  {
   double minDistance = DISTANCE_PERCENT * adr;
   if(minDistance <= 0.0)
      return true;

// Check open positions
   for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue;
      if(PositionGetInteger(POSITION_MAGIC) != magic)
         continue;

      double refPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      if(MathAbs(newPrice - refPrice) < minDistance)
        {
         Print("<", __FUNCTION__, "> New order too close to existing position: ", symbol);
         return false;
        }
     }

// Check pending orders
   for(int i = OrdersTotal() - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != symbol)
         continue;
      if(OrderGetInteger(ORDER_MAGIC) != magic)
         continue;

      double refPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      if(MathAbs(newPrice - refPrice) < minDistance)
        {
         Print("<", __FUNCTION__, "> New order too close to existing pending: ", symbol);
         return false;
        }
     }

   return true;
  }
//+====================================================================================================================+
//| DAYLIGHT SAVING TIME (London / New York)
//+====================================================================================================================+
bool IsLondonDST(datetime now)
  {
   MqlDateTime dt;
   if(!TimeToStruct(now, dt))
      return false;

   datetime dstStart = LastSundayOfMonth(dt.year, 3) + 3600;
   datetime dstEnd   = LastSundayOfMonth(dt.year, 10) + 3600;

   return (now >= dstStart && now < dstEnd);
  }
//+--------------------------------------------------------------------------------------------------------------------+
bool IsNewYorkDST(datetime now)
  {
   MqlDateTime dt;
   if(!TimeToStruct(now, dt))
      return false;

   datetime dstStart = NthSundayOfMonth(dt.year, 3, 2) + 2 * 3600;
   datetime dstEnd   = NthSundayOfMonth(dt.year, 11, 1) + 2 * 3600;

   return (now >= dstStart && now < dstEnd);
  }
//+--------------------------------------------------------------------------------------------------------------------+
datetime LastSundayOfMonth(int year, int month)
  {
   int nextMonth = (month == 12) ? 1 : month + 1;
   int nextYear  = (month == 12) ? year + 1 : year;

   MqlDateTime dt;
   dt.year = nextYear;
   dt.mon  = nextMonth;
   dt.day  = 1;
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;

   datetime firstOfNext = StructToTime(dt);
   datetime lastDay = firstOfNext - 86400;
   if(!TimeToStruct(lastDay, dt))
      return 0;

   while(dt.day_of_week != 0)
     {
      lastDay -= 86400;
      if(!TimeToStruct(lastDay, dt))
         return 0;
     }

   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;
   return StructToTime(dt);
  }
//+--------------------------------------------------------------------------------------------------------------------+
datetime NthSundayOfMonth(int year, int month, int n)
  {
   MqlDateTime dt;
   dt.year = year;
   dt.mon  = month;
   dt.day  = 1;
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;

   datetime firstDay = StructToTime(dt);
   if(!TimeToStruct(firstDay, dt))
      return 0;

   int daysToSunday = (7 - dt.day_of_week) % 7;
   datetime firstSunday = firstDay + daysToSunday * 86400;
   return firstSunday + (n - 1) * 7 * 86400;
  }
//+====================================================================================================================+
//| TRADING SESSION TIMES (server GMT offset is manual)
//+====================================================================================================================+
int GetServerGMTOffset()
  {
   return InpServerGMTOffset * 3600;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| London open in GMT, adjusted for DST. Base: 08:00 GMT (winter) / 07:00 GMT (summer)
//+--------------------------------------------------------------------------------------------------------------------+
int GetLondonStartHourGMT(datetime now)
  {
   const int baseHour = 8;
   if(!IsLondonDST(now))
      return baseHour;
   if(InpServerDST == DST_EUROPE)
      return baseHour;
   return baseHour - 1;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| London close in GMT, adjusted for DST. Base: 16:00 GMT (winter) / 15:00 GMT (summer)
//+--------------------------------------------------------------------------------------------------------------------+
int GetLondonEndHourGMT(datetime now)
  {
   const int baseHour = 16;
   if(!IsLondonDST(now))
      return baseHour;
   if(InpServerDST == DST_EUROPE)
      return baseHour;
   return baseHour - 1;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| New York close in GMT, adjusted for DST. Base: 22:00 GMT (winter) / 21:00 GMT (summer)
//+--------------------------------------------------------------------------------------------------------------------+
int GetTradingEndHourGMT(datetime now)
  {
   const int baseHour = 22;
   if(!IsNewYorkDST(now))
      return baseHour;
   if(InpServerDST == DST_USA)
      return baseHour;
   return baseHour - 1;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Server-time timestamp for a given GMT hour of the current GMT day
//+--------------------------------------------------------------------------------------------------------------------+
datetime GetServerTimeForGMTHour(int hourGMT)
  {
   datetime now = TimeCurrent();
   int serverOffset = GetServerGMTOffset();

   datetime nowGMT = now - serverOffset;
   MqlDateTime dtGMT;
   if(!TimeToStruct(nowGMT, dtGMT))
      return 0;

   dtGMT.hour = hourGMT;
   dtGMT.min  = 0;
   dtGMT.sec  = 0;
   datetime timestampGMT = StructToTime(dtGMT);

   return timestampGMT + serverOffset;
  }
//+--------------------------------------------------------------------------------------------------------------------+
datetime GetLondonStartTime()
  {
   return GetServerTimeForGMTHour(GetLondonStartHourGMT(TimeCurrent()));
  }
//+--------------------------------------------------------------------------------------------------------------------+
datetime GetLondonEndTime()
  {
   return GetServerTimeForGMTHour(GetLondonEndHourGMT(TimeCurrent()));
  }
//+--------------------------------------------------------------------------------------------------------------------+
datetime GetTradingEndTime()
  {
   return GetServerTimeForGMTHour(GetTradingEndHourGMT(TimeCurrent()));
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Placement window: pending orders may be placed from London open until London close
//+--------------------------------------------------------------------------------------------------------------------+
bool IsWithinPlacementWindow()
  {
   datetime now = TimeCurrent();
   return (now >= GetLondonStartTime() && now < GetLondonEndTime());
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| After trading hours: at/after the New York close
//+--------------------------------------------------------------------------------------------------------------------+
bool IsAfterTradingHours()
  {
   return (TimeCurrent() >= GetTradingEndTime());
  }
//+====================================================================================================================+
//| SYMBOL SESSION CLOSE (symbol's own broker session)
//+====================================================================================================================+
bool IsNearSymbolSessionClose(string symbol, datetime now)
  {
   datetime sessionStart = 0, sessionEnd = 0;
   bool sessionExists = true;
   int sessionIndex = 0;
   MqlDateTime dt;

   if(!TimeToStruct(now, dt))
      return false;

   int dow = dt.day_of_week;
   datetime dayStart = (datetime)(PeriodSeconds(PERIOD_D1) * (now / PeriodSeconds(PERIOD_D1)));

   while(sessionExists && sessionIndex < 10 && !IsStopped())
     {
      sessionExists = SymbolInfoSessionTrade(symbol, (ENUM_DAY_OF_WEEK)dow, sessionIndex, sessionStart, sessionEnd);
      if(sessionExists)
        {
         datetime start = dayStart + sessionStart;
         datetime end   = dayStart + sessionEnd;
         if(now >= start && now < end)
           {
            if(now >= end - CLOSE_BEFORE_SESSION)
               return true;
            return false;
           }
        }
      sessionIndex++;
     }

   return false;
  }
//+====================================================================================================================+
//| DAILY LIMITS
//+====================================================================================================================+
int CheckDailyLimits(string symbol)
  {
   if(InpDailyProfit <= 0.0 && InpDailyLoss <= 0.0)
      return CLOSE_REASON_NONE;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_CREDIT);

// Closed result today
   double closedResult = 0.0;
   datetime dayStart = iTime(symbol, PERIOD_D1, 0);
   if(HistorySelect(dayStart, TimeCurrent()))
     {
      int deals = HistoryDealsTotal();
      for(int i = 0; i < deals && !IsStopped(); i++)
        {
         ulong dealTicket = HistoryDealGetTicket(i);
         if(dealTicket == 0)
            continue;
         if(IsMagicValid(HistoryDealGetInteger(dealTicket, DEAL_MAGIC)))
            closedResult += HistoryDealGetDouble(dealTicket, DEAL_PROFIT) +
                            HistoryDealGetDouble(dealTicket, DEAL_SWAP) +
                            HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
        }
     }

   double dailyDeposit = balance - closedResult;
   if(dailyDeposit <= 0.0)
      return CLOSE_REASON_NONE;

// Open result
   double openResult = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(IsMagicValid(PositionGetInteger(POSITION_MAGIC)))
         openResult += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
     }

   if(InpDailyProfit > 0.0)
     {
      double profitPercent = ((closedResult + openResult) / dailyDeposit) * 100.0;
      if(profitPercent >= InpDailyProfit)
         return CLOSE_REASON_PROFIT;
     }

   if(InpDailyLoss > 0.0)
     {
      double totalLoss = closedResult + openResult;
      double lossPercent = (MathAbs(totalLoss < 0.0 ? totalLoss : 0.0) / dailyDeposit) * 100.0;
      if(lossPercent >= InpDailyLoss)
         return CLOSE_REASON_LOSS;
     }

   return CLOSE_REASON_NONE;
  }
//+====================================================================================================================+
//| SYMBOL INITIALIZATION
//+====================================================================================================================+
bool InitializeSymbols()
  {
   ArrayFree(g_symbols);
   g_symbolCount = 0;

   string symbolList = InpSymbolList;

   if(StringLen(symbolList) > 0)
     {
      string symbols[];
      int count = StringSplit(symbolList, ',', symbols);

      if(count < 0)
        {
         Print("<", __FUNCTION__, "> Error splitting symbol list");
         return false;
        }

      for(int i = 0; i < count && !IsStopped(); i++)
        {
         string sym = TrimString(symbols[i]);
         if(StringLen(sym) == 0)
            continue;

         if(!AddSymbol(sym))
            continue;

         if(g_symbolCount >= MAX_SYMBOLS)
           {
            Print("<", __FUNCTION__, "> Max symbols reached: ", MAX_SYMBOLS);
            break;
           }
        }
      ArrayFree(symbols);
     }

// Fallback: current symbol
   if(g_symbolCount == 0)
     {
      Print("<", __FUNCTION__, "> Using current symbol as fallback");
      if(!AddSymbol(_Symbol))
        {
         Print("<", __FUNCTION__, "> Failed to add current symbol");
         return false;
        }
     }

   Print("<", __FUNCTION__, "> Initialized with ", g_symbolCount, " symbols");
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Add a symbol to the array
//+--------------------------------------------------------------------------------------------------------------------+
bool AddSymbol(string symbol)
  {
   if(!ValidateSymbol(symbol))
     {
      Print("<", __FUNCTION__, "> Symbol not available: ", symbol);
      return false;
     }

// Duplicates
   for(int i = 0; i < g_symbolCount; i++)
      if(g_symbols[i].symbol == symbol)
        {
         Print("<", __FUNCTION__, "> Duplicate ignored: ", symbol);
         return false;
        }

   ArrayResize(g_symbols, g_symbolCount + 1);
   g_symbols[g_symbolCount].symbol = symbol;

   int    adrPeriod        = DEFAULT_ADR_PERIOD;
   int    periodH1         = DEFAULT_PERIOD_H1;
   double stepSAR          = DEFAULT_STEP_SAR;
   int    macdSignalH1     = DEFAULT_MACD_SIGNAL_H1;
   int    asianRangeBarsH1 = DEFAULT_ASIAN_RANGE_BARS_H1;

   LookupSymbolParams(symbol, adrPeriod, periodH1, stepSAR, macdSignalH1, asianRangeBarsH1);

   g_symbols[g_symbolCount].adrPeriod        = adrPeriod;
   g_symbols[g_symbolCount].periodH1         = periodH1;
   g_symbols[g_symbolCount].stepSAR          = stepSAR;
   g_symbols[g_symbolCount].macdSignalH1     = macdSignalH1;
   g_symbols[g_symbolCount].asianRangeBarsH1 = asianRangeBarsH1;

   Print("<", __FUNCTION__, "> Added: ", symbol,
         " | adrPeriod=", adrPeriod, " | periodH1=", periodH1, " | stepSAR=", DoubleToString(stepSAR, 3),
         " | macdSignalH1=", macdSignalH1, " | asianBarsH1=", asianRangeBarsH1);

   g_symbolCount++;
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Lookup predefined parameters for a symbol
//+--------------------------------------------------------------------------------------------------------------------+
void LookupSymbolParams(string symbol, int &adrPeriod, int &periodH1, double &stepSAR, int &macdSignalH1, int &asianRangeBarsH1)
  {
   string upperSymbol = symbol;
   StringToUpper(upperSymbol);

   int tableSize = ArraySize(g_symbolParamsTable);
   for(int i = 0; i < tableSize; i++)
     {
      if(StringFind(upperSymbol, g_symbolParamsTable[i].pattern) >= 0)
        {
         adrPeriod        = g_symbolParamsTable[i].adrPeriod;
         periodH1         = g_symbolParamsTable[i].periodH1;
         stepSAR          = g_symbolParamsTable[i].stepSAR;
         macdSignalH1     = g_symbolParamsTable[i].macdSignalH1;
         asianRangeBarsH1 = g_symbolParamsTable[i].asianRangeBarsH1;
         return;
        }
     }

   adrPeriod        = DEFAULT_ADR_PERIOD;
   periodH1         = DEFAULT_PERIOD_H1;
   stepSAR          = DEFAULT_STEP_SAR;
   macdSignalH1     = DEFAULT_MACD_SIGNAL_H1;
   asianRangeBarsH1 = DEFAULT_ASIAN_RANGE_BARS_H1;
  }
//+====================================================================================================================+
//| INDICATOR HANDLES
//+====================================================================================================================+
bool InitializeAllIndicators()
  {
// Initialize all handles as invalid
   for(int s = 0; s < MAX_SYMBOLS; s++)
     {
      g_handleADR[s]     = INVALID_HANDLE;
      g_handleADRfast[s] = INVALID_HANDLE;
      for(int t = 0; t < TF_INDEX_COUNT; t++)
        {
         g_handleATR[s][t]        = INVALID_HANDLE;
         g_handleATRfast[s][t]    = INVALID_HANDLE;
         g_handleStochastic[s][t] = INVALID_HANDLE;
         g_handlePSAR[s][t]       = INVALID_HANDLE;
         g_handleMACD[s][t]       = INVALID_HANDLE;
        }
     }

   for(int symIndex = 0; symIndex < g_symbolCount; symIndex++)
     {
      string symbol  = g_symbols[symIndex].symbol;
      double stepSAR = g_symbols[symIndex].stepSAR;

      // ADR on D1 (single fixed period) + 1-period ADR for ATR variation
      g_handleADR[symIndex]     = iATR(symbol, PERIOD_D1, g_symbols[symIndex].adrPeriod);
      g_handleADRfast[symIndex] = iATR(symbol, PERIOD_D1, 1);
      if(g_handleADR[symIndex] == INVALID_HANDLE || g_handleADRfast[symIndex] == INVALID_HANDLE)
        {
         Print("<", __FUNCTION__, "> ADR handle failed: ", symbol);
         return false;
        }

      for(int tfIndex = 0; tfIndex < TF_INDEX_COUNT; tfIndex++)
        {
         ENUM_TIMEFRAMES tf = IndexToTimeframe(tfIndex);
         int tradingPeriod  = GetTradingPeriod(symbol, tf, symIndex, tfIndex);
         if(tradingPeriod <= 0)
           {
            Print("<", __FUNCTION__, "> Invalid trading period: ", symbol, " ", TimeframeName(tf));
            return false;
           }

         // ATR on trading TF (adrPeriod x tradingPeriod) + fast ATR (tradingPeriod) for variation
         g_handleATR[symIndex][tfIndex]     = iATR(symbol, tf, g_symbols[symIndex].adrPeriod * tradingPeriod);
         g_handleATRfast[symIndex][tfIndex] = iATR(symbol, tf, tradingPeriod);
         if(g_handleATR[symIndex][tfIndex] == INVALID_HANDLE || g_handleATRfast[symIndex][tfIndex] == INVALID_HANDLE)
           {
            Print("<", __FUNCTION__, "> ATR handle failed: ", symbol, " ", TimeframeName(tf));
            return false;
           }

         // Stochastic (period derived from tradingPeriod)
         int stoPeriod = (int)MathRound(tradingPeriod * STOCHASTIC_FACTOR);
         if(stoPeriod < 1)
            stoPeriod = 1;
         g_handleStochastic[symIndex][tfIndex] = iStochastic(symbol, tf, tradingPeriod, stoPeriod, stoPeriod,
                                                 MODE_SMA, STO_CLOSECLOSE);
         if(g_handleStochastic[symIndex][tfIndex] == INVALID_HANDLE)
           {
            Print("<", __FUNCTION__, "> Stochastic handle failed: ", symbol, " ", TimeframeName(tf));
            return false;
           }

         // PSAR (step per symbol)
         g_handlePSAR[symIndex][tfIndex] = iSAR(symbol, tf, stepSAR, PSAR_MAX);
         if(g_handlePSAR[symIndex][tfIndex] == INVALID_HANDLE)
           {
            Print("<", __FUNCTION__, "> PSAR handle failed: ", symbol, " ", TimeframeName(tf));
            return false;
           }

         // MACD (signal per symbol in hours, converted to the TF; fast/slow derived from signal)
         int macdSignalConv = ConvertHoursToBars(g_symbols[symIndex].macdSignalH1, tf);
         if(macdSignalConv < 1)
            macdSignalConv = 1;
         int macdFast = (int)MathRound(macdSignalConv * MACD_FAST_FACTOR);
         int macdSlow = (int)MathRound(macdSignalConv * MACD_SLOW_FACTOR);
         if(macdFast < 1)
            macdFast = 1;
         if(macdSlow <= macdFast)
            macdSlow = macdFast + 1;

         g_handleMACD[symIndex][tfIndex] = iMACD(symbol, tf, macdFast, macdSlow, macdSignalConv, PRICE_CLOSE);
         if(g_handleMACD[symIndex][tfIndex] == INVALID_HANDLE)
           {
            Print("<", __FUNCTION__, "> MACD handle failed: ", symbol, " ", TimeframeName(tf));
            return false;
           }
        }
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
void ReleaseAllIndicators()
  {
   for(int s = 0; s < MAX_SYMBOLS; s++)
     {
      SafeReleaseHandle(g_handleADR[s]);
      SafeReleaseHandle(g_handleADRfast[s]);
      for(int t = 0; t < TF_INDEX_COUNT; t++)
        {
         SafeReleaseHandle(g_handleATR[s][t]);
         SafeReleaseHandle(g_handleATRfast[s][t]);
         SafeReleaseHandle(g_handleStochastic[s][t]);
         SafeReleaseHandle(g_handlePSAR[s][t]);
         SafeReleaseHandle(g_handleMACD[s][t]);
        }
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
void SafeReleaseHandle(int &handle)
  {
   if(handle != INVALID_HANDLE)
     {
      IndicatorRelease(handle);
      handle = INVALID_HANDLE;
     }
  }
//+====================================================================================================================+
//| TRADING PERIOD (bars), dynamic or derived from periodH1 (hours) for the timeframe
//+====================================================================================================================+
int GetTradingPeriod(string symbol, ENUM_TIMEFRAMES tf, int symIndex, int tfIndex)
  {
   int calculated;

   if(symIndex >= 0 && symIndex < g_symbolCount && g_symbols[symIndex].periodH1 > 0)
     {
      calculated = ConvertHoursToBars(g_symbols[symIndex].periodH1, tf);
     }
   else
     {
      // Dynamic period
      calculated = CalcTradingPeriod(symbol, tf, TimeCurrent());
      if(calculated <= 0)
         return 0;
     }

// Clamp into a sane range per timeframe
   int minPeriod = g_minIndPeriods[tfIndex];
   int maxPeriod = g_maxIndPeriods[tfIndex];

   return MathMin(maxPeriod, MathMax(minPeriod, calculated));
  }
//+--------------------------------------------------------------------------------------------------------------------+
int CalcTradingPeriod(string symbol, ENUM_TIMEFRAMES tf, datetime now)
  {
   datetime sessionStart = 0, sessionEnd = 0;
   double tradingPeriod = 0.0;
   bool sessionExists = true;
   uint sessionIndex = 0;
   MqlDateTime dt;

   if(!TimeToStruct(now, dt))
     {
      Print("<", __FUNCTION__, "> Error converting time: ", symbol);
      return 0;
     }

   ENUM_DAY_OF_WEEK dow = (ENUM_DAY_OF_WEEK)dt.day_of_week;
   if(dow == SATURDAY)
      dow = FRIDAY;
   if(dow == SUNDAY)
      dow = MONDAY;

   while(sessionExists && sessionIndex < 10 && !IsStopped())
     {
      sessionExists = SymbolInfoSessionTrade(symbol, dow, sessionIndex, sessionStart, sessionEnd);
      if(sessionExists)
         tradingPeriod += MathCeil((sessionEnd - sessionStart) / (double)PeriodSeconds(tf));
      sessionIndex++;
     }

   return (int)tradingPeriod;
  }
//+====================================================================================================================+
//| SYMBOL CACHE
//+====================================================================================================================+
bool UpdateSymbolCache(string symbol)
  {
   g_cache.symbol  = symbol;
   g_cache.isValid = false;

   if(!SymbolInfoDouble(symbol, SYMBOL_POINT, g_cache.point) || g_cache.point == 0.0)
      return false;

   SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE, g_cache.tickSize);
   SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE, g_cache.tickValue);
   SymbolInfoDouble(symbol, SYMBOL_BID, g_cache.bid);
   SymbolInfoDouble(symbol, SYMBOL_ASK, g_cache.ask);
   g_cache.spread     = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN, g_cache.volumeMin);
   SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX, g_cache.volumeMax);
   SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP, g_cache.volumeStep);
   SymbolInfoDouble(symbol, SYMBOL_VOLUME_LIMIT, g_cache.volumeLimit);
   g_cache.stopsLevel = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   g_cache.freezeLevel = SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   g_cache.digits     = SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   if(g_cache.volumeMin == 0.0 || g_cache.bid == 0.0)
      return false;

   g_cache.isValid = true;
   return true;
  }
//+====================================================================================================================+
//| VOLUME & MARGIN
//+====================================================================================================================+
bool CalculateVolume(string symbol, ENUM_ORDER_TYPE type, double price, double sl, double &lots)
  {
   lots = 0.0;

   if(InpRiskMode != RISK_MODE_FIXED_LOT)
     {
      if(sl == 0.0)
        {
         Print("<", __FUNCTION__, "> ERROR: Stop Loss is zero - ", symbol);
         return false;
        }
      if(MathAbs(price - sl) < 10 * g_cache.point)
        {
         Print("<", __FUNCTION__, "> ERROR: Stop Loss too close - ", symbol);
         return false;
        }
     }

// Fixed lot
   if(InpRiskMode == RISK_MODE_FIXED_LOT)
     {
      lots = MathFloor(InpRiskSize / g_cache.volumeStep) * g_cache.volumeStep;
      lots = NormalizeDouble(lots, 2);
      if(lots < g_cache.volumeMin || lots > g_cache.volumeMax)
        {
         Print("<", __FUNCTION__, "> ERROR: Fixed lot out of bounds - ", symbol);
         return false;
        }
      return true;
     }

// Risk-based modes
   double balance = AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_CREDIT);
   if(balance <= 0.0)
      return false;

// Loss for 1 lot (native OrderCalcProfit). Entry/exit ordered to produce a loss.
   ENUM_ORDER_TYPE marketType = (type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double profit = 0.0;
   if(!OrderCalcProfit(marketType, symbol, 1.0, price, sl, profit))
     {
      Print("<", __FUNCTION__, "> ERROR: OrderCalcProfit failed - ", symbol);
      return false;
     }
   double lossPerLot = MathAbs(profit);
   if(lossPerLot < 0.01)
     {
      Print("<", __FUNCTION__, "> CRITICAL: invalid loss-per-lot - ", symbol);
      return false;
     }

   double maxLoss = (InpRiskMode == RISK_MODE_PERCENTAGE) ? (balance * InpRiskSize / 100.0) : InpRiskSize;
   if(maxLoss <= 0.0)
      return false;

   double lotsRaw = maxLoss / lossPerLot;
   lots = MathFloor(lotsRaw / g_cache.volumeStep) * g_cache.volumeStep;
   lots = NormalizeDouble(lots, 2);

   if(lots < g_cache.volumeMin)
     {
      if(!MQLInfoInteger(MQL_TESTER))
        {
         Print("<", __FUNCTION__, "> ERROR: Calculated lot < minimum (risk too small) - ", symbol);
         return false;
        }
      lots = g_cache.volumeMin;
     }
   if(lots > g_cache.volumeMax)
     {
      Print("<", __FUNCTION__, "> ERROR: Calculated lot > maximum - ", symbol);
      return false;
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
bool HasEnoughMargin()
  {
   double margin = AccountInfoDouble(ACCOUNT_MARGIN);
   if(margin == 0.0)
      return true;

   long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
   double minLevel = MathMax(MIN_MARGIN_LEVEL, (double)leverage);
   double level = (AccountInfoDouble(ACCOUNT_EQUITY) / margin) * 100.0;

   if(level < minLevel)
     {
      Print("<", __FUNCTION__, "> Margin level too low: ", DoubleToString(level, 2), "%");
      return false;
     }
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Total volume (positions + pending orders) of a symbol
//+--------------------------------------------------------------------------------------------------------------------+
double GetSymbolVolume(string symbol)
  {
   double total = 0.0;

// Open positions
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) == symbol)
         total += PositionGetDouble(POSITION_VOLUME);
     }

// Pending orders
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(OrderGetString(ORDER_SYMBOL) == symbol)
         total += OrderGetDouble(ORDER_VOLUME_CURRENT);
     }

   return total;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Check there is enough free margin for the new order, accounting for the margin that ALREADY-PLACED
//| pending orders will require when triggered.
//+--------------------------------------------------------------------------------------------------------------------+
bool HasSufficientFunds(string symbol, ENUM_ORDER_TYPE type, double price, double lots)
  {
   ENUM_ORDER_TYPE marketType = (type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

// Margin required by the new order
   double newMargin = 0.0;
   if(!OrderCalcMargin(marketType, symbol, lots, price, newMargin))
     {
      Print("<", __FUNCTION__, "> Error calculating margin: ", symbol);
      return false;
     }

// Margin already committed by existing pending orders (they will consume margin when triggered)
   double pendingMargin = PendingOrdersMargin();

// Require the combined margin to fit within the free margin, keeping a small safety buffer
   double required = (newMargin + pendingMargin) * (1.0 + MARGIN_SAFETY_BUFFER);

   return (required <= freeMargin);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Estimated margin required by all pending orders if they were triggered now
//+--------------------------------------------------------------------------------------------------------------------+
double PendingOrdersMargin()
  {
   double total = 0.0;

   for(int i = OrdersTotal() - 1; i >= 0 && !IsStopped(); i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0)
         continue;

      string orderSymbol = OrderGetString(ORDER_SYMBOL);
      ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      double olots = OrderGetDouble(ORDER_VOLUME_CURRENT);
      double oprice = OrderGetDouble(ORDER_PRICE_OPEN);

      ENUM_ORDER_TYPE marketType;
      if(otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_BUY_LIMIT)
         marketType = ORDER_TYPE_BUY;
      else
         if(otype == ORDER_TYPE_SELL_STOP || otype == ORDER_TYPE_SELL_LIMIT)
            marketType = ORDER_TYPE_SELL;
         else
            continue;   // skip market positions here

      double m = 0.0;
      if(OrderCalcMargin(marketType, orderSymbol, olots, oprice, m))
         total += m;
     }

   return total;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Check whether another pending order can be placed (account ACCOUNT_LIMIT_ORDERS restriction)
//+--------------------------------------------------------------------------------------------------------------------+
bool IsNewOrderAllowed()
  {
   int maxAllowedOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   if(maxAllowedOrders == 0)
      return true;   // no restriction

   return (OrdersTotal() < maxAllowedOrders);
  }
//+====================================================================================================================+
//| PRICE / STOPS HELPERS
//+====================================================================================================================+
void NormalizePrice(string symbol, double &price)
  {
   if(g_cache.tickSize == 0.0)
      price = NormalizeDouble(price, (int)g_cache.digits);
   else
      price = NormalizeDouble(MathRound(price / g_cache.tickSize) * g_cache.tickSize, (int)g_cache.digits);
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Validate stops level. For pending stop orders, the reference is the pending entry price.
//+--------------------------------------------------------------------------------------------------------------------+
bool CheckStopsLevel(string symbol, ENUM_ORDER_TYPE type, double price, double sl, double tp)
  {
   if(g_cache.stopsLevel == 0)
      return true;

   double minDistance = g_cache.stopsLevel * g_cache.point;
   bool isBuySide = (type == ORDER_TYPE_BUY || type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_LIMIT);

   if(isBuySide)
     {
      if(price - sl <= minDistance)
         return false;
      if(tp - price <= minDistance)
         return false;
     }
   else
     {
      if(sl - price <= minDistance)
         return false;
      if(price - tp <= minDistance)
         return false;
     }
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Validate the distance between a STOP pending entry and the current market price.
//| MT5 rejects (Invalid price) a BuyStop too close to/below Ask, or a SellStop too close to/above Bid.
//| Required gap = the largest of stops_level, freeze_level and the current spread (with a 1-point floor),
//| which also covers servers (e.g. MetaQuotes-Demo) where stops/freeze levels are reported as zero.
//+--------------------------------------------------------------------------------------------------------------------+
bool CheckPendingDistance(bool isBuy, double entryPrice)
  {
   long levelPoints = g_cache.stopsLevel;
   if(g_cache.freezeLevel > levelPoints)
      levelPoints = g_cache.freezeLevel;
   if(g_cache.spread > levelPoints)
      levelPoints = g_cache.spread;
   if(levelPoints < 1)
      levelPoints = 1;   // floor: at least 1 point away from market

   double minGap = (double)levelPoints * g_cache.point;

   if(isBuy)
     {
      // BuyStop must be above Ask by at least minGap
      if(entryPrice - g_cache.ask <= minGap)
         return false;
     }
   else
     {
      // SellStop must be below Bid by at least minGap
      if(g_cache.bid - entryPrice <= minGap)
         return false;
     }
   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Freeze zone for an OPEN POSITION. Inside the freeze level the server forbids closing/modifying it,
//| because price is too close to the position SL or TP. Returns true when the operation must be skipped.
//+--------------------------------------------------------------------------------------------------------------------+
bool IsPositionFrozen(ENUM_POSITION_TYPE posType, double sl, double tp)
  {
   if(g_cache.freezeLevel <= 0)
      return false;

   double freezeGap = (double)g_cache.freezeLevel * g_cache.point;

   if(posType == POSITION_TYPE_BUY)
     {
      // Closing a BUY happens at Bid
      if(tp > 0.0 && MathAbs(tp - g_cache.bid) <= freezeGap)
         return true;
      if(sl > 0.0 && MathAbs(g_cache.bid - sl) <= freezeGap)
         return true;
     }
   else
     {
      // Closing a SELL happens at Ask
      if(tp > 0.0 && MathAbs(g_cache.ask - tp) <= freezeGap)
         return true;
      if(sl > 0.0 && MathAbs(sl - g_cache.ask) <= freezeGap)
         return true;
     }
   return false;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Freeze zone for a PENDING ORDER. Inside the freeze level the server forbids deleting/modifying it,
//| because price is too close to the trigger price. Returns true when the operation must be skipped.
//+--------------------------------------------------------------------------------------------------------------------+
bool IsPendingFrozen(double triggerPrice)
  {
   if(g_cache.freezeLevel <= 0)
      return false;

   double freezeGap = (double)g_cache.freezeLevel * g_cache.point;
   double distance  = MathMin(MathAbs(triggerPrice - g_cache.ask), MathAbs(triggerPrice - g_cache.bid));
   return (distance <= freezeGap);
  }
//+====================================================================================================================+
//| SYMBOL VALIDATION
//+====================================================================================================================+
bool ValidateSymbol(string symbol)
  {
// Existence gate: if the name is not offered by the server,
// reject it WITHOUT calling any data/trade function on it.
   if(!SymbolExistsOnServer(symbol))
     {
      Print("<", __FUNCTION__, "> Symbol not on server (ignored): ", symbol);
      return false;
     }
// The symbol exists -> now it is safe to select it and confirm data.
   if(!SymbolSelect(symbol, true))
     {
      Print("<", __FUNCTION__, "> Could not select symbol: ", symbol);
      return false;
     }
   double rates[1];
// Note: '<=' on purpose -> also validates D1 (TF_INDEX_COUNT -> PERIOD_D1)
   for(int i = 0; i <= TF_INDEX_COUNT; i++)
     {
      ENUM_TIMEFRAMES tf = IndexToTimeframe(i);
      if(CopyClose(symbol, tf, 0, 1, rates) > -1)
         return true;
      Sleep(100);
     }
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   if(bid > 0.0)
      return true;
   Print("<", __FUNCTION__, "> Symbol has no data yet: ", symbol);
   return false;
  }
//+--------------------------------------------------------------------------------------------------------------------+
bool SymbolExistsOnServer(string symbol)
  {
   int total = SymbolsTotal(false);
   for(int i = 0; i < total && !IsStopped(); i++)
     {
      if(SymbolName(i, false) == symbol)
         return true;
     }
   return false;
  }
//+--------------------------------------------------------------------------------------------------------------------+
bool IsSymbolAvailable(string symbol)
  {
   datetime expiration = (datetime)SymbolInfoInteger(symbol, SYMBOL_EXPIRATION_TIME);
   return (expiration == 0 || TimeCurrent() < expiration);
  }
//+--------------------------------------------------------------------------------------------------------------------+
string TrimString(const string str)
  {
   string result = "";
   int len = StringLen(str);
   for(int i = 0; i < len && !IsStopped(); i++)
     {
      ushort ch = StringGetCharacter(str, i);
      if(ch != ' ' && ch != '\t' && ch != '\r' && ch != '\n')
         result += CharToString((uchar)ch);
     }
   return result;
  }
//+--------------------------------------------------------------------------------------------------------------------+
//| Trading-hours check (symbol broker sessions)
//+--------------------------------------------------------------------------------------------------------------------+
bool IsWithinTradingHours(string symbol, datetime now)
  {
   datetime sessionStart = 0, sessionEnd = 0;
   bool sessionExists = true;
   int sessionIndex = 0;
   MqlDateTime dt;

   if(!TimeToStruct(now, dt))
      return false;

   datetime dayStart = (datetime)(PeriodSeconds(PERIOD_D1) * (now / PeriodSeconds(PERIOD_D1)));

   while(sessionExists && sessionIndex < 10 && !IsStopped())
     {
      sessionExists = SymbolInfoSessionTrade(symbol, (ENUM_DAY_OF_WEEK)dt.day_of_week, sessionIndex, sessionStart, sessionEnd);
      if(sessionExists)
        {
         datetime start = dayStart + sessionStart;
         datetime end   = dayStart + sessionEnd;
         if(start == end)
            return true;
         if(now >= start && now < end)
            return true;
        }
      sessionIndex++;
     }

   return false;
  }
//+====================================================================================================================+
//| HISTORICAL DATA
//+====================================================================================================================+
bool CheckHistoricalData(string symbol, ENUM_TIMEFRAMES tf, int barsRequired, int adrPeriod)
  {
   int available = iBars(symbol, tf);
   if(available >= barsRequired)
      return true;

// Add 5 extra days for safety (reduced trading-hour days)
   datetime startDate = iTime(symbol, PERIOD_D1, adrPeriod + 5);
   if(startDate == 0)
     {
      Print("<", __FUNCTION__, "> Insufficient history: ", symbol, " ", TimeframeName(tf));
      return false;
     }

   Print("<", __FUNCTION__, "> Start load ", symbol, " ", TimeframeName(tf), " from ", startDate);
   int res = LoadHistory(symbol, tf, startDate);
   switch(res)
     {
      case HISTORY_ERR_UNKNOWN_SYMBOL:
         Print("<", __FUNCTION__, "> Unknown symbol ", symbol);
         break;
      case HISTORY_ERR_MAX_BARS:
         Print("<", __FUNCTION__, "> Requested bars more than max bars in chart");
         break;
      case HISTORY_ERR_STOPPED:
         Print("<", __FUNCTION__, "> Program was stopped");
         break;
      case HISTORY_ERR_LOAD_FAILED:
         Print("<", __FUNCTION__, "> Load failed");
         break;
      case HISTORY_LOAD_OK:
         Print("<", __FUNCTION__, "> Loaded OK");
         break;
      case HISTORY_LOAD_CACHED:
         Print("<", __FUNCTION__, "> Loaded previously");
         break;
      case HISTORY_LOAD_BUILT:
         Print("<", __FUNCTION__, "> Loaded previously and built");
         break;
      default:
         Print("<", __FUNCTION__, "> Unknown result");
     }

   available = iBars(symbol, tf);
   if(available < barsRequired)
     {
      Print("<", __FUNCTION__, "> Insufficient history: ", symbol, " ", TimeframeName(tf));
      return false;
     }

   return true;
  }
//+--------------------------------------------------------------------------------------------------------------------+
int LoadHistory(string symbol, ENUM_TIMEFRAMES tf, datetime startDate)
  {
   datetime firstDate = 0;
   datetime times[100];

   if(!SymbolInfoInteger(symbol, SYMBOL_SELECT))
     {
      if(GetLastError() == ERR_MARKET_UNKNOWN_SYMBOL)
         return HISTORY_ERR_UNKNOWN_SYMBOL;
      SymbolSelect(symbol, true);
     }

   SeriesInfoInteger(symbol, tf, SERIES_FIRSTDATE, firstDate);
   if(firstDate > 0 && firstDate <= startDate)
      return HISTORY_LOAD_CACHED;

   if(SeriesInfoInteger(symbol, PERIOD_M1, SERIES_TERMINAL_FIRSTDATE, firstDate))
     {
      if(firstDate > 0)
        {
         CopyTime(symbol, tf, firstDate + PeriodSeconds(tf), 1, times);
         if(SeriesInfoInteger(symbol, tf, SERIES_FIRSTDATE, firstDate))
            if(firstDate > 0 && firstDate <= startDate)
               return HISTORY_LOAD_BUILT;
        }
     }

   int maxBars = TerminalInfoInteger(TERMINAL_MAXBARS);

   datetime firstServerDate = 0;
   while(!SeriesInfoInteger(symbol, PERIOD_M1, SERIES_SERVER_FIRSTDATE, firstServerDate) && !IsStopped())
      Sleep(5);

   if(firstServerDate > startDate)
      startDate = firstServerDate;
   if(firstDate > 0 && firstDate < firstServerDate)
      Print("Warning: first server date ", TimeToString(firstServerDate), " for ",
            symbol, " does not match to first series date ", TimeToString(firstDate));

   int failCnt = 0;
   while(!IsStopped())
     {
      while(!SeriesInfoInteger(symbol, tf, SERIES_SYNCHRONIZED) && !IsStopped())
         Sleep(5);
      int bars = Bars(symbol, tf);
      if(bars > 0)
        {
         if(bars >= maxBars)
            return HISTORY_ERR_MAX_BARS;
         if(SeriesInfoInteger(symbol, tf, SERIES_FIRSTDATE, firstDate))
            if(firstDate > 0 && firstDate <= startDate)
               return HISTORY_LOAD_OK;
        }
      int copied = CopyTime(symbol, tf, bars, 100, times);
      if(copied > 0)
        {
         if(times[0] <= startDate)
            return HISTORY_LOAD_OK;
         if(bars + copied >= maxBars)
            return HISTORY_ERR_MAX_BARS;
         failCnt = 0;
        }
      else
        {
         failCnt++;
         if(failCnt >= 100)
            return HISTORY_ERR_LOAD_FAILED;
         Sleep(10);
        }
     }

   return HISTORY_ERR_STOPPED;
  }
//+====================================================================================================================+
//| CONVERSION & MAGIC HELPERS
//+====================================================================================================================+
ENUM_TIMEFRAMES IndexToTimeframe(int idx)
  {
   switch(idx)
     {
      case TF_INDEX_M15:
         return PERIOD_M15;
      case TF_INDEX_M30:
         return PERIOD_M30;
      case TF_INDEX_H1:
         return PERIOD_H1;
      default:
         return PERIOD_D1;
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
string TimeframeName(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return "M1";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H4:
         return "H4";
      case PERIOD_D1:
         return "D1";
      default:
         return "UNKNOWN";
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
int GetMagicNumber(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:
         return 110111;
      case PERIOD_M5:
         return 110511;
      case PERIOD_M15:
         return 110911;
      case PERIOD_M30:
         return 111111;
      case PERIOD_H1:
         return 111211;
      case PERIOD_H4:
         return 111511;
      case PERIOD_D1:
         return 111911;
      case PERIOD_W1:
         return 112011;
      case PERIOD_MN1:
         return 112111;
      default:
         return 0;
     }
  }
//+--------------------------------------------------------------------------------------------------------------------+
bool IsMagicValid(long magic)
  {
   for(int i = 0; i < TF_INDEX_COUNT; i++)
      if(magic == GetMagicNumber(IndexToTimeframe(i)))
         return true;
   return false;
  }
//+====================================================================================================================+
//| END OF EXPERT ADVISOR
//+====================================================================================================================+
