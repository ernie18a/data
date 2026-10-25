//+------------------------------------------------------------------+
//|                                                 ADX Smoothed.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
//--- ссылка на сайт автора
#property link      "https://www.metaquotes.net"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//--- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color1  Lime
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "Di Plus"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color2  Red
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Di Minus"
//+----------------------------------------------+
//| Параметры отрисовки ADX индикатора           |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//--- в качестве цвета ADX линии индикатора использован синий цвет
#property indicator_color3  Blue
//--- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//--- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//--- отображение медвежьей метки индикатора
#property indicator_label3  "ADX"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 88.0
#property indicator_level2 50.0
#property indicator_level3 12.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int    period = 14;
input double alpha1 = 0.25;
input double alpha2 = 0.33;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double DiPlusBuffer[];
double DiMinusBuffer[];
double ADXBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int ADX_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- получение хендла индикатора ADX
   ADX_Handle=iADX(NULL,0,period);
   if(ADX_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ADX");
      return(INIT_FAILED);
     }
//--- инициализация переменных начала отсчета данных
   min_rates_total=period+1;
//--- превращение динамического массива DiPlusBuffer в индикаторный буфер
   SetIndexBuffer(0,DiPlusBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(DiPlusBuffer,true);
//--- превращение динамического массива DiMinusBuffer в индикаторный буфер
   SetIndexBuffer(1,DiMinusBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(DiMinusBuffer,true);
//--- превращение динамического массива DiMinusBuffer в индикаторный буфер
   SetIndexBuffer(2,ADXBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ADXBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ADX(",period,")smothed");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ADX_Handle)<rates_total || rates_total<min_rates_total) return(0);
//--- объявления локальных переменных 
   int limit,to_copy,bar;
   double ADX[],DIP[],DIM[],DiPlus,DiMinus,Adx;
   static double DiPlus_,DiMinus_,Adx_;
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ADX,true);
   ArraySetAsSeries(DIP,true);
   ArraySetAsSeries(DIM,true);
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-2; // стартовый номер для расчета всех баров
      DiPlus_=0.0;
      DiMinus_=0.0;
      Adx_=0.0;
      DiPlusBuffer[rates_total-1]=0.0;
      DiMinusBuffer[rates_total-1]=0.0;
      ADXBuffer[rates_total-1]=0.0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---
   to_copy=limit+2;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ADX_Handle,0,0,to_copy,ADX)<=0) return(0);
   if(CopyBuffer(ADX_Handle,1,0,to_copy,DIP)<=0) return(0);
   if(CopyBuffer(ADX_Handle,2,0,to_copy,DIM)<=0) return(0);
//--- восстанавливаем значения переменных
   DiPlus=DiPlus_;
   DiMinus=DiMinus_;
   Adx=Adx_;
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0; bar--)
     {
      //--- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         DiPlus_=DiPlus;
         DiMinus_=DiMinus;
         Adx_=Adx;
        }
      //---
      DiPlus=2*DIP[bar]+(alpha1-2)*DIP[bar+1]+(1-alpha1)*DiPlus;
      DiMinus=2*DIM[bar]+(alpha1-2)*DIM[bar+1]+(1-alpha1)*DiMinus;
      Adx=2*ADX[bar]+(alpha1-2)*ADX[bar+1]+(1-alpha1)*Adx;
      //---
      DiPlusBuffer[bar]=alpha2*DiPlus+(1-alpha2)*DiPlusBuffer[bar+1];
      DiMinusBuffer[bar]=alpha2*DiMinus+(1-alpha2)*DiMinusBuffer[bar+1];
      ADXBuffer[bar]=alpha2*Adx+(1-alpha2)*ADXBuffer[bar+1];
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
