//+------------------------------------------------------------------+
//|                              Ambush(barabashkakvn's edition).mq5 |
//|                                                         Zuzabush |
//|                                          www.Zuzabush@yandex.ru  |
//+------------------------------------------------------------------+
#property copyright "Zuzabush"
#property link      "www.Zuzabush@yandex"
#property version   "1.000"
//---
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
//--- input parameters
input int      InpIndentation = 10;          // Initial indentation
input ushort   InpMaxSpread   = 5;           // Max spread
input ushort   InpTrailingStop= 10;          // Trailing Stop
input ushort   InpTrailingStep= 1;           // Trailing Step 
input uchar    InpPause       = 1;           // Pause (seconds)
input double   InpEquityTP    = 15;          // Equity profit 
input double   InpEquitySL    = 5;           // Equity loss 
input ulong    m_magic        =331101773;    // magic number
//---
ulong          m_slippage=10;                // slippage

double         ExtIndentation=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);

   ExtIndentation = InpIndentation*m_symbol.Point();
   ExtTrailingStop= InpTrailingStop*m_symbol.Point();
   ExtTrailingStep= InpTrailingStep*m_symbol.Point();
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
   if(m_account.Profit()>InpEquityTP || (m_account.Profit()<0.0 && m_account.Profit()<-InpEquitySL))
      CloseAllPositions();
//--- calculate all pending orders for symbol                          
   int count_buy_stop   = 0;
   int count_sell_stop  = 0;
   int count_other      = 0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
               count_buy_stop++;
            else if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               count_sell_stop++;
            else
               count_other++;
           }
   if(count_other!=0) // you can only work with "Buy stop" and "Sell stop" pending orders
      return;
   if(count_buy_stop>1) // you can only work with one "Buy stop" pending order
     {
      DeleteOrders(ORDER_TYPE_BUY_STOP);
      return;
     }
   if(count_sell_stop>1) // you can only work with one "Sell stop" pending order
     {
      DeleteOrders(ORDER_TYPE_SELL_STOP);
      return;
     }
   if(count_buy_stop==0 || count_sell_stop==0)
      if(!RefreshRates()) // if the prices could not be updated - this is an error
         return;
   if(count_buy_stop==0)
     {
      int      spread      = m_symbol.Spread();
      double   stops_level = (double)m_symbol.StopsLevel();
      double   point       = m_symbol.Point();
      double   ask         = m_symbol.Ask();
      if(spread<=InpMaxSpread)
        {
         //--- if StopsLevel() is zero - then we take three spreads
         stops_level=(stops_level==0.0)?(double)spread*3.0:stops_level;
         stops_level*=point;
         double price=(stops_level<ExtIndentation)?ask+ExtIndentation:ask+stops_level;
         bool result=m_trade.BuyStop(m_symbol.LotsMin(),m_symbol.NormalizePrice(price),m_symbol.Name());
         //if(result)
         //   DebugBreak();
         Print("BUY_STOP -> ",result,". Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),"\n",
               "--> Spread: ",DoubleToString(spread,0),
               ", Ask: ",DoubleToString(ask,m_symbol.Digits()),
               ", StopsLevel: ",DoubleToString(stops_level,m_symbol.Digits()),
               ", price Buy stop: ",DoubleToString(price,m_symbol.Digits()));
         int d=0;
        }
     }
   if(count_sell_stop==0)
     {
      int      spread      = m_symbol.Spread();
      double   stops_level = (double)m_symbol.StopsLevel();
      double   point       = m_symbol.Point();
      double   bid         = m_symbol.Bid();
      if(spread<=InpMaxSpread)
        {
         //--- if StopsLevel() is zero - then we take three spreads
         stops_level=(stops_level==0.0)?(double)spread*3.0:stops_level;
         stops_level*=point;
         double price=(stops_level<ExtIndentation)?bid-ExtIndentation:bid-stops_level;
         bool result=m_trade.SellStop(m_symbol.LotsMin(),m_symbol.NormalizePrice(price),m_symbol.Name());
         //if(result)
         //   DebugBreak();
         Print("Sell_STOP -> ",result,". Result Retcode: ",m_trade.ResultRetcode(),
               ", description of Retcode: ",m_trade.ResultRetcodeDescription(),"\n",
               "--> Spread: ",DoubleToString(spread,0),
               ", Bid: ",DoubleToString(bid,m_symbol.Digits()),
               ", StopsLevel: ",DoubleToString(stops_level,m_symbol.Digits()),
               ", price Sell stop: ",DoubleToString(price,m_symbol.Digits()));
         int d=0;
        }
     }
//--- trailing pending orders
   static datetime PrevTime=0;
   datetime time_current=TimeCurrent();
   if(time_current-PrevTime<InpPause)
      return;
   PrevTime=time_current;
   if(!RefreshRates()) // if the prices could not be updated - this is an error
      return;
   TrailingPendigOrders();
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Trailing pendig orders                                           |
//+------------------------------------------------------------------+
void TrailingPendigOrders()
  {
   if(InpTrailingStop==0)
      return;
   int spread=m_symbol.Spread();
//if(spread>InpMaxSpread)
//   return;
   if(!RefreshRates()) // if the prices could not be updated - this is an error
      return;
   double   stops_level = (double)m_symbol.StopsLevel();
   double   point       = m_symbol.Point();
   double   ask         = m_symbol.Ask();
   double   bid         = m_symbol.Bid();
//--- if StopsLevel() is zero - then we take three spreads
   stops_level=(stops_level==0.0)?(double)spread*3.0:stops_level;
   stops_level*=point;
//---
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
              {
               double price=(stops_level<ExtTrailingStop+ExtTrailingStep)?ask+ExtTrailingStop+ExtTrailingStep:ask+stops_level;
               if(!CompareDoubles(price,m_order.PriceOpen(),m_symbol.Digits()))
                  m_trade.OrderModify(m_order.Ticket(),price,0.0,0.0,
                                      m_order.TypeTime(),m_order.TimeExpiration());
               continue;
              }
            else if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
              {
               double price=(stops_level<ExtTrailingStop+ExtTrailingStep)?bid-ExtTrailingStop-ExtTrailingStep:bid-stops_level;
               if(!CompareDoubles(price,m_order.PriceOpen(),m_symbol.Digits()))
                  m_trade.OrderModify(m_order.Ticket(),price,0.0,0.0,
                                      m_order.TypeTime(),m_order.TimeExpiration());
              }
           }
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
