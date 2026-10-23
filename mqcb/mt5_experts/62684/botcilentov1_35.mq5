//+------------------------------------------------------------------+
//|                                              BotCilentoV1.33.mq5 |
//|                               Copyright 2025, Lupus Materia Ltd. |
//|                                    https://www.lupusmateria.com/ |
//| WARNING: This trading robot comes with no guarantees of profit.  |
//| Forex trading involves substantial risk of loss.                 |
//| Only use risk capital you can afford to lose.                    |
//| No liability accepted for any losses incurred.                   |
//| Always test thoroughly in demo account before live use.          |
//+------------------------------------------------------------------+


#property copyright "Copyright 2025, Lupus Materia Ltd."
#property link      "https://www.lupusmateria.com/"
#property version   "1.35"

// Include standard MQL5 libraries for trading, indicators, etc.
#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>
#include <Indicators\Volumes.mqh>
#include <Indicators\Indicators.mqh>

//+-------------------------------------------------------------------+
//| EA Overview                                                       |
//| This Expert Advisor implements a MA-based directional grid with   |
//| optional Martingale or Arithmetic lot progression. It manages     |
//| entries using fast/slow MAs, optional volatility & slope filters, |
//| and enforces risk constraints (spread, daily loss, drawdown, etc).|
//| Key modules:                                                      |
//|  • Indicators: MA values and optional ATR (for step & filters)    |
//|  • Entry logic: start buy/sell cycles on MA cross/distance checks |
//|  • Grid logic: add positions by step (fixed/ATR), size by strategy|
//|  • Risk mgmt: free margin, spread, cooldowns, trade rate limiting |
//|  • Cycle mgmt: average price, TP-in-pips grid close, timeouts     |
//+-------------------------------------------------------------------+


// ------------------------------
// Enums (User-selectable options)
// ------------------------------

// Defines the lot sizing strategy options
enum ENUM_LOT_STRATEGY
  {
   MARTINGALE,               // Martingale (exponential lot increase)
   ARITHMETIC_PROGRESSION    // Arithmetic (linear lot increase)
  };

// Defines the grid step type options
enum ENUM_STEP_TYPE
  {
   FIXED_PIPS,              // Fixed distance between grid trades in pips
   ATR_BASED                // Dynamic distance based on ATR indicator
  };

// ------------------------------
// Structs (Data containers)
// ------------------------------

// Contains all configurable parameters for the EA
struct TradeConfig
  {
   bool              enableEmergencyClose;       // Enable emergency close at max drawdown
   bool              enableSignalFlipClose;      // Close trades on opposite signal
   int               magicNumber;                // Unique EA identifier
   string            eaComment;                  // Comment attached to trades
   double            initialLot;                 // Starting lot size
   double            martingaleMultiplier;       // Multiplier for martingale strategy
   int               maxGridTrades;              // Maximum trades in a grid
   double            fixedStepInPips;            // Fixed step between grid trades in pips
   int               stepATRPeriod;              // ATR period for step calculation
   double            stepATRMultiplier;          // Multiplier for ATR step
   ENUM_TIMEFRAMES   stepATRTimeframe;           // Timeframe for ATR step
   double            takeProfitInPips;           // Take profit in pips
   double            stagnationThresholdPips;    // Threshold for stagnation close
   double            maxSpreadInPips;            // Maximum allowed spread
   int               maxSlippageInPips;          // Maximum allowed slippage
   double            minFreeMarginBuffer;        // Minimum free margin required
   double            maxGridDrawdownPercent;     // Max drawdown before emergency close
   bool              flipOnOppositeSignal;       // Flip position on opposite signal
   int               maxCycleHours;              // Maximum cycle duration in hours
   bool              enableVolatilityFilter;     // Enable volatility filter
   int               vFilterShortATR;            // Short ATR period for volatility filter
   int               vFilterLongATR;             // Long ATR period for volatility filter
   double            vFilterThreshold;           // Volatility threshold
   int               cycleCooldownHours;         // Cooldown period after cycle
   int               minGridTradeIntervalMinutes;// Minimum time between grid trades
   bool              showInfo;                   // Show info panel
   bool              debugMode;                  // Enable debug logging
   ENUM_LOT_STRATEGY lotStrategy;               // Lot sizing strategy
   ENUM_STEP_TYPE    stepType;                   // Grid step type
   int               minEntryDelayMinutes;       // Minimum delay between new cycles
   bool              enableMASlopeFilter;        // Filter trades based on MA slope
   bool              useATRStep;                 // Use ATR for step calculation
   bool              useVolFilter;               // Use volatility filter
   int               maFastPeriod;               // Fast MA period
   int               maSlowPeriod;               // Slow MA period
   double            minGridStepPips;            // Minimum grid step in pips
   int               maxTotalTrades;             // Maximum total trades per cycle
   int               maxTradesPerSecond;         // Maximum trades per second
   double            dailyLossLimitPercent;      // Daily loss limit percentage
   double            dailyLossLimitDollar;       // Daily loss limit in dollars
   int               maxPositionAgeHours;        // Maximum position age in hours
   int               minCycleDurationMinutes;    // Minimum cycle duration
   double            minSignalDistancePips;      // Minimum signal distance in pips
   bool              useClosePriceSignals;       // Use closing prices for signals
   double            volumeFilterMultiplier;     // Volume filter multiplier
   bool              enableGridTrading;          // Enable grid trading
   double            gridCloseProfitPips;        // Profit target to close grid
   bool              enableGridCloseAtProfit;    // Enable grid profit closure
  };

// Tracks the current state of trading cycles
struct CycleState
  {
   bool              buyCycleActive;            // Flag for active buy cycle
   bool              sellCycleActive;           // Flag for active sell cycle
   int               currentGridTrades;         // Current number of grid trades
   double            averageEntryPrice;         // Weighted average entry price
   double            totalLots;                 // Total lots in current cycle
   datetime          cycleStartTime;            // Time when cycle started
   datetime          lastCycleCloseTime;        // Time of last cycle close
   datetime          lastGridTradeTime;         // Time of last grid trade
   datetime          lastCycleStartTime;        // Time of last cycle start
   bool              isTradeInProgress;         // Flag for trade in progress
   int               tradesThisTick;            // Trades executed this tick
   int               tradesThisSecond;          // Trades executed this second
   datetime          lastTradeSecond;           // Time of last trade
   double            dailyStartBalance;         // Account balance at day start
   bool              dailyLossLimitHit;         // Flag for daily loss limit
   double            lastTradePrice;            // Price of last trade
  };

// Handles for indicator objects
struct IndicatorHandles
  {
   int               maFastHandle;              // Handle for fast MA
   int               maSlowHandle;              // Handle for slow MA
   CiATR             atrStepIndicator;          // ATR for step calculation
   CiATR             atrVolShort;               // Short ATR for volatility filter
   CiATR             atrVolLong;                // Long ATR for volatility filter
  };

