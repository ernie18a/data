//+------------------------------------------------------------------+
//|                                             RSICandleKeltner.mq5 |
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "RSICandle Smoothed"
//---- номер версии индикатора
#property version   "1.00"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано семь буферов
#property indicator_buffers 7
//---- использовано всего два графических построения
#property indicator_plots   2
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrDeepPink,clrBlue,clrTeal
//---- отображение метки индикатора
#property indicator_label1  "RSICandle Open;RSICandle High;RSICandle Low;RSICandle Close"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора уровней      |
//+----------------------------------------------+
//---- отрисовка канала в виде облака
#property indicator_type2   DRAW_FILLING
//---- выбор цвета облака
#property indicator_color2  clrLavender
//---- отображение метки индикатора
#property indicator_label2  "Channels"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1  +70
#property indicator_level2  +50
#property indicator_level3  +30
#property indicator_levelcolor clrBlueViolet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint RSI_Period=14;
input int KeltnerPeriod=20; //период усреднения Келтнера
input double Ratio=3.01;    //девиация канала
input int Shift=0;          //сдвиг канала по горизонтали в барах
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double BorderTopBuffer[],BorderBotBuffer[];

//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int RSI_Handle[4],MA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_1=int(RSI_Period);
   min_rates_total=min_rates_1+int(KeltnerPeriod);

//---- получение хендла индикатора iRSI
   RSI_Handle[0]=iRSI(NULL,0,RSI_Period,PRICE_OPEN);
   if(RSI_Handle[0]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI["+string(0)+"]!");
      return(INIT_FAILED);
     }

   RSI_Handle[1]=iRSI(NULL,0,RSI_Period,PRICE_HIGH);
   if(RSI_Handle[1]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI["+string(1)+"]!");
      return(INIT_FAILED);
     }

   RSI_Handle[2]=iRSI(NULL,0,RSI_Period,PRICE_LOW);
   if(RSI_Handle[2]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI["+string(2)+"]!");
      return(INIT_FAILED);
     }

   RSI_Handle[3]=iRSI(NULL,0,RSI_Period,PRICE_CLOSE);
   if(RSI_Handle[3]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI["+string(3)+"]!");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMA
   MA_Handle=iMA(NULL,0,KeltnerPeriod,0,MODE_SMA,RSI_Handle[3]);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(5,BorderTopBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,BorderBotBuffer,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка канала
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- осуществление сдвига индикаторов по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
   ArraySetAsSeries(BorderTopBuffer,true);
   ArraySetAsSeries(BorderBotBuffer,true);

//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);

//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- имя для окон данных и метка для субъокон 
   string short_name="RSICandleKeltner";
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
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(RSI_Handle[0])<rates_total
      || BarsCalculated(RSI_Handle[1])<rates_total
      || BarsCalculated(RSI_Handle[2])<rates_total
      || BarsCalculated(RSI_Handle[3])<rates_total
      || BarsCalculated(MA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double MA[];

//---- расчёты необходимого количества копируемых данных и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle[0],0,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[1],0,0,to_copy,ExtHighBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[2],0,0,to_copy,ExtLowBuffer)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[3],0,0,to_copy,ExtCloseBuffer)<=0) return(RESET);
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
   
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(MA,true);

//---- Основной цикл исправления и окрашивания свечей
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);

      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);

      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;

      double Keltner=Ratio*GetKeltner(KeltnerPeriod,bar,ExtHighBuffer,ExtLowBuffer);
      BorderTopBuffer[bar]=MA[bar]+Keltner;
      BorderBotBuffer[bar]=MA[bar]-Keltner;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
// вычисление половины ширины канала Келтнера                        |
//+------------------------------------------------------------------+ 
double GetKeltner(int period,int bar,const double &High[],const double &Low[])
  {
//----
   double Resalt,sum=0;
   for(int iii=0; iii<period; iii++)
      sum+=High[bar+iii] - Low[bar+iii];
   Resalt = sum / period;
   return(Resalt);
//----
  }
//+------------------------------------------------------------------+
