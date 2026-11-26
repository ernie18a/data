//+------------------------------------------------------------------+
//|                                           Master Intelligence EA |
//|                            Advanced Multi-Module Market Analysis |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Master Intelligence"
#property link      "https://www.mql5.com/en/users/searchmixed"
#property version   "2.00"
#property description "Advanced multi-module market analysis EA with enhanced data storage and analysis"
#property strict

#include <Trade\Trade.mqh>
#include <Arrays\ArrayObj.mqh>

//--- Input Parameters
input group "Data Management"
input bool   EnableDataPersistence = true;     // Enable saving/loading data to files
input string DataDirectory = "MasterIntelligence"; // Directory for data files
input int    MaxTickDataSize = 10000;          // Maximum tick data to store (increased)
input int    MaxMemoryEntries = 1000;          // Maximum memory entries (increased)
input bool   EnableAutoSave = true;            // Auto-save data on deinit
input int    AutoSaveIntervalMinutes = 30;     // Auto-save interval in minutes

input group "Reaction Engine 2.0"
input int    ReactionWindowSec = 10;         // Look-back window in seconds
input double ReactionVolWeight = 0.6;        // Volume weight (0-1)
input double ReactionSpeedWeight = 0.4;      // Tick velocity weight (0-1)
input double PriceSmoothing = 0.2;           // EMA alpha for price smoothing

input group "Flow Pattern Detector"
input int    PatternWindowTicks = 20;        // Pattern window in ticks
input double PatternMinConfidence = 0.55;    // Minimum confidence threshold
input int    MaxPatternHistory = 1000;       // Maximum pattern history to store

input group "Weighted Volume Delta"
input double WeightedExponent = 1.25;        // Volume weighting exponent
input bool   UseDOM = false;                 // Use DOM if available
input int    TopLevels = 5;                  // Top DOM levels to consider

input group "Candle Forecast Engine"
input double w_pressure = 0.3;               // Pressure weight
input double w_dv = 0.25;                    // Delta Volume weight
input double w_pattern = 0.2;                // Pattern weight
input double w_tps = 0.15;                   // TPS weight
input double w_prevtrend = 0.1;              // Previous trend weight
input double ConfidenceSmoothing = 0.3;      // EMA alpha for confidence
input bool   UseNeuralNetwork = true;        // Enable neural network-like processing

input group "Adaptive Thresholds"
input int    ATRlen = 14;                    // ATR period
input double ThresholdMultiplierBase = 0.5;  // Base threshold multiplier
input double VolatilityScaling = 1.0;        // Volatility scaling factor

input group "Tick Density Clock"
input int    TPSWindowSec = 10;              // TPS window in seconds
input double TPSAlertHigh = 2.0;             // High TPS alert threshold (std devs)
input double TPSAlertLow = 0.5;              // Low TPS alert threshold (std devs)

input group "Market Reaction Memory"
input int    MemorySize = 1000;              // Memory buffer size (increased)
input double LearningRate = 0.01;            // Learning rate for weight updates
input bool   EnablePatternLearning = true;   // Enable pattern learning from historical data

input group "Advanced Analytics"
input bool   EnableCorrelationAnalysis = true; // Enable correlation analysis between indicators
input bool   EnableRegressionAnalysis = true;  // Enable regression analysis for prediction
input bool   EnableVolatilityAnalysis = true;  // Enable advanced volatility analysis
input bool   EnableSentimentAnalysis = false;  // Enable sentiment analysis (if data available)

input group "Decision Layer"
input double min_confidence_to_act = 0.65;   // Minimum confidence to act
input int    risk_mode = 1;                  // 0=Conservative, 1=Normal, 2=Aggressive

input group "Display Settings"
input int    PanelRefreshMs = 250;           // Panel refresh interval (ms)
input color  PanelBackgroundColor = C'25,25,35';
input color  PanelTextColor = White;
input color  BullishColor = Lime;
input color  BearishColor = Red;
input color  NeutralColor = Gray;
input bool   ShowAdvancedPanel = true;       // Show advanced analytics panel

//--- Global Variables
CTrade trade;
datetime lastBarTime = 0;
datetime lastAutoSaveTime = 0;
int panelTimer = 0;
bool panelInitialized = false;
ENUM_TIMEFRAMES currentPeriod = PERIOD_CURRENT; // Track current timeframe
bool memoryComputed = false; // Track if memory has enough data

//--- Module Data Structures
struct TickData
  {
   datetime          time;
   double            bid;
   double            ask;
   double            volume;
   double            mid;
   double            spread;  // Added spread
   double            volatility; // Added volatility
  };

struct PatternMatch
  {
   string            name;
   double            confidence;
   string            sequence;
   int               frequency; // How often this pattern occurs
   double            success_rate; // Historical success rate
  };

struct ForecastResult
  {
   double            score;
   int               direction;  // -1=DOWN, 0=NEUTRAL, 1=UP
   double            confidence;
   double            probability_up; // Probability of upward movement
   double            probability_down; // Probability of downward movement
   double            expected_move; // Expected price movement in pips
  };

struct DecisionResult
  {
   string            bias;
   double            strength;
   string            action;
   string            rationale;
   double            risk_reward_ratio; // Added risk/reward ratio
  };

// Advanced Analytics Structures
struct CorrelationData
  {
   double            pressure_delta_corr; // Correlation between pressure and delta
   double            pressure_tps_corr;   // Correlation between pressure and TPS
   double            delta_tps_corr;      // Correlation between delta and TPS
   double            pattern_success_corr; // Correlation between pattern and success
  };

struct VolatilityMetrics
  {
   double            current_volatility;
   double            historical_avg;
   double            volatility_percentile; // Current volatility percentile
   bool              is_high_volatility;     // High volatility flag
   bool              is_low_volatility;      // Low volatility flag
  };

struct RegressionModel
  {
   double            intercept;
   double            pressure_coefficient;
   double            delta_coefficient;
   double            pattern_coefficient;
   double            tps_coefficient;
   double            r_squared; // Model fit quality
  };

//--- Module Buffers
TickData tickBuffer[];
int tickBufferSize = 0;
int maxTickBufferSize = 10000; // Increased from 1000

// Pattern history for learning
PatternMatch patternHistory[];
int patternHistorySize = 0;

//--- Module Outputs
double PressureIndex = 0.0;
string PressureLabel = "Neutral";
PatternMatch CurrentPattern;
double WeightedDelta = 0.0;
double DeltaNormalized = 0.0;
ForecastResult Forecast;
double CurrentTPS = 0.0;
string TPSState = "Idle";
double Accuracy = 0.0;
double BiasCorrection = 0.0;
DecisionResult Decision;

// Advanced Analytics Outputs
CorrelationData Correlations;
VolatilityMetrics Volatility;
RegressionModel Regression;

//--- Memory Module
struct MemoryEntry
  {
   datetime          timestamp;
   double            forecast_score;
   int               forecast_dir;
   double            confidence;
   int               actual_dir;
   double            price_move;
   double            volume;
   double            pressure; // Added pressure at time of forecast
   double            delta;    // Added delta at time of forecast
   string            pattern;  // Added pattern at time of forecast
   double            tps;      // Added TPS at time of forecast
  };

MemoryEntry memoryBuffer[];
int memoryIndex = 0;

//--- Adaptive Thresholds
double dynamicThreshold = 0.0;
double currentATR = 0.0;

//--- TPS History for more accurate calculations
double tpsHistory[];
int tpsHistorySize = 20;
int tpsHistoryIndex = 0;

//--- Indicator handles
int atrHandle = INVALID_HANDLE;

//--- File handles for data persistence
int tickDataFileHandle = INVALID_HANDLE;
int memoryDataFileHandle = INVALID_HANDLE;
int patternDataFileHandle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| SafeSetText helper - prevents silent failures                      |
//+------------------------------------------------------------------+
void SafeSetText(string name, string txt, color col = CLR_NONE)
  {
   if(ObjectFind(0, name) >= 0)
     {
      ObjectSetString(0, name, OBJPROP_TEXT, txt);
      if(col != CLR_NONE)
         ObjectSetInteger(0, name, OBJPROP_COLOR, col);
     }
   else
     {
      static bool shown=false;
      if(!shown)
        {
         Print("Warning: panel object missing: ", name);
         shown=true;
        }
     }
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Check if timeframe changed
   if(_Period != currentPeriod)
     {
      // Clean up previous objects if timeframe changed
      CleanUpAllObjects();
      currentPeriod = _Period;
     }

//--- Create data directory if it doesn't exist
   if(EnableDataPersistence)
     {
      string terminalDataPath = TerminalInfoString(TERMINAL_DATA_PATH);
      string fullPath = terminalDataPath + "\\MQL4\\Files\\" + DataDirectory;

      // Try to create directory (MQL4 doesn't have FolderCreate, so we'll use a workaround)
      if(!FolderExists(fullPath))
        {
         // Create a dummy file to ensure directory exists
         int fileHandle = FileOpen(DataDirectory + "\\__init__.txt", FILE_WRITE|FILE_TXT);
         if(fileHandle != INVALID_HANDLE)
           {
            FileWrite(fileHandle, "Initialization file for Master Intelligence EA");
            FileClose(fileHandle);
           }
        }
     }

//--- Initialize buffers
   ArrayResize(tickBuffer, maxTickBufferSize);
   ArrayResize(memoryBuffer, MemorySize);
   ArrayResize(tpsHistory, tpsHistorySize);
   ArrayResize(patternHistory, MaxPatternHistory);

//--- Load existing data if enabled
   if(EnableDataPersistence)
     {
      LoadTickData();
      LoadMemoryData();
      LoadPatternHistory();
     }

//--- Initialize module outputs
   InitializeModuleOutputs();

//--- Initialize ATR indicator
   atrHandle = iATR(_Symbol, _Period, ATRlen);
   if(atrHandle == INVALID_HANDLE)
     {
      Print("Error creating ATR indicator");
      return(INIT_FAILED);
     }

//--- Create panel
   CreatePanel();
   panelInitialized = true;

//--- Set timer for panel updates
   EventSetTimer(PanelRefreshMs / 1000);

//--- Initialize last bar time
   lastBarTime = iTime(_Symbol, _Period, 0);
   lastAutoSaveTime = TimeCurrent();

//--- Initialize memory
   for(int i = 0; i < MemorySize; i++)
     {
      memoryBuffer[i].timestamp = 0;
      memoryBuffer[i].forecast_score = 0;
      memoryBuffer[i].forecast_dir = 0;
      memoryBuffer[i].confidence = 0;
      memoryBuffer[i].actual_dir = 0;
      memoryBuffer[i].price_move = 0;
      memoryBuffer[i].volume = 0;
      memoryBuffer[i].pressure = 0;
      memoryBuffer[i].delta = 0;
      memoryBuffer[i].pattern = "";
      memoryBuffer[i].tps = 0;
     }

//--- Initial panel update
   UpdatePanel();

   Print("Master Intelligence EA v2.0 initialized successfully on ", _Symbol, " ", PeriodToString(_Period));
   Print("Data persistence: ", EnableDataPersistence ? "ENABLED" : "DISABLED");
   Print("Loaded ", tickBufferSize, " ticks and ", memoryIndex, " memory entries");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Kill timer
   EventKillTimer();

//--- Save data if enabled
   if(EnableDataPersistence && EnableAutoSave)
     {
      SaveTickData();
      SaveMemoryData();
      SavePatternHistory();
      Print("Data auto-saved on deinitialization");
     }

//--- Clean up all objects
   CleanUpAllObjects();

//--- Release indicator handles
   if(atrHandle != INVALID_HANDLE)
     {
      IndicatorRelease(atrHandle);
      atrHandle = INVALID_HANDLE;
     }

//--- Clear chart comment
   Comment("");

//--- Print deinitialization reason
   string deinitReason = "";
   switch(reason)
     {
      case REASON_PROGRAM:
         deinitReason = "Program stopped";
         break;
      case REASON_REMOVE:
         deinitReason = "Program removed from chart";
         break;
      case REASON_RECOMPILE:
         deinitReason = "Program recompiled";
         break;
      case REASON_CHARTCHANGE:
         deinitReason = "Symbol or timeframe changed";
         break;
      case REASON_CHARTCLOSE:
         deinitReason = "Chart closed";
         break;
      case REASON_PARAMETERS:
         deinitReason = "Input parameters changed";
         break;
      case REASON_ACCOUNT:
         deinitReason = "Account changed";
         break;
      default:
         deinitReason = "Unknown reason";
         break;
     }

   Print("Master Intelligence EA deinitialized: ", deinitReason);
  }

