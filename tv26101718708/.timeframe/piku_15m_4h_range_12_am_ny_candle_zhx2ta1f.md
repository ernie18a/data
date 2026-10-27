# Piku 15m + 4H Range 12 am NY Candle

- url: https://www.tradingview.com/script/zHx2tA1f-Piku-15m-4H-Range-12-am-NY-Candle/
- type: indicator
- pine_id: PUB;9e1853237d614fdc8c843e3632dd7de0
- version: 1.0

## Description

This indicator automatically plots the first 15-minute and first 4-hour candle ranges of the day using true multi-timeframe data. The ranges are displayed as shaded boxes that extend throughout the trading day, helping traders visualize key liquidity zones.

The script also includes an EMA (default 21) for trend context.

Trade signals are generated when price breaks outside the 4H range and then re-enters it, indicating potential false breakouts and mean-reversion opportunities.

Features:

Automatic First 15m Range
Automatic First 4H Range
True MTF locking for accurate ranges
21 EMA trend reference
BUY / SELL signals on 4H range re-entry
Alert conditions for automated notifications

This tool is useful for intraday traders looking to trade liquidity grabs, fake breakouts, and range re-entries.

## Source Code

````pine
//@version=6
indicator("15m + 4H Range 12 am NY Candle", overlay=true)

// === INPUT ===
emaLength = input.int(21, "EMA Length")

// === EMA ===
ema = ta.ema(close, emaLength)
plot(ema, title="EMA", linewidth=2)

// === COLORS ===
color15 = color.new(color.blue, 80)
color4h = color.new(color.orange, 85)

// === NEW DAY (NY assumed) ===
isNewDay = ta.change(dayofmonth(time)) != 0

// =========================
// 🔵 TRUE 15m FIRST CANDLE
// =========================
var float rangeHigh15 = na
var float rangeLow15  = na
var int start15 = na
var box box15 = na
var bool got15 = false

[high15m, low15m, t15] = request.security(syminfo.tickerid, "15", [high, low, time])
new15 = ta.change(t15) != 0

if isNewDay
    got15 := false
    box15 := na

// Detect first 15m candle of the day
if new15 and not got15 and hour(t15) == 0 and minute(t15) == 0
    rangeHigh15 := high15m
    rangeLow15 := low15m
    start15 := bar_index
    got15 := true

if got15
    if na(box15)
        box15 := box.new(start15, rangeHigh15, bar_index, rangeLow15,
            bgcolor=color15, border_color=color.blue)
    else
        box.set_right(box15, bar_index)


// =========================
// 🟠 TRUE 4H FIRST CANDLE
// =========================
var float rangeHigh4h = na
var float rangeLow4h  = na
var int start4h = na
var box box4h = na
var bool got4h = false

[high4h, low4h, t4h] = request.security(syminfo.tickerid, "240", [high, low, time])
new4h = ta.change(t4h) != 0

if isNewDay
    got4h := false
    box4h := na

// Detect first 4H candle of the day (robust)
if new4h and not got4h and dayofmonth(t4h) == dayofmonth(time)
    rangeHigh4h := high4h
    rangeLow4h := low4h
    start4h := bar_index
    got4h := true

if got4h
    if na(box4h)
        box4h := box.new(start4h, rangeHigh4h, bar_index, rangeLow4h,
            bgcolor=color4h, border_color=color.orange)
    else
        box.set_right(box4h, bar_index)


// =========================
// 🔥 SIGNAL LOGIC (4H RANGE)
// =========================
var bool brokeAbove = false
var bool brokeBelow = false

rangeReady = got4h

if rangeReady
    if close > rangeHigh4h
        brokeAbove := true
    if close < rangeLow4h
        brokeBelow := true

sellSignal = rangeReady and brokeAbove and close < rangeHigh4h and close > rangeLow4h
buySignal  = rangeReady and brokeBelow and close > rangeLow4h and close < rangeHigh4h

if sellSignal
    brokeAbove := false

if buySignal
    brokeBelow := false

// =========================
// 📍 SIGNALS
// =========================
plotshape(sellSignal, location=location.abovebar,
     color=color.red, style=shape.labeldown, text="SELL")

plotshape(buySignal, location=location.belowbar,
     color=color.green, style=shape.labelup, text="BUY")

// =========================
// 🔔 ALERTS
// =========================
alertcondition(buySignal, "BUY", "BUY: Re-entry into 4H range")
alertcondition(sellSignal, "SELL", "SELL: Re-entry into 4H range")
````
