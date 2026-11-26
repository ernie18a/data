# Advanced First Red + 12:45 Breakout Indicator

- url: https://www.tradingview.com/script/OHxdWMx9-Advanced-First-Red-12-45-Breakout-Indicator/
- type: indicator
- pine_id: PUB;449f4f0368a64b1085712532cd3e19c5
- version: 13.0

## Description

# Advanced First Red + 12:45 Breakout Indicator

## Overview

This TradingView indicator identifies breakout and breakdown opportunities using two intraday reference candles:

1. The first red candle of the trading session
2. The 12:45 PM candle, whether red or green

The indicator marks BUY signals when price crosses above the reference candle high and SELL signals when price crosses below the reference candle low.

## Recommended Timeframe

Use this indicator on a 5-minute chart.

## Core Logic

Before 12:45 PM, the indicator uses the first red candle of the session as the reference candle.

After the 12:45 PM candle forms, the indicator switches the reference levels to the 12:45 candle high and low.

## BUY Signal

A BUY signal is generated when price crosses above the active reference candle high.

## SELL Signal

A SELL signal is generated when price crosses below the active reference candle low.

## Important Feature

The indicator does not generate signals on every candle. It gives a fresh signal only when price crosses above or below the reference level.

## Input Settings

Trading Session
Defines the active market session. Default is 09:15 to 15:30.

Use First Red Candle
Enables or disables first red candle logic.

Use 12:45 Candle
Enables or disables 12:45 candle logic.

Use Candle Body High/Low Instead of Wick
If enabled, the indicator uses candle body high and body low instead of full wick high and low.

Use EMA Trend Filter
Filters BUY signals only above EMA and SELL signals only below EMA.

EMA Length
Defines the EMA period used for trend filtering.

Show Target / Stoploss
Displays entry, stoploss, and target levels after a signal.

Risk Reward
Defines target distance based on stoploss risk.

## Plotted Levels

Reference High
The active breakout level.

Reference Low
The active breakdown level.

EMA Filter
Trend filter line when enabled.

Entry
Signal candle close price.

Stoploss
For BUY, stoploss is reference low.
For SELL, stoploss is reference high.

Target
Calculated using selected risk-reward ratio.

## Dashboard

The dashboard displays:

Reference candle type
Reference high
Reference low
Current bias
Trend filter status

## Alerts

The indicator includes alert conditions for:

BUY Signal
SELL Signal

You can create alerts from TradingView using these conditions.

## Best Usage

Use BUY signals when price breaks above the reference high with strong momentum.

Use SELL signals when price breaks below the reference low with strong momentum.

Avoid trading signals during sideways or low-volume market conditions.

## Notes

This is an indicator, not an automated strategy.

It does not place trades automatically.

Signals should be combined with market context, volume, trend, and risk management.

## Source Code

````pine
//@version=6
indicator("First Red + 12:45 Range + Fib Buy + EMA + Order Blocks (Optimized)", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=400)

//────────────────────────────────────
// Inputs
//────────────────────────────────────
sessionInput  = input.session("0915-1530", "Trading Session")
bufferPoints  = input.float(1.0, "Buy/Sell Buffer Points", step=0.05)

showDayLevels      = input.bool(true, "Show Current / Previous Day High Low")
showFirstRedRange  = input.bool(true, "Show First Red Range")
show1245Range      = input.bool(true, "Show 12:45 Range")
showRedBarShade    = input.bool(true, "Shade First Red Range")
showTags           = input.bool(true, "Show Right Side Price Tags")
showDashboard      = input.bool(false, "Show Dashboard")

showBuyLabels      = input.bool(false, "Show Main Buy Signals")
showSellLabels     = input.bool(false, "Show Sell Signals")
showExitLabels     = input.bool(false, "Show Exit Signals")
showFib50BuyLabels = input.bool(false, "Show Fib 0.50 Buy Signals")
showFib68BuyLabels = input.bool(false, "Show Fib 0.618 Buy Signals")
showFib50SellLabels = input.bool(false, "Show Fib 0.50 Sell Signals")
showFib68SellLabels = input.bool(false, "Show Fib 0.618 Sell Signals")



showFib44 = input.bool(true, "Show Fib 0.44")
showFib50 = input.bool(true, "Show Fib 0.50")
showFib68 = input.bool(true, "Show Fib 0.618")

