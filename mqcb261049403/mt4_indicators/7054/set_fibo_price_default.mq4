//+------------------------------------------------------------------+
//|                                       Set_Fibo_Price_Default.mq4 |
//|                              Copyright © 2006, Eng. Waddah Attar |
//|                                          waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright Waddah Attar"
#property link      "waddahattar@hotmail.com"
//----
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Comment("Set_Fibo_Default");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   int    obj_total = ObjectsTotal();
   string name;
   for(int i = 0; i < obj_total; i++)
     {
       name = ObjectName(i);
       if(ObjectType(name) == OBJ_FIBO)
         {
           ObjectSetFiboDescription(name,0, "0.0");
           ObjectSetFiboDescription(name,1, "23.6");
           ObjectSetFiboDescription(name,2, "38.2");
           ObjectSetFiboDescription(name,3, "50");
           ObjectSetFiboDescription(name,4, "61.8");
           ObjectSetFiboDescription(name,5, "100");
           ObjectSetFiboDescription(name,6, "161.8");
           ObjectSetFiboDescription(name,7, "261.8");
           ObjectSetFiboDescription(name,8, "423.6");
         }
     }
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    obj_total = ObjectsTotal();
   string name;
   for(int i = 0; i < obj_total; i++)
     {
       name = ObjectName(i);
       if(ObjectType(name) == OBJ_FIBO)
         {
           ObjectSetFiboDescription(name, 0, "(0.0) - %$");
           ObjectSetFiboDescription(name, 1, "(23.6) - %$");
           ObjectSetFiboDescription(name, 2, "(38.2) - %$");
           ObjectSetFiboDescription(name, 3, "(50) - %$");
           ObjectSetFiboDescription(name, 4, "(61.8) - %$");
           ObjectSetFiboDescription(name, 5, "(100) - %$");
           ObjectSetFiboDescription(name, 6, "(161.8) - %$");
           ObjectSetFiboDescription(name, 7, "(261.8) - %$");
           ObjectSetFiboDescription(name, 8, "(423.6) - %$");
         }
     }
//----   
   return(0);
  }
//+------------------------------------------------------------------+


