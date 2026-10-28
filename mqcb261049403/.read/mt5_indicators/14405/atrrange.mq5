//+------------------------------------------------------------------+
//|                                                     AtrRange.mq5 | 
//|                                         Copyright © 2011, raxxla | 
//|                                         http://www.cmetrading.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, raxxla"
#property link "http://www.cmetrading.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета значка индикатора использован Blue цвет
#property indicator_color1 clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина значка индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "HiRange"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде значка
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета верхнего значка индикатора использован Red цвет
#property indicator_color2  clrRed
//---- толщина значка индикатора 2 равна 3
#property indicator_width2  3
//---- отображение метки индикатора
#property indicator_label2  "LoRange"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета нижнего значка индикатора использован Goldw цвет
#property indicator_color3  clrGold
//---- толщина значка индикатора 3 равна 2
#property indicator_width3 3 
//---- отображение метки индикатора
#property indicator_label3  "MultiRange"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint  MaxRange=25;
input int   Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double HiRangeBuffer[];
double LoRangeBuffer[];
double MRangeBuffer[];
//---- объявление переменной для хранения хендла индикатора
int ATR_Handle[5];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,Atr_Start,Atr_Step,MA,pt;
double ATR1[],ATR2[],ATR3[],ATR4[],ATR5[];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   Atr_Start=3;
   Atr_Step=2;
   MA=14;
   pt=1;
   if(_Digits==5 || _Digits==3) pt=10;
   min_rates_total=Atr_Start+Atr_Step*5+3+MA;
//---- получение хендла индикатора ATR1
   ATR_Handle[0]=iATR(NULL,PERIOD_CURRENT,Atr_Start+Atr_Step*1);
   if(ATR_Handle[0]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR1");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ATR2
   ATR_Handle[1]=iATR(NULL,PERIOD_CURRENT,Atr_Start+Atr_Step*2);
   if(ATR_Handle[1]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR2");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ATR3
   ATR_Handle[2]=iATR(NULL,PERIOD_CURRENT,Atr_Start+Atr_Step*3);
   if(ATR_Handle[2]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR3");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ATR4
   ATR_Handle[3]=iATR(NULL,PERIOD_CURRENT,Atr_Start+Atr_Step*4);
   if(ATR_Handle[3]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR4");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ATR5
   ATR_Handle[4]=iATR(NULL,PERIOD_CURRENT,Atr_Start+Atr_Step*5);
   if(ATR_Handle[4]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR5");
      return(INIT_FAILED);
     }

//----индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR1,true);
   ArraySetAsSeries(ATR2,true);
   ArraySetAsSeries(ATR3,true);
   ArraySetAsSeries(ATR4,true);
   ArraySetAsSeries(ATR5,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,HiRangeBuffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(HiRangeBuffer,true);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,159);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,LoRangeBuffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(LoRangeBuffer,true);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,MRangeBuffer,INDICATOR_DATA);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(MRangeBuffer,true);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,162);

//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"AtrRange(",MaxRange,", ",Shift,")");
//----создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//----завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle[0])<rates_total
      || BarsCalculated(ATR_Handle[1])<rates_total
      || BarsCalculated(ATR_Handle[2])<rates_total
      || BarsCalculated(ATR_Handle[3])<rates_total
      || BarsCalculated(ATR_Handle[4])<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- объявление локальных переменных 
   int to_copy,limit,bar;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//---
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle[0],0,0,to_copy+1,ATR1)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle[1],0,0,to_copy,ATR2)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle[2],0,0,to_copy+MA,ATR3)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle[3],0,0,to_copy,ATR4)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle[4],0,0,to_copy,ATR5)<=0) return(RESET);
//---- основной цикл индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(AtrRange(bar,MaxRange*pt,high,low))
        {
         HiRangeBuffer[bar]=high[bar]+_Point*3;
         LoRangeBuffer[bar]=low[bar]-_Point*3;
        }
      else
        {
         HiRangeBuffer[bar]=0.0;
         LoRangeBuffer[bar]=0.0;
        }
      //---
      if(AtrBreakIn(bar,high,low)) MRangeBuffer[bar]=(high[bar]+low[bar])/2;
      else MRangeBuffer[bar]=0.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  AtrBreakIn()                                                    |
//+------------------------------------------------------------------+
bool AtrBreakIn(int index,const double &High[],const double &Low[])
  {
   double vlt1 = (High[index]-Low[index])/_Point+_Point;
   double vlt2 = (High[index+1]-Low[index+1])/_Point+_Point;
//----
   if((vlt1/vlt2)>1.5) return false;
//----
   double max = MathMax(ATR2[index], MathMax(ATR3[index], MathMax(ATR4[index], ATR5[index])));
   double min = MathMin(ATR2[index], MathMin(ATR3[index], MathMin(ATR4[index], ATR5[index])));
   double summ=0.0;
   for(int iii=0; iii<MA; iii++) summ+=ATR3[index+iii];
   double atrMa3=summ/MA;
//----
   if(max>atrMa3) return false;
//----
   if((max-min)/_Point>25*pt) return false;
//----
   double atr1=ATR1[index];
//----
   if(atr1<min || atr1>atrMa3) return false;
//----
   if(atr1<ATR1[index+1]) return false;
//----
   if(atr1>=ATR5[index]) return false;
//----
   return true;
  }
//+------------------------------------------------------------------+
//| AtrRange()                                                       |
//+------------------------------------------------------------------+
bool AtrRange(int index,int maxRange,const double &High[],const double &Low[])
  {
//----
   double vlt1 = (High[index]-Low[index])/_Point+_Point;
   double vlt2 = (High[index+1]-Low[index+1])/_Point+_Point;
   double vlt3 = (High[index+2]-Low[index+2])/_Point+_Point;
//---
   if(vlt1>maxRange) return false;
//---
   if((vlt3/vlt2)>1.8) return false;
//---
   if(vlt1>vlt2 || vlt2>vlt3 || vlt1>vlt3) return false;
//---
   if(High[index]-High[index+1]>_Point) return false;
//---
   if(High[index+1]-High[index+2]>_Point) return false;
//---
   if(Low[index+1]-Low[index]>_Point) return false;
//---
   if(Low[index+2]-Low[index+1]>_Point) return false;
//----
   return true;
  }
//+------------------------------------------------------------------+
