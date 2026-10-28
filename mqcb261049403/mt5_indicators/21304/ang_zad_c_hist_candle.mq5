//+------------------------------------------------------------------+
//|                                        Ang_Zad_C_Hist_Candle.mq5 | 
//|                                        Copyright © 2018, ANG3110 | 
//|                                             ANG3110@latchess.com | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2018, ANG3110"
//---- авторство индикатора
#property link      "ANG3110@latchess.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора Ang_Zad_C     |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrBlue,clrDodgerBlue,clrGray,clrLightPink,clrMagenta
//---- отображение метки индикатора
#property indicator_label1  "Ang_Zad_C_Hist_Open;Ang_Zad_C_Hist_High;Ang_Zad_C_Hist_Low;Ang_Zad_C_Hist_Close"
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double ki=4.000001;  // Коэффициент усреднения индикатора 
input int Shift=0;         // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в  дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=2;

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Ang_Zad_C_Hist_Candle(",DoubleToString(ki,4),", ",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int first,bar;
   double price,price_prev,Oz,Oz2,Hz,Hz2,Lz,Lz2,Cz,Cz2;
   static double Oz_prev,Oz2_prev,Hz_prev,Hz2_prev,Lz_prev,Lz2_prev,Cz_prev,Cz2_prev;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=min_rates_total;                   // стартовый номер для расчета всех баров        
      Oz_prev=Oz2_prev=open[first-1];
      Hz_prev=Hz2_prev=high[first-1];
      Lz_prev=Lz2_prev=low[first-1];
      Cz_prev=Cz2_prev=close[first-1];
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
   
   Oz=Oz_prev;
   Oz2=Oz2_prev;
   Hz=Hz_prev;
   Hz2=Hz2_prev;
   Lz=Lz_prev;
   Lz2=Lz2_prev;
   Cz=Cz_prev;
   Cz2=Cz2_prev;

//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=open[bar];
      price_prev=open[bar-1];    
      if(price>Oz && price>price_prev) Oz=Oz_prev+(price-Oz_prev)/ki;
      if(price<Oz && price<price_prev) Oz=Oz_prev+(price-Oz_prev)/ki;
      if(price>Oz2 && price<price_prev) Oz2=Lz2_prev+(price-Oz2_prev)/ki;
      if(price<Oz2 && price>price_prev) Oz2=Cz2_prev+(price-Oz2_prev)/ki;      
      ExtOpenBuffer[bar]=(Oz-Oz2)/_Point;
      //----
      price=high[bar];
      price_prev=high[bar-1];    
      if(price>Hz && price>price_prev) Hz=Hz_prev+(price-Hz_prev)/ki;
      if(price<Hz && price<price_prev) Hz=Hz_prev+(price-Hz_prev)/ki;
      if(price>Hz2 && price<price_prev) Hz2=Lz2_prev+(price-Hz2_prev)/ki;
      if(price<Hz2 && price>price_prev) Hz2=Cz2_prev+(price-Hz2_prev)/ki;      
      ExtHighBuffer[bar]=(Hz-Hz2)/_Point;
      //----
      price=low[bar];
      price_prev=low[bar-1];    
      if(price>Lz && price>price_prev) Lz=Lz_prev+(price-Lz_prev)/ki;
      if(price<Lz && price<price_prev) Lz=Lz_prev+(price-Lz_prev)/ki;
      if(price>Lz2 && price<price_prev) Lz2=Lz2_prev+(price-Lz2_prev)/ki;
      if(price<Lz2 && price>price_prev) Lz2=Cz2_prev+(price-Lz2_prev)/ki;      
      ExtLowBuffer[bar]=(Lz-Lz2)/_Point;
      //----
      price=close[bar];
      price_prev=close[bar-1];    
      if(price>Cz && price>price_prev) Cz=Cz_prev+(price-Cz_prev)/ki;
      if(price<Cz && price<price_prev) Cz=Cz_prev+(price-Cz_prev)/ki;
      if(price>Cz2 && price<price_prev) Cz2=Lz2_prev+(price-Cz2_prev)/ki;
      if(price<Cz2 && price>price_prev) Cz2=Cz2_prev+(price-Cz2_prev)/ki;      
      ExtCloseBuffer[bar]=(Cz-Cz2)/_Point;     
      //---- исправление и окрашивание свечей
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);      
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);     
      //---- окрашивание свечей
      ExtColorsBuffer[bar]=2;
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar])
        {
         if(ExtCloseBuffer[bar-1]<=ExtCloseBuffer[bar]) ExtColorsBuffer[bar]=0;
         else ExtColorsBuffer[bar]=1;
        }
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar])
        {
         if(ExtCloseBuffer[bar-1]>=ExtCloseBuffer[bar]) ExtColorsBuffer[bar]=4;
         else ExtColorsBuffer[bar]=3;
        }
      //----  
      if(bar<rates_total-1)
        {
         Oz_prev=Oz;
         Oz2_prev=Oz2;
         Hz_prev=Hz;
         Hz2_prev=Hz2;
         Lz_prev=Lz;
         Lz2_prev=Lz2;
         Cz_prev=Cz;
         Cz2_prev=Cz2;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
