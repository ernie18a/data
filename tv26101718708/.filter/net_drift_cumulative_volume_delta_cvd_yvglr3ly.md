# Net Drift Cumulative Volume Delta (CVD)

- url: https://www.tradingview.com/script/yVglr3Ly-Net-Drift-Cumulative-Volume-Delta-CVD/
- type: indicator
- pine_id: PUB;f1f5afa8fffe4a759e2b8ebfa222a2e3
- version: 2.0

## Description

Use to determine dealer conviction on moves if false breakout great tool when paired with net drift and delta levels works bet on 5 min and 1 min charts made for intra day scalping.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © creamofedenbutters
//@version=6
plot(close)
//@version=6
indicator("Net Drift Cumulative Volume Delta (CVD)", overlay=false)

// --- INPUTS ---
fastLength = input.int(9, title="Fast Length (9)")
slowLength = input.int(21, title="Slow Length (21)")
volCheckLen = input.int(5, title="Short-Term Volume Lookback")

// --- GLOBAL HISTORICAL CALCULATIONS ---
is_new_session = ta.change(time("D")) != 0

isBullish = close > open
candleDelta = isBullish ? volume : -volume

// Track individual bar changes globally for consistency
cvdChange = ta.change(candleDelta)

// --- CORE CVD ENGINE ---
var float cvdWave = 0.0
if is_new_session
    cvdWave := candleDelta
else
    cvdWave := cvdWave + candleDelta

// Smooth the wave with an institutional average line (9 EMA)
cvdSignalLine = ta.ema(cvdWave, fastLength)

// --- VOLUME AVERAGE & DRY-UP CALCULATIONS ---
avgVol9 = ta.sma(volume, fastLength)
avgVol21 = ta.sma(volume, slowLength)

// Short-term volume compared to long-term baseline
shortVolSma = ta.sma(volume, volCheckLen)
// True when short-term volume drops to 75% or lower of the 21-period baseline
isVolumeDrying = shortVolSma < (avgVol21 * 0.75)

// Additional global metrics for checklist conditions
highestCVD = ta.highest(cvdWave, fastLength)
lowestCVD = ta.lowest(cvdWave, fastLength)
cvdCrossedOver = ta.crossover(cvdWave, cvdSignalLine)
cvdCrossedUnder = ta.crossunder(cvdWave, cvdSignalLine)

// --- VISUAL PLOTTING ---
// Plot the main Cumulative Wave
waveColor = cvdWave >= cvdSignalLine ? color.green : color.red
plot(cvdWave, title="CVD Institutional Wave", color=waveColor, linewidth=3)

// Fixed Line Style Syntax for Version 6
plot(cvdSignalLine, title="Signal Smooth Line (9 EMA)", color=color.gray, linewidth=1, style=plot.style_line)

// --- THE LONGEVITY LOOK (Your Condition Checklist) ---
bullishIgnition = cvdCrossedOver and cvdWave == highestCVD
// Triggers when the wave is high/bullish, but volume has dried up and momentum is stalling
volumeDryExhaustion = cvdWave >= cvdSignalLine and isVolumeDrying and (cvdWave < highestCVD or cvdChange < 0)

// --- VISUAL SIGNAL MARKERS ON THE WAVE ---
// Green Triangle: Bullish ignition / institutional surge
plotshape(bullishIgnition, title="Longevity Run Confirmed", style=shape.triangleup, location=location.bottom, color=color.green, size=size.small)

// Yellow/Orange Triangle: Volume drying up / momentum fading before the flip
plotshape(volumeDryExhaustion, title="Volume Drying Up / Exhaustion", style=shape.triangledown, location=location.top, color=color.orange, size=size.small)

// --- AVERAGE VOLUME NUMBERS (Hidden line, visible in status header) ---
plot(avgVol9, title="9-Bar Avg Vol", color=color.new(color.teal, 100))
plot(avgVol21, title="21-Bar Avg Vol", color=color.new(color.orange, 100))
````
