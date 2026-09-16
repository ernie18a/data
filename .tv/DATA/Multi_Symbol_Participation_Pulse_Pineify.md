<!-- tradingview-pine-id: PUB;3ce0f19b63f249fe829bb653d7657428 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi Symbol Participation Pulse [Pineify]

Source: https://www.tradingview.com/script/283CExyp-Multi-Symbol-Participation-Pulse-Pineify/

## Description

Multi Symbol Participation Pulse [Pineify]

Overview
Multi Symbol Participation Pulse tests whether a chart move has broad support across a custom basket. Its pulse combines return breadth, EMA trend breadth, dispersion, and data coverage. It describes participation, not a forecast or trade signal.

Problem Definition
A simple advance ratio can hide synchronized movement, a few extreme outliers, or a thin sample caused by closed sessions. A one-bar vote also misses established trend position. This script keeps only valid observations in the denominator, separates fast return and slower trend votes, and lowers confidence when votes disagree, dispersion rises, or coverage falls. It measures a finite equal-weight basket, not official exchange breadth.

Design Rationale
Symbols are requested on the chart timeframe with gaps exposed and lookahead disabled. One-bar return direction supplies the fast vote; close versus a configurable EMA supplies slower context. Return dispersion is divided by its rolling EMA, so fragmentation is judged against the basket's recent scale instead of a fixed percentage. Coverage and vote agreement modulate amplitude. This structure suppresses incomplete or internally split evidence even when the raw advance ratio looks decisive.

Key Features

[*]Ten configurable symbol slots with missing and invalid-symbol handling.
[*]Return breadth, trend breadth, coverage, and normalized dispersion.
[*]Confirmed broad-positive, broad-negative, fragmented, and neutral states.
[*]Optional components, halo, rail, divergence markers, dashboard, and alerts.

How It Works
For each valid symbol, the script calculates one-bar return and tests whether close is above its EMA. Positive-return count gives fast participation; above-EMA count gives trend participation. Both ratios are mapped from 0–100% into -100 to +100.

Cross-sectional return standard deviation is divided by its rolling EMA to measure unusual dispersion. Coverage, agreement between the two votes, and dispersion-derived coherence form a bounded confidence term. The pulse blends return and trend votes 55/45 and reduces amplitude when evidence is weak. High relative dispersion also widens the halo.

States update only on confirmed bars. Broad states require the pulse threshold and both votes on the same side of 50%; hysteresis limits threshold chatter. Too few active symbols, low coverage, or warm-up produces no pulse. Invalid symbols return missing data rather than terminating the script. A lower rail maps dispersion into a fixed visual zone.

How Multiple Indicators Work Together
The components form one causal chain. Return breadth detects current participation but can chatter. Trend breadth adds persistence but lags. Dispersion reveals whether votes are compact or split by outliers. Coverage tests whether the sample is representative. Removing a component could make the result lag, overreact, hide fragmentation, or overstate a thin sample; their roles are not interchangeable.

Trading Ideas and Insights
Use the pulse as context, not an entry command. Broad states test whether a move is shared by selected proxies. Fragmentation flags disagreement between headline direction and internal distribution. Fixed-window divergence markers identify price/pulse disagreement for review, not a promised reversal. Compare similar sessions and build the basket around one coherent question.

Unique Aspects
Common breadth plots stop at an advance percentage or advance-decline difference. Here, fast and slow votes remain visible, dispersion is normalized to the basket's history, missing coverage reduces confidence, and confirmed hysteresis limits threshold chatter. Halo width exposes dispersion instead of hiding uncertainty behind the composite line, while the lower rail keeps fragmentation in a stable visual location.

How to Use

[*]Choose a coherent basket and disable unused slots.
[*]Check active coverage before interpreting the pulse.
[*]Read sign and state color, then inspect component separation and halo width.
[*]Use confirmed alerts beside price structure, liquidity, and risk controls.

The default US ETF basket is only an example.

