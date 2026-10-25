//+------------------------------------------------------------------+
//|                                                    AMA_SLOPE.mq5 |
//|                                        Copyright © 2007, Kalenzo |
//|                                      bartlomiej.gorski@gmail.com | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2007, Kalenzo"
//--- ссылка на сайт автора
#property link      "bartlomiej.gorski@gmail.combartlomiej.gorski@gmail.com"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//--- использовано одно графическе построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован сине-фиолетовый цвет
#property indicator_color1  clrBlueViolet
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 3
#property indicator_width1  3
//--- отображение бычей метки индикатора
#property indicator_label1  "AMA_SLOPE"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint ama_period=9;        // Период AMA
input uint fast_ma_period=2;    // Период быстрой скользящей
input uint slow_ma_period=30;   // Период медленной скользящей
input double G=2.0;             // Степень, в которую возводится сглаживающая константа
input int AMAShift = 0;         // Сдвиг индикатора по горизонтали в барах 
input double dK = 1.0;          // Коэффициент для фильтра
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double AMABuffer[];
//--- объявление переменных с плавающей точкой для констант
double dSC,slowSC,fastSC;
int AMA_Handle,dAMA_Handle;
//--- объявление целых переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация глобальных переменных
   min_rates_total=int(ama_period+1);
//--- превращение динамического массива AMABuffer в индикаторный буфер
   SetIndexBuffer(0,AMABuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на ama_shift
   PlotIndexSetInteger(0,PLOT_SHIFT,AMAShift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1 на 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"AMA_SLOPE( ",ama_period,", ",fast_ma_period,", ",slow_ma_period," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- инициализация констант 
   slowSC = (2.0 / (slow_ma_period + 1));
   fastSC = (2.0 / (fast_ma_period + 1));
   dSC=fastSC-slowSC;
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total+begin) return(0);
//--- объявления локальных переменных 
   int first,bar;
   double noise,AMA,signal,ER,ERSC,SSC,price0,price1;
   static double AMA_;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=min_rates_total+begin+1; // стартовый номер для расчета всех баров
      AMA_=price[first-1];
      AMA=AMA_;
      //--- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0)
        {
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
        }
     }
   else
     {
      first=prev_calculated-1; // стартовый номер для расчета новых баров
      AMA=AMA_;
     }
//--- основной цикл расчета индикатора AMA
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---
      noise=_Point/10000;
      for(int iii=0; iii<int(ama_period); iii++)
        {
         price0=price[bar-iii-0];
         price1=price[bar-iii-1];
         noise+=MathAbs(price0-price1);
        }
      //---
      price0=price[bar];
      price1=price[bar-ama_period];
      signal=MathAbs(price0-price1);
      ER=signal/noise;
      ERSC=ER*dSC;
      SSC=ERSC+slowSC;
      AMA=AMA+(MathPow(SSC,G)*(price0-AMA));
      //--- инициализация ячейки индикаторного буфера полученным значением AMA
      AMABuffer[bar]=(AMA-AMA_)/_Point;
      if(bar<rates_total-1) AMA_=AMA;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
