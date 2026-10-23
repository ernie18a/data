//+---------------------------------------------------------------------+ 
//|                                                      dTrend_HTF.mq5 | 
//|                                  Copyright © 2016, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\MQL5\Include         |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                             // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "dTrend"             // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- использовано всего два графических построения
#property indicator_plots   2
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrLime
#property indicator_color2  clrPurple,clrMagenta
#property indicator_width1  2
#property indicator_width2  2
#property indicator_label1  "dTrend Upper"
#property indicator_label2  "dTrend Lower"
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Период графика
input uint Rasrad=16;
input uint Level=15;                      //уровень срабатывания
input int Shift=0;                        //сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer1[],ColorIndBuffer1[];
double IndBuffer2[],ColorIndBuffer2[];
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
      Print("Период графика для индикатора dTrend не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- Инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- получение хендла индикатора dTrend
   Ind_Handle=iCustom(Symbol_,TimeFrame,"dTrend",Rasrad,Level,0);
   if(Ind_Handle==INVALID_HANDLE)
    {
     Print(" Не удалось получить хендл индикатора dTrend");
     return(INIT_FAILED);
    }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer1,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer1,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer1,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer2,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer2,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorIndBuffer2,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer2,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);

//---- количество  горизонтальных уровней индикатора 2  
   IndicatorSetInteger(INDICATOR_LEVELS,2);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+Level);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-Level);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrRed);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
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
      IndBuffer1[bar]=EMPTY_VALUE;
      IndBuffer2[bar]=EMPTY_VALUE;

      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,IndTime)<=0) return(RESET);
      
      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind_Handle,0,time[bar],1,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,Col)<=0) return(RESET);        
         IndBuffer1[bar]=Ind[0];
         ColorIndBuffer1[bar]=Col[0]; 
         
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind_Handle,2,time[bar],1,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,3,time[bar],1,Col)<=0) return(RESET);
         
         IndBuffer2[bar]=Ind[0];
         ColorIndBuffer2[bar]=Col[0]; 
        }
      else
        {
         IndBuffer1[bar]=IndBuffer1[bar+1];
         ColorIndBuffer1[bar]=ColorIndBuffer1[bar+1];
         
         IndBuffer2[bar]=IndBuffer2[bar+1];
         ColorIndBuffer2[bar]=ColorIndBuffer2[bar+1];  
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
