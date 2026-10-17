# Vytis_fx 5mins NQ scalping. 

- url: https://www.tradingview.com/script/jRkLOnXj-Vytis-fx-5mins-NQ-scalping/
- type: indicator
- pine_id: PUB;f7e1b2ed15ab4403a3e2476530c83732
- version: 1.0

## Description

Vytis_fx 5mins NQ Scalping is an advanced NAS100/NQ scalping framework designed for real-time intraday trading on lower timeframes. The indicator combines market structure, EMA trend analysis, liquidity sweeps, momentum confirmation, wick rejection logic, and volatility filters to identify high-probability BUY and SELL setups.

Key features:

* Automatic entry, stop loss, and take profit levels
* Dynamic risk/reward visualization
* EMA trend and momentum filtering
* Liquidity sweep and reclaim detection
* Multi-target TP1 / TP2 / TP3 management
* Built-in performance statistics and win-rate tracking
* Optimized for fast NAS100 scalping conditions

The framework is focused on providing clean, professional, institutional-style setup visualization while improving trade quality, risk management, and execution consistency for active scalpers.

## Source Code

````pine
//@version=5
indicator("NAS100 Scalp Framework V8", overlay=true, max_boxes_count=300, max_lines_count=300, max_labels_count=300)

// INPUTS
ema20Len = input.int(20, "EMA 20")
ema50Len = input.int(50, "EMA 50")
ema200Len = input.int(200, "EMA 200")
atrLen = input.int(14, "ATR")
pivotLen = input.int(5, "Swing Length")

statsDays = input.int(30, "Stats Days")
cooldownBars = input.int(10, "Cooldown Bars")
extendBars = input.int(35, "Setup Extend Bars")

minSL = input.float(18, "Min SL Points")
maxSL = input.float(55, "Max SL Points")
atrBuffer = input.float(0.35, "ATR Buffer")
minImpulseATR = input.float(0.60, "Min Impulse ATR")
wickBodyMult = input.float(1.35, "Wick > Body Multiplier")
emaCompressionMax = input.float(20, "No Trade EMA Compression")

showEMAs = input.bool(true, "Show EMAs")
showStats = input.bool(true, "Show Stats")
showHistorical = input.bool(false, "Show Historical Setups")

// EMA / ATR
ema20 = ta.ema(close, ema20Len)
ema50 = ta.ema(close, ema50Len)
ema200 = ta.ema(close, ema200Len)
atr = ta.atr(atrLen)
rsi = ta.rsi(close, 14)

plot(showEMAs ? ema20 : na, "EMA20", color=color.purple)
plot(showEMAs ? ema50 : na, "EMA50", color=color.blue)
plot(showEMAs ? ema200 : na, "EMA200", color=color.red, linewidth=2)

// STRUCTURE
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// MARKET FILTERS
emaSpread = math.abs(ema20 - ema50) + math.abs(ema50 - ema200)
noTradeChop = emaSpread < emaCompressionMax

bullTrend = close > ema20 and ema20 > ema50
bearTrend = close < ema20 and ema20 < ema50

body = math.abs(close - open)
rng = high - low
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bullImpulse = close > open and rng > atr * minImpulseATR and close > ema20
bearImpulse = close < open and rng > atr * minImpulseATR and close < ema20

buyWickReject = lowerWick > body * wickBodyMult and close > open
sellWickReject = upperWick > body * wickBodyMult and close < open

buySweep = not na(lastLow) and low < lastLow and close > lastLow
sellSweep = not na(lastHigh) and high > lastHigh and close < lastHigh

buyPullback = bullTrend and low <= ema20 and close > ema20 and bullImpulse and rsi > 45
sellPullback = bearTrend and high >= ema20 and close < ema20 and bearImpulse and rsi < 55

buyReclaim = buySweep and (bullImpulse or buyWickReject)
sellReclaim = sellSweep and (bearImpulse or sellWickReject)

buySetup = not noTradeChop and (buyPullback or buyReclaim)
sellSetup = not noTradeChop and (sellPullback or sellReclaim)

// COOLDOWN
var int lastSignalBar = na
canSignal = na(lastSignalBar) or bar_index - lastSignalBar >= cooldownBars

// ACTIVE OBJECTS
var box riskBox = na
var box rewardBox = na
var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

