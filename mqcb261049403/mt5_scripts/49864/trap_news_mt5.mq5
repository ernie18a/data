//+------------------------------------------------------------------+
//|                                                Trap News MT5.mq5 |
//|                                                  rezarahmad 2024 |
//|                                             rezarahmad@gmail.com |
//+------------------------------------------------------------------+
#property copyright "rezarahmad 2024"
#property link      "rezarahmad@gmail.com"
#property version   "1.00"
#property script_show_inputs

//--- Input parameters (in Pips)
input double DistancePips     = 50.0; // Distance for Stop Orders (Pips)
input double StopLossPips     = 25.0; // Stop Loss (Pips)
input double TakeProfitPips   = 100.0;// Take Profit (Pips)
input double LotSize          = 0.01; // Size of the orders
input ulong  MagicNumber      = 1234; // Magic Number

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Check if Algo Trading is globally enabled in MT5
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("❌ GAGAL: Tombol 'Algo Trading' di atas MT5 belum diaktifkan (masih merah)!");
      return;
     }
     
   string symbol = Symbol();
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   
//--- Automatically determine Pip size for Forex and Gold
   double pip_multiplier = (digits == 3 || digits == 5) ? 10.0 : 1.0;
   double pip_value = point * pip_multiplier;

//--- Refresh prices to get the absolute latest tick
   MqlTick last_tick;
   SymbolInfoTick(symbol, last_tick);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

//--- Calculate prices for Buy Stop
   double buy_price = ask + (DistancePips * pip_value);
   double buy_sl    = buy_price - (StopLossPips * pip_value);
   double buy_tp    = buy_price + (TakeProfitPips * pip_value);

//--- Calculate prices for Sell Stop
   double sell_price = bid - (DistancePips * pip_value);
   double sell_sl    = sell_price + (StopLossPips * pip_value);
   double sell_tp    = sell_price - (TakeProfitPips * pip_value);

//--- Normalize prices to broker's digit requirement
   buy_price = NormalizeDouble(buy_price, digits);
   buy_sl    = NormalizeDouble(buy_sl, digits);
   buy_tp    = NormalizeDouble(buy_tp, digits);
   
   sell_price = NormalizeDouble(sell_price, digits);
   sell_sl    = NormalizeDouble(sell_sl, digits);
   sell_tp    = NormalizeDouble(sell_tp, digits);

//--- Determine valid filling mode for the broker
   int filling = (int)SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
   ENUM_ORDER_TYPE_FILLING fill_mode = ORDER_FILLING_RETURN;
   if((filling & SYMBOL_FILLING_FOK) != 0) fill_mode = ORDER_FILLING_FOK;
   else if((filling & SYMBOL_FILLING_IOC) != 0) fill_mode = ORDER_FILLING_IOC;

//--- Send Buy Stop
   MqlTradeRequest buy_request;
   MqlTradeResult buy_result;
   ZeroMemory(buy_request);
   ZeroMemory(buy_result);

   buy_request.action       = TRADE_ACTION_PENDING;
   buy_request.symbol       = symbol;
   buy_request.volume       = LotSize;
   buy_request.type         = ORDER_TYPE_BUY_STOP;
   buy_request.price        = buy_price;
   buy_request.sl           = buy_sl;
   buy_request.tp           = buy_tp;
   buy_request.type_time    = ORDER_TIME_GTC;
   buy_request.type_filling = fill_mode;
   buy_request.magic        = MagicNumber;
   buy_request.comment      = "Trap News Buy";

   string msg = "";
   if(!OrderSend(buy_request, buy_result))
     {
      msg = "❌ GAGAL pasang Buy Stop! Error: " + IntegerToString(buy_result.retcode);
      Print(msg); Alert(msg);
     }
   else
     {
      msg = "✅ Buy Stop BERHASIL! Ticket: " + IntegerToString(buy_result.order);
      Print(msg);
     }

//--- Send Sell Stop
   MqlTradeRequest sell_request;
   MqlTradeResult sell_result;
   ZeroMemory(sell_request);
   ZeroMemory(sell_result);

   sell_request.action       = TRADE_ACTION_PENDING;
   sell_request.symbol       = symbol;
   sell_request.volume       = LotSize;
   sell_request.type         = ORDER_TYPE_SELL_STOP;
   sell_request.price        = sell_price;
   sell_request.sl           = sell_sl;
   sell_request.tp           = sell_tp;
   sell_request.type_time    = ORDER_TIME_GTC;
   sell_request.type_filling = fill_mode;
   sell_request.magic        = MagicNumber;
   sell_request.comment      = "Trap News Sell";

   if(!OrderSend(sell_request, sell_result))
     {
      msg = "❌ GAGAL pasang Sell Stop! Error: " + IntegerToString(sell_result.retcode);
      Print(msg); Alert(msg);
     }
   else
     {
      msg = "✅ Sell Stop BERHASIL! Ticket: " + IntegerToString(sell_result.order);
      Print(msg);
     }
  }
//+------------------------------------------------------------------+
