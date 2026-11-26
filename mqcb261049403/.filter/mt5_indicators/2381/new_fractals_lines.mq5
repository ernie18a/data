//+------------------------------------------------------------------+
//|                                           New_Fractals_Lines.mq4 |
//|                                       Copyright © 2007, olyakish |
//|                                           plutonia-dmb#yandex.ru |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2007, olyakish"
//--- ссылка на сайт автора
#property link      "plutonia-dmb#yandex.ru"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки верхнего индикатора      |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета индикатора использован Crimson цвет
#property indicator_color1  clrCrimson
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "Down Fractal"
//+----------------------------------------------+
//| Параметры отрисовки нижнего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета индикатора использован LimeGreen цвет
#property indicator_color2  clrLimeGreen
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Up Fractal"
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // Объём 
input int  UpLabel=164;                            // Метка верхнего фрактала
input int  DnLabel=164;                            // Метка нижнего фрактала
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double DnBuffer[];
double UpBuffer[];
//---
int min_rates_total;
int FRA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   min_rates_total=3;
//--- получение хендла индикатора iFractals
   FRA_Handle=iFractals(Symbol(),PERIOD_CURRENT);
   if(FRA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iFractals");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DnBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,UpLabel);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,DnLabel);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="New_Fractals_Lines";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- завершение инициализации
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
//--- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit;
   double AllHLUp,AllMFIUp,AllHLDown,AllMFIDown,UpFractal[],DnFractal[];
   long AllVolDown,AllVolUp;
   bool Up,Down;
   static int OldFractal;
//--- расчёты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      OldFractal=0;
     }
   else
     {
      limit=rates_total-prev_calculated+min_rates_total; // стартовый номер для расчёта новых баров
     }
   to_copy=limit+1+min_rates_total;
//--- копируем вновь появившиеся данные в массивы UpFractal и DnFractal
   if(CopyBuffer(FRA_Handle,0,0,to_copy,UpFractal)<=0) return(RESET);
   if(CopyBuffer(FRA_Handle,1,0,to_copy,DnFractal)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(UpFractal,true);
   ArraySetAsSeries(DnFractal,true);
   if(VolumeType==VOLUME_TICK) ArraySetAsSeries(tick_volume,true);
   else ArraySetAsSeries(volume,true);
//--- основной цикл расчёта индикатора
   for(int bar=2; bar<=limit && !IsStopped(); bar++)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
      //---
      if(UpFractal[bar] && UpFractal[bar]!=EMPTY_VALUE)
        {
         Up=true;
         Down=false;
        }
      if(DnFractal[bar] && DnFractal[bar]!=EMPTY_VALUE)
        {
         Up=false;
         Down=true;
        }
      //--- два фрактала сразу - игнорируем
      if(UpFractal[bar] && UpFractal[bar]!=EMPTY_VALUE && DnFractal[bar] && DnFractal[bar]!=EMPTY_VALUE)
        {
         Up=false;
         Down=false;
        }
      //---
      if(!Up && Down)
        {
         AllHLDown=high[bar+2]-low[bar+2]+high[bar+1]-low[bar+1]+high[bar]-low[bar]+high[bar-1]-low[bar-1]+high[bar-2]-low[bar-2];
         AllVolDown=VolSum(VolumeType,tick_volume,volume,bar);
         AllMFIDown=AllHLDown/AllVolDown;
         if(OldFractal==1 && AllMFIDown<AllMFIUp && AllVolDown>AllVolUp) DnBuffer[bar]=DnFractal[bar];
         OldFractal=0;
        }
      //---
      if(Up && !Down)
        {
         AllHLUp=high[bar+2]-low[bar+2]+high[bar+1]-low[bar+1]+high[bar]-low[bar]+high[bar-1]-low[bar-1]+high[bar-2]-low[bar-2];
         AllVolUp=VolSum(VolumeType,tick_volume,volume,bar);
         AllMFIUp=AllHLUp/AllVolUp;
         if(OldFractal==0 && AllMFIUp<AllMFIDown && AllVolUp>AllVolDown) UpBuffer[bar]=UpFractal[bar];
         OldFractal=1;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| VolSum()                                                         |
//+------------------------------------------------------------------+    
long VolSum(ENUM_APPLIED_VOLUME VolType,
            const long &Tick_Volume[],
            const long &Volume[],
            int index)
  {
//---
   long Vol;
   if(VolType==VOLUME_REAL) Vol=Volume[index+2]+Volume[index+1]+Volume[index]+Volume[index-1]+Volume[index-2];
   else Vol=Tick_Volume[index+2]+Tick_Volume[index+1]+Tick_Volume[index]+Tick_Volume[index-1]+Tick_Volume[index-2];
//---
   return(Vol);
  }
//+------------------------------------------------------------------+
