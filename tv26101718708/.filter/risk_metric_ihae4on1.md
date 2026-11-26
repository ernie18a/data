# Risk Metric

- url: https://www.tradingview.com/script/IHAE4oN1-Risk-Metric/
- type: indicator
- pine_id: PUB;0aa40fc42bca492dad4d0c623c331f03
- version: 1.0

## Description

ZIZO Risk Metric
Hard money. Don't trust. Verify.
OVERVIEW
ZIZO Risk Metric scores Bitcoin on a 0–100 scale. 0 means maximum opportunity (deep value). 100 means maximum risk (stretched). It answers one question: how expensive is price right now relative to its own long-term trend?
Every anchor in this script is fixed and chosen on purpose. Nothing refits itself to recent price. That is the point — the metric is a verification tool, not a curve that chases the market.
THE IDEA
Price rarely sits at a fair value. It swings between two log-scaled boundaries around a 200-period moving average. This script measures where price sits between those two boundaries, on a log scale, and turns that position into a single number.
Low readings cluster near cycle bottoms. High readings cluster near cycle tops. The scale compresses over time to reflect diminishing returns as the asset matures.
HOW IT WORKS
Two bounds are built from the SMA:

Upper bound = 3.0 × SMA × scale
Lower bound = 0.35 × SMA (static by default)

The scale factor gently contracts the upper bound over time:
scale = e^(decay × (bar_index − offset) × sensitivity) + baseline
Risk is the log-distance of price between the two bounds:
Risk = (ln price − ln lower) / (ln upper − ln lower), clamped to 0–1, shown ×100.
The smoothed line applies the same transform to the SMA instead of raw price. It strips out daily noise and shows the underlying cycle position.
HOW TO READ IT

Colour map runs cool (low risk) to hot (high risk).
Green zone = accumulation. Red zone = distribution.
Exit threshold default: 89.43. Entry threshold default: 32.79.
The weighted Entry/Exit plot suggests a DCA weight that scales up as risk moves deeper into a zone. It only fires inside the entry or exit band, and it caps at the cutoff (default 9%).

SETTINGS

Risk Metric — SMA length, time offset, decay, sensitivity, baseline, and the two bounds. These define the model. Once calibrated, leave them fixed.
Colorway — heat-map colouring and the legend table.
Weighted Entry/Exit — base, exponent, cutoff, and the two thresholds that define the accumulation and distribution zones.
Model X Overlays — threshold lines, shaded zone fills, and an optional 50 midline.
Timeframe — evaluate the metric on Daily, Weekly, Monthly, or the chart's own resolution.

WHAT THIS VERSION ADDS
Rebuilt on foosmoo's Risk Metric core. Additions over the original:

Full colour-map redesign on a clean 0–100 display scale
Smoothed risk line derived from the SMA
Weighted, zone-aware entry/exit DCA percentages
Threshold lines, zone fills, and midline overlays
Time-offset marker and colour-map legend table
Entry-zone and exit-zone alert conditions

CREDITS & LICENSE
Based on foosmoo's Risk Metric (v2.2), used under the Mozilla Public License 2.0. This script keeps that licence. Full text: https://mozilla.org/MPL/2.0/
DISCLAIMER
This is an educational and research tool, not financial advice. Risk metrics describe the past and present. They do not predict the future. Verify every number yourself before acting on it.
Hard money. Don't trust. Verify.

## Source Code

````pine
//@version=6
indicator("PseudoNakamoto21 Risk", " Risk Metric", overlay = false, precision = 2)

// ─── INPUTS & ENUMS ────────────────────────────────────────────────────────

enum TimeFramePeriod
    DAILY
    WEEKLY
    MONTHLY
    CHART

// Convert enum to valid Pine Script v6 timeframe strings
method asString(TimeFramePeriod p) =>
    switch p
        TimeFramePeriod.DAILY   => "D"
        TimeFramePeriod.WEEKLY  => "W"
        TimeFramePeriod.MONTHLY => "M"
        TimeFramePeriod.CHART   => "Chart"

