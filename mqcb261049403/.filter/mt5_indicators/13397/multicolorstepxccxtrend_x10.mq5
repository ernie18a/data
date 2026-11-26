//+------------------------------------------------------------------+
//|                                  MultiColorStepXCCXTrend_x10.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//| Для работы  индикатора файл SmoothAlgorithms.mqh                 |
//| следует положить в папку: каталог_данных_терминала\\MQL5\Include |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Индикатор отображает положение осциллятора ColorStepXCCX с разных таймфреймов"
//--- номер версии индикатора
#property version   "1.60"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- фиксированная высота подокна индикатора в пикселях 
#property indicator_height 150
//--- нижнее и верхнее ограничения шкалы отдельного окна индикатора
#property indicator_maximum +10.9
#property indicator_minimum +0.3
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                  // константа для возврата терминалу команды на пересчет индикатора
#define INDTOTAL 10                              // Константа для количества отображаемых индикаторов
#define INDICATOR_NAME "ColorStepXCCXTrend_x10"  // константа для имени индикатора
//+----------------------------------------------+
//--- количество индикаторных буферов
#property indicator_buffers 40 // INDTOTAL*4
//--- использовано всего графических построений
#property indicator_plots   20 // INDTOTAL*2
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color1 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width1  3
//--- отображение метки индикатора
#property indicator_label1  "Signal line 1"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде значка
#property indicator_type2   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color2 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width2  5
//--- отображение метки индикатора
#property indicator_label2  "Signal Arrow 1"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color3 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style3  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width3  3
//--- отображение метки индикатора
#property indicator_label3  "Signal line 2"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде значка
#property indicator_type4   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color4 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width4  5
//--- отображение метки индикатора
#property indicator_label4  "Signal Arrow 2"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде линии
#property indicator_type5   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color5 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style5  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width5  3
//--- отображение метки индикатора
#property indicator_label5  "Signal line 3"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде значка
#property indicator_type6   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color6 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width6  5
//--- отображение метки индикатора
#property indicator_label6  "Signal Arrow 3"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 4             |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде линии
#property indicator_type7   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color7 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style7  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width7  3
//--- отображение метки индикатора
#property indicator_label7  "Signal line 4"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 4             |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде значка
#property indicator_type8   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color8 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width8  5
//--- отображение метки индикатора
#property indicator_label8  "Signal Arrow 4"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 5             |
//+----------------------------------------------+
//--- отрисовка индикатора 5 в виде линии
#property indicator_type9   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color9 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style9  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width9  3
//--- отображение метки индикатора
#property indicator_label9  "Signal line 5"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 5             |
//+----------------------------------------------+
//--- отрисовка индикатора 5 в виде значка
#property indicator_type10   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color10 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width10  5
//--- отображение метки индикатора
#property indicator_label10  "Signal Arrow 5"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 6             |
//+----------------------------------------------+
//--- отрисовка индикатора 6 в виде линии
#property indicator_type11   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color11 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style11  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width11  3
//--- отображение метки индикатора
#property indicator_label11  "Signal line 6"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 6             |
//+----------------------------------------------+
//--- отрисовка индикатора 6 в виде значка
#property indicator_type12   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color12 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width12  5
//--- отображение метки индикатора
#property indicator_label12  "Signal Arrow 6"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 7             |
//+----------------------------------------------+
//--- отрисовка индикатора 7 в виде линии
#property indicator_type13   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color13 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style13  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width13  3
//--- отображение метки индикатора
#property indicator_label13  "Signal line 7"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 7             |
//+----------------------------------------------+
//--- отрисовка индикатора 7 в виде значка
#property indicator_type14   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color14 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width14  5
//--- отображение метки индикатора
#property indicator_label14  "Signal Arrow 7"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 8             |
//+----------------------------------------------+
//--- отрисовка индикатора 8 в виде линии
#property indicator_type15   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color15 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style15  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width15  3
//--- отображение метки индикатора
#property indicator_label15  "Signal line 8"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 8             |
//+----------------------------------------------+
//--- отрисовка индикатора 8 в виде значка
#property indicator_type16   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color16 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width16  5
//--- отображение метки индикатора
#property indicator_label16  "Signal Arrow 8"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 9             |
//+----------------------------------------------+
//--- отрисовка индикатора 9 в виде линии
#property indicator_type17   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color17 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style17  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width17  3
//--- отображение метки индикатора
#property indicator_label17  "Signal line 9"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 9             |
//+----------------------------------------------+
//--- отрисовка индикатора 9 в виде значка
#property indicator_type18   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color18 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width18  5
//--- отображение метки индикатора
#property indicator_label18  "Signal Arrow 9"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 10            |
//+----------------------------------------------+
//--- отрисовка индикатора 10 в виде линии
#property indicator_type19   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color19 clrMagenta,clrGray,clrTeal
//--- линия индикатора - штрих
#property indicator_style19  STYLE_SOLID
//--- толщина линии индикатора равна 3
#property indicator_width19  3
//--- отображение метки индикатора
#property indicator_label19  "Signal line 10"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 10            |
//+----------------------------------------------+
//--- отрисовка индикатора 10 в виде значка
#property indicator_type20   DRAW_COLOR_ARROW
//--- в качестве цвета значка использован
#property indicator_color20 clrMagenta,clrGray,clrTeal
//--- толщина линии индикатора равна 5
#property indicator_width20  5
//--- отображение метки индикатора
#property indicator_label20  "Signal Arrow 10"
//+-----------------------------------+
//| Описание класса CXMA              |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_      // тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price 
  };
