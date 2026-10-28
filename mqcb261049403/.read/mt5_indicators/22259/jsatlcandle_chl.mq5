//+------------------------------------------------------------------+
//|                                              JSatlCandle_Chl.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Индикатор JSatl в свечном виде"
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
#property indicator_color3   C'255,208,121',clrGray,C'106,255,255'
//---- отображение метки индикатора
#property indicator_label3  "JSatlCandle Open;JSatlCandle High;JSatlCandle Low;JSatlCandle Close"
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
input uint BBLength=20;                                // период Боллинджера                                                   
input double BandsDeviation=3.0;                       // девиация
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,SATLSize;
//+X----------------------------------------------X+ 
//| Инициализация коэффициентов цифрового фильтра  |
//+X----------------------------------------------X+ 
double dSATLTable[]=
  {
   -0.00514293,-0.00398417,-0.00262594,-0.00107121,+0.00066887,+0.00258172,+0.00465269,
   +0.00686394,+0.00919334,+0.01161720,+0.01411056,+0.01664635,+0.01919533,+0.02172747,
   +0.02421320,+0.02662203,+0.02892446,+0.03109071,+0.03309496,+0.03490921,+0.03651145,
   +0.03788045,+0.03899804,+0.03984915,+0.04042329,+0.04071263,+0.04071263,+0.04042329,
   +0.03984915,+0.03899804,+0.03788045,+0.03651145,+0.03490921,+0.03309496,+0.03109071,
   +0.02892446,+0.02662203,+0.02421320,+0.02172747,+0.01919533,+0.01664635,+0.01411056,
   +0.01161720,+0.00919334,+0.00686394,+0.00465269,+0.00258172,+0.00066887,-0.00107121,
   -0.00262594,-0.00398417,-0.00514293,-0.00609634,-0.00684602,-0.00739452,-0.00774847,
   -0.00791630,-0.00790940,-0.00774085,-0.00742482,-0.00697718,-0.00641613,-0.00576108,
   -0.00502957,-0.00423873,-0.00340812,-0.00255923,-0.00170217,-0.00085902,-0.00004113,
   +0.00073700,+0.00146422,+0.00213007,+0.00272649,+0.00324752,+0.00368922,+0.00405000,
   +0.00433024,+0.00453068,+0.00465046,+0.00469058,+0.00466041,+0.00457855,+0.00442491,
   +0.00423019,+0.00399201,+0.00372169,+0.00342736,+0.00311822,+0.00280309,+0.00249088,
   +0.00219089,+0.00191283,+0.00166683,+0.00146419,+0.00131867,+0.00124645,+0.00126836,
   -0.00401854
  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация переменных 
   SATLSize=ArraySize(dSATLTable);
//---- инициализация глобальных переменных 
   min_rates_1=SATLSize+30;
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
//---- имя для окон данных и метка для субъокон 
   string short_name="JSatlCandle_Chl";
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
   double O,H,L,C,SATLO,SATLH,SATLL,SATLC,stdev;
//---- объявление целых переменных и получение уже посчитанных баров
   int first;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=SATLSize-1;                                  // стартовый номер для расчета всех баров
      ExtCloseBuffer[first-1]=close[first-1];
     }
   else first=prev_calculated-1;                         // стартовый номер для расчета новых баров

//---- основной цикл расчета индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- считаем свечи
      SATLO=0.0;
      for(int index=0; index<SATLSize; index++) SATLO+=dSATLTable[index]*open[bar-index];
      O=XMAo.XMASeries(SATLSize-1,prev_calculated,rates_total,5,JPhase,JLength,SATLO,bar,false);
      SATLH=0.0;
      for(int index=0; index<SATLSize; index++) SATLH+=dSATLTable[index]*high[bar-index];
      H=XMAh.XMASeries(SATLSize-1,prev_calculated,rates_total,5,JPhase,JLength,SATLH,bar,false);
      SATLL=0.0;
      for(int index=0; index<SATLSize; index++) SATLL+=dSATLTable[index]*low[bar-index];
      L=XMAl.XMASeries(SATLSize-1,prev_calculated,rates_total,5,JPhase,JLength,SATLL,bar,false);
      SATLC=0.0;
      for(int index=0; index<SATLSize; index++) SATLC+=dSATLTable[index]*close[bar-index];
      C=XMAc.XMASeries(SATLSize-1,prev_calculated,rates_total,5,JPhase,JLength,SATLC,bar,false);
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
      stdev=STDh.StdDevSeries(min_rates_1,prev_calculated,rates_total,BBLength,BandsDeviation,SATLH,ExtHighBuffer[bar],bar,false);
      UpUpBuffer[bar]=ExtHighBuffer[bar]+stdev;
      UpDnBuffer[bar]=ExtHighBuffer[bar];
      DnUpBuffer[bar]=ExtLowBuffer[bar];
      stdev=STDl.StdDevSeries(min_rates_1,prev_calculated,rates_total,BBLength,BandsDeviation,SATLL,ExtLowBuffer[bar],bar,false);
      DnDnBuffer[bar]=ExtLowBuffer[bar]-stdev;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
