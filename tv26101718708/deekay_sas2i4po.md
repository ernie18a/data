# DeeKay

- url: https://www.tradingview.com/script/sAs2I4PO-DeeKay/
- type: indicator
- pine_id: PUB;bf01c4ab9e0d441d9f0df34a62fc3b55
- version: 1.0

## Description

DeeKay Provides strong Higher Lower swing indicator

## Source Code

````pine
//@version=6
indicator("DeeKay", overlay=true, max_labels_count=500)

// Inputs
swingLength = input.int(50, "Swing Length", minval=10)

// LuxAlgo Leg Logic
BULLISH_LEG = 1
BEARISH_LEG = 0

leg(size) =>
    var int leg = 0

    newLegHigh = high[size] > ta.highest(size)
    newLegLow  = low[size]  < ta.lowest(size)

    if newLegHigh
        leg := BEARISH_LEG
    else if newLegLow
        leg := BULLISH_LEG

    leg

startOfNewLeg(legValue) =>
    ta.change(legValue) != 0

startOfBearishLeg(legValue) =>
    ta.change(legValue) == -1

startOfBullishLeg(legValue) =>
    ta.change(legValue) == 1

// Current Structure
currentLeg = leg(swingLength)

newPivot  = startOfNewLeg(currentLeg)
pivotLow  = startOfBullishLeg(currentLeg)
pivotHigh = startOfBearishLeg(currentLeg)

// Storage
var float lastSwingHigh = na
var float currentSwingHigh = na

var float lastSwingLow = na
var float currentSwingLow = na

// Detect swings and label HH HL LH LL
if newPivot

    if pivotLow
        lastSwingLow := currentSwingLow
        currentSwingLow := low[swingLength]

        string lowLabel = na(lastSwingLow) ? "L" :
             currentSwingLow < lastSwingLow ? "LL" : "HL"

        label.new(
             bar_index[swingLength],
             currentSwingLow,
             lowLabel,
             style=label.style_label_up,
             color=color.new(color.green, 100),
             textcolor=color.green,
             size=size.small)

    else
        lastSwingHigh := currentSwingHigh
        currentSwingHigh := high[swingLength]

        string highLabel = na(lastSwingHigh) ? "H" :
             currentSwingHigh > lastSwingHigh ? "HH" : "LH"

        label.new(
             bar_index[swingLength],
             currentSwingHigh,
             highLabel,
             style=label.style_label_down,
             color=color.new(color.red, 100),
             textcolor=color.red,
             size=size.small)
````
