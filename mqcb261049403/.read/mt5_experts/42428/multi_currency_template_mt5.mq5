//+------------------------------------------------------------------+
//|                                    MultiCurrency Template EA MT5 |
//|                                                   Copyright 2023 |
//|                                               drdz9876@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2023, drdz9876@gmail.com"
#property version "1.2"
#property strict
#include <Trade\Trade.mqh> CTrade trade;


input const string Main="//---------------- Main Input Settings ----------------//";
input double Lots             = 0.01;      // Basic lot size
input int    StopLoss         = 50;    //Stoploss (in Pips)
input int    TakeProfit       = 100;  //TakeProfit (in Pips)
input int    TrailingStop     = 15; // Trailing Stop (in points)
input int    TrailingStep     = 5;// Trailing Step (in points)
input int    Slippage         = 100;  // Tolerated slippage in brokers' pips
input bool   NewBarTrade      = true; // Trade at New Bar
input ENUM_TIMEFRAMES newBarPeriod = PERIOD_M15;   //New Bar Period
input bool   TradeMultipair   = false; // Trade Multipair
input string PairsToTrade     = "EURUSD,GBPUSD"; //Pairs to Trade
input int    Magic            = 1; // Magic Number
input string Commentary       = "MultiCurrency EA";   //EA Comment

input const string Martin="//---------------- Martingale Settings ----------------//";
input bool EnableMartingale = true;   //Enable Martingale
input double nextLot       = 1.2;    //Lot Multiplier
input int  StepPips        = 300;     //Pip Step (in Points)
input bool EnableTPAvg     = true;   //Enable TP Average
input int  TPPlus          = 75;      //TP Average (in Points)

//--------
int      NoOfPairs;           // Holds the number of pairs passed by the user via the inputs screen
string   TradePair[];         //Array to hold the pairs traded by the user
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Expert
  {
private:
   int               Signal(string sym);
   double            lotAdjust(string sym, double lots);
   bool              NewBar(string sym);
   void              BuyOrder(string sym);
   void              SellOrder(string sym);
   void              Trailing(string sym);
   void              ModifyStopLoss(string sym, double ldStopLoss);
   void              Martingale(string sym);
   bool              compareDoubles(string sym, double val1, double val2);

protected:
   bool              CheckMoneyForTrade(string sym, double lots,ENUM_ORDER_TYPE type);
   bool              CheckVolumeValue(string sym, double volume);

public:
   void              Trade(string sym);
   double            PipValue;
  };

