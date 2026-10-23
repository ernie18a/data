//+------------------------------------------------------------------+
//|                                                ADXCrossingMA.mq5 |
//|                                           Copyright © 2012, Amir |
//|                                http://www.forex-instruments.info |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2012, Amir"
//---- ссылка на сайт автора
#property link      "http://www.forex-instruments.info"
//---- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьего индикатора использован оранжевый цвет
#property indicator_color1  clrOrange
//--- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//--- отображение бычей метки индикатора
#property indicator_label1  "ADXCrossingMA Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьего индикатора использован зеленый цвет
#property indicator_color2  clrLime
//--- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//--- отображение медвежьей метки индикатора
#property indicator_label2 "ADXCrossingMA Buy"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int    period = 14;
input double alpha1 = 0.25;
input double alpha2 = 0.33;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//---
int ADX_Handle,ATR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   int ATR_Period=15;
   min_rates_total=int(MathMax(period,ATR_Period))+1;

//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- получение хендла индикатора ADX
   ADX_Handle=iADX(NULL,0,period);
   if(ADX_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ADX");
      return(INIT_FAILED);
     }

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,108);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="ADXCrossingMA";
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
   if(BarsCalculated(ADX_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double ATR[],DIP[],DIM[],DiPlus,DiMinus,SDiPlus,SDiMinus,diff_DI,diff_DI_;
   static double DiPlus_,DiMinus_,SDiPlus_,SDiMinus_;

//--- расчеты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      SDiPlus_=0.0;
      SDiMinus_=0.0;
      DiPlus_=0.0;
      DiMinus_=0.0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy++;
   if(CopyBuffer(ADX_Handle,1,0,to_copy,DIP)<=0) return(RESET);
   if(CopyBuffer(ADX_Handle,2,0,to_copy,DIM)<=0) return(RESET);

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(DIP,true);
   ArraySetAsSeries(DIM,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=NULL;
      SellBuffer[bar]=NULL;
      //---
      DiPlus=2*DIP[bar]+(alpha1-2)*DIP[bar+1]+(1-alpha1)*DiPlus_;
      DiMinus=2*DIM[bar]+(alpha1-2)*DIM[bar+1]+(1-alpha1)*DiMinus_;
      //---
      SDiPlus=alpha2*DiPlus+(1-alpha2)*SDiPlus_;
      SDiMinus=alpha2*DiMinus+(1-alpha2)*SDiMinus_;
      //---
      diff_DI=SDiPlus-SDiMinus;
      diff_DI_=SDiPlus_-SDiMinus_;
      //---
      if(diff_DI_<=0 && diff_DI>0) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(diff_DI_>=0 && diff_DI<0) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
      
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(bar)
        {
         DiPlus_=DiPlus;
         DiMinus_=DiMinus;
         SDiPlus_=SDiPlus;
         SDiMinus_=SDiMinus;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
