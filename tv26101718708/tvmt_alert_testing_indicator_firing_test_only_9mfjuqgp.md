# TVMT- Alert Testing Indicator (Firing Test only)

- url: https://www.tradingview.com/script/9MfJUqgp-TVMT-Alert-Testing-Indicator-Firing-Test-only/
- type: indicator
- pine_id: PUB;2666862404bb4389aa9828170fb382fe
- version: 7.0

## Description

This indicator is exclusively for TVMT users. It is created for testing signal firing and alert demonstrations only, and should not be considered a complete trading strategy.

For more information, please visit: https://tvmt.lorghic.com/

## Source Code

````pine
//@version=6
indicator("TVMT- Alert Testing Indicator (Firing Test only)", overlay = true, max_lines_count = 500, max_labels_count = 100)

// Inputs
gSig = "Signal"
fastLen  = input.int(9,  "Fast EMA", minval = 1, group = gSig)
slowLen  = input.int(21, "Slow EMA", minval = 1, group = gSig)
useTrend = input.bool(false, "Trend filter (trade with the trend only)", group = gSig)
trendLen = input.int(200, "Trend EMA", minval = 1, group = gSig)
showEMAs = input.bool(true, "Show EMAs", group = gSig)

gRisk = "SL / TP"
stopMethod = input.string("ATR", "Stop method", options = ["ATR", "Percent", "Pips"], group = gRisk)
atrLen  = input.int(14, "ATR length", minval = 1, group = gRisk)
atrMult = input.float(1.5, "ATR multiplier", minval = 0.1, step = 0.1, group = gRisk)
stopPct = input.float(1.0, "Stop percent (%)", minval = 0.1, step = 0.1, group = gRisk)
stopPips = input.float(20.0, "SL pips", minval = 0.1, step = 0.1, group = gRisk)
tpMethod = input.string("R Multiple", "TP method", options = ["R Multiple", "Pips"], group = gRisk)
rr1 = input.float(1.0, "TP1 (R multiple)", minval = 0.1, step = 0.1, group = gRisk)
rr2 = input.float(2.0, "TP2 (R multiple)", minval = 0.1, step = 0.1, group = gRisk)
rr3 = input.float(3.0, "TP3 (R multiple)", minval = 0.1, step = 0.1, group = gRisk)
tp1Pips = input.float(20.0, "TP1 pips", minval = 0.1, step = 0.1, group = gRisk)
tp2Pips = input.float(40.0, "TP2 pips", minval = 0.1, step = 0.1, group = gRisk)
tp3Pips = input.float(60.0, "TP3 pips", minval = 0.1, step = 0.1, group = gRisk)
showTP3 = input.bool(true, "Show TP3", group = gRisk)

gDisp = "Display"
showLabels  = input.bool(true, "Price labels", group = gDisp)
labelOffset = input.int(5, "Label offset (bars)", minval = 1, maxval = 100, group = gDisp)
showPanel   = input.bool(true, "Show info panel", group = gDisp)

// Colors
cEntry = color.rgb(33, 150, 243)
cStop  = color.rgb(239, 83, 80)
cTp1   = color.rgb(38, 166, 154)
cTp2   = color.rgb(102, 187, 106)
cTp3   = color.rgb(255, 193, 7)
cLong  = color.rgb(0, 150, 136)
cShort = color.rgb(229, 57, 53)

// Pip helper
isForex = syminfo.type == "forex"
isJpyPair = isForex and str.contains(syminfo.ticker, "JPY")
isGold = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
pipSize = isGold ? 0.10 : (isForex ? (isJpyPair ? 0.01 : 0.0001) : syminfo.mintick)

// Signal logic
emaFast  = ta.ema(close, fastLen)
emaSlow  = ta.ema(close, slowLen)
emaTrend = ta.ema(close, trendLen)
atrVal   = ta.atr(atrLen)

trendUp     = not useTrend or close > emaTrend
trendDown   = not useTrend or close < emaTrend
longSignal  = ta.crossover(emaFast, emaSlow)  and trendUp
shortSignal = ta.crossunder(emaFast, emaSlow) and trendDown
newSetup    = longSignal or shortSignal

var float entryPrice = na
var float riskDist   = na
var int   dir        = 0

if newSetup
    dir := longSignal ? 1 : -1
    entryPrice := close
    rawRisk = stopMethod == "ATR" ? atrVal * atrMult : (stopMethod == "Percent" ? entryPrice * stopPct / 100.0 : stopPips * pipSize)
    riskDist := math.max(rawRisk, syminfo.mintick)

