# SK Stable Supertrend Optimizer

- url: https://www.tradingview.com/script/7RANkvQH-SK-Stable-Supertrend-Optimizer/
- type: indicator
- pine_id: PUB;1d3a4413d585485a9e690d40437fca3e
- version: 1.0

## Description

SK Stable Supertrend Optimizer
Author: Shayan Khursheed

SK Stable Supertrend Optimizer is a day-trading Supertrend optimization tool designed to make trend, momentum, and entry quality easy to read at a glance.

The script tests 100 Supertrend combinations bar by bar across different ATR lengths and multipliers. It ranks the results using selectable performance metrics, then highlights both the best single setting and the safer stable parameter zone. The stable zone is designed to help avoid over-optimized settings that only work for one perfect market condition.

The indicator is built for lower timeframes such as 5m, 15m, and 30m. It combines optimized Supertrend direction with a simple momentum score, agreement filter, volatility filter, trend filter, and optional volume confirmation.

Key features:

100 Supertrend parameter combinations
Best setting and stable-zone selection
Heatmap dashboard
Long, short, and wait status
Momentum score from 1/5 to 5/5
Fast and slow momentum EMAs
RSI momentum confirmation
Volume confirmation
Pullback momentum entries
Beginner-friendly BUY, SELL, MOMO, and WAIT signals
Alerts for long and short setups
How to read it:

LONG BIAS means only look for buys.
SHORT BIAS means only look for sells.
WAIT means skip the trade.
MOMO 4/5 or 5/5 means momentum is strong.
Green Supertrend line means bullish support.
Red Supertrend line means bearish resistance.
BEST shows the highest single-performing setting.
SAFE shows the most stable parameter zone.
Simple trading idea:
Use LONG BIAS with strong MOMO to look for pullback buys near the green Supertrend line. Use SHORT BIAS with strong MOMO to look for rally sells near the red Supertrend line. Avoid trades when the dashboard shows WAIT, weak momentum, low agreement, or bad volatility conditions.

This tool is an indicator and optimization assistant, not financial advice or a guarantee of profit. Always backtest, forward-test, and use proper risk management.

## Source Code

````pine
//@version=6
indicator("SK Stable Supertrend Optimizer", "SK ST Optimizer", overlay = true, max_labels_count = 200, max_lines_count = 100, max_bars_back = 5000)

// Apex Stable Supertrend Optimizer
// Built for low-timeframe clarity: find robust Supertrend settings, then show simple trade/no-trade cues.

const int GRID = 10
const int COMBOS = GRID * GRID

const string GROUP_SIGNAL = "1. Easy Trade Signal"
const string GROUP_GRID = "2. Optimization Grid"
const string GROUP_FILTERS = "3. Low Timeframe Filters"
const string GROUP_MOMENTUM = "4. Day Trader Momentum"
const string GROUP_VISUALS = "5. Visuals"
const string GROUP_DASH = "6. Dashboard"

signalMode = input.string("Stable Zone", "Signal uses", options = ["Stable Zone", "Best Single", "Manual"], group = GROUP_SIGNAL)
entryStyle = input.string("Flip + Momentum Pullback", "Entry style", options = ["Flip Only", "Flip + Momentum Pullback"], group = GROUP_SIGNAL)
manualLen = input.int(10, "Manual ATR Length", minval = 1, group = GROUP_SIGNAL)
manualMult = input.float(2.5, "Manual Multiplier", minval = 0.1, step = 0.1, group = GROUP_SIGNAL)
learningBars = input.int(1500, "Learning window bars", minval = 200, maxval = 5000, group = GROUP_SIGNAL)
metric = input.string("Net Profit", "Optimize for", options = ["Win Rate", "Net Profit", "Profit Factor", "Total Trades", "Average Trade", "Reward/Risk Ratio", "Gross Profit", "Total Wins", "Win/Loss Ratio"], group = GROUP_SIGNAL)
minTrades = input.int(8, "Minimum closed trades", minval = 1, maxval = 100, group = GROUP_SIGNAL)

lenStart = input.int(5, "Length Start", minval = 1, group = GROUP_GRID)
lenStep = input.int(2, "Length Step", minval = 1, group = GROUP_GRID)
multStart = input.float(1.0, "Multiplier Start", minval = 0.1, step = 0.1, group = GROUP_GRID)
multStep = input.float(0.25, "Multiplier Step", minval = 0.05, step = 0.05, group = GROUP_GRID)

