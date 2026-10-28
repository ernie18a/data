//+------------------------------------------------------------------+ 
//|                                  Hans_Indicator_Cloud_System.mq5 | 
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
#property description "Индикатор расширяющихся коридоров временных зон с фоновым цветовым заполнением и средней линией коридора."
#property description "Сформированный коридор равен четырём часам, расширение коридора - шестнадцать часов."
//---- номер версии индикатора
#property version   "1.12"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window  
//---- количество индикаторных буферов 14
#property indicator_buffers 14 
//---- использовано восемь графических построений
#property indicator_plots   8
//+-----------------------------------------+
//|  объявление констант                    |
//+-----------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------------+
//| Параметры отрисовки верхнего облака     |
//+-----------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'232,255,247'
#property indicator_color1 C'232,255,247'
//---- отображение метки индикатора
#property indicator_label1  "Upper Hans_Indicator cloud"
//+-----------------------------------------+
//| Параметры отрисовки нижнего облака      |
//+-----------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'255,240,255'
#property indicator_color2 C'255,240,255'
//---- отображение метки индикатора
#property indicator_label2  "Lower Hans_Indicator cloud"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 1       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color3 clrBlue
//---- линия индикатора - сплошная
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Upper Hans_Indicator 1"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 2       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован Magenta цвет
#property indicator_color4 clrMagenta
//---- линия индикатора - сплошная
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width4  1
//---- отображение метки индикатора
#property indicator_label4  "Lower Hans_Indicator 1"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 3       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован LimeGreen цвет
#property indicator_color5 clrLimeGreen
//---- линия индикатора - сплошная
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width5 3
//---- отображение метки индикатора
#property indicator_label5  "Upper Hans_Indicator 2"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 4       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type6   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color6 clrRed
//---- линия индикатора - сплошная
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width6  3
//---- отображение метки индикатора
#property indicator_label6  "Lower Hans_Indicator 2"
//+-----------------------------------------+
//|  Параметры отрисовки индикатора 5       |
//+-----------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type7   DRAW_LINE
//---- в качестве цвета линии индикатора использован SlateGray цвет
#property indicator_color7 clrSlateGray
//---- линия индикатора - сплошная
#property indicator_style7  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width7 2
//---- отображение метки индикатора
#property indicator_label7  "Middle Hans_Indicator"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type8   DRAW_COLOR_CANDLES
#property indicator_color8   clrDeepSkyBlue,clrBlue,clrGray,clrPurple,clrMagenta
//---- отображение метки индикатора
#property indicator_label8  "Hans_Indicator Open;Hans_Indicator High;Hans_Indicator Low;Hans_Indicator Close"
//+-----------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА           |
//+-----------------------------------------+
input uint LocalTimeZone=0;         // час начала отсчёта исходного коридора
input uint DestTimeZone=4;          // сдвиг коридора влево в барах
input  int PipsForEntry=100;        // расширение границ сформированного коридора в пунктах
//+-----------------------------------------+

//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpUp2Buffer[],UpDn2Buffer[],DnUp2Buffer[],DnDn2Buffer[];
double Zone1Upper[],Zone2Upper[];
double Zone1Lower[],Zone2Lower[];
double MiddleBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=100;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpUp2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
//PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpUp2Buffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpDn2Buffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpDn2Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnUp2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
//PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnUp2Buffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnDn2Buffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnDn2Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,Zone1Upper,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone1Upper,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,Zone1Lower,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone1Lower,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,Zone2Upper,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone2Upper,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,Zone2Lower,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Zone2Lower,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(8,MiddleBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(6,PLOT_SHOW_DATA,false);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MiddleBuffer,true);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(9,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(11,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(12,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(13,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(7,PLOT_SHOW_DATA,false);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Hans_Indicator_Cloud_System("+string(LocalTimeZone)+","+string(DestTimeZone)+","+string(PipsForEntry)+")");
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
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