//+------------------------------------------------------------------+
//| Check if folder exists                                           |
//+------------------------------------------------------------------+
bool FolderExists(string path)
  {
   string file = path + "\\__check__.txt";
   int handle = FileOpen(file, FILE_READ|FILE_TXT);
   if(handle != INVALID_HANDLE)
     {
      FileClose(handle);
      FileDelete(file);
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Save tick data to file                                           |
//+------------------------------------------------------------------+
void SaveTickData()
  {
   if(!EnableDataPersistence || tickBufferSize == 0)
      return;

   string filename = DataDirectory + "\\" + _Symbol + "_" + PeriodToString(_Period) + "_ticks.csv";
   int fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI, ",");

   if(fileHandle != INVALID_HANDLE)
     {
      // Write header
      FileWrite(fileHandle, "Time", "Bid", "Ask", "Volume", "Mid", "Spread", "Volatility");

      // Write data
      int startIdx = (tickBufferSize > maxTickBufferSize) ? (tickBufferSize % maxTickBufferSize) : 0;
      int count = MathMin(tickBufferSize, maxTickBufferSize);

      for(int i = 0; i < count; i++)
        {
         int idx = (startIdx + i) % maxTickBufferSize;
         FileWrite(fileHandle,
                   TimeToString(tickBuffer[idx].time, TIME_DATE|TIME_SECONDS),
                   DoubleToString(tickBuffer[idx].bid, _Digits),
                   DoubleToString(tickBuffer[idx].ask, _Digits),
                   DoubleToString(tickBuffer[idx].volume, 2),
                   DoubleToString(tickBuffer[idx].mid, _Digits),
                   DoubleToString(tickBuffer[idx].spread, _Digits),
                   DoubleToString(tickBuffer[idx].volatility, 5)
                  );
        }

      FileClose(fileHandle);
      Print("Saved ", count, " tick data points to ", filename);
     }
   else
     {
      Print("Error saving tick data to file: ", filename);
     }
  }

//+------------------------------------------------------------------+
//| Load tick data from file                                          |
//+------------------------------------------------------------------+
void LoadTickData()
  {
   if(!EnableDataPersistence)
      return;

   string filename = DataDirectory + "\\" + _Symbol + "_" + PeriodToString(_Period) + "_ticks.csv";
   int fileHandle = FileOpen(filename, FILE_READ|FILE_CSV|FILE_ANSI, ",");

   if(fileHandle != INVALID_HANDLE)
     {
      // Skip header
      FileReadString(fileHandle);

      int loaded = 0;
      while(!FileIsEnding(fileHandle) && loaded < maxTickBufferSize)
        {
         string timeStr = FileReadString(fileHandle);
         double bid = StringToDouble(FileReadString(fileHandle));
         double ask = StringToDouble(FileReadString(fileHandle));
         double volume = StringToDouble(FileReadString(fileHandle));
         double mid = StringToDouble(FileReadString(fileHandle));
         double spread = StringToDouble(FileReadString(fileHandle));
         double volatility = StringToDouble(FileReadString(fileHandle));

         tickBuffer[loaded].time = StringToTime(timeStr);
         tickBuffer[loaded].bid = bid;
         tickBuffer[loaded].ask = ask;
         tickBuffer[loaded].volume = volume;
         tickBuffer[loaded].mid = mid;
         tickBuffer[loaded].spread = spread;
         tickBuffer[loaded].volatility = volatility;

         loaded++;
        }

      tickBufferSize = loaded;
      FileClose(fileHandle);
      Print("Loaded ", loaded, " tick data points from ", filename);
     }
   else
     {
      Print("No existing tick data file found or error opening: ", filename);
     }
  }

//+------------------------------------------------------------------+
//| Save memory data to file                                          |
//+------------------------------------------------------------------+
void SaveMemoryData()
  {
   if(!EnableDataPersistence || memoryIndex == 0)
      return;

   string filename = DataDirectory + "\\" + _Symbol + "_" + PeriodToString(_Period) + "_memory.csv";
   int fileHandle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_ANSI, ",");

   if(fileHandle != INVALID_HANDLE)
     {
      // Write header
      FileWrite(fileHandle, "Timestamp", "ForecastScore", "ForecastDir", "Confidence",
                "ActualDir", "PriceMove", "Volume", "Pressure", "Delta", "Pattern", "TPS");

      // Write data
      for(int i = 0; i < MemorySize; i++)
        {
         if(memoryBuffer[i].timestamp == 0)
            continue;

         FileWrite(fileHandle,
                   TimeToString(memoryBuffer[i].timestamp, TIME_DATE|TIME_SECONDS),
                   DoubleToString(memoryBuffer[i].forecast_score, 5),
                   IntegerToString(memoryBuffer[i].forecast_dir),
                   DoubleToString(memoryBuffer[i].confidence, 2),
                   IntegerToString(memoryBuffer[i].actual_dir),
                   DoubleToString(memoryBuffer[i].price_move, _Digits),
                   DoubleToString(memoryBuffer[i].volume, 2),
                   DoubleToString(memoryBuffer[i].pressure, 5),
                   DoubleToString(memoryBuffer[i].delta, 2),
                   memoryBuffer[i].pattern,
                   DoubleToString(memoryBuffer[i].tps, 2)
                  );
        }

      FileClose(fileHandle);
      Print("Saved memory data to ", filename);
     }
   else
     {
      Print("Error saving memory data to file: ", filename);
     }
  }

//+------------------------------------------------------------------+
//| Load memory data from file                                         |
//+------------------------------------------------------------------+
void LoadMemoryData()
  {
   if(!EnableDataPersistence)
      return;

   string filename = DataDirectory + "\\" + _Symbol + "_" + PeriodToString(_Period) + "_memory.csv";
   int fileHandle = FileOpen(filename, FILE_READ|FILE_CSV|FILE_ANSI, ",");

   if(fileHandle != INVALID_HANDLE)
     {
      // Skip header
      FileReadString(fileHandle);

      int loaded = 0;
      while(!FileIsEnding(fileHandle) && loaded < MemorySize)
        {
         string timeStr = FileReadString(fileHandle);
         double forecast_score = StringToDouble(FileReadString(fileHandle));
         string forecast_str = FileReadString(fileHandle);
         int forecast_dir = 0;
         if(forecast_str != "")
            forecast_dir = (int)StringToInteger(forecast_str);
         double confidence = StringToDouble(FileReadString(fileHandle));
         string actual_str = FileReadString(fileHandle);
         int actual_dir = 0;
         if(actual_str != "")
            actual_dir = (int)StringToInteger(actual_str);
         double price_move = StringToDouble(FileReadString(fileHandle));
         double volume = StringToDouble(FileReadString(fileHandle));
         double pressure = StringToDouble(FileReadString(fileHandle));
         double delta = StringToDouble(FileReadString(fileHandle));
         string pattern = FileReadString(fileHandle);
         double tps = StringToDouble(FileReadString(fileHandle));

         memoryBuffer[loaded].timestamp = StringToTime(timeStr);
         memoryBuffer[loaded].forecast_score = forecast_score;
         memoryBuffer[loaded].forecast_dir = forecast_dir;
         memoryBuffer[loaded].confidence = confidence;
         memoryBuffer[loaded].actual_dir = actual_dir;
         memoryBuffer[loaded].price_move = price_move;
         memoryBuffer[loaded].volume = volume;
         memoryBuffer[loaded].pressure = pressure;
         memoryBuffer[loaded].delta = delta;
         memoryBuffer[loaded].pattern = pattern;
         memoryBuffer[loaded].tps = tps;

         loaded++;
        }

      memoryIndex = loaded;
      FileClose(fileHandle);
      Print("Loaded ", loaded, " memory entries from ", filename);
     }
   else
     {
      Print("No existing memory data file found or error opening: ", filename);
     }
  }

//+------------------------------------------------------------------+
//| Save pattern history to file                                      |
//+------------------------------------------------------------------+
void SavePatternHistory()
  {
   if(!EnableDataPersistence || patternHistorySize == 0)
      return;

   string filename = DataDirectory + "\\" + _Symbol + "_" + PeriodToString(_Period) + "_patterns.csv";
   int fileHandle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_ANSI, ",");

   if(fileHandle != INVALID_HANDLE)
     {
      // Write header
      FileWrite(fileHandle, "Name", "Confidence", "Sequence", "Frequency", "SuccessRate");

      // Write data
      for(int i = 0; i < patternHistorySize; i++)
        {
         FileWrite(fileHandle,
                   patternHistory[i].name,
                   DoubleToString(patternHistory[i].confidence, 3),
                   patternHistory[i].sequence,
                   IntegerToString(patternHistory[i].frequency),
                   DoubleToString(patternHistory[i].success_rate, 3)
                  );
        }

      FileClose(fileHandle);
      Print("Saved pattern history to ", filename);
     }
   else
     {
      Print("Error saving pattern history to file: ", filename);
     }
  }

