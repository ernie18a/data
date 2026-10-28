//+------------------------------------------------------------------+
//|                                  Statistical characteristics.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.00"
#property description "Применение стандартной библиотеки Статистика: Статистические характеристики"
#property description "The use of standard library statistics: Statistical characteristics"
//--- подключаем функции для расчета нормального распределения
//--- include the functions for calculating the normal distribution
#include <Math\Stat\Normal.mqh>
#property indicator_separate_window 
#property indicator_buffers 4 
#property indicator_plots   1 
//--- plot Histogram 
#property indicator_label1  "Method Of Stat" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrBlue 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- indicator buffers 
double         meanBuffer[];                 // среднее значение (1-ый момент)      // the mean (first moment)
double         varianceBuffer[];             // дисперсия (2-ой момент)             // the variance (second moment)
double         skewnessBuffer[];             // коэффициент асимметрии (3-ий момент)// the skewness (third moment)
double         kurtosisBuffer[];             // коэффициент эксцесса (4-ый момент)  // the kurtosis (fourth moment)
//--- method of stat 
enum methodOfStat
  {
   mean=0,        // среднее значение, mean 
   variance=1,    // дисперсия, variance 
   skewness=2,    // коэффициент асимметрии, skewness 
   kurtosis=3,    // коэффициент эксцесса, kurtosis 
  };
//--- input parameters
input int            Inpcount=10;            // количество элементов, the number of elements 
input methodOfStat   Inpmethod=mean;         // метод, method
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- нюанс: буфер "INDICATOR_DATA" должен иметь индекс "0"
//--- caveat: buffer "INDICATOR_DATA" must have an index of "0"
   if(Inpmethod==mean)
     {
      SetIndexBuffer(0,meanBuffer,INDICATOR_DATA);
      SetIndexBuffer(1,varianceBuffer,INDICATOR_CALCULATIONS);
      SetIndexBuffer(2,skewnessBuffer,INDICATOR_CALCULATIONS);
      SetIndexBuffer(3,kurtosisBuffer,INDICATOR_CALCULATIONS);
     }
   if(Inpmethod==variance)
     {
      SetIndexBuffer(0,varianceBuffer,INDICATOR_DATA);
      SetIndexBuffer(1,meanBuffer,INDICATOR_CALCULATIONS);
      SetIndexBuffer(2,skewnessBuffer,INDICATOR_CALCULATIONS);
      SetIndexBuffer(3,kurtosisBuffer,INDICATOR_CALCULATIONS);
     }
   if(Inpmethod==skewness)
     {
      SetIndexBuffer(0,skewnessBuffer,INDICATOR_DATA);
      SetIndexBuffer(1,meanBuffer,INDICATOR_CALCULATIONS);
      SetIndexBuffer(2,varianceBuffer,INDICATOR_CALCULATIONS);
      SetIndexBuffer(3,kurtosisBuffer,INDICATOR_CALCULATIONS);
     }
   if(Inpmethod==kurtosis)
     {
      SetIndexBuffer(0,kurtosisBuffer,INDICATOR_DATA);
      SetIndexBuffer(1,meanBuffer,INDICATOR_CALCULATIONS);
      SetIndexBuffer(2,varianceBuffer,INDICATOR_CALCULATIONS);
      SetIndexBuffer(3,skewnessBuffer,INDICATOR_CALCULATIONS);
     }
//--- короткое наименование индикатора 
//--- name for DataWindow and indicator subwindow label 
   IndicatorSetString(INDICATOR_SHORTNAME,EnumToString(Inpmethod)+"("+IntegerToString(Inpcount)+")");
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
//--- check for rates total
   if(rates_total<Inpcount)
      return(0); // not enough bars for calculation
   int limit=Inpcount;
   if(prev_calculated==0)
      for(int i=0;i<Inpcount;i++)
        {
         meanBuffer[i]=0.0;
         varianceBuffer[i]=0.0;
         skewnessBuffer[i]=0.0;
         kurtosisBuffer[i]=0.0;
        }
   else
      limit=prev_calculated;
//---
   for(int i=limit;i<rates_total;i++)
     {
      double mean=0.0;
      double variance=0.0;
      double skewness=0.0;
      double kurtosis=0.0;
      //--- MathMoments: аассчитывает первые 4 момента (среднее, дисперсия, коэффициент асимметрии, коэффициент эксцесса) элементов массива
      //--- MathMoments: calculates the first 4 moments (mean, variance, skewness, kurtosis) of array elements
      if(MathMoments(close,mean,variance,skewness,kurtosis,i-Inpcount,Inpcount))
        {
         meanBuffer[i]=mean;
         varianceBuffer[i]=variance;
         skewnessBuffer[i]=skewness;
         kurtosisBuffer[i]=kurtosis;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
