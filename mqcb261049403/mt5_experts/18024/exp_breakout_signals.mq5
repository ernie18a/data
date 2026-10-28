//+------------------------------------------------------------------+
//|                                         exp_breakout_signals.mq5 |
//|                                                         Tapochun |
//|                           https://www.mql5.com/ru/users/tapochun |
//+------------------------------------------------------------------+
#property copyright "Tapochun"
#property link      "https://www.mql5.com/ru/users/tapochun"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Версии																				|
//+------------------------------------------------------------------+
//--- 1.00: Рабочая версия;
//+------------------------------------------------------------------+
//| Глобальные переменные															|
//+------------------------------------------------------------------+
enum ENUM_ADD_MODE      // Перечисление - режимы добавления объектов 
  {
   ADD_MODE_ALL,         // Добавлять все линии
   ADD_MODE_MESSAGE      // Добавлять линии по запросу
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_MODE   // Перечисление - режим подачи сигнала
  {
   SIGNAL_MODE_SOUND,   // Звуковой сигнал
   SIGNAL_MODE_ALERT,   // Алерт на экран
   SIGNAL_MODE_PUSH,// Пуш-уведомление на телефон
   SIGNAL_MODE_MAIL      // Сообщение на почту
  };
//+------------------------------------------------------------------+
//| Входные параметры																|
//+------------------------------------------------------------------+
sinput   string             inpPrefix="bot_";               	// Префикс рабочих линий
sinput   ENUM_ADD_MODE      inpAddMode=ADD_MODE_MESSAGE;      	// Режим добавления линий
sinput   ENUM_SIGNAL_MODE    inpSignalMode=SIGNAL_MODE_SOUND;  // Режим подачи сигналов
sinput   string            inpSoundName="Alert2.wav";         	// Имя звукового файла (для режима звукового файла)
sinput   bool               inpDelObjects=false;               // Удалять рабочие линии при удалении эксперта?
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Проверяем входные параметры
   if(!CheckInputParameters())      	// Если проверка не пройдена
      return(INIT_FAILED);            	// Выходим с ошибкой
//--- Подписываемся на событие создание граф. объектов
   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,true);
