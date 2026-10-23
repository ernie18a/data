//+------------------------------------------------------------------+
//|                                           Iin_MA_Signal_NRTR.mq5 |
//|                                 Copyright © 2007, Iin Zulkarnain | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Iin Zulkarnainn"
#property link ""
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//---- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//---- отображение бычьей метки индикатора
#property indicator_label1  "Iin_MA_Signal Up"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета бычьей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Iin_MA_Signal Dn"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Magenta
#property indicator_color3  clrMagenta
//---- толщина линии индикатора 3 равна 4
#property indicator_width3  4
//---- отображение бычьей метки индикатора
#property indicator_label3  "Iin_MA_Signal Buy signal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован цвет Blue
#property indicator_color4  clrBlue
//---- толщина индикатора 4 равна 4
#property indicator_width4  4
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Iin_MA_Signal Sell signal"

//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint              FastMAPeriod=10;
input  ENUM_MA_METHOD   FastMAType=MODE_EMA;
input ENUM_APPLIED_PRICE FastMAPrice=PRICE_CLOSE;
input uint              SlowMAPeriod=22;
input  ENUM_MA_METHOD   SlowMAType=MODE_SMA;
input ENUM_APPLIED_PRICE SlowMAPrice=PRICE_CLOSE;
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
double UpBuffer[],DnBuffer[];
//---- объявление целых переменных начала отсчета данных
int min_rates_total,AtrPeriod;
//---- Объявление целых переменных для хендлов индикаторов
int FsMA_Handle,SlMA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных
   AtrPeriod=10;
   min_rates_total=int(MathMax(MathMax(FastMAPeriod,SlowMAPeriod)+3,AtrPeriod));

//---- получение хендла индикатора iMA
   FsMA_Handle=iMA(NULL,0,FastMAPeriod,0,FastMAType,FastMAPrice);
   if(FsMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMA
   SlMA_Handle=iMA(NULL,0,SlowMAPeriod,0,SlowMAType,SlowMAPrice);
   if(SlMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,175);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,175);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для подокон 
   string short_name="Iin_MA_Signal("+string(FastMAPeriod)+","+string(SlowMAPeriod)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
double GetRange(int index,const double &High[],const double &Low[],uint Len)
  {
//----
   double AvgRange=0.0;
   for(int count=int(index+Len-1); count>=index; count--) AvgRange+=MathAbs(High[count]-Low[count]);
//---- 
   return(AvgRange/Len);
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(FsMA_Handle)<rates_total
      || BarsCalculated(SlMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- объявления локальных переменных 
   int limit,bar,to_copy,trend;
   double FsMA[],SlMA[],fasterMAnow,slowerMAnow,fasterMAprevious,slowerMAprevious,newstop;
   static int trend_prev;

//---- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      trend_prev=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых 
   to_copy=limit+2;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(FsMA,true);
   ArraySetAsSeries(SlMA,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(FsMA_Handle,0,0,to_copy,FsMA)<=0) return(RESET);
   if(CopyBuffer(SlMA_Handle,0,0,to_copy,SlMA)<=0) return(RESET);

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SellBuffer[bar]=NULL;
      BuyBuffer[bar]=NULL;
      trend=trend_prev;

      fasterMAnow=FsMA[bar];
      fasterMAprevious=FsMA[bar+1];
      //----
      slowerMAnow=SlMA[bar];
      slowerMAprevious=SlMA[bar+1];

      if(trend<=0 && fasterMAnow>slowerMAnow && fasterMAprevious<slowerMAprevious)
        {
         BuyBuffer[bar]=UpBuffer[bar]=low[bar]-GetRange(bar,high,low,AtrPeriod)*0.5;
         trend=+1;
        }

      if(trend>=0 && fasterMAnow<slowerMAnow && fasterMAprevious>slowerMAprevious)
        {
         SellBuffer[bar]=DnBuffer[bar]=high[bar]+GetRange(bar,high,low,AtrPeriod)*0.5;
         trend=-1;
        }
        
      UpBuffer[bar]=NULL;
      DnBuffer[bar]=NULL;
      //----
      if(trend>0)
        {
         newstop=low[bar]-GetRange(bar,high,low,AtrPeriod)*0.5;
         if(trend_prev>0)
           {
            if(newstop>UpBuffer[bar+1]) UpBuffer[bar]=newstop;
            else UpBuffer[bar]=UpBuffer[bar+1];
           }
         else
           {
            UpBuffer[bar]=newstop;
           }
        }        
      //---- 
      if(trend<0)
        {
         newstop=high[bar]+GetRange(bar,high,low,AtrPeriod)*0.5;
         if(trend_prev<0)
           {
            if(newstop<DnBuffer[bar+1]) DnBuffer[bar]=newstop;
            else DnBuffer[bar]=DnBuffer[bar+1];
           }
         else
           {
            DnBuffer[bar]=newstop;
           }
        }
       //----
       if(bar) trend_prev=trend;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
