//+------------------------------------------------------------------+
//|                                                PLAYGROUND_EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Experimental trading modes - Encroachment & Liquidity Scalping"
/*
I figured it out lol anyways this EA is called the Playground EA what it basically does:
trades using the Enc point in fvg as the baise for trades
if price closes above it then we buy and if it closes below we sell
I also added the liqudity function but unfortunatly it doesn't work so i removed it in v1.01'
Another issue of it was that trades immediately closed so yeah didnt work lol
*/

#include <FVGLibrary.mqh>
#include <LiquidityLibrary.mqh>


//--- Trading modes enumeration
enum ENUM_PLAYGROUND_MODE
{
   PLAYGROUND_ENCROACHMENT_SCALP,    // Encroachment Scalping Mode
   PLAYGROUND_LIQUIDITY_SCALP        // Liquidity Scalping Mode
};

//--- Volatility calculation method
enum ENUM_VOLATILITY_METHOD
{
   VOLATILITY_ATR,                   // ATR-based
   VOLATILITY_RANGE,                 // Price Range-based
   VOLATILITY_VOLUME                 // Volume-based
};

//--- Input parameters
input group "=== PLAYGROUND MODE SELECTION ==="
input ENUM_PLAYGROUND_MODE InpPlaygroundMode = PLAYGROUND_ENCROACHMENT_SCALP; // Experimental Mode
input string InpModeInfo = "ENC_SCALP: Close vs ENC | LIQ_SCALP: Liquidity sweeps"; // Mode Info

input group "=== FVG Settings ==="
input double InpMinGapSize = 50.0;               // Minimum gap size in points
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_M5;  // FVG detection timeframe
input ENUM_TIMEFRAMES InpAccuracyTF = PERIOD_M1; // Accuracy timeframe
input bool InpAccuracy = false;                  // Use 1M entry precision
input bool InpDrawObjects = true;                // Draw visual objects

input group "=== Trading Settings ==="
input double InpBaseLotSize = 0.01;             // Base lot size
input double InpEProfit = 0.10;                  // Profit target ($)
input double InpELoss = 0.10;                    // Loss threshold ($)
input bool InpUseStopLoss = true;                // Use stop loss

input group "=== Dynamic Lot Sizing ==="
input bool InpUseDynamicLots = false;            // Enable dynamic lot sizing
input ENUM_VOLATILITY_METHOD InpVolatilityMethod = VOLATILITY_ATR; // Volatility calculation method
input int InpVolatilityPeriod = 14;              // Period for volatility calculation
input double InpHighVolatilityThreshold = 1.5;   // High volatility multiplier
input double InpLowVolatilityLotSize = 0.02;     // Lot size for low volatility
input double InpHighVolatilityLotSize = 0.01;    // Lot size for high volatility

input group "=== Encroachment Scalping Settings ==="
input bool InpEncScalpUseFilters = true;         // Use additional filters
input int InpEncScalpMinGapPoints = 30;          // Minimum gap size for scalp entry
input bool InpEncScalpCheckTrend = false;        // Check trend alignment
input int InpEncScalpTrendPeriod = 20;           // Trend MA period

input group "=== Liquidity Scalping Settings ==="
input bool InpLiqScalpUseSessionFilter = true;   // Use session timing filter
input double InpLiqScalpMinDistance = 10.0;      // Min pips from liquidity level
input bool InpLiqScalpTradeOnSweep = true;       // Trade immediately on sweep
input bool InpLiqScalpWaitForRetrace = false;    // Wait for retrace after sweep

input group "=== Stop Loss Settings ==="
input bool InpUseFixedSL = false;                // Use fixed SL instead of FVG-based
input double InpFixedSLPoints = 100.0;           // Fixed SL in points
input bool InpUseTrailingSL = false;             // Enable trailing stop
input double InpTrailingStart = 50.0;            // Trailing start (points)
input double InpTrailingStep = 20.0;             // Trailing step (points)

//--- Global variables
CFVGLibrary* fvg_lib;
CLiquidityLibrary* liq_lib;
int atr_handle = INVALID_HANDLE;
int trend_ma_handle = INVALID_HANDLE;

//--- EA Magic number
const int EA_MAGIC = 9999;

