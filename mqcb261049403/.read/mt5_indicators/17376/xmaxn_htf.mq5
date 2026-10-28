//+------------------------------------------------------------------+ 
//|                                                   XMA-XN_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "XMA-XN с фиксированным во входных параметрах таймфреймом"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- Включение пользовательских индикаторов в код индикатора как ресурсов
#resource "\\Indicators\\XMA-XN.ex5"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define LINES_TOTAL         100      // Константа для количества линий индикатора
#define INDICATOR_NAME "XMA-XN"      // Константа для имени индикатора
#define SIZE        LINES_TOTAL      // Константа для количества вызовов функции CountIndicator в коде
#define RESET              NULL      // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//---- количество индикаторных буферов
#property indicator_buffers LINES_TOTAL 
//---- использовано всего графических построений
#property indicator_plots   LINES_TOTAL
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка осцилляторов в виде линий
#property indicator_type1   DRAW_LINE
//---- линии - штрихпунктирные кривые
#property indicator_style1 STYLE_SOLID
//---- толщина линий 1
#property indicator_width1  1
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
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
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Smooth_Method
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
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Период графика индикатора
//---
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
//+----------------------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
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
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора XMA-XN
   Ind_Handle=iCustom(Symbol(),TimeFrame,"::Indicators\\XMA-XN",Step,xMA_Method,xLength,xPhase,IPC,0,PriceShift,ColorWidth);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XMA-XN");
      return(INIT_FAILED);
     }
//---    
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
//----
   double K=double(ColorWidth_/(LINES_TOTAL*1.0));
   int period[LINES_TOTAL];
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
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
//---
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   for(int numb=0; numb<LINES_TOTAL; numb++)
      if(!CountIndicator(numb,NULL,TimeFrame,Ind_Handle,numb,Ind[numb].IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора
                    double&  IndBuf[],        // Приемный буфер индикатора
                    const datetime& iTime[],  // Таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET); IndBuf[bar]=Arr[0];
        }
      else
        {
         IndBuf[bar]=IndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) // Период графика индикатора
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
