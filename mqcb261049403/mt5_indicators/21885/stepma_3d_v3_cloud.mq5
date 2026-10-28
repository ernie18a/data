//+------------------------------------------------------------------+
//|                                           StepMA_3D_v3_Cloud.mq5 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2006, TrendLaboratory"
//---- ссылка на сайт автора
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов линии индикатора использованы
#property indicator_color1  clrLimeGreen,clrMagenta
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//---- отображение метки индикатора
#property indicator_label1  "Upper StepMA_3D_v3"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color2  clrLightSkyBlue,clrPink
//---- отображение метки индикатора
#property indicator_label2  "Upper StepMA_3D_v3 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки среднего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color3  clrBlue
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "Middle StepMA_3D_v3"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color4  clrRed
//---- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение метки индикатора
#property indicator_label4  "Lower StepMA_3D_v3"
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_MA_MODE //Тип константы
  {
   MODE_SMA_,     //SMA
   MODE_LWMA_     //LWMA
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint    Length       = 10;         // Период ATR
input double  Kv           =  1.000001;  // Фактор чувствительности на изменения цены
input ENUM_MA_MODE MA_Mode = MODE_SMA_;  // Метод усреднения ATR
input int     Shift        =  0;         // сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],UpColorBuffer[],MiddleBuffer[],DnBuffer[];
double UpCldBuffer[],DnCldBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(Length)+1;

//---- превращение динамического массива UpBuffer в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(UpBuffer,true);
//---- превращение динамического массива UpBuffer в цветовой буфер
   SetIndexBuffer(1,UpColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(UpColorBuffer,true);
   
//---- превращение динамического массива UpCldBuffer в индикаторный буфер
   SetIndexBuffer(2,UpCldBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(UpCldBuffer,true);
//---- превращение динамического массива DnCldBuffer в индикаторный буфер
   SetIndexBuffer(3,DnCldBuffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(DnCldBuffer,true);

//---- превращение динамического массива MiddleBuffer в индикаторный буфер
   SetIndexBuffer(4,MiddleBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(MiddleBuffer,true);

//---- превращение динамического массива MiddleBuffer в индикаторный буфер
   SetIndexBuffer(5,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(DnBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"StepMA_3D_v3_Cloud(",Length,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
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
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,bar,TrendMin0,TrendMax0,TrendMid0;
   double StepSizeMin,StepSizeMax,StepSizeMid,AvgRange,Weight;
   double SminMin0,SmaxMin0,SminMax0,SmaxMax0,SminMid0,SmaxMid0,alfa,ATR0;
   static double SminMin1,SmaxMin1,SminMax1,SmaxMax1,SminMid1,SmaxMid1,ATRmax,ATRmin;
   static int TrendMin1,TrendMax1,TrendMid1;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      ATRmax=0.0;
      ATRmin=999999999.0;
      TrendMin1=TrendMax1=TrendMid1=0;
      SminMin1=SmaxMin1=SminMax1=SmaxMax1=SminMid1=SmaxMid1=close[limit+1];
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      AvgRange=0;
      Weight=0;
      for(int iii=int(Length)-1; iii>=0; iii--)
        {
         if(MA_Mode==MODE_SMA_) alfa=1.0;
         else alfa=1.0*(Length-iii)/Length;
         AvgRange+=alfa*(high[bar+iii]-low[bar+iii]);
         Weight+=alfa;
        }
      ATR0=AvgRange/Weight;
      //----
      if(ATR0>ATRmax) ATRmax=ATR0;
      if(ATR0<ATRmin) ATRmin=ATR0;
      //----
      StepSizeMin=MathRound(Kv*ATRmin/_Point)*_Point;
      StepSizeMax=MathRound(Kv*ATRmax/_Point)*_Point;
      StepSizeMid=MathRound(Kv*0.5*(ATRmax+ATRmin)/_Point)*_Point;
      //----
      SmaxMin0=close[bar]+2.0*StepSizeMin;
      SminMin0=close[bar]-2.0*StepSizeMin;
      //----
      SmaxMax0=close[bar]+2.0*StepSizeMax;
      SminMax0=close[bar]-2.0*StepSizeMax;
      //----
      SmaxMid0=close[bar]+2.0*StepSizeMid;
      SminMid0=close[bar]-2.0*StepSizeMid;
      //----
      TrendMin0=TrendMin1;
      TrendMax0=TrendMax1;
      TrendMid0=TrendMid1;
      //----
      if(close[bar]>SmaxMin1) TrendMin0=1;
      if(close[bar]<SminMin1) TrendMin0=-1;
      //----
      if(close[bar]>SmaxMax1) TrendMax0=1;
      if(close[bar]<SminMax1) TrendMax0=-1;
      //----
      if(close[bar]>SmaxMid1) TrendMid0=1;
      if(close[bar]<SminMid1) TrendMid0=-1;
      //----
      if(TrendMin0>0)
        {
         if(SminMin0<SminMin1) SminMin0=SminMin1;
         UpBuffer[bar]=SminMin0+StepSizeMin;
        }
      if(TrendMin0<0)
        {
         if(SmaxMin0>SmaxMin1) SmaxMin0=SmaxMin1;
         UpBuffer[bar]=SmaxMin0-StepSizeMin;
        }
      if(TrendMax0>0)
        {
         if(SminMax0<SminMax1) SminMax0=SminMax1;
         DnBuffer[bar]=DnCldBuffer[bar]=SminMax0+StepSizeMax;
        }

      if(TrendMax0<0)
        {
         if(SmaxMax0>SmaxMax1) SmaxMax0=SmaxMax1;
         DnBuffer[bar]=DnCldBuffer[bar]=SmaxMax0-StepSizeMax;
        }

      if(TrendMid0>0)
        {
         if(SminMid0<SminMid1) SminMid0=SminMid1;
         MiddleBuffer[bar]=UpCldBuffer[bar]=SminMid0+StepSizeMid;
        }

      if(TrendMid0<0)
        {
         if(SmaxMid0>SmaxMid1) SmaxMid0=SmaxMid1;
         MiddleBuffer[bar]=UpCldBuffer[bar]=SmaxMid0-StepSizeMid;
        }
      
      if(UpBuffer[bar]>DnBuffer[bar] && UpBuffer[bar]>MiddleBuffer[bar]) UpColorBuffer[bar]=0;
      else if(UpBuffer[bar]<DnBuffer[bar] && UpBuffer[bar]<MiddleBuffer[bar]) UpColorBuffer[bar]=1;
      else UpColorBuffer[bar]=UpColorBuffer[bar+1];
      
      
      if(bar)
        {
         SmaxMin1=SmaxMin0;
         SminMin1=SminMin0;
         SmaxMax1=SmaxMax0;
         SminMax1=SminMax0;
         SmaxMid1=SmaxMid0;
         SminMid1=SminMid0;
         //----
         TrendMin1=TrendMin0;
         TrendMax1=TrendMax0;
         TrendMid1=TrendMid0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