var bool activeTrade = false
var int activeDir = 0
var float activeEntry = na
var float activeSL = na
var float activeTP1 = na
var float activeTP2 = na
var float activeTP3 = na

// STATS
var array<float> statEntry = array.new_float()
var array<float> statSL = array.new_float()
var array<float> statTP1 = array.new_float()
var array<float> statTP2 = array.new_float()
var array<float> statTP3 = array.new_float()
var array<int> statDir = array.new_int()
var array<int> statTime = array.new_int()
var array<int> statStatus = array.new_int()

// DELETE ACTIVE
if activeTrade
    hit = false

    if activeDir == 1
        hit := low <= activeSL or high >= activeTP3

    if activeDir == -1
        hit := high >= activeSL or low <= activeTP3

    if hit and not showHistorical
        box.delete(riskBox)
        box.delete(rewardBox)
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tp1Line)
        line.delete(tp2Line)
        line.delete(tp3Line)
        label.delete(entryLabel)
        label.delete(slLabel)
        label.delete(tp1Label)
        label.delete(tp2Label)
        label.delete(tp3Label)

        activeTrade := false

// UPDATE STATS
if array.size(statEntry) > 0
    for i = 0 to array.size(statEntry) - 1
        st = array.get(statStatus, i)
        dir = array.get(statDir, i)

        if st == 0
            sl = array.get(statSL, i)
            tp1 = array.get(statTP1, i)
            tp2 = array.get(statTP2, i)
            tp3 = array.get(statTP3, i)

            if dir == 1
                if low <= sl
                    array.set(statStatus, i, -1)
                else if high >= tp3
                    array.set(statStatus, i, 3)
                else if high >= tp2
                    array.set(statStatus, i, 2)
                else if high >= tp1
                    array.set(statStatus, i, 1)

            if dir == -1
                if high >= sl
                    array.set(statStatus, i, -1)
                else if low <= tp3
                    array.set(statStatus, i, 3)
                else if low <= tp2
                    array.set(statStatus, i, 2)
                else if low <= tp1
                    array.set(statStatus, i, 1)