// Market data and current conditions
struct MarketData
  {
   double            pointValue;                // Value of a point
   double            pipValue;                  // Value of a pip
   int               digits;                    // Symbol digits
   double            contractSize;              // Contract size
   long              leverage;                  // Account leverage
   double            bid;                       // Current bid price
   double            ask;                       // Current ask price
   double            currentSpreadInPips;       // Current spread in pips
   double            lastValidMAFast;           // Last valid fast MA value
   double            lastValidMASlow;           // Last valid slow MA value
   double            maFast;                    // Current fast MA value
   double            maSlow;                    // Current slow MA value
   double            atrStepValue;              // Current ATR step value
   double            atrVolShortValue;          // Short ATR volatility value
   double            atrVolLongValue;           // Long ATR volatility value
   bool              maValuesValid;             // Flag for valid MA values
   int               lastSignalBar;             // Last bar processed for signals
   datetime          lastPanelUpdate;           // Last time info panel updated
   datetime          lastSpreadUpdate;          // Last time spread updated
   datetime          lastIndicatorUpdate;       // Last time indicators updated
   double            lastProcessedPrice;        // Last price processed
   datetime          lastDailyResetCheck;       // Last time daily reset checked
  };

// ------------------------------
// Global Variables
// ------------------------------
CTrade           trade;        // Trading object for order execution
TradeConfig      config;       // Configuration parameters
CycleState       state;        // Current trading cycle state
IndicatorHandles indicators;   // Indicator handles
MarketData       market;       // Current market data

// ------------------------------
// Utility Functions
// ------------------------------

/**
 * Prints debug messages when debug mode is enabled
 * @param msg The message to print
 */
void DebugPrint(const string msg)
  {
   if(config.debugMode)
      Print("Debug: ", msg);
  }

/**
 * Updates current bid/ask prices and spread
 */
void SnapshotQuotes()
  {
   market.digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   market.bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   market.ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double spreadPts = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   double pipFactor = (market.digits % 2 == 1) ? 10.0 : 1.0;
   market.currentSpreadInPips = spreadPts / pipFactor;
  }

// ------------------------------
// Market State Functions
// ------------------------------

/**
 * Checks if market is open (not weekend and within trading hours)
 * @return true if market is open, false otherwise
 */
bool IsMarketOpen()
  {
   MqlDateTime now;
   TimeCurrent(now);
   if(now.day_of_week == SATURDAY || now.day_of_week == SUNDAY)
      return false;
   int hour = now.hour;
   return (hour >= 1 && hour <= 22);
  }

// ------------------------------
// Indicator Functions
// ------------------------------

/**
 * Gets MA value from indicator handle
 * @param handle Indicator handle
 * @param shift Bar shift
 * @return MA value or EMPTY_VALUE on error
 */
double GetMAValue(int handle, int shift)
  {
   double buf[1];
   if(iBars(_Symbol, PERIOD_H1) < shift + config.maSlowPeriod)
     {
      DebugPrint("GetMAValue: Insufficient bars for shift=" + (string)shift);
      return EMPTY_VALUE;
     }
   if(CopyBuffer(handle, 0, shift, 1, buf) <= 0)
     {
      DebugPrint("GetMAValue: Failed CopyBuffer, shift=" + (string)shift + ", err=" + (string)GetLastError());
      return EMPTY_VALUE;
     }
   return buf[0];
  }

/**
 * Updates all indicator values
 * @param force Force update even if not new bar
 */
void UpdateIndicators(bool force=false)
  {
   int bars = iBars(_Symbol, PERIOD_H1);
   bool newBar = (bars > market.lastSignalBar);
   if(!(newBar || force))
      return;

   market.maFast = GetMAValue(indicators.maFastHandle, 1);
   market.maSlow = GetMAValue(indicators.maSlowHandle, 1);

   market.maValuesValid = (market.maFast != EMPTY_VALUE && market.maSlow != EMPTY_VALUE);

   if(market.maValuesValid)
     {
      market.lastValidMAFast = market.maFast;
      market.lastValidMASlow = market.maSlow;
     }
   else
     {
      market.maFast = market.lastValidMAFast;
      market.maSlow = market.lastValidMASlow;
      DebugPrint("UpdateIndicators: Using fallback MA values");
     }

   if(config.useATRStep)
      market.atrStepValue = indicators.atrStepIndicator.Main(1);

   if(config.useVolFilter)
     {
      market.atrVolShortValue = indicators.atrVolShort.Main(1);
      market.atrVolLongValue  = indicators.atrVolLong.Main(1);
     }

   market.lastIndicatorUpdate = TimeCurrent();
   market.lastSignalBar = bars;
  }

// ------------------------------
// Initialization and Deinitialization
// ------------------------------

/**
 * EA initialization function
 * @return INIT_SUCCEEDED or INIT_FAILED
 */
