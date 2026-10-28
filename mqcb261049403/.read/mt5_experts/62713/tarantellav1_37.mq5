//+------------------------------------------------------------------+
//| Disclaimer:                                                      |
//| This EA is provided "as is" without warranty of any kind.        |
//| Lupus Materia Ltd. shall not be liable for any losses incurred.  |
//| Use at your own risk. Trading involves substantial risk of loss. |
//| Test thoroughly in a demo account before live deployment.        |
//+------------------------------------------------------------------+
//| Description:                                                     |
//| Tarantella is a sophisticated grid trading EA with:              |
//| 1. ADX trend filtering + MA/MACD trend confirmation              |
//| 2. Market Profile integration (Value Area/POC avoidance)         |
//| 3. Fibonacci-based grid spacing and lot scaling                  |
//| 4. Advanced hedging capabilities with partial close options      |
//| 5. Multi-layered entry filters (ATR, RSI, volume, consecutive bars)|
//|                                                                  |
//| Core Strategy:                                                   |
//| - Places expanding grid of buy/sell orders                       |
//| - Activates hedge positions when price moves against main trades |
//| - Uses multiple timeframe trend confirmation                     |
//| - Restricts trading to Market Profile Value Areas                |
//| - Implements comprehensive risk management features             |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                      Tarantella.mq5                              |
//|           Grid Trading EA with Hedging and ADX Trend Filter      |
//|           Now with Market Profile Integration                    |
//|                      Copyright 2025, Lupus Materia Ltd.          |
//|                         Version 1.37                             |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2025, lupusmat@gmx.com"
#property link      "https://lupusmateria.com"
#property version   "1.37"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>

// Enumeration for trend detection method selection
enum ENUM_TREND_METHOD
  {
   TREND_MA,     // Use Moving Average for trend detection
   TREND_MACD    // Use MACD for trend detection
  };

//--- Input Parameters ---
input group "Debug Settings"
input bool         EnableDebugLogging = false;   // Enable detailed logging (disabling reduces log size)

input group "General"
input int          MagicNumber1         = 777777;    // Main trades magic number (unique ID)
input int          MagicNumber2         = 888888;    // Hedge trades magic number (unique ID)
input int          Slippage             = 15;        // Maximum slippage (points)
input int          ModifyThrottleSeconds= 2;         // Order modify cooldown (seconds)

input group "Trend Filters"
input bool         UseADX_Filter        = true;      // Enable ADX trend strength filter
input int          ADX_Period          = 14;        // ADX period (14-21 recommended)
input double       ADX_Threshold        = 25.0;      // Minimum trend strength (25+ = strong)
input ENUM_TIMEFRAMES TrendTimeframe   = PERIOD_D1; // Trend confirmation timeframe
input bool         UseADX_FilterForHedge= true;     // Enable ADX trend filter for hedge trades
input bool         UseTrendFilterForHedge= true;    // Enable trend filter for hedge trades
input bool         UseTrendFilterForMain= true;     // Enable trend filter for main trades
input ENUM_TREND_METHOD TrendMethod    = TREND_MA; // Trend method: MA or MACD
input int          MAPeriod             = 50;        // MA period (bars)
input ENUM_MA_METHOD MAMethod          = MODE_EMA;  // MA calculation method
input int          MACD_FastEMA         = 12;        // MACD Fast EMA
input int          MACD_SlowEMA         = 26;        // MACD Slow EMA
input int          MACD_SMA             = 9;         // MACD SMA
input ENUM_APPLIED_PRICE MACD_AppliedPrice = PRICE_CLOSE; // MACD Applied Price

input group "Market Profile"
input bool         UseMarketProfile     = true;      // Enable Market Profile filtering
input int          MPPeriod             = 1440;      // Profile period (minutes)
input double       MPValueAreaPercent   = 70.0;      // Value Area percentage (70% typical)
input bool         OnlyTradeInVA        = true;      // Restrict trades to Value Area
input bool         AvoidPOC             = true;      // Avoid Point of Control (POC)
input int          POCAvoidPips         = 20;        // POC avoidance distance (pips)

input group "Entry Conditions"
input int          ConsecutiveBars      = 3;         // Required same-direction bars (2-3)
input long         MinVolume            = 100;       // Minimum tick volume threshold
input bool         UseATR_Filter        = false;      // Enable ATR filter for candle body
input int          ATR_Period           = 14;        // ATR period
input double       ATR_Multiplier       = 0.5;       // Minimum candle body as multiple of ATR
input bool         UseRSI_Filter        = false;      // Enable RSI filter
input int          RSI_Period           = 14;        // RSI period
input double       RSI_Overbought       = 70.0;      // RSI overbought level
input double       RSI_Oversold         = 30.0;      // RSI oversold level

input group "Risk Management"
input double       StartLots            = 0.01;      // Initial trade size (lots)
input double       MaximalLots          = 0.1;       // Maximum trade size (lots)
input double       MaxHedgeLot          = 0.1;       // Maximum lot size for hedge trades
input double       Multiplier           = 1.0;       // Position size multiplier
input bool         FibAdjustLots        = true;     // Enable Fibonacci lot scaling
input double       MinAccountBalance    = 1.0;     // Minimum account balance to trade (USD)

input group "Grid Settings"
input int          PointOrderStep       = 50;       // Distance between orders (pips)
input bool         UseFibGrid           = true;      // Fibonacci-based grid spacing
input double       MaxFibRatio          = 10.0;      // Maximum grid expansion ratio

input group "Stop Management"
input int          DefaultStopPoints    = 10;        // Default stop distance (points)
input int          MinStopBuffer        = 10;        // Additional stop buffer (points)
input bool         UseTrailingSL        = true;     // Enable trailing stops
input int          TrailingStop         = 50;        // Trailing stop distance (pips)
input int          EnableStopLoss       = 0;         // Enable Stop-Loss management
input int          MinimalProfit        = 1;         // Breakeven trigger pips
input int          CloseNo              = 1;         // Positions for breakeven

input group "Take Profit"
input int          TakeProfit           = 50;        // Profit target (pips)
input bool         UseTrailingTP        = false;     // Enable trailing take-profit
input int          EnableTakeProfit     = 0;        // Enable Take-Profit management

input group "Hedging"
input int          EnableHedging        = 1;         // Enable hedging strategy
input double       HedgeRatio           = 1.0;       // Hedge volume multiplier
input int          HedgeStep            = 50;        // Hedge activation distance (pips)
input ulong        Duration             = 2;         // Seconds between hedge checks
input int          MaxHedgeTrades       = 5;         // Maximum simultaneous hedges

input group "Trade Limits"
input int          MaxBuyTrades         = 5;         // Maximum long positions
input int          MaxSellTrades        = 5;         // Maximum short positions
input int          MaxTotalTrades       = 20;        // Global position limit
input bool         CloseOldest          = true;     // Close oldest trade at limit

input group "Closing Rules"
input int          CloseType            = 1;         // 1=All, 2=Main, 3=Hedge
input double       InpProfit            = 10.0;      // Close all at profit ($)
input bool         EnablePartialClose   = false;     // Enable partial position closing
input double       ProfitThreshold      = 80.0;      // Profit Threshold in Account Currency
input bool         HedgePartialClose    = false;     // Partial close enabled
input double       HedgePartialPercent  = 50.0;      // Percentage to close (0-100)
input double       HedgeProfitClose     = 5.0;       // $ profit to close hedge
input int          CloseOldestProfitMode= 2;         // Close oldest profit mode (0=Negative, 1=Positive, 2=Breakeven)
input double       CloseOldestBreakevenRange = 0.5;  // Breakeven range for closing oldest ($)

