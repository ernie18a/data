# Bias & Sweep Dashboard

- url: https://www.tradingview.com/script/3Dxwvteo-Bias-Sweep-Dashboard/
- type: indicator
- pine_id: PUB;861f66b1b245442d8e1fb332f624f0ca
- version: 1.0

## Description

1. Inputs & Configuration
Timeframes: Allows you to set the Higher Time Frame (HTF) (default: Daily / D) and the Intermediate/Lower Time Frame (ITF) (default: 4H / 240).
Sweep Settings: Features a customizable Swing Lookback input (default: 10 bars) to determine the structural swing points.
Table Settings: Allows configuration of the visual dashboard placement on the screen (Top Right, Bottom Left, etc.) along with background and text color styling.
2. Detection Logic
Pivots & Liquidity Sweeps:
Finds swing highs and swing lows using ta.pivothigh() and ta.pivotlow().
A Sweep is triggered when a candle's wick breaks past a key swing high/low, but the candle close returns back inside (denoting rejection of liquidity).
Uses request.security() to evaluate these sweeps on your defined HTF and ITF timeframes.
Inversions:
Tracks Fair Value Gaps (FVGs).
An Inversion is triggered when the price closes completely through a recent opposing FVG (e.g. closing above a Bearish FVG, or closing below a Bullish FVG).
Trend Bias:
Calculates trend direction using a standard EMA crossover (50 EMA vs 200 EMA) to decide if the baseline market environment is Bullish, Bearish, or Neutral.
3. Visual Dashboard (Table UI)
At the final bar (barstate.islast), the script builds a 2x4 table panel displaying:

Bias: Displayed as "Bullish" (green), "Bearish" (red), or "Neutral" (gray).
HTF Sweep: Shows ✅ if an HTF sweep is active, else ❌.
ITF Sweep: Shows ✅ if an ITF sweep is active, else ❌.
Inversion: Shows ✅ if an FVG Inversion has occurred, else ❌.

## Source Code

````pine
//@version=6
indicator("Bias & Sweep Dashboard", overlay=true)

// ========================================================================= //
// ============================= INPUTS ==================================== //
// ========================================================================= //
grp_timeframes = "Timeframes"
htf_res = input.timeframe("D", "HTF Timeframe", group=grp_timeframes)
itf_res = input.timeframe("240", "ITF Timeframe", group=grp_timeframes) // 4 hours

grp_table = "Table Settings"
table_position = input.string("Top Right", "Table Position", options=["Top Right", "Top Center", "Top Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=grp_table)
bg_color = input.color(color.new(color.gray, 95), "Background Color", group=grp_table)
text_color = input.color(color.gray, "Text Color", group=grp_table)
bullish_color = input.color(#4CAF50, "Bullish Color", group=grp_table) // Green
bearish_color = input.color(#F44336, "Bearish Color", group=grp_table) // Red

// ========================================================================= //
// ============================= LOGIC ===================================== //
// ========================================================================= //

// Basic Sweep Logic (Example: Price wicks past recent X bars high/low)
lookback = input.int(10, "Swing Lookback", group="Sweep Settings")

// Function to detect pivots
pivotHigh = ta.pivothigh(high, lookback, lookback)
pivotLow  = ta.pivotlow(low, lookback, lookback)

var float ph = na
var float pl = na
if not na(pivotHigh)
    ph := pivotHigh
if not na(pivotLow)
    pl := pivotLow

// Sweep detection logic (simplified)
sweepHigh = high > ph and close < ph // Price goes above pivot high but closes below
sweepLow  = low < pl and close > pl  // Price goes below pivot low but closes above

// HTF and ITF Sweeps
htf_sweepHigh = request.security(syminfo.tickerid, htf_res, sweepHigh, lookahead=barmerge.lookahead_on)
htf_sweepLow  = request.security(syminfo.tickerid, htf_res, sweepLow, lookahead=barmerge.lookahead_on)

itf_sweepHigh = request.security(syminfo.tickerid, itf_res, sweepHigh, lookahead=barmerge.lookahead_on)
itf_sweepLow  = request.security(syminfo.tickerid, itf_res, sweepLow, lookahead=barmerge.lookahead_on)

htf_sweep_active = htf_sweepHigh or htf_sweepLow
itf_sweep_active = itf_sweepHigh or itf_sweepLow

// Inversion logic (Simplified: Close above a bearish FVG or below a bullish FVG)
fvg_bullish = low > high[2]
fvg_bearish = high < low[2]

var float bear_fvg_high = na
var float bear_fvg_low = na
if fvg_bearish
    bear_fvg_high := low[2]
    bear_fvg_low := high

var float bull_fvg_high = na
var float bull_fvg_low = na
if fvg_bullish
    bull_fvg_high := low
    bull_fvg_low := high[2]

inversion_bullish = close > bear_fvg_high and close[1] < bear_fvg_high // Close above recent bearish FVG
inversion_bearish = close < bull_fvg_low and close[1] > bull_fvg_low   // Close below recent bullish FVG

inversion_active = inversion_bullish or inversion_bearish

// Bias Logic (Simple EMA trend for example purposes)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
is_bullish = ema50 > ema200
is_bearish = ema50 < ema200

// Determine Bias text and color
bias_text = is_bullish ? "Bullish" : (is_bearish ? "Bearish" : "Neutral")
bias_color = is_bullish ? bullish_color : (is_bearish ? bearish_color : text_color)

// ========================================================================= //
// ============================= TABLE UI ================================== //
// ========================================================================= //

var table panel = na

get_position() =>
    table_position == "Top Right" ? position.top_right : 
      table_position == "Top Center" ? position.top_center : 
      table_position == "Top Left" ? position.top_left : 
      table_position == "Bottom Right" ? position.bottom_right : 
      table_position == "Bottom Center" ? position.bottom_center : 
      position.bottom_left

if barstate.islast
    if na(panel)
        panel := table.new(get_position(), 2, 4, bgcolor=bg_color, border_width=0, frame_color=na, frame_width=0)
    
    // Header
    table.cell(panel, 0, 0, "Bias", text_color=text_color, text_size=size.normal, text_halign=text.align_right, text_font_family=font.family_default, bgcolor=color.new(bg_color, 100))
    table.cell(panel, 1, 0, bias_text, text_color=bias_color, text_size=size.normal, text_halign=text.align_left, bgcolor=color.new(bg_color, 100))
    
    // HTF Sweep
    table.cell(panel, 0, 1, "HTF Sweep", text_color=text_color, text_size=size.normal, text_halign=text.align_right, bgcolor=color.new(bg_color, 100))
    table.cell(panel, 1, 1, htf_sweep_active ? "✅" : "❌", text_size=size.normal, text_halign=text.align_left, bgcolor=color.new(bg_color, 100))
    
    // ITF Sweep
    table.cell(panel, 0, 2, "ITF Sweep", text_color=text_color, text_size=size.normal, text_halign=text.align_right, bgcolor=color.new(bg_color, 100))
    table.cell(panel, 1, 2, itf_sweep_active ? "✅" : "❌", text_size=size.normal, text_halign=text.align_left, bgcolor=color.new(bg_color, 100))
    
    // Inversion
    table.cell(panel, 0, 3, "Inversion", text_color=text_color, text_size=size.normal, text_halign=text.align_right, bgcolor=color.new(bg_color, 100))
    table.cell(panel, 1, 3, inversion_active ? "✅" : "❌", text_size=size.normal, text_halign=text.align_left, bgcolor=color.new(bg_color, 100))
````
