//+---------------------------------------------------------------------+
//|                                          XRSXCandleKeltnerPluse.mq5 | 
//|                                  Copyright © 2017, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "XRSXCandle"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано семь буферов
#property indicator_buffers 7
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrMagenta,clrRed,clrGray,clrDeepSkyBlue,clrBlue
//--- отображение метки индикатора
#property indicator_label1  "XRSXCandle Open;XRSXCandle High;XRSXCandle Low;XRSXCandle Close"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора уровней      |
//+----------------------------------------------+
//---- отрисовка канала в виде облака
#property indicator_type2   DRAW_FILLING
//---- выбор цвета облака
#property indicator_color2  clrLavender
//---- отображение метки индикатора
#property indicator_label2  "Channels"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA OUPXRSX,ODNXRSX,OXSIGN;
CXMA HUPXRSX,HDNXRSX,HXSIGN;
CXMA LUPXRSX,LDNXRSX,LXSIGN;
CXMA CUPXRSX,CDNXRSX,CXSIGN;
CXMA XXMA;
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
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_COLOR_MODE //Тип константы
  {
   ENUM_LEVELS = 1,     //по уровням перекупленности/перепроданности
   ENUM__CHANELS         //по границам канала Келтнера
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method DSmoothMethod=MODE_JJMA; //метод усреднения цены
input int DPeriod=15;                        //период мувинга
input int DPhase=100;                        //параметр усреднения мувинга,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method SSmoothMethod=MODE_JurX; //метод сглаживания индикатора
input int SPeriod=7;                         //период сглаживания индикатора
input int SPhase=100;                        //параметр сглаживания индикатора,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint KeltnerPeriod=100;                //период усреднения Келтнера
input double Ratio=4.01;                     //девиация канала
input int Shift=0;                           //сдвиг канала по горизонтали в барах
input ENUM_COLOR_MODE Mode=ENUM_LEVELS;      //метод индикации пробоя
input int HighLevel=+50;
input int MiddleLevel=0;
input int LowLevel=-50;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double BorderTopBuffer[],BorderBotBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,min_rates_2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=GetStartBars(DSmoothMethod,DPeriod,DPhase)+1;
   min_rates_2=min_rates_1+GetStartBars(SSmoothMethod,SPeriod,SPhase);
   min_rates_total=min_rates_2+int(KeltnerPeriod);
//--- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(5,BorderTopBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,BorderBotBuffer,INDICATOR_DATA);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);

//---- осуществление сдвига начала отсчета отрисовки индикатора 
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- имя для окон данных и метка для субъокон 
   string short_name="XRSXCandleKeltner";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrBrown);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
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
   if(rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int first,bar;
   double MA,dprice,absdprice,up_xrsx,dn_xrsx,xrsx;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
     }
   else
     {
      first=prev_calculated-1; // стартовый номер для расчета новых баров
     }

