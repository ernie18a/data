//+------------------------------------------------------------------+
//|                Jims Close Positions(barabashkakvn's edition).mq5 |
//|                                             Jedimedic77@gmail.com|
//|             Origional Coding Before Chop Copyright © 2007, sx ted|
//|                                                                  |
//| Several Functions were removed from the origonal to speed it up  |
//| and K.I.S.S. its my first attempt at leaening MQL4 good luck guys|
//|                                                     Jim Malwitz  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input string   info           = "Select One of the Following:";   // -*-*-*-
input bool     CloseAll       = true;                             // close all positions
input bool     CloseAllProfit = false;                            // close only profit positions
input bool     CloseAllLoss   = false;                            // close only loss positions
//---
ulong          m_slippage=100;                              // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if((int)CloseAll+(int)CloseAllLoss+int(CloseAllProfit)>1)
     {
      string text="The value \"true\" can have ONLY one input parameter";
      Print(text);
      Comment(text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   Comment("");
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
//---
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
        {
         if(CloseAll)
            ClosePosition(m_position.Symbol()); // close a position by the specified symbo
         else if(CloseAllProfit)
           {
            if(m_position.Commission()+m_position.Swap()+m_position.Profit()>0.0)
               ClosePosition(m_position.Symbol()); // close a position by the specified symbo
           }
         else if(CloseAllLoss)
           {
            if(m_position.Commission()+m_position.Swap()+m_position.Profit()<0.0)
               ClosePosition(m_position.Symbol());  // close a position by the specified symbo
           }
        }
  }
//+------------------------------------------------------------------+
//| Close selected position                                          |
//+------------------------------------------------------------------+
void ClosePosition(const string symbol)
  {
   if(InitTrade(symbol))
      m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbo
  }
//+------------------------------------------------------------------+
//| Init trade object                                                |
//+------------------------------------------------------------------+
bool InitTrade(const string symbol)
  {
   if(!m_symbol.Name(symbol)) // sets symbol name
      return(false);
//---
   if(IsFillingTypeAllowed(symbol,SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(symbol,SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   return(true);
//---
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