//--- Trade tracking
struct PlaygroundTrade
{
   ulong ticket;
   int fvg_id;
   int liq_id;
   double entry_price;
   double stop_loss;
   double take_profit;
   datetime entry_time;
   string trade_type; // "ENC_SCALP" or "LIQ_SCALP"
   bool trailing_active;
};
PlaygroundTrade active_trades[];
int trade_count = 0;

//--- Volatility tracking
double current_volatility = 0.0;
bool is_high_volatility = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== PLAYGROUND EA - Experimental Trading System ===");
   Print("Mode: ", EnumToString(InpPlaygroundMode));
   
   // Initialize FVG Library
   fvg_lib = new CFVGLibrary(_Symbol, InpTimeframe, InpAccuracyTF, 
                            InpMinGapSize, InpAccuracy, InpDrawObjects);
   
   if(!fvg_lib.Init())
   {
      Print("Failed to initialize FVG Library!");
      return(INIT_FAILED);
   }
   fvg_lib.SetCallback(OnFVGEvent);
   
   // Initialize Liquidity Library
   liq_lib = new CLiquidityLibrary(_Symbol, InpTimeframe, 0, InpDrawObjects);
   
   if(!liq_lib.Init())
   {
      Print("Failed to initialize Liquidity Library!");
      return(INIT_FAILED);
   }
   liq_lib.SetCallback(OnLiquidityEvent);
   
   // Initialize indicators
   if(InpUseDynamicLots && InpVolatilityMethod == VOLATILITY_ATR)
   {
      atr_handle = iATR(_Symbol, InpTimeframe, InpVolatilityPeriod);
      if(atr_handle == INVALID_HANDLE)
      {
         Print("Failed to create ATR indicator!");
         return(INIT_FAILED);
      }
   }
   
   if(InpEncScalpCheckTrend && InpPlaygroundMode == PLAYGROUND_ENCROACHMENT_SCALP)
   {
      trend_ma_handle = iMA(_Symbol, InpTimeframe, InpEncScalpTrendPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if(trend_ma_handle == INVALID_HANDLE)
      {
         Print("Failed to create trend MA indicator!");
         return(INIT_FAILED);
      }
   }
   
   // Initialize trade array
   ArrayResize(active_trades, 50);
   trade_count = 0;
   
   PrintConfiguration();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(fvg_lib != NULL)
   {
      fvg_lib.PrintFVGStats();
      fvg_lib.Deinit();
      delete fvg_lib;
      fvg_lib = NULL;
   }
   
   if(liq_lib != NULL)
   {
      liq_lib.PrintLiquidityStats();
      liq_lib.Deinit();
      delete liq_lib;
      liq_lib = NULL;
   }
   
   if(atr_handle != INVALID_HANDLE)
      IndicatorRelease(atr_handle);
   
   if(trend_ma_handle != INVALID_HANDLE)
      IndicatorRelease(trend_ma_handle);
   
   Print("=== PLAYGROUND EA Deinitialized ===");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Update libraries
   if(fvg_lib != NULL) fvg_lib.OnTick();
   if(liq_lib != NULL) liq_lib.OnTick();
   
   // Update volatility if using dynamic lots
   if(InpUseDynamicLots)
      UpdateVolatility();
   
   // Manage open positions
   ManageOpenPositions();
}

//+------------------------------------------------------------------+
//| FVG Event Callback                                               |
//+------------------------------------------------------------------+
void OnFVGEvent(FVGInfo& fvg, string event_type)
{
   if(event_type == "FVG_FORMED")
   {
      Print("=== FVG FORMED ===");
      Print("ID: ", fvg.fvg_id, " | Type: ", (fvg.is_bullish ? "BULLISH" : "BEARISH"));
      Print("Size: ", DoubleToString(fvg.gap_size, 1), " points");
   }
   else if(event_type == "FVG_ENCROACHED" || event_type == "FVG_ENCROACHED_HA")
   {
      Print("=== FVG ENCROACHED ===");
      Print("ID: ", fvg.fvg_id, " | Bias: ", fvg.directional_bias);
      
      // Encroachment Scalping Mode
      if(InpPlaygroundMode == PLAYGROUND_ENCROACHMENT_SCALP)
      {
         HandleEncroachmentScalp(fvg);
      }
   }
   else if(event_type == "FVG_RESET")
   {
      Print("=== FVG RESET ===");
      Print("ID: ", fvg.fvg_id, " invalidated by inverse candle");
   }
}

