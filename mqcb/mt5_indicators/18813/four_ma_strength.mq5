//+----------------------------------------------------------------------+
//|                                                 Four_MA_Strength.mq5 |
//|        Copyright © 2006 , kurkafund on 11/05/2006 by David Honeywell |
//|                      kurkafund@yahoo.com , transport.david@gmail.com |
//+----------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2006, Custom Built For kurkafund on 11/05/2006 by David Honeywell"
//--- ссылка на сайт автора
#property link      "kurkafund@yahoo.com , transport.david@gmail.com"
//+--------------------------------------------------------------------------------------------------------------------+
//|                            Custom Built For kurkafund on 11/05/2006 by David Honeywell , transport.david@gmail.com |
//+--------------------------------------------------------------------------------------------------------------------+
//--- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window  
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "Four_MA_Strength Upper"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде гистограммы
#property indicator_type2   DRAW_HISTOGRAM
//--- в качестве цвета бычей линии индикатора использован зеленый цвет
#property indicator_color2  clrLime
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Four_MA_Strength Lower"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int Ma1_Period = 8; // Averaging period 1 for calculation.
input ENUM_MA_METHOD Ma1_Method = MODE_EMA; // MA method 1. It can be any of the Moving Average method enumeration value.
input ENUM_APPLIED_PRICE Ma1_Price  = PRICE_CLOSE; // Applied price 1. It can be any of Applied price enumeration values.

input int Ma2_Period = 24; // Averaging period 2 for calculation.
input ENUM_MA_METHOD Ma2_Method = MODE_EMA; // MA metho 2. It can be any of the Moving Average method enumeration value.
input ENUM_APPLIED_PRICE Ma2_Price  = PRICE_CLOSE; // Applied price 2. It can be any of Applied price enumeration values.

input int Ma3_Period = 72; // Averaging period 3 for calculation.
input ENUM_MA_METHOD Ma3_Method = MODE_EMA; // MA method 3. It can be any of the Moving Average method enumeration value.
input ENUM_APPLIED_PRICE Ma3_Price  = PRICE_CLOSE; // Applied price 3. It can be any of Applied price enumeration values.

input int Ma4_Period = 216; // Averaging period 4 for calculation.
input ENUM_MA_METHOD Ma4_Method = MODE_EMA; // MA method 4. It can be any of the Moving Average method enumeration value.
input ENUM_APPLIED_PRICE Ma4_Price  = PRICE_CLOSE; // Applied price 4. It can be any of Applied price enumeration values.

input double  HighLevel=+3.501;         // уровень перекупленности
input double  LowLevel=-3.501;          // уровень перепроданности
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double LowerBuffer[],UpperBuffer[];
//---
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int MA_Handle[4];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   min_rates_total=int(MathMax(Ma1_Period,MathMax(Ma2_Period,MathMax(Ma3_Period,Ma4_Period))))+1;

