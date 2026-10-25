//+------------------------------------------------------------------+ 
//|                                                      MFI_HTF.mq5 | 
//|                               Copyright © 2014, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2014, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- номер версии индикатора
#property version   "1.60"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//--- отрисовка индикатора в виде четырёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- в качестве цветов четырёхцветной гистограммы использованы
#property indicator_color1 clrRed,clrPurple,clrGray,clrTeal,clrLime
//--- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//--- толщина линии индикатора равна 5
#property indicator_width1 5
//--- отображение метки индикатора
#property indicator_label1 "MFI HTF"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 +20.0
#property indicator_level2   0.0
#property indicator_level3 -20.0
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;         // Период графика
input int Length=8;                                // Период индикатора 
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Объём 
input bool ReDraw=true;                            // Повтор отображения инфомации на пустых барах
//+----------------------------------------------+
//--- объявление переменной для хранения результата инициализации индикатора
bool Init;
//--- объявление целочисленных переменных начала отсчёта данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int MFI_Handle;
//--- объявление динамических массивов, которые будут в 
//--- в дальнейшем использованы в качестве индикаторных буферов
double MFIBuffer[],ColorMFIBuffer[];
//+------------------------------------------------------------------+
//|  Получение стрингового таймфрейма                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+    
//| MFI indicator initialization function                            | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=3;
   Init=true;
//--- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора iMFI не может быть меньше периода текущего графика");
      Init=false;
      return;
     }
//--- получение хендла индикатора  iMFI
   MFI_Handle=iMFI(Symbol(),TimeFrame,Length,VolumeType);
   if(MFI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора  iMFI");
      Init=false;
      return;
     }
//--- превращение динамического массива MFIBuffer в индикаторный буфер
   SetIndexBuffer(0,MFIBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL," MFI HTF");
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(MFIBuffer,true);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorMFIBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorMFIBuffer,true);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname," MFI HTF(",GetStringTimeframe(TimeFrame),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| MFI iteration function                                           | 
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
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(MFI_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- объявление целочисленных переменных
   int limit,bar;
//--- объявление переменных с плавающей точкой  
   double MFI[2];
   datetime MFITime[1];
   static uint LastCountBar;
//--- расчёты необходимого количества копируемых данных и
//--- и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // стартовый номер для расчёта новых баров 
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//--- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- обнулим содержимое индикаторных буферов до расчёта
      MFIBuffer[bar]=EMPTY_VALUE;
      ColorMFIBuffer[bar]=0;
      //--- копируем вновь появившиеся данные в массив
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,MFITime)<=0) return(RESET);

      if(time[bar]>=MFITime[0] && time[bar+1]<MFITime[0])
        {
         LastCountBar=bar;
         //--- копируем вновь появившиеся данные в массивы
         if(CopyBuffer(MFI_Handle,0,time[bar],2,MFI)<=0) return(RESET);
         //--- загрузка полученных значений в индикаторные буферы
         MFIBuffer[bar]=MFI[1]-50.0;
         //---
         if(MFIBuffer[bar]>0)
           {
            if(MFI[1]>MFI[0]) ColorMFIBuffer[bar]=4;
            if(MFI[1]<MFI[0]) ColorMFIBuffer[bar]=3;
           }
         //---
         if(MFIBuffer[bar]<0)
           {
            if(MFI[1]<MFI[0]) ColorMFIBuffer[bar]=0;
            if(MFI[1]>MFI[0]) ColorMFIBuffer[bar]=1;
           }
        }
      //---
      if(ReDraw)
        {
         if(MFIBuffer[bar+1]!=EMPTY_VALUE && MFIBuffer[bar]==EMPTY_VALUE)
           {
            MFIBuffer[bar]=MFIBuffer[bar+1];
            ColorMFIBuffer[bar]=ColorMFIBuffer[bar+1];
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
