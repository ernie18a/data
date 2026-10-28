//+------------------------------------------------------------------+
//|                                      NarrowestRangeSignal_EA.mq5 |
//|                                            Copyright 2013, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "The Expert Advisor based on the NarrowestRangeSignal indicator. If there is no position, "
#property description "stop orders will be set in both sides of the range by the signal of the indicator. "
#property description "When either of orders triggers, the opposite order is deleted."
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MM_MODE {
   FIXED_LOT,        // Fixed lot
   FIXED_PERCENT     // Fixed percent
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int            InpBarsInRange = 3;     // Bars in Range
input int            InpCheckPeriod = 10;    // Check Period
input int            InpIndent = 50;         // Order Indent from High/Low
input int            InpTakeProfit = 500;    // Take Profit (pips)
input ENUM_MM_MODE   InpMmMode = FIXED_LOT;  // MM Mode
input double         InpVolume = 1.0;        // Volume(Lot or percent)
//---
int bars_in_range;
int check_period;
int nrs_handle = INVALID_HANDLE;

double take_profit;
double indent;
double inp_volume;
bool is_buy_stop = false;
bool is_sell_stop = false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---
   bars_in_range = InpBarsInRange;
   check_period = InpCheckPeriod;
   
   take_profit = InpTakeProfit * _Point;
   indent = InpIndent * _Point;
   inp_volume = InpVolume;
   
   ResetLastError();
   nrs_handle = iCustom(_Symbol, _Period, "NarrowestRangeSignal", bars_in_range, check_period);
   if ( nrs_handle == INVALID_HANDLE ) {
      Print("Creating NarrowestRangeSignal indicator failed. Error #", GetLastError());
      return(-1);
   }
//---
   return(0);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---
   IndicatorRelease(nrs_handle);
//---
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetCurrentTime() {
//---
   datetime time[1];
   
   ResetLastError();
   if ( CopyTime(_Symbol, _Period, 0, 1, time) != 1 ) {
      Print(__FUNCTION__, ": getting time data failed. Error #", GetLastError());
      return((datetime)0);
   }
//---
   return(time[0]);
}
//+------------------------------------------------------------------+
//| Check volume value function                                      |
//+------------------------------------------------------------------+
double CheckLotValue(double volume) {
//---
   double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volume_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
//---
   if ( volume < min_volume ) {
      volume = min_volume;
   } else if ( volume > max_volume ) {
      volume = max_volume;
   }
//---
   int digits = (int)MathCeil(MathLog10(1/volume_step));
//---
   return(NormalizeDouble(volume, digits));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateLot() {
//---
   double result;
   
   if ( InpMmMode == FIXED_LOT ) {
      result = inp_volume;
   } else {
      double free_margin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
      long leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
      
      result = NormalizeDouble((free_margin/1000/leverage)*inp_volume, 1); 
   }
//---
   return(CheckLotValue(result));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenPendingOrder(ENUM_ORDER_TYPE type, double price, double sl) {
//---
   MqlTick last_tick;
   
   ResetLastError();
   if ( !SymbolInfoTick(_Symbol, last_tick) ) {
      Print(__FUNCTION__, ": getting tick data failed. Error #", GetLastError());
      return(false);
   }
//---
   double tp;
   if ( type == ORDER_TYPE_BUY_STOP ) {
      price += (last_tick.ask - last_tick.bid);
      tp = price + take_profit;
   } else {
      tp = price - take_profit;
   }
   
   CTrade trade;
   
   if ( !trade.OrderOpen(_Symbol, type, CalculateLot(), price, price, sl, tp) ) {
      Print(__FUNCTION__, ": opening order failed. Error #", GetLastError());
      return(false);
   }
//---
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNarrowestRangeSignal(double &max_price, double &min_price) {
//---
   double nrs_values[], high[], low[];
   int to_copy = bars_in_range + 1;
   
   ResetLastError();
   if ( CopyBuffer(nrs_handle, 2, 1, 1, nrs_values) == 1
      && CopyHigh(_Symbol, _Period, 0, to_copy, high) == to_copy
      && CopyLow(_Symbol, _Period, 0, to_copy, low) == to_copy)
   {
      if ( nrs_values[0] != 0.0 && nrs_values[0] != EMPTY_VALUE ) {
         if ( ArrayMaximum(high) != bars_in_range && ArrayMinimum(low) != bars_in_range ) {
            max_price = high[ArrayMaximum(high)];
            min_price = low[ArrayMinimum(low)];
            return(true);
         }
      }
   } else {
      Print(__FUNCTION__, ": getting NarrowestRangeSignal or/and high or/and low data failed. Error #", 
         GetLastError());
   }
//---
   return(false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckOrders() {
//---
   datetime cur_time = GetCurrentTime();
   static datetime prev_time;
   
   if ( cur_time == prev_time ) {
      return;
   }
//---
   double max_high, min_low;
   
   if ( IsNarrowestRangeSignal(max_high, min_low) ) {
      DeletePendingOrders();
      if ( !is_buy_stop ) {
         if ( !OpenPendingOrder(ORDER_TYPE_BUY_STOP, max_high+indent, min_low-indent) ) {
            return;
         }
         is_buy_stop = true;
      }
      if ( !is_sell_stop ) {
         if ( !OpenPendingOrder(ORDER_TYPE_SELL_STOP, min_low-indent, max_high+indent) ) {
            return;
         }
         is_sell_stop = true;
      }
   }
//---
   prev_time = cur_time;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeletePendingOrders() {
//---
   datetime cur_time = GetCurrentTime();
   static datetime prev_time;   
   
   if ( prev_time == cur_time ) {
      return;
   }
   
   for ( int ord = OrdersTotal() - 1; ord >= 0; ord-- ) {
      ulong ticket;
      
      if ( (ticket = OrderGetTicket(ord)) > 0 ) {
         if ( OrderGetString(ORDER_SYMBOL) == _Symbol ) {
            CTrade trade;
            
            if ( !trade.OrderDelete(ticket) ) {
               Print(__FUNCTION__, ": deleting order failed. Error #", GetLastError());
               return;
            }
         }
      }   
   }
//---
   is_buy_stop = false;
   is_sell_stop = false;
   prev_time = cur_time;
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
   if ( PositionSelect(_Symbol) ) {
      DeletePendingOrders();
   } else {
      CheckOrders();
   }
//---   
}
//+------------------------------------------------------------------+
