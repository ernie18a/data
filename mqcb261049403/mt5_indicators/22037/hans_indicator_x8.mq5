//+------------------------------------------------------------------+ 
//|                                            Hans_Indicator_x8.mq5 | 
//|                                       Copyright © 2014, Shimodax | 
//|   http://www.strategybuilderfx.com/forums/showthread.php?t=15439 | 
//+------------------------------------------------------------------+ 
/* Introduction:

   Draw ranges for "Simple Combined Breakout System for EUR/USD and GBP/USD" thread
   (see http://www.strategybuilderfx.com/forums/showthread.php?t=15439)

   LocalTimeZone: TimeZone for which MT5 shows your local time, 
                  e.g. 1 or 2 for Europe (GMT+1 or GMT+2 (daylight 
                  savings time).  Use zero for no adjustment.
                  
                  The MetaQuotes demo server uses GMT +2.   
   Enjoy  :-)
   
   Markus

*/
#property copyright "Copyright © 2014, Shimodax"
#property link "http://www.strategybuilderfx.com/forums/showthread.php?t=15439"
#property description "Индикатор расширяющихся коридоров временных зон с четырьмя коридорами. Сформированный коридор равен четырём часам, расширения коридора - шестнадцать часов."
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window  
//---- количество индикаторных буферов 10
#property indicator_buffers 10 
//---- использовано десяь графических построений
#property indicator_plots   10
//+-----------------------------------------+
//|  объявление констант                    |
//+-----------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 1       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color1 clrBlue
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Upper Hans_Indicator 1"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 2       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Magenta цвет
#property indicator_color2 clrMagenta
//---- линия индикатора - сплошная
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Lower Hans_Indicator 1"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 3       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован Lime цвет
#property indicator_color3 clrLime
//---- линия индикатора - сплошная
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width3 3
//---- отображение метки индикатора
#property indicator_label3  "Upper Hans_Indicator 2"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 4       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color4 clrRed
//---- линия индикатора - сплошная
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width4  3
//---- отображение метки индикатора
#property indicator_label4  "Lower Hans_Indicator 2"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 5       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color5 clrGreen
//---- линия индикатора - сплошная
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width5 3
//---- отображение метки индикатора
#property indicator_label5  "Upper Hans_Indicator 3"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 6       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type6   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color6 clrIndigo
//---- линия индикатора - сплошная
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width6  3
//---- отображение метки индикатора
#property indicator_label6  "Lower Hans_Indicator 3"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 7       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type7   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color7 clrGreen
//---- линия индикатора - пунктир
#property indicator_style7  STYLE_DASH
//---- толщина линии индикатора равна 1
#property indicator_width7 1
//---- отображение метки индикатора
#property indicator_label7  "Upper Hans_Indicator 4"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 8       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type8   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color8 clrIndigo
//---- линия индикатора - пунктир
#property indicator_style8  STYLE_DASH
//---- толщина линии индикатора равна 1
#property indicator_width8  1
//---- отображение метки индикатора
#property indicator_label8  "Lower Hans_Indicator 4"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 9       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type9   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color9 clrGreen
//---- линия индикатора - штрих-пунктир
#property indicator_style9  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width9 1
//---- отображение метки индикатора
#property indicator_label9  "Upper Hans_Indicator 5"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 10      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type10   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color10 clrIndigo
//---- линия индикатора - штрих-пунктир
#property indicator_style10  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width10  1
//---- отображение метки индикатора
#property indicator_label10  "Lower Hans_Indicator 6"
//+-----------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА           |
//+-----------------------------------------+
input uint LocalTimeZone=0;         // час начала отсчёта исходного коридора
input uint DestTimeZone=4;          // сдвиг коридора влево в барах
input uint PipsForEntry1=100;       // расширение границ первого сформированного коридора в пунктах
input uint PipsForEntry2=200;       // расширение границ второго сформированного коридора в пунктах
input uint PipsForEntry3=300;       // расширение границ третьего сформированного коридора в пунктах
input uint PipsForEntry4=400;       // расширение границ четвёртого сформированного коридора в пунктах
input int  Shift=0;                 // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------------+

