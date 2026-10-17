# Allah's Compass

- url: https://www.tradingview.com/script/Jbk2fJc1-Allah-s-Compass/
- type: strategy
- pine_id: PUB;c54c91bb83c34bddb9547649dd94e40e
- version: 4.0

## Description

This strategy trades bullish divergence setups using the Bollinger Band %B indicator (BB%) as its primary signal. Rather than trading price action directly, it reads momentum through the position of price relative to the Bollinger Bands, entering when oversold conditions show signs of reversal and exiting when price reaches the upper extreme.
Entry Logic
The strategy enters on a bullish divergence — when price makes a lower low but BB% makes a higher low, signaling that downside momentum is weakening while price is still falling. This divergence must occur while BB% is in oversold territory, filtered by an adjustable ceiling threshold. A second divergence while already in a trade triggers a scaled add-on position using a configurable multiplier. A third add-on fires when BB% crosses back above zero, confirming the bounce is underway.
Failed Run Double-Down
If BB% runs up after entry but fails to reach the exit threshold, then pulls back with price making a new low and a fresh divergence forming, the strategy adds to the position again using a separate multiplier. This targets the scenario where the first recovery attempt stalls and resets before a stronger move.
Exit Logic
All positions are closed when BB% reaches the configurable exit threshold, defaulting to 1.0 which represents price touching the upper Bollinger Band. A percentage-based stop loss is set at each entry and updated to the lowest stop across all add-on entries.
Inputs Summary
BB length, standard deviation multiplier, stop loss percentage, divergence lookback period, divergence BB% ceiling, double-down multiplier, failed run multiplier, green cross add-on toggle, and exit threshold are all adjustable from the strategy settings panel.

## Source Code

````pine
//@version=5
strategy("Allah's Compass", overlay=false, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=10)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
bbLength    = input.int(20,    "BB Length")
bbMult      = input.float(2.0, "BB StdDev Multiplier")
stopLossPct = input.float(100.0, "Stop Loss %", step=0.1)
divLookback = input.int(10,    "Divergence Lookback Bars")

// ─────────────────────────────────────────
// BOLLINGER BAND %B CALCULATION
// ─────────────────────────────────────────
basis  = ta.sma(close, bbLength)
dev    = bbMult * ta.stdev(close, bbLength)
upper  = basis + dev
lower  = basis - dev
bbPct  = (close - lower) / (upper - lower)

// ─────────────────────────────────────────
// VISUALS
// ─────────────────────────────────────────
hline(1.0, "Upper Band",  color=color.red,   linestyle=hline.style_dashed)
hline(0.5, "Middle",      color=color.gray,  linestyle=hline.style_dotted)
hline(0.0, "Lower Band",  color=color.green, linestyle=hline.style_dashed)

bbColor = bbPct >= 0.5 ? color.new(color.green, 40) : color.new(color.red, 40)
plot(bbPct, "BB%", color=bbColor, linewidth=2)

bgcolor(bbPct >= 0 and bbPct < 0.5 ? color.new(color.green, 88) : na, title="Lower Green Zone")
bgcolor(bbPct >= 0.5               ? color.new(color.teal,  88) : na, title="Upper Green Zone")
bgcolor(bbPct < 0                  ? color.new(color.red,   88) : na, title="Below Lower Band")

// ─────────────────────────────────────────
// SIGNALS
// ─────────────────────────────────────────
crossIntoGreen = ta.crossover(bbPct, 0.0)

prevPriceLow = close[divLookback]
prevBbPctLow = bbPct[divLookback]
bullishDiv   = (close < prevPriceLow) and (bbPct > prevBbPctLow) and (bbPct < 0.2)
divAddOn     = bullishDiv and not bullishDiv[1] and strategy.position_size > 0

// Bearish divergence — price higher high, BB% lower high, near top
bearishDiv      = (close > close[divLookback]) and (bbPct < bbPct[divLookback]) and (bbPct > 0.8)
bearishDivAlert = bearishDiv and not bearishDiv[1]

exitSignal   = bbPct >= 1.0

// ─────────────────────────────────────────
// STOP LOSS TRACKING
// ─────────────────────────────────────────
var float stopPrice = na

// ─────────────────────────────────────────
// STRATEGY EXECUTION
// ─────────────────────────────────────────

// Initial entry — BB% crosses into green
if crossIntoGreen and strategy.position_size == 0
    strategy.entry("Long", strategy.long)
    stopPrice := close * (1 - stopLossPct / 100)

// Add-on entry — divergence double down (2x the default qty)
if divAddOn
    strategy.entry("Long_Add", strategy.long, qty=2)
    stopPrice := math.min(stopPrice, close * (1 - stopLossPct / 100))

// Stop loss
if strategy.position_size > 0 and close <= stopPrice
    strategy.close_all(comment="Stop Loss")
    stopPrice := na

// Take profit at BB% top
if exitSignal and strategy.position_size > 0
    strategy.close_all(comment="BB% Top Exit")
    stopPrice := na

// ─────────────────────────────────────────
// PLOT SIGNALS
// ─────────────────────────────────────────
plotshape(crossIntoGreen and strategy.position_size == 0,
     title="Buy", location=location.bottom,
     style=shape.triangleup, color=color.green, size=size.small)

plotshape(divAddOn,
     title="Divergence Add-On", location=location.bottom,
     style=shape.diamond, color=color.aqua, size=size.small)

plotshape(bearishDivAlert,
     title="Bearish Divergence", location=location.top,
     style=shape.diamond, color=color.orange, size=size.small)

plotshape(exitSignal and strategy.position_size > 0,
     title="Exit", location=location.top,
     style=shape.triangledown, color=color.red, size=size.small)

plot(strategy.position_size > 0 ? stopPrice : na,
     "Stop Loss", color=color.red, style=plot.style_linebr, linewidth=1)
````
