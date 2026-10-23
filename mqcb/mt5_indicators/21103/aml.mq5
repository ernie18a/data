//+------------------------------------------------------------------+
//|                                                          AML.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Adaptive Market Level indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot AML
#property indicator_label1  "AML"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRoyalBlue,clrMediumSeaGreen,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint     InpFractal  =  6; // Period
input uint     InpLag      =  7; // Dimension
//--- indicator buffers
double         BufferAML[];
double         BufferColors[];
double         BufferFR[];
//--- global variables
int            period_max;
int            fractal;
int            lag;
double         lag2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Point()==0)
     {
      Print("Error! Point() value is zero.");
      return INIT_FAILED;
     }
//--- set global variables
   fractal=int(InpFractal<1 ? 1 : InpFractal);
   lag=int(InpLag<1 ? 1 : InpLag);
   period_max=fmax(fractal,lag);
   lag2=lag*lag*Point();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferAML,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferFR,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptive Market Level ("+(string)fractal+","+(string)lag+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferAML,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferFR,true);
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4 || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferAML,EMPTY_VALUE);
      ArrayInitialize(BufferFR,0);
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double R=Range(fractal,i,high,low);
      if(R==EMPTY_VALUE)
         continue;
      double R1=R/fractal;
      //---
      R=Range(fractal,i+fractal,high,low);
      if(R==EMPTY_VALUE)
         continue;
      double R2=R/fractal;
      //---
      R=Range(2*fractal,i,high,low);
      if(R==EMPTY_VALUE)
         continue;
      double R3=R/(2.0*fractal);
      //---
      double dim=(R1+R2>0 && R3>0 ? 1.44269504088896*(log(R1+R2)-log(R3)) : 0);
      double alpha=exp(-1.0*lag*(dim-1.0));
      alpha=fmin(alpha,1.0);
      alpha=fmax(alpha,0.01);
      double price=(high[i]+low[i]+2.0*open[i]+2.0*close[i])/6.0;
      BufferFR[i]=alpha*price+(1.0-alpha)*BufferFR[i+1];
      
      BufferAML[i]=(fabs(BufferFR[i]-BufferFR[i+lag])<lag2 ? BufferAML[i+1] : BufferFR[i]);
      BufferColors[i]=(BufferAML[i]>BufferAML[i+1] ? 1 : BufferAML[i]<BufferAML[i+1] ? 2 : 0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Range(const int count,const int index,const double &high[],const double &low[])
  {
   int bl=Lowest(count,index);
   int bh=Highest(count,index);
   if(bl==WRONG_VALUE || bh==WRONG_VALUE)
      return EMPTY_VALUE;
   return(high[bh]-low[bl]);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс максимального значения таймсерии High          |
//+------------------------------------------------------------------+
int Highest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyHigh(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMaximum(array)+start : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс минимального значения таймсерии Low            |
//+------------------------------------------------------------------+
int Lowest(const int count,const int start)
  {
   double array[];
   ArraySetAsSeries(array,true);
   return(CopyLow(Symbol(),PERIOD_CURRENT,start,count,array)==count ? ArrayMinimum(array)+start : WRONG_VALUE);
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
