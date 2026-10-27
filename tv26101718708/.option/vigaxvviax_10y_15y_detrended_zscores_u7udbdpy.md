# VIGAX/VVIAX 10Y & 15Y Detrended Z-Scores

- url: https://www.tradingview.com/script/u7UDbdpY-VIGAX-VVIAX-10Y-15Y-Detrended-Z-Scores/
- type: indicator
- pine_id: PUB;6472214665634a62bf4d79fb944a3c50
- version: 1.0

## Description

This indicator measures how stretched U.S. large-cap growth is versus U.S. large-cap value by analyzing the VIGAX/VVIAX ratio. Because VIGAX represents large-cap growth and VVIAX represents large-cap value, a rising ratio means growth is outperforming value, while a falling ratio means value is outperforming growth.

The script calculates the ratio, converts it to log scale, and then fits rolling 10-year and 15-year regression trends. It plots the residual z-score of the ratio relative to those trends. In plain terms, the indicator shows [b]whether growth is unusually strong or weak versus value[/b] after accounting for the long-term upward trend in growth/value leadership.

A z-score near 0 means the ratio is near trend. A positive z-score means growth is above trend versus value. A negative z-score means growth is below trend versus value. The script plots reference bands at [b]±1.5, ±2.0, and ±2.5 standard deviations[/b].

The signal logic is contrarian and re-entry based. A [b]VALUE[/b] signal occurs when the selected z-score has moved above the chosen positive threshold and then crosses back below it. This means growth became statistically stretched and then started to fail. A [b]GROWTH[/b] signal occurs when the selected z-score has moved below the chosen negative threshold and then crosses back above it. This means growth became statistically washed out and then started to recover.

Suggested use:

Use the 15-year z-score for the cleaner, long-cycle signal. Use the 10-year z-score for a more responsive, current-regime read. The [b]±2.5 threshold is the highest-conviction signal[/b] and will fire rarely. The [b]±2.0 and ±1.5 levels are better treated as early-warning zones[/b] rather than automatic trade signals.

The indicator does not read manual TradingView trendlines. It creates its own statistical trend using rolling regression. The strongest setup occurs when the z-score signal aligns with the visual long-term channel on the VIGAX/VVIAX chart. 

The indicator is not designed to work with charts other than the VIGAX/VVIAX chart.

Code by ChatGPT 5.5 Thinking
Prompts by Jeremy L. A. Hill Edwards

## Source Code

````pine
//@version=6
indicator("VIGAX/VVIAX 10Y & 15Y Detrended Z-Scores", overlay=false, max_labels_count=500, max_bars_back=5000)

// =====================================================
// Inputs
// =====================================================
grpSymbols = "Symbols"
growthSymbol = input.symbol("NASDAQ:VIGAX", "Growth symbol", group=grpSymbols)
valueSymbol  = input.symbol("NASDAQ:VVIAX", "Value symbol", group=grpSymbols)

grpCalc = "Calculation"
barsPerYear = input.int(52, "Bars per year: 52 weekly, 12 monthly, 252 daily", minval=12, maxval=252, group=grpCalc)

grpDisplay = "Display"
showLookbacks = input.string("Both", "Show lookbacks", options=["Both", "15Y only", "10Y only"], group=grpDisplay)
show15Band = input.bool(true, "Show ±1.5 bands", group=grpDisplay)
show20Band = input.bool(true, "Show ±2.0 bands", group=grpDisplay)
show25Band = input.bool(true, "Show ±2.5 bands", group=grpDisplay)

grpSignals = "Signals"
signalLookback = input.string("15Y", "Signals use lookback", options=["15Y", "10Y"], group=grpSignals)
signalLevel = input.string("2.5", "Signal z-score level", options=["1.5", "2.0", "2.5", "All"], group=grpSignals)
useReentrySignal = input.bool(true, "Signal only after re-entry from extreme", group=grpSignals)

// =====================================================
// Data
// =====================================================
growthClose = request.security(growthSymbol, timeframe.period, close, gaps=barmerge.gaps_off, calc_bars_count=5000)
valueClose  = request.security(valueSymbol, timeframe.period, close, gaps=barmerge.gaps_off, calc_bars_count=5000)

ratio = growthClose / valueClose
logRatio = math.log(ratio)

// =====================================================
// Rolling log-regression function
// x = 0 current bar; x = lookback - 1 oldest bar
// Residual z-score = current log ratio minus rolling regression value,
// divided by regression residual standard deviation.
// =====================================================
f_regression(_src, _len) =>
    float sx = 0.0
    float sy = 0.0
    float sxx = 0.0
    float sxy = 0.0
    float n = 0.0

    for i = 0 to _len - 1
        float y = _src[i]
        if not na(y)
            float x = i
            sx  += x
            sy  += y
            sxx += x * x
            sxy += x * y
            n   += 1.0

    float denom = n * sxx - sx * sx
    float slope = n > 2 and denom != 0.0 ? (n * sxy - sx * sy) / denom : na
    float intercept = n > 2 and not na(slope) ? (sy - slope * sx) / n : na

    float ss = 0.0
    if n > 2 and not na(intercept)
        for i = 0 to _len - 1
            float y = _src[i]
            if not na(y)
                float fit = intercept + slope * i
                float resid = y - fit
                ss += resid * resid

    float residSd = n > 2 and not na(intercept) ? math.sqrt(ss / math.max(n - 2.0, 1.0)) : na

    [intercept, residSd, n]

f_zscore(_src, _len) =>
    [regLogRaw, residSdRaw, nObs] = f_regression(_src, _len)
    bool enoughData = nObs >= _len * 0.85
    float z = enoughData and not na(residSdRaw) and residSdRaw > 0 ? (_src - regLogRaw) / residSdRaw : na
    [z, regLogRaw, residSdRaw, nObs]

