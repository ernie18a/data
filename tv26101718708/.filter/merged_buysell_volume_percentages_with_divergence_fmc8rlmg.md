# Merged Buy/Sell Volume Percentages with Divergence

- url: https://www.tradingview.com/script/Fmc8RLmG-Merged-Buy-Sell-Volume-Percentages-with-Divergence/
- type: indicator
- pine_id: PUB;5651027bfb7c4fecbd616eebe402f457
- version: 1.0

## Description

the best script to determine the volume % with divergance. Only Options Trade Style.

## Source Code

````pine
//@version=5
indicator("Merged Buy/Sell Volume Percentages with Divergence", overlay = false, max_labels_count = 500)

// ──────────────────────────────────────────────────────────────
// Session logic
// ──────────────────────────────────────────────────────────────
inRTH = not na(time(timeframe.period, "0930-1700"))
newRTH = inRTH and not inRTH[1]

inETH = not na(time(timeframe.period, "1800-0929"))
newETH = inETH and not inETH[1]

// ──────────────────────────────────────────────────────────────
// RTH aggregates
// ──────────────────────────────────────────────────────────────
var int rth_barCount = 0
var float rth_dailyOpen = na
var float rth_dailyHigh = na
var float rth_dailyLow = na
var float rth_dailyClose = na
var float rth_dailyVolume = na

if newRTH
    rth_barCount := 1
    rth_dailyOpen := open
    rth_dailyHigh := high
    rth_dailyLow := low
    rth_dailyClose := close
    rth_dailyVolume := volume
else if inRTH
    rth_barCount += 1
    rth_dailyOpen := nz(rth_dailyOpen, open)
    rth_dailyHigh := math.max(nz(rth_dailyHigh, high), high)
    rth_dailyLow := math.min(nz(rth_dailyLow, low), low)
    rth_dailyClose := close
    rth_dailyVolume := nz(rth_dailyVolume) + volume

rth_SV = rth_dailyHigh != rth_dailyLow ? rth_dailyVolume * (rth_dailyHigh - rth_dailyClose) / (rth_dailyHigh - rth_dailyLow) : 0
rth_BV = rth_dailyHigh != rth_dailyLow ? rth_dailyVolume * (rth_dailyClose - rth_dailyLow) / (rth_dailyHigh - rth_dailyLow) : 0
rth_totalVol = inRTH ? rth_BV + rth_SV : na
rth_buyPercent = rth_totalVol > 0 ? math.round((rth_BV / rth_totalVol) * 10000) / 100 : 0
rth_sellPercent = rth_totalVol > 0 ? math.round((rth_SV / rth_totalVol) * 10000) / 100 : 0
rth_buyPlotValue = inRTH and rth_buyPercent > rth_sellPercent ? math.max(rth_buyPercent, 50) : na
rth_sellPlotValue = inRTH and rth_sellPercent > rth_buyPercent ? math.max(rth_sellPercent, 50) : na

plot(rth_buyPlotValue, "RTH Buy%", color.green, 2)
plot(rth_sellPlotValue, "RTH Sell%", color.red, 2)

arrowFloor = 50.0
rth_up = inRTH and ta.crossover(rth_buyPercent, rth_sellPercent) and rth_buyPercent > 1 and rth_sellPercent > 1 and rth_totalVol > 0 ? math.max(rth_buyPercent, arrowFloor) : na
rth_down = inRTH and ta.crossover(rth_sellPercent, rth_buyPercent) and rth_buyPercent > 1 and rth_sellPercent > 1 and rth_totalVol > 0 ? math.max(rth_sellPercent, arrowFloor) : na

plotshape(rth_up, title="RTH Up Arrow", style=shape.arrowup, location=location.absolute, color=color.green, size=size.small)
plotshape(rth_down, title="RTH Down Arrow", style=shape.arrowdown, location=location.absolute, color=color.red, size=size.small)

// RTH rolling std dev style
var float rth_volMean = na
rth_volMean := newRTH ? rth_dailyVolume : inRTH ? ((nz(rth_volMean[1]) * (nz(rth_barCount[1]) - 1)) + rth_dailyVolume) / rth_barCount : nz(rth_volMean[1])
rth_volSqrDiff = inRTH ? math.pow(rth_dailyVolume - rth_volMean, 2) : 0
var float rth_volSumSqrDiff = na
rth_volSumSqrDiff := newRTH ? rth_volSqrDiff : inRTH ? nz(rth_volSumSqrDiff[1]) + rth_volSqrDiff : nz(rth_volSumSqrDiff[1])
rth_volStdDev = rth_barCount > 1 and inRTH ? math.sqrt(rth_volSumSqrDiff / (rth_barCount - 1)) : 0
rth_volThirdStdDev = rth_volMean + 1.5 * rth_volStdDev

level50 = 50.0
level120 = 120.0
p50 = plot(level50, "Level 50", color.gray, 1, plot.style_linebr)
p120 = plot(level120, "Level 120", color.gray, 1, plot.style_linebr)
fill(plot(rth_buyPlotValue, display=display.none), p50, color.new(color.green, 80))
fill(plot(rth_sellPlotValue, display=display.none), p50, color.new(color.red, 80))

// ──────────────────────────────────────────────────────────────
// ETH aggregates
// ──────────────────────────────────────────────────────────────
var int eth_barCount = 0
var float eth_sessionOpen = na
var float eth_sessionHigh = na
var float eth_sessionLow = na
var float eth_sessionClose = na
var float eth_sessionVolume = na

if newETH
    eth_barCount := 1
    eth_sessionOpen := open
    eth_sessionHigh := high
    eth_sessionLow := low
    eth_sessionClose := close
    eth_sessionVolume := volume
