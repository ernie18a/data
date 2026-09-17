<!-- tradingview-pine-id: PUB;aba78ab18a1143c9bbdc3278e2bde62b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Combo Oscillator - MACD + Stoch + RSI + EMA

Source: https://www.tradingview.com/script/5GhV5RK3-Combo-Oscillator-MACD-Stoch-RSI-EMA/

## Description

Combo Oscillator – MACD + Stochastic + RSI + EMA

The Combo Oscillator combines four widely used technical indicators into one simple momentum oscillator:

MACD + Stochastic + RSI + EMA

Instead of switching between several indicators, the Combo Oscillator combines their information into one normalized and smoothed line.

🟢 GREEN / BULLISH SIGNAL
Generated when the combined oscillator crosses above the zero line, indicating a potential shift toward bullish momentum.

🔴 RED / BEARISH SIGNAL
Generated when the combined oscillator crosses below the zero line, indicating a potential shift toward bearish momentum.

The oscillator also uses ATR normalization, allowing indicators with different scales to work together in one combined calculation.

DEFAULT SETTINGS:

EMA: 21 / 55
MACD: 12 / 26 / 9
RSI: 14
Stochastic: 14 / 3 / 3
ATR: 14
Smoothing: 3

The major parameters are adjustable, allowing traders to experiment with different settings for different markets and timeframes.

The Combo Oscillator is designed as a momentum and confirmation tool, not as a standalone trading system.

For best use, combine it with your own analysis, market structure, support and resistance, liquidity and risk management.

One oscillator.
Four indicators.
One clear view of momentum.

---

## Source Code

````pine
//@version=6
indicator("Combo Oscillator - MACD + Stoch + RSI + EMA", overlay=false)

// Inputs
emaFastLen = input.int(21, "EMA Fast", minval=1)
emaSlowLen = input.int(55, "EMA Slow", minval=1)

macdFastLen = input.int(12, "MACD Fast", minval=1)
macdSlowLen = input.int(26, "MACD Slow", minval=1)
macdSignalLen = input.int(9, "MACD Signal", minval=1)

rsiLen = input.int(14, "RSI Length", minval=1)

stochLen = input.int(14, "Stochastic Length", minval=1)
stochSmoothK = input.int(3, "Stoch K Smooth", minval=1)
stochSmoothD = input.int(3, "Stoch D Smooth", minval=1)

atrLen = input.int(14, "ATR Length", minval=1)
smoothLen = input.int(3, "Combo Smoothing", minval=1)

showComponents = input.bool(false, "Show component lines")
showSignals = input.bool(true, "Show zero-line cross signals")

// EMA component
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

atr = ta.atr(atrLen)

emaRaw = atr != 0 ? (emaFast - emaSlow) / atr : 0.0
emaComponent = math.max(-100.0, math.min(100.0, emaRaw * 35.0))

// MACD component
[macdLine, macdSignal, macdHist] = ta.macd(
    close,
    macdFastLen,
    macdSlowLen,
    macdSignalLen
)

macdRaw = atr != 0 ? macdHist / atr : 0.0
macdComponent = math.max(-100.0, math.min(100.0, macdRaw * 250.0))

// RSI component
rsi = ta.rsi(close, rsiLen)
rsiComponent = (rsi - 50.0) * 2.0

// Stochastic component
stochRaw = ta.stoch(close, high, low, stochLen)
stochK = ta.sma(stochRaw, stochSmoothK)
stochD = ta.sma(stochK, stochSmoothD)

stochComponent = (stochK - 50.0) * 2.0

// Combined oscillator
comboRaw = (
    emaComponent +
    macdComponent +
    rsiComponent +
    stochComponent
) / 4.0

combo = ta.ema(comboRaw, smoothLen)

// Levels
hline(0, "Zero", color=color.new(color.gray, 40))
hline(50, "+50", color=color.new(color.gray, 80))
hline(-50, "-50", color=color.new(color.gray, 80))

// Main oscillator color
comboColor = combo >= 0 ? color.lime : color.red

plot(
    combo,
    title="Combo Oscillator",
    color=comboColor,
    linewidth=2
)

// Optional component lines
plot(
    showComponents ? emaComponent : na,
    title="EMA Component",
    color=color.orange,
    linewidth=1
)

plot(
    showComponents ? macdComponent : na,
    title="MACD Component",
    color=color.blue,
    linewidth=1
)

plot(
    showComponents ? rsiComponent : na,
    title="RSI Component",
    color=color.purple,
    linewidth=1
)

plot(
    showComponents ? stochComponent : na,
    title="Stoch Component",
    color=color.aqua,
    linewidth=1
)

// Signals
bullCross = ta.crossover(combo, 0)
bearCross = ta.crossunder(combo, 0)

plotshape(
    showSignals and bullCross,
    title="Bull Cross",
    text="▲",
    style=shape.labelup,
    location=location.bottom,
    color=color.green,
    textcolor=color.white,
    size=size.tiny
)

plotshape(
    showSignals and bearCross,
    title="Bear Cross",
    text="▼",
    style=shape.labeldown,
    location=location.top,
    color=color.red,
    textcolor=color.white,
    size=size.tiny
)

// Alerts
alertcondition(
    bullCross,
    title="Combo Bullish Cross",
    message="Combo Oscillator crossed above zero."
)

alertcondition(
    bearCross,
    title="Combo Bearish Cross",
    message="Combo Oscillator crossed below zero."
)
````
