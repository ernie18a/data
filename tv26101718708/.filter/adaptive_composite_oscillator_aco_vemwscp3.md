# Adaptive Composite Oscillator (ACO)

- url: https://www.tradingview.com/script/vEMWSCP3-Adaptive-Composite-Oscillator-ACO/
- type: indicator
- pine_id: PUB;96ce5f8afabb491191d28d35ca3528ec
- version: 1.0

## Description

[b]Adaptive Composite Oscillator (ACO)[/b]

A momentum oscillator that adapts its own lookback length, normalization bands, and signal logic to current market conditions, rather than relying on the fixed parameters and fixed 70/30-style bands used by traditional oscillators like RSI or Stochastic.


[b]How it works[/b]

1. Adaptive lookback. The effective momentum length shortens when recent volatility (ATR relative to its own average) is elevated, and lengthens when volatility is calm. The oscillator speeds up in choppy or volatile stretches and slows down in quiet ones, instead of using one fixed period regardless of context.

2. Manual adaptive RSI. Pine's built-in ta.rsi() requires a fixed length, which a bar-by-bar adaptive length can't satisfy. So the RSI is built manually with a Wilder-style recursive average whose smoothing factor is derived from the adaptive length on every bar — same underlying math as RSI, just computed in a way that tolerates a variable length.

3. KAMA-style smoothing. The raw adaptive RSI is passed through a Kaufman Adaptive Moving Average-style filter, using an efficiency ratio between fast and slow EMA constants. This makes the line track efficient, directional moves closely while damping down noise during back-and-forth chop.

4. Statistical normalization. Rather than fixed overbought/oversold levels, the smoothed momentum is converted into a z-score against its own rolling mean and standard deviation. The ±2 SD bands self-calibrate to each instrument's own volatility character instead of using one arbitrary threshold for every market.

5. Regime filter (ADX/DMI). An ADX reading classifies conditions as ranging or trending. In ranging conditions, z-score extremes are treated as mean-reversion signals. In strong trends (ADX above threshold), those same extremes are deliberately ignored — since momentum can stay "overbought" for a long time inside a real trend — and instead a zero-line cross in the direction confirmed by +DI/−DI is treated as a trend-continuation signal.

6. Volume confirmation. Every signal additionally requires volume above its own moving average, filtering out low-participation moves that wouldn't hold up.

7. Algorithmic divergence with connecting lines. Bullish and bearish divergence is detected by comparing confirmed price pivots to oscillator pivots — a defined rule, not a discretionary read — and drawn as connecting lines on both the price chart and the oscillator pane, so the actual shape of the divergence is visible rather than marked with a single dot.
[b]
What's plotted[/b]
Oscillator line (z-score), colored by regime — gray for ranging, blue for confirmed uptrend, orange for confirmed downtrend
Dashed ±2 SD statistical bands and a zero line
Yellow background shading while in a strong-trend regime
Green/red triangles for volume-confirmed long/short signals
Magenta/lime connecting lines for bearish/bullish divergence, on both panes

[b]How to use it[/b]

Start by reading the regime background: yellow shading means the market is trending strongly by ADX; no shading means it's ranging. That tells you which of the two signal modes is currently active. Then read the line color — gray, blue, or orange — which tells you the direction of any active trend. Triangles mark volume-confirmed signals: green below the line for long, red above for short. Connecting lines mark divergence: magenta between two price/oscillator highs for bearish, lime between two lows for bullish — these appear a few bars after the second pivot confirms, since a pivot needs bars on both sides to validate.

The strongest setups combine elements rather than relying on one signal alone — for example, a long triangle firing alongside a lime divergence line, or a trend-mode zero-cross that agrees with a higher-timeframe trend you've checked separately. Avoid taking ranging-mode mean-reversion signals against a clearly shaded trending background — that's exactly the mismatch the regime filter exists to prevent.

All lengths, the ADX trend threshold, volume multiplier, pivot lookback, and KAMA constants are adjustable in settings; the defaults are a reasonable starting point, not a finished strategy. Four alert conditions are built in (Long Signal, Short Signal, Bullish Divergence, Bearish Divergence) via TradingView's standard Add Alert dialog.

## Source Code

````pine
//@version=6
indicator("Adaptive Composite Oscillator (ACO)", overlay = false)

