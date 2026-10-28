# Daily OHLC + POC + VAH/VAL + ATR Lookup Table

- url: https://www.tradingview.com/script/OhtRbBnP-Daily-OHLC-POC-VAH-VAL-ATR-Lookup-Table/
- type: indicator
- pine_id: PUB;b84276c80c534b7dbc38b4ae8365a87c
- version: 1.0

## Description

A historical day analysis tool. Enter any trading date and the table displays that day's full price action — Open, High, Low, Close, Volume Profile levels (POC, VAH, VAL at 70% value area), and ATR-relative day range showing whether it was a trend day or chop day. Built for studying past 0DTE setups on SPY, QQQ, and IWM.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © georgep0014

//@version=6
indicator("Daily OHLC + POC + VAH/VAL + ATR Lookup Table", overlay=true, max_bars_back=5000)

// ===== INPUTS =====
lookupDate   = input.time(timestamp("2025-01-15 00:00 -0500"), title="Lookup Date", confirm=true)
profileBins  = input.int(50, title="POC Price Bins", minval=10, maxval=200)
vaPercent    = input.float(70.0, title="Value Area %", minval=50.0, maxval=95.0, step=1.0)
atrLength    = input.int(14, title="ATR Length", minval=1)
tablePos     = input.string("top_right", title="Table Position", options=["top_left","top_right","bottom_left","bottom_right","middle_right"])
showMarker   = input.bool(true, title="Highlight the day on chart")
showVALines  = input.bool(true, title="Plot POC/VAH/VAL lines on the day")

// ===== EXTRACT TARGET DAY =====
targetYear  = year(lookupDate)
targetMonth = month(lookupDate)
targetDay   = dayofmonth(lookupDate)

isTargetDay = year == targetYear and month == targetMonth and dayofmonth == targetDay

// ===== PULL DAILY ATR =====
dailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLength), lookahead=barmerge.lookahead_off)
dailyTR  = request.security(syminfo.tickerid, "D", ta.tr(true),       lookahead=barmerge.lookahead_off)

// ===== TRACK OHLC + VOLUME PROFILE + ATR =====
var float dOpen   = na
var float dHigh   = na
var float dLow    = na
var float dClose  = na
var float dPOC    = na
var float dVAH    = na
var float dVAL    = na
var float dATR    = na
var float dDayTR  = na
var bool  dayDone = false

var array<float> priceArr  = array.new<float>()
var array<float> volumeArr = array.new<float>()

if isTargetDay
    if na(dOpen)
        dOpen := open
        array.clear(priceArr)
        array.clear(volumeArr)

    dHigh  := na(dHigh) ? high : math.max(dHigh, high)
    dLow   := na(dLow)  ? low  : math.min(dLow, low)
    dClose := close
    dATR   := dailyATR
    dDayTR := dailyTR

    array.push(priceArr,  hlc3)
    array.push(volumeArr, volume)

if not isTargetDay and not dayDone and not na(dOpen) and array.size(priceArr) > 0
    hi = dHigh
    lo = dLow
    binSize = (hi - lo) / profileBins
    if binSize > 0
        var array<float> binVols = array.new<float>(profileBins, 0.0)
        array.fill(binVols, 0.0)

        for i = 0 to array.size(priceArr) - 1
            p = array.get(priceArr, i)
            v = array.get(volumeArr, i)
            idx = math.floor((p - lo) / binSize)
            idx := math.min(math.max(idx, 0), profileBins - 1)
            array.set(binVols, idx, array.get(binVols, idx) + v)

        maxVol = 0.0
        pocIdx = 0
        totalVol = 0.0
        for i = 0 to profileBins - 1
            v = array.get(binVols, i)
            totalVol += v
            if v > maxVol
                maxVol := v
                pocIdx := i
        dPOC := lo + (pocIdx + 0.5) * binSize

        targetVol = totalVol * (vaPercent / 100.0)
        accumVol  = maxVol
        upperIdx  = pocIdx
        lowerIdx  = pocIdx

        while accumVol < targetVol and (upperIdx < profileBins - 1 or lowerIdx > 0)
            volAbove1 = upperIdx < profileBins - 1 ? array.get(binVols, upperIdx + 1) : 0.0
            volAbove2 = upperIdx < profileBins - 2 ? array.get(binVols, upperIdx + 2) : 0.0
            volBelow1 = lowerIdx > 0              ? array.get(binVols, lowerIdx - 1) : 0.0
            volBelow2 = lowerIdx > 1              ? array.get(binVols, lowerIdx - 2) : 0.0

            sumAbove = volAbove1 + volAbove2
            sumBelow = volBelow1 + volBelow2

            if sumAbove >= sumBelow and upperIdx < profileBins - 1
                upperIdx += 1
                accumVol += array.get(binVols, upperIdx)
                if accumVol < targetVol and upperIdx < profileBins - 1
                    upperIdx += 1
                    accumVol += array.get(binVols, upperIdx)
            else if lowerIdx > 0
                lowerIdx -= 1
                accumVol += array.get(binVols, lowerIdx)
                if accumVol < targetVol and lowerIdx > 0
                    lowerIdx -= 1
                    accumVol += array.get(binVols, lowerIdx)
            else
                break

        dVAH := lo + (upperIdx + 1) * binSize
        dVAL := lo + lowerIdx * binSize
    dayDone := true

