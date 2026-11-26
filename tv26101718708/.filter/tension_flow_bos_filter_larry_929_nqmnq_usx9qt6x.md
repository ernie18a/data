# Tension Flow + BOS Filter [Larry 9:29] - NQ/MNQ

- url: https://www.tradingview.com/script/Usx9QT6X-Tension-Flow-BOS-Filter-Larry-9-29-NQ-MNQ/
- type: indicator
- pine_id: PUB;67aa42ece0714cb082156bb453dbd5ce
- version: 1.0

## Description

**Larry 9:29 Rubber Band — Tension Flow + BOS Filter [NQ/MNQ]**

Tension Flow trend + Break of Structure confirmation, locked to the first 2 hours of the US session on NQ/MNQ 1-min chart.

Fair Price captured at 9:29 AM ET. Signals only fire when price is stretched AND Tension Flow + BOS agree — non-repainting, confirmed on closed bars only.

Bright GREEN BUY / RED SELL labels. TradersPost webhook alerts included for automated execution. Pair with a NinjaTrader 8 ATM strategy for near full automation — signal fires, trade enters, ATM manages the rest.

 will Live test on a 150K prop firm funded account. m,onte carlo simulation loks promising 10000 simulations

**Open source — collaboration welcome. Message me to forward test together.** 🎯

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga — modified by Larry (BOS + 9:29 Session Filter added)
//@version=6

indicator('Tension Flow + BOS Filter [Larry 9:29] - NQ/MNQ', overlay = true, max_boxes_count = 500)

