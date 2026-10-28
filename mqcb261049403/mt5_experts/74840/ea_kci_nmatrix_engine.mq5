/*          // 24/10/2023 16:23:59 ~ 06/25/2026 -
//+------------------------------------------------------------------+
//|                         DISCLAIMER                               |
//+------------------------------------------------------------------+

  Trading Risk Notice
  -------------------
  Trading in the financial markets, including Forex, CFDs,
  Futures, Stocks, and Cryptocurrencies, involves substantial risk
  and may not be suitable for all investors.

  Past performance is not indicative of future results. No trading
  strategy, indicator, or Expert Advisor (EA) can guarantee profits
  or eliminate the risk of financial loss.

  This software is provided solely for educational, informational,
  and research purposes. Nothing contained in this project should
  be interpreted as financial, investment, legal, or tax advice.

  Users are solely responsible for evaluating the suitability of
  this software, managing their own trading decisions, and accepting
  all associated risks. The author and contributors assume no
  liability for any direct or indirect losses resulting from the
  use or misuse of this software.


  Development Notice
  ------------------
  This Expert Advisor (EA) is an ongoing development project and
  should not be considered a finished or production-ready trading
  system.

  The software is continuously being developed, tested, optimized,
  and validated. Trading logic, risk management, and other features
  may change without prior notice, and unexpected behavior or
  software defects may exist.

  This EA is NOT intended for live trading in its current state.
  It is designed as a technical demonstration, research project,
  and development reference only.

  Before any live deployment, users should perform extensive
  independent testing using the MetaTrader Strategy Tester,
  forward testing on a demo account, and their own validation.

  By downloading, compiling, or using this software, you acknowledge
  and accept that all usage is entirely at your own risk.

//+------------------------------------------------------------------+
*/

//+------------------------------------------------------------------+
//| Project    : Generation of KCI indicators                        |
//|              as automated trading material                       |
//| Objective  : Development                                         |
//| Module     : Trading Engine                                      |
//| Version    : 1.0                                                 |
//| Author     : https://www.mql5.com/en/users/ritzfalih             |
//| Copyright  : (C) 2023 - 2026                                     |
//| Description: Core trading logic and risk management module.      |
//+------------------------------------------------------------------+

//--------- Testing new project indicators [codebase] ---------------
//-------------------------------------------------------------------
//          1. KCI Standard/custom (oscillator) [Publish] [engine for EA]
//          2. KCI VR (Volatility Range) (Oscillator) [Publish] [engine for EA]
//          3. KCI Trend (Chart Window) [Market] [engine for EA]
// ------------------------ https://www.mql5.com/en/market/product/185095
//          4. KCI Arrow (Chart Window) [Market]
// ------------------------ https://www.mql5.com/en/market/product/185094
//          5. KCI Candle (Chart Window) [Market]
// ------------------------ https://www.mql5.com/en/market/product/185093
//          5. KCI DX (Directional Matrix) (Oscillator) [Publish] [engine for EA]

//+------------------------------------------------------------------+
//|                                    KCI Native Matrix Engine .mq5 |
//|                           Copyright 2026, KCI Standard Developer |
//+------------------------------------------------------------------+
#property copyright   "Copyright©2026. Ritz EAneha"
#property link        "https://www.mql5.com/en/users/ritzfalih"
#property version     "1.1"
#property description "KCI Native Matrix Engine"
#property description "EA Standalone: Pure KCI Zero-Line Breakout & Hold Strategy"
#property description "Embedded Native KVR SL/TP, KCI Trend MTF Filter, Trailing (INSTANT TRIGGER NATIVE)"

enum ENUM_LOT_MODE
  {
   LOT_FIXED,      // Fixed lot size
   LOT_RISK        // Risk % of balance
  };
  
// ----------- Aggressive KCI
input group "=== KCI Computing Core ==="
input int    ZScorePeriod          = 30;   // Z-Score period 
input double CompressionThreshold  = 2.0;  // Compression threshold (std:2.0)
input int    BasePeriod            = 9;    // Base period

/* // -------- Moderat KCI
input group "=== KCI Computing Core ==="
input int    ZScorePeriod          = 60;   // Z-Score period 
input double CompressionThreshold  = 1.8;  // Compression threshold
input int    BasePeriod            = 21;   // Base period
*/

input group "=== KCI Trend Filter (MTF) ==="
input bool   InpUseTrendFilter   = true;       // Enable KCI Trend Filter
input ENUM_TIMEFRAMES InpTrendTF = PERIOD_H1;   // KCI Trend Timeframe
input int    InpTrendBasePeriod  = 34;          // KCI Trend Base Period

// input bool   InpUseTrendFilter   = false;       // Enable KCI Trend Filter (false=Aggressive)

input group "=== KCI Signal Confirmation ==="
input group "--Minimum slope of KCI Trend (in Points) for validation (check digit symbol)--"
input group "=== KCI Signal Confirmation ==="
input double InpMinTrendSlopePoints    = 500.0;    // Minimum slope of KCI Trend (Points)
input bool   InpContinuousEntry        = true;     // TRUE = Chain entry during valid trend & momentum
input double InpMaxTrendDistancePoints = 1000.0;   // Maximum price distance from KCI Trend Line (Points)

/*
input group "=== KCI Signal Confirmation ===" // Aggressive
input double InpMinTrendSlopePoints    = 275.0;    // Kemiringan minimal KCI Trend (Points)
input bool   InpContinuousEntry        = true;     // TRUE = Entry berantai selama trend & momentum valid
input double InpMaxTrendDistancePoints = 300.0;    // Maksimal jarak harga dari KCI Trend Line (Points)
*/

input group "=== Trade Execution ==="
input ulong  InpMagicNumber  = 77720265;   // Magic number
input int    InpSlippage     = 10;         // Maximum slippage
input int    InpMaxSpread    = 100;        // Maximum spread (points)

input group "=== Money Management & Risk ==="
input ENUM_LOT_MODE InpLotMode = LOT_RISK; // Lot mode
input double InpLotSize      = 0.01;       // Fixed lot size (if mode = Fixed)
input double InpRiskPercent  = 1.0;        // Risk % per trade (if mode = Risk)
input int    InpKVRPeriod    = 14;         // KVR period (Embedded Native)
input double InpKVRMultiplierSL = 2.0;     // STOP LOSS multiplier (KVR) (12.0=Grid/hedge Survival)
input double InpKVRMultiplierTP = 3.0;     // TAKE PROFIT multiplier (KVR) (Single entry target)

// input double InpKVRMultiplierSL = 12.0;     // SL multiplier (KVR) (12.0=Grid/hedge Survival) for activate Averaging/hedging

input group "=== Averaging & Hedging (Grid Core) ==="
input bool   InpUseAveraging     = false;  // Enable One-way Averaging (false=single)
input double InpAveragingKVRStep = 2.0;    // Averaging Distance (in KVR multipliers)
input double InpLotMultiplier    = 1.3;    // Multiplier Lot for Averaging/Hedging
input int    InpMaxPositions     = 10;     // MAXIMUM total open positions per direction
input bool   InpHedgeOnSignal    = false;  // (true=for>) Opposite signal opens Hedge position (false=single)

input group "=== Moderat Trailing Stop (KVR-based) ==="
input bool   InpUseKVRTrailing = true;     // Enable KVR trailing
input double InpKVRTrailingStart = 1.0;    // Trailing start (KVR units) > HC Profit so as not to race
input double InpKVRTrailingStep  = 0.05;   // Slide SL every time the price moves (KVR units)
input double InpKVRTrailingStop  = 0.1;    // Trailing stop distance (KVR units)

/* // --------- Trailing Single entry
input group "=== Aggresive Trailing Stop (KVR-based) ===" // FOR RAW/ZERO ACCOUNT
input bool   InpUseKVRTrailing = true;       // Enable KVR trailing
input double InpKVRTrailingStart = 0.8;      // Trailing start (KVR units) > HC Profit so as not to race
input double InpKVRTrailingStep  = 0.05;     // Slide SL every time the price moves (KVR units)
input double InpKVRTrailingStop  = 0.08;     // Trailing stop distance (KVR units)
*/

input group "=== Hard Close Profit ==="
input bool   InpUseHardCloseProfit = false;  // Enable hard close profit
input double InpHardCloseProfitKVR = 2.5;    // Profit target (KVR) realistic for mass close basket

// input double InpHardCloseProfitKVR = 1.0;    // Aggressive Profit target (KVR) realistic for mass close basket

input group "=== Daily Limits ==="
input bool   InpUseDailyLimit = false;      // Daily Limit en|dis
input double InpDailyLossPercent = 10.0;    // Limit daily losses to a maximum of 10%.
input double InpDailyDrawdownPercent = 5.0; // Maximum floating drawdown 5%.

//--- Global Engine Variables
ulong          g_magic;
ulong          g_slippage;

//--- KCI Engine Buffers
double         vq[], kd[], ed[], pv[], Raw_KCI[], Polar_KCI[];
double         decay_constant;

//--- Daily Limit Variables
datetime       g_last_day = 0;
double         g_start_equity = 0;
double         g_daily_max_equity = 0;
bool           g_trade_allowed = true;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_magic = InpMagicNumber;
   g_slippage = InpSlippage;

// Allocate memory for KCI Core Engine
   int total_bars = ZScorePeriod + BasePeriod + 10;
   ArrayResize(vq, total_bars);
   ArraySetAsSeries(vq, true);
   ArrayResize(kd, total_bars);
   ArraySetAsSeries(kd, true);
   ArrayResize(ed, total_bars);
   ArraySetAsSeries(ed, true);
   ArrayResize(pv, total_bars);
   ArraySetAsSeries(pv, true);
   ArrayResize(Raw_KCI, 5);
   ArraySetAsSeries(Raw_KCI, true);
   ArrayResize(Polar_KCI, 5);
   ArraySetAsSeries(Polar_KCI, true);

   decay_constant = 0.22314355 / CompressionThreshold;

// Initialize daily tracking
   ResetDailyIfNewDay();

   Print("KCI Native Matrix Engine (INSTANT TRIGGER NATIVE) Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("KCI Native Matrix Engine Shutdown. Reason: ", reason);
  }

//+------------------------------------------------------------------+
//| Check New Signal (Hedge Lot Sizing)                              |
//+------------------------------------------------------------------+
void CheckNewSignal()
  {
   int signal = GetSignal();
   if(signal == 0) return;

   int count_buy = 0, count_sell = 0;
   double max_lot_buy = 0, max_lot_sell = 0;

   // 1. Calculate the position and find the LARGEST LOT from each direction
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == g_magic)
        {
         double vol = PositionGetDouble(POSITION_VOLUME);
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           { 
            count_buy++; 
            if(vol > max_lot_buy) max_lot_buy = vol; 
           }
         else
           { 
            count_sell++; 
            if(vol > max_lot_sell) max_lot_sell = vol; 
           }
        }
     }

   double kvr = GetKVR(0);
   if(kvr <= 0) return;
   MqlTick tick; SymbolInfoTick(_Symbol, tick);

   // -----------------------------------------------------------------
   // BUY Signal Execution
   // -----------------------------------------------------------------
   if(signal == 1 && count_buy == 0)
     {
      if(!InpHedgeOnSignal && count_sell > 0) 
        {
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong tkt = PositionGetTicket(i);
            if(PositionSelectByTicket(tkt) && PositionGetInteger(POSITION_MAGIC) == g_magic && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
               NativeClosePosition(tkt);
           }
         count_sell = 0; 
        }
        
      double base_lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
      
      // Multiply the lot from the MAX LOT Sell that is currently lagging
      double lot = (count_sell > 0 && InpHedgeOnSignal) ? NormalizeVolume(max_lot_sell * InpLotMultiplier) : base_lot;
      
      double sl = tick.ask - (kvr * InpKVRMultiplierSL);
      double tp = tick.ask + (kvr * InpKVRMultiplierTP);
      string comment = (count_sell > 0 && InpHedgeOnSignal) ? "KCI BUY Hedge Rescue" : "KCI BUY Sniper";
      
      NativeOpenPosition(ORDER_TYPE_BUY, lot, tick.ask, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), comment);
     }
     
   // -----------------------------------------------------------------
   // SELL Signal Execution
   // -----------------------------------------------------------------
   if(signal == -1 && count_sell == 0)
     {
      if(!InpHedgeOnSignal && count_buy > 0) 
        {
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong tkt = PositionGetTicket(i);
            if(PositionSelectByTicket(tkt) && PositionGetInteger(POSITION_MAGIC) == g_magic && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
               NativeClosePosition(tkt);
           }
         count_buy = 0; 
        }
        
      double base_lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
      
      // Multiply the lot from the MAX LOT Buy that is currently lagging
      double lot = (count_buy > 0 && InpHedgeOnSignal) ? NormalizeVolume(max_lot_buy * InpLotMultiplier) : base_lot;
      
      double sl = tick.bid + (kvr * InpKVRMultiplierSL);
      double tp = tick.bid - (kvr * InpKVRMultiplierTP);
      string comment = (count_buy > 0 && InpHedgeOnSignal) ? "KCI SELL Hedge Rescue" : "KCI SELL Sniper";
      
      NativeOpenPosition(ORDER_TYPE_SELL, lot, tick.bid, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), comment);
     }
  }
  
