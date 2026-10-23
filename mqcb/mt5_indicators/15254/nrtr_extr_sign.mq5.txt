//+------------------------------------------------------------------+
//|                                               NRTR_extr_Sign.mq5 |
//|                                        Copyright © 2005, Ramdass | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2005, Ramdass" 
#property link      "" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type1 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "Buy NRTR_extr signal"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color2 clrMagenta
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки сигнальной линии
#property indicator_label2  "Sell NRTR_extr signal"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint iPeriod=10;  // Период индикатора
input int iDig=0;       // Разряд
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double SignUp[];
double SignDown[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация глобальных переменных 
   int ATR_Period=15;
   min_rates_total=int(MathMax(iPeriod,ATR_Period))+1;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"NRTR_extr Sign(",string(iPeriod),", ",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SignUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignUp,true);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,110);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,SignDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignDown,true);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,110);
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   double price,value,dK,ATR[];
   static double price_prev,value_prev;
   int to_copy,limit,bar,trend;
   static int trend_prev;
//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ATR,true);
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
      trend_prev=0;
      price_prev=value_prev=close[limit];
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
   trend=trend_prev;
   price=price_prev;
   value=value_prev;
//--- копируем вновь появившиеся данные в массивы ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SignUp[bar]=0.0;
      SignDown[bar]=0.0;
      //----
      double AvgRange=0.0;
      for(int iii=0; iii<int(iPeriod); iii++) AvgRange+=MathAbs(high[bar+iii]-low[bar+iii]);
      dK=(AvgRange/iPeriod)/MathPow(10,SymbolInfoInteger("EURUSD",SYMBOL_DIGITS)-_Digits-iDig);
      //----
      if(trend>=0)
        {
         price=MathMax(price,high[bar]);
         value=MathMax(value,price*(1.0-dK));
         if(high[bar]<value)
           {
            price = high[bar];
            value = price*(1.0+dK);
            trend = -1;
           }
        }
      else if(trend<=0)
        {
         price=MathMin(price,low[bar]);
         value=MathMin(value,price*(1.0+dK));
         if(low[bar]>value)
           {
            price = low[bar];
            value = price*(1.0-dK);
            trend = +1;
           }
        }
      //----
      if(trend_prev<0  &&  trend>0) SignUp[bar]=low[bar]-ATR[bar]*3/8;
      if(trend_prev>0 && trend<0) SignDown[bar]=high[bar]+ATR[bar]*3/8;
      //----
      if(bar)
        {
         trend_prev=trend;
         price_prev=price;
         value_prev=value;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
