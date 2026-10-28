//+------------------------------------------------------------------+ 
//|                                     Hans_Indicator_x22_Cloud.mq5 | 
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
#property description "Индикатор расширяющихся коридоров временных зон с одиннадцатью коридорами."
#property description "Сформированный коридор равен четырём часам, расширения коридора - шестнадцать часов."
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window  
//---- количество индикаторных буферов 24
#property indicator_buffers 24
//---- использовано двадцать четыре графических построения
#property indicator_plots   24
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
#property indicator_label10  "Lower Hans_Indicator 5"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 11      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type11   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color11 clrGreen
//---- линия индикатора - сплошная
#property indicator_style11  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width11  1
//---- отображение метки индикатора
#property indicator_label11  "Upper Hans_Indicator 6"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 12      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type12   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color12 clrIndigo
//---- линия индикатора - сплошная
#property indicator_style12  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width12  1
//---- отображение метки индикатора
#property indicator_label12  "Lower Hans_Indicator 6"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 13      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type13   DRAW_LINE
//---- в качестве цвета линии индикатора использован Lime цвет
#property indicator_color13 clrLime
//---- линия индикатора - сплошная
#property indicator_style13  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width13 3
//---- отображение метки индикатора
#property indicator_label13  "Upper Hans_Indicator 7"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 14      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type14   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color14 clrRed
//---- линия индикатора - сплошная
#property indicator_style14  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width14  3
//---- отображение метки индикатора
#property indicator_label14  "Lower Hans_Indicator 7"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 15      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type15   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color15 clrGreen
//---- линия индикатора - сплошная
#property indicator_style15  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width15 3
//---- отображение метки индикатора
#property indicator_label15  "Upper Hans_Indicator 8"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 16      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type16   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color16 clrIndigo
//---- линия индикатора - сплошная
#property indicator_style16  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width16  3
//---- отображение метки индикатора
#property indicator_label16  "Lower Hans_Indicator 8"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 17      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type17   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color17 clrGreen
//---- линия индикатора - пунктир
#property indicator_style17  STYLE_DASH
//---- толщина линии индикатора равна 1
#property indicator_width17 1
//---- отображение метки индикатора
#property indicator_label17  "Upper Hans_Indicator 8"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 18      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type18   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color18 clrIndigo
//---- линия индикатора - пунктир
#property indicator_style18  STYLE_DASH
//---- толщина линии индикатора равна 1
#property indicator_width18  1
//---- отображение метки индикатора
#property indicator_label18  "Lower Hans_Indicator 8"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 19      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type19   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color19 clrGreen
//---- линия индикатора - штрих-пунктир
#property indicator_style19  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width19 1
//---- отображение метки индикатора
#property indicator_label19  "Upper Hans_Indicator 10"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 20      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type20   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color20 clrIndigo
//---- линия индикатора - штрих-пунктир
#property indicator_style20  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width20  1
//---- отображение метки индикатора
#property indicator_label20  "Lower Hans_Indicator 10"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 21      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type21   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color21 clrGreen
//---- линия индикатора - сплошная
#property indicator_style21  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width21  1
//---- отображение метки индикатора
#property indicator_label21  "Upper Hans_Indicator 11"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 22      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type22   DRAW_LINE
//---- в качестве цвета линии индикатора использован Indigo цвет
#property indicator_color22 clrIndigo
//---- линия индикатора - сплошная
#property indicator_style22  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width22  1
//---- отображение метки индикатора
#property indicator_label22  "Lower Hans_Indicator 11"

//+-----------------------------------------+
//|  Параметры отрисовки индикатора 23      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type23   DRAW_LINE
//---- в качестве цвета линии индикатора использован Lime цвет
#property indicator_color23 clrLime
//---- линия индикатора - сплошная
#property indicator_style23  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width23 3
//---- отображение метки индикатора
#property indicator_label23  "Upper Hans_Indicator 12"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 24      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type24   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color24 clrRed
//---- линия индикатора - сплошная
#property indicator_style24  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width24  3
//---- отображение метки индикатора
#property indicator_label24  "Lower Hans_Indicator 12"
//+-----------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА           |
//+-----------------------------------------+
input uint LocalTimeZone=0;         // час начала отсчёта исходного коридора
input uint DestTimeZone=4;          // сдвиг коридора влево в барах
input uint PipsForEntryStep=50;     // шаг расширения границ каждого сформированного коридора в пунктах
input int  Shift=0;                 // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------------+