//+------------------------------------------------------------------+
//| NATIVE TRADE ENGINE (HFT-Level Routing)                          |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetFillingMode()
  {
   int filling = (int)SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   if((filling & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
      return ORDER_FILLING_FOK;
   if((filling & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
      return ORDER_FILLING_IOC;
   return ORDER_FILLING_RETURN;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NativeOpenPosition(ENUM_ORDER_TYPE type, double volume, double price, double sl, double tp, string comment)
  {
   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};

   request.action       = TRADE_ACTION_DEAL;
   request.symbol       = _Symbol;
   request.volume       = volume;
   request.type         = type;
   request.price        = price;
   request.sl           = sl;
   request.tp           = tp;
   request.deviation    = g_slippage;
   request.magic        = g_magic;
   request.comment      = comment;
   request.type_filling = GetFillingMode();

   bool sent = OrderSend(request, result);
   if(!sent)
      Print("Native OrderSend Error: ", GetLastError(), " | Retcode: ", result.retcode);
   return sent;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NativeClosePosition(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket))
      return false;

   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};

   request.action       = TRADE_ACTION_DEAL;
   request.position     = ticket;
   request.symbol       = PositionGetString(POSITION_SYMBOL);
   request.volume       = PositionGetDouble(POSITION_VOLUME);

   ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   request.type         = (pos_type == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;

   MqlTick tick;
   if(!SymbolInfoTick(request.symbol, tick))
      return false;
   request.price        = (request.type == ORDER_TYPE_SELL) ? tick.bid : tick.ask;

   request.deviation    = g_slippage;
   request.magic        = g_magic;
   request.type_filling = GetFillingMode();

   bool sent = OrderSend(request, result);
   if(!sent)
      Print("Native Close Error: ", GetLastError(), " | Retcode: ", result.retcode);
   return sent;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NativeModifyPosition(ulong ticket, double sl, double tp)
  {
   MqlTradeRequest request = {};
   MqlTradeResult  result  = {};

   request.action    = TRADE_ACTION_SLTP;
   request.position  = ticket;
   request.symbol    = PositionGetString(POSITION_SYMBOL);
   request.sl        = sl;
   request.tp        = tp;
   request.magic     = g_magic;

   bool sent = OrderSend(request, result);
   if(!sent)
      Print("Native Modify Error: ", GetLastError(), " | Retcode: ", result.retcode);
   return sent;
  }

//+------------------------------------------------------------------+
//| Get KVR Value (Embedded Native Engine)                           |
//+------------------------------------------------------------------+
double GetKVR(int shift = 0)
  {
   int period = InpKVRPeriod;
   if(period < 2)
      return 0.0;

   double close_prices[];
   ArraySetAsSeries(close_prices, true);

   if(CopyClose(_Symbol, _Period, shift, period + 1, close_prices) < period + 1)
      return 0.0;

   double sum_price = 0.0;
   double path_length = 0.0;

   double net_distance = MathAbs(close_prices[0] - close_prices[period - 1]);

   for(int j = 0; j < period; j++)
     {
      sum_price += close_prices[j];
      if(j < period - 1)
         path_length += MathAbs(close_prices[j] - close_prices[j + 1]);
     }

   if(path_length == 0.0)
      path_length = _Point;

   double mean_price = sum_price / period;
   double variance_sum = 0.0;

   for(int j = 0; j < period; j++)
     {
      variance_sum += MathPow(close_prices[j] - mean_price, 2);
     }

   double std_dev = MathSqrt(variance_sum / period);
   double efficiency_ratio = net_distance / path_length;

   return std_dev * (2.0 - efficiency_ratio);
  }

//+------------------------------------------------------------------+
//| Embedded KCI Trend Filter (MTF Standalone)                       |
//+------------------------------------------------------------------+
int GetMTFKCITrend(ENUM_TIMEFRAMES tf, int base_period, int shift = 1)
  {
   if(base_period < 1)
      return 0;

   double close_prices[];
   ArraySetAsSeries(close_prices, true);

   if(CopyClose(_Symbol, tf, shift, base_period, close_prices) < base_period)
      return 0;

   double sum_price = 0;
   for(int j = 0; j < base_period; j++)
      sum_price += close_prices[j];

   double mean_price = sum_price / base_period;
   double kd_polarity = close_prices[0] - mean_price;

   if(kd_polarity >= 0.0)
      return 1;
   if(kd_polarity < 0.0)
      return -1;

   return 0;
  }

//+------------------------------------------------------------------+
//| Custom Z-Score                                                   |
//+------------------------------------------------------------------+
double GetZScoreCustom(const double &data_array[], int start_index, int period)
  {
   if(period < 2)
      return 0.0;
   double sum = 0.0, mean = 0.0, variance = 0.0, std_dev = 0.0;

   for(int i = 0; i < period; i++)
      sum += data_array[start_index + i];
   mean = sum / period;

   for(int i = 0; i < period; i++)
      variance += MathPow(data_array[start_index + i] - mean, 2);
   variance = variance / period;
   std_dev = MathSqrt(variance);

   if(std_dev == 0)
      return 0.0;
   return (data_array[start_index] - mean) / std_dev;
  }

//+------------------------------------------------------------------+
//| KCI Core Engine (with Diagonal Slope & Mean Extraction)          |
//+------------------------------------------------------------------+
void GetEmbeddedKCIData(double &out_ed, double &kci_bar0, double &kci_bar1, double &out_mean_slope, double &out_current_mean)
  {
   int total_bars = ZScorePeriod + BasePeriod + 10;
   double close_prices[];
   ArraySetAsSeries(close_prices, true);

   if(CopyClose(_Symbol, _Period, 0, total_bars, close_prices) < total_bars)
      return;

   double mean_buffer[4]; // Temporary buffer to track the last 4 candles

   for(int i = total_bars - BasePeriod - 1; i >= 0; i--)
     {
      double sum_price = 0, path_length = 0.000001;
      double net_dist = close_prices[i] - close_prices[i + BasePeriod];

      for(int j = 0; j < BasePeriod; j++)
        {
         sum_price += close_prices[i + j];
         path_length += MathAbs(close_prices[i + j] - close_prices[i + j + 1]);
        }

      double mean_price = sum_price / BasePeriod;
      
      // Save the mean value of the last 4 candles for slope calculation
      if(i < 4) mean_buffer[i] = mean_price; 

      double variance_price = 0;
      for(int j = 0; j < BasePeriod; j++)
         variance_price += MathPow(close_prices[i + j] - mean_price, 2);

      vq[i] = net_dist / path_length;
      kd[i] = close_prices[i] - mean_price;
      ed[i] = MathSqrt(variance_price / BasePeriod);
      pv[i] = net_dist;
     }

   for(int i = 4; i >= 0; i--)
     {
      double z_vq = GetZScoreCustom(vq, i, ZScorePeriod);
      double z_kd = GetZScoreCustom(kd, i, ZScorePeriod);
      double z_ed = GetZScoreCustom(ed, i, ZScorePeriod);
      double z_pv = GetZScoreCustom(pv, i, ZScorePeriod);

      Raw_KCI[i] = MathAbs(z_vq-z_kd) + MathAbs(z_vq-z_ed) + MathAbs(z_vq-z_pv) +
                   MathAbs(z_kd-z_ed) + MathAbs(z_kd-z_pv) + MathAbs(z_ed-z_pv);

      double direction = (kd[i] >= 0) ? 1.0 : -1.0;
      Polar_KCI[i] = 100.0 * MathExp(-decay_constant * Raw_KCI[i]) * direction;
     }

   out_ed = ed[0];
   kci_bar0 = Polar_KCI[0];
   kci_bar1 = Polar_KCI[1];
   
   // Calculate the Slope/Diagonal Momentum
   out_mean_slope = (mean_buffer[0] - mean_buffer[3]) / 3.0 / _Point;
   
   // export current trend line kci values for distance filter
   out_current_mean = mean_buffer[0];
  }

//+------------------------------------------------------------------+
//| Get Trading Signal (INSTANT TRIGGER + DIAGONAL + OVER-EXT FILTER)|
//+------------------------------------------------------------------+
int GetSignal()
  {
   double current_ed, kci_bar0, kci_bar1, mean_slope_points, current_mean;
   
   // Call the data that has been updated with its arguments
   GetEmbeddedKCIData(current_ed, kci_bar0, kci_bar1, mean_slope_points, current_mean);
   if(current_ed == 0) return 0;

   bool is_uptrend = true;
   bool is_downtrend = true;

   // 1. External MTF Trend KCI Validation
   if(InpUseTrendFilter)
     {
      int kci_trend = GetMTFKCITrend(InpTrendTF, InpTrendBasePeriod, 1);
      if(kci_trend != 1) is_uptrend = false;
      if(kci_trend != -1) is_downtrend = false;
     }

   // 2. KCI Polar Status (Is it in the positive/negative zone?)
   bool state_up = (kci_bar0 > 0.0);
   bool state_dn = (kci_bar0 < 0.0);

   // 3. Pure Cross Status (Only detected right when it breaks through 0)
   bool cross_up = (kci_bar1 <= 0.0 && state_up);
   bool cross_dn = (kci_bar1 >= 0.0 && state_dn);

   // 4. Trigger Mode Selection Based on Input
   bool trigger_up = InpContinuousEntry ? state_up : cross_up;
   bool trigger_dn = InpContinuousEntry ? state_dn : cross_dn;

   // 5. Diagonal Momentum Validation (Kinetic Slope)
   bool momentum_up = (mean_slope_points >= InpMinTrendSlopePoints);
   bool momentum_dn = (mean_slope_points <= -InpMinTrendSlopePoints);

   // 6. OVER-EXTENSION PROTECTION (RUBBER BAND EFFECT FILTER)
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return 0;
   
   // Calculates the absolute distance between the current price and the KCI Trend line
   double distance_buy_points  = (tick.ask - current_mean) / _Point;
   double distance_sell_points = (current_mean - tick.bid) / _Point;

   // If the distance is too far, mark it as overextended (trend exhaustion)
   bool overextended_up = (InpMaxTrendDistancePoints > 0 && distance_buy_points > InpMaxTrendDistancePoints);
   bool overextended_dn = (InpMaxTrendDistancePoints > 0 && distance_sell_points > InpMaxTrendDistancePoints);

   // DECISION ENGINE
   // Must be aligned: Trigger + MTF Trend + Momentum Diagonal + NOT Overextended   
   // Block BUY if the price is too high to leave equilibrium
   if(trigger_up && is_uptrend && momentum_up && !overextended_up) return 1;
   
   // Block SELL if the price is too low to leave equilibrium
   if(trigger_dn && is_downtrend && momentum_dn && !overextended_dn) return -1;

   return 0; // Returns neutral if momentum is lost, trend reverses, or price is exhausted
  }
  
//+------------------------------------------------------------------+
//| Calculate Lot Size by Risk                                       |
//+------------------------------------------------------------------+
double CalculateLotByRisk(double sl_distance_price)
  {
   if(InpLotMode == LOT_FIXED)
      return InpLotSize;

   sl_distance_price = MathAbs(sl_distance_price);
   if(sl_distance_price == 0.0)
      return InpLotSize;

   double riskPercent = InpRiskPercent / 100.0;
   double riskMoney   = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent;

   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize == 0.0 || tickValue == 0.0)
      return InpLotSize;

   double sl_ticks = sl_distance_price / tickSize;
   if(sl_ticks <= 0.0)
      return InpLotSize;

   double lot = riskMoney / (sl_ticks * tickValue);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(lotStep == 0.0)
      lotStep = 0.01;

   lot = MathFloor(lot / lotStep) * lotStep;
   double lotMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double lotMax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lot = MathMax(lot, lotMin);
   lot = MathMin(lot, lotMax);

   return lot;
  }

//+------------------------------------------------------------------+
//| Foolproof Lot Multiplier                                         |
//+------------------------------------------------------------------+
double GetMultipliedLot(double current_lot)
  {
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   // 1. Basic calculations with multipliers
   double calculated = current_lot * InpLotMultiplier;
   
   // 2. Add a small Epsilon (0.0001) to counter the 1.499999 error
   double new_lot = MathRound((calculated + (step * 0.0001)) / step) * step;
   
   // 3. IRON RULE: If Multiplier > 1.0, the lot MUST increase! 
   // If for any reason the new lot is still the same/smaller than the old lot, 
   // we force the volume to increase by 1 step (for example from 0.01 to 0.02)
   if(InpLotMultiplier > 1.0 && new_lot <= current_lot)
     {
      new_lot = current_lot + step;
     }
     
   // 4. Make sure you do not exceed the broker's maximum/minimum limits.
   if(new_lot < min_lot) new_lot = min_lot;
   if(new_lot > max_lot) new_lot = max_lot;
   
   // NormalizeDouble ensures the decimal format is ready to be sent to the server
   return NormalizeDouble(new_lot, 2);
  }
  
//+------------------------------------------------------------------+
//| Daily Limit Functions                                            |
//+------------------------------------------------------------------+
void ResetDailyIfNewDay()
  {
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   datetime day_start = StringToTime(TimeToString(now, TIME_DATE));
   if(day_start > g_last_day)
     {
      g_last_day = day_start;
      g_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_daily_max_equity = g_start_equity;
      g_trade_allowed = true;
      Print("New day. Start equity: ", DoubleToString(g_start_equity, 2));
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckDailyLimits()
  {
   ResetDailyIfNewDay();
   if(!g_trade_allowed || !InpUseDailyLimit)
      return;

   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(current_equity > g_daily_max_equity)
      g_daily_max_equity = current_equity;

   double lossPercent = (g_start_equity - current_equity) / g_start_equity * 100.0;
   if(lossPercent >= InpDailyLossPercent)
     {
      g_trade_allowed = false;
      Print("Daily loss limit reached. Trading stopped.");
      return;
     }

   double drawdownPercent = (g_daily_max_equity - current_equity) / g_daily_max_equity * 100.0;
   if(drawdownPercent >= InpDailyDrawdownPercent)
     {
      g_trade_allowed = false;
      Print("Daily drawdown limit reached. Trading stopped.");
     }
  }

//+------------------------------------------------------------------+
//| Manage Trailing Stop (KVR-based NATIVE)                          |
//+------------------------------------------------------------------+
void ManageTrailingStop()
  {
   if(!InpUseKVRTrailing)
      return;
   double kvr = GetKVR(0);
   if(kvr <= 0)
      return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == g_magic)
        {
         double price = PositionGetDouble(POSITION_PRICE_CURRENT);
         double sl = PositionGetDouble(POSITION_SL);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double tp = PositionGetDouble(POSITION_TP);

         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            double profit_points = (price - open_price) / _Point;
            if(profit_points >= InpKVRTrailingStart * kvr / _Point)
              {
               double new_sl = price - InpKVRTrailingStop * kvr;
               if(new_sl > sl + InpKVRTrailingStep * kvr)
                 {
                  if(new_sl > sl)
                     NativeModifyPosition(ticket, NormalizeDouble(new_sl, _Digits), NormalizeDouble(tp, _Digits));
                 }
              }
           }
         else // SELL
           {
            double profit_points = (open_price - price) / _Point;
            if(profit_points >= InpKVRTrailingStart * kvr / _Point)
              {
               double new_sl = price + InpKVRTrailingStop * kvr;
               if(new_sl < sl - InpKVRTrailingStep * kvr)
                 {
                  if(new_sl < sl || sl == 0)
                     NativeModifyPosition(ticket, NormalizeDouble(new_sl, _Digits), NormalizeDouble(tp, _Digits));
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Get Real Commission from Deal History (Bypass Deprecation)       |
//+------------------------------------------------------------------+
double GetPositionCommission(ulong position_ticket)
  {
   double commission = 0.0;
   
   // Open transaction history specific to this position only
   if(HistorySelectByPosition(position_ticket))
     {
      int deals = HistoryDealsTotal();
      for(int i = 0; i < deals; i++)
        {
         ulong deal_ticket = HistoryDealGetTicket(i);
         if(deal_ticket > 0)
           {
            commission += HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
           }
        }
     }
     
   return commission;
  }

//+------------------------------------------------------------------+
//| High Precision Volume Normalization (Prevents Lot Stagnation)    |
//+------------------------------------------------------------------+
double NormalizeVolume(double vol)
  {
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   // Use MathRound to round fractional lots (e.g. 0.015) up to 0.02
   double normalized = MathRound(vol / step) * step; 
   
   if(normalized < min_lot) normalized = min_lot;
   if(normalized > max_lot) normalized = max_lot;
   
   return normalized;
  }

//+------------------------------------------------------------------+
//| Virtual Basket Close (GLOBAL UNIFIED RECOVERY)                   |
//+------------------------------------------------------------------+
void CheckBasketClose()
  {
   if(!InpUseHardCloseProfit || PositionsTotal() == 0) return;
   
   double kvr = GetKVR(0);
   if(kvr <= 0) return;

   double global_net_profit = 0.0;
   double actual_base_lot = 99999.0;
   int total_magic_positions = 0;

   // 1. Calculation of Global Net Profit (Cross Subsidy Buy & Sell)
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == g_magic)
        {
         total_magic_positions++;
         double vol    = PositionGetDouble(POSITION_VOLUME);
         
         // Take real profit including fee deductions
         double profit = PositionGetDouble(POSITION_PROFIT) + 
                         PositionGetDouble(POSITION_SWAP) + 
                         GetPositionCommission(ticket);
         
         global_net_profit += profit;
         
         // The smallest lot key as a reference for the Base Lot
         if(vol < actual_base_lot) actual_base_lot = vol; 
        }
     }

   if(total_magic_positions == 0 || actual_base_lot == 99999.0) return;

   // 2. Calculation of Monetary Target Based on Base Lot
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tick_size == 0.0 || tick_value == 0.0) return;

   double target_points = (InpHardCloseProfitKVR * kvr) / tick_size;
   double target_money_base = target_points * tick_value * actual_base_lot;

   // 3. GLOBAL CLEAN SWEEP EXECUTION
   // If the total profit from the large lot has successfully covered the Major Entry loss
   if(global_net_profit >= target_money_base)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong tkt = PositionGetTicket(i);
         if(PositionSelectByTicket(tkt) && PositionGetInteger(POSITION_MAGIC) == g_magic)
            NativeClosePosition(tkt);
        }
      Print("KCI GLOBAL BASKET Reached Target: ", DoubleToString(global_net_profit, 2), " | Mayor Entry Successfully Rescued!");
     }
  }

//+------------------------------------------------------------------+
//| Execution Averaging Multiplier (NATIVE SL/TP Restored)           |
//+------------------------------------------------------------------+
void CheckAveragingEntry()
  {
   if(!InpUseAveraging) return;
   double kvr = GetKVR(0);
   if(kvr <= 0) return;

   double lowest_buy_price = 0, highest_sell_price = 0;
   double max_buy_lot = 0, max_sell_lot = 0;
   int buy_count = 0, sell_count = 0;

   for(int i = 0; i < PositionsTotal(); i++) 
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == g_magic)
        {
         double vol = PositionGetDouble(POSITION_VOLUME);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);

         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            buy_count++;
            if(vol > max_buy_lot) max_buy_lot = vol;
            if(lowest_buy_price == 0 || open_price < lowest_buy_price) lowest_buy_price = open_price; 
           }
         else // SELL
           {
            sell_count++;
            if(vol > max_sell_lot) max_sell_lot = vol;
            if(highest_sell_price == 0 || open_price > highest_sell_price) highest_sell_price = open_price;
           }
        }
     }

   MqlTick tick; 
   SymbolInfoTick(_Symbol, tick);
   double step_distance = InpAveragingKVRStep * kvr;

