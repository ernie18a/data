//+------------------------------------------------------------------+ 
//|                                AbsolutelyNoLagLwma_Digit_HTF.mq5 | 
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.70"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                        // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "AbsolutelyNoLagLwma_Digit_HTF" // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrViolet,clrGray,clrDodgerBlue
//---- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//---- отображение бычей лэйбы индикатора
#property indicator_label1  INDICATOR_NAME
//+----------------------------------------------+
//|  объявление перечислений                     |
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
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Период графика
input uint AlertCount=0;//количество подаваемых алертов
input uint SignalBar=1;//номер бара для сигнала, 0-текущий бар
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input string  SirName="AbsolutelyNoLagLwma_Digit";     //Первая часть имени графических объектов
input uint Length=7;                                   //глубина сглаживания                   
input Applied_price_ IPC=PRICE_CLOSE_;                 //ценовая константа
input int Shift=0;                                     //сдвиг по горизонтали в барах
input int PriceShift=0;                                //cдвиг по вертикали в пунктах
input uint Digit=2;                                    //количество разрядов округления
input bool ShowPrice=true;                             //показывать ценовые метки
//---- цвета ценовых меток
input color  UpPrice_color=clrMediumSeaGreen;          //цвет цены выше мувинга
input color  Price_color=clrGray;                      //цвет цены равен мувингу
input color  DnPrice_color=clrRed;                     //цвет цены ниже мувинга
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//---- Объявление стрингов
string Symbol_,Word;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора AbsolutelyNoLagLwma_Digit не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- Инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);

//---- получение хендла индикатора AbsolutelyNoLagLwma_Digit
   Ind_Handle=iCustom(Symbol_,TimeFrame,"AbsolutelyNoLagLwma_Digit",SirName,Length,IPC,0,PriceShift,Digit,ShowPrice,UpPrice_color,Price_color,DnPrice_color);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора AbsolutelyNoLagLwma_Digit");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);

//---- объявления локальных переменных 
   double Ind[1],Col[1];
   int limit,bar;
   datetime IndTime[1];
   static uint UpCount,DnCount;
   static uint UpCount_,DnCount_;
   static double LastInd=0.0;
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
      IndBuffer[bar]=NULL;
      IndBuffer[bar]=1.0;

      //---- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,IndTime)<=0) return(RESET);

      if(time[bar]>=IndTime[0] && time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;

         //---- копируем вновь появившиеся данные в массив Ind
         if(CopyBuffer(Ind_Handle,0,time[bar],1,Ind)<=0) return(RESET);
         if(CopyBuffer(Ind_Handle,1,time[bar],1,Col)<=0) return(RESET);

         IndBuffer[bar]=Ind[0];
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
   if(UpCount<AlertCount && ColorIndBuffer[SignalBar]==2 && ColorIndBuffer[SignalBar+1]!=2)
     {
      UpCount++;
      Alert(Word+": Сигнал на покупку по "+Symbol_);
     }

//---- подача алерта для продажи
   if(DnCount<AlertCount && ColorIndBuffer[SignalBar]==0 && ColorIndBuffer[SignalBar+1]!=0)
     {
      DnCount++;
      Alert(Word+": Сигнал на продажу по "+Symbol_);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