//--- основной цикл расчёта индикатора, исправления и окрашивания свечей
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Расчёт для open
      dprice=open[bar]-open[bar-1];
      absdprice=MathAbs(dprice);
      up_xrsx=OUPXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,dprice,bar,false);
      dn_xrsx=ODNXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,absdprice,bar,false);

      //---- Предотвращение деления на ноль на пустых значениях
      if(!dn_xrsx) xrsx=EMPTY_VALUE;
      else
        {
         xrsx=up_xrsx/dn_xrsx;
         //---- Ограничение индикатора сверху и снизу 
         if(xrsx > +1)xrsx = +1;
         if(xrsx < -1)xrsx = -1;
        }
      ExtOpenBuffer[bar]=100*OXSIGN.XMASeries(min_rates_1,prev_calculated,rates_total,SSmoothMethod,SPhase,SPeriod,xrsx,bar,false);

      //---- Расчёт для close
      dprice=close[bar]-close[bar-1];
      absdprice=MathAbs(dprice);
      up_xrsx=CUPXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,dprice,bar,false);
      dn_xrsx=CDNXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,absdprice,bar,false);

      //---- Предотвращение деления на ноль на пустых значениях
      if(!dn_xrsx) xrsx=EMPTY_VALUE;
      else
        {
         xrsx=up_xrsx/dn_xrsx;
         //---- Ограничение индикатора сверху и снизу 
         if(xrsx > +1)xrsx = +1;
         if(xrsx < -1)xrsx = -1;
        }
      ExtCloseBuffer[bar]=100*CXSIGN.XMASeries(min_rates_1,prev_calculated,rates_total,SSmoothMethod,SPhase,SPeriod,xrsx,bar,false);

      //---- Расчёт для high
      dprice=high[bar]-high[bar-1];
      absdprice=MathAbs(dprice);
      up_xrsx=HUPXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,dprice,bar,false);
      dn_xrsx=HDNXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,absdprice,bar,false);

      //---- Предотвращение деления на ноль на пустых значениях
      if(!dn_xrsx) xrsx=EMPTY_VALUE;
      else
        {
         xrsx=up_xrsx/dn_xrsx;
         //---- Ограничение индикатора сверху и снизу 
         if(xrsx > +1)xrsx = +1;
         if(xrsx < -1)xrsx = -1;
        }
      ExtHighBuffer[bar]=100*HXSIGN.XMASeries(min_rates_1,prev_calculated,rates_total,SSmoothMethod,SPhase,SPeriod,xrsx,bar,false);

      //---- Расчёт для low
      dprice=low[bar]-low[bar-1];
      absdprice=MathAbs(dprice);
      up_xrsx=LUPXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,dprice,bar,false);
      dn_xrsx=LDNXRSX.XMASeries(1,prev_calculated,rates_total,DSmoothMethod,DPhase,DPeriod,absdprice,bar,false);

      //---- Предотвращение деления на ноль на пустых значениях
      if(!dn_xrsx) xrsx=EMPTY_VALUE;
      else
        {
         xrsx=up_xrsx/dn_xrsx;
         //---- Ограничение индикатора сверху и снизу 
         if(xrsx > +1)xrsx = +1;
         if(xrsx < -1)xrsx = -1;
        }
      ExtLowBuffer[bar]=100*LXSIGN.XMASeries(min_rates_1,prev_calculated,rates_total,SSmoothMethod,SPhase,SPeriod,xrsx,bar,false);

      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      //---
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);
      //---
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=3.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=1.0;
      else ExtColorBuffer[bar]=2.0;
     }

//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      first=min_rates_2; // стартовый номер для расчета всех баров
     }
//--- основной цикл расчёта канала
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      MA=XXMA.XMASeries(min_rates_2,prev_calculated,rates_total,MODE_SMA_,0,KeltnerPeriod,ExtCloseBuffer[bar],bar,false);
      if(bar<min_rates_total) continue;
      double Keltner=Ratio*GetKeltner(KeltnerPeriod,bar,ExtHighBuffer,ExtLowBuffer);
      BorderTopBuffer[bar]=MA+Keltner;
      BorderBotBuffer[bar]=MA-Keltner;
     }
//--- основной цикл расчёта индикации пробоя
   if(Mode==ENUM_LEVELS)
     {
      for(bar=first; bar<rates_total && !IsStopped(); bar++)
        {
         if(ExtCloseBuffer[bar]>HighLevel) ExtColorBuffer[bar]=4.0;
         else if(ExtCloseBuffer[bar]<LowLevel) ExtColorBuffer[bar]=0.0;
        }
     }
   else
     {
      for(bar=first; bar<rates_total && !IsStopped(); bar++)
        {
         if(ExtCloseBuffer[bar]>BorderTopBuffer[bar]) ExtColorBuffer[bar]=4.0;
         else if(ExtCloseBuffer[bar]<BorderBotBuffer[bar]) ExtColorBuffer[bar]=0.0;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
// вычисление половины ширины канала Келтнера                        |
//+------------------------------------------------------------------+ 
double GetKeltner(int period,int bar,const double &High[],const double &Low[])
  {
//----
   double Resalt,sum=0;
   for(int iii=0; iii<period; iii++)
      sum+=High[bar-iii] - Low[bar-iii];
   Resalt = sum / period;
   return(Resalt);
//----
  }
//+------------------------------------------------------------------+
