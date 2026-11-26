# MYND Adaptive Parameter Optimizer v1.0

- url: https://www.tradingview.com/script/x3sluUIi-MYND-Adaptive-Parameter-Optimizer-v1-0/
- type: indicator
- pine_id: PUB;03006f96dcff43faaba0ba47d93780c1
- version: 1.0

## Description

MYND Adaptive Parameter Optimizer [v1.0]

A genuine walk-forward self-tuning engine - it doesn't just use a moving average or RSI length you picked once, it periodically re-tests a range of lengths against recent history and adopts whichever one actually worked best.

WHAT IT DOES

Every N bars (your Recalibration Interval), this indicator tests a range of candidate lengths for either a Moving Average Crossover engine or an RSI Mean-Reversion engine against a bounded recent evaluation window, scores each candidate by how well its historical signal events actually predicted the next move, and adopts whichever length scored best - until the next recalibration. This is real walk-forward re-optimization built into the indicator itself, not a single fixed parameter you set once and hope keeps working.

HOW IT WORKS

Choose one mode per instance: Moving Average Crossover (favors trending behavior) or RSI Mean-Reversion (favors range-bound behavior) - add a second copy of the tool if you want both running side by side. The candidate search only runs periodically, never every bar, and uses efficient techniques (a prefix-sum trick for MA mode, one linear pass per candidate for RSI mode) to stay cheap even while testing up to 25 candidate lengths at once. Once a length is adopted, live plotting and signals use one simple, standard call every bar until the next recalibration.

Beyond the in-sample fitness score each recalibration produces, this tool also grades its own LIVE signals out-of-sample - a genuinely honest check on whether the adopted length is actually working going forward, not just how it looked during the search that chose it.

KEY FEATURES

A live dashboard showing the currently adopted length, the in-sample fitness score and event count from the last recalibration, a rolling out-of-sample Live Signal Accuracy stat, and time until the next recalibration attempt. A dedicated alert the moment the adopted length actually changes. An optional volume-confirmation gate on signals. Light/Dark theme presets plus a colorblind-safe signal color option. Full customization throughout, with tooltips on every setting that benefits from one.

IMPORTANT - this tool always renders in a separate lower pane, in both modes. Pine's overlay setting is fixed at compile time and can't switch between "on the price chart" and "separate pane" based on a runtime mode selection - so rather than a hack, Moving Average mode plots the adaptive MA's %-distance from price (oscillating around a zero line) instead of overlaying the MA line directly on price. RSI mode plots the adaptive RSI itself (0-100). Both modes signal off the same real underlying cross events either way.

HOW TO USE IT

Works out of the box with sensible defaults. Expect a genuine warm-up period after first adding it to a chart - the optimizer needs a meaningful amount of history before its first real recalibration can run, and uses Candidate Length - Min as a placeholder until then. Watch the Adopted Length on the dashboard over time to see how the tool responds to changing market character, and compare the in-sample fitness score against the out-of-sample Live Signal Accuracy for an honest read on whether it's actually working right now.

SETTINGS WORTH TUNING FIRST

Recalibration Interval and Evaluation Window - lengthen either for steadier, less frequent length changes; shorten for faster adaptation. Candidate Length - Min/Max/Step - defines the search range; note the number of tested candidates is capped at 25 for compute-cost reasons. Minimum Events for Valid Score - raise it to require more statistical support before a candidate can win.

ALERTS

The 4 standard alerts (Bullish/Bearish Signal, Live Accuracy Warning, and the ALL Signals combo) use TradingView's normal alertcondition() system. The Adopted Length Changed alert is different - it uses Pine's dynamic alert() function since it announces a changing numeric value, so set it up with Condition -> this script -> "Any alert() function call" rather than a named condition.

