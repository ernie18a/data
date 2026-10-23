//+------------------------------------------------------------------+
//|                                          Chart save template.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.00"
#property script_show_inputs
//--- input parameter
input string InpNameTemplate="tester"; // Name template
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   ResetLastError();
//--- save the current chart in a template
   if(!ChartSaveTemplate(0,InpNameTemplate))
      MessageBox("Error SaveTemplate #"+IntegerToString(GetLastError()));
   else
      MessageBox("Template \""+InpNameTemplate+".tpl\" overwritten!");
  }
//+------------------------------------------------------------------+
