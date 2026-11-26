# Agreement Streak Analyzer [FibonacciFlux]

- url: https://www.tradingview.com/script/eowbBWy9-Agreement-Streak-Analyzer-FibonacciFlux/
- type: indicator
- pine_id: PUB;5805a7c552b54b41a2305ea89863491a
- version: 1.0

## Description

An experiment about multi-timeframe agreement, published with the result it actually produced - which is a negative one.

https://www.tradingview.com/x/Af8e72F0/

The frame above is 6-10 August on BTCUSDT 15m, chosen because it contains one of the longest runs in the sample: eight consecutive bars of four-timeframe agreement, which is two hours. The longest anywhere in the 62 days measured is nine. Both labels land on it, and the shaded band between the two thresholds is visible there precisely because the two percentiles briefly differ - most of the time they do not.

WHAT IT DOES

Inside each of four timeframes (15m, 1H, 4H, 1D by default) it computes a Stochastic %K and its %D, and takes the sign of %K minus %D as that timeframe's direction. When all four point the same way, the chart bar counts as an agreement bar. The indicator plots the length of the current run of agreement bars, stores every completed run in a rolling array (200 by default), and scores the live run against that array by empirical percentile. Labels mark a run longer than the 90th percentile of its own history (RARE), a run longer than the 95th while the fast timeframe sits in an extreme zone (EXH), and a run longer than every stored run (REC). An audit table shows each timeframe's raw %K, %D and direction, the current run in bars and in elapsed time, its percentile, the sample count, and both thresholds.

THE MEASUREMENT, AND WHY IT IS A NEGATIVE RESULT

The premise worth testing is whether agreement runs are a property of the market or a property of the construction. The test is a circular shift: shift each timeframe's direction series against the others, which preserves each series' own distribution and its autocorrelation and destroys only the alignment between them.

De-aligned copies of these four sensors agree MORE than the real ones.

- Real all-four agreement: 5.72% of bars on BTCUSDT, 6.67% on ETHUSDT
- Circular-shift null, median of 200 draws: 12.4% and 12.5%
- Analytic independence baseline: 12.43% and 12.47%
- Empirical p in both cases: 0.0050, the resolution floor of 200 draws

The null lands on the independence baseline, so four coin flips would agree about twice as often as these four timeframes do. Read at the same bar without the confirmed-mode lag, agreement rises to 13.2% and 13.6% - indistinguishable from chance. The rarity being scored is mostly manufactured by staggering the four sensors in time, not detected in the market.

Runs are short and the distribution is coarse. Median completed run 2 bars (30 min), mean 2.58, longest observed 9 bars (2h15m) on BTCUSDT and 8 on ETHUSDT, over 133 completed runs in 62 days. The streak line reads 0 on 94.3% of bars. Because the run lengths are small integers, the 90th and 95th percentiles are equal on 82.8% of scored bars on BTCUSDT - the shaded "rare zone" between them has zero height most of the time, and is drawn only where it has width.

No edge is claimed and none was found. The 4-hour forward return after a continuation event was significantly positive on BTCUSDT and significantly negative on ETHUSDT over the same window. That is what a non-effect looks like when it is measured twice.

All figures: Binance spot, 15m chart, 6000 bars ending 2026-08-18, default inputs, both symbols measured identically.

HOW THE NUMBERS WERE CHECKED

The logic was reimplemented outside Pine and cross-checked against this chart's Data Window bar by bar. On seven deliberately chosen bars - runs of 0, 3, 4, 5, 6, 7 and 8 bars, including one bar carrying a RARE label and one carrying an EXH label - the reimplementation matched the chart exactly, thresholds included.

One caveat that a reader can hit: the two percentile thresholds depend on how many completed runs the chart has loaded, not only on the symbol. A chart whose stored array has saturated at 200 samples can put a threshold at 5.0 where a shorter history puts it at 4.5, and because the test is "run longer than the threshold", a run of exactly 5 bars is a label in one case and not in the other. Label counts are not portable between charts with different history depth.

SETTINGS THAT DO AND DO NOT MATTER

