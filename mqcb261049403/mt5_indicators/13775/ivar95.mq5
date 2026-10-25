//+------------------------------------------------------------------+
//|                                                      i-VaR95.mq5 |
//|                                       Copyright © 2009, piccioli | 
//|                                    http://piccstick.blogspot.com |
//+------------------------------------------------------------------+
//| Индикатор отображает значение исторической волатильности         |
//| Возможен расчет волатильности несколькими методами               |
//|  - Simple Historical Volatility                                  |
//|  - Exponential Historical Volatility                             |
//|  - High-Low Historical Volatility                                |
//|                                                                  |  
//| Несколько замечаний:                                             |
//| 1. Данный индикатор не показывает точек входа в рынок            |
//|    и выхода из него                                              |
//| 2. Картинка индикатора похожа на картинку изветного ATR, особенно|
//|    при расчете методом Паркинсона, значения, тем не менее, разные|
//| 3. Для расчета VaR используется 95-процентная вероятность,       |
//|    то есть индикатор отображает значение в пунктах (без учета    | 
//|    5-го символа), которое может быть достигнуто ценой с          |
//|    вероятностью 5% за период, равный инвестиционному             |
//|    горизонту (grznt)                                             |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, piccioli@gmail.com"
#property link      "http://piccstick.blogspot.com"
//----
#property description "Индикатор отображает значение исторической волатильности"
#property description "Несколько замечаний: "
#property description "1. Данный индикатор не показывает точек входа в рынок и выхода из него"
#property description "2. Картинка индикатора похожа на картинку изветного ATR, особенно|"
#property description "   при расчете методом Паркинсона, значения, тем не менее, разные"
#property description "3. Для расчета VaR используется 95-процентная вероятность,"
#property description "   то есть индикатор отображает значение в пунктах, которое может быть достигнуто ценой"
#property description "   с вероятностью 5% за период, равный инвестиционному горизонту (grznt)"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде трехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов  использованы
#property indicator_color1 clrGray,clrIndianRed,clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "HistVolatility"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum MODE //тип константы
  {
   SHV = 1,     //Simple Historical Volatility
   EHV,         //Exponential Historical Volatility
   HLHV,        //High-Low Historical Volatility
   VaR95        //95-процентный VaR
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int HV_Period = 21;     // Период расчета исторической волатильности
input MODE Mode=SHV;          // Метод расчета      
input double decline=0.94;    // Коэффициент сглаживания
                              // традиционно принимается равным 0.94
                              // данный параметр влияет только на экспоненциально-взвешенный метод
input int grznt=3;            // Инвестиционный горизонт для вычисления 95% VaR
input int Shift=0;            // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- индикаторные буферы
double LineBuffer[],ColorLineBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| HistVolatility initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=HV_Period+1;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LineBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorLineBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorLineBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Historical Volatility(",HV_Period,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| HistVolatility iteration function                                | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
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
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int limit,bar;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(spread,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)LineBuffer[bar]=HistoricalVolatility(Mode,low,high,close,spread,bar);
//----
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorLineBuffer[bar]=0;
      if(LineBuffer[bar]>LineBuffer[bar+1]) ColorLineBuffer[bar]=2;
      if(LineBuffer[bar]<LineBuffer[bar+1]) ColorLineBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+
double HistoricalVolatility(MODE mode,const double &Low[],const double &High[],const double &Close[],const int &Spread[],int index)
  {
//----
   int start=int(HV_Period+index-1);
//----
   switch(mode)
     {
      case SHV:
        {
         double tshv=0;
         for(int i=start; i>=index; i--) tshv+=MathLog(Close[i+1]/Close[i+1]);
         tshv/=HV_Period;

         double shv=0;
         for(int i=start; i>=index; i--) shv+=(tshv -(MathLog(Close[i]/Close[i+1])))*(tshv -(MathLog(Close[i]/Close[i+1])));
         return(MathSqrt(shv/(HV_Period-1)));
        }
      //----
      case EHV:
        {
         double tshv=0;
         for(int i=start; i>=index; i--) tshv+=MathLog(Close[i+1]/Close[i+1]);
         tshv/=HV_Period;

         double shv=0;
         for(int i=start; i>=index; i--) shv+=(tshv -(MathLog(Close[i]/Close[i+1])))*(tshv -(MathLog(Close[i]/Close[i+1])));
         shv=MathSqrt(shv/(HV_Period-1));
         double ehv=MathSqrt((1-decline)*shv);
        }
      //----
      case HLHV:
        {
         double hlhv=0;
         for(int i=start; i>=index; i--) hlhv+=(MathLog(High[i]/Low[i])*MathLog(High[i]/Low[i]))/(4*MathLog(2));
         return(MathSqrt(hlhv/HV_Period));
        }
      //----
      case VaR95:
        {
         double tshv=0;
         for(int i=start; i>=index; i--) tshv+=MathLog(Close[i+1]/Close[i+1]);
         tshv/=HV_Period;
         //----
         double shv=0;
         for(int i=start; i>=index; i--) shv+=(tshv -(MathLog(Close[i]/Close[i+1])))*(tshv -(MathLog(Close[i]/Close[i+1])));
         shv=MathSqrt(shv/(HV_Period-1));
         return(1.65 *(shv)*10000*MathSqrt(grznt)+2*Spread[index]);
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
