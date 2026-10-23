//+------------------------------------------------------------------------------------------------------------------+
//|                                                                              fractal_dimension.mq5               |
//|                                                                              Copyright © 2011, iliko             |
//|                                                                              arcsin5@netscape.net                |
//|                                                                                                                  |
//|  The Fractal Dimension Index determines the amount of market volatility. The easiest way to use this indicator is|
//|  to understand that a value of 1.5 suggests the market is acting in a completely random fashion.                 |
//|  As the market deviates from 1.5, the opportunity for earning profits is increased in proportion                 |
//|  to the amount of deviation.                                                                                     |
//|  But be carreful, the indicator does not show the direction of trends !!                                         |
//|                                                                                                                  |
//|  The indicator is red when the market is in a trend. And it is blue when there is a high volatility.             |
//|  When the FDI changes its color from red to blue, it means that a trend is finishing, the market becomes         |
//|  erratic and a high volatility is present. Usually, these "blue times" do not go for a long time.They come before|
//|  a new trend.                                                                                                    |
//|                                                                                                                  |
//|  For more informations, see                                                                                      |
//|  http://www.forex-tsd.com/suggestions-trading-systems/6119-tasc-03-07-fractal-dimension-index.html               |
//|                                                                                                                  |
//|                                                                                                                  |   
//|  HOW TO USE INPUT PARAMETERS :                                                                                   |   
//|  -----------------------------                                                                                   |   
//|                                                                                                                  |   
//|      1) e_period [ integer >= 1 ]                                              =>  30                            |   
//|                                                                                                                  |   
//|         The indicator will compute the historical market volatility over this period.                            |   
//|         Choose its value according to the average of trend lengths.                                              |   
//|                                                                                                                  |   
//|      2) e_type_data [ int = {PRICE_CLOSE_ = 1,     //Close                                                       |
//|                              PRICE_OPEN_,          //Open                                                        |
//|                              PRICE_HIGH_,          //High                                                        |
//|                              PRICE_LOW_,           //Low                                                         |
//|                              PRICE_MEDIAN_,        //Median Price (HL/2)                                         |
//|                              PRICE_TYPICAL_,       //Typical Price (HLC/3)                                       |
//|                              PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)                                     |
//|                              PRICE_SIMPL_,         //Simpl Price (OC/2)                                          |
//|                              PRICE_QUARTER_,       //Quarted Price (HLOC/4)                                      |
//|                              PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price                                         |
//|                              PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price                                         |
//|                              PRICE_DEMARK_         //Demark Price}     => PRICE_CLOSE                            |   
//|                                                                                                                  |   
//|         Defines on which price type the Fractal Dimension is computed.                                           |   
//|                                                                                                                  |
//|      3) e_random_line [ 0.0 < double < 2.0 ]                                   => 1.5                            |
//|                                                                                                                  |
//|         Defines your separation betwen a trend market (red) and an erratic/high volatily one.                    |   
//|                                                                                                                  |   
//| v1.0 - February 2007                                                                                             |   
//+------------------------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2011, iliko"
#property link "arcsin5@netscape.net"
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
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrRed,clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "fractal_dimension"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint                e_period=30;          // Период усреднения
input Applied_price_   e_type_data=PRICE_CLOSE; // Ценовая константа
input double         e_random_line=1.5;         // Уровень срабатывания
input int                    Shift=0;           // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double Price[];
double Log2,Log2e,Pow2e;
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+   
//| fractal_dimension indicator initialization function              | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(e_period);
   Log2e=MathLog(2*e_period);
   Pow2e=1.0/MathPow(e_period,2.0);
   Log2=MathLog(2.0);
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,e_period);
   ArrayResize(Price,e_period);
//----
   ArrayInitialize(Count,0);
   ArrayInitialize(Price,0.0);
//---- индексация элементов в массиве как в таймсерии
   ArraySetAsSeries(Price,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"fractal_dimension(",
                     e_period,", ",EnumToString(e_type_data),", ",
                     DoubleToString(e_random_line,4),", ",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- количество  горизонтальных уровней индикатора 1  
   IndicatorSetInteger(INDICATOR_LEVELS,1);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,e_random_line);
//---- в качестве цвета линии горизонтального уровня использован Purple цвет  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrPurple);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| fractal_dimension iteration function                             | 
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
//---- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- объявление переменных с плавающей точкой  
   double HH,LL,diff,priorDiff,length,fdi,Range;
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int limit,bar,iii,clr;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      limit=rates_total-1;   // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Price[Count[0]]=PriceSeries(e_type_data,bar,open,low,high,close);
      HH=high[ArrayMaximum(high,bar,e_period)];
      LL=low[ArrayMinimum(low,bar,e_period)];
      Range=HH-LL;
      length=0.0;
      priorDiff=0.0;
      //----
      if(Range) for(iii=0; iii<int(e_period); iii++)
        {
         diff=(Price[Count[iii]]-LL)/Range;
         length+=MathSqrt(MathPow(diff-priorDiff,2.0)+Pow2e);
         priorDiff=diff;
        }
      //----
      if(length>0.0) fdi=1.0+(MathLog(length)+Log2)/Log2e;
      else
        {
         //---- The FDI algorithm suggests in this case a zero value. I prefer to use the previous FDI value.
         fdi=0.0;
        }
      //----
      IndBuffer[bar]=fdi;
      if(bar) Recount_ArrayZeroPos(Count,e_period);
     }
//---- корректировка значения переменной limit
   if(prev_calculated>rates_total || prev_calculated<=0) limit-=min_rates_total;
//---- основной цикл раскраски сигнальной линии
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(IndBuffer[bar]>=e_random_line) clr=1;
      else clr=0;
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,  // ценовая константа
                   uint bar,            // индекс сдвига относительно текущего бара на указанное количество периодов назад или вперед
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[]
                   )
  {
//----
   switch(applied_price)
     {
      //---- ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);
      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----         
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];

         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