//+------------------------------------------------------------------+
//| Load pattern history from file                                    |
//+------------------------------------------------------------------+
void LoadPatternHistory()
  {
   if(!EnableDataPersistence)
      return;

   string filename = DataDirectory + "\\" + _Symbol + "_" + PeriodToString(_Period) + "_patterns.csv";
   int fileHandle = FileOpen(filename, FILE_READ|FILE_CSV|FILE_ANSI, ",");

   if(fileHandle != INVALID_HANDLE)
     {
      // Skip header
      FileReadString(fileHandle);

      int loaded = 0;
      while(!FileIsEnding(fileHandle) && loaded < MaxPatternHistory)
        {
         string name = FileReadString(fileHandle);
         double confidence = StringToDouble(FileReadString(fileHandle));
         string sequence = FileReadString(fileHandle);
         string freq_str = FileReadString(fileHandle);
         int frequency = 0;
         if(freq_str != "")
            frequency = (int)StringToInteger(freq_str);
         double success_rate = StringToDouble(FileReadString(fileHandle));

         patternHistory[loaded].name = name;
         patternHistory[loaded].confidence = confidence;
         patternHistory[loaded].sequence = sequence;
         patternHistory[loaded].frequency = frequency;
         patternHistory[loaded].success_rate = success_rate;

         loaded++;
        }

      patternHistorySize = loaded;
      FileClose(fileHandle);
      Print("Loaded ", loaded, " pattern history entries from ", filename);
     }
   else
     {
      Print("No existing pattern history file found or error opening: ", filename);
     }
  }

//+------------------------------------------------------------------+
//| Clean up all objects function                                    |
//+------------------------------------------------------------------+
void CleanUpAllObjects()
  {
//--- Clean up panel objects
   ObjectsDeleteAll(0, "MIModule");
   ObjectsDeleteAll(0, "MITitle");
   ObjectsDeleteAll(0, "MIPanel");
   ObjectsDeleteAll(0, "MIData");
   ObjectsDeleteAll(0, "MISeparator");
   ObjectsDeleteAll(0, "MIAdvanced");

//--- Force chart redraw to clear any remaining text
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Check if timeframe changed
   if(_Period != currentPeriod)
     {
      // Reinitialize if timeframe changed
      Print("Timeframe changed from ", PeriodToString(currentPeriod), " to ", PeriodToString(_Period));
      OnDeinit(REASON_CHARTCHANGE);
      OnInit();
      return;
     }

//--- Update tick buffer
   UpdateTickBuffer();

//--- FAST modules: recompute every tick for live UI (cheap)
   ComputeReactionEngine();        // PressureIndex
   ComputeFlowPatternDetector();   // CurrentPattern (tick-level)
   ComputeWeightedVolumeDelta();   // WeightedDelta & DeltaNormalized
   ComputeTickDensityClock();      // CurrentTPS & TPSState
   ComputeCandleForecastEngine();  // Forecast.score/confidence (light)
   ComputeDecisionLayer();         // Decision + rationale depends on above

//--- Occasionally update ATR-based thresholds (every 5 ticks)
   static int adaptTickCounter = 0;
   adaptTickCounter++;
   if(adaptTickCounter >= 5)
     {
      ComputeAdaptiveThresholds();
      adaptTickCounter = 0;
     }

//--- Advanced analytics (every 10 ticks to reduce CPU load)
   static int analyticsCounter = 0;
   analyticsCounter++;
   if(analyticsCounter >= 10)
     {
      if(EnableCorrelationAnalysis)
         ComputeCorrelationAnalysis();
      if(EnableVolatilityAnalysis)
         ComputeVolatilityAnalysis();
      if(EnableRegressionAnalysis)
         ComputeRegressionAnalysis();
      analyticsCounter = 0;
     }

//--- Now update the panel (after all computed values are fresh)
   if(panelInitialized)
      UpdatePanel();

//--- Auto-save data at intervals
   if(EnableDataPersistence && EnableAutoSave)
     {
      datetime currentTime = TimeCurrent();
      if(currentTime - lastAutoSaveTime > AutoSaveIntervalMinutes * 60)
        {
         SaveTickData();
         SaveMemoryData();
         SavePatternHistory();
         lastAutoSaveTime = currentTime;
         Print("Data auto-saved at ", TimeToString(currentTime));
        }
     }

//--- New bar check (runs heavy work that must be on new bar)
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   if(currentBarTime != lastBarTime)
     {
      lastBarTime = currentBarTime;
      OnNewBar();
     }
  }

//+------------------------------------------------------------------+
//| Timer function for panel updates                                 |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- Run light computations on timer for more responsive display
   if(tickBufferSize > 0)
     {
      ComputeTickDensityClock();
     }
  }

//+------------------------------------------------------------------+
//| New bar event handler                                            |
//+------------------------------------------------------------------+
void OnNewBar()
  {
//--- Run all modules
   ComputeReactionEngine();
   ComputeFlowPatternDetector();
   ComputeWeightedVolumeDelta();
   ComputeCandleForecastEngine();
   ComputeAdaptiveThresholds();
   ComputeTickDensityClock();
   ComputeMarketReactionMemory();
   ComputeDecisionLayer();

//--- Advanced analytics on new bar
   if(EnableCorrelationAnalysis)
      ComputeCorrelationAnalysis();
   if(EnableVolatilityAnalysis)
      ComputeVolatilityAnalysis();
   if(EnableRegressionAnalysis)
      ComputeRegressionAnalysis();

//--- Force panel update on new bar
   if(panelInitialized)
     {
      UpdatePanel();
     }
  }

//+------------------------------------------------------------------+
//| Update tick buffer                                               |
//+------------------------------------------------------------------+
void UpdateTickBuffer()
  {
   MqlTick tick;
   SymbolInfoTick(_Symbol, tick);

//--- Add new tick to buffer
   int index = tickBufferSize % maxTickBufferSize;
   tickBuffer[index].time = tick.time;
   tickBuffer[index].bid = tick.bid;
   tickBuffer[index].ask = tick.ask;
   tickBuffer[index].volume = (double)tick.volume; // Explicit cast to resolve warning
   tickBuffer[index].mid = (tick.bid + tick.ask) / 2.0;
   tickBuffer[index].spread = tick.ask - tick.bid;

// Calculate tick volatility (price change from previous tick)
   if(tickBufferSize > 0)
     {
      int prevIdx = (tickBufferSize - 1) % maxTickBufferSize;
      double priceChange = MathAbs(tickBuffer[index].mid - tickBuffer[prevIdx].mid);
      tickBuffer[index].volatility = priceChange;
     }
   else
     {
      tickBuffer[index].volatility = 0.0;
     }

   tickBufferSize++;
  }

//+------------------------------------------------------------------+
//| Compute Reaction Engine 2.0 - Enhanced                           |
//+------------------------------------------------------------------+
void ComputeReactionEngine()
  {
   if(tickBufferSize < 2)
      return;

//--- Calculate window size in ticks
   int windowTicks = 0;
   datetime cutoffTime = TimeCurrent() - ReactionWindowSec;

   for(int i = 0; i < MathMin(tickBufferSize, maxTickBufferSize); i++)
     {
      int idx = (tickBufferSize - 1 - i) % maxTickBufferSize;
      if(tickBuffer[idx].time < cutoffTime)
         break;
      windowTicks++;
     }

   if(windowTicks < 2)
      return;

//--- Calculate weighted move sum with enhanced factors
   double weightedMoveSum = 0.0;
   double sumMid = 0.0;
   double sumMidSq = 0.0;
   double tickVelocity = windowTicks / (double)ReactionWindowSec;
   double volatilitySum = 0.0;

   for(int i = 1; i < windowTicks; i++)
     {
      int currIdx = (tickBufferSize - i) % maxTickBufferSize;
      int prevIdx = (tickBufferSize - i - 1) % maxTickBufferSize;

      double dP = tickBuffer[currIdx].mid - tickBuffer[prevIdx].mid;
      double volFactor = 1.0 + tickBuffer[currIdx].volume * 0.1;

      // Enhanced weighting with volatility factor
      double volatilityFactor = 1.0 + tickBuffer[currIdx].volatility * 100.0;
      double spreadFactor = 1.0 - (tickBuffer[currIdx].spread / (tickBuffer[currIdx].ask * 0.01)); // Normalize spread to percentage

      weightedMoveSum += dP * volFactor * volatilityFactor * spreadFactor;

      sumMid += tickBuffer[currIdx].mid;
      sumMidSq += tickBuffer[currIdx].mid * tickBuffer[currIdx].mid;
      volatilitySum += tickBuffer[currIdx].volatility;
     }

//--- Calculate window std
   double meanMid = sumMid / windowTicks;
   double variance = (sumMidSq / windowTicks) - (meanMid * meanMid);
   double stdMid = MathSqrt(variance);

//--- Normalize and combine with TPS and volatility
   double norm = (stdMid > 0) ? weightedMoveSum / stdMid : 0;
   double tickVelocityNormalizer = 10.0; // Default 10 ticks/sec
   double avgVolatility = volatilitySum / windowTicks;
   double volatilityNormalizer = _Point * 10; // Default 10 points
   double volatilityRatio = (volatilityNormalizer > 0) ? avgVolatility / volatilityNormalizer : 1.0;

   double pressureRaw = norm * (1.0 + ReactionSpeedWeight * (tickVelocity / tickVelocityNormalizer) + 0.2 * volatilityRatio);

//--- Map to -1..+1 range
   double rawPressure = MathTanh(pressureRaw);

//--- Apply EMA smoothing
   static double emaPressure = 0.0;
   if(emaPressure == 0.0)
      emaPressure = rawPressure;
   else
      emaPressure = PriceSmoothing * rawPressure + (1.0 - PriceSmoothing) * emaPressure;

   PressureIndex = emaPressure;

//--- Determine pressure label
   if(PressureIndex > 0.6)
      PressureLabel = "Strong";
   else
      if(PressureIndex > 0.2)
         PressureLabel = "Moderate";
      else
         if(PressureIndex > -0.2)
            PressureLabel = "Neutral";
         else
            if(PressureIndex > -0.6)
               PressureLabel = "Moderate (Sell)";
            else
               PressureLabel = "Strong (Sell)";
  }

