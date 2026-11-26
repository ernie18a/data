# GFG S/R lines ES + SPY correlation by Agaam

- url: https://www.tradingview.com/script/zsHBWAq5-GFG-S-R-lines-ES-SPY-correlation-by-Agaam/
- type: indicator
- pine_id: PUB;7a7ce9039e0846298e94a0eda17ea81c
- version: 1.0

## Description

## GFG S/R Lines + EMA by Agaam

**GFG S/R Lines + EMA** is a clean chart-overlay indicator designed to show important swing-based support and resistance levels together with a trend EMA.

The purpose of this indicator is to give traders a simple visual structure on the chart: where price has recently formed swing highs, where price has recently formed swing lows, and whether price is trading with or against the EMA trend.

## What The Indicator Shows

This script displays two main tools:

1. **Swing-based support and resistance lines**
2. **Trend EMA**

These two components work together to help traders understand market structure and trend direction without overcrowding the chart.

## Support and Resistance Logic

The indicator finds support and resistance using confirmed swing pivots.

A **resistance line** is created when price forms a confirmed swing high.
A **support line** is created when price forms a confirmed swing low.

The swing length can be adjusted in the settings. A smaller swing length will detect more levels, while a larger swing length will create fewer but stronger-looking levels.

The script also avoids placing duplicate levels too close together. If a new pivot forms near an existing level, the script filters it out so the chart stays cleaner.

## Support and Resistance Display

Support and resistance levels are drawn as horizontal lines directly on the chart.

Users can control:

* How many support and resistance levels are shown
* Line length
* Line width
* Whether lines extend right
* Whether lines extend left
* Support color
* Resistance color
* Timeframe tags
* Label size
* Label offset

This makes the indicator flexible for different chart styles and timeframes.

## Timeframe Tags

The indicator can display a small timeframe tag beside each support or resistance line.

This helps traders quickly see which chart timeframe created the level. For example, a level created on the 5-minute chart can be marked as 5m.

Timeframe tags can be turned on or off in the settings.

## EMA Logic

The indicator includes a trend EMA that helps show the current directional bias of price.

When the EMA is rising, it can suggest bullish trend pressure.
When the EMA is falling, it can suggest bearish trend pressure.
When the EMA is flat, it can suggest a more neutral or sideways condition.

The EMA length is adjustable, allowing traders to use a faster or slower trend guide depending on their trading style.

## EMA Colors

The EMA changes color based on its direction:

* Green when the EMA is rising
* Red when the EMA is falling
* Gray when the EMA is flat or neutral

This gives a fast visual read of trend direction without needing extra labels or panels.

## How Traders Can Use It

Traders can use this indicator to:

* Identify recent support areas
* Identify recent resistance areas
* Watch how price reacts near swing levels
* Use the EMA as a simple trend guide
* Compare price location to nearby support/resistance
* Keep the chart clean while still seeing structure and trend

For example, if price is above a rising EMA and pulling back toward a support line, traders may watch that area for a possible reaction. If price is below a falling EMA and approaching resistance, traders may watch for weakness or rejection.

## Important Notes

Support and resistance levels are based on confirmed pivots, so they appear after the swing is confirmed. They should be used as visual reference levels, not as guaranteed reversal points.

The EMA is a trend guide, not a standalone signal. Price can move above or below the EMA during choppy or volatile conditions.

This indicator is best used with market context, price action, and proper risk management.

## Disclaimer

This script is for educational and informational purposes only. It is not financial advice and does not guarantee trading results. Trading involves risk, and every trader is responsible for their own decisions.

## Source Code

````pine
//@version=5
indicator("GFG S/R lines ES + SPY correlation by Agaam", overlay=true, behind_chart=false, max_lines_count=250, max_labels_count=200)

// ===================== INPUTS =====================
emaLen           = input.int(34, "Trend EMA Length", minval=1)

macdFast         = input.int(12, "MACD Fast", minval=1)
macdSlow         = input.int(26, "MACD Slow", minval=1)
macdSignal       = input.int(9, "MACD Signal", minval=1)

stochLen         = input.int(14, "Stochastic Length", minval=1)
stochSmoothK     = input.int(3, "Stochastic Smooth K", minval=1)
stochDLen        = input.int(3, "Stochastic D Length", minval=1)

bullPullLow      = input.float(20.0, "Bull Pullback Zone Low", step=0.1)
bullPullHigh     = input.float(45.0, "Bull Pullback Zone High", step=0.1)
bearPullLow      = input.float(55.0, "Bear Pullback Zone Low", step=0.1)
bearPullHigh     = input.float(80.0, "Bear Pullback Zone High", step=0.1)

swingLen         = input.int(5, "Swing Length", minval=1)

