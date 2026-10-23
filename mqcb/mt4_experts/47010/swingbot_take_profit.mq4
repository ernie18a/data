

//+------------------------------------------------------------------+
//|                                                      SwingBOT EA |
//|                                 Copyright 2023, Luca Cerquatelli |
//|       https://www.mql5.com/en/users/lucacerquatelli-gmail/seller |
//+------------------------------------------------------------------+

#property copyright "Copyright 2023, Luca Cerquatelli"
#property link      "https://www.youtube.com/@SwingBotEA"
#property strict


void OnTick()
  {


   double ProfittoMinimo = 3; // Profitto Minimo: attiva trailing stop a questo livello
   double profit = 0;
   double StopLoss = 0;
   int MagicNumber = 20230910;


   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderMagicNumber() == MagicNumber) // Nel caso di più EA. si può togliere il filtro del MagicNumber per mantenere la funzione sul totale ordini
           {
            profit += OrderProfit();
           }
        }
     }

   for(int e = OrdersTotal() - 1; e >= 0; e--)
     {
      if(OrderSelect(e, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber) // l’ordine viene modificato solo se il MagicNumber corrisponde a quello dell’ordine in corso.
           {
            if(profit >= ProfittoMinimo)
              {
               OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3); // Bid price
               Print("Chiuso ordine BUY per raggiungimento Profitto minimo ", profit, " - Stoploss minimo: ",MarketInfo(Symbol(), MODE_STOPLEVEL));
              }
           }

         if(OrderSymbol() == Symbol() && OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber)
           {
            if(profit >= ProfittoMinimo)
              {
               OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3); // Ask price
               Print("Chiuso ordine SELL per raggiungimento Profitto minimo ", profit, " - Stoploss minimo: ",MarketInfo(Symbol(), MODE_STOPLEVEL));
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
