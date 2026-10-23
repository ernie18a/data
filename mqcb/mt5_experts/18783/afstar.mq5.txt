//+------------------------------------------------------------------+
//|                                                       AFStar.mq5 |
//|                                  Copyright © 2005, Forex-Experts |
//|                                     http://www.forex-experts.com |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2005, Forex-Experts"
//--- ссылка на сайт автора
#property link      "http://www.forex-experts.com"
//--- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано три буфера
#property indicator_buffers 3
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован оранжевый цвет
#property indicator_color1  clrOrange
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "AFStar Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "AFStar Buy"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double StartFast=3;
input double EndFast=3.5;
input double StartSlow=8;
input double EndSlow=9;
input double StepPeriod=0.2;
input double StartRisk=1;
input double EndRisk=2.8;
input double StepRisk=0.5;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[],Table_value2[];
//---
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   min_rates_total=12;

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Table_value2,INDICATOR_CALCULATIONS);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Table_value2,true);
//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="AFStar";
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
   if(rates_total<min_rates_total) return(RESET);

//--- объявления локальных переменных 
   int limit,bar;
   double Buy,Sell,RiskCnt;
   int Counter,i1;
   double value10,value11;
   int Sell1,Buy1;
   double Sell2,Buy2;
   int EndScan1,EndScan2;
   double x1,x2;
   double FastCnt,SlowCnt;
   double value2,value3,FastPer,SlowPer;
   double TrueCount,Range=0,AvgRange,MRO1,MRO2;
   double iMaSlowPrevious,iMaSlowCurrent,iMaFastPrevious,iMaFastCurrent;
   static int Sell1_prev,Buy1_prev;
   static double Sell2_prev,Buy2_prev;

//--- расчеты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      for(bar=rates_total-1; bar>=0 && !IsStopped(); bar--) Table_value2[bar]=NULL;
      Sell1_prev=0;
      Buy1_prev=0;
      Sell2_prev=0;
      Buy2_prev=999999999;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }

//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Table_value2[bar]=NULL;
      Sell1=0;
      Buy1=0;
      EndScan1=0;
      SlowCnt=StartSlow;
      while(SlowCnt<=EndSlow)
        {
         if(EndScan1==1) break;
         FastCnt=StartFast;
         while(FastCnt<=EndFast)
           {
            if(EndScan1==1) break;

            SlowPer=2.0/(SlowCnt+1.0);
            FastPer=2.0/(FastCnt+1.0);

            iMaSlowCurrent=close[bar]*SlowPer+close[bar+1]*(1-SlowPer);
            iMaSlowPrevious=close[bar+1]*SlowPer+close[bar+2]*(1-SlowPer);
            iMaFastCurrent=close[bar]*FastPer+close[bar+1]*(1-FastPer);
            iMaFastPrevious=close[bar+1]*FastPer+close[bar+2]*(1-FastPer);

            if(iMaFastPrevious<iMaSlowPrevious && iMaFastCurrent>iMaSlowCurrent) { EndScan1=1; Buy1=1;}
            if(iMaFastPrevious>iMaSlowPrevious && iMaFastCurrent<iMaSlowCurrent) { EndScan1=1; Sell1=1;}
            FastCnt+=StepPeriod;
           }
         SlowCnt+=StepPeriod;
        }
        
      EndScan2=0;
      Sell2=0;
      Buy2=0;
      RiskCnt=StartRisk;

      if(RiskCnt<=EndRisk)
        {
         if(EndScan2!=1)
           {
            value10=3+RiskCnt*2;
            x1=67+RiskCnt;
            x2=33-RiskCnt;
            value11=value10;
            Range=NULL;
            AvgRange=NULL;
            for(Counter=bar+9; Counter>=bar; Counter--) AvgRange+=MathAbs(high[Counter]-low[Counter]);
            Range=AvgRange/10;
            Counter=bar;
            TrueCount=0;
            while(Counter<bar+9 && TrueCount<1)
              {
               if(MathAbs(open[Counter]-close[Counter+1])>=Range*2.0) TrueCount++;
               Counter++;
              }
            if(TrueCount>=1) MRO1=Counter;
            else MRO1=-1;

            Counter=bar;
            TrueCount=0;
            while(Counter<bar+6 && TrueCount<1)
              {
               if(MathAbs(close[Counter+3]-close[Counter])>=Range*4.6) TrueCount++;
               Counter++;
              }
            if(TrueCount>=1) MRO2=Counter;
            else MRO2=-1;

            if(MRO1>-1) value11=3;
            else value11=value10;

            if(MRO2>-1) value11=4;
            else value11=value10;

            value2=100-MathAbs(GetWPR(int(value11),bar,high,low,close));
            Table_value2[bar]=value2;
            value3=0;

            if(value2<x2)
              {
               i1=1;
               while(Table_value2[bar+i1]>=x2 && Table_value2[bar+i1]<=x1) i1++;
               if(Table_value2[bar+i1]>x1)
                 {
                  value3=high[bar]+Range*0.5;
                  Sell2=value3;
                 }
              }

            if(value2>x1)
              {
               i1=1;
               while(Table_value2[bar+i1]>=x2 && Table_value2[bar+i1]<=x1) i1++;
               if(Table_value2[bar+i1]<x2)
                 {
                  value3=low[bar]-Range*0.5;
                  Buy2=value3;
                 }
              }
           }
         if(Buy2>0 || Sell2>0) EndScan2=1;
         RiskCnt+=StepRisk;
        }

      Buy=NULL;
      Sell=NULL;
      if((Buy1>0 && Buy2>0) || (Buy1>0 && Buy2_prev>0) || (Buy1_prev>0 && Buy2>0)) Buy=low[bar]-0.3*Range;
      if((Sell1>0 && Sell2>0) || (Sell1>0 && Sell2_prev>0) || (Sell1_prev>0 && Sell2>0)) Sell=high[bar]+0.3*Range;
      //Ignore if we have two signals
      if(Buy && Sell)
        {
         Buy=NULL;
         Sell=NULL;
        }
      BuyBuffer[bar]=Buy;
      SellBuffer[bar]=Sell;
      //---
      if(bar)
        {
         Sell1_prev=Sell1;
         Buy1_prev=Buy1;
         Sell2_prev=Sell2;
         Buy2_prev=Buy2;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
// вычисление осциллятора WPR                                        |
//+------------------------------------------------------------------+ 
double GetWPR(int period,int index,const double &High[],const double &Low[],const double &Close[])
  {
//----
   double WPR=-50;
   static double WPR_prev=-50;
//--- calculate maximum High
   double dMaxHigh=High[ArrayMaximum(High,index,period)];;
//--- calculate minimum Low
   double dMinLow=Low[ArrayMinimum(Low,index,period)];
//--- calculate WPR
   double res=dMaxHigh-dMinLow;
   if(res) WPR=-(dMaxHigh-Close[index])*100/res;
   else WPR=WPR_prev;
   if(index) WPR_prev=WPR;
//----
   return(WPR);
  }
//+------------------------------------------------------------------+
