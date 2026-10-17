#  PI Radius Energy (PRE)

- url: https://www.tradingview.com/script/4J5nWtyR/
- type: indicator
- pine_id: PUB;37607c3a7955484cbb3ebe3ce67f9279
- version: 1.0

## Description

# PI Radius Energy (PRE)

PI Radius Energy (PRE) is a momentum and volatility fusion engine designed to transform traditional ATR data into a dynamic circular energy model.

Instead of treating ATR as a simple volatility measurement, PRE interprets ATR as a radius and converts it into an energy field using the mathematical relationship of a circle:

π × r²

This approach allows market volatility to be expressed as an expanding or contracting energy field rather than a linear value. The resulting energy is then combined with OBV momentum flow, creating a unique representation of market participation, pressure, and directional strength.

The core objective of PRE is not to chase trends after they have already developed, but to identify the moments when energy begins to build beneath the surface. By combining circular volatility expansion, volume flow acceleration, squeeze detection, and momentum confirmation, PRE attempts to highlight areas where market energy is transitioning from compression to expansion.

### Main Components

• PI Radius Engine (πr² volatility model)
• OBV Momentum Flow Integration
• Dynamic Energy Normalization
• Squeeze Compression Detection
• Energy Trend EMA Filter
• ATR Rank & Volume Rank Validation
• Momentum Z-Score Filtering
• 3D Aura Visualization
• Early Bottom Detection Pills
• Bullish Confirmation Signals

### How to Read PRE

**Green Aura**

* Energy is above its average.
* Market pressure is expanding.
* Bullish conditions are strengthening.

**Red Aura**

* Energy is below its average.
* Market pressure is weakening.
* Bearish conditions are dominant.

**Green Pills**

* Early signs of energy expansion.
* Potential transition from compression to movement.
* Designed to appear before major momentum phases whenever possible.

**Yellow Confirmation Pills**

* Additional confirmation that energy has crossed into a stronger bullish state.

**Purple Energy Trend Line**

* Long-term energy trend.
* Helps distinguish temporary spikes from sustained energy expansion.

### Philosophy Behind PRE

Most indicators measure price.

Some indicators measure volume.

PRE attempts to measure something different:

**Market Energy.**

By transforming volatility into a circular energy field and combining it with volume-driven momentum, PRE seeks to provide a different perspective on trend development, accumulation, expansion phases, and emerging directional pressure.

PRE is not intended to predict the future. Instead, it is designed to visualize how market energy evolves, contracts, and expands over time, helping traders identify potential opportunities before they become obvious to the broader market.

## Source Code

