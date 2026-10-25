//+------------------------------------------------------------------+
//|                                LinearRegressionChannel_Cloud.mq5 | 
//|                                         Copyright © 2008, dimicr | 
//|                                         http://www.signalsbg.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, dimicr"
#property link "http://www.signalsbg.com"
#property description "Канал линейной регрессии с сохранением своих значений в индикаторных буферах и с цветным фоновым заполнением канала"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 7
#property indicator_buffers 7 
//---- использовано всего 5 графических построений
#property indicator_plots   5
//+----------------------------------------------+
//| Параметры отрисовки верхнего облака          |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет PaleGreen
#property indicator_color1 clrPaleGreen
//---- отображение метки индикатора
#property indicator_label1  "LinearRegressionChannel_Cloud Upper"
//+----------------------------------------------+
//| Параметры отрисовки нижнего облака           |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет Pink
#property indicator_color2 clrPink
//---- отображение метки индикатора
#property indicator_label2  "LinearRegressionChannel_Cloud Lower"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color3 clrBlueViolet
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style3  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "LinearRegression Line"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора уровней      |
//+----------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//---- выбор цветов линий
#property indicator_color4  clrTeal
#property indicator_color5  clrRed
//---- линии- штрихпунктирные кривые
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
//---- толщина линий равна 1
#property indicator_width4  1
#property indicator_width5  1
//---- отображение меток линий
#property indicator_label4  "LinearRegression Resistance"
#property indicator_label5  "LinearRegression Support"
//+----------------------------------------------+
//|  объявление перечисления                     |
//+----------------------------------------------+
enum ENUM_USER_PRICE
  {
   MODE_CLOSE_,    //Используем close
   MODE_HIGH_LOW  //Используем high и low
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input ENUM_USER_PRICE UserPrice=MODE_CLOSE_; //Вариант цен
input uint  barsToCount=100;  //Количество баров для расчёта
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double LineBuffer[],ResBuffer[],SupBuffer[];
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| LinearRegression indicator initialization function               | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(barsToCount);

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
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LineBuffer,true);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(5,ResBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,SupBuffer,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ResBuffer,true);
   ArraySetAsSeries(SupBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"LinearRegression(",EnumToString(UserPrice),", ",barsToCount,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| LinearRegression iteration function                              | 
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

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   int DRAW_BEGIN=rates_total-min_rates_total+1;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DRAW_BEGIN);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,DRAW_BEGIN);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,DRAW_BEGIN);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,DRAW_BEGIN);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,DRAW_BEGIN);

//---- Объявление переменных с плавающей точкой  
   double a,b,c,res,
   sumy=0.0,
   sumx=0.0,
   sumxy=0.0,
   sumx2=0.0,
   h=0.0,l=0.0;

//---- Объявление целых переменных
   int bar,limit;

//---- расчёты стартового номера limit для цикла стирания баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1;
     }
   else limit=rates_total-prev_calculated;

//---- стираем уже ненужные данные
   for(bar=limit+min_rates_total; bar>min_rates_total && !IsStopped(); bar--)
     {
      LineBuffer[bar]=NULL;
      SupBuffer[bar]=NULL;
      ResBuffer[bar]=NULL;

      UpUpBuffer[bar]=NULL;
      UpDnBuffer[bar]=NULL;
      DnUpBuffer[bar]=NULL;
      DnDnBuffer[bar]=NULL;
     }

   for(bar=0; bar<min_rates_total; bar++)
     {
      sumy+=close[bar];
      sumxy+=close[bar]*bar;
      sumx+=bar;
      sumx2+=bar*bar;
     }
//----
   c=sumx2*barsToCount-sumx*sumx;

   if(!c)
     {
      Alert("Error in linear regression!");
      return(0);
     }

//---- Line equation    
   b=(sumxy*barsToCount-sumx*sumy)/c;
   a=(sumy-sumx*b)/barsToCount;

//---- Linear regression line in buffer
   for(bar=0; bar<min_rates_total; bar++) LineBuffer[bar]=UpDnBuffer[bar]=DnUpBuffer[bar]=a+b*bar;

//---- Use PRICE_CLOSE for support-resistance
   if(UserPrice==MODE_CLOSE_)
      for(bar=0; bar<min_rates_total; bar++)
        {
         h=MathMax(h,close[bar]-LineBuffer[bar]);
         l=MathMax(l,LineBuffer[bar]-close[bar]);
        }
//---- Use HIGH - LOW
   else
   for(bar=0; bar<min_rates_total; bar++)
     {
      h=MathMax(h,high[bar]-LineBuffer[bar]);
      l=MathMax(l,LineBuffer[bar]-low[bar]);
     }

//----  Drawing support - resistance lines   
   if(h>l) res=h;
   else res=l;

   for(bar=0; bar<min_rates_total; bar++)
     {
      SupBuffer[bar]=DnDnBuffer[bar]=a-res+b*bar;
      ResBuffer[bar]=UpUpBuffer[bar]=a+res+b*bar;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
