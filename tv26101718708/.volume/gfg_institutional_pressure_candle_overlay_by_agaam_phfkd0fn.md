# GFG Institutional Pressure Candle Overlay by Agaam

- url: https://www.tradingview.com/script/pHFKD0fn-GFG-Institutional-Pressure-Candle-Overlay-by-Agaam/
- type: indicator
- pine_id: PUB;49d0073a9fbd472ca6c99faaa84b871b
- version: 1.0

## Description

GFG Institutional Pressure Candle Overlay by Agaam

This indicator is designed to help identify potential institutional-style buying pressure, selling pressure, and absorption directly on the chart.

The script analyzes each candle using multiple pressure factors, including candle body strength, close location, relative volume, ATR range expansion, VWAP position, and wick rejection. It then assigns a simple 0–10 pressure score and displays clean BUY or SELL labels when pressure conditions are detected.

Main Features:

* BUY and SELL pressure labels with 0–10 scoring
* Candle coloring based on detected pressure
* VWAP control filter
* Relative volume pressure filter
* ATR expansion filter
* Wick-based absorption detection
* Optional labels for all signals or strong signals only
* Status table showing pressure score, volume ratio, range/ATR, body %, close location, and VWAP position
* Alerts for buy pressure, sell pressure, and strong pressure conditions

How It Works:
Bullish pressure is detected when candles show strong body structure, close near the high, volume support, ATR expansion, and VWAP control.

Bearish pressure is detected when candles show strong downside structure, close near the low, volume support, ATR expansion, and VWAP control.

Absorption logic looks for high-volume candles with smaller bodies and larger wicks, which may suggest that one side is absorbing orders near a key level.

Suggested Use:
This indicator works best as a confirmation tool together with market structure, VWAP, supply/demand zones, support/resistance, and multi-timeframe analysis.

Example:

* Demand zone + BUY score = stronger bullish confirmation
* Supply zone + SELL score = stronger bearish confirmation
* High score near liquidity sweep = possible institutional reaction area

This indicator does not predict the future and does not confirm real institutional orders. It is an analytical tool that estimates pressure using price action, volume, volatility, VWAP, and candle behavior.

Disclaimer:
This script is for educational and informational purposes only. It is not financial advice. Trading involves risk, and you are responsible for your own trading decisions. Always use proper risk management.

## Source Code

````pine
//@version=5
indicator("GFG Institutional Pressure Candle Overlay by Agaam", overlay=true, max_labels_count=500, max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupMain = "Institutional Pressure Logic"

useVwapFilter = input.bool(true, "Use VWAP Control", group=groupMain)
useVolumePressure = input.bool(true, "Use Volume Pressure", group=groupMain)
useAtrExpansion = input.bool(true, "Use ATR Expansion", group=groupMain)
useAbsorption = input.bool(true, "Detect Absorption", group=groupMain)

volumeLength = input.int(20, "Volume Average Length", minval=1, group=groupMain)
atrLength = input.int(14, "ATR Length", minval=1, group=groupMain)

strongScore = input.int(7, "Strong Pressure Minimum Score", minval=1, maxval=10, group=groupMain)
mediumScore = input.int(5, "Medium Pressure Minimum Score", minval=1, maxval=10, group=groupMain)

groupThresholds = "Pressure Thresholds"

strongBodyPercent = input.float(0.55, "Strong Body Percent", minval=0.05, maxval=1.0, step=0.05, group=groupThresholds)
strongClosePercent = input.float(0.70, "Strong Close Location", minval=0.50, maxval=1.0, step=0.05, group=groupThresholds)
highVolumeMultiplier = input.float(1.30, "High Volume Multiplier", minval=0.1, step=0.05, group=groupThresholds)
atrExpansionMultiplier = input.float(1.10, "ATR Expansion Multiplier", minval=0.1, step=0.05, group=groupThresholds)

absorptionBodyMax = input.float(0.35, "Absorption Max Body Percent", minval=0.05, maxval=1.0, step=0.05, group=groupThresholds)
absorptionVolumeMultiplier = input.float(1.40, "Absorption Volume Multiplier", minval=0.1, step=0.05, group=groupThresholds)
absorptionWickMin = input.float(0.45, "Absorption Wick Minimum", minval=0.05, maxval=1.0, step=0.05, group=groupThresholds)

groupVisual = "Visuals"

colorCandles = input.bool(true, "Color Candles By Pressure", group=groupVisual)
showLabels = input.bool(true, "Show Pressure Labels", group=groupVisual)
showOnlyStrongLabels = input.bool(false, "Show Only Strong Labels", group=groupVisual)
showStatusTable = input.bool(true, "Show Status Table", group=groupVisual)

buyPressureColor = input.color(color.lime, "Buy Pressure Color", group=groupVisual)
sellPressureColor = input.color(color.red, "Sell Pressure Color", group=groupVisual)
absorptionColor = input.color(color.orange, "Absorption Color", group=groupVisual)
neutralColor = input.color(color.gray, "Neutral Color", group=groupVisual)

candleTransparency = input.int(0, "Candle Color Transparency", minval=0, maxval=100, group=groupVisual)
labelTransparency = input.int(10, "Label Background Transparency", minval=0, maxval=100, group=groupVisual)

labelSizeInput = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupVisual)
labelAtrOffset = input.float(0.60, "Label Distance From Candle ATR", minval=0.0, step=0.05, group=groupVisual)