active = dir != 0 and not na(entryPrice) and not na(riskDist)
tp1Dist = active ? (tpMethod == "Pips" ? tp1Pips * pipSize : riskDist * rr1) : na
tp2Dist = active ? (tpMethod == "Pips" ? tp2Pips * pipSize : riskDist * rr2) : na
tp3Dist = active ? (tpMethod == "Pips" ? tp3Pips * pipSize : riskDist * rr3) : na
slPrice  = active ? entryPrice - dir * riskDist : na
tp1Price = active ? entryPrice + dir * tp1Dist : na
tp2Price = active ? entryPrice + dir * tp2Dist : na
tp3Price = active ? entryPrice + dir * tp3Dist : na
slPips  = active ? riskDist / pipSize : na
tp1PipsOut = active ? tp1Dist / pipSize : na
tp2PipsOut = active ? tp2Dist / pipSize : na
tp3PipsOut = active ? tp3Dist / pipSize : na

// Level lines
var line lE = na
var line lS = na
var line l1 = na
var line l2 = na
var line l3 = na

if newSetup
    line.delete(lE)
    line.delete(lS)
    line.delete(l1)
    line.delete(l2)
    line.delete(l3)
    lE := line.new(bar_index, entryPrice, bar_index + 1, entryPrice, xloc = xloc.bar_index, extend = extend.right, color = cEntry, width = 2)
    lS := line.new(bar_index, slPrice,  bar_index + 1, slPrice,  xloc = xloc.bar_index, extend = extend.right, color = cStop, width = 2, style = line.style_dashed)
    l1 := line.new(bar_index, tp1Price, bar_index + 1, tp1Price, xloc = xloc.bar_index, extend = extend.right, color = cTp1, width = 1)
    l2 := line.new(bar_index, tp2Price, bar_index + 1, tp2Price, xloc = xloc.bar_index, extend = extend.right, color = cTp2, width = 1)
    l3 := showTP3 ? line.new(bar_index, tp3Price, bar_index + 1, tp3Price, xloc = xloc.bar_index, extend = extend.right, color = cTp3, width = 1) : na

// Labels
priceText(price) => str.tostring(price, format.mintick)
pipsText(pips) => str.tostring(pips, "#.##") + " pips"
levelText(name, price) => name + "  " + priceText(price)
levelTextPips(name, price, pips) => name + "  " + priceText(price) + "  (" + pipsText(pips) + ")"

var label bE = na
var label bS = na
var label b1 = na
var label b2 = na
var label b3 = na

if barstate.islast and showLabels and active
    lx = bar_index + labelOffset
    if na(bE)
        bE := label.new(lx, entryPrice, "", xloc = xloc.bar_index, style = label.style_label_left, color = cEntry, textcolor = color.white, size = size.small)
    label.set_xy(bE, lx, entryPrice), label.set_text(bE, levelText("ENTRY", entryPrice))
    if na(bS)
        bS := label.new(lx, slPrice, "", xloc = xloc.bar_index, style = label.style_label_left, color = cStop, textcolor = color.white, size = size.small)
    label.set_xy(bS, lx, slPrice), label.set_text(bS, levelTextPips("SL", slPrice, slPips))
    if na(b1)
        b1 := label.new(lx, tp1Price, "", xloc = xloc.bar_index, style = label.style_label_left, color = cTp1, textcolor = color.white, size = size.small)
    label.set_xy(b1, lx, tp1Price), label.set_text(b1, levelTextPips("TP1", tp1Price, tp1PipsOut))
    if na(b2)
        b2 := label.new(lx, tp2Price, "", xloc = xloc.bar_index, style = label.style_label_left, color = cTp2, textcolor = color.white, size = size.small)
    label.set_xy(b2, lx, tp2Price), label.set_text(b2, levelTextPips("TP2", tp2Price, tp2PipsOut))
    if showTP3
        if na(b3)
            b3 := label.new(lx, tp3Price, "", xloc = xloc.bar_index, style = label.style_label_left, color = cTp3, textcolor = color.black, size = size.small)
        label.set_xy(b3, lx, tp3Price), label.set_text(b3, levelTextPips("TP3", tp3Price, tp3PipsOut))

// Hit detection
prevHigh = nz(high[1], high)
prevLow  = nz(low[1], low)
hitStop = active and ((dir ==  1 and low  <= slPrice  and prevLow  > slPrice)  or (dir == -1 and high >= slPrice  and prevHigh < slPrice))
hitTp1  = active and ((dir ==  1 and high >= tp1Price and prevHigh < tp1Price) or (dir == -1 and low  <= tp1Price and prevLow  > tp1Price))
hitTp2  = active and ((dir ==  1 and high >= tp2Price and prevHigh < tp2Price) or (dir == -1 and low  <= tp2Price and prevLow  > tp2Price))
hitTp3  = active and showTP3 and ((dir == 1 and high >= tp3Price and prevHigh < tp3Price) or (dir == -1 and low <= tp3Price and prevLow > tp3Price))

// Plots
plot(showEMAs ? emaFast : na, "Fast EMA", color = color.new(cEntry, 20))
plot(showEMAs ? emaSlow : na, "Slow EMA", color = color.new(cStop, 20))
plot(showEMAs and useTrend ? emaTrend : na, "Trend EMA", color = color.new(color.gray, 0))

