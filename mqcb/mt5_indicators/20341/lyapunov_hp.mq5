//+------------------------------------------------------------------+
//|                                                  Lyapunov_HP.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Lyapunov HP oscillator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot HP
#property indicator_label1  "HP"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCrimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input uint                 InpFilter         =  7;             // Filter
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferHP[];
double         BufferH[];
double         BufferA[];
double         BufferB[];
double         BufferC[];
double         BufferMA[];
//--- global variables
int            filter;
int            handle_ma;
double         lambda;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   filter=int(InpFilter<2 ? 2 : InpFilter);
   lambda=0.0625/pow(sin(M_PI/filter),4);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferB,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"LHPosc("+(string)filter+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHP,true);
   ArraySetAsSeries(BufferH,true);
   ArraySetAsSeries(BufferA,true);
   ArraySetAsSeries(BufferB,true);
   ArraySetAsSeries(BufferC,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<3) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   int limit1=rates_total-2;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferHP,EMPTY_VALUE);
      ArrayInitialize(BufferH,0);
      ArrayInitialize(BufferA,6*lambda+1);
      ArrayInitialize(BufferB,-4*lambda);
      ArrayInitialize(BufferC,lambda);
      ArrayInitialize(BufferMA,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;

   BufferA[0]=1+lambda;
   BufferB[0]=-2*lambda;
   BufferC[0]=lambda;
   for(int i=limit1; i>0; i--)
     {
      BufferA[i]=6*lambda+1;
      BufferB[i]=-4*lambda;
      BufferC[i]=lambda;
     }
   BufferA[1]=5*lambda+1;
   BufferA[limit1]=1+lambda;
   BufferA[limit1-1]=5*lambda+1;
   BufferB[limit1-1]=-2*lambda;
   BufferB[limit1]=0;
   BufferC[limit1-1]=0;
   BufferC[limit1]=0;

   double H1=0;
   double H2=0;
   double H3=0;
   double H4=0;
   double H5=0;
   double HH1=0;
   double HH2=0;
   double HH3=0;
   double HH4=0;
   double HH5=0;
   double HB=0;
   double HC=0;
   double Z=0;

   for(int i=0; i<=limit1; i++)
     {
      Z=BufferA[i]-H4*H1-HH5*HH2;
      HB=BufferB[i];
      HH1=H1;
      H1=(HB-H4*H2)/(Z!=0 ? Z : DBL_MIN);
      BufferB[i]=H1;
      HC=BufferC[i];
      HH2=H2;
      H2=HC/(Z!=0 ? Z : DBL_MIN);
      BufferC[i]=H2;
      BufferA[i]=(BufferMA[i]-HH3*HH5-H3*H4)/(Z!=0 ? Z : DBL_MIN);
      HH3=H3;
      H3=BufferA[i];
      H4=HB-H5*HH1;
      HH5=H5;
      H5=HC;
     }
   H2=0;
   H1=BufferA[limit1-1];
   BufferH[limit1-1]=H1;

   for(int i=limit1-2; i>=0; i--)
     {
      BufferH[i]=BufferA[i]-BufferB[i]*H1-BufferC[i]*H2;
      H2=H1;
      H1=BufferH[i];
     }

//--- Расчёт индикатора
   for(int i=0; i<limit1-2; i++)
     {
      double v=BufferH[i+1];
      BufferHP[i]=MathLog(MathAbs(BufferH[i]/(v!=0 ? v : DBL_MIN)))*100000;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
