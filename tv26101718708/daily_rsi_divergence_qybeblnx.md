# Daily RSI divergence

- url: https://www.tradingview.com/script/qybEBLnx-Daily-RSI-divergence/
- type: indicator
- pine_id: PUB;99f0ff7781944038a03497b1e74e7e89
- version: 1.0

## Description

Script to find RSI divergences in all[image]https://www.tradingview.com/x/eBrz5wau/[/image] different time frames with a few tweaking point.

## Source Code

````pine
//@version=6
indicator("Daily RSI divergence", overlay=true, max_labels_count=500)

// Inputs
rsiLength = input.int(9, "RSI Length")
pivotLeft = input.int(2, "Pivot Left")
pivotRight = input.int(2, "Pivot Right")

bullRsiThreshold = input.float(100.0, "Bullish RSI Must Be Below")
bearRsiThreshold = input.float(0.0, "Bearish RSI Must Be Above")

minRsiDiff = input.float(0.5, "Minimum RSI Difference")
minPriceDiffPct = input.float(0.10, "Minimum Price Difference %")

useConfirmation = input.bool(false, "Require Price Confirmation")
showOnlyDaily = input.bool(true, "Show Only On Daily Chart")

// Daily chart filter
isDailyChart = timeframe.isdaily
canShow = not showOnlyDaily or isDailyChart

// Core data
rsiValue = ta.rsi(close, rsiLength)

// Price pivots only
pivotLowPrice = ta.pivotlow(low, pivotLeft, pivotRight)
pivotHighPrice = ta.pivothigh(high, pivotLeft, pivotRight)

// RSI at the price pivot candle
rsiAtPivotLow = rsiValue[pivotRight]
rsiAtPivotHigh = rsiValue[pivotRight]

// Previous pivot storage
var float prevPriceLow = na
var float prevRsiLow = na
var float prevPriceHigh = na
var float prevRsiHigh = na

// Signals
bool bullishDivRaw = false
bool bearishDivRaw = false

// Reset every bar
bullishDivRaw := false
bearishDivRaw := false

// Bullish divergence
if not na(pivotLowPrice)
    float currentPriceLow = pivotLowPrice
    float currentRsiLow = rsiAtPivotLow

    bool priceLowerLow = not na(prevPriceLow) and currentPriceLow < prevPriceLow
    bool rsiHigherLow = not na(prevRsiLow) and currentRsiLow > prevRsiLow

    bool rsiWasWeak = not na(prevRsiLow) and prevRsiLow < bullRsiThreshold
    bool enoughRsiDiff = not na(prevRsiLow) and math.abs(currentRsiLow - prevRsiLow) >= minRsiDiff
    bool enoughPriceDiff = not na(prevPriceLow) and math.abs(currentPriceLow - prevPriceLow) / prevPriceLow * 100 >= minPriceDiffPct

    bullishDivRaw := priceLowerLow and rsiHigherLow and rsiWasWeak and enoughRsiDiff and enoughPriceDiff

    prevPriceLow := currentPriceLow
    prevRsiLow := currentRsiLow

// Bearish divergence
if not na(pivotHighPrice)
    float currentPriceHigh = pivotHighPrice
    float currentRsiHigh = rsiAtPivotHigh

    bool priceHigherHigh = not na(prevPriceHigh) and currentPriceHigh > prevPriceHigh
    bool rsiLowerHigh = not na(prevRsiHigh) and currentRsiHigh < prevRsiHigh

    bool rsiWasStrong = not na(prevRsiHigh) and prevRsiHigh > bearRsiThreshold
    bool enoughRsiDiffBear = not na(prevRsiHigh) and math.abs(currentRsiHigh - prevRsiHigh) >= minRsiDiff
    bool enoughPriceDiffBear = not na(prevPriceHigh) and math.abs(currentPriceHigh - prevPriceHigh) / prevPriceHigh * 100 >= minPriceDiffPct

    bearishDivRaw := priceHigherHigh and rsiLowerHigh and rsiWasStrong and enoughRsiDiffBear and enoughPriceDiffBear

    prevPriceHigh := currentPriceHigh
    prevRsiHigh := currentRsiHigh

// Confirmation
bullConfirm = close > close[1]
bearConfirm = close < close[1]

bool bullishDiv = bullishDivRaw and (not useConfirmation or bullConfirm)
bool bearishDiv = bearishDivRaw and (not useConfirmation or bearConfirm)

// Labels
if canShow and bullishDiv
    label.new(x=bar_index - pivotRight, y=na, text="Bull RSI Div", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, textcolor=color.white, color=color.green)

if canShow and bearishDiv
    label.new(x=bar_index - pivotRight, y=na, text="Bear RSI Div", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, textcolor=color.white, color=color.red)
````
