//+------------------------------------------------------------------+
//|                                      Multi Arbitration 1.1xx.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version "1.104"
#property description "Run ONLY ON PERIOD_M1"
#property description "New strategy (1.1xx):"
#property description "https://www.mql5.com/en/forum/189685/page24#comment_5420669"
#property description "For \"BUY\": the next position \"BUY\" can be opened below the lowest \"BUY\""
#property description "For \"SELL\": the next position \"SELL\" can be opened above the highest \"SELL\""
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol_one;                 // symbol info object
CSymbolInfo    m_symbol_two;                 // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input ENUM_TIMEFRAMES InpTimeFrame=PERIOD_M15;// Time frame
input uchar    InpSymbolTwo      = 1;        // from "0" to 19
input double   InpProfitFoClose  = 300;      // Profit Fo Close
input ulong    m_magic           = 130108500;// magic number
ulong          m_slippage        = 30;       // slippage
string         ExtArrSymbols[20]=
  {
   "EURUSD","GBPUSD","USDCHF","USDJPY","USDCAD",
   "AUDUSD","AUDNZD","AUDCAD","AUDCHF","AUDJPY",
   "CHFJPY","EURGBP","EURAUD","EURCHF","EURJPY",
   "EURNZD","EURCAD","GBPCHF","GBPJPY","CADCHF"
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()!=PERIOD_M1)
     {
      Print("Run ONLY ON PERIOD_M1");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol_one.Name(Symbol())) // sets symbol name
      return(INIT_PARAMETERS_INCORRECT);
   if(!m_symbol_two.Name(ExtArrSymbols[InpSymbolTwo])) // sets symbol name
      return(INIT_PARAMETERS_INCORRECT);
   Print("Symbol two: ",m_symbol_two.Name());

   RefreshRates(m_symbol_one);
   RefreshRates(m_symbol_two);

   m_symbol_one.Refresh();
   m_symbol_two.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(m_symbol_one.Name(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(m_symbol_one.Name(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//---
   m_trade.SetAsyncMode(true);
//---
   bool result_one=false,result_two=false;
   while(!result_one)
      result_one=m_trade.Buy(m_symbol_one.LotsMin(),m_symbol_one.Name());
   while(!result_two)
      result_two=m_trade.Buy(m_symbol_two.LotsMin(),m_symbol_two.Name());
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
   datetime time_0=iTime(m_symbol_one.Name(),InpTimeFrame,0);
   if(time_0==prevtime)
      return;
   prevtime=time_0;

   if(!IsTradeAllowed())
     {
      prevtime=iTime(m_symbol_one.Name(),InpTimeFrame,0);
      return;
     }

//--- Search for the highest "SELL" and the lowest "BUY"
   ulong    symbol_TICKET_buy_one=0;
   ulong    symbol_TICKET_sell_one=0;
   ulong    symbol_TICKET_buy_two=0;
   ulong    symbol_TICKET_sell_two=0;

   double   price_lowest_buy_one=DBL_MAX;
   double   price_lowest_buy_two=DBL_MAX;
   double   price_highest_sell_one=DBL_MIN;
   double   price_highest_sell_two=DBL_MIN;

   int count_buys_one=0,count_sells_one=0,count_buys_two=0,count_sells_two=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Magic()==m_magic)
            if(m_position.Symbol()==m_symbol_one.Name() || m_position.Symbol()==m_symbol_two.Name())
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_position.Symbol()==m_symbol_one.Name())
                    {
                     symbol_TICKET_buy_one=m_position.Ticket();
                     if(m_position.PriceOpen()<price_lowest_buy_one)
                        price_lowest_buy_one=m_position.PriceOpen();
                     count_buys_one++;
                    }
                  else if(m_position.Symbol()==m_symbol_two.Name())
                    {
                     symbol_TICKET_buy_two=m_position.Ticket();
                     if(m_position.PriceOpen()<price_lowest_buy_two)
                        price_lowest_buy_two=m_position.PriceOpen();
                     count_buys_two++;
                    }
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(m_position.Symbol()==m_symbol_one.Name())
                    {
                     symbol_TICKET_sell_one=m_position.Ticket();
                     if(m_position.PriceOpen()>price_highest_sell_one)
                        price_highest_sell_one=m_position.PriceOpen();
                     count_sells_one++;
                    }
                  else if(m_position.Symbol()==m_symbol_two.Name())
                    {
                     symbol_TICKET_sell_two=m_position.Ticket();
                     if(m_position.PriceOpen()>price_highest_sell_two)
                        price_highest_sell_two=m_position.PriceOpen();
                     count_sells_two++;
                    }
                 }
              }
   if(symbol_TICKET_buy_one!=0 && symbol_TICKET_sell_one!=0)
      if(count_buys_one>1 && count_sells_one>1)
         m_trade.PositionCloseBy(symbol_TICKET_buy_one,symbol_TICKET_sell_one);
   if(symbol_TICKET_buy_two!=0 && symbol_TICKET_sell_two!=0)
      if(count_buys_two>1 && count_sells_two>1)
         m_trade.PositionCloseBy(symbol_TICKET_buy_two,symbol_TICKET_sell_two);

   if(!RefreshRates(m_symbol_one) || !RefreshRates(m_symbol_two))
      return;

   CalculatePositions(count_buys_one,count_sells_one,count_buys_two,count_sells_two);
   Comment("count buys ",m_symbol_one.Name(),": ",count_buys_one,"\n",
           "count sells ",m_symbol_one.Name(),": ",count_sells_one,"\n",
           "count buys ",m_symbol_two.Name(),": ",count_buys_two,"\n",
           "count sells ",m_symbol_two.Name(),": ",count_sells_two);
