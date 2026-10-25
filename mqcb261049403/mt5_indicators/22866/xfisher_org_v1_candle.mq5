//+---------------------------------------------------------------------+
//|                                           XFisher_org_v1_Candle.mq5 |
//|                              Copyright © 2006, TrendLaboratory Ltd. |
//|               http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                          E-mail: igorad2004@list.ru |
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
//---- авторство индикатора
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора Fisher_org_v1 |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrMagenta,clrGray,clrDodgerBlue
//---- отображение метки индикатора
#property indicator_label1  "XFisher_org_v1 Open;XFisher_org_v1 High;XFisher_org_v1 Low;XFisher_org_v1 Close"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 +1.5
#property indicator_level2  0.0
#property indicator_level3 -1.5
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA oXMA,hXMA,lXMA,cXMA;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA    // AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint FLength=14;                            // глубина усреднения
input Smooth_Method MA_SMethod=MODE_JJMA;         // Метод сглаживания
input uint MA_Length=5;                           // Глубина сглаживания                    
input int MA_Phase=15;                            // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей                  
input uint Gap=10;                                // размер неучитываемого гэпа в пунктах
input int Shift=0;                                // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=int(FLength)+1;
   min_rates_total=min_rates_1+GetStartBars(MA_SMethod,MA_Length,MA_Phase);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"XFisher_org_v1_Candle(",FLength,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,4);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int first,bar;
   double smax,smin,price,wpr,ovalue,hvalue,lvalue,cvalue,res1,res2,ofish,hfish,lfish,cfish,O,H,L,C;
   static double ovalue_prev,ofish_prev,hvalue_prev,hfish_prev,lvalue_prev,lfish_prev,cvalue_prev,cfish_prev;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=min_rates_1;                           // стартовый номер для расчета всех баров
      ovalue_prev=hvalue_prev=lvalue_prev=cvalue_prev=NULL;
      ofish_prev=hfish_prev=lfish_prev=cfish_prev=0.0;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      smax=DBL_MIN;
      smin=DBL_MAX;
      //----
      for(int iii=0; iii<int(FLength); iii++)
        {
         int barx=bar-iii;
         smax=MathMax(smax,high[barx]);
         smin=MathMin(smin,low[barx]);
        }
      if(smax==smin) smax+=_Point;
      //----
      price=open[bar];
      wpr=(price-smin)/(smax-smin);
      ovalue=(wpr-0.5)+0.67*ovalue_prev;
      ovalue=MathMin(ovalue,+DBL_MAX);
      ovalue=MathMax(ovalue,-DBL_MAX);
      res1=1.0-ovalue;
      if(!res1) res1=1.0;
      res2=(1.0+ovalue)/(1.0-ovalue);
      if(res2<0.0000001) res2=1.0;
      ofish=0.5*MathLog(res2)+0.5*ofish_prev;
      O=oXMA.XMASeries(min_rates_1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,ofish,bar,false);
      //----
      price=high[bar];
      wpr=(price-smin)/(smax-smin);
      hvalue=(wpr-0.5)+0.67*hvalue_prev;
      hvalue=MathMin(hvalue,+DBL_MAX);
      hvalue=MathMax(hvalue,-DBL_MAX);
      res1=1.0-hvalue;
      if(!res1) res1=1.0;
      res2=(1.0+hvalue)/(1.0-hvalue);
      if(res2<0.0000001) res2=1.0;
      hfish=0.5*MathLog(res2)+0.5*hfish_prev;
      H=hXMA.XMASeries(min_rates_1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,hfish,bar,false);
      //----
      price=low[bar];
      wpr=(price-smin)/(smax-smin);
      lvalue=(wpr-0.5)+0.67*lvalue_prev;
      lvalue=MathMin(lvalue,+DBL_MAX);
      lvalue=MathMax(lvalue,-DBL_MAX);
      res1=1.0-lvalue;
      if(!res1) res1=1.0;
      res2=(1.0+lvalue)/(1.0-lvalue);
      if(res2<0.0000001) res2=1.0;
      lfish=0.5*MathLog(res2)+0.5*lfish_prev;
      L=lXMA.XMASeries(min_rates_1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,lfish,bar,false);
      //----
      price=close[bar];
      wpr=(price-smin)/(smax-smin);
      cvalue=(wpr-0.5)+0.67*cvalue_prev;
      cvalue=MathMin(cvalue,+DBL_MAX);
      cvalue=MathMax(cvalue,-DBL_MAX);
      res1=1.0-cvalue;
      if(!res1) res1=1.0;
      res2=(1.0+cvalue)/(1.0-cvalue);
      if(res2<0.0000001) res2=1.0;
      cfish=0.5*MathLog(res2)+0.5*cfish_prev;
      C=cXMA.XMASeries(min_rates_1,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,cfish,bar,false);     
      //---- исправляем значения полученных свечек
      double Max=MathMax(O,C);
      Max=MathMax(Max,L);
      Max=MathMax(Max,H);
      double Min=MathMin(O,C);
      Min=MathMin(Min,L);
      Min=MathMin(Min,H);
      ExtOpenBuffer[bar]=O;
      ExtHighBuffer[bar]=Max;
      ExtLowBuffer[bar]=Min;
      ExtCloseBuffer[bar]=C;
      //---- удаляем несуществующие гепы
      if(MathAbs(open[bar]-close[bar])<=Gap) ExtOpenBuffer[bar]=ExtCloseBuffer[MathMax(bar-1,0)];
      //---- красим свечи
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
      
      if(bar<rates_total-1)
        {
         ovalue_prev=ovalue;
         ofish_prev=ofish;
         hvalue_prev=hvalue;
         hfish_prev=hfish;
         lvalue_prev=lvalue;
         lfish_prev=lfish;
         cvalue_prev=cvalue;
         cfish_prev=cfish;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
