//+------------------------------------------------------------------+
//|                                       MurreyMathFixPeriod_Lv.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
/*
   --------------------------------------------------------------------------------------------
  * Линии 8/8 и 0/8 (Окончательное сопротивление).
  * Эти линии самые сильные и оказывают сильнейшие сопротивления и поддержку.
   --------------------------------------------------------------------------------------------
  * Линия 7/8  (Слабая, место для остановки и разворота). Weak, Stall and Reverse
  * Эта линия слаба. Если цена зашла слишком далеко и слишком быстро и если она остановилась около этой линии, 
  * значит она развернется быстро вниз. Если цена не остановилась около этой линии, она продолжит движение вверх к 8/8.
   --------------------------------------------------------------------------------------------
  * Линия 1/8  (Слабая, место для остановки и разворота). Weak, Stall and Reverse
  * Эта линия слаба. Если цена зашла слишком далеко и слишком быстро и если она остановилась около этой линии, 
  * значит она развернется быстро вверх. Если цена не остановилась около этой линии, она продолжит движение вниз к 0/8.
   --------------------------------------------------------------------------------------------
  * Линии 6/8 и 2/8 (Вращение, разворот). Pivot, Reverse
  * Эти две линии уступают в своей силе только 4/8 в своей способности полностью развернуть ценовое движение.
   --------------------------------------------------------------------------------------------
  * Линия 5/8 (Верх торгового диапазона). Top of Trading Range
  * Цены всех рынков тратят 40% времени, на движение между 5/8 и 3/8 линиями. 
  * Если цена двигается около линии 5/8 и остается около нее в течении 10-12 дней, рынок сказал что следует 
  * продавать в этой «премиальной зоне», что и делают некоторые люди, но если цена сохраняет тенденцию оставаться 
  * выше 5/8, то она и останется выше нее. Если, однако, цена падает ниже 5/8, то она скорее всего продолжит 
  * падать далее до следующего уровня сопротивления.
   --------------------------------------------------------------------------------------------
  * Линия 3/8 (Дно торгового диапазона). Bottom of Trading Range
  * Если цены ниже этой лини и двигаются вверх, то цене будет сложно пробить этот уровень. 
  * Если пробивают вверх эту линию и остаются выше нее в течении 10-12 дней, значит цены останутся выше этой линии 
  * и потратят 40% времени двигаясь между этой линией и 5/8 линией.
   --------------------------------------------------------------------------------------------
  * Линия 4/8 (Главная линия сопротивления/поддержки). Major Support/Resistance
  * Эта линия обеспечивает наибольшее сопротивление/поддержку. Этот уровень является лучшим для новой покупки или продажи. 
  * Если цена находится выше 4/8, то это сильный уровень поддержки. Если цена находится ниже 4/8, то это прекрасный уровень 
  * сопротивления.
   --------------------------------------------------------------------------------------------
  */
