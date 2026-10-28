//+------------------------------------------------------------------+
//|                                                    LineTable.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.007"
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#define EQUAL 0
#define LESS -1
#define MORE 1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SORT_TYPE
  {
   SORT_BY_UP,
   SORT_BY_DOWN,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLineTable : public CObject
  {
private:
   double            m_price;             // position price
   ulong             m_ticket;            // position ticket
public:
                     CLineTable();
                    ~CLineTable();
   //---
                     CLineTable(double price,ulong ticket)
     {
      m_price=price;
      m_ticket=ticket;
     }
   double            Price()                                const { return m_price;    }
   ulong             Ticket()                               const { return m_ticket;   }
   virtual int       Compare(const CObject *node,const int mode=0) const
     {
      const CLineTable *line=node;
      switch(mode)
        {
         case SORT_BY_UP:
           {
            if(line.Price()==this.Price())
               return EQUAL;
            else
               if(line.Price()>this.Price())
                  return MORE;
               else
                  return LESS;
           }
         case SORT_BY_DOWN:
           {
            if(line.Price()==this.Price())
               return EQUAL;
            else
               if(line.Price()<this.Price())
                  return MORE;
               else
                  return LESS;
           }
        }
      return EQUAL;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLineTable::CLineTable()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLineTable::~CLineTable()
  {
  }
//+------------------------------------------------------------------+
//|                                               TradingEngine4.mqh |
//|                              Copyright © 2021, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "4.002"
#property description "barabashkakvn Class Trading engine 4.002"
#property description "Take Profit in Points (1.00055-1.00045=10 points)"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
//+------------------------------------------------------------------+
//| Class CTradingEngine4                                           |
//| Appointment: Class Expert Advisor.                               |
//|              Derives from class CObject.                         |
//+------------------------------------------------------------------+
class CTradingEngine4 : public CObject
  {
protected:
   CPositionInfo           m_position;                   // object of CPositionInfo class
   CTrade                  m_trade;                      // object of CTrade class
   CSymbolInfo             m_symbol;                     // object of CSymbolInfo class
   CAccountInfo            m_account;                    // object of CAccountInfo class
   //--- tables
   CArrayObj               m_table_buys;
   CArrayObj               m_table_sells;

   //---                "Trading settings"
   double                  m_take_profit;                // Take Profit             -> double
   //---                "Additional features"
   bool                    m_print_log;                  // Print log
   uchar                   m_freeze_coefficient;         // Coefficient (if Freeze==0 Or StopsLevels==0)
   ulong                   m_magic;                      // Magic number
   //---
   bool                    m_need_close_all;             // close all positions

private:

public:
                     CTradingEngine4();
                    ~CTradingEngine4();
   //--- Expert initialization function
   int               OnInit(string                 _TradeSymbol,
                            // "Trading settings"
                            uint                   _InpTakeProfit,               // Take Profit
                            // "Additional features"
                            uchar                  _InpFreezeCoefficient,        // Coefficient (if Freeze==0 Or StopsLevels==0)
                            bool                   _InpPrintLog,                 // Print log
                            ulong                  _InpDeviation,                // Deviation, in Points (1.00045-1.00055=10 points)
                            ulong                  _InpMagic                     // Magic number
                           );
   //--- Expert deinitialization function
   void              OnDeinit(const int reason);
   //--- Expert tick function
   void              OnTick();
   //--- delete take profit
   void              DeleteTakeProfit(const ENUM_POSITION_TYPE pos_type,bool &arr_check[]);
   //--- set take profit
   void              SetTakeProfit(const ENUM_POSITION_TYPE pos_type,bool &arr_check[]);
   //--- breakeven
   void              Breakeven(const ENUM_POSITION_TYPE pos_type,bool &arr_check[]);
   //---
   void              UpdateCheckGroups(string &array_buys[],string &array_sells[]/*,bool &arr_check_buys[],bool &arr_check_sells[]*/);

protected:
   //--- Refreshes the symbol quotes data
   bool              RefreshRates(void);
   //--- Check Freeze and Stops levels
   void              FreezeStopsLevels(double &freeze,double &stops);
   //--- Trailing
   void              Trailing(void);
   //--- Print CTrade result
   void              PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position);
   //--- Close positions
   void              ClosePositions(const ENUM_POSITION_TYPE pos_type);
   //--- Calculate all positions
   void              CalculateAllPositions(int &count_buys,double &volume_buys,double &volume_biggest_buys,
                                           int &count_sells,double &volume_sells,double &volume_biggest_sells,
                                           bool lots_limit=false);
   //--- Is position exists
   bool              IsPositionExists(void);
   //--- Close all positions
   void              CloseAllPositions(void);
   //--- Compare doubles
   bool              CompareDoubles(double number1,double number2,int digits,double points);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradingEngine4::CTradingEngine4() :
   m_take_profit(0.0),                 // Take Profit             -> double
   m_print_log(false),                 // Print log
   m_freeze_coefficient(1),            // Coefficient (if Freeze==0 Or StopsLevels==0)
   m_magic(200),                       // Magic number
   m_need_close_all(false)             // close all positions
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradingEngine4::~CTradingEngine4()
  {
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int CTradingEngine4::OnInit(string                _TradeSymbol,
                            // "Trading settings"
                            uint                   _InpTakeProfit,               // Take Profit
                            // "Additional features"
                            uchar                  _InpFreezeCoefficient,        // Coefficient (if Freeze==0 Or StopsLevels==0)
                            bool                   _InpPrintLog,                 // Print log
                            ulong                  _InpDeviation,                // Deviation, in Points (1.00045-1.00055=10 points)
                            ulong                  _InpMagic                     // Magic number
                           )
  {
//--- forced initialization of variables
   /*m_stop_loss                = 0.0;      // Stop Loss                  -> double
   m_take_profit              = 0.0;      // Take Profit                -> double
   m_trailing_stop            = 0.0;      // Trailing Stop              -> double
   m_trailing_step            = 0.0;      // Trailing Step              -> double
   m_pending_indent           = 0.0;      // Pending: Indent            -> double
   m_pending_max_spread       = 0.0;      // Pending: Maximum spread    -> double
   m_need_close_all           = false;    // close all positions
   m_last_trailing            = 0;        // "0" -> D'1970.01.01 00:00';
   m_last_signal              = 0;        // "0" -> D'1970.01.01 00:00';
   m_prev_bars                = 0;        // "0" -> D'1970.01.01 00:00';
   m_last_deal_in             = 0;        // "0" -> D'1970.01.01 00:00';
   m_bar_current              = 0;
   m_need_delete_all          = false;    // delete all pending orders
   m_waiting_pending_order    = false;    // waiting for a pending order
   m_init_error               = false;    // error on InInit*/
//---
   ResetLastError();
   if(!m_symbol.Name(_TradeSymbol)) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_take_profit              = _InpTakeProfit              * m_symbol.Point();
//---
   m_freeze_coefficient       = (_InpFreezeCoefficient>0)?_InpFreezeCoefficient:1;
   m_print_log                = _InpPrintLog;
   m_magic                    = _InpMagic;
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(_InpDeviation);
//--- tables
   m_table_buys.Sort(SORT_BY_UP);
   m_table_sells.Sort(SORT_BY_DOWN);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void CTradingEngine4::OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void CTradingEngine4::OnTick(void)
  {
//---
   if(m_need_close_all)
     {
      if(IsPositionExists())
        {
         CloseAllPositions();
         return;
        }
      else
        {
         m_need_close_all=false;
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Delete TakeProfit                                                |
//+------------------------------------------------------------------+
void CTradingEngine4::DeleteTakeProfit(const ENUM_POSITION_TYPE pos_type,bool &arr_check[])
  {
   if(pos_type==POSITION_TYPE_BUY)
     {
      int total=m_table_buys.Total();
      total=(total>5)?5:total;
      for(int i=0; i<total; i++)
        {
         if(arr_check[i])
           {
            CLineTable *line=m_table_buys.At(i);
            ulong ticket=line.Ticket();
            if(m_position.SelectByTicket(ticket)) // selects the position by ticket for further access to its properties
              {
               double stop_loss     = m_position.StopLoss();
               double take_profit   = m_position.TakeProfit();
               if(take_profit>0.0)
                  m_trade.PositionModify(ticket,stop_loss,0.0);
              }
           }
        }
     }
   else
     {
      int total=m_table_sells.Total();
      total=(total>5)?5:total;
      for(int i=0; i<total; i++)
        {
         if(arr_check[i])
           {
            CLineTable *line=m_table_sells.At(i);
            ulong ticket=line.Ticket();
            if(m_position.SelectByTicket(ticket)) // selects the position by ticket for further access to its properties
              {
               double stop_loss     = m_position.StopLoss();
               double take_profit   = m_position.TakeProfit();
               if(take_profit>0.0)
                  m_trade.PositionModify(ticket,stop_loss,0.0);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Set TakeProfit                                                   |
//+------------------------------------------------------------------+
void CTradingEngine4::SetTakeProfit(const ENUM_POSITION_TYPE pos_type,bool &arr_check[])
  {
   if(pos_type==POSITION_TYPE_BUY)
     {
      int total=m_table_buys.Total();
      total=(total>5)?5:total;
      for(int i=0; i<total; i++)
        {
         if(arr_check[i])
           {
            CLineTable *line=m_table_buys.At(i);
            ulong ticket=line.Ticket();
            if(m_position.SelectByTicket(ticket)) // selects the position by ticket for further access to its properties
              {
               double price_current = m_position.PriceCurrent();
               double price_open    = m_position.PriceOpen();
               double stop_loss     = m_position.StopLoss();
               double take_profit   = m_position.TakeProfit();
               double new_tp        = price_open+m_take_profit;
               if(new_tp>price_current)
                  if(!CompareDoubles(take_profit,new_tp,m_symbol.Digits(),m_symbol.Point()))
                     m_trade.PositionModify(ticket,stop_loss,new_tp);
              }
           }
        }
     }
   else
     {
      int total=m_table_sells.Total();
      total=(total>5)?5:total;
      for(int i=0; i<total; i++)
        {
         if(arr_check[i])
           {
            CLineTable *line=m_table_sells.At(i);
            ulong ticket=line.Ticket();
            if(m_position.SelectByTicket(ticket)) // selects the position by ticket for further access to its properties
              {
               double price_current = m_position.PriceCurrent();
               double price_open    = m_position.PriceOpen();
               double stop_loss     = m_position.StopLoss();
               double take_profit   = m_position.TakeProfit();
               double new_tp        = price_open-m_take_profit;
               if(new_tp<price_current)
                  if(!CompareDoubles(take_profit,new_tp,m_symbol.Digits(),m_symbol.Point()))
                     m_trade.PositionModify(ticket,stop_loss,new_tp);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Breakeven                                                        |
//+------------------------------------------------------------------+
void CTradingEngine4::Breakeven(const ENUM_POSITION_TYPE pos_type,bool &arr_check[])
  {
   double total_price_multiply_volume_buy    = 0.0;
   double total_volume_buy                   = 0.0;
   double net_price_buy                      = 0.0;
   int count_buys                            = 0;
   double total_price_multiply_volume_sell   = 0.0;
   double total_volume_sell                  = 0.0;
   double net_price_sell                     = 0.0;
   int count_sells                           = 0;
//double breakeven_price                    = 0.0;
//---
   if(pos_type==POSITION_TYPE_BUY)
     {
      int total=m_table_buys.Total();
      total=(total>5)?5:total;
      for(int i=0; i<total; i++)
        {
         if(arr_check[i])
           {
            CLineTable *line=m_table_buys.At(i);
            ulong ticket=line.Ticket();
            if(m_position.SelectByTicket(ticket)) // selects the position by ticket for further access to its properties
              {
               total_price_multiply_volume_buy+=m_position.PriceOpen()*m_position.Volume();
               total_volume_buy+=m_position.Volume();
               count_buys++;
              }
           }
        }
     }
   else
     {
      int total=m_table_sells.Total();
      total=(total>5)?5:total;
      for(int i=0; i<total; i++)
        {
         if(arr_check[i])
           {
            CLineTable *line=m_table_sells.At(i);
            ulong ticket=line.Ticket();
            if(m_position.SelectByTicket(ticket)) // selects the position by ticket for further access to its properties
              {
               total_price_multiply_volume_sell+=m_position.PriceOpen()*m_position.Volume();
               total_volume_sell+=m_position.Volume();
               count_sells++;
              }
           }
        }
     }
//---
   if(total_price_multiply_volume_buy!=0 && total_volume_buy!=0)
     {
      net_price_buy=total_price_multiply_volume_buy/total_volume_buy;
      /*HLineMove(0,m_hline_name_buy,net_price_buy);*/
      int total=m_table_buys.Total();
      total=(total>5)?5:total;
      for(int i=0; i<total; i++)
        {
         if(arr_check[i])
           {
            CLineTable *line=m_table_buys.At(i);
            ulong ticket=line.Ticket();
            if(m_position.SelectByTicket(ticket)) // selects the position by ticket for further access to its properties
              {
               double price_current = m_position.PriceCurrent();
               double stop_loss     = m_position.StopLoss();
               double take_profit   = m_position.TakeProfit();
               if(net_price_buy>price_current)
                  if(!CompareDoubles(take_profit,net_price_buy,m_symbol.Digits(),m_symbol.Point()))
                     m_trade.PositionModify(ticket,stop_loss,net_price_buy);
              }
           }
        }
     }
   /*else
      HLineMove(0,m_hline_name_buy);*/
   if(total_price_multiply_volume_sell!=0 && total_volume_sell!=0)
     {
      net_price_sell=total_price_multiply_volume_sell/total_volume_sell;
      /*HLineMove(0,m_hline_name_sell,net_price_sell);*/
      int total=m_table_sells.Total();
      total=(total>5)?5:total;
      for(int i=0; i<total; i++)
        {
         if(arr_check[i])
           {
            CLineTable *line=m_table_sells.At(i);
            ulong ticket=line.Ticket();
            if(m_position.SelectByTicket(ticket)) // selects the position by ticket for further access to its properties
              {
               double price_current = m_position.PriceCurrent();
               double stop_loss     = m_position.StopLoss();
               double take_profit   = m_position.TakeProfit();
               if(net_price_sell<price_current)
                  if(!CompareDoubles(take_profit,net_price_sell,m_symbol.Digits(),m_symbol.Point()))
                     m_trade.PositionModify(ticket,stop_loss,net_price_sell);
              }
           }
        }
     }
   /*else
      HLineMove(0,m_hline_name_sell);*/
  }
//+------------------------------------------------------------------+
//| Update CheckGroups                                               |
//+------------------------------------------------------------------+
void CTradingEngine4::UpdateCheckGroups(string &array_buys[],string &array_sells[]/*,bool &arr_check_buys[],bool &arr_check_sells[]*/)
  {
   m_table_buys.Clear();
   m_table_sells.Clear();
   int positions_total=PositionsTotal();
   for(int i=positions_total-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               m_table_buys.InsertSort(new CLineTable(m_position.PriceOpen(),m_position.Ticket()));
            else
               m_table_sells.InsertSort(new CLineTable(m_position.PriceOpen(),m_position.Ticket()));
           }
//--- buys
   int total=m_table_buys.Total();
   total=(total>5)?5:total;
   for(int i=0; i<total; i++)
     {
      CLineTable *line=m_table_buys.At(i);
      array_buys[i]=DoubleToString(line.Price(),m_symbol.Digits());
     }
   for(int i=total; i<5; i++)
     {
      array_buys[i]="---";
     }
//--- sells
   total=m_table_sells.Total();
   total=(total>5)?5:total;
   for(int i=0; i<total; i++)
     {
      CLineTable *line=m_table_sells.At(i);
      array_sells[i]=DoubleToString(line.Price(),m_symbol.Digits());
     }
   for(int i=total; i<5; i++)
     {
      array_sells[i]="---";
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool CTradingEngine4::RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: ","RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: ","Ask == 0.0 OR Bid == 0.0");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check Freeze and Stops levels                                    |
//+------------------------------------------------------------------+
void CTradingEngine4::FreezeStopsLevels(double &freeze,double &stops)
  {
//--- check Freeze and Stops levels
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------

   SYMBOL_TRADE_STOPS_LEVEL determines the number of points for minimum indentation of the
      StopLoss and TakeProfit levels from the current closing price of the open position
   ------------------------------------------------|------------------------------------------
   Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|------------------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid                        |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   ------------------------------------------------------------------------------------------
   */
   double coeff=(double)m_freeze_coefficient;
   if(!RefreshRates() || !m_symbol.Refresh())
      return;
//--- FreezeLevel -> for pending order and modification
   double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
   if(freeze_level==0.0)
      if(m_freeze_coefficient>0)
         freeze_level=(m_symbol.Ask()-m_symbol.Bid())*coeff;
//--- StopsLevel -> for TakeProfit and StopLoss
   double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(stop_level==0.0)
      if(m_freeze_coefficient>0)
         stop_level=(m_symbol.Ask()-m_symbol.Bid())*coeff;
//---
   freeze=freeze_level;
   stops=stop_level;
//---
   return;
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//|  _InpTrailingStop: min distance from price to Stop Loss          |
//+------------------------------------------------------------------+
void CTradingEngine4::Trailing(void)
  {
   /*if(m_trailing_stop==0)
      return;
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);*/
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------
   */
   /*for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() &&m_position.Magic()==m_magic)
           {
            double price_current = m_position.PriceCurrent();
            double price_open    = m_position.PriceOpen();
            double stop_loss     = m_position.StopLoss();
            double take_profit   = m_position.TakeProfit();
            double ask           = m_symbol.Ask();
            double bid           = m_symbol.Bid();
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(price_current-price_open>m_trailing_stop+m_trailing_step)
                  if(stop_loss<price_current-(m_trailing_stop+m_trailing_step))
                     if(m_trailing_stop>=freeze &&(take_profit-bid>=freeze || take_profit==0.0))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                                                   m_symbol.NormalizePrice(price_current-m_trailing_stop),
                                                   take_profit))
                           if(m_print_log)
                              Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify BUY ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                        if(m_print_log)
                          {
                           RefreshRates();
                           m_position.SelectByIndex(i);
                           PrintResultModify(m_trade,m_symbol,m_position);
                          }
                        continue;
                       }
              }
            else
              {
               if(price_open-price_current>m_trailing_stop+m_trailing_step)
                  if((stop_loss>(price_current+(m_trailing_stop+m_trailing_step))) || (stop_loss==0))
                     if(m_trailing_stop>=freeze &&ask-take_profit>=freeze)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                                                   m_symbol.NormalizePrice(price_current+m_trailing_stop),
                                                   take_profit))
                           if(m_print_log)
                              Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify SELL ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                        if(m_print_log)
                          {
                           RefreshRates();
                           m_position.SelectByIndex(i);
                           PrintResultModify(m_trade,m_symbol,m_position);
                          }
                       }
              }
           }*/
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void CTradingEngine4::PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position)
  {
   Print("File: ",__FILE__,", symbol: ",symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
   Print("Freeze Level: "+DoubleToString(symbol.FreezeLevel(),0),", Stops Level: "+DoubleToString(symbol.StopsLevel(),0));
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void CTradingEngine4::ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------
   */
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() &&m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  bool take_profit_level=((m_position.TakeProfit()!=0.0 &&m_position.TakeProfit()-m_position.PriceCurrent()>=freeze) || m_position.TakeProfit()==0.0);
                  bool stop_loss_level=((m_position.StopLoss()!=0.0 &&m_position.PriceCurrent()-m_position.StopLoss()>=freeze) || m_position.StopLoss()==0.0);
                  if(take_profit_level &&stop_loss_level)
                     if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                        if(m_print_log)
                           Print(__FILE__," ",__FUNCTION__,", ERROR: ","BUY PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  bool take_profit_level=((m_position.TakeProfit()!=0.0 &&m_position.PriceCurrent()-m_position.TakeProfit()>=freeze) || m_position.TakeProfit()==0.0);
                  bool stop_loss_level=((m_position.StopLoss()!=0.0 &&m_position.StopLoss()-m_position.PriceCurrent()>=freeze) || m_position.StopLoss()==0.0);
                  if(take_profit_level &&stop_loss_level)
                     if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                        if(m_print_log)
                           Print(__FILE__," ",__FUNCTION__,", ERROR: ","SELL PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
                 }
              }
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//|  'lots_limit=true' - only for 'if(m_symbol.LotsLimit()>0.0)'     |
//+------------------------------------------------------------------+
void CTradingEngine4::CalculateAllPositions(int &count_buys,double &volume_buys,double &volume_biggest_buys,
      int &count_sells,double &volume_sells,double &volume_biggest_sells,
      bool lots_limit=false)
  {
   count_buys  = 0;
   volume_buys   = 0.0;
   volume_biggest_buys  = 0.0;
   count_sells = 0;
   volume_sells  = 0.0;
   volume_biggest_sells = 0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() &&(lots_limit || (!lots_limit &&m_position.Magic()==m_magic)))
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               count_buys++;
               volume_buys+=m_position.Volume();
               if(m_position.Volume()>volume_biggest_buys)
                  volume_biggest_buys=m_position.Volume();
               continue;
              }
            else
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  count_sells++;
                  volume_sells+=m_position.Volume();
                  if(m_position.Volume()>volume_biggest_sells)
                     volume_biggest_sells=m_position.Volume();
                 }
           }
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool CTradingEngine4::IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() &&m_position.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CTradingEngine4::CloseAllPositions(void)
  {
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------
   */
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() &&m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               bool take_profit_level=(m_position.TakeProfit()!=0.0 &&m_position.TakeProfit()-m_position.PriceCurrent()>=freeze) || m_position.TakeProfit()==0.0;
               bool stop_loss_level=(m_position.StopLoss()!=0.0 &&m_position.PriceCurrent()-m_position.StopLoss()>=freeze) || m_position.StopLoss()==0.0;
               if(take_profit_level &&stop_loss_level)
                  if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                     if(m_print_log)
                        Print(__FILE__," ",__FUNCTION__,", ERROR: ","BUY PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               bool take_profit_level=(m_position.TakeProfit()!=0.0 &&m_position.PriceCurrent()-m_position.TakeProfit()>=freeze) || m_position.TakeProfit()==0.0;
               bool stop_loss_level=(m_position.StopLoss()!=0.0 &&m_position.StopLoss()-m_position.PriceCurrent()>=freeze) || m_position.StopLoss()==0.0;
               if(take_profit_level &&stop_loss_level)
                  if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                     if(m_print_log)
                        Print(__FILE__," ",__FUNCTION__,", ERROR: ","SELL PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
              }
           }
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CTradingEngine4::CompareDoubles(double number1,double number2,int digits,double points)
  {
   if(MathAbs(NormalizeDouble(number1-number2,digits))<=points)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\CheckGroupKVN.mqh>
#include <Controls\Label.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                    (13)     // indent from left (with allowance for border width)
#define INDENT_TOP                     (13)     // indent from top (with allowance for border width)
#define CONTROLS_GAP_X                 (4)      // gap by X coordinate
#define CONTROLS_GAP_Y                 (4)      // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                   (100)    // size by X coordinate
#define BUTTON_HEIGHT                  (19)     // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                    (150)    // size by X coordinate
#define CHECK_HEIGHT                   (93)     // size by Y coordinate
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   //--- buys
   CCheckGroup       m_check_group_border_buys; // CCheckGroup object
   CCheckGroup       m_check_group_label_buys;  // CCheckGroup object
   CLabel            m_label_buys;              // CLabel object
   CCheckGroup       m_check_group_buys;        // CCheckGroup object
   CButton           m_button_del_tp_buys;      // CButton object
   CButton           m_button_tp_points_buys;   // CButton object
   CButton           m_button_breakeven_buys;   // CButton object
   //--- sells
   CCheckGroup       m_check_group_border_sells;// CCheckGroup object
   CCheckGroup       m_check_group_label_sells; // CCheckGroup object
   CLabel            m_label_sells;             // CLabel object
   CCheckGroup       m_check_group_sells;       // CCheckGroup object
   CButton           m_button_del_tp_sells;     // CButton object
   CButton           m_button_tp_points_sells;  // CButton object
   CButton           m_button_breakeven_sells;  // CButton object
   //--- trading engine
   CTradingEngine4   m_trading_engine;          // CTradingEngine4 object

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- init
   virtual int       Init(const string TradeSymbol,
                          const uint   TakeProfit,             // Take Profit
                          const uchar  FreezeCoefficient,      // Coefficient (if Freeze==0 Or StopsLevels==0)
                          const bool   PrintLog,               // Print log
                          const ulong  Deviation,              // Deviation, in Points (1.00045-1.00055=10 points)
                          const ulong  Magic                   // Magic number
                         );

   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- update Check Groups
   void              UpdateCheckGroups(void);

protected:
   //--- create dependent controls
   //--- buys
   bool              CreateCheckGroupBorderBuys(void);
   bool              CreateCheckGroupLabelBuys(void);
   bool              CreateLabelBuys(void);
   bool              CreateCheckGroupBuys(void);
   bool              CreateButtonDelTPBuys(void);
   bool              CreateButtonTPPointsBuys(void);
   bool              CreateButtonBreakevenBuys(void);
   //--- sells
   bool              CreateCheckGroupBorderSells(void);
   bool              CreateCheckGroupLabelSells(void);
   bool              CreateLabelSells(void);
   bool              CreateCheckGroupSells(void);
   bool              CreateButtonDelTPSells(void);
   bool              CreateButtonTPPointsSells(void);
   bool              CreateButtonBreakevenSells(void);
   //--- handlers of the dependent controls events
   void              OnChangeCheckGroupBuys(void);
   void              OnChangeCheckGroupSells(void);
   void              OnClickButtonDelTPBuys(void);
   void              OnClickButtonDelTPSells(void);
   void              OnClickButtonTPPointsBuys(void);
   void              OnClickButtonTPPointsSells(void);
   void              OnClickButtonBreakevenBuys(void);
   void              OnClickButtonBreakevenSells(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CHANGE,m_check_group_buys,OnChangeCheckGroupBuys)
ON_EVENT(ON_CHANGE,m_check_group_sells,OnChangeCheckGroupSells)
ON_EVENT(ON_CLICK,m_button_del_tp_buys,OnClickButtonDelTPBuys)
ON_EVENT(ON_CLICK,m_button_del_tp_sells,OnClickButtonDelTPSells)
ON_EVENT(ON_CLICK,m_button_tp_points_buys,OnClickButtonTPPointsBuys)
ON_EVENT(ON_CLICK,m_button_tp_points_sells,OnClickButtonTPPointsSells)
ON_EVENT(ON_CLICK,m_button_breakeven_buys,OnClickButtonBreakevenBuys)
ON_EVENT(ON_CLICK,m_button_breakeven_sells,OnClickButtonBreakevenSells)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void)
  {
//Print(__FUNCTION__);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
//Print(__FUNCTION__);
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
//--- buys
   if(!CreateCheckGroupBorderBuys())
      return(false);
   if(!CreateCheckGroupLabelBuys())
      return(false);
   if(!CreateLabelBuys())
      return(false);
   if(!CreateCheckGroupBuys())
      return(false);
   if(!CreateButtonDelTPBuys())
      return(false);
   if(!CreateButtonTPPointsBuys())
      return(false);
   if(!CreateButtonBreakevenBuys())
      return(false);
//--- sells
   if(!CreateCheckGroupBorderSells())
      return(false);
   if(!CreateCheckGroupLabelSells())
      return(false);
   if(!CreateCheckGroupSells())
      return(false);
   if(!CreateLabelSells())
      return(false);
   if(!CreateButtonDelTPSells())
      return(false);
   if(!CreateButtonTPPointsSells())
      return(false);
   if(!CreateButtonBreakevenSells())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
int CControlsDialog::Init(const string TradeSymbol,const uint TakeProfit,const uchar FreezeCoefficient,
                          const bool PrintLog,const ulong Deviation,const ulong Magic)
  {
   return(m_trading_engine.OnInit(TradeSymbol,TakeProfit,FreezeCoefficient,PrintLog,Deviation,Magic));
  }
//+------------------------------------------------------------------+
//| Update Check Groups                                              |
//+------------------------------------------------------------------+
void CControlsDialog::UpdateCheckGroups(void)
  {
   string arr_positions_buys[5],arr_positions_sells[5];
   bool   arr_check_buys[5],arr_check_sells[5];
   for(int i=0; i<5; i++)
     {
      arr_positions_buys[i]="";
      arr_positions_sells[i]="";
     }
   m_trading_engine.UpdateCheckGroups(arr_positions_buys,arr_positions_sells/*,arr_check_buys,arr_check_sells*/);
//---
   for(int i=0; i<5; i++)
     {
      m_check_group_buys.ItemUpdate(i,"BUY "+arr_positions_buys[i],1<<i);
      m_check_group_sells.ItemUpdate(i,"SELL "+arr_positions_sells[i],1<<i);
     }
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup Border Buys" element                      |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateCheckGroupBorderBuys(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;//;+2;
   int x2=x1+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X;
   int y2=y1+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y;//y1+INDENT_TOP+CHECK_HEIGHT;
//--- create
   if(!m_check_group_border_buys.Create(m_chart_id,m_name+"CheckGroup Border Buys",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_check_group_border_buys))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup Label Buys" element                       |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateCheckGroupLabelBuys(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+GROUP_WIDTH-BUTTON_WIDTH/2;
   int y1=CONTROLS_GAP_Y;//2+2;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_check_group_label_buys.Create(m_chart_id,m_name+"CheckGroup Label Buys",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_check_group_label_buys))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Label Buys" element                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabelBuys(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+GROUP_WIDTH-BUTTON_WIDTH/6;
   int y1=CONTROLS_GAP_Y;//2+2;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_label_buys.Create(m_chart_id,m_name+"Label Buys",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_buys.Text("Buys"))
      return(false);
   if(!Add(m_label_buys))
      return(false);
   m_label_buys.ColorBorder(clrRed);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup Buys" element                             |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateCheckGroupBuys(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+CONTROLS_GAP_X;
   int y1=INDENT_TOP*2;//CONTROLS_GAP_Y+BUTTON_HEIGHT+CONTROLS_GAP_Y-1;//INDENT_TOP*2+4;
   int x2=x1+GROUP_WIDTH;
   int y2=y1+CHECK_HEIGHT;
//--- create
   if(!m_check_group_buys.Create(m_chart_id,m_name+"CheckGroup Buys",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_check_group_buys))
      return(false);
//--- fill out with strings
   for(int i=0; i<5; i++)
      if(!m_check_group_buys.AddItem("---",1<<i))
         return(false);
   m_check_group_buys.Check(0,1<<0);
   m_check_group_buys.Check(2,1<<2);
   Comment(__FUNCTION__+" : Value="+IntegerToString(m_check_group_buys.Value()));
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button DelTPBuys" element                            |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonDelTPBuys(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP*2;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_del_tp_buys.Create(m_chart_id,m_name+"Button DelTPBuys",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_del_tp_buys.Text("Delete TP"))
      return(false);
   if(!Add(m_button_del_tp_buys))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button TPPointsBuys" element                         |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonTPPointsBuys(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP*2+CONTROLS_GAP_Y+BUTTON_HEIGHT;
   int x2=x1+GROUP_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_tp_points_buys.Create(m_chart_id,m_name+"Button TPPointsBuys",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_tp_points_buys.Text("TP from PriceOpen"))
      return(false);
   if(!Add(m_button_tp_points_buys))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button BreakevenBuys" element                        |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonBreakevenBuys(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP*2+(CONTROLS_GAP_Y+BUTTON_HEIGHT)*2;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_breakeven_buys.Create(m_chart_id,m_name+"Button BreakevenBuys",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_breakeven_buys.Text("Breakeven"))
      return(false);
   if(!Add(m_button_breakeven_buys))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup Border Sells" element                     |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateCheckGroupBorderSells(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y+INDENT_TOP-1;//;+2;
   int x2=x1+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X;
   int y2=y1+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y;//y1+INDENT_TOP+CHECK_HEIGHT;
//--- create
   if(!m_check_group_border_sells.Create(m_chart_id,m_name+"CheckGroup Border Sells",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_check_group_border_sells))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup Label Sells" element                      |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateCheckGroupLabelSells(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+GROUP_WIDTH-BUTTON_WIDTH/2;
   int y1=INDENT_TOP+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y+CONTROLS_GAP_Y-1;//2+2;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_check_group_label_sells.Create(m_chart_id,m_name+"CheckGroup Label Sells",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_check_group_label_sells))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Label Sells" element                                 |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabelSells(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+GROUP_WIDTH-BUTTON_WIDTH/6;
   int y1=INDENT_TOP+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y+CONTROLS_GAP_Y-1;//2+2;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_label_sells.Create(m_chart_id,m_name+"Label Sells",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_sells.Text("Sells"))
      return(false);
   if(!Add(m_label_sells))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CheckGroup Sells" element                            |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateCheckGroupSells(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+CONTROLS_GAP_X;
   int y1=INDENT_TOP+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y+INDENT_TOP+INDENT_TOP-1;
   int x2=x1+GROUP_WIDTH;
   int y2=y1+CHECK_HEIGHT;
//--- create
   if(!m_check_group_sells.Create(m_chart_id,m_name+"CheckGroup Sells",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_check_group_sells))
      return(false);
//--- fill out with strings
   for(int i=0; i<5; i++)
      if(!m_check_group_sells.AddItem("---",1<<i))
         return(false);
   m_check_group_sells.Check(0,1<<0);
   m_check_group_sells.Check(2,1<<2);
//Comment(__FUNCTION__+" : Value="+IntegerToString(m_check_group_sells.Value()));
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button DelTPSells" element                           |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonDelTPSells(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y+INDENT_TOP+INDENT_TOP-1;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_del_tp_sells.Create(m_chart_id,m_name+"Button DelTPSells",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_del_tp_sells.Text("Delete TP"))
      return(false);
   if(!Add(m_button_del_tp_sells))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button TPPointsSells" element                        |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonTPPointsSells(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y+INDENT_TOP+INDENT_TOP-1+CONTROLS_GAP_Y+BUTTON_HEIGHT;
   int x2=x1+GROUP_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_tp_points_sells.Create(m_chart_id,m_name+"Button TPPointsSells",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_tp_points_sells.Text("TP from PriceOpen"))
      return(false);
   if(!Add(m_button_tp_points_sells))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button BreakevenSells" element                       |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonBreakevenSells(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+CONTROLS_GAP_X+GROUP_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP+INDENT_TOP+CHECK_HEIGHT+CONTROLS_GAP_Y+INDENT_TOP+INDENT_TOP-1+(CONTROLS_GAP_Y+BUTTON_HEIGHT)*2;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_breakeven_sells.Create(m_chart_id,m_name+"Button BreakevenSells",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_breakeven_sells.Text("Breakeven"))
      return(false);
   if(!Add(m_button_breakeven_sells))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeCheckGroupBuys(void)
  {
//Comment(__FUNCTION__+" : Value="+IntegerToString(m_check_group_buys.Value()));
   /*long value=m_check_group_buys.Value();
   string text=__FUNCTION__+" : Value="+IntegerToString(value);
   for(int i=0; i<5; i++)
     {
      int res=m_check_group_buys.Check(i);
      string check=(res)?" check ":" uncheck ";
      text=text+"\r\n"+IntegerToString(i)+check;
     }
   Comment(text);*/
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnChangeCheckGroupSells(void)
  {
//Comment(__FUNCTION__+" : Value="+IntegerToString(m_check_group_sells.Value()));
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonDelTPBuys(void)
  {
//Comment(__FUNCTION__);
   bool arr_check_buys[5];
   for(int i=0; i<5; i++)
      arr_check_buys[i]=m_check_group_buys.Check(i);
   m_trading_engine.DeleteTakeProfit(POSITION_TYPE_BUY,arr_check_buys);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonDelTPSells(void)
  {
//Comment(__FUNCTION__);
   bool arr_check_sells[5];
   for(int i=0; i<5; i++)
      arr_check_sells[i]=m_check_group_sells.Check(i);
   m_trading_engine.DeleteTakeProfit(POSITION_TYPE_SELL,arr_check_sells);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonTPPointsBuys(void)
  {
//Comment(__FUNCTION__);
   bool arr_check_buys[5];
   for(int i=0; i<5; i++)
      arr_check_buys[i]=m_check_group_buys.Check(i);
   m_trading_engine.SetTakeProfit(POSITION_TYPE_BUY,arr_check_buys);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonTPPointsSells(void)
  {
//Comment(__FUNCTION__);
   bool arr_check_sells[5];
   for(int i=0; i<5; i++)
      arr_check_sells[i]=m_check_group_sells.Check(i);
   m_trading_engine.SetTakeProfit(POSITION_TYPE_SELL,arr_check_sells);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonBreakevenBuys(void)
  {
//Comment(__FUNCTION__);
   bool arr_check_buys[5];
   for(int i=0; i<5; i++)
      arr_check_buys[i]=m_check_group_buys.Check(i);
   m_trading_engine.Breakeven(POSITION_TYPE_BUY,arr_check_buys);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonBreakevenSells(void)
  {
//Comment(__FUNCTION__);
   bool arr_check_sells[5];
   for(int i=0; i<5; i++)
      arr_check_sells[i]=m_check_group_sells.Check(i);
   m_trading_engine.Breakeven(POSITION_TYPE_SELL,arr_check_sells);
  }
//+------------------------------------------------------------------+
//|                               Manual Position Tracking Panel.mq5 |
//|                              Copyright © 2021, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.007"
//--- Global Variable
CControlsDialog ExtDialog;
//--- input parameters
input group             "Trading settings"
input uint                 InpTakeProfit           = 460;            // Take Profit
input group             "Additional features"
input bool                 InpPrintLog             = true;           // Print log
input uchar                InpFreezeCoefficient    = 1;              // Coefficient (if Freeze==0 Or StopsLevels==0)
input ulong                InpDeviation            = 10;             // Deviation, in Points (1.00045-1.00055=10 points)
input ulong                InpMagic                = 304733189;      // Magic number
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create application dialog
   int shift_x=0,shift_y=0;
   bool one_click=ChartGetInteger(ChartID(),CHART_SHOW_ONE_CLICK,0);
   if(one_click)
     {
      shift_x=15;
      shift_y=62;
     }
   if(!ExtDialog.Create(ChartID(),"Manual Position Tracking Panel",0,40+shift_x,40+shift_y,386+shift_x,326+shift_y))
      return(INIT_FAILED);
   int init=ExtDialog.Init(Symbol(),
                           InpTakeProfit,
                           InpFreezeCoefficient,
                           InpPrintLog,
                           InpDeviation,
                           InpMagic
                          );
   if(init!=INIT_SUCCEEDED)
      return(init);
//--- run application
   ExtDialog.Run();
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ExtDialog.UpdateCheckGroups();
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID
                  const long&lparam,   // event parameter of the long type
                  const double&dparam, // event parameter of the double type
                  const string&sparam) // event parameter of the string type
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
