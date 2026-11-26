# Institutional Gravity

- url: https://www.tradingview.com/script/RxHNqNhm-Institutional-Gravity/
- type: indicator
- pine_id: PUB;fde037cd497248ab80ac9d19cac45bfc
- version: 1.0

## Description

Institutional Gravity is a market structure and institutional price-mapping indicator designed to identify the areas where professional money is most likely to defend, accumulate, distribute, or react. Rather than focusing on single price levels, the indicator builds high-probability institutional zones by combining multiple forms of technical confluence.

Core Features
30-Day Rolling VWAP (institutional accumulation benchmark)
Calendar Year VWAP
±1 Standard Deviation Bands for both VWAPs
20-Day & 50-Day Simple Moving Averages
Automatic Confluence Detection
Institutional Support & Resistance Zones
Major Swing Structure Detection
ATR-Based Dynamic Zone Width
Automatic Zone Merging to eliminate overlapping levels
Price-Axis Highlights for important support and resistance zones
Designed for Daily Swing & Position Trading
Philosophy

Institutional traders rarely react to a single price. Instead, they transact within areas of value created by overlapping technical factors.

Institutional Gravity automatically identifies where multiple institutional reference points converge—including VWAPs, moving averages, volatility bands, and major swing structure—to highlight the zones with the highest probability of attracting buyers or sellers.

The result is a cleaner, more actionable map of price than relying on individual indicators alone.

Best Used For
Identifying high-probability pullback zones
Finding institutional support and resistance
Planning entries and exits
Managing swing trades
Understanding where price is statistically likely to react
Timeframes

Optimized primarily for the Daily timeframe, but can also be used on higher timeframes for broader market structure analysis.

Institutional Gravity is intended to help traders think in probabilities—not predictions—by focusing attention on the price areas where institutional participation is most likely to influence future market behavior.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ryani8877
//@version=6
indicator("Institutional Gravity", shorttitle="Inst Gravity", overlay=true, max_boxes_count=300, max_labels_count=300, max_lines_count=500, max_bars_back=1500)

rollingDays    = input.int(30, "Rolling Monthly VWAP: Calendar Days", minval=5)
atrLen         = input.int(14, "ATR Length")
zoneAtrMult    = input.float(0.20, "Zone Padding ATR Multiplier", step=0.05)
clusterAtrMult = input.float(0.65, "Confluence Threshold ATR Multiplier", step=0.05)
mergeAtrMult   = input.float(0.45, "Merge Nearby Zones ATR Multiplier", step=0.05)
pivotLen       = input.int(8, "Swing Pivot Strength", minval=3, maxval=25)
majorLookback  = input.int(250, "Major Structure Lookback Bars", minval=75, maxval=750)
forwardBars    = input.int(55, "Extend Zones Right", minval=10)
maxPivots      = input.int(6, "Max Pivot Boxes", minval=0, maxval=20)

showVWAPs      = input.bool(true, "Show VWAPs")
showBands      = input.bool(true, "Show Thin Dashed 1 StDev Bands")
showSMAs       = input.bool(true, "Show 20 / 50 SMAs")
showPivots     = input.bool(true, "Show Swing Pivot Boxes")
showMajor      = input.bool(true, "Show Major Structure")
showZones      = input.bool(true, "Show Right-Side Zones")
showLabels     = input.bool(true, "Show Zone Labels")
showAxisPrices = input.bool(true, "Show Zone Prices On Axis")

yearColor  = color.orange
monthColor = color.blue
sma20Color = color.aqua
sma50Color = color.rgb(0, 45, 180)

atr = ta.atr(atrLen)
zonePad = atr * zoneAtrMult
clusterDist = atr * clusterAtrMult
mergeDist = atr * mergeAtrMult

sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)

msDay = 24 * 60 * 60 * 1000
startTime = timenow - rollingDays * msDay

float pv = 0.0
float vol = 0.0
float dev = 0.0
int count = 0

for i = 0 to 300
    if time[i] >= startTime
        pv += hlc3[i] * volume[i]
        vol += volume[i]

rollVWAP = vol > 0 ? pv / vol : na

for i = 0 to 300
    if time[i] >= startTime and not na(rollVWAP)
        dev += math.pow(hlc3[i] - rollVWAP, 2)
        count += 1

rollSD = count > 1 ? math.sqrt(dev / count) : na
rollUpper = rollVWAP + rollSD
rollLower = rollVWAP - rollSD

isNewYear = year(time) != year(time[1])

var float yPV = na
var float yVol = na
var float yDev = na
var int yCount = na

if isNewYear or na(yPV)
    yPV := hlc3 * volume
    yVol := volume
    yDev := 0.0
    yCount := 1
else
    yPV += hlc3 * volume
    yVol += volume
    yCount += 1

