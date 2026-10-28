//+---------------------------------------------------------------------+
//|                                   ColorXFisher_org_v1_X20_Cloud.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ivan Kornilov"
#property link "excelf@gmail.com"
#property description "ColorXFisher_org_v1_X20"
//---- номер версии индикатора
#property version   "1.20"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define LINES_TOTAL         20 // Константа для количества линий индикатора
#define RESET               0 // Константа для возврата терминалу команды на пересчёт индикатора
//---- использовано всего графических построений
#property indicator_buffers 44 //LINES_TOTAL*2+4
//---- использовано всего графических построений
#property indicator_plots   22 //LINES_TOTAL+2
//+----------------------------------------------+
//| Параметры отрисовки верхнего облака          |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'151,255,219'
#property indicator_color1 C'151,255,219'
//---- отображение метки индикатора
#property indicator_label1  "Upper XFisher_org_v1"
//+----------------------------------------------+
//| Параметры отрисовки нижнего облака           |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'255,185,255'
#property indicator_color2 C'255,185,255'
//---- отображение метки индикатора
#property indicator_label2  "Lower XFisher_org_v1"
//+----------------------------------------------+
//|  Параметры отрисовки индикаторов             |
//+----------------------------------------------+
//---- отрисовка осцилляторов в виде цветных линий
#property indicator_type3 DRAW_COLOR_LINE
//---- выбор цветов линий
#property indicator_color3 clrDodgerBlue,clrGray,clrMagenta
//---- линии - штрихпунктирные кривые
#property indicator_style3 STYLE_SOLID
//---- толщина линий 1
#property indicator_width3  1
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_,  // TrendFollow_2 Price 
   PRICE_DEMARK_         // Demark Price 
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint FLength=3;                             // стартовая глубина усреднения
input uint  step = 1;                             // шаг изменения глубины усреднения
input Smooth_Method MA_SMethod=MODE_JJMA;         // Метод сглаживания
input uint MA_Length=3;                           // Глубина сглаживания                    
input int MA_Phase=15;                            // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей                  
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;       // ценовая константа
input double              HighLevelM=+2.30001;      // уровень максимальной перекупленности
input double              HighLevel=+1.0001;      // уровень перекупленности
input double               MidLevel=0.0;          // уровень середины
input double               LowLevel=-1.0001;      // уровень перепроданности
input double               LowLevelM=-2.3001;      // уровень минимальной перепроданности
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpUpBuffer[],UpDnBuffer[],DnUpBuffer[],DnDnBuffer[];
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
   min_rates_total=int(FLength+step*(LINES_TOTAL-1))+1;
   min_rates_total+=GetStartBars(MA_SMethod,MA_Length,MA_Phase);
//Maxrange=rangeN+LINES_TOTAL*(step-1+1)*2;
//----
//--- инициализация индикаторных буферов  
   IndInit(0,UpUpBuffer,INDICATOR_DATA);
   IndInit(1,UpDnBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,EMPTY_VALUE,min_rates_total,0);
//--- инициализация индикаторных буферов  
   IndInit(2,DnUpBuffer,INDICATOR_DATA);
   IndInit(3,DnDnBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(1,EMPTY_VALUE,min_rates_total,0);

   uint period=FLength;
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      period+=step;

      //---- получение хендла индикатора XFisher_org_v1
      Ind_Handle[numb]=iCustom(NULL,0,"XFisher_org_v1",period,MA_SMethod,MA_Length,MA_Phase,IPC,0);
      if(Ind_Handle[numb]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора XFisher_org_v1 ",numb);

      string shortname="";
      StringConcatenate(shortname,"Fisher_org_v1 X",LINES_TOTAL,"*",period,")");
      int numb1=numb+2;
      //--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
      PlotIndexSetString(numb1,PLOT_LABEL,shortname);
      //---- установка значений индикатора, которые не будут видимы на графике
      PlotIndexSetDouble(numb1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      //---- осуществление сдвига начала отсчёта отрисовки индикатора
      PlotIndexSetInteger(numb1,PLOT_DRAW_BEGIN,min_rates_total);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(2*numb+4,Ind[numb].IndBuffer,INDICATOR_DATA);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].IndBuffer,true);
      //---- превращение динамических массивов в индикаторные буферы
      SetIndexBuffer(2*numb+1+4,Ind[numb].ColorIndBuffer,INDICATOR_COLOR_INDEX);
      //---- индексация элементов в буферах как в таймсериях   
      ArraySetAsSeries(Ind[numb].ColorIndBuffer,true);
      //---- копирование свойств первой линии индикатора для всех остальных
      PlotIndexSetInteger(numb1,PLOT_DRAW_TYPE,PlotIndexGetInteger(2,PLOT_DRAW_TYPE));
      PlotIndexSetInteger(numb1,PLOT_LINE_STYLE,PlotIndexGetInteger(2,PLOT_LINE_STYLE));
      PlotIndexSetInteger(numb1,PLOT_LINE_WIDTH,PlotIndexGetInteger(2,PLOT_LINE_WIDTH));
      PlotIndexSetInteger(numb1,PLOT_COLOR_INDEXES,3);
      PlotIndexSetInteger(numb1,PLOT_LINE_COLOR,0,PlotIndexGetInteger(2,PLOT_LINE_COLOR,0));
      PlotIndexSetInteger(numb1,PLOT_LINE_COLOR,1,PlotIndexGetInteger(2,PLOT_LINE_COLOR,1));
      PlotIndexSetInteger(numb1,PLOT_LINE_COLOR,2,PlotIndexGetInteger(2,PLOT_LINE_COLOR,2));
      //---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
      PlotIndexSetInteger(numb1,PLOT_SHOW_DATA,false);
     }

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ColorXFisher_org_v1 X",LINES_TOTAL,"*",FLength,"(",step,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MidLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMediumSeaGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrRed);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_SOLID);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//---
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(Number,PLOT_SHOW_DATA,false);
//---
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
      UpUpBuffer[bar]=HighLevelM;
      UpDnBuffer[bar]=HighLevel;
      //----      
      DnUpBuffer[bar]=LowLevel;
      DnDnBuffer[bar]=LowLevelM;
      //---- 
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
