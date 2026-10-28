//+------------------------------------------------------------------+
//|                                                NRTR_ATR_STOP.mq5 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано 4 буфера
#property indicator_buffers 4
//---- использовано 4 графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован SeaGreen цвет
#property indicator_color1  clrSeaGreen
//---- линия индикатора 1 - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение метки линии индикатора
#property indicator_label1  "Upper NRTR_ATR_STOP"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет MediumVioletRed
#property indicator_color2  clrMediumVioletRed
//---- линия индикатора 2 - сплошная
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки линии индикатора
#property indicator_label2  "Lower NRTR_ATR_STOP"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет SpringGreen
#property indicator_color3  clrSpringGreen
//---- толщина индикатора 3 равна 4
#property indicator_width3  4
//---- отображение метки индикатора
#property indicator_label3  "Buy NRTR_ATR_STOP"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Red
#property indicator_color4  clrRed
//---- толщина индикатора 4 равна 4
#property indicator_width4  4
//---- отображение метки индикатора
#property indicator_label4  "Sell NRTR_ATR_STOP"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint ATR_Period=20;
input uint Coeficient=2;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_total=int(ATR_Period+1);
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(Symbol(),PERIOD_CURRENT,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- превращение динамического массива ExtMapBufferExtMapBufferUp[] в индикаторный буфер
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива ExtMapBufferDown[] в индикаторный буфер
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива ExtMapBufferUp1[] в индикаторный буфер
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,171);

//---- превращение динамического массива ExtMapBufferDown1[] в индикаторный буфер
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,171);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="NRTR_ATR_STOP";
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar,Trend;
   double REZ,ATR[];
   static int Trend_;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      Trend_=NULL;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);


//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//----    
   Trend=Trend_;

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtMapBufferUp[bar]=0.0;
      ExtMapBufferDown[bar]=0.0;
      ExtMapBufferUp1[bar]=0.0;
      ExtMapBufferDown1[bar]=0.0;
      REZ=Coeficient*ATR[bar];
      //----
      if(Trend<=0 && low[bar+1]>ExtMapBufferDown[bar+1])
        {
         ExtMapBufferUp[bar+1]=low[bar+1]-REZ;
         Trend=+1;
        }
      //----
      if(Trend>=0 && high[bar+1]<ExtMapBufferUp[bar+1])
        {
         ExtMapBufferDown[bar+1]=high[bar+1]+REZ;
         Trend=-1;
        }
      //----
      if(Trend>=0)
        {
         if(low[bar+1]>ExtMapBufferUp[bar+1]+REZ) ExtMapBufferUp[bar]=low[bar+1]-REZ;
         else ExtMapBufferUp[bar]=ExtMapBufferUp[bar+1];
        }
      //----
      if(Trend<=0)
        {
         if(high[bar+1]<ExtMapBufferDown[bar+1]-REZ) ExtMapBufferDown[bar]=high[bar+1]+REZ;
         else ExtMapBufferDown[bar]=ExtMapBufferDown[bar+1];
        }
        
      if(Trend>0 && Trend_<=0) ExtMapBufferUp1[bar]=ExtMapBufferUp[bar];
      if(Trend<0 && Trend_>=0) ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];

      if(bar) Trend_=Trend;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
