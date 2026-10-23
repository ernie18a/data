//+-----------------------------------------------------------------------+
//|                                                     Stalin_Signal.mq5 | 
//|                                    Copyright © 2018, Nikolay Kositsin | 
//|                                   Khabarovsk,   farria@mail.redcom.ru | 
//+-----------------------------------------------------------------------+
//| Для компиляции индикатора файл SmoothAlgorithms.mqh следует положить  |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include          |
//+-----------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description ""
//--- номер версии индикатора
#property version   "1.60"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- фиксированная высота подокна индикатора в пикселях 
#property indicator_height 20
//--- нижнее и верхнее ограничения шкалы отдельного окна индикатора
#property indicator_maximum +2.1
#property indicator_minimum +0.3
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                          // Константа для возврата терминалу команды на пересчет индикатора
#define INDTOTAL 1                       // Константа для количества отображаемых индикаторов
#define INDICATOR_NAME "Stalin"          // Константа для имени индикатора
//+----------------------------------------------+
//--- количество индикаторных буферов
#property indicator_buffers 4 // INDTOTAL*4
//--- использовано всего графических построений
#property indicator_plots   2 // INDTOTAL*2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color1 clrLimeGreen,clrRed
//--- линия индикатора - штрих
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1  2
//--- отображение метки индикатора
#property indicator_label1  "Signal line"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветных значков
#property indicator_type2 DRAW_COLOR_ARROW
//--- в качестве цветов пятицветной использованы
#property indicator_color2 clrLimeGreen,clrRed
//--- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//--- толщина линии индикатора равна 5
#property indicator_width2 5
//--- отображение метки индикатора
#property indicator_label2  "Signal Arrow"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;             //Период графика
input ENUM_MA_METHOD MAMethod=MODE_EMA;
input int    MAShift=0;
input int    Fast=14;
input int    Slow=21;
input int    RSI=17;
input int    Confirm=0.0;
input int    Flat=0.0;
input bool   SoundAlert=false;
input bool   EmailAlert=false;
//+----------------------------------------------+
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//|  Класс индикаторных буферов                                      |
//+------------------------------------------------------------------+  
class CIndBuffers
  {
   //---
public:
   double            m_LineBuffer[];
   double            m_ColorLineBuffer[];
   double            m_ArrowBuffer[];
   double            m_ColorArrowBuffer[];
   int               m_Handle;
   ENUM_TIMEFRAMES   m_TimeFrame;
   //--- 
  };
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
CIndBuffers Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| Stalin indicator initialization function                         | 
//+------------------------------------------------------------------+ 
bool IndInit(uint Number)
  {
//--- получение хендлов индикаторов  
   Ind[Number].m_Handle=iCustom(Symbol(),Ind[Number].m_TimeFrame,"Stalin_NRTR",MAMethod,MAShift,Fast,Slow,RSI,Confirm,Flat,0,SoundAlert,EmailAlert);
   if(Ind[Number].m_Handle==INVALID_HANDLE)
     {
      Print("IndInit(",Number,"): Не удалось получить хендл индикатора Stalin_NRTR");
      return(false);
     }
   uint BIndex=Number*4+0;
   uint PIndex=Number*2+0;
   InitTsIndBuffer(BIndex,PIndex,Ind[Number].m_LineBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(BIndex+1,Ind[Number].m_ColorLineBuffer);
   InitTsIndArrBuffer(BIndex+2,PIndex+1,Ind[Number].m_ArrowBuffer,EMPTY_VALUE,min_rates_total);
   InitTsIndColorBuffer(BIndex+3,Ind[Number].m_ColorArrowBuffer);
//----   
   string tmf=GetStringTimeframe(Ind[Number].m_TimeFrame);
   PlotIndexSetString(PIndex+0,PLOT_LABEL,INDICATOR_NAME+"Line("+tmf+")");
   PlotIndexSetString(PIndex+1,PLOT_LABEL,INDICATOR_NAME+"Arrow("+tmf+")");
//--- завершение инициализации одного индикатора
   return(true);
  }
//+------------------------------------------------------------------+
//|  Инициализация индикаторного буфера таймсерии                    |
//+------------------------------------------------------------------+  
void InitTsIndBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(Plot,PLOT_SHOW_DATA,false);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---
  }
