//+------------------------------------------------------------------+
//|                                                      RSI_X20.mq5 | 
//|                                  Copyright © 2010, Ivan Kornilov | 
//|                                                 excelf@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ivan Kornilov"
#property link "excelf@gmail.com"
#property description "Двадцать индикаторов RSI в одном окне"
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- параметры минимального и максимального значений индикатора
#property indicator_minimum 0
#property indicator_maximum 100
//---- параметры горизонтальных уровней индикатора
#property indicator_level1  70
#property indicator_level2  50
#property indicator_level3  30
#property indicator_levelcolor clrTeal
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define LINES_TOTAL         20 // Константа для количества линий индикатора
#define RESET               0  // Константа для возврата терминалу команды на пересчёт индикатора
//---- количество индикаторных буферов
#property indicator_buffers LINES_TOTAL 
//---- использовано всего графических построений
#property indicator_plots   LINES_TOTAL
//+-----------------------------------+
//|  Параметры отрисовки индикаторов  |
//+-----------------------------------+
//---- отрисовка осцилляторов в виде линий
#property indicator_type1 DRAW_LINE
//---- выбор цветов линий
#property indicator_color1 clrRed
//---- линии - штрихпунктирные кривые
#property indicator_style1 STYLE_SOLID
//---- толщина линий 1
#property indicator_width1  1
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint StartRSIPeriod=5;                          // стартовый период
input uint  step = 1;                                 // шаг периода
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;      // цена
//+-----------------------------------+

//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle[LINES_TOTAL];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных буферов            |
//+------------------------------------------------------------------+  
class CIndicatorsBuffers
  {
public: double    IndBuffer[];
  };
//+------------------------------------------------------------------+
//| Создание индикаторных буферов                                    |
//+------------------------------------------------------------------+
CIndicatorsBuffers Ind[LINES_TOTAL];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(StartRSIPeriod+step*(LINES_TOTAL-1))+1;
   uint Maxrange=StartRSIPeriod+LINES_TOTAL*(step-1+1)*2;
//----
   uint period=StartRSIPeriod;
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      period+=step;

      //---- получение хендла индикатора iRSI
      Ind_Handle[numb]=iRSI(Symbol(),0,period,RSIPrice);
      if(Ind_Handle[numb]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iRSI ",numb);

      string shortname="";
      StringConcatenate(shortname,"iRSI X",LINES_TOTAL,"*",period,")");
      //--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- установка значений индикатора, которые не будут видимы на графике
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- осуществление сдвига начала отсчёта отрисовки индикатора
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(numb,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- копирование свойств первой линии индикатора для всех остальных
      PlotIndexSetInteger(numb,PLOT_DRAW_TYPE,PlotIndexGetInteger(0,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb,PLOT_LINE_STYLE,PlotIndexGetInteger(0,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb,PLOT_LINE_WIDTH,PlotIndexGetInteger(0,PLOT_LINE_WIDTH));
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,PlotIndexGetInteger(0,PLOT_LINE_COLOR));
      //---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
      PlotIndexSetInteger(numb,PLOT_SHOW_DATA,false);
     }

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"iRSI X",LINES_TOTAL,"*",StartRSIPeriod,"(",step,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
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
   for(int numb=0; numb<LINES_TOTAL; numb++) if(BarsCalculated(Ind_Handle[numb])<min_rates_total) return(RESET);
   for(int numb=0; numb<LINES_TOTAL; numb++) if(BarsCalculated(Ind_Handle[numb])<rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy;

//---- расчёт необходимого количества копируемых данных
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      to_copy=rates_total;
   else to_copy=rates_total-prev_calculated+1;

//---- копируем вновь появившиеся данные в индикаторные буферы
   for(int numb=0; numb<LINES_TOTAL; numb++) if(CopyBuffer(Ind_Handle[numb],0,0,to_copy,Ind[numb].IndBuffer)<=0) return(RESET);
   
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
