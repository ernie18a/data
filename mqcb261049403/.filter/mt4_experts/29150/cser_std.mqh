//+------------------------------------------------------------------+
//|                                                     CSer_std.mqh |
//|                                    Copyright © 2021, cs software |
//|                                   https://cs-robots5.webnode.se/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, cs software"
#property link      "https://cs-robots5.webnode.se/"
#property strict
extern double       TakeFactor    = 4.2;//TP factor
extern double       StopFactor    = 4.9;//SL factor
extern bool         UseTstop      = true;//Trailing stop?
extern double       Tstart        = 40.;//Start pips
extern double       Tstep         = 19.;//Step pips
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tcheck()
  {
   if(Tstep>Tstart)
      return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PointValue()
  {
   double
   MPP=1;
   if((MarketInfo(Symbol(),MODE_DIGITS)==3)||(MarketInfo(Symbol(),MODE_DIGITS)==5))
      MPP=10;
   return(MarketInfo(Symbol(),MODE_TICKSIZE)*MPP);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Zd(double n, double d)
  {
   if(d == 0)
      return(0);
   else
      return(n/d);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SC(double val)
  {
   double
   MinStop=MarketInfo(Symbol(),MODE_STOPLEVEL)*PointValue();
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
