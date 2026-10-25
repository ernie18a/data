//+------------------------------------------------------------------+
//|                                       Support_and_Resistance.mq5 |
//|                                       Copyright © 2005,  Дмитрий |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "https://www.metaquotes.net/"
//---- номер версии индикатора
#property version   "1.12"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                     // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета уровней поддержки использован розовый цвет
#property indicator_color1  clrMagenta
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение метки поддержки
#property indicator_label1  "Support"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета уровней сопротивления использован зеленый цвет
#property indicator_color2  clrLime
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки сопротивления
#property indicator_label2 "Resistance"

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+

//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//---
int StartBars;
int FRA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных 
   StartBars=6;
//---- получение хендла индикатора iFractals
   FRA_Handle=iFractals(NULL,0);
   if(FRA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iFractals");
     return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Support");
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Resistance");
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="Support & Resistance";
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
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<StartBars) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double FRAUp[],FRALo[],upVel,loVel;

//---- расчеты необходимого количества копируемых данных
//---- и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      to_copy=rates_total; // расчетное количество всех баров
      limit=rates_total-StartBars-1; // стартовый номер для расчета всех баров
     }
   else
     {
      to_copy=rates_total-prev_calculated+3; // расчетное количество только новых баров
      limit=rates_total-prev_calculated+2; // стартовый номер для расчета новых баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(FRAUp,true);
   ArraySetAsSeries(FRALo,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(FRA_Handle,0,0,to_copy,FRAUp)<=0) return(RESET);
   if(CopyBuffer(FRA_Handle,1,0,to_copy,FRALo)<=0) return(RESET);

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0; bar--)
     {
       BuyBuffer[bar]=NULL;
       SellBuffer[bar]=NULL; 
       //----
       upVel=FRAUp[bar];
       loVel=FRALo[bar];
       //----
       if(upVel && upVel!=EMPTY_VALUE) BuyBuffer[bar]=high[bar]; else BuyBuffer[bar]=BuyBuffer[bar+1];
       if(loVel && loVel!=EMPTY_VALUE) SellBuffer[bar]=low[bar]; else SellBuffer[bar]=SellBuffer[bar+1];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

   