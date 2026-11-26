# MULTI VWAP with Labels

- url: https://www.tradingview.com/script/kJbGtmMo-MULTI-VWAP-with-Labels/
- type: indicator
- pine_id: PUB;a375fb706bbc48eb8eea0e73e253600e
- version: 1.0

## Description

Multi-VWAP with Strategy Presets —  (Session, Week, Month, Quarter, Year, Decade, All Time + 5 Custom).

IMPORTANT: To use "All Time" VWAP correctly, load a chart with full historical data from day 1 (longest available history).

Features:
• Strategy Preset dropdown with auto-enable + recommended timeframes
• Right-side VWAP labels
• Preset name displayed on chart

Preset Combinations + Suggested EMAs:

• Scalp → Session VWAP 
  Recommended TF: 1m - 15m
  EMAs: 9 + 21
  Fast intraday mean reversion scalping

• Day Trade → Session + Week + All Time
  Recommended TF: 5m - 4H
  EMAs: 9 + 21 or 21 + 50
  Intraday structure and bounces

• Swing → Quarter + Year + All Time
  Recommended TF: 1H - Daily
  EMAs: 50 + 200
  Higher timeframe confluences

• Long Term → Year + Decade + All Time
  Recommended TF: Daily - Weekly
  EMAs: 200
  Major institutional fair value levels

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © itsjustAL

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator(title="MULTI VWAP with Labels", shorttitle="Multi-VWAP", overlay=true)

// --- Global Settings ---
srcInput    = input.source(hlc3, "Source", group = "Global Settings")
hideOnDwm   = input.bool(false, "Hide VWAP on 1D or Above", group = "Global Settings")
labelOffset = input.int(1, "Label Offset (Bars)", minval = 1, group = "Global Settings")
labelSize   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Global Settings")

// Strategy Preset
strategyPreset = input.string("None", "Strategy Preset", 
     options = ["None", "Scalp", "Day Trade", "Swing", "Long Term"], 
     group = "Global Settings", tooltip = "Auto-enables recommended VWAPs for each style")

