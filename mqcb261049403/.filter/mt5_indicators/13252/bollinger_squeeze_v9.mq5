//+------------------------------------------------------------------+
//|                                         Bollinger_Squeeze_v9.mq5 |
//|                                      Original code by Nick Bilak |
//|                                         Modifications by Akuma99 |
//|                                                                  |
//|            For help on this indicator, tutorials and information | 
//|            visit http://www.beginnertrader.com                   |
//|                                                                  |
//|   Trigger types: 1-stochastic, 2-cci, 3-rsi, 4-macd, 5-momentum  |
//|                                                                  |
//|                                        Copyright © 2006  Akuma99 |
//|                                    http://www.beginnertrader.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Akuma99"
#property link      "http://www.beginnertrader.com "
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырехцветной гистограммы использованы
#property indicator_color1 clrRed,clrOrchid,clrGray,clrDodgerBlue,clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 4
#property indicator_width1 4
//---- отображение метки индикатора
#property indicator_label1 "Bollinger_Squeeze_v9 HISTOGRAM"
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2 DRAW_LINE
//---- в качестве цвета линии использован
#property indicator_color2 clrBlueViolet
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 1
#property indicator_width2 1
//---- отображение метки индикатора
#property indicator_label2 "Bollinger_Squeeze_v9 LINE"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Mode //тип константы
  {
   ENAME_STOCHASTIC = 1,     //stochastic
   ENAME_CCI,                //cci
   ENAME_RSI,                //rsi
   ENAME_MACD,               //macd
   ENAME_MOMENTUM            //momentum
  };
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input Mode triggerType=ENAME_MACD;
input uint stochPeriod_trigger1=14;
input uint cciPeriod_trigger2=50;
input uint rsiPeriod_trigger3=10;
input uint macd_fastEMA_trigger4=5;
input uint macd_slowEMA_trigger4=13;
input uint macd_macdEMA_trigger4=1;
input uint momentumPeriod_trigger5=14;
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[],LineBuffer[];
//---- объявление переменных
int       bolPrd=20;
double    bolDev=2.0;
int       keltPrd=20;
double    keltFactor=1.5;
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle,ATR_Handle,Std_Handle;
//+------------------------------------------------------------------+    
//| Bollinger_Squeeze_v9 indicator initialization function           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   switch(triggerType)
     {
      case 1: min_rates_total=int(stochPeriod_trigger1+3+3); break;
      case 2: min_rates_total=int(cciPeriod_trigger2); break;
      case 3: min_rates_total=int(rsiPeriod_trigger3); break;
      case 4: min_rates_total=int(5+13+1); break;
      case 5: min_rates_total=int(momentumPeriod_trigger5); break;
     }
   min_rates_total=MathMax(MathMax(min_rates_total,bolPrd),keltPrd);
//---- получение хендла индикатора
   switch(triggerType)
     {
      case 1: Ind_Handle=iStochastic(NULL,0,stochPeriod_trigger1,3,3,MODE_SMA,STO_CLOSECLOSE); break;
      case 2: Ind_Handle=iCCI(NULL,0,cciPeriod_trigger2,PRICE_CLOSE); break;
      case 3: Ind_Handle=iRSI(NULL,0,rsiPeriod_trigger3,PRICE_CLOSE); break;
      case 4: Ind_Handle=iMACD(NULL,0,5,13,1,PRICE_CLOSE); break;
      case 5: Ind_Handle=iMomentum(NULL,0,momentumPeriod_trigger5,PRICE_CLOSE); break;
     }
   if(Ind_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора!");
//----
   ATR_Handle=iATR(NULL,0,keltPrd);
   if(ATR_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора!");
//----
   Std_Handle=iStdDev(NULL,0,bolPrd,0,MODE_SMA,PRICE_CLOSE);
   if(Std_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора!");
//---- установка уровней   
   switch(triggerType)
     {
      case 1:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- значения горизонтальных уровней индикатора   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+30);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-30);
         //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- в линии горизонтального уровня использован короткий штрих-пунктир  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
      case 2:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,4);
         //---- значения горизонтальных уровней индикатора   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+200);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,+100);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-100);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-200);
         //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
         //---- в линии горизонтального уровня использован короткий штрих-пунктир  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
         break;
      case 3:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- значения горизонтальных уровней индикатора   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+20);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-20);
         //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- в линии горизонтального уровня использован короткий штрих-пунктир  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
      case 4:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,0);
         break;
      case 5:
         //---- количество  горизонтальных уровней индикатора   
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         //---- значения горизонтальных уровней индикатора   
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-1);
         //---- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMagenta);
         IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
         //---- в линии горизонтального уровня использован короткий штрих-пунктир  
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
         IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
         break;
     }
//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//----
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);

//---- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(2,LineBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LineBuffer,true);
//----
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   switch(triggerType)
     {
      case 1: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with Stochastic ("+string(stochPeriod_trigger1)+",3,3)"); break;
      case 2: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with CCI ("+string(cciPeriod_trigger2)+",CLOSE)"); break;
      case 3: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with RSI ("+string(rsiPeriod_trigger3)+",CLOSE)"); break;
      case 4: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with MACD (5,13,1,CLOSE)"); break;
      case 5: IndicatorSetString(INDICATOR_SHORTNAME,"Bollinger Squeeze with Momentum ("+string(momentumPeriod_trigger5)+",CLOSE)"); break;
     }
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Bollinger_Squeeze_v9 iteration function                          | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
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
   if(BarsCalculated(Ind_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(Std_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar,clr;
   double d=0.0,Value[],ATR[],STD[];
//---- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,0,0,to_copy,Value)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(Std_Handle,0,0,to_copy,STD)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Value,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(STD,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      switch(triggerType)
        {
         case 1: d=Value[bar]-50; break;
         case 2: d=Value[bar]; break;
         case 3: d=Value[bar]-50; break;
         case 4: d=Value[bar]; break;
         case 5: d=Value[bar]-100; break;
        }
      //----
      IndBuffer[bar]=d;
      LineBuffer[bar]=d;
      clr=2;
      //----
      if(d>0) clr=4;
      else if(d<0) clr=0;
      //----
      double bbs=bolDev*STD[bar]/(ATR[bar]*keltFactor);
      //----
      if(bbs<1)
        {
         if(d>0) clr=3;
         else clr=1;
        }
      else
        {
         if(d>0) clr=4;
         else clr=0;
        }
      //----
      ColorIndBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