// =============================================================================


// ------------------------------- Inputs -------------------------------------
grpCore = "Core"
baseLen      = input.int(14, "Base Momentum Length", minval = 2, group = grpCore)
volLen       = input.int(20, "Volatility Lookback (for adaptive length)", minval = 2, group = grpCore)
zLen         = input.int(100, "Z-Score Normalization Window", minval = 10, group = grpCore)

grpRegime = "Regime Filter"
adxLen       = input.int(14, "ADX Length", minval = 2, group = grpRegime)
adxTrendThr  = input.float(25.0, "ADX Trend Threshold", group = grpRegime)

grpVol = "Volume Confirmation"
volMaLen     = input.int(20, "Volume MA Length", minval = 2, group = grpVol)
volMult      = input.float(1.0, "Min Volume vs Avg (x)", minval = 0.1, step = 0.1, group = grpVol)

grpDiv = "Divergence"
pivotLeft    = input.int(5, "Pivot Left Bars", minval = 1, group = grpDiv)
pivotRight   = input.int(5, "Pivot Right Bars", minval = 1, group = grpDiv)
showDiv      = input.bool(true, "Show Divergence Signals", group = grpDiv)
divLineWidth = input.int(2, "Divergence Line Width", minval = 1, group = grpDiv)

grpSmooth = "Adaptive Smoothing (KAMA-style)"
kamaFast     = input.int(2, "Fast EMA constant", minval = 1, group = grpSmooth)
kamaSlow     = input.int(30, "Slow EMA constant", minval = 1, group = grpSmooth)

// ------------------------- 1. Adaptive lookback ------------------------------
atrNow   = ta.atr(volLen)
atrAvg   = ta.sma(atrNow, volLen)
volRatio = atrAvg == 0 ? 1.0 : atrNow / atrAvg
adaptiveLen = math.max(3.0, math.min(baseLen * 3.0, baseLen / math.max(volRatio, 0.25)))

// ------------------------- 2. Base momentum layer (manual adaptive RSI) ------
priceChange = close - close[1]
gain = priceChange > 0 ? priceChange : 0.0
loss = priceChange < 0 ? -priceChange : 0.0

rsiAlpha = 2.0 / (adaptiveLen + 1.0)

var float avgGain = na
var float avgLoss = na
avgGain := na(avgGain[1]) ? gain : avgGain[1] + rsiAlpha * (gain - avgGain[1])
avgLoss := na(avgLoss[1]) ? loss : avgLoss[1] + rsiAlpha * (loss - avgLoss[1])

rs = avgLoss == 0 ? 0.0 : avgGain / avgLoss
rawRsi = avgLoss == 0 ? 100.0 : 100.0 - (100.0 / (1.0 + rs))

// ------------------------- 6. Adaptive smoothing (KAMA on the RSI) -----------
change   = math.abs(rawRsi - rawRsi[baseLen])
volatilitySum = 0.0
for i = 0 to baseLen - 1
    volatilitySum += math.abs(rawRsi[i] - rawRsi[i + 1])
efficiencyRatio = volatilitySum == 0 ? 0.0 : change / volatilitySum
fastSC = 2.0 / (kamaFast + 1)
slowSC = 2.0 / (kamaSlow + 1)
sc = math.pow(efficiencyRatio * (fastSC - slowSC) + slowSC, 2)

var float kama = na
kama := na(kama[1]) ? rawRsi : kama[1] + sc * (rawRsi - kama[1])

// ------------------------- 3. Normalization layer (z-score) ------------------
zMean = ta.sma(kama, zLen)
zStd  = ta.stdev(kama, zLen)
zScore = zStd == 0 ? 0.0 : (kama - zMean) / zStd

// ------------------------- 4. Regime filter (ADX) -----------------------------
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
strongTrend = adxVal > adxTrendThr

// ------------------------- 5. Volume confirmation -----------------------------
volAvg = ta.sma(volume, volMaLen)
volConfirmed = volume >= volAvg * volMult

// ------------------------- Signal logic ---------------------------------------
overboughtZ = 2.0
oversoldZ   = -2.0

rangeLong  = not strongTrend and ta.crossover(zScore, oversoldZ) and volConfirmed
rangeShort = not strongTrend and ta.crossunder(zScore, overboughtZ) and volConfirmed