//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double Zone1Upper[],Zone2Upper[],Zone3Upper[],Zone4Upper[],Zone5Upper[],Zone6Upper[];
double Zone1Lower[],Zone2Lower[],Zone3Lower[],Zone4Lower[],Zone5Lower[],Zone6Lower[];
double Zone7Upper[],Zone8Upper[],Zone9Upper[],Zone10Upper[],Zone11Upper[],Zone12Upper[];
double Zone7Lower[],Zone8Lower[],Zone9Lower[],Zone10Lower[],Zone11Lower[],Zone12Lower[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=100;


//---- Инициализация индикаторных буферов  
   IndBufferInit(0,Zone1Upper);
   IndBufferInit(1,Zone1Lower);
   //----
   IndBufferInit(2,Zone2Upper);
   IndBufferInit(3,Zone2Lower);
   //----
   IndBufferInit(4,Zone3Upper);
   IndBufferInit(5,Zone3Lower);
   //----
   IndBufferInit(6,Zone4Upper);
   IndBufferInit(7,Zone4Lower);
   //----
   IndBufferInit(8,Zone5Upper);
   IndBufferInit(9,Zone5Lower);
   //----
   IndBufferInit(10,Zone6Upper);
   IndBufferInit(11,Zone6Lower);
   //----
   IndBufferInit(12,Zone7Upper);
   IndBufferInit(13,Zone7Lower);
   //----
   IndBufferInit(14,Zone8Upper);
   IndBufferInit(15,Zone8Lower);
   //----
   IndBufferInit(16,Zone9Upper);
   IndBufferInit(17,Zone9Lower);
   //----
   IndBufferInit(18,Zone10Upper);
   IndBufferInit(19,Zone10Lower);
   //----
   IndBufferInit(20,Zone11Upper);
   IndBufferInit(21,Zone11Lower);
   //----
   IndBufferInit(22,Zone12Upper);
   IndBufferInit(23,Zone12Lower);

//---- Инициализация индикаторов  
   for(int count=0; count<24; count++) IndInit(count,NULL,min_rates_total,Shift);
   
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Hans_Indicator_x22("+string(LocalTimeZone)+","+ string(DestTimeZone)+","+string(PipsForEntryStep)+","+string(Shift)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndBufferInit(int BuffNumber,double &Buffer[])
  {
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(BuffNumber,Buffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(Buffer,true);
//----
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void IndInit(int PlotNumber,double Empty_Value,int Draw_Begin,int nShift)
  {
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(PlotNumber,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,nShift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_SHOW_DATA,false);
//----
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
         Zone1Upper[i]= thigh[0]+1*PipsForEntryStep*_Point;
         Zone1Lower[i]= tlow[0]-1*PipsForEntryStep*_Point;
         Zone2Upper[i]= thigh[0]+1*PipsForEntryStep*_Point;
         Zone2Lower[i]= tlow[0]-1*PipsForEntryStep*_Point;
         Zone3Upper[i]= thigh[0]+2*PipsForEntryStep*_Point;
         Zone3Lower[i]= tlow[0]-2*PipsForEntryStep*_Point;
         Zone4Upper[i]= thigh[0]+3*PipsForEntryStep*_Point;
         Zone4Lower[i]= tlow[0]-3*PipsForEntryStep*_Point;
         Zone5Upper[i]= thigh[0]+4*PipsForEntryStep*_Point;
         Zone5Lower[i]= tlow[0]-4*PipsForEntryStep*_Point;
         Zone6Upper[i]= thigh[0]+5*PipsForEntryStep*_Point;
         Zone6Lower[i]= tlow[0]-5*PipsForEntryStep*_Point;
         Zone7Upper[i]= thigh[0]+6*PipsForEntryStep*_Point;
         Zone7Lower[i]= tlow[0]-6*PipsForEntryStep*_Point;
         Zone8Upper[i]= thigh[0]+7*PipsForEntryStep*_Point;
         Zone8Lower[i]= tlow[0]-7*PipsForEntryStep*_Point;
         Zone9Upper[i]= thigh[0]+8*PipsForEntryStep*_Point;
         Zone9Lower[i]= tlow[0]-8*PipsForEntryStep*_Point;
         Zone10Upper[i]= thigh[0]+9*PipsForEntryStep*_Point;
         Zone10Lower[i]= tlow[0]-9*PipsForEntryStep*_Point;
         Zone11Upper[i]= thigh[0]+10*PipsForEntryStep*_Point;
         Zone11Lower[i]= tlow[0]-10*PipsForEntryStep*_Point;
         Zone12Upper[i]= thigh[0]+11*PipsForEntryStep*_Point;
         Zone12Lower[i]= tlow[0]-11*PipsForEntryStep*_Point;
        }
      else
        {   // none yet to carry forward (zero to clear old values, e.g. from switching timeframe)
         Zone1Upper[i]=Zone1Lower[i]=Zone2Upper[i]=Zone2Lower[i]=Zone3Upper[i]=Zone3Lower[i]=Zone4Upper[i]=Zone4Lower[i]=Zone5Upper[i]=Zone5Lower[i]=NULL;
         Zone6Upper[i]=Zone6Lower[i]=Zone7Upper[i]=Zone7Lower[i]=Zone8Upper[i]=Zone8Lower[i]=Zone9Upper[i]=Zone9Lower[i]=Zone10Upper[i]=Zone10Lower[i]=NULL;
         Zone11Upper[i]=Zone11Lower[i]=Zone12Upper[i]=Zone12Lower[i]=NULL;
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
