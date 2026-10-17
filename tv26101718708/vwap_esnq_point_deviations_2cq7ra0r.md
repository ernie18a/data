# VWAP + ES/NQ Point Deviations

- url: https://www.tradingview.com/script/2cq7ra0r-VWAP-ES-NQ-Point-Deviations/
- type: indicator
- pine_id: PUB;ea41fc8a39314388b25b84f1b370a1a7
- version: 1.0

## Description

VWAP + ES/NQ Point Deviations

User defined point deviation from VWAP

## Source Code

````pine
//@version=6
indicator("VWAP + ES/NQ Point Deviations", overlay=true)

//====================================================
// INPUTS
//====================================================
nqDev = input.float(50.0, "NQ Deviation (1.0)", step=0.25)
esDev = input.float(10.0, "ES Deviation (1.0)", step=0.25)

showFills = input.bool(true, "Show Zone Fills")

//====================================================
// SYMBOL DETECTION
//====================================================
isNQ = str.contains(syminfo.ticker, "NQ")
isES = str.contains(syminfo.ticker, "ES")

dev = isNQ ? nqDev : isES ? esDev : na
halfDev = dev * 0.5

//====================================================
// GLOBEX SESSION RESET (18:00)
//====================================================
isNewSession = (hour(time) == 18 and minute(time) == 0)

//====================================================
// CUMULATIVE VWAP
//====================================================
var float cumVol = na
var float cumPV  = na

if isNewSession or na(cumVol)
    cumVol := volume
    cumPV  := hlc3 * volume
else
    cumVol += volume
    cumPV  += hlc3 * volume

vwap = cumPV / cumVol

//====================================================
// LEVELS
//====================================================
uHalf = vwap + halfDev
lHalf = vwap - halfDev

uFull = vwap + dev
lFull = vwap - dev

//====================================================
// PLOTS
//====================================================
plot(vwap, "VWAP (Globex 18:00)", color=color.yellow, linewidth=2)

// hidden plots for fills
p0  = plot(vwap, display=display.none)
pU1 = plot(uHalf, display=display.none)
pU2 = plot(uFull, display=display.none)
pL1 = plot(lHalf, display=display.none)
pL2 = plot(lFull, display=display.none)

//====================================================
// FILLS
//====================================================
fill(p0, pU1, color=showFills ? color.new(color.green, 85) : na)
fill(pU1, pU2, color=showFills ? color.new(color.green, 75) : na)

fill(p0, pL1, color=showFills ? color.new(color.red, 85) : na)
fill(pL1, pL2, color=showFills ? color.new(color.red, 75) : na)

//====================================================
// OPTIONAL LINES
//====================================================
plot(uHalf, "Upper 0.5", color=color.new(color.green, 40))
plot(uFull, "Upper 1.0", color=color.new(color.green, 0))

plot(lHalf, "Lower 0.5", color=color.new(color.red, 40))
plot(lFull, "Lower 1.0", color=color.new(color.red, 0))
````
