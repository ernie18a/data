//+---------------------------------------------------------------------+ 
//|                                                        Dots_HTF.mq5 | 
//|                                  Copyright © 2015, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+  
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Dots" // константа для имени индикатора
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветных значков
#property indicator_type1   DRAW_COLOR_ARROW
//---- в качестве цветов значков использованы
#property indicator_color1  clrBlue,clrRed
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Dots"
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;        // Период графика
input uint AlertCount=0;                          // Количество подаваемых алертов
input uint SignalBar=1;                           // Номер бара для сигнала, 0-текущий бар
input bool Repeat=true;                           // Повтор значений на следующих барах
input uint Length = 10;                           // Глубина сглаживания
input uint Filter = 0;                            // Параметр, позволяющий фильтровать всплески цен без добавления задержек в отображение
input Applied_price_ IPC=PRICE_CLOSE_;            // Ценовая константа
input int PriceShift=0;                           // Сдвиг индикатора по вертикали в пунктах
input int Shift=0;                                // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//---- объявление строковых переменных
string Symbol_,Word;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int Dots_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора Dots не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//---- инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//---- получение хендла индикатора Dots
   Dots_Handle=iCustom(Symbol_,TimeFrame,"Dots",Length,Filter,IPC,PriceShift,0);
   if(Dots_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Dots");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
//PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Dots_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//---- объявление локальных переменных 
   double Dots[1],CLR[1];
   int limit,bar;
   datetime DotsTime[1];
   static uint UpCount,DnCount;
   static uint UpCount_,DnCount_;
   static double LastDots=0.0;
   static uint LastCountBar;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчета новых баров 
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчета
      IndBuffer[bar]=0.0;
      ColorIndBuffer[bar]=EMPTY_VALUE;
      //---- копируем вновь появившиеся данные в массив DotsTime
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,DotsTime)<=0) return(RESET);
      //----
      if(time[bar]>=DotsTime[0] && time[bar+1]<DotsTime[0])
        {
         LastCountBar=bar;
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Dots_Handle,0,time[bar],1,Dots)<=0) return(RESET);
         if(CopyBuffer(Dots_Handle,1,time[bar],1,CLR)<=0) return(RESET);
         //----
         IndBuffer[bar]=Dots[0];
         ColorIndBuffer[bar]=CLR[0];
        }
      else if(Repeat)
        {
         IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
        }
     }
//---- сброс счетчиков алертов в нули
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
      UpCount_=0;
      DnCount_=0;
     }
//---- подача алерта для покупки
   if(UpCount<AlertCount && ColorIndBuffer[SignalBar]==2)
     {
      UpCount++;
      Alert(Word+": Сигнал на покупку по "+Symbol_);
     }
//---- подача алерта для продажи
   if(DnCount<AlertCount && ColorIndBuffer[SignalBar]==1)
     {
      DnCount++;
      Alert(Word+": Сигнал на продажу по "+Symbol_);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
