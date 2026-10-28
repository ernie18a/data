//+------------------------------------------------------------------+
//|                                                   ZigZag_RVI.mq5 |
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
//---- для расчёта и отрисовки индикатора использовано 4 буфера
#property indicator_buffers 4
//---- использовано всего 2 графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки осциллятора             |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  clrPaleGreen,clrPink
//---- отображение бычей метки индикатора
#property indicator_label1  "RVI Oscillator"
//+----------------------------------------------+ 
//|  Параметры отрисовки зигзага                 |
//+----------------------------------------------+
//---- в качестве индикатора использован ZIGZAG
#property indicator_type2   DRAW_ZIGZAG
//---- отображение метки индикатора
#property indicator_label2  "ZigZag_RVI"
//---- в качестве цвета линии индикатора использован Blue цвет
#property indicator_color2 clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//+----------------------------------------------+ 
//|  объявление перечислений                     |
//+----------------------------------------------+ 
enum ENUM_MODE //Тип константы
  {
   MODE_MAIN = 0,     //Зигзаг по основной линии индикатора
   MODE_SIGNAL        //Зигзаг по сигнальной линии индикатора
   };
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
//---- входные параметры осциллятора RVI
input ENUM_MODE Mode=MODE_MAIN;                            // Вариант построения
input uint RVI_period=13;                                  // период RVI  
//---- входные параметры зигзага
input uint ExtDepth=3;
input double ExtDeviation=0.1;
input uint ExtBackstep=3;
input double  HighLevel=+0.1;                                 // уровень перезакупа
input double  LowLevel=-0.1;                                  // уровень перепроданности
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double LowestBuffer[],HighestBuffer[],RVIBuffer[],SignBuffer[];

//---- Объявление переменных памяти для пересчёта индикатора только на непосчитанных барах
int LASTlowpos,LASThighpos,LASTColor;
double LASTlow0,LASTlow1,LASThigh0,LASThigh1;

//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total,RVI_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- получение хендла индикатора iRVI
   RVI_Handle=iRVI(NULL,0,RVI_period);
   if(RVI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRVI");
      return(INIT_FAILED);
     }
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(RVI_period);
   min_rates_total=int(min_rates_1+ExtDepth+ExtBackstep);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,RVIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,HighestBuffer,INDICATOR_DATA);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(RVIBuffer,true);
   ArraySetAsSeries(SignBuffer,true);
//---- установка позиции, с которой начинается отрисовка
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,3);
//---- имя для окон данных и лэйба для субъокон 
   IndicatorSetString(INDICATOR_SHORTNAME,"ZigZag_RVI");
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrDodgerBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrRed);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
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
   if(BarsCalculated(RVI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

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

//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RVI_Handle,0,0,to_copy,RVIBuffer)<=0) return(RESET);
   if(CopyBuffer(RVI_Handle,1,0,to_copy,SignBuffer)<=0) return(RESET);

//---- Первый большой цикл расчёта индикатора
   if(Mode==MODE_MAIN)for(bar=limit; bar>=0 && !IsStopped(); bar--)
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
      val=RVIBuffer[ArrayMinimum(RVIBuffer,bar,ExtDepth)];
      if(val==lastlow0) val=EMPTY_VALUE;
      else
        {
         lastlow0=val;
         if(RVIBuffer[bar]-val>ExtDeviation) val=EMPTY_VALUE;
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
      val=RVIBuffer[ArrayMaximum(RVIBuffer,bar,ExtDepth)];
      if(val==lasthigh0) val=EMPTY_VALUE;
      else
        {
         lasthigh0=val;
         if(val-RVIBuffer[bar]>ExtDeviation) val=EMPTY_VALUE;
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
     
//---- Первый большой цикл расчёта индикатора
   if(Mode==MODE_SIGNAL)for(bar=limit; bar>=0 && !IsStopped(); bar--)
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
      val=SignBuffer[ArrayMinimum(SignBuffer,bar,ExtDepth)];
      if(val==lastlow0) val=EMPTY_VALUE;
      else
        {
         lastlow0=val;
         if(SignBuffer[bar]-val>ExtDeviation) val=EMPTY_VALUE;
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
      val=SignBuffer[ArrayMaximum(SignBuffer,bar,ExtDepth)];
      if(val==lasthigh0) val=EMPTY_VALUE;
      else
        {
         lasthigh0=val;
         if(val-SignBuffer[bar]>ExtDeviation) val=EMPTY_VALUE;
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
