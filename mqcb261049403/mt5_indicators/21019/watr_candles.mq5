//+------------------------------------------------------------------+
//|                                                WATR_Candles.mq5  |
//|                      Written WizardSerg under article konkop in  |
//|                                        "Modern trading" #4/2001  |
//|                                  http://www.wizardserg.inweb.ru  |
//|                                              wizardserg@mail.ru  |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Written WizardSerg under article konkop in <Modern trading> #4/2001"
//---- ссылка на сайт автора
#property link      "http://www.wizardserg.inweb.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrDeepSkyBlue,clrBlue,clrGray,clrMaroon,clrOrchid
//---- отображение метки индикатора
#property indicator_label1  "WATROpen;WATRHigh;WATRLow;WATRClose"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                        // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int    WATR_K = 10;
input double WATR_M = 4.0;
input int    ATR=21;
input int    Shift=0; // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
bool AntiTrendBar(const double &Open[],const double &Close[],int index, double NRTR_Up_prev)
  {
//----
   bool res=(TrendUp(Close,index,NRTR_Up_prev) && (Close[index]<Open[index])) || (!TrendUp(Close,index,NRTR_Up_prev) && (Close[index]>Open[index]));
//----   
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
double CalcIndicValue(double &ATRArray[],const double &Close[],int index,bool trend)
  {
//----
   double res=Close[index];
   if(trend)res -= (WATR_K*_Point + WATR_M*ATRArray[index]);
   else     res += (WATR_K*_Point + WATR_M*ATRArray[index]);
//----   
   return(res);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
bool TrendUp(const double &Close[],int index, double NRTR_Up_prev)
  {
//----
   return(Close[index+1]>NRTR_Up_prev && NRTR_Up_prev);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=ATR;
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"WATR_Candles(",WATR_K,", ",WATR_M,", ",ATR,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
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
   int limit,to_copy,bar;
   double iATR_[],Up,Down;
   static double Up_prev,Down_prev;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(iATR_,true);

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      to_copy=rates_total;
      Up_prev=Down_prev=close[limit+1]-WATR_K*_Point;;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      to_copy=limit+1;
     }

//---- копируем вновь появившиеся данные в массив iATR_[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,iATR_)<=0) return(RESET);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(AntiTrendBar(open,close,bar,Up_prev))
        {
         Up=Up_prev;
         Down=Down_prev;
        }
      else
        {
         if(TrendUp(close,bar,Up_prev))
           {
            Up=CalcIndicValue(iATR_,close,bar,true);
            if(Up<Up_prev) Up=Up_prev;
            Down=NULL;
           }
         else
           {
            Down=CalcIndicValue(iATR_,close,bar,false);
            if(Down>Down_prev) Down=Down_prev;
            Up=NULL;
           }
        }
      //---- пересечения с ценой                 
      if(TrendUp(close,bar,Up_prev) && close[bar]<Up)
        {
         Down=CalcIndicValue(iATR_,close,bar,false);
         Up=NULL;
        }
      if((!TrendUp(close,bar,Up_prev)) && close[bar]>Down)
        {
         Up=CalcIndicValue(iATR_,close,bar,true);
         Down=NULL;
        }

      ExtOpenBuffer[bar]=open[bar];
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer[bar]=low[bar];
      ExtCloseBuffer[bar]=close[bar];
      
      if(Up)
        {
         if(open[bar]<=close[bar]) ExtColorsBuffer[bar]=0;
         else ExtColorsBuffer[bar]=1;
        }
      if(Down)
        {
          if(open[bar]>=close[bar]) ExtColorsBuffer[bar]=4;
         else ExtColorsBuffer[bar]=3;
        }

      if(bar)
        {
         Up_prev=Up;
         Down_prev=Down;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
