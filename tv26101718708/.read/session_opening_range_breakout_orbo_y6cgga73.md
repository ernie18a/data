# Session Opening Range Breakout (ORBO)

- url: https://www.tradingview.com/script/Y6cGGA73-Session-Opening-Range-Breakout-ORBO/
- type: strategy
- pine_id: PUB;e36c6ad741f24e668183adbd6daffc5c
- version: 1.0

## Description

This strategy automates a classic Opening Range Breakout (ORBO) approach: it builds a price range for the first minutes after the market opens, then looks for strong breakouts above or below that range to catch early directional moves.

[b]Concept[/b]
The idea behind ORBO is simple:
[list]
[*]The first minutes after the session open are often highly informative.
[*]Price forms an “opening range” that acts as a mini support/resistance zone.
[*]A clean breakout beyond this zone can lead to high-momentum moves.
[/list]
This script turns that logic into a fully backtestable strategy in TradingView.

[b]How the strategy works[/b]
[i][b]Opening Range Session[/b][/i]
[list]
[*]Default session: 09:30–09:50 (exchange time)
[*]During this window, the script tracks:
[/list]
[list=1]
[*]orHigh → highest high within the session
[*]orLow → lowest low within the session
[/list]
This forms your Opening Range for the day.

[i][b]Breakout Logic (after the window ends)[/b][/i]
Once the defined session ends:
[b]Long Entry:[/b]
If the close crosses above the Opening Range High (orHigh),
 [quote]→ strategy.entry("OR Long", strategy.long) is triggered.[/quote]
[b]Short Entry:[/b]
If the close crosses below the Opening Range Low (orLow),
 [quote]→ strategy.entry("OR Short", strategy.short) is triggered.[/quote]
Only one opening range per day is considered, which keeps the logic clean and easy to interpret.

[b]Daily Reset[/b]
[list]
[*]At the start of a new trading day, the script resets:
[/list]
[list=1]
[*]orHigh := na
[*]orLow := na
[/list]
[list]
[*]A fresh Opening Range is then built using the next session’s 09:30–09:50 candles.
[/list]
This ensures entries are always based on today’s structure, not yesterday’s.

[b]Visuals & Inputs[/b]
[i][b]Inputs:[/b][/i]
[list]
[*]Opening range session → default: "0930-0950"
[*]Show OR levels → toggle visibility of OR High / Low lines
[*]Fill range body → optional shaded zone between OR High and OR Low
[/list]
[i][b]Chart visuals:[/b][/i]
[list]
[*]A green line marks the Opening Range High.
[*]A red line marks the Opening Range Low.
[*]Optional yellow fill highlights the entire OR zone.
[*]Background shading during the session shows when the range is currently being built.
[/list]
These visuals make it easy to see:
[list]
[*]Where the OR sits relative to current price
[*]How clean / noisy the breakout was
[*]How often price respects or rejects the opening zone
[/list]
[i][b]Backtesting & Optimization[/b][/i]
Because this is written as a strategy():
You can use TradingView’s Strategy Tester to view:
[list]
[*]Win rate
[*]Net profit
[*]Drawdown
[*]Profit factor
[*]Equity curve
[/list]
[i]Ideas to experiment with:[/i]
[list]
[*]Change the session window (e.g., 09:15–09:45, 10:00–10:30)
[*]Apply to different:
[*]Markets: indices, FX, crypto, stocks
[*]Timeframes: 1m / 5m / 15m
[/list]
[i]Add your own:[/i]
[list]
[*]Stop Loss & Take Profit levels
[*]Time filters (only trade certain days / times)
[*]Volatility filters (e.g., ATR, range size thresholds)
[*]Higher-timeframe trend filter (e.g., only take longs above 200 EMA)
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AIScripts

//@version=6
strategy("Session Opening Range Breakout (ORBO)",
     overlay           = true,
     initial_capital   = 100000,
     default_qty_type  = strategy.percent_of_equity,
     default_qty_value = 10,
     commission_type   = strategy.commission.percent,
     commission_value  = 0.01)

//──────────────────────────────
// Inputs
//──────────────────────────────
orSession = input.session("0930-0950", "Opening range session")
showRange = input.bool(true, "Show OR levels")
fillRange = input.bool(true, "Fill range body")

//──────────────────────────────
// Session & day detection
//──────────────────────────────
inSession = not na(time(timeframe.period, orSession))
isNewDay  = ta.change(time("D")) != 0

//──────────────────────────────
// Track Opening Range High / Low
//──────────────────────────────
var float orHigh = na
var float orLow  = na

// Reset OR levels at the start of a new day
if isNewDay
    orHigh := na
    orLow  := na

// Build opening range during the session
if inSession
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow, low)

//──────────────────────────────
// Breakout logic (after OR session ends)
//──────────────────────────────
sessionFinished = not inSession and not na(orHigh) and not na(orLow)

longBreak  = sessionFinished and ta.crossover(close, orHigh)
shortBreak = sessionFinished and ta.crossunder(close, orLow)

if longBreak
    strategy.entry("OR Long", strategy.long)

if shortBreak
    strategy.entry("OR Short", strategy.short)

//──────────────────────────────
// Visuals
//──────────────────────────────
plotOrHigh = plot(
     showRange ? orHigh : na,
     title = "OR High",
     color = color.new(color.green, 0),
     style = plot.style_linebr)

plotOrLow = plot(
     showRange ? orLow : na,
     title = "OR Low",
     color = color.new(color.red, 0),
     style = plot.style_linebr)

// Global-scope fill (required in Pine)
fillColor = showRange and fillRange ? color.new(color.yellow, 90) : na
fill(plotOrHigh, plotOrLow, fillColor)

// Highlight while OR is being built
bgcolor(inSession ? color.new(color.yellow, 92) : na)
````
