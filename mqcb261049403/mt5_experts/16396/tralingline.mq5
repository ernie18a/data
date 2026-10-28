//+------------------------------------------------------------------+
//|                                                  TralingLine.mq5 |
//|                                                         Viktorov |
//|                                                v4forex@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Viktorov"
#property link      "v4forex@yandex.ru"
#property version   "1.00"
#include <Trade\Trade.mqh>
input  int     StopLevel   = 70;
input  color   ColorLine   = clrIndianRed;
input  color   ColorProf   = clrGreen;
input  color   ColorLoss   = clrRed;

int Buy, Sell;
double prbuys, prsels, fixProfitBuy, fixProfitSell;
double newPriceBuys = 0, newPriceSells = 0;
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlRates mqlRates[];
    MqlTick mqlTick;
      string str = ", убыток  ", strBuy = "Buy закроются по цене ", strSell = "Sell закроются по цене ";
     CountTrades();
    fixProfit();
   do while(!SymbolInfoTick(_Symbol, mqlTick));
   do while(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, mqlRates) < 1);
   if(ObjectFind(0, "StopBuy") > -1)
    {
     datetime timeStopBuy = (datetime)ObjectGetInteger(0, "StopBuy", OBJPROP_TIME, 0);
     if(newPriceBuys == 0 && timeStopBuy == mqlRates[0].time+PeriodSeconds())
      {
       ObjectSetInteger(0, "StopBuy", OBJPROP_TIME, 0, mqlRates[0].time+2*PeriodSeconds());
       ObjectSetInteger(0, "StopBuy", OBJPROP_TIME, 1, mqlRates[0].time+9*PeriodSeconds());
      }
    }
   if(ObjectFind(0, "StopSell") > -1)
    {
     datetime timeStopSell = (datetime)ObjectGetInteger(0, "StopSell", OBJPROP_TIME, 0);
     if(newPriceSells == 0 && timeStopSell == mqlRates[0].time+PeriodSeconds())
      {
       ObjectSetInteger(0, "StopSell", OBJPROP_TIME, 0, mqlRates[0].time+2*PeriodSeconds());
       ObjectSetInteger(0, "StopSell", OBJPROP_TIME, 1, mqlRates[0].time+9*PeriodSeconds());
      }
    }
   
   if(newPriceBuys > 0 && mqlTick.bid <= newPriceBuys)
   {
    allPositionClose(POSITION_TYPE_BUY);
     if(ObjectFind(0, "StopBuy") > -1)
      {
       ObjectDelete(0, "LableBuy");
        ObjectDelete(0, "StopBuy");
       Buy = 0;
      }
   }
   if(newPriceSells > 0 && mqlTick.ask >= newPriceSells)
   {
    allPositionClose(POSITION_TYPE_SELL);
     if(ObjectFind(0, "StopSell") > -1)
      {
       ObjectDelete(0, "LableSell");
        ObjectDelete(0, "StopSell");
       Sell = 0;
      }
   }
   
   if(Buy > 0)
    {
     if(ObjectFind(0, "StopBuy") < 0)
      lineCreate(POSITION_TYPE_BUY);
     else
       {
        if(fixProfitBuy != 0) lableCreate(POSITION_TYPE_BUY);
         if(fixProfitBuy == 0) ObjectDelete(0, "LableBuy");
          str = fixProfitBuy > 0 ? ", прибыль  " : ", убыток  ";
           ObjectSetString(0, "LableBuy", OBJPROP_TEXT, (strBuy+ DoubleToString(newPriceBuys, _Digits)+ str+ DoubleToString(fixProfitBuy, 2)));
          color clr;
         clr = fixProfitBuy > 0 ? ColorProf : ColorLoss;
        ObjectSetInteger(0, "LableBuy", OBJPROP_COLOR, clr);
       }
    }
   if(Sell > 0)
    if(ObjectFind(0, "StopSell") < 0)
     lineCreate(POSITION_TYPE_SELL);
    else
      {
       if(fixProfitSell != 0) lableCreate(POSITION_TYPE_SELL);
        if(fixProfitSell == 0) ObjectDelete(0, "LableSell");
         str = fixProfitSell > 0 ? ", прибыль  " : ", убыток  ";
          ObjectSetString(0, "LableSell", OBJPROP_TEXT, (strSell+ DoubleToString(newPriceSells, _Digits)+ str+ DoubleToString(fixProfitSell, 2)));
         color clr;
        clr = fixProfitSell > 0 ? ColorProf : ColorLoss;
       ObjectSetInteger(0, "LableSell", OBJPROP_COLOR, clr);
      }
  }
//+------------------------------------------------------------------+

/**************************Закрытие позиций***************************/
void allPositionClose(ENUM_POSITION_TYPE type)
{
 CTrade trade;
  int i = 0, total = PositionsTotal();
   int ticket;
    for(i = total-1; i >= 0; i--)
     {
      ticket = (int)PositionGetTicket(i);
       if(PositionGetInteger(POSITION_TYPE) == type &&  PositionGetString(POSITION_SYMBOL) == _Symbol)
        trade.PositionClose(ticket);
     }
 
}/*******************************************************************/