showEMA5      = input.bool(true, "Show EMA 5")
showEMA10     = input.bool(true, "Show EMA 10")
showEMA30     = input.bool(true, "Show EMA 30")
showEMA200    = input.bool(true, "Show EMA 200")
showEMAShade  = input.bool(true, "Show EMA Area Shade")

showTargets = input.bool(true, "Show Targets")
targetStep  = input.float(10.0, "Target Step Points")
targetCount = input.int(2, "Number of Targets", minval=1, maxval=10)

showOrderBlocks = input.bool(true, "Show Order Blocks")
obLookbackBars  = input.int(3, "OB Breakout Strength Bars", minval=1, maxval=10)
maxOBPerSide    = input.int(12, "Max OB Zones Per Side", minval=1, maxval=30)

//────────────────────────────────────
// Colors
//────────────────────────────────────
buyColor      = color.rgb(0, 200, 120)
sellColor     = color.rgb(255, 70, 85)
specialBuyC   = color.rgb(45, 140, 255)
specialSellC  = color.rgb(255, 165, 40)
exitColor     = color.rgb(180, 90, 255)
fib50BuyColor = color.rgb(0, 255, 255)
fib68BuyColor = color.rgb(255, 0, 255)
fib50SellColor = color.rgb(0, 180, 255)   // Cyan-blue for Sell
fib68SellColor = color.rgb(200, 0, 200)   // Purple for Sell


redRangeShade = input.color(color.new(color.red, 88), "First Red Range Shade")

fib44Color = input.color(color.rgb(255, 235, 59), "Fib 0.44 Color")
fib50Color = input.color(color.rgb(0, 255, 255), "Fib 0.50 Color")
fib68Color = input.color(color.rgb(255, 0, 255), "Fib 0.618 Color")
fibWidth   = input.int(1, "Fib Line Width", minval=1, maxval=4)

ema5Color   = input.color(color.rgb(0, 255, 120), "EMA 5 Color")
ema10Color  = input.color(color.rgb(255, 193, 7), "EMA 10 Color")
ema30Color  = input.color(color.rgb(0, 188, 212), "EMA 30 Color")
ema200Color = input.color(color.rgb(255, 255, 255), "EMA 200 Color")
emaWidth    = input.int(2, "EMA Line Width", minval=1, maxval=5)

greenShadeColor = input.color(color.new(color.rgb(0, 200, 120), 94), "Bullish EMA Area Shade")
redShadeColor   = input.color(color.new(color.rgb(255, 80, 80), 94), "Bearish EMA Area Shade")

obBullColor  = input.color(color.new(color.green, 85), "Bullish OB Fill")
obBearColor  = input.color(color.new(color.red, 85), "Bearish OB Fill")
obBullBorder = input.color(color.new(color.green, 20), "Bullish OB Border")
obBearBorder = input.color(color.new(color.red, 20), "Bearish OB Border")

//────────────────────────────────────
// Common state
//────────────────────────────────────
newDay    = ta.change(time("D")) != 0
inSession = not na(time(timeframe.period, sessionInput))

//────────────────────────────────────
// Helpers
//────────────────────────────────────
fibPrice(float h, float l, float r) =>
    na(h) or na(l) ? na : l + ((h - l) * r)

updateLine(line ln, int x1, float price, color clr, string style, int width) =>
    if na(price)
        ln
    else
        if na(ln)
            line.new(x1, price, time, price, xloc=xloc.bar_time, extend=extend.right, color=clr, width=width, style=style)
        else
            line.set_x1(ln, x1)
            line.set_y1(ln, price)
            line.set_x2(ln, time)
            line.set_y2(ln, price)
            line.set_color(ln, clr)
            line.set_width(ln, width)
            line.set_style(ln, style)
            ln

makeTag(label old, float price, string txt, color clr) =>
    label.delete(old)
    showTags and not na(price) ? label.new(bar_index + 2, price, txt + "  " + str.tostring(price, format.mintick), style=label.style_label_left, color=clr, textcolor=color.white, size=size.normal) : na

clearLine(line ln) =>
    if not na(ln)
        line.delete(ln)
    line(na)

clearBox(box bx) =>
    if not na(bx)
        box.delete(bx)
    box(na)

//────────────────────────────────────
// EMA
//────────────────────────────────────
ema5   = ta.ema(close, 5)
ema10  = ta.ema(close, 10)
ema30  = ta.ema(close, 30)
ema200 = ta.ema(close, 200)

