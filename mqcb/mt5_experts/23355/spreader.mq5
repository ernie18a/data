//+------------------------------------------------------------------+
//|                            Spreader(barabashkakvn's edition).mq5 |
//|                               Copyright © 2010, Yury V. Reshetov |
//|                                         http://spreader.heigh.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Yury V. Reshetov"
#property link      "http://spreader.heigh.ru"
#property version   "1.000"
#property description "Run only M1 timeframe!"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol_current;             // symbol info object
CSymbolInfo    m_symbol_second;              // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedMargin *m_money;
//--- input parameters
input double   InpLots           = 1.0;      // Lots (current Symbol)
input string   InpSecondSymbol   = "GBPUSD"; // Second symbol name 
input double   InpMinimumProfit  = 100.0;    // Minimum profit, in money
input bool     InpPrintLog       = false;    // Print log
input ulong    m_magic           = 72660400; // magic number
//---
ulong  m_slippage=10;                        // slippage

bool   m_need_open_buy_current   = false;    // "true" -> need to open BUY on current Symbol
bool   m_need_open_sell_current  = false;    // "true" -> need to open SELL on current Symbol

bool   m_need_open_buy_second    = false;    // "true" -> need to open BUY on second Symbol
bool   m_need_open_sell_second   = false;    // "true" -> need to open SELL on second Symbol

bool   m_waiting_transaction_current=false;  // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
bool   m_waiting_transaction_second=false;   // "true" -> it's forbidden to trade, we expect a transaction on second Symbol

ulong  m_waiting_order_ticket_current=0;     // ticket of the expected order on current Symbol
ulong  m_waiting_order_ticket_second=0;      // ticket of the expected order on second Symbol

bool   m_transaction_confirmed_current=false;// "true" -> transaction confirmed on current Symbol
bool   m_transaction_confirmed_second=false; // "true" -> transaction confirmed on second Symbol

