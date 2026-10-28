//+------------------------------------------------------------------+
//|                                                     InOutBar.mq5 |
//|                                        Copyright © 2005, Kalenzo |
//|                                          http://www.fxservice.eu |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, Kalenzo"
//---- ссылка на сайт автора
#property link      "http://www.fxservice.eu"
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
//---- в качестве окраски индикатора использован
#property indicator_color1 clrLime
//---- толщина линии индикатора равна 1
#property indicator_width1 1
//---- отображение метки сигнальной линии
#property indicator_label1  "High Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color2 clrLime
//---- толщина линии индикатора равна 1
#property indicator_width2 1
//---- отображение метки сигнальной линии
#property indicator_label2  "Low Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета линии индикатора использован
#property indicator_color3  clrDodgerBlue
//---- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//---- отображение бычьей метки индикатора
#property indicator_label3  "High Down"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета линии индикатора использован
#property indicator_color4  clrDodgerBlue
//---- толщина линии индикатора 2 равна 1
#property indicator_width4  1
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Low Down"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES     TimeFrame=PERIOD_H4;         // Период графика
input int Shift=0;                                     // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpHiBuffer[],UpLoBuffer[];
double DnHiBuffer[],DnLoBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//|  Получение стрингового таймфрейма                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT));

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"InOutBar(",GetStringTimeframe(TimeFrame),", ",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpHiBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,218);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(UpHiBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpLoBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,217);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(UpLoBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,DnHiBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(DnHiBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,217);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnLoBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(DnLoBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,218);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total<min_rates_total) return(RESET);

//---- Объявление целых переменных
   int limit,bar;
//---- Объявление переменных с плавающей точкой  
   double iHigh[2],iLow[2];
   static uint LastCountBar;
   datetime iTime[1];

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(time,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(NULL,TimeFrame,time[bar],1,iTime)<1) return(RESET);

      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         LastCountBar=bar;
        }

      UpHiBuffer[bar]=NULL;
      UpLoBuffer[bar]=NULL;
      DnHiBuffer[bar]=NULL;
      DnLoBuffer[bar]=NULL;

      if(CopyHigh(NULL,TimeFrame,time[bar],2,iHigh)<2) return(RESET);
      if(CopyLow(NULL,TimeFrame,time[bar],2,iLow)<2) return(RESET);

      if(iHigh[0]>iHigh[1] && iLow[0]<iLow[1])
        {
         UpHiBuffer[bar]=high[bar];
         UpLoBuffer[bar]=low[bar];
        }
      if(iHigh[0]<iHigh[1] && iLow[0]>iLow[1])
        {
         DnHiBuffer[bar]=high[bar];
         DnLoBuffer[bar]=low[bar];
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
