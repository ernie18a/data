//+------------------------------------------------------------------+
//|                                                 ColorMFI_X20.mq5 | 
//|                                  Copyright © 2010, Ivan Kornilov | 
//|                                                 excelf@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ivan Kornilov"
#property link "excelf@gmail.com"
#property description "Двадцать индикаторов MFI в одном окне"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define LINES_TOTAL         20 // Константа для количества линий индикатора
#define RESET               0  // Константа для возврата терминалу команды на пересчёт индикатора
//---- количество индикаторных буферов
#property indicator_buffers 40 //LINES_TOTAL*2 
//---- использовано всего графических построений
#property indicator_plots   LINES_TOTAL
//+-----------------------------------+
//|  Параметры отрисовки индикаторов  |
//+-----------------------------------+
//---- отрисовка осцилляторов в виде цветных линий
#property indicator_type1 DRAW_COLOR_LINE
//---- выбор цветов линий
#property indicator_color1 clrDodgerBlue,clrGray,clrRed
//---- линии - штрихпунктирные кривые
#property indicator_style1 STYLE_SOLID
//---- толщина линий 1
#property indicator_width1  1
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint StartMFIPeriod=5;                       // стартовый период
input uint  step = 1;                              // шаг периода
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём 
input uint                 HighLevel=60;           // уровень перекупленности
input uint                 MidLevel=50;            // уровень середины
input uint                 LowLevel=40;            // уровень перепроданности
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
public: double    ColorIndBuffer[];
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
   min_rates_total=int(StartMFIPeriod+step*(LINES_TOTAL-1))+1;
   uint Maxrange=StartMFIPeriod+LINES_TOTAL*(step-1+1)*2;
//----
   uint period=StartMFIPeriod;
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      period+=step;

      //---- получение хендла индикатора iMFI
      Ind_Handle[numb]=iMFI(Symbol(),0,period,VolumeType);
      if(Ind_Handle[numb]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iMFI ",numb);

      string shortname="";
      StringConcatenate(shortname,"iMFI X",LINES_TOTAL,"*",period,")");
      //--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
      PlotIndexSetString(numb,PLOT_LABEL,shortname);
      //---- установка значений индикатора, которые не будут видимы на графике
      PlotIndexSetDouble(numb,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- осуществление сдвига начала отсчёта отрисовки индикатора
      PlotIndexSetInteger(numb,PLOT_DRAW_BEGIN,min_rates_total);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(2*numb,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(2*numb+1,Ind[numb].ColorIndBuffer,INDICATOR_COLOR_INDEX);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].ColorIndBuffer,true); 
      //---- копирование свойств первой линии индикатора для всех остальных
      PlotIndexSetInteger(numb,PLOT_DRAW_TYPE,PlotIndexGetInteger(0,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb,PLOT_LINE_STYLE,PlotIndexGetInteger(0,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb,PLOT_LINE_WIDTH,PlotIndexGetInteger(0,PLOT_LINE_WIDTH));    
      PlotIndexSetInteger(numb,PLOT_COLOR_INDEXES,3);    
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,0,PlotIndexGetInteger(0,PLOT_LINE_COLOR,0));
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,1,PlotIndexGetInteger(0,PLOT_LINE_COLOR,1));
      PlotIndexSetInteger(numb,PLOT_LINE_COLOR,2,PlotIndexGetInteger(0,PLOT_LINE_COLOR,2));
      //---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
      PlotIndexSetInteger(numb,PLOT_SHOW_DATA,false);
     }

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"iMFI X",LINES_TOTAL,"(",StartMFIPeriod,",",step,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MidLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrLimeGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_SOLID);
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
   int to_copy,limit;

//---- расчёт необходимого количества копируемых данных
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1;
     }
   else limit=rates_total-prev_calculated;
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в индикаторные буферы
   for(int numb=0; numb<LINES_TOTAL; numb++) if(CopyBuffer(Ind_Handle[numb],0,0,to_copy,Ind[numb].IndBuffer)<=0) return(RESET);

//---- цикл раскраски индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      for(int numb=0; numb<LINES_TOTAL; numb++)
        {
         int clr=1.0;
         if(Ind[numb].IndBuffer[bar]>HighLevel) clr=0.0;
         else if(Ind[numb].IndBuffer[bar]<LowLevel) clr=2.0;
         Ind[numb].ColorIndBuffer[bar]=clr;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
