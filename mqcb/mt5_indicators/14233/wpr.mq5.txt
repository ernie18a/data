//+------------------------------------------------------------------+
//|                                                          WPR.mq5 |
//|                                       Copyright © 2005, Dark Han |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, Dark Han"
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net/"
#property description "Williams’ Percent Range"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 1
#property indicator_buffers 1 
//---- использовано всего одно графические построение
#property indicator_plots   1
//---- ограничения масштаба размеров окна индикатора по вертикали
#property indicator_maximum 0
#property indicator_minimum -100
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве цвета линии использован MediumOrchid цвет
#property indicator_color1 clrMediumOrchid
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "WPR"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 -30
#property indicator_level2 -70
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_            //PRICE_LOW
  };
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint ExtWPRPeriod=11;                       // Период усреднения
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;       // Ценовая константа
input int Shift = 0;                              // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(ExtWPRPeriod);
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"WPR(",ExtWPRPeriod," ",EnumToString(IPC),")");
//---- осуществление сдвига индикатора 1 по горизонтали на ATRShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtLineBuffer,true);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if(rates_total<min_rates_total) return(RESET);
//---- объявление локальных переменных 
   int limit,bar;
   double range,HH,LL;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtLineBuffer[bar]=50;
      HH=high[ArrayMaximum(high,bar,ExtWPRPeriod)];
      LL=low[ArrayMinimum(low,bar,ExtWPRPeriod)];
      range=HH-LL;
//----
      if(!CompareDouble(range,0.0))
         switch(IPC)
           {
            case PRICE_CLOSE_ :
              {
               ExtLineBuffer[bar]=-100*(HH-close[bar])/range;
               break;
              }
            case PRICE_HIGH_ :
              {
               ExtLineBuffer[bar]=-100*(HH-high[bar])/range;
               break;
              }
            case PRICE_LOW_ :
              {
               ExtLineBuffer[bar]=-100*(HH-low[bar])/range;
               break;
              }
           }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Функция сравнения двух вещественных чисел                        |
//+------------------------------------------------------------------+
bool CompareDouble(double Number1,double Number2)
  {
//----
   bool Compare=NormalizeDouble(Number1-Number2,8)==0;
//----
   return(Compare);
  }
//+------------------------------------------------------------------+
