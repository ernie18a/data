//+------------------------------------------------------------------+
//|                                          i-GentorLSMAEMA_v02.mq5 | 
//|                               Copyright © 2007, FX Sniper, KimIV | 
//|                                              http://www.kimiv.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, FX Sniper, KimIV"
#property link "http://www.kimiv.ru"
#property description ""
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- фиксированная высота подокна индикатора в пикселях 
#property indicator_height 40
//--- нижнее и верхнее ограничения шкалы отдельного окна индикатора
#property indicator_maximum +3.9
#property indicator_minimum +0.3
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0      // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//--- количество индикаторных буферов
#property indicator_buffers 4
//--- использовано 2 графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//--- в качестве цвета линии индикатора использованы
#property indicator_color1 clrRed,clrGray,clrLime
//--- линия индикатора - штрих
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора равна 5
#property indicator_width1  5
//--- отображение метки индикатора
#property indicator_label1  "Signal line"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 2            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде четырехцветных значков
#property indicator_type2 DRAW_COLOR_LINE
//--- в качестве цветов пятицветной гистограммы использованы
#property indicator_color2 clrYellow,clrGray,clrBlue
//--- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//--- толщина линии индикатора равна 5
#property indicator_width2 5
//--- отображение метки индикатора
#property indicator_label2  "Signal Arrow"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint                 LSMAPeriod=25;         // Период LSMA
input uint                 MAPeriod=34;           // Период MA
input ENUM_MA_METHOD       MAType=MODE_EMA;       // Тип усреднения
input ENUM_APPLIED_PRICE   MAPrice=PRICE_TYPICAL; // Ценовая константа
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем 
//--- будут использованы в качестве индикаторных буферов
double Ind1Buffer[];
double ColorInd1Buffer[];
double Ind2Buffer[];
double ColorInd2Buffer[];
//---
double res,lengthvar;
//--- объявление целочисленных переменных для хендлов индикаторов
int MA_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных   
   min_rates_total=int(MathMax(LSMAPeriod,MAPeriod));
   lengthvar=(LSMAPeriod+1)/3.0;
   res=6.0/(LSMAPeriod*(LSMAPeriod+1.0));
//--- получение хендла индикатора iMA
   MA_Handle=iMA(_Symbol,PERIOD_CURRENT,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Ind1Buffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ind1Buffer,true);
//--- превращение динамического массива в цветовой индексный буфер   
   SetIndexBuffer(1,ColorInd1Buffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorInd1Buffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Ind2Buffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ind2Buffer,true);
//--- превращение динамического массива в цветовой индексный буфер   
   SetIndexBuffer(3,ColorInd2Buffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorInd2Buffer,true);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="i-GentorLSMAEMA_v02";
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
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double MA[];
//--- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      limit=rates_total-int(MAPeriod)-1; // стартовый номер для расчета всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
   to_copy=limit+1;
//--- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(MA,true);
   ArraySetAsSeries(close,true);
//--- копируем вновь появившиеся данные в массив
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);
//--- основной цикл расчета индикатора 2
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Ind2Buffer[bar]=+1.4;
      ColorInd2Buffer[bar]=1;
      if(close[bar]>MA[bar]) ColorInd2Buffer[bar]=2;
      else if(close[bar]<MA[bar]) ColorInd2Buffer[bar]=0;
     }
//---     
   if(prev_calculated>rates_total || prev_calculated<=0) limit=rates_total-int(LSMAPeriod)-1;
//--- основной цикл расчета индикатора 1
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Ind1Buffer[bar]=+3;
      ColorInd1Buffer[bar]=1;
      double sum=0;
      for(int iii=int(LSMAPeriod); iii>=1; iii--)
        {
         double tmp=(iii-lengthvar)*close[LSMAPeriod-iii+bar];
         sum+=tmp;
        }
      double wt=sum*res;
      //---
      if(wt>close[bar]) ColorInd1Buffer[bar]=0;
      else if(wt<close[bar]) ColorInd1Buffer[bar]=2;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
