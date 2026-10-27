# CVD Candle Divergence

- url: https://www.tradingview.com/script/VE2bX58I-CVD-Candle-Divergence/
- type: indicator
- pine_id: PUB;348d924d00bc421d92382280df1bfe23
- version: 2.0

## Description

CVD Candle Divergence detects candle-by-candle divergence between price action and CVD: when price closes bearish while CVD closes bullish, or price closes bullish while CVD closes bearish. Divergence signals are shown with arrows on supported lower timeframes. This tool is designed for traders who want clearer insight into hidden buying/selling pressure, exhaustion, and potential reversals using CVD structure.

## Source Code

````pine
//@version=6
indicator("CVD Candle Divergence", overlay=false, format=format.volume, max_labels_count=500)

lowerTf    = input.timeframe("1", "Lower timeframe")
showArrows = input.bool(true, "Afficher flèches")
resetTZ    = input.string("America/New_York", "Timezone reset")
sessionStr = input.session("1800-1759", "Session CVD reset")

//====================================================
// LOWER TF VOLUME DELTA LOGIC
//====================================================
upDownVolume() =>
    var bool isBuyVolume = true

    if close > open
        isBuyVolume := true
    else if close < open
        isBuyVolume := false
    else if close > close[1]
        isBuyVolume := true
    else if close < close[1]
        isBuyVolume := false

    isBuyVolume ? volume : -volume

//====================================================
// LOWER TF ARRAYS
//====================================================
ltfDelta = request.security_lower_tf(
     syminfo.tickerid,
     lowerTf,
     upDownVolume()
)

ltfReset = request.security_lower_tf(
     syminfo.tickerid,
     lowerTf,
     ta.change(time("D", sessionStr, resetTZ)) != 0 ? 1.0 : 0.0
)

//====================================================
// BUILD CVD WITH INTRABAR SESSION RESET
//====================================================
var float cvdMemory = 0.0

float cvdOpen  = cvdMemory
float cvdHigh  = cvdMemory
float cvdLow   = cvdMemory
float cvdClose = cvdMemory

int sz = array.size(ltfDelta)

if sz > 0
    float running = cvdMemory

    for i = 0 to sz - 1
        float resetValue = array.get(ltfReset, i)

        if resetValue == 1.0
            running := 0.0
            cvdOpen := 0.0
            cvdHigh := 0.0
            cvdLow := 0.0

        running += array.get(ltfDelta, i)

        cvdHigh := running > cvdHigh ? running : cvdHigh
        cvdLow  := running < cvdLow ? running : cvdLow

    cvdClose := running
    cvdMemory := cvdClose

//====================================================
// DIRECTIONS
//====================================================
cvdBull = cvdClose > cvdOpen
cvdBear = cvdClose < cvdOpen

priceBull = close > open
priceBear = close < open

bullDiv = priceBear and cvdBull
bearDiv = priceBull and cvdBear

//====================================================
// PLOT CVD
//====================================================
plotcandle(
     cvdOpen,
     cvdHigh,
     cvdLow,
     cvdClose,
     title="CVD",
     color=cvdBull ? color.teal : color.red,
     wickcolor=cvdBull ? color.teal : color.red,
     bordercolor=cvdBull ? color.teal : color.red
)

hline(0, "Zero", color=color.gray)

//====================================================
// TOP ARROWS UP TO 4H INCLUDED
//====================================================
isAbove4H = timeframe.in_seconds(timeframe.period) > timeframe.in_seconds("240")
showTop = showArrows and not isAbove4H

plotshape(showTop and bullDiv, title="Bullish Div", style=shape.triangleup, location=location.top, color=color.lime, size=size.tiny)
plotshape(showTop and bearDiv, title="Bearish Div", style=shape.triangledown, location=location.top, color=color.red, size=size.tiny)

//====================================================
// ALERTS
//====================================================
alertcondition(bullDiv, title="Bullish Divergence", message="Price bearish candle + CVD bullish candle")
alertcondition(bearDiv, title="Bearish Divergence", message="Price bullish candle + CVD bearish candle")
````