//--- Global Variables ---
CTrade            trade;                        // Main trading object
CTrade            m_trade;                      // Secondary trading object for hedging
CPositionInfo     m_position;                   // Position information object

// Price and Position Tracking
double            AverageBuyPrice = 0;          // Average price of buy positions
double            AverageSelPrice = 0;          // Average price of sell positions
double            bidpricesnap = 0;             // Snapshot of bid price
double            askpricesnap = 0;             // Snapshot of ask price
int               buyCount = 0;                 // Count of buy positions
int               sellCount = 0;                // Count of sell positions
int               hedgeBuyCount = 0;           // Count of hedge buy positions
int               hedgeSellCount = 0;          // Count of hedge sell positions

// Timing and Throttling
ulong             stime = 0;                    // Timestamp for system operations
datetime          lastModifyTimeP = 0;          // Last position modification time

// Fibonacci Grid Settings
double            fibRatios[] = {1.0, 1.618, 2.618, 4.236, 6.854, 11.09, 17.944, 29.034, 46.978, 76.012}; // Fibonacci ratios for grid

// Market Profile Variables
struct SPriceLevel
  {
   double            price;                      // Price level
   int               volume;                     // Volume at price level
   // Default constructor
                     SPriceLevel() : price(0), volume(0) {}
   // Copy constructor
                     SPriceLevel(const SPriceLevel &other) : price(other.price), volume(other.volume) {}
  };
SPriceLevel       m_priceLevels[];             // Array of price levels for Market Profile
datetime          m_lastProfileUpdate = 0;      // Last Market Profile update time
double            m_pocPrice = 0;              // Point of Control price
double            m_vaHigh = 0;                // Value Area high
double            m_vaLow = 0;                 // Value Area low

//+------------------------------------------------------------------+
//| Debug print wrapper                                              |
//+------------------------------------------------------------------+
void DebugPrint(string message)
{
    if(EnableDebugLogging) 
        Print(message);
}

//+------------------------------------------------------------------+
//| Margin availability check                                        |
//+------------------------------------------------------------------+
bool CheckMarginAvailable(ENUM_ORDER_TYPE type, double volume, double price)
{
    double margin_required;
    if(!OrderCalcMargin(type, Symbol(), volume, price, margin_required))
    {
        DebugPrint("OrderCalcMargin failed. Error: " + IntegerToString(GetLastError()));
        return false;
    }
    
    double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    if(free_margin >= margin_required)
        return true;
    
    DebugPrint(StringFormat("Insufficient margin: Required=%.2f Free=%.2f", margin_required, free_margin));
    return false;
}

//+------------------------------------------------------------------+
//| Robust volume normalization                                      |
//+------------------------------------------------------------------+
double NormalizeLotSize(double volume)
{
   if(volume <= 0) return 0.0;
   
   double step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   
   if(step <= 0) return volume; // Safety check
   
   // Calculate required precision
   int decimals = 0;
   if(step < 1.0) 
   {
      double temp = step;
      while(temp < 1.0)
      {
         decimals++;
         temp *= 10;
      }
   }
   
   // Normalize to step precision
   double normalized = NormalizeDouble(volume, decimals);
   normalized = MathRound(normalized / step) * step;
   
   // Clamp to broker limits
   normalized = MathMax(minLot, MathMin(maxLot, normalized));
   
   return normalized;
}

//+------------------------------------------------------------------+
//| Trade execution with margin and volume validation                |
//+------------------------------------------------------------------+
void ExecuteTrade(CTrade &tradeObj, ENUM_ORDER_TYPE type, double volume, double price, 
                 double sl, double tp, string comment)
{
   // Validate volume before execution
   double validVolume = NormalizeLotSize(volume);
   double minLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   
   if(validVolume < minLot || validVolume > maxLot)
   {
      DebugPrint("Invalid volume detected: " + DoubleToString(volume, 2) + 
                " Normalized: " + DoubleToString(validVolume, 2) +
                " Min: " + DoubleToString(minLot, 2) +
                " Max: " + DoubleToString(maxLot, 2));
      return;
   }

   // Check account balance before trading
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(accountBalance < MinAccountBalance)
   {
      DebugPrint("Account balance too low: " + DoubleToString(accountBalance) + 
                " < " + DoubleToString(MinAccountBalance));
      return;
   }

   // Check margin availability
   if(!CheckMarginAvailable(type, validVolume, price))
   {
      DebugPrint("Aborted trade: " + comment + " | Volume: " + DoubleToString(validVolume, 2));
      return;
   }

   if(type == ORDER_TYPE_BUY)
   {
      if(tradeObj.Buy(validVolume, Symbol(), price, sl, tp, comment))
         DebugPrint("Buy order executed: " + DoubleToString(validVolume, 2) + 
                   " at " + DoubleToString(price, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS)));
      else
         DebugPrint("Buy failed: " + tradeObj.ResultRetcodeDescription() +
                   " Volume: " + DoubleToString(validVolume, 2) +
                   " Price: " + DoubleToString(price, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS)));
   }
   else
   {
      if(tradeObj.Sell(validVolume, Symbol(), price, sl, tp, comment))
         DebugPrint("Sell order executed: " + DoubleToString(validVolume, 2) + 
                   " at " + DoubleToString(price, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS)));
      else
         DebugPrint("Sell failed: " + tradeObj.ResultRetcodeDescription() +
                   " Volume: " + DoubleToString(validVolume, 2) +
                   " Price: " + DoubleToString(price, (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS)));
   }
}

//+------------------------------------------------------------------+
//| Convert pips to points based on symbol digits                    |
//+------------------------------------------------------------------+
double PipValue()
  {
   if(_Digits == 3 || _Digits == 5)
      return(_Point * 10);
   else
      return(_Point);
  }

//+------------------------------------------------------------------+
//| Convert pips to price value                                      |
//+------------------------------------------------------------------+
double PipToPrice(double pips)
  {
   return pips * PipValue();
  }

