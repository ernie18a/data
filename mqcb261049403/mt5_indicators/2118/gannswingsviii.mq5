//+------------------------------------------------------------------+
//|                                               GannSwingsVIII.mq5 |
//|                                           Copyright © 2005, Rosh |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2005, Rosh"
//--- ссылка на сайт автора
#property link "https://www.metaquotes.net"
//--- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в основном окне
#property indicator_chart_window
//--- для расчета и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//--- использовано пять графических построений
#property indicator_plots   5
//+-----------------------------------------------+
//|  Параметры отрисовки индикатора зигзага       |
//+-----------------------------------------------+
//--- отрисовка индикатора в виде секции
#property indicator_type1   DRAW_SECTION
//--- в качестве цвета линии индикатора использован Gold цвет
#property indicator_color1 clrGold
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- отображение метки индикатора
#property indicator_label1  "BinaryWave"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде значка
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color2  clrBlue
//--- линия индикатора 2 - штрих-пунктир
#property indicator_style2  STYLE_DASHDOTDOT
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение метки линии индикатора
#property indicator_label2  "Upper"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//--- в качестве цвета линии индикатора использован цвет MediumVioletRed
#property indicator_color3  clrMediumVioletRed
//--- линия индикатора 3 - штрих-пунктир
#property indicator_style3  STYLE_DASHDOTDOT
//--- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//--- отображение метки линии индикатора
#property indicator_label3  "Lower"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//--- в качестве цвета индикатора использован цвет DeepSkyBlue
#property indicator_color4  clrDeepSkyBlue
//--- толщина индикатора 4 равна 1
#property indicator_width4  1
//--- отображение метки индикатора
#property indicator_label4  "Buy"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 5 в виде значка
#property indicator_type5   DRAW_ARROW
//--- в качестве цвета индикатора использован цвет Magenta
#property indicator_color5  clrMagenta
//--- толщина индикатора 5 равна 1
#property indicator_width5  1
//--- отображение метки индикатора
#property indicator_label5  "Sell"
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Type
  {
   LITTLE=1,   // малая
   MIDLE,      // промежуточная
   MAIN        // основная
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Type  kind=LITTLE;            // Тип тенденции
input bool  MoveLastSwing=false;    // Сдвиг хвоста зигзага к нулевому бару для двух одинаковых баров по High или Low
input int   Shift=0;                // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SwingsBuffer[];
double HighsBuffer[];
double LowsBuffer[];
double TrendBuffer[];
double UpCloseOutSideBuffers[];
double DownCloseOutSideBuffers[];
//---
double SwingHigh,SwingLow;
int LastSwing,lowCounter,highCounter;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=2;

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SwingsBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SwingsBuffer,true);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,HighsBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(HighsBuffer,true);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,LowsBuffer,INDICATOR_DATA);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(LowsBuffer,true);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,159);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,UpCloseOutSideBuffers,INDICATOR_DATA);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(UpCloseOutSideBuffers,true);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,108);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,DownCloseOutSideBuffers,INDICATOR_DATA);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(DownCloseOutSideBuffers,true);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
//--- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,108);

//--- превращение динамического массива в буфер для хранения данных
   SetIndexBuffer(5,TrendBuffer,INDICATOR_CALCULATIONS);
//--- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(TrendBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"GannSwingsVIII");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double& High[],     // ценовой массив максимумов цены для расчета индикатора
                const double& Low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//--- объявления локальных переменных 
   int limit,bar,maxbar;
   bool nonOutSide;
//--- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
//---
   maxbar=rates_total-min_rates_total-1;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=maxbar;
      lowCounter=0;
      highCounter=0;                                  // стартовый номер для расчета всех баров
      LowsBuffer[limit]=Low[limit];
      SwingsBuffer[limit]=High[limit];
      SwingsBuffer[limit]=Low[limit];
      SwingHigh=High[limit];
      SwingLow=Low[limit];
      LastSwing=0;
      TrendBuffer[limit+1]=-1.0;
      TrendBuffer[limit]=-1.0;
     }
   else
     {
      limit=maxbar;
      lowCounter=0;
      highCounter=0;                                  // стартовый номер для расчета всех баров
      LowsBuffer[limit]=Low[limit];
      SwingsBuffer[limit]=High[limit];
      SwingsBuffer[limit]=Low[limit];
      SwingHigh=High[limit];
      SwingLow=Low[limit];
      LastSwing=0;
      TrendBuffer[limit+1]=-1.0;
      TrendBuffer[limit]=-1.0;
     }
