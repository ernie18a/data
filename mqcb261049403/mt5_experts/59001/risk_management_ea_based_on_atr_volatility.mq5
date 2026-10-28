//+------------------------------------------------------------------+
//| EnhancedRiskManagerEA.mq5                                        |
//| Copyright 2025, Advanced Trading Systems                         |
//| https://forge.mql5.io                                            |
//+------------------------------------------------------------------+
#property copyright "Advanced Trading Systems"
#property link      "https://forge.mql5.io"
#property version   "3.00"
#property strict
#property description "Professional Risk-Based Position Sizing Expert Advisor"
#property description "Dynamic lot calculation using ATR volatility measurement"
#property description "Optimized performance with reduced redundancy"

//--- Include necessary libraries
#include <Trade\Trade.mqh>

//--- Input parameters
input group "=== Capital Protection Settings ==="
input double RiskPercentagePerTrade = 1.0;        // Risk per trade (% of balance)
input double MaximumRiskInMoney = 0;              // Max risk cap in account currency (0 = no limit)

input group "=== Volatility Analysis ==="
input int    VolatilityPeriod = 14;               // ATR calculation period
input double VolatilityMultiplier = 2.0;          // Stop loss ATR multiplier
input bool   EnableDynamicStopLoss = true;        // Use ATR-based stop loss
input int    StaticStopLossPips = 50;             // Fixed SL in pips (when dynamic disabled)

input group "=== Signal Generation ==="
input int    FastMovingAveragePeriod = 10;        // Fast MA period
input int    SlowMovingAveragePeriod = 20;        // Slow MA period
input ENUM_MA_METHOD MovingAverageType = MODE_SMA;// MA calculation method

input group "=== Order Management ==="
input int    ExpertMagicIdentifier = 123456;      // Unique magic number
input string OrderCommentLabel = "RiskManager_v3"; // Trade comment

//--- Global state variables
CTrade tradeEngine;                               // Trade execution handler
double currentVolatility;                         // Current ATR reading
double optimizedLotSize;                          // Risk-calculated position size
double calculatedStopPrice;                       // Computed stop loss level
double prevFastMAValue;                           // Previous fast MA (for crossover)
double prevSlowMAValue;                           // Previous slow MA (for crossover)

//--- Indicator handles
int volatilityHandle;                             // ATR indicator handle
int fastMAHandle;                                 // Fast moving average handle
int slowMAHandle;                                 // Slow moving average handle

