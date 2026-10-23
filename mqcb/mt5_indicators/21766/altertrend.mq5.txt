//+------------------------------------------------------------------+
//|                                                   AlterTrend.mq5 |
//|                                         Copyright © 2005, OlegVS |
//|                                                                  |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2005, OlegVS"
//--- ссылка на сайт автора
#property link      ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLime,clrGreen,clrBrown,clrDarkOrange
//---- отображение метки индикатора
#property indicator_label1  "AlterTrend_Open;AlterTrend_High;AlterTrend_Low;AlterTrend_Close"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int K=30;
input uint Kperiod=150;
input uint PerADX=14;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int ADX_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных
   min_rates_total=1+int(Kperiod+PerADX);
//---- получение хендла индикатора ADX
   ADX_Handle=iADX(NULL,0,PerADX);
   if(ADX_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ADX");
      return(INIT_FAILED);
     }
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="AlterTrend";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- завершение инициализации
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ADX_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//--- объявления локальных переменных 
   int limit,to_copy;
   double ADX[];

//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров   
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(ADX,true);
   
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ADX_Handle,0,0,to_copy,ADX)<=0) return(RESET);

//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtOpenBuffer[bar]=ExtLowBuffer[bar]=ExtHighBuffer[bar]=ExtCloseBuffer[bar]=NULL;
      ExtColorBuffer[bar]=4;

      
      int SSP=int(MathCeil(Kperiod/ADX[bar]));
      double AvgRange=0;
      for(int kkk=MathMin(bar+SSP,rates_total-1); kkk>=bar; kkk--) AvgRange+=MathAbs(high[kkk]-low[kkk]);
      double Range=AvgRange/(SSP+1);
      //----
      double SsMax=high[bar];
      double SsMin=low[bar];
      //----
      for(int iii=MathMin(bar+SSP-1,rates_total-1); iii>bar; iii--)
        {
         double price=high[iii];
         if(SsMax<price) SsMax=price;
         price=low[iii];
         if(SsMin>=price) SsMin=price;
        }
      //----
      double smin=SsMin+(SsMax-SsMin)*K/100;
      double smax=SsMax-(SsMax-SsMin)*K/100;
      //----
      if(close[bar]<smin)
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtCloseBuffer[bar]=close[bar];
         if(close[bar]<=open[bar]) ExtColorBuffer[bar]=3;
         else ExtColorBuffer[bar]=2;
        }
      if(close[bar]>smax)
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtCloseBuffer[bar]=close[bar];
         if(close[bar]>=open[bar]) ExtColorBuffer[bar]=0;
         else ExtColorBuffer[bar]=1;
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