Customization
EMA length controls the slower vote, while the dispersion baseline defines ordinary spread. Minimum active symbols and coverage set the evidence floor. Broad threshold and hysteresis balance sensitivity against stability. Fragmentation and agreement settings govern conflict states. Divergence settings control markers. Visual layers can be hidden without changing calculations.

Assumptions and Limitations
Every enabled symbol receives one vote; there are no constituent weights, official breadth, order flow, or membership data. Sessions, holidays, stale markets, delayed feeds, and permissions can reduce coverage or desynchronize timestamps. Gaps are exposed, so the active subset may change. EMA and dispersion baselines lag and depend on parameters. Pulse, halo, and divergence can change intrabar; states and alerts confirm at bar close. Fixed-window divergence is descriptive, not a reversal prediction. The script does not estimate probability, expected return, sizing, execution, or profitability.

Conclusion
Multi Symbol Participation Pulse turns a custom basket into an auditable breadth portrait. It separates fast and trend participation, dispersion, and coverage, then displays direction and uncertainty together. Use it while respecting asynchronous equal-weight data limits.

---

## Source Code

````pine
//@version=6
indicator("Multi Symbol Participation Pulse [Pineify]", shorttitle="MSPP [Pineify]", overlay=false)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string GROUP_BASKET = "Symbol basket"
string GROUP_MODEL = "Participation model"
string GROUP_VISUALS = "Visual system"

enable1 = input.bool(true, "Enable 1", inline="s1", group=GROUP_BASKET)
symbol1 = input.symbol("AMEX:SPY", "Symbol 1", inline="s1", group=GROUP_BASKET)
enable2 = input.bool(true, "Enable 2", inline="s2", group=GROUP_BASKET)
symbol2 = input.symbol("NASDAQ:QQQ", "Symbol 2", inline="s2", group=GROUP_BASKET)
enable3 = input.bool(true, "Enable 3", inline="s3", group=GROUP_BASKET)
symbol3 = input.symbol("AMEX:IWM", "Symbol 3", inline="s3", group=GROUP_BASKET)
enable4 = input.bool(true, "Enable 4", inline="s4", group=GROUP_BASKET)
symbol4 = input.symbol("AMEX:DIA", "Symbol 4", inline="s4", group=GROUP_BASKET)
enable5 = input.bool(true, "Enable 5", inline="s5", group=GROUP_BASKET)
symbol5 = input.symbol("AMEX:XLK", "Symbol 5", inline="s5", group=GROUP_BASKET)
enable6 = input.bool(true, "Enable 6", inline="s6", group=GROUP_BASKET)
symbol6 = input.symbol("AMEX:XLF", "Symbol 6", inline="s6", group=GROUP_BASKET)
enable7 = input.bool(true, "Enable 7", inline="s7", group=GROUP_BASKET)
symbol7 = input.symbol("AMEX:XLE", "Symbol 7", inline="s7", group=GROUP_BASKET)
enable8 = input.bool(true, "Enable 8", inline="s8", group=GROUP_BASKET)
symbol8 = input.symbol("AMEX:XLV", "Symbol 8", inline="s8", group=GROUP_BASKET)
enable9 = input.bool(true, "Enable 9", inline="s9", group=GROUP_BASKET)
symbol9 = input.symbol("AMEX:XLI", "Symbol 9", inline="s9", group=GROUP_BASKET)
enable10 = input.bool(true, "Enable 10", inline="s10", group=GROUP_BASKET)
symbol10 = input.symbol("AMEX:XLY", "Symbol 10", inline="s10", group=GROUP_BASKET)