//+------------------------------------------------------------------+
//|                                       MurreyMathFixPeriod_Lv.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использован 41 буфер
#property indicator_buffers 41
//---- использовано 40 графических построений
#property indicator_plots   40
//+----------------------------------------------+ 
//|  объявление констант                         |
//+----------------------------------------------+ 
#define  width_line          2 // Константа для толщины линии индикатора
#define RESET                0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+ 
//|  Параметры отрисовки индикаторов             |
//+----------------------------------------------+ 
//--- plot buffer 1
//#property indicator_label1  "Вращение, разворот [-2/8]" //"extremely overshoot [-2/8]"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  width_line
//--- plot buffer 2
//#property indicator_label2  "Слабая остановка и разворот [-1/8]" // "overshoot [-1/8]"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkViolet
#property indicator_style2  STYLE_SOLID
#property indicator_width2  width_line
//--- plot buffer 3
//#property indicator_label3  "Окончательное сопротивление [0/8]" // "Ultimate Support - extremely oversold [0/8]"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrAqua
#property indicator_style3  STYLE_SOLID
#property indicator_width3  width_line
//--- plot buffer 4
//#property indicator_label4  "Слабая остановка и разворот [1/8]" // "Weak, Stall and Reverse - [1/8]"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrPeru
#property indicator_style4  STYLE_SOLID
#property indicator_width4  width_line
//--- plot buffer 5
//#property indicator_label5  "Вращение, разворот [2/8]" // "Pivot, Reverse - major [2/8]"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  width_line
//--- plot buffer 6
//#property indicator_label6  "Дно торгового диапазона [3/8]" // "Bottom of Trading Range - [3/8], if 10-12 bars then 40% Time. BUY Premium Zone"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrLime
#property indicator_style6  STYLE_SOLID
#property indicator_width6  width_line
//--- plot buffer 7
//#property indicator_label7  "Главные сопротивление/поддержка [4/8]" // "Major Support/Resistance Pivotal Point [4/8]- Best New BUY or SELL level"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDarkGray
#property indicator_style7  STYLE_SOLID
#property indicator_width7  width_line
//--- plot buffer 8
//#property indicator_label8  "Верх торгового диапазона [5/8]" // "Top of Trading Range - [5/8], if 10-12 bars then 40% Time. SELL Premium Zone"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrLime
#property indicator_style8  STYLE_SOLID
#property indicator_width8  width_line
//--- plot buffer 9
//#property indicator_label9  "Вращение, разворот [6/8]" // "Pivot, Reverse - major [6/8]"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrRed
#property indicator_style9  STYLE_SOLID
#property indicator_width9  width_line
//--- plot buffer 10
//#property indicator_label10  "Слабая остановка и разворот [7/8]" // "Weak, Stall and Reverse - [7/8]"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrPeru
#property indicator_style10  STYLE_SOLID
#property indicator_width10  width_line
//--- plot buffer 11
//#property indicator_label11  "Окончательное сопротивление [8/8]" // "Ultimate Resistance - extremely overbought [8/8]"
#property indicator_type11   DRAW_LINE
#property indicator_color11  clrAqua
#property indicator_style11  STYLE_SOLID
#property indicator_width11  width_line
//--- plot buffer 12
//#property indicator_label12  "Слабая остановка и разворот [+1/8]" // "overshoot [+1/8]"
#property indicator_type12   DRAW_LINE
#property indicator_color12  clrDarkViolet
#property indicator_style12  STYLE_SOLID
#property indicator_width12  width_line
//--- plot buffer 13
//#property indicator_label13  "Вращение, разворот [+2/8]" // "extremely overshoot [+2/8]"
#property indicator_type13   DRAW_LINE
#property indicator_color13  clrBlue
#property indicator_style13  STYLE_SOLID
#property indicator_width13  width_line

//#property indicator_label40  "Вертикальные разделители периодов"
#property indicator_type40   DRAW_HISTOGRAM2
#property indicator_color40  clrSilver
#property indicator_style40  STYLE_DASH
#property indicator_width40  1
//--- отображение метки индикатора
#property indicator_label40  "Вертикальный разделитель периодов индикатора"
//+----------------------------------------------+
// Описание перечисления type_font               |
// Описание класса CFontName                     | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+ 
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES Timeframe=PERIOD_D1;   //Таймфрейм индикатора для расчёта уровней
input int CalculationPeriod=64;              //Период расчета P
input int StepBack=0;
input int    FontSize=8;                     //размер шрифта
input type_font FontType=Font7;              //тип шрифта
input string  LableSirname="Murrey_Math_Lv"; //Первая часть имени графических объектов
//+----------------------------------------------+ 
//---- Объявление массива для хранения имён линий
string LinesNames[13]=
  {
   "Вращение, разворот [-2/8]",
   "Слабая остановка и разворот [-1/8]",
   "Окончательное сопротивление [0/8]",
   "Слабая остановка и разворот [1/8]",
   "Вращение, разворот [2/8]",
   "Дно торгового диапазона [3/8]",
   "Главные сопротивление/поддержка [4/8]",
   "Верх торгового диапазона [5/8]",
   "Вращение, разворот [6/8]",
   "Слабая остановка и разворот [7/8]",
   "Окончательное сопротивление [8/8]",
   "Слабая остановка и разворот [+1/8]",
   "Вращение, разворот [+2/8]"
  };
//---- Объявление переменной для хранения результата инициализации индикатора
bool Init;
//---- Объявление целых переменных сдвига отсчёта данных
int ShiftBarsForward;
//---- Объявление целых переменных для хендлов индикаторов
int Murrey_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,Murrey_Calculated;
//+------------------------------------------------------------------+
//|  Массивы переменных для создания нидикаторных буферов            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public:
   double            IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[3][13];
