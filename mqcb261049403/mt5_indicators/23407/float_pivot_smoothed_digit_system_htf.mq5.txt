//+------------------------------------------------------------------+ 
//|                        Float_Pivot_Smoothed_Digit_System_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.70"
#property description "Float_Pivot_Smoothed_Digit_System с фиксированным во входных параметрах таймфреймом"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//--- для расчета и отрисовки индикатора использовано тринадцать буферов
#property indicator_buffers 12
//--- использовано шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                                     // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Float_Pivot_Smoothed_Digit_System"          // Константа для имени индикатора
#define SIZE 12                                                     // Константа для количества вызовов функции CountIndicator в коде
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован PaleGreen
#property indicator_color1  C'241,254,241'
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхней границы         |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован DodgerBlue
#property indicator_color2  clrDodgerBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Upper FloatPivot"
//+----------------------------------------------+
//|  Параметры отрисовки средней линии           |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован SlateBlue
#property indicator_color3  clrSlateBlue
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Middle FloatPivot"
//+----------------------------------------------+
//|  Параметры отрисовки нижней границы          |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован DeepPink
#property indicator_color4  clrDeepPink
//---- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Lower FloatPivot"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//---- в качестве цвета облака использован C'253,238,253'
#property indicator_color5  C'253,238,253'
//---- отображение метки индикатора
#property indicator_label5  "Lower Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 6            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветных свеч
#property indicator_type6 DRAW_COLOR_CANDLES
//---- в качестве цветов индикатора использованы
#property indicator_color6 clrDeepPink,clrPurple,clrGray,clrMediumBlue,clrDodgerBlue
//---- линия индикатора - сплошная
#property indicator_style6 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width6 2
//---- отображение метки индикатора
#property indicator_label6 "Float_Pivot_Smoothed_Digit Open;Float_Pivot_Smoothed_Digit High;Float_Pivot_Smoothed_Digit Low;Float_Pivot_Smoothed_Digit Close"
//+-----------------------------------------+
//|  объявление перечислений                |
//+-----------------------------------------+
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
//+-----------------------------------------+
//|  объявление перечислений                |
//+-----------------------------------------+
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
   PRICE_TRENDFOLLOW1_,  //PRICE_TRENDFOLLOW0_2
   PRICE_DEMARK_         //Demark Price 
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;             //Период графика индикатора
//---
input string  SirName="Float_Pivot_Digit";         //Первая часть имени графических объектов
input int IPeriod=100;                             //Период поиска экстремумов
input ENUM_APPLIED_PRICE_ IPC=PRICE_MEDIAN_;       //ценовая константа
input Smooth_Method     HMA_Method=MODE_SMA_;      //Метод сглаживания
input uint              HLength=12;                //Глубина  сглаживания                    
input int               HPhase=100;                //Параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input uint Shift=3;                                //сдвиг индикатора по горизонтали в барах
input uint Digit=2;                                //количество разрядов округления
input bool ShowPrice=true;                         //показывать ценовые метки
input color Upper_color=clrTeal;                   //Цвет верхней ценовой метки
input color Middle_color=clrBlue;                  //Цвет средней ценовой метки
input color Lower_color=clrMagenta;                //Цвет нижней ценовой метки
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtUp1Buffer[];
double ExtUp2Buffer[];
double ExtABuffer[];
double ExtBBuffer[];
double ExtCBuffer[];
double ExtDn1Buffer[];
double ExtDn2Buffer[];
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];

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
   min_rates_total=100;
//--- получение хендла индикатора Float_Pivot_Smoothed_Digit_System
   Ind_Handle=iCustom(Symbol(),TimeFrame,"Float_Pivot_Smoothed_Digit_System",
                      SirName,IPeriod,IPC,HMA_Method,HLength,HPhase,Shift,Digit,ShowPrice,Upper_color,Middle_color,Lower_color);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Float_Pivot_Smoothed_Digit_System");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtUp1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtUp2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
//PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtABuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
//PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtBBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
//PlotIndexSetInteger(2,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,ExtCBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
//PlotIndexSetInteger(3,PLOT_SHIFT,Shift);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,ExtDn1Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtDn2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
//PlotIndexSetInteger(4,PLOT_SHIFT,Shift);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(7,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,ExtCloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(11,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtUp1Buffer,true);
   ArraySetAsSeries(ExtUp2Buffer,true);
   ArraySetAsSeries(ExtABuffer,true);
   ArraySetAsSeries(ExtBBuffer,true);
   ArraySetAsSeries(ExtCBuffer,true);
   ArraySetAsSeries(ExtDn1Buffer,true);
   ArraySetAsSeries(ExtDn2Buffer,true);
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
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
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----   
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,ExtUp1Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(1,NULL,TimeFrame,Ind_Handle,1,ExtUp2Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(2,NULL,TimeFrame,Ind_Handle,2,ExtABuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(3,NULL,TimeFrame,Ind_Handle,3,ExtBBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(4,NULL,TimeFrame,Ind_Handle,4,ExtCBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(5,NULL,TimeFrame,Ind_Handle,5,ExtDn1Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicator(6,NULL,TimeFrame,Ind_Handle,6,ExtDn2Buffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
   if(!CountIndicatorBar(NULL,TimeFrame,Ind_Handle,time,open,high,low,close,rates_total,prev_calculated,min_rates_total)) return(RESET);
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
         if(CopyBuffer(IndHandle,BuffNumb,Time[bar]-Shift*PeriodSeconds(TimeFrame),1,Arr)<=0) return(RESET);
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
//| CountIndicatorBar                                                |
//+------------------------------------------------------------------+
bool CountIndicatorBar(string   Symb,            // Символ графика
                       ENUM_TIMEFRAMES TFrame,   // Период графика
                       int      IndHandle,       // Хендл обрабатываемого индикатора                                                                                 
                       const datetime &Time[],   // Таймсерия времени
                       const double &Open[],     // Таймсерия iOpen
                       const double &High[],     // Таймсерия iHigh
                       const double &Low[],      // Таймсерия iLow
                       const double &Close[],    // Таймсерия iClose
                       const int Rates_Total,    // количество истории в барах на текущем тике
                       const int Prev_Calculated,// количество истории в барах на предыдущем тике
                       const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar;
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar=limit;
     }
   else limit=LastCountBar+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtOpenBuffer[bar]=ExtCloseBuffer[bar]=ExtHighBuffer[bar]=ExtLowBuffer[bar]=NULL;
      ExtColorBuffer[bar]=2;
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TimeFrame,Time[bar],1,IndTime)<=0) return(RESET);
      //---
      if(Time[bar]>=IndTime[0] && Time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         double Col[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,11,Time[bar],1,Col)<=0) return(RESET);

         ExtColorBuffer[bar]=2;
         if(Col[0]>2)
           {
            if(Open[bar]<=Close[bar]) ExtColorBuffer[bar]=4;
            else ExtColorBuffer[bar]=3;
            ExtOpenBuffer[bar]=Open[bar];
            ExtLowBuffer[bar]=Low[bar];
            ExtHighBuffer[bar]=High[bar];
            ExtCloseBuffer[bar]=Close[bar];
           }
         else if(Col[0]<2)
           {
            if(Open[bar]>=Close[bar]) ExtColorBuffer[bar]=0;
            else ExtColorBuffer[bar]=1;
            ExtOpenBuffer[bar]=Open[bar];
            ExtLowBuffer[bar]=Low[bar];
            ExtHighBuffer[bar]=High[bar];
            ExtCloseBuffer[bar]=Close[bar];
           }
        }
      else
        {
         if(ExtColorBuffer[bar+1]>2)
           {
            if(Open[bar]<=Close[bar]) ExtColorBuffer[bar]=4;
            else ExtColorBuffer[bar]=3;
            ExtOpenBuffer[bar]=Open[bar];
            ExtLowBuffer[bar]=Low[bar];
            ExtHighBuffer[bar]=High[bar];
            ExtCloseBuffer[bar]=Close[bar];
           }
         else if(ExtColorBuffer[bar+1]<2)
           {
            if(Open[bar]>=Close[bar]) ExtColorBuffer[bar]=0;
            else ExtColorBuffer[bar]=1;
            ExtOpenBuffer[bar]=Open[bar];
            ExtLowBuffer[bar]=Low[bar];
            ExtHighBuffer[bar]=High[bar];
            ExtCloseBuffer[bar]=Close[bar];
           }
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
