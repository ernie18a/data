//+------------------------------------------------------------------+
//|                                                     Snapshot.mq4 |
//|                                         Copyright © 2011, bdeyes |
//|                                              bdeyes357@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, bdeyes"
#property link      "bdeyes357@yahoo.com"

// Script will take "snapshot" of chart and put it in a .gif file named 
// "Snapshot" by symbol, chart timeframe, and time (hhmmss)the picture was taken.

// By default MetaTrader puts files in C:\Program Files\MetaTrader4\experts\files

// Set _width and _height variables to match your screen resolution settings.

// To make it easier to find the most recent snapshots the times in the file name have 
// been set to local machine time. If you prefer broker time change "TimeLocal()" to
// "TimeCurrent()".

/**************** END OF CONFIGURATION *********/


//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+                                                                                                                                               // PadString(DoubleToStr(TimeMonth(date),0),"0",2
int start()
{
   int   _width     = 2560;// set to match your screen resolution numbers
   int   _height    = 1600;// set to match your screen resolution numbers
   string SCREENSHOT_FILENAME = StringConcatenate("Snapshot ", Symbol(), " MIN ", Period(), " ", TimeYear(TimeLocal()), "-", TimeMonth(TimeLocal()), "-", TimeDay(TimeLocal()), "  ", PadString(DoubleToStr(TimeHour(TimeLocal()),0),"0",2), PadString(DoubleToStr(TimeMinute(TimeLocal()),0),"0",2), PadString(DoubleToStr(TimeSeconds(TimeLocal()),0),"0",2), ".gif" );
   
  if (true)
  WindowScreenShot(SCREENSHOT_FILENAME, _width, _height);    
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