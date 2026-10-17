# Undertow Backtest

- url: https://www.tradingview.com/script/0rGWkv97-Undertow-Backtest/
- type: strategy
- pine_id: PUB;1b1e675238ec4492aa4bd7753948f230
- version: 1.0

## Description

[b]STRATEGY — UNDERTOW BACKTEST [UNDR BT]

https://www.tradingview.com/x/9sLb2Le3/

SHORT SUMMARY[/b]
The backtest engine for Undertow. Simulate the buy/sell dots across any asset and timeframe, and choose whether to trade only the strong signals or every crossover.

WHAT IT IS
Undertow Backtest is the strategy version of the Undertow indicator. It applies Undertow's buy and sell logic to historical data and reports how a simple long-only approach would have performed — net profit, win rate, drawdown, and a full trade list — in TradingView's Strategy Tester.

[b]HOW IT WORKS[/b]
— Entry (long): on an Undertow buy signal
— Exit: on an Undertow sell signal

— You independently choose, via dropdowns, whether buys fire on strong dots only (crosses beyond the oversold bound) or on all dots (every upward cross), and likewise for sells.
This lets you compare four behaviors: patient (strong/strong), active (all/all), aggressive long-bias (all buys / strong sells), and defensive (strong buys / all sells).

[b]SETTINGS[/b]
— All the same WaveTrend and threshold inputs as the indicator
— Buy On: Strong dots only / All dots
— Sell On: Strong dots only / All dots
— Default starting capital, position sizing, and commission are set in the strategy properties and can be edited

[b]IMPORTANT LIMITATIONS — PLEASE READ[/b]
— The backtest fills orders at bar close and does NOT model slippage; real-world results would typically be worse.

— It is long-only and goes effectively all-in per signal by default; this is a simplification, not a recommended position-sizing method.

— Higher timeframes (weekly, monthly) produce few trades, which is too small a sample to draw firm conclusions from. Test across multiple assets and timeframes.

— Optimizing the settings until the backtest looks great ("curve fitting") usually produces results that fall apart on live data. Prefer settings that are robust across many markets over ones that are perfect on one.

[b]CREDITS & BASIS[/b]
Based on the open-source WaveTrend Oscillator concept (LazyBear) plus a standard RSI. Published open-source.

[b]DISCLAIMER[/b]
For educational purposes only. Not financial advice. Backtested performance is hypothetical and does not represent actual trading. No system guarantees future profits. Trade at your own risk and never risk more than you can afford to lose.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © grieto

//@version=6
// ─────────────────────────────────────────────────────────────
//  UNDERTOW BACKTEST  [UNDR BT]  —  Strategy version
//  Pine Script v6
//  Backtests the Undertow signals. Choose independently whether
//  to BUY on strong dots only or ALL dots, and likewise for
//  SELL. Results appear in the Strategy Tester tab.
// ─────────────────────────────────────────────────────────────
strategy("Undertow Backtest", shorttitle="UNDR BT",
     overlay=false,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     commission_type=strategy.commission.percent,
     commission_value=0.1)

// ───────────── Inputs ─────────────
srcOpt    = input.string("hlc3", "WT Source", options=["hlc3", "hl2", "close"], group="WaveTrend")
n1        = input.int(9,  "WT Channel Length", group="WaveTrend")
n2        = input.int(12, "WT Average Length", group="WaveTrend")
sigLen    = input.int(3,  "WT Signal Smoothing", group="WaveTrend")
sigType   = input.string("SMA", "WT Signal Type", options=["SMA", "EMA"], group="WaveTrend")

obLevel   = input.int(60,  "Overbought Bound (strong sell)", group="Levels")
osLevel   = input.int(-40, "Oversold Bound (strong buy)",    group="Levels")

buyMode   = input.string("Strong dots only", "Buy On",
     options=["Strong dots only", "All dots"], group="Strategy",
     tooltip="Strong = green dots below the oversold bound. All = every upward crossover.")
sellMode  = input.string("Strong dots only", "Sell On",
     options=["Strong dots only", "All dots"], group="Strategy",
     tooltip="Strong = red dots above the overbought bound. All = every downward crossover.")

// ───────────── WaveTrend ─────────────
ap  = srcOpt == "hlc3" ? hlc3 : srcOpt == "hl2" ? hl2 : close
esa = ta.ema(ap, n1)
de  = ta.ema(math.abs(ap - esa), n1)
ci  = (ap - esa) / (0.015 * de)
wt1 = ta.ema(ci, n2)
wt2 = sigType == "SMA" ? ta.sma(wt1, sigLen) : ta.ema(wt1, sigLen)

crossUp   = ta.crossover(wt1, wt2)
crossDown = ta.crossunder(wt1, wt2)

buyStrong  = crossUp   and wt2 <= osLevel
sellStrong = crossDown and wt2 >= obLevel

longEntry = buyMode  == "All dots" ? crossUp   : buyStrong
longExit  = sellMode == "All dots" ? crossDown : sellStrong

// ───────────── Orders ─────────────
if longEntry
    strategy.entry("Long", strategy.long)
if longExit
    strategy.close("Long")

// ───────────── Visuals ─────────────
lineCol      = chart.fg_color
lineColFaint = color.new(chart.fg_color, 65)
lineColFrame = color.new(chart.fg_color, 40)

hline(obLevel,  "Upper Bound", color=lineCol, linestyle=hline.style_solid)
hline(osLevel,  "Lower Bound", color=lineCol, linestyle=hline.style_solid)
hline(100,  "Top",    color=lineColFrame, linestyle=hline.style_dotted)
hline(0,    "Zero",   color=lineColFaint, linestyle=hline.style_solid)
hline(-100, "Bottom", color=lineColFrame, linestyle=hline.style_dotted)

plot(wt1, "WT Wave 1", color=color.new(#80f7ff, 45), style=plot.style_area)
plot(wt2, "WT Wave 2", color=color.new(#3949ab, 20), style=plot.style_area)
plot(wt1, "WT Edge",   color=color.new(#00e5ff, 0), linewidth=1)

// Strong dots (bright)
plotshape(buyStrong  ? wt2 : na, "Buy (strong)",
     style=shape.circle, location=location.absolute,
     color=color.new(#00a050, 0), size=size.tiny)

plotshape(sellStrong ? wt2 : na, "Sell (strong)",
     style=shape.circle, location=location.absolute,
     color=color.new(#e60026, 0), size=size.tiny)

// Weak dots (dim) — every other crossover
plotshape(crossUp and not buyStrong ? wt2 : na, "Buy (weak)",
     style=shape.circle, location=location.absolute,
     color=color.new(#00a050, 60), size=size.tiny)

plotshape(crossDown and not sellStrong ? wt2 : na, "Sell (weak)",
     style=shape.circle, location=location.absolute,
     color=color.new(#e60026, 60), size=size.tiny)
````