yearVWAP = yVol > 0 ? yPV / yVol : na
yDev += not na(yearVWAP) ? math.pow(hlc3 - yearVWAP, 2) : 0.0
yearSD = yCount > 1 ? math.sqrt(yDev / yCount) : na

yearUpper = yearVWAP + yearSD
yearLower = yearVWAP - yearSD

plot(showVWAPs ? yearVWAP : na, "Yearly VWAP", color=yearColor, linewidth=5)
plot(showVWAPs ? rollVWAP : na, "Rolling 30D VWAP", color=monthColor, linewidth=5)
plot(showSMAs ? sma20 : na, "20 Day SMA", color=sma20Color, linewidth=5)
plot(showSMAs ? sma50 : na, "50 Day SMA", color=sma50Color, linewidth=5)

dashOn = bar_index % 4 < 2
plot(showBands and dashOn ? yearUpper : na, "Yearly Upper 1SD", color=yearColor, linewidth=2, style=plot.style_linebr)
plot(showBands and dashOn ? yearLower : na, "Yearly Lower 1SD", color=yearColor, linewidth=2, style=plot.style_linebr)
plot(showBands and dashOn ? rollUpper : na, "Rolling Upper 1SD", color=monthColor, linewidth=2, style=plot.style_linebr)
plot(showBands and dashOn ? rollLower : na, "Rolling Lower 1SD", color=monthColor, linewidth=2, style=plot.style_linebr)

var box[] zoneBoxes = array.new_box()
var label[] zoneLabels = array.new_label()
var box[] pivotBoxes = array.new_box()
var float[] pivotTops = array.new_float()
var float[] pivotBots = array.new_float()
var bool[] pivotSupports = array.new_bool()
var float[] supportAxisLevels = array.new_float()
var float[] resistanceAxisLevels = array.new_float()

pushAxis(float top, float bot, bool support) =>
    if showAxisPrices
        if support
            array.push(supportAxisLevels, top)
            array.push(supportAxisLevels, bot)
        else
            array.push(resistanceAxisLevels, top)
            array.push(resistanceAxisLevels, bot)

clearZones() =>
    while array.size(zoneBoxes) > 0
        box.delete(array.pop(zoneBoxes))
    while array.size(zoneLabels) > 0
        label.delete(array.pop(zoneLabels))
    array.clear(supportAxisLevels)
    array.clear(resistanceAxisLevels)

drawZone(float top, float bot, string title, bool support, int score) =>
    color c = support ? color.green : color.red
    box b = box.new(bar_index + 3, top, bar_index + forwardBars, bot, bgcolor=color.new(c, 94), border_color=color.new(c, 30))
    array.push(zoneBoxes, b)
    pushAxis(top, bot, support)

    if showLabels
        mid = (top + bot) / 2
        txt = title + "\nScore: " + str.tostring(score)
        label l = label.new(bar_index + 4, mid, txt, style=label.style_label_left, textcolor=color.white, color=color.new(c, 10), size=size.small)
        array.push(zoneLabels, l)

// Swing pivot boxes
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow  = ta.pivotlow(low, pivotLen, pivotLen)

if showPivots and not na(pivotHigh)
    top = pivotHigh + zonePad
    bot = pivotHigh - zonePad
    box b = box.new(bar_index - pivotLen, top, bar_index + forwardBars, bot, bgcolor=color.new(color.red, 97), border_color=color.new(color.red, 50))
    array.push(pivotBoxes, b)
    array.push(pivotTops, top)
    array.push(pivotBots, bot)
    array.push(pivotSupports, false)

if showPivots and not na(pivotLow)
    top = pivotLow + zonePad
    bot = pivotLow - zonePad
    box b = box.new(bar_index - pivotLen, top, bar_index + forwardBars, bot, bgcolor=color.new(color.green, 97), border_color=color.new(color.green, 50))
    array.push(pivotBoxes, b)
    array.push(pivotTops, top)
    array.push(pivotBots, bot)
    array.push(pivotSupports, true)

while array.size(pivotBoxes) > maxPivots
    box.delete(array.shift(pivotBoxes))
    array.shift(pivotTops)
    array.shift(pivotBots)
    array.shift(pivotSupports)

