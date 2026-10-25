//+------------------------------------------------------------------+
//|                                                 Risk Manager.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//|                                                  Anatoly Sergeev |
//|                                                       12/06/2014 |
//+------------------------------------------------------------------+
#include<Trade\Trade.mqh>
#property copyright "Anatoly Sergeev"
#property link      "Anatoly.Sergeev@ya.ru"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OrderFilling
  {
   type_1,         // Все/Ничего
   type_2,         // Все/Частично
   type_3,         // Вернуть
  };

input double risk= 5.00;                  //Риск на день в %:
input double riskTrade = 0.00;            //Риск на сделку в %:
input double riskTrail = 0.00;            //Трейлинг-стоп дневной прибыли в %:
input OrderFilling typeFilling = type_1;  //Режим исполнения ордеров:

CTrade  tr;            //Объект класса CTrade
MqlDateTime dt;        //Enum для выбора дня запроса баланса
double balance;        //Баланс на начало дня
double maxDayProfit;
string prefix;         //Уникальный префикс счета
//+------------------------------------------------------------------+
//|Функция инициализации                                             |
//+------------------------------------------------------------------+
void OnInit()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Проверьте в настройках терминала разрешение на автоматическую торговлю!");   //проверка разрешений на торговлю
        }else{
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Автоматическая торговля запрещена в свойствах программы для ",__FILE__);   //проверка разрешений на торговлю
        }
     }

   prefix=IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))+"_";

   tr.SetDeviationInPoints(10000);            //допустимое проскальзывание в пунктах при совершении покупки/продажи

   switch(typeFilling)
     {                         //Политика исполнения ордера
      case type_1:
         tr.SetTypeFilling(ORDER_FILLING_FOK);
         break;
      case type_2:
         tr.SetTypeFilling(ORDER_FILLING_IOC);
         break;
      case type_3:
         tr.SetTypeFilling(ORDER_FILLING_RETURN);
         break;
     }

   checkBalance();    //первичное заполнение глобальных переменных терминала
   dayRisk();         //Первичный расчет
  }
//+------------------------------------------------------------------+
//|Обработка тиков                                                   |
//+------------------------------------------------------------------+
void OnTick()
  {
   checkBalance();
   if(dayRisk())
     {
      if(riskTrade > 0.0)tradeRisk();
      if(riskTrail > 0.0)trailingStop();
     }
  }
//+------------------------------------------------------------------+
//|Ежедневное обновление баланса                                     |
//+------------------------------------------------------------------+
void checkBalance()
  {
   TimeCurrent(dt);

   if(GlobalVariableCheck(prefix+"Balance") && GlobalVariableCheck(prefix+"Day") && GlobalVariableCheck(prefix+"Year")) //если ли переменные?
     {
      if(dt.day_of_year>GlobalVariableGet(prefix+"Day")) //Если следующий день, то обновить данные баланса и даты
        {
         GlobalVariableSet(prefix+"Day",dt.day_of_year);
         GlobalVariableSet(prefix+"Year",dt.year);
         GlobalVariableSet(prefix+"Balance",AccountInfoDouble(ACCOUNT_BALANCE));
           }else{
         if(dt.year>GlobalVariableGet(prefix+"Year")) //Проверка на наступление нового года
           {
            GlobalVariableSet(prefix+"Day",dt.day_of_year);
            GlobalVariableSet(prefix+"Year",dt.year);
            GlobalVariableSet(prefix+"Balance",AccountInfoDouble(ACCOUNT_BALANCE));
           }
        }
        }else{                                                                             //Нет. Создать.
      GlobalVariableSet(prefix+"Balance",AccountInfoDouble(ACCOUNT_BALANCE));
      GlobalVariableSet(prefix+"Day",dt.day_of_year);
      GlobalVariableSet(prefix+"Year",dt.year);
     }
  }
