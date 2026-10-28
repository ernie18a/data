//+------------------------------------------------------------------+
//|                                   Market_Direction_Indicator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Market Direction Indicator"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
//--- plot MDI
#property indicator_label1  "MDI"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrLime,clrMediumSeaGreen,clrRed,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint                 InpPeriodFast     =  13;            // Fast MA period
input uint                 InpPeriodSlow     =  55;            // Slow MA period
input uint                 InpCutoff         =  2;             // Cutoff in points
input ENUM_INPUT_YES_NO    InpShowBelowZero  =  INPUT_YES;     // Show below zero
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferMDI[];
double         BufferColors[];
double         BufferCP[];
double         BufferMA1[];
double         BufferFMA[];
double         BufferSMA[];
//--- global variables
double         cutoff;
int            period_fma;
int            period_sma;
int            period_max;
int            handle_fma;
int            handle_sma;
int            handle_ma1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_fma=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_sma=int(InpPeriodSlow==period_fma ? period_fma+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_max=fmax(period_fma,period_sma);
   cutoff=InpCutoff/Point();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMDI,INDICATOR_DATA);
   SetIndexBuffer(1,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferCP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferFMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferSMA,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MDI ("+(string)period_fma+","+(string)period_sma+","+(string)InpCutoff+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
//--- setting plot buffer parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_max+2);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMDI,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferCP,true);
   ArraySetAsSeries(BufferMA1,true);
   ArraySetAsSeries(BufferFMA,true);
   ArraySetAsSeries(BufferSMA,true);
//--- create MA's handles
   ResetLastError();
   handle_fma=iMA(NULL,PERIOD_CURRENT,period_fma,0,MODE_SMA,InpAppliedPrice);
   if(handle_fma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_fma,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_sma=iMA(NULL,PERIOD_CURRENT,period_sma,0,MODE_SMA,InpAppliedPrice);
   if(handle_sma==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_sma,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period_max,4) || Point()==0) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_max-2;
      ArrayInitialize(BufferMDI,0);
      ArrayInitialize(BufferColors,0);
      ArrayInitialize(BufferCP,0);
      ArrayInitialize(BufferMA1,0);
      ArrayInitialize(BufferFMA,0);
      ArrayInitialize(BufferSMA,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_fma,0,0,count,BufferFMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_sma,0,0,count,BufferSMA);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
   
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferCP[i]=period_fma*period_sma*(BufferSMA[i]-BufferFMA[i]/(period_sma-period_fma));
      double sum=BufferMA1[i]+BufferMA1[i+1];
      if(sum!=0)
        {
         if(InpShowBelowZero)
            BufferMDI[i]=200.0*(BufferCP[i+1]-BufferCP[i])/sum/Point();
         else
            BufferMDI[i]=200.0*fabs((BufferCP[i+1]-BufferCP[i])/sum)/Point();
        }
      else
         BufferMDI[i]=0;
      //---
      BufferColors[i]=
        (
         BufferMDI[i]<-cutoff ?
         (BufferMDI[i]>BufferMDI[i+1] ? 3 : 4) :
         BufferMDI[i]>cutoff ?
         (BufferMDI[i]>BufferMDI[i+1] ? 1 : 2) : 0
        );
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
