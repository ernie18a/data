//+---------------------------------------------------------------------+
//|                                            i-KlPrice_Vol_Direct.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property description "i-KlPrice_Direct"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 8
#property indicator_buffers 8 
//---- использовано шесть графических построений
#property indicator_plots   6
//+-----------------------------------------+
//|  объявление констант                    |
//+-----------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------------+
//|  Параметры отрисовки максимума          |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован Teal цвет
#property indicator_color1 clrTeal
//---- линия индикатора - штрих-пунктир
#property indicator_style1  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "i-KlPrice_Vol Max"
//+-----------------------------------------+
//|  Параметры отрисовки уровня Res         |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован SeaGreen цвет
#property indicator_color2 clrSeaGreen
//---- линия индикатора - штрих-пунктир
#property indicator_style2  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "i-KlPrice_Vol Res"
//+-----------------------------------------+
//| Параметры отрисовки индикатора RSI      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type3   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов индикатора использованы
#property indicator_color3  clrRed,clrMaroon,clrGray,clrBlue,clrDeepSkyBlue
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3 2
//---- отображение метки индикатора
#property indicator_label3  "i-KlPrice_Vol"
//+-----------------------------------------+
//|  Параметры отрисовки уровня Supr        |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован MediumOrchid цвет
#property indicator_color4 clrMediumOrchid
//---- линия индикатора - штрих-пунктир
#property indicator_style4  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "i-KlPrice_Vol Supr"
//+-----------------------------------------+
//|  Параметры отрисовки минимума           |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован Purple цвет
#property indicator_color5 clrPurple
//---- линия индикатора - штрих-пунктир
#property indicator_style5  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width5  1
//---- отображение метки индикатора
#property indicator_label5  "i-KlPrice_Vol Min"
//+-----------------------------------------+
//|  Параметры отрисовки значков            |
//+-----------------------------------------+
//---- отрисовка индикатора 6 в виде цветного символа
#property indicator_type6   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы
#property indicator_color6  clrLimeGreen,clrDeepPink
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение метки индикатора
#property indicator_label6  "i-KlPrice_Vol_Direct"
//+-----------------------------------------+
//|  Описание классов усреднений            |
//+-----------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------------+
//---- объявление переменных классов CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3,XMA4;
//+-----------------------------------------+
//|  объявление перечислений                |
//+-----------------------------------------+
enum Applied_price_ //Тип константы
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
//+-----------------------------------------+
//|  объявление перечислений                |
//+-----------------------------------------+
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
//+-----------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА           |
//+-----------------------------------------+
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;   //объём 
input Smooth_Method MA_Method1=MODE_SMA_;           //метод усреднения мувинга
input uint Length1=100;                             //глубина сглаживания мувинга                  
input int Phase1=15;                                //параметр усреднения мувинга,
//--- для JJMA изменяющийся в пределах -100..+100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей.
input Smooth_Method MA_Method2=MODE_JJMA;           //метод усреднения размера свеч
input uint Length2=20;                              //глубина усреднения  размера свеч 
input int Phase2=100;                               //параметр сглаживания  размера свеч,
//--- для JJMA изменяющийся в пределах -100..+100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей.
input uint Smooth=20;                               //период сглаживания индикатора
input Applied_price_ IPC=PRICE_CLOSE_;              //ценовая константа
input int                 HighLevel2=+150;          //уровень перекупленности 2
input int                 HighLevel1=+20;           //уровень перекупленности 1
input int                 LowLevel1=-20;            //уровень перепроданности 1
input int                 LowLevel2=-150;           //уровень перепроданности 2
input int Shift=0;                                  //сдвиг индикатора по горизонтали в барах
//+-----------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
double UpIndBuffer[],DnIndBuffer[];
double MaxIndBuffer[],MinIndBuffer[];
double DirectBuffer[],ColorDirectBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1,min_rates_2;
//+------------------------------------------------------------------+   
//| i-KlPrice indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных   
   min_rates_1=GetStartBars(MA_Method1,Length1,Phase1);
   min_rates_2=min_rates_1+GetStartBars(MA_Method2,Length2,Phase2);
   min_rates_total=min_rates_2+30;

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Length1", Length1);
   XMA2.XMALengthCheck("Length2", Length2);
   XMA3.XMALengthCheck("Smooth",Smooth);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("Phase1", Phase1, MA_Method1);
   XMA2.XMAPhaseCheck("Phase2", Phase2, MA_Method2);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,MaxIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,MinIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
   
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(6,DirectBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикаторапо горизонтали
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(5,PLOT_ARROW,159);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(7,ColorDirectBuffer,INDICATOR_COLOR_INDEX);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"i-KlPrice_Vol_Direct");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| i-KlPrice iteration function                                     | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double price_,xma,range,xrange,res,jres,dwband,vol,xvol;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar,clr;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price_=PriceSeries(IPC,bar,open,low,high,close);
      xma=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method1,Phase1,Length1,price_,bar,false);
      range=high[bar]-low[bar];
      xrange=XMA2.XMASeries(min_rates_1,prev_calculated,rates_total,MA_Method2,Phase2,Length2,range,bar,false);      
      dwband=xma-xrange;
      if(!xrange) xrange=1.0;
      res=100*(price_-dwband)/(2*xrange)-50;      
      if(VolumeType==VOLUME_TICK) vol=double(tick_volume[bar]);
      else vol=double(volume[bar]);
      res*=vol; //домножаем значение i-KlPrice на объём      
      jres=XMA3.XMASeries(min_rates_2,prev_calculated,rates_total,MODE_JJMA,100,Smooth,res,bar,false);
      IndBuffer[bar]=jres; 
      DirectBuffer[bar]=IndBuffer[bar];      
      xvol=XMA4.XMASeries(min_rates_2,prev_calculated,rates_total,MODE_JJMA,100,Smooth,vol,bar,false);  //усредняем объём  
      MaxIndBuffer[bar]=HighLevel2*xvol;
      UpIndBuffer[bar]=HighLevel1*xvol;
      DnIndBuffer[bar]=LowLevel1*xvol;
      MinIndBuffer[bar]=LowLevel2*xvol;
      //---- раскраска гистограммы      
      clr=2;
      if(IndBuffer[bar]>MaxIndBuffer[bar]) clr=4.0;
      else if(IndBuffer[bar]>UpIndBuffer[bar]) clr=3.0;
      else if(IndBuffer[bar]<MinIndBuffer[bar]) clr=0.0;
      else if(IndBuffer[bar]<DnIndBuffer[bar]) clr=1.0;
      ColorIndBuffer[bar]=clr;
     }
//---- пересчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) first++; 
//---- Основной цикл раскраска значков
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(IndBuffer[bar]>IndBuffer[bar-1]) clr=0.0;
      else if(IndBuffer[bar]<IndBuffer[bar-1]) clr=1.0;
      else clr=int(ColorDirectBuffer[bar-1]);
      ColorDirectBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
