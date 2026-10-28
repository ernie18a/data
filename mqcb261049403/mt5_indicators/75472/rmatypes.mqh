//+------------------------------------------------------------------+
//|                                                     RmaTypes.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23693"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Shared vocabulary for the RMA engine, its panels and the EA.     |
//|                                                                  |
//|  Three parties have to agree on these: the indicator that fills  |
//|  the buffers, the passthrough panels that re-plot a subset of    |
//|  them, and the Expert that reads them back with CopyBuffer.      |
//|  Keeping the buffer map in one header is what stops those three  |
//|  from drifting apart silently — a reordered plot in the engine   |
//|  would otherwise leave the EA reading the wrong series with no   |
//|  compile error to warn anyone.                                   |
//+------------------------------------------------------------------+

//--- range regime, derived from the spread of normalised returns.
enum ENUM_RMA_REGIME
  {
   RMA_REGIME_EXPANSION,               // range widening
   RMA_REGIME_CONTRACTION,             // range narrowing
   RMA_REGIME_TO_CONTRACTION,          // expansion rolling over
   RMA_REGIME_TO_EXPANSION,            // contraction breaking out
   RMA_REGIME_UNKNOWN                  // warming up / not enough history
  };

//--- which leg of the cross the open position belongs to.
enum ENUM_RMA_CROSS_STATE
  {
   RMA_STATE_NONE,
   RMA_STATE_LONG_CROSS_REVERSE,
   RMA_STATE_SHORT_CROSS_REVERSE,
   RMA_STATE_LONG_CROSS_REVERT,
   RMA_STATE_SHORT_CROSS_REVERT,
   RMA_STATE_TREND_FOLLOW_LONG,        // entered long after a short was blocked
   RMA_STATE_TREND_FOLLOW_SHORT        // entered short after a long was blocked
  };

//+------------------------------------------------------------------+
//| Engine buffer map.                                               |
//|                                                                  |
//|  Order is not free, for two reasons. MQL5 assigns plots to       |
//|  buffer indices in declaration order, so every plotted series    |
//|  must sit ahead of every calculation-only series. And plots are  |
//|  drawn in index order, later over earlier — which is why the     |
//|  regime band comes first: it is a full-height histogram meant    |
//|  to sit behind the fractile lines, and at any later index it     |
//|  would paint over them instead.                                  |
//|                                                                  |
//|  Adding a plot therefore means inserting before RMA_BUF_SMA and  |
//|  bumping indicator_plots — not appending at the end.             |
//+------------------------------------------------------------------+
enum ENUM_RMA_BUFFER
  {
//--- plotted by the engine (keep first, in plot order)
   RMA_BUF_REGIME_BG       = 0,        // full-height bar, drawn as the backdrop
   RMA_BUF_REGIME_COLOR    = 1,        // colour index into the regime palette
   RMA_BUF_FW              = 2,        // fractile of the window's last normalised return
   RMA_BUF_FMIN            = 3,        // fractile of the window minimum
   RMA_BUF_FMAX            = 4,        // fractile of the window maximum
   RMA_BUF_ALPHA_LO_MEAN   = 5,        // EMA of the lower alpha bound
   RMA_BUF_ALPHA_HI_MEAN   = 6,        // EMA of the upper alpha bound
//--- calculation only, read via CopyBuffer
   RMA_BUF_SMA             = 7,
   RMA_BUF_RMA_W           = 8,        // sma/last  - 1
   RMA_BUF_RMA_1           = 9,        // sma/first - 1
   RMA_BUF_RMA_MID         = 10,       // sma/mid   - 1
   RMA_BUF_RMA_MIN         = 11,       // sma/min   - 1
   RMA_BUF_RMA_MAX         = 12,       // sma/max   - 1
   RMA_BUF_RANGE           = 13,       // spread of normalised returns
   RMA_BUF_ALPHA_LO        = 14,       // raw lower alpha bound
   RMA_BUF_ALPHA_HI        = 15,       // raw upper alpha bound
   RMA_BUF_REGIME          = 16,       // ENUM_RMA_REGIME as a double
   RMA_BUF_D_K             = 17,       // directional consistency of d_med_w
   RMA_BUF_D_MED_W         = 18,       // f_w - 0.5
//--- sentinel
   RMA_BUF_TOTAL           = 19
  };

//--- plots the engine declares. The regime band is one plot built
//--- from two buffers; the remaining five are plain lines.
#define RMA_PLOT_COUNT   6

//--- colour slots in the regime palette, in ENUM_RMA_REGIME order.
#define RMA_REGIME_COLORS 5

//+------------------------------------------------------------------+
//| Which group of buffers a passthrough panel should draw.          |
//+------------------------------------------------------------------+
enum ENUM_RMA_PANEL_MODE
  {
   RMA_PANEL_ADVERSE,                  // D_k and d_med_w
   RMA_PANEL_RMA_VALUES                // rma_w / rma_min / rma_max
  };

//+------------------------------------------------------------------+
//| Human-readable regime name.                                      |
//+------------------------------------------------------------------+
string RmaRegimeName(ENUM_RMA_REGIME r)
  {
   switch(r)
     {
      case RMA_REGIME_EXPANSION:
         return "expansion";
      case RMA_REGIME_CONTRACTION:
         return "contraction";
      case RMA_REGIME_TO_CONTRACTION:
         return "to-contraction";
      case RMA_REGIME_TO_EXPANSION:
         return "to-expansion";
      case RMA_REGIME_UNKNOWN:
         return "unknown";
     }
   return "unknown";
  }

//+------------------------------------------------------------------+
