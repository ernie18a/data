//+------------------------------------------------------------------+
//|                                       Parabolic_TrailingStop.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Trade\OrderInfo.mqh>
//--- object for conducting trading operations
CTrade  trade;
COrderInfo myorder;
//input parameters
input ENUM_TIMEFRAMES base_tf;  //set timeframe
input double sar_step=0.1;      //set parabolic step
input double maximum_step=0.11; //set parabolic maximum step
int Sar_base;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//get the handle of the iSar indicator
   Sar_base=iSAR(Symbol(),base_tf,sar_step,maximum_step);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- search for iSar
   double Sar_array_base[];//--- declaration of array for writing the values of the buffers of the indicator iSar
   CopyBuffer(Sar_base,0,TimeCurrent(),Bars(Symbol(),base_tf),Sar_array_base);// --- filling with the data of the buffer
   ArraySetAsSeries(Sar_array_base,true);// --- indexing as in timeseries
//---
//---search for high and low
   double High_base[],Low_base[];
   ArraySetAsSeries(High_base,true);
   ArraySetAsSeries(Low_base,true);
   CopyHigh(Symbol(),base_tf,0,10,High_base);
   CopyLow(Symbol(),base_tf,0,10,Low_base);
//---
//--- searcg for time of iSar
   datetime Sar_time_base[];
   ArraySetAsSeries(Sar_time_base,true);
   CopyTime(Symbol(),base_tf,0,10,Sar_time_base);
//---
//--- order modification
   double OP_double,TP_double;
   int P_type,P_opentime;
   string P_symbol;
   if(PositionsTotal()>0)
     {
      for(int i=PositionsTotal();i>=0;i--)
        {
         if(PositionGetTicket(i))
           {
            OP_double=double (PositionGetDouble(POSITION_PRICE_OPEN));
            TP_double=double (PositionGetDouble(POSITION_TP));
            P_type=int(PositionGetInteger(POSITION_TYPE));
            P_opentime=int(PositionGetInteger(POSITION_TIME));
            P_symbol=string(PositionGetString(POSITION_SYMBOL));
            if(P_symbol==Symbol())
              {
               if(P_type==0 && Sar_array_base[1]>OP_double && Sar_array_base[1]<Low_base[1] && Sar_time_base[1]>P_opentime)
                 {
                  trade.PositionModify(PositionGetInteger(POSITION_TICKET),Sar_array_base[1],TP_double);
                 }
               if(P_type==1 && Sar_array_base[1]<OP_double && Sar_array_base[1]>High_base[1] && Sar_time_base[1]>P_opentime)
                 {
                  trade.PositionModify(PositionGetInteger(POSITION_TICKET),Sar_array_base[1],TP_double);
                 }
              }
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
