//+------------------------------------------------------------------+
//|                                                  ChandelExit.mq5 |
//|                                                       MQLService |
//|                                           scripts@mqlservice.com |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "MQLService"
#property link      "scripts@mqlservice.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета индикатора использованы
#property indicator_color1  clrViolet,clrLime
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычьей метки индикатора
#property indicator_label1  "UpLoss Line"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int RangePeriod=15;
input int Shift=1;
input int ATRPeriod=14;
input int MultipleATR=4;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=MathMax(ATRPeriod,RangePeriod+Shift);
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора ATR");
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- осуществление сдвига начала отсчета отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ChandelExit(",RangePeriod,", ",ATRPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   static int direction;
   int to_copy,limit,bar;
   double ATR[],HH0,LL0;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчета всех баров
      direction=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- расчет необходимого количества копируемых данных
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ATR[bar]*=MultipleATR;
      HH0=high[ArrayMaximum(high,bar+Shift,RangePeriod)]-ATR[bar];
      LL0=low[ArrayMinimum(low,bar+Shift,RangePeriod)]+ATR[bar];
      //---
      if(direction>=0)
        {
         if(close[bar]<HH0)
           {
            if(bar) direction=-1;
            UpBuffer[bar]=LL0;
            DnBuffer[bar]=HH0;
           }
         else
           {
            UpBuffer[bar]=HH0;
            DnBuffer[bar]=LL0;
           }
        }
      else
      if(direction<=0)
        {
         if(close[bar]>LL0)
           {
            if(bar) direction=+1;
            DnBuffer[bar]=LL0;
            UpBuffer[bar]=HH0;
           }
         else
           {
            UpBuffer[bar]=LL0;
            DnBuffer[bar]=HH0;
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
