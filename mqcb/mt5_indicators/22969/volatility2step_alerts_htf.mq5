//+------------------------------------------------------------------+ 
//|                                   Volatility2Step_Alerts_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "Volatility2Step_Alerts с возможностью изменения таймфрейма во входных параметрах"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- количество индикаторных буферов 1
#property indicator_buffers 1 
//--- использовано одно графическое построение
#property indicator_plots   1
//---- зафиксирован нихний предел отображения индикатора
#property indicator_minimum 0
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                  // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Volatility2Step_Alerts"  // Константа для имени индикатора
#define SIZE 1                                   // Константа для количества вызовов функции CountIndicator коде
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
//---- в качестве цвета бычей линии индикатора использован BlueViolet цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1  4
//---- отображение метки индикатора
#property indicator_label1  "Volatility2Step_Alerts"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;         // Период графика индикатора (таймфрейм)
input  ENUM_MA_METHOD   MAType=MODE_SMA;           // метод усреднения
input uint              VolatilityPeriod=5;        // период индикатора
input int               Shift=0;                   // сдвиг индикатора по горизонтали в барах
input uint              LevelsTotal=20;            // количество уровеней
input uint              StartLevel=25;             // стартовый уровень
input uint              LevelsStep=25;             // расстояние между уровнями
input color             LevelsColor=clrDarkOrange; // цвет уровеней
input uint AlertLevel=150;                      // Уровень срабатывания
input uint NumberofBar=1;                       // Номер бара для подачи сигнала
input bool SoundON=true;                        // Разрешение алерта
input uint NumberofAlerts=2;                    // Количество алертов
input bool EMailON=false;                       // Разрешение почтовой отправки сигнала
input bool PushON=false;                        // Разрешение отправки сигнала на мобильный
input color AlertLevelColor=clrMediumSeaGreen;  // цвет уровня срабатывания
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double IndBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
int LastCountBar[SIZE];
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
//--- получение хендла индикатора Volatility2Step_Alerts
   Ind_Handle=iCustom(Symbol(),TimeFrame,"Volatility2Step_Alerts",MAType,VolatilityPeriod,0,
                      LevelsTotal,StartLevel,LevelsStep,LevelsColor,AlertLevel,NumberofBar,SoundON,NumberofAlerts,EMailON,PushON,AlertLevelColor);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Volatility2Step_Alerts");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,IndBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,EMPTY_VALUE,0,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора LevelsTotal   
   IndicatorSetInteger(INDICATOR_LEVELS,LevelsTotal+1);
   for(int numb=0; numb<int(LevelsTotal); numb++)
     {
      int level=int(StartLevel+LevelsStep*numb);
      //---- значения горизонтальных уровней индикатора   
      IndicatorSetDouble(INDICATOR_LEVELVALUE,numb,level);
      //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,numb,LevelsColor);
      //---- в линии горизонтального уровня использован короткий штрих-пунктир  
      IndicatorSetInteger(INDICATOR_LEVELSTYLE,numb,STYLE_DASHDOTDOT);
     }
//---- значения уровня срабатывания индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,LevelsTotal,AlertLevel);
//---- в качестве цвета линии уровня срабатывания ипользован цвет  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,LevelsTotal,AlertLevelColor);
//---- в линии уровня срабатывания использована сплошная линия 
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,LevelsTotal,STYLE_SOLID);
//---- толщина линии уровня срабатывания 
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,LevelsTotal,3);
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
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,time,rates_total,prev_calculated,min_rates_total))
      return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
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
//---
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
                    const datetime& nTime[],  // Таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
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
      if(CopyTime(Symbol(),TFrame,nTime[bar],1,IndTime)<=0) return(RESET);

      if(nTime[bar]>=IndTime[0] && nTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,BuffNumb,nTime[bar],1,Arr)<=0) return(RESET);

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
