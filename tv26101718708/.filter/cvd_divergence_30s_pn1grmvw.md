# CVD + Divergence (30s)

- url: https://www.tradingview.com/script/PN1GrMVW/
- type: indicator
- pine_id: PUB;3108898e92de4319a99cc9ea867e756e
- version: 1.0

## Description

pour la methode Eleazar : 

prise de position quand divergence entre le prix et le CVD

## Source Code

````pine
//@version=6
indicator("CVD + Divergence (robuste 30s)", "CVD Div 30s", format=format.volume, max_labels_count=500)

import TradingView/ta/8

anchorInput = input.timeframe("1D", "Anchor period")

useCustomTimeframeInput = input.bool(false, "Use custom lower timeframe")
lowerTimeframeInput = input.timeframe("5S", "Custom lower timeframe")

pivotLeft  = input.int(3, "Pivot left", minval=1)
pivotRight = input.int(3, "Pivot right", minval=1)

showBull = input.bool(true, "Show bullish divergence")
showBear = input.bool(true, "Show bearish divergence")
confirmOnClose = input.bool(true, "Confirm only on bar close")

var string lowerTimeframe = na
lowerTimeframe := switch
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.period == "30S" => "5S"
    timeframe.isseconds      => "1S"
    timeframe.isintraday     => "1"
    timeframe.isdaily        => "5"
    => "60"

[openVolume, maxVolume, minVolume, lastVolume] = ta.requestVolumeDelta(lowerTimeframe, anchorInput)

cvdColor = lastVolume >= openVolume ? color.teal : color.red
hline(0)
plotcandle(openVolume, maxVolume, minVolume, lastVolume, "CVD", color=cvdColor, bordercolor=cvdColor, wickcolor=cvdColor)

var float cumVol = 0.0
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume data available for this symbol.")

// === Pivot detection on PRICE ===
pricePivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)
pricePivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)

// === Pivot detection on CVD ===
cvdPivotLow  = ta.pivotlow(lastVolume, pivotLeft, pivotRight)
cvdPivotHigh = ta.pivothigh(lastVolume, pivotLeft, pivotRight)

// Current confirmed pivot values
currPriceLow  = pricePivotLow
currPriceHigh = pricePivotHigh
currCvdLow    = cvdPivotLow
currCvdHigh   = cvdPivotHigh

// Previous pivot values
prevPriceLow  = ta.valuewhen(not na(pricePivotLow), pricePivotLow, 1)
prevPriceHigh = ta.valuewhen(not na(pricePivotHigh), pricePivotHigh, 1)
prevCvdLow    = ta.valuewhen(not na(cvdPivotLow), cvdPivotLow, 1)
prevCvdHigh   = ta.valuewhen(not na(cvdPivotHigh), cvdPivotHigh, 1)

// === Divergences ===
bullCondRaw = (
    not na(currPriceLow) and
    not na(currCvdLow) and
    not na(prevPriceLow) and
    not na(prevCvdLow) and
    currPriceLow < prevPriceLow and
    currCvdLow > prevCvdLow
)

bearCondRaw = (
    not na(currPriceHigh) and
    not na(currCvdHigh) and
    not na(prevPriceHigh) and
    not na(prevCvdHigh) and
    currPriceHigh > prevPriceHigh and
    currCvdHigh < prevCvdHigh
)

bullCond = confirmOnClose ? (bullCondRaw and barstate.isconfirmed) : bullCondRaw
bearCond = confirmOnClose ? (bearCondRaw and barstate.isconfirmed) : bearCondRaw

plot(showBull and not na(cvdPivotLow) ? cvdPivotLow : na,
     title="Bullish pivot",
     offset=-pivotRight,
     linewidth=2,
     color=bullCond ? color.lime : color.new(color.lime, 80))

plot(showBear and not na(cvdPivotHigh) ? cvdPivotHigh : na,
     title="Bearish pivot",
     offset=-pivotRight,
     linewidth=2,
     color=bearCond ? color.red : color.new(color.red, 80))

plotshape(showBull and bullCond ? cvdPivotLow : na,
     title="Bullish Div",
     offset=-pivotRight,
     style=shape.labelup,
     location=location.absolute,
     color=color.lime,
     textcolor=color.black,
     text="Bull")

plotshape(showBear and bearCond ? cvdPivotHigh : na,
     title="Bearish Div",
     offset=-pivotRight,
     style=shape.labeldown,
     location=location.absolute,
     color=color.red,
     textcolor=color.white,
     text="Bear")

alertcondition(bullCond, title="Bullish CVD Divergence", message="Bullish divergence detected between price and CVD.")
alertcondition(bearCond, title="Bearish CVD Divergence", message="Bearish divergence detected between price and CVD.")
````
