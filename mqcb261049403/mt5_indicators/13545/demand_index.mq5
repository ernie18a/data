//+------------------------------------------------------------------+
//|                                                 Demand_Index.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru"
#property description "Demand Index"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 1
//---- использовано два графических построения
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован серо-голубой цвет
#property indicator_color1  clrMediumSlateBlue
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Demand Index"
//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //тип константы
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
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//+-----------------------------------+
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
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения
input int XLength=12; // Глубина сглаживания
input int XPhase=15;  // Параметр сглаживания
                      // Для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса
                      // для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_QUARTER_; // Ценовая константа
/* , по которой производится расчет индикатора ( 1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Объем
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в
//---- дальнейшем использованы в качестве индикаторных буферов
double DIBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   StartBars=XMA1.GetStartBars(XMA_Method,XLength,XPhase)+1;
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength", XLength);
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
//---- инициализация сдвига по вертикали
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DIBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на StartBars
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Demand Index");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<StartBars) return(0);
//---- объявления локальных переменных 
   int first,bar,Sign;
   double AvgTR,Avg,VolAvg,price0,price1,WtCRatio=0.0,VolRatio;
   double Constant,DMI,TempDI,BuyPres,SellPres,BuyP,SellP;
   long Volume;
   static double VolAvg_,BuyPres_,SellPres_;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
      //----
      BuyPres_=1;
      SellPres_=1;
      //----
      if(VolumeType==VOLUME_TICK) VolAvg_=double(tick_volume[0]);
      else                        VolAvg_=double(volume[0]);
     }
//----
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- восстанавливаем значения переменных
   VolAvg=VolAvg_;
   BuyPres=BuyPres_;
   SellPres=SellPres_;
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         VolAvg_=VolAvg;
         BuyPres_=BuyPres;
         SellPres_=SellPres;
        }
      //---- вызов функции PriceSeries для получения входной цены price_
      price0=PriceSeries(IPC,bar,  open,low,high,close);
      price1=PriceSeries(IPC,bar-1,open,low,high,close);
      //----
      if(VolumeType==VOLUME_TICK) Volume=long(tick_volume[bar]);
      else                        Volume=long(volume[bar]);
      //----
      Avg=MathMax(high[bar],high[bar-1])-MathMin(low[bar],low[bar-1]);
      AvgTR=XMA1.XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,Avg,bar,false);
      VolAvg=((VolAvg *(XLength-1))+Volume)/XLength;
      //----
      if(price0!=0 && price1!=0 && AvgTR!=0 && VolAvg!=0)
         WtCRatio=(price0-price1)/MathMin(price0,price1);
      //----
      if(VolAvg!=0)VolRatio=Volume/VolAvg;
      else         VolRatio=1;
      //----
      Constant=((price0*3)/AvgTR)*MathAbs(WtCRatio);
      //----
      if(Constant>88) Constant=88;
      //----
      Constant=VolRatio/MathExp(Constant);
      //----
      if(WtCRatio>0)
        {
         BuyP=VolRatio;
         SellP=Constant;
        }
      else
        {
         BuyP=Constant;
         SellP=VolRatio;
        }
      //----
      BuyPres =((BuyPres *(XLength-1))+BuyP )/XLength;
      SellPres=((SellPres*(XLength-1))+SellP)/XLength;
      //----
      TempDI=+1;
      //----
      if(SellPres>BuyPres)
        {
         Sign=-1;
         if(SellPres!=0) TempDI=BuyPres/SellPres;
        }
      else
        {
         Sign=+1;
         if(BuyPres!=0) TempDI=SellPres/BuyPres;
        }
      //----
      TempDI*=Sign;
      //----
      if(TempDI < 0) DMI = -1 - TempDI;
      else           DMI = +1 - TempDI;
      //----
      DIBuffer[bar]=DMI*100.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
