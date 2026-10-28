//+------------------------------------------------------------------+
//|                                   Heiken Ashi On Adaptive MA.mq5 |
//|                                                        extern.fx |
//|                                              extern.fx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "extern.fx"
#property link      "extern.fx@gmail.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   1
//--- plot HeikenAshiOnAMA
#property indicator_label1  "HeikenAshiOnAMA"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  Blue, Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label1  "Heiken Ashi Open;Heiken Ashi High;Heiken Ashi Low;Heiken Ashi Close"
//--- input parameters
input int      AMAPeriod=9;
input int      FastEMA = 2;
input int      SlowEMA = 30;
input int      AMAShift= 0;
//--- indicator buffers
double         extOpen[];
double         extClose[];
double         extHigh[];
double         extLow[];
double         extColor[];
double AMAOpen[];
double AMAClose[];
double AMAHigh[];
double AMALow[];

int AMAOpenHandle;
int AMACloseHandle;
int AMAHighHandle;
int AMALowHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,extOpen,INDICATOR_DATA);
   SetIndexBuffer(3,extClose,INDICATOR_DATA);
   SetIndexBuffer(1,extHigh,INDICATOR_DATA);
   SetIndexBuffer(2,extLow,INDICATOR_DATA);
   SetIndexBuffer(4,extColor,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,AMAOpen,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,AMAClose,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,AMAHigh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,AMALow,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"Heiken Ashi");
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   AMAOpenHandle=iAMA(_Symbol,_Period,AMAPeriod,FastEMA,SlowEMA,AMAShift,PRICE_OPEN);
   AMACloseHandle= iAMA(_Symbol,_Period,AMAPeriod,FastEMA,SlowEMA,AMAShift,PRICE_CLOSE);
   AMAHighHandle = iAMA(_Symbol,_Period,AMAPeriod,FastEMA,SlowEMA,AMAShift,PRICE_HIGH);
   AMALowHandle=iAMA(_Symbol,_Period,AMAPeriod,FastEMA,SlowEMA,AMAShift,PRICE_LOW);
   ArraySetAsSeries(extOpen,true);
   ArraySetAsSeries(extClose,true);
   ArraySetAsSeries(extHigh,true);
   ArraySetAsSeries(extLow,true);
   ArraySetAsSeries(AMAOpen,true);
   ArraySetAsSeries(AMAClose,true);
   ArraySetAsSeries(AMAHigh,true);
   ArraySetAsSeries(AMALow,true);
   return(0);
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
//---
//--- return value of prev_calculated for next call
   int copy_count;
   if(prev_calculated==0) copy_count=rates_total-SlowEMA;
   else copy_count=rates_total-prev_calculated+1;
   if(CopyBuffer(AMAOpenHandle,0,0,copy_count,AMAOpen)<0)
     {
      Print("HeikenAshiOnAMA: ошибка копирования буфера индикатора...");
      return(1);
     }
   if(CopyBuffer(AMACloseHandle,0,0,copy_count,AMAClose)<0)
     {
      Print("HeikenAshiOnAMA: ошибка копирования буфера индикатора...");
      return(1);
     }
   if(CopyBuffer(AMAHighHandle,0,0,copy_count,AMAHigh)<0)
     {
      Print("HeikenAshiOnAMA: ошибка копирования буфера индикатора...");
      return(1);
     }
   if(CopyBuffer(AMALowHandle,0,0,copy_count,AMALow)<0)
     {
      Print("HeikenAshiOnAMA: ошибка копирования буфера индикатора...");
      return(1);
     }
   int total=rates_total-SlowEMA;
   if(prev_calculated==0)
     {
      extOpen[total]=AMAOpen[total];
      extClose[total]= AMAClose[total];
      extHigh[total] = AMAHigh[total];
      extLow[total]=AMALow[total];
      total++;
     }
   else total = rates_total - prev_calculated + 1;
   for( int i = total; i >= 0; i-- )
     {
      double haOpen=(extOpen[i+1]+extClose[i+1])/2;
      double haClose=(AMAOpen[i]+AMAClose[i]+AMAHigh[i]+AMAClose[i])/4;
      double haHigh = MathMax(AMAHigh[i],MathMax(haOpen,haClose));
      double haLow=MathMin(AMALow[i],MathMin(haOpen,haClose));

      extOpen[i]=haOpen;
      extClose[i]=haClose;
      extHigh[i]=haHigh;
      extLow[i]=haLow;
      if(haOpen<haClose) extColor[i]=0.0; // set color DodgerBlue
      else extColor[i]=1.0; // set color Red
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