int OnInit()
  {

   Print("==============================================");
   Print("WARNING: BotCilento EA comes with no guarantees");
   Print("Trading involves substantial risk of loss");
   Print("Use at your own risk - no liability accepted");
   Print("Always test thoroughly in demo account first");
   Print("Adjust parameters carefully before live use");
   Print("==============================================");

// Set up trade object with magic number and slippage
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetDeviationInPoints(MaxSlippage_In_Pips);

// Load configuration from input parameters
   config.enableEmergencyClose = Enable_Emergency_Close;
   config.enableSignalFlipClose = Enable_Signal_Flip_Close;
   config.magicNumber              = MagicNumber;
   config.eaComment                = EA_Comment;
   config.lotStrategy              = LotStrategy;
   config.initialLot               = Initial_Lot;
   config.martingaleMultiplier     = Martingale_Multiplier;
   config.maxGridTrades            = Max_Grid_Trades;
   config.stepType                 = StepType;
   config.fixedStepInPips          = Fixed_Step_In_Pips;
   config.stepATRPeriod            = Step_ATR_Period;
   config.stepATRMultiplier        = Step_ATR_Multiplier;
   config.stepATRTimeframe         = Step_ATR_Timeframe;
   config.takeProfitInPips         = Take_Profit_In_Pips;
   config.stagnationThresholdPips  = Stagnation_Threshold_Pips;
   config.maxSpreadInPips          = MaxSpread_In_Pips;
   config.maxSlippageInPips        = MaxSlippage_In_Pips;
   config.minFreeMarginBuffer      = Min_Free_Margin_Buffer;
   config.maxGridDrawdownPercent   = Max_Grid_Drawdown_Percent;
   config.flipOnOppositeSignal     = Flip_On_Opposite_Signal;
   config.maxCycleHours            = Max_Cycle_Hours;
   config.enableVolatilityFilter   = Enable_Volatility_Filter;
   config.vFilterShortATR          = V_Filter_Short_ATR;
   config.vFilterLongATR           = V_Filter_Long_ATR;
   config.vFilterThreshold         = V_Filter_Threshold;
   config.cycleCooldownHours       = CycleCooldownHours;
   config.minGridTradeIntervalMinutes = MinGridTradeIntervalMinutes;
   config.showInfo                 = ShowInfo;
   config.debugMode                = DebugMode;
   config.minEntryDelayMinutes     = MinEntryDelayMinutes;
   config.enableMASlopeFilter      = Enable_MA_Slope_Filter;
   config.useATRStep               = (config.stepType == ATR_BASED);
   config.useVolFilter             = (config.enableVolatilityFilter);
   config.maFastPeriod             = MA_Fast_Period;
   config.maSlowPeriod             = MA_Slow_Period;
   config.minGridStepPips          = Min_Grid_Step_Pips;
   config.maxTotalTrades           = Max_Total_Trades;
   config.maxTradesPerSecond       = Max_Trades_Per_Second;
   config.dailyLossLimitPercent    = Daily_Loss_Limit_Percent;
   config.dailyLossLimitDollar     = Daily_Loss_Limit_Dollar;
   config.maxPositionAgeHours      = Max_Position_Age_Hours;
   config.minCycleDurationMinutes  = Min_Cycle_Duration_Minutes;
   config.minSignalDistancePips    = Min_Signal_Distance_Pips;
   config.useClosePriceSignals     = Use_Close_Price_Signals;
   config.volumeFilterMultiplier   = Volume_Filter_Multiplier;
   config.enableGridTrading        = Enable_Grid_Trading;
   config.gridCloseProfitPips      = GridCloseProfitPips;        // NEW: Profit target to close grid
   config.enableGridCloseAtProfit  = EnableGridCloseAtProfit;    // NEW: Enable grid profit closure

// Check for sufficient historical data
   int requiredBars = config.maSlowPeriod + 10;
   if(iBars(_Symbol, PERIOD_H1) < requiredBars)
     {
      Print("Insufficient historical bars: ", iBars(_Symbol, PERIOD_H1), " required: ", requiredBars);
      return INIT_FAILED;
     }

// Create MA indicators
   indicators.maFastHandle = iMA(_Symbol, PERIOD_H1, config.maFastPeriod, 0, MODE_SMA, PRICE_CLOSE);
   if(indicators.maFastHandle == INVALID_HANDLE)
     {
      Print("Failed to create MAFast handle, error: ", GetLastError());
      return INIT_FAILED;
     }
   indicators.maSlowHandle = iMA(_Symbol, PERIOD_H1, config.maSlowPeriod, 0, MODE_SMA, PRICE_CLOSE);
   if(indicators.maSlowHandle == INVALID_HANDLE)
     {
      Print("Failed to create MASlow handle, error: ", GetLastError());
      return INIT_FAILED;
     }

// Test MA indicator
   double testMA = GetMAValue(indicators.maFastHandle, 1);
   if(testMA <= 0)
     {
      Print("Failed to get initial MA data, retrying after delay...");
      Sleep(1000);
      testMA = GetMAValue(indicators.maFastHandle, 1);
      if(testMA <= 0)
        {
         Print("Persistent MA data failure, initialization aborted");
         return INIT_FAILED;
        }
     }

// Add indicators to chart
   long chart_id = ChartID();
   ChartIndicatorAdd(chart_id, 0, indicators.maFastHandle);
   ChartIndicatorAdd(chart_id, 0, indicators.maSlowHandle);

// Create ATR indicators if needed
   if(config.useATRStep)
     {
      if(!indicators.atrStepIndicator.Create(_Symbol, config.stepATRTimeframe, config.stepATRPeriod))
        {
         Print("Failed to create ATR for step calc, err: ", GetLastError());
         return INIT_FAILED;
        }
     }

   if(config.useVolFilter)
     {
      if(!indicators.atrVolShort.Create(_Symbol, PERIOD_CURRENT, config.vFilterShortATR) ||
         !indicators.atrVolLong.Create(_Symbol, PERIOD_CURRENT, config.vFilterLongATR))
        {
         Print("Failed to create ATR for vol filter, err: ", GetLastError());
         return INIT_FAILED;
        }
     }

// Initialize market data
   market.pointValue   = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   market.digits       = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   market.pipValue     = market.pointValue * ((market.digits == 3 || market.digits == 5) ? 10.0 : 1.0);
   market.contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   market.leverage     = AccountInfoInteger(ACCOUNT_LEVERAGE);

   DebugPrint("OnInit: Point=" + DoubleToString(market.pointValue, market.digits) +
              " Pip=" + DoubleToString(market.pipValue, 5));

// Initialize MA values with fallback to close price if needed
   market.lastValidMAFast = GetMAValue(indicators.maFastHandle, 1);
   if(market.lastValidMAFast <= 0)
      market.lastValidMAFast = iClose(_Symbol, PERIOD_H1, 1);
   market.lastValidMASlow = GetMAValue(indicators.maSlowHandle, 1);
   if(market.lastValidMASlow <= 0)
      market.lastValidMASlow = iClose(_Symbol, PERIOD_H1, 1);
   market.maValuesValid = (market.lastValidMAFast > 0 && market.lastValidMASlow > 0);

// Initialize trading state
   state.currentGridTrades = 0;
   state.averageEntryPrice = 0.0;
   state.totalLots         = 0.0;
   state.buyCycleActive    = false;
   state.sellCycleActive   = false;
   state.isTradeInProgress = false;
   state.tradesThisTick    = 0;
   state.tradesThisSecond  = 0;
   state.lastTradeSecond   = 0;
   state.dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   state.dailyLossLimitHit = false;
   state.lastTradePrice    = 0.0;
   state.cycleStartTime    = 0;
   market.lastDailyResetCheck = TimeCurrent();

// Check for existing positions on initialization
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) &&
         PositionGetInteger(POSITION_MAGIC) == config.magicNumber &&
         PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         double price = PositionGetDouble(POSITION_PRICE_OPEN);
         double lot   = PositionGetDouble(POSITION_VOLUME);
         long   type  = PositionGetInteger(POSITION_TYPE);

         if(type == POSITION_TYPE_BUY || type == POSITION_TYPE_SELL)
           {
            if(type == POSITION_TYPE_BUY)
               state.buyCycleActive = true;
            else
               state.sellCycleActive = true;

            state.currentGridTrades++;
            double denominator = state.totalLots + lot;
            if(denominator <= 0.0)
              {
               DebugPrint("OnInit: Zero or negative denominator in avg price calc");
               state.averageEntryPrice = price;
              }
            else
              {
               state.averageEntryPrice = (state.averageEntryPrice * state.totalLots + price * lot) / denominator;
              }
            state.totalLots += lot;
            state.lastTradePrice = price;
           }
        }
     }

// Set cycle start time if positions exist
   if(state.buyCycleActive || state.sellCycleActive)
     {
      if(PositionSelectByTicket(PositionGetTicket(0)))
        {
         state.cycleStartTime = (datetime)PositionGetInteger(POSITION_TIME);
         if(state.cycleStartTime <= 0 || state.cycleStartTime < TimeCurrent() - 365*24*3600)
            state.cycleStartTime = TimeCurrent();
        }
     }

// Initialize market tracking variables
   market.lastSignalBar      = iBars(_Symbol, PERIOD_H1);
   market.lastPanelUpdate    = 0;
   market.lastSpreadUpdate   = 0;
   market.lastIndicatorUpdate = 0;
   market.lastProcessedPrice = 0.0;

// Set up timer for periodic updates
   EventSetTimer(1);

   return INIT_SUCCEEDED;
  }

/**
 * EA deinitialization function
 * @param reason Reason for deinitialization
 */
void OnDeinit(const int reason)
  {
// Clean up resources
   EventKillTimer();
   if(indicators.maFastHandle != INVALID_HANDLE)
      IndicatorRelease(indicators.maFastHandle);
   if(indicators.maSlowHandle != INVALID_HANDLE)
      IndicatorRelease(indicators.maSlowHandle);
   if(config.useATRStep)
      indicators.atrStepIndicator.Shutdown();
   if(config.useVolFilter)
     {
      indicators.atrVolShort.Shutdown();
      indicators.atrVolLong.Shutdown();
     }
   Comment("");  // Clear info panel
  }

