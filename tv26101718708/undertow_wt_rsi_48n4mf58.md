# Undertow [WT + RSI]

- url: https://www.tradingview.com/script/48N4Mf58-Undertow-WT-RSI/
- type: indicator
- pine_id: PUB;f09d58e7e296440b9b033b1a269867eb
- version: 2.0

## Description

[b]INDICATOR — UNDERTOW [UNDR][/b]

Undertow pulls you back. A WaveTrend momentum oscillator with an RSI overlay and clean buy/sell dots that mark when price gets pulled too far, too fast.

https://www.tradingview.com/x/YgSsZjza/

[b]WHAT IT IS[/b]
Undertow is a momentum oscillator that helps you see when an asset has swung too far in one direction and may be due to turn. It combines three classic tools into one clean panel:
— A WaveTrend wave: the filled cyan/navy "tide" that rises and falls with momentum
— A fast trigger line riding on top of the wave, used to catch turns early
— An RSI line for confirmation of overbought/oversold conditions
When the fast line crosses the wave inside an extreme zone, Undertow plots a dot: green for a potential buy, red for a potential sell.

[b]HOW IT WORKS[/b]
The core is the WaveTrend calculation: price is run through a channel-and-average smoothing process that produces an oscillator centered on zero. A faster smoothing of the same series gives the trigger line. When the two cross while the oscillator sits beyond a threshold, the cross is flagged as a signal.
Undertow uses asymmetric thresholds by design: the overbought (sell) level sits higher than the oversold (buy) level is low. This gives the tool a long-friendly bias — it flags buying opportunities on moderate dips, but only flags selling once momentum is stretched well into overbought territory. All thresholds are adjustable in the settings.

[b]SIGNAL TYPES[/b]
— Green dot (buy): trigger crosses up while the oscillator is below the oversold bound
— Red dot (sell): trigger crosses down while the oscillator is above the overbought bound
— Large dots (extreme): crosses occurring at the far extremes, pinned to the top/bottom of the panel for visibility
— Dim dots (optional): every other crossover, shown faintly so you can see the full picture; toggle off for a cleaner chart

[b]SETTINGS YOU CAN TUNE[/b]
— WT Channel / Average / Signal lengths: control how fast or smooth the wave is
— WT Source: hlc3, hl2, or close
— Overbought / Oversold bounds: where signals are allowed to fire
— Extreme level: where the big dots appear
— RSI length and an optional slower RSI line
— Toggle for showing all crossover dots vs only the strong ones

[b]ALERTS[/b]
Built-in alert conditions for Strong Buy, Strong Sell, Extreme Buy, Extreme Sell, and any raw crossover. Set them to "Once Per Bar Close" to avoid signals that flicker while a candle is still forming.

[b]HOW TO READ IT[/b]
Treat the dots as context, not automatic trade commands. A green dot in a strong uptrend pullback is very different from a green dot in a sustained downtrend. Combine Undertow with trend context, support/resistance, and your own risk management.

[b]CREDITS & BASIS[/b]
Undertow is built on the open-source WaveTrend Oscillator concept (popularized by LazyBear on TradingView), combined with a standard RSI overlay. It is published open-source so others can learn from, verify, and adapt it.

[b]DISCLAIMER[/b]
This script is for educational and informational purposes only. It is not financial advice. No indicator predicts the future; signals can and do fail. Always do your own research and manage risk. Past performance does not guarantee future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © grieto

// ─────────────────────────────────────────────────────────────
//  UNDERTOW  [UNDR]  —  WaveTrend Oscillator + RSI + Signal Dots
//  Pine Script v6
//  A momentum oscillator that rides the swings between
//  overbought and oversold. 
// ─────────────────────────────────────────────────────────────
//@version=6
indicator("Undertow [WT + RSI]", shorttitle="UNDR", overlay=false)

// ───────────── Inputs ─────────────
srcOpt    = input.string("hlc3", "WT Source", options=["hlc3", "hl2", "close"], group="WaveTrend")
n1        = input.int(9,  "WT Channel Length", group="WaveTrend")
n2        = input.int(12, "WT Average Length", group="WaveTrend")
sigLen    = input.int(3,  "WT Signal Smoothing", group="WaveTrend")
sigType   = input.string("SMA", "WT Signal Type", options=["SMA", "EMA"], group="WaveTrend")
fastLen   = input.int(6,  "Fast Trigger Line Length", group="WaveTrend",
     tooltip="The wiggly cyan line drawn over the wave. Smaller = wigglier. Try 4-8.")

obLevel   = input.int(60,  "Overbought Bound",  group="Levels")
osLevel   = input.int(-40, "Oversold Bound",    group="Levels")
extLevel  = input.int(80,  "Extreme Level (big dots)", group="Levels")

