//---
//|                     Master_MM_Droid(barabashkakvn's edition).mq5 |
//|     Публичная бесплатная версия 2.4 для http://codebase.mql4.com |
//|                              Copyright © 2013, Musa Esmagambetov |
//|                                                   cocaine@nxt.ru |
//---
#property copyright "Copyright © 2013, Musa Esmagambetov"
#property link      "cocaine@nxt.ru"
#property version   "1.001"
#define MODE_LOW 1
#define MODE_HIGH 2

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedRisk m_money;
//--- конфигурация управления капиталом (ММ):
#define mm_math_sqrt       1                 // квадратный корень от депозита
#define mm_percent         2                 // процент депозита
#define mm_martingale      3                 // мартингейл
#define mm_antimartingale  4                 // антимартингейл
#define mm_rajan_jones     5                 // метод Райана Джонса
#define mm_larry_williams  6                 // метод Ларри Вильямса
#define mm_second_chance   7                 // защищенный (ТС сливает)
#define mm_f2stop          8                 // 2%
#define mm_test            9                 // тестовый режим для новых методов
//input int mm_user_mode = 1;                // выбор пользователем режима ММ
input int time_shift       = 2;              // временной сдвиг котировок брокера от GMT
int       start_hour       = 0;              // стартовый час
//---
input int Inp_mm_rsi_mode      = 1;              // режим ММ для ТС "RSI"
input int Inp_mm_boxes_mode    = 1;              // режим ММ для ТС "Прорыв коробки"
input int Inp_mm_weekly_mode   = 1;              // режим ММ для ТС "Ленивый трейдер"
input int Inp_mm_gap_mode      = 1;              // режим ММ для ТС "Гэп понедельника"
//---
string mm_names[]=
  {
   "ММ отключен, торги минимальным лотом","20% квадратного корня от депозита",
   "процент от депозита","мартингейл","антимартингейл","по Райану Джонсу","метод Ларри Вильямса","защищенный (ТС сливает)",
   "2 процента","тест"
  };
//--- счетчики для расчетов ММ по мартингейлу, антимартингейлу и методу Райана Джонса
int martingale_count=1,antimartingale_count=0,rajan_jones_count=0;
//---
double risk=0.05;           // уровень риска для расчетов ММ по Ларри Вильямса и проценту от депозита
double delta_rj=500;            // дельта для расчетов ММ по методу Райана Джонса
//---
double start_virtual_balance[4];             // массив начальных балансов для запуска расчетов ММ
//---
double rajan_jones_level;                    // баланс для расчетов ММ по методу Райана Джонса
double martingale_balance;                   // баланс для расчетов ММ мартингейла
double antimartingale_balance;               // баланс для расчетов ММ антимартингейла
double virtual_deposit;                      // виртуальный депозит, динамический используется в расчетах ММ для каждой ТС
double balance_separator   = 0.25;           // разделитель реального баланса на 4 виртуальных
//---
#define rsi_magic          50                // магический номер и трейлинг стоп ТС "RSI"
#define boxes_magic        35                // магический номер и трейлинг стоп ТС "Прорыв коробки"
#define weekly_magic       100               // магический номер и трейлинг стоп ТС "Ленивый трейдер"
#define gap_magic          115               // магический номер и трейлинг стоп ТС "Гэп понедельника"
//---
int orders_limit           = 3;              // количество ордеров для ТС "RSI"
int dif                    = 15;             // смещение в пунктах для ТС "RSI"
double min_lot             = 0.1;            // минимальный лот, значение сугубо для инициализации, здесь не менять!
//--- торговые сигналы 
#define sell_signal        -11               // сигнал на продажу
#define buy_signal          11               // сигнал на покупку
#define no_signal           0                // сигнал вне рынка, запускает трейлинг
#define close_buy           22               // сигнал на закрытие покупок
#define close_sell         -22               // сигнал на закрытие продаж
#define error_signal        33               // сигнал о наличии ошибки
#define clear_signal        44               // сигнал удаления несработавших ордеров
#define set_stops           55               // сигнал выставления ордеров на границах коробки
#define weekly_open         66               // сигнал выставления ордеров на границах коробки
#define weekly_close        77               // сигнал на закрытие покупок и удаление несработавших ордеров
#define gap_clear           88               // сигнал удаления несработавших ордеров
#define gap_open            99               // сигнал выставления ордеров на границах коробки
//---   
string   my_comment="Master_MM_Droid, v 2.4"; // Комментарий
int      error_number      = 0;              // код ошибки
int      rsi_sl            = 35;             // стоп лосс ТС "RSI"
int      ts_step           = 5;              // шаг трейлинга
//---
int slippage               = 5;              // слипейдж
ulong magics[4];                             // массив магических номеров
int enter                  = 6;              // отступ от цены для установки отложенных ордеров ТС Прорыв коробки
int weekly_enter           = 15;             // отступ от цены для установки отложенных ордеров ТС Ленивый трейдер
int gap_stop               = 105;            // стоп лосс ТС Гэп понедельника
//--- флаги краха ТС для подсистемы защиты депозита
bool ts_rsi_on             = true;
bool ts_weekly_on          = true;
bool ts_gap_on             = true;
bool ts_box_on             = true;
//---
string my_symbol;
int rebalance_index[]={0,0,0,0};
//---
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
int    handle_iRSI;                          // variable for storing the handle of the iRSI indicator
int Ext_mm_rsi_mode      = 0;
int Ext_mm_boxes_mode    = 0;
int Ext_mm_weekly_mode   = 0;
int Ext_mm_gap_mode      = 0;

