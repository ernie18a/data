//+------------------------------------------------------------------+
//|This script resets the stop-loss orders and TakeProfit            |
//|                              Copyright © 2012, Khlystov Vladimir |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Khlystov Vladimir"
#property link      "cmillion@narod.ru"
//--------------------------------------------------------------------
int start()
{  
   int Ticket;
   double OSL,OTP,OOP;
   RefreshRates();
   for (int i=0; i<OrdersTotal(); i++) 
   {  
      if (OrderSelect(i, SELECT_BY_POS))
      {  
         if (OrderSymbol()==Symbol())
         {
            OSL = NormalizeDouble(OrderStopLoss(),Digits);
            OTP = NormalizeDouble(OrderTakeProfit(),Digits);
            OOP = NormalizeDouble(OrderOpenPrice(),Digits);
            Ticket = OrderTicket();
            if (OSL!=0 || OTP!=0)             
            {
               if (!OrderModify(Ticket,OOP,0,0,0,White))
                  Alert(Symbol()," error Modify ",GetLastError()," Ticket ",Ticket);
            }
         }
      }
   }
   return;
}
//--------------------------------------------------------------------