// Hidden series for the data window.
plot(active ? entryPrice : na, "Entry Level", display = display.data_window)
plot(active ? slPrice  : na, "SL Level",  display = display.data_window)
plot(active ? tp1Price : na, "TP1 Level", display = display.data_window)
plot(active ? tp2Price : na, "TP2 Level", display = display.data_window)
plot(active ? tp3Price : na, "TP3 Level", display = display.data_window)
plot(active ? slPips : na, "SL Pips", display = display.data_window)
plot(active ? tp1PipsOut : na, "TP1 Pips", display = display.data_window)
plot(active ? tp2PipsOut : na, "TP2 Pips", display = display.data_window)
plot(active ? tp3PipsOut : na, "TP3 Pips", display = display.data_window)

plotshape(longSignal,  "Long",  shape.labelup,   location.belowbar, cLong,  text = "LONG",  textcolor = color.white, size = size.tiny)
plotshape(shortSignal, "Short", shape.labeldown, location.abovebar, cShort, text = "SHORT", textcolor = color.white, size = size.tiny)
plotshape(hitStop ? slPrice  : na, "SL hit",  shape.xcross, location.absolute, cStop, size = size.tiny)
plotshape(hitTp1 ? tp1Price : na, "TP1 hit", shape.circle, location.absolute, cTp1, size = size.tiny)
plotshape(hitTp2 ? tp2Price : na, "TP2 hit", shape.circle, location.absolute, cTp2, size = size.tiny)
plotshape(hitTp3 ? tp3Price : na, "TP3 hit", shape.circle, location.absolute, cTp3, size = size.tiny)

// Info panel
var table panel = table.new(position.top_right, 2, 6, border_width = 1)
if showPanel and barstate.islast and active
    dCol = dir == 1 ? cLong : cShort
    table.cell(panel, 0, 0, "TVMT Setup", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
    table.cell(panel, 1, 0, dir == 1 ? "LONG" : "SHORT", text_color = color.white, bgcolor = dCol, text_size = size.small)
    table.cell(panel, 0, 1, "Entry", text_color = color.white, text_size = size.small)
    table.cell(panel, 1, 1, priceText(entryPrice), text_color = color.white, text_size = size.small)
    table.cell(panel, 0, 2, "SL", text_color = cStop, text_size = size.small)
    table.cell(panel, 1, 2, priceText(slPrice) + " (" + pipsText(slPips) + ")", text_color = cStop, text_size = size.small)
    table.cell(panel, 0, 3, "TP1", text_color = cTp1, text_size = size.small)
    table.cell(panel, 1, 3, priceText(tp1Price) + " (" + pipsText(tp1PipsOut) + ")", text_color = cTp1, text_size = size.small)
    table.cell(panel, 0, 4, "TP2", text_color = cTp2, text_size = size.small)
    table.cell(panel, 1, 4, priceText(tp2Price) + " (" + pipsText(tp2PipsOut) + ")", text_color = cTp2, text_size = size.small)
    table.cell(panel, 0, 5, "TP3", text_color = cTp3, text_size = size.small)
    table.cell(panel, 1, 5, showTP3 ? priceText(tp3Price) + " (" + pipsText(tp3PipsOut) + ")" : "-", text_color = cTp3, text_size = size.small)

// Alerts
// Point these two at your TVMT webhook to auto-execute in MT4/MT5/cTrader.
alertcondition(longSignal,  "Long -> TVMT",  '{"action":"buy","symbol":"{{ticker}}","entry":"{{plot_3}}","sl":"{{plot_4}}","tp":"{{plot_5}}","tp2":"{{plot_6}}","tp3":"{{plot_7}}","sl_pips":"{{plot_8}}","tp_pips":"{{plot_9}}","tp2_pips":"{{plot_10}}","tp3_pips":"{{plot_11}}"}')
alertcondition(shortSignal, "Short -> TVMT", '{"action":"sell","symbol":"{{ticker}}","entry":"{{plot_3}}","sl":"{{plot_4}}","tp":"{{plot_5}}","tp2":"{{plot_6}}","tp3":"{{plot_7}}","sl_pips":"{{plot_8}}","tp_pips":"{{plot_9}}","tp2_pips":"{{plot_10}}","tp3_pips":"{{plot_11}}"}')

// Information only. Do not send these to the TVMT webhook; the EA manages SL/TP itself.
alertcondition(hitStop, "SL hit (info)",  "Stop loss hit on {{ticker}}")
alertcondition(hitTp1,  "TP1 hit (info)", "TP1 hit on {{ticker}}")
alertcondition(hitTp2,  "TP2 hit (info)", "TP2 hit on {{ticker}}")
alertcondition(hitTp3,  "TP3 hit (info)", "TP3 hit on {{ticker}}")
````
