//+------------------------------------------------------------------+
//|                                                  LeadingSign.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2015, Nikolay Kositsin"
//--- ссылка на сайт автора
#property link      "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0   // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "LeadingSign Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color2  clrLime
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "LeadingSign Buy"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double Alpha1 = 0.25;    // 1 коэффициент индикатора
input double Alpha2 = 0.33;    // 2 коэффициент индикатора 
//+----------------------------------------------+
//--- объявление динамических массивов, которые будут в 
//---  в дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Получение среднего от ценовых таймсерий                          |
//+------------------------------------------------------------------+   
double Get_Price(const double  &High[],const double  &Low[],int bar)
  {
//---
   return((High[bar]+Low[bar])/2);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,2));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,171);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,171);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и лэйба для субъокон 
   string short_name="LeadingSign";
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar,maxbar;
   double Lead,NetLead,EMA,ATR[];
//--- объявления статических переменных для хранения действительных значений коэфициентов
   static double Lead_,NetLead_,EMA_;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
   maxbar=rates_total-min_rates_total;
//--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- восстанавливаем значения переменных
   Lead=Lead_;
   NetLead=NetLead_;
   EMA=EMA_;
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==rates_total-1)
         Lead_=Lead;
      //---
      if(bar<maxbar)
        {
         Lead=2.0*Get_Price(high,low,bar)+(Alpha1-2.0)*Get_Price(high,low,bar+1)+(1.0-Alpha1)*Lead_;
         NetLead=Alpha2*Lead+(1-Alpha2)*NetLead_;
         EMA=0.5*Get_Price(high,low,bar)+0.5*EMA_;
        }
      else
        {
         Lead=Get_Price(high,low,bar);
         NetLead=Lead;
         EMA=Lead;
         if(bar)
           {
            NetLead_=NetLead;
            Lead_=Lead;
            EMA_=EMA;
           }
         continue;
        }
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(EMA_>Lead_ && EMA<Lead) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(EMA_<Lead_ && EMA>Lead) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
      //---
      if(bar)
        {
         NetLead_=NetLead;
         Lead_=Lead;
         EMA_=EMA;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