pEma5  = plot(showEMA5 ? ema5 : na, "EMA 5", color=ema5Color, linewidth=emaWidth)
pEma10 = plot(showEMA10 ? ema10 : na, "EMA 10", color=ema10Color, linewidth=emaWidth)
pEma30 = plot(showEMA30 ? ema30 : na, "EMA 30", color=ema30Color, linewidth=emaWidth)
plot(showEMA200 ? ema200 : na, "EMA 200", color=ema200Color, linewidth=emaWidth)

bullEMA = ema5 > ema30 and ema10 > ema30
bearEMA = ema30 > ema5 and ema30 > ema10

fill(pEma5, pEma30, color=showEMAShade and bullEMA ? greenShadeColor : showEMAShade and bearEMA ? redShadeColor : na)
fill(pEma10, pEma30, color=showEMAShade and bullEMA ? color.new(color.rgb(0, 200, 120), 96) : showEMAShade and bearEMA ? color.new(color.rgb(255, 80, 80), 96) : na)

//────────────────────────────────────
// Day High / Low
//────────────────────────────────────
var float cdh = na
var float cdl = na
var float pdh = na
var float pdl = na

if newDay
    pdh := cdh
    pdl := cdl
    cdh := high
    cdl := low
else
    cdh := na(cdh) ? high : math.max(cdh, high)
    cdl := na(cdl) ? low : math.min(cdl, low)

var line cdhLine = na
var line cdlLine = na
var line pdhLine = na
var line pdlLine = na

if showDayLevels
    cdhLine := updateLine(cdhLine, time, cdh, color.rgb(0, 220, 130), line.style_dotted, 1)
    cdlLine := updateLine(cdlLine, time, cdl, color.rgb(255, 90, 90), line.style_dotted, 1)
    if not na(pdh)
        pdhLine := updateLine(pdhLine, time, pdh, color.new(color.rgb(0, 220, 130), 45), line.style_dotted, 1)
    if not na(pdl)
        pdlLine := updateLine(pdlLine, time, pdl, color.new(color.rgb(255, 90, 90), 45), line.style_dotted, 1)

//────────────────────────────────────
// First Red 5m
//────────────────────────────────────
getFirstRedVals() =>
    var float frH = na
    var float frL = na
    var int frT = na
    var bool found = false
    isNewDayLocal = ta.change(time("D")) != 0
    inSess5 = not na(time(timeframe.period, sessionInput))
    isOpenCandle = hour == 9 and minute == 15

    if isNewDayLocal
        frH := na
        frL := na
        frT := na
        found := false

    if inSess5 and not isOpenCandle and not found and close < open
        frH := high
        frL := low
        frT := time
        found := true

    [frH, frL, frT]

[firstRedHigh, firstRedLow, firstRedTime] = request.security(syminfo.tickerid, "5", getFirstRedVals(), barmerge.gaps_off, barmerge.lookahead_off)

firstRedBuyTrigger  = firstRedHigh + bufferPoints
firstRedSellTrigger = firstRedLow - bufferPoints

frFib44Price = fibPrice(firstRedHigh, firstRedLow, 0.44)
frFib50Price = fibPrice(firstRedHigh, firstRedLow, 0.50)
frFib68Price = fibPrice(firstRedHigh, firstRedLow, 0.618)

//────────────────────────────────────
// 12:45 to 1:15 Range on 5m
//────────────────────────────────────
get1245Vals() =>
    var float rH = na
    var float rL = na
    var bool locked = false
    isNewDayLocal = ta.change(time("D")) != 0

    if isNewDayLocal
        rH := na
        rL := na
        locked := false

    inRange = (hour == 12 and minute >= 45) or (hour == 13 and minute < 15)

    if inRange and not locked
        rH := na(rH) ? high : math.max(rH, high)
        rL := na(rL) ? low : math.min(rL, low)

    if hour == 13 and minute == 15
        locked := true

    [rH, rL]

[specialHigh, specialLow] = request.security(syminfo.tickerid, "5", get1245Vals(), barmerge.gaps_off, barmerge.lookahead_off)

specialBuyTrigger  = specialHigh + bufferPoints
specialSellTrigger = specialLow - bufferPoints

spFib44Price = fibPrice(specialHigh, specialLow, 0.44)
spFib50Price = fibPrice(specialHigh, specialLow, 0.50)
spFib68Price = fibPrice(specialHigh, specialLow, 0.618)


//────────────────────────────────────
// Range Objects
//────────────────────────────────────
var line frHighLine = na
var line frLowLine  = na
var line spHighLine = na
var line spLowLine  = na
var line frFib44    = na
var line frFib50    = na
var line frFib68    = na
var line spFib44    = na
var line spFib50    = na
var line spFib68    = na
var box  frBox      = na

