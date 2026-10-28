//+---------------------------------------------------------------------+
//|                                                       JFatlSign.mq5 | 
//|                                 иCopyright © 2015, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "2015, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//--- отрисовка индикатора в основном окне
#property indicator_chart_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован Red цвет
#property indicator_color1  clrRed
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "JFatlSign Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован LimeGreen цвет
#property indicator_color2  clrLimeGreen
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "JFatlSign Buy"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0  // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int JLength=5;                    // Глубина JMA-сглаживания
input int JPhase=-100;                  // Параметр JMA-сглаживания
//--- JPhase: изменяется в пределах -100 ... +100, влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE_;  // Ценовая константа
input int FATLShift=0;                  // Сдвиг FATL по горизонтали в барах
//+----------------------------------------------+
//--- объявление и инициализация переменной для хранения количества расчетных баров
int FATLPeriod=39;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total,start,fstart,FATLSize;
//+------------------------------------------------+ 
//| Инициализация коэффициентов цифрового фильтра  |
//+------------------------------------------------+ 
double dFATLTable[]=
  {
   +0.4360409450, +0.3658689069, +0.2460452079, +0.1104506886,
   -0.0054034585, -0.0760367731, -0.0933058722, -0.0670110374,
   -0.0190795053, +0.0259609206, +0.0502044896, +0.0477818607,
   +0.0249252327, -0.0047706151, -0.0272432537, -0.0338917071,
   -0.0244141482, -0.0055774838, +0.0128149838, +0.0226522218,
   +0.0208778257, +0.0100299086, -0.0036771622, -0.0136744850,
   -0.0160483392, -0.0108597376, -0.0016060704, +0.0069480557,
   +0.0110573605, +0.0095711419, +0.0040444064, -0.0023824623,
   -0.0067093714, -0.0072003400, -0.0047717710, +0.0005541115,
   +0.0007860160, +0.0130129076, +0.0040364019
  };
//+------------------------------------------------------------------+
//| Описание функции iPriceSeries()                                  |
//| Описание функции iPriceSeriesAlert()                             |
//| Описание класса CJJMA                                            |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных 
   FATLSize=ArraySize(dFATLTable);
   start=FATLSize+30;
   min_rates_total=start+1;
   int ATR_Period=10;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,174);
//--- осуществление сдвига индикатора по горизонтали на FATLShift
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,174);
//--- осуществление сдвига индикатора по горизонтали на FATLShift
   PlotIndexSetInteger(1,PLOT_SHIFT,FATLShift);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"JFATLSign(",JLength," ,",JPhase,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int first,bar;
   double jfatl,trend,FATL,ATR[1];
   static double jfatl1,trend1;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=FATLPeriod-1; // стартовый номер для расчета всех баров
      fstart=first;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- объявление переменной класса CJJMA из файла JJMASeries_Cls.mqh
   static CJJMA JMA;
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- формула для фильтра FATL
      FATL=0.0;
      for(int iii=0; iii<FATLSize; iii++) FATL+=dFATLTable[iii]*PriceSeries(IPC,bar-iii,open,low,high,close);
      //--- один вызов функции JJMASeries. 
      //--- параметры Phase и Length не меняются на каждом баре (Din=0) 
      jfatl=JMA.JJMASeries(fstart,prev_calculated,rates_total,0,JPhase,JLength,FATL,bar,false);
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      trend=jfatl-jfatl1;
      //---
      if(trend1<=0 && trend>0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(trend1>=0 && trend<0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //---
      if(bar<rates_total-1)
        {
         trend1=trend;
         jfatl1=jfatl;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
