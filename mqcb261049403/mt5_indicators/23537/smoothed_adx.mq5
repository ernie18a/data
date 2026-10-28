//+------------------------------------------------------------------+
//|                                                 Smoothed_ADX.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Smoothed ADX by John Ehlers indicator"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   3
//--- plot SADX
#property indicator_label1  "SADX"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SDIP
#property indicator_label2  "+SDI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot SDIM
#property indicator_label3  "- SDI"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint     InpPeriod   =  14;      // Period
input double   InpAlpha1   =  0.25;    // Primary smoothing factor
input double   InpAlpha2   =  0.33;    // Secondary smoothing factor
input double   InpLevStrong=  40.0;    // Strong trend level
input double   InpLevWeak  =  20.0;    // Weak trend level
//--- indicator buffers
double         BufferSDIP[];
double         BufferSDIM[];
double         BufferSADX[];
double         BufferDIPtmp[];
double         BufferDIMtmp[];
double         BufferADXtmp[];
double         BufferDIP[];
double         BufferDIM[];
double         BufferADX[];
//--- global variables
double         alpha1;
double         alpha2;
double         strong;
double         weak;
int            period;
int            handle_adx;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   alpha1=(InpAlpha1<0 ? 0 : InpAlpha1);
   alpha2=(InpAlpha2<0.109 ? 0.109 : InpAlpha2);
   strong=(InpLevStrong>100.0 ? 100.0 : InpLevStrong<0.1 ? 0.1 : InpLevStrong);
   weak=(InpLevWeak>=strong ? strong-0.1 : InpLevWeak<0 ? 0 : InpLevWeak);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferSADX,INDICATOR_DATA);
   SetIndexBuffer(1,BufferSDIP,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSDIM,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDIPtmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDIMtmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferADXtmp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferDIP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferDIM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferADX,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoothed ADX ("+(string)period+","+DoubleToString(alpha1,2)+","+DoubleToString(alpha2,2)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,strong);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,weak);
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
//--- setting plot buffer parameters
   PlotIndexSetString(0,PLOT_LABEL,"SADX("+(string)period+")");
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferSDIP,true);
   ArraySetAsSeries(BufferSDIM,true);
   ArraySetAsSeries(BufferSADX,true);
   ArraySetAsSeries(BufferDIPtmp,true);
   ArraySetAsSeries(BufferDIMtmp,true);
   ArraySetAsSeries(BufferADXtmp,true);
   ArraySetAsSeries(BufferDIP,true);
   ArraySetAsSeries(BufferDIM,true);
   ArraySetAsSeries(BufferADX,true);
//--- create ADX handle
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX (",(string)period,") object was not created: Error ",GetLastError());
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
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferSDIP,EMPTY_VALUE);
      ArrayInitialize(BufferSDIM,EMPTY_VALUE);
      ArrayInitialize(BufferSADX,EMPTY_VALUE);
      ArrayInitialize(BufferDIPtmp,0);
      ArrayInitialize(BufferDIMtmp,0);
      ArrayInitialize(BufferADXtmp,0);
      ArrayInitialize(BufferDIP,0);
      ArrayInitialize(BufferDIM,0);
      ArrayInitialize(BufferADX,0);
     }
//--- Подготовка данных
   int count=(limit>0 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,PLUSDI_LINE,0,count,BufferDIP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_adx,MINUSDI_LINE,0,count,BufferDIM);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDIPtmp[i]=2.0*BufferDIP[i]+(alpha1-2.0)*BufferDIP[i+1]+(1.0-alpha1)*BufferDIPtmp[i+1];
      BufferDIMtmp[i]=2.0*BufferDIM[i]+(alpha1-2.0)*BufferDIM[i+1]+(1.0-alpha1)*BufferDIMtmp[i+1];
      BufferADXtmp[i]=2.0*BufferADX[i]+(alpha1-2.0)*BufferADX[i+1]+(1.0-alpha1)*BufferADXtmp[i+1];

      BufferSDIP[i]=alpha2*BufferDIPtmp[i]+(1.0-alpha2)*BufferSDIP[i+1];
      BufferSDIM[i]=alpha2*BufferDIMtmp[i]+(1.0-alpha2)*BufferSDIM[i+1];
      BufferSADX[i]=alpha2*BufferADXtmp[i]+(1.0-alpha2)*BufferSADX[i+1];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
