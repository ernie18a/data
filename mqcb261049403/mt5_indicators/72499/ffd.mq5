//+------------------------------------------------------------------+
//| FFD.mq5 — Fixed-Width Fractional Differencing Indicator          |
//| Copyright 2025, Patrick M. Njoroge                               |
//|                                                                  |
//| Draws the FFD series in a separate chart window.                 |
//| Uses the second form of OnCalculate for ENUM_APPLIED_PRICE       |
//| support — the indicator can fractionally differentiate any       |
//| price type (close, open, high, low, median, typical, weighted).  |
//+------------------------------------------------------------------+
#property copyright   "Patrick M. Njoroge"
#property version     "1.11"
#property description "Fixed-Width Fractional Differencing (FFD)"
#property description "López de Prado, AFML Chapter 5"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "FFD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Inputs
input double             InpD         = 0.4;         // Differencing order d
input double             InpThreshold = 1e-5;        // Weight cutoff threshold
input bool               InpUseLog    = true;        // Log-transform prices
input ENUM_APPLIED_PRICE InpPrice     = PRICE_CLOSE; // Applied price

//--- Include the computation engine from MQL5\Include\
#include <FFDEngine.mqh>

//--- Globals
double     FFDBuffer[];
CFFDEngine g_engine;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Set up indicator buffer
   SetIndexBuffer(0, FFDBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

//--- Initialize the FFD engine
   if(!g_engine.Init(InpD, InpThreshold, InpUseLog))
     {
      Print("FFD indicator: engine initialization failed");
      return INIT_FAILED;
     }

//--- Hide bars before the lookback window is filled
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, g_engine.GetWidth());

//--- Display name
   string short_name = StringFormat("FFD(%.2f)", InpD);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   IndicatorSetInteger(INDICATOR_DIGITS, 6);

   return INIT_SUCCEEDED;
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//| Second form: receives a single price[] array selected by         |
//| InpPrice (ENUM_APPLIED_PRICE). The terminal provides price[] in  |
//| chronological order (AsSeries = false), which is what            |
//| CFFDEngine::ComputeBuffer expects.                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   return g_engine.ComputeBuffer(price, FFDBuffer,
                                 rates_total, prev_calculated);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
