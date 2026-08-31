<!-- tradingview-pine-id: PUB;1eb2a02ec8c04e928d672028fe26783e -->
<!-- tradingviewscripts-format: 1 -->
# All-in-One: 200 SMA + Risk Mgmt + PVP Levels

Source: https://www.tradingview.com/script/IIHYEYBH-All-in-1-for-2min-200-SMA-Risk-Mgmt-PVP-Levels/

## Description

3 tools in one which make a good risk management and trading system package. The 200 SMA, Risk mgmt levels, and PVP levels. Intended to be used on a 2min chart.

---

## Source Code

````pine
//@version=6
indicator("All-in-One: 200 SMA + Risk Mgmt + PVP Levels", 
     shorttitle="SMA+Risk+PVP", 
     overlay=true, 
     max_lines_count=500, 
     max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
// 1. 200 SMA
// ═══════════════════════════════════════════════════════════════
smaGroup = "200 SMA"
smaLength = input.int(200, "SMA Length", minval=1, group=smaGroup)
smaSrc    = input.source(close, "Source", group=smaGroup)
smaColor  = input.color(color.new(#2962FF, 0), "Color", group=smaGroup)
smaWidth  = input.int(2, "Line Width", minval=1, maxval=4, group=smaGroup)

smaValue = ta.sma(smaSrc, smaLength)
plot(smaValue, "200 SMA", color=smaColor, linewidth=smaWidth)

// ═══════════════════════════════════════════════════════════════
// 2. Risk Mgmt Levels (right-aligned)
// ═══════════════════════════════════════════════════════════════
riskGroup = "Risk Mgmt Levels"
desiredRiskDollars = input.float(50, "Desired Risk per Trade ($)", minval=1, group=riskGroup)
entryPriceInput    = input.float(0.0, "Entry Price (E) - 0 = live floating", group=riskGroup)
atrMultiplier      = input.float(2.5, "ATR Multiplier (R)", step=0.1, minval=0.5, group=riskGroup)

isValidSession = time >= timestamp(year, month, dayofmonth, 9, 45, 0)

rawATR = ta.atr(14)
var float validATR = na
if isValidSession
    validATR := rawATR
else
    validATR := validATR[1]
R = atrMultiplier * (na(validATR) ? rawATR : validATR)

entryPrice = (entryPriceInput == 0 or na(entryPriceInput)) ? close : entryPriceInput
E     = entryPrice
SL    = E - R
T1    = E + R
T2    = E + 2 * R
T3    = E + 3 * R
halfR = E - 0.5 * R
recommendedShares = math.round(desiredRiskDollars / R)

var line lE = na
var line lSL = na
var line lT1 = na
var line lT2 = na
var line lT3 = na
var line l05R = na

var label lblE = na
var label lblSL = na
var label lblT1 = na
var label lblT2 = na
var label lblT3 = na
var label lbl05R = na
var label lblShares = na

if barstate.islast
    if not na(lE)
        line.delete(lE)
    if not na(lSL)
        line.delete(lSL)
    if not na(lT1)
        line.delete(lT1)
    if not na(lT2)
        line.delete(lT2)
    if not na(lT3)
        line.delete(lT3)
    if not na(l05R)
        line.delete(l05R)
    if not na(lblE)
        label.delete(lblE)
    if not na(lblSL)
        label.delete(lblSL)
    if not na(lblT1)
        label.delete(lblT1)
    if not na(lblT2)
        label.delete(lblT2)
    if not na(lblT3)
        label.delete(lblT3)
    if not na(lbl05R)
        label.delete(lbl05R)
    if not na(lblShares)
        label.delete(lblShares)

    // Right-aligned: start near current bar and extend to the right
    int riskStart = bar_index - 5
    int riskEnd   = bar_index + 18

    lE   := line.new(riskStart, E,     riskEnd, E,     color=color.white, width=1)
    lSL  := line.new(riskStart, SL,    riskEnd, SL,    color=color.red,   width=1)
    lT1  := line.new(riskStart, T1,    riskEnd, T1,    color=color.green, width=1)
    lT2  := line.new(riskStart, T2,    riskEnd, T2,    color=color.green, width=1)
    lT3  := line.new(riskStart, T3,    riskEnd, T3,    color=color.green, width=1)
    l05R := line.new(riskStart, halfR, riskEnd, halfR, color=color.new(color.yellow, 60), width=1, style=line.style_dotted)

    lblE    := label.new(riskEnd + 2, E,     "E",      style=label.style_label_left, color=color.new(color.black,80), textcolor=color.white,  size=size.small)
    lblSL   := label.new(riskEnd + 2, SL,    "-1R",    style=label.style_label_left, color=color.new(color.black,80), textcolor=color.red,    size=size.small)
    lblT1   := label.new(riskEnd + 2, T1,    "1R 50%", style=label.style_label_left, color=color.new(color.black,80), textcolor=color.green,  size=size.small)
    lblT2   := label.new(riskEnd + 2, T2,    "2R 30%", style=label.style_label_left, color=color.new(color.black,80), textcolor=color.green,  size=size.small)
    lblT3   := label.new(riskEnd + 2, T3,    "3R 20%", style=label.style_label_left, color=color.new(color.black,80), textcolor=color.green,  size=size.small)
    lbl05R  := label.new(riskEnd + 2, halfR, "-0.5R",  style=label.style_label_left, color=color.new(color.black,80), textcolor=color.yellow, size=size.small)
    lblShares := label.new(riskStart - 2, E - (R * 0.3), str.tostring(recommendedShares),
                           style=label.style_label_right, color=color.new(color.black,70), textcolor=color.yellow, size=size.normal)

// ═══════════════════════════════════════════════════════════════
// 3. PVP Levels – ONLY the most recent completed value area (left-aligned)
// ═══════════════════════════════════════════════════════════════
pvpGroup = "PVP Levels (POC / VAH / VAL only)"
periodMult   = input.int(45, "Period", minval=1, group=pvpGroup)
periodUnit   = input.string("Minute", "Period Unit", options=["Bar", "Minute", "Hour", "Day", "Week", "Month"], group=pvpGroup)
vaPercent    = input.float(68.0, "Value Area Volume %", minval=10, maxval=99, step=1, group=pvpGroup)
numRows      = input.int(85, "Row Size (Number of Rows)", minval=10, maxval=200, group=pvpGroup)

showPOC      = input.bool(false, "Show POC", group=pvpGroup)           // OFF by default
extendPOC    = input.bool(false, "Extend POC Right", group=pvpGroup)
extendVAH    = input.bool(false, "Extend VAH Right", group=pvpGroup)
extendVAL    = input.bool(false, "Extend VAL Right", group=pvpGroup)

pocColor  = input.color(color.new(color.orange, 0), "POC Color", group=pvpGroup)
pocWidth  = input.int(2, "POC Width", minval=1, maxval=4, group=pvpGroup)
pocStyle  = input.string("Solid", "POC Style", options=["Solid", "Dashed", "Dotted"], group=pvpGroup)

// Grey defaults – visible on both light and dark backgrounds
vahColor  = input.color(color.new(#787B86, 0), "VAH Color", group=pvpGroup)
vahWidth  = input.int(1, "VAH Width", minval=1, maxval=4, group=pvpGroup)
vahStyle  = input.string("Dashed", "VAH Style", options=["Solid", "Dashed", "Dotted"], group=pvpGroup)

valColor  = input.color(color.new(#787B86, 0), "VAL Color", group=pvpGroup)
valWidth  = input.int(1, "VAL Width", minval=1, maxval=4, group=pvpGroup)
valStyle  = input.string("Dashed", "VAL Style", options=["Solid", "Dashed", "Dotted"], group=pvpGroup)

getSafe(arr, idx) =>
    array.get(arr, math.max(0, math.min(array.size(arr) - 1, idx)))

setSafe(arr, idx, val) =>
    array.set(arr, math.max(0, math.min(array.size(arr) - 1, idx)), val)

string tfStr = switch periodUnit
    "Bar"    => timeframe.period
    "Minute" => str.tostring(periodMult)
    "Hour"   => str.tostring(periodMult * 60)
    "Day"    => str.tostring(periodMult) + "D"
    "Week"   => str.tostring(periodMult) + "W"
    "Month"  => str.tostring(periodMult) + "M"
    => "D"

isNewPeriod = ta.change(time(tfStr)) != 0

var int barsInPeriod = 0
if isNewPeriod
    barsInPeriod := 1
else
    barsInPeriod += 1

var float histPOC = na
var float histVAH = na
var float histVAL = na
var int   histStart = na
var int   histEnd = na

var line pocLine = na
var line vahLine = na
var line valLine = na

if isNewPeriod
    int prevBars = barsInPeriod[1]
    int periodEnd = bar_index - 1
    int periodStart = periodEnd - prevBars + 1

    if prevBars >= 8 and prevBars <= 300
        float highest = ta.highest(high[1], prevBars)
        float lowest  = ta.lowest(low[1], prevBars)
        float range_  = highest - lowest

        if range_ < syminfo.mintick * 50
            range_ := syminfo.mintick * 50

        float rowSize = range_ / numRows
        float[] volBins = array.new_float(numRows, 0.0)

        for i = 1 to prevBars
            float barVol  = volume[i]
            float barLow  = low[i]
            float barHigh = high[i]

            int fromBin = int(math.max(0, math.floor((barLow  - lowest) / rowSize)))
            int toBin   = int(math.min(numRows - 1, math.floor((barHigh - lowest) / rowSize)))

            int binsSpanned = math.max(1, toBin - fromBin + 1)
            float volPerBin = barVol / binsSpanned

            for b = fromBin to toBin
                setSafe(volBins, b, getSafe(volBins, b) + volPerBin)

        // POC
        float maxVol = 0.0
        int   pocIdx = 0
        for i = 0 to numRows - 1
            float v = getSafe(volBins, i)
            if v > maxVol
                maxVol := v
                pocIdx := i
        histPOC := lowest + (pocIdx + 0.5) * rowSize

        // 68% Value Area
        float totalVol  = array.sum(volBins)
        float targetVol = totalVol * (vaPercent / 100.0)
        float cumVol    = getSafe(volBins, pocIdx)
        int up   = pocIdx
        int down = pocIdx

        while cumVol < targetVol and (up < numRows - 1 or down > 0)
            float upVol   = up < numRows - 1 ? getSafe(volBins, up + 1) : 0.0
            float downVol = down > 0         ? getSafe(volBins, down - 1) : 0.0

            if upVol >= downVol and up < numRows - 1
                up += 1
                cumVol += upVol
            else if down > 0
                down -= 1
                cumVol += downVol
            else
                break

        up   := math.min(up, numRows - 1)
        down := math.max(down, 0)

        histVAH := lowest + (up + 1) * rowSize
        histVAL := lowest + down * rowSize

        histStart := periodStart
        histEnd   := periodEnd

// Draw – Value Area left-aligned over its own period
if barstate.islast and not na(histPOC)
    if not na(pocLine)
        line.delete(pocLine)
    if not na(vahLine)
        line.delete(vahLine)
    if not na(valLine)
        line.delete(valLine)

    lineStylePOC = pocStyle == "Dashed" ? line.style_dashed : pocStyle == "Dotted" ? line.style_dotted : line.style_solid
    lineStyleVAH = vahStyle == "Dashed" ? line.style_dashed : vahStyle == "Dotted" ? line.style_dotted : line.style_solid
    lineStyleVAL = valStyle == "Dashed" ? line.style_dashed : valStyle == "Dotted" ? line.style_dotted : line.style_solid

    // Left-aligned: stay over the calculation period
    int x2poc = extendPOC ? bar_index + 40 : histEnd + 3
    int x2vah = extendVAH ? bar_index + 40 : histEnd + 3
    int x2val = extendVAL ? bar_index + 40 : histEnd + 3

    if showPOC
        pocLine := line.new(histStart, histPOC, x2poc, histPOC, color=pocColor, width=pocWidth, style=lineStylePOC)
        label.new(histEnd + 2, histPOC, "POC", style=label.style_label_left, color=color.new(pocColor, 70), textcolor=pocColor, size=size.small)

    vahLine := line.new(histStart, histVAH, x2vah, histVAH, color=vahColor, width=vahWidth, style=lineStyleVAH)
    valLine := line.new(histStart, histVAL, x2val, histVAL, color=valColor, width=valWidth, style=lineStyleVAL)

    label.new(histEnd + 2, histVAH, "VAH", style=label.style_label_left, color=color.new(vahColor, 70), textcolor=vahColor, size=size.small)
    label.new(histEnd + 2, histVAL, "VAL", style=label.style_label_left, color=color.new(valColor, 70), textcolor=valColor, size=size.small)
````
