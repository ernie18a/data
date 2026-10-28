//+------------------------------------------------------------------+
//|                                               e_CheckSampler.mq5 |
//|                                        Copyright 2012, her.human |
//|                                              her.human@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, her.human"
#property link      "her.human@gmail.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

input double lot=1.0;

int signal[];
CTrade trade;
MqlTick tick;
datetime time[],prevtime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ResetLastError();
   string namefile;
   StringConcatenate(namefile,_Symbol,"_Sampler.BIN");
   int filehandle=FileOpen(namefile,FILE_READ|FILE_BIN|FILE_COMMON);
   if(filehandle!=INVALID_HANDLE)
     {
      FileReadArray(filehandle,signal,0,WHOLE_ARRAY);
      FileClose(filehandle);
      Print(namefile," FileOpen OK");
     }
   else Print(namefile,"  FileOpen failed, error ",GetLastError());
   ArraySort(signal);
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   CopyTime(_Symbol,_Period,0,1,time);

   if(time[0]==prevtime) return;
   prevtime=time[0];

   int sig=0,index;
   index=ArrayBsearch(signal,time[0]);
   if(signal[index]==time[0]) sig=1;
   index=ArrayBsearch(signal,-time[0]);
   if(signal[index]==-time[0]) sig=-1;

   SymbolInfoTick(_Symbol,tick);
   if(sig==1)
     {
      if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         trade.PositionClose(_Symbol);
      trade.Buy(lot,NULL,tick.ask);
     }
   if(sig==-1)
     {
      if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         trade.PositionClose(_Symbol);
      trade.Sell(lot,NULL,tick.bid);
     }
//   if(MathAbs(sig)==0) trade.PositionClose(_Symbol);
  }
//+------------------------------------------------------------------+
