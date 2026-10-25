//+------------------------------------------------------------------+
//|                    Waddah Attar Win(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property link      "waddahattar@hotmail.com"
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
input int      InpStep        = 20;          // Step between the current price and the price of the pending order
input double   FirstLot       = 0.1;         // FirstLot (position + pending orders = 0)
input double   IncLot         = 0.0;         // IncLot (position + pending orders > 0)
input double   MinProfit      = 910;         // MinProfit (in the deposit currency)
input int      m_magic        = 2008;        // Magic Number

double LastSellLimitlLot=0;
double LastBuyLimitLot=0;
double LastSellLimitPrice=0.0;
double LastBuyLimitPrice=0.0;
//---
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
double         ExtStep=0.0;
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

   ExtStep=InpStep*m_adjusted_point;
   LastSellLimitPrice=0.0;
   LastBuyLimitPrice=0.0;
//---
   Comment("Waddah Attar Win");
   GlobalVariableSet("OldBalance",m_account.Balance());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(m_account.Equity()>=GlobalVariableGet("OldBalance")+MinProfit)
     {
      DeleteOrders();
      ClosePositions();
      GlobalVariableSet("OldBalance",0.0);
     }

   GlobalVariableSet("OldBalance",m_account.Balance());

   if(TotalPositionsAndPendingOrders()==0)
     {
      if(!RefreshRates())
         return;

      m_trade.BuyLimit(FirstLot,m_symbol.NormalizePrice(m_symbol.Bid()-ExtStep));
      m_trade.SellLimit(FirstLot,m_symbol.NormalizePrice(m_symbol.Ask()+ExtStep));

      return;
     }

   if(!RefreshRates())
      return;

   if((m_symbol.Ask()-LastBuyLimitPrice)<=5*m_symbol.Point()) // FirstLot is very close
      m_trade.BuyLimit(LastBuyLimitLot+IncLot,m_symbol.NormalizePrice(m_symbol.Bid()-ExtStep));

   if((LastSellLimitPrice-m_symbol.Bid())<=5*m_symbol.Point()) // FirstLot is very close
      m_trade.SellLimit(LastBuyLimitLot+IncLot,m_symbol.NormalizePrice(m_symbol.Ask()+ExtStep));

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
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalPositionsAndPendingOrders()
  {
   int total=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            total++;

   return(total);
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_ORDER_ADD)
     {
      long     order_type        =0;
      double   order_price       =0.0;
      double   order_volume      =0.0;
      string   order_symbol      ="";
      long     order_magic       =0;
      if(OrderSelect(trans.order)) // select pending orders 
        {
         order_type=OrderGetInteger(ORDER_TYPE);
         order_price=OrderGetDouble(ORDER_PRICE_OPEN);
         order_volume=OrderGetDouble(ORDER_VOLUME_INITIAL);
         order_symbol=OrderGetString(ORDER_SYMBOL);
         order_magic=OrderGetInteger(ORDER_MAGIC);
        }
      else
         return;
      if(order_symbol==m_symbol.Name() && order_magic==m_magic)
        {
         if(order_type==ORDER_TYPE_BUY_LIMIT)
           {
            LastBuyLimitPrice=order_price;
            LastBuyLimitLot=order_volume;
           }
         if(order_type==ORDER_TYPE_SELL_LIMIT)
           {
            LastSellLimitPrice=order_price;
            LastSellLimitlLot=order_volume;
           }
        }
     }
  }
//+------------------------------------------------------------------+
