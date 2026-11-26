# EW Bottom Signals 1.4X VOLUME_strategy

- url: https://www.tradingview.com/script/vMuEblZr-EW-Bottom-Signals-1-4X-VOLUME-strategy/
- type: strategy
- pine_id: PUB;a84af810edf34889a98f5cb2ea39297a
- version: 1.0

## Description

published strategy for backtesting. 📘 Strategy Overview — Built for Long‑Term Investors With Real Lives
This strategy is designed for people who work full‑time, have steady income, and want to grow their wealth without day‑trading, screen‑watching, or trying to guess market bottoms. It’s built for long‑term accounts — retirement or taxable — with an average hold time of about a year.

We wait for a confirmed downtrend and use Elliott Wave theory to identify the final leg of the correction. Once Wave C forms, we enter in three staged buys at the most reliable points of a reversal:

1️⃣ 10% Buy — Capitulation Candle
A high‑volume flush (1.4× 20‑day average) signals panic selling. This gets us in early, but lightly.

2️⃣ 60% Buy — Price Reclaims the 50MA
Momentum shifts upward. This is the heavy buy, catching the first real move off the bottom.

3️⃣ 30% Buy — Golden Cross (50MA > 200MA)
Institutional money typically steps in here. This confirms the new long‑term trend.

We exit only when the 50MA crosses back below the 200MA — a clean, reliable trend‑break signal that avoids noise and protects gains.

This system lets you invest patiently, intelligently, and automatically — without chasing bottoms or watching charts all day. It’s long‑term, disciplined, and built for people who want better returns than passive index investing, with far less stress than active trading.

## Source Code

````pine
//@version=6
strategy("EW Bottom Signals 1.4X VOLUME (Wave Leg Display + ABC Visualization)", 
     overlay=true, initial_capital=10000, pyramiding=3,
     commission_type=strategy.commission.percent, commission_value=0.0)

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

// Store A
if waveA_signal
    waveA_price := swingHigh
    waveA_index := bar_index - zigzagDepth

// Store B
if waveB_signal
    waveB_price := swingLow
    waveB_index := bar_index - zigzagDepth

// Store C
if waveC_signal
    waveC_price := swingHigh
    waveC_index := bar_index - zigzagDepth

// === DRAW ACTIVE ABC LABELS ===

// A label (shown in A, B, C)
if waveState >= 1 and not na(waveA_price)
    label.new(waveA_index, waveA_price, "A",
        style = label.style_label_down,
        color = color.new(color.red, 0),
        textcolor = color.white,
        size = size.large)

// B label (shown in B, C)
if waveState >= 2 and not na(waveB_price)
    label.new(waveB_index, waveB_price, "B",
        style = label.style_label_up,
        color = color.new(color.orange, 0),
        textcolor = color.white,
        size = size.large)

// C label (shown only in C)
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

// === WAVE LEG DISPLAY (TOP LABEL) ===
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

// === BUY/SELL STATE MACHINE ===
var bool allowBuys = false
var bool firstBuyTriggered = false
var bool secondBuyTriggered = false
var bool finalBuyTriggered = false
var bool sellTriggered = false

// === ACTIVATE BUY MODE ONLY WHEN PRICE FALLS BELOW 200MA ===
if (below200 and not allowBuys and not sellTriggered)
    allowBuys := true

// === FIRST BUY ($1,000) ===
inWaveC = waveState == 3

firstBuySignal = (
    allowBuys and
    inWaveC and
    below200 and
    capitulation and
    not firstBuyTriggered
)

if (firstBuySignal)
    firstBuyTriggered := true
    strategy.entry("FIRST BUY", strategy.long, qty=(1000 / close))

// === SECOND BUY ($6,000) ===
cross50 = ta.crossover(close, ma50)

secondBuySignal = (
    allowBuys and
    firstBuyTriggered and
    cross50 and
    not secondBuyTriggered
)

if (secondBuySignal)
    secondBuyTriggered := true
    strategy.entry("50MA BUY", strategy.long, qty=(6000 / close))

// === FINAL BUY ($3,000) — Golden Cross ===
goldenCross = ta.crossover(ma50, ma200)