//---
/*enum Smooth_Method - объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame0=PERIOD_H1;           // Период графика 1
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H2;           // Период графика 2
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H3;           // Период графика 3
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H4;           // Период графика 4
input ENUM_TIMEFRAMES TimeFrame4=PERIOD_H6;           // Период графика 5
input ENUM_TIMEFRAMES TimeFrame5=PERIOD_H8;           // Период графика 6
input ENUM_TIMEFRAMES TimeFrame6=PERIOD_H12;          // Период графика 7
input ENUM_TIMEFRAMES TimeFrame7=PERIOD_D1;           // Период графика 8
input ENUM_TIMEFRAMES TimeFrame8=PERIOD_W1;           // Период графика 9
input ENUM_TIMEFRAMES TimeFrame9=PERIOD_MN1;          // Период графика 10
//---- параметры ColorStepXCCX
input Smooth_Method DSmoothMethod=MODE_JJMA;  // Метод усреднения цены
input uint DPeriod=30;                        // Период средней
input int DPhase=100;                         // Параметр усреднения
input Smooth_Method MSmoothMethod=MODE_T3;    // Метод усреднения отклонения
input uint MPeriod=7;                         // Период среднего отклонения
input int MPhase=15;                          // Параметр усреднения отклонения
input Applied_price_ IPC=PRICE_TYPICAL;       // Ценовая константа
input uint StepSizeFast=5;                    // Быстрый шаг
input uint StepSizeSlow=30;                   // Медленный шаг
//+----------------------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//| Класс индикаторных буферов                                       |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
   //---
public:
   double            m_ArrBuffer[];
   double            m_ColorArrBuffer[];
   double            m_LineBuffer[];
   double            m_ColorLineBuffer[];
   int               m_Handle;
   ENUM_TIMEFRAMES   m_TimeFrame;
  };
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
CIndBuffers Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| ColorStepXCCXTrend_x10 indicator initialization function         | 
//+------------------------------------------------------------------+ 
bool IndInit(uint Number)
  {
//--- проверка периодов графиков на корректность
   if(Ind[Number].m_TimeFrame<Period() && Ind[Number].m_TimeFrame!=PERIOD_CURRENT)
     {
      Print("IndInit(",Number,"): Период графика для индикатора ColorStepXCCXTrend_x10 не может быть меньше периода текущего графика");
      return(false);
     }
//---- получение хендлов индикаторов  
   Ind[Number].m_Handle=iCustom(NULL,Ind[Number].m_TimeFrame,"ColorStepXCCX",DSmoothMethod,DPeriod,DPhase,MSmoothMethod,MPeriod,MPhase,IPC,StepSizeFast,StepSizeSlow,0);

   if(Ind[Number].m_Handle==INVALID_HANDLE)
     {
      Print("IndInit(",Number,"): Не удалось получить хендл индикатора ColorStepXCCX");
      return(false);
     }
   uint BIndex=Number*4+0;
   uint PIndex=Number*2+0;
   InitTsIndBuffer(BIndex,PIndex,Ind[Number].m_LineBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(BIndex+1,Ind[Number].m_ColorLineBuffer,min_rates_total);
   InitTsIndArrBuffer(BIndex+2,PIndex+1,Ind[Number].m_ArrBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(BIndex+3,Ind[Number].m_ColorArrBuffer,min_rates_total);
//----   
   string tmf=GetStringTimeframe(Ind[Number].m_TimeFrame);
   PlotIndexSetString(PIndex+0,PLOT_LABEL,INDICATOR_NAME+"("+tmf+")");
   PlotIndexSetString(PIndex+1,PLOT_LABEL,INDICATOR_NAME+"Arr("+tmf+")");
//--- завершение инициализации
   return(true);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера таймсерии                     |
//+------------------------------------------------------------------+  
void InitTsIndBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера таймсерии                     |
//+------------------------------------------------------------------+  
void InitTsIndArrBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//--- выбор символа для отрисовки
   PlotIndexSetInteger(Plot,PLOT_ARROW,159);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера цвета таймсерии               |
//+------------------------------------------------------------------+  
void InitTsIndColorBuffer(uint Number,double &IndColorBuffer[],uint Draw_Begin)
  {
//--- превращение динамического массива в цветовой индексный буфер   
   SetIndexBuffer(Number,IndColorBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndColorBuffer,true);
  }
//+------------------------------------------------------------------+ 
//| IndOnCalculate                                                   | 
//+------------------------------------------------------------------+ 
bool IndOnCalculate(int Number,int Limit,const datetime &Time[],uint Rates_Total,uint Prev_Calculated)
  {
//--- объявление целочисленнных переменных
   int limit_;
//--- объявление переменных
   datetime Time_[1],Time0;
   static int LastCountBar[INDTOTAL];
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit_=Limit;
      LastCountBar[Number]=limit_;
     }
   else limit_=int(MathMin(LastCountBar[Number]+Limit,Rates_Total-2)); // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(int bar=int(limit_); bar>=0 && !IsStopped(); bar--)
     {
      //--- обнулим содержимое индикаторных буферов до расчета
      Ind[Number].m_ArrBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_LineBuffer[bar]=Number+1.0;
      Ind[Number].m_ColorArrBuffer[bar]=1;
      Ind[Number].m_ColorLineBuffer[bar]=1;
      Time0=Time[bar];
      //--- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),Ind[Number].m_TimeFrame,Time0,1,Time_)<=0) return(false);
      //---
      if(Time0>=Time_[0] && Time[bar+1]<Time_[0])
        {
         LastCountBar[Number]=bar;
         //--- объявление переменных
         double Up[1],Dn[1];
         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind[Number].m_Handle,0,Time0,1,Up)<=0) return(false);
         if(CopyBuffer(Ind[Number].m_Handle,1,Time0,1,Dn)<=0) return(false);

         if(Up[0]>Dn[0])
           {
            Ind[Number].m_ColorLineBuffer[bar]=2;
            Ind[Number].m_ColorArrBuffer[bar]=2;
           }
         //---
         if(Dn[0]>Up[0])
           {
            Ind[Number].m_ColorLineBuffer[bar]=0;
            Ind[Number].m_ColorArrBuffer[bar]=0;
           }
         //---
         Ind[Number].m_ArrBuffer[bar]=Number+1.0;
        }
      else Ind[Number].m_ColorLineBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
     }
//--- завершение расчета одного индикатора    
   return(true);
  }
//+------------------------------------------------------------------+   
//| ColorStepXCCXTrend_x10 indicator initialization function         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=GetStartBars(DSmoothMethod,DPeriod,DPhase);
   min_rates_total+=GetStartBars(MSmoothMethod,MPeriod,MPhase);
   min_rates_total++;
//--- инициализация переменных 
   Ind[0].m_TimeFrame=TimeFrame0;
   Ind[1].m_TimeFrame=TimeFrame1;
   Ind[2].m_TimeFrame=TimeFrame2;
   Ind[3].m_TimeFrame=TimeFrame3;
   Ind[4].m_TimeFrame=TimeFrame4;
   Ind[5].m_TimeFrame=TimeFrame5;
   Ind[6].m_TimeFrame=TimeFrame6;
   Ind[7].m_TimeFrame=TimeFrame7;
   Ind[8].m_TimeFrame=TimeFrame8;
   Ind[9].m_TimeFrame=TimeFrame9;
//--- инициализация буферов индикаторов
   for(int count=0; count<INDTOTAL; count++) if(!IndInit(count)) return(INIT_FAILED);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"MultiColorStepXCCXTrend_x10");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| ColorStepXCCXTrend_x10 iteration function                        | 
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
//--- объявление целочисленных переменных
   int limit;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров 
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
   for(int count=0; count<INDTOTAL; count++) if(!IndOnCalculate(count,limit,time,rates_total,prev_calculated)) return(RESET);
//---   
   return(rates_total);
  }
//+------------------------------------------------------------------+