//+------------------------------------------------------------------+
//| Compute Flow Pattern Detector - Enhanced with Learning           |
//+------------------------------------------------------------------+
void ComputeFlowPatternDetector()
  {
   if(tickBufferSize < 2)
     {
      CurrentPattern.name = "None";
      CurrentPattern.confidence = 0.0;
      CurrentPattern.sequence = "";
      return;
     }

   int window = MathMin(PatternWindowTicks, MathMin(tickBufferSize, maxTickBufferSize));
   int tickSides[];
   ArrayResize(tickSides, window);

// build tick sides using most recent window (index 0 = oldest in window, window-1 = latest)
   for(int i=0;i<window;i++)
     {
      int idx = (tickBufferSize - window + i) % maxTickBufferSize;
      if(i==0)
         tickSides[i] = 0;
      else
        {
         int prevIdx = (tickBufferSize - window + i - 1) % maxTickBufferSize;
         if(tickBuffer[idx].bid > tickBuffer[prevIdx].bid)
            tickSides[i] = 1;
         else
            if(tickBuffer[idx].bid < tickBuffer[prevIdx].bid)
               tickSides[i] = -1;
            else
               tickSides[i] = 0;
        }
     }

// templates (make seller template stronger)
   string patternNames[] = {"Buyer Re-entry","Seller Exhaustion","Spike-Bounce","Seller Re-entry","Buyer Exhaustion"};
   int patternTemplates[][5] =
     {
        {1,1,-1,1,1},
        {-1,-1,-1,1,1},  // stronger seller pattern
        {1,1,1,0,-1},
        {-1,-1,1,-1,-1}, // Seller Re-entry (NEW)
        {1,1,-1,-1,0}    // Buyer Exhaustion (NEW)
     };

   double bestConfidence = 0.0;
   int bestP=-1;
   for(int p=0;p<5;p++)   // Changed from 3 to 5
     {
      int templateSize = 5;
      for(int i=0;i<=window-templateSize;i++)
        {
         double match=0;
         for(int j=0;j<templateSize;j++)
            if(tickSides[i+j] == patternTemplates[p][j])
               match++;
         double sim = match / templateSize;

         // Enhanced confidence calculation with historical success rate
         double conf = sim * 0.8;

         // Check if this pattern exists in our history and adjust confidence based on success rate
         if(EnablePatternLearning && patternHistorySize > 0)
           {
            for(int h=0; h<patternHistorySize; h++)
              {
               if(patternHistory[h].name == patternNames[p])
                 {
                  // Boost confidence if pattern has high historical success rate
                  conf *= (0.5 + 0.5 * patternHistory[h].success_rate);
                  break;
                 }
              }
           }

         if(conf > bestConfidence)
           {
            bestConfidence = conf;
            bestP = p;
           }
        }
     }

   if(bestP >= 0 && bestConfidence >= PatternMinConfidence)
     {
      CurrentPattern.name = patternNames[bestP];
      CurrentPattern.confidence = bestConfidence;

      // show last 5 flow symbols (most recent)
      string seq="";
      for(int k = MathMax(0,window-5); k<window; k++)
        {
         seq += (tickSides[k] == 1) ? "↑" : (tickSides[k] == -1) ? "↓" : "→";
        }
      CurrentPattern.sequence = seq;

      // Update pattern history if learning is enabled
      if(EnablePatternLearning)
        {
         UpdatePatternHistory(CurrentPattern);
        }
     }
   else
     {
      CurrentPattern.name = "None";
      CurrentPattern.confidence = 0.0;
      CurrentPattern.sequence = "";
     }
  }

//+------------------------------------------------------------------+
//| Update pattern history with learning                             |
//+------------------------------------------------------------------+
void UpdatePatternHistory(PatternMatch &pattern)
  {
// Check if pattern already exists in history
   int foundIndex = -1;
   for(int i = 0; i < patternHistorySize; i++)
     {
      if(patternHistory[i].name == pattern.name &&
         patternHistory[i].sequence == pattern.sequence)
        {
         foundIndex = i;
         break;
        }
     }

   if(foundIndex >= 0)
     {
      // Update existing pattern
      patternHistory[foundIndex].frequency++;
      // Weighted average of confidence
      patternHistory[foundIndex].confidence =
         0.9 * patternHistory[foundIndex].confidence + 0.1 * pattern.confidence;
     }
   else
     {
      // Add new pattern if we have space
      if(patternHistorySize < MaxPatternHistory)
        {
         patternHistory[patternHistorySize] = pattern;
         patternHistory[patternHistorySize].frequency = 1;
         patternHistory[patternHistorySize].success_rate = 0.5; // Initialize with neutral success rate
         patternHistorySize++;
        }
      else
        {
         // Replace least frequent pattern
         int leastFreqIdx = 0;
         for(int i = 1; i < patternHistorySize; i++)
           {
            if(patternHistory[i].frequency < patternHistory[leastFreqIdx].frequency)
              {
               leastFreqIdx = i;
              }
           }
         patternHistory[leastFreqIdx] = pattern;
         patternHistory[leastFreqIdx].frequency = 1;
         patternHistory[leastFreqIdx].success_rate = 0.5;
        }
     }
  }

//+------------------------------------------------------------------+
//| Compute Weighted Volume Delta - Enhanced                         |
//+------------------------------------------------------------------+
void ComputeWeightedVolumeDelta()
  {
// --- inside ComputeWeightedVolumeDelta() at the top
   static bool deltaHistorySeeded = false;
   static double deltaHistory[20];
   static int deltaHistoryIdx = 0;
   if(!deltaHistorySeeded)
     {
      for(int d=0; d<20; d++)
         deltaHistory[d] = 1.0; // small baseline
      deltaHistorySeeded = true;
     }

   if(tickBufferSize < 2)
      return;

//--- Calculate delta for current bar
   datetime barTime = iTime(_Symbol, _Period, 0);
   double delta = 0.0;
   int tickCount = 0;
   double totalVolume = 0.0;
   double buyVolume = 0.0;
   double sellVolume = 0.0;

   for(int i = 0; i < MathMin(tickBufferSize, maxTickBufferSize); i++)
     {
      int idx = (tickBufferSize - 1 - i) % maxTickBufferSize;

      //--- Check if tick belongs to current bar
      if(tickBuffer[idx].time < barTime)
         break;

      //--- Determine tick side
      int side = 0;
      if(i > 0)
        {
         int prevIdx = (tickBufferSize - i) % maxTickBufferSize;
         if(tickBuffer[idx].bid > tickBuffer[prevIdx].bid)
           {
            side = 1; // Buy
           }
         else
            if(tickBuffer[idx].bid < tickBuffer[prevIdx].bid)
              {
               side = -1; // Sell
              }
        }

      //--- Apply volume weighting
      double volume = (tickBuffer[idx].volume > 0) ? tickBuffer[idx].volume : 1.0;
      double weightedVolume = MathPow(volume, WeightedExponent);

      delta += side * weightedVolume;
      totalVolume += weightedVolume;

      if(side == 1)
         buyVolume += weightedVolume;
      else
         if(side == -1)
            sellVolume += weightedVolume;

      tickCount++;
     }

   WeightedDelta = delta;

//--- Enhanced normalization with buy/sell ratio
   deltaHistory[deltaHistoryIdx] = MathAbs(delta);
   deltaHistoryIdx = (deltaHistoryIdx + 1) % 20;

   double avgDelta = 0.0;
   for(int i = 0; i < 20; i++)
     {
      avgDelta += deltaHistory[i];
     }
   avgDelta /= 20.0;
   if(avgDelta <= 0.0)
      avgDelta = 1.0; // fallback baseline

// Calculate buy/sell ratio
   double buySellRatio = (sellVolume > 0) ? buyVolume / sellVolume : 1.0;

// Enhanced normalization with buy/sell ratio
   DeltaNormalized = (delta / avgDelta) * MathLog(buySellRatio);
  }

//+------------------------------------------------------------------+
//| Compute Candle Forecast Engine - Enhanced with Neural Network    |
//+------------------------------------------------------------------+
void ComputeCandleForecastEngine()
  {
//--- Get features
   double f1 = PressureIndex; // Pressure
   double f2 = DeltaNormalized; // Weighted Delta
   double f3 = (CurrentPattern.name == "Buyer Re-entry") ? CurrentPattern.confidence :
               (CurrentPattern.name == "Seller Exhaustion") ? -CurrentPattern.confidence :
               (CurrentPattern.name == "Seller Re-entry") ? -CurrentPattern.confidence :
               (CurrentPattern.name == "Buyer Exhaustion") ? CurrentPattern.confidence : 0;
   double f4 = CurrentTPS / 10.0; // Normalized TPS
   double f5 = GetPrevTrend(); // Previous trend

//--- Enhanced forecast with neural network-like processing
   double forecastRaw;

   if(UseNeuralNetwork && memoryIndex > 100)
     {
      // Use regression model if we have enough data
      forecastRaw = Regression.intercept +
                    Regression.pressure_coefficient * f1 +
                    Regression.delta_coefficient * f2 +
                    Regression.pattern_coefficient * f3 +
                    Regression.tps_coefficient * f4;

      // Adjust with previous trend
      forecastRaw += w_prevtrend * f5;
     }
   else
     {
      // Standard weighted forecast
      forecastRaw = w_pressure * f1 + w_dv * f2 + w_pattern * f3 + w_tps * f4 + w_prevtrend * f5;
     }

//--- Apply tanh and scale
   Forecast.score = MathTanh(forecastRaw);

//--- Determine direction
   if(Forecast.score > 0.2)
      Forecast.direction = 1; // UP
   else
      if(Forecast.score < -0.2)
         Forecast.direction = -1; // DOWN
      else
         Forecast.direction = 0; // NEUTRAL

//--- Calculate confidence with enhanced metrics
   static double confidenceHistory[50];
   static int confHistoryIdx = 0;

   confidenceHistory[confHistoryIdx] = MathAbs(forecastRaw);
   confHistoryIdx = (confHistoryIdx + 1) % 50;

   double avgConf = 0.0;
   for(int i = 0; i < 50; i++)
     {
      avgConf += confidenceHistory[i];
     }
   avgConf /= 50.0;

   double stdConf = 0.0;
   for(int i = 0; i < 50; i++)
     {
      stdConf += MathPow(confidenceHistory[i] - avgConf, 2);
     }
   stdConf = MathSqrt(stdConf / 50.0);

// Enhanced confidence calculation with model fit quality
   double baseConfidence = (stdConf > 0) ? MathAbs(forecastRaw) / stdConf * 50.0 : 50.0;

// Adjust confidence based on regression model quality if available
   if(UseNeuralNetwork && Regression.r_squared > 0)
     {
      baseConfidence *= (0.5 + 0.5 * Regression.r_squared);
     }

   Forecast.confidence = MathMin(99.0, baseConfidence);

// Calculate probabilities
   double upProb = 0.0;
   double downProb = 0.0;

   if(Forecast.direction == 1)
     {
      upProb = 0.5 + 0.5 * Forecast.score;
      downProb = 1.0 - upProb;
     }
   else
      if(Forecast.direction == -1)
        {
         downProb = 0.5 + 0.5 * MathAbs(Forecast.score);
         upProb = 1.0 - downProb;
        }
      else
        {
         upProb = downProb = 0.5;
        }

   Forecast.probability_up = upProb;
   Forecast.probability_down = downProb;

// Calculate expected move in pips
   double atrMultiplier = (currentATR > 0) ? currentATR : 0.001;
   Forecast.expected_move = Forecast.score * atrMultiplier * 0.5; // Expected move is half ATR in direction

//--- Apply EMA smoothing to confidence
   static double emaConfidence = 0.0;
   if(emaConfidence == 0.0)
      emaConfidence = Forecast.confidence;
   else
      emaConfidence = ConfidenceSmoothing * Forecast.confidence + (1.0 - ConfidenceSmoothing) * emaConfidence;

   Forecast.confidence = emaConfidence;
  }