// ═════════════════════════════════════════════
// TENSION FLOW SETTINGS
// ═════════════════════════════════════════════
hmaLen     = input.int(50,   'HMA Length',              minval = 1,   group = 'Tension Flow Settings')
zLen       = input.int(50,   'Z-Score Length',           minval = 1,   group = 'Tension Flow Settings')
offsetMult = input.float(0.5,'Ribbon Width',             step = 0.1,   group = 'Tension Flow Settings')
signalGap  = input.int(30,   'Signal Cooldown (Bars)',   minval = 1,   group = 'Tension Flow Settings')
atrMultSL  = input.float(2,  'Stop Loss ATR Multiplier', step = 0.1,   group = 'Tension Flow Settings')
rrRatio    = input.float(1.0,'Risk:Reward Ratio',        step = 0.1,   group = 'Tension Flow Settings')
maxTrades  = input.int(100,  'Backtest Trade Window',    minval = 1,   group = 'Tension Flow Settings')
showLabels = input.bool(true, 'Show Trend Start Labels',               group = 'Tension Flow Settings')
showTable  = input.bool(true, 'Show Energy Dashboard',                 group = 'Tension Flow Settings')
showRRTable= input.bool(true, 'Show RR Performance Dashboard',         group = 'Tension Flow Settings')
colorBull  = input.color(#00ffbb, 'Bullish Color',                     group = 'Tension Flow Settings')
colorBear  = input.color(#ff0055, 'Bearish Color',                     group = 'Tension Flow Settings')

// ═════════════════════════════════════════════
// BOS FILTER SETTINGS
// ═════════════════════════════════════════════
useBOSFilter    = input.bool(true,  'Require BOS Confirmation',         group = 'BOS Filter', tooltip = 'Signal only fires when Tension Flow direction matches a Break of Structure in the same direction')
structureLen    = input.int(5,      'BOS Structure Lookback (bars)',     group = 'BOS Filter', minval = 2, tooltip = 'Number of bars to look back for prior swing high/low')
requireStretch  = input.bool(true,  'Require 9:29 Band Stretch for BOS',group = 'BOS Filter', tooltip = 'BOS must occur from a stretched zone beyond the 9:29 fair price bands')

// ═════════════════════════════════════════════
// 9:29 FAIR PRICE + SESSION SETTINGS
// ═════════════════════════════════════════════
useSessionFilter = input.bool(true,  'Limit to 9:29–11:00 AM Session',  group = '9:29 Session', tooltip = 'Only take signals during the 9:29 to 11:00 AM ET trading window')
stretchPoints    = input.float(25.0, 'Stretch Band (pts)',               group = '9:29 Session', minval = 1.0, step = 5.0, tooltip = 'Distance from 9:29 fair price before BOS stretch filter activates')
startHour        = input.int(9,      'Start Hour NY',                    group = '9:29 Session', minval = 0, maxval = 23)
startMinute      = input.int(29,     'Start Minute NY',                  group = '9:29 Session', minval = 0, maxval = 59)
endHour          = input.int(11,     'End Hour NY',                      group = '9:29 Session', minval = 0, maxval = 23)
endMinute        = input.int(0,      'End Minute NY',                    group = '9:29 Session', minval = 0, maxval = 59)

// ═════════════════════════════════════════════
// NY TIME
// ═════════════════════════════════════════════
etHour   = hour(time,   'America/New_York')
etMinute = minute(time, 'America/New_York')
todayKey = year(time, 'America/New_York') * 10000 + month(time, 'America/New_York') * 100 + dayofmonth(time, 'America/New_York')

// ═════════════════════════════════════════════
// 9:29 FAIR PRICE CAPTURE
// ═════════════════════════════════════════════
targetTime = timestamp('America/New_York', year(time, 'America/New_York'), month(time, 'America/New_York'), dayofmonth(time, 'America/New_York'), 9, 29)
is0929     = time <= targetTime and time_close > targetTime

bodyHigh = math.max(open, close)
bodyLow  = math.min(open, close)

var float fairPrice   = na
var float fpHigh      = na
var float fpLow       = na
var int   capturedDay = 0
var bool  labelDrawn  = false

if is0929 and todayKey != capturedDay
    fairPrice   := (bodyHigh + bodyLow) / 2.0
    fpHigh      := high
    fpLow       := low
    capturedDay := todayKey
    labelDrawn  := false

todayCaptured = capturedDay == todayKey

// Session window
afterTarget = todayCaptured and (etHour > 9 or (etHour == 9 and etMinute >= 29))
afterStart  = etHour > startHour  or (etHour == startHour  and etMinute >= startMinute)
beforeEnd   = etHour < endHour    or (etHour == endHour    and etMinute <= endMinute)
inWindow    = afterTarget and afterStart and beforeEnd

// Stretch bands
upperBand = todayCaptured ? fairPrice + stretchPoints : na
lowerBand = todayCaptured ? fairPrice - stretchPoints : na
deviation = todayCaptured ? close - fairPrice : 0.0
stretched = todayCaptured and math.abs(deviation) >= stretchPoints

// ═════════════════════════════════════════════
// TENSION FLOW CALCULATIONS
// ═════════════════════════════════════════════
hmaValue      = ta.hma(close, hmaLen)
hmaSlopeUp    = hmaValue > hmaValue[1]
priceDist     = close - hmaValue
stdDev        = ta.stdev(priceDist, zLen)
zScore        = stdDev != 0 ? priceDist / stdDev : 0
absZ          = math.abs(zScore)
dynamicTransp = math.min(90, math.max(10, absZ * 25))

upperRibbon = hmaValue + ta.atr(14) * offsetMult
lowerRibbon = hmaValue - ta.atr(14) * offsetMult

// ═════════════════════════════════════════════
// TENSION FLOW SIGNALS (raw)
// ═════════════════════════════════════════════
var int lastSignalBar = -100
canTrigger = (bar_index - lastSignalBar) >= signalGap

crossUp = ta.crossover(close,  hmaValue)
crossDn = ta.crossunder(close, hmaValue)

confirmedBar = barstate.isconfirmed
trendChange  = hmaSlopeUp != hmaSlopeUp[1]

rawBullFlow = hmaSlopeUp      and crossUp and canTrigger and confirmedBar and not trendChange and not trendChange[1]
rawBearFlow = not hmaSlopeUp  and crossDn and canTrigger and confirmedBar and not trendChange and not trendChange[1]

// ═════════════════════════════════════════════
// BOS LOGIC
// ═════════════════════════════════════════════
priorHigh = ta.highest(high[1], structureLen)
priorLow  = ta.lowest(low[1],   structureLen)

bullBOS = close > priorHigh and close > open
bearBOS = close < priorLow  and close < open

// Stretch requirement for BOS
bullBOSStretch = requireStretch ? (deviation < 0 and stretched) : true
bearBOSStretch = requireStretch ? (deviation > 0 and stretched) : true

// BOS must be in session if session filter on
bosInSession = useSessionFilter ? inWindow : true

bosLong  = useBOSFilter and bullBOS and bullBOSStretch and bosInSession and confirmedBar
bosShort = useBOSFilter and bearBOS and bearBOSStretch and bosInSession and confirmedBar

// ═════════════════════════════════════════════
// COMBINED SIGNAL — Tension Flow + BOS agree
// ═════════════════════════════════════════════
// Session gate
sessionGate = useSessionFilter ? inWindow : true

bullSignal = rawBullFlow and (not useBOSFilter or bosLong)  and sessionGate
bearSignal = rawBearFlow and (not useBOSFilter or bosShort) and sessionGate

if bullSignal or bearSignal
    lastSignalBar := bar_index

// ═════════════════════════════════════════════
// STANDALONE BOS SIGNALS (visual only)
// ═════════════════════════════════════════════
standaloneBOSLong  = bosLong  and not bullSignal
standaloneBOSShort = bosShort and not bearSignal

// ═════════════════════════════════════════════
// HISTORICAL BOX LOGIC
// ═════════════════════════════════════════════
var tradeHistory  = array.new_bool()
var activeSLBoxes = array.new_box()
var activeTPBoxes = array.new_box()
var entryPrices   = array.new_float()
var slPrices      = array.new_float()
var tpPrices      = array.new_float()
var directions    = array.new_int()

float atr = ta.atr(200)

if confirmedBar and (bullSignal or bearSignal)
    float entry = close
    int   dir   = bullSignal ? 1 : -1
    float sl    = dir == 1 ? entry - (atr * atrMultSL) : entry + (atr * atrMultSL)
    float risk  = math.abs(entry - sl)
    float tp    = dir == 1 ? entry + (risk * rrRatio) : entry - (risk * rrRatio)

    box newSL = box.new(
         left         = bar_index,
         top          = dir == 1 ? entry : sl,
         right        = bar_index,
         bottom       = dir == 1 ? sl : entry,
         bgcolor      = color.new(colorBear, 85),
         border_color = color.new(colorBear, 40))

    box newTP = box.new(
         left         = bar_index,
         top          = dir == 1 ? tp : entry,
         right        = bar_index,
         bottom       = dir == 1 ? entry : tp,
         bgcolor      = color.new(colorBull, 85),
         border_color = color.new(colorBull, 40),
         text         = 'RR: ' + str.tostring(rrRatio),
         text_color   = color.white,
         text_size    = size.normal)

    array.push(activeSLBoxes, newSL)
    array.push(activeTPBoxes, newTP)
    array.push(entryPrices, entry)
    array.push(slPrices, sl)
    array.push(tpPrices, tp)
    array.push(directions, dir)

// Update active boxes and check exits
if array.size(activeSLBoxes) > 0
    for i = array.size(activeSLBoxes) - 1 to 0
        box   currSL = array.get(activeSLBoxes, i)
        box   currTP = array.get(activeTPBoxes, i)
        float sL     = array.get(slPrices, i)
        float tP     = array.get(tpPrices, i)
        int   d      = array.get(directions, i)

        box.set_right(currSL, bar_index)
        box.set_right(currTP, bar_index)

        bool hitSL   = d == 1 ? low <= sL : high >= sL
        bool hitTP   = d == 1 ? high >= tP : low <= tP
        bool bothHit = hitSL and hitTP

        if confirmedBar and (hitTP or hitSL)
            bool tradeWon = bothHit ? false : hitTP
            array.push(tradeHistory, tradeWon)

            if array.size(tradeHistory) > maxTrades
                array.shift(tradeHistory)

            array.remove(activeSLBoxes, i)
            array.remove(activeTPBoxes, i)
            array.remove(entryPrices, i)
            array.remove(slPrices, i)
            array.remove(tpPrices, i)
            array.remove(directions, i)

// ═════════════════════════════════════════════
// STATS
// ═════════════════════════════════════════════
int totalWins   = 0
int totalLosses = 0

if array.size(tradeHistory) > 0
    for i = 0 to array.size(tradeHistory) - 1
        if array.get(tradeHistory, i)
            totalWins += 1
        else
            totalLosses += 1

int   totalClosed = totalWins + totalLosses
float winRate     = totalClosed > 0 ? (totalWins / totalClosed) * 100 : 0.0

// ═════════════════════════════════════════════
// PLOTS
// ═════════════════════════════════════════════
p1 = plot(upperRibbon, color = color.new(hmaSlopeUp ? colorBull : colorBear, 70), display = display.none)
p2 = plot(lowerRibbon, color = color.new(hmaSlopeUp ? colorBull : colorBear, 70), display = display.none)

fillColor = hmaSlopeUp ? colorBull : colorBear
fill(p1, p2, upperRibbon, hmaValue, color.new(fillColor, 75), color.new(fillColor, 90))
fill(p1, p2, hmaValue, lowerRibbon, color.new(fillColor, 90), color.new(fillColor, 75))

plot(hmaValue, 'Trend Baseline', color = color.new(fillColor, 30), linewidth = 2)

// 9:29 levels
plot(todayCaptured and afterTarget ? fairPrice : na, '9:29 Fair Price', color = color.white,  linewidth = 1, style = plot.style_stepline)
plot(todayCaptured and afterTarget ? upperBand  : na, 'Upper Band',     color = color.new(color.red,   55), linewidth = 1)
plot(todayCaptured and afterTarget ? lowerBand  : na, 'Lower Band',     color = color.new(color.green, 55), linewidth = 1)

// Combined signals — Tension Flow + BOS confirmed
plotshape(showLabels and bullSignal, style = shape.labelup,   location = location.belowbar, color = color.new(colorBull, 20), text = 'TF+BOS\nLONG',  textcolor = color.white, size = size.small)
plotshape(showLabels and bearSignal, style = shape.labeldown, location = location.abovebar, color = color.new(colorBear, 20), text = 'TF+BOS\nSHORT', textcolor = color.white, size = size.small)

// Standalone BOS signals (Tension Flow not yet confirmed)
plotshape(standaloneBOSLong,  title = 'BOS Only Long',  style = shape.triangleup,   location = location.belowbar, color = color.new(color.lime,   60), size = size.tiny)
plotshape(standaloneBOSShort, title = 'BOS Only Short', style = shape.triangledown, location = location.abovebar, color = color.new(color.maroon, 60), size = size.tiny)

bgcolor(is0929 ? color.new(color.yellow, 75) : na, title = '9:29 Candle')

// Labels
if afterTarget and not afterTarget[1] and not labelDrawn
    label.new(bar_index, fpHigh,    'H '  + str.tostring(fpHigh,    '#.00'), color = color.new(color.aqua,   20), textcolor = color.black, style = label.style_label_right)
    label.new(bar_index, fairPrice, 'FP ' + str.tostring(fairPrice, '#.00'), color = color.new(color.white,  20), textcolor = color.black, style = label.style_label_right)
    label.new(bar_index, fpLow,     'L '  + str.tostring(fpLow,     '#.00'), color = color.new(color.orange, 20), textcolor = color.black, style = label.style_label_right)
    labelDrawn := true

// ═════════════════════════════════════════════
// ENERGY DASHBOARD
// ═════════════════════════════════════════════
if showTable
    var table trendTable = table.new(position.bottom_right, 2, 3, border_width = 1)

    statusText  = absZ > 2.0 ? 'Overextended' : 'Strong'
    statusColor = absZ > 2.0 ? color.orange : hmaSlopeUp ? colorBull : colorBear
    bosText     = (bosLong or bosShort) ? 'ACTIVE' : 'Waiting'
    bosColor    = (bosLong or bosShort) ? color.new(colorBull, 20) : color.gray

    table.cell(trendTable, 0, 0, 'Z-Score',   bgcolor = #131722, text_color = color.white)
    table.cell(trendTable, 1, 0, str.tostring(zScore, '#.##'), bgcolor = #131722, text_color = statusColor)
    table.cell(trendTable, 0, 1, 'TF Status', bgcolor = #131722, text_color = color.white)
    table.cell(trendTable, 1, 1, statusText,  bgcolor = #131722, text_color = statusColor)
    table.cell(trendTable, 0, 2, 'BOS',       bgcolor = #131722, text_color = color.white)
    table.cell(trendTable, 1, 2, bosText,     bgcolor = #131722, text_color = bosColor)

// ═════════════════════════════════════════════
// RR PERFORMANCE DASHBOARD
// ═════════════════════════════════════════════
if showRRTable
    var table rrTable = table.new(position.top_right, 2, 6, border_width = 1, border_color = color.new(color.gray, 60))

    winRateColor = winRate >= 55 ? color.new(#22c55e, 15) : winRate >= 40 ? color.orange : color.new(#ef4444, 15)

    table.cell(rrTable, 0, 0, 'TF + BOS Performance',   bgcolor = color.new(#1e222d, 0), text_color = color.white,             text_size = size.normal)
    table.cell(rrTable, 1, 0, 'RR ' + str.tostring(rrRatio, '#.#') + ':1', bgcolor = color.new(#1e222d, 0), text_color = color.new(color.gray, 20), text_size = size.normal)
    table.cell(rrTable, 0, 1, '✔ Wins',                 bgcolor = color.new(#131722, 0), text_color = color.white,             text_size = size.normal)
    table.cell(rrTable, 1, 1, str.tostring(totalWins),  bgcolor = color.new(#22c55e, 75), text_color = color.white,            text_size = size.normal)
    table.cell(rrTable, 0, 2, 'X Losses',               bgcolor = color.new(#131722, 0), text_color = color.white,             text_size = size.normal)
    table.cell(rrTable, 1, 2, str.tostring(totalLosses),bgcolor = color.new(#ef4444, 75), text_color = color.white,            text_size = size.normal)
    table.cell(rrTable, 0, 3, 'Win Rate',               bgcolor = color.new(#131722, 0), text_color = color.white,             text_size = size.normal)
    table.cell(rrTable, 1, 3, str.tostring(winRate, '#.##') + '%', bgcolor = winRateColor, text_color = color.white,           text_size = size.normal)
    table.cell(rrTable, 0, 4, 'Sample (last)',           bgcolor = color.new(#131722, 0), text_color = color.new(color.gray, 20), text_size = size.normal)
    table.cell(rrTable, 1, 4, str.tostring(totalClosed) + ' / ' + str.tostring(maxTrades), bgcolor = color.new(#131722, 0), text_color = color.new(color.gray, 20), text_size = size.normal)
    table.cell(rrTable, 0, 5, 'Session Filter',          bgcolor = color.new(#131722, 0), text_color = color.white,             text_size = size.normal)
    table.cell(rrTable, 1, 5, useSessionFilter ? '9:29–11:00 AM' : 'All Day', bgcolor = color.new(#1e222d, 0), text_color = color.new(color.gray, 20), text_size = size.normal)

// ═════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════
alertcondition(bullSignal, title = 'TF+BOS LONG',  message = '{"action":"buy","ticker":"{{ticker}}","price":{{close}},"comment":"Tension Flow + BOS LONG {{ticker}} at {{close}}"}')
alertcondition(bearSignal, title = 'TF+BOS SHORT', message = '{"action":"sell","ticker":"{{ticker}}","price":{{close}},"comment":"Tension Flow + BOS SHORT {{ticker}} at {{close}}"}')
````
