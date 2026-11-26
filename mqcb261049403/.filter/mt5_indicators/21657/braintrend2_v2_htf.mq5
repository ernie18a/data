//+---------------------------------------------------------------------+ 
//|                                              BrainTrend2_V2_HTF.mq5 | 
//|                                  Copyright © 2018, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\MQL5\Include         |
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                         // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "BrainTrend2_V2"                 // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLime,clrTeal,clrGray,clrMaroon,clrMagenta
//---- отображение метки индикатора
#property indicator_label1  "BrainTrend2_V2_Open;BrainTrend2_V2_High;BrainTrend2_V2_Low;BrainTrend2_V2_Close"
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Период графика
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint ATR_Period=7;
input uint NumberofBar=1;//Номер бара индикатора BrainTrend2_V2 для подачи сигнала
input bool SoundON=true; //Разрешение алерта
input uint NumberofAlerts=2;//Количество алертов
input bool EMailON=false; //Разрешение почтовой отправки сигнала
input bool PushON=false; //Разрешение отправки сигнала на мобильный
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
//---- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора BrainTrend2_V2 не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }

//---- Инициализация переменных 
   min_rates_total=2;
   string short_name=INDICATOR_NAME+" "+Symbol()+"("+GetStringTimeframe(_Period)+")";

//---- получение хендла индикатора BrainTrend2_V2
   Ind_Handle=iCustom(Symbol(),TimeFrame,"BrainTrend2_V2",ATR_Period,NumberofBar,SoundON,NumberofAlerts,EMailON,PushON);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора BrainTrend2_V2");
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
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
//--- основной цикл расчета индикатора
   if(!CountIndicatorBar(NULL,TimeFrame,Ind_Handle,time,open,high,low,close,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
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
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TimeFrame,Time[bar],1,IndTime)<=0) return(RESET);
      //---
      if(Time[bar]>=IndTime[0] && Time[bar+1]<IndTime[0])
        {
         LastCountBar=bar;
         double Col[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,4,Time[bar],1,Col)<=0) return(RESET);
         ExtOpenBuffer[bar]=Open[bar];
         ExtLowBuffer[bar]=Low[bar];
         ExtHighBuffer[bar]=High[bar];
         ExtCloseBuffer[bar]=Close[bar];
         if(Col[0]<2)
           {
            if(Open[bar]<=Close[bar]) ExtColorBuffer[bar]=0;
            else ExtColorBuffer[bar]=1;
           }
         else
           {
            if(Open[bar]>=Close[bar]) ExtColorBuffer[bar]=4;
            else ExtColorBuffer[bar]=3;
           }
        }
      else
        {
         ExtOpenBuffer[bar]=Open[bar];
         ExtLowBuffer[bar]=Low[bar];
         ExtHighBuffer[bar]=High[bar];
         ExtCloseBuffer[bar]=Close[bar];
         
         if(ExtColorBuffer[bar+1]<2)
           {
            if(Open[bar]<=Close[bar]) ExtColorBuffer[bar]=0;
            else ExtColorBuffer[bar]=1;
           }
         else
           {
            if(Open[bar]>=Close[bar]) ExtColorBuffer[bar]=4;
            else ExtColorBuffer[bar]=3;
           }
        }
     }
//---     
   return(true);
  }
//+------------------------------------------------------------------+
