//+------------------------------------------------------------------+
//|                                                   New Martin.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.113"
#property description "Идея взята здесь: https://www.mql5.com/ru/forum/167026"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
input ushort   InpTP                = 50;    // TakeProfit (in pips)
input double   InpLot               = 0.1;   // Lot
input int      Inp_ma_period_slow   = 20;    // ma_period (slow)
input int      Inp_ma_period_fast   = 5;     // ma_period (fast)
input double   InpPersent           = 12;    // Loss persent
//---
ulong          m_magic=524150170;            // magic number
ulong          m_slippage=10;                // slippage
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
bool           m_first=true;
int            handle_iMA_slow;              // variable for storing the handle of the iMA indicator 
int            handle_iMA_fast;              // variable for storing the handle of the iMA indicator 
//--- глобальные переменные
bool           bln_buy=false;                // false -> нужно открывать Buy
bool           bln_sell=false;               // false -> нужно открывать Sell
bool           bln_loss_close_pos=false;     // true -> нужно закрыть позицию loss_ticket_close_pos
ulong          loss_ticket_close_pos=0;      // тикет позиции, которую нужно закрыть
bool           bln_profit_close_pos=false;   // true -> нужно закрыть позицию profit_ticket_close_pos
ulong          profit_ticket_close_pos=0;    // тикет позиции, которую нужно закрыть
double         ExtLot=0.0;
double         start_balance=0.0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//--- проверка периодов "Машек"
   if(Inp_ma_period_slow<=Inp_ma_period_fast)
     {
      Print("Неправильные параметры периодов индикаторов!");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);    // sets magic number
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//---
   ExtLot=InpLot;
   start_balance=m_account.Balance();
