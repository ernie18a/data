//+----------------------------------------------------------------------------+
//|                                                         i-AnyRangeCld.mq5  |
//|                                  Copyright © 2006, Ким Игорь В. aka KimIV  |
//|                                                       http://www.kimiv.ru  |
//+----------------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2006, Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
//---- номер версии индикатора
#property version   "1.10"
//---- описание индикатора
#property description "Индикатор диапазонов произвольных временных интервалов"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки облака                   |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет Lavender
#property indicator_color1 clrLavender
//---- отображение метки индикатора
#property indicator_label1  "i-AnyRange"
//+----------------------------------------------+
//| Параметры отрисовки верхней линии            |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//---- отображение бычей метки индикатора
#property indicator_label2  "Upper Zone"
//+----------------------------------------------+
//| Параметры отрисовки нижней линии             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color3  clrRed
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Lower Zone"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string Time1 = "02:00";    // Временная точка 1
input string Time2 = "07:00";    // Временная точка 2
input uint   nDays = 2;          // Количество дней обсчёта (0-все)
input int    Shift=0; // сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
double Up0Buffer[];
double Dn0Buffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,Max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(24*60*60*nDays/PeriodSeconds()+1);
   Max=int(nDays*1440*60/PeriodSeconds());

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Up0Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   //PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Up0Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Dn0Buffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Dn0Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"i-AnyRangeCld(",Time1,", ",Time2,", ",nDays,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----   
  }
//+------------------------------------------------------------------+
//| iBarShift() function                                             |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)

// iBarShift(symbol, timeframe, time)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----+
   if(time<0) return(-1);

   datetime Arr[],time1;

   time1=(datetime) SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);
   if(time>=time1) return(0);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----+
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка периода графика
   if(Period()>PERIOD_H1)
     {
      Comment("Индикатору i-AnyRange нужен ТФ младше H4!");
      return(RESET);
     }
   else Comment("");

//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   double up=NULL,dn=NULL;
   int    bar,limit,kd=0,nb1=0,nb2=0,nd=0,rates_10;
   string sdt;
      
   rates_10=rates_total-10;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(nDays==0) limit=rates_10;
   else limit=Max;
   limit=MathMin(rates_10,limit);
   
//---- осуществление сдвига начала отсчёта отрисовки индикаторов
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,rates_total-limit);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   
//---- основной цикл обнуления
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      Up0Buffer[bar]=NULL;
      Dn0Buffer[bar]=NULL;
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
     }
     
//---- основной цикл расчёта индикатора
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
      MqlDateTime tm;
      TimeToStruct(time[bar],tm);

      if(nd!=tm.day)
        {
         nd=tm.day;
         kd++;
         if(kd>int(nDays) && nDays) return(rates_total);

         sdt=TimeToString(time[bar],TIME_DATE);

         nb1=iBarShift(NULL, 0, StringToTime(sdt+" "+Time1));
         nb2=iBarShift(NULL, 0, StringToTime(sdt+" "+Time2));

         if(nb1>nb2+1)
           {
            up=high[ArrayMaximum(high,nb2+1,nb1-nb2)];
            dn=low[ArrayMinimum(low,nb2+1,nb1-nb2)];
           }

         if(nb2>nb1+1)
           {
            up=high[ArrayMaximum(high,nb1+1,nb2-nb1)];
            dn=low[ArrayMinimum(low,nb1+1,nb2-nb1)];
           }
        }
      if((nb1>=bar && bar>nb2) || (nb2>=bar && bar>nb1))
        {
         UpBuffer[bar]=up;
         DnBuffer[bar]=dn;
         Up0Buffer[bar]=up;
         Dn0Buffer[bar]=dn;
        }
      else
        {
         UpBuffer[bar]=EMPTY_VALUE;
         DnBuffer[bar]=EMPTY_VALUE;
        }
     }
     
//---- основной цикл обнуления облака
   for(bar=0; bar<limit && !IsStopped(); bar++)
     {
      if(UpBuffer[bar]==EMPTY_VALUE && DnBuffer[bar]==EMPTY_VALUE)
        {
         Up0Buffer[bar]=NULL;
         Dn0Buffer[bar]=NULL;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