Measured, not assumed. The timeframe set is by far the strongest control: dropping the daily leg moves agreement from 5.7% to 18.8% of bars, and using only 15m and 1H gives 46.0%. The sensor lengths and the percentiles are load-bearing. The four agreement weights are not - the test is unanimity, so they change no threshold and no label, and they scale only the optional agreement mass line. The colour mid percentile only tints the line.

WHAT IS FIXED IN THIS VERSION

Nine defects found by adversarial review of the previous private version, each verified against the code before it was fixed. %D smoothing could be set to 1, which made every direction exactly zero and the whole indicator permanently blank; a minimum-samples value above the array cap did the same. The rarity alert compared the percentile rank to the percentile input while the label compared the run to the interpolated quantile, so it fired one bar early on three of five labels and four more times with no label at all - alerts now fire on exactly the booleans that draw the labels. The pane colour used that same second rule and painted exhaustion red on runs one bar shorter than any run that could carry a verdict. An "extreme membership softness" input was algebraically a no-op across its whole range and has been removed in favour of the comparison it actually performed. The exhaustion percentile can no longer sit below the continuation percentile and invert the zone. The streak line is blanked during sensor warm-up instead of drawing a confident flat zero. Draw order was changed so the thresholds and the band no longer cover the line they describe. The audit table promised by the previous version's settings did not exist; it does now.

Every one of these fixes is either display-only or a guard on a setting the defaults do not use, so none of them moves a plotted number at default settings. That was not left as an argument: the same bar was read off the chart before and after the rewrite, and the run length, both thresholds and all three event series came back identical.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
indicator("Agreement Streak Analyzer [FibonacciFlux]", "AGR Streak", overlay = false, precision = 1)

// An experiment, and a negative one. It counts consecutive chart bars on which four
// timeframes all point the same way (sign of Stochastic %K minus %D inside each), then
// scores the current run against this symbol's own history of completed runs.
//
// The measurement that matters is the null test, and it went against the idea. Under a
// circular shift that preserves each timeframe's own distribution and autocorrelation and
// breaks only the alignment between them, DE-ALIGNED copies of these four sensors agree
// MORE than the real ones: 12.4% of bars against a real 5.72% on BTCUSDT 15m, 12.5%
// against 6.67% on ETHUSDT, over 6000 bars and 200 draws each. The shifted null sits on
// the analytic independence baseline, so four coin flips would agree twice as often as
// these four timeframes do. Read at the same bar without the confirmed-mode lag, agreement
// is 13.2% / 13.6% - chance. The rarity this indicator scores is mostly manufactured by
// staggering the four sensors, not found in the market.
//
// So this is published as what it is: the whole method, the null it was tested against,
// and the result. Rare agreement runs are a property of the construction. Nothing here
// forecasts anything, and the 4-hour forward return after a signal came out significantly
// POSITIVE on BTCUSDT and significantly NEGATIVE on ETHUSDT over the same window, which is
// how a non-effect looks when you measure it twice.
//
// Intended chart: 15m, with 15m/1H/4H/1D as the watched timeframes.

// -----------------------------------------------------------------------------
// 01. Direction sensor (Stochastic %K vs %D sign inside each timeframe)
// -----------------------------------------------------------------------------
string G_DIR = "01. Direction sensor"
int stochLength = input.int(14, "Stochastic length", minval = 2, group = G_DIR)
int smoothK = input.int(3, "%K smoothing", minval = 1, group = G_DIR)
int smoothD = input.int(3, "%D smoothing", minval = 2, group = G_DIR,
     tooltip = "Minimum 2. At 1 the %D line equals %K, every direction reads exactly zero, and the indicator can never produce a single agreement bar.")
string dataMode = input.string("Confirmed only", "HTF data mode", options = ["Confirmed only", "Developing HTF"], group = G_DIR,
     tooltip = "Confirmed only uses the previous completed bar in each requested timeframe. Developing HTF reacts earlier but values can change until the open higher-timeframe bar closes. This choice is not cosmetic: measured on 6000 bars of BTCUSDT 15m, all-four agreement is 5.72% of bars under Confirmed only and 13.24% read at the same bar without the lag.")

