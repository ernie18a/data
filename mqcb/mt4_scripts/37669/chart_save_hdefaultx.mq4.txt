//+------------------------------------------------------------------+
//|                                          CHART SAVE(default).mq4 |
//|                                 Copyright © 2021, payman zamani. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, payman zamani."
#property link      "https://www.forexfactory.com/paymanz"
#property strict
//#property show_confirm

//+------------------------------------------------------------------+
//| script "saves the current chart to default template"     |
//+------------------------------------------------------------------+
int start()
  {
  ChartSaveTemplate(0,"default.tpl");
   
     return(0);
  }
//+------------------------------------------------------------------+
