//+------------------------------------------------------------------+
//|                                     VTS_Float_Pivot_Smoothed.mq5 |
//|                                           Copyright © 2007, IZZY | 
//|                                                                  | 
//+------------------------------------------------------------------+  
//--- авторство индикатора
#property copyright "Copyright © 2007, IZZY"
//--- ссылка на сайт автора
#property link      ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано восемь буферов
#property indicator_buffers 8
//--- использовано всего восемь графических построений
#property indicator_plots   8
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора 1 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type1   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован Purple цвет
#property indicator_color1  clrPurple
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "VTS Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора 1     |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type2   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//--- толщина линии индикатора равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "VTS Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора 2 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type3   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован Purple цвет
#property indicator_color3  clrPurple
//--- толщина линии индикатора равна 2
#property indicator_width3  2
//--- отображение бычей метки индикатора
#property indicator_label3  "VTS Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора 2     |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type4   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color4  clrBlue
//--- толщина линии индикатора равна 2
#property indicator_width4  2
//--- отображение медвежьей метки индикатора
#property indicator_label4 "VTS Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора 3 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type5   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован Purple цвет
#property indicator_color5  clrPurple
//--- толщина линии индикатора равна 2
#property indicator_width5  2
//--- отображение бычей метки индикатора
#property indicator_label5  "VTS Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора 3     |
//+----------------------------------------------+
//--- отрисовка индикатора в виде линии 
#property indicator_type6   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color6  clrBlue
//--- толщина линии индикатора равна 2
#property indicator_width6  2
//--- отображение медвежьей метки индикатора
#property indicator_label6 "VTS Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора 4 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде символа
#property indicator_type7   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color7  clrMagenta
//--- толщина линии индикатора равна 2
#property indicator_width7  2
//--- отображение бычей метки индикатора
#property indicator_label7  "VTS Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора 4     |
//+----------------------------------------------+
//--- отрисовка индикатора в виде символа
#property indicator_type8   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован салатовый цвет
#property indicator_color8  clrMediumSpringGreen
//--- толщина линии индикатора равна 2
#property indicator_width8  2
//--- отображение медвежьей метки индикатора
#property indicator_label8 "VTS Buy"
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
CXMA XMAL,XMAH,XMAP;
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
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_,  //PRICE_TRENDFOLLOW0_2
   PRICE_DEMARK_         //Demark Price 
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int IPeriod=30;                              //Период поиска экстремумов
input ENUM_APPLIED_PRICE_ IPC=PRICE_MEDIAN_;       //ценовая константа
input Smooth_Method     HMA_Method=MODE_SMA_;      //Метод сглаживания
input uint              HLength=12;                //Глубина  сглаживания                    
input int               HPhase=100;                //Параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpIndBuffer1[],DnIndBuffer1[];
double UpIndBuffer2[],DnIndBuffer2[];
double UpIndBuffer3[],DnIndBuffer3[];
double UpIndBuffer4[],DnIndBuffer4[];
//---
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double XHigh[],XLow[];
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
//--- инициализация глобальных переменных 
   min_rates_total=GetStartBars(HMA_Method,HLength,HPhase)+1;
   min_rates_total+=int(MathMax(3,IPeriod));
   min_rates_total+=30;
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,IPeriod);
   ArrayResize(XHigh,IPeriod);
   ArrayResize(XLow,IPeriod);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Count,true);
   ArraySetAsSeries(XHigh,true);
   ArraySetAsSeries(XLow,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DnIndBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpIndBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnIndBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,UpIndBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DnIndBuffer3,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,UpIndBuffer3,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,DnIndBuffer4,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,UpIndBuffer4,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);


//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="VTS_Float_Pivot_Smoothed";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);

//--- объявления локальных переменных 
   int first,bar;
   double VTS,VTS1,VTS2,VTS3,VTS4,VTS5,VTS6,VTS7,VTS8,VTS9;
   double VTS10,VTS11,VTS12,VTS13,VTS14,VTS15,VTS16,VTS17,VTS18,VTS19;
   double VTS20,VTS21,VTS22,VTS23;

   static double VTS_prev,VTS1_prev,VTS2_prev,VTS3_prev,VTS4_prev,VTS5_prev,VTS6_prev,VTS7_prev,VTS8_prev,VTS9_prev;
   static double VTS10_prev,VTS11_prev,VTS12_prev,VTS13_prev,VTS14_prev,VTS15_prev,VTS16_prev,VTS17_prev,VTS18_prev,VTS19_prev;
   static double VTS20_prev,VTS21_prev,VTS22_prev,VTS23_prev;

