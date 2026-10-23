//+---------------------------------------------------------------------+ 
//|                                                        si_q_asi.mq5 | 
//|                                             Copyright © 2006, Evbut | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2006, Evbut"
#property link ""
//---- номер версии индикатора
#property version   "1.00"
#property description "Краткосрочный и Аккумулятивный Индексы колебания цены. \nCurrent and Accumulative Swing Index"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 2
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots  1
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов индикатора использованы
#property indicator_color1 clrLime,clrDeepSkyBlue,clrGray,clrMagenta,clrRed
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1 3
//---- отображение метки индикатора
#property indicator_label1  "si_q_asi"
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_CHOIS
  {
   SwingIndex,                        //Краткросрочный индекс / Current Index
   AccumulativeIndex                  //Накопительный индекс / Accumulative Index
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input ENUM_CHOIS IndexType=SwingIndex;               //Тип индекса / Index Type
input int Shift=0;                                   //Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+

//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- получение хендла индикатора ATR
   int ATR_Period=15;
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=MathMax(ATR_Period,2);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали на InpKijun
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBuffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"si_q_asi("+EnumToString(IndexType)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,4);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных
   int to_copy,limit,bar;
   double SI,K,SH,R,ER,ATR[];
   static double SI_prev,ER_prev;

//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      SI_prev=NULL;
      ER_prev=NULL;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

   to_copy=limit+1;
   ER=ER_prev;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,MAIN_LINE,0,to_copy,ATR)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(Close[bar+1]>=Low[bar] && Close[bar+1]<=High[bar]) ER=NULL;
      else
        {
         if(Close[bar+1]>High[bar]) ER=MathAbs(High[bar]-Close[bar+1]);
         if(Close[bar+1]<Low[bar])  ER=MathAbs(Low[bar]-Close[bar+1]);
        }
      K=MathMax(MathAbs(High[bar]-Close[bar+1]),MathAbs(Low[bar]-Close[bar+1]));
      SH=MathAbs(Close[bar+1]-Open[bar+1]);
      R=ATR[bar]-0.5*ER+0.25*SH;
      if(!R) SI=NULL;
      else SI=50*(Close[bar]-Close[bar+1]+0.5*(Close[bar]-Open[bar])+0.25*(Close[bar+1]-Open[bar+1]))*(K/_Point)/R;
      if(IndexType==SwingIndex) IndBuffer[bar]=SI;
      else
        {
         IndBuffer[bar]=SI+SI_prev;
         if(bar) SI_prev=SI;
        }
      if(bar) ER_prev=ER;

      int clr=2;
      if(IndBuffer[bar]>=0)
        {
         if(IndBuffer[bar]>=IndBuffer[bar+1]) clr=0;
         else clr=1;
        }
      else
        {
         if(IndBuffer[bar]<=IndBuffer[bar+1]) clr=4;
         else clr=3;
        }
      ColorBuffer[bar]=clr;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