//+------------------------------------------------------------------+
//| Liquidity Event Callback                                         |
//+------------------------------------------------------------------+
void OnLiquidityEvent(LiquidityInfo& liq, string event_type)
{
   if(event_type == "LIQUIDITY_CREATED")
   {
      Print("=== LIQUIDITY CREATED ===");
      Print("ID: ", liq.liquidity_id, " | Type: ", EnumToString(liq.type));
      Print("Price: ", DoubleToString(liq.price_level, _Digits));
   }
   else if(event_type == "LIQUIDITY_SWEPT")
   {
      Print("=== LIQUIDITY SWEPT ===");
      Print("ID: ", liq.liquidity_id, " | Type: ", EnumToString(liq.type));
      Print("Price: ", DoubleToString(liq.price_level, _Digits));
      
      // Liquidity Scalping Mode
      if(InpPlaygroundMode == PLAYGROUND_LIQUIDITY_SCALP)
      {
         HandleLiquidityScalp(liq);
      }
   }
}

//+------------------------------------------------------------------+
//| Handle Encroachment Scalping                                     |
//+------------------------------------------------------------------+
void HandleEncroachmentScalp(FVGInfo& fvg)
{
   // Check if we should enter based on filters
   if(!ShouldEnterEncScalp(fvg))
   {
      Print("Encroachment scalp filters not met - skipping");
      return;
   }
   
   double current_close = iClose(_Symbol, InpTimeframe, 0);
   string trade_direction = "";
   
   // Determine direction based on close relative to ENC point
   if(current_close > fvg.enc_point)
      trade_direction = "BUY";
   else if(current_close < fvg.enc_point)
      trade_direction = "SELL";
   else
   {
      Print("Close exactly at ENC point - no trade");
      return;
   }
   
   Print("=== ENCROACHMENT SCALP SIGNAL ===");
   Print("FVG ID: ", fvg.fvg_id);
   Print("ENC Point: ", DoubleToString(fvg.enc_point, _Digits));
   Print("Current Close: ", DoubleToString(current_close, _Digits));
   Print("Direction: ", trade_direction);
   
   // Calculate lot size
   double lot_size = CalculateLotSize();
   
   // Calculate stop loss
   double stop_loss = 0.0;
   if(InpUseStopLoss)
   {
      if(InpUseFixedSL)
      {
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         stop_loss = (trade_direction == "BUY") ? 
                     current_close - (InpFixedSLPoints * point) :
                     current_close + (InpFixedSLPoints * point);
      }
      else
      {
         // Use FVG boundaries as stop loss
         stop_loss = (trade_direction == "BUY") ? fvg.bottom_price : fvg.top_price;
      }
   }
   
   // Open trade
   ulong ticket = 0;
   if(trade_direction == "BUY")
      ticket = OpenBuy(lot_size);
   else if(trade_direction == "SELL")
      ticket = OpenSell(lot_size);
   
   if(ticket > 0)
   {
      // Store trade info
      StoreTrade(ticket, fvg.fvg_id, 0, current_close, stop_loss, "ENC_SCALP");
      
      Print("=== ENCROACHMENT SCALP OPENED ===");
      Print("Ticket: ", ticket);
      Print("Lot Size: ", lot_size);
      Print("Stop Loss: ", DoubleToString(stop_loss, _Digits));
      Print("================================");
   }
}

