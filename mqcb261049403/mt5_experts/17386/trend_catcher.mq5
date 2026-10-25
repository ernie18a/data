//+------------------------------------------------------------------+
//|                    Trend_Catcher_v2(barabashkakvn's edition).mq5 |
//|                                                 Dmitriy Epshteyn |
//|                                                  setkafx@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Dmitriy Epshteyn"
#property link      "setkafx@mail.ru"
#property version   "1.001"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CMoneyFixedRisk m_money;
//--- Свеча, за период которой может быть открыта только одна позиция,
//--- Например, если выбрать PERIOD_D1 - то советник может открыть только одну позицию на текущей дневной свече 
input ENUM_TIMEFRAMES Candle_TF=PERIOD_CURRENT; // Свеча, за период которой может быть открыта только одна позиция
input bool     Close_opposite_signal=true;   // Закрывать ли позицию по обратному сигналу
input bool     Monday            = true;     // Торговый день Понедельник
input bool     Tuesday           = true;     // Торговый день Вторник
input bool     Wednesday         = true;     // Торговый день Среда
input bool     Thursday          = true;     // Торговый день Четверг
input bool     Friday            = true;     // Торговый день Пятница
input bool     Reverse_Sig_Open  = false;    // "true" -> сигнал будет перевернут, вместо бай откроется селл, вместо селл откроется бай  
input int      PeriodMA_slow     = 200;      // Период медленной MA
input int      PeriodMA_fast     = 50;       // Период первой быстрой MA 
input int      PeriodMA_fast2    = 25;       // Период второй быстрой MA
input double   Step_Sar          = 0.004;    // Шаг изменения цены Parabolic SAR
input double   Max_Sar           = 0.2;      // Максимальный шаг изменения цены Parabolic SAR
input bool     Auto_SL           = true;     // Включить автоматический стоп лосс на точке индикатора Parabolic SAR
input bool     Auto_TP           = true;     // Включить автоматический тейк профит, который рассчитывается по коэффициенту
input ushort   minSL             = 10;       // Если расчетный стоп лосс меньше minSL, позицию не открываем
input ushort   maxSL             = 200;      // Если расчетный стоп лосс больше maxSL, позицию не открываем
input double   SL_koef           = 1;        // Коэффициент на который умножается стоп лосс (если 1, то стоп лосс будет на точке Parabolic SAR)
input double   TP_koef           = 1;        // Коэффициент расчета тейк профита от стоп лосса, пример: если TP_koef=2,то это означает, что тейк профит в два раза больше стоп лосса
input ushort   SL                = 20;       // Стоп лосс в пунктах, применяется, если Auto_SL = false
input ushort   TP                = 200;      // Тейк профит в пунктах, применяется, если  Auto_TP = false
input double   Risk              = 2;        // Риск, по которому рассчитывается лот ордера, зависит от стоп лосса
input bool     Martin            = true;     // Если включен, то применяется Мартингейл.
input double   Koef              = 2;        // Если последняя сделка закрыта с убытком, то риск следующей сделки будет умножен на Koef
input ushort   Profit_Level      = 500;      // Если позиция выходит в плюс на Profit_Level пунктов
input ushort   SL_Plus           = 1;        // то +SL_Plus выставляется безубыток
input ushort   Profit_Level2     = 500;      // Если позиция выходит в профит на Profit_Level2 пунктов
input ushort   TrailingStop2     = 10;       // то на расстоянии TrailingStop2 пунктов стоп лосс будет тянуться за ценой
input ulong    m_slippage        = 30;       // Проскальзывание
input ulong    m_magic           = 1;        // Индивидуальный номер для позиций, которые выставляет советник
//---
double         m_Full_Financial_Result=0;    // Полный финансовый результат последней сделки
int            handle_iMA_slow;              // variable for storing the handle of the iMA indicator 
int            handle_iMA_fast;              // variable for storing the handle of the iMA indicator 
int            handle_iMA_fast2;             // variable for storing the handle of the iMA indicator 
int            handle_iSAR;                  // variable for storing the handle of the iSAR indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//SetMarginMode();
//if(!IsHedging())
//  {
//   Print("Hedging only!");
//   return(INIT_FAILED);
//  }
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
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(Risk);                    // risk
//--- create handle of the indicator iMA
   handle_iMA_slow=iMA(m_symbol.Name(),Period(),PeriodMA_slow,0,MODE_EMA,PRICE_CLOSE);
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
//--- create handle of the indicator iMA
   handle_iMA_fast=iMA(m_symbol.Name(),Period(),PeriodMA_fast,0,MODE_EMA,PRICE_CLOSE);
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
   handle_iMA_fast2=iMA(m_symbol.Name(),Period(),PeriodMA_fast2,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_fast2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iSAR
   handle_iSAR=iSAR(Symbol(),Period(),Step_Sar,Max_Sar);
//--- if the handle is not created 
   if(handle_iSAR==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iSAR indicator for the symbol %s/%s, error code %d",
                  Symbol(),
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
//---
   int b=0,s=0,n=0;
   double bez     = m_symbol.NormalizePrice(Profit_Level*m_adjusted_point);
   double sl_plus = m_symbol.NormalizePrice(SL_Plus*m_adjusted_point);
   double bez2    = m_symbol.NormalizePrice(Profit_Level2*m_adjusted_point);
   double tr      = m_symbol.NormalizePrice(TrailingStop2*m_adjusted_point);

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(!RefreshRates())
               continue;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               b++;n++;
               if(m_symbol.Bid()-m_position.PriceOpen()>bez && 
                  m_position.StopLoss()<m_symbol.NormalizePrice(m_position.PriceOpen()+sl_plus) &&
                  m_position.StopLoss()!=m_symbol.NormalizePrice(m_position.PriceOpen()+sl_plus))
                 {
                  if(m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_position.PriceOpen()+sl_plus),
                     m_position.TakeProfit()))
                     Print("Безубыток Buy",m_symbol.NormalizePrice(m_position.PriceOpen()+sl_plus));
                 }
               if(m_symbol.Bid()-m_position.PriceOpen()>bez2 &&
                  m_symbol.Bid()-m_position.StopLoss()>tr &&
                  m_position.StopLoss()!=m_symbol.NormalizePrice(m_symbol.Bid()-tr))
                 {
                  if(m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_symbol.Bid()-tr),
                     m_position.TakeProfit()))
                     Print("Трейлинг Buy",m_symbol.NormalizePrice(m_symbol.Bid()-tr));
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               s++;n++;
               if(m_position.PriceOpen()-m_symbol.Ask()>bez &&
                  m_position.StopLoss()>m_symbol.NormalizePrice(m_position.PriceOpen()-sl_plus) &&
                  m_position.StopLoss()!=m_symbol.NormalizePrice(m_position.PriceOpen()-sl_plus))
                 {
                  if(m_trade.PositionModify(m_position.Ticket(),
                     m_symbol.NormalizePrice(m_position.PriceOpen()-sl_plus),
                     m_position.TakeProfit()))
                     Print("Безубыток Sell",m_symbol.NormalizePrice(m_position.PriceOpen()-sl_plus));
                 }
               if(m_position.PriceOpen()-m_symbol.Ask()>bez2)
                  if(m_position.StopLoss()-m_symbol.Ask()>tr || m_position.StopLoss()==0)
                     if(m_position.StopLoss()!=m_symbol.NormalizePrice(m_symbol.Ask()+tr))
                       {
                        if(m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_symbol.Ask()+tr),
                           m_position.TakeProfit()))
                           Print("Трейлинг Sell",m_symbol.NormalizePrice(m_symbol.Ask()+tr));
                       }
              }
           }