showRSI   = input.bool(true, "Show RSI Line (magenta)", group="RSI")
rsiLen    = input.int(14,  "RSI Length",          group="RSI")
showSlow  = input.bool(true, "Show Slow RSI Line (red)", group="RSI")
slowLen   = input.int(40,  "Slow RSI Length",     group="RSI")
showWeak  = input.bool(true, "Show All Crossover Dots", group="Signals")

// Theme-adaptive line color: black on light charts, white on dark charts
lineCol      = chart.fg_color
lineColFaint = color.new(chart.fg_color, 65)
lineColFrame = color.new(chart.fg_color, 40)

// ───────────── WaveTrend ─────────────
ap  = srcOpt == "hlc3" ? hlc3 : srcOpt == "hl2" ? hl2 : close
esa = ta.ema(ap, n1)
de  = ta.ema(math.abs(ap - esa), n1)
ci  = (ap - esa) / (0.015 * de)
wt1 = ta.ema(ci, n2)                                                // main wave
wt2 = sigType == "SMA" ? ta.sma(wt1, sigLen) : ta.ema(wt1, sigLen)  // slow wave
wtFast = ta.ema(ci, fastLen)                                        // fast cyan trigger line

crossUp   = ta.crossover(wt1, wt2)
crossDown = ta.crossunder(wt1, wt2)

buyStrong  = crossUp   and wt2 <= osLevel
sellStrong = crossDown and wt2 >= obLevel
buyWeak    = crossUp   and not buyStrong
sellWeak   = crossDown and not sellStrong

buyExtreme  = crossUp   and wt2 <= -extLevel
sellExtreme = crossDown and wt2 >=  extLevel

// ───────────── RSI lines ─────────────
rsi     = ta.rsi(close, rsiLen)
rsiSlow = ta.rsi(close, slowLen)

// ───────────── Reference lines ─────────────
hline(obLevel,  "Upper Bound", color=lineCol, linestyle=hline.style_solid)
hline(osLevel,  "Lower Bound", color=lineCol, linestyle=hline.style_solid)
hline(100,  "Top",    color=lineColFrame, linestyle=hline.style_dotted)
hline(0,    "Zero",   color=lineColFaint, linestyle=hline.style_solid)
hline(-100, "Bottom", color=lineColFrame, linestyle=hline.style_dotted)

// ───────────── WaveTrend — solid area waves from zero ─────────────
plot(wt1, "WT Wave 1", color=color.new(#80f7ff, 45), style=plot.style_area)
plot(wt2, "WT Wave 2", color=color.new(#3949ab, 20), style=plot.style_area)

// Fast wiggly cyan trigger line riding on top of the wave
plot(wtFast, "Fast Trigger", color=color.new(#00e5ff, 0), linewidth=2)

// ───────────── RSI overlays ─────────────
plot(showRSI  ? rsi     : na, "RSI",      color=color.new(#ff00cc, 0), linewidth=1)
plot(showSlow ? rsiSlow : na, "Slow RSI", color=color.new(#e53935, 0), linewidth=1)

// ───────────── Signal dots ─────────────
plotshape(buyStrong  ? wt2 : na, "Buy",
     style=shape.circle, location=location.absolute,
     color=color.new(#00a050, 0), size=size.tiny)

plotshape(sellStrong ? wt2 : na, "Sell",
     style=shape.circle, location=location.absolute,
     color=color.new(#e60026, 0), size=size.tiny)

plotshape(showWeak and buyWeak  ? wt2 : na, "Buy (weak)",
     style=shape.circle, location=location.absolute,
     color=color.new(#00a050, 60), size=size.tiny)

plotshape(showWeak and sellWeak ? wt2 : na, "Sell (weak)",
     style=shape.circle, location=location.absolute,
     color=color.new(#e60026, 60), size=size.tiny)

// Extreme signals — big dots pinned to the top/bottom of the pane
plotshape(sellExtreme, "EXTREME Sell",
     style=shape.circle, location=location.top,
     color=color.new(#e60026, 0), size=size.small)

plotshape(buyExtreme, "EXTREME Buy",
     style=shape.circle, location=location.bottom,
     color=color.new(#00a050, 0), size=size.small)

// ───────────── Alerts ─────────────
alertcondition(buyStrong,   "Strong Buy",   "UNDERTOW: Strong BUY on {{ticker}} ({{interval}})")
alertcondition(sellStrong,  "Strong Sell",  "UNDERTOW: Strong SELL on {{ticker}} ({{interval}})")
alertcondition(buyExtreme,  "EXTREME Buy",  "UNDERTOW: EXTREME BUY on {{ticker}} ({{interval}})")
alertcondition(sellExtreme, "EXTREME Sell", "UNDERTOW: EXTREME SELL on {{ticker}} ({{interval}})")
alertcondition(crossUp,     "Any Buy Cross",  "UNDERTOW: WT cross UP on {{ticker}}")
alertcondition(crossDown,   "Any Sell Cross", "UNDERTOW: WT cross DOWN on {{ticker}}")
````