//+------------------------------------------------------------------+
//|  Инициализация индикаторного буфера таймсерии                    |
//+------------------------------------------------------------------+  
void InitTsIndArrBuffer(uint Number,uint Plot,double &IndBuffer[],double Empty_Value,uint Draw_Begin)
  {
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(Number,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Plot,PLOT_DRAW_BEGIN,Draw_Begin);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Plot,PLOT_EMPTY_VALUE,Empty_Value);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(Plot,PLOT_SHOW_DATA,false);
//--- выбор символа для отрисовки
   PlotIndexSetInteger(Plot,PLOT_ARROW,171);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---
  }
//+------------------------------------------------------------------+
//|  Инициализация индикаторного буфера цвета таймсерии              |
//+------------------------------------------------------------------+  
void InitTsIndColorBuffer(uint Number,double &IndColorBuffer[])
  {
//--- превращение динамического массива в цветовой индексный буфер   
   SetIndexBuffer(Number,IndColorBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndColorBuffer,true);
//---
  }
//+------------------------------------------------------------------+ 
//| IndOnCalculate                                                   | 
//+------------------------------------------------------------------+ 
bool IndOnCalculate(int Number,int Limit,const datetime &Time[],uint Rates_Total,uint Prev_Calculated)
  {
//--- объявление целочисленнных переменных
   int limit_;
//--- объявление локальных переменных
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
      Ind[Number].m_LineBuffer[bar]=Number+1.0;
      Ind[Number].m_ArrowBuffer[bar]=EMPTY_VALUE;
      Ind[Number].m_ColorLineBuffer[bar]=EMPTY_VALUE;

      Time0=Time[bar];
      //--- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),Ind[Number].m_TimeFrame,Time0,1,Time_)<=0) return(RESET);

      if(Time0>=Time_[0] && Time[bar+1]<Time_[0])
        {
         LastCountBar[Number]=bar;
         Ind[Number].m_ArrowBuffer[bar]=Number+1.0;
         Ind[Number].m_ColorLineBuffer[bar]=2;

         double Up[1],Dn[1];
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(Ind[Number].m_Handle,0,Time0,1,Up)<=0) return(RESET);
         if(CopyBuffer(Ind[Number].m_Handle,1,Time0,1,Dn)<=0) return(RESET);

            if(Up[0])
              {
               Ind[Number].m_ColorLineBuffer[bar]=0;
               Ind[Number].m_ColorArrowBuffer[bar]=0;
              }
            if(Dn[0])
              {
               Ind[Number].m_ColorLineBuffer[bar]=1;
               Ind[Number].m_ColorArrowBuffer[bar]=1;
              }

         if(!Up[0] && !Dn[0])
           {
            Ind[Number].m_ColorLineBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
            Ind[Number].m_ColorArrowBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
           }
        }
      else
        {
         Ind[Number].m_ColorLineBuffer[bar]=Ind[Number].m_ColorLineBuffer[bar+1];
        }
     }
//--- завершение расчета одного индикатора    
   return(true);
  }
//+------------------------------------------------------------------+   
//| Stalin indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=3;
//--- инициализация переменных 
   Ind[0].m_TimeFrame=TimeFrame;
//--- инициализация буферов индикаторов
   for(int count=0; count<INDTOTAL; count++) if(!IndInit(count)) return(INIT_FAILED);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Stalin_Signal("+GetStringTimeframe(TimeFrame)+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
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
  }
//+------------------------------------------------------------------+ 
//| Stalin iteration function                                        | 
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
//--- проверка периодов графиков на корректность
   if(!TimeFramesCheck(INDICATOR_NAME,TimeFrame)) return(RESET);
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   for(int count=0; count<INDTOTAL; count++)
      if(BarsCalculated(Ind[count].m_Handle)<Bars(Symbol(),Ind[count].m_TimeFrame))
         return(prev_calculated);
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