//---- основной цикл расчёта индикатора
   BreakoutRanges(0,limit,LocalTimeZone,DestTimeZone,rates_total,Time,Open,High,Low,Close);
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Compute index of first/last k of yesterday and today             |
//+------------------------------------------------------------------+
int BreakoutRanges(int offset,int &lastk,int tzlocal,int tzdest,const int rates_total_,const datetime &Time_[],
                   const double &Open_[],const double &High_[],const double &Low_[],const double &Close_[])
  {
//----
   int i,j,k,
   tzdiff=tzlocal-tzdest,
   tzdiffsec=tzdiff*3600,
   tidxstart[2]={ 0,0},
   tidxend[2]={ 0,0 };
   double thigh[2]={ NULL },
   tlow[2]={ DBL_MAX };
   string tfrom[3]={ "04:00","08:00",/*rest of day: */ "12:00"},
   tto[3]={ "08:00","12:00",/*rest of day: */ "24:00" },
   tday;
   bool inperiod=-1;
   datetime timet;
//----
//
// search back for the beginning of the day
//
   tday=TimeToString(Time_[lastk]-tzdiffsec,TIME_DATE);
   for(; lastk<rates_total_-1; lastk++)
     {
      if(TimeToString(Time_[lastk]-tzdiffsec,TIME_DATE)!=tday)
        {
         lastk--;
         break;
        }
     }

//
// find the high/low for the two periods and carry them forward through the day
//
   tday="XXX";
   for(i=lastk; i>=offset; i--)
     {
      ExtOpenBuffer[i]=ExtHighBuffer[i]=ExtLowBuffer[i]=ExtCloseBuffer[i]=NULL;
      ExtColorBuffer[i]=2;

      timet=Time_[i]-tzdiffsec;   // time of this k

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
                     //----
                     ExtOpenBuffer[k]=ExtHighBuffer[k]=ExtLowBuffer[k]=ExtCloseBuffer[k]=NULL;
                     ExtColorBuffer[k]=2;

                     if(j-1==0)
                       {
                        Zone1Upper[k]=UpUp2Buffer[k]=thigh[j-1];
                        Zone1Lower[k]=DnDn2Buffer[k]=tlow[j-1];
                        MiddleBuffer[k]=UpDn2Buffer[k]=DnUp2Buffer[k]=(Zone1Upper[k]+Zone1Lower[k])/2;
                        if(Close_[k]>UpUp2Buffer[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]>=Open_[k]) ExtColorBuffer[k]=0;
                           else ExtColorBuffer[k]=1;
                          }
                        if(Close_[k]<DnDn2Buffer[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]<=Open_[k]) ExtColorBuffer[k]=4;
                           else ExtColorBuffer[k]=3;
                          }
                       }

                     if(j-1==1)
                       {
                        Zone2Upper[k]=UpUp2Buffer[k]=thigh[j-1];
                        Zone2Lower[k]=DnDn2Buffer[k]=tlow[j-1];
                        MiddleBuffer[k]=UpDn2Buffer[k]=DnUp2Buffer[k]=(Zone1Upper[k]+Zone1Lower[k])/2;
                        if(Close_[k]>UpUp2Buffer[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]>=Open_[k]) ExtColorBuffer[k]=0;
                           else ExtColorBuffer[k]=1;
                          }
                        if(Close_[k]<DnDn2Buffer[k])
                          {
                           ExtOpenBuffer[k]=Open_[k];
                           ExtHighBuffer[k]=High_[k];
                           ExtLowBuffer[k]=Low_[k];
                           ExtCloseBuffer[k]=Close_[k];
                           if(Close_[k]<=Open_[k]) ExtColorBuffer[k]=4;
                           else ExtColorBuffer[k]=3;
                          }
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
      ExtOpenBuffer[i]=ExtHighBuffer[i]=ExtLowBuffer[i]=ExtCloseBuffer[i]=NULL;
      ExtColorBuffer[i]=2;
      if(inperiod>=1 && tday==thisday)
        { // first time period completed
         Zone1Upper[i]=UpUp2Buffer[i]=thigh[0]+PipsForEntry*_Point;
         Zone1Lower[i]=DnDn2Buffer[i]=tlow[0]-PipsForEntry*_Point;
         MiddleBuffer[i]=UpDn2Buffer[i]=DnUp2Buffer[i]=(Zone1Upper[i]+Zone1Lower[i])/2;
         Zone2Upper[i]= thigh[0]+PipsForEntry*_Point;
         Zone2Lower[i]= tlow[0]-PipsForEntry*_Point;
         if(Close_[i]>UpUp2Buffer[i])
           {
            ExtOpenBuffer[i]=Open_[i];
            ExtHighBuffer[i]=High_[i];
            ExtLowBuffer[i]=Low_[i];
            ExtCloseBuffer[i]=Close_[i];
            if(Close_[i]>=Open_[i]) ExtColorBuffer[i]=0;
            else ExtColorBuffer[i]=1;
           }
         if(Close_[i]<DnDn2Buffer[i])
           {
            ExtOpenBuffer[i]=Open_[i];
            ExtHighBuffer[i]=High_[i];
            ExtLowBuffer[i]=Low_[i];
            ExtCloseBuffer[i]=Close_[i];
            if(Close_[i]<=Open_[i]) ExtColorBuffer[i]=4;
            else ExtColorBuffer[i]=3;
           }
         if(inperiod>=2)
           {   // second period completed
            Zone2Upper[i]=UpUp2Buffer[i]=thigh[1]+PipsForEntry*_Point;
            Zone2Lower[i]=DnDn2Buffer[i]=tlow[1]-PipsForEntry*_Point;
            MiddleBuffer[i]=UpDn2Buffer[i]=DnUp2Buffer[i]=(Zone1Upper[i]+Zone1Lower[i])/2;
            if(Close_[i]>UpUp2Buffer[i])
              {
               ExtOpenBuffer[i]=Open_[i];
               ExtHighBuffer[i]=High_[i];
               ExtLowBuffer[i]=Low_[i];
               ExtCloseBuffer[i]=Close_[i];
               if(Close_[i]>=Open_[i]) ExtColorBuffer[i]=0;
               else ExtColorBuffer[i]=1;
              }
            if(Close_[i]<DnDn2Buffer[i])
              {
               ExtOpenBuffer[i]=Open_[i];
               ExtHighBuffer[i]=High_[i];
               ExtLowBuffer[i]=Low_[i];
               ExtCloseBuffer[i]=Close_[i];
               if(Close_[i]<=Open_[i]) ExtColorBuffer[i]=4;
               else ExtColorBuffer[i]=3;
              }
           }
        }
      else
        {   // none yet to carry forward (zero to clear old values, e.g. from switching timeframe)
         Zone1Upper[i]=Zone1Lower[i]=Zone2Upper[i]=Zone2Lower[i]=MiddleBuffer[i]=UpDn2Buffer[i]=DnUp2Buffer[i]=UpUp2Buffer[i]=DnDn2Buffer[i]=NULL;
         ExtOpenBuffer[i]=ExtHighBuffer[i]=ExtLowBuffer[i]=ExtCloseBuffer[i]=NULL;
         ExtColorBuffer[i]=2;
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

            thigh[j]=NULL;
            tlow[j]=DBL_MAX;
           }
        }
     }
//----
   return (0);
  }
//+------------------------------------------------------------------+
