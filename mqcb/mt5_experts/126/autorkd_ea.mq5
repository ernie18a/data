//+------------------------------------------------------------------+
//|                                                    autoKD_EA.mq5 |
//|                          Copyright 2010,bigsea QQ:806935610      |
//|                          http://waihuiea.5d6d.com                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010,Bigsea QQ:806935610"
#property link      "http://waihuiea.5d6d.com"
#property version   "1.00"
#property description "An Example of a Trading System Based on a custom Indicator RKD"
//--- input parameters
input double Lots=0.1;
input int SL=31;       // Stop Loss
input int TP=50;       // Take Profit
input int MAGIC=666;   // MAGIC number
input int       KDPeriod=30;
input int       M1=3;
input int       M2=6;
MqlTradeRequest trReq;
MqlTradeResult trRez;
int handle1;
double RSVBuffer[];
double KBuffer[];
double DBuffer[];
int sl;
int tp;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ZeroMemory(trReq);
   ZeroMemory(trRez);
//--- set default vaules for all new order requests
   trReq.action=TRADE_ACTION_DEAL;
   trReq.magic=MAGIC;
   trReq.symbol=Symbol();                 // Trade symbol
   trReq.volume=Lots;                     // Requested volume for a deal in lots
   trReq.deviation=1;                     // Maximal possible deviation from the requested price
   trReq.type_filling=ORDER_FILLING_FOK;  // Order execution type
   trReq.type_time=ORDER_TIME_GTC;        // Order execution time
   trReq.comment="RKD_EA ";

//--- create handle for a specified custom indicator
   handle1=iCustom(_Symbol,_Period,"RKD",KDPeriod,M1,M2);
   if(handle1==INVALID_HANDLE)
     {
      Print("Error in RKD indicator!");
      return(1);
     }

//--- input parameters are ReadOnly
   tp=TP;
   sl=SL;
   if(_Digits==5 || _Digits==3)
     {
      tp=TP*10;
      sl=SL*10;
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- release our indicator handles
   IndicatorRelease(handle1);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlTick tick; //variable for tick info
   if(!SymbolInfoTick(Symbol(),tick))
     {
      Print("Failed to get Symbol info!");
      return;
     }
//--- K and D values arrays
   ArraySetAsSeries(KBuffer,true);
   ArraySetAsSeries(DBuffer,true);
//--- copy the new values of our indicators to buffers (arrays) using the handle
   if(CopyBuffer(handle1,1,0,3,KBuffer)<0 || CopyBuffer(handle1,2,0,3,DBuffer)<0
      || CopyBuffer(handle1,0,0,3,RSVBuffer)<0)
     {
      Alert("Error copying RKD indicator Buffers - error:",GetLastError(),"!!");
      return;
     }
//--- position check for   
   bool openLong=0,openShort=0,closeLong=0,closeShort=0;
   if(PositionSelect(_Symbol))
     {
      //--- positions already selected before
      long type=PositionGetInteger(POSITION_TYPE);
      if(type==(long)POSITION_TYPE_BUY)
         if(KBuffer[1]<DBuffer[1] && KBuffer[2]>DBuffer[2])
            closeLong=true;
      if(type==(long)POSITION_TYPE_SELL)
         if(KBuffer[1]>DBuffer[1] && KBuffer[2]<DBuffer[2])
            closeShort=true;
     }
   else
     {
      if(KBuffer[1]>DBuffer[1] && KBuffer[2]<DBuffer[2])openLong=true;
      if(KBuffer[1]<DBuffer[1] && KBuffer[2]>DBuffer[2])openShort=true;
     }

//--- trade doing
     {
      //--- if K up to D 
      if(openLong || closeShort)
        {
         trReq.price=tick.ask;               // SymbolInfoDouble(NULL,SYMBOL_ASK);
         if(sl>100)
            trReq.sl=tick.ask-_Point*sl;     // Stop Loss level of the order
         if(tp>100)
            trReq.tp=tick.ask+_Point*tp;     // Take Profit level of the order
         trReq.type=ORDER_TYPE_BUY;          // Order type
         OrderSend(trReq,trRez);
        }
      //--- if K down to D
      else if(openShort || closeLong)
        {
         trReq.price=tick.bid;
         if(sl>100)
            trReq.sl=tick.bid+_Point*sl;      // Stop Loss level of the order
         if(tp>100)
            trReq.tp=tick.bid-_Point*tp;      // Take Profit level of the order
         trReq.type=ORDER_TYPE_SELL;          // Order type
         OrderSend(trReq,trRez);
        }
     }
  }
//+------------------------------------------------------------------+
