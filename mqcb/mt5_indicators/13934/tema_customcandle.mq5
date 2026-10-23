//+------------------------------------------------------------------+
//|                                            TEMA_CUSTOMCandle.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "TEMA_CUSTOMCandle"
//---- номер версии индикатора
#property version   "1.00"
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrDeepPink,clrGray,clrBlue
//---- отображение метки индикатора
#property indicator_label1  "TEMA_CUSTOM Open;TEMA_CUSTOM High;TEMA_CUSTOM Low;TEMA_CUSTOM Close"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
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
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method MA_Method1=MODE_EMA_; // Метод усреднения первого сглаживания
input int Length1=12; // Глубина  первого сглаживания
input int Phase1=15;  // Параметр первого сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method2=MODE_EMA; // Метод усреднения второго сглаживания
input int Length2 = 5; // Глубина  второго сглаживания
input int Phase2=15;   // Параметр второго сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method MA_Method3=MODE_EMA; // Метод усреднения третьего сглаживания
input int Length3 = 5; // Глубина третьего сглаживания
input int Phase3=15;   // Параметр третьего сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_MEDIAN; // Ценовая константа, по которой производится расчет индикатора
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // Сдвиг индикатора по вертикали в пунктах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle[4];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_total=30;
//---- получение хендлов индикатора iTEMA_CUSTOM
   Ind_Handle[0]=iCustom(NULL,0,"TEMA_CUSTOM",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,MA_Method3,Length3,Phase3,PRICE_OPEN_,0,PriceShift);
   if(Ind_Handle[0]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iTEMA_CUSTOM["+string(0)+"]!");
      return(INIT_FAILED);
     }
//----
   Ind_Handle[1]=iCustom(NULL,0,"TEMA_CUSTOM",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,MA_Method3,Length3,Phase3,PRICE_HIGH_,0,PriceShift);
   if(Ind_Handle[1]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iTEMA_CUSTOM["+string(1)+"]!");
      return(INIT_FAILED);
     }
//----
   Ind_Handle[2]=iCustom(NULL,0,"TEMA_CUSTOM",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,MA_Method3,Length3,Phase3,PRICE_LOW_,0,PriceShift);
   if(Ind_Handle[2]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iTEMA_CUSTOM["+string(2)+"]!");
      return(INIT_FAILED);
     }
//----
   Ind_Handle[3]=iCustom(NULL,0,"TEMA_CUSTOM",MA_Method1,Length1,Phase1,MA_Method2,Length2,Phase2,MA_Method3,Length3,Phase3,PRICE_CLOSE_,0,PriceShift);
   if(Ind_Handle[3]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iTEMA_CUSTOM["+string(3)+"]!");
      return(INIT_FAILED);
     }
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для субъокон 
   string short_name="TEMA_CUSTOMCandle";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(Ind_Handle[0])<rates_total
      || BarsCalculated(Ind_Handle[1])<rates_total
      || BarsCalculated(Ind_Handle[2])<rates_total
      || BarsCalculated(Ind_Handle[3])<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar;
//---- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle[0],0,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[1],0,0,to_copy,ExtHighBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[2],0,0,to_copy,ExtLowBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[3],0,0,to_copy,ExtCloseBuffer)<=0) return(RESET);
//---- основной цикл исправления и окрашивания свечей
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      //----
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);
      //----
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
