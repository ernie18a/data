//+---------------------------------------------------------------------+ 
//|                                          ColorX2MA_x2_cloud_HTF.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\MQL5\Include         |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.62"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                              // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "ColorX2MA_x2_cloud"  // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  clrBlueViolet,clrMagenta
//---- отображение бычей лэйбы индикатора
#property indicator_label1  INDICATOR_NAME
//+----------------------------------------------+
//|  объявление перечислений                     |
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
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
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
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА       |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H1;//Период графика 1
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H4;//Период графика 2
//+-------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА       |
//+-------------------------------------+
input Smooth_Method MA_Method1=MODE_SMA_; //Метод усреднения первого сглаживания 
input uint Length1=12; //Глубина  первого сглаживания                    
input int Phase1=15; //Параметр первого сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_JJMA; //Метод усреднения второго сглаживания 
input uint Length2= 5; //Глубина  второго сглаживания 
input int Phase2=15;  //Параметр второго сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;//Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // Сдвиг индикатора по вертикали в пунктах
//+-------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle1,Ind_Handle2;
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
//---- проверка периодов графиков на корректность
   if(TimeFrame1<Period() && TimeFrame1!=PERIOD_CURRENT)
     {
      Print("Период графика 1 для индикатора ColorX2MA не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//---- проверка периодов графиков на корректность
   if(TimeFrame2<Period() && TimeFrame2!=PERIOD_CURRENT)
     {
      Print("Период графика 2 для индикатора ColorX2MA не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- Инициализация переменных 
   min_rates_total=2;

//---- получение хендла индикатора ColorX2MA 1
  Ind_Handle1=iCustom(Symbol(),TimeFrame1,"ColorX2MA",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,IPC,0,PriceShift);
   if(Ind_Handle1==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorX2MA 1");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ColorX2MA 2
  Ind_Handle2=iCustom(Symbol(),TimeFrame2,"ColorX2MA",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,IPC,0,PriceShift);
   if(Ind_Handle2==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ColorX2MA 2");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);

//---- превращение динамического массива в индикаторный буфер 
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame1)+","+GetStringTimeframe(TimeFrame2)+")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
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
   if(BarsCalculated(Ind_Handle1)<Bars(Symbol(),TimeFrame1)
      || BarsCalculated(Ind_Handle2)<Bars(Symbol(),TimeFrame2)) return(prev_calculated);

//---- объявления локальных переменных 
   double XM[1],Col[1];
   int limit1,limit2,bar;
   datetime XMTime[1];
   static uint LastCountBar1,LastCountBar2;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit1=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      limit2=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar1=rates_total;
      LastCountBar2=rates_total;
     }
   else
     {
      limit1=int(LastCountBar1)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 
      limit2=int(LastCountBar2)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

//---- основной цикл расчёта индикатора 1
   for(bar=limit1; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      UpBuffer[bar]=EMPTY_VALUE;
      //---- копируем вновь появившиеся данные в массив XMTime
      if(CopyTime(Symbol(),TimeFrame1,time[bar],1,XMTime)<=0) return(RESET);

      if(time[bar]>=XMTime[0] && time[bar+1]<XMTime[0])
        {
         LastCountBar1=bar;
         //---- копируем вновь появившиеся данные в массив XM
         if(CopyBuffer(Ind_Handle1,0,time[bar],1,XM)<=0) return(RESET);
         UpBuffer[bar]=XM[0];
        }
      else UpBuffer[bar]=UpBuffer[bar+1];
     }
//---- основной цикл расчёта индикатора 2
   for(bar=limit2; bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      DnBuffer[bar]=EMPTY_VALUE;
      //---- копируем вновь появившиеся данные в массив XMTime
      if(CopyTime(Symbol(),TimeFrame2,time[bar],1,XMTime)<=0) return(RESET);

      if(time[bar]>=XMTime[0] && time[bar+1]<XMTime[0])
        {
         LastCountBar2=bar;
         //---- копируем вновь появившиеся данные в массив XM
         if(CopyBuffer(Ind_Handle2,0,time[bar],1,XM)<=0) return(RESET);
         DnBuffer[bar]=XM[0];
        }
      else DnBuffer[bar]=DnBuffer[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
