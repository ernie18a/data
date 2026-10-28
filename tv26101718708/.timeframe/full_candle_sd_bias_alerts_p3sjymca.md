# Full Candle S/D Bias Alerts

- url: https://www.tradingview.com/script/p3sjymCA-Full-Candle-S-D-Bias-Alerts/
- type: indicator
- pine_id: PUB;a7aaaee2d50a4980843e1d443fbffd1b
- version: 6.0

## Description

Full Candle S/D Zones with MTF Bias and Alerts

This indicator plots supply and demand zones using confirmed swing high and swing low candles. It includes a multi-timeframe bias table using 5m, 15m, and 60m trend direction, stochastic momentum confirmation, safety filters to avoid late entries, optional reversal signals, and alert conditions for A+, B+, and reversal setups.

The table shows directional bias only. Chart labels show potential setup areas after candle confirmation. Signals should be used with trader discretion and risk management. This script does not guarantee profitable trades and is not financial advice.

## Source Code

````pine
//@version=6
indicator("Full Candle S/D Bias Alerts - Better BOS Zones", overlay=true, max_boxes_count=100, max_labels_count=100, max_lines_count=100)

// This indicator is for educational and decision-support purposes only.
// It does not guarantee profitable trades. Always use risk management.

//-------------------- INPUTS --------------------
pivotLen = input.int(5, "Swing Strength", minval=2, maxval=20)

showTable = input.bool(true, "Show Table")
showSignals = input.bool(true, "Show Signals")
showSLTP = input.bool(true, "Show SL / TP1 / TP2")

rr1 = input.float(1.0, "TP1 Risk Reward", step=0.25)
rr2 = input.float(2.0, "TP2 Risk Reward", step=0.25)

// Supply / Demand settings
zoneLookback = input.int(20, "Zone Candle Lookback", minval=3, maxval=100)
minBosMoveATR = input.float(0.25, "Minimum BOS Strength ATR", step=0.05)
showBOS = input.bool(true, "Show BOS Labels")
deleteOldZones = input.bool(true, "Only Show Most Recent Zone")
hideBrokenZones = input.bool(false, "Hide Broken Zones")
useBodyZone = input.bool(true, "Use Body-To-Wick Zones")

// Stoch settings
periodK = input.int(14, "%K Length", minval=1)
smoothK = input.int(3, "%K Smoothing", minval=1)
periodD = input.int(3, "%D Smoothing", minval=1)

oversoldLevel = input.float(30, "Oversold Block Sell Level")
overboughtLevel = input.float(70, "Overbought Block Buy Level")

showReversals = input.bool(true, "Show REV Buy/Sell Signals")
confirmedOnly = input.bool(true, "Only Signal After Candle Close")

//-------------------- COLORS --------------------
demandColor = color.new(color.lime, 82)
supplyColor = color.new(color.red, 82)
demandBorder = color.new(color.lime, 15)
supplyBorder = color.new(color.red, 15)

//-------------------- CONFIRMATION --------------------
confirmed = confirmedOnly ? barstate.isconfirmed : true

//-------------------- ATR --------------------
atr = ta.atr(14)

//-------------------- STOCHASTIC --------------------
k = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
d = ta.sma(k, periodD)

stochBullMom = k > d
stochBearMom = k < d

stochOversold = k < oversoldLevel
stochOverbought = k > overboughtLevel

stochTurningUp = k > k[1] and k < 45
stochTurningDown = k < k[1] and k > 55

bullCross = ta.crossover(k, d)
bearCross = ta.crossunder(k, d)

//-------------------- SWINGS --------------------
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(ph)
    lastSwingHigh := ph

if not na(pl)
    lastSwingLow := pl

//-------------------- BETTER SUPPLY / DEMAND ZONES --------------------
// Demand = lowest bearish candle before bullish BOS.
// Supply = highest bullish candle before bearish BOS.

bullBOS = confirmed and not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh and math.abs(close - lastSwingHigh) > atr * minBosMoveATR
bearBOS = confirmed and not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow and math.abs(close - lastSwingLow) > atr * minBosMoveATR

var box demandBox = na
var box supplyBox = na

var float demandTop = na
var float demandBot = na
var float supplyTop = na
var float supplyBot = na

//-------------------- DEMAND ZONE --------------------
if bullBOS
    int foundDemand = na
    float bestLow = na
    float zTop = na
    float zBot = na

    for i = 1 to zoneLookback
        isBearCandle = close[i] < open[i]

        if isBearCandle
            if na(bestLow) or low[i] < bestLow
                bestLow := low[i]
                foundDemand := i
                zTop := useBodyZone ? open[i] : high[i]
                zBot := low[i]

    if not na(foundDemand)
        demandTop := zTop
        demandBot := zBot

        if deleteOldZones and not na(demandBox)
            box.delete(demandBox)

        demandBox := box.new(
             left=bar_index - foundDemand,
             top=demandTop,
             right=bar_index,
             bottom=demandBot,
             xloc=xloc.bar_index,
             extend=extend.right,
             bgcolor=demandColor,
             border_color=demandBorder)

        if showBOS
            label.new(
                 x=bar_index,
                 y=low,
                 text="BOS",
                 xloc=xloc.bar_index,
                 yloc=yloc.belowbar,
                 style=label.style_label_up,
                 color=color.green,
                 textcolor=color.white,
                 size=size.tiny)

