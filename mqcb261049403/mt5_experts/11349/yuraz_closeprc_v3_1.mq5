//+------------------------------------------------------------------+
//|                                          YURAZ_CLOSEPRC_V3_1.mq5 |
//|                                            Copyright 2017, YuraZ |
//|                              https://www.mql5.com/ru/users/yuraz |
//| 28.02.2017  поправил проблемы с изменения новых версий           |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, YuraZ"
#property link      "https://www.mql5.com/ru/users/yuraz"
#property version   "3.01"

input string gpsPrcClose="10"; // 10% профита по умолчанию
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CYurazTrade
  {
public:
   int               AllCloseMonitor;
   double            PrcClose;

   void CYurazTrade()
     {
      AllCloseMonitor=0; //  тут для монитора событий информация
      LastCloseCode=0;
      LastCodePS=0;

      PrcClose=100000000000;

     } // конструктор
   void              CloseAll();
private:
   int               LastCloseCode;
   int               LastCodePS;

   string            sCodeError(int code);
   void              ClosePosition(string sSymbol,int ip);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CYurazTrade::sCodeError(int retcode)
  {
   string sRetCode;
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE: sRetCode=(string)retcode+" Реквота"; break;// 10004
      case TRADE_RETCODE_REJECT: sRetCode=(string)retcode+" Запрос отвергнут";  break;
      case TRADE_RETCODE_CANCEL: sRetCode = (string)retcode+" Запрос отменен трейдером"; break;
      case TRADE_RETCODE_PLACED: sRetCode = (string)retcode+" Ордер размещен"; break;
      case TRADE_RETCODE_DONE: sRetCode=(string)retcode+" Заявка выполнена"; break;
      case TRADE_RETCODE_DONE_PARTIAL: sRetCode=(string)retcode+" Заявка выполнена частично"; break;
      case TRADE_RETCODE_ERROR: sRetCode=(string)retcode+" Ошибка обработки запроса"; break;
      case TRADE_RETCODE_TIMEOUT: sRetCode = (string)retcode+" Запрос отменен по истечению времени"; break;
      case TRADE_RETCODE_INVALID: sRetCode = (string)retcode+" Неправильный запрос"; break;
      case TRADE_RETCODE_INVALID_VOLUME: sRetCode=(string)retcode+" Неправильный объем в запросе"; break;
      case TRADE_RETCODE_INVALID_PRICE: sRetCode = (string)retcode+" Неправильная цена в запросе"; break;
      case TRADE_RETCODE_INVALID_STOPS: sRetCode = (string)retcode+" Неправильные стопы в запросе"; break;
      case TRADE_RETCODE_TRADE_DISABLED: sRetCode=(string)retcode+" Торговля запрещена"; break;
      case TRADE_RETCODE_MARKET_CLOSED: sRetCode =(string)retcode+" Рынок закрыт"; break;
      case TRADE_RETCODE_NO_MONEY: sRetCode=(string)retcode+" Нет достаточных денежных средств для выполнения запроса"; break;
      case TRADE_RETCODE_PRICE_CHANGED: sRetCode=(string)retcode+" Цены изменились"; break;
      case TRADE_RETCODE_PRICE_OFF: sRetCode=(string)retcode+" Отсутствуют котировки для обработки запроса"; break;
      case TRADE_RETCODE_INVALID_EXPIRATION: sRetCode=(string)retcode+" Неверная дата истечения ордера в запросе"; break;
      case TRADE_RETCODE_ORDER_CHANGED: sRetCode=(string)retcode+" Состояние ордера изменилось"; break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS: sRetCode=(string)retcode+" Слишком частые запросы"; break;
      default:   sRetCode=(string)retcode+" неизвестная ошибка"; break;
     }
   return(sRetCode);
  }
