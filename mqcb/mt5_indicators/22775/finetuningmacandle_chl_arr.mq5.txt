//+------------------------------------------------------------------+
//|                                   FineTuningMACandle_Chl_Arr.mq5 | 
//|                                         Copyright © 2018, gumgum |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, gumgum"
#property link      ""
//---- номер версии индикатора
#property version   "1.00"
//---- описание индикатора
#property description "Свечной график на более тонком усреднении таймсерий"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  C'170,255,227'
//--- отображение метки индикатора
#property indicator_label1  "Upper Signal Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color2  C'255,255,187'
//--- отображение метки индикатора
#property indicator_label2  "Lower Signal Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные значки
#property indicator_type3   DRAW_COLOR_ARROW
#property indicator_color3   clrDeepPink,clrGray,clrCornflowerBlue
//---- толщина индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "FineTuningMACandle Signal"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CStdDeviation из файла SmoothAlgorithms.mqh
CStdDeviation STDh,STDl;
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint   FTMA=10;
input double rank1=2;
input double rank2=2;
input double rank3=2;
input double Shift1=1;
input double Shift2=1;
input double Shift3=1;
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
input uint Gap=10;                                     //размер неучитываемого гэпа в пунктах
input uint BBLength=10;                                // период Боллинджера                                                   
input double BandsDeviation=1.0;                       // девиация
input uint ArraySymb=108;                              // Символ для сигнальных значков
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[];
double ExtBuffer[],ExtColorBuffer[];
//----
double PM[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| FineTuningMA indicator initialization function                   | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- распределение памяти под массивы переменных  
   ArrayResize(PM,FTMA);

//---- Инициализация переменных
   double sum=0;
   for(int h=0; h<int(FTMA); h++)
     {
      PM[h]=Shift1+MathPow(h/(FTMA-1.0),rank1)*(1.0-Shift1);
      PM[h]=(Shift2+MathPow(1-(h/(FTMA-1.0)),rank2)*(1.0-Shift2))*PM[h];

      if((h/(FTMA-1.))<0.5) PM[h]=(Shift3+MathPow((1-(h/(FTMA-1.0))*2.0),rank3)*(1.0-Shift3))*PM[h];
      else PM[h]=(Shift3+MathPow((h/(FTMA-1.0))*2.0-1.0,rank3)*(1.0-Shift3))*PM[h];

      sum+=PM[h];
     }

   double sum1=0;
   for(int h=0; h<int(FTMA); h++)
     {
      PM[h]=PM[h]/sum;
      sum1+=PM[h];
     }

//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(FTMA)+1;
   min_rates_total=min_rates_1+int(BBLength);
//--- инициализация индикаторных буферов  
   IndInit(0,UpUpBuffer,INDICATOR_DATA);
   IndInit(1,UpDnBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,NULL,min_rates_total,0);
//--- инициализация индикаторных буферов  
   IndInit(2,DnUpBuffer,INDICATOR_DATA);
   IndInit(3,DnDnBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(1,NULL,min_rates_total,0);
//---- превращение динамических массивов в индикаторные буферы
   IndInit(4,ExtBuffer,INDICATOR_DATA);
   IndInit(5,ExtColorBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(2,NULL,min_rates_total,0);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,ArraySymb);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"FineTuningMACandle_Chl_Arr("+string(FTMA)+")");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//---
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---
  }
//+------------------------------------------------------------------+ 
//| FineTuningMA iteration function                                  | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;
   double O,H,L,C,stdev;
   static double ExtClose_prev;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=min_rates_1; // стартовый номер для расчёта всех баров
      ExtClose_prev=close[first-1];
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      O=NULL;
      for(int index=0; index<int(FTMA); index++) O+=PM[index]*open[bar-index];
      H=NULL;
      for(int index=0; index<int(FTMA); index++) H+=PM[index]*high[bar-index];
      L=NULL;
      for(int index=0; index<int(FTMA); index++) L+=PM[index]*low[bar-index];
      C=NULL;
      for(int index=0; index<int(FTMA); index++) C+=PM[index]*close[bar-index];

      //---- исправляем значения полученных свечек
      double Max=MathMax(O,C);
      Max=MathMax(Max,L);
      Max=MathMax(Max,H);
      double Min=MathMin(O,C);
      Min=MathMin(Min,L);
      Min=MathMin(Min,H);
      double ExtOpen=O;
      double ExtHigh=Max;
      double ExtLow=Min;
      double ExtClose=C;
      //---- удаляем несуществующие гепы
      if(MathAbs(open[bar]-close[bar])<=Gap) ExtOpen=ExtClose_prev;
      //---- красим свечи
      if(ExtOpen<ExtClose) ExtColorBuffer[bar]=2.0;
      else if(ExtOpen>ExtClose) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
      //---- сдвигаем свечи по вертикали
      ExtOpen+=dPriceShift;
      ExtHigh+=dPriceShift;
      ExtLow+=dPriceShift;
      ExtClose+=dPriceShift;
      ExtBuffer[bar]=(ExtHigh+ExtLow)/2.0;
      //----
      stdev=STDh.StdDevSeries(min_rates_1,prev_calculated,rates_total,BBLength,BandsDeviation,high[bar],ExtHigh,bar,false);
      UpUpBuffer[bar]=ExtHigh+stdev;
      UpDnBuffer[bar]=ExtHigh;
      DnUpBuffer[bar]=ExtLow;
      stdev=STDl.StdDevSeries(min_rates_1,prev_calculated,rates_total,BBLength,BandsDeviation,low[bar],ExtLow,bar,false);
      DnDnBuffer[bar]=ExtLow-stdev;
      if(bar<rates_total-1) ExtClose_prev=ExtClose;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
