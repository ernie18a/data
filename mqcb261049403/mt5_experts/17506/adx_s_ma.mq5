//+------------------------------------------------------------------+
//|                            ADX & MA(barabashkakvn's edition).mq5 |
//|                                                        fortrader |
//|                                                 www.fortrader.ru |
//+------------------------------------------------------------------+
#property copyright "fortrader"
#property link      "www.fortrader.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input int      per_MA            = 15;
input int      per_ADX           = 12;
input int      porog_ADX         = 16;
input ushort   TakeProfit_Buy    = 83;
input ushort   StopLoss_Buy      = 55;
input ushort   TrailingStop_Buy  = 27;
input ushort   TakeProfit_Sell   = 63;
input ushort   StopLoss_Sell     = 50;
input ushort   TrailingStop_Sell = 27;
input double   Lots              = 0.1;
//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=30;                // slippage
int            handle_iMA;                           // variable for storing the handle of the iMA indicator 
int            handle_iADX;                          // variable for storing the handle of the iADX indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
   m_trade.SetExpertMagicNumber(m_magic);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),per_MA,0,MODE_SMMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iADX
   handle_iADX=iADX(m_symbol.Name(),Period(),per_ADX);
//--- if the handle is not created 
   if(handle_iADX==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iADX indicator for the symbol %s/%s, error code %d",
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
//---
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

//--- Вычисляем начальные параметры индикаторов для поиска условий входа
   double MA=iMAGet(1);
   double ADX=iADXGet(MAIN_LINE,1);

//-- проверка средств
   if(m_account.FreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",m_account.FreeMargin());
      return;
     }

//--- проверка условий для совершения сделки
   if(iClose(1)>MA && iClose(2)<MA && ADX>porog_ADX)
     {
      if(!RefreshRates())
        {
         time_0=iTime(1);
         return;
        }

      if(m_trade.Buy(Lots,NULL,m_symbol.Ask(),
         m_symbol.NormalizePrice(m_symbol.Ask()-StopLoss_Buy*m_adjusted_point),
         m_symbol.NormalizePrice(m_symbol.Ask()+TakeProfit_Buy*m_adjusted_point)))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            time_0=iTime(1);
            return;
           }
        }
      else
        {
         Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         time_0=iTime(1);
         return;
        }
     }

   if(iClose(1)<MA && iClose(2)>MA && ADX>porog_ADX)
     {
      if(!RefreshRates())
        {
         time_0=iTime(1);
         return;
        }

      if(m_trade.Sell(Lots,NULL,m_symbol.Bid(),
         m_symbol.NormalizePrice(m_symbol.Bid()+StopLoss_Buy*m_adjusted_point),
         m_symbol.NormalizePrice(m_symbol.Bid()-TakeProfit_Buy*m_adjusted_point)))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            time_0=iTime(1);
            return;
           }
        }
      else
        {
         Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         time_0=iTime(1);
         return;
        }
     }

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
              {
               time_0=iTime(1);
               return;
              }
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(iClose(1)<MA)
                 {
                  m_trade.PositionClose(m_position.Ticket()); // close position
                  continue;
                 }
               if(TrailingStop_Buy>0)
                 {
                  if(m_symbol.Bid()-m_position.PriceOpen()>TrailingStop_Buy*m_adjusted_point)
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-TrailingStop_Buy*m_adjusted_point)
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Bid()-TrailingStop_Buy*m_adjusted_point,
                                               m_position.TakeProfit());
                       }
                    }
                 }
              }
            //---
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(iClose(1)>MA)
                 {
                  m_trade.PositionClose(m_position.Ticket()); // close position
                  continue;
                 }
               if(TrailingStop_Sell>0)
                 {
                  if((m_position.PriceOpen()-m_symbol.Ask())>(TrailingStop_Sell*m_adjusted_point))
                    {
                     if((m_position.StopLoss()>(m_symbol.Ask()+TrailingStop_Sell*m_adjusted_point)) || 
                        (m_position.StopLoss()==0))
                       {
                        m_trade.PositionModify(m_position.Ticket(),
                                               m_symbol.Ask()+TrailingStop_Sell*m_adjusted_point,
                                               m_position.TakeProfit());
                       }
                    }
                 }
              }
           }
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
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
//| Get value of buffers for the iADX                                |
//|  the buffer numbers are the following:                           |
//|    0 - MAIN_LINE, 1 - PLUSDI_LINE, 2 - MINUSDI_LINE              |
//+------------------------------------------------------------------+
double iADXGet(const int buffer,const int index)
  {
   double ADX[];
   ArraySetAsSeries(ADX,true);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iADX,buffer,0,index+1,ADX)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ADX[index]);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
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
