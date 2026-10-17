# ATR based ZigZag

- url: https://www.tradingview.com/script/CC176aL8-ATR-based-ZigZag/
- type: indicator
- pine_id: PUB;101b2ae14b664dec8fbde7d9092b3721
- version: 1.0

## Description

An ATR-based ZigZag indicator that adapts automatically to any timeframe without requiring parameter changes. Uses ATR(20) × 2.0 to determine swing significance — swings smaller than this threshold are filtered out as noise, while genuine trend reversals are connected with clean diagonal lines.

Two display modes:
- Classic ZigZag: diagonal lines connecting confirmed swing highs and lows, with a dashed line for the current unconfirmed leg
- Stepped ZigZag: horizontal stepped line tracking the current swing level

Default settings: ATR Lookback 20, Multiplier 2.0.

## Source Code

````pine
//@version=6
indicator("ATR ZigZag RAK", overlay=true, max_lines_count=500)

// === Toggles ===
showStepped = input.bool(false, "Show ATR ZigZag (stepped)")
showClassic = input.bool(true, "Show Classic ZigZag (diagonal)")

// === ATR Inputs ===
atrLen = input.int(20, "ATR Lookback")
atrMult = input.float(2.0, "ATR Multiplier")
zzColor = input.color(color.orange, "ZigZag Color")
zzWidth = input.int(2, "ZigZag Line Width", minval=1, maxval=5)

// === ATR Calculation ===
atr = ta.atr(atrLen)
threshold = atr * atrMult

// === ZigZag State ===
var float zzPrice = na
var int zzDir = 0
var int zzBar = 0

// Previous confirmed pivot
var float prevPrice = na
var int prevBar = 0

// Track the last unconfirmed leg line
var line lastLeg = na

// Track whether we need to draw a new confirmed line
drawConfirmed = false
var float confirmedFromPrice = na
var int confirmedFromBar = 0
var float confirmedToPrice = na
var int confirmedToBar = 0

if na(zzPrice)
    zzPrice := close
    zzDir := 0
    zzBar := bar_index
else
    if zzDir == 0
        if high > zzPrice + threshold
            zzDir := 1
            prevPrice := zzPrice
            prevBar := zzBar
            zzPrice := high
            zzBar := bar_index
        else if low < zzPrice - threshold
            zzDir := -1
            prevPrice := zzPrice
            prevBar := zzBar
            zzPrice := low
            zzBar := bar_index
    else if zzDir == 1
        if high > zzPrice
            zzPrice := high
            zzBar := bar_index
        else if low < zzPrice - threshold
            confirmedFromPrice := prevPrice
            confirmedFromBar := prevBar
            confirmedToPrice := zzPrice
            confirmedToBar := zzBar
            drawConfirmed := true
            prevPrice := zzPrice
            prevBar := zzBar
            zzDir := -1
            zzPrice := low
            zzBar := bar_index
    else if zzDir == -1
        if low < zzPrice
            zzPrice := low
            zzBar := bar_index
        else if high > zzPrice + threshold
            confirmedFromPrice := prevPrice
            confirmedFromBar := prevBar
            confirmedToPrice := zzPrice
            confirmedToBar := zzBar
            drawConfirmed := true
            prevPrice := zzPrice
            prevBar := zzBar
            zzDir := 1
            zzPrice := high
            zzBar := bar_index

// === Draw confirmed leg ===
if showClassic and drawConfirmed
    line.new(confirmedFromBar, confirmedFromPrice, confirmedToBar, confirmedToPrice, color=zzColor, width=zzWidth)

// === Draw/update unconfirmed leg (dashed) ===
if showClassic and not na(prevPrice)
    if not na(lastLeg)
        line.delete(lastLeg)
    lastLeg := line.new(prevBar, prevPrice, zzBar, zzPrice, color=zzColor, width=zzWidth, style=line.style_dashed)

// === Stepped ZigZag Plot ===
plot(showStepped ? zzPrice : na, title="ATR ZigZag Stepped", color=zzColor, linewidth=zzWidth)
````
