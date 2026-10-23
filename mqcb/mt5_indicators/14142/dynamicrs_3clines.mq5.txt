//+------------------------------------------------------------------+
//|                                            DynamicRS_3CLines.mq5 |
//|                           Copyright © 2006, Renato P. dos Santos |
//|                   inspired on 4xtraderCY's and SchaunRSA's ideas |
//|   http://www.strategybuilderfx.com/forums/showthread.php?t=16086 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Renato P. dos Santos"
#property link "http://www.strategybuilderfx.com/forums/showthread.php?t=16086"
//---- номер версии индикатора
#property version   "1.00"
//---- описание индикатора
#property description ""
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки верхней линии 1          |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DarkOrange цвет
#property indicator_color1  clrDarkOrange
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Top"
//+----------------------------------------------+
//| Параметры отрисовки линии 2                  |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Lime цвет
#property indicator_color2  clrLime
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Bottom"
//+----------------------------------------------+
//| Параметры отрисовки линии 3                  |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован MediumPurple цвет
#property indicator_color3  clrMediumPurple
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "ExtMap"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int    Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=2;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Ind1Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ind1Buffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Ind3Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ind3Buffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Ind2Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ind2Buffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"DynamicRS_3CLines");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   int limit,bar;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчета всех баров
      bar=limit+1;
      double res=(high[bar]+low[bar])/2;
      Ind1Buffer[bar]=res;
      Ind2Buffer[bar]=res;
      Ind3Buffer[bar]=res;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Ind1Buffer[bar]=Ind1Buffer[bar+1];
      Ind2Buffer[bar]=Ind2Buffer[bar+1];
      Ind3Buffer[bar]=Ind3Buffer[bar+1];
      //----
      if(high[bar]<high[bar+1] && high[bar]<Ind2Buffer[bar+1])
        {
         Ind2Buffer[bar]=high[bar];
         Ind3Buffer[bar]=high[bar];
         Ind1Buffer[bar]=Ind1Buffer[bar+1];
        }
      else if(low[bar]>low[bar+1] && low[bar]>Ind2Buffer[bar+1])
        {
         Ind2Buffer[bar]=low[bar];
         Ind1Buffer[bar]=low[bar];
         Ind3Buffer[bar]=Ind3Buffer[bar+1];
        }
      else
        {
         Ind2Buffer[bar]=Ind2Buffer[bar+1];
         if(Ind2Buffer[bar+1]==Ind1Buffer[bar+1])
           {
            Ind1Buffer[bar]=Ind2Buffer[bar+1];
            Ind3Buffer[bar]=Ind3Buffer[bar+1];
           }
         else if(Ind2Buffer[bar+1]==Ind3Buffer[bar+1])
           {
            Ind3Buffer[bar]=Ind2Buffer[bar+1];
            Ind1Buffer[bar]=Ind1Buffer[bar+1];
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
