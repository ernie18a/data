//+------------------------------------------------------------------+
//|                             LGP_Ivanoff_Maloma-Demark_levels.mq5 |
//|                                            Copyright © 2006, LGP |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, LGP" 
#property link      "https://www.metaquotes.net" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 4
#property indicator_buffers 4
//---- использовано всего четыре графических построения
#property indicator_plots   4
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
//---- в качестве окраски индикатора использован LimeGreen
#property indicator_color2 clrLimeGreen
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
//---- в качестве цвета бычей линии индикатора использован цвет Magenta
#property indicator_color3  clrMagenta
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
//---- в качестве цвета медвежьей линии индикатора использован цвет Blue
#property indicator_color4  clrBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Signal Down"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint width_H_L=0;
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtMapBuffer1[],ExtMapBuffer2[],ExtMapBuffer3[],ExtMapBuffer4[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
double P;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=6;
   if(Period()>=PERIOD_D1) P=15*_Point;
   else if(Period()>=PERIOD_H4) P=7*_Point;
   else if(Period()>=PERIOD_H1) P=4*_Point;
   else if(Period()>=PERIOD_M30) P=3*_Point;
   else if(Period()>=PERIOD_M15) P=2*_Point;
   else if(Period()>=PERIOD_M5) P=1*_Point;
   if(Period()==PERIOD_M1) P=0.5*_Point;

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"LGP_Ivanoff_Maloma-Demark_levels(",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,217);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBuffer1,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtMapBuffer3,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBuffer3,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtMapBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBuffer2,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,217);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtMapBuffer4,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBuffer4,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,218);
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
   int limit=rates_total-min_rates_total-3;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Close,true);

//---- High
   for(int bar=1; bar<=limit && !IsStopped(); bar++)
     {
      ExtMapBuffer1[bar]=NULL;
      ExtMapBuffer2[bar]=NULL;

      int j=bar;
      for(int k=bar; k<=rates_total-2; k++)
        {
         if(Close[j+1]!=Close[bar])
            break;
         j++;
        }
      //----    
      if(Close[bar]>Close[bar-1] && Close[bar]>Close[j+1] && Close[j+1]>Close[j+2])
        {
         if(Close[bar]>High[bar-1]) ExtMapBuffer2[bar-1]=Close[bar-1]+P;
         else ExtMapBuffer1[bar]=High[bar]+P;
        }
      //----
      bar=j;
     }
//---- Low  
   for(int bar=1; bar<=limit && !IsStopped(); bar++)
     {
      ExtMapBuffer3[bar]=NULL;
      ExtMapBuffer4[bar]=NULL;

      int j=bar;
      for(int k=bar; k<=rates_total-2; k++)
        {
         if(Close[j+1]!=Close[bar])
            break;
         j++;
        }
      //----  
      if(Close[bar]<Close[bar-1] && Close[bar]<Close[j+1] && Close[j+1]<Close[j+2])
        {
         if(Close[bar]<Low[bar-1]) ExtMapBuffer4[bar-1]=Close[bar-1]-P;
         else ExtMapBuffer3[bar]=Low[bar]-P;
        }
      //----
      bar=j;
     }

   ExtMapBuffer1[0]=NULL;
   ExtMapBuffer2[0]=NULL;
   ExtMapBuffer3[0]=NULL;
   ExtMapBuffer4[0]=NULL;
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