//+------------------------------------------------------------------+
//| Expert Initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   Comment("Tarantella EA Active");

   // Log initial information for debugging
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   Print("OnInit: Symbol=", Symbol(), ", Timeframe=", EnumToString(Period()), 
         ", Balance=", accountBalance, ", MinAccountBalance=", MinAccountBalance);

   // Bypass balance check for M1 timeframe
   if(Period() != PERIOD_M1)
   {
      if(accountBalance <= 0)
      {
         Alert("Invalid account balance: ", accountBalance, " (must be positive)");
         return(INIT_FAILED);
      }
      if(accountBalance < MinAccountBalance)
      {
         Alert("Account balance too low: ", accountBalance, " < ", MinAccountBalance);
         return(INIT_FAILED);
      }
   }
   else
   {
      Print("OnInit: Balance check bypassed for M1 timeframe");
   }
   Print("OnInit: Balance check passed or bypassed. Initializing trade objects...");

   // Initialize main trading object
   trade.LogLevel(LOG_LEVEL_ERRORS);
   trade.SetExpertMagicNumber(MagicNumber1);
   trade.SetDeviationInPoints(Slippage);
   trade.SetTypeFillingBySymbol(Symbol());

   // Initialize hedging trading object
   m_trade.LogLevel(LOG_LEVEL_ERRORS);
   m_trade.SetExpertMagicNumber(MagicNumber2);
   m_trade.SetDeviationInPoints(Slippage);
   m_trade.SetTypeFillingBySymbol(Symbol());

   // Calculate minimum stop distance with buffer
   double minDist = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   if(minDist == 0)
      minDist = 10 * _Point;

   minDist += PipToPrice(MinStopBuffer);

   DebugPrint("Symbol: " + Symbol() + " Calculated Min Stop Distance: " + 
             DoubleToString(minDist / _Point, 2) + " points (broker level + buffer)");

   // Market Profile check and initialization
   if(UseMarketProfile)
   {
      if(!FileIsExist("Indicators\\MarketProfile.ex5"))
      {
         Alert("MarketProfile.ex5 indicator not found - switching to built-in calculations");
         DebugPrint("Using built-in Market Profile calculations instead of external indicator");
      }
      else
      {
         DebugPrint("Market Profile indicator found and will be used");
      }

      // Initialize Market Profile variables
      DebugPrint("Market Profile Configuration:");
      DebugPrint("Period: " + IntegerToString(MPPeriod) + " minutes");
      DebugPrint("Value Area Percentage: " + DoubleToString(MPValueAreaPercent, 1) + "%");
      DebugPrint("POC Avoidance: " + (AvoidPOC ? "Enabled" : "Disabled"));
      DebugPrint("POC Avoidance Pips: " + IntegerToString(POCAvoidPips));
      DebugPrint("Only Trade in Value Area: " + (OnlyTradeInVA ? "Enabled" : "Disabled"));

      ArrayFree(m_priceLevels);
      m_pocPrice = 0;
      m_vaHigh = 0;
      m_vaLow = 0;
      m_lastProfileUpdate = 0;
   }

   // Validate input parameters
   if(ProfitThreshold <= 0)
   {
      Print("Error: ProfitThreshold must be greater than 0");
      return(INIT_PARAMETERS_INCORRECT);
   }

   if(ConsecutiveBars < 1)
   {
      Print("Error: iConsecutiveBars must be at least 1");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(MinVolume < 0)
   {
      Print("Error: iMinVolume must be non-negative");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(MaxHedgeLot < 0)
   {
      Print("Error: iMaxHedgeLot must be non-negative");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(CloseOldestBreakevenRange < 0)
   {
      Print("Error: CloseOldestBreakevenRange must be non-negative");
      return(INIT_PARAMETERS_INCORRECT);
   }
   if(CloseOldestProfitMode < 0 || CloseOldestProfitMode > 2)
   {
      Print("Error: CloseOldestProfitMode must be 0 (Negative), 1 (Positive), or 2 (Breakeven)");
      return(INIT_PARAMETERS_INCORRECT);
   }

   // Reset tracking variables
   buyCount = 0;
   sellCount = 0;
   hedgeBuyCount = 0;
   hedgeSellCount = 0;
   AverageBuyPrice = 0;
   AverageSelPrice = 0;
   stime = 0;
   bidpricesnap = 0;
   askpricesnap = 0;
   lastModifyTimeP = 0;

   // Log broker volume settings
   DebugPrint("Broker Volume Settings for " + Symbol() + ": " +
             "Min=" + DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN), 2) + 
             " Max=" + DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX), 2) +
             " Step=" + DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP), 6));
   
   DebugPrint("Tarantella EA initialized successfully");
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Enhanced Stop Level Validation (Generalized for all symbols)     |
//+------------------------------------------------------------------+
bool IsValidStopLevel(double price, double sl, double tp, bool isBuy)
  {
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double minDist = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   if(minDist == 0)
      minDist = DefaultStopPoints * tickSize;
   minDist += MinStopBuffer * _Point;

   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);

   if(isBuy)
     {
      if(tp > 0 && tp - ask < minDist)
        {
         DebugPrint("Invalid TP for Buy: TP=" + DoubleToString(tp) + " Ask=" + DoubleToString(ask) + 
                   " Required min distance=" + DoubleToString(minDist / _Point) + " points");
         return false;
        }
      if(sl > 0 && bid - sl < minDist)
        {
         DebugPrint("Invalid SL for Buy: SL=" + DoubleToString(sl) + " Bid=" + DoubleToString(bid) + 
                   " Required min distance=" + DoubleToString(minDist / _Point) + " points");
         return false;
        }
     }
   else
     {
      if(tp > 0 && bid - tp < minDist)
        {
         DebugPrint("Invalid TP for Sell: TP=" + DoubleToString(tp) + " Bid=" + DoubleToString(bid) + 
                   " Required min distance=" + DoubleToString(minDist / _Point) + " points");
         return false;
        }
      if(sl > 0 && sl - ask < minDist)
        {
         DebugPrint("Invalid SL for Sell: SL=" + DoubleToString(sl) + " Ask=" + DoubleToString(ask) + 
                   " Required min distance=" + DoubleToString(minDist / _Point) + " points");
         return false;
        }
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Safe Position Modification                                       |
//+------------------------------------------------------------------+
void SafePositionModify(ulong ticket, double sl, double tp)
  {
   if(TimeCurrent() - lastModifyTimeP < ModifyThrottleSeconds)
     {
      DebugPrint("Modification throttled - too frequent");
      return;
     }

   if(m_position.SelectByTicket(ticket))
     {
      double currentPrice = m_position.PriceCurrent();
      bool isBuy = (m_position.PositionType() == POSITION_TYPE_BUY);
      int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
      sl = NormalizeDouble(sl, digits);
      tp = NormalizeDouble(tp, digits);

      ResetLastError();
      if(IsValidStopLevel(currentPrice, sl, tp, isBuy))
        {
         if(trade.PositionModify(ticket, sl, tp))
           {
            lastModifyTimeP = TimeCurrent();
            DebugPrint("Successfully modified position " + (string)ticket + " SL=" + DoubleToString(sl) + " TP=" + DoubleToString(tp));
           }
         else
           {
            DebugPrint("Failed to modify position " + (string)ticket + " Error: " + (string)GetLastError() +
                  " Symbol: " + Symbol() + " Current Price: " + DoubleToString(currentPrice) +
                  " Attempted SL: " + DoubleToString(sl) + " Attempted TP: " + DoubleToString(tp));
           }
        }
      else
        {
         double minDist = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL) * _Point;
         if(minDist == 0)
            minDist = 10 * _Point;

         minDist += PipToPrice(MinStopBuffer);

         DebugPrint("Invalid stop levels for position " + (string)ticket +
               " Current: " + DoubleToString(currentPrice) + " Attempted SL: " + DoubleToString(sl) + " Attempted TP: " + DoubleToString(tp) +
               " Minimum required distance: " + DoubleToString(minDist / _Point) + " points");
        }
     }
  }

