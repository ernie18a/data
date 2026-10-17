# EW Bottom Signals (Indicator Version)

- url: https://www.tradingview.com/script/D0GLzSnl-EW-Bottom-Signals-Indicator-Version/
- type: indicator
- pine_id: PUB;8aa1ea92411047fb94d0eef6ee44bb03
- version: 1.0

## Description

This strategy identifies Elliott Wave A‑B‑C corrections inside downtrends and uses the final Wave C flush as the earliest possible reversal signal. It waits for a capitulation candle with a volume spike to trigger a small “first buy,” then adds size only when price regains strength by crossing the 50MA and finally the 200MA. The system visualizes the active A‑B‑C structure on the chart, connects the legs, and scores the wave’s strength so you only act on high‑quality reversals instead of noisy chop.

## Source Code

````pine
//@version=6
indicator("EW Bottom Signals (Indicator Version)", overlay=true, max_labels_count=500, max_lines_count=500)

// === INPUTS ===
zigzagDepth = input.int(3, "ZigZag Depth", minval=1)

// === ZIGZAG SWINGS ===
var float swingHigh = na
var float swingLow  = na
var int   swingDir  = 0

isSwingHigh = high[zigzagDepth] == ta.highest(high, zigzagDepth * 2 + 1)
isSwingLow  = low[zigzagDepth]  == ta.lowest(low, zigzagDepth * 2 + 1)

if (isSwingHigh)
    swingHigh := high[zigzagDepth]
    swingDir  := -1

if (isSwingLow)
    swingLow := low[zigzagDepth]
    swingDir := 1

// === ABC STATE MACHINE ===
var int waveState = 0
waveA_signal = false
waveB_signal = false
waveC_signal = false

if (isSwingHigh and swingDir == -1 and waveState == 0)
    waveState := 1
    waveA_signal := true

if (isSwingLow and swingDir == 1 and waveState == 1)
    waveState := 2
    waveB_signal := true

if (isSwingHigh and swingDir == -1 and waveState == 2)
    waveState := 3
    waveC_signal := true

if (waveState == 3 and isSwingLow and swingDir == 1)
    waveState := 0

// === ACTIVE ABC VISUALIZATION STORAGE ===
var float waveA_price = na
var float waveB_price = na
var float waveC_price = na

var int waveA_index = na
var int waveB_index = na
var int waveC_index = na

if waveA_signal
    waveA_price := swingHigh
    waveA_index := bar_index - zigzagDepth

if waveB_signal
    waveB_price := swingLow
    waveB_index := bar_index - zigzagDepth

if waveC_signal
    waveC_price := swingHigh
    waveC_index := bar_index - zigzagDepth

// === DRAW ACTIVE ABC LABELS ===
if waveState >= 1 and not na(waveA_price)
    label.new(waveA_index, waveA_price, "A",
        style = label.style_label_down,
        color = color.new(color.red, 0),
        textcolor = color.white,
        size = size.large)

if waveState >= 2 and not na(waveB_price)
    label.new(waveB_index, waveB_price, "B",
        style = label.style_label_up,
        color = color.new(color.orange, 0),
        textcolor = color.white,
        size = size.large)

if waveState == 3 and not na(waveC_price)
    label.new(waveC_index, waveC_price, "C",
        style = label.style_label_down,
        color = color.new(color.green, 0),
        textcolor = color.white,
        size = size.large)

// === CONNECT A → B → C WHEN IN WAVE C ===
if waveState == 3 and not na(waveA_price) and not na(waveB_price)
    line.new(waveA_index, waveA_price, waveB_index, waveB_price,
        color = color.new(color.white, 0), width = 2)

if waveState == 3 and not na(waveB_price) and not na(waveC_price)
    line.new(waveB_index, waveB_price, waveC_index, waveC_price,
        color = color.new(color.white, 0), width = 2)

// === WAVE LEG DISPLAY ===
waveText = waveState == 0 ? "NONE" :
           waveState == 1 ? "A" :
           waveState == 2 ? "B" :
           waveState == 3 ? "C" : "NONE"

var label waveLabel = na

