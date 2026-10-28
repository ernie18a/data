//+------------------------------------------------------------------+
//|                                                  KoliErBands.mq5 | 
//|                                       Copyright 2010, KoliEr Li. | 
//|                                                 http://kolier.li | 
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, KoliEr Li."
#property link "http://kolier.li"
#property description "Модификация индикатора Боллинджера"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 11
#property indicator_buffers 11 
//---- использовано всего 7 графических построений
#property indicator_plots   7
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "KoliEr Line"
//+--------------------------------------------+
//|  Параметры отрисовки индикатора BB уровней |
//+--------------------------------------------+
//---- отрисовка уровней Келтнера в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- выбор цветов уровней Келтнера
#property indicator_color2  clrBlue
#property indicator_color3  clrBlue
//---- уровни Келтнера - штрихпунктирные кривые
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- толщина уровней Келтнера равна 1
#property indicator_width2  1
#property indicator_width3  1
//---- отображение меток уровней Келтнера
#property indicator_label2  "Up KoliErBands"
#property indicator_label3  "Dn KoliErBands"
//+--------------------------------------------+
//|  Параметры отрисовки фона                  |
//+--------------------------------------------+
//---- отрисовка фона в облачном виде
#property indicator_type4   DRAW_FILLING
#property indicator_type5   DRAW_FILLING
#property indicator_type6   DRAW_FILLING
#property indicator_type7   DRAW_FILLING
//---- выбор цветов фона
#property indicator_color4  clrAquamarine
#property indicator_color5  clrDeepSkyBlue
#property indicator_color6  clrViolet
#property indicator_color7 clrLightPink
//---- отображение меток уровней Боллинджера
#property indicator_label4  "Up KoliErBands Cloud Out"
#property indicator_label5  "Up KoliErBands Cloud In"
#property indicator_label6  "Dn KoliErBands Cloud In"
#property indicator_label7  "Dn KoliErBands Cloud Out"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint KB_Period=14;   // Peroid of KoliEr Bands                 
input double KB_Deviation=2.01;    // Deviation Level
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
//+-----------------------------------+
//---- объявление динамического массива, который будет в дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer0[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов уровней Боллинджера
double ExtLineBuffer1[],ExtLineBuffer2[];
double ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[];
double ExtLineBuffer7[],ExtLineBuffer8[];
double ExtLineBuffer9[],ExtLineBuffer10[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| KoliErBands indicator initialization function                    | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(KB_Period)+1;

//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней Келтнера
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer8,INDICATOR_DATA);
   SetIndexBuffer(9,ExtLineBuffer9,INDICATOR_DATA);
   SetIndexBuffer(10,ExtLineBuffer10,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка фона
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(9,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(10,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(10,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"KoliErBands(",KB_Period,", ",DoubleToString(KB_Deviation,3),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| KoliErBands iteration function                                   | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double sum,kb,val_new,deviation;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=min_rates_total; // стартовый номер для расчёта всех баров для канала
     }
   else
     {
      first=prev_calculated-1; // стартовый номер для расчёта новых баров для мувинга
     }
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      kb=(high[ArrayMaximum(high,rates_total-1-bar,KB_Period)]+low[ArrayMinimum(low,rates_total-1-bar,KB_Period)])/2;
      sum=NULL;
      int kkk=bar-int(KB_Period)+1;
      while(kkk<=bar)
        {
         val_new=close[kkk]-kb;
         sum+=val_new*val_new;
         kkk++;
        }
      deviation=KB_Deviation*MathSqrt(sum/KB_Period);
      ExtLineBuffer0[bar]=kb+dPriceShift;

      //---- Расчёт уровней и инициализация индикаторных буферов
      ExtLineBuffer1[bar]=ExtLineBuffer0[bar]+deviation+dPriceShift;
      ExtLineBuffer2[bar]=ExtLineBuffer0[bar]-deviation+dPriceShift;

      ExtLineBuffer3[bar]=ExtLineBuffer0[bar]+deviation*100+dPriceShift;
      ExtLineBuffer4[bar]=ExtLineBuffer0[bar]+deviation+dPriceShift;

      ExtLineBuffer5[bar]=ExtLineBuffer0[bar]+deviation+dPriceShift;
      ExtLineBuffer6[bar]=ExtLineBuffer0[bar]+dPriceShift;


      ExtLineBuffer7[bar]=ExtLineBuffer0[bar]+dPriceShift;
      ExtLineBuffer8[bar]=ExtLineBuffer0[bar]-deviation+dPriceShift;

      ExtLineBuffer9[bar]=ExtLineBuffer0[bar]-deviation+dPriceShift;
      ExtLineBuffer10[bar]=ExtLineBuffer0[bar]-deviation*100+dPriceShift;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
