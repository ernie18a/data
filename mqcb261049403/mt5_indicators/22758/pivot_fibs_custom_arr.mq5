//+------------------------------------------------------------------+ 
//|                                        Pivot_Fibs_Custom_Arr.mq5 | 
//|                            Copyright © 2006, Archer Trading, LLC |
//|                                    http://www.archertrading.net/ |
//+------------------------------------------------------------------+
#property copyright "Archer Trading, LLC"
#property link      "http://www.archertrading.net/"
//---- номер версии индикатора
#property version   "1.00"
#property description "Линии сопротивлений и поддержки по Фибо уровням с выбором таймфрейма для пивота"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 7
#property indicator_buffers 7 
//---- использовано всего семь графических построений
#property indicator_plots   7
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                // Константа для возврата терминалу команды на пересчёт индикатора
#define INDICATOR_NAME "Pivot_Fibs_Custom"     // Константа для имени индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде значка
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета индикатора использован
#property indicator_color1  clrDeepSkyBlue
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Res 3"

//+----------------------------------------------+
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде значка
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета индикатора использован
#property indicator_color2  clrDodgerBlue
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "Res 2"

//+----------------------------------------------+
//|  Параметры отрисовки индикатора 3            |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета индикатора использован
#property indicator_color3  clrBlue
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "Res 1"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 4            |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован
#property indicator_color4  clrPurple
//---- толщина линии индикатора 4 равна 3
#property indicator_width4  3
//---- отображение метки индикатора
#property indicator_label4  "Pivot"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 5            |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован
#property indicator_color5  clrRed
//---- толщина линии индикатора 5 равна 2
#property indicator_width5  2
//---- отображение метки индикатора
#property indicator_label5  "Sup 1"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 6            |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета индикатора использован
#property indicator_color6  clrHotPink
//---- толщина линии индикатора 6 равна 1
#property indicator_width6  1
//---- отображение метки индикатора
#property indicator_label6  "Sup 2"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 7            |
//+----------------------------------------------+
//---- отрисовка индикатора 7 в виде значка
#property indicator_type7   DRAW_ARROW
//---- в качестве цвета индикатора использован
#property indicator_color7  clrViolet
//---- толщина линии индикатора 7 равна 2
#property indicator_width7  2
//---- отображение метки индикатора
#property indicator_label7  "Sup 3"
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H12;           // Период графика
input double FiboRatio1=0.99;
input double FiboRatio2=0.382;
input double FiboRatio3=0.618;
input int Shift=0;                                    // сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
double Ind4Buffer[];
double Ind5Buffer[];
double Ind6Buffer[];
double Ind7Buffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных 
   min_rates_total=2*PeriodSeconds(TimeFrame)/PeriodSeconds(Period());

//---- Инициализация индикаторных буферов
   IndInit(0,Ind1Buffer,0.0,min_rates_total,Shift);
   IndInit(1,Ind2Buffer,0.0,min_rates_total,Shift);
   IndInit(2,Ind3Buffer,0.0,min_rates_total,Shift);
   IndInit(3,Ind4Buffer,0.0,min_rates_total,Shift);
   IndInit(4,Ind5Buffer,0.0,min_rates_total,Shift);
   IndInit(5,Ind6Buffer,0.0,min_rates_total,Shift);
   IndInit(6,Ind7Buffer,0.0,min_rates_total,Shift);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,167);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",Shift,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(RESET);
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- Объявление целых переменных
   int limit,bar;

//---- Объявление переменных с плавающей точкой  
   double P,R,S1,R1,S2,R2,S3,R3;
   static double LastHigh,LastLow;
//----    
   datetime Time[1];
   static uint LastCountBar;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
      LastHigh=0;
      LastLow=999999999;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Ind1Buffer[bar]=Ind2Buffer[bar]=Ind3Buffer[bar]=Ind4Buffer[bar]=Ind5Buffer[bar]=Ind6Buffer[bar]=Ind7Buffer[bar]=NULL;

      if(high[bar+1]>LastHigh) LastHigh=high[bar+1];
      if(low[bar+1]<LastLow) LastLow=low[bar+1];

      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,Time)<=0) return(RESET);

      if(time[bar]>=Time[0] && time[bar+1]<Time[0])
        {
         LastCountBar=bar;
         Ind1Buffer[bar+1]=Ind2Buffer[bar+1]=Ind3Buffer[bar+1]=Ind4Buffer[bar+1]=Ind5Buffer[bar+1]=Ind6Buffer[bar+1]=Ind7Buffer[bar+1]=NULL;
         
         P=(LastHigh+LastLow+close[bar+1])/3;
         R=LastHigh-LastLow;
         R1=P+(R*FiboRatio2);
         S1=P-(R*FiboRatio2);
         R2=P+(R*FiboRatio3);
         S2=P-(R*FiboRatio3);
         R3=P+(R*FiboRatio1);
         S3=P-(R*FiboRatio1);
         LastLow=open[bar];
         LastHigh=open[bar];

         //---- Загрузка полученных значений в индикаторные буферы
         Ind1Buffer[bar]=R3;
         Ind2Buffer[bar]=R2;
         Ind3Buffer[bar]=R1;
         Ind4Buffer[bar]=P;
         Ind5Buffer[bar]=S1;
         Ind6Buffer[bar]=S2;
         Ind7Buffer[bar]=S3;
        }

      if(Ind1Buffer[bar+1] && !Ind1Buffer[bar])
        {
         Ind1Buffer[bar]=Ind1Buffer[bar+1];
         Ind2Buffer[bar]=Ind2Buffer[bar+1];
         Ind3Buffer[bar]=Ind3Buffer[bar+1];
         Ind4Buffer[bar]=Ind4Buffer[bar+1];
         Ind5Buffer[bar]=Ind5Buffer[bar+1];
         Ind6Buffer[bar]=Ind6Buffer[bar+1];
         Ind7Buffer[bar]=Ind7Buffer[bar+1];
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
//----
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) // Период графика индикатора
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Comment("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика! \n Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
