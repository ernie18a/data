//+------------------------------------------------------------------+
//|                            AbsolutelyNoLagLwma_Range_Channel.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, ellizii"
#property link ""
#property description "AbsolutelyNoLagLwma Range Channel"
//---- номер версии индикатора
#property version   "1.03"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 9
#property indicator_buffers 9 
//---- использовано 4 графических построения
#property indicator_plots   4
//+--------------------------------------------+
//| Параметры отрисовки облака                 |
//+--------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет Lavender
#property indicator_color1 clrLavender
//---- отображение метки индикатора
#property indicator_label1  "AbsolutelyNoLagLwma Range Channel"
//+--------------------------------------------+
//| Параметры отрисовки уровней                |
//+--------------------------------------------+
//---- отрисовка уровней в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- ввыбор цветов уровней
#property indicator_color2  clrBlue
#property indicator_color3  clrRed
//---- уровни - штрихпунктирные кривые
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- толщина уровней равна 1
#property indicator_width2  1
#property indicator_width3  1
//---- отображение меток уровней
#property indicator_label2  "Up Line"
#property indicator_label3  "Down Line"
//+--------------------------------------------+
//| Параметры отрисовки свечей                 |
//+--------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type4   DRAW_COLOR_CANDLES
#property indicator_color4   clrYellow,clrDarkOrange,clrGreen,clrLime
//---- отображение метки индикатора
#property indicator_label4  "Open;High;Low;Close"
//+--------------------------------------------+
//| Входные параметры индикатора               |
//+--------------------------------------------+ 
input uint Length=7;    // глубина сглаживания                   
input int Shift=0;      // сдвиг по горизонтали в барах
input int PriceShift=0; // cдвиг по вертикали в пунктах
//+--------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
double UpIndBuffer[],DnIndBuffer[],UpLineBuffer[],DnLineBuffer[];
//---- объявление переменной значения вертикального сдвига средней
double dPriceShift;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double UpPrice[],DnPrice[],UpLwma[],DnLwma[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+---------------------------------------------------------------------+   
//| AbsolutelyNoLagLwma_Range_Channel indicator initialization function | 
//+---------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(Length*2.0);
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,Length);
   ArrayResize(UpPrice,Length);
   ArrayResize(DnPrice,Length);
   ArrayResize(UpLwma,Length);
   ArrayResize(DnLwma,Length);
//---- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,UpIndBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnIndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(2,UpLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,DnLineBuffer,INDICATOR_DATA);
//---- установка позиции, с которой начинается линий канала
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(4,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(8,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- установка позиции, с которой начинается линий канала
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"AbsolutelyNoLagLwma_Range_Channel",Length,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| AbsolutelyNoLagLwma_Range_Channel iteration function             | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- объявления локальных переменных 
   int first,bar,weight;
   double sum,sumw,lwma2;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      ArrayInitialize(Count,0);
      ArrayInitialize(UpPrice,0.0);
      ArrayInitialize(DnPrice,0.0);
      ArrayInitialize(UpLwma,0.0);
      ArrayInitialize(DnLwma,0.0);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//---- основной цикл расчета индикатора
   //---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      UpPrice[Count[0]]=high[bar];
      //----
      sum=0;
      sumw=0;
      for(int kkk=0; kkk<int(Length); kkk++) { weight=int(Length)-kkk; sumw+=weight; sum+=weight*UpPrice[Count[kkk]]; }
      if(sumw) UpLwma[Count[0]]=sum/sumw;
      else  UpLwma[Count[0]]=NULL;
      //----
      sum=0;
      sumw=0;
      for(int kkk=0; kkk<int(Length); kkk++) { weight=int(Length)-kkk; sumw+=weight; sum+=weight*UpLwma[Count[kkk]]; }
      if(sumw) lwma2=sum/sumw;
      else  lwma2=NULL;
      //---- Инициализация ячейки индикаторного буфера полученным значением 
      UpLineBuffer[bar]=UpIndBuffer[bar]=lwma2+dPriceShift;
      
      DnPrice[Count[0]]=low[bar];
      //----
      sum=0;
      sumw=0;
      for(int kkk=0; kkk<int(Length); kkk++) { weight=int(Length)-kkk; sumw+=weight; sum+=weight*DnPrice[Count[kkk]]; }
      if(sumw) DnLwma[Count[0]]=sum/sumw;
      else  DnLwma[Count[0]]=NULL;
      //----
      sum=0;
      sumw=0;
      for(int kkk=0; kkk<int(Length); kkk++) { weight=int(Length)-kkk; sumw+=weight; sum+=weight*DnLwma[Count[kkk]]; }
      if(sumw) lwma2=sum/sumw;
      else  lwma2=NULL;
      //---- Инициализация ячейки индикаторного буфера полученным значением 
      DnLineBuffer[bar]=DnIndBuffer[bar]=lwma2+dPriceShift;
      
      if(bar<rates_total-1) Recount_ArrayZeroPos(Count,Length);
     }
//---- основной цикл исправления и окрашивания свечей
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ExtOpenBuffer[bar]=ExtCloseBuffer[bar]=ExtHighBuffer[bar]=ExtLowBuffer[bar]=EMPTY_VALUE;
      ExtColorBuffer[bar]=4;
      //----
      if(close[bar]>UpLineBuffer[bar])
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         if(close[bar]>=open[bar]) ExtColorBuffer[bar]=3;
         else ExtColorBuffer[bar]=2;
        }
      //----
      if(close[bar]<DnLineBuffer[bar])
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         if(close[bar]<=open[bar]) ExtColorBuffer[bar]=0;
         else ExtColorBuffer[bar]=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

   