// ------------------------------
// Risk Management Functions
// ------------------------------

/**
 * Checks if daily reset conditions are met (new day or loss limits)
 */
void CheckDailyReset()
  {
   datetime now = TimeCurrent();
   if(now > market.lastDailyResetCheck + 3600)
     {
      MqlDateTime today, lastCheck;
      TimeToStruct(now, today);
      TimeToStruct(market.lastDailyResetCheck, lastCheck);

      // Check if new day started
      if(today.day != lastCheck.day)
        {
         state.dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         state.dailyLossLimitHit = false;
         DebugPrint("Daily reset: New day started. Balance: " + DoubleToString(state.dailyStartBalance, 2));
        }

      // Check daily loss limits
      if(!state.dailyLossLimitHit)
        {
         double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         double loss = state.dailyStartBalance - currentBalance;
         double lossPercent = (loss / state.dailyStartBalance) * 100.0;

         if((config.dailyLossLimitDollar > 0 && loss >= config.dailyLossLimitDollar) ||
            (config.dailyLossLimitPercent > 0 && lossPercent >= config.dailyLossLimitPercent))
           {
            state.dailyLossLimitHit = true;
            CloseAllOpenTrades();
            Print("Daily loss limit triggered! Loss: " + DoubleToString(loss, 2) +
                  " (" + DoubleToString(lossPercent, 1) + "%)");
           }
        }

      market.lastDailyResetCheck = now;
     }
  }

/**
 * Closes positions that have been open too long
 */
void CheckPositionAge()
  {
   if(config.maxPositionAgeHours <= 0)
      return;

   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) &&
         PositionGetInteger(POSITION_MAGIC) == config.magicNumber &&
         PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
         double hoursOpen = (TimeCurrent() - openTime) / 3600.0;

         // Adjust for weekends (don't count weekend hours)
         int fullWeeks = (int)(hoursOpen / (24*7));
         hoursOpen -= fullWeeks * 48;

         if(hoursOpen >= config.maxPositionAgeHours)
           {
            Print("Closing position #", ticket, " - Max age reached (",
                  DoubleToString(hoursOpen, 1), " hours)");
            trade.PositionClose(ticket);
           }
        }
     }
  }

/**
 * Executes a trade with proper checks and limits
 * @param orderType Type of order (BUY/SELL)
 * @param lot Lot size
 * @param comment Trade comment
 * @return true if trade executed successfully
 */
bool ExecuteTrade(ENUM_ORDER_TYPE orderType, double lot, string comment)
  {
// Check trade limits
   if(state.isTradeInProgress ||
      state.tradesThisTick >= 1 ||
      state.tradesThisSecond >= config.maxTradesPerSecond ||
      state.dailyLossLimitHit)
     {
      DebugPrint("ExecuteTrade: Blocked by trade limits");
      return false;
     }

// Check market hours
   if(!IsMarketOpen())
     {
      DebugPrint("ExecuteTrade: Market closed - trade skipped");
      return false;
     }

// Aggressive margin check when emergency close disabled
   if(!config.enableEmergencyClose)
     {
      double price = (orderType == ORDER_TYPE_BUY) ? market.ask : market.bid;
      double requiredMargin = (lot * market.contractSize * price) / (double)market.leverage;
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

      if(freeMargin < requiredMargin * 3)
        {
         DebugPrint("ExecuteTrade: Insufficient free margin (aggressive mode)");
         return false;
        }
     }

// Standard margin check
   if(!CheckMargin(lot, orderType))
     {
      Print("ExecuteTrade: Margin check failed");
      return false;
     }

// Set up trade parameters
   double price = (orderType == ORDER_TYPE_BUY) ? market.ask : market.bid;
   double sl = 0, tp = 0;
   CTrade localTrade;
   localTrade.SetExpertMagicNumber(config.magicNumber);
   localTrade.SetDeviationInPoints(config.maxSlippageInPips);

// Execute trade
   bool success = false;
   if(orderType == ORDER_TYPE_BUY)
      success = localTrade.Buy(lot, _Symbol, price, sl, tp, comment);
   else
      success = localTrade.Sell(lot, _Symbol, price, sl, tp, comment);

// Update state if successful
   if(success)
     {
      state.lastGridTradeTime = TimeCurrent();
      state.lastTradeSecond = TimeCurrent();
      state.tradesThisTick++;
      state.tradesThisSecond++;
      state.lastTradePrice = price;
      DebugPrint("Trade executed: " + EnumToString(orderType) +
                 " Lot: " + DoubleToString(lot, 2) +
                 " Price: " + DoubleToString(price, market.digits));
      return true;
     }
   else
     {
      Print("Trade failed: ", EnumToString(orderType), " Error: ", GetLastError());
      return false;
     }
  }

/**
 * Checks if there's sufficient margin for a trade
 * @param lot Lot size to check
 * @param orderType Type of order (BUY/SELL)
 * @return true if margin is sufficient
 */
bool CheckMargin(double lot, ENUM_ORDER_TYPE orderType)
  {
   if(market.leverage == 0)
     {
      Print("Error: leverage is zero");
      return false;
     }

// Calculate required margin with buffer
   double price = (orderType == ORDER_TYPE_BUY) ? market.ask : market.bid;
   double marginRequired = (lot * market.contractSize * price) / (double)market.leverage;
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double bufferMultiplier = 1.2;

   if((freeMargin - marginRequired * bufferMultiplier) < config.minFreeMarginBuffer)
     {
      DebugPrint("CheckMargin: Insufficient margin. Required: " +
                 DoubleToString(marginRequired * bufferMultiplier, 2) +
                 " Free: " + DoubleToString(freeMargin, 2));
      return false;
     }

// Check margin level
   double accountMargin = AccountInfoDouble(ACCOUNT_MARGIN);
   if(accountMargin > 1e-6)
     {
      double marginLevel = (AccountInfoDouble(ACCOUNT_EQUITY) / accountMargin) * 100.0;
      if(marginLevel < 50.0)
        {
         DebugPrint("CheckMargin: margin level too low (" + DoubleToString(marginLevel, 1) + "%)");
         return false;
        }
     }

   return true;
  }

/**
 * Closes all open trades and resets cycle state
 */
void CloseAllOpenTrades()
  {
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) &&
         PositionGetInteger(POSITION_MAGIC) == config.magicNumber &&
         PositionGetString(POSITION_SYMBOL) == _Symbol)
        {
         trade.PositionClose(ticket);
        }
     }
   ResetCycleState();
  }

// ------------------------------
// Position Management Functions
// ------------------------------

/**
 * Closes all trades of a specific type (BUY/SELL)
 * @param orderType Type of trades to close
 */
void CloseAllTradesOfType(ENUM_ORDER_TYPE orderType)
  {
   int closedCount = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) &&
         PositionGetInteger(POSITION_MAGIC) == config.magicNumber &&
         PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_TYPE) == orderType)
        {
         if(trade.PositionClose(ticket))
            closedCount++;
         else
            Print("Close fail #", ticket, " err=", GetLastError());
        }
     }
   DebugPrint("Closed " + IntegerToString(closedCount) + " trades of type " + EnumToString(orderType));
   state.lastCycleCloseTime = TimeCurrent();
  }

/**
 * Resets all cycle state variables
 */
