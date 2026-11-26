# Propulsive Asymmetric Turbulence Ribbon

- url: https://www.tradingview.com/script/zkWiIWCC-Propulsive-Asymmetric-Turbulence-Ribbon/
- type: indicator
- pine_id: PUB;a4074bc32f3640368fa46f16f030985a
- version: 1.0

## Description

Average True Range shows how large the bars have been. It says nothing of where the market sits in its breathing, whether a quiet stretch is storing energy or simply dying, or whether a sudden expansion has fuel behind it. A volatility reading without timing is a thermometer without a calendar.

The Propulsive Asymmetric Turbulence Ribbon (ATRPro) adds the calendar. It places realized range, a ribbon of smoothed ATR, and a normalized cycle field on one scale in a single pane, then classifies the field into five phases and tracks how much compression it has stored. It measures the condition and timing of volatility only; it reads neither price direction nor volume. The sections below explain the pane, the phase engine, and a two-clock reading of Definium Therapeutics, the chart above.

[b]One Scale for Range and Rhythm
[/b]
The dotted zero line is the ATR baseline. The histogram plots a 13-bar ATR minus its own 55-bar average, so columns above zero mean ranges are wider than usual and columns beneath it mean they are narrower. Column hue follows the eight-bar rate of change in ATR, running from red for rapid acceleration through yellow near flat to blue for pronounced deceleration. Column opacity follows candle efficiency, measured as body divided by full range, so dense columns describe decisive bars and faint ones describe bars made mostly of wick.

A yellow and orange ribbon plots the ATR's 13-bar EMA and Hull average, each centered on the same baseline. The faster Hull line turns first, so a Hull average above the EMA describes volatility that is accelerating, while an EMA above the Hull average describes volatility that is settling. The ribbon behaves like a tachometer needle laid over the odometer of the histogram.

Raw ATR, in the symbol's own price units, appears in the table and the Data Window but never in the pane. That choice keeps one violent bar from stretching the shared scale and flattening everything else into illegibility. Every element in the pane is therefore a deviation, and every deviation can be compared with its neighbors.

[b]A Cycle Field With a Memory
[/b]
The cycle field begins with price, not range. A high-pass filter removes the slow trend, a low-pass filter removes bar-to-bar noise, and the surviving oscillation is normalized against a slowly decaying envelope of its own recent peaks. A tension transform then shapes the result into a quotient whose amplitude the pane draws as a core line and its mirror, enclosing a shaded field that swells and narrows with the market's rhythm.

The phase engine reads that amplitude in five states. Coiled means the field is narrow. Igniting means it has begun to widen, Released means expansion is confirmed, Exhausted means ATR has started decelerating while the field remains wide, and Resetting means the field is contracting back toward the coil. Each transition has a stated rule, so the phase is a reading rather than an opinion.

Charge is the engine's memory. It accumulates while the field is coiled and ATR sits at or below its baseline, and it fades once either condition fails, so it measures how long compression has been stored. The field grows more opaque as charge builds, which makes a well-loaded coil visible at a glance. Charge also governs the second path into ignition: a sharp rise in ATR can ignite the engine only when enough charge has accumulated, so a range spike from an empty coil does not count as a launch.

Three markers sit on the zero line. A diamond marks entry into Igniting. A triangle pointing up marks a Release Lead, when the cycle field expands before realized range accelerates, and a triangle pointing down marks a Range Shock, when ATR accelerates into a field that is still compressed. None of the markers indicates price direction; each describes which half of the instrument moved first.

[b]Reading the Chart
[/b]
The chart above shows DFTX on the hourly clock from early August through the close of 9 October. The pane records three distinct volatility events: the expansion around the 49.66 high of 7 August, the spike of 14 September, and the slide to the 32.86 low of 8 October with its sharp rebound on 9 October. Between those events the histogram sinks beneath its baseline and the field narrows, which is what compression looks like on this instrument.

The table places the chart's clock beside the daily clock, and each column computes its own ATR, baseline, ribbon, cycle, charge and phase on bars of that timeframe. The daily column reads the last completed day by default, so it never repaints. On the hourly side the phase reads Released, charge 0.9 percent, ATR 0.08 above its baseline and accelerating 15.04 percent, with the Hull line above the EMA. On the daily side the phase reads Coiled, charge 19.6 percent, ATR 0.52 beneath its baseline and decelerating 10.33 percent, with the EMA above the Hull line.

