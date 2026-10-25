//+------------------------------------------------------------------+
//|                                                ZigZag_iForce.mq5 |
//|                      Copyright © 2016, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2016, MetaQuotes Software Corp."
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.00"
#property description "ZigZag" 
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- для расчёта и отрисовки индикатора использовано 3 буфера
#property indicator_buffers 3
//---- использовано всего 2 графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки осциллятора             |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован Green цвет
#property indicator_color1  clrGreen
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычей метки индикатора
#property indicator_label1  "iForce Oscillator"
//+----------------------------------------------+ 
//|  Параметры отрисовки зигзага                 |
//+----------------------------------------------+
//---- в качестве индикатора использован ZIGZAG
#property indicator_type2   DRAW_ZIGZAG
//---- отображение метки индикатора
#property indicator_label2  "ZigZag_iForce"
//---- в качестве цвета линии индикатора использован BlueViolet цвет
#property indicator_color2 clrBlueViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
//---- входные параметры осциллятора iForce
input uint iForce_period=13;                                  // период iForce  
input  ENUM_MA_METHOD MAType=MODE_EMA;
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK; // Объём
//---- входные параметры зигзага
input uint ExtDepth=3;
input uint ExtDeviation=3;
input uint ExtBackstep=3;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double LowestBuffer[],HighestBuffer[],iForceBuffer[];

//---- Объявление переменных памяти для пересчёта индикатора только на непосчитанных барах
int LASTlowpos,LASThighpos,LASTColor;
double LASTlow0,LASTlow1,LASThigh0,LASThigh1;
double dExtDeviation;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total,iForce_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- получение хендла индикатора iForce
   iForce_Handle=iForce(NULL,0,iForce_period,MAType,VolumeType);
   if(iForce_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iForce");
      return(INIT_FAILED);
     }
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(iForce_period);
   min_rates_total=int(min_rates_1+ExtDepth+ExtBackstep);
   dExtDeviation=ExtDeviation*_Point;

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,iForceBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,HighestBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(iForceBuffer,true);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   IndicatorSetString(INDICATOR_SHORTNAME,"ZigZag_iForce");
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
   if(BarsCalculated(iForce_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,climit,bar,back,lasthighpos,lastlowpos;
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
      climit=limit+min_rates_total; // стартовый номер для раскраски индикатора

      //---- восстанавливаем значения переменных
      lastlow0=LASTlow0;
      lasthigh0=LASThigh0;

      lastlow1=LASTlow1;
      lasthigh1=LASThigh1;

      lastlowpos=LASTlowpos+limit;
      lasthighpos=LASThighpos+limit;
     }
    to_copy=limit+1;

//--- копируем вновь появившиеся данные в массив
   if(CopyBuffer(iForce_Handle,0,0,to_copy,iForceBuffer)<=0) return(RESET);

//---- Первый большой цикл расчёта индикатора
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
      val=iForceBuffer[ArrayMinimum(iForceBuffer,bar,ExtDepth)];
      if(val==lastlow0) val=EMPTY_VALUE;
      else
        {
         lastlow0=val;
         if(iForceBuffer[bar]-val>dExtDeviation) val=EMPTY_VALUE;
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
      val=iForceBuffer[ArrayMaximum(iForceBuffer,bar,ExtDepth)];
      if(val==lasthigh0) val=EMPTY_VALUE;
      else
        {
         lasthigh0=val;
         if(val-iForceBuffer[bar]>dExtDeviation) val=EMPTY_VALUE;
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

//---- Второй большой цикл расчёта индикатора
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
