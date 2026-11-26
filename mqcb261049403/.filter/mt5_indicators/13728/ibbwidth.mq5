//+------------------------------------------------------------------+
//|                                                   i-BB-Width.mq5 | 
//|                        Copyright © 2007, Ким Игорь В. aka KimIV. | 
//|                                             http://www.kimiv.ru/ | 
//+------------------------------------------------------------------+

#property copyright "Copyright © 2007, Ким Игорь В. aka KimIV."
#property link "http://www.kimiv.ru/"
#property description "Ширина Полос Боллинджера"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color1 Blue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "i-BB-Width"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint bands_period=20; // Глубина сглаживания
input double deviation=2.0; // Девиация
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE; // Тип цены или handle
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double IndBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int BB_Handle;
//---- объявление целочисленных переменных начала отсчета данных
uint min_rates_total;
//+------------------------------------------------------------------+   
//| i-BB-Width indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=bands_period;
//---- получение хендла индикатора iBearsPower
   BB_Handle=iBands(NULL,0,int(bands_period),0,deviation,applied_price);
   if(BB_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iBands");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"i-BB-Width(",
                     bands_period,", ",deviation,", ",EnumToString(applied_price),", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| i-BB-Width iteration function                                    | 
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
   if(BarsCalculated(BB_Handle)<rates_total || rates_total<int(min_rates_total)) return(RESET);
//---- объявление переменных с плавающей точкой  
   double UpBB[],DnBB[];
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int limit,bar,to_copy;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=int(rates_total-min_rates_total-1); // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
   to_copy=limit+1;
//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(UpBB,true);
   ArraySetAsSeries(DnBB,true);
//---- копируем вновь появившиеся данные в массивы  
   if(CopyBuffer(BB_Handle,UPPER_BAND,0,to_copy,UpBB)<=0) return(RESET);
   if(CopyBuffer(BB_Handle,LOWER_BAND,0,to_copy,DnBB)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=(UpBB[bar]-DnBB[bar])/_Point;
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