double prev_prev_lastprofit=0.0;
double prev_lastprofit=0.0;
double lastprofit=0.0;
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
//--- create handle of the indicator iRSI
   handle_iRSI=iRSI(Symbol(),Period(),14,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iRSI==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
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
   my_symbol=m_symbol.Name();

   magics[0] = rsi_magic;
   magics[1] = boxes_magic;
   magics[2] = weekly_magic;
   magics[3] = gap_magic;

   if(m_symbol.Digits()==5 || m_symbol.Digits()==3)
     {
      gap_stop       *=10;
      enter          *=10;
      slippage       *= 10;
      ts_step        *= 10;
      rsi_sl         *= 10;
      weekly_enter   *=10;
      dif            *=10;
     }

   if(balance_separator==0)
     {
      balance_separator=1;
     }
   else
     {
      double t_blnc=balance_separator*m_account.Balance();
      rajan_jones_level=t_blnc;
      martingale_balance=t_blnc;
      antimartingale_balance=t_blnc;
      virtual_deposit=t_blnc;
      //---   
      start_virtual_balance[0] = t_blnc;
      start_virtual_balance[1] = t_blnc;
      start_virtual_balance[2] = t_blnc;
      start_virtual_balance[3] = t_blnc;
     }
   min_lot=MathMax(NormalizeDouble(virtual_deposit/100000,2),m_symbol.LotsMin());
//---
   Ext_mm_rsi_mode      = Inp_mm_rsi_mode;
   Ext_mm_boxes_mode    = Inp_mm_boxes_mode;
   Ext_mm_weekly_mode   = Inp_mm_weekly_mode;
   Ext_mm_gap_mode      = Inp_mm_gap_mode;
//---
   prev_prev_lastprofit=0.0;
   prev_lastprofit=0.0;
   lastprofit=0.0;
//---
   return(INIT_SUCCEEDED);
  }
//---
//| Expert deinitialization function                                 |
//---
void OnDeinit(const int reason)
  {
   info();
  }
//---
//| Expert tick function                                             |
//---
void OnTick()
  {
   if(IsTradeAllowed()==false || iTickVolume(0)>1)
      return;
   for(int main_count=0; main_count<4; main_count++)
     {
      ulong magic_number=magics[main_count];
      switch(scan_market(my_symbol,magic_number))
        {
         case sell_signal:
            if(ts_rsi_on==true)
            sell_routine(Ext_mm_rsi_mode,my_symbol,magic_number,rsi_sl);
            break;
         case buy_signal:
            if(ts_rsi_on==true)
            buy_routine(Ext_mm_rsi_mode,my_symbol,magic_number,rsi_sl);
            break;
         case clear_signal:
            close_all(my_symbol,magic_number);
            break;
         case set_stops:
            if(ts_box_on==true)
            set_stop_orders(Ext_mm_boxes_mode,my_symbol,magic_number);
            break;
         case weekly_open:
            if(ts_weekly_on==true)
            weekly_orders(Ext_mm_weekly_mode,my_symbol,magic_number);
            break;
         case weekly_close:
            close_all(my_symbol,magic_number);
            break;
         case gap_clear:
            close_all(my_symbol,magic_number);
            break;
         case gap_open:
            if(ts_gap_on==true)
            gap_weekly(Ext_mm_gap_mode,my_symbol,magic_number);
            break;
         case no_signal:
            trailing(my_symbol,magic_number);
            break;
         case error_signal:
            Print(error_func(error_number));
            error_number=0;
            break;
        }
     }
   return;
  }
//---
//| Трейлинг                                                         |
//---
void trailing(string symbol,ulong mn)
  {
   ulong ts=mn;
   if(m_symbol.Digits()==5 || m_symbol.Digits()==3)
      ts*=10;

   while(!IsTradeAllowed())
      Sleep(100);
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==symbol && m_position.Magic()==mn)
            trail_position(m_position.Ticket(),(int)ts);
   return;
  }
//---
//| Трейлинг позиций                                                 |
//---
void trail_position(ulong ticket,int treil_stop)
  {
   if(!RefreshRates())
      return;

   if(m_position.PositionType()==POSITION_TYPE_BUY)
     {
      if(m_symbol.Bid()-treil_stop*m_symbol.Point()>m_position.StopLoss()+ts_step*m_symbol.Point())
         trail_routine(ticket,NormalizeDouble(m_symbol.Bid()-treil_stop*m_symbol.Point(),m_symbol.Digits()));
     }
   if(m_position.PositionType()==POSITION_TYPE_SELL)
     {
      if(m_symbol.Ask()+treil_stop*m_symbol.Point()<m_position.StopLoss()-ts_step*m_symbol.Point())
         trail_routine(ticket,NormalizeDouble(m_symbol.Ask()+treil_stop*m_symbol.Point(),m_symbol.Digits()));
     }
//---
   return;
  }
//---
//| Рутина трейлинга                                                 |
//---
void trail_routine(ulong ticket,double price)
  {
   int count=0;
   if(m_position.SelectByTicket(ticket))
      while(m_trade.PositionModify(ticket,price,0.0)==false)
        {
         Sleep(30000);
         //RefreshRates();
         count++;
         if(count>5)
            break;
        }
   return;
  }
