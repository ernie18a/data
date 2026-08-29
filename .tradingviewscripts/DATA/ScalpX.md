<!-- tradingview-pine-id: PUB;4b8909239ac0456b93d87cf62e78d002 -->
<!-- tradingviewscripts-format: 1 -->
# ScalpX

Source: https://www.tradingview.com/script/S5sersa5-ScalpX/

## Description

Learning analysis indicator providing direction of market

---

## Source Code

````pine
//@version=6
indicator("ScalpX", overlay=true, max_lines_count=500, max_labels_count=500)

// ===================== INPUTS =====================
length = input.int(5, "SMA Length", minval=1)
labelOffset = input.int(5, "Live Label Offset", minval=1, maxval=20)

// ===================== SMA =====================
smaHigh  = ta.sma(high, length)
smaLow   = ta.sma(low, length)
smaClose = ta.sma(close, length)

plot(smaHigh, color=color.red)
plot(smaLow, color=color.green)
plot(smaClose, color=color.blue)

upperBand = math.max(smaHigh, math.max(smaLow, smaClose))
lowerBand = math.min(smaHigh, math.min(smaLow, smaClose))

// ===================== CLEAN CANDLES =====================
cleanUp   = low > upperBand
cleanDown = high < lowerBand

// ===================== TRADE STATE =====================
var bool   tradeOpen  = false
var string posDir     = na

var float entryPrice = na
var float slPrice    = na
var float risk       = na

var float tp1Price = na
var float tp2Price = na
var float tp3Price = na

var int currentTP = 0

var float maxR      = 0.0
var float maxRPrice = na

var int entryRefBar = na

// Live objects
var line  entryLine  = na
var line  stopLine   = na
var line  liveTPLine = na

var label entryLbl   = na
var label stopLbl    = na
var label liveTPLbl  = na

// Completed TP objects
var line tp1DoneLine = na
var line tp2DoneLine = na
var line tp3DoneLine = na

var label tp1DoneLbl = na
var label tp2DoneLbl = na
var label tp3DoneLbl = na

// Same-direction re-entry blockers (set on a stop-out, cleared on the matching SMA touch)
var bool blockBuyUntilTouch  = false
var bool blockSellUntilTouch = false

// ===================== FINAL RR FUNCTION =====================
freezeAndReport() =>

    // delete live objects
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(liveTPLine)
        line.delete(liveTPLine)

    if not na(entryLbl)
        label.delete(entryLbl)
    if not na(stopLbl)
        label.delete(stopLbl)
    if not na(liveTPLbl)
        label.delete(liveTPLbl)

    // delete completed TP objects
    if not na(tp1DoneLine)
        line.delete(tp1DoneLine)
    if not na(tp2DoneLine)
        line.delete(tp2DoneLine)
    if not na(tp3DoneLine)
        line.delete(tp3DoneLine)

    if not na(tp1DoneLbl)
        label.delete(tp1DoneLbl)
    if not na(tp2DoneLbl)
        label.delete(tp2DoneLbl)
    if not na(tp3DoneLbl)
        label.delete(tp3DoneLbl)

    // ================= OLD TRADE RR DISPLAY =================
    finalR = math.max(maxR, 0)
    pts = math.abs(maxRPrice - entryPrice)

    // RR line uses the OLD trade's actual live entry point
    rrEntryLevel = entryPrice
    // Dotted line uses the OLD trade's actual live stop level
    rrStopLevel  = slPrice

    rrBar = entryRefBar
    rrX   = rrBar + 3
    rrColor = posDir == "long" ? color.green : color.red

    // RR line - from entry candle to 3 candles after, green for buy / red for sell
    line.new(rrBar, rrEntryLevel, rrX, rrEntryLevel,
         color=rrColor, width=2)

    // Dotted stop line - exact live-trade stop level, entry candle to 3 candles after only
    line.new(rrBar, rrStopLevel, rrX, rrStopLevel,
         color=color.gray, width=2, style=line.style_dotted)

    // RR label
    label.new(rrX, rrEntryLevel,
         "Max RR 1:" + str.tostring(finalR, "#.##") + " | " + str.tostring(pts, "#.##") + " pts",
         style=label.style_label_left,
         color=color.orange,
         textcolor=color.white,
         size=size.small)

// ===================== STOP HIT CHECK (closes the trade) =====================
if tradeOpen
    stopHit = posDir == "long" ? low <= slPrice : high >= slPrice
    if stopHit
        freezeAndReport()
        tradeOpen := false
        if posDir == "long"
            blockBuyUntilTouch := true
        else
            blockSellUntilTouch := true

// ===================== CLEAR THE BLOCK ONCE THE MATCHING SMA LINE IS TOUCHED =====================
// Sell stopped out -> needs SMA LOW touch to allow sell entries again
// Buy stopped out  -> needs SMA HIGH touch to allow buy entries again
if blockBuyUntilTouch and high >= smaHigh
    blockBuyUntilTouch := false
if blockSellUntilTouch and low <= smaLow
    blockSellUntilTouch := false

// ===================== TRACKING =====================
var bool trackingDown = false
var bool trackingUp   = false

var float refHigh       = na
var float refLow        = na
var float refCandleLow  = na
var float refCandleHigh = na
var int   refBar        = na

