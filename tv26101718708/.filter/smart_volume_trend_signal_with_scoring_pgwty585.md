# Smart Volume Trend Signal with Scoring

- url: https://www.tradingview.com/script/pgWtY585/
- type: indicator
- pine_id: PUB;994756bf16844a44868eb64b211643dc
- version: 1.0

## Description

Bu indikatör, hacim artışı, trend ve momentum kombinasyonunu kullanarak potansiyel alım fırsatlarını tespit eder. Oluşan sinyaller geçmiş veriler üzerinden test edilerek performans analizi yapılır.

## Source Code

````pine
//@version=5
indicator("Akıllı Sinyal V11 - Scoring System", overlay=true)

// === INPUTS ===
rsiThreshold = input.int(52, "RSI Threshold")
emaLength    = input.int(50, "EMA Length")
cooldownBars = input.int(15, "Cooldown")
tradeLength  = input.int(250, "Trade Süresi")
stopLoss     = input.float(10.0, "Stop Loss %")

// =======================
// CORE SIGNAL
// =======================

// Volume (balanced)
avgVol = ta.sma(volume, 20)
volumeSpike = volume > avgVol * 1.3

// Trend
ema50 = ta.ema(close, emaLength)
trend = close > ema50

// Breakout (soft)
breakout = close > ta.highest(high, 20)[1]

// Momentum
rsi = ta.rsi(close, 14)
momentum = rsi > rsiThreshold

// Signal
signalRaw = volumeSpike and breakout and trend and momentum

var int lastSignalBar = na
canSignal = na(lastSignalBar) or (bar_index - lastSignalBar > cooldownBars)

signal = signalRaw and canSignal

if signal
    lastSignalBar := bar_index

// Plot
plot(ema50, color=color.orange)
plotshape(signal, location=location.belowbar, color=color.green, style=shape.labelup, text="AL")

// =======================
// TRADE ENGINE
// =======================

var entryPrices = array.new_float()
var entryBars   = array.new_int()
var maxPrices   = array.new_float()
var minPrices   = array.new_float()

var float totalGain = 0
var float totalDD   = 0
var int totalTrades = 0
var int winCount    = 0

// New trade
if signal
    array.push(entryPrices, close)
    array.push(entryBars, bar_index)
    array.push(maxPrices, close)
    array.push(minPrices, close)

// Update trades
if array.size(entryPrices) > 0
    for i = array.size(entryPrices) - 1 to 0
        entry = array.get(entryPrices, i)
        eBar  = array.get(entryBars, i)
        maxP  = array.get(maxPrices, i)
        minP  = array.get(minPrices, i)

        maxP := math.max(maxP, high)
        minP := math.min(minP, low)

        array.set(maxPrices, i, maxP)
        array.set(minPrices, i, minP)

        dd = (entry - minP) / entry * 100
        gain = (maxP - entry) / entry * 100
        barsPassed = bar_index - eBar

        if dd >= stopLoss or barsPassed >= tradeLength
            totalGain += gain
            totalDD += dd
            totalTrades += 1

            if gain >= 25
                winCount += 1

            array.remove(entryPrices, i)
            array.remove(entryBars, i)
            array.remove(maxPrices, i)
            array.remove(minPrices, i)

// =======================
// METRICS
// =======================

avgGain = totalTrades > 0 ? totalGain / totalTrades : 0
avgDD   = totalTrades > 0 ? totalDD / totalTrades : 0
winRate = totalTrades > 0 ? winCount / totalTrades * 100 : 0
rr      = avgDD > 0 ? avgGain / avgDD : 0

// =======================
// SCORING ENGINE
// =======================

// Win Score
winScore = math.min(winRate / 10, 10)

// RR Score
rrScore = math.min(rr * 2, 10)

// Drawdown Score (inverse)
ddScore = avgDD < 10 ? 10 : avgDD < 20 ? 7 : avgDD < 30 ? 4 : 2

// Gain Score
gainScore = math.min(avgGain / 10, 10)

// Trade Count Score
tradeScore = totalTrades > 30 ? 10 : totalTrades > 15 ? 7 : totalTrades > 10 ? 5 : 3

// Final Score
finalScore =
     winScore * 0.25 +
     rrScore  * 0.30 +
     ddScore  * 0.25 +
     gainScore * 0.10 +
     tradeScore * 0.10

// =======================
// DECISION ENGINE
// =======================

string decision = ""

if finalScore >= 8
    decision := "AGRESIF AL"
else if finalScore >= 6
    decision := "AL"
else if finalScore >= 4
    decision := "DIKKATLI"
else
    decision := "ALMA"

// =======================
// TABLE
// =======================

var table t = table.new(position.top_right, 2, 8)

if barstate.islast
    table.cell(t, 0, 0, "Trades")
    table.cell(t, 1, 0, str.tostring(totalTrades))

    table.cell(t, 0, 1, "Win %")
    table.cell(t, 1, 1, str.tostring(winRate, "#.##"))

    table.cell(t, 0, 2, "Avg Gain")
    table.cell(t, 1, 2, str.tostring(avgGain, "#.##"))

    table.cell(t, 0, 3, "Avg DD")
    table.cell(t, 1, 3, str.tostring(avgDD, "#.##"))

    table.cell(t, 0, 4, "RR")
    table.cell(t, 1, 4, str.tostring(rr, "#.##"))

    table.cell(t, 0, 5, "Score")
    table.cell(t, 1, 5, str.tostring(finalScore, "#.##"))

    table.cell(t, 0, 6, "Decision")
    table.cell(t, 1, 6, decision)
````
