//+------------------------------------------------------------------+
//|                          Spreader 2(barabashkakvn's edition).mq5 |
//|                               Copyright © 2010, Yury V. Reshetov |
//|                                         http://spreader.heigh.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Yury V. Reshetov"
#property link      "http://spreader.heigh.ru"
#property version   "2.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol_current;             // symbol info object
CSymbolInfo    m_symbol_seconds;             // symbol info object
//--- input parameters
input string   InpSymbolSeconds  = "GBPUSD"; // Symbol seconds
input double   InpLots           = 1.0;      // Position volume for the current symbol
input double   InpProfit         = 100;      // Profit (in money)

ulong          m_slippage=30;                // slippage

static datetime prevtime=0;
static bool open_bar_price_only=true;
static int m_shift=30;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()!=PERIOD_M1)
     {
      Comment("Change timeframe for "+Symbol()+" to M1");
      return(INIT_PARAMETERS_INCORRECT);
     }
   Comment("");
   if(!m_symbol_current.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   if(!m_symbol_seconds.Name(InpSymbolSeconds)) // sets symbol name
      return(INIT_FAILED);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   prevtime=iTime(m_symbol_current.Name(),Period(),0);
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
   if((iTime(m_symbol_current.Name(),Period(),0)==prevtime) && open_bar_price_only)
      return;
   if(!IsTradeAllowed())
      return;
//---
   prevtime=iTime(m_symbol_current.Name(),Period(),0);

   ulong ticket_current= ULONG_MAX;
   ulong ticket_second = ULONG_MAX;

   ENUM_POSITION_TYPE pos_type_current=POSITION_TYPE_SELL; // direction of position for the current symbols
   ENUM_POSITION_TYPE pos_type_second=POSITION_TYPE_BUY;   // direction of position for the second symbols

   double profit_current=0;
   double volume_second=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         if(m_position.Symbol()==m_symbol_current.Name())
           {
            ticket_current = m_position.Ticket();
            profit_current = profit_current + m_position.Profit();
            pos_type_current=m_position.PositionType();
           }
         else if(m_position.Symbol()==m_symbol_seconds.Name())
           {
            ticket_second=m_position.Ticket();
            pos_type_second=m_position.PositionType();
            profit_current=profit_current+m_position.Profit();
            volume_second=m_position.Volume();
           }
        }

//---
   if(ticket_second==ULONG_MAX && ticket_current!=ULONG_MAX)
     {
      Comment("Try close positon for "+m_symbol_current.Name());
      if(m_trade.PositionClose(ticket_current))
         open_bar_price_only=true;
      return;
     }

   if(ticket_second!=ULONG_MAX && ticket_current!=ULONG_MAX)
     {
      open_bar_price_only=false;
      if(profit_current>InpProfit)
        {
         if(m_trade.PositionClose(ticket_second))
            open_bar_price_only=true;
         return;
        }
      //--- positions on both symbols are already open
      Comment("Positions for "+m_symbol_current.Name()+" and "+InpSymbolSeconds+" is open"+"\n"+
              "Total InpProfit: $"+DoubleToString(profit_current,2));
      return;
     }

   open_bar_price_only=true;

   if((ticket_second!=ULONG_MAX) && (ticket_current==ULONG_MAX))
     {
      Comment("Try open positon for "+m_symbol_current.Name());
      // open the position for the current symbol
      // in the opposite direction of the position of the second symbol
      if(pos_type_second==POSITION_TYPE_SELL)
        {
         if(m_trade.Buy(InpLots,m_symbol_current.Name()))
            if(m_trade.ResultDeal()!=0.0)
               ticket_current=m_trade.ResultDeal();
        }
      else
        {
         if(m_trade.Sell(InpLots,m_symbol_current.Name()))
            if(m_trade.ResultDeal()!=0.0)
               ticket_current=m_trade.ResultDeal();
        }
      return;
     }

   if(m_symbol_current.ContractSize()!=m_symbol_seconds.ContractSize())
     {
      Alert("Contracts size not equals. Change instruments");
      return;
     }

//--- we are looking for the first differences for two periods of both symbols
   double close_cur_0=iClose(m_symbol_current.Name(),Period(),0);
   double close_cur_period=iClose(m_symbol_current.Name(),Period(),m_shift);
   double close_cur_period_multiply_two=iClose(m_symbol_current.Name(),Period(),m_shift*2);
   if(close_cur_0==0.0 || close_cur_period==0.0 || close_cur_period_multiply_two==0.0)
      return;

   double close_sec_0=iClose(m_symbol_seconds.Name(),Period(),0);
   double close_sec_period=iClose(m_symbol_seconds.Name(),Period(),m_shift);
   double close_sec_period_multiply_two=iClose(m_symbol_seconds.Name(),Period(),m_shift*2);
   if(close_sec_0==0.0 || close_sec_period==0.0 || close_sec_period_multiply_two==0.0)
      return;

   double x1 = close_cur_0 - close_cur_period;
   double x2 = close_cur_period - close_cur_period_multiply_two;
   double y1 = close_sec_0 - close_sec_period;
   double y2 = close_sec_period - close_sec_period_multiply_two;

//--- looking for conditions for correlation
   if((x1*x2)>0)
     {
      // in both sections the unidirectional trend
      // correlations can not be calculated
      Comment(m_symbol_current.Name()+" trend found");
      return;
     }

   if((y1*y2)>0)
     {
      // in both sections the unidirectional trend
      // correlations can not be calculated
      Comment(InpSymbolSeconds+" trend found");
      return;
     }

//--- direction of position for the current symbol
   if(x1*y1>0)
     {
      //--- we are dealing with a positive correlation
      double a = MathAbs(x1) + MathAbs(x2);
      double b = MathAbs(y1) + MathAbs(y2);

      if(a/b>3.0)
         return;

      if(a/b<0.3)
         return;

      //--- volume of the position for the second symbol
      volume_second=LotCheck(a*InpLots/b);
      if(volume_second==0.0)
         return;

      //--- consider the ranges in the last 24 hours
      double close_cur_1440=iClose(m_symbol_current.Name(),Period(),1440);
      double close_sec_1440=iClose(m_symbol_seconds.Name(),Period(),1440);
      if(close_cur_1440==0.0 || close_sec_1440==0.0)
         return;

      double x3 = close_cur_0 - close_cur_1440;
      double y3 = close_sec_0 - close_sec_1440;

      //--- choose the direction of the positions for the symbol
      if(x1*b>y1*a)
        {
         //--- additional check in the last 24 hours
         if(x3*b<y3*a)
           {
            Comment("False testimony");
            return; // false signal
           }
         pos_type_current=POSITION_TYPE_BUY;
        }
      else
        {
         //--- additional check in the last 24 hours
         if(x3*b>y3*a)
           {
            Comment("False testimony");
            return;  // false signal
           }
        }
     }
   else
     {
      //--- we are dealing with a negative correlation
      Comment("Negative correlation found");
      return;
     }

//--- opOpen the position for the second symbol
   if(pos_type_current==POSITION_TYPE_SELL)
     {
      if(m_trade.Buy(volume_second,m_symbol_seconds.Name()))
         if(m_trade.ResultDeal()!=0.0)
            ticket_second=m_trade.ResultDeal();
     }
   else
     {
      if(m_trade.Sell(volume_second,m_symbol_seconds.Name()))
         if(m_trade.ResultDeal()!=0.0)
            ticket_second=m_trade.ResultDeal();
     }

   if(ticket_second!=ULONG_MAX)
      open_bar_price_only=false;
//---
   return;
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
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol_current.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol_seconds.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol_seconds.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol_seconds.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
