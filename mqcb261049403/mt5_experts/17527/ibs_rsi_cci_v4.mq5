//+------------------------------------------------------------------+
//|                                               IBS_RSI_CCI_v4.mq5 |
//|                                     Copyright © 2017, Martingeil | 
//|                                                    fx.09@mail.ru | 
//+------------------------------------------------------------------+ 
/*
 * Три методики расчёта IBS,RSI,CCI все равноправны в упраляемости, у всех есть переворот расчёта, 
 * коэффициент относительности и аплиедпрайс ( для IBS это не значащий параметр, но стоит для симметрии параметров).
 * Отрисовка линий идёт как средняя от трёх IBS,RSI,CCI .
 * Внутри как прямого так и перевёрнутого можно в свою очередь перевернуть одину из методик,
 * те они не зависимы как по перевороту так и по относительности.
 * Так же через Shift линии можно двигать (Shift не может быть отрицательной).
 * "вариант_1" управляет вариантами расчёта 1 или 2. По умолчанию стоит 2 --> "вариант_1 = false".
 * "positive" управляет зеркальностью отображения. По умолчанию стоит нормальное отображение --> "positive = true".
 */
//---- авторство индикатора
#property copyright "Copyright © 2017, Martingeil"
#property link      "fx.09@mail.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window  
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета индикатора использованы
#property indicator_color1  clrDodgerBlue,clrMediumPurple
//---- отображение бычей метки индикатора
#property indicator_label1  "IBS_RSI_CCI_v4"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
//---- параметры средней линии
input uint      IBSPeriod=5;
input  ENUM_MA_METHOD   MAType=MODE_SMA;
//---- Параметры RSI
input uint   RSIPeriod=14;
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE;
//---- Параметры CCI
input uint   CCIPeriod=14;
input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN;

input int      porog=50; //порог
//---- параметр фильтра линии VKWB 
input  ENUM_MA_METHOD   MAType_VKWB=MODE_SMA;     
input int      RangePeriod_VKWB  = 25;
input int      SmoothPeriod_VKWB =  3;
//+----------------------------------------------+
double koef_ibs = 7.0;
double koef_rsi = 9.0;
double koef_cci = 1.0;
bool ibs = true;//применять ibs для расчета средней линии
bool rsi = true;//применять rsi для расчета средней линии
bool cci = true;//применять cci для расчета средней линии
int kibs=-1,kcci=-1,krsi=-1,posit=-1,xma1=1;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
//---- Объявление целых переменных для хендлов индикаторов
int CCI_Handle,RSI_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,min_rates_1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_1=int(MathMax(CCIPeriod,RSIPeriod)+IBSPeriod+RangePeriod_VKWB);
   min_rates_total=min_rates_1+int(SmoothPeriod_VKWB+RangePeriod_VKWB);

//---- получение хендла индикатора iCCI
   CCI_Handle=iCCI(NULL,0,CCIPeriod,CCIPrice);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iCCI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iRSI
   RSI_Handle=iRSI(NULL,0,RSIPeriod,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);

//---- осуществление сдвига начала отсчёта отрисовки индикатора на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"IBS_RSI_CCI_v4");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,4);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(CCI_Handle)<rates_total || BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double CCI[],RSI[];
   double series,xseries,sum,divisor,raz10;
   double E0,E1,E3,E4,E5,E6,E7;
   int maxbar1=rates_total-2;
   int maxbar2=rates_total-2-min_rates_1;

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-2; // стартовый номер для расчёта всех баров
      UpBuffer[limit+1]=NULL;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- расчёт необходимого количества копируемых данных
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      divisor=MathMax(high[bar]-low[bar],_Point);
      series=(close[bar]-low[bar])/divisor;
      xseries=XMA1.XMASeries(maxbar1,prev_calculated,rates_total,Smooth_Method(MAType),0,IBSPeriod,series,bar,true);
      sum=NULL;
      sum+=kibs*(xseries-0.5)*100.0*koef_ibs;
      sum+=kcci*CCI[bar]*koef_cci;
      sum+=krsi*(RSI[bar]-50.0)*koef_rsi;
      sum*=1.0/3.0;
      E1=posit*sum;
      E0=UpBuffer[bar+1];
      raz10=E1-E0;
      if(MathAbs(raz10)>porog)
        {
         if(raz10>0) E0=E1-porog*xma1;
         if(raz10<0) E0=E1+porog*xma1;
        }
      UpBuffer[bar]=E0;
      E3=UpBuffer[ArrayMaximum(UpBuffer,bar,RangePeriod_VKWB)];
      E4=UpBuffer[ArrayMinimum(UpBuffer,bar,RangePeriod_VKWB)];        
      E5=XMA2.XMASeries(maxbar2,prev_calculated,rates_total,Smooth_Method(MAType_VKWB),0,SmoothPeriod_VKWB,E3,bar,true);
      E6=XMA3.XMASeries(maxbar2,prev_calculated,rates_total,Smooth_Method(MAType_VKWB),0,SmoothPeriod_VKWB,E4,bar,true);      
      E7=(E5+E6)/2;     
      DnBuffer[bar]=E7;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