//---
//| Закрытие всех позиций и удаление всех отложенных ордеров         |
//---
void close_all(string symbol,ulong mn)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==symbol && m_order.Magic()==mn)
            close_order(m_order.Ticket());

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==symbol && m_position.Magic()==mn)
            close_position(m_position.Ticket());

   return;
  }
//---
//| Рутина для удаления отложенных ордеров                           |
//---
void close_order(ulong ticket)
  {
   bool temp = false;
   int count = 0;
   while(!IsTradeAllowed())
      Sleep(100);
   if(m_order.Select(ticket))
      while(temp==false)
        {
         temp=m_trade.OrderDelete(ticket);
         if(!temp)
           {
            Sleep(30000);
            count++;
            if(count>5)
               break;
           }
        }
   return;
  }
//---
//| Рутина для закрытия позиций                                      |
//---
void close_position(ulong ticket)
  {
   bool temp = false;
   int count = 0;
   while(!IsTradeAllowed())
      Sleep(100);
   if(m_position.SelectByTicket(ticket))
      while(temp==false)
        {
         temp=m_trade.PositionClose(ticket);
         if(!temp)
           {
            Sleep(30000);
            count++;
            if(count>5)
               break;
           }
        }
   return;
  }
//---
//| Подсчет отложенных ордеров                                       |
//---
int calculate_orders(string symbol,ENUM_ORDER_TYPE cmd,ulong mn)
  {
   int count=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))
         if(m_order.Symbol()==symbol && m_order.Magic()==mn && m_order.OrderType()==cmd)
            count++;
   return (count);
  }
//---
//| Подсчет позиций                                                  |
//---
int calculate_positions(string symbol,ENUM_POSITION_TYPE cmd,ulong mn)
  {
   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==symbol && m_position.Magic()==mn && m_position.PositionType()==cmd)
            count++;
   return (count);
  }
//---
//| Поиск сигналов                                                   |
//---
int scan_market(string symbol,ulong magic)
  {
   if(!RefreshRates())
      return (error_signal);
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
//error_number=GetLastError();
//if(error_number!=0)
//   return (error_signal);
   int b_positions = calculate_positions(symbol,POSITION_TYPE_BUY, magic);
   int s_positions = calculate_positions(symbol,POSITION_TYPE_SELL, magic);
   int t_positions=s_positions+b_positions;
   int st_orders=stop_orders(symbol,magic);

   switch((int)magic)
     {
      case rsi_magic:
        {
         double open_price=0;
         double r1 = iRSIGet(1);
         double r2 = iRSIGet(2);
         //--- нужно получить цену открытия последней позиции  
         //--- "total-1" элемент - это будет последняя открытая позициия 
         int total=PositionsTotal();
         for(int i=total-1;i>=0;i--)
           {
            if(m_position.SelectByIndex(i))
               if(m_position.Symbol()==symbol && m_position.Magic()==rsi_magic)
                 {
                  open_price=m_position.PriceOpen();
                  break;
                 }
           }
         //--- критерии покупки      
         if((r2<30 && r1>30 && b_positions==0) || 
            (b_positions>0 && b_positions<orders_limit && m_symbol.Bid()>open_price+dif*m_symbol.Point()))
            return (buy_signal);
         //--- критерии продажи      
         if((r2>70 && r1<70 && s_positions==0) || 
            (s_positions>0 && s_positions<orders_limit && m_symbol.Ask()<open_price-dif*m_symbol.Point()))
            return (sell_signal);
         break;
        }
      case boxes_magic:
        {
         int fgfg=0; // для форматирования кода стилизатора :)
         //---- критерии    
         if(str1.hour==(0+time_shift) || str1.hour==(10+time_shift) || str1.hour==(16+time_shift))
            return (clear_signal);
         if((str1.hour==(6+time_shift) || str1.hour==(12+time_shift) || str1.hour==(20+time_shift)) && st_orders==0)
            return (set_stops);
         break;
        }
      case weekly_magic:
        {
         int fgfg=0; // для форматирования кода стилизатора :)
         //--- критерии          
         if(str1.day_of_week==1 && str1.hour>(start_hour+time_shift) && 
            str1.hour<(6+time_shift) && t_positions==0 && st_orders==0)
            return (weekly_open);
         if(str1.day_of_week==5 && str1.hour>(18+time_shift) && t_positions>=0)
            return(weekly_close);
         break;
        }
      case gap_magic:
        {
         int fgfg=0; // для форматирования кода стилизатора :)
         //--- критерии  
         //--- есть есть самый старый отложенный ордер (его индекс "0") и
         //--- индекс бара PERIOD_D1, на котором его выставили >=1
         if(m_order.SelectByIndex(0))
            if(iBarsOpen(symbol,PERIOD_D1,m_order.TimeSetup())>=1)
               return (gap_clear);
         if(t_positions==0 && str1.hour==0)
            return(gap_open);
         break;
        }
     }
   return(no_signal);
  }
//---
//|                                                                  |
//---
int stop_orders(string symbol,ulong mn)
  {
   return(calculate_orders(symbol,ORDER_TYPE_SELL_STOP, mn) + calculate_orders(symbol, ORDER_TYPE_BUY_STOP, mn));
  }
