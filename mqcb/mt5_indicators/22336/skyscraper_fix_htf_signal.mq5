//+------------------------------------------------------------------+ 
//|                                    Skyscraper_Fix_HTF_Signal.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//+------------------------------------------------+ 
//|  Параметры отрисовки индикатора                |
//+------------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------+ 
//|  объявление констант                           |
//+------------------------------------------------+
#define INDICATOR_NAME      "Skyscraper_Fix"    // Имя индикатора
#define RESET               0                   // Константа для возврата терминалу команды на пересчет индикатора
#define NAMES_SYMBOLS_FONT  "Georgia"           // Шрифт для названия индикатора
#define SIGNAL_SYMBOLS_FONT "Wingdings 3"       // Шрифт для символа входа в позицию
#define TREND_SYMBOLS_FONT  "Wingdings 3"       // Шрифт для символа тренда
#define UP_SIGNAL_SYMBOL    "ж"                 // Символ для открывания long
#define DN_SIGNAL_SYMBOL    "и"                 // Символ для открывания short
#define UP_TREND_SYMBOL     "в"                 // Символ для растущего тренда
#define DN_TREND_SYMBOL     "в"                 // Символ для падающего тренда
#define BUY_SOUND           "alert.wav"         // Звуковой файл для входа в long
#define SELL_SOUND          "alert.wav"         // Звуковой файл для входа в short
#define BUY_ALERT_TEXT      "Сигнал на покупку" // Текст алерта для входа в long
#define SELL_ALERT_TEXT     "Сигнал на продажу" // Текст алерта для входа в short
//+------------------------------------------------+ 
//| Перечисление для индикации срабатывания уровня |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE // Тип константы
  {
   OnlySound,   // только звук
   OnlyAlert    // только алерт
  };
//+------------------------------------------------+ 
//| Объявление перечислений                        |
//+------------------------------------------------+ 
enum Method
  {
   MODE_HighLow,  //High/Low
   MODE_Close     //Close
  };
//+------------------------------------------------+ 
//|  Входные параметры индикатора                  |
//+------------------------------------------------+ 
input string Symbol_="";                               // Финансовый актив
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;             // Таймфрейм индикатора для расчета индикатора
input uint    Length=10;                               // Период ATR
input double  Kv=0.9;                                  // Фактор чувствительности индикатора
input double  Percentage=0;                            // Приближение средней линии к линиям экстремумов
input Method  HighLow=MODE_HighLow;                    // Расчёт индикатора по High/Low или Close
//---- настройки визуального отображения индикатора
input uint SignalBar=0;                                // Номер бара для получения сигнала (0 - текущий бар)
input string Symbols_Sirname=INDICATOR_NAME"_Label_";  // Название для меток индикатора
input color UpSymol_Color=clrLimeGreen;                // Цвет символа роста
input color DnSymol_Color=clrDeepPink;                 // Цвет символа падения
input color IndName_Color=clrDarkOrchid;               // Цвет названия индикатора
input uint Symbols_Size=60;                            // Размер символов сигнала
input uint Font_Size=10;                               // Размер шрифта названия индикатора
input int X_1=5;                                       // Смещение названия по горизонтали
input int Y_1=-15;                                     // Смещение названия по вертикали
input bool ShowIndName=true;                           // Отображение названия индикатора
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Угол расположения
input uint X_=0;                                       // Смещение по горизонтали
input uint Y_=20;                                      // Смещение по вертикали
//---- настройки алертов
input ENUM_ALERT_MODE alert_mode=OnlySound;            // Вариант индикации срабатывания
input uint AlertCount=0;                               // Количество подаваемых алертов
input bool Push=true;                                  // Разрешение на передачу push-сообщений
//+-----------------------------------+
//---- объявление целочисленных переменных для хендлов индикаторов
int Skyscraper_Fix_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных расположения индексов по горизонтали и вертикали
uint X_0,Yn,X_1_,Y_1_;
//---- объявление переменных для имен меток
string name0,name1,IndName,Symb;
//---- объявление переменных для текста алертов
string BuySignal,SellSignal;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+
//|  Создание текстовой метки                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // идентификатор графика
                  string name,             // имя объекта
                  int    nwin,             // индекс окна
                  ENUM_BASE_CORNER corner, // положение угла привязки
                  ENUM_ANCHOR_POINT point, // положение точки привязки
                  int    X,                // дистанция в пикселях по оси X от угла привязки
                  int    Y,                // дистанция в пикселях по оси Y от угла привязки
                  string text,             // текст
                  string textTT,           // текст всплывающей подсказки
                  color  Color,            // цвет текста
                  string Font,             // шрифт текста
                  int    Size)             // размер шрифта
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка текстовой метки                                   |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // идентификатор графика
               string name,             // имя объекта
               int    nwin,             // индекс окна
               ENUM_BASE_CORNER corner, // положение угла привязки
               ENUM_ANCHOR_POINT point, // положение точки привязки
               int    X,                // дистанция в пикселях по оси X от угла привязки
               int    Y,                // дистанция в пикселях по оси Y от угла привязки
               string text,             // текст
               string textTT,           // текст всплывающей подсказки
               color  Color,            // цвет текста
               string Font,             // шрифт текста
               int    Size)             // размер шрифта
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,textTT,Color,Font,Size);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных   
   int ATR_Period=15;
   min_rates_total=ATR_Period+int(Length+1);
   min_rates_total+=int(SignalBar);

