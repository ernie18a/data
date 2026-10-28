//+------------------------------------------------------------------+
//|                                                   Buy Market.mq4 |
//|                                         Copyright © 2011, bdeyes |
//|                                              bdeyes357@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, bdeyes"
#property link      "bdeyes357@yahoo.com"

// When dropped on chart this script will place a buy order at market.

// If "TakePicture" is set to true script will take "snapshot" of chart and put it in a
// .gif file named "Buy" by symbol, chart timeframe, and time (hhmmss)the picture was taken.

// By default MetaTrader puts files in C:\Program Files\MetaTrader4\experts\files

// Set _width and _height variables to match your screen resolution settings.

// To make it easier to match snapshots to trades the times in the file name have 
// been set to broker time. If you prefer local machine time change "TimeCurrent()" to
// "TimeLocal()".

#include <stdlib.mqh>
#include <WinUser32.mqh>


extern double Lots=5.0; /* Strictly set amount of lots.*/
extern double StopLoss=25;  /* SL for an opened order.*/
extern double TakeProfit=15;  /* TP for an opened order.*/
extern int slippage=3;      // Slippage
extern bool UsePrint= true;   /* Set true to log trades.*/
extern bool TakePicture = true; /* set true to take snapshot of trade */
double PipValue=1;    // this variable is here to support 5-digit brokers
/**************** END OF CONFIGURATION *********/

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
    if (Digits == 3 || Digits == 5) PipValue = 10;
    double SL = Ask - StopLoss*PipValue*Point;
    if (StopLoss == 0) SL = 0;
    double TP = Ask + TakeProfit*PipValue*Point;
    if (TakeProfit == 0) TP = 0;
    int ticket = -1;
    int   _width     = 2560;// set to match your screen resolution numbers
    int   _height    = 1600;// set to match your screen resolution numbers
    string SCREENSHOT_FILENAME = StringConcatenate("Buy ", Symbol(), " MIN ", Period(), " ", TimeYear(TimeLocal()), "-", TimeMonth(TimeLocal()), "-", TimeDay(TimeLocal()), "  ", PadString(DoubleToStr(TimeHour(TimeLocal()),0),"0",2), PadString(DoubleToStr(TimeMinute(TimeLocal()),0),"0",2), PadString(DoubleToStr(TimeSeconds(TimeLocal()),0),"0",2), ".gif" );
   
    if (true)
    ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, slippage, 0, 0, "Buy Market script", 0, Blue);
    else
    ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, slippage, SL, TP, "Buy Market script", 0, Blue);
    if (ticket > -1)
			{
        if (true)
					{
						OrderSelect(ticket, SELECT_BY_TICKET);
						bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0, Blue);
						if (ret == true && UsePrint) OrderPrint();
						if (ret == true && TakePicture) WindowScreenShot(SCREENSHOT_FILENAME, _width, _height);  
						if (ret == false)
						Print("OrderModify() error - ", ErrorDescription(GetLastError()));
					}
          //Alert3();  
			}
    else
			{
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
			}
}
//+------------------------------------------------------------------+

string PadString(string toBePadded, string paddingChar, int paddingLength)
{
   while(StringLen(toBePadded) <  paddingLength)
   {
      toBePadded = StringConcatenate(paddingChar,toBePadded);
   }
   return (toBePadded);
}

//+------------------------------------------------------------------+
 