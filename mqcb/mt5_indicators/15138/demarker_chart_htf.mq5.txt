//+------------------------------------------------------------------+ 
//|                                           DeMarker_Chart_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define SIZE 4                          // Константа для количества вызовов функции CountLine
#define RESET 0                         // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "DeMarker_Chart" // Константа для имени индикатора
//+----------------------------------------------+
//|Параметры отрисовки индикатора DeMarker Cloud |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов облака индикатора использованы
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "DeMarker Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора XMA          |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет HotPink
#property indicator_color2  clrHotPink
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "XMA"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора DeMarker     |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет BlueViolet
#property indicator_color3  clrBlueViolet
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "DeMarker"
//+----------------------------------------------+
//|  Объявление перечислений                     |
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
   MODE_AMA    //AMA
  };
//+----------------------------------------------+
//|  Объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
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
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;            // Период графика
input uint PeriodDeMarker=14;                         // Период индикатора DeMarker
input Smooth_Method XMA_Method=MODE_SMMA_;            // Метод усреднения
input uint XLength=12;                                // Глубина  усреднения
input int XPhase=15;                                  // Параметр сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input double Dev=1.0;                                 // Девиация ширины канала
input ENUM_APPLIED_PRICE  Applied_price=PRICE_CLOSE;  // Тип цены или handle
input uint  Level_DeMarker_UP = 70;                   // Уровень перекупленности
input uint  Level_DeMarker_DN = 30;                   // Уровень перепроданности
input int Shift=0;                                    // Сдвиг индикатора по горизонтали в барах  
//+-------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer1[],IndBuffer2[],IndBuffer3[],IndBuffer4[];
//--- объявление строковых переменных
string Symbol_,Word;
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
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора DeMarker_Chart не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//--- инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- получение хендла индикатора DeMarker_Chart
   Ind_Handle=iCustom(Symbol_,TimeFrame,"DeMarker_Chart",PeriodDeMarker,XMA_Method,XLength,XPhase,Dev,Applied_price,Level_DeMarker_UP,Level_DeMarker_DN,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора DeMarker_Chart");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer1,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer1,true);   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,IndBuffer2,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer2,true);   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,IndBuffer3,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer3,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,IndBuffer4,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer4,true);

//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME"(",GetStringTimeframe(TimeFrame),")");
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
//--- основной цикл расчета индикатора
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer1,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame,Ind_Handle,1,IndBuffer2,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame,Ind_Handle,2,IndBuffer3,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(3,NULL,TimeFrame,Ind_Handle,3,IndBuffer4,time,rates_total,prev_calculated,min_rates_total)) return(RESET);

//---     
   return(rates_total);
  }
//---
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
      if(CopyTime(Symbol_,TimeFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
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