// ================== BLOK BUY ==================
   if(buy_count > 0 && buy_count < InpMaxPositions)
     {
      if(lowest_buy_price - tick.ask >= step_distance)
        {
         // Gunakan fungsi Foolproof
         double new_lot = GetMultipliedLot(max_buy_lot);
         
         double sl = tick.ask - (kvr * InpKVRMultiplierSL);
         double tp = tick.ask + (kvr * InpKVRMultiplierTP);
         string comment = "KCI BUY Ave Layer " + IntegerToString(buy_count + 1);
         NativeOpenPosition(ORDER_TYPE_BUY, new_lot, tick.ask, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), comment);
        }
     }

   // ================== BLOK SELL ==================
   if(sell_count > 0 && sell_count < InpMaxPositions)
     {
      if(tick.bid - highest_sell_price >= step_distance)
        {
         // Gunakan fungsi Foolproof
         double new_lot = GetMultipliedLot(max_sell_lot);
         
         double sl = tick.bid + (kvr * InpKVRMultiplierSL);
         double tp = tick.bid - (kvr * InpKVRMultiplierTP);
         string comment = "KCI SELL Ave Layer " + IntegerToString(sell_count + 1);
         NativeOpenPosition(ORDER_TYPE_SELL, new_lot, tick.bid, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), comment);
        }
     }
  }

