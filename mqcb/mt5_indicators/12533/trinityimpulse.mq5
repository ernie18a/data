//+------------------------------------------------------------------+ 
//|                                              Trinity-Impulse.mq5 | 
//|                           Copyright © 2010, basisforex@gmail.com | 
//|                                             basisforex@gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, basisforex@gmail.com"
#property link "basisforex@gmail.com"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов
#property indicator_buffers 1 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован Orchid цвет
#property indicator_color1 clrOrchid
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 1
#property indicator_width1  1
//--- отображение метки индикатора
#property indicator_label1  "Trinity-Impulse"
//+-----------------------------------+
//| объявление констант               |
//+-----------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int nPeriod= 5;                           // Период индикатора
input int nLevel= 34;                           // Уровень срабатывания
input  ENUM_MA_METHOD nType=MODE_LWMA;          // Тип усреднения
input ENUM_APPLIED_PRICE nPrice=PRICE_WEIGHTED; // Цена
input ENUM_APPLIED_VOLUME nVolume=VOLUME_TICK;  // Тип объема
//+-----------------------------------+
//--- объявление динамического массива, который в дальнейшем
//--- будет использован в качестве индикаторного буфера
double ExtLineBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int CCI_Handle,Force_Handle;
//+------------------------------------------------------------------+    
//| Trinity-Impulse indicator initialization function                | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=nPeriod;
//--- получение хендла индикатора iCCI
   CCI_Handle=iCCI(NULL,0,nPeriod,nPrice);
   if(CCI_Handle==INVALID_HANDLE) 
     {
      Print("Не удалось получить хендл индикатора iCCI");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iForce
   Force_Handle=iForce(NULL,0,nPeriod,nType,nVolume);
   if(Force_Handle==INVALID_HANDLE) 
     {
      Print("Не удалось получить хендл индикатора iForce");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Trinity-Impulse(",nPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Trinity-Impulse iteration function                               | 
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(CCI_Handle)<rates_total
      || BarsCalculated(Force_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- объявление локальных переменных
   int to_copy,limit,bar;
   double CCI[],FORCE[];
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-2; // расчетное количество всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(FORCE,true);
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
   if(CopyBuffer(Force_Handle,0,0,to_copy,FORCE)<=0) return(RESET);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0; bar--)
     {
      if(CCI[bar]*FORCE[bar]>=nLevel)
        {
         if(CCI[bar]>0 && FORCE[bar]>0) ExtLineBuffer[bar]=1;
         if(CCI[bar]<0 && FORCE[bar]<0) ExtLineBuffer[bar]=-1;
        }
      else ExtLineBuffer[bar]=0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
