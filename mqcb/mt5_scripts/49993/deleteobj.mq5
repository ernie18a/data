//+------------------------------------------------------------------+
//|                                                    DeleteObj.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
      ObjectsDeleteAll(ChartID());
  }
//+------------------------------------------------------------------+
