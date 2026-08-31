<!-- tradingview-pine-id: PUB;ad754629e48c419fb3af2d9f4e44c458 -->
<!-- tradingviewscripts-format: 1 -->
# Mean Reversion Half-Life & Spread Tracker [OnlyFibonacci] v3.0

Source: https://www.tradingview.com/script/BYGyZ11S/

## Description

Mean Reversion Half-Life & Spread Tracker [OnlyFibonacci] v3.0

A statistical mean-reversion oscillator for spread analysis — Z-Score normalization, closure-time tracking, confirmed signals, target price projection, and a real-time dashboard. Built in Pine Script v6.

This indicator is for educational and analytical purposes only. It does not constitute investment advice, financial advice, or a trading recommendation. Past signal performance does not guarantee future results. Always do your own research and manage risk responsibly.

---

What does this indicator do?

Mean Reversion Half-Life & Spread Tracker measures how far a price or spread has deviated from its statistical mean using a Z-Score oscillator. Beyond simple overbought/oversold readings, it tracks how long extreme deviations typically take to revert to zero, whether the current deviation is lasting longer than average, where price may revert if Z-Score returns to 0, and the historical success rate of confirmed signals.

Default mode: Asset vs Single Moving Average (Mean Reversion) — the chart symbol is normalized against a configurable SMA.

---

Core Features

[*]Two Operational Modes

[*]Asset vs SMA (default): Analyzes Close / SMA ratio for single-asset mean reversion
[*]Pair Trading: Analyzes chart symbol (Asset A) divided by a secondary symbol (Asset B)

[*]Z-Score Engine

[*]Spread Ratio = Close/SMA or Close/Asset B
[*]Z-Score = (Ratio − Rolling Mean) / Rolling Standard Deviation
[*]Default lookback: 200 bars
[*]EMA(3) smoothing applied to raw Z-Score to reduce whipsaw noise

[*]Threshold Levels

[*]Upper threshold: +2.3 (statistical overbought zone)
[*]Lower threshold: −2.3 (statistical oversold zone)
[*]Center line: 0.0 (equilibrium / mean)

[*]Mean Closure Time

[*]Tracks the average number of bars required for Z-Score to return to 0 after breaching ±2.3
[*]Displays active spread duration in real time
[*]Triggers a Time-Stop WARNING when duration exceeds the historical average

[*]Confirmed Signal Logic

[*]BUY: Smoothed Z-Score crosses above −2.3 and holds beyond the threshold for at least 1 full confirmed bar close (bullish mean reversion)
[*]SELL: Smoothed Z-Score crosses below +2.3 and holds beyond the threshold for at least 1 full confirmed bar close (bearish mean reversion)
[*]EXIT: Z-Score reaches 0, time-stop is triggered, or duration exceeds 2× average closure time

[*]Signal Win Rate (%)

[*]Historical success rate of confirmed signals
[*]Win: Z-Score returns to 0 before exceeding 2× average closure time
[*]Loss: Timeout or time-stop triggered before mean reversion completes

[*]Target Price Level

[*]Estimated chart price where Z-Score would equal 0
[*]MA mode: RatioMean × SMA
[*]Pair mode: RatioMean × Asset B price
[*]Optional dynamic dashed projection line on the main chart while a signal is active

[*]Visual Design (v3.0)

[*]Dynamic gradient Z-Score line (red above 0, green below 0, neon tones at extremes)
[*]Gradient-filled area between Z-Score and the zero line
[*]Soft background glow in extreme zones
[*]Modern dark-theme dashboard table with live status indicators

[*]Built-in Alerts

[*]Upper / Lower Threshold Breach
[*]Time-Stop Warning
[*]Bullish Mean Reversion BUY
[*]Bearish Mean Reversion SELL
[*]Signal EXIT

---

Dashboard Table

Live metrics displayed in the top-right corner:

[*]Pair / Mode — active analysis configuration
[*]Current Z-Score — real-time smoothed reading
[*]Target Price Level — estimated Z=0 price
[*]Avg Closure Time — historical mean reversion duration (bars)
[*]Spread Duration — active deviation duration
[*]Time-Stop Status — Normal or Warning
[*]Signal Win Rate (%) — historical confirmed signal success rate