if newDay
    frHighLine := clearLine(frHighLine)
    frLowLine  := clearLine(frLowLine)
    spHighLine := clearLine(spHighLine)
    spLowLine  := clearLine(spLowLine)
    frFib44    := clearLine(frFib44)
    frFib50    := clearLine(frFib50)
    frFib68    := clearLine(frFib68)
    spFib44    := clearLine(spFib44)
    spFib50    := clearLine(spFib50)
    spFib68    := clearLine(spFib68)
    frBox      := clearBox(frBox)

if showFirstRedRange and not na(firstRedHigh) and not na(firstRedLow) and not na(firstRedTime)
    frHighLine := updateLine(frHighLine, firstRedTime, firstRedHigh, buyColor, line.style_solid, 2)
    frLowLine  := updateLine(frLowLine, firstRedTime, firstRedLow, sellColor, line.style_solid, 2)

    if showRedBarShade
        if na(frBox)
            frBox := box.new(firstRedTime, firstRedHigh, time, firstRedLow, xloc=xloc.bar_time, bgcolor=redRangeShade, border_color=color.new(color.red, 50))
        else
            box.set_left(frBox, firstRedTime)
            box.set_right(frBox, time)
            box.set_top(frBox, firstRedHigh)
            box.set_bottom(frBox, firstRedLow)

    if showFib44
        frFib44 := updateLine(frFib44, firstRedTime, frFib44Price, fib44Color, line.style_solid, fibWidth)
    if showFib50
        frFib50 := updateLine(frFib50, firstRedTime, frFib50Price, fib50Color, line.style_solid, fibWidth)
    if showFib68
        frFib68 := updateLine(frFib68, firstRedTime, frFib68Price, fib68Color, line.style_solid, fibWidth)

if show1245Range and not na(specialHigh) and not na(specialLow)
    spStartTime = timestamp(year, month, dayofmonth, 12, 45)
    spHighLine := updateLine(spHighLine, spStartTime, specialHigh, specialBuyC, line.style_solid, 2)
    spLowLine  := updateLine(spLowLine, spStartTime, specialLow, specialSellC, line.style_solid, 2)

    if showFib44
        spFib44 := updateLine(spFib44, spStartTime, spFib44Price, fib44Color, line.style_solid, fibWidth)
    if showFib50
        spFib50 := updateLine(spFib50, spStartTime, spFib50Price, fib50Color, line.style_solid, fibWidth)
    if showFib68
        spFib68 := updateLine(spFib68, spStartTime, spFib68Price, fib68Color, line.style_solid, fibWidth)

//────────────────────────────────────
// Tags
//────────────────────────────────────
var label frHighTag = na
var label frLowTag  = na
var label spHighTag = na
var label spLowTag  = na

if showTags and barstate.islast
    if showFirstRedRange
        frHighTag := makeTag(frHighTag, firstRedHigh, "FR High", buyColor)
        frLowTag  := makeTag(frLowTag, firstRedLow, "FR Low", sellColor)

    if show1245Range
        spHighTag := makeTag(spHighTag, specialHigh, "12:45 High", specialBuyC)
        spLowTag  := makeTag(spLowTag, specialLow, "12:45 Low", specialSellC)

//────────────────────────────────────
// Signals
//────────────────────────────────────

signalCooldownBars = input.int(10, "Signal Cooldown Bars", minval = 1)

var int lastBuySignalBar  = na
var int lastSellSignalBar = na

var bool frFib50BuyDone = false
var bool frFib68BuyDone = false
var bool spFib50BuyDone = false
var bool spFib68BuyDone = false

if newDay
    frFib50BuyDone := false
    frFib68BuyDone := false
    spFib50BuyDone := false
    spFib68BuyDone := false

canBuy =
     na(lastBuySignalBar) or
     (bar_index - lastBuySignalBar >= signalCooldownBars)

canSell =
     na(lastSellSignalBar) or
     (bar_index - lastSellSignalBar >= signalCooldownBars)

//────────────────────────────────────
// Main Buy/Sell Signals
//────────────────────────────────────

buyFirstRed =
     not na(firstRedBuyTrigger) and
     ta.crossover(close, firstRedBuyTrigger) and
     bullEMA and
     canBuy

sellFirstRed =
     not na(firstRedSellTrigger) and
     ta.crossunder(close, firstRedSellTrigger) and
     bearEMA and
     canSell