useEmaFilter = input.bool(true, "Use trend filter", group = GROUP_FILTERS)
emaLen = input.int(200, "Trend EMA Length", minval = 10, group = GROUP_FILTERS)
minConsensus = input.int(58, "Minimum grid agreement %", minval = 1, maxval = 100, group = GROUP_FILTERS)
minAtrPct = input.float(0.03, "Minimum ATR %", minval = 0.0, step = 0.01, group = GROUP_FILTERS)
maxAtrPct = input.float(3.00, "Maximum ATR %", minval = 0.1, step = 0.05, group = GROUP_FILTERS)
cooldownBars = input.int(3, "Signal cooldown bars", minval = 0, maxval = 50, group = GROUP_FILTERS)

useMomentum = input.bool(true, "Use momentum filter", group = GROUP_MOMENTUM)
fastMomentumLen = input.int(9, "Fast EMA", minval = 2, maxval = 100, group = GROUP_MOMENTUM)
slowMomentumLen = input.int(21, "Slow EMA", minval = 3, maxval = 200, group = GROUP_MOMENTUM)
rsiLen = input.int(14, "RSI Length", minval = 2, maxval = 100, group = GROUP_MOMENTUM)
longRsiMin = input.float(52.0, "Long RSI minimum", minval = 1.0, maxval = 99.0, step = 0.5, group = GROUP_MOMENTUM)
shortRsiMax = input.float(48.0, "Short RSI maximum", minval = 1.0, maxval = 99.0, step = 0.5, group = GROUP_MOMENTUM)
useVolumeConfirm = input.bool(true, "Require volume confirmation", group = GROUP_MOMENTUM)
volumeLen = input.int(20, "Volume average length", minval = 2, maxval = 200, group = GROUP_MOMENTUM)
minMomentumScore = input.int(4, "Minimum momentum score", minval = 1, maxval = 5, group = GROUP_MOMENTUM)

showLine = input.bool(true, "Show adaptive Supertrend", group = GROUP_VISUALS)
showSignals = input.bool(true, "Show entry markers", group = GROUP_VISUALS)
showTrendEma = input.bool(false, "Show trend EMA", group = GROUP_VISUALS)
showMomentumEma = input.bool(true, "Show momentum EMAs", group = GROUP_VISUALS)
showStatusLabel = input.bool(true, "Show easy status label", group = GROUP_VISUALS)
longColor = input.color(color.rgb(0, 180, 120), "Long color", group = GROUP_VISUALS)
shortColor = input.color(color.rgb(235, 74, 74), "Short color", group = GROUP_VISUALS)
stableColor = input.color(color.rgb(29, 120, 255), "Stable-zone color", group = GROUP_VISUALS)
bestColor = input.color(color.rgb(255, 190, 40), "Best-cell color", group = GROUP_VISUALS)
neutralColor = input.color(color.rgb(130, 135, 145), "Neutral color", group = GROUP_VISUALS)

showDash = input.bool(true, "Enable dashboard", group = GROUP_DASH)
dashPosInput = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_DASH)
compactDash = input.bool(false, "Compact heatmap text", group = GROUP_DASH)

var array<float> atrs = array.new_float(COMBOS, na)
var array<float> upperBands = array.new_float(COMBOS, na)
var array<float> lowerBands = array.new_float(COMBOS, na)
var array<float> stops = array.new_float(COMBOS, na)
var array<int> dirs = array.new_int(COMBOS, 1)
var array<float> entries = array.new_float(COMBOS, na)
var array<float> grossProfits = array.new_float(COMBOS, 0.0)
var array<float> grossLosses = array.new_float(COMBOS, 0.0)
var array<float> totalReturns = array.new_float(COMBOS, 0.0)
var array<float> winSums = array.new_float(COMBOS, 0.0)
var array<float> lossSums = array.new_float(COMBOS, 0.0)
var array<int> wins = array.new_int(COMBOS, 0)
var array<int> losses = array.new_int(COMBOS, 0)
var array<int> trades = array.new_int(COMBOS, 0)
var array<float> scores = array.new_float(COMBOS, 0.0)

dashPosition(string p) =>
    switch p
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

resetStats() =>
    for i = 0 to COMBOS - 1
        array.set(entries, i, na)
        array.set(grossProfits, i, 0.0)
        array.set(grossLosses, i, 0.0)
        array.set(totalReturns, i, 0.0)
        array.set(winSums, i, 0.0)
        array.set(lossSums, i, 0.0)
        array.set(wins, i, 0)
        array.set(losses, i, 0)
        array.set(trades, i, 0)
        array.set(scores, i, 0.0)

