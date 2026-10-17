# Gaussian Channel System [GCS]

- url: https://www.tradingview.com/script/aGCyt6EW-Gaussian-Channel-System-GCS/
- type: indicator
- pine_id: PUB;83d2ecd5aa44459e94e7207a6c771e81
- version: 1.0

## Description

## DESCRIPTION

https://www.tradingview.com/x/c1wJtMZQ/

Gaussian Ribbon Engine (GRE) is a multi-layer trend analysis system built on the Arnaud Legoux Moving Average (ALMA), which applies a Gaussian (bell curve) weighting function to price data instead of the linear or exponential weights used by traditional moving averages.

**Mathematical Foundation**

https://www.tradingview.com/x/hawUeAmu/

ALMA uses a Gaussian kernel — the same bell-curve distribution found in statistics and physics — to weight the prices in its lookback window. The Gaussian function is parameterized by two values: offset (which shifts the bell curve left or right, controlling responsiveness vs. smoothness) and sigma (which controls the width of the bell curve, determining how sharply weights decay from the center). The formula applies: w(i) = exp(-((i - offset * (N-1))^2) / (2 * sigma^2 * N^2)), where each price bar receives a weight according to its position on the Gaussian curve. This produces a moving average with mathematically optimal noise filtering properties.

GRE constructs five ALMA layers with increasing periods (default 9, 21, 55, 100, 200), creating a visual ribbon. When all five layers align in order (fastest on top for bullish, fastest on bottom for bearish), the market is in full directional agreement. The spread between the outermost layers, measured as a percentage and compared to its own historical average, identifies squeeze (convergence) and expansion (divergence) conditions.

**9-Point Confluence Scoring**

The scoring matrix evaluates: price vs. Layer 1, Layer 1 vs. 2, Layer 2 vs. 3, Layer 3 vs. 4, Layer 4 vs. 5 alignment, Layer 1 slope direction, Layer 3 slope direction, RSI above/below 50, and DI+/DI- directional movement. Signals fire when the score crosses the configurable threshold with ADX confirmation.

**Features**
- Five-layer ALMA ribbon with Gaussian kernel weighting
- Adjustable offset (0-1) and sigma parameters for fine-tuning the Gaussian bell shape
- Ribbon spread analysis with squeeze and expansion detection
- 9-point confluence scoring with visual dot notation in dashboard
- ATR-based dual take-profit levels (TP1 and TP2)
- Squeeze breakout signals when ribbon compresses then expands
- ADX and volume confirmation filters
- Full color-coded dashboard with regime classification
- Multiple alert conditions

https://www.tradingview.com/x/avq4gQF0/

---

## Source Code

````pine
//@version=5
indicator("Gaussian Channel System [GCS]", overlay=true, max_labels_count=300, max_lines_count=100)

g1 = "═══ Gaussian Filter ═══"
i_len = input.int(50, "Filter Length", minval=10, maxval=200, group=g1, tooltip="Length of the Gaussian kernel. Longer = smoother trend extraction")
i_sigma = input.float(6.0, "Sigma", minval=1.0, maxval=20.0, step=0.5, group=g1, tooltip="Standard deviation of Gaussian bell curve. Controls filter shape")
i_offset = input.float(0.85, "Offset", minval=0.0, maxval=1.0, step=0.01, group=g1, tooltip="Center of Gaussian window. 0.85 = slight lag reduction")
i_src = input.source(close, "Source", group=g1)
i_chanMult = input.float(2.0, "Channel Width (StdDev)", minval=0.5, maxval=5.0, step=0.1, group=g1)

g2 = "═══ Z-Score Analysis ═══"
i_zLen = input.int(20, "Z-Score Lookback", minval=5, maxval=100, group=g2)
i_zThreshHigh = input.float(2.0, "Z-Score Upper Threshold", minval=1.0, maxval=4.0, step=0.1, group=g2)
i_zThreshLow = input.float(-2.0, "Z-Score Lower Threshold", minval=-4.0, maxval=-1.0, step=0.1, group=g2)

