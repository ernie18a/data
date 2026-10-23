//+------------------------------------------------------------------+
//|                  Elite eFibo Trader(barabashkakvn's edition).mq5 |
//|                             Copyright © 2007, Elite E Services   |
//|                                         www.eliteeservices.net   |
//|    Programmed by:  Mikhail Veneracion   mikhail.eforex@yahoo.com |
//| Forum: www.eesfx.com  Google Group: www.forexcoding.com          |
//|For MQL Programming, EA purchase and lease, and managed accounts  |
//|Contact Elite E Services www.startelite.com                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Elite E Services "
#property link      "info@eliteeservices.net"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
//---
input ulong    MagicNumber       = 100;      // MagicNumber
input ulong    Slippage          = 4;        // Slippage
input bool     Open_Buy          = false;    // Open_Buy
input bool     Open_Sell         = true;     // Open_Sell
input bool     TradeAgainAfterProfit=true;   // TradeAgainAfterProfit   
input ushort   InpLevelDistance  = 20;       // LevelDistance
input ushort   InpStopLoss       = 10;       // ExtStopLoss
input double   MoneyTakeProfit   = 2000;     // Profit (in money)
input double   Lots_Level_1      = 1;        // Level_1
input double   Lots_Level_2      = 1;        // Level_2
input double   Lots_Level_3      = 2;        // Level_3
input double   Lots_Level_4      = 3;        // Level_4
input double   Lots_Level_5      = 5;        // Level_5
input double   Lots_Level_6      = 8;        // Level_6
input double   Lots_Level_7      = 13;       // Level_7
input double   Lots_Level_8      = 21;       // Level_8
input double   Lots_Level_9      = 34;       // Level_9
input double   Lots_Level_10     = 55;       // Level_10
input double   Lots_Level_11     = 89;       // Level_11
input double   Lots_Level_12     = 144;      // Level_12
input double   Lots_Level_13     = 233;      // Level_13
input double   Lots_Level_14     = 377;      // Level_14
//---
bool Trade=true;
datetime FirstTime;
double BestBuySL,BestSellSL;
ulong ticket1,ticket2,ticket3,ticket4,ticket5,ticket6,ticket7,ticket8,ticket9,ticket10,ticket11,ticket12,ticket13,ticket14;

