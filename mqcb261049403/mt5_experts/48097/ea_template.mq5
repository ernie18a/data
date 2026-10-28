//+------------------------------------------------------------------+
//|                                                  ea_template.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//| Example of Expert Advisor to use with neural network models      |
//| from book "Neural Networks for algorithmic trading in MQL5"      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
//--- input parameters
sinput string          Model = "our_model.net";
sinput int             BarsToPattern = 3;
sinput bool            Common = true;
input ENUM_TIMEFRAMES  TimeFrame = PERIOD_M5;
input double           TradeLevel = 0.9;
input double           Lot = 0.01;
input int              MaxTP = 500;
input double           ProfitMultiply = 0.8;
input int              MinTarget = 100;
input int              StopLoss = 300;
sinput bool            UseOpenCL = true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <NeuroNetworksBook\realization\neuronnet.mqh>
#include <Trade\Trade.mqh>

CNet *net;
CTrade *trade;
datetime lastbar = 0;
int h_RSI;
int h_MACD;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!(net = new CNet()))
     {
      PrintFormat("Error of create Net: %d", GetLastError());
      return INIT_FAILED;
     }
   if(!net.Load(Model, Common))
     {
      PrintFormat("Error of load mode %s: %d", Model, GetLastError());
      return INIT_FAILED;
     }
   net.UseOpenCL(UseOpenCL);
//---
   h_RSI = iRSI(_Symbol, TimeFrame, 12, PRICE_TYPICAL);
   if(h_RSI == INVALID_HANDLE)
     {
      PrintFormat("Error of load indicator %s", "RSI");
      return INIT_FAILED;
     }
   h_MACD = iMACD(_Symbol, TimeFrame, 12, 48, 12, PRICE_TYPICAL);
   if(h_MACD == INVALID_HANDLE)
     {
      PrintFormat("Error of load indicator %s", "MACD");
      return INIT_FAILED;
     }
//---
   if(!(trade = new CTrade()))
     {
      PrintFormat("Error of create CTrade: %d", GetLastError());
      return INIT_FAILED;
     }
   if(!trade.SetTypeFillingBySymbol(_Symbol))
      return INIT_FAILED;
//---
   lastbar = TimeCurrent();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(!!net)
      delete net;
   if(!!trade)
      delete trade;
   IndicatorRelease(h_RSI);
   IndicatorRelease(h_MACD);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(lastbar >= iTime(_Symbol, TimeFrame, 0))
      return;
   lastbar = iTime(_Symbol, TimeFrame, 0);
//---
   double macd_main[], macd_signal[], rsi[];
   if(h_RSI == INVALID_HANDLE || CopyBuffer(h_RSI, 0, 1, BarsToPattern, rsi) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "RSI");
      return;
     }
   if(h_MACD == INVALID_HANDLE || CopyBuffer(h_MACD, MAIN_LINE, 1, BarsToPattern, macd_main) <= 0 ||
      CopyBuffer(h_MACD, SIGNAL_LINE, 1, BarsToPattern, macd_signal) <= 0)
     {
      PrintFormat("Error loading indicator %s data", "MACD");
      return;
     }
   CBufferType *input_data = new CBufferType();
   if(!input_data)
     {
      PrintFormat("Error of create Input data array: %d", GetLastError());
      return;
     }
   if(!input_data.BufferInit(BarsToPattern, 4, 0))
      return;
   for(int i = 0; i < BarsToPattern; i++)
     {
      if(!input_data.Update(i, 0, (TYPE)rsi[i]))
        {
         PrintFormat("Error of add Input data to array: %d", GetLastError());
         delete input_data;
         return;
        }
      if(!input_data.Update(i, 1, (TYPE)macd_main[i]))
        {
         PrintFormat("Error of add Input data to array: %d", GetLastError());
         delete input_data;
         return;
        }
      if(!input_data.Update(i, 2, (TYPE)macd_signal[i]))
        {
         PrintFormat("Error of add Input data to array: %d", GetLastError());
         delete input_data;
         return;
        }
      if(!input_data.Update(i, 3, (TYPE)(macd_main[i] - macd_signal[i])))
        {
         PrintFormat("Error of add Input data to array: %d", GetLastError());
         delete input_data;
         return;
        }
     }
   if(!input_data.Reshape(1,input_data.Total()))
     return;
//---
   if(!net)
     {
      delete input_data;
      return;
     }
   if(!net.FeedForward(input_data))
     {
      PrintFormat("Error of Feed Forward: %d", GetLastError());
      delete input_data;
      return;
     }
   if(!net.GetResults(input_data))
     {
      PrintFormat("Error of Get Result: %d", GetLastError());
      delete input_data;
      return;
     }
   if(input_data.At(0) > 0.0)
     {
      bool opened = false;
      for(int i = 0; i < PositionsTotal(); i++)
        {
         if(PositionGetSymbol(i) != _Symbol)
            continue;
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            opened = true;
        }
      if(opened)
        {
         delete input_data;
         return;
        }
      if(input_data.At(0) < TradeLevel ||
         input_data.At(1) < (MinTarget * SymbolInfoDouble(_Symbol, SYMBOL_POINT)))
        {
         delete input_data;
         return;
        }
      double tp = SymbolInfoDouble(_Symbol, SYMBOL_BID) + MathMin(input_data.At(1) * ProfitMultiply, MaxTP * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
      double sl = SymbolInfoDouble(_Symbol, SYMBOL_BID) - StopLoss * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      trade.Buy(Lot, _Symbol, 0, sl, tp);
     }
   if(input_data.At(0) < 0)
     {
      bool opened = false;
      for(int i = 0; i < PositionsTotal(); i++)
        {
         if(PositionGetSymbol(i) != _Symbol)
            continue;
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            opened = true;
        }
      if(opened)
        {
         delete input_data;
         return;
        }
      if(input_data.At(0) > -TradeLevel ||
         input_data.At(1) > -(MinTarget * SymbolInfoDouble(_Symbol, SYMBOL_POINT)))
        {
         delete input_data;
         return;
        }
      double tp = SymbolInfoDouble(_Symbol, SYMBOL_BID) + MathMax(input_data.At(1) * ProfitMultiply, -MaxTP * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
      double sl = SymbolInfoDouble(_Symbol, SYMBOL_BID) + StopLoss * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      trade.Sell(Lot, _Symbol, 0, sl, tp);
     }
   delete input_data;
  }
//+------------------------------------------------------------------+
