//+------------------------------------------------------------------+
//|                                                       NonLag.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Non lag average indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot NonLag
#property indicator_label1  "NonLag"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreen,clrRed,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod         =  10;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpFilter         =  0;             // Filter
input double               InpDeviation      =  0.0;           // Deviation (price)
//--- indicator buffers
double         BufferNonLag[];
double         BufferColors[];
double         BufferMA[];
//--- global variables
double         deviation;
double         coeff;
double         phase;
double         len;
double         dt1;
double         dt2;
double         kd;
double         filter;
int            period;
int            handle_ma;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<3 ? 3 : InpPeriod);
   deviation=InpDeviation;
   coeff=3.0*M_PI;
   phase=period-1;
   len=4.0*period+phase;
   dt1=7.0/(4.0*period-1.0);
   dt2=1.0/(phase-1.0);
   kd=1.0+deviation/100.0;
   filter=(double)InpFilter*Point();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferNonLag,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Non lag average ("+(string)period+","+(string)InpFilter+","+DoubleToString(deviation,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferNonLag,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA (",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(len+period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-(int)(len+period)-2;
      ArrayInitialize(BufferNonLag,EMPTY_VALUE);
      ArrayInitialize(BufferColors,2);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double weight=0,sum=0,t=0;
      for(int j=0; j<len; j++)
        {
         double g=1.0/(coeff*t+1);
         if(t<=0.5) g=1;
         double beta=cos(M_PI*t);
         double alpha=g*beta;
         sum+=alpha*BufferMA[i+j];
         weight+=alpha;
         if(t<1.0) t+=dt2; else if(t<len-1) t=+dt1;
        }
      if(weight>0)
         BufferNonLag[i]=kd*sum/weight;
      if(filter>0 && fabs(BufferNonLag[i]-BufferNonLag[i+1])<filter)
         BufferNonLag[i]=BufferNonLag[i+1];
      BufferColors[i]=(BufferNonLag[i]-BufferNonLag[i+1]>filter ? 0 : BufferNonLag[i+1]-BufferNonLag[i]>filter ? 1 : BufferColors[i+1]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
