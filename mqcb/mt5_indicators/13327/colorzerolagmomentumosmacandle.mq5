//+------------------------------------------------------------------+
//|                               ColorZerolagMomentumOSMACandle.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "ColorZerolagMomentumOSMACandle"
//---- номер версии индикатора
#property version   "1.00"
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrGold,clrGray,clrTeal
//---- отображение метки индикатора
#property indicator_label1  "ColorZerolagMomentumOSMACandle Open;High;Low;Close"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint    smoothing1=5;
input uint    smoothing2=3;
//----
input double Factor1=0.16;
input uint    Momentum_period1=8;
//----
input double Factor2=0.26;
input uint    Momentum_period2=21;
//----
input double Factor3=0.16;
input uint    Momentum_period3=34;
//----
input double Factor4=0.1;
input int    Momentum_period4=55;
//----
input double Factor5=0.05;
input uint    Momentum_period5=89;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle[4];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- 
   uint PeriodBuffer[5];
//---- расчет стартового бара
   PeriodBuffer[0] = Momentum_period1;
   PeriodBuffer[1] = Momentum_period2;
   PeriodBuffer[2] = Momentum_period3;
   PeriodBuffer[3] = Momentum_period4;
   PeriodBuffer[4] = Momentum_period5;
//----
   min_rates_total=int(3*PeriodBuffer[ArrayMaximum(PeriodBuffer,0,WHOLE_ARRAY)])+2;
//---- получение хендла индикатора iColorZerolagMomentumOSMA
   Ind_Handle[0]=iCustom(NULL,0,"ColorZerolagMomentumOSMA",smoothing1,smoothing2,PRICE_OPEN,Factor1,Momentum_period1,Factor2,Momentum_period2,
                         Factor3,Momentum_period3,Factor4,Momentum_period4,Factor5,Momentum_period5);
   if(Ind_Handle[0]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iColorZerolagMomentumOSMA["+string(0)+"]!");
//----
   Ind_Handle[1]=iCustom(NULL,0,"ColorZerolagMomentumOSMA",smoothing1,smoothing2,PRICE_HIGH,Factor1,Momentum_period1,Factor2,Momentum_period2,
                         Factor3,Momentum_period3,Factor4,Momentum_period4,Factor5,Momentum_period5);
   if(Ind_Handle[1]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iColorZerolagMomentumOSMA["+string(1)+"]!");
//----
   Ind_Handle[2]=iCustom(NULL,0,"ColorZerolagMomentumOSMA",smoothing1,smoothing2,PRICE_LOW,Factor1,Momentum_period1,Factor2,Momentum_period2,
                         Factor3,Momentum_period3,Factor4,Momentum_period4,Factor5,Momentum_period5);
   if(Ind_Handle[2]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iColorZerolagMomentumOSMA["+string(2)+"]!");
//----
   Ind_Handle[3]=iCustom(NULL,0,"ColorZerolagMomentumOSMA",smoothing1,smoothing2,PRICE_CLOSE,Factor1,Momentum_period1,Factor2,Momentum_period2,
                         Factor3,Momentum_period3,Factor4,Momentum_period4,Factor5,Momentum_period5);
   if(Ind_Handle[3]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iColorZerolagMomentumOSMA["+string(3)+"]!");
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,4);
//---- имя для окон данных и метка для подокон 
   string short_name="ColorZerolagMomentumOSMACandl";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   if(BarsCalculated(Ind_Handle[0])<rates_total
      || BarsCalculated(Ind_Handle[1])<rates_total
      || BarsCalculated(Ind_Handle[2])<rates_total
      || BarsCalculated(Ind_Handle[3])<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar;
//---- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle[0],0,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[1],0,0,to_copy,ExtHighBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[2],0,0,to_copy,ExtLowBuffer)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle[3],0,0,to_copy,ExtCloseBuffer)<=0) return(RESET);
//---- основной цикл исправления и окрашивания свечей
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double Max=MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      double Min=MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]);
      //----
      ExtHighBuffer[bar]=MathMax(Max,ExtHighBuffer[bar]);
      ExtLowBuffer[bar]=MathMin(Min,ExtLowBuffer[bar]);
      //----
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=2.0;
      else if(ExtOpenBuffer[bar]>ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
