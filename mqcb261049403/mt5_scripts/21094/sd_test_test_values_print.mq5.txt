//+------------------------------------------------------------------+
//|                                    SD_Test_Test_values_print.mq5 |
//|                                                      Dina Paches |
//|                             https://www.mql5.com/ru/users/dipach |
//+------------------------------------------------------------------+
//|Тестовый скрипт.                                                  |
//|При установке на график показывает координаты, соответствующие    |
//|точке, в которой брошен мышкой данный скрипт: номер подокна       |
//|графика, x, y, time, price                                        |
//+------------------------------------------------------------------+
#property copyright "Dina Paches"
#property link      "https://www.mql5.com/ru/users/dipach"
#property version   "1.00"
//---
#include <Test_values_print.mqh>
//+------------------------------------------------------------------+
void OnStart()
  {
   int x = ChartXOnDropped();
   int y = ChartYOnDropped();
   //---
   TEST_PRINT_2_V(x,y);
   //---
   datetime time       = 0;
   double   price      = 0.0;
   int      sub_window = -1;
  //---
   bool res = ChartXYToTimePrice(0,x,y,sub_window,time,price);
//---
   TEST_PRINT_1_V(res);
//---
   if(res){TEST_PRINT_3_V(sub_window,time,DTS_DIGITS(price));}
//---
  }
//+------------------------------------------------------------------+