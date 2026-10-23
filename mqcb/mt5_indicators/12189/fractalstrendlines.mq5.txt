//+------------------------------------------------------------------+
//|                                           FractalsTrendLines.mq5 |
//|                                           Copyright 2014, Svds75 |
//|                                             http://reksystem.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Svds75"
#property link      "https://login.mql5.com/ru/users/svds75/"
#property version   "1.00"
#property description "Индикатор чертит бычью и медвежью линии тренда, на основании инд. iFractals. От ближайшего экстремума до последнего не пробитого фрактала. При пробитии данного фрактала линия закрепляется до появления нового экстремума.\n"
#property description "Трактовать можно следующим образом:"
#property description "1) Пересечение линий \"Проходной Крест\""
#property description "2) Закрытие выше обоих линий: \"Тренд бычий\""
#property description "3) Закрытие ниже обоих линий: \"Тренд медвежий\""
#property description "4) Закрытие между линий, и \"П.К.\" слева: \"Флет\""
#property description "5) Закрытие между линий, и \"П.К.\" справа: \"Треугольник неопределенности\""
#property indicator_chart_window
#property indicator_plots 0
//+------------------------------------------------------------------+
#define PROGRAM_NAME MQLInfoString(MQL_PROGRAM_NAME)
//+------------------------------------------------------------------+
sinput color inpClrBull=clrGreen;   // Цвет бычьей линии тренда
sinput color inpClrBear=clrRed;     // Цвет медвежьей линии тренда
//+------------------------------------------------------------------+
#include <ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
int handle;                // Будет хранить хэндл индикатора iFractals
CChartObjectTrend upLine;  // Объект верхней линии тренда (медвежей)
CChartObjectTrend dnLine;  // Объект нижней линии тренда (бычей)
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create handle indicator iFractals
   handle=iFractals(_Symbol,_Period);
   if(handle==INVALID_HANDLE) handle=IndicatorCreate(_Symbol,_Period,IND_FRACTALS);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("Error create Fractals indicator handle %s/%s, code %d",_Symbol,EnumToString(_Period),GetLastError());
      return(INIT_FAILED);
     }
//--- create indicator shortname
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat(PROGRAM_NAME+"(%s/%s)",_Symbol,EnumToString(_Period)));
//--- init ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // размер входных таймсерий
                 const int prev_calculated,  // обработано баров на предыдущем вызове
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[]         // Spread
                 )
  {
//---
   ArraySetAsSeries(time,true);
   if(!createTrendLine(0,time)) return(0);
   if(!createTrendLine(1,time)) return(0);
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete handle indicator iFractals
   IndicatorRelease(handle);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator create TrendLine function                       |
//+------------------------------------------------------------------+
int createTrendLine(const int t,const datetime &TM[])
  {
//---
   int count=500;
//---
   if(t==0)
     {
      double a[];
      ArraySetAsSeries(a,true);
      if(CopyBuffer(handle,0,0,count,a)<0)
        {
         PrintFormat("Не удалось скопировать данные из индикатора iFractals, код ошибки %d",GetLastError());
         return(false);
        }
      int b1=0,b2=0;
      double p1=0,p2=0;
      datetime t1=0,t2=0;
      //---
      for(int b=3;b<count;b++) if(a[b]!=EMPTY_VALUE)
        {
         if(p2==0)
           {
            p2=a[b];
            t2=TM[b];
            b2=b;
           }
         else if(p1==0)
           {
            p1=a[b];
            t1=TM[b];
            b1=b;
           }
         else if(a[b]<p1 && p1>p2) break;
         else
           {
            p2=p1;
            t2=t1;
            b2=b1;
            p1=a[b];
            t1=TM[b];
            b1=b;
           }
        }
      //---
      for(int b=b2-1;b>2;b--) if(a[b]!=EMPTY_VALUE) if(p2>a[b])
        {
         p2=a[b];
         t2=TM[b];
         b2=b;
        }
      else break;
      //---
      if(upLine.Name()!=PROGRAM_NAME+"_Bear_Trend")
        {
         upLine.Create(0,PROGRAM_NAME+"_Bear_Trend",0,t1,p1,t2,p2);
         upLine.RayRight(true);
         upLine.Style(STYLE_DOT);
         upLine.Color(inpClrBear);
        }
      else
        {
         upLine.Time(0,t1);
         upLine.Price(0,p1);
         upLine.Time(1,t2);
         upLine.Price(1,p2);
        }
      //---
      return(true);
     }
//---
   if(t==1)
     {
      double a[];
      ArraySetAsSeries(a,true);
      if(CopyBuffer(handle,1,0,count,a)<0)
        {
         PrintFormat("Не удалось скопировать данные из индикатора iFractals, код ошибки %d",GetLastError());
         return(false);
        }
      int b1=0,b2=0;
      double p1=0,p2=0;
      datetime t1=0,t2=0;
      //---
      for(int b=3;b<count;b++) if(a[b]!=EMPTY_VALUE)
        {
         if(p2==0)
           {
            p2=a[b];
            t2=TM[b];
            b2=b;
           }
         else if(p1==0)
           {
            p1=a[b];
            t1=TM[b];
            b1=b;
           }
         else if(a[b]>p1 && p1<p2) break;
         else
           {
            p2=p1;
            t2=t1;
            b2=b1;
            p1=a[b];
            t1=TM[b];
            b1=b;
           }
        }
      //---
      for(int b=b2-1;b>2;b--) if(a[b]!=EMPTY_VALUE) if(p2<a[b])
        {
         p2=a[b];
         t2=TM[b];
         b2=b;
        }
      else break;
      //---
      if(dnLine.Name()!=PROGRAM_NAME+"_Bull_Trend")
        {
         dnLine.Create(0,PROGRAM_NAME+"_Bull_Trend",0,t1,p1,t2,p2);
         dnLine.RayRight(true);
         dnLine.Style(STYLE_DOT);
         dnLine.Color(inpClrBull);
        }
      else
        {
         dnLine.Time(0,t1);
         dnLine.Price(0,p1);
         dnLine.Time(1,t2);
         dnLine.Price(1,p2);
        }
      //---
      return(true);
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
