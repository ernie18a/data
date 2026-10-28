//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021"
#property link "drdz9876@gmail.com"
#property version   "2.1"
#include <Trade\Trade.mqh> CTrade trade;                      // trading object

enum LossMode
  {
   ENUM_PERCENTLOSS,          //Close Loss in Percentage
   ENUM_CURRENCYLOSS          //Close Loss in Money
  };
enum ProfitMode
  {
   ENUM_PERCENTPROFIT,     //Close Profit in Percentage
   ENUM_CURRENCYPROFIT     //Close Profit in Money
  };

input LossMode          LMode       = ENUM_PERCENTLOSS;     //Select the Loss Closing Type
input double            LPercentage  = 1.0;              // Close All Positions if reach Target Percentage
input double            LMoneySum    = 100;              // Close All Positions if reach Target Money
input ProfitMode        PMode       = ENUM_PERCENTPROFIT;     //Select the Profit Closing Type
input double            PPercentage  = 1.0;              // Close All Positions if reach Target Percentage
input double            PMoneySum    = 100;              // Close All Positions if reach Target Money
input bool              OrderTest   = false;            //Enable Tester Order (in Backtest Only)
input int               Slippage    = 10;            //Slippage
//+----------------------------------------------+
bool Stop, Profit;
double Percentage;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   createBackground();
   createObject("Profit","Money P/L is: $"+DoubleToString(CalculateTotalProfit(),2));
   createObject2("Percent","Percentage P/L is: "+DoubleToString(Percentage,2)+"%");
//----
   Stop=false;
   Profit = false;
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"Background");
   ObjectDelete(0,"Profit");
   ObjectDelete(0,"Percent");
   return;
//----
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {

   Percentage = (CalculateTotalProfit()*100)/AccountInfoDouble(ACCOUNT_BALANCE);

//----
   if(CalculateTotalProfit() != 0)
      ObjectSetString(0,"Profit",OBJPROP_TEXT,"Money P/L is: $"+DoubleToString(CalculateTotalProfit(),2));

   if(Percentage != 0)
      ObjectSetString(0,"Percent",OBJPROP_TEXT,"Percentage P/L is: "+DoubleToString(Percentage,2)+"%");
//----

   if(!Stop)
     {
      switch(LMode)
        {
         case ENUM_PERCENTLOSS :
           {
            if(Percentage <= (-LPercentage))
               Stop=true;
            break;
           }
         case ENUM_CURRENCYLOSS :
           {
            if(CalculateTotalProfit() <= -LMoneySum)
               Stop=true;
            break;
           }
        }
     }
   if(!Profit)
     {
      switch(PMode)
        {
         case ENUM_CURRENCYPROFIT :
           {
            if(CalculateTotalProfit() >= PMoneySum)
               Profit=true;
            break;
           }
         case ENUM_PERCENTPROFIT :
           {
            if(Percentage >= PPercentage)
               Profit=true;
            break;
           }
        }
     }
   if(Stop)
     {
      ClosePositions();
      Print("Positions Closed At Loss");
      if(!IsPositionExists())
         Stop = false;
     }
   if(Profit)
     {
      ClosePositions();
      Print("Positions Closed At Profit");
      if(!IsPositionExists())
         Profit = false;
     }
   if(OrderTest)
     {
      if(MQLInfoInteger(MQL_TESTER) && !IsPositionExists())
        {
         trade.Sell(0.1,Symbol(),Bid(),0,0,NULL);
         trade.Buy(0.1,Symbol(),Ask(),0,0,NULL);
        }
     }

   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IsPositionExists()
  {
   int count = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetTicket(i))
         if(PositionGetString(POSITION_SYMBOL)==Symbol())
           {
            count++;
           }
//---
   return(count);
  }

//+------------------------------------------------------------------+
//| Get current bid value                                            |
//+------------------------------------------------------------------+
double Bid()
  {
   return (SymbolInfoDouble(Symbol(), SYMBOL_BID));
  }

//+------------------------------------------------------------------+
//| Get current ask value                                            |
//+------------------------------------------------------------------+
double Ask()
  {
   return (SymbolInfoDouble(Symbol(), SYMBOL_ASK));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int digits()
  {
   return ((int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePositions()
  {
   int total=PositionsTotal();
   for(int k=total-1; k>=0; k--)
      if(PositionGetTicket(k))
         if(PositionGetInteger(POSITION_TYPE)== POSITION_TYPE_BUY || PositionGetInteger(POSITION_TYPE)== POSITION_TYPE_SELL)
           {
            // position with appropriate ORDER_MAGIC, symbol and order type
            trade.PositionClose(PositionGetInteger(POSITION_TICKET), Slippage);
           }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTotalProfit()
  {
   double val = 0;
   double profit = 0, swap = 0, comm = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i))
        {
         profit = PositionGetDouble(POSITION_PROFIT);
         swap = PositionGetDouble(POSITION_SWAP);
         comm = AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
         val += profit + swap + comm;
        }
     }

   return (NormalizeDouble(val,2));
  }
//+------------------------------------------------------------------+
bool createObject(string name,string text)
  {
   ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0,name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE, 30);
   ObjectSetInteger(0,name, OBJPROP_YDISTANCE, 40);
   ObjectSetString(0,name,OBJPROP_TEXT, text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,14);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createObject2(string name,string text)
  {
   ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0,name, OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE, 30);
   ObjectSetInteger(0,name, OBJPROP_YDISTANCE, 80);
   ObjectSetString(0,name,OBJPROP_TEXT, text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,14);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrDarkBlue);

   return (true);
  }
//+------------------------------------------------------------------+
bool createBackground()
  {
   ObjectCreate(0, "Background", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0,"Background", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "Background", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "Background", OBJPROP_YDISTANCE, 100);
   ObjectSetInteger(0, "Background", OBJPROP_XSIZE, 240);
   ObjectSetInteger(0, "Background", OBJPROP_YSIZE, 100);
   ObjectSetInteger(0, "Background", OBJPROP_BGCOLOR, clrWhite);
   ObjectSetInteger(0, "Background", OBJPROP_BORDER_COLOR, clrGreenYellow);
   ObjectSetInteger(0, "Background", OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, "Background", OBJPROP_WIDTH, 0);
   ObjectSetInteger(0, "Background", OBJPROP_BACK, false);
   ObjectSetInteger(0, "Background", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Background", OBJPROP_HIDDEN, true);
   return (true);
  }
//+------------------------------------------------------------------+
