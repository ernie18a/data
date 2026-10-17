# AOC Market Regime Classifier

- url: https://www.tradingview.com/script/pgKxkjFp-AOC-Market-Regime-Classifier/
- type: indicator
- pine_id: PUB;ae98c863ea95423793463f6e4d729997
- version: 1.0

## Description

How it works

The indicator combines three core components:

EMA Structure (21 / 55) → measures directional bias
ATR (volatility normalization) → evaluates movement relative to market activity
Range Analysis (highest/lowest window) → detects compression and breakout conditions

Using these inputs, the script calculates:

Trend strength → distance between EMAs normalized by ATR
Range tightness → price compression relative to volatility
Breakout conditions → price escaping recent highs/lows

Regime Classification

The market is dynamically classified into four states:

TREND → Strong directional movement with sustained structure
RANGE → Low volatility, compressed price action
BREAKOUT → Price expansion beyond recent range
TRANSITION → Mixed or unclear conditions between regimes

Each regime is color-coded directly on the chart for quick visual interpretation.

What makes it useful
Helps filter trades based on market context
Prevents using the wrong strategy in the wrong environment
Highlights compression → expansion cycles
Keeps analysis simple and adaptive

How to use
Focus on trend-following strategies during TREND phases
Use mean-reversion approaches in RANGE conditions
Watch BREAKOUT for potential expansion opportunities
Be cautious during TRANSITION phases (lower conviction environment)

Key idea

Markets change behavior your strategy should too.

This tool helps you stay aligned with current conditions instead of applying a one-size-fits-all approach.

## Source Code

````pine
//@version=5
indicator("AOC Market Regime Classifier", overlay=true)

fastLen = input.int(21, "Fast EMA")
slowLen = input.int(55, "Slow EMA")
atrLen = input.int(14, "ATR Length")
rangeLen = input.int(20, "Range Length")

fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)
atr = ta.atr(atrLen)
hh = ta.highest(high, rangeLen)
ll = ta.lowest(low, rangeLen)

trendStrength = atr > 0 ? math.abs(fast - slow) / atr : 0.0
rangeTight = atr > 0 ? (hh - ll) / atr < 4.0 : false
breakout = close > hh[1] or close < ll[1]

isTrend = trendStrength > 0.45 and not breakout
isRange = rangeTight and trendStrength < 0.35
isBreakout = breakout

regime = isBreakout ? "BREAKOUT" : isTrend ? "TREND" : isRange ? "RANGE" : "TRANSITION"
regCol = isBreakout ? color.purple : isTrend ? color.lime : isRange ? color.orange : color.gray

bgcolor(isBreakout ? color.new(color.purple, 92) : isTrend ? color.new(color.lime, 95) : isRange ? color.new(color.orange, 94) : na)

plot(fast, color=regCol, linewidth=3)
plot(slow, color=color.new(regCol, 35), linewidth=2)

if barstate.islast
    label.new(bar_index, high, regime, style=label.style_label_down, color=color.new(regCol, 65), textcolor=color.white, size=size.small)
````
