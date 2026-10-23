//+------------------------------------------------------------------+
//|                                                     TurnGrid.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#define MAGIC 001

#include <Trade\Trade.mqh>        CTrade        trade;
#include <Trade\AccountInfo.mqh>  CAccountInfo  accountInfo;
#include <Trade\SymbolInfo.mqh>   CSymbolInfo   symbolInfo;
#include <Trade\PositionInfo.mqh> CPositionInfo positionInfo;

input double   gridDistance   = 0.01;     //Grid distance
input int      shares         = 50;       //Divide the money
input double   allTp          = 0.02;     //Equity reaches this value close all positions
input int      symbolStep     = 1;        //Transaction quantity decimal limit (0: Use Symbol's setting)

struct gridInfo
  {
   double            price;
   bool              holdSell, holdBuy;        //Is there hold position
   ulong  ticketSell, ticketBuy;    //Close position is ticket (nor open position is ticket)
  };
gridInfo grid[];
int      current;                   //Now grid
double   openMoney;
int      buyPosition, sellPosition; //Buy or sell hold position amount
double   nowPrice;
double   fee = 0.0008;              //Transaction fees
double   totalFee;
double   initBlance;
enum     tradeType {buy, sell};
double   openMoneyDistance;         //Open money increase ratio
int      step_int;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(MAGIC);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());

   symbolInfo.Refresh();
//Calculate the minimum number of positions to open
   if(symbolStep == 0)
     {
      double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
      for(double v = step; v<1; step_int++)
         v = v * 10;
     }
   else
      step_int = symbolStep;
   MqlRates rt[];
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rt);
   nowPrice = rt[0].close;
   
//Set the grid and open a position
   FirstTrade();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   symbolInfo.RefreshRates();
   nowPrice = symbolInfo.Last();
   if(nowPrice == 0)
      return;

//Price rise
   if(nowPrice >= grid[current+1].price)
      current++;
//Price drop
   else
      if(nowPrice <= grid[current-1].price)
         current--;
      //Grid doesn't change
      else
         return;

//Determine whether the equity reaches take profit
   if(accountInfo.Equity()-totalFee > initBlance * (1+allTp))
      CloseAllGrid();

//Close position
   if(grid[current].ticketBuy != 0)
     {
      trade.PositionClose(grid[current].ticketBuy);
      buyPosition--;
      grid[current].ticketBuy = 0;
      grid[current-2].holdBuy = false;
     }
   if(grid[current].ticketSell != 0)
     {
      trade.PositionClose(grid[current].ticketSell);
      sellPosition--;
      grid[current].ticketSell = 0;
      grid[current+2].holdSell = false;
     }
//Open postion
   if(grid[current].holdBuy && !grid[current].holdSell)
      OpenSell();
   else
      if(!grid[current].holdBuy && grid[current].holdSell)
         OpenBuy();
   if(!grid[current].holdBuy && !grid[current].holdSell)
     {
      if(buyPosition > sellPosition)
         OpenSell();
      else
         OpenBuy();
     }
  }
//+----------------------- Calc trade volume ------------------------+
double CalcVolume(tradeType type)
  {
//Open money increment
   double firstMoney = openMoney / 10; //First open money
   double money = 0;                   //This time open money
   if(type == buy)
      money = firstMoney + (double)buyPosition * openMoneyDistance;
   else
      if(type == sell)
         money = firstMoney + (double)sellPosition * openMoneyDistance;
   double volume = NormalizeDouble(money / symbolInfo.ContractSize() / nowPrice, step_int);
   if(volume <= 0)
      volume = symbolInfo.LotsMin();
   if(accountInfo.FreeMarginCheck(Symbol(),ORDER_TYPE_BUY,volume,nowPrice)<0.0)
      return 0;
   totalFee = totalFee + nowPrice * volume * fee;
   Comment("Total Fee = ", NormalizeDouble(totalFee,2), "; Grid = ", buyPosition+sellPosition, " / ", shares, " (", buyPosition, ", ", sellPosition, ")");
   return volume;
  }
//+--------------------- Open long position -------------------------+
void OpenBuy()
  {
   if(buyPosition+sellPosition>=shares)
      return;
   trade.Buy(CalcVolume(buy));
   grid[current].holdBuy = true;
   grid[current+2].ticketBuy = trade.ResultOrder();
   buyPosition++;
  }
//+--------------------- Open short position ------------------------+
void OpenSell()
  {
   if(buyPosition+sellPosition>=shares)
      return;
   trade.Sell(CalcVolume(sell));
   grid[current].holdSell = true;
   grid[current-2].ticketSell = trade.ResultOrder();
   sellPosition++;
  }
//+-------------- Set the grid and open a position ------------------+
void FirstTrade()
  {
//Set the grid
   ArrayResize(grid, shares*4);
   current = shares+shares;
   grid[current].price = nowPrice;
   grid[current].holdBuy = false;
   grid[current].holdSell = false;
   grid[current].ticketBuy = 0;
   grid[current].ticketSell = 0;
   for(int i=current+1, all=shares*4; i<all; i++)
     {
      grid[i].price = grid[i-1].price * (1 + gridDistance);
      grid[i].holdBuy = false;
      grid[i].holdSell = false;
      grid[i].ticketBuy = 0;
      grid[i].ticketSell = 0;
     }
   for(int i=current-1; i>-1; i--)
     {
      grid[i].price = grid[i+1].price * (1 - gridDistance);
      grid[i].holdBuy = false;
      grid[i].holdSell = false;
      grid[i].ticketBuy = 0;
      grid[i].ticketSell = 0;
     }
//Calc open money
   openMoney = accountInfo.Balance() / (double)shares;
   initBlance = accountInfo.Balance();
//Increment
   openMoneyDistance = (initBlance / 2 - shares / 2 / 10) / ((1 + shares/2-1) * (shares/2-1) / 2);    //10指的是首次开仓资金为平均的十分之一，如100块分100份，平均每份1，然后再除以10
//Open one long position
   trade.Buy(CalcVolume(buy));
   grid[current].holdBuy = true;
   grid[current+2].ticketBuy = trade.ResultOrder();
   buyPosition=1;
   sellPosition=0;
  }
//+---------------------- close all position ------------------------+
void CloseAllGrid()
  {
   int total = PositionsTotal();
   for(int i=0; i<total; i++)
      trade.PositionClose(_Symbol);
   FirstTrade();
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }