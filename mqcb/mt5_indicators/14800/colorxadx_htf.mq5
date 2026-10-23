//+------------------------------------------------------------------+ 
//|                                                ColorXADX_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "ColorXADX с фиксированным во входных параметрах таймфреймом"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                               // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "ColorXADX_HTF"        // константа для имени индикатора
#define SIZE 1                                // константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+
//| Параметры отрисовки индикатора XDi           |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrLime,clrRed
//---- отображение метки индикатора
#property indicator_label1  "XDi"
//+----------------------------------------------+
//| Параметры отрисовки индикатора XADX Line     |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета  линии индикатора использован серый цвет
#property indicator_color2  clrGray
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "XADX Line"
//+----------------------------------------------+
//| Параметры отрисовки ADX индикатора           |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_COLOR_ARROW
//---- в качестве цветов ADX линии индикатора использованы
#property indicator_color3  clrGray,clrBlue,clrMagenta,clrRed
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение метки индикатора
#property indicator_label3  "XADX"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Smooth_Method
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  };
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum ENUM_WIDTH //тип константы
  {
   w_1=0,  //1
   w_2,    //2
   w_3,    //3
   w_4,    //4
   w_5     //5
  };

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;   // Период графика индикатора
//---
input Smooth_Method XMA_Method=MODE_T3; // Метод усреднения гистограммы
input uint ADX_Period=14; // Период XMA усреднения
input int ADX_Phase=100; // Параметр XMA усреднения
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE_;// Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input uint ExtraHighLevel=60; // Уровень максимального тренда
input uint HighLevel=40; // Уровень сильного тренда
input uint LowLevel=20;// Уровень слабого тренда
input ENUM_LINE_STYLE LevelStyle=STYLE_DASHDOTDOT; // Стиль линий уровней
input color LevelColor=clrBlue; // Цвет уровней
input ENUM_WIDTH LevelWidth=w_1; // Толщина уровней
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
double Ind4Buffer[];
double Ind5Buffer[];
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
//--- получение хендла индикатора ColorXADX
   Ind_Handle=iCustom(Symbol(),TimeFrame,"ColorXADX",XMA_Method,ADX_Period,ADX_Phase,IPC,0,ExtraHighLevel,HighLevel,LowLevel,LevelStyle,LevelColor,LevelWidth);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorXADX");
      return(INIT_FAILED);
     }
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,Ind1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Ind2Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,Ind3Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,Ind4Buffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,Ind5Buffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ind1Buffer,true);
   ArraySetAsSeries(Ind2Buffer,true);
   ArraySetAsSeries(Ind3Buffer,true);
   ArraySetAsSeries(Ind4Buffer,true);
   ArraySetAsSeries(Ind5Buffer,true);

//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- осуществление сдвига начала отсчета отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
//---
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0.0);
//---- параметры отрисовки уровней индикатора
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtraHighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelWidth);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelWidth);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2,LevelWidth);
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
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,
      0,Ind1Buffer,1,Ind2Buffer,2,Ind3Buffer,3,Ind4Buffer,4,Ind5Buffer,
      time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
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
                    uint     BuffNumb4,       // Номер буфера обрабатываемого индикатора 4
                    double&  IndBuf4[],       // Приемный буфер индикатора 4
                    uint     BuffNumb5,       // Номер буфера обрабатываемого индикатора 5
                    double&  IndBuf5[],       // Приемный буфер индикатора 5
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
         if(CopyBuffer(IndHandle,BuffNumb4,iTime[bar],1,Arr)<=0) return(RESET); IndBuf4[bar]=Arr[0];
         if(CopyBuffer(IndHandle,BuffNumb5,iTime[bar],1,Arr)<=0) return(RESET); IndBuf5[bar]=Arr[0];
        }
      else
        {
         IndBuf1[bar]=IndBuf1[bar+1];
         IndBuf2[bar]=IndBuf2[bar+1];
         IndBuf3[bar]=IndBuf3[bar+1];
         IndBuf4[bar]=IndBuf4[bar+1];
         IndBuf5[bar]=IndBuf5[bar+1];
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
