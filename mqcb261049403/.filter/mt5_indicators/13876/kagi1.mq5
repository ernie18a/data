//+------------------------------------------------------------------+
//|                                                       KAGI-1.mq5 |
//|                           Copyright © 2005, Инструменты трейдера |
//|                                   http://www.traderstools.h15.ru |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, Инструменты трейдера"
//---- ссылка на сайт автора
#property link      "http://www.traderstools.h15.ru" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 3
#property indicator_buffers 3 
//---- использовано одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrMagenta,clrTeal
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "KAGI-1"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input bool Percent=true;
input uint Threshold=1;
input uint Size=12;
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double KagiBuffer[];
double IndBuffer[];
double ColorIndBuffer[];
//----
double dThreshold;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация констант
   min_rates_total=2;
   dThreshold=Threshold/_Point;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,KagiBuffer,INDICATOR_CALCULATIONS);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(KagiBuffer,true);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- инициализация переменной для короткого имени индикатора
   string shortname="KAGI-1";
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
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
   if(rates_total<min_rates_total) return(0);
//---- объявление переменных с плавающей точкой  
   double;
//---- объявление целочисленных переменных
   int i,j,Ind,size1,Threshold1,KagiBuffShift=0;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(close,true);
//----
   KagiBuffer[KagiBuffShift]=close[rates_total-1];
//----
   for(int bar=rates_total-2; bar>=0; bar--)
     {
      if(Percent) Threshold1=int(close[bar]/100*dThreshold);
      else Threshold1=int(Threshold);
      //----
      if(!KagiBuffShift)
        {
         if(close[bar]>=KagiBuffer[KagiBuffShift]+Threshold1*_Point)
           {
            KagiBuffShift++;
            KagiBuffer[KagiBuffShift]=close[bar];
           }
         //----
         if(close[bar]<=KagiBuffer[KagiBuffShift]-Threshold1*_Point)
           {
            KagiBuffShift++;
            KagiBuffer[KagiBuffShift]=close[bar];
           }
        }
      //----
      if(KagiBuffShift>0)
        {
         if(KagiBuffer[KagiBuffShift]>KagiBuffer[KagiBuffShift-1])
           {
            if(close[bar]>KagiBuffer[KagiBuffShift]) KagiBuffer[KagiBuffShift]=close[bar];
            //----
            if(close[bar]<=KagiBuffer[KagiBuffShift]-Threshold1*_Point)
              {
               KagiBuffShift++;
               KagiBuffer[KagiBuffShift]=close[bar];
              }
           }
         //----
         if(KagiBuffer[KagiBuffShift]<KagiBuffer[KagiBuffShift-1])
           {
            if(close[bar]<KagiBuffer[KagiBuffShift]) KagiBuffer[KagiBuffShift]=close[bar];
            //----
            if(close[bar]>=KagiBuffer[KagiBuffShift]+Threshold1*_Point)
              {
               KagiBuffShift++;
               KagiBuffer[KagiBuffShift]=close[bar];
              }
           }
        }
     }
//---- 
   size1=int(MathMin(MathMax(3,Size),50));
//----
   for(i=rates_total-1; i>=0; i--) IndBuffer[i]=0.0;
//----
   for(i=0; i<=KagiBuffShift; i++)
      for(j=0; j<size1; j++)
        {
         int barX=MathMin(MathMax((KagiBuffShift-i)*size1-j,0),rates_total-1);
         IndBuffer[barX]=KagiBuffer[i];
         ColorIndBuffer[barX]=0;
        }
//----    
   if(KagiBuffer[0]<KagiBuffer[1]) Ind=1;
   else Ind=2;
//----    
   for(i=0; i<2; i++) for(j=0; j<size1; j++)
      if(Ind==1 || Ind==2) ColorIndBuffer[MathMin(MathMax((KagiBuffShift-i)*size1-j,0),rates_total-1)]=1;
//----
   for(i=2; i<=KagiBuffShift; i++)
     {
      if(Ind==2 && KagiBuffer[i]>KagiBuffer[i-1] && KagiBuffer[i]>KagiBuffer[i-2])
        {
         ColorIndBuffer[MathMin(MathMax((KagiBuffShift-i)*size1+1,0),rates_total-1)]=1;
         Ind=1;
        }
      //----
      if(Ind==1 && KagiBuffer[i]<KagiBuffer[i-1] && KagiBuffer[i]<KagiBuffer[i-2])
        {
         ColorIndBuffer[MathMin(MathMax((KagiBuffShift-i)*size1,0),rates_total-1)]=1;
         Ind=2;
        }
      //----
      if(Ind==1) for(j=0; j<size1; j++) ColorIndBuffer[MathMin(MathMax((KagiBuffShift-i)*size1-j,0),rates_total-1)]=1;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
