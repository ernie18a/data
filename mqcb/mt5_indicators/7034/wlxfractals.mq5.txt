//+------------------------------------------------------------------+
//|                                                  wlxFractals.mq5 |
//|         Copyright © 2004, by konKop, GOODMAN, Mstera, af + wellx |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2004, by konKop, GOODMAN, Mstera, af + wellx"
//---- ссылка на сайт автора
#property link      "https://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.00"
#property description "Фракталы Билла Вильямса"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета индикатора использован синий цвет
#property indicator_color1  clrBlue
//---- толщина линии индикатора 1 равна 3
#property indicator_width1  3
//---- отображение бычей метки индикатора
#property indicator_label1  "Up Fractal"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета индикатора использован розовый цвет
#property indicator_color2  clrMagenta
//---- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Down Fractal"

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Equals=5;
input uint nLeftUp=2;
input uint nRightUp=2;
input uint nLeftDown=2;
input uint nRightDown=2;
input int  UpLable=217;//лейба верхнего фрактала
input int  DnLable=218;//лейба нижнего фрактала
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[];
double DnBuffer[];
//---
int min_rates_total;
int cntup,cntdown,cnt,r,l,e,fup,fdown;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных 
   r=0;
   l=0;
   e=0;
   fup=0;
   fdown=0;
   cntup=int(nLeftUp+nRightUp+Equals)+1;
   cntdown=int(nLeftDown+nRightDown+Equals)+1;
   if(cntup>=cntdown) cnt=cntup;
   if(cntup<cntdown) cnt=cntdown;
   min_rates_total=MathMax(cntup,cntdown);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="wlxFractals";
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
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int limit,bar,i,j;
   double;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      UpBuffer[bar]=EMPTY_VALUE;
      DnBuffer[bar]=EMPTY_VALUE;
     }

//---- основной цикл расчёта индикатора
   for(bar=limit+(int)nRightUp; bar>=(int)nRightUp && !IsStopped(); bar--)
     {
      //фРАКТАЛ ВВЕРХ
      r=(int)nRightUp; //проверяем правую сторону фрактала
      //----
      for(i=1; i<=r; i++) if(high[bar]<=high[bar-i]) break;
      //если справа все ОК то i должно быть равно r+1
      if(i==r+1)
        {
         l=(int)nLeftUp;  //проверяем левую сторону фрактала
         e=(int)Equals;
         //----
         for(j=1; j<=l+(int)Equals; j++)
           {
            if(high[bar]<high[bar+j]) break;
            //----
            if(high[bar]>high[bar+j]) l--;
            //----
            if(high[bar]==high[bar+j]) e--;
            //----
            if(!l)
              {
               UpBuffer[bar]=high[bar];
               break;
              }
            //----
            if(e<0) break;
           }
        }
     }

//---- основной цикл расчёта индикатора
   for(bar=limit+(int)nRightDown; bar>=(int)nRightDown && !IsStopped(); bar--)
     {
      //ФРАКТАЛ ВНИЗ
      r=(int)nRightDown; //проверяем правую сторону фрактала
      //----
      for(i=1; i<=r; i++) if(low[bar]>=low[bar-i]) break;
      //----
      if(i==r+1)
        {
         l=(int)nLeftDown;  //проверяем левую сторону фрактала
         e=(int)Equals;
         //----
         for(j=1; j<=l+(int)Equals; j++)
           {
            if(low[bar]>low[bar+j]) break;
            //----
            if(low[bar]<low[bar+j]) l--;
            //----
            if(low[bar]==low[bar+j]) e--;
            //----
            if(l==0)
              {
               DnBuffer[bar]=low[bar];
               break;
              }
            if(e<0) break;
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