void ResetCycleState()
  {
   state.buyCycleActive = false;
   state.sellCycleActive = false;
   state.currentGridTrades = 0;
   state.averageEntryPrice = 0.0;
   state.totalLots = 0.0;
   state.cycleStartTime = 0;
   state.lastGridTradeTime = 0;
   state.isTradeInProgress = false;
   state.tradesThisTick = 0;
   state.tradesThisSecond = 0;
   state.lastTradeSecond = 0;
   state.lastTradePrice = 0.0;
  }

// ------------------------------
// Core Trading Logic
// ------------------------------

/**
 * Main tick processing function
 */
void OnTick()
  {
// Update market data
   SnapshotQuotes();
   CheckDailyReset();

// Skip processing if price hasn't moved significantly
   double currentPrice = (market.bid + market.ask) / 2.0;
   if(MathAbs(currentPrice - market.lastProcessedPrice) < market.pipValue * 5 && market.lastProcessedPrice != 0.0)
      return;
   market.lastProcessedPrice = currentPrice;

// Reset trade counters
   state.tradesThisTick = 0;
   datetime currentSecond = TimeCurrent();
   if(currentSecond > state.lastTradeSecond)
     {
      state.tradesThisSecond = 0;
      state.lastTradeSecond = currentSecond;
     }

// Check if daily loss limit was hit
   if(state.dailyLossLimitHit)
     {
      if(config.showInfo)
         Comment("Trading halted: Daily loss limit reached");
      return;
     }

// Perform safety checks
   CheckSafetyConditions();
   CheckPositionAge();

// Check for new cycle on new bar
   static int lastBar = 0;
   int currentBar = iBars(_Symbol, PERIOD_H1);
   if(currentBar > lastBar && !state.buyCycleActive && !state.sellCycleActive)
     {
      CheckForNewCycle();
      lastBar = currentBar;
     }

// Manage active cycles
   if(state.buyCycleActive)
      ManageBuyCycle();
   else
      if(state.sellCycleActive)
         ManageSellCycle();
  }

/**
 * Timer function for periodic updates
 */
void OnTimer()
  {
   datetime now = TimeCurrent();

// Update indicators if needed
   if(now >= market.lastIndicatorUpdate + 120)
      UpdateIndicators(true);
   else
      UpdateIndicators(false);

// Update spread periodically
   if(now >= market.lastSpreadUpdate + 5)
     {
      double spreadPts = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      double pf = ((market.digits == 3 || market.digits == 5) ? 10.0 : 1.0);
      market.currentSpreadInPips = spreadPts / pf;
      market.lastSpreadUpdate = now;
     }

// Update info panel if enabled
   if(config.showInfo && now >= market.lastPanelUpdate + 5)
     {
      DisplayInfoPanel();
      market.lastPanelUpdate = now;
     }

// Reset trade in progress flag if timeout
   if(state.isTradeInProgress && now >= state.lastGridTradeTime + 5)
      state.isTradeInProgress = false;
  }

/**
 * Checks for new trading cycle conditions
 */
void CheckForNewCycle()
  {
// Check trade limits
   if(state.isTradeInProgress || state.tradesThisSecond >= config.maxTradesPerSecond)
     {
      DebugPrint("CheckForNewCycle: blocked by trade in progress or max trades per second");
      return;
     }

// Check minimum entry delay
   if(TimeCurrent() < state.lastCycleStartTime + config.minEntryDelayMinutes * 60)
     {
      DebugPrint("CheckForNewCycle: blocked by MinEntryDelayMinutes");
      return;
     }

// Get price and MA values
   double price  = iClose(_Symbol, PERIOD_H1, 1);
   double maFast = GetMAValue(indicators.maFastHandle, 1);
   double maSlow = GetMAValue(indicators.maSlowHandle, 1);

// Volume filter check
   long prevVolume    = iVolume(_Symbol, PERIOD_H1, 2);
   long currentVolume = iVolume(_Symbol, PERIOD_H1, 1);

   if(currentVolume < (long)(prevVolume * config.volumeFilterMultiplier))
     {
      DebugPrint("CheckForNewCycle: Volume too low - signal ignored");
      return;
     }

// MA slope filter check
   if(config.enableMASlopeFilter)
     {
      double maFastPrev = GetMAValue(indicators.maFastHandle, 2);
      double maPrevSlope = maFast - maFastPrev;
      if(MathAbs(maPrevSlope) < (market.pipValue * 5))
        {
         DebugPrint("CheckForNewCycle: blocked by MA slope filter");
         return;
        }
     }

// Cycle cooldown check
   if(TimeCurrent() < state.lastCycleCloseTime + config.cycleCooldownHours * 3600)
     {
      DebugPrint("CheckForNewCycle: cooldown active");
      return;
     }

// Volatility filter check
   if(config.useVolFilter && IsMarketTooVolatile())
     {
      DebugPrint("CheckForNewCycle: volatility filter blocked");
      return;
     }

// Spread check
   if(market.currentSpreadInPips > config.maxSpreadInPips)
     {
      DebugPrint("CheckForNewCycle: spread too high");
      return;
     }

// MA validity check
   if(!market.maValuesValid)
     {
      DebugPrint("CheckForNewCycle: invalid MA values");
      return;
     }

// Determine signal price (close or bid)
   double signalPrice = config.useClosePriceSignals ? price : market.bid;

// Check for buy signal (price above both MAs with minimum distance)
   bool buySignal = signalPrice > maFast &&
                    signalPrice > maSlow &&
                    (signalPrice - maFast) >= config.minSignalDistancePips * market.pipValue;

// Check for sell signal (price below both MAs with minimum distance)
   bool sellSignal = signalPrice < maFast &&
                     signalPrice < maSlow &&
                     (maFast - signalPrice) >= config.minSignalDistancePips * market.pipValue;

// Enter appropriate cycle if signal detected
   if(buySignal)
      EnterBuyCycle();
   else
      if(sellSignal)
         EnterSellCycle();
  }

/**
 * Starts a new buy cycle
 */
void EnterBuyCycle()
  {
// Don't enter if sell cycle active and flip not enabled
   if(state.sellCycleActive && !config.enableSignalFlipClose)
      return;

// Check max trades limit
   if(state.currentGridTrades >= config.maxTotalTrades)
     {
      DebugPrint("EnterBuyCycle: max total trades reached");
      return;
     }

// Calculate and execute initial buy trade
   double lot = NormalizeLot(config.initialLot);
   if(ExecuteTrade(ORDER_TYPE_BUY, lot, config.eaComment))
     {
      // Update cycle state
      state.lastCycleStartTime = TimeCurrent();
      state.buyCycleActive   = true;
      state.currentGridTrades= 1;
      state.averageEntryPrice= market.ask;
      state.totalLots        = lot;
      state.cycleStartTime   = TimeCurrent();
      state.lastTradePrice   = market.ask;
      DebugPrint("Buy cycle started, lot=" + DoubleToString(lot, 2) + " at " + DoubleToString(market.ask, market.digits));
     }
  }

/**
 * Starts a new sell cycle
 */
