//+------------------------------------------------------------------+ 
//|                                             ColorRSI_X20_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "ColorRSI_X20 с фиксированным во входных параметрах таймфреймом"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define LINES_TOTAL         20                          // Константа для количества линий индикатора
#define RESET 0                                         // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "ColorRSI_X20"                   // Константа для имени индикатора
#define SIZE 40                                         // Константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+
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
#property indicator_color1 clrSpringGreen,clrGray,clrRed
//---- линии - штрихпунктирные кривые
#property indicator_style1 STYLE_SOLID
//---- толщина линий 1
#property indicator_width1  1
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;        // Период графика индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint StartRSIPeriod=5;                       // стартовый период
input uint  step = 1;                              // шаг периода
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;   // цена
input uint                 HighLevel=60;           // уровень перекупленности
input uint                 MidLevel=50;            // уровень середины
input uint                 LowLevel=40;            // уровень перепроданности
input int Shift=0;                                 // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double IndBuffer1[],IndBuffer2[];
double IndBuffer3[],IndBuffer4[];
double IndBuffer5[],IndBuffer6[];
double IndBuffer7[],IndBuffer8[];
double IndBuffer9[],IndBuffer10[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
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
int OnInit()
  {
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора ColorRSI_X20
   Ind_Handle=iCustom(Symbol(),TimeFrame,"ColorRSI_X20",StartRSIPeriod,step,RSIPrice,HighLevel,MidLevel,LowLevel,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorRSI_X20");
      return(INIT_FAILED);
     }
//----
   uint period=StartRSIPeriod;
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      period+=step;
      string shortname="";
      StringConcatenate(shortname,"iRSI X",LINES_TOTAL,"*",period,")");
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
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
//---
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
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_SOLID);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(RESET);
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   for(int numb=0; numb<LINES_TOTAL; numb++)
     {
      int count=2*numb;
      if(!CountIndicator(count,NULL,TimeFrame,Ind_Handle,count,Ind[numb].IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
      if(!CountIndicator(count+1,NULL,TimeFrame,Ind_Handle,count+1,Ind[numb].ColorIndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора 1
                    double&  IndBuf[],        // Приемный буфер индикатора 1
                    const datetime& Time[],   // Таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,Time[bar],1,IndTime)<=0) return(RESET);
      //---
      if(Time[bar]>=IndTime[0] && Time[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,Time[bar],1,Arr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
        }
      else
        {
         IndBuf[bar]=IndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) // Период графика индикатора
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Comment("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика! \n Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