//--- Performance optimization flags
bool indicatorsReady = false;                     // Indicator initialization status
datetime lastBarTime = 0;                         // New bar detection

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Validate trading symbol
   if(!SymbolSelect(_Symbol, true))
   {
      Print("INIT ERROR: Symbol ", _Symbol, " unavailable");
      return INIT_FAILED;
   }
   
   // Validate risk parameters
   if(RiskPercentagePerTrade <= 0 || RiskPercentagePerTrade > 100)
   {
      Print("INIT ERROR: Risk percentage invalid (", RiskPercentagePerTrade, "%). Must be 0-100");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   if(VolatilityPeriod < 1)
   {
      Print("INIT ERROR: ATR period invalid (", VolatilityPeriod, "). Must be > 0");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   if(FastMovingAveragePeriod >= SlowMovingAveragePeriod)
   {
      Print("INIT ERROR: Fast MA period must be less than Slow MA period");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Configure trade engine
   tradeEngine.SetExpertMagicNumber(ExpertMagicIdentifier);
   tradeEngine.SetDeviationInPoints(10);
   tradeEngine.SetTypeFilling(ORDER_FILLING_FOK);
   tradeEngine.SetAsyncMode(false); // Synchronous execution for reliability
   
   // Initialize technical indicators
   volatilityHandle = iATR(_Symbol, PERIOD_CURRENT, VolatilityPeriod);
   fastMAHandle = iMA(_Symbol, PERIOD_CURRENT, FastMovingAveragePeriod, 0, MovingAverageType, PRICE_CLOSE);
   slowMAHandle = iMA(_Symbol, PERIOD_CURRENT, SlowMovingAveragePeriod, 0, MovingAverageType, PRICE_CLOSE);
   
   // Verify indicator creation
   if(volatilityHandle == INVALID_HANDLE || fastMAHandle == INVALID_HANDLE || slowMAHandle == INVALID_HANDLE)
   {
      Print("INIT ERROR: Indicator initialization failed");
      if(volatilityHandle == INVALID_HANDLE) Print("  - ATR handle invalid");
      if(fastMAHandle == INVALID_HANDLE) Print("  - Fast MA handle invalid");
      if(slowMAHandle == INVALID_HANDLE) Print("  - Slow MA handle invalid");
      return INIT_FAILED;
   }
   
   // Wait for indicators to calculate
   Sleep(100);
   
   // Initialize historical MA values
   prevFastMAValue = 0;
   prevSlowMAValue = 0;
   
   Print("╔════════════════════════════════════════════════════════╗");
   Print("║  RISK MANAGER EA v3.0 - INITIALIZED SUCCESSFULLY      ║");
   Print("╠════════════════════════════════════════════════════════╣");
   Print("║  Symbol: ", _Symbol);
   Print("║  Risk per Trade: ", RiskPercentagePerTrade, "%");
   Print("║  ATR Period: ", VolatilityPeriod);
   Print("║  Magic Number: ", ExpertMagicIdentifier);
   Print("║  Dynamic SL: ", (EnableDynamicStopLoss ? "ENABLED" : "DISABLED"));
   Print("╚════════════════════════════════════════════════════════╝");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release all indicator resources
   if(volatilityHandle != INVALID_HANDLE) IndicatorRelease(volatilityHandle);
   if(fastMAHandle != INVALID_HANDLE) IndicatorRelease(fastMAHandle);
   if(slowMAHandle != INVALID_HANDLE) IndicatorRelease(slowMAHandle);
   
   Print("╔════════════════════════════════════════════════════════╗");
   Print("║  RISK MANAGER EA - SHUTDOWN COMPLETE                  ║");
   Print("╠════════════════════════════════════════════════════════╣");
   Print("║  Reason: ", GetDeinitReasonText(reason));
   Print("╚════════════════════════════════════════════════════════╝");
}

//+------------------------------------------------------------------+
//| Expert tick function - optimized execution                       |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if new bar formed (optimization: trade only on new bars)
   if(!IsNewBar()) return;
   
   // Refresh technical indicator values
   if(!RefreshIndicatorData())
   {
      Print("TICK WARNING: Indicator data refresh failed, skipping tick");
      return;
   }
   
   // Analyze market conditions for entry signals
   if(DetectBullishSignal())
   {
      // Calculate risk-adjusted position sizing
      if(ComputePositionSize(ORDER_TYPE_BUY))
      {
         OpenLongPosition();
      }
   }
}

//+------------------------------------------------------------------+
//| Detect new bar formation for optimization                        |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   
   if(currentBarTime != lastBarTime)
   {
      lastBarTime = currentBarTime;
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Refresh all indicator data efficiently                           |
//+------------------------------------------------------------------+
bool RefreshIndicatorData()
{
   double atrArray[1];
   double fastMAArray[2];
   double slowMAArray[2];
   
   // Configure arrays as time series
   ArraySetAsSeries(atrArray, true);
   ArraySetAsSeries(fastMAArray, true);
   ArraySetAsSeries(slowMAArray, true);
   
   // Copy ATR value (only current)
   if(CopyBuffer(volatilityHandle, 0, 0, 1, atrArray) <= 0)
   {
      Print("DATA ERROR: ATR buffer copy failed");
      return false;
   }
   currentVolatility = atrArray[0];
   
   // Copy Fast MA values (current and previous)
   if(CopyBuffer(fastMAHandle, 0, 0, 2, fastMAArray) < 2)
   {
      Print("DATA ERROR: Fast MA buffer copy failed");
      return false;
   }
   
   // Copy Slow MA values (current and previous)
   if(CopyBuffer(slowMAHandle, 0, 0, 2, slowMAArray) < 2)
   {
      Print("DATA ERROR: Slow MA buffer copy failed");
      return false;
   }
   
   // Store previous values for crossover detection
   prevFastMAValue = fastMAArray[1];
   prevSlowMAValue = slowMAArray[1];
   
   // Mark indicators as ready
   if(!indicatorsReady) indicatorsReady = true;
   
   return true;
}

//+------------------------------------------------------------------+
//| Detect bullish crossover signal                                  |
//+------------------------------------------------------------------+
bool DetectBullishSignal()
{
   // Skip if indicators not ready
   if(!indicatorsReady) return false;
   
   // Check for existing position
   if(HasOpenPosition()) return false;
   
   // Get current MA values
   double currentFastMAArray[1];
   double currentSlowMAArray[1];
   
   ArraySetAsSeries(currentFastMAArray, true);
   ArraySetAsSeries(currentSlowMAArray, true);
   
   if(CopyBuffer(fastMAHandle, 0, 0, 1, currentFastMAArray) <= 0) return false;
   if(CopyBuffer(slowMAHandle, 0, 0, 1, currentSlowMAArray) <= 0) return false;
   
   double currentFastMA = currentFastMAArray[0];
   double currentSlowMA = currentSlowMAArray[0];
   
   // Detect bullish crossover: Fast MA crosses above Slow MA
   bool crossoverDetected = (prevFastMAValue <= prevSlowMAValue) && (currentFastMA > currentSlowMA);
   
   if(crossoverDetected)
   {
      Print("► BULLISH SIGNAL: Fast MA (", DoubleToString(currentFastMA, _Digits), 
            ") crossed above Slow MA (", DoubleToString(currentSlowMA, _Digits), ")");
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk parameters                 |
//+------------------------------------------------------------------+
bool ComputePositionSize(ENUM_ORDER_TYPE orderType)
{
   // Retrieve account metrics
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // Calculate monetary risk amount
   double monetaryRisk = accountBalance * (RiskPercentagePerTrade / 100.0);
   
   // Apply risk ceiling if configured
   if(MaximumRiskInMoney > 0 && monetaryRisk > MaximumRiskInMoney)
   {
      monetaryRisk = MaximumRiskInMoney;
      Print("RISK CONTROL: Risk capped at ", MaximumRiskInMoney, " ", AccountInfoString(ACCOUNT_CURRENCY));
   }
   
   // Get current market price
   double entryPrice = (orderType == ORDER_TYPE_BUY) ?
                       SymbolInfoDouble(_Symbol, SYMBOL_ASK) :
                       SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Calculate stop loss distance in price
   double stopDistancePrice;
   if(EnableDynamicStopLoss)
   {
      stopDistancePrice = currentVolatility * VolatilityMultiplier;
   }
   else
   {
      double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;
      stopDistancePrice = StaticStopLossPips * pipValue;
   }
   
   // Determine stop loss price level
   calculatedStopPrice = (orderType == ORDER_TYPE_BUY) ?
                         entryPrice - stopDistancePrice :
                         entryPrice + stopDistancePrice;
   calculatedStopPrice = NormalizeDouble(calculatedStopPrice, _Digits);
   
   // Calculate position size using risk formula
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   double stopDistancePoints = MathAbs(entryPrice - calculatedStopPrice) / pointValue;
   
   // Risk formula: Lot Size = Risk Amount / (Stop Distance in Points × Tick Value)
   optimizedLotSize = monetaryRisk / (stopDistancePoints * tickValue);
   
   // Normalize to broker lot specifications
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   optimizedLotSize = MathFloor(optimizedLotSize / lotStep) * lotStep;
   optimizedLotSize = MathMax(minLot, MathMin(maxLot, optimizedLotSize));
   optimizedLotSize = NormalizeDouble(optimizedLotSize, 2);
   
   // Validate final lot size
   if(optimizedLotSize < minLot)
   {
      Print("POSITION WARNING: Calculated lot (", optimizedLotSize, ") below minimum (", minLot, ")");
      Print("  → Increase risk % or reduce stop loss distance");
      return false;
   }
   
   // Log position parameters
   Print("╔════════════════════════════════════════════════════════╗");
   Print("║  POSITION SIZING CALCULATION                          ║");
   Print("╠════════════════════════════════════════════════════════╣");
   Print("║  Risk Amount: ", DoubleToString(monetaryRisk, 2), " ", AccountInfoString(ACCOUNT_CURRENCY));
   Print("║  Lot Size: ", DoubleToString(optimizedLotSize, 2));
   Print("║  Stop Loss: ", DoubleToString(calculatedStopPrice, _Digits));
   Print("║  SL Distance: ", DoubleToString(stopDistancePoints, 1), " points");
   Print("║  SL Distance: ", DoubleToString(stopDistancePrice / (SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10), 1), " pips");
   Print("╚════════════════════════════════════════════════════════╝");
   
   return true;
}

//+------------------------------------------------------------------+
//| Execute long position with calculated parameters                 |
//+------------------------------------------------------------------+
void OpenLongPosition()
{
   double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   // Verify stop loss validity
   double minStopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double actualStopDistance = askPrice - calculatedStopPrice;
   
   if(actualStopDistance < minStopLevel)
   {
      Print("ORDER ERROR: Stop loss too close to market (", actualStopDistance / _Point, " points, min: ", minStopLevel / _Point, ")");
      return;
   }
   
   // Execute buy order
   if(tradeEngine.Buy(optimizedLotSize, _Symbol, askPrice, calculatedStopPrice, 0, OrderCommentLabel))
   {
      Print("╔════════════════════════════════════════════════════════╗");
      Print("║  ✓ LONG POSITION OPENED SUCCESSFULLY                  ║");
      Print("╠════════════════════════════════════════════════════════╣");
      Print("║  Ticket: #", tradeEngine.ResultOrder());
      Print("║  Volume: ", optimizedLotSize, " lots");
      Print("║  Entry: ", DoubleToString(askPrice, _Digits));
      Print("║  Stop Loss: ", DoubleToString(calculatedStopPrice, _Digits));
      Print("║  Risk: ", DoubleToString(optimizedLotSize * (askPrice - calculatedStopPrice) / _Point * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE), 2));
      Print("╚════════════════════════════════════════════════════════╝");
   }
   else
   {
      Print("╔════════════════════════════════════════════════════════╗");
      Print("║  ✗ ORDER EXECUTION FAILED                             ║");
      Print("╠════════════════════════════════════════════════════════╣");
      Print("║  Error Code: ", GetLastError());
      Print("║  Description: ", tradeEngine.ResultRetcodeDescription());
      Print("║  Return Code: ", tradeEngine.ResultRetcode());
      Print("╚════════════════════════════════════════════════════════╝");
   }
}

//+------------------------------------------------------------------+
//| Check if position exists for this EA                             |
//+------------------------------------------------------------------+
bool HasOpenPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong positionTicket = PositionGetTicket(i);
      if(positionTicket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
            PositionGetInteger(POSITION_MAGIC) == ExpertMagicIdentifier)
         {
            return true;
         }
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Get deinitialization reason text                                 |
//+------------------------------------------------------------------+
string GetDeinitReasonText(int reason)
{
   switch(reason)
   {
      case REASON_PROGRAM: return "Expert removed from chart";
      case REASON_REMOVE: return "Program deleted from chart";
      case REASON_RECOMPILE: return "Program recompiled";
      case REASON_CHARTCHANGE: return "Symbol or timeframe changed";
      case REASON_CHARTCLOSE: return "Chart closed";
      case REASON_PARAMETERS: return "Input parameters changed";
      case REASON_ACCOUNT: return "Account changed";
      case REASON_TEMPLATE: return "Template applied";
      case REASON_INITFAILED: return "Initialization failed";
      case REASON_CLOSE: return "Terminal closed";
      default: return "Unknown reason";
   }
}
//+------------------------------------------------------------------+