//+------------------------------------------------------------------+
//|                                                     StmtNull.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   int i = 0;
   ushort c;
   string s = "Hello, " + Symbol();

   while((c = s[i++]) != ' ' && c != 0); // intentional ';' (!)

   if(c == ' ')
   {
      Print("Space found at: ", i);
   }
}
//+------------------------------------------------------------------+
