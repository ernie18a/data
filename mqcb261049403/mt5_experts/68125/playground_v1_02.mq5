//+------------------------------------------------------------------+
//|                                          PLAYGROUND_EA_v1.02.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.02"
#property description "Disciplined Encroachment Scalping with Silver Bullet Structure"
/*
Playground v1.02 - Made by loki ☠️✨
Two disciplined modes:
1. SILVER_BULLET_ENC: Trade during SB windows, target liquidity zones
2. SIMPLE_ENC: One trade at a time, use Eprofit/Eloss targets
Both modes use ENC point logic: Close above ENC = BUY, Close below ENC = SELL
I personally don't like this v because it uses the defualt timeframe and Enum for the modes which makes it
confusing to me lol so lets move over to v1.03
it should include the proper dol and time windows
*/

#include <FVGLibrary.mqh>
#include <LiquidityLibrary.mqh>

//--- Trading modes enumeration
enum ENUM_PLAYGROUND_MODE
{
   MODE_SILVER_BULLET_ENC,    // Silver Bullet Encroachment (Liquidity targets)
   MODE_SIMPLE_ENC            // Simple Encroachment (One trade at a time)
};

//--- Input parameters
input group "=== PLAYGROUND MODE SELECTION ==="
input ENUM_PLAYGROUND_MODE InpPlaygroundMode = MODE_SILVER_BULLET_ENC; // Trading Mode
input string InpModeInfo = "SB_ENC: Timed+Liquidity | SIMPLE: One at a time"; // Mode Info

input group "=== FVG Settings ==="
input double InpMinGapSize = 50.0;               // Minimum gap size in points
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_M5;  // FVG detection timeframe
input ENUM_TIMEFRAMES InpAccuracyTF = PERIOD_M1; // Accuracy timeframe
input bool InpAccuracy = false;                  // Use 1M entry precision
input bool InpDrawObjects = true;                // Draw visual objects

input group "=== Trading Settings ==="
input double InpLotSize = 0.01;                  // Lot size
input double InpEProfit = 10.0;                  // Profit target ($) - SIMPLE mode only
input double InpELoss = 10.0;                    // Loss threshold ($) - Both modes

input group "=== Silver Bullet ENC Settings ==="
input int InpGMTOffset = 0;                      // GMT offset for session timing
input bool InpTradeSB1 = true;                   // Trade Silver Bullet 1 (3-4am GMT)
input bool InpTradeSB2 = true;                   // Trade Silver Bullet 2 (10-11am GMT)
input bool InpTradeSB3 = true;                   // Trade Silver Bullet 3 (2-3pm GMT)
input double InpMinDOLDistance = 20.0;           // Minimum pips to DOL target
input double InpTarget1Percent = 50.0;           // First target as % to DOL
input double InpTarget2Percent = 80.0;           // Second target as % to DOL

input group "=== Encroachment Filters ==="
input bool InpEncScalpUseFilters = false;        // Use additional filters
input int InpEncScalpMinGapPoints = 30;          // Minimum gap size for entry
input bool InpEncScalpCheckTrend = false;        // Check trend alignment
input int InpEncScalpTrendPeriod = 20;           // Trend MA period

//--- Global variables
CFVGLibrary* fvg_lib;
CLiquidityLibrary* liq_lib;
int trend_ma_handle = INVALID_HANDLE;

//--- EA Magic number
const int EA_MAGIC = 1002;

//--- Trade tracking for Silver Bullet mode
struct SilverBulletTrade
{
   ulong ticket;
   int fvg_id;
   string dol_target;
   double target1_price;
   double target2_price;
   double entry_price;
   datetime entry_time;
   bool target1_hit;
   bool target2_hit;
};
SilverBulletTrade sb_trades[];
int sb_trade_count = 0;

