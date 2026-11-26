# Quantum Pulse AI V6 [Nifty AI Scalper]

- url: https://www.tradingview.com/script/9iHO83wh-Quantum-Pulse-AI-V6-Nifty-AI-Scalper/
- type: indicator
- pine_id: PUB;ec684926448f4cb785794e1654319997
- version: 1.0

## Description

High-Level Overview
This script is a hybrid trading system that combines traditional trend-following indicators with a k-Nearest Neighbors (k-NN) Machine Learning engine. Instead of relying solely on hardcoded crossovers, it looks at the current market conditions, searches its historical memory for similar moments, and predicts the next move based on what happened in the past.

1. The Technical Foundation (Base Features)
Before the AI even kicks in, the script tracks a robust baseline of institutional-grade metrics:

Moving Averages: Two customizable MAs (SMA/EMA/VWMA) determine short-term momentum.

VWAP & Bands: Anchored daily VWAP with up to 3 standard deviation bands to judge institutional value and overbought/oversold extremes.

Trend Smoothing: Hull Moving Average (HMA) and Supertrend dictate the broader directional bias.

Momentum Filters: ADX ensures the market is actually trending (ignoring chop), while relative volume tracks participation.

2. The AI k-NN Classification Engine
This is the "brain" of the script. It uses a mathematical algorithm to predict price direction based on Euclidean geometry.

Feature Vectors: It takes 4 real-time data points (MA spread, Price vs. VWAP, HMA slope, and Relative Volume) and normalizes them into a 4-dimensional spatial grid.

Historical Scanning: The script looks back in time (e.g., 2,000 bars) and calculates the exact geometric distance between the current market conditions and historical market conditions.

Voting System: It isolates the k closest historical matches (e.g., the 8 most similar moments in the past). It then looks at what price actually did next in those historical moments (went up or went down). Those neighbors "vote" on the current probability, generating a Bull/Bear Confidence Percentage.

3. Signal Filtering & State Tracking (Anti-Flicker)
The script includes strict logic to prevent chart clutter and false signals:

Convergence: A signal will only fire if the AI probability is above your defined threshold (e.g., 70%), the ADX shows a strong trend, and price is structurally on the correct side of the VWAP.

State Tracker: A built-in memory state (currentTradeState) forces strict alternation. Once an "AI BUY" fires, the system locks into a Long state. It will ignore any duplicate bullish spikes and will only fire again when an "AI SELL" conditions are met.

4. Dashboards & UI
Core Dashboard: A bottom-center panel that gives a rapid visual summary of all traditional metrics (Price, VWAP, MA, HMA, ST, ADX, Volume).

ML Ensemble Panel: A top-right heads-up display showing the AI's exact live confidence percentages, its grading scale (A+, A, B, C), and the current active forecast.

Day Trading Extras: Automatically plots Previous Day High/Low/Close, daily Pivot points, Support/Resistance levels, and the critical First 15-Minute High/Low breakout zones.

## Source Code

````pine
//@version=6
// © Harry_Bhullar | Quantum Pulse AI V6  [Nifty AI Scalper Edition]

indicator('Quantum Pulse AI V6 [Nifty AI Scalper]', overlay = true, max_labels_count = 500, max_bars_back = 5000)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 1 — Moving Average Function
// ═══════════════════════════════════════════════════════════════════════════
ma(source, length, maType) =>
    switch maType
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'VWMA' => ta.vwma(source, length)
        => na

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS (Nifty Scalper Defaults)
// ═══════════════════════════════════════════════════════════════════════════
show_ma1 = input.bool(true, 'MA #1', inline = 'MA #1')
ma1_type = input.string('EMA', '', inline = 'MA #1', options = ['SMA', 'EMA', 'VWMA'])
ma1_source = input.source(ohlc4, '', inline = 'MA #1')
ma1_length = input.int(9, '', inline = 'MA #1', minval = 1)

show_ma2 = input.bool(true, 'MA #2', inline = 'MA #2')
ma2_type = input.string('EMA', '', inline = 'MA #2', options = ['SMA', 'EMA', 'VWMA'])
ma2_source = input.source(ohlc4, '', inline = 'MA #2')
ma2_length = input.int(21, '', inline = 'MA #2', minval = 1)

hmaLen = input.int(21, title = 'HMA Length', minval = 1) // Optimized for 3m/5m
stLen = input.int(10, title = 'Supertrend Length', minval = 1) // Optimized for momentum
stMult = input.float(2.0, title = 'Supertrend Multiplier', minval = 0.1, step = 0.1) // Optimized for tighter stops

