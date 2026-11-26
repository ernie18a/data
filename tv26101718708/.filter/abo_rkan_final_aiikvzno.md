# Abo Rkan Final

- url: https://www.tradingview.com/script/AiIKVzno-Abo-Rkan-Final/
- type: indicator
- pine_id: PUB;1a6387b18df448af9185d41f5a5adfcd
- version: 2.0

## Description

Key Features:
• Donchian Channel Breakout Detection
• EMA Trend Filters
• Ichimoku Cloud Confirmation
• Supertrend Validation
• ADX Trend Strength Filter
• Volume Confirmation Filter
• ATR-Based Risk Management
• Optional Chandelier Stop Loss

## Source Code

````pine
//@version=6
indicator("Abo Rkan Final (EMA + Ichimoku + Donchian + ATR + Supertrend + ADX + Volume)", overlay=true, max_labels_count=500)
// ─────────────────────────────────────────────
// SIGNALS
enableBuy  = input.bool(true,  "Enable BUY Signals")
enableSell = input.bool(true,  "Enable SELL Signals")

// ─────────────────────────────────────────────
// DONCHIAN
len            = input.int(20, "Donchian Lookback", minval=2)
useCloseLevels = input.bool(true, "Use Close for Levels")

atrLen         = input.int(14, "ATR Length")
atrMult        = input.float(0.10, "ATR Buffer Mult", step=0.05)
confirmClose   = input.bool(true, "Require Close Confirmation")
cooldownBars   = input.int(0, "Cooldown Bars", minval=0)

// ─────────────────────────────────────────────
// VOLUME FILTER
useVolFilter = input.bool(true, "Use Volume Filter")
volLen       = input.int(30, "Volume SMA Length")
volMult      = input.float(1.2, "Volume Multiplier")

// ─────────────────────────────────────────────
// ATR MARKET FILTER (SEPARATE)

useAtrFilter = input.bool(true, "Use ATR Market Filter")
atrFilterLen = input.int(14, "ATR Filter Length")
atrMaLen     = input.int(50, "ATR MA Length")
atrThreshold = input.float(0.85, "ATR Threshold", step=0.05)


// ─────────────────────────────────────────────
// EMA FILTERS
useEma1Filter = input.bool(false, "Use EMA 1 As Filter")
ema1Len       = input.int(20, "EMA 1 Length")

useEma2Filter = input.bool(false, "Use EMA 2 As Filter")
ema2Len       = input.int(50, "EMA 2 Length")

useEma3Filter = input.bool(false, "Use EMA 3 As Filter")
ema3Len       = input.int(100, "EMA 3 Length")

ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)

emaLongOk =
     (not useEma1Filter or close > ema1) and
     (not useEma2Filter or close > ema2) and
     (not useEma3Filter or close > ema3)

emaShortOk =
     (not useEma1Filter or close < ema1) and
     (not useEma2Filter or close < ema2) and
     (not useEma3Filter or close < ema3)

// ─────────────────────────────────────────────
// EMA 200 TREND FILTER
useTrendFilter = input.bool(false, "Use EMA 200 Filter")
emaLen = input.int(200, "EMA 200 Length")
ema200 = ta.ema(close, emaLen)

trendOkLong  = not useTrendFilter or close > ema200
trendOkShort = not useTrendFilter or close < ema200

// ─────────────────────────────────────────────
// ICHIMOKU
useIchimoku       = input.bool(true, "Show Ichimoku Cloud")
useIchimokuFilter = input.bool(true, "Use Ichimoku Filter")

tenkanLen = input.int(9, "Tenkan")
kijunLen  = input.int(26, "Kijun")
spanBLen  = input.int(52, "Span B")
displacement = 26

tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2
kijun  = (ta.highest(high, kijunLen)  + ta.lowest(low, kijunLen))  / 2

spanA = (tenkan + kijun) / 2
spanB = (ta.highest(high, spanBLen) + ta.lowest(low, spanBLen)) / 2

// ✔️ FIX: Correct Cloud Logic (price vs cloud)
cloudTop = math.max(spanA, spanB)
cloudBot = math.min(spanA, spanB)

ichimokuLongOk =
     not useIchimokuFilter or close > cloudTop

ichimokuShortOk =
     not useIchimokuFilter or close < cloudBot

// ─────────────────────────────────────────────
// ATR
atr = ta.atr(atrLen)
buf = atr * atrMult

atrValue = ta.atr(atrFilterLen)
atrAvg   = ta.sma(atrValue, atrMaLen)

atrRatio = atrValue / atrAvg

isTrendingATR = atrRatio > atrThreshold
isSidewaysATR = atrRatio <= atrThreshold

// ─────────────────────────────────────────────
// DONCHIAN
srcHigh = useCloseLevels ? close : high
srcLow  = useCloseLevels ? close : low

upper = ta.highest(srcHigh[1], len)
lower = ta.lowest(srcLow[1], len)

longBreak  = confirmClose ? close > upper + buf : high > upper + buf
shortBreak = confirmClose ? close < lower - buf : low < lower - buf

