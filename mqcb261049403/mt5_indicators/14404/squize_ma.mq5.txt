//+---------------------------------------------------------------------+
//|                                                       Squize_MA.mq5 | 
//| mtf:ForexTSD.com                          Copyright © 2007, Kalenzo | 
//| mladen's formula   ki                   bartlomiej.gorski@gmail.com |
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"
#property description "Новая и очень удачная версия MA - на график добавлены условные границы флета." 
#property description "Выход за них сигнализирует о возникновении условий для устойчивого тренда."
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего 4 графических построения
#property indicator_plots   4
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован Chocolate цвет
#property indicator_color1 clrChocolate
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Squize_MA1"
//+--------------------------------------------+
//| Параметры отрисовки индикатора уровней     |
//+--------------------------------------------+
//---- отрисовка уровней Боллинджера в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- ввыбор цветов уровней Боллинджера
#property indicator_color2  clrTeal
#property indicator_color3  clrRed
//---- уровни Боллинджера - штрихпунктирные кривые
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- толщина уровней равна 5
#property indicator_width2  5
#property indicator_width3  5
//---- отображение меток уровней Боллинджера
#property indicator_label2  "+Squize_MA Env"
#property indicator_label3  "-Squize_MA Env"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color4 clrBlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4  2
//---- отображение метки индикатора
#property indicator_label4  "Squize_MA2"
//+-----------------------------------+
//| Описание классов усреднений       |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных классов CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
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
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Smooth_Method MA_Method1=MODE_EMA; // Метод первого усреднения
input uint Length1=5; // Глубина  первого сглаживания
input int Phase1=15;  // Параметр первого среднения
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC1=PRICE_CLOSE; // Ценовая константа
input Smooth_Method MA_Method2=MODE_EMA; // Метод второго усреднения
input uint Length2=21; // Глубина  второго усреднения
input int Phase2=100;  // Параметр второго сглаживания
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC2=PRICE_CLOSE; // Ценовая константа
input uint MAsThreSHoldPips=15;
input bool ATRmode=true;
input uint ATRperiod=50;
input double ATRmultipl=0.4;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамического массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double XMA1Buffer[],XMA2Buffer[];
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов уровней Боллинджера
double ExtLineBuffer1[],ExtLineBuffer2[];
//---- объявление переменной для хранения хендла индикатора
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
uint min_rates_1,min_rates_2,min_rates_total;
//+------------------------------------------------------------------+   
//| Squize_MA indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=XMA1.GetStartBars(MA_Method1, Length1, Phase1);
   min_rates_2=XMA2.GetStartBars(MA_Method2, Length2, Phase2);
   min_rates_total=MathMax(min_rates_1,min_rates_2);
   if(ATRmode) min_rates_total+=ATRperiod;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
   XMA2.XMALengthCheck("BandsPeriod",ATRperiod);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);
//---- получение хендла индикатора ATR
   if(ATRmode)
     {
      ATR_Handle=iATR(NULL,PERIOD_CURRENT,ATRperiod);
      if(ATR_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора ATR");
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,XMA1Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(XMA1Buffer,true);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней пробоя
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,XMA2Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 4 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(XMA2Buffer,true);

//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(MA_Method1);
   string Smooth2=XMA1.GetString_MA_Method(MA_Method2);
   StringConcatenate(shortname,"X2MA_Bollinger Bands(",
                     Length1,", ",Length2,", ",ATRperiod,", ",Smooth1,", ",Smooth2,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Squize_MASquize_MA iteration function                            | 
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
   if((ATRmode && BarsCalculated(ATR_Handle)<rates_total) || rates_total<int(min_rates_total)) return(RESET);
//---- объявление переменных с плавающей точкой  
   double price_1,price_2,x1xma,x2xma,madif,delta,Range[];
//---- объявление целых переменных и получение уже посчитанных баров
   int to_copy,limit,bar;
   uint maxbar=rates_total-1;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      to_copy=rates_total; // расчетное количество всех баров
      limit=rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
      to_copy=limit+1; // расчетное количество только новых баров
     }
//---- копируем вновь появившиеся данные в массив Range[]
   if(ATRmode)if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Range,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price_1=PriceSeries(IPC1,bar,open,low,high,close);
      price_2=PriceSeries(IPC2,bar,open,low,high,close);
      //---- два вызова функции XMASeries
      //---- во втором вызове параметр begin увеличен на StartBars1, т. к. это повторное XMA сглаживание
      x1xma = XMA1.XMASeries(maxbar, prev_calculated, rates_total, MA_Method1, Phase1, Length1, price_1, bar, true);
      x2xma = XMA2.XMASeries(maxbar, prev_calculated, rates_total, MA_Method2, Phase2, Length2, price_2, bar, true);
      madif = MathAbs(x1xma-x2xma);
      //----
      XMA1Buffer[bar]=x1xma;
      XMA2Buffer[bar]=x2xma;
      //----
      if(ATRmode) delta=Range[bar]*ATRmultipl/_Point;
      else        delta=MAsThreSHoldPips;
      //----
      if(madif/_Point<delta)
        {
         double dPoint=delta*_Point;
         ExtLineBuffer1[bar]=x2xma+dPoint;
         ExtLineBuffer2[bar]=x2xma-dPoint;
        }
      else
        {
         ExtLineBuffer1[bar]=EMPTY_VALUE;
         ExtLineBuffer2[bar]=EMPTY_VALUE;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