//---
   return( INIT_SUCCEEDED );
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) // Код причины деинициализации
  {
//--- Проверим необходимость удаления рабочих линий
   if(reason==REASON_REMOVE && inpDelObjects) // Если эксперт удален с графика и нужно удалить рабочие линии
     {
      ObjectsDeleteAll( 0, inpPrefix, 0, OBJ_HLINE );   // Удаляем рабочие горизонтальные линии
      ChartRedraw();                                    // Перерисовываем график
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Сохраненное время открытия бара
   static datetime savedTime=0;
//--- Проверяем образование нового бара
   if(!IsNewBar(savedTime))         // Если новый бар не образован
      return;                           // Выходим
//--- Проверяем образование сигналов
   CheckSignals();
  }
//+------------------------------------------------------------------+
//| Проверяем образование сигналов												|
//+------------------------------------------------------------------+
void CheckSignals()
  {
//--- Общее количество линий в главном окне
   const int total=ObjectsTotal(0,0,OBJ_HLINE);
   if(total<=0) // Если линии отсутствуют
      return;                              // Выходим
//--- Получаем цены открытия и закрытия сформированной свечи
   MqlRates rates[2];                  // Массив - приемник
//--- Получение..
   if(CopyRates(_Symbol,_Period,0,2,rates)!=2) // Если данные не получены
     {
      Print(__FUNCTION__,": ОШИБКА #",GetLastError(),": данные двух последних свечей не получены!");
      return;                                                // Выходим с ошибкой
     }
//--- Имя линии
   string name;
//--- Тексе сообщения
   string text;
//--- Цена линии
   double price;
//--- Цикл по линиям
   for(int i=0; i<total; i++)
     {
      //--- Имя линии
      name=ObjectName(0,i,0,OBJ_HLINE);
      //--- Проверяем, относится ли линия к рабочим
      if(StringFind(name,inpPrefix)<0) // Если подстрока не найдена
         continue;                              // Переходим к след. объекту
      //--- Определяем цену линии
      price=ObjectGetDouble(0,name,OBJPROP_PRICE,0);
      //--- Проверяем, была ли пересечена линия предыдущей свечей
      if(( rates[0].high>price && rates[0].low<price) || // Если было пересечение на сформированной свече или..
         (rates[ 1 ].open > price && rates[ 0 ].open < price ) ||      // ..если было пересечение гэпом вверх или..
         ( rates[ 1 ].open < price && rates[ 0 ].open > price ) )      // ..если было пересечение гэпом вниз
        {
         //--- Формируем текст сообщения
         text=_Symbol+": пересечение линии '"+name+"'";
         //--- Линия была пересечена! Сигнал!
         switch(inpSignalMode) // В зависимости от типа сигнала
           {
            case SIGNAL_MODE_SOUND:                  // Звуковой сигнал
               if(!PlaySound(inpSoundName))
               Print(__FUNCTION__,": ОШИБКА #",GetLastError(),": звуковой файл '"+inpSoundName+"' не воспроизведен!");
               break;
            case SIGNAL_MODE_ALERT:                  // Алерт
               Alert(text);
               break;
            case SIGNAL_MODE_PUSH:                     // Пуш-сообщение
               if(!SendNotification(text))
               Print(__FUNCTION__,": ОШИБКА #",GetLastError(),": пуш-сообщение не отправлено!");
               break;
            case SIGNAL_MODE_MAIL:                     // Сообщение на почту
               if(!SendMail("MT5: "+text,text))
               Print(__FUNCTION__,": ОШИБКА #",GetLastError(),": сообщение на почту не отправлено!");
               break;
            default:                                 // Неизвестный тип сигнала
               Print(__FUNCTION__,": ОШИБКА! Неизвестный тип сигнала '"+EnumToString(inpSignalMode)+"'");
               return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      //--- Проверяем тип граф. объекта
      if(ObjectGetInteger(0,sparam,OBJPROP_TYPE)!=OBJ_HLINE) // Если создана не гор. линия
         return;                                                         // Выходим
      //--- Новое имя граф. объекта
      const string name=inpPrefix+sparam;
      //--- Проверяем, каким образом нужно добавлять объект
      if( inpAddMode == ADD_MODE_ALL )                        // Если в работу добавляются все горизонтальные линии
         ObjectSetString( 0,sparam,OBJPROP_NAME,name );      // Добавляем к имени линии постфикс
      else if( inpAddMode == ADD_MODE_MESSAGE )               // Если в работу добавляются гор. линии по запросу
        {
         //--- Устанавливаем параметры текста и заголовка окна
         const string text="Добавить линию '"+sparam+"' к списку рабочих?";
         const string caption="Добавление линии";
         //--- Запуск бокса. Получаем ответ
         const int answer=MessageBox(text,caption,MB_YESNO|MB_ICONQUESTION);
         if( answer == IDYES )                                 // Если нажата кнопка "да"
            ObjectSetString( 0,sparam,OBJPROP_NAME, name );   // Добавляем к имени линии постфикс
        }
      //--- Перерисовываем график
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Проверка входных параметров													|
//+------------------------------------------------------------------+
bool CheckInputParameters()
  {
//--- Проверяем разрешения для некоторых режимов сигнала
   switch(inpSignalMode) // В зависимости от режима сигнала
     {
      case SIGNAL_MODE_SOUND:            // Если звуковое оповещение
         if(inpSoundName=="") // Если имя звукового файла не указано
           {
            Print(__FUNCTION__,": ОШИБКА! Необходимо указать имя звукового файла!");
            return(false);               // Выходим с ошибкой
           }
         else                            // Если имя указано
         return(true);               // Возвращаем истину
      case SIGNAL_MODE_ALERT:            // Если оповещение алертом
         return( true );                  // Возвращаем истину
      case SIGNAL_MODE_PUSH:               // Если оповещение пуш-уведомлением
         if(!TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))   // Если пуш-уведомления отключены
           {
            Print(__FUNCTION__,": ОШИБКА! Необходимо разрешить отправку пуш-сообщений на телефон!");
            return(false);               // Выходим с ошибкой
           }
         else                            // Если пуш-уведомления разрешены
         return(true );               // Возвращаем истину
      case SIGNAL_MODE_MAIL:               // Если оповещения на почту
         if(!TerminalInfoInteger(TERMINAL_EMAIL_ENABLED))            // Если оповещения на почту отключены
           {
            Print(__FUNCTION__,": ОШИБКА! Необходимо разрешить отправку сообщений на почту!");
            return(false);               // Выходим с ошибкой
           }
         else                            // Если оповещения на почту включены
         return(true);               // Возвращаем истину
      default:                            // Если неизвестный режим сигнала
         Print(__FUNCTION__,": ОШИБКА! Неизвестный режим сигнала '"+EnumToString(inpSignalMode)+"'");
         return(false);                  // Выходим с ошибкой
     }
//--- Если все проверки пройдены
   return(true);                        // Возвращаем истину
  }
//+------------------------------------------------------------------+
//| Проверка формирования нового бара											|
//+------------------------------------------------------------------+
bool IsNewBar(datetime &savedTime) // Сохраненное время открытия (out)
  {
//--- Получаем время открытия последнего бара по символу/периоду
   datetime currentTime=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
//---
   if(savedTime==0) // Если первый запуск
     {
      savedTime = currentTime;            // Запоминаем время формирования бара
      return(false );                     // Возвращаем ложь
     }
   else                                  // Если не первый запуск
     {
      if(savedTime!=currentTime) // Если сохраненное время не равно времени открытия текущей свечи
        {
         savedTime = currentTime;         // Сохраняем время открытия текущей свечи
         return( true );                  // Возвращаем истину
        }
      else                               // Если сохраненное время совпадает со временем текущей
      return(false);                  // Возвращаем ложь
     }
  }
//+------------------------------------------------------------------+
