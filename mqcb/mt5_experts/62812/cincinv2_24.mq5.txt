//+------------------------------------------------------------------+
//| Cincin EA                                                        |
//| Copyright © 2025, Lupus Materia Ltd, Yashar Seyyedin,            |
//|                   barabashkakvn, SalmanSoltaniyan                |
//| Based on:                                                        |
//| - Optimised Basket Close by DADALI ARWALY                        |
//| - Basket Manager EA by Yashar Seyyedin                           |
//| - Hedge any positions by barabashkakvn                           |
//| - Random Trader by SalmanSoltaniyan                              |
//|                                                                  |
//| DISCLAIMER: Use at your own risk. Trading may result in total    |
//| loss. No guarantees provided. Always test first before use.      |
//+------------------------------------------------------------------+
#property strict
#property copyright "Copyright © 2025, Lupus Materia Ltd, Yashar Seyyedin, barabashkakvn, SalmanSoltaniyan"
#property version   "2.24"
#property description "Optimized EA with structs for conservative random trading, basket management, and hedging."

#include <Trade\Trade.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Enum Definitions                                                 |
//+------------------------------------------------------------------+
enum ENUM_LOSS { ATR, PIP }; // Moved to global scope

//+------------------------------------------------------------------+
//| Struct Definitions                                               |
//+------------------------------------------------------------------+
struct TradeParams
  {
   ENUM_ORDER_TYPE   order_type;
   double            entry_price;
   double            sl_price;
   double            tp_price;
   double            lot_size;

   // Default constructor
                     TradeParams()
     {
      order_type = ORDER_TYPE_BUY; // Default to BUY (arbitrary choice)
      entry_price = 0.0;
      sl_price = 0.0;
      tp_price = 0.0;
      lot_size = 0.0;
     }

   // Copy constructor
                     TradeParams(const TradeParams &source)
     {
      order_type = source.order_type;
      entry_price = source.entry_price;
      sl_price = source.sl_price;
      tp_price = source.tp_price;
      lot_size = source.lot_size;
     }
  };

struct PositionInfoStruct
  {
   ulong             ticket;
   ENUM_POSITION_TYPE pos_type;
   double            open_price;
   double            current_price;
   double            stop_loss;
   double            take_profit;
   long              identifier;
   string            symbol;
   ulong             magic;
  };

struct ConfigSettings
  {
   bool              enable_profit_close;
   double            profit_target;
   bool              profit_in_percent;
   bool              enable_loss_close;
   double            loss_limit;
   bool              loss_in_percent;
   int               position_threshold;
   bool              close_on_profit_only;
   bool              enable_hedging;
   ushort            hedge_pips;
   double            hedge_lot_multiplier;
   bool              print_trade_results;
   double            reward_risk_ratio;
   ENUM_LOSS         loss_type;
   double            loss_atr;
   double            loss_pip;
   double            risk_percent_per_trade;
   bool              use_breakeven;
   double            breakeven_distance;
   bool              enable_stop_loss;
   int               slippage;
   bool              enable_alerts;
   bool              all_symbols;
   int               label_x_distance;
   int               label_y_distance;
   int               label_update_interval;
   bool              open_test_trade;
   bool              enable_debug_log;
   bool              use_max_margin;
   int               min_minutes_between_trades;
   double            min_pips_between_trades;
   int               max_daily_trades;
   ulong             magic;
  };

