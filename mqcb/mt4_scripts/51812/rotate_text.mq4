//+------------------------------------------------------------------+
//|                                                  rotate_text.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
#property strict

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   int    index=0;
   double price;
   int    k=1;
//----
   price=Low[index];
   ObjectCreate("rotating_text", OBJ_TEXT, 0, Time[index], price);
   ObjectSetText("rotating_text", "Up...", 20);
   ObjectSet("rotating_text", OBJPROP_TIME1, Time[index]);
   ObjectSet("rotating_text", OBJPROP_PRICE1, price);
   ObjectSetInteger(0, "rotating_text", OBJPROP_COLOR, clrGreen);
   
   while(true)
     {
      index += k;
      
      // Zabezpieczenie przed wyjściem poza zakres dostępnych danych
      if(index < 0) index = 0;
      if(index >= Bars) index = Bars - 1;

      ObjectMove("rotating_text", 0, Time[index], price + index * 0.0001);
      ChartRedraw(0);
      
      if(index > 20)
       {
        k = -1;
        ObjectSetText("rotating_text", "...and Down", 20);
        ObjectSetInteger(0, "rotating_text", OBJPROP_COLOR, clrIndianRed);
       }
      
      if(index == 0)
       {
        k = 1;
        ObjectSetText("rotating_text", "Up...", 20);
        ObjectSetInteger(0, "rotating_text", OBJPROP_COLOR, clrGold);
       }  
      
      Sleep(100);
     }
   
   return(0);
  }
//+------------------------------------------------------------------+
