//+------------------------------------------------------------------+
//|                                    ADX_Cross_Hull_Style_NRTR.mq5 | 
//|                                             Copyright © 2005,  . |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, ."
#property link      ""
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type1 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color1 clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width1 1
//---- отображение метки сигнальной линии
#property indicator_label1  "NRTR Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color2 clrRed
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2 1
//---- отображение метки сигнальной линии
#property indicator_label2  "NRTR Down"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован цвет Teal
#property indicator_color3  clrTeal
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение бычьей метки индикатора
#property indicator_label3  "Buy NRTR signal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован цвет Magenta
#property indicator_color4  clrMagenta
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Sell NRTR signal"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint ADXPeriod=14;//период индикатора
input int Shift=0; //сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double TrendUp[],TrendDown[];
double SignUp[],SignDown[];
//---- Объявление целых переменных для хендлов индикаторов
int ADX1_Handle,ADX2_Handle,ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int AtrPeriod=10;
   min_rates_total=int(MathMax(ADXPeriod+1,AtrPeriod));

//---- получение хендла индикатора ADX1
   ADX1_Handle=iADX(NULL,0,ADXPeriod);
   if(ADX1_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора ADX1");

//---- получение хендла индикатора ADX2
   ADX2_Handle=iADX(NULL,0,int(MathFloor(ADXPeriod/2.0)));
   if(ADX2_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора ADX2");

//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,AtrPeriod);
   if(ATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,TrendUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(TrendUp,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,TrendDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(TrendDown,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,SignUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignUp,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,171);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,SignDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignDown,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,171);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ADX_Cross_Hull_Style_NRTR(",ADXPeriod,", ",Shift,")");
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
   if(BarsCalculated(ADX1_Handle)<rates_total
      || BarsCalculated(ADX2_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit,to_copy,bar,trend;
   double pADX1[],pADX2[],mADX1[],mADX2[],ATR[];
   double b4plusdi,nowplusdi,b4minusdi,nowminusdi,newstop;
   static int trend_prev;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(pADX1,true);
   ArraySetAsSeries(pADX2,true);
   ArraySetAsSeries(mADX1,true);
   ArraySetAsSeries(mADX2,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчёта всех баров
      trend_prev=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
//----
   to_copy=limit+2;

//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(ADX1_Handle,PLUSDI_LINE,0,to_copy,pADX1)<=0) return(RESET);
   if(CopyBuffer(ADX2_Handle,PLUSDI_LINE,0,to_copy,pADX2)<=0) return(RESET);
   if(CopyBuffer(ADX1_Handle,MINUSDI_LINE,0,to_copy,mADX1)<=0) return(RESET);
   if(CopyBuffer(ADX2_Handle,MINUSDI_LINE,0,to_copy,mADX2)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy-1,ATR)<=0) return(RESET);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      TrendUp[bar]=NULL;
      TrendDown[bar]=NULL;
      SignUp[bar]=NULL;
      SignDown[bar]=NULL;
      trend=trend_prev;
      //----
      b4plusdi=pADX2[bar+1]*2-pADX1[bar+1];
      nowplusdi=pADX2[bar]*2-pADX1[bar];
      b4minusdi=mADX2[bar+1]*2-mADX1[bar+1];
      nowminusdi=mADX2[bar]*2-mADX1[bar];
      //----
      if(b4plusdi < b4minusdi && nowplusdi > nowminusdi) trend=+1;
      if(b4plusdi > b4minusdi && nowplusdi < nowminusdi) trend=-1;
      //----
      if(trend>0)
        {
         newstop=low[bar]-0.25*ATR[bar];
         if(trend_prev>0)
           {
            if(newstop>TrendUp[bar+1]) TrendUp[bar]=newstop;
            else TrendUp[bar]=TrendUp[bar+1];
           }
         else
           {
            SignUp[bar]=TrendUp[bar]=newstop;
           }
        }
      //---- 
      if(trend<0)
        {
         newstop=high[bar]+0.25*ATR[bar];
         if(trend_prev<0)
           {
            if(newstop<TrendDown[bar+1]) TrendDown[bar]=newstop;
            else TrendDown[bar]=TrendDown[bar+1];
           }
         else
           {
            SignDown[bar]=TrendDown[bar]=newstop;
           }
        }
      //----
      if(bar) trend_prev=trend;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