else if inETH
    eth_barCount += 1
    eth_sessionOpen := nz(eth_sessionOpen, open)
    eth_sessionHigh := math.max(nz(eth_sessionHigh, high), high)
    eth_sessionLow := math.min(nz(eth_sessionLow, low), low)
    eth_sessionClose := close
    eth_sessionVolume := nz(eth_sessionVolume) + volume

eth_SV = eth_sessionHigh != eth_sessionLow ? eth_sessionVolume * (eth_sessionHigh - eth_sessionClose) / (eth_sessionHigh - eth_sessionLow) : 0
eth_BV = eth_sessionHigh != eth_sessionLow ? eth_sessionVolume * (eth_sessionClose - eth_sessionLow) / (eth_sessionHigh - eth_sessionLow) : 0
eth_totalVol = inETH ? eth_BV + eth_SV : na
eth_buyPercent = eth_totalVol > 0 ? math.round((eth_BV / eth_totalVol) * 10000) / 100 : 0
eth_sellPercent = eth_totalVol > 0 ? math.round((eth_SV / eth_totalVol) * 10000) / 100 : 0
eth_buyPlotValue = inETH and eth_buyPercent > eth_sellPercent ? math.max(eth_buyPercent, 50) : na
eth_sellPlotValue = inETH and eth_sellPercent > eth_buyPercent ? math.max(eth_sellPercent, 50) : na

plot(eth_buyPlotValue, "ETH Buy%", color.green, 2)
plot(eth_sellPlotValue, "ETH Sell%", color.red, 2)

eth_up = inETH and ta.crossover(eth_buyPercent, eth_sellPercent) and eth_buyPercent > 1 and eth_sellPercent > 1 and eth_totalVol > 0 ? math.max(eth_buyPercent, arrowFloor) : na
eth_down = inETH and ta.crossover(eth_sellPercent, eth_buyPercent) and eth_buyPercent > 1 and eth_sellPercent > 1 and eth_totalVol > 0 ? math.max(eth_sellPercent, arrowFloor) : na

plotshape(eth_up, title="ETH Up Arrow", style=shape.arrowup, location=location.absolute, color=color.green, size=size.small)
plotshape(eth_down, title="ETH Down Arrow", style=shape.arrowdown, location=location.absolute, color=color.red, size=size.small)

var float eth_volMean = na
eth_volMean := newETH ? eth_sessionVolume : inETH ? ((nz(eth_volMean[1]) * (nz(eth_barCount[1]) - 1)) + eth_sessionVolume) / eth_barCount : nz(eth_volMean[1])
eth_volSqrDiff = inETH ? math.pow(eth_sessionVolume - eth_volMean, 2) : 0
var float eth_volSumSqrDiff = na
eth_volSumSqrDiff := newETH ? eth_volSqrDiff : inETH ? nz(eth_volSumSqrDiff[1]) + eth_volSqrDiff : nz(eth_volSumSqrDiff[1])
eth_volStdDev = eth_barCount > 1 and inETH ? math.sqrt(eth_volSumSqrDiff / (eth_barCount - 1)) : 0
eth_volThirdStdDev = eth_volMean + 2 * eth_volStdDev

fill(plot(eth_buyPlotValue, display=display.none), p50, color.new(color.green, 80))
fill(plot(eth_sellPlotValue, display=display.none), p50, color.new(color.red, 80))

// ──────────────────────────────────────────────────────────────
// Labels via table
// ──────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 1, 4)

if barstate.islast
    table.cell(t, 0, 0, inRTH ? "RTH Buy%: " + str.tostring(rth_buyPercent) + " | Sell%: " + str.tostring(rth_sellPercent) : "",
      text_color=color.white, bgcolor=inRTH ? (rth_buyPercent > rth_sellPercent ? color.green : color.red) : color.new(color.black, 100))
    table.cell(t, 0, 1, inETH ? "ETH Buy%: " + str.tostring(eth_buyPercent) + " | Sell%: " + str.tostring(eth_sellPercent) : "",
      text_color=color.white, bgcolor=inETH ? (eth_buyPercent > eth_sellPercent ? color.green : color.red) : color.new(color.black, 100))
    table.cell(t, 0, 2, inRTH and (ta.crossover(rth_buyPercent, rth_sellPercent) or ta.crossover(rth_sellPercent, rth_buyPercent)) ? "RTH Crossover" : "",
      text_color=color.black, bgcolor=color.yellow)
    table.cell(t, 0, 3, inETH and (ta.crossover(eth_buyPercent, eth_sellPercent) or ta.crossover(eth_sellPercent, eth_buyPercent)) ? "ETH Crossover" : "",
      text_color=color.black, bgcolor=color.yellow)

// ──────────────────────────────────────────────────────────────
// HOD / LOD markers, last occurrence per RTH session
// ──────────────────────────────────────────────────────────────
rth_isNewHigh = inRTH and high == rth_dailyHigh and (na(rth_dailyHigh[1]) or high > rth_dailyHigh[1])
rth_isNewLow = inRTH and low == rth_dailyLow and (na(rth_dailyLow[1]) or low < rth_dailyLow[1])

var int rth_lastHODBar = na
var int rth_lastLODBar = na
if newRTH
    rth_lastHODBar := na
    rth_lastLODBar := na
else
    if rth_isNewHigh
        rth_lastHODBar := bar_index
    if rth_isNewLow
        rth_lastLODBar := bar_index

plotshape(bar_index == rth_lastHODBar ? 100 : na, title="HOD", style=shape.labelup, location=location.absolute, color=color.green, text="HOD", textcolor=color.white, size=size.tiny)
plotshape(bar_index == rth_lastLODBar ? 100 : na, title="LOD", style=shape.labeldown, location=location.absolute, color=color.red, text="LOD", textcolor=color.white, size=size.tiny)
````
