<!-- tradingview-pine-id: PUB;f400a19f40fb4fb5bdee31ac010d504b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Rolling Z Score Reversion Map [Pineify]

Source: https://www.tradingview.com/script/XaCB6ar0-Rolling-Z-Score-Reversion-Map-Pineify/

## Description

Rolling Z Score Reversion Map [Pineify]

Overview
This map keeps rolling price Z-score visible while separating reversion-eligible extremes from trend-aligned extremes. It describes context; it does not forecast returns or issue trades.

Problem Definition
Z-score measures distance from a rolling mean in deviation units. Fixed lines such as +2 and -2 treat every extreme alike. That fails when the mean moves: positive Z can persist with a rising mean, so a contrarian reading confuses extension with disequilibrium. The script preserves raw Z and asks separately whether aligned trend and range pressure should withhold a reversion watch.

Design Rationale
Raw Z remains unchanged so its units stay interpretable. Mean slope is expressed as ATR per bar for cross-market comparison. ATR uses a prior-only percentile to avoid fixed price units and candidate self-ranking. Sign alignment isolates positive deviation with rising mean and its negative mirror. High ATR rank adds pressure but cannot dominate alone. A finite closed-bar watch preserves event order; permanent extreme marks would duplicate events. Lag and confirmation delay are accepted for auditable states.

Key Features

[*]Raw Z-score with symmetric rails.
[*]ATR-normalized slope, prior-only ATR rank, and direction gate.
[*]Confirmed watch with mean, pressure, data, and time exits.
[*]Optional visuals, table, and two alerts.

How It Works
The script computes a rolling mean and deviation of closes. Raw Z is their price difference divided by deviation; a near-zero denominator returns no value.

ATR defines range scale. Its percentile is a midrank against N prior ATR values: lower samples vote one and ties half. Current ATR is excluded. Mean change over the slope span is divided by ATR and bar count to obtain ATR per bar.

The gate tests whether Z and slope share a sign. Pressure combines 65% aligned trend strength, 20% upper-half ATR expansion, and 15% trend-volatility interaction, bounded from zero to one. An extreme qualifies when absolute Z reaches its rail and pressure stays below the gate.

A newly qualified close freezes watch side and entry Z. The watch ends on a crossing of the evolving mean, expiry, invalid data, or an invalidation-rail extreme with excessive pressure. A crossing is only observed, not caused. Warm-up covers all windows and rank history. Live colors can change; watches, markers, and alerts update on confirmed bars.

How Multiple Indicators Work Together
The components form one filter. Z supplies distance but not reference motion. ATR-normalized slope supplies motion; sign alignment relates it to the deviation. Prior ATR rank adds portable range context. Together they decide whether an extreme starts a watch. Without slope, the fixed-threshold failure returns; without ATR, calm and expansion are alike; without the watch, event chronology disappears.

Trading Ideas and Insights
Use the map to organize observation, not assume reversal. Cyan means pressure is below the gate and an extreme can start a confirmed watch. Orange means the same raw distance has stronger continuation context, so a contrarian label is withheld. A gold zero-axis marker records a later mean crossing. Compare states to find where fixed Z thresholds misdescribe context.

Unique Aspects
The contribution is separating measurement from interpretation. Many filters rescale an oscillator, preventing comparison with ordinary Z rails. Here raw distance stays intact while a bounded, direction-sensitive, range-relative gate classifies events. The watch preserves sequence: qualification occurs first; later bars cross the evolving mean or invalidate. No result is moved backward and no probability is implied.

How to Use
After warm-up, read height as raw Z and color as context. Cyan marks a candidate or active watch, orange a higher-pressure extreme, and gray a balanced or unavailable state. Diamonds and alerts mark confirmed entry. A zero circle records a watched crossing; an orange cross records invalidation. Use 15-minute to weekly charts and Once Per Bar Close alerts. These are states, not trade instructions.

