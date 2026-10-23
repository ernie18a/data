//--- Include system libraries
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Arrays\ArrayDouble.mqh>
#include <Math\Stat\Math.mqh>
#include <Hon-APS-Dashboard.mqh>
#include <Hon-NewsTrader.mqh>

//--- Input parameters
input group "=== Risk Management ==="
input double   BaseRiskPercent = 1.0;              // Base Risk % per trade
input double   MaxDailyLoss = 5.0;                 // Maximum daily loss %
input double   MaxWeeklyLoss = 10.0;               // Maximum weekly loss %
input int      MaxConcurrentPositions = 3;         // Maximum concurrent positions
input double   MaxCorrelatedExposure = 3.0;        // Maximum correlated exposure %
input bool     UseKellyCriterion = true;           // Use Kelly Criterion for sizing
input double   KellyFraction = 0.25;               // Kelly fraction (0.25 = 25% of Kelly)

input group "=== Pattern Settings ==="
input bool     TradeCupHandle = true;              // Trade Cup & Handle patterns
input bool     TradeHeadShoulders = true;          // Trade Head & Shoulders patterns
input bool     TradeDoubleBottom = true;           // Trade Double Bottom patterns
input bool     TradeRoundingBottom = true;         // Trade Rounding Bottom patterns (97% success)
input bool     TradeTriangles = true;              // Trade Triangle patterns
input bool     TradeFlags = true;                  // Trade Flag patterns
input int      MinPatternBars = 20;                // Minimum pattern formation bars
input int      MaxPatternBars = 200;               // Maximum pattern formation bars
input int      PatternAgeLimit = 10;               // Pattern age limit (bars)
input double   MinConsensusScore = 70.0;           // Minimum consensus score

input group "=== Volume Analysis ==="
input double   VolumeDeclineRatio = 0.7;           // Volume decline ratio in consolidation
input double   BreakoutVolumeMultiple = 1.5;       // Breakout volume multiplier
input int      VolumeMAperiod = 20;                // Volume moving average period
input bool     RequireVolumeConfirmation = true;   // Require volume confirmation

input group "=== Technical Confirmation ==="
input int      ADXPeriod = 14;                     // ADX Period
input double   ADXThreshold = 25.0;                // ADX Threshold
input int      RSIPeriod = 14;                     // RSI Period
input double   RSIOverbought = 70.0;               // RSI Overbought
input double   RSIOversold = 30.0;                 // RSI Oversold
input int      MACDFast = 12;                      // MACD Fast
input int      MACDSlow = 26;                      // MACD Slow
input int      MACDSignal = 9;                     // MACD Signal
input group "=== Adaptive Moving Average (KAMA) Settings ==="
input int      MA200Period = 200;                  // KAMA Period (was MA200)
input int      KAMAFastEMA = 2;                   // Fast EMA Period
input int      KAMASlowEMA = 30;                  // Slow EMA Period
input int      KAMAShift = 0;                     // KAMA Shift
input ENUM_APPLIED_PRICE KAMAPrice = PRICE_CLOSE; // Applied Price
input bool     UseKAMAFilter = true;              // Use KAMA for trend filter
input double   KAMASlopeThreshold = 10.0;         // KAMA slope threshold (basis points)        // KAMA slope threshold (basis points)
input group "=== Trade Management ==="
input bool     UsePartialProfits = true;           // Use partial profit taking
input double   PartialProfit1R = 1.0;              // First partial at R
input double   PartialPercent1 = 30.0;             // First partial %
input double   PartialProfit2R = 2.0;              // Second partial at R
input double   PartialPercent2 = 40.0;             // Second partial %
input double   TrailingActivationR = 1.5;          // Trailing activation R
input double   InitialTrailingATR = 1.0;           // Initial trailing ATR multiple
input double   TightTrailingATR = 0.5;             // Tight trailing ATR multiple
input double   TightTrailingThresholdR = 3.0;      // R threshold for tight trailing

input group "=== Advanced Settings ==="
input bool     UseMarketRegimeFilter = true;       // Use market regime filter
input bool     UseDivergenceDetection = true;      // Use divergence detection
input bool     UseOrderFlowAnalysis = true;        // Use order flow analysis
input int      SRLookback = 100;                   // Support/Resistance lookback
input double   SRZonePercent = 0.2;                // S/R zone percentage
input bool     EnableLogging = true;               // Enable detailed logging
//input string   LogFileName = "Hon-APS.log";    // Log file name

input group "=== Small Account Settings ==="
input double   MaxRiskPerTrade = 100.0;        // Maximum $ risk per trade
input double   MaxMarginPercent = 50.0;        // Maximum margin % of account
input double   MinLotSize = 0.01;              // Minimum lot size
input double   MaxLotSize = 1.0;               // Maximum lot size for small accounts
input bool     UseFixedLotSize = false;        // Use fixed lot size instead of calculated
input double   FixedLotSize = 0.01;            // Fixed lot size for small accounts
input group "=== Spread Control ==="
input double   MaxSpreadPips = 5.0;              // Maximum spread in pips (for forex)
input double   MaxSpreadPoints = 50.0;           // Maximum spread in points (for crypto/indices)
input bool     UseAdaptiveSpread = true;         // Auto-detect spread type by symbol
input bool     DisableSpreadCheck = false;      // Disable spread check entirely
input double   CryptoMaxSpread = 100.0;          // Maximum spread for crypto pairs
input double   IndexMaxSpread = 20.0;            // Maximum spread for indices
input double   ForexMaxSpread = 2.0;             // Maximum spread for forex pairs (pips)
input group "=== Stop Loss Settings ==="
input double   MinStopDistancePips = 10.0;       // Minimum stop distance in pips
input bool     RelaxStopChecks = true;           // Relax stop level checks for crypto
input group "=== Auto Stop Loss Correction ==="
input bool     AutoCorrectStops = true;          // Auto-correct invalid stop losses
input bool     UseATRStops = true;               // Use ATR for stop calculation
input double   ATRMultiplier = 2.0;              // ATR multiplier for stops
input double   MinStopPips = 15.0;               // Minimum stop distance in pips
input double   MaxStopPips = 100.0;              // Maximum stop distance in pips
input bool     UsePercentageStops = false;       // Use percentage-based stops
input double   StopPercentage = 1.5;             // Stop loss percentage from entry
input bool     UseSupportResistanceStops = true; // Adjust stops to S/R levels

input group "=== Pending Orders Settings ==="
input bool     UsePendingOrders = true;           // Use pending orders instead of market orders
input int      PendingOrderExpiry = 24;           // Pending order expiry (hours)
input double   EntryBufferPips = 0.5;             // Buffer pips beyond breakout level
input int      MaxPendingOrders = 5;              // Maximum pending orders allowed
input group "=== DOM Settings ==="
input bool     ForceDOMDisable = false;           // Force disable DOM (for incompatible brokers)
input int      MinDOMDepth = 4;                   // Minimum DOM depth required
input bool     UseEstimationOnly = false;         // Always use estimation-based order flow
input double   DOMConfidenceThreshold = 30.0;     // Minimum DOM confidence to use data
input group "=== Trend Exhaustion Settings ==="
input bool     UseExhaustionFilter = true;        // Use trend exhaustion filter
input int      MinExhaustionSignals = 3;          // Minimum exhaustion signals required
input double   MaxDistanceFromKAMA = 2.5;         // Max % distance from KAMA
input int      MaxConsecutiveBars = 7;            // Max consecutive bars before exhaustion
input bool     RequirePullbackEntry = true;       // Require pullback for exhausted trends
input double   PullbackMinDepth = 0.382;          // Minimum pullback depth (Fibonacci)
//--- Global objects and variables
CTrade trade;
CPositionInfo position;
CSymbolInfo symbol_info;
CAccountInfo account;
COrderInfo order;
long MagicNumber = 12345; // EA's magic number
bool g_logging_active = false;  // Runtime logging state

//GLOBAL DASHBOARD OBJECT
//Dashboard g_dashboard;
long g_magic_number;
static double g_high[], g_low[], g_close[];
static long g_volume[];
static datetime g_lastDataUpdate = 0;
static bool g_dataReady = false;
//--- Performance tracking
struct PerformanceData
  {
   int               totalTrades;
   int               winningTrades;
   double            totalProfit;
   double            totalGrossLoss;
   double            maxDrawdown;
   double            currentDrawdown;
   double            winRate;
   double            profitFactor;
   double            sharpeRatio;
   datetime          lastUpdate;
  };

PerformanceData performance;

//--- Pattern structure with enhanced data
struct PatternData
  {
   string            patternType;
   datetime          formationStart;
   datetime          formationEnd;
   bool              isBullish;
   double            entryPrice;
   double            stopLoss;
   double            takeProfit;
   double            patternHeight;
   double            qualityScore;
   double            volumeScore;
   double            indicatorScore;
   double            contextScore;
   double            consensusScore;
   bool              isValid;
   bool              hasVolumeConfirmation;
   bool              hasDivergence;
   int               supportResistanceAlignment;
   string            description;
  };

//--- Market structure
struct MarketStructure
  {
   double            supportLevels[];
   double            resistanceLevels[];
   string            regime;  // TRENDING_UP, TRENDING_DOWN, RANGING, VOLATILE
   double            trendStrength;
   double            volatilityLevel;
   bool              isDivergent;
   double            volumeTrend;
  };

//+------------------------------------------------------------------+
//| Enhanced Order Flow Structure with DOM Support                   |
//+------------------------------------------------------------------+
struct OrderFlowData
  {
   // Original estimation data
   double            deltaVolume[];
   double            cumulativeDelta;
   double            volumeProfile[];
   double            poc;
   double            vah;
   double            val;
   bool              deltaDivergence;
   double            buyPressure;
   double            sellPressure;
   double            largeOrdersRatio;

   // DOM-based data
   double            bidAskImbalance;    // Bid volume / Ask volume ratio
   double            orderBookPressure;  // Net order book pressure
   double            bidDepth;           // Total bid volume in DOM
   double            askDepth;           // Total ask volume in DOM
   int               strongBidLevels;       // Number of strong bid levels
   int               strongAskLevels;       // Number of strong ask levels
   double            absorptionScore;    // How well price absorbs selling/buying
   bool              isDOMAvailable;       // Whether DOM data is available
   double            domConfidence;      // Confidence in DOM data (0-100)
   MqlBookInfo       dom_book[];
  };
struct PendingOrderInfo
  {
   ulong             ticket;
   string            patternType;
   datetime          expiry;
   double            entryPrice;
   double            stopLoss;
   double            takeProfit;
   bool              isActive;
  };

PendingOrderInfo pendingOrdersList[];
struct PatternPerformance
  {
   string            patternType;
   int               totalTrades;
   int               winningTrades;
   double            totalProfit;
   double            totalLoss;
   double            avgWinAmount;
   double            avgLossAmount;
   double            successRateByRegime[4];  // TRENDING_UP, TRENDING_DOWN, RANGING, VOLATILE
   int               tradesByRegime[4];
   double            successRateByVolatility[3]; // Low, Medium, High
   int               tradesByVolatility[3];
   double            successRateByHour[24];
   int               tradesByHour[24];
   datetime          lastUpdate;
  };
struct AdaptiveWeights
  {
   double            qualityWeight;
   double            volumeWeight;
   double            indicatorWeight;
   double            contextWeight;
   double            orderFlowWeight;
   double            performanceScore;
   int               optimizationCount;
   datetime          lastOptimization;
  };

struct AdaptiveThresholds
  {
   double            cupHandleDepthMin;
   double            cupHandleDepthMax;
   double            hsShoulderTolerance;
   double            doubleBottomTolerance;
   double            triangleConvergence;
   double            flagRetracement;
   datetime          lastUpdate;
  };
//--- Global variables
PatternData activePatterns[];
MarketStructure marketStructure;
OrderFlowData orderFlow;
int fileHandle;
double dailyStartBalance;
double weeklyStartBalance;
datetime lastDailyReset;
datetime lastWeeklyReset;
int debugTickCounter = 0;
bool riskLimitsPaused = false;
datetime lastRiskCheck = 0;
PatternPerformance patternStats[];
AdaptiveWeights consensusWeights;
AdaptiveThresholds adaptiveThresholds;
double recentTradesBuffer[];
int recentTradesIndex = 0;
const int RECENT_TRADES_SIZE = 100;
//--- Indicator handles
int handle_atr, handle_adx, handle_rsi, handle_macd;
int handle_ma200, handle_volumes, handle_bbands;

//--- Forward declarations
double AnalyzeCupHandleVolume(int leftLip, int bottom, int rightLip, int breakout, const long &volume[]);
double AnalyzeHSVolume(int leftShoulder, int head, int rightShoulder, int breakout, const long &volume[]);
double AnalyzeDoubleBottomVolume(int first, int peak, int second, int breakout, const long &volume[]);
double AnalyzeRoundingBottomVolume(int left, int bottom, int right, int breakout, const long &volume[]);
double AnalyzeTriangleVolume(int start, int end, int breakout, const long &volume[]);
double AnalyzeFlagVolume(int poleStart, int flagStart, int breakout, const long &volume[]);
double CalculateTradeSize(const PatternData &pattern);
bool PreExecutionChecks(const PatternData &pattern);
void LogPositionLimits();
bool IsGoodTradingSession();
bool IsNewsTime();
void LogDebugStatus();
void HandleRiskLimitExceeded();
bool IsTradingSessionActive();
bool IsPatternScanningEnabled();
void ScanForTradingPatterns();
//+------------------------------------------------------------------+
//| Generate a unique Magic Number for this EA instance              |
//+------------------------------------------------------------------+
long GenerateUniqueMagicNumber()
  {
   long magic = 0;

// Add current time component
   magic = (long)TimeCurrent() % 100000;

// Add random component
   MathSrand((int)TimeCurrent());
   magic += MathRand() % 10000;

// Add symbol component
   for(int i = 0; i < StringLen(_Symbol); i++)
     {
      magic += (long)StringGetCharacter(_Symbol, i) * (i + 1);
     }

// Add timeframe component
   magic += (int)_Period;

// Ensure positive and within reasonable range
   magic = MathAbs(magic) % 900000 + 100000; // Between 100000-999999

   return magic;
  }
//==============================
// Add this function to your main EA file (.mq5)

//+------------------------------------------------------------------+
//| Calculate Profit/Loss for today                                  |
//+------------------------------------------------------------------+
double CalculateTodayPL()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   datetime today_start = StructToTime(dt) - (dt.hour * 3600 + dt.min * 60 + dt.sec);
   datetime today_end = today_start + 24 * 3600 - 1;

   double profit = 0;

// Select deals from today
   if(HistorySelect(today_start, today_end))
     {
      for(int i = 0; i < HistoryDealsTotal(); i++)
        {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket > 0)
           {
            // Only count deals from this EA
            if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == g_magic_number)
              {
               // Sum up profit, commission, and swap
               profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
               profit += HistoryDealGetDouble(ticket, DEAL_COMMISSION);
               profit += HistoryDealGetDouble(ticket, DEAL_SWAP);
              }
           }
        }
     }
   return profit;
  }
//+------------------------------------------------------------------+
//| Calculate Profit/Loss for the current week                       |
//+------------------------------------------------------------------+
double CalculateWeekPL()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

// Find the number of days to go back to reach Monday.
// MQL5: Sunday=0, Monday=1, ..., Saturday=6
   int days_to_monday = dt.day_of_week - 1;
   if(days_to_monday < 0) // If today is Sunday (0)
     {
      days_to_monday = 6; // Go back 6 days to find last Monday
     }

// Get the timestamp for the start of the week (Monday 00:00:00)
   datetime week_start = TimeCurrent() - (days_to_monday * 24 * 3600) - (dt.hour * 3600 + dt.min * 60 + dt.sec);
   datetime week_end = TimeCurrent(); // From start of week until now

   double profit = 0;

// Select deals from this week
   if(HistorySelect(week_start, week_end))
     {
      for(int i = 0; i < HistoryDealsTotal(); i++)
        {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket > 0)
           {
            // Only count deals from this EA's magic number
            if(HistoryDealGetInteger(ticket, DEAL_MAGIC) == g_magic_number)
              {
               // Sum up profit, commission, and swap
               profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
               profit += HistoryDealGetDouble(ticket, DEAL_COMMISSION);
               profit += HistoryDealGetDouble(ticket, DEAL_SWAP);
              }
           }
        }
     }
   return profit;
  }
//+------------------------------------------------------------------+
//| Count open positions managed by this EA                          |
//+------------------------------------------------------------------+
int CountOpenPositions()
  {
   int ea_positions = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      // Select position by index and check if it belongs to this EA
      if(position.SelectByIndex(i) && position.Magic() == g_magic_number)
        {
         ea_positions++;
        }
     }
   return ea_positions;
  }
//==================================

//+------------------------------------------------------------------+
//| Check if DOM is available for the symbol                        |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Enhanced DOM availability check with broker detection            |
//+------------------------------------------------------------------+
bool IsDOMAvailable()
  {
// First check if the broker supports DOM at all
   if(!TerminalInfoInteger(TERMINAL_MQID))
     {
      LogMessage("Broker does not support Market Depth");
      return false;
     }

// Try to get book info
   MqlBookInfo book_array[];
   bool available = MarketBookGet(_Symbol, book_array);

// Additional validation
   if(available && ArraySize(book_array) == 0)
     {
      LogMessage("DOM available but empty for " + _Symbol);
      return false;
     }

   return available;
  }
//+------------------------------------------------------------------+
//| Initialize DOM subscription                                      |
//+------------------------------------------------------------------+
bool InitializeDOM()
  {
   if(!IsDOMAvailable())
     {
      LogMessage("DOM not available for " + _Symbol);
      return false;
     }

   if(!MarketBookAdd(_Symbol))
     {
      LogMessage("Failed to subscribe to DOM for " + _Symbol);
      return false;
     }

   LogMessage("Successfully subscribed to DOM for " + _Symbol);
   return true;
  }

//+------------------------------------------------------------------+
//| Analyze DOM (Depth of Market)                                    |
//+------------------------------------------------------------------+
void AnalyzeDOMOrderFlow(OrderFlowData &flow)
  {
   MqlBookInfo book_array[];

   if(!MarketBookGet(_Symbol, book_array))
     {
      flow.isDOMAvailable = false;
      flow.domConfidence = 0;
      return;
     }

// Add minimum depth check
   if(ArraySize(book_array) < 4)   // Need at least 2 bid and 2 ask levels
     {
      flow.isDOMAvailable = true;
      flow.domConfidence = 10; // Very low confidence
      LogMessage("DOM available but insufficient depth: " + IntegerToString(ArraySize(book_array)) + " levels");
      return;
     }

   flow.isDOMAvailable = true;

// Reset DOM metrics
   flow.bidDepth = 0;
   flow.askDepth = 0;
   flow.strongBidLevels = 0;
   flow.strongAskLevels = 0;

   double totalBidVolume = 0;
   double totalAskVolume = 0;
   double weightedBidPrice = 0;
   double weightedAskPrice = 0;

// Analyze each level in the DOM
   for(int i = 0; i < ArraySize(book_array); i++)
     {
      if(book_array[i].type == BOOK_TYPE_BUY || book_array[i].type == BOOK_TYPE_BUY_MARKET)
        {
         totalBidVolume += (double)book_array[i].volume;
         weightedBidPrice += book_array[i].price * (double)book_array[i].volume;
         flow.bidDepth += (double)book_array[i].volume;

         // Check for strong bid levels (large volume concentrations)
         if(book_array[i].volume > GetAverageBookVolume() * 2.0)
           {
            flow.strongBidLevels++;
           }
        }
      else
         if(book_array[i].type == BOOK_TYPE_SELL || book_array[i].type == BOOK_TYPE_SELL_MARKET)
           {
            totalAskVolume += (double)book_array[i].volume;
            weightedAskPrice += book_array[i].price * (double)book_array[i].volume;
            flow.askDepth += (double)book_array[i].volume;

            // Check for strong ask levels
            if(book_array[i].volume > GetAverageBookVolume() * 2.0)
              {
               flow.strongAskLevels++;
              }
           }
     }

// Calculate bid/ask imbalance
   if(totalAskVolume > 0)
     {
      flow.bidAskImbalance = totalBidVolume / totalAskVolume;
     }
   else
     {
      flow.bidAskImbalance = totalBidVolume > 0 ? 2.0 : 1.0;
     }

// Calculate order book pressure
   flow.orderBookPressure = (totalBidVolume - totalAskVolume) / (totalBidVolume + totalAskVolume + 1);

// Calculate DOM confidence based on depth
   int totalLevels = ArraySize(book_array);
   flow.domConfidence = MathMin(100.0, totalLevels * 10.0); // More levels = more confidence

// Adjust confidence based on volume
   if(totalBidVolume + totalAskVolume < GetMinimumBookVolume())
     {
      flow.domConfidence *= 0.5; // Low volume reduces confidence
     }

   LogMessage(StringFormat("DOM Analysis: Bid/Ask Imbalance=%.2f, Pressure=%.2f, Confidence=%.1f%%",
                           flow.bidAskImbalance, flow.orderBookPressure, flow.domConfidence));
  }
//+------------------------------------------------------------------+
//| Calculate DOM score based on order flow data                     |
//+------------------------------------------------------------------+
double CalculateDOMScore(const OrderFlowData &flow, bool isBullishPattern)
  {
   double score = 50.0; // Base score

// Bid/Ask imbalance scoring
   if(isBullishPattern)
     {
      if(flow.bidAskImbalance > 1.2)
         score += 15;
      if(flow.bidAskImbalance > 1.5)
         score += 10;
      if(flow.orderBookPressure > 0.2)
         score += 15;
      if(flow.strongBidLevels > flow.strongAskLevels)
         score += 10;
     }
   else
     {
      if(flow.bidAskImbalance < 0.8)
         score += 15;
      if(flow.bidAskImbalance < 0.5)
         score += 10;
      if(flow.orderBookPressure < -0.2)
         score += 15;
      if(flow.strongAskLevels > flow.strongBidLevels)
         score += 10;
     }

// Absorption scoring
   if(flow.absorptionScore > 70)
     {
      score += 15;
     }

   return MathMin(100.0, score);
  }
//+------------------------------------------------------------------+
//| Enhanced Order Flow Analysis combining DOM and estimation        |
//+------------------------------------------------------------------+
double AnalyzeEnhancedOrderFlow(int startBar, int endBar, bool isBullishPattern)
  {
   OrderFlowData enhancedFlow;

// First, perform the original estimation-based analysis
   double estimationScore = AnalyzeOrderFlow(startBar, endBar, isBullishPattern);

// Then, analyze DOM if available
   AnalyzeDOMOrderFlow(enhancedFlow);

// Calculate absorption score
   CalculateAbsorptionScore(enhancedFlow);

// Combine scores based on availability and confidence
   double finalScore = 50.0; // Base score

   if(enhancedFlow.isDOMAvailable && enhancedFlow.domConfidence > 30)
     {
      // Weight DOM analysis based on confidence
      double domWeight = enhancedFlow.domConfidence / 100.0;
      double estimationWeight = 1.0 - domWeight * 0.5; // DOM doesn't completely replace estimation

      // Calculate DOM score
      double domScore = CalculateDOMScore(enhancedFlow, isBullishPattern);

      // Combine DOM and estimation scores
      finalScore = (domScore * domWeight + estimationScore * estimationWeight) /
                   (domWeight + estimationWeight);

      LogMessage(StringFormat("Enhanced Order Flow: DOM Score=%.1f, Estimation Score=%.1f, Final=%.1f",
                              domScore, estimationScore, finalScore));
     }
   else
     {
      // No DOM available, use estimation only
      finalScore = estimationScore;
      LogMessage("Using estimation-based order flow only (DOM not available)");
     }

   return MathMin(100.0, MathMax(0.0, finalScore));
  }
//+------------------------------------------------------------------+
//| Detect broker type and capabilities                              |
//+------------------------------------------------------------------+
string DetectBrokerCapabilities()
  {
   string brokerName = AccountInfoString(ACCOUNT_COMPANY);
   string capabilities = "STANDARD";

// Known brokers with good DOM support
   if(StringFind(brokerName, "Interactive Brokers") >= 0 ||
      StringFind(brokerName, "AMP") >= 0 ||
      StringFind(brokerName, "NinjaTrader") >= 0)
     {
      capabilities = "FULL_DOM";
     }
// Brokers with limited or no DOM
   else
      if(StringFind(brokerName, "Oanda") >= 0 ||
         StringFind(brokerName, "FXCM") >= 0 ||
         StringFind(brokerName, "Pepperstone") >= 0 ||
         StringFind(brokerName, "IC Markets") >= 0)
        {
         capabilities = "NO_DOM";
        }

   LogMessage("Broker: " + brokerName + " - Capabilities: " + capabilities);
   return capabilities;
  }
//+------------------------------------------------------------------+
//| Calculate absorption score from DOM                              |
//+------------------------------------------------------------------+
void CalculateAbsorptionScore(OrderFlowData &flow)
  {
   static double previousBidDepth = 0;
   static double previousAskDepth = 0;
   static double previousPrice = 0;

   double currentPrice = symbol_info.Bid();

   if(previousPrice == 0)
     {
      previousPrice = currentPrice;
      previousBidDepth = flow.bidDepth;
      previousAskDepth = flow.askDepth;
      flow.absorptionScore = 50;
      return;
     }

// Calculate absorption based on price movement vs volume changes
   double priceChange = currentPrice - previousPrice;
   double bidDepthChange = flow.bidDepth - previousBidDepth;
   double askDepthChange = flow.askDepth - previousAskDepth;

   flow.absorptionScore = 50; // Neutral

   if(priceChange > 0)
     {
      // Price went up
      if(askDepthChange < 0 && MathAbs(askDepthChange) > flow.askDepth * 0.1)
        {
         // Asks were absorbed (bullish)
         flow.absorptionScore = 70 + MathMin(30, MathAbs(askDepthChange) / flow.askDepth * 100);
        }
     }
   else
      if(priceChange < 0)
        {
         // Price went down
         if(bidDepthChange < 0 && MathAbs(bidDepthChange) > flow.bidDepth * 0.1)
           {
            // Bids were absorbed (bearish)
            flow.absorptionScore = 30 - MathMin(30, MathAbs(bidDepthChange) / flow.bidDepth * 100);
           }
        }

// Update previous values
   previousPrice = currentPrice;
   previousBidDepth = flow.bidDepth;
   previousAskDepth = flow.askDepth;
  }

//+------------------------------------------------------------------+
//| Get average book volume for comparison                          |
//+------------------------------------------------------------------+
double GetAverageBookVolume()
  {
   static double avgVolume = 0;
   static datetime lastUpdate = 0;

   if(TimeCurrent() - lastUpdate > 60)   // Update every minute
     {
      MqlBookInfo book_array[];
      if(MarketBookGet(_Symbol, book_array))
        {
         double totalVolume = 0;
         int count = 0;

         for(int i = 0; i < ArraySize(book_array); i++)
           {
            totalVolume += (double)book_array[i].volume;
            count++;
           }

         if(count > 0)
           {
            avgVolume = totalVolume / count;
           }
        }
      lastUpdate = TimeCurrent();
     }

   return avgVolume > 0 ? avgVolume : 100; // Default fallback
  }

//+------------------------------------------------------------------+
//| Get minimum book volume threshold                               |
//+------------------------------------------------------------------+
double GetMinimumBookVolume()
  {
// This should be adjusted based on the symbol and market
// For major forex pairs, might be 1000
// For crypto, might be 10
// For indices, might be 100

   if(IsCryptoSymbol())
     {
      return 10;
     }
   else
      if(StringFind(_Symbol, "US30") >= 0 || StringFind(_Symbol, "NAS") >= 0)
        {
         return 100;
        }
      else
        {
         return 1000; // Forex default
        }
  }

//+------------------------------------------------------------------+
//| OnBookEvent handler for real-time DOM updates                   |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
   if(symbol != _Symbol)
      return;

// You can perform real-time DOM analysis here
// For example, detect large orders hitting the book
// or sudden changes in bid/ask imbalance

   static datetime lastDOMAnalysis = 0;
   if(TimeCurrent() - lastDOMAnalysis >= 1)   // Analyze every second
     {
      OrderFlowData realtimeFlow;
      AnalyzeDOMOrderFlow(realtimeFlow);

      // Detect significant changes
      static double lastImbalance = 1.0;
      double imbalanceChange = MathAbs(realtimeFlow.bidAskImbalance - lastImbalance);

      if(imbalanceChange > 0.3)
        {
         LogMessage(StringFormat("Significant DOM change detected! Imbalance: %.2f -> %.2f",
                                 lastImbalance, realtimeFlow.bidAskImbalance));
        }

      lastImbalance = realtimeFlow.bidAskImbalance;
      lastDOMAnalysis = TimeCurrent();
     }
  }

//+------------------------------------------------------------------+
//| Modified CalculateAdaptiveConsensusScore to use enhanced flow   |
//+------------------------------------------------------------------+
double CalculateAdaptiveConsensusScoreWithDOM(PatternData &pattern)
  {
// Get the original consensus score
   double baseScore = CalculateAdaptiveConsensusScore(pattern);

// If UseOrderFlowAnalysis is enabled, use enhanced analysis
   if(UseOrderFlowAnalysis)
     {
      int startBar = iBarShift(_Symbol, PERIOD_CURRENT, pattern.formationStart);
      int endBar = iBarShift(_Symbol, PERIOD_CURRENT, pattern.formationEnd);

      if(startBar > 0 && endBar >= 0 && startBar > endBar)
        {
         // Use enhanced order flow with DOM
         double enhancedFlowScore = AnalyzeEnhancedOrderFlow(startBar, endBar, pattern.isBullish);

         // Replace the order flow component with enhanced score
         double adjustedScore = baseScore * (1.0 - consensusWeights.orderFlowWeight) +
                                enhancedFlowScore * consensusWeights.orderFlowWeight;

         return MathMin(100.0, MathMax(0.0, adjustedScore));
        }
     }

   return baseScore;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RefineEntryWithDOM(double originalEntry, bool isBullish)
  {
   if(!IsDOMAvailable())
      return originalEntry;

   OrderFlowData flow;
   AnalyzeDOMOrderFlow(flow);

   if(!flow.isDOMAvailable || flow.domConfidence < 50)
      return originalEntry;

// If strong bid support for bullish trades
   if(isBullish && flow.strongBidLevels > flow.strongAskLevels)
     {
      // Consider entering slightly lower at strong bid level
      // Implementation depends on your strategy
     }

   return originalEntry;
  }
//==================================
//+------------------------------------------------------------------+
//| Enhanced OnTimer with Dashboard Updates                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   static int timerCount = 0;
   timerCount++;

// Prepare enhanced dashboard data
   DashboardData data;
   if(UseOrderFlowAnalysis)
     {
      MarketBookGet(_Symbol, data.dom_book);
     }


// --- Calculate total lots of open positions ---
   double total_lots = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(position.SelectByIndex(i) && position.Magic() == g_magic_number)
        {
         total_lots += position.Volume();
        }
     }
   data.total_lots = total_lots; //
// Basic status
   data.is_trading_allowed = account.TradeAllowed();
   data.is_paused = riskLimitsPaused;
   data.symbol = _Symbol;
   data.is_emergency_stop = false;

// Account information
   data.balance = account.Balance();
   data.equity = account.Equity();
   data.free_margin = account.FreeMargin();
   data.margin_level = account.MarginLevel();
   data.floating_pl = account.Profit();
   data.today_pl = CalculateTodayPL();    // Implement this
   data.week_pl = CalculateWeekPL();      // Implement this

// Market analysis
   data.market_regime = marketStructure.regime;
   data.kama_trend = GetKAMATrend();
   data.spread_points = (int)symbol_info.Spread();
   data.volatility_level = marketStructure.volatilityLevel;
   data.active_patterns = ArraySize(activePatterns);
   data.market_state = "ACTIVE";
   data.trend_strength = marketStructure.trendStrength;

// Performance
   data.win_rate = performance.winRate;
   data.profit_factor = performance.profitFactor;
   data.total_trades = performance.totalTrades;
   data.sharpe_ratio = CalculateRecentSharpe(30);
   data.current_drawdown = CalculateRecentDrawdown();

// Risk management
   data.daily_loss_pct = (dailyStartBalance > 0) ? (dailyStartBalance - account.Equity()) / dailyStartBalance * 100.0 : 0.0;
   data.max_daily_loss_pct = MaxDailyLoss;
   data.weekly_loss_pct = (weeklyStartBalance > 0) ? (weeklyStartBalance - account.Equity()) / weeklyStartBalance * 100.0 : 0.0;
   data.max_weekly_loss_pct = MaxWeeklyLoss;
   data.open_positions = CountOpenPositions();
   data.max_positions = MaxConcurrentPositions;
   data.adaptive_risk_pct = GetAdaptiveRiskPercent();

// News trading integration
   if(EnableNewsTrading)
     {
      NewsDataForDashboard news_data = g_news_trader.GetDashboardData();
      data.news_trading_active = news_data.is_active;
      data.news_trading_halted = news_data.trading_halted;
      data.next_news_currency = news_data.next_news_currency;
      data.next_news_title = news_data.next_news_title;
      data.minutes_to_news = news_data.minutes_to_next_news;
      data.news_impact_level = news_data.news_impact_level;
      data.news_daily_risk_pct = news_data.daily_risk_used_pct;
      data.news_positions = news_data.active_news_positions;
      data.news_pending_orders = news_data.pending_news_orders;
      data.news_status = news_data.trading_status;
     }
// Update DOM data in dashboard
   if(UseOrderFlowAnalysis)
     {
      MqlBookInfo dom_data[];
      if(MarketBookGet(_Symbol, dom_data) && ArraySize(dom_data) > 0)
        {
         // Copy DOM data to dashboard data structure
         ArrayResize(data.dom_book, ArraySize(dom_data));
         for(int i = 0; i < ArraySize(dom_data); i++)
           {
            data.dom_book[i] = dom_data[i];
           }
        }
     }
//--- Update pullback zones every 30 seconds (6 timer calls)
   if(UseExhaustionFilter && timerCount % 6 == 0)
     {
      DrawPullbackZones();
     }
// Update the beautiful dashboard
   g_beautiful_dashboard.Update(data);
// Save adaptive data less frequently (every 2 minutes)
   if(timerCount % 24 == 0)
     {
      SaveAdaptiveData();
     }
  }
//=============================================

