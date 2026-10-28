//+------------------------------------------------------------------+
//|                                                         WRPC.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   6
//--- plot Upper
#property indicator_label1  "Upper overbought"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot OverBought
#property indicator_label2  "Overbought zone"
#property indicator_type2   DRAW_HISTOGRAM2
#property indicator_color2  clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot NeutralUP
#property indicator_label3  "Neutral Up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot NeutralDN
#property indicator_label4  "Neutral Down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDeepSkyBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot OverSold
#property indicator_label5  "Oversold zone"
#property indicator_type5   DRAW_HISTOGRAM2
#property indicator_color5  clrDeepSkyBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Lower
#property indicator_label6  "Lower oversold"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrDeepSkyBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width6  1
//--- input parameters
input uint                 InpPeriod         =  34;               // Channels period
input uint                 InpSmoothing      =  14;               // Period of smoothing
input double               InpOverBought     =  70.0;             // Overbought level
input double               InpUpperNeutral   =  55.0;             // Upper level of neutral zone
input double               InpLowerNeutral   =  45.0;             // Lower level of neutral zone
input double               InpOverSold       =  30.0;             // Oversold level
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;      // Applied price
input color                InpColorOverbough =  clrDeepSkyBlue;   // Color of overbought zone
input color                InpColorOversold  =  clrDarkOrange;    // Color of oversold zone
//--- indicator buffers
double         BufferUpper[];
double         BufferOverBought1[];
double         BufferOverBought2[];
double         BufferNeutralUP[];
double         BufferNeutralDN[];
double         BufferOverSold1[];
double         BufferOverSold2[];
double         BufferLower[];
double         BufferRSI[];
double         BufferMAOnRSI[];
double         BufferMA1[];
//--- global variables
int            handle_rsi;
int            handle_ma_on_rsi;
int            handle_ma1;
int            period;
int            smoothing;
double         overbough;
double         upper_neutral;
double         lower_neutral;
double         oversold;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   smoothing=int(InpSmoothing<1 ? 1 : InpSmoothing);
   overbough=(InpOverBought<1 ? 1 : InpOverBought>99.9 ? 99.9 : InpOverBought);                 // >=1.0   overbough   <=99.9 
   upper_neutral=(InpUpperNeutral<0.5 ? 0.5 : InpUpperNeutral>99.5 ? 99.5 : InpUpperNeutral);   // >=0.5 upper_neutral <=99.5
   lower_neutral=(InpLowerNeutral<0.5 ? 0.5 : InpLowerNeutral> 99.5 ? 99.5 : InpLowerNeutral);  // >=0.5 lower_neutral <=99.5
   oversold=(InpOverSold<0.1 ? 0.1 : InpOverSold>99 ? 99 : InpOverSold);                        // >=0.1   oversold    <=99.0
//--- correction of the overbought zone offset
   if(overbough<=upper_neutral) upper_neutral=overbough-0.1;
   if(upper_neutral<=lower_neutral) lower_neutral=upper_neutral-0.1;
   if(lower_neutral<-oversold) oversold=lower_neutral-0.1;
//--- correction of the oversold zone offset
   if(oversold>=lower_neutral) lower_neutral=oversold+0.1;
   if(lower_neutral>=upper_neutral) upper_neutral=lower_neutral+0.1;
   if(upper_neutral>=overbough) overbough=upper_neutral+0.1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpper,INDICATOR_DATA);
   SetIndexBuffer(1,BufferOverBought1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferOverBought2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferNeutralUP,INDICATOR_DATA);
   SetIndexBuffer(4,BufferNeutralDN,INDICATOR_DATA);
   SetIndexBuffer(5,BufferOverSold1,INDICATOR_DATA);
   SetIndexBuffer(6,BufferOverSold2,INDICATOR_DATA);
   SetIndexBuffer(7,BufferLower,INDICATOR_DATA);
   SetIndexBuffer(8,BufferRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferMAOnRSI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferMA1,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Wilson relative price channel");
//--- setings parameters for plot buffers
   for(uchar i=0; i<8; i++)
     {
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,period);
      PlotIndexSetInteger(i,PLOT_LINE_COLOR,(i<3 ? InpColorOverbough : InpColorOversold));
     }
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUpper,true);
   ArraySetAsSeries(BufferOverBought1,true);
   ArraySetAsSeries(BufferOverBought2,true);
   ArraySetAsSeries(BufferNeutralUP,true);
   ArraySetAsSeries(BufferNeutralDN,true);
   ArraySetAsSeries(BufferOverSold1,true);
   ArraySetAsSeries(BufferOverSold2,true);
   ArraySetAsSeries(BufferLower,true);
   ArraySetAsSeries(BufferRSI,true);
   ArraySetAsSeries(BufferMAOnRSI,true);
   ArraySetAsSeries(BufferMA1,true);
//--- Creating the RSI, MA, MA1 handles
   ResetLastError();
   handle_rsi=iRSI(Symbol(),PERIOD_CURRENT,period,InpAppliedPrice);
   if(handle_rsi==INVALID_HANDLE)
     {
      Print("The iRSI(",(string)period,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ma_on_rsi=iMA(Symbol(),PERIOD_CURRENT,smoothing,0,MODE_EMA,handle_rsi);
   if(handle_ma_on_rsi==INVALID_HANDLE)
     {
      Print("The iMAOnRSI(",(string)smoothing,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   ResetLastError();
   handle_ma1=iMA(Symbol(),PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma1==INVALID_HANDLE)
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<period+smoothing) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferUpper,EMPTY_VALUE);
      ArrayInitialize(BufferOverBought1,0);
      ArrayInitialize(BufferNeutralUP,EMPTY_VALUE);
      ArrayInitialize(BufferNeutralDN,EMPTY_VALUE);
      ArrayInitialize(BufferOverSold1,EMPTY_VALUE);
      ArrayInitialize(BufferOverSold2,EMPTY_VALUE);
      ArrayInitialize(BufferLower,EMPTY_VALUE);
      ArrayInitialize(BufferRSI,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_rsi,0,0,count,BufferRSI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma_on_rsi,0,0,count,BufferMAOnRSI);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_ma1,0,0,count,BufferMA1);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      double MA=BufferMAOnRSI[i];
      double MA0=BufferMA1[i];
      BufferOverBought1[i]=BufferUpper[i]=MA0*(1-(MA-overbough)/100.0);
      BufferOverBought2[i]=BufferNeutralUP[i]=MA0*(1.0-(MA-upper_neutral)/100.0);
      BufferOverSold1[i]=BufferNeutralDN[i]=MA0*(1.0-(MA-lower_neutral)/100.0);
      BufferOverSold2[i]=BufferLower[i]=MA0*(1.0-(MA-oversold)/100.0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