//--- create handle of the indicator iMA
   handle_iMA_fast=iMA(m_symbol.Name(),Period(),Inp_ma_period_fast,0,MODE_SMMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_slow=iMA(m_symbol.Name(),Period(),Inp_ma_period_slow,0,MODE_SMMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_slow==INVALID_HANDLE)
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
   m_first=true;
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
//--- закрытие убыточной позиции
   if(bln_loss_close_pos)
     {
      if(PositionSelectByTicket(loss_ticket_close_pos))
        {
         if(m_trade.PositionClose(loss_ticket_close_pos))
           {
            Print("Close loss position -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            //---
            loss_ticket_close_pos=0;
            bln_loss_close_pos=false;
           }
         else
           {
            Print("Close loss position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
      else
        {
         //--- такой позиции уже нет (PositionSelectByTicket вернул false)
         loss_ticket_close_pos=0;
         bln_loss_close_pos=false;

        }
     }
//--- закрытие прибыльной позиции
   if(bln_profit_close_pos)
     {
      if(PositionSelectByTicket(profit_ticket_close_pos))
        {
         if(m_trade.PositionClose(profit_ticket_close_pos))
           {
            Print("Close profit position -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            //---
            profit_ticket_close_pos=0;
            bln_profit_close_pos=false;
           }
         else
           {
            Print("Close profit position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
      else
        {
         //--- такой позиции уже нет (PositionSelectByTicket вернул false)
         profit_ticket_close_pos=0;
         bln_profit_close_pos=false;
        }
     }
//--- если мы увеличили баланс - то увеличим лот
   if(start_balance*1.6<m_account.Balance())
     {
      start_balance=m_account.Balance();
      ExtLot*=1.6;
      ExtLot=LotCheck(ExtLot);
      if(ExtLot==0)
         return;
      Print(__FUNCTION__,", теперь базовый баланс ",DoubleToString(start_balance,2),", лот ",DoubleToString(ExtLot,2));
     }
//--- защита по средствам: если просадка превышает заданный процент 
//--- значит всё закрываем
   static double max_equity=0;
   double equity=m_account.Equity();
   double balance=m_account.Balance();

   if((balance-equity)*100.0/balance>InpPersent)
     {
      CloseAllPositions();
      bln_buy=false;
      bln_sell=false;
      //return;
     }

   datetime time_0=iTime(0);
//---
   if(!RefreshRates())
      return;

   if(m_first)
     {
      //--- защита от перезапуска терминала:
      int total=0;
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
         if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
               total++;
      //--- если на торговом счёте уже есть позиции открытые данным экспертом - 
      //--- значит инициализируем переменные таким образом, что вроде уже был первый раз
      if(total>0)
        {
         bln_buy=true;
         bln_sell=true;
         m_first=false;
         return;
        }

      if(OpenBuy(ExtLot))
         bln_buy=true;
      if(OpenSell(ExtLot))
         bln_sell=true;
      m_first=false;
     }
//---
   if(!bln_buy)
     {
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),ExtLot,m_symbol.Ask(),ORDER_TYPE_BUY);
      if(chek_volime_lot!=0.0)
         if(chek_volime_lot<ExtLot)
            return; // денег не хватит на открытие позиции
      if(OpenBuy(ExtLot))
         bln_buy=true;
     }
   if(!bln_sell)
     {
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),ExtLot,m_symbol.Bid(),ORDER_TYPE_SELL);
      if(chek_volime_lot!=0.0)
         if(chek_volime_lot<ExtLot)
            return; // денег не хватит на открытие позиции
      if(OpenSell(ExtLot))
         bln_sell=true;
     }
//--- ищем пересечение двух iMA
   double slow_2=iMAGet(handle_iMA_slow,2);
   double slow_1=iMAGet(handle_iMA_slow,1);
   double fast_2=iMAGet(handle_iMA_fast,2);
   double fast_1=iMAGet(handle_iMA_fast,1);

   if((slow_2>fast_2 && slow_1<fast_1) || (slow_2<fast_2 && slow_1>fast_1)) // это пересечение!
     {
      static datetime crossing=0;
      if(crossing==time_0)
         return;
      crossing=time_0;
      Print("Обнаружено пересечение!");
      //--- поиск самой убыточной и самой прибыльной позиции и определение их направления
      //DebugBreak();
      ENUM_POSITION_TYPE loss_type=-1;    double loss_volume=0.0;    ulong loss_ticket=0;
      ENUM_POSITION_TYPE profit_type=-1;  double profit_volume=0.0;  ulong profit_ticket=0;
      FindMaxMinProfitPositions(loss_type,loss_volume,loss_ticket,
                                profit_type,profit_volume,profit_ticket);
      if(loss_ticket!=0)
        {
         loss_volume*=1.6;//  увеличим лот
         loss_volume=LotCheck(loss_volume);
         if(loss_volume==0)
            return;

         Print("Пересечение. Увеличим лот - теперь он равен: ",DoubleToString(loss_volume,2));

         if(loss_type==POSITION_TYPE_BUY)
           {
            //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
            double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),loss_volume,m_symbol.Ask(),ORDER_TYPE_BUY);
            if(chek_volime_lot!=0.0)
               if(chek_volime_lot<loss_volume)
                  return; // денег не хватит на открытие позиции
            Print("Пересечение. Убыточная поизция имеет тип POSITION_TYPE_BUY. Попытка открыть Buy");
            if(!OpenBuy(loss_volume))
               crossing-=1;
           }
         if(loss_type==POSITION_TYPE_SELL)
           {
            //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
            double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),loss_volume,m_symbol.Bid(),ORDER_TYPE_SELL);
            if(chek_volime_lot!=0.0)
               if(chek_volime_lot<loss_volume)
                  return; // денег не хватит на открытие позиции
            Print("Пересечение. Убыточная поизция имеет тип POSITION_TYPE_SELL. Попытка открыть Sell");
            if(!OpenSell(loss_volume))
               crossing-=1;
           }
         if(profit_ticket!=0)
           {
            //--- закрытие будет в OnTick
            Print("Пересечение. Отдан приказ на закрытие прибыльной позиции с тикетом ",profit_ticket);
            profit_ticket_close_pos=profit_ticket;
            bln_profit_close_pos=true;
            //Print(__FUNCTION__,": Close profit position");
            //m_trade.PositionClose(profit_ticket);
           }
        }
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
      long     deal_entry        =0;
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      long     deal_type         =0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_type=HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment=HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==Symbol() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            if(deal_profit>0)
              {
               //--- есть шанс, что это было закрытие по TakeProfit
               if(StringFind(deal_comment,"tp",0)==-1)
                  return;
               Print("Обнаружено закрытие по TakeProfit!");
               //--- если закрыли BUY
               if(deal_type==DEAL_TYPE_SELL)
                 {
                  //--- обнуление для BUY
                  Print("TakeProfit. Отдан приказ на открытие Buy");
                  bln_buy=false;
                 }
               //--- если закрыли SELL
               if(deal_type==DEAL_TYPE_BUY)
                 {
                  //--- обнуление для SELL
                  Print("TakeProfit. Отдан приказ на открытие Sell");
                  bln_sell=false;
                 }
               ////--- поиск самой убыточной позиции и определение её направления
               ////DebugBreak();
               //ENUM_POSITION_TYPE pos_type=-1;
               //double pos_volume=-1;
               //ulong loss_ticket=MostUnprofitablePosition(pos_type,pos_volume);
               //if(loss_ticket!=0)
               //  {
               //   Print(__FUNCTION__,": TakeProfit volume ",DoubleToString(deal_volume,2),
               //         ", close volume ",DoubleToString(pos_volume,2));
               //   m_trade.PositionClose(loss_ticket);
               //  }

               //--- поиск самой убыточной и самой прибыльной позиции и определение их направления
               //DebugBreak();
               ENUM_POSITION_TYPE loss_type=-1;    double loss_volume=0.0;    ulong loss_ticket=0;
               ENUM_POSITION_TYPE profit_type=-1;  double profit_volume=0.0;  ulong profit_ticket=0;
               FindMaxMinProfitPositions(loss_type,loss_volume,loss_ticket,
                                         profit_type,profit_volume,profit_ticket);
               if(loss_ticket!=0)
                 {
                  //--- закрытие будет в OnTick
                  Print("TakeProfit. Отдан приказ на закрытие убыточной позиции с тикетом ",loss_ticket);
                  loss_ticket_close_pos=loss_ticket;
                  bln_loss_close_pos=true;
                  //Print(__FUNCTION__,": Close loss position");
                  //m_trade.PositionClose(loss_ticket);
                 }
               if(profit_ticket!=0)
                 {
                  //--- закрытие будет в OnTick
                  Print("TakeProfit. Отдан приказ на закрытие прибыльной позиции с тикетом ",profit_ticket);
                  profit_ticket_close_pos=profit_ticket;
                  bln_profit_close_pos=true;
                  //Print(__FUNCTION__,": Close profit position");
                  //m_trade.PositionClose(profit_ticket);
                 }
              }
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle_iMA,const int index)
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
//| Поиск самой убыточной и самой прибыльной позиции                 |
//+------------------------------------------------------------------+
void FindMaxMinProfitPositions(ENUM_POSITION_TYPE &loss_type,double &loss_volume,ulong &loss_ticket,
                               ENUM_POSITION_TYPE &profit_type,double &profit_volume,ulong &profit_ticket)
  {
   loss_type=-1;     loss_volume=0.0;     loss_ticket=0;
   profit_type=-1;   profit_volume=0.0;   profit_ticket=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.Profit()<loss_volume)
              {
               loss_type=m_position.PositionType();
               loss_volume=m_position.Volume();
               loss_ticket=m_position.Ticket();
              }
            if(m_position.Profit()>profit_volume)
              {
               profit_type=m_position.PositionType();
               profit_volume=m_position.Volume();
               profit_ticket=m_position.Ticket();
              }
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Close All Positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(void)
  {
//--- закрываем все позиции (по всем магикам и по всем символам)
   bool res=false;

   while(!res)
     {
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
         if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
            //if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            res=m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
            if(!res)
               break;
           }
     }
  }
//+------------------------------------------------------------------+
//| Открытие BUY позиции по символу                                  |
//+------------------------------------------------------------------+
bool OpenBuy(const double lot)
  {
   bool res=false;

   double price=m_symbol.Ask();
   double tp=m_symbol.NormalizePrice(m_symbol.Bid()+InpTP*m_adjusted_point);
   if(m_trade.Buy(lot,m_symbol.Name(),price,0.0,tp))
      if(m_trade.ResultDeal()>0)
         res=true;

   return(res);
  }
//+------------------------------------------------------------------+
//| Открытие SELL позиции по символу                                 |
//+------------------------------------------------------------------+
bool OpenSell(const double lot)
  {
   bool res=false;

   double price=m_symbol.Bid();
   double tp=m_symbol.NormalizePrice(m_symbol.Ask()-InpTP*m_adjusted_point);
   if(m_trade.Sell(lot,m_symbol.Name(),price,0.0,tp))
      if(m_trade.ResultDeal()>0)
         res=true;

   return(res);
  }
//+------------------------------------------------------------------+
