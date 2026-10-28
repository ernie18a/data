//+------------------------------------------------------------------+
//|                                                       Renko2.mq5 |
//|                                Copyright 2018, Guilherme Santos. |
//|                                               fishguil@gmail.com |
//|                            Renko 2.0, A complete Renko indicator |
//|                                                                  |
//|2017-12-31:                                                       |
//| Implemented Bars History Input for better performance.           |
//|2018-01-04:                                                       |
//| Fixed: Array out of range exception for Bars History input.      |
//| Fixed: Invalid plot of two Renko bricks when pivot high.         |
//|2018-01-13:                                                       |
//| Fixed: Wick size on history and chart reload.                    |
//| Fixed: Wick malformed with brick size.                           |
//|2018-01-15:                                                       |
//| Fixed: Minimum brick size to one tick.                           |
//|2018-01-17:                                                       |
//| Implemented normal array buffer for better performance.          |
//| w/ Aécio F. Neto <aecio.neto@xcalper.com.br>                     |
//| Implemented chart reload algorithm and other corrections.        |
//|2018-03-08:                                                       |
//| Implemented Renko 2 class, Renko2 offline, custom symbol,        |
//| volumes, gap colors, and other modifications.                    |
//|2018-03-28:                                                       |
//| Fixed events and time from renko rates                           |
//|2018-09-27:                                                       |
//| Asymetric reversals, corrections on wick size and initialization |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Guilherme Santos."
#property link      "fishguil@gmail.com"
#property version   "2.0"
#property description "Renko 2.0, A complete Renko indicator"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4
// Renko plots
#property indicator_label1  "Renko Open;Renko High;Renko Low;Renko Close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrWhite, clrRed, clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
// Information plots
#property indicator_label2  "Tick Volume"
#property indicator_label3  "Volume"
#property indicator_label4  "Real Time"
#include <RenkoCharts.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input ENUM_RENKO_TYPE   RenkoType      = RENKO_TYPE_TICKS;     // Type
input double            RenkoSize      = 20;                   // Brick Size (Ticks, Pips or Points)
input bool              RenkoWicks     = true;                 // Show Wicks
input bool              RenkoTime      = true;                 // Brick Open Time
input bool              RenkoAsymetricReversal = false;        // Asymetric Reversals
//+------------------------------------------------------------------+
//| Internal variables and objects                                   |
//+------------------------------------------------------------------+
double open_buffer[],
   high_buffer[],
   low_buffer[],
   close_buffer[],
   color_buffer[],
   tick_volume_buffer[],
   real_volume_buffer[],
   time_buffer[];
RenkoCharts *RenkoOffline;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
// Buffer mapping
   SetIndexBuffer(0,open_buffer,INDICATOR_DATA);
   SetIndexBuffer(1,high_buffer,INDICATOR_DATA);
   SetIndexBuffer(2,low_buffer,INDICATOR_DATA);
   SetIndexBuffer(3,close_buffer,INDICATOR_DATA);
   SetIndexBuffer(4,color_buffer,INDICATOR_COLOR_INDEX);
// Extra buffers
   SetIndexBuffer(5,tick_volume_buffer,INDICATOR_DATA);
   SetIndexBuffer(6,real_volume_buffer,INDICATOR_DATA);
   SetIndexBuffer(7,time_buffer,INDICATOR_DATA);
// Levels
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
// Setup Renko
   //Setup Renko
   if (RenkoOffline == NULL) 
      if ((RenkoOffline = new RenkoCharts()) == NULL)
        {
         MessageBox("Renko create class error. Check error log!", __FILE__, MB_OK);
         return(INIT_FAILED);
        }
   if (!RenkoOffline.Setup(_Symbol, RenkoType, RenkoSize, RenkoWicks, RenkoTime, RenkoAsymetricReversal))
     {
      MessageBox("Renko setup error. Check error log!", __FILE__, MB_OK);
      return(INIT_FAILED);
     }
   RenkoOffline.UpdateRates();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(RenkoOffline!=NULL)
     {
      RenkoOffline.Stop();
      delete RenkoOffline;
      RenkoOffline=NULL;
     }  
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
// Get buffer size
   static int prev_total = 0;
   int index = rates_total - 1;
   int total = RenkoOffline.UpdateRates();
   if(total<=0) return(0);
// Fill indicator buffers
   if(rates_total != prev_calculated || total != prev_total)
   for(int i=index, j=total-1; i>0 && j>0; i--, j--)
     {
      open_buffer[i] = RenkoOffline.GetValue(1, j);
      high_buffer[i] = RenkoOffline.GetValue(2, j);
      low_buffer[i] = RenkoOffline.GetValue(3, j);
      close_buffer[i] = RenkoOffline.GetValue(4, j);
      close_buffer[i-1] = RenkoOffline.GetValue(4, j-1);
      // Custom buffers
      tick_volume_buffer[i] = RenkoOffline.GetValue(5, j);
      real_volume_buffer[i] = RenkoOffline.GetValue(6, j);
      time_buffer[i] = RenkoOffline.GetValue(0, j);
      // Color buffer
      if(tick_volume_buffer[i]==0)
         color_buffer[i] = 0;
      else if(close_buffer[i]>close_buffer[i-1])
         color_buffer[i] = 2;
      else
         color_buffer[i] = 1;
     }
   prev_total = total;
//Current bar
   open_buffer[index] = RenkoOffline.GetValue(1, total-1);
   high_buffer[index] = RenkoOffline.GetValue(2, total-1);
   low_buffer[index] = RenkoOffline.GetValue(3, total-1);
   close_buffer[index] = RenkoOffline.GetValue(4, total-1);
   color_buffer[index] = color_buffer[index-1];
// Custom buffers
   tick_volume_buffer[index] = RenkoOffline.GetValue(5, total-1);
   real_volume_buffer[index] = RenkoOffline.GetValue(6, total-1);
   time_buffer[index] = RenkoOffline.GetValue(0, total-1);
// Indicator level
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,price[index]);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