finalBuySignal = (
    allowBuys and
    secondBuyTriggered and
    goldenCross and
    not finalBuyTriggered
)

if (finalBuySignal)
    finalBuyTriggered := true
    strategy.entry("GOLDEN BUY", strategy.long, qty=(3000 / close))

// === SELL — Death Cross ===
deathCross = ta.crossunder(ma50, ma200)

sellSignal = (
    finalBuyTriggered and
    deathCross and
    not sellTriggered
)

if (sellSignal)
    sellTriggered := true
    strategy.close_all("SELL")
    allowBuys := false
    firstBuyTriggered := false
    secondBuyTriggered := false
    finalBuyTriggered := false

// === RESET SELL TRIGGER WHEN PRICE GOES ABOVE 200MA ===
if (not below200 and sellTriggered)
    sellTriggered := false
// === WAVE STRENGTH SCORE ===

// --- Magnitude ---
magnitudeA = math.abs(waveA_price - waveB_price)
magnitudeC = math.abs(waveC_price - waveB_price)
magnitudeScore = math.min(25, (magnitudeA + magnitudeC) / close * 250)

// --- Symmetry ---
symmetryRatio = magnitudeC / magnitudeA
symmetryScore = (
    symmetryRatio > 0.8 and symmetryRatio < 2.0 ? 25 :
    symmetryRatio > 0.5 and symmetryRatio < 3.0 ? 15 : 5
)

// --- Volume ---
volC = volume[zigzagDepth]
volBase = ta.sma(volume, 20)
volumeScore = math.min(25, (volC / volBase) * 10)

// --- Cleanliness ---
cleanA = not na(waveA_price) ? 5 : 0
cleanB = not na(waveB_price) ? 5 : 0
cleanC = not na(waveC_price) ? 5 : 0
cleanlinessScore = cleanA + cleanB + cleanC  // max 15

// --- Trend Context ---
trendScore = (ma50 < ma200 ? 5 : 0) + (close < ma200 ? 5 : 0)

// --- Final Score ---
waveStrength = magnitudeScore + symmetryScore + volumeScore + cleanlinessScore + trendScore
waveStrength := math.min(100, waveStrength)

// === COLOR METER ===
meterColor =(
    waveStrength >= 80 ? color.green :
    waveStrength >= 60 ? color.lime :
    waveStrength >= 40 ? color.yellow :
    waveStrength >= 20 ? color.orange :
    color.red
)
// === TABLE METER (TOP RIGHT) ===
var table strengthTable = table.new(position.top_right, 1, 2, border_width=1)

if barstate.islast
    table.cell(strengthTable, 0, 0, "Wave Strength", text_color=color.white, bgcolor=color.black)
    table.cell(strengthTable, 0, 1, str.tostring(waveStrength, "#") + "/100",
        text_color=color.white, bgcolor=meterColor)

// === PLOTS ===
plotshape(firstBuySignal, title="FIRST BUY",
     style=shape.labeldown, text="FIRST BUY",
     color=color.yellow, size=size.large)

plotshape(secondBuySignal, title="50MA BUY",
     style=shape.labeldown, text="50MA BUY",
     color=color.orange, size=size.large)

plotshape(finalBuySignal, title="GOLDEN BUY",
     style=shape.labeldown, text="GOLDEN BUY",
     color=color.green, size=size.large)

plotshape(sellSignal, title="SELL",
     style=shape.labelup, text="SELL",
     color=color.red, size=size.large)

plot(ma50,  "MA 50",  color=color.new(color.orange, 60))
plot(ma200, "MA 200", color=color.new(color.green, 60))

// === ALERTS ===
alertcondition(firstBuySignal, "FIRST BUY ALERT", "FIRST BUY triggered — $1,000 position opened on {{ticker}}")
alertcondition(secondBuySignal, "SECOND BUY ALERT", "50MA BUY triggered — $6,000 position added on {{ticker}}")
alertcondition(finalBuySignal, "GOLDEN BUY ALERT", "GOLDEN BUY triggered — $3,000 position added on {{ticker}} (Golden Cross)")
alertcondition(sellSignal, "SELL ALERT", "SELL triggered — Full position closed on {{ticker}} (Death Cross)")
````
