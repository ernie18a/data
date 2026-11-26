//+------------------------------------------------------------------+
//|                                                 GlobalsFlush.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   // enforce writing global variables to disk if they are not yet
   // saved in their current state
   GlobalVariablesFlush();
}
//+------------------------------------------------------------------+