//--- восстанавливаем значения переменных
   LastSwing+=limit;
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(bar!=maxbar)
        {
         UpCloseOutSideBuffers[bar]=0.0;
         DownCloseOutSideBuffers[bar]=0.0;
         SwingsBuffer[bar]=0.0;
         HighsBuffer[bar]=0.0;
         LowsBuffer[bar]=0.0;
        }
      //---
      nonOutSide=!((High[bar]>High[bar+1]) && (Low[bar]<Low[bar+1]));
      if(!nonOutSide)
        {
         if(Close[bar]>Open[bar]) UpCloseOutSideBuffers[bar]=(High[bar]+Low[bar])/2.0;
         else DownCloseOutSideBuffers[bar]=(High[bar]+Low[bar])/2.0;
        }
      //---
      if(High[bar]>SwingHigh)
        {
         highCounter++;
         SwingHigh=High[bar];
         HighsBuffer[bar]=SwingHigh;
        }
      //---
      if(Low[bar]<SwingLow)
        {
         lowCounter++;
         SwingLow=Low[bar];
         LowsBuffer[bar]=SwingLow;
        }
      //---
      TrendBuffer[bar]=TrendBuffer[bar+1];// если не будут изменений - тренд сохранится
      if(TrendBuffer[bar+1]==-1.0 && lowCounter==1)// && nonOutSide) 
        {
         if(LastSwing!=maxbar) SwingsBuffer[LastSwing]=0.0; // затрем предыдущий свинг
         LastSwing=bar;
         SwingHigh=High[bar];
         SwingLow=Low[bar];
         highCounter=0;
         lowCounter=0;
         SwingsBuffer[bar]=Low[bar];
         HighsBuffer[bar]=SwingHigh;
        }
      else
        {
         if(TrendBuffer[bar+1]==-1.0 && highCounter==kind)
           {
            LastSwing=bar;
            SwingHigh=High[bar];
            SwingLow=Low[bar];
            TrendBuffer[bar]=+1.0;
            highCounter=0;
            lowCounter=0;
            SwingsBuffer[bar]=High[bar];
            LowsBuffer[bar]=SwingLow;
           }
         else
           {
            if(TrendBuffer[bar+1]==-1.0 && Low[bar]==SwingLow && MoveLastSwing)
              {
               SwingsBuffer[LastSwing]=0.0;
               LastSwing=bar;
               SwingsBuffer[bar]=Low[bar];
              }
           }
        }
      if(TrendBuffer[bar+1]==+1.0 && highCounter==1)// && nonOutSide) 
        {
         if(LastSwing!=maxbar) SwingsBuffer[LastSwing]=0.0; // затрем предыдущий свинг
         LastSwing=bar;
         SwingHigh=High[bar];
         SwingLow=Low[bar];
         highCounter=0;
         lowCounter=0;
         SwingsBuffer[bar]=High[bar];
         LowsBuffer[bar]=SwingLow;
         // продолжение аптренда
        }
      else
        {
         if(TrendBuffer[bar+1]==+1.0 && lowCounter==kind)
           {
            LastSwing=bar;
            SwingHigh=High[bar];
            SwingLow=Low[bar];
            TrendBuffer[bar]=-1.0;
            highCounter=0;
            lowCounter=0;
            SwingsBuffer[bar]=Low[bar];
            HighsBuffer[bar]=SwingHigh;
            // разворот аптренда
           }
         else
           {
            if(TrendBuffer[bar+1]==1.0 && High[bar]==SwingHigh && MoveLastSwing)
              {
               SwingsBuffer[LastSwing]=0.0;
               LastSwing=bar;
               SwingsBuffer[bar]=High[bar];
              }
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+