void EnterSellCycle()
  {
// Check max trades limit
   if(state.currentGridTrades >= config.maxTotalTrades)
     {
      DebugPrint("EnterSellCycle: max total trades reached");
      return;
     }

// Calculate and execute initial sell trade
   double lot = NormalizeLot(config.initialLot);
   if(ExecuteTrade(ORDER_TYPE_SELL, lot, config.eaComment))
     {
      // Update cycle state
      state.lastCycleStartTime = TimeCurrent();
      state.sellCycleActive   = true;
      state.currentGridTrades = 1;
      state.averageEntryPrice = market.bid;
      state.totalLots         = lot;
      state.cycleStartTime    = TimeCurrent();
      state.lastTradePrice    = market.bid;
      DebugPrint("Sell cycle started, lot=" + DoubleToString(lot, 2) + " at " + DoubleToString(market.bid, market.digits));
     }
  }

/**
 * NEW: Checks if grid should be closed at profit target
 */
void CheckGridProfitClosure()
  {
// Skip if feature disabled or invalid settings
   if(!config.enableGridCloseAtProfit || config.gridCloseProfitPips <= 0)
      return;

// Check buy cycle profit
   if(state.buyCycleActive)
     {
      double currentProfitPips = (market.bid - state.averageEntryPrice) / market.pipValue;
      if(currentProfitPips >= config.gridCloseProfitPips)
        {
         Print("Closing BUY grid at profit: ", DoubleToString(currentProfitPips, 1), " pips");
         CloseAllTradesOfType(ORDER_TYPE_BUY);
         ResetCycleState();
        }
     }
// Check sell cycle profit
   else
      if(state.sellCycleActive)
        {
         double currentProfitPips = (state.averageEntryPrice - market.ask) / market.pipValue;
         if(currentProfitPips >= config.gridCloseProfitPips)
           {
            Print("Closing SELL grid at profit: ", DoubleToString(currentProfitPips, 1), " pips");
            CloseAllTradesOfType(ORDER_TYPE_SELL);
            ResetCycleState();
           }
        }
  }

/**
 * Manages an active buy cycle
 */
void ManageBuyCycle()
  {
// Grid trading logic
   if(config.enableGridTrading)
     {
      // Check max trades limit
      if(state.currentGridTrades >= config.maxTotalTrades)
        {
         Print("Max total trades reached, closing buy cycle");
         CloseAllTradesOfType(ORDER_TYPE_BUY);
         ResetCycleState();
         return;
        }

      // Calculate grid step and price differences
      double gridStep = GetGridStep();
      double priceDiff = state.averageEntryPrice - market.bid;
      double lastTradeDistance = state.lastTradePrice - market.bid;

      // Add to grid if conditions met
      if(priceDiff >= gridStep && state.currentGridTrades < config.maxGridTrades && lastTradeDistance >= gridStep)
        {
         DebugPrint("Buy grid condition met: priceDiff=" + DoubleToString(priceDiff/market.pipValue,1) +
                    "pips, lastTradeDist=" + DoubleToString(lastTradeDistance/market.pipValue,1) + "pips");
         AddToBuyGrid();
        }
      else
         // Close cycle if max grid trades reached
         if(state.currentGridTrades >= config.maxGridTrades)
           {
            Print("Max grid reached, closing buy cycle");
            CloseAllTradesOfType(ORDER_TYPE_BUY);
            ResetCycleState();
            return;
           }
     }

// NEW: Check for profit closure
   CheckGridProfitClosure();

// Check other exit conditions
   CheckForTakeProfit();
   CheckForEmergencyClose();
   CheckForStagnation();

// Check for signal flip if enabled
   if(config.flipOnOppositeSignal && config.enableSignalFlipClose &&
      market.maValuesValid &&
      (TimeCurrent() > state.cycleStartTime + config.minCycleDurationMinutes*60))
     {
      double price = iClose(_Symbol, PERIOD_H1, 1);
      if(price < market.maFast || price < market.maSlow)
        {
         Print("Flip to SELL");
         CloseAllTradesOfType(ORDER_TYPE_BUY);
         ResetCycleState();
         EnterSellCycle();
        }
     }
  }

/**
 * Manages an active sell cycle
 */
void ManageSellCycle()
  {
// Grid trading logic
   if(config.enableGridTrading)
     {
      // Check max trades limit
      if(state.currentGridTrades >= config.maxTotalTrades)
        {
         Print("Max total trades reached, closing sell cycle");
         CloseAllTradesOfType(ORDER_TYPE_SELL);
         ResetCycleState();
         return;
        }

      // Calculate grid step and price differences
      double gridStep = GetGridStep();
      double priceDiff = market.ask - state.averageEntryPrice;
      double lastTradeDistance = market.ask - state.lastTradePrice;

      // Add to grid if conditions met
      if(priceDiff >= gridStep && state.currentGridTrades < config.maxGridTrades && lastTradeDistance >= gridStep)
        {
         DebugPrint("Sell grid condition met: priceDiff=" + DoubleToString(priceDiff/market.pipValue,1) +
                    "pips, lastTradeDist=" + DoubleToString(lastTradeDistance/market.pipValue,1) + "pips");
         AddToSellGrid();
        }
      else
         // Close cycle if max grid trades reached
         if(state.currentGridTrades >= config.maxGridTrades)
           {
            Print("Max grid reached, closing sell cycle");
            CloseAllTradesOfType(ORDER_TYPE_SELL);
            ResetCycleState();
            return;
           }
     }

// NEW: Check for profit closure
   CheckGridProfitClosure();

// Check other exit conditions
   CheckForTakeProfit();
   CheckForEmergencyClose();
   CheckForStagnation();

// Check for signal flip if enabled
   if(config.flipOnOppositeSignal && config.enableSignalFlipClose &&
      market.maValuesValid &&
      (TimeCurrent() > state.cycleStartTime + config.minCycleDurationMinutes*60))
     {
      double price = iClose(_Symbol, PERIOD_H1, 1);
      if(price > market.maFast || price > market.maSlow)
        {
         Print("Flip to BUY");
         CloseAllTradesOfType(ORDER_TYPE_SELL);
         ResetCycleState();
         EnterBuyCycle();
        }
     }
  }

/**
 * Adds a new trade to the buy grid
 */
void AddToBuyGrid()
  {
// Check minimum grid trade interval
   datetime now = TimeCurrent();
   if(now < state.lastGridTradeTime + config.minGridTradeIntervalMinutes * 60)
     {
      DebugPrint("AddToBuyGrid: blocked by min interval");
      return;
     }

// Volatility filter check
   if(config.useVolFilter && IsMarketTooVolatile())
     {
      DebugPrint("AddToBuyGrid: too volatile");
      return;
     }

// Spread check
   if(market.currentSpreadInPips > config.maxSpreadInPips)
     {
      DebugPrint("AddToBuyGrid: spread too high");
      return;
     }

// Calculate and validate next lot size
   double lot = CalculateNextLotSize();
   if(lot <= 0.0 || !MathIsValidNumber(lot))
     {
      DebugPrint("AddToBuyGrid: invalid lot size");
      return;
     }

// Execute buy trade
   if(ExecuteTrade(ORDER_TYPE_BUY, lot, config.eaComment))
     {
      // Update average entry price
      double denominator = state.totalLots + lot;

      if(denominator > 1e-6)
        {
         state.averageEntryPrice = (state.averageEntryPrice * state.totalLots + market.ask * lot) / denominator;
        }
      else
        {
         state.averageEntryPrice = market.ask;
        }

      // Update cycle state
      state.totalLots += lot;
      state.currentGridTrades++;
      state.lastTradePrice = market.ask;
      DebugPrint("Buy grid added, lot=" + DoubleToString(lot, 2) + " at " + DoubleToString(market.ask, market.digits));
     }
  }

