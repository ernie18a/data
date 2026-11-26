# Distance from Moving Average (%) Daily & Weekly

- url: https://www.tradingview.com/script/q7UauEzc-Distance-from-Moving-Average-Daily-Weekly/
- type: indicator
- pine_id: PUB;b007b25a3e4a493f91dc72e4c4aeae52
- version: 1.0

## Description

A clean histogram oscillator showing how far price is currently trading above or below any moving average — in percentage terms. Configurable MA length, type, and timeframe (daily, weekly, monthly, etc.) so you can quickly switch between short-term and long-term trend reference points.

## Source Code

````pine
//@version=5
indicator(title="Distance from Moving Average (%)", shorttitle="Dist-from-MA", overlay=false, format=format.percent, precision=2)

// ============================================================
// INPUTS
// ============================================================
grpMA = "Moving Average"
maLength   = input.int(10, "MA Length", minval=1, maxval=500, group=grpMA, tooltip="Number of periods in the moving average. Default 10.")
maType     = input.string("EMA", "MA Type", options=["SMA","EMA","WMA","HMA","RMA"], group=grpMA, tooltip="EMA = Exponential, SMA = Simple, WMA = Weighted, HMA = Hull, RMA = Wilders.")
maTFChoice = input.string("Daily", "MA Timeframe", options=["Current Chart","Daily","Weekly","Monthly","4 Hours","1 Hour"], group=grpMA, tooltip="Timeframe used to compute the MA. 'Daily' with length 10 = 10-day MA. 'Weekly' with length 10 = 10-week MA.")
maSrc      = input.source(close, "MA Source", group=grpMA)

grpSmooth = "Smoothing"
showSmooth = input.bool(true, "Show Smoothing Line", group=grpSmooth)
smoothLen  = input.int(21, "Smoothing Length", minval=1, maxval=200, group=grpSmooth, tooltip="Length of the moving average applied to the distance histogram.")
smoothType = input.string("EMA", "Smoothing Type", options=["SMA","EMA","WMA"], group=grpSmooth)

grpStyle = "Style"
posColor    = input.color(#ef5350, "Above MA (positive)", group=grpStyle)
negColor    = input.color(#ff9800, "Below MA (negative)", group=grpStyle)
zeroColor   = input.color(color.gray, "Zero Line Color", group=grpStyle)
smoothColor = input.color(color.new(#2196f3, 0), "Smoothing Line Color", group=grpStyle)
barWidth    = input.int(4, "Bar Width", minval=1, maxval=10, group=grpStyle)

grpAlerts = "Display & Threshold"
showLabel  = input.bool(true, "Show Current Value Label", group=grpAlerts)
extremeThr = input.float(3.0, "Extreme Threshold (%)", minval=0.5, maxval=20, step=0.5, group=grpAlerts, tooltip="Bars exceeding +/- this percentage are shown in brighter shade.")

// ============================================================
// MAP TIMEFRAME CHOICE TO PINE TIMEFRAME STRING
// ============================================================
maTF = maTFChoice == "Current Chart" ? timeframe.period : maTFChoice == "Daily" ? "D" : maTFChoice == "Weekly" ? "W" : maTFChoice == "Monthly" ? "M" : maTFChoice == "4 Hours" ? "240" : "60"

// ============================================================
// MOVING AVERAGE FUNCTION
// ============================================================
f_ma(_src, _len, _type) =>
    _type == "SMA" ? ta.sma(_src, _len) :
     _type == "EMA" ? ta.ema(_src, _len) :
     _type == "WMA" ? ta.wma(_src, _len) :
     _type == "HMA" ? ta.hma(_src, _len) :
     ta.rma(_src, _len)

// Request MA from the chosen timeframe
maValue = request.security(syminfo.tickerid, maTF, f_ma(maSrc, maLength, maType), lookahead=barmerge.lookahead_off)

// ============================================================
// DISTANCE %
// ============================================================
distPct = na(maValue) or maValue == 0 ? na : ((close - maValue) / maValue) * 100.0

// ============================================================
// HISTOGRAM
// ============================================================
isPos = distPct >= 0
isExtreme = math.abs(distPct) >= extremeThr
barColor = isPos ? (isExtreme ? posColor : color.new(posColor, 30)) : (isExtreme ? negColor : color.new(negColor, 30))

plot(distPct, title="Distance from MA (%)", style=plot.style_histogram, color=barColor, linewidth=barWidth)

// ============================================================
// SMOOTHING LINE
// ============================================================
f_smooth(_src, _len, _type) =>
    _type == "SMA" ? ta.sma(_src, _len) :
     _type == "EMA" ? ta.ema(_src, _len) :
     ta.wma(_src, _len)

smoothLine = showSmooth ? f_smooth(distPct, smoothLen, smoothType) : na
plot(smoothLine, title="Smoothing", color=smoothColor, linewidth=2)

// ============================================================
// REFERENCE LINES
// ============================================================
hline(0,            title="Zero",       color=zeroColor, linestyle=hline.style_solid, linewidth=1)
hline(extremeThr,   title="Extreme +",  color=color.new(posColor, 70), linestyle=hline.style_dashed)
hline(-extremeThr,  title="Extreme -",  color=color.new(negColor, 70), linestyle=hline.style_dashed)

// ============================================================
// CURRENT VALUE LABEL
// ============================================================
var label curLbl = na
if showLabel and barstate.islast and not na(distPct)
    label.delete(curLbl)
    sign = distPct >= 0 ? "+" : ""
    tfLabel = maTFChoice == "Current Chart" ? "" : (maTFChoice == "Daily" ? "D" : maTFChoice == "Weekly" ? "W" : maTFChoice == "Monthly" ? "M" : maTFChoice == "4 Hours" ? "4H" : "1H")
    txt = sign + str.tostring(distPct, "#.##") + "% " + (distPct >= 0 ? "above" : "below") + " " + str.tostring(maLength) + tfLabel + " " + maType
    curLbl := label.new(bar_index, distPct, txt, style=label.style_label_left, color=color.new(distPct >= 0 ? posColor : negColor, 30), textcolor=color.white, size=size.small)
````
