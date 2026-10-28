//+------------------------------------------------------------------+
//|                                       s_WaveMarker_DeleteAll.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "for-good-letters@yandex.ru"
#property show_inputs
extern int Index = 0;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       if(StringFind(ObjectName(i), "WM(" + Index, 0) == 0)
         {
           ObjectDelete(ObjectName(i));
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+