buySpecial =
     not na(specialBuyTrigger) and
     ta.crossover(close, specialBuyTrigger) and
     bullEMA and
     canBuy

sellSpecial =
     not na(specialSellTrigger) and
     ta.crossunder(close, specialSellTrigger) and
     bearEMA and
     canSell

//────────────────────────────────────
// Fib Buy Signals
//────────────────────────────────────

fib50BuyFirstRed =
     showFib50BuyLabels and
     not na(frFib50Price) and
     ta.crossover(close, frFib50Price) and
     not frFib50BuyDone

fib68BuyFirstRed =
     showFib68BuyLabels and
     not na(frFib68Price) and
     ta.crossover(close, frFib68Price) and
     not frFib68BuyDone

fib50BuySpecial =
     showFib50BuyLabels and
     not na(spFib50Price) and
     ta.crossover(close, spFib50Price) and
     not spFib50BuyDone

fib68BuySpecial =
     showFib68BuyLabels and
     not na(spFib68Price) and
     ta.crossover(close, spFib68Price) and
     not spFib68BuyDone

fib50SellFirstRed =
     showFib50SellLabels and
     not na(frFib50Price) and
     ta.crossunder(close, frFib50Price)

fib68SellFirstRed =
     showFib68SellLabels and
     not na(frFib68Price) and
     ta.crossunder(close, frFib68Price)

fib50SellSpecial =
     showFib50SellLabels and
     not na(spFib50Price) and
     ta.crossunder(close, spFib50Price)

fib68SellSpecial =
     showFib68SellLabels and
     not na(spFib68Price) and
     ta.crossunder(close, spFib68Price)
 

//────────────────────────────────────
// Cooldown Tracking
//────────────────────────────────────

if buyFirstRed or buySpecial
    lastBuySignalBar := bar_index

if sellFirstRed or sellSpecial
    lastSellSignalBar := bar_index

//────────────────────────────────────
// One-time Fib Triggers
//────────────────────────────────────

if fib50BuyFirstRed
    frFib50BuyDone := true

if fib68BuyFirstRed
    frFib68BuyDone := true

if fib50BuySpecial
    spFib50BuyDone := true

if fib68BuySpecial
    spFib68BuyDone := true




//────────────────────────────────────
// Combined Signals
//────────────────────────────────────

buySignal =
     buyFirstRed or
     buySpecial or
     fib50BuyFirstRed or
     fib68BuyFirstRed or
     fib50BuySpecial or
     fib68BuySpecial

sellSignal =
     sellFirstRed or
     sellSpecial or
     fib50SellFirstRed or
     fib68SellFirstRed or
     fib50SellSpecial or
     fib68SellSpecial



//────────────────────────────────────
// Exit Logic
//────────────────────────────────────
var float frBuyExitLevel  = na
var float frSellExitLevel = na
var float spBuyExitLevel  = na
var float spSellExitLevel = na
var bool frBuyActive  = false
var bool frSellActive = false
var bool spBuyActive  = false
var bool spSellActive = false

if newDay
    frBuyActive := false
    frSellActive := false
    spBuyActive := false
    spSellActive := false

if buyFirstRed or fib50BuyFirstRed or fib68BuyFirstRed
    frBuyExitLevel := low
    frBuyActive := true
    frSellActive := false

if sellFirstRed
    frSellExitLevel := high
    frSellActive := true
    frBuyActive := false

if buySpecial or fib50BuySpecial or fib68BuySpecial
    spBuyExitLevel := low
    spBuyActive := true
    spSellActive := false

if sellSpecial
    spSellExitLevel := high
    spSellActive := true
    spBuyActive := false

exitFrBuy  = frBuyActive and close < frBuyExitLevel
exitFrSell = frSellActive and close > frSellExitLevel
exitSpBuy  = spBuyActive and close < spBuyExitLevel
exitSpSell = spSellActive and close > spSellExitLevel

if exitFrBuy
    frBuyActive := false
if exitFrSell
    frSellActive := false
if exitSpBuy
    spBuyActive := false
if exitSpSell
    spSellActive := false

//────────────────────────────────────
// Labels
//────────────────────────────────────
if showBuyLabels and buyFirstRed
    label.new(bar_index, low, "BUY\nFR @ " + str.tostring(close, format.mintick), style=label.style_label_up, color=buyColor, textcolor=color.white)

if showSellLabels and sellFirstRed
    label.new(bar_index, high, "SELL\nFR @ " + str.tostring(close, format.mintick), style=label.style_label_down, color=sellColor, textcolor=color.white)

