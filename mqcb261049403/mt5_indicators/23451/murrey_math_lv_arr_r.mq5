//+------------------------------------------------------------------+
//|                                         Murrey_Math_Lv_Arr_r.mq5 |
//|                                               Copyright VDV Soft |
//|                                                 vdv_2001@mail.ru |
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
//|                                         Murrey_Math_Lv_Arr_r.mq5 |
//|                                               Copyright VDV Soft |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "VDV Soft"
#property link      "vdv_2001@mail.ru"
#property version   "1.12"
#property description "Данный индикатор создан на основе и с использованием алгоритма"
#property description "Vladislav Goshkov (VG) 4vg@mail.ru"
#property description "The given indicator is created on a basis and with algorithm use"
#property description "Vladislav Goshkov (VG) 4vg@mail.ru"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано 13 буферов
#property indicator_buffers 13
//---- использовано 13 графических построений
#property indicator_plots   13
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define  width_line          1
//+----------------------------------------------+
//|  Параметры отрисовки индикаторов             |
//+----------------------------------------------+
//--- plot buffer 1
#property indicator_label1  "Вращение, разворот [-2/8]" //"extremely overshoot [-2/8]"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  DarkBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  width_line
//--- plot buffer 2
#property indicator_label2  "Слабая остановка и разворот [-1/8]" // "overshoot [-1/8]"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  DarkViolet
#property indicator_style2  STYLE_SOLID
#property indicator_width2  width_line
//--- plot buffer 3
#property indicator_label3  "Окончательное сопротивление [0/8]" // "Ultimate Support - extremely oversold [0/8]"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  DeepSkyBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  width_line
//--- plot buffer 4
#property indicator_label4  "Слабая остановка и разворот [1/8]" // "Weak, Stall and Reverse - [1/8]"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  Peru
#property indicator_style4  STYLE_SOLID
#property indicator_width4  width_line
//--- plot buffer 5
#property indicator_label5  "Вращение, разворот [2/8]" // "Pivot, Reverse - major [2/8]"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  Red
#property indicator_style5  STYLE_SOLID
#property indicator_width5  width_line
//--- plot buffer 6
#property indicator_label6  "Дно торгового диапазона [3/8]" // "Bottom of Trading Range - [3/8], if 10-12 bars then 40% Time. BUY Premium Zone"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  MediumSeaGreen
#property indicator_style6  STYLE_SOLID
#property indicator_width6  width_line
//--- plot buffer 7
#property indicator_label7  "Главные сопротивление/поддержка [4/8]" // "Major Support/Resistance Pivotal Point [4/8]- Best New BUY or SELL level"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  DarkGray
#property indicator_style7  STYLE_SOLID
#property indicator_width7  width_line
//--- plot buffer 8
#property indicator_label8  "Верх торгового диапазона [5/8]" // "Top of Trading Range - [5/8], if 10-12 bars then 40% Time. SELL Premium Zone"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  MediumSeaGreen
#property indicator_style8  STYLE_SOLID
#property indicator_width8  width_line
//--- plot buffer 9
#property indicator_label9  "Вращение, разворот [6/8]" // "Pivot, Reverse - major [6/8]"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  Red
#property indicator_style9  STYLE_SOLID
#property indicator_width9  width_line
//--- plot buffer 10
#property indicator_label10  "Слабая остановка и разворот [7/8]" // "Weak, Stall and Reverse - [7/8]"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  Peru
#property indicator_style10  STYLE_SOLID
#property indicator_width10  width_line
//--- plot buffer 11
#property indicator_label11  "Окончательное сопротивление [8/8]" // "Ultimate Resistance - extremely overbought [8/8]"
#property indicator_type11   DRAW_ARROW
#property indicator_color11  DeepSkyBlue
#property indicator_style11  STYLE_SOLID
#property indicator_width11  width_line
//--- plot buffer 12
#property indicator_label12  "Слабая остановка и разворот [+1/8]" // "overshoot [+1/8]"
#property indicator_type12   DRAW_ARROW
#property indicator_color12  DarkViolet
#property indicator_style12  STYLE_SOLID
#property indicator_width12  width_line
//--- plot buffer 13
#property indicator_label13  "Вращение, разворот [+2/8]" // "extremely overshoot [+2/8]"
#property indicator_type13   DRAW_ARROW
#property indicator_color13  DarkBlue
#property indicator_style13  STYLE_SOLID
#property indicator_width13  width_line
//+----------------------------------------------+
// Описание перечисления type_font               |
// Описание класса CFontName                     | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+ 
//|  объявление перечислений                     |
//+----------------------------------------------+ 
enum PLOT_DRAW_TYPE_ //Тип константы
  {
   DRAW_ARROW_ = 1,     //значёк
   DRAW_LINE_           //линия
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input int CalculationPeriod=64;              //Период расчета P
input int StepBack=0;
input bool ViewFlag=false;
input int    FontSize=8;                     //размер шрифта
input type_font FontType=Font7;              //тип шрифта
input string  LableSirname="Murrey_Math_Lv"; //Первая часть имени графических объектов
input PLOT_DRAW_TYPE_ DrawType=DRAW_ARROW_;  //Вариант отображения уровней Мюррея
input uint Arrow=160;                        //Символ для уровней Мюррея
input uint ArrowSize=1;                      //Размер символа для уровней Мюррея
input uint CountBars=500;                    //количество баров для расчёта индикатора
input uint ForwardBars=3;                    //количество баров справа от графика (максимум CalculationPeriod)
//+----------------------------------------------+
//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];
double Buffer7[];
double Buffer8[];
double Buffer9[];
double Buffer10[];
double Buffer11[];
double Buffer12[];
double Buffer13[];
int ShiftBarsForward=100;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,count_bars,nForwardBars;
string sFontType;
string LablesNames[13]=
  {
   "Вращение, разворот [-2/8]","Слабая остановка и разворот [-1/8]","Окончательное сопротивление [0/8]","Слабая остановка и разворот [1/8]",
   "Вращение, разворот [2/8]","Дно торгового диапазона [3/8]","Главные сопротивление/поддержка [4/8]","Верх торгового диапазона [5/8]",
   "Вращение, разворот [6/8]","Слабая остановка и разворот [7/8]","Окончательное сопротивление [8/8]",
   "Слабая остановка и разворот [+1/8]","Вращение, разворот [+2/8]"
  };
color LablesColors[13];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Инициализация переменных начала отсчёта данных
   min_rates_total=2*(CalculationPeriod+StepBack)+1;
   count_bars=int(MathMax(CountBars,min_rates_total));
   ShiftBarsForward=CalculationPeriod-1;
   nForwardBars=int(MathMin(ForwardBars,ShiftBarsForward));
//--- indicator buffers mapping
   SetIndexBuffer(0,Buffer1,INDICATOR_DATA);
   SetIndexBuffer(1,Buffer2,INDICATOR_DATA);
   SetIndexBuffer(2,Buffer3,INDICATOR_DATA);
   SetIndexBuffer(3,Buffer4,INDICATOR_DATA);
   SetIndexBuffer(4,Buffer5,INDICATOR_DATA);
   SetIndexBuffer(5,Buffer6,INDICATOR_DATA);
   SetIndexBuffer(6,Buffer7,INDICATOR_DATA);
   SetIndexBuffer(7,Buffer8,INDICATOR_DATA);
   SetIndexBuffer(8,Buffer9,INDICATOR_DATA);
   SetIndexBuffer(9,Buffer10,INDICATOR_DATA);
   SetIndexBuffer(10,Buffer11,INDICATOR_DATA);
   SetIndexBuffer(11,Buffer12,INDICATOR_DATA);
   SetIndexBuffer(12,Buffer13,INDICATOR_DATA);

   for(int count=0; count<13; count++) PlotIndexSetInteger(count,PLOT_LINE_WIDTH,MathMin(ArrowSize,5));
   

   if(DrawType==DRAW_ARROW_) for(int count=0; count<13; count++) 
    {    
     PlotIndexSetInteger(count,PLOT_DRAW_TYPE,DRAW_ARROW);
     PlotIndexSetInteger(count,PLOT_ARROW,Arrow);
    }
   else for(int count=0; count<13; count++) PlotIndexSetInteger(count,PLOT_DRAW_TYPE,DRAW_LINE);
//---   
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"Murrey_Math_Lv_Arr_r("+IntegerToString(CalculationPeriod)+")");
//---  
   for(int rrr=0; rrr<13; rrr++)
     {
      PlotIndexSetInteger(rrr,PLOT_SHIFT,ShiftBarsForward);
      PlotIndexSetDouble(rrr,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      LablesColors[rrr]=color(PlotIndexGetInteger(rrr,PLOT_LINE_COLOR));
     }
//---
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,LableSirname,0,-1);
//----
   ChartRedraw(0);
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
//--- check for data
   if(rates_total<min_rates_total) return(0);

   int first=prev_calculated-1;

   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      first=min_rates_total;
      for(int i=0; i<=min_rates_total; i++)
        {
         Buffer1[i]=EMPTY_VALUE;
         Buffer2[i]=EMPTY_VALUE;
         Buffer3[i]=EMPTY_VALUE;
         Buffer4[i]=EMPTY_VALUE;
         Buffer5[i]=EMPTY_VALUE;
         Buffer6[i]=EMPTY_VALUE;
         Buffer7[i]=EMPTY_VALUE;
         Buffer8[i]=EMPTY_VALUE;
         Buffer9[i]=EMPTY_VALUE;
         Buffer10[i]=EMPTY_VALUE;
         Buffer11[i]=EMPTY_VALUE;
         Buffer12[i]=EMPTY_VALUE;
         Buffer13[i]=EMPTY_VALUE;
        }
     }

