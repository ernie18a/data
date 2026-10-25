//+------------------------------------------------------------------+
//|                                                        MaDev.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Deviation from MA indicator"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Up
#property indicator_label2  "Upper max dev"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Dn
#property indicator_label3  "Lower max dev"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_MA_METHOD       InpMethod         =  MODE_EMA;      // Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpFrame          =  3;             // Frames
//--- indicator buffers
double         BufferMA[];
double         BufferUp[];
double         BufferDn[];
double         BufferPrice[];
double         BufferDev[];
//--- global variables
int            period;
int            shift;
int            frame;
int            handle_ma1;
int            handle_maP;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   frame=int(InpFrame<2 ? 2 : InpFrame);
   shift=(int)floor((frame-1.0)/2.0);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferUp,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDn,INDICATOR_DATA);
   SetIndexBuffer(3,BufferPrice,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferDev,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"MaDev ("+(string)period+","+(string)frame+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferUp,true);
   ArraySetAsSeries(BufferDn,true);
   ArraySetAsSeries(BufferPrice,true);
   ArraySetAsSeries(BufferDev,true);
//--- create handles
   ResetLastError();
   handle_ma1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
     {
      Print("The iMA(1) by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maP=iMA(NULL,PERIOD_CURRENT,period,0,InpMethod,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period,") by ",EnumToString(InpAppliedPrice)," object was not created: Error ",GetLastError());
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
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<fmax(shift,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2*shift-2;
      ArrayInitialize(BufferMA,EMPTY_VALUE);
      ArrayInitialize(BufferUp,EMPTY_VALUE);
      ArrayInitialize(BufferDn,EMPTY_VALUE);
      ArrayInitialize(BufferPrice,0);
      ArrayInitialize(BufferDev,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferPrice);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maP,0,0,count,BufferMA);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferDev[i]=BufferPrice[i]-BufferMA[i];
      bool min=true;
      bool max=true;
      for(int j=1; j<=shift; j++)
        {
         if(BufferDev[i+shift+1]>=BufferDev[i+j+shift+1] || BufferDev[i+shift+1]>=BufferDev[i-j+shift+1])
            min=false;
         if(BufferDev[i+shift+1]<=BufferDev[i+j+shift+1] || BufferDev[i+shift+1]<=BufferDev[i-j+shift+1])
            max=false;
        }
      BufferDn[i+shift+1]=(min && BufferDev[i+shift+1]<0 ? low[i+shift+1] : EMPTY_VALUE);
      BufferUp[i+shift+1]=(max && BufferDev[i+shift+1]>0 ? high[i+shift+1] : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