// Comprehensive input validation function
bool ValidateAllInputParameters()
  {
   bool valid = true;

// Risk parameters
   if(BaseRiskPercent <= 0 || BaseRiskPercent > 10)
     {
      Print("ERROR: BaseRiskPercent must be between 0 and 10, current: ", BaseRiskPercent);
      valid = false;
     }

   if(MaxDailyLoss <= 0 || MaxDailyLoss > 50)
     {
      Print("ERROR: MaxDailyLoss must be between 0 and 50, current: ", MaxDailyLoss);
      valid = false;
     }

   if(MaxConcurrentPositions <= 0 || MaxConcurrentPositions > 20)
     {
      Print("ERROR: MaxConcurrentPositions must be between 1 and 20, current: ", MaxConcurrentPositions);
      valid = false;
     }

// Pattern parameters
   if(MinPatternBars <= 0 || MinPatternBars > MaxPatternBars)
     {
      Print("ERROR: Invalid pattern bar settings");
      valid = false;
     }

   if(MinConsensusScore <= 0 || MinConsensusScore > 100)
     {
      Print("ERROR: MinConsensusScore must be between 0 and 100, current: ", MinConsensusScore);
      valid = false;
     }

   return valid;
  }
//+------------------------------------------------------------------+
//| Monitor DOM health and availability                              |
//+------------------------------------------------------------------+
void MonitorDOMHealth()
  {
   static datetime lastDOMCheck = 0;
   static int domFailures = 0;

   if(TimeCurrent() - lastDOMCheck < 60)
      return; // Check every minute
   lastDOMCheck = TimeCurrent();

   if(UseOrderFlowAnalysis && !ForceDOMDisable)
     {
      MqlBookInfo book[];
      if(!MarketBookGet(_Symbol, book) || ArraySize(book) < MinDOMDepth)
        {
         domFailures++;

         if(domFailures > 5)
           {
            LogMessage("DOM repeatedly unavailable - consider disabling UseOrderFlowAnalysis");
            // Optionally auto-disable after repeated failures
            // UseOrderFlowAnalysis = false;
           }
        }
      else
        {
         domFailures = 0; // Reset on success
        }
     }
  }
//=====================================================
//+------------------------------------------------------------------+
//| Log debug status information                                     |
//+------------------------------------------------------------------+
void LogDebugStatus()
  {
   static int debugCallCount = 0;
   debugCallCount++;

   LogMessage("=== DEBUG STATUS #" + IntegerToString(debugCallCount) + " ===");
   LogMessage("SETTINGS: MinConsensus=" + DoubleToString(MinConsensusScore, 1) +
              ", MaxPos=" + IntegerToString(MaxConcurrentPositions) +
              ", Risk=" + DoubleToString(BaseRiskPercent, 1) + "%");
   LogMessage("ACCOUNT: Bal=" + DoubleToString(account.Balance(), 2) +
              ", Eq=" + DoubleToString(account.Equity(), 2) +
              ", Margin=" + DoubleToString(account.Margin(), 2));
   LogMessage("PRICES: " + DoubleToString(symbol_info.Bid(), 5) + "/" +
              DoubleToString(symbol_info.Ask(), 5) +
              " Spread=" + DoubleToString(symbol_info.Spread() * symbol_info.Point(), 5));
  }

//+------------------------------------------------------------------+
//| Handle risk limit exceeded situation                             |
//+------------------------------------------------------------------+
void HandleRiskLimitExceeded()
  {
   if(!riskLimitsPaused)
     {
      riskLimitsPaused = true;
      LogMessage("RISK ALERT: Trading paused - limits exceeded");

      // Send notification if available
      string alertMsg = "Hon-APS: Risk limits exceeded - trading paused";
      Alert(alertMsg);
      SendNotification(alertMsg);
     }

   Comment("⚠️ RISK LIMITS EXCEEDED - Trading Paused until Reset");
   ManageOpenPositions();
  }

//+------------------------------------------------------------------+
//| Check if trading session is active                               |
//+------------------------------------------------------------------+
bool IsTradingSessionActive()
  {
//--- Check basic trading permissions
   if(!account.TradeAllowed())
     {
      LogMessage("Trading not allowed on account");
      return false;
     }

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      LogMessage("Trading not allowed in terminal");
      return false;
     }

//--- Check market hours
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

// Weekend check
   if(dt.day_of_week == 0 || dt.day_of_week == 6)
     {
      return false;
     }

// Friday evening check
   if(dt.day_of_week == 5 && dt.hour >= 21)
     {
      return false;
     }

//--- Check spread conditions (if spread checking is enabled)
   if(!DisableSpreadCheck)
     {
      double currentSpread = symbol_info.Spread() * symbol_info.Point();
      double maxSpread = MaxSpreadPoints * symbol_info.Point();

      if(currentSpread > maxSpread)
        {
         return false;
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Check if pattern scanning is enabled                             |
//+------------------------------------------------------------------+
bool IsPatternScanningEnabled()
  {
   return (TradeCupHandle || TradeHeadShoulders || TradeDoubleBottom ||
           TradeRoundingBottom || TradeTriangles || TradeFlags);
  }

//+------------------------------------------------------------------+
//| Scan for all enabled trading patterns                            |
//+------------------------------------------------------------------+
void ScanForTradingPatterns()
  {
//--- Clear old patterns first
   CleanupOldPatterns();

//--- Check if we have too many active patterns
   int currentPatterns = ArraySize(activePatterns);
   if(currentPatterns >= 20)   // Reasonable limit
     {
      LogMessage("Pattern limit reached (" + IntegerToString(currentPatterns) + ") - skipping new scans");
      return;
     }

//--- Scan for each enabled pattern type
   if(TradeCupHandle)
     {
      ScanCupAndHandlePatterns();
     }

   if(TradeHeadShoulders)
     {
      ScanHeadAndShouldersPatterns();
     }

   if(TradeDoubleBottom)
     {
      ScanDoubleBottomPatterns();
     }

   if(TradeRoundingBottom)
     {
      ScanRoundingBottomPatterns();
     }

   if(TradeTriangles)
     {
      ScanTrianglePatterns();
     }

   if(TradeFlags)
     {
      ScanFlagPatterns();
     }

//--- Log new patterns found
   int newPatterns = ArraySize(activePatterns) - currentPatterns;
   if(newPatterns > 0)
     {
      LogMessage("Pattern scan complete: " + IntegerToString(newPatterns) + " new patterns found");
     }
  }
//====================================================
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("=== Hon-APS EA Initialization Started ===");

//--- Comprehensive input validation
   if(!ValidateAllInputParameters())
     {
      Print("ERROR: Input parameter validation failed");
      return INIT_PARAMETERS_INCORRECT;
     }

//--- Initialize symbol
   if(!symbol_info.Name(_Symbol))
     {
      Print("FATAL: Failed to initialize symbol: ", _Symbol);
      return INIT_FAILED;
     }
   Print("Symbol initialized: ", _Symbol);

//--- Generate unique magic number and setup trade object
   long uniqueMagicNumber = GenerateUniqueMagicNumber();
   trade.SetExpertMagicNumber(uniqueMagicNumber);
   trade.SetDeviationInPoints(10);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   trade.SetTypeFillingBySymbol(_Symbol);

   g_magic_number = uniqueMagicNumber;
   Print("Trade object initialized with Magic Number: ", uniqueMagicNumber);

//--- Initialize indicators
   Print("Creating indicators...");
   handle_atr = iATR(_Symbol, PERIOD_CURRENT, 14);
   handle_adx = iADX(_Symbol, PERIOD_CURRENT, ADXPeriod);
   handle_rsi = iRSI(_Symbol, PERIOD_CURRENT, RSIPeriod, PRICE_CLOSE);
   handle_macd = iMACD(_Symbol, PERIOD_CURRENT, MACDFast, MACDSlow, MACDSignal, PRICE_CLOSE);
   handle_ma200 = iAMA(_Symbol, PERIOD_CURRENT, MA200Period, KAMAFastEMA, KAMASlowEMA, KAMAShift, KAMAPrice);
   handle_volumes = iVolumes(_Symbol, PERIOD_CURRENT, VOLUME_REAL);
   handle_bbands = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);

//--- Enhanced indicator validation
   if(handle_atr == INVALID_HANDLE || handle_adx == INVALID_HANDLE ||
      handle_rsi == INVALID_HANDLE || handle_macd == INVALID_HANDLE ||
      handle_ma200 == INVALID_HANDLE || handle_volumes == INVALID_HANDLE ||
      handle_bbands == INVALID_HANDLE)
     {

      Print("FATAL: Failed to create indicator handles:");
      if(handle_atr == INVALID_HANDLE)
         Print("- ATR handle failed");
      if(handle_adx == INVALID_HANDLE)
         Print("- ADX handle failed");
      if(handle_rsi == INVALID_HANDLE)
         Print("- RSI handle failed");
      if(handle_macd == INVALID_HANDLE)
         Print("- MACD handle failed");
      if(handle_ma200 == INVALID_HANDLE)
         Print("- KAMA handle failed");
      if(handle_volumes == INVALID_HANDLE)
         Print("- Volume handle failed");
      if(handle_bbands == INVALID_HANDLE)
         Print("- Bollinger Bands handle failed");

      return INIT_FAILED;
     }
   Print("All indicators created successfully");
//--- FORCE TERMINAL LOGGING
   g_logging_active = true;  // Enable logging
   Print("=== Hon-APS EA STARTING - TERMINAL LOGGING ENABLED ===");
   Print("Symbol: ", _Symbol, " Period: ", _Period);
   Print("Build Date: ", __DATETIME__);
//--- Initialize logging with enhanced error handling
   if(g_logging_active)
     {
      string uniqueLogFileName = "Hon-APS_Log_" + _Symbol + "_" + EnumToString(_Period) + ".log";
      fileHandle = FileOpen(uniqueLogFileName, FILE_WRITE|FILE_TXT|FILE_ANSI);

      if(fileHandle == INVALID_HANDLE)
        {
         int error = GetLastError();
         Print("WARNING: Failed to open log file (", error, "). Continuing without file logging.");
         g_logging_active = false;
        }
      else
        {
         LogMessage("=== Hon-APS EA Log Started ===");
         LogMessage("Symbol: " + _Symbol + ", Magic: " + IntegerToString(uniqueMagicNumber));
        }
     }

//--- Initialize subsystems
   InitializeAdaptiveSystems();
   LogMessage("Adaptive systems initialized");

//--- Initialize News Trading System
   if(EnableNewsTrading)
     {
      if(!g_news_trader.Initialize(_Symbol, uniqueMagicNumber))
        {
         LogMessage("WARNING: News trading system failed to initialize - continuing without it");
        }
      else
        {
         LogMessage("News trading system initialized successfully");
        }
     }

//--- Initialize risk tracking
   dailyStartBalance = account.Balance();
   weeklyStartBalance = account.Balance();
   lastDailyReset = TimeCurrent();
   lastWeeklyReset = TimeCurrent();
   riskLimitsPaused = false;
   lastRiskCheck = 0;

//--- Handle backtesting scenarios
   if(MQLInfoInteger(MQL_TESTER))
     {
      double currentEquity = account.Equity();
      double currentBalance = account.Balance();

      if(currentEquity < currentBalance * 0.95)
        {
         LogMessage("Backtest: Adjusting for existing unrealized losses");
         dailyStartBalance = currentEquity;
         weeklyStartBalance = currentEquity;
        }
     }

//--- Initialize performance tracking
   LoadPerformanceData();

//--- Startup validation
   PerformStartupValidation();

//--- Initialize dashboard
   if(!g_beautiful_dashboard.Init(g_magic_number))
     {
      Print("Beautiful Dashboard initialization failed!");
      return INIT_FAILED;
     }

//--- Setup timer with proper management
   EventKillTimer();
   if(!EventSetTimer(5))
     {
      LogMessage("WARNING: Failed to set timer");
     }
   else
     {
      LogMessage("Timer set (5 second intervals)");
     }
// After successful DOM initialization
   if(UseOrderFlowAnalysis)
     {
      LogMessage("Order Flow Analysis ENABLED - Checking DOM availability...");
      if(InitializeDOM())
        {
         LogMessage("DOM analysis enabled for enhanced order flow");
         LogMessage("DOM successfully subscribed for " + _Symbol);
        }
      else
        {
         LogMessage("DOM not available - using estimation-based order flow");
         LogMessage("Symbol " + _Symbol + " does not support market depth");
        }
     }
   else
     {
      LogMessage("Order Flow Analysis DISABLED in settings");
     }
// Enhanced DOM initialization with broker detection
   if(UseOrderFlowAnalysis && !ForceDOMDisable)
     {
      string brokerCaps = DetectBrokerCapabilities();

      if(brokerCaps == "NO_DOM")
        {
         LogMessage("WARNING: Your broker (" + AccountInfoString(ACCOUNT_COMPANY) +
                    ") typically doesn't support DOM. Using estimation-based order flow.");
         // Don't try to initialize DOM for known incompatible brokers
        }
      else
        {
         LogMessage("Order Flow Analysis ENABLED - Checking DOM availability...");
         if(InitializeDOM())
           {
            LogMessage("DOM successfully initialized for " + _Symbol);

            // Test DOM depth
            MqlBookInfo test_book[];
            if(MarketBookGet(_Symbol, test_book))
              {
               LogMessage("DOM depth available: " + IntegerToString(ArraySize(test_book)) + " levels");
               if(ArraySize(test_book) < MinDOMDepth)
                 {
                  LogMessage("WARNING: DOM depth below minimum threshold");
                 }
              }
           }
         else
           {
            LogMessage("DOM not available - using estimation-based order flow");
            LogMessage("This is normal for many forex brokers and symbols");
           }
        }
     }
   else
     {
      LogMessage("Order Flow Analysis DISABLED in settings");
     }

//--- Final status
   LogMessage(StringFormat("Risk Management: Daily %.1f%%, Weekly %.1f%%",
                           MaxDailyLoss, MaxWeeklyLoss));

   if(UseOrderFlowAnalysis)
     {
      if(InitializeDOM())
        {
         LogMessage("DOM analysis enabled for enhanced order flow");
        }
      else
        {
         LogMessage("DOM not available - using estimation-based order flow");
        }
     }
// After successful DOM initialization
   if(UseOrderFlowAnalysis)
     {
      if(InitializeDOM())
        {
         LogMessage("DOM analysis enabled for enhanced order flow");
         // Enable book event notifications
         EventSetMillisecondTimer(100); // For real-time updates if needed
        }
      else
        {
         LogMessage("DOM not available - using estimation-based order flow");
        }
     }
//--- Draw pullback zones on startup
   if(UseExhaustionFilter)
     {
      DrawPullbackZones();
      LogMessage("Pullback zones drawn on chart");
     }
   Print("=== Hon-APS EA Initialization Complete ===");
   Print("Status: READY FOR TRADING");
   DebugInputParameters();
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Save performance data
   SavePerformanceData();

//--- Close log file
   if(fileHandle != INVALID_HANDLE)
     {
      FileClose(fileHandle);
     }
//--- Clean up pullback zone objects
   ObjectDelete(0, "KAMA_Line");
   ObjectDelete(0, "Fib_0.236");
   ObjectDelete(0, "Fib_0.382");
   ObjectDelete(0, "Fib_0.500");
   ObjectDelete(0, "Fib_0.618");
   ObjectDelete(0, "Fib_0.786");
//--- Release indicators
   IndicatorRelease(handle_atr);
   IndicatorRelease(handle_adx);
   IndicatorRelease(handle_rsi);
   IndicatorRelease(handle_macd);
   IndicatorRelease(handle_ma200);
   IndicatorRelease(handle_volumes);
   IndicatorRelease(handle_bbands);
   SaveAdaptiveData();
   LogMessage("Adaptive data saved");
   if(UseOrderFlowAnalysis)
     {
      MarketBookRelease(_Symbol);
     }
// !!! DEINITIALIZE DASHBOARD !!!
   g_beautiful_dashboard.Deinit();
// Clean up news trader objects
   g_news_trader.Cleanup();

// Clean up ALL chart objects created by this EA
   ObjectsDeleteAll(0, "NewsLine_");
   ObjectsDeleteAll(0, "SR_");
   ObjectsDeleteAll(0, "beautiful_aps_");

   ChartRedraw();

   Comment("");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- New bar detection with counters

   static bool firstTick = true;
   if(firstTick)
     {
      Print("=== FIRST TICK RECEIVED ===");
      Print("Account Balance: ", account.Balance());
      Print("Symbol: ", _Symbol);
      Print("Spread: ", symbol_info.Spread());
      firstTick = false;
     }
   static datetime lastBarTime = 0;
   static int newBarCounter = 0;
   static datetime lastDebugTime = 0;
   static datetime lastMarketUpdate = 0;

   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(lastBarTime == currentBarTime)
      return;
   lastBarTime = currentBarTime;
   newBarCounter++;
// Add this once at the beginning of OnTick
   static bool domStatusLogged = false;
   if(!domStatusLogged && UseOrderFlowAnalysis)
     {
      LogMessage("DOM Available: " + (IsDOMAvailable() ? "YES" : "NO"));
      domStatusLogged = true;
     }
//--- Debug logging (throttled)
   datetime currentTime = TimeCurrent();
   if((newBarCounter % 20 == 0) || (currentTime - lastDebugTime > 300))
     {
      LogDebugStatus();
      lastDebugTime = currentTime;
     }

//--- Price monitoring for stability
   MonitorPrices();

//--- Critical checks (every bar)
   CheckEmergencyShutdown();

//--- News trading integration
   if(EnableNewsTrading)
     {
      g_news_trader.OnTick();

      if(!g_news_trader.IsTradingAllowed())
        {
         Comment("🔴 TRADING HALTED: " + g_news_trader.GetTradingStatus());
         ManageOpenPositions();
         return;
        }
     }

//--- Market structure update (optimized frequency)
   if(currentTime - lastMarketUpdate > 300)   // Every 5 minutes
     {
      UpdateMarketStructure();
      lastMarketUpdate = currentTime;
     }

//--- Risk management
   bool riskOK = CheckRiskLimits();
   if(!riskOK)
     {
      HandleRiskLimitExceeded();
      return;
     }
   else
     {
      if(riskLimitsPaused)
        {
         riskLimitsPaused = false;
         LogMessage("✅ Risk limits reset - trading resumed");
         SendNotification("Hon-APS: Trading resumed - risk limits reset");
        }
     }

//--- Trading session validation
   if(!IsTradingSessionActive())
     {
      Comment("⏰ Outside trading hours or poor conditions");
      ManageOpenPositions();
      return;
     }

//--- Pattern analysis and trading
   if(IsPatternScanningEnabled())
     {
      ScanForTradingPatterns();

      if(ArraySize(activePatterns) > 0)
        {
         EvaluateAndExecutePatterns();
        }
     }

//--- Position management (always run)
   ManageOpenPositions();


//--- Status comment
   string status = StringFormat("🟢 Hon-APS Active | Bar #%d | Patterns: %d | Positions: %d",
                                newBarCounter, ArraySize(activePatterns), PositionsTotal());
//Comment(status);
  }
//=======================================
void DebugInputParameters()
  {
   LogMessage("=== INPUT PARAMETERS DEBUG ===");
   LogMessage("BaseRiskPercent: " + DoubleToString(BaseRiskPercent, 2));
   LogMessage("MinConsensusScore: " + DoubleToString(MinConsensusScore, 1));
   LogMessage("MinPatternBars: " + IntegerToString(MinPatternBars));
   LogMessage("MaxPatternBars: " + IntegerToString(MaxPatternBars));
   LogMessage("PatternAgeLimit: " + IntegerToString(PatternAgeLimit));
   LogMessage("MaxConcurrentPositions: " + IntegerToString(MaxConcurrentPositions));

   LogMessage("Pattern Toggles:");
   LogMessage("  TradeCupHandle: " + (TradeCupHandle ? "ON" : "OFF"));
   LogMessage("  TradeHeadShoulders: " + (TradeHeadShoulders ? "ON" : "OFF"));
   LogMessage("  TradeDoubleBottom: " + (TradeDoubleBottom ? "ON" : "OFF"));
   LogMessage("  TradeRoundingBottom: " + (TradeRoundingBottom ? "ON" : "OFF"));
   LogMessage("  TradeTriangles: " + (TradeTriangles ? "ON" : "OFF"));
   LogMessage("  TradeFlags: " + (TradeFlags ? "ON" : "OFF"));

// === CRITICAL CHECK ===
   if(MinConsensusScore > 95)
     {
      LogMessage("WARNING: MinConsensusScore is very high (" + DoubleToString(MinConsensusScore,1) + ") - consider lowering to 60-80 for testing");
     }
  }
