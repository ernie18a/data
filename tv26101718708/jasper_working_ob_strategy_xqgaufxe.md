# Jasper Working OB Strategy

- url: https://www.tradingview.com/script/xqGaUFXE-Jasper-Working-OB-Strategy/
- type: indicator
- pine_id: PUB;934fabb5bc394287a7afc8160b3633ac
- version: 5.0

## Description

Price-action based Order Block strategy that identifies institutional-style supply and demand zones formed after displacement moves and uses them as potential reversal areas. It generates entries when price revisits these zones, confirms interaction, and then shows momentum-based continuation or reversal through simple breakout behavior.

## Source Code

````pine
//@version=6
indicator("Working 1:1 OB Strategy W/SL & TP (By Jasper)", overlay=true, max_boxes_count=500)

//====================================================
// SETTINGS
//====================================================

showBullOB = input.bool(true, "Show Bullish OBs")
showBearOB = input.bool(true, "Show Bearish OBs")
extendBoxes = input.int(30, "Extend Boxes", minval=5)

//====================================================
// NEW YORK SESSION FILTER
//====================================================

nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")

startTime = (nyHour == 7 and nyMinute >= 0) or (nyHour > 7)
endTime   = (nyHour < 9) or (nyHour == 9 and nyMinute <= 30)

tradeWindow = startTime and endTime

//====================================================
// ZONE STORAGE
//====================================================

var float bullZoneTop = na
var float bullZoneBot = na

var float bearZoneTop = na
var float bearZoneBot = na

var bool bullActive = false
var bool bearActive = false

var bool invalidWick = false
var bool skipNextBar = false
var int wickBar = na

var bool bullZoneLeft = false
var bool bearZoneLeft = false

var bool bullReady = false
var bool bearReady = false

var bool bullZoneUsed = false
var bool bearZoneUsed = false

var bool tpHitLock = false
var float activeBullTP = na
var float activeBearTP = na
var bool bullTradeActive = false
var bool bearTradeActive = false

//====================================================
// VALID ORDER BLOCK CONDITIONS
//====================================================

// Bullish sequence
bullDisplacement = close[1] > open[1]
bullConfirm      = close > open
bullFVG          = low > high[2]

// Bearish sequence
bearDisplacement = close[1] < open[1]
bearConfirm      = close < open
bearFVG          = high < low[2]

// Prevent candle BEFORE sequence from being FVG
preBullFVG = low[2] > high[3] or low[1] > high[3]
preBearFVG = high[2] < low[3] or high[1] < low[3]

// Final OB validation
validBullOB = 
     bullDisplacement and 
     bullConfirm and 
     bullFVG and 
     not preBullFVG and
     tradeWindow

validBearOB = 
     bearDisplacement and 
     bearConfirm and 
     bearFVG and 
     not preBearFVG and
     tradeWindow

//====================================================
// CREATE NEW BULLISH ZONE
//====================================================

if validBullOB
    bullZoneTop  := high[2]
    bullZoneBot  := low[2]

    bullActive   := true

    bullZoneLeft := false
    bullReady    := false
    bullZoneUsed := false

//====================================================
// CREATE NEW BEARISH ZONE
//====================================================

if validBearOB
    bearZoneTop  := high[2]
    bearZoneBot  := low[2]

    bearActive   := true

    bearZoneLeft := false
    bearReady    := false
    bearZoneUsed := false

//====================================================
// PRICE MUST LEAVE ZONE FIRST
//====================================================

if bullActive and high > bullZoneTop
    bullZoneLeft := true

if bearActive and low < bearZoneBot
    bearZoneLeft := true

//====================================================
// VALID RETURN INTO ZONE
//====================================================

// Bullish mitigation
bullReturn =
     bullZoneLeft and
     bullActive and
     low <= bullZoneTop and
     high >= bullZoneBot

// Bearish mitigation
bearReturn =
     bearZoneLeft and
     bearActive and
     high >= bearZoneBot and
     low <= bearZoneTop

if bullReturn
    bullReady := true

if bearReturn
    bearReady := true

//====================================================
// ORDER BLOCK FILL DETECTION
//====================================================

// bullish OB fully filled
bullFullyFilled =
     bullActive and
     low <= bullZoneBot

// bearish OB fully filled
bearFullyFilled =
     bearActive and
     high >= bearZoneTop

//====================================================
// ZONE INVALIDATION
//====================================================

// Bullish OB completely consumed
if bullFullyFilled
    bullActive := false
    bullReady := false
    bullZoneUsed := true

