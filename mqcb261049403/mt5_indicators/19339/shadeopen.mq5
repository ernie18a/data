//+------------------------------------------------------------------+ 
//|                                                    ShadeOpen.mq5 | 
//|                               Copyright © 2017, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2017, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.60"
#property description "Индикатор ночных ссесий в виде свечек."
//--- отрисовка индикатора в основном окне
#property indicator_chart_window
//--- количество индикаторных буферов 6
#property indicator_buffers 6
//--- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                                        // Константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "ShadeOpen"                     // Константа для имени индикатора
#define EMPTYVALUE 0                                   // Константа для неотображаемых значений индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цвета индикатора использованы
#property indicator_color1  clrPaleGreen,clrYellow
//--- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label1  "Upper Shade"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//--- в качестве цвета индикатора использованы
#property indicator_color2  clrLimeGreen,clrDarkOrange
//--- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label2  "Body"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 3            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type3   DRAW_FILLING
//--- в качестве цвета индикатора использован
#property indicator_color3  clrPaleGreen,clrYellow
//--- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//--- отображение метки индикатора
#property indicator_label3  "Lower Shade"
//+------------------------------------------------------------------+
//|  Объявление перечисления часов суток                             |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|  Объявление перечисления минут часов                             |
//+------------------------------------------------------------------+
enum MINUTS
  {
   ENUM_MINUT_0=0,   //0
   ENUM_MINUT_1,     //1
   ENUM_MINUT_2,     //2
   ENUM_MINUT_3,     //3
   ENUM_MINUT_4,     //4
   ENUM_MINUT_5,     //5
   ENUM_MINUT_6,     //6
   ENUM_MINUT_7,     //7
   ENUM_MINUT_8,     //8
   ENUM_MINUT_9,     //9
   ENUM_MINUT_10,     //10
   ENUM_MINUT_11,     //11   
   ENUM_MINUT_12,     //12
   ENUM_MINUT_13,     //13
   ENUM_MINUT_14,     //14
   ENUM_MINUT_15,     //15
   ENUM_MINUT_16,     //16
   ENUM_MINUT_17,     //17
   ENUM_MINUT_18,     //18
   ENUM_MINUT_19,     //19
   ENUM_MINUT_20,     //20
   ENUM_MINUT_21,     //21  
   ENUM_MINUT_22,     //22
   ENUM_MINUT_23,     //23
   ENUM_MINUT_24,     //24
   ENUM_MINUT_25,     //25
   ENUM_MINUT_26,     //26
   ENUM_MINUT_27,     //27
   ENUM_MINUT_28,     //28
   ENUM_MINUT_29,     //29
   ENUM_MINUT_30,     //30
   ENUM_MINUT_31,     //31  
   ENUM_MINUT_32,     //32
   ENUM_MINUT_33,     //33
   ENUM_MINUT_34,     //34
   ENUM_MINUT_35,     //35
   ENUM_MINUT_36,     //36
   ENUM_MINUT_37,     //37
   ENUM_MINUT_38,     //38
   ENUM_MINUT_39,     //39 
   ENUM_MINUT_40,     //40
   ENUM_MINUT_41,     //41  
   ENUM_MINUT_42,     //42
   ENUM_MINUT_43,     //43
   ENUM_MINUT_44,     //44
   ENUM_MINUT_45,     //45
   ENUM_MINUT_46,     //46
   ENUM_MINUT_47,     //47
   ENUM_MINUT_48,     //48
   ENUM_MINUT_49,     //49
   ENUM_MINUT_50,     //50
   ENUM_MINUT_51,     //51  
   ENUM_MINUT_52,     //52
   ENUM_MINUT_53,     //53
   ENUM_MINUT_54,     //54
   ENUM_MINUT_55,     //55
   ENUM_MINUT_56,     //56
   ENUM_MINUT_57,     //57
   ENUM_MINUT_58,     //58
   ENUM_MINUT_59      //59             
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input HOURS  StartH=ENUM_HOUR_6;   //Старт торговли (Часы)
input MINUTS StartM=ENUM_MINUT_30; //Старт торговли (Минуты)
input HOURS  EndH=ENUM_HOUR_13;    //Окончание торговли (Часы)
input MINUTS EndM=ENUM_MINUT_5;    //Окончание торговли (Минуты) 
input int    Shift=0;              //Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double ExtA1Buffer[];
double ExtB1Buffer[];
double ExtA2Buffer[];
double ExtB2Buffer[];
double ExtA3Buffer[];
double ExtB3Buffer[];
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка входных переменных 
   if(StartH>EndH || (StartH==EndH && StartM>=EndM))
     {
      Print("Неверные значения входных переменных старта и окончания торговли!");
      return(INIT_PARAMETERS_INCORRECT);
     }

//--- инициализация переменных 
   min_rates_total=2;
//--- превращение динамических массивов в индикаторные буферы
   ArrayInit(0,ExtA1Buffer);
   ArrayInit(1,ExtB1Buffer);
   ArrayInit(2,ExtA2Buffer);
   ArrayInit(3,ExtB2Buffer);
   ArrayInit(4,ExtA3Buffer);
   ArrayInit(5,ExtB3Buffer);
//--- инициализация индикаторов
   PlotInit(0,2,Shift);
   PlotInit(1,2,Shift);
   PlotInit(2,2,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int limit;
   static int lshift=NULL;
   double;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated+lshift; // стартовый номер для расчёта новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(!ShadeOpenCheck(time[bar]))
        {
         ExtA1Buffer[bar]=EMPTYVALUE;
         ExtB1Buffer[bar]=EMPTYVALUE;
         ExtA2Buffer[bar]=EMPTYVALUE;
         ExtB2Buffer[bar]=EMPTYVALUE;
         ExtA3Buffer[bar]=EMPTYVALUE;
         ExtB3Buffer[bar]=EMPTYVALUE;
         lshift=NULL;
         continue;
        }
      else
        {
         datetime Start=GetShadeOpenStart(time[bar]);
         datetime End=MathMin(GetShadeOpenEnd(time[bar]),time[0]);
         double iOpen[1],iClose[1],iHigh[],iLow[];
         //---- индексация элементов в массивах как в таймсериях  
         ArraySetAsSeries(iHigh,true);
         ArraySetAsSeries(iLow,true);
         //----
         if(CopyOpen(Symbol(),PERIOD_CURRENT,Start,1,iOpen)<=0) return(RESET);
         if(CopyHigh(Symbol(),PERIOD_CURRENT,Start,End,iHigh)<=0) return(RESET);
         if(CopyLow(Symbol(),PERIOD_CURRENT,Start,End,iLow)<=0) return(RESET);
         if(CopyClose(Symbol(),PERIOD_CURRENT,End,1,iClose)<=0) return(RESET);
         //----
         double ihigh=iHigh[ArrayMaximum(iHigh,0,WHOLE_ARRAY)];
         double ilow=iLow[ArrayMinimum(iLow,0,WHOLE_ARRAY)];
         //----
         if(iClose[0]>=iOpen[0])
           {
            ExtA1Buffer[bar]=ihigh;
            ExtB1Buffer[bar]=iClose[0];
            ExtA2Buffer[bar]=iClose[0];
            ExtB2Buffer[bar]=iOpen[0];
            ExtA3Buffer[bar]=iOpen[0];
            ExtB3Buffer[bar]=ilow;
           }
         else
           {
               ExtB1Buffer[bar]=ihigh;
               ExtA1Buffer[bar]=iClose[0];
               ExtA2Buffer[bar]=iClose[0];
               ExtB2Buffer[bar]=iOpen[0];
               ExtB3Buffer[bar]=iOpen[0];
               ExtA3Buffer[bar]=ilow;
           }
         lshift=bar;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+  
//| Определение сигналов для торговли в периоде                      |
//+------------------------------------------------------------------+  
bool ShadeOpenCheck(datetime ChkTime)
  {
//---- Объявление переменной для разрешения торговли
   bool Trade=false;
   MqlDateTime tm;
   TimeToStruct(ChkTime,tm);

   if(StartH<EndH)
     {
      if(tm.hour==StartH && tm.min>=StartM) Trade=true;
      if(tm.hour>StartH && tm.hour<EndH) Trade=true;
      if(tm.hour>StartH && tm.hour==EndH && tm.min<EndM) Trade=true;
     }
   if(StartH==EndH)
     {
      if(tm.hour==StartH && tm.min>=StartM && tm.min<EndM) Trade=true;
     }
//---- 
   return(Trade);
  }
//+------------------------------------------------------------------+  
//| Определение начала для торговли в периоде                        |
//+------------------------------------------------------------------+  
datetime GetShadeOpenStart(datetime ChkTime)
  {
//---- 
   datetime Start,iTime[1];
   if(CopyTime(Symbol(),PERIOD_D1,ChkTime,1,iTime)<=0) return(RESET);
   Start=iTime[0]+StartH*60*60+StartM*60;
//---- 
   return(Start);
  }
//+------------------------------------------------------------------+  
//| Определение конца для торговли в периоде                         |
//+------------------------------------------------------------------+  
datetime GetShadeOpenEnd(datetime ChkTime)
  {
//---- Объявление
   datetime End,iTime[1];
   if(CopyTime(Symbol(),PERIOD_D1,ChkTime,1,iTime)<=0) return(RESET);
   End=iTime[0]+EndH*60*60+EndM*60;
//---- 
   return(End);
  }
//+------------------------------------------------------------------+
//| PlotInit()                                                       |
//+------------------------------------------------------------------+    
void PlotInit(uint PlotNumber,
              int DrawBegin,
              int PlotShift)
  {
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(PlotNumber,PLOT_DRAW_BEGIN,DrawBegin);
//--- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(PlotNumber,PLOT_SHIFT,PlotShift);
//---
  }
//+------------------------------------------------------------------+
//| ArrayInit()                                                      |
//+------------------------------------------------------------------+    
void ArrayInit(uint ArrNumber,
               double &Array[])
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(ArrNumber,Array,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Array,true);
//---
  }
//+------------------------------------------------------------------+
