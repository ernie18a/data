//+------------------------------------------------------------------+ 
//|                                          Begin_Trend_v02_HTF.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "Begin_Trend_v02 с возможностью изменения таймфрейма во входных параметрах"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window
//--- для расчета и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//--- использовано четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                            // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "Begin_Trend_v02"   // Константа для имени индикатора
#define SIZE 1                             // Константа для количества вызовов функции CountIndicator коде
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//--- использовано четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//| Параметры отрисовки индикатора +             |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color1  clrLimeGreen
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "Begin_Trend_v01 Up"
//+----------------------------------------------+
//| Параметры отрисовки индикатора -             |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//--- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color2  clrRed
//--- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2  "Begin_Trend_v01 Down"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Buy           |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде гистограммы
#property indicator_type3   DRAW_HISTOGRAM
//--- в качестве цвета бычей линии индикатора использован салатовый цвет
#property indicator_color3  clrLime
//--- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//--- толщина линии индикатора 3 равна 4
#property indicator_width3  4
//--- отображение бычей метки индикатора
#property indicator_label3  "Begin_Trend_v01 Up"
//+----------------------------------------------+
//| Параметры отрисовки индикатора Sell          |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде гистограммы
#property indicator_type4   DRAW_HISTOGRAM
//--- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color4  clrRed
//--- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//--- толщина линии индикатора 4 равна 4
#property indicator_width4  4
//--- отображение медвежьей метки индикатора
#property indicator_label4  "Begin_Trend_v01 Down"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 +100.0
#property indicator_level2  +50.0
#property indicator_level3    0.0
#property indicator_level4  -50.0
#property indicator_level5 -100.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;  // Период графика индикатора (таймфрейм)
input uint Period_Channel=70;
input uint Period_Input=48;
input int Shift=0;                          // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double Up1IndBuffer[];
double Dn1IndBuffer[];
double Up2IndBuffer[];
double Dn2IndBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(INIT_FAILED);
//--- инициализация переменных 
   min_rates_total=2;
//--- получение хендла индикатора Begin_Trend_v02
   Ind_Handle=iCustom(Symbol(),TimeFrame,"Begin_Trend_v02",Period_Channel,Period_Input,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Begin_Trend_v02");
      return(INIT_FAILED);
     }
//--- инициализация индикаторных буферов
   IndInit(0,Up1IndBuffer,INDICATOR_DATA);
   IndInit(1,Dn1IndBuffer,INDICATOR_DATA);
   IndInit(2,Up2IndBuffer,INDICATOR_DATA);
   IndInit(3,Dn2IndBuffer,INDICATOR_DATA);
//--- инициализация индикаторов
   PlotInit(0,EMPTY_VALUE,0,Shift);
   PlotInit(1,EMPTY_VALUE,0,Shift);
   PlotInit(2,EMPTY_VALUE,0,Shift);
   PlotInit(3,EMPTY_VALUE,0,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",GetStringTimeframe(TimeFrame),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//---
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,Up1IndBuffer,1,Dn1IndBuffer,2,
      Up2IndBuffer,3,Dn2IndBuffer,time,rates_total,prev_calculated,min_rates_total))return(RESET);
//---     
   return(rates_total);
  }
//---
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],ENUM_INDEXBUFFER_TYPE Type)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,Buffer,Type);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| Инициализация индикатора                                         |
//+------------------------------------------------------------------+    
void PlotInit(int Number,double Empty_Value,int Draw_Begin,int nShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---
  }
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // Номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // Символ графика
                    ENUM_TIMEFRAMES TFrame,   // Период графика
                    int      IndHandle,       // Хендл обрабатываемого индикатора
                    uint     Up1BuffNumb,      // Номер верхнего буфера обрабатываемого индикатора для облака
                    double&  Up1IndBuf[],      // Приемный верхний буфер индикатора 1
                    uint     Dn1BuffNumb,      // Номер нижнего буфера обрабатываемого индикатора для облака
                    double&  Dn1IndBuf[],      // Приемный нижний буфер индикатора 2
                    uint     Up2BuffNumb,      // Номер верхнего буфера обрабатываемого индикатора для облака
                    double&  Up2IndBuf[],      // Приемный верхний буфер индикатора 3
                    uint     Dn2BuffNumb,      // Номер нижнего буфера обрабатываемого индикатора для облака
                    double&  Dn2IndBuf[],      // Приемный нижний буфер индикатора 4
                    const datetime& iTime[],  // Таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol(),TFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Up1Arr[1],Dn1Arr[1];
         double Up2Arr[1],Dn2Arr[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(IndHandle,Up1BuffNumb,iTime[bar],1,Up1Arr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,Dn1BuffNumb,iTime[bar],1,Dn1Arr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,Up2BuffNumb,iTime[bar],1,Up2Arr)<=0) return(RESET);
         if(CopyBuffer(IndHandle,Dn2BuffNumb,iTime[bar],1,Dn2Arr)<=0) return(RESET);
         //---         
         Up1IndBuf[bar]=Up1Arr[0];
         Dn1IndBuf[bar]=Dn1Arr[0];
         Up2IndBuf[bar]=Up2Arr[0];
         Dn2IndBuf[bar]=Dn2Arr[0];
        }
      else
        {
         Up1IndBuf[bar]=Up1IndBuf[bar+1];
         Dn1IndBuf[bar]=Dn1IndBuf[bar+1];
         Up2IndBuf[bar]=Up2IndBuf[bar+1];
         Dn2IndBuf[bar]=Dn2IndBuf[bar+1];
        }
     }
//--- 
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeFramesCheck()                                                |
//+------------------------------------------------------------------+    
bool TimeFramesCheck(string IndName,
                     ENUM_TIMEFRAMES TFrame) //Период графика индикатора (таймфрейм)
  {
//--- проверка периодов графиков на корректность
   if(TFrame<Period() && TFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора "+IndName+" не может быть меньше периода текущего графика!");
      Print("Следует изменить входные параметры индикатора!");
      return(RESET);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
