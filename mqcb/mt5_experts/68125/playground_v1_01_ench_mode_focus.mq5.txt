//+------------------------------------------------------------------+
//|                                                PLAYGROUND_EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.01"
#property description "Experimental Encroachment Scalping - Simple & Clean"
/*
This is v1.01 with the liqudity function removed, fixed the issue we had with v1.00
And focused fully On the Enc and it works really well
*/

#include <FVGLibrary.mqh>

//--- Input parameters
input group "=== FVG Settings ==="
input double InpMinGapSize = 50.0;               // Minimum gap size in points
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_M5;  // FVG detection timeframe
input ENUM_TIMEFRAMES InpAccuracyTF = PERIOD_M1; // Accuracy timeframe
input bool InpAccuracy = false;                  // Use 1M entry precision
input bool InpDrawObjects = true;                // Draw visual objects

input group "=== Trading Settings ==="
input double InpLotSize = 0.01;                  // Lot size
input double InpEProfit = 10.0;                  // Profit target in account currency ($)
input double InpELoss = 10.0;                    // Loss threshold in account currency ($)

input group "=== Encroachment Scalping Settings ==="
input bool InpEncScalpUseFilters = false;        // Use additional filters
input int InpEncScalpMinGapPoints = 30;          // Minimum gap size for scalp entry
input bool InpEncScalpCheckTrend = false;        // Check trend alignment
input int InpEncScalpTrendPeriod = 20;           // Trend MA period

//--- Global variables
CFVGLibrary* fvg_lib;
int trend_ma_handle = INVALID_HANDLE;

//--- EA Magic number
const int EA_MAGIC = 9999;

//--- Trade tracking
struct PlaygroundTrade
{
   ulong ticket;
   int fvg_id;
   double entry_price;
   datetime entry_time;
};
PlaygroundTrade active_trades[];
int trade_count = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== PLAYGROUND EA - Encroachment Scalping ===");
   
   // Initialize FVG Library
   fvg_lib = new CFVGLibrary(_Symbol, InpTimeframe, InpAccuracyTF, 
                            InpMinGapSize, InpAccuracy, InpDrawObjects);
   
   if(!fvg_lib.Init())
   {
      Print("Failed to initialize FVG Library!");
      return(INIT_FAILED);
   }
   fvg_lib.SetCallback(OnFVGEvent);
   
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
   
   if(trend_ma_handle != INVALID_HANDLE)
      IndicatorRelease(trend_ma_handle);
   
   Print("=== PLAYGROUND EA Deinitialized ===");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Update library
   if(fvg_lib != NULL) 
      fvg_lib.OnTick();
   
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
      
      // Encroachment Scalping
      HandleEncroachmentScalp(fvg);
   }
   else if(event_type == "FVG_RESET")
   {
      Print("=== FVG RESET ===");
      Print("ID: ", fvg.fvg_id, " invalidated by inverse candle");
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
   
   // Open trade
   ulong ticket = 0;
   if(trade_direction == "BUY")
      ticket = OpenBuy(InpLotSize);
   else if(trade_direction == "SELL")
      ticket = OpenSell(InpLotSize);
   
   if(ticket > 0)
   {
      // Store trade info
      StoreTrade(ticket, fvg.fvg_id, current_close);
      
      Print("=== ENCROACHMENT SCALP OPENED ===");
      Print("Ticket: ", ticket);
      Print("Lot Size: ", InpLotSize);
      Print("Entry Price: ", DoubleToString(current_close, _Digits));
      Print("================================");
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
//| Store trade information                                          |
//+------------------------------------------------------------------+
void StoreTrade(ulong ticket, int fvg_id, double entry_price)
{
   if(trade_count >= ArraySize(active_trades))
      ArrayResize(active_trades, ArraySize(active_trades) + 20);
   
   active_trades[trade_count].ticket = ticket;
   active_trades[trade_count].fvg_id = fvg_id;
   active_trades[trade_count].entry_price = entry_price;
   active_trades[trade_count].entry_time = TimeCurrent();
   
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
                    Print(">>> PROFIT TARGET REACHED <<<");
                    Print("Ticket: ", ticket);
                    Print("Profit: $", DoubleToString(profit, 2));
                    Print("Target was: $", DoubleToString(InpEProfit, 2));
                    
                    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) 
                        CloseBuyByTicket(ticket);
                    else 
                        CloseSellByTicket(ticket);
                    continue;
                }
                
                // Close on loss threshold
                if (profit <= -InpELoss) 
                {
                    Print(">>> LOSS THRESHOLD HIT <<<");
                    Print("Ticket: ", ticket);
                    Print("Loss: $", DoubleToString(profit, 2));
                    Print("Threshold was: $", DoubleToString(-InpELoss, 2));
                    
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

//+------------------------------------------------------------------+
//| Print configuration                                              |
//+------------------------------------------------------------------+
void PrintConfiguration()
{
   Print("=== PLAYGROUND EA CONFIGURATION ===");
   Print("Mode: ENCROACHMENT SCALPING");
   Print("Timeframe: ", EnumToString(InpTimeframe));
   Print("Min Gap Size: ", InpMinGapSize, " points");
   Print("Lot Size: ", InpLotSize);
   Print("Profit Target: $", DoubleToString(InpEProfit, 2));
   Print("Loss Threshold: $", DoubleToString(InpELoss, 2));
   Print("");
   Print("=== SCALPING SETTINGS ===");
   Print("Use Filters: ", (InpEncScalpUseFilters ? "YES" : "NO"));
   if(InpEncScalpUseFilters)
   {
      Print("Min Gap Points: ", InpEncScalpMinGapPoints);
      Print("Check Trend: ", (InpEncScalpCheckTrend ? "YES" : "NO"));
      if(InpEncScalpCheckTrend)
         Print("Trend MA Period: ", InpEncScalpTrendPeriod);
   }
   Print("===================================");
}