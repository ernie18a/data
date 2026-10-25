//+------------------------------------------------------------------+
//|                                                      r_Gator.mq5 |
//|                                         Copyright © 2006, Rosych | 
//|                                                   rosych@mail.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Rosych"
#property link "rosych@mail.ru"
#property description "Аналог  Аллигатора с меньшей задержкой сигналов"
//--- номер версии индикатора
#property version   "1.03"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//--- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета линии индикатора использован красный цвет
#property indicator_color1  clrRed
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение метки индикатора
#property indicator_label1  "r_Gator Fast"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета линии индикатора использован зеленый цвет
#property indicator_color2  clrGreen
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение метки индикатора
#property indicator_label2 "r_Gator"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//--- в качестве цвета линии индикатора использован синий цвет
#property indicator_color3  clrBlue
//--- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//--- отображение метки индикатора
#property indicator_label3 "r_Gator Slow"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint period1=5;    // Период быстрой MA 
input uint period2=8;    // Период средней MA
input uint period3=13;   // Период медленной MA
input int  Shift1=0;     // Сдвиг быстрой MA по горизонтали в барах
input int  Shift2=0;     // Сдвиг средней MA по горизонтали в барах
input int  Shift3=0;     // Сдвиг медленной MA по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double Buffer1[],Buffer2[],Buffer3[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int MA_Handle[3][4][7]; //[номер мувинга][метод усреднения][цена-1]
//+------------------------------------------------------------------+
//| Массивы объектов для создания многомерных массивов объектов      |
//+------------------------------------------------------------------+  
class CArray
  {
public: double    Array[];
  };
//+------------------------------------------------------------------+
//| Создание массива объектов                                        |
//+------------------------------------------------------------------+
CArray Arr[3][4][7];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных   
   min_rates_total=int(MathMax(period1,MathMax(period2,period3)));
//---
   uint MAPeriod[3];
   MAPeriod[0]=period1;
   MAPeriod[1]=period2;
   MAPeriod[2]=period3;
//--- получение хендлов индикаторов
   for(int i=0; i<3; i++)
      for(int k=0; k<4; k++)
         for(int r=0; r<7; r++)
           {
            MA_Handle[i][k][r]=iMA(NULL,0,MAPeriod[i],0,ENUM_MA_METHOD(k),ENUM_APPLIED_PRICE(r+1));
            if(MA_Handle[i][k][r]==INVALID_HANDLE)
              {
               Print(" Не удалось получить хендл индикатора iMA");
               return(INIT_FAILED);
              }
           }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Buffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(Buffer1,true);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift1);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Buffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(Buffer2,true);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift2);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Buffer3,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(Buffer3,true);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift3);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="r_Gator";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---
   Comment("");
//---
   ChartRedraw(0);
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
//--- проверка количества баров на достаточность для расчета
   for(int i=0; i<3; i++)
      for(int k=0; k<4; k++)
         for(int r=0; r<7; r++)
            if(BarsCalculated(MA_Handle[i][k][r])<rates_total) return(RESET);
//---
   if(rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int limit,to_copy;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total;   // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//--- индексация элементов в массивах, как в таймсериях 
   for(int i=0; i<3; i++)
      for(int k=0; k<4; k++)
         for(int r=0; r<7; r++)
            ArraySetAsSeries(Arr[i][k][r].Array,true);
//---   
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   for(int i=0; i<3; i++)
      for(int k=0; k<4; k++)
         for(int r=0; r<7; r++)
            if(CopyBuffer(MA_Handle[i][k][r],0,0,to_copy,Arr[i][k][r].Array)<=0) return(RESET);

//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Buffer1[bar]=0.0; for(int k=0; k<4; k++) for(int r=0; r<7; r++) Buffer1[bar]+=Arr[0][k][r].Array[bar]; Buffer1[bar]/=28;
      Buffer2[bar]=0.0; for(int k=0; k<4; k++) for(int r=0; r<7; r++) Buffer2[bar]+=Arr[1][k][r].Array[bar]; Buffer2[bar]/=28;
      Buffer3[bar]=0.0; for(int k=0; k<4; k++) for(int r=0; r<7; r++) Buffer3[bar]+=Arr[2][k][r].Array[bar]; Buffer3[bar]/=28;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