This tool can only tell you what would have worked recently on this symbol/timeframe - it is not a guarantee of what will keep working, which is exactly why the out-of-sample Live Signal Accuracy stat exists as a separate, honest check. This tool is provided for informational and educational purposes and does not constitute financial advice. Trading involves risk; past performance and historical patterns do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("MYND Adaptive Parameter Optimizer v1.0", shorttitle="MYND APO v1.0", overlay=false)

// =====================================================================================
// MYND ADAPTIVE PARAMETER OPTIMIZER v1.0
// A genuine walk-forward self-tuning engine: every N bars ("Recalibration Interval"),
// tests a range of candidate lengths for either a Moving Average Crossover or an RSI
// Mean-Reversion engine against a bounded recent evaluation window, scores each candidate
// by how well its historical signal events actually predicted the next move, and adopts
// whichever length scored best going forward - until the next recalibration. This is real
// walk-forward re-optimization built into the indicator itself, not a fixed-parameter tool.
//
// Efficiency design, stated plainly: the expensive candidate search only runs periodically
// (every Recalibration Interval bars), never every bar. MA-mode candidate scoring uses a
// prefix-sum technique so every candidate's moving averages across the whole evaluation
// window are O(1) lookups after one O(bufferSize) setup pass - no repeated summation. RSI-
// mode candidate scoring walks Wilder's real recursive smoothing formula once per candidate
// across the buffer (RSI cannot be prefix-summed since it is path-dependent) - still cheap
// since it is one linear pass per candidate, not nested per-bar work. Both engines keep
// their own manually-maintained rolling price buffer (an array, not raw series[] indexing)
// specifically so this works safely beyond Pine's default historical-reference limits.
// Once a length is adopted, LIVE plotting/signals use one single, cheap call every bar -
// never inside a loop, never with a varying length per iteration within one bar. MA mode
// uses ta.sma() directly with the runtime-adopted length (ta.sma's length parameter accepts
// a "series int", so this is directly supported). RSI mode CANNOT do the equivalent with
// ta.rsi() - unlike ta.sma(), ta.rsi()'s length parameter requires a "simple int" (fixed at
// compile time), so a runtime-adaptive length is rejected by the compiler. RSI mode's live
// engine instead maintains its own persistent Wilder avgGain/avgLoss recursion (one line per
// bar, var-persisted) using the current adoptedLength each step - the exact same recursive
// RSI formula ta.rsi() uses internally, just computed manually so the length is free to
// change bar to bar as recalibration adopts a new value. This mirrors the same manual
// Wilder-recursive technique already used in the RSI mode recalibration search above.
//
// Deliberate design choice: this script always renders in a separate lower pane
// (overlay=false) regardless of Optimization Mode. Pine's overlay setting is fixed at
// compile time and cannot switch between "on the price chart" and "separate pane" based on
// a runtime dropdown - so rather than a hack, Moving Average Crossover mode plots the
// adaptive MA's %-distance from price (oscillating around a zero line) instead of overlaying
// the MA line directly on price. RSI Mean-Reversion mode plots the adaptive RSI itself
// (0-100). Both signal off the same real underlying cross events either way - only the
// on-chart visual differs from a typical overlaid MA. See Directions & Notes for detail.
//
// Cold-start and fallback, stated plainly: until enough history accumulates for a first
// real recalibration, the tool uses Candidate Length - Min as a placeholder default. If a
// recalibration cycle finds no candidate with enough qualifying signal events (see Minimum
// Events for Valid Score), the previously adopted length is kept unchanged until the next
// cycle rather than adopting a statistically unreliable winner.

// =====================================================================================

