# AEST ORB + 3-Candle Expansion System

- url: https://www.tradingview.com/script/Ryr0LxMu-AEST-ORB-3-Candle-Expansion-System/
- type: indicator
- pine_id: PUB;f23d6d1a953946169d01d2ffdab809e9
- version: 2.0

## Description

15 minute ORB with 3 candle expansion breakout system. Set to AEST

## Source Code

````pine
//@version=6
indicator("OR + True 3-Candle Expansion System (Timezone Dropdown)", overlay=true, max_boxes_count=500, max_labels_count=500)

//====================================================
// TIMEZONE DROPDOWN (NO LIBRARY)
//====================================================
tzChoice = input.string(
     "Australia/Brisbane",
     "Session Timezone",
     options = [
         "Australia/Brisbane",
         "Australia/Sydney",
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "Europe/London",
         "Europe/Berlin",
         "Europe/Paris",
         "Asia/Tokyo",
         "Asia/Singapore",
         "Asia/Hong_Kong",
         "Asia/Dubai",
         "Pacific/Auckland",
         "UTC",
         "Custom"
     ]
)

tzCustom = input.string("Australia/Brisbane", "Custom Timezone (IANA)", tooltip="Used only when Session Timezone = Custom")
string tz = tzChoice == "Custom" ? tzCustom : tzChoice

//====================================================
// INPUTS
//====================================================
orMinutes   = input.int(15, "Opening Range Minutes", minval=1)
boxMinutes  = input.int(120, "Box Duration Minutes", minval=15)
showSignals = input.bool(true, "Show BUY/SELL")
oneSignal   = input.bool(true, "One Signal Per Direction Per Session")

atrLength   = input.int(14, "ATR Length", minval=1)
rangeMult   = input.float(1.2, "Candle 2 Range > ATR x", minval=0.1, step=0.05)
bodyPctMin  = input.float(70.0, "Candle 2 Min Body %", minval=0, maxval=100, step=1)

useSydney = input.bool(true, "Enable Sydney")
useAsia   = input.bool(true, "Enable Asia")
useLondon = input.bool(true, "Enable London")
useNY     = input.bool(true, "Enable New York")

sydneySession = input.session("0700-1600", "Sydney Session")
asiaSession   = input.session("0900-1800", "Asia Session")
londonSession = input.session("1700-0200", "London Session")
nySession     = input.session("2200-0700", "New York Session")

sydColor  = input.color(color.new(color.aqua, 85), "Sydney Box Color")
asiaColor = input.color(color.new(color.yellow, 85), "Asia Box Color")
lonColor  = input.color(color.new(color.orange, 85), "London Box Color")
nyColor   = input.color(color.new(color.fuchsia, 85), "New York Box Color")

//====================================================
// HELPERS
//====================================================
inSession(sess) =>
    not na(time(timeframe.period, sess, tz))

sessionStart(sess) =>
    inSession(sess) and not inSession(sess)[1]

atr = ta.atr(atrLength)

orEndTime(startTime) =>
    startTime + (orMinutes * 60000)

// Candle mapping:
// [2] = Candle 1
// [1] = Candle 2 (true expansion candle)
// [0] = Candle 3 (signal candle)

// Strong bullish candle 2
bullExpansionCandle2() =>
    c2Range   = high[1] - low[1]
    c2Body    = math.abs(close[1] - open[1])
    c2BodyPct = c2Range > 0 ? (c2Body / c2Range) * 100.0 : 0.0
    (close[1] > open[1]) and (c2Range > atr[1] * rangeMult) and (c2BodyPct >= bodyPctMin)

// Strong bearish candle 2
bearExpansionCandle2() =>
    c2Range   = high[1] - low[1]
    c2Body    = math.abs(close[1] - open[1])
    c2BodyPct = c2Range > 0 ? (c2Body / c2Range) * 100.0 : 0.0
    (close[1] < open[1]) and (c2Range > atr[1] * rangeMult) and (c2BodyPct >= bodyPctMin)

