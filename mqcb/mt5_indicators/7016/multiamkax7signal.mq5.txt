//+---------------------------------------------------------------------+
//|                                               MultiAMkAx7Signal.mq5 | 
//|                                  Copyright © 2014, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description ""
//---- номер версии индикатора
#property version   "1.60"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- фиксированная высота подокна индикатора в пикселях 
#property indicator_height 90
//---- нижнее и верхнее ограничения шкалы отдельного окна индикатора
#property indicator_maximum +7.9
#property indicator_minimum +0.3
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0                                         // Константа для возврата терминалу команды на пересчёт индикатора
#define INDTOTAL 7                                      // Константа для количества отображаемых индикаторов
#define INDICATOR_NAME "AMkA"                           // Константа для имени индикатора
//+-----------------------------------+
//---- количество индикаторных буферов
#property indicator_buffers 28 // INDTOTAL*4
//---- использовано всего графических построений
#property indicator_plots   21 // INDTOTAL*3

//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color1 clrGray,clrDarkOrange,clrDarkTurquoise
//---- линия индикатора - штрих
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
////#property indicator_label1  "Signal line 1"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора 1 в виде значка
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color2 clrLimeGreen
//---- толщина линии индикатора равна 3
#property indicator_width2  3
//---- отображение метки индикатора
//#property indicator_label2  "Up AMkA 1"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 1 |
//+-----------------------------------+
//---- отрисовка индикатора 1 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color3 clrIndianRed
//---- толщина линии индикатора равна 3
#property indicator_width3  3
//---- отображение метки индикатора
//#property indicator_label3  "Down AMkA 1"

//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type4   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color4 clrGray,clrDarkOrange,clrDarkTurquoise
//---- линия индикатора - штрих
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width4  3
//---- отображение метки индикатора
//#property indicator_label4  "Signal line 2"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора 2 в виде значка
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color5 clrLimeGreen
//---- толщина линии индикатора равна 3
#property indicator_width5  3
//---- отображение метки индикатора
//#property indicator_label5  "Up AMkA 2"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 2 |
//+-----------------------------------+
//---- отрисовка индикатора 2 в виде значка
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color6 clrIndianRed
//---- толщина линии индикатора равна 3
#property indicator_width6  3
//---- отображение метки индикатора
//#property indicator_label6  "Down AMkA 2"

//+-----------------------------------+
//|  Параметры отрисовки индикатора 3 |
//+-----------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type7   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color7 clrGray,clrDarkOrange,clrDarkTurquoise
//---- линия индикатора - штрих
#property indicator_style7  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width7  3
//---- отображение метки индикатора
//#property indicator_label7  "Signal line 3"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 3 |
//+-----------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type8   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color8 clrLimeGreen
//---- толщина линии индикатора равна 3
#property indicator_width8  3
//---- отображение метки индикатора
//#property indicator_label8  "Up AMkA 3"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 3 |
//+-----------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type9   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color9 clrIndianRed
//---- толщина линии индикатора равна 3
#property indicator_width9  3
//---- отображение метки индикатора
//#property indicator_label9  "Down AMkA 3"