// ===================== CORRELATION =====================
useCorrelation   = input.bool(true, "Use ES + SPY Correlation")
symbolES         = input.symbol("CME_MINI:ES1!", "ES Symbol")
symbolSPY        = input.symbol("AMEX:SPY", "SPY Symbol")
corrEMAOnly      = input.bool(true, "Correlation Uses EMA Trend Only")

// ===================== LINE CONTROLS =====================
showSR           = input.bool(true, "Show S/R Levels")
maxSRLevels      = input.int(4, "Max S/R Levels Per Side", minval=1, maxval=20)
srLineLen        = input.int(30, "S/R Line Length", minval=5, maxval=300)
extendRight      = input.bool(true, "Extend S/R Right")
extendLeft       = input.bool(false, "Extend S/R Left")
showTFTag        = input.bool(true, "Show S/R TF Tags")
tfLabelSizeInput = input.string("tiny", "S/R TF Label Size", options=["tiny", "small", "normal", "large", "huge"])
tfLabelOffsetATR = input.float(0.03, "S/R TF Label Vertical Offset ATR", minval=0.0, step=0.01)

atrLen           = input.int(14, "ATR Length", minval=1)
stopATRMult      = input.float(0.6, "Stop Buffer ATR", minval=0.1, step=0.1)

// ===================== TRADE LINE CONTROLS =====================
showTradeLines   = input.bool(true, "Show Stop Lines")
tradeLineLen     = input.int(25, "Stop Line Length", minval=5, maxval=200)
showEntryLabels  = input.bool(true, "Show Entry Labels")
useStochExit     = input.bool(true, "Use Stochastic Exit")

// ===================== FILTERS =====================
useVolumeFilter  = input.bool(true, "Use Volume Confirmation")
volLen           = input.int(20, "Volume Average Length", minval=1)
volMult          = input.float(1.1, "Volume Multiplier", minval=0.1, step=0.1)

useChopFilter    = input.bool(true, "Use Chop Filter")
adxLen           = input.int(14, "ADX Length", minval=1)
adxMin           = input.float(18.0, "Minimum ADX", step=0.1)

// ===================== DISPLAY =====================
showEMA          = input.bool(true, "Show EMA")

buyColor         = input.color(color.lime, "BUY Color")
sellColor        = input.color(color.red, "SELL Color")
supportColor     = input.color(color.new(color.green, 0), "Support Color")
resistanceColor  = input.color(color.new(color.red, 0), "Resistance Color")
emaUpColor       = input.color(color.lime, "EMA Up Color")
emaDownColor     = input.color(color.red, "EMA Down Color")
emaFlatColor     = input.color(color.gray, "EMA Flat Color")

stopColor        = input.color(color.new(color.red, 0), "Stop Line Color")

srWidth          = input.int(1, "S/R Line Width", minval=1, maxval=4)
otherTradeWidth  = input.int(1, "Stop Line Width", minval=1, maxval=4)

// ===================== STORAGE =====================
var line[] resLines = array.new_line()
var line[] supLines = array.new_line()
var float[] resPrices = array.new_float()
var float[] supPrices = array.new_float()
var int[] resBars = array.new_int()
var int[] supBars = array.new_int()

// ===================== FUNCTIONS =====================
f_extend() =>
    extendMode = extend.none
    if extendRight and extendLeft
        extendMode := extend.both
    else if extendRight
        extendMode := extend.right
    else if extendLeft
        extendMode := extend.left
    extendMode

f_get_label_size(_s) =>
    labelSize = size.tiny
    if _s == "tiny"
        labelSize := size.tiny
    else if _s == "small"
        labelSize := size.small
    else if _s == "normal"
        labelSize := size.normal
    else if _s == "large"
        labelSize := size.large
    else
        labelSize := size.huge
    labelSize

f_stoch_k(_h, _l, _c) =>
    ta.sma(ta.stoch(_h, _l, _c, stochLen), stochSmoothK)

f_stoch_d(_h, _l, _c) =>
    _k = ta.sma(ta.stoch(_h, _l, _c, stochLen), stochSmoothK)
    ta.sma(_k, stochDLen)

f_has_recent_level(_prices, _bars, _price, _barIndex, _atr) =>
    bool found = false
    if array.size(_prices) > 0
        for i = 0 to array.size(_prices) - 1
            p = array.get(_prices, i)
            b = array.get(_bars, i)
            if math.abs(p - _price) <= _atr * 0.25 or b == _barIndex
                found := true
    found

f_tf_label(_tf) =>
    tfText = _tf
    numericTf = not str.contains(_tf, "S") and not str.contains(_tf, "H") and not str.contains(_tf, "D") and not str.contains(_tf, "W") and not str.contains(_tf, "M")
    if numericTf
        tfText := _tf + "m"
    tfText

