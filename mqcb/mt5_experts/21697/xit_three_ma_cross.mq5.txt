//+------------------------------------------------------------------+
//|                                          XIT_THREE_EMA_CROSS.mq5 |
//|                            Copyright 2018, Forex XIT - Jeff West |
//|                                         https://www.forexxit.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Forex XIT - Jeff West"
#property link      "https://www.forexxit.com"
#property version   "2.00"


#define XIT_MAGIC 54637763
//---
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>


//--- Slow Moving Average Settings
input int InpSlowMA_Period=60;                                       // Slow Moving Average
input int InpSlowMA_Shift=0;                                         // Slow Moving Average Shift
input ENUM_MA_METHOD InpSlowMA_Method=MODE_SMA;                      // Slow MA Method
input ENUM_APPLIED_PRICE InpSlowMA_AppliedPrice=PRICE_CLOSE;         // Slow MA Applied Price

//--- Intermidate Moving Average Settings
input int InpIntermediateMA_Period=14;                               // Intermidate Moving Average
input int InpIntermediateMA_Shift=0;                                 // Intermidate Moving Average Shift
input ENUM_MA_METHOD InpIntermediateMA_Method=MODE_SMA;              // Intermidate MA Mode
input ENUM_APPLIED_PRICE InpIntermediateMA_AppliedPrice=PRICE_CLOSE; // Intermidate MA Applied Price

//--- Fast Moving Average Settings
input int InpFastMA_Period=4;                                        // Fast Moving Average
input int InpFastMA_Shift=0;                                         // Fast Moving Average Shift
input ENUM_MA_METHOD InpFastMA_Method=MODE_SMA;                      // Fast MA Mode
input ENUM_APPLIED_PRICE InpFastMA_AppliedPrice=PRICE_CLOSE;         // Fast MA Applied Price

//--- MACD Settings
input int InpMACD_Trigger=7;                                         // Points Above or Below Before Signal
input int InpMACD_Fast=12;                                           // MACD Fast
input int InpMACD_Slow=26;                                           // MACD Slow
input int InpMACD_Signal=9;                                          // MACD Signal
input ENUM_APPLIED_PRICE InpMACD_AppliedPrice=PRICE_CLOSE;           // MACD Applied Price

//--- Risk Management         
input int InpRiskPercentage=10;                                       // Risk Percentage
input ENUM_TIMEFRAMES InpATR_TakeProfitTimeframe=PERIOD_H4;          // ATR Take Profit Timeframe
input ENUM_TIMEFRAMES InpATR_StopLossTimeframe=PERIOD_H4;            // ATR Stop Loss Timeframe
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CXitThreeMACross
  {
protected:
   double            adjusted_point;
   CTrade            trade;
   CSymbolInfo       symbol;
   CPositionInfo     position;
   CAccountInfo      account;
   CMoneyFixedRisk   fixed_risk;

   int               slow_ma_handle;
   int               intermediate_ma_handle;
   int               fast_ma_handle;
   int               macd_handle;
   int               atr_take_handle;
   int               atr_stop_handle;

   double            slow_ma_buffer[];
   double            intermediate_ma_buffer[];
   double            fast_ma_buffer[];
   double            macd_main_buffer[];
   double            macd_signal_buffer[];
   double            atr_take_buffer[];
   double            atr_stop_buffer[];

   double            slow_ma_current;
   double            slow_ma_previous;
   double            intermediate_ma_current;
   double            intermediate_ma_previous;
   double            fast_ma_current;
   double            fast_ma_previous;
   double            macd_main_current;
   double            macd_main_previous;
   double            macd_signal_current;
   double            macd_signal_previous;
   double            macd_trigger;
   double            atr_take;
   double            atr_stop;
   double            risk_percentage;

public:
                     CXitThreeMACross(void);
                    ~CXitThreeMACross(void);
   bool              Init(void);
   void              DeInit(void);
   bool              Processing(void);

protected:
   bool              InitCheckParams(const int digits_adjust);
   bool              InitIndicators(void);
   bool              BuyClose(void);
   bool              BuyOpen(void);
   bool              SellClose(void);
   bool              SellOpen(void);
   double            CalcLots(void);
  };
