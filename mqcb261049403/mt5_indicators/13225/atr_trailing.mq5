//+------------------------------------------------------------------+
//|                                                 ATR_Trailing.mq5 | 
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Индикатор линии перемещения трейлинг-стопа"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2
//---- использовано всего 2 графических построений
#property indicator_plots   2
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+--------------------------------------------+
//| Параметры отрисовки уровней индикатора     |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
//---- толщина линии индикатора равна 3
#property indicator_width1 3
#property indicator_width2 3
//---- ввыбор цветов уровней
#property indicator_color1  LightGreen
#property indicator_color2  Magenta
//---- отображение меток уровней
#property indicator_label1  "StopLoss Sell"
#property indicator_label2  "StopLoss Buy"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int Period_ATR=14; // Период АТR
input double Sell_Factor=2.0;
input double Buy_Factor=2.0;
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer1[],ExtLineBuffer2[];
//---- объявление целочисленных переменных для хранения хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| SL_ATR indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=Period_ATR;
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,Period_ATR);
   if(ATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ATR_Trailing(",Period_ATR,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| SL_ATR iteration function                                        | 
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double Range[],ATR;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      for(bar=rates_total-1; bar>limit && !IsStopped(); bar--)
        {
         ExtLineBuffer1[bar]=0.0;
         ExtLineBuffer2[bar]=0.0;
        }

     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- расчет необходимого количества копируемых данных
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы Range[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Range,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ATR=Range[bar];
      ExtLineBuffer1[bar]=NormalizeDouble(low[bar]+ATR*Sell_Factor,_Digits);
      ExtLineBuffer2[bar]=NormalizeDouble(high[bar]-ATR*Buy_Factor,_Digits);
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
