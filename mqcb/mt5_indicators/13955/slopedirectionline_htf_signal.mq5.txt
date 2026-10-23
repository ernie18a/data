//+------------------------------------------------------------------+
//|                                SlopeDirectionLine_HTF_Signal.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru |
//+------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh                  |
//| следует положить в папку: каталог_данных_терминала\MQL5\Include  |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- номер версии индикатора
#property version   "1.60"
//+----------------------------------------------+ 
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+ 
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
#property indicator_buffers 1
#property indicator_plots   1
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+    
//| Описание классов усреднений       |
//+-----------------------------------+    
#include <SmoothAlgorithms.mqh>
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum APPLIED_PRICE // тип константы
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input string Symbol_="";                   // Финансовый актив
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6; // Таймфрейм индикатора для расчета индикатора
input Smooth_Method MA_Method1=MODE_LWMA;  // Метод первого усреднения
input uint Length1=12; // Глубина первого усреднения
input int Phase1=15;   // Параметр первого усреднения
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_SMA; // Метод усреднения второго сглаживания
input int Phase2=15;  // Параметр второго сглаживания
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- для VIDIA это период CMO, для AMA это период медленной скользящей
input APPLIED_PRICE IPC=PRICE_CLOSE;//ценовая константа
input bool On_Push = false;                           // Разрешение на передачу push-сообщений
input bool On_Email = false;                          // Разрешение на отправку почты
input bool On_Alert = true;                           // Разрешение на подачу алерта
input bool On_Play_Sound = false;                     // Разрешение на подачу звукового сигнала
input string NameFileSound = "expert.wav";            // Имя для файла звукового сигнала
input string  CommentSirName="SlopeDirectionLine: ";  // Первая часть алерт-коммента
input uint SignalBar=1;                               // Номер бара для сигнала
//--- настройки отображения индикатора
input string Symbols_Sirname="SlopeDirectionLine_Label_"; // Название для меток индикатора
input color UpSymbol_Color=clrBlue;        // Цвет символа роста
input color DnSymbol_Color=clrRed;         // Цвет символа падения
input color IndName_Color=clrDarkOrchid;   // Цвет названия индикатора
input uint Symbols_Size=34;                // Размер символов сигнала
input uint Font_Size=15;                   // Размер шрифта названия индикатора
input int X_3=120;                         // Смещение названия по горизонтали
input int Y_3=10;                          // Смещение названия по вертикали
input bool ShowIndName=true;               // Отображение названия индикатора
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Угол расположения
input uint X_=0;                           // Смещение по горизонтали
input uint Y_=0;                           // Смещение по вертикали
//+-----------------------------------+
//--- объявление целочисленных переменных для хендлов индикаторов
int SlopeDirectionLine_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных расположения индексов по горизонтали и вертикали
uint X_0,X_1,X_2,X_3_,Yn,Y_3_;
//--- объявление переменных для имен меток
string name0,name1,name2,name3,IndName,Symb;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+
//| Создание текстовой метки                                         |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // идентификатор графика
                  string name,             // имя объекта
                  int    nwin,             // индекс окна
                  ENUM_BASE_CORNER corner, // положение угла привязки
                  ENUM_ANCHOR_POINT point, // положение точки привязки
                  int    X,                // дистанция в пикселях по оси X от угла привязки
                  int    Y,                // дистанция в пикселях по оси Y от угла привязки
                  string text,             // текст
                  color  Color,            // цвет текста
                  string Font,             // шрифт текста
                  int    Size)             // размер шрифта
  {
//---
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
  }
//+------------------------------------------------------------------+
//| Переустановка текстовой метки                                    |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // идентификатор графика
               string name,             // имя объекта
               int    nwin,             // индекс окна
               ENUM_BASE_CORNER corner, // положение угла привязки
               ENUM_ANCHOR_POINT point, // положение точки привязки
               int    X,                // дистанция в пикселях по оси X от угла привязки
               int    Y,                // дистанция в пикселях по оси Y от угла привязки
               string text,             // текст
               color  Color,            // цвет текста
               string Font,             // шрифт текста
               int    Size)             // размер шрифта
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
  }
//+------------------------------------------------------------------+    
//| SlopeDirectionLine indicator initialization function             | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
   CXMA XMA;
//--- инициализация переменных начала отсчета данных
   int LengthR=int(MathMax(MathSqrt(Length1),1));
   min_rates_total=GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_total+=int(GetStartBars(MA_Method2,LengthR,Phase2)+4+SignalBar);
//--- инициализация переменных
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();
//---
   X_0=X_;
   X_1=uint(X_0+Symbols_Size*1.1);
   X_2=uint(X_1+Symbols_Size*1.1);
   Yn=Y_+5;
//---
   name0=Symbols_Sirname+"0";
   name1=Symbols_Sirname+"1";
   name2=Symbols_Sirname+"2";
   if(ShowIndName)
     {
      Y_3_=Yn+Y_3;
      X_3_=X_0+X_3;
      name3=Symbols_Sirname+"3";
      StringConcatenate(IndName,"SlopeDirectionLine(",Symb," ",GetStringTimeframe(Timeframe),")");
     }
//--- получение хендла индикатора SlopeDirectionLine
   SlopeDirectionLine_Handle=iCustom(Symb,Timeframe,"SlopeDirectionLine",MA_Method1,Length1,Phase1,MA_Method2,Phase2,IPC,0,0,On_Push,On_Email,On_Alert,On_Play_Sound,NameFileSound,CommentSirName,SignalBar);
   if(SlopeDirectionLine_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора SlopeDirectionLine");
//--- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"SlopeDirectionLine(",Length1,", ",Smooth1,", ",Smooth2,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//---
   if(ObjectFind(0,name0)!=-1) ObjectDelete(0,name0);
   if(ObjectFind(0,name1)!=-1) ObjectDelete(0,name1);
   if(ObjectFind(0,name2)!=-1) ObjectDelete(0,name2);
   if(ObjectFind(0,name3)!=-1) ObjectDelete(0,name3);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---
   Deinit();
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| SlopeDirectionLine iteration function                            | 
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(SlopeDirectionLine_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(SlopeDirectionLine_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//--- объявление локальныхх переменных
   int to_copy=4;
   double dind0,dind1,dind2;
   double SlopeDirectionLine[4];
   color Color0,Color1,Color2;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(SlopeDirectionLine_Handle,0,SignalBar,to_copy,SlopeDirectionLine)<=0) return(RESET);
//---
   dind0=SlopeDirectionLine[3]-SlopeDirectionLine[2];
   dind1=SlopeDirectionLine[2]-SlopeDirectionLine[1];
   dind2=SlopeDirectionLine[1]-SlopeDirectionLine[0];
//---
   if(dind0<0) Color0=DnSymbol_Color; else Color0=UpSymbol_Color;
   if(dind1<0) Color1=DnSymbol_Color; else Color1=UpSymbol_Color;
   if(dind2<0) Color2=DnSymbol_Color; else Color2=UpSymbol_Color;
//---
   SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,"t",Color0,"Wingdings 2",Symbols_Size);
   SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1,Yn,"u",Color1,"Wingdings 2",Symbols_Size);
   SetTLabel(0,name2,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_2,Yn,"v",Color2,"Wingdings 2",Symbols_Size);
   if(ShowIndName) SetTLabel(0,name3,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_3_,Y_3_,IndName,IndName_Color,"Georgia",Font_Size);
//---
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
