//+------------------------------------------------------------------+
//|                                       Advanced_Fractal_On_MA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Advanced fractal on MA indicator"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
//--- plot UP
#property indicator_label1  "Lower Fractal"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Upper Fractal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Signal UP
#property indicator_label3  "Bullish signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Signal DN
#property indicator_label4  "Bearish signal"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input uint                 InpPeriod         =  20;         // MA period
input ENUM_MA_METHOD       InpMethod         =  MODE_SMA;   // MA method
input ENUM_APPLIED_PRICE   InpAppliedPriceUP =  PRICE_HIGH; // Upper applied price
input ENUM_APPLIED_PRICE   InpAppliedPriceDN =  PRICE_LOW;  // Lower applied price
input uint                 InpFrames         =  5;          // Frames
//--- indicator buffers
double         BufferUPFR[];
double         BufferDNFR[];
double         BufferUPSig[];
double         BufferDNSig[];
double         BufferMAUP[];
double         BufferMADN[];
//--- global variables
int            period;
int            frames;
int            shift;
int            shift2;
int            handle_maup;
int            handle_madn;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   frames=int(InpFrames<3 ? 3 : InpFrames);
   shift=(int)floor((frames-1)/2);
   shift2=2*shift;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDNFR,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUPFR,INDICATOR_DATA);
   SetIndexBuffer(2,BufferUPSig,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDNSig,INDICATOR_DATA);
   SetIndexBuffer(4,BufferMAUP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferMADN,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,233);
   PlotIndexSetInteger(3,PLOT_ARROW,234);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Advanced fractal on MA ("+(string)period+","+(string)frames+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUPFR,true);
   ArraySetAsSeries(BufferDNFR,true);
   ArraySetAsSeries(BufferUPSig,true);
   ArraySetAsSeries(BufferDNSig,true);
   ArraySetAsSeries(BufferMAUP,true);
   ArraySetAsSeries(BufferMADN,true);
//--- create MA's handles
   ResetLastError();
   handle_maup=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPriceUP);
   if(handle_maup==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by ",EnumToString(InpAppliedPriceUP)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_madn=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPriceDN);
   if(handle_madn==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by ",EnumToString(InpAppliedPriceDN)," object was not created: Error ",GetLastError());
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
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(period,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-shift2-1;
      ArrayInitialize(BufferUPFR,EMPTY_VALUE);
      ArrayInitialize(BufferDNFR,EMPTY_VALUE);
      ArrayInitialize(BufferUPSig,EMPTY_VALUE);
      ArrayInitialize(BufferDNSig,EMPTY_VALUE);
      ArrayInitialize(BufferMAUP,0);
      ArrayInitialize(BufferMADN,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_maup,0,0,count,BufferMAUP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_madn,0,0,count,BufferMADN);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      if(IsUpFractal(i+shift))
        {
         BufferUPFR[i+shift]=high[i+shift];
         BufferDNSig[i]=open[i];
        }
      else
        {
         BufferUPFR[i+shift]=EMPTY_VALUE;
         BufferDNSig[i]=EMPTY_VALUE;
        }

      if(IsDnFractal(i+shift))
        {
         BufferDNFR[i+shift]=low[i+shift];
         BufferUPSig[i]=open[i];
        }
      else
        {
         BufferDNFR[i+shift]=EMPTY_VALUE;
         BufferUPSig[i]=EMPTY_VALUE;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsUpFractal(const int index)
  {
   bool find=true;
   for(int i=1; i<=shift; i++)
      if(BufferMAUP[index]<=BufferMAUP[index+i] || BufferMAUP[index]<=BufferMAUP[index-i])
         find=false;
   return find;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsDnFractal(const int index)
  {
   bool find=true;
   for(int i=1; i<=shift; i++)
      if(BufferMADN[index]>=BufferMADN[index+i] || BufferMADN[index]>=BufferMADN[index-i])
         find=false;
   return find;
  }
//+------------------------------------------------------------------+
