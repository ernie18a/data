# Shawn's Indicator

- url: https://www.tradingview.com/script/RZYlfGC2-Shawn-s-Indicator/
- type: indicator
- pine_id: PUB;edf6f774bca94d6986759b7298614d76
- version: 1.0

## Description

this is a indicator created base on Shawn's strategy

## Source Code

````pine
//@version=6
indicator("MACD Strength Labels + EMAs + Fixed Panel", overlay=true, max_labels_count=500)

//==================================================
// INPUT GROUPS
//==================================================
groupMacd   = "MACD Settings"
groupSignal = "Signal Strength"
groupVolume = "Volume Settings"
groupEma    = "EMA Settings"
groupVisual = "Visual Settings"
groupPanel  = "Info Panel"

//==================================================
// MACD SETTINGS
//==================================================
fastLen   = input.int(12, "MACD Fast Length", minval=1, group=groupMacd)
slowLen   = input.int(26, "MACD Slow Length", minval=1, group=groupMacd)
signalLen = input.int(9, "MACD Signal Length", minval=1, group=groupMacd)

//==================================================
// SIGNAL SETTINGS
//==================================================
useOneSideOnly = input.bool(true, "Only First Signal Until Opposite Signal", group=groupSignal)
cooldownBars   = input.int(0, "Cooldown Bars", minval=0, group=groupSignal)

showWeakSignals   = input.bool(true, "Show Weak Signals", group=groupSignal)
showNormalSignals = input.bool(true, "Show Normal Signals", group=groupSignal)
showStrongSignals = input.bool(true, "Show Strong Signals", group=groupSignal)

//==================================================
// VOLUME SETTINGS
//==================================================
volMaLen        = input.int(20, "Volume MA Length", minval=1, group=groupVolume)
volMultiplier   = input.float(2.0, "Strong Volume Multiplier", minval=0.1, step=0.1, group=groupVolume)
showVolumePanel = input.bool(true, "Show Fixed Info Panel", group=groupVolume)
showVolRatio    = input.bool(true, "Show Volume Ratio", group=groupVolume)

//==================================================
// EMA SETTINGS
//==================================================
showEMA20  = input.bool(true, "Show EMA 20", group=groupEma)
showEMA50  = input.bool(true, "Show EMA 50", group=groupEma)
showEMA200 = input.bool(true, "Show EMA 200", group=groupEma)

ema20Len  = input.int(20, "EMA 20 Length", minval=1, group=groupEma)
ema50Len  = input.int(50, "EMA 50 Length", minval=1, group=groupEma)
ema200Len = input.int(200, "EMA 200 Length", minval=1, group=groupEma)

useEmaTrendForStrong = input.bool(true, "Require EMA Trend For Strong Signals", group=groupEma)

//==================================================
// VISUAL SETTINGS
//==================================================
showBgBias        = input.bool(false, "Show EMA 200 Background Bias", group=groupVisual)
showSignalTextTag = input.bool(true, "Add Strength Tag To Label Text", group=groupVisual)
labelOffsetTicks  = input.int(250, "Label Offset Ticks", minval=1, group=groupVisual)

//==================================================
// PANEL SETTINGS
//==================================================
panelPosition = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupPanel)

//==================================================
// CORE CALCULATIONS
//==================================================
[macdLine, signalLine, histLine] = ta.macd(close, fastLen, slowLen, signalLen)

ema20  = ta.ema(close, ema20Len)
ema50  = ta.ema(close, ema50Len)
ema200 = ta.ema(close, ema200Len)

volMA = ta.sma(volume, volMaLen)

//==================================================
// VOLUME LOGIC
//==================================================
buyVol  = close > open ? volume : 0.0
sellVol = close < open ? volume : 0.0

buyVolStrong  = buyVol >= volMA * volMultiplier
sellVolStrong = sellVol >= volMA * volMultiplier

volRatio = volMA > 0 ? volume / volMA : na

