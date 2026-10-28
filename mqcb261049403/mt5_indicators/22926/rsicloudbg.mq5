//+------------------------------------------------------------------+
//|                                                   RSICloudBG.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 10
#property indicator_buffers 10 
//---- использовано пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//| Параметры отрисовки верхнего облака 2        |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'130,255,211'
#property indicator_color1 C'130,255,211'
//---- отображение метки индикатора
#property indicator_label1  "Upper RSICloudBg_Cloud 2"
//+----------------------------------------------+
//| Параметры отрисовки верхнего облака 1        |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'202,255,237'
#property indicator_color2 C'202,255,237'
//---- отображение метки индикатора
#property indicator_label2  "Upper RSICloudBg_Cloud 1"
//+----------------------------------------------+
//| Параметры отрисовки нижнего облака 1         |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type3   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'255,225,255'
#property indicator_color3 C'255,225,255'
//---- отображение метки индикатора
#property indicator_label3  "Lower RSICloudBg_Cloud 1"
//+----------------------------------------------+
//| Параметры отрисовки нижнего облака 2         |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type4   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет C'255,185,255'
#property indicator_color4 C'255,185,255'
//---- отображение метки индикатора
#property indicator_label4  "Lower RSICloudBg_Cloud 2"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color5  clrLimeGreen,clrMagenta
//---- отображение метки индикатора
#property indicator_label5  "RSICloud"
//+----------------------------------------------+
//|  Пределы отображения индикатора              |
//+----------------------------------------------+
#property indicator_maximum 100
#property indicator_minimum 0
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint RSIPeriod=14;                        // Период RSI индикатора
input double HighLevel=70;                      // уровень перезакупа
input double LowLevel=30;                       // уровень перепроданности
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtABuffer[],ExtBBuffer[];
double UpUpBuffer1[],UpDnBuffer1[],DnUpBuffer1[],DnDnBuffer1[];
double UpUpBuffer2[],UpDnBuffer2[],DnUpBuffer2[],DnDnBuffer2[];
//---- Объявление целых переменных для хранения хендлов индикаторов
int IndA_Handle,IndB_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(RSIPeriod);

//--- получение хендла индикатора iRSI HIGH
   IndA_Handle=iRSI(Symbol(),PERIOD_CURRENT,RSIPeriod,PRICE_HIGH);
   if(IndA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI HIGH");
      return(INIT_FAILED);
     }

//--- получение хендла индикатора iRSI LOW
   IndB_Handle=iRSI(Symbol(),PERIOD_CURRENT,RSIPeriod,PRICE_LOW);
   if(IndB_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI LOW");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов  
   IndInit(0,UpUpBuffer2,INDICATOR_DATA);
   IndInit(1,UpDnBuffer2,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,EMPTY_VALUE,min_rates_total,0);
//--- инициализация индикаторных буферов  
   IndInit(2,UpUpBuffer1,INDICATOR_DATA);
   IndInit(3,UpDnBuffer1,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(1,EMPTY_VALUE,min_rates_total,0);

//--- инициализация индикаторных буферов  
   IndInit(4,DnUpBuffer1,INDICATOR_DATA);
   IndInit(5,DnDnBuffer1,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(2,EMPTY_VALUE,min_rates_total,0);
//--- инициализация индикаторных буферов  
   IndInit(6,DnUpBuffer2,INDICATOR_DATA);
   IndInit(7,DnDnBuffer2,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(3,EMPTY_VALUE,min_rates_total,0);
//--- инициализация индикаторных буферов  
   IndInit(8,ExtABuffer,INDICATOR_DATA);
   IndInit(9,ExtBBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(4,EMPTY_VALUE,min_rates_total,0);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"RSICloudBG("+string(RSIPeriod)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(Number,PLOT_SHOW_DATA,false);
//---
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
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
   if(rates_total<min_rates_total
      || BarsCalculated(IndA_Handle)<rates_total
      || BarsCalculated(IndB_Handle)<rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit;

//---- расчёты необходимого количества копируемых данных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(IndA_Handle,0,0,to_copy,ExtABuffer)<=0) return(RESET);
   if(CopyBuffer(IndB_Handle,0,0,to_copy,ExtBBuffer)<=0) return(RESET);

//---- Основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpUpBuffer2[bar]=100;
      UpDnBuffer2[bar]=HighLevel;
      UpUpBuffer1[bar]=HighLevel;
      UpDnBuffer1[bar]=50;
      //----      
      DnUpBuffer1[bar]=50;
      DnDnBuffer1[bar]=LowLevel;
      DnUpBuffer2[bar]=LowLevel;
      DnDnBuffer2[bar]=0;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