// Risk Metric core — v3.9 defaults
smaLen            = input.int  (defval = 200,    title = "SMA length",       group = "Risk Metric",  inline = "UI_1")
sfTimeOffset      = input.int  (defval = 126,    title = "Time offset",      group = "Risk Metric",  inline = "UI_1", minval = 0, tooltip = "Centering offset for the exponential transformation relative to bar_index")
sfDecay           = input.float(defval = -0.85,  title = "Decay",            group = "Risk Metric",  inline = "UI_2", tooltip = "Exponent multiplier controlling how quickly dynamic bounds change with bar_index")
sfSensitivity     = input.float(defval = 0.006,  title = "Sensitivity",      group = "Risk Metric",  inline = "UI_2", tooltip = "Time-sensitivity of dynamic bound adjustments")
sfBaselineControl = input.float(defval = 1.024,  title = "Baseline control", group = "Risk Metric",  inline = "1",    tooltip = "Additive offset for dynamic bounds — keeps them positive and non-trivial")

upperbound          = input.float(defval = 3.0,  title = "Upper bound",      group = "Risk Metric",  inline = "2",    tooltip = "Headroom multiplier above the SMA baseline")
lowerbound          = input.float(defval = 0.35, title = "Lower bound",      group = "Risk Metric",  inline = "2",    tooltip = "Log-scale compression multiplier below the SMA baseline")
lowerboundIsDynamic = input.bool (defval = false,title = "Lowerbound is dynamic", group = "Risk Metric", inline = "2", tooltip = "Recommended: false")
timeframeInput      = input.enum (defval = TimeFramePeriod.DAILY, title = "Timeframe", group = "Risk Metric", inline = "3")
showSmoothedRiskMetric = input.bool(defval = true, title = "Show Smoothing", group = "Risk Metric", inline = "3")

// Colorway
showColorway        = input.bool(defval = true, title = "Colorway",        group = "Colorway", inline = "4")
showColorwayLegend  = input.bool(defval = true, title = "Colorway Legend", group = "Colorway", inline = "4")

// Weighted Entry/Exit — v3.9 thresholds on 0-100 scale
showEntryExit       = input.bool (defval = true,    title = "Show Entry/Exit", group = "Weighted Entry/Exit", inline = "5")
baseForWeight       = input.float(defval = 7.0,     title = "Base",            group = "Weighted Entry/Exit", inline = "6")
exponentForWeight   = input.float(defval = 2.5,     title = "Exponent",        group = "Weighted Entry/Exit", inline = "6")
cutoffForWeight     = input.float(defval = 0.09,    title = "Cutoff",          group = "Weighted Entry/Exit", inline = "6", minval = 0.0, maxval = 1.0)

exitThresholdComparator  = input.string(defval = ">=", title = "Exit condition: Risk Metric",  options = [">=", ">"], group = "Weighted Entry/Exit", inline = "7")
exitThresholdPct         = input.float (defval = 89.43, title = "",                            group = "Weighted Entry/Exit", inline = "7", minval = 0.0, maxval = 100.0)

entryThresholdComparator = input.string(defval = "<=", title = "Entry condition: Risk Metric", options = ["<=", "<"], group = "Weighted Entry/Exit", inline = "8")
entryThresholdPct        = input.float (defval = 32.79, title = "",                            group = "Weighted Entry/Exit", inline = "8", minval = 0.0, maxval = 100.0)

// Model X overlays (custom additions)
showThresholdLines = input.bool(defval = true,  title = "Threshold lines",  group = "Model X Overlays", inline = "9")
showZoneFills      = input.bool(defval = false, title = "Zone fills",       group = "Model X Overlays", inline = "9")
showMidline        = input.bool(defval = false,  title = "50 midline",       group = "Model X Overlays", inline = "10")


// ─── VALIDATION & SETUP ────────────────────────────────────────────────────

// Safe initialization of mutable offset variable for v6 compiler
var int adjustedOffset = sfTimeOffset
if barstate.isfirst and adjustedOffset > last_bar_index
    adjustedOffset := last_bar_index

string timeframePreference = timeframeInput.asString()
string resolvedTimeframe = timeframePreference == "Chart" ? "" : timeframePreference

// Internal 0-1 versions of thresholds
float exitThreshold  = exitThresholdPct  / 100.0
float entryThreshold = entryThresholdPct / 100.0


// ─── FUNCTIONS & TABLES (Persistent Global Declarations) ────────────────────

var table legendTable   = table.new(position = position.top_left, columns = 12, rows = 2, bgcolor = chart.bg_color, frame_width = 0, border_width = 0)
var table entryExitTable = table.new(position = position.bottom_center, columns = 10, rows = 3, bgcolor = chart.bg_color, frame_width = 0, border_width = 0)

riskMetricFrom(float price, float upperBound, float lowerBound) =>
    float logUpperBound = math.log(upperBound)
    float logLowerBound = math.log(lowerBound)
    float logPrice      = math.log(price)
    (logPrice - logLowerBound) / (logUpperBound - logLowerBound)