if showBuyLabels and buySpecial
    label.new(bar_index, low, "BUY\n12:45 @ " + str.tostring(close, format.mintick), style=label.style_label_up, color=specialBuyC, textcolor=color.white)

if showSellLabels and sellSpecial
    label.new(bar_index, high, "SELL\n12:45 @ " + str.tostring(close, format.mintick), style=label.style_label_down, color=specialSellC, textcolor=color.white)

if fib50BuyFirstRed
    label.new(bar_index, low, "FIB 0.50 BUY\nFR @ " + str.tostring(close, format.mintick), style=label.style_label_up, color=fib50BuyColor, textcolor=color.black)

if fib68BuyFirstRed
    label.new(bar_index, low, "FIB 0.618 BUY\nFR @ " + str.tostring(close, format.mintick), style=label.style_label_up, color=fib68BuyColor, textcolor=color.white)

if fib50BuySpecial
    label.new(bar_index, low, "FIB 0.50 BUY\n12:45 @ " + str.tostring(close, format.mintick), style=label.style_label_up, color=fib50BuyColor, textcolor=color.black)

if fib68BuySpecial
    label.new(bar_index, low, "FIB 0.618 BUY\n12:45 @ " + str.tostring(close, format.mintick), style=label.style_label_up, color=fib68BuyColor, textcolor=color.white)

if fib50SellFirstRed
    label.new(bar_index, high, "FIB 0.50 SELL\nFR @ " + str.tostring(close, format.mintick), style=label.style_label_down, color=fib50SellColor, textcolor=color.white)

if fib68SellFirstRed
    label.new(bar_index, high, "FIB 0.618 SELL\nFR @ " + str.tostring(close, format.mintick), style=label.style_label_down, color=fib68SellColor, textcolor=color.white)

if fib50SellSpecial
    label.new(bar_index, high, "FIB 0.50 SELL\n12:45 @ " + str.tostring(close, format.mintick), style=label.style_label_down, color=fib50SellColor, textcolor=color.white)

if fib68SellSpecial
    label.new(bar_index, high, "FIB 0.618 SELL\n12:45 @ " + str.tostring(close, format.mintick), style=label.style_label_down, color=fib68SellColor, textcolor=color.white)


if showExitLabels and exitFrBuy
    label.new(bar_index, high, "EXIT FR BUY\n@ " + str.tostring(close, format.mintick), style=label.style_label_down, color=exitColor, textcolor=color.white)

if showExitLabels and exitFrSell
    label.new(bar_index, low, "EXIT FR SELL\n@ " + str.tostring(close, format.mintick), style=label.style_label_up, color=exitColor, textcolor=color.white)

if showExitLabels and exitSpBuy
    label.new(bar_index, high, "EXIT 12:45 BUY\n@ " + str.tostring(close, format.mintick), style=label.style_label_down, color=exitColor, textcolor=color.white)

if showExitLabels and exitSpSell
    label.new(bar_index, low, "EXIT 12:45 SELL\n@ " + str.tostring(close, format.mintick), style=label.style_label_up, color=exitColor, textcolor=color.white)

if fib50SellFirstRed
    label.new(bar_index, high, "FIB 0.50 SELL\nFR @ " + str.tostring(close, format.mintick), 
              style=label.style_label_down, color=fib50SellColor, textcolor=color.white)

if fib68SellFirstRed
    label.new(bar_index, high, "FIB 0.618 SELL\nFR @ " + str.tostring(close, format.mintick), 
              style=label.style_label_down, color=fib68SellColor, textcolor=color.white)


//────────────────────────────────────
// Targets
//────────────────────────────────────
var line[]  targetLines  = array.new_line()
var label[] targetLabels = array.new_label()

clearTargets() =>
    if array.size(targetLines) > 0
        for i = 0 to array.size(targetLines) - 1
            line.delete(array.get(targetLines, i))
    if array.size(targetLabels) > 0
        for i = 0 to array.size(targetLabels) - 1
            label.delete(array.get(targetLabels, i))
    array.clear(targetLines)
    array.clear(targetLabels)