// -----------------------------------------------------------------------------
// 02. Timeframes
// -----------------------------------------------------------------------------
string G_TF = "02. Timeframes"
string tf15 = input.timeframe("15", "Short-term timeframe", group = G_TF)
string tf1h = input.timeframe("60", "Intraday timeframe", group = G_TF)
string tf4h = input.timeframe("240", "Swing timeframe", group = G_TF)
string tf1d = input.timeframe("1D", "Position timeframe", group = G_TF)
string WEIGHT_TIP = "The agreement test is unanimity, so these weights cannot change the streak, the thresholds or any label. They scale only the optional weighted agreement mass line. Measured: 200 random weight vectors per symbol left every plotted number identical."
float w15Input = input.float(0.10, "Short-term weight", minval = 0.0, step = 0.05, group = G_TF, tooltip = WEIGHT_TIP)
float w1hInput = input.float(0.20, "Intraday weight", minval = 0.0, step = 0.05, group = G_TF)
float w4hInput = input.float(0.40, "Swing weight", minval = 0.0, step = 0.05, group = G_TF)
float w1dInput = input.float(0.30, "Position weight", minval = 0.0, step = 0.05, group = G_TF)

// -----------------------------------------------------------------------------
// 03. Streak distribution and signals
// -----------------------------------------------------------------------------
string G_ST = "03. Streak distribution and signals"
int maxSamples = input.int(200, "Max completed streaks kept", minval = 30, maxval = 1000, step = 10, group = G_ST)
int minSamples = input.int(30, "Min samples before scoring", minval = 5, maxval = 200, step = 5, group = G_ST,
     tooltip = "Capped by Max completed streaks kept. The stored history can never exceed that cap, so a larger value here would hold scoring off forever.")
float midPct = input.float(50.0, "Color mid percentile", minval = 10.0, maxval = 90.0, step = 5.0, group = G_ST,
     tooltip = "Affects the streak line's tint only. It moves no threshold, label or alert.")
float contPct = input.float(90.0, "Continuation percentile", minval = 50.0, maxval = 99.5, step = 0.5, group = G_ST)
float exhaustPct = input.float(95.0, "Exhaustion percentile", minval = 50.0, maxval = 99.9, step = 0.5, group = G_ST,
     tooltip = "Raised to the continuation percentile if set below it, so the exhaustion threshold can never sit under the continuation threshold and invert the shaded zone.")
string fireMode = input.string("Both", "Signal mode", options = ["Continuation follow", "Exhaustion watch", "Both"], group = G_ST,
     tooltip = "Governs the RARE and EXH labels and their alerts. The REC record marker is not gated by it.")
bool resetOnNewDay = input.bool(false, "Break streak at new calendar day", group = G_ST,
     tooltip = "Optional guard for symbols with real session breaks. Off by default: on 24h crypto there is no session to respect, and breaking runs at midnight would only shorten them.")
float obLevel = input.float(80.0, "Fast timeframe overbought level", minval = 50.0, maxval = 100.0, step = 1.0, group = G_ST,
     tooltip = "Filters the exhaustion state only, and it filters very little: 89% of BTCUSDT bars and 67% of ETHUSDT bars that already passed the percentile also passed this gate.")
float osLevel = input.float(20.0, "Fast timeframe oversold level", minval = 0.0, maxval = 50.0, step = 1.0, group = G_ST)
bool signalOnClose = input.bool(true, "Alerts only on confirmed chart bars", group = G_ST)