//---
//| Покупка, возвращает тикет                                        |
//---
int gap_weekly(int mm,string symbol,ulong magic)
  {
   while(!IsTradeAllowed())
      Sleep(100);

   if(!RefreshRates())
      return(0);

   double buy_sl  = NormalizeDouble(m_symbol.Ask()-gap_stop*m_symbol.Point(), m_symbol.Digits());
   double sell_sl = NormalizeDouble(m_symbol.Bid()+gap_stop*m_symbol.Point(), m_symbol.Digits());
   int stop=(int)((buy_sl-sell_sl)/m_symbol.Point());
   int count=0;
   double lot=mm_func(mm,symbol,magic,stop);
   if(lot==0)
     {
      Print("ТС Недельный гэп отключена из-за слива");
      ts_gap_on=false;
      return(0);
     }

   if(iOpen(symbol,PERIOD_D1,0)<iLow(symbol,PERIOD_D1,1))
     {
      m_trade.SetExpertMagicNumber(magic);
      while(!m_trade.Buy(lot,symbol,m_symbol.Ask(),buy_sl,0.0,my_comment))
        {
         Sleep(30000);
         if(!RefreshRates())
            return(0);
         count++;
         if(count>10)
            break;
        }
      count=0;
     }
   else
   if(iOpen(symbol,PERIOD_D1,0)>iHigh(symbol,PERIOD_D1,1))
     {
      m_trade.SetExpertMagicNumber(magic);
      while(!m_trade.Sell(lot,symbol,m_symbol.Bid(),sell_sl,0.0,my_comment))
        {
         Sleep(30000);
         if(!RefreshRates())
            return(0);
         count++;
         if(count>10)
            break;
        }
      count=0;
     }
   return(0);
  }
//---
//| Покупка, возвращает тикет                                        |
//---
int weekly_orders(int mm,string symbol,ulong magic)
  {
   while(!IsTradeAllowed())
      Sleep(100);
   double high=iHigh(symbol,PERIOD_M5,iHighest(symbol,PERIOD_M5,MODE_HIGH,(start_hour+time_shift)*16,0));
   double low=iLow(symbol,PERIOD_M5,iLowest(symbol,PERIOD_M5,MODE_LOW,(start_hour+time_shift)*16,0));
   double buy  = NormalizeDouble(high + weekly_enter*m_symbol.Point(), m_symbol.Digits());
   double sell = NormalizeDouble(low - weekly_enter*m_symbol.Point(), m_symbol.Digits());
   int stop=(int)((buy-sell)/m_symbol.Point());
   int count=0;
   double lot=mm_func(mm,symbol,magic,stop);
   if(lot==0)
     {
      Print("ТС Ленивый трейдер отключена из-за слива");
      ts_weekly_on=false;
      return (0);
     }

   if(!RefreshRates())
      return(0);

   m_trade.SetExpertMagicNumber(magic);

   while(!m_trade.BuyStop(lot,buy,symbol,sell,0.0,0,0,my_comment))
     {
      Sleep(30000);
      if(!RefreshRates())
         return(0);
      count++;
      if(count>10)
         break;
     }
   count=0;

   if(!RefreshRates())
      return(0);

   while(!m_trade.SellStop(lot,sell,symbol,buy,0.0,0,0,my_comment))
     {
      Sleep(30000);
      if(!RefreshRates())
         return(0);
      count++;
      if(count>10)
         break;
     }
   return (0);
  }
//---
//| Покупка                                                          |
//---
int set_stop_orders(int mm,string symbol,ulong magic)
  {
   while(!IsTradeAllowed())
      Sleep(100);
   double high = iHigh(symbol, PERIOD_H1,1);
   double low  = iLow(symbol, PERIOD_H1,1);

   double buy  = NormalizeDouble(high + enter*m_symbol.Point(), m_symbol.Digits());
   double sell = NormalizeDouble(low - enter*m_symbol.Point(), m_symbol.Digits());
   int stop=(int)((buy-sell)/m_symbol.Point());
   double lot=mm_func(mm,symbol,magic,stop);
   if(lot==0)
     {
      Print("ТС Прорыв коробки отключена из-за слива");
      ts_box_on=false;
      return (0);
     }
   int count=0;

   if(!RefreshRates())
      return(0);

   m_trade.SetExpertMagicNumber(magic);

   while(!m_trade.BuyStop(lot,buy,symbol,sell,0.0,0,0,my_comment))
     {
      Sleep(30000);
      if(!RefreshRates())
         return(0);
      count++;
      if(count>5)
         break;
     }

   count=0;

   if(!RefreshRates())
      return(0);

   while(!m_trade.SellStop(lot,sell,symbol,buy,0.0,0,0,my_comment))
     {
      Sleep(30000);
      if(!RefreshRates())
         return(0);
      count++;
      if(count>5)
         break;
     }

   return (0);
  }
//+------------------------------------------------------------------+
//| Покупка                                                          |
//+------------------------------------------------------------------+
void buy_routine(int mm,string symbol,ulong magic,int sl)
  {
   while(!IsTradeAllowed())
      Sleep(100);
   int count=0;
   int i=-1;
   double lot=mm_func(mm,symbol,magic,35);
   if(lot==0)
     {
      Print("ТС RSI отключена из-за слива");
      ts_rsi_on=false;
      return;
     }

   if(!RefreshRates())
      return;

   m_trade.SetExpertMagicNumber(magic);
   while(!m_trade.Buy(lot,symbol,m_symbol.Ask(),m_symbol.Ask()-sl*m_symbol.Point(),0.0,my_comment))
     {
      Sleep(30000);
      if(!RefreshRates())
         return;
      count++;
      if(count>5)
         break;
     }
   return;
  }
