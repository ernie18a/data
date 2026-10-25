//+------------------------------------------------------------------+
//|                                               Fractal_Levels.mq5 |
//|                                        Copyright © 2008, lotos4u | 
//|                                            lotos4u@gmail.com     | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, lotos4u" 
#property link      "lotos4u@gmail.com" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего четыре графических построения
#property indicator_plots   4

//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован цвет DodgerBlue
#property indicator_color1  clrDodgerBlue
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение бычьей метки индикатора
#property indicator_label1  "Фрактальное сопротивление"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован цвет Orchid
#property indicator_color2  clrOrchid
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Фрактальная поддержка"

//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type3 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color3 clrLime
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width3 1
//---- отображение метки сигнальной линии
#property indicator_label3  "Фрактал ВЕРХ"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type4 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color4 clrRed
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width4 1
//---- отображение метки сигнальной линии
#property indicator_label4  "Фрактал ВНИЗ"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint LeftBars  = 3;
input uint RightBars = 3;
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double LineUp[],LineDown[];
double SignUp[];
double SignDown[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(LeftBars+RightBars);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Fractal_Levels(",string(LeftBars),", ",string(RightBars),", ",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,LineUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(LineUp,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,LineDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(LineDown,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,SignUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignUp,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,167);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,SignDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignDown,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,167);
   
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,bar;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SignUp[bar]=isFractalUp(bar,LeftBars,RightBars,rates_total,high);
      SignDown[bar]=isFractalDown(bar,LeftBars,RightBars,rates_total,low);
      if(SignUp[bar]) LineUp[bar]=SignUp[bar];
      else LineUp[bar]=LineUp[bar+1];
      if(SignDown[bar]) LineDown[bar]=SignDown[bar];
      else LineDown[bar]=LineDown[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double isFractalUp(int index,int lBars,int rBars,const int Rates_Total,const double& High[])
  {
   int left=MathMin(Rates_Total-1,index+lBars),right=MathMax(0,index-rBars);
   double max=High[index];
   for(int iii=right; iii<=left; iii++)
     {
      if(max<=High[iii] && iii!=index)
        {
         if(max<High[iii]) return(0);
         if(MathAbs(iii-index)>1) return(0);
        }
     }
//----     
   return(max);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double isFractalDown(int index,int lBars,int rBars,const int Rates_Total,const double& Low[])
  {
   int left=MathMin(Rates_Total-1,index+lBars),right=MathMax(0,index-rBars);
   double min= Low[index];
   for(int iii=right; iii<=left; iii++)
     {
      if(min>=Low[iii] && iii!=index)
        {
         if(min>Low[iii]) return(0);
         if(MathAbs(iii-index)>1) return(0);
        }
     }
//----     
   return(min);
  }
//+------------------------------------------------------------------+