maxLabels = input.int(250, "Maximum Labels On Chart", minval=20, maxval=500, group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal :
     _s == "Large" ? size.large :
     size.huge

f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_value, _max))

labelSize = f_size(labelSizeInput)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE VALUES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

candleRange = math.max(high - low, syminfo.mintick)
candleBody = math.abs(close - open)

bodyPercent = candleBody / candleRange
closeLocation = (close - low) / candleRange

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

upperWickPercent = upperWick / candleRange
lowerWickPercent = lowerWick / candleRange

isBullCandle = close > open
isBearCandle = close < open

volAverage = ta.sma(volume, volumeLength)
volumeRatio = volAverage > 0 ? volume / volAverage : 1.0

atrValue = ta.atr(atrLength)
rangeAtrRatio = atrValue > 0 ? candleRange / atrValue : 1.0

vwapValue = ta.vwap(hlc3)

aboveVwap = close >= vwapValue
belowVwap = close <= vwapValue

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRESSURE COMPONENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullBodyPoints = isBullCandle and bodyPercent >= strongBodyPercent ? 2 : isBullCandle and bodyPercent >= strongBodyPercent * 0.70 ? 1 : 0
bearBodyPoints = isBearCandle and bodyPercent >= strongBodyPercent ? 2 : isBearCandle and bodyPercent >= strongBodyPercent * 0.70 ? 1 : 0

bullClosePoints = closeLocation >= strongClosePercent ? 2 : closeLocation >= 0.60 ? 1 : 0
bearClosePoints = closeLocation <= 1.0 - strongClosePercent ? 2 : closeLocation <= 0.40 ? 1 : 0

volumePoints = useVolumePressure ? volumeRatio >= highVolumeMultiplier ? 2 : volumeRatio >= 1.0 ? 1 : 0 : 1
atrPoints = useAtrExpansion ? rangeAtrRatio >= atrExpansionMultiplier ? 2 : rangeAtrRatio >= 0.85 ? 1 : 0 : 1

bullVwapPoints = useVwapFilter ? aboveVwap ? 2 : 0 : 1
bearVwapPoints = useVwapFilter ? belowVwap ? 2 : 0 : 1

bullWickPoints = lowerWickPercent > upperWickPercent and lowerWickPercent >= 0.20 ? 1 : 0
bearWickPoints = upperWickPercent > lowerWickPercent and upperWickPercent >= 0.20 ? 1 : 0

rawBullScore = bullBodyPoints + bullClosePoints + volumePoints + atrPoints + bullVwapPoints + bullWickPoints
rawBearScore = bearBodyPoints + bearClosePoints + volumePoints + atrPoints + bearVwapPoints + bearWickPoints

bullScore = int(f_clamp(rawBullScore, 0, 10))
bearScore = int(f_clamp(rawBearScore, 0, 10))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ABSORPTION LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

highVolume = volumeRatio >= absorptionVolumeMultiplier
smallBody = bodyPercent <= absorptionBodyMax

bullishAbsorption = useAbsorption and highVolume and smallBody and lowerWickPercent >= absorptionWickMin and closeLocation >= 0.45
bearishAbsorption = useAbsorption and highVolume and smallBody and upperWickPercent >= absorptionWickMin and closeLocation <= 0.55

absorptionScoreRaw = 0
absorptionScoreRaw += highVolume ? 3 : 0
absorptionScoreRaw += smallBody ? 2 : 0
absorptionScoreRaw += math.max(upperWickPercent, lowerWickPercent) >= absorptionWickMin ? 3 : 0
absorptionScoreRaw += rangeAtrRatio >= 0.75 ? 1 : 0
absorptionScoreRaw += volumeRatio >= absorptionVolumeMultiplier * 1.25 ? 1 : 0

absorptionScore = int(f_clamp(absorptionScoreRaw, 0, 10))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL PRESSURE STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buyPressure = bullScore >= mediumScore and bullScore > bearScore and not bearishAbsorption
sellPressure = bearScore >= mediumScore and bearScore > bullScore and not bullishAbsorption
absorptionPressure = bullishAbsorption or bearishAbsorption

