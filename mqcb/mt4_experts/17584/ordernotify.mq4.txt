//+--------------------- ---------------------------------------------+
//|                                                   OrderNotify.mq4 |
//|                                2017, Tomas Hruby / Parbest s.r.o. |
//|                                             http://tomashruby.com |
//+-------------------------------------------------------------------+
#property copyright   "2017, Tomas Hruby - Parbest.com"
#property link        "http://tomashruby.com" 
#property version     "1.0"; 
#property description "OrderNotify is Expert Advisor for email monitoring newly opened and closed orders.";
#property strict

int   OrdersTotalOld = 0;
int   OrdersTotalHandle = 0;
bool  first = true;

void OnTick(){

    OrdersTotalHandle = OrdersTotal();
 
    // If this is the first launch of the Expert, we don't know the amount of orders on the previous tick.
    // So just remeber it, mark that the first launch has been happened, and exit.
    if(first){
        OrdersTotalOld = OrdersTotalHandle;
        first = false;
    }else{ 
      // Compare the amount of positions on the previous tick with the current amount
      // If it has been changed, display message
       if(OrdersTotalHandle > OrdersTotalOld){
           SendMail("New order ",StringConcatenate(InfoOpened(),"\n",accountDetails()));
       }
       if(OrdersTotalHandle < OrdersTotalOld){
           SendMail("Closed order ",StringConcatenate(InfoClosed(),"\n",accountDetails()));
       }
       
      // Memorize the amount of positions
      OrdersTotalOld = OrdersTotalHandle;
   }
}

string InfoClosed(){
   string info;
   for(int i=OrdersHistoryTotal();i>=OrdersHistoryTotal()-1;i--)
   {
      if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)){
         info = orderDetails();
      }
   }
   return(info);
}   

string InfoOpened(){
   string info;
   ulong orderOpenTime,lastOpenTime=0;
   int latestTicket=0;
   for(int r=0;r<OrdersTotal();r++){
      if(OrderSelect(r,SELECT_BY_POS,MODE_TRADES)==true){   
         orderOpenTime = OrderOpenTime();
         if(orderOpenTime > lastOpenTime){
            lastOpenTime = orderOpenTime;
            latestTicket = OrderTicket();
         }
      }
   }
   if(latestTicket>0){
      if(OrderSelect(latestTicket,SELECT_BY_TICKET,MODE_TRADES)){
         info = orderDetails(); 
      }
   }
   return(info);
}

string orderDetails(){
   string info = StringConcatenate(OrderSymbol()," ",CmdPrint(OrderType())," ",DoubleToStr(OrderLots(),2),": ",DoubleToStr(OrderProfit(),2)," (",DoubleToStr(OrderSwap(),2),") ",AccountCurrency());
   return(info);
}

string accountDetails(){
   string info = StringConcatenate("Account: ",AccountNumber(),", balance: ",DoubleToStr(AccountBalance(),2)," ",AccountCurrency(),", profit: ",DoubleToStr(AccountProfit(),2)," ",AccountCurrency());
   return(info);
}


string CmdPrint(int Cmd){
   if(Cmd==OP_BUY){
      return ("BUY");
   }else if(Cmd==OP_BUYSTOP){
         return ("BUY STOP");
   }else if(Cmd==OP_BUYLIMIT){
         return ("BUY LIMIT");
   }else if(Cmd==OP_SELL){
         return ("SELL");
   }else if(Cmd==OP_SELLSTOP){
         return ("SELL STOP");                        
   }else if(Cmd==OP_SELLLIMIT){
      return ("SELL LIMIT");
   }else{
      return("");
   }
}