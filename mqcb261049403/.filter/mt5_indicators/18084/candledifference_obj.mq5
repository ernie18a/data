//+------------------------------------------------------------------+
//|                                         CandleDifference_Obj.mq5 |
//|                                       Copyright 2016, Il Anokhin |
//|                          https://www.mql5.com/en/users/ilanokhin |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Il Anokhin"
#property link "https://www.mql5.com/en/users/ilanokhin"
#property description ""
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
//|  Объявление констант                           |
//+------------------------------------------------+
#define INDICATOR_NAME      "CandleDifference"  // Имя индикатора
#define RESET               0                   // Константа для возврата терминалу команды на пересчет индикатора
#define SIZE                8                   // Количество валютных пар
#define NAMES_SYMBOLS_FONT  "Georgia"           // Шрифт для названия индикатора
//+------------------------------------------------+ 
//|  Входные параметры индикатора                  |
//+------------------------------------------------+ 
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;             // Таймфрейм индикатора для расчета индикатора
input string P1 = "EURUSD";                  //Pair 1
input string P2 = "GBPUSD";                  //Pair 2
input string P3 = "AUDUSD";                  //Pair 3
input string P4 = "GBPJPY";                  //Pair 4
input string P5 = "USDCHF";                  //Pair 5
input string P6 = "USDCAD";                  //Pair 6
input string P7 = "USDJPY";                  //Pair 7
input string P8 = "EURJPY";                  //Pair 8
//---- настройки визуального отображения индикатора
input uint SignalBar=0;                                 // Номер бара для получения сигнала (0 - текущий бар)
input string Symbols_Sirname="CandleDifference_Label_"; // Название для меток индикатора
input color Ind_Color=clrDarkOrchid;                    // Цвет индикатора
input uint Font_Size=15;                                // Размер шрифта названия индикатора
input uint X_=30;                                       // Смещение по горизонтали
input uint Y_=30;                                       // Смещение по вертикали
input bool ShowIndName=true;                            // Отображение названия индикатора
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER;  // Угол расположения
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление переменных
uint Y_N[SIZE];
double d[SIZE];
string pair[SIZE],lname[SIZE],data[SIZE];
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
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
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=1+int(SignalBar);

//---- инициализация переменных
   pair[0]=P1;
   pair[1]=P2;
   pair[2]=P3;
   pair[3]=P4;
   pair[4]=P5;
   pair[5]=P6;
   pair[6]=P7;
   pair[7]=P8;

   for(int numb=0; numb<SIZE; numb++) lname[numb]=Symbols_Sirname+pair[numb];
   Y_N[0]=Y_;
   for(int numb=1; numb<SIZE; numb++) Y_N[numb]=Y_N[numb-1]+int(1.7*Font_Size);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,Symbols_Sirname,-1,-1);
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
//---- 
   double iOpen[1],iClose[1];
//--- копируем вновь появившиеся данные в массивы
   for(int numb=0; numb<SIZE; numb++)
     {
      if(CopyOpen(pair[numb],Timeframe,int(SignalBar),1,iOpen)<=0) return(prev_calculated);
      if(CopyClose(pair[numb],Timeframe,int(SignalBar),1,iClose)<=0) return(prev_calculated);
      d[numb]=(100*iClose[0]/iOpen[0])-100;
     }
//----     
   for(int numb=0; numb<SIZE; numb++)
     {
      data[numb]="";
      if(pair[numb]!="") data[numb]=pair[numb]+": "+DoubleToString(d[numb],2)+"%";
     }
//----    
   for(int numb=0; numb<SIZE; numb++)
      SetTLabel(0,lname[numb],0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_N[numb],data[numb],data[numb],Ind_Color,NAMES_SYMBOLS_FONT,Font_Size);
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
