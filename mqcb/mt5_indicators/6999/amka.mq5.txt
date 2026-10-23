//+------------------------------------------------------------------+
//|                                                         AMkA.mq5 |
//|              MQL4 Code:  Copyright © 2004, GOODMAN & Mstera и AF |
//|              MQL5 Code:     Copyright © 2010,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2004, by GOODMAN & Mstera и AF"
//--- ссылка на сайт автора
#property link      "http://forum.viac.ru/viewforum.php?f=7"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчёта и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//--- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки линии AMA                |
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
#property indicator_label1  "AMA"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color2  clrRed
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Dn_Signal"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован зелёный цвет
#property indicator_color3  clrLime
//--- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//--- отображение бычей метки индикатора
#property indicator_label3  "Up_Signal"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int ama_period=9;      // Период AMA
input int fast_ma_period=2;  // Период быстрой скользящей
input int slow_ma_period=30; // Период медленной скользящей
input double G=2.0;          // Степень, в которую возводится сглаживающая константа
input int AMAShift = 0;      // Сдвиг индикатора по горизонтали в барах 
input double dK = 1.0;       // Коэффициент для фильтра
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double AMABuffer[];
double BearsBuffer[];
double BullsBuffer[];
//--- объявление переменных с плавающей точкой для констант
double dSC,slowSC,fastSC; int AMA_Handle,dAMA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- превращение динамического массива AMABuffer в индикаторный буфер
   SetIndexBuffer(0,AMABuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на ama_shift
   PlotIndexSetInteger(0,PLOT_SHIFT,AMAShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 1 на 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ama_period+1);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"AMA");
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(1,BearsBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на ama_shift
   PlotIndexSetInteger(1,PLOT_SHIFT,AMAShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 2 на ama_period + 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,ama_period+2);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"DnSignal");
//--- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(2,BullsBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 3 по горизонтали на ama_shift
   PlotIndexSetInteger(2,PLOT_SHIFT,AMAShift);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 3 на ama_period + 2
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,ama_period+2);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"UpSignal");
//--- выбор символа для отрисовки
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"AMkA( ",ama_period,", ",fast_ma_period,", ",slow_ma_period," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
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
                const int begin,          // номер начала достоверного отсчёта баров
                const double &price[])    // ценовой массив для расчёта индикатора
  {
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<2*ama_period+2+begin) return(0);
//--- объявления локальных переменных 
   int first,bar,iii;
   double noise,AMA,signal,ER,ERSC,SSC,price0,price1;
   double Sum,SMAdif,StDev,BULLS,BEARS,Filter;
   static double dAMA[],dama;
//--- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=ama_period+2+begin; // стартовый номер для расчёта всех баров
      AMA=price[first-1];
      if(ArrayResize(dAMA,ama_period)!=ama_period) return(0);

      //--- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0)
        {
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ama_period+begin);
         PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,2*ama_period+begin+2);
         PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,2*ama_period+begin+2);
        }
     }
   else
     {
      first=prev_calculated-1; // стартовый номер для расчёта новых баров
      AMA=AMABuffer[first-1];
     }
//--- основной цикл расчёта индикатора AMA
   for(bar=first; bar<rates_total; bar++)
     {
      //--- 
      noise=Point()/10000;
      for(iii=0; iii<ama_period; iii++)
        {
         price0 = price[bar - iii - 0];
         price1 = price[bar - iii - 1];
         noise += MathAbs(price0 - price1);
        }
      price0 = price[bar];
      price1 = price[bar - ama_period];
      signal = MathAbs(price0 - price1);
      ER=signal/noise;
      ERSC= ER * dSC;
      SSC = ERSC + slowSC;
      AMA = AMA + (MathPow(SSC, G) * (price0 - AMA));
      //AMA = NormalizeDouble(AMA, _Digits);
      //--- инициализация ячейки индикаторного буфера полученным значением AMA
      AMABuffer[bar]=AMA;
     }

   if(prev_calculated==0)
      first=2*ama_period+6+begin;
//--- основной цикл расчёта индикатора AMkA
   for(bar=first; bar<rates_total; bar++)
     {
      //--- загружаем приращения индикатора AMA в массив для промежуточных вычислений
      for(iii=0; iii<ama_period; iii++)
         dAMA[iii]=AMABuffer[bar-iii-0]-AMABuffer[bar-iii-1];
      //--- находим простое среднее приращений AMA
      Sum=0.0;
      for(iii=0; iii<ama_period; iii++)
         Sum+=dAMA[iii];
      SMAdif=Sum/ama_period;
      //--- находим сумму квадратов разностей приращений и среднего
      Sum=0.0;
      for(iii=0; iii<ama_period; iii++)
         Sum+=MathPow(dAMA[iii]-SMAdif,2);
      //--- определяем итоговое значение среднеквадратичного отклонения StDev от приращения AMA
      StDev=MathSqrt(Sum/ama_period);
      //--- инициализация переменных
      dama=NormalizeDouble(dAMA[0],_Digits+2);
      Filter= NormalizeDouble(dK * StDev,_Digits+2);
      BEARS = 0;
      BULLS = 0;
      //--- вычисление индикаторных значений
      if(dama < -Filter) BEARS = AMABuffer[bar]; //есть нисходящий тренд
      if(dama > +Filter) BULLS = AMABuffer[bar]; //есть восходящий тренд
      //--- инициализация ячеек индикаторных буферов полученными значениями 
      BullsBuffer[bar] = BULLS;
      BearsBuffer[bar] = BEARS;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
