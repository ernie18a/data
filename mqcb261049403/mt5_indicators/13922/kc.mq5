//+------------------------------------------------------------------+
//|                                                           KC.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "ATR channel"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего 5 графических построений
#property indicator_plots   3
//+--------------------------------------------+ 
//| Объявление констант                        |
//+--------------------------------------------+
#define RESET 0  // константа для возврата терминалу команды на пересчет индикатора
//+--------------------------------------------+
//| Параметры отрисовки индикатора             |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 BlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "MA"
//+--------------------------------------------+
//| Параметры отрисовки канала                 |
//+--------------------------------------------+
//---- отрисовка уровней Боллинджера в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- ввыбор цветов уровней Боллинджера
#property indicator_color2  Red
#property indicator_color3  Red
//---- уровни Боллинджера - штрихпунктирные кривые
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- толщина уровней Боллинджера равна 1
#property indicator_width2  1
#property indicator_width3  1
//---- отображение меток уровней Боллинджера
#property indicator_label2  "+ATR"
#property indicator_label3  "-ATR"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input ENUM_MA_METHOD MA_Method=MODE_SMA; // Метод усреднения MA
input uint MA_Period=20;                 // Период MA
input uint ATR_Period=20;                // Период ATR
input double Factor=1.5;                 // Девиация канала 
input ENUM_APPLIED_PRICE IPC=PRICE_CLOSE;// Ценовая константа
input int Shift=0;                       // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double MA_Buffer[],UpATRBuffer[],DnATRBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int MA_Handle,ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(MA_Period,ATR_Period));
//---- получение хендла индикатора MA
   MA_Handle=iMA(NULL,0,MA_Period,0,MA_Method,IPC);
   if(MA_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора MA");
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора ATR");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,MA_Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(MA_Buffer,true);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,UpATRBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,DnATRBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикаторов по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- установка позиции, с которой начинается отрисовка индикаторов
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(UpATRBuffer,true);
   ArraySetAsSeries(DnATRBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR channel");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
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
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int limit,to_copy;
   double ATR[],atr;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA_Buffer)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      atr=Factor*ATR[bar];
      UpATRBuffer[bar]=MA_Buffer[bar]+atr;
      DnATRBuffer[bar]=MA_Buffer[bar]-atr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
