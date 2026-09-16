<!-- tradingview-pine-id: PUB;1bccccb4527b43ca8b742341e2bf91a8 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# GM Fusion v2.1 - Power Confirmation

Source: https://www.tradingview.com/script/8ZY3jsh7-GM-Fusion-Oscillator/

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
indicator("GM Fusion v2.1 - Power Confirmation", shorttitle="GM Fusion v2.1", overlay=false)

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

// ADX
useAdxFilter = input.bool(true, "Use ADX Minimum")
adxLen = input.int(14, "ADX DI Length", minval=1)
adxSmoothing = input.int(14, "ADX Smoothing", minval=1)
adxMin = input.float(20.0, "Minimum ADX", minval=0, step=0.5)

useAdxRising = input.bool(true, "Require ADX Rising")
adxRiseBars = input.int(1, "ADX Rising Lookback", minval=1)

// DI
useDiFilter = input.bool(true, "Use DI Direction Filter")

// Cooldown
useCooldown = input.bool(true, "Use Signal Cooldown")
cooldownBars = input.int(3, "Cooldown Bars", minval=0)

// Display
showSignals = input.bool(true, "Show Signals")
showComponents = input.bool(false, "Show Component Lines")
showAdx = input.bool(false, "Show ADX Line")

// EMA
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

atr = ta.atr(atrLen)

emaRaw = atr != 0 ? (emaFast - emaSlow) / atr : 0.0
emaComponent = math.max(-100.0, math.min(100.0, emaRaw * 35.0))

// MACD
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFastLen, macdSlowLen, macdSignalLen)

macdRaw = atr != 0 ? macdHist / atr : 0.0
macdComponent = math.max(-100.0, math.min(100.0, macdRaw * 250.0))

// RSI
rsi = ta.rsi(close, rsiLen)
rsiComponent = (rsi - 50.0) * 2.0

// Stochastic
stochRaw = ta.stoch(close, high, low, stochLen)
stochK = ta.sma(stochRaw, stochSmoothK)
stochD = ta.sma(stochK, stochSmoothD)

stochComponent = (stochK - 50.0) * 2.0

// Combo
comboRaw = (emaComponent + macdComponent + rsiComponent + stochComponent) / 4.0
combo = ta.ema(comboRaw, smoothLen)

// ADX + DI
[plusDI, minusDI, adx] = ta.dmi(adxLen, adxSmoothing)

adxMinimumOK = not useAdxFilter or adx >= adxMin
adxRisingOK = not useAdxRising or adx > adx[adxRiseBars]

bullDiOK = not useDiFilter or plusDI > minusDI
bearDiOK = not useDiFilter or minusDI > plusDI

// Base crosses
bullCross = ta.crossover(combo, 0)
bearCross = ta.crossunder(combo, 0)

// Filtered raw signals
bullRawSignal = bullCross and adxMinimumOK and adxRisingOK and bullDiOK
bearRawSignal = bearCross and adxMinimumOK and adxRisingOK and bearDiOK

// Cooldown
var int lastSignalBar = na

cooldownOK = not useCooldown or na(lastSignalBar) or (bar_index - lastSignalBar > cooldownBars)

bullSignal = bullRawSignal and cooldownOK
bearSignal = bearRawSignal and cooldownOK

if bullSignal or bearSignal
    lastSignalBar := bar_index

// Levels
hline(0, "Zero", color=color.new(color.gray, 40))
hline(50, "+50", color=color.new(color.gray, 80))
hline(-50, "-50", color=color.new(color.gray, 80))

// Main oscillator
comboColor = combo >= 0 ? color.lime : color.red

plot(combo, title="GM Fusion", color=comboColor, linewidth=2)

// Components
plot(showComponents ? emaComponent : na, title="EMA Component", color=color.orange)
plot(showComponents ? macdComponent : na, title="MACD Component", color=color.blue)
plot(showComponents ? rsiComponent : na, title="RSI Component", color=color.purple)
plot(showComponents ? stochComponent : na, title="Stochastic Component", color=color.aqua)

// ADX
plot(showAdx ? adx : na, title="ADX Power", color=color.yellow, linewidth=2)

// Signals
plotshape(showSignals and bullSignal, title="Bullish Power Signal", text="▲", style=shape.labelup, location=location.bottom, color=color.green, textcolor=color.white, size=size.tiny)

plotshape(showSignals and bearSignal, title="Bearish Power Signal", text="▼", style=shape.labeldown, location=location.top, color=color.red, textcolor=color.white, size=size.tiny)

// Alerts
alertcondition(bullSignal, title="GM Fusion Bullish Power Signal", message="GM Fusion bullish signal confirmed by ADX and DI filters.")

alertcondition(bearSignal, title="GM Fusion Bearish Power Signal", message="GM Fusion bearish signal confirmed by ADX and DI filters.")
````