// Bearish OB completely consumed
if bearFullyFilled
    bearActive := false
    bearReady := false
    bearZoneUsed := true

//====================================================
// ENTRY LOGIC
//====================================================

doubleWick =
     high > high[1] and
     low < low[1]

if (bullReady or bearReady) and doubleWick
    invalidWick := true
    skipNextBar := true
    wickBar := bar_index

if skipNextBar and bar_index > wickBar
    skipNextBar := false

if not skipNextBar
    invalidWick := false

// BUY:
// 1. valid return into bullish OB
// 2. zone not already traded
// 3. current candle breaks previous candle high

bullEntry =
     bullReady and
     not bullZoneUsed and
     not invalidWick and
     not skipNextBar and
     high > high[1] and
     tradeWindow and 
     not tpHitLock

// SELL:
// 1. valid return into bearish OB
// 2. zone not already traded
// 3. current candle breaks previous candle low

bearEntry =
     bearReady and
     not bearZoneUsed and
     not invalidWick and
     not skipNextBar and
     low < low[1] and
     tradeWindow and 
     not tpHitLock

//====================================================
// SMART STRUCTURE-BASED SL / TP
//====================================================

// BUY
bullEntryPrice = high[1]

// use current candle low IF lower than previous low
bullSL =
     low < low[1]
     ? low
     : low[1]

bullRisk = bullEntryPrice - bullSL
bullTP   = bullEntryPrice + bullRisk

// SELL
bearEntryPrice = low[1]

// use current candle high IF higher than previous high
bearSL =
     high > high[1]
     ? high
     : high[1]

bearRisk = bearSL - bearEntryPrice
bearTP   = bearEntryPrice - bearRisk

bullTPHit = bullTradeActive and high >= activeBullTP
bearTPHit = bearTradeActive and low <= activeBearTP

if bullTPHit or bearTPHit
    tpHitLock := true
    bullTradeActive := false
    bearTradeActive := false

if not tradeWindow
    tpHitLock := false

//====================================================
// LOCK ZONE AFTER ENTRY
//====================================================

if bullEntry
    bullZoneUsed := true
    bullReady := false

    activeBullTP := bullTP
    bullTradeActive := true

if bearEntry
    bearZoneUsed := true
    bearReady := false

    activeBearTP := bearTP
    bearTradeActive := true

//====================================================
// DRAW ORDER BLOCKS
//====================================================

if validBullOB and showBullOB
    box.new(
         bar_index - 2,
         high[2],
         bar_index + extendBoxes,
         low[2],
         bgcolor=color.new(color.green, 85),
         border_color=color.green)

if validBearOB and showBearOB
    box.new(
         bar_index - 2,
         high[2],
         bar_index + extendBoxes,
         low[2],
         bgcolor=color.new(color.red, 85),
         border_color=color.red)

//====================================================
// SIGNALS
//====================================================

plotshape(
     bullEntry,
     title="BUY",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     text="BUY")

plotshape(
     bearEntry,
     title="SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL")

//====================================================
// DRAW SL / TP
//====================================================

if bullEntry

    line.new(
         bar_index,
         bullEntryPrice,
         bar_index + 10,
         bullEntryPrice,
         color=color.white,
         width=2)

    line.new(
         bar_index,
         bullSL,
         bar_index + 10,
         bullSL,
         color=color.red,
         width=2)

    line.new(
         bar_index,
         bullTP,
         bar_index + 10,
         bullTP,
         color=color.green,
         width=2)

    label.new(
         bar_index + 10,
         bullEntryPrice,
         text="Buy Entry",
         style=label.style_label_left,
         color=color.white,
         textcolor=color.black)

    label.new(
         bar_index + 10,
         bullSL,
         text="Buy SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    label.new(
         bar_index + 10,
         bullTP,
         text="Buy TP",
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white)

if bearEntry

    line.new(
         bar_index,
         bearEntryPrice,
         bar_index + 10,
         bearEntryPrice,
         color=color.white,
         width=2)

    line.new(
         bar_index,
         bearSL,
         bar_index + 10,
         bearSL,
         color=color.red,
         width=2)

    line.new(
         bar_index,
         bearTP,
         bar_index + 10,
         bearTP,
         color=color.green,
         width=2)

    label.new(
         bar_index + 10,
         bearEntryPrice,
         text="Sell Entry",
         style=label.style_label_left,
         color=color.white,
         textcolor=color.black)

    label.new(
         bar_index + 10,
         bearSL,
         text="Sell SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white)

    label.new(
         bar_index + 10,
         bearTP,
         text="Sell TP",
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white)
````