Expert EA[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(Magic);
   trade.SetDeviationInPoints(Slippage);

   if(TradeMultipair)
     {
      //Extract the pairs traded by the user
      NoOfPairs = StringFindCount(PairsToTrade,",")+1;
      ArrayResize(TradePair, NoOfPairs);
      ArrayResize(EA, NoOfPairs);
      string AddChar = StringSubstr(Symbol(),6, 4);
      StrPairToStringArray(PairsToTrade, TradePair, AddChar);
     }
   else
     {
      //Fill the array with only chart pair
      NoOfPairs = 1;
      ArrayResize(TradePair, NoOfPairs);
      ArrayResize(EA, NoOfPairs);
      TradePair[0] = Symbol();
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   ENUM_ACCOUNT_TRADE_MODE tradeMode=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   switch(tradeMode)
     {
      case(ACCOUNT_TRADE_MODE_DEMO):
        {
         break;
        }
      case(ACCOUNT_TRADE_MODE_CONTEST):
        {
         break;
        }
      case(ACCOUNT_TRADE_MODE_REAL):
        {
         Alert("This EA Is Just for Test");
         ExpertRemove();
         break;
        }
     }

   if(TradeMultipair)
     {
      for(int i = 0; i<NoOfPairs; i++)
        {
         EA[i].Trade(TradePair[i]);
        }
     }
   else
     {
      EA[0].Trade(TradePair[0]);
     }

   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Expert::Trade(string sym)
  {
   double ask = SymbolInfoDouble(sym,SYMBOL_ASK);
   double bid = SymbolInfoDouble(sym,SYMBOL_BID);
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(sym,SYMBOL_DIGITS);

   if(digits == 3 || digits == 5)
      PipValue = 10*point;
   else
      PipValue = point;


   int countOpen = 0,b=0,s=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i)) // selects the position by index for further access to its properties
        {
         if(PositionGetString(POSITION_SYMBOL)==sym)
            if(PositionGetInteger(POSITION_MAGIC)==Magic)
              {
               countOpen++;
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                  b++;
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                  s++;
              }
        }
     }
   double SLbuy = 0, TPbuy = 0, SLsell = 0, TPsell = 0;

   if(StopLoss > 0)
     {
      SLbuy = ask - StopLoss * PipValue;
      SLsell = bid + StopLoss * PipValue;
     }
   if(TakeProfit > 0)
     {
      TPbuy = ask + TakeProfit * PipValue;
      TPsell = bid - TakeProfit * PipValue;
     }

   if((NewBarTrade && NewBar(sym)) || (!NewBarTrade))
      if(countOpen == 0)
        {
         if(Signal(sym) == 1)
           {
            if(CheckMoneyForTrade(sym,Lots,ORDER_TYPE_BUY) && CheckVolumeValue(sym,Lots))
               if(b == 0)
                  trade.Buy(Lots,sym,ask,SLbuy,TPbuy,Commentary);
           }
         else
            if(Signal(sym) == -1)
              {
               if(CheckMoneyForTrade(sym,Lots,ORDER_TYPE_SELL) && CheckVolumeValue(sym,Lots))
                  if(s == 0)
                     trade.Sell(Lots,sym,bid,SLsell,TPsell,Commentary);
              }
        }

   if(EnableMartingale)
      Martingale(sym);

   Trailing(sym);

   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert::Signal(string sym)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   if(CopyRates(sym,PERIOD_D1,0,3,rates) < 0)
      return(0);

   if(rates[0].close < rates[1].open && rates[1].close > rates[1].open)
      return(1);
   if(rates[0].close > rates[1].open && rates[1].close < rates[1].open)
      return(-1);

   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Expert::Martingale(string sym)
  {
   double ask = SymbolInfoDouble(sym,SYMBOL_ASK);
   double bid = SymbolInfoDouble(sym,SYMBOL_BID);
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
   int stopLevel = (int)SymbolInfoInteger(sym,SYMBOL_TRADE_STOPS_LEVEL);
   int spread = (int)SymbolInfoInteger(sym,SYMBOL_SPREAD);

   double
   BuyPriceMax=0,BuyPriceMin=0,BuyPriceMaxLot=0,BuyPriceMinLot=0,
   SelPriceMin=0,SelPriceMax=0,SelPriceMinLot=0,SelPriceMaxLot=0,
   tpS1 = 0, tpB1 = 0;

   ulong
   BuyPriceMaxTic=0,BuyPriceMinTic=0,SelPriceMaxTic=0,SelPriceMinTic=0;

   ulong tkb= 0,tks=0;

   double
   opB=0,opS=0,lt=0,tpb=0,tps=0, slb=0,sls=0;

   double opBE = 0, ltB = 0, ltBE = 0, opSE = 0, ltS = 0, ltSE = 0, BEBuy = 0, BESell = 0;

   int OpenPos = 0, b = 0, s = 0;
   for(int k=PositionsTotal()-1; k>=0; k--)
     {
      if(PositionGetTicket(k))
        {
         if(PositionGetString(POSITION_SYMBOL)==sym)
           {
            if(PositionGetInteger(POSITION_MAGIC)==Magic)
              {
               OpenPos++;
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  b++;
                  opB=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),digits);
                  tpb = NormalizeDouble(PositionGetDouble(POSITION_TP),digits);
                  slb = NormalizeDouble(PositionGetDouble(POSITION_SL),digits);
                  lt=NormalizeDouble(PositionGetDouble(POSITION_VOLUME),2);
                  tkb = PositionGetInteger(POSITION_TICKET);
                  ltB=NormalizeDouble(PositionGetDouble(POSITION_VOLUME),2);
                  opBE += PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
                  ltBE += PositionGetDouble(POSITION_VOLUME);
                  BEBuy = opBE/ltBE;
                  if(opB>BuyPriceMax || BuyPriceMax==0)
                    {
                     BuyPriceMax    = opB;
                     BuyPriceMaxLot = ltB;
                     BuyPriceMaxTic = tkb;
                    }
                  if(opB<BuyPriceMin || BuyPriceMin==0)
                    {
                     BuyPriceMin    = opB;
                     BuyPriceMinLot = ltB;
                     BuyPriceMinTic = tkb;
                    }
                 }
               // ===
               else
                  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                    {
                     s++;
                     opS=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),digits);
                     tps = NormalizeDouble(PositionGetDouble(POSITION_TP),digits);
                     sls = NormalizeDouble(PositionGetDouble(POSITION_SL),digits);
                     ltS=NormalizeDouble(PositionGetDouble(POSITION_VOLUME),2);
                     tks = PositionGetInteger(POSITION_TICKET);
                     opSE+= PositionGetDouble(POSITION_PRICE_OPEN) * PositionGetDouble(POSITION_VOLUME);
                     ltSE += PositionGetDouble(POSITION_VOLUME);
                     BESell = opSE/ltSE;
                     if(opS>SelPriceMax || SelPriceMax==0)
                       {
                        SelPriceMax    = opS;
                        SelPriceMaxLot = ltS;
                        SelPriceMaxTic = tks;
                       }
                     if(opS<SelPriceMin || SelPriceMin==0)
                       {
                        SelPriceMin    = opS;
                        SelPriceMinLot = ltS;
                        SelPriceMinTic = tks;
                       }
                    }
              }
           }
        }
     }
   double PipSteps = 0;
   PipSteps = StepPips * point;

   double buyLot = 0, selLot = 0;

   buyLot = lotAdjust(sym,BuyPriceMinLot * MathPow(nextLot,b));
   selLot = lotAdjust(sym,SelPriceMaxLot * MathPow(nextLot,s));

   if(b > 0)
     {
      if(BuyPriceMin - ask >= PipSteps)
        {
         if(CheckMoneyForTrade(sym,buyLot,ORDER_TYPE_BUY) && CheckVolumeValue(sym,buyLot))
           {
            trade.Buy(buyLot,sym,ask,0,0,Commentary);
           }
        }
     }
   if(s > 0)
     {
      if(bid - SelPriceMax >= PipSteps)
        {
         if(CheckMoneyForTrade(sym,selLot,ORDER_TYPE_SELL) && CheckVolumeValue(sym,selLot))
           {
            trade.Sell(selLot,sym,bid,0,0,Commentary);
           }
        }
     }

   double CORR = NormalizeDouble((TPPlus + stopLevel)* point,digits);

   for(int uui=PositionsTotal()-1; uui>=0; uui--)
     {
      if(PositionGetTicket(uui))
        {
         if(PositionGetString(POSITION_SYMBOL)==sym)
            if(PositionGetInteger(POSITION_MAGIC)==Magic)
              {
               if(b>=2 && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  if(EnableTPAvg)
                    {
                     if(!compareDoubles(sym,PositionGetDouble(POSITION_TP),BEBuy+CORR))
                        if(!trade.PositionModify(PositionGetInteger(POSITION_TICKET),slb,BEBuy+CORR))
                           Print(sym+" Buy Martingale TP Average Failed "+IntegerToString(GetLastError()));
                    }
                  else
                    {
                     if(!compareDoubles(sym,PositionGetDouble(POSITION_TP),tpb))
                        if(!trade.PositionModify(PositionGetInteger(POSITION_TICKET),slb,tpb))
                           Print(sym+" Buy Martingale TP Average Failed "+IntegerToString(GetLastError()));
                    }
                 }
               if(s>=2 && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  if(EnableTPAvg)
                    {
                     if(!compareDoubles(sym,PositionGetDouble(POSITION_TP),BESell-CORR))
                        if(!trade.PositionModify(PositionGetInteger(POSITION_TICKET),sls,BESell-CORR))
                           Print(sym+" Sell Martingale TP Average Failed "+IntegerToString(GetLastError()));
                    }
                  else
                    {
                     if(!compareDoubles(sym,PositionGetDouble(POSITION_TP),tps))
                        if(!trade.PositionModify(PositionGetInteger(POSITION_TICKET),sls,tps))
                           Print(sym+" Buy Martingale TP Average Failed "+IntegerToString(GetLastError()));
                    }
                 }
              }
        }
     }
   return;
   ResetLastError();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Expert::compareDoubles(string sym, double val1, double val2)
  {
   int digits = (int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
   if(NormalizeDouble(val1 - val2,digits-1)==0)
      return (true);

   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int StringFindCount(string str, string str2)
//+------------------------------------------------------------------+
// Returns the number of occurrences of STR2 in STR
// Usage:   int x = StringFindCount("ABCDEFGHIJKABACABB","AB")   returns x = 3
  {
   int c = 0;
   for(int i=0; i<StringLen(str); i++)
      if(StringSubstr(str,i,StringLen(str2)) == str2)
         c++;
   return(c);
  } // End int StringFindCount(string str, string str2)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StrPairToStringArray(string str, string &a[], string p_suffix, string delim=",")
//+------------------------------------------------------------------+
  {
   int z1=-1, z2=0;
   for(int i=0; i<ArraySize(a); i++)
     {
      z2 = StringFind(str,delim,z1+1);
      a[i] = StringSubstr(str,z1+1,z2-z1-1) + p_suffix;
      if(z2 >= StringLen(str)-1)
         break;
      z1 = z2;
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Expert::CheckMoneyForTrade(string sym, double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(sym,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- call of the checking function
   if(!OrderCalcMargin(type,sym,lots,price,margin))
     {
      //--- something went wrong, report and return false
      return(false);
     }
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      return(false);
     }
//--- checking successful
   return(true);
  }
//************************************************************************************************/
bool Expert::CheckVolumeValue(string sym, double volume)
  {

   double min_volume = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   if(volume < min_volume)
      return(false);

   double max_volume = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   if(volume > max_volume)
      return(false);

   double volume_step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);

   int ratio = (int)MathRound(volume / volume_step);
   if(MathAbs(ratio * volume_step - volume) > 0.0000001)
      return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Expert::lotAdjust(string sym, double lots)
  {
   double value = 0;
   double lotStep = SymbolInfoDouble(sym,SYMBOL_VOLUME_STEP);
   double minLot  = SymbolInfoDouble(sym,SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(sym,SYMBOL_VOLUME_MAX);
   value          = NormalizeDouble(lots/lotStep,0) * lotStep;

   if(value < minLot)
      value = minLot;
   if(value > maxLot)
      value = maxLot;

   return(value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Expert::NewBar(string sym)
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time=(datetime)SeriesInfoInteger(sym,newBarPeriod,SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }

//+------------------------------------------------------------------+
void Expert::Trailing(string sym)
  {
   double ask = SymbolInfoDouble(sym,SYMBOL_ASK);
   double  bid = SymbolInfoDouble(sym,SYMBOL_BID);
   double  points = SymbolInfoDouble(sym,SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
   int stopLevel = (int)SymbolInfoInteger(sym,SYMBOL_TRADE_STOPS_LEVEL);
   int spread = (int)SymbolInfoInteger(sym,SYMBOL_SPREAD);
//---
   if(digits == 3 || digits == 5)
      PipValue = 10*points;
   else
      PipValue = points;

   int b = 0, s = 0, count = 0;
   double TS = (TrailingStop + stopLevel)*points;
   double TST = (TrailingStep + stopLevel)*points;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i))
         if(PositionGetString(POSITION_SYMBOL) == sym)
            if(PositionGetInteger(POSITION_MAGIC) == Magic)
              {
               count++;
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                 {
                  b++;
                 }
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                 {
                  s++;
                 }
              }
     }

   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i))
         if(PositionGetString(POSITION_SYMBOL) == sym)
            if(PositionGetInteger(POSITION_MAGIC) == Magic)
              {
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && b == 1)
                 {
                  if((PositionGetDouble(POSITION_SL) == 0 || (PositionGetDouble(POSITION_SL) != 0 && PositionGetDouble(POSITION_SL) < PositionGetDouble(POSITION_PRICE_OPEN))) && bid - PositionGetDouble(POSITION_PRICE_OPEN) > TS + TST)
                    {
                     if(!trade.PositionModify(PositionGetInteger(POSITION_TICKET),NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) + TS,digits),PositionGetDouble(POSITION_TP)))
                        Print(sym+" Trail Buy Profit 1 Error "+ IntegerToString(GetLastError()));
                    }
                  if(PositionGetDouble(POSITION_SL) != 0 && PositionGetDouble(POSITION_SL) > PositionGetDouble(POSITION_PRICE_OPEN) && bid - PositionGetDouble(POSITION_SL) > TS + TST)
                    {
                     if(!trade.PositionModify(PositionGetInteger(POSITION_TICKET),NormalizeDouble(bid - TS,digits),PositionGetDouble(POSITION_TP)))
                        Print(sym+" Trail Buy Profit 2 Error "+ IntegerToString(GetLastError()));
                    }
                 }
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && s == 1)
                 {
                  if((PositionGetDouble(POSITION_SL) == 0 || (PositionGetDouble(POSITION_SL) != 0 && PositionGetDouble(POSITION_SL) > PositionGetDouble(POSITION_PRICE_OPEN))) && PositionGetDouble(POSITION_PRICE_OPEN) - ask > TS + TST)
                    {
                     if(!trade.PositionModify(PositionGetInteger(POSITION_TICKET),NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN) - TS,digits),PositionGetDouble(POSITION_TP)))
                        Print(sym+" Trail Sell Profit 1 Error "+ IntegerToString(GetLastError()));
                    }
                  if(PositionGetDouble(POSITION_SL) != 0 && PositionGetDouble(POSITION_SL) < PositionGetDouble(POSITION_PRICE_OPEN) && PositionGetDouble(POSITION_SL) - ask > TS + TST)
                    {
                     if(!trade.PositionModify(PositionGetInteger(POSITION_TICKET),NormalizeDouble(ask + TS,digits),PositionGetDouble(POSITION_TP)))
                        Print(sym+" Trail Sell Profit 2 Error "+ IntegerToString(GetLastError()));
                    }
                 }
              }
     }

   return;
   ResetLastError();
  }
//+------------------------------------------------------------------+