//-------------------- SUPPLY ZONE --------------------
if bearBOS
    int foundSupply = na
    float bestHigh = na
    float zTop = na
    float zBot = na

    for i = 1 to zoneLookback
        isBullCandle = close[i] > open[i]

        if isBullCandle
            if na(bestHigh) or high[i] > bestHigh
                bestHigh := high[i]
                foundSupply := i
                zTop := high[i]
                zBot := useBodyZone ? open[i] : low[i]

    if not na(foundSupply)
        supplyTop := zTop
        supplyBot := zBot

        if deleteOldZones and not na(supplyBox)
            box.delete(supplyBox)

        supplyBox := box.new(
             left=bar_index - foundSupply,
             top=supplyTop,
             right=bar_index,
             bottom=supplyBot,
             xloc=xloc.bar_index,
             extend=extend.right,
             bgcolor=supplyColor,
             border_color=supplyBorder)

        if showBOS
            label.new(
                 x=bar_index,
                 y=high,
                 text="BOS",
                 xloc=xloc.bar_index,
                 yloc=yloc.abovebar,
                 style=label.style_label_down,
                 color=color.red,
                 textcolor=color.white,
                 size=size.tiny)

//-------------------- BROKEN ZONE CONTROL --------------------
if hideBrokenZones and not na(demandBox) and not na(demandBot) and close < demandBot
    box.delete(demandBox)
    demandBox := na
    demandTop := na
    demandBot := na

if hideBrokenZones and not na(supplyBox) and not na(supplyTop) and close > supplyTop
    box.delete(supplyBox)
    supplyBox := na
    supplyTop := na
    supplyBot := na

//-------------------- MTF BIAS --------------------
getBias(tf) =>
    fast = request.security(syminfo.tickerid, tf, ta.ema(close, 20))
    slow = request.security(syminfo.tickerid, tf, ta.ema(close, 50))
    fast > slow ? 1 : fast < slow ? -1 : 0

bias5 = getBias("5")
bias15 = getBias("15")
bias60 = getBias("60")

bullCount = (bias5 == 1 ? 1 : 0) + (bias15 == 1 ? 1 : 0) + (bias60 == 1 ? 1 : 0) + (stochBullMom ? 1 : 0)
bearCount = (bias5 == -1 ? 1 : 0) + (bias15 == -1 ? 1 : 0) + (bias60 == -1 ? 1 : 0) + (stochBearMom ? 1 : 0)

allBull = bias5 == 1 and bias15 == 1 and bias60 == 1 and stochBullMom
allBear = bias5 == -1 and bias15 == -1 and bias60 == -1 and stochBearMom

//-------------------- ZONE TOUCH / REJECTION --------------------
inDemand = not na(demandTop) and not na(demandBot) and low <= demandTop and high >= demandBot
inSupply = not na(supplyTop) and not na(supplyBot) and high >= supplyBot and low <= supplyTop

bullCandle = close > open
bearCandle = close < open

demandReject = inDemand and bullCandle and close > demandBot
supplyReject = inSupply and bearCandle and close < supplyTop

strongDemandReject = inDemand and bullCandle and close > demandTop
strongSupplyReject = inSupply and bearCandle and close < supplyBot

//-------------------- LATE ENTRY SAFETY FILTERS --------------------
bigDrop = close < open and (open - close) > atr * 1.2
bigPump = close > open and (close - open) > atr * 1.2

recentBigDrop = bigDrop or bigDrop[1] or bigDrop[2]
recentBigPump = bigPump or bigPump[1] or bigPump[2]

safeToSell = not stochOversold and not stochTurningUp and not recentBigDrop
safeToBuy = not stochOverbought and not stochTurningDown and not recentBigPump

//-------------------- TREND SIGNALS --------------------
aPlusBuy = showSignals and confirmed and strongDemandReject and allBull and safeToBuy
bPlusBuy = showSignals and confirmed and demandReject and bullCount == 3 and safeToBuy and not aPlusBuy

aPlusSell = showSignals and confirmed and strongSupplyReject and allBear and safeToSell
bPlusSell = showSignals and confirmed and supplyReject and bearCount == 3 and safeToSell and not aPlusSell