//==================================================
// BASE LOGIC
//==================================================
macdBuyCross  = ta.crossover(macdLine, signalLine)
macdSellCross = ta.crossunder(macdLine, signalLine)

buyBelowZero  = macdLine < 0 and signalLine < 0
sellAboveZero = macdLine > 0 and signalLine > 0

histBull = histLine > 0 and histLine > histLine[1]
histBear = histLine < 0 and histLine < histLine[1]

emaBull = close > ema200
emaBear = close < ema200

//==================================================
// STRENGTH LEVELS
// weak   = zero-line reversal only
// normal = weak + histogram confirmation
// strong = normal + EMA bias + strong volume
//==================================================
weakBuyRaw   = macdBuyCross and buyBelowZero
weakSellRaw  = macdSellCross and sellAboveZero

normalBuyRaw  = weakBuyRaw and histBull
normalSellRaw = weakSellRaw and histBear

strongBuyRaw  = normalBuyRaw and (not useEmaTrendForStrong or emaBull) and buyVolStrong
strongSellRaw = normalSellRaw and (not useEmaTrendForStrong or emaBear) and sellVolStrong

normalBuyOnly  = normalBuyRaw and not strongBuyRaw
normalSellOnly = normalSellRaw and not strongSellRaw
weakBuyOnly    = weakBuyRaw and not normalBuyRaw
weakSellOnly   = weakSellRaw and not normalSellRaw

//==================================================
// SIDE CONTROL / COOLDOWN
//==================================================
var int lastPrintedSignal = 0
var int lastSignalBar = na

enoughBarsPassed = na(lastSignalBar) or (bar_index - lastSignalBar > cooldownBars)

allowBuy  = enoughBarsPassed and (not useOneSideOnly or lastPrintedSignal != 1)
allowSell = enoughBarsPassed and (not useOneSideOnly or lastPrintedSignal != -1)

weakBuy   = showWeakSignals and weakBuyOnly and allowBuy
normalBuy = showNormalSignals and normalBuyOnly and allowBuy
strongBuy = showStrongSignals and strongBuyRaw and allowBuy

weakSell   = showWeakSignals and weakSellOnly and allowSell
normalSell = showNormalSignals and normalSellOnly and allowSell
strongSell = showStrongSignals and strongSellRaw and allowSell

buyPrinted  = weakBuy or normalBuy or strongBuy
sellPrinted = weakSell or normalSell or strongSell

if buyPrinted
    lastPrintedSignal := 1
    lastSignalBar := bar_index

if sellPrinted
    lastPrintedSignal := -1
    lastSignalBar := bar_index

//==================================================
// EMA PLOTS
//==================================================
plot(showEMA20 ? ema20 : na, "EMA 20", color=color.new(color.green, 0), linewidth=2)
plot(showEMA50 ? ema50 : na, "EMA 50", color=color.new(color.orange, 0), linewidth=2)
plot(showEMA200 ? ema200 : na, "EMA 200", color=color.new(color.blue, 0), linewidth=2)

bgcolor(showBgBias ? (close > ema200 ? color.new(color.green, 92) : close < ema200 ? color.new(color.red, 92) : na) : na)

//==================================================
// LABEL TEXT
//==================================================
buyWeakText   = showSignalTextTag ? "BUY W" : "BUY"
buyNormalText = showSignalTextTag ? "BUY N" : "BUY"
buyStrongText = showSignalTextTag ? "BUY S" : "BUY"

sellWeakText   = showSignalTextTag ? "SELL W" : "SELL"
sellNormalText = showSignalTextTag ? "SELL N" : "SELL"
sellStrongText = showSignalTextTag ? "SELL S" : "SELL"

//==================================================
// LABEL POSITIONS
//==================================================
offsetValue = syminfo.mintick * labelOffsetTicks
buyY  = low  - offsetValue
sellY = high + offsetValue

