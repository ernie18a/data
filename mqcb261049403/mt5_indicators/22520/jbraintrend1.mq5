//+------------------------------------------------------------------+
//|                                                 JBrainTrend1.mq5 |
//|                               Copyright © 2005, BrainTrading Inc |
//|                                      http://www.braintrading.com |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, BrainTrading Inc."
//---- ссылка на сайт автора
#property link      "http://www.braintrading.com/"
//---- номер версии индикатора
#property version   "1.01"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
//---- в качестве цветов свечей использованы
#property indicator_color1 clrNONE,clrDeepPink,clrDodgerBlue
//---- отображение метки индикатора
#property indicator_label1  "Flat; UpTend; DownTrend;"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint ATR_Period=7;                            //период ATR 
input uint STO_Period=9;                            //период стохастика
input ENUM_MA_METHOD MA_Method = MODE_SMA;          //метод усреднения
input ENUM_STO_PRICE STO_Price = STO_LOWHIGH;       //метод расчёта цен 
input int Length_=7;                                //глубина JMA сглаживания                   
input int Phase_=100;                               //параметр JMA сглаживания,
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//---
double d;
int p,x1,x2,P_,min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int ATR_Handle,STO_Handle,JO_Handle,JH_Handle,JL_Handle,JC_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных 
   d=2.3;
   x1 = 53;
   x2 = 47;
   min_rates_total=int(MathMax(MathMax(ATR_Period,STO_Period),30)+2);
   
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора ATR");
   
//---- получение хендла индикатора Stochastic
   STO_Handle=iStochastic(NULL,0,STO_Period,STO_Period,1,MA_Method,STO_Price);
   if(STO_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора Stochastic");

//---- получение хендла индикатора JMA
   JO_Handle=iCustom(NULL,0,"JMA",Length_,Phase_,2,0,0);
   if(JO_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора JMA");
      
//---- получение хендла индикатора JMA
   JL_Handle=iCustom(NULL,0,"JMA",Length_,Phase_,4,0,0);
   if(JL_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора JMA");
   
//---- получение хендла индикатора JMA
   JC_Handle=iCustom(NULL,0,"JMA",Length_,Phase_,1,0,0);
   if(JC_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора JMA");
   
//---- получение хендла индикатора JMA
   JH_Handle=iCustom(NULL,0,"JMA",Length_,Phase_,3,0,0);
   if(JH_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора JMA");
   
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
   
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
   
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="JBrainTrend1";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(STO_Handle)<rates_total
      || BarsCalculated(JO_Handle)<rates_total
      || BarsCalculated(JH_Handle)<rates_total
      || BarsCalculated(JL_Handle)<rates_total
      || BarsCalculated(JC_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double value2[],Range[],JO[],JH[],JL[],JC[],range,val1,val2,val3;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
        limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров    
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(RESET);
   if(CopyBuffer(STO_Handle,0,0,to_copy,value2)<=0) return(RESET);
   if(CopyBuffer(JO_Handle,0,0,to_copy,JO)<=0) return(RESET);
   if(CopyBuffer(JH_Handle,0,0,to_copy,JH)<=0) return(RESET);
   if(CopyBuffer(JL_Handle,0,0,to_copy,JL)<=0) return(RESET);
   if(CopyBuffer(JC_Handle,0,0,to_copy+2,JC)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Range,true);
   ArraySetAsSeries(value2,true);
   ArraySetAsSeries(JO,true);
   ArraySetAsSeries(JH,true);
   ArraySetAsSeries(JL,true);
   ArraySetAsSeries(JC,true);

//---- восстанавливаем значения переменных
   p=P_;

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0; bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
         P_=p;

      range= Range[bar]/d;
      val1 = 0.0;
      val2 = 0.0;
      ExtOpenBuffer[bar]=0.0;
      ExtHighBuffer[bar]=0.0;
      ExtLowBuffer[bar]=0.0;
      ExtCloseBuffer[bar]=0.0;
      ExtColorsBuffer[bar]=0;

      val3=MathAbs(NormalizeDouble(JC[bar],_Digits)-NormalizeDouble(JC[bar+2],_Digits));
      
      if(value2[bar] < x2 && val3 > range) p = 1;
      if(value2[bar] > x1 && val3 > range) p = 2;

      if(val3<=range) continue;

      if(value2[bar]<x2 && (p==1 || p==0))
        {
         ExtOpenBuffer[bar]=JO[bar];
         ExtHighBuffer[bar]=JH[bar];
         ExtLowBuffer[bar]=JL[bar];
         ExtCloseBuffer[bar]=JC[bar];
         ExtColorsBuffer[bar]=1;
        }
      if(value2[bar]>x1 && (p==2 || p==0))
        {
         ExtOpenBuffer[bar]=JO[bar];
         ExtHighBuffer[bar]=JH[bar];
         ExtLowBuffer[bar]=JL[bar];
         ExtCloseBuffer[bar]=JC[bar];
         ExtColorsBuffer[bar]=2;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
