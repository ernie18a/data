# Volume Activity Suite

- url: https://www.tradingview.com/script/ML56Rx6L/
- type: indicator
- pine_id: PUB;79dca6b4eb894f4cad5c4abc558d24d0
- version: 1.0

## Description

A daily-stock panel that answers one question from several angles: is trading participation right now unusually high, normal, or unusually low relative to this stock's own recent history, and what does that imply when read together with price?
 
Volume is right-skewed and heavy-tailed, so comparing today's volume to a simple average is easily distorted by a few spike days. This tool handles that with a log transform, a baseline taken over the window up to the previous bar, and distribution-free ranking, and it adds a few refinements drawn from the abnormal-volume and market-microstructure literature.
 
Metrics. All are computed every bar. The pane plots the one you select in Display, and the table shows them together.
 
Log Z is the z-score of log volume over a rolling baseline. Because log volume is close to normal in its bulk, the z-score reads as how many standard deviations the current volume sits from its usual level. The zero line is the normal level, the green line marks the high threshold, and the red line marks the low threshold.
 
Percentile is the rank of today's volume within the lookback window. It assumes nothing about the distribution, so it is the most robust to fat tails and the most sensitive to quiet periods.
 
RVOL is classic relative volume: today's volume divided by the prior-window average.
 
PVO is the Percentage Volume Oscillator, the MACD calculation applied to volume. It reads whether the volume regime is expanding or shrinking rather than its level.
 
Bias combines activity with price direction into an accumulation, distribution, or quiet read.
 
Range and Flow add a volume-versus-range view based on the Mixture of Distributions Hypothesis, under which volume and price movement are jointly driven by information arrival. Range is the z-score of the day's true range. Flow labels a high-volume day as Conviction when the range is also wide, or Churn when the range is narrow.
 
Options.
 
Volume basis can be raw share volume or turnover, shares traded relative to shares outstanding, following the log relative-volume approach used in volume event studies. Turnover normalizes for share-count changes and falls back to share volume when the data is unavailable.
 
Robust z-score replaces mean and standard deviation with median and MAD, so that a few extreme days do not distort the baseline.
 
Market-adjust subtracts a market symbol's log-volume z from the stock's, isolating stock-specific volume from days when the whole market trades heavily.
 
Reading it. The columns show where the day sits versus its own history. Colored bars flag the days where real participation entered, while ordinary days stay gray. Because volume measures participation rather than direction, read the panel alongside price: high volume on an up day is accumulation-like, high volume on a down day is distribution-like, and a decline on drying-up volume is drift rather than heavy selling.
 
Notes and limits. This is a descriptive context tool, not a buy or sell signal. Volume does not predict direction, and the accumulation, distribution, conviction, and churn labels are heuristics rather than conclusions. Everything is measured relative to the stock's own recent window, so regime shifts and the usual heavy-tail caveats apply. Nothing here is financial advice.

## Source Code

````pine
//@version=6
// Volume Activity Suite
// A daily-stock panel for judging whether recent volume is active or quiet.
//
// Metrics (all computed every bar; the pane plots the one selected in Display):
//   Log Z      : z-score of log(volume) over a rolling baseline. Volume is heavy
//                tailed, but log volume is close to normal in the bulk, so the
//                z-score is interpretable.
//   Percentile : ta.percentrank of volume. Distribution-free; most robust to fat
//                tails and most sensitive to quiet periods.
//   RVOL       : volume divided by the prior-window average volume.
//   PVO        : MACD applied to volume (momentum of volume, not a level).
//
// Literature-based options:
//   - Volume basis: raw share volume, or turnover (shares traded / shares
//     outstanding), following Campbell and Wasley (1996) log relative-volume
//     event studies. Turnover normalizes for share-count changes.
//   - Robust z: median and MAD instead of mean and standard deviation, because
//     abnormal daily volume is extremely skewed and kurtotic.
//   - Market adjustment: subtract a market symbol's log-volume z, isolating
//     stock-specific volume from market-wide volume days (market-model idea).
//   - Volume vs range (Mixture of Distributions Hypothesis): high volume with a
//     wide range reads as conviction; high volume with a narrow range as churn.
//
// Baselines use the window up to the previous bar, so today does not inflate its
// own reference. Volume measures participation, not direction; read it with price.

