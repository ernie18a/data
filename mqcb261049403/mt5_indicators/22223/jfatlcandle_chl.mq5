//+------------------------------------------------------------------+
//|                                              JFatlCandle_Chl.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Индикатор JFatl в свечном виде"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчета и отрисовки индикатора использовано девять буферов
#property indicator_buffers 9
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  C'223,255,232'
//--- отображение метки индикатора
#property indicator_label1  "Upper Signal Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color2  C'255,242,255'
//--- отображение метки индикатора
#property indicator_label2  "Lower Signal Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3   C'255,138,255',clrGray,C'117,186,255';
//---- отображение метки индикатора
#property indicator_label3  "JFatlCandle Open;JFatlCandle High;JFatlCandle Low;JFatlCandle Close"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAo,XMAh,XMAl,XMAc;
CStdDeviation STDh,STDl;
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint JLength=5;                                  // глубина JMA сглаживания                   
input int JPhase=100;                                  // параметр JMA сглаживания,
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input uint Gap=10;                                     // размер неучитываемого гэпа в пунктах
input uint BBLength=10;                                // период Боллинджера                                                   
input double BandsDeviation=1.0;                       // девиация

//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,FATLSize;
//+X----------------------------------------------X+ 
//| Инициализация коэффициентов цифрового фильтра  |
//+X----------------------------------------------X+ 
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_1=39+30;
   min_rates_total=min_rates_1+int(BBLength);
//---- инициализация переменных 
   FATLSize=ArraySize(dFATLTable);
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
   SetIndexBuffer(4,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(8,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- инициализация индикаторов
   PlotInit(2,NULL,min_rates_1,0);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для субъокон 
   string short_name="JFatlCandle_Chl";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
   if(rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double O,H,L,C,FATLO,FATLH,FATLL,FATLC,stdev;
//---- объявление целых переменных и получение уже посчитанных баров
   int first;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=FATLSize-1;                                  // стартовый номер для расчета всех баров
      ExtCloseBuffer[first-1]=close[first-1];
     }
   else first=prev_calculated-1;                         // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- считаем свечи
      FATLO=0.0;
      for(int index=0; index<FATLSize; index++) FATLO+=dFATLTable[index]*open[bar-index];
      O=XMAo.XMASeries(FATLSize-1,prev_calculated,rates_total,5,JPhase,JLength,FATLO,bar,false);
      FATLH=0.0;
      for(int index=0; index<FATLSize; index++) FATLH+=dFATLTable[index]*high[bar-index];
      H=XMAh.XMASeries(FATLSize-1,prev_calculated,rates_total,5,JPhase,JLength,FATLH,bar,false);
      FATLL=0.0;
      for(int index=0; index<FATLSize; index++) FATLL+=dFATLTable[index]*low[bar-index];
      L=XMAl.XMASeries(FATLSize-1,prev_calculated,rates_total,5,JPhase,JLength,FATLL,bar,false);
      FATLC=0.0;
      for(int index=0; index<FATLSize; index++) FATLC+=dFATLTable[index]*close[bar-index];
      C=XMAc.XMASeries(FATLSize-1,prev_calculated,rates_total,5,JPhase,JLength,FATLC,bar,false);
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
      if(MathAbs(open[bar]-close[bar])<=Gap) ExtOpenBuffer[bar]=ExtCloseBuffer[bar-1];
      //---- красим свечи
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
      //----           
      stdev=STDh.StdDevSeries(min_rates_1,prev_calculated,rates_total,BBLength,BandsDeviation,FATLH,ExtHighBuffer[bar],bar,false);
      UpUpBuffer[bar]=ExtHighBuffer[bar]+stdev;     
      UpDnBuffer[bar]=ExtHighBuffer[bar]; 
      DnUpBuffer[bar]=ExtLowBuffer[bar];
      stdev=STDl.StdDevSeries(min_rates_1,prev_calculated,rates_total,BBLength,BandsDeviation,FATLL,ExtLowBuffer[bar],bar,false);
      DnDnBuffer[bar]=ExtLowBuffer[bar]-stdev;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
