//+------------------------------------------------------------------+
//|                                                    Swap Informer |
//|                                 Copyright 2022, Evgeniy Chumakov |
//+------------------------------------------------------------------+
#property copyright "Evgeniy Chumakov"
#property description "Search for symbols in the market watch window with a positive swap."
#property version "1.0"
#property link "https://www.mql5.com/en/users/jack857752/seller"
#property strict

//+------------------------------------------------------------------+
void OnInit()
  {
   EventSetTimer(1);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   int Symbol_Total = SymbolsTotal(true);

   if(Symbol_Total == 0)
     {
      Comment("Error! No symbols in the market watch window!");
      return;
     }

   string SwapInfo = "";

   for(int pos = 0; pos < Symbol_Total; pos++)
     {

      string Symbol_Name = SymbolName(pos,true);

      double Swap_Long = SymbolInfoDouble(Symbol_Name,SYMBOL_SWAP_LONG);
      double Swap_Short = SymbolInfoDouble(Symbol_Name,SYMBOL_SWAP_SHORT);

      if(Swap_Long > 0 && Swap_Short <= 0)
        {
         StringAdd(SwapInfo,Symbol_Name + ":  " + "Swap Long (Buy) = " + DoubleToString(Swap_Long,8) + "\n");
        }

      if(Swap_Long <= 0 && Swap_Short > 0)
        {
         StringAdd(SwapInfo,Symbol_Name + ":  " + "Swap Short (Sell) = " + DoubleToString(Swap_Short,8) + "\n");
        }

     }

   Comment(" - - Positive Swap Symbols - - ","\n",SwapInfo);

   return;
  }
//+------------------------------------------------------------------+