adxLen = input.int(10, title = 'ADX Length', minval = 1, group = 'Signal Filters') // Faster response
adxThreshold = input.float(25.0, title = 'ADX Threshold', minval = 1.0, group = 'Signal Filters') // Stricter chop filter

showVWAPBands = input.bool(true, 'Show VWAP Bands', group = 'Visibility')
showDashboard = input.bool(true, 'Show Dashboard', group = 'Visibility')
showCrossMarkers = input.bool(true, 'Show Cross Markers', group = 'Visibility')
showSupertrend = input.bool(true, 'Show Supertrend', group = 'Visibility')
showHMA = input.bool(true, 'Show HMA', group = 'Visibility')
showFirst15 = input.bool(true, 'Show First 15-Min H/L', group = 'Visibility')

// Machine Learning AI Configurations (Nifty Optimized)
useML = input.bool(true, 'Enable AI k-NN Engine', group = 'Machine Learning AI')
k_neighbors = input.int(9, 'Number of Neighbors (k)', group = 'Machine Learning AI', minval = 1, maxval = 20) // Odd number prevents ties
memory_lookback = input.int(2000, 'AI Historical Lookback Window', group = 'Machine Learning AI', minval = 200, maxval = 5000)
confidenceThreshold = input.int(75, 'AI Confidence Threshold (%)', group = 'Machine Learning AI', minval = 50, maxval = 100) // Stricter accuracy requirement
showConfLabels = input.bool(true, 'Show AI Confidence Labels', group = 'Machine Learning AI')
showMLDashboard = input.bool(true, 'Show AI Probability Panel', group = 'Machine Learning AI')

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 3 — CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════
maFast = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
maSlow = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na

newDay = ta.change(time('D')) != 0
[vwap, upper_raw, _] = ta.vwap(hlc3, newDay, 1)
stdev = upper_raw - vwap

upper1 = vwap + stdev
lower1 = vwap - stdev
upper2 = vwap + stdev * 2
lower2 = vwap - stdev * 2
upper3 = vwap + stdev * 3
lower3 = vwap - stdev * 3

