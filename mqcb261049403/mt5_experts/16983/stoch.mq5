//+------------------------------------------------------------------+
//|                               Stoch(barabashkakvn's edition).mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
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
input double InpTakeProfit = 57;             // Take Profit
input double Lots = 0.1;                     // Lots
input double InpStopLoss = 7;                // Stop Loss
//---
ulong  m_magic=8352076;                      // magic number
double ExtTakeProfit=0;
double ExtStopLoss=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   ExtTakeProfit=InpTakeProfit*digits_adjust;
   ExtStopLoss=InpStopLoss*digits_adjust;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double s = GlobalVariableGet("SELLLIMIT");
   double b = GlobalVariableGet("BUYLIMIT");
   double ds = GlobalVariableGet("DateS");
   double db = GlobalVariableGet("DateB");
//---
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
//---
   if(ds!=str1.day_of_week)
     {
      GlobalVariableDel("SELLLIMIT");
      GlobalVariableDel("BUYLIMIT");
      GlobalVariableDel("DatesS");
      GlobalVariableDel("DatesB");
     }
//---
   int total_pos=CountPositions();
   int total_orders=CountOrders();
   if((total_pos+total_orders)==0 && str1.hour==23 && str1.min==59)
      return;
//---
   if(total_pos>0 && str1.hour==23 && str1.min==59)
      DeleteAllPositions();

   if(total_orders>0 && str1.hour==23 && str1.min==59)
      DeleteAllOrders();

   double temp_h=iHigh(m_symbol.Name(),Period(),1);
   double temp_l=iLow(m_symbol.Name(),Period(),1);
   double temp_c=iClose(m_symbol.Name(),Period(),1);
   double H4,L4;
   H4 = (((temp_h - temp_l)*1.1) / 2.0) + temp_c;
   L4 = temp_c - ((temp_h - temp_l)*1.1) / 2.0;
//---
   if(db!=str1.day_of_week && s==0)
     {
      if(!m_trade.SellLimit(Lots,H4,m_symbol.Name(),
         H4+ExtStopLoss*Point(),
         H4-ExtTakeProfit*Point(),0,0,"H4"))
         GlobalVariableSet("SELLLIMIT",0);
      else
        {
         GlobalVariableSet("SELLLIMIT",1);
         GlobalVariableSet("DateS",str1.day_of_week);
        }
     }
//----
   if(db!=str1.day_of_week && b==0)
     {
      if(!m_trade.BuyLimit(Lots,L4,m_symbol.Name(),
         L4-ExtStopLoss*Point(),
         L4+ExtTakeProfit*Point(),0,0,"L4"))
         GlobalVariableSet("BUYLIMIT",0);
      else
        {
         GlobalVariableSet("BUYLIMIT",1);
         GlobalVariableSet("DateB",str1.day_of_week);
        }
     }
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
//|  Count All Positions                                             |
//+------------------------------------------------------------------+
int CountPositions()
  {
   int res=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            res++;
   return(res);
  }
//+------------------------------------------------------------------+
//| Count All Orders                                                 |
//+------------------------------------------------------------------+
int CountOrders()
  {
   int res=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==Symbol() && m_order.Magic()==m_magic)
            res++;
   return(res);
  }
//+------------------------------------------------------------------+
//| Delete All Positions                                             |
//+------------------------------------------------------------------+
void DeleteAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket());
  }
//+------------------------------------------------------------------+
//| Delete All Orders                                                |
//+------------------------------------------------------------------+
void DeleteAllOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--)
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==Symbol() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
