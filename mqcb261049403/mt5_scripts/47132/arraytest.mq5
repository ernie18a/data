//+------------------------------------------------------------------+
//|                                                    Array_MT5.mq5 |
//|                                            copyright © 2023 Enev |
//|                              https://www.mql5.com/en/users/esebg |
//+------------------------------------------------------------------+
#property copyright "E.Enev"
#property strict
#property version   "1.00"
#property description "Two dimension Array fill and Print"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   string array_test[][2] = {"0.001", "0.002",
                             "0.003", "0.004",
                             "0.005", "0.006",
                             "0.007", "0.008",
                             "0.009", "0.010"
                            };
   int sizein = ArraySize(array_test) / 2;
   for(int i = 0; i < sizein; i++)
     {
      Print("Print line1 element1 ", StringToDouble(array_test[i][0]));
      Print("Print line1 element2 ", StringToDouble(array_test[i][1]));
     }
  }
//+------------------------------------------------------------------+