//---- ограничение числа расчитываемых и отображаемых баров
   if(CountBars)
     {
      int barx=rates_total-1-count_bars;
      first=int(MathMax(first,barx));
      barx=rates_total-int(CountBars)-ShiftBarsForward;
      //--- осуществление сдвига начала отсчета отрисовки индикатора     
      for(int count=12; count>=0; count--) PlotIndexSetInteger(count,PLOT_DRAW_BEGIN,barx);
     }
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);

//--- calculate Murrey_Math
   for(int i=first; i<rates_total; i++) CalcMurreyMath(i,rates_total,high,low);

   for(int i=ShiftBarsForward-nForwardBars; i<=ShiftBarsForward; i++)
     {
      Buffer1[rates_total-i]=Buffer1[rates_total-ShiftBarsForward-1];
      Buffer2[rates_total-i]=Buffer2[rates_total-ShiftBarsForward-1];
      Buffer3[rates_total-i]=Buffer3[rates_total-ShiftBarsForward-1];
      Buffer4[rates_total-i]=Buffer4[rates_total-ShiftBarsForward-1];
      Buffer5[rates_total-i]=Buffer5[rates_total-ShiftBarsForward-1];
      Buffer6[rates_total-i]=Buffer6[rates_total-ShiftBarsForward-1];
      Buffer7[rates_total-i]=Buffer7[rates_total-ShiftBarsForward-1];
      Buffer8[rates_total-i]=Buffer8[rates_total-ShiftBarsForward-1];
      Buffer9[rates_total-i]=Buffer9[rates_total-ShiftBarsForward-1];
      Buffer10[rates_total-i]=Buffer10[rates_total-ShiftBarsForward-1];
      Buffer11[rates_total-i]=Buffer11[rates_total-ShiftBarsForward-1];
      Buffer12[rates_total-i]=Buffer12[rates_total-ShiftBarsForward-1];
      Buffer13[rates_total-i]=Buffer13[rates_total-ShiftBarsForward-1];
     }

   for(int i=1; i<=ShiftBarsForward-nForwardBars; i++)
     {
      Buffer1[rates_total-i]=Buffer2[rates_total-i]=Buffer3[rates_total-i]=Buffer4[rates_total-i]=EMPTY_VALUE;
      Buffer5[rates_total-i]=Buffer6[rates_total-i]=Buffer7[rates_total-i]=Buffer8[rates_total-i]=EMPTY_VALUE;
      Buffer9[rates_total-i]=Buffer10[rates_total-i]=Buffer11[rates_total-i]=Buffer12[rates_total-i]=Buffer13[rates_total-i]=EMPTY_VALUE;
     }

   datetime time0=time[rates_total-1]+PeriodSeconds(PERIOD_CURRENT);
   int barx=rates_total-ShiftBarsForward-1;
   SetTLabel(0,LablesNames[0],0,time0,Buffer1[barx],LablesNames[0],LablesColors[0],sFontType,FontSize);
   SetTLabel(0,LablesNames[1],0,time0,Buffer2[barx],LablesNames[1],LablesColors[1],sFontType,FontSize);
   SetTLabel(0,LablesNames[2],0,time0,Buffer3[barx],LablesNames[2],LablesColors[2],sFontType,FontSize);
   SetTLabel(0,LablesNames[3],0,time0,Buffer4[barx],LablesNames[3],LablesColors[3],sFontType,FontSize);
   SetTLabel(0,LablesNames[4],0,time0,Buffer5[barx],LablesNames[4],LablesColors[4],sFontType,FontSize);
   SetTLabel(0,LablesNames[5],0,time0,Buffer6[barx],LablesNames[5],LablesColors[5],sFontType,FontSize);
   SetTLabel(0,LablesNames[6],0,time0,Buffer7[barx],LablesNames[6],LablesColors[6],sFontType,FontSize);
   SetTLabel(0,LablesNames[7],0,time0,Buffer8[barx],LablesNames[7],LablesColors[7],sFontType,FontSize);
   SetTLabel(0,LablesNames[8],0,time0,Buffer9[barx],LablesNames[8],LablesColors[8],sFontType,FontSize);
   SetTLabel(0,LablesNames[9],0,time0,Buffer10[barx],LablesNames[9],LablesColors[9],sFontType,FontSize);
   SetTLabel(0,LablesNames[10],0,time0,Buffer11[barx],LablesNames[10],LablesColors[10],sFontType,FontSize);
   SetTLabel(0,LablesNames[11],0,time0,Buffer12[barx],LablesNames[11],LablesColors[11],sFontType,FontSize);
   SetTLabel(0,LablesNames[12],0,time0,Buffer13[barx],LablesNames[12],LablesColors[12],sFontType,FontSize);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalcMurreyMath(int index,const int Rates_total,const double &high[],const double &low[])
  {
//---
   int sht=CalculationPeriod+StepBack;
   int barx=Rates_total-1-index;
   double min=low[ArrayMinimum(low,barx,sht)];
   double max=high[ArrayMaximum(high,barx,sht)];
   double fractal=DetermineFractal(max);
   double range=MathMax(max-min,_Point);
   double sum=MathFloor(MathLog(fractal/range)/MathLog(2));
   double octave=fractal*(MathPow(0.5,sum));
   double mn=MathFloor(min/octave)*octave;
   double mx=mn+octave;
//---
   if(mx<max) mx+=octave;
//---
   double x1=0;
   double x2=0;
   double x3=0;
   double x4=0;
   double x5=0;
   double x6=0;
//---
   double y1=0;
   double y2=0;
   double y3=0;
   double y4=0;
   double y5=0;
   double y6=0;
//---
   double dm=mx-mn;
   double dm2=dm/2;
   double dm4=dm/4;
   double dm8=dm/8;
   double dm16=dm/16;
//---
   if(min>=3*dm/16+mn&&max<=9*dm16+mn) x2=mn+dm2;
   if(min>=mn-dm8 && max<=5*dm8+mn && x2==0) x1=mn+dm2;
   if(min>=mn+7*dm16&&max<=13*dm16+mn) x4=mn+3*dm4;
   if(min>=mn+3*dm8&&max<=9*dm8+mn&&x4==0) x5=mx;
   if(min>=mn+dm8&&max<=7*dm8+mn&&x1==0&&x2==0&&x4==0&&x5==0) x3=mn+3*dm4;
   if(x1+x2+x3+x4+x5==0) x6=mx;
//---
   double finalH=x1+x2+x3+x4+x5+x6;
//---
   if(x1>0) y1=mn;
   if(x2>0) y2=mn+dm4;
   if(x3>0) y3=mn+dm4;
   if(x4>0) y4=mn+dm2;
   if(x5>0) y5=mn+dm2;
//---
   double finalL=y1+y2+y3+y4+y5;
   if(finalH>0 && !finalL) y6=mn;
   finalL+=y6;
   double dmml=(finalH-finalL)/8;
   int bar=index-ShiftBarsForward;
//---
   Buffer1[bar]=(finalL-dmml*2);
   Buffer2[bar]=Buffer1[bar]+dmml;
   Buffer3[bar]=Buffer2[bar]+dmml;
   Buffer4[bar]=Buffer3[bar]+dmml;
   Buffer5[bar]=Buffer4[bar]+dmml;
   Buffer6[bar]=Buffer5[bar]+dmml;
   Buffer7[bar]=Buffer6[bar]+dmml;
   Buffer8[bar]=Buffer7[bar]+dmml;
   Buffer9[bar]=Buffer8[bar]+dmml;
   Buffer10[bar]=Buffer9[bar]+dmml;
   Buffer11[bar]=Buffer10[bar]+dmml;
   Buffer12[bar]=Buffer11[bar]+dmml;
   Buffer13[bar]=Buffer12[bar]+dmml;
//---
   if(!ViewFlag)
     {
      int bar1=bar-1;
      //---  
      if(Buffer1[bar]!=Buffer1[bar1]
         ||Buffer2[bar]!=Buffer2[bar1]
         ||Buffer3[bar]!=Buffer3[bar1]
         ||Buffer4[bar]!=Buffer4[bar1]
         ||Buffer5[bar]!=Buffer5[bar1]
         ||Buffer6[bar]!=Buffer6[bar1]
         ||Buffer7[bar]!=Buffer7[bar1]
         ||Buffer8[bar]!=Buffer8[bar1]
         ||Buffer9[bar]!=Buffer9[bar1]
         ||Buffer10[bar]!=Buffer10[bar1]
         ||Buffer11[bar]!=Buffer11[bar1]
         ||Buffer12[bar]!=Buffer12[bar1]
         ||Buffer13[bar]!=Buffer13[bar1])
        {
         Buffer1[bar1]=EMPTY_VALUE;
         Buffer2[bar1]=EMPTY_VALUE;
         Buffer3[bar1]=EMPTY_VALUE;
         Buffer4[bar1]=EMPTY_VALUE;
         Buffer5[bar1]=EMPTY_VALUE;
         Buffer6[bar1]=EMPTY_VALUE;
         Buffer7[bar1]=EMPTY_VALUE;
         Buffer8[bar1]=EMPTY_VALUE;
         Buffer9[bar1]=EMPTY_VALUE;
         Buffer10[bar1]=EMPTY_VALUE;
         Buffer11[bar1]=EMPTY_VALUE;
         Buffer12[bar1]=EMPTY_VALUE;
         Buffer13[bar1]=EMPTY_VALUE;
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DetermineFractal(double v)
  {
//---
   if(v<=250000 && v>25000) return(100000);
   if(v<=25000  &&  v>2500) return(10000);
   if(v<=2500 && v>250) return(1000);
   if(v<=250  &&  v>25) return(100);
   if(v<=25  &&  v>12.5) return(12.5);
   if(v<=12.5 && v>6.25) return(12.5);
   if(v<=6.25  &&  v>3.125) return(6.25);
   if(v<=3.125 && v>1.5625) return(3.125);
   if(v<=1.5625 && v>0.390625) return(1.5625);
   if(v<=0.390625 && v>0) return(0.1953125);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//|  Создание текстовой лейбы                                        |
//+------------------------------------------------------------------+
void CreateTLabel
(
 long   chart_id,         // идентификатор графика
 string name,             // имя объекта
 int    nwin,             // индекс окна
 datetime X,              // дистанция по оси X
 double   Y,// дистанция по оси Y
 string text,             // текст
 color  Color,            // цвет текста
 string Font,             // шрифт текста
 int    Size              // размер шрифта
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_TIME,X);
   ObjectSetDouble(chart_id,name,OBJPROP_PRICE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка текстовой лейбы                                   |
//+------------------------------------------------------------------+
void SetTLabel
(
 long   chart_id,         // идентификатор графика
 string name,             // имя объекта
 int    nwin,             // индекс окна
 datetime X,              // дистанция по оси X
 double   Y,// дистанция по оси Y
 string text,             // текст
 color  Color,            // цвет текста
 string Font,             // шрифт текста
 int    Size              // размер шрифта
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_TIME,X);
      ObjectSetDouble(chart_id,name,OBJPROP_PRICE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
//+------------------------------------------------------------------+
