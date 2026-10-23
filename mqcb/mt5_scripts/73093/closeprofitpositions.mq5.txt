//+------------------------------------------------------------------+
//|                                         CloseProfitPositions.mq5 |
//|                                  Copyright 2026, Volodymyr Bobal |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property script_show_inputs

#include <Trade\Trade.mqh>
CTrade trade;

enum E_CloseMode {
   CLOSE_PROFIT, // Только прибыльные
   CLOSE_LOSS,   // Только убыточные
   CLOSE_ALL     // Закрыть абсолютно все
};

input E_CloseMode CloseMode = CLOSE_PROFIT;
input long        TargetMagic = 0; // Фильтр по Magic Number (0 - все)

void OnStart()
{
   int closedCount = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket <= 0) continue;
      
      if(TargetMagic != 0 && PositionGetInteger(POSITION_MAGIC) != TargetMagic) continue;
      
      double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + PositionGetDouble(POSITION_COMMISSION);
      
      bool shouldClose = false;
      if(CloseMode == CLOSE_PROFIT && profit > 0) shouldClose = true;
      else if(CloseMode == CLOSE_LOSS && profit < 0) shouldClose = true;
      else if(CloseMode == CLOSE_ALL) shouldClose = true;
      
      if(shouldClose)
      {
         if(trade.PositionClose(ticket)) closedCount++;
      }
   }
   
   Print("Успешно закрыто позиций: ", closedCount);
}