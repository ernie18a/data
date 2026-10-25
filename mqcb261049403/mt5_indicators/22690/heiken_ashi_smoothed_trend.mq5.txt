//+---------------------------------------------------------------------+
//|                                      Heiken_Ashi_Smoothed_Trend.mq5 |
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Семафорный сигнальный индикатор, подающий торговые сигналы при изменении направления свечей Heiken Ashi Smoothed"
//---- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован аквамариновый цвет
#property indicator_color1  clrAqua
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычьей метки индикатора
#property indicator_label1  "Heiken_Ashi_Smoothed_Trend Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован розовый цвет
#property indicator_color2  clrDeepPink
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Heiken_Ashi_Smoothed_Trend Sell"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Описание классов усреднений                 |
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
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method HMA_Method=MODE_JJMA; //Метод усреднения
input int HLength=30; //Глубина  усреднения                    
input int HPhase=100; //Параметр усреднения, влияет на качество переходного процесса,
//---- для JJMA изменяющийся в пределах -100 ... +100;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint Gap=10;                                     //размер неучитываемого гэпа в пунктах
input uint BuySymb=174;                                //Символ покупки
input uint SellSymb=174;                               //Символ продажи
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//----
int min_rates_total,min_rates_1,ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных
   int ATR_Period=15;
   min_rates_1=ATR_Period;
   min_rates_total=min_rates_1+XMAO.GetStartBars(HMA_Method,HLength,HPhase)+1;
   
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- установка алертов на недопустимые значения внешних переменных
   XMAO.XMAPhaseCheck("HPhase",HPhase,HMA_Method);

//--- инициализация индикаторных буферов  
   IndInit(0,BuyBuffer,INDICATOR_DATA);
   IndInit(1,SellBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,NULL,min_rates_total,0,BuySymb);
   PlotInit(1,NULL,min_rates_total,0,SellSymb);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для субъокон 
   string short_name="Heiken Ashi Smoothed";
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

//---- объявления локальных переменных 
   int to_copy,first,trend;
   static int trend_prev;
   double ATR[],XmaOpen,XmaHigh,XmaLow,XmaClose,O,C;
   static double O_prev,C_prev;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=min_rates_1; // стартовый номер для расчета всех баров
      O_prev=open[first];
      C_prev=close[first];
      trend_prev=0;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
   to_copy=rates_total-first;
   
   //--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);

//---- Основной цикл расчета индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      trend=trend_prev;
      BuyBuffer[bar]=SellBuffer[bar]=NULL;
      //---- Четыре вызова функции XMASeries.  
      XmaOpen=XMAO.XMASeries(min_rates_1,prev_calculated,rates_total,HMA_Method,HPhase,HLength,open[bar],bar,false);
      XmaClose=XMAC.XMASeries(min_rates_1,prev_calculated,rates_total,HMA_Method,HPhase,HLength,close[bar],bar,false);
      XmaHigh=XMAH.XMASeries(min_rates_1,prev_calculated,rates_total,HMA_Method,HPhase,HLength,high[bar],bar,false);
      XmaLow=XMAL.XMASeries(min_rates_1,prev_calculated,rates_total,HMA_Method,HPhase,HLength,low[bar],bar,false);
      O=(O_prev+C_prev)/2;
      C=(XmaOpen+XmaHigh+XmaLow+XmaClose)/4;
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