//--- подсчёт количства сделок внутри текущей свечи
   int      CountInCandel=0;
   datetime from_date=iTime(0,m_symbol.Name(),Candle_TF);
   datetime to_date=TimeCurrent();
//--- request trade history 
   HistorySelect(from_date-PeriodSeconds(Candle_TF),to_date+PeriodSeconds(Candle_TF));
//---
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   string   symbol;
   long     magic;
   long     entry;
   datetime time;
//--- for all deals 
   for(uint i=0;i<total;i++)
     {
      //--- try to get deals ticket 
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties 
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         //--- only for current symbol and magic
         if(symbol==m_symbol.Name() && magic==m_magic)
           {
            if(entry==DEAL_ENTRY_OUT)
              {
               if(time>=from_date)
                  CountInCandel++;
               if(time<from_date)
                  break;
              }
           }
        }

     }
//--- сигнал и индикаторы
   double SAR0=iSARGet(0); //по нему стоп лосс рассчитываем // stop loss forward on it 
   double SAR1 = iSARGet(1);
   double SAR2 = iSARGet(2);
   double MA_slow = iMAGet(handle_iMA_slow,0);
   double MA_fast = iMAGet(handle_iMA_fast,0);
   double MA_fast2= iMAGet(handle_iMA_fast2,0);

   if(!RefreshRates())
      return;

   int sig=0;

   if(iClose(0)>SAR0 && iClose(1)<SAR1 && MA_fast>MA_slow && m_symbol.Ask()>MA_fast2)
      sig=1;
   if(iClose(0)<SAR0 && iClose(1)>SAR1 && MA_fast<MA_slow && m_symbol.Bid()<MA_fast2)
      sig=2;
//--- Определение торгового дня

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   bool trade_day=false;
   if(str1.day_of_week==1 && Monday==true)
      trade_day=true;
   if(str1.day_of_week==2 && Tuesday==true)
      trade_day=true;
   if(str1.day_of_week==3 && Wednesday==true)
      trade_day=true;
   if(str1.day_of_week==4 && Thursday==true)
      trade_day=true;
   if(str1.day_of_week==5 && Friday==true)
      trade_day=true;