// ===================== CORE CALCS =====================
tfLabelSize = f_get_label_size(tfLabelSizeInput)

emaVal = ta.ema(close, emaLen)
emaUp = emaVal > emaVal[1]
emaDown = emaVal < emaVal[1]

emaColor = emaFlatColor
if emaUp
    emaColor := emaUpColor
else if emaDown
    emaColor := emaDownColor

[macdLine, signalLine, hist] = ta.macd(close, macdFast, macdSlow, macdSignal)

rawK = ta.stoch(high, low, close, stochLen)
k = ta.sma(rawK, stochSmoothK)
d = ta.sma(k, stochDLen)

atrVal = ta.atr(atrLen)

volAvg = ta.sma(volume, volLen)
volOK = not useVolumeFilter or volume > volAvg * volMult

// ===================== ES / SPY CORRELATION =====================
esClose = request.security(symbolES, timeframe.period, close)
spyClose = request.security(symbolSPY, timeframe.period, close)

esEMA = request.security(symbolES, timeframe.period, ta.ema(close, emaLen))
spyEMA = request.security(symbolSPY, timeframe.period, ta.ema(close, emaLen))

esEMAUp = esEMA > esEMA[1]
esEMADown = esEMA < esEMA[1]
spyEMAUp = spyEMA > spyEMA[1]
spyEMADown = spyEMA < spyEMA[1]

esBullTrend = esClose > esEMA and esEMAUp
esBearTrend = esClose < esEMA and esEMADown
spyBullTrend = spyClose > spyEMA and spyEMAUp
spyBearTrend = spyClose < spyEMA and spyEMADown

esK = request.security(symbolES, timeframe.period, f_stoch_k(high, low, close))
esD = request.security(symbolES, timeframe.period, f_stoch_d(high, low, close))
spyK = request.security(symbolSPY, timeframe.period, f_stoch_k(high, low, close))
spyD = request.security(symbolSPY, timeframe.period, f_stoch_d(high, low, close))

esBullMomentum = ta.crossover(esK, esD) or esK > esD
esBearMomentum = ta.crossunder(esK, esD) or esK < esD
spyBullMomentum = ta.crossover(spyK, spyD) or spyK > spyD
spyBearMomentum = ta.crossunder(spyK, spyD) or spyK < spyD

corrBullOK = not useCorrelation or (corrEMAOnly ? (esBullTrend and spyBullTrend) : (esBullTrend and spyBullTrend and esBullMomentum and spyBullMomentum))
corrBearOK = not useCorrelation or (corrEMAOnly ? (esBearTrend and spyBearTrend) : (esBearTrend and spyBearTrend and esBearMomentum and spyBearMomentum))

// ===================== MANUAL ADX =====================
upMove = high - high[1]
downMove = low[1] - low

plusDM = (upMove > downMove and upMove > 0) ? upMove : 0.0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0.0

tr = ta.tr(true)
trRma = ta.rma(tr, adxLen)
plusRma = ta.rma(plusDM, adxLen)
minusRma = ta.rma(minusDM, adxLen)

plusDI = trRma != 0 ? 100 * plusRma / trRma : 0.0
minusDI = trRma != 0 ? 100 * minusRma / trRma : 0.0
dx = (plusDI + minusDI) != 0 ? 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI) : 0.0
adxVal = ta.rma(dx, adxLen)

trendOK = not useChopFilter or adxVal >= adxMin

// ===================== TREND / ENTRY LOGIC =====================
bullTrend = close > emaVal and emaUp
bearTrend = close < emaVal and emaDown

nearEMA = math.abs(close - emaVal) <= atrVal * 0.8

bullPullbackZone = math.min(k, d) >= bullPullLow and math.min(k, d) <= bullPullHigh
bearPullbackZone = math.max(k, d) >= bearPullLow and math.max(k, d) <= bearPullHigh

bullStochCross = ta.crossover(k, d)
bearStochCross = ta.crossunder(k, d)

bullMACD = hist > hist[1]
bearMACD = hist < hist[1]

bullCandle = close > open
bearCandle = close < open

longSetup = bullTrend and nearEMA and bullPullbackZone and bullStochCross and bullMACD and bullCandle and trendOK and volOK and corrBullOK
shortSetup = bearTrend and nearEMA and bearPullbackZone and bearStochCross and bearMACD and bearCandle and trendOK and volOK and corrBearOK

longSignal = longSetup and not longSetup[1]
shortSignal = shortSetup and not shortSetup[1]

// ===================== CHART-TF SWING S/R =====================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