//=====================================
//+------------------------------------------------------------------+
//| Enhanced symbol info refresh function                            |
//+------------------------------------------------------------------+
bool RefreshSymbolInfo()
  {
   if(!symbol_info.Name(_Symbol))
     {
      LogMessage("ERROR: Cannot initialize symbol info for " + _Symbol);
      return false;
     }

   if(!symbol_info.RefreshRates())
     {
      LogMessage("ERROR: Cannot refresh rates for " + _Symbol);
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Safe price retrieval with validation                             |
//+------------------------------------------------------------------+
bool GetCurrentPrices(double &bid, double &ask)
  {
//--- Refresh symbol info first
   if(!RefreshSymbolInfo())
     {
      return false;
     }

//--- Get prices with multiple attempts
   for(int attempt = 0; attempt < 3; attempt++)
     {
      bid = symbol_info.Bid();
      ask = symbol_info.Ask();

      LogMessage("Attempt " + IntegerToString(attempt + 1) + ": Bid=" + DoubleToString(bid, 5) +
                 ", Ask=" + DoubleToString(ask, 5));

      //--- Validate prices
      if(bid > 0 && ask > 0 && ask >= bid)
        {
         double spread = ask - bid;
         double maxSpread = bid * 0.01; // Max 1% spread (sanity check)

         if(spread <= maxSpread)
           {
            LogMessage("Valid prices obtained: Bid=" + DoubleToString(bid, 5) +
                       ", Ask=" + DoubleToString(ask, 5) +
                       ", Spread=" + DoubleToString(spread, 5));
            return true;
           }
         else
           {
            LogMessage("WARNING: Spread too wide: " + DoubleToString(spread, 5));
           }
        }

      //--- Wait and retry
      if(attempt < 2)
        {
         LogMessage("Invalid prices, retrying in 100ms...");
         Sleep(100);
        }
     }

   LogMessage("ERROR: Failed to get valid prices after 3 attempts");
   return false;
  }

//+------------------------------------------------------------------+
//| Initialize adaptive systems                                       |
//+------------------------------------------------------------------+
void InitializeAdaptiveSystems()
  {
//--- Initialize pattern performance tracking
   ArrayResize(patternStats, 10);
   string patterns[] = {"CUP_AND_HANDLE", "HEAD_AND_SHOULDERS", "INVERSE_HEAD_AND_SHOULDERS",
                        "DOUBLE_BOTTOM", "ROUNDING_BOTTOM", "ASCENDING_TRIANGLE",
                        "DESCENDING_TRIANGLE", "SYMMETRICAL_TRIANGLE", "BULL_FLAG", "BEAR_FLAG"
                       };

   for(int i = 0; i < ArraySize(patterns); i++)
     {
      patternStats[i].patternType = patterns[i];
      patternStats[i].totalTrades = 0;
      patternStats[i].winningTrades = 0;
      patternStats[i].totalProfit = 0;
      patternStats[i].totalLoss = 0;
      patternStats[i].avgWinAmount = 0;
      patternStats[i].avgLossAmount = 0;
      ArrayInitialize(patternStats[i].successRateByRegime, 0);
      ArrayInitialize(patternStats[i].tradesByRegime, 0);
      ArrayInitialize(patternStats[i].successRateByVolatility, 0);
      ArrayInitialize(patternStats[i].tradesByVolatility, 0);
      ArrayInitialize(patternStats[i].successRateByHour, 0);
      ArrayInitialize(patternStats[i].tradesByHour, 0);
      patternStats[i].lastUpdate = TimeCurrent();
     }

//--- Initialize consensus weights
   consensusWeights.qualityWeight = 0.35;
   consensusWeights.volumeWeight = 0.10;
   consensusWeights.indicatorWeight = 0.25;
   consensusWeights.contextWeight = 0.15;
   consensusWeights.orderFlowWeight = 0.15;
   consensusWeights.performanceScore = 0;
   consensusWeights.optimizationCount = 0;
   consensusWeights.lastOptimization = TimeCurrent();

//--- Initialize adaptive thresholds
   adaptiveThresholds.cupHandleDepthMin = 0.1;
   adaptiveThresholds.cupHandleDepthMax = 0.5;
   adaptiveThresholds.hsShoulderTolerance = 0.05;
   adaptiveThresholds.doubleBottomTolerance = 0.03;
   adaptiveThresholds.triangleConvergence = 0.0001;
   adaptiveThresholds.flagRetracement = 0.38;
   adaptiveThresholds.lastUpdate = TimeCurrent();

//--- Initialize recent trades buffer
   ArrayResize(recentTradesBuffer, RECENT_TRADES_SIZE);
   ArrayInitialize(recentTradesBuffer, 0);

//--- Load saved data if exists
   LoadAdaptiveData();
  }

//+------------------------------------------------------------------+
//| Get dynamic success rate for pattern                             |
//+------------------------------------------------------------------+
double GetDynamicSuccessRate(string patternType)
  {
   int patternIndex = GetPatternIndex(patternType);
   if(patternIndex < 0)
      return 0.0;

   PatternPerformance stats = patternStats[patternIndex];

//--- If not enough data, return base rate
   if(stats.totalTrades < 10)
     {
      return GetBaseSuccessRate(patternType);
     }

//--- Calculate weighted success rate
   double baseRate = (double)stats.winningTrades / stats.totalTrades;

//--- Get current market regime
   int regimeIndex = GetRegimeIndex(marketStructure.regime);
   double regimeRate = 0;
   if(stats.tradesByRegime[regimeIndex] >= 5)
     {
      regimeRate = stats.successRateByRegime[regimeIndex];
     }
   else
     {
      regimeRate = baseRate;
     }

//--- Get current volatility level
   int volIndex = GetVolatilityIndex(marketStructure.volatilityLevel);
   double volRate = 0;
   if(stats.tradesByVolatility[volIndex] >= 5)
     {
      volRate = stats.successRateByVolatility[volIndex];
     }
   else
     {
      volRate = baseRate;
     }

//--- Get time-based success rate
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   double timeRate = 0;
   if(stats.tradesByHour[dt.hour] >= 3)
     {
      timeRate = stats.successRateByHour[dt.hour];
     }
   else
     {
      timeRate = baseRate;
     }

//--- Calculate weighted average
   double weightedRate = baseRate * 0.4 + regimeRate * 0.3 + volRate * 0.2 + timeRate * 0.1;

//--- Apply confidence adjustment based on sample size
   double confidence = MathMin(1.0, stats.totalTrades / 50.0);
   double adjustedRate = weightedRate * confidence + GetBaseSuccessRate(patternType) * (1.0 - confidence);

   return MathMin(0.99, MathMax(0.01, adjustedRate));
  }

//+------------------------------------------------------------------+
//| Update pattern performance after trade closes                     |
//+------------------------------------------------------------------+
void UpdatePatternPerformance(string patternType, bool isWin, double profit,
                              string marketRegime, double volatility, int hour)
  {
   int patternIndex = GetPatternIndex(patternType);
   if(patternIndex < 0)
      return;

//--- Update basic stats
   patternStats[patternIndex].totalTrades++;
   if(isWin)
     {
      patternStats[patternIndex].winningTrades++;
      patternStats[patternIndex].totalProfit += profit;

      //--- Update average win
      double currentAvgWin = patternStats[patternIndex].avgWinAmount;
      patternStats[patternIndex].avgWinAmount =
         (currentAvgWin * (patternStats[patternIndex].winningTrades - 1) + profit) /
         patternStats[patternIndex].winningTrades;
     }
   else
     {
      patternStats[patternIndex].totalLoss += MathAbs(profit);

      //--- Update average loss
      int losses = patternStats[patternIndex].totalTrades - patternStats[patternIndex].winningTrades;
      if(losses > 0)
        {
         double currentAvgLoss = patternStats[patternIndex].avgLossAmount;
         patternStats[patternIndex].avgLossAmount =
            (currentAvgLoss * (losses - 1) + MathAbs(profit)) / losses;
        }
     }

//--- Update regime-specific stats
   int regimeIndex = GetRegimeIndex(marketRegime);
   patternStats[patternIndex].tradesByRegime[regimeIndex]++;
   int regimeTrades = patternStats[patternIndex].tradesByRegime[regimeIndex];
   double currentRegimeRate = patternStats[patternIndex].successRateByRegime[regimeIndex];
   patternStats[patternIndex].successRateByRegime[regimeIndex] =
      (currentRegimeRate * (regimeTrades - 1) + (isWin ? 1.0 : 0.0)) / regimeTrades;

//--- Update volatility-specific stats
   int volIndex = GetVolatilityIndex(volatility);
   patternStats[patternIndex].tradesByVolatility[volIndex]++;
   int volTrades = patternStats[patternIndex].tradesByVolatility[volIndex];
   double currentVolRate = patternStats[patternIndex].successRateByVolatility[volIndex];
   patternStats[patternIndex].successRateByVolatility[volIndex] =
      (currentVolRate * (volTrades - 1) + (isWin ? 1.0 : 0.0)) / volTrades;

//--- Update hourly stats
   patternStats[patternIndex].tradesByHour[hour]++;
   int hourTrades = patternStats[patternIndex].tradesByHour[hour];
   double currentHourRate = patternStats[patternIndex].successRateByHour[hour];
   patternStats[patternIndex].successRateByHour[hour] =
      (currentHourRate * (hourTrades - 1) + (isWin ? 1.0 : 0.0)) / hourTrades;

   patternStats[patternIndex].lastUpdate = TimeCurrent();

//--- Save updated data
   SaveAdaptiveData();
  }

//+------------------------------------------------------------------+
//| Get adaptive risk percentage based on performance                 |
//+------------------------------------------------------------------+
double GetAdaptiveRiskPercent()
  {
   double baseRisk = BaseRiskPercent;

//--- Calculate recent win rate (last 20 trades)
   double recentWinRate = CalculateRecentWinRate(20);
   double recentSharpe = CalculateRecentSharpe(30);
   double recentDrawdown = CalculateRecentDrawdown();

//--- Risk reduction factors
   double riskMultiplier = 1.0;

//--- Reduce risk after consecutive losses
   int consecutiveLosses = CountConsecutiveLosses();
   if(consecutiveLosses >= 3)
     {
      riskMultiplier *= 0.5;
     }
   else
      if(consecutiveLosses >= 2)
        {
         riskMultiplier *= 0.75;
        }

//--- Reduce risk if recent performance is poor
   if(recentWinRate < 0.35 && performance.totalTrades >= 20)
     {
      riskMultiplier *= 0.7;
     }

//--- Reduce risk in high drawdown
   if(recentDrawdown > 10.0)
     {
      riskMultiplier *= 0.6;
     }
   else
      if(recentDrawdown > 5.0)
        {
         riskMultiplier *= 0.8;
        }

//--- Increase risk if performance is exceptional
   if(recentWinRate > 0.65 && recentSharpe > 2.0 && recentDrawdown < 3.0)
     {
      riskMultiplier *= 1.2;
     }

//--- Adjust for market regime
   if(marketStructure.regime == "VOLATILE")
     {
      riskMultiplier *= 0.7;
     }
   else
      if(marketStructure.regime == "TRENDING_UP" || marketStructure.regime == "TRENDING_DOWN")
        {
         if(marketStructure.trendStrength > 30)
           {
            riskMultiplier *= 1.1;
           }
        }

//--- Adjust for time of day
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   double hourlyPerformance = GetHourlyPerformance(dt.hour);
   if(hourlyPerformance < -0.5)
     {
      riskMultiplier *= 0.8;
     }
   else
      if(hourlyPerformance > 1.0)
        {
         riskMultiplier *= 1.1;
        }

//--- Apply Kelly Criterion adjustment if enabled
   if(UseKellyCriterion && performance.totalTrades >= 30)
     {
      double kellyFraction = CalculateKellyFraction();
      double kellyRisk = account.Balance() * kellyFraction;
      double maxKellyRisk = account.Balance() * baseRisk / 100.0 * 1.5;

      if(kellyRisk < maxKellyRisk)
        {
         double kellyAdjustment = kellyRisk / (account.Balance() * baseRisk / 100.0);
         riskMultiplier = (riskMultiplier + kellyAdjustment) / 2.0;
        }
     }

//--- Final risk calculation
   double adaptiveRisk = baseRisk * riskMultiplier;

//--- Apply absolute limits
   adaptiveRisk = MathMax(0.25, MathMin(adaptiveRisk, baseRisk * 1.5));

   LogMessage(StringFormat("Adaptive Risk: %.2f%% (Base: %.2f%%, Multiplier: %.2f)",
                           adaptiveRisk, baseRisk, riskMultiplier));

   return adaptiveRisk;
  }

//+------------------------------------------------------------------+
//| Calculate adaptive consensus score                                |
//+------------------------------------------------------------------+
double CalculateAdaptiveConsensusScore(PatternData &pattern)
  {
//--- Check if weights need optimization
   if(TimeCurrent() - consensusWeights.lastOptimization > 7 * 24 * 3600)
     {
      OptimizeConsensusWeights();
     }

//--- Get dynamic success rate for this pattern
   double dynamicQuality = GetDynamicSuccessRate(pattern.patternType);
   pattern.qualityScore = dynamicQuality * 100.0;

//--- Calculate weighted score
   double score = pattern.qualityScore * consensusWeights.qualityWeight +
                  pattern.volumeScore * consensusWeights.volumeWeight +
                  pattern.indicatorScore * consensusWeights.indicatorWeight +
                  pattern.contextScore * consensusWeights.contextWeight;

   if(UseOrderFlowAnalysis)
     {
      double orderFlowScore = 50.0;
      int startBar = iBarShift(_Symbol, PERIOD_CURRENT, pattern.formationStart);
      int endBar = iBarShift(_Symbol, PERIOD_CURRENT, pattern.formationEnd);

      if(startBar > 0 && endBar >= 0 && startBar > endBar)
        {
         orderFlowScore = AnalyzeOrderFlow(startBar, endBar, pattern.isBullish);
        }

      score = score * (1.0 - consensusWeights.orderFlowWeight) +
              orderFlowScore * consensusWeights.orderFlowWeight;
     }

//--- Apply performance-based adjustment
   double patternPerformance = GetPatternRecentPerformance(pattern.patternType, 50);
   if(patternPerformance < -2.0)
     {
      score *= 0.8;
     }
   else
      if(patternPerformance > 2.0)
        {
         score *= 1.1;
        }

//--- Apply time-based adjustment
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   double timeScore = GetTimeBasedScore(dt.hour, dt.day_of_week);
   score *= timeScore;

   return MathMin(100.0, MathMax(0.0, score));
  }

//+------------------------------------------------------------------+
//| Optimize consensus weights using performance data                 |
//+------------------------------------------------------------------+
void OptimizeConsensusWeights()
  {
   if(performance.totalTrades < 50)
      return;

//--- Simple gradient optimization
   double learningRate = 0.01;
   double currentPerformance = CalculateWeightedPerformance();

//--- Test small changes to each weight
   double gradients[5];
   double weights[5] = {consensusWeights.qualityWeight, consensusWeights.volumeWeight,
                        consensusWeights.indicatorWeight, consensusWeights.contextWeight,
                        consensusWeights.orderFlowWeight
                       };

   for(int i = 0; i < 5; i++)
     {
      //--- Increase weight slightly
      weights[i] += 0.01;
      NormalizeWeights(weights);
      double perfUp = SimulatePerformance(weights);

      //--- Decrease weight slightly
      weights[i] -= 0.02;
      NormalizeWeights(weights);
      double perfDown = SimulatePerformance(weights);

      //--- Calculate gradient
      gradients[i] = (perfUp - perfDown) / 0.02;

      //--- Restore original
      weights[i] += 0.01;
     }

//--- Update weights based on gradients
   for(int i = 0; i < 5; i++)
     {
      weights[i] += gradients[i] * learningRate;
     }

//--- Normalize and apply constraints
   NormalizeWeights(weights);

//--- Ensure no weight is too small or too large
   for(int i = 0; i < 5; i++)
     {
      weights[i] = MathMax(0.05, MathMin(0.5, weights[i]));
     }

//--- Re-normalize after constraints
   NormalizeWeights(weights);

//--- Apply new weights
   consensusWeights.qualityWeight = weights[0];
   consensusWeights.volumeWeight = weights[1];
   consensusWeights.indicatorWeight = weights[2];
   consensusWeights.contextWeight = weights[3];
   consensusWeights.orderFlowWeight = weights[4];

   consensusWeights.optimizationCount++;
   consensusWeights.lastOptimization = TimeCurrent();
   consensusWeights.performanceScore = currentPerformance;

   LogMessage(StringFormat("Weights optimized: Q=%.3f, V=%.3f, I=%.3f, C=%.3f, O=%.3f",
                           weights[0], weights[1], weights[2], weights[3], weights[4]));
  }

//+------------------------------------------------------------------+
//| Get adaptive thresholds for pattern detection                     |
//+------------------------------------------------------------------+
AdaptiveThresholds GetAdaptiveThresholds()
  {
//--- Update thresholds based on market conditions
   if(TimeCurrent() - adaptiveThresholds.lastUpdate > 4 * 3600)
     {
      UpdateAdaptiveThresholds();
     }

   return adaptiveThresholds;
  }

//+------------------------------------------------------------------+
//| Update adaptive thresholds based on market conditions             |
//+------------------------------------------------------------------+
void UpdateAdaptiveThresholds()
  {
//--- Base thresholds
   AdaptiveThresholds newThresholds = adaptiveThresholds;

//--- Adjust for volatility
   double volMultiplier = MathSqrt(marketStructure.volatilityLevel);

//--- Cup & Handle adjustments
   newThresholds.cupHandleDepthMin = 0.1 * volMultiplier;
   newThresholds.cupHandleDepthMax = 0.5 * volMultiplier;

//--- Head & Shoulders adjustments
   newThresholds.hsShoulderTolerance = 0.05 * volMultiplier;

//--- Double Bottom adjustments
   newThresholds.doubleBottomTolerance = 0.03 * volMultiplier;

//--- Triangle adjustments
   if(marketStructure.regime == "RANGING")
     {
      newThresholds.triangleConvergence = 0.0001 * 0.5;
     }
   else
     {
      newThresholds.triangleConvergence = 0.0001 * volMultiplier;
     }

//--- Flag adjustments
   if(marketStructure.regime == "TRENDING_UP" || marketStructure.regime == "TRENDING_DOWN")
     {
      newThresholds.flagRetracement = 0.38 * 0.8;
     }
   else
     {
      newThresholds.flagRetracement = 0.38 * 1.2;
     }

   newThresholds.lastUpdate = TimeCurrent();
   adaptiveThresholds = newThresholds;
  }

//+------------------------------------------------------------------+
//| Check if pattern should be traded based on performance            |
//+------------------------------------------------------------------+
bool ShouldTradePattern(string patternType)
  {
   int patternIndex = GetPatternIndex(patternType);
   if(patternIndex < 0)
      return true;

   PatternPerformance stats = patternStats[patternIndex];

//--- Always trade if not enough data
   if(stats.totalTrades < 20)
      return true;

//--- Check recent performance
   double recentPerformance = GetPatternRecentPerformance(patternType, 30);
   double recentWinRate = GetPatternRecentWinRate(patternType, 20);

//--- Disable if performing very poorly
   if(recentPerformance < -3.0 || recentWinRate < 0.25)
     {
      LogMessage(StringFormat("Pattern %s temporarily disabled. Performance: %.2f, WinRate: %.2f",
                              patternType, recentPerformance, recentWinRate));
      return false;
     }

//--- Check regime-specific performance
   int regimeIndex = GetRegimeIndex(marketStructure.regime);
   if(stats.tradesByRegime[regimeIndex] >= 10)
     {
      if(stats.successRateByRegime[regimeIndex] < 0.3)
        {
         LogMessage(StringFormat("Pattern %s disabled in %s regime. Success rate: %.2f",
                                 patternType, marketStructure.regime, stats.successRateByRegime[regimeIndex]));
         return false;
        }
     }

//--- Check time-based performance
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(stats.tradesByHour[dt.hour] >= 5)
     {
      if(stats.successRateByHour[dt.hour] < 0.2)
        {
         LogMessage(StringFormat("Pattern %s disabled at hour %d. Success rate: %.2f",
                                 patternType, dt.hour, stats.successRateByHour[dt.hour]));
         return false;
        }
     }

   return true;
  }

//+------------------------------------------------------------------+
//| Helper function to get pattern index                             |
//+------------------------------------------------------------------+
int GetPatternIndex(string patternType)
  {
   for(int i = 0; i < ArraySize(patternStats); i++)
     {
      if(patternStats[i].patternType == patternType)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| Get base success rate for pattern                                |
//+------------------------------------------------------------------+
double GetBaseSuccessRate(string patternType)
  {
   if(patternType == "CUP_AND_HANDLE")
      return 0.95;
   if(patternType == "HEAD_AND_SHOULDERS")
      return 0.81;
   if(patternType == "INVERSE_HEAD_AND_SHOULDERS")
      return 0.90;
   if(patternType == "DOUBLE_BOTTOM")
      return 0.81;
   if(patternType == "ROUNDING_BOTTOM")
      return 0.97;
   if(patternType == "ASCENDING_TRIANGLE")
      return 0.75;
   if(patternType == "DESCENDING_TRIANGLE")
      return 0.70;
   if(patternType == "SYMMETRICAL_TRIANGLE")
      return 0.68;
   if(patternType == "BULL_FLAG")
      return 0.75;
   if(patternType == "BEAR_FLAG")
      return 0.75;
   return 0.70;
  }

//+------------------------------------------------------------------+
//| Get regime index                                                 |
//+------------------------------------------------------------------+
int GetRegimeIndex(string regime)
  {
   if(regime == "TRENDING_UP")
      return 0;
   if(regime == "TRENDING_DOWN")
      return 1;
   if(regime == "RANGING")
      return 2;
   if(regime == "VOLATILE")
      return 3;
   return 2;
  }

//+------------------------------------------------------------------+
//| Get volatility index                                             |
//+------------------------------------------------------------------+
int GetVolatilityIndex(double volatility)
  {
   if(volatility < 0.8)
      return 0;  // Low
   if(volatility < 1.5)
      return 1;  // Medium
   return 2;  // High
  }

//+------------------------------------------------------------------+
//| Calculate recent win rate                                        |
//+------------------------------------------------------------------+
double CalculateRecentWinRate(int lookback)
  {
   if(lookback > RECENT_TRADES_SIZE)
      lookback = RECENT_TRADES_SIZE;

   int wins = 0;
   int trades = 0;

   for(int i = 0; i < lookback; i++)
     {
      int index = (recentTradesIndex - i + RECENT_TRADES_SIZE) % RECENT_TRADES_SIZE;
      if(recentTradesBuffer[index] != 0)
        {
         trades++;
         if(recentTradesBuffer[index] > 0)
            wins++;
        }
     }

   return trades > 0 ? (double)wins / trades : 0.5;
  }

//+------------------------------------------------------------------+
//| Calculate recent Sharpe ratio                                    |
//+------------------------------------------------------------------+
double CalculateRecentSharpe(int lookback)
  {
   if(lookback > RECENT_TRADES_SIZE)
      lookback = RECENT_TRADES_SIZE;

   double returns[];
   ArrayResize(returns, 0);

   for(int i = 0; i < lookback; i++)
     {
      int index = (recentTradesIndex - i + RECENT_TRADES_SIZE) % RECENT_TRADES_SIZE;
      if(recentTradesBuffer[index] != 0)
        {
         ArrayResize(returns, ArraySize(returns) + 1);
         returns[ArraySize(returns) - 1] = recentTradesBuffer[index];
        }
     }

   if(ArraySize(returns) < 5)
      return 0;

   double mean = 0;
   for(int i = 0; i < ArraySize(returns); i++)
     {
      mean += returns[i];
     }
   mean /= ArraySize(returns);

   double stdDev = 0;
   for(int i = 0; i < ArraySize(returns); i++)
     {
      stdDev += MathPow(returns[i] - mean, 2);
     }
   stdDev = MathSqrt(stdDev / ArraySize(returns));

   return stdDev > 0 ? mean / stdDev * MathSqrt(252) : 0;
  }

//+------------------------------------------------------------------+
//| Calculate recent drawdown                                        |
//+------------------------------------------------------------------+
double CalculateRecentDrawdown()
  {
   double peak = account.Balance();
   double maxDrawdown = 0;
   double runningBalance = account.Balance();

   for(int i = 0; i < RECENT_TRADES_SIZE; i++)
     {
      int index = (recentTradesIndex - i + RECENT_TRADES_SIZE) % RECENT_TRADES_SIZE;
      if(recentTradesBuffer[index] == 0)
         break;

      runningBalance -= recentTradesBuffer[index];
      if(runningBalance > peak)
         peak = runningBalance;

      double drawdown = (peak - runningBalance) / peak * 100;
      if(drawdown > maxDrawdown)
         maxDrawdown = drawdown;
     }

   return maxDrawdown;
  }

//+------------------------------------------------------------------+
//| Count consecutive losses                                         |
//+------------------------------------------------------------------+
int CountConsecutiveLosses()
  {
   int losses = 0;

   for(int i = 0; i < RECENT_TRADES_SIZE; i++)
     {
      int index = (recentTradesIndex - i + RECENT_TRADES_SIZE) % RECENT_TRADES_SIZE;
      if(recentTradesBuffer[index] == 0)
         break;
      if(recentTradesBuffer[index] < 0)
        {
         losses++;
        }
      else
        {
         break;
        }
     }

   return losses;
  }

//+------------------------------------------------------------------+
//| Get hourly performance                                           |
//+------------------------------------------------------------------+
double GetHourlyPerformance(int hour)
  {
   double totalPerformance = 0;
   int totalTrades = 0;

   for(int i = 0; i < ArraySize(patternStats); i++)
     {
      if(patternStats[i].tradesByHour[hour] > 0)
        {
         double winRate = patternStats[i].successRateByHour[hour];
         double avgWin = patternStats[i].avgWinAmount;
         double avgLoss = patternStats[i].avgLossAmount;

         if(avgWin > 0 && avgLoss > 0)
           {
            double expectancy = winRate * avgWin - (1 - winRate) * avgLoss;
            totalPerformance += expectancy * patternStats[i].tradesByHour[hour];
            totalTrades += patternStats[i].tradesByHour[hour];
           }
        }
     }

   return totalTrades > 0 ? totalPerformance / totalTrades : 0;
  }

//+------------------------------------------------------------------+
//| Calculate Kelly fraction                                         |
//+------------------------------------------------------------------+
double CalculateKellyFraction()
  {
   if(performance.totalTrades < 30)
      return 0.01;

   double totalWins = 0;
   double totalLosses = 0;
   int winCount = 0;
   int lossCount = 0;

   for(int i = 0; i < ArraySize(patternStats); i++)
     {
      totalWins += patternStats[i].totalProfit;
      totalLosses += patternStats[i].totalLoss;
      winCount += patternStats[i].winningTrades;
      lossCount += patternStats[i].totalTrades - patternStats[i].winningTrades;
     }

   if(winCount == 0 || lossCount == 0 || totalLosses == 0)
      return 0.01;

   double avgWin = totalWins / winCount;
   double avgLoss = totalLosses / lossCount;
   double winProb = (double)winCount / (winCount + lossCount);

   double kelly = (winProb * avgWin - (1 - winProb) * avgLoss) / avgWin;

//--- Apply Kelly fraction multiplier and limits
   kelly *= KellyFraction;
   kelly = MathMax(0.001, MathMin(kelly, 0.25));

   return kelly;
  }

//+------------------------------------------------------------------+
//| Get pattern recent performance                                   |
//+------------------------------------------------------------------+
double GetPatternRecentPerformance(string patternType, int lookback)
  {
   int patternIndex = GetPatternIndex(patternType);
   if(patternIndex < 0)
      return 0;

//--- This would require tracking individual pattern trades
//--- For now, use overall performance metrics
   PatternPerformance stats = patternStats[patternIndex];
   if(stats.totalTrades == 0)
      return 0;

   double avgReturn = (stats.totalProfit - stats.totalLoss) / stats.totalTrades;
   double winRate = (double)stats.winningTrades / stats.totalTrades;

//--- Simple performance metric
   return avgReturn * winRate;
  }

//+------------------------------------------------------------------+
//| Get pattern recent win rate                                     |
//+------------------------------------------------------------------+
double GetPatternRecentWinRate(string patternType, int lookback)
  {
   int patternIndex = GetPatternIndex(patternType);
   if(patternIndex < 0)
      return 0.5;

   PatternPerformance stats = patternStats[patternIndex];
   if(stats.totalTrades == 0)
      return GetBaseSuccessRate(patternType);

//--- Use overall win rate with decay for older trades
   double decayFactor = MathMin(1.0, (double)lookback / stats.totalTrades);
   double baseRate = GetBaseSuccessRate(patternType);
   double actualRate = (double)stats.winningTrades / stats.totalTrades;

   return actualRate * decayFactor + baseRate * (1.0 - decayFactor);
  }

//+------------------------------------------------------------------+
//| Calculate weighted performance for optimization                   |
//+------------------------------------------------------------------+
double CalculateWeightedPerformance()
  {
   if(performance.totalTrades < 10)
      return 0;

   double sharpe = CalculateRecentSharpe(50);
   double winRate = CalculateRecentWinRate(50);
   double drawdown = CalculateRecentDrawdown();

//--- Weighted performance metric
   double perfScore = sharpe * 0.4 + winRate * 3.0 - drawdown * 0.1;

   return perfScore;
  }

//+------------------------------------------------------------------+
//| Simulate performance with different weights                      |
//+------------------------------------------------------------------+
double SimulatePerformance(double &weights[])
  {
//--- This would ideally backtest with new weights
//--- For now, use a heuristic based on historical data

   double simulatedScore = 0;

//--- Quality weight impact
   simulatedScore += weights[0] * 2.0;  // Quality is important

//--- Volume weight impact
   simulatedScore += weights[1] * 1.0;  // Volume is moderate

//--- Indicator weight impact
   simulatedScore += weights[2] * 1.5;  // Indicators are useful

//--- Context weight impact
   simulatedScore += weights[3] * 1.2;  // Context helps

//--- Order flow weight impact
   if(UseOrderFlowAnalysis)
     {
      simulatedScore += weights[4] * 1.3;  // Order flow is valuable
     }

   return simulatedScore;
  }

//+------------------------------------------------------------------+
//| Normalize weights to sum to 1.0                                  |
//+------------------------------------------------------------------+
void NormalizeWeights(double &weights[])
  {
   double sum = 0;
   for(int i = 0; i < ArraySize(weights); i++)
     {
      sum += weights[i];
     }

   if(sum > 0)
     {
      for(int i = 0; i < ArraySize(weights); i++)
        {
         weights[i] /= sum;
        }
     }
  }

//+------------------------------------------------------------------+
//| Get time-based score                                             |
//+------------------------------------------------------------------+
double GetTimeBasedScore(int hour, int dayOfWeek)
  {
   double score = 1.0;

//--- Weekend and Friday evening penalty
   if(dayOfWeek == 0 || dayOfWeek == 6)
      score *= 0.5;
   if(dayOfWeek == 5 && hour >= 20)
      score *= 0.7;

//--- Low liquidity hours
   if(hour >= 22 || hour < 2)
      score *= 0.8;

//--- Optimal trading hours
   if((hour >= 8 && hour <= 11) || (hour >= 13 && hour <= 16))
     {
      score *= 1.1;
     }

//--- Use historical performance
   double hourlyPerf = GetHourlyPerformance(hour);
   if(hourlyPerf < -0.5)
     {
      score *= 0.8;
     }
   else
      if(hourlyPerf > 0.5)
        {
         score *= 1.2;
        }

   return MathMax(0.5, MathMin(1.5, score));
  }

//+------------------------------------------------------------------+
//| Save adaptive data to file                                       |
//+------------------------------------------------------------------+
void SaveAdaptiveData()
  {
// FIXED: Correct symbol syntax
   string unique_filename = "Hon-APS_Adaptive_Data_" + _Symbol + "_" + EnumToString(_Period) + ".bin";
   int handle = FileOpen(unique_filename, FILE_WRITE|FILE_BIN);

   if(handle == INVALID_HANDLE)
     {
      LogMessage("ERROR: Cannot open file for saving adaptive data: " + unique_filename);
      return;
     }

// FIXED: Proper error handling for FileWrite functions
   bool success = true;

   do
     {
      // Save pattern statistics - FIXED: Check for 0 return (failure), not < 0
      if(FileWriteInteger(handle, ArraySize(patternStats)) == 0)
        {
         success = false;
         break;
        }

      for(int i = 0; i < ArraySize(patternStats); i++)
        {
         // FIXED: FileWrite functions return bytes written (>0) on success, 0 on failure
         if(FileWriteString(handle, patternStats[i].patternType) == 0)
           {
            success = false;
            break;
           }
         if(FileWriteInteger(handle, patternStats[i].totalTrades) == 0)
           {
            success = false;
            break;
           }
         if(FileWriteInteger(handle, patternStats[i].winningTrades) == 0)
           {
            success = false;
            break;
           }
         if(FileWriteDouble(handle, patternStats[i].totalProfit) == 0)
           {
            success = false;
            break;
           }
         if(FileWriteDouble(handle, patternStats[i].totalLoss) == 0)
           {
            success = false;
            break;
           }
         if(FileWriteDouble(handle, patternStats[i].avgWinAmount) == 0)
           {
            success = false;
            break;
           }
         if(FileWriteDouble(handle, patternStats[i].avgLossAmount) == 0)
           {
            success = false;
            break;
           }

         for(int j = 0; j < 4; j++)
           {
            if(FileWriteDouble(handle, patternStats[i].successRateByRegime[j]) == 0)
              {
               success = false;
               break;
              }
            if(FileWriteInteger(handle, patternStats[i].tradesByRegime[j]) == 0)
              {
               success = false;
               break;
              }
           }
         if(!success)
            break;

         for(int j = 0; j < 3; j++)
           {
            if(FileWriteDouble(handle, patternStats[i].successRateByVolatility[j]) == 0)
              {
               success = false;
               break;
              }
            if(FileWriteInteger(handle, patternStats[i].tradesByVolatility[j]) == 0)
              {
               success = false;
               break;
              }
           }
         if(!success)
            break;

         for(int j = 0; j < 24; j++)
           {
            if(FileWriteDouble(handle, patternStats[i].successRateByHour[j]) == 0)
              {
               success = false;
               break;
              }
            if(FileWriteInteger(handle, patternStats[i].tradesByHour[j]) == 0)
              {
               success = false;
               break;
              }
           }
         if(!success)
            break;
        }

      if(!success)
         break;

      // Save consensus weights - FIXED: Check for 0 return (failure)
      if(FileWriteDouble(handle, consensusWeights.qualityWeight) == 0)
        {
         success = false;
         break;
        }
      if(FileWriteDouble(handle, consensusWeights.volumeWeight) == 0)
        {
         success = false;
         break;
        }
      if(FileWriteDouble(handle, consensusWeights.indicatorWeight) == 0)
        {
         success = false;
         break;
        }
      if(FileWriteDouble(handle, consensusWeights.contextWeight) == 0)
        {
         success = false;
         break;
        }
      if(FileWriteDouble(handle, consensusWeights.orderFlowWeight) == 0)
        {
         success = false;
         break;
        }

     }
   while(false);

// Always close the file handle
   FileClose(handle);

   if(success)
     {
      LogMessage("Adaptive data saved successfully");
     }
   else
     {
      LogMessage("ERROR: Failed to save adaptive data completely");
     }
  }
//+------------------------------------------------------------------+
//| Load adaptive data from file                                     |
//+------------------------------------------------------------------+
void LoadAdaptiveData()
  {
// Create a unique filename for each chart instance ---
   string unique_filename = "Hon-APS_Adaptive_Data_" + _Symbol + "_" + EnumToString(_Period) + ".bin";
   int handle = FileOpen(unique_filename, FILE_READ|FILE_BIN);
// --- END

   if(handle == INVALID_HANDLE)
      return;

//--- Load pattern statistics
   int patternCount = FileReadInteger(handle);
   if(patternCount > 0 && patternCount <= 10)
     {
      for(int i = 0; i < patternCount; i++)
        {
         string patternType = FileReadString(handle);

         //--- Find matching pattern
         for(int p = 0; p < ArraySize(patternStats); p++)
           {
            if(patternStats[p].patternType == patternType)
              {
               patternStats[p].totalTrades = FileReadInteger(handle);
               patternStats[p].winningTrades = FileReadInteger(handle);
               patternStats[p].totalProfit = FileReadDouble(handle);
               patternStats[p].totalLoss = FileReadDouble(handle);
               patternStats[p].avgWinAmount = FileReadDouble(handle);
               patternStats[p].avgLossAmount = FileReadDouble(handle);

               for(int j = 0; j < 4; j++)
                 {
                  patternStats[p].successRateByRegime[j] = FileReadDouble(handle);
                  patternStats[p].tradesByRegime[j] = FileReadInteger(handle);
                 }

               for(int j = 0; j < 3; j++)
                 {
                  patternStats[p].successRateByVolatility[j] = FileReadDouble(handle);
                  patternStats[p].tradesByVolatility[j] = FileReadInteger(handle);
                 }

               for(int j = 0; j < 24; j++)
                 {
                  patternStats[p].successRateByHour[j] = FileReadDouble(handle);
                  patternStats[p].tradesByHour[j] = FileReadInteger(handle);
                 }

               break;
              }
           }
        }
     }

//--- Load consensus weights
   if(!FileIsEnding(handle))
     {
      consensusWeights.qualityWeight = FileReadDouble(handle);
      consensusWeights.volumeWeight = FileReadDouble(handle);
      consensusWeights.indicatorWeight = FileReadDouble(handle);
      consensusWeights.contextWeight = FileReadDouble(handle);
      consensusWeights.orderFlowWeight = FileReadDouble(handle);
     }

   FileClose(handle);
  }

//+------------------------------------------------------------------+
//| Add trade result to recent buffer                                |
//+------------------------------------------------------------------+
void AddTradeResult(double profit)
  {
   recentTradesBuffer[recentTradesIndex] = profit;
   recentTradesIndex = (recentTradesIndex + 1) % RECENT_TRADES_SIZE;
  }
//+------------------------------------------------------------------+
//| Check if trend is exhausted                                      |
//+------------------------------------------------------------------+
bool IsTrendExhausted(bool isBullish)
  {
// Multiple exhaustion checks
   bool exhausted = false;
   int exhaustionSignals = 0;

// 1. RSI Overbought/Oversold Check
   double rsi[];
   ArraySetAsSeries(rsi, true);
   if(CopyBuffer(handle_rsi, 0, 0, 3, rsi) > 0)
     {
      if(isBullish && rsi[0] > 70)
        {
         exhaustionSignals++;
         LogMessage("Exhaustion Signal: RSI Overbought (" + DoubleToString(rsi[0], 1) + ")");
        }
      else
         if(!isBullish && rsi[0] < 30)
           {
            exhaustionSignals++;
            LogMessage("Exhaustion Signal: RSI Oversold (" + DoubleToString(rsi[0], 1) + ")");
           }
     }

// 2. Distance from KAMA Check
   double kama_value = GetKAMAValue(0);
   double current_price = symbol_info.Bid();
   double distance_percent = ((current_price - kama_value) / kama_value) * 100;

   if(isBullish && distance_percent > 2.5)   // Price more than 2.5% above KAMA
     {
      exhaustionSignals++;
      LogMessage("Exhaustion Signal: Price far above KAMA (" + DoubleToString(distance_percent, 2) + "%)");
     }
   else
      if(!isBullish && distance_percent < -2.5)   // Price more than 2.5% below KAMA
        {
         exhaustionSignals++;
         LogMessage("Exhaustion Signal: Price far below KAMA (" + DoubleToString(distance_percent, 2) + "%)");
        }

// 3. ADX Declining (trend losing strength)
   double adx[];
   ArraySetAsSeries(adx, true);
   if(CopyBuffer(handle_adx, 0, 0, 5, adx) > 0)
     {
      if(adx[0] > 40 && adx[0] < adx[1] && adx[1] < adx[2])
        {
         exhaustionSignals++;
         LogMessage("Exhaustion Signal: ADX declining from high levels");
        }
     }

// 4. Multiple consecutive bars in same direction
   int consecutiveBars = CountConsecutiveBars(isBullish);
   if(consecutiveBars >= 7)   // 7 or more bars in same direction
     {
      exhaustionSignals++;
      LogMessage("Exhaustion Signal: " + IntegerToString(consecutiveBars) + " consecutive bars");
     }

// 5. Bollinger Bands Check
   double bb_upper[], bb_lower[], bb_middle[];
   ArraySetAsSeries(bb_upper, true);
   ArraySetAsSeries(bb_lower, true);
   if(CopyBuffer(handle_bbands, 1, 0, 1, bb_upper) > 0 &&
      CopyBuffer(handle_bbands, 2, 0, 1, bb_lower) > 0)
     {
      if(isBullish && current_price > bb_upper[0])
        {
         exhaustionSignals++;
         LogMessage("Exhaustion Signal: Price above Bollinger Band");
        }
      else
         if(!isBullish && current_price < bb_lower[0])
           {
            exhaustionSignals++;
            LogMessage("Exhaustion Signal: Price below Bollinger Band");
           }
     }

// Consider exhausted if 3 or more signals
   exhausted = (exhaustionSignals >= 3);

   LogMessage("Trend Exhaustion Check: " + IntegerToString(exhaustionSignals) +
              " signals, Exhausted: " + (exhausted ? "YES" : "NO"));

   return exhausted;
  }
//+------------------------------------------------------------------+
//| Count consecutive bars in one direction                          |
//+------------------------------------------------------------------+
int CountConsecutiveBars(bool bullishDirection)
  {
   double close[];
   ArraySetAsSeries(close, true);

   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 20, close) < 20)
      return 0;

   int count = 0;
   for(int i = 1; i < 20; i++)
     {
      if(bullishDirection)
        {
         if(close[i-1] > close[i])
            count++;
         else
            break;
        }
      else
        {
         if(close[i-1] < close[i])
            count++;
         else
            break;
        }
     }

   return count;
  }
//+------------------------------------------------------------------+
//| Check if a pullback has occurred                                |
//+------------------------------------------------------------------+
bool HasPullbackOccurred(const PatternData &pattern, bool isBullish)
  {
   LogMessage("=== CHECKING FOR PULLBACK ===");

   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   int lookback = 10; // Look at last 10 bars for pullback
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, lookback, high) < lookback ||
      CopyLow(_Symbol, PERIOD_CURRENT, 0, lookback, low) < lookback ||
      CopyClose(_Symbol, PERIOD_CURRENT, 0, lookback, close) < lookback)
     {
      return false;
     }

   bool pullbackFound = false;

   if(isBullish)
     {
      // For bullish patterns, look for a dip/pullback

      // 1. Check if price pulled back to KAMA
      double kama_value = GetKAMAValue(0);
      for(int i = 0; i < lookback - 1; i++)
        {
         if(low[i] <= kama_value * 1.002)   // Within 0.2% of KAMA
           {
            pullbackFound = true;
            LogMessage("Pullback found: Price touched KAMA");
            break;
           }
        }

      // 2. Check for support bounce
      if(!pullbackFound)
        {
         for(int i = 0; i < ArraySize(marketStructure.supportLevels); i++)
           {
            double support = marketStructure.supportLevels[i];
            for(int j = 0; j < lookback - 1; j++)
              {
               if(low[j] <= support * 1.001 && close[j] > support)
                 {
                  pullbackFound = true;
                  LogMessage("Pullback found: Bounced from support " + DoubleToString(support, 5));
                  break;
                 }
              }
            if(pullbackFound)
               break;
           }
        }

      // 3. Check for Fibonacci retracement (38.2%, 50%, 61.8%)
      if(!pullbackFound)
        {
         double recentHigh = high[ArrayMaximum(high, 0, lookback)];
         double recentLow = low[ArrayMinimum(low, 0, lookback)];
         double range = recentHigh - recentLow;

         double fib382 = recentHigh - range * 0.382;
         double fib50 = recentHigh - range * 0.5;
         double fib618 = recentHigh - range * 0.618;

         for(int i = 0; i < lookback - 1; i++)
           {
            if((low[i] <= fib382 * 1.002 && low[i] >= fib382 * 0.998) ||
               (low[i] <= fib50 * 1.002 && low[i] >= fib50 * 0.998) ||
               (low[i] <= fib618 * 1.002 && low[i] >= fib618 * 0.998))
              {
               pullbackFound = true;
               LogMessage("Pullback found: Fibonacci retracement level");
               break;
              }
           }
        }

     }
   else
     {
      // For bearish patterns, look for a rally/pullback up

      // 1. Check if price pulled back to KAMA
      double kama_value = GetKAMAValue(0);
      for(int i = 0; i < lookback - 1; i++)
        {
         if(high[i] >= kama_value * 0.998)   // Within 0.2% of KAMA
           {
            pullbackFound = true;
            LogMessage("Pullback found: Price touched KAMA");
            break;
           }
        }

      // 2. Check for resistance rejection
      if(!pullbackFound)
        {
         for(int i = 0; i < ArraySize(marketStructure.resistanceLevels); i++)
           {
            double resistance = marketStructure.resistanceLevels[i];
            for(int j = 0; j < lookback - 1; j++)
              {
               if(high[j] >= resistance * 0.999 && close[j] < resistance)
                 {
                  pullbackFound = true;
                  LogMessage("Pullback found: Rejected from resistance " + DoubleToString(resistance, 5));
                  break;
                 }
              }
            if(pullbackFound)
               break;
           }
        }

      // 3. Check for Fibonacci retracement
      if(!pullbackFound)
        {
         double recentHigh = high[ArrayMaximum(high, 0, lookback)];
         double recentLow = low[ArrayMinimum(low, 0, lookback)];
         double range = recentHigh - recentLow;

         double fib382 = recentLow + range * 0.382;
         double fib50 = recentLow + range * 0.5;
         double fib618 = recentLow + range * 0.618;

         for(int i = 0; i < lookback - 1; i++)
           {
            if((high[i] >= fib382 * 0.998 && high[i] <= fib382 * 1.002) ||
               (high[i] >= fib50 * 0.998 && high[i] <= fib50 * 1.002) ||
               (high[i] >= fib618 * 0.998 && high[i] <= fib618 * 1.002))
              {
               pullbackFound = true;
               LogMessage("Pullback found: Fibonacci retracement level");
               break;
              }
           }
        }
     }

   LogMessage("Pullback check result: " + (pullbackFound ? "FOUND" : "NOT FOUND"));
   return pullbackFound;
  }

//+------------------------------------------------------------------+
//| Check if currently in pullback                                  |
//+------------------------------------------------------------------+
bool IsInPullback(bool isBullish)
  {
   double rsi[];
   ArraySetAsSeries(rsi, true);
   CopyBuffer(handle_rsi, 0, 0, 3, rsi);

   double kama_value = GetKAMAValue(0);
   double current_price = symbol_info.Bid();
   double distance_percent = ((current_price - kama_value) / kama_value) * 100;

   if(isBullish)
     {
      // In pullback if: RSI < 50, price near KAMA, or recent down move
      return (rsi[0] < 50 || MathAbs(distance_percent) < 0.5 ||
              symbol_info.Bid() < iClose(_Symbol, PERIOD_CURRENT, 1));
     }
   else
     {
      // In pullback if: RSI > 50, price near KAMA, or recent up move
      return (rsi[0] > 50 || MathAbs(distance_percent) < 0.5 ||
              symbol_info.Ask() > iClose(_Symbol, PERIOD_CURRENT, 1));
     }
  }
//+------------------------------------------------------------------+
//| Scan for Cup and Handle patterns                                 |
//+------------------------------------------------------------------+
void ScanCupAndHandlePatterns()
  {
//--- ADDED: Check if pattern should be traded
   if(!ShouldTradePattern("CUP_AND_HANDLE"))
      return;

//--- ADDED: Get adaptive thresholds
   AdaptiveThresholds thresholds = GetAdaptiveThresholds();

   double high[], low[], close[];
   long volume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);

   int bars = CopyHigh(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, low);
   CopyClose(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, close);
   CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, volume);

   if(bars < MinPatternBars * 3)
      return;

