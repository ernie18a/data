//+------------------------------------------------------------------+
//|                                                    Trap News.mq4 |
//|                                                      reza rahmad |
//|                                             rezarahmad@gmail.com |
//+------------------------------------------------------------------+
#property copyright "reza rahmad"
#property link      "rezarahmad@gmail.com"
#property version   "2.00"
#property strict
#property show_inputs

//--- Inputs
input double DistancePips   = 10.0; // Distance for Stop Orders (Pips)
input double StopLossPips   = 7.0;  // Stop Loss (Pips)
input double TakeProfitPips = 20.0; // Take Profit (Pips)
input double LotSize        = 0.01; // Size of the orders
input int    Slippage       = 3;    // Slippage (Points)
input int    MagicNumber    = 1234; // Magic Number

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Check if AutoTrading is allowed
   if(!IsTradeAllowed())
     {
      MessageBox("? FAILED: The 'AutoTrading' button at the top of MT4 is not enabled (still red)!", "Error", MB_ICONERROR);
      return;
     }

//--- Prompt single confirmation for speed (Very important for News Trading!)
   string conf_msg = StringFormat("Place TRAP NEWS (Buy Stop & Sell Stop)?\nDistance: %.1f Pips\nSL: %.1f Pips | TP: %.1f Pips\nLot: %.2f", DistancePips, StopLossPips, TakeProfitPips, LotSize);
   if(MessageBox(conf_msg, "Trap News Confirmation", MB_YESNO | MB_ICONQUESTION) != IDYES)
     {
      Print("Trap News placement cancelled.");
      return;
     }

   double point = Point;
   int digits = Digits;
   
//--- Automatically determine Pip size for Forex and Gold
   double pip_multiplier = (digits == 3 || digits == 5) ? 10.0 : 1.0;
   double pip_value = point * pip_multiplier;

   RefreshRates();
   double ask = Ask;
   double bid = Bid;

//--- Calculate prices for Buy Stop
   double buy_price = ask + (DistancePips * pip_value);
   double buy_sl    = buy_price - (StopLossPips * pip_value);
   double buy_tp    = buy_price + (TakeProfitPips * pip_value);

//--- Calculate prices for Sell Stop
   double sell_price = bid - (DistancePips * pip_value);
   double sell_sl    = sell_price + (StopLossPips * pip_value);
   double sell_tp    = sell_price - (TakeProfitPips * pip_value);

//--- Normalize prices
   buy_price = NormalizeDouble(buy_price, digits);
   buy_sl    = NormalizeDouble(buy_sl, digits);
   buy_tp    = NormalizeDouble(buy_tp, digits);
   
   sell_price = NormalizeDouble(sell_price, digits);
   sell_sl    = NormalizeDouble(sell_sl, digits);
   sell_tp    = NormalizeDouble(sell_tp, digits);

   int err = 0;
//--- Send Buy Stop
   int b_ticket = OrderSend(Symbol(), OP_BUYSTOP, LotSize, buy_price, Slippage, buy_sl, buy_tp, "Trap News Buy", MagicNumber, 0, clrBlue);
   if(b_ticket < 0)
     {
      err = GetLastError();
      MessageBox("? FAILED to place Buy Stop! Error code: " + IntegerToString(err), "Error", MB_ICONERROR);
     }
   else
     {
      Print("? Buy Stop SUCCESS! Ticket: ", b_ticket);
     }

//--- Send Sell Stop
   int s_ticket = OrderSend(Symbol(), OP_SELLSTOP, LotSize, sell_price, Slippage, sell_sl, sell_tp, "Trap News Sell", MagicNumber, 0, clrRed);
   if(s_ticket < 0)
     {
      err = GetLastError();
      MessageBox("? FAILED to place Sell Stop! Error code: " + IntegerToString(err), "Error", MB_ICONERROR);
     }
   else
     {
      Print("? Sell Stop SUCCESS! Ticket: ", s_ticket);
     }
  }
//+------------------------------------------------------------------+
