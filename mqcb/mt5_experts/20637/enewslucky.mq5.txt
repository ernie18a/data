//+------------------------------------------------------------------+
//|                        e-News-Lucky(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
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
input double   InpLots           = 0.1;      // Lots
input ushort   InpStopLoss       = 50;       // Stop Loss (in pips)
input ushort   InpTakeProfit     = 150;      // Take Profit (in pips)
input ushort   InpTrailingStop   = 5;        // Trailing Stop (in pips)
input ushort   InpTrailingStep   = 5;        // Trailing Step (in pips)
input datetime InpTimeSet        = D'1970.01.01 10:30'; // Time of order placement (use only hh:mm !!!)
input datetime InpTimeDel        = D'1970.01.01 22:30'; // Time of order removal (use only hh:mm !!!)
input ushort   InpDistanceSet    = 20;       // Distance from market
input ulong    m_magic=15489;                // magic number
//---
ulong          m_slippage=10;                // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtTrailingStop=0.0;
double         ExtTrailingStep=0.0;
double         ExtDistanceSet=0.0;

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
MqlDateTime    STimeSet;                     // date type structure contains time "Time of order placement"
MqlDateTime    STimeDel;                     // date type structure contains time "Time of order removal"
bool           m_delete_orders=false;        // true -> you must delete all pending orders
bool           m_close_positions=false;      // true -> you must close all positions
bool           m_place_buy_stop=false;       // true -> you must place buy stop pending order
bool           m_place_sell_stop=false;      // true -> you must place sell stop pending order
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      Alert(__FUNCTION__," ERROR: Trailing is not possible: the parameter \"Trailing Step\" is zero!");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(__FUNCTION__,", ERROR: ",err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss       = InpStopLoss     * m_adjusted_point;
   ExtTakeProfit     = InpTakeProfit   * m_adjusted_point;
   ExtTrailingStop   = InpTrailingStop * m_adjusted_point;
   ExtTrailingStep   = InpTrailingStep * m_adjusted_point;
   ExtDistanceSet    = InpDistanceSet  * m_adjusted_point;
//---
   m_delete_orders=false;        // true -> you must delete all pending orders
   m_close_positions=false;      // true -> you must close all positions
   m_place_buy_stop=false;       // true -> you must place buy stop pending order
   m_place_sell_stop=false;      // true -> you must place sell stop pending order
   if(!TimeToStruct(InpTimeSet,STimeSet))
     {
      Print(__FUNCTION__,", ERROR TimeToStruct");
      return(INIT_FAILED);
     }
   if(!TimeToStruct(InpTimeDel,STimeDel))
     {
      Print(__FUNCTION__,", ERROR TimeToStruct");
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
//---
   if(m_delete_orders)
     {
      if(CalculateAllPendingOrders()==0)
         m_delete_orders=false;        // true -> you must delete all pending orders
      else
        {
         DeleteAllPendingOrders();
         return;
        }
     }
   if(m_close_positions)
     {
      if(CalculateAllPositions()==0)
         m_close_positions=false;      // true -> you must close all positions
      else
        {
         CloseAllPositions();
         return;
        }
     }
   if(m_place_buy_stop || m_place_sell_stop)
     {
      int count_buy_stop=0;
      int count_sell_stop=0;
      CalculatePendingOrders(count_buy_stop,count_sell_stop);
      if(count_buy_stop>0)
         m_place_buy_stop=false;       // true -> you must place buy stop pending order
      if(count_sell_stop>0)
         m_place_sell_stop=false;      // true -> you must place sell stop pending order
      //---
      if(m_place_buy_stop)
        {
         PlacePending(ORDER_TYPE_BUY_STOP);
         return;
        }
      if(m_place_sell_stop)
        {
         PlacePending(ORDER_TYPE_SELL_STOP);
         return;
        }
     }
//---
   MqlDateTime STimeCurrent;
   TimeToStruct(TimeCurrent(),STimeCurrent);
   if(STimeCurrent.hour==STimeSet.hour && STimeCurrent.min==STimeSet.min)
     {
      m_place_buy_stop=true;        // true -> you must place buy stop pending order
      m_place_sell_stop=true;       // true -> you must place sell stop pending order
      return;
     }
   if(STimeCurrent.hour==STimeDel.hour && STimeCurrent.min==STimeDel.min)
     {
      m_delete_orders=true;         // true -> you must delete all pending orders
      m_close_positions=true;       // true -> you must close all positions
      return;
     }
//---
   Trailing();
//---

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
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_ticket       =0;
      long     deal_order        =0;
      long     deal_time         =0;
      long     deal_time_msc     =0;
      long     deal_type         =-1;
      long     deal_entry        =-1;
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_position_id  =0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      string   deal_external_id  ="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket       =HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order        =HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time         =HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc     =HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type         =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_magic        =HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason       =HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id  =HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price        =HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission   =HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap         =HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit       =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);
        }
      else
         return;
      if(deal_reason!=-1)
         int d=0;;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
            if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
               m_delete_orders=true;         // true -> you must delete all pending orders
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
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
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
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
//| Calculate all pending orders                                     |
//+------------------------------------------------------------------+
int CalculateAllPendingOrders(void)
  {
   int total=0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Delete all pending orders                                        |
//+------------------------------------------------------------------+
void DeleteAllPendingOrders(void)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify BUY ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify SELL ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }

           }
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
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
//| Calculate BUY STOP and SELL STOP                                 |
//+------------------------------------------------------------------+
void CalculatePendingOrders(int &count_buy_stop,int &count_sell_stop)
  {
   count_buy_stop=0;
   count_sell_stop=0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
           {
            if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
               count_buy_stop++;

            if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
               count_sell_stop++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Place pending order                                              |
//+------------------------------------------------------------------+
void PlacePending(ENUM_ORDER_TYPE order_type)
  {
   if(order_type!=ORDER_TYPE_BUY_STOP && order_type!=ORDER_TYPE_SELL_STOP)
      return;
   if(!RefreshRates())
      return;
   double price=0.0;
   double sl   =0.0;
   double tp   =0.0;
//--- buy stop
   if(order_type==ORDER_TYPE_BUY_STOP)
     {
      price =m_symbol.Ask()+ExtDistanceSet;
      sl    =(InpStopLoss==0)?0.0:price-ExtStopLoss;
      tp    =(InpTakeProfit==0)?0.0:price+ExtTakeProfit;
     }
//--- sell stop
   if(order_type==ORDER_TYPE_SELL_STOP)
     {
      price =m_symbol.Bid()-ExtDistanceSet;
      sl    =(InpStopLoss==0)?0.0:price+ExtStopLoss;
      tp    =(InpTakeProfit==0)?0.0:price-ExtTakeProfit;
     }
   string text=StringSubstr(EnumToString(order_type),11);
//---
   if(m_trade.OrderOpen(m_symbol.Name(),
      (order_type==ORDER_TYPE_BUY_STOP)?ORDER_TYPE_BUY_STOP:ORDER_TYPE_SELL_STOP,
      InpLots,
      0.0,
      m_symbol.NormalizePrice(price),
      m_symbol.NormalizePrice(sl),
      m_symbol.NormalizePrice(tp)))
     {
      Print(text," - > true. ticket of order = ",m_trade.ResultOrder());
     }
   else
     {
      Print(text," - > false. Result Retcode: ",m_trade.ResultRetcode(),
            ", description of Retcode: ",m_trade.ResultRetcodeDescription(),
            ", ticket of order: ",m_trade.ResultOrder());
     }
  }
//+------------------------------------------------------------------+
