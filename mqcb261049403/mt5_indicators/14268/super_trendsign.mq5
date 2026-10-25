//+------------------------------------------------------------------+
//|                                              Super_TrendSign.mq5 |
//|                   Copyright © 2005, Jason Robinson (jnrtrading). | 
//|                                      http://www.jnrtrading.co.uk | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)." 
#property link      "http://www.jnrtrading.co.uk" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован DarkOrange цвет
#property indicator_color1  clrDarkOrange
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение медвежьей метки индикатора
#property indicator_label1  "Sell Super_Trend signal"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован MediumTurquoise цвет
#property indicator_color2  clrMediumTurquoise
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение бычьей метки индикатора
#property indicator_label2 "Buy Super_Trend signal"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                             // константа для возврата терминалу команды на пересчет индикатора
#define UP_DOWN_SHIFT_CR  0
#define UP_DOWN_SHIFT_M1  3
#define UP_DOWN_SHIFT_M2  3
#define UP_DOWN_SHIFT_M3  4
#define UP_DOWN_SHIFT_M4  5
#define UP_DOWN_SHIFT_M5  5
#define UP_DOWN_SHIFT_M6  5
#define UP_DOWN_SHIFT_M10 6
#define UP_DOWN_SHIFT_M12 6
#define UP_DOWN_SHIFT_M15 7
#define UP_DOWN_SHIFT_M20 8
#define UP_DOWN_SHIFT_M30 9
#define UP_DOWN_SHIFT_H1  20
#define UP_DOWN_SHIFT_H2  27
#define UP_DOWN_SHIFT_H3  30
#define UP_DOWN_SHIFT_H4  35
#define UP_DOWN_SHIFT_H6  33
#define UP_DOWN_SHIFT_H8  35
#define UP_DOWN_SHIFT_H12 37
#define UP_DOWN_SHIFT_D1  40
#define UP_DOWN_SHIFT_W1  100
#define UP_DOWN_SHIFT_MN1 120
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int CCIPeriod=14; // Период индикатора CCI 
input int Level=0;      // Уровень срабатывания CCI
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//----
double UpDownShift;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int CCI_Handle,ATR_Handle;
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int GetUpDownShift(ENUM_TIMEFRAMES Timeframe)
  {
//----
   switch(Timeframe)
     {
      case PERIOD_M1:     return(UP_DOWN_SHIFT_M1);
      case PERIOD_M2:     return(UP_DOWN_SHIFT_M2);
      case PERIOD_M3:     return(UP_DOWN_SHIFT_M3);
      case PERIOD_M4:     return(UP_DOWN_SHIFT_M4);
      case PERIOD_M5:     return(UP_DOWN_SHIFT_M5);
      case PERIOD_M6:     return(UP_DOWN_SHIFT_M6);
      case PERIOD_M10:    return(UP_DOWN_SHIFT_M10);
      case PERIOD_M12:    return(UP_DOWN_SHIFT_M12);
      case PERIOD_M15:    return(UP_DOWN_SHIFT_M15);
      case PERIOD_M20:    return(UP_DOWN_SHIFT_M20);
      case PERIOD_M30:    return(UP_DOWN_SHIFT_M30);
      case PERIOD_H1:     return(UP_DOWN_SHIFT_H1);
      case PERIOD_H2:     return(UP_DOWN_SHIFT_H2);
      case PERIOD_H3:     return(UP_DOWN_SHIFT_H3);
      case PERIOD_H4:     return(UP_DOWN_SHIFT_H4);
      case PERIOD_H6:     return(UP_DOWN_SHIFT_H6);
      case PERIOD_H8:     return(UP_DOWN_SHIFT_H8);
      case PERIOD_H12:    return(UP_DOWN_SHIFT_H12);
      case PERIOD_D1:     return(UP_DOWN_SHIFT_D1);
      case PERIOD_W1:     return(UP_DOWN_SHIFT_W1);
      case PERIOD_MN1:    return(UP_DOWN_SHIFT_MN1);
     }
//----
   return(UP_DOWN_SHIFT_CR);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- получение хендла индикатора ATR
   int ATR_Period=15;
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора CCI
   CCI_Handle=iCCI(NULL,0,CCIPeriod,PRICE_TYPICAL);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора CCI");
      return(INIT_FAILED);
     }
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(CCIPeriod)+1;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));
//---- инициализация переменной для сдвига значений     
   UpDownShift=GetUpDownShift(Period())*_Point;
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Super_Trend(",string(CCIPeriod),", ",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- символ для индикатора
//PlotIndexSetInteger(0,PLOT_ARROW,234);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- символ для индикатора
//PlotIndexSetInteger(1,PLOT_ARROW,233);
//--- завершение инициализации
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
                const double& low[],      // ценовой массив минимумов цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || BarsCalculated(CCI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   double CCI[],ATR[],cciTrendNow,cciTrendPrevious,TrendUp,TrendDown;
   static double TrendUp_prev,TrendDown_prev;
   int limit,to_copy,bar;
//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(ATR,true);
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total;                 // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy++;
//---- копируем вновь появившиеся данные в массив CCI[]
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      cciTrendNow=CCI[bar]+70;
      cciTrendPrevious=CCI[bar+1]+70;
      //----
      if(cciTrendNow>=Level && cciTrendPrevious<Level) TrendUp_prev=TrendDown_prev;
      if(cciTrendNow<=Level && cciTrendPrevious>Level) TrendDown_prev=TrendUp_prev;
      //----
      if(cciTrendNow>Level)
        {
         TrendDown=0.0;
         TrendUp=low[bar]-UpDownShift;
         if(close[bar]<open[bar] && TrendDown_prev!=TrendUp_prev) TrendUp=TrendUp_prev;
         if(TrendUp<TrendUp_prev && TrendDown_prev!=TrendUp_prev) TrendUp=TrendUp_prev;
         if(high[bar]<high[bar+1]&& TrendDown_prev!=TrendUp_prev) TrendUp=TrendUp_prev;
        }
      //----
      if(cciTrendNow<Level)
        {
         TrendUp=0.0;
         TrendDown=high[bar]+UpDownShift;
         if(close[bar]>open[bar] && TrendUp_prev!=TrendDown_prev) TrendDown_prev=TrendDown_prev;
         if(TrendDown>TrendDown_prev && TrendDown_prev!=TrendUp_prev) TrendDown=TrendDown_prev;
         if(low[bar]>low[bar+1] && TrendUp_prev!=TrendDown_prev) TrendDown=TrendDown_prev;
        }
      //----
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      if(TrendDown_prev && TrendUp) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(TrendUp_prev && TrendDown) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
      //----
      if(bar)
        {
         TrendUp_prev=TrendUp;
         TrendDown_prev=TrendDown;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
