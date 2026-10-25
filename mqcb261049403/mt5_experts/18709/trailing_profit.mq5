//+------------------------------------------------------------------+
//|                     Trailing_Profit(barabashkakvn's edition).mq5 |
//|                     Copyright © 2008, Демёхин Виталий Евгеньевич |
//|                                             vitalya_1983@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Демёхин Виталий Евгеньевич"
#property link      "vitalya_1983@list.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
//--- input parameters
input double percent_of_profit   = 33;
input double minimum_profit      = 1000;
//---
ulong          m_slippage=30;                // slippage
double         m_lot=0.0;
double m_profit=0.0,m_profit_off=0.0,m_final_result=0.0;
bool m_trail_enable=false,m_close_start=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   m_profit_off=0.0;
   m_final_result=0.0;
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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- allow work every three seconds
   static datetime prev_time=0;
   datetime time_current=TimeCurrent();
   if(time_current-prev_time<3)
      return;
   prev_time=time_current;
//---
   if(m_close_start)
     {
      m_final_result+=CloseAllPositions();
      //m_close_start=false;
      //return;
     }
//---
   int      total_positions= 0;
   double   total_profit   = 0.0;
   CalculatePositionsAndProfit(total_positions,total_profit);

   if(m_close_start && total_positions==0)
     {
      Alert("The adviser closed the positions with the m_final_result ",DoubleToString(m_final_result,2));
      m_profit=0.0;
      m_profit_off=0.0;
      m_final_result=0.0;
      m_trail_enable=false;
      m_close_start=false;

      //      m_trail_enable=false;
      //      m_close_start=false;
      //      
      //      m_profit_off=0.0;
      //      m_final_result=0.0;
      return;
     }
//---
   if(!m_trail_enable && total_positions!=0)
     {
      Comment("Tracking mode is off.",
              "\n",
              "The advisor will begin to accompany the positions with m_profit growth up to ",
              DoubleToString(minimum_profit,2),
              ", сurrent m_profit ",DoubleToString(total_profit,2));
     }
//---
   if((m_profit_off==0.0 && minimum_profit<total_profit) || 
      (m_profit_off!=0.0 && m_profit_off<total_profit-total_profit*(percent_of_profit/100)))
     {
      m_trail_enable=true;
      m_profit_off=total_profit-total_profit*(percent_of_profit/100);
      Comment("Tracking mode enabled.",
              "\n",
              "The adviser will close positions at falling of m_profit up to ",
              DoubleToString(m_profit_off,2),
              ", maximum m_profit ",DoubleToString(total_profit,2));
     }
//---
   if(m_trail_enable && m_profit_off>total_profit)
      m_close_start=true;

  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
double CloseAllPositions()
  {
   double res=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
        {
         //if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
         //  {
         double temp_res=m_position.Commission()+m_position.Swap()+m_position.Profit();
         if(m_trade.PositionClose(m_position.Ticket())) // close a position by the specified symbol
            res=res+temp_res;
         //}
        }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Calculate positions and profit                                   |
//+------------------------------------------------------------------+
void CalculatePositionsAndProfit(int &total_positions,double &total_profit)
  {
   total_positions=0;
   total_profit=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         //if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
         //  {
         total_positions++;
         total_profit=total_profit+m_position.Commission()+m_position.Swap()+m_position.Profit();
         //}
        }
//---
   return;
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