/**
 * Adds a new trade to the sell grid
 */
void AddToSellGrid()
  {
// Check minimum grid trade interval
   datetime now = TimeCurrent();
   if(now < state.lastGridTradeTime + config.minGridTradeIntervalMinutes * 60)
     {
      DebugPrint("AddToSellGrid: blocked by min interval");
      return;
     }

// Volatility filter check
   if(config.useVolFilter && IsMarketTooVolatile())
     {
      DebugPrint("AddToSellGrid: too volatile");
      return;
     }

// Spread check
   if(market.currentSpreadInPips > config.maxSpreadInPips)
     {
      DebugPrint("AddToSellGrid: spread too high");
      return;
     }

// Calculate and validate next lot size
   double lot = CalculateNextLotSize();
   if(lot <= 0.0 || !MathIsValidNumber(lot))
     {
      DebugPrint("AddToSellGrid: invalid lot size");
      return;
     }

// Execute sell trade
   if(ExecuteTrade(ORDER_TYPE_SELL, lot, config.eaComment))
     {
      // Update average entry price
      double denominator = state.totalLots + lot;

      if(denominator > 1e-6)
        {
         state.averageEntryPrice = (state.averageEntryPrice * state.totalLots + market.bid * lot) / denominator;
        }
      else
        {
         state.averageEntryPrice = market.bid;
        }

      // Update cycle state
      state.totalLots += lot;
      state.currentGridTrades++;
      state.lastTradePrice = market.bid;
      DebugPrint("Sell grid added, lot=" + DoubleToString(lot, 2) + " at " + DoubleToString(market.bid, market.digits));
     }
  }

/**
 * Calculates the next lot size based on strategy
 * @return Calculated lot size
 */
double CalculateNextLotSize()
  {
   double lot = config.initialLot;
   if(config.lotStrategy == MARTINGALE)
     {
      if(state.currentGridTrades == 0)
         return NormalizeLot(lot);
      lot = config.initialLot * MathPow(config.martingaleMultiplier, state.currentGridTrades);
     }
   else
      if(config.lotStrategy == ARITHMETIC_PROGRESSION)
         lot = config.initialLot * (state.currentGridTrades + 1);
   return NormalizeLot(lot);
  }

/**
 * Calculates the grid step size
 * @return Grid step in price units
 */
double GetGridStep()
  {
   double minStep = config.minGridStepPips * market.pipValue;
   if(!config.useATRStep)
      return MathMax(config.fixedStepInPips * market.pipValue, minStep);

   if(market.atrStepValue <= 0 || market.atrStepValue == EMPTY_VALUE)
     {
      DebugPrint("GetGridStep: invalid ATR, fallback to fixed");
      return MathMax(config.fixedStepInPips * market.pipValue, minStep);
     }
   return MathMax(market.atrStepValue * config.stepATRMultiplier, minStep);
  }

/**
 * Checks for take profit conditions
 */
void CheckForTakeProfit()
  {
// Calculate take profit distance
   double takeProfitPips = config.takeProfitInPips;
   if(config.useATRStep && market.atrStepValue > 0 && market.atrStepValue != EMPTY_VALUE)
      takeProfitPips = market.atrStepValue / market.pipValue * config.stepATRMultiplier;

// Adjust for spread
   double spreadCost = market.currentSpreadInPips * market.pipValue;

// Check buy cycle take profit
   if(state.buyCycleActive)
     {
      double profitPrice = state.averageEntryPrice + (takeProfitPips * market.pipValue + spreadCost);
      if(market.bid >= profitPrice)
        {
         Print("TP hit BUY, closing cycle");
         CloseAllTradesOfType(ORDER_TYPE_BUY);
         ResetCycleState();
        }
     }
   else
      // Check sell cycle take profit
      if(state.sellCycleActive)
        {
         double profitPrice = state.averageEntryPrice - (takeProfitPips * market.pipValue + spreadCost);
         if(market.ask <= profitPrice)
           {
            Print("TP hit SELL, closing cycle");
            CloseAllTradesOfType(ORDER_TYPE_SELL);
            ResetCycleState();
           }
        }
  }

/**
 * Checks for emergency close conditions (max drawdown)
 */
void CheckForEmergencyClose()
  {
   if(!config.enableEmergencyClose)
      return;
   if(config.maxGridDrawdownPercent <= 0)
      return;

// Calculate current drawdown
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0.0)
      return;
   double dd = (balance - equity) / balance * 100.0;

// Close all if drawdown exceeds limit
   if(dd >= config.maxGridDrawdownPercent)
     {
      if(state.buyCycleActive)
         CloseAllTradesOfType(ORDER_TYPE_BUY);
      if(state.sellCycleActive)
         CloseAllTradesOfType(ORDER_TYPE_SELL);
      Print("Emergency close, DD=", DoubleToString(dd,1), "%");
      ResetCycleState();
     }
  }

/**
 * Checks for stagnation (price not moving enough)
 */
void CheckForStagnation()
  {
   if(state.cycleStartTime <= 0)
      return;
   double durationHours = (TimeCurrent() - state.cycleStartTime) / 3600.0;
   if(durationHours < 0.5)
      return;

// Calculate current price difference from average entry
   double curPrice = state.buyCycleActive ? market.bid : market.ask;
   double priceDiffPips = MathAbs(curPrice - state.averageEntryPrice) / market.pipValue;

// Close if price hasn't moved enough
   if(priceDiffPips <= config.stagnationThresholdPips)
     {
      Print("Stagnation: closing cycle");
      if(state.buyCycleActive)
         CloseAllTradesOfType(ORDER_TYPE_BUY);
      else
         if(state.sellCycleActive)
            CloseAllTradesOfType(ORDER_TYPE_SELL);
      ResetCycleState();
     }
  }

/**
 * Normalizes lot size to broker requirements
 * @param lot Raw lot size
 * @return Normalized lot size
 */
double NormalizeLot(double lot)
  {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lot = MathMax(lot, minLot);
   lot = MathMin(lot, maxLot);
   lot = MathRound(lot / step) * step;
   return lot;
  }

/**
 * Checks if market is too volatile based on ATR ratio
 * @return true if too volatile, false otherwise
 */
bool IsMarketTooVolatile()
  {
   if(!config.useVolFilter)
      return false;
   if(market.atrVolLongValue == 0)
      return false;
   double ratio = market.atrVolShortValue / market.atrVolLongValue;
   return (ratio >= config.vFilterThreshold);
  }

/**
 * Checks various safety conditions before trading
 */
void CheckSafetyConditions()
  {
   if((state.buyCycleActive || state.sellCycleActive) && state.currentGridTrades >= config.maxGridTrades)
     {
      DebugPrint("Safety: max grid reached");
      return;
     }
   if(market.currentSpreadInPips > config.maxSpreadInPips)
     {
      DebugPrint("Safety: spread too high");
      return;
     }
   if(state.currentGridTrades >= config.maxTotalTrades)
     {
      DebugPrint("Safety: max total trades reached");
      if(state.buyCycleActive)
         CloseAllTradesOfType(ORDER_TYPE_BUY);
      if(state.sellCycleActive)
         CloseAllTradesOfType(ORDER_TYPE_SELL);
      ResetCycleState();
     }
  }