comboLength(int row) =>
    lenStart + row * lenStep

comboMult(int col) =>
    multStart + col * multStep

metricValue(int i) =>
    int t = array.get(trades, i)
    int w = array.get(wins, i)
    int l = array.get(losses, i)
    float gp = array.get(grossProfits, i)
    float gl = array.get(grossLosses, i)
    float total = array.get(totalReturns, i)
    float avgWin = w > 0 ? array.get(winSums, i) / w : 0.0
    float avgLoss = l > 0 ? array.get(lossSums, i) / l : 0.0
    float value = switch metric
        "Win Rate" => t > 0 ? (w / t) * 100.0 : 0.0
        "Profit Factor" => gl > 0.0 ? gp / gl : gp > 0.0 ? 99.0 : 0.0
        "Total Trades" => t * 1.0
        "Average Trade" => t > 0 ? total / t : 0.0
        "Reward/Risk Ratio" => avgLoss > 0.0 ? avgWin / avgLoss : avgWin > 0.0 ? 99.0 : 0.0
        "Gross Profit" => gp
        "Total Wins" => w * 1.0
        "Win/Loss Ratio" => l > 0 ? w / l : w > 0 ? 99.0 : 0.0
        => gp - gl
    t >= minTrades ? value : na

heatColor(float value, float low, float high, bool isBest, bool isStable) =>
    if isBest
        color.new(bestColor, 0)
    else if isStable
        color.new(stableColor, 0)
    else if na(value) or high == low
        color.new(neutralColor, 80)
    else
        float ratio = math.max(0.0, math.min(1.0, (value - low) / (high - low)))
        color.from_gradient(ratio, 0.0, 1.0, color.rgb(150, 35, 45), color.rgb(25, 165, 115))

gradeText(float value, float low, float high) =>
    if na(value) or high == low
        "-"
    else
        float ratio = math.max(0.0, math.min(1.0, (value - low) / (high - low)))
        ratio >= 0.90 ? "A+" : ratio >= 0.75 ? "A" : ratio >= 0.60 ? "B" : ratio >= 0.40 ? "C" : ratio >= 0.20 ? "D" : "F"