/***************************рисование линий***************************/
void lineCreate(ENUM_POSITION_TYPE sig)
{
 MqlRates mqlRates0[], mqlRates4[];
  string nameLine = "";
   double Otstup_ = StopLevel*_Point;
    do
     while(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, mqlRates0) < 1 || CopyRates(_Symbol, PERIOD_H4, 0, 1, mqlRates4) < 1);
    if(sig == POSITION_TYPE_BUY)
     {
       prbuys = NormalizeDouble(mqlRates4[0].low-Otstup_, _Digits);
        nameLine = "StopBuy";
     }
    if(sig == POSITION_TYPE_SELL)
     {
       prsels = NormalizeDouble(mqlRates4[0].high+Otstup_, _Digits);
        nameLine = "StopSell";
     }
        double price = sig == POSITION_TYPE_BUY ? prbuys : prsels;
         
       if(ObjectCreate(0, nameLine, OBJ_TREND, 0, mqlRates0[0].time+2*PeriodSeconds(), price, mqlRates0[0].time+10*PeriodSeconds(), price))
        {
         ObjectSetInteger(0, nameLine, OBJPROP_COLOR, ColorLine);
         ObjectSetInteger(0, nameLine, OBJPROP_STYLE, STYLE_DOT);
         ObjectSetInteger(0, nameLine, OBJPROP_RAY_RIGHT, true);
         ObjectSetInteger(0, nameLine, OBJPROP_SELECTED, true);
         ObjectSetInteger(0, nameLine, OBJPROP_SELECTABLE, true);
         //Print("создан объект ", nameLine);
        }

}/*******************************************************************/

void lableCreate(ENUM_POSITION_TYPE sig)
{
  string nameLable = "";
    if(sig == POSITION_TYPE_BUY)
     {
      nameLable = "LableBuy";
     }
    if(sig == POSITION_TYPE_SELL)
     {
      nameLable = "LableSell";
     }
       if(ObjectCreate(0, nameLable, OBJ_LABEL, 0, 0, 0))
        ObjectSetInteger(0, nameLable, OBJPROP_XDISTANCE, 5); 

         if(ObjectFind(0, "LableBuy") < 0 || nameLable == "LableBuy")
          ObjectSetInteger(0, nameLable, OBJPROP_YDISTANCE, 20);
           else if(ObjectFind(0, "LableBuy") > -1 && nameLable == "LableSell")
             ObjectSetInteger(0, nameLable, OBJPROP_YDISTANCE, 40);

}/*******************************************************************/

/**********************Подсчёт открытых позиций***********************/
void CountTrades()
{
  Buy = 0; Sell = 0;
  int i = 0, ticket, posTotal = PositionsTotal();
   for(i = 0; i < posTotal; i++)
    {
     ticket = (int)PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol)
       {
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) Sell++;
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) Buy++;
       }
     }
}/*******************************************************************/

/********************Подсчёт профита всех ордеров********************/ 
void fixProfit()
{  
   double TICKVALUE = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   MqlRates mqlRates[];
   do while(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, mqlRates) < 1);
   newPriceBuys = NormalizeDouble(ObjectGetValueByTime(0, "StopBuy", mqlRates[0].time), _Digits);
   newPriceSells = NormalizeDouble(ObjectGetValueByTime(0, "StopSell", mqlRates[0].time), _Digits);
    fixProfitBuy = 0; fixProfitSell = 0;
     int ticket, posTotal = PositionsTotal();
    MqlTick mqlTick;
   do while(!SymbolInfoTick(_Symbol, mqlTick));
   
   for(int i = posTotal-1; i >= 0; i--)
    {
     ticket = (int)PositionGetTicket(i);
     if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol)
       {
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && newPriceBuys > 0)
         {
          fixProfitBuy += (comissionPosition(PositionGetInteger(POSITION_IDENTIFIER)) +
                           PositionGetDouble(POSITION_SWAP) + 
                          (newPriceBuys - PositionGetDouble(POSITION_PRICE_OPEN))/_Point*TICKVALUE*PositionGetDouble(POSITION_VOLUME));
         } 
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && newPriceSells > 0)
         {
          fixProfitSell += (comissionPosition(PositionGetInteger(POSITION_IDENTIFIER)) +
                           PositionGetDouble(POSITION_SWAP) + 
                          (PositionGetDouble(POSITION_PRICE_OPEN) - newPriceSells)/_Point*TICKVALUE*PositionGetDouble(POSITION_VOLUME));
         } 
       }
    }
}/*******************************************************************/

/*******************Определение комиссии позиции*********************/ 
double comissionPosition(long identifer)
{
 double comission = 0;
  ulong dealTicket = 0;
 int i, dealsTotal = HistorySelectByPosition(identifer);
  for(i = 0; i < dealsTotal; i++)
   {
    dealTicket = HistoryDealGetTicket(i);
    comission = HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
   }
 return(comission);
}/*******************************************************************/

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0, "StopBuy");
   ObjectDelete(0, "StopSell");
   ObjectDelete(0, "LableBuy");
   ObjectDelete(0, "LableSell");
  }