trendLength = input.int(34, "Trend EMA length", minval=5, maxval=200, group=GROUP_MODEL)
dispersionLookback = input.int(50, "Dispersion baseline length", minval=10, maxval=300, group=GROUP_MODEL)
minimumActive = input.int(3, "Minimum active symbols", minval=2, maxval=10, group=GROUP_MODEL)
minimumCoverage = input.float(0.60, "Minimum basket coverage", minval=0.20, maxval=1.00, step=0.05, group=GROUP_MODEL)
broadThreshold = input.float(32.0, "Broad participation threshold", minval=10.0, maxval=80.0, step=1.0, group=GROUP_MODEL)
hysteresis = input.float(10.0, "State retention threshold", minval=0.0, maxval=30.0, step=1.0, group=GROUP_MODEL)
fragmentationRatio = input.float(1.35, "Fragmentation dispersion ratio", minval=0.75, maxval=3.00, step=0.05, group=GROUP_MODEL)
agreementFloor = input.float(0.55, "Return / trend agreement floor", minval=0.20, maxval=0.90, step=0.05, group=GROUP_MODEL)
divergenceLookback = input.int(12, "Divergence comparison bars", minval=3, maxval=100, group=GROUP_MODEL)
divergencePulseChange = input.float(18.0, "Minimum divergence pulse change", minval=5.0, maxval=60.0, step=1.0, group=GROUP_MODEL)

showComponents = input.bool(true, "Show participation components", group=GROUP_VISUALS)
showDispersionRail = input.bool(true, "Show dispersion rail", group=GROUP_VISUALS)
showStateWash = input.bool(true, "Show state background", group=GROUP_VISUALS)
showDivergence = input.bool(true, "Show chart / breadth divergence", group=GROUP_VISUALS)
showDashboard = input.bool(true, "Show basket dashboard", group=GROUP_VISUALS)

bullColor = input.color(color.rgb(18, 190, 168), "Broad positive", group=GROUP_VISUALS)
bearColor = input.color(color.rgb(226, 82, 128), "Broad negative", group=GROUP_VISUALS)
fragmentColor = input.color(color.rgb(245, 158, 11), "Fragmented", group=GROUP_VISUALS)
returnColor = input.color(color.rgb(56, 189, 248), "Return participation", group=GROUP_VISUALS)
trendColor = input.color(color.rgb(167, 139, 250), "Trend participation", group=GROUP_VISUALS)
neutralColor = input.color(color.rgb(148, 163, 184), "Neutral / insufficient", group=GROUP_VISUALS)

