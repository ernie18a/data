//+------------------------------------------------------------------+
//|                                           XPeriodCandleRange.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2018, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+ 
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrBlue,clrDodgerBlue,clrGray,clrLightPink,clrMagenta
//---- отображение метки индикатора
#property indicator_label1  "XPeriodOpen;XPeriodHigh;XPeriodLow;XPeriodClose"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                    // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh>
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAO,XMAL,XMAH,XMAC;
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
input uint period=10;                      // Период расчёта свечей
input Smooth_Method MA_SMethod=MODE_JJMA;  // Метод усреднения
input int MA_Length=3;                     // глубина сглаживания                    
input int MA_Phase=100; //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в  дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//---
int min_rates_total,min_rates_1;
//---- объявление глобальных переменных
int Count[];
double iopen[],ihigh[],ilow[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_1=GetStartBars(MA_SMethod,MA_Length,MA_Phase);
   min_rates_total=min_rates_1+int(period)+1;
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,period);
   ArrayResize(iopen,period);
   ArrayResize(ihigh,period);
   ArrayResize(ilow,period);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="XPeriodCandleRange";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных    
   int bar,limit,maxbar=rates_total-2;
   double HH,LL,iclose;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=maxbar; // стартовый номер для расчёта всех баров
      ArrayInitialize(Count,0);
      ArrayInitialize(iopen,open[maxbar]);
      ArrayInitialize(ihigh,high[maxbar]);
      ArrayInitialize(ilow,low[maxbar]);
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      iopen[Count[0]]=XMAO.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,open[bar],bar,true);
      ihigh[Count[0]]=XMAH.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,high[bar],bar,true);
      ilow[Count[0]]=XMAL.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,low[bar],bar,true);
      iclose=XMAC.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,close[bar],bar,true);
      //----
      HH=ihigh[ArrayMaximum(ihigh,0,period)];
      LL=ilow[ArrayMinimum(ilow,0,period)];
      //---- 
      ExtOpenBuffer[bar]=iopen[Count[period-1]];
      ExtHighBuffer[bar]=HH;
      ExtLowBuffer[bar]=LL;
      ExtCloseBuffer[bar]=iclose;
      ExtColorsBuffer[bar]=1;
      //---- исправление неправильных свечей     
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);
      
      //---- итоговый пересчёт свечек для графика  
      ExtHighBuffer[bar]-=ExtOpenBuffer[bar];
      ExtLowBuffer[bar]-=ExtOpenBuffer[bar];
      ExtCloseBuffer[bar]-=ExtOpenBuffer[bar];
      ExtOpenBuffer[bar]=NULL;
      ExtHighBuffer[bar]/=_Point;
      ExtLowBuffer[bar]/=_Point;
      ExtCloseBuffer[bar]/=_Point;
      
      //---- окрашивание свечей
      ExtColorsBuffer[bar]=2;
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar])
        {
         if(ExtCloseBuffer[bar+1]<=ExtCloseBuffer[bar]) ExtColorsBuffer[bar]=0;
         else ExtColorsBuffer[bar]=1;
        }
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar])
        {
         if(ExtCloseBuffer[bar+1]>=ExtCloseBuffer[bar]) ExtColorsBuffer[bar]=4;
         else ExtColorsBuffer[bar]=3;
        }
      //---- пересчёт позиций баров в кольцевом буфере
      if(bar) Recount_ArrayZeroPos(Count,period);
     }
//---       
   return(rates_total);
  }
//+------------------------------------------------------------------+
