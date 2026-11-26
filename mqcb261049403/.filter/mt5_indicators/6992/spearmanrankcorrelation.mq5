//+------------------------------------------------------------------+
//|                                      SpearmanRankCorrelation.mq5 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
// http://www.infamed.com/stat/s05.html
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//--- использовано всего одно графическое построение
#property indicator_plots   1
//--- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован цвет Magenta
#property indicator_color1  Magenta
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- параметры минимального и максимального значений индикатора
#property indicator_minimum -1
#property indicator_maximum +1
//--- параметры горизонтальных уровней индикатора
#property indicator_level1  +0.50
#property indicator_level2   0
#property indicator_level3  -0.50
#property indicator_levelcolor Blue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int  rangeN=14;
input int  CalculatedBars=0;
input int  Maxrange=30;
input bool direction=true;
//+----------------------------------------------+
//--- объявление динамического массива, который в дальнейшем
//--- будет использован в качестве индикаторного буфера
double ExtLineBuffer[];
//---
double multiply;
double R2[],TrueRanks[];
int    PriceInt[],SortInt[],Maxrange_;
//+------------------------------------------------------------------+
//| Сalculate RSP function                                           |
//+------------------------------------------------------------------+
double SpearmanRankCorrelation(double &Ranks[],int N)
  {
//---
   double res,z2=0.0;
   for(int iii=0; iii<N; iii++) z2+=MathPow(Ranks[iii]-iii-1,2);
   res=1-6*z2/(MathPow(N,3)-N);
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Ranking array of prices function                                 |
//+------------------------------------------------------------------+
void RankPrices(double &TrueRanks_[],int &InitialArray[])
  {
//---
   int i,k,m,dublicat,counter,etalon;
   double dcounter,averageRank;
//---
   ArrayCopy(SortInt,InitialArray,0,0,WHOLE_ARRAY);
//---
   for(i=0; i<rangeN; i++) TrueRanks_[i]=i+1;
//---
   ArraySort(SortInt);
//---   
   for(i=0; i<rangeN-1; i++)
     {
      if(SortInt[i]!=SortInt[i+1]) continue;

      dublicat=SortInt[i];
      k=i+1;
      counter=1;
      averageRank=i+1;

      while(k<rangeN)
        {
         if(SortInt[k]==dublicat)
           {
            counter++;
            averageRank+=k+1;
            k++;
           }
         else
            break;
        }
      dcounter=counter;
      averageRank=averageRank/dcounter;

      for(m=i; m<k; m++)
         TrueRanks_[m]=averageRank;
      i=k;
     }
   for(i=0; i<rangeN; i++)
     {
      etalon=InitialArray[i];
      k=0;
      while(k<rangeN)
        {
         if(etalon==SortInt[k])
           {
            R2[i]=TrueRanks_[k];
            break;
           }
         k++;
        }
     }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- распределение памяти под массивы переменных   
   ArrayResize(R2,rangeN);
   ArrayResize(PriceInt,rangeN);
   ArrayResize(SortInt,rangeN);
//--- изменение индексации элементов в массиве переменных
   if(direction) ArraySetAsSeries(SortInt,true);
   ArrayResize(TrueRanks,rangeN);
//--- инициализация переменных
   if(Maxrange<=0)
      Maxrange_=10;
   else Maxrange_=Maxrange;
   multiply=MathPow(10,_Digits);
//--- превращение динамического массива ExtLineBuffer[] в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rangeN);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   if(rangeN>Maxrange_)
      shortname="Decrease rangeN input!";
   else StringConcatenate(shortname,"Spearman(",rangeN,")");
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчета баров
                const double &price[])    // ценовой массив для расчета индикатора
  {
//--- проверка количества баров на достаточность для расчета
   if(rates_total<rangeN+begin) return(0);
//---
   if(rangeN>Maxrange_) return(0);
//--- объявления локальных переменных 
   int limit;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-2-rangeN-begin; // стартовый номер для расчета всех баров
      //--- увеличим позицию начала данных на begin баров, вследствие расчетов на данных другого индикатора
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rangeN+begin);
     }
   else
     {
      if(CalculatedBars==0)
         limit=rates_total-prev_calculated;
      else limit=CalculatedBars;
     }
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(price,true);
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0; bar--)
     {
      for(int k=0; k<rangeN; k++) PriceInt[k]=int(price[bar+k]*multiply);
      //---
      RankPrices(TrueRanks,PriceInt);
      ExtLineBuffer[bar]=SpearmanRankCorrelation(R2,rangeN);
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
