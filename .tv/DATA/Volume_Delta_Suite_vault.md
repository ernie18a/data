<!-- tradingview-pine-id: PUB;44e5cb0e1ad94b1bb868dee605aff4e1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Delta Suite [vault]

Source: https://www.tradingview.com/script/246KKGHW-Volume-Delta-Suite-vault/

## Description

Volume Delta Suite [vault]

Volume Delta Suite is a tool for reading buy and sell pressure from lower-timeframe volume data, showing the real imbalance between buyers and sellers instead of raw volume alone.

How it works

The script pulls data from a selected lower timeframe (LTF Timeframe) using request.security_lower_tf and classifies every intrabar candle as buying (close >= open) or selling (close < open). The volume from each of those intrabar candles is summed separately on the buy side and the sell side. The difference between these two sums (buy volume minus sell volume) becomes the Volume Delta for the current chart bar. This approach gives a more accurate picture of market aggression than standard volume, since it shows which side was actually initiating trades during that period.

Volume Delta is then accumulated over time into CVD (Cumulative Volume Delta), a tool for tracking the longer-term buy/sell pressure trend and spotting divergences against price, for example when price prints a new high while CVD fails to confirm it.

Display modes

- Volume: standard volume shown as columns
- Volume Delta: buy volume minus sell volume, selectable as columns or candles
- CVD (Cumulative Volume Delta): the running total of delta over time, selectable as columns or candles

Delta Spike Detection

A three-tier system for flagging abnormal delta readings, based on the ratio of the current delta to its average over the last N bars (Relative Length). Each of the three thresholds (default 1.5x, 2.5x, 3.5x) has its own independent up and down color, so weak, moderate, and extreme impulses are visually distinguishable at a glance. The calculation mode (Threshold Calculation Type) can be switched between RELATIVE, which measures against the average absolute delta, and ABSOLUTE, which measures standard deviation against the SMA of delta.

Additional settings

- Color Bars: colors the price bars on the main chart according to the current delta spike level
- LTF Timeframe: the lower timeframe used to reconstruct buy/sell microstructure
- Z Length, SMA Length, Relative Length: the statistical parameters used for smoothing and setting the spike thresholds
- Full color customization for positive and negative values, and for each of the three spike tiers
- Built-in Dark, Light, and Custom theme presets

How to use it

Volume Delta and CVD are best used to confirm or question price action. A strong price move accompanied by a strong delta in the same direction shows genuine participation behind the move. A price move on weak or opposing delta can point to exhaustion, absorption, or a low-conviction push that is more likely to fail. Watching CVD against price over a session or a trend leg is a simple way to spot when the move is losing the support of actual buying or selling volume, even while price keeps climbing or falling.

This is not a buy/sell signal generator. It is a volume-flow read intended to be combined with your own structure, levels, and risk management.

---

## Source Code

````pine
//@version=6
indicator("Volume Delta Suite [vault]", shorttitle="Volume Delta Suite [vault]", overlay=false, format=format.volume)

// ============================================================================
// THEME
// ============================================================================
themeMode = input.string("Dark", "Theme", options=["Dark", "Light", "Custom"], group="THEME")

