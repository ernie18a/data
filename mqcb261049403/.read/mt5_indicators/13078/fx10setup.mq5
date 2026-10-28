//+------------------------------------------------------------------+
//|                                                    Fx10Setup.mq5 |
//|                                    Copyright © 2006, palanka.com |
//|                                         http://www.metaquotes.ru |                                      
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2006, palanka"
//---- ссылка на сайт автора
#property link      "http://www.metaquotes.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//--- нижнее и верхнее ограничения шкалы отдельного окна индикатора
#property indicator_maximum +1.1
#property indicator_minimum +0.3
//+---------------------------------------------+
//| Параметры отрисовки бычьего индикатора      |
//+---------------------------------------------+
//---- отрисовка индикатора 1 в виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован LimeGreen цвет
#property indicator_color1  clrLimeGreen
//---- линия индикатора 1 - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 5
#property indicator_width1  5
//---- отображение метки линии индикатора
#property indicator_label1  "Upper Fx10Setup"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде гистограммы
#property indicator_type2   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован цвет Tomato
#property indicator_color2  clrTomato
//---- линия индикатора 2 - сплошная
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 5
#property indicator_width2  5
//---- отображение метки линии индикатора
#property indicator_label2  "Lower Fx10Setup"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double ParmMult=2.0;        // Multiply the standard parameters by this scale factor
input int    Shift=0;             // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double ExtMapBufferUp[];
double ExtMapBufferDown[];
//---- объявление целочисленных переменных для хендлов индикаторов
int FsMa_Handle,SlMa_Handle,STO_Handle,MACD_Handle,RSI_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- получение хендла индикатора iRSI
   RSI_Handle=iRSI(NULL,0,int(14*ParmMult),PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMACD
   MACD_Handle=iMACD(NULL,0,int(12*ParmMult),int(26*ParmMult),int(9*ParmMult),PRICE_CLOSE);
   if(MACD_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMACD");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора fast iMA
   FsMa_Handle=iMA(NULL,0,int(5*ParmMult),0,MODE_LWMA,PRICE_CLOSE);
   if(FsMa_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора fast iMA");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора slow iMA
   SlMa_Handle=iMA(NULL,0,int(10*ParmMult),0,MODE_SMA,PRICE_CLOSE);
   if(SlMa_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора slow iMA");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iStochastic
   STO_Handle=iStochastic(NULL,0,int(5*ParmMult),int(3*ParmMult),int(3*ParmMult),MODE_SMA,STO_CLOSECLOSE);
   if(STO_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iStochastic");
      return(INIT_FAILED);
     }
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(12*ParmMult+26*ParmMult+9*ParmMult);
//---- превращение динамического массива ExtMapBufferUp[] в индикаторный буфер
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамического массива ExtMapBufferDown[] в индикаторный буфер
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Fx10Setup(",DoubleToString(ParmMult,4),", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total
      || BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(MACD_Handle)<rates_total
      || BarsCalculated(STO_Handle)<rates_total
      || BarsCalculated(FsMa_Handle)<rates_total
      || BarsCalculated(SlMa_Handle)<rates_total)
      return(RESET);
//---- объявления локальных переменных 
   double RSI[],FsMa[],SlMa[],MMacd[],SMacd[],MSto[],SSto[];
   bool StochUp,StochDown,RsiUp,RsiDown,MacdUp,MacdDown;
   int limit,to_copy,bar;
//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(MMacd,true);
   ArraySetAsSeries(SMacd,true);
   ArraySetAsSeries(MSto,true);
   ArraySetAsSeries(SSto,true);
   ArraySetAsSeries(FsMa,true);
   ArraySetAsSeries(SlMa,true);
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }
//---
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);
   if(CopyBuffer(MACD_Handle,MAIN_LINE,0,to_copy,MMacd)<=0) return(RESET);
   if(CopyBuffer(MACD_Handle,SIGNAL_LINE,0,to_copy,SMacd)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,MAIN_LINE,0,to_copy,MSto)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,SIGNAL_LINE,0,to_copy,SSto)<=0) return(RESET);
   if(CopyBuffer(FsMa_Handle,0,0,to_copy,FsMa)<=0) return(RESET);
   if(CopyBuffer(SlMa_Handle,0,0,to_copy,SlMa)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtMapBufferUp[bar]=EMPTY_VALUE;
      ExtMapBufferDown[bar]=EMPTY_VALUE;
      //----
      if(FsMa[bar]>SlMa[bar])
        {
         RsiUp=RSI[bar]>=55.0;
         StochUp=(MSto[bar]>SSto[bar]);
         MacdUp=(MMacd[bar]>SMacd[bar]);
         if(StochUp && RsiUp && MacdUp) ExtMapBufferUp[bar]=1;
        }
      else if(FsMa[bar]<SlMa[bar])
        {
         RsiDown=RSI[bar]<=45.0;
         StochDown=(MSto[bar]<SSto[bar]);
         MacdDown=(MMacd[bar]<SMacd[bar]);
         if(StochDown && RsiDown && MacdDown) ExtMapBufferDown[bar]=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
