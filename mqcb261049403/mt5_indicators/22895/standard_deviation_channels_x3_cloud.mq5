//+------------------------------------------------------------------+
//|                         Standard_Deviation_Channels_x3_Cloud.mq5 | 
//|                                       Copyright © 2009, Stajer59 | 
//|                                      http://www.stajer59.ucoz.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Stajer59"
#property link "http://www.stajer59.ucoz.ru"
#property description "Индикатор трёх каналов стандартной девиации"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 11
#property indicator_buffers 11 
//---- использовано всего девять графических построений
#property indicator_plots   9
//+----------------------------------------------+
//| Параметры отрисовки верхнего облака          |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет 221,255,242
#property indicator_color1 C'221,255,242'
//---- отображение метки индикатора
#property indicator_label1  "Standard_Deviation_Channels_x3 Upper"
//+----------------------------------------------+
//| Параметры отрисовки нижнего облака           |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет 255,234,255
#property indicator_color2 C'255,234,255'
//---- отображение метки индикатора
#property indicator_label2  "Standard_Deviation_Channels_x3 Lower"
//+--------------------------------------------+
//|  Параметры отрисовки индикатора            |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован DarkViolet цвет
#property indicator_color3 clrDarkViolet
//---- линия индикатора - сплошная линия
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "Standard_Deviation_Channels Middle Line"

//+--------------------------------------------+
//|  Параметры отрисовки индикатора уровней    |
//+--------------------------------------------+
//---- отрисовка уровней канала в виде линий
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
#property indicator_type9   DRAW_LINE
//---- выбор цветов уровней канала
#property indicator_color4  clrMediumSpringGreen
#property indicator_color5  clrMediumSeaGreen
#property indicator_color6  clrTeal
#property indicator_color7  clrMediumVioletRed
#property indicator_color8  clrRed
#property indicator_color9  clrGold
//---- уровни канала - штрихпунктирные кривые
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
#property indicator_style7 STYLE_SOLID
#property indicator_style8 STYLE_SOLID
#property indicator_style9 STYLE_SOLID
//---- толщина уровней канала равна 3
#property indicator_width4  3
#property indicator_width5  3
#property indicator_width6  3
#property indicator_width7  3
#property indicator_width8  3
#property indicator_width9  3
//---- отображение меток уровней канала
#property indicator_label4  "+3Sigma"
#property indicator_label5  "+2Sigma"
#property indicator_label6  "+1Sigma"
#property indicator_label7  "-1Sigma"
#property indicator_label8  "-2Sigma"
#property indicator_label9  "-3Sigma"
//+--------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА              |
//+--------------------------------------------+
input uint N_=240;        // количество свечей для анализа
input double StdDev1=1.0; // девиация первого канала
input double StdDev2=1.5; // девиация второго канала
input double StdDev3=2.0; // девиация третьего канала
input int Shift=0;        // сдвиг индикатора по горизонтали в барах
input int PriceShift=0;   // cдвиг индикатора по вертикали в пунктах
//+--------------------------------------------+
//---- объявление динамического массива, который будет в дальнейшем использован в качестве индикаторного буфера
double LineBuffer[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов фонового заполнения
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов уровней
double ExtLineBuffer1[],ExtLineBuffer2[],ExtLineBuffer3[];
double ExtLineBuffer4[],ExtLineBuffer5[],ExtLineBuffer6[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,N;
//+------------------------------------------------------------------+   
//| Standard_Deviation_Channels_x3 indicator initialization function | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   N=int(N_);
   min_rates_total=N;

//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpUpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpUpBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpDnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpDnBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnUpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnUpBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnDnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnDnBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,LineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LineBuffer,true);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(5,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(8,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(9,ExtLineBuffer5,INDICATOR_DATA);
   SetIndexBuffer(10,ExtLineBuffer6,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(ExtLineBuffer3,true);
   ArraySetAsSeries(ExtLineBuffer4,true);
   ArraySetAsSeries(ExtLineBuffer5,true);
   ArraySetAsSeries(ExtLineBuffer6,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Standard_Deviation_Channels_x3_Cloud(",N,", ",
                     DoubleToString(StdDev1,2),", ",DoubleToString(StdDev2,2),", ",DoubleToString(StdDev3,2),", ",Shift,", ",PriceShift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Standard_Deviation_Channels_x3 iteration function                | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных
   int index,x,drawbegin;
   double a,b,Summ_x,Summ_y,Summ_x_2,Summ_xy,Deviation,StdDeviation,Middle_y;

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   drawbegin=rates_total-1-N;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,drawbegin);
   PlotIndexSetInteger(8,PLOT_DRAW_BEGIN,drawbegin);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(close,true);

   Summ_x=0.0;
   Summ_y=0.0;
   Summ_xy=0.0;
   Summ_x_2=0.0;

   for(x=1; x<=N && !IsStopped(); x++)
     {
      index=N-x;
      Summ_x+=x;
      Summ_y+=close[index];
      Summ_xy+=x*close[index];
      Summ_x_2+=MathPow(x,2);
     }

   b=(N*Summ_xy-Summ_x*Summ_y)/(N*Summ_x_2-MathPow(Summ_x,2));
   a=(Summ_y-b*Summ_x)/N;
   Middle_y=Summ_y/N;
   Deviation=0.0;

   for(x=0; x<N && !IsStopped(); x++)
     {
      index=N-x;
      Deviation+=MathPow((close[index]-Middle_y),2);
     }

   StdDeviation=MathSqrt(Deviation/N);
   UpUpBuffer[N]=UpDnBuffer[N]=DnUpBuffer[N]=DnDnBuffer[N]=NULL;
   ExtLineBuffer1[N]=ExtLineBuffer2[N]=ExtLineBuffer3[N]=EMPTY_VALUE;
   ExtLineBuffer4[N]=ExtLineBuffer5[N]=ExtLineBuffer6[N]=EMPTY_VALUE;
   LineBuffer[N]=EMPTY_VALUE;

   for(x=0; x<=N && !IsStopped(); x++)
     {
      index=N-x;
      double res=b*x+a;
      LineBuffer[index]=UpDnBuffer[index]=DnUpBuffer[index]=res+dPriceShift;
      ExtLineBuffer3[index]=res+StdDev1*StdDeviation+dPriceShift;
      ExtLineBuffer4[index]=res-StdDev1*StdDeviation+dPriceShift;
      ExtLineBuffer2[index]=res+StdDev2*StdDeviation+dPriceShift;
      ExtLineBuffer5[index]=res-StdDev2*StdDeviation+dPriceShift;
      ExtLineBuffer1[index]=res+StdDev3*StdDeviation+dPriceShift;
      ExtLineBuffer6[index]=res-StdDev3*StdDeviation+dPriceShift;
      UpUpBuffer[index]=MathMax(MathMax(ExtLineBuffer3[index],ExtLineBuffer2[index]),ExtLineBuffer1[index]);
      DnDnBuffer[index]=MathMin(MathMin(ExtLineBuffer6[index],ExtLineBuffer5[index]),ExtLineBuffer4[index]);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
