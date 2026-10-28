//+------------------------------------------------------------------+
//|                                                FractalSystem.mq5 |
//|                                         Copyright © 2005, Maloma | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Maloma" 
#property link      "" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 6
#property indicator_buffers 6
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type1 DRAW_ARROW
//---- в качестве окраски индикатора использован Red
#property indicator_color1 clrRed
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "Fractal Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован Blue
#property indicator_color2 clrBlue
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки сигнальной линии
#property indicator_label2  "Fractal Down"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован цвет OrangeRed
#property indicator_color3  clrOrangeRed
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение бычьей метки индикатора
#property indicator_label3  "Signal Up"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован цвет CornflowerBlue
#property indicator_color4  clrCornflowerBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Signal Down"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type5   DRAW_SECTION
//---- в качестве цвета бычей линии индикатора использован цвет Magenta
#property indicator_color5  clrMagenta
//---- линия индикатора 5 - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора 5 равна 1
#property indicator_width5  1
//---- отображение бычьей метки индикатора
#property indicator_label5  "Diapazon Up"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type6   DRAW_SECTION
//---- в качестве цвета медвежьей линии индикатора использован цвет Teal
#property indicator_color6  clrTeal
//---- линия индикатора 6 - непрерывная кривая
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение медвежьей метки индикатора
#property indicator_label6  "Diapazon Down"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double dUpFractalsBuffer[],dDownFractalsBuffer[];
double dUpSignalBuffer[],dDownSignalBuffer[];
double UpDiapazonBuffer[],DnDiapazonBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
double Point3;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=6;
   Point3=3*_Point;

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"FractalsmSignal6diapazon(",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,dUpFractalsBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,119);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(dUpFractalsBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,dDownFractalsBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(dDownFractalsBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,dUpSignalBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(dUpSignalBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,241);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,dDownSignalBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(dDownSignalBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,242);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,UpDiapazonBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(UpDiapazonBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,DnDiapazonBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(DnDiapazonBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0.0);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,bar;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Close,true);

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-6;               // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {      
      dUpSignalBuffer[bar]=NULL;
      UpDiapazonBuffer[bar]=NULL;
      dUpFractalsBuffer[bar]=NULL;
      
      dDownSignalBuffer[bar]=NULL;
      DnDiapazonBuffer[bar]=NULL;
      dDownFractalsBuffer[bar]=NULL;
      //----Up and Down Fractals
      //----5 bars Fractal
      if(High[bar+3]>High[bar+3+1] && High[bar+3]>High[bar+3+2] && High[bar+3]>High[bar+3-1] && High[bar+3]>High[bar+3-2])
        {
         dUpSignalBuffer[bar]=Low[bar]-Point3;
         dUpFractalsBuffer[bar+3]=High[bar+3];
         UpDiapazonBuffer[bar]=Open[bar];
         UpDiapazonBuffer[bar+3]=High[bar+3];
        }
      if(Low[bar+3]<Low[bar+3+1] && Low[bar+3]<Low[bar+3+2] && Low[bar+3]<Low[bar+3-1] && Low[bar+3]<Low[bar+3-2])
        {
         dDownSignalBuffer[bar]=High[bar]+Point3;
         dDownFractalsBuffer[bar+3]=Low[bar+3];
         DnDiapazonBuffer[bar]=Open[bar];
         DnDiapazonBuffer[bar+3]=Low[bar+3];
         continue;
        }
      //----6 bars Fractal
      if(High[bar+3]==High[bar+3+1] && High[bar+3]>High[bar+3+2] && High[bar+3]>High[bar+3+3] && High[bar+3]>High[bar+3-1] && High[bar+3]>High[bar+3-2])
        {
         dUpSignalBuffer[bar]=Low[bar]-Point3;
         dUpFractalsBuffer[bar+3]=High[bar+3];
         UpDiapazonBuffer[bar]=Open[bar];
         UpDiapazonBuffer[bar+3]=High[bar+3];
        }
      if(Low[bar+3]==Low[bar+3+1] && Low[bar+3]<Low[bar+3+2] && Low[bar+3]<Low[bar+3+3] && Low[bar+3]<Low[bar+3-1] && Low[bar+3]<Low[bar+3-2])
        {
         dDownSignalBuffer[bar]=High[bar]+Point3;
         dDownFractalsBuffer[bar+3]=Low[bar+3];
         DnDiapazonBuffer[bar]=Open[bar];
         DnDiapazonBuffer[bar+3]=Low[bar+3];
         continue;
        }
      //----7 bars Fractal
      if(High[bar+3]>=High[bar+3+1] && High[bar+3]==High[bar+3+2] && High[bar+3]>High[bar+3+3] && High[bar+3]>High[bar+3+4] && High[bar+3]>High[bar+3-1] && 
         High[bar+3]>High[bar+3-2])
        {
         dUpSignalBuffer[bar]=Low[bar]-Point3;
         dUpFractalsBuffer[bar+3]=High[bar+3];
         UpDiapazonBuffer[bar]=Open[bar];
         UpDiapazonBuffer[bar+3]=High[bar+3];
        }
      if(Low[bar+3]<=Low[bar+3+1] && Low[bar+3]==Low[bar+3+2] && Low[bar+3]<Low[bar+3+3] && Low[bar+3]<Low[bar+3+4] && Low[bar+3]<Low[bar+3-1] && 
         Low[bar+3]<Low[bar+3-2])
        {
         dDownSignalBuffer[bar]=High[bar]+Point3;
         dDownFractalsBuffer[bar+3]=Low[bar+3];
         DnDiapazonBuffer[bar]=Open[bar];
         DnDiapazonBuffer[bar+3]=Low[bar+3];
         continue;
        }
      //----8 bars Fractal                          
      if(High[bar+3]>=High[bar+3+1] && High[bar+3]==High[bar+3+2] && High[bar+3]==High[bar+3+3] && High[bar+3]>High[bar+3+4] && High[bar+3]>High[bar+3+5] && 
         High[bar+3]>High[bar+3-1] && High[bar+3]>High[bar+3-2])
        {
         dUpSignalBuffer[bar]=Low[bar]-Point3;
         dUpFractalsBuffer[bar+3]=High[bar+3];
         UpDiapazonBuffer[bar]=Open[bar];
         UpDiapazonBuffer[bar+3]=High[bar+3];
        }
      if(Low[bar+3]<=Low[bar+3+1] && Low[bar+3]==Low[bar+3+2] && Low[bar+3]==Low[bar+3+3] && Low[bar+3]<Low[bar+3+4] && Low[bar+3]<Low[bar+3+5] && 
         Low[bar+3]<Low[bar+3-1] && Low[bar+3]<Low[bar+3-2])
        {
         dDownSignalBuffer[bar]=High[bar]+Point3;
         dDownFractalsBuffer[bar+3]=Low[bar+3];
         DnDiapazonBuffer[bar]=Open[bar];
         DnDiapazonBuffer[bar+3]=Low[bar+3];
         continue;
        }
      //----9 bars Fractal                                        
      if(High[bar+3]>=High[bar+3+1] && High[bar+3]==High[bar+3+2] && High[bar+3]>=High[bar+3+3] && High[bar+3]==High[bar+3+4] && High[bar+3]>High[bar+3+5] && 
         High[bar+3]>High[bar+3+6] && High[bar+3]>High[bar+3-1] && High[bar+3]>High[bar+3-2])
        {
         dUpSignalBuffer[bar]=Low[bar]-Point3;
         dUpFractalsBuffer[bar+3]=High[bar+3];
         UpDiapazonBuffer[bar]=Open[bar];
         UpDiapazonBuffer[bar+3]=High[bar+3];
        }
      if(Low[bar+3]<=Low[bar+3+1] && Low[bar+3]==Low[bar+3+2] && Low[bar+3]<=Low[bar+3+3] && Low[bar+3]==Low[bar+3+4] && Low[bar+3]<Low[bar+3+5] && 
         Low[bar+3]<Low[bar+3+6] && Low[bar+3]<Low[bar+3-1] && Low[bar+3]<Low[bar+3-2])
        {
         dDownSignalBuffer[bar]=High[bar]+Point3;
         dDownFractalsBuffer[bar+3]=Low[bar+3];
         DnDiapazonBuffer[bar]=Open[bar];
         DnDiapazonBuffer[bar+3]=Low[bar+3];
         continue;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