indicator("Volume Activity Suite", shorttitle="VolActivity", overlay=false, precision=2)

// --- Inputs: baseline ---
groupBaseline = "Baseline"
lookback   = input.int(60, "Baseline lookback (bars)", minval=5, group=groupBaseline, tooltip="Rolling window used as the normal reference. On daily bars, 60 is about one quarter.")
rvolLength = input.int(20, "RVOL average length", minval=2, group=groupBaseline)

// --- Inputs: volume basis and normalization ---
groupNorm = "Volume basis and normalization"
volumeBasis  = input.string("Share volume", "Volume basis", options=["Share volume", "Turnover"], group=groupNorm, tooltip="Turnover divides volume by shares outstanding, normalizing for share-count changes. Falls back to share volume when shares outstanding is unavailable.")
zRobust      = input.bool(false, "Robust z-score (median and MAD)", group=groupNorm, tooltip="Uses median and MAD instead of mean and standard deviation, so a few extreme days do not distort the baseline. Affects Log Z and the range z.")
marketAdjust = input.bool(false, "Market-adjust Log Z", group=groupNorm, tooltip="Subtracts the market symbol's log-volume z from the stock's, isolating stock-specific volume from market-wide volume days. Affects Log Z only.")
marketSymbol = input.symbol("AMEX:SPY", "Market symbol", group=groupNorm)

// --- Inputs: optional deseasonalization ---
groupSeasonal = "Deseasonalize"
useWeekday = input.bool(false, "Adjust for day-of-week effect", group=groupSeasonal, tooltip="Divides volume by (average volume of the same weekday in the window / overall window average). Mild on daily bars, so off by default.")

// --- Inputs: display ---
groupDisplay = "Display"
metric          = input.string("Log Z", "Metric to plot", options=["Log Z", "Percentile", "RVOL", "PVO"], group=groupDisplay, tooltip="All metrics are always computed; this selects which one is plotted. The table shows all of them.")
showContext     = input.bool(true, "Add volume-vs-range read (MDH)", group=groupDisplay, tooltip="Adds a Range row and a Flow row (Conviction / Churn / Active) comparing volume activity with the day's range.")
showTable       = input.bool(true, "Show summary table", group=groupDisplay)
tablePosition   = input.string("Bottom Center", "Table position", options=["Bottom Center", "Bottom Left", "Bottom Right", "Top Center", "Top Left", "Top Right", "Middle Right"], group=groupDisplay)
tableHorizontal = input.bool(true, "Horizontal table (metrics as columns)", group=groupDisplay)
tableTextSize   = input.string("Normal", "Table text size", options=["Tiny", "Small", "Normal", "Large"], group=groupDisplay)

// --- Inputs: coloring ---
groupColor = "Coloring"
colorScheme    = input.string("Spikes", "Color scheme", options=["Spikes", "Direction", "Activity"], group=groupColor, tooltip="Spikes: ordinary bars gray, only high-volume days colored (green up, red down). Direction: every bar colored by price. Activity: high green, low red, normal gray. PVO mode is unaffected.")
directionBasis = input.string("Candle", "Direction basis", options=["Candle", "Daily change"], group=groupColor, tooltip="How an up or down day is decided. Candle: close vs open. Daily change: close vs previous close.")

// --- Inputs: thresholds ---
groupThreshold = "Thresholds"
zHigh    = input.float(2.0,  "Z-Score high",    group=groupThreshold)
zLow     = input.float(-2.0, "Z-Score low",     group=groupThreshold)
pctHigh  = input.float(80,   "Percentile high", group=groupThreshold)
pctLow   = input.float(20,   "Percentile low",  group=groupThreshold)
rvolHigh = input.float(2.0,  "RVOL high",       group=groupThreshold)
rvolLow  = input.float(0.5,  "RVOL low",        group=groupThreshold)