//+------------------------------------------------------------------+
//| Get Previous Trend - Enhanced                                    |
//+------------------------------------------------------------------+
double GetPrevTrend()
  {
   int bars = MathMin(5, Bars(_Symbol, _Period) - 1); // Increased from 3 to 5
   if(bars < 1)
      return 0.0;

   double trend = 0.0;
   double totalMove = 0.0;

   for(int i = 1; i <= bars; i++)
     {
      double open = iOpen(_Symbol, _Period, i);
      double close = iClose(_Symbol, _Period, i);
      double high = iHigh(_Symbol, _Period, i);
      double low = iLow(_Symbol, _Period, i);

      // Enhanced trend calculation with body size and wicks
      double body = close - open;
      double upperWick = high - MathMax(open, close);
      double lowerWick = MathMin(open, close) - low;
      double range = high - low;

      if(range > 0)
        {
         // Weight by body size relative to range
         double bodyRatio = MathAbs(body) / range;
         trend += (close > open) ? bodyRatio : -bodyRatio;
         totalMove += bodyRatio;
        }
     }

   return (totalMove > 0) ? trend / totalMove : 0.0;
  }

//+------------------------------------------------------------------+
//| Compute Adaptive Thresholds - Enhanced                           |
//+------------------------------------------------------------------+
void ComputeAdaptiveThresholds()
  {
//--- Get ATR values
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);

   if(CopyBuffer(atrHandle, 0, 0, 2, atrBuffer) <= 0)
     {
      Print("Error copying ATR buffer");
      return;
     }

   currentATR = atrBuffer[0];

//--- Calculate average TPS from history
   double avgTPS = 0.0;
   int validTPS = 0;

   for(int i = 0; i < tpsHistorySize; i++)
     {
      if(tpsHistory[i] > 0)
        {
         avgTPS += tpsHistory[i];
         validTPS++;
        }
     }

   if(validTPS > 0)
     {
      avgTPS /= validTPS;
     }
   else
     {
      avgTPS = CurrentTPS; // Fallback to current TPS
     }

   double baselineTPS = 5.0; // Baseline TPS
   double tpsFactor = 1.0 + VolatilityScaling * (avgTPS / baselineTPS);

// Enhanced threshold calculation with volatility adjustment
   double volatilityFactor = 1.0;
   if(Volatility.is_high_volatility)
     {
      volatilityFactor = 1.5; // Increase threshold in high volatility
     }
   else
      if(Volatility.is_low_volatility)
        {
         volatilityFactor = 0.7; // Decrease threshold in low volatility
        }

   dynamicThreshold = ThresholdMultiplierBase * currentATR * tpsFactor * volatilityFactor;
  }

//+------------------------------------------------------------------+
//| Compute Tick Density Clock - Enhanced                            |
//+------------------------------------------------------------------+
void ComputeTickDensityClock()
  {
//--- Count ticks in window
   int tickCount = 0;
   datetime cutoffTime = TimeCurrent() - TPSWindowSec;

   for(int i = 0; i < MathMin(tickBufferSize, maxTickBufferSize); i++)
     {
      int idx = (tickBufferSize - 1 - i) % maxTickBufferSize;
      if(tickBuffer[idx].time < cutoffTime)
         break;
      tickCount++;
     }

   CurrentTPS = tickCount / (double)TPSWindowSec;

//--- Store in history
   tpsHistory[tpsHistoryIndex] = CurrentTPS;
   tpsHistoryIndex = (tpsHistoryIndex + 1) % tpsHistorySize;

//--- Calculate TPS state with enhanced analysis
   double avgTPS = 0.0;
   int validTPS = 0;

   for(int i = 0; i < tpsHistorySize; i++)
     {
      if(tpsHistory[i] > 0)
        {
         avgTPS += tpsHistory[i];
         validTPS++;
        }
     }

   if(validTPS > 0)
     {
      avgTPS /= validTPS;
     }
   else
     {
      avgTPS = CurrentTPS; // Fallback to current TPS
     }

   double stdTPS = 0.0;
   for(int i = 0; i < tpsHistorySize; i++)
     {
      if(tpsHistory[i] > 0)
        {
         stdTPS += MathPow(tpsHistory[i] - avgTPS, 2);
        }
     }

   if(validTPS > 1)
     {
      stdTPS = MathSqrt(stdTPS / validTPS);
     }

// Enhanced TPS state calculation with trend analysis
   double tpsTrend = 0.0;
   if(validTPS > 5)
     {
      // Simple linear regression to determine trend
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
      for(int i = 0; i < MathMin(5, validTPS); i++)
        {
         int idx = (tpsHistoryIndex - 1 - i + tpsHistorySize) % tpsHistorySize;
         sumX += i;
         sumY += tpsHistory[idx];
         sumXY += i * tpsHistory[idx];
         sumX2 += i * i;
        }

      double n = MathMin(5, validTPS);
      double denominator = n * sumX2 - sumX * sumX;
      if(denominator != 0)
        {
         tpsTrend = (n * sumXY - sumX * sumY) / denominator;
        }
     }

   if(CurrentTPS > avgTPS + TPSAlertHigh * stdTPS)
     {
      TPSState = (tpsTrend > 0) ? "High (Accelerating)" : "High (Decelerating)";
     }
   else
      if(CurrentTPS < avgTPS - TPSAlertLow * stdTPS)
        {
         TPSState = (tpsTrend < 0) ? "Idle (Slowing)" : "Idle (Recovering)";
        }
      else
        {
         TPSState = (tpsTrend > 0) ? "Active (Increasing)" : "Active (Decreasing)";
        }
  }

//+------------------------------------------------------------------+
//| Compute Market Reaction Memory - Enhanced                        |
//+------------------------------------------------------------------+
void ComputeMarketReactionMemory()
  {
//--- Update memory with previous forecast
   if(memoryBuffer[(memoryIndex + MemorySize - 1) % MemorySize].timestamp > 0)
     {
      int prevIdx = (memoryIndex + MemorySize - 1) % MemorySize;

      //--- Determine actual direction
      double prevClose = iClose(_Symbol, _Period, 1);
      double prevPrevClose = iClose(_Symbol, _Period, 2);

      int actualDir = 0;
      if(prevClose > prevPrevClose)
         actualDir = 1;
      else
         if(prevClose < prevPrevClose)
            actualDir = -1;

      memoryBuffer[prevIdx].actual_dir = actualDir;
      memoryBuffer[prevIdx].price_move = prevClose - prevPrevClose;

      // Update pattern success rate if learning is enabled
      if(EnablePatternLearning && memoryBuffer[prevIdx].pattern != "")
        {
         UpdatePatternSuccessRate(memoryBuffer[prevIdx].pattern, memoryBuffer[prevIdx].forecast_dir, actualDir);
        }
     }

//--- Add current forecast to memory
   memoryBuffer[memoryIndex].timestamp = TimeCurrent();
   memoryBuffer[memoryIndex].forecast_score = Forecast.score;
   memoryBuffer[memoryIndex].forecast_dir = Forecast.direction;
   memoryBuffer[memoryIndex].confidence = Forecast.confidence;
   memoryBuffer[memoryIndex].pressure = PressureIndex;
   memoryBuffer[memoryIndex].delta = DeltaNormalized;
   memoryBuffer[memoryIndex].pattern = CurrentPattern.name;
   memoryBuffer[memoryIndex].tps = CurrentTPS;

   memoryIndex = (memoryIndex + 1) % MemorySize;

//--- Calculate accuracy with enhanced metrics
   int correct = 0;
   int total = 0;
   double totalError = 0.0;

   for(int i = 0; i < MemorySize; i++)
     {
      if(memoryBuffer[i].timestamp == 0)
         continue;
      if(memoryBuffer[i].actual_dir == 0)
         continue;

      total++;
      if(memoryBuffer[i].forecast_dir == memoryBuffer[i].actual_dir)
        {
         correct++;
        }

      // Calculate error for regression analysis
      double expected = memoryBuffer[i].forecast_score;
      double actual = memoryBuffer[i].actual_dir;
      totalError += MathPow(expected - actual, 2);
     }

   if(total > 0)
     {
      Accuracy = (double)correct / total * 100.0;
      memoryComputed = true;

      // Calculate mean squared error for regression model
      double mse = totalError / total;
      // This could be used to adjust model parameters
     }
   else
     {
      Accuracy = 0.0;
      memoryComputed = false;
     }

//--- Calculate bias correction
   double sumError = 0.0;
   for(int i = 0; i < MemorySize; i++)
     {
      if(memoryBuffer[i].timestamp == 0)
         continue;
      if(memoryBuffer[i].actual_dir == 0)
         continue;

      sumError += memoryBuffer[i].forecast_score - memoryBuffer[i].actual_dir;
     }

   BiasCorrection = (total > 0) ? sumError / total * 100.0 : 0.0;
  }

//+------------------------------------------------------------------+
//| Update pattern success rate for learning                        |
//+------------------------------------------------------------------+
void UpdatePatternSuccessRate(string patternName, int forecastDir, int actualDir)
  {
   for(int i = 0; i < patternHistorySize; i++)
     {
      if(patternHistory[i].name == patternName)
        {
         // Update success rate with exponential moving average
         double success = (forecastDir == actualDir) ? 1.0 : 0.0;
         patternHistory[i].success_rate = 0.9 * patternHistory[i].success_rate + 0.1 * success;
         break;
        }
     }
  }

