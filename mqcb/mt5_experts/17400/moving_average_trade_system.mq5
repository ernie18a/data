//+------------------------------------------------------------------+
//|         Moving Average Trade System(barabashkakvn's edition).mq5 |
//|                                                        fortrader |
//|                                                 www.fortrader.ru |
//+------------------------------------------------------------------+
#property copyright "fortrader"
#property link      "www.fortrader.ru"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---- input parameters
input ushort   TakeProfit     = 50;
input ushort   StopLoss       = 50;
input ushort   TrailingStop   = 11;
input double   Lots           = 0.1;
//---
int      per_SMA5       = 5;
int      per_SMA20      = 20;
int      per_SMA40      = 40;
int      per_SMA60      = 60;
//---
ulong          m_magic=15489;                // magic number
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
int    handle_iMA_5;                         // variable for storing the handle of the iMA indicator 
int    handle_iMA_20;                        // variable for storing the handle of the iMA indicator 
int    handle_iMA_40;                        // variable for storing the handle of the iMA indicator 
int    handle_iMA_60;                        // variable for storing the handle of the iMA indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iMA
   handle_iMA_5=iMA(m_symbol.Name(),Period(),per_SMA5,0,MODE_SMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_5==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_20=iMA(m_symbol.Name(),Period(),per_SMA20,0,MODE_SMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_20==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_40=iMA(m_symbol.Name(),Period(),per_SMA40,0,MODE_SMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_40==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_60=iMA(m_symbol.Name(),Period(),per_SMA60,0,MODE_SMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_60==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- работаем только на новом баре
   static datetime prev_time=0;
   datetime time_0=iTime(0);

   if(prev_time==time_0)
      return;

   prev_time=time_0;
//--- Вычисляем начальные параметры индикаторов для поиска условий входа
   double SMA5=iMAGet(handle_iMA_5,1);
   double SMA20=iMAGet(handle_iMA_20,1);
   double SMA40_prew=iMAGet(handle_iMA_40,2);
   double SMA40 = iMAGet(handle_iMA_40,1);
   double SMA60 = iMAGet(handle_iMA_60,1);
//--- Проверка условий для совершения сделки
   if(SMA5>SMA20 && SMA20>SMA40 && (SMA40-SMA60)>=0.0001 && SMA40_prew<=SMA60)
     {
      if(!RefreshRates())
        {
         prev_time=iTime(1);
         return;
        }

      double price=m_symbol.Ask();
      double sl=m_symbol.Ask()-StopLoss*m_adjusted_point;
      double tp=m_symbol.Ask()+TakeProfit*m_adjusted_point;

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,price,ORDER_TYPE_BUY);
      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=Lots)
           {
            Print("BUY SMA40 = ",SMA40," SMA60 = ",SMA60," SMA40_prew = ",SMA40_prew);
            m_trade.Buy(Lots,NULL,price,sl,tp,"Покупаем");
            return;
           }
     }

   if(SMA5<SMA20 && SMA20<SMA40 && (SMA60-SMA40)>=0.0001 && SMA40_prew>=SMA60)
     {
      if(!RefreshRates())
        {
         prev_time=iTime(1);
         return;
        }

      double price=m_symbol.Bid();
      double sl=m_symbol.Bid()+StopLoss*m_adjusted_point;
      double tp=m_symbol.Bid()-TakeProfit*m_adjusted_point;

      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),Lots,price,ORDER_TYPE_SELL);
      if(chek_volime_lot!=0.0)
         if(chek_volime_lot>=Lots)
           {
            Print("SELL SMA40 = ",SMA40," SMA60 = ",SMA60," SMA40_prew = ",SMA40_prew);
            m_trade.Sell(Lots,NULL,price,sl,tp,"Продаем");
            return;
           }
     }

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(SMA40<=SMA60)
                 {
                  m_trade.PositionClose(m_position.Ticket()); // close position
                 }
               if(TrailingStop>0)
                 {
                  if(!RefreshRates())
                    {
                     prev_time=iTime(1);
                     return;
                    }

                  if(m_symbol.Bid()-m_position.PriceOpen()>TrailingStop*m_adjusted_point) // Bid - цена покупки
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-TrailingStop*m_adjusted_point)
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Bid()-TrailingStop*m_adjusted_point,
                                               m_position.TakeProfit());
                       }
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(SMA40>=SMA60)
                 {
                  m_trade.PositionClose(m_position.Ticket()); // close position
                 }
               if(TrailingStop>0)
                 {
                  if(!RefreshRates())
                    {
                     prev_time=iTime(1);
                     return;
                    }

                  if((m_position.PriceOpen()-m_symbol.Ask())>(TrailingStop*m_adjusted_point)) // Ask - цена продажи
                    {
                     if((m_position.StopLoss()>(m_symbol.Ask()+TrailingStop*m_adjusted_point)) || (m_position.StopLoss()==0))
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Ask()+TrailingStop*m_adjusted_point,
                                               m_position.TakeProfit());
                       }
                    }
                 }
              }
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle_iMA,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
