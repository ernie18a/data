//+---------------------------------------------------------------------+ 
//|                                                  ColorJJRSX_HTF.mq5 | 
//|                                Copyright © 2010,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\MQL5\Include         |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "JJRSX" // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов гистограммы использованы
#property indicator_color1 clrRed,clrDarkOrange,clrGray,clrTeal,clrLime
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение бычей лэйбы индикатора
#property indicator_label1  INDICATOR_NAME
//+------------------------------------------+
//|  объявление перечислений                 |
//+------------------------------------------+
enum Applied_price //Тип константы
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
//+------------------------------------------+
//|  объявление перечислений                 |
//+------------------------------------------+
enum IndStyle //Стиль отображения индикатора
  {
   COLOR_LINE = DRAW_COLOR_LINE,          //Цветная линия
   COLOR_HISTOGRAM=DRAW_COLOR_HISTOGRAM,  //Цветная гистограмма
   COLOR_ARROW=DRAW_COLOR_ARROW           //Цветные значки
  };
//+-------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА       |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Период графика
input uint AlertCount=0;//количество подаваемых алертов
input uint SignalBar=1;//номер бара для сигнала, 0-текущий бар
//+-------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА       |
//+-------------------------------------+
input uint JurXPeriod=8; //период JurX
input uint JMAPeriod=3;  //период JMA
input int JMAPhase=100;   //параметр усреднения JMA,
                          // для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
input Applied_price IPC=PRICE_CLOSE_; //ценовая константа
input int Shift=0; //сдвиг индикатора по горизонтали в барах
input IndStyle Style=COLOR_HISTOGRAM; //стиль отображения JJRSX
input int HighLevel=+20; //верхний уровень срабатывания
input int MiddleLevel=0; //середина диапазона
input int LowLevel=-20;  //нижний уровень срабатывания
//+-------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//---- Объявление стрингов
string Symbol_,Word;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int JJRSX_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора ColorJJRSX не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- Инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- получение хендла индикатора ColorJJRSX
   JJRSX_Handle=iCustom(Symbol_,TimeFrame,"ColorJJRSX",JurXPeriod,JMAPeriod,JMAPhase,IPC,0,Style,HighLevel,MiddleLevel,LowLevel);
   if(JJRSX_Handle==INVALID_HANDLE)
    {
     Print(" Не удалось получить хендл индикатора ColorJJRSX");
     return(INIT_FAILED);
    }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- изменение стиля отображения индикатора   
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,Style);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,MiddleLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrPurple);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrPurple);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
   if(BarsCalculated(JJRSX_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- объявления локальных переменных 
   double JJRSX[1],Col[1];
   int limit,bar;
   datetime JJRSXTime[1];
   static uint UpCount,DnCount;
   static uint UpCount_,DnCount_;
   static double LastJJRSX=0.0;
   static uint LastCountBar;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      IndBuffer[bar]=EMPTY_VALUE;
      IndBuffer[bar]=2.0;

      //---- копируем вновь появившиеся данные в массив JJRSXTime
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,JJRSXTime)<=0) return(RESET);
      
      if(time[bar]>=JJRSXTime[0] && time[bar+1]<JJRSXTime[0])
        {
         LastCountBar=bar;
         
         //---- копируем вновь появившиеся данные в массив JJRSX
         if(CopyBuffer(JJRSX_Handle,1,time[bar],1,JJRSX)<=0) return(RESET);
         if(CopyBuffer(JJRSX_Handle,2,time[bar],1,Col)<=0) return(RESET);
         
         IndBuffer[bar]=JJRSX[0];
         ColorIndBuffer[bar]=Col[0];
        }
      else
        {
         IndBuffer[bar]=IndBuffer[bar+1];
         ColorIndBuffer[bar]=ColorIndBuffer[bar+1];
        }
     }

//---- сброс счётчиков алертов в нули
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
      UpCount_=0;
      DnCount_=0;
     }

//---- подача алерта для покупки
   if(UpCount<AlertCount && ColorIndBuffer[SignalBar]==4)
     {
      UpCount++;
      Alert(Word+": Сигнал на покупку по "+Symbol_);
     }

//---- подача алерта для продажи
   if(DnCount<AlertCount && ColorIndBuffer[SignalBar]==0)
     {
      DnCount++;
      Alert(Word+": Сигнал на продажу по "+Symbol_);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