//------------------------------------------------------------------------------
// Fixed, bounded cross-symbol requests
//------------------------------------------------------------------------------
[c1, p1, e1] = request.security(symbol1, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c2, p2, e2] = request.security(symbol2, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c3, p3, e3] = request.security(symbol3, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c4, p4, e4] = request.security(symbol4, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c5, p5, e5] = request.security(symbol5, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c6, p6, e6] = request.security(symbol6, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c7, p7, e7] = request.security(symbol7, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c8, p8, e8] = request.security(symbol8, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c9, p9, e9] = request.security(symbol9, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[c10, p10, e10] = request.security(symbol10, timeframe.period, [close, close[1], ta.ema(close, trendLength)], gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

f_clamp(float value, float lower, float upper) =>
    math.min(math.max(value, lower), upper)

v1 = enable1 and not na(c1) and not na(p1) and p1 != 0.0 and not na(e1)
v2 = enable2 and not na(c2) and not na(p2) and p2 != 0.0 and not na(e2)
v3 = enable3 and not na(c3) and not na(p3) and p3 != 0.0 and not na(e3)
v4 = enable4 and not na(c4) and not na(p4) and p4 != 0.0 and not na(e4)
v5 = enable5 and not na(c5) and not na(p5) and p5 != 0.0 and not na(e5)
v6 = enable6 and not na(c6) and not na(p6) and p6 != 0.0 and not na(e6)
v7 = enable7 and not na(c7) and not na(p7) and p7 != 0.0 and not na(e7)
v8 = enable8 and not na(c8) and not na(p8) and p8 != 0.0 and not na(e8)
v9 = enable9 and not na(c9) and not na(p9) and p9 != 0.0 and not na(e9)
v10 = enable10 and not na(c10) and not na(p10) and p10 != 0.0 and not na(e10)

r1 = v1 ? c1 / p1 - 1.0 : 0.0
r2 = v2 ? c2 / p2 - 1.0 : 0.0
r3 = v3 ? c3 / p3 - 1.0 : 0.0
r4 = v4 ? c4 / p4 - 1.0 : 0.0
r5 = v5 ? c5 / p5 - 1.0 : 0.0
r6 = v6 ? c6 / p6 - 1.0 : 0.0
r7 = v7 ? c7 / p7 - 1.0 : 0.0
r8 = v8 ? c8 / p8 - 1.0 : 0.0
r9 = v9 ? c9 / p9 - 1.0 : 0.0
r10 = v10 ? c10 / p10 - 1.0 : 0.0

enabledCount = (enable1 ? 1.0 : 0.0) + (enable2 ? 1.0 : 0.0) + (enable3 ? 1.0 : 0.0) + (enable4 ? 1.0 : 0.0) + (enable5 ? 1.0 : 0.0) + (enable6 ? 1.0 : 0.0) + (enable7 ? 1.0 : 0.0) + (enable8 ? 1.0 : 0.0) + (enable9 ? 1.0 : 0.0) + (enable10 ? 1.0 : 0.0)
activeCount = (v1 ? 1.0 : 0.0) + (v2 ? 1.0 : 0.0) + (v3 ? 1.0 : 0.0) + (v4 ? 1.0 : 0.0) + (v5 ? 1.0 : 0.0) + (v6 ? 1.0 : 0.0) + (v7 ? 1.0 : 0.0) + (v8 ? 1.0 : 0.0) + (v9 ? 1.0 : 0.0) + (v10 ? 1.0 : 0.0)
upCount = (v1 and r1 > 0.0 ? 1.0 : 0.0) + (v2 and r2 > 0.0 ? 1.0 : 0.0) + (v3 and r3 > 0.0 ? 1.0 : 0.0) + (v4 and r4 > 0.0 ? 1.0 : 0.0) + (v5 and r5 > 0.0 ? 1.0 : 0.0) + (v6 and r6 > 0.0 ? 1.0 : 0.0) + (v7 and r7 > 0.0 ? 1.0 : 0.0) + (v8 and r8 > 0.0 ? 1.0 : 0.0) + (v9 and r9 > 0.0 ? 1.0 : 0.0) + (v10 and r10 > 0.0 ? 1.0 : 0.0)
trendCount = (v1 and c1 > e1 ? 1.0 : 0.0) + (v2 and c2 > e2 ? 1.0 : 0.0) + (v3 and c3 > e3 ? 1.0 : 0.0) + (v4 and c4 > e4 ? 1.0 : 0.0) + (v5 and c5 > e5 ? 1.0 : 0.0) + (v6 and c6 > e6 ? 1.0 : 0.0) + (v7 and c7 > e7 ? 1.0 : 0.0) + (v8 and c8 > e8 ? 1.0 : 0.0) + (v9 and c9 > e9 ? 1.0 : 0.0) + (v10 and c10 > e10 ? 1.0 : 0.0)
sumReturn = r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + r10
sumReturnSq = r1 * r1 + r2 * r2 + r3 * r3 + r4 * r4 + r5 * r5 + r6 * r6 + r7 * r7 + r8 * r8 + r9 * r9 + r10 * r10

//------------------------------------------------------------------------------
// Reliability-gated participation pulse and state memory
//------------------------------------------------------------------------------
readyCount = enabledCount >= float(minimumActive) and activeCount >= float(minimumActive)
coverage = enabledCount > 0.0 ? activeCount / enabledCount : 0.0
ready = readyCount and coverage >= minimumCoverage
meanReturn = activeCount > 0.0 ? sumReturn / activeCount : na
dispersion = activeCount > 1.0 ? math.sqrt(math.max(sumReturnSq / activeCount - meanReturn * meanReturn, 0.0)) : na
dispersionBaseline = ta.ema(dispersion, dispersionLookback)
dispersionRatioValue = ready and dispersionBaseline > 0.0 ? dispersion / dispersionBaseline : 0.0
coherence = ready ? 1.0 / (1.0 + math.max(dispersionRatioValue, 0.0)) : 0.0
dispersionIntensity = ready ? f_clamp((dispersionRatioValue - 0.50) / 1.50, 0.0, 1.0) : 0.0

upRatio = ready ? upCount / activeCount : na
trendRatio = ready ? trendCount / activeCount : na
agreement = ready ? 1.0 - math.abs(upRatio - trendRatio) : 0.0
returnComponent = ready ? 100.0 * (2.0 * upRatio - 1.0) : na
trendComponent = ready ? 100.0 * (2.0 * trendRatio - 1.0) : na
confidence = ready ? f_clamp(coverage * agreement * (0.35 + 0.65 * coherence), 0.0, 1.0) : 0.0
rawPulse = ready ? 0.55 * returnComponent + 0.45 * trendComponent : na
pulse = ready ? rawPulse * (0.45 + 0.55 * confidence) : na
fragmented = ready and (dispersionRatioValue >= fragmentationRatio or agreement <= agreementFloor)

var int participationState = 0
if barstate.isconfirmed
    if not ready
        participationState := 0
    else if fragmented
        participationState := 2
    else if pulse >= broadThreshold and upRatio > 0.50 and trendRatio > 0.50
        participationState := 1
    else if pulse <= -broadThreshold and upRatio < 0.50 and trendRatio < 0.50
        participationState := -1
    else if participationState == 1 and pulse > hysteresis
        participationState := 1
    else if participationState == -1 and pulse < -hysteresis
        participationState := -1
    else
        participationState := 0

stateColor = participationState == 1 ? bullColor : participationState == -1 ? bearColor : participationState == 2 ? fragmentColor : neutralColor
haloWidth = ready ? 4.0 + 18.0 * dispersionIntensity : na
haloUpper = ready ? math.min(100.0, pulse + haloWidth) : na
haloLower = ready ? math.max(-100.0, pulse - haloWidth) : na
fillTransparency = int(math.round(f_clamp(90.0 - 22.0 * confidence, 62.0, 92.0)))

bullishDivergence = showDivergence and ready and barstate.isconfirmed and close < close[divergenceLookback] and pulse - pulse[divergenceLookback] >= divergencePulseChange
bearishDivergence = showDivergence and ready and barstate.isconfirmed and close > close[divergenceLookback] and pulse - pulse[divergenceLookback] <= -divergencePulseChange

//------------------------------------------------------------------------------
// Participation portrait
//------------------------------------------------------------------------------
hline(0.0, "Neutral axis", color=color.new(neutralColor, 55), linestyle=hline.style_dotted)
hline(100.0, "Upper scale", color=color.new(neutralColor, 92))
hline(-100.0, "Lower scale", color=color.new(neutralColor, 92))
hline(broadThreshold, "Broad positive threshold", color=color.new(bullColor, 78), linestyle=hline.style_dashed)
hline(-broadThreshold, "Broad negative threshold", color=color.new(bearColor, 78), linestyle=hline.style_dashed)

upperPlot = plot(haloUpper, "Dispersion Halo Upper", color=color.new(stateColor, 100))
lowerPlot = plot(haloLower, "Dispersion Halo Lower", color=color.new(stateColor, 100))
fill(upperPlot, lowerPlot, color=ready ? color.new(stateColor, fillTransparency) : na, title="Dispersion Halo")

plot(pulse, "Participation Pulse Halo", color=ready ? color.new(stateColor, 80) : na, linewidth=8)
plot(pulse, "Participation Pulse", color=ready ? stateColor : na, linewidth=3)
plot(showComponents ? returnComponent : na, "Return Participation", color=color.new(returnColor, 18), linewidth=1)
plot(showComponents ? trendComponent : na, "Trend Participation", color=color.new(trendColor, 18), linewidth=1)
dispersionRail = showDispersionRail and ready ? -100.0 + 26.0 * dispersionIntensity : na
plot(dispersionRail, "Dispersion Rail", color=color.new(fragmentColor, 20), style=plot.style_columns, histbase=-100.0)

bgcolor(showStateWash and ready and participationState != 0 ? color.new(stateColor, 92) : na, title="Participation State Wash")
plotshape(bullishDivergence, title="Bullish Chart Breadth Divergence", style=shape.triangleup, location=location.bottom, color=bullColor, size=size.tiny, text="B+")
plotshape(bearishDivergence, title="Bearish Chart Breadth Divergence", style=shape.triangledown, location=location.top, color=bearColor, size=size.tiny, text="B-")

//------------------------------------------------------------------------------
// Dashboard and confirmed alerts
//------------------------------------------------------------------------------
var table dashboard = table.new(position.top_right, 2, 7, border_width=1)
if barstate.islast
    if showDashboard
        stateText = not readyCount ? "TOO FEW SYMBOLS" : coverage < minimumCoverage ? "LOW COVERAGE" : participationState == 1 ? "BROAD POSITIVE" : participationState == -1 ? "BROAD NEGATIVE" : participationState == 2 ? "FRAGMENTED" : "NEUTRAL"
        table.cell(dashboard, 0, 0, "PARTICIPATION", text_color=color.white, bgcolor=color.rgb(36, 42, 54))
        table.cell(dashboard, 1, 0, stateText, text_color=color.white, bgcolor=color.new(stateColor, 15))
        table.cell(dashboard, 0, 1, "Active / enabled", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 1, str.tostring(activeCount, "#") + " / " + str.tostring(enabledCount, "#"), text_color=ready ? color.white : neutralColor, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 0, 2, "Up participation", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 2, ready ? str.tostring(100.0 * upRatio, "#.0") + "%" : "n/a", text_color=returnColor, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 0, 3, "Trend participation", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 3, ready ? str.tostring(100.0 * trendRatio, "#.0") + "%" : "n/a", text_color=trendColor, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 0, 4, "Dispersion ratio", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 4, ready ? str.tostring(dispersionRatioValue, "#.00") + "x" : "n/a", text_color=fragmentColor, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 0, 5, "Pulse", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 5, ready ? str.tostring(pulse, "#.0") : "n/a", text_color=stateColor, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 0, 6, "Coverage", text_color=color.silver, bgcolor=color.new(color.black, 20))
        table.cell(dashboard, 1, 6, str.tostring(100.0 * coverage, "#.0") + "%", text_color=coverage >= minimumCoverage ? color.white : fragmentColor, bgcolor=color.new(color.black, 20))
    else
        table.clear(dashboard, 0, 0, 1, 6)

confirmedBroadPositive = barstate.isconfirmed and participationState == 1 and participationState[1] != 1
confirmedBroadNegative = barstate.isconfirmed and participationState == -1 and participationState[1] != -1
confirmedFragmentation = barstate.isconfirmed and participationState == 2 and participationState[1] != 2

alertcondition(confirmedBroadPositive, "Broad positive participation", "The completed bar entered broad positive participation for the selected symbol basket.")
alertcondition(confirmedBroadNegative, "Broad negative participation", "The completed bar entered broad negative participation for the selected symbol basket.")
alertcondition(confirmedFragmentation, "Basket fragmentation", "The completed bar entered a high-dispersion or low-agreement participation state.")
alertcondition(bullishDivergence, "Bullish chart breadth divergence", "The chart price declined over the comparison window while the selected basket participation pulse improved.")
alertcondition(bearishDivergence, "Bearish chart breadth divergence", "The chart price advanced over the comparison window while the selected basket participation pulse weakened.")
````
