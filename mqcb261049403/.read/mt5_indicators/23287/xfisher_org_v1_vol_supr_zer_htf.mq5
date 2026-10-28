//+------------------------------------------------------------------+ 
//|                              XFisher_org_v1_Vol_Supr_Zer_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "XFisher_org_v1_Vol_Supr_Zer с фиксированным во входных параметрах таймфреймом"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано десять буферов
#property indicator_buffers 10
//---- использовано шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                         // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "XFisher_org_v1_Vol_Supr_Zer"    // Константа для имени индикатора
#define SIZE 10                                         // Константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+
//| Параметры отрисовки облака канала            |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color1  clrLavender
//---- отображение метки линии индикатора
#property indicator_label1  "XFisher_org_v1_Vol Cloud"
//+----------------------------------------------+
//| Параметры отрисовки линии сопротивления      |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован Teal цвет
#property indicator_color2 clrTeal
//---- линия индикатора - штрих-пунктир
#property indicator_style2  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "XFisher_org_v1_Vol Res"
//+----------------------------------------------+
//| Параметры отрисовки линии поддержки          |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color3 clrRed
//---- линия индикатора - штрих-пунктир
#property indicator_style3  STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 1
#property indicator_width3  1
//---- отображение метки индикатора
#property indicator_label3  "XFisher_org_v1_Vol Supr"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Fisher_org_v1 |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type4   DRAW_FILLING
//---- в качестве цветjd индикатора использованы
#property indicator_color4  clrDodgerBlue,clrDeepPink
//---- отображение метки линии индикатора
#property indicator_label4  "XFisher_org_v1_Vol"
//+----------------------------------------------+
//| Параметры отрисовки сигнальных значков       |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветных значков
#property indicator_type5   DRAW_COLOR_ARROW
//---- в качестве цветов трехцветной гистограммы использованы
#property indicator_color5  clrLime,clrGray,clrMagenta
//---- гистограммы индикатора - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width5  2
//---- отображение метки индикатора
#property indicator_label5  "XFisher_org_v1_Vol Arrows"
//+----------------------------------------------+
//|  Параметры отрисовки значков                 |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде цветного символа
#property indicator_type6   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы
#property indicator_color6  clrAqua,clrYellow
//---- толщина линии индикатора 6 равна 4
#property indicator_width6  4
//---- отображение метки индикатора
#property indicator_label6  "XFisher_org_v1_Vol ZeroSignal"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Smooth_Method
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
   MODE_AMA    // AMA
  };
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
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;        // Период графика индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint FLength=7;                             // глубина усреднения
input Smooth_Method MA_SMethod=MODE_JJMA;         // Метод сглаживания
input uint MA_Length=5;                           // Глубина сглаживания                    
input int MA_Phase=15;                            // параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей                  
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;       // ценовая константа
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; // объём 
input int HighLevel=+150;                         // уровень перекупленности
input int LowLevel=-150;                          // уровень перепроданности
input int Shift=0;                                // Сдвиг индикатора по горизонтали в барах 
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
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных 
   min_rates_total=2;
   int AtrPeriod=15;
//--- получение хендла индикатора XFisher_org_v1_Vol_Supr_Zer
   Ind_Handle=iCustom(Symbol(),TimeFrame,"XFisher_org_v1_Vol_Supr_Zer",FLength,MA_SMethod,MA_Length,MA_Phase,IPC,VolumeType,HighLevel,LowLevel,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XFisher_org_v1_Vol_Supr_Zer");
      return(INIT_FAILED);
     }
//---- превращение динамического массива IndBuffer[] в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer1,true);
//---- превращение динамического массива IndBuffer6[] в индикаторный буфер
   SetIndexBuffer(1,IndBuffer2,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer2,true);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//----
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer3,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer3,true);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//----   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,IndBuffer4,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer4,true);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
//----
//---- превращение динамического массива IndBuffer[] в индикаторный буфер
   SetIndexBuffer(4,IndBuffer5,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer5,true);
//---- превращение динамического массива IndBuffer6[] в индикаторный буфер
   SetIndexBuffer(5,IndBuffer6,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer6,true);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//----
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,IndBuffer7,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer7,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(7,IndBuffer8,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer8,true);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,110);
//----  
//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(8,IndBuffer9,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer9,true);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total+AtrPeriod);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикаторапо горизонтали
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(5,PLOT_ARROW,108);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(9,IndBuffer10,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer10,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
//---
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame,Ind_Handle,1,IndBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame,Ind_Handle,2,IndBuffer3,time,rates_total,prev_calculated,min_rates_total)) return(RESET);  
   if(!CountIndicator(3,NULL,TimeFrame,Ind_Handle,3,IndBuffer4,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(4,NULL,TimeFrame,Ind_Handle,4,IndBuffer5,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(5,NULL,TimeFrame,Ind_Handle,5,IndBuffer6,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(6,NULL,TimeFrame,Ind_Handle,6,IndBuffer7,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(7,NULL,TimeFrame,Ind_Handle,7,IndBuffer8,time,rates_total,prev_calculated,min_rates_total)) return(RESET);   
   if(!CountIndicator(8,NULL,TimeFrame,Ind_Handle,8,IndBuffer9,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(9,NULL,TimeFrame,Ind_Handle,9,IndBuffer10,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
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