//+------------------------------------------------------------------+
//| Продажа                                                          |
//+------------------------------------------------------------------+
void sell_routine(int mm,string symbol,ulong magic,int sl)
  {
   while(!IsTradeAllowed())
      Sleep(100);
   int count=0;
   int i=-1;
   double lot=mm_func(mm,symbol,magic,35);
   if(lot==0)
     {
      Print("ТС RSI отключена из-за слива");
      ts_rsi_on=false;
      return;
     }

   if(!RefreshRates())
      return;

   m_trade.SetExpertMagicNumber(magic);
   while(!m_trade.Sell(lot,symbol,m_symbol.Bid(),m_symbol.Bid()+sl*m_symbol.Point(),0.0,my_comment))
     {
      Sleep(30000);
      if(!RefreshRates())
         return;
      count++;
      if(count>5)
         break;
     }

   return;
  }
//+------------------------------------------------------------------+
//| MM                                                               |
//+------------------------------------------------------------------+
double mm_func(int mm_mode,string symbol,ulong mn,int stop)
  {
   double lot=0;
   rebalance(get_balance(mn));
//--- 
   if(m_symbol.Digits()==5 || m_symbol.Digits()==3)
     {
      stop*=10;
     }
//--- Ребалансировка капитала, перераспределение прибыли 
   virtual_deposit=virtual_balance(symbol,mn,get_rebalance_index(mn));
//---
   switch(mm_mode)
     {
      case mm_math_sqrt: //1
         lot=math_sqrt(virtual_deposit);
         break;
      case mm_percent:  //2
         lot=percent(virtual_deposit);
         break;
      case mm_martingale: //3
         lot=martingale(virtual_deposit);
         break;
      case mm_antimartingale: //4
         lot=antimartingale(virtual_deposit);
         break;
      case mm_rajan_jones: //5
         lot=rajan_jones(virtual_deposit,mn);
         break;
      case mm_larry_williams: //6     
         lot=larry_williams(virtual_deposit,5);
         break;
      case mm_second_chance: //7
         lot=min_lot;
         break;
      case mm_f2stop: //8 
         lot=quasi_lots(symbol,stop,risk,virtual_deposit);
         break;
      case mm_test: //9
         //lot = virtual_deposit / ((stop*MarketInfo(symbol, MODE_TICKVALUE)) / risk);
         lot=crazy(virtual_deposit);
         break;
      default: lot=0.1;
      break;
     }
//---
   double lot_step=m_symbol.LotsStep();
   lot=MathRound(lot/lot_step)*lot_step;
//---
   lot=MathMin(MathMax(lot,min_lot),m_symbol.LotsMax());
   Comment(" Запрос к режиму ММ ",mm_names[mm_mode],"\n Символ запроса: ",symbol," \n ",ts_name(mn),
           "  \n Виртуальный депозит: ",virtual_deposit," \n Реальный баланс: ",m_account.Balance(),
           " \n Запрошенный лот: ",NormalizeDouble(lot,2));
//---
   double safe_level=virtual_deposit-margin_to_lot(symbol,lot);
   if(safe_level>0)
     {
      return(NormalizeDouble(lot, 2));
     }
   else if(safe_level<=0)
     {
      return(second_chance(symbol, lot, virtual_deposit, mm_mode, mn));
     }
//---
   return(NormalizeDouble(lot, 2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double second_chance(string symbol,double lot,double deposit,int mm,ulong mn)
  {
//---
   Print(" Не хватает виртуальной маржи, режим ММ: (",mm_names[mm],"), символ: ",symbol);
   Print(" Требуемая виртуальная маржа для запрошенного лота: ",margin_to_lot(symbol,lot));
   Print(" Запрошенный лот: ",lot);
   Print(" Остаток виртуального депозита: ",deposit);
//---       
   double temp=m_account.Balance()-min_lot*400;
//---
   if(temp<=0 || mm==mm_second_chance)
     {
      Print(" ММ полностью отключен, ТС: ",ts_name(mn)," слила виртуальный депозит: ",deposit);
      return(0);
     }
//---
   else if(temp>=0 && mm!=mm_second_chance)
     {
      //start_virtual_balance += margin_to_lot(symbol, MarketInfo(Symbol(), MODE_MINLOT)*3);
      deposit+=MathAbs(deposit)+margin_to_lot(symbol,min_lot*50);
      //---
      Print(" Включен режим последнего шанса, увеличен депозит на 50 минимальных лотов: ",deposit);
      //---                        
      switch((int)mn)
        {
         case 35:
            //"ТС Прорыв коробки";
            Ext_mm_boxes_mode=mm_second_chance;
            break;
         case 50:
            //"ТС RSI";
            Ext_mm_rsi_mode=mm_second_chance;
            break;
         case 100:
            //"ТС Ленивый трейдер";
            Ext_mm_weekly_mode=mm_second_chance;
            break;
         case 115:
            //"ТС Гэп понедельника";
            Ext_mm_gap_mode=mm_second_chance;
            break;
        }
      //---
      Print(" Текущая ТС: ",ts_name(mn)," Переключен режим ММ на: ",mm_names[mm_second_chance]);
      return(min_lot);
     }
//---
   return(0);
  }
//---
double get_balance(ulong mn)
  {
   double virt_balance=0.0;
   switch((int)mn)
     {
      case 35:
         //"ТС Прорыв коробки";
         virt_balance=start_virtual_balance[0];
         break;
      case 50:
         //"ТС RSI";
         virt_balance=start_virtual_balance[1];
         break;
      case 100:
         //"ТС Ленивый трейдер";
         virt_balance=start_virtual_balance[2];
         break;
      case 115:
         //"ТС Гэп понедельника";
         virt_balance=start_virtual_balance[3];
         break;
     }
   return(virt_balance);
  }
//---
void set_balance(int mn,double balance)
  {
   switch(mn)
     {
      case 35:
         //"ТС Прорыв коробки";
         start_virtual_balance[0]=balance;
         break;
      case 50:
         //"ТС RSI";
         start_virtual_balance[1]=balance;
         break;
      case 100:
         //"ТС Ленивый трейдер";
         start_virtual_balance[2]=balance;
         break;
      case 115:
         //"ТС Гэп понедельника";
         start_virtual_balance[3]=balance;
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_rebalance_index(ulong mn)
  {
   int reb_index=-1;
   switch((int)mn)
     {
      case 35:
         //"ТС Прорыв коробки";
         reb_index=rebalance_index[0];
         break;
      case 50:
         //"ТС RSI";
         reb_index=rebalance_index[1];
         break;
      case 100:
         //"ТС Ленивый трейдер";
         reb_index=rebalance_index[2];
         break;
      case 115:
         //"ТС Гэп понедельника";
         reb_index=rebalance_index[3];
         break;
     }
   return(reb_index);
  }
//---
void set_rebalance_index(int mn,int s)
  {
   switch(mn)
     {
      case 35:
         //"ТС Прорыв коробки";
         rebalance_index[0]=s;
         break;
      case 50:
         //"ТС RSI";
         rebalance_index[1]=s;
         break;
      case 100:
         //"ТС Ленивый трейдер";
         rebalance_index[2]=s;
         break;
      case 115:
         //"ТС Гэп понедельника";
         rebalance_index[3]=s;
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double virtual_balance(string symbol,ulong mn,int seek=0)
  {
   double balance=get_balance(mn);
//--- запросить историю (последние 10 дней)
   HistorySelect(TimeCurrent()-86400*10,TimeCurrent()+86400);
//--- переменные для получения значений из свойств сделки 
   uint     d_total=HistoryDealsTotal();
   ulong    d_ticket=0;
   long     d_entry=0;
   string   d_symbol="";
   long     d_magic=0;
   double   d_profit=0.0;
//--- for all deals 
   for(uint i=0;i<d_total;i++)
     {
      //--- try to get deals ticket 
      if((d_ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties 
         d_entry =HistoryDealGetInteger(d_ticket,DEAL_ENTRY);
         d_symbol=HistoryDealGetString(d_ticket,DEAL_SYMBOL);
         d_magic=HistoryDealGetInteger(d_ticket,DEAL_MAGIC);
         d_profit=HistoryDealGetDouble(d_ticket,DEAL_PROFIT);
         //--- only for current symbol 
         if(d_entry==DEAL_ENTRY_OUT && d_symbol==symbol && d_magic==mn)
            balance+=d_profit;
        }
     }
//---
   return (balance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int count_history(string symbol,int mn)
  {
   int t=0;
//--- запросить историю (последние 10 дней)
   HistorySelect(TimeCurrent()-86400*10,TimeCurrent()+86400);
//--- переменные для получения значений из свойств сделки 
   uint     d_total=HistoryDealsTotal();
   ulong    d_ticket=0;
   long     d_entry=0;
   string   d_symbol="";
   long     d_magic=0;
//--- for all deals 
   for(uint i=0;i<d_total;i++)
     {
      //--- try to get deals ticket 
      if((d_ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties 
         d_entry =HistoryDealGetInteger(d_ticket,DEAL_ENTRY);
         d_symbol=HistoryDealGetString(d_ticket,DEAL_SYMBOL);
         d_magic=HistoryDealGetInteger(d_ticket,DEAL_MAGIC);
         //--- only for current symbol 
         if(d_entry==DEAL_ENTRY_OUT && d_symbol==symbol && d_magic==mn)
            t++;
        }
     }
   return (t+1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ts_name(ulong mn)
  {
   string name;
   switch((int)mn)
     {
      case 35:
         name=" ТС Прорыв коробки";
         break;
      case 50:
         name=" ТС RSI";
         break;
      case 100:
         name=" ТС Ленивый трейдер";
         break;
      case 115:
         name=" ТС Гэп понедельника";
         break;
     }
   return (name);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double margin_to_lot(string symbol,double lot_to_check)
  {
   if(!RefreshRates())
      return(0);
   double margin_check=m_account.MarginCheck(symbol,ORDER_TYPE_BUY,1.0,m_symbol.Ask());
   return (NormalizeDouble(lot_to_check * margin_check,2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double math_sqrt(double deposit)
  {
   double lot=0.2*MathSqrt(deposit/1000);
   return (lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double percent(double deposit)
  {
   if(!RefreshRates())
      return(0);
   double margin_check=m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,1.0,m_symbol.Ask());
   double lot=virtual_deposit*risk/margin_check;// тоже самое   
   return (lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double crazy(double deposit)
  {
   double lot=0;

//--- prev_prev_lastprofit, prev_lastprofit и lastprofit получаем в OnTradeTransaction
   lot=NormalizeDouble(m_account.FreeMargin()*risk/1000.0,1);
   if(lastprofit<0 && prev_lastprofit<0 && prev_prev_lastprofit<0)
      return(lot);
   return(min_lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double quasi_lots(string symbol,int stop,double ts_risk,double deposit)
  {
   double bet=deposit*ts_risk;
//double pip_price = NormalizeDouble(bet/stop,2);
//double contract_size = NormalizeDouble((pip_price / MarketInfo(symbol, MODE_POINT)/100000),2);

   double step=m_symbol.LotsStep();
   double stop_value=stop*m_symbol.TickValue();
   double contract_size=NormalizeDouble(bet/stop_value,2);
   contract_size=MathFloor(contract_size/step)*step;
   return(contract_size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double antimartingale(double deposit)
  {
   double lot;
   if(antimartingale_balance>deposit)
     {
      antimartingale_count --;
     }
   if(antimartingale_balance<=deposit)
     {
      antimartingale_count++;
     }
   lot=antimartingale_count*min_lot;
   antimartingale_balance=deposit;
   return (lot);
  }
//---
double martingale(double deposit)
  {
   double lot;
   if(martingale_balance<=deposit)
     {
      martingale_count=1; //min_lot = NormalizeDouble(virtual_deposit/100000,2);
     }
   if(martingale_balance>deposit)
     {
      martingale_count+=martingale_count;
     }
   lot=martingale_count*min_lot;
   martingale_balance=deposit;
   return (lot);
  }
//---
//| rajan_jones                                                      |
//---
double rajan_jones(double deposit,ulong mn)
  {
   double lot;
//[(число контрактов х число контрактов - число контрактов)/2] х дельта = минимальный уровень прибыли
   while(rajan_jones_level>deposit && rajan_jones_count>=1)
     {
      rajan_jones_count --;
      //if (rajan_jones_count <= 1) {rajan_jones_level = start_virtual_balance; lot = min_lot; break;}
      if(rajan_jones_count<=1) {rajan_jones_level=get_balance(mn); lot=min_lot; break;}
      rajan_jones_level=(((rajan_jones_count*rajan_jones_count-rajan_jones_count)/2)*delta_rj);
     }

   while(deposit-rajan_jones_level>delta_rj)
     {
      rajan_jones_count++;
      rajan_jones_level=(((rajan_jones_count*rajan_jones_count-rajan_jones_count)/2)*delta_rj);
     }

   lot=min_lot*rajan_jones_count;
   return (lot);
  }
//+------------------------------------------------------------------+
//| Larry Williams                                                   |
//+------------------------------------------------------------------+
double larry_williams(double deposit,double lw_risk)
  {
   return (deposit * (lw_risk / 100) / deposit);
  }
//+------------------------------------------------------------------+
//| Ребалансировка капитала, перераспределение прибыли               |
//+------------------------------------------------------------------+
void rebalance(double balance)
  {
   if(NormalizeDouble(virtual_deposit/balance,0)>3)
     {
      for(int i=0; i<4; i++)
        {
         set_rebalance_index((int)magics[i],count_history(m_symbol.Name(),(int)magics[i]));
         set_balance((int)magics[i],balance_separator*m_account.Balance());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_mm_name(int mn)
  {
   switch(mn)
     {
      case 35:
         //" ТС Прорыв коробки";
         return (Ext_mm_boxes_mode);
         break;
      case 50:
         //" ТС RSI";
         return (Ext_mm_rsi_mode);
         break;
      case 100:
         //" ТС Ленивый трейдер";
         return (Ext_mm_weekly_mode);
         break;
      case 115:
         //" ТС Гэп понедельника";
         return (Ext_mm_gap_mode);
         break;
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int info()
  {
   Print(" реальный депозит: ",m_account.Balance());
   for(int i=0; i<4; i++)
     {
      int temp=(int)magics[i];
      Print(ts_name(temp),", виртуальный депозит: ",
            NormalizeDouble(virtual_balance(m_symbol.Name(),temp,get_rebalance_index(temp)),2),
            " индекс: ",get_rebalance_index(temp),
            " режим ММ: ",mm_names[get_mm_name(temp)]);
     }
   return(0);
  }
//-----------------------обработчик ошибок   
string error_func(int error)
  {
   switch(error)
     {
      case(0):   return("Нет ошибки");
      case(1):   return("Нет ошибки, но результат неизвестен");
      case(2):   return("Общая ошибка");
      case(3):   return("Неправильные параметры");
      case(4):   return("Торговый сервер занят");
      case(5):   return("Старая версия клиентского терминала");
      case(6):   return("Нет связи с торговым сервером");
      case(7):   return("Недостаточно прав");
      case(8):   return("Слишком частые запросы");
      case(9):   return("Недопустимая операция, нарушающая функционирование сервера");
      case(64):  return("Счет заблокирован");
      case(65):  return("Неправильный номер счета");
      case(128): return("Истек срок ожидания совершения сделки");
      case(129): return("Неправильная цена");
      case(130): return("Неправильные стопы");
      case(131): return("Неправильный объём");
      case(132): return("Рынок закрыт");
      case(133): return("Торговля запрещена");
      case(134): return("Недостаточно денег для совершения операции");
      case(135): return("Цена изменилась");
      case(136): return("Нет цен");
      case(137): return("Брокер занят");
      case(138): return("Новые цены");
      case(139): return("Ордер заблокирован и уже обрабатывается");
      case(140): return("Разрешена только покупка");
      case(141): return("Слишком много запросов");
      case(145): return("Модификация запрещена, т.к. ордер слишком близок к рынку");
      case(146): return("Подсистема торговли занята");
      case(147): return("Использование даты истечения запрещено брокером");
      case(148): return("Количество открытых и отложенных ордеров достигло предела, установленного брокером");
      case(149): return("Попытка открыть противоположную позицию к уже существующей в случае, если хеджирование запрещено");
      case(150): return("Попытка закрыть позицию по инструменту в противоречии с правилом FIFO");
      case(4000): return("    Нет ошибки");
      case(4001): return("    Неправильный указатель функции");
      case(4002): return("Индекс массива - вне диапазона");
      case(4003): return("Нет памяти для стека функций");
      case(4004): return("Переполнение стека после рекурсивного вызова");
      case(4005): return("На стеке нет памяти для передачи параметров");
      case(4006): return("Нет памяти для строкового параметра");
      case(4007): return("Нет памяти для временной строки");
      case(4008): return("Неинициализированная строка");
      case(4009): return("Неинициализированная строка в массиве");
      case(4010): return("Нет памяти для строкового массива");
      case(4011): return("Слишком длинная строка");
      case(4012): return("Остаток от деления на ноль");
      case(4013): return("Деление на ноль");
      case(4014): return("Неизвестная команда");
      case(4015): return("Неправильный переход");
      case(4016): return("Неинициализированный массив");
      case(4017): return("Вызовы DLL не разрешены");
      case(4018): return("Невозможно загрузить библиотеку");
      case(4019): return("Невозможно вызвать функцию");
      case(4020): return("Вызовы внешних библиотечных функций не разрешены");
      case(4021): return("Недостаточно памяти для строки, возвращаемой из функции");
      case(4022): return("Система занята");
      case(4050): return("Неправильное количество параметров функции");
      case(4051): return("Недопустимое значение параметра функции");
      case(4052): return("Внутренняя ошибка строковой функции");
      case(4053): return("Ошибка массива");
      case(4054): return("Неправильное использование массива-таймсерии");
      case(4055): return("Ошибка пользовательского индикатора");
      case(4056): return("Массивы несовместимы");
      case(4057): return("Ошибка обработки глобальныех переменных");
      case(4058): return("Глобальная переменная не обнаружена");
      case(4059): return("Функция не разрешена в тестовом режиме");
      case(4060): return("Функция не разрешена");
      case(4061): return("Ошибка отправки почты");
      case(4062): return("Ожидается параметр типа string");
      case(4063): return("Ожидается параметр типа integer");
      case(4064): return("Ожидается параметр типа double");
      case(4065): return("В качестве параметра ожидается массив");
      case(4066): return("Запрошенные исторические данные в состоянии обновления");
      case(4067): return("Ошибка при выполнении торговой операции");
      case(4099): return("Конец файла");
      case(4100): return("Ошибка при работе с файлом");
      case(4101): return("Неправильное имя файла");
      case(4102): return("Слишком много открытых файлов");
      case(4103): return("Невозможно открыть файл");
      case(4104): return("Несовместимый режим доступа к файлу");
      case(4105): return("Ни один ордер не выбран");
      case(4106): return("Неизвестный символ");
      case(4107): return("Неправильный параметр цены для торговой функции");
      case(4108): return("Неверный номер тикета");
      case(4109): return("Торговля не разрешена. Необходимо включить опцию -*- Разрешить советнику торговать -*- в свойствах эксперта.");
      case(4110): return("Длинные позиции не разрешены. Необходимо проверить свойства эксперта.");
      case(4111): return("Короткие позиции не разрешены. Необходимо проверить свойства эксперта.");
      case(4200): return("Объект уже существует");
      case(4201): return("Запрошено неизвестное свойство объекта");
      case(4202): return("Объект не существует");
      case(4203): return("Неизвестный тип объекта");
      case(4204): return("Нет имени объекта");
      case(4205): return("Ошибка координат объекта");
      case(4206): return("Не найдено указанное подокно");
      case(4207): return("Ошибка при работе с объектом");
      default:   return("Нераспознанная ошибка");
     }
  }
//---
//|                                                                  |
//---
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//---
//|                                                                  |
//---
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
  }
//---
//| Refreshes the symbol quotes data                                 |
//---
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
//---
//| Gets the information about permission to trade                   |
//---
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
//--- 
//| Get TickVolume for specified bar index                           | 
//--- 
long iTickVolume(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   long TickVolume[1];
   long tickvolume=0;
   int copied=CopyTickVolume(symbol,timeframe,index,1,TickVolume);
   if(copied>0) tickvolume=TickVolume[0];
   return(tickvolume);
  }
//---
//| Get value of buffers for the iRSI                                |
//---
double iRSIGet(const int index)
  {
   double RSI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSI array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iRSI,0,index,1,RSI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(RSI[0]);
  }
//---
//| Bar number on which the order/position is open                   |
//---
int iBarsOpen(string symbol,
              ENUM_TIMEFRAMES timeframe,
              datetime time)
  {
   if(time<0)
      return(-1);
   datetime Arr[],time1;
   CopyTime(symbol,timeframe,0,1,Arr);
   time1=Arr[0];
   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      if(ArraySize(Arr)>1)
         return(ArraySize(Arr));
      if(time<time1)
         return(1);
      else
         return(0);
     }
   else
      return(-1);
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
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
        }
      else
         return;
      if(deal_entry==DEAL_ENTRY_OUT)
        {
         prev_prev_lastprofit=prev_lastprofit;
         prev_lastprofit=lastprofit;
         lastprofit=deal_profit;
        }
     }
  }
//+------------------------------------------------------------------+
