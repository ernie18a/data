//+---------------------------------------------------------------------+ 
//|                                                   ColorXMUV_HTF.mq5 | 
//|                                  Copyright © 2017, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\MQL5\Include         |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.62"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "ColorXMUV" // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color1  clrMagenta,clrGray,clrTeal
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width1  5
//---- отображение бычей лэйбы индикатора
#property indicator_label1  INDICATOR_NAME
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Smooth_Method
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
  };
//+-------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА       |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Период графика
//+-------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА       |
//+-------------------------------------+
input Smooth_Method XMA_Method=MODE_SMA_; //метод усреднения
input int XLength=14; //глубина сглаживания                    
input int XPhase=15; //параметр сглаживания,
  //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
  // Для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
//+-------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//---- Объявление стрингов
string Symbol_,Word;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора ColorXMUV не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- Инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- получение хендла индикатора ColorXMUV
   Ind_Handle=iCustom(Symbol_,TimeFrame,"ColorXMUV",XMA_Method,XLength,XPhase,0,PriceShift);
   if(Ind_Handle==INVALID_HANDLE)
    {
     Print(" Не удалось получить хендл индикатора ColorXMUV");
     return(INIT_FAILED);
    }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
   
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,"INDICATOR_NAME(",EnumToString(TimeFrame)," ,",XLength," ,",XPhase,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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

//---- объявления локальных переменных 
   double Ind[1],Col[1];
   int limit,bar;
   datetime IndTime[1];
   static double LastInd=0.0;
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

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      IndBuffer[bar]=0.0;
      ColorIndBuffer[bar]=1.0;

      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,IndTime)<=0) return(RESET);
      
      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         
         //---- копируем вновь появившиеся данные в массив Ind
         if(CopyBuffer(Ind_Handle,0,time[bar],1,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,Col)<=0) return(RESET);
         
         IndBuffer[bar]=Ind[0];
         ColorIndBuffer[bar]=Col[0];
        }
      else
        {
         IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=ColorIndBuffer[bar+1];        
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
