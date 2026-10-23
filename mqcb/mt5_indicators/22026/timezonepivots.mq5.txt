//+----------------------------------------------------------------------------+
//|                                                        TimeZonePivots.mq5  |
//|                                                        Copyright © 2005,   |
//|                                                                            |
//+----------------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, "
#property link      ""
//---- номер версии индикатора
#property version   "1.00"
//---- описание индикатора
#property description ""
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки облака                   |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета линии индикатора использован цвет Lavender
#property indicator_color1 clrLavender
//---- отображение метки индикатора
#property indicator_label1  "TimeZonePivots"
//+----------------------------------------------+
//| Параметры отрисовки верхней линии            |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован Lime цвет
#property indicator_color2  clrLime
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//---- отображение бычей метки индикатора
#property indicator_label2  "Upper Zone"
//+----------------------------------------------+
//| Параметры отрисовки нижней линии             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован Orange цвет
#property indicator_color3  clrOrange
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Lower Zone"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Объявление перечисления часов суток         |
//+----------------------------------------------+
enum HOURS
  {
   ENUM_HOUR_0=0,   //0
   ENUM_HOUR_1,     //1
   ENUM_HOUR_2,     //2
   ENUM_HOUR_3,     //3
   ENUM_HOUR_4,     //4
   ENUM_HOUR_5,     //5
   ENUM_HOUR_6,     //6
   ENUM_HOUR_7,     //7
   ENUM_HOUR_8,     //8
   ENUM_HOUR_9,     //9
   ENUM_HOUR_10,     //10
   ENUM_HOUR_11,     //11   
   ENUM_HOUR_12,     //12
   ENUM_HOUR_13,     //13
   ENUM_HOUR_14,     //14
   ENUM_HOUR_15,     //15
   ENUM_HOUR_16,     //16
   ENUM_HOUR_17,     //17
   ENUM_HOUR_18,     //18
   ENUM_HOUR_19,     //19
   ENUM_HOUR_20,     //20
   ENUM_HOUR_21,     //21  
   ENUM_HOUR_22,     //22
   ENUM_HOUR_23      //23    
  };
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum ENUM_MIDDLE_TYPE
  {
   MODE_PRICE_OPEN,  // по цене открытия стартового часа
   MODE_PRICE_CLOSE  // по цене закрытия текущей свечи
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input HOURS  StartH=ENUM_HOUR_0;                    // Старт расчёта канала (Часы)
input ENUM_MIDDLE_TYPE MiddleLine=MODE_PRICE_OPEN;  // линия канала 
input uint Offset=100;                              // ширина канала в пунктах
input int    Shift=0;                               // сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
double Up0Buffer[];
double Dn0Buffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=4;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Up0Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
//PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Up0Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Dn0Buffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Dn0Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"TimeZonePivots(",EnumToString(StartH),", ",EnumToString(MiddleLine),", ",Offset,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка периода графика
   if(Period()>PERIOD_H1)
     {
      Comment("Индикатору TimeZonePivots нужен ТФ младше H2!");
      return(RESET);
     }
   else Comment("");
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   static double Last_open;
   static int Last_day,Last_hour,Last_bar;
   int bar,limit;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      Last_open=NULL;
      Last_day=-1;
      Last_hour=-1;
      Last_bar=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- основной цикл расчёта индикатора по ценам открытия
   if(MiddleLine==MODE_PRICE_OPEN)
      for(bar=limit; bar>=0 && !IsStopped(); bar--)
        {
         MqlDateTime tm;
         TimeToStruct(time[bar],tm);

         if(Last_day!=tm.day && tm.hour==StartH)
           {
            Last_day=tm.day;
            Last_hour=tm.hour;
            Last_open=open[bar];
            UpBuffer[bar+1]=DnBuffer[bar+1]=UpBuffer[bar+2]=DnBuffer[bar+2]=NULL;
            Up0Buffer[bar+1]=Dn0Buffer[bar+1]=Up0Buffer[bar+2]=Dn0Buffer[bar+2]=NULL;
           }

         if(Last_day>0)
           {
            UpBuffer[bar]=Up0Buffer[bar]=Last_open+Offset*_Point;
            DnBuffer[bar]=Dn0Buffer[bar]=Last_open-Offset*_Point;
           }
         else
           {
            UpBuffer[bar]=Up0Buffer[bar]=NULL;
            DnBuffer[bar]=Dn0Buffer[bar]=NULL;
           }
        }

//---- основной цикл расчёта индикатора по ценам закрытия
   if(MiddleLine==MODE_PRICE_CLOSE)
     {
      int limit_=limit+Last_bar;
      Last_bar+=limit;      
      for(bar=limit_; bar>=0 && !IsStopped(); bar--)
        {
         MqlDateTime tm;
         TimeToStruct(time[bar],tm);

         if(Last_day!=tm.day && tm.hour==StartH)
           {
            Last_bar=bar;
            Last_day=tm.day;
            Last_hour=tm.hour;
            UpBuffer[bar+1]=DnBuffer[bar+1]=UpBuffer[bar+2]=DnBuffer[bar+2]=NULL;
            Up0Buffer[bar+1]=Dn0Buffer[bar+1]=Up0Buffer[bar+2]=Dn0Buffer[bar+2]=NULL;
           }

         for(int index=Last_bar; index>=bar && !IsStopped(); index--)
           {
            if(Last_day>0)
              {
               UpBuffer[index]=Up0Buffer[index]=close[bar]+Offset*_Point;
               DnBuffer[index]=Dn0Buffer[index]=close[bar]-Offset*_Point;
              }
            else
              {
               UpBuffer[index]=Up0Buffer[index]=NULL;
               DnBuffer[index]=Dn0Buffer[index]=NULL;
              }
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
