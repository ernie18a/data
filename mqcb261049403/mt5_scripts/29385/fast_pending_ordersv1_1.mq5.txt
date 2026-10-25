//+------------------------------------------------------------------+
//|                                      Fast Pending Orders.mq5     |
//|                                 Copyright © 2020, behzad.mvr     |
//|                                         Behzad.mvr@gmail.com     |
//+------------------------------------------------------------------+

#property script_show_inputs

// Set riskPercent=0 if you want to use riskAmount
enum definePendingType
  {
   BuyStop=1,//Buy Stop
   BuyLimit=2,//Buy Limit
   SellStop=-1,//Sell Stop
   SellLimit=-2,//Sell Limit
   None=0,// Not Defined!
  };
  
input string firstRun="----- Set in First script run -----"; // -----------------------------------
input definePendingType pendingType=0; //Type of Pending Order
input string secondRun="----- Set in Second script run -----"; // -----------------------------------
input double riskPercent=2; //Risk Percent (%)
input double riskAmount=0; //Risk Amount ($)
input int TotalOrders=1; //Number of Pending Orders
input double minLot=0.01;  //Minimum Lot Allowed by Broker to open Orders
int Slipage=0;   //Max order slipage(deviation) (points)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ulong  magic=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnStart()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings.");
      return(0);
     }
   if(riskPercent!=0 && riskAmount!=0)
     {
      Alert("Set one of the risk parameters=0 to other parameter works.");
      return(0);
     }
   if(riskPercent==0 && riskAmount==0)
     {
      Alert("Don't set both of risk parameters = 0");
      return(0);
     }
   int totalOrders=TotalOrders;
   double orderPrice=0,sl=0;
   double lots=0;
   double price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double TP=0,SL=0;
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double maxLoss=0;
   if(riskPercent!=0)
      maxLoss=(riskPercent/100)*equity;
   else
      if(riskAmount!=0)
         maxLoss=riskAmount;

   ENUM_ORDER_TYPE orderType=-1;

   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=OrdersTotal();

   double volume=0;
   ulong  order_ticket=0;
   int minLotCnt=0;
   for(int i=0; i<total; i++)
     {
      //--- parameters of the order
      order_ticket=OrderGetTicket(i);// ticket of the order
      string order_symbol=OrderGetString(ORDER_SYMBOL); // symbol
      volume=OrderGetDouble(ORDER_VOLUME_CURRENT);    // volume of the order
      if(order_symbol!=_Symbol || volume!=minLot)
         continue;
      minLotCnt++;
      int    digits=(int)SymbolInfoInteger(order_symbol,SYMBOL_DIGITS); // number of decimal places
      magic=OrderGetInteger(ORDER_MAGIC); // MagicNumber of the order
      orderPrice=OrderGetDouble(ORDER_PRICE_OPEN);
      sl=OrderGetDouble(ORDER_SL);  // Stop Loss of the order
      if(sl==0)
        {
         Alert("Please Set the StopLoss!");
         return(0);
        }
      orderType=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);  // type of the order
     }
   if(minLotCnt==0 && pendingType==0)
     {
     // Alert("First set a "+DoubleToString(minLot,2)+" pending order for "+_Symbol);
      Alert("Please set Type of Pending Order parameter in inputs window.");
      return(0);
     }
   if(minLotCnt>1)
     {
      Alert("There must be only one "+DoubleToString(minLot,2)+" lot pending order for "+_Symbol);
      return(0);
     }
   if(minLotCnt==1)
     {
      double usedLoss=0;
      if(orderType==ORDER_TYPE_BUY_STOP || orderType==ORDER_TYPE_BUY_LIMIT)
        {
         double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
         usedLoss=minLot*(ask-sl)*tick/_Point;
         for(int k=1; k<=totalOrders; k++)
           {
            if(maxLoss<k*usedLoss)
              {
               totalOrders=k-1;
               Alert("There is only enough risked eguity to split pending order into "+IntegerToString(k-1)+" order.");
               break;
              }
           }
         if(totalOrders==0)
            return(0);
         TP=orderPrice+(orderPrice-sl);
         lots=NormalizeDouble((maxLoss/((orderPrice-sl)*tick/_Point)/totalOrders),2);
         for(int i=0; i<totalOrders; i++)
           {
            sendOrder(orderType,orderPrice,sl,TP,lots,"");
            TP=TP+50*_Point;
           }
        }
      //----
      if(orderType==ORDER_TYPE_SELL_STOP || orderType==ORDER_TYPE_SELL_LIMIT)
        {
         double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
         usedLoss=minLot*(bid-sl)*tick/_Point;
         for(int k=1; k<=totalOrders; k++)
           {
            if(maxLoss<k*usedLoss)
              {
               totalOrders=k-1;
               Alert("There is only enough risked eguity to split pending order into "+IntegerToString(k-1)+" order.");
               break;
              }
           }
         if(totalOrders==0)
            return(0);
         TP=orderPrice-(sl-orderPrice);
         lots=NormalizeDouble((maxLoss/((sl-orderPrice)*tick/_Point)/totalOrders),2);
         for(int i=0; i<totalOrders; i++)
           {
            sendOrder(orderType,orderPrice,sl,TP,lots,"");
            TP=TP-50*_Point;
           }
        }
      deletePendingOrder(order_ticket);
     }
   else
      if(minLotCnt==0)
        {
         if(pendingType==1)
           {
            orderPrice=price+200*_Point;
            SL=orderPrice-100*_Point;
            TP=orderPrice+100*_Point;
            lots=minLot;
            sendOrder(ORDER_TYPE_BUY_STOP,orderPrice,SL,TP,lots,"");
           }
         if(pendingType==2)
           {
            orderPrice=price-200*_Point;
            SL=orderPrice-100*_Point;
            TP=orderPrice+100*_Point;
            lots=minLot;
            sendOrder(ORDER_TYPE_BUY_LIMIT,orderPrice,SL,TP,lots,"");
           }
         if(pendingType==-1)
           {
            orderPrice=price-200*_Point;
            SL=orderPrice+100*_Point;
            TP=orderPrice-100*_Point;
            lots=minLot;;
            sendOrder(ORDER_TYPE_SELL_STOP,orderPrice,SL,TP,lots,"");
           }
         if(pendingType==-2)
           {
            orderPrice=price+200*_Point;
            SL=orderPrice+100*_Point;
            TP=orderPrice-100*_Point;
            lots=minLot;;
            sendOrder(ORDER_TYPE_SELL_LIMIT,orderPrice,SL,TP,lots,"");
           }
        }
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint sendOrder(ENUM_ORDER_TYPE orderType,double Price,double SL,double TP,double Volume,string comment)
  {
//--- prepare a request
   MqlTradeRequest request= {0};
   request.action=TRADE_ACTION_PENDING;
   request.type=orderType;
   request.magic=magic;
   request.symbol=_Symbol;
   request.volume=Volume;
   request.sl=NormalizeDouble(SL,_Digits);
   request.tp=NormalizeDouble(TP,_Digits);
   request.deviation=Slipage;
   request.comment=comment;
//  request.type_filling=GetFilling(request.symbol);
   request.price=NormalizeDouble(Price,_Digits);
   request.expiration=TimeCurrent()+PeriodSeconds(PERIOD_CURRENT)*10;
//--- send a trade request
   MqlTradeResult result= {0};
   bool success=OrderSend(request,result);
   if(!success)
     {
      Alert(_Symbol," Error in order send: ",orderType," ",result.retcode," lots= ",Volume," Price= ",Price," SL= ",SL," request.type= ",request.type," TP= ",TP);
     }
//--- return code of the trade server reply
   return result.retcode;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deletePendingOrder(ulong ticket)
  {
//--- declare and initialize the trade request and result of trade request
   MqlTradeRequest request= {0};
   MqlTradeResult  result= {0};
   int total=OrdersTotal(); // total number of placed pending orders
//--- iterate over all placed pending orders
   for(int i=total-1; i>=0; i--)
     {
      ulong  order_ticket=OrderGetTicket(i);                   // order ticket
      ulong  exmagic=OrderGetInteger(ORDER_MAGIC);
      string order_symbol=OrderGetString(ORDER_SYMBOL);              // MagicNumber of the order
      //--- if the MagicNumber matches
      if(exmagic==magic && order_symbol==Symbol() && (order_ticket==ticket || ticket==0))
        {
         //--- zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);
         //--- setting the operation parameters
         request.action=TRADE_ACTION_REMOVE;                   // type of trade operation
         request.order = order_ticket;                         // order ticket
         //--- send the request
         if(!OrderSend(request,result))
            PrintFormat("deletePOrderSend error %d",GetLastError());  // if unable to send the request, output the error code
         //--- information about the operation
         PrintFormat("deletePretcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
        }
     }
  }
//+------------------------------------------------------------------+
