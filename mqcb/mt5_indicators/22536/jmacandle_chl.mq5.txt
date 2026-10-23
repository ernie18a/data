//+---------------------------------------------------------------------+
//|                                                   JMACandle_Chl.mq5 |
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Индикатор JMA в свечном виде с двумя, заполненными цветным фоном каналами, построенными на среднеквадратичных отклонениях от High и Low индикаторных свеч"
//---- номер версии индикатора
#property version   "1.01"
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
#property indicator_color1  C'170,255,227'
//--- отображение метки индикатора
#property indicator_label1  "Upper Signal Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color2  C'255,170,255'
//--- отображение метки индикатора
#property indicator_label2  "Lower Signal Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type3   DRAW_COLOR_CANDLES
#property indicator_color3   clrDeepPink,clrGray,clrDeepSkyBlue
//---- отображение метки индикатора
#property indicator_label3  "JMACandle Open;JMACandle High;JMACandle Low;JMACandle Close"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных классов CXMA и CStdDeviation из файла SmoothAlgorithms.mqh
CXMA XMAo,XMAh,XMAl,XMAc;
CStdDeviation STDh,STDl;
//+----------------------------------------------+
//|  объявление перечислений                     |
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
   MODE_AMA    //AMA
  }; */
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input Smooth_Method MA_Method1=MODE_JJMA;              //метод усреднения
input int Length1=12;                                  //глубина усреднения                    
input int Phase1=15;                                   //параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint Gap=10;                                     //размер неучитываемого гэпа в пунктах
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
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=GetStartBars(MA_Method1, Length1, Phase1);
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
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMAo.GetString_MA_Method(MA_Method1);
   StringConcatenate(shortname,"JMACandle_Chl(",Length1,", ",Smooth1,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
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

//---- Объявление переменных с плавающей точкой  
   double O,H,L,C,stdev;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first;
   
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
   
//---- основной цикл расчета индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- считаем свечи
      O=XMAo.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,open[bar],bar,false);
      //----     
      H=XMAh.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,high[bar],bar,false);
      //----
      L=XMAl.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,low[bar],bar,false);
      //----
      C=XMAc.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,close[bar],bar,false);
      //---- 
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
      //----           
      stdev=STDh.StdDevSeries(min_rates_1,prev_calculated,rates_total,BBLength,BandsDeviation,high[bar],ExtHighBuffer[bar],bar,false);
      UpUpBuffer[bar]=ExtHighBuffer[bar]+stdev;     
      UpDnBuffer[bar]=ExtHighBuffer[bar]; 
      DnUpBuffer[bar]=ExtLowBuffer[bar];
      stdev=STDl.StdDevSeries(min_rates_1,prev_calculated,rates_total,BBLength,BandsDeviation,low[bar],ExtLowBuffer[bar],bar,false);
      DnDnBuffer[bar]=ExtLowBuffer[bar]-stdev;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