// --- Standard VWAP Toggles ---
GRP_STD = "Standard VWAPs"
showSession = input.bool(true,  "Session", group = GRP_STD, inline = "1")
colSession  = input.color(#2962FF, "", group = GRP_STD, inline = "1")
showWeek    = input.bool(false, "Week", group = GRP_STD, inline = "2")
colWeek     = input.color(#089981, "", group = GRP_STD, inline = "2")
showMonth   = input.bool(false, "Month", group = GRP_STD, inline = "3")
colMonth    = input.color(#f23645, "", group = GRP_STD, inline = "3")
showQuarter = input.bool(false, "Quarter", group = GRP_STD, inline = "4")
colQuarter  = input.color(#FF9800, "", group = GRP_STD, inline = "4")
showYear    = input.bool(false, "Year", group = GRP_STD, inline = "5")
colYear     = input.color(#9C27B0, "", group = GRP_STD, inline = "5")
showDecade  = input.bool(false, "Decade", group = GRP_STD, inline = "6")
colDecade   = input.color(#795548, "", group = GRP_STD, inline = "6")
showAllTime = input.bool(true, "All Time", group = GRP_STD, inline = "7")
colAllTime  = input.color(#607D8B, "", group = GRP_STD, inline = "7")

// --- ESD VWAP Toggles ---
GRP_ESD = "ESD VWAPs (Earnings, Splits, Dividends)"
showEarnings = input.bool(false, "Earnings", group = GRP_ESD, inline = "8")
colEarnings  = input.color(#E91E63, "", group = GRP_ESD, inline = "8")
showDivs     = input.bool(false, "Dividends",group = GRP_ESD, inline = "9")
colDivs      = input.color(#FFEB3B, "", group = GRP_ESD, inline = "9")
showSplits   = input.bool(false, "Splits", group = GRP_ESD, inline = "10")
colSplits    = input.color(#00BCD4, "", group = GRP_ESD, inline = "10")

// Preset Logic
useSession = (strategyPreset == "Scalp" or strategyPreset == "Day Trade" or strategyPreset == "None") and showSession
useWeek    = (strategyPreset == "Day Trade" or strategyPreset == "None") and showWeek
useMonth   = strategyPreset == "None" and showMonth
useQuarter = (strategyPreset == "Swing" or strategyPreset == "None") and showQuarter
useYear    = (strategyPreset == "Swing" or strategyPreset == "Long Term" or strategyPreset == "None") and showYear
useDecade  = (strategyPreset == "Long Term" or strategyPreset == "None") and showDecade
useAllTime = (strategyPreset == "Day Trade" or strategyPreset == "Swing" or strategyPreset == "Long Term" or strategyPreset == "None") and showAllTime

// --- Custom VWAPs ---
GRP_C1 = "Custom VWAP 1"
showC1   = input.bool(false, "Enabled", group = GRP_C1, inline = "c1")
anchorC1 = input.string("Session", "Anchor", options = ["Session", "Week", "Month", "Quarter", "Year", "Decade", "All Time", "Earnings", "Dividends", "Splits"], group = GRP_C1, inline = "c1")
nameC1   = input.string("Custom 1", "Name", group = GRP_C1, inline = "c1_2")
colC1    = input.color(#5b9cf6, "", group = GRP_C1, inline = "c1_2")

GRP_C2 = "Custom VWAP 2"
showC2   = input.bool(false, "Enabled", group = GRP_C2, inline = "c2")
anchorC2 = input.string("Week", "Anchor", options = ["Session", "Week", "Month", "Quarter", "Year", "Decade", "All Time", "Earnings", "Dividends", "Splits"], group = GRP_C2, inline = "c2")
nameC2   = input.string("Custom 2", "Name", group = GRP_C2, inline = "c2_2")
colC2    = input.color(#5b9cf6, "", group = GRP_C2, inline = "c2_2")

GRP_C3 = "Custom VWAP 3"
showC3   = input.bool(false, "Enabled", group = GRP_C3, inline = "c3")
anchorC3 = input.string("Month", "Anchor", options = ["Session", "Week", "Month", "Quarter", "Year", "Decade", "All Time", "Earnings", "Dividends", "Splits"], group = GRP_C3, inline = "c3")
nameC3   = input.string("Custom 3", "Name", group = GRP_C3, inline = "c3_2")
colC3    = input.color(#5b9cf6, "", group = GRP_C3, inline = "c3_2")

GRP_C4 = "Custom VWAP 4"
showC4   = input.bool(false, "Enabled", group = GRP_C4, inline = "c4")
anchorC4 = input.string("Quarter", "Anchor", options = ["Session", "Week", "Month", "Quarter", "Year", "Decade", "All Time", "Earnings", "Dividends", "Splits"], group = GRP_C4, inline = "c4")
nameC4   = input.string("Custom 4", "Name", group = GRP_C4, inline = "c4_2")
colC4    = input.color(#5b9cf6, "", group = GRP_C4, inline = "c4_2")

GRP_C5 = "Custom VWAP 5"
showC5   = input.bool(false, "Enabled", group = GRP_C5, inline = "c5")
anchorC5 = input.string("Year", "Anchor", options = ["Session", "Week", "Month", "Quarter", "Year", "Decade", "All Time", "Earnings", "Dividends", "Splits"], group = GRP_C5, inline = "c5")
nameC5   = input.string("Custom 5", "Name", group = GRP_C5, inline = "c5_2")
colC5    = input.color(#5b9cf6, "", group = GRP_C5, inline = "c5_2")

// --- Functions ---
getLabelSize() =>
    switch labelSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

computeVwap(src, cond) =>
    var float sumSrcVol = 0.0
    var float sumVol = 0.0
    if cond
        sumSrcVol := src * volume
        sumVol := volume
    else
        sumSrcVol += src * volume
        sumVol += volume
    sumSrcVol / sumVol

// --- Triggers ---
isNewSession = timeframe.change("D")
isNewWeek    = timeframe.change("W")
isNewMonth   = timeframe.change("M")
isNewQuarter = timeframe.change("3M")
isNewYear    = timeframe.change("12M")
isNewDecade  = timeframe.change("12M") and year % 10 == 0
isNewAllTime = barstate.isfirst

// Safe ESD calculation (using request)
earned   = request.earnings(syminfo.tickerid, earnings.actual)
divs     = request.dividends(syminfo.tickerid, dividends.net)
splitVal = request.splits(syminfo.tickerid, splits.denominator)

isEarnings = ta.change(earned) != 0
isDivs     = ta.change(divs) != 0
isSplits   = ta.change(splitVal) != 0

getTrigger(anchor) =>
    switch anchor
        "Session"   => isNewSession
        "Week"      => isNewWeek
        "Month"     => isNewMonth
        "Quarter"   => isNewQuarter
        "Year"      => isNewYear
        "Decade"    => isNewDecade
        "All Time"  => isNewAllTime
        "Earnings"  => isEarnings
        "Dividends" => isDivs
        "Splits"    => isSplits
        => false

// --- Calculations ---
canShow = not (hideOnDwm and timeframe.isdwm)

vS = computeVwap(srcInput, isNewSession)
vW = computeVwap(srcInput, isNewWeek)
vM = computeVwap(srcInput, isNewMonth)
vQ = computeVwap(srcInput, isNewQuarter)
vY = computeVwap(srcInput, isNewYear)
vD = computeVwap(srcInput, isNewDecade)
vA = computeVwap(srcInput, isNewAllTime)
vE = computeVwap(srcInput, isEarnings)
vDiv = computeVwap(srcInput, isDivs)
vSplit = computeVwap(srcInput, isSplits)

vC1 = computeVwap(srcInput, getTrigger(anchorC1))
vC2 = computeVwap(srcInput, getTrigger(anchorC2))
vC3 = computeVwap(srcInput, getTrigger(anchorC3))
vC4 = computeVwap(srcInput, getTrigger(anchorC4))
vC5 = computeVwap(srcInput, getTrigger(anchorC5))

// --- Plotting Logic ---
plot(canShow and useSession ? vS : na, "Session VWAP", colSession, style = plot.style_linebr)
plot(canShow and useWeek    ? vW : na, "Week VWAP", colWeek, style = plot.style_linebr)
plot(canShow and useMonth   ? vM : na, "Month VWAP", colMonth, style = plot.style_linebr)
plot(canShow and useQuarter ? vQ : na, "Quarter VWAP", colQuarter, style = plot.style_linebr)
plot(canShow and useYear    ? vY : na, "Year VWAP", colYear, style = plot.style_linebr)
plot(canShow and useDecade  ? vD : na, "Decade VWAP", colDecade, style = plot.style_linebr)
plot(canShow and useAllTime ? vA : na, "All Time VWAP", colAllTime, style = plot.style_linebr)
plot(canShow and showEarnings? vE : na, "Earnings VWAP", colEarnings, style = plot.style_linebr)
plot(canShow and showDivs    ? vDiv : na, "Dividends VWAP", colDivs, style = plot.style_linebr)
plot(canShow and showSplits  ? vSplit : na, "Splits VWAP", colSplits, style = plot.style_linebr)

plot(canShow and showC1 ? vC1 : na, "Custom 1", colC1, style = plot.style_linebr)
plot(canShow and showC2 ? vC2 : na, "Custom 2", colC2, style = plot.style_linebr)
plot(canShow and showC3 ? vC3 : na, "Custom 3", colC3, style = plot.style_linebr)
plot(canShow and showC4 ? vC4 : na, "Custom 4", colC4, style = plot.style_linebr)
plot(canShow and showC5 ? vC5 : na, "Custom 5", colC5, style = plot.style_linebr)

// --- Labels ---
updateLabel(lbl, val, txt, col) =>
    if barstate.islast and not na(val)
        if na(lbl)
            label.new(bar_index + labelOffset, val, txt, color = #00000000, style = label.style_label_left, textcolor = col, size = getLabelSize())
        else
            label.set_xy(lbl, bar_index + labelOffset, val)
            label.set_textcolor(lbl, col)
            label.set_size(lbl, getLabelSize())
            lbl
    else
        lbl

var label labelS = na, labelS := updateLabel(labelS, canShow and useSession ? vS : na, "Session", colSession)
var label labelW = na, labelW := updateLabel(labelW, canShow and useWeek ? vW : na, "Week", colWeek)
var label labelM = na, labelM := updateLabel(labelM, canShow and useMonth ? vM : na, "Month", colMonth)
var label labelQ = na, labelQ := updateLabel(labelQ, canShow and useQuarter ? vQ : na, "Quarter", colQuarter)
var label labelY = na, labelY := updateLabel(labelY, canShow and useYear ? vY : na, "Year", colYear)
var label labelD = na, labelD := updateLabel(labelD, canShow and useDecade ? vD : na, "Decade", colDecade)
var label labelA = na, labelA := updateLabel(labelA, canShow and useAllTime ? vA : na, "All Time", colAllTime)
var label labelE = na, labelE := updateLabel(labelE, canShow and showEarnings ? vE : na, "Earnings", colEarnings)
var label labelDiv = na, labelDiv := updateLabel(labelDiv, canShow and showDivs ? vDiv : na, "Dividends", colDivs)
var label labelSpl = na, labelSpl := updateLabel(labelSpl, canShow and showSplits ? vSplit : na, "Splits", colSplits)

var label labelC1 = na, labelC1 := updateLabel(labelC1, canShow and showC1 ? vC1 : na, nameC1, colC1)
var label labelC2 = na, labelC2 := updateLabel(labelC2, canShow and showC2 ? vC2 : na, nameC2, colC2)
var label labelC3 = na, labelC3 := updateLabel(labelC3, canShow and showC3 ? vC3 : na, nameC3, colC3)
var label labelC4 = na, labelC4 := updateLabel(labelC4, canShow and showC4 ? vC4 : na, nameC4, colC4)
var label labelC5 = na, labelC5 := updateLabel(labelC5, canShow and showC5 ? vC5 : na, nameC5, colC5)
````
