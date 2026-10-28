//+------------------------------------------------------------------+
//|                         VR---Moving(barabashkakvn's edition).mq5 |
//|                     "Copyright 2013, www.trading-go.ru Project." |
//|                                       "http://www.trading-go.ru" |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, www.trading-go.ru Project."
#property link      "http://www.trading-go.ru"
#property description " Автор идеи Алексей, автор кода Voldemar "
#property description " Торговая система на основе индикатора Moving Awerage "
#property version   "1.000"
//---
#include "Moving.mqh"
CMoving        *m_moving;                    // CMoving object
//--- input parameters
input ulong                m_magic=997750134;                  // magic number
input double               InpLots              = 0;           // Lots (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input double               Risk                 = 5;           // Risk (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input ENUM_TIMEFRAMES      InpMA_period         = PERIOD_H1;   // MA: period 
input int                  InpMA_ma_period      = 60;          // MA: averaging period 
input int                  InpMA_ma_shift       = 0;           // MA: horizontal shift 
input ENUM_MA_METHOD       InpMA_ma_method      = MODE_EMA;    // MA: smoothing type 
input ENUM_APPLIED_PRICE   InpMA_applied_price  = PRICE_CLOSE; // MA: type of price

input ushort               InpTakeProfit        = 50;          // Take Profit (in pips) (only if one position is open)
input double               InpMultiplier        = 1;           // Lot multiplier for a series of Positions
input ushort               InpDistanceMA        = 50 ;         // Distance from Moving Average (in pips) 
input ushort               InpProfitPlus        = 0;           // Additive in the presence of the general profit (in pips) 
//---
ulong                      m_slippage=10;                      // slippage

double                     ExtTakeProfit=0.0;
double                     ExtDistanceMA=0.0;
double                     ExtProfitPlus=0.0;

int                        handle_iMA;                         // variable for storing the handle of the iMA indicator 

double                     m_adjusted_point;                   // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(m_moving!=NULL)
      delete m_moving;
   m_moving=new CMoving;
   if(m_moving!=NULL)
     {
      Print(__FUNCTION__,", before calling the CMoving::Initialization, GetFlag: ",m_moving.GetFlag());
      if(!m_moving.Initialization(Symbol(),m_magic,m_slippage))
         return(INIT_FAILED);
      Print(__FUNCTION__,", after  calling the CMoving::Initialization, GetFlag: ",m_moving.GetFlag());
     }
   else
     {
      Print(__FUNCTION__,", ERROR: Object CMoving is NULL");
      return(INIT_FAILED);
     }
   if(!m_moving.LotsOrRisk(InpLots,Risk))
      return(INIT_FAILED);
   if(!m_moving.CreateMA(InpMA_period,InpMA_ma_period,InpMA_ma_shift,InpMA_ma_method,InpMA_applied_price))
      return(INIT_FAILED);
//---
   m_moving.TakeProfit(InpTakeProfit);
   m_moving.Multiplier(InpMultiplier);
   m_moving.DistanceMA(InpDistanceMA);
   m_moving.ProfitPlus(InpProfitPlus);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(m_moving!=NULL)
      delete m_moving;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   m_moving.Processing();
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