//+------------------------------------------------------------------+
//| Compute Correlation Analysis - New Module                        |
//+------------------------------------------------------------------+
void ComputeCorrelationAnalysis()
  {
   if(memoryIndex < 50)
      return; // Need sufficient data

// Calculate correlations between different indicators
   double sumPressure = 0, sumDelta = 0, sumTPS = 0;
   double sumPressureDelta = 0, sumPressureTPS = 0, sumDeltaTPS = 0;
   double sumPressureSq = 0, sumDeltaSq = 0, sumTPSSq = 0;
   int count = 0;

   for(int i = 0; i < MemorySize; i++)
     {
      if(memoryBuffer[i].timestamp == 0)
         continue;

      sumPressure += memoryBuffer[i].pressure;
      sumDelta += memoryBuffer[i].delta;
      sumTPS += memoryBuffer[i].tps;

      sumPressureDelta += memoryBuffer[i].pressure * memoryBuffer[i].delta;
      sumPressureTPS += memoryBuffer[i].pressure * memoryBuffer[i].tps;
      sumDeltaTPS += memoryBuffer[i].delta * memoryBuffer[i].tps;

      sumPressureSq += memoryBuffer[i].pressure * memoryBuffer[i].pressure;
      sumDeltaSq += memoryBuffer[i].delta * memoryBuffer[i].delta;
      sumTPSSq += memoryBuffer[i].tps * memoryBuffer[i].tps;

      count++;
     }

   if(count < 2)
      return;

// Calculate correlations
   double avgPressure = sumPressure / count;
   double avgDelta = sumDelta / count;
   double avgTPS = sumTPS / count;

   double numeratorPressureDelta = sumPressureDelta - count * avgPressure * avgDelta;
   double denominatorPressureDelta = MathSqrt((sumPressureSq - count * avgPressure * avgPressure) *
                                     (sumDeltaSq - count * avgDelta * avgDelta));

   Correlations.pressure_delta_corr = (denominatorPressureDelta > 0) ?
                                      numeratorPressureDelta / denominatorPressureDelta : 0;

   double numeratorPressureTPS = sumPressureTPS - count * avgPressure * avgTPS;
   double denominatorPressureTPS = MathSqrt((sumPressureSq - count * avgPressure * avgPressure) *
                                   (sumTPSSq - count * avgTPS * avgTPS));

   Correlations.pressure_tps_corr = (denominatorPressureTPS > 0) ?
                                    numeratorPressureTPS / denominatorPressureTPS : 0;

   double numeratorDeltaTPS = sumDeltaTPS - count * avgDelta * avgTPS;
   double denominatorDeltaTPS = MathSqrt((sumDeltaSq - count * avgDelta * avgDelta) *
                                         (sumTPSSq - count * avgTPS * avgTPS));

   Correlations.delta_tps_corr = (denominatorDeltaTPS > 0) ?
                                 numeratorDeltaTPS / denominatorDeltaTPS : 0;

// Calculate pattern success correlation
   double sumPatternSuccess = 0, sumForecastSuccess = 0, sumPatternForecastSuccess = 0;
   double sumPatternSuccessSq = 0, sumForecastSuccessSq = 0;
   int patternCount = 0;

   for(int i = 0; i < MemorySize; i++)
     {
      if(memoryBuffer[i].timestamp == 0 || memoryBuffer[i].actual_dir == 0)
         continue;

      double patternSuccess = 0.0;
      if(memoryBuffer[i].pattern != "")
        {
         for(int p = 0; p < patternHistorySize; p++)
           {
            if(patternHistory[p].name == memoryBuffer[i].pattern)
              {
               patternSuccess = patternHistory[p].success_rate;
               break;
              }
           }
        }

      double forecastSuccess = (memoryBuffer[i].forecast_dir == memoryBuffer[i].actual_dir) ? 1.0 : 0.0;

      sumPatternSuccess += patternSuccess;
      sumForecastSuccess += forecastSuccess;
      sumPatternForecastSuccess += patternSuccess * forecastSuccess;
      sumPatternSuccessSq += patternSuccess * patternSuccess;
      sumForecastSuccessSq += forecastSuccess * forecastSuccess;

      patternCount++;
     }

   if(patternCount >= 2)
     {
      double avgPatternSuccess = sumPatternSuccess / patternCount;
      double avgForecastSuccess = sumForecastSuccess / patternCount;

      double numerator = sumPatternForecastSuccess - patternCount * avgPatternSuccess * avgForecastSuccess;
      double denominator = MathSqrt((sumPatternSuccessSq - patternCount * avgPatternSuccess * avgPatternSuccess) *
                                    (sumForecastSuccessSq - patternCount * avgForecastSuccess * avgForecastSuccess));

      Correlations.pattern_success_corr = (denominator > 0) ? numerator / denominator : 0;
     }
   else
     {
      Correlations.pattern_success_corr = 0;
     }
  }

//+------------------------------------------------------------------+
//| Compute Volatility Analysis - New Module                         |
//+------------------------------------------------------------------+
void ComputeVolatilityAnalysis()
  {
   if(tickBufferSize < 50)
      return;

// Calculate current volatility (standard deviation of price changes)
   double sumVolatility = 0.0;
   int count = 0;

   for(int i = 0; i < MathMin(100, tickBufferSize); i++)
     {
      int idx = (tickBufferSize - 1 - i) % maxTickBufferSize;
      sumVolatility += tickBuffer[idx].volatility;
      count++;
     }

   if(count == 0)
      return;

   Volatility.current_volatility = sumVolatility / count;

// Calculate historical average volatility
   double sumHistoricalVolatility = 0.0;
   int historicalCount = 0;

   for(int i = 100; i < MathMin(1000, tickBufferSize); i++)
     {
      int idx = (tickBufferSize - 1 - i) % maxTickBufferSize;
      sumHistoricalVolatility += tickBuffer[idx].volatility;
      historicalCount++;
     }

   if(historicalCount > 0)
     {
      Volatility.historical_avg = sumHistoricalVolatility / historicalCount;
     }
   else
     {
      Volatility.historical_avg = Volatility.current_volatility;
     }

// Calculate volatility percentile
   int lowerCount = 0;
   for(int i = 0; i < MathMin(1000, tickBufferSize); i++)
     {
      int idx = (tickBufferSize - 1 - i) % maxTickBufferSize;
      if(tickBuffer[idx].volatility < Volatility.current_volatility)
        {
         lowerCount++;
        }
     }

   int totalVolatilitySamples = MathMin(1000, tickBufferSize);
   Volatility.volatility_percentile = (totalVolatilitySamples > 0) ?
                                      (double)lowerCount / totalVolatilitySamples : 0.5;

// Determine volatility state
   Volatility.is_high_volatility = Volatility.volatility_percentile > 0.8;
   Volatility.is_low_volatility = Volatility.volatility_percentile < 0.2;
  }

//+------------------------------------------------------------------+
//| Compute Regression Analysis - New Module                         |
//+------------------------------------------------------------------+
void ComputeRegressionAnalysis()
  {
   if(memoryIndex < 100)
      return; // Need sufficient data for regression

// Simple linear regression to predict price movement
   double sumX1 = 0, sumX2 = 0, sumX3 = 0, sumX4 = 0, sumY = 0;
   double sumX1X1 = 0, sumX2X2 = 0, sumX3X3 = 0, sumX4X4 = 0;
   double sumX1Y = 0, sumX2Y = 0, sumX3Y = 0, sumX4Y = 0;
   double sumX1X2 = 0, sumX1X3 = 0, sumX1X4 = 0;
   double sumX2X3 = 0, sumX2X4 = 0, sumX3X4 = 0;
   int n = 0;

   for(int i = 0; i < MemorySize; i++)
     {
      if(memoryBuffer[i].timestamp == 0 || memoryBuffer[i].actual_dir == 0)
         continue;

      double x1 = memoryBuffer[i].pressure;     // Pressure
      double x2 = memoryBuffer[i].delta;        // Delta
      double x3 = memoryBuffer[i].tps / 10.0;   // Normalized TPS
      double x4 = (memoryBuffer[i].pattern == "Buyer Re-entry" || memoryBuffer[i].pattern == "Buyer Exhaustion") ? 1.0 :
                  (memoryBuffer[i].pattern == "Seller Exhaustion" || memoryBuffer[i].pattern == "Seller Re-entry") ? -1.0 : 0.0;
      double y = memoryBuffer[i].actual_dir;    // Actual direction

      sumX1 += x1;
      sumX2 += x2;
      sumX3 += x3;
      sumX4 += x4;
      sumY += y;
      sumX1X1 += x1 * x1;
      sumX2X2 += x2 * x2;
      sumX3X3 += x3 * x3;
      sumX4X4 += x4 * x4;
      sumX1Y += x1 * y;
      sumX2Y += x2 * y;
      sumX3Y += x3 * y;
      sumX4Y += x4 * y;
      sumX1X2 += x1 * x2;
      sumX1X3 += x1 * x3;
      sumX1X4 += x1 * x4;
      sumX2X3 += x2 * x3;
      sumX2X4 += x2 * x4;
      sumX3X4 += x3 * x4;

      n++;
     }

   if(n < 10)
      return; // Not enough data

// Calculate means
   double meanX1 = sumX1 / n;
   double meanX2 = sumX2 / n;
   double meanX3 = sumX3 / n;
   double meanX4 = sumX4 / n;
   double meanY = sumY / n;

// Calculate coefficients using multiple linear regression
// This is a simplified approach - in practice, you might use matrix operations
   double denominator = n * sumX1X1 - sumX1 * sumX1;
   if(denominator != 0)
     {
      Regression.pressure_coefficient = (n * sumX1Y - sumX1 * sumY) / denominator;
     }
   else
     {
      Regression.pressure_coefficient = 0;
     }

   denominator = n * sumX2X2 - sumX2 * sumX2;
   if(denominator != 0)
     {
      Regression.delta_coefficient = (n * sumX2Y - sumX2 * sumY) / denominator;
     }
   else
     {
      Regression.delta_coefficient = 0;
     }

   denominator = n * sumX3X3 - sumX3 * sumX3;
   if(denominator != 0)
     {
      Regression.tps_coefficient = (n * sumX3Y - sumX3 * sumY) / denominator;
     }
   else
     {
      Regression.tps_coefficient = 0;
     }

   denominator = n * sumX4X4 - sumX4 * sumX4;
   if(denominator != 0)
     {
      Regression.pattern_coefficient = (n * sumX4Y - sumX4 * sumY) / denominator;
     }
   else
     {
      Regression.pattern_coefficient = 0;
     }

// Calculate intercept
   Regression.intercept = meanY - Regression.pressure_coefficient * meanX1
                          - Regression.delta_coefficient * meanX2
                          - Regression.tps_coefficient * meanX3
                          - Regression.pattern_coefficient * meanX4;

// Calculate R-squared (model fit quality)
   double sumSquaredTotal = 0;
   double sumSquaredResidual = 0;

   for(int i = 0; i < MemorySize; i++)
     {
      if(memoryBuffer[i].timestamp == 0 || memoryBuffer[i].actual_dir == 0)
         continue;

      double x1 = memoryBuffer[i].pressure;
      double x2 = memoryBuffer[i].delta;
      double x3 = memoryBuffer[i].tps / 10.0;
      double x4 = (memoryBuffer[i].pattern == "Buyer Re-entry" || memoryBuffer[i].pattern == "Buyer Exhaustion") ? 1.0 :
                  (memoryBuffer[i].pattern == "Seller Exhaustion" || memoryBuffer[i].pattern == "Seller Re-entry") ? -1.0 : 0.0;
      double y = memoryBuffer[i].actual_dir;

      double predicted = Regression.intercept + Regression.pressure_coefficient * x1
                         + Regression.delta_coefficient * x2
                         + Regression.tps_coefficient * x3
                         + Regression.pattern_coefficient * x4;

      sumSquaredTotal += MathPow(y - meanY, 2);
      sumSquaredResidual += MathPow(y - predicted, 2);
     }

   Regression.r_squared = (sumSquaredTotal > 0) ? 1 - (sumSquaredResidual / sumSquaredTotal) : 0;
  }

