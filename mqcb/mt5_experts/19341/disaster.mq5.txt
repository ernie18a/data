//+------------------------------------------------------------------+
//|                            Disaster(barabashkakvn's edition).mq5 |
//|                                                         Max Fade |
//+------------------------------------------------------------------+
#property copyright "Max Fade"
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
input ushort   InpStopLoss    = 35;          // Stop Loss (in pips)
input ushort   InpTakeProfit  = 95;          // Take Profit (in pips)
input ushort   InpTrailingStep= 3;           // Trailing Step (in pips)
input ushort   InpDistance    = 14;          // Distance from MA for setting a pending order (in pips)
input ushort   InpTimeOut     = 180;         // Timeout (sec)
input ulong    m_magic=195536760;            // magic number
//---
ulong          m_slippage=30;                // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStep=0.0;
double         ExtDistance=0.0;

int            handle_iMA;                   // variable for storing the handle of the iMA indicator 
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
datetime       m_last_trade_modify;
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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss    = InpStopLoss     * m_adjusted_point;
   ExtTakeProfit  = InpTakeProfit   * m_adjusted_point;
   ExtTrailingStep= InpTrailingStep * m_adjusted_point;
   ExtDistance    = InpDistance     * m_adjusted_point;

//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),PERIOD_M1,590,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
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
   if(Bars(m_symbol.Name(),Period())<590+5)
      return;
//--- we work with the interval "Time out"
   static datetime prev_time=0;
   datetime time_current=TimeCurrent();
   if(time_current-prev_time<InpTimeOut)
      return;
   prev_time=time_current;

   double ima=iMAGet(1);
   if(ima==0.0 || !RefreshRates())
     {
      prev_time-=InpTimeOut+3;
      return;
     }
   if(m_symbol.Ask()-ima>ExtDistance)
      DeleteOrders(ORDER_TYPE_SELL_STOP);
   else if(ima-m_symbol.Bid()>ExtDistance)
      DeleteOrders(ORDER_TYPE_BUY_STOP);
//---
   int total_pending_orders=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            total_pending_orders++;
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
              {
               //--- if the current price is higher than the Moving Average on "Distance from MA for setting a pending order"
               if(m_order.PriceCurrent()-ima>ExtDistance)
                 {
                  if(m_order.PriceOpen()-m_order.PriceCurrent()<ExtTrailingStep)
                    {
                     double new_price_buy_stop=m_order.PriceOpen()+ExtTrailingStep;
                     m_trade.OrderModify(m_order.Ticket(),
                                         m_symbol.NormalizePrice(new_price_buy_stop),
                                         m_symbol.NormalizePrice(new_price_buy_stop-ExtStopLoss),
                                         m_symbol.NormalizePrice(new_price_buy_stop+ExtTakeProfit),
                                         m_order.TypeTime(),
                                         m_order.TimeExpiration());
                    }
                 }
              }
            else if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
              {
               //--- if the current price is below than the Moving Average on "Distance from MA for setting a pending order"
               if(ima-m_order.PriceCurrent()>ExtDistance)
                 {
                  if(m_order.PriceCurrent()-m_order.PriceOpen()<ExtTrailingStep)
                    {
                     double new_price_sell_stop=m_order.PriceOpen()-ExtTrailingStep;
                     m_trade.OrderModify(m_order.Ticket(),
                                         m_symbol.NormalizePrice(new_price_sell_stop),
                                         m_symbol.NormalizePrice(new_price_sell_stop+ExtStopLoss),
                                         m_symbol.NormalizePrice(new_price_sell_stop-ExtTakeProfit),
                                         m_order.TypeTime(),
                                         m_order.TimeExpiration());
                    }
                 }
              }
           }
//---
   if(total_pending_orders==0)
     {
      if(m_symbol.Ask()-ima>ExtDistance)
         m_trade.BuyStop(m_symbol.LotsMin(),m_symbol.NormalizePrice(m_symbol.Ask()+ExtTrailingStep));
      else if(ima-m_symbol.Bid()>ExtDistance)
         m_trade.SellStop(m_symbol.LotsMin(),m_symbol.NormalizePrice(m_symbol.Bid()-ExtTrailingStep));
     }
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
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
