# TRNDREVERSAL Demand/Supply 

- url: https://www.tradingview.com/script/vTFMngTK-TRNDREVERSAL-Demand-Supply/
- type: indicator
- pine_id: PUB;4c0b47c685b14d7d877fd29439d366d0
- version: 3.0

## Description

Demand/ Supply zone script with change of character. Gives you an entry and exit based on structure break with volume confirmation, Also comes with stop loss and possible gtarget based on previous key levels.

## Source Code

````pine
//@version=6
indicator("HTF Zone + CHoCH + Delta Outlier (Automation Ready)", overlay=true, max_boxes_count=500)

// --- Inputs ---
leftBars  = input.int(15, title="HTF Pivot Left Bars")
rightBars = input.int(15, title="HTF Pivot Right Bars")
zoneMult  = input.float(2.0, title="Zone Width Multiplier (ATR)")
rrRatio   = input.float(2.5, title="Risk to Reward Ratio")

deltaLength = input.int(20, title="Delta Threshold Lookback", group="Delta Settings")
deltaStDev  = input.float(2.0, title="Delta Outlier Multiplier (StDev)", group="Delta Settings")

// --- Technical Calculations ---
atr = ta.atr(14)
pHi = ta.pivothigh(high, leftBars, rightBars)
pLo = ta.pivotlow(low, leftBars, rightBars)

// Volume Delta Proxy
candleRange = high - low
closeness   = candleRange == 0 ? 0.5 : (close - low) / candleRange
volumeDelta = volume * (closeness - 0.5) * 2.0

avgDelta   = ta.sma(volumeDelta, deltaLength)
stDevDelta = ta.stdev(volumeDelta, deltaLength)
upperBand  = avgDelta + (stDevDelta * deltaStDev)
lowerBand  = avgDelta - (stDevDelta * deltaStDev)

largePositiveDelta = volumeDelta > upperBand
largeNegativeDelta = volumeDelta < lowerBand

// --- Custom Types for Active Zones ---
type Zone
    box   zoneBox
    float top
    float bottom
    bool  isSupply
    bool  isLive

var Zone[] activeZones = array.new<Zone>()

if not na(pHi)
    int leftIdx = bar_index - rightBars
    int rightIdx = bar_index
    float topPrice = high[rightBars]
    float botPrice = high[rightBars] - (atr[rightBars] * zoneMult)
    box b = box.new(left=leftIdx, top=topPrice, right=rightIdx, bottom=botPrice, bgcolor=color.new(color.red, 92), border_color=color.new(color.red, 50))
    array.push(activeZones, Zone.new(b, topPrice, botPrice, true, true))

if not na(pLo)
    int leftIdx = bar_index - rightBars
    int rightIdx = bar_index
    float topPrice = low[rightBars] + (atr[rightBars] * zoneMult)
    float botPrice = low[rightBars]
    box b = box.new(left=leftIdx, top=topPrice, right=rightIdx, bottom=botPrice, bgcolor=color.new(color.green, 92), border_color=color.new(color.green, 50))
    array.push(activeZones, Zone.new(b, topPrice, botPrice, false, true))

bool demandHit = false
bool supplyHit = false

if array.size(activeZones) > 0
    for i = array.size(activeZones) - 1 to 0
        Zone z = array.get(activeZones, i)
        if z.isLive
            box.set_right(z.zoneBox, bar_index)
            if z.isSupply and high >= z.bottom
                z.isLive := false
                supplyHit := true
                box.set_bgcolor(z.zoneBox, color.new(color.gray, 95))
                box.set_border_color(z.zoneBox, color.new(color.gray, 80))
            else if not z.isSupply and low <= z.top
                z.isLive := false
                demandHit := true
                box.set_bgcolor(z.zoneBox, color.new(color.gray, 95))
                box.set_border_color(z.zoneBox, color.new(color.gray, 80))

var float lastPivotLow = na
var float lastPivotHigh = na
var bool chochBullish = false
var bool chochBearish = false

if not na(pLo)
    lastPivotLow := low[rightBars]
if not na(pHi)
    lastPivotHigh := high[rightBars]

if demandHit
    chochBullish := false 
if supplyHit
    chochBearish := false 

if demandHit and not na(lastPivotHigh) and ta.crossover(close, lastPivotHigh)
    chochBullish := true
if supplyHit and not na(lastPivotLow) and ta.crossunder(close, lastPivotLow)
    chochBearish := true

// Execution Checkers
longConfirmed = false
shortConfirmed = false
var float longSL = na, var float longTP = na
var float shortSL = na, var float shortTP = na

if chochBullish and not na(pLo)
    currentPivotLow = low[rightBars]
    if currentPivotLow > lastPivotLow[1] and largePositiveDelta
        longConfirmed := true
        chochBullish := false 
        longSL := currentPivotLow
        longTP := close + ((close - longSL) * rrRatio)

if chochBearish and not na(pHi)
    currentPivotHigh = high[rightBars]
    if currentPivotHigh < lastPivotHigh[1] and largeNegativeDelta
        shortConfirmed := true
        chochBearish := false 
        shortSL := currentPivotHigh
        shortTP := close - ((shortSL - close) * rrRatio)

// --- Automation Alert Engines ---
if longConfirmed
    alert("LONG_ENTRY_SL_" + str.tostring(longSL) + "_TP_" + str.tostring(longTP), alert.freq_once_per_bar_close)
if shortConfirmed
    alert("SHORT_ENTRY_SL_" + str.tostring(shortSL) + "_TP_" + str.tostring(shortTP), alert.freq_once_per_bar_close)

// Visuals
color barColorChoice = chochBullish ? color.green : chochBearish ? color.red : na
barcolor(barColorChoice)
plotshape(longConfirmed, title="Long Arrow", style=shape.arrowup, location=location.belowbar, color=color.green, size=size.large)
plotshape(shortConfirmed, title="Short Arrow", style=shape.arrowdown, location=location.abovebar, color=color.red, size=size.large)
````
