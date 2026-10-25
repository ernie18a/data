//+------------------------------------------------------------------+
//|                                            ZigZag_XMACandles.mq5 |
//|                      Copyright © 2016, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2016, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.00"
#property description "ZigZag_XMACandles" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- для расчёта и отрисовки индикатора использовано 7 буферов
#property indicator_buffers 7
//---- использовано всего 2 графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки осциллятора             |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrMediumOrchid,clrSlateBlue,clrGreen
//---- отображение метки индикатора
#property indicator_label1  "XMACandles Open;XMACandles High;XMACandles Low;XMACandles Close"
//+----------------------------------------------+ 
//|  Параметры отрисовки зигзага                 |
//+----------------------------------------------+
//---- в качестве индикатора использован ZIGZAG
#property indicator_type2   DRAW_ZIGZAG
//---- отображение метки индикатора
#property indicator_label2  "ZigZag_XMACandles"
//---- в качестве цвета линии индикатора использован Purple цвет
#property indicator_color2 clrPurple
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh>
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
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
//---- входные параметры осциллятора
input Smooth_Method MA_Method1=MODE_T3;     // Метод усреднения первого сглаживания 
input int Length1=12;                       // Глубина первого сглаживания                    
input int Phase1=15;                        // Параметр первого сглаживания, 
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
//---- входные параметры зигзага
input uint ExtDepth=3;
input double ExtDeviation=3.0;
input uint ExtBackstep=10;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double LowestBuffer[],HighestBuffer[];
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- Объявление переменных памяти для пересчёта индикатора только на непосчитанных барах
int LASTlowpos,LASThighpos,LASTColor;
double LASTlow0,LASTlow1,LASThigh0,LASThigh1;

//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- получение хендлов индикатора XMACandles
   Ind_Handle=iCustom(NULL,0,"XMACandles",MA_Method1,Length1,Phase1,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора XMACandles!");
      return(INIT_FAILED);
     }
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(GetStartBars(MA_Method1, Length1, Phase1));
   min_rates_total=min_rates_1+int(ExtDepth+ExtBackstep);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
   
   SetIndexBuffer(5,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,HighestBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   IndicatorSetString(INDICATOR_SHORTNAME,"ZigZag_MACD");
//---   
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
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar,back,lasthighpos,lastlowpos;
   double curlow,curhigh,lasthigh0=EMPTY_VALUE,lastlow0=EMPTY_VALUE,lasthigh1,lastlow1,val,res;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      lastlow1=-1;
      lasthigh1=-1;
      lastlowpos=-1;
      lasthighpos=-1;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      //---- восстанавливаем значения переменных
      lastlow0=LASTlow0;
      lasthigh0=LASThigh0;

      lastlow1=LASTlow1;
      lasthigh1=LASThigh1;

      lastlowpos=LASTlowpos+limit;
      lasthighpos=LASThighpos+limit;
     }
    to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,0,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,1,0,to_copy,ExtHighBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,2,0,to_copy,ExtLowBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,3,0,to_copy,ExtCloseBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,4,0,to_copy,ExtColorBuffer)<=0) return(RESET);

//---- Первый большой цикл расчёта зигзага
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         LASTlow0=lastlow0;
         LASThigh0=lasthigh0;
        }
      LowestBuffer[bar]=EMPTY_VALUE;
      HighestBuffer[bar]=EMPTY_VALUE;
      //--- low
      val=ExtLowBuffer[ArrayMinimum(ExtLowBuffer,bar,ExtDepth)];
      if(val==lastlow0) val=EMPTY_VALUE;
      else
        {
         lastlow0=val;
         if(ExtLowBuffer[bar]-val>ExtDeviation*_Point) val=EMPTY_VALUE;
         else
           {
            for(back=1; back<=int(ExtBackstep); back++)
              {
               res=LowestBuffer[bar+back];
               if(res!=EMPTY_VALUE && res>val) LowestBuffer[bar+back]=EMPTY_VALUE;
              }
           }
        }
      LowestBuffer[bar]=val;

      //--- high
      val=ExtHighBuffer[ArrayMaximum(ExtHighBuffer,bar,ExtDepth)];
      if(val==lasthigh0) val=EMPTY_VALUE;
      else
        {
         lasthigh0=val;
         if(val-ExtHighBuffer[bar]>ExtDeviation*_Point) val=EMPTY_VALUE;
         else
           {
            for(back=1; back<=int(ExtBackstep); back++)
              {
               res=HighestBuffer[bar+back];
               if(res!=EMPTY_VALUE && res<val) HighestBuffer[bar+back]=EMPTY_VALUE;
              }
           }
        }
      HighestBuffer[bar]=val;
     }

//---- Второй большой цикл расчёта зигзага
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         LASTlow1=lastlow1;
         LASThigh1=lasthigh1;
         //----
         LASTlowpos=lastlowpos;
         LASThighpos=lasthighpos;
        }

      curlow=LowestBuffer[bar];
      curhigh=HighestBuffer[bar];
      //---
      if(curlow==EMPTY_VALUE && curhigh==EMPTY_VALUE) continue;
      //---
      if(curhigh!=EMPTY_VALUE)
        {
         if(lasthigh1>0)
           {
            if(lasthigh1<curhigh) HighestBuffer[lasthighpos]=EMPTY_VALUE;
            else HighestBuffer[bar]=EMPTY_VALUE;
           }
         //---
         if(lasthigh1<curhigh || lasthigh1<0 || curhigh==EMPTY_VALUE || lasthigh1==EMPTY_VALUE)
           {
            lasthigh1=curhigh;
            lasthighpos=bar;
           }
         lastlow1=-1;
        }
      //----
      if(curlow!=EMPTY_VALUE)
        {
         if(lastlow1>0)
           {
            if(lastlow1>curlow) LowestBuffer[lastlowpos]=EMPTY_VALUE;
            else LowestBuffer[bar]=EMPTY_VALUE;
           }
         //---
         if(curlow<lastlow1 || lastlow1<0 || curlow==EMPTY_VALUE || lastlow1==EMPTY_VALUE)
           {
            lastlow1=curlow;
            lastlowpos=bar;
           }
         lasthigh1=-1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
