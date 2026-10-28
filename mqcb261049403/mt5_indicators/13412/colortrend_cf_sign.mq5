//+------------------------------------------------------------------+
//|                                           ColorTrend_CF_Sign.mq5 |
//|                                         CF = Continuation Factor |
//|               Converted by and Copyright: Ronald Verwer/ROVERCOM |
//|                                                         27/04/06 |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Converted by and Copyright: Ronald Verwer/ROVERCOM"
#property link ""
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован DarkOrange цвет
#property indicator_color1  clrDarkOrange
//--- толщина линии индикатора 1 равна 1 
#property indicator_width1  1
//--- отображение медвежьей метки индикатора
#property indicator_label1  "Trend_CF Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован Aqua цвет
#property indicator_color2  clrAqua
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение бычьей метки индикатора
#property indicator_label2 "Trend_CF Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Period_=30;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//----
int ATR_Handle;
int Count[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление массивов переменных для кольцевых буферов
double x_p[],x_n[],y_p[],y_n[];
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в кольцевом буфере       |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[]// возврат по ссылке номера текущего значения ценового ряда
                          )
  {
//----
   int numb;
   static int count=1;
   count--;
   if(count<0) count=int(Period_)-1;
//----
   for(int iii=0; iii<int(Period_); iii++)
     {
      numb=iii+count;
      if(numb>int(Period_)-1) numb-=int(Period_);
      CoArr[iii]=numb;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация глобальных переменных 
   int ATR_Period=15;
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- инициализация констант
   min_rates_total=int(MathMax(Period_,ATR_Period));
//---- распределение памяти под массивы переменных   
   ArrayResize(x_p,Period_);
   ArrayResize(x_n,Period_);
   ArrayResize(y_p,Period_);
   ArrayResize(y_n,Period_);
   ArrayResize(Count,Period_);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,124);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,124);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"ColorTrend_CF_Sign(",Period_,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
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
//---- объявления локальных переменных 
   int first,bar,bar0,bar1,barq;
   double chp,chn,cffp,cffn,dprice,Upper,Lower,ATR[1];
   static double Upper1,Lower1;
//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=1; // стартовый номер для расчета всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      dprice=close[bar]-close[bar-1];
      //----
      bar0=Count[0];
      bar1=Count[1];
      //----
      if(dprice>0)
        {
         x_p[bar0]=dprice;
         y_p[bar0]=x_p[bar0]+y_p[bar1];
         x_n[bar0]=0;
         y_n[bar0]=0;
        }
      else
        {
         x_n[bar0]=-dprice;
         y_n[bar0]=x_n[bar0]+y_n[bar1];
         x_p[bar0]=0;
         y_p[bar0]=0;
        }
      //----
      if(bar<min_rates_total)
        {
         if(bar<rates_total-1) Recount_ArrayZeroPos(Count);
         continue;
        }
      //----
      chp=0;
      chn=0;
      cffp=0;
      cffn=0;
      //----
      for(int q=int(Period_)-1; q>=0; q--)
        {
         barq=Count[q];
         //----
         chp+=x_p[barq];
         chn+=x_n[barq];
         cffp+=y_p[barq];
         cffn+=y_n[barq];
        }
      //----
      Upper=(chp-cffn)/_Point;
      Lower=(chn-cffp)/_Point;
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(Upper1<=Lower1 && Upper>Lower)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(Upper1>=Lower1 && Upper<Lower)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //----
      if(bar<rates_total-1)
        {
         Recount_ArrayZeroPos(Count);
         Upper1=Upper;
         Lower1=Lower;
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