//+------------------------------------------------------------------+
//| Main Tick                                                        |
//+------------------------------------------------------------------+
void OnTick()
  {
   ManageTrailingStop();

   CheckDailyLimits();
   if(!g_trade_allowed)
      return;

   if(PositionsTotal() > 0)
     {
      CheckNewSignal();
     }

   if(PositionsTotal() == 0)
     {
      if((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > InpMaxSpread)
         return;

      int signal = GetSignal();
      if(signal == 0)
         return;

      double kvr = GetKVR(0);
      if(kvr <= 0)
         return;

      double lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
      double entry_price, sl, tp;

      MqlTick tick;
      if(!SymbolInfoTick(_Symbol, tick))
         return;

      if(signal == 1) // BUY
        {
         entry_price = tick.ask;
         sl = entry_price - kvr * InpKVRMultiplierSL;
         tp = entry_price + kvr * InpKVRMultiplierTP;
         NativeOpenPosition(ORDER_TYPE_BUY, lot, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Instant Sniper BUY");
         Print("Sniper Buy Executed natively. Lot: ", lot, " SL: ", sl, " TP: ", tp);
        }
      else
         if(signal == -1) // SELL
           {
            entry_price = tick.bid;
            sl = entry_price + kvr * InpKVRMultiplierSL;
            tp = entry_price - kvr * InpKVRMultiplierTP;
            NativeOpenPosition(ORDER_TYPE_SELL, lot, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Instant Sniper SELL");
            Print("Sniper Sell Executed natively. Lot: ", lot, " SL: ", sl, " TP: ", tp);
           }
     }
     CheckAveragingEntry();
     CheckBasketClose();
  }

//+------------------------------------------------------------------+
//| OnTradeTransaction - Pure Real Market Server Execution Pulse     |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
// Pure transactional detection to track Order/Deal confirmations
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
     {
      // 1. Select a deal from the server history based on the transaction ticket.
      if(HistoryDealSelect(trans.deal))
        {
         // 2. Take the pure Magic Number from the deal
         long deal_magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);

         // 3. Match with this EA's Magic Number
         if(deal_magic == g_magic)
           {
            Print("[NATIVE DEAL EXECUTION] Ticket: ", trans.deal,
                  " | Type: ", EnumToString(trans.deal_type),
                  " | Vol: ", trans.volume,
                  " | Server Price: ", trans.price);
           }
        }
     }
  }


//+------------------------------------------------------------------+

/*
This project is intended as a technical demonstration and development reference.
It is not a recommendation to trade, invest, or deploy the software in a live trading
environment without extensive independent testing and validation.
*/

//+------------------------------------------------------------------+


/* // Code With MTF External MA indicators

//+------------------------------------------------------------------+
//|                           Copyright 2026, KCI Standard Developer |
//+------------------------------------------------------------------+
#property copyright   "Copyright©2024. Ritz EAneha"
#property link        "https://www.mql5.com/en/users/ritzfalih"
#property version     "1.0"
#property description "EA Standalone: Pure KCI Zero-Line Breakout & Hold Strategy"
#property description "Embedded Native KVR-based SL/TP, Risk%, Daily Limits, Trailing"

#include <Trade\Trade.mqh>

//--- Enums
enum ENUM_LOT_MODE
{
   LOT_FIXED,      // Fixed lot size
   LOT_RISK        // Risk % of balance
};

input group "=== KCI Computing Core ==="
input int    ZScorePeriod          = 30;   // Z-Score period
input double CompressionThreshold  = 2.0;  // Compression threshold
input int    BasePeriod            = 9;   // Base period

input group "=== Trend Filter (MTF) ==="
input bool   InpUseTrendFilter = false;     // Enable trend filter
input ENUM_TIMEFRAMES InpTrendTF = PERIOD_CURRENT; // Trend timeframe
input int    InpTrendPeriod    = 34;      // Trend period

//--- Input Groups
input group "=== Trade Execution ==="
input ulong  InpMagicNumber  = 77720265;   // Magic number
input int    InpSlippage     = 10;         // Maximum slippage
input int    InpMaxSpread    = 200;        // Maximum spread (points)

input group "=== Money Management & Risk ==="
input ENUM_LOT_MODE InpLotMode = LOT_RISK; // Lot mode
input double InpLotSize      = 0.01;       // Fixed lot size (if mode = Fixed)
input double InpRiskPercent  = 1.0;        // Risk % per trade (if mode = Risk)
input int    InpKVRPeriod    = 14;         // KVR period (Embedded Native)
input double InpKVRMultiplierSL = 1.5;     // SL multiplier (KVR)
input double InpKVRMultiplierTP = 4.0;     // TP multiplier (KVR)

input group "=== Aggresive Trailing Stop (KVR-based) ==="
input bool   InpUseKVRTrailing = true;     // Enable KVR trailing
input double InpKVRTrailingStart = 0.08;    // Trailing start (KVR units) (2.0 = standard)
input double InpKVRTrailingStep  = 0.02;    // Trailing step (KVR units) (0.5 = standard)
input double InpKVRTrailingStop  = 0.15;    // Trailing stop distance (KVR units) (1.0 = standard)

input group "=== Hard Close Profit ==="
input bool   InpUseHardCloseProfit = true; // Enable hard close profit
input double InpHardCloseProfitKVR = 2.0;  // Profit target (KVR units)

input group "=== Daily Limits ==="
input bool   InpUseDailyLimit = false;
input double InpDailyLossPercent = 20.0;    // Max daily loss %
input double InpDailyDrawdownPercent = 10.0; // Max daily drawdown %


//--- Global Objects & Buffers
CTrade         trade;
int            handle_trend;
datetime       last_bar_time = 0;
double         buf_trend[];

//--- KCI Engine Buffers
double         vq[], kd[], ed[], pv[], Raw_KCI[], Polar_KCI[];
double         decay_constant;

//--- Daily Limit Variables
datetime       g_last_day = 0;
double         g_start_equity = 0;
double         g_daily_max_equity = 0;
bool           g_trade_allowed = true;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippage);
   
   ArraySetAsSeries(buf_trend, true);
   
   // MTF Trend
   handle_trend = iMA(_Symbol, InpTrendTF, InpTrendPeriod, 0, MODE_EMA, PRICE_CLOSE);
   if(handle_trend == INVALID_HANDLE)
   {
      Print("Failed to load MTF Trend indicator handle.");
      return(INIT_FAILED);
   }
   
   // Allocate memory for KCI Core Engine
   int total_bars = ZScorePeriod + BasePeriod + 10;
   ArrayResize(vq, total_bars); ArraySetAsSeries(vq, true);
   ArrayResize(kd, total_bars); ArraySetAsSeries(kd, true);
   ArrayResize(ed, total_bars); ArraySetAsSeries(ed, true);
   ArrayResize(pv, total_bars); ArraySetAsSeries(pv, true);
   ArrayResize(Raw_KCI, 5);     ArraySetAsSeries(Raw_KCI, true);
   ArrayResize(Polar_KCI, 5);   ArraySetAsSeries(Polar_KCI, true);

   decay_constant = 0.22314355 / CompressionThreshold;

   // Initialize daily tracking
   ResetDailyIfNewDay();

   Print("KCI Sniper V2.3 Enhanced (100% Standalone KVR) Initialized.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handle_trend != INVALID_HANDLE) IndicatorRelease(handle_trend);
}

//+------------------------------------------------------------------+
//| New Bar Detection                                                |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime current_time = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(current_time != last_bar_time)
   {
      last_bar_time = current_time;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Get KVR Value (Embedded Native Engine)                           |
//| shift = 1 ensures we use the finalized closed bar for stability  |
//+------------------------------------------------------------------+
double GetKVR(int shift = 1)
{
   int period = InpKVRPeriod;
   if(period < 2) return 0.0;
   
   double close[];
   ArraySetAsSeries(close, true);
   
   // Kita butuh (period + 1) bar untuk menghitung pergerakan poin demi poin
   if(CopyClose(_Symbol, _Period, shift, period + 1, close) < period + 1) return 0.0;
   
   double sum_price = 0.0;
   double path_length = 0.0;
   
   // Jarak absolut dari bar terkini (shift) ke bar masa lalu
   double net_distance = MathAbs(close[0] - close[period - 1]);
   
   for(int j = 0; j < period; j++)
   {
      sum_price += close[j];
      if(j < period - 1)
         path_length += MathAbs(close[j] - close[j + 1]);
   }
   
   if(path_length == 0.0) path_length = _Point; // Cegah Division by Zero
   
   double mean_price = sum_price / period;
   double variance_sum = 0.0;
   
   for(int j = 0; j < period; j++)
   {
      variance_sum += MathPow(close[j] - mean_price, 2);
   }
   
   double std_dev = MathSqrt(variance_sum / period);
   double efficiency_ratio = net_distance / path_length;
   
   // Rumusan Inti KVR: Standar Deviasi * (2.0 - Efficiency)
   return std_dev * (2.0 - efficiency_ratio);
}

//+------------------------------------------------------------------+
//| Custom Z-Score                                                   |
//+------------------------------------------------------------------+
double GetZScoreCustom(const double &data_array[], int start_index, int period)
{
   if(period < 2) return 0.0;
   double sum = 0.0, mean = 0.0, variance = 0.0, std_dev = 0.0;
   
   for(int i = 0; i < period; i++) sum += data_array[start_index + i];
   mean = sum / period;
   
   for(int i = 0; i < period; i++) variance += MathPow(data_array[start_index + i] - mean, 2);
   variance = variance / period;
   std_dev = MathSqrt(variance);
   
   if(std_dev == 0) return 0.0;
   return (data_array[start_index] - mean) / std_dev;
}

//+------------------------------------------------------------------+
//| KCI Core Engine (Signal Generation)                              |
//+------------------------------------------------------------------+
void GetEmbeddedKCIData(double &out_ed, double &kci_bar1, double &kci_bar2, double &kci_bar3)
{
   int total_bars = ZScorePeriod + BasePeriod + 10;
   double close[];
   ArraySetAsSeries(close, true);
   
   if(CopyClose(_Symbol, _Period, 0, total_bars, close) < total_bars) return;

   // Phase 1: Kinematics
   for(int i = total_bars - BasePeriod - 1; i >= 1; i--)
   {
      double sum_price = 0, path_length = 0.000001;
      double net_dist = close[i] - close[i + BasePeriod];
      
      for(int j = 0; j < BasePeriod; j++) {
         sum_price += close[i + j];
         path_length += MathAbs(close[i + j] - close[i + j + 1]);
      }
      
      double mean_price = sum_price / BasePeriod;
      double variance_price = 0;
      
      for(int j = 0; j < BasePeriod; j++) variance_price += MathPow(close[i + j] - mean_price, 2);

      vq[i] = net_dist / path_length;
      kd[i] = close[i] - mean_price;
      ed[i] = MathSqrt(variance_price / BasePeriod);
      pv[i] = net_dist;
   }

   // Phase 2: Z-Score & Polarized Mapping
   for(int i = 4; i >= 1; i--)
   {
      double z_vq = GetZScoreCustom(vq, i, ZScorePeriod);
      double z_kd = GetZScoreCustom(kd, i, ZScorePeriod);
      double z_ed = GetZScoreCustom(ed, i, ZScorePeriod);
      double z_pv = GetZScoreCustom(pv, i, ZScorePeriod);
      
      Raw_KCI[i] = MathAbs(z_vq-z_kd) + MathAbs(z_vq-z_ed) + MathAbs(z_vq-z_pv) +
                   MathAbs(z_kd-z_ed) + MathAbs(z_kd-z_pv) + MathAbs(z_ed-z_pv);
                   
      double direction = (kd[i] >= 0) ? 1.0 : -1.0;
      Polar_KCI[i] = 100.0 * MathExp(-decay_constant * Raw_KCI[i]) * direction;
   }

   out_ed = ed[1];
   kci_bar1 = Polar_KCI[1];
   kci_bar2 = Polar_KCI[2];
   kci_bar3 = Polar_KCI[3];
}

//+------------------------------------------------------------------+
//| Get Trading Signal (1=Buy, -1=Sell, 0=None)                      |
//+------------------------------------------------------------------+
int GetSignal()
{
   double current_ed, kci_bar1, kci_bar2, kci_bar3;
   GetEmbeddedKCIData(current_ed, kci_bar1, kci_bar2, kci_bar3);
   if(current_ed == 0) return 0;
   
   bool is_uptrend = true;
   bool is_downtrend = true;
   if(InpUseTrendFilter)
   {
      CopyBuffer(handle_trend, 0, 1, 1, buf_trend);
      double trend_ma = buf_trend[0];
      if(SymbolInfoDouble(_Symbol, SYMBOL_BID) < trend_ma) is_uptrend = false;
      if(SymbolInfoDouble(_Symbol, SYMBOL_BID) > trend_ma) is_downtrend = false;
   }
   
   // Buy signal
   if(kci_bar2 <= 0.0 && kci_bar1 > 0.0 && current_ed > 0.0 && is_uptrend)
      return 1;
   // Sell signal
   if(current_ed >= 0.0 && kci_bar2 < 0.0 && kci_bar1 < 0.0 && is_downtrend)
      return -1;
      
   return 0;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size by Risk (Diperbaiki & Aman Semua Simbol)      |
//| Menggunakan MathAbs untuk jarak SL dan validasi ketat            |
//+------------------------------------------------------------------+
double CalculateLotByRisk(double sl_distance_price)
{
   if(InpLotMode == LOT_FIXED) 
      return InpLotSize;

   // Pastikan jarak SL positif (antisipasi parameter negatif)
   sl_distance_price = MathAbs(sl_distance_price);
   if(sl_distance_price == 0.0) 
      return InpLotSize;

   double riskPercent = InpRiskPercent / 100.0;
   double riskMoney   = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent;

   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize == 0.0 || tickValue == 0.0) 
      return InpLotSize;

   double sl_ticks = sl_distance_price / tickSize;
   if(sl_ticks <= 0.0) 
      return InpLotSize;

   double lot = riskMoney / (sl_ticks * tickValue);

   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(lotStep == 0.0) 
      lotStep = 0.01;

   lot = MathFloor(lot / lotStep) * lotStep;

   double lotMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double lotMax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lot = MathMax(lot, lotMin);
   lot = MathMin(lot, lotMax);

   return lot;
}

//+------------------------------------------------------------------+
//| Daily Limit Functions                                            |
//+------------------------------------------------------------------+
void ResetDailyIfNewDay()
{
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   datetime day_start = StringToTime(TimeToString(now, TIME_DATE));
   if(day_start > g_last_day)
   {
      g_last_day = day_start;
      g_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_daily_max_equity = g_start_equity;
      g_trade_allowed = true;
      Print("New day. Start equity: ", DoubleToString(g_start_equity, 2));
   }
}

void CheckDailyLimits()
{
   ResetDailyIfNewDay();
   if(!g_trade_allowed || !InpUseDailyLimit) return;
   
   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(current_equity > g_daily_max_equity) g_daily_max_equity = current_equity;
   
   double lossPercent = (g_start_equity - current_equity) / g_start_equity * 100.0;
   if(lossPercent >= InpDailyLossPercent)
   {
      g_trade_allowed = false;
      Print("Daily loss limit reached. Trading stopped.");
      return;
   }
   
   double drawdownPercent = (g_daily_max_equity - current_equity) / g_daily_max_equity * 100.0;
   if(drawdownPercent >= InpDailyDrawdownPercent)
   {
      g_trade_allowed = false;
      Print("Daily drawdown limit reached. Trading stopped.");
   }
}

//+------------------------------------------------------------------+
//| Manage Trailing Stop (KVR-based)                                 |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
   if(!InpUseKVRTrailing) return;
   double kvr = GetKVR(1); // Gunakan data dari bar yg sudah close
   if(kvr <= 0) return;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         double price = PositionGetDouble(POSITION_PRICE_CURRENT);
         double sl = PositionGetDouble(POSITION_SL);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double tp = PositionGetDouble(POSITION_TP);
         
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            double profit_points = (price - open_price) / _Point;
            if(profit_points >= InpKVRTrailingStart * kvr / _Point)
            {
               double new_sl = price - InpKVRTrailingStop * kvr;
               if(new_sl > sl + InpKVRTrailingStep * kvr)
               {
                  if(new_sl > sl)
                     trade.PositionModify(ticket, NormalizeDouble(new_sl, _Digits), tp);
               }
            }
         }
         else // SELL
         {
            double profit_points = (open_price - price) / _Point;
            if(profit_points >= InpKVRTrailingStart * kvr / _Point)
            {
               double new_sl = price + InpKVRTrailingStop * kvr;
               if(new_sl < sl - InpKVRTrailingStep * kvr)
               {
                  if(new_sl < sl || sl == 0)
                     trade.PositionModify(ticket, NormalizeDouble(new_sl, _Digits), tp);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Hard Close Profit by KVR                                         |
//+------------------------------------------------------------------+
void CheckHardCloseProfit()
{
   if(!InpUseHardCloseProfit) return;
   double kvr = GetKVR(1);
   if(kvr <= 0) return;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         double price = PositionGetDouble(POSITION_PRICE_CURRENT);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double profit_points;
         
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            profit_points = (price - open_price) / _Point;
         else
            profit_points = (open_price - price) / _Point;
            
         if(profit_points >= InpHardCloseProfitKVR * kvr / _Point)
         {
            trade.PositionClose(ticket);
            Print("Hard close profit reached. Closing position #", ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check New Signal – Close opposite and open new                   |
//+------------------------------------------------------------------+
void CheckNewSignal()
{
   int signal = GetSignal();
   if(signal == 0) return;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         bool opposite = false;
         if(type == POSITION_TYPE_BUY && signal == -1) opposite = true;
         if(type == POSITION_TYPE_SELL && signal == 1) opposite = true;
         
         if(opposite)
         {
            // Close existing
            trade.PositionClose(ticket);
            
            // Buka posisi baru - Hitung KVR
            double kvr = GetKVR(1);
            if(kvr <= 0) return;
            
            double lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
            double entry_price, sl, tp;
            
            if(signal == 1) // BUY
            {
               entry_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               sl = entry_price - kvr * InpKVRMultiplierSL;
               tp = entry_price + kvr * InpKVRMultiplierTP;
               trade.Buy(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "New Signal BUY");
            }
            else // SELL
            {
               entry_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               sl = entry_price + kvr * InpKVRMultiplierSL;
               tp = entry_price - kvr * InpKVRMultiplierTP;
               trade.Sell(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "New Signal SELL");
            }
            Print("New signal detected. Closed opposite position and opened new one.");
            break; 
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Main Tick                                                        |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Trailing (every tick)
   ManageTrailingStop();
   
   //--- Daily limits
   CheckDailyLimits();
   if(!g_trade_allowed) return;
   
   //--- Hard close profit (every tick)
   CheckHardCloseProfit();
   
   //--- New bar actions
   if(!IsNewBar()) return;
   
   //--- Check new signal for existing positions
   if(PositionsTotal() > 0)
   {
      CheckNewSignal();
   }
   
   //--- Entry if no position
   if(PositionsTotal() == 0)
   {
      // Spread filter
      if((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > InpMaxSpread)
      {
         Print("Spread too high: ", SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
         return;
      }
      
      int signal = GetSignal();
      if(signal == 0) return;
      
      double kvr = GetKVR(1);
      if(kvr <= 0) return;
      
      double lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
      double entry_price, sl, tp;
      
      if(signal == 1) // BUY
      {
         entry_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         sl = entry_price - kvr * InpKVRMultiplierSL;
         tp = entry_price + kvr * InpKVRMultiplierTP;
         trade.Buy(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Pure KCI BUY");
         Print("Buy order placed. Lot: ", lot, " SL: ", sl, " TP: ", tp);
      }
      else if(signal == -1) // SELL
      {
         entry_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         sl = entry_price + kvr * InpKVRMultiplierSL;
         tp = entry_price - kvr * InpKVRMultiplierTP;
         trade.Sell(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Pure KCI SELL");
         Print("Sell order placed. Lot: ", lot, " SL: ", sl, " TP: ", tp);
      }
   }
}

*/ // end of Code With MTF External indicators

//+------------------------------------------------------------------+

/*
This project is intended as a technical demonstration and development reference.
It is not a recommendation to trade, invest, or deploy the software in a live trading environment without extensive independent testing and validation.
*/

// syamsurizal dimjati

// 2024/03/15
/*
//+------------------------------------------------------------------+
//|                                             KCI Sniper V1.0 .mq5 |
//|                           Copyright 2026, KCI Standard Developer |
//+------------------------------------------------------------------+
#property copyright   "Copyright©2026. Ritz EAneha"
#property link        "https://www.mql5.com/en/users/ritzfalih"
#property version     "1.0"
#property description "EA Standalone: Pure KCI Zero-Line Breakout & Hold Strategy"
#property description "Embedded Native KVR SL/TP, KCI Trend MTF Filter, Trailing (INSTANT TRIGGER)"

#include <Trade\Trade.mqh>

//--- Enums
enum ENUM_LOT_MODE
{
   LOT_FIXED,      // Fixed lot size
   LOT_RISK        // Risk % of balance
};

input group "=== KCI Computing Core ==="
input int    ZScorePeriod          = 30;        // Z-Score period
input double CompressionThreshold  = 2.0;       // Compression threshold
input int    BasePeriod            = 9;         // Base period
input group ""

input group "=== KCI Trend Filter (MTF) ==="
input bool   InpUseTrendFilter   = true;         // Enable KCI Trend Filter
input ENUM_TIMEFRAMES InpTrendTF = PERIOD_M15;   // KCI Trend Timeframe
input int    InpTrendBasePeriod  = 34;           // KCI Trend Base Period
input group ""

input group "=== Trade Execution ==="
input ulong  InpMagicNumber  = 77720265;   // Magic number
input int    InpSlippage     = 20;         // Maximum slippage
input int    InpMaxSpread    = 200;        // Maximum spread (points)
input group ""

input group "=== Money Management & Risk ==="
input ENUM_LOT_MODE InpLotMode = LOT_RISK; // Lot mode
input double InpLotSize      = 0.01;       // Fixed lot size (if mode = Fixed)
input double InpRiskPercent  = 1.0;        // Risk % per trade (if mode = Risk)
input int    InpKVRPeriod    = 14;         // KVR period (Embedded Native)
input double InpKVRMultiplierSL = 1.5;     // SL multiplier (KVR)
input double InpKVRMultiplierTP = 3.5;     // TP multiplier (KVR)
input group ""

input group "=== Aggresive Trailing Stop (KVR-based) ==="
input bool   InpUseKVRTrailing = true;     // Enable KVR trailing
input double InpKVRTrailingStart = 1.0;    // Trailing start (KVR units) (2.0 = standard)
input double InpKVRTrailingStep  = 0.2;    // Slide SL every time the price moves 0.2 KVR.
input double InpKVRTrailingStop  = 0.5;    // Trailing stop distance (KVR units) (1.0 = standard)
input group ""

input group "=== Hard Close Profit ==="
input bool   InpUseHardCloseProfit = true; // Enable hard close profit
input double InpHardCloseProfitKVR = 3.0;  // Profit target (KVR units)
input group ""

input group "=== Daily Limits ==="
input bool   InpUseDailyLimit = true;       // Daily Limit en|dis
input double InpDailyLossPercent = 10.0;    // Limit daily losses to a maximum of 10%. (10 consecutive SL).
input double InpDailyDrawdownPercent = 5.0; // Maximum floating drawdown 5%.

//--- Global Objects & Buffers
CTrade         trade;

//--- KCI Engine Buffers
double         vq[], kd[], ed[], pv[], Raw_KCI[], Polar_KCI[];
double         decay_constant;

//--- Daily Limit Variables
datetime       g_last_day = 0;
double         g_start_equity = 0;
double         g_daily_max_equity = 0;
bool           g_trade_allowed = true;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippage);

   // Allocate memory for KCI Core Engine
   int total_bars = ZScorePeriod + BasePeriod + 10;
   ArrayResize(vq, total_bars); ArraySetAsSeries(vq, true);
   ArrayResize(kd, total_bars); ArraySetAsSeries(kd, true);
   ArrayResize(ed, total_bars); ArraySetAsSeries(ed, true);
   ArrayResize(pv, total_bars); ArraySetAsSeries(pv, true);
   ArrayResize(Raw_KCI, 5);     ArraySetAsSeries(Raw_KCI, true);
   ArrayResize(Polar_KCI, 5);   ArraySetAsSeries(Polar_KCI, true);

   decay_constant = 0.22314355 / CompressionThreshold;

   // Initialize daily tracking
   ResetDailyIfNewDay();

   Print("KCI Sniper V1.0 Enhanced (INSTANT TRIGGER ACTIVATED) Initialized.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // No handles to release anymore! 100% Clean.
}

//+------------------------------------------------------------------+
//| Get KVR Value (Embedded Native Engine)                           |
//+------------------------------------------------------------------+
double GetKVR(int shift = 0) // <--- Diubah ke 0 agar Volatilitas Instan saat tick terjadi
{
   int period = InpKVRPeriod;
   if(period < 2) return 0.0;

   double close[];
   ArraySetAsSeries(close, true);

   if(CopyClose(_Symbol, _Period, shift, period + 1, close) < period + 1) return 0.0;

   double sum_price = 0.0;
   double path_length = 0.0;

   double net_distance = MathAbs(close[0] - close[period - 1]);

   for(int j = 0; j < period; j++)
   {
      sum_price += close[j];
      if(j < period - 1)
         path_length += MathAbs(close[j] - close[j + 1]);
   }

   if(path_length == 0.0) path_length = _Point;

   double mean_price = sum_price / period;
   double variance_sum = 0.0;

   for(int j = 0; j < period; j++)
   {
      variance_sum += MathPow(close[j] - mean_price, 2);
   }

   double std_dev = MathSqrt(variance_sum / period);
   double efficiency_ratio = net_distance / path_length;

   return std_dev * (2.0 - efficiency_ratio);
}

//+------------------------------------------------------------------+
//| Embedded KCI Trend Filter (MTF Standalone)                       |
//+------------------------------------------------------------------+
int GetMTFKCITrend(ENUM_TIMEFRAMES tf, int base_period, int shift = 1)
{
   if(base_period < 1) return 0;

   double close[];
   ArraySetAsSeries(close, true);

   if(CopyClose(_Symbol, tf, shift, base_period, close) < base_period) return 0;

   double sum_price = 0;
   for(int j = 0; j < base_period; j++) sum_price += close[j];

   double mean_price = sum_price / base_period;
   double kd_polarity = close[0] - mean_price;

   if(kd_polarity >= 0.0) return 1;
   if(kd_polarity < 0.0)  return -1;

   return 0;
}

//+------------------------------------------------------------------+
//| Custom Z-Score                                                   |
//+------------------------------------------------------------------+
double GetZScoreCustom(const double &data_array[], int start_index, int period)
{
   if(period < 2) return 0.0;
   double sum = 0.0, mean = 0.0, variance = 0.0, std_dev = 0.0;

   for(int i = 0; i < period; i++) sum += data_array[start_index + i];
   mean = sum / period;

   for(int i = 0; i < period; i++) variance += MathPow(data_array[start_index + i] - mean, 2);
   variance = variance / period;
   std_dev = MathSqrt(variance);

   if(std_dev == 0) return 0.0;
   return (data_array[start_index] - mean) / std_dev;
}

//+------------------------------------------------------------------+
//| KCI Core Engine (Real-Time Generation)                           |
//+------------------------------------------------------------------+
// Mengambil Bar 0 (saat ini) dan Bar 1 (sebelumnya)
void GetEmbeddedKCIData(double &out_ed, double &kci_bar0, double &kci_bar1)
{
   int total_bars = ZScorePeriod + BasePeriod + 10;
   double close[];
   ArraySetAsSeries(close, true);

   if(CopyClose(_Symbol, _Period, 0, total_bars, close) < total_bars) return;

   // Perubahan Krusial: Iterasi kini turun hingga i = 0 (Real-time harga berjalan)
   for(int i = total_bars - BasePeriod - 1; i >= 0; i--)
   {
      double sum_price = 0, path_length = 0.000001;
      double net_dist = close[i] - close[i + BasePeriod];

      for(int j = 0; j < BasePeriod; j++) {
         sum_price += close[i + j];
         path_length += MathAbs(close[i + j] - close[i + j + 1]);
      }

      double mean_price = sum_price / BasePeriod;
      double variance_price = 0;
      for(int j = 0; j < BasePeriod; j++) variance_price += MathPow(close[i + j] - mean_price, 2);

      vq[i] = net_dist / path_length;
      kd[i] = close[i] - mean_price;
      ed[i] = MathSqrt(variance_price / BasePeriod);
      pv[i] = net_dist;
   }

   // Hitung Z-Score hingga bar ke 0
   for(int i = 4; i >= 0; i--)
   {
      double z_vq = GetZScoreCustom(vq, i, ZScorePeriod);
      double z_kd = GetZScoreCustom(kd, i, ZScorePeriod);
      double z_ed = GetZScoreCustom(ed, i, ZScorePeriod);
      double z_pv = GetZScoreCustom(pv, i, ZScorePeriod);

      Raw_KCI[i] = MathAbs(z_vq-z_kd) + MathAbs(z_vq-z_ed) + MathAbs(z_vq-z_pv) +
                   MathAbs(z_kd-z_ed) + MathAbs(z_kd-z_pv) + MathAbs(z_ed-z_pv);

      double direction = (kd[i] >= 0) ? 1.0 : -1.0;
      Polar_KCI[i] = 100.0 * MathExp(-decay_constant * Raw_KCI[i]) * direction;
   }

   out_ed = ed[0];
   kci_bar0 = Polar_KCI[0]; // State tick saat ini
   kci_bar1 = Polar_KCI[1]; // State bar sebelumnya
}

//+------------------------------------------------------------------+
//| Get Trading Signal (INSTANT TRIGGER)                             |
//+------------------------------------------------------------------+
int GetSignal()
{
   double current_ed, kci_bar0, kci_bar1;
   GetEmbeddedKCIData(current_ed, kci_bar0, kci_bar1);
   if(current_ed == 0) return 0;

   bool is_uptrend = true;
   bool is_downtrend = true;

   if(InpUseTrendFilter)
   {
      int kci_trend = GetMTFKCITrend(InpTrendTF, InpTrendBasePeriod, 1);
      if(kci_trend != 1) is_uptrend = false;
      if(kci_trend != -1) is_downtrend = false;
   }

   // LOGIKA ENTRY INSTAN (Tick-by-Tick Cross)
   // Jika Bar Sebelumnya Minus/Nol, DAN Tick Saat Ini Berubah Positif = INSTANT BUY Arrow!
   if(kci_bar1 <= 0.0 && kci_bar0 > 0.0 && is_uptrend) return 1;

   // Jika Bar Sebelumnya Plus/Nol, DAN Tick Saat Ini Berubah Negatif = INSTANT SELL Arrow!
   if(kci_bar1 >= 0.0 && kci_bar0 < 0.0 && is_downtrend) return -1;

   return 0;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size by Risk                                       |
//+------------------------------------------------------------------+
double CalculateLotByRisk(double sl_distance_price)
{
   if(InpLotMode == LOT_FIXED) return InpLotSize;

   sl_distance_price = MathAbs(sl_distance_price);
   if(sl_distance_price == 0.0) return InpLotSize;

   double riskPercent = InpRiskPercent / 100.0;
   double riskMoney   = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent;

   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize == 0.0 || tickValue == 0.0) return InpLotSize;

   double sl_ticks = sl_distance_price / tickSize;
   if(sl_ticks <= 0.0) return InpLotSize;

   double lot = riskMoney / (sl_ticks * tickValue);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(lotStep == 0.0) lotStep = 0.01;

   lot = MathFloor(lot / lotStep) * lotStep;
   double lotMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double lotMax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lot = MathMax(lot, lotMin);
   lot = MathMin(lot, lotMax);

   return lot;
}

//+------------------------------------------------------------------+
//| Daily Limit Functions                                            |
//+------------------------------------------------------------------+
void ResetDailyIfNewDay()
{
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   datetime day_start = StringToTime(TimeToString(now, TIME_DATE));
   if(day_start > g_last_day)
   {
      g_last_day = day_start;
      g_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_daily_max_equity = g_start_equity;
      g_trade_allowed = true;
      Print("New day. Start equity: ", DoubleToString(g_start_equity, 2));
   }
}

void CheckDailyLimits()
{
   ResetDailyIfNewDay();
   if(!g_trade_allowed || !InpUseDailyLimit) return;

   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(current_equity > g_daily_max_equity) g_daily_max_equity = current_equity;

   double lossPercent = (g_start_equity - current_equity) / g_start_equity * 100.0;
   if(lossPercent >= InpDailyLossPercent)
   {
      g_trade_allowed = false;
      Print("Daily loss limit reached. Trading stopped.");
      return;
   }

   double drawdownPercent = (g_daily_max_equity - current_equity) / g_daily_max_equity * 100.0;
   if(drawdownPercent >= InpDailyDrawdownPercent)
   {
      g_trade_allowed = false;
      Print("Daily drawdown limit reached. Trading stopped.");
   }
}

//+------------------------------------------------------------------+
//| Manage Trailing Stop (KVR-based)                                 |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
   if(!InpUseKVRTrailing) return;
   double kvr = GetKVR(0); // Real-time KVR
   if(kvr <= 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         double price = PositionGetDouble(POSITION_PRICE_CURRENT);
         double sl = PositionGetDouble(POSITION_SL);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double tp = PositionGetDouble(POSITION_TP);

         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            double profit_points = (price - open_price) / _Point;
            if(profit_points >= InpKVRTrailingStart * kvr / _Point)
            {
               double new_sl = price - InpKVRTrailingStop * kvr;
               if(new_sl > sl + InpKVRTrailingStep * kvr)
               {
                  if(new_sl > sl)
                     trade.PositionModify(ticket, NormalizeDouble(new_sl, _Digits), tp);
               }
            }
         }
         else // SELL
         {
            double profit_points = (open_price - price) / _Point;
            if(profit_points >= InpKVRTrailingStart * kvr / _Point)
            {
               double new_sl = price + InpKVRTrailingStop * kvr;
               if(new_sl < sl - InpKVRTrailingStep * kvr)
               {
                  if(new_sl < sl || sl == 0)
                     trade.PositionModify(ticket, NormalizeDouble(new_sl, _Digits), tp);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Hard Close Profit by KVR                                         |
//+------------------------------------------------------------------+
void CheckHardCloseProfit()
{
   if(!InpUseHardCloseProfit) return;
   double kvr = GetKVR(0); // Real-time KVR
   if(kvr <= 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         double price = PositionGetDouble(POSITION_PRICE_CURRENT);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double profit_points;

         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            profit_points = (price - open_price) / _Point;
         else
            profit_points = (open_price - price) / _Point;

         if(profit_points >= InpHardCloseProfitKVR * kvr / _Point)
         {
            trade.PositionClose(ticket);
            Print("Hard close profit reached. Closing position #", ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check New Signal – Close opposite and open new                   |
//+------------------------------------------------------------------+
void CheckNewSignal()
{
   int signal = GetSignal();
   if(signal == 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         bool opposite = false;
         if(type == POSITION_TYPE_BUY && signal == -1) opposite = true;
         if(type == POSITION_TYPE_SELL && signal == 1) opposite = true;

         if(opposite)
         {
            trade.PositionClose(ticket);

            double kvr = GetKVR(0); // Real-time KVR entry
            if(kvr <= 0) return;

            double lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
            double entry_price, sl, tp;

            if(signal == 1) // BUY
            {
               entry_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               sl = entry_price - kvr * InpKVRMultiplierSL;
               tp = entry_price + kvr * InpKVRMultiplierTP;
               trade.Buy(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "New Instant Signal BUY");
            }
            else // SELL
            {
               entry_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               sl = entry_price + kvr * InpKVRMultiplierSL;
               tp = entry_price - kvr * InpKVRMultiplierTP;
               trade.Sell(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "New Instant Signal SELL");
            }
            Print("Instant reversal detected! Closed opposite position and deployed Sniper.");
            break;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Main Tick (NO MORE DELAY - EXECUTES EVERY TICK)                  |
//+------------------------------------------------------------------+
void OnTick()
{
   ManageTrailingStop();

   CheckDailyLimits();
   if(!g_trade_allowed) return;

   CheckHardCloseProfit();

   if(PositionsTotal() > 0)
   {
      CheckNewSignal(); // Cek jika ada sinyal pembalikan arah saat ini juga
   }

   if(PositionsTotal() == 0)
   {
      if((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > InpMaxSpread)
      {
         return; // Hening jika spread terlalu lebar, tunggu tick berikutnya
      }

      int signal = GetSignal();
      if(signal == 0) return;

      double kvr = GetKVR(0); // Volatilitas dihitung dari harga tick terakhir
      if(kvr <= 0) return;

      double lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
      double entry_price, sl, tp;

      if(signal == 1) // BUY
      {
         entry_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         sl = entry_price - kvr * InpKVRMultiplierSL;
         tp = entry_price + kvr * InpKVRMultiplierTP;
         trade.Buy(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Instant Sniper BUY");
         Print("Sniper Buy Executed instantly. Lot: ", lot, " SL: ", sl, " TP: ", tp);
      }
      else if(signal == -1) // SELL
      {
         entry_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         sl = entry_price + kvr * InpKVRMultiplierSL;
         tp = entry_price - kvr * InpKVRMultiplierTP;
         trade.Sell(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Instant Sniper SELL");
         Print("Sniper Sell Executed instantly. Lot: ", lot, " SL: ", sl, " TP: ", tp);
      }
   }
}


*/




/*
//+------------------------------------------------------------------+
//|                                             KCI Sniper V1.0 .mq5 |
//|                           Copyright 2026, KCI Standard Developer |
//+------------------------------------------------------------------+
#property copyright   "Copyright©2026. Ritz EAneha"
#property link        "https://www.mql5.com/en/users/ritzfalih"
#property version     "1.0"
#property description "EA Standalone: Pure KCI Zero-Line Breakout & Hold Strategy"
#property description "Embedded Native KVR SL/TP, KCI Trend MTF Filter, Trailing"

#include <Trade\Trade.mqh>

//--- Enums
enum ENUM_LOT_MODE
{
   LOT_FIXED,      // Fixed lot size
   LOT_RISK        // Risk % of balance
};

input group "=== KCI Computing Core ==="
input int    ZScorePeriod          = 60;   // Z-Score period
input double CompressionThreshold  = 1.8;  // Compression threshold
input int    BasePeriod            = 21;   // Base period

input group "=== KCI Trend Filter (MTF) ==="
input bool   InpUseTrendFilter   = true;         // Enable KCI Trend Filter
input ENUM_TIMEFRAMES InpTrendTF = PERIOD_M15;   // KCI Trend Timeframe
input int    InpTrendBasePeriod  = 34;           // KCI Trend Base Period

input group "=== Trade Execution ==="
input ulong  InpMagicNumber  = 77720265;   // Magic number
input int    InpSlippage     = 20;         // Maximum slippage
input int    InpMaxSpread    = 100;        // Maximum spread (points)

input group "=== Money Management & Risk ==="
input ENUM_LOT_MODE InpLotMode = LOT_RISK; // Lot mode
input double InpLotSize      = 0.01;       // Fixed lot size (if mode = Fixed)
input double InpRiskPercent  = 1.0;        // Risk % per trade (if mode = Risk)
input int    InpKVRPeriod    = 14;         // KVR period (Embedded Native)
input double InpKVRMultiplierSL = 1.5;     // SL multiplier (KVR)
input double InpKVRMultiplierTP = 3.5;     // TP multiplier (KVR)

input group "=== Aggresive Trailing Stop (KVR-based) ==="
input bool   InpUseKVRTrailing = true;     // Enable KVR trailing
// CAUTION: original Aggressive values ​​(0.08, etc.) are too narrow for M1 Gold. be instantly swept away by noise. Use this:
input double InpKVRTrailingStart = 1.0;    // Trailing start (KVR units) (2.0 = standard)
input double InpKVRTrailingStep  = 0.2;    // Slide SL every time the price moves 0.2 KVR.
input double InpKVRTrailingStop  = 0.5;    // Trailing stop distance (KVR units) (1.0 = standard)

input group "=== Hard Close Profit ==="
input bool   InpUseHardCloseProfit = true; // Enable hard close profit
input double InpHardCloseProfitKVR = 3.0;  // Profit target (KVR units)

input group "=== Daily Limits ==="
input bool   InpUseDailyLimit = true;       // Daily Limit en|dis
input double InpDailyLossPercent = 10.0;    // Limit daily losses to a maximum of 10%. (10 consecutive SL).
input double InpDailyDrawdownPercent = 5.0; // Maximum floating drawdown 5%.

//--- Global Objects & Buffers
CTrade         trade;
datetime       last_bar_time = 0;

//--- KCI Engine Buffers
double         vq[], kd[], ed[], pv[], Raw_KCI[], Polar_KCI[];
double         decay_constant;

//--- Daily Limit Variables
datetime       g_last_day = 0;
double         g_start_equity = 0;
double         g_daily_max_equity = 0;
bool           g_trade_allowed = true;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippage);

   // Allocate memory for KCI Core Engine
   int total_bars = ZScorePeriod + BasePeriod + 10;
   ArrayResize(vq, total_bars); ArraySetAsSeries(vq, true);
   ArrayResize(kd, total_bars); ArraySetAsSeries(kd, true);
   ArrayResize(ed, total_bars); ArraySetAsSeries(ed, true);
   ArrayResize(pv, total_bars); ArraySetAsSeries(pv, true);
   ArrayResize(Raw_KCI, 5);     ArraySetAsSeries(Raw_KCI, true);
   ArrayResize(Polar_KCI, 5);   ArraySetAsSeries(Polar_KCI, true);

   decay_constant = 0.22314355 / CompressionThreshold;

   // Initialize daily tracking
   ResetDailyIfNewDay();

   Print("KCI Sniper V1.0 Enhanced (100% Standalone KVR & KCI Trend) Initialized.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // No handles to release anymore! 100% Clean.
}

//+------------------------------------------------------------------+
//| New Bar Detection                                                |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime current_time = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(current_time != last_bar_time)
   {
      last_bar_time = current_time;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Get KVR Value (Embedded Native Engine)                           |
//+------------------------------------------------------------------+
double GetKVR(int shift = 1)
{
   int period = InpKVRPeriod;
   if(period < 2) return 0.0;

   double close[];
   ArraySetAsSeries(close, true);

   if(CopyClose(_Symbol, _Period, shift, period + 1, close) < period + 1) return 0.0;

   double sum_price = 0.0;
   double path_length = 0.0;

   double net_distance = MathAbs(close[0] - close[period - 1]);

   for(int j = 0; j < period; j++)
   {
      sum_price += close[j];
      if(j < period - 1)
         path_length += MathAbs(close[j] - close[j + 1]);
   }

   if(path_length == 0.0) path_length = _Point;

   double mean_price = sum_price / period;
   double variance_sum = 0.0;

   for(int j = 0; j < period; j++)
   {
      variance_sum += MathPow(close[j] - mean_price, 2);
   }

   double std_dev = MathSqrt(variance_sum / period);
   double efficiency_ratio = net_distance / path_length;

   return std_dev * (2.0 - efficiency_ratio);
}

//+------------------------------------------------------------------+
//| Embedded KCI Trend Filter (MTF Standalone)                       |
//| Returns: 1 (Bullish), -1 (Bearish), 0 (Error)                    |
//+------------------------------------------------------------------+
int GetMTFKCITrend(ENUM_TIMEFRAMES tf, int base_period, int shift = 1)
{
   if(base_period < 1) return 0;

   double close[];
   ArraySetAsSeries(close, true);

   // We retrieve the close data from the user-inputted Timeframe (MTF)
   // shift = 1 ensures we read the closed kinetic base (No Repaint)
   if(CopyClose(_Symbol, tf, shift, base_period, close) < base_period) return 0;

   double sum_price = 0;
   for(int j = 0; j < base_period; j++)
   {
      sum_price += close[j];
   }

   // Phase 1 Calculation: Gravity Base & Kinetic Direction (kd)
   double mean_price = sum_price / base_period;
   double kd_polarity = close[0] - mean_price;

   // Same as indicator logic: kd >= 0 = Blue (Bullish), kd < 0 = Red (Bearish)
   if(kd_polarity >= 0.0) return 1;
   if(kd_polarity < 0.0)  return -1;

   return 0;
}

//+------------------------------------------------------------------+
//| Custom Z-Score                                                   |
//+------------------------------------------------------------------+
double GetZScoreCustom(const double &data_array[], int start_index, int period)
{
   if(period < 2) return 0.0;
   double sum = 0.0, mean = 0.0, variance = 0.0, std_dev = 0.0;

   for(int i = 0; i < period; i++) sum += data_array[start_index + i];
   mean = sum / period;

   for(int i = 0; i < period; i++) variance += MathPow(data_array[start_index + i] - mean, 2);
   variance = variance / period;
   std_dev = MathSqrt(variance);

   if(std_dev == 0) return 0.0;
   return (data_array[start_index] - mean) / std_dev;
}

//+------------------------------------------------------------------+
//| KCI Core Engine (Signal Generation)                              |
//+------------------------------------------------------------------+
void GetEmbeddedKCIData(double &out_ed, double &kci_bar1, double &kci_bar2, double &kci_bar3)
{
   int total_bars = ZScorePeriod + BasePeriod + 10;
   double close[];
   ArraySetAsSeries(close, true);

   if(CopyClose(_Symbol, _Period, 0, total_bars, close) < total_bars) return;

   for(int i = total_bars - BasePeriod - 1; i >= 1; i--)
   {
      double sum_price = 0, path_length = 0.000001;
      double net_dist = close[i] - close[i + BasePeriod];

      for(int j = 0; j < BasePeriod; j++) {
         sum_price += close[i + j];
         path_length += MathAbs(close[i + j] - close[i + j + 1]);
      }

      double mean_price = sum_price / BasePeriod;
      double variance_price = 0;

      for(int j = 0; j < BasePeriod; j++) variance_price += MathPow(close[i + j] - mean_price, 2);

      vq[i] = net_dist / path_length;
      kd[i] = close[i] - mean_price;
      ed[i] = MathSqrt(variance_price / BasePeriod);
      pv[i] = net_dist;
   }

   for(int i = 4; i >= 1; i--)
   {
      double z_vq = GetZScoreCustom(vq, i, ZScorePeriod);
      double z_kd = GetZScoreCustom(kd, i, ZScorePeriod);
      double z_ed = GetZScoreCustom(ed, i, ZScorePeriod);
      double z_pv = GetZScoreCustom(pv, i, ZScorePeriod);

      Raw_KCI[i] = MathAbs(z_vq-z_kd) + MathAbs(z_vq-z_ed) + MathAbs(z_vq-z_pv) +
                   MathAbs(z_kd-z_ed) + MathAbs(z_kd-z_pv) + MathAbs(z_ed-z_pv);

      double direction = (kd[i] >= 0) ? 1.0 : -1.0;
      Polar_KCI[i] = 100.0 * MathExp(-decay_constant * Raw_KCI[i]) * direction;
   }

   out_ed = ed[1];
   kci_bar1 = Polar_KCI[1];
   kci_bar2 = Polar_KCI[2];
   kci_bar3 = Polar_KCI[3];
}

//+------------------------------------------------------------------+
//| Get Trading Signal (1=Buy, -1=Sell, 0=None)                      |
//+------------------------------------------------------------------+
int GetSignal()
{
   double current_ed, kci_bar1, kci_bar2, kci_bar3;
   GetEmbeddedKCIData(current_ed, kci_bar1, kci_bar2, kci_bar3);
   if(current_ed == 0) return 0;

   bool is_uptrend = true;
   bool is_downtrend = true;

   // Call KCI Trend Standalone if enabled
   if(InpUseTrendFilter)
   {
      int kci_trend = GetMTFKCITrend(InpTrendTF, InpTrendBasePeriod, 1);

      // If kci_trend is not 1 (Bullish), turn off is_uptrend
      if(kci_trend != 1) is_uptrend = false;
      // If kcl trend is not -1 (Bearish), turn off is downtrend
      if(kci_trend != -1) is_downtrend = false;
   }

   if(kci_bar2 <= 0.0 && kci_bar1 > 0.0 && current_ed > 0.0 && is_uptrend)
      return 1;

   if(current_ed >= 0.0 && kci_bar2 < 0.0 && kci_bar1 < 0.0 && is_downtrend)
      return -1;

   return 0;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size by Risk                                       |
//+------------------------------------------------------------------+
double CalculateLotByRisk(double sl_distance_price)
{
   if(InpLotMode == LOT_FIXED)
      return InpLotSize;

   sl_distance_price = MathAbs(sl_distance_price);
   if(sl_distance_price == 0.0)
      return InpLotSize;

   double riskPercent = InpRiskPercent / 100.0;
   double riskMoney   = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent;

   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize == 0.0 || tickValue == 0.0)
      return InpLotSize;

   double sl_ticks = sl_distance_price / tickSize;
   if(sl_ticks <= 0.0)
      return InpLotSize;

   double lot = riskMoney / (sl_ticks * tickValue);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(lotStep == 0.0) lotStep = 0.01;

   lot = MathFloor(lot / lotStep) * lotStep;
   double lotMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double lotMax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   lot = MathMax(lot, lotMin);
   lot = MathMin(lot, lotMax);

   return lot;
}

//+------------------------------------------------------------------+
//| Daily Limit Functions                                            |
//+------------------------------------------------------------------+
void ResetDailyIfNewDay()
{
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   datetime day_start = StringToTime(TimeToString(now, TIME_DATE));
   if(day_start > g_last_day)
   {
      g_last_day = day_start;
      g_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_daily_max_equity = g_start_equity;
      g_trade_allowed = true;
      Print("New day. Start equity: ", DoubleToString(g_start_equity, 2));
   }
}

void CheckDailyLimits()
{
   ResetDailyIfNewDay();
   if(!g_trade_allowed || !InpUseDailyLimit) return;

   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(current_equity > g_daily_max_equity) g_daily_max_equity = current_equity;

   double lossPercent = (g_start_equity - current_equity) / g_start_equity * 100.0;
   if(lossPercent >= InpDailyLossPercent)
   {
      g_trade_allowed = false;
      Print("Daily loss limit reached. Trading stopped.");
      return;
   }

   double drawdownPercent = (g_daily_max_equity - current_equity) / g_daily_max_equity * 100.0;
   if(drawdownPercent >= InpDailyDrawdownPercent)
   {
      g_trade_allowed = false;
      Print("Daily drawdown limit reached. Trading stopped.");
   }
}

//+------------------------------------------------------------------+
//| Manage Trailing Stop (KVR-based)                                 |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
   if(!InpUseKVRTrailing) return;
   double kvr = GetKVR(1);
   if(kvr <= 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         double price = PositionGetDouble(POSITION_PRICE_CURRENT);
         double sl = PositionGetDouble(POSITION_SL);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double tp = PositionGetDouble(POSITION_TP);

         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            double profit_points = (price - open_price) / _Point;
            if(profit_points >= InpKVRTrailingStart * kvr / _Point)
            {
               double new_sl = price - InpKVRTrailingStop * kvr;
               if(new_sl > sl + InpKVRTrailingStep * kvr)
               {
                  if(new_sl > sl)
                     trade.PositionModify(ticket, NormalizeDouble(new_sl, _Digits), tp);
               }
            }
         }
         else // SELL
         {
            double profit_points = (open_price - price) / _Point;
            if(profit_points >= InpKVRTrailingStart * kvr / _Point)
            {
               double new_sl = price + InpKVRTrailingStop * kvr;
               if(new_sl < sl - InpKVRTrailingStep * kvr)
               {
                  if(new_sl < sl || sl == 0)
                     trade.PositionModify(ticket, NormalizeDouble(new_sl, _Digits), tp);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Hard Close Profit by KVR                                         |
//+------------------------------------------------------------------+
void CheckHardCloseProfit()
{
   if(!InpUseHardCloseProfit) return;
   double kvr = GetKVR(1);
   if(kvr <= 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         double price = PositionGetDouble(POSITION_PRICE_CURRENT);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double profit_points;

         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            profit_points = (price - open_price) / _Point;
         else
            profit_points = (open_price - price) / _Point;

         if(profit_points >= InpHardCloseProfitKVR * kvr / _Point)
         {
            trade.PositionClose(ticket);
            Print("Hard close profit reached. Closing position #", ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check New Signal – Close opposite and open new                   |
//+------------------------------------------------------------------+
void CheckNewSignal()
{
   int signal = GetSignal();
   if(signal == 0) return;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
      {
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         bool opposite = false;
         if(type == POSITION_TYPE_BUY && signal == -1) opposite = true;
         if(type == POSITION_TYPE_SELL && signal == 1) opposite = true;

         if(opposite)
         {
            trade.PositionClose(ticket);

            double kvr = GetKVR(1);
            if(kvr <= 0) return;

            double lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
            double entry_price, sl, tp;

            if(signal == 1) // BUY
            {
               entry_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               sl = entry_price - kvr * InpKVRMultiplierSL;
               tp = entry_price + kvr * InpKVRMultiplierTP;
               trade.Buy(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "New Signal BUY");
            }
            else // SELL
            {
               entry_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               sl = entry_price + kvr * InpKVRMultiplierSL;
               tp = entry_price - kvr * InpKVRMultiplierTP;
               trade.Sell(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "New Signal SELL");
            }
            Print("New signal detected. Closed opposite position and opened new one.");
            break;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Main Tick                                                        |
//+------------------------------------------------------------------+
void OnTick()
{
   ManageTrailingStop();

   CheckDailyLimits();
   if(!g_trade_allowed) return;

   CheckHardCloseProfit();

   if(!IsNewBar()) return;

   if(PositionsTotal() > 0)
   {
      CheckNewSignal();
   }

   if(PositionsTotal() == 0)
   {
      if((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > InpMaxSpread)
      {
         Print("Spread too high: ", SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
         return;
      }

      int signal = GetSignal();
      if(signal == 0) return;

      double kvr = GetKVR(1);
      if(kvr <= 0) return;

      double lot = CalculateLotByRisk(kvr * InpKVRMultiplierSL);
      double entry_price, sl, tp;

      if(signal == 1) // BUY
      {
         entry_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         sl = entry_price - kvr * InpKVRMultiplierSL;
         tp = entry_price + kvr * InpKVRMultiplierTP;
         trade.Buy(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Pure KCI BUY");
         Print("Buy order placed. Lot: ", lot, " SL: ", sl, " TP: ", tp);
      }
      else if(signal == -1) // SELL
      {
         entry_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         sl = entry_price + kvr * InpKVRMultiplierSL;
         tp = entry_price - kvr * InpKVRMultiplierTP;
         trade.Sell(lot, _Symbol, entry_price, NormalizeDouble(sl, _Digits), NormalizeDouble(tp, _Digits), "Pure KCI SELL");
         Print("Sell order placed. Lot: ", lot, " SL: ", sl, " TP: ", tp);
      }
   }
}

*/

/* // aggressive Parameter [old] ================================

input group "=== KCI Computing Core ==="
input int    ZScorePeriod          = 30;   // Z-Score period
input double CompressionThreshold  = 2.0;  // Compression threshold
input int    BasePeriod            = 9;    // Base period

input group "=== KCI Trend Filter (MTF) ==="
input bool   InpUseTrendFilter   = false;          // Enable KCI Trend Filter
input ENUM_TIMEFRAMES InpTrendTF = PERIOD_CURRENT; // KCI Trend Timeframe
input int    InpTrendBasePeriod  = 34;             // KCI Trend Base Period

//--- Input Groups
input group "=== Trade Execution ==="
input ulong  InpMagicNumber  = 77720265;   // Magic number
input int    InpSlippage     = 10;         // Maximum slippage
input int    InpMaxSpread    = 200;        // Maximum spread (points)

input group "=== Money Management & Risk ==="
input ENUM_LOT_MODE InpLotMode = LOT_RISK; // Lot mode
input double InpLotSize      = 0.01;       // Fixed lot size (if mode = Fixed)
input double InpRiskPercent  = 1.0;        // Risk % per trade (if mode = Risk)
input int    InpKVRPeriod    = 14;         // KVR period (Embedded Native)
input double InpKVRMultiplierSL = 1.5;     // SL multiplier (KVR)
input double InpKVRMultiplierTP = 4.0;     // TP multiplier (KVR)

input group "=== Aggressive Trailing Stop (KVR-based) ==="
input bool   InpUseKVRTrailing = true;     // Enable KVR trailing
input double InpKVRTrailingStart = 0.08;   // Trailing start (KVR units) (2.0 = standard)
input double InpKVRTrailingStep  = 0.02;   // Trailing step (KVR units) (0.5 = standard)
input double InpKVRTrailingStop  = 0.15;   // Trailing stop distance (KVR units) (1.0 = standard)

input group "=== Hard Close Profit ==="
input bool   InpUseHardCloseProfit = true; // Enable hard close profit
input double InpHardCloseProfitKVR = 2.0;  // Profit target (KVR units)

input group "=== Daily Limits ==="
input bool   InpUseDailyLimit = false;
input double InpDailyLossPercent = 20.0;    // Max daily loss %
input double InpDailyDrawdownPercent = 10.0; // Max daily drawdown %

*/ // end aggressive parameter

/*
This project is intended as a technical demonstration and development reference.
It is not a recommendation to trade, invest, or deploy the software in a live trading
environment without extensive independent testing and validation.
*/

/*
input group "=== KCI Computing Core ==="
input int    ZScorePeriod          = 60;   // Z-Score period
input double CompressionThreshold  = 1.8;  // Compression threshold
input int    BasePeriod            = 21;   // Base period

input group "=== KCI Trend Filter (MTF) ==="
input bool   InpUseTrendFilter   = true;         // Enable KCI Trend Filter
input ENUM_TIMEFRAMES InpTrendTF = PERIOD_M15;   // KCI Trend Timeframe
input int    InpTrendBasePeriod  = 34;           // KCI Trend Base Period

input group "=== Trade Execution ==="
input ulong  InpMagicNumber  = 77720265;   // Magic number
input int    InpSlippage     = 20;         // Maximum slippage
input int    InpMaxSpread    = 100;        // Maximum spread (points)

input group "=== Money Management & Risk ==="
input ENUM_LOT_MODE InpLotMode = LOT_RISK; // Lot mode
input double InpLotSize      = 0.01;       // Fixed lot size (if mode = Fixed)
input double InpRiskPercent  = 1.0;        // Risk % per trade (if mode = Risk)
input int    InpKVRPeriod    = 14;         // KVR period (Embedded Native)
input double InpKVRMultiplierSL = 1.5;     // SL multiplier (KVR)
input double InpKVRMultiplierTP = 3.5;     // TP multiplier (KVR)

input group "=== Aggresive Trailing Stop (KVR-based) ==="
input bool   InpUseKVRTrailing = true;     // Enable KVR trailing
input double InpKVRTrailingStart = 1.0;    // Trailing start (KVR units) (2.0 = standard)
input double InpKVRTrailingStep  = 0.2;    // Slide SL every time the price moves 0.2 KVR.
input double InpKVRTrailingStop  = 0.5;    // Trailing stop distance (KVR units) (1.0 = standard)

input group "=== Hard Close Profit ==="
input bool   InpUseHardCloseProfit = true; // Enable hard close profit
input double InpHardCloseProfitKVR = 3.0;  // Profit target (KVR units)

input group "=== Daily Limits ==="
input bool   InpUseDailyLimit = true;       // Daily Limit en|dis
input double InpDailyLossPercent = 10.0;    // Limit daily losses to a maximum of 10%. (10 consecutive SL).
input double InpDailyDrawdownPercent = 5.0; // Maximum floating drawdown 5%.
*/

// ------- ♥ ♥ ♥ ------- [ ⠁⠅⠥ ⠉⠊⠝⠞⠁ ⠅⠁⠇⠊⠁⠝ ]
// If you want to be kind, and give me a coffee (while we discuss code).
// buy my indicator (any of them) thanks for the coffee.
// https://www.mql5.com/en/users/ritzfalih/seller
// syamsurizal dimjati
//+------------------------------------------------------------------+