//-------------------- REVERSAL SIGNALS --------------------
revBuy = showSignals and confirmed and showReversals and demandReject and bearCount >= 3 and stochOversold and (stochTurningUp or bullCross)
revSell = showSignals and confirmed and showReversals and supplyReject and bullCount >= 3 and stochOverbought and (stochTurningDown or bearCross)

longSignal = aPlusBuy or bPlusBuy or revBuy
shortSignal = aPlusSell or bPlusSell or revSell

//-------------------- CHART LABELS --------------------
plotshape(aPlusBuy, title="A+ Buy", style=shape.labelup, text="A+ BUY", location=location.belowbar, color=color.new(color.lime, 0), textcolor=color.black, size=size.normal)
plotshape(bPlusBuy, title="B+ Buy", style=shape.labelup, text="B+ BUY", location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, size=size.small)

plotshape(aPlusSell, title="A+ Sell", style=shape.labeldown, text="A+ SELL", location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.normal)
plotshape(bPlusSell, title="B+ Sell", style=shape.labeldown, text="B+ SELL", location=location.abovebar, color=color.new(color.maroon, 0), textcolor=color.white, size=size.small)

plotshape(revBuy, title="REV Buy", style=shape.labelup, text="REV BUY", location=location.belowbar, color=color.new(color.aqua, 0), textcolor=color.black, size=size.small)
plotshape(revSell, title="REV Sell", style=shape.labeldown, text="REV SELL", location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.black, size=size.small)

//-------------------- SL / TP LINES --------------------
var line slLine = na
var line tp1Line = na
var line tp2Line = na

var label slLabel = na
var label tp1Label = na
var label tp2Label = na

deleteLevels() =>
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(slLabel)
        label.delete(slLabel)
    if not na(tp1Label)
        label.delete(tp1Label)
    if not na(tp2Label)
        label.delete(tp2Label)

if showSLTP and longSignal and not na(demandBot)
    deleteLevels()

    entry = close
    sl = demandBot
    risk = entry - sl
    tp1 = entry + risk * rr1
    tp2 = entry + risk * rr2

    if risk > 0
        slLine := line.new(bar_index, sl, bar_index + 30, sl, xloc=xloc.bar_index, color=color.red, width=2)
        tp1Line := line.new(bar_index, tp1, bar_index + 30, tp1, xloc=xloc.bar_index, color=color.lime, width=2)
        tp2Line := line.new(bar_index, tp2, bar_index + 30, tp2, xloc=xloc.bar_index, color=color.lime, width=2)

        slLabel := label.new(bar_index + 30, sl, "SL", xloc=xloc.bar_index, style=label.style_label_left, color=color.red, textcolor=color.white)
        tp1Label := label.new(bar_index + 30, tp1, "TP1", xloc=xloc.bar_index, style=label.style_label_left, color=color.lime, textcolor=color.black)
        tp2Label := label.new(bar_index + 30, tp2, "TP2", xloc=xloc.bar_index, style=label.style_label_left, color=color.lime, textcolor=color.black)

if showSLTP and shortSignal and not na(supplyTop)
    deleteLevels()

    entry = close
    sl = supplyTop
    risk = sl - entry
    tp1 = entry - risk * rr1
    tp2 = entry - risk * rr2

    if risk > 0
        slLine := line.new(bar_index, sl, bar_index + 30, sl, xloc=xloc.bar_index, color=color.red, width=2)
        tp1Line := line.new(bar_index, tp1, bar_index + 30, tp1, xloc=xloc.bar_index, color=color.lime, width=2)
        tp2Line := line.new(bar_index, tp2, bar_index + 30, tp2, xloc=xloc.bar_index, color=color.lime, width=2)

        slLabel := label.new(bar_index + 30, sl, "SL", xloc=xloc.bar_index, style=label.style_label_left, color=color.red, textcolor=color.white)
        tp1Label := label.new(bar_index + 30, tp1, "TP1", xloc=xloc.bar_index, style=label.style_label_left, color=color.lime, textcolor=color.black)
        tp2Label := label.new(bar_index + 30, tp2, "TP2", xloc=xloc.bar_index, style=label.style_label_left, color=color.lime, textcolor=color.black)

//-------------------- CLEAN STATUS TABLE --------------------
biasText(x) =>
    x == 1 ? "BULL" : x == -1 ? "BEAR" : "WAIT"

biasColor(x) =>
    x == 1 ? color.new(color.lime, 0) : x == -1 ? color.new(color.red, 0) : color.new(color.gray, 0)

stochText = stochBullMom ? "BULL MOM" : stochBearMom ? "BEAR MOM" : "FLAT"
stochColor = stochBullMom ? color.new(color.lime, 0) : stochBearMom ? color.new(color.red, 0) : color.new(color.gray, 0)

