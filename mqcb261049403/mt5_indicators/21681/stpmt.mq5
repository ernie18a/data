//+------------------------------------------------------------------+
//|                                                        STPMT.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property description "Medium Term Weighted Stochastics oscillator"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot STPMT
#property indicator_label1  "STPMT"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Sto1
#property indicator_label3  "Stochastic 1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Sto2
#property indicator_label4  "Stochastic 2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Sto3
#property indicator_label5  "Stochastic 3"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSilver
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Sto4
#property indicator_label6  "Stochastic 4"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSilver
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpPeriodK1       =  5;             // Stochastic 1 %K period
input uint              InpPeriodD1       =  3;             // Stochastic 1 %D period
input uint              InpSlowing1       =  3;             // Stochastic 1 Slowing
input ENUM_MA_METHOD    InpMethod1        =  MODE_SMA;      // Stochastic 1 Method
input ENUM_STO_PRICE    InpPriceField1    =  STO_LOWHIGH;   // Stochastic 1 Price field
input double            InpWeight1        =  4.1;           // Stochastic 1 Weight

input uint              InpPeriodK2       =  14;            // Stochastic 2 %K period
input uint              InpPeriodD2       =  3;             // Stochastic 2 %D period
input uint              InpSlowing2       =  3;             // Stochastic 2 Slowing
input ENUM_MA_METHOD    InpMethod2        =  MODE_SMA;      // Stochastic 2 Method
input ENUM_STO_PRICE    InpPriceField2    =  STO_LOWHIGH;   // Stochastic 2 Price field
input double            InpWeight2        =  2.5;           // Stochastic 2 Weight

input uint              InpPeriodK3       =  45;            // Stochastic 3 %K period
input uint              InpPeriodD3       =  14;            // Stochastic 3 %D period
input uint              InpSlowing3       =  3;             // Stochastic 3 Slowing
input ENUM_MA_METHOD    InpMethod3        =  MODE_SMA;      // Stochastic 3 Method
input ENUM_STO_PRICE    InpPriceField3    =  STO_LOWHIGH;   // Stochastic 3 Price field
input double            InpWeight3        =  1.0;           // Stochastic 3 Weight

input uint              InpPeriodK4       =  75;            // Stochastic 4 %K period
input uint              InpPeriodD4       =  20;            // Stochastic 4 %D period
input uint              InpSlowing4       =  3;             // Stochastic 4 Slowing
input ENUM_MA_METHOD    InpMethod4        =  MODE_SMA;      // Stochastic 4 Method
input ENUM_STO_PRICE    InpPriceField4    =  STO_LOWHIGH;   // Stochastic 4 Price field
input double            InpWeight4        =  4.0;           // Stochastic 4 Weight

input uint              InpPeriodSig      =  9;             // Signal line period
input ENUM_INPUT_YES_NO InpShowComponents =  INPUT_YES;     // Show components
//--- indicator buffers
double         BufferSTPMT[];
double         BufferSignal[];
//--- global variables
struct SDataStoch
  {
   double            buffer[];
   double            weight;
   ENUM_MA_METHOD    method;
   ENUM_STO_PRICE    price;
   int               period_k;
   int               period_d;
   int               slowing;
   int               handle;
  } stoch[4];
