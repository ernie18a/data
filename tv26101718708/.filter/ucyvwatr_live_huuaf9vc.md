# UCY-VWATR (live)

- url: https://www.tradingview.com/script/huUAF9Vc-UCY-VWATR-live/
- type: indicator
- pine_id: PUB;fa3400388dc54fbc968ff064af4ffbab
- version: 1.0

## Description

═══════════════════════════════════════
UCY-VWATR — Volume Weighted ATR Bands with Supertrend
═══════════════════════════════════════

▸ OVERVIEW

A volatility-band indicator that combines a Volume Weighted 
Moving Average (VWMA) center line with ATR-based deviation 
bands and a Supertrend overlay for trend direction.

The indicator visualizes how far price extends from its 
volume-weighted mean in units of Average True Range, while 
the Supertrend acts as a dynamic trend filter.

═══════════════════════════════════════

▸ HOW IT WORKS

- VWMA forms the central reference band (default: 20 period), 
  giving more weight to bars with higher volume than a standard 
  moving average.

- ATR (default: 14 period) generates three pairs of upper and 
  lower deviation bands at ±1, ±2, and ±3 multiples — mapping 
  volatility expansion zones around the mean.

- Supertrend (default: 10 period, factor 3.0) determines the 
  prevailing trend direction. Green = uptrend, Red = downtrend.

