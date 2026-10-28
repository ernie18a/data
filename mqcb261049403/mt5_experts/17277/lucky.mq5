//+------------------------------------------------------------------+
//|                               Lucky(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input ushort   InpShift = 3;                 // разница между ценой на предыдущем тике и текущей
input ushort   InpLimit = 18;                // убыток в пунктах
input bool     Reverse  = false;             // реверс сигналов
//---
bool first=true;
ulong          m_magic=15489;                // magic number
double         ExtShift=0.0;
double         ExtLimit=0.0;
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
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point  = m_symbol.Point()*digits_adjust;
   ExtShift          = InpShift * m_adjusted_point;
   ExtLimit          = InpLimit * m_adjusted_point;

   first=true;
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
   static double prev_ask=0.0; // статическая переменная для хранения цены ask на предыдущем тике
   static double prev_bid=0.0; // статическая переменная для хранения цены bid на предыдущем тике

   if(!RefreshRates())
      return;

   if(first)
     {
      prev_ask=m_symbol.Ask();
      prev_bid=m_symbol.Bid();
      first=false;
      return;
     }

   if(m_symbol.Ask()-prev_ask>=ExtShift)
     {
      double lot=GetLots(ORDER_TYPE_BUY);
      if(lot!=0.0)
        {
         if(!Reverse) // если настройка "реверс сигналов" false
            m_trade.Buy(lot);
         else
            m_trade.Sell(lot);
        }
     }
   if(prev_bid-m_symbol.Bid()>=ExtShift)
     {
      double lot=GetLots(ORDER_TYPE_SELL);
      if(lot!=0.0)
        {
         if(!Reverse) // если настройка "реверс сигналов" false
            m_trade.Sell(lot);
         else
            m_trade.Buy(lot);
        }
     }

   prev_ask=m_symbol.Ask();
   prev_bid=m_symbol.Bid();

   CloseAll();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.Profit()>0)
              {
               m_trade.PositionClose(m_position.Ticket());
              }
            else
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_position.PriceOpen()-m_symbol.Ask()>ExtLimit)
                     m_trade.PositionClose(m_position.Ticket());
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(m_symbol.Bid()-m_position.PriceOpen()>ExtLimit)
                     m_trade.PositionClose(m_position.Ticket());
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLots(ENUM_ORDER_TYPE order_type)
  {
   double result_volume=NormalizeDouble(m_account.FreeMargin()/10000,1);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=0.0;
   if(order_type==ORDER_TYPE_BUY)
      chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),result_volume,m_symbol.Ask(),ORDER_TYPE_BUY);
   if(order_type==ORDER_TYPE_SELL)
      chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),result_volume,m_symbol.Bid(),ORDER_TYPE_SELL);
//---
   if(chek_volime_lot<result_volume) // если можно открыть меньше, чем рассчитанный объём
      return(0.0);
//---
   return (result_volume);
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
//------------------------------------------------------------------------- 
