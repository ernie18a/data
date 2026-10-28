//+---------------------------------------------------------------+ 
//|                              UltraAbsolutelyNoLagLwma_HTF.mq5 | 
//|                            Copyright © 2018, Nikolay Kositsin | 
//|                           Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего одно графическое построение
#property indicator_plots   2
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде гистограммы 2
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов гистограммы использованы
#property indicator_color1  clrGray,clrMagenta,clrHotPink,clrRed,clrBrown,clrLimeGreen,clrTeal,clrLime,clrPaleGreen
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width1 5
//---- отображение лэйбы индикатора
#property indicator_label1 "UltraAbsolutelyNoLagLwma HTF"

//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  объявление перечислений          |
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
//|  объявление перечисления          |
//+-----------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+-----------------------------------+
//|  объявление перечисления          |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,       // Сплошная линия
   DASH_,        // Штриховая линия
   DOT_,         // Пунктирная линия
   DASHDOT_,     // Штрих-пунктирная линия
   DASHDOTDOT_   // Штрих-пунктирная линия с двойными точками
  };
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;          // Период графика
//----
input uint FLength=7;                                // глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;              // ценовая константа
//----
input Smooth_Method W_Method=MODE_JJMA;             // Метод усреднения
input int StartLength=3;                            // Стартовый период усреднения                    
input int WPhase=100;                               // Параметр усреднения
//----  
input uint Step=5;                                  // Шаг изменения периода
input uint StepsTotal=10;                           // Количество изменений периода
//----
input Smooth_Method SmoothMethod=MODE_JJMA;         // Метод сглаживания
input int SmoothLength=3;                           // Глубина сглаживания
input int SmoothPhase=100;                          // Параметр сглаживания
//----                          
input uint UpLevel=80;                              // Уровень перекупленности в %%
input uint DnLevel=20;                              // Уровень перепроданности в %%
input color UpLevelsColor=clrBlue;                  // Цвет уровня перекупленности
input color DnLevelsColor=clrBlue;                  // Цвет уровня перепроданности
input STYLE Levelstyle=DASH_;                       // Стиль уровней
input WIDTH  LevelsWidth=Width_1;                   // Толщина уровней   
  
input bool ReDraw=true;                             // повтор отображения инфомации на пустых барах
//+-----------------------------------+
//---- Объявление массива переменных для хранения периодов сигнальных линий индикатора UltraAbsolutelyNoLagLwma
int period[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle;
//----
double dUpLevel,dDnLevel;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[],ColorBuffer[];
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| UltraAbsolutelyNoLagLwma indicator initialization function       | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=3;

//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора UltraAbsolutelyNoLagLwma не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора UltraAbsolutelyNoLagLwma
   Ind_Handle=iCustom(Symbol(),TimeFrame,"UltraAbsolutelyNoLagLwma",FLength,IPC,W_Method,StartLength,WPhase,
                            Step,StepsTotal,SmoothMethod,SmoothLength,SmoothPhase,UpLevel,DnLevel,clrNONE,clrNONE,0,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора UltraAbsolutelyNoLagLwma");
      return(INIT_FAILED);
     }

//---- инициализация переменных
   dUpLevel=StepsTotal*UpLevel/100.0;
   dDnLevel=StepsTotal*DnLevel/100.0;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBuffer,true);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"UltraAbsolutelyNoLagLwma HTF( ",GetStringTimeframe(TimeFrame)," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);

//---- параметры отрисовки линий  
   IndicatorSetInteger(INDICATOR_LEVELS,2);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,dUpLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,dDnLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);

//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| UltraAbsolutelyNoLagLwma iteration function                                     | 
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
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);


//---- Объявление целых переменных
   int limit,bar;
//---- Объявление переменных с плавающей точкой  
   double UpValue[1],DnValue[1],clrValue[1];
   datetime UltraAbsolutelyNoLagLwmaTime[1];
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
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
      ColorBuffer[bar]=0;

      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,UltraAbsolutelyNoLagLwmaTime)<=0) return(RESET);

      if(time[bar]>=UltraAbsolutelyNoLagLwmaTime[0] && time[bar+1]<UltraAbsolutelyNoLagLwmaTime[0])
        {
         LastCountBar=bar;

         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind_Handle,0,time[bar],1,DnValue)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,UpValue)<=0) return(RESET);        
         if(CopyBuffer(Ind_Handle,2,time[bar],1,clrValue)<=0) return(RESET);

         //---- Загрузка полученных значений в индикаторные буферы
         UpBuffer[bar]=UpValue[0];
         DnBuffer[bar]=DnValue[0];
         ColorBuffer[bar]=clrValue[0];
        }

      if(ReDraw)
        {
         if(UpBuffer[bar+1]!=EMPTY_VALUE && UpBuffer[bar]==EMPTY_VALUE)
           {
            ColorBuffer[bar]=ColorBuffer[bar+1];
            UpBuffer[bar]=UpBuffer[bar+1];
            DnBuffer[bar]=DnBuffer[bar+1];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