// -----------------------------------------------------------------------------
// 04. Visuals
// -----------------------------------------------------------------------------
string G_VIS = "04. Visuals"
bool showTable = input.bool(true, "Show audit table", group = G_VIS)
string tablePos = input.string("Top right", "Audit table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = G_VIS)
string tableSize = input.string("Small", "Audit table text size", options = ["Tiny", "Small", "Normal"], group = G_VIS)
bool showMass = input.bool(false, "Show weighted agreement mass line", group = G_VIS,
     tooltip = "Plotted on the same axis as the streak count, where it is a flat line near the bottom - it is a 0 to 1 quantity sharing an axis with a bar count.")
bool shadeRareZone = input.bool(true, "Fill between continuation and exhaustion thresholds", group = G_VIS,
     tooltip = "At default settings the two thresholds are equal on 83% of scored bars, so this band has zero height most of the time. It is drawn only where it has width.")

// -----------------------------------------------------------------------------
// Direction sensors
// -----------------------------------------------------------------------------
// The complete sensor is evaluated inside each requested timeframe.
f_dir() =>
    float kRaw = ta.stoch(close, high, low, stochLength)
    float k = ta.sma(kRaw, smoothK)
    float d = ta.sma(k, smoothD)
    float dir = math.sign(k - d)
    [k, d, dir]

f_dirConfirmed() =>
    [kk, dd, dr] = f_dir()
    [kk[1], dd[1], dr[1]]

[k15Dev, d15Dev, dir15Dev] = request.security(syminfo.tickerid, tf15, f_dir(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1hDev, d1hDev, dir1hDev] = request.security(syminfo.tickerid, tf1h, f_dir(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k4hDev, d4hDev, dir4hDev] = request.security(syminfo.tickerid, tf4h, f_dir(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[k1dDev, d1dDev, dir1dDev] = request.security(syminfo.tickerid, tf1d, f_dir(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

[k15Con, d15Con, dir15Con] = request.security(syminfo.tickerid, tf15, f_dirConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1hCon, d1hCon, dir1hCon] = request.security(syminfo.tickerid, tf1h, f_dirConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k4hCon, d4hCon, dir4hCon] = request.security(syminfo.tickerid, tf4h, f_dirConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[k1dCon, d1dCon, dir1dCon] = request.security(syminfo.tickerid, tf1d, f_dirConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

confirmedMode = dataMode == "Confirmed only"
float k15 = confirmedMode ? k15Con : k15Dev
float k1h = confirmedMode ? k1hCon : k1hDev
float k4h = confirmedMode ? k4hCon : k4hDev
float k1d = confirmedMode ? k1dCon : k1dDev
float d15 = confirmedMode ? d15Con : d15Dev
float d1h = confirmedMode ? d1hCon : d1hDev
float d4h = confirmedMode ? d4hCon : d4hDev
float d1d = confirmedMode ? d1dCon : d1dDev
float dir15 = confirmedMode ? dir15Con : dir15Dev
float dir1h = confirmedMode ? dir1hCon : dir1hDev
float dir4h = confirmedMode ? dir4hCon : dir4hDev
float dir1d = confirmedMode ? dir1dCon : dir1dDev

// Normalize agreement weights onto a simplex. All-zero input falls back to defaults.
float weightSum = w15Input + w1hInput + w4hInput + w1dInput
bool useDefaultW = weightSum <= 0.0
float w15 = useDefaultW ? 0.10 : w15Input / weightSum
float w1h = useDefaultW ? 0.20 : w1hInput / weightSum
float w4h = useDefaultW ? 0.40 : w4hInput / weightSum
float w1d = useDefaultW ? 0.30 : w1dInput / weightSum

// -----------------------------------------------------------------------------
// Warm-up
// -----------------------------------------------------------------------------
// Each sensor needs stochLength + smoothK + smoothD closed bars OF ITS OWN TIMEFRAME, which
// on a 15m chart is over two weeks of chart bars for the daily leg. Before that the streak
// is legitimately zero, but a flat zero line is indistinguishable from a measured "no
// agreement" reading, so the plot is blanked instead. This is display only - no run can be
// recorded while a direction is still na, so the stored distribution is untouched either way.
f_warmBars(string tf) =>
    float htfSec = timeframe.in_seconds(tf)
    float chartSec = math.max(timeframe.in_seconds(timeframe.period), 1)
    int ratio = math.max(1, math.ceil(htfSec / chartSec))
    ratio * (stochLength + smoothK + smoothD)

int warmBars = math.max(math.max(f_warmBars(tf15), f_warmBars(tf1h)), math.max(f_warmBars(tf4h), f_warmBars(tf1d)))
bool warm = bar_index >= warmBars

// -----------------------------------------------------------------------------
// Agreement state and streak counting (chart bars)
// -----------------------------------------------------------------------------
bool dirsValid = not na(dir15) and not na(dir1h) and not na(dir4h) and not na(dir1d)
float dirScore = w15 * nz(dir15, 0.0) + w1h * nz(dir1h, 0.0) + w4h * nz(dir4h, 0.0) + w1d * nz(dir1d, 0.0)
float domDir = dirsValid ? math.sign(dirScore) : 0.0
bool allSame = dirsValid and dir15 == dir1h and dir1h == dir4h and dir4h == dir1d
bool agreeRaw = allSame and domDir != 0.0
bool dayBreak = resetOnNewDay and timeframe.change("1D")
bool agree = agreeRaw and not dayBreak

int streak = ta.barssince(not agree)
bool streakEnd = agree[1] and not agree
int completedLen = streak[1]

var streaks = array.new_float()
if streakEnd and not na(completedLen)
    array.push(streaks, completedLen)
    if array.size(streaks) > maxSamples
        array.shift(streaks)

// The stored history is capped at maxSamples, so a minimum above that cap could never be
// reached and scoring would never start on any chart.
int minSamplesEff = math.min(minSamples, maxSamples)
int n = array.size(streaks)
bool samplesReady = n >= minSamplesEff

// Empirical percentile rank of the current run inside completed-run history.
int leCount = 0
if n > 0 and not na(streak)
    for i = 0 to n - 1
        if array.get(streaks, i) <= streak
            leCount += 1
float streakPctRaw = n > 0 and not na(streak) ? 100.0 * leCount / n : na
float streakPct = samplesReady ? streakPctRaw : na

// The exhaustion percentile is held at or above the continuation percentile. Both inputs
// carry independent ranges, and setting exhaustion below continuation would make the
// exhaustion state fire on shorter runs than continuation and invert the shaded zone.
float exhaustPctEff = math.max(exhaustPct, contPct)

// Array statistics are taken only through explicit guards so empty-array
// calls can never happen regardless of ternary evaluation order.
float qMid = na
float qCont = na
float qExhaust = na
float histMax = na
if samplesReady
    qMid := array.percentile_linear_interpolation(streaks, midPct)
    qCont := array.percentile_linear_interpolation(streaks, contPct)
    qExhaust := array.percentile_linear_interpolation(streaks, exhaustPctEff)
    histMax := array.max(streaks)

float agreeMass = (dir15 == domDir ? w15 : 0.0) + (dir1h == domDir ? w1h : 0.0) + (dir4h == domDir ? w4h : 0.0) + (dir1d == domDir ? w1d : 0.0)

// Extreme zone of the fast timeframe for the exhaustion mode. This was written as a sigmoid
// membership with a softness input, but the state compared that membership to 0.5, which is
// exactly k15 >= obLevel for any softness - the knob could not move a single bar on 6000.
// The comparison is written out directly rather than left as a control that does nothing.
bool bullExtreme = k15 >= obLevel
bool bearExtreme = k15 <= osLevel

// -----------------------------------------------------------------------------
// Signal states and events
// -----------------------------------------------------------------------------
bool fireCont = fireMode == "Continuation follow" or fireMode == "Both"
bool fireExh = fireMode == "Exhaustion watch" or fireMode == "Both"

bool scored = agree and samplesReady and not na(streak)
bool contBullState = scored and streak > qCont and domDir > 0.0
bool contBearState = scored and streak > qCont and domDir < 0.0
bool exhaustState = scored and streak > qExhaust and ((domDir > 0.0 and bullExtreme) or (domDir < 0.0 and bearExtreme))
bool recordState = scored and streak > histMax

chartBarGate = not signalOnClose or barstate.isconfirmed
bool contBullEvent = chartBarGate and fireCont and contBullState and not contBullState[1]
bool contBearEvent = chartBarGate and fireCont and contBearState and not contBearState[1]
bool exhaustEvent = chartBarGate and fireExh and exhaustState and not exhaustState[1]
bool recordEvent = chartBarGate and recordState and not recordState[1]

// -----------------------------------------------------------------------------
// Pane visuals
// -----------------------------------------------------------------------------
color cInk = color.rgb(216, 220, 226)
color cGray = color.rgb(128, 132, 138)
color cMid = color.rgb(109, 141, 122)
color cCont = color.rgb(178, 133, 66)
color cExh = color.rgb(163, 84, 70)
color cPanel = color.rgb(20, 23, 28)
color cLine = color.rgb(58, 63, 71)

// The colour is derived from the same states the labels are, not from a second rule. The
// original compared the percentile RANK to the percentile INPUT while the labels compared
// the raw streak to the interpolated QUANTILE, so the pane painted exhaustion red on runs
// one bar shorter than any run that could carry an exhaustion verdict - 10 of 18 red bars
// carried no verdict at all.
color streakColor = not samplesReady ? color.new(cGray, 40) :
     exhaustState ? color.new(cExh, 5) :
     (contBullState or contBearState) ? color.new(cCont, 5) :
     streakPct >= midPct ? color.new(cMid, 15) : color.new(cGray, 50)

// Draw order matters: the thresholds and the band go down first so the streak line stays
// readable on top of them.
contPlot = plot(warm ? qCont : na, "Continuation threshold", color = color.new(cCont, 30), linewidth = 1)
exhPlot = plot(warm ? qExhaust : na, "Exhaustion threshold", color = color.new(cExh, 25), linewidth = 1)
bool zoneHasWidth = not na(qCont) and not na(qExhaust) and qExhaust > qCont
fill(contPlot, exhPlot, color = shadeRareZone and zoneHasWidth ? color.new(cExh, 88) : na, title = "Rare streak zone")

plot(warm and showMass ? agreeMass : na, "Weighted agreement mass", color = color.new(cGray, 60), linewidth = 1)
// A run length is a small integer that is zero on 94% of bars. As a stepline that reads as a
// thin spike fence; as columns each run is a block whose height is its length, which is what
// the series actually is. Display only - the plotted values are unchanged.
plot(warm ? streak : na, "Agreement streak (chart bars)", color = streakColor, linewidth = 2, style = plot.style_columns, histbase = 0)

plotshape(recordEvent, "New streak record", style = shape.labelup, location = location.bottom, color = color.new(cMid, 15), text = "REC", textcolor = color.white, size = size.tiny)
plotshape(contBullEvent or contBearEvent, "Continuation zone entry", style = shape.labelup, location = location.top, color = contBullEvent ? color.new(cMid, 10) : color.new(cExh, 10), text = "RARE", textcolor = color.white, size = size.tiny)
plotshape(exhaustEvent, "Exhaustion watch", style = shape.labeldown, location = location.top, color = color.new(cExh, 5), text = "EXH", textcolor = color.white, size = size.tiny)

// Alerts fire on exactly the booleans that draw the labels. The original rarity alert
// compared the percentile rank to the percentile input while the label compared the streak
// to the quantile, so it fired one bar early on three of five labels and four more times
// with no label at all.
alertcondition(contBullEvent, "Bullish agreement streak continuation", "All watched timeframes agree upward and the run is longer than the continuation percentile of its own completed-run history. A distribution position, not a forecast.")
alertcondition(contBearEvent, "Bearish agreement streak continuation", "All watched timeframes agree downward and the run is longer than the continuation percentile of its own completed-run history. A distribution position, not a forecast.")
alertcondition(exhaustEvent, "Agreement streak exhaustion watch", "Run longer than the exhaustion percentile of its own history while the fast timeframe sits in an extreme zone. Persistence rarity does not imply reversal.")
alertcondition(recordEvent, "Agreement streak record", "The current run is longer than every completed run stored for this symbol.")

// -----------------------------------------------------------------------------
// Audit table (raw per-timeframe values and distribution state)
// -----------------------------------------------------------------------------
f_tfName(string tf) =>
    tf == "15" ? "15m" : tf == "60" ? "1H" : tf == "240" ? "4H" : tf == "1D" ? "1D" : tf

f_num(float value) => na(value) ? "-" : str.tostring(value, "0.0")

f_intTxt(float value) => na(value) ? "-" : str.tostring(value, "0")

f_dirTxt(float d) => na(d) ? "--" : d > 0.0 ? "UP" : d < 0.0 ? "DN" : "FL"

f_dirColor(float d) => na(d) ? cGray : d > 0.0 ? cMid : d < 0.0 ? cExh : cGray

int secPerBar = timeframe.in_seconds(timeframe.period)
float streakHours = na(streak) ? na : streak * secPerBar / 3600.0
string streakTimeTxt = na(streakHours) ? "-" : streakHours >= 1.0 ? str.tostring(streakHours, "0.0") + "h" : str.tostring(streakHours * 60.0, "0") + "m"

tablePosition = tablePos == "Top left" ? position.top_left : tablePos == "Bottom right" ? position.bottom_right : tablePos == "Bottom left" ? position.bottom_left : position.top_right
tableTextSize = tableSize == "Tiny" ? size.tiny : tableSize == "Normal" ? size.normal : size.small

var table auditTable = table.new(position.top_right, 4, 8, border_color = cLine, border_width = 1, frame_color = cLine, frame_width = 1)

f_head(int col, int row, string txt) =>
    table.cell(auditTable, col, row, txt, text_color = cGray, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_right)

f_cell(int col, int row, string txt, color txtColor) =>
    table.cell(auditTable, col, row, txt, text_color = txtColor, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_right)

if barstate.islast and showTable
    table.set_position(auditTable, tablePosition)

    f_head(0, 0, "TF")
    f_head(1, 0, "%K")
    f_head(2, 0, "%D")
    f_head(3, 0, "DIR")

    table.cell(auditTable, 0, 1, f_tfName(tf15), text_color = cInk, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)
    f_cell(1, 1, f_num(k15), cInk)
    f_cell(2, 1, f_num(d15), cInk)
    f_cell(3, 1, f_dirTxt(dir15), f_dirColor(dir15))

    table.cell(auditTable, 0, 2, f_tfName(tf1h), text_color = cInk, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)
    f_cell(1, 2, f_num(k1h), cInk)
    f_cell(2, 2, f_num(d1h), cInk)
    f_cell(3, 2, f_dirTxt(dir1h), f_dirColor(dir1h))

    table.cell(auditTable, 0, 3, f_tfName(tf4h), text_color = cInk, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)
    f_cell(1, 3, f_num(k4h), cInk)
    f_cell(2, 3, f_num(d4h), cInk)
    f_cell(3, 3, f_dirTxt(dir4h), f_dirColor(dir4h))

    table.cell(auditTable, 0, 4, f_tfName(tf1d), text_color = cInk, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)
    f_cell(1, 4, f_num(k1d), cInk)
    f_cell(2, 4, f_num(d1d), cInk)
    f_cell(3, 4, f_dirTxt(dir1d), f_dirColor(dir1d))

    table.cell(auditTable, 0, 5, "RUN", text_color = cGray, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)
    f_cell(1, 5, warm ? f_intTxt(streak) + "b" : "-", agree ? cInk : cGray)
    f_cell(2, 5, warm ? streakTimeTxt : "-", agree ? cInk : cGray)
    f_cell(3, 5, f_dirTxt(agree ? domDir : na), f_dirColor(agree ? domDir : na))

    table.cell(auditTable, 0, 6, "PCTL", text_color = cGray, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)
    f_cell(1, 6, na(streakPct) ? "-" : f_num(streakPct), cInk)
    f_cell(2, 6, "n=" + str.tostring(n), cGray)
    f_cell(3, 6, not samplesReady ? "WARM" : exhaustState ? "EXH" : (contBullState or contBearState) ? "RARE" : "-",
         not samplesReady ? cGray : exhaustState ? cExh : (contBullState or contBearState) ? cCont : cGray)

    table.cell(auditTable, 0, 7, "THR", text_color = cGray, text_size = tableTextSize, bgcolor = cPanel, text_halign = text.align_left)
    f_cell(1, 7, f_num(qCont), cCont)
    f_cell(2, 7, f_num(qExhaust), cExh)
    f_cell(3, 7, f_num(histMax) + "max", cGray)
````