//+------------------------------------------------------------------+
//| Trailing Take-Profit Logic                                       |
//+------------------------------------------------------------------+
void UpdateTrailingTP()
  {
   if(!UseTrailingTP || !EnableTakeProfit)
      return;

   MqlTick tick;
   if(!SymbolInfoTick(Symbol(), tick))
      return;

   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      if(m_position.SelectByIndex(k) && m_position.Symbol() == Symbol() && m_position.Magic() == MagicNumber1)
        {
         ulong ticket = m_position.Ticket();
         double currentTP = m_position.TakeProfit();
         double currentSL = m_position.StopLoss();
         bool isBuy = (m_position.PositionType() == POSITION_TYPE_BUY);
         double newTP = 0;

         double trailingDistance = PipToPrice(TakeProfit);

         if(isBuy)
           {
            newTP = tick.bid + trailingDistance;
            newTP = NormalizeDouble(newTP, digits);

            if(currentTP == 0 || newTP > currentTP)
              {
               if(IsValidStopLevel(m_position.PriceCurrent(), currentSL, newTP, isBuy))
                 {
                  SafePositionModify(ticket, currentSL, newTP);
                  DebugPrint("Trailing TP updated for Buy position " + (string)ticket + " New TP: " + DoubleToString(newTP) +
                        " Bid: " + DoubleToString(tick.bid) + " Ask: " + DoubleToString(tick.ask));
                 }
              }
           }
         else
           {
            newTP = tick.ask - trailingDistance;
            newTP = NormalizeDouble(newTP, digits);

            if(currentTP == 0 || newTP < currentTP)
              {
               if(IsValidStopLevel(m_position.PriceCurrent(), currentSL, newTP, isBuy))
                 {
                  SafePositionModify(ticket, currentSL, newTP);
                  DebugPrint("Trailing TP updated for Sell position " + (string)ticket + " New TP: " + DoubleToString(newTP) +
                        " Bid: " + DoubleToString(tick.bid) + " Ask: " + DoubleToString(tick.ask));
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|   Update Trailing SL                                             |
//+------------------------------------------------------------------+
void UpdateTrailingSL()
  {
   if(!UseTrailingSL || !EnableStopLoss)
      return;

   MqlTick tick;
   if(!SymbolInfoTick(Symbol(), tick))
      return;

   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      if(m_position.SelectByIndex(k) && m_position.Symbol() == Symbol() && m_position.Magic() == MagicNumber1)
        {
         ulong ticket = m_position.Ticket();
         double currentSL = m_position.StopLoss();
         double currentTP = m_position.TakeProfit();
         bool isBuy = (m_position.PositionType() == POSITION_TYPE_BUY);
         double newSL = 0;

         double trailingDistance = PipToPrice(TrailingStop);

         if(isBuy)
           {
            newSL = tick.bid - trailingDistance;
            newSL = NormalizeDouble(newSL, digits);

            if(currentSL == 0 || newSL > currentSL)
              {
               if(IsValidStopLevel(m_position.PriceCurrent(), newSL, currentTP, isBuy))
                 {
                  SafePositionModify(ticket, newSL, currentTP);
                  DebugPrint("Trailing SL updated for Buy position " + (string)ticket + " New SL: " + DoubleToString(newSL) +
                        " Bid: " + DoubleToString(tick.bid) + " Ask: " + DoubleToString(tick.ask));
                 }
              }
           }
         else
           {
            newSL = tick.ask + trailingDistance;
            newSL = NormalizeDouble(newSL, digits);

            if(currentSL == 0 || newSL < currentSL)
              {
               if(IsValidStopLevel(m_position.PriceCurrent(), newSL, currentTP, isBuy))
                 {
                  SafePositionModify(ticket, newSL, currentTP);
                  DebugPrint("Trailing SL updated for Sell position " + (string)ticket + " New SL: " + DoubleToString(newSL) +
                        " Bid: " + DoubleToString(tick.bid) + " Ask: " + DoubleToString(tick.ask));
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|  Update Market Profile                                           |
//+------------------------------------------------------------------+
void UpdateMarketProfile()
  {
   if(!UseMarketProfile || TimeCurrent() - m_lastProfileUpdate < 300)
      return;

   ArrayFree(m_priceLevels);
   m_pocPrice = 0;
   m_vaHigh = 0;
   m_vaLow = 0;

   MqlRates rates[];
   int secondsPerBar = (int)PeriodSeconds(PERIOD_CURRENT);
   int barsToFetch = (MPPeriod * 60) / secondsPerBar;
   barsToFetch = MathMin(barsToFetch, 1000);

   int copiedBars = CopyRates(Symbol(), PERIOD_CURRENT, 0, barsToFetch, rates);
   if(copiedBars < barsToFetch)
     {
      DebugPrint("Failed to copy enough bars for Market Profile. Requested: " + 
                IntegerToString(barsToFetch) + ", got: " + IntegerToString(copiedBars) +
                " Error: " + IntegerToString(GetLastError()));
      return;
     }

   ArrayResize(m_priceLevels, barsToFetch / 10);
   int levelCount = 0;

   double priceThreshold = _Point * 5;
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);

   for(int i = 0; i < copiedBars; i++)
     {
      double price = NormalizeDouble(rates[i].close, digits);
      bool found = false;

      for(int j = 0; j < levelCount; j++)
        {
         if(MathAbs(m_priceLevels[j].price - price) < priceThreshold)
           {
            m_priceLevels[j].volume++;
            found = true;
            break;
           }
        }

      if(!found)
        {
         if(levelCount >= ArraySize(m_priceLevels))
           {
            ArrayResize(m_priceLevels, levelCount + 100);
           }
         m_priceLevels[levelCount].price = price;
         m_priceLevels[levelCount].volume = 1;
         levelCount++;
        }
     }

   ArrayResize(m_priceLevels, levelCount);

   int maxVolume = 0;
   for(int i = 0; i < levelCount; i++)
     {
      if(m_priceLevels[i].volume > maxVolume)
        {
         maxVolume = m_priceLevels[i].volume;
         m_pocPrice = m_priceLevels[i].price;
        }
     }

   CalculateValueArea();

   m_lastProfileUpdate = TimeCurrent();

   if(EnableDebugLogging)
      PrintFormat("Market Profile updated: POC=%.5f VA High=%.5f VA Low=%.5f", m_pocPrice, m_vaHigh, m_vaLow);
  }

//+------------------------------------------------------------------+
//|  Calculate Value Area                                            |
//+------------------------------------------------------------------+
void CalculateValueArea()
  {
   int totalVol = 0;
   int size = ArraySize(m_priceLevels);
   for(int i=0; i<size; i++)
      totalVol += m_priceLevels[i].volume;

   int targetVol = (int)(totalVol * MPValueAreaPercent / 100.0);

   for(int i=0; i<size-1; i++)
     {
      for(int j=i+1; j<size; j++)
        {
         if(m_priceLevels[i].price > m_priceLevels[j].price)
           {
            SPriceLevel tmp = m_priceLevels[i];
            m_priceLevels[i] = m_priceLevels[j];
            m_priceLevels[j] = tmp;
           }
        }
     }

   int pocIdx = -1;
   for(int i=0; i<size; i++)
     {
      if(m_priceLevels[i].price == m_pocPrice)
        {
         pocIdx = i;
         break;
        }
     }

   if(pocIdx < 0)
     {
      m_vaHigh = m_vaLow = m_pocPrice;
      return;
     }

   m_vaHigh = m_vaLow = m_pocPrice;
   int currentVol = m_priceLevels[pocIdx].volume;
   int left = pocIdx - 1;
   int right = pocIdx + 1;

   while(currentVol < targetVol && (left >= 0 || right < size))
     {
      bool expandLeft = false;
      if(left < 0)
         expandLeft = false;
      else
         if(right >= size)
            expandLeft = true;
         else
            expandLeft = (m_pocPrice - m_priceLevels[left].price) <= (m_priceLevels[right].price - m_pocPrice);

      if(expandLeft && left >= 0)
        {
         currentVol += m_priceLevels[left].volume;
         m_vaLow = m_priceLevels[left--].price;
        }
      else
         if(right < size)
           {
            currentVol += m_priceLevels[right].volume;
            m_vaHigh = m_priceLevels[right++].price;
           }
     }
  }

//+------------------------------------------------------------------+
//|  Is In Value Area                                                |
//+------------------------------------------------------------------+
bool IsInValueArea()
  {
   if(!UseMarketProfile || !OnlyTradeInVA)
      return true;

   MqlTick tick;
   if(!SymbolInfoTick(Symbol(), tick))
      return true;

   return (tick.bid >= m_vaLow && tick.bid <= m_vaHigh);
  }

//+------------------------------------------------------------------+
//| Is Near POC                                                      |
//+------------------------------------------------------------------+
bool IsNearPOC()
  {
   if(!UseMarketProfile || !AvoidPOC)
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(Symbol(), tick))
      return false;

   return (MathAbs(tick.bid - m_pocPrice) <= POCAvoidPips * _Point);
  }

//+------------------------------------------------------------------+
//| ADX Trend Filter                                                 |
//+------------------------------------------------------------------+
bool IsStrongTrend(int direction)
  {
   if(!UseADX_Filter)
      return(true);

   if(direction != 0 && direction != 1)
      return(false);

   double adx[], pdi[], ndi[];
   int handle = iADX(Symbol(), PERIOD_CURRENT, ADX_Period);
   if(handle == INVALID_HANDLE)
      return(false);

   bool copied =
      CopyBuffer(handle, 0, 0, 3, adx) > 0 &&
      CopyBuffer(handle, 1, 0, 3, pdi) > 0 &&
      CopyBuffer(handle, 2, 0, 3, ndi) > 0;

   IndicatorRelease(handle);

   if(!copied)
      return(false);

   if(direction == 0)
      return(adx[0] > ADX_Threshold && pdi[0] > ndi[0]);
   else
      return(adx[0] > ADX_Threshold && ndi[0] > pdi[0]);
  }

//+------------------------------------------------------------------+
//| Trend Filter for Uptrend                                         |
//+------------------------------------------------------------------+
bool IsUptrend()
  {
   if(TrendMethod == TREND_MA)
     {
      double ma[], close[];
      int handle = iMA(Symbol(), TrendTimeframe, MAPeriod, 0, MAMethod, PRICE_CLOSE);
      if(handle == INVALID_HANDLE)
         return(false);

      bool maCopied = CopyBuffer(handle, 0, 0, 1, ma) > 0;
      IndicatorRelease(handle);

      if(!maCopied)
         return(false);

      if(CopyClose(Symbol(), TrendTimeframe, 0, 1, close) <= 0)
         return(false);

      if(ArraySize(ma) == 0 || ArraySize(close) == 0)
         return(false);

      return(close[0] > ma[0]);
     }
   else // TREND_MACD
     {
      double macd[], signal[];
      int handle = iMACD(Symbol(), TrendTimeframe, MACD_FastEMA, MACD_SlowEMA, MACD_SMA, MACD_AppliedPrice);
      if(handle == INVALID_HANDLE)
         return(false);

      bool copied = CopyBuffer(handle, 0, 0, 1, macd) > 0 &&
                    CopyBuffer(handle, 1, 0, 1, signal) > 0;
      IndicatorRelease(handle);

      if(!copied)
         return(false);

      return(macd[0] > signal[0]);
     }
  }

//+------------------------------------------------------------------+
//|  Trend Filter for Downtrend                                      |
//+------------------------------------------------------------------+
bool IsDowntrend()
  {
   if(TrendMethod == TREND_MA)
     {
      double ma[], close[];
      int handle = iMA(Symbol(), TrendTimeframe, MAPeriod, 0, MAMethod, PRICE_CLOSE);
      if(handle == INVALID_HANDLE)
         return(false);

      bool maCopied = CopyBuffer(handle, 0, 0, 1, ma) > 0;
      IndicatorRelease(handle);

      if(!maCopied)
         return(false);

      if(CopyClose(Symbol(), TrendTimeframe, 0, 1, close) <= 0)
         return(false);

      if(ArraySize(ma) == 0 || ArraySize(close) == 0)
         return(false);

      return(close[0] < ma[0]);
     }
   else // TREND_MACD
     {
      double macd[], signal[];
      int handle = iMACD(Symbol(), TrendTimeframe, MACD_FastEMA, MACD_SlowEMA, MACD_SMA, MACD_AppliedPrice);
      if(handle == INVALID_HANDLE)
         return(false);

      bool copied = CopyBuffer(handle, 0, 0, 1, macd) > 0 &&
                    CopyBuffer(handle, 1, 0, 1, signal) > 0;
      IndicatorRelease(handle);

      if(!copied)
         return(false);

      return(macd[0] < signal[0]);
     }
  }

//+------------------------------------------------------------------+
//| Position Management                                              |
//+------------------------------------------------------------------+
void CountPositions()
  {
   buyCount = 0;
   sellCount = 0;
   hedgeBuyCount = 0;
   hedgeSellCount = 0;

   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      if(m_position.SelectByIndex(k))
        {
         if(m_position.Symbol() == Symbol())
           {
            if(m_position.Magic() == MagicNumber1)
              {
               if(m_position.PositionType() == POSITION_TYPE_BUY)
                  buyCount++;
               else
                  sellCount++;
              }
            else
               if(m_position.Magic() == MagicNumber2)
                 {
                  if(m_position.PositionType() == POSITION_TYPE_BUY)
                     hedgeBuyCount++;
                  else
                     hedgeSellCount++;
                 }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|   Close Oldest Trade                                             |
//+------------------------------------------------------------------+
void CloseOldestTrade(int type, int magic)
  {
   datetime oldest = D'3000.01.01';
   ulong ticket = 0;
   double totalProfit = 0.0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i) &&
         m_position.Symbol() == Symbol() &&
         m_position.Magic() == magic &&
         m_position.PositionType() == type &&
         m_position.Time() < oldest)
        {
         double profit = m_position.Profit() + m_position.Commission() + m_position.Swap();
         bool validProfit = false;

         if(CloseOldestProfitMode == 0 && profit < 0) // Negative (unprofitable)
            validProfit = true;
         else
            if(CloseOldestProfitMode == 1 && profit > 0) // Positive (profitable)
               validProfit = true;
            else
               if(CloseOldestProfitMode == 2 &&
                  profit >= -CloseOldestBreakevenRange &&
                  profit <= CloseOldestBreakevenRange) // Breakeven
                  validProfit = true;

         if(validProfit)
           {
            oldest = m_position.Time();
            ticket = m_position.Ticket();
            totalProfit = profit;
           }
        }
     }

   if(ticket != 0)
     {
      bool closed = trade.PositionClose(ticket);
      if(closed)
         DebugPrint("Closed oldest position with ticket: " + (string)ticket + " Profit: " + DoubleToString(totalProfit));
      else
         DebugPrint("Failed to close position with ticket: " + (string)ticket + " Error: " + (string)GetLastError());
     }
   else
     {
      DebugPrint("No matching position found to close for profit mode: " + IntegerToString(CloseOldestProfitMode));
     }
  }

//+------------------------------------------------------------------+
//| Helper function to close profitable positions                    |
//+------------------------------------------------------------------+
void CloseProfitablePosition()
  {
   if(!EnablePartialClose)
      return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         string symbol = PositionGetString(POSITION_SYMBOL);
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(profit >= ProfitThreshold)
           {
            MqlTradeRequest request;
            ZeroMemory(request);
            MqlTradeResult result;
            ZeroMemory(result);
            request.action = TRADE_ACTION_DEAL;
            request.position = ticket;
            request.symbol = symbol;
            request.volume = PositionGetDouble(POSITION_VOLUME);
            request.type = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
            request.price = SymbolInfoDouble(symbol, SYMBOL_BID);
            if(request.symbol == "" || request.price <= 0)
              {
               DebugPrint("Invalid symbol or price for position #" + (string)ticket);
               continue;
              }
            if(!OrderSend(request, result))
              {
               DebugPrint("Failed to close position #" + (string)ticket + ", Error: " + (string)GetLastError());
              }
            else
              {
               DebugPrint("Closed position #" + (string)ticket + " with profit: " + DoubleToString(profit));
              }
           }
        }
      else
        {
         DebugPrint("Failed to select position #" + (string)ticket + ", Error: " + (string)GetLastError());
        }
     }
  }

//+------------------------------------------------------------------+
//| Structs for cleaner data passing                                 |
//+------------------------------------------------------------------+
struct PositionStats
  {
   int               buyCount;
   int               sellCount;
   double            BuyPriceMax, BuyPriceMin, BuyPriceMaxLot, BuyPriceMinLot;
   double            SelPriceMax, SelPriceMin, SelPriceMaxLot, SelPriceMinLot;
  };

struct TradeParams
  {
   double            buyStep;
   double            sellStep;
   double            BuyLot;
   double            SelLot;
  };

//+------------------------------------------------------------------+
//| OnTick - Main Orchestrator                                       |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(UseMarketProfile)
      UpdateMarketProfile();

   if(HedgeProfitClose > 0)
      CheckHedgeProfit();

   CountPositions();
   UpdateTrailingTP();
   UpdateTrailingSL();
   PositionStats stats;
   stats = GatherPositionStats();

   UpdateAveragePrices(stats);
   TradeParams params;
   params = CalculateTradeParams(stats);

   MqlRates rates[];
   MqlTick tick;
   if(!GetMarketData(rates, tick))
      return;

   InitHedgeTiming(tick);
   TryOpenHedge(tick, stats);

   TryOpenBuy(rates, tick, stats, params);
   TryOpenSell(rates, tick, stats, params);

   ManageStopsAndTargets(tick, stats);
   CheckProfitClosure();

   CloseProfitablePosition();
  }

//+------------------------------------------------------------------+
//| Gather position statistics                                       |
//+------------------------------------------------------------------+
PositionStats GatherPositionStats()
  {
   PositionStats stats;
   stats.buyCount = 0;
   stats.sellCount = 0;
   stats.BuyPriceMax = stats.BuyPriceMin = 0;
   stats.SelPriceMax = stats.SelPriceMin = 0;
   stats.BuyPriceMaxLot = stats.BuyPriceMinLot = 0;
   stats.SelPriceMaxLot = stats.SelPriceMinLot = 0;

   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      if(m_position.SelectByIndex(k) && m_position.Symbol() == Symbol() && m_position.Magic() == MagicNumber1)
        {
         double op = m_position.PriceOpen();
         double lt = m_position.Volume();
         ulong tk = m_position.Ticket();

         if(m_position.PositionType() == POSITION_TYPE_BUY)
           {
            stats.buyCount++;
            if(op > stats.BuyPriceMax || stats.BuyPriceMax == 0)
              {
               stats.BuyPriceMax = op;
               stats.BuyPriceMaxLot = lt;
              }
            if(op < stats.BuyPriceMin || stats.BuyPriceMin == 0)
              {
               stats.BuyPriceMin = op;
               stats.BuyPriceMinLot = lt;
              }
           }
         else
           {
            stats.sellCount++;
            if(op > stats.SelPriceMax || stats.SelPriceMax == 0)
              {
               stats.SelPriceMax = op;
               stats.SelPriceMaxLot = lt;
              }
            if(op < stats.SelPriceMin || stats.SelPriceMin == 0)
              {
               stats.SelPriceMin = op;
               stats.SelPriceMinLot = lt;
              }
           }
        }
     }
   return stats;
  }

//+------------------------------------------------------------------+
//| Update average prices                                            |
//+------------------------------------------------------------------+
void UpdateAveragePrices(PositionStats &stats)
  {
   double totalbuyprices = 0, totalbuylots = 0, totalsellprices = 0, totalselllots = 0;

   for(int k = PositionsTotal() - 1; k >= 0; k--)
     {
      if(m_position.SelectByIndex(k) && m_position.Symbol() == Symbol() && m_position.Magic() == MagicNumber1)
        {
         double op = m_position.PriceOpen();
         double lt = m_position.Volume();

         if(m_position.PositionType() == POSITION_TYPE_BUY)
           {
            totalbuyprices += (op * lt);
            totalbuylots += lt;
           }
         else
           {
            totalsellprices += (op * lt);
            totalselllots += lt;
           }
        }
     }

   if(stats.buyCount >= CloseNo)
      AverageBuyPrice = (totalbuyprices / totalbuylots) + (MinimalProfit * _Point);
   if(stats.sellCount >= CloseNo)
      AverageSelPrice = (totalsellprices / totalselllots) - (MinimalProfit * _Point);
  }

//+------------------------------------------------------------------+
//| Calculate trade parameters                                       |
//+------------------------------------------------------------------+
TradeParams CalculateTradeParams(PositionStats &stats)
  {
   TradeParams params;

   int fibIdxBuy = MathMin(stats.buyCount, ArraySize(fibRatios) - 1);
   int fibIdxSell = MathMin(stats.sellCount, ArraySize(fibRatios) - 1);
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double pipAdjust = tickSize / _Point;
   double fibRatioBuy = MathMin(fibRatios[fibIdxBuy], MaxFibRatio);
   double fibRatioSell = MathMin(fibRatios[fibIdxSell], MaxFibRatio);

   params.buyStep = UseFibGrid ? PointOrderStep * fibRatioBuy * pipAdjust : PointOrderStep * pipAdjust;
   params.sellStep = UseFibGrid ? PointOrderStep * fibRatioSell * pipAdjust : PointOrderStep * pipAdjust;

   params.BuyLot = (stats.BuyPriceMinLot == 0) ? StartLots :
                   (Multiplier > 1) ? stats.BuyPriceMinLot * Multiplier : stats.BuyPriceMinLot + StartLots;
   params.SelLot = (stats.SelPriceMaxLot == 0) ? StartLots :
                   (Multiplier > 1) ? stats.SelPriceMaxLot * Multiplier : stats.SelPriceMaxLot + StartLots;

   if(UseFibGrid && FibAdjustLots)
     {
      params.BuyLot = (stats.BuyPriceMinLot == 0) ? StartLots :
                      (Multiplier > 1) ? stats.BuyPriceMinLot * fibRatioBuy : stats.BuyPriceMinLot + (StartLots * fibRatioBuy);
      params.SelLot = (stats.SelPriceMaxLot == 0) ? StartLots :
                      (Multiplier > 1) ? stats.SelPriceMaxLot * fibRatioSell : stats.SelPriceMaxLot + (StartLots * fibRatioSell);
     }

   if(MaximalLots > 0)
     {
      params.BuyLot = MathMin(params.BuyLot, MaximalLots);
      params.SelLot = MathMin(params.SelLot, MaximalLots);
     }
   return params;
  }

//+------------------------------------------------------------------+
//| Get market data                                                  |
//+------------------------------------------------------------------+
bool GetMarketData(MqlRates &rates[], MqlTick &tick)
  {
   if(CopyRates(Symbol(), PERIOD_CURRENT, 0, ConsecutiveBars + 1, rates) < ConsecutiveBars + 1 || !SymbolInfoTick(Symbol(), tick))
      return false;
   return true;
  }

//+------------------------------------------------------------------+
//| Init hedge timing snapshot                                       |
//+------------------------------------------------------------------+
void InitHedgeTiming(MqlTick &tick)
  {
   if(stime == 0)
     {
      stime = TimeCurrent();
      bidpricesnap = tick.bid;
      askpricesnap = tick.ask;
     }
  }

//+------------------------------------------------------------------+
//|   Try Open Hedge                                                 |
//+------------------------------------------------------------------+
void TryOpenHedge(MqlTick &tick, PositionStats &stats)
  {
   if(!EnableHedging || (MaxHedgeTrades > 0 && (hedgeBuyCount + hedgeSellCount) >= MaxHedgeTrades))
      return;

   if(TimeCurrent() - stime < Duration)
      return;

   if(stats.buyCount > 0 && (bidpricesnap - tick.bid) >= PipToPrice(HedgeStep))
     {
      if((!UseADX_FilterForHedge || IsStrongTrend(0)) && (!UseTrendFilterForHedge || IsUptrend()))
        {
         double hedgeLot = stats.BuyPriceMinLot * HedgeRatio;
         if(MaxHedgeLot > 0)
            hedgeLot = MathMin(hedgeLot, MaxHedgeLot);
         
         ExecuteTrade(m_trade, ORDER_TYPE_SELL, hedgeLot, tick.bid, 0, 0, "Hedge Sell");
         
         if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
           {
            stime = TimeCurrent();
            bidpricesnap = tick.bid;
            askpricesnap = tick.ask;
           }
        }
     }
   else
      if(stats.sellCount > 0 && (tick.ask - askpricesnap) >= PipToPrice(HedgeStep))
        {
         if((!UseADX_FilterForHedge || IsStrongTrend(1)) && (!UseTrendFilterForHedge || IsDowntrend()))
           {
            double hedgeLot = stats.SelPriceMaxLot * HedgeRatio;
            if(MaxHedgeLot > 0)
               hedgeLot = MathMin(hedgeLot, MaxHedgeLot);
            
            ExecuteTrade(m_trade, ORDER_TYPE_BUY, hedgeLot, tick.ask, 0, 0, "Hedge Buy");
            
            if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
              {
               stime = TimeCurrent();
               bidpricesnap = tick.bid;
               askpricesnap = tick.ask;
              }
           }
        }
  }

//+------------------------------------------------------------------+
//| Try opening a buy                                                |
//+------------------------------------------------------------------+
void TryOpenBuy(MqlRates &rates[], MqlTick &tick, PositionStats &stats, TradeParams &params)
  {
   bool canBuyMain = (MaxBuyTrades <= 0 || stats.buyCount < MaxBuyTrades) &&
                     (MaxTotalTrades <= 0 || (stats.buyCount + stats.sellCount) < MaxTotalTrades);

// Check for consecutive bullish bars, minimum volume, and ATR filter
   bool isBullish = true;
   if(UseATR_Filter)
     {
      double atr[];
      int atrHandle = iATR(Symbol(), PERIOD_CURRENT, ATR_Period);
      if(CopyBuffer(atrHandle, 0, 1, ConsecutiveBars, atr) < ConsecutiveBars)
        {
         isBullish = false;
         DebugPrint("Failed to copy ATR buffer for Buy");
        }
      else
        {
         for(int i = 1; i <= ConsecutiveBars; i++)
           {
            double body = MathAbs(rates[i].close - rates[i].open);
            if(rates[i].close <= rates[i].open || rates[i].tick_volume < MinVolume || body <= ATR_Multiplier * atr[i-1])
              {
               isBullish = false;
               break;
              }
           }
        }
      IndicatorRelease(atrHandle);
     }
   else
     {
      for(int i = 1; i <= ConsecutiveBars; i++)
        {
         if(rates[i].close <= rates[i].open || rates[i].tick_volume < MinVolume)
           {
            isBullish = false;
            break;
           }
        }
     }

// RSI filter
   bool rsiCheck = true;
   if(UseRSI_Filter)
     {
      double rsi[];
      int rsiHandle = iRSI(Symbol(), PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
      if(CopyBuffer(rsiHandle, 0, 0, 1, rsi) < 1)
        {
         rsiCheck = false;
         DebugPrint("Failed to copy RSI buffer for Buy");
        }
      else
        {
         rsiCheck = rsi[0] > 50.0 && rsi[0] < RSI_Overbought;
        }
      IndicatorRelease(rsiHandle);
     }

   if(isBullish && canBuyMain && (!UseTrendFilterForMain || IsUptrend()) &&
      (!UseADX_Filter || IsStrongTrend(0)) &&
      (!UseMarketProfile || (IsInValueArea() && !IsNearPOC())) &&
      rsiCheck)
     {
      if((stats.buyCount == 0) || (stats.buyCount > 0 && (stats.BuyPriceMin - tick.ask) > (params.buyStep * _Point)))
        {
         if(CloseOldest && stats.buyCount >= MaxBuyTrades)
            CloseOldestTrade(POSITION_TYPE_BUY, MagicNumber1);

         double sl = EnableStopLoss ? tick.ask - TakeProfit * _Point : 0;
         double tp = EnableTakeProfit && !UseTrailingTP ? tick.ask + TakeProfit * _Point : 0;
         ExecuteTrade(trade, ORDER_TYPE_BUY, params.BuyLot, tick.ask, sl, tp, "Grid Buy");
        }
     }
  }

//+------------------------------------------------------------------+
//| Try opening a sell                                               |
//+------------------------------------------------------------------+
void TryOpenSell(MqlRates &rates[], MqlTick &tick, PositionStats &stats, TradeParams &params)
  {
   bool canSellMain = (MaxSellTrades <= 0 || stats.sellCount < MaxSellTrades) &&
                      (MaxTotalTrades <= 0 || (stats.buyCount + stats.sellCount) < MaxTotalTrades);

// Check for consecutive bearish bars, minimum volume, and ATR filter
   bool isBearish = true;
   if(UseATR_Filter)
     {
      double atr[];
      int atrHandle = iATR(Symbol(), PERIOD_CURRENT, ATR_Period);
      if(CopyBuffer(atrHandle, 0, 1, ConsecutiveBars, atr) < ConsecutiveBars)
        {
         isBearish = false;
         DebugPrint("Failed to copy ATR buffer for Sell");
        }
      else
        {
         for(int i = 1; i <= ConsecutiveBars; i++)
           {
            double body = MathAbs(rates[i].close - rates[i].open);
            if(rates[i].close >= rates[i].open || rates[i].tick_volume < MinVolume || body <= ATR_Multiplier * atr[i-1])
              {
               isBearish = false;
               break;
              }
           }
        }
      IndicatorRelease(atrHandle);
     }
   else
     {
      for(int i = 1; i <= ConsecutiveBars; i++)
        {
         if(rates[i].close >= rates[i].open || rates[i].tick_volume < MinVolume)
           {
            isBearish = false;
            break;
           }
        }
     }

// RSI filter
   bool rsiCheck = true;
   if(UseRSI_Filter)
     {
      double rsi[];
      int rsiHandle = iRSI(Symbol(), PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
      if(CopyBuffer(rsiHandle, 0, 0, 1, rsi) < 1)
        {
         rsiCheck = false;
         DebugPrint("Failed to copy RSI buffer for Sell");
        }
      else
        {
         rsiCheck = rsi[0] < 50.0 && rsi[0] > RSI_Oversold;
        }
      IndicatorRelease(rsiHandle);
     }

   if(isBearish && canSellMain && (!UseTrendFilterForMain || IsDowntrend()) &&
      (!UseADX_Filter || IsStrongTrend(1)) &&
      (!UseMarketProfile || (IsInValueArea() && !IsNearPOC())) &&
      rsiCheck)
     {
      if((stats.sellCount == 0) || (stats.sellCount > 0 && (tick.bid - stats.SelPriceMax) > (params.sellStep * _Point)))
        {
         if(CloseOldest && stats.sellCount >= MaxSellTrades)
            CloseOldestTrade(POSITION_TYPE_SELL, MagicNumber1);

         double sl = EnableStopLoss ? tick.bid + TakeProfit * _Point : 0;
         double tp = EnableTakeProfit && !UseTrailingTP ? tick.bid - TakeProfit * _Point : 0;
         ExecuteTrade(trade, ORDER_TYPE_SELL, params.SelLot, tick.bid, sl, tp, "Grid Sell");
        }
     }
  }

//+------------------------------------------------------------------+
//| Manage SL and TP                                                 |
//+------------------------------------------------------------------+
void ManageStopsAndTargets(MqlTick &tick, PositionStats &stats)
  {
   if(EnableTakeProfit || EnableStopLoss)
     {
      for(int k = PositionsTotal() - 1; k >= 0; k--)
        {
         if(m_position.SelectByIndex(k) && m_position.Symbol() == Symbol() && m_position.Magic() == MagicNumber1)
           {
            double sl = m_position.StopLoss();
            double tp = m_position.TakeProfit();
            ulong tk = m_position.Ticket();

            if(m_position.PositionType() == POSITION_TYPE_BUY)
              {
               if(EnableTakeProfit && !UseTrailingTP && stats.buyCount == 1 && tp == 0)
                  SafePositionModify(tk, sl, tick.ask + TakeProfit * _Point);

               if(EnableTakeProfit && !UseTrailingTP && stats.buyCount >= CloseNo && tick.bid < AverageBuyPrice && tp != AverageBuyPrice)
                  SafePositionModify(tk, sl, AverageBuyPrice);
              }
            else
              {
               if(EnableTakeProfit && !UseTrailingTP && stats.sellCount == 1 && tp == 0)
                  SafePositionModify(tk, sl, tick.bid - TakeProfit * _Point);

               if(EnableTakeProfit && !UseTrailingTP && stats.sellCount >= CloseNo && tick.ask > AverageSelPrice && tp != AverageSelPrice)
                  SafePositionModify(tk, sl, AverageSelPrice);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Profit-based closure                                             |
//+------------------------------------------------------------------+
void CheckProfitClosure()
  {
   if(IsPositionExists())
     {
      double totalProfit = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if(m_position.SelectByIndex(i))
            totalProfit += m_position.Profit() + m_position.Commission() + m_position.Swap();
        }

      if(totalProfit >= InpProfit)
        {
         switch(CloseType)
           {
            case 1:
               CloseAllPositions();
               DebugPrint("Closed all positions due to profit target: " + DoubleToString(InpProfit));
               break;
            case 2:
               CloseTradePositions();
               DebugPrint("Closed main positions due to profit target: " + DoubleToString(InpProfit));
               break;
            case 3:
               CloseHedgePositions();
               DebugPrint("Closed hedge positions due to profit target: " + DoubleToString(InpProfit));
               break;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|  Check Hedge Profit                                              |
//+------------------------------------------------------------------+
void CheckHedgeProfit()
  {
   string currentSymbol = Symbol();
   double minVol = SymbolInfoDouble(currentSymbol, SYMBOL_VOLUME_MIN);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         if(m_position.Symbol() == currentSymbol && m_position.Magic() == MagicNumber2)
           {
            double profit = m_position.Profit() + m_position.Commission() + m_position.Swap();
            if(profit >= HedgeProfitClose)
              {
               if(HedgePartialClose && HedgePartialPercent > 0 && HedgePartialPercent < 100)
                 {
                  double keepVol = NormalizeLotSize(m_position.Volume() * (1 - HedgePartialPercent / 100.0));
                  if(keepVol >= minVol)
                    {
                     if(trade.PositionClose(m_position.Ticket()))
                       {
                        if(m_position.PositionType() == POSITION_TYPE_BUY)
                          {
                           ExecuteTrade(trade, ORDER_TYPE_BUY, keepVol, 0, 0, 0, "PartialKeep");
                          }
                        else
                          {
                           ExecuteTrade(trade, ORDER_TYPE_SELL, keepVol, 0, 0, 0, "PartialKeep");
                          }
                       }
                    }
                  else
                    {
                     trade.PositionClose(m_position.Ticket());
                    }
                 }
               else
                 {
                  trade.PositionClose(m_position.Ticket());
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|   Close All Positions                                            |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i))
        {
         ulong ticket = m_position.Ticket();
         if(m_trade.PositionClose(ticket))
           {
            DebugPrint("Closed position Ticket: " + (string)ticket);
           }
         else
           {
            DebugPrint("Failed to close position Ticket: " + (string)ticket + " Error: " + (string)GetLastError());
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|    Close Trade Positions                                         |
//+------------------------------------------------------------------+
void CloseTradePositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i) && m_position.Magic() == MagicNumber1)
        {
         ulong ticket = m_position.Ticket();
         if(m_trade.PositionClose(ticket))
            DebugPrint("Closed trade position Ticket: " + (string)ticket);
         else
            DebugPrint("Failed to close trade position Ticket: " + (string)ticket + " Error: " + (string)GetLastError());
        }
     }
  }

//+------------------------------------------------------------------+
//|   Close Hedge Positions                                          |
//+------------------------------------------------------------------+
void CloseHedgePositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i) && m_position.Magic() == MagicNumber2)
        {
         ulong ticket = m_position.Ticket();
         if(m_trade.PositionClose(ticket))
           {
            DebugPrint("Hedge position closed successfully, Ticket: " + (string)ticket);
           }
         else
           {
            DebugPrint("Failed to close hedge position, Ticket: " + (string)ticket + ", Error: " + (string)GetLastError());
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|   Is Position Exists                                             |
//+------------------------------------------------------------------+
bool IsPositionExists()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(m_position.SelectByIndex(i) && m_position.Symbol() == Symbol())
        {
         DebugPrint("Position exists for symbol: " + Symbol());
         return true;
        }
     }
   DebugPrint("No position exists for symbol: " + Symbol());
   return false;
  }

//+------------------------------------------------------------------+
//| Cleanup on Deinit                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DebugPrint("OnDeinit called with reason: " + IntegerToString(reason));
   ObjectsDeleteAll(0, 0, -1);
   Comment("");
  }
//+------------------------------------------------------------------+