//+-----------------------------------+
//|  Параметры отрисовки индикатора 4 |
//+-----------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type10   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color10 clrGray,clrDarkOrange,clrDarkTurquoise
//---- линия индикатора - штрих
#property indicator_style10 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width10  3
//---- отображение метки индикатора
//#property indicator_label10  "Signal line 4"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 4 |
//+-----------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type11   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color11 clrLimeGreen
//---- толщина линии индикатора равна 3
#property indicator_width11  3
//---- отображение метки индикатора
//#property indicator_label11  "Up AMkA 4"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 4 |
//+-----------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type12   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color12 clrIndianRed
//---- толщина линии индикатора равна 3
#property indicator_width12  3
//---- отображение метки индикатора
//#property indicator_label12  "Down AMkA 4"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 5 |
//+-----------------------------------+
//---- отрисовка индикатора 5 в виде линии
#property indicator_type13   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color13 clrGray,clrDarkOrange,clrDarkTurquoise
//---- линия индикатора - штрих
#property indicator_style13 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width13  3
//---- отображение метки индикатора
//#property indicator_label13  "Signal line 5"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 5 |
//+-----------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type14   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color14 clrLimeGreen
//---- толщина линии индикатора равна 3
#property indicator_width14  3
//---- отображение метки индикатора
//#property indicator_label14  "Up AMkA 5"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 5 |
//+-----------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type15   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color15 clrIndianRed
//---- толщина линии индикатора равна 3
#property indicator_width15  3
//---- отображение метки индикатора
//#property indicator_label15  "Down AMkA 5"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 6 |
//+-----------------------------------+
//---- отрисовка индикатора 6 в виде линии
#property indicator_type16   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color16 clrGray,clrDarkOrange,clrDarkTurquoise
//---- линия индикатора - штрих
#property indicator_style16 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width16  3
//---- отображение метки индикатора
//#property indicator_label16  "Signal line 6"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 6 |
//+-----------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type17   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color17 clrLimeGreen
//---- толщина линии индикатора равна 3
#property indicator_width17  3
//---- отображение метки индикатора
//#property indicator_label17  "Up AMkA 6"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 6 |
//+-----------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type18   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color18 clrIndianRed
//---- толщина линии индикатора равна 3
#property indicator_width18  3
//---- отображение метки индикатора
//#property indicator_label18  "Down AMkA 6"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 7 |
//+-----------------------------------+
//---- отрисовка индикатора 7 в виде линии
#property indicator_type19   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color19 clrGray,clrDarkOrange,clrDarkTurquoise
//---- линия индикатора - штрих
#property indicator_style19 STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width19  1
//---- отображение метки индикатора
//#property indicator_label19  "Signal line 7"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 7 |
//+-----------------------------------+
//---- отрисовка индикатора 7 в виде значка
#property indicator_type20   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color20 clrLimeGreen
//---- толщина линии индикатора равна 1
#property indicator_width20  1
//---- отображение метки индикатора
//#property indicator_label20  "Up AMkA 7"
//+-----------------------------------+
//|  Параметры отрисовки индикатора 7 |
//+-----------------------------------+
//---- отрисовка индикатора 7 в виде значка
#property indicator_type21   DRAW_ARROW
//---- в качестве цвета значка использован
#property indicator_color21 clrIndianRed
//---- толщина линии индикатора равна 1
#property indicator_width21  1
//---- отображение метки индикатора
//#property indicator_label21  "Down AMkA 7"
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame0=PERIOD_D1;  //1 Период графика
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H12; //2 Период графика
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H8;  //3 Период графика
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H6;  //4 Период графика
input ENUM_TIMEFRAMES TimeFrame4=PERIOD_H4;  //5 Период графика
input ENUM_TIMEFRAMES TimeFrame5=PERIOD_H2;  //6 Период графика
input ENUM_TIMEFRAMES TimeFrame6=PERIOD_M30; //7 Период графика
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int ama_period=9;                          // период AMA
input int fast_ma_period=2;                      // период быстрой скользящей
input int slow_ma_period=30;                     // период медленной скользящей
input double G=2.0;                              // степень, в которую возводится сглаживающая константа
input int AMAShift = 0;                          // сдвиг индикатора по горизонтали в барах 
input double dK = 1.0;                           // коэффициент для фильтра
//+-----------------------------------+
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+
//|  Получение стрингового таймфрейма                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//|  Класс индикаторных буферов                                      |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
   //----
public:
   double            m_UpBuffer[];
   double            m_DnBuffer[];
   double            m_LineBuffer[];
   double            m_ColorLineBuffer[];
   int               m_Handle;
   ENUM_TIMEFRAMES   m_TimeFrame;
   //---- 
  };

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
CIndBuffers Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| AMkA indicator initialization function                           | 
//+------------------------------------------------------------------+ 
bool IndInit(uint Number)
  {
//---- проверка периодов графиков на корректность
   if(Ind[Number].m_TimeFrame<Period() && Ind[Number].m_TimeFrame!=PERIOD_CURRENT)
     {
      Print("IndInit(",Number,"): Период графика для индикатора AMkA не может быть меньше периода текущего графика");
      return(false);
     }

//---- Получение хендлов индикаторов  
   Ind[Number].m_Handle=iCustom(NULL,Ind[Number].m_TimeFrame,"AMkA",ama_period,fast_ma_period,slow_ma_period,G,0,dK);


   if(Ind[Number].m_Handle==INVALID_HANDLE)
     {
      Print("IndInit(",Number,"): Не удалось получить хендл индикатора AMkA");
      return(false);
     }

   uint BIndex=Number*4+0;
   uint PIndex=Number*3+0;
   InitTsIndBuffer(BIndex,PIndex,Ind[Number].m_LineBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(BIndex+1,PIndex,Ind[Number].m_ColorLineBuffer,min_rates_total);
   InitTsIndArrBuffer(BIndex+2,PIndex+1,Ind[Number].m_UpBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndArrBuffer(BIndex+3,PIndex+2,Ind[Number].m_DnBuffer,EMPTY_VALUE,min_rates_total);
//----   
   string tmf=GetStringTimeframe(Ind[Number].m_TimeFrame);
   PlotIndexSetString(PIndex+0,PLOT_LABEL,INDICATOR_NAME+"("+tmf+")");
   PlotIndexSetString(PIndex+1,PLOT_LABEL,INDICATOR_NAME+"Up("+tmf+")");
   PlotIndexSetString(PIndex+2,PLOT_LABEL,INDICATOR_NAME+"Down("+tmf+")");

//---- завершение инициализации одного индикатора
   return(true);
  }
//+------------------------------------------------------------------+
//|  Инициализация индикаторного буфера таймсерии                    |
//+------------------------------------------------------------------+  
void InitTsIndBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//----
  }
//+------------------------------------------------------------------+
//|  Инициализация индикаторного буфера таймсерии                    |
//+------------------------------------------------------------------+  
void InitTsIndArrBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(Plot,PLOT_ARROW,167);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//----
  }