/**
 * Displays the info panel on chart
 */
void DisplayInfoPanel()
  {

   string panelText = "BotCilento EA v1.35\n";
   panelText += "================================\n";
   panelText += "WARNING: This EA does not guarantee profits.\n";
   panelText += "Use at your own risk. No liability accepted.\n";
   panelText += "Always test in demo before live trading.\n";
   panelText += "================================\n";
   panelText += "Symbol: " + _Symbol + "\n";
   panelText += "Spread: " + DoubleToString(market.currentSpreadInPips, 1) + " pips\n";
   panelText += "Daily P/L: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE) - state.dailyStartBalance, 2) + "\n";
   panelText += "Grid Trading: " + (config.enableGridTrading ? "ON" : "OFF") + "\n";

// Add status information
   if(state.dailyLossLimitHit)
      panelText += "STATUS: DAILY LOSS LIMIT ACTIVE!\n";
   else
      if(state.buyCycleActive)
        {
         double profitPips = (market.bid - state.averageEntryPrice) / market.pipValue;
         panelText += "Status: BUY CYCLE ACTIVE\n";
         panelText += "Grid Profit: " + DoubleToString(profitPips, 1) + " pips\n";
         panelText += "Grid Trades: " + IntegerToString(state.currentGridTrades) + "/" + IntegerToString(config.maxGridTrades) + "\n";
         panelText += "Avg Entry: " + DoubleToString(state.averageEntryPrice, Digits()) + "\n";
         panelText += "Total Lots: " + DoubleToString(state.totalLots, 2) + "\n";
         panelText += "Last Trade: " + DoubleToString(state.lastTradePrice, Digits()) + "\n";
        }
      else
         if(state.sellCycleActive)
           {
            double profitPips = (state.averageEntryPrice - market.ask) / market.pipValue;
            panelText += "Status: SELL CYCLE ACTIVE\n";
            panelText += "Grid Profit: " + DoubleToString(profitPips, 1) + " pips\n";
            panelText += "Grid Trades: " + IntegerToString(state.currentGridTrades) + "/" + IntegerToString(config.maxGridTrades) + "\n";
            panelText += "Avg Entry: " + DoubleToString(state.averageEntryPrice, Digits()) + "\n";
            panelText += "Total Lots: " + DoubleToString(state.totalLots, 2) + "\n";
            panelText += "Last Trade: " + DoubleToString(state.lastTradePrice, Digits()) + "\n";
           }
         else
           {
            panelText += "Status: WAITING FOR SIGNAL\n";
           }

// Add margin information
   panelText += "Free Margin: " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2) + "\n";
   Comment(panelText);
  }

// ------------------------------
// Input Parameters (User Settings)
// ------------------------------

// ===== GENERAL EA SETTINGS =====
input group "General EA Settings"
input int      MagicNumber            = 152311;                // Unique EA identifier
input string   EA_Comment             = "BotCilento v1.33";    // Trade comment
input bool     ShowInfo               = true;                  // Show info panel
input bool     DebugMode              = true;                  // Enable debug logging

// ===== LOT SIZING & GRID SETTINGS =====
input group "Lot Sizing & Grid Settings"
input ENUM_LOT_STRATEGY LotStrategy    = MARTINGALE;            // Lot sizing strategy
input bool     Enable_Grid_Trading     = true;                  // Enable grid trading
input double   Initial_Lot             = 0.1;                  // Initial lot size
input double   Martingale_Multiplier   = 1.3;                   // Lot multiplier for Martingale
input int      Max_Grid_Trades         = 5;                     // Maximum trades in grid
input int      Max_Total_Trades        = 10;                    // Max total trades per cycle
input double   Min_Grid_Step_Pips      = 20.0;                  // Minimum grid step in pips
input ENUM_STEP_TYPE StepType          = FIXED_PIPS;            // Grid step type
input double   Fixed_Step_In_Pips      = 50.0;                  // Fixed step in pips
input int      Step_ATR_Period         = 14;                    // ATR period for step calculation
input double   Step_ATR_Multiplier     = 0.5;                   // ATR multiplier for step
input ENUM_TIMEFRAMES Step_ATR_Timeframe = PERIOD_H1;            // ATR timeframe

// ===== TRADE ENTRY & SIGNAL FILTERS =====
input group "Trade Entry & Signal Filters"
input bool     Enable_MA_Slope_Filter  = true;                  // Enable MA slope filter
input int      MA_Fast_Period          = 5;                     // Fast MA period
input int      MA_Slow_Period          = 20;                    // Slow MA period
input bool     Use_Close_Price_Signals = true;                  // Use closing prices for signals
input double   Min_Signal_Distance_Pips= 15.0;                  // Min signal distance in pips
input double   Volume_Filter_Multiplier= 1.5;                   // Volume filter multiplier
input bool     Enable_Volatility_Filter= true;                  // Enable volatility filter
input int      V_Filter_Short_ATR      = 5;                     // Short ATR period
input int      V_Filter_Long_ATR       = 20;                    // Long ATR period
input double   V_Filter_Threshold      = 1.5;                   // Volatility threshold multiplier
input double   MaxSpread_In_Pips       = 5.0;                   // Maximum allowed spread
input int      MaxSlippage_In_Pips     = 15;                    // Maximum allowed slippage
input double   Min_Free_Margin_Buffer  = 100.0;                 // Minimum free margin buffer

// ===== TAKE PROFIT, CYCLE & TIMING =====
input group "Take Profit, Cycle & Timing"
input bool     Enable_Signal_Flip_Close   = true;               // Close trades on signal flip
input double   Take_Profit_In_Pips     = 100.0;                 // Take profit in pips
input bool     Flip_On_Opposite_Signal = true;                  // Close & flip on opposite MA
input int      Max_Cycle_Hours         = 48;                    // Max cycle duration (hours)
input int      Min_Cycle_Duration_Minutes = 180;                // Min cycle duration before flip
input int      MinEntryDelayMinutes    = 60;                    // Min minutes between new cycles
input int      MinGridTradeIntervalMinutes= 30;                 // Min minutes between grid trades
input int      CycleCooldownHours      = 4;                     // Cooldown after cycle close
input int      Max_Position_Age_Hours  = 72;                    // Close positions after X hours

// ===== RISK MANAGEMENT =====
input group "Risk Management"
input bool     Enable_Emergency_Close     = true;               // Close trades at max drawdown
input double   Max_Grid_Drawdown_Percent  = 20.0;               // Max drawdown before close
input double   Daily_Loss_Limit_Percent   = 5.0;                // Max daily loss (%)
input double   Daily_Loss_Limit_Dollar    = 0.0;                // Max daily loss ($, 0=disable)
input int      Max_Trades_Per_Second      = 1;                  // Max trades per second

// ===== OTHER CONDITIONS =====
input group "Other Conditions"
input double   Stagnation_Threshold_Pips = 10.0;                // Stagnation threshold

// ===== GRID PROFIT CLOSURE SETTINGS =====
input group "Grid Profit Closure"
input bool     EnableGridCloseAtProfit = true;                   // Enable grid closure at profit
input double   GridCloseProfitPips     = 10.0;                   // Close grid when profit reaches (pips)
//+------------------------------------------------------------------+
