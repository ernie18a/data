//+------------------------------------------------------------------+
//| OHLCMTF Scalper EA - v8.0 (MQL5 Margin & Stress Test Fix)        |
//| Version: 8.0                                                     |
//| Developer: Amanda V                                              |
//| Description: Professional Fix for [No money] and Stress Tests    |
//+------------------------------------------------------------------+
#property copyright "Amanda V - Price Action Dev"
#property version   "8.0"
#property strict

#include <Trade\Trade.mqh>

enum ENUM_SL_MODE { SL_FIXED_POINTS, SL_PERCENT_PRICE }; 

input group "--- BAR SETTINGS ---"
input int  Look_Back_Bar     = 300; 
input int  Look_Forward_Bar  = 10;  

input group "--- BUY CONDITIONS ---"
input bool Buy_Cond_1 = false; 
input bool Buy_Cond_2 = true;  

input group "--- SELL CONDITIONS ---"
input bool Sell_Cond_1 = false; 
input bool Sell_Cond_2 = true;  

input group "--- OPTIONS ---"
input bool Use_Custom_Pair    = true;           
input ENUM_TIMEFRAMES TF_Fast = PERIOD_M5;      
input ENUM_TIMEFRAMES TF_Slow = PERIOD_H1;      
input bool Use_Limit_Orders   = true;  
input bool Use_Break_Even     = true; 
input int  Auto_Expiration    = 60;   

input group "--- RISK MANAGEMENT ---"
input ENUM_SL_MODE Calculation_Mode = SL_PERCENT_PRICE;
input double Stop_Loss       = 1.0;   
input double Take_Profit     = 2.0;   
input double Fixed_Lot       = 0.1;  

CTrade trade;
string symb;
double point_val;
int g_Digits;
datetime last_bar_time = 0;

int OnInit() {
   symb = _Symbol;
   point_val = SymbolInfoDouble(symb, SYMBOL_POINT);
   g_Digits = (int)SymbolInfoInteger(symb, SYMBOL_DIGITS);
   trade.SetExpertMagicNumber(123456);
   return(INIT_SUCCEEDED);
}

void OnTick() {
   if(Use_Break_Even) ManageBreakEven();
   datetime time_0 = iTime(symb, PERIOD_CURRENT, 0);
   if (time_0 == last_bar_time) return;
   last_bar_time = time_0;

   CheckTradingLogic(PERIOD_H1, PERIOD_H4, PERIOD_D1);
   if(Use_Custom_Pair) CheckTradingLogic(TF_Fast, TF_Slow, TF_Slow); 
}

void CheckTradingLogic(ENUM_TIMEFRAMES t1, ENUM_TIMEFRAMES t2, ENUM_TIMEFRAMES t3) {
   double h1_1 = iHigh(symb, t1, 1); double h1_2 = iHigh(symb, t1, 2);
   double l1_1 = iLow(symb, t1, 1);  double l1_2 = iLow(symb, t1, 2);
   double h2_1 = iHigh(symb, t2, 1); 

   bool buy_signal = (h1_1 > h1_2) && (h1_1 > h2_1);
   bool sell_signal = (l1_1 < l1_2) && (l1_1 < iLow(symb, t2, 1));

   datetime time = iTime(symb, t1, 1);
   if(buy_signal) ProcessSignal(1, time, l1_1);
   if(sell_signal) ProcessSignal(2, time, h1_1);
}

void ProcessSignal(int type, datetime t, double price) {
   string baseName = "DOT_" + (type==1?"B":"S") + "_" + TimeToString(t);
   if(ObjectFind(0, baseName) < 0) {
      ExecuteTrade(type, price);
      ObjectCreate(0, baseName, OBJ_ARROW, 0, t, price);
      ObjectSetInteger(0, baseName, OBJPROP_ARROWCODE, 159);
   }
}

void ExecuteTrade(int type, double signal_price) {
   double ask = SymbolInfoDouble(symb, SYMBOL_ASK);
   double bid = SymbolInfoDouble(symb, SYMBOL_BID);
   double price = signal_price;
   
   // --- DYNAMIC LOT CALCULATION (FIX FOR [NO MONEY]) ---
   double minVol = SymbolInfoDouble(symb, SYMBOL_VOLUME_MIN);
   double stepVol = SymbolInfoDouble(symb, SYMBOL_VOLUME_STEP);
   double vol = Fixed_Lot;

   // Check how many lots we can actually afford with current margin
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double marginForOneLot = 0;
   if(OrderCalcMargin(type==1?ORDER_TYPE_BUY:ORDER_TYPE_SELL, symb, 1.0, (type==1?ask:bid), marginForOneLot) && marginForOneLot > 0) {
      double maxAllowedVol = (freeMargin * 0.9) / marginForOneLot; // Use only 90% of free margin
      if(vol > maxAllowedVol) vol = maxAllowedVol;
   }

   // Final Volume Normalization
   if(stepVol > 0) vol = MathFloor(vol / stepVol) * stepVol;
   if(vol < minVol) return; // Skip trade if we can't even afford the minimum lot

   double sl_dist = (Calculation_Mode == SL_FIXED_POINTS) ? Stop_Loss * point_val : price * (Stop_Loss / 100.0);
   double tp_dist = (Calculation_Mode == SL_FIXED_POINTS) ? Take_Profit * point_val : price * (Take_Profit / 100.0);
   double sl = (type == 1) ? price - sl_dist : price + sl_dist;
   double tp = (type == 1) ? price + tp_dist : price - tp_dist;

   double stopLevel = SymbolInfoInteger(symb, SYMBOL_TRADE_STOPS_LEVEL) * point_val;
   if(stopLevel <= 0) stopLevel = 10 * point_val;

   if(Use_Limit_Orders) {
      if(type == 1) {
         if(price < ask - stopLevel) trade.OrderOpen(symb, ORDER_TYPE_BUY_LIMIT, vol, price, price, sl, tp, ORDER_TIME_SPECIFIED, TimeCurrent()+(Auto_Expiration*60));
         else trade.PositionOpen(symb, ORDER_TYPE_BUY, vol, ask, sl, tp);
      } else {
         if(price > bid + stopLevel) trade.OrderOpen(symb, ORDER_TYPE_SELL_LIMIT, vol, price, price, sl, tp, ORDER_TIME_SPECIFIED, TimeCurrent()+(Auto_Expiration*60));
         else trade.PositionOpen(symb, ORDER_TYPE_SELL, vol, bid, sl, tp);
      }
   } else {
      if(type == 1) trade.PositionOpen(symb, ORDER_TYPE_BUY, vol, ask, sl, tp);
      else trade.PositionOpen(symb, ORDER_TYPE_SELL, vol, bid, sl, tp);
   }
}

void ManageBreakEven() {
   for(int i=PositionsTotal()-1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == symb) {
         double open = PositionGetDouble(POSITION_PRICE_OPEN);
         double sl = PositionGetDouble(POSITION_SL);
         double current = PositionGetDouble(POSITION_PRICE_CURRENT);
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && current > open + 100*point_val && MathAbs(sl-open) > 5*point_val) 
            trade.PositionModify(ticket, open, PositionGetDouble(POSITION_TP));
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && current < open - 100*point_val && (sl == 0 || MathAbs(sl-open) > 5*point_val)) 
            trade.PositionModify(ticket, open, PositionGetDouble(POSITION_TP));
      }
   }
}