if barstate.islast and showZones
    clearZones()

    float[] levels = array.from(rollVWAP, rollUpper, rollLower, yearVWAP, yearUpper, yearLower, sma20, sma50)
    string[] names = array.from("Rolling VWAP", "Rolling +1σ", "Rolling -1σ", "Yearly VWAP", "Yearly +1σ", "Yearly -1σ", "20 SMA", "50 SMA")
    bool[] used = array.new_bool(array.size(levels), false)

    float[] zTops = array.new_float()
    float[] zBots = array.new_float()
    bool[] zSups = array.new_bool()
    int[] zScores = array.new_int()
    string[] zTitles = array.new_string()

    for i = 0 to array.size(levels) - 1
        base = array.get(levels, i)

        if not na(base) and not array.get(used, i)
            top = base
            bot = base
            matches = 0

            for j = 0 to array.size(levels) - 1
                other = array.get(levels, j)
                if not na(other) and math.abs(base - other) <= clusterDist
                    matches += 1
                    top := math.max(top, other)
                    bot := math.min(bot, other)
                    array.set(used, j, true)

            important = str.contains(array.get(names, i), "VWAP") or str.contains(array.get(names, i), "1σ")

            if matches >= 2 or important
                top += zonePad
                bot -= zonePad
                support = base < close
                score = math.max(25, matches * 25)
                title = support ? "Institutional Support" : "Institutional Resistance"

                merged = false
                if array.size(zTops) > 0
                    for z = 0 to array.size(zTops) - 1
                        sameSide = array.get(zSups, z) == support
                        closeEnough = bot <= array.get(zTops, z) + mergeDist and top >= array.get(zBots, z) - mergeDist

                        if sameSide and closeEnough
                            array.set(zTops, z, math.max(array.get(zTops, z), top))
                            array.set(zBots, z, math.min(array.get(zBots, z), bot))
                            array.set(zScores, z, math.max(array.get(zScores, z), score))
                            merged := true

                if not merged
                    array.push(zTops, top)
                    array.push(zBots, bot)
                    array.push(zSups, support)
                    array.push(zScores, score)
                    array.push(zTitles, title)

    if showMajor
        majorLow = ta.lowest(low, majorLookback)
        majorHigh = ta.highest(high, majorLookback)

        array.push(zTops, majorLow + zonePad)
        array.push(zBots, majorLow - zonePad)
        array.push(zSups, true)
        array.push(zScores, 75)
        array.push(zTitles, "Major Structure Support")

        array.push(zTops, majorHigh + zonePad)
        array.push(zBots, majorHigh - zonePad)
        array.push(zSups, false)
        array.push(zScores, 75)
        array.push(zTitles, "Major Structure Resistance")

    for z = 0 to array.size(zTops) - 1
        drawZone(array.get(zTops, z), array.get(zBots, z), array.get(zTitles, z), array.get(zSups, z), array.get(zScores, z))

    // Push recent swing pivot boxes into price axis too
    if array.size(pivotTops) > 0
        for p = 0 to array.size(pivotTops) - 1
            pushAxis(array.get(pivotTops, p), array.get(pivotBots, p), array.get(pivotSupports, p))

supAxis(int idx) =>
    showAxisPrices and array.size(supportAxisLevels) > idx ? array.get(supportAxisLevels, idx) : na

resAxis(int idx) =>
    showAxisPrices and array.size(resistanceAxisLevels) > idx ? array.get(resistanceAxisLevels, idx) : na

plot(supAxis(0), "Support Axis 1", color=color.green, linewidth=1, trackprice=true, show_last=1)
plot(supAxis(1), "Support Axis 2", color=color.green, linewidth=1, trackprice=true, show_last=1)
plot(supAxis(2), "Support Axis 3", color=color.green, linewidth=1, trackprice=true, show_last=1)
plot(supAxis(3), "Support Axis 4", color=color.green, linewidth=1, trackprice=true, show_last=1)
plot(supAxis(4), "Support Axis 5", color=color.green, linewidth=1, trackprice=true, show_last=1)
plot(supAxis(5), "Support Axis 6", color=color.green, linewidth=1, trackprice=true, show_last=1)
plot(supAxis(6), "Support Axis 7", color=color.green, linewidth=1, trackprice=true, show_last=1)
plot(supAxis(7), "Support Axis 8", color=color.green, linewidth=1, trackprice=true, show_last=1)

plot(resAxis(0), "Resistance Axis 1", color=color.red, linewidth=1, trackprice=true, show_last=1)
plot(resAxis(1), "Resistance Axis 2", color=color.red, linewidth=1, trackprice=true, show_last=1)
plot(resAxis(2), "Resistance Axis 3", color=color.red, linewidth=1, trackprice=true, show_last=1)
plot(resAxis(3), "Resistance Axis 4", color=color.red, linewidth=1, trackprice=true, show_last=1)
plot(resAxis(4), "Resistance Axis 5", color=color.red, linewidth=1, trackprice=true, show_last=1)
plot(resAxis(5), "Resistance Axis 6", color=color.red, linewidth=1, trackprice=true, show_last=1)
plot(resAxis(6), "Resistance Axis 7", color=color.red, linewidth=1, trackprice=true, show_last=1)
plot(resAxis(7), "Resistance Axis 8", color=color.red, linewidth=1, trackprice=true, show_last=1)
````
