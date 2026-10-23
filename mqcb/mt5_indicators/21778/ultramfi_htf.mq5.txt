//+------------------------------------------------------------------+ 
//|                                                 UltraMFI_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "Индикатор UltraMFI с возможностью изменения таймфрейма во входных параметрах"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                    // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "UltraMFI"  // Константа для имени индикатора
#define SIZE  1                    // Константа для количества вызовов функции CountIndicator в коде
#define EMPTYVALUE EMPTY_VALUE     // Константа для неотображаемых значений индикатора
//+----------------------------------------------+
//|  Параметры отрисовки заливки                 |
//+----------------------------------------------+
//--- отрисовка индикатора в виде заливки между двумя линиями
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов заливки индикатора использованы зелёный цвет и оранжевый цвета
#property indicator_color1  clrLime, clrDarkOrange
//--- отображение метки индикатора
#property indicator_label1 INDICATOR_NAME " HTF"
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
   MODE_AMA,   // AMA
  };
//+----------------------------------------------+
//|  объявление перечисления                     |
//+----------------------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+----------------------------------------------+
//|  объявление перечисления                     |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,       // Сплошная линия
   DASH_,        // Штриховая линия
   DOT_,         // Пунктирная линия
   DASHDOT_,     // Штрих-пунктирная линия
   DASHDOTDOT_   // Штрих-пунктирная линия с двойными точками
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Период графика индикатора
input int MFI_Period=13; //период индикатора MFI
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём индикатора MFI 
//----
input Smooth_Method W_Method=MODE_JJMA; //метод усреднения
input int StartLength=3; //стартовый период усреднения                    
input int WPhase=100; //параметр усреднения,
                      //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
//----  
input uint Step=5; //шаг изменения периода
input uint StepsTotal=10; //количество изменений периода
//----
input Smooth_Method SmoothMethod=MODE_JJMA; //метод сглаживания
input int SmoothLength=3; //глубина сглаживания                    
input int SmoothPhase=100; //параметр сглаживания,
                           //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//----                          
input uint UpLevel=80; // уровень перезакупа в %%
input uint DnLevel=20; // уровень перепродажи в %%
input color UpLevelsColor=Blue; //цвет уровня перезакупа
input color DnLevelsColor=Blue; //цвет уровня перепродажи
input STYLE Levelstyle=DASH_;   //стиль уровней
input WIDTH  LevelsWidth=Width_1;  //толщина уровней
input int    Shift=0;                        // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
//--- Объявление целых переменных начала отсчета данных
int min_rates_total;
//--- Объявление целых переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора UltraMFI
   Ind_Handle=iCustom(Symbol(),TimeFrame,"UltraMFI",MFI_Period,VolumeType,W_Method,StartLength,WPhase,
                           Step,StepsTotal,SmoothMethod,SmoothLength,SmoothPhase,0,0,clrRed,clrRed,0,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора UltraMFI");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,Ind1Buffer);
   IndInit(1,Ind2Buffer);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTYVALUE);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",EnumToString(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);  
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- параметры отрисовки линий  
   IndicatorSetInteger(INDICATOR_LEVELS,2);  
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,StepsTotal*UpLevel/100);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);
//---  
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,StepsTotal*DnLevel/100);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);
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
   if(!CountIndicator(0,Symbol(),TimeFrame,Ind_Handle,0,Ind1Buffer,1,Ind2Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[])
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     UpBuffNumb,      // Номер буфера обрабатываемого индикатора для растущего тренда
                    double&  UpIndBuf[],      // Приемный буфер индикатора для растущего тренда
                    uint     DnBuffNumb,      // Номер буфера обрабатываемого индикатора  для падающего тренда
                    double&  DnIndBuf[],      // Приемный буфер индикатора  для падающего тренда
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
      UpIndBuf[bar]=EMPTYVALUE;
      DnIndBuf[bar]=EMPTYVALUE;

      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);

      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];

         //--- копируем вновь появившиеся данные в массив Arr
         if(CopyBuffer(IndHandle,UpBuffNumb,iTime[bar],1,Arr)<=0) return(RESET); UpIndBuf[bar]=Arr[0];
         if(CopyBuffer(IndHandle,DnBuffNumb,iTime[bar],1,Arr)<=0) return(RESET); DnIndBuf[bar]=Arr[0];
        }
      else
        {
         UpIndBuf[bar]=UpIndBuf[bar+1];
         DnIndBuf[bar]=DnIndBuf[bar+1];
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Период графика индикатора 1 (младший таймфрейм)
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