//---
   int limit=m_account.LimitOrders();
   if(!RefreshRates(m_symbol_one) || !RefreshRates(m_symbol_two))
      return;
   if(count_buys_one+count_sells_one+count_buys_two+count_sells_two<limit-15)
     {
      if(m_symbol_one.Ask()<price_lowest_buy_one) // trend down
         m_trade.Buy(m_symbol_one.LotsMin(),m_symbol_one.Name());
      else if(m_symbol_one.Bid()>price_highest_sell_one) // trend up
      m_trade.Sell(m_symbol_one.LotsMin(),m_symbol_one.Name());
      else if(count_buys_one==0 && count_sells_one==0)
         m_trade.Buy(m_symbol_one.LotsMin(),m_symbol_one.Name());

      if(m_symbol_two.Ask()<price_lowest_buy_two) // trend down
         m_trade.Buy(m_symbol_two.LotsMin(),m_symbol_two.Name());
      else if(m_symbol_two.Bid()>price_highest_sell_two) // trend up
      m_trade.Sell(m_symbol_two.LotsMin(),m_symbol_two.Name());
      else if(count_buys_two==0 && count_sells_two==0)
         m_trade.Buy(m_symbol_two.LotsMin(),m_symbol_two.Name());
     }
   else
     {
      if(m_account.Profit()>0.0)
         CloseAllPositions();
     }

//---
   CalculatePositions(count_buys_one,count_sells_one,count_buys_two,count_sells_two);
   Comment("count buys ",m_symbol_one.Name(),": ",count_buys_one,"\n",
           "count sells ",m_symbol_one.Name(),": ",count_sells_one,"\n",
           "count buys ",m_symbol_two.Name(),": ",count_buys_two,"\n",
           "count sells ",m_symbol_two.Name(),": ",count_sells_two);
   if(m_account.Equity()-m_account.Balance()>InpProfitFoClose)
      CloseAllPositions();
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(CSymbolInfo &m_symbol)
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
void CalculateProfitPositions(double &profit_buys_one,double &profit_sells_one,
                              double &profit_buys_two,double &profit_sells_two)
  {
   profit_buys_one   = 0.0;
   profit_sells_one  = 0.0;
   profit_buys_two   = 0.0;
   profit_sells_two  = 0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Magic()==m_magic)
            if(m_position.Symbol()==m_symbol_one.Name() || m_position.Symbol()==m_symbol_two.Name())
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_position.Symbol()==m_symbol_one.Name())
                     profit_buys_one+=m_position.Profit();
                  else if(m_position.Symbol()==m_symbol_two.Name())
                     profit_buys_two+=m_position.Profit();
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(m_position.Symbol()==m_symbol_one.Name())
                     profit_sells_one+=m_position.Profit();
                  else if(m_position.Symbol()==m_symbol_two.Name())
                     profit_sells_two+=m_position.Profit();
                 }
              }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
//m_trade.SetAsyncMode(true);
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Magic()==m_magic)
            if(m_position.Symbol()==m_symbol_one.Name() || m_position.Symbol()==m_symbol_two.Name())
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
//m_trade.SetAsyncMode(false);
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int  &count_buys_one,int  &count_sells_one,int  &count_buys_two,int  &count_sells_two)
  {
   count_buys_one = 0;
   count_sells_one= 0;
   count_buys_two = 0;
   count_sells_two= 0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Magic()==m_magic)
            if(m_position.Symbol()==m_symbol_one.Name() || m_position.Symbol()==m_symbol_two.Name())
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  if(m_position.Symbol()==m_symbol_one.Name())
                     count_buys_one++;
                  else if(m_position.Symbol()==m_symbol_two.Name())
                     count_buys_two++;
                 }

               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  if(m_position.Symbol()==m_symbol_one.Name())
                     count_sells_one++;
                  else if(m_position.Symbol()==m_symbol_two.Name())
                     count_sells_two++;
                 }
              }
//---
   return;
  }
//+------------------------------------------------------------------+
