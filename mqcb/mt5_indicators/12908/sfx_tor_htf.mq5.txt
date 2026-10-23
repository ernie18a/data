//+------------------------------------------------------------------+ 
//|                                                  SFX_TOR_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "SFX_TOR_HTF с фиксированным во входных параметрах таймфреймом"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- количество индикаторных буферов три
#property indicator_buffers 3 
//--- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                          // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "SFX_TOR"         // Константа для имени индикатора
#define SIZE 1                           // Константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color1  clrLimeGreen
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "ATR"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color2  clrMagenta
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2  "StdDev"
//+----------------------------------------------+
//| Параметры отрисовки StdDev MA индикатора     |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//--- в качестве цвета MA линии индикатора использован синий цвет
#property indicator_color3  clrDodgerBlue
//--- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//--- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//--- отображение медвежьей метки индикатора
#property indicator_label3  "StdDev MA"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 88.0
#property indicator_level2 50.0
#property indicator_level3 12.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Период графика индикатора
//---
input uint   ATR_period=12;
input uint   Std_period=12;
input  ENUM_MA_METHOD   Std_method=MODE_EMA;
input ENUM_APPLIED_PRICE   Std_price=PRICE_CLOSE;
input int   MAPeriod=3;
input  ENUM_MA_METHOD   MAType=MODE_SMMA;
input int    Shift1=0;     // Сдвиг ATR
input int    Shift2=0;     // Сдвиг Std
input int    Shift3=0;     // Сдвиг Std Ma
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
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
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора SFX_TOR
   Ind_Handle=iCustom(Symbol(),TimeFrame,"SFX_TOR",ATR_period,Std_period,Std_method,Std_price,MAPeriod,MAType);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора SFX_TOR");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,Ind1Buffer,EMPTY_VALUE,min_rates_total,Shift1);
   IndInit(1,Ind2Buffer,EMPTY_VALUE,min_rates_total,Shift2);
   IndInit(2,Ind3Buffer,EMPTY_VALUE,min_rates_total,Shift3);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
//---
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,Ind1Buffer,1,Ind2Buffer,2,Ind3Buffer,
      time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
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
//---
  }
//+------------------------------------------------------------------+
//| CountIndicator                                                   |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     BuffNumb1,       // Номер буфера обрабатываемого индикатора 1
                    double&  IndBuf1[],       // Приемный буфер индикатора 1
                    uint     BuffNumb2,       // Номер буфера обрабатываемого индикатора 2
                    double&  IndBuf2[],       // Приемный буфер индикатора 2
                    uint     BuffNumb3,       // Номер буфера обрабатываемого индикатора 3
                    double&  IndBuf3[],       // Приемный буфер индикатора 3
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
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb1,iTime[bar],1,Arr)<=0) return(RESET); IndBuf1[bar]=Arr[0];
         if(CopyBuffer(IndHandle,BuffNumb2,iTime[bar],1,Arr)<=0) return(RESET); IndBuf2[bar]=Arr[0];
         if(CopyBuffer(IndHandle,BuffNumb3,iTime[bar],1,Arr)<=0) return(RESET); IndBuf3[bar]=Arr[0];
        }
      else
        {
         IndBuf1[bar]=IndBuf1[bar+1];
         IndBuf2[bar]=IndBuf2[bar+1];
         IndBuf3[bar]=IndBuf3[bar+1];
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
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