//+------------------------------------------------------------------+
//| Validation class for trading operations                          |
//+------------------------------------------------------------------+
class CTradeValidation
  {
private:
   string            symbol;
   double            point;
   double            pip_point;
   double            stop_level;
   double            freeze_level;
   double            tick_size;

public:
                     CTradeValidation(string _symbol, bool use_max_level = false)
     {
      symbol = _symbol;
      point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);

      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      pip_point = (digits == 2 || digits == 3) ? point : point * 10;

      freeze_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL) * point + (10 * point);
      stop_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * point + (15 * point); // Increased buffer

      if(use_max_level)
        {
         freeze_level = MathMax(freeze_level, stop_level);
         stop_level = freeze_level;
        }
     }

   double            GetStopLevel() { return stop_level; }
   double            GetFreezeLevel() { return freeze_level; }
   double            GetPipPoint() { return pip_point; }

   double            CalculateValidLot(double sl_price, double entry_price, double risk_percent)
     {
      if(sl_price == 0 || !config.enable_stop_loss)
         return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

      double risk_amount = AccountInfoDouble(ACCOUNT_BALANCE) * risk_percent / 100;
      double sl_distance = MathAbs(entry_price - sl_price);
      double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      if(sl_distance == 0 || tick_value == 0)
         return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

      double lot_size = risk_amount / (sl_distance * tick_value / SymbolInfoDouble(symbol, SYMBOL_POINT));

      // Apply lot constraints
      double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      lot_size = MathFloor(lot_size / lot_step) * lot_step;
      lot_size = MathMax(min_lot, MathMin(max_lot, lot_size));

      return lot_size;
     }

   bool              CheckMargin(double &lot_size, ENUM_ORDER_TYPE order_type, bool use_max_margin)
     {
      double margin_required;
      double price = (order_type == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);

      if(!OrderCalcMargin(order_type, symbol, lot_size, price, margin_required))
         return false;

      double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      margin_required *= 1.1;

      if(free_margin < margin_required && use_max_margin)
        {
         double max_lot = CalculateMaxLot(order_type, free_margin);
         if(max_lot > 0)
           {
            lot_size = max_lot;
            return true;
           }
         return false;
        }
      return free_margin >= margin_required;
     }

   double            CalculateMaxLot(ENUM_ORDER_TYPE order_type, double available_margin)
     {
      double price = (order_type == ORDER_TYPE_BUY) ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);
      double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_LIMIT);
      if(max_lot == 0)
         max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      double margin_per_lot;
      if(!OrderCalcMargin(order_type, symbol, 1.0, price, margin_per_lot))
         return 0;

      double max_possible_lot = (available_margin / 1.1) / margin_per_lot;
      max_possible_lot = MathFloor(max_possible_lot / lot_step) * lot_step;

      return (max_possible_lot < min_lot) ? 0 : MathMin(max_lot, max_possible_lot);
     }

   double            Round2Ticksize(double price)
     {
      return MathRound(price / tick_size) * tick_size;
     }

   bool              ValidateOrderPlacement(const TradeParams &params)
     {
      if(!config.enable_stop_loss && params.sl_price == 0)
         return true; // Skip validation if SL disabled

      double entry_price = Round2Ticksize(params.entry_price);
      double sl_price = Round2Ticksize(params.sl_price);
      double tp_price = Round2Ticksize(params.tp_price);

      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

      double min_stop_distance = stop_level; // Ensure SL/TP respects minimum stop level

      switch(params.order_type)
        {
         case ORDER_TYPE_BUY:
            if(sl_price != 0 && bid - sl_price < min_stop_distance)
               return false;
            if(tp_price != 0 && tp_price - bid < min_stop_distance)
               return false;
            return true;
         case ORDER_TYPE_SELL:
            if(sl_price != 0 && sl_price - ask < min_stop_distance)
               return false;
            if(tp_price != 0 && ask - tp_price < min_stop_distance)
               return false;
            return true;
         case ORDER_TYPE_BUY_LIMIT:
            if(ask - entry_price < min_stop_distance)
               return false;
            if(sl_price != 0 && entry_price - sl_price < min_stop_distance)
               return false;
            if(tp_price != 0 && tp_price - entry_price < min_stop_distance)
               return false;
            return true;
         case ORDER_TYPE_SELL_LIMIT:
            if(entry_price - bid < min_stop_distance)
               return false;
            if(sl_price != 0 && sl_price - entry_price < min_stop_distance)
               return false;
            if(tp_price != 0 && entry_price - tp_price < min_stop_distance)
               return false;
            return true;
         case ORDER_TYPE_BUY_STOP:
            if(entry_price - ask < min_stop_distance)
               return false;
            if(sl_price != 0 && entry_price - sl_price < min_stop_distance)
               return false;
            if(tp_price != 0 && tp_price - entry_price < min_stop_distance)
               return false;
            return true;
         case ORDER_TYPE_SELL_STOP:
            if(bid - entry_price < min_stop_distance)
               return false;
            if(sl_price != 0 && sl_price - entry_price < min_stop_distance)
               return false;
            if(tp_price != 0 && entry_price - tp_price < min_stop_distance)
               return false;
            return true;
        }
      return false;
     }

   bool              ValidateSLModify(ENUM_ORDER_TYPE order_type, double old_sl, double new_sl, double open_price = 0)
     {
      if(!config.enable_stop_loss)
         return false; // Skip if SL disabled

      old_sl = Round2Ticksize(old_sl);
      new_sl = Round2Ticksize(new_sl);
      open_price = Round2Ticksize(open_price);

      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

      if(order_type == ORDER_TYPE_BUY || order_type == ORDER_TYPE_SELL)
        {
         if(order_type == ORDER_TYPE_BUY && bid - old_sl <= freeze_level)
            return false;
         if(order_type == ORDER_TYPE_SELL && old_sl - ask <= freeze_level)
            return false;
        }

      switch(order_type)
        {
         case ORDER_TYPE_BUY:
            return (bid - new_sl >= stop_level);
         case ORDER_TYPE_SELL:
            return (new_sl - ask >= stop_level);
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
            return (open_price - new_sl >= stop_level);
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
            return (new_sl - open_price >= stop_level);
        }
      return false;
     }
  };

//+------------------------------------------------------------------+
//| Global Objects and Variables                                     |
//+------------------------------------------------------------------+
CTrade trade;
CDealInfo m_deal;
CPositionInfo m_position;
CSymbolInfo m_symbol;
CAccountInfo m_account;
CTradeValidation *validation;

ConfigSettings config;
double balance;
bool positionClosedThisTick = false;
long chartID;
datetime lastLabelCheck;
ulong hedgeIdArray[];
int atr_handle;
double atr_array[];
bool breakeven_activated = false;
MqlTick lastTick;
datetime lastTradeTime = 0;
datetime lastTradeDay = 0;
int modificationAttempts[100]; // Track modification attempts per position

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input group "Profit/Loss Settings"
input bool   InpEnableProfitClose = true;     // Enable Profit Closing
input double InpProfitTarget      = 1.0;      // Profit Target (1.0% or $1.0)
input bool   InpProfitInPercent   = true;     // Profit Target in %
input bool   InpEnableLossClose   = false;     // Enable Loss Closing
input double InpLossLimit         = 1.0;      // Loss Limit (1.0% or $1.0)
input bool   InpLossInPercent     = true;     // Loss Limit in %

input group "Position Count Settings"
input int    InpPositionThreshold = 1;        // Max positions before closing
input bool   InpCloseOnProfitOnly = true;     // Only close if equity > balance

input group "Hedging Settings"
input bool   InpEnableHedging     = true;     // Enable Hedging Functionality
input ushort InpHedgePips         = 5;        // Losing pips before hedging
input double InpHedgeLotMultiplier= 2.0;      // Lot multiplier for hedge position
input bool   InpPrintTradeResults = false;    // Print detailed trade results

input group "Random Trade Settings"
input double InpRewardRiskRatio   = 2.0;      // Reward/Risk ratio
input ENUM_LOSS InpLossType       = PIP;      // Loss based on ATR or PIP
input double InpLossATR           = 5.0;      // ATR multiplier for stop loss
input double InpLossPip           = 30.0;     // Fixed pip distance for stop loss (increased to avoid invalid stops)
input double InpRiskPercentPerTrade = 1.0;    // Risk percent per trade
input bool   InpUseBreakeven      = true;     // Use breakeven mechanism
input double InpBreakevenDistance = 10.0;     // Distance in pips for breakeven