//+------------------------------------------------------------------+
//|Расчет дневного риска                                             |
//+------------------------------------------------------------------+
bool dayRisk()
  {
   balance=GlobalVariableGet(prefix+"Balance");      //считывание баланса
   double currentRiskPercent=(balance -(AccountInfoDouble(ACCOUNT_BALANCE)+AccountInfoDouble(ACCOUNT_PROFIT)))/(balance/100);

   if(currentRiskPercent>0) //убыток
     {
      if(currentRiskPercent>=risk) //если больше макс. риска на день
        {
         closedAll();                  //закрыть все сделки
         Comment("\nДопустимый дневной риск: ",DoubleToString(risk,2),"%\n",
                 isOnTradeRisk(),
                 isOnTrail(),
                 "Баланс на начало дня: ",DoubleToString(balance,2)," ",AccountInfoString(ACCOUNT_CURRENCY),"\n",
                 "Общий результат: -",DoubleToString(currentRiskPercent,2),"%\n",
                 "Торговля запрещена! Превышен максимальный дневной риск!");
         return(false);                  //запрет торговли
           }else{                        //если минус в рамках дневного риска
         Comment("\nДопустимый дневной риск: ",DoubleToString(risk,2),"%\n",
                 isOnTradeRisk(),
                 isOnTrail(),
                 "Баланс на начало дня: ",DoubleToString(balance,2)," ",AccountInfoString(ACCOUNT_CURRENCY),"\n",
                 "Общий результат: -",DoubleToString(currentRiskPercent,2));
         return(true);
        }
        }else{                              //профит
      currentRiskPercent=MathAbs(currentRiskPercent);
      Comment("\nДопустимый дневной риск: ",DoubleToString(risk,2),"%\n",
              isOnTradeRisk(),
              isOnTrail(),
              "Баланс на начало дня: ",DoubleToString(balance,2)," ",AccountInfoString(ACCOUNT_CURRENCY),"\n",
              "Общий результат: +",DoubleToString(currentRiskPercent,2));
      return(true);
     }
  }
//+------------------------------------------------------------------+
//|Расчет риска на трейд                                             |
//+------------------------------------------------------------------+
void tradeRisk()
  {
   double tradeRiskPercent;
   string symbl;
   balance=GlobalVariableGet(prefix+"Balance");            //считывание баланса

   if(PositionsTotal()>0) //Есть ли открытые позиции?
     {
      for(int loop=0; PositionsTotal()>=loop; loop++)
        {
         symbl= PositionGetSymbol(loop);                    //Получение символа позиции
         if(symbl != "")                                    //Если успешно
           {
            if(PositionGetDouble(POSITION_PROFIT)<0)
              {      //Проверка на убыток
               tradeRiskPercent=MathAbs(PositionGetDouble(POSITION_PROFIT)/(balance/100));      //Расчет %
               if(tradeRiskPercent>=riskTrade) //Если % убытка больше или равен максимальному на сделку
                 {
                  if(tr.PositionClose(symbl))Print("Позиция по ",symbl," ЗАКРЫТА. Превышен раск на трейд!");      //Закрываем позицию
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|Функция закрытия всех сделок и ордеров                            |
//+------------------------------------------------------------------+
bool closedAll()
  {
   string symbl;
   ulong ticket;

   if(PositionsTotal()>0)
     {
      for(int loop=0; PositionsTotal()>=loop; loop++)
        {
         symbl=PositionGetSymbol(loop);
         if(symbl!="")
           {
            if(tr.PositionClose(symbl))Print("Позиция по ",symbl," ЗАКРЫТА.");
           }
        }
     }

   if(OrdersTotal()>0)
     {
      for(int loop=0; OrdersTotal()>=loop; loop++)
        {
         ticket=OrderGetTicket(loop);
         if(ticket!=0)
           {
            if(tr.OrderDelete(ticket))Print("Отложенный ордер #",ticket," УДАЛЕН.");
           }
        }
     }

   if(PositionsTotal()==0 && OrdersTotal()==0)
     {
      return(true);
        }else{
      return(false);
     }
  }
//+------------------------------------------------------------------+
//|Отображение режима работы tradeRisk()                             |
//+------------------------------------------------------------------+
string isOnTradeRisk()
  {
   if(riskTrade>0.0)
     {
      return("Допустимый риск на сделку: " + DoubleToString(riskTrade, 2) + "%\n");
     }
   return("");
  }
//+------------------------------------------------------------------+
//|Отображение режима работы трейлинг-стопа                          |
//+------------------------------------------------------------------+
string isOnTrail()
  {
   if(riskTrail>0.0)
     {
      return("Трейлинг-стоп дневной прибыли: " + DoubleToString(riskTrail, 2) + "%\n");
     }
   return("");
  }
//+------------------------------------------------------------------+
//|Трейлинг-стоп дневной прибыли                                     |
//+------------------------------------------------------------------+
void trailingStop()
  {
   bool flag=false;
   double currentRiskPercent=((AccountInfoDouble(ACCOUNT_BALANCE)+AccountInfoDouble(ACCOUNT_PROFIT))-balance)/(balance/100);

   if(currentRiskPercent>=riskTrail && currentRiskPercent>=maxDayProfit)
     {
      maxDayProfit=currentRiskPercent;
      flag=true;
     }
   if(currentRiskPercent<=maxDayProfit-riskTrail && flag)
     {
      if(closedAll())
        {
         Alert("Сработал трейлинг-стоп по дневной прибыли!");
         flag=false;
         maxDayProfit=0;
        }
     }
  }
//+------------------------------------------------------------------+
//|END                                                               |
//+------------------------------------------------------------------+