isExitTriggered (float riskMetric) => exitThresholdComparator  == ">=" ? riskMetric >= exitThreshold  : riskMetric >  exitThreshold
isEntryTriggered(float riskMetric) => entryThresholdComparator == "<=" ? riskMetric <= entryThreshold : riskMetric <  entryThreshold

weight(float riskMetric, float base, float exponent, float threshold) =>
    math.min(base * math.pow((isEntryTriggered(riskMetric) ? 1 - riskMetric : riskMetric), exponent), threshold * 100)

adjustTransparency(color col, int transparency) =>
    color.rgb(color.r(col), color.g(col), color.b(col), transparency)

// Colormap — v6 optimized direct inline map declaration
var map<string, color> riskMetricColorMap = map.new<string, color>()
if barstate.isfirst
    riskMetricColorMap.put("1.0", #e6392e)
    riskMetricColorMap.put("0.9", #ff6633)
    riskMetricColorMap.put("0.8", #ff9933)
    riskMetricColorMap.put("0.7", #ffcc33)
    riskMetricColorMap.put("0.6", #e6e64c)
    riskMetricColorMap.put("0.5", #a6d96e)
    riskMetricColorMap.put("0.4", #3ed9a6)
    riskMetricColorMap.put("0.3", #2eb8d9)
    riskMetricColorMap.put("0.2", #1e7cc2)
    riskMetricColorMap.put("0.1", #0a4d8c)

var map<color, string> rangeForColorMap = map.new<color, string>()
if barstate.isfirst
    rangeForColorMap.put(#e6392e, "100")
    rangeForColorMap.put(#ff6633, " 90")
    rangeForColorMap.put(#ff9933, " 80")
    rangeForColorMap.put(#ffcc33, " 70")
    rangeForColorMap.put(#e6e64c, " 60")
    rangeForColorMap.put(#a6d96e, " 50")
    rangeForColorMap.put(#3ed9a6, " 40")
    rangeForColorMap.put(#2eb8d9, " 30")
    rangeForColorMap.put(#1e7cc2, " 20")
    rangeForColorMap.put(#0a4d8c, " 10")

colorForRiskMetric(float metric) =>
    float clampedMetric = math.min(1.0, math.max(0.0, metric))
    string key = str.tostring(clampedMetric, "0.0")
    color c = riskMetricColorMap.get(key)
    if bar_index < adjustedOffset
        c := adjustTransparency(c, 95)
    c

rangeForColor(color c) => rangeForColorMap.get(c)

colorForEntryExit(float riskMetric) =>
    switch
        isExitTriggered(riskMetric)  => color.new(color.red,   35)
        isEntryTriggered(riskMetric) => color.new(color.green, 35)
        => na

tableSetCell(table t, int col, int row, string s, color bg, color c, string sz) =>
    table.cell_set_text      (t, col, row, s)
    table.cell_set_bgcolor   (t, col, row, bg)
    table.cell_set_text_color(t, col, row, c)
    table.cell_set_text_size (t, col, row, sz)

renderColorwayLegend() =>
    tableSetCell(legendTable, 0, 0, "", chart.bg_color, chart.bg_color, size.small)
    tableSetCell(legendTable, 0, 1, "ColourMap", chart.bg_color, color.white, size.tiny)
    int z = 1
    for j = 0.0 to 1.0 by 0.1
        tableSetCell(legendTable, z, 1, rangeForColor(colorForRiskMetric(j)), chart.bg_color, colorForRiskMetric(j), size.small)
        z += 1

renderTimeOffsetMarker(float y) =>
    if timeframe.isdwm
        label.new(adjustedOffset, 150.0, "Time Offset", color = color.orange, textcolor = color.black, style = label.style_label_down, textalign = text.align_center, size = size.tiny)
        line.new(chart.point.from_index(adjustedOffset, 150.0), chart.point.from_index(adjustedOffset, y), xloc = xloc.bar_index, width = 1, color = color.new(color.orange, 65), style = line.style_dotted, extend = extend.none)

renderExitEntryTable(float riskMetric, float valuePercentage) =>
    tableSetCell(entryExitTable, 0, 0, "Risk",  chart.bg_color, color.blue,  size.tiny)
    tableSetCell(entryExitTable, 1, 0, "Exit",  chart.bg_color, color.red,   size.tiny)
    tableSetCell(entryExitTable, 2, 0, "Entry", chart.bg_color, color.green, size.tiny)
    float exitValue  = exitThresholdComparator  == ">=" ? (riskMetric >= exitThreshold  ? valuePercentage : 0.0) : (riskMetric >  exitThreshold  ? valuePercentage : 0.0)
    float entryValue = entryThresholdComparator == "<=" ? (riskMetric <= entryThreshold ? valuePercentage : 0.0) : (riskMetric <  entryThreshold ? valuePercentage : 0.0)
    tableSetCell(entryExitTable, 0, 1, str.format("{0,number,#.##}",  riskMetric * 100), chart.bg_color, color.white, size.small)
    tableSetCell(entryExitTable, 1, 1, str.format("{0,number,#.##}%", exitValue),        chart.bg_color, color.white, size.small)
    tableSetCell(entryExitTable, 2, 1, str.format("{0,number,#.##}%", entryValue),       chart.bg_color, color.white, size.small)


// ─── LOGIC & CALCS ─────────────────────────────────────────────────────────

// Native SMA calculation passed cleanly via request.security
float assetSMA           = request.security(syminfo.tickerid, resolvedTimeframe, expression = ta.sma(close, smaLen))
float scalingFactor      = math.pow(math.e, sfDecay * ((bar_index - adjustedOffset) * sfSensitivity)) + sfBaselineControl
float smoothedUpperbound = upperbound * assetSMA * scalingFactor
float smoothedLowerbound = lowerbound * assetSMA * (lowerboundIsDynamic ? scalingFactor : 1)

float riskMetric         = riskMetricFrom(close,    smoothedUpperbound, smoothedLowerbound)
float smoothedRiskMetric = riskMetricFrom(assetSMA, smoothedUpperbound, smoothedLowerbound)

float entryExit = weight(riskMetric, baseForWeight, exponentForWeight, cutoffForWeight)

var float markerYPos = 0.0
if bar_index == adjustedOffset
    markerYPos := smoothedRiskMetric * 100


// ─── PLOTS (0-100 display scale) ───────────────────────────────────────────

plot(series = riskMetric * 100,                                       title = "Relative Risk Metric", color = showColorway ? colorForRiskMetric(riskMetric)         : color.white, linewidth = 1, style = plot.style_circles)
plot(series = showSmoothedRiskMetric ? smoothedRiskMetric * 100 : na, title = "Smoothed Risk Metric", color = showColorway ? colorForRiskMetric(smoothedRiskMetric) : color.white, linewidth = 1, style = plot.style_line)
plot(entryExit,                                                       title = "Entry/Exit Percentage", color = colorForEntryExit(riskMetric), linewidth = 1, style = plot.style_cross)

// Threshold reference lines (0-100 scale)
hline(showThresholdLines ? exitThresholdPct  : na, "Exit Threshold",  color = color.new(color.red,   50), linestyle = hline.style_dashed)
hline(showThresholdLines ? entryThresholdPct : na, "Entry Threshold", color = color.new(color.green, 50), linestyle = hline.style_dashed)
hline(showMidline        ? 50.0              : na, "Midline 50",      color = color.new(color.gray,  70), linestyle = hline.style_dotted)

// Zone fills
exitTop    = hline(100.0,             "Exit Zone Top",    display = display.none)
exitFloor  = hline(exitThresholdPct,  "Exit Zone Floor",  display = display.none)
entryCeil  = hline(entryThresholdPct, "Entry Zone Ceil",  display = display.none)
entryFloor = hline(0.0,               "Entry Zone Floor", display = display.none)
fill(exitTop,   exitFloor,  color = showZoneFills ? color.new(color.red,   92) : na, title = "Exit Zone Fill")
fill(entryCeil, entryFloor, color = showZoneFills ? color.new(color.green, 92) : na, title = "Entry Zone Fill")


// ─── FINAL RENDER & ALERTS ─────────────────────────────────────────────────

if barstate.islast
    if showEntryExit
        renderExitEntryTable(riskMetric, entryExit)
    if showColorwayLegend
        renderColorwayLegend()
    renderTimeOffsetMarker(markerYPos)

alertcondition(isEntryTriggered(riskMetric) and not isEntryTriggered(riskMetric[1]), title = "Entry zone entered", message = "Risk metric crossed into entry/accumulation zone")
alertcondition(isExitTriggered(riskMetric)  and not isExitTriggered(riskMetric[1]),  title = "Exit zone entered",  message = "Risk metric crossed into exit/distribution zone")
````