// ---------------------------- INPUTS: OPTIMIZER SETTINGS ----------------------------
optimizationMode = input.string("Moving Average Crossover", "Optimization Mode", options=["Moving Average Crossover", "RSI Mean-Reversion"], group="Optimizer Settings", tooltip="Which underlying engine this tool self-tunes and signals from. Moving Average Crossover favors trending behavior; RSI Mean-Reversion favors range-bound behavior. Only one mode runs per instance - add a second copy of this tool to run both at once.")
candidateMinLen = input.int(5, "Candidate Length - Min", minval=2, group="Optimizer Settings", tooltip="Shortest length considered as a candidate during each recalibration.")
candidateMaxLen = input.int(50, "Candidate Length - Max", minval=3, maxval=150, group="Optimizer Settings", tooltip="Longest length considered as a candidate during each recalibration. Higher increases compute cost per recalibration.")
candidateStep = input.int(5, "Candidate Length - Step", minval=1, maxval=50, group="Optimizer Settings", tooltip="Spacing between tested candidate lengths (e.g. Min 5, Max 50, Step 5 tests 5, 10, 15 ... 50). The number of candidates tested is capped at 25 for compute-cost reasons - if Min/Max/Step would produce more than that, only the first 25 (ascending from Min) are tested.")
recalibBars = input.int(20, "Recalibration Interval (bars)", minval=5, group="Optimizer Settings", tooltip="How often the optimizer re-tests all candidates and potentially switches the adopted length - the 'walk-forward' step. Shorter reacts faster to changing conditions but adopted lengths become less statistically stable.")
evalWindowBars = input.int(150, "Evaluation Window (bars)", minval=30, maxval=300, group="Optimizer Settings", tooltip="How much recent history each candidate is scored against at every recalibration. Longer gives a more statistically stable fitness score but reacts more slowly to genuinely new conditions.")
evalForwardBars = input.int(5, "Evaluation Forward Bars", minval=1, maxval=50, group="Optimizer Settings", tooltip="How many bars forward each historical signal event's outcome is measured over when scoring candidates - should roughly match your intended holding period. Also used to grade the tool's own live signals for the Live Signal Accuracy stat.")
minEventsForValid = input.int(4, "Minimum Events for Valid Score", minval=1, group="Optimizer Settings", tooltip="A candidate length with fewer than this many signal events inside the Evaluation Window is considered statistically unreliable and excluded from that recalibration's comparison.")

// ---------------------------- INPUTS: RSI MODE SETTINGS ----------------------------
rsiOversold = input.float(30, "RSI Oversold Level", minval=1, maxval=49, group="RSI Mode Settings", tooltip="RSI Mean-Reversion mode only: level a candidate's RSI must fall below to count as an oversold event, and the live cross-back-above level that fires a Bullish Signal.")
rsiOverbought = input.float(70, "RSI Overbought Level", minval=51, maxval=99, group="RSI Mode Settings", tooltip="RSI Mean-Reversion mode only: level a candidate's RSI must rise above to count as an overbought event, and the live cross-back-below level that fires a Bearish Signal.")

// ---------------------------- INPUTS: SIGNAL SETTINGS ----------------------------
requireVolConfirm = input.bool(false, "Require Volume Confirmation on Signals", group="Signal Settings", tooltip="When on, live Bullish/Bearish Signals only fire if current volume also clears the multiple of average volume set below.")
volConfirmLen = input.int(20, "Volume Confirmation Average Length", minval=2, group="Signal Settings", tooltip="Average volume length used for confirmation. Only applies when Require Volume Confirmation is on.")
volConfirmMult = input.float(1.2, "Volume Confirmation Multiplier", minval=0.5, step=0.1, group="Signal Settings", tooltip="Volume must be at least this multiple of the average to confirm a signal. Only applies when Require Volume Confirmation is on.")

// ---------------------------- INPUTS: ACCURACY TRACKING ----------------------------
rollingWindow = input.int(30, "Live Accuracy Rolling Window (signals)", minval=5, group="Accuracy Tracking", tooltip="How many of the tool's own most recent LIVE, already-graded signals the Live Signal Accuracy stat is based on - a rolling, not all-time, window.")
accuracyWarnLevel = input.float(45, "Live Accuracy Warning Level (%)", minval=1, maxval=99, group="Accuracy Tracking", tooltip="If Live Signal Accuracy falls below this, the Live Accuracy Warning alert fires.")
minTrackedForAccuracyAlert = input.int(20, "Minimum Tracked Signals for Accuracy Alert", minval=1, group="Accuracy Tracking", tooltip="The accuracy alert stays silent until at least this many live signals have been graded, to avoid an unreliable early read.")