// ─────────────────────────────────────────────
// VOLUME
volOk = not useVolFilter or (volume > ta.sma(volume, volLen) * volMult)

// ─────────────────────────────────────────────
// COOLDOWN
var int lastSignalBar = na
canSignal = na(lastSignalBar) or (bar_index - lastSignalBar > cooldownBars)

// ─────────────────────────────────────────────
// SUPER TREND
useSupertrend = input.bool(true, "Use Supertrend Filter")
stAtrLen      = input.int(10, "Supertrend ATR Length")
stFactor      = input.float(3.0, "Supertrend Factor", step=0.1)

[stLine, stDir] = ta.supertrend(stFactor, stAtrLen)

supertrendLongOk  = not useSupertrend or close > stLine
supertrendShortOk = not useSupertrend or close < stLine

// ─────────────────────────────────────────────
// ADX FILTER

useAdxFilter = input.bool(true, "Use ADX Filter")
adxLen       = input.int(14, "ADX Length")
adxSmooth    = input.int(14, "ADX Smoothing")
adxMin       = input.float(17.0, "Minimum ADX", step=0.5)

[plusDI, minusDI, adxValue] = ta.dmi(adxLen, adxSmooth)

adxOk = not useAdxFilter or adxValue > adxMin

// ─────────────────────────────────────────────
// FINAL SIGNALS

buySignal =
     enableBuy and canSignal and volOk and adxOk and
     emaLongOk and trendOkLong and
     ichimokuLongOk and longBreak and
     supertrendLongOk and
     (not useAtrFilter or isTrendingATR)

sellSignal =
     enableSell and canSignal and volOk and adxOk and
     emaShortOk and trendOkShort and
     ichimokuShortOk and shortBreak and
     supertrendShortOk and
     (not useAtrFilter or isTrendingATR)

if buySignal or sellSignal
    lastSignalBar := bar_index

// ─────────────────────────────────────────────
// ATR STOPS

stopMode     = input.string("Fixed From Entry", "Stop Mode", options=["Fixed From Entry", "Chandelier"])
stopAtrMult  = input.float(2.5, "Stop ATR Mult", step=0.25)
stopLookback = input.int(22, "Chandelier Lookback")

var float buyEntry  = na
var float sellEntry = na

if buySignal
    buyEntry := close

if sellSignal
    sellEntry := close

longStopFixed  = buyEntry - stopAtrMult * atr
shortStopFixed = sellEntry + stopAtrMult * atr

longStopChand  = ta.highest(high, stopLookback) - stopAtrMult * atr
shortStopChand = ta.lowest(low, stopLookback)  + stopAtrMult * atr

buyStopPrice  = stopMode == "Chandelier" ? longStopChand  : longStopFixed
sellStopPrice = stopMode == "Chandelier" ? shortStopChand : shortStopFixed

buyStopDot  = buySignal  ? buyStopPrice  : na
sellStopDot = sellSignal ? sellStopPrice : na

// ─────────────────────────────────────────────
// PLOTS

plot(upper, "Upper Donchian", color=color.green, linewidth=2)
plot(lower, "Lower Donchian", color=color.red, linewidth=2)

plot(useTrendFilter ? ema200 : na, "EMA 200", color=color.orange)

plot(useEma1Filter ? ema1 : na, "EMA 1", color=color.blue)
plot(useEma2Filter ? ema2 : na, "EMA 2", color=color.aqua)
plot(useEma3Filter ? ema3 : na, "EMA 3", color=color.fuchsia)

plot(useSupertrend ? stLine : na, "Supertrend",
     color = stDir == 1 ? color.green : color.red,
     linewidth=2)

// ─────────────────────────────────────────────
// ICHIMOKU VISUAL

pA = plot(useIchimoku ? spanA : na, "Span A", color=color.green, offset=displacement)
pB = plot(useIchimoku ? spanB : na, "Span B", color=color.red, offset=displacement)

fill(pA, pB, color = spanA > spanB ? color.new(color.green, 85) : color.new(color.red, 85))

plot(useIchimoku ? tenkan : na, "Tenkan", color=color.yellow)
plot(useIchimoku ? kijun  : na, "Kijun", color=color.purple)

// ─────────────────────────────────────────────
// SIGNAL SHAPES

plotshape(buySignal, title="BUY", style=shape.labelup,
     text="BUY", color=color.green,
     location=location.belowbar, textcolor=color.white)

plotshape(sellSignal, title="SELL", style=shape.labeldown,
     text="SELL", color=color.red,
     location=location.abovebar, textcolor=color.white)

// ─────────────────────────────────────────────
// STOP DOTS

plot(buyStopDot,  title="BUY Stop",  style=plot.style_circles, linewidth=4, color=color.yellow)
plot(sellStopDot, title="SELL Stop", style=plot.style_circles, linewidth=4, color=color.yellow)

// ─────────────────────────────────────────────
// ALERTS

alertcondition(buySignal, title="BUY Signal", message="BUY breakout + Supertrend confirmation")
alertcondition(sellSignal, title="SELL Signal", message="SELL breakout + Supertrend confirmation")
````