double m_lot_current=1.0;
double m_lot_second=1.0;
//---
static bool m_openbarspriceonly  = true;
static int m_shift               = 30;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol_current.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates(m_symbol_current);

   if(!m_symbol_second.Name(InpSecondSymbol)) // sets symbol name
      return(INIT_FAILED);
   RefreshRates(m_symbol_second);
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol_current.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- check the input parameter "Lots"
   string err_text="";
   if(!CheckVolumeValue(m_symbol_current,InpLots,err_text))
     {
      //--- when testing, we will only output to the log about incorrect input parameters
      if(MQLInfoInteger(MQL_TESTER))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_FAILED);
        }
      else // if the Expert Advisor is run on the chart, tell the user about the error
        {
         Alert(__FUNCTION__,", ERROR: ",err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
   m_lot_current=InpLots;
   m_lot_second=InpLots;
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
   if(m_waiting_transaction_current)
     {
      if(!m_transaction_confirmed_current)
        {
         Print("m_transaction_confirmed_current: ",m_transaction_confirmed_current);
         return;
        }
      else if(m_transaction_confirmed_current)
        {
         m_need_open_buy_current          = false;    // "true" -> need to open BUY on current Symbol
         m_need_open_sell_current         = false;    // "true" -> need to open SELL on current Symbol
         m_waiting_transaction_current    = false;    // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
         m_waiting_order_ticket_current   = 0;        // ticket of the expected order on current Symbol
         m_transaction_confirmed_current  = false;    // "true" -> transaction confirmed on current Symbol
        }
     }
   if(m_need_open_buy_current)
     {
      if(RefreshRates(m_symbol_current))
        {
         m_waiting_transaction_current=true;
         OpenBuy(m_symbol_current,m_lot_current);
        }
      return;
     }
   if(m_need_open_sell_current)
     {
      if(RefreshRates(m_symbol_current))
        {
         m_waiting_transaction_current=true;
         OpenSell(m_symbol_current,m_lot_current);
        }
      return;
     }

   if(m_waiting_transaction_second)
     {
      if(!m_transaction_confirmed_second)
        {
         Print("m_transaction_confirmed_second: ",m_transaction_confirmed_second);
         return;
        }
      else if(m_transaction_confirmed_second)
        {
         m_need_open_buy_second          = false;    // "true" -> need to open BUY on second Symbol
         m_need_open_sell_second         = false;    // "true" -> need to open SELL on second Symbol
         m_waiting_transaction_second    = false;    // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
         m_waiting_order_ticket_second   = 0;        // ticket of the expected order on second Symbol
         m_transaction_confirmed_second  = false;    // "true" -> transaction confirmed on second Symbol
        }
     }
   if(m_need_open_buy_second)
     {
      if(RefreshRates(m_symbol_second))
        {
         m_waiting_transaction_second=true;
         OpenBuy(m_symbol_second,m_lot_second);
        }
      return;
     }
   if(m_need_open_sell_second)
     {
      if(RefreshRates(m_symbol_second))
        {
         m_waiting_transaction_second=true;
         OpenSell(m_symbol_second,m_lot_second);
        }
      return;
     }
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol_current.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates(m_symbol_current) || !RefreshRates(m_symbol_second))
     {
      PrevBars=0;
      return;
     }
//--- work
   ulong currentticket= ULONG_MAX;
   ulong secondticket = ULONG_MAX;

// Направление позиции для текущего инструмента
   long currenttype=POSITION_TYPE_SELL;
// Направление позиции для второго инструмента
   long secondtype=POSITION_TYPE_BUY;

   double currentprofit=0.0;

   double secondlots=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
        {
         if(m_position.Symbol()==m_symbol_current.Name() && m_position.Magic()==m_magic)
           {
            currentticket  = m_position.Ticket();
            currentprofit  = currentprofit+m_position.Profit();
            currenttype    = m_position.PositionType();
           }
         if(m_position.Symbol()==m_symbol_second.Name() && m_position.Magic()==m_magic)
           {
            secondticket   = m_position.Ticket();
            currentprofit  = currentprofit+m_position.Profit();
            secondtype     = m_position.PositionType();
            secondlots     = m_position.Volume();
           }
        }

   if(secondticket==ULONG_MAX && currentticket!=ULONG_MAX)
     {
      Comment("Try close positon for "+m_symbol_current.Name());
      if(m_trade.PositionClose(currentticket))
         m_openbarspriceonly=true;
      return;
     }

   if(secondticket!=ULONG_MAX && currentticket!=ULONG_MAX)
     {
      m_openbarspriceonly=false;
      if(currentprofit>InpMinimumProfit)
        {
         m_trade.PositionClose(secondticket,100);
         return;
        }
      // Позиции по обоим инструментам уже открыты
      Comment("Positions for "+m_symbol_current.Name()+" and "+m_symbol_second.Name()+" is open");
      return;
     }

   m_openbarspriceonly=true;

   if((secondticket!=ULONG_MAX) && (currentticket==ULONG_MAX))
     {
      Comment("Try open positon for "+m_symbol_current.Name());
      // Открываем позицию для текущего символа 
      // в противоположном направлении позиции второго инструмента
      m_lot_current=InpLots;
      if(secondtype==POSITION_TYPE_SELL)
         m_need_open_buy_current=true;     // "true" -> need to open BUY on current Symbol
      else
         m_need_open_sell_current=true;     // "true" -> need to open SELL on current Symbol
      return;
     }

   if(m_symbol_current.ContractSize()!=m_symbol_second.ContractSize())
     {
      Alert("Contracts size not equals. Change instruments");
      return;
     }

// Ищем первые разности для двух периодов обоих инструментов

   double close_current[],close_second[];
   ArraySetAsSeries(close_current,true);
   ArraySetAsSeries(close_second,true);
   int start_pos=0,count=m_shift*2+1;
   if(CopyClose(m_symbol_current.Name(),Period(),start_pos,count,close_current)!=count || 
      CopyClose(m_symbol_second.Name(),Period(),start_pos,count,close_second)!=count)
     {
      PrevBars=0;
      return;
     }

   double x1 = close_current[0]        - close_current[m_shift];
   double x2 = close_current[m_shift]  - close_current[m_shift*2];
   double y1 = close_second[0]         - close_second[m_shift];
   double y2 = close_second[m_shift]   - close_second[m_shift*2];
//---

// Ищем условия для корреляции
   if((x1*x2)>0.0)
     {
      // На обоих участках однонаправленный тренд
      // корреляции вычислить не удается
      Comment(m_symbol_current.Name()+" trend found");
      return;
     }

   if((y1*y2)>0.0)
     {
      // На обоих участках однонаправленный тренд
      // корреляции вычислить не удается
      Comment(m_symbol_second.Name()+" trend found");
      return;
     }

// Направление позиции для текущего инструмента
   if((x1*y1)>0)
     {
      // Имеем дело с положительной корреляцией
      double a = MathAbs(x1) + MathAbs(x2);
      double b = MathAbs(y1) + MathAbs(y2);

      if((a/b)>3.0)
         return;

      if((a/b)<0.3)
         return;

      // Объем позиции для второго инструмента
      m_lot_second=LotCheck(m_symbol_second,a*InpLots/b);
      if(m_lot_second==0.0)
         return;

      // Выбираем направление позиций для инструментов
      if((x1*b)>(y1*a))
         currenttype=POSITION_TYPE_BUY;
     }
   else
     {
      // Имеем дело с отрицательной корреляцией
      Comment("Negative correlation found");
      return;
     }

// Открываем позицию для второго инструмента
   if(currenttype==POSITION_TYPE_SELL)
      m_need_open_buy_second=true;   // "true" -> need to open BUY on second Symbol
   else
      m_need_open_sell_second=true;   // "true" -> need to open SELL on second Symbol

   //if(secondticket!=ULONG_MAX)
      //m_openbarspriceonly=false;
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
      if(deal_symbol==m_symbol_current.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
            if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
              {
               if(m_waiting_transaction_current)
                  if(m_waiting_order_ticket_current==deal_order)
                    {
                     Print(__FUNCTION__," Transaction confirmed");
                     m_transaction_confirmed_current=true;
                    }
              }
      if(deal_symbol==m_symbol_second.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
            if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
              {
               if(m_waiting_transaction_second)
                  if(m_waiting_order_ticket_second==deal_order)
                    {
                     Print(__FUNCTION__," Transaction confirmed");
                     m_transaction_confirmed_second=true;
                    }
              }
     }

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(CSymbolInfo &m_symbol)
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
bool CheckVolumeValue(CSymbolInfo &m_symbol,double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(CSymbolInfo &m_symbol,double lot)
  {
   double sl=0.0;
   double tp=0.0;

   double long_lot=lot;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,long_lot,m_symbol.Ask());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,long_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),m_symbol.Ask(),sl,tp)) // CTrade::Buy -> "true"
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_symbol.Name()==m_symbol_current.Name())
              {
               m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
               m_waiting_order_ticket_current=m_trade.ResultOrder();
              }
            else if(m_symbol.Name()==m_symbol_second.Name())
              {
               m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
               m_waiting_order_ticket_second=m_trade.ResultOrder();
              }
            else
              {
               if(m_symbol.Name()==m_symbol_current.Name())
                  m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
               else if(m_symbol.Name()==m_symbol_second.Name())
                  m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
              }
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
               if(m_symbol.Name()==m_symbol_current.Name())
                 {
                  m_waiting_transaction_current=true; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
                  m_waiting_order_ticket_current=m_trade.ResultOrder();
                 }
               else if(m_symbol.Name()==m_symbol_second.Name())
                 {
                  m_waiting_transaction_second=true; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
                  m_waiting_order_ticket_second=m_trade.ResultOrder();
                 }
              }
            else
              {
               if(m_symbol.Name()==m_symbol_current.Name())
                  m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
               else if(m_symbol.Name()==m_symbol_second.Name())
                  m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
              }
            if(InpPrintLog)
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         if(m_symbol.Name()==m_symbol_current.Name())
            m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
         else if(m_symbol.Name()==m_symbol_second.Name())
            m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
         if(InpPrintLog)
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintLog)
            PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      if(m_symbol.Name()==m_symbol_current.Name())
         m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
      else if(m_symbol.Name()==m_symbol_second.Name())
         m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
      if(InpPrintLog)
         Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(CSymbolInfo &m_symbol,double lot)
  {
   double sl=0.0;
   double tp=0.0;

   double short_lot=lot;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Sell(short_lot,m_symbol.Name(),m_symbol.Bid(),sl,tp)) // CTrade::Sell -> "true"
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009) // trade order went to the exchange
              {
               if(m_symbol.Name()==m_symbol_current.Name())
                 {
                  m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
                  m_waiting_order_ticket_current=m_trade.ResultOrder();
                 }
               else if(m_symbol.Name()==m_symbol_second.Name())
                 {
                  m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
                  m_waiting_order_ticket_second=m_trade.ResultOrder();
                 }
              }
            else
              {
               if(m_symbol.Name()==m_symbol_current.Name())
                  m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
               else if(m_symbol.Name()==m_symbol_second.Name())
                  m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
              }
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
               if(m_symbol.Name()==m_symbol_current.Name())
                 {
                  m_waiting_transaction_current=true; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
                  m_waiting_order_ticket_current=m_trade.ResultOrder();
                 }
               else if(m_symbol.Name()==m_symbol_second.Name())
                 {
                  m_waiting_transaction_second=true; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
                  m_waiting_order_ticket_second=m_trade.ResultOrder();
                 }
              }
            else
              {
               if(m_symbol.Name()==m_symbol_current.Name())
                  m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
               else if(m_symbol.Name()==m_symbol_second.Name())
                  m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
              }
            if(InpPrintLog)
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         if(m_symbol.Name()==m_symbol_current.Name())
            m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
         else if(m_symbol.Name()==m_symbol_second.Name())
            m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
         if(InpPrintLog)
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintLog)
            PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      if(m_symbol.Name()==m_symbol_current.Name())
         m_waiting_transaction_current=false; // "true" -> it's forbidden to trade, we expect a transaction on current Symbol
      else if(m_symbol.Name()==m_symbol_second.Name())
         m_waiting_transaction_second=false; // "true" -> it's forbidden to trade, we expect a transaction on second Symbol
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
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(CSymbolInfo &m_symbol,double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
