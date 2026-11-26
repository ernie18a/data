# PMARP Slope Direction (Daily)

- url: https://www.tradingview.com/script/eZPpkfSH-PMARP-Slope-Direction-Daily/
- type: indicator
- pine_id: PUB;98e36161927f4096a487304c22cb9ad9
- version: 1.0

## Description

How it works

Rebuilds the PMARP calculation internally (same logic as The_Caretaker's original — percentrank of close / MA over the lookback period)
Always evaluates on the Daily timeframe via request.security, so it works correctly even if your chart is on a 4H or weekly view
Compares current PMARP to its value N bars ago — if it's higher, slope is up (+1, green); if lower, slope is down (-1, red)

What you'll see

A green column at +1 when PMARP is sloping up (bullish momentum)
A red column at -1 when sloping down (bearish / fading momentum)
The dimmed PMARP line itself for context
A label on the last bar showing current state
Alerts fire when slope flips direction — useful for regime change notifications

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// PMARP Slope Direction Indicator
// Rebuilds PMARP calculation (original by @The_Caretaker) and detects
// whether the PMARP line is sloping up (+1) or down (-1) on the Daily timeframe.
// Works on any chart timeframe — always evaluates slope on Daily candles.

//@version=5
indicator(title="PMARP Slope Direction (Daily)", shorttitle="PMARP Slope", overlay=false)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
pmar_src        = input.source(close,   title="Source Price")
pmar_length     = input.int(140,        title="PMAR MA Length",     minval=1)
pmar_type       = input.string("SMA",   title="PMAR MA Type",       options=["SMA","EMA","WMA","VWMA","RMA"])
pmarp_lookback  = input.int(350,        title="PMARP Lookback",     minval=2)
slope_lookback  = input.int(3,          title="Slope Lookback (bars)", minval=1,
     tooltip="Number of Daily bars to look back when measuring slope direction. Lower = more sensitive.")

// ─── HELPER: MA TYPE ─────────────────────────────────────────────────────────
f_ma(src, len, mtype) =>
    switch mtype
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "VWMA" => ta.vwma(src, len)
        "RMA"  => ta.rma(src, len)
        =>        ta.sma(src, len)

// ─── PMARP CALCULATION (Daily timeframe) ─────────────────────────────────────
// We request all values from the Daily timeframe so the slope detection
// is always based on daily candles regardless of chart timeframe.

pmarp_daily = request.security(syminfo.tickerid, "D", 
     ta.percentrank(
         pmar_src / f_ma(pmar_src, pmar_length, pmar_type) , 
         pmarp_lookback
     ), 
     lookahead=barmerge.lookahead_off)

// ─── SLOPE DETECTION ─────────────────────────────────────────────────────────
// Slope = current PMARP minus its value N daily bars ago
// Positive slope → trending up → +1 (bullish regime)
// Negative slope → trending down → -1 (bearish regime)

pmarp_prev      = pmarp_daily[slope_lookback]
slope_value     = pmarp_daily - pmarp_prev
is_rising       = slope_value > 0
direction       = is_rising ? 1 : -1

// ─── COLORS ──────────────────────────────────────────────────────────────────
col_bull = color.new(#00e676, 0)   // bright green
col_bear = color.new(#ff1744, 0)   // bright red
col_bg   = is_rising ? color.new(#00e676, 90) : color.new(#ff1744, 90)

// ─── PLOTS ───────────────────────────────────────────────────────────────────
// Plot the raw PMARP line (dimmed) for context
plot(pmarp_daily, title="PMARP (Daily)", color=color.new(color.gray, 50), linewidth=1)

// Plot the direction signal as a histogram: +1 or -1
plot(direction, title="Slope Direction", style=plot.style_columns,
     color=is_rising ? col_bull : col_bear, linewidth=2)

// Zero line
hline(0,  "Zero",  color=color.new(color.white, 60), linestyle=hline.style_dashed)

// Reference lines for PMARP context
hline(1,  "+1 (Up)",   color=color.new(col_bull, 40), linestyle=hline.style_dotted)
hline(-1, "-1 (Down)", color=color.new(col_bear, 40), linestyle=hline.style_dotted)

// Background shading
bgcolor(col_bg, title="Background")

// ─── LABELS ──────────────────────────────────────────────────────────────────
if barstate.islast
    label_text = is_rising ? "▲ PMARP Sloping UP" : "▼ PMARP Sloping DOWN"
    label_col  = is_rising ? col_bull : col_bear
    label.new(bar_index, direction, label_text,
         style=label.style_label_left,
         color=label_col,
         textcolor=color.white,
         size=size.normal)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(direction, 0),  
     title="PMARP Slope turned UP",   
     message="PMARP (Daily) slope has turned POSITIVE — bullish regime signal")

alertcondition(ta.crossunder(direction, 0), 
     title="PMARP Slope turned DOWN", 
     message="PMARP (Daily) slope has turned NEGATIVE — bearish regime signal")
````
