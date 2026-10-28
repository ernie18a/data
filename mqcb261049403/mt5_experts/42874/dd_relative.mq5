//+------------------------------------------------------------------+
//|                                        Get Drawdown Relative.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+

#property copyright "Copyright ©Arthur."
#property link      "https://www.mql5.com/es/users/neverwolf"
#property version   "1.0"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input int MAGIC = 232323;
//---

//+------------------------------------------------------------------+
//| Expert Initialization function                                   |
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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   DD_Relative();
  }
//+------------------------------------------------------------------+
//| Calculate Relative Drawdown Percent                              |
//+------------------------------------------------------------------+
double DD_Relative()
  {
   double DD = 0.0;
//Main Calculation
   DD = ((Current_LossOrProfit() * 100) / AccountInfoDouble(ACCOUNT_BALANCE));
   DD = NormalizeDouble(DD, 2);
   Comment(DoubleToString(DD));
   return (DD);
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
double Current_LossOrProfit()
  {
   double Profit = 0;
   double Positionsprofit=0.0;
//Go through all positions
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      if(PositionGetTicket(i))
        {
         //Select the magic number and the symbol
         if(PositionGetInteger(POSITION_MAGIC)== MAGIC && PositionGetString(POSITION_SYMBOL) == Symbol())
            Positionsprofit = Positionsprofit + PositionGetDouble(POSITION_COMMISSION) + PositionGetDouble(POSITION_SWAP) + PositionGetDouble(POSITION_PROFIT);
         Profit = NormalizeDouble(Positionsprofit, 2);
        }
     }
   return(Profit);
  }
//+------------------------------------------------------------------+