// ---------------------------- INPUTS: THEME & ACCESSIBILITY ----------------------------
themeMode = input.string("Light", "Theme Preset", options=["Light", "Dark", "Custom"], group="Theme & Accessibility", tooltip="Light and Dark apply a curated color palette suited to that chart background. Custom uses the individual color pickers in Display instead - Theme Preset overrides them unless set to Custom.")
colorblindMode = input.bool(false, "Colorblind-Safe Signal Colors", group="Theme & Accessibility", tooltip="When on, overrides Bullish/Bearish colors to a colorblind-safe blue/orange palette (Okabe-Ito), regardless of Theme Preset or Custom colors.")

// ---------------------------- INPUTS: DISPLAY ----------------------------
showTable = input.bool(true, "Show Dashboard Table", group="Display")
tablePosIn = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Display")
tableSizeIn = input.string("Normal", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Display")
plotLineWidth = input.int(2, "Oscillator Line Width", minval=1, maxval=5, group="Display", tooltip="Line thickness for the main adaptive oscillator plot (Adaptive RSI in RSI mode, Adaptive MA Distance % in Moving Average mode).")
headerBgColorCustom = input.color(color.new(color.navy, 0), "Custom Table Header Background", group="Display", tooltip="Only applied when Theme Preset is set to Custom.")
headerTextColorCustom = input.color(color.new(color.white, 0), "Custom Table Header Text", group="Display", tooltip="Only applied when Theme Preset is set to Custom.")
bullishColorCustom = input.color(color.new(color.green, 0), "Custom Bullish Color", group="Display", tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe Signal Colors is off.")
bearishColorCustom = input.color(color.new(color.red, 0), "Custom Bearish Color", group="Display", tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe Signal Colors is off.")
neutralColorCustom = input.color(color.new(color.gray, 0), "Custom Neutral/Reference Line Color", group="Display", tooltip="Only applied when Theme Preset is set to Custom.")

// =====================================================================================
// THEME RESOLUTION (Light/Dark/Custom base palette, then Colorblind-Safe override on top)
// =====================================================================================
lightHeaderBg = color.new(color.navy, 0)
lightHeaderText = color.new(color.white, 0)
lightBullish = color.new(color.green, 0)
lightBearish = color.new(color.red, 0)
lightNeutral = color.new(color.gray, 0)

darkHeaderBg = color.new(#1A1F2E, 0)
darkHeaderText = color.new(#E0E0E0, 0)
darkBullish = color.new(#26A69A, 0)
darkBearish = color.new(#EF5350, 0)
darkNeutral = color.new(#787B86, 0)

cbBullish = color.new(#0072B2, 0)
cbBearish = color.new(#E69F00, 0)

headerBgColor = themeMode == "Custom" ? headerBgColorCustom : themeMode == "Dark" ? darkHeaderBg : lightHeaderBg
headerTextColor = themeMode == "Custom" ? headerTextColorCustom : themeMode == "Dark" ? darkHeaderText : lightHeaderText
baseBullishColor = themeMode == "Custom" ? bullishColorCustom : themeMode == "Dark" ? darkBullish : lightBullish
baseBearishColor = themeMode == "Custom" ? bearishColorCustom : themeMode == "Dark" ? darkBearish : lightBearish
neutralColor = themeMode == "Custom" ? neutralColorCustom : themeMode == "Dark" ? darkNeutral : lightNeutral
bullishColor = colorblindMode ? cbBullish : baseBullishColor
bearishColor = colorblindMode ? cbBearish : baseBearishColor

// =====================================================================================
// ROLLING PRICE BUFFER - maintained manually (not raw series[] indexing) so the
// recalibration search can safely look back well beyond typical historical-reference limits
// =====================================================================================
totalHistoryNeeded = evalWindowBars + candidateMaxLen + evalForwardBars + 60

var array<float> closeBuf = array.new_float(0)
array.push(closeBuf, close)
if array.size(closeBuf) > totalHistoryNeeded
    array.shift(closeBuf)

recalibEligible = array.size(closeBuf) >= totalHistoryNeeded and bar_index % recalibBars == 0

// =====================================================================================
// RECALIBRATION - the periodic, bounded candidate search (never runs every bar)
// =====================================================================================
var int adoptedLength = candidateMinLen
var float adoptedFitness = na
var int adoptedEventCount = na
var int lastRecalibBar = na

if recalibEligible
    rawNumCandidates = candidateMaxLen >= candidateMinLen and candidateStep > 0 ? int(math.floor((candidateMaxLen - candidateMinLen) / candidateStep)) + 1 : 1
    numCandidates = math.min(rawNumCandidates, 25)
    bufSize = array.size(closeBuf)

    bestLen = int(na)
    bestFitness = float(na)
    bestEventCount = int(na)

    if optimizationMode == "Moving Average Crossover"
        // Prefix-sum setup: O(bufSize) once, then every candidate's SMA at any point is O(1)
        prefixSum = array.new_float(bufSize + 1, 0.0)
        for i = 0 to bufSize - 1
            array.set(prefixSum, i + 1, array.get(prefixSum, i) + array.get(closeBuf, i))

        for c = 0 to numCandidates - 1
            candLen = math.min(candidateMinLen + c * candidateStep, candidateMaxLen)
            fitnessSum = 0.0
            eventCount = 0
            for p = candidateMaxLen to bufSize - 1 - evalForwardBars
                smaAtP = (array.get(prefixSum, p + 1) - array.get(prefixSum, p + 1 - candLen)) / candLen
                smaAtPrev = (array.get(prefixSum, p) - array.get(prefixSum, p - candLen)) / candLen
                closeAtP = array.get(closeBuf, p)
                closeAtPrev = array.get(closeBuf, p - 1)
                bullCrossEvt = closeAtPrev <= smaAtPrev and closeAtP > smaAtP
                bearCrossEvt = closeAtPrev >= smaAtPrev and closeAtP < smaAtP
                if bullCrossEvt or bearCrossEvt
                    futureClose = array.get(closeBuf, p + evalForwardBars)
                    fwdReturn = closeAtP > 0 ? (futureClose - closeAtP) / closeAtP : 0.0
                    signedReturn = bullCrossEvt ? fwdReturn : -fwdReturn
                    fitnessSum := fitnessSum + signedReturn
                    eventCount := eventCount + 1
            if eventCount >= minEventsForValid
                candFitness = fitnessSum / eventCount
                if na(bestFitness) or candFitness > bestFitness
                    bestFitness := candFitness
                    bestLen := candLen
                    bestEventCount := eventCount
    else
        // RSI Mean-Reversion: Wilder's smoothing is recursive/path-dependent, so each
        // candidate gets one linear walk-forward pass across the buffer (not prefix-summed)
        for c = 0 to numCandidates - 1
            candLen = math.min(candidateMinLen + c * candidateStep, candidateMaxLen)
            sumGain = 0.0
            sumLoss = 0.0
            for i = 1 to candLen
                diffSeed = array.get(closeBuf, i) - array.get(closeBuf, i - 1)
                sumGain := sumGain + math.max(diffSeed, 0.0)
                sumLoss := sumLoss + math.max(-diffSeed, 0.0)
            avgGain = sumGain / candLen
            avgLoss = sumLoss / candLen
            fitnessSum = 0.0
            eventCount = 0
            warmupEnd = candLen + 30
            for p = candLen + 1 to bufSize - 1 - evalForwardBars
                diffStep = array.get(closeBuf, p) - array.get(closeBuf, p - 1)
                gainStep = math.max(diffStep, 0.0)
                lossStep = math.max(-diffStep, 0.0)
                avgGain := (avgGain * (candLen - 1) + gainStep) / candLen
                avgLoss := (avgLoss * (candLen - 1) + lossStep) / candLen
                if p >= warmupEnd
                    rs = avgLoss > 0 ? avgGain / avgLoss : (avgGain > 0 ? 999999.0 : 0.0)
                    rsiVal = 100.0 - (100.0 / (1.0 + rs))
                    oversoldEvt = rsiVal < rsiOversold
                    overboughtEvt = rsiVal > rsiOverbought
                    if oversoldEvt or overboughtEvt
                        closeAtP2 = array.get(closeBuf, p)
                        futureClose2 = array.get(closeBuf, p + evalForwardBars)
                        fwdReturn2 = closeAtP2 > 0 ? (futureClose2 - closeAtP2) / closeAtP2 : 0.0
                        signedReturn2 = oversoldEvt ? fwdReturn2 : -fwdReturn2
                        fitnessSum := fitnessSum + signedReturn2
                        eventCount := eventCount + 1
            if eventCount >= minEventsForValid
                candFitness2 = fitnessSum / eventCount
                if na(bestFitness) or candFitness2 > bestFitness
                    bestFitness := candFitness2
                    bestLen := candLen
                    bestEventCount := eventCount

    if not na(bestLen)
        prevLenForAlert = adoptedLength
        lengthChangedNow = not na(lastRecalibBar) and prevLenForAlert != bestLen
        adoptedLength := bestLen
        adoptedFitness := bestFitness
        adoptedEventCount := bestEventCount
        lastRecalibBar := bar_index
        if lengthChangedNow
            alert("MYND APO: Adopted length changed from " + str.tostring(prevLenForAlert) + " to " + str.tostring(bestLen) + " (" + optimizationMode + ") on " + syminfo.ticker + " (" + timeframe.period + ")", alert.freq_once_per_bar)

// =====================================================================================
// LIVE ENGINE - cheap, single call per bar using the currently adopted length
// =====================================================================================
adaptedMA = ta.sma(close, adoptedLength)

// Manual live RSI - see header comment: ta.rsi()'s length must be a "simple int" and cannot
// accept our runtime-adaptive adoptedLength, so this replicates ta.rsi()'s own Wilder
// recursive formula manually, persisted across bars via var, using adoptedLength each step.
var float avgGainLive = na
var float avgLossLive = na
diffLive = close - close[1]
gainLive = math.max(diffLive, 0.0)
lossLive = math.max(-diffLive, 0.0)
if na(avgGainLive)
    avgGainLive := gainLive
    avgLossLive := lossLive
else
    avgGainLive := (avgGainLive * (adoptedLength - 1) + gainLive) / adoptedLength
    avgLossLive := (avgLossLive * (adoptedLength - 1) + lossLive) / adoptedLength
rsLive = avgLossLive > 0 ? avgGainLive / avgLossLive : (avgGainLive > 0 ? 999999.0 : 0.0)
adaptedRSI = 100.0 - (100.0 / (1.0 + rsLive))

maDistancePct = adaptedMA != 0 ? ((close - adaptedMA) / adaptedMA) * 100 : 0.0

maCrossUp = ta.crossover(close, adaptedMA)
maCrossDown = ta.crossunder(close, adaptedMA)
rsiCrossUp = ta.crossover(adaptedRSI, rsiOversold)
rsiCrossDown = ta.crossunder(adaptedRSI, rsiOverbought)

bullishCrossLive = optimizationMode == "Moving Average Crossover" ? maCrossUp : rsiCrossUp
bearishCrossLive = optimizationMode == "Moving Average Crossover" ? maCrossDown : rsiCrossDown

volSma = ta.sma(volume, volConfirmLen)
volOk = requireVolConfirm ? (volume >= volSma * volConfirmMult) : true

bullishSignal = bullishCrossLive and volOk
bearishSignal = bearishCrossLive and volOk

var string lastEventType = "None"
var int lastEventBar = na
if bullishSignal
    lastEventType := "Bullish Signal"
    lastEventBar := bar_index
if bearishSignal
    lastEventType := "Bearish Signal"
    lastEventBar := bar_index
barsSinceEvent = na(lastEventBar) ? na : bar_index - lastEventBar

// =====================================================================================
// LIVE SIGNAL ACCURACY - self-tracking, rolling window, graded on the tool's own
// already-fired live signals (genuinely out-of-sample vs. the in-sample recalibration score)
// =====================================================================================
var array<float> liveResults = array.new_float(0)
hasHistoryForGrading = bar_index >= evalForwardBars
signalToGradeBull = hasHistoryForGrading ? bullishSignal[evalForwardBars] : false
signalToGradeBear = hasHistoryForGrading ? bearishSignal[evalForwardBars] : false

if signalToGradeBull or signalToGradeBear
    priorClose = close[evalForwardBars]
    outcomeReturn = priorClose > 0 ? (close - priorClose) / priorClose : 0.0
    wasCorrect = signalToGradeBull ? outcomeReturn > 0 : outcomeReturn < 0
    array.push(liveResults, wasCorrect ? 1.0 : 0.0)
    if array.size(liveResults) > rollingWindow
        array.shift(liveResults)

liveAccuracyPct = array.size(liveResults) > 0 ? array.avg(liveResults) * 100 : na
liveTrackedCount = array.size(liveResults)
accuracyLowAlert = liveTrackedCount >= minTrackedForAccuracyAlert and not na(liveAccuracyPct) and liveAccuracyPct < accuracyWarnLevel

// =====================================================================================
// PLOTS
// =====================================================================================
plotRSI = optimizationMode == "RSI Mean-Reversion" ? adaptedRSI : na
plotMADist = optimizationMode == "Moving Average Crossover" ? maDistancePct : na

plot(plotRSI, title="Adaptive RSI", color=neutralColor, linewidth=plotLineWidth)
plot(plotMADist, title="Adaptive MA Distance %", color=neutralColor, linewidth=plotLineWidth)
plot(optimizationMode == "RSI Mean-Reversion" ? rsiOversold : na, title="Oversold Level", color=color.new(bearishColor, 50))
plot(optimizationMode == "RSI Mean-Reversion" ? rsiOverbought : na, title="Overbought Level", color=color.new(bullishColor, 50))
plot(optimizationMode == "RSI Mean-Reversion" ? 50.0 : na, title="RSI Midline", color=color.new(neutralColor, 70))
plot(optimizationMode == "Moving Average Crossover" ? 0.0 : na, title="Zero Line", color=color.new(neutralColor, 70))

plotshape(bullishSignal, title="Bullish Signal", style=shape.triangleup, location=location.bottom, color=bullishColor, size=size.small)
plotshape(bearishSignal, title="Bearish Signal", style=shape.triangledown, location=location.top, color=bearishColor, size=size.small)

// =====================================================================================
// DASHBOARD TABLE
// =====================================================================================
tablePosConst = tablePosIn == "Top Left" ? position.top_left : tablePosIn == "Top Right" ? position.top_right : tablePosIn == "Bottom Left" ? position.bottom_left : position.bottom_right
tableSizeConst = tableSizeIn == "Tiny" ? size.tiny : tableSizeIn == "Small" ? size.small : tableSizeIn == "Large" ? size.large : tableSizeIn == "Huge" ? size.huge : size.normal

var table dash = table.new(tablePosConst, 2, 7, border_width=1)

f_cell(_col, _row, _txt, _bg, _txtcol) =>
    table.cell(dash, _col, _row, _txt, bgcolor=_bg, text_color=_txtcol, text_size=tableSizeConst)

if showTable and barstate.islast
    f_cell(0, 0, "MYND APO v1.0", headerBgColor, headerTextColor)
    f_cell(1, 0, "Status", headerBgColor, headerTextColor)

    f_cell(0, 1, "Optimization Mode", color.new(color.gray, 85), color.black)
    f_cell(1, 1, optimizationMode, color.new(color.gray, 88), color.black)

    lenTxt = na(lastRecalibBar) ? str.tostring(adoptedLength) + " (default, warming up)" : str.tostring(adoptedLength)
    f_cell(0, 2, "Adopted Length", color.new(color.gray, 85), color.black)
    f_cell(1, 2, lenTxt, color.new(neutralColor, 80), color.black)

    fitTxt = na(adoptedFitness) ? "Building..." : str.tostring(adoptedFitness * 100, "#.##") + "% avg / " + str.tostring(adoptedEventCount) + " events"
    f_cell(0, 3, "Last Recalibration Fitness", color.new(color.gray, 85), color.black)
    f_cell(1, 3, fitTxt, color.new(color.gray, 88), color.black)

    accTxt = na(liveAccuracyPct) ? "Building..." : str.tostring(liveAccuracyPct, "#.#") + "% (" + str.tostring(liveTrackedCount) + " tracked)"
    accColor = na(liveAccuracyPct) ? color.new(color.gray, 85) : liveAccuracyPct < accuracyWarnLevel ? color.new(bearishColor, 70) : color.new(bullishColor, 80)
    f_cell(0, 4, "Live Signal Accuracy", color.new(color.gray, 85), color.black)
    f_cell(1, 4, accTxt, accColor, color.black)

    barsUntilNext = recalibBars - (bar_index % recalibBars)
    f_cell(0, 5, "Next Recalibration Attempt", color.new(color.gray, 85), color.black)
    f_cell(1, 5, str.tostring(barsUntilNext) + " bars", color.new(color.gray, 88), color.black)

    lastColor = lastEventType == "Bullish Signal" ? color.new(bullishColor, 70) : lastEventType == "Bearish Signal" ? color.new(bearishColor, 70) : color.new(color.gray, 85)
    lastTxt = na(barsSinceEvent) ? "None yet" : lastEventType + " (" + str.tostring(barsSinceEvent) + " bars ago)"
    f_cell(0, 6, "Last Signal", color.new(color.gray, 85), color.black)
    f_cell(1, 6, lastTxt, lastColor, color.black)

// =====================================================================================
// ALERTS - INDIVIDUAL (standard alertcondition() alerts)
// =====================================================================================
alertcondition(bullishSignal, title="Bullish Signal", message="MYND APO: Bullish signal on {{ticker}} ({{interval}}) - check dashboard for current adopted length.")
alertcondition(bearishSignal, title="Bearish Signal", message="MYND APO: Bearish signal on {{ticker}} ({{interval}}) - check dashboard for current adopted length.")
alertcondition(accuracyLowAlert, title="Live Accuracy Warning", message="MYND APO: Live Signal Accuracy has dropped below your warning level on {{ticker}} ({{interval}}).")

// =====================================================================================
// ALERTS - COMBO BUNDLE
// =====================================================================================
allSignals = bullishSignal or bearishSignal
alertcondition(allSignals, title="ALL Signals", message="MYND APO: Signal on {{ticker}} ({{interval}}) - check chart/dashboard.")

// NOTE: "Adopted Length Changed" is a DIFFERENT alert setup - it uses Pine's dynamic alert()
// function (fired inline in the recalibration block above) since it announces a changing
// numeric value, which alertcondition() cannot do. Set it up via Condition -> this script ->
// "Any alert() function call" - same mechanism already used in MYND Command Center Screener
// and MYND PWEV. See Signals & Alerts tab for full setup instructions.
````