//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double Zone1Upper[],Zone2Upper[],Zone3Upper[],Zone4Upper[],Zone5Upper[];
double Zone1Lower[],Zone2Lower[],Zone3Lower[],Zone4Lower[],Zone5Lower[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=100;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Zone1Upper,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone1Upper,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Zone1Lower,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone1Lower,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Zone2Upper,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone2Upper,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,Zone2Lower,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone2Lower,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,Zone3Upper,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone3Upper,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,Zone3Lower,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone3Lower,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,Zone4Upper,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(6,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(6,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone4Upper,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,Zone4Lower,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(7,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(7,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone4Lower,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(8,Zone5Upper,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(8,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(8,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone5Upper,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(9,Zone5Lower,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(9,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(9,PLOT_EMPTY_VALUE,NULL);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(9,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(9,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone5Lower,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Hans_Indicator_x8("+string(LocalTimeZone)+","+
                      string(DestTimeZone)+","+string(PipsForEntry1)+","+string(PipsForEntry2)+","
                      +string(PipsForEntry3)+","+string(PipsForEntry4)+","+string(Shift)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных
   int limit;

//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

//---- основной цикл расчёта индикатора
   BreakoutRanges(0,limit,LocalTimeZone,DestTimeZone,rates_total,Time,High,Low);
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Compute index of first/last bar of yesterday and today           |
//+------------------------------------------------------------------+
int BreakoutRanges(int offset,int &lastbar,int tzlocal,int tzdest,
                   const int rates_total_,const datetime &Time_[],const double &High_[],const double &Low_[])
  {
//----
   int i,j,k,
   tzdiff=tzlocal-tzdest,
   tzdiffsec=tzdiff*3600,
   tidxstart[2]={ 0,0},
   tidxend[2]={ 0,0 };
   double thigh[2]={ 0.0,0.0 },
   tlow[2]={ DBL_MAX };
   string tfrom[3]={ "04:00","08:00",/*rest of day: */ "12:00"},
   tto[3]={ "08:00","12:00",/*rest of day: */ "24:00" },
   tday;
   bool inperiod=-1;
   datetime timet;

//
// search back for the beginning of the day
//
   tday=TimeToString(Time_[lastbar]-tzdiffsec,TIME_DATE);
   for(; lastbar<rates_total_-1; lastbar++)
     {
      if(TimeToString(Time_[lastbar]-tzdiffsec,TIME_DATE)!=tday)
        {
         lastbar--;
         break;
        }
     }

//
// find the high/low for the two periods and carry them forward through the day
//
   tday="XXX";
   for(i=lastbar; i>=offset; i--)
     {

      timet=Time_[i]-tzdiffsec;   // time of this bar

      string timestr=TimeToString(timet,TIME_MINUTES),// current time HH:MM
      thisday=TimeToString(timet,TIME_DATE);       // current date

                                                   //
      // for all three periods (first period, second period, rest of day)
      //
      for(j=0; j<2; j++)
        {
         if(tfrom[j]<=timestr && timestr<tto[j])
           {   // Bar[i] in this period
            if(inperiod!=j)
              { // entered new period, so last one is completed

               if(j>0)
                 {      // now draw high/low back over the recently completed period
                  for(k=tidxstart[j-1]; k>=tidxend[j-1]; k--)
                    {
                     if(j-1==0)
                       {
                        Zone1Upper[k]= thigh[j-1];
                        Zone1Lower[k]= tlow[j-1];
                       }

                     if(j-1==1)
                       {
                        Zone2Upper[k]= thigh[j-1];
                        Zone2Lower[k]= tlow[j-1];
                       }
                    }
                 }

               inperiod=j;   // remember current period
              }

            if(inperiod==2) // inperiod==2 (end of day) is just to check completion of zone 2
               break;

            // for the current period find idxstart, idxend and compute high/low
            if(tidxstart[j]==0)
              {
               tidxstart[j]=i;
               tday=thisday;
              }

            tidxend[j]=i;

            thigh[j]=MathMax(thigh[j],High_[i]);
            tlow[j]=MathMin(tlow[j],Low_[i]);
           }
        }

      // 
      // carry forward the periods for which we have definite high/lows
      //
      if(inperiod>=1 && tday==thisday)
        { // first time period completed
         Zone1Upper[i]= thigh[0]+PipsForEntry1*_Point;
         Zone1Lower[i]= tlow[0]-PipsForEntry1*_Point;
         Zone2Upper[i]= thigh[0]+PipsForEntry1*_Point;
         Zone2Lower[i]= tlow[0]-PipsForEntry1*_Point;
         Zone3Upper[i]= thigh[0]+PipsForEntry2*_Point;
         Zone3Lower[i]= tlow[0]-PipsForEntry2*_Point;
         Zone4Upper[i]= thigh[0]+PipsForEntry3*_Point;
         Zone4Lower[i]= tlow[0]-PipsForEntry3*_Point;
         Zone5Upper[i]= thigh[0]+PipsForEntry4*_Point;
         Zone5Lower[i]= tlow[0]-PipsForEntry4*_Point;
        }
      else
        {   // none yet to carry forward (zero to clear old values, e.g. from switching timeframe)
         Zone1Upper[i]=Zone1Lower[i]=Zone2Upper[i]=Zone2Lower[i]=Zone3Upper[i]=Zone3Lower[i]=Zone4Upper[i]=Zone4Lower[i]=Zone5Upper[i]=Zone5Lower[i]=NULL;
        }

      //
      // at the beginning of a new day reset everything
      //
      if(tday!="XXX" && tday!=thisday)
        {
         //Print("#",i,"new day ",thisday,"/",tday);

         tday="XXX";

         inperiod=-1;

         for(j=0; j<2; j++)
           {
            tidxstart[j]=0;
            tidxend[j]=0;

            thigh[j]=0;
            tlow[j]=99999;
           }
        }
     }
//----
   return (0);
  }
//+------------------------------------------------------------------+