// preset palettes
darkPositive = color.new(#d1d4dc, 0)
darkNegative = color.new(#5c5f66, 0)
lightPositive = color.new(#131722, 0)
lightNegative = color.new(#9598a1, 0)

customPositive = input.color(#d1d4dc, "Positive Color", inline="posneg", group="DISPLAY")
customNegative = input.color(#5c5f66, "Negative Color", inline="posneg", group="DISPLAY")

positiveColor = themeMode == "Custom" ? customPositive : themeMode == "Dark" ? darkPositive : lightPositive
negativeColor = themeMode == "Custom" ? customNegative : themeMode == "Dark" ? darkNegative : lightNegative

// ============================================================================
// DISPLAY
// ============================================================================
displayMode = input.string("Volume Delta", "Display", options=["Volume", "Volume Delta", "CVD (Cumulative Volume Delta)"], group="DISPLAY")

// ============================================================================
// DELTA SPIKE DETECTION
// ============================================================================
tier1On = input.bool(true, "", inline="t1", group="DELTA SPIKE DETECTION")
tier1Mult = input.float(1.5, ">", inline="t1", group="DELTA SPIKE DETECTION")
tier1Up = input.color(color.new(#4caf50, 30), "", inline="t1", group="DELTA SPIKE DETECTION")
tier1Down = input.color(color.new(#ef5350, 30), "", inline="t1", group="DELTA SPIKE DETECTION")

tier2On = input.bool(true, "", inline="t2", group="DELTA SPIKE DETECTION")
tier2Mult = input.float(2.5, ">", inline="t2", group="DELTA SPIKE DETECTION")
tier2Up = input.color(color.new(#4caf50, 10), "", inline="t2", group="DELTA SPIKE DETECTION")
tier2Down = input.color(color.new(#ef5350, 10), "", inline="t2", group="DELTA SPIKE DETECTION")

tier3On = input.bool(true, "", inline="t3", group="DELTA SPIKE DETECTION")
tier3Mult = input.float(3.5, ">", inline="t3", group="DELTA SPIKE DETECTION")
tier3Up = input.color(#2e7d32, "", inline="t3", group="DELTA SPIKE DETECTION")
tier3Down = input.color(#c62828, "", inline="t3", group="DELTA SPIKE DETECTION")

// ============================================================================
// DISPLAY SETTINGS
// ============================================================================
colorBars = input.bool(true, "Color Bars", group="DISPLAY SETTINGS")
ltfTimeframe = input.string("1 minute", "LTF Timeframe", options=["1 minute", "3 minutes", "5 minutes", "15 minutes"], group="DISPLAY SETTINGS")
thresholdType = input.string("RELATIVE", "Threshold Calculation Type", options=["RELATIVE", "ABSOLUTE"], group="DISPLAY SETTINGS")
zLength = input.int(50, "Z Length", minval=1, group="DISPLAY SETTINGS")
smaLength = input.int(300, "SMA Length", minval=1, group="DISPLAY SETTINGS")
relativeLength = input.int(20, "Relative Length", minval=1, group="DISPLAY SETTINGS")
volDeltaFormat = input.string("Columns", "Volume Delta", options=["Columns", "Candles"], group="DISPLAY SETTINGS")
cvdFormat = input.string("Candles", "CVD", options=["Columns", "Candles"], group="DISPLAY SETTINGS")

// ============================================================================
// LTF TIMEFRAME MAP
// ============================================================================
ltfTf = ltfTimeframe == "1 minute" ? "1" : ltfTimeframe == "3 minutes" ? "3" : ltfTimeframe == "5 minutes" ? "5" : "15"

// ============================================================================
// LOWER TIMEFRAME BUY/SELL VOLUME SPLIT
// ============================================================================
[ltfClose, ltfOpen, ltfVol] = request.security_lower_tf(syminfo.tickerid, ltfTf, [close, open, volume])

buyVol = 0.0
sellVol = 0.0
if ltfClose.size() > 0
    for i = 0 to (ltfClose.size() - 1)
        c = ltfClose.get(i)
        o = ltfOpen.get(i)
        v = ltfVol.get(i)
        if c >= o
            buyVol += v
        else
            sellVol += v

delta = buyVol - sellVol
cvd = ta.cum(delta)

// ============================================================================
// SPIKE TIER DETECTION
// ============================================================================
avgAbsDelta = ta.sma(math.abs(delta), relativeLength)
stdevDelta = ta.stdev(delta, zLength)
smaDelta = ta.sma(delta, smaLength)

ratio = thresholdType == "RELATIVE" ? (avgAbsDelta != 0 ? math.abs(delta) / avgAbsDelta : 0) : (stdevDelta != 0 ? math.abs(delta - smaDelta) / stdevDelta : 0)

tier = tier3On and ratio > tier3Mult ? 3 : tier2On and ratio > tier2Mult ? 2 : tier1On and ratio > tier1Mult ? 1 : 0
isUp = delta >= 0

tierColor = tier == 3 ? (isUp ? tier3Up : tier3Down) : tier == 2 ? (isUp ? tier2Up : tier2Down) : tier == 1 ? (isUp ? tier1Up : tier1Down) : (isUp ? positiveColor : negativeColor)

// ============================================================================
// PLOTTING
// ============================================================================
volColor = close >= open ? positiveColor : negativeColor

plot(displayMode == "Volume" ? volume : na, title="Volume", style=plot.style_columns, color=volColor)

deltaColor = tierColor
plot(displayMode == "Volume Delta" and volDeltaFormat == "Columns" ? delta : na, title="Volume Delta (Columns)", style=plot.style_columns, color=deltaColor)

deltaOpen = delta >= 0 ? 0.0 : delta
deltaClose = delta >= 0 ? delta : 0.0
plotcandle(displayMode == "Volume Delta" and volDeltaFormat == "Candles" ? deltaOpen : na,
     displayMode == "Volume Delta" and volDeltaFormat == "Candles" ? math.max(deltaOpen, deltaClose) : na,
     displayMode == "Volume Delta" and volDeltaFormat == "Candles" ? math.min(deltaOpen, deltaClose) : na,
     displayMode == "Volume Delta" and volDeltaFormat == "Candles" ? deltaClose : na,
     title="Volume Delta (Candles)", color=deltaColor, wickcolor=deltaColor, bordercolor=deltaColor)

plot(displayMode == "CVD (Cumulative Volume Delta)" and cvdFormat == "Columns" ? cvd : na, title="CVD (Columns)", style=plot.style_columns, color=cvd >= cvd[1] ? positiveColor : negativeColor)

cvdColor = cvd >= cvd[1] ? positiveColor : negativeColor
plotcandle(displayMode == "CVD (Cumulative Volume Delta)" and cvdFormat == "Candles" ? math.min(cvd, cvd[1]) : na,
     displayMode == "CVD (Cumulative Volume Delta)" and cvdFormat == "Candles" ? math.max(cvd, cvd[1]) : na,
     displayMode == "CVD (Cumulative Volume Delta)" and cvdFormat == "Candles" ? math.min(cvd, cvd[1]) : na,
     displayMode == "CVD (Cumulative Volume Delta)" and cvdFormat == "Candles" ? cvd : na,
     title="CVD (Candles)", color=cvdColor, wickcolor=cvdColor, bordercolor=cvdColor)

barcolor(colorBars ? deltaColor : na, title="Delta Bar Color")

hline(0, "Zero Line", color=color.new(color.gray, 70))
````
