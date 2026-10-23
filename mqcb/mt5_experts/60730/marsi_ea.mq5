//+------------------------------------------------------------------+
//|                                                      MARSIEA.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#include <Trade\Trade.mqh>
//input parameters
input int maPeriod =14;
input int rsiPeriod=14;
input double rsiOverbought=70.0;
input double rsiOversold=30.0;
input double riskPercent=10.0;
input double stopLoss=100;
input double takeProfit=300;
input double slippage=10;
//Indicator Handles
int maHandle;
int rsiHandle;
//Trading Object
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   maHandle=iMA(_Symbol, PERIOD_CURRENT, maPeriod,0,MODE_SMA,PRICE_CLOSE);
   rsiHandle=iRSI(_Symbol,PERIOD_CURRENT,rsiPeriod,PRICE_CLOSE);

   if(maHandle==INVALID_HANDLE || rsiHandle==INVALID_HANDLE)
     {
      Print("❌ Failed to create indicator handles.");
      return INIT_FAILED;
     }

   Print("✅ MARSIEA initialized.");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(maHandle);
   IndicatorRelease(rsiHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(PositionSelect(_Symbol))
      return;

   double ma[2],rsi[2];

   if(CopyBuffer(maHandle,0,0,2,ma) < 0 || CopyBuffer(rsiHandle,0,0,2,rsi) < 0)
     {
      Print("⚠️ Indicator data missing.");
      return;
     }
   double bid= SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double lot=calculateLot();


   if(bid > ma[0] && rsi[0] < rsiOversold)
     {
      double sl = NormalizeDouble(ask - stopLoss * PipSize(),_Digits);
      double tp = NormalizeDouble(ask + takeProfit*PipSize(),_Digits);
      trade.Buy(lot,_Symbol,ask,sl,tp,"Buy MA+RSI");
      Print("📈 Buy order placed.");

     }


   if(bid < ma[0] && rsi[0] > rsiOverbought)
     {
      double sl = NormalizeDouble(bid + stopLoss * PipSize(),_Digits);
      double tp = NormalizeDouble(bid - takeProfit*PipSize(),_Digits);
      trade.Sell(lot,_Symbol,bid,sl,tp,"Sell MA+RSI");
      Print("📉 Sell order placed.");

     }

  }
//+------------------------------------------------------------------+
//Custom dynamic lot calculation function
double calculateLot()
  {
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount=balance*riskPercent / 100;
   double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);

   if(tickValue == 0 || tickSize == 0)
     {
      Print("⚠️ Tick value/size not available");
      return 0.1;
     }
   double valuePerPoint = tickValue/tickSize;
   double lotSize= riskAmount/(stopLoss*valuePerPoint);
   lotSize = NormalizeDouble(lotSize,2);

   return lotSize;

  }
//+------------------------------------------------------------------+
//|   custom function to handle price difference                                                               |
//+------------------------------------------------------------------+
double PipSize()
  {
   if(_Digits == 5 || _Digits == 3)
      return _Point * 10;
   else
      return _Point;
  }
//+------------------------------------------------------------------+
