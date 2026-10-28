//+------------------------------------------------------------------+
//|                                            Test_values_print.mqh |
//|                                                      Dina Paches |
//|                             https://www.mql5.com/ru/users/dipach |
//+------------------------------------------------------------------+
//|Для вывода на печать значений. Например: при создании кодов,      |
//|результатов работы функций                                        |
//+------------------------------------------------------------------+
#property copyright "Dina Paches"
#property link      "https://www.mql5.com/ru/users/dipach"
//+------------------------------------------------------------------+
#define TEST_PRINT_1_V(v1)               Print(__LINE__,", ",__FUNCTION__,", ",(#v1)," = ",(v1))
#define TEST_PRINT_2_V(v1,v2)            Print(__LINE__,", ",__FUNCTION__,", ",(#v1)," = ",(v1),\
                                               ", ",(#v2)," = ",(v2))
#define TEST_PRINT_3_V(v1,v2,v3)         Print(__LINE__,", ",__FUNCTION__,", ",(#v1)," = ",(v1),\
                                               ", ",(#v2)," = ",(v2),", ",(#v3)," = ",(v3))
//---
#define DTS_DIGITS(vd1)                  DoubleToString(vd1,Digits())
#define ITS(vi1)                         IntegerToString(vi1)                   
//+------------------------------------------------------------------+