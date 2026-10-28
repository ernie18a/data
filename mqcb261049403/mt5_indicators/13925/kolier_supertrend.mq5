//+------------------------------------------------------------------+
//|                                            Kolier_SuperTrend.mq5 |
//|                                       Copyright 2010, KoliEr Li. |
//|                                                 http://kolier.li |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright 2010, KoliEr Li."
//---- ссылка на сайт автора
#property link "http://kolier.li"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчета и отрисовки индикатора использовано 4 буфера
#property indicator_buffers 4
//---- использовано 4 графических построения
#property indicator_plots   4
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован LightSeaGreen цвет
#property indicator_color1  clrLightSeaGreen
//---- линия индикатора 1 - пунктир
#property indicator_style1  STYLE_DASH
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки линии индикатора
#property indicator_label1  "Upper SuperTrend"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет DeepPink
#property indicator_color2  clrDeepPink
//---- линия индикатора 2 - пунктир
#property indicator_style2  STYLE_DASH
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки линии индикатора
#property indicator_label2  "Lower SuperTrend"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Lime
#property indicator_color3  clrLime
//---- толщина индикатора 3 равна 4
#property indicator_width3  4
//---- отображение метки индикатора
#property indicator_label3  "Buy SuperTrend"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Red
#property indicator_color4  Red
//---- толщина индикатора 4 равна 4
#property indicator_width4  4
//---- отображение метки индикатора
#property indicator_label4  "Sell SuperTrend"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
#define PHASE_NONE 0
#define PHASE_BUY 1
#define PHASE_SELL -1
//+-----------------------------------------------+
//| Объявление перечислений                       |
//+-----------------------------------------------+
enum Mode
  {
   SuperTrend=0,//Отображать как SuperTrend
   NewWay,      //Отображать как NeWay
   Visual,      //Отображать для визуального трейдинга
   ExpertSignal //Отображать для автоматического трейдинга
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Mode TrendMode=NewWay; // Вариант отображения
input uint ATR_Period=10;
input double ATR_Multiplier=3.0;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
double BuyBuffer[];
double SellBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(1);
     }
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(ATR_Period+3);
//---- превращение динамического массива UpBuffer[] в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(UpBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- превращение динамического массива DnBuffer[] в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(DnBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- превращение динамического массива BuyBuffer[] в индикаторный буфер
   SetIndexBuffer(2,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(BuyBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,167);
//---- превращение динамического массива SellBuffer[] в индикаторный буфер
   SetIndexBuffer(3,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SellBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,167);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"SuperTrend(",ATR_Period,", ",ATR_Multiplier,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
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
   double ATR[],atr,band_upper,band_lower;
   int limit,to_copy,bar,phase;
   static int phase_;
//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
      phase_=PHASE_NONE;
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//---- восстанавливаем значения переменных
   phase=phase_;
//----
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double mediane=(high[bar]+low[bar])/2;
      atr=ATR[bar];
      atr*=ATR_Multiplier;
      band_upper = mediane + atr;
      band_lower = mediane - atr;
      //----
      UpBuffer[bar]=0.0;
      DnBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //----
      if(phase==PHASE_NONE)
        {
         UpBuffer[bar]=mediane;
         DnBuffer[bar]=mediane;
        }
      //----
      if(phase!=PHASE_BUY && close[bar]>DnBuffer[bar+1] && DnBuffer[bar+1])
        {
         phase=PHASE_BUY;
         UpBuffer[bar]=band_lower;
         if(TrendMode<Visual) UpBuffer[bar+1]=DnBuffer[bar+1];
         else if(TrendMode==Visual) DnBuffer[bar]=DnBuffer[bar+1];
        }
      //----
      if(phase!=PHASE_SELL && close[bar]<UpBuffer[bar+1] && UpBuffer[bar+1])
        {
         phase=PHASE_SELL;
         DnBuffer[bar]=band_upper;
         if(TrendMode<Visual) DnBuffer[bar+1]=UpBuffer[bar+1];
         else if(TrendMode==Visual) UpBuffer[bar]=UpBuffer[bar+1];
        }
      //----
      if(phase==PHASE_BUY && ((TrendMode==SuperTrend && UpBuffer[bar+2]) || TrendMode>SuperTrend))
        {
         if(band_lower>UpBuffer[bar+1] || (UpBuffer[bar] && TrendMode>NewWay)) UpBuffer[bar]=band_lower;
         else UpBuffer[bar]=UpBuffer[bar+1];
        }
      //----
      if(phase==PHASE_SELL && ((TrendMode==SuperTrend && DnBuffer[bar+2]) || TrendMode>SuperTrend))
        {
         if(band_upper<DnBuffer[bar+1] || (DnBuffer[bar] && TrendMode>NewWay)) DnBuffer[bar]=band_upper;
         else DnBuffer[bar]=DnBuffer[bar+1];
        }
      //----
      if(TrendMode!=Visual)
        {
         if(DnBuffer[bar+1] && UpBuffer[bar]) BuyBuffer[bar]=UpBuffer[bar];
         if(UpBuffer[bar+1] && DnBuffer[bar]) SellBuffer[bar]=DnBuffer[bar];
        }
      else
        {
         if(!UpBuffer[bar+1] && UpBuffer[bar]) BuyBuffer[bar]=UpBuffer[bar];
         if(!DnBuffer[bar+1] && DnBuffer[bar]) SellBuffer[bar]=DnBuffer[bar];
        }
      //---- запоминаем значения переменных
      if(bar==1) phase_=phase;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