Status indicators: Normal, Active Trade, Warning.

---

How to Use

[*]Add the indicator to your chart (separate oscillator pane).
[*]In default Asset vs SMA mode, set the SMA length (default: 50).
[*]For pair analysis, switch to Pair Trading mode and select Asset B.
[*]Monitor the Z-Score panel:

[*]Z > +2.3 → spread is statistically extended above mean (potential bearish mean reversion)
[*]Z < −2.3 → spread is statistically extended below mean (potential bullish mean reversion)
[*]Z ≈ 0 → statistical equilibrium

[*]Compare Spread Duration against Avg Closure Time in the dashboard.
[*]If Time-Stop shows WARNING, the deviation may be persisting longer than historically normal — review risk management.
[*]Set alerts for threshold breaches, confirmed signals, and exits.

---

How to Interpret

[*]Mean reversion concept: When price or spread reaches statistical extremes, it tends to revert toward its rolling mean over time.
[*]Z-Score: Measures deviation in standard deviation units. ±2.3 represents a strong statistical extreme.
[*]Avg Closure Time: How long past extreme deviations took to revert to zero. If current duration exceeds this, caution is warranted.
[*]Target Price: A dynamic estimate of where price may revert if Z-Score normalizes — a reference level, not a guaranteed target.
[*]Win Rate: A summary of past confirmed signal outcomes. Not a promise of future performance.
[*]Gradient fill: Visually emphasizes the magnitude and direction of deviation from equilibrium.

Horizontal dashed line on the main chart (if enabled): Projects the estimated price level where Z-Score = 0 while a BUY or SELL signal is active. It updates dynamically and disappears on EXIT or target reached. Disable via Show Target Price Projection Line.

---

Recommended Use Cases

[*]Single-asset mean reversion analysis vs SMA
[*]Crypto, forex, and equity pair spread monitoring
[*]Multi-timeframe confluence checks
[*]Alert-based watchlist monitoring
[*]Time-stop and duration-based risk awareness

---

Customizable Inputs

[*]Mode, Asset B Symbol, MA Length
[*]Z-Score Lookback (200), EMA Smoothing (3)
[*]Upper/Lower Threshold (±2.3)
[*]Signal Confirmation Bars (1–5)
[*]Gradient Area Fill, Background Glow, Target Line, Dashboard

---

Important Notes

[*]Non-repainting security calls: gaps_off, lookahead_off
[*]This is an analysis tool — it does not execute trades automatically
[*]Parameters may require optimization across different markets and timeframes
[*]Win rate and closure time are based on historical data and may differ in live conditions
[*]Always use proper position sizing and risk management

---

Keywords

Mean Reversion, Z-Score, Half-Life, Spread Tracker, Pair Trading, Statistical Arbitrage, Oscillator, SMA, Closure Time, Time-Stop, Pine Script v6, OnlyFibonacci

---

Developed with Pine Script v6. For analysis and education only.

---

## Source Code