// --- Inputs: PVO ---
groupPvo = "PVO"
pvoFastLength   = input.int(12, "PVO fast EMA",   minval=1, group=groupPvo)
pvoSlowLength   = input.int(26, "PVO slow EMA",   minval=2, group=groupPvo)
pvoSignalLength = input.int(9,  "PVO signal EMA", minval=1, group=groupPvo)

// --- Log z-score helper: standard (mean, stdev) or robust (median, MAD), on the prior window ---
logZScore(float logSeries, simple int length, bool robust) =>
    float mean  = ta.sma(logSeries, length)[1]
    float stdev = ta.stdev(logSeries, length)[1]
    float standardZ = (not na(stdev) and stdev > 0) ? (logSeries - mean) / stdev : na
    float rollingMedian = ta.median(logSeries, length)
    float median = rollingMedian[1]
    float mad = ta.median(math.abs(logSeries - rollingMedian), length)[1]
    float robustZ = (not na(mad) and mad > 0) ? 0.6745 * (logSeries - median) / mad : na
    robust ? robustZ : standardZ

// --- Volume basis: share volume or turnover (shares traded * 100 / shares outstanding) ---
float sharesOutstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
bool  useTurnover = volumeBasis == "Turnover" and not na(sharesOutstanding) and sharesOutstanding > 0
float baseVolume  = useTurnover ? volume / sharesOutstanding * 100 : volume
float logConstant = useTurnover ? 0.000255 : 1.0

// --- Optional day-of-week deseasonalization ---
float adjustedVolume = baseVolume
if useWeekday
    float sumSameDay   = 0.0
    float sumAllDays   = 0.0
    int   countSameDay = 0
    int   countAllDays = 0
    for i = 0 to lookback - 1
        float pastVolume = baseVolume[i]
        if not na(pastVolume)
            sumAllDays   := sumAllDays + pastVolume
            countAllDays := countAllDays + 1
            if dayofweek[i] == dayofweek
                sumSameDay   := sumSameDay + pastVolume
                countSameDay := countSameDay + 1
    float avgSameDay = countSameDay > 0 ? sumSameDay / countSameDay : na
    float avgAllDays = countAllDays > 0 ? sumAllDays / countAllDays : na
    float factor     = (not na(avgSameDay) and not na(avgAllDays) and avgAllDays > 0) ? avgSameDay / avgAllDays : 1.0
    adjustedVolume  := factor > 0 ? baseVolume / factor : baseVolume

// --- Core volume metrics ---
float stockLogVolume = math.log(adjustedVolume + logConstant)
float stockZ = logZScore(stockLogVolume, lookback, zRobust)

float marketVolume = request.security(marketSymbol, timeframe.period, volume, ignore_invalid_symbol = true)
float marketZ = logZScore(math.log(marketVolume + 1.0), lookback, zRobust)
float logZ = (marketAdjust and not na(marketZ)) ? stockZ - marketZ : stockZ

float pctRank = ta.percentrank(adjustedVolume, lookback)

float avgVolume = ta.sma(adjustedVolume, rvolLength)[1]
float rvol = (not na(avgVolume) and avgVolume > 0) ? adjustedVolume / avgVolume : na

float volFastEma = ta.ema(adjustedVolume, pvoFastLength)
float volSlowEma = ta.ema(adjustedVolume, pvoSlowLength)
float pvo = volSlowEma != 0 ? (volFastEma - volSlowEma) / volSlowEma * 100 : na
float pvoSignal = ta.ema(pvo, pvoSignalLength)
float pvoHist = pvo - pvoSignal

// --- Range z: log true range, same method as volume, as a volatility proxy for the MDH read ---
float rangeValue = ta.tr(true)
float rangeZ = logZScore(math.log(math.max(rangeValue, syminfo.mintick)), lookback, zRobust)