input group "General Settings"
input bool   InpEnableStopLoss    = false;     // Enable Stop Loss (enabled to match log)
input int    InpSlippage          = 10;       // Slippage in points
input bool   InpEnableAlerts      = true;     // Enable Alerts
input bool   InpAllSymbols        = false;    // Monitor all symbols (false=current only)
input int    InpLabelXDistance    = 30;       // Label X Distance (pixels from left)
input int    InpLabelYDistance    = 80;       // Label Y Distance (pixels from bottom)
input int    InpLabelUpdateInterval = 60;     // Label update interval (seconds)
input bool   InpOpenTestTrade     = true;     // Open Test Trade on Init
input bool   InpEnableDebugLog    = true;     // Enable detailed debug logging
input bool   InpUseMaxMargin      = true;     // Use max margin if required margin insufficient
input ulong  InpMagic             = 1234;     // EA Magic Number (for trade identification)

input group "Position Control Settings"
input int    InpMinMinutesBetweenTrades = 5;  // Minimum minutes between trades
input double InpMinPipsBetweenTrades = 50.0;  // Minimum pips between same-direction trades
input int    InpMaxDailyTrades = 1;          // Maximum trades per day (0=unlimited)

//+------------------------------------------------------------------+
//| Expert Initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   chartID = ChartID();
   Print("Initializing Cincin EA v2.24 on chart ", chartID, ", Symbol: ", Symbol(), ", Timeframe: ", Period());

// Initialize configuration
   config.enable_profit_close = InpEnableProfitClose;
   config.profit_target = InpProfitTarget;
   config.profit_in_percent = InpProfitInPercent;
   config.enable_loss_close = InpEnableLossClose;
   config.loss_limit = InpLossLimit;
   config.loss_in_percent = InpLossInPercent;
   config.position_threshold = InpPositionThreshold;
   config.close_on_profit_only = InpCloseOnProfitOnly;
   config.enable_hedging = InpEnableHedging;
   config.hedge_pips = InpHedgePips;
   config.hedge_lot_multiplier = InpHedgeLotMultiplier;
   config.print_trade_results = InpPrintTradeResults;
   config.reward_risk_ratio = InpRewardRiskRatio;
   config.loss_type = InpLossType;
   config.loss_atr = InpLossATR;
   config.loss_pip = InpLossPip;
   config.risk_percent_per_trade = InpRiskPercentPerTrade;
   config.use_breakeven = InpUseBreakeven;
   config.breakeven_distance = InpBreakevenDistance;
   config.enable_stop_loss = InpEnableStopLoss;
   config.slippage = InpSlippage;
   config.enable_alerts = InpEnableAlerts;
   config.all_symbols = InpAllSymbols;
   config.label_x_distance = InpLabelXDistance;
   config.label_y_distance = InpLabelYDistance;
   config.label_update_interval = InpLabelUpdateInterval;
   config.open_test_trade = InpOpenTestTrade;
   config.enable_debug_log = InpEnableDebugLog;
   config.use_max_margin = InpUseMaxMargin;
   config.min_minutes_between_trades = InpMinMinutesBetweenTrades;
   config.min_pips_between_trades = InpMinPipsBetweenTrades;
   config.max_daily_trades = InpMaxDailyTrades;
   config.magic = InpMagic;

// Set fixed magic number for all trades
   trade.SetExpertMagicNumber(config.magic);

