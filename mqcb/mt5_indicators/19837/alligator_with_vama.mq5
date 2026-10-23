//+------------------------------------------------------------------+
//|                                          Alligator_With_VAMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Jaws
#property indicator_label1  "Jaws"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Teeth
#property indicator_label2  "Teeth"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Lips
#property indicator_label3  "Lips"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input uint                 InpPeriodJaws     =  13;            // Period of Jaws line
input int                  InpShiftJaws      =  8;             // Shift of Jaws line
input uint                 InpPeriodTeeth    =  8;             // Period of Teeth line
input int                  InpShiftTeeth     =  5;             // Shift of Teeth line
input uint                 InpPeriodLips     =  5;             // Period of Lips line
input int                  InpShiftLips      =  3;             // Shift of Lips line
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferJaws[];
double         BufferTeeth[];
double         BufferLips[];
//--- global variables
int            period_jaws;
int            period_teeth;
int            period_lips;
int            handle_jaws;
int            handle_teeth;
int            handle_lips;
int            bars_minimum;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set parameters
   period_jaws=int(InpPeriodJaws<1 ? 1 : InpPeriodJaws);
   period_teeth=int(InpPeriodTeeth<1 ? 1 : InpPeriodTeeth);
   period_lips=int(InpPeriodLips<1 ? 1 : InpPeriodLips);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferJaws,INDICATOR_DATA);
   SetIndexBuffer(1,BufferTeeth,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLips,INDICATOR_DATA);
//--- set indicators parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Alligator with VAMA");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_jaws-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period_teeth-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,period_lips-1);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,InpShiftJaws);
   PlotIndexSetInteger(1,PLOT_SHIFT,InpShiftTeeth);
   PlotIndexSetInteger(2,PLOT_SHIFT,InpShiftLips);
//---- name for DataWindow 
   PlotIndexSetString(0,PLOT_LABEL,"Jaws("+string(period_jaws)+")");
   PlotIndexSetString(1,PLOT_LABEL,"Teeth("+string(period_teeth)+")");
   PlotIndexSetString(2,PLOT_LABEL,"Lips("+string(period_lips)+")");
//--- setting buffers as timeseries
   ArraySetAsSeries(BufferJaws,true);
   ArraySetAsSeries(BufferTeeth,true);
   ArraySetAsSeries(BufferLips,true);
//--- get VAMA's handles
   ResetLastError();
   handle_jaws=iCustom(Symbol(),PERIOD_CURRENT,"VAMA",period_jaws,InpAppliedPrice);
   if(handle_jaws==INVALID_HANDLE){
      Print("Error creating VAMA indicator handle for Javs line: ",GetLastError());
      }
   ResetLastError();
   handle_teeth=iCustom(Symbol(),PERIOD_CURRENT,"VAMA",period_teeth,InpAppliedPrice);
   if(handle_jaws==INVALID_HANDLE){
      Print("Error creating VAMA indicator handle for Teeth line: ",GetLastError());
      }
   ResetLastError();
   handle_lips=iCustom(Symbol(),PERIOD_CURRENT,"VAMA",period_lips,InpAppliedPrice);
   if(handle_jaws==INVALID_HANDLE){
      Print("Error creating VAMA indicator handle for Lips line: ",GetLastError());
      }
//--- bars minimum for calculation
   bars_minimum=period_jaws+InpShiftJaws;
   if(bars_minimum<(period_teeth+InpShiftTeeth))
      bars_minimum=period_teeth+InpShiftTeeth;
   if(bars_minimum<(period_lips*2))
      bars_minimum=period_lips*2;
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
   if(rates_total<bars_minimum) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferJaws,EMPTY_VALUE);
      ArrayInitialize(BufferTeeth,EMPTY_VALUE);
      ArrayInitialize(BufferLips,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   int copied=(limit>1 ? rates_total : 1);
   //--- Jaws
   int copied_jaws=CopyBuffer(handle_jaws,0,0,copied,BufferJaws);
   if(copied_jaws!=copied) return 0;
   //--- Teeth
   int copied_teeth=CopyBuffer(handle_teeth,0,0,copied,BufferTeeth);
   if(copied_teeth!=copied) return 0;
   //--- Lips
   int copied_lips=CopyBuffer(handle_lips,0,0,copied,BufferLips);
   if(copied_lips!=copied) return 0;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
