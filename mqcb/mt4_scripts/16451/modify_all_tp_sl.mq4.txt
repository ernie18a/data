//+------------------------------------------------------------------+
//|                                             Modify_All_TP_SL.mq4 |
//|                                                  © Tecciztecatl  |
//+------------------------------------------------------------------+
#property copyright     "© Tecciztecatl 2016-2018"
#property link          "https://www.mql5.com/en/users/tecciztecatl"
#property version       "2.00"
#property description   "The script modifies all orders (market and pending) on the symbol Take Profit and Stop Loss."
#property script_show_inputs
#property strict

input double TakeProfit=0; //Take Profit (price)
input double StopLoss=0;   //Stop Loss (price)
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(OrdersTotal()>0)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            double tp=NormalizeDouble(TakeProfit,_Digits);
            double sl=NormalizeDouble(StopLoss,_Digits);

            if(OrderSymbol()==Symbol())
              {
               int ticket=OrderTicket();
               if(tp<=0) tp=OrderTakeProfit();
               if(sl<=0) sl=OrderStopLoss();
               if(OrderType()==OP_SELL || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
                 {
                  if(OrderType()==OP_SELL)
                    {
                     if(tp>Ask) tp=OrderTakeProfit();
                     if(sl<Ask) sl=OrderStopLoss();
                    }
                  else
                    {
                     if(tp>=OrderOpenPrice()) tp=OrderTakeProfit();
                     if(sl<=OrderOpenPrice()) sl=OrderStopLoss();
                    }
                 }
               if(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)
                 {
                  if(OrderType()==OP_BUY)
                    {
                     if(tp<Bid) tp=OrderTakeProfit();
                     if(sl>Bid) sl=OrderStopLoss();
                    }
                  else
                    {
                     if(tp<=OrderOpenPrice()) tp=OrderTakeProfit();
                     if(sl>=OrderOpenPrice()) sl=OrderStopLoss();
                    }
                 }
               Ord_Modify(ticket,tp,sl);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Ord_Modify(int ticket,double tp,double sl)
  {
   ResetLastError();
   if(OrderCloseTime()==0 && (tp!=OrderTakeProfit() || sl!=OrderStopLoss()))
     {
      bool i2=false;
      while(!i2 && !IsStopped())
        {
         i2=OrderModify(ticket,OrderOpenPrice(),sl,tp,0,clrNONE);
         if(i2==false)
           {
            Print("Error modifying orders, #"+IntegerToString(GetLastError()));
            RefreshRates();
            Sleep(500);
           }
        }
     }
  }
//+------------------------------------------------------------------+
