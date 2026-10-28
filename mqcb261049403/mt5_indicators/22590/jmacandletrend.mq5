//+---------------------------------------------------------------------+
//|                                                  JMACandleTrend.mq5 |
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Семафорный сигнальный индикатор, подающий торговые сигналы при изменении направления свечей JMACandle"
//---- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован голубой цвет
#property indicator_color1  clrDodgerBlue
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычьей метки индикатора
#property indicator_label1  "JMACandleTrend Buy"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован розовый цвет
#property indicator_color2  clrMagenta
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "JMACandleTrend Sell"
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
CXMA XMAo,XMAc;
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
input int Length1=30;                                  //глубина усреднения                    
input int Phase1=15;                                   //параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint Gap=10;                                     //размер неучитываемого гэпа в пунктах
input uint BuySymb=171;                                //Символ покупки
input uint SellSymb=171;                               //Символ продажи
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(MA_Method1, Length1, Phase1);
   int ATR_Period=15;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+1;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//--- инициализация индикаторных буферов  
   IndInit(0,BuyBuffer,INDICATOR_DATA);
   IndInit(1,SellBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,NULL,min_rates_total,0,BuySymb);
   PlotInit(1,NULL,min_rates_total,0,SellSymb);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMAo.GetString_MA_Method(MA_Method1);
   StringConcatenate(shortname,"JMACandleTrend(",Length1,", ",Smooth1,")");
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
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift,uint ArrSymb)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- выбор символа для отрисовки
   PlotIndexSetInteger(Number,PLOT_ARROW,ArrSymb);
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double O,C,ATR[];
   static double C_prev;
//---- Объявление целых переменных и получение уже посчитанных баров
   int to_copy,first,trend;
   static int trend_prev;
   
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      {
       first=0; // стартовый номер для расчёта всех баров
       C_prev=close[first];
       trend_prev=0;
      }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
   to_copy=rates_total-first;
   
//--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   
//---- основной цикл расчета индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      trend=trend_prev;
      BuyBuffer[bar]=SellBuffer[bar]=NULL;
      //---- считаем свечи
      O=XMAo.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,open[bar],bar,false);
      C=XMAc.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,close[bar],bar,false);
      //---- удаляем несуществующие гепы
      if(MathAbs(open[bar]-close[bar])<=Gap) O=C_prev;
      //----
      if(O<C) trend=+1;
      else if(O>C)  trend=-1;      
      if(trend_prev<=0 && trend>0) BuyBuffer[bar]=low[bar]-ATR[rates_total-bar-1]*3/8;
      if(trend_prev>=0 && trend<0) SellBuffer[bar]=high[bar]+ATR[rates_total-bar-1]*3/8;
      if(bar<rates_total-1)
        {
         C_prev=C;
         trend_prev=trend;
        }   
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
