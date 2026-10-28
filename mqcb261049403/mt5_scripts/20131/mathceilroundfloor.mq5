//+------------------------------------------------------------------+
//|                                           MathCeilRoundFloor.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property description "MathCeil: Возвращает ближайшее сверху целое числовое значение"
#property description "MathRound: Округляет число до ближайшего целого"
#property description "MathFloor: Возвращает ближайшее снизу целое числовое значение"
#property description "MathCeil: Returns integer numeric value closest from above"
#property description "MathRound: Rounds of a value to the nearest integer"
#property description "MathFloor: Returns integer numeric value closest from below"
#property version   "1.003"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   double price=1.01561;
   Print("\n","Start price: ",DoubleToString(price,5));
   for(int i=0;i<10;i++)
     {
      Print("MathCeil(",DoubleToString(price,5),") ->  ",MathCeil(price));
      Print("MathRound(",DoubleToString(price,5),") ->  ",MathRound(price));
      Print("MathFloor(",DoubleToString(price,5),") ->  ",MathFloor(price));
      Print("");
      price+=1.9;
     }
  }
//+------------------------------------------------------------------+
