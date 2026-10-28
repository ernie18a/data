//+---------------------------------------------------------------------+
//|                                                       J2JMASign.mq5 | 
//|                                  Copyright © 2010, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+------------------------------------------------+ 
//| Параметры отрисовки медвежьего индикатора      |
//+------------------------------------------------+ 
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение медвежьей метки индикатора
#property indicator_label1  "J2JMA Sell"
//+------------------------------------------------+ 
//| Параметры отрисовки бычьего индикатора         |
//+------------------------------------------------+ 
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение бычьей метки индикатора
#property indicator_label2 "J2JMA Buy"
//+------------------------------------------------+ 
//| Объявление констант                            |
//+------------------------------------------------+ 
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+------------------------------------------------+ 
//| Объявление перечислений                        |
//+------------------------------------------------+ 
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
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------+ 
//| Входные параметры индикатора                   |
//+------------------------------------------------+ 
input double Length1 = 5; // Глубина  первого сглаживания
input double Length2 = 5; // Глубина  второго сглаживания
input double Phase1= 100; // Параметр первого сглаживания
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input double Phase2=100;  // Параметр второго сглаживания
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE_; // Ценовая константа
//+------------------------------------------------+ 
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double BuyBuffer[];
double SellBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_,min_rates_total;
//+------------------------------------------------------------------+
//| Описание класса CJJMA                                            |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+   
//| J2JMA indicator initialization function                          | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_=30;
   min_rates_total=min_rates_+31+3;
//---- инициализация переменных начала отсчета данных
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,min_rates_total));
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"J2JMA( Length1 = ",Length1,", Length2 = ",Length2,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- объявление переменной класса CJJMA из файла JJMASeries_Cls.mqh
   CJJMA JMA;
//---- установка алертов на недопустимые значения внешних переменных
   JMA.JJMALengthCheck("Length1", (int)Length1);
   JMA.JJMALengthCheck("Length2", (int)Length2);
//---- установка алертов на недопустимые значения внешних переменных
   JMA.JJMAPhaseCheck("Phase1", (int)Phase1);
   JMA.JJMAPhaseCheck("Phase2", (int)Phase2);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| J2JMA iteration function                                         | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double price,j1jma,j2jma,ATR[1];
   static double j2jma1,j2jma2;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- объявление переменных класса CJJMA из файла JJMASeries_Cls.mqh
   static CJJMA JMA1,JMA2;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- вызов функции PriceSeries для получения входной цены price_
      price=PriceSeries(IPC,bar,open,low,high,close);
      //---- два вызова функции JJMASeries
      //---- параметры Phase и Length не меняются на каждом баре (Din = 0)
      //---- во втором вызове параметр begin увеличен на 30, т.к. это повторное JMA сглаживание
      j1jma=JMA1.JJMASeries(0,prev_calculated,rates_total,0,Phase1,Length1,price,bar,false);
      j2jma=JMA2.JJMASeries(min_rates_,prev_calculated,rates_total,0,Phase2,Length2,j1jma,bar,false);
      //----
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //----
      if(j2jma2>=j2jma1 && j2jma1<j2jma)
        {
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //----
      if(j2jma2<=j2jma1 && j2jma1>j2jma)
        {
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //----
      if(bar<rates_total-1)
        {
         j2jma2=j2jma1;
         j2jma1=j2jma;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
