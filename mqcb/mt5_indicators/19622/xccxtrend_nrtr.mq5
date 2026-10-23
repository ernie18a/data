//+---------------------------------------------------------------------+
//|                                                  XCCXTrend_NRTR.mq5 |
//|                                           Ramdass - Conversion only |
//|                                                                     |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Ramdass - Conversion only"
//--- ссылка на сайт автора
#property link      ""
//--- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве окраски индикатора использован
#property indicator_color1 clrGreenYellow
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "NRTR Line Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2 DRAW_LINE
//---- в качестве окраски индикатора использован
#property indicator_color2 clrOrchid
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки сигнальной линии
#property indicator_label2  "NRTR Line Down"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type3 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color3 clrSeaGreen
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3 2
//---- отображение метки сигнальной линии
#property indicator_label3  "NRTR Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type4 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color4 clrMaroon
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4 2
//---- отображение метки сигнальной линии
#property indicator_label4  "NRTR Down"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован цвет синий
#property indicator_color5  clrBlue
//---- линия индикатора 5 - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора 5 равна 5
#property indicator_width5  5
//---- отображение бычьей метки индикатора
#property indicator_label5  "Buy XCCXTrend signal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован цвет розовый
#property indicator_color6  clrMagenta
//---- линия индикатора 6 - непрерывная кривая
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора 6 равна 5
#property indicator_width6  5
//---- отображение медвежьей метки индикатора
#property indicator_label6 "Sell XCCXTrend signal"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMAD,XMAH,XMAL;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - объявлено в файле SmoothAlgorithms.mqh
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
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint RISK=4;
input Smooth_Method DSmoothMethod=MODE_T3; //метод усреднения цены
input uint DPeriod=21;  //период мувинга
input int DPhase=10;   //параметр усреднения мувинга,
           // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
           // Для VIDIA это период CMO, для AMA это период медленной скользящей

input Smooth_Method MSmoothMethod=MODE_JJMA; //метод усреднения отклонения
input uint MPeriod=7; //период среднего отклонения
input int MPhase=15;   //среднего отклонения,
           // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
           // Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price IPC=PRICE_TYPICAL_; //ценовая константа
input double AtrRatio=0.375;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpBuffer1[],DnBuffer1[];
double UpBuffer2[],DnBuffer2[];
double SellBuffer[],BuyBuffer[];
//---
int Kx,ATR_Handle;
int min_rates_total,min_rates_D,min_rates_M;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   Kx=33-int(RISK);
   int ATR_Period=15;
   min_rates_D=XMAD.GetStartBars(DSmoothMethod,DPeriod,DPhase);
   min_rates_M=XMAD.GetStartBars(MSmoothMethod,MPeriod,MPhase);
   min_rates_total=min_rates_D+min_rates_M;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+1;
   
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer1,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer1,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer2,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer2,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,175);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(5,PLOT_ARROW,175);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="XCCXTrend_NRTR";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//--- объявления локальных переменных 
   int limit,to_copy,bar,trend,maxbar;
   double ATR[],range,stop;
   double price,xma,upccx,dnccx,xupccx,xdnccx,xccx;
   static int oldtrend;
   maxbar=rates_total-2;

//--- расчеты стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=maxbar; // стартовый номер для расчета всех баров
      oldtrend=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;

//--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Вызов функции PriceSeries для получения входной цены price
      price=PriceSeries(IPC,bar,open,low,high,close);

      //---- Один вызов функции XMASeries 
      xma=XMAD.XMASeries(maxbar,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,price,bar,true);      
      upccx=price-xma;
      dnccx=MathAbs(upccx);
      
      //---- Два вызова функции XMASeries  
      xupccx=XMAH.XMASeries(maxbar-min_rates_D,prev_calculated,rates_total,MSmoothMethod,MPhase,MPeriod,upccx,bar,true);
      xdnccx=XMAL.XMASeries(maxbar-min_rates_D,prev_calculated,rates_total,MSmoothMethod,MPhase,MPeriod,dnccx,bar,true);

      //---- инициализация индикаторного буфера
      if(xupccx) // запрет деления на ноль!
        xccx=100*xupccx/xdnccx;
      else xccx=EMPTY_VALUE; 
      //---
      xccx*=100;
      xccx+=100;
      xccx/=2;   
      BuyBuffer[bar]=SellBuffer[bar]=UpBuffer1[bar]=DnBuffer1[bar]=UpBuffer2[bar]=DnBuffer2[bar]=NULL;
      trend=oldtrend;
      if(xccx<Kx) trend=-1;
      if(xccx>100-Kx) trend=+1;
      range=AtrRatio*ATR[bar];
      //---
      if(oldtrend<0 && trend>0) BuyBuffer[bar]=low[bar]-range;
      if(oldtrend>0 && trend<0) SellBuffer[bar]=high[bar]+range;

      if(trend>0)
        {
         if(BuyBuffer[bar])
           {
            UpBuffer1[bar]=UpBuffer2[bar]=BuyBuffer[bar];
            DnBuffer1[bar]=DnBuffer1[bar+1];
           }
         else
           {
            stop=low[bar]-range;
            if(stop<UpBuffer1[bar+1]) stop=UpBuffer1[bar+1];
            UpBuffer1[bar]=UpBuffer2[bar]=stop;
           }
        }

      if(trend<0)
        {
         if(SellBuffer[bar])
           {
            DnBuffer1[bar]=DnBuffer2[bar]=SellBuffer[bar];
            UpBuffer1[bar]=UpBuffer1[bar+1];
           }
         else
           {
            stop=high[bar]+range;
            if(stop>DnBuffer1[bar+1]) stop=DnBuffer1[bar+1];
            DnBuffer1[bar]=DnBuffer2[bar]=stop;
           }
        }
      //---
      if(bar) oldtrend=trend;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
