# Everex Lite (Effort vs Result Participation)

- url: https://www.tradingview.com/script/aNEZKkTL-Everex-Lite-Effort-vs-Result-Participation/
- type: indicator
- pine_id: PUB;a01d3947cc4c4847826c200901e5c6d5
- version: 1.0

## Description

Everex Lite is a streamlined Effort vs Result participation indicator inspired by the original RedK Everex concept.

The indicator measures the relationship between market participation (effort) and price movement (result) to help traders visualize how efficiently price is moving through the auction.

Rather than focusing solely on volume or momentum, Everex Lite evaluates whether price progress is being supported by participation. This can help identify conditions such as:

• Strong participation supporting directional movement
• Absorption and stalled auctions
• Weakening momentum
• Thin liquidity moves
• Potential shifts in participation strength

Everex Lite intentionally removes several components from the original implementation to create a cleaner and easier-to-read display. The result is a lightweight tool that focuses on the core Rate of Flow (ROF) model and Signal Line while reducing visual clutter.

Features:

• Simplified Rate of Flow (ROF) calculation
• Optional Line or Histogram display modes
• Configurable Signal Line
• Multiple moving average types (WMA, EMA, SMA, HMA, RMA)
• Optional participation levels
• Clean, lightweight design

This indicator is best used alongside market structure, VWAP, volume profile, support/resistance levels, and Auction Market Theory concepts.

Everex Lite is not designed as a standalone buy or sell signal. Instead, it provides additional context regarding participation and price efficiency to help traders better understand the auction taking place beneath the chart.

Credits:

This indicator is a simplified derivative of the original RedK Everex indicator. Full credit for the original Effort vs Result implementation belongs to RedK.

If you find the indicator useful, please leave a like and share your feedback.

## Source Code

````pine
//=====================================================================
//  Indicator: Everex Lite — Effort vs Result Participation
//  Author: Christopher C. Berg
//  TradingView: cChristopherBergTraderWorkshop
//  Version: 1.0.1
//  Initial Release: March 2026
//=====================================================================
//
//  Inspired by the original "RedK Everex" indicator by RedK
//
//---------------------------------------------------------------------
//  OVERVIEW
//---------------------------------------------------------------------
//  Everex Lite is a streamlined Effort vs Result participation
//  indicator designed to visualize the relationship between market
//  activity and price movement.
//
//  This script focuses on the core Rate of Flow (ROF) model from the
//  original RedK Everex indicator while removing additional elements
//  in order to create a cleaner and easier-to-read visualization.
//
//  The goal of Everex Lite is to highlight how efficiently price is
//  moving by comparing directional participation with actual price
//  progress.
//
//---------------------------------------------------------------------
//  EFFORT VS RESULT CONCEPT
//---------------------------------------------------------------------
//  The Effort vs Result principle originates from the work of
//  market technician Richard D. Wyckoff,
//  where traders analyze the relationship between:
//
//     • Effort  → market participation and activity
//     • Result  → the amount of price progress achieved
//
//  When effort and result diverge, it can reveal hidden market
//  dynamics such as absorption, weakening momentum, or thin liquidity.
//
//  Examples:
//
//     • Strong effort with little progress → possible absorption
//     • Large price movement with low effort → thin liquidity
//     • Expanding effort with price progress → healthy trend
//
//---------------------------------------------------------------------
//  INDICATOR STRUCTURE
//---------------------------------------------------------------------
//  Everex Lite focuses on two primary components:
//
//     • Rate of Flow (ROF)
//       Measures directional participation based on price behavior.
//
//     • Signal Line
//       A smoothed version of ROF used to identify shifts in
//       participation momentum.
//
//  A central zero line separates bullish and bearish participation.
//  Optional levels help identify stronger participation extremes.
//
//---------------------------------------------------------------------
//  DESIGN PHILOSOPHY
//---------------------------------------------------------------------
//  This version intentionally removes several features from the
//  original RedK implementation in order to prioritize:
//
//     • visual clarity
//     • reduced indicator noise
//     • faster chart performance
//
//  Everex Lite is designed to complement structural tools such as:
//
//     • VWAP
//     • market structure levels
//     • volume profile
//     • auction market analysis
//
//---------------------------------------------------------------------
//  ATTRIBUTION
//---------------------------------------------------------------------
//  This indicator is a simplified derivative of the original
//  "RedK Everex" indicator created by RedK on TradingView.
//
//  Full credit for the original Effort vs Result implementation
//  belongs to the RedK script author.
//
//---------------------------------------------------------------------
//  DISCLAIMER
//---------------------------------------------------------------------
//  This script is provided for educational and informational purposes
//  only. It does not constitute financial, investment, or trading
//  advice.
//
//  All trading involves risk. Users are solely responsible for their
//  own analysis, decisions, and trading results.
//
//---------------------------------------------------------------------
//  COPYRIGHT
//---------------------------------------------------------------------
//  © 2026 Christopher C. Berg. All rights reserved.
//
//  Unauthorized redistribution, resale, or commercial reuse of this
//  script is prohibited without the express permission of the author.
//=====================================================================

//@version=6

indicator('Everex Lite — Effort vs Result Participation', precision = 0,
  timeframe = '', timeframe_gaps = false, explicit_plot_zorder = true)

// ***********************************************************************************************************
// Selectable average type
GetAverage(_data, _len, MAOption) =>
    value = switch MAOption
        'SMA' => ta.sma(_data, _len)
        'EMA' => ta.ema(_data, _len)
        'HMA' => ta.hma(_data, _len)
        'RMA' => ta.rma(_data, _len)
        => ta.wma(_data, _len)
    value