// ===== TABLE =====
var table infoTable = table.new(position = tablePos == "top_left" ? position.top_left : tablePos == "top_right" ? position.top_right : tablePos == "bottom_left" ? position.bottom_left : tablePos == "bottom_right" ? position.bottom_right : position.middle_right, columns = 2, rows = 10, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.gray)

if barstate.islast
    dateStr = str.format("{0,number,0000}-{1,number,00}-{2,number,00}", targetYear, targetMonth, targetDay)
    table.cell(infoTable, 0, 0, "Date",  text_color=color.white, bgcolor=color.new(color.blue, 30))
    table.cell(infoTable, 1, 0, dateStr, text_color=color.white, bgcolor=color.new(color.blue, 30))
    table.cell(infoTable, 0, 1, "Open",  text_color=color.white)
    table.cell(infoTable, 1, 1, na(dOpen)  ? "—" : str.tostring(dOpen,  format.mintick), text_color=color.white)
    table.cell(infoTable, 0, 2, "High",  text_color=color.white)
    table.cell(infoTable, 1, 2, na(dHigh)  ? "—" : str.tostring(dHigh,  format.mintick), text_color=color.lime)
    table.cell(infoTable, 0, 3, "Low",   text_color=color.white)
    table.cell(infoTable, 1, 3, na(dLow)   ? "—" : str.tostring(dLow,   format.mintick), text_color=color.red)
    table.cell(infoTable, 0, 4, "Close", text_color=color.white)
    table.cell(infoTable, 1, 4, na(dClose) ? "—" : str.tostring(dClose, format.mintick), text_color=color.yellow)
    table.cell(infoTable, 0, 5, "VAH",   text_color=color.white)
    table.cell(infoTable, 1, 5, na(dVAH)  ? "—" : str.tostring(dVAH,   format.mintick), text_color=color.aqua)
    table.cell(infoTable, 0, 6, "POC",   text_color=color.white, bgcolor=color.new(color.orange, 50))
    table.cell(infoTable, 1, 6, na(dPOC)  ? "—" : str.tostring(dPOC,   format.mintick), text_color=color.white, bgcolor=color.new(color.orange, 50))
    table.cell(infoTable, 0, 7, "VAL",   text_color=color.white)
    table.cell(infoTable, 1, 7, na(dVAL)  ? "—" : str.tostring(dVAL,   format.mintick), text_color=color.fuchsia)
    table.cell(infoTable, 0, 8, "ATR(" + str.tostring(atrLength) + ")", text_color=color.white, bgcolor=color.new(color.purple, 50))
    table.cell(infoTable, 1, 8, na(dATR)   ? "—" : str.tostring(dATR,   format.mintick), text_color=color.white, bgcolor=color.new(color.purple, 50))

    rangeRatio = not na(dDayTR) and not na(dATR) and dATR > 0 ? dDayTR / dATR : na
    ratioStr   = na(rangeRatio) ? "—" : str.tostring(rangeRatio, "#.##") + "x ATR"
    ratioColor = na(rangeRatio) ? color.white : rangeRatio > 1.5 ? color.lime : rangeRatio < 0.7 ? color.red : color.white
    table.cell(infoTable, 0, 9, "Day Range", text_color=color.white)
    table.cell(infoTable, 1, 9, ratioStr, text_color=ratioColor)

bgcolor(showMarker and isTargetDay ? color.new(color.blue, 90) : na)
plot(showVALines and isTargetDay ? dPOC : na, "POC", color=color.orange,  style=plot.style_linebr, linewidth=2)
plot(showVALines and isTargetDay ? dVAH : na, "VAH", color=color.aqua,    style=plot.style_linebr, linewidth=1)
plot(showVALines and isTargetDay ? dVAL : na, "VAL", color=color.fuchsia, style=plot.style_linebr, linewidth=1)
````