//--- стоп лосс и тейк профит
   double sl=0;
   double tp=0;
   double min_sl = m_symbol.NormalizePrice(minSL*m_adjusted_point);
   double max_sl = m_symbol.NormalizePrice(maxSL*m_adjusted_point);

   if(!Auto_SL)
      sl=m_symbol.NormalizePrice(SL*m_adjusted_point);
   if(!Auto_TP)
      tp=m_symbol.NormalizePrice(TP*m_adjusted_point);

   if(Auto_SL && m_symbol.Ask()<SAR0)
      sl=m_symbol.NormalizePrice((MathAbs(SAR0-m_symbol.Ask()))*SL_koef);
   if(Auto_SL && m_symbol.Bid()>SAR0)
      sl=m_symbol.NormalizePrice((MathAbs(m_symbol.Bid()-SAR0))*SL_koef);

   if(sl<min_sl)
      sl=min_sl;
   if(sl>max_sl)
      sl=max_sl;

   if(Auto_TP==true)
      tp=m_symbol.NormalizePrice(sl*TP_koef);
//--- лот рассчитываем по проценту от баланса счета и применяем мартингейл в соответствии с настройками
//double Procent=AccountBalance()/100*Risk;
   if(m_Full_Financial_Result<0 && Martin)
      m_money.Percent(Risk*Koef);
   else
      m_money.Percent(Risk);
//Procent=NormalizeDouble(MathAbs(m_Full_Financial_Result)*Koef,Digits);

//--- получаем размер лота для Buy при указанном риске
   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
   if(check_open_long_lot==0.0)
     {
      Print("CheckOpenLong == 0");
      return;
     }
//--- получаем размер лота для Sell при указанном риске
   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
   if(check_open_long_lot==0.0)
     {
      Print("CheckOpenShort == 0");
      return;
     }

//--- открываем позицию
   if(!Reverse_Sig_Open && trade_day && n==0 && sig==1 && CountInCandel==0 && sl>min_sl)
     {
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

      if(chek_volume_lot!=0.0)
         if(chek_volume_lot>=check_open_long_lot)
           {
            if(m_trade.Buy(check_open_long_lot,NULL,
               m_symbol.Ask(),
               m_symbol.NormalizePrice(m_symbol.Ask()-sl),
               m_symbol.NormalizePrice(m_symbol.Ask()+tp)))
               Print("Цена buy=",m_symbol.Ask(),", Стоп лосс=",m_symbol.Ask()-sl,", Тейк профит=",m_symbol.Ask()+tp);
           }
     }
   if(!Reverse_Sig_Open && trade_day && n==0 && sig==2 && CountInCandel==0 && sl>min_sl)
     {
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

      if(chek_volume_lot!=0.0)
         if(chek_volume_lot>=check_open_short_lot)
           {
            if(m_trade.Sell(check_open_short_lot,NULL,
               m_symbol.Bid(),
               m_symbol.Bid()+sl,
               m_symbol.Bid()-tp))
               Print("Цена sell=",m_symbol.Bid(),", Стоп лосс=",m_symbol.Bid()+sl,", Тейк профит=",m_symbol.Bid()-tp);
           }
     }
   if(Reverse_Sig_Open && trade_day && n==0 && sig==2 && CountInCandel==0 && sl>min_sl)
     {
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

      if(chek_volume_lot!=0.0)
         if(chek_volume_lot>=check_open_long_lot)
           {
            if(m_trade.Buy(check_open_long_lot,NULL,
               m_symbol.Ask(),
               m_symbol.Ask()-sl,
               m_symbol.Ask()+tp))
               Print("Цена buy=",m_symbol.Ask(),", Стоп лосс=",m_symbol.Ask()-sl,", Тейк профит=",m_symbol.Ask()+tp);
           }
     }
   if(Reverse_Sig_Open && trade_day && n==0 && sig==1 && CountInCandel==0 && sl>min_sl)
     {
      //--- check volume before OrderSend to avoid "not enough money" error (CTrade)
      double chek_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

      if(chek_volume_lot!=0.0)
         if(chek_volume_lot>=check_open_short_lot)
           {
            if(m_trade.Sell(check_open_short_lot,NULL,
               m_symbol.Bid(),
               m_symbol.Bid()+sl,
               m_symbol.Bid()-tp))
               Print("Цена sell=",m_symbol.Bid(),", Стоп лосс=",m_symbol.Bid()+sl,", Тейк профит=",m_symbol.Bid()-tp);
           }
     }

//--- закрываем позицию по обратному сигналу
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(sig==2 && Close_opposite_signal && !Reverse_Sig_Open)
                  m_trade.PositionClose(m_position.Ticket());

               if(sig==1 && Close_opposite_signal && Reverse_Sig_Open)
                  m_trade.PositionClose(m_position.Ticket());
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(sig==1 && Close_opposite_signal && !Reverse_Sig_Open)
                  m_trade.PositionClose(m_position.Ticket());

               if(sig==2 && Close_opposite_signal && Reverse_Sig_Open)
                  m_trade.PositionClose(m_position.Ticket());
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
//| Get value of buffers for the iSAR                                |
//+------------------------------------------------------------------+
double iSARGet(const int index)
  {
   double SAR[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iSARBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iSAR,0,index,1,SAR)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iSAR indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(SAR[0]);
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
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_commission=HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap=HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==Symbol() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            m_Full_Financial_Result=deal_commission+deal_swap+deal_profit;
           }
     }
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
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+