//--- Simple mode tracking
bool simple_mode_has_trade = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== PLAYGROUND EA v1.02 - Disciplined Encroachment ===");
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
   
   // Initialize Liquidity Library for Silver Bullet mode
   if(InpPlaygroundMode == MODE_SILVER_BULLET_ENC)
   {
      liq_lib = new CLiquidityLibrary(_Symbol, InpTimeframe, InpGMTOffset, InpDrawObjects);
      
      if(!liq_lib.Init())
      {
         Print("Failed to initialize Liquidity Library!");
         return(INIT_FAILED);
      }
      liq_lib.SetCallback(OnLiquidityEvent);
   }
   
   // Initialize trend MA if needed
   if(InpEncScalpCheckTrend)
   {
      trend_ma_handle = iMA(_Symbol, InpTimeframe, InpEncScalpTrendPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if(trend_ma_handle == INVALID_HANDLE)
      {
         Print("Failed to create trend MA indicator!");
         return(INIT_FAILED);
      }
   }
   
   // Initialize trade arrays
   ArrayResize(sb_trades, 50);
   sb_trade_count = 0;
   simple_mode_has_trade = false;
   
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
      liq_lib.PrintDailyBias();
      liq_lib.Deinit();
      delete liq_lib;
      liq_lib = NULL;
   }
   
   if(trend_ma_handle != INVALID_HANDLE)
      IndicatorRelease(trend_ma_handle);
   
   Print("=== PLAYGROUND EA v1.02 Deinitialized ===");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Update libraries
   if(fvg_lib != NULL) 
      fvg_lib.OnTick();
   
   if(liq_lib != NULL) 
      liq_lib.OnTick();
   
   // Manage open positions
   ManageOpenPositions();
   
   // Update simple mode trade status
   if(InpPlaygroundMode == MODE_SIMPLE_ENC)
      UpdateSimpleModeStatus();
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
      
      if(InpPlaygroundMode == MODE_SILVER_BULLET_ENC)
      {
         HandleSilverBulletEncroachment(fvg);
      }
      else if(InpPlaygroundMode == MODE_SIMPLE_ENC)
      {
         HandleSimpleEncroachment(fvg);
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
      
      // Update Silver Bullet targets
      UpdateSilverBulletTargets(liq);
   }
}

//+------------------------------------------------------------------+
//| Handle Silver Bullet Encroachment                                |
//+------------------------------------------------------------------+
void HandleSilverBulletEncroachment(FVGInfo& fvg)
{
   // Check if in Silver Bullet window
   if(!IsInSilverBulletWindow())
   {
      Print("Outside Silver Bullet window - FVG noted but no trade");
      return;
   }
   
   // Check filters
   if(!ShouldEnterEncScalp(fvg))
   {
      Print("Encroachment filters not met - skipping");
      return;
   }
   
   // Get current session DOL
   ENUM_SESSION_TYPE current_session = GetCurrentSilverBulletSession();
   if(current_session == -1)
   {
      Print("Cannot determine Silver Bullet session");
      return;
   }
   
   string priority_dol = GetCurrentSessionDOL(current_session);
   double dol_price = liq_lib.GetPriorityLevel(priority_dol);
   
   if(dol_price == 0.0)
   {
      Print("No valid DOL found for session");
      return;
   }
   
   // Check minimum distance to DOL
   double current_price = iClose(_Symbol, InpTimeframe, 0);
   double distance_pips = MathAbs(dol_price - current_price) / (SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10);
   
   if(distance_pips < InpMinDOLDistance)
   {
      Print("DOL too close (", DoubleToString(distance_pips, 1), " pips) - minimum: ", InpMinDOLDistance);
      return;
   }
   
   // Determine trade direction based on ENC logic
   double current_close = iClose(_Symbol, InpTimeframe, 0);
   string trade_direction = "";
   
   if(current_close > fvg.enc_point)
      trade_direction = "BUY";
   else if(current_close < fvg.enc_point)
      trade_direction = "SELL";
   else
   {
      Print("Close exactly at ENC point - no trade");
      return;
   }
   
   Print("=== SILVER BULLET ENC SIGNAL ===");
   Print("FVG ID: ", fvg.fvg_id);
   Print("ENC Point: ", DoubleToString(fvg.enc_point, _Digits));
   Print("Current Close: ", DoubleToString(current_close, _Digits));
   Print("Direction: ", trade_direction);
   Print("DOL Target: ", priority_dol, " (", DoubleToString(dol_price, _Digits), ")");
   Print("Distance: ", DoubleToString(distance_pips, 1), " pips");
   
   // Open trade
   ulong ticket = 0;
   if(trade_direction == "BUY")
      ticket = OpenBuy(InpLotSize);
   else if(trade_direction == "SELL")
      ticket = OpenSell(InpLotSize);
   
   if(ticket > 0)
   {
      // Calculate targets
      double distance_to_dol = MathAbs(dol_price - current_price);
      double target1_price = current_price + (distance_to_dol * InpTarget1Percent / 100.0) * (trade_direction == "BUY" ? 1 : -1);
      double target2_price = current_price + (distance_to_dol * InpTarget2Percent / 100.0) * (trade_direction == "BUY" ? 1 : -1);
      
      // Store Silver Bullet trade
      if(sb_trade_count >= ArraySize(sb_trades))
         ArrayResize(sb_trades, ArraySize(sb_trades) + 20);
      
      sb_trades[sb_trade_count].ticket = ticket;
      sb_trades[sb_trade_count].fvg_id = fvg.fvg_id;
      sb_trades[sb_trade_count].dol_target = priority_dol;
      sb_trades[sb_trade_count].target1_price = target1_price;
      sb_trades[sb_trade_count].target2_price = target2_price;
      sb_trades[sb_trade_count].entry_price = current_price;
      sb_trades[sb_trade_count].entry_time = TimeCurrent();
      sb_trades[sb_trade_count].target1_hit = false;
      sb_trades[sb_trade_count].target2_hit = false;
      sb_trade_count++;
      
      // Associate with FVG
      fvg_lib.AssociateTradeWithFVG(fvg.fvg_id, ticket);
      
      Print("=== SILVER BULLET ENC OPENED ===");
      Print("Ticket: ", ticket);
      Print("Target 1 (", InpTarget1Percent, "%): ", DoubleToString(target1_price, _Digits));
      Print("Target 2 (", InpTarget2Percent, "%): ", DoubleToString(target2_price, _Digits));
      Print("================================");
   }
}