// ========================================================================================
// Normalization function
Normalize(_Value, _Avg) =>
    _safeAvg = math.max(_Avg, 0.0000001)
    _X = _Value / _safeAvg
    _Nor =
      _X > 1.50 ? 1.00 :
      _X > 1.20 ? 0.90 :
      _X > 1.00 ? 0.80 :
      _X > 0.80 ? 0.70 :
      _X > 0.60 ? 0.60 :
      _X > 0.40 ? 0.50 :
      _X > 0.20 ? 0.25 :
      0.10
    _Nor
// ===========================================================================================================
// Inputs (ROF + Signal only)
// ===========================================================================================================
grp_1 = 'Rate of Flow (RoF)'

length   = input.int(10, minval = 1, inline = 'ROF', group = grp_1)
MA_Type  = input.string(defval = 'WMA', title = 'MA type',
  options = ['WMA', 'EMA', 'SMA', 'HMA', 'RMA'], inline = 'ROF', group = grp_1)
smooth   = input.int(defval = 3, title = 'Smooth', minval = 1, inline = 'ROF', group = grp_1)

sig_length = input.int(5, 'Signal Length', minval = 1, inline = 'Signal', group = grp_1)
S_Type     = input.string(defval = 'WMA', title = 'Signal Type',
  options = ['WMA', 'EMA', 'SMA', 'HMA', 'RMA'], inline = 'Signal', group = grp_1)

lookback  = input.int(defval = 20, title = 'Lookback (Normalization)', minval = 1, group = grp_1)
lkbk_Calc = input.string(defval = 'Simple', title = 'Lookback Averaging',
  options = ['Simple', 'Same as ROF'], group = grp_1)

// ===========================================================================================================
// Calculations
// ===========================================================================================================

// Volume effort (handles symbols with no volume)
v          = na(volume) ? 1.0 : volume
NoVol_Flag = na(volume)

lkbk_MA_Type = lkbk_Calc == 'Simple' ? 'SMA' : MA_Type

Vola       = GetAverage(v, lookback, lkbk_MA_Type)
Vola_n_pre = Normalize(v, Vola) * 100
Vola_n     = NoVol_Flag ? 100 : Vola_n_pre

// Price result components
BarSpread   = close - open
BarRange    = high - low
R2          = ta.highest(high, 2) - ta.lowest(low, 2)
SrcShift    = ta.change(close)

sign_shift  = math.sign(SrcShift)
sign_spread = math.sign(BarSpread)

// In-bar
eps        = 0.0000001
safeRange  = math.max(BarRange, eps)
safeR2     = math.max(R2, eps)

barclosing = 2 * (close - low) / safeRange * 100 - 100
s2r        = BarSpread / safeRange * 100

barclosing_2  = 2 * (close - ta.lowest(low, 2)) / safeR2 * 100 - 100
Shift2Bar_toR2 = SrcShift / safeR2 * 100

BarSpread_abs     = math.abs(BarSpread)
BarSpread_avg     = GetAverage(BarSpread_abs, lookback, lkbk_MA_Type)
BarSpread_ratio_n = Normalize(BarSpread_abs, BarSpread_avg) * 100 * sign_spread

SrcShift_abs     = math.abs(SrcShift)
srcshift_avg     = GetAverage(SrcShift_abs, lookback, lkbk_MA_Type)
srcshift_ratio_n = Normalize(SrcShift_abs, srcshift_avg) * 100 * sign_shift

// Relative Price Strength
Pricea_n  = (barclosing + s2r + BarSpread_ratio_n + barclosing_2 + Shift2Bar_toR2 + srcshift_ratio_n) / 6

// Bar flow
bar_flow  = Pricea_n * Vola_n / 100

// ROF (RSI-style separation)
bulls     = math.max(bar_flow, 0)
bears     = -1 * math.min(bar_flow, 0)

bulls_avg = GetAverage(bulls, length, MA_Type)
bears_avg = GetAverage(bears, length, MA_Type)

dx        = bulls_avg / math.max(bears_avg, eps)
RROF      = 2 * (100 - 100 / (1 + dx)) - 100
RROF_s    = ta.wma(RROF, smooth)

Signal    = GetAverage(RROF_s, sig_length, S_Type)

// ===========================================================================================================
// Plots
// ===========================================================================================================
c_zero  = color.new(#0058fb, 0)
c_level = color.new(#8e8d8d, 50)
c_rof   = color.yellow

// Editable levels
ShowLevels  = input.bool(false, "Show Levels", inline = "lvl")
lvl         = input.int(25, "Level", inline = "lvl", minval = 1)

// Zero + Levels
hline(0, "Zero Line", c_zero, linestyle = hline.style_dashed)
plot(ShowLevels ?  lvl : na, "+Level", color = c_level, linewidth = 1)
plot(ShowLevels ? -lvl : na, "-Level", color = c_level, linewidth = 1)

// Display mode
displayMode = input.string("Line", "ROF Display", options = ["Line", "Histogram"])

// ROF colors
histColor = RROF_s >= 0 ? color.lime : color.red

// Signal
plot(displayMode == "Line" ? Signal : na, "Signal Line", color = color.new(#737373, 0), linewidth = 1)

// ROF
plot(displayMode == "Line" ? RROF_s : na, "ROF Line", color = c_rof, linewidth = 4)
plot(displayMode == "Histogram" ? RROF_s : na, "ROF Histogram", color = histColor, linewidth = 3, style = plot.style_histogram)

// MCP-readable values — data window only, invisible on chart
plot(RROF_s, "ROF Value", display = display.data_window)
plot(Signal, "Signal Value", display = display.data_window)
````
