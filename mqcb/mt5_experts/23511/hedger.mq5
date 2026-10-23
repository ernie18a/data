//+------------------------------------------------------------------+
//|                                                       hedger.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//+------------------------------------------------------------------+
//| Enum Lor or Risk                                                 |
//+------------------------------------------------------------------+
enum ENUM_LOT_OR_RISK
  {
   lot=0,   // Constant lot
   risk=1,  // Risk in percent for a deal
  };
//--- input parameters
input ushort   InpDrawdownOpen   = 50;       // Drawdown (opening a hedge), in pips (1.00045-1.00055=1 pips)
input ushort   InpDrawdownClose  = 30;       // Drawdown (closing the hedge), in pips (1.00045-1.00055=1 pips)
input bool     InpPrintLog       = false;    // Print log
input ulong    m_magic=363193656;            // magic number
//---
ulong  m_slippage=10;                        // slippage
double ExtDrawdownOpen  = 0.0;               // Drawdown (opening a hedge) -> double
double ExtDrawdownClose = 0.0;               // Drawdown (closing the hedge) -> double
double m_adjusted_point;                     // point value adjusted for 3 or 5 points
bool   m_need_open_buy           = false;
bool   m_need_open_sell          = false;
bool   m_waiting_transaction     = false;    // "true" -> it's forbidden to trade, we expect a transaction
ulong  m_waiting_order_ticket    = 0;        // ticket of the expected order
bool   m_transaction_confirmed   = false;    // "true" -> transaction confirmed
double m_volume                  = 0.0;      // volume
string m_comment                 = "";       // comment
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
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtDrawdownOpen   = InpDrawdownOpen    * m_adjusted_point;
   ExtDrawdownClose  = InpDrawdownClose   * m_adjusted_point;
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
   if(m_waiting_transaction)
     {
      if(!m_transaction_confirmed)
        {
         Print("m_transaction_confirmed: ",m_transaction_confirmed);
         return;
        }
      else if(m_transaction_confirmed)
        {
         m_need_open_buy            = false;    // "true" -> need to open BUY
         m_need_open_sell           = false;    // "true" -> need to open SELL
         m_waiting_transaction      = false;    // "true" -> it's forbidden to trade, we expect a transaction
         m_waiting_order_ticket     = 0;        // ticket of the expected order
         m_transaction_confirmed    = false;    // "true" -> transaction confirmed
         m_volume                   = 0.0;      // volume
         m_comment                  = "";       // comment
        }
     }
   if(m_need_open_buy)
     {
      if(RefreshRates())
        {
         m_waiting_transaction=true;
         OpenBuy(0.0,0.0,m_comment);
        }
      return;
     }
   if(m_need_open_sell)
     {
      if(RefreshRates())
        {
         m_waiting_transaction=true;
         OpenSell(0.0,0.0,m_comment);
        }
      return;
     }
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }
//---
   int count_buys       = 0;
   int count_hedge_buys = 0;
   int count_sells      = 0;
   int count_hedge_sells= 0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.Comment()=="hedge_buy")
                  count_hedge_buys++;
               count_buys++;
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.Comment()=="hedge_sell")
                  count_hedge_sells++;
               count_sells++;
              }
           }
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(count_hedge_sells==0)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>=ExtDrawdownOpen)
                    {
                     m_volume          = m_position.Volume();
                     m_comment         = "hedge_sell";
                     m_need_open_sell  = true;
                     return;
                    }
                 }
               if(m_position.Comment()=="hedge_buy")
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>=ExtDrawdownClose)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     return;
                    }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(count_hedge_buys==0)
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>=ExtDrawdownOpen)
                    {
                     m_volume          = m_position.Volume();
                     m_comment         = "hedge_buy";
                     m_need_open_buy   = true;
                     return;
                    }
                 }
               if(m_position.Comment()=="hedge_sell")
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>=ExtDrawdownClose)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     return;
                    }
              }
           }
//---
   if(MQLInfoInteger(MQL_TESTER))
      if(count_buys==0 && count_sells==0)
        {
         m_volume=m_symbol.LotsMin();
         m_need_open_buy=true;
        }