g3 = "═══ Trend Confirmation ═══"
i_adxLen = input.int(14, "ADX Length", minval=5, maxval=50, group=g3)
i_adxThresh = input.int(20, "ADX Trending Level", minval=10, maxval=50, group=g3)
i_emaFast = input.int(8, "Fast EMA", minval=3, maxval=50, group=g3)
i_emaSlow = input.int(21, "Slow EMA", minval=10, maxval=100, group=g3)
i_atrLen = input.int(14, "ATR Length", minval=5, maxval=50, group=g3)

g4 = "═══ Signal Settings ═══"
i_showSignals = input.bool(true, "Show Signals", group=g4)
i_cooldown = input.int(5, "Signal Cooldown", minval=1, maxval=20, group=g4)
i_volFilter = input.bool(true, "Volume Filter", group=g4)
i_slMult = input.float(1.5, "SL ATR Mult", minval=0.5, maxval=5.0, step=0.1, group=g4)
i_tp1Mult = input.float(2.5, "TP1 ATR Mult", minval=1.0, maxval=5.0, step=0.1, group=g4)
i_tp2Mult = input.float(4.0, "TP2 ATR Mult", minval=2.0, maxval=10.0, step=0.1, group=g4)

g5 = "═══ Display ═══"
i_showChannel = input.bool(true, "Show Channel", group=g5)
i_showEMA = input.bool(true, "Show EMAs", group=g5)
i_showSLTP = input.bool(true, "Show SL/TP", group=g5)
i_showDash = input.bool(true, "Show Dashboard", group=g5)
i_barColor = input.bool(false, "Bar Coloring", group=g5)
i_bullCol = input.color(#00E676, "Bullish", group=g5)
i_bearCol = input.color(#FF1744, "Bearish", group=g5)
i_chanCol = input.color(#7C4DFF, "Channel", group=g5)

f_gaussian(_src, _len, _sigma, _offset) =>
    _m = math.floor(_offset * (_len - 1))
    _sum = 0.0
    _wSum = 0.0
    for i = 0 to _len - 1
        _w = math.exp(-0.5 * math.pow((i - _m) / _sigma, 2))
        _sum += _w * _src[i]
        _wSum += _w
    _wSum != 0 ? _sum / _wSum : _src

gaussMA = f_gaussian(i_src, i_len, i_sigma, i_offset)

residuals = i_src - gaussMA
residStdev = ta.stdev(residuals, i_len)
upperChan = gaussMA + residStdev * i_chanMult
lowerChan = gaussMA - residStdev * i_chanMult
midUpper = gaussMA + residStdev * i_chanMult * 0.5
midLower = gaussMA - residStdev * i_chanMult * 0.5

gaussSlope = (gaussMA - gaussMA[5]) / 5.0
slopeNorm = gaussSlope / ta.atr(14)
trendUp = slopeNorm > 0.05
trendDn = slopeNorm < -0.05

zMean = ta.sma(i_src, i_zLen)
zStdev = ta.stdev(i_src, i_zLen)
zScore = zStdev != 0 ? (i_src - zMean) / zStdev : 0.0
zOverbought = zScore > i_zThreshHigh
zOversold = zScore < i_zThreshLow

[diPlus, diMinus, adxVal] = ta.dmi(i_adxLen, i_adxLen)
trending = adxVal > i_adxThresh
bullADX = diPlus > diMinus
bearADX = diMinus > diPlus

emaF = ta.ema(close, i_emaFast)
emaS = ta.ema(close, i_emaSlow)
emaBull = emaF > emaS
emaBear = emaF < emaS

atr = ta.atr(i_atrLen)
volMA = ta.sma(volume, 20)
volOK = not i_volFilter or volume > volMA * 1.1

percentB = residStdev != 0 ? (i_src - lowerChan) / (upperChan - lowerChan) : 0.5
channelPos = math.round(percentB * 100, 1)

priceTouchLower = low <= midLower
priceTouchUpper = high >= midUpper
priceInsideChannel = close > lowerChan and close < upperChan

var int lastBuy = 0
var int lastSell = 0

buyReversion = priceTouchLower and trendUp and zOversold[1] and volOK and bar_index - lastBuy > i_cooldown
sellReversion = priceTouchUpper and trendDn and zOverbought[1] and volOK and bar_index - lastSell > i_cooldown

buyBreakout = ta.crossover(close, upperChan) and trending and bullADX and emaBull and volOK and bar_index - lastBuy > i_cooldown
sellBreakout = ta.crossunder(close, lowerChan) and trending and bearADX and emaBear and volOK and bar_index - lastSell > i_cooldown

buyMomentum = ta.crossover(emaF, emaS) and close > gaussMA and trending and volOK and bar_index - lastBuy > i_cooldown
sellMomentum = ta.crossunder(emaF, emaS) and close < gaussMA and trending and volOK and bar_index - lastSell > i_cooldown

finalBuy = buyReversion or buyBreakout or buyMomentum
finalSell = sellReversion or sellBreakout or sellMomentum

if finalBuy
    lastBuy := bar_index
if finalSell
    lastSell := bar_index

var float sl = na
var float tp1 = na
var float tp2 = na
var int dir = 0
var string sigType = ""

if finalBuy
    sl := close - atr * i_slMult
    tp1 := close + atr * i_tp1Mult
    tp2 := close + atr * i_tp2Mult
    dir := 1
    sigType := buyReversion ? "REV" : buyBreakout ? "BRK" : "MOM"
if finalSell
    sl := close + atr * i_slMult
    tp1 := close - atr * i_tp1Mult
    tp2 := close - atr * i_tp2Mult
    dir := -1
    sigType := sellReversion ? "REV" : sellBreakout ? "BRK" : "MOM"

chanColor = trendUp ? i_bullCol : trendDn ? i_bearCol : i_chanCol
pGauss = plot(gaussMA, "Gaussian MA", color=chanColor, linewidth=3)
pUp = plot(i_showChannel ? upperChan : na, "Upper", color=color.new(i_chanCol, 50))
pLow = plot(i_showChannel ? lowerChan : na, "Lower", color=color.new(i_chanCol, 50))
pMU = plot(i_showChannel ? midUpper : na, "Mid Upper", color=color.new(i_chanCol, 80))
pML = plot(i_showChannel ? midLower : na, "Mid Lower", color=color.new(i_chanCol, 80))
fill(pUp, pMU, color=color.new(i_bearCol, 93))
fill(pMU, pGauss, color=color.new(i_chanCol, 95))
fill(pGauss, pML, color=color.new(i_chanCol, 95))
fill(pML, pLow, color=color.new(i_bullCol, 93))

plot(i_showEMA ? emaF : na, "Fast EMA", color=color.new(#FF9800, 50), linewidth=1)
plot(i_showEMA ? emaS : na, "Slow EMA", color=color.new(#2196F3, 50), linewidth=1)

plotshape(i_showSignals and buyReversion, "Buy REV", shape.labelup, location.belowbar, i_bullCol, size=size.small, text="BUY\nREV", textcolor=color.white)
plotshape(i_showSignals and buyBreakout, "Buy BRK", shape.labelup, location.belowbar, i_bullCol, size=size.small, text="BUY\nBRK", textcolor=color.white)
plotshape(i_showSignals and buyMomentum, "Buy MOM", shape.labelup, location.belowbar, i_bullCol, size=size.small, text="BUY\nMOM", textcolor=color.white)
plotshape(i_showSignals and sellReversion, "Sell REV", shape.labeldown, location.abovebar, i_bearCol, size=size.small, text="SELL\nREV", textcolor=color.white)
plotshape(i_showSignals and sellBreakout, "Sell BRK", shape.labeldown, location.abovebar, i_bearCol, size=size.small, text="SELL\nBRK", textcolor=color.white)
plotshape(i_showSignals and sellMomentum, "Sell MOM", shape.labeldown, location.abovebar, i_bearCol, size=size.small, text="SELL\nMOM", textcolor=color.white)

plot(i_showSLTP and dir == 1 ? sl : na, "SL", color.new(i_bearCol, 50), style=plot.style_linebr)
plot(i_showSLTP and dir == 1 ? tp1 : na, "TP1", color.new(i_bullCol, 50), style=plot.style_linebr)
plot(i_showSLTP and dir == 1 ? tp2 : na, "TP2", color.new(i_bullCol, 70), style=plot.style_linebr)
plot(i_showSLTP and dir == -1 ? sl : na, "SL", color.new(i_bearCol, 50), style=plot.style_linebr)
plot(i_showSLTP and dir == -1 ? tp1 : na, "TP1", color.new(i_bullCol, 50), style=plot.style_linebr)
plot(i_showSLTP and dir == -1 ? tp2 : na, "TP2", color.new(i_bullCol, 70), style=plot.style_linebr)

barcolor(i_barColor ? (zOverbought ? i_bearCol : zOversold ? i_bullCol : close > gaussMA ? color.new(i_bullCol, 50) : color.new(i_bearCol, 50)) : na)

if i_showDash and barstate.islast
    var table t = table.new(position.top_right, 2, 7, bgcolor=color.new(#1a1a2e, 10), border_width=1, border_color=color.new(color.gray, 70))
    table.cell(t, 0, 0, "GCS", text_color=i_chanCol, text_size=size.small, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 1, 0, syminfo.ticker, text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 0, 1, "Z-Score", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 1, 1, str.tostring(math.round(zScore, 2)), text_color=zOverbought ? i_bearCol : zOversold ? i_bullCol : color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 0, 2, "Channel %", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 1, 2, str.tostring(channelPos) + "%", text_color=channelPos > 80 ? i_bearCol : channelPos < 20 ? i_bullCol : color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 0, 3, "Slope", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 1, 3, str.tostring(math.round(slopeNorm, 3)), text_color=trendUp ? i_bullCol : trendDn ? i_bearCol : color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 0, 4, "ADX", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 1, 4, str.tostring(math.round(adxVal, 1)), text_color=trending ? i_bullCol : color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 0, 5, "EMA Cross", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 1, 5, emaBull ? "BULLISH" : "BEARISH", text_color=emaBull ? i_bullCol : i_bearCol, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 0, 6, "Signal", text_color=color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))
    _lastSig = dir == 1 ? "BUY (" + sigType + ")" : dir == -1 ? "SELL (" + sigType + ")" : "NONE"
    table.cell(t, 1, 6, _lastSig, text_color=dir == 1 ? i_bullCol : dir == -1 ? i_bearCol : color.gray, text_size=size.tiny, bgcolor=color.new(#1a1a2e, 0))

alertcondition(finalBuy, "GCS Buy", "GCS: Buy on {{ticker}} at {{close}}")
alertcondition(finalSell, "GCS Sell", "GCS: Sell on {{ticker}} at {{close}}")
alertcondition(buyReversion, "GCS Reversion Buy", "GCS: Mean reversion buy on {{ticker}}")
alertcondition(sellReversion, "GCS Reversion Sell", "GCS: Mean reversion sell on {{ticker}}")
alertcondition(buyBreakout, "GCS Breakout Buy", "GCS: Channel breakout buy on {{ticker}}")
alertcondition(zOverbought and not zOverbought[1], "Z-Score Overbought", "GCS: Z-Score overbought on {{ticker}}")
alertcondition(zOversold and not zOversold[1], "Z-Score Oversold", "GCS: Z-Score oversold on {{ticker}}")
````