//+------------------------------------------------------------------+
//| Compute Decision Layer - Enhanced                                |
//+------------------------------------------------------------------+
void ComputeDecisionLayer()
  {
//--- Calculate decision score with enhanced factors
   double patternSign = (CurrentPattern.name == "Buyer Re-entry") ? 1.0 :
                        (CurrentPattern.name == "Seller Exhaustion") ? -1.0 :
                        (CurrentPattern.name == "Seller Re-entry") ? -1.0 :
                        (CurrentPattern.name == "Buyer Exhaustion") ? 1.0 : 0.0;

// Enhanced decision score with correlation factors
   double correlationFactor = 1.0;
   if(EnableCorrelationAnalysis)
     {
      // Adjust weights based on correlations
      correlationFactor = 1.0 + 0.2 * Correlations.pressure_delta_corr;
     }

   double decisionScore = correlationFactor * (
                             0.4 * Forecast.score +
                             0.3 * PressureIndex +
                             0.2 * DeltaNormalized +
                             0.1 * patternSign * CurrentPattern.confidence
                          );

//--- Calculate strength
   Decision.strength = 1.0 / (1.0 + MathExp(-5.0 * decisionScore)); // Sigmoid function

//--- Determine bias
   if(decisionScore > 0.2)
     {
      Decision.bias = "Bullish";
     }
   else
      if(decisionScore < -0.2)
        {
         Decision.bias = "Bearish";
        }
      else
        {
         Decision.bias = "Neutral";
        }

//--- Calculate risk/reward ratio
   double potentialReward = MathAbs(Forecast.expected_move);
   double potentialRisk = dynamicThreshold;
   Decision.risk_reward_ratio = (potentialRisk > 0) ? potentialReward / potentialRisk : 0.0;

//--- Determine action based on risk mode and additional factors
   double threshold = 0.0;
   if(risk_mode == 0)
      threshold = 0.75;      // Conservative
   else
      if(risk_mode == 1)
         threshold = 0.6;  // Normal
      else
         threshold = 0.45;                     // Aggressive

// Adjust threshold based on volatility
   if(EnableVolatilityAnalysis)
     {
      if(Volatility.is_high_volatility)
        {
         threshold += 0.1; // Increase threshold in high volatility
        }
      else
         if(Volatility.is_low_volatility)
           {
            threshold -= 0.05; // Decrease threshold in low volatility
           }
     }

// Adjust threshold based on regression model quality
   if(UseNeuralNetwork && Regression.r_squared > 0.5)
     {
      threshold -= 0.1 * Regression.r_squared; // Decrease threshold if model is good
     }

   if(Forecast.confidence > min_confidence_to_act * 100 && Decision.strength > threshold)
     {
      if(Decision.bias == "Bullish")
        {
         Decision.action = (Decision.risk_reward_ratio > 1.5) ? "Enter Long" : "Wait (Low R/R)";
        }
      else
         if(Decision.bias == "Bearish")
           {
            Decision.action = (Decision.risk_reward_ratio > 1.5) ? "Enter Short" : "Wait (Low R/R)";
           }
         else
           {
            Decision.action = "Wait";
           }
     }
   else
      if(Forecast.confidence > 50)
        {
         Decision.action = "Prepare";
        }
      else
        {
         Decision.action = "Wait";
        }

//--- Generate rationale with enhanced information
   string correlationInfo = "";
   if(EnableCorrelationAnalysis)
     {
      correlationInfo = StringFormat(" | Corr: P/D %.2f, P/T %.2f",
                                     Correlations.pressure_delta_corr,
                                     Correlations.pressure_tps_corr);
     }

   string volatilityInfo = "";
   if(EnableVolatilityAnalysis)
     {
      volatilityInfo = StringFormat(" | Vol: %s (%.0f%%)",
                                    Volatility.is_high_volatility ? "High" :
                                    (Volatility.is_low_volatility ? "Low" : "Normal"),
                                    Volatility.volatility_percentile * 100);
     }

   Decision.rationale = StringFormat("Pressure: %.2f, ΔV: %.1f, Pattern: %s (%.0f%%)%s%s | R/R: %.2f",
                                     PressureIndex, WeightedDelta, CurrentPattern.name,
                                     CurrentPattern.confidence * 100, correlationInfo,
                                     volatilityInfo, Decision.risk_reward_ratio);
  }

//+------------------------------------------------------------------+
//| Initialize all module outputs with default values                 |
//+------------------------------------------------------------------+
void InitializeModuleOutputs()
  {
//--- Initialize Pressure Engine
   PressureIndex = 0.0;
   PressureLabel = "Neutral";

//--- Initialize Pattern Detector
   CurrentPattern.name = "None";
   CurrentPattern.confidence = 0.0;
   CurrentPattern.sequence = "";

//--- Initialize Weighted Volume Delta
   WeightedDelta = 0.0;
   DeltaNormalized = 0.0;

//--- Initialize Forecast Engine
   Forecast.score = 0.0;
   Forecast.direction = 0;
   Forecast.confidence = 0.0;
   Forecast.probability_up = 0.5;
   Forecast.probability_down = 0.5;
   Forecast.expected_move = 0.0;

//--- Initialize Tick Density Clock
   CurrentTPS = 0.0;
   TPSState = "Idle";

//--- Initialize Market Reaction Memory
   Accuracy = 0.0;
   BiasCorrection = 0.0;
   memoryComputed = false;

//--- Initialize Decision Layer
   Decision.bias = "Neutral";
   Decision.strength = 0.0;
   Decision.action = "Wait";
   Decision.rationale = "Initializing...";
   Decision.risk_reward_ratio = 0.0;

//--- Initialize Adaptive Thresholds
   currentATR = 0.0;
   dynamicThreshold = 0.0;

//--- Initialize Advanced Analytics
   Correlations.pressure_delta_corr = 0.0;
   Correlations.pressure_tps_corr = 0.0;
   Correlations.delta_tps_corr = 0.0;
   Correlations.pattern_success_corr = 0.0;

   Volatility.current_volatility = 0.0;
   Volatility.historical_avg = 0.0;
   Volatility.volatility_percentile = 0.5;
   Volatility.is_high_volatility = false;
   Volatility.is_low_volatility = false;

   Regression.intercept = 0.0;
   Regression.pressure_coefficient = 0.0;
   Regression.delta_coefficient = 0.0;
   Regression.pattern_coefficient = 0.0;
   Regression.tps_coefficient = 0.0;
   Regression.r_squared = 0.0;

//--- Seed tpsHistory to avoid avg==0 on startup
   for(int k=0; k<tpsHistorySize; k++)
      tpsHistory[k] = 1.0;
  }

//+------------------------------------------------------------------+
//| Create Panel - Creates all label objects for the dashboard       |
//+------------------------------------------------------------------+
void CreatePanel()
  {
//--- Delete existing panel objects first
   CleanUpAllObjects();

//--- Panel dimensions (increased for better spacing)
   int x = 15;
   int y = 25;
   int width = 480;  // Increased from 400
   int height = ShowAdvancedPanel ? 830 : 620; // Increased height for advanced panel

//--- Create panel background
   ObjectCreate(0, "MIPanel_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "MIPanel_BG", OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, "MIPanel_BG", OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, "MIPanel_BG", OBJPROP_XSIZE, width);
   ObjectSetInteger(0, "MIPanel_BG", OBJPROP_YSIZE, height);
   ObjectSetInteger(0, "MIPanel_BG", OBJPROP_BGCOLOR, PanelBackgroundColor);
   ObjectSetInteger(0, "MIPanel_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "MIPanel_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);

//--- Create title
   ObjectCreate(0, "MITitle", OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, "MITitle", OBJPROP_TEXT, "MARKET INTELLIGENCE v2.0");
   ObjectSetInteger(0, "MITitle", OBJPROP_XDISTANCE, x + 100);
   ObjectSetInteger(0, "MITitle", OBJPROP_YDISTANCE, y + 15);
   ObjectSetInteger(0, "MITitle", OBJPROP_COLOR, PanelTextColor);
   ObjectSetString(0, "MITitle", OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, "MITitle", OBJPROP_FONTSIZE, 14);
   ObjectSetInteger(0, "MITitle", OBJPROP_CORNER, CORNER_LEFT_UPPER);

//--- Create module labels and data fields with improved spacing
   int moduleSpacing = 70; // Increased from 60
   int dataSpacing = 18;   // Increased from 15
   int totalModules = ShowAdvancedPanel ? 11 : 8; // Add 3 advanced modules

   for(int i = 1; i <= totalModules; i++)
     {
      string moduleName = "";
      switch(i)
        {
         case 1:
            moduleName = "REACTION ENGINE 2.0";
            break;
         case 2:
            moduleName = "FLOW PATTERN DETECTOR";
            break;
         case 3:
            moduleName = "WEIGHTED VOLUME DELTA";
            break;
         case 4:
            moduleName = "CANDLE FORECAST ENGINE";
            break;
         case 5:
            moduleName = "ADAPTIVE THRESHOLDS";
            break;
         case 6:
            moduleName = "TICK DENSITY CLOCK";
            break;
         case 7:
            moduleName = "MARKET REACTION MEMORY";
            break;
         case 8:
            moduleName = "DECISION LAYER";
            break;
         case 9:
            moduleName = "CORRELATION ANALYSIS";
            break;
         case 10:
            moduleName = "VOLATILITY ANALYSIS";
            break;
         case 11:
            moduleName = "REGRESSION MODEL";
            break;
        }

      // Create module title
      ObjectCreate(0, "MIModule" + IntegerToString(i), OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "MIModule" + IntegerToString(i), OBJPROP_TEXT, IntegerToString(i) + " " + moduleName);
      ObjectSetInteger(0, "MIModule" + IntegerToString(i), OBJPROP_XDISTANCE, x + 25);
      ObjectSetInteger(0, "MIModule" + IntegerToString(i), OBJPROP_YDISTANCE, y + 50 + (i-1) * moduleSpacing);
      ObjectSetInteger(0, "MIModule" + IntegerToString(i), OBJPROP_COLOR, C'200,200,220');
      ObjectSetString(0, "MIModule" + IntegerToString(i), OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, "MIModule" + IntegerToString(i), OBJPROP_FONTSIZE, 11);
      ObjectSetInteger(0, "MIModule" + IntegerToString(i), OBJPROP_CORNER, CORNER_LEFT_UPPER);

      // Create data labels for each module (3 per module)
      for(int j = 1; j <= 3; j++)
        {
         string labelName = "MIData" + IntegerToString(i) + "_" + IntegerToString(j);
         ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
         ObjectSetString(0, labelName, OBJPROP_TEXT, "N/A"); // Changed from "Loading..." to "N/A"
         ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, x + 35);
         ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, y + 70 + (i-1) * moduleSpacing + (j-1) * dataSpacing);
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, PanelTextColor);
         ObjectSetString(0, labelName, OBJPROP_FONT, "Consolas");
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 10);
         ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        }

      // Create separator line (except for the last module) - Using OBJ_RECTANGLE_LABEL
      if(i < totalModules)
        {
         ObjectCreate(0, "MISeparator" + IntegerToString(i), OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "MISeparator" + IntegerToString(i), OBJPROP_XDISTANCE, x + 25);
         ObjectSetInteger(0, "MISeparator" + IntegerToString(i), OBJPROP_YDISTANCE, y + 45 + i * moduleSpacing);
         ObjectSetInteger(0, "MISeparator" + IntegerToString(i), OBJPROP_XSIZE, width - 50);
         ObjectSetInteger(0, "MISeparator" + IntegerToString(i), OBJPROP_YSIZE, 1);
         ObjectSetInteger(0, "MISeparator" + IntegerToString(i), OBJPROP_BGCOLOR, C'60,60,70');
         ObjectSetInteger(0, "MISeparator" + IntegerToString(i), OBJPROP_BORDER_TYPE, BORDER_FLAT);
         ObjectSetInteger(0, "MISeparator" + IntegerToString(i), OBJPROP_CORNER, CORNER_LEFT_UPPER);
        }
     }