Customization
Z window sets reference horizon; Extreme threshold sets event distance. ATR window and rank length set range context and history needs. Slope span smooths motion; Full trend pressure maps ATR-per-bar slope to full strength. Lower Maximum pressure tightens qualification. Invalidation Z and Maximum watch bars bound observation life. Visual layers can be disabled independently while raw Z and rails remain. Colors support varied themes.

Assumptions and Limitations
Rolling statistics change as samples enter and leave; Z implies neither normality nor stationarity. ATR rank is empirical, not probability, and needs complete history. Weights are design choices, not optimized constants. Slope lags; gaps can outrun it. The watch targets an evolving mean, not the entry mean. Live visuals are provisional, and confirmed events still depend on feed history. Inputs, adjustments, and synthetic charts can change results. Execution, costs, sizing, news, structure, and future returns are outside scope. Pineify checks syntax, not market behavior.

Conclusion
The map adds auditable context without changing Z-score units. Distance remains distance; trend, volatility, and watch state change only its label. Keep lag, sensitivity, and scope explicit.

---

## Source Code

````pine
//@version=6
indicator("Rolling Z Score Reversion Map [Pineify]", overlay = false, max_bars_back = 1201, precision = 2)

// Independent implementation. The raw Z-score is never rescaled by the context gate.
// Context classifies an extreme; it does not predict that price must revert or continue.
int zLength = input.int(100, "Z-score window", minval = 20, maxval = 500, group = "Standardization")
float entryZ = input.float(2.0, "Extreme threshold", minval = 1.0, maxval = 4.0, step = 0.1, group = "Standardization")
int atrLength = input.int(14, "ATR window", minval = 2, maxval = 100, group = "Context gate")
int atrRankLength = input.int(200, "Prior bars for ATR rank", minval = 50, maxval = 500, group = "Context gate")
int slopeLength = input.int(20, "Mean slope span", minval = 2, maxval = 100, group = "Context gate")
float fullTrendScale = input.float(0.08, "Full trend pressure (ATR per bar)", minval = 0.01, maxval = 0.50, step = 0.01, group = "Context gate")
float maxContinuation = input.float(0.55, "Maximum pressure for reversion watch", minval = 0.10, maxval = 0.90, step = 0.05, group = "Context gate")
float invalidationZ = input.float(3.5, "Watch invalidation Z", minval = 2.1, maxval = 6.0, step = 0.1, group = "Observation")
int maxWatchBars = input.int(40, "Maximum watch bars", minval = 5, maxval = 200, group = "Observation")
bool showHalo = input.bool(true, "Show context halo", group = "Visuals")
bool showFill = input.bool(true, "Show zero-axis fill", group = "Visuals")
bool showBackground = input.bool(true, "Show state background", group = "Visuals")
bool showMarkers = input.bool(true, "Show confirmed event markers", group = "Visuals")
bool showTable = input.bool(true, "Show context table", group = "Visuals")
color watchColor = input.color(#00A6A6, "Reversion-watch color", group = "Colors")
color extensionColor = input.color(#E06B3C, "Trend-extension color", group = "Colors")
color neutralColor = input.color(#7D8797, "Neutral color", group = "Colors")
color resolvedColor = input.color(#C49A28, "Observed mean-return color", group = "Colors")

f_clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

// Midrank against completed prior observations. Current ATR never votes in its own rank.
f_priorRank(float value, int length) =>
    float votes = 0.0
    int samples = 0
    if not na(value)
        for i = 1 to length
            float prior = value[i]
            if not na(prior)
                samples += 1
                votes += value > prior ? 1.0 : value == prior ? 0.5 : 0.0
    samples == length ? 100.0 * votes / length : na

f_number(float value, string pattern) =>
    na(value) ? "--" : str.tostring(value, pattern)

float mean = ta.sma(close, zLength)
float deviation = ta.stdev(close, zLength)
float scaleFloor = math.max(syminfo.mintick, 1e-10)
float z = not na(deviation) and deviation > scaleFloor ? (close - mean) / deviation : na
float atr = ta.atr(atrLength)
float atrRank = f_priorRank(atr, atrRankLength)
float meanSlopeAtr = not na(mean[slopeLength]) and atr > scaleFloor ? (mean - mean[slopeLength]) / (atr * slopeLength) : na
float trendStrength = not na(meanSlopeAtr) ? f_clamp(math.abs(meanSlopeAtr) / fullTrendScale, 0.0, 1.0) : na
float volatilityExpansion = not na(atrRank) ? f_clamp((atrRank - 50.0) / 50.0, 0.0, 1.0) : na
bool ready = not na(z) and not na(trendStrength) and not na(volatilityExpansion)
bool aligned = ready and z * meanSlopeAtr > 0.0
float continuationPressure = ready ? f_clamp((aligned ? 0.65 * trendStrength : 0.0) + 0.20 * volatilityExpansion + 0.15 * trendStrength * volatilityExpansion, 0.0, 1.0) : na
float reversionEligibility = ready ? 100.0 * (1.0 - continuationPressure) : na
bool extreme = ready and math.abs(z) >= entryZ
bool eligibleExtreme = extreme and continuationPressure <= maxContinuation
bool extensionExtreme = extreme and continuationPressure > maxContinuation
bool newEligibleExtreme = eligibleExtreme and not eligibleExtreme[1]

bool crossedDownMean = ta.crossunder(z, 0.0)
bool crossedUpMean = ta.crossover(z, 0.0)
var int watchSide = 0
var int watchAge = 0
var float watchEntryZ = na
bool watchStarted = false
bool meanReturnObserved = false
bool watchInvalidated = false

if barstate.isconfirmed
    if watchSide != 0
        watchAge += 1
        bool crossedMean = watchSide == 1 ? crossedDownMean : crossedUpMean
        bool pressureInvalidation = math.abs(z) >= invalidationZ and continuationPressure > maxContinuation
        bool dataInvalidation = not ready
        bool timeInvalidation = watchAge >= maxWatchBars
        if crossedMean
            meanReturnObserved := true
            watchSide := 0
            watchAge := 0
            watchEntryZ := na
        else if pressureInvalidation or dataInvalidation or timeInvalidation
            watchInvalidated := true
            watchSide := 0
            watchAge := 0
            watchEntryZ := na
    if watchSide == 0 and newEligibleExtreme
        watchSide := z > 0.0 ? 1 : -1
        watchAge := 0
        watchEntryZ := z
        watchStarted := true

bool watchActive = watchSide != 0
string stateName = not ready ? "WARMUP / DATA" : watchActive ? (watchSide > 0 ? "UPPER WATCH" : "LOWER WATCH") : extensionExtreme ? (z > 0.0 ? "UP EXTENSION" : "DOWN EXTENSION") : eligibleExtreme ? (z > 0.0 ? "UP CANDIDATE" : "DOWN CANDIDATE") : "BALANCED"
color stateColor = not ready ? neutralColor : watchActive or eligibleExtreme ? watchColor : extensionExtreme ? extensionColor : neutralColor
int stateCode = not ready ? 0 : watchActive ? (watchSide > 0 ? 1 : -1) : extensionExtreme ? (z > 0.0 ? 2 : -2) : eligibleExtreme ? (z > 0.0 ? 3 : -3) : 0

hline(0.0, "Rolling mean axis", color.new(chart.fg_color, 65))
hline(entryZ, "Upper extreme rail", color.new(chart.fg_color, 58), hline.style_dashed)
hline(-entryZ, "Lower extreme rail", color.new(chart.fg_color, 58), hline.style_dashed)
hline(invalidationZ, "Upper invalidation rail", color.new(extensionColor, 78), hline.style_dotted)
hline(-invalidationZ, "Lower invalidation rail", color.new(extensionColor, 78), hline.style_dotted)

plot(showHalo and eligibleExtreme ? z : na, "Eligible extreme halo", color.new(watchColor, barstate.isconfirmed ? 52 : 76), 9, plot.style_line, display = display.pane)
plot(showHalo and extensionExtreme ? z : na, "Trend extension halo", color.new(extensionColor, barstate.isconfirmed ? 52 : 76), 9, plot.style_line, display = display.pane)
zeroAxis = plot(0.0, "Zero fill anchor", color = color.new(chart.fg_color, 100), display = display.pane)
zCore = plot(ready ? z : na, "Raw rolling Z-score", color.new(stateColor, barstate.isconfirmed ? 0 : 34), 2, plot.style_line, display = display.pane)
fill(zCore, zeroAxis, color = showFill and ready ? color.new(stateColor, extensionExtreme or eligibleExtreme or watchActive ? 86 : 94) : na, title = "Context field")
bgcolor(showBackground and ready ? color.new(stateColor, extensionExtreme or watchActive ? 92 : 97) : na, title = "State background")
plotshape(showMarkers and watchStarted ? z : na, "Confirmed reversion watch", shape.diamond, location.absolute, watchColor, size = size.tiny, display = display.pane)
plotshape(showMarkers and meanReturnObserved ? 0.0 : na, "Observed mean return", shape.circle, location.absolute, resolvedColor, size = size.small, display = display.pane)
plotshape(showMarkers and watchInvalidated ? z : na, "Watch invalidated", shape.xcross, location.absolute, extensionColor, size = size.tiny, display = display.pane)

plot(ready ? atrRank : na, "ATR prior percentile", display = display.data_window)
plot(ready ? meanSlopeAtr : na, "Mean slope (ATR per bar)", display = display.data_window)
plot(ready ? continuationPressure * 100.0 : na, "Continuation pressure (%)", display = display.data_window)
plot(ready ? reversionEligibility : na, "Reversion eligibility (%)", display = display.data_window)
plot(ready ? stateCode : na, "State code: +/-1 watch, +/-2 extension, +/-3 candidate", display = display.data_window)
plot(watchActive ? watchEntryZ : na, "Active watch entry Z", display = display.data_window)

var table panel = table.new(position.top_right, 2, 7, bgcolor = color.new(chart.bg_color, 8), frame_color = color.new(chart.fg_color, 76), frame_width = 1)
if barstate.islast
    if showTable
        table.cell(panel, 0, 0, "Z MAP", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 1, 0, barstate.isconfirmed ? "CLOSED" : "LIVE", text_color = stateColor, text_size = size.small)
        table.cell(panel, 0, 1, "State", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 1, 1, stateName, text_color = stateColor, text_size = size.small)
        table.cell(panel, 0, 2, "Raw Z", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 1, 2, f_number(z, "#.00"), text_color = stateColor, text_size = size.small)
        table.cell(panel, 0, 3, "Trend / bar", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 1, 3, f_number(meanSlopeAtr, "#.000") + " ATR", text_color = aligned ? extensionColor : chart.fg_color, text_size = size.small)
        table.cell(panel, 0, 4, "ATR rank", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 1, 4, f_number(atrRank, "#.0") + "%", text_color = volatilityExpansion > 0.5 ? extensionColor : chart.fg_color, text_size = size.small)
        table.cell(panel, 0, 5, "Pressure", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 1, 5, f_number(continuationPressure * 100.0, "#.0") + "%", text_color = continuationPressure > maxContinuation ? extensionColor : watchColor, text_size = size.small)
        table.cell(panel, 0, 6, "Watch age", text_color = chart.fg_color, text_size = size.small)
        table.cell(panel, 1, 6, watchActive ? str.tostring(watchAge) + "/" + str.tostring(maxWatchBars) : "--", text_color = watchActive ? watchColor : chart.fg_color, text_size = size.small)
    else
        table.clear(panel, 0, 0, 1, 6)

alertcondition(watchStarted, "Reversion-eligible extreme confirmed", "Rolling Z Score Reversion Map: a context-eligible Z-score extreme was confirmed on {{ticker}} {{interval}}.")
alertcondition(meanReturnObserved, "Observed return through rolling mean", "Rolling Z Score Reversion Map: an active extreme watch crossed the rolling mean on {{ticker}} {{interval}}.")
````