// =====================================================
// 10Y and 15Y z-scores
// =====================================================
lookback10 = 10 * barsPerYear
lookback15 = 15 * barsPerYear

[z10, reg10, sd10, n10] = f_zscore(logRatio, lookback10)
[z15, reg15, sd15, n15] = f_zscore(logRatio, lookback15)

// =====================================================
// Plot controls
// =====================================================
show10 = showLookbacks == "Both" or showLookbacks == "10Y only"
show15 = showLookbacks == "Both" or showLookbacks == "15Y only"

// Zero line
plot(0.0, "Zero / trend line", color=color.new(color.blue, 0), linewidth=1)

// Z-score bands
plot(show15Band ? 1.5 : na, "+1.5", color=color.new(color.red, 70), linewidth=1)
plot(show15Band ? -1.5 : na, "-1.5", color=color.new(color.green, 70), linewidth=1)

plot(show20Band ? 2.0 : na, "+2.0", color=color.new(color.red, 45), linewidth=1)
plot(show20Band ? -2.0 : na, "-2.0", color=color.new(color.green, 45), linewidth=1)

plot(show25Band ? 2.5 : na, "+2.5", color=color.new(color.red, 0), linewidth=2)
plot(show25Band ? -2.5 : na, "-2.5", color=color.new(color.green, 0), linewidth=2)

// Z-score lines
plot(show15 ? z15 : na, "15Y residual z-score", color=color.white, linewidth=2)
plot(show10 ? z10 : na, "10Y residual z-score", color=color.yellow, linewidth=2)

// =====================================================
// Signal logic
// DO NOT INVERT:
// High positive z-score = growth stretched versus value.
// Re-entry downward from high extreme = VALUE signal.
// Low negative z-score = growth washed out versus value.
// Re-entry upward from low extreme = GROWTH signal.
// =====================================================
zSig = signalLookback == "15Y" ? z15 : z10

valueReentry15 = ta.crossunder(zSig, 1.5)
valueReentry20 = ta.crossunder(zSig, 2.0)
valueReentry25 = ta.crossunder(zSig, 2.5)

growthReentry15 = ta.crossover(zSig, -1.5)
growthReentry20 = ta.crossover(zSig, -2.0)
growthReentry25 = ta.crossover(zSig, -2.5)

valueExtreme15 = zSig >= 1.5
valueExtreme20 = zSig >= 2.0
valueExtreme25 = zSig >= 2.5

growthExtreme15 = zSig <= -1.5
growthExtreme20 = zSig <= -2.0
growthExtreme25 = zSig <= -2.5

valueSignal15 = useReentrySignal ? valueReentry15 : valueExtreme15
valueSignal20 = useReentrySignal ? valueReentry20 : valueExtreme20
valueSignal25 = useReentrySignal ? valueReentry25 : valueExtreme25

growthSignal15 = useReentrySignal ? growthReentry15 : growthExtreme15
growthSignal20 = useReentrySignal ? growthReentry20 : growthExtreme20
growthSignal25 = useReentrySignal ? growthReentry25 : growthExtreme25

showSig15 = signalLevel == "1.5" or signalLevel == "All"
showSig20 = signalLevel == "2.0" or signalLevel == "All"
showSig25 = signalLevel == "2.5" or signalLevel == "All"

// VALUE signals
plotshape(showSig15 and valueSignal15 ? zSig : na, title="VALUE 1.5", style=shape.triangledown,
     location=location.absolute, color=color.new(color.red, 55), text="V1.5", textcolor=color.white, size=size.tiny)

plotshape(showSig20 and valueSignal20 ? zSig : na, title="VALUE 2.0", style=shape.triangledown,
     location=location.absolute, color=color.new(color.red, 25), text="V2.0", textcolor=color.white, size=size.tiny)

plotshape(showSig25 and valueSignal25 ? zSig : na, title="VALUE 2.5", style=shape.triangledown,
     location=location.absolute, color=color.red, text="V2.5", textcolor=color.white, size=size.tiny)

// GROWTH signals
plotshape(showSig15 and growthSignal15 ? zSig : na, title="GROWTH 1.5", style=shape.triangleup,
     location=location.absolute, color=color.new(color.green, 55), text="G1.5", textcolor=color.white, size=size.tiny)

plotshape(showSig20 and growthSignal20 ? zSig : na, title="GROWTH 2.0", style=shape.triangleup,
     location=location.absolute, color=color.new(color.green, 25), text="G2.0", textcolor=color.white, size=size.tiny)

plotshape(showSig25 and growthSignal25 ? zSig : na, title="GROWTH 2.5", style=shape.triangleup,
     location=location.absolute, color=color.green, text="G2.5", textcolor=color.white, size=size.tiny)

// Alerts
alertcondition(valueSignal15, "VALUE 1.5", "VIGAX/VVIAX re-entered from a +1.5 z-score growth extreme. Consider tilting toward value.")
alertcondition(valueSignal20, "VALUE 2.0", "VIGAX/VVIAX re-entered from a +2.0 z-score growth extreme. Consider tilting toward value.")
alertcondition(valueSignal25, "VALUE 2.5", "VIGAX/VVIAX re-entered from a +2.5 z-score growth extreme. Consider tilting toward value.")

alertcondition(growthSignal15, "GROWTH 1.5", "VIGAX/VVIAX re-entered from a -1.5 z-score growth washout. Consider tilting toward growth.")
alertcondition(growthSignal20, "GROWTH 2.0", "VIGAX/VVIAX re-entered from a -2.0 z-score growth washout. Consider tilting toward growth.")
alertcondition(growthSignal25, "GROWTH 2.5", "VIGAX/VVIAX re-entered from a -2.5 z-score growth washout. Consider tilting toward growth.")
````
