//+------------------------------------------------------------------+
//|                                                      TASSKlT.mq5 |
//|                                         Copyright © 2009, KurlFX |
//|                                                                  |
//+------------------------------------------------------------------+ 
#property description "Простой визуализатор тренда"
//--- авторство индикатора
#property copyright "Copyright © 2009, KurlFX"
//--- ссылка на сайт автора
#property link      ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//--- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки гистограммы             |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//--- в качестве цвета медвежьей линии индикатора использованы розовый и зеленый цвета
#property indicator_color1  clrMagenta,clrLimeGreen
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "TASSKlT Dn"

//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color2  clrMagenta
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение бычей метки индикатора
#property indicator_label2  "TASSKlT Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color3  clrLime
//--- толщина линии индикатора 3 равна 4
#property indicator_width3  4
//--- отображение медвежьей метки индикатора
#property indicator_label3 "TASSKlT Buy"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4 DRAW_LINE
//---- в качестве цвета линии индикатора использован оранжевый цвет
#property indicator_color4 clrDarkOrange
//---- линия индикатора - сплошная
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4  2
//---- отображение метки индикатора
#property indicator_label4  "TASSKlT End"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET   0    // Константа для возврата терминалу команды на пересчёт индикатора
#define Alvl   35.0
#define Alvl2  30.0
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int ADXperiod1 = 10;
input int ADXperiod2 = 14;
input int ADXperiod3 = 20;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double To[];
double Tc[];
double ColorT[];
double Up[];
double Dn[];
double Ex[];
//---
int MxP,MnP,MdP;
int ADX1_Handle,ADX2_Handle,ADX3_Handle,ATR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   MxP=MathMax(MathMax(ADXperiod1,ADXperiod2),ADXperiod3);
   MnP=MathMin(MathMin(ADXperiod1,ADXperiod2),ADXperiod3);
   if(MxP==ADXperiod1) MdP=MathMax(ADXperiod2,ADXperiod3);
   else if(MxP==ADXperiod2) MdP=MathMax(ADXperiod1,ADXperiod3);
   else MdP=MathMax(ADXperiod2,ADXperiod1);
   int ATR_Period=15;
   min_rates_total=int(MathMax(MxP,ATR_Period))+2;
//--- получение хендла индикатора ADX1
   ADX1_Handle=iADX(NULL,0,MnP);
   if(ADX1_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iADX1");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора ADX2
   ADX2_Handle=iADX(NULL,0,MdP);
   if(ADX2_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iADX2");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора ADX3
   ADX3_Handle=iADX(NULL,0,MxP);
   if(ADX3_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iADX3");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,To,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(To,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Tc,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Tc,true);
//--- превращение динамического массива в цветовой индексный буфер
   SetIndexBuffer(2,ColorT,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorT,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,Dn,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,226);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Dn,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,Up,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,225);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Up,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,Ex,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ex,true);

//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="TASSKlT";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(ADX1_Handle)<rates_total
      || BarsCalculated(ADX2_Handle)<rates_total
      || BarsCalculated(ADX3_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double ADX1[],PADX1[],MADX1[],ADX2[],ADX3[],ATR[];

//--- расчеты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy++;
   if(CopyBuffer(ADX1_Handle,MAIN_LINE,0,to_copy,ADX1)<=0) return(RESET);
   if(CopyBuffer(ADX2_Handle,MAIN_LINE,0,to_copy,ADX2)<=0) return(RESET);
   if(CopyBuffer(ADX3_Handle,MAIN_LINE,0,to_copy,ADX3)<=0) return(RESET);
   if(CopyBuffer(ADX1_Handle,PLUSDI_LINE,0,to_copy,PADX1)<=0) return(RESET);
   if(CopyBuffer(ADX1_Handle,MINUSDI_LINE,0,to_copy,MADX1)<=0) return(RESET);

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ADX1,true);
   ArraySetAsSeries(PADX1,true);
   ArraySetAsSeries(MADX1,true);
   ArraySetAsSeries(ADX2,true);
   ArraySetAsSeries(ADX3,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bool f1=false,f2=false,f3=false;
      To[bar]=EMPTY_VALUE;
      Tc[bar]=EMPTY_VALUE;
      Up[bar]=EMPTY_VALUE;
      Dn[bar]=EMPTY_VALUE;
      Ex[bar]=EMPTY_VALUE;
      if(ADX1[bar+1]<ADX1[bar])f1=true;
      if(ADX2[bar+1]<ADX2[bar])f2=true;
      if(ADX3[bar+1]<ADX3[bar])f3=true;
      if(f1 && f2 && f3 && ADX1[bar]>Alvl && ADX2[bar]>Alvl2)
        {
         double di=PADX1[bar]-MADX1[bar];
         double hi=MathMax(open[bar],close[bar]);
         double lo=MathMin(open[bar],close[bar]);
         double op=open[bar];
         if(di>0)
           {
            To[bar]=lo;
            Tc[bar]=hi;
            ColorT[bar]=1;
            if(To[bar+1]==EMPTY_VALUE) Up[bar]=low[bar]-ATR[bar]*3/8;
           }
         else
           {
            To[bar]=hi;
            Tc[bar]=lo;
            ColorT[bar]=0;
            if(To[bar+1]==EMPTY_VALUE) Dn[bar]=high[bar]+ATR[bar]*3/8;
           }
        }
      else
        {
         if(To[bar+1]!=EMPTY_VALUE)Ex[bar]=close[bar+1];
         else Ex[bar]=Ex[bar+1];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