//+------------------------------------------------------------------+
//| Handle Liquidity Scalping                                        |
//+------------------------------------------------------------------+
void HandleLiquidityScalp(LiquidityInfo& liq)
{
   // Check session filter
   if(InpLiqScalpUseSessionFilter && !IsInOptimalSession())
   {
      Print("Outside optimal session for liquidity scalping");
      return;
   }
   
   // Check if we should trade immediately or wait for retrace
   if(InpLiqScalpWaitForRetrace)
   {
      Print("Liquidity swept - waiting for retrace setup");
      // This would require additional logic to track retraces
      return;
   }
   
   if(!InpLiqScalpTradeOnSweep)
   {
      Print("Trade on sweep disabled - liquidity noted");
      return;
   }
   
   // Determine trade direction based on liquidity type
   string trade_direction = "";
   double current_price = iClose(_Symbol, InpTimeframe, 0);
   
   // Check minimum distance from liquidity level
   double distance_pips = MathAbs(liq.price_level - current_price) / (SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10);
   if(distance_pips < InpLiqScalpMinDistance)
   {
      Print("Too close to liquidity level (", DoubleToString(distance_pips, 1), " pips) - minimum: ", InpLiqScalpMinDistance);
      return;
   }
   
   // Determine direction based on liquidity type and sweep
   if(liq.type == LIQUIDITY_SWING_HIGH || liq.type == LIQUIDITY_EQUAL_HIGHS ||
      liq.type == LIQUIDITY_PDH || liq.type == LIQUIDITY_PWH)
   {
      // Buy side liquidity swept - expect reversal down
      trade_direction = "SELL";
   }
   else if(liq.type == LIQUIDITY_SWING_LOW || liq.type == LIQUIDITY_EQUAL_LOWS ||
           liq.type == LIQUIDITY_PDL || liq.type == LIQUIDITY_PWL)
   {
      // Sell side liquidity swept - expect reversal up
      trade_direction = "BUY";
   }
   
   if(trade_direction == "")
   {
      Print("Cannot determine trade direction from liquidity type");
      return;
   }
   
   Print("=== LIQUIDITY SCALP SIGNAL ===");
   Print("Liquidity ID: ", liq.liquidity_id);
   Print("Type: ", EnumToString(liq.type));
   Print("Level: ", DoubleToString(liq.price_level, _Digits));
   Print("Direction: ", trade_direction);
   
   // Calculate lot size
   double lot_size = CalculateLotSize();
   
   // Calculate stop loss (beyond the swept liquidity)
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double stop_loss = 0.0;
   if(InpUseStopLoss)
   {
      if(InpUseFixedSL)
      {
         stop_loss = (trade_direction == "BUY") ? 
                     current_price - (InpFixedSLPoints * point) :
                     current_price + (InpFixedSLPoints * point);
      }
      else
      {
         // Place stop beyond the liquidity level
         double buffer = 20 * point; // 20 point buffer
         stop_loss = (trade_direction == "BUY") ? 
                     liq.price_level - buffer :
                     liq.price_level + buffer;
      }
   }
   
   // Open trade
   ulong ticket = 0;
   if(trade_direction == "BUY")
      ticket = OpenBuy(lot_size);
   else if(trade_direction == "SELL")
      ticket = OpenSell(lot_size);
   
   if(ticket > 0)
   {
      // Store trade info
      StoreTrade(ticket, 0, liq.liquidity_id, current_price, stop_loss, "LIQ_SCALP");
      
      Print("=== LIQUIDITY SCALP OPENED ===");
      Print("Ticket: ", ticket);
      Print("Lot Size: ", lot_size);
      Print("Stop Loss: ", DoubleToString(stop_loss, _Digits));
      Print("===============================");
   }
}

