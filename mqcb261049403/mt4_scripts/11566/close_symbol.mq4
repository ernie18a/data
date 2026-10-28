//+------------------------------------------------------------------+
//|                                                     close tk.mq4 |
//|                                                               tk |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "tk"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {string cs = ChartSymbol();
  long chid=ChartFirst();long pom;
//---
  //ChartAc
  for(int i=0;i<20;i++)
    {pom=ChartNext(chid);if(ChartSymbol(chid)==cs)ChartClose(chid);if(pom==-1)break;chid=pom;}
    
  }
//+------------------------------------------------------------------+
