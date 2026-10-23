//+------------------------------------------------------------------+ 
//|                                              KiS_max_min_Avg.mq5 | 
//|                                           Copyright © 2009, KCBT | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2009, KCBT"
#property link ""
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 9
#property indicator_buffers 9 
//---- использовано пять графических построений
#property indicator_plots   5
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrTurquoise
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color2  clrOrchid
//---- отображение метки индикатора
#property indicator_label2  "Lower Cloud"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован зелёный цвет
#property indicator_color3 clrGreen
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "Upper PC Channel"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color4 clrBlue,clrRed
//---- линия индикатора - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width4  3
//---- отображение метки индикатора
#property indicator_label4  "Middle PC Channel"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован розовый цвет
#property indicator_color5 clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width5  1
//---- отображение метки индикатора
#property indicator_label5  "Lower PC Channel"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpperBuffer[],MiddleBuffer[],ColorMiddleBuffer[],LowerBuffer[];
double UpBuffer1[],UpBuffer2[],DnBuffer1[],DnBuffer2[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация констант
   min_rates_total=2;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer2,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnBuffer1,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,UpperBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,MiddleBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,ColorMiddleBuffer,INDICATOR_COLOR_INDEX);

//---- превращение динамического массива в цветовой буфер
   SetIndexBuffer(7,LowerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname="KiS_max_min_Avg";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление целых переменных
   int first,bar,CurDay=0,Color=0,BarCount=0;
   static int BarCount_prev,Color_prev,CurDay_prev,lastbar;
   double DayMax,DayMin,DayOpen;
   static double DayMax_prev,DayMin_prev;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=1;
      BarCount_prev=0;
      DayMax_prev=0.0;
      DayMin_prev=999999999.0;
      Color=0;
      Color_prev=0;
      CurDay_prev=0;
      CurDay=0;
     }
   else // стартовый номер для расчёта новых баров
     {
      first=prev_calculated-1;
     }

   DayMin=DayMin_prev;
   DayMax=DayMax_prev;
   BarCount=BarCount_prev;
   CurDay=CurDay_prev;
   Color=Color_prev;

//---- Основной цикл расчёта канала
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      MqlDateTime str;
      TimeToStruct(Time[bar],str);
      if(CurDay!=str.day)
        {
         for(int iii=BarCount; iii>=0; iii--)
           {
            int barx=bar-iii;
            UpBuffer2[barx]=UpperBuffer[barx]=DayMax_prev;
            UpBuffer1[barx]=DnBuffer1[barx]=MiddleBuffer[barx]=(DayMax_prev+DayMin_prev)/2;
            DnBuffer2[barx]=LowerBuffer[barx]=DayMin_prev;
            if(iii==BarCount)
              {
               if(MiddleBuffer[barx-1]<MiddleBuffer[barx]) Color=0;
               else if(MiddleBuffer[barx-1]>MiddleBuffer[barx]) Color=1;
              }
            ColorMiddleBuffer[barx]=Color;
            lastbar=bar;
           }
         CurDay=str.day;
         BarCount=0;
         DayMax=0.0;
         DayMin=999999999.0;
         DayOpen=Open[bar];
        }
      else
        {
         int barx=bar-1;
         UpBuffer2[bar]=UpperBuffer[bar]=UpBuffer2[barx];
         UpBuffer1[bar]=DnBuffer1[bar]=MiddleBuffer[bar]=UpBuffer1[barx];
         DnBuffer2[bar]=LowerBuffer[bar]=DnBuffer2[barx];
         ColorMiddleBuffer[bar]=ColorMiddleBuffer[barx];
        }
      if(DayMax<High[bar]) DayMax=High[bar];
      if(DayMin>Low[bar]) DayMin=Low[bar];

      BarCount++;
      BarCount=MathMin(rates_total-1,BarCount);

      if(bar<rates_total-1)
        {
         BarCount_prev=BarCount;
         DayMax_prev=DayMax;
         DayMin_prev=DayMin;
         Color_prev=Color;
         CurDay_prev=CurDay;
        }
     }
//----    
   for(bar=rates_total-BarCount-1; bar<rates_total && !IsStopped(); bar++)
     {
      UpBuffer2[bar]=UpperBuffer[bar]=DayMax;
      UpBuffer1[bar]=DnBuffer1[bar]=MiddleBuffer[bar]=(DayMax+DayMin)/2;
      DnBuffer2[bar]=LowerBuffer[bar]=DayMin;
      if(bar==rates_total-BarCount-1)
        {
         if(MiddleBuffer[bar-1]<MiddleBuffer[bar]) Color=0;
         else if(MiddleBuffer[bar-1]>MiddleBuffer[bar]) Color=1;
        }
      else Color=int(ColorMiddleBuffer[bar-1]);
      ColorMiddleBuffer[bar]=Color;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
