//+------------------------------------------------------------------+
//|                                      Auto TP multipled by SL.mq4 |
//|                                          Copyright 2023, Sathyam |
//|                             https://www.mql5.com/en/users/hacsat |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Sathyam"
#property link      "https://www.mql5.com/en/users/hacsat"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//Works for Single symbol

//
extern string  SL_MUL = "<<< Multiplier value to set TP based on SL>>>";
extern double SL_Multiplier=4;//Profit Percentage

//

// Declare a function to set the profit target for open positions
void setProfitTarget()
  {

// Loop through all open positions
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {





         if(OrderType() == OP_BUY)
           {

            double takeProfitDistance=(OrderOpenPrice()-OrderStopLoss())*SL_Multiplier;

            // Set take profit to required distance
            bool result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), OrderOpenPrice()+takeProfitDistance, 0, Green);
            if(result)
              {
               Print("Profit target set for buy order ", OrderTicket());
              }
            else
              {
               //  Print("Failed to set profit target for buy order ", OrderTicket());
              }


           }
         //If sell
         if(OrderType() == OP_SELL)
           {


            double takeProfitDistance1=(OrderStopLoss()-OrderOpenPrice())*SL_Multiplier;

            // Set take profit to required distance
            bool result1 = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), OrderOpenPrice()-takeProfitDistance1, 0, Green);


            if(result1)
              {
               Print("Profit target set for sell order ", OrderTicket());
              }
            else
              {
               // Print("Failed to set profit target for sell order ", OrderTicket());
              }
           }
        }
     }
  }

// Declare an event handler for the OnTick event
void OnTick()
  {

   setProfitTarget();
  }

//+------------------------------------------------------------------+