// --- State of the selected metric ---
bool isHigh = metric == "Log Z" ? (not na(logZ) and logZ >= zHigh) : metric == "Percentile" ? (not na(pctRank) and pctRank >= pctHigh) : metric == "RVOL" ? (not na(rvol) and rvol >= rvolHigh) : metric == "PVO" ? (not na(pvo) and pvo > 0) : false
bool isLow  = metric == "Log Z" ? (not na(logZ) and logZ <= zLow)  : metric == "Percentile" ? (not na(pctRank) and pctRank <= pctLow)  : metric == "RVOL" ? (not na(rvol) and rvol <= rvolLow)  : metric == "PVO" ? (not na(pvo) and pvo < 0) : false

// --- Direction of the current bar ---
bool isUp = directionBasis == "Daily change" ? (not na(close[1]) and close >= close[1]) : close >= open

// --- Colors ---
color colorUp   = color.new(#26a69a, 0)
color colorDown = color.new(#ef5350, 0)
color colorGray = color.new(#9598a1, 35)

color mainColor = colorScheme == "Direction" ? (isUp ? colorUp : colorDown) : colorScheme == "Activity" ? (isHigh ? colorUp : isLow ? colorDown : colorGray) : (isHigh ? (isUp ? colorUp : colorDown) : colorGray)

// --- Plots: only the selected metric is non-na, so scales never clash ---
float plottedValue = metric == "Log Z" ? logZ : metric == "Percentile" ? pctRank : metric == "RVOL" ? rvol : na
plot(plottedValue, "Selected metric", color=mainColor, style=plot.style_columns)

plot(metric == "PVO" ? pvo : na, "PVO", color=color.new(#2962ff, 0), linewidth=2)
plot(metric == "PVO" ? pvoSignal : na, "PVO signal", color=color.new(#ff6d00, 0))
color pvoHistColor = (not na(pvoHist) and pvoHist >= 0) ? color.new(#26a69a, 30) : color.new(#ef5350, 30)
plot(metric == "PVO" ? pvoHist : na, "PVO histogram", color=pvoHistColor, style=plot.style_columns)

// --- Reference lines follow the selected metric ---
float refHigh = metric == "Log Z" ? zHigh : metric == "Percentile" ? pctHigh : metric == "RVOL" ? rvolHigh : na
float refMid  = metric == "Log Z" ? 0.0   : metric == "Percentile" ? 50.0    : metric == "RVOL" ? 1.0      : metric == "PVO" ? 0.0 : na
float refLow  = metric == "Log Z" ? zLow  : metric == "Percentile" ? pctLow  : metric == "RVOL" ? rvolLow  : na
plot(refHigh, "High reference", color=color.new(#26a69a, 55), style=plot.style_stepline)
plot(refMid,  "Mid reference",  color=color.new(#787b86, 40), style=plot.style_stepline)
plot(refLow,  "Low reference",  color=color.new(#ef5350, 55), style=plot.style_stepline)

// --- Summary table ---
stateLabel(float value, float high, float low) =>
    na(value) ? "NA" : value >= high ? "High" : value <= low ? "Low" : "Normal"

stateColor(float value, float high, float low) =>
    na(value) ? colorGray : value >= high ? colorUp : value <= low ? colorDown : colorGray

color headerBg    = color.new(#363a45, 0)
color bodyBg      = color.new(#1e222d, 0)
color colorChurn  = color.new(#ffa726, 0)
color colorActive = color.new(#42a5f5, 0)

tablePos = tablePosition == "Bottom Center" ? position.bottom_center : tablePosition == "Bottom Left" ? position.bottom_left : tablePosition == "Bottom Right" ? position.bottom_right : tablePosition == "Top Center" ? position.top_center : tablePosition == "Top Left" ? position.top_left : tablePosition == "Middle Right" ? position.middle_right : position.top_right
textSize = tableTextSize == "Tiny" ? size.tiny : tableTextSize == "Small" ? size.small : tableTextSize == "Large" ? size.large : size.normal

// Volume vs range (Mixture of Distributions Hypothesis) flow read
bool volumeHigh = not na(logZ) and logZ >= zHigh
bool rangeHigh  = not na(rangeZ) and rangeZ >= zHigh
bool rangeLow   = not na(rangeZ) and rangeZ <= zLow
string flowState = not volumeHigh ? "Normal" : rangeHigh ? "Conviction" : rangeLow ? "Churn" : "Active"
color  flowColor = not volumeHigh ? colorGray : rangeHigh ? colorUp : rangeLow ? colorChurn : colorActive

// Per-metric readings ("value (state)") and their state colors
string readingZ     = (na(logZ)    ? "NA" : str.tostring(logZ, "#.00"))       + " (" + stateLabel(logZ, zHigh, zLow) + ")"
string readingPct   = (na(pctRank) ? "NA" : str.tostring(pctRank, "#") + "%") + " (" + stateLabel(pctRank, pctHigh, pctLow) + ")"
string readingRvol  = (na(rvol)    ? "NA" : str.tostring(rvol, "#.00") + "x") + " (" + stateLabel(rvol, rvolHigh, rvolLow) + ")"
string readingPvo   = (na(pvo)     ? "NA" : str.tostring(pvo, "#.0"))         + " (" + (na(pvo) ? "NA" : pvo > 0 ? "Vol above avg" : "Vol below avg") + ")"
string readingBias  = (isUp ? "Up day" : "Down day") + " (" + (isHigh ? (isUp ? "Accumulation" : "Distribution") : isLow ? (isUp ? "Quiet up" : "Quiet down") : "Normal") + ")"
string readingRange = (na(rangeZ)  ? "NA" : str.tostring(rangeZ, "#.00"))     + " (" + stateLabel(rangeZ, zHigh, zLow) + ")"

color colorZ     = stateColor(logZ, zHigh, zLow)
color colorPct   = stateColor(pctRank, pctHigh, pctLow)
color colorRvol  = stateColor(rvol, rvolHigh, rvolLow)
color colorPvo   = na(pvo) ? colorGray : pvo > 0 ? colorUp : colorDown
color colorBias  = isHigh ? (isUp ? colorUp : colorDown) : isLow ? (isUp ? color.new(#4db6ac, 0) : color.new(#e57373, 0)) : color.new(#b2b5be, 0)
color colorRange = stateColor(rangeZ, zHigh, zLow)

metricNames    = showContext ? array.from("Log Z", "Percentile", "RVOL", "PVO", "Bias", "Range", "Flow") : array.from("Log Z", "Percentile", "RVOL", "PVO", "Bias")
metricReadings = showContext ? array.from(readingZ, readingPct, readingRvol, readingPvo, readingBias, readingRange, flowState) : array.from(readingZ, readingPct, readingRvol, readingPvo, readingBias)
metricColors   = showContext ? array.from(colorZ, colorPct, colorRvol, colorPvo, colorBias, colorRange, flowColor) : array.from(colorZ, colorPct, colorRvol, colorPvo, colorBias)

int metricCount = array.size(metricNames)
var table summaryTable = table.new(tablePos, tableHorizontal ? (showContext ? 7 : 5) : 2, tableHorizontal ? 2 : (showContext ? 7 : 5), border_width=1, border_color=color.new(#363a45, 0))
if showTable and barstate.islast
    if tableHorizontal
        for i = 0 to metricCount - 1
            table.cell(summaryTable, i, 0, array.get(metricNames, i),    text_color=color.white,               text_size=textSize, bgcolor=headerBg)
            table.cell(summaryTable, i, 1, array.get(metricReadings, i), text_color=array.get(metricColors, i), text_size=textSize, bgcolor=bodyBg)
    else
        for i = 0 to metricCount - 1
            table.cell(summaryTable, 0, i, array.get(metricNames, i),    text_color=color.white,               text_size=textSize, bgcolor=headerBg)
            table.cell(summaryTable, 1, i, array.get(metricReadings, i), text_color=array.get(metricColors, i), text_size=textSize, bgcolor=bodyBg)

// --- Alerts ---
alertcondition(ta.crossover(logZ, zHigh),      "Log volume Z spike", "Log-volume z-score crossed above the high threshold")
alertcondition(ta.crossover(rvol, rvolHigh),   "RVOL spike",         "RVOL crossed above the high threshold")
alertcondition(ta.crossunder(pctRank, pctLow), "Volume dry up",      "Volume percentile dropped below the low threshold")
````
