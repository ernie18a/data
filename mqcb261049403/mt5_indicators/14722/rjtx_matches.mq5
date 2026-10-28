//+------------------------------------------------------------------+
//|                                                 RJTX_Matches.mq5 |
//|                            Copyright 2015, Rafael Jimenez Tocino |
//|               http://www.tradingrafa.com/indicadores/rjt_matches |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright 2015, Rafael Jimenez Tocino"
//--- ссылка на сайт автора
#property link      "http://www.tradingrafa.com/indicadores/rjt_matches"
#property description "We recommend adjust the body and head size of the matches for better visualization."
//--- номер версии индикатора
#property version   "2.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 5
//--- использовано всего два графических построения
#property indicator_plots   5
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color1  clrBlue
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "match 1"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "match 2"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 3             |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован синий цвет
#property indicator_color3  clrBlue
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "match 3"
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован розовый цвет
#property indicator_color4  clrMagenta
//--- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//--- отображение медвежьей метки индикатора
#property indicator_label4  "RJTX_Matches Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован зеленый цвет
#property indicator_color5  clrLime
//--- толщина линии индикатора 5 равна 2
#property indicator_width5  2
//--- отображение бычьей метки индикатора
#property indicator_label5 "RJTX_Matches Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint iPeriod=10;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double LineBuffer0[];
double LineBuffer1[];
double LineBuffer2[];
double SellBuffer[];
double BuyBuffer[];
//---
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   min_rates_total=int(iPeriod);
//---- инициализация индикаторного буферов
   IndInit(0,LineBuffer0,0,min_rates_total,0);
   IndInit(1,LineBuffer1,0,min_rates_total,0);
   IndInit(2,LineBuffer2,0,min_rates_total,0);
   IndInit(3,SellBuffer,0,min_rates_total,0);
   IndInit(4,BuyBuffer,0,min_rates_total,0);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,174);
   PlotIndexSetInteger(4,PLOT_ARROW,174);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="RJTX_Matches";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Инициализация индикаторного буфера                               |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(Buffer,true);
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//--- объявление локальных переменных 
   int limit,bar;
   static uint p=0;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- the color of matchstick heads
      if(close[bar]>open[bar+iPeriod])
        {
         SellBuffer[bar]=0.0;
         BuyBuffer[bar]=close[bar];
        }
      else
        {
         SellBuffer[bar]=close[bar];
         BuyBuffer[bar]=0.0;
        }
      //---
      switch(p)
        {
         case 0:
           {
            LineBuffer0[bar]=open[bar+iPeriod-1];
            LineBuffer1[bar]=0.0;
            LineBuffer2[bar]=close[bar];
            break;
           }
         case 1:
           {
            LineBuffer0[bar]=close[bar];
            LineBuffer1[bar]=open[bar+iPeriod-1];
            LineBuffer2[bar]=0.0;
            break;
           }
         case 2:
           {
            LineBuffer0[bar]=0.0;
            LineBuffer1[bar]=close[bar];
            LineBuffer2[bar]=open[bar+iPeriod-1];
           }
        }
      if(bar) p++;
      if(p>2) p=0;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
