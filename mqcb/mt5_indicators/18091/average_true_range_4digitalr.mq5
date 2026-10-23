//+------------------------------------------------------------------+
//|                                 Average True Range (digital).mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "The value of the indicator Average True Range (ATR) from several timeframes"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//--- inputs parameters
input ENUM_TIMEFRAMES   period_first      = PERIOD_M15;  // period first ATR
input int               ma_period_first   = 14;          // averaging period first ATR
input ENUM_TIMEFRAMES   period_second     = PERIOD_H1;   // period second ATR
input int               ma_period_second  = 14;          // averaging period second ATR
//---
int    handle_iATR_first;              // variable for storing the handle of the iATR indicator 
int    handle_iATR_second;             // variable for storing the handle of the iATR indicator 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create handle of the indicator iATR
   handle_iATR_first=iATR(Symbol(),period_first,ma_period_first);
//--- if the handle is not created 
   if(handle_iATR_first==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(period_first),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iATR
   handle_iATR_second=iATR(Symbol(),period_second,ma_period_second);
//--- if the handle is not created 
   if(handle_iATR_second==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iATR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(period_second),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(prev_calculated==0)
      return(rates_total);
   string text="ATR("+IntegerToString(ma_period_first)+
               "),"+EnumToString(period_first)+": "+
               DoubleToString(iATRGet(handle_iATR_first,0),Digits())+"\n"+
               "ATR("+IntegerToString(ma_period_second)+
               "),"+EnumToString(period_second)+": "+
               DoubleToString(iATRGet(handle_iATR_second,0),Digits());
   Comment(text);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iATR                                |
//+------------------------------------------------------------------+
double iATRGet(int handle_iATR,const int index)
  {
   double ATR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iATR array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iATR,0,index,1,ATR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iATR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ATR[0]);
  }
//+------------------------------------------------------------------+
