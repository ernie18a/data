//+------------------------------------------------------------------+
//|                                        Rj_SlidingRange_Cloud.mq5 |
//|                            Copyright © 2011,RJ Rjabkov Alexander |
//|                                                     rj-a@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011,RJ Rjabkov Alexander"
#property link      "rj-a@mail.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 11
#property indicator_buffers 11 
//---- использовано всего 7 графических построений
#property indicator_plots   7
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style1  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Rj_SlidingRange middle line"

//+--------------------------------------------+
//|  Параметры отрисовки индикатора BB уровней |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- выбор цветов уровней
#property indicator_color2 clrRed
#property indicator_color3 clrRed
//---- уровни - штрихпунктирные кривые
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- толщина уровней равна 1
#property indicator_width2  1
#property indicator_width3  1
//---- отображение меток уровней Боллинджера
#property indicator_label2  "Upper Rj_SlidingRange line"
#property indicator_label3  "Lower Rj_SlidingRange line"

//+--------------------------------------------+
//|  Параметры отрисовки фона                  |
//+--------------------------------------------+
//---- отрисовка фона в облачном виде
#property indicator_type4   DRAW_FILLING
#property indicator_type5   DRAW_FILLING
#property indicator_type6   DRAW_FILLING
#property indicator_type7   DRAW_FILLING
//---- выбор цветов фона
#property indicator_color4  clrAquamarine
#property indicator_color5  clrPaleTurquoise
#property indicator_color6  clrWheat
#property indicator_color7  clrLightPink
//---- отображение меток уровней Боллинджера
#property indicator_label4  "Upper Rj_SlidingRange Cloud Out"
#property indicator_label5  "Upper Rj_SlidingRange Cloud In"
#property indicator_label6  "Lower Rj_SlidingRange Cloud In"
#property indicator_label7  "Lower Rj_SlidingRange Cloud Out"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint CalcPeriodRange=5;
input int Shift=0;  // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов уровней Боллинджера
double ExtLineBuffer0[];
double ExtLineBuffer1[],ExtLineBuffer2[];
double ExtLineBuffer3[],ExtLineBuffer4[];
double ExtLineBuffer5[],ExtLineBuffer6[];
double ExtLineBuffer7[],ExtLineBuffer8[];
double ExtLineBuffer9[],ExtLineBuffer10[];

//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Rj_SlidingRange Channel indicator initialization function        | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация констант
   min_rates_total=int(CalcPeriodRange+1);   
   
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer6,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer7,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer8,INDICATOR_DATA);
   SetIndexBuffer(9,ExtLineBuffer9,INDICATOR_DATA);
   SetIndexBuffer(10,ExtLineBuffer10,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(6,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer0,true);
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);
   ArraySetAsSeries(ExtLineBuffer7,true);
   ArraySetAsSeries(ExtLineBuffer8,true);
   ArraySetAsSeries(ExtLineBuffer9,true);
   ArraySetAsSeries(ExtLineBuffer10,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Rj_SlidingRange(",CalcPeriodRange,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Rj_SlidingRange Channel iteration function                       | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных
   int limit;
   double upper,lower,midlle,range;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчёта только новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int iii=bar+int(CalcPeriodRange)-1;
      double b1=0,b2=0;
      while(iii>=bar)
        {
         b1+=High[ArrayMaximum(High,iii,CalcPeriodRange)];
         b2+=Low[ArrayMinimum(Low,iii,CalcPeriodRange)];
         iii--;
        }
        
      upper=ExtLineBuffer1[bar]=b1/CalcPeriodRange;
      lower=ExtLineBuffer2[bar]=b2/CalcPeriodRange;     
      midlle=ExtLineBuffer0[bar]=NormalizeDouble((upper+lower)/2,_Digits);
      range=100*(upper-lower)/2;
      
      ExtLineBuffer3[bar]=midlle+range;
      ExtLineBuffer4[bar]=upper;
           
      ExtLineBuffer5[bar]=upper;
      ExtLineBuffer6[bar]=midlle;
      
      
      ExtLineBuffer7[bar]=midlle;
      ExtLineBuffer8[bar]=lower;
      
      ExtLineBuffer9[bar]=lower;
      ExtLineBuffer10[bar]=midlle-range;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