//==================================================
// CANDLE-ATTACHED LABELS
//==================================================
if weakBuy
    label.new(bar_index, buyY, buyWeakText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.green, 15), textcolor=color.white, size=size.tiny)

if normalBuy
    label.new(bar_index, buyY, buyNormalText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

if strongBuy
    label.new(bar_index, buyY, buyStrongText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.normal)

if weakSell
    label.new(bar_index, sellY, sellWeakText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.red, 15), textcolor=color.white, size=size.tiny)

if normalSell
    label.new(bar_index, sellY, sellNormalText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

if strongSell
    label.new(bar_index, sellY, sellStrongText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.normal)

//==================================================
// PANEL POSITION
//==================================================
tablePos = panelPosition == "Top Left" ? position.top_left : panelPosition == "Bottom Right" ? position.bottom_right : panelPosition == "Bottom Left" ? position.bottom_left : position.top_right

//==================================================
// FIXED SCREEN PANEL
//==================================================
var table infoTable = table.new(tablePos, 2, 9, border_width=1)

if barstate.islast and showVolumePanel
    table.cell(infoTable, 0, 0, "Metric", text_color=color.white, bgcolor=color.black)
    table.cell(infoTable, 1, 0, "Value", text_color=color.white, bgcolor=color.black)

    table.cell(infoTable, 0, 1, "Volume", text_color=color.white)
    table.cell(infoTable, 1, 1, str.tostring(volume), text_color=color.white)

    table.cell(infoTable, 0, 2, "Volume MA", text_color=color.white)
    table.cell(infoTable, 1, 2, str.tostring(volMA), text_color=color.white)

    table.cell(infoTable, 0, 3, "Buy Volume", text_color=color.white)
    table.cell(infoTable, 1, 3, str.tostring(buyVol), text_color=color.white)

    table.cell(infoTable, 0, 4, "Sell Volume", text_color=color.white)
    table.cell(infoTable, 1, 4, str.tostring(sellVol), text_color=color.white)

    table.cell(infoTable, 0, 5, "Vol Ratio", text_color=color.white)
    table.cell(infoTable, 1, 5, showVolRatio and not na(volRatio) ? str.tostring(volRatio, "#.##") + "x" : "-", text_color=not na(volRatio) and volRatio >= volMultiplier ? color.lime : color.white)

    table.cell(infoTable, 0, 6, "Bias", text_color=color.white)
    table.cell(infoTable, 1, 6, close > ema200 ? "Bullish" : close < ema200 ? "Bearish" : "Neutral", text_color=close > ema200 ? color.lime : close < ema200 ? color.red : color.white)

    table.cell(infoTable, 0, 7, "Last Side", text_color=color.white)
    table.cell(infoTable, 1, 7, lastPrintedSignal == 1 ? "BUY" : lastPrintedSignal == -1 ? "SELL" : "NONE", text_color=lastPrintedSignal == 1 ? color.lime : lastPrintedSignal == -1 ? color.red : color.white)

    strengthText = strongBuy or strongSell ? "STRONG" : normalBuy or normalSell ? "NORMAL" : weakBuy or weakSell ? "WEAK" : "-"
    table.cell(infoTable, 0, 8, "This Bar", text_color=color.white)
    table.cell(infoTable, 1, 8, strengthText, text_color=strengthText == "STRONG" ? color.lime : strengthText == "NORMAL" ? color.yellow : strengthText == "WEAK" ? color.orange : color.white)

//==================================================
// ALERTS
//==================================================
alertcondition(weakBuy, "Weak Buy Alert", "Weak BUY signal")
alertcondition(normalBuy, "Normal Buy Alert", "Normal BUY signal")
alertcondition(strongBuy, "Strong Buy Alert", "Strong BUY signal")

alertcondition(weakSell, "Weak Sell Alert", "Weak SELL signal")
alertcondition(normalSell, "Normal Sell Alert", "Normal SELL signal")
alertcondition(strongSell, "Strong Sell Alert", "Strong SELL signal")
````