// exact clean candle breakout reference
var float triggerRefHigh = na
var float triggerRefLow  = na
var int   triggerRefBar  = na

buySignal  = false
sellSignal = false

// ===================== BUY SETUP =====================
if trackingDown
    if high > refHigh
        // only suppressed if a BUY was just stopped out and the SMA high hasn't been touched yet
        if not blockBuyUntilTouch
            buySignal      := true
            triggerRefHigh := refHigh
            triggerRefBar  := refBar
        trackingDown   := false
    else if high >= smaHigh
        trackingDown := false
    else if cleanDown
        refHigh      := high
        refCandleLow := low
        refBar       := bar_index

// ===================== SELL SETUP =====================
if trackingUp
    if low < refLow
        // only suppressed if a SELL was just stopped out and the SMA low hasn't been touched yet
        if not blockSellUntilTouch
            sellSignal      := true
            triggerRefLow   := refLow
            triggerRefBar   := refBar
        trackingUp      := false
    else if low <= smaLow
        trackingUp := false
    else if cleanUp
        refLow         := low
        refCandleHigh  := high
        refBar         := bar_index

// ===================== START TRACKING =====================
if not trackingDown and not trackingUp
    if cleanDown
        trackingDown  := true
        refHigh       := high
        refCandleLow  := low
        refBar        := bar_index
    else if cleanUp
        trackingUp    := true
        refLow        := low
        refCandleHigh := high
        refBar        := bar_index

// ===================== SIGNALS =====================
buyCharY  = buySignal  ? low  - (high - low) * 0.15 : na
sellCharY = sellSignal ? high + (high - low) * 0.15 : na

plotchar(buyCharY,  char="▲", location=location.absolute, color=color.green, size=size.small)
plotchar(sellCharY, char="▼", location=location.absolute, color=color.red,   size=size.small)

// ===================== OPEN LONG =====================
if buySignal

    if tradeOpen
        freezeAndReport()

    posDir := "long"
    tradeOpen := true

    entryPrice := triggerRefHigh
    slPrice := math.min(refCandleLow, entryPrice - syminfo.mintick)
    risk := entryPrice - slPrice

    tp1Price := entryPrice + risk
    tp2Price := entryPrice + risk * 2
    tp3Price := entryPrice + risk * 3

    currentTP := 1
    maxR := 0.0
    maxRPrice := entryPrice

    entryRefBar := bar_index

    entryLine := line.new(bar_index, entryPrice, bar_index + labelOffset, entryPrice, color=color.red, width=3)
    stopLine  := line.new(bar_index, slPrice,    bar_index + labelOffset, slPrice,    color=color.gray, width=3)

    entryLbl := label.new(bar_index + labelOffset, entryPrice, "ENTRY",
         style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small)

    stopLbl := label.new(bar_index + labelOffset, slPrice, "STOP",
         style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.small)

    liveTPLine := line.new(bar_index, tp1Price, bar_index + labelOffset, tp1Price,
         color=color.aqua, width=2, style=line.style_dotted)

    liveTPLbl := label.new(bar_index + labelOffset, tp1Price, "TP1 | RR 1:1",
         style=label.style_label_left, color=color.aqua, textcolor=color.black, size=size.small)

// ===================== OPEN SHORT =====================
if sellSignal

    if tradeOpen
        freezeAndReport()

    posDir := "short"
    tradeOpen := true

    entryPrice := triggerRefLow
    slPrice := math.max(refCandleHigh, entryPrice + syminfo.mintick)
    risk := slPrice - entryPrice

    tp1Price := entryPrice - risk
    tp2Price := entryPrice - risk * 2
    tp3Price := entryPrice - risk * 3

    currentTP := 1
    maxR := 0.0
    maxRPrice := entryPrice

    entryRefBar := bar_index

    entryLine := line.new(bar_index, entryPrice, bar_index + labelOffset, entryPrice, color=color.red, width=3)
    stopLine  := line.new(bar_index, slPrice,    bar_index + labelOffset, slPrice,    color=color.gray, width=3)

    entryLbl := label.new(bar_index + labelOffset, entryPrice, "ENTRY",
         style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small)

    stopLbl := label.new(bar_index + labelOffset, slPrice, "STOP",
         style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.small)

    liveTPLine := line.new(bar_index, tp1Price, bar_index + labelOffset, tp1Price,
         color=color.aqua, width=2, style=line.style_dotted)

    liveTPLbl := label.new(bar_index + labelOffset, tp1Price, "TP1 | RR 1:1",
         style=label.style_label_left, color=color.aqua, textcolor=color.black, size=size.small)

// ===================== EXTEND ALL LIVE OBJECTS =====================
if tradeOpen

    line.set_x2(entryLine, bar_index + labelOffset)
    label.set_x(entryLbl, bar_index + labelOffset)

    line.set_x2(stopLine, bar_index + labelOffset)
    label.set_x(stopLbl, bar_index + labelOffset)

    if not na(liveTPLine)
        line.set_x2(liveTPLine, bar_index + labelOffset)
    if not na(liveTPLbl)
        label.set_x(liveTPLbl, bar_index + labelOffset)
````