````pine
//@version=6
indicator("PI ATR OBV ENERGY • 3D Aura Squeeze Pills EMA200", shorttitle="PI OBV SQZ EMA200", overlay=false, max_lines_count=200, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
atrLen     = input.int(14, "ATR Length", minval=1)
obvLen     = input.int(14, "OBV ROC Length", minval=1)
smoothLen  = input.int(9,  "Energy Smooth", minval=1)
avgLen     = input.int(5,  "Energy Average", minval=1)
scaleLen   = input.int(100,"Normalize Length", minval=20)
buffer     = input.float(0.0, "Average Buffer", step=0.1)

showPanel  = input.bool(true, "Show Panel")
showDots   = input.bool(true, "Show Pills")

sqzLen     = input.int(34, "Squeeze Length", minval=10)
sqzFactor  = input.float(0.75, "Squeeze Sensitivity", step=0.05)
bottomZone = input.float(45.0, "Bottom Zone", step=1)
pillPower  = input.float(8.0, "Green Power Pill Strength", step=0.5)

useLightFilter = input.bool(true, "Use Light Filter")
filterLen      = input.int(50, "Filter Rank Length", minval=20)
atrMinRank     = input.float(40.0, "Min ATR Rank", step=1)
volMinRank     = input.float(40.0, "Min Volume Rank", step=1)
momLen         = input.int(5, "Momentum ROC Length", minval=1)
zLen           = input.int(30, "Mini Z Length", minval=10)
minZ           = input.float(-0.25, "Min Momentum Z", step=0.05)

useEnergyEMA200 = input.bool(true, "Use Energy EMA200 Filter")
energyTrendLen  = input.int(200, "Energy Trend EMA Length", minval=20)

//━━━━━━━━━━━━━━━━━━━
// CORE
//━━━━━━━━━━━━━━━━━━━
atrValue = ta.atr(atrLen)
atrArea  = math.pi * math.pow(atrValue, 2)

obv     = ta.obv
obvRoc  = ta.roc(obv, obvLen)
obvRoot = obvRoc >= 0 ? math.sqrt(math.abs(obvRoc)) : -math.sqrt(math.abs(obvRoc))

rawEnergy = atrArea * obvRoot

lowestE  = ta.lowest(rawEnergy, scaleLen)
highestE = ta.highest(rawEnergy, scaleLen)

energyNorm = highestE != lowestE ? 100 * (rawEnergy - lowestE) / (highestE - lowestE) : 50
energy     = ta.ema(energyNorm, smoothLen)
energyAvg  = ta.ema(energy, avgLen)
avgLine    = energyAvg + buffer

energyTrend = ta.ema(energy, energyTrendLen)
trendBull   = energy > energyTrend
trendOK     = not useEnergyEMA200 or trendBull

//━━━━━━━━━━━━━━━━━━━
// LIGHT FILTER
//━━━━━━━━━━━━━━━━━━━
atrRank = ta.percentrank(atrValue, filterLen)
volRank = ta.percentrank(volume, filterLen)

mom     = ta.roc(close, momLen)
momMean = ta.sma(mom, zLen)
momDev  = ta.stdev(mom, zLen)
momZ    = momDev != 0 ? (mom - momMean) / momDev : 0.0

atrOK = atrRank >= atrMinRank
volOK = volRank >= volMinRank
zOK   = momZ >= minZ 

filterOK = not useLightFilter or (atrOK and volOK and zOK)

//━━━━━━━━━━━━━━━━━━━
// AURA
//━━━━━━━━━━━━━━━━━━━
spread    = energy - avgLine
absSpread = math.abs(spread)

bullAura = spread > 0
bearAura = spread < 0

energyColor = bullAura ? color.new(#00E5A8, 0) :
              bearAura ? color.new(#FF5252, 0) :
              color.new(color.gray, 35)

avgColor = bullAura ? color.new(#00E5A8, 55) :
           bearAura ? color.new(#FF5252, 55) :
           color.new(color.gray, 65)

auraColor = bullAura ?
     color.from_gradient(absSpread, 0, 30, color.new(#00E5A8, 88), color.new(#00E5A8, 20)) :
     bearAura ?
     color.from_gradient(absSpread, 0, 30, color.new(#FF5252, 88), color.new(#FF5252, 20)) :
     color.new(color.gray, 92)

//━━━━━━━━━━━━━━━━━━━
// SQUEEZE BOTTOM ENGINE
//━━━━━━━━━━━━━━━━━━━
energyVol = ta.stdev(energy, sqzLen)
avgVol    = ta.sma(energyVol, sqzLen)

isSqueeze  = energyVol < avgVol * sqzFactor
wasSqueeze = ta.barssince(isSqueeze) <= 6

bottomReady = energy < bottomZone or ta.lowest(energy, 8) < bottomZone

obvTurn    = obvRoot > obvRoot[1]
energyTurn = energy > energy[1] and energy[1] <= energy[2]

earlyBull   = showDots and filterOK and trendOK and wasSqueeze and bottomReady and energyTurn and obvTurn
confirmBull = showDots and filterOK and trendOK and ta.crossover(energy, avgLine) and wasSqueeze

powerBull = showDots and filterOK and trendOK and bullAura and absSpread >= pillPower and energy > energy[1] and obvRoot > obvRoot[1]

//━━━━━━━━━━━━━━━━━━━
// 3D DEPTH
//━━━━━━━━━━━━━━━━━━━
depth1 = avgLine + spread * 0.75
depth2 = avgLine + spread * 0.50
depth3 = avgLine + spread * 0.25

pDepth1 = plot(depth1, "3D Depth 1", color=bullAura ? color.new(#00E5A8, 84) : color.new(#FF5252, 84), linewidth=6)
pDepth2 = plot(depth2, "3D Depth 2", color=bullAura ? color.new(#00E5A8, 91) : color.new(#FF5252, 91), linewidth=8)
pDepth3 = plot(depth3, "3D Depth 3", color=color.new(color.gray, 100), linewidth=1)

pEnergy = plot(energy, "PI ATR OBV Energy", color=energyColor, linewidth=3)
pAvg    = plot(avgLine, "Energy Average", color=avgColor, linewidth=2)
pTrend = plot(energyTrend, "Energy EMA200",
     color=color.new(#8840fb, 0),
     linewidth=3)

fill(pEnergy, pAvg, color=auraColor, title="Main Aura")
fill(pDepth1, pDepth2, color=bullAura ? color.new(#00E5A8, 88) : color.new(#FF5252, 88), title="3D Glow")
fill(pDepth2, pDepth3, color=bullAura ? color.new(#00E5A8, 94) : color.new(#FF5252, 94), title="Soft Depth")

//━━━━━━━━━━━━━━━━━━━
// PILLS
//━━━━━━━━━━━━━━━━━━━
earlyDot   = earlyBull ? energy : na
powerDot   = powerBull and not earlyBull ? energy : na
confirmDot = confirmBull ? energy : na

plot(earlyDot, "Early Bottom Pill Outer", style=plot.style_circles, linewidth=13, color=color.new(#00E5A8, 72))
plot(earlyDot, "Early Bottom Pill Core",  style=plot.style_circles, linewidth=6, color=color.new(#00E5A8, 0))

plot(powerDot, "Green Power Pill Outer", style=plot.style_circles, linewidth=9, color=color.new(#00E5A8, 78))
plot(powerDot, "Green Power Pill Core",  style=plot.style_circles, linewidth=4, color=color.new(#00E5A8, 0))

plot(confirmDot, "Confirm Pill Outer", style=plot.style_circles, linewidth=12, color=color.new(#FFFF00, 75))
plot(confirmDot, "Confirm Pill Core",  style=plot.style_circles, linewidth=5, color=color.new(#FFFF00, 0))

//━━━━━━━━━━━━━━━━━━━
// LEVELS
//━━━━━━━━━━━━━━━━━━━
hline(80, "High Zone", color=color.new(#FF5252, 75))
hline(50, "Middle", color=color.new(color.gray, 82))
hline(20, "Low Zone", color=color.new(#00E5A8, 75))

//━━━━━━━━━━━━━━━━━━━
// PANEL
//━━━━━━━━━━━━━━━━━━━
stateText = earlyBull ? "EARLY BOTTOM" : confirmBull ? "CONFIRM BULL" : powerBull ? "GREEN POWER" : trendBull ? "ENERGY TREND BULL" : bullAura ? "BULL AURA" : bearAura ? "BEAR AURA" : "NEUTRAL"
stateCol  = earlyBull ? color.new(#00E5A8, 0) : confirmBull ? color.yellow : powerBull ? color.new(#00E5A8, 0) : trendBull ? color.new(#00E5A8, 0) : bearAura ? color.new(#FF5252, 0) : color.gray

if barstate.islast and showPanel
    var table pan = table.new(
         position.bottom_right,
         2,
         8,
         bgcolor=color.new(#070707, 5),
         border_width=1,
         border_color=color.new(color.gray, 65))

    table.cell(pan, 0, 0, "PI", text_color=color.white, text_size=size.small)
    table.cell(pan, 1, 0, "PRO", text_color=color.gray, text_size=size.small)

    table.cell(pan, 0, 1, "ENG", text_color=color.gray, text_size=size.small)
    table.cell(pan, 1, 1, str.tostring(energy, "#.#"),
         text_color=energyColor,
         text_size=size.small)

    table.cell(pan, 0, 2, "EMA", text_color=color.gray, text_size=size.small)
    table.cell(pan, 1, 2, str.tostring(energyTrend, "#.#"),
         text_color=color.new(#8840fb, 0),
         text_size=size.small)

    table.cell(pan, 0, 3, "SPD", text_color=color.gray, text_size=size.small)
    table.cell(pan, 1, 3, str.tostring(spread, "#.#"),
         text_color=stateCol,
         text_size=size.small)

    table.cell(pan, 0, 4, "SQZ", text_color=color.gray, text_size=size.small)
    table.cell(pan, 1, 4, isSqueeze ? "ON" : "OFF",
         text_color=isSqueeze ? color.yellow : color.gray,
         text_size=size.small)

    table.cell(pan, 0, 5, "ATR", text_color=color.gray, text_size=size.small)
    table.cell(pan, 1, 5, str.tostring(atrRank, "#"),
         text_color=atrOK ? color.new(#00E5A8, 0) : color.orange,
         text_size=size.small)

    table.cell(pan, 0, 6, "VOL", text_color=color.gray, text_size=size.small)
    table.cell(pan, 1, 6, str.tostring(volRank, "#"),
         text_color=volOK ? color.new(#00E5A8, 0) : color.orange,
         text_size=size.small)

    table.cell(pan, 0, 7, "Z", text_color=color.gray, text_size=size.small)
    table.cell(pan, 1, 7, str.tostring(momZ, "#.##"),
         text_color=zOK ? color.new(#00E5A8, 0) : color.orange,
         text_size=size.small)
//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(earlyBull, "Early Squeeze Bottom EMA200", "PI OBV SQZ EMA200: Early bottom {{ticker}} @ {{close}}")
alertcondition(confirmBull, "Squeeze Bull Confirm EMA200", "PI OBV SQZ EMA200: Bull confirm {{ticker}} @ {{close}}")
alertcondition(powerBull, "Green Power Pill EMA200", "PI OBV SQZ EMA200: Green power pill {{ticker}} @ {{close}}")
````
