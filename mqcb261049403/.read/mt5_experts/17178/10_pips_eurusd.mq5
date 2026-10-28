//+------------------------------------------------------------------+
//|                      10 pips EURUSD(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
COrderInfo     m_order;                      // pending orders object
//---
input double   Lot               = 0.01;
input int      StopLoss          = 50;
input int      TakeProfit        = 150;
input bool     UseTrailing       = false;
input int      TrailingStopLoss  = 50;
input int      TrailingStep      = 25;
input int      m_magic           = 888;
//---
int MAX_TRAILING_STEP=15;
//---
double m_digits_adjust=0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   m_digits_adjust=m_symbol.Point()*digits_adjust;
//---
   double stopLevel=m_symbol.StopsLevel();
   if(StopLoss<stopLevel)
     {
      Alert("StopLoss установлен меньше, чем разрешен вашим ДЦ. Минимальное значение: ",stopLevel);
      return(INIT_FAILED);
     }
   if(TakeProfit<stopLevel && !UseTrailing)
     {
      Alert("TakeProfit установлен меньше, чем разрешен вашим ДЦ. Минимальное значение: ",stopLevel);
      return(INIT_FAILED);
     }
   double minLot=m_symbol.LotsMin();
   if(Lot<minLot)
     {
      Alert("Lot установлен меньше, чем разрешен вашим ДЦ. Минимальное значение: ",minLot);
      return(INIT_FAILED);
     }
   double maxLot=m_symbol.LotsMax();
   if(Lot>maxLot)
     {
      Alert("Lot установлен больше, чем разрешен вашим ДЦ. Максимальное значение: ",maxLot);
      return(INIT_FAILED);
     }
   double lotStep=m_symbol.LotsStep();
   for(double i=minLot; i<=maxLot; i+=lotStep)
     {
      if(i==Lot)
        {
         break;
        }
      if(i+lotStep>maxLot)
        {
         Alert("Lot установлен неправильный, шаг лота для вашего ДЦ: ",lotStep);
         return(INIT_FAILED);
        }
     }
   if(UseTrailing)
     {
      if(TrailingStopLoss<stopLevel)
        {
         Alert("TrailingStopLoss установлен меньше, чем разрешен вашим ДЦ. Минимальное значение: ",stopLevel);
         return(INIT_FAILED);
        }
      if(TrailingStep<MAX_TRAILING_STEP)
        {
         Alert("TrailingStep установлен маленький, вряд ли это понравиться вашему ДЦ. Если не хотите штрафных санкций от ДЦ ставьте не меньше, чем ",MAX_TRAILING_STEP);
         return(INIT_FAILED);
        }
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
   if(!IsTradeAllowed())
     {
      // пропустим тик если терминал занят
      return;
     }

   int q=0;

   double L = iLow(m_symbol.Name(),Period(),1);
   double H = iHigh(m_symbol.Name(),Period(),1);
   double C = iClose(m_symbol.Name(),Period(),0);
   double O = iOpen(m_symbol.Name(),Period(),0);
   double spred=m_symbol.Spread()*m_digits_adjust;
   double sl = StopLoss * m_digits_adjust;
   double tp = TakeProfit * m_digits_adjust;

   if(UseTrailing)
     {
      TrailingPositions(TrailingStopLoss,TrailingStep);
     }

//--- проверка на пробой High или Low Day (защита от ГЭП)
   if(O>=H || O<=L)
     {
      Comment("\nЗащита от ГЭП (скачек цены нового дня)\n",
              "Не возможно выставить OP_BUYSTOP и OP_SELLSTOP\n",
              "Цена Open пробила High или Low предыдущего дня");
      return;
     }

//--- проверяем наличие отложенных ордеров
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==Symbol() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP || m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               return;
           }

   double stopLevel=m_symbol.StopsLevel()*m_digits_adjust;
   if(stopLevel==0)
      stopLevel=3*m_digits_adjust;

//--- условие на BUY_STOP
   if(H-C>=stopLevel && C-L>=stopLevel && O<H)
     {
      double tpReal=0.0;
      if(!UseTrailing)
         tpReal=H+tp+spred*2;

      if(!m_trade.BuyStop(Lot,H+spred*2,NULL,H-sl+spred*2,tpReal,ORDER_TIME_GTC,iTime(m_symbol.Name(),Period(),0)+PeriodSeconds(Period())))
        {
         Print("BUY_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
               ", ticket of order: ",m_trade.ResultOrder());
        }
     }

//--- условие на SELL_STOP
   if(H-C>=stopLevel && C-L>=stopLevel && O>L)
     {
      double tpReal=0.0;
      if(!UseTrailing)
         tpReal=L-spred-tp;

      if(!m_trade.SellStop(Lot,L-spred,NULL,L-spred+sl,tpReal,ORDER_TIME_GTC,iTime(m_symbol.Name(),Period(),0)+PeriodSeconds(Period())))
        {
         Print("SELL_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
               ", ticket of order: ",m_trade.ResultOrder());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingPositions(int trailingStopLoss,int trailingStep)
  {
   if(!RefreshRates())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               if(m_symbol.Bid()-m_position.PriceOpen()>trailingStopLoss*m_digits_adjust)
                  if(m_position.StopLoss()<
                     m_symbol.Bid() -(trailingStopLoss+trailingStep)*m_digits_adjust || 
                     m_position.StopLoss()==0)
                    {
                     m_trade.PositionModify(m_position.Ticket(),
                                            m_symbol.Bid()-trailingStopLoss*m_digits_adjust,
                                            m_position.TakeProfit());
                    }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               if(m_position.PriceOpen()-m_symbol.Ask()>trailingStopLoss*Point())
                  if(m_position.StopLoss()>
                     m_symbol.Ask()+(trailingStopLoss+trailingStep)*m_digits_adjust || 
                     m_position.StopLoss()==0)
                    {
                     m_trade.PositionModify(m_position.Ticket(),
                                            m_symbol.Ask()+trailingStopLoss*m_digits_adjust,
                                            m_position.TakeProfit());
                    }
           }
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
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
