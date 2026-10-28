//+------------------------------------------------------------------+  
//|                                                 ToClearChart.mq5 | 
//|                           Copyright © 2011,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
#property script_show_confirm
//+------------------------------------------------------------------+ 
//| start function                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
   ObjectsDeleteAll(0,-1,-1);
  }
//+------------------------------------------------------------------+