drawTargets(float entry) =>
    clearTargets()
    if showTargets
        for i = 1 to targetCount
            buyTarget  = entry + targetStep * i
            sellTarget = entry - targetStep * i

            bl = line.new(bar_index, buyTarget, bar_index + 1, buyTarget, extend=extend.right, color=color.new(color.green, 25), width=1, style=line.style_dashed)
            sl = line.new(bar_index, sellTarget, bar_index + 1, sellTarget, extend=extend.right, color=color.new(color.red, 25), width=1, style=line.style_dashed)
            bt = label.new(bar_index + 4, buyTarget, "BUY T" + str.tostring(i) + "  " + str.tostring(buyTarget, format.mintick), style=label.style_label_left, color=color.new(color.green, 10), textcolor=color.white)
            st = label.new(bar_index + 4, sellTarget, "SELL T" + str.tostring(i) + "  " + str.tostring(sellTarget, format.mintick), style=label.style_label_left, color=color.new(color.red, 10), textcolor=color.white)

            array.push(targetLines, bl)
            array.push(targetLines, sl)
            array.push(targetLabels, bt)
            array.push(targetLabels, st)

if buySignal or sellSignal
    drawTargets(close)

//────────────────────────────────────
// Order Blocks - last 2 days, unbroken only
//────────────────────────────────────
var int dayCounter = 0
if newDay
    dayCounter += 1

var box[] bullObBoxes = array.new_box()
var float[] bullTopArr = array.new_float()
var float[] bullBotArr = array.new_float()
var int[] bullLeftArr = array.new_int()
var int[] bullDayArr = array.new_int()

var box[] bearObBoxes = array.new_box()
var float[] bearTopArr = array.new_float()
var float[] bearBotArr = array.new_float()
var int[] bearLeftArr = array.new_int()
var int[] bearDayArr = array.new_int()

trimOBs(box[] bxArr, float[] topArr, float[] botArr, int[] leftArr, int[] dayArr, int maxCount) =>
    while array.size(topArr) > maxCount
        oldBox = array.shift(bxArr)
        box.delete(oldBox)
        array.shift(topArr)
        array.shift(botArr)
        array.shift(leftArr)
        array.shift(dayArr)

addBullOB(float top, float bot, int leftTime, int d) =>
    if showOrderBlocks
        bx = box.new(leftTime, top, time, bot, xloc=xloc.bar_time, extend=extend.right, bgcolor=obBullColor, border_color=obBullBorder)
        array.push(bullObBoxes, bx)
        array.push(bullTopArr, top)
        array.push(bullBotArr, bot)
        array.push(bullLeftArr, leftTime)
        array.push(bullDayArr, d)
        trimOBs(bullObBoxes, bullTopArr, bullBotArr, bullLeftArr, bullDayArr, maxOBPerSide)

addBearOB(float top, float bot, int leftTime, int d) =>
    if showOrderBlocks
        bx = box.new(leftTime, top, time, bot, xloc=xloc.bar_time, extend=extend.right, bgcolor=obBearColor, border_color=obBearBorder)
        array.push(bearObBoxes, bx)
        array.push(bearTopArr, top)
        array.push(bearBotArr, bot)
        array.push(bearLeftArr, leftTime)
        array.push(bearDayArr, d)
        trimOBs(bearObBoxes, bearTopArr, bearBotArr, bearLeftArr, bearDayArr, maxOBPerSide)

bullImpulse = close > high[1] and close > ta.highest(high, obLookbackBars)[1]
bearImpulse = close < low[1] and close < ta.lowest(low, obLookbackBars)[1]

bullObSignal = close[1] < open[1] and bullImpulse and bullEMA and inSession
bearObSignal = close[1] > open[1] and bearImpulse and bearEMA and inSession

if bullObSignal
    addBullOB(open[1], low[1], time[1], dayCounter)

if bearObSignal
    addBearOB(high[1], open[1], time[1], dayCounter)

if array.size(bullTopArr) > 0
    for i = array.size(bullTopArr) - 1 to 0
        obTop = array.get(bullTopArr, i)
        obBot = array.get(bullBotArr, i)
        obDay = array.get(bullDayArr, i)
        obBox = array.get(bullObBoxes, i)

        isBroken = low < obBot
        isOld = dayCounter - obDay > 2

        if isBroken or isOld or not showOrderBlocks
            box.delete(obBox)
            array.remove(bullObBoxes, i)
            array.remove(bullTopArr, i)
            array.remove(bullBotArr, i)
            array.remove(bullLeftArr, i)
            array.remove(bullDayArr, i)
        else
            box.set_right(obBox, time)
            box.set_top(obBox, obTop)
            box.set_bottom(obBox, obBot)
            box.set_bgcolor(obBox, obBullColor)
            box.set_border_color(obBox, obBullBorder)