resPivotPrice = not na(ph) ? high[swingLen] : na
resPivotBar   = not na(ph) ? bar_index - swingLen : na

supPivotPrice = not na(pl) ? low[swingLen] : na
supPivotBar   = not na(pl) ? bar_index - swingLen : na

newResLevel = showSR and not na(resPivotPrice) and not na(resPivotBar)
newSupLevel = showSR and not na(supPivotPrice) and not na(supPivotBar)

tfLabelText = f_tf_label(timeframe.period)

if newResLevel and not f_has_recent_level(resPrices, resBars, resPivotPrice, int(resPivotBar), atrVal)
    x1 = int(resPivotBar)
    x2 = int(resPivotBar) + srLineLen

    lnRes = line.new(x1, resPivotPrice, x2, resPivotPrice, xloc=xloc.bar_index, extend=f_extend(), color=resistanceColor, width=srWidth)
    array.push(resLines, lnRes)
    array.push(resPrices, resPivotPrice)
    array.push(resBars, int(resPivotBar))

    if showTFTag
        label.new(x=x2, y=resPivotPrice + atrVal * tfLabelOffsetATR, text=tfLabelText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=resistanceColor, size=tfLabelSize)

    if array.size(resLines) > maxSRLevels
        oldResLine = array.shift(resLines)
        line.delete(oldResLine)
        array.shift(resPrices)
        array.shift(resBars)

if newSupLevel and not f_has_recent_level(supPrices, supBars, supPivotPrice, int(supPivotBar), atrVal)
    x1 = int(supPivotBar)
    x2 = int(supPivotBar) + srLineLen

    lnSup = line.new(x1, supPivotPrice, x2, supPivotPrice, xloc=xloc.bar_index, extend=f_extend(), color=supportColor, width=srWidth)
    array.push(supLines, lnSup)
    array.push(supPrices, supPivotPrice)
    array.push(supBars, int(supPivotBar))

    if showTFTag
        label.new(x=x2, y=supPivotPrice + atrVal * tfLabelOffsetATR, text=tfLabelText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=supportColor, size=tfLabelSize)

    if array.size(supLines) > maxSRLevels
        oldSupLine = array.shift(supLines)
        line.delete(oldSupLine)
        array.shift(supPrices)
        array.shift(supBars)

// ===================== TRADE MANAGEMENT =====================
var int tradeDir = 0
var float entryPrice = na
var float stopPrice = na

var line stopLn = na

if longSignal
    tradeDir := 1
    entryPrice := close
    swingStopLow = ta.lowest(low, swingLen + 1)
    stopPrice := math.min(swingStopLow, low) - atrVal * stopATRMult

    if not na(stopLn)
        line.delete(stopLn)

    if showTradeLines
        stopLn := line.new(bar_index, stopPrice, bar_index + tradeLineLen, stopPrice, xloc=xloc.bar_index, extend=extend.none, color=stopColor, width=otherTradeWidth)

if shortSignal
    tradeDir := -1
    entryPrice := close
    swingStopHigh = ta.highest(high, swingLen + 1)
    stopPrice := math.max(swingStopHigh, high) + atrVal * stopATRMult

    if not na(stopLn)
        line.delete(stopLn)

    if showTradeLines
        stopLn := line.new(bar_index, stopPrice, bar_index + tradeLineLen, stopPrice, xloc=xloc.bar_index, extend=extend.none, color=stopColor, width=otherTradeWidth)

// ===================== EXIT LOGIC =====================
longStochExit = tradeDir == 1 and useStochExit and k >= 80 and ta.crossunder(k, d)
shortStochExit = tradeDir == -1 and useStochExit and k <= 20 and ta.crossover(k, d)

stopLong = tradeDir == 1 and low <= stopPrice
stopShort = tradeDir == -1 and high >= stopPrice

if longStochExit or shortStochExit or stopLong or stopShort
    tradeDir := 0

// ===================== LABELS =====================
if showEntryLabels and longSignal
    label.new(bar_index, low - atrVal * 0.2, "BUY", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=buyColor, textcolor=color.white, size=size.small)

if showEntryLabels and shortSignal
    label.new(bar_index, high + atrVal * 0.2, "SELL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=sellColor, textcolor=color.white, size=size.small)

// ===================== PLOTS =====================
plot(showEMA ? emaVal : na, "EMA", color=emaColor, linewidth=2)

// ===================== ALERTS =====================
alertcondition(longSignal, title="BUY", message="Bullish pullback entry with ES/SPY correlation")
alertcondition(shortSignal, title="SELL", message="Bearish pullback entry with ES/SPY correlation")
alertcondition(longStochExit or shortStochExit, title="Stochastic Exit", message="Momentum exit")
````