//--- расчеты необходимого количества копируемых данных и стартового номера для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      ArrayInitialize(Count,NULL);
      ArrayInitialize(XHigh,NULL);
      ArrayInitialize(XLow,NULL);
      int start=min_rates_total-2;
      UpIndBuffer1[start]=UpIndBuffer2[start]=DnIndBuffer1[start]=DnIndBuffer2[start]=PriceSeries(IPC,start,open,low,high,close);
      double res=UpIndBuffer1[start];
      VTS_prev=res;
      VTS1_prev=res;
      VTS2_prev=res;
      VTS3_prev=res;
      VTS4_prev=res;
      VTS5_prev=res;
      VTS6_prev=res;
      VTS7_prev=res;
      VTS8_prev=res;
      VTS9_prev=res;
      VTS10_prev=res;
      VTS11_prev=res;
      VTS12_prev=res;
      VTS13_prev=res;
      VTS14_prev=res;
      VTS15_prev=res;
      VTS16_prev=res;
      VTS17_prev=res;
      VTS18_prev=res;
      VTS19_prev=res;
      VTS20_prev=res;
      VTS21_prev=res;
      VTS22_prev=res;
      VTS23_prev=res;
     }
   else first=prev_calculated-1;// стартовый номер для расчёта новых баров

//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Три вызова функции XMASeries.  
      double pivot=XMAP.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,PriceSeries(IPC,bar,open,low,high,close),bar,false);
      XHigh[Count[0]]=XMAH.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,high[bar],bar,false);
      XLow[Count[0]]=XMAL.XMASeries(0,prev_calculated,rates_total,HMA_Method,HPhase,HLength,low[bar],bar,false);      
      //----
      double max=XHigh[ArrayMaximum(XHigh,0,IPeriod)];
      double min=XLow[ArrayMinimum(XLow,0,IPeriod)];
      //---- Pivot
      double res=(max+min+pivot)/3;
      //---- (R1 - Pivot) / 2
      VTS1=((2*res-min)+res)/2;
      VTS=(res+(2*res-max))/2;
      //---- 
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,IPeriod);
      if(bar<min_rates_total-1) continue;
      //---  
      VTS2=MathMax(VTS,VTS_prev);
      VTS3=MathMin(VTS1,VTS1_prev);
      VTS4=MathMax(VTS2,VTS2_prev);
      VTS5=MathMin(VTS3,VTS3_prev);
      VTS6=MathMax(VTS4,VTS4_prev);
      VTS7=MathMin(VTS5,VTS5_prev);
      VTS8=MathMax(VTS6,VTS6_prev);
      VTS9=MathMin(VTS7,VTS7_prev);
      VTS10=MathMax(VTS8,VTS8_prev);
      VTS11=MathMin(VTS9,VTS9_prev);
      VTS12=MathMax(VTS10,VTS10_prev);
      VTS13=MathMin(VTS11,VTS11_prev);
      VTS14=MathMax(VTS12,VTS12_prev);
      VTS15=MathMin(VTS13,VTS13_prev);
      VTS16=MathMax(VTS14,VTS14_prev);
      VTS17=MathMin(VTS15,VTS15_prev);
      VTS18=MathMax(VTS16,VTS16_prev);
      VTS19=MathMin(VTS17,VTS17_prev);
      VTS20=MathMax(VTS18,VTS18_prev);
      VTS21=MathMin(VTS19,VTS19_prev);
      VTS22=MathMax(VTS20,VTS20_prev);
      VTS23=MathMin(VTS21,VTS21_prev);
      UpIndBuffer1[bar]=MathMax(VTS22,VTS22_prev);
      DnIndBuffer1[bar]=MathMin(VTS23,VTS23_prev);
      UpIndBuffer2[bar]=MathMax(UpIndBuffer1[bar],UpIndBuffer1[bar-1]);
      DnIndBuffer2[bar]=MathMin(DnIndBuffer1[bar],DnIndBuffer1[bar-1]);
      UpIndBuffer3[bar]=MathMax(UpIndBuffer2[bar],UpIndBuffer2[bar-1]);
      DnIndBuffer3[bar]=MathMin(DnIndBuffer2[bar],DnIndBuffer2[bar-1]);
      UpIndBuffer4[bar]=UpIndBuffer4[bar-1];
      DnIndBuffer4[bar]=DnIndBuffer4[bar-1];
      double price=PriceSeries(IPC,bar,open,low,high,close);
      if(price>DnIndBuffer3[bar])
        {
         UpIndBuffer4[bar]=UpIndBuffer3[bar];
         DnIndBuffer4[bar]=NULL;
        }
      if(price<UpIndBuffer3[bar])
        {
         DnIndBuffer4[bar]=DnIndBuffer3[bar];
         UpIndBuffer4[bar]=NULL;
        }

      if(bar<rates_total-1)
        {
         VTS_prev=VTS;
         VTS1_prev=VTS1;
         VTS2_prev=VTS2;
         VTS3_prev=VTS3;
         VTS4_prev=VTS4;
         VTS5_prev=VTS5;
         VTS6_prev=VTS6;
         VTS7_prev=VTS7;
         VTS8_prev=VTS8;
         VTS9_prev=VTS9;
         VTS10_prev=VTS10;
         VTS11_prev=VTS11;
         VTS12_prev=VTS12;
         VTS13_prev=VTS13;
         VTS14_prev=VTS14;
         VTS15_prev=VTS15;
         VTS16_prev=VTS16;
         VTS17_prev=VTS17;
         VTS18_prev=VTS18;
         VTS19_prev=VTS19;
         VTS20_prev=VTS20;
         VTS21_prev=VTS21;
         VTS22_prev=VTS22;
         VTS23_prev=VTS23;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