//
// закрыть все что открыто
//
void CYurazTrade::CloseAll()
  {
   int pos=PositionsTotal(); // получим количество открытых позиций
   for(int ip=0;ip<pos;ip++)
     {
      string sSymbol=PositionGetSymbol(ip);
      if(PositionSelect(sSymbol)==true)
         ClosePosition(sSymbol,ip);
      else
         LastCodePS=GetLastError(); // получим возможный код ошибки , по описанию пока не знаю коды
     }
   if(PositionsTotal()==0)
     {
      AllCloseMonitor=0;    // Скажем монитору что бы больше не вызывалсобытие
     }

   printf(" %s ",sCodeError(LastCloseCode)); // напечатаем в лог

   if(LastCloseCode==TRADE_RETCODE_MARKET_CLOSED) // рынок закрыт
     {
      AllCloseMonitor=0;    // Скажем монитору что бы больше не вызывал событие
      LastCloseCode=0;
     }

   if(LastCloseCode==TRADE_RETCODE_TRADE_DISABLED) // торговля запрещена
     {
      AllCloseMonitor=0;    // Скажем монитору что бы больше не вызывал событие
      LastCloseCode=0;
     }
   if(AllCloseMonitor==0)
     {
      if(ObjectGetInteger(0,buttonID,OBJPROP_STATE)==true)
        {

         //--- отправим пользовательское событие "своему"графику
         EventChartCustom(0,CHARTEVENT_CUSTOM+999-CHARTEVENT_CUSTOM,0,0,"");
         //--- отправим сообщение всем открытым графикам
         BroadcastEvent(ChartID(),0,"Broadcast Message");
         ObjectSetInteger(0,buttonID,OBJPROP_STATE,false);
         ChartRedraw();// принудительно перерисуем все объекты на графике
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CYurazTrade::ClosePosition(string sSymbol,int ip)
  {
   MqlTradeRequest request={0}; // структура запроса
   MqlTradeResult result={0}; // структура ответа
   request.symbol = sSymbol;
   request.volume = PositionGetDouble( POSITION_VOLUME );
   request.action=TRADE_ACTION_DEAL; //(ENUM_TRADE_REQUEST_ACTIONS)0; //TRADE_ACTION_MARKET ; // операция с рынка
   request.tp=0;
   request.sl=0;
   request.deviation=(ulong)((SymbolInfoDouble(sSymbol,SYMBOL_ASK)-SymbolInfoDouble(sSymbol,SYMBOL_BID))/SymbolInfoDouble(sSymbol,SYMBOL_POINT)); // по спреду
   request.type_filling=ORDER_FILLING_IOC;
   if(request.volume>9) // пока не смог решить проблему с request
      request.volume=9;

   if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
     {
      request.type=ORDER_TYPE_SELL;
      request.price=SymbolInfoDouble(sSymbol,SYMBOL_BID);
     }
   if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
     {
      request.type=ORDER_TYPE_BUY;
      request.price=SymbolInfoDouble(sSymbol,SYMBOL_ASK);
     }
   bool ret=OrderSend(request,result);
   LastCloseCode = (int)result.retcode;
  }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Монитор событий ( вызвается из таймера )
//
class CYurazMonitor
  {
public:
   void              Monitor();

  };
//
//
//
void CYurazMonitor::Monitor(void)
  {
   yzTrade.PrcClose=StringToDouble(ObjectGetString(0,editID,OBJPROP_TEXT));
   ObjectSetString(0,labelID1,OBJPROP_TEXT,
                   DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT),2)
                   +" "
                   +DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE)/100,2)
                   +" "
                   +DoubleToString(yzTrade.PrcClose,4)

                   );
   if(yzTrade.AllCloseMonitor!=0) // монитор событий обнаружил, необходимо  закрыть все позиции
     {
      yzTrade.CloseAll();

     }
   if(AccountInfoDouble(ACCOUNT_PROFIT)>AccountInfoDouble(ACCOUNT_BALANCE)/100 *yzTrade.PrcClose)
     {
      yzTrade.AllCloseMonitor=2; // событие закрыть по профиту
      yzTrade.CloseAll();
     }
  }
