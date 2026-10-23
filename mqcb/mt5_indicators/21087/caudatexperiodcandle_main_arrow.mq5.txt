//+------------------------------------------------------------------+
//|                              CaudateXPeriodCandle_main_Arrow.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2018, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+ 
//---- отрисовка индикатора в виде цветного значка
#property indicator_type1 DRAW_COLOR_ARROW
//---- в качестве окраски индикатора использованы
#property indicator_color1  clrDodgerBlue,clrBlue,clrPaleTurquoise,clrGray,clrLightPink,clrMaroon,clrMagenta
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1 4
//---- отображение метки индикатора
#property indicator_label1  "CaudateXPeriodCandle_main_Arrow"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                    // Константа для возврата терминалу команды на пересчет индикатора
#define TYPE_NO_TAIL     0                         // Свеча без хвоста
#define TYPE_HIGHER_TAIL 1                         // Свеча с верхним хвостом         
#define TYPE_LOWER_TAIL  2                         // Свеча с нижним хвостом
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
//|  объявление перечислений                     |
//+----------------------------------------------+
enum MOD_EXTREM
  {
   MODE_REAL,       // по экстремумам реальных свечей 
   MODE_SYNTHETIC   // по экстремумам синтетических свечей 
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input MOD_EXTREM SignalPoint=MODE_REAL;    // расположение сигнальных точек
input uint period=5;                       // Период расчёта свечей
input Smooth_Method MA_SMethod=MODE_JJMA;  // Метод усреднения
input int MA_Length=3;                     // глубина сглаживания                    
input int MA_Phase=100; //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в  дальнейшем использованы в качестве индикаторных буферов
double ExtBuffer[],ExtColorsBuffer[];
//---
int min_rates_total,min_rates_1;
//---- объявление глобальных переменных
int Count[];
double iopen[],ihigh[],ilow[];
//+------------------------------------------------------------------+
//| Определение типа свечи                                           |
//+------------------------------------------------------------------+
int GetCandleType(double Open,double High,double Low,double Close)
  {
//----
   double candleHalf=(High+Low)/2;            // Середина высоты свечи

   if(Open<candleHalf && Close<candleHalf)    // Тело свечи находится в нижней половине свечи                        
      return(TYPE_HIGHER_TAIL);               // Верхний хвост

   if(Open>candleHalf && Close>candleHalf)    // Тело свечи находится в верхней половине свечи                        
      return(TYPE_LOWER_TAIL);                // Нижний хвост
//----   
   return(TYPE_NO_TAIL);                      // У свечи нет хвоста
  }
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
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="CaudateXPeriodCandle_main_Arrow";
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
   int bar,limit,maxbar=rates_total-1;
   double HH,LL,ExtOpen,ExtHigh,ExtLow,ExtClose;

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
      ExtClose=XMAC.XMASeries(maxbar,prev_calculated,rates_total,MA_SMethod,MA_Phase,MA_Length,close[bar],bar,true);
      //----
      HH=ihigh[ArrayMaximum(ihigh,0,period)];
      LL=ilow[ArrayMinimum(ilow,0,period)];
      //---- 
      ExtOpen=iopen[Count[period-1]];
      ExtHigh=HH;
      ExtLow=LL;      
      ExtColorsBuffer[bar]=1;
      //---- исправление неправильных свечей     
      double Max=MathMax(ExtOpen,ExtClose);
      double Min=MathMin(ExtOpen,ExtClose);
      ExtHigh=MathMax(Max,ExtHigh);
      ExtLow=MathMin(Min,ExtLow);
      //---- окрашивание свечей
      if(ExtOpen<=ExtClose) ExtColorsBuffer[bar]=2;
      else ExtColorsBuffer[bar]=4;
      //---- определение хвостатых свечей
      switch(GetCandleType(ExtOpen,ExtHigh,ExtLow,ExtClose)) // Получение типа свечи
        {
         case TYPE_NO_TAIL: // Свеча без хвоста не интересует
            ExtBuffer[bar]=NULL;
            break;

         case TYPE_LOWER_TAIL: // Свеча с нижним хвостом
            if(ExtOpen<=ExtClose) ExtColorsBuffer[bar]=0;
            else ExtColorsBuffer[bar]=1;
            if(SignalPoint==MODE_SYNTHETIC) ExtBuffer[bar]=ExtLow;
            else ExtBuffer[bar]=low[bar];
            break;

         case TYPE_HIGHER_TAIL: // Свеча с верхним хвостом
            if(ExtOpen>=ExtClose) ExtColorsBuffer[bar]=6;
            else ExtColorsBuffer[bar]=5;
            if(SignalPoint==MODE_SYNTHETIC) ExtBuffer[bar]=ExtHigh;
            else ExtBuffer[bar]=high[bar];
            break;
        }      
      //---- пересчёт баров в кольцевом буфере
      if(bar) Recount_ArrayZeroPos(Count,period);
     }
//---       
   return(rates_total);
  }
//+------------------------------------------------------------------+
