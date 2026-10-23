//+------------------------------------------------------------------+
//|                                                 Filling Type.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                          https://www.mql5.com/es/users/neverwolf |
//+------------------------------------------------------------------+

#property copyright "Copyright ©Arthur."
#property link      "https://www.mql5.com/es/users/neverwolf"
#property version   "1.0"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ENUM_ORDER_TYPE_FILLING fillingType = SetTypeFillingBySymbol(Symbol());

   if(fillingType == ORDER_FILLING_FOK)
     {
      Comment("Fill or Kill (FOK) Filling Policy");
      Print("Fill or Kill (FOK) Filling Policy");
     }
   if(fillingType == ORDER_FILLING_IOC)
     {
      Comment("Immediate or Cancel (IOC) Filling Policy");
      Print("Immediate or Cancel (IOC) Filling Policy");
     }
   if(fillingType == ORDER_FILLING_RETURN)
     {
      Comment("Return Filling Policy");
      Print("Return Filling Policy");
     }

  }
//+------------------------------------------------------------------+
//---
//--- SetTypeFillingBySymbol
ENUM_ORDER_TYPE_FILLING SetTypeFillingBySymbol(const string symbol)
  {
// Get possible filling policy types by symbol
   uint filling = (uint)SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);

   if((filling & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
     {
      return ORDER_FILLING_FOK;
     }
   else
      if((filling & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
        {
         return ORDER_FILLING_IOC;
        }
      else
        {
         return ORDER_FILLING_RETURN;
        }
  }
//---
//---