//  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//
CYurazTrade   yzTrade;    // клас обработки торговых операций
CYurazMonitor yzMonitor;  // монитор событий
                          //
string buttonID="Button";
string editID="Edit";
string labelID1="Info1";

ushort  broadcastEventID = 5000;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   yzTrade.AllCloseMonitor=0;

//--- создадим кнопку, для передачи пользовательских событий
   ObjectCreate(0,buttonID,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,buttonID,OBJPROP_COLOR,White);
   ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,Gray);
   ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,60);
   ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,250);
   ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,50);
   ObjectSetString(0,buttonID,OBJPROP_FONT,"Arial");
   ObjectSetString(0,buttonID,OBJPROP_TEXT,"Закрыть все позиции одним кликом");
   ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,false); // иначе нажать на нее нельзя

//--- создадим метку для вывода информации
//ObjectCreate(0,labelID,OBJ_LABEL,0,100,100);
//ObjectSetInteger(0,labelID,OBJPROP_COLOR,Red);
//ObjectSetInteger(0,labelID,OBJPROP_XDISTANCE,10);
//ObjectSetInteger(0,labelID,OBJPROP_YDISTANCE,100);
//ObjectSetString(0,labelID,OBJPROP_FONT,"Trebuchet MS");
//ObjectSetString(0,labelID,OBJPROP_TEXT,"Нет информации");
//ObjectSetInteger(0,labelID,OBJPROP_FONTSIZE,20);
//ObjectSetInteger(0,labelID,OBJPROP_SELECTABLE,0);


   ObjectCreate(0,labelID1,OBJ_LABEL,0,100,100);
   ObjectSetInteger(0,labelID1,OBJPROP_COLOR,Red);
   ObjectSetInteger(0,labelID1,OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,labelID1,OBJPROP_YDISTANCE,20);
   ObjectSetString(0,labelID1,OBJPROP_FONT,"Trebuchet MS");
   ObjectSetString(0,labelID1,OBJPROP_TEXT,"Позиции закроются при достижении процента от депозита");
   ObjectSetInteger(0,labelID1,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,labelID1,OBJPROP_SELECTABLE,true);

   ObjectCreate(0,editID,OBJ_EDIT,0,100,100);
   ObjectSetInteger(0,editID,OBJPROP_XDISTANCE,370);
   ObjectSetInteger(0,editID,OBJPROP_YDISTANCE,20);
   ObjectSetInteger(0,editID,OBJPROP_COLOR,Red);

   ObjectSetInteger(0,editID,OBJPROP_XSIZE,50);
   ObjectSetInteger(0,editID,OBJPROP_YSIZE,50);
   ObjectSetString(0,editID,OBJPROP_TEXT,gpsPrcClose); // 3%
   ObjectSetInteger(0,editID,OBJPROP_FONTSIZE,20);
   ObjectSetInteger(0,editID,OBJPROP_SELECTABLE,false); // иначе нажать на нее нельзя

   yzTrade.PrcClose=StringToDouble(gpsPrcClose); // положим в торговый класс % прибыли при котором закроются все позиции

                                                 //   int customEventID; // номер пользовательского события для отправки

   EventSetTimer(1); // каждую секунду вызываем OnTimer

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---

  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| послать широковещательное сообщение всем открытм графикам        |
//+------------------------------------------------------------------+
void BroadcastEvent(long lparam,double dparam,string sparam)
  {
   int limit=100;// у нас наверняка не больше 100 открытых графиков
   ushort eventID = broadcastEventID - (ushort)CHARTEVENT_CUSTOM;
   long currChart,prevChart=ChartFirst();
   int i=0;
   while(i<limit)
     {
      currChart=ChartNext(prevChart); // на основании предыдущего получим новый график
      if(currChart==0) break;         // достигли конца списка графиков
      EventChartCustom(currChart,eventID,lparam,dparam,sparam);
      prevChart=currChart;// запомним идентификатор текущего графика для ChartNext()
      i++;// не забудем увеличить счетчик
     }
  }
//+------------------------------------------------------------------+