//+------------------------------------------------------------------+
//| Handle Simple Encroachment                                       |
//+------------------------------------------------------------------+
void HandleSimpleEncroachment(FVGInfo& fvg)
{
   // Check if we already have a trade
   if(simple_mode_has_trade)
   {
      Print("Simple mode already has an active trade - skipping");
      return;
   }
   
   // Check filters
   if(!ShouldEnterEncScalp(fvg))
   {
      Print("Encroachment filters not met - skipping");
      return;
   }
   
   // Determine trade direction based on ENC logic
   double current_close = iClose(_Symbol, InpTimeframe, 0);
   string trade_direction = "";
   
   if(current_close > fvg.enc_point)
      trade_direction = "BUY";
   else if(current_close < fvg.enc_point)
      trade_direction = "SELL";
   else
   {
      Print("Close exactly at ENC point - no trade");
      return;
   }
   
   Print("=== SIMPLE ENC SIGNAL ===");
   Print("FVG ID: ", fvg.fvg_id);
   Print("ENC Point: ", DoubleToString(fvg.enc_point, _Digits));
   Print("Current Close: ", DoubleToString(current_close, _Digits));
   Print("Direction: ", trade_direction);
   
   // Open trade
   ulong ticket = 0;
   if(trade_direction == "BUY")
      ticket = OpenBuy(InpLotSize);
   else if(trade_direction == "SELL")
      ticket = OpenSell(InpLotSize);
   
   if(ticket > 0)
   {
      simple_mode_has_trade = true;
      
      // Associate with FVG
      fvg_lib.AssociateTradeWithFVG(fvg.fvg_id, ticket);
      
      Print("=== SIMPLE ENC OPENED ===");
      Print("Ticket: ", ticket);
      Print("Profit Target: $", DoubleToString(InpEProfit, 2));
      Print("Loss Threshold: $", DoubleToString(InpELoss, 2));
      Print("=========================");
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
//| Check if in Silver Bullet window                                |
//+------------------------------------------------------------------+
bool IsInSilverBulletWindow()
{
   if(liq_lib == NULL) return false;
   
   return (liq_lib.IsInSession(SESSION_SILVER_BULLET_1) && InpTradeSB1) ||
          (liq_lib.IsInSession(SESSION_SILVER_BULLET_2) && InpTradeSB2) ||
          (liq_lib.IsInSession(SESSION_SILVER_BULLET_3) && InpTradeSB3);
}

//+------------------------------------------------------------------+
//| Get current Silver Bullet session                               |
//+------------------------------------------------------------------+
ENUM_SESSION_TYPE GetCurrentSilverBulletSession()
{
   if(liq_lib == NULL) return (ENUM_SESSION_TYPE)-1;
   
   if(liq_lib.IsInSession(SESSION_SILVER_BULLET_1) && InpTradeSB1)
      return SESSION_SILVER_BULLET_1;
   else if(liq_lib.IsInSession(SESSION_SILVER_BULLET_2) && InpTradeSB2)
      return SESSION_SILVER_BULLET_2;
   else if(liq_lib.IsInSession(SESSION_SILVER_BULLET_3) && InpTradeSB3)
      return SESSION_SILVER_BULLET_3;
   
   return (ENUM_SESSION_TYPE)-1;
}

//+------------------------------------------------------------------+
//| Get current session DOL priority                                |
//+------------------------------------------------------------------+
string GetCurrentSessionDOL(ENUM_SESSION_TYPE session)
{
   if(liq_lib == NULL) return "UNKNOWN";
   
   // Priority list based on session
   string priority = liq_lib.GetSilverBulletPriority(session, 0);
   double priority_price = liq_lib.GetPriorityLevel(priority);
   
   if(priority_price != 0.0)
      return priority;
   
   // Try next priorities
   for(int i = 1; i < 7; i++)
   {
      priority = liq_lib.GetSilverBulletPriority(session, i);
      priority_price = liq_lib.GetPriorityLevel(priority);
      if(priority_price != 0.0)
         return priority;
   }
   
   return "UNKNOWN";
}

//+------------------------------------------------------------------+
//| Update Silver Bullet targets                                     |
//+------------------------------------------------------------------+
void UpdateSilverBulletTargets(LiquidityInfo& swept_liq)
{
   for(int i = 0; i < sb_trade_count; i++)
   {
      if(!PositionSelectByTicket(sb_trades[i].ticket))
         continue;
      
      double current_price = iClose(_Symbol, InpTimeframe, 0);
      bool is_buy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      
      // Check Target 1
      if(!sb_trades[i].target1_hit)
      {
         bool target1_reached = is_buy ? (current_price >= sb_trades[i].target1_price) : 
                                        (current_price <= sb_trades[i].target1_price);
         if(target1_reached)
         {
            ClosePartialPosition(sb_trades[i].ticket, 50); // Close 50%
            sb_trades[i].target1_hit = true;
            Print(">>> Target 1 hit for ticket: ", sb_trades[i].ticket);
         }
      }
      
      // Check Target 2
      if(!sb_trades[i].target2_hit && sb_trades[i].target1_hit)
      {
         bool target2_reached = is_buy ? (current_price >= sb_trades[i].target2_price) : 
                                        (current_price <= sb_trades[i].target2_price);
         if(target2_reached)
         {
            if(is_buy) CloseBuyByTicket(sb_trades[i].ticket);
            else CloseSellByTicket(sb_trades[i].ticket);
            sb_trades[i].target2_hit = true;
            Print(">>> Target 2 hit for ticket: ", sb_trades[i].ticket, " - Position fully closed");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Update simple mode trade status                                  |
//+------------------------------------------------------------------+
void UpdateSimpleModeStatus()
{
   // Check if we still have an active trade
   bool has_active = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && 
            (int)PositionGetInteger(POSITION_MAGIC) == EA_MAGIC)
         {
            has_active = true;
            break;
         }
      }
   }
   
   simple_mode_has_trade = has_active;
}

//+------------------------------------------------------------------+
//| Close partial position                                           |
//+------------------------------------------------------------------+
void ClosePartialPosition(ulong ticket, int percentage)
{
   if(!PositionSelectByTicket(ticket)) return;
   
   double volume = PositionGetDouble(POSITION_VOLUME);
   double close_volume = NormalizeDouble(volume * percentage / 100.0, 2);
   
   if(close_volume < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
      return;
   
   bool is_buy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
   double price = is_buy ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = close_volume;
   request.type = is_buy ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   request.price = price;
   request.deviation = 20;
   request.type_filling = ORDER_FILLING_FOK;
   request.position = ticket;
   request.magic = EA_MAGIC;
   
   if(OrderSend(request, result))
   {
      Print("Partial close (", percentage, "%) successful. Ticket: ", ticket);
   }
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
                
                // Mode-specific handling
                if(InpPlaygroundMode == MODE_SIMPLE_ENC)
                {
                    // Simple mode: Use Eprofit and Eloss
                    if (profit >= InpEProfit) 
                    {
                        Print(">>> PROFIT TARGET REACHED <<<");
                        Print("Ticket: ", ticket, " | Profit: $", DoubleToString(profit, 2));
                        
                        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
                            CloseBuyByTicket(ticket);
                        else 
                            CloseSellByTicket(ticket);
                        
                        simple_mode_has_trade = false;
                        continue;
                    }
                    
                    if (profit <= -InpELoss) 
                    {
                        Print(">>> LOSS THRESHOLD HIT <<<");
                        Print("Ticket: ", ticket, " | Loss: $", DoubleToString(profit, 2));
                        
                        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
                            CloseBuyByTicket(ticket);
                        else 
                            CloseSellByTicket(ticket);
                        
                        simple_mode_has_trade = false;
                        continue;
                    }
                }
                else if(InpPlaygroundMode == MODE_SILVER_BULLET_ENC)
                {
                    // Silver Bullet mode: Check loss threshold only
                    if (profit <= -InpELoss) 
                    {
                        Print(">>> LOSS THRESHOLD HIT (SB MODE) <<<");
                        Print("Ticket: ", ticket, " | Loss: $", DoubleToString(profit, 2));
                        
                        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
                            CloseBuyByTicket(ticket);
                        else 
                            CloseSellByTicket(ticket);
                        continue;
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Print configuration                                              |
//+------------------------------------------------------------------+
void PrintConfiguration()
{
   Print("=== PLAYGROUND EA v1.02 CONFIGURATION ===");
   Print("Mode: ", EnumToString(InpPlaygroundMode));
   Print("Timeframe: ", EnumToString(InpTimeframe));
   Print("Min Gap Size: ", InpMinGapSize, " points");
   Print("Lot Size: ", InpLotSize);
   Print("");
   
   if(InpPlaygroundMode == MODE_SILVER_BULLET_ENC)
   {
      Print("=== SILVER BULLET ENC MODE ===");
      Print("GMT Offset: ", InpGMTOffset);
      Print("SB1 (3-4am): ", (InpTradeSB1 ? "ON" : "OFF"));
      Print("SB2 (10-11am): ", (InpTradeSB2 ? "ON" : "OFF"));
      Print("SB3 (2-3pm): ", (InpTradeSB3 ? "ON" : "OFF"));
      Print("Min DOL Distance: ", InpMinDOLDistance, " pips");
      Print("Target 1: ", InpTarget1Percent, "% to DOL");
      Print("Target 2: ", InpTarget2Percent, "% to DOL");
      Print("Loss Threshold: $", DoubleToString(InpELoss, 2));
      Print("Note: Profit targets based on liquidity zones");
   }
   else if(InpPlaygroundMode == MODE_SIMPLE_ENC)
   {
      Print("=== SIMPLE ENC MODE ===");
      Print("Profit Target: $", DoubleToString(InpEProfit, 2));
      Print("Loss Threshold: $", DoubleToString(InpELoss, 2));
      Print("Trading Rule: One trade at a time");
   }
   
   Print("");
   Print("=== ENCROACHMENT LOGIC ===");
   Print("Entry Rule: Close above ENC = BUY | Close below ENC = SELL");
   Print("Use Filters: ", (InpEncScalpUseFilters ? "YES" : "NO"));
   if(InpEncScalpUseFilters)
   {
      Print("Min Gap Points: ", InpEncScalpMinGapPoints);
      Print("Check Trend: ", (InpEncScalpCheckTrend ? "YES" : "NO"));
      if(InpEncScalpCheckTrend)
         Print("Trend MA Period: ", InpEncScalpTrendPeriod);
   }
   Print("=========================================");
}