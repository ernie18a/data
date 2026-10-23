//+------------------------------------------------------------------+
//|                                   wajdyss_Ichimoku_Indicator.mq5 |
//|                                        Copyright © 2009, Wajdyss |
//|                                                wajdyss@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Wajdyss"
#property link "wajdyss@yahoo.com"
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего 5 графических построений
#property indicator_plots   3
//+--------------------------------------------+
//|  Параметры отрисовки индикатора            |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован SlateBlue цвет
#property indicator_color1 clrSlateBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение лэйбы индикатора
#property indicator_label1  "Kijun Sen"
//+--------------------------------------------+
//|  Параметры отрисовки индикатора уровней    |
//+--------------------------------------------+
//---- отрисовка уровней в виде значков
#property indicator_type2   DRAW_ARROW
#property indicator_type3   DRAW_ARROW
//---- выбор цветов уровней
#property indicator_color2  clrLimeGreen
#property indicator_color3  clrDeepPink
//---- толщина уровней равна 5
#property indicator_width2  5
#property indicator_width3  5
//---- отображение меток уровней
#property indicator_label2  "Buy wajdyss_Ichimoku"
#property indicator_label3  "Sell wajdyss_Ichimoku"
//+--------------------------------------------+
//|  объявление констант                       |
//+--------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+--------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА              |
//+--------------------------------------------+
input uint Kijun=26;
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+--------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов уровней Боллинджера
double ExtLineBuffer0[],BuyBuffer[],SellBuffer[];
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| CandleStop initialization function                               | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(Kijun);
   int ATR_Period=15;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+1;
   
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtLineBuffer0,true);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);

//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
   
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(BuyBuffer,true);  
   ArraySetAsSeries(SellBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"wajdyss_Ichimoku_Indicator");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| CandleStop iteration function                                    | 
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double ATR[],kijun,kijun_prev,price,High,Low;
//---- Объявление целых переменных и получение
   int limit,bar,to_copy;
  
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
   
//---- индексация элементов в массивах, как в таймсериях 
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true); 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   
//--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=NULL;
      SellBuffer[bar]=NULL;
      //----
      High=high[bar];
      Low=low[bar];
      int index=bar+int(Kijun)-1;
      while(index>bar)
        {
         price=high[index];
         if(High<price) High=price;
         price=low[index];
         if(Low>price) Low=price;
         index--;
        }
      //----  
      ExtLineBuffer0[bar]=kijun=(High+Low)/2;
      kijun_prev=ExtLineBuffer0[bar+1];
      //----
      if(close[bar]>=kijun && close[bar+1]<kijun_prev) BuyBuffer[bar]=low[bar]-ATR[bar]*3/16;
      else if(close[bar]<=kijun && close[bar+1]>kijun_prev) SellBuffer[bar]=high[bar]+ATR[bar]*3/16;
     }
//----  
   return(rates_total);
  }
//+------------------------------------------------------------------+
