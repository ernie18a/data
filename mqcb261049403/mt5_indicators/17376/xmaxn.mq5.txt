//+---------------------------------------------------------------------+
//|                                                          XMA-XN.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define LINES_TOTAL         100   // Константа для количества линий индикатора
#define RESET               NULL  // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
#property description "XMA-X"
//---- количество индикаторных буферов
#property indicator_buffers LINES_TOTAL 
//---- использовано всего графических построений
#property indicator_plots   LINES_TOTAL

//+-----------------------------------+
//|  Параметры отрисовки индикаторов  |
//+-----------------------------------+
//---- отрисовка осцилляторов в виде линий
#property indicator_type1   DRAW_LINE
//---- линии - штрихпунктирные кривые
#property indicator_style1 STYLE_SOLID
//---- толщина линий 1
#property indicator_width1  1
//+-----------------------------------+
//|  Описание класса CXMA             |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA[LINES_TOTAL];
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
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
//+-----------------------------------+
//|  объявление перечислений          |
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
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int Step=10; //шаг периода
input Smooth_Method xMA_Method=MODE_JJMA; //метод усреднения
input int xLength=3; //глубина сглаживания                    
input int xPhase=100; //параметр сглаживания,
                      //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; //cдвиг индикатора по вертикали в пунктах
input int ColorWidth=40; //ширина цветовой палитры (изменяется от 0 до 131)
//+-----------------------------------+
int period[LINES_TOTAL];
//---- Объявление переменной значения вертикального сдвига мувингов
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных буферов            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=GetStartBars(xMA_Method,xLength+Step*LINES_TOTAL,xPhase);
//----
   color ArrayColors[]=
     {
      //---- 
      clrBlack,clrDarkGreen,clrDarkSlateGray,clrOlive,clrGreen,clrTeal,clrNavy,clrPurple,clrMaroon,clrIndigo,clrMidnightBlue,clrDarkBlue,
      clrDarkOliveGreen,clrSaddleBrown,clrForestGreen,clrOliveDrab,clrSeaGreen,clrDarkGoldenrod,clrDarkSlateBlue,clrSienna,clrMediumBlue,
      clrBrown,clrDarkTurquoise,clrDimGray,clrLightSeaGreen,clrDarkViolet,clrFireBrick,clrMediumVioletRed,clrMediumSeaGreen,clrChocolate,
      clrCrimson,clrSteelBlue,clrGoldenrod,clrMediumSpringGreen,clrLawnGreen,clrCadetBlue,clrDarkOrchid,clrYellowGreen,clrLimeGreen,clrOrangeRed,
      clrDarkOrange,clrOrange,clrGold,clrYellow,clrChartreuse,clrLime,clrSpringGreen,clrAqua,clrDeepSkyBlue,clrBlue,clrMagenta,clrRed,clrGray,
      clrSlateGray,clrPeru,clrBlueViolet,clrLightSlateGray,clrDeepPink,clrMediumTurquoise,clrDodgerBlue,clrTurquoise,clrRoyalBlue,clrSlateBlue,
      clrDarkKhaki,clrIndianRed,clrMediumOrchid,clrGreenYellow,clrMediumAquamarine,clrDarkSeaGreen,clrTomato,clrRosyBrown,clrOrchid,clrMediumPurple,
      clrPaleVioletRed,clrCoral,clrCornflowerBlue,clrDarkGray,clrSandyBrown,clrMediumSlateBlue,clrTan,clrDarkSalmon,clrBurlyWood,clrHotPink,clrSalmon,
      clrViolet,clrLightCoral,clrSkyBlue,clrLightSalmon,clrPlum,clrKhaki,clrLightGreen,clrAquamarine,clrSilver,clrLightSkyBlue,clrLightSteelBlue,
      clrLightBlue,clrPaleGreen,clrThistle,clrPowderBlue,clrPaleGoldenrod,clrPaleTurquoise,clrLightGray,clrWheat,clrNavajoWhite,clrMoccasin,clrLightPink,
      clrGainsboro,clrPeachPuff,clrPink,clrBisque,clrLightGoldenrod,clrBlanchedAlmond,clrLemonChiffon,clrBeige,clrAntiqueWhite,clrPapayaWhip,clrCornsilk,
      clrLightYellow,clrLightCyan,clrLinen,clrLavender,clrMistyRose,clrOldLace,clrWhiteSmoke,clrSeashell,clrIvory,clrHoneydew,clrAliceBlue,clrLavenderBlush,
      clrMintCream,clrSnow,clrWhite
      //---- 
     };
//----
   int size=ArraySize(ArrayColors);
   size-=2;
   int ColorWidth_=ColorWidth;
   if(ColorWidth>size) ColorWidth_=size;
   if(ColorWidth<1) ColorWidth_=1;
//----
   color Colors[];
   if(ArrayResize(Colors,ColorWidth_)<ColorWidth_) Print("Не удалось распределить память под массив Colors");
   ArrayCopy(Colors,ArrayColors,0,2,ColorWidth_);

//---- индексация элементов в массиве как в таймсерии   
   ArraySetAsSeries(Colors,true);

   double K=double(ColorWidth_/(LINES_TOTAL*1.0));
//----
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      period[numb]=xLength+Step*numb;
      string shortname="";
      StringConcatenate(shortname,"XMA-X",numb,"(",period[numb],")");
      //--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- установка значений индикатора, которые не будут видимы на графике
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- осуществление сдвига начала отсчёта отрисовки индикатора
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(numb,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- копирование свойств первой линии индикатора для всех остальных
      PlotIndexSetInteger(numb,PLOT_DRAW_TYPE,PlotIndexGetInteger(0,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb,PLOT_LINE_STYLE,PlotIndexGetInteger(0,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb,PLOT_LINE_WIDTH,PlotIndexGetInteger(0,PLOT_LINE_WIDTH));
      //---- задание цвета для линии
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,Colors[int(numb*K)]);
     }
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA[0].GetString_MA_Method(xMA_Method);
   StringConcatenate(shortname,"XMA-X",LINES_TOTAL,"(",Step,",",xLength,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int bar,limit,maxbar;
   double price_;

   maxbar=rates_total-1;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      limit=rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- Вызов функции PriceSeries для получения входной цены price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      for(int numb=0; numb<LINES_TOTAL; numb++)
         Ind[numb].IndBuffer[bar]=XMA[numb].XMASeries(maxbar,prev_calculated,rates_total,xMA_Method,xPhase,period[numb],price_,bar,true);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
