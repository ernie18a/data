//+------------------------------------------------------------------+ 
//|                                                 ReversalNavi.mq5 | 
//|                                         Copyright © 2015, fxborg | 
//|                                  http://blog.livedoor.jp/fxborg/ | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Copyright © 2015, fxborg"
//---- авторство индикатора
#property link      "http://blog.livedoor.jp/fxborg/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано восемь буферов
#property indicator_buffers 8
//---- использовано шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора 1  |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован Red цвет
#property indicator_color1  clrRed
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение медвежьей метки индикатора
#property indicator_label1  "Sell Reversal Bar Mark"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора 1     |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение бычьей метки индикатора
#property indicator_label2 "Buy Reversal Bar Mark"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора 2  |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован Red цвет
#property indicator_color3  clrRed
//--- толщина линии индикатора 3 равна 4
#property indicator_width3  4
//--- отображение медвежьей метки индикатора
#property indicator_label3  "Sell Reversal Bar"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора 2     |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован DodgerBlue цвет
#property indicator_color4  clrDodgerBlue
//--- толщина линии индикатора 4 равна 4
#property indicator_width4  4
//--- отображение бычьей метки индикатора
#property indicator_label4 "Buy Reversal Bar"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора 3  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type5   DRAW_LINE
//---- в качестве цвета линии индикатора использован Red цвет
#property indicator_color5 clrRed
//---- линия индикатора - сплошная линия
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width5  2
//---- отображение метки индикатора
#property indicator_label5  "Sell Reversal Bar Line"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора 3     |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type6   DRAW_LINE
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color6 clrDodgerBlue
//---- линия индикатора - сплошная линия
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width6  2
//---- отображение метки индикатора
#property indicator_label6  "Buy Reversal Bar Line"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int InpHiLoPeriod=8; // High Low Period
input int InpStanbyBars=8; // Stanby Bars
int CalcBarCount=4;        // Calc Bar Count
input int Shift=0;         // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtTopBuffer[];
double ExtBtmBuffer[];
double ExtSellStandbyBuffer[];
double ExtBuyStandbyBuffer[];
double ExtSellLineBuffer[];
double ExtBuyLineBuffer[];
//---- for calc 
double ExtHighesBuffer[];
double ExtLowesBuffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   int ATR_Period=10;
   min_rates_total=int(MathMax(InpHiLoPeriod+InpStanbyBars+CalcBarCount,ATR_Period));

//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtTopBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,218);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtBtmBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,217);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtSellStandbyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtBuyStandbyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- осуществление сдвига индикатора 4 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,ExtSellLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,ExtBuyLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,ExtHighesBuffer,INDICATOR_CALCULATIONS);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,ExtLowesBuffer,INDICATOR_CALCULATIONS);

//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ReversalNavi(",InpHiLoPeriod,", ",InpStanbyBars,", ",Shift,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление локальных переменных 
   int first,bar;
   double dmin,dmax,entry_point,range_lo,range_hi,ATR[1];
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=min_rates_total;                   // стартовый номер для расчета всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//----
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- calculate range spread
      dmin=1000000.0;
      dmax=-1000000.0;
      for(int iii=bar-int(InpHiLoPeriod)+1; iii<=bar; iii++)
        {
         if(dmin>low[iii]) dmin=low[iii];
         if(dmax<high[iii]) dmax=high[iii];
        }
      ExtLowesBuffer[bar]=dmin;
      ExtHighesBuffer[bar]=dmax;
      ExtBuyStandbyBuffer[bar]=NULL;
      ExtSellStandbyBuffer[bar]=NULL;
      ExtBuyLineBuffer[bar]=NULL;
      ExtSellLineBuffer[bar]=NULL;
      ExtTopBuffer[bar]=NULL;
      ExtBtmBuffer[bar]=NULL;
     }
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //--- buy
      int btm_pos=bar-1;
      for(int iii=bar-1; iii>1; iii--)
        {
         if(ExtLowesBuffer[iii-2]>ExtLowesBuffer[iii-1] && ExtLowesBuffer[iii-1]==ExtLowesBuffer[iii])
           {
            btm_pos=iii-1;
            break;
           }
        }
      int setup=NULL;
      for(int iii=btm_pos; iii<=bar-1; iii++)
        {
         if(ExtBuyStandbyBuffer[iii])
           {
            setup=iii;
            break;
           }
        }
      //--- entry line
      entry_point=NULL;
      range_lo=1000000.0;
      range_hi=-1000000.0;
      if(!setup || bar-setup<=int(InpStanbyBars))
        {
         for(int iii=btm_pos; iii<=bar-1; iii++)
           {
            if(range_hi<high[iii])range_hi=high[iii];
            if(range_lo>low[iii])range_lo=low[iii];
           }
         //---
         entry_point=(range_hi+range_lo)/2;
         ExtBuyLineBuffer[bar]=entry_point;
        }
      //---
      if(MathMin(low[bar-4],MathMin(low[bar-3],low[bar-2]))<low[bar-1])
        {
         if(!setup)
           {
            //---- копируем вновь появившиеся данные в массив
            if(CopyBuffer(ATR_Handle,0,time[btm_pos],1,ATR)<=0) return(RESET);
            ExtBtmBuffer[btm_pos]=low[btm_pos]-MathMax(ATR[0]*3/8,5*_Point);
            ExtBuyStandbyBuffer[bar]=entry_point;
           }
         //else ExtBtmBuffer[btm_pos]=NULL;
        }
      //--- sell
      int top_pos=bar-1;
      for(int iii=bar-1; iii>1; iii--)
        {
         if(ExtHighesBuffer[iii-2]<ExtHighesBuffer[iii-1] && ExtHighesBuffer[iii-1]==ExtHighesBuffer[iii])
           {
            top_pos=iii-1;
            break;
           }
        }
      setup=NULL;
      for(int iii=top_pos; iii<=bar-1; iii++)
        {
         if(ExtSellStandbyBuffer[iii])
           {
            setup=iii;
            break;
           }
        }
      //----
      entry_point=NULL;
      range_lo=1000000.0;
      range_hi=-1000000.0;
      //----
      if(!setup || (bar-setup)<=int(InpStanbyBars))
        {
         //---
         for(int iii=top_pos; iii<=bar-1; iii++)
           {
            if(range_hi<high[iii]) range_hi=high[iii];
            if(range_lo>low[iii]) range_lo=low[iii];
           }
         entry_point=(range_hi+range_lo)/2;
         ExtSellLineBuffer[bar]=entry_point;
        }
      if(MathMax(high[bar-4],MathMax(high[bar-3],high[bar-2]))>high[bar-1])
        {
         if(!setup)
           {
            //---- копируем вновь появившиеся данные в массив
            if(CopyBuffer(ATR_Handle,0,time[top_pos],1,ATR)<=0) return(RESET);
            ExtTopBuffer[top_pos]=high[top_pos]+MathMax(ATR[0]*3/8,5*_Point);
            ExtSellStandbyBuffer[bar]=entry_point;
           }
         // else ExtTopBuffer[top_pos]=NULL;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