formatMetric(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

float tr = ta.tr(true)
bool inWindow = bar_index >= math.max(0, last_bar_index - learningBars)

if inWindow and not inWindow[1]
    resetStats()

for row = 0 to GRID - 1
    for col = 0 to GRID - 1
        int i = row * GRID + col
        int len = comboLength(row)
        float mult = comboMult(col)
        float prevAtr = array.get(atrs, i)
        float atr = na(prevAtr) ? tr : prevAtr + (tr - prevAtr) / len
        float basicUpper = hl2 + mult * atr
        float basicLower = hl2 - mult * atr
        float prevUpper = array.get(upperBands, i)
        float prevLower = array.get(lowerBands, i)
        int prevDir = array.get(dirs, i)
        float finalUpper = na(prevUpper) or basicUpper < prevUpper or nz(close[1], close) > prevUpper ? basicUpper : prevUpper
        float finalLower = na(prevLower) or basicLower > prevLower or nz(close[1], close) < prevLower ? basicLower : prevLower
        int dir = prevDir
        if prevDir == -1 and close > finalUpper
            dir := 1
        else if prevDir == 1 and close < finalLower
            dir := -1
        float stop = dir == 1 ? finalLower : finalUpper

        if inWindow
            float entry = array.get(entries, i)
            if na(entry)
                array.set(entries, i, close)
            else if dir != prevDir
                float tradeReturn = prevDir == 1 ? ((close - entry) / entry) * 100.0 : ((entry - close) / entry) * 100.0
                array.set(totalReturns, i, array.get(totalReturns, i) + tradeReturn)
                array.set(trades, i, array.get(trades, i) + 1)
                if tradeReturn > 0
                    array.set(wins, i, array.get(wins, i) + 1)
                    array.set(grossProfits, i, array.get(grossProfits, i) + tradeReturn)
                    array.set(winSums, i, array.get(winSums, i) + tradeReturn)
                else
                    float absLoss = math.abs(tradeReturn)
                    array.set(losses, i, array.get(losses, i) + 1)
                    array.set(grossLosses, i, array.get(grossLosses, i) + absLoss)
                    array.set(lossSums, i, array.get(lossSums, i) + absLoss)
                array.set(entries, i, close)

        array.set(atrs, i, atr)
        array.set(upperBands, i, finalUpper)
        array.set(lowerBands, i, finalLower)
        array.set(stops, i, stop)
        array.set(dirs, i, dir)
        array.set(scores, i, metricValue(i))

float bestScore = na
int bestIdx = 0
float lowScore = na
float highScore = na

for i = 0 to COMBOS - 1
    float score = array.get(scores, i)
    if not na(score)
        bestIdx := na(bestScore) or score > bestScore ? i : bestIdx
        bestScore := na(bestScore) or score > bestScore ? score : bestScore
        lowScore := na(lowScore) or score < lowScore ? score : lowScore
        highScore := na(highScore) or score > highScore ? score : highScore

float stableScore = na
int stableIdx = bestIdx

for row = 1 to GRID - 2
    for col = 1 to GRID - 2
        float sumScore = 0.0
        int scoreCount = 0
        for rr = row - 1 to row + 1
            for cc = col - 1 to col + 1
                int ni = rr * GRID + cc
                float neighborScore = array.get(scores, ni)
                if not na(neighborScore)
                    sumScore += neighborScore
                    scoreCount += 1
        float avgScore = scoreCount == 9 ? sumScore / 9.0 : na
        stableIdx := not na(avgScore) and (na(stableScore) or avgScore > stableScore) ? row * GRID + col : stableIdx
        stableScore := not na(avgScore) and (na(stableScore) or avgScore > stableScore) ? avgScore : stableScore

int selectedIdx = signalMode == "Best Single" ? bestIdx : stableIdx
int selectedRow = int(math.floor(selectedIdx / GRID))
int selectedCol = selectedIdx % GRID
int selectedLen = comboLength(selectedRow)
float selectedMult = comboMult(selectedCol)

float manualAtr = ta.atr(manualLen)
var float manualUpperBand = na
var float manualLowerBand = na
var int manualDir = 1
float manualBasicUpper = hl2 + manualMult * manualAtr
float manualBasicLower = hl2 - manualMult * manualAtr
manualUpperBand := na(manualUpperBand[1]) or manualBasicUpper < manualUpperBand[1] or nz(close[1], close) > manualUpperBand[1] ? manualBasicUpper : manualUpperBand[1]
manualLowerBand := na(manualLowerBand[1]) or manualBasicLower > manualLowerBand[1] or nz(close[1], close) < manualLowerBand[1] ? manualBasicLower : manualLowerBand[1]
int prevManualDir = nz(manualDir[1], 1)
manualDir := prevManualDir
if prevManualDir == -1 and close > manualUpperBand
    manualDir := 1
else if prevManualDir == 1 and close < manualLowerBand
    manualDir := -1
float manualStop = manualDir == 1 ? manualLowerBand : manualUpperBand

int activeDir = signalMode == "Manual" ? manualDir : array.get(dirs, selectedIdx)
float activeStop = signalMode == "Manual" ? manualStop : array.get(stops, selectedIdx)
int activeLen = signalMode == "Manual" ? manualLen : selectedLen
float activeMult = signalMode == "Manual" ? manualMult : selectedMult

int agree = 0
for i = 0 to COMBOS - 1
    agree += array.get(dirs, i) == activeDir ? 1 : 0
float agreementPct = (agree / COMBOS) * 100.0

float trendEma = ta.ema(close, emaLen)
float fastMomentumEma = ta.ema(close, fastMomentumLen)
float slowMomentumEma = ta.ema(close, slowMomentumLen)
float rsi = ta.rsi(close, rsiLen)
float volumeAvg = ta.sma(volume, volumeLen)
float atrPct = close != 0.0 ? (manualAtr / close) * 100.0 : 0.0
bool volatilityOk = atrPct >= minAtrPct and atrPct <= maxAtrPct
bool trendOkLong = not useEmaFilter or close > trendEma
bool trendOkShort = not useEmaFilter or close < trendEma
bool consensusOk = agreementPct >= minConsensus
bool volumeOk = not useVolumeConfirm or volume >= volumeAvg
int longMomentumScore = (close > fastMomentumEma ? 1 : 0) + (fastMomentumEma > slowMomentumEma ? 1 : 0) + (rsi >= longRsiMin ? 1 : 0) + (close > close[1] ? 1 : 0) + (volumeOk ? 1 : 0)
int shortMomentumScore = (close < fastMomentumEma ? 1 : 0) + (fastMomentumEma < slowMomentumEma ? 1 : 0) + (rsi <= shortRsiMax ? 1 : 0) + (close < close[1] ? 1 : 0) + (volumeOk ? 1 : 0)
bool momentumOkLong = not useMomentum or longMomentumScore >= minMomentumScore
bool momentumOkShort = not useMomentum or shortMomentumScore >= minMomentumScore
bool activeMomentumOk = activeDir == 1 ? momentumOkLong : momentumOkShort
bool ready = not na(bestScore) and consensusOk and volatilityOk and activeMomentumOk

var int lastSignalBar = na
bool cooldownOk = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
bool flipLong = activeDir == 1 and activeDir[1] == -1
bool flipShort = activeDir == -1 and activeDir[1] == 1
bool pullbackLong = entryStyle == "Flip + Momentum Pullback" and activeDir == 1 and activeDir[1] == 1 and ta.crossover(close, fastMomentumEma) and close > slowMomentumEma
bool pullbackShort = entryStyle == "Flip + Momentum Pullback" and activeDir == -1 and activeDir[1] == -1 and ta.crossunder(close, fastMomentumEma) and close < slowMomentumEma
bool longSignal = (flipLong or pullbackLong) and trendOkLong and momentumOkLong and ready and cooldownOk
bool shortSignal = (flipShort or pullbackShort) and trendOkShort and momentumOkShort and ready and cooldownOk

if longSignal or shortSignal
    lastSignalBar := bar_index

color activeColor = activeDir == 1 ? longColor : shortColor
plot(showLine ? activeStop : na, "Adaptive Supertrend", color = activeColor, linewidth = 2, style = plot.style_linebr)
plot(showTrendEma ? trendEma : na, "Trend EMA", color = color.new(neutralColor, 15), linewidth = 1)
plot(showMomentumEma ? fastMomentumEma : na, "Fast Momentum EMA", color = color.new(color.aqua, 0), linewidth = 1)
plot(showMomentumEma ? slowMomentumEma : na, "Slow Momentum EMA", color = color.new(color.orange, 0), linewidth = 1)
plotshape(showSignals and longSignal and flipLong, "Long flip signal", shape.triangleup, location.belowbar, color = longColor, text = "BUY", textcolor = color.white, size = size.small)
plotshape(showSignals and longSignal and pullbackLong, "Long momentum signal", shape.triangleup, location.belowbar, color = longColor, text = "MOMO", textcolor = color.white, size = size.small)
plotshape(showSignals and shortSignal and flipShort, "Short flip signal", shape.triangledown, location.abovebar, color = shortColor, text = "SELL", textcolor = color.white, size = size.small)
plotshape(showSignals and shortSignal and pullbackShort, "Short momentum signal", shape.triangledown, location.abovebar, color = shortColor, text = "MOMO", textcolor = color.white, size = size.small)
barcolor(ready ? color.new(activeColor, 80) : na)

alertcondition(longSignal, "Apex Supertrend Long", "Apex Stable Supertrend Optimizer: BUY signal on {{ticker}} {{interval}}")
alertcondition(shortSignal, "Apex Supertrend Short", "Apex Stable Supertrend Optimizer: SELL signal on {{ticker}} {{interval}}")

string tradeState = ready ? (activeDir == 1 ? "LONG BIAS" : "SHORT BIAS") : "WAIT"
string momentumText = activeDir == 1 ? str.tostring(longMomentumScore) + "/5" : str.tostring(shortMomentumScore) + "/5"
string blockReason = not volatilityOk ? "ATR filter" : not consensusOk ? "low agreement" : not activeMomentumOk ? "weak momentum" : na(bestScore) ? "learning" : "ok"
string selectedName = signalMode == "Manual" ? "Manual" : signalMode == "Best Single" ? "Best" : "Stable"
string statusText = tradeState + "\n" + selectedName + " ST " + str.tostring(activeLen) + " x " + str.tostring(activeMult, "#.##") + "\nAgree " + str.tostring(agreementPct, "#") + "% | MOMO " + momentumText + " | " + blockReason

var label statusLabel = na
if showStatusLabel and barstate.islast
    label.delete(statusLabel)
    statusLabel := label.new(bar_index, activeDir == 1 ? low : high, statusText, style = activeDir == 1 ? label.style_label_up : label.style_label_down, textcolor = color.white, color = ready ? color.new(activeColor, 0) : color.new(neutralColor, 15), size = size.normal)

var table dash = table.new(dashPosition(dashPosInput), 12, 16, border_width = 1)

if showDash and barstate.islast
    table.clear(dash, 0, 0, 11, 15)
    color headerBg = color.rgb(22, 26, 33)
    color panelBg = color.rgb(35, 40, 50)
    color textFg = color.white
    table.cell(dash, 0, 0, "Apex ST", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 1, 0, tradeState, text_color = textFg, bgcolor = ready ? color.new(activeColor, 0) : color.new(neutralColor, 0))
    table.cell(dash, 2, 0, "Mode", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 3, 0, selectedName, text_color = textFg, bgcolor = panelBg)
    table.cell(dash, 4, 0, "Metric", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 5, 0, metric, text_color = textFg, bgcolor = panelBg)
    table.cell(dash, 6, 0, "Best", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 7, 0, formatMetric(bestScore), text_color = textFg, bgcolor = color.new(bestColor, 0))
    table.cell(dash, 8, 0, "Stable", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 9, 0, formatMetric(stableScore), text_color = textFg, bgcolor = color.new(stableColor, 0))
    table.cell(dash, 10, 0, "Bars", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 11, 0, str.tostring(learningBars), text_color = textFg, bgcolor = panelBg)

    table.cell(dash, 0, 1, "Use", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 1, 1, "Len", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 2, 1, str.tostring(activeLen), text_color = textFg, bgcolor = panelBg)
    table.cell(dash, 3, 1, "Mult", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 4, 1, str.tostring(activeMult, "#.##"), text_color = textFg, bgcolor = panelBg)
    table.cell(dash, 5, 1, "Agree", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 6, 1, str.tostring(agreementPct, "#") + "%", text_color = textFg, bgcolor = consensusOk ? color.new(longColor, 15) : color.new(shortColor, 15))
    table.cell(dash, 7, 1, "ATR%", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 8, 1, str.tostring(atrPct, "#.##"), text_color = textFg, bgcolor = volatilityOk ? color.new(longColor, 15) : color.new(shortColor, 15))
    table.cell(dash, 9, 1, "MOMO", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 10, 1, momentumText, text_color = textFg, bgcolor = activeMomentumOk ? color.new(longColor, 20) : color.new(shortColor, 20))
    table.cell(dash, 11, 1, blockReason, text_color = textFg, bgcolor = ready and activeMomentumOk ? color.new(longColor, 25) : color.new(shortColor, 20))

    table.cell(dash, 0, 2, "Len \\ Mult", text_color = textFg, bgcolor = headerBg)
    for col = 0 to GRID - 1
        table.cell(dash, col + 1, 2, str.tostring(comboMult(col), "#.##"), text_color = textFg, bgcolor = headerBg)

    for row = 0 to GRID - 1
        table.cell(dash, 0, row + 3, str.tostring(comboLength(row)), text_color = textFg, bgcolor = headerBg)
        for col = 0 to GRID - 1
            int i = row * GRID + col
            float score = array.get(scores, i)
            bool isBest = i == bestIdx
            bool isStable = i == stableIdx
            string cellText = compactDash ? gradeText(score, lowScore, highScore) : isBest ? "BEST" : isStable ? "SAFE" : gradeText(score, lowScore, highScore)
            string tip = "Length: " + str.tostring(comboLength(row)) + "\nMultiplier: " + str.tostring(comboMult(col), "#.##") + "\n" + metric + ": " + formatMetric(score) + "\nTrades: " + str.tostring(array.get(trades, i)) + "\nWins: " + str.tostring(array.get(wins, i)) + "\nLosses: " + str.tostring(array.get(losses, i))
            table.cell(dash, col + 1, row + 3, cellText, text_color = textFg, bgcolor = heatColor(score, lowScore, highScore, isBest, isStable), tooltip = tip)

    table.cell(dash, 0, 14, "Rule", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 1, 14, activeDir == 1 ? "Green + MOMO: buy pullbacks." : "Red + MOMO: sell rallies.", text_color = textFg, bgcolor = panelBg)
    for col = 2 to 11
        table.cell(dash, col, 14, "", text_color = textFg, bgcolor = panelBg)
    table.cell(dash, 0, 15, "Wait", text_color = textFg, bgcolor = headerBg)
    table.cell(dash, 1, 15, "Skip WAIT / weak / ATR / MOMO.", text_color = textFg, bgcolor = panelBg)
    for col = 2 to 11
        table.cell(dash, col, 15, "", text_color = textFg, bgcolor = panelBg)

if not showDash and barstate.islast
    table.clear(dash, 0, 0, 11, 15)
````
