//+------------------------------------------------------------------+
//|                                                      ATRNorm.mq5 |
//|                                  Copyright © 2012, Ivan Kornilov |
//|                                  excelf@gmail.com, skype: excelf |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2012, Ivan Kornilov"
//--- авторство индикатора
#property link      "excelf@gmail.com"
//--- номер версии индикатора
#property version   "1.01"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора ATRNorm       |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован красный цвет
#property indicator_color1  clrRed
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "ATRNorm"
//+----------------------------------------------+
//| Параметры отрисовки индикатора LeadATRNorm   |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2  "LeadATRNorm"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.25
#property indicator_level1 0.50
#property indicator_level1 0.75
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Параметры окна индикатора                    |
//+----------------------------------------------+
//#property indicator_minimum -1
//#property indicator_maximum 1
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
enum IndType
  {
   ATR=0,           // ATR
   Volume_,         // Volume
   TrueRange,       // TrueRange
   TrueRangeVolume, // TrueRange Volume
   Log,             // Log
   stdDev           // stdDev
  };
//+----------------------------------------------+
//| объявление перечислений                      |
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
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint period=12;                              // Период индикатора
input uint ma=12;                                  // Период сглаживания
input IndType ValueType=ATR;                       // Тип нормируемого индикатора
input uint normLimit=24;                           // Период нормирования
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Объем
input int Shift=0;                                 // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double AtrBuffer[];
double FlatBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве кольцевых буферов
int Count[];
double SMABuffer[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//---
   int numb,Max1,Max2;
   static int count=1;
//---
   Max2=Size;
   Max1=Max2-1;
//---
   count--;
   if(count<0) count=Max1;
//---
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(period+ma+1,normLimit));
//--- получение хендла индикатора iBearsPower
   if(ValueType==ATR)
     {
      Handle=iATR(NULL,0,int(period));
      if(Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора!");
     }
//---
   if(ValueType==stdDev)
     {
      Handle=iStdDev(NULL,0,int(period),0,MODE_SMA,PRICE_CLOSE);
      if(Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора!");
     }
//--- распределение памяти под массивы переменных  
   ArrayResize(Count,normLimit);
   ArrayResize(SMABuffer,normLimit);
   ArrayInitialize(Count,0.0);
   ArrayInitialize(SMABuffer,0.0);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,AtrBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,FlatBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ATRNorm(",period,",",ma,",",normLimit," ",EnumToString(ValueType),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(ValueType==ATR || ValueType==stdDev)if(BarsCalculated(Handle)<rates_total) return(RESET);
//--- объявления локальных переменных 
   int first,bar;
   double val;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=1;                   // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      val=getValue(ValueType,rates_total-1,high,low,close,tick_volume,volume,bar);
      //---
      if(ValueType!=ATR || ValueType!=stdDev)
         SMABuffer[Count[0]]=XMA1.XMASeries(period+1,prev_calculated,rates_total,MODE_SMA_,0,period,val,bar,false);
      else SMABuffer[Count[0]]=val;
      //---
      AtrBuffer[bar]=normValue(SMABuffer,normLimit,Count[0]);
      if(AtrBuffer[bar]==EMPTY_VALUE) return(RESET);
      //---
      FlatBuffer[bar]=XMA2.XMASeries(period+1+period+normLimit,prev_calculated,rates_total,MODE_SMA_,0,ma,AtrBuffer[bar],bar,false);
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,normLimit);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+    
//| normValue()                                                      | 
//+------------------------------------------------------------------+
double normValue(double &buffer[],int count,int i)
  {
//---
   double max = buffer[ArrayMaximum(buffer,0,WHOLE_ARRAY)];
   double min = buffer[ArrayMinimum(buffer,0,WHOLE_ARRAY)];
   double value;
//---
   if(max-min == 0) value = 1;
   else value =(buffer[i] - min) /(max - min);
//---
   if(value>1) value=1;
   else if(value<0) value=0;
//---
   return(value);
  }
//+------------------------------------------------------------------+    
//| getValue                                                         | 
//+------------------------------------------------------------------+
double getValue(IndType valueType,int MaxBar,const double &High[],const double &Low[],
                const double &Close[],const long &TcVolume[],const long &Volume[],int shift)
  {
//---
   double Arr[1],value=0;
//---
   switch(valueType)
     {
      case ATR:
         //--- копируем вновь появившиеся данные в массив  
         if(CopyBuffer(Handle,0,MaxBar-shift,1,Arr)<=0) return(EMPTY_VALUE);
         return(Arr[0]);
         //---
      case Volume_:
        {
         long vol;
         if(VolumeType==VOLUME_TICK) vol=TcVolume[shift];
         else                        vol=Volume[shift];
         return(double(vol));
        }
      //---
      case TrueRange:
         if(shift==1) value=High[shift]-Low[shift];
         else value=MathMax(High[shift],High[shift-1])-MathMin(Low[shift],Low[shift-1]);
         return(value);
         //---
      case TrueRangeVolume:
        {
         if(shift==1) value=High[shift]-Low[shift];
         else value=MathMax(High[shift],Close[shift-1])-MathMin(Low[shift],Close[shift-1]);
         long vol;
         if(VolumeType==VOLUME_TICK) vol=TcVolume[shift];
         else                        vol=Volume[shift];
         return(value/_Point*vol);
        }
      //---
      case Log:
         if(Close[shift-1]==0) value=0;
         else value=MathLog(MathMax(Close[shift-1],Close[shift])/MathMin(Close[shift-1],Close[shift]));
         return(value);
         //---
      case stdDev:
         //--- копируем вновь появившиеся данные в массив  
         if(CopyBuffer(Handle,0,MaxBar-shift,1,Arr)<=0) return(EMPTY_VALUE);
         return(Arr[0]);
      default: return(0);
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
