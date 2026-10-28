//+------------------------------------------------------------------+ 
//|                                                   Stoch_2HTF.mq5 | 
//|                                         Copyright © 2006, lukas1 | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2006, lukas1"
#property link ""
//--- номер версии индикатора
#property version   "1.60"
#property description "Цветное облако из осцилляторов Stoch с разных таймфреймов на одном графике."
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                 // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Stoch"  // Константа для имени индикатора
#define SIZE 2                  // Константа для количества вызовов функции CountIndicator коде
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  clrAqua,clrMediumOrchid
//--- отображение метки индикатора
#property indicator_label1  "Stoch_2HTF"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 80.0
#property indicator_level2 50.0
#property indicator_level3 20.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Line
  {
   MODE_MAIN,  // основная линия 
   MODE_SIGNAL // сигнальная линия
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H2;        // Период графика индикатора 1 (младший таймфрейм)
input int KPeriod1=5;
input int DPeriod1=3;
input int Slowing1=3;
input ENUM_MA_METHOD MA_Method1=MODE_SMA;
input ENUM_STO_PRICE Price_field1=STO_LOWHIGH;
input Line Line_Type1=MODE_SIGNAL;                 // Тип линии 1
//---
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H4;        // Период графика индикатора 2 (старший таймфрейм)
input int KPeriod2=5;
input int DPeriod2=3;
input int Slowing2=3;
input ENUM_MA_METHOD MA_Method2=MODE_SMA;
input ENUM_STO_PRICE Price_field2=STO_LOWHIGH;
input Line Line_Type2=MODE_SIGNAL;                 // Тип линии 2
//---
input int                  Shift=0;                // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+ 
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind1_Handle,Ind2_Handle;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame1,TimeFrame2)) return(INIT_FAILED);
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора Stoch 1
   Ind1_Handle=iStochastic(Symbol(),TimeFrame1,KPeriod1,DPeriod1,Slowing1,MA_Method1,Price_field1);
   if(Ind1_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Stoch 1");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора Stoch 2
   Ind2_Handle=iStochastic(Symbol(),TimeFrame2,KPeriod2,DPeriod2,Slowing2,MA_Method2,Price_field2);
   if(Ind2_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Stoch 2");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,Ind1Buffer);
   IndInit(1,Ind2Buffer);
   PlotInit(0,0.0,min_rates_total,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame1),", ",GetStringTimeframe(TimeFrame2),")");
//---
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind1_Handle)<Bars(Symbol(),TimeFrame1)) return(prev_calculated);
   if(BarsCalculated(Ind2_Handle)<Bars(Symbol(),TimeFrame2)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame1,Ind1_Handle,Line_Type1,Ind1Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame2,Ind2_Handle,Line_Type2,Ind2Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[])
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb,        // Номер буфера обрабатываемого индикатора
                    double&  IndBuf[],        // Приемный буфер индикатора
                    const datetime& iTime[],  // Таймсерия времени
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
      //--- обнулим содержимое индикаторных буферов до расчета
      IndBuf[bar]=0.0;
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массив Arr
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame1, //Период графика индикатора 1 (младший таймфрейм)
                     ENUM_TIMEFRAMES TFrame2) //Период графика индикатора 3 (старший таймфрейм)
  {
//--- проверка периодов графиков на корректность
   if(TFrame1<Period() && TFrame1!=PERIOD_CURRENT)
     {
      Print("Период графика 1 для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }

   if(TFrame2<=TFrame1)
     {
      Print("Период графика 2 для индикатора "+IndName+" должен быть больше периода графика 1!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