//+------------------------------------------------------------------+
//| Check if should enter encroachment scalp                        |
//+------------------------------------------------------------------+
bool ShouldEnterEncScalp(FVGInfo& fvg)
{
   if(!InpEncScalpUseFilters)
      return true;
   
   // Check minimum gap size
   if(fvg.gap_size < InpEncScalpMinGapPoints)
   {
      Print("FVG gap too small: ", fvg.gap_size, " < ", InpEncScalpMinGapPoints);
      return false;
   }
   
   // Check trend alignment if enabled
   if(InpEncScalpCheckTrend)
   {
      if(!IsTrendAligned(fvg))
      {
         Print("Trend not aligned with FVG");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if trend is aligned                                        |
//+------------------------------------------------------------------+
bool IsTrendAligned(FVGInfo& fvg)
{
   if(trend_ma_handle == INVALID_HANDLE)
      return true;
   
   double ma_values[2];
   if(CopyBuffer(trend_ma_handle, 0, 0, 2, ma_values) < 2)
      return true;
   
   double current_price = iClose(_Symbol, InpTimeframe, 0);
   bool is_uptrend = (current_price > ma_values[0] && ma_values[0] > ma_values[1]);
   bool is_downtrend = (current_price < ma_values[0] && ma_values[0] < ma_values[1]);
   
   // For bullish FVG, prefer uptrend
   if(fvg.is_bullish && is_uptrend)
      return true;
   
   // For bearish FVG, prefer downtrend
   if(!fvg.is_bullish && is_downtrend)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Check if in optimal trading session                             |
//+------------------------------------------------------------------+
bool IsInOptimalSession()
{
   // London or New York sessions are typically best for liquidity
   return liq_lib.IsInSession(SESSION_LONDON) || 
          liq_lib.IsInSession(SESSION_NEW_YORK);
}

//+------------------------------------------------------------------+
//| Update volatility measurement                                    |
//+------------------------------------------------------------------+
void UpdateVolatility()
{
   if(InpVolatilityMethod == VOLATILITY_ATR && atr_handle != INVALID_HANDLE)
   {
      double atr_values[1];
      if(CopyBuffer(atr_handle, 0, 0, 1, atr_values) > 0)
      {
         double atr = atr_values[0];
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double average_range = 100 * point; // 100 points as baseline
         
         current_volatility = atr / average_range;
         is_high_volatility = (current_volatility >= InpHighVolatilityThreshold);
      }
   }
   else if(InpVolatilityMethod == VOLATILITY_RANGE)
   {
      double total_range = 0.0;
      for(int i = 1; i <= InpVolatilityPeriod; i++)
      {
         double high = iHigh(_Symbol, InpTimeframe, i);
         double low = iLow(_Symbol, InpTimeframe, i);
         total_range += (high - low);
      }
      
      double avg_range = total_range / InpVolatilityPeriod;
      double recent_range = iHigh(_Symbol, InpTimeframe, 0) - iLow(_Symbol, InpTimeframe, 0);
      
      current_volatility = recent_range / avg_range;
      is_high_volatility = (current_volatility >= InpHighVolatilityThreshold);
   }
   else if(InpVolatilityMethod == VOLATILITY_VOLUME)
   {
      long total_volume = 0;
      for(int i = 1; i <= InpVolatilityPeriod; i++)
      {
         total_volume += iVolume(_Symbol, InpTimeframe, i);
      }
      
      double avg_volume = (double)total_volume / InpVolatilityPeriod;
      long recent_volume = iVolume(_Symbol, InpTimeframe, 0);
      
      current_volatility = (double)recent_volume / avg_volume;
      is_high_volatility = (current_volatility >= InpHighVolatilityThreshold);
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on volatility                          |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   if(!InpUseDynamicLots)
      return InpBaseLotSize;
   
   double lot_size = InpBaseLotSize;
   
   if(is_high_volatility)
   {
      lot_size = InpHighVolatilityLotSize;
      Print("High volatility detected (", DoubleToString(current_volatility, 2), 
            ") - using lot size: ", lot_size);
   }
   else
   {
      lot_size = InpLowVolatilityLotSize;
      Print("Low volatility detected (", DoubleToString(current_volatility, 2), 
            ") - using lot size: ", lot_size);
   }
   
   return lot_size;
}

//+------------------------------------------------------------------+
//| Store trade information                                          |
//+------------------------------------------------------------------+
void StoreTrade(ulong ticket, int fvg_id, int liq_id, double entry_price, 
                double stop_loss, string trade_type)
{
   if(trade_count >= ArraySize(active_trades))
      ArrayResize(active_trades, ArraySize(active_trades) + 20);
   
   active_trades[trade_count].ticket = ticket;
   active_trades[trade_count].fvg_id = fvg_id;
   active_trades[trade_count].liq_id = liq_id;
   active_trades[trade_count].entry_price = entry_price;
   active_trades[trade_count].stop_loss = stop_loss;
   active_trades[trade_count].entry_time = TimeCurrent();
   active_trades[trade_count].trade_type = trade_type;
   active_trades[trade_count].trailing_active = false;
   
   trade_count++;
}

//+------------------------------------------------------------------+
//| Trading functions                                                |
//+------------------------------------------------------------------+
ulong OpenBuy(double lotSize) 
{
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = lotSize;
    request.type = ORDER_TYPE_BUY;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    request.deviation = 20;
    request.type_filling = ORDER_FILLING_FOK;
    request.magic = EA_MAGIC;
    
    if (OrderSend(request, result)) {
        if (result.deal > 0) {
            Print("Buy order opened. Ticket: ", result.deal);
            return result.deal;
        }
    }
    return 0;
}

ulong OpenSell(double lotSize) 
{
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = lotSize;
    request.type = ORDER_TYPE_SELL;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    request.deviation = 20;
    request.type_filling = ORDER_FILLING_FOK;
    request.magic = EA_MAGIC;
    
    if (OrderSend(request, result)) {
        if (result.deal > 0) {
            Print("Sell order opened. Ticket: ", result.deal);
            return result.deal;
        }
    }
    return 0;
}

void CloseBuyByTicket(ulong ticket) 
{
    if (!PositionSelectByTicket(ticket)) return;
    double volume = PositionGetDouble(POSITION_VOLUME);
    double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = volume;
    request.type = ORDER_TYPE_SELL;
    request.price = price;
    request.deviation = 20;
    request.type_filling = ORDER_FILLING_FOK;
    request.position = ticket;
    request.magic = EA_MAGIC;
    
    if (OrderSend(request, result)) {
        Print("Buy position closed. Ticket: ", ticket);
    }
}

void CloseSellByTicket(ulong ticket) 
{
    if (!PositionSelectByTicket(ticket)) return;
    double volume = PositionGetDouble(POSITION_VOLUME);
    double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);
    ZeroMemory(result);
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = volume;
    request.type = ORDER_TYPE_BUY;
    request.price = price;
    request.deviation = 20;
    request.type_filling = ORDER_FILLING_FOK;
    request.position = ticket;
    request.magic = EA_MAGIC;
    
    if (OrderSend(request, result)) {
        Print("Sell position closed. Ticket: ", ticket);
    }
}

//+------------------------------------------------------------------+
//| Manage open positions                                            |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--) 
    {
        ulong ticket = PositionGetTicket(i);
        if (PositionSelectByTicket(ticket)) 
        {
            if (PositionGetString(POSITION_SYMBOL) == _Symbol && 
                (int)PositionGetInteger(POSITION_MAGIC) == EA_MAGIC) 
            {
                double profit = PositionGetDouble(POSITION_PROFIT);
                
                // Close on profit target
                if (profit >= InpEProfit) 
                {
                    Print("Profit target reached. Ticket: ", ticket, " Profit=$", DoubleToString(profit,2));
                    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
                        CloseBuyByTicket(ticket);
                    else 
                        CloseSellByTicket(ticket);
                    continue;
                }
                
                // Close on loss threshold
                if (profit <= -InpELoss) 
                {
                    Print("Loss threshold hit. Ticket: ", ticket);
                    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
                        CloseBuyByTicket(ticket);
                    else 
                        CloseSellByTicket(ticket);
                    continue;
                }
                
                // Check stop loss
                if(InpUseStopLoss)
                {
                    CheckStopLoss(ticket);
                }
                
                // Check trailing stop
                if(InpUseTrailingSL)
                {
                    CheckTrailingStop(ticket);
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Check stop loss                                                  |
//+------------------------------------------------------------------+
void CheckStopLoss(ulong ticket)
{
    double current_bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double current_ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    // Find trade in our tracking array
    for(int i = 0; i < trade_count; i++)
    {
        if(active_trades[i].ticket == ticket)
        {
            if(active_trades[i].stop_loss == 0.0)
                return; // No stop loss set
            
            bool should_close = false;
            
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
                if(current_bid <= active_trades[i].stop_loss)
                {
                    should_close = true;
                    Print("Stop loss hit (BUY). Ticket: ", ticket, 
                          " SL: ", DoubleToString(active_trades[i].stop_loss, _Digits));
                }
            }
            else
            {
                if(current_ask >= active_trades[i].stop_loss)
                {
                    should_close = true;
                    Print("Stop loss hit (SELL). Ticket: ", ticket,
                          " SL: ", DoubleToString(active_trades[i].stop_loss, _Digits));
                }
            }
            
            if(should_close)
            {
                if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                    CloseBuyByTicket(ticket);
                else
                    CloseSellByTicket(ticket);
            }
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Check trailing stop                                              |
//+------------------------------------------------------------------+
void CheckTrailingStop(ulong ticket)
{
    if(!PositionSelectByTicket(ticket)) return;
    
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double current_price = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 
                          SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                          SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
    
    // Find trade in tracking array
    for(int i = 0; i < trade_count; i++)
    {
        if(active_trades[i].ticket == ticket)
        {
            bool is_buy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
            double profit_points = 0.0;
            
            if(is_buy)
                profit_points = (current_price - entry_price) / point;
            else
                profit_points = (entry_price - current_price) / point;
            
            // Check if profit is enough to activate trailing
            if(profit_points >= InpTrailingStart)
            {
                if(!active_trades[i].trailing_active)
                {
                    active_trades[i].trailing_active = true;
                    Print("Trailing stop activated for ticket: ", ticket);
                }
                
                // Calculate new stop loss
                double new_stop = 0.0;
                if(is_buy)
                    new_stop = current_price - (InpTrailingStep * point);
                else
                    new_stop = current_price + (InpTrailingStep * point);
                
                // Update stop loss if it's better
                bool should_update = false;
                if(is_buy && new_stop > active_trades[i].stop_loss)
                    should_update = true;
                else if(!is_buy && (active_trades[i].stop_loss == 0.0 || new_stop < active_trades[i].stop_loss))
                    should_update = true;
                
                if(should_update)
                {
                    active_trades[i].stop_loss = new_stop;
                    Print("Trailing stop updated. Ticket: ", ticket, 
                          " New SL: ", DoubleToString(new_stop, _Digits));
                }
            }
            break;
        }
    }
}

//+------------------------------------------------------------------+
//| Print configuration                                              |
//+------------------------------------------------------------------+
void PrintConfiguration()
{
   Print("=== PLAYGROUND EA CONFIGURATION ===");
   Print("Mode: ", EnumToString(InpPlaygroundMode));
   Print("Timeframe: ", EnumToString(InpTimeframe));
   Print("Min Gap Size: ", InpMinGapSize, " points");
   Print("Base Lot Size: ", InpBaseLotSize);
   Print("Profit Target: $", InpEProfit);
   Print("Loss Threshold: $", InpELoss);
   
   if(InpUseDynamicLots)
   {
      Print("=== DYNAMIC LOT SIZING ===");
      Print("Method: ", EnumToString(InpVolatilityMethod));
      Print("Period: ", InpVolatilityPeriod);
      Print("High Vol Threshold: ", InpHighVolatilityThreshold);
      Print("Low Vol Lot: ", InpLowVolatilityLotSize);
      Print("High Vol Lot: ", InpHighVolatilityLotSize);
   }
   
   if(InpPlaygroundMode == PLAYGROUND_ENCROACHMENT_SCALP)
   {
      Print("=== ENCROACHMENT SCALPING ===");
      Print("Use Filters: ", (InpEncScalpUseFilters ? "YES" : "NO"));
      Print("Min Gap Points: ", InpEncScalpMinGapPoints);
      Print("Check Trend: ", (InpEncScalpCheckTrend ? "YES" : "NO"));
      if(InpEncScalpCheckTrend)
         Print("Trend MA Period: ", InpEncScalpTrendPeriod);
   }
   else if(InpPlaygroundMode == PLAYGROUND_LIQUIDITY_SCALP)
   {
      Print("=== LIQUIDITY SCALPING ===");
      Print("Use Session Filter: ", (InpLiqScalpUseSessionFilter ? "YES" : "NO"));
      Print("Min Distance: ", InpLiqScalpMinDistance, " pips");
      Print("Trade On Sweep: ", (InpLiqScalpTradeOnSweep ? "YES" : "NO"));
      Print("Wait For Retrace: ", (InpLiqScalpWaitForRetrace ? "YES" : "NO"));
   }
   
   Print("=== STOP LOSS SETTINGS ===");
   Print("Use Stop Loss: ", (InpUseStopLoss ? "YES" : "NO"));
   Print("Use Fixed SL: ", (InpUseFixedSL ? "YES" : "NO"));
   if(InpUseFixedSL)
      Print("Fixed SL Points: ", InpFixedSLPoints);
   Print("Use Trailing SL: ", (InpUseTrailingSL ? "YES" : "NO"));
   if(InpUseTrailingSL)
   {
      Print("Trailing Start: ", InpTrailingStart, " points");
      Print("Trailing Step: ", InpTrailingStep, " points");
   }
   
   Print("===================================");
}