````pine
//@version=6
indicator(
     title = "Mean Reversion Half-Life & Spread Tracker [OnlyFibonacci] v3.0",
     shorttitle = "MR Half-Life v3 [OF]",
     overlay = false,
     max_bars_back = 5000,
     max_lines_count = 500,
     max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

string GRP_MODE   = "Operational Mode"
string GRP_CALC   = "Calculation Settings"
string GRP_THRESH = "Thresholds"
string GRP_SIGNAL = "Signal Filters"
string GRP_VISUAL = "Visual Styling"
string GRP_TABLE  = "Dashboard"

string MODE_PAIR = "Pair Trading (Asset A vs Asset B)"
string MODE_MA   = "Asset vs Single Moving Average (Mean Reversion)"

string operMode = input.string(
     MODE_MA,
     title = "Mode",
     options = [MODE_PAIR, MODE_MA],
     group = GRP_MODE,
     tooltip = "Pair mode compares chart symbol (Asset A) against a secondary symbol (Asset B). MA mode compares close price against a simple moving average.")

string assetBSymbol = input.symbol(
     "BINANCE:BTCUSDT",
     title = "Asset B Symbol",
     group = GRP_MODE,
     tooltip = "Secondary ticker used in Pair Trading mode. Chart symbol is treated as Asset A.")

int maLength = input.int(
     50,
     title = "Moving Average Length",
     minval = 2,
     group = GRP_MODE,
     tooltip = "SMA length used when operating in single-asset mean reversion mode.")

int zLookback = input.int(
     200,
     title = "Z-Score Lookback",
     minval = 10,
     group = GRP_CALC,
     tooltip = "Number of bars used to compute rolling mean and standard deviation of the spread ratio.")

int zEmaLength = input.int(
     3,
     title = "Z-Score EMA Smoothing",
     minval = 1,
     group = GRP_CALC,
     tooltip = "Exponential moving average applied to the raw Z-Score to reduce noise before signal evaluation.")

int maxClosureSamples = input.int(
     200,
     title = "Max Closure History Samples",
     minval = 10,
     maxval = 500,
     group = GRP_CALC,
     tooltip = "Maximum number of completed breach-to-zero cycles stored for the average closure time calculation.")

int maxSignalSamples = input.int(
     200,
     title = "Max Signal History Samples",
     minval = 10,
     maxval = 500,
     group = GRP_CALC,
     tooltip = "Maximum number of completed trade signals stored for win-rate calculation.")

float upperThreshold = input.float(
     2.3,
     title = "Upper Threshold",
     minval = 0.5,
     step = 0.1,
     group = GRP_THRESH,
     tooltip = "Overbought Z-Score level that starts a mean-reversion closure timer.")

float lowerThreshold = input.float(
     -2.3,
     title = "Lower Threshold",
     minval = -5.0,
     maxval = -0.5,
     step = 0.1,
     group = GRP_THRESH,
     tooltip = "Oversold Z-Score level that starts a mean-reversion closure timer.")

int confirmBars = input.int(
     1,
     title = "Signal Confirmation Bars",
     minval = 1,
     maxval = 5,
     group = GRP_SIGNAL,
     tooltip = "Number of full bar closes the smoothed Z-Score must hold beyond the threshold after crossover before a signal is triggered.")

bool showGradientArea   = input.bool(true, title = "Show Gradient Area Fill", group = GRP_VISUAL, tooltip = "Fills the area between the Z-Score line and zero with a smooth gradient instead of histogram bars.")
bool showBackgroundGlow = input.bool(true, title = "Show Extreme Zone Background Glow", group = GRP_VISUAL, tooltip = "Soft pane glow when Z-Score enters extreme overbought or oversold zones.")
bool showTargetLine     = input.bool(true, title = "Show Target Price Projection Line", group = GRP_VISUAL, tooltip = "Projects a dynamic Z=0 target price line on the main chart while a signal is active.")

bool showDashboard = input.bool(true, title = "Show Dashboard Table", group = GRP_TABLE)
string tableSize   = input.string("Normal", title = "Table Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_TABLE)

// Theme palette — modern dark aesthetic
color CLR_HEADER_BG    = color.new(#12141C, 0)
color CLR_ROW_ODD      = color.new(#131722, 0)
color CLR_ROW_EVEN     = color.new(#1A1E2B, 10)
color CLR_BORDER       = color.new(#2A2E39, 0)
color CLR_FRAME        = color.new(#FFD700, 25)
color CLR_LABEL_MUTED  = color.new(#787B86, 0)
color CLR_NORMAL       = color.new(#26A69A, 0)
color CLR_WARNING      = color.new(#EF5350, 0)
color CLR_ACTIVE       = color.new(#FFD700, 0)
color CLR_DARK_RED     = color.new(#8B0000, 0)
color CLR_RED          = color.new(#F23645, 0)
color CLR_GREEN        = color.new(#089981, 0)
color CLR_LIME         = color.new(#32CD32, 0)
color CLR_NEON_RED     = color.new(#FF1744, 0)
color CLR_NEON_GREEN   = color.new(#00E676, 0)

// ─────────────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────

getTableSize(string sizeLabel) =>
    switch sizeLabel
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        => size.normal

getModeLabel(string mode, string symbolB, int smaLen) =>
    if mode == MODE_PAIR
        syminfo.ticker + " / " + syminfo.ticker(symbolB)
    else
        syminfo.ticker + " / SMA(" + str.tostring(smaLen) + ")"

// Computes rolling mean of the spread ratio (Z = 0 target level).
calcRatioMean(float ratio, int lookback) =>
    ta.sma(ratio, lookback)

// Computes rolling Z-Score for a given ratio series.
calcZScore(float ratio, float ratioMean, int lookback) =>
    float ratioStdev = ta.stdev(ratio, lookback)
    float z = ratioStdev > 0.0 ? (ratio - ratioMean) / ratioStdev : 0.0
    z

// Estimates chart-symbol price where Z-Score would equal zero.
calcTargetPrice(string mode, float ratioMean, float assetBClose, float assetSma) =>
    if na(ratioMean)
        na
    else if mode == MODE_PAIR
        assetBClose > 0.0 ? ratioMean * assetBClose : na
    else
        assetSma > 0.0 ? ratioMean * assetSma : na

// Dynamic line color for Z-Score plot.
getZScoreColor(float z, float upper, float lower) =>
    if na(z)
        color.new(color.gray, 50)
    else if z > upper
        CLR_DARK_RED
    else if z > 0.0
        color.from_gradient(z, 0.0, upper, CLR_RED, CLR_DARK_RED)
    else if z < lower
        CLR_LIME
    else
        color.from_gradient(z, lower, 0.0, CLR_LIME, CLR_GREEN)

// Gradient area fill between Z-Score line and zero center line.
getAreaFillColor(float z, float upper, float lower) =>
    if na(z)
        color.new(color.gray, 100)
    else if z >= upper
        color.new(CLR_NEON_RED, 72)
    else if z > 0.0
        color.from_gradient(z, 0.0, upper, color.new(CLR_RED, 90), color.new(CLR_NEON_RED, 75))
    else if z <= lower
        color.new(CLR_NEON_GREEN, 72)
    else
        color.from_gradient(z, lower, 0.0, color.new(CLR_NEON_GREEN, 75), color.new(CLR_GREEN, 90))

// Pushes a new closure duration into a bounded FIFO array.
pushClosureSample(array<int> samples, int duration, int maxSamples) =>
    if duration > 0
        array.push(samples, duration)
        while array.size(samples) > maxSamples
            array.shift(samples)

// Pushes a boolean win/loss result into a bounded FIFO array.
pushSignalResult(array<bool> results, bool isWin, int maxSamples) =>
    array.push(results, isWin)
    while array.size(results) > maxSamples
        array.shift(results)

avgClosureTime(array<int> samples) =>
    int sampleCount = array.size(samples)
    float total = 0.0
    if sampleCount > 0
        for i = 0 to sampleCount - 1
            total += array.get(samples, i)
        total / sampleCount
    else
        na

calcWinRate(array<bool> results) =>
    int sampleCount = array.size(results)
    int winCount = 0
    if sampleCount > 0
        for i = 0 to sampleCount - 1
            if array.get(results, i)
                winCount += 1
        100.0 * winCount / sampleCount
    else
        na

// Safely deletes a line drawing object.
deleteLine(line ln) =>
    if not na(ln)
        line.delete(ln)

setDashboardRow(table tbl, int row, string metric, string value, color valueColor, bool isOddRow, string sizeLabel) =>
    color rowBg = isOddRow ? CLR_ROW_ODD : CLR_ROW_EVEN
    table.cell(tbl, 0, row, metric, text_color = CLR_LABEL_MUTED, bgcolor = rowBg, text_size = getTableSize(sizeLabel))
    table.cell(tbl, 1, row, value, text_color = valueColor, bgcolor = rowBg, text_size = getTableSize(sizeLabel))

// ─────────────────────────────────────────────────────────────────────────────
// SPREAD RATIO & Z-SCORE
// ─────────────────────────────────────────────────────────────────────────────

float assetBClose = request.security(
     assetBSymbol,
     timeframe.period,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off)

float assetSma = ta.sma(close, maLength)

float spreadRatio = operMode == MODE_PAIR
     ? (assetBClose > 0.0 ? close / assetBClose : na)
     : (assetSma > 0.0 ? close / assetSma : na)

float ratioMean = calcRatioMean(spreadRatio, zLookback)
float zScoreRaw = calcZScore(spreadRatio, ratioMean, zLookback)
float zScore = ta.ema(zScoreRaw, zEmaLength)
bool isValidZ = not na(zScore) and not na(spreadRatio)

// Target price level where Z-Score would equal zero.
float targetPrice = calcTargetPrice(operMode, ratioMean, assetBClose, assetSma)

// ─────────────────────────────────────────────────────────────────────────────
// MEAN CLOSURE TIME & CURRENT OPEN DURATION TRACKER
// ─────────────────────────────────────────────────────────────────────────────

var int breachState = 0
var int openDuration = 0
var array<int> closureHistory = array.new<int>()

bool enterUpper = isValidZ and breachState == 0 and zScore >= upperThreshold
bool enterLower = isValidZ and breachState == 0 and zScore <= lowerThreshold
bool closeFromUpper = breachState == 1 and isValidZ and zScore <= 0.0
bool closeFromLower = breachState == -1 and isValidZ and zScore >= 0.0

if enterUpper
    breachState := 1
    openDuration := 1
else if enterLower
    breachState := -1
    openDuration := 1
else if breachState != 0
    openDuration += 1
    if closeFromUpper or closeFromLower
        pushClosureSample(closureHistory, openDuration, maxClosureSamples)
        breachState := 0
        openDuration := 0

float avgClosureBars = avgClosureTime(closureHistory)

string timeStopStatus = "NORMAL"
if breachState != 0 and not na(avgClosureBars) and openDuration > avgClosureBars
    timeStopStatus := "WARNING: Exceeded Avg Duration"

bool timeStopTriggered = timeStopStatus == "WARNING: Exceeded Avg Duration"

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL ENGINE — BUY / SELL / EXIT & WIN-RATE TRACKING
// ─────────────────────────────────────────────────────────────────────────────

var int signalState = 0
var int signalDuration = 0
var int pendingBuyBars = 0
var int pendingSellBars = 0
var bool buyArmed = false
var bool sellArmed = false
var array<bool> signalResults = array.new<bool>()
var line targetPriceLine = na

bool zCrossAboveLower = ta.crossover(zScore, lowerThreshold)
bool zCrossBelowUpper = ta.crossunder(zScore, upperThreshold)

if zCrossAboveLower and signalState == 0
    pendingBuyBars := 1
    pendingSellBars := 0
    buyArmed := false
    sellArmed := false
else if pendingBuyBars > 0
    if zScore > lowerThreshold
        pendingBuyBars += 1
        if pendingBuyBars > confirmBars
            buyArmed := true
    else
        pendingBuyBars := 0
        buyArmed := false

if zCrossBelowUpper and signalState == 0
    pendingSellBars := 1
    pendingBuyBars := 0
    buyArmed := false
    sellArmed := false
else if pendingSellBars > 0
    if zScore < upperThreshold
        pendingSellBars += 1
        if pendingSellBars > confirmBars
            sellArmed := true
    else
        pendingSellBars := 0
        sellArmed := false

if signalState != 0
    pendingBuyBars := 0
    pendingSellBars := 0
    buyArmed := false
    sellArmed := false

bool buySignal = isValidZ and signalState == 0 and buyArmed
bool sellSignal = isValidZ and signalState == 0 and sellArmed

if buySignal
    pendingBuyBars := 0
    buyArmed := false
if sellSignal
    pendingSellBars := 0
    sellArmed := false

if buySignal and signalState == 0
    signalState := 1
    signalDuration := 1
else if sellSignal and signalState == 0
    signalState := -1
    signalDuration := 1
else if signalState != 0
    signalDuration += 1

float signalTimeoutLimit = not na(avgClosureBars) ? 2.0 * avgClosureBars : na
bool signalReachedZero = (signalState == 1 and isValidZ and zScore >= 0.0) or (signalState == -1 and isValidZ and zScore <= 0.0)
bool signalTimedOut = not na(signalTimeoutLimit) and signalDuration > signalTimeoutLimit
bool signalExitTimeStop = signalState != 0 and timeStopTriggered
bool exitSignal = signalState != 0 and (signalReachedZero or signalTimedOut or signalExitTimeStop)

if signalState != 0 and (signalReachedZero or signalTimedOut or signalExitTimeStop)
    bool isWin = signalReachedZero
    pushSignalResult(signalResults, isWin, maxSignalSamples)
    signalState := 0
    signalDuration := 0

float signalWinRate = calcWinRate(signalResults)
bool hasActiveSignal = signalState != 0

// ─────────────────────────────────────────────────────────────────────────────
// TARGET PRICE PROJECTION LINE (MAIN CHART — force_overlay)
// ─────────────────────────────────────────────────────────────────────────────

color targetLineColor = signalState == 1 ? CLR_NEON_GREEN : signalState == -1 ? CLR_NEON_RED : color.new(color.gray, 40)

// Spawn projection line on confirmed entry signals.
if showTargetLine and (buySignal or sellSignal) and not na(targetPrice)
    deleteLine(targetPriceLine)
    targetPriceLine := line.new(
         bar_index,
         targetPrice,
         bar_index + 1,
         targetPrice,
         xloc = xloc.bar_index,
         extend = extend.right,
         color = buySignal ? CLR_NEON_GREEN : CLR_NEON_RED,
         style = line.style_dashed,
         width = 2,
         force_overlay = true)

// Dynamically update the projected target while the trade signal is active.
if showTargetLine and hasActiveSignal and not na(targetPriceLine) and not na(targetPrice)
    line.set_xy1(targetPriceLine, bar_index, targetPrice)
    line.set_xy2(targetPriceLine, bar_index + 1, targetPrice)
    line.set_color(targetPriceLine, targetLineColor)

// Dissolve projection line once EXIT fires or target is reached.
if exitSignal
    deleteLine(targetPriceLine)
    targetPriceLine := na

// ─────────────────────────────────────────────────────────────────────────────
// VISUALS — Z-SCORE OSCILLATOR PANE
// ─────────────────────────────────────────────────────────────────────────────

color zLineColor = getZScoreColor(zScore, upperThreshold, lowerThreshold)
color areaFillColor = getAreaFillColor(zScore, upperThreshold, lowerThreshold)

hline(upperThreshold, title = "Upper Threshold", color = color.new(#F23645, 35), linestyle = hline.style_dashed)
hline(0.0, title = "Zero Line", color = color.new(color.gray, 55), linestyle = hline.style_dotted)
hline(lowerThreshold, title = "Lower Threshold", color = color.new(#089981, 35), linestyle = hline.style_dashed)

bgcolor(
     showBackgroundGlow and isValidZ and zScore >= upperThreshold ? color.new(#F23645, 90) : na,
     title = "Upper Zone Glow")
bgcolor(
     showBackgroundGlow and isValidZ and zScore <= lowerThreshold ? color.new(#089981, 90) : na,
     title = "Lower Zone Glow")

zScorePlot = plot(zScore, title = "Z-Score (Smoothed)", color = zLineColor, linewidth = 2)
zeroPlot = plot(0.0, title = "Zero Baseline", color = color.new(color.gray, 100), display = display.none)

// Gradient-filled area between Z-Score and zero (replaces histogram).
fill(
     zScorePlot,
     zeroPlot,
     color = showGradientArea and isValidZ ? areaFillColor : color.new(color.gray, 100),
     title = "Z-Score Gradient Area")

plot(zScoreRaw, title = "Z-Score (Raw)", color = color.new(color.gray, 60), linewidth = 1, display = display.none)
plot(breachState != 0 ? openDuration : na, title = "Active Open Duration", color = color.new(color.orange, 0), display = display.none)
plot(hasActiveSignal ? signalDuration : na, title = "Active Signal Duration", color = color.new(CLR_ACTIVE, 0), display = display.none)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD TABLE — ULTRA POLISH MODERN DARK AESTHETIC
// ─────────────────────────────────────────────────────────────────────────────

var table dashboard = table.new(
     position.top_right,
     2,
     8,
     border_width = 1,
     border_color = CLR_BORDER,
     frame_width = 3,
     frame_color = CLR_FRAME)

if showDashboard and barstate.islast
    string modeLabel = getModeLabel(operMode, assetBSymbol, maLength)
    string zText = isValidZ ? str.tostring(zScore, "#.###") + " (smoothed)" : "n/a"
    string avgText = not na(avgClosureBars) ? str.tostring(avgClosureBars, "#.##") + " bars" : "Collecting data..."
    string durationText = breachState != 0 ? "🟡 " + str.tostring(openDuration) + " bars" : "🟢 0 (Idle)"
    string statusText = timeStopTriggered ? "🔴 " + timeStopStatus : "🟢 " + timeStopStatus
    string winRateText = not na(signalWinRate) ? str.tostring(signalWinRate, "#.##") + "%" : "Collecting data..."
    string targetText = not na(targetPrice) ? str.tostring(targetPrice, format.mintick) : "n/a"
    string tradeIcon = hasActiveSignal ? "🟡 Active Trade" : "🟢 No Active Trade"

    color zValueColor = isValidZ ? getZScoreColor(zScore, upperThreshold, lowerThreshold) : color.white
    color durationColor = breachState != 0 ? CLR_ACTIVE : CLR_NORMAL
    color statusColor = timeStopTriggered ? CLR_WARNING : CLR_NORMAL
    color winRateColor = not na(signalWinRate) ? (signalWinRate >= 50.0 ? CLR_NORMAL : CLR_WARNING) : color.white
    color targetColor = hasActiveSignal ? CLR_ACTIVE : color.white

    table.cell(dashboard, 0, 0, "◆ MR Tracker v3.0", text_color = CLR_ACTIVE, bgcolor = CLR_HEADER_BG, text_size = getTableSize(tableSize))
    table.cell(dashboard, 1, 0, tradeIcon, text_color = hasActiveSignal ? CLR_ACTIVE : CLR_NORMAL, bgcolor = CLR_HEADER_BG, text_size = getTableSize(tableSize))

    setDashboardRow(dashboard, 1, "Pair / Mode", modeLabel, color.white, true, tableSize)
    setDashboardRow(dashboard, 2, "Current Z-Score", zText, zValueColor, false, tableSize)
    setDashboardRow(dashboard, 3, "Target Price Level", targetText, targetColor, true, tableSize)
    setDashboardRow(dashboard, 4, "Avg Closure Time", avgText, color.white, false, tableSize)
    setDashboardRow(dashboard, 5, "Spread Duration", durationText, durationColor, true, tableSize)
    setDashboardRow(dashboard, 6, "Time-Stop Status", statusText, statusColor, false, tableSize)
    setDashboardRow(dashboard, 7, "Signal Win Rate (%)", winRateText, winRateColor, true, tableSize)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(enterUpper, title = "Upper Threshold Breach", message = "Z-Score crossed above upper threshold — mean reversion cycle started.")
alertcondition(enterLower, title = "Lower Threshold Breach", message = "Z-Score crossed below lower threshold — mean reversion cycle started.")
alertcondition(timeStopTriggered, title = "Time-Stop Warning", message = "Current spread duration exceeded historical average closure time.")
alertcondition(buySignal, title = "Bullish Mean Reversion BUY", message = "Confirmed BUY: smoothed Z-Score held above lower threshold.")
alertcondition(sellSignal, title = "Bearish Mean Reversion SELL", message = "Confirmed SELL: smoothed Z-Score held below upper threshold.")
alertcondition(exitSignal, title = "Signal EXIT", message = "Mean reversion target reached at zero or time-stop triggered — exit signal.")
````