//---
   return;
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
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
            if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
              {
               if(m_waiting_transaction)
                  if(m_waiting_order_ticket==deal_order)
                    {
                     Print(__FUNCTION__," Transaction confirmed");
                     m_transaction_confirmed=true;
                    }
              }
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,const string comment)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double long_lot=m_volume;
   if(m_symbol.LotsLimit()>0.0)
     {
      int count_buys=0;    double volume_buys=0.0;    double volume_biggest_buys=0.0;
      int count_sells=0;   double volume_sells=0.0;   double volume_biggest_sells=0.0;
      CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                            count_sells,volume_sells,volume_biggest_sells);
      if(volume_buys+volume_sells+long_lot>m_symbol.LotsLimit())
        {
         Print("#0 Buy, Volume Buy (",DoubleToString(volume_buys,2),
               ") + Volume Sell (",DoubleToString(volume_sells,2),
               ") + Volume long (",DoubleToString(long_lot,2),
               ") > Lots Limit (",DoubleToString(m_symbol.LotsLimit(),2),")");
         return;
        }
     }
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,long_lot,m_symbol.Ask());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,long_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),m_symbol.Ask(),sl,tp,comment)) // CTrade::Buy -> "true"
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009) // trade order went to the exchange
              {
               m_waiting_transaction=true;  // "true" -> it's forbidden to trade,we expect a transaction
               m_waiting_order_ticket=m_trade.ResultOrder();
              }
            else
               m_waiting_transaction=false;
            if(InpPrintLog)
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            if(m_trade.ResultRetcode()==10009)
              {
               m_waiting_transaction=true;  // "true" -> it's forbidden to trade, we expect a transaction
               m_waiting_order_ticket=m_trade.ResultOrder();
              }
            else
               m_waiting_transaction=false;
            if(InpPrintLog)
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         m_waiting_transaction=false;
         if(InpPrintLog)
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintLog)
            PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      m_waiting_transaction=false;
      if(InpPrintLog)
         Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp,const string comment)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double short_lot=m_volume;
   if(m_symbol.LotsLimit()>0.0)
     {
      int count_buys=0;    double volume_buys=0.0;    double volume_biggest_buys=0.0;
      int count_sells=0;   double volume_sells=0.0;   double volume_biggest_sells=0.0;
      CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                            count_sells,volume_sells,volume_biggest_sells);
      if(volume_buys+volume_sells+short_lot>m_symbol.LotsLimit())
         Print("#0 Buy, Volume Buy (",DoubleToString(volume_buys,2),
               ") + Volume Sell (",DoubleToString(volume_sells,2),
               ") + Volume short (",DoubleToString(short_lot,2),
               ") > Lots Limit (",DoubleToString(m_symbol.LotsLimit(),2),")");
      return;
     }
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Sell(short_lot,m_symbol.Name(),m_symbol.Bid(),sl,tp,comment)) // CTrade::Sell -> "true"
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009) // trade order went to the exchange
              {
               m_waiting_transaction=true;  // "true" -> it's forbidden to trade, we expect a transaction
               m_waiting_order_ticket=m_trade.ResultOrder();
              }
            else
               m_waiting_transaction=false;
            if(InpPrintLog)
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            if(m_trade.ResultRetcode()==10009)
              {
               m_waiting_transaction=true;  // "true" -> it's forbidden to trade, we expect a transaction
               m_waiting_order_ticket=m_trade.ResultOrder();
              }
            else
               m_waiting_transaction=false;
            if(InpPrintLog)
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         m_waiting_transaction=false;
         if(InpPrintLog)
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintLog)
            PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      m_waiting_transaction=false;
      if(InpPrintLog)
         Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
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
   int d=0;
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
void CalculateAllPositions(int &count_buys,double &volume_buys,double &volume_biggest_buys,
                           int &count_sells,double &volume_sells,double &volume_biggest_sells)
  {
   count_buys  =0;   volume_buys   = 0.0; volume_biggest_buys  = 0.0;
   count_sells =0;   volume_sells  = 0.0; volume_biggest_sells = 0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               count_buys++;
               volume_buys+=m_position.Volume();
               if(m_position.Volume()>volume_biggest_buys)
                  volume_biggest_buys=m_position.Volume();
               continue;
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               count_sells++;
               volume_sells+=m_position.Volume();
               if(m_position.Volume()>volume_biggest_sells)
                  volume_biggest_sells=m_position.Volume();
              }
           }
  }
//+------------------------------------------------------------------+
