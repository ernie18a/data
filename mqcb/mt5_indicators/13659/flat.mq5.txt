//+------------------------------------------------------------------+
//|                                                         Flat.mq5 |
//|                                                      Pedro Puado |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Pedro Puado"
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета  линии индикатора использован серый цвет
#property indicator_color1  clrGray
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки индикатора
#property indicator_label1  "Line"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_COLOR_ARROW
//---- в качестве цветов индикатора использованы
#property indicator_color2  clrGray,clrBlue,clrMagenta,clrRed
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "Arrows"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum ENUM_WIDTH //тип константы
  {
   w_1=0,  //1
   w_2,    //2
   w_3,    //3
   w_4,    //4
   w_5     //5
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Smooth=10; // Период сглаживания
input ENUM_MA_METHOD      ma_method=MODE_SMA; // Тип сглаживания
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE; // Тип цены
input uint HLRef=100;
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input uint ExtraHighLevel=60; // Уровень максимального тренда
input uint HighLevel=40; // Уровень сильного тренда
input uint LowLevel=20; // Уровень слабого тренда
input ENUM_LINE_STYLE LevelStyle=STYLE_DASHDOTDOT; // Стиль линий уровней
input color LevelColor=clrBlue; // Цвет уровней
input ENUM_WIDTH LevelWidth=w_1; // Толщина уровней
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
double ColorInd2Buffer[];
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double Value[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
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
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(2*Smooth);
//---- получение хендла индикатора iStdDev
   Ind_Handle=iStdDev(NULL,0,Smooth,0,ma_method,applied_price);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iStdDev");
      return(INIT_FAILED);
     }
//---- распределение памяти под массивы переменных  
   ArrayResize(Count,HLRef);
   ArrayResize(Value,HLRef);
//----
   ArrayInitialize(Count,0);
   ArrayInitialize(Value,0.0);
//---- индексация элементов в массиве как в таймсерии
   ArraySetAsSeries(Value,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Ind1Buffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ind1Buffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Ind2Buffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ind2Buffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorInd2Buffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorInd2Buffer,true);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Flat( ",Smooth,", ",HLRef,", ",Shift," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- параметры отрисовки уровней индикатора
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtraHighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelWidth);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelWidth);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2,LevelWidth);
//---- завершение инициализации
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double Std[],Sum,sStd,HH,LL,Range;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Std,true);
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=int(rates_total-1-Smooth);   // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=int(limit+1+Smooth);
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,0,0,to_copy,Std)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Sum=0;
      for(int iii=0; iii<int(Smooth); iii++) Sum+=Std[bar+iii];
      sStd=Sum/Smooth;
      //----
      Sum=0;
      for(int iii=0; iii<int(Smooth); iii++) Sum+=MathAbs((Std[bar+iii]-sStd)*2);
      Value[Count[0]]=MathSqrt(Sum/Smooth);
      //----
      HH=Value[ArrayMaximum(Value,0,HLRef)];
      LL=Value[ArrayMinimum(Value,0,HLRef)];
      //----
      Range=HH-LL;
      if(Range) Ind1Buffer[bar]=100*(Value[Count[0]]-LL)/Range;
      else Ind1Buffer[bar]=100.0;
      Ind2Buffer[bar]=Ind1Buffer[bar];
      if(bar) Recount_ArrayZeroPos(Count,HLRef);
     }
//---- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorInd2Buffer[bar]=1;
      if(Ind1Buffer[bar]>ExtraHighLevel) ColorInd2Buffer[bar]=3;
      else if(Ind1Buffer[bar]>HighLevel) ColorInd2Buffer[bar]=2;
      else if(Ind1Buffer[bar]<LowLevel)  ColorInd2Buffer[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
