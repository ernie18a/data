//+------------------------------------------------------------------+ 
//|                                                       AO_HTF.mq5 | 
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrGray,clrLime,clrMediumVioletRed,clrRed,clrTeal
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width1 5
//---- отображение лэйбы индикатора
#property indicator_label1 "AO HTF"

//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Период графика
input bool ReDraw=true; //повтор отображения инфомации на пустых барах
//+-----------------------------------+
//---- Объявление переменной для хранения результата инициализации индикатора
bool Init;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int AO_Handle;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double AOBuffer[],ColorAOBuffer[];
//+------------------------------------------------------------------+
//|  Получение стрингового таймфрейма                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+    
//| AO indicator initialization function                             | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=3;
   Init=true;

//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора  Awesome oscillator не может быть меньше периода текущего графика");
      Init=false;
      return;
     }

//---- получение хендла индикатора   Awesome oscillator 
   AO_Handle=iAO(Symbol(),TimeFrame);
   if(AO_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора   Awesome oscillator");
      Init=false;
      return;
     }

//---- превращение динамического массива AOBuffer в индикаторный буфер
   SetIndexBuffer(0,AOBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Awesome oscillator  HTF");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(AOBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorAOBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorAOBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Awesome oscillator HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| AO iteration function                                         | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(AO_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- Объявление целых переменных
   int limit,bar;
//---- Объявление переменных с плавающей точкой  
   double AO[2];
   datetime AOTime[1];
   static uint LastCountBar;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      AOBuffer[bar]=EMPTY_VALUE;
      ColorAOBuffer[bar]=0;

      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,AOTime)<=0) return(RESET);

      if(time[bar]>=AOTime[0] && time[bar+1]<AOTime[0])
        {
         LastCountBar=bar;

         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(AO_Handle,0,time[bar],2,AO)<=0) return(RESET);

         //---- Загрузка полученных значений в индикаторные буферы
         AOBuffer[bar]=AO[1];

         if(AOBuffer[bar]>0)
           {
            if(AO[1]>AO[0]) ColorAOBuffer[bar]=1;
            if(AO[1]<AO[0]) ColorAOBuffer[bar]=2;
           }

         if(AOBuffer[bar]<0)
           {
            if(AO[1]<AO[0]) ColorAOBuffer[bar]=3;
            if(AO[1]>AO[0]) ColorAOBuffer[bar]=4;
           }
        }

      if(ReDraw)
        {
         if(AOBuffer[bar+1]!=EMPTY_VALUE && AOBuffer[bar]==EMPTY_VALUE)
           {
            AOBuffer[bar]=AOBuffer[bar+1];
            ColorAOBuffer[bar]=ColorAOBuffer[bar+1];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
