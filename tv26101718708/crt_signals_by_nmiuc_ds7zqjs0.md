# CRT Signals by Nmiuc

- url: https://www.tradingview.com/script/Ds7zqJs0/
- type: indicator
- pine_id: PUB;9cc12c0fe738493583f51a2e6541172c
- version: 3.0

## Description

[b]CRT Signals[/b]

CRT Signals is an indicator designed to detect liquidity sweeps and active CRT ranges across multiple timeframes.

The script identifies bullish and bearish CRT ranges when price sweeps liquidity from previous candles and then returns back inside the swept structure. It also displays trade signals with entry, stop loss, and take profit levels based on the detected range.

[b]Main Features[/b]
[list]
[*]Detects bullish and bearish CRT sweep signals.
[*]Calculates the full swept range, including consecutive previous candles that were also swept.
[*]Draws visual trade levels:[list]
[*]Entry
[*]Stop Loss
[*]Take Profit
[/list]
[*]Limits Take Profit according to the configured maximum RR.
[*]Optional midpoint filter for signal validation.
[*]Optional session filter.
[*]Multi-timeframe CRT range panel.
[*]Configurable MTF timeframes.
[*]Ability to show or hide each timeframe in the panel.
[*]Ability to draw active MTF ranges directly on the chart.
[*]Shows range size and remaining distance to target in pips.
[/list]

[b]MTF Range Panel[/b]

The panel shows the latest active CRT range for up to five selected timeframes. By default, it tracks:
[list]
[*]Monthly
[*]Weekly
[*]Daily
[*]4H
[*]1H
[/list]
For each timeframe, the panel displays:

Range direction: Bullish or Bearish
Range size in pips
Distance remaining to the range target

[b]How CRT Ranges Are Detected[/b]

A bullish range is created when price sweeps the low of one or more previous candles and then returns back inside the swept candle structure. The range is measured from the sweep low to the highest high of the swept candles.

A bearish range is created when price sweeps the high of one or more previous candles and then returns back inside the swept candle structure. The range is measured from the sweep high to the lowest low of the swept candles.

The script keeps tracking a range until price either completes the range target or invalidates it by closing beyond the opposite side.

[b]Signal Logic[/b]

Buy and sell signals are generated from the same CRT sweep logic used by the MTF range engine. When a valid signal appears, the script plots:

Entry at candle close
Stop Loss at the sweep extreme, capped by the maximum SL input
Take Profit at the range objective, capped by the configured RR

[b]Disclaimer[/b]

This indicator is intended for educational and analytical purposes only. It does not guarantee profitable trades and should be used together with proper risk management and market context.

## Source Code

````pine
//@version=5
indicator("CRT Range", overlay=true)

// ────────────── INPUTS ──────────────
lookback = input.int(1, "Lookback Liquidity", minval=1)
lineLength = input.int(1, "Line Length (bars)", minval=1)
isAllowedTF =timeframe.multiplier >= 60 or not timeframe.isminutes

if isAllowedTF
    // ────────────── LIQUIDITY LEVELS ──────────────
    prevHigh = ta.highest(high[1], lookback)
    prevLow  = ta.lowest(low[1], lookback)

    bullish = close > open
    edgeHigh = bullish? close < prevHigh : open < prevHigh
    edgeLow = bullish? open > prevLow : close > prevLow
    // ────────────── SWEEP CONDITIONS ──────────────
    sweepHigh = high > prevHigh and edgeHigh
    sweepLow  = low  < prevLow and edgeLow

    // ────────────── ONLY LAST N BARS ──────────────
    barsFromLast = last_bar_index - bar_index
    allowDraw = barsFromLast <= 10

    // ────────────── DRAW SHORT LINES ──────────────
    if sweepHigh
        line.new(x1 = bar_index - 1,y1 = high[1],x2 = bar_index,y2 = high[1],color = color.rgb(75, 75, 75),width = 1)
    if sweepLow
        line.new(x1 = bar_index - 1,y1 = low[1],x2 = bar_index,y2 = low[1],color = color.rgb(75, 75, 75),width = 1)
````
