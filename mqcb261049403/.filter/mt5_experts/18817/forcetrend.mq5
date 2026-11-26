//+---------------------------------------------------------------------+
//|                                                      ForceTrend.mq5 | 
//|                                                                     | 
//|                                                                     |
//+---------------------------------------------------------------------+
#property copyright ""
#property link ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов трехцветной гистограммы использованы
#property indicator_color1  clrDodgerBlue,clrMagenta
//---- гистограммы индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ForceTrend"
//---- фиксированная высота подокна индикатора в пикселях 
#property indicator_height 15
//---- нижнее и верхнее ограничения шкалы отдельного окна индикатора
#property indicator_maximum +1.1
#property indicator_minimum +0.0
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint Length=13; //Период для поиска экстремумов                   
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
//---- Объявление целых переменных начала отсчета данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+   
//| Bears indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   min_rates_total=int(Length)+1;   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);  
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);     
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ForceTrend(",Length,", ",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Bears iteration function                                         | 
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;
   double Ind,Force1;
   static double Ind_prev,Force1_prev; 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      {
      first=min_rates_total; // стартовый номер для расчета всех баров
      Ind_prev=NULL;
      Force1_prev=NULL;
      }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- Основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int barx=rates_total-1-bar;
      double high1=high[ArrayMaximum(high,barx,Length)];
      double low1=low[ArrayMinimum(low,barx,Length)];
      double Avrg = (high[barx] + low[barx]) / 2.0;
      double Res=high1 - low1;
      if (Res) Force1 = 0.66 * ((Avrg - low1) / Res - 0.5) + 0.67 * Force1_prev;
      else Force1 = 0.67 * Force1_prev + (-0.33);
      Force1 = MathMin(MathMax(Force1, -0.999), 0.999);
      Res=1 - Force1;
      if (Res) Ind = MathLog((Force1 + 1.0) / Res) / 2.0 + Ind_prev / 2.0;
      else Ind = Ind_prev / 2.0 + 0.5;
      IndBuffer[bar]=1.0;
      //----
      if(Ind<0) ColorIndBuffer[bar]=1;
      else if(Ind>0) ColorIndBuffer[bar]=0;
      else ColorIndBuffer[bar]=ColorIndBuffer[bar-1];
      //----    
      if(bar<rates_total-1)
        {
         Force1_prev = Force1;
         Ind_prev=Ind;  
        }    
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