// Force chart redraw to ensure all objects are visible
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Update Panel - Updates all label objects with current data       |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
//--- Update symbol and time
   string symbolText = StringFormat("SYMBOL: %s (%s)", _Symbol, PeriodToString(_Period));
   string timeText = StringFormat("TIME: %s  |  TPS: %.2f", TimeToString(TimeCurrent(), TIME_SECONDS), CurrentTPS);

   SafeSetText("MIData1_1", symbolText);
   SafeSetText("MIData1_2", timeText);

//--- Update Reaction Engine
   string pressureBias = (PressureIndex > 0) ? "Bullish Bias" : "Bearish Bias";
   color pressureColor = (PressureIndex > 0) ? BullishColor : BearishColor;

   SafeSetText("MIData1_3", StringFormat("Net Reaction: %+.2f (%s)", PressureIndex, pressureBias), pressureColor);

   string pressureBar = CreateProgressBar(MathAbs(PressureIndex));
   SafeSetText("MIData2_1", StringFormat("Pressure Index: %s %.1f%%", pressureBar, MathAbs(PressureIndex) * 100.0), pressureColor);

//--- Update Flow Pattern Detector
   string patternIcon = (CurrentPattern.name == "Buyer Re-entry") ? "🔼" :
                        (CurrentPattern.name == "Seller Exhaustion") ? "🔽" :
                        (CurrentPattern.name == "Spike-Bounce") ? "⚡" :
                        (CurrentPattern.name == "Seller Re-entry") ? "🔴" :
                        (CurrentPattern.name == "Buyer Exhaustion") ? "🟢" : "➖";

   SafeSetText("MIData2_2", StringFormat("Pattern: %s (%.0f%%) %s", CurrentPattern.name, CurrentPattern.confidence * 100, patternIcon));
   SafeSetText("MIData2_3", StringFormat("Sequence: %s (Tick Flow)", CurrentPattern.sequence));

//--- Update Weighted Volume Delta
   string deltaText = (WeightedDelta > 0) ? "Buy Absorption" : "Sell Absorption";
   color deltaColor = (WeightedDelta > 0) ? BullishColor : BearishColor;

   SafeSetText("MIData3_1", StringFormat("ΔV: %+.0f (%s)", WeightedDelta, deltaText), deltaColor);

   string volumeBar = CreateProgressBar(MathAbs(DeltaNormalized));
   SafeSetText("MIData3_2", StringFormat("Volume Strength: %s %.1f%%", volumeBar, MathAbs(DeltaNormalized) * 100.0));

//--- Update Candle Forecast Engine
   string forecastIcon = (Forecast.direction > 0) ? "🔼" :
                         (Forecast.direction < 0) ? "🔽" : "➖";
   string forecastText = (Forecast.direction > 0) ? "UP" :
                         (Forecast.direction < 0) ? "DOWN" : "NEUTRAL";

   SafeSetText("MIData4_1", StringFormat("Forecast: %s %s | Confidence: %.1f%%", forecastIcon, forecastText, Forecast.confidence));

   string nextDirection = (Forecast.confidence > 70) ? "Strong Signal" :
                          (Forecast.confidence > 40) ? "Evaluating..." : "Weak Signal";

   SafeSetText("MIData4_2", StringFormat("Next Direction: %s", nextDirection));

// Update with probability information
   SafeSetText("MIData4_3", StringFormat("Probabilities: Up %.0f%% | Down %.0f%% | Move %.1f pips",
                                         Forecast.probability_up * 100,
                                         Forecast.probability_down * 100,
                                         Forecast.expected_move / _Point));

//--- Update Adaptive Thresholds
   SafeSetText("MIData5_1", StringFormat("ATR(%d): %.2f | Threshold: %.2f", ATRlen, currentATR, dynamicThreshold));

   string modeText = (VolatilityScaling > 0) ? "Dynamic Sensitivity (ON)" : "Fixed Sensitivity";
   SafeSetText("MIData5_2", StringFormat("Mode: %s", modeText));

//--- Update Tick Density Clock
   string tpsIcon = (TPSState == "High") ? "⚡" :
                    (TPSState == "Idle") ? "💤" : "📊";
   string sessionText = (TPSState == "High") ? "Active Session" :
                        (TPSState == "Idle") ? "Quiet Session" : "Normal Session";

   SafeSetText("MIData6_1", StringFormat("Tick Rate: %.1f/sec (%s)", CurrentTPS, TPSState));
   SafeSetText("MIData6_2", StringFormat("Market State: %s %s", tpsIcon, sessionText));

//--- Update Market Reaction Memory
   if(memoryComputed)
     {
      SafeSetText("MIData7_1", StringFormat("Accuracy (Last %d): %.1f%%", MemorySize, Accuracy));
     }
   else
     {
      SafeSetText("MIData7_1", "Accuracy: Calculating...");
     }

   string biasText = (BiasCorrection > 0) ? "Bullish" : "Bearish";
   color biasColor = (BiasCorrection > 0) ? BullishColor : BearishColor;

   if(memoryComputed)
     {
      SafeSetText("MIData7_2", StringFormat("Bias Correction: %+.2f%% %s", BiasCorrection, biasText), biasColor);
     }
   else
     {
      SafeSetText("MIData7_2", "Bias Correction: Calculating...");
     }

//--- Update Decision Layer
   string decisionIcon = (Decision.bias == "Bullish") ? "🔼" :
                         (Decision.bias == "Bearish") ? "🔽" : "➖";

   SafeSetText("MIData8_1", StringFormat("Bias: %s %s | Strength: %.2f", decisionIcon, Decision.bias, Decision.strength));

   string actionIcon = (Decision.action == "Enter Long") ? "📈" :
                       (Decision.action == "Enter Short") ? "📉" :
                       (Decision.action == "Prepare") ? "⏳" : "⏸️";

   SafeSetText("MIData8_2", StringFormat("Suggestion: %s %s", actionIcon, Decision.action));
   SafeSetText("MIData8_3", StringFormat("R/R Ratio: %.2f", Decision.risk_reward_ratio));

//--- Update Advanced Analytics if enabled
   if(ShowAdvancedPanel)
     {
      // Correlation Analysis
      SafeSetText("MIData9_1", StringFormat("Pressure/Delta: %.2f", Correlations.pressure_delta_corr));
      SafeSetText("MIData9_2", StringFormat("Pressure/TPS: %.2f", Correlations.pressure_tps_corr));
      SafeSetText("MIData9_3", StringFormat("Pattern Success: %.2f", Correlations.pattern_success_corr));

      // Volatility Analysis
      string volState = (Volatility.is_high_volatility) ? "HIGH" :
                        (Volatility.is_low_volatility) ? "LOW" : "NORMAL";
      color volColor = (Volatility.is_high_volatility) ? Red :
                       (Volatility.is_low_volatility) ? Blue : Gray;

      SafeSetText("MIData10_1", StringFormat("Current: %.5f | Avg: %.5f", Volatility.current_volatility, Volatility.historical_avg));
      SafeSetText("MIData10_2", StringFormat("State: %s (%.0f%%)", volState, Volatility.volatility_percentile * 100), volColor);
      SafeSetText("MIData10_3", StringFormat("Ratio: %.2f", (Volatility.historical_avg > 0) ? Volatility.current_volatility / Volatility.historical_avg : 1.0));

      // Regression Model
      string modelQuality = (Regression.r_squared > 0.7) ? "EXCELLENT" :
                            (Regression.r_squared > 0.5) ? "GOOD" :
                            (Regression.r_squared > 0.3) ? "FAIR" : "POOR";
      color modelColor = (Regression.r_squared > 0.7) ? Lime :
                         (Regression.r_squared > 0.5) ? YellowGreen :
                         (Regression.r_squared > 0.3) ? Orange : Red;

      SafeSetText("MIData11_1", StringFormat("Model Quality: %s (R²=%.2f)", modelQuality, Regression.r_squared), modelColor);
      SafeSetText("MIData11_2", StringFormat("Coefficients: P=%.2f D=%.2f T=%.2f",
                                             Regression.pressure_coefficient,
                                             Regression.delta_coefficient,
                                             Regression.tps_coefficient));
      SafeSetText("MIData11_3", StringFormat("Pattern Coef: %.2f | Intercept: %.2f",
                                             Regression.pattern_coefficient,
                                             Regression.intercept));
     }

//--- Force chart redraw to ensure updates are visible
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Create Progress Bar - Returns a visual progress bar string        |
//+------------------------------------------------------------------+
string CreateProgressBar(double val)
  {
// Clamp values between 0.0 and 1.0 to prevent overflow
   val = MathMin(MathMax(val, 0.0), 1.0);

   int len = 20;
   int fill = (int)(val * len);
   string bar = "";

   for(int i = 0; i < len; i++)
     {
      bar += (i < fill ? "█" : "░");
     }

   return "[" + bar + "]";
  }

//+------------------------------------------------------------------+
//| Convert Period to String                                          |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period)
  {
   switch(period)
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
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN1";
      default:
         return "Custom";
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