double ExtLevelDistance = 0.0;
double ExtStopLoss      = 0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//if(m_account.MarginMode()!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(MagicNumber);    // sets magic number
//---
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//---
   m_trade.SetDeviationInPoints(Slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;

   ExtLevelDistance  = InpLevelDistance*digits_adjust;
   ExtStopLoss       = InpStopLoss*digits_adjust;
//---
   FirstTime         = 0;
   BestBuySL         = 0.0;
   BestSellSL        = 0.0;
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
//----
   if(TradeAgainAfterProfit)
      Trade=true;
   ticket1 = 0;
   ticket2 = 0;
   ticket3 = 0;
   ticket4 = 0;
   ticket5 = 0;
   ticket6 = 0;
   ticket7 = 0;
   ticket8 = 0;
   ticket9 = 0;
   ticket10 = 0;
   ticket11 = 0;
   ticket12 = 0;
   ticket13 = 0;
   ticket14 = 0;

   if((subTotalOrdersAndPositions()<1) && (Trade))
     {
      subDeleteAllOrders();
      //--- OPEN BUY
      if(Open_Buy && !Open_Sell)
        {
         if(!RefreshRates())
            return;

         double OP=m_symbol.Ask();

         if(ticket1==0)
            ticket1=subOpenPosition(POSITION_TYPE_BUY,Lots_Level_1,ExtStopLoss,0.0);
         if(ticket1>0 && ticket2==0)
            ticket2=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(ExtLevelDistance*Point()),Lots_Level_2,0,ExtStopLoss);
         if(ticket2>0 && ticket3==0)
            ticket3=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(2*ExtLevelDistance*Point()),Lots_Level_3,0,ExtStopLoss);
         if(ticket3>0 && ticket4==0)
            ticket4=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(3*ExtLevelDistance*Point()),Lots_Level_4,0,ExtStopLoss);
         if(ticket4>0 && ticket5==0)
            ticket5=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(4*ExtLevelDistance*Point()),Lots_Level_5,0,ExtStopLoss);
         if(ticket5>0 && ticket6==0)
            ticket6=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(5*ExtLevelDistance*Point()),Lots_Level_6,0,ExtStopLoss);
         if(ticket6>0 && ticket7==0)
            ticket7=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(6*ExtLevelDistance*Point()),Lots_Level_7,0,ExtStopLoss);
         if(ticket7>0 && ticket8==0)
            ticket8=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(7*ExtLevelDistance*Point()),Lots_Level_8,0,ExtStopLoss);
         if(ticket8>0 && ticket9==0)
            ticket9=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(8*ExtLevelDistance*Point()),Lots_Level_9,0,ExtStopLoss);
         if(ticket9>0 && ticket10==0)
            ticket10=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(9*ExtLevelDistance*Point()),Lots_Level_10,0,ExtStopLoss);
         if(ticket10>0 && ticket11==0)
            ticket11=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(10*ExtLevelDistance*Point()),Lots_Level_11,0,ExtStopLoss);
         if(ticket11>0 && ticket12==0)
            ticket12=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(11*ExtLevelDistance*Point()),Lots_Level_12,0,ExtStopLoss);
         if(ticket12>0 && ticket13==0)
            ticket13=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(12*ExtLevelDistance*Point()),Lots_Level_13,0,ExtStopLoss);
         if(ticket13>0 && ticket14==0)
            ticket14=subOpenPendingOrder(ORDER_TYPE_BUY_STOP,OP+(13*ExtLevelDistance*Point()),Lots_Level_14,0,ExtStopLoss);

         if(ticket14>0)
           {
            FirstTime=iTime(m_symbol.Name(),Period(),0);
            return;
           }
        }

      //--- OPEN SELL
      if(Open_Sell && !Open_Buy)
        {
         if(!RefreshRates())
            return;

         double OP=m_symbol.Bid();

         if(ticket1==0)
            ticket1=subOpenPosition(POSITION_TYPE_SELL,Lots_Level_1,ExtStopLoss,0.0);
         if(ticket1>0 && ticket2==0)
            ticket2=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(ExtLevelDistance*Point()),Lots_Level_2,0,ExtStopLoss);
         if(ticket2>0 && ticket3==0)
            ticket3=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(2*ExtLevelDistance*Point()),Lots_Level_3,0,ExtStopLoss);
         if(ticket3>0 && ticket4==0)
            ticket4=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(3*ExtLevelDistance*Point()),Lots_Level_4,0,ExtStopLoss);
         if(ticket4>0 && ticket5==0)
            ticket5=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(4*ExtLevelDistance*Point()),Lots_Level_5,0,ExtStopLoss);
         if(ticket5>0 && ticket6==0)
            ticket6=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(5*ExtLevelDistance*Point()),Lots_Level_6,0,ExtStopLoss);
         if(ticket6>0 && ticket7==0)
            ticket7=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(6*ExtLevelDistance*Point()),Lots_Level_7,0,ExtStopLoss);
         if(ticket7>0 && ticket8==0)
            ticket8=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(7*ExtLevelDistance*Point()),Lots_Level_8,0,ExtStopLoss);
         if(ticket8>0 && ticket9==0)
            ticket9=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(8*ExtLevelDistance*Point()),Lots_Level_9,0,ExtStopLoss);
         if(ticket9>0 && ticket10==0)
            ticket10=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(9*ExtLevelDistance*Point()),Lots_Level_10,0,ExtStopLoss);
         if(ticket10>0 && ticket11==0)
            ticket11=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(10*ExtLevelDistance*Point()),Lots_Level_11,0,ExtStopLoss);
         if(ticket11>0 && ticket12==0)
            ticket12=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(11*ExtLevelDistance*Point()),Lots_Level_12,0,ExtStopLoss);
         if(ticket12>0 && ticket13==0)
            ticket13=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(12*ExtLevelDistance*Point()),Lots_Level_13,0,ExtStopLoss);
         if(ticket13>0 && ticket14==0)
            ticket14=subOpenPendingOrder(ORDER_TYPE_SELL_STOP,OP-(13*ExtLevelDistance*Point()),Lots_Level_14,0,ExtStopLoss);

         if(ticket14>0)
           {
            FirstTime=iTime(m_symbol.Name(),Period(),0);
            return;
           }
        }
      FirstTime=iTime(m_symbol.Name(),Period(),0);
     }
   FirstTime=iTime(m_symbol.Name(),Period(),0);