// BUY
if buySetup and canSignal and not activeTrade
    entry = close
    rawSL = math.min(low, entry - atr * atrBuffer)
    riskRaw = entry - rawSL
    risk = math.min(math.max(riskRaw, minSL), maxSL)

    sl = entry - risk
    tp1 = entry + risk
    tp2 = entry + risk * 1.5
    tp3 = entry + risk * 2

    x1 = bar_index
    x2 = bar_index + extendBars

    riskBox := box.new(x1, entry, x2, sl, bgcolor=color.new(color.red, 84), border_color=color.red)
    rewardBox := box.new(x1, tp3, x2, entry, bgcolor=color.new(color.green, 88), border_color=color.green)

    entryLine := line.new(x1, entry, x2, entry, color=color.yellow, width=2)
    slLine := line.new(x1, sl, x2, sl, color=color.red, width=2)
    tp1Line := line.new(x1, tp1, x2, tp1, color=color.green, style=line.style_dotted)
    tp2Line := line.new(x1, tp2, x2, tp2, color=color.green, style=line.style_dotted)
    tp3Line := line.new(x1, tp3, x2, tp3, color=color.green, style=line.style_dotted)

    entryLabel := label.new(x1, entry, "BUY ENTRY\n" + str.tostring(entry, format.mintick), style=label.style_label_right, color=color.yellow, textcolor=color.black)
    slLabel := label.new(x1, sl, "SL\n" + str.tostring(sl, format.mintick), style=label.style_label_right, color=color.red, textcolor=color.white)
    tp1Label := label.new(x2, tp1, "TP1 1R\n" + str.tostring(tp1, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    tp2Label := label.new(x2, tp2, "TP2 1.5R\n" + str.tostring(tp2, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    tp3Label := label.new(x2, tp3, "TP3 2R\n" + str.tostring(tp3, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)

    activeTrade := true
    activeDir := 1
    activeEntry := entry
    activeSL := sl
    activeTP1 := tp1
    activeTP2 := tp2
    activeTP3 := tp3
    lastSignalBar := bar_index

    array.push(statEntry, entry)
    array.push(statSL, sl)
    array.push(statTP1, tp1)
    array.push(statTP2, tp2)
    array.push(statTP3, tp3)
    array.push(statDir, 1)
    array.push(statTime, time)
    array.push(statStatus, 0)

// SELL
if sellSetup and canSignal and not activeTrade
    entry = close
    rawSL = math.max(high, entry + atr * atrBuffer)
    riskRaw = rawSL - entry
    risk = math.min(math.max(riskRaw, minSL), maxSL)

    sl = entry + risk
    tp1 = entry - risk
    tp2 = entry - risk * 1.5
    tp3 = entry - risk * 2

    x1 = bar_index
    x2 = bar_index + extendBars

    riskBox := box.new(x1, sl, x2, entry, bgcolor=color.new(color.red, 84), border_color=color.red)
    rewardBox := box.new(x1, entry, x2, tp3, bgcolor=color.new(color.green, 88), border_color=color.green)

    entryLine := line.new(x1, entry, x2, entry, color=color.yellow, width=2)
    slLine := line.new(x1, sl, x2, sl, color=color.red, width=2)
    tp1Line := line.new(x1, tp1, x2, tp1, color=color.green, style=line.style_dotted)
    tp2Line := line.new(x1, tp2, x2, tp2, color=color.green, style=line.style_dotted)
    tp3Line := line.new(x1, tp3, x2, tp3, color=color.green, style=line.style_dotted)

    entryLabel := label.new(x1, entry, "SELL ENTRY\n" + str.tostring(entry, format.mintick), style=label.style_label_right, color=color.yellow, textcolor=color.black)
    slLabel := label.new(x1, sl, "SL\n" + str.tostring(sl, format.mintick), style=label.style_label_right, color=color.red, textcolor=color.white)
    tp1Label := label.new(x2, tp1, "TP1 1R\n" + str.tostring(tp1, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    tp2Label := label.new(x2, tp2, "TP2 1.5R\n" + str.tostring(tp2, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)
    tp3Label := label.new(x2, tp3, "TP3 2R\n" + str.tostring(tp3, format.mintick), style=label.style_label_left, color=color.green, textcolor=color.white)

    activeTrade := true
    activeDir := -1
    activeEntry := entry
    activeSL := sl
    activeTP1 := tp1
    activeTP2 := tp2
    activeTP3 := tp3
    lastSignalBar := bar_index

    array.push(statEntry, entry)
    array.push(statSL, sl)
    array.push(statTP1, tp1)
    array.push(statTP2, tp2)
    array.push(statTP3, tp3)
    array.push(statDir, -1)
    array.push(statTime, time)
    array.push(statStatus, 0)

// TABLE
cutoff = time - statsDays * 24 * 60 * 60 * 1000

total = 0
tp1Count = 0
tp2Count = 0
tp3Count = 0
slCount = 0
openCount = 0

if array.size(statEntry) > 0
    for i = 0 to array.size(statEntry) - 1
        sigTime = array.get(statTime, i)
        st = array.get(statStatus, i)

        if sigTime >= cutoff
            total += 1

            if st == 1
                tp1Count += 1
            else if st == 2
                tp1Count += 1
                tp2Count += 1
            else if st == 3
                tp1Count += 1
                tp2Count += 1
                tp3Count += 1
            else if st == -1
                slCount += 1
            else
                openCount += 1

tp1Rate = total > 0 ? tp1Count / total * 100 : na
slRate = total > 0 ? slCount / total * 100 : na

var table t = table.new(position.top_right, 2, 8, border_width=1)

if barstate.islast and showStats
    table.cell(t, 0, 0, "V8 STATS", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 0, str.tostring(statsDays) + "D", bgcolor=color.black, text_color=color.white)

    table.cell(t, 0, 1, "Setups")
    table.cell(t, 1, 1, str.tostring(total))

    table.cell(t, 0, 2, "TP1")
    table.cell(t, 1, 2, str.tostring(tp1Count))

    table.cell(t, 0, 3, "TP2")
    table.cell(t, 1, 3, str.tostring(tp2Count))

    table.cell(t, 0, 4, "TP3")
    table.cell(t, 1, 4, str.tostring(tp3Count))

    table.cell(t, 0, 5, "SL")
    table.cell(t, 1, 5, str.tostring(slCount))

    table.cell(t, 0, 6, "Open")
    table.cell(t, 1, 6, str.tostring(openCount))

    table.cell(t, 0, 7, "TP1 %")
    table.cell(t, 1, 7, na(tp1Rate) ? "n/a" : str.tostring(tp1Rate, "#.##") + "%")
````