setupText = allBull ? "A+ BUY BIAS" : allBear ? "A+ SELL BIAS" : bullCount == 3 ? "B+ BUY BIAS" : bearCount == 3 ? "B+ SELL BIAS" : "WAIT"
setupColor = allBull or bullCount == 3 ? color.new(color.lime, 0) : allBear or bearCount == 3 ? color.new(color.red, 0) : color.new(color.gray, 0)

safetyText = safeToBuy and safeToSell ? "OK" : not safeToSell ? "NO LATE SELL" : not safeToBuy ? "NO LATE BUY" : "WAIT"
safetyColor = safetyText == "OK" ? color.new(color.lime, 0) : color.new(color.orange, 0)

zoneText = inDemand ? "IN DEMAND" : inSupply ? "IN SUPPLY" : "NO ZONE TAP"
zoneColor = inDemand ? color.new(color.lime, 0) : inSupply ? color.new(color.red, 0) : color.new(color.gray, 0)

panelDark = color.new(color.rgb(20, 24, 31), 0)
panelMid = color.new(color.rgb(35, 40, 50), 0)
headerBg = color.new(color.rgb(15, 18, 24), 0)
lineBg = color.new(color.rgb(45, 51, 62), 0)

var table dash = table.new(position.top_right, 2, 9, border_width=1, frame_color=color.new(color.gray, 35), border_color=color.new(color.gray, 55))

if barstate.isfirst
    table.merge_cells(dash, 0, 0, 1, 0)

if showTable and barstate.islast
    table.cell(dash, 0, 0, "STATUS", text_color=color.white, bgcolor=headerBg, text_size=size.normal, text_halign=text.align_center)

    table.cell(dash, 0, 1, "CHECK", text_color=color.new(color.white, 10), bgcolor=lineBg, text_size=size.small)
    table.cell(dash, 1, 1, "STATUS", text_color=color.new(color.white, 10), bgcolor=lineBg, text_size=size.small)

    table.cell(dash, 0, 2, "5m", text_color=color.white, bgcolor=panelDark, text_size=size.small)
    table.cell(dash, 1, 2, biasText(bias5), text_color=biasColor(bias5), bgcolor=panelDark, text_size=size.small)

    table.cell(dash, 0, 3, "15m", text_color=color.white, bgcolor=panelMid, text_size=size.small)
    table.cell(dash, 1, 3, biasText(bias15), text_color=biasColor(bias15), bgcolor=panelMid, text_size=size.small)

    table.cell(dash, 0, 4, "60m", text_color=color.white, bgcolor=panelDark, text_size=size.small)
    table.cell(dash, 1, 4, biasText(bias60), text_color=biasColor(bias60), bgcolor=panelDark, text_size=size.small)

    table.cell(dash, 0, 5, "STOCH", text_color=color.white, bgcolor=panelMid, text_size=size.small)
    table.cell(dash, 1, 5, stochText, text_color=stochColor, bgcolor=panelMid, text_size=size.small)

    table.cell(dash, 0, 6, "ZONE", text_color=color.white, bgcolor=panelDark, text_size=size.small)
    table.cell(dash, 1, 6, zoneText, text_color=zoneColor, bgcolor=panelDark, text_size=size.small)

    table.cell(dash, 0, 7, "BIAS", text_color=color.white, bgcolor=panelMid, text_size=size.small)
    table.cell(dash, 1, 7, setupText, text_color=setupColor, bgcolor=panelMid, text_size=size.small)

    table.cell(dash, 0, 8, "SAFETY", text_color=color.white, bgcolor=panelDark, text_size=size.small)
    table.cell(dash, 1, 8, safetyText, text_color=safetyColor, bgcolor=panelDark, text_size=size.small)

else if not showTable and barstate.islast
    table.clear(dash, 0, 0, 1, 8)

//-------------------- ALERTS --------------------
alertcondition(bullBOS, title="Bullish BOS Alert", message="Bullish BOS detected. Demand zone created on {{ticker}} {{interval}}")
alertcondition(bearBOS, title="Bearish BOS Alert", message="Bearish BOS detected. Supply zone created on {{ticker}} {{interval}}")

alertcondition(aPlusBuy, title="A+ Buy Alert", message="A+ BUY setup on {{ticker}} {{interval}}")
alertcondition(bPlusBuy, title="B+ Buy Alert", message="B+ BUY setup on {{ticker}} {{interval}}")
alertcondition(aPlusSell, title="A+ Sell Alert", message="A+ SELL setup on {{ticker}} {{interval}}")
alertcondition(bPlusSell, title="B+ SELL Alert", message="B+ SELL setup on {{ticker}} {{interval}}")

alertcondition(revBuy, title="REV Buy Alert", message="REV BUY counter-trend bounce on {{ticker}} {{interval}}")
alertcondition(revSell, title="REV Sell Alert", message="REV SELL counter-trend rejection on {{ticker}} {{interval}}")
````