//---- инициализация переменных
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();

   X_0=X_;
   Yn=Y_+5;

   name0=Symbols_Sirname+"0";
   if(ShowIndName)
     {
      Y_1_=Yn+Y_1;
      X_1_=X_0+X_1;
      name1=Symbols_Sirname+"1";
      StringConcatenate(IndName,INDICATOR_NAME,"(",Symb," ",GetStringTimeframe(Timeframe),")");
     }

//---- получение хендла индикатора Skyscraper_Fix
   Skyscraper_Fix_Handle=iCustom(Symb,Timeframe,"Skyscraper_Fix",Length,Kv,Percentage,HighLow);
   if(Skyscraper_Fix_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Skyscraper_Fix");
      return(INIT_FAILED);
     }
     
   BuySignal=IndName+": "+BUY_ALERT_TEXT;
   SellSignal=IndName+": "+SELL_ALERT_TEXT;

//---- инициализации переменной для короткого имени индикатора
   string shortname=name1;
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   if(ObjectFind(0,name0)!=-1) ObjectDelete(0,name0);
   if(ObjectFind(0,name1)!=-1) ObjectDelete(0,name1);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(Skyscraper_Fix_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(Skyscraper_Fix_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);

//---- объявление локальных переменных
   int trend=0;
   double Sign[2];
   color Color0=clrNONE;
   string SignSymbol;
   bool signal=false;
   static uint buycount,sellcount;
   static bool RePush;

//---- расчеты необходимого количества копируемых данных для функции CopyBuffer
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      buycount=0;
      sellcount=0;
     }
   else
     {
      if(prev_calculated==rates_total && SignalBar && (!buycount || !sellcount)) return(rates_total);
     }

//---- копируем вновь появившиеся данные в массив  
   if(CopyBuffer(Skyscraper_Fix_Handle,5,SignalBar,2,Sign)<=0) return(prev_calculated);

   if(Sign[1]==0)
     {
      trend=+1;
      if(Sign[0]==1) signal=true;
     }

   if(Sign[1]==1)
     {
      trend=-1;
      if(Sign[0]==0) signal=true;
     }

//---- ставим счетчики алертов в исходное положение   
   if(prev_calculated!=rates_total && AlertCount && signal)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
     }

//---- получим сигналы для покупки
   if(trend>0)
     {
      Color0=UpSymol_Color;

      if(signal)
        {
         SignSymbol=UP_SIGNAL_SYMBOL;
         if(Push && SignalBar && prev_calculated!=rates_total) RePush=true;        
         if(RePush) if(SendNotification(BuySignal)) RePush=false;

         if(buycount && SignalBar)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(BuySignal); break;
               case OnlySound: PlaySound(BUY_SOUND); break;
              }

            buycount--;
           }
        }
      else SignSymbol=UP_TREND_SYMBOL;
     }

//---- получим сигналы для продажи
   if(trend<0)
     {
      Color0=DnSymol_Color;

      if(signal)
        {
         SignSymbol=DN_SIGNAL_SYMBOL;
         if(Push && SignalBar && prev_calculated!=rates_total) RePush=true;        
         if(RePush) if(SendNotification(SellSignal)) RePush=false;

         if(sellcount && SignalBar)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(SellSignal); break;
               case OnlySound: PlaySound(SELL_SOUND); break;
              }

            sellcount--;
           }

        }
      else SignSymbol=DN_TREND_SYMBOL;
     }
     
//---- отобразим сигналы на графике
   if(trend)
     {
      if(ShowIndName)
         SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1_,Y_1_,IndName,IndName,IndName_Color,NAMES_SYMBOLS_FONT,Font_Size);
      if(signal) SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,SIGNAL_SYMBOLS_FONT,Symbols_Size);
      else SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,TREND_SYMBOLS_FONT,Symbols_Size);
     }
   else Deinit();
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