The Context row condenses that disagreement into one phrase: chart above, daily below, phases differ. The hourly clock has spent its stored charge in a release, while the daily clock remains coiled and still accumulating. A daily charge of 19.6 percent sits just short of the default 21 percent that the range-led ignition path requires, which means the daily engine is close to the point at which an ATR surge would count as ignition rather than noise.

[b]Where It Fits in a Trading Process
[/b]
ATRPro is a supplementary instrument. It tells whether volatility is storing, waking, spending or resting, and it leaves direction, location and entries to price structure and the trader's own method. A breakout that arrives during Igniting or Released has volatility behind it; the same breakout in a deep coil with no charge deserves more suspicion.

The instrument is built for intraday and daily charts. Above the daily clock its bar-count windows and phases no longer serve the intended read, so the table withholds the daily comparison and asks for a lower timeframe. A Timeframe Override can draw the pane's ATR from another clock, though its windows still count chart bars, so the pane then shows a mixed-clock reading; the table's columns remain independent of the override. Five alerts cover Ignition, Release, Release Lead, Range Shock and a return to Coiled.

Every value behind the pane, from raw ATR and its baseline to the cycle quotient, amplitude, charge and phase code, appears in the Data Window. Nothing in this description or in the script is financial advice, and past behavior of volatility does not predict future prices.

[b]Charge Is Stored Slowly and Spent Quickly
[/b]
The DFTX table shows something a single-clock volatility tool cannot. An hourly release and a daily coil were true at the same moment, and neither one was wrong. The hourly clock had drained its reservoir to under one percent, while the daily clock was still filling its own.

That asymmetry is the one the instrument's name promises. Compression accumulates over many bars and discharges over a few, so the clock that looks calm often holds the larger store of energy. A trader who reads volatility on one clock sees whether the market is moving; a trader who reads it on two sees which reservoir is being drawn, and which one has not yet been touched.

## Source Code

````pine
//@version=6
// Open Source | Designed by Adrian Dyer for "The Leading Indicator"
// ATRPro is the suite's pure volatility indicator: realized range and cycle phase on one scale.
indicator("Propulsive Asymmetric Turbulence Ribbon", shorttitle="ATRPro", overlay=false)

const float PI = 3.14159265359
const float TWOPI = 6.28318530718

// ATR engine
grpATR = "ATR Engine"
atrLen = input.int(13, "ATR Length", minval=1, group=grpATR)
atrAvgLen = input.int(55, "ATR Baseline Length", minval=1, group=grpATR)
rocLen = input.int(8, "ATR ROC Lookback", minval=1, group=grpATR)
htf = input.timeframe("", "Timeframe Override", group=grpATR, tooltip="Changes the plotted pane's ATR series only. The table's Chart and 1D columns always use their own timeframes.")

// Cycle and phase engine
grpCore = "Cycle"
src = input.source(hlc3, "Core Source", group=grpCore)
hpPeriod = input.int(89, "Highpass Period", minval=21, maxval=233, group=grpCore)
lpPeriod = input.int(13, "Lowpass Period", minval=3, maxval=34, group=grpCore)
envDecay = input.float(0.991, "Envelope Decay", minval=0.950, maxval=0.999, step=0.001, group=grpCore)
tensionK = input.float(0.30, "Tension Shape", minval=0.0, maxval=0.9, step=0.05, group=grpCore)

grpPhase = "Phase"
coilThresh = input.float(0.21, "Coil Threshold", minval=0.05, maxval=0.50, step=0.01, group=grpPhase)
releaseThr = input.float(0.55, "Release Threshold", minval=0.30, maxval=0.95, step=0.01, group=grpPhase)
phaseSmooth = input.int(5, "Amplitude Smoothing", minval=1, maxval=21, group=grpPhase)
ignSlopeLen = input.int(3, "Ignition Slope Lookback", minval=1, maxval=13, group=grpPhase)
rocThresh = input.float(0.10, "ATR ROC Threshold", minval=0.02, maxval=0.30, step=0.01, group=grpPhase)

grpCharge = "Charge"
chargeBars = input.int(89, "Charge Memory", minval=8, maxval=377, group=grpCharge)
resetFade = input.float(0.95, "Reset Fade", minval=0.50, maxval=0.999, step=0.005, group=grpCharge)
minCharge = input.float(21.0, "Minimum Charge for ATR Ignition (%)", minval=0.0, maxval=100.0, step=1.0, group=grpCharge)

