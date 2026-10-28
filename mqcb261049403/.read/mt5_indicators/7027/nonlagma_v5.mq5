//+------------------------------------------------------------------+
//|                                                  NonLagMA_v5.mq5 |
//|                                Copyright © 2006, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrGray,clrGreen,clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "NonLagMA_v5"
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int                 MAPeriod       = 13;            // Период
input  ENUM_MA_METHOD     MAType         = MODE_EMA;      // Тип усреднения
input ENUM_APPLIED_PRICE  MAPrice        = PRICE_CLOSE;   // Цена
input uint                Filter         = 0;             // Static filter in points  
input uint                ColorBarBack   = 1;             // Bar back for color mode
input double              Deviation      = 0;             // Up/down deviation  
input int                 Shift          = 0;             // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
//----
double alfa[];
int Phase,Len,Cycle,size;
double Coeff,beta,t,Sum,Weight,g,pi,dFilter;
//---- Объявление целых переменных для хендлов индикаторов
int MA_Handle;
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//---- Объявление целых переменных начала отсчета данных
int min_rates_total;
//---- объявление глобальных переменных
int Count[];
double Trend[];
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
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- получение хендла индикатора iMA
   MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }

//---- Инициализация сдвига по вертикали
   dFilter=Filter*_Point;
//----  
   Cycle=4;
   pi=3.1415926535;
   Coeff=3*pi;
   Phase=MAPeriod-1;
   Len=MAPeriod*Cycle+Phase;
   if(ArrayResize(alfa,Len)<Len)
     {
      Print("Не удалось распределить память под массив alfa[]");
      return(INIT_FAILED);
     }
   Weight=0;
   for(int iii=0; iii<Len; iii++)
     {
      if(iii<=Phase-1) t=1.0*iii/(Phase-1);
      else t=1.0+(iii-Phase+1)*(2.0*Cycle-1.0)/(Cycle*MAPeriod-1.0);
      beta=MathCos(pi*t);
      g=1.0/(Coeff*t+1);
      if(t<=0.5) g=1;
      alfa[iii]=g*beta;
      Weight+=alfa[iii];
     }
     
//---- Инициализация переменных начала отсчета данных
   min_rates_total=int(MAPeriod+ColorBarBack+Len);

//---- распределение памяти под массивы переменных
   size=int(ColorBarBack+1);
   if(ArrayResize(Count,size)<size)
     {
      Print("Не удалось распределить память под массив Count[]");
      return(INIT_FAILED);
     }
   if(ArrayResize(Trend,size)<size)
     {
      Print("Не удалось распределить память под массив Trend[]");
      return(INIT_FAILED);
     }
   ArrayInitialize(Count,0);
   ArrayInitialize(Trend,0.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);

//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"NonLagMA_v5(",MAPeriod,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double MA[];

//---- расчёты необходимого количества копируемых данных и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
   to_copy=limit+Len+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(MA,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Sum=0;
      for(int kkk=0; kkk<Len; kkk++) Sum+=alfa[kkk]*MA[bar+kkk];
      if(Weight) IndBuffer[bar]=(1.0+Deviation/100)*Sum/Weight;
      if(Filter>0) if(MathAbs(IndBuffer[bar]-IndBuffer[bar+1])<dFilter) IndBuffer[bar]=IndBuffer[bar+1];
     }

//---- корректировка значения переменной limit
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;

//---- Основной цикл раскраски линии
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorIndBuffer[bar]=0;
      Trend[Count[0]]=Trend[Count[1]];
      if(IndBuffer[bar]-IndBuffer[bar+1]>dFilter) Trend[Count[0]]=+1;
      if(IndBuffer[bar+1]-IndBuffer[bar]>dFilter) Trend[Count[0]]=-1;
      if(Trend[Count[0]]>0)
        {
         ColorIndBuffer[bar]=1;
         if(Trend[Count[ColorBarBack]]<0) ColorIndBuffer[bar+ColorBarBack]=1;
        }
      if(Trend[Count[0]]<0)
        {
         ColorIndBuffer[bar]=2;
         if(Trend[Count[ColorBarBack]]>0) ColorIndBuffer[bar+ColorBarBack]=2;
        }
      if(bar) Recount_ArrayZeroPos(Count,size);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