// Buy:
// - Candle 2 bullish expansion
// - High of Candle 1 below Low of Candle 3
// - Candle 3 closes above OR high
buyPattern(orHigh) =>
    (
        bar_index >= 2 and
        bullExpansionCandle2() and
        (high[2] < low) and
        (close > orHigh)
    )

// Sell:
// - Candle 2 bearish expansion
// - Low of Candle 1 above High of Candle 3
// - Candle 3 closes below OR low
sellPattern(orLow) =>
    (
        bar_index >= 2 and
        bearExpansionCandle2() and
        (low[2] > high) and
        (close < orLow)
    )

//====================================================
// SYDNEY
//====================================================
var float sydORHigh = na
var float sydORLow = na
var int sydStartTime = na
var int sydOREnd = na
var bool sydBuilt = false
var bool sydLongUsed = false
var bool sydShortUsed = false
var box sydBox = na

sydIn = useSydney and inSession(sydneySession)
sydStart = useSydney and sessionStart(sydneySession)

if sydStart
    sydStartTime := time
    sydOREnd := orEndTime(sydStartTime)
    sydORHigh := high
    sydORLow := low
    sydBuilt := false
    sydLongUsed := false
    sydShortUsed := false
    sydBox := na

sydBuilding = sydIn and not na(sydStartTime) and (time < sydOREnd)
sydBoxWindow = sydIn and not na(sydStartTime) and (time <= sydStartTime + boxMinutes * 60000)

if sydBuilding
    sydORHigh := math.max(nz(sydORHigh, high), high)
    sydORLow := math.min(nz(sydORLow, low), low)

if sydIn and not sydBuilt and not na(sydORHigh) and not na(sydORLow) and time >= sydOREnd
    sydBuilt := true
    sydBox := box.new(left=sydStartTime, top=sydORHigh, right=sydStartTime + boxMinutes * 60000, bottom=sydORLow, xloc=xloc.bar_time, bgcolor=sydColor, border_color=color.aqua)

sydBuy = sydBoxWindow and sydBuilt and buyPattern(sydORHigh) and (not oneSignal or not sydLongUsed)
sydSell = sydBoxWindow and sydBuilt and sellPattern(sydORLow) and (not oneSignal or not sydShortUsed)

if sydBuy
    sydLongUsed := true
if sydSell
    sydShortUsed := true

//====================================================
// ASIA
//====================================================
var float asiaORHigh = na
var float asiaORLow = na
var int asiaStartTime = na
var int asiaOREnd = na
var bool asiaBuilt = false
var bool asiaLongUsed = false
var bool asiaShortUsed = false
var box asiaBox = na

asiaIn = useAsia and inSession(asiaSession)
asiaStart = useAsia and sessionStart(asiaSession)

if asiaStart
    asiaStartTime := time
    asiaOREnd := orEndTime(asiaStartTime)
    asiaORHigh := high
    asiaORLow := low
    asiaBuilt := false
    asiaLongUsed := false
    asiaShortUsed := false
    asiaBox := na

asiaBuilding = asiaIn and not na(asiaStartTime) and (time < asiaOREnd)
asiaBoxWindow = asiaIn and not na(asiaStartTime) and (time <= asiaStartTime + boxMinutes * 60000)

if asiaBuilding
    asiaORHigh := math.max(nz(asiaORHigh, high), high)
    asiaORLow := math.min(nz(asiaORLow, low), low)

if asiaIn and not asiaBuilt and not na(asiaORHigh) and not na(asiaORLow) and time >= asiaOREnd
    asiaBuilt := true
    asiaBox := box.new(left=asiaStartTime, top=asiaORHigh, right=asiaStartTime + boxMinutes * 60000, bottom=asiaORLow, xloc=xloc.bar_time, bgcolor=asiaColor, border_color=color.yellow)

asiaBuy = asiaBoxWindow and asiaBuilt and buyPattern(asiaORHigh) and (not oneSignal or not asiaLongUsed)
asiaSell = asiaBoxWindow and asiaBuilt and sellPattern(asiaORLow) and (not oneSignal or not asiaShortUsed)