//--- Look for cup formation (U-shape)
   for(int i = MinPatternBars * 2; i < bars - 20; i++)
     {
      //--- Find potential left lip
      if(IsLocalHigh(high, i, 5))
        {
         double leftLip = high[i];

         //--- Find cup bottom
         double cupBottom = leftLip;
         int bottomIndex = -1;
         for(int j = i - 10; j > i - MinPatternBars * 2 && j > 20; j--)
           {
            if(low[j] < cupBottom)
              {
               cupBottom = low[j];
               bottomIndex = j;
              }
           }

         if(bottomIndex < 0)
            continue;

         //--- Check cup depth (USING ADAPTIVE THRESHOLDS)
         double cupDepth = (leftLip - cupBottom) / leftLip;
         if(cupDepth < thresholds.cupHandleDepthMin ||
            cupDepth > thresholds.cupHandleDepthMax)
            continue;  // CHANGED: Use adaptive thresholds

         //--- Rest of the function remains the same...
         //--- Find right lip (should be near left lip level)
         int rightLipIndex = -1;
         for(int k = bottomIndex - 5; k > 10; k--)
           {
            if(IsLocalHigh(high, k, 3))
              {
               double rightLip = high[k];
               if(MathAbs(rightLip - leftLip) / leftLip < 0.05)   // Within 5%
                 {
                  rightLipIndex = k;
                  break;
                 }
              }
           }

         if(rightLipIndex < 0)
            continue;

         //--- Look for handle formation
         bool handleFound = false;
         double handleLow = high[rightLipIndex];
         int handleEndIndex = -1;

         for(int h = rightLipIndex - 3; h >= 0; h--)
           {
            if(low[h] < handleLow)
               handleLow = low[h];

            //--- Handle should be shallow (less than 50% of cup depth)
            double handleDepth = (high[rightLipIndex] - handleLow) / (leftLip - cupBottom);
            if(handleDepth > 0.5)
               break;

            //--- Check if price is breaking out
            if(h <= 5 && close[h] > high[rightLipIndex])
              {
               handleFound = true;
               handleEndIndex = h;
               break;
              }
           }

         if(handleFound)
           {
            //--- Validate volume pattern
            double volumeScore = AnalyzeCupHandleVolume(i, bottomIndex, rightLipIndex, handleEndIndex, volume);

            if(volumeScore >= 60)
              {
               //--- Create pattern
               PatternData pattern;
               pattern.patternType = "CUP_AND_HANDLE";
               pattern.formationStart = iTime(_Symbol, PERIOD_CURRENT, i);
               pattern.formationEnd = iTime(_Symbol, PERIOD_CURRENT, handleEndIndex);
               pattern.entryPrice = high[rightLipIndex] + symbol_info.Point() * 10;
               pattern.stopLoss = handleLow - symbol_info.Point() * 10;
               pattern.takeProfit = pattern.entryPrice + (leftLip - cupBottom);
               pattern.patternHeight = leftLip - cupBottom;
               pattern.qualityScore = 95.0; // Base score for C&H
               pattern.isBullish = true;
               pattern.volumeScore = volumeScore;
               pattern.isValid = true;

               AddPattern(pattern);
               LogMessage(StringFormat("Cup & Handle pattern detected. Entry: %.5f, Stop: %.5f, Target: %.5f",
                                       pattern.entryPrice, pattern.stopLoss, pattern.takeProfit));
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Scan for Head and Shoulders patterns                            |
//+------------------------------------------------------------------+
void ScanHeadAndShouldersPatterns()
  {
//--- ADDED: Check if patterns should be traded
   if(!ShouldTradePattern("HEAD_AND_SHOULDERS") &&
      !ShouldTradePattern("INVERSE_HEAD_AND_SHOULDERS"))
      return;

//--- ADDED: Get adaptive thresholds
   AdaptiveThresholds thresholds = GetAdaptiveThresholds();

   double high[], low[], close[];
   long volume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);

   int bars = CopyHigh(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, low);
   CopyClose(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, close);
   CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, volume);

   if(bars < MinPatternBars)
      return;

//--- Scan for bearish H&S (top)
   if(ShouldTradePattern("HEAD_AND_SHOULDERS"))    // ADDED: Check specific pattern
     {
      for(int i = 15; i < bars - 15; i++)
        {
         if(IsLocalHigh(high, i, 7))
           {
            double head = high[i];

            //--- Find left shoulder
            int leftShoulderIdx = -1;
            double leftShoulder = 0;
            for(int j = i + 5; j < i + 25 && j < bars - 5; j++)
              {
               if(IsLocalHigh(high, j, 5))
                 {
                  leftShoulder = high[j];
                  if(leftShoulder < head * 0.98 && leftShoulder > head * 0.85)
                    {
                     leftShoulderIdx = j;
                     break;
                    }
                 }
              }

            if(leftShoulderIdx < 0)
               continue;

            //--- Find right shoulder
            int rightShoulderIdx = -1;
            double rightShoulder = 0;
            for(int k = i - 5; k > i - 25 && k > 5; k--)
              {
               if(IsLocalHigh(high, k, 5))
                 {
                  rightShoulder = high[k];
                  //--- CHANGED: Use adaptive threshold for shoulder tolerance
                  if(MathAbs(rightShoulder - leftShoulder) / leftShoulder < thresholds.hsShoulderTolerance)
                    {
                     rightShoulderIdx = k;
                     break;
                    }
                 }
              }

            if(rightShoulderIdx < 0)
               continue;

            //--- Rest of the function continues as before...
            //--- Find neckline
            double neckline = low[i];
            for(int n = leftShoulderIdx; n >= rightShoulderIdx; n--)
              {
               if(n != i)
                 {
                  double valleyLow = low[n];
                  if(IsLocalLow(low, n, 3))
                    {
                     neckline = MathMin(neckline, valleyLow);
                    }
                 }
              }

            //--- Check if neckline is being broken
            bool necklineBroken = false;
            for(int b = rightShoulderIdx - 1; b >= 0 && b >= rightShoulderIdx - 10; b--)
              {
               if(close[b] < neckline)
                 {
                  necklineBroken = true;

                  //--- Validate volume pattern
                  double volumeScore = AnalyzeHSVolume(leftShoulderIdx, i, rightShoulderIdx, b, volume);

                  if(volumeScore >= 60)
                    {
                     //--- Create pattern
                     PatternData pattern;
                     pattern.patternType = "HEAD_AND_SHOULDERS";
                     pattern.formationStart = iTime(_Symbol, PERIOD_CURRENT, leftShoulderIdx);
                     pattern.formationEnd = iTime(_Symbol, PERIOD_CURRENT, b);
                     pattern.entryPrice = neckline - symbol_info.Point() * 10;
                     pattern.stopLoss = rightShoulder + symbol_info.Point() * 20;
                     pattern.takeProfit = neckline - (head - neckline);
                     pattern.patternHeight = head - neckline;
                     pattern.qualityScore = 81.0;
                     pattern.isBullish = false;
                     pattern.volumeScore = volumeScore;
                     pattern.isValid = true;

                     //--- Check for divergence
                     if(UseDivergenceDetection)
                       {
                        pattern.hasDivergence = CheckBearishDivergence(leftShoulderIdx, i, rightShoulderIdx);
                        if(pattern.hasDivergence)
                           pattern.qualityScore += 9.0; // Boost to 90%
                       }

                     AddPattern(pattern);
                     LogMessage(StringFormat("Head & Shoulders pattern detected. Entry: %.5f, Stop: %.5f, Target: %.5f",
                                             pattern.entryPrice, pattern.stopLoss, pattern.takeProfit));
                    }
                  break;
                 }
              }
           }
        }
     }
//--- Scan for bullish Inverse H&S (bottom)
//--- ADDED: Check if patterns should be traded
   if(!ShouldTradePattern("HEAD_AND_SHOULDERS") &&
      !ShouldTradePattern("INVERSE_HEAD_AND_SHOULDERS"))
      return;

   for(int i = 15; i < bars - 15; i++)
     {
      if(IsLocalLow(low, i, 7))
        {
         double head = low[i];

         //--- Find left shoulder
         int leftShoulderIdx = -1;
         double leftShoulder = 0;
         for(int j = i + 5; j < i + 25 && j < bars - 5; j++)
           {
            if(IsLocalLow(low, j, 5))
              {
               leftShoulder = low[j];
               if(leftShoulder > head * 1.02 && leftShoulder < head * 1.15)
                 {
                  leftShoulderIdx = j;
                  break;
                 }
              }
           }

         if(leftShoulderIdx < 0)
            continue;

         //--- Find right shoulder
         int rightShoulderIdx = -1;
         double rightShoulder = 0;
         for(int k = i - 5; k > i - 25 && k > 5; k--)
           {
            if(IsLocalLow(low, k, 5))
              {
               rightShoulder = low[k];
               if(MathAbs(rightShoulder - leftShoulder) / leftShoulder < 0.05)
                 {
                  rightShoulderIdx = k;
                  break;
                 }
              }
           }

         if(rightShoulderIdx < 0)
            continue;

         //--- Find neckline
         double neckline = high[i];
         for(int n = leftShoulderIdx; n >= rightShoulderIdx; n--)
           {
            if(n != i)
              {
               double peakHigh = high[n];
               if(IsLocalHigh(high, n, 3))
                 {
                  neckline = MathMax(neckline, peakHigh);
                 }
              }
           }

         //--- Check if neckline is being broken
         bool necklineBroken = false;
         for(int b = rightShoulderIdx - 1; b >= 0 && b >= rightShoulderIdx - 10; b--)
           {
            if(close[b] > neckline)
              {
               necklineBroken = true;

               //--- Validate volume
               double volumeScore = AnalyzeHSVolume(leftShoulderIdx, i, rightShoulderIdx, b, volume);

               if(volumeScore >= 60)
                 {
                  //--- Create pattern
                  PatternData pattern;
                  pattern.patternType = "INVERSE_HEAD_AND_SHOULDERS";
                  pattern.formationStart = iTime(_Symbol, PERIOD_CURRENT, leftShoulderIdx);
                  pattern.formationEnd = iTime(_Symbol, PERIOD_CURRENT, b);
                  pattern.entryPrice = neckline + symbol_info.Point() * 10;
                  pattern.stopLoss = rightShoulder - symbol_info.Point() * 20;
                  pattern.takeProfit = neckline + (neckline - head);
                  pattern.patternHeight = neckline - head;
                  pattern.qualityScore = 90.0; // Higher for inverse
                  pattern.isBullish = true;
                  pattern.volumeScore = volumeScore;
                  pattern.isValid = true;

                  //--- Check for divergence
                  if(UseDivergenceDetection)
                    {
                     pattern.hasDivergence = CheckBullishDivergence(leftShoulderIdx, i, rightShoulderIdx);
                     if(pattern.hasDivergence)
                        pattern.qualityScore = 95.0;
                    }

                  AddPattern(pattern);
                  LogMessage(StringFormat("Inverse H&S pattern detected. Entry: %.5f, Stop: %.5f, Target: %.5f",
                                          pattern.entryPrice, pattern.stopLoss, pattern.takeProfit));
                 }
               break;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Scan for Double Bottom patterns                                  |
//+------------------------------------------------------------------+
void ScanDoubleBottomPatterns()
  {
//--- ADDED: Check if pattern should be traded
   if(!ShouldTradePattern("DOUBLE_BOTTOM"))
      return;

//--- ADDED: Get adaptive thresholds
   AdaptiveThresholds thresholds = GetAdaptiveThresholds();

   double high[], low[], close[];
   long volume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);

   int bars = CopyHigh(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, low);
   CopyClose(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, close);
   CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, volume);

   if(bars < MinPatternBars)
      return;

//--- Scan for double bottoms
   for(int i = 10; i < bars - 10; i++)
     {
      if(IsLocalLow(low, i, 5))
        {
         double firstBottom = low[i];

         //--- Look for second bottom
         for(int j = i - 10; j > i - 40 && j > 5; j--)
           {
            if(IsLocalLow(low, j, 5))
              {
               double secondBottom = low[j];

               //--- CHANGED: Use adaptive threshold for bottom tolerance
               if(MathAbs(secondBottom - firstBottom) / firstBottom < thresholds.doubleBottomTolerance)
                 {
                  //--- Rest of the function continues as before...

                  //--- Find peak between bottoms
                  double peakHigh = 0;
                  int peakIndex = -1;
                  for(int k = i - 1; k > j; k--)
                    {
                     if(high[k] > peakHigh)
                       {
                        peakHigh = high[k];
                        peakIndex = k;
                       }
                    }

                  //--- Peak should be significant (at least 5% above bottoms)
                  double patternHeight = peakHigh - MathMin(firstBottom, secondBottom);
                  if(patternHeight / MathMin(firstBottom, secondBottom) < 0.05)
                     continue;

                  //--- Check for breakout above peak
                  bool breakoutFound = false;
                  for(int b = j - 1; b >= 0 && b >= j - 10; b--)
                    {
                     if(close[b] > peakHigh)
                       {
                        breakoutFound = true;

                        //--- Validate volume
                        double volumeScore = AnalyzeDoubleBottomVolume(i, peakIndex, j, b, volume);

                        if(volumeScore >= 60)
                          {
                           //--- Create pattern
                           PatternData pattern;
                           pattern.patternType = "DOUBLE_BOTTOM";
                           pattern.formationStart = iTime(_Symbol, PERIOD_CURRENT, i);
                           pattern.formationEnd = iTime(_Symbol, PERIOD_CURRENT, b);
                           pattern.entryPrice = peakHigh + symbol_info.Point() * 10;
                           pattern.stopLoss = MathMin(firstBottom, secondBottom) - symbol_info.Point() * 20;
                           pattern.takeProfit = peakHigh + patternHeight * 1.5; // 150% extension
                           pattern.patternHeight = patternHeight;
                           pattern.qualityScore = 81.0;
                           pattern.isBullish = true;
                           pattern.volumeScore = volumeScore;
                           pattern.isValid = true;

                           //--- Check support alignment
                           pattern.supportResistanceAlignment = CheckSupportAlignment(MathMin(firstBottom, secondBottom));
                           if(pattern.supportResistanceAlignment > 0)
                             {
                              pattern.qualityScore += 5.0;
                             }

                           AddPattern(pattern);
                           LogMessage(StringFormat("Double Bottom pattern detected. Entry: %.5f, Stop: %.5f, Target: %.5f",
                                                   pattern.entryPrice, pattern.stopLoss, pattern.takeProfit));
                          }
                        break;
                       }
                    }

                  if(breakoutFound)
                     break;
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Scan for Rounding Bottom patterns (97% success rate)            |
//+------------------------------------------------------------------+
void ScanRoundingBottomPatterns()
  {
//--- ADDED: Check if pattern should be traded
   if(!ShouldTradePattern("ROUNDING_BOTTOM"))
      return;

//--- ADDED: Get adaptive thresholds
   AdaptiveThresholds thresholds = GetAdaptiveThresholds();

// Rest of the function remains the same as it doesn't use specific thresholds
// but the pattern check at the beginning will disable it if performing poorly

   double high[], low[], close[];
   long volume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);

   int bars = CopyHigh(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, low);
   CopyClose(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, close);
   CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, volume);

   if(bars < MinPatternBars * 2)
      return; // Rounding bottoms need more bars

//--- Look for U-shaped formations
   for(int center = 40; center < bars - 40; center++)
     {
      //--- Check if this could be the bottom of a rounding formation
      if(!IsLocalLow(low, center, 20))
         continue;

      //--- Analyze the curve on both sides
      bool isRoundingBottom = true;
      double centerLow = low[center];

      //--- Left side analysis
      double leftGradient = 0;
      for(int i = center + 30; i > center + 5; i--)
        {
         double expectedLow = centerLow + MathPow((i - center) / 30.0, 2) * (high[center + 30] - centerLow);
         if(MathAbs(low[i] - expectedLow) / expectedLow > 0.1)
           {
            isRoundingBottom = false;
            break;
           }
         leftGradient += (low[i] - low[i+1]);
        }

      if(!isRoundingBottom)
         continue;

      //--- Right side analysis
      double rightGradient = 0;
      for(int i = center - 5; i > center - 30 && i >= 0; i--)
        {
         double expectedLow = centerLow + MathPow((center - i) / 30.0, 2) * (high[center - 30] - centerLow);
         if(MathAbs(low[i] - expectedLow) / expectedLow > 0.1)
           {
            isRoundingBottom = false;
            break;
           }
         rightGradient += (low[i-1] - low[i]);
        }

      if(!isRoundingBottom)
         continue;

      //--- Check for breakout
      double neckline = MathMax(high[center + 30], high[center - 30]);
      for(int b = center - 35; b >= 0 && b >= center - 40; b--)
        {
         if(close[b] > neckline)
           {
            //--- Validate volume pattern (should be low at bottom, increasing on breakout)
            double volumeScore = AnalyzeRoundingBottomVolume(center + 30, center, center - 30, b, volume);

            if(volumeScore >= 60)
              {
               PatternData pattern;
               pattern.patternType = "ROUNDING_BOTTOM";
               pattern.formationStart = iTime(_Symbol, PERIOD_CURRENT, center + 30);
               pattern.formationEnd = iTime(_Symbol, PERIOD_CURRENT, b);
               pattern.entryPrice = neckline + symbol_info.Point() * 10;
               pattern.stopLoss = centerLow - symbol_info.Point() * 20;
               pattern.takeProfit = neckline + (neckline - centerLow) * 0.64; // 64% target probability
               pattern.patternHeight = neckline - centerLow;
               pattern.qualityScore = 97.0; // Highest success rate!
               pattern.isBullish = true;
               pattern.volumeScore = volumeScore;
               pattern.isValid = true;

               AddPattern(pattern);
               LogMessage(StringFormat("Rounding Bottom pattern detected. Entry: %.5f, Stop: %.5f, Target: %.5f",
                                       pattern.entryPrice, pattern.stopLoss, pattern.takeProfit));
              }
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Scan for Triangle patterns                                       |
//+------------------------------------------------------------------+
void ScanTrianglePatterns()
  {
//--- ADDED: Check if patterns should be traded
   if(!ShouldTradePattern("ASCENDING_TRIANGLE") &&
      !ShouldTradePattern("DESCENDING_TRIANGLE") &&
      !ShouldTradePattern("SYMMETRICAL_TRIANGLE"))
      return;

//--- ADDED: Get adaptive thresholds
   AdaptiveThresholds thresholds = GetAdaptiveThresholds();

   double high[], low[], close[];
   long volume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);

   int bars = CopyHigh(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, low);
   CopyClose(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, close);
   CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, volume);

   if(bars < MinPatternBars)
      return;

//--- Look for converging highs and lows
   for(int start = MinPatternBars; start < bars - 20; start++)
     {
      //--- Get trend lines
      double upperSlope, lowerSlope;
      double upperIntercept, lowerIntercept;

      if(!CalculateTrendLines(high, low, start, 20, upperSlope, upperIntercept, lowerSlope, lowerIntercept))
         continue;

      //--- Determine triangle type
      string triangleType = "";
      double successRate = 0;

      //--- CHANGED: Use adaptive threshold for convergence
      if(MathAbs(upperSlope) < thresholds.triangleConvergence && lowerSlope > thresholds.triangleConvergence)
        {
         triangleType = "ASCENDING_TRIANGLE";
         successRate = 75.0; // Up to 83% in strong trends
        }
      else
         if(upperSlope < -thresholds.triangleConvergence && MathAbs(lowerSlope) < thresholds.triangleConvergence)
           {
            triangleType = "DESCENDING_TRIANGLE";
            successRate = 70.0; // Up to 87% success
           }
         else
            if(upperSlope < -thresholds.triangleConvergence && lowerSlope > thresholds.triangleConvergence)
              {
               triangleType = "SYMMETRICAL_TRIANGLE";
               successRate = 68.0;
              }
            else
               continue;

      //--- ADDED: Check if this specific triangle type should be traded
      if(!ShouldTradePattern(triangleType))
         continue;

      //--- Check for breakout
      for(int b = start - 22; b >= 0 && b >= start - 30; b--)
        {
         bool breakout = false;
         bool bullishBreakout = false;

         double upperLine = upperIntercept + upperSlope * (start - b);
         double lowerLine = lowerIntercept + lowerSlope * (start - b);

         if(close[b] > upperLine)
           {
            breakout = true;
            bullishBreakout = true;
           }
         else
            if(close[b] < lowerLine)
              {
               breakout = true;
               bullishBreakout = false;
              }

         if(breakout)
           {
            double volumeScore = AnalyzeTriangleVolume(start, start - 20, b, volume);

            if(volumeScore >= 60)
              {
               PatternData pattern;
               pattern.patternType = triangleType;
               pattern.formationStart = iTime(_Symbol, PERIOD_CURRENT, start);
               pattern.formationEnd = iTime(_Symbol, PERIOD_CURRENT, b);

               double patternHeight = upperIntercept - lowerIntercept;

               if(bullishBreakout)
                 {
                  pattern.entryPrice = upperLine + symbol_info.Point() * 10;
                  pattern.stopLoss = lowerLine - symbol_info.Point() * 20;
                  pattern.takeProfit = upperLine + patternHeight * 0.75;
                 }
               else
                 {
                  pattern.entryPrice = lowerLine - symbol_info.Point() * 10;
                  pattern.stopLoss = upperLine + symbol_info.Point() * 20;
                  pattern.takeProfit = lowerLine - patternHeight * 0.75;
                 }

               pattern.patternHeight = patternHeight;
               pattern.qualityScore = successRate;
               pattern.isBullish = bullishBreakout;
               pattern.volumeScore = volumeScore;
               pattern.isValid = true;

               AddPattern(pattern);
               LogMessage(StringFormat("%s pattern detected. Entry: %.5f, Stop: %.5f, Target: %.5f",
                                       triangleType, pattern.entryPrice, pattern.stopLoss, pattern.takeProfit));
              }
            break;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Scan for Flag patterns                                           |
//+------------------------------------------------------------------+
void ScanFlagPatterns()
  {
//--- ADDED: Check if patterns should be traded
   if(!ShouldTradePattern("BULL_FLAG") && !ShouldTradePattern("BEAR_FLAG"))
      return;

//--- ADDED: Get adaptive thresholds
   AdaptiveThresholds thresholds = GetAdaptiveThresholds();

   double high[], low[], close[], open[];
   long volume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(volume, true);

   int bars = CopyHigh(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, low);
   CopyClose(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, close);
   CopyOpen(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, open);
   CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, MaxPatternBars, volume);

   if(bars < 30)
      return;

//--- Look for strong directional moves (flagpoles)
   for(int i = 10; i < 40; i++)
     {
      double moveSize = MathAbs(close[i] - close[i+8]);
      double avgCandle = GetAverageCandle(20);

      //--- Flagpole should be at least 3x average candle
      if(moveSize < avgCandle * 3)
         continue;

      bool isBullishPole = close[i] > close[i+8];

      //--- ADDED: Check if this specific flag type should be traded
      if(isBullishPole && !ShouldTradePattern("BULL_FLAG"))
         continue;
      if(!isBullishPole && !ShouldTradePattern("BEAR_FLAG"))
         continue;

      //--- Look for consolidation (flag)
      bool validFlag = true;
      double flagHigh = high[i], flagLow = low[i];

      for(int j = i - 1; j >= i - 8 && j >= 0; j--)
        {
         flagHigh = MathMax(flagHigh, high[j]);
         flagLow = MathMin(flagLow, low[j]);

         //--- CHANGED: Use adaptive threshold for flag retracement
         if((flagHigh - flagLow) > moveSize * thresholds.flagRetracement)
           {
            validFlag = false;
            break;
           }
        }

      if(!validFlag)
         continue;

      //--- Check for breakout
      for(int b = i - 9; b >= 0 && b >= i - 15; b--)
        {
         bool breakout = false;

         if(isBullishPole && close[b] > flagHigh)
           {
            breakout = true;
           }
         else
            if(!isBullishPole && close[b] < flagLow)
              {
               breakout = true;
              }

         if(breakout)
           {
            double volumeScore = AnalyzeFlagVolume(i+8, i, b, volume);

            if(volumeScore >= 60)
              {
               PatternData pattern;
               pattern.patternType = isBullishPole ? "BULL_FLAG" : "BEAR_FLAG";
               pattern.formationStart = iTime(_Symbol, PERIOD_CURRENT, i+8);
               pattern.formationEnd = iTime(_Symbol, PERIOD_CURRENT, b);

               if(isBullishPole)
                 {
                  pattern.entryPrice = flagHigh + symbol_info.Point() * 10;
                  pattern.stopLoss = flagLow - symbol_info.Point() * 20;
                  pattern.takeProfit = flagHigh + moveSize * 0.618;
                 }
               else
                 {
                  pattern.entryPrice = flagLow - symbol_info.Point() * 10;
                  pattern.stopLoss = flagHigh + symbol_info.Point() * 20;
                  pattern.takeProfit = flagLow - moveSize * 0.618;
                 }

               pattern.patternHeight = moveSize;
               pattern.qualityScore = 75.0; // 70-80% success in trends
               pattern.volumeScore = volumeScore;
               pattern.isBullish = isBullishPole;
               pattern.isValid = true;

               AddPattern(pattern);
               LogMessage(StringFormat("%s pattern detected. Entry: %.5f, Stop: %.5f, Target: %.5f",
                                       pattern.patternType, pattern.entryPrice, pattern.stopLoss, pattern.takeProfit));
              }
            break;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Volume analysis for Cup and Handle                              |
//+------------------------------------------------------------------+
double AnalyzeCupHandleVolume(int leftLip, int bottom, int rightLip, int breakout, const long &volume[])
  {
   double score = 50.0; // Base score

//--- Calculate average volumes for different phases
   double leftVolAvg = 0, bottomVolAvg = 0, rightVolAvg = 0, handleVolAvg = 0;
   int leftCount = 0, bottomCount = 0, rightCount = 0, handleCount = 0;

//--- Left side of cup
   for(int i = leftLip; i > bottom + (leftLip - bottom) / 2; i--)
     {
      leftVolAvg += (double)volume[i];  // FIXED: Added explicit cast
      leftCount++;
     }
   if(leftCount > 0)
      leftVolAvg /= leftCount;

//--- Bottom of cup
   for(int i = bottom - 5; i <= bottom + 5 && i < leftLip; i++)
     {
      if(i >= 0)
        {
         bottomVolAvg += (double)volume[i];  // FIXED: Added explicit cast
         bottomCount++;
        }
     }
   if(bottomCount > 0)
      bottomVolAvg /= bottomCount;

//--- Right side of cup
   for(int i = bottom - (bottom - rightLip) / 2; i > rightLip; i--)
     {
      if(i >= 0)
        {
         rightVolAvg += (double)volume[i];  // FIXED: Added explicit cast
         rightCount++;
        }
     }
   if(rightCount > 0)
      rightVolAvg /= rightCount;

//--- Handle
   for(int i = rightLip - 1; i > breakout; i--)
     {
      if(i >= 0)
        {
         handleVolAvg += (double)volume[i];  // FIXED: Added explicit cast
         handleCount++;
        }
     }
   if(handleCount > 0)
      handleVolAvg /= handleCount;

//--- Volume should be lower at bottom than sides
   if(bottomVolAvg < leftVolAvg * VolumeDeclineRatio)
      score += 15.0;
   if(bottomVolAvg < rightVolAvg * VolumeDeclineRatio)
      score += 15.0;

//--- Handle volume should be declining
   if(handleVolAvg < rightVolAvg * VolumeDeclineRatio)
      score += 10.0;

//--- Breakout volume should be high
   if(breakout >= 0 && (double)volume[breakout] > rightVolAvg * BreakoutVolumeMultiple)    // FIXED
     {
      score += 10.0;
     }

   return MathMin(score, 100.0);
  }
//+------------------------------------------------------------------+
//| Volume analysis for Head and Shoulders                          |
//+------------------------------------------------------------------+
double AnalyzeHSVolume(int leftShoulder, int head, int rightShoulder, int breakout, const long &volume[])
  {
   double score = 50.0;

//--- Volume should be highest at left shoulder, declining through pattern
   if((double)volume[leftShoulder] > (double)volume[head])
      score += 15.0;
   if((double)volume[head] > (double)volume[rightShoulder])
      score += 15.0;

//--- Right shoulder volume should be notably lower
   if((double)volume[rightShoulder] < (double)volume[leftShoulder] * 0.7)
      score += 10.0;

//--- Breakout volume should increase
   double avgVolume = ((double)volume[leftShoulder] + (double)volume[head] + (double)volume[rightShoulder]) / 3;
   if((double)volume[breakout] > avgVolume * BreakoutVolumeMultiple)
      score += 10.0;

   return MathMin(score, 100.0);
  }

//+------------------------------------------------------------------+
//| Volume analysis for Double Bottom                                |
//+------------------------------------------------------------------+
double AnalyzeDoubleBottomVolume(int first, int peak, int second, int breakout, const long &volume[])
  {
   double score = 50.0;

//--- Second bottom should have lower volume than first
   if((double)volume[second] < (double)volume[first])
      score += 20.0;

//--- Peak volume should be moderate
   double avgBottomVol = ((double)volume[first] + (double)volume[second]) / 2;
   if((double)volume[peak] < avgBottomVol * 1.5)
      score += 15.0;

//--- Breakout volume should be high
   if((double)volume[breakout] > avgBottomVol * BreakoutVolumeMultiple)
      score += 15.0;

   return MathMin(score, 100.0);
  }

//+------------------------------------------------------------------+
//| Volume analysis for Rounding Bottom                              |
//+------------------------------------------------------------------+
double AnalyzeRoundingBottomVolume(int left, int bottom, int right, int breakout, const long &volume[])
  {
   double score = 50.0;

//--- Volume should be lowest at the bottom
   double bottomAvgVol = 0;
   int bottomCount = 0;
   for(int i = bottom - 5; i <= bottom + 5 && i >= 0 && i < left; i++)
     {
      bottomAvgVol += (double)volume[i];
      bottomCount++;
     }
   if(bottomCount > 0)
      bottomAvgVol /= bottomCount;

//--- Side volumes
   double sideAvgVol = ((double)volume[left] + (double)volume[right]) / 2;

//--- Bottom volume should be low
   if(bottomAvgVol < sideAvgVol * 0.7)
      score += 25.0;

//--- Breakout volume should be high
   if((double)volume[breakout] > sideAvgVol * BreakoutVolumeMultiple)
      score += 25.0;

   return MathMin(score, 100.0);
  }

//+------------------------------------------------------------------+
//| Volume analysis for Triangles                                    |
//+------------------------------------------------------------------+
double AnalyzeTriangleVolume(int start, int end, int breakout, const long &volume[])
  {
   double score = 50.0;

//--- Volume should decline during triangle formation
   double earlyVol = 0, lateVol = 0;
   int count = (start - end) / 2;

   for(int i = 0; i < count; i++)
     {
      if(start - i >= 0)
         earlyVol += (double)volume[start - i];
      if(end + i >= 0)
         lateVol += (double)volume[end + i];
     }

   earlyVol /= count;
   lateVol /= count;

   if(lateVol < earlyVol * 0.8)
      score += 25.0;

//--- Breakout volume
   if((double)volume[breakout] > earlyVol * BreakoutVolumeMultiple)
      score += 25.0;

   return MathMin(score, 100.0);
  }

//+------------------------------------------------------------------+
//| Volume analysis for Flags                                        |
//+------------------------------------------------------------------+
double AnalyzeFlagVolume(int poleStart, int flagStart, int breakout, const long &volume[])
  {
   double score = 50.0;

//--- High volume during pole formation
   double poleAvgVol = 0;
   for(int i = poleStart; i > flagStart; i--)
     {
      poleAvgVol += (double)volume[i];
     }
   poleAvgVol /= (poleStart - flagStart);

//--- Lower volume during flag
   double flagAvgVol = 0;
   for(int i = flagStart; i > breakout + 1; i--)
     {
      flagAvgVol += (double)volume[i];
     }
   flagAvgVol /= (flagStart - breakout - 1);

   if(flagAvgVol < poleAvgVol * 0.6)
      score += 25.0;

//--- Breakout volume
   if((double)volume[breakout] > poleAvgVol * 0.8)
      score += 25.0;

   return MathMin(score, 100.0);
  }

//+------------------------------------------------------------------+
//| Calculate trend lines for triangle detection                     |
//+------------------------------------------------------------------+
bool CalculateTrendLines(const double &high[], const double &low[], int start, int length,
                         double &upperSlope, double &upperIntercept,
                         double &lowerSlope, double &lowerIntercept)
  {
//--- Find highs and lows
   CArrayDouble highPoints, lowPoints;

   for(int i = start; i > start - length && i >= 0; i--)
     {
      if(IsLocalHigh(high, i, 3))
         highPoints.Add(high[i]);
      if(IsLocalLow(low, i, 3))
         lowPoints.Add(low[i]);
     }

   if(highPoints.Total() < 2 || lowPoints.Total() < 2)
      return false;

//--- Simple linear regression for upper and lower lines
   upperSlope = (highPoints[highPoints.Total()-1] - highPoints[0]) / length;
   upperIntercept = highPoints[0];

   lowerSlope = (lowPoints[lowPoints.Total()-1] - lowPoints[0]) / length;
   lowerIntercept = lowPoints[0];

   return true;
  }

//+------------------------------------------------------------------+
//| Get average candle size                                         |
//+------------------------------------------------------------------+
double GetAverageCandle(int period)
  {
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, period, high) < period)
      return 0;
   if(CopyLow(_Symbol, PERIOD_CURRENT, 0, period, low) < period)
      return 0;

   double sum = 0;
   for(int i = 0; i < period; i++)
     {
      sum += high[i] - low[i];
     }

   return sum / period;
  }

//+------------------------------------------------------------------+
//| Analyze order flow for pattern confirmation                      |
//+------------------------------------------------------------------+
double AnalyzeOrderFlow(int startBar, int endBar, bool isBullishPattern)
  {
// If DOM is available and UseOrderFlowAnalysis is true, use enhanced analysis
   if(UseOrderFlowAnalysis && IsDOMAvailable())
     {
      return AnalyzeEnhancedOrderFlow(startBar, endBar, isBullishPattern);
     }

   double score = 50.0; // Base score

//--- Validate bar indices
   if(startBar < 0 || endBar < 0 || startBar <= endBar)
     {
      LogMessage("Invalid bar indices in AnalyzeOrderFlow");
      return score;
     }

   int barCount = startBar - endBar + 1;
   if(barCount <= 0)
      return score;

//--- Initialize arrays
   ArrayResize(orderFlow.deltaVolume, barCount);
   ArrayResize(orderFlow.volumeProfile, 50); // 50 price levels

   double high[], low[], close[];
   long volume[], tickVolume[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(tickVolume, true);

//--- Copy data starting from endBar (more recent) with barCount bars
   if(CopyHigh(_Symbol, PERIOD_CURRENT, endBar, barCount, high) != barCount ||
      CopyLow(_Symbol, PERIOD_CURRENT, endBar, barCount, low) != barCount ||
      CopyClose(_Symbol, PERIOD_CURRENT, endBar, barCount, close) != barCount ||
      CopyTickVolume(_Symbol, PERIOD_CURRENT, endBar, barCount, tickVolume) != barCount ||
      CopyRealVolume(_Symbol, PERIOD_CURRENT, endBar, barCount, volume) != barCount)
     {
      LogMessage("Failed to copy market data in AnalyzeOrderFlow");
      return score;
     }

//--- Validate arrays are properly filled
   if(ArraySize(close) < 1 || ArraySize(high) < 1 || ArraySize(low) < 1 || ArraySize(tickVolume) < 1)
     {
      LogMessage("Arrays not properly filled in AnalyzeOrderFlow");
      return score;
     }

//--- Calculate delta volume for each bar
   double totalBuyVolume = 0, totalSellVolume = 0;
   orderFlow.cumulativeDelta = 0;

   for(int i = 0; i < barCount; i++)
     {
      //--- Validate array access
      if(i >= ArraySize(high) || i >= ArraySize(low) || i >= ArraySize(close) || i >= ArraySize(tickVolume))
        {
         break;
        }

      //--- Estimate buy/sell volume based on close position within bar
      double range = high[i] - low[i];
      if(range > 0)
        {
         double closePosition = (close[i] - low[i]) / range;
         double buyVol = (double)tickVolume[i] * closePosition;
         double sellVol = (double)tickVolume[i] * (1 - closePosition);

         if(i < ArraySize(orderFlow.deltaVolume))
           {
            orderFlow.deltaVolume[i] = buyVol - sellVol;
            orderFlow.cumulativeDelta += orderFlow.deltaVolume[i];
           }

         totalBuyVolume += buyVol;
         totalSellVolume += sellVol;
        }
     }

//--- Calculate buy/sell pressure
   double totalVolume = totalBuyVolume + totalSellVolume;
   if(totalVolume > 0)
     {
      orderFlow.buyPressure = totalBuyVolume / totalVolume;
      orderFlow.sellPressure = totalSellVolume / totalVolume;
     }

//--- Score based on order flow alignment
   if(isBullishPattern)
     {
      if(orderFlow.buyPressure > 0.55)
         score += 15.0;
      if(orderFlow.buyPressure > 0.60)
         score += 10.0;
      if(orderFlow.cumulativeDelta > 0)
         score += 10.0;
     }
   else
     {
      if(orderFlow.sellPressure > 0.55)
         score += 15.0;
      if(orderFlow.sellPressure > 0.60)
         score += 10.0;
      if(orderFlow.cumulativeDelta < 0)
         score += 10.0;
     }

//--- Check for delta divergence (using array indices 0 and barCount-1)
   if(barCount >= 2)
     {
      CheckDeltaDivergence(high, low, close, 0, barCount - 1);
      if(orderFlow.deltaDivergence)
        {
         if(isBullishPattern)
            score += 15.0; // Bullish divergence supports bullish pattern
        }
     }

//--- Volume profile analysis
   if(barCount >= 2)
     {
      CalculateVolumeProfile(high, low, tickVolume, 0, barCount - 1);
     }

//--- Score based on POC position - FIXED: Check array size before access
   if(ArraySize(close) > 0)
     {
      double currentPrice = close[0];
      if(isBullishPattern && currentPrice > orderFlow.poc)
         score += 10.0;
      if(!isBullishPattern && currentPrice < orderFlow.poc)
         score += 10.0;
     }

   return MathMin(score, 100.0);
  }
//+------------------------------------------------------------------+
//| Check for delta divergence                                       |
//+------------------------------------------------------------------+
void CheckDeltaDivergence(const double &high[], const double &low[], const double &close[],
                          int startIdx, int endIdx)
  {
//--- Validate array indices
   if(startIdx < 0 || endIdx < 0 || startIdx >= ArraySize(close) || endIdx >= ArraySize(close))
     {
      orderFlow.deltaDivergence = false;
      return;
     }

//--- Simple divergence: price makes new high/low but delta doesn't
   double priceChange = close[endIdx] - close[startIdx];

   orderFlow.deltaDivergence = false;

   if(priceChange > 0 && orderFlow.cumulativeDelta < 0)
     {
      orderFlow.deltaDivergence = true; // Bearish divergence
     }
   else
      if(priceChange < 0 && orderFlow.cumulativeDelta > 0)
        {
         orderFlow.deltaDivergence = true; // Bullish divergence
        }
  }
//+------------------------------------------------------------------+
//| Calculate volume profile                                         |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate volume profile                                         |
//+------------------------------------------------------------------+
void CalculateVolumeProfile(const double &high[], const double &low[],
                            const long &volume[], int startIdx, int endIdx)
  {
//--- Validate indices
   if(startIdx < 0 || endIdx < 0 || startIdx >= ArraySize(high) || endIdx >= ArraySize(high) ||
      startIdx >= ArraySize(low) || endIdx >= ArraySize(low) || startIdx >= ArraySize(volume) || endIdx >= ArraySize(volume))
     {
      return;
     }

//--- Find price range within the valid index range
   double maxPrice = high[startIdx];
   double minPrice = low[startIdx];

   for(int i = startIdx; i <= endIdx && i < ArraySize(high); i++)
     {
      if(high[i] > maxPrice)
         maxPrice = high[i];
      if(low[i] < minPrice)
         minPrice = low[i];
     }

   if(maxPrice <= minPrice)
      return; // Invalid price range

   double priceStep = (maxPrice - minPrice) / 50;
   if(priceStep <= 0)
      return;

//--- Clear volume profile
   ArrayInitialize(orderFlow.volumeProfile, 0);

//--- Distribute volume across price levels
   for(int i = startIdx; i <= endIdx && i < ArraySize(volume); i++)
     {
      if(i < ArraySize(high) && i < ArraySize(low))
        {
         double barMid = (high[i] + low[i]) / 2;
         int level = (int)((barMid - minPrice) / priceStep);
         if(level >= 0 && level < 50)
           {
            orderFlow.volumeProfile[level] += (double)volume[i];
           }
        }
     }

//--- Find POC (Point of Control)
   int pocLevel = ArrayMaximum(orderFlow.volumeProfile);
   if(pocLevel >= 0 && pocLevel < 50)
     {
      orderFlow.poc = minPrice + pocLevel * priceStep;
     }
   else
     {
      orderFlow.poc = (maxPrice + minPrice) / 2; // Fallback to midpoint
      return;
     }

//--- Calculate Value Area (70% of volume)
   double totalVol = 0;
   for(int i = 0; i < 50; i++)
     {
      totalVol += orderFlow.volumeProfile[i];
     }

   if(totalVol <= 0)
      return;

   double targetVol = totalVol * 0.7;
   double currentVol = orderFlow.volumeProfile[pocLevel];

   int upperLevel = pocLevel, lowerLevel = pocLevel;

   while(currentVol < targetVol && (upperLevel < 49 || lowerLevel > 0))
     {
      if(upperLevel < 49 && (lowerLevel == 0 ||
                             orderFlow.volumeProfile[upperLevel + 1] >= orderFlow.volumeProfile[lowerLevel - 1]))
        {
         upperLevel++;
         if(upperLevel < 50)
            currentVol += orderFlow.volumeProfile[upperLevel];
        }
      else
         if(lowerLevel > 0)
           {
            lowerLevel--;
            currentVol += orderFlow.volumeProfile[lowerLevel];
           }
     }

   orderFlow.vah = minPrice + upperLevel * priceStep;
   orderFlow.val = minPrice + lowerLevel * priceStep;
  }
//+------------------------------------------------------------------+
//| Check for bearish divergence                                     |
//+------------------------------------------------------------------+
bool CheckBearishDivergence(int idx1, int idx2, int idx3)
  {
   double rsi[];
   ArraySetAsSeries(rsi, true);

   if(CopyBuffer(handle_rsi, 0, 0, idx1 + 1, rsi) < idx1 + 1)
      return false;

//--- Price makes higher highs but RSI makes lower highs
   double high[];
   ArraySetAsSeries(high, true);
   CopyHigh(_Symbol, PERIOD_CURRENT, 0, idx1 + 1, high);

   bool priceDivergence = (high[idx2] > high[idx1] && high[idx3] < high[idx2]);
   bool rsiDivergence = (rsi[idx2] < rsi[idx1] || rsi[idx3] < rsi[idx2]);

   return priceDivergence && rsiDivergence;
  }

//+------------------------------------------------------------------+
//| Check for bullish divergence                                     |
//+------------------------------------------------------------------+
bool CheckBullishDivergence(int idx1, int idx2, int idx3)
  {
   double rsi[];
   ArraySetAsSeries(rsi, true);

   if(CopyBuffer(handle_rsi, 0, 0, idx1 + 1, rsi) < idx1 + 1)
      return false;

//--- Price makes lower lows but RSI makes higher lows
   double low[];
   ArraySetAsSeries(low, true);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, idx1 + 1, low);

   bool priceDivergence = (low[idx2] < low[idx1] && low[idx3] > low[idx2]);
   bool rsiDivergence = (rsi[idx2] > rsi[idx1] || rsi[idx3] > rsi[idx2]);

   return priceDivergence && rsiDivergence;
  }
//======================================================
//+------------------------------------------------------------------+
//| Get KAMA value at specified shift                                |
//+------------------------------------------------------------------+
double GetKAMAValue(int shift = 0)
  {
   double kama_buffer[];
   ArraySetAsSeries(kama_buffer, true);

   if(CopyBuffer(handle_ma200, 0, shift, 1, kama_buffer) > 0)
     {
      return kama_buffer[0];
     }

   LogMessage("Failed to get KAMA value at shift " + IntegerToString(shift));
   return 0;
  }

//+------------------------------------------------------------------+
//| Calculate KAMA slope in basis points                             |
//+------------------------------------------------------------------+
double GetKAMASlope(int period = 1)
  {
   double current_kama = GetKAMAValue(0);
   double prev_kama = GetKAMAValue(period);

   if(current_kama > 0 && prev_kama > 0)
     {
      return (current_kama - prev_kama) / prev_kama * 10000; // Slope in basis points
     }

   return 0;
  }

//+------------------------------------------------------------------+
//| Get KAMA trend direction                                         |
//+------------------------------------------------------------------+
string GetKAMATrend()
  {
   double slope = GetKAMASlope();

   if(slope > KAMASlopeThreshold)
     {
      return "BULLISH";
     }
   else
      if(slope < -KAMASlopeThreshold)
        {
         return "BEARISH";
        }
      else
        {
         return "NEUTRAL";
        }
  }

//+------------------------------------------------------------------+
//| Check if price is in KAMA trend direction                        |
//+------------------------------------------------------------------+
bool IsInKAMATrend(bool isBullish)
  {
   if(!UseKAMAFilter)
      return true;

   double current_price = symbol_info.Bid();
   double kama_value = GetKAMAValue(0);
   string kama_trend = GetKAMATrend();

   if(isBullish)
     {
      return (current_price > kama_value && kama_trend != "BEARISH");
     }
   else
     {
      return (current_price < kama_value && kama_trend != "BULLISH");
     }
  }
//=======================================================
//+------------------------------------------------------------------+
//| Update market structure                                          |
//+------------------------------------------------------------------+
void UpdateMarketStructure()
  {
//--- Detect support and resistance levels
   DetectSupportResistance();

//--- Determine market regime
   double adx[], plusDi[], minusDi[], atr[], ma200[];
   ArraySetAsSeries(adx, true);
   ArraySetAsSeries(plusDi, true);
   ArraySetAsSeries(minusDi, true);
   ArraySetAsSeries(atr, true);
   ArraySetAsSeries(ma200, true);

   CopyBuffer(handle_adx, 0, 0, 3, adx);
   CopyBuffer(handle_adx, 1, 0, 3, plusDi);
   CopyBuffer(handle_adx, 2, 0, 3, minusDi);
   CopyBuffer(handle_atr, 0, 0, 20, atr);
   CopyBuffer(handle_ma200, 0, 0, 3, ma200);  // Now copying KAMA values

//--- Get KAMA slope
   double kama_slope = GetKAMASlope();
   string kama_trend = GetKAMATrend();

//--- Calculate volatility
   double avgATR = 0;
   for(int i = 0; i < 20; i++)
      avgATR += atr[i];
   avgATR /= 20;
   marketStructure.volatilityLevel = atr[0] / avgATR;

//--- Determine regime
   marketStructure.trendStrength = adx[0];

   if(adx[0] > ADXThreshold)
     {
      if(plusDi[0] > minusDi[0] && symbol_info.Bid() > ma200[0] && kama_trend == "BULLISH")
        {
         marketStructure.regime = "TRENDING_UP";
        }
      else
         if(minusDi[0] > plusDi[0] && symbol_info.Bid() < ma200[0] && kama_trend == "BEARISH")
           {
            marketStructure.regime = "TRENDING_DOWN";
           }
         else
           {
            marketStructure.regime = "RANGING";
           }
     }
   else
     {
      if(marketStructure.volatilityLevel > 1.5)
        {
         marketStructure.regime = "VOLATILE";
        }
      else
         if(MathAbs(kama_slope) < KAMASlopeThreshold)
           {
            marketStructure.regime = "RANGING";
           }
         else
           {
            marketStructure.regime = kama_slope > 0 ? "TRENDING_UP" : "TRENDING_DOWN";
            marketStructure.trendStrength = MathAbs(kama_slope);
           }
     }

//--- Check volume trend
   long volume[];
   ArraySetAsSeries(volume, true);
   CopyTickVolume(_Symbol, PERIOD_CURRENT, 0, 20, volume);

   double recentVolAvg = 0, olderVolAvg = 0;
   for(int i = 0; i < 10; i++)
     {
      recentVolAvg += (double)volume[i];
      olderVolAvg += (double)volume[i + 10];
     }
   marketStructure.volumeTrend = (recentVolAvg / 10) / (olderVolAvg / 10);

//--- Log KAMA details
   LogMessage(StringFormat("KAMA: %.5f, Slope: %.2f bp, Trend: %s, Regime: %s",
                           ma200[0], kama_slope, kama_trend, marketStructure.regime));

//--- Update pullback zones when market structure updates
   if(UseExhaustionFilter)
     {
      DrawPullbackZones();
     }
  }
//+------------------------------------------------------------------+
//| Detect support and resistance levels                             |
//+------------------------------------------------------------------+
void DetectSupportResistance()
  {
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   CopyHigh(_Symbol, PERIOD_CURRENT, 0, SRLookback, high);
   CopyLow(_Symbol, PERIOD_CURRENT, 0, SRLookback, low);

//--- Clear previous levels
   ArrayResize(marketStructure.supportLevels, 0);
   ArrayResize(marketStructure.resistanceLevels, 0);

//--- Find significant highs and lows
   for(int i = 10; i < SRLookback - 10; i++)
     {
      //--- Resistance levels
      if(IsLocalHigh(high, i, 10))
        {
         bool isDuplicate = false;
         for(int j = 0; j < ArraySize(marketStructure.resistanceLevels); j++)
           {
            if(MathAbs(high[i] - marketStructure.resistanceLevels[j]) / high[i] < SRZonePercent / 100)
              {
               isDuplicate = true;
               break;
              }
           }
         if(!isDuplicate)
           {
            int size = ArraySize(marketStructure.resistanceLevels);
            ArrayResize(marketStructure.resistanceLevels, size + 1);
            marketStructure.resistanceLevels[size] = high[i];
           }
        }

      //--- Support levels
      if(IsLocalLow(low, i, 10))
        {
         bool isDuplicate = false;
         for(int j = 0; j < ArraySize(marketStructure.supportLevels); j++)
           {
            if(MathAbs(low[i] - marketStructure.supportLevels[j]) / low[i] < SRZonePercent / 100)
              {
               isDuplicate = true;
               break;
              }
           }
         if(!isDuplicate)
           {
            int size = ArraySize(marketStructure.supportLevels);
            ArrayResize(marketStructure.supportLevels, size + 1);
            marketStructure.supportLevels[size] = low[i];
           }
        }
     }

//--- Sort levels
   ArraySort(marketStructure.supportLevels);
   ArraySort(marketStructure.resistanceLevels);
  }

//+------------------------------------------------------------------+
//| Check support alignment                                          |
//+------------------------------------------------------------------+
int CheckSupportAlignment(double level)
  {
   int alignment = 0;

   for(int i = 0; i < ArraySize(marketStructure.supportLevels); i++)
     {
      if(MathAbs(level - marketStructure.supportLevels[i]) / level < SRZonePercent / 100)
        {
         alignment++;
        }
     }

   return alignment;
  }

//+------------------------------------------------------------------+
//| Auto-correct stop loss function                                  |
//+------------------------------------------------------------------+
bool AutoCorrectStopLoss(PatternData &pattern)
  {
   LogMessage("=== AUTO-CORRECTING STOP LOSS ===");

   bool isBullish = pattern.isBullish;
   double originalStop = pattern.stopLoss;
   double entryPrice = pattern.entryPrice;

   LogMessage("Original - Entry: " + DoubleToString(entryPrice, 5) +
              ", Stop: " + DoubleToString(originalStop, 5) +
              ", Pattern: " + pattern.patternType + " (Bullish: " + (isBullish ? "Yes" : "No") + ")");

//--- Step 1: Check if stop is on correct side
   bool stopOnCorrectSide = false;
   if(isBullish && originalStop < entryPrice)
     {
      stopOnCorrectSide = true;
     }
   else
      if(!isBullish && originalStop > entryPrice)
        {
         stopOnCorrectSide = true;
        }

   if(!stopOnCorrectSide)
     {
      LogMessage("CORRECTION NEEDED: Stop on wrong side");

      //--- Auto-correct to proper side
      if(isBullish)
        {
         // For bullish patterns, stop should be below entry
         pattern.stopLoss = entryPrice - MathAbs(originalStop - entryPrice);
        }
      else
        {
         // For bearish patterns, stop should be above entry
         pattern.stopLoss = entryPrice + MathAbs(originalStop - entryPrice);
        }

      LogMessage("Side corrected - New stop: " + DoubleToString(pattern.stopLoss, 5));
     }

//--- Step 2: Calculate optimal stop distance using multiple methods
   double optimalStopDistance = CalculateOptimalStopDistance(entryPrice, isBullish);

//--- Step 3: Apply the optimal stop
   if(isBullish)
     {
      pattern.stopLoss = entryPrice - optimalStopDistance;
     }
   else
     {
      pattern.stopLoss = entryPrice + optimalStopDistance;
     }

//--- Step 4: Validate broker requirements
   double minBrokerDistance = symbol_info.StopsLevel() * symbol_info.Point();
   double actualDistance = MathAbs(pattern.stopLoss - entryPrice);

   if(actualDistance < minBrokerDistance)
     {
      LogMessage("Adjusting for broker minimum: " + DoubleToString(minBrokerDistance, 5));
      if(isBullish)
        {
         pattern.stopLoss = entryPrice - minBrokerDistance * 1.1; // 10% buffer
        }
      else
        {
         pattern.stopLoss = entryPrice + minBrokerDistance * 1.1;
        }
     }

//--- Step 5: Support/Resistance adjustment
   if(UseSupportResistanceStops)
     {
      AdjustStopToSupportResistance(pattern, isBullish);
     }

//--- Step 6: Adjust take profit accordingly
   AutoAdjustTakeProfit(pattern, isBullish);

   LogMessage("FINAL CORRECTED LEVELS:");
   LogMessage("  Entry: " + DoubleToString(pattern.entryPrice, 5));
   LogMessage("  Stop: " + DoubleToString(pattern.stopLoss, 5));
   LogMessage("  Target: " + DoubleToString(pattern.takeProfit, 5));
   LogMessage("  Stop distance: " + DoubleToString(MathAbs(pattern.stopLoss - pattern.entryPrice), 5));
   LogMessage("  Risk/Reward: " + DoubleToString(
                 MathAbs(pattern.takeProfit - pattern.entryPrice) / MathAbs(pattern.stopLoss - pattern.entryPrice), 2));

   return true;
  }

//+------------------------------------------------------------------+
//| Calculate optimal stop distance using multiple methods           |
//+------------------------------------------------------------------+
double CalculateOptimalStopDistance(double entryPrice, bool isBullish)
  {
   LogMessage("=== CALCULATING OPTIMAL STOP DISTANCE ===");

   double distances[];
   ArrayResize(distances, 0);

//--- Method 1: ATR-based stops
   if(UseATRStops)
     {
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(handle_atr, 0, 0, 1, atr) > 0)
        {
         double atrDistance = atr[0] * ATRMultiplier;
         ArrayResize(distances, ArraySize(distances) + 1);
         distances[ArraySize(distances) - 1] = atrDistance;
         LogMessage("ATR distance: " + DoubleToString(atrDistance, 5) +
                    " (ATR=" + DoubleToString(atr[0], 5) + " * " + DoubleToString(ATRMultiplier, 1) + ")");
        }
     }

//--- Method 2: Percentage-based stops
   if(UsePercentageStops)
     {
      double percentDistance = entryPrice * StopPercentage / 100.0;
      ArrayResize(distances, ArraySize(distances) + 1);
      distances[ArraySize(distances) - 1] = percentDistance;
      LogMessage("Percentage distance: " + DoubleToString(percentDistance, 5) +
                 " (" + DoubleToString(StopPercentage, 1) + "% of entry)");
     }

//--- Method 3: Pip-based stops
   double pipDistance = MinStopPips * symbol_info.Point() * 10; // Convert pips to price
   ArrayResize(distances, ArraySize(distances) + 1);
   distances[ArraySize(distances) - 1] = pipDistance;
   LogMessage("Pip distance: " + DoubleToString(pipDistance, 5) +
              " (" + DoubleToString(MinStopPips, 1) + " pips)");

//--- Method 4: Volatility-based stops
   double volatilityDistance = CalculateVolatilityBasedStop();
   if(volatilityDistance > 0)
     {
      ArrayResize(distances, ArraySize(distances) + 1);
      distances[ArraySize(distances) - 1] = volatilityDistance;
      LogMessage("Volatility distance: " + DoubleToString(volatilityDistance, 5));
     }

//--- Choose the median distance (more robust than average)
   if(ArraySize(distances) > 0)
     {
      ArraySort(distances);
      int medianIndex = ArraySize(distances) / 2;
      double optimalDistance = distances[medianIndex];

      //--- Apply min/max limits
      double minDistance = MinStopPips * symbol_info.Point() * 10;
      double maxDistance = MaxStopPips * symbol_info.Point() * 10;

      optimalDistance = MathMax(optimalDistance, minDistance);
      optimalDistance = MathMin(optimalDistance, maxDistance);

      LogMessage("Optimal distance selected: " + DoubleToString(optimalDistance, 5) +
                 " (from " + IntegerToString(ArraySize(distances)) + " methods)");

      return optimalDistance;
     }

//--- Fallback: use minimum pips
   LogMessage("Using fallback minimum distance");
   return MinStopPips * symbol_info.Point() * 10;
  }

//+------------------------------------------------------------------+
//| Calculate volatility-based stop distance                         |
//+------------------------------------------------------------------+
double CalculateVolatilityBasedStop()
  {
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, 20, high) != 20 ||
      CopyLow(_Symbol, PERIOD_CURRENT, 0, 20, low) != 20)
     {
      return 0;
     }

//--- Calculate recent volatility (average true range over 20 periods)
   double totalRange = 0;
   for(int i = 0; i < 20; i++)
     {
      totalRange += (high[i] - low[i]);
     }

   double avgRange = totalRange / 20;
   double volatilityStop = avgRange * 1.5; // 1.5x average range

   return volatilityStop;
  }

//+------------------------------------------------------------------+
//| Adjust stop to nearest support/resistance level                  |
//+------------------------------------------------------------------+
void AdjustStopToSupportResistance(PatternData &pattern, bool isBullish)
  {
   LogMessage("=== ADJUSTING TO SUPPORT/RESISTANCE ===");

//--- Find nearest S/R level
   double srLevel = 0;
   double entryPrice = pattern.entryPrice;
   double currentStop = pattern.stopLoss;

   if(isBullish)
     {
      //--- Look for support level below current stop
      for(int i = 0; i < ArraySize(marketStructure.supportLevels); i++)
        {
         double supportLevel = marketStructure.supportLevels[i];
         if(supportLevel < entryPrice && supportLevel < currentStop)
           {
            //--- Check if this support is close to our stop (within 50% range)
            double stopRange = MathAbs(currentStop - entryPrice);
            double supportRange = MathAbs(supportLevel - entryPrice);

            if(supportRange <= stopRange * 1.5)   // Within 150% of original stop range
              {
               srLevel = supportLevel;
               break;
              }
           }
        }

      if(srLevel > 0)
        {
         pattern.stopLoss = srLevel - 5 * symbol_info.Point(); // 5 points below support
         LogMessage("Adjusted to support level: " + DoubleToString(srLevel, 5) +
                    ", Stop set to: " + DoubleToString(pattern.stopLoss, 5));
        }
     }
   else
     {
      //--- Look for resistance level above current stop
      for(int i = 0; i < ArraySize(marketStructure.resistanceLevels); i++)
        {
         double resistanceLevel = marketStructure.resistanceLevels[i];
         if(resistanceLevel > entryPrice && resistanceLevel > currentStop)
           {
            //--- Check if this resistance is close to our stop
            double stopRange = MathAbs(currentStop - entryPrice);
            double resistanceRange = MathAbs(resistanceLevel - entryPrice);

            if(resistanceRange <= stopRange * 1.5)
              {
               srLevel = resistanceLevel;
               break;
              }
           }
        }

      if(srLevel > 0)
        {
         pattern.stopLoss = srLevel + 5 * symbol_info.Point(); // 5 points above resistance
         LogMessage("Adjusted to resistance level: " + DoubleToString(srLevel, 5) +
                    ", Stop set to: " + DoubleToString(pattern.stopLoss, 5));
        }
     }
  }

//+------------------------------------------------------------------+
//| Auto-adjust take profit to maintain good risk/reward             |
//+------------------------------------------------------------------+
void AutoAdjustTakeProfit(PatternData &pattern, bool isBullish)
  {
   double stopDistance = MathAbs(pattern.stopLoss - pattern.entryPrice);
   double currentTPDistance = MathAbs(pattern.takeProfit - pattern.entryPrice);

//--- Calculate current R:R ratio
   double currentRR = currentTPDistance / stopDistance;

   LogMessage("Current R:R ratio: " + DoubleToString(currentRR, 2));

//--- If R:R is poor (less than 1.5), adjust take profit
   if(currentRR < 1.5)
     {
      double targetRR = 2.0; // Aim for 1:2 risk/reward
      double newTPDistance = stopDistance * targetRR;

      if(isBullish)
        {
         pattern.takeProfit = pattern.entryPrice + newTPDistance;
        }
      else
        {
         pattern.takeProfit = pattern.entryPrice - newTPDistance;
        }

      LogMessage("Adjusted take profit for better R:R. New target: " +
                 DoubleToString(pattern.takeProfit, 5) +
                 ", New R:R: " + DoubleToString(targetRR, 1));
     }
  }

//+------------------------------------------------------------------+
//| UPDATED ValidateStopLoss with auto-correction                    |
//+------------------------------------------------------------------+
bool ValidateStopLoss(const PatternData &pattern, bool isBuy)
  {
   LogMessage("=== VALIDATING STOP LOSS ===");

   double entryPrice = pattern.entryPrice;
   double stopLoss = pattern.stopLoss;
   double stopDistance = MathAbs(entryPrice - stopLoss);

   LogMessage("Entry: " + DoubleToString(entryPrice, 5) +
              ", Stop: " + DoubleToString(stopLoss, 5) +
              ", Distance: " + DoubleToString(stopDistance, 5));

//--- Validate stop direction
   if(isBuy && stopLoss >= entryPrice)
     {
      LogMessage("STOP VALIDATION FAIL: Buy stop loss must be below entry price");
      return false;
     }

   if(!isBuy && stopLoss <= entryPrice)
     {
      LogMessage("STOP VALIDATION FAIL: Sell stop loss must be below entry price");
      return false;
     }

//--- Get minimum requirements
   double minStopLevel = symbol_info.StopsLevel() * symbol_info.Point();
   double userMinDistance = MinStopPips * symbol_info.Point() * 10;
   double requiredMinDistance = MathMax(minStopLevel, userMinDistance);

   LogMessage("Broker minimum: " + DoubleToString(minStopLevel, 5) +
              ", User minimum: " + DoubleToString(userMinDistance, 5) +
              ", Required: " + DoubleToString(requiredMinDistance, 5));

//--- Validate minimum distance
   if(stopDistance < requiredMinDistance)
     {
      LogMessage("STOP VALIDATION FAIL: Distance too small");
      return false;
     }

   LogMessage("STOP VALIDATION: PASSED");
   return true;
  }
//+------------------------------------------------------------------+
//| Calculate Optimal Risk/Reward Ratio - ADD THIS FUNCTION         |
//+------------------------------------------------------------------+
void CalculateOptimalRiskReward(PatternData &pattern, bool isBullish)
  {
   LogMessage("=== CALCULATING OPTIMAL RISK/REWARD ===");
   LogMessage("Pattern: " + pattern.patternType);
   LogMessage("Original Entry: " + DoubleToString(pattern.entryPrice, 5));
   LogMessage("Original Stop: " + DoubleToString(pattern.stopLoss, 5));
   LogMessage("Original Target: " + DoubleToString(pattern.takeProfit, 5));

   double stopDistance = MathAbs(pattern.entryPrice - pattern.stopLoss);
   LogMessage("Stop distance: " + DoubleToString(stopDistance, 5));

   if(stopDistance <= 0)
     {
      LogMessage("ERROR: Invalid stop distance - invalidating pattern");
      pattern.isValid = false;
      return;
     }

// Calculate current R:R ratio
   double currentTPDistance = MathAbs(pattern.takeProfit - pattern.entryPrice);
   double currentRR = currentTPDistance / stopDistance;
   LogMessage("Current R:R ratio: 1:" + DoubleToString(currentRR, 2));

// Set minimum acceptable R:R based on pattern type
   double minRR = GetMinimumRiskReward(pattern.patternType);
   double optimalRR = minRR + 0.5; // Add 0.5 to minimum for optimal

   LogMessage("Minimum R:R required: 1:" + DoubleToString(minRR, 2));
   LogMessage("Optimal R:R target: 1:" + DoubleToString(optimalRR, 2));

// If current R:R is too low, recalculate take profit
   if(currentRR < minRR)
     {
      LogMessage("R:R too low - recalculating take profit");

      double newTPDistance = stopDistance * optimalRR;

      if(isBullish)
        {
         pattern.takeProfit = pattern.entryPrice + newTPDistance;
        }
      else
        {
         pattern.takeProfit = pattern.entryPrice - newTPDistance;
        }

      LogMessage("NEW Take Profit: " + DoubleToString(pattern.takeProfit, 5));
      LogMessage("NEW R:R ratio: 1:" + DoubleToString(optimalRR, 2));
     }

// Final validation - reject if still poor R:R
   double finalTPDistance = MathAbs(pattern.takeProfit - pattern.entryPrice);
   double finalRR = finalTPDistance / stopDistance;

   if(finalRR < minRR)
     {
      LogMessage("PATTERN REJECTED: Final R:R ratio " + DoubleToString(finalRR, 2) +
                 " below minimum " + DoubleToString(minRR, 2));
      pattern.isValid = false;
      return;
     }

   LogMessage("FINAL R:R CALCULATION COMPLETE - Pattern Valid: " + (pattern.isValid ? "YES" : "NO"));
  }

//+------------------------------------------------------------------+
//| Get minimum R:R ratio based on pattern type - ADD THIS TOO      |
//+------------------------------------------------------------------+
double GetMinimumRiskReward(string patternType)
  {
   if(patternType == "ROUNDING_BOTTOM")
     {
      return 1.8; // High success rate = can accept lower R:R
     }
   else
      if(patternType == "CUP_AND_HANDLE")
        {
         return 2.0; // Very reliable pattern
        }
      else
         if(patternType == "INVERSE_HEAD_AND_SHOULDERS")
           {
            return 2.0; // Strong reversal pattern
           }
         else
            if(patternType == "DOUBLE_BOTTOM")
              {
               return 2.2; // Good pattern but need better R:R
              }
            else
               if(patternType == "HEAD_AND_SHOULDERS")
                 {
                  return 2.2; // Good reversal pattern
                 }
               else
                  if(patternType == "ASCENDING_TRIANGLE" ||
                     patternType == "DESCENDING_TRIANGLE")
                    {
                     return 2.5; // Continuation patterns need higher R:R
                    }
                  else
                     if(patternType == "SYMMETRICAL_TRIANGLE")
                       {
                        return 2.5; // Bilateral pattern - higher R:R needed
                       }
                     else
                        if(patternType == "BULL_FLAG" || patternType == "BEAR_FLAG")
                          {
                           return 2.0; // Strong continuation patterns
                          }
                        else
                          {
                           return 2.5; // Default minimum for unknown patterns
                          }
  }
//+------------------------------------------------------------------+
//| UPDATED AddPattern function with auto-correction                 |
//+------------------------------------------------------------------+
void AddPattern(PatternData &pattern)
  {
   LogMessage("=== CREATING PATTERN: " + pattern.patternType + " ===");

//--- FIRST: Check if this pattern type should be traded
   if(!ShouldTradePattern(pattern.patternType))
     {
      LogMessage("PATTERN BLOCKED: " + pattern.patternType + " is temporarily disabled due to poor performance");
      return;
     }

//--- AUTO-CORRECT STOP LOSS IF ENABLED
   if(AutoCorrectStops)
     {
      LogMessage("Auto-correcting stop loss...");
      AutoCorrectStopLoss(pattern);
     }

//--- Calculate additional scores
   pattern.indicatorScore = CalculateIndicatorScore(pattern);
   pattern.contextScore = CalculateContextScore(pattern);

   LogMessage("Pattern scores - Quality: " + DoubleToString(pattern.qualityScore, 1) +
              ", Volume: " + DoubleToString(pattern.volumeScore, 1) +
              ", Indicator: " + DoubleToString(pattern.indicatorScore, 1) +
              ", Context: " + DoubleToString(pattern.contextScore, 1));

//--- Get order flow score if enabled
   double orderFlowScore = 50.0;
   if(UseOrderFlowAnalysis)
     {
      int startBar = iBarShift(_Symbol, PERIOD_CURRENT, pattern.formationStart);
      int endBar = iBarShift(_Symbol, PERIOD_CURRENT, pattern.formationEnd);

      if(startBar > 0 && endBar >= 0 && startBar > endBar)
        {
         orderFlowScore = AnalyzeOrderFlow(startBar, endBar, pattern.isBullish);
         LogMessage("Order flow score: " + DoubleToString(orderFlowScore, 1));
        }
      else
        {
         LogMessage("Could not calculate order flow - using default score");
        }
     }

//--- IMPORTANT: Calculate ADAPTIVE consensus score
//--- This replaces the old static calculation
   pattern.consensusScore = CalculateAdaptiveConsensusScoreWithDOM(pattern);

   LogMessage("Final consensus score: " + DoubleToString(pattern.consensusScore, 1) +
              " (threshold: " + DoubleToString(MinConsensusScore, 1) + ")");

//--- FIXED: Calculate proper R:R before adding to active patterns
   bool isBullish = pattern.isBullish;
   CalculateOptimalRiskReward(pattern, isBullish);

//--- Add to array if score is sufficient AND R:R is valid
   if(pattern.consensusScore >= MinConsensusScore && pattern.isValid)
     {
      int size = ArraySize(activePatterns);
      ArrayResize(activePatterns, size + 1);
      activePatterns[size] = pattern;

      // Calculate final R:R for logging
      double stopDist = MathAbs(pattern.entryPrice - pattern.stopLoss);
      double tpDist = MathAbs(pattern.takeProfit - pattern.entryPrice);
      double rrRatio = stopDist > 0 ? tpDist / stopDist : 0;

      LogMessage("PATTERN ADDED TO ACTIVE LIST: " + pattern.patternType);
      LogMessage("  Consensus Score: " + DoubleToString(pattern.consensusScore, 1));
      LogMessage("  Risk/Reward: 1:" + DoubleToString(rrRatio, 2));
      LogMessage("  Entry: " + DoubleToString(pattern.entryPrice, 5));
      LogMessage("  Stop: " + DoubleToString(pattern.stopLoss, 5));
      LogMessage("  Target: " + DoubleToString(pattern.takeProfit, 5));

      //--- Log adaptive information
      double dynamicSuccessRate = GetDynamicSuccessRate(pattern.patternType);
      LogMessage("Dynamic success rate for " + pattern.patternType + ": " +
                 DoubleToString(dynamicSuccessRate * 100, 1) + "%");
     }
   else
     {
      // ADDED: Proper rejection logging
      string rejectionReason = "";
      if(pattern.consensusScore < MinConsensusScore)
        {
         rejectionReason += "Low consensus score (" + DoubleToString(pattern.consensusScore, 1) +
                            " < " + DoubleToString(MinConsensusScore, 1) + ")";
        }
      if(!pattern.isValid)
        {
         if(rejectionReason != "")
            rejectionReason += " + ";
         rejectionReason += "Invalid pattern (likely poor R:R ratio)";
        }

      LogMessage("PATTERN REJECTED: " + rejectionReason);

      // Log what the R:R would have been for debugging
      double stopDist = MathAbs(pattern.entryPrice - pattern.stopLoss);
      double tpDist = MathAbs(pattern.takeProfit - pattern.entryPrice);
      double rrRatio = stopDist > 0 ? tpDist / stopDist : 0;
      LogMessage("  Would-be R:R: 1:" + DoubleToString(rrRatio, 2));
     }

   LogMessage("=== PATTERN CREATION COMPLETE ===");
  }

//+------------------------------------------------------------------+
//| FIXED CalculateTradeSize function                                |
//+------------------------------------------------------------------+
double CalculateTradeSize(const PatternData &pattern)
  {
   LogMessage("=== CALCULATING TRADE SIZE ===");

//--- If using fixed lot size, return it immediately
   if(UseFixedLotSize)
     {
      double fixedLot = NormalizeLotSize(FixedLotSize);
      LogMessage("Using fixed lot size: " + DoubleToString(fixedLot, 2));
      return fixedLot;
     }
//--- Get ADAPTIVE risk amount instead of fixed
   double adaptiveRiskPercent = GetAdaptiveRiskPercent();
   double riskAmount = account.Balance() * adaptiveRiskPercent / 100.0;

//--- Cap risk amount for small accounts
   if(riskAmount > MaxRiskPerTrade)
     {
      riskAmount = MaxRiskPerTrade;
      LogMessage("Risk capped at maximum: $" + DoubleToString(MaxRiskPerTrade, 2));
     }

   LogMessage("Base risk amount: $" + DoubleToString(riskAmount, 2) +
              " (" + DoubleToString(BaseRiskPercent, 1) + "% of $" + DoubleToString(account.Balance(), 2) + ")");

//--- Apply Kelly Criterion if enabled (but cap it)
   if(UseKellyCriterion && performance.winRate > 0 && performance.totalTrades >= 20)
     {
      double avgWin = performance.totalProfit / performance.winningTrades;
      double avgLoss = (performance.totalTrades - performance.winningTrades) > 0 ?
                       MathAbs(performance.totalProfit - avgWin * performance.winningTrades) /
                       (performance.totalTrades - performance.winningTrades) : riskAmount;

      double kellyPercent = (performance.winRate * avgWin - (1 - performance.winRate) * avgLoss) / avgWin;
      kellyPercent = MathMax(0, MathMin(kellyPercent * KellyFraction, 0.1)); // Cap Kelly at 10% for small accounts

      double kellyRisk = account.Balance() * kellyPercent;
      riskAmount = MathMin(riskAmount, kellyRisk);
      LogMessage("Kelly adjusted risk: $" + DoubleToString(riskAmount, 2));
     }

//--- Adjust for pattern confidence
   double confidenceMultiplier = pattern.consensusScore / 100.0;
   riskAmount *= confidenceMultiplier;
   LogMessage("Confidence adjusted risk: $" + DoubleToString(riskAmount, 2) +
              " (multiplier: " + DoubleToString(confidenceMultiplier, 2) + ")");

//--- Calculate lot size based on stop distance
   double stopDistance = MathAbs(pattern.entryPrice - pattern.stopLoss);
   double tickValue = symbol_info.TickValue();
   double tickSize = symbol_info.TickSize();

   LogMessage("Stop distance: " + DoubleToString(stopDistance, 5) +
              ", Tick value: $" + DoubleToString(tickValue, 5) +
              ", Tick size: " + DoubleToString(tickSize, 8));

   if(stopDistance <= 0 || tickValue <= 0 || tickSize <= 0)
     {
      LogMessage("ERROR: Invalid calculation parameters");
      return NormalizeLotSize(MinLotSize);
     }

//--- Calculate lot size
   double lotSize = (riskAmount * tickSize) / (stopDistance * tickValue);
   LogMessage("Raw calculated lot size: " + DoubleToString(lotSize, 4));

//--- Apply maximum lot size limit for small accounts
   if(lotSize > MaxLotSize)
     {
      lotSize = MaxLotSize;
      LogMessage("Lot size capped at maximum: " + DoubleToString(MaxLotSize, 2));
     }

//--- Ensure minimum lot size
   if(lotSize < MinLotSize)
     {
      lotSize = MinLotSize;
      LogMessage("Lot size increased to minimum: " + DoubleToString(MinLotSize, 2));
     }

//--- Normalize lot size
   lotSize = NormalizeLotSize(lotSize);
   LogMessage("Normalized lot size: " + DoubleToString(lotSize, 2));

//--- CRITICAL: Check margin requirement before returning
   double marginRequired = lotSize * symbol_info.MarginInitial();
   double maxAllowedMargin = account.Balance() * MaxMarginPercent / 100.0;

   LogMessage("Margin check: Required=$" + DoubleToString(marginRequired, 2) +
              ", Max allowed=$" + DoubleToString(maxAllowedMargin, 2) +
              " (" + DoubleToString(MaxMarginPercent, 1) + "% of balance)");

//--- If margin requirement is too high, reduce lot size
   if(marginRequired > maxAllowedMargin)
     {
      double maxSafeLotSize = maxAllowedMargin / symbol_info.MarginInitial();
      maxSafeLotSize = NormalizeLotSize(maxSafeLotSize);

      LogMessage("MARGIN ADJUSTMENT: Reducing lot size from " + DoubleToString(lotSize, 2) +
                 " to " + DoubleToString(maxSafeLotSize, 2));

      lotSize = maxSafeLotSize;
     }

//--- Final validation
   if(lotSize < symbol_info.LotsMin())
     {
      LogMessage("WARNING: Calculated lot size too small, using minimum");
      lotSize = symbol_info.LotsMin();
     }

   if(lotSize > symbol_info.LotsMax())
     {
      LogMessage("WARNING: Calculated lot size too large, using maximum");
      lotSize = symbol_info.LotsMax();
     }

//--- Final margin check
   double finalMarginRequired = lotSize * symbol_info.MarginInitial();
   LogMessage("FINAL: Lot size=" + DoubleToString(lotSize, 2) +
              ", Margin required=$" + DoubleToString(finalMarginRequired, 2) +
              ", Available=$" + DoubleToString(account.FreeMargin(), 2));

   return lotSize;
  }

//+------------------------------------------------------------------+
//| COMPLETE PreExecutionChecks function                             |
//+------------------------------------------------------------------+
bool PreExecutionChecks(const PatternData &pattern)
  {
   LogMessage("=== PRE-EXECUTION CHECKS ===");

//--- Check account trading permission
   if(!account.TradeAllowed())
     {
      LogMessage("CHECK FAIL: Account trading not allowed");
      return false;
     }

//--- Check expert advisor trading permission
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      LogMessage("CHECK FAIL: Terminal trading not allowed");
      return false;
     }

//--- Check if EA trading is enabled
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      LogMessage("CHECK FAIL: EA trading not allowed");
      return false;
     }

//--- Check market hours
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   if(dt.day_of_week == 0 || dt.day_of_week == 6)
     {
      LogMessage("CHECK FAIL: Weekend - market closed");
      return false;
     }

//--- Calculate trade size with the improved function
   double lotSize = CalculateTradeSize(pattern);
   if(lotSize <= 0)
     {
      LogMessage("CHECK FAIL: Invalid lot size calculated");
      return false;
     }

//--- Check lot size limits
   if(lotSize < symbol_info.LotsMin())
     {
      LogMessage("CHECK FAIL: Lot size " + DoubleToString(lotSize, 2) +
                 " < minimum " + DoubleToString(symbol_info.LotsMin(), 2));
      return false;
     }

   if(lotSize > symbol_info.LotsMax())
     {
      LogMessage("CHECK FAIL: Lot size " + DoubleToString(lotSize, 2) +
                 " > maximum " + DoubleToString(symbol_info.LotsMax(), 2));
      return false;
     }

//--- Enhanced margin check
   double marginRequired = lotSize * symbol_info.MarginInitial();
   double marginAvailable = account.FreeMargin();
   double marginBuffer = marginAvailable * 0.2; // 20% safety buffer

   LogMessage("Enhanced margin check:");
   LogMessage("  Required: $" + DoubleToString(marginRequired, 2));
   LogMessage("  Available: $" + DoubleToString(marginAvailable, 2));
   LogMessage("  Buffer: $" + DoubleToString(marginBuffer, 2));
   LogMessage("  Safe limit: $" + DoubleToString(marginAvailable - marginBuffer, 2));

   if(marginRequired > (marginAvailable - marginBuffer))
     {
      LogMessage("CHECK FAIL: Insufficient margin (including buffer)");
      return false;
     }

//--- FIXED: Enhanced price validation
   double currentBid, currentAsk;
   if(!GetCurrentPrices(currentBid, currentAsk))
     {
      LogMessage("CHECK FAIL: Cannot get valid current prices");
      return false;
     }

//--- Determine current price based on pattern direction
   bool isBuy = pattern.isBullish;
   double currentPrice = isBuy ? currentAsk : currentBid;

   LogMessage("Price validation passed: Using " + (isBuy ? "ASK" : "BID") +
              " price = " + DoubleToString(currentPrice, 5));

//--- Check stop loss distance
   double stopDistance = MathAbs(pattern.entryPrice - pattern.stopLoss);
   double minStopLevel = symbol_info.StopsLevel() * symbol_info.Point();

   if(stopDistance < minStopLevel)
     {
      LogMessage("CHECK FAIL: Stop distance " + DoubleToString(stopDistance, 5) +
                 " < minimum " + DoubleToString(minStopLevel, 5));
      return false;
     }

//--- Final risk validation
   double dollarRisk = lotSize * symbol_info.TickValue() * stopDistance / symbol_info.TickSize();
   double riskPercent = dollarRisk / account.Balance() * 100;

   LogMessage("Risk validation:");
   LogMessage("  Dollar risk: $" + DoubleToString(dollarRisk, 2));
   LogMessage("  Risk percent: " + DoubleToString(riskPercent, 2) + "%");

   if(riskPercent > BaseRiskPercent * 2)   // Allow up to 2x base risk
     {
      LogMessage("CHECK FAIL: Risk too high - " + DoubleToString(riskPercent, 2) + "%");
      return false;
     }

   LogMessage("CHECK PASS: All pre-execution checks passed");
   LogMessage("Final trade parameters: Lot=" + DoubleToString(lotSize, 2) +
              ", Risk=$" + DoubleToString(dollarRisk, 2) +
              ", Margin=$" + DoubleToString(marginRequired, 2));

   return true;
  }

//+------------------------------------------------------------------+
//| FIXED LogPositionLimits function                                 |
//+------------------------------------------------------------------+
void LogPositionLimits()
  {
   int currentPositions = 0;
   double totalExposure = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(position.SelectByIndex(i))
        {
         if(position.Magic() == g_magic_number)
           {
            currentPositions++;
            totalExposure += position.Volume() * symbol_info.ContractSize() *
                             MathAbs(position.PriceOpen() - position.StopLoss());
           }
        }
     }

   double maxExposure = account.Balance() * MaxCorrelatedExposure / 100.0;

   LogMessage("POSITION LIMITS: Current=" + IntegerToString(currentPositions) + "/" +
              IntegerToString(MaxConcurrentPositions) + ", Exposure=" +
              DoubleToString(totalExposure, 2) + "/" + DoubleToString(maxExposure, 2));

   if(currentPositions >= MaxConcurrentPositions)
     {
      LogMessage("Position limit reached");
     }

   if(totalExposure >= maxExposure)
     {
      LogMessage("Exposure limit reached");
     }
  }

//+------------------------------------------------------------------+
//| Calculate indicator score                                        |
//+------------------------------------------------------------------+
double CalculateIndicatorScore(const PatternData &pattern)
  {
   double score = 0;
   int confirmations = 0;

   double adx[], rsi[], macdMain[], macdSignal[];
   ArraySetAsSeries(adx, true);
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(macdMain, true);
   ArraySetAsSeries(macdSignal, true);

   CopyBuffer(handle_adx, 0, 0, 3, adx);
   CopyBuffer(handle_rsi, 0, 0, 3, rsi);
   CopyBuffer(handle_macd, 0, 0, 3, macdMain);
   CopyBuffer(handle_macd, 1, 0, 3, macdSignal);

   bool isBullish = pattern.isBullish;

//--- ADX confirmation (trend strength)
   if(adx[0] > ADXThreshold)
     {
      score += 25;
      confirmations++;
     }

//--- RSI confirmation
   if(isBullish)
     {
      if(rsi[0] > 50 && rsi[0] < RSIOverbought)
        {
         score += 25;
         confirmations++;
        }
     }
   else
     {
      if(rsi[0] < 50 && rsi[0] > RSIOversold)
        {
         score += 25;
         confirmations++;
        }
     }

//--- MACD confirmation
   if(isBullish && macdMain[0] > macdSignal[0] && macdMain[0] > macdMain[1])
     {
      score += 25;
      confirmations++;
     }
   else
      if(!isBullish && macdMain[0] < macdSignal[0] && macdMain[0] < macdMain[1])
        {
         score += 25;
         confirmations++;
        }

//--- Momentum confirmation
   double momentum = (symbol_info.Bid() - iClose(_Symbol, PERIOD_CURRENT, 10)) / iClose(_Symbol, PERIOD_CURRENT, 10) * 100;
   if((isBullish && momentum > 0) || (!isBullish && momentum < 0))
     {
      score += 25;
      confirmations++;
     }

   return MathMin(score, 100.0);
  }

//+------------------------------------------------------------------+
//| Calculate context score                                          |
//+------------------------------------------------------------------+
double CalculateContextScore(const PatternData &pattern)
  {
   double score = 50; // Base score

   double ma200[];
   ArraySetAsSeries(ma200, true);
   CopyBuffer(handle_ma200, 0, 0, 1, ma200);  // Now getting KAMA value

//--- Get KAMA data
   double kama_slope = GetKAMASlope();
   string kama_trend = GetKAMATrend();

   bool isBullish = pattern.isBullish;

//--- Trend alignment
   if(isBullish && symbol_info.Bid() > ma200[0])
     {
      score += 20;
      if(kama_trend == "BULLISH")
        {
         score += 15;
         if(kama_slope > KAMASlopeThreshold * 2)
            score += 10;
        }
     }
   else
      if(!isBullish && symbol_info.Bid() < ma200[0])
        {
         score += 20;
         if(kama_trend == "BEARISH")
           {
            score += 15;
            if(kama_slope < -KAMASlopeThreshold * 2)
               score += 10;
           }
        }
      else
        {
         score -= 20;
        }

//--- Distance from KAMA
   double distance_percent = MathAbs(symbol_info.Bid() - ma200[0]) / ma200[0] * 100;

   if(distance_percent > 1.0 && distance_percent < 3.0)
     {
      score += 10;
     }
   else
      if(distance_percent > 5.0)
        {
         score -= 10;
        }

//--- Support/Resistance alignment
   if(pattern.supportResistanceAlignment > 0)
     {
      score += 15;
     }

//--- Volume trend
   if(marketStructure.volumeTrend > 1.0)
     {
      score += 10;
     }

   return MathMin(score, 100.0);
  }
//+------------------------------------------------------------------+
//| Evaluate patterns and execute trades                             |
//+------------------------------------------------------------------+
void EvaluateAndExecutePatterns()
  {
   int patternCount = ArraySize(activePatterns);
   if(patternCount == 0)
     {
      return; // No need to log if there are no patterns
     }

   LogMessage("=== EVALUATING " + IntegerToString(patternCount) + " ACTIVE PATTERNS ===");
//--- Update zones before evaluating patterns
   if(UseExhaustionFilter && patternCount > 0)
     {
      DrawPullbackZones();
     }
   for(int i = patternCount - 1; i >= 0; i--)
     {
      if(!activePatterns[i].isValid)
        {
         continue;
        }

      LogMessage("--> Evaluating pattern #" + IntegerToString(i) + ": " + activePatterns[i].patternType +
                 " with score " + DoubleToString(activePatterns[i].consensusScore, 1));

      // Check pattern age
      datetime patternAge = TimeCurrent() - activePatterns[i].formationEnd;
      datetime maxAge = PatternAgeLimit * PeriodSeconds();

      if(patternAge > maxAge)
        {
         activePatterns[i].isValid = false;
         LogMessage("    -> REJECTED: Pattern is too old.");
         continue;
        }

      // Check consensus score
      if(activePatterns[i].consensusScore < MinConsensusScore)
        {
         LogMessage("    -> REJECTED: Consensus score (" + DoubleToString(activePatterns[i].consensusScore,1) +
                    ") is below minimum (" + DoubleToString(MinConsensusScore,1) + ").");
         continue;
        }

      // Check position limits
      if(!CanOpenNewPosition())
        {
         LogMessage("    -> REJECTED: Position limit reached.");
         continue;
        }

      // Validate pattern context
      if(!ValidatePatternContext(activePatterns[i]))
        {
         LogMessage("    -> REJECTED: Context validation failed (check logs from that function).");
         continue;
        }

      // If we get here, the pattern is valid for trading
      LogMessage("    --> PASSED ALL CHECKS. Attempting to place order.");

      // ENHANCED: Use pending orders or market orders
      if(UsePendingOrders)
        {
         if(PlacePendingOrderForPattern(activePatterns[i]))
           {
            activePatterns[i].isValid = false; // Mark as processed
            LogMessage("    --> SUCCESS: Pending order placed.");
           }
         else
           {
            LogMessage("    --> FAILED: Placing pending order failed (check logs).");
           }
        }
      else
        {
         // Original market order logic
         ExecuteMarketOrderForPattern(activePatterns[i], i);
        }
     }
  }
//+------------------------------------------------------------------+
//| Execute trade                                                    |
//+------------------------------------------------------------------+
void ExecuteTrade(const PatternData &pattern)
  {
   LogMessage("=== EXECUTING TRADE ===");
   LogMessage("Pattern: " + pattern.patternType + ", Consensus: " + DoubleToString(pattern.consensusScore, 1));

//--- Calculate position size
   double riskAmount = account.Balance() * BaseRiskPercent / 100.0;
   LogMessage("Base risk amount: " + DoubleToString(riskAmount, 2) + " (" +
              DoubleToString(BaseRiskPercent, 1) + "% of " + DoubleToString(account.Balance(), 2) + ")");

//--- Apply Kelly Criterion if enabled
   if(UseKellyCriterion && performance.winRate > 0 && performance.totalTrades >= 20)
     {
      double avgWin = performance.totalProfit / performance.winningTrades;
      double avgLoss = (performance.totalTrades - performance.winningTrades) > 0 ?
                       MathAbs(performance.totalProfit - avgWin * performance.winningTrades) /
                       (performance.totalTrades - performance.winningTrades) : riskAmount;

      double kellyPercent = (performance.winRate * avgWin - (1 - performance.winRate) * avgLoss) / avgWin;
      kellyPercent = MathMax(0, MathMin(kellyPercent * KellyFraction, 0.25));

      riskAmount = account.Balance() * kellyPercent;
      LogMessage("Kelly adjusted risk: " + DoubleToString(riskAmount, 2) + " (" +
                 DoubleToString(kellyPercent * 100, 3) + "%)");
     }

//--- Adjust risk based on pattern confidence
   double confidenceMultiplier = pattern.consensusScore / 100.0;
   riskAmount *= confidenceMultiplier;
   LogMessage("Confidence adjusted risk: " + DoubleToString(riskAmount, 2) +
              " (multiplier: " + DoubleToString(confidenceMultiplier, 2) + ")");

//--- Calculate lot size
   double stopDistance = MathAbs(pattern.entryPrice - pattern.stopLoss);
   double tickValue = symbol_info.TickValue();
   double tickSize = symbol_info.TickSize();

   LogMessage("Size calculation: StopDistance=" + DoubleToString(stopDistance, 5) +
              ", TickValue=" + DoubleToString(tickValue, 5) +
              ", TickSize=" + DoubleToString(tickSize, 5));

   if(stopDistance <= 0 || tickValue <= 0 || tickSize <= 0)
     {
      LogMessage("TRADE ABORTED: Invalid calculation parameters");
      return;
     }

   double lotSize = (riskAmount * tickSize) / (stopDistance * tickValue);
   LogMessage("Raw lot size: " + DoubleToString(lotSize, 4));

//--- Normalize lot size
   lotSize = NormalizeLotSize(lotSize);
   LogMessage("Normalized lot size: " + DoubleToString(lotSize, 2));

   if(lotSize <= 0)
     {
      LogMessage("TRADE ABORTED: Invalid lot size after normalization");
      return;
     }

//--- Determine trade direction
   bool isBuy = pattern.isBullish;

//--- Log trade setup
   double entryPrice = isBuy ? symbol_info.Ask() : symbol_info.Bid();
   LogMessage("TRADE SETUP: " + (isBuy ? "BUY" : "SELL") + " " + DoubleToString(lotSize, 2) + " lots");
   LogMessage("Entry: " + DoubleToString(entryPrice, 5) +
              ", SL: " + DoubleToString(pattern.stopLoss, 5) +
              ", TP: " + DoubleToString(pattern.takeProfit, 5));
   LogMessage("Risk: " + DoubleToString(riskAmount, 2) +
              ", R:R: " + DoubleToString(MathAbs(pattern.takeProfit - entryPrice) / MathAbs(entryPrice - pattern.stopLoss), 2));

//--- Execute trade
   bool result = false;

//--- Validate absolute directions before market order
   double currentPrice = isBuy ? symbol_info.Ask() : symbol_info.Bid();
   double minSp = symbol_info.StopsLevel() * symbol_info.Point();

   if(isBuy)
     {
      if(pattern.takeProfit > 0 && pattern.takeProfit <= currentPrice + minSp)
        {
         LogMessage("MARKET ORDER BLOCKED: Buy Take Profit too close");
         return;
        }
      if(pattern.stopLoss > 0 && pattern.stopLoss >= currentPrice - minSp)
        {
         LogMessage("MARKET ORDER BLOCKED: Buy Stop Loss too close");
         return;
        }
      result = trade.Buy(lotSize, _Symbol, 0, pattern.stopLoss, pattern.takeProfit, pattern.patternType);
     }
   else
     {
      if(pattern.takeProfit > 0 && pattern.takeProfit >= currentPrice - minSp)
        {
         LogMessage("MARKET ORDER BLOCKED: Sell Take Profit too close");
         return;
        }
      if(pattern.stopLoss > 0 && pattern.stopLoss <= currentPrice + minSp)
        {
         LogMessage("MARKET ORDER BLOCKED: Sell Stop Loss too close");
         return;
        }
      result = trade.Sell(lotSize, _Symbol, 0, pattern.stopLoss, pattern.takeProfit, pattern.patternType);
     }

//--- Handle result
   if(result)
     {
      ulong ticket = trade.ResultOrder();
      LogMessage("TRADE SUCCESS: " + (isBuy ? "BUY" : "SELL") + " order executed, Ticket=" + IntegerToString((int)ticket));
      LogMessage("Order details: Price=" + DoubleToString(trade.ResultPrice(), 5) +
                 ", Volume=" + DoubleToString(trade.ResultVolume(), 2) +
                 ", SL=" + DoubleToString(pattern.stopLoss, 5) +
                 ", TP=" + DoubleToString(pattern.takeProfit, 5));

      performance.totalTrades++;

      //--- Send notification if enabled
      SendNotification("Hon-APS: " + (isBuy ? "BUY" : "SELL") + " " + pattern.patternType + " " +
                       DoubleToString(lotSize, 2) + " lots @ " + DoubleToString(trade.ResultPrice(), 5));
     }
   else
     {
      int error = GetLastError();
      LogMessage("TRADE FAILED: Error " + IntegerToString(error) + " - " + ErrorDescription(error));
      LogMessage("Failed trade details: " + (isBuy ? "BUY" : "SELL") + " " + DoubleToString(lotSize, 2) +
                 " lots, Price=" + DoubleToString(entryPrice, 5) +
                 ", SL=" + DoubleToString(pattern.stopLoss, 5) +
                 ", TP=" + DoubleToString(pattern.takeProfit, 5));

      //--- Additional error analysis
      if(error == 131)   // Invalid volume
        {
         LogMessage("Volume error details: Min=" + DoubleToString(symbol_info.LotsMin(), 2) +
                    ", Max=" + DoubleToString(symbol_info.LotsMax(), 2) +
                    ", Step=" + DoubleToString(symbol_info.LotsStep(), 2));
        }
      else
         if(error == 130)   // Invalid stops
           {
            double stopsLevel = symbol_info.StopsLevel() * symbol_info.Point();
            LogMessage("Stops error: StopsLevel=" + DoubleToString(stopsLevel, 5) +
                       ", Current distance=" + DoubleToString(stopDistance, 5));
           }
         else
            if(error == 134)   // Not enough money
              {
               LogMessage("Margin error: Required≈" + DoubleToString(lotSize * symbol_info.MarginInitial(), 2) +
                          ", Available=" + DoubleToString(account.FreeMargin(), 2));
              }
     }

   LogMessage("=== TRADE EXECUTION COMPLETE ===");
  }
//+------------------------------------------------------------------+
//| Place pending order for detected pattern                         |
//+------------------------------------------------------------------+
bool PlacePendingOrderForPattern(const PatternData &pattern)
  {
   LogMessage("=== PLACING PENDING ORDER ===");
   LogMessage("Pattern: " + pattern.patternType + ", Entry: " + DoubleToString(pattern.entryPrice, 5));

//--- Check if we already have a pending order for this pattern
   if(HasPendingOrderForPattern(pattern))
     {
      LogMessage("PENDING ORDER: Already exists for this pattern type");
      return false;
     }

//--- Check pending order limits
   if(CountActivePendingOrders() >= MaxPendingOrders)
     {
      LogMessage("PENDING ORDER BLOCKED: Maximum pending orders reached");
      return false;
     }

//--- Pre-execution checks
   if(!PreExecutionChecks(pattern))
     {
      LogMessage("PENDING ORDER BLOCKED: Pre-execution checks failed");
      return false;
     }

//--- Calculate trade size
   double lotSize = CalculateTradeSize(pattern);
   if(lotSize <= 0)
     {
      LogMessage("PENDING ORDER BLOCKED: Invalid lot size");
      return false;
     }

//--- FIXED: Get current prices safely
   double currentBid, currentAsk;
   if(!GetCurrentPrices(currentBid, currentAsk))
     {
      LogMessage("PENDING ORDER BLOCKED: Cannot get current prices");
      return false;
     }

//--- Determine order type and adjust entry price
   bool isBullish = pattern.isBullish;
   ENUM_ORDER_TYPE orderType;
   double adjustedEntry = pattern.entryPrice;
   double adjustedTP = pattern.takeProfit;
   double currentPrice = isBullish ? currentAsk : currentBid;

//--- Add buffer to entry price
   double buffer = EntryBufferPips * symbol_info.Point() * 10; // Convert pips to price

//--- Create a strict minimum distance (Broker StopLevel OR 50 points/5 pips, whichever is larger)
   double strictMinDistance = MathMax(symbol_info.StopsLevel() * symbol_info.Point(), 50 * symbol_info.Point());

   if(isBullish)
     {
      // For bullish breakouts: Buy Stop (above current price)
      adjustedEntry = pattern.entryPrice + buffer;
      orderType = ORDER_TYPE_BUY_STOP;

      if(adjustedEntry <= currentPrice + strictMinDistance)
        {
         // Push the entry safely away from current price
         adjustedEntry = currentPrice + strictMinDistance + buffer;

         // Shift TP up so the target distance remains the same
         if(adjustedTP <= adjustedEntry)
            adjustedTP = adjustedEntry + MathAbs(pattern.takeProfit - pattern.entryPrice);
        }
     }
   else
     {
      // For bearish breakouts: Sell Stop (below current price)
      adjustedEntry = pattern.entryPrice - buffer;
      orderType = ORDER_TYPE_SELL_STOP;

      if(adjustedEntry >= currentPrice - strictMinDistance)
        {
         // Push the entry safely away from current price
         adjustedEntry = currentPrice - strictMinDistance - buffer;

         // Shift TP down so the target distance remains the same
         if(adjustedTP >= adjustedEntry)
            adjustedTP = adjustedEntry - MathAbs(pattern.takeProfit - pattern.entryPrice);
        }
     }

//--- Validate stop loss distance
   double stopDistance = MathAbs(adjustedEntry - pattern.stopLoss);
   double minStopLevel = symbol_info.StopsLevel() * symbol_info.Point();

   if(stopDistance < minStopLevel)
     {
      LogMessage("PENDING ORDER BLOCKED: Stop loss too close");
      return false;
     }

//--- Calculate expiry time
   datetime expiry = TimeCurrent() + PendingOrderExpiry * 3600; // Convert hours to seconds

//--- Log order details
   LogMessage("PENDING ORDER SETUP:");
   LogMessage("  Type: " + EnumToString(orderType));
   LogMessage("  Entry: " + DoubleToString(adjustedEntry, 5) + " (Original: " + DoubleToString(pattern.entryPrice, 5) + ")");
   LogMessage("  Current " + (isBullish ? "Ask" : "Bid") + ": " + DoubleToString(currentPrice, 5));
   LogMessage("  Volume: " + DoubleToString(lotSize, 2));
   LogMessage("  SL: " + DoubleToString(pattern.stopLoss, 5));
   LogMessage("  TP: " + DoubleToString(adjustedTP, 5));
   LogMessage("  Expiry: " + TimeToString(expiry));

//--- Place the pending order
   bool result = false;

   if(orderType == ORDER_TYPE_BUY_STOP)
     {
      result = trade.BuyStop(lotSize, adjustedEntry, _Symbol, pattern.stopLoss, adjustedTP,
                             ORDER_TIME_SPECIFIED, expiry, pattern.patternType);
     }
   else
      if(orderType == ORDER_TYPE_SELL_STOP)
        {
         result = trade.SellStop(lotSize, adjustedEntry, _Symbol, pattern.stopLoss, adjustedTP,
                                 ORDER_TIME_SPECIFIED, expiry, pattern.patternType);
        }

//--- Handle result
   if(result)
     {
      ulong ticket = trade.ResultOrder();
      LogMessage("PENDING ORDER SUCCESS: Ticket=" + IntegerToString((int)ticket));

      //--- Add to pending orders tracking
      AddToPendingOrdersList(ticket, pattern.patternType, expiry, adjustedEntry,
                             pattern.stopLoss, adjustedTP);

      //--- Send notification
      SendNotification("Hon-APS: Pending " + EnumToString(orderType) + " placed for " +
                       pattern.patternType + " @ " + DoubleToString(adjustedEntry, 5));

      return true;
     }
   else
     {
      int error = GetLastError();
      LogMessage("PENDING ORDER FAILED: Error " + IntegerToString(error) + " - " + ErrorDescription(error));

      //--- Additional error analysis
      if(error == 130)   // Invalid stops
        {
         LogMessage("Entry price: " + DoubleToString(adjustedEntry, 5) +
                    ", Current: " + DoubleToString(currentPrice, 5) +
                    ", Distance: " + DoubleToString(MathAbs(adjustedEntry - currentPrice), 5) +
                    ", Min required: " + DoubleToString(minStopLevel, 5));
        }

      return false;
     }
  }
//+------------------------------------------------------------------+
//|    |
//+------------------------------------------------------------------+
void MonitorPrices()
  {
   static datetime lastPriceCheck = 0;

   if(TimeCurrent() - lastPriceCheck > 60)   // Every minute
     {
      lastPriceCheck = TimeCurrent();

      double bid, ask;
      if(GetCurrentPrices(bid, ask))
        {
         LogMessage("Price monitor: " + _Symbol + " Bid=" + DoubleToString(bid, 5) +
                    ", Ask=" + DoubleToString(ask, 5) +
                    ", Spread=" + DoubleToString((ask - bid), 5));
        }
     }
  }
//+------------------------------------------------------------------+
//| Execute market order for pattern (with exhaustion check)        |
//+------------------------------------------------------------------+
void ExecuteMarketOrderForPattern(const PatternData &pattern, int patternIndex)
  {
   double currentBid = symbol_info.Bid();
   double currentAsk = symbol_info.Ask();
   bool isBullish = pattern.isBullish;
   bool readyToEnter = false;

   LogMessage("Pattern " + IntegerToString(patternIndex) + ": Entry=" + DoubleToString(pattern.entryPrice, 5) +
              ", Current Bid=" + DoubleToString(currentBid, 5) +
              ", Ask=" + DoubleToString(currentAsk, 5) +
              ", Stop=" + DoubleToString(pattern.stopLoss, 5));

// Check if trend is exhausted
   if(IsTrendExhausted(isBullish))
     {
      LogMessage("TREND EXHAUSTED - Waiting for pullback before entry");

      // Check if pullback has occurred
      if(!HasPullbackOccurred(pattern, isBullish))
        {
         LogMessage("Pattern " + IntegerToString(patternIndex) + ": WAITING - No pullback yet");
         return; // Don't enter until pullback occurs
        }
      else
        {
         LogMessage("PULLBACK DETECTED - Checking entry conditions");
        }
     }

// Original entry condition checks
   if(isBullish)
     {
      bool priceAboveEntry = (currentAsk >= pattern.entryPrice);
      bool priceAboveStop = (currentBid > pattern.stopLoss);
      readyToEnter = priceAboveEntry && priceAboveStop;

      // Additional check: if in active pullback, wait
      if(readyToEnter && IsInPullback(isBullish))
        {
         LogMessage("Currently in pullback - waiting for confirmation");
         readyToEnter = false;
        }

      LogMessage("Pattern " + IntegerToString(patternIndex) + " BULLISH: Above entry=" +
                 (priceAboveEntry ? "YES" : "NO") + ", Above stop=" + (priceAboveStop ? "YES" : "NO"));
     }
   else
     {
      bool priceBelowEntry = (currentBid <= pattern.entryPrice);
      bool priceBelowStop = (currentAsk < pattern.stopLoss);
      readyToEnter = priceBelowEntry && priceBelowStop;

      // Additional check: if in active pullback, wait
      if(readyToEnter && IsInPullback(isBullish))
        {
         LogMessage("Currently in pullback - waiting for confirmation");
         readyToEnter = false;
        }

      LogMessage("Pattern " + IntegerToString(patternIndex) + " BEARISH: Below entry=" +
                 (priceBelowEntry ? "YES" : "NO") + ", Below stop=" + (priceBelowStop ? "YES" : "NO"));
     }

   if(readyToEnter)
     {
      LogMessage("Pattern " + IntegerToString(patternIndex) + ": READY TO EXECUTE MARKET ORDER!");
      if(PreExecutionChecks(pattern))
        {
         ExecuteTrade(pattern);
         activePatterns[patternIndex].isValid = false;
        }
     }
   else
     {
      LogMessage("Pattern " + IntegerToString(patternIndex) + ": WAITING - Entry conditions not met");
     }
  }
//+------------------------------------------------------------------+
//| Draw pullback zones on chart (Enhanced Version)                 |
//+------------------------------------------------------------------+
void DrawPullbackZones()
  {
//--- Delete old objects first
   ObjectDelete(0, "KAMA_Line");
   for(int i = ObjectsTotal(0, 0, OBJ_HLINE) - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, 0, OBJ_HLINE);
      if(StringFind(name, "Fib_") == 0 || StringFind(name, "PullbackZone_") == 0)
        {
         ObjectDelete(0, name);
        }
     }

//--- Draw KAMA line
   double kama_value = GetKAMAValue(0);
   if(kama_value > 0)
     {
      ObjectCreate(0, "KAMA_Line", OBJ_HLINE, 0, 0, kama_value);
      ObjectSetInteger(0, "KAMA_Line", OBJPROP_COLOR, clrBlue);
      ObjectSetInteger(0, "KAMA_Line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, "KAMA_Line", OBJPROP_WIDTH, 2);
      ObjectSetString(0, "KAMA_Line", OBJPROP_TEXT, "KAMA");
      ObjectSetInteger(0, "KAMA_Line", OBJPROP_SELECTABLE, false);
     }

//--- Draw Fibonacci levels
   double high[], low[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, 50, high) > 0 &&
      CopyLow(_Symbol, PERIOD_CURRENT, 0, 50, low) > 0)
     {

      double recentHigh = high[ArrayMaximum(high, 0, 50)];
      double recentLow = low[ArrayMinimum(low, 0, 50)];
      double range = recentHigh - recentLow;

      //--- Draw Fib levels with labels
      double fib_levels[] = {0.236, 0.382, 0.5, 0.618, 0.786};
      color fib_colors[] = {clrLightGray, clrGold, clrOrange, clrGold, clrLightGray};
      string fib_labels[] = {"23.6%", "38.2%", "50.0%", "61.8%", "78.6%"};

      for(int i = 0; i < ArraySize(fib_levels); i++)
        {
         double level = recentLow + range * fib_levels[i];
         string name = "Fib_" + DoubleToString(fib_levels[i], 3);

         ObjectCreate(0, name, OBJ_HLINE, 0, 0, level);
         ObjectSetInteger(0, name, OBJPROP_COLOR, fib_colors[i]);
         ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
         ObjectSetString(0, name, OBJPROP_TEXT, "Fib " + fib_labels[i]);
         ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        }

      //--- Draw range high/low
      ObjectCreate(0, "PullbackZone_High", OBJ_HLINE, 0, 0, recentHigh);
      ObjectSetInteger(0, "PullbackZone_High", OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, "PullbackZone_High", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, "PullbackZone_High", OBJPROP_WIDTH, 1);
      ObjectSetString(0, "PullbackZone_High", OBJPROP_TEXT, "Recent High");

      ObjectCreate(0, "PullbackZone_Low", OBJ_HLINE, 0, 0, recentLow);
      ObjectSetInteger(0, "PullbackZone_Low", OBJPROP_COLOR, clrGreen);
      ObjectSetInteger(0, "PullbackZone_Low", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, "PullbackZone_Low", OBJPROP_WIDTH, 1);
      ObjectSetString(0, "PullbackZone_Low", OBJPROP_TEXT, "Recent Low");
     }

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Check if pending order already exists for pattern                |
//+------------------------------------------------------------------+
bool HasPendingOrderForPattern(const PatternData &pattern)
  {
   for(int i = 0; i < ArraySize(pendingOrdersList); i++)
     {
      if(pendingOrdersList[i].isActive &&
         pendingOrdersList[i].patternType == pattern.patternType)
        {

         //--- Check if order still exists
         if(OrderSelect(pendingOrdersList[i].ticket))
           {
            return true;
           }
         else
           {
            //--- Order no longer exists, mark as inactive
            pendingOrdersList[i].isActive = false;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Count active pending orders                                      |
//+------------------------------------------------------------------+
int CountActivePendingOrders()
  {
   int count = 0;
   for(int i = 0; i < ArraySize(pendingOrdersList); i++)
     {
      if(pendingOrdersList[i].isActive)
        {
         //--- Verify order still exists
         if(OrderSelect(pendingOrdersList[i].ticket))
           {
            count++;
           }
         else
           {
            pendingOrdersList[i].isActive = false;
           }
        }
     }
   return count;
  }
//+------------------------------------------------------------------+
//| Add order to pending orders tracking list                        |
//+------------------------------------------------------------------+
void AddToPendingOrdersList(ulong ticket, string patternType, datetime expiry,
                            double entryPrice, double stopLoss, double takeProfit)
  {
   int size = ArraySize(pendingOrdersList);
   ArrayResize(pendingOrdersList, size + 1);

   pendingOrdersList[size].ticket = ticket;
   pendingOrdersList[size].patternType = patternType;
   pendingOrdersList[size].expiry = expiry;
   pendingOrdersList[size].entryPrice = entryPrice;
   pendingOrdersList[size].stopLoss = stopLoss;
   pendingOrdersList[size].takeProfit = takeProfit;
   pendingOrdersList[size].isActive = true;

   LogMessage("Added to pending orders list: Ticket=" + IntegerToString((int)ticket) +
              ", Pattern=" + patternType);
  }
//+------------------------------------------------------------------+
//| Clean up expired pending orders                                  |
//+------------------------------------------------------------------+
void CleanupExpiredPendingOrders()
  {
   datetime currentTime = TimeCurrent();

   for(int i = ArraySize(pendingOrdersList) - 1; i >= 0; i--)
     {
      if(pendingOrdersList[i].isActive)
        {
         //--- Check if order is expired
         if(currentTime > pendingOrdersList[i].expiry)
           {
            //--- Try to delete the order
            if(OrderSelect(pendingOrdersList[i].ticket))
              {
               if(trade.OrderDelete(pendingOrdersList[i].ticket))
                 {
                  LogMessage("Expired pending order deleted: Ticket=" +
                             IntegerToString((int)pendingOrdersList[i].ticket));
                 }
              }
            pendingOrdersList[i].isActive = false;
           }
         //--- Check if order no longer exists (filled or cancelled)
         else
            if(!OrderSelect(pendingOrdersList[i].ticket))
              {
               LogMessage("Pending order no longer exists: Ticket=" +
                          IntegerToString((int)pendingOrdersList[i].ticket) + " (possibly filled)");
               pendingOrdersList[i].isActive = false;
              }
        }
     }
  }

//+------------------------------------------------------------------+
//| Manage open positions                                            |
//+------------------------------------------------------------------+
void ManageOpenPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(!position.SelectByIndex(i))
         continue;
      if(position.Symbol() != _Symbol || position.Magic() != trade.RequestMagic())
         continue;

      //--- Calculate profit in R
      double entryPrice = position.PriceOpen();
      double stopLoss = position.StopLoss();
      double currentPrice = position.PositionType() == POSITION_TYPE_BUY ?
                            symbol_info.Bid() : symbol_info.Ask();

      double riskDistance = MathAbs(entryPrice - stopLoss);
      double profitDistance = position.PositionType() == POSITION_TYPE_BUY ?
                              currentPrice - entryPrice : entryPrice - currentPrice;

      if(riskDistance == 0)
         continue;
      double profitInR = profitDistance / riskDistance;

      //--- Apply partial profits
      if(UsePartialProfits)
        {
         ApplyPartialProfits(position.Ticket(), profitInR, position.Volume());
        }

      //--- Apply trailing stop
      if(profitInR >= TrailingActivationR)
        {
         ApplyTrailingStop(position.Ticket(), profitInR);
        }

      //--- Time-based exit for stagnant trades
      if(TimeCurrent() - position.Time() > 48 * 3600 && profitInR < 0.5)
        {
         trade.PositionClose(position.Ticket());
         LogMessage(StringFormat("Position closed due to time limit. Ticket: %d, Profit R: %.2f",
                                 position.Ticket(), profitInR));
        }
     }
  }

//+------------------------------------------------------------------+
//| Apply partial profits                                            |
//+------------------------------------------------------------------+
void ApplyPartialProfits(ulong ticket, double profitInR, double currentVolume)
  {
   static ulong processedPartial1[];
   static ulong processedPartial2[];

//--- Check if already processed
   bool partial1Done = false, partial2Done = false;
   for(int i = 0; i < ArraySize(processedPartial1); i++)
     {
      if(processedPartial1[i] == ticket)
         partial1Done = true;
     }
   for(int i = 0; i < ArraySize(processedPartial2); i++)
     {
      if(processedPartial2[i] == ticket)
         partial2Done = true;
     }

//--- First partial
   if(!partial1Done && profitInR >= PartialProfit1R)
     {
      double closeVolume = NormalizeLotSize(currentVolume * PartialPercent1 / 100.0);
      if(closeVolume > 0 && trade.PositionClosePartial(ticket, closeVolume))
        {
         ArrayResize(processedPartial1, ArraySize(processedPartial1) + 1);
         processedPartial1[ArraySize(processedPartial1) - 1] = ticket;
         LogMessage(StringFormat("Partial profit 1 taken. Ticket: %d, Volume: %.2f", ticket, closeVolume));
        }
     }

//--- Second partial
   if(!partial2Done && profitInR >= PartialProfit2R)
     {
      double remainingVolume = position.Volume();
      double closeVolume = NormalizeLotSize(remainingVolume * PartialPercent2 / (100 - PartialPercent1));
      if(closeVolume > 0 && trade.PositionClosePartial(ticket, closeVolume))
        {
         ArrayResize(processedPartial2, ArraySize(processedPartial2) + 1);
         processedPartial2[ArraySize(processedPartial2) - 1] = ticket;
         LogMessage(StringFormat("Partial profit 2 taken. Ticket: %d, Volume: %.2f", ticket, closeVolume));
        }
     }
  }

//+------------------------------------------------------------------+
//| Apply trailing stop (Bulletproof Validator Version)              |
//+------------------------------------------------------------------+
void ApplyTrailingStop(ulong ticket, double profitInR)
  {
   double atr[];
   ArraySetAsSeries(atr, true);
   
   if(CopyBuffer(handle_atr, 0, 0, 1, atr) <= 0) return; 

   if(!position.SelectByTicket(ticket)) return;
   
   // CRITICAL FIX 1: Force a price refresh! 
   // Using stale Bid/Ask prices is the #1 cause of Error 130 during trailing.
   if(!symbol_info.RefreshRates()) return;

//--- Determine trailing distance based on profit
   double trailMultiple = profitInR >= TightTrailingThresholdR ? TightTrailingATR : InitialTrailingATR;
   double trailDistance = atr[0] * trailMultiple;

//--- CRITICAL FIX 2: Validator-Proof Minimum Distance
   long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   long freezeLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   long currentSpread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   
   // The tester tests extreme conditions. We use the maximum of StopsLevel, 
   // FreezeLevel, or 2x the current Spread to guarantee we don't breach.
   long safeLevel = MathMax(stopsLevel, MathMax(freezeLevel, currentSpread * 2));
   
   // Hard floor of 50 points (5 pips) for absolute certainty
   if(safeLevel < 50) safeLevel = 50; 
   
   double minStopDist = safeLevel * symbol_info.Point();

//--- Enforce minimum stop distance against the calculated ATR
   if(trailDistance < minStopDist)
     {
      trailDistance = minStopDist; 
     }

   double currentSL = position.StopLoss();
   double currentTP = position.TakeProfit();
   double newStop = 0;
   
   if(position.PositionType() == POSITION_TYPE_BUY)
     {
      newStop = NormalizeDouble(symbol_info.Bid() - trailDistance, symbol_info.Digits());
      
      // Verify the new SL is higher than the current SL AND strictly safely away from Bid
      if((currentSL == 0 || newStop > currentSL) && (symbol_info.Bid() - newStop >= minStopDist))
        {
         if(trade.PositionModify(ticket, newStop, currentTP))
           {
            LogMessage(StringFormat("Trailing stop updated. Ticket: %d, New SL: %.5f", ticket, newStop));
           }
        }
     }
   else if(position.PositionType() == POSITION_TYPE_SELL)
     {
      newStop = NormalizeDouble(symbol_info.Ask() + trailDistance, symbol_info.Digits());
      
      // Verify the new SL is lower than the current SL AND strictly safely away from Ask
      if((currentSL == 0 || newStop < currentSL) && (newStop - symbol_info.Ask() >= minStopDist))
        {
         if(trade.PositionModify(ticket, newStop, currentTP))
           {
            LogMessage(StringFormat("Trailing stop updated. Ticket: %d, New SL: %.5f", ticket, newStop));
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsLocalHigh(const double &high[], int index, int range)
  {
// Add comprehensive bounds checking
   if(ArraySize(high) == 0)
     {
      LogMessage("ERROR: Empty array passed to IsLocalHigh");
      return false;
     }

   if(index < 0 || index >= ArraySize(high))
     {
      LogMessage("ERROR: Index out of bounds in IsLocalHigh: " + IntegerToString(index) +
                 " (array size: " + IntegerToString(ArraySize(high)) + ")");
      return false;
     }

   if(index < range || index >= ArraySize(high) - range)
     {
      return false; // Not enough data for comparison
     }

   for(int i = index - range; i <= index + range; i++)
     {
      if(i != index && i >= 0 && i < ArraySize(high) && high[i] >= high[index])
        {
         return false;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsLocalLow(const double &low[], int index, int range)
  {
// Add comprehensive bounds checking
   if(ArraySize(low) == 0)
     {
      LogMessage("ERROR: Empty array passed to IsLocalLow");
      return false;
     }

   if(index < 0 || index >= ArraySize(low))
     {
      LogMessage("ERROR: Index out of bounds in IsLocalLow: " + IntegerToString(index) +
                 " (array size: " + IntegerToString(ArraySize(low)) + ")");
      return false;
     }

   if(index < range || index >= ArraySize(low) - range)
     {
      return false; // Not enough data for comparison
     }

   for(int i = index - range; i <= index + range; i++)
     {
      if(i != index && i >= 0 && i < ArraySize(low) && low[i] <= low[index])
        {
         return false;
        }
     }
   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLotSize(double lots)
  {
   double minLot = symbol_info.LotsMin();
   double maxLot = symbol_info.LotsMax();
   double stepLot = symbol_info.LotsStep();

   lots = MathMax(minLot, lots);
   lots = MathMin(maxLot, lots);
   lots = MathRound(lots / stepLot) * stepLot;

   return NormalizeDouble(lots, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CanOpenNewPosition()
  {
   int currentPositions = 0;
   double totalExposure = 0;

   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(position.SelectByIndex(i))
        {
         if(position.Magic() == g_magic_number)     // Fixed: use RequestMagic() instead of ExpertMagicNumber()
           {
            currentPositions++;
            totalExposure += position.Volume() * symbol_info.ContractSize() *
                             MathAbs(position.PriceOpen() - position.StopLoss());
           }
        }
     }

//--- Check position limit
   if(currentPositions >= MaxConcurrentPositions)
      return false;

//--- Check exposure limit
   double maxExposure = account.Balance() * MaxCorrelatedExposure / 100.0;
   if(totalExposure >= maxExposure)
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| Fixed CheckRiskLimits function                                   |
//+------------------------------------------------------------------+
bool CheckRiskLimits()
  {
//--- Get current time structure
   MqlDateTime current, lastDaily, lastWeekly;
   TimeToStruct(TimeCurrent(), current);
   TimeToStruct(lastDailyReset, lastDaily);
   TimeToStruct(lastWeeklyReset, lastWeekly);

//--- FIXED: Better daily reset logic
   if(current.day != lastDaily.day ||
      (TimeCurrent() - lastDailyReset) > 24 * 3600)
     {
      dailyStartBalance = account.Balance();
      lastDailyReset = TimeCurrent();
      LogMessage(StringFormat("Daily reset triggered. New start balance: %.2f", dailyStartBalance));
     }

//--- FIXED: Better weekly reset logic
   bool weekChanged = false;

// Method 1: Check if we've moved to a new week (Monday = 1)
   if(current.day_of_week == 1 && lastWeekly.day_of_week > 1)
     {
      weekChanged = true;
     }

// Method 2: Check if more than 7 days have passed
   if((TimeCurrent() - lastWeeklyReset) > 7 * 24 * 3600)
     {
      weekChanged = true;
     }

// Method 3: For backtesting, also check if we're in a new week period
   if(MQLInfoInteger(MQL_TESTER))
     {
      int currentWeek = (int)(TimeCurrent() / (7 * 24 * 3600));
      int lastWeek = (int)(lastWeeklyReset / (7 * 24 * 3600));
      if(currentWeek != lastWeek)
        {
         weekChanged = true;
        }
     }

   if(weekChanged)
     {
      weeklyStartBalance = account.Balance();
      lastWeeklyReset = TimeCurrent();
      LogMessage(StringFormat("Weekly reset triggered. New start balance: %.2f", weeklyStartBalance));
     }

//--- Calculate current losses (handle division by zero)
   double dailyLossPercent = 0;
   double weeklyLossPercent = 0;

   if(dailyStartBalance > 0)
     {
      dailyLossPercent = (dailyStartBalance - account.Balance()) / dailyStartBalance * 100;
     }

   if(weeklyStartBalance > 0)
     {
      weeklyLossPercent = (weeklyStartBalance - account.Balance()) / weeklyStartBalance * 100;
     }

//--- Log current status periodically
   if(TimeCurrent() - lastRiskCheck > 3600)   // Every hour
     {
      lastRiskCheck = TimeCurrent();
      LogMessage(StringFormat("Risk Check - Daily Loss: %.2f%% (Limit: %.2f%%), Weekly Loss: %.2f%% (Limit: %.2f%%)",
                              dailyLossPercent, MaxDailyLoss, weeklyLossPercent, MaxWeeklyLoss));
     }

//--- FIXED: Add some tolerance to prevent edge cases
   bool dailyOK = dailyLossPercent < (MaxDailyLoss - 0.1); // 0.1% tolerance
   bool weeklyOK = weeklyLossPercent < (MaxWeeklyLoss - 0.1); // 0.1% tolerance

   return (dailyOK && weeklyOK);
  }
//+------------------------------------------------------------------+
//| Add manual reset function for risk limits                        |
//+------------------------------------------------------------------+
void ResetRiskLimits()
  {
   dailyStartBalance = account.Balance();
   weeklyStartBalance = account.Balance();
   lastDailyReset = TimeCurrent();
   lastWeeklyReset = TimeCurrent();
   riskLimitsPaused = false;

   LogMessage("Risk limits manually reset");
   Print("Risk limits manually reset");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanupOldPatterns()
  {
// First pass: mark invalid patterns
   int validCount = 0;
   for(int i = 0; i < ArraySize(activePatterns); i++)
     {
      if(activePatterns[i].isValid &&
         TimeCurrent() - activePatterns[i].formationEnd <= PatternAgeLimit * PeriodSeconds())
        {
         if(validCount != i)
           {
            activePatterns[validCount] = activePatterns[i];
           }
         validCount++;
        }
     }
// Single resize operation
   ArrayResize(activePatterns, validCount);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LogMessage(string message)
  {
// ALWAYS print to terminal
   Print("[Hon-APS] ", message);

// Try file logging if handle is valid
   if(fileHandle != INVALID_HANDLE)
     {
      string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
      FileWrite(fileHandle, timestamp + " - " + message);
      FileFlush(fileHandle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadPerformanceData()
  {
//--- Initialize with defaults
   performance.totalTrades = 0;
   performance.winningTrades = 0;
   performance.totalProfit = 0;
   performance.totalGrossLoss = 0;
   performance.maxDrawdown = 0;
   performance.currentDrawdown = 0;
   performance.winRate = 0;
   performance.profitFactor = 1.0;
   performance.sharpeRatio = 0;
   performance.lastUpdate = TimeCurrent();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SavePerformanceData()
  {
//--- In production, save to file or database
//--- For now, just log the stats
   LogMessage(StringFormat("Performance Summary - Trades: %d, Win Rate: %.1f%%, PF: %.2f",
                           performance.totalTrades, performance.winRate * 100, performance.profitFactor));
  }

//+------------------------------------------------------------------+
//| Trade event handler                                              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Trade event handler                                              |
//+------------------------------------------------------------------+
void OnTrade()
  {
//--- Check for pending orders that have been filled or canceled
   CheckPendingOrderFills();

//--- Check history for any newly closed positions to update stats
   TrackClosedPositionsForAdaptiveSystem();
  }
//+------------------------------------------------------------------+
//| Track closed positions and update adaptive systems               |
//+------------------------------------------------------------------+
void TrackClosedPositionsForAdaptiveSystem()
  {
   static datetime lastHistoryCheck = 0;
   static int lastDealsTotal = 0;

//--- Check history for recent closed positions
   if(!HistorySelect(0, TimeCurrent()))
     {
      LogMessage("Failed to select trade history");
      return;
     }

   int currentDealsTotal = HistoryDealsTotal();

//--- If no new deals, return
   if(currentDealsTotal == lastDealsTotal)
      return;

//--- Process new deals since last check
   for(int i = lastDealsTotal; i < currentDealsTotal; i++)
     {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0)
         continue;

      //--- Check if it's our EA's deal
      long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      if(dealMagic != trade.RequestMagic())
         continue;

      //--- Check if it's a closing deal (OUT or INOUT)
      ENUM_DEAL_ENTRY dealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
      if(dealEntry != DEAL_ENTRY_OUT && dealEntry != DEAL_ENTRY_INOUT)
         continue;

      //--- Get deal information
      string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      if(dealSymbol != _Symbol)
         continue;

      //--- Find the corresponding position in history
      ulong positionId = HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
      if(positionId == 0)
         continue;

      //--- Get position details by finding all deals for this position
      ProcessClosedPosition(positionId);
     }

   lastDealsTotal = currentDealsTotal;
   lastHistoryCheck = TimeCurrent();
  }
//+------------------------------------------------------------------+
//| Process a closed position and update adaptive systems            |
//+------------------------------------------------------------------+
void ProcessClosedPosition(ulong positionId)
  {
//--- Find all deals for this position
   double positionProfit = 0;
   double positionCommission = 0;
   double positionSwap = 0;
   datetime positionOpenTime = 0;
   datetime positionCloseTime = 0;
   string positionComment = "";
   double entryPrice = 0;
   double exitPrice = 0;
   double volume = 0;
   bool isBuy = true;
   double totalLoss = 0; // Keep track of losses for Profit Factor

//--- Scan all deals to find position details
   for(int i = 0; i < HistoryDealsTotal(); i++)
     {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0)
         continue;

      if(HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID) != positionId)
         continue;

      ENUM_DEAL_ENTRY dealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

      if(dealEntry == DEAL_ENTRY_IN)
        {
         positionOpenTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
         entryPrice = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
         volume = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
         positionComment = HistoryDealGetString(dealTicket, DEAL_COMMENT);
         isBuy = (HistoryDealGetInteger(dealTicket, DEAL_TYPE) == DEAL_TYPE_BUY);
        }
      else
         if(dealEntry == DEAL_ENTRY_OUT || dealEntry == DEAL_ENTRY_INOUT)
           {
            positionCloseTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
            exitPrice = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
            positionProfit += HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
            positionCommission += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
            positionSwap += HistoryDealGetDouble(dealTicket, DEAL_SWAP);
           }
     }

//--- If we didn't find the opening deal, we can't process it
   if(positionOpenTime == 0)
      return;

//--- Calculate total result
   double totalProfitLoss = positionProfit + positionCommission + positionSwap;
   bool isWin = totalProfitLoss > 0;

// ================================================================= //
// === FIX STARTS HERE: UPDATE GLOBAL PERFORMANCE STRUCT === //
// ================================================================= //

   performance.totalTrades++;
   if(isWin)
     {
      performance.winningTrades++;
      performance.totalProfit += totalProfitLoss; // Add to gross profit
     }
   else
     {
      performance.totalGrossLoss += MathAbs(totalProfitLoss); // Add to gross loss
     }

// Recalculate Win Rate
   if(performance.totalTrades > 0)
     {
      performance.winRate = (double)performance.winningTrades / performance.totalTrades;
     }

// Recalculate Profit Factor ACCURATELY
   if(performance.totalGrossLoss > 0)
     {
      performance.profitFactor = performance.totalProfit / performance.totalGrossLoss;
     }
   else
     {
      // If there are no losses, Profit Factor is infinite. We show 0 or a high number.
      performance.profitFactor = 0.0;
     }

   performance.lastUpdate = TimeCurrent();
// ================================================================= //
// === FIX ENDS HERE === //
// ================================================================= //

//--- Extract pattern type from comment
   string patternType = ExtractPatternTypeFromComment(positionComment);

   if(patternType != "")
     {
      LogMessage(StringFormat("Closed position - Pattern: %s, Profit: %.2f, Win: %s",
                              patternType, totalProfitLoss, isWin ? "Yes" : "No"));

      MqlDateTime dt;
      TimeToStruct(positionCloseTime, dt);

      //--- Update adaptive systems (This part is correct)
      UpdatePatternPerformance(patternType, isWin, totalProfitLoss,
                               marketStructure.regime,
                               marketStructure.volatilityLevel,
                               dt.hour);

      //--- Add to recent trades buffer for adaptive risk (This part is correct)
      AddTradeResult(totalProfitLoss);
     }
  }
//+------------------------------------------------------------------+
//| Extract pattern type from position comment                       |
//+------------------------------------------------------------------+
string ExtractPatternTypeFromComment(string comment)
  {
//--- List all possible pattern types
   string patterns[] =
     {
      "CUP_AND_HANDLE",
      "HEAD_AND_SHOULDERS",
      "INVERSE_HEAD_AND_SHOULDERS",
      "DOUBLE_BOTTOM",
      "ROUNDING_BOTTOM",
      "ASCENDING_TRIANGLE",
      "DESCENDING_TRIANGLE",
      "SYMMETRICAL_TRIANGLE",
      "BULL_FLAG",
      "BEAR_FLAG"
     };

//--- Convert comment to uppercase for case-insensitive search
   string upperComment = comment;
   StringToUpper(upperComment);

//--- Search for each pattern in the comment
   for(int i = 0; i < ArraySize(patterns); i++)
     {
      if(StringFind(upperComment, patterns[i]) >= 0)
        {
         return patterns[i];
        }
     }

//--- If no exact match, try to identify pattern from keywords
   if(StringFind(upperComment, "CUP") >= 0 && StringFind(upperComment, "HANDLE") >= 0)
     {
      return "CUP_AND_HANDLE";
     }
   if(StringFind(upperComment, "HEAD") >= 0 && StringFind(upperComment, "SHOULDERS") >= 0)
     {
      if(StringFind(upperComment, "INVERSE") >= 0)
        {
         return "INVERSE_HEAD_AND_SHOULDERS";
        }
      return "HEAD_AND_SHOULDERS";
     }
   if(StringFind(upperComment, "DOUBLE") >= 0 && StringFind(upperComment, "BOTTOM") >= 0)
     {
      return "DOUBLE_BOTTOM";
     }
   if(StringFind(upperComment, "ROUNDING") >= 0 && StringFind(upperComment, "BOTTOM") >= 0)
     {
      return "ROUNDING_BOTTOM";
     }
   if(StringFind(upperComment, "TRIANGLE") >= 0)
     {
      if(StringFind(upperComment, "ASCENDING") >= 0)
         return "ASCENDING_TRIANGLE";
      if(StringFind(upperComment, "DESCENDING") >= 0)
         return "DESCENDING_TRIANGLE";
      if(StringFind(upperComment, "SYMMETRICAL") >= 0)
         return "SYMMETRICAL_TRIANGLE";
     }
   if(StringFind(upperComment, "FLAG") >= 0)
     {
      if(StringFind(upperComment, "BULL") >= 0)
         return "BULL_FLAG";
      if(StringFind(upperComment, "BEAR") >= 0)
         return "BEAR_FLAG";
     }

   LogMessage("WARNING: Could not extract pattern type from comment: " + comment);
   return "";
  }
//+------------------------------------------------------------------+
//| Enhanced OnChartEvent with Keyboard Shortcuts                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      ENUM_DASHBOARD_ACTION action = g_beautiful_dashboard.EventAction(sparam);

      switch(action)
        {
         case DASH_ACTION_PAUSE_TOGGLE:
            riskLimitsPaused = !riskLimitsPaused;
            break;
         case DASH_ACTION_CLOSE_ALL:
            CloseAllPositions("Manual close all");
            break;
         case DASH_ACTION_EMERGENCY_STOP:
            //EmergencyStop();
            break;
         case DASH_ACTION_RESET_RISK:
            ResetRiskLimits();
            break;
         case DASH_ACTION_SHOW_STATS:
            ShowEnhancedStatistics();
            break;
         case DASH_ACTION_NEWS_TOGGLE:
            //ToggleNewsTrading();
            break;
        }
     }

//--- Handle Keyboard Shortcuts
   if(id == CHARTEVENT_KEYDOWN)
     {
      switch((int)lparam)
        {
         case 'P':
         case 'p':  // Pause/Resume
            riskLimitsPaused = !riskLimitsPaused;
            LogMessage("SHORTCUT: Trading " + (riskLimitsPaused ? "PAUSED" : "RESUMED"));
            break;

         case 'C':
         case 'c':  // Close All
            if(MessageBox("Close all positions? (Ctrl+C)", "Confirm", MB_YESNO) == IDYES)
              {
               CloseAllPositions("Keyboard shortcut close all");
              }
            break;

         case 'E':
         case 'e':  // Emergency Stop
            if(MessageBox("EMERGENCY STOP? (Ctrl+E)", "EMERGENCY", MB_YESNO|MB_ICONWARNING) == IDYES)
              {
               CloseAllPositions("EMERGENCY STOP - Keyboard");
               riskLimitsPaused = true;
              }
            break;

         case 'R':
         case 'r':  // Reset Risk
            ResetRiskLimits();
            LogMessage("SHORTCUT: Risk limits reset");
            break;

         case 'S':
         case 's':  // Show Stats
            ShowEnhancedStatistics();
            break;

         case 'M':
         case 'm':  // Minimize Dashboard
            //g_dashboard.SetVisibility(false);
            break;

         case 'A':
         case 'a':  // Show Adaptive Stats
            ShowAdaptiveStatistics();
            break;

         case 'H':
         case 'h':  // Help
            ShowKeyboardShortcuts();
            break;
         case 'Z':
         case 'z':  // Z for Zones
            DrawPullbackZones();
            LogMessage("SHORTCUT: Pullback zones refreshed");
            break;


        }
     }
  }

//==============================================
void ShowAdaptiveStatistics()
  {
   string stats = "=== ADAPTIVE SYSTEM STATISTICS ===\n\n";

//--- Consensus weights
   stats += "CONSENSUS WEIGHTS:\n";
   stats += StringFormat("Quality: %.3f\n", consensusWeights.qualityWeight);
   stats += StringFormat("Volume: %.3f\n", consensusWeights.volumeWeight);
   stats += StringFormat("Indicator: %.3f\n", consensusWeights.indicatorWeight);
   stats += StringFormat("Context: %.3f\n", consensusWeights.contextWeight);
   stats += StringFormat("Order Flow: %.3f\n", consensusWeights.orderFlowWeight);

//--- Pattern performance
   stats += "\nPATTERN PERFORMANCE:\n";
   for(int i = 0; i < ArraySize(patternStats); i++)
     {
      if(patternStats[i].totalTrades > 0)
        {
         double winRate = (double)patternStats[i].winningTrades / patternStats[i].totalTrades;
         double expectancy = (patternStats[i].totalProfit - patternStats[i].totalLoss) /
                             patternStats[i].totalTrades;

         stats += StringFormat("\n%s:\n", patternStats[i].patternType);
         stats += StringFormat("  Trades: %d, Win Rate: %.1f%%\n",
                               patternStats[i].totalTrades, winRate * 100);
         stats += StringFormat("  Expectancy: %.2f, Avg Win: %.2f, Avg Loss: %.2f\n",
                               expectancy, patternStats[i].avgWinAmount,
                               patternStats[i].avgLossAmount);

         //--- Regime performance
         string regimes[] = {"Trend Up", "Trend Down", "Ranging", "Volatile"};
         for(int j = 0; j < 4; j++)
           {
            if(patternStats[i].tradesByRegime[j] >= 5)
              {
               stats += StringFormat("  %s: %.1f%% (%d trades)\n",
                                     regimes[j],
                                     patternStats[i].successRateByRegime[j] * 100,
                                     patternStats[i].tradesByRegime[j]);
              }
           }
        }
     }

//--- Recent metrics
   stats += "\nRECENT PERFORMANCE:\n";
   stats += StringFormat("Win Rate (20): %.1f%%\n", CalculateRecentWinRate(20) * 100);
   stats += StringFormat("Win Rate (50): %.1f%%\n", CalculateRecentWinRate(50) * 100);
   stats += StringFormat("Sharpe (30): %.2f\n", CalculateRecentSharpe(30));
   stats += StringFormat("Max Drawdown: %.2f%%\n", CalculateRecentDrawdown());
   stats += StringFormat("Current Risk: %.2f%%\n", GetAdaptiveRiskPercent());

   MessageBox(stats, "Adaptive Statistics", MB_OK);
  }
//+------------------------------------------------------------------+
//| Check for filled pending orders                                  |
//+------------------------------------------------------------------+
void CheckPendingOrderFills()
  {
   for(int i = 0; i < ArraySize(pendingOrdersList); i++)
     {
      if(pendingOrdersList[i].isActive)
        {
         //--- Check if order no longer exists (might be filled)
         if(!OrderSelect(pendingOrdersList[i].ticket))
           {
            //--- Check if it became a position
            for(int j = 0; j < PositionsTotal(); j++)
              {
               if(position.SelectByIndex(j))
                 {
                  if(position.Identifier() == pendingOrdersList[i].ticket)
                    {
                     LogMessage("PENDING ORDER FILLED: " + pendingOrdersList[i].patternType +
                                " Ticket=" + IntegerToString((int)pendingOrdersList[i].ticket));

                     SendNotification("Hon-APS: " + pendingOrdersList[i].patternType +
                                      " pending order filled @ " +
                                      DoubleToString(position.PriceOpen(), 5));

                     performance.totalTrades++;
                     break;
                    }
                 }
              }
            pendingOrdersList[i].isActive = false;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Show performance statistics                                      |
//+------------------------------------------------------------------+
void ShowPerformanceStats()
  {
   string stats = "=== PERFORMANCE STATISTICS ===\n";
   stats += StringFormat("Total Trades: %d\n", performance.totalTrades);
   stats += StringFormat("Winning Trades: %d\n", performance.winningTrades);
   stats += StringFormat("Win Rate: %.1f%%\n", performance.winRate * 100);
   stats += StringFormat("Total Profit: %.2f%%\n", performance.totalProfit);
   stats += StringFormat("Max Drawdown: %.2f%%\n", performance.maxDrawdown);
   stats += StringFormat("Profit Factor: %.2f\n", performance.profitFactor);
   stats += StringFormat("Sharpe Ratio: %.2f\n", performance.sharpeRatio);
   stats += "\n=== CURRENT STATUS ===\n";
   stats += StringFormat("Balance: %.2f\n", account.Balance());
   stats += StringFormat("Equity: %.2f\n", account.Equity());
   stats += StringFormat("Margin: %.2f\n", account.Margin());
   stats += StringFormat("Free Margin: %.2f\n", account.FreeMargin());

   if(UseOrderFlowAnalysis)
     {
      stats += "\n=== ORDER FLOW ===\n";
      stats += StringFormat("Buy Pressure: %.2f\n", orderFlow.buyPressure);
      stats += StringFormat("Sell Pressure: %.2f\n", orderFlow.sellPressure);
      stats += StringFormat("Cumulative Delta: %.0f\n", orderFlow.cumulativeDelta);
      stats += StringFormat("POC: %.5f\n", orderFlow.poc);
      stats += StringFormat("Value Area High: %.5f\n", orderFlow.vah);
      stats += StringFormat("Value Area Low: %.5f\n", orderFlow.val);
     }

   MessageBox(stats, "Hon-APS Performance", MB_OK);
  }
//+------------------------------------------------------------------+
//| Show Enhanced Statistics                                         |
//+------------------------------------------------------------------+
void ShowEnhancedStatistics()
  {
   string stats = "📊 HON-APS ENHANCED STATISTICS 📊\n\n";

   stats += "🎯 PERFORMANCE METRICS:\n";
   stats += StringFormat("Win Rate: %.1f%% | Profit Factor: %.2f\n", performance.winRate * 100, performance.profitFactor);
   stats += StringFormat("Sharpe Ratio: %.2f | Max Drawdown: %.2f%%\n", CalculateRecentSharpe(50), CalculateRecentDrawdown());
   stats += StringFormat("Total Trades: %d | Adaptive Risk: %.2f%%\n\n", performance.totalTrades, GetAdaptiveRiskPercent());

   stats += "📈 MARKET CONDITIONS:\n";
   stats += StringFormat("Regime: %s | KAMA Trend: %s\n", marketStructure.regime, GetKAMATrend());
   stats += StringFormat("Volatility: %.2f | Active Patterns: %d\n\n", marketStructure.volatilityLevel, ArraySize(activePatterns));

   stats += "🛡️ RISK STATUS:\n";
   double daily_loss = (dailyStartBalance > 0) ? (dailyStartBalance - account.Equity()) / dailyStartBalance * 100.0 : 0.0;
   double weekly_loss = (weeklyStartBalance > 0) ? (weeklyStartBalance - account.Equity()) / weeklyStartBalance * 100.0 : 0.0;
   stats += StringFormat("Daily Loss: %.2f%% / %.1f%%\n", daily_loss, MaxDailyLoss);
   stats += StringFormat("Weekly Loss: %.2f%% / %.1f%%\n", weekly_loss, MaxWeeklyLoss);

   stats += "\n⌨️ KEYBOARD SHORTCUTS:\n";
   stats += "[P] Pause/Resume | [C] Close All | [E] Emergency\n";
   stats += "[R] Reset Risk | [S] Stats | [M] Minimize | [A] Adaptive";

   MessageBox(stats, "Hon-APS Enhanced Statistics", MB_OK|MB_ICONINFORMATION);
  }

//+------------------------------------------------------------------+
//| Show Keyboard Shortcuts Help                                    |
//+------------------------------------------------------------------+
void ShowKeyboardShortcuts()
  {
   string help = "⌨️ HON-APS KEYBOARD SHORTCUTS ⌨️\n\n";
   help += "[P] - Pause/Resume Trading\n";
   help += "[C] - Close All Positions\n";
   help += "[E] - Emergency Stop\n";
   help += "[R] - Reset Risk Limits\n";
   help += "[S] - Show Statistics\n";
   help += "[M] - Minimize Dashboard\n";
   help += "[A] - Adaptive Statistics\n";
   help += "[Z] - Refresh Pullback Zones\n";  // Add this line
   help += "[H] - Show This Help\n\n";
   help += "💡 TIP: Dashboard buttons also show shortcuts!";

   MessageBox(help, "Keyboard Shortcuts Help", MB_OK|MB_ICONINFORMATION);
  }
//+------------------------------------------------------------------+
//| Show active patterns                                             |
//+------------------------------------------------------------------+
void ShowActivePatterns()
  {
   string patterns = "=== ACTIVE PATTERNS ===\n";

   if(ArraySize(activePatterns) == 0)
     {
      patterns += "No active patterns detected.\n";
     }
   else
     {
      for(int i = 0; i < ArraySize(activePatterns); i++)
        {
         if(activePatterns[i].isValid)
           {
            patterns += StringFormat("%s - Score: %.1f\n",
                                     activePatterns[i].patternType,
                                     activePatterns[i].consensusScore);
            patterns += StringFormat("  Entry: %.5f, SL: %.5f, TP: %.5f\n",
                                     activePatterns[i].entryPrice,
                                     activePatterns[i].stopLoss,
                                     activePatterns[i].takeProfit);
            patterns += StringFormat("  Quality: %.1f, Volume: %.1f\n",
                                     activePatterns[i].qualityScore,
                                     activePatterns[i].volumeScore);
            patterns += "  ---\n";
           }
        }
     }

   patterns += StringFormat("\nTotal Active: %d patterns", ArraySize(activePatterns));
   MessageBox(patterns, "Active Patterns", MB_OK);
  }

//+------------------------------------------------------------------+
//| Show market structure                                            |
//+------------------------------------------------------------------+
void ShowMarketStructure()
  {
   string structure = "=== MARKET STRUCTURE ===\n";
   structure += StringFormat("Regime: %s\n", marketStructure.regime);
   structure += StringFormat("Trend Strength: %.1f\n", marketStructure.trendStrength);
   structure += StringFormat("Volatility Level: %.2f\n", marketStructure.volatilityLevel);
   structure += StringFormat("Volume Trend: %.2f\n", marketStructure.volumeTrend);

   structure += "\n=== SUPPORT LEVELS ===\n";
   for(int i = 0; i < ArraySize(marketStructure.supportLevels) && i < 5; i++)
     {
      structure += StringFormat("S%d: %.5f\n", i+1, marketStructure.supportLevels[i]);
     }

   structure += "\n=== RESISTANCE LEVELS ===\n";
   for(int i = 0; i < ArraySize(marketStructure.resistanceLevels) && i < 5; i++)
     {
      structure += StringFormat("R%d: %.5f\n", i+1, marketStructure.resistanceLevels[i]);
     }

   structure += StringFormat("\nCurrent Price: %.5f", symbol_info.Bid());
   MessageBox(structure, "Market Structure", MB_OK);
  }

//+------------------------------------------------------------------+
//| Enhanced risk management functions                               |
//+------------------------------------------------------------------+
double CalculateOptimalRiskSize(const PatternData &pattern)
  {
   double baseRisk = BaseRiskPercent / 100.0;

//--- Adjust based on pattern quality
   double qualityMultiplier = pattern.consensusScore / 100.0;

//--- Adjust based on market regime
   double regimeMultiplier = 1.0;
   if(marketStructure.regime == "TRENDING_UP" && pattern.isBullish)
     {
      regimeMultiplier = 1.2;
     }
   else
      if(marketStructure.regime == "TRENDING_DOWN" && !pattern.isBullish)
        {
         regimeMultiplier = 1.2;
        }
      else
         if(marketStructure.regime == "RANGING")
           {
            regimeMultiplier = 0.8;
           }
         else
            if(marketStructure.regime == "VOLATILE")
              {
               regimeMultiplier = 0.6;
              }

//--- Adjust based on volatility
   double volatilityMultiplier = 1.0;
   if(marketStructure.volatilityLevel > 1.5)
     {
      volatilityMultiplier = 0.8;
     }
   else
      if(marketStructure.volatilityLevel < 0.8)
        {
         volatilityMultiplier = 1.1;
        }

//--- Calculate final risk
   double adjustedRisk = baseRisk * qualityMultiplier * regimeMultiplier * volatilityMultiplier;

//--- Cap the risk
   adjustedRisk = MathMin(adjustedRisk, 0.05); // Max 5% per trade
   adjustedRisk = MathMax(adjustedRisk, 0.005); // Min 0.5% per trade

   return adjustedRisk;
  }

//+------------------------------------------------------------------+
//| Advanced position sizing with Kelly Criterion                   |
//+------------------------------------------------------------------+
double CalculateKellyPosition(const PatternData &pattern)
  {
   if(performance.totalTrades < 20)
     {
      return BaseRiskPercent / 100.0; // Use base risk if not enough data
     }

//--- Calculate average win and loss
   double avgWin = 0, avgLoss = 0;
   int wins = performance.winningTrades;
   int losses = performance.totalTrades - wins;

   if(wins > 0)
      avgWin = performance.totalProfit / wins;
   if(losses > 0)
      avgLoss = MathAbs(performance.totalProfit - avgWin * wins) / losses;

//--- Kelly formula: f = (bp - q) / b
//--- where b = odds received (avg win/avg loss), p = probability of win, q = probability of loss
   double winProbability = performance.winRate;
   double lossProbability = 1.0 - winProbability;
   double odds = avgLoss > 0 ? avgWin / avgLoss : 1.0;

   double kellyFraction = (odds * winProbability - lossProbability) / odds;

//--- Apply safety margin
   kellyFraction *= KellyFraction; // Apply Kelly fraction multiplier

//--- Cap Kelly sizing
   kellyFraction = MathMax(0.005, MathMin(kellyFraction, 0.05));

   return kellyFraction;
  }

//+------------------------------------------------------------------+
//| Market session awareness                                         |
//+------------------------------------------------------------------+
bool IsGoodTradingSession()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   int hour = dt.hour;

   bool asianSession = (hour >= 0 && hour < 9);
   bool londonSession = (hour >= 8 && hour < 17);
   bool nySession = (hour >= 13 && hour < 22);
   bool londonNyOverlap = (hour >= 13 && hour < 17);
   bool lowLiquidity = (hour >= 22 || hour < 1);

   bool goodDay = (dt.day_of_week >= 1 && dt.day_of_week <= 5);
   if(dt.day_of_week == 5 && hour >= 21)
      goodDay = false;

   LogMessage("SESSION: Hour=" + IntegerToString(hour) + ", London=" + (londonSession ? "Y" : "N") +
              ", NY=" + (nySession ? "Y" : "N") + ", Overlap=" + (londonNyOverlap ? "Y" : "N") +
              ", LowLiq=" + (lowLiquidity ? "Y" : "N") + ", GoodDay=" + (goodDay ? "Y" : "N"));

   bool result = (londonSession || nySession || londonNyOverlap) && !lowLiquidity && goodDay;
   LogMessage("SESSION RESULT: " + (result ? "GOOD" : "BAD"));

   return result;
  }
//+------------------------------------------------------------------+
//| News filter functionality                                        |
//+------------------------------------------------------------------+
bool IsNewsTime()
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   int hour = dt.hour;
   int minutes = dt.min;

//--- Major news times (GMT)
   bool usOpenNews = (hour == 13 && minutes >= 25 && minutes <= 35);
   bool euroNews = (hour == 9 && minutes >= 25 && minutes <= 35);
   bool fomc = (hour == 18 && minutes >= 55) || (hour == 19 && minutes <= 5);
   bool nfp = (hour == 12 && minutes >= 25 && minutes <= 35 && dt.day_of_week == 5);

   bool result = usOpenNews || euroNews || fomc || nfp;

   if(result)
     {
      LogMessage("NEWS TIME DETECTED: Hour=" + IntegerToString(hour) + ", Min=" + IntegerToString(minutes));
     }

   return result;
  }
//+------------------------------------------------------------------+
//| Enhanced spread checking function                                |
//+------------------------------------------------------------------+
bool CheckSpreadConditions()
  {
   if(DisableSpreadCheck)
     {
      LogMessage("SPREAD CHECK: Disabled by user setting");
      return true;
     }

   double currentSpread = symbol_info.Spread() * symbol_info.Point();
   double maxAllowedSpread = 0;
   string symbolName = _Symbol;
   string assetType = "Unknown";

//--- Determine asset type and appropriate spread limit
   if(UseAdaptiveSpread)
     {
      //--- Auto-detect asset type based on symbol name
      if(StringFind(symbolName, "BTC") >= 0 || StringFind(symbolName, "ETH") >= 0 ||
         StringFind(symbolName, "XRP") >= 0 || StringFind(symbolName, "ADA") >= 0 ||
         StringFind(symbolName, "DOGE") >= 0 || StringFind(symbolName, "LTC") >= 0)
        {
         assetType = "Crypto";
         maxAllowedSpread = CryptoMaxSpread * symbol_info.Point();
        }
      else
         if(StringFind(symbolName, "US30") >= 0 || StringFind(symbolName, "NAS100") >= 0 ||
            StringFind(symbolName, "SPX500") >= 0 || StringFind(symbolName, "UK100") >= 0 ||
            StringFind(symbolName, "GER30") >= 0 || StringFind(symbolName, "JPN225") >= 0)
           {
            assetType = "Index";
            maxAllowedSpread = IndexMaxSpread * symbol_info.Point();
           }
         else
            if(StringLen(symbolName) == 6 || StringLen(symbolName) == 7)
              {
               //--- Likely forex pair (6-7 characters like EURUSD, GBPUSD.m)
               assetType = "Forex";
               maxAllowedSpread = ForexMaxSpread * symbol_info.Point() * 10; // Convert pips to price
              }
            else
              {
               //--- Unknown asset, use general settings
               assetType = "General";
               maxAllowedSpread = MaxSpreadPoints * symbol_info.Point();
              }
     }
   else
     {
      //--- Use manual settings
      assetType = "Manual";
      maxAllowedSpread = MaxSpreadPoints * symbol_info.Point();
     }

   LogMessage("SPREAD CHECK: Symbol=" + symbolName + ", Type=" + assetType);
   LogMessage("  Current spread: " + DoubleToString(currentSpread, 5) +
              " (" + DoubleToString(symbol_info.Spread(), 1) + " points)");
   LogMessage("  Max allowed: " + DoubleToString(maxAllowedSpread, 5));

   if(currentSpread <= maxAllowedSpread)
     {
      LogMessage("SPREAD CHECK: PASSED");
      return true;
     }
   else
     {
      LogMessage("SPREAD CHECK: FAILED - Spread too wide");
      return false;
     }
  }

//+------------------------------------------------------------------+
//| Enhanced stop loss validation                                    |
//+------------------------------------------------------------------+
bool ValidateStopLoss(double entryPrice, double stopLoss, bool isBuy)
  {
   LogMessage("=== VALIDATING STOP LOSS ===");

   double stopDistance = MathAbs(entryPrice - stopLoss);
   LogMessage("Stop distance: " + DoubleToString(stopDistance, 5));

//--- Get minimum stop level from broker
   double minStopLevel = symbol_info.StopsLevel() * symbol_info.Point();
   LogMessage("Broker minimum stop level: " + DoubleToString(minStopLevel, 5));

//--- Calculate minimum distance based on user settings
   double userMinDistance = MinStopDistancePips * symbol_info.Point() * 10; // Convert pips to price

//--- Use ATR-based stops if enabled
   if(UseATRStops)
     {
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(handle_atr, 0, 0, 1, atr) > 0)
        {
         double atrMinDistance = atr[0] * ATRMultiplier;
         userMinDistance = MathMax(userMinDistance, atrMinDistance);
         LogMessage("ATR-based minimum: " + DoubleToString(atrMinDistance, 5));
        }
     }

   LogMessage("User minimum distance: " + DoubleToString(userMinDistance, 5));

//--- Use the larger of broker or user minimum
   double requiredMinDistance = MathMax(minStopLevel, userMinDistance);

//--- Relax checks for crypto if enabled
   if(RelaxStopChecks)
     {
      string symbolName = _Symbol;
      if(StringFind(symbolName, "BTC") >= 0 || StringFind(symbolName, "ETH") >= 0 ||
         StringFind(symbolName, "XRP") >= 0 || StringFind(symbolName, "ADA") >= 0)
        {
         requiredMinDistance = MathMin(requiredMinDistance, userMinDistance);
         LogMessage("Relaxed stop checks applied for crypto");
        }
     }

   LogMessage("Required minimum distance: " + DoubleToString(requiredMinDistance, 5));

//--- Validate stop direction
   if(isBuy && stopLoss >= entryPrice)
     {
      LogMessage("STOP VALIDATION FAIL: Buy stop loss must be below entry price");
      return false;
     }

   if(!isBuy && stopLoss <= entryPrice)
     {
      LogMessage("STOP VALIDATION FAIL: Sell stop loss must be above entry price");
      return false;
     }

//--- Validate minimum distance
   if(stopDistance < requiredMinDistance)
     {
      LogMessage("STOP VALIDATION FAIL: Distance " + DoubleToString(stopDistance, 5) +
                 " < required " + DoubleToString(requiredMinDistance, 5));
      return false;
     }

   LogMessage("STOP VALIDATION: PASSED");
   return true;
  }

//-------------------------------------------
string ExtractPatternType(string comment)
  {
//--- Pattern types to search for
   string patterns[] = {"CUP_AND_HANDLE", "HEAD_AND_SHOULDERS",
                        "INVERSE_HEAD_AND_SHOULDERS", "DOUBLE_BOTTOM",
                        "ROUNDING_BOTTOM", "ASCENDING_TRIANGLE",
                        "DESCENDING_TRIANGLE", "SYMMETRICAL_TRIANGLE",
                        "BULL_FLAG", "BEAR_FLAG"
                       };

   for(int i = 0; i < ArraySize(patterns); i++)
     {
      if(StringFind(comment, patterns[i]) >= 0)
        {
         return patterns[i];
        }
     }

   return "";
  }
//+------------------------------------------------------------------+
//| Enhanced pattern validation                                      |
//+------------------------------------------------------------------+
bool ValidatePatternContext(const PatternData &pattern)
  {
   LogMessage("=== VALIDATING PATTERN CONTEXT ===");

   bool isTesting = MQLInfoInteger(MQL_TESTER);

//--- Check account status
   if(!account.TradeAllowed())
     {
      LogMessage("CONTEXT FAIL: Account trading not allowed");
      return false;
     }

//--- Check symbol trading status
   if(!symbol_info.TradeMode())
     {
      LogMessage("CONTEXT FAIL: Symbol trading disabled");
      return false;
     }

//--- Check if symbol info is properly initialized
   if(symbol_info.Name() != _Symbol)
     {
      if(!symbol_info.Name(_Symbol))
        {
         LogMessage("CONTEXT FAIL: Cannot initialize symbol info");
         return false;
        }
     }

//--- Check market hours (skip in tester)
   if(!isTesting)
     {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);

      if(dt.day_of_week == 0 || dt.day_of_week == 6)
        {
         LogMessage("CONTEXT FAIL: Weekend - market closed");
         return false;
        }

      if(dt.day_of_week == 5 && dt.hour >= 21)
        {
         LogMessage("CONTEXT FAIL: Friday after 21:00 GMT");
         return false;
        }

      //--- Check trading session (more lenient for crypto)
      if(!IsGoodTradingSession() && !IsCryptoSymbol())
        {
         LogMessage("CONTEXT FAIL: Poor trading session (forex only)");
         return false;
        }

      //--- Check news time (skip for crypto)
      if(IsNewsTime() && !IsCryptoSymbol())
        {
         LogMessage("CONTEXT FAIL: High-impact news time (forex only)");
         return false;
        }
     }
   else
     {
      LogMessage("CONTEXT: Backtesting mode - skipping session/news checks");
     }

//--- UPDATED: Use new spread checking function
   if(!CheckSpreadConditions())
     {
      LogMessage("CONTEXT FAIL: Spread conditions not met");
      return false;
     }

//--- UPDATED: Use enhanced stop loss validation
   bool isBullish = pattern.isBullish;
   if(!ValidateStopLoss(pattern.entryPrice, pattern.stopLoss, isBullish))
     {
      LogMessage("CONTEXT FAIL: Stop loss validation failed");
      return false;
     }

   LogMessage("CONTEXT PASS: All validations passed");
   return true;
  }
//+------------------------------------------------------------------+
//| Helper function to detect crypto symbols                         |
//+------------------------------------------------------------------+
bool IsCryptoSymbol()
  {
   string symbolName = _Symbol;
   return (StringFind(symbolName, "BTC") >= 0 || StringFind(symbolName, "ETH") >= 0 ||
           StringFind(symbolName, "XRP") >= 0 || StringFind(symbolName, "ADA") >= 0 ||
           StringFind(symbolName, "DOGE") >= 0 || StringFind(symbolName, "LTC") >= 0 ||
           StringFind(symbolName, "USDT") >= 0 || StringFind(symbolName, "USDC") >= 0);
  }
//+------------------------------------------------------------------+
//| Enhanced pending order placement with better stop validation     |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Enhanced pending order placement with better stop validation     |
//+------------------------------------------------------------------+
bool PlacePendingOrderForPattern_Enhanced(const PatternData &pattern)
  {
   LogMessage("=== PLACING PENDING ORDER (ENHANCED) ===");
   LogMessage("Pattern: " + pattern.patternType + ", Entry: " + DoubleToString(pattern.entryPrice, 5));

//--- Check if we already have a pending order for this pattern
   if(HasPendingOrderForPattern(pattern))
     {
      LogMessage("PENDING ORDER: Already exists for this pattern type");
      return false;
     }

//--- Check pending order limits
   if(CountActivePendingOrders() >= MaxPendingOrders)
     {
      LogMessage("PENDING ORDER BLOCKED: Maximum pending orders reached");
      return false;
     }

//--- Pre-execution checks
   if(!PreExecutionChecks(pattern))
     {
      LogMessage("PENDING ORDER BLOCKED: Pre-execution checks failed");
      return false;
     }

//--- Calculate trade size
   double lotSize = CalculateTradeSize(pattern);
   if(lotSize <= 0)
     {
      LogMessage("PENDING ORDER BLOCKED: Invalid lot size");
      return false;
     }

//--- Get current prices safely
   double currentBid, currentAsk;
   if(!GetCurrentPrices(currentBid, currentAsk))
     {
      LogMessage("PENDING ORDER BLOCKED: Cannot get current prices");
      return false;
     }

//--- Determine order type and adjust entry price
   bool isBullish = pattern.isBullish;
   ENUM_ORDER_TYPE orderType;
   double adjustedEntry = pattern.entryPrice;
   double adjustedTP = pattern.takeProfit;
   double currentPrice = isBullish ? currentAsk : currentBid;

//--- Adjust buffer based on asset type
   double bufferMultiplier = IsCryptoSymbol() ? 5.0 : 1.0; // Larger buffer for crypto
   double buffer = EntryBufferPips * symbol_info.Point() * 10 * bufferMultiplier;

//--- Create a strict minimum distance (Broker StopLevel OR 50 points/5 pips, whichever is larger)
   double strictMinDistance = MathMax(symbol_info.StopsLevel() * symbol_info.Point(), 50 * symbol_info.Point());

   if(isBullish)
     {
      adjustedEntry = pattern.entryPrice + buffer;
      orderType = ORDER_TYPE_BUY_STOP;

      //--- Ensure entry is safely above current price
      double minEntry = currentPrice + strictMinDistance + buffer;

      if(adjustedEntry < minEntry)
        {
         adjustedEntry = minEntry;
         // Shift TP up if the entry got pushed up
         if(adjustedTP <= adjustedEntry)
            adjustedTP = adjustedEntry + MathAbs(pattern.takeProfit - pattern.entryPrice);
        }
     }
   else
     {
      adjustedEntry = pattern.entryPrice - buffer;
      orderType = ORDER_TYPE_SELL_STOP;

      //--- Ensure entry is safely below current price
      double maxEntry = currentPrice - strictMinDistance - buffer;

      if(adjustedEntry > maxEntry)
        {
         adjustedEntry = maxEntry;
         // Shift TP down if the entry got pushed down
         if(adjustedTP >= adjustedEntry)
            adjustedTP = adjustedEntry - MathAbs(pattern.takeProfit - pattern.entryPrice);
        }
     }

//--- Enhanced stop loss validation
   if(!ValidateStopLoss(adjustedEntry, pattern.stopLoss, isBullish))
     {
      LogMessage("PENDING ORDER BLOCKED: Stop loss validation failed");
      return false;
     }

//--- Enhanced Take Profit and direction validation
   double minSp = symbol_info.StopsLevel() * symbol_info.Point();
   if(orderType == ORDER_TYPE_BUY_STOP)
     {
      if(adjustedTP <= adjustedEntry + minSp || pattern.stopLoss >= adjustedEntry - minSp)
        {
         LogMessage("PENDING ORDER BLOCKED: Buy parameters invalid (TP/SL crossed entry)");
         return false;
        }
     }
   else
      if(orderType == ORDER_TYPE_SELL_STOP)
        {
         if(adjustedTP >= adjustedEntry - minSp || pattern.stopLoss <= adjustedEntry + minSp)
           {
            LogMessage("PENDING ORDER BLOCKED: Sell parameters invalid (TP/SL crossed entry)");
            return false;
           }
        }

//--- Calculate expiry time
   datetime expiry = TimeCurrent() + PendingOrderExpiry * 3600;

//--- Log order details
   LogMessage("PENDING ORDER SETUP:");
   LogMessage("  Symbol: " + _Symbol + (IsCryptoSymbol() ? " (CRYPTO)" : " (FOREX)"));
   LogMessage("  Type: " + EnumToString(orderType));
   LogMessage("  Entry: " + DoubleToString(adjustedEntry, 5) + " (Original: " + DoubleToString(pattern.entryPrice, 5) + ")");
   LogMessage("  Current " + (isBullish ? "Ask" : "Bid") + ": " + DoubleToString(currentPrice, 5));
   LogMessage("  Buffer applied: " + DoubleToString(buffer, 5));
   LogMessage("  Volume: " + DoubleToString(lotSize, 2));
   LogMessage("  SL: " + DoubleToString(pattern.stopLoss, 5));
   LogMessage("  TP: " + DoubleToString(adjustedTP, 5));
   LogMessage("  Expiry: " + TimeToString(expiry));

//--- Place the pending order
   bool result = false;

   if(orderType == ORDER_TYPE_BUY_STOP)
     {
      result = trade.BuyStop(lotSize, adjustedEntry, _Symbol, pattern.stopLoss, adjustedTP,
                             ORDER_TIME_SPECIFIED, expiry, pattern.patternType);
     }
   else
      if(orderType == ORDER_TYPE_SELL_STOP)
        {
         result = trade.SellStop(lotSize, adjustedEntry, _Symbol, pattern.stopLoss, adjustedTP,
                                 ORDER_TIME_SPECIFIED, expiry, pattern.patternType);
        }

//--- Handle result
   if(result)
     {
      ulong ticket = trade.ResultOrder();
      LogMessage("PENDING ORDER SUCCESS: Ticket=" + IntegerToString((int)ticket));

      //--- Add to pending orders tracking
      AddToPendingOrdersList(ticket, pattern.patternType, expiry, adjustedEntry,
                             pattern.stopLoss, adjustedTP);

      //--- Send notification
      SendNotification("Hon-APS: Pending " + EnumToString(orderType) + " placed for " +
                       pattern.patternType + " @ " + DoubleToString(adjustedEntry, 5));

      return true;
     }
   else
     {
      int error = GetLastError();
      LogMessage("PENDING ORDER FAILED: Error " + IntegerToString(error) + " - " + ErrorDescription(error));

      //--- Additional error analysis
      if(error == 130)   // Invalid stops
        {
         LogMessage("DETAILED ERROR ANALYSIS:");
         LogMessage("  Entry price: " + DoubleToString(adjustedEntry, 5));
         LogMessage("  Current price: " + DoubleToString(currentPrice, 5));
         LogMessage("  Price distance: " + DoubleToString(MathAbs(adjustedEntry - currentPrice), 5));
         LogMessage("  Stop loss: " + DoubleToString(pattern.stopLoss, 5));
         LogMessage("  Stop distance: " + DoubleToString(MathAbs(adjustedEntry - pattern.stopLoss), 5));
         LogMessage("  Min stop level: " + DoubleToString(symbol_info.StopsLevel() * symbol_info.Point(), 5));
        }

      return false;
     }
  }
//+------------------------------------------------------------------+
//| Get average spread                                               |
//+------------------------------------------------------------------+
double GetAverageSpread(int period)
  {
   double totalSpread = 0;
   int count = 0;

   for(int i = 0; i < period; i++)
     {
      double high = iHigh(_Symbol, PERIOD_M1, i);
      double low = iLow(_Symbol, PERIOD_M1, i);
      if(high > 0 && low > 0)
        {
         totalSpread += (high - low);
         count++;
        }
     }

   return count > 0 ? totalSpread / count : symbol_info.Spread() * symbol_info.Point();
  }

//+------------------------------------------------------------------+
//| Emergency shutdown functionality                                 |
//+------------------------------------------------------------------+
void CheckEmergencyShutdown()
  {
//--- Check for excessive drawdown
   double currentDrawdown = (account.Balance() - dailyStartBalance) / dailyStartBalance * 100;

   if(currentDrawdown < -MaxDailyLoss * 1.5)   // 150% of max daily loss
     {
      CloseAllPositions("Emergency shutdown: Excessive drawdown");
      ExpertRemove();
     }

//--- Check for margin call risk
   if(account.MarginLevel() < 200 && account.MarginLevel() > 0)
     {
      CloseAllPositions("Emergency shutdown: Low margin level");
      ExpertRemove();
     }

//--- Check for connection issues
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      LogMessage("Warning: Terminal disconnected");
     }
  }

//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(string reason)
  {
   LogMessage("Closing all positions: " + reason);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(position.SelectByIndex(i))
        {
         if(position.Magic() == g_magic_number)     // Fixed: use RequestMagic() instead of ExpertMagicNumber()
           {
            trade.PositionClose(position.Ticket());
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Enhanced logging with error handling                             |
//+------------------------------------------------------------------+
void LogError(string functionName, int errorCode)
  {
   string errorMsg = StringFormat("ERROR in %s: Code %d - %s",
                                  functionName, errorCode, ErrorDescription(errorCode));
   LogMessage(errorMsg);
   Print(errorMsg);
  }

//+------------------------------------------------------------------+
//| Get error description                                            |
//+------------------------------------------------------------------+
string ErrorDescription(int errorCode)
  {
   switch(errorCode)
     {
      case 0:
         return "No error";
      case 1:
         return "No result";
      case 2:
         return "Common error";
      case 3:
         return "Invalid trade parameters";
      case 4:
         return "Server busy";
      case 5:
         return "Old version";
      case 6:
         return "No connection";
      case 7:
         return "Not enough rights";
      case 8:
         return "Too frequent requests";
      case 9:
         return "Malfunctional trade";
      case 64:
         return "Account disabled";
      case 65:
         return "Invalid account";
      case 128:
         return "Trade timeout";
      case 129:
         return "Invalid price";
      case 130:
         return "Invalid stops";
      case 131:
         return "Invalid trade volume";
      case 132:
         return "Market closed";
      case 133:
         return "Trade disabled";
      case 134:
         return "Not enough money";
      case 135:
         return "Price changed";
      case 136:
         return "Off quotes";
      case 137:
         return "Broker busy";
      case 138:
         return "Requote";
      case 139:
         return "Order locked";
      case 140:
         return "Long positions only";
      case 141:
         return "Too many requests";
      case 10004:
         return "No result";
      case 10006:
         return "Unknown symbol";
      case 10007:
         return "Invalid price";
      case 10008:
         return "Invalid stops";
      case 10009:
         return "Invalid volume";
      case 10010:
         return "Incorrect stops";
      case 10011:
         return "Insufficient funds";
      case 10012:
         return "Invalid volume";
      case 10013:
         return "Invalid price";
      case 10014:
         return "Invalid request";
      case 10015:
         return "Invalid operation";
      case 10016:
         return "Invalid volume";
      case 10017:
         return "Invalid price";
      case 10018:
         return "Invalid stops";
      case 10019:
         return "Invalid volume";
      case 10020:
         return "Invalid request";
      case 10021:
         return "Invalid volume";
      case 10022:
         return "Invalid price";
      case 10023:
         return "Invalid request";
      case 10024:
         return "Invalid volume";
      case 10025:
         return "Invalid price";
      default:
         return "Unknown error";
     }
  }

//+------------------------------------------------------------------+
//| Final validation and startup                                     |
//+------------------------------------------------------------------+
void PerformStartupValidation()
  {
//--- Validate account type
   if(account.TradeMode() != ACCOUNT_TRADE_MODE_DEMO &&
      account.TradeMode() != ACCOUNT_TRADE_MODE_REAL)
     {
      LogMessage("WARNING: Unknown account type");
     }

//--- Validate symbol specifications
   if(symbol_info.LotsMin() <= 0 || symbol_info.LotsMax() <= 0)
     {
      LogMessage("ERROR: Invalid lot specifications");
     }

//--- Validate spread
   if(symbol_info.Spread() > 100)   // 10 pips for major pairs
     {
      LogMessage("WARNING: High spread detected: " + IntegerToString(symbol_info.Spread()));
     }

//--- Log important settings
   LogMessage(StringFormat("EA Settings - Risk: %.1f%%, Patterns: C&H:%s H&S:%s DB:%s RB:%s",
                           BaseRiskPercent,
                           TradeCupHandle ? "ON" : "OFF",
                           TradeHeadShoulders ? "ON" : "OFF",
                           TradeDoubleBottom ? "ON" : "OFF",
                           TradeRoundingBottom ? "ON" : "OFF"));

   LogMessage("Hon-APS EA startup validation completed successfully");
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
