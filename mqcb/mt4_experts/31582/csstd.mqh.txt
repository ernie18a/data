//+------------------------------------------------------------------+
//|                                                        CSstd.mqh |
//|                                    Copyright © 2021, cs software |
//|                                   https://cs-robots5.webnode.se/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, cs software"
#property link      "https://cs-robots5.webnode.se/"
#property strict
extern int            TakeProfit    = 460,//Take profit points
                      StopLoss      = 520;//Stop loss points
extern double         BullsPwr      = 1.056,//Bulls power increase
                      BearsPwr      = -0.078;//Bears power decrease
extern bool           Utr           = false;//Apply trailing stop ?
extern int            TrailingStart = 290,//Trailing start points
                      TrailingStep  = 120;//Trailing step points
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tcheck()
  {
   if(TrailingStep>TrailingStart)
      return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SC(double val)
  {
   double
   MinStop=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
   if(val < MinStop)
      val = MinStop;
   return(val);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckVolumeValue(double checkedvol)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(checkedvol<min_volume)
      return(min_volume);

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(checkedvol>max_volume)
      return(max_volume);

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(checkedvol/volume_step);
   if(MathAbs(ratio*volume_step-checkedvol)>0.0000001)
      return(ratio*volume_step);
   return(checkedvol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
   if(free_margin<0)
     {
      string oper=(type==OP_BUY)? "Buy":"Sell";
      Print("Not enough money for ", oper," ",lots, " ", symb, " Error code=",GetLastError());
      return(false);
     }
   if(Period()!=PERIOD_H1)
      return(false);
   return(true);
  }
//+------------------------------------------------------------------+
