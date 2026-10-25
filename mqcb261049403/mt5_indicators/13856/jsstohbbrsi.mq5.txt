//+---------------------------------------------------------------------+
//|                                                  JS-Stoh-BB-RSI.mq5 | 
//|                                         Copyright © 2009, js_sergey | 
//|                          js_sergey@list.ru, http://multiexperts.ru/ | 
//+---------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh следует положить    |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, js_sergey"
#property link "http://multiexperts.ru/"
#property description "X2MA Bollinger Bands"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 5
#property indicator_buffers 5 
//---- использовано всего 5 графических построений
#property indicator_plots   5
//+----------------------------------------------+
//| Параметры отрисовки индикатора  1            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color1 clrBlue
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Stochastic"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован зеленый цвет
#property indicator_color2 clrTeal
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "RSI"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color3 clrBlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "Stochastic Signal"
//+----------------------------------------------+
//| Параметры отрисовки индикатора BB уровней    |
//+----------------------------------------------+
//---- отрисовка уровней Боллинджера в виде линий
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//---- ввыбор цветов уровней Боллинджера
#property indicator_color4  clrRed
#property indicator_color5  clrRed
//---- уровни Боллинджера - сплошные кривые
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
//---- толщина уровней Боллинджера равна 1
#property indicator_width4  1
#property indicator_width5  1
//---- отображение меток уровней Боллинджера
#property indicator_label4  "+2Sigma Stochastic"
#property indicator_label5  "-2Sigma Stochastic"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1  80.0
#property indicator_level2  70.0
#property indicator_level3  50.0
#property indicator_level4  30.0
#property indicator_level5  20.0
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Описание классов усреднений                  |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных классов CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMA;
CStdDeviation STD;
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint STO_KPeriod=5;  // K period стохастика
input uint STO_DPeriod=3;  // D period стохастика
input uint STO_Slowing=3;  // Slowing стохастика
input ENUM_MA_METHOD STO_Method=MODE_SMA; // Тип сглаживания стохастика
input ENUM_STO_PRICE STO_Price=STO_LOWHIGH; // Способ расчета стохастика
input uint BandsPeriod=10; // Период усреднения BB
input double BandsDeviation=1.0; // Девиация
input uint RSI_Period=8; // Период индикатора RSI
input ENUM_APPLIED_PRICE RSI_Price=PRICE_CLOSE; // Тип цены для индикатора RSI
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[];
//---- объявление целочисленных переменных для хендлов индикаторов
int RSI_Handle,STO_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_sto;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_sto=int(STO_KPeriod+STO_DPeriod+STO_Slowing+1);
   int min_rates_=int(min_rates_sto+BandsDeviation);
   min_rates_total=int(MathMax(min_rates_,RSI_Period));
//---- получение хендла индикатора iRSI  
   RSI_Handle=iRSI(NULL,PERIOD_CURRENT,RSI_Period,RSI_Price);
   if(RSI_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iRSI");
//---- получение  хендла индикатора iStochastic
   STO_Handle=iStochastic(NULL,0,STO_KPeriod,STO_DPeriod,STO_Slowing,STO_Method,STO_Price);
   if(STO_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iStochastic");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer1,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer2,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer3,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer4,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer5,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"JS-Stoh-BB-RSI");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
   if(BarsCalculated(STO_Handle)<rates_total
      || BarsCalculated(RSI_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);
//---- объявление целочисленных переменных
   int limit,bar,to_copy,xmaxbar,smaxbar;
//---- объявление переменных с плавающей точкой  
   double stoh,xstoh,stdev;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров 
//----
   xmaxbar=rates_total-min_rates_sto-1;
   smaxbar=xmaxbar-int(BandsPeriod);
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(STO_Handle,MAIN_LINE,0,to_copy,ExtLineBuffer1)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle,MAIN_LINE,0,to_copy,ExtLineBuffer2)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      stoh=ExtLineBuffer1[bar];
      xstoh=XMA.XMASeries(xmaxbar,prev_calculated,rates_total,int(MODE_SMA),0,BandsPeriod,stoh,bar,true);
      ExtLineBuffer3[bar]=xstoh;
      stdev=STD.StdDevSeries(smaxbar,prev_calculated,rates_total,BandsPeriod,BandsDeviation,stoh,xstoh,bar,true);
      ExtLineBuffer4[bar]=xstoh+stdev;
      ExtLineBuffer5[bar]=xstoh-stdev;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
