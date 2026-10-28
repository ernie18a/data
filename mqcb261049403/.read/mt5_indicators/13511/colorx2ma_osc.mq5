//+---------------------------------------------------------------------+
//|                                                   ColorX2MA_Osc.mq5 | 
//|                                Copyright © 2012,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Мувинг X2MA, превращенный в осциллятор с помощью нормирования своих значений в диапозоне от 0 и до 100."
#property description "Для более наглядного восприятия итоговый индикакатор был сдвинут вниз на пятьдесят значений."
#property description "Основная идея нормализации была предложена Трофимовым Евгением Витальевичем"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырехцветной гистограммы использованы
#property indicator_color1 clrTeal,clrBlueViolet,clrIndianRed,clrMagenta
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "X2MA_Osc"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
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
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint nPeriod=100; // Период нормализации осциллятора
input Smooth_Method MA_Method1=MODE_SMA; // Метод усреднения первого сглаживания 
input uint Length1=12; // Глубина  первого сглаживания                    
input int Phase1=15;   // Параметр первого сглаживания
                       // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                       // для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA; // Метод усреднения второго сглаживания 
input uint Length2 = 5; // Глубина  второго сглаживания 
input int Phase2=15;    // Параметр второго сглаживания
                        // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
                        // для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE; // Ценовая константа
/* , по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double X2MAOsc[],ColorX2MAOsc[];
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве кольцевых буферов
int Count[];
double X2MA[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1,min_rates_2;
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента кольцевом буфере        |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)    // размер кольцевых буферов
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+
//| Расчет интерполируемых значений                                  |
//+------------------------------------------------------------------+   
double Interpolation(double a,double b,double c,double d,double X) //a; X; b - столбец известных чисел, c; d; - столбец со стороны неизвестной.
  {
//----
   if(b-a==0) return(10000000); //бесконечность
   else return(d -(b-X) *(d-c)/(b-a));
  }
//+------------------------------------------------------------------+   
//| X2MA Osc indicator initialization function                       | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   min_rates_2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=min_rates_1+min_rates_2+1;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,nPeriod);
   ArrayResize(X2MA,nPeriod);
//---- инициализация массивов переменных
   ArrayInitialize(Count,0);
   ArrayInitialize(X2MA,0.0);
//---- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(Count,true);
   ArraySetAsSeries(X2MA,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,X2MAOsc,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(X2MAOsc,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorX2MAOsc,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorX2MAOsc,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA_Osc(",nPeriod,", ",Length1,", ",Length2,", ",Smooth1,", ",Smooth2,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| X2MA Osc iteration function                                      | 
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
   if(rates_total<min_rates_total) return(0);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);
//---- объявление переменных с плавающей точкой  
   double price_,x1xma,x2xmaosc,MAX,MIN;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int limit,bar,maxbar1,maxbar2;
//----
   maxbar1=rates_total-1;
   maxbar2=maxbar1-min_rates_1;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);
      //---- два вызова функции XMASeries
      x1xma=XMA1.XMASeries(maxbar1,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price_,bar,true);
      X2MA[Count[0]]=XMA2.XMASeries(maxbar2,prev_calculated,rates_total,MA_Method2,Phase2,Length2,x1xma,bar,true);
      //---- нормализация волатильности
      MAX=X2MA[ArrayMaximum(X2MA,0,WHOLE_ARRAY)];
      MIN=X2MA[ArrayMinimum(X2MA,0,WHOLE_ARRAY)];
      //---- нормализуем полученное значение волатильности в пределах диапозона от 0 до 100 и загрузим в индикаторный буфер
      x2xmaosc=Interpolation(MAX,MIN,100,0,X2MA[Count[0]]);
      X2MAOsc[bar]=x2xmaosc-50;
      //---- сделаем пересчет позиций элементов в кольцевых буферах   
      if(bar) Recount_ArrayZeroPos(Count,nPeriod);
     }
//----
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0; bar--)
     {
      int bar1=bar+1;
      //----
      if(X2MAOsc[bar]>=0)
        {
         if(X2MAOsc[bar]>X2MAOsc[bar1]) ColorX2MAOsc[bar]=0;
         if(X2MAOsc[bar]<X2MAOsc[bar1]) ColorX2MAOsc[bar]=1;
         if(X2MAOsc[bar]==X2MAOsc[bar1]) ColorX2MAOsc[bar]=ColorX2MAOsc[bar1];
        }
      //----
      if(X2MAOsc[bar]<0)
        {
         if(X2MAOsc[bar]<X2MAOsc[bar1]) ColorX2MAOsc[bar]=2;
         if(X2MAOsc[bar]>X2MAOsc[bar1]) ColorX2MAOsc[bar]=3;
         if(X2MAOsc[bar]==X2MAOsc[bar1]) ColorX2MAOsc[bar]=ColorX2MAOsc[bar1];
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
