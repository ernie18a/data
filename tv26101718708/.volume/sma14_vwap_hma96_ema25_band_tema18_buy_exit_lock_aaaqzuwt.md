# SMA14 + VWAP + HMA96 + EMA25 Band + TEMA18 (Buy + Exit + Lock)

- url: https://www.tradingview.com/script/aAaQZuwT-SMA14-VWAP-HMA96-EMA25-Band-TEMA18-Buy-Exit-Lock/
- type: indicator
- pine_id: PUB;b41c15586a9049508b09f7f55bc044f3
- version: 1.0

## Description

SMA14 + VWAP + HMA96 + EMA25 Band + TEMA18 (Buy + Exit + Lock) for Indian market

## Source Code

````pine
//@version=6
indicator("SMA14 + VWAP + HMA96 + EMA25 Band + TEMA18 (Buy + Exit + Lock)", overlay=true, max_labels_count=500)

// ===== INPUTS =====
smaLen     = input.int(14, title="SMA Length")
hmaLen     = input.int(96, title="HMA Length")
emaBandLen = input.int(25, title="EMA Band Length")
temaLen    = input.int(18, title="TEMA Length")

lockTrigger = input.float(80.0, "Lock Trigger Points")
lockPoints  = input.float(60.0, "Lock Profit Points")

showBuy  = input.bool(true, title="Show Buy Label")
showExit = input.bool(true, title="Show Exit Label")

// ===== SMA =====
smaValue = ta.sma(close, smaLen)

// ===== VWAP =====
vwapValue = ta.vwap(close)

// ===== HMA =====
hma(src, length) =>
    halfLen = math.round(length / 2)
    sqrtLen = math.round(math.sqrt(length))
    ta.wma(2 * ta.wma(src, halfLen) - ta.wma(src, length), sqrtLen)

hma96 = hma(close, hmaLen)

// ===== EMA BAND =====
emaHigh = ta.ema(high, emaBandLen)
emaLow  = ta.ema(low, emaBandLen)

// ===== TEMA =====
ema1 = ta.ema(close, temaLen)
ema2 = ta.ema(ema1, temaLen)
ema3 = ta.ema(ema2, temaLen)
tema18 = 3 * (ema1 - ema2) + ema3

// ===== GREEN ZONE =====
crossUp = ta.crossover(smaValue, vwapValue)
trendOk = close > hma96

var bool inZone = false

if crossUp and trendOk
    inZone := true

if inZone and (smaValue < vwapValue or close < hma96)
    inZone := false

// ===== TRADE STATE =====
var bool buyTakenInZone = false
var bool inTrade = false
var float entryPrice = na
var float lockLevel = na

if not inZone
    buyTakenInZone := false

// ===== BUY =====
retestToEmaHigh = low <= emaHigh and close >= emaHigh
zoneJustStarted = inZone and not inZone[1]

buySignal = inZone and not zoneJustStarted and not buyTakenInZone and not inTrade and retestToEmaHigh

if buySignal
    buyTakenInZone := true
    inTrade := true
    entryPrice := close
    lockLevel := na

// ===== LOCK PROFIT =====
if inTrade and not na(entryPrice)
    if (close - entryPrice) >= lockTrigger
        lockLevel := entryPrice + lockPoints

// ===== EXIT CONDITIONS =====
temaCrossDown = ta.crossunder(tema18, smaValue)
greenZoneBreak = inTrade and not inZone and inZone[1]
lockHit = inTrade and not na(lockLevel) and close <= lockLevel

exitSignal = inTrade and (greenZoneBreak or temaCrossDown or lockHit)

if exitSignal
    inTrade := false
    entryPrice := na
    lockLevel := na

// ===== PLOTS =====
plot(smaValue, color=color.green, linewidth=2, title="SMA 14")
plot(vwapValue, color=color.orange, linewidth=2, title="VWAP")
plot(hma96, color=color.red, linewidth=2, title="HMA 96")
plot(tema18, color=color.purple, linewidth=2, title="TEMA 18")

emaHighPlot = plot(emaHigh, color=color.blue, title="EMA 25 High")
emaLowPlot  = plot(emaLow, color=color.blue, title="EMA 25 Low")
fill(emaHighPlot, emaLowPlot, color=color.new(color.blue, 85))

bgcolor(inZone ? color.new(color.green, 85) : na)

// ===== LOCK LEVEL =====
plot(lockLevel, color=color.yellow, title="Lock Level", style=plot.style_linebr)

// ===== LABELS WITH PRICE =====
if showBuy and buySignal
    label.new(bar_index, low,
     "BUY @ " + str.tostring(close, format.mintick),
     style=label.style_label_up,
     color=color.lime,
     textcolor=color.black)

if showExit and exitSignal
    label.new(bar_index, high,
     "EXIT @ " + str.tostring(close, format.mintick),
     style=label.style_label_down,
     color=color.red,
     textcolor=color.white)

// ===== ALERTS =====
alertcondition(buySignal, title="BUY ALERT", message="BUY: EMA High retest in green zone")
alertcondition(exitSignal, title="EXIT ALERT", message="EXIT: Zone break / TEMA cross / Lock hit")
````