trendLongCont  = strongTrend and diPlus > diMinus and ta.crossover(zScore, 0) and volConfirmed
trendShortCont = strongTrend and diMinus > diPlus and ta.crossunder(zScore, 0) and volConfirmed

longSignal  = rangeLong or trendLongCont
shortSignal = rangeShort or trendShortCont

// ------------------------- Divergence detection (algorithmic + lines) --------
pivHighPrice = ta.pivothigh(high, pivotLeft, pivotRight)
pivLowPrice  = ta.pivotlow(low, pivotLeft, pivotRight)
pivHighOsc   = ta.pivothigh(zScore, pivotLeft, pivotRight)
pivLowOsc    = ta.pivotlow(zScore, pivotLeft, pivotRight)

var float lastPivHighPrice = na
var float lastPivHighOsc   = na
var int   lastPivHighBar   = na
var float lastPivLowPrice  = na
var float lastPivLowOsc    = na
var int   lastPivLowBar    = na

bearDiv = false
bullDiv = false

if not na(pivHighPrice)
    curPivHighBar = bar_index - pivotRight
    if not na(lastPivHighPrice) and pivHighPrice > lastPivHighPrice and pivHighOsc < lastPivHighOsc
        bearDiv := true
        if showDiv
            // price-pane line (forced onto main chart even though overlay=false)
            line.new(lastPivHighBar, lastPivHighPrice, curPivHighBar, pivHighPrice, xloc = xloc.bar_index, color = color.new(color.fuchsia, 0), width = divLineWidth, force_overlay = true)
            // oscillator-pane line
            line.new(lastPivHighBar, lastPivHighOsc, curPivHighBar, pivHighOsc, xloc = xloc.bar_index, color = color.new(color.fuchsia, 0), width = divLineWidth)
    lastPivHighPrice := pivHighPrice
    lastPivHighOsc   := pivHighOsc
    lastPivHighBar   := curPivHighBar

if not na(pivLowPrice)
    curPivLowBar = bar_index - pivotRight
    if not na(lastPivLowPrice) and pivLowPrice < lastPivLowPrice and pivLowOsc > lastPivLowOsc
        bullDiv := true
        if showDiv
            line.new(lastPivLowBar, lastPivLowPrice, curPivLowBar, pivLowPrice, xloc = xloc.bar_index, color = color.new(color.lime, 0), width = divLineWidth, force_overlay = true)
            line.new(lastPivLowBar, lastPivLowOsc, curPivLowBar, pivLowOsc, xloc = xloc.bar_index, color = color.new(color.lime, 0), width = divLineWidth)
    lastPivLowPrice := pivLowPrice
    lastPivLowOsc   := pivLowOsc
    lastPivLowBar   := curPivLowBar

// ------------------------------- Plotting -------------------------------------
oscColor = strongTrend ? (diPlus > diMinus ? color.new(color.blue, 0) : color.new(color.orange, 0)) : color.new(color.gray, 0)

plot(zScore, "ACO", color = oscColor, linewidth = 2)
hline(overboughtZ, "Overbought (2.0 sd)", color = color.new(color.red, 60), linestyle = hline.style_dashed)
hline(oversoldZ, "Oversold (-2.0 sd)", color = color.new(color.green, 60), linestyle = hline.style_dashed)
hline(0, "Zero", color = color.new(color.gray, 70))

bgcolor(strongTrend ? color.new(color.yellow, 92) : na, title = "Strong Trend Regime")

plotshape(longSignal, "Long Signal", shape.triangleup, location.bottom, color.new(color.green, 0), size = size.small)
plotshape(shortSignal, "Short Signal", shape.triangledown, location.top, color.new(color.red, 0), size = size.small)

// ------------------------------- Alerts ----------------------------------------
alertcondition(longSignal, "ACO Long Signal", "Adaptive Composite Oscillator: long signal (volume-confirmed)")
alertcondition(shortSignal, "ACO Short Signal", "Adaptive Composite Oscillator: short signal (volume-confirmed)")
alertcondition(bullDiv, "ACO Bullish Divergence", "Price made a lower low while ACO made a higher low")
alertcondition(bearDiv, "ACO Bearish Divergence", "Price made a higher high while ACO made a lower high")
````