strongBuy = buyPressure and bullScore >= strongScore
strongSell = sellPressure and bearScore >= strongScore
strongAbsorption = absorptionPressure and absorptionScore >= strongScore

// Labels/text cleaned: no "PRESSURE" and no "ABSORB".
pressureText =
     buyPressure ? "BUY " + str.tostring(bullScore) + "/10" :
     sellPressure ? "SELL " + str.tostring(bearScore) + "/10" :
     absorptionPressure and bullishAbsorption ? "BUY " + str.tostring(absorptionScore) + "/10" :
     absorptionPressure and bearishAbsorption ? "SELL " + str.tostring(absorptionScore) + "/10" :
     "NEUTRAL"

pressureColor =
     buyPressure ? buyPressureColor :
     sellPressure ? sellPressureColor :
     absorptionPressure ? absorptionColor :
     neutralColor

pressureScore =
     buyPressure ? bullScore :
     sellPressure ? bearScore :
     absorptionPressure ? absorptionScore :
     0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barcolor(colorCandles ? color.new(pressureColor, candleTransparency) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABEL STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label[] pressureLabels = array.new<label>()

f_storeLabel(_label) =>
    array.push(pressureLabels, _label)

    if array.size(pressureLabels) > maxLabels
        oldLabel = array.shift(pressureLabels)
        if not na(oldLabel)
            label.delete(oldLabel)

    0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showThisLabel =
     showLabels and
     (
         not showOnlyStrongLabels or
         strongBuy or
         strongSell or
         strongAbsorption
     ) and
     (
         buyPressure or
         sellPressure or
         absorptionPressure
     )

labelY =
     buyPressure or bullishAbsorption ?
     low - atrValue * labelAtrOffset :
     high + atrValue * labelAtrOffset

labelStyle =
     buyPressure or bullishAbsorption ?
     label.style_label_up :
     label.style_label_down

if showThisLabel
    newLabel = label.new(
         x=bar_index,
         y=labelY,
         text=pressureText,
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=labelStyle,
         color=color.new(pressureColor, labelTransparency),
         textcolor=color.white,
         size=labelSize
     )
    f_storeLabel(newLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATUS TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table pressureTable = table.new(position.top_right, 2, 7, border_width=1)

if barstate.islast and showStatusTable
    table.cell(pressureTable, 0, 0, "GFG Pressure", text_color=color.white, bgcolor=color.new(pressureColor, 0))
    table.cell(pressureTable, 1, 0, pressureText, text_color=color.white, bgcolor=color.new(pressureColor, 0))

    table.cell(pressureTable, 0, 1, "Score", text_color=color.white, bgcolor=color.new(color.black, 70))
    table.cell(pressureTable, 1, 1, str.tostring(pressureScore) + "/10", text_color=color.white, bgcolor=color.new(color.black, 70))

    table.cell(pressureTable, 0, 2, "Volume", text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(pressureTable, 1, 2, str.tostring(volumeRatio, "#.##") + "x", text_color=color.white, bgcolor=color.new(color.black, 75))

    table.cell(pressureTable, 0, 3, "Range / ATR", text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(pressureTable, 1, 3, str.tostring(rangeAtrRatio, "#.##") + "x", text_color=color.white, bgcolor=color.new(color.black, 75))

    table.cell(pressureTable, 0, 4, "Body %", text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(pressureTable, 1, 4, str.tostring(bodyPercent * 100, "#") + "%", text_color=color.white, bgcolor=color.new(color.black, 75))

    table.cell(pressureTable, 0, 5, "Close Loc", text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(pressureTable, 1, 5, str.tostring(closeLocation * 100, "#") + "%", text_color=color.white, bgcolor=color.new(color.black, 75))

    table.cell(pressureTable, 0, 6, "VWAP", text_color=color.white, bgcolor=color.new(color.black, 75))
    table.cell(pressureTable, 1, 6, aboveVwap ? "Above" : "Below", text_color=color.white, bgcolor=color.new(color.black, 75))

if barstate.islast and not showStatusTable
    table.clear(pressureTable, 0, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(strongBuy, title="Strong Buy Pressure", message="GFG Institutional Pressure: Strong BUY pressure detected")
alertcondition(strongSell, title="Strong Sell Pressure", message="GFG Institutional Pressure: Strong SELL pressure detected")
alertcondition(strongAbsorption, title="Strong Absorption", message="GFG Institutional Pressure: Strong absorption detected")

alertcondition(buyPressure, title="Buy Pressure", message="GFG Institutional Pressure: BUY pressure detected")
alertcondition(sellPressure, title="Sell Pressure", message="GFG Institutional Pressure: SELL pressure detected")
alertcondition(absorptionPressure, title="Absorption Pressure", message="GFG Institutional Pressure: Absorption detected")
````
