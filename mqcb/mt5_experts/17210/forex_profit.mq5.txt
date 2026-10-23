//+------------------------------------------------------------------+
//|                        Forex Profit(barabashkakvn's edition).mq5 |
//|                                                        fortrader |
//|                                                 www.fortrader.ru |
//+------------------------------------------------------------------+
#property copyright "fortrader"
#property link      "www.fortrader.ru"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input ushort InpTakeProfit    = 55;          // TakeProfit
input ushort InpTakeProfit1   = 65;          // TakeProfit1
input ushort InpStopLoss      = 60;          // StopLoss
input ushort InpStopLoss1     = 85;          // StopLoss1
input ushort InpTrailingStop  = 20;          // TrailingStop
input ushort InpTrailingStep  = 5;           // TrailingStep
input ushort InpTrailingStop1 = 74;          // TrailingStop1 
input double Lots             = 1;
//---
int          per_EMA10        = 10;
int          per_EMA25        = 25;
int          per_EMA50        = 50;
ulong        m_magic=398064704;    // magic number
//---
double       ExtTakeProfit    = 0.0;
double       ExtTakeProfit1   = 0.0;
double       ExtStopLoss      = 0.0;
double       ExtStopLoss1     = 0.0;
double       ExtTrailingStop  = 0.0;
double       ExtTrailingStep  = 0.0;
double       ExtTrailingStop1 = 0.0;
int          handle_iMA_EMA10;               // variable for storing the handle of the iMA indicator 
int          handle_iMA_EMA25;               // variable for storing the handle of the iMA indicator 
int          handle_iMA_EMA50;               // variable for storing the handle of the iMA indicator 
int          handle_iSAR;                    // variable for storing the handle of the iSAR indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
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
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   ExtTakeProfit=InpTakeProfit;
   ExtTakeProfit1   = InpTakeProfit1;
   ExtStopLoss      = InpStopLoss;
   ExtStopLoss1     = InpStopLoss1;
   ExtTrailingStop  = InpTrailingStop1;
   ExtTrailingStep  = InpTrailingStep;
   ExtTrailingStop1 = InpTrailingStop1;
//--- create handle of the indicator iMA
   handle_iMA_EMA10=iMA(Symbol(),Period(),per_EMA10,0,MODE_EMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_EMA10==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_EMA25=iMA(Symbol(),Period(),per_EMA25,0,MODE_EMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_EMA25==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_EMA50=iMA(Symbol(),Period(),per_EMA50,0,MODE_EMA,PRICE_MEDIAN);
//--- if the handle is not created 
   if(handle_iMA_EMA50==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iSAR
   handle_iSAR=iSAR(Symbol(),Period(),0.02,0.2);
//--- if the handle is not created 
   if(handle_iSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
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
//--- рабтаем только в момент рождения нового бара
   static datetime prev_time=0;
   if(prev_time==iTime(m_symbol.Name(),Period(),0))
      return;
   prev_time=iTime(m_symbol.Name(),Period(),0);
//--- объявляем переменные
   int Buy=0,Sell=0,Buy1=0,Sell1=0;
   double EMA10=0.0,EMA25=0.0,EMA50=0.0,EMA10_prew=0.0,SAR=0.0;

//--- получаем значения индикаторов для поиска условий входа
   EMA10=iMAGet(handle_iMA_EMA10,1);
   EMA10_prew=iMAGet(handle_iMA_EMA10,2);
   EMA25=iMAGet(handle_iMA_EMA25,1);
   EMA50=iMAGet(handle_iMA_EMA50,1);
   SAR=iSARGet(1);
//--- проверка средств
   if(m_account.FreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",m_account.FreeMargin());
      return;
     }
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            total++;
            break;
           }
   if(total==0) // если нет открытых позиций
     {
      if(!RefreshRates())
         return;
      //--- поверка условий для совершения сделки
      if(EMA10>EMA25 && EMA10>EMA50 && EMA10_prew<=EMA50 && SAR<iClose(m_symbol.Name(),Period(),1))
        {
         Print("Open Buy: EMA10>EMA25 && EMA10>EMA50 && EMA10_prew<=EMA50 && SAR<iClose(1)");
         m_trade.Buy(Lots,NULL,m_symbol.Ask(),m_symbol.Ask()-ExtStopLoss*Point(),m_symbol.Ask()+ExtTakeProfit*Point());
        }
      if(EMA10<EMA25 && EMA10<EMA50 && EMA10_prew>=EMA50 && SAR>iClose(m_symbol.Name(),Period(),1))
        {
         Print("Open Sell: EMA10<EMA25 && EMA10<EMA50 && EMA10_prew>=EMA50 && SAR>iClose(1)");
         m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),m_symbol.Bid()+ExtStopLoss1*Point(),m_symbol.Bid()-ExtTakeProfit1*Point());
        }
      return; // выходим
     }

//--- проверка условий на закрытие позиций или на трейлинг
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(EMA10<EMA10_prew && m_position.Profit()>10)
                 {
                  Print("Close Buy: EMA10<EMA10_prew && m_position.Profit()>10");
                  m_trade.PositionClose(m_position.Ticket()); // close position
                  continue; // после закрытия переходим к следующей позиции
                 }
               if(ExtTrailingStop>0)
                 {
                  if(!RefreshRates())
                     continue; // если не удалось обновить цены - переходим к следующей позиции
                  if(m_symbol.Bid()-m_position.PriceOpen()>Point()*ExtTrailingStop)
                     if(m_position.StopLoss()<m_symbol.Bid()-Point()*(ExtTrailingStop+ExtTrailingStep) || m_position.StopLoss()==0)
                       {
                        m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-Point()*ExtTrailingStop,m_position.TakeProfit());
                       }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(EMA10>EMA10_prew && m_position.Profit()>10)
                 {
                  Print("Close Sell: EMA10>EMA10_prew && m_position.Profit()>10");
                  m_trade.PositionClose(m_position.Ticket()); // close position
                  continue; // после закрытия переходим к следующей позиции
                 }
               if(ExtTrailingStop>0)
                 {
                  if(!RefreshRates())
                     continue; // если не удалось обновить цены - переходим к следующей позиции
                  if(m_position.PriceOpen()-m_symbol.Ask()>Point()*ExtTrailingStop)
                     if(m_position.StopLoss()>m_symbol.Ask()+Point()*(ExtTrailingStop+ExtTrailingStep) || m_position.StopLoss()==0)
                       {
                        m_trade.PositionModify(m_position.Ticket(),m_symbol.Ask()+Point()*ExtTrailingStop,m_position.TakeProfit());
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iSAR                                |
//+------------------------------------------------------------------+
double iSARGet(const int index)
  {
   double SAR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iSAR,0,index,1,SAR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(SAR[0]);
  }
//+------------------------------------------------------------------+