if array.size(bearTopArr) > 0
    for i = array.size(bearTopArr) - 1 to 0
        obTop = array.get(bearTopArr, i)
        obBot = array.get(bearBotArr, i)
        obDay = array.get(bearDayArr, i)
        obBox = array.get(bearObBoxes, i)

        isBroken = high > obTop
        isOld = dayCounter - obDay > 2

        if isBroken or isOld or not showOrderBlocks
            box.delete(obBox)
            array.remove(bearObBoxes, i)
            array.remove(bearTopArr, i)
            array.remove(bearBotArr, i)
            array.remove(bearLeftArr, i)
            array.remove(bearDayArr, i)
        else
            box.set_right(obBox, time)
            box.set_top(obBox, obTop)
            box.set_bottom(obBox, obBot)
            box.set_bgcolor(obBox, obBearColor)
            box.set_border_color(obBox, obBearBorder)

//────────────────────────────────────
// Optional Dashboard
//────────────────────────────────────
var table dash = na
if showDashboard
    if na(dash)
        dash := table.new(position.top_right, 2, 8, border_width=1)

    table.cell(dash, 0, 0, "Metric", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(dash, 0, 1, "FR High")
    table.cell(dash, 1, 1, na(firstRedHigh) ? "na" : str.tostring(firstRedHigh, format.mintick))

    table.cell(dash, 0, 2, "FR Low")
    table.cell(dash, 1, 2, na(firstRedLow) ? "na" : str.tostring(firstRedLow, format.mintick))

    table.cell(dash, 0, 3, "12:45 High")
    table.cell(dash, 1, 3, na(specialHigh) ? "na" : str.tostring(specialHigh, format.mintick))

    table.cell(dash, 0, 4, "12:45 Low")
    table.cell(dash, 1, 4, na(specialLow) ? "na" : str.tostring(specialLow, format.mintick))

    table.cell(dash, 0, 5, "EMA Bias")
    table.cell(dash, 1, 5, bullEMA ? "Bullish" : bearEMA ? "Bearish" : "Neutral")

    table.cell(dash, 0, 6, "Buy Signal")
    table.cell(dash, 1, 6, buySignal ? "Yes" : "No")

    table.cell(dash, 0, 7, "Sell Signal")
    table.cell(dash, 1, 7, sellSignal ? "Yes" : "No")

//────────────────────────────────────
// Alerts
//────────────────────────────────────
alertcondition(buyFirstRed, "BUY First Red 5m", "BUY First Red 5m at {{close}}")
alertcondition(sellFirstRed, "SELL First Red 5m", "SELL First Red 5m at {{close}}")
alertcondition(buySpecial, "BUY 12:45 Range", "BUY 12:45 Range at {{close}}")
alertcondition(sellSpecial, "SELL 12:45 Range", "SELL 12:45 Range at {{close}}")
alertcondition(fib50BuyFirstRed, "FIB 0.50 BUY First Red", "Price closed above First Red Fib 0.50 at {{close}}")
alertcondition(fib68BuyFirstRed, "FIB 0.618 BUY First Red", "Price closed above First Red Fib 0.618 at {{close}}")
alertcondition(fib50BuySpecial, "FIB 0.50 BUY 12:45", "Price closed above 12:45 Fib 0.50 at {{close}}")
alertcondition(fib68BuySpecial, "FIB 0.618 BUY 12:45", "Price closed above 12:45 Fib 0.618 at {{close}}")
alertcondition(fib50SellFirstRed, "FIB 0.50 SELL First Red", "Price broke below First Red Fib 0.50 at {{close}}")
alertcondition(fib68SellFirstRed, "FIB 0.618 SELL First Red", "Price broke below First Red Fib 0.618 at {{close}}")
alertcondition(fib50SellSpecial, "FIB 0.50 SELL 12:45", "Price broke below 12:45 Fib 0.50 at {{close}}")
alertcondition(fib68SellSpecial, "FIB 0.618 SELL 12:45", "Price broke below 12:45 Fib 0.618 at {{close}}")
alertcondition(exitFrBuy, "EXIT FR BUY", "EXIT First Red BUY at {{close}}")
alertcondition(exitFrSell, "EXIT FR SELL", "EXIT First Red SELL at {{close}}")
alertcondition(exitSpBuy, "EXIT 12:45 BUY", "EXIT 12:45 BUY at {{close}}")
alertcondition(exitSpSell, "EXIT 12:45 SELL", "EXIT 12:45 SELL at {{close}}")
````