grpVis = "Display"
showHist = input.bool(true, "ATR Histogram", group=grpVis)
showRibbon = input.bool(true, "Centered ATR Ribbon", group=grpVis)
showCrossMarkers = input.bool(false, "Ribbon Crossovers", group=grpVis)
showCore = input.bool(true, "Cycle Core", group=grpVis)
tintCore = input.bool(true, "Tint Core by Phase", group=grpVis)
showMirror = input.bool(true, "Cycle Mirror", group=grpVis)
showField = input.bool(true, "Cycle Field", group=grpVis)
showGlow = input.bool(true, "Ignition Glow", group=grpVis)
showMarkers = input.bool(true, "Lead / Shock Markers", group=grpVis)
showIgnDots = input.bool(true, "Ignition Diamonds", group=grpVis)
scaleMult = input.float(1.0, "Cycle Scale Multiplier", minval=0.1, maxval=3.0, step=0.1, group=grpVis)

grpOpacity = "Field Opacity"
transpAtZero = input.int(88, "Transparency at 0% Charge", minval=0, maxval=100, group=grpOpacity)
transpAtFull = input.int(55, "Transparency at 100% Charge", minval=0, maxval=100, group=grpOpacity)
glowTransp = input.int(82, "Ignition Glow Transparency", minval=0, maxval=100, group=grpOpacity)

