//+------------------------------------------------------------------+
//|                                                 Close Orders.mq4 |
//|                                         Copyright © 2011, bdeyes |
//|                                              bdeyes357@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, bdeyes"
#property link      "bdeyes357@yahoo.com"

// When dropped on chart this script will close all open orders.

// If "TakePicture" is set to true script will take "snapshot" of chart and put it in a
// .gif file named "Close" by symbol, chart timeframe, and time (hhmmss)the picture was taken.

// By default MetaTrader puts files in C:\Program Files\MetaTrader4\experts\files

// Set _width and _height variables to match your screen resolution settings.

// To make it easier to match snapshots to trades the times in the file name have 
// been set to broker time. If you prefer local machine time change "TimeCurrent()" to
// "TimeLocal()".

#include <stdlib.mqh>
#include <WinUser32.mqh>

//--- exported variables
extern bool TakePicture = true; /* set true to take snapshot of trade */

//--- local variables
double PipValue=1;// this variable is here to support 5-digit brokers
int   _width;// in ScreenPicture function set to match your screen resolution numbers
int   _height;// in ScreenPicture function set to match your screen resolution numbers
string SCREENSHOT_FILENAME;
/**************** END OF CONFIGURATION *********/
   

//+------------------------------------------------------------------+
//| script program init function                                     |
//+------------------------------------------------------------------+
int init()
{
    if (Digits==3 || Digits==5)//to adjust for 5-digit broker
      PipValue = Point*10;
    else
      PipValue = Point;     
}

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
{    
    CloseSellOrder();
    CloseBuyOrder();
    if (TakePicture) ScreenPicture();    
}

//+------------------------------------------------------------------+
//| script CloseSellOrder function                                   |
//+------------------------------------------------------------------+
void CloseSellOrder()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[30][2];
    for (int i = 0; i < orderstotal; i++)
    {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_SELL || OrderSymbol() != Symbol() || OrderMagicNumber() != 0)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Red);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

//+------------------------------------------------------------------+
//| script CloseBuyOrder function                                    |
//+------------------------------------------------------------------+
void CloseBuyOrder()
{
    int orderstotal = OrdersTotal();
    int orders = 0;
    int ordticket[30][2];
    for (int i = 0; i < orderstotal; i++)
    {
        OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
        if (OrderType() != OP_BUY || OrderSymbol() != Symbol() || OrderMagicNumber() != 0)
        {
            continue;
        }
        ordticket[orders][0] = OrderOpenTime();
        ordticket[orders][1] = OrderTicket();
        orders++;
    }
    if (orders > 1)
    {
        ArrayResize(ordticket,orders);
        ArraySort(ordticket);
    }
    for (i = 0; i < orders; i++)
    {
        if (OrderSelect(ordticket[i][1], SELECT_BY_TICKET) == true)
        {
            bool ret = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 4, Blue);
            if (ret == false)
            Print("OrderClose() error - ", ErrorDescription(GetLastError()));
        }
    }
    
}

//+------------------------------------------------------------------+
//| script ScreenPicture function                                    |
//+------------------------------------------------------------------+
void ScreenPicture()
{
   int   _width     = 2560;// set to match your screen resolution numbers
   int   _height    = 1600;// set to match your screen resolution numbers
   //---- wait for 2 seconds
   Sleep(2000);
   string SCREENSHOT_FILENAME = StringConcatenate("Close ", Symbol(), " MIN ", Period(), " ", TimeYear(TimeLocal()), "-", TimeMonth(TimeLocal()), "-", TimeDay(TimeLocal()), "  ", PadString(DoubleToStr(TimeHour(TimeLocal()),0),"0",2), PadString(DoubleToStr(TimeMinute(TimeLocal()),0),"0",2), PadString(DoubleToStr(TimeSeconds(TimeLocal()),0),"0",2), ".gif" );
   
   if (true)
   WindowScreenShot(SCREENSHOT_FILENAME, _width, _height); 
} 

//+------------------------------------------------------------------+
//| script PadString function                                        |
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
//| script END                                                       |
//+------------------------------------------------------------------+  