isReady = not na(maFast) and not na(maSlow) and not na(vwap)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 4 — DAILY LEVELS
// ═══════════════════════════════════════════════════════════════════════════
[prevH, prevL, prevC] = request.security(syminfo.tickerid, 'D', [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

prange = prevH - prevL
pivot = (prevH + prevL + prevC) / 3
r1 = prevC + prange * 0.55
r2 = prevC + prange * 1.1
s1 = prevC - prange * 0.55
s2 = prevC - prange * 1.1
UT = prevC + prange * 0.75
LT = prevC - prange * 0.75

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 5 — INDICATORS (HMA & SUPERTREND)
// ═══════════════════════════════════════════════════════════════════════════
hma = ta.hma(close, hmaLen)
hmaBull = hma > hma[2] and close > hma
hmaBear = hma < hma[2] and close < hma

[supertrend, direction] = ta.supertrend(stMult, stLen)
stBull = direction == -1
stBear = direction == 1

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 5B — FIRST 15-MINUTE HIGH / LOW 
// ═══════════════════════════════════════════════════════════════════════════
sessionOpen = not na(time('D', '0915-0930'))
newSession = ta.change(time('D')) != 0

var float first15High = na
var float first15Low = na
var bool first15Done = false
var int currentDayTime = na

if newSession
    first15High := na
    first15Low := na
    first15Done := false
    currentDayTime := time
    currentDayTime

if sessionOpen and not first15Done
    first15High := na(first15High) ? high : math.max(first15High, high)
    first15Low := na(first15Low) ? low : math.min(first15Low, low)
    first15Low

if not sessionOpen and not na(first15High) and not first15Done
    first15Done := true
    first15Done

isCurrentDay = not na(currentDayTime) and time >= currentDayTime

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 6 — CONDITIONS & SIGNALS
// ═══════════════════════════════════════════════════════════════════════════
maUp = maFast > maSlow
maDown = maFast < maSlow
aboveVwap = close > vwap and maFast > vwap
belowVwap = close < vwap and maFast < vwap

bullCross = isReady and ta.crossover(maFast, maSlow)
bearCross = isReady and ta.crossunder(maFast, maSlow)
vwapBullCross = isReady and ta.crossover(maFast, vwap)
vwapBearCross = isReady and ta.crossunder(maFast, vwap)

[_, _di_minus, adxValue] = ta.dmi(adxLen, adxLen)
trendStrong = adxValue > adxThreshold

relVol = volume / ta.sma(volume, 20)
highVolume = relVol > 1.2

// Legacy baseline states initialized first so the AI can use them as fallbacks
longState = maUp and aboveVwap and hmaBull and stBull and trendStrong and highVolume
shortState = maDown and belowVwap and hmaBear and stBear and trendStrong and highVolume

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 6A — ARTIFICIAL INTELLIGENCE: FEATURE VECTOR ENGINEERING
// ═══════════════════════════════════════════════════════════════════════════
atrLen = 14
atrVal = ta.atr(atrLen)
atrSafe = na(atrVal) or atrVal == 0 ? 1.0 : atrVal

f_norm(x, scale) =>
    math.max(-1.0, math.min(1.0, x / scale))

// The 4 spatial dimensions the AI maps out onto historical coordinates
f1 = f_norm(maFast - maSlow, atrSafe * 2.0)
f2 = f_norm(close - vwap, atrSafe * 3.0)
f3 = f_norm(hma - hma[2], atrSafe * 1.5)
f4 = math.min(1.0, relVol / 3.0)

// Real-time calculation of historical direction vectors (Classifier ground-truth label)
classLabel = close[4] > close[8] ? 1 : close[4] < close[8] ? -1 : 0

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 6B — AI k-NEAREST NEIGHBORS (k-NN) CORE PREDICTION ENGINE
// ═══════════════════════════════════════════════════════════════════════════
var array<int> neighborDirections = array.new_int(0)
var array<float> neighborDistances = array.new_float(0)

// Memory registers to prevent recalculations
var float bullConfidence = 0.0
var float bearConfidence = 0.0

if useML and bar_index > memory_lookback
    array.clear(neighborDirections)
    array.clear(neighborDistances)

    // Scan backwards through chart memory window
    for i = 1 to memory_lookback by 1
        // Euclidean Spatial Distance calculation between current bar and historical bar [i]
        float d1 = math.pow(f1 - f1[i], 2)
        float d2 = math.pow(f2 - f2[i], 2)
        float d3 = math.pow(f3 - f3[i], 2)
        float d4 = math.pow(f4 - f4[i], 2)
        float currentDistance = math.sqrt(d1 + d2 + d3 + d4)

        // Sorting mechanics: insertion algorithm to keep track of the closest k neighbors
        if array.size(neighborDistances) < k_neighbors
            array.push(neighborDistances, currentDistance)
            array.push(neighborDirections, classLabel[i])
        else
            float maxDist = array.max(neighborDistances)
            int maxIdx = array.indexof(neighborDistances, maxDist)
            if currentDistance < maxDist
                array.set(neighborDistances, maxIdx, currentDistance)
                array.set(neighborDirections, maxIdx, classLabel[i])

    // Sum matching votes from the neural neighbors
    int bullVotes = 0
    int bearVotes = 0
    for j = 0 to array.size(neighborDirections) - 1 by 1
        int vote = array.get(neighborDirections, j)
        if vote == 1
            bullVotes := bullVotes + 1
            bullVotes
        if vote == -1
            bearVotes := bearVotes + 1
            bearVotes

    totalNeighbors = math.max(1, array.size(neighborDirections))
    bullConfidence := bullVotes / totalNeighbors * 100.0
    bearConfidence := bearVotes / totalNeighbors * 100.0
    bearConfidence
else if not useML
    // Fallback scoring if AI is switched off
    bullConfidence := longState ? 85.0 : 0.0
    bearConfidence := shortState ? 85.0 : 0.0
    bearConfidence

f_grade(conf) =>
    conf >= 85 ? 'A+' : conf >= 75 ? 'A' : conf >= 65 ? 'B' : conf >= 50 ? 'C' : '–'

bullGrade = f_grade(bullConfidence)
bearGrade = f_grade(bearConfidence)

f_confColor(conf, isBull) =>
    base_hi = isBull ? color.rgb(0, 180, 60) : color.rgb(200, 0, 40)
    base_med = isBull ? color.rgb(80, 220, 80) : color.rgb(240, 80, 80)
    base_lo = color.yellow
    base_na = color.gray
    conf >= 85 ? base_hi : conf >= 75 ? base_med : conf >= 50 ? base_lo : base_na // Updated threshold mapping to match the new 75% limit conf >= 50 ? base_lo  : base_na

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 6C — FINAL SIGNALS & STATE FILTERING
// ═══════════════════════════════════════════════════════════════════════════
aiLongState = bullConfidence >= confidenceThreshold and close > vwap and trendStrong
aiShortState = bearConfidence >= confidenceThreshold and close < vwap and trendStrong

aiLongSignal = aiLongState and not aiLongState[1]
aiShortSignal = aiShortState and not aiShortState[1]

legacyLong = longState and not longState[1]
legacyShort = shortState and not shortState[1]

rawLongSignal = useML ? aiLongSignal : legacyLong
rawShortSignal = useML ? aiShortSignal : legacyShort

// --- Anti-Flicker State Tracker ---
var int currentTradeState = 0 // 1 = Long, -1 = Short, 0 = Flat

finalLongSignal = rawLongSignal and currentTradeState != 1
finalShortSignal = rawShortSignal and currentTradeState != -1

if finalLongSignal
    currentTradeState := 1
    currentTradeState
if finalShortSignal
    currentTradeState := -1
    currentTradeState

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 7 — COLORS & DASHBOARDS
// ═══════════════════════════════════════════════════════════════════════════
c_green = color.green
c_red = color.red
c_gray = color.gray
c_white = color.white
c_orange = color.orange

hmaColor = hmaBull ? c_green : hmaBear ? c_red : c_gray
stColor = stBull ? c_green : c_red
maColor = maUp ? c_green : maDown ? c_red : c_orange
vwapColor = aboveVwap ? c_green : belowVwap ? c_red : c_orange
priceColor = close > close[1] ? c_green : close < close[1] ? c_red : c_orange
adxColor = trendStrong ? c_green : c_orange
volColor = highVolume ? c_green : c_red

if showDashboard and barstate.islast
    var table dash = table.new(position.bottom_center, 7, 2, border_width = 1)
    table.cell(dash, 0, 0, 'PRICE', text_color = c_white, bgcolor = c_gray)
    table.cell(dash, 1, 0, 'VWAP', text_color = c_white, bgcolor = c_gray)
    table.cell(dash, 2, 0, 'MA', text_color = c_white, bgcolor = c_gray)
    table.cell(dash, 3, 0, 'HMA', text_color = c_white, bgcolor = c_gray)
    table.cell(dash, 4, 0, 'ST', text_color = c_white, bgcolor = c_gray)
    table.cell(dash, 5, 0, 'ADX', text_color = c_white, bgcolor = c_gray)
    table.cell(dash, 6, 0, 'VOLUME', text_color = c_white, bgcolor = c_gray)
    table.cell(dash, 0, 1, str.tostring(close, format.mintick), text_color = c_white, bgcolor = priceColor)
    table.cell(dash, 1, 1, aboveVwap ? 'BULLISH' : 'BEARISH', text_color = c_white, bgcolor = vwapColor)
    table.cell(dash, 2, 1, maUp ? 'BUY' : 'SELL', text_color = c_white, bgcolor = maColor)
    table.cell(dash, 3, 1, hmaBull ? 'BULLISH' : hmaBear ? 'BEARISH' : 'SIDEWAYS', text_color = c_white, bgcolor = hmaColor)
    table.cell(dash, 4, 1, stBull ? 'BUY' : 'SELL', text_color = c_white, bgcolor = stColor)
    table.cell(dash, 5, 1, trendStrong ? 'STRONG' : 'WEAK', text_color = c_white, bgcolor = adxColor)
    table.cell(dash, 6, 1, highVolume ? 'HIGH VOL' : 'LOW VOL', text_color = c_white, bgcolor = volColor)

if showMLDashboard and barstate.islast
    var table mlDash = table.new(position.top_right, 4, 4, border_width = 1, frame_width = 2, frame_color = color.gray)
    table.merge_cells(mlDash, 0, 0, 3, 0)
    table.merge_cells(mlDash, 1, 3, 3, 3)

    table.cell(mlDash, 0, 0, '── AI k-NN ENSEMBLE ──', text_color = c_white, bgcolor = color.rgb(20, 30, 40), text_size = size.small)
    table.cell(mlDash, 0, 1, 'METRIC', text_color = c_white, bgcolor = color.rgb(50, 50, 50), text_size = size.small)
    table.cell(mlDash, 1, 1, 'PROB BUY', text_color = c_green, bgcolor = color.rgb(50, 50, 50), text_size = size.small)
    table.cell(mlDash, 2, 1, 'PROB SELL', text_color = c_red, bgcolor = color.rgb(50, 50, 50), text_size = size.small)
    table.cell(mlDash, 3, 1, 'GRADE', text_color = c_white, bgcolor = color.rgb(50, 50, 50), text_size = size.small)

    bullBG = f_confColor(bullConfidence, true)
    bearBG = f_confColor(bearConfidence, false)
    table.cell(mlDash, 0, 2, 'AI Vector Match', text_color = c_white, bgcolor = color.rgb(40, 40, 40), text_size = size.small)
    table.cell(mlDash, 1, 2, str.tostring(math.round(bullConfidence)) + '%', text_color = c_white, bgcolor = bullBG, text_size = size.small)
    table.cell(mlDash, 2, 2, str.tostring(math.round(bearConfidence)) + '%', text_color = c_white, bgcolor = bearBG, text_size = size.small)
    table.cell(mlDash, 3, 2, bullConfidence >= bearConfidence ? bullGrade : bearGrade, text_color = c_white, bgcolor = color.rgb(40, 40, 40), text_size = size.small)

    sigText = finalLongSignal ? '▲ AI BUY' : finalShortSignal ? '▼ AI SELL' : aiLongState ? 'AI LONG HOLD' : aiShortState ? 'AI SHORT HOLD' : 'NEUTRAL'
    sigColor = finalLongSignal ? c_green : finalShortSignal ? c_red : aiLongState ? color.rgb(0, 120, 40) : aiShortState ? color.rgb(150, 0, 30) : c_gray
    table.cell(mlDash, 0, 3, 'AI Forecast', text_color = c_white, bgcolor = color.rgb(40, 40, 40), text_size = size.small)
    table.cell(mlDash, 1, 3, sigText, text_color = c_white, bgcolor = sigColor, text_size = size.small)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 8 — PLOTS 
// ═══════════════════════════════════════════════════════════════════════════
// Updated styling defaults: Blue (Fast), Red (Slow), Black (VWAP) — all bold (linewidth=2)
plot(maFast, 'MA Fast', color.blue, linewidth = 2)
plot(maSlow, 'MA Slow', color.red, linewidth = 2)
plot(vwap, 'VWAP', color.black, linewidth = 2)

plot(showHMA ? hma : na, 'HMA', hmaColor, 3)
plot(showSupertrend ? supertrend : na, 'Supertrend', stColor, 2)

u1 = plot(showVWAPBands ? upper1 : na, 'VWAP Upper 1', color = color.new(c_green, 50))
l1 = plot(showVWAPBands ? lower1 : na, 'VWAP Lower 1', color = color.new(c_green, 50))
u2 = plot(showVWAPBands ? upper2 : na, 'VWAP Upper 2', color = color.new(c_orange, 50))
l2 = plot(showVWAPBands ? lower2 : na, 'VWAP Lower 2', color = color.new(c_orange, 50))
u3 = plot(showVWAPBands ? upper3 : na, 'VWAP Upper 3', color = color.new(c_red, 50))
l3 = plot(showVWAPBands ? lower3 : na, 'VWAP Lower 3', color = color.new(c_red, 50))
fill(u1, l1, showVWAPBands ? color.new(c_green, 90) : na)
fill(u2, l2, showVWAPBands ? color.new(c_orange, 90) : na)
fill(u3, l3, showVWAPBands ? color.new(c_red, 90) : na)

plot(showFirst15 and isCurrentDay ? first15High : na, 'First 15 High', color = color.new(color.purple, 0), linewidth = 2, style = plot.style_stepline)
plot(showFirst15 and isCurrentDay ? first15Low : na, 'First 15 Low', color = color.new(color.purple, 0), linewidth = 2, style = plot.style_stepline)

plot(prevH, 'PDH', color.red, style = plot.style_stepline)
plot(prevL, 'PDL', color.red, style = plot.style_stepline)
plot(prevC, 'PDC', color.blue, style = plot.style_stepline)
plot(pivot, 'Pivot', c_orange, style = plot.style_stepline)
plot(r1, 'R1', color.maroon, style = plot.style_stepline)
plot(r2, 'R2', color.maroon, style = plot.style_stepline)
plot(s1, 'S1', color.teal, style = plot.style_stepline)
plot(s2, 'S2', color.teal, style = plot.style_stepline)
plot(UT, 'UT', color.yellow, style = plot.style_stepline)
plot(LT, 'LT', color.yellow, style = plot.style_stepline)

plotshape(finalLongSignal, title = 'AI Long Signal Marker', style = shape.triangleup, location = location.belowbar, color = c_green, size = size.small)
plotshape(finalShortSignal, title = 'AI Short Signal Marker', style = shape.triangledown, location = location.abovebar, color = c_red, size = size.small)

if showConfLabels and finalLongSignal
    label.new(bar_index, low - atrSafe * 0.4, text = '🤖 AI BUY ' + str.tostring(math.round(bullConfidence)) + '% [' + bullGrade + ']', style = label.style_label_up, color = f_confColor(bullConfidence, true), textcolor = c_white, size = size.small)

if showConfLabels and finalShortSignal
    label.new(bar_index, high + atrSafe * 0.4, text = '🤖 AI SELL ' + str.tostring(math.round(bearConfidence)) + '% [' + bearGrade + ']', style = label.style_label_down, color = f_confColor(bearConfidence, false), textcolor = c_white, size = size.small)

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 9 — LEVEL LABELS 
// ═══════════════════════════════════════════════════════════════════════════
var label lblPDH = na
var label lblPDL = na
var label lblPDC = na
var label lblPivot = na
var label lblR1 = na
var label lblR2 = na
var label lblS1 = na
var label lblS2 = na
var label lblUT = na
var label lblLT = na

if barstate.islast
    label.delete(lblPDH)
    label.delete(lblPDL)
    label.delete(lblPDC)
    label.delete(lblPivot)
    label.delete(lblR1)
    label.delete(lblR2)
    label.delete(lblS1)
    label.delete(lblS2)
    label.delete(lblUT)
    label.delete(lblLT)

    lblPDH := label.new(bar_index + 6, prevH, 'PDH', style = label.style_label_center, color = color.red, textcolor = c_white)
    lblPDL := label.new(bar_index + 6, prevL, 'PDL', style = label.style_label_center, color = color.red, textcolor = c_white)
    lblPDC := label.new(bar_index + 6, prevC, 'PDC', style = label.style_label_center, color = color.blue, textcolor = c_white)
    lblPivot := label.new(bar_index + 6, pivot, 'PT', style = label.style_label_center, color = c_orange, textcolor = c_white)
    lblR1 := label.new(bar_index + 6, r1, 'R1', style = label.style_label_center, color = color.maroon, textcolor = c_white)
    lblR2 := label.new(bar_index + 6, r2, 'R2', style = label.style_label_center, color = color.maroon, textcolor = c_white)
    lblS1 := label.new(bar_index + 6, s1, 'S1', style = label.style_label_center, color = color.teal, textcolor = c_white)
    lblS2 := label.new(bar_index + 6, s2, 'S2', style = label.style_label_center, color = color.teal, textcolor = c_white)
    lblUT := label.new(bar_index + 6, UT, 'UT', style = label.style_label_center, color = color.yellow, textcolor = color.black)
    lblLT := label.new(bar_index + 6, LT, 'LT', style = label.style_label_center, color = color.yellow, textcolor = color.black)
    lblLT

// ═══════════════════════════════════════════════════════════════════════════
// SECTION 10 — SHAPES & ALERTS
// ═══════════════════════════════════════════════════════════════════════════
plotshape(showCrossMarkers and bullCross ? maFast : na, title = 'EMA Bull Cross', style = shape.xcross, location = location.absolute, color = c_green, size = size.small)
plotshape(showCrossMarkers and bearCross ? maFast : na, title = 'EMA Bear Cross', style = shape.xcross, location = location.absolute, color = c_red, size = size.small)
plotshape(showCrossMarkers and vwapBullCross ? vwap : na, title = 'VWAP Bull Cross', style = shape.xcross, location = location.absolute, color = color.black, size = size.small)
plotshape(showCrossMarkers and vwapBearCross ? vwap : na, title = 'VWAP Bear Cross', style = shape.xcross, location = location.absolute, color = color.black, size = size.small)

if finalLongSignal
    alert('AI BUY Signal | Probability: ' + str.tostring(math.round(bullConfidence)) + '% | Grade: ' + bullGrade, alert.freq_once_per_bar_close)
if finalShortSignal
    alert('AI SELL Signal | Probability: ' + str.tostring(math.round(bearConfidence)) + '% | Grade: ' + bearGrade, alert.freq_once_per_bar_close)
````