double         weights;
int            period_sig;
int            period_max;
int            total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sig=int(InpPeriodSig<2 ? 2 : InpPeriodSig);
   total=ArraySize(stoch);
   weights=period_max=0;
   for(int i=0;i<total;i++)
     {
      SetIndexBuffer(i+2,stoch[i].buffer,INDICATOR_DATA);
      ArraySetAsSeries(stoch[i].buffer,true);
      PlotIndexSetInteger(i+2,PLOT_DRAW_TYPE,InpShowComponents);
      PlotIndexSetInteger(i+2,PLOT_SHOW_DATA,false);
      SetParams(i,stoch[i].period_k,stoch[i].period_d,stoch[i].slowing,stoch[i].weight,stoch[i].method,stoch[i].price);
      stoch[i].handle=iStochastic(NULL,PERIOD_CURRENT,stoch[i].period_k,stoch[i].period_d,stoch[i].slowing,stoch[i].method,stoch[i].price);
      if(stoch[i].handle==INVALID_HANDLE)
        {
         Print("The iStochastic",i+1," (",(string)stoch[i].period_k,",",(string)stoch[i].period_d,",",(string)stoch[i].slowing,") object was not created: Error ",GetLastError());
         return INIT_FAILED;
        }
      weights+=stoch[i].weight;
      int period=fmax(stoch[i].period_k,stoch[i].period_d);
      if(period>period_max)
         period_max=period;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSTPMT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSignal,INDICATOR_DATA);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Medium Term Weighted Stochastics");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period_max);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSTPMT,true);
   ArraySetAsSeries(BufferSignal,true);
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferSTPMT,0);
      ArrayInitialize(BufferSignal,0);
      for(int i=0;i<total;i++)
         ArrayInitialize(stoch[i].buffer,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   for(int i=0;i<total;i++)
     {
      copied=CopyBuffer(stoch[i].handle,MAIN_LINE,0,count,stoch[i].buffer);
      if(copied!=count) return 0;
     }

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferSTPMT[i]=(stoch[0].weight*stoch[0].buffer[i] + stoch[1].weight*stoch[1].buffer[i] + stoch[2].weight*stoch[2].buffer[i] + stoch[3].weight*stoch[3].buffer[i])/weights;
      BufferSignal[i]=GetSMA(rates_total,i,period_sig,BufferSTPMT);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
double GetSMA(const int rates_total,const int index,const int period,const double &price[],const bool as_series=true)
  {
//---
   double result=0.0;
//--- check position
   bool check_index=(as_series ? index<=rates_total-period-1 : index>=period-1);
   if(period<1 || !check_index)
      return 0;
//--- calculate value
   for(int i=0; i<period; i++)
      result=result+(as_series ? price[index+i]: price[index-i]);
//---
   return(result/period);
  }
//+------------------------------------------------------------------+
//| Устанавливает параметры стохастика по индексу                    |
//+------------------------------------------------------------------+
void SetParams(const int index,int &period_k,int &period_d,int &slowihg,double &weight,ENUM_MA_METHOD &method,ENUM_STO_PRICE &price)
  {
   switch(index)
     {
      case 1 :
         period_k=int(InpPeriodK2<1 ? 1 : InpPeriodK2);
         period_d=int(InpPeriodD2<1 ? 1 : InpPeriodD2);
         slowihg =int(InpSlowing2<1 ? 1 : InpSlowing2);
         price   =InpPriceField2;
         method  =InpMethod2;
         weight  =InpWeight2;
         break;
      case 2 :
         period_k=int(InpPeriodK3<1 ? 1 : InpPeriodK3);
         period_d=int(InpPeriodD3<1 ? 1 : InpPeriodD3);
         slowihg =int(InpSlowing3<1 ? 1 : InpSlowing3);
         price   =InpPriceField3;
         method  =InpMethod3;
         weight  =InpWeight3;
         break;
      case 3 :
         period_k=int(InpPeriodK4<1 ? 1 : InpPeriodK4);
         period_d=int(InpPeriodD4<1 ? 1 : InpPeriodD4);
         slowihg =int(InpSlowing4<1 ? 1 : InpSlowing4);
         price   =InpPriceField4;
         method  =InpMethod4;
         weight  =InpWeight4;
         break;
      default:
         period_k=int(InpPeriodK1<1 ? 1 : InpPeriodK1);
         period_d=int(InpPeriodD1<1 ? 1 : InpPeriodD1);
         slowihg =int(InpSlowing1<1 ? 1 : InpSlowing1);
         price   =InpPriceField1;
         method  =InpMethod1;
         weight  =InpWeight1;
         break;
     }
  }
//+------------------------------------------------------------------+
