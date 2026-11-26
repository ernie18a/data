# Bollinger Squeeze Breakout + Volume

- url: https://www.tradingview.com/script/N1OCoFkf-Bollinger-Squeeze-Breakout-Volume/
- type: strategy
- pine_id: PUB;f7cc96e006d34d7b87d9731bc119fa0c
- version: 1.0

## Description

A volatility contraction often precedes a volatility expansion. When Bollinger Bands narrow significantly, it signals that the market has entered a period of low energy, and low energy rarely lasts. This strategy is built around that principle: it waits for a genuine squeeze, then enters only when price breaks out of the bands with volume confirming that the move has real participation behind it, not just noise.

[b]The logic[/b]

A squeeze is identified when the Bollinger Band width (the distance between the upper and lower bands relative to price) falls below its own recent average,meaning volatility is unusually compressed compared to the recent past. Once that condition is met, the strategy watches for price to close outside either band. A long entry triggers when price closes above the upper band during a squeeze, confirmed by volume exceeding its 20-period average. A short entry triggers under the mirrored condition on the lower band. Stops and targets are based on ATR, since the appropriate distance for both should scale with the market's actual movement at the time of entry, not a fixed number.
This approach tends to filter out the false breakouts that occur during already-volatile, choppy conditions, since the entry only fires after a genuine period of compression, which is when breakouts have historically had more follow-through.

[b]Notes on use[/b]

The squeeze threshold and lookback length are the two inputs worth tuning per instrument, a 50-period lookback works reasonably well on daily and 4-hour charts, but lower timeframes may benefit from a shorter lookback to react faster to genuine volatility shifts. As with any breakout strategy, backtest across both trending and range-bound periods before drawing conclusions, since this approach is built specifically to perform during regime transitions and may underperform in markets that stay range-bound for extended periods without ever truly compressing.
This is shared for educational and discussion purposes. As always, backtest thoroughly on your own instruments and timeframes, and treat this as a starting framework rather than a finished system. Feedback and variations are welcome in the comments.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AIScripts

//@version=6
strategy("Bollinger Squeeze Breakout + Volume", overlay=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// ── INPUTS ─────────────────────────────────────────────
bbLen      = input.int(20,    "BB Length",            group="Bollinger Bands")
bbMult     = input.float(2.0, "BB StdDev Multiplier",  group="Bollinger Bands", step=0.1)
squeezeLen = input.int(50,    "Squeeze Lookback",      group="Squeeze")
squeezePct = input.float(0.8, "Squeeze Threshold (x avg width)", group="Squeeze", step=0.05)
volLen     = input.int(20,    "Volume MA Length",      group="Volume")
atrLen     = input.int(14,    "ATR Length",            group="Risk")
slMult     = input.float(1.5, "Stop ATR Multiplier",   group="Risk", step=0.1)
tpMult     = input.float(3.0, "Target ATR Multiplier", group="Risk", step=0.1)

// ── BOLLINGER BANDS ─────────────────────────────────────
[bbMid, bbUpper, bbLower] = ta.bb(close, bbLen, bbMult)
bbWidth   = (bbUpper - bbLower) / bbMid
avgWidth  = ta.sma(bbWidth, squeezeLen)
inSqueeze = bbWidth < (avgWidth * squeezePct)

// ── VOLUME & VOLATILITY ─────────────────────────────────
volPass = volume > ta.sma(volume, volLen)
atrVal  = ta.atr(atrLen)

// ── ENTRY CONDITIONS ─────────────────────────────────────
wasSqueezed = inSqueeze[1]
longCond  = wasSqueezed and ta.crossover(close, bbUpper)  and volPass and strategy.position_size == 0
shortCond = wasSqueezed and ta.crossunder(close, bbLower) and volPass and strategy.position_size == 0

// ── RISK LEVELS ──────────────────────────────────────────
longSL  = close - atrVal * slMult
longTP  = close + atrVal * tpMult
shortSL = close + atrVal * slMult
shortTP = close - atrVal * tpMult

// ── EXECUTION ────────────────────────────────────────────
if longCond
    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", "Long", stop=longSL, limit=longTP)

if shortCond
    strategy.entry("Short", strategy.short)
    strategy.exit("Short Exit", "Short", stop=shortSL, limit=shortTP)

// ── VISUALS ──────────────────────────────────────────────
plot(bbUpper, "Upper Band", color=color.gray)
plot(bbLower, "Lower Band", color=color.gray)
plot(bbMid,   "Basis",      color=color.new(color.gray, 50))

bgcolor(inSqueeze ? color.new(color.yellow, 90) : na)

plotshape(longCond,  location=location.belowbar, color=color.green,
     style=shape.triangleup,   size=size.small, text="Squeeze↑")
plotshape(shortCond, location=location.abovebar, color=color.red,
     style=shape.triangledown, size=size.small, text="Squeeze↓")

// ── ALERTS ───────────────────────────────────────────────
alertcondition(longCond,  "Squeeze Breakout Long",  "Bollinger squeeze breakout — long entry on {{ticker}} @ {{close}}")
alertcondition(shortCond, "Squeeze Breakout Short", "Bollinger squeeze breakout — short entry on {{ticker}} @ {{close}}")
````