//+------------------------------------------------------------------+
//|  Инициализация индикаторного буфера цвета таймсерии              |
//+------------------------------------------------------------------+  
void InitTsIndColorBuffer(uint Number,uint Plot,double &IndColorBuffer[],uint Draw_Begin)
  {
//---- превращение динамического массива в цветовой индексный буфер   
   SetIndexBuffer(Number,IndColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndColorBuffer,true);
//----
  }
//+------------------------------------------------------------------+ 
//| AMkA iteration function                                          | 
//+------------------------------------------------------------------+ 
bool IndOnCalculate(uint Number,uint Limit,const datetime &Time[],uint Rates_Total,uint Prev_Calculated)
  {
//---- Объявление целых переменных
   uint limit_;
//---- Объявление переменных с плавающей точкой  
   double Dn[1],Up[1];
   datetime Time_[1],Time0;
   static uint LastCountBar[INDTOTAL];

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчёта индикатора
     {
      LastCountBar[Number]=Rates_Total;
      limit_=Limit;
     }
   else limit_=int(LastCountBar[Number])+Limit; // стартовый номер для расчёта новых баров 

//---- Основной цикл расчёта индикатора
   for(int bar=int(limit_); bar>=0 && !IsStopped(); bar--)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      Ind[Number].m_UpBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_DnBuffer[bar]=EMPTY_VALUE;

      Ind[Number].m_LineBuffer[bar]=Number+1.0;

      Ind[Number].m_ColorLineBuffer[bar]=0;
      Time0=Time[bar];

      //---- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),Ind[Number].m_TimeFrame,Time0,1,Time_)<=0) return(RESET);

      if(Time0>=Time_[0] && Time[bar+1]<Time_[0])
        {
         LastCountBar[Number]=bar;

         //---- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind[Number].m_Handle,2,Time0,1,Up)<=0) return(RESET);
         if(CopyBuffer(Ind[Number].m_Handle,1,Time0,1,Dn)<=0) return(RESET);

         if(Up[0])
           {
            Ind[Number].m_UpBuffer[bar]=Number+1.0;
            Ind[Number].m_ColorLineBuffer[bar]=2;
           }

         if(Dn[0])
           {
            Ind[Number].m_DnBuffer[bar]=Number+1.0;
            Ind[Number].m_ColorLineBuffer[bar]=1;
           }
        }
      else
      if(Ind[Number].m_ColorLineBuffer[bar+1] && !Ind[Number].m_ColorLineBuffer[bar]) Ind[Number].m_ColorLineBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
     }
//---- завершение расчёта одного индикатора    
   return(true);
  }
//+------------------------------------------------------------------+   
//| AMkA indicator initialization function                           | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=3;

//---- Инициализация переменных 
   Ind[0].m_TimeFrame=TimeFrame0;
   Ind[1].m_TimeFrame=TimeFrame1;
   Ind[2].m_TimeFrame=TimeFrame2;
   Ind[3].m_TimeFrame=TimeFrame3;
   Ind[4].m_TimeFrame=TimeFrame4;
   Ind[5].m_TimeFrame=TimeFrame5;
   Ind[6].m_TimeFrame=TimeFrame6;

//---- Инициализация буферов индикаторов
   for(int count=0; count<INDTOTAL; count++) if(!IndInit(count)) return(INIT_FAILED);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"MultiAMkASignal");

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| AMkA iteration function                                          | 
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
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(RESET);
   for(int count=0; count<INDTOTAL; count++)
      if(BarsCalculated(Ind[count].m_Handle)<Bars(Symbol(),Ind[count].m_TimeFrame))
         return(prev_calculated);
//---- Объявление целых переменных
   int limit;
//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров 

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);

   for(int count=0; count<INDTOTAL; count++) if(!IndOnCalculate(count,limit,time,rates_total,prev_calculated)) return(RESET);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
