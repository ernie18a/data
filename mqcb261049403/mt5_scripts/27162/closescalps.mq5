#property copyright           "Mokara"
#property link                "https://www.mql5.com/en/users/mokara"
#property description         "Close Scalps"
#property version             "1.0"
#property script_show_inputs  true

input bool Profit = false;   //Only Positions in Profit

void OnStart()
{
   int pTotal = PositionsTotal();
   ulong pTicket;
   double pLot, pVolume;
   string pSymbol;
   MqlTradeRequest tReq;
   MqlTradeResult tRes;
   MqlTradeCheckResult tChk;
   
   for(int i = pTotal - 1; i >= 0; i--)
   {
      pTicket = PositionGetTicket(i);
      pSymbol = PositionGetSymbol(i);
      if(!PositionSelectByTicket(pTicket)) continue;
      if(PositionGetInteger(POSITION_MAGIC) != 999) continue;
      if(PositionGetDouble(POSITION_PROFIT) < 0 && Profit == true) continue;      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
         ZeroMemory(tReq);
         ZeroMemory(tRes);
         pVolume = PositionGetDouble(POSITION_VOLUME);
         pLot = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MAX);
         if(pVolume > pLot) pVolume = pLot;

         tReq.type   = ORDER_TYPE_SELL;
         tReq.price  = SymbolInfoDouble(pSymbol, SYMBOL_BID);
         tReq.action = TRADE_ACTION_DEAL;
         tReq.symbol = pSymbol;
         tReq.volume = pVolume;
         tReq.sl = 0;
         tReq.tp = 0;
         tReq.deviation = 5;
         tReq.position = PositionGetInteger(POSITION_TICKET);
         
         if(!OrderSend(tReq, tRes) || tRes.retcode != TRADE_RETCODE_DONE)
         {
            Print("ERROR: order send. Error Code: " + tRes.retcode);
         }
      }
      
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
      {
         ZeroMemory(tReq);
         ZeroMemory(tRes);
         pVolume = PositionGetDouble(POSITION_VOLUME);
         pLot = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MAX);
         if(pVolume > pLot) pVolume = pLot;
         
         tReq.type   = ORDER_TYPE_BUY;
         tReq.price  = SymbolInfoDouble(pSymbol, SYMBOL_ASK);
         tReq.action = TRADE_ACTION_DEAL;
         tReq.symbol = pSymbol;
         tReq.volume = pVolume;
         tReq.sl = 0;
         tReq.tp = 0;
         tReq.deviation = 5;
         tReq.position = PositionGetInteger(POSITION_TICKET);      
 
         if(!OrderSend(tReq, tRes) || tRes.retcode != TRADE_RETCODE_DONE)
         {
            Print("ERROR: order send. " + pSymbol + tRes.retcode);
         }
      }
   }
}   