if asiaBuy
    asiaLongUsed := true
if asiaSell
    asiaShortUsed := true

//====================================================
// LONDON
//====================================================
var float lonORHigh = na
var float lonORLow = na
var int lonStartTime = na
var int lonOREnd = na
var bool lonBuilt = false
var bool lonLongUsed = false
var bool lonShortUsed = false
var box lonBox = na

lonIn = useLondon and inSession(londonSession)
lonStart = useLondon and sessionStart(londonSession)

if lonStart
    lonStartTime := time
    lonOREnd := orEndTime(lonStartTime)
    lonORHigh := high
    lonORLow := low
    lonBuilt := false
    lonLongUsed := false
    lonShortUsed := false
    lonBox := na

lonBuilding = lonIn and not na(lonStartTime) and (time < lonOREnd)
lonBoxWindow = lonIn and not na(lonStartTime) and (time <= lonStartTime + boxMinutes * 60000)

if lonBuilding
    lonORHigh := math.max(nz(lonORHigh, high), high)
    lonORLow := math.min(nz(lonORLow, low), low)

if lonIn and not lonBuilt and not na(lonORHigh) and not na(lonORLow) and time >= lonOREnd
    lonBuilt := true
    lonBox := box.new(left=lonStartTime, top=lonORHigh, right=lonStartTime + boxMinutes * 60000, bottom=lonORLow, xloc=xloc.bar_time, bgcolor=lonColor, border_color=color.orange)

lonBuy = lonBoxWindow and lonBuilt and buyPattern(lonORHigh) and (not oneSignal or not lonLongUsed)
lonSell = lonBoxWindow and lonBuilt and sellPattern(lonORLow) and (not oneSignal or not lonShortUsed)

if lonBuy
    lonLongUsed := true
if lonSell
    lonShortUsed := true

//====================================================
// NEW YORK
//====================================================
var float nyORHigh = na
var float nyORLow = na
var int nyStartTime = na
var int nyOREnd = na
var bool nyBuilt = false
var bool nyLongUsed = false
var bool nyShortUsed = false
var box nyBox = na

nyIn = useNY and inSession(nySession)
nyStart = useNY and sessionStart(nySession)

if nyStart
    nyStartTime := time
    nyOREnd := orEndTime(nyStartTime)
    nyORHigh := high
    nyORLow := low
    nyBuilt := false
    nyLongUsed := false
    nyShortUsed := false
    nyBox := na

nyBuilding = nyIn and not na(nyStartTime) and (time < nyOREnd)
nyBoxWindow = nyIn and not na(nyStartTime) and (time <= nyStartTime + boxMinutes * 60000)

if nyBuilding
    nyORHigh := math.max(nz(nyORHigh, high), high)
    nyORLow := math.min(nz(nyORLow, low), low)

if nyIn and not nyBuilt and not na(nyORHigh) and not na(nyORLow) and time >= nyOREnd
    nyBuilt := true
    nyBox := box.new(left=nyStartTime, top=nyORHigh, right=nyStartTime + boxMinutes * 60000, bottom=nyORLow, xloc=xloc.bar_time, bgcolor=nyColor, border_color=color.fuchsia)

nyBuy = nyBoxWindow and nyBuilt and buyPattern(nyORHigh) and (not oneSignal or not nyLongUsed)
nySell = nyBoxWindow and nyBuilt and sellPattern(nyORLow) and (not oneSignal or not nyShortUsed)

if nyBuy
    nyLongUsed := true
if nySell
    nyShortUsed := true

//====================================================
// FINAL OUTPUT
//====================================================
buy = showSignals and (sydBuy or asiaBuy or lonBuy or nyBuy)
sell = showSignals and (sydSell or asiaSell or lonSell or nySell)

plotshape(buy, title="BUY", style=shape.labelup, location=location.belowbar, color=color.lime, text="buy", textcolor=color.black, size=size.small)
plotshape(sell, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, text="sell", textcolor=color.white, size=size.small)
````
