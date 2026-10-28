//+------------------------------------------------------------------+
//|                                        ChandelierExit_Candle.mq5 |
//|                                     Copyright © 2009, MQLService |
//|                                           scripts@mqlservice.com |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2009, MQLService"
#property link      "scripts@mqlservice.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки линии Sell StopLoss      |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMagenta,clrBrown,clrForestGreen,clrDarkTurquoise
//---- отображение метки индикатора
#property indicator_label1  "ChandelierExitOpen;ChandelierExitHigh;ChandelierExitLow;ChandelierExitClose"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+ 
//| Перечисление для ценовой константы           |
//+----------------------------------------------+ 
enum ENUM_PRICE_MODE   // Тип константы
  {
   CLOSE_CLOSE= 1,     //Close/Close
   HIGH_LOW            //High/low
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int RangePeriod=15;
input int Shift=1;
input int ATRPeriod=14;
input int MultipleATR=4;
input ENUM_PRICE_MODE PriceMode=CLOSE_CLOSE;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=MathMax(ATRPeriod,RangePeriod+Shift);

//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
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

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ChandelierExit(",RangePeriod,", ",ATRPeriod,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   static int direction;
   static double HH1,LL1;
   int to_copy,limit,bar;
   double ATR[],HH0,LL0,hi,lo,stop;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчёта всех баров
      direction=0;
      HH1=0;
      LL1=999999999;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- расчёт необходимого количества копируемых данных
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true); 
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtOpenBuffer[bar]=open[bar];
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer[bar]=low[bar];
      ExtCloseBuffer[bar]=close[bar];
      
      ATR[bar]*=MultipleATR;
      HH0=high[ArrayMaximum(high,bar+Shift,RangePeriod)]-ATR[bar];
      LL0=low[ArrayMinimum(low,bar+Shift,RangePeriod)]+ATR[bar];
      stop=close[bar];
      
      if(PriceMode==CLOSE_CLOSE)
        {
         hi=close[bar+1];
         lo=close[bar+1];
        }
      else 
        {
         hi=high[bar+1];
         lo=low[bar+1];
        }

      if(direction>=0)
        {
         if(hi<HH1)
           {
            if(bar) direction=-1;
            stop=LL0;
           }
         else stop=HH0;
        }
     else
     if(direction<=0)
        {
         if(lo>LL1)
           {
            if(bar) direction=+1;
            stop=HH0;
           }
         else stop=LL0;
        }        
      //----
      if(stop<=close[bar])
        {
         if(close[bar]>=open[bar]) ExtColorBuffer[bar]=3;
         else ExtColorBuffer[bar]=2;
        }
      //----
      if(stop>=close[bar])
        {
         if(close[bar]<=open[bar]) ExtColorBuffer[bar]=0;
         else ExtColorBuffer[bar]=1;
        }
      //----
      if(bar)
        {
         HH1=HH0;
         LL1=LL0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
