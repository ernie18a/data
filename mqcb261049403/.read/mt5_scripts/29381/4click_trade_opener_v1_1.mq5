//+------------------------------------------------------------------+
//|                                 4click Trade Opener_v1.1.mq5     |
//|                                 Copyright © 2020, behzad.mvr     |
//|                                         Behzad.mvr@gmail.com     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Set riskPercent=0 if you want to use riskAmount
double riskPercent=2; //Risk Percent (%)
double riskAmount=0; //Risk Amount ($)
double minLot=0.01; //Minimum Lot Allowed by Broker to open Orders
int totalPositions=1; //Number of Positions to open
int Slipage=20; //Max order slipage(deviation) (points)


ulong magic=0;
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
      Alert("Set one of risk parameters = 0 to other parameter works.");
      return(0);
     }
   if(riskPercent==0 && riskAmount==0)
     {
      Alert("Don't set both of risk parameters = 0");
      return(0);
     }

   double sl=0,tp=0;
   double lots=0;

   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double maxLoss=0;
   if(riskPercent!=0)
      maxLoss=(riskPercent/100)*equity;
   else
      if(riskAmount!=0)
         maxLoss=riskAmount;
   double usedLoss=0;
   double remainedLoss=0;

   ENUM_POSITION_TYPE orderType=-1;

   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal();

   int minLotCnt=0;
   for(int i=0; i<total; i++)
     {
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);// ticket of the position
      string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol
      double volume=PositionGetDouble(POSITION_VOLUME);    // volume of the position
      if(position_symbol!=_Symbol || volume!=minLot)
         continue;
      minLotCnt++;
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
      magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position
      sl=PositionGetDouble(POSITION_SL);  // Stop Loss of the position
      if(sl==0)
        {
         Alert("Please Set the StopLoss Line on Chart.");
         return(0);
        }
      tp=PositionGetDouble(POSITION_TP);  // Take Profit of the position
      orderType=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position
     }
   if(minLotCnt==0)
     {
      Alert("First there must be a "+DoubleToString(minLot,2)+" lot open position for "+_Symbol);
      return(0);
     }
   if(minLotCnt>1)
     {
      Alert("There must be only one "+DoubleToString(minLot,2)+" lot open position for "+_Symbol);
      return(0);
     }
//----

   if(orderType==POSITION_TYPE_BUY)
     {
      int lotDivider=2;
      double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      usedLoss=minLot*(ask-sl)*tick/_Point;
      remainedLoss=maxLoss-usedLoss;
      for(int k=1; k<=totalPositions; k++)
        {
         if(remainedLoss<k*usedLoss)
           {
            Alert("There is only enough risked eguity to split order into "+IntegerToString(k-1)+" position.");
            totalPositions=k-1;
            break;
           }
        }
      if(totalPositions==0)
         return(0);
      lots=NormalizeDouble((remainedLoss/((ask-sl)*tick/_Point)/totalPositions),2);
      for(int i=0; i<totalPositions; i++)
        {
         sendOrder(ORDER_TYPE_BUY,sl,tp,lots,"");
         tp=tp+50*_Point;
        }
     }
//----
   if(orderType==POSITION_TYPE_SELL)
     {
      int lotDivider=2;
      bool secondTrade=true;
      double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      usedLoss=minLot*(sl-bid)*tick/_Point;
      remainedLoss=maxLoss-usedLoss;
      for(int k=1; k<=totalPositions; k++)
        {
         if(remainedLoss<k*usedLoss)
           {
            Alert("There is only enough risked eguity to split order into "+IntegerToString(k-1)+" position.");
            totalPositions=k-1;
            break;
           }
        }
      if(totalPositions==0)
         return(0);
      lots=NormalizeDouble((remainedLoss/((sl-bid)*tick/_Point)/totalPositions),2);
      for(int i=0; i<totalPositions; i++)
        {
         sendOrder(ORDER_TYPE_SELL,sl,tp,lots,"");
         tp=tp-50*_Point;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uint sendOrder(ENUM_ORDER_TYPE orderType,double SL,double TP,double Volume,string comment)
  {
//--- prepare a request
   MqlTradeRequest request= {};
   request.action=TRADE_ACTION_DEAL;
   request.type=orderType;
   request.magic=magic;
   request.symbol=_Symbol;
   request.volume=Volume;
   request.sl=NormalizeDouble(SL,_Digits);
   request.tp=NormalizeDouble(TP,_Digits);
   request.deviation=Slipage;
   request.comment=comment;
// request.type_filling=GetFilling(request.symbol);
   if(request.type==ORDER_TYPE_SELL)
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   else
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
//--- send a trade request
   MqlTradeResult result= {0};
   bool success=OrderSend(request,result);
   if(!success)
     {
      Alert(_Symbol," Error in order send: ",orderType," ",result.retcode," lots= ",Volume);
     }
//--- return code of the trade server reply
   return result.retcode;
  }
