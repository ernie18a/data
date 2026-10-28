//+------------------------------------------------------------------+
//|                                                   geTrendOsc.mq5 | 
//|                                       Copyright © 2007, Forte928 | 
//|                                                                  | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2007, Forte928"
//---- авторство индикатора
#property link      ""
//---- номер версии индикатора
#property version   "1.10"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора CG            |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован YellowGreen цвет
#property indicator_color1  clrYellowGreen
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "OscTrend"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Trigger       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован Tomato цвет
#property indicator_color2  clrTomato
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей метки индикатора
#property indicator_label2  "HPFilter"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 80
#property indicator_level2 60
#property indicator_level3 50
#property indicator_level4 40
#property indicator_level5 20
#property indicator_level6 0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Window=1;
input uint OscPeriod=14;
input uint HPPeriod=100;
input uint CBars=500;
input uint Shift=0; // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double TriggerBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double Series[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(Window+OscPeriod+HPPeriod);
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,OscPeriod);
   ArrayResize(Series,OscPeriod);
//---- инициализация памяти   
   ArrayInitialize(Count,0);
   ArrayInitialize(Series,0.0);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,TriggerBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(TriggerBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname="geTrendOsc";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//---- объявление локальных переменных 
   int limit,bar;
//---- расчет стартового номера limit для цикла пересчета баров
   limit=int(rates_total-Window-1);
   limit=int(MathMin(limit,CBars));
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-limit);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-limit);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double IxHigh,IxLow,IxOpen,IxClose;
      //----
      IxHigh=High[ArrayMaximum(High,bar,Window)];
      IxLow=Low[ArrayMinimum(Low,bar,Window)];
      //----
      if(IxHigh-IxLow>0)
        {
         IxOpen=Open[bar+Window];
         IxClose=Close[bar];
         Series[Count[0]]=(IxClose-IxOpen)/(IxHigh-IxLow);
        }
      else Series[Count[0]]=0;
      //----
      double Sumer=0;
      double AbsSumer=0;
      //----
      for(int Px=int(OscPeriod-1); Px>=0; Px--)
        {
         Sumer+=Series[Px];
         AbsSumer+=MathAbs(Series[Px]);
        }
      //----
      if(AbsSumer) IndBuffer[bar]=Sumer/AbsSumer*100/2+50;
      else IndBuffer[bar]=0.0;
      //----
      HPFilter(IndBuffer,TriggerBuffer,HPPeriod,limit+1);
      //----
      if(bar>0) Recount_ArrayZeroPos(Count,OscPeriod);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Пересчет позиции самого нового элемента в массиве                |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;
//----
   Max2=Size;
   Max1=Max2-1;
//----
   count--;
   if(count<0) count=Max1;
//----
   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| HPFilter - Фильтр Ходрика-Прескотта                              |
//+------------------------------------------------------------------+
void HPFilter(double &aySource[],double &ayResult[],int Lambda,int iCount)
  {
//----
   double Ak[],Bk[],Ck[],H1=0.0,H2=0.0,H3=0.0,H4=0.0,H5=0.0,HH1=0.0,HH2=0.0,HH3=0.0,HH5=0.0,HB,HC,Z;
   ArrayResize(Ak,iCount);
   ArrayResize(Bk,iCount);
   ArrayResize(Ck,iCount);
//----
   Ak[0]=1.0+Lambda;
   Bk[0]=-2.0*Lambda;
   Ck[0]=Lambda;
//----
   for(int Hx=1; Hx<iCount-2; Hx++)
     {
      Ak[Hx]=6.0*Lambda+1.0;
      Bk[Hx]=-4.0*Lambda;
      Ck[Hx]=Lambda;
     }
//----
   Ak[1]=5.0*Lambda+1;
   Ak[iCount-1]=1.0+Lambda;
   Ak[iCount-2]=5.0*Lambda+1.0;
   Bk[iCount-2]=-2.0*Lambda;
   Bk[iCount-1]=0.0;
   Ck[iCount-2]=0.0;
   Ck[iCount-1]=0.0;
//---- Forward
   for(int Hx=0; Hx<iCount; Hx++)
     {
      Z=Ak[Hx]-H4*H1-HH5*HH2;
      HB=Bk[Hx];
      HH1=H1;
      H1=(HB-H4*H2)/Z;
      Bk[Hx]=H1;
      HC=Ck[Hx];
      HH2=H2;
      H2=HC/Z;
      Ck[Hx]=H2;
      Ak[Hx]=(aySource[Hx]-HH3*HH5-H3*H4)/Z;
      HH3=H3;
      H3=Ak[Hx];
      H4=HB-H5*HH1;
      HH5=H5;
      H5=HC;
     }
//---- Backward 
   H2=0;
   H1=Ak[iCount-1];
   ayResult[iCount-1]=H1;
//----
   for(int Hx=iCount-2; Hx>=0; Hx--)
     {
      ayResult[Hx]=Ak[Hx]-Bk[Hx]*H1-Ck[Hx]*H2;
      H2=H1;
      H1=ayResult[Hx];
     }
//----
  }
//+------------------------------------------------------------------+