if barstate.islast
    if na(waveLabel)
        waveLabel := label.new(bar_index, high, "LEG: " + waveText,
            style=label.style_label_center,
            color=color.new(color.black, 0),
            textcolor=color.white,
            size=size.large)
    else
        label.set_x(waveLabel, bar_index)
        label.set_y(waveLabel, high)
        label.set_text(waveLabel, "LEG: " + waveText)

// === MOVING AVERAGES ===
ma50  = ta.sma(close, 50)
ma200 = ta.sma(close, 200)
below200 = close < ma200

// === CAPITULATION CANDLE ===
bodySize = math.abs(close - open)
wickSize = (high - low) - bodySize
volumeSpike = volume > ta.sma(volume, 20) * 1.4

capitulation = (
    open > close and
    wickSize > bodySize and
    volumeSpike
)

// === BUY SIGNALS (PERCENTAGE-BASED) ===
inWaveC = waveState == 3

firstBuySignal = (
    inWaveC and
    below200 and
    capitulation
)

cross50 = ta.crossover(close, ma50)
cross200 = ta.crossover(ma50, ma200)

secondBuySignal = (
    firstBuySignal[1] and cross50
)

finalBuySignal = (
    secondBuySignal[1] and
    cross200
)


sellSignal = (
    ta.crossunder(ma50, ma200)
)

// === PLOT SIGNALS ===
plotshape(firstBuySignal, title="FIRST BUY 10%", style=shape.labeldown,
     text="FIRST BUY\n10%", color=color.yellow, size=size.large)

plotshape(secondBuySignal, title="50MA BUY 60%", style=shape.labeldown,
     text="50MA BUY\n60%", color=color.orange, size=size.large)

plotshape(finalBuySignal, title="GOLDEN BUY 30%", style=shape.labeldown,
     text="GOLDEN BUY\n30%", color=color.green, size=size.large)

plotshape(sellSignal, title="SELL", style=shape.labelup,
     text="SELL", color=color.red, size=size.large)

// === ALERTS ===
alertcondition(firstBuySignal, "FIRST BUY 10%", "FIRST BUY SIGNAL — Add 10% position")
alertcondition(secondBuySignal, "50MA BUY 60%", "50MA BUY SIGNAL — Add 60% position")
alertcondition(finalBuySignal, "GOLDEN BUY 30%", "GOLDEN BUY SIGNAL — Add 30% position")
alertcondition(sellSignal, "SELL SIGNAL", "SELL SIGNAL — Exit position")

// === WAVE STRENGTH SCORE ===
magnitudeA = math.abs(waveA_price - waveB_price)
magnitudeC = math.abs(waveC_price - waveB_price)
magnitudeScore = math.min(25, (magnitudeA + magnitudeC) / close * 250)

symmetryRatio = magnitudeC / magnitudeA
symmetryScore = (
    symmetryRatio > 0.8 and symmetryRatio < 2.0 ? 25 :
    symmetryRatio > 0.5 and symmetryRatio < 3.0 ? 15 : 5
)

volC = volume[zigzagDepth]
volBase = ta.sma(volume, 20)
volumeScore = math.min(25, (volC / volBase) * 10)

cleanA = not na(waveA_price) ? 5 : 0
cleanB = not na(waveB_price) ? 5 : 0
cleanC = not na(waveC_price) ? 5 : 0
cleanlinessScore = cleanA + cleanB + cleanC

trendScore = (ma50 < ma200 ? 5 : 0) + (close < ma200 ? 5 : 0)

waveStrength = magnitudeScore + symmetryScore + volumeScore + cleanlinessScore + trendScore
waveStrength := math.min(100, waveStrength)

meterColor =(
    waveStrength >= 80 ? color.green :
    waveStrength >= 60 ? color.lime :
    waveStrength >= 40 ? color.yellow :
    waveStrength >= 20 ? color.orange :
    color.red
)
var table strengthTable = table.new(position.top_right, 1, 2, border_width=1)

if barstate.islast
    table.cell(strengthTable, 0, 0, "Wave Strength", text_color=color.white, bgcolor=color.black)
    table.cell(strengthTable, 0, 1, str.tostring(waveStrength, "#") + "/100",
        text_color=color.white, bgcolor=meterColor)
````