CIndicatorsBuffers Ind1[2];
//+------------------------------------------------------------------+
//| Получение уровней Мюррея                                         |
//+------------------------------------------------------------------+  
bool GetMurreyLevels(double &Array[],datetime Time)
  {
//----
   double Murrey[1];
   for(int i=0; i<13; i++)
     {
      if(CopyBuffer(Murrey_Handle,i,Time,1,Murrey)<=0) return(RESET);
      Array[i]=Murrey[0];
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Проверка уровней Мюррея на перестановку                          |
//+------------------------------------------------------------------+  
bool CheckMurreyLevels(double &Array[])
  {
//----
   static double OldMurrey[13];

   for(int iii=0; iii<13; iii++)
      if(Array[iii]!=OldMurrey[iii])
        {
         for(int kkk=0; kkk<13; kkk++) OldMurrey[kkk]=Array[kkk];
         return(true);
        }
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- Инициализация переменных начала отсчёта данных
   Murrey_Calculated=CalculationPeriod+StepBack+3;
   min_rates_total=Murrey_Calculated*PeriodSeconds(Timeframe)/PeriodSeconds(PERIOD_CURRENT);

   Init=true;
//---- проверка периодов графиков на корректность
   if(Timeframe<Period() && Timeframe!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора MurreyMath не может быть меньше периода текущего графика");
      Init=false;
      return;
     }

//---- получение хендла индикатора MurreyMath_Lv
   Murrey_Handle=iCustom(NULL,Timeframe,"Murrey_Math_Lv",CalculationPeriod,StepBack,true,FontSize,FontType,LableSirname);
   if(Murrey_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора MurreyMath_Lv");

   for(int kkk=0; kkk<3; kkk++)
      for(int iii=0; iii<13; iii++)
        {
         //---- превращение динамического массива в индикаторные буферы
         SetIndexBuffer(13*kkk+iii,Ind[kkk][iii].IndBuffer,INDICATOR_DATA);

         //---- установка значений индикатора, которые не будут видимы на графике
         PlotIndexSetDouble(13*kkk+iii,PLOT_EMPTY_VALUE,EMPTY_VALUE);

         //---- создание метки для отображения в DataWindow
         PlotIndexSetString(13*kkk+iii,PLOT_LABEL,LinesNames[iii]);
        }

//---- превращение динамического массива в индикаторные буферы
   SetIndexBuffer(39,Ind1[0].IndBuffer,INDICATOR_DATA);
   SetIndexBuffer(40,Ind1[1].IndBuffer,INDICATOR_DATA);

//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(39,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   for(int fff=1; fff<3; fff++)
      for(int iii=0; iii<13; iii++)
        {
         //---- копирование свойств первых 13 индикаторов для остальных
         PlotIndexSetInteger(13*fff+iii,PLOT_DRAW_TYPE,PlotIndexGetInteger(iii,PLOT_DRAW_TYPE));
         PlotIndexSetInteger(13*fff+iii,PLOT_LINE_STYLE,PlotIndexGetInteger(iii,PLOT_LINE_STYLE));
         PlotIndexSetInteger(13*fff+iii,PLOT_LINE_WIDTH,PlotIndexGetInteger(iii,PLOT_LINE_WIDTH));
         PlotIndexSetInteger(13*fff+iii,PLOT_LINE_COLOR,PlotIndexGetInteger(iii,PLOT_LINE_COLOR));
        }
//----   
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"Murrey_LvMath_Lv("+EnumToString(Timeframe)+", "+string(CalculationPeriod)+", "+string(StepBack)+")");
//----
   return;
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
   if(BarsCalculated(Murrey_Handle)<10*Murrey_Calculated || rates_total<min_rates_total || !Init) return(RESET);
   if(prev_calculated==rates_total) return(rates_total);

//---- объявления локальных переменных 
   int first,oldcount;
   static int count,bar1;
   static double Murrey[13];
   double val[26];

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first=min_rates_total;
      bar1=first;

      for(int kkk=0; kkk<3; kkk++)
         for(int iii=0; iii<13; iii++)
            for(int bar=0; bar<min_rates_total; bar++)

               count=0;
     }
   else first=prev_calculated-1;

//---- основной цикл расчёта индикатора
   for(int bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(!GetMurreyLevels(Murrey,time[bar]))return(RESET);
      if(CheckMurreyLevels(Murrey))
        {
         count++;
         if(count>2) count=0;

         bar1=bar-1;
         for(int iii=0; iii<13; iii++) Ind[count][iii].IndBuffer[bar1]=Murrey[iii];
        }

      for(int kkk=0; kkk<3; kkk++) for(int iii=0; iii<13; iii++) Ind[kkk][iii].IndBuffer[bar]=EMPTY_VALUE;
      for(int iii=0; iii<13; iii++) Ind[count][iii].IndBuffer[bar]=Murrey[iii];

      //---- Расчёт и отрисовка вертикальных разделителей периодов
      Ind1[0].IndBuffer[bar]=EMPTY_VALUE;
      Ind1[1].IndBuffer[bar]=EMPTY_VALUE;
      ArrayInitialize(val,NULL);
      oldcount=count-1;
      if(oldcount<0) oldcount=2;

      for(int iii=0; iii<13; iii++)
        {
         val[iii]=Ind[oldcount][iii].IndBuffer[bar1];
         val[iii+13]=Ind[count][iii].IndBuffer[bar];
        }
      Ind1[0].IndBuffer[bar1]=5*val[25-ArrayMaximum(val)];
      Ind1[1].IndBuffer[bar1]=val[25-ArrayMinimum(val)]/5;
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
