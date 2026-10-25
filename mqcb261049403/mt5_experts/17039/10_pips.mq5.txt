//+------------------------------------------------------------------+
//|                             10 pips(barabashkakvn's edition).mq5 |
//|                                                        fortrader |
//|                                                 www.fortrader.ru |
//+------------------------------------------------------------------+
#property copyright "fortrader"
#property link      "www.fortrader.ru"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input ushort   InpTakeProfit_Buy    = 10;          // TakeProfit_Buy
input ushort   InpStopLoss_Buy      = 50;          // StopLoss_Buy
input ushort   InpTrailingStop_Buy  = 50;          // TrailingStop_Buy 
input ushort   InpTakeProfit_Sell   = 10;          // TakeProfit_Sell  
input ushort   InpStopLoss_Sell     = 50;          // StopLoss_Sell  
input ushort   InpTrailingStop_Sell = 50;          // TrailingStop_Sell
input double   Lots                 = 0.1;         // Lots
//---
ulong          m_magic=948578796;                  // magic number
double         ExtTakeProfit_Buy    = 0.0;
double         ExtStopLoss_Buy      = 0.0;
double         ExtTrailingStop_Buy  = 0.0;
double         ExtTakeProfit_Sell   = 0.0;
double         ExtStopLoss_Sell     = 0.0;
double         ExtTrailingStop_Sell = 0.0;
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
      Print("Error RefreshRates. m_symbol.Bid()=",DoubleToString(m_symbol.Bid(),Digits()),
            ", m_symbol.Ask()=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtTakeProfit_Buy    = InpTakeProfit_Buy     *digits_adjust;
   ExtStopLoss_Buy      = InpStopLoss_Buy       *digits_adjust;
   ExtTrailingStop_Buy  = InpTrailingStop_Buy   *digits_adjust;
   ExtTakeProfit_Sell   = InpTakeProfit_Sell    *digits_adjust;
   ExtStopLoss_Sell     = InpStopLoss_Sell      *digits_adjust;
   ExtTrailingStop_Sell = InpTrailingStop_Sell  *digits_adjust;

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
   if(iTickVolume(0)>1)
      return;

   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            total++;

//--- Проверка средств
   if(m_account.FreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",m_account.FreeMargin());
      return;
     }

   if(total==0)
     {
      if(!RefreshRates())
         return;

      //--- Открытие сделкок
      m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),m_symbol.Ask()-ExtStopLoss_Buy*Point(),
                  m_symbol.Ask()+ExtTakeProfit_Buy*Point(),"Покупаем");
      m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),m_symbol.Bid()+ExtStopLoss_Sell*Point(),
                   m_symbol.Bid()-ExtTakeProfit_Sell*Point(),"Продаем");
      return;
     }

   if(total==1)
     {
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
              {
               if(!RefreshRates())
                  return;

               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  m_trade.Buy(Lots,Symbol(),m_symbol.Ask(),m_symbol.Bid()-ExtStopLoss_Buy*Point(),
                              m_symbol.Ask()+ExtTakeProfit_Buy*Point(),"Покупаем");
               else
                  m_trade.Sell(Lots,Symbol(),m_symbol.Bid(),m_symbol.Ask()+ExtStopLoss_Sell*Point(),
                               m_symbol.Bid()-ExtTakeProfit_Sell*Point(),"Продаем");
              }
      return;
     }

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
               return;

            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(ExtTrailingStop_Buy>0)
                 {
                  if(m_symbol.Bid()-m_position.PriceOpen()>Point()*ExtTrailingStop_Buy) // m_symbol.Bid() - цена покупки
                    {
                     if(m_position.StopLoss()<m_symbol.Bid()-Point()*ExtTrailingStop_Buy)
                       {
                        m_trade.PositionModify(m_position.Ticket(),m_symbol.Bid()-Point()*ExtTrailingStop_Buy,m_position.TakeProfit());
                        return;
                       }
                    }
                 }
              }
            else
              {
               if(ExtTrailingStop_Sell>0)
                 {
                  if((m_position.PriceOpen()-m_symbol.Ask())>(Point()*ExtTrailingStop_Sell)) // m_symbol.Ask() - цена продажи
                    {
                     if((m_position.StopLoss()>(m_symbol.Ask()+Point()*ExtTrailingStop_Sell)) || (m_position.StopLoss()==0))
                       {
                        m_trade.PositionModify(m_position.Ticket(),m_symbol.Ask()+Point()*ExtTrailingStop_Sell,m_position.TakeProfit());
                        return;
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
//| Get TickVolume for specified bar index                           | 
//+------------------------------------------------------------------+ 
long iTickVolume(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   long TickVolume[];
   long tickvolume=0;
   ArraySetAsSeries(TickVolume,true);
   int copied=CopyTickVolume(symbol,timeframe,index,1,TickVolume);
   if(copied>0) tickvolume=TickVolume[0];
   return(tickvolume);
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