// Validate inputs
   if(config.profit_target <= 0 && config.enable_profit_close)
     {
      Alert("Error: ProfitTarget must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.loss_limit <= 0 && config.enable_loss_close)
     {
      Alert("Error: LossLimit must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.slippage < 0)
     {
      Alert("Error: Slippage must be non-negative");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.label_x_distance < 0 || config.label_y_distance < 0)
     {
      Alert("Error: Label distances must be non-negative");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.position_threshold < 1)
     {
      Alert("Error: PositionThreshold must be at least 1");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.enable_hedging && config.hedge_pips <= 0)
     {
      Alert("Error: HedgePips must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.enable_hedging && config.hedge_lot_multiplier <= 0)
     {
      Alert("Error: HedgeLotMultiplier must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.loss_atr <= 0 && config.loss_type == ATR)
     {
      Alert("Error: LossATR must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.loss_pip <= 0 && config.loss_type == PIP)
     {
      Alert("Error: LossPip must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.reward_risk_ratio <= 0)
     {
      Alert("Error: RewardRiskRatio must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.risk_percent_per_trade <= 0)
     {
      Alert("Error: RiskPercentPerTrade must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.use_breakeven && config.breakeven_distance <= 0)
     {
      Alert("Error: BreakevenDistance must be positive");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.min_minutes_between_trades < 0)
     {
      Alert("Error: MinMinutesBetweenTrades must be non-negative");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.min_pips_between_trades < 0)
     {
      Alert("Error: MinPipsBetweenTrades must be non-negative");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(config.max_daily_trades < 0)
     {
      Alert("Error: MaxDailyTrades must be non-negative");
      return INIT_PARAMETERS_INCORRECT;
     }

   EventSetMillisecondTimer(100);
   trade.SetDeviationInPoints(config.slippage);
   balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0)
     {
      Alert("Error: Account balance is zero or negative");
      return INIT_FAILED;
     }

   ArrayFree(hedgeIdArray);
   validation = new CTradeValidation(Symbol());

   if(!m_symbol.Name(Symbol()))
     {
      Alert("Failed to initialize symbol info");
      return INIT_FAILED;
     }

   if(config.loss_type == ATR)
     {
      atr_handle = iATR(Symbol(), PERIOD_CURRENT, 14); // Adjusted to standard ATR period
      ArraySetAsSeries(atr_array, true);
      if(atr_handle == INVALID_HANDLE)
        {
         Alert("Error: Failed to initialize ATR indicator");
         return INIT_FAILED;
        }
     }

   int chartWidth = (int)ChartGetInteger(chartID, CHART_WIDTH_IN_PIXELS);
   int chartHeight = (int)ChartGetInteger(chartID, CHART_HEIGHT_IN_PIXELS);
   if(config.enable_debug_log)
      Print("Chart: Width=", chartWidth, ", Height=", chartHeight);

   if(config.label_x_distance + 200 > chartWidth || config.label_y_distance + 20 > chartHeight)
      Print("Warning: Label position may be outside chart bounds");

   CreateLabel();

// Initialize modification attempts array
   ArrayInitialize(modificationAttempts, 0);

   if(config.open_test_trade && !config.all_symbols && !IsPositionExists() && IsMarketOpen())
      OpenNewPosition();

   lastLabelCheck = TimeCurrent();
   lastTick.time_msc = 0;
   lastTradeDay = iTime(NULL, PERIOD_D1, 0); // Initialize trading day
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Check if Market is Open                                          |
//+------------------------------------------------------------------+
bool IsMarketOpen()
  {
   if(!m_symbol.RefreshRates() || m_symbol.Ask() == 0 || m_symbol.Bid() == 0)
     {
      if(config.enable_debug_log)
         Print("Market is closed for ", m_symbol.Name(), " at ", TimeToString(TimeCurrent()));
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Simple market-hours guard for FX (skip weekends)                  |
//+------------------------------------------------------------------+
bool IsMarketOpenNow()
  {
   MqlDateTime dt;
   TimeCurrent(dt);
   int dow = dt.day_of_week;               // 0=Sunday, 6=Saturday
   if(dow == 0 || dow == 6)
      return false;  // closed on weekends
   return true;
  }

//+------------------------------------------------------------------+
//| Expert Tick Function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Optimization: Skip if no new tick data
   MqlTick currentTick;
   if(!SymbolInfoTick(Symbol(), currentTick) || currentTick.time_msc == lastTick.time_msc)
      return;
   lastTick = currentTick;

   if(positionClosedThisTick)
     {
      positionClosedThisTick = false;
      return;
     }

   balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance <= 0)
     {
      Print("Warning: Account balance is zero or negative, skipping tick");
      return;
     }

// Check if it's a new trading day
   datetime currentDay = iTime(NULL, PERIOD_D1, 0);
   if(currentDay != lastTradeDay)
     {
      lastTradeDay = currentDay;
      if(config.enable_debug_log)
         Print("New trading day started: ", TimeToString(currentDay, TIME_DATE));
     }

// Check market status
   if(!IsMarketOpen())
     {
      if(config.enable_debug_log)
         Print("Skipping tick: Market is closed");
      return;
     }

// Optimization: Update label only at specified interval
   if(TimeCurrent() - lastLabelCheck >= config.label_update_interval)
     {
      if(ObjectFind(chartID, "PLabel") < 0)
        {
         Print("Label missing, recreating...");
         CreateLabel();
        }
      lastLabelCheck = TimeCurrent();
      double profit = CalculateTotalProfit();
      UpdateLabel(profit, (profit / balance) * 100);
     }

   if(config.use_breakeven && config.enable_stop_loss)
      CheckBreakeven();

   bool closePositions = false;
   string alertMsg = "";
   double profit = CalculateTotalProfit();
   double percent = (profit / balance) * 100;

   if(config.enable_profit_close && (config.profit_in_percent ? percent >= config.profit_target : profit >= config.profit_target))
     {
      closePositions = true;
      alertMsg = StringFormat("Profit Target Reached: %s%.2f%s, Closing %d positions",
                              config.profit_in_percent ? "" : "$", config.profit_in_percent ? percent : profit,
                              config.profit_in_percent ? "%" : "", PositionsTotal());
     }
   else
      if(config.enable_loss_close && (config.loss_in_percent ? percent <= -config.loss_limit : profit <= -config.loss_limit))
        {
         closePositions = true;
         alertMsg = StringFormat("Loss Limit Reached: %s%.2f%s, Closing %d positions",
                                 config.profit_in_percent ? "" : "$", config.profit_in_percent ? -percent : -profit,
                                 config.profit_in_percent ? "%" : "", PositionsTotal());
        }
      else
         if(PositionsTotal() >= config.position_threshold && (!config.close_on_profit_only || AccountInfoDouble(ACCOUNT_EQUITY) > balance))
           {
            closePositions = true;
            alertMsg = StringFormat("Position Threshold (%d) Reached, Equity: %.2f, Closing all positions",
                                    config.position_threshold, AccountInfoDouble(ACCOUNT_EQUITY));
           }

   int currentPositions = PositionsTotal();

   if(closePositions)
     {
      CloseAllPositions(alertMsg);
     }
   else
      if(currentPositions < config.position_threshold && (config.max_daily_trades == 0 || CountTradesToday() < config.max_daily_trades))
        {
         OpenNewPosition();
        }

   if(config.enable_hedging && !closePositions && (config.max_daily_trades == 0 || CountTradesToday() < config.max_daily_trades))
     {
      CheckForHedgeOpportunities();
     }
  }

//+------------------------------------------------------------------+
//| Ensure SL/TP meet broker stop levels (zeros if too close)        |
//+------------------------------------------------------------------+
void AdjustSLTPForStops(const int order_type, double &sl, double &tp)
  {
// Get current market prices
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);

// Get broker stop levels
   double stops_level = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL) * point;
   double freeze_level = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_FREEZE_LEVEL) * point;

// Use the larger of the two with buffer
   double min_distance = MathMax(stops_level, freeze_level) + (10 * point);

   if(order_type == ORDER_TYPE_BUY)
     {
      if(sl > 0 && (ask - sl) < min_distance)
        {
         if(config.enable_debug_log)
            Print("SL too close for BUY. Ask: ", ask, " SL: ", sl, " Distance: ", (ask-sl), " Min: ", min_distance);
         sl = 0.0; // Disable SL if too close
        }
      if(tp > 0 && (tp - ask) < min_distance)
        {
         if(config.enable_debug_log)
            Print("TP too close for BUY. Ask: ", ask, " TP: ", tp, " Distance: ", (tp-ask), " Min: ", min_distance);
         tp = 0.0; // Disable TP if too close
        }
     }
   else
      if(order_type == ORDER_TYPE_SELL)
        {
         if(sl > 0 && (sl - bid) < min_distance)
           {
            if(config.enable_debug_log)
               Print("SL too close for SELL. Bid: ", bid, " SL: ", sl, " Distance: ", (sl-bid), " Min: ", min_distance);
            sl = 0.0; // Disable SL if too close
           }
         if(tp > 0 && (bid - tp) < min_distance)
           {
            if(config.enable_debug_log)
               Print("TP too close for SELL. Bid: ", bid, " TP: ", tp, " Distance: ", (bid-tp), " Min: ", min_distance);
            tp = 0.0; // Disable TP if too close
           }
        }

// Normalize prices
   if(sl > 0)
      sl = NormalizeDouble(sl, _Digits);
   if(tp > 0)
      tp = NormalizeDouble(tp, _Digits);
  }

//+------------------------------------------------------------------+
//| Open New Position                                                |
//+------------------------------------------------------------------+
void OpenNewPosition()
  {
   if(!IsMarketOpenNow())
      return;
// Check time since last trade
   if(TimeCurrent() - lastTradeTime < config.min_minutes_between_trades * 60)
     {
      if(config.enable_debug_log)
         Print("Skipping trade: Minimum time between trades not reached");
      return;
     }

// Check daily trade limit
   if(config.max_daily_trades > 0 && CountTradesToday() >= config.max_daily_trades)
     {
      if(config.enable_debug_log)
         Print("Skipping trade: Daily trade limit reached");
      return;
     }

// Check distance from existing positions
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      if(PositionGetTicket(i))
        {
         string symbol = PositionGetString(POSITION_SYMBOL);
         if(symbol != Symbol())
            continue;

         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double distance = MathAbs(lastTick.bid - openPrice) / validation.GetPipPoint();

         if(distance < config.min_pips_between_trades)
           {
            if(config.enable_debug_log)
               Print("Skipping trade: Minimum pips between trades not reached");
            return;
           }
        }
     }

   breakeven_activated = false;

   double sl_distance = 0, tp_distance = 0;
   double min_stop_distance = validation.GetStopLevel(); // Get broker's minimum stop level

   if(config.enable_stop_loss)
     {
      if(config.loss_type == ATR)
        {
         if(CopyBuffer(atr_handle, 0, 0, 5, atr_array) <= 0)
           {
            if(config.enable_debug_log)
               Print("Failed to get ATR data");
            return;
           }
         sl_distance = MathMax(config.loss_atr * atr_array[0], min_stop_distance);
         tp_distance = sl_distance * config.reward_risk_ratio;
        }
      else
        {
         sl_distance = MathMax(config.loss_pip * validation.GetPipPoint(), min_stop_distance);
         tp_distance = sl_distance * config.reward_risk_ratio;
        }
     }

   TradeParams params;
   params.order_type = (MathMod(MathRand(), 2) == 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   params.entry_price = (params.order_type == ORDER_TYPE_BUY) ? lastTick.ask : lastTick.bid;

// Set SL price only if enabled
   if(config.enable_stop_loss)
     {
      params.sl_price = (params.order_type == ORDER_TYPE_BUY) ? params.entry_price - sl_distance : params.entry_price + sl_distance;
      params.sl_price = NormalizeDouble(params.sl_price, _Digits);
     }
   else
     {
      params.sl_price = 0; // No SL
     }

// Always set TP
   params.tp_price = (params.order_type == ORDER_TYPE_BUY) ? params.entry_price + tp_distance : params.entry_price - tp_distance;
   params.tp_price = NormalizeDouble(params.tp_price, _Digits);

// Ensure stops meet broker minimums
   AdjustSLTPForStops(params.order_type, params.sl_price, params.tp_price);

// Additional validation - disable SL/TP if invalid
   if(params.sl_price > 0 && !validation.ValidateOrderPlacement(params))
     {
      if(config.enable_debug_log)
        {
         Print("Trade validation failed - disabling SL/TP");
         Print("Entry: ", params.entry_price, " SL: ", params.sl_price, " TP: ", params.tp_price);
        }
      params.sl_price = 0; // Disable invalid SL
      params.tp_price = 0; // Disable invalid TP
     }

// Calculate lot size
   if(config.enable_stop_loss && params.sl_price > 0)
     {
      params.lot_size = validation.CalculateValidLot(params.sl_price, params.entry_price, config.risk_percent_per_trade);
     }
   else
     {
      params.lot_size = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
     }

   if(params.lot_size <= 0 || !validation.CheckMargin(params.lot_size, params.order_type, config.use_max_margin))
     {
      if(config.enable_debug_log)
         Print("Insufficient margin or invalid lot size for ", (params.order_type == ORDER_TYPE_BUY ? "BUY" : "SELL"));
      return;
     }

// Validate SL/TP distances
   if(!validation.ValidateOrderPlacement(params))
     {
      if(config.enable_debug_log)
         Print("Invalid SL/TP for ", (params.order_type == ORDER_TYPE_BUY ? "BUY" : "SELL"),
               ", SL: ", params.sl_price, ", TP: ", params.tp_price, ", Min Stop Level: ", min_stop_distance);
      return;
     }

// Ensure magic number is set
   trade.SetExpertMagicNumber(config.magic);

// Execute trade
   if((params.order_type == ORDER_TYPE_BUY && trade.Buy(params.lot_size, Symbol(), 0.0, params.sl_price, params.tp_price)) ||
      (params.order_type == ORDER_TYPE_SELL && trade.Sell(params.lot_size, Symbol(), 0.0, params.sl_price, params.tp_price)))
     {
      lastTradeTime = TimeCurrent();
      if(config.print_trade_results)
         PrintTradeDetails(trade, m_symbol);
      if(config.enable_debug_log)
         Print("Trade opened: ", (params.order_type == ORDER_TYPE_BUY ? "BUY" : "SELL"),
               ", Lot: ", params.lot_size, ", SL: ", params.sl_price, ", TP: ", params.tp_price);
     }
   else
     {
      Print((params.order_type == ORDER_TYPE_BUY ? "Buy" : "Sell"), " failed. Retcode: ", trade.ResultRetcode(),
            ", description: ", trade.ResultRetcodeDescription());
      if(config.print_trade_results)
         PrintTradeDetails(trade, m_symbol);
     }
  }

//+------------------------------------------------------------------+
//| Count today's trades                                             |
//+------------------------------------------------------------------+
int CountTradesToday()
  {
   int count = 0;
   datetime dayStart = iTime(NULL, PERIOD_D1, 0);
   datetime dayEnd = dayStart + 86400; // Next day

   if(HistorySelect(dayStart, dayEnd))
     {
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++)
        {
         ulong ticket = HistoryDealGetTicket(i);
         if(HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_IN &&
            HistoryDealGetInteger(ticket, DEAL_MAGIC) == config.magic)
           {
            count++;
           }
        }
     }
   if(config.enable_debug_log)
      Print("Trades today: ", count, " (Max: ", config.max_daily_trades, ") on ", TimeToString(dayStart, TIME_DATE));
   return count;
  }

//+------------------------------------------------------------------+
//| Check Breakeven                                                  |
//+------------------------------------------------------------------+
void CheckBreakeven()
  {
   if(!config.enable_stop_loss)
      return;

   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      PositionInfoStruct pos;
      if(!m_position.SelectByIndex(i))
         continue;

      pos.ticket = m_position.Ticket();
      pos.pos_type = (ENUM_POSITION_TYPE)m_position.PositionType();
      pos.open_price = m_position.PriceOpen();
      pos.current_price = (pos.pos_type == POSITION_TYPE_BUY) ? lastTick.bid : lastTick.ask;
      pos.stop_loss = m_position.StopLoss();
      pos.take_profit = m_position.TakeProfit();

      double breakeven_points = config.breakeven_distance * validation.GetPipPoint();

      if(!breakeven_activated &&
         ((pos.pos_type == POSITION_TYPE_BUY && pos.current_price - pos.open_price >= breakeven_points) ||
          (pos.pos_type == POSITION_TYPE_SELL && pos.open_price - pos.current_price >= breakeven_points)))
        {
         double new_sl = NormalizeDouble(pos.open_price, _Digits);
         ENUM_ORDER_TYPE order_type = (pos.pos_type == POSITION_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;

         // Limit modification attempts
         if(modificationAttempts[i] >= 3)
           {
            if(config.enable_debug_log)
               Print("Skipping modification - too many failed attempts for position: ", pos.ticket);
            continue;
           }

         if(validation.ValidateSLModify(order_type, pos.stop_loss, new_sl))
           {
            if(trade.PositionModify(pos.ticket, new_sl, pos.take_profit))
              {
               modificationAttempts[i] = 0; // Reset counter on success
               breakeven_activated = true;
               if(config.enable_debug_log)
                  Print("Breakeven activated for ", (pos.pos_type == POSITION_TYPE_BUY ? "BUY" : "SELL"), " position: ", pos.ticket);
              }
            else
              {
               modificationAttempts[i]++; // Increment on failure
               if(config.enable_debug_log)
                  Print("Breakeven modification failed for position: ", pos.ticket, " Attempt: ", modificationAttempts[i]);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Check for Hedge Opportunities                                    |
//+------------------------------------------------------------------+
void CheckForHedgeOpportunities()
  {
   if(config.max_daily_trades > 0 && CountTradesToday() >= config.max_daily_trades)
     {
      if(config.enable_debug_log)
         Print("Skipping hedging: Daily trade limit reached");
      return;
     }

   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      if(!m_position.SelectByIndex(i))
         continue;

      PositionInfoStruct pos;
      pos.ticket = m_position.Ticket();
      pos.identifier = m_position.Identifier();
      pos.pos_type = (ENUM_POSITION_TYPE)m_position.PositionType();
      pos.open_price = m_position.PriceOpen();
      pos.current_price = m_position.PriceCurrent();
      pos.symbol = m_position.Symbol();
      pos.magic = m_position.Magic();

      if(FindHedgeId(pos.identifier))
         continue;

      double freeze_level, stop_level;
      if(!RefreshSymbolRates(pos.symbol, pos.magic, freeze_level, stop_level))
         continue;

      int digits_adjust = (m_symbol.Digits() == 3 || m_symbol.Digits() == 5) ? 10 : 1;
      double adjusted_point = m_symbol.Point() * digits_adjust;
      double min_stop_distance = stop_level; // Use broker's minimum stop level

      TradeParams hedge_params;
      if(pos.pos_type == POSITION_TYPE_BUY && pos.open_price - pos.current_price >= config.hedge_pips * adjusted_point)
        {
         hedge_params.order_type = ORDER_TYPE_SELL;
         hedge_params.entry_price = pos.current_price;
         hedge_params.sl_price = config.enable_stop_loss ? (pos.current_price + MathMax(config.hedge_pips * adjusted_point, min_stop_distance)) : 0;
         hedge_params.tp_price = 0.0;
         hedge_params.lot_size = validation.CalculateValidLot(hedge_params.sl_price, hedge_params.entry_price,
                                 config.risk_percent_per_trade * config.hedge_lot_multiplier);
         if(hedge_params.lot_size > 0 && OpenSellPosition(hedge_params))
           {
            AddHedgeId(pos.identifier);
            if(config.enable_debug_log)
               Print("Hedge trade opened: SELL, Ticket: ", pos.ticket);
           }
        }
      else
         if(pos.pos_type == POSITION_TYPE_SELL && pos.current_price - pos.open_price >= config.hedge_pips * adjusted_point)
           {
            hedge_params.order_type = ORDER_TYPE_BUY;
            hedge_params.entry_price = pos.current_price;
            hedge_params.sl_price = config.enable_stop_loss ? (pos.current_price - MathMax(config.hedge_pips * adjusted_point, min_stop_distance)) : 0;
            hedge_params.tp_price = 0.0;
            hedge_params.lot_size = validation.CalculateValidLot(hedge_params.sl_price, hedge_params.entry_price,
                                    config.risk_percent_per_trade * config.hedge_lot_multiplier);
            if(hedge_params.lot_size > 0 && OpenBuyPosition(hedge_params))
              {
               AddHedgeId(pos.identifier);
               if(config.enable_debug_log)
                  Print("Hedge trade opened: BUY, Ticket: ", pos.ticket);
              }
           }
     }
  }

//+------------------------------------------------------------------+
//| Close All Positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(string alertMsg)
  {
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      PositionInfoStruct pos;
      pos.ticket = PositionGetTicket(i);
      if(pos.ticket == 0 || !PositionSelectByTicket(pos.ticket))
         continue;

      pos.symbol = PositionGetString(POSITION_SYMBOL);
      if(config.all_symbols || pos.symbol == Symbol())
        {
         if(!trade.PositionClose(pos.ticket, config.slippage))
            Print("Failed to close position ticket ", pos.ticket, ", error: ", trade.ResultRetcode());
         else
            if(config.enable_debug_log)
               Print("Closed position ticket: ", pos.ticket);
        }
     }

   positionClosedThisTick = true;
   if(config.enable_alerts && alertMsg != "")
     {
      Alert(alertMsg);
      Print(alertMsg);
     }
  }

//+------------------------------------------------------------------+
//| Trade Transaction Handler                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result)
  {
   if(PositionsTotal() != config.position_threshold || (config.close_on_profit_only && AccountInfoDouble(ACCOUNT_EQUITY) < balance))
      return;

   if(trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal))
     {
      m_deal.Ticket(trans.deal);
      long deal_entry = -1;
      m_deal.InfoInteger(DEAL_ENTRY, deal_entry);
      if(deal_entry == DEAL_ENTRY_IN)
        {
         string alertMsg = StringFormat("Position Threshold (%d) reached with new entry, closing others", config.position_threshold);
         CloseAllPositions(alertMsg);
        }
     }
  }

//+------------------------------------------------------------------+
//| Calculate Total Profit                                           |
//+------------------------------------------------------------------+
double CalculateTotalProfit()
  {
   double total = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      if(PositionGetTicket(i))
        {
         double profit = PositionGetDouble(POSITION_PROFIT);
         double swap = PositionGetDouble(POSITION_SWAP);
         total += profit + swap;
        }
     }
   return NormalizeDouble(total, 2);
  }

//+------------------------------------------------------------------+
//| Hedging Functions                                                |
//+------------------------------------------------------------------+
bool RefreshSymbolRates(const string symbol, const ulong magic, double &freeze_level, double &stop_level)
  {
   if(!m_symbol.Name(symbol))
      return false;

   trade.SetExpertMagicNumber(magic);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(m_symbol.Name());
   trade.SetDeviationInPoints(config.slippage);

   if(!m_symbol.RefreshRates() || !m_symbol.Refresh() || m_symbol.Ask() == 0 || m_symbol.Bid() == 0)
     {
      if(config.enable_debug_log)
         Print("Symbol refresh failed for ", symbol);
      return false;
     }

   freeze_level = m_symbol.FreezeLevel() * m_symbol.Point();
   if(freeze_level == 0.0)
      freeze_level = (m_symbol.Ask() - m_symbol.Bid()) * 3.0;
   freeze_level *= 1.1;

   stop_level = m_symbol.StopsLevel() * m_symbol.Point();
   if(stop_level == 0.0)
      stop_level = (m_symbol.Ask() - m_symbol.Bid()) * 3.0;
   stop_level *= 1.2; // Increased buffer for stop level

   return (freeze_level > 0.0 && stop_level > 0.0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool FindHedgeId(const long id)
  {
   for(int i = 0; i < ArraySize(hedgeIdArray); i++)
      if(hedgeIdArray[i] == id)
         return true;
   return false;
  }

//+------------------------------------------------------------------+
//| Add Hedge id                                                     |
//+------------------------------------------------------------------+
void AddHedgeId(const long id)
  {
   int size = ArraySize(hedgeIdArray);
   ArrayResize(hedgeIdArray, size + 1, 100);
   hedgeIdArray[size] = id;
  }

//+------------------------------------------------------------------+
//| Open Buy                                                         |
//+------------------------------------------------------------------+
bool OpenBuyPosition(const TradeParams &params)
  {
   double sl = m_symbol.NormalizePrice(params.sl_price);
   double tp = m_symbol.NormalizePrice(params.tp_price);

   AdjustSLTPForStops(ORDER_TYPE_BUY, sl, tp);

// Additional validation - disable SL/TP if invalid
   TradeParams validated_params = params;
   validated_params.sl_price = sl;
   validated_params.tp_price = tp;

   if(!validation.ValidateOrderPlacement(validated_params))
     {
      if(config.enable_debug_log)
         Print("Invalid SL/TP for BUY hedge, disabling stops");
      sl = 0;
      tp = 0;
     }

   double lot_size = params.lot_size;
   if(validation.CheckMargin(lot_size, ORDER_TYPE_BUY, config.use_max_margin))
     {
      if(trade.Buy(lot_size, m_symbol.Name(), 0.0, sl, tp))
        {
         if(config.print_trade_results)
            PrintTradeDetails(trade, m_symbol);
         return true;
        }
      Print("Buy failed. Retcode: ", trade.ResultRetcode(), ", description: ", trade.ResultRetcodeDescription());
      if(config.print_trade_results)
         PrintTradeDetails(trade, m_symbol);
      return false;
     }
   if(config.print_trade_results)
      Print(__FUNCTION__, ", ERROR: Not enough margin. Free: ", DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2));
   return false;
  }

//+------------------------------------------------------------------+
//| Open Sell                                                        |
//+------------------------------------------------------------------+
bool OpenSellPosition(const TradeParams &params)
  {
   double sl = m_symbol.NormalizePrice(params.sl_price);
   double tp = m_symbol.NormalizePrice(params.tp_price);

   AdjustSLTPForStops(ORDER_TYPE_SELL, sl, tp);

// Additional validation - disable SL/TP if invalid
   TradeParams validated_params = params;
   validated_params.sl_price = sl;
   validated_params.tp_price = tp;

   if(!validation.ValidateOrderPlacement(validated_params))
     {
      if(config.enable_debug_log)
         Print("Invalid SL/TP for SELL hedge, disabling stops");
      sl = 0;
      tp = 0;
     }

   double lot_size = params.lot_size;
   if(validation.CheckMargin(lot_size, ORDER_TYPE_SELL, config.use_max_margin))
     {
      if(trade.Sell(lot_size, m_symbol.Name(), 0.0, sl, tp))
        {
         if(config.print_trade_results)
            PrintTradeDetails(trade, m_symbol);
         return true;
        }
      Print("Sell failed. Retcode: ", trade.ResultRetcode(), ", description: ", trade.ResultRetcodeDescription());
      if(config.print_trade_results)
         PrintTradeDetails(trade, m_symbol);
      return false;
     }
   if(config.print_trade_results)
      Print(__FUNCTION__, ", ERROR: Not enough margin. Free: ", DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2));
   return false;
  }

//+------------------------------------------------------------------+
//| Print Trade Details                                              |
//+------------------------------------------------------------------+
void PrintTradeDetails(CTrade &ctrade, CSymbolInfo &symbol)
  {
   Print("File: ", __FILE__, ", symbol: ", symbol.Name());
   Print("Request result code: ", ctrade.ResultRetcode(), ", description: ", ctrade.ResultRetcodeDescription());
   Print("Deal ticket: ", ctrade.ResultDeal(), ", Order ticket: ", ctrade.ResultOrder());
   Print("Volume: ", DoubleToString(ctrade.ResultVolume(), 2));
   Print("Confirmed price: ", DoubleToString(ctrade.ResultPrice(), symbol.Digits()));
   Print("Current bid: ", DoubleToString(symbol.Bid(), symbol.Digits()),
         " (requote): ", DoubleToString(ctrade.ResultBid(), symbol.Digits()));
   Print("Current ask: ", DoubleToString(symbol.Ask(), symbol.Digits()),
         " (requote): ", DoubleToString(ctrade.ResultAsk(), symbol.Digits()));
   Print("Broker comment: ", ctrade.ResultComment());
  }

//+------------------------------------------------------------------+
//| Position Exists                                                  |
//+------------------------------------------------------------------+
bool IsPositionExists()
  {
   return PositionsTotal() > 0;
  }

//+------------------------------------------------------------------+
//| Label Functions                                                  |
//+------------------------------------------------------------------+
void CreateLabel()
  {
   ObjectDelete(chartID, "PLabel");

   int chartWidth = (int)ChartGetInteger(chartID, CHART_WIDTH_IN_PIXELS);
   int chartHeight = (int)ChartGetInteger(chartID, CHART_HEIGHT_IN_PIXELS);
   int xDistance = MathMin(config.label_x_distance, chartWidth - 210);
   int yDistance = MathMin(config.label_y_distance, chartHeight - 30);

   if(!ObjectCreate(chartID, "PLabel", OBJ_LABEL, 0, 0, 0))
     {
      Print("Failed to create label, error: ", GetLastError());
      Comment("P/L: Label creation failed");
      return;
     }

   ObjectSetInteger(chartID, "PLabel", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(chartID, "PLabel", OBJPROP_XDISTANCE, xDistance);
   ObjectSetInteger(chartID, "PLabel", OBJPROP_YDISTANCE, yDistance);
   ObjectSetInteger(chartID, "PLabel", OBJPROP_FONTSIZE, 14);
   ObjectSetInteger(chartID, "PLabel", OBJPROP_COLOR, clrWhite);
   ObjectSetString(chartID, "PLabel", OBJPROP_FONT, "Arial");
   ObjectSetInteger(chartID, "PLabel", OBJPROP_BACK, false);
   ObjectSetInteger(chartID, "PLabel", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chartID, "PLabel", OBJPROP_HIDDEN, false);
   ObjectSetInteger(chartID, "PLabel", OBJPROP_ZORDER, 1);
   ObjectSetString(chartID, "PLabel", OBJPROP_TEXT, "P/L: Initializing...");

   ChartRedraw(chartID);
  }

//+------------------------------------------------------------------+
//| Update Label                                                     |
//+------------------------------------------------------------------+
void UpdateLabel(double profit, double percent)
  {
   if(ObjectFind(chartID, "PLabel") < 0)
      CreateLabel();

   string text = StringFormat("P/L: $%.2f (%.1f%%)", profit, percent);
   ObjectSetString(chartID, "PLabel", OBJPROP_TEXT, text);
   ObjectSetInteger(chartID, "PLabel", OBJPROP_COLOR, profit >= 0 ? clrLime : clrRed);

   ChartRedraw(chartID);
  }

//+------------------------------------------------------------------+
//| Cleanup on Deinit                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("EA Deinitialized, Reason: ", reason);
   ObjectDelete(chartID, "PLabel");
   ChartRedraw(chartID);
   Comment("");
   ArrayFree(hedgeIdArray);
   if(atr_handle != INVALID_HANDLE)
      IndicatorRelease(atr_handle);
   if(validation != NULL)
     {
      delete validation;
      validation = NULL;
     }
  }

//+------------------------------------------------------------------+
//| MIT License                                                     |
//+------------------------------------------------------------------+
/* Copyright (c) 2025 Lupus Materia Ltd
   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED to the WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH the SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
*/
//+------------------------------------------------------------------+
