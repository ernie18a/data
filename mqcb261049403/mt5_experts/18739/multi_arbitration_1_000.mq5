//+------------------------------------------------------------------+
//|                                      Multi_arbitration 1_000.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version "1.001"
#property description ""
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input string   InpSymbol         = "EURUSD"; // Symbol
input double   InpProfitFoClose  = 300;      // Profit Fo Close
input ulong    m_magic           = 130108500;// magic number
ulong          m_slippage        = 30;       // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(InpSymbol)) // sets symbol name
      return(INIT_PARAMETERS_INCORRECT);

   RefreshRates();

   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//---
   bool result=false;
   while(!result)
     {
      result=m_trade.Buy(m_symbol.LotsMin(),m_symbol.Name());
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
//--- we work only at the time of the birth of new bar
   static datetime prevtime=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==prevtime)
      return;
   prevtime=time_0;

   if(!IsTradeAllowed())
     {
      prevtime=iTime(m_symbol.Name(),Period(),1);
      return;
     }

   ulong    symbol_TICKET_buy=0;
   ulong    symbol_TICKET_sell=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               symbol_TICKET_buy=m_position.Ticket();
            if(m_position.PositionType()==POSITION_TYPE_SELL)
               symbol_TICKET_sell=m_position.Ticket();
           }
   if(symbol_TICKET_buy!=0 && symbol_TICKET_sell!=0)
      m_trade.PositionCloseBy(symbol_TICKET_buy,symbol_TICKET_sell);

   int count_buys=0,count_sells=0;
   CalculatePositions(count_buys,count_sells);
   Comment("count buys: ",count_buys,"\n",
           "count sells: ",count_sells);
   double profit_buys=0.0;
   double profit_sells=0.0;
   CalculateProfitPositions(profit_buys,profit_sells);

   int limit=m_account.LimitOrders();
   if(count_buys+count_sells<limit-15)
     {
      if(profit_buys<profit_sells) // trend down
         m_trade.Buy(m_symbol.LotsMin(),m_symbol.Name());
      else if(profit_sells<profit_buys) // trend up
      m_trade.Sell(m_symbol.LotsMin(),m_symbol.Name());
      else if(profit_buys==0.0 && profit_sells==0.0)
         m_trade.Buy(m_symbol.LotsMin(),m_symbol.Name());
     }
   else
     {
      if(m_account.Profit()>0.0)
         CloseAllPositions();
     }

//---
   CalculatePositions(count_buys,count_sells);
   Comment("count buys: ",count_buys,"\n",
           "count sells: ",count_sells);
   if(m_account.Equity()-m_account.Balance()>InpProfitFoClose)
      CloseAllPositions();
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
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
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
//| Calculate profit positions Buy and Sell                          |
//+------------------------------------------------------------------+
void CalculateProfitPositions(double &profit_buys,double &profit_sells)
  {
   profit_buys=0.0;
   profit_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               profit_buys=profit_buys+m_position.Profit();

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               profit_sells=profit_sells+m_position.Profit();
           }
//---
   return;
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
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0.0;
   count_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