CXitThreeMACross XitExpert;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CXitThreeMACross::CXitThreeMACross(void): adjusted_point(0),
                                          slow_ma_handle(INVALID_HANDLE),
                                          intermediate_ma_handle(INVALID_HANDLE),
                                          fast_ma_handle(INVALID_HANDLE),
                                          macd_handle(INVALID_HANDLE),
                                          atr_take_handle(INVALID_HANDLE),
                                          atr_stop_handle(INVALID_HANDLE),
                                          slow_ma_current(0),
                                          slow_ma_previous(0),
                                          intermediate_ma_current(0),
                                          intermediate_ma_previous(0),
                                          fast_ma_current(0),
                                          fast_ma_previous(0),
                                          macd_main_current(0),
                                          macd_main_previous(0),
                                          macd_signal_current(0),
                                          macd_signal_previous(0),
                                          macd_trigger(0),
                                          atr_take(0),
                                          atr_stop(0),
                                          risk_percentage(0)
  {
   ArraySetAsSeries(slow_ma_buffer,true);
   ArraySetAsSeries(intermediate_ma_buffer,true);
   ArraySetAsSeries(fast_ma_buffer,true);
   ArraySetAsSeries(macd_main_buffer,true);
   ArraySetAsSeries(macd_signal_buffer,true);
   ArraySetAsSeries(atr_take_buffer,true);
   ArraySetAsSeries(atr_stop_buffer,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CXitThreeMACross::~CXitThreeMACross(void)
  {
   IndicatorRelease(slow_ma_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CXitThreeMACross::Init(void)
  {
   symbol.Name(_Symbol);
   trade.SetExpertMagicNumber(XIT_MAGIC);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(_Symbol);


   int digits_adjust=1;
   if(symbol.Digits()==3 || symbol.Digits()==5)
      digits_adjust=10;
   adjusted_point=symbol.Point()*digits_adjust;

   macd_trigger=InpMACD_Trigger*_Point;

   trade.SetDeviationInPoints(3*digits_adjust);

   if(!InitCheckParams(digits_adjust))
      return(false);
   fixed_risk.Percent(InpRiskPercentage);

   if(!InitIndicators())
      return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CXitThreeMACross::InitCheckParams(const int digits_adjust)
  {
   if(!fixed_risk.Init(GetPointer(symbol),_Period,adjusted_point))
     {
      printf("Risk not working!");
      return(false);
     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CXitThreeMACross::InitIndicators(void)
  {
   if(slow_ma_handle==INVALID_HANDLE)
      if((slow_ma_handle=iMA(_Symbol,_Period,InpSlowMA_Period,InpSlowMA_Shift,InpSlowMA_Method,InpSlowMA_AppliedPrice))==INVALID_HANDLE)
        {
         printf("Error creating Slow MA handle.");
         return(false);
        }
   if(fast_ma_handle==INVALID_HANDLE)
      if((fast_ma_handle=iMA(_Symbol,_Period,InpFastMA_Period,InpFastMA_Shift,InpFastMA_Method,InpFastMA_AppliedPrice))==INVALID_HANDLE)
        {
         printf("Error creating Fast MA handle.");
         return(false);
        }
   if(intermediate_ma_handle==INVALID_HANDLE)
      if((intermediate_ma_handle=iMA(_Symbol,_Period,InpIntermediateMA_Period,InpIntermediateMA_Shift,InpIntermediateMA_Method,InpIntermediateMA_AppliedPrice))==INVALID_HANDLE)
        {
         printf("Error creating Intermediate MA handle.");
         return(false);
        }
   if(macd_handle==INVALID_HANDLE)
      if((macd_handle=iMACD(_Symbol,_Period,InpMACD_Fast,InpMACD_Slow,InpMACD_Signal,InpMACD_AppliedPrice))==INVALID_HANDLE)
        {
         printf("Error creating MACD MA handle.");
         return(false);
        }
   if(atr_take_handle==INVALID_HANDLE)
      if((atr_take_handle=iATR(_Symbol,InpATR_TakeProfitTimeframe,14))==INVALID_HANDLE)
        {
         printf("Error creating ATR take handle");
         return(false);
        }
   if(atr_stop_handle==INVALID_HANDLE)
      if((atr_stop_handle=iATR(_Symbol,InpATR_StopLossTimeframe,14))==INVALID_HANDLE)
        {
         printf("Error creating ATR stop handle");
         return(false);
        }

   ArrayResize(slow_ma_buffer,2);
   ArrayResize(intermediate_ma_buffer,2);
   ArrayResize(fast_ma_buffer,2);
   ArrayResize(macd_main_buffer,2);
   ArrayResize(macd_signal_buffer,2);
   ArrayResize(atr_take_buffer,2);
   ArrayResize(atr_stop_buffer,2);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CXitThreeMACross::BuyClose(void)
  {
   bool res=false;

   if(fast_ma_current<intermediate_ma_current)
     {
      if(trade.PositionClose(_Symbol))
         printf("Short position by %s to be closed",_Symbol);
      else
         printf("Error closing position by %s : '%s'",_Symbol,trade.ResultComment());
      //--- processed and cannot be modified
      res=true;
     }

   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CXitThreeMACross::SellClose(void)
  {
   bool res=false;

   if(fast_ma_current>intermediate_ma_current)
     {
      if(trade.PositionClose(_Symbol))
         printf("Short position by %s to be closed",_Symbol);
      else
         printf("Error closing position by %s : '%s'",_Symbol,trade.ResultComment());
      //--- processed and cannot be modified
      res=true;
     }

   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CXitThreeMACross::BuyOpen(void)
  {
   bool res=false;

   if(
      macd_main_current>macd_main_previous && 
      macd_signal_current>macd_signal_previous && 
      macd_signal_current<macd_main_current-macd_trigger && 
      intermediate_ma_current>intermediate_ma_previous && 
      fast_ma_current>fast_ma_previous && 
      intermediate_ma_current>slow_ma_current && 
      fast_ma_current>intermediate_ma_current
      )
     {

      double   price=symbol.Ask();
      double   tp=NormalizeDouble(symbol.Bid()+atr_take,_Digits);
      double   sl=NormalizeDouble(symbol.Ask()-atr_stop,_Digits);
      double   lots_check=fixed_risk.CheckOpenLong(price,sl);
      double   lots=trade.CheckVolume(symbol.Name(),lots_check,price,ORDER_TYPE_BUY);
      string   comment="XIT Three MA - Buy";

      if(account.FreeMarginCheck(_Symbol,ORDER_TYPE_BUY,lots,price)<0.0)
         printf("We have no money. Free Margin = %f",account.FreeMargin());
      else
        {

         //--- open position
         if(trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,lots,price,sl,tp,comment))
           {
            printf("Position by %s to be opened",_Symbol);
           }
         else
           {
            printf("Error opening BUY position by %s : '%s'",_Symbol,trade.ResultComment());
            printf("Open parameters : price=%f, TP=%f, SL=%f",price,tp,sl);
           }
        }

      res=true;
     }

   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CXitThreeMACross::SellOpen(void)
  {
   bool res=false;

   if(
      macd_main_current<macd_main_previous && 
      macd_signal_current<macd_signal_previous && 
      macd_signal_current>macd_main_current+macd_trigger && 
      intermediate_ma_current<intermediate_ma_previous && 
      fast_ma_current<fast_ma_previous && 
      intermediate_ma_current<slow_ma_current && 
      fast_ma_current<intermediate_ma_current
      )
     {
      double   price=symbol.Bid();
      double   tp=NormalizeDouble(symbol.Ask()-atr_take,_Digits);
      double   sl=NormalizeDouble(symbol.Bid()+atr_stop,_Digits);
      double   lots_check=fixed_risk.CheckOpenShort(price,sl);
      double   lots=trade.CheckVolume(symbol.Name(),lots_check,price,ORDER_TYPE_SELL);
      string   comment="XIT Three MA - Sell";

      if(account.FreeMarginCheck(_Symbol,ORDER_TYPE_SELL,lots,price)<0.0)
         printf("We have no money. Free Margin = %f",account.FreeMargin());
      else
        {
         //--- open position
         if(trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,lots,price,sl,tp,comment))
           {
            printf("Position by %s to be opened",_Symbol);

           }
         else
           {
            printf("Error opening SELL position by %s : '%s'",_Symbol,trade.ResultComment());
            printf("Open parameters : price=%f, TP=%f, SL=%f",price,tp,sl);
           }
        }

      res=true;
     }

   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CXitThreeMACross::Processing(void)
  {
   if(!symbol.RefreshRates())
      return(false);
   if(
      BarsCalculated(slow_ma_handle)<2 || 
      BarsCalculated(intermediate_ma_handle)<2 || 
      BarsCalculated(fast_ma_handle)<2 || 
      BarsCalculated(macd_handle)<2 || 
      BarsCalculated(atr_stop_handle)<2 || 
      BarsCalculated(atr_take_handle)<2
      ) return(false);

   if(
      CopyBuffer(slow_ma_handle,0,0,2,slow_ma_buffer)!=2 || 
      CopyBuffer(intermediate_ma_handle,0,0,2,intermediate_ma_buffer)!=2 || 
      CopyBuffer(fast_ma_handle,0,0,2,fast_ma_buffer)!=2||
      CopyBuffer(macd_handle,0,0,2,macd_main_buffer) !=2||
      CopyBuffer(macd_handle,1,0,2,macd_signal_buffer)!=2 || 
      CopyBuffer(atr_stop_handle,0,0,2,atr_stop_buffer) != 2 ||
      CopyBuffer(atr_take_handle,0,0,2,atr_take_buffer) != 2
      ) return(false);

   slow_ma_current=slow_ma_buffer[0];
   slow_ma_previous=slow_ma_buffer[1];
   intermediate_ma_current=intermediate_ma_buffer[0];
   intermediate_ma_previous=intermediate_ma_buffer[1];
   fast_ma_current=fast_ma_buffer[0];
   fast_ma_previous=fast_ma_buffer[1];
   macd_main_current=macd_main_buffer[0];
   macd_main_previous=macd_main_buffer[1];
   macd_signal_current=macd_signal_buffer[0];
   macd_signal_previous=macd_signal_buffer[1];
   atr_take=atr_take_buffer[0];
   atr_stop=atr_stop_buffer[0];

   if(position.Select(_Symbol))
     {
      if(position.PositionType()==POSITION_TYPE_BUY)
        {
         if(BuyClose())
            return(true);
        }
      else
        {
         if(SellClose())
            return(true);
        }
     }
//-- Open
   else
     {
      if(BuyOpen())
         return(true);
      if(SellOpen())
         return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//---
   if(!XitExpert.Init())
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   static datetime limit_time=0; // last trade processing time + timeout
//--- don't process if timeout
   if(TimeCurrent()>=limit_time)
     {
      //--- check for data
      if(Bars(_Symbol,_Period)>2*InpSlowMA_Period)
        {

         //--- change limit time by timeout in seconds if processed
         if(XitExpert.Processing())
            limit_time=TimeCurrent();
        }
     }
  }
//+------------------------------------------------------------------+
