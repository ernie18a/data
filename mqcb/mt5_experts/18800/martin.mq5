//+------------------------------------------------------------------+
//|                              Martin(barabashkakvn's edition).mq5 |
//|                           Copyright © 2011, Skype:  mqlcmillion  |
//|                                         http://cmillion.narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Skype:  mqlcmillion "
#property link      "http://cmillion.narod.ru"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
COrderInfo     m_order;                      // pending orders object
//--- input parameters
input ushort   InpStep=10;
input double   InpProfitClose    = 5.0;
input double   InpLot            = 0.01;
ulong          m_magic=118203574;            // magic number
ulong          m_slippage=30;                // slippage
//---
double         ExtStep=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("Старт советника ",TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS));
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLot,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(m_symbol.Name(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(m_symbol.Name(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStep=InpStep*m_adjusted_point;
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
/*
   You need to find the last open position and its characteristics:
      - opening price
      - InpLot
      - position type
   It is also necessary to calculate the total profit of all positions
*/

   datetime             last_position_time         = 0;
   double               last_position_price_open   = 0.0;
   double               last_position_volume       = 0.0;
   ENUM_POSITION_TYPE   last_position_type         = -1;
   int                  count_positions            = 0;
   double               total_profit               = 0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.Time()>last_position_time)
              {
               last_position_time         = m_position.Time();
               last_position_price_open   = m_position.PriceOpen();
               last_position_volume       = m_position.Volume();
               last_position_type         = m_position.PositionType();
              }
            count_positions++;
            total_profit=total_profit+m_position.Commission()+m_position.Swap()+m_position.Profit();
           }

   int count_pending_orders=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            count_pending_orders++;

//Comment("Total profit ",DoubleToString(total_profit,2));
   if(total_profit>InpProfitClose)
     {
      Print("total_profit: ",DoubleToString(total_profit,2));
      CloseAllPositions();
      return;
     }

   if(!RefreshRates())
      return;

   if(count_positions>0)
     {
      if(last_position_type==POSITION_TYPE_BUY && m_symbol.Bid()+count_positions*ExtStep<last_position_price_open)
         m_trade.Sell(last_position_volume*2,m_symbol.Name());

      if(last_position_type==POSITION_TYPE_SELL && m_symbol.Ask()-count_positions*ExtStep>last_position_price_open)
         m_trade.Buy(last_position_volume*2,m_symbol.Name());
     }

   if(count_positions==0 && count_pending_orders==0)
     {
      m_trade.SellStop(InpLot,m_symbol.Bid()-10.0*m_symbol.Point());
      m_trade.BuyStop(InpLot,m_symbol.Ask()+10.0*m_symbol.Point());
      return;
     }

   if(count_positions>0 && count_pending_orders>0)
      DeleteAllOrders();
//---
   return;
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
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
// double min_volume=m_symbol.LotsMin();
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
// double max_volume=m_symbol.LotsMax();
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
// double volume_step=m_symbol.LotsStep();
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
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
//| Delete all pending rders                                         |
//+------------------------------------------------------------------+
void DeleteAllOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