grpTable = "Data Table"
showTable = input.bool(true, "Show Table", group=grpTable)
dailyRead = input.string("Closed 1D", "Daily Read", options=["Closed 1D", "Live 1D"], group=grpTable, tooltip="Closed 1D uses the previous completed daily bar. Live 1D includes the developing daily bar and can change before its close.")
tableSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=grpTable)
tableBg = input.color(color.new(#2A2E39, 18), "Background", group=grpTable)
tableText = input.color(#E6E6E6, "Text", group=grpTable)
tableAccent = input.color(#FAF3B2, "Accent", group=grpTable)

grpColor = "Palette"
colFieldPos = input.color(#4F7CAC, "Field: Positive Quotient", group=grpColor)
colFieldNeg = input.color(#7E57C2, "Field: Negative Quotient", group=grpColor)
colCoiled = input.color(#9575CD, "Phase: Coiled", group=grpColor)
colIgnite = input.color(#FFB74D, "Phase: Igniting", group=grpColor)
colRelease = input.color(#4FC3F7, "Phase: Released", group=grpColor)
colExhaust = input.color(#E57373, "Phase: Exhausted", group=grpColor)
colReset = input.color(#90A4AE, "Phase: Resetting", group=grpColor)
colCore = input.color(color.new(#74B8F0, 15), "Core Line", group=grpColor)
colMirror = input.color(color.new(#E480D0, 30), "Mirror Line", group=grpColor)
colZero = input.color(color.new(#F5E6C8, 55), "Zero Line", group=grpColor)
colRibbonEMA = input.color(color.yellow, "Ribbon EMA", group=grpColor)
colRibbonHMA = input.color(color.orange, "Ribbon HMA", group=grpColor)
colRawATR = input.color(#8BEAF6, "Raw ATR Table Value", group=grpColor)

f_tableSize(string s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small
f_num(float x) => na(x) ? "--" : str.tostring(x, format.mintick)
f_pct(float x) => na(x) ? "--" : str.tostring(x * 100.0, "#.##") + "%"
f_phaseCode(string state) => state == "COILED" ? 0 : state == "IGNITING" ? 1 : state == "RELEASED" ? 2 : state == "EXHAUSTED" ? 3 : 4
f_phaseName(int code) => code == 0 ? "COILED" : code == 1 ? "IGNITING" : code == 2 ? "RELEASED" : code == 3 ? "EXHAUSTED" : "RESETTING"
f_phaseColor(int code) => code == 0 ? colCoiled : code == 1 ? colIgnite : code == 2 ? colRelease : code == 3 ? colExhaust : colReset

// Pane ATR windows count chart bars; the table samples each clock independently.
tfEff = htf == "" ? timeframe.period : htf
atr = request.security(syminfo.tickerid, tfEff, ta.atr(atrLen), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
chartAtr = ta.atr(atrLen)
chartBase = ta.sma(chartAtr, atrAvgLen)
chartHist = chartAtr - chartBase
chartRoc = chartAtr[rocLen] != 0 ? (chartAtr - chartAtr[rocLen]) / chartAtr[rocLen] : 0.0
chartRibbonUp = ta.ema(chartAtr, atrLen) > ta.hma(chartAtr, atrLen)
atrBase = ta.sma(atr, atrAvgLen)
atrHist = atr - atrBase
atrRoc = atr[rocLen] != 0 ? (atr - atr[rocLen]) / atr[rocLen] : 0.0
atrEMA = ta.ema(atr, atrLen)
atrHMA = ta.hma(atr, atrLen)
ribbonEMA = atrEMA - atrBase
ribbonHMA = atrHMA - atrBase
ribbonUp = atrEMA > atrHMA
crossUp = ta.crossover(atrEMA, atrHMA)
crossDown = ta.crossunder(atrEMA, atrHMA)

histHigh = ta.highest(atrHist, atrAvgLen)
histLow = ta.lowest(atrHist, atrAvgLen)
histRange = histHigh - histLow
atrScale = histRange > 0 ? histRange * scaleMult * 0.5 : atr * 0.25

// Histogram hue shows ATR acceleration; opacity shows candle body efficiency.
effort = high - low
bodyRatio = effort > 0 ? math.abs(close - open) / effort : 0.0
histOpacity = int(math.max(10.0, math.min(100.0, 100.0 - bodyRatio * 100.0)))
histBaseColor = atrRoc > 0.20 ? color.red : atrRoc > 0.10 ? color.orange : atrRoc > 0.00 ? color.yellow : atrRoc > -0.10 ? color.green : atrRoc > -0.20 ? color.aqua : color.blue
histColor = color.new(histBaseColor, histOpacity)

getCycleLength(_src) =>
    v1 = _src - _src[7]
    s2 = ta.ema(math.pow(v1 + nz(v1[1]), 2), 5)
    s3 = ta.ema(math.pow(v1 - nz(v1[1]), 2), 5)
    v2 = s2 != 0 ? math.sqrt(s3 / s2) : 0.0
    delta = s3 != 0 ? 2 * math.atan(v2) : 0.0
    var float accum = 0.0
    var float inst = 0.0
    var float smoothedLen = 0.0
    accum += delta
    isComplete = accum > TWOPI
    inst := isComplete ? 0.0 : inst + 1.0
    accum := isComplete ? accum - TWOPI : accum
    smoothedLen := 0.25 * inst + 0.75 * nz(smoothedLen[1])
    smoothedLen

getFilteredCycle(_src, _hpPer, _lpPer) =>
    alpha1 = (math.cos(0.707 * TWOPI / _hpPer) + math.sin(0.707 * TWOPI / _hpPer) - 1) / math.cos(0.707 * TWOPI / _hpPer)
    var float HP = 0.0
    HP := (1 - alpha1 / 2) * (1 - alpha1 / 2) * (_src - 2 * nz(_src[1]) + nz(_src[2])) + 2 * (1 - alpha1) * nz(HP[1]) - (1 - alpha1) * (1 - alpha1) * nz(HP[2])
    a1 = math.exp(-1.414 * PI / _lpPer)
    b1 = 2 * a1 * math.cos(1.414 * PI / _lpPer)
    c2 = b1
    c3 = -a1 * a1
    c1 = 1 - c2 - c3
    var float Filt = 0.0
    Filt := c1 * (HP + nz(HP[1])) / 2 + c2 * nz(Filt[1]) + c3 * nz(Filt[2])
    Filt

f_phase(float amp, float hist, float roc) =>
    var float pressure = 0.0
    var string state = "COILED"
    slope = amp - amp[ignSlopeLen]
    coil = amp < coilThresh
    pressure := coil and hist <= 0 ? math.min(pressure + 100.0 / chargeBars, 100.0) : pressure * resetFade
    cycleIgnition = ta.crossover(amp, coilThresh) and slope > 0
    rangeIgnition = ta.crossover(roc, rocThresh) and pressure >= minCharge
    if state == "COILED"
        if cycleIgnition or rangeIgnition
            state := "IGNITING"
    else if state == "IGNITING"
        if amp > releaseThr
            state := "RELEASED"
        else if amp < coilThresh and slope <= 0 and roc < rocThresh
            state := "COILED"
    else if state == "RELEASED"
        if roc < -rocThresh and amp > coilThresh
            state := "EXHAUSTED"
        else if amp < releaseThr and slope < 0
            state := "RESETTING"
    else if state == "EXHAUSTED"
        if amp < releaseThr
            state := "RESETTING"
        else if roc > rocThresh and slope > 0
            state := "RELEASED"
    else if state == "RESETTING"
        if amp < coilThresh
            state := "COILED"
        else if roc > rocThresh and slope > 0
            state := "IGNITING"
    [state, pressure]

f_dailySnapshot() =>
    dAtr = ta.atr(atrLen)
    dBase = ta.sma(dAtr, atrAvgLen)
    dHist = dAtr - dBase
    dRoc = dAtr[rocLen] != 0 ? (dAtr - dAtr[rocLen]) / dAtr[rocLen] : 0.0
    dEMA = ta.ema(dAtr, atrLen)
    dHMA = ta.hma(dAtr, atrLen)
    dFiltered = getFilteredCycle(src, hpPeriod, lpPeriod)
    var float dPeakEnv = 0.0
    dPeakEnv := envDecay * nz(dPeakEnv[1])
    if math.abs(dFiltered) > dPeakEnv
        dPeakEnv := math.abs(dFiltered)
    dX = dPeakEnv != 0 ? dFiltered / dPeakEnv : 0.0
    dQ = (dX + tensionK) / (tensionK * dX + 1)
    dAmp = ta.sma(math.abs(dQ), phaseSmooth)
    [dState, dCharge] = f_phase(dAmp, dHist, dRoc)
    dReady = not na(dBase) and not na(dHMA) and not na(dAmp)
    [dAtr, dHist, dRoc, dCharge, f_phaseCode(dState), dEMA > dHMA ? 1 : 0, dReady]

f_dailySnapshotClosed() =>
    [a, h, r, c, p, b, ready] = f_dailySnapshot()
    [a[1], h[1], r[1], c[1], p[1], b[1], ready[1]]

rawCycleLen = getCycleLength(src)
filtered = getFilteredCycle(src, hpPeriod, lpPeriod)
var float peakEnv = 0.0
peakEnv := envDecay * nz(peakEnv[1])
if math.abs(filtered) > peakEnv
    peakEnv := math.abs(filtered)

X = peakEnv != 0 ? filtered / peakEnv : 0.0
q = (X + tensionK) / (tensionK * X + 1)
fieldAmp = ta.sma(math.abs(q), phaseSmooth)
[phase, charge] = f_phase(fieldAmp, atrHist, atrRoc)
[chartPhase, chartCharge] = f_phase(fieldAmp, chartHist, chartRoc)
chartPhaseCode = f_phaseCode(chartPhase)
chartReady = not na(chartBase) and not na(fieldAmp)

isCoiled = phase == "COILED"
isIgnite = phase == "IGNITING"
isRelease = phase == "RELEASED"
isExhaust = phase == "EXHAUSTED"
phaseColor = isCoiled ? colCoiled : isIgnite ? colIgnite : isRelease ? colRelease : isExhaust ? colExhaust : colReset
phaseCode = f_phaseCode(phase)

// The 1D request evaluates ATR, its windows, the cycle, charge, and phase on daily bars.
// The fallback avoids requesting a lower timeframe when the chart exceeds 1D.
dailyTf = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds("1D") ? "1D" : timeframe.period
[dAtrLive, dHistLive, dRocLive, dChargeLive, dCodeLive, dRibbonLive, dReadyLive] = request.security(syminfo.tickerid, dailyTf, f_dailySnapshot(), lookahead=barmerge.lookahead_off)
[dAtrClosed, dHistClosed, dRocClosed, dChargeClosed, dCodeClosed, dRibbonClosed, dReadyClosed] = request.security(syminfo.tickerid, dailyTf, f_dailySnapshotClosed(), lookahead=barmerge.lookahead_on)
useLiveDaily = dailyRead == "Live 1D"
dAtr = useLiveDaily ? dAtrLive : dAtrClosed
dHist = useLiveDaily ? dHistLive : dHistClosed
dRoc = useLiveDaily ? dRocLive : dRocClosed
dCharge = useLiveDaily ? dChargeLive : dChargeClosed
dCode = useLiveDaily ? dCodeLive : dCodeClosed
dRibbon = useLiveDaily ? dRibbonLive : dRibbonClosed
dReady = useLiveDaily ? dReadyLive : dReadyClosed

releaseLead = ta.crossover(fieldAmp, releaseThr) and atrRoc < rocThresh
rangeShock = ta.crossover(atrRoc, rocThresh) and fieldAmp < coilThresh
ignFlag = isIgnite and phase[1] != "IGNITING"

dynTransp = transpAtZero - (transpAtZero - transpAtFull) * (charge / 100.0)
dynTransp := math.max(0.0, math.min(100.0, dynTransp))
scaledCore = q * atrScale
scaledMirror = -q * atrScale
qPositive = q >= 0

// One axis: ATR deviations, centered ribbon averages, and the scaled cycle field.
plot(showHist ? atrHist : na, "ATR Histogram", style=plot.style_columns, color=histColor)
pEMA = plot(showRibbon ? ribbonEMA : na, "ATR EMA - Baseline", color=colRibbonEMA, linewidth=1)
pHMA = plot(showRibbon ? ribbonHMA : na, "ATR HMA - Baseline", color=colRibbonHMA, linewidth=1)
fill(pEMA, pHMA, color=showRibbon ? ribbonUp ? color.new(colRibbonEMA, 40) : color.new(colRibbonHMA, 40) : na, title="Centered ATR Ribbon")
plotshape(showCrossMarkers and (crossUp or crossDown) ? ribbonEMA : na, "Ribbon Crossover", style=shape.triangleup, location=location.absolute, color=ribbonUp ? colRibbonEMA : colRibbonHMA, size=size.tiny)

glowAmp = atrScale * 0.13
gTop = plot(showGlow and isIgnite ? glowAmp : na, "Ignition Glow Top", color=color.new(colIgnite, 100), editable=false)
gBot = plot(showGlow and isIgnite ? -glowAmp : na, "Ignition Glow Bottom", color=color.new(colIgnite, 100), editable=false)
fill(gTop, gBot, color=color.new(colIgnite, glowTransp), title="Ignition Glow")

pPosA = plot(showField and qPositive ? scaledCore : na, "Field +A", color=na, editable=false, display=display.pane)
pPosB = plot(showField and qPositive ? scaledMirror : na, "Field +B", color=na, editable=false, display=display.pane)
fill(pPosA, pPosB, color=color.new(colFieldPos, int(dynTransp)), title="Positive Quotient Field")
pNegA = plot(showField and not qPositive ? scaledCore : na, "Field -A", color=na, editable=false, display=display.pane)
pNegB = plot(showField and not qPositive ? scaledMirror : na, "Field -B", color=na, editable=false, display=display.pane)
fill(pNegA, pNegB, color=color.new(colFieldNeg, int(dynTransp)), title="Negative Quotient Field")

plot(showCore ? scaledCore : na, "Cycle Core", color=tintCore ? phaseColor : colCore, linewidth=1)
plot(showMirror ? scaledMirror : na, "Cycle Mirror", color=colMirror, linewidth=1)
hline(0, "Zero Line", color=colZero, linestyle=hline.style_dotted)
plotshape(showMarkers and releaseLead ? 0 : na, "Release Lead", style=shape.triangleup, location=location.absolute, color=colRelease, size=size.tiny)
plotshape(showMarkers and rangeShock ? 0 : na, "Range Shock", style=shape.triangledown, location=location.absolute, color=colIgnite, size=size.tiny)
plotshape(showIgnDots and ignFlag ? 0 : na, "Ignition", style=shape.diamond, location=location.absolute, color=color.new(colIgnite, 25), size=size.tiny)

alertcondition(ignFlag, "ATRPro: Ignition", "ATRPro entered IGNITING: the volatility field is waking.")
alertcondition(isRelease and phase[1] != "RELEASED", "ATRPro: Release", "ATRPro entered RELEASED: expansion confirmed in the cycle field.")
alertcondition(releaseLead, "ATRPro: Release Lead", "Cycle expansion is leading realized range.")
alertcondition(rangeShock, "ATRPro: Range Shock", "Realized range is accelerating into a compressed cycle.")
alertcondition(isCoiled and phase[1] != "COILED", "ATRPro: Recoiled", "ATRPro returned to COILED.")

// Historical values remain available without changing the pane scale.
plot(atr, "Pane Raw ATR", display=display.data_window)
plot(atrBase, "Pane ATR Baseline", display=display.data_window)
plot(atrRoc, "Pane ATR ROC", display=display.data_window)
plot(q, "Cycle Quotient", display=display.data_window)
plot(fieldAmp, "Cycle Field Amplitude", display=display.data_window)
plot(charge, "Cycle Charge %", display=display.data_window)
plot(phaseCode, "Cycle Phase Code (0 Coil / 1 Ignite / 2 Release / 3 Exhaust / 4 Reset)", display=display.data_window)
plot(atrScale, "Cycle ATR Scale Factor", display=display.data_window)
plot(rawCycleLen, "Raw Cycle Length", display=display.data_window)
plot(peakEnv, "Cycle Peak Envelope", display=display.data_window)

chartAboveDaily = timeframe.in_seconds(timeframe.period) > timeframe.in_seconds("1D")
chartIsDaily = timeframe.in_seconds(timeframe.period) == timeframe.in_seconds("1D")
var table dash = table.new(position.top_right, 3, 8, bgcolor=tableBg, frame_color=color.new(tableAccent, 70), frame_width=1)
if barstate.isfirst
    table.merge_cells(dash, 1, 7, 2, 7)
if barstate.islast
    if showTable
        ts = f_tableSize(tableSizeInput)
        dailyOk = not chartAboveDaily and dReady
        string context = "Waiting for history"
        if chartAboveDaily
            context := "Use 1D or lower"
        else if chartIsDaily
            context := useLiveDaily ? "1D chart" : "1D chart vs prior close"
        else if chartReady and dailyOk
            rangeRead = chartHist > 0 and dHist > 0 ? "Both above baseline" : chartHist < 0 and dHist < 0 ? "Both below baseline" : chartHist > 0 and dHist < 0 ? "Chart above / 1D below" : chartHist < 0 and dHist > 0 ? "Chart below / 1D above" : "At baseline on one clock"
            context := rangeRead + (chartPhaseCode == dCode ? "; same phase" : "; phases differ")
        table.cell(dash, 0, 0, "ATRPro", text_color=tableAccent, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, 0, "Chart " + timeframe.period, text_color=tableAccent, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 2, 0, useLiveDaily ? "1D live" : "1D closed", text_color=tableAccent, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 0, 1, "Phase", text_color=tableText, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, 1, chartReady ? chartPhase : "--", text_color=chartReady ? f_phaseColor(chartPhaseCode) : tableText, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 2, 1, dailyOk ? f_phaseName(dCode) : "--", text_color=dailyOk ? f_phaseColor(dCode) : tableText, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 0, 2, "Charge", text_color=tableText, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, 2, chartReady ? str.tostring(chartCharge, "#.0") + "%" : "--", text_color=chartReady ? f_phaseColor(chartPhaseCode) : tableText, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 2, 2, dailyOk ? str.tostring(dCharge, "#.0") + "%" : "--", text_color=dailyOk ? f_phaseColor(dCode) : tableText, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 0, 3, "Raw ATR", text_color=tableText, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, 3, chartReady ? f_num(chartAtr) : "--", text_color=colRawATR, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 2, 3, dailyOk ? f_num(dAtr) : "--", text_color=colRawATR, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 0, 4, "vs Baseline", text_color=tableText, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, 4, chartReady ? f_num(chartHist) : "--", text_color=chartHist >= 0 ? colIgnite : colFieldNeg, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 2, 4, dailyOk ? f_num(dHist) : "--", text_color=dHist >= 0 ? colIgnite : colFieldNeg, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 0, 5, "ATR ROC", text_color=tableText, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, 5, chartReady ? f_pct(chartRoc) : "--", text_color=chartRoc >= 0 ? colIgnite : colFieldNeg, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 2, 5, dailyOk ? f_pct(dRoc) : "--", text_color=dRoc >= 0 ? colIgnite : colFieldNeg, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 0, 6, "Ribbon", text_color=tableText, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, 6, chartReady ? chartRibbonUp ? "EMA > HMA" : "HMA >= EMA" : "--", text_color=chartRibbonUp ? colRibbonEMA : colRibbonHMA, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 2, 6, dailyOk ? dRibbon == 1 ? "EMA > HMA" : "HMA >= EMA" : "--", text_color=dRibbon == 1 ? colRibbonEMA : colRibbonHMA, text_size=ts, text_halign=text.align_right)
        table.cell(dash, 0, 7, "Context", text_color=tableAccent, text_size=ts, text_halign=text.align_left)
        table.cell(dash, 1, 7, context, text_color=tableAccent, text_size=ts, text_halign=text.align_right)
    else
        table.clear(dash, 0, 0, 2, 7)
````
