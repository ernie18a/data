//+------------------------------------------------------------------+
//|                                                    Asymmetry.mq5 |
//|                                  Copyright © 2008, Fedor Igumnov |
//|                                           igumnovfedor@yandex.ru |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2008,Fedor Igumnov"
//---- ссылка на сайт автора
#property link      "igumnovfedor@yandex.ru"
#property description "Индикатор ассиметрии"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 1
#property indicator_buffers 1 
//---- использовано всего одно графические построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве цвета линии использован MediumSlateBlue цвет
#property indicator_color1 clrMediumSlateBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "Asymmetry"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint AsPeriod=30; // Период индикатора
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer[];
//---- объявление переменных для хранения хендлов индикаторов
int RSI_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- получение хендла индикатора RSI
   RSI_Handle=iRSI(NULL,PERIOD_CURRENT,AsPeriod,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора iRSI");
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(AsPeriod);
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Asymmetry(",AsPeriod," ",Shift,")");
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- создание метки для отображения в Окне данных
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtLineBuffer,true);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление локальных переменных 
   int to_copy,limit,bar,i;
   double RSI[],M,D,MD,stdDev;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//----
   to_copy=int(limit+1+AsPeriod);
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);
//---- индексация элементов в массиве как в таймсериии  
   ArraySetAsSeries(RSI,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      M=0.0;
      D=0.0;
      MD=0.0;
      //----
      for(i=0; i<int(AsPeriod); i++) M+=RSI[bar+i];
      M/=AsPeriod;
      for(i=0; i<int(AsPeriod); i++) D+=MathPow(RSI[bar+i]-M,2);
      D/=AsPeriod;
      stdDev=MathSqrt(D);
      for(i=0; i<int(AsPeriod); i++) MD+=MathPow(RSI[bar+i]-D,2);
      MD/=AsPeriod;
      ExtLineBuffer[bar]=MathAbs(MD/(D*stdDev));
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