- Body-middle (the midpoint of each candle's open and close) 
  is compared against each band. When the body crosses beyond 
  a band in the direction of the active trend, a colored fill 
  appears — darker fills indicate stronger displacement from 
  the mean.

═══════════════════════════════════════

▸ HOW TO READ THE FILLS

In an UPTREND (green Supertrend):
- Body above VWMA → light green fill (mild momentum)
- Body above +1 ATR → medium green
- Body above +2 ATR → strong green
- Body above +3 ATR → extreme green (potential exhaustion)

In a DOWNTREND (red Supertrend):
- Body below VWMA → light red fill
- Body below -1 ATR → medium red
- Body below -2 ATR → strong red
- Body below -3 ATR → extreme red (potential exhaustion)

The intensity of the fill provides an at-a-glance read of 
how stretched price is relative to its volume-weighted mean.

═══════════════════════════════════════

▸ POTENTIAL USE CASES

- Trend-following: Enter in the direction of the Supertrend 
  when price pulls back to VWMA or ±1 ATR band.

- Mean reversion: Look for exhaustion signals when price 
  reaches ±3 ATR bands against the prevailing trend.

- Breakout confirmation: A break and hold above/below ±1 ATR 
  in the direction of a fresh Supertrend flip can act as 
  trend confirmation.

- Volatility context: Wider band spacing signals high 
  volatility regimes; narrow bands indicate compression.

═══════════════════════════════════════

▸ SETTINGS

- VWMA Length: 20 (medium-term balance)
- ATR Length: 14 (classic Wilder period)
- ATR Multipliers: 1.0 / 2.0 / 3.0
- Supertrend ATR Length: 10
- Supertrend Factor: 3.0

All parameters are user-adjustable to fit different timeframes 
and instruments. Lower multipliers suit ranging markets; 
higher multipliers suit trending or volatile assets.

═══════════════════════════════════════

▸ NOTES

- Works on all timeframes and instruments (stocks, futures, 
  forex, crypto).
- VWMA requires volume data — best results on instruments 
  with reliable volume feeds (avoid forex spot pairs without 
  aggregated volume).
- Designed as a visual decision-support tool, not a 
  standalone signal generator.

═══════════════════════════════════════

⚠️ DISCLAIMER

This indicator is published for educational and analytical 
purposes only. It does not constitute financial advice or a 
recommendation to buy or sell any asset. All trading decisions 
and their outcomes are the sole responsibility of the user. 
Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("UCY-VWATR", overlay=true, max_labels_count=500)

// Constants
renk1 = color.new(color.aqua,0)
renk2 = color.new(color.orange,0)
renk3 = color.new(color.red,0)

// Inputs
length = input.int(defval = 20, title = "VWMA Length")
atrLength = input.int(defval = 14, title = "ATR Length")
mult1 = input.float(defval = 1.0, title = "ATR Multiplier 1", step = 0.1)
mult2 = input.float(defval = 2.0, title = "ATR Multiplier 2", step = 0.1)
mult3 = input.float(defval = 3.0, title = "ATR Multiplier 3", step = 0.1)
atrPeriod = input.int(defval = 10, title = "ATR Length", minval = 1)
factor = input.float(defval = 3.0, title = "Factor",     minval = 0.01, step = 0.01)

// Calculation
vwma = ta.vwma(close, length)
atr = ta.atr(atrLength)
upper1 = vwma + (atr * mult1)
lower1 = vwma - (atr * mult1)
upper2 = vwma + (atr * mult2)
lower2 = vwma - (atr * mult2)
upper3 = vwma + (atr * mult3)
lower3 = vwma - (atr * mult3)
[supertrend, direction] = ta.supertrend(factor, atrPeriod)
supertrend := barstate.isfirst ? na : supertrend
upTrend = direction < 0
downTrend = direction > 0
bodyMiddle = barstate.isfirst ? na : (open + close) / 2

// Plot
plot_upTrend = plot(direction < 0 ? supertrend : na, title = "Up Trend", color = color.green, style = plot.style_linebr, linewidth = 2, display = display.all, editable = true)
plot_downTrend = plot(direction < 0 ? na : supertrend, title = "Down Trend", color = color.red, style = plot.style_linebr, linewidth = 2, display = display.all, editable = true)
plot_bodyMiddle = plot(bodyMiddle, "Body Middle", color = na, display = display.all, editable = false)

plot_vwma = plot(vwma, color = color.blue, title="VWMA", style = plot.style_linebr, display = display.all, editable = true, linewidth = 2)
plot_vwmaUp = plot(direction < 0 ? vwma : na, color = na, title="VWMA Up", style = plot.style_linebr, display = display.pane, editable = false)
plot_vwmaDn = plot(direction > 0 ? vwma : na, color = na, title="VWMA Dn", style = plot.style_linebr, display = display.pane, editable = false)

plot_upper1 = plot(upper1, color = renk1, title="Upper 1", style = plot.style_linebr, display = display.pane, editable = true)
plot_upper1Up = plot(direction < 0 ? upper1 : na, color = na, title="Upper 1 Up", style = plot.style_linebr, display = display.pane, editable = false)
plot_upper1Dn = plot(direction > 0 ? upper1 : na, color = na, title="Upper 1 Dn", style = plot.style_linebr, display = display.pane, editable = false)

plot_upper2 = plot(upper2, color = renk2, title="Upper 2", style = plot.style_linebr, display = display.pane, editable = true)
plot_upper2Up = plot(direction < 0 ? upper2 : na, color = na, title="Upper 2 Up", style = plot.style_linebr, display = display.pane, editable = false)
plot_upper2Dn = plot(direction > 0 ? upper2 : na, color = na, title="Upper 2 Dn", style = plot.style_linebr, display = display.pane, editable = false)

plot_upper3 = plot(upper3, color = renk3, title="Upper 3", style = plot.style_linebr, display = display.pane, editable = true)
plot_upper3Up = plot(direction < 0 ? upper3 : na, color = na, title="Upper 3 Up", style = plot.style_linebr, display = display.pane, editable = false)
plot_upper3Dn = plot(direction > 0 ? upper3 : na, color = na, title="Upper 3 Dn", style = plot.style_linebr, display = display.pane, editable = false)

plot_lower1 = plot(lower1, color = renk1, title="Lower 1", style = plot.style_linebr, display = display.pane, editable = true)
plot_lower1Up = plot(direction < 0 ? lower1 : na, color = na, title="Lower 1 Up", style = plot.style_linebr, display = display.pane, editable = false)
plot_lower1Dn = plot(direction > 0 ? lower1 : na, color = na, title="Lower 1 Dn", style = plot.style_linebr, display = display.pane, editable = false)

plot_lower2 = plot(lower2, color = renk2, title="Lower 2", style = plot.style_linebr, display = display.pane, editable = true)
plot_lower2Up = plot(direction < 0 ? lower2 : na, color = na, title="Lower 2 Up", style = plot.style_linebr, display = display.pane, editable = false)
plot_lower2Dn = plot(direction > 0 ? lower2 : na, color = na, title="Lower 2 Dn", style = plot.style_linebr, display = display.pane, editable = false)

plot_lower3 = plot(lower3, color = renk3, title="Lower 3", style = plot.style_linebr, display = display.pane, editable = true)
plot_lower3Up = plot(direction < 0 ? lower3 : na, color = na, title="Lower 3 Up", style = plot.style_linebr, display = display.pane, editable = false)
plot_lower3Dn = plot(direction > 0 ? lower3 : na, color = na, title="Lower 3 Dn", style = plot.style_linebr, display = display.all, editable = false)

// Fill
fill(plot_downTrend, plot_vwmaDn, title = "", color = downTrend and supertrend > vwma ? color.new(color.red, 80) : na, fillgaps = false, editable = false)
fill(plot_bodyMiddle, plot_vwmaDn, title = "", color = downTrend and bodyMiddle < vwma ? color.new(color.red, 80) : na, fillgaps = false, editable = false)
fill(plot_bodyMiddle, plot_lower1Dn, title = "", color = downTrend and bodyMiddle < lower1 ? color.new(color.red, 70) : na, fillgaps = false, editable = false)
fill(plot_bodyMiddle, plot_lower2Dn, title = "", color = downTrend and bodyMiddle < lower2 ? color.new(color.red, 60) : na, fillgaps = false, editable = false)
fill(plot_bodyMiddle, plot_lower3Dn, title = "", color = downTrend and bodyMiddle < lower3 ? color.new(color.red, 50) : na, fillgaps = false, editable = false)

fill(plot_upTrend, plot_vwmaUp, title = "", color = upTrend and supertrend < vwma ? color.new(color.green, 80) : na, fillgaps = false, editable = false)
fill(plot_bodyMiddle, plot_vwmaUp, title = "", color = upTrend and bodyMiddle > vwma ? color.new(color.green, 80) : na, fillgaps = false, editable = false)
fill(plot_bodyMiddle, plot_upper1Up, title = "", color = upTrend and bodyMiddle > upper1 ? color.new(color.green, 70) : na, fillgaps = false, editable = false)
fill(plot_bodyMiddle, plot_upper2Up, title = "", color = upTrend and bodyMiddle > upper2 ? color.new(color.green, 60) : na, fillgaps = false, editable = false)
fill(plot_bodyMiddle, plot_upper3Up, title = "", color = upTrend and bodyMiddle > upper3 ? color.new(color.green, 50) : na, fillgaps = false, editable = false)

// Labels on Last Bar
if barstate.islast
    label.new(bar_index + 2, vwma,   "VWMA",   style = label.style_label_left, color = color.new(color.blue, 80),   textcolor = color.blue,   size = size.small)
    label.new(bar_index + 2, upper1, "+1 ATR",  style = label.style_label_left, color = color.new(renk1, 80),        textcolor = renk1,        size = size.small)
    label.new(bar_index + 2, upper2, "+2 ATR",  style = label.style_label_left, color = color.new(renk2, 80),        textcolor = renk2,        size = size.small)
    label.new(bar_index + 2, upper3, "+3 ATR",  style = label.style_label_left, color = color.new(renk3, 80),        textcolor = renk3,        size = size.small)
    label.new(bar_index + 2, lower1, "-1 ATR",  style = label.style_label_left, color = color.new(renk1, 80),        textcolor = renk1,        size = size.small)
    label.new(bar_index + 2, lower2, "-2 ATR",  style = label.style_label_left, color = color.new(renk2, 80),        textcolor = renk2,        size = size.small)
    label.new(bar_index + 2, lower3, "-3 ATR",  style = label.style_label_left, color = color.new(renk3, 80),        textcolor = renk3,        size = size.small)
````