//--- TAKE PROFIT
   if(subTotalProfit()>=MoneyTakeProfit)
     {
      Print("Money Take Profit Reached");
      if(!TradeAgainAfterProfit)
         Trade=false;

      subClosePositions();
      subDeleteAllOrders();
     }
//--- ModifySL
   if(subTotalPositions()>0)
     {
      BestSellSL= subBestSellSL();
      BestBuySL = subBestBuySL();
      //Print("BestBuySL:"+DoubleToString(BestBuySL,Digits())+
      //      "| BestSellSL:"+DoubleToString(BestSellSL,Digits()));

      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))
            if(m_position.Symbol()==Symbol() && m_position.Magic()==MagicNumber)
               subTrailingStop(m_position.PositionType(),BestSellSL,BestBuySL);

     }
//--- DELETE ALL PENDING ORDERS   
   if(subTotalPositions()<1)
      subDeleteAllOrders();
//---
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int subTotalOrdersAndPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==MagicNumber)
            total++;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==MagicNumber)
            total++;

   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int subTotalPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==MagicNumber)
            total++;

   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double subTotalProfit()
  {
   double Profit=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==MagicNumber)
            Profit+=m_position.Profit();

   return(Profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong subOpenPendingOrder(ENUM_ORDER_TYPE type,double OpenPrice,double Lots,double takeprofit,double stoploss)
  {
   if(!IsTradeAllowed())
      return(0);

   ulong ticket=0;

   int NumberOfTries=10;
   string TicketComment="Andrew EA";

   double
   aStopLoss   = 0.0,
   aTakeProfit = 0.0,
   aOpenPrice  = 0.0,
   bStopLoss   = 0.0,
   bTakeProfit = 0.0;

   if(takeprofit!=0)
     {
      aTakeProfit = NormalizeDouble(OpenPrice+takeprofit*Point(),Digits());
      bTakeProfit = NormalizeDouble(OpenPrice-takeprofit*Point(),Digits());
     }
   if(stoploss!=0)
     {
      aStopLoss   = NormalizeDouble(OpenPrice-stoploss*Point(),Digits());
      bStopLoss   = NormalizeDouble(OpenPrice+stoploss*Point(),Digits());
     }

   if(type==ORDER_TYPE_BUY_STOP)
     {
      for(int c=0;c<NumberOfTries;c++)
        {
         if(m_trade.OrderOpen(Symbol(),ORDER_TYPE_BUY_STOP,Lots,0.0,OpenPrice,aStopLoss,aTakeProfit,0,0,TicketComment))
           {
            ticket=m_trade.ResultOrder();
            if(ticket>0)
               return(ticket);
           }
         else
           {
            Print("BUY_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of order: ",m_trade.ResultOrder());
            Sleep(5000);
            continue;
           }
        }
     }
   if(type==ORDER_TYPE_SELL_STOP)
     {
      for(int c=0;c<NumberOfTries;c++)
        {
         if(m_trade.OrderOpen(Symbol(),ORDER_TYPE_SELL_STOP,Lots,0.0,OpenPrice,bStopLoss,bTakeProfit,0,0,TicketComment))
           {
            ticket=m_trade.ResultOrder();
            if(ticket>0)
               return(ticket);
           }
         else
           {
            Print("SELL_STOP -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of order: ",m_trade.ResultOrder());
            Sleep(5000);
            continue;
           }
        }
     }
   if(type==ORDER_TYPE_BUY_LIMIT)
     {
      for(int c=0;c<NumberOfTries;c++)
        {
         if(m_trade.OrderOpen(Symbol(),ORDER_TYPE_BUY_LIMIT,Lots,0.0,OpenPrice,aStopLoss,aTakeProfit,0,0,TicketComment))
           {
            ticket=m_trade.ResultOrder();
            if(ticket>0)
               return(ticket);
           }
         else
           {
            Print("BUY_LIMIT -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of order: ",m_trade.ResultOrder());
            Sleep(5000);
            continue;
           }
        }
     }
   if(type==ORDER_TYPE_SELL_LIMIT)
     {
      for(int c=0;c<NumberOfTries;c++)
        {
         if(m_trade.OrderOpen(Symbol(),ORDER_TYPE_SELL_LIMIT,Lots,0.0,OpenPrice,bStopLoss,bTakeProfit,0,0,TicketComment))
           {
            ticket=m_trade.ResultOrder();
            if(ticket>0)
               return(ticket);
           }
         else
           {
            Print("BUY_LIMIT -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of order: ",m_trade.ResultOrder());
            Sleep(5000);
            continue;
           }
        }
     }
   return(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong subOpenPosition(ENUM_POSITION_TYPE type,double Lotz,double stoploss,double takeprofit)
  {
   if(!IsTradeAllowed())
      return(0);

   if(!RefreshRates())
      return(0);

   ulong ticket=0;

   int NumberOfTries=10;
   string TicketComment="Hedge EA";

   double
   aStopLoss   = 0.0,
   aTakeProfit = 0.0,
   bStopLoss   = 0.0,
   bTakeProfit = 0.0;

   if(stoploss!=0)
     {
      aStopLoss   = NormalizeDouble(m_symbol.Ask()-stoploss*Point(),Digits());//NormalizeDouble(m_symbol.Ask()-stoploss*Point(),4);
      bStopLoss   = NormalizeDouble(m_symbol.Bid()+stoploss*Point(),Digits());//NormalizeDouble(m_symbol.Bid()+stoploss*Point(),4);
     }

   if(takeprofit!=0)
     {
      aTakeProfit = NormalizeDouble(m_symbol.Ask()+takeprofit*Point(),Digits());//NormalizeDouble(m_symbol.Ask()+takeprofit*Point(),4);
      bTakeProfit = NormalizeDouble(m_symbol.Bid()-takeprofit*Point(),Digits());//NormalizeDouble(m_symbol.Bid()-takeprofit*Point(),4);
     }

   if(type==POSITION_TYPE_BUY)
     {
      for(int c=0;c<NumberOfTries;c++)
        {
         if(m_trade.Buy(Lotz,Symbol(),m_symbol.Ask(),aStopLoss,aTakeProfit,TicketComment))
           {
            ticket=m_trade.ResultDeal();
            if(ticket>0)
               return(ticket);
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
            Sleep(5000);
            continue;
           }
        }
     }

   if(type==POSITION_TYPE_SELL)
     {
      for(int c=0;c<NumberOfTries;c++)
        {
         if(m_trade.Sell(Lotz,Symbol(),m_symbol.Bid(),bStopLoss,bTakeProfit,TicketComment))
           {
            ticket=m_trade.ResultDeal();
            if(ticket>0)
               return(ticket);
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription(),
                  ", ticket of deal: ",m_trade.ResultDeal());
            Sleep(5000);
            continue;
           }
        }
     }
   return(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double subBestBuySL()
  {
   double SL=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==MagicNumber && m_position.PositionType()==POSITION_TYPE_BUY)
            if(m_position.StopLoss()>SL)
               SL=m_position.StopLoss();
   return(SL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double subBestSellSL()
  {
   double SL=10000000;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==MagicNumber && m_position.PositionType()==POSITION_TYPE_SELL)
            if(m_position.StopLoss()<SL)
               SL=m_position.StopLoss();
   return(SL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void subTrailingStop(ENUM_POSITION_TYPE Type,const double best_sell_sl,const double best_buy_sl)
  {
   if(Type==POSITION_TYPE_BUY) // buy position is opened   
     {
      //--- AFTER PROFIT TRAILING STOP      
      if(m_position.StopLoss()<BestBuySL)
        {
         m_trade.PositionModify(m_position.Ticket(),best_buy_sl,m_position.TakeProfit());
         return;
        }

     }
   if(Type==POSITION_TYPE_SELL) // sell position is opened   
     {
      //--- AFTER PROFIT TRAILING STOP      
      if(m_position.StopLoss()>BestSellSL)
        {
         m_trade.PositionModify(m_position.Ticket(),best_sell_sl,m_position.TakeProfit());
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void subDeleteAllOrders()
  {
   if(!IsTradeAllowed())
      return;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==Symbol() && m_order.Magic()==MagicNumber)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void subClosePositions()
  {
   if(!IsTradeAllowed())
      return;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==MagicNumber)
            m_trade.PositionClose(m_position.Ticket());
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
