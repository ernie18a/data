//+------------------------------------------------------------------+
//|                                                   Graph_test.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "2.000"
#property description "Display interactive HTML graph of the account balance inside the web browser."
#property script_show_inputs

#include "Graph_HTML.mqh"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   CreateHighChartsBalanceReport("Graph.htm");
  }
//+------------------------------------------------------------------+