//---- получение хендла индикатора iMA 1
   MA_Handle[0]=iMA(NULL,0,Ma1_Period,0,Ma1_Method,Ma1_Price);
   if(MA_Handle[0]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA 1");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMA 2
   MA_Handle[1]=iMA(NULL,0,Ma2_Period,0,Ma2_Method,Ma2_Price);
   if(MA_Handle[1]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA 2");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMA 3
   MA_Handle[2]=iMA(NULL,0,Ma3_Period,0,Ma3_Method,Ma3_Price);
   if(MA_Handle[2]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA 3");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMA 4
   MA_Handle[3]=iMA(NULL,0,Ma4_Period,0,Ma4_Method,Ma4_Price);
   if(MA_Handle[3]==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA 4");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,LowerBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(LowerBuffer,true);
   
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,UpperBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpperBuffer,true);
   
//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- имя для окон данных и метка для подокон 
   string short_name="Four_MA_Strength";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   
//---- количество  горизонтальных уровней индикатора 3   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
//---- в качестве цветов линий горизонтальных уровней использованы
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrMediumSeaGreen);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrRed);
//---- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
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
   if(BarsCalculated(MA_Handle[0])<rates_total
      || BarsCalculated(MA_Handle[1])<rates_total
      || BarsCalculated(MA_Handle[2])<rates_total
      || BarsCalculated(MA_Handle[3])<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double Ma1[],Ma2[],Ma3[],Ma4[];

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
   if(CopyBuffer(MA_Handle[0],0,0,to_copy,Ma1)<=0) return(RESET);
   if(CopyBuffer(MA_Handle[1],0,0,to_copy,Ma2)<=0) return(RESET);
   if(CopyBuffer(MA_Handle[2],0,0,to_copy,Ma3)<=0) return(RESET);
   if(CopyBuffer(MA_Handle[3],0,0,to_copy,Ma4)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Ma1,true);
   ArraySetAsSeries(Ma2,true);
   ArraySetAsSeries(Ma3,true);
   ArraySetAsSeries(Ma4,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double ustrength1 = 0, ustrength2 = 0, ustrength3 = 0, ustrength4 = 0, ustrength5 = 0, ustrength6 = 0;
      double dstrength1 = 0, dstrength2 = 0, dstrength3 = 0, dstrength4 = 0, dstrength5 = 0, dstrength6 = 0;
      
      double Ma1_0 = Ma1[bar]*1000;
      double Ma2_0 = Ma2[bar]*1000;
      double Ma3_0 = Ma3[bar]*1000;
      double Ma4_0 = Ma4[bar]*1000;
      
      if ( Ma1_0 > Ma2_0 ) ustrength1 =  0.25;
      if ( Ma1_0 < Ma2_0 ) dstrength1 = -0.25;
      
      if ( Ma1_0 > Ma2_0 && Ma1_0 > Ma3_0 ) ustrength2 =  0.50;
      if ( Ma1_0 < Ma2_0 && Ma1_0 < Ma3_0 ) dstrength2 = -0.50;
      
      if ( Ma1_0 > Ma2_0 && Ma1_0 > Ma3_0 && Ma1_0 > Ma4_0 ) ustrength3 =  0.75;
      if ( Ma1_0 < Ma2_0 && Ma1_0 < Ma3_0 && Ma1_0 < Ma4_0 ) dstrength3 = -0.75;
      
      if ( Ma1_0 > Ma2_0 && Ma1_0 > Ma3_0 && Ma1_0 > Ma4_0 && Ma2_0 > Ma3_0 ) ustrength4 =  1.00;
      if ( Ma1_0 < Ma2_0 && Ma1_0 < Ma3_0 && Ma1_0 < Ma4_0 && Ma2_0 < Ma3_0 ) dstrength4 = -1.00;
      
      if ( Ma1_0 > Ma2_0 && Ma1_0 > Ma3_0 && Ma1_0 > Ma4_0 && Ma2_0 > Ma3_0 && Ma2_0 > Ma4_0 ) ustrength5 =  1.25;
      if ( Ma1_0 < Ma2_0 && Ma1_0 < Ma3_0 && Ma1_0 < Ma4_0 && Ma2_0 < Ma3_0 && Ma2_0 < Ma4_0 ) dstrength5 = -1.25;
      
      if ( Ma1_0 > Ma2_0 && Ma1_0 > Ma3_0 && Ma1_0 > Ma4_0 && Ma2_0 > Ma3_0 && Ma2_0 > Ma4_0 && Ma3_0 > Ma4_0 ) ustrength6 =  1.50;
      if ( Ma1_0 < Ma2_0 && Ma1_0 < Ma3_0 && Ma1_0 < Ma4_0 && Ma2_0 < Ma3_0 && Ma2_0 < Ma4_0 && Ma3_0 > Ma4_0 ) dstrength6 = -1.50;
      
      UpperBuffer[bar] = ustrength1 + ustrength2 + ustrength3 + ustrength4 + ustrength5 + ustrength6;
      LowerBuffer[bar] = dstrength1 + dstrength2 + dstrength3 + dstrength4 + dstrength5 + dstrength6;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
