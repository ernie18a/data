//+------------------------------------------------------------------+
//|                                        ZZ_DeleteFonts 0-0010.mq4 |
//|                                        Copyright © Zhunko        |
//|22.11.2007                              zhunko@mail.ru            |
//+------------------------------------------------------------------+
#property copyright "Copyright © Zhunko"
#property link      "zhunko@mail.ru"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
 {
  for (int i = 0; i <= 455; i++)
   {
    ObjectDelete ("LABEL Arrow " + i);
    ObjectDelete ("LABEL Arrow №" + i);
   }
  return(0);
 }
//+------------------------------------------------------------------+