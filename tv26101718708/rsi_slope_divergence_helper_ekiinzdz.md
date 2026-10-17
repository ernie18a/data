# RSI Slope Divergence Helper

- url: https://www.tradingview.com/script/EKiINZDZ-RSI-Slope-Divergence-Helper/
- type: indicator
- pine_id: PUB;b586cc2e5489426cb844836058536f32
- version: 1.0

## Description

RSI Slope Divergence Helper compares the rolling slope of price with the rolling slope of RSI.

This is not a classic pivot-divergence detector. It does not wait for confirmed swing pivots. Instead, it compares rolling price behavior and rolling RSI behavior directly by converting both slopes into normalized, unitless values and displaying them in the same pane.

The purpose of this script is to help users observe when price slope and RSI slope are moving together, moving against each other, or moving with low slope. It is a context and visualization tool only. It does not provide trade-action instructions and it is not a trading system.

What it shows

- Normalized price slope.
- Normalized RSI slope.
- A spread histogram between the two normalized slopes.
- Neutral slope-relationship states.
- A compact dashboard.
- Optional factual markers.
- A neutral Divergence Footprint layer.

How the calculation works

The script first calculates RSI using the selected RSI source and RSI length.

For price, it estimates a rolling linear-regression slope by comparing the current linear-regression value with the prior linear-regression value. The price slope is expressed as a percentage of the prior fitted price value so it can be compared across different symbols and price levels.

For RSI, the script estimates a rolling linear-regression slope from RSI itself. Since RSI is already bounded from 0 to 100, its slope is measured in RSI points.

The two slope series have different units, so they are normalized separately:

- price slope is divided by its own rolling standard deviation
- RSI slope is divided by its own rolling standard deviation

This converts both slopes into comparable unitless values.

The displayed spread is:

normalized price slope - normalized RSI slope

A positive spread means the normalized price slope is above the normalized RSI slope. A negative spread means the normalized price slope is below the normalized RSI slope.

No request.security() is used. The script uses current chart bars only and does not use lookahead or future data.

Why it is different from classic RSI divergence scripts

Many RSI divergence scripts compare confirmed price pivots with confirmed RSI pivots. This script takes a different approach.

It focuses on rolling slope behavior:

- price slope
- RSI slope
- normalized slope spread
- duration of the current disagreement episode
- peak spread during the current episode
- spread motion
- phase gap

Because it is slope-based, it is intended as a visual helper for observing disagreement between price movement and RSI movement. It is not a reversal detector and it does not forecast future price behavior.

Divergence Footprint

The Divergence Footprint is a neutral context layer that describes the current slope-disagreement episode.

It can show:

- whether slope disagreement is active
- how many bars the current disagreement episode has persisted
- the peak absolute spread reached during the current episode
- whether the absolute spread is expanding, cooling, or holding
- the phase gap between normalized price slope and normalized RSI slope

The phase gap is calculated by applying an angle transform to each normalized slope and then comparing the two angles. It is descriptive only. It is not a probability, score, forecast, or confirmation tool.

Optional phase-gap and duration plots are off by default to keep the pane clean.

State model

The dashboard uses neutral state names:

- Warming up
- Aligned upward
- Aligned downward
- Upper disagreement
- Lower disagreement
- Flat / low slope
- Mixed slopes

Upper disagreement means price slope is positive while RSI slope is negative.

Lower disagreement means price slope is negative while RSI slope is positive.

These states describe the current relationship between the two slopes. They do not imply reversal or continuation.

Markers and alerts

Markers are optional and off by default.

The marker display mode can be set to:

- Off
- Disagreement only
- All events

When enabled, markers are small and factual:

- P+ R- means price slope is positive while RSI slope is negative.
- P- R+ means price slope is negative while RSI slope is positive.
- Align marks slope agreement returning after a prior slope-disagreement episode, when enabled.

Alerts use the same neutral event logic:

- Upper slope disagreement
- Lower slope disagreement
- Slope agreement restored
- Spread crossed above threshold
- Spread crossed below threshold

Alerts are confirmed on bar close by default. Intrabar mode is available, but realtime values can update until the bar closes.

Dashboard

The default dashboard is compact and auto-sized. It is designed to stay readable without covering the indicator pane.

Compact layout shows:

- State
- Price slope
- RSI slope
- Spread
- Footprint
- Event mode

Standard and Detailed layouts add more context, including RSI value, spread motion, phase gap, disagreement bars, episode peak spread, active warm-up bars, and bar status.

Visual customization

Users can adjust:

- table layout
- table position
- table text size
- header text size
- table colors
- row backgrounds
- state-row highlighting
- plot colors
- histogram transparency
- marker colors
- background tint
- fixed table sizing, when desired

By default, fixed table cell sizing is off, so the dashboard auto-sizes to its content. Markers and background tint are also off by default to keep the pane clean.

Visual settings do not affect the calculations.

Live behavior and robustness

The script includes:

- automatic warm-up floor
- guarded denominators
- minimum normalized slope threshold
- optional spread-threshold filter for events
- optional minimum persistence for disagreement events
- optional event cooldown
- confirmed-bar event handling by default
- realtime / confirmed bar status disclosure in the table

If there is not enough history, or if the normalization denominator is not usable, the script avoids producing misleading slope states and displays safe fallback text such as n/a or Warming up.

Limitations

This script is not financial advice and not a trading system.

Slope disagreement can persist.

Slope disagreement can disappear without a major price move.

Slope disagreement does not predict reversal or continuation.

RSI is a bounded oscillator and can remain extended while price continues moving.

Default settings are starting points, not optimized settings.

Normalization length, slope length, smoothing length, and thresholds affect sensitivity.

Japanese notes

価格の傾きとRSIの傾きを正規化して比較し、両者の乖離をスプレッドとDivergence Footprintで表示する補助ツールです。通常のピボット型RSIダイバージェンス検出ではありません。売買判断や将来の値動きを示すものではなく、状況把握のための可視化ツールです。既定ではCompact表示、マーカーと背景色はオフ、確定足イベント処理がオンです。

## Source Code

````pine
//@version=6
indicator(title = "RSI Slope Divergence Helper", shorttitle = "RSI Slope Div", overlay = false)

// ----------------------------------------------------------------------------
// 1. Calculation inputs
// ----------------------------------------------------------------------------
priceSource           = input.source(close, "Price source",                          group = "Calculation", display = display.none)
rsiSource             = input.source(close, "RSI source",                             group = "Calculation", display = display.none)
rsiLength             = input.int(14,  "RSI length",                       minval = 2, group = "Calculation", display = display.none)
slopeLength           = input.int(21,  "Slope length",                     minval = 2, group = "Calculation", display = display.none)
normalizationLength   = input.int(100, "Normalization length",             minval = 5, group = "Calculation", display = display.none)
smoothingLength       = input.int(3,   "Smoothing length (display)",       minval = 1, group = "Calculation", display = display.none)
minBars               = input.int(100, "Minimum bars before classification", minval = 0, group = "Calculation", display = display.none)
useAutoWarmup         = input.bool(true, "Use automatic warm-up floor", group = "Calculation", display = display.none, tooltip = "Raises the warm-up count to cover the RSI, slope, normalization, and smoothing lengths so classification does not begin too early.")

// ----------------------------------------------------------------------------
// 2. Threshold inputs
// ----------------------------------------------------------------------------
minSlopeMagnitude       = input.float(0.35, "Minimum normalized slope magnitude", minval = 0.0, step = 0.05, group = "Thresholds", display = display.none)
disagreementThreshold   = input.float(1.0,  "Disagreement threshold",             minval = 0.0, step = 0.05, group = "Thresholds", display = display.none)
spreadMotionThreshold   = input.float(0.05, "Spread motion threshold",            minval = 0.0, step = 0.01, group = "Thresholds", display = display.none, tooltip = "Minimum bar-to-bar change in absolute spread to read as Expanding or Cooling rather than Holding.")
disagreementEventFilter = input.string("Direction + spread threshold", "Disagreement event filter", options = ["Direction only", "Direction + spread threshold"], group = "Thresholds", display = display.none, tooltip = "Whether markers and alerts require the spread to reach the disagreement threshold, or just the directional disagreement.")

// ----------------------------------------------------------------------------
// 3. Events and live behavior inputs
// ----------------------------------------------------------------------------
markerMode                  = input.string("Off", "Marker display mode", options = ["Off", "Disagreement only", "All events"], group = "Events and live behavior", display = display.none, tooltip = "Off shows no markers (default, clean pane). Disagreement only shows the P+ R- / P- R+ markers. All events also shows the agreement-restored marker when it is enabled.")
showAlignMarker             = input.bool(false, "Show agreement-restored marker", group = "Events and live behavior", display = display.none)
confirmOnClose              = input.bool(true,  "Confirm events on bar close",    group = "Events and live behavior", display = display.none)
minDisagreementBarsForEvent = input.int(1, "Minimum disagreement bars for event", minval = 1, maxval = 20, group = "Events and live behavior", display = display.none, tooltip = "Consecutive qualified disagreement bars required before a marker or alert can fire.")
eventCooldownBars           = input.int(0, "Event cooldown bars",                 minval = 0, maxval = 50, group = "Events and live behavior", display = display.none, tooltip = "Bars to wait after an event before another marker or alert can fire. Does not affect the table state.")
showRealtimeStatus          = input.bool(true,  "Show realtime status in table",  group = "Events and live behavior", display = display.none)

// ----------------------------------------------------------------------------
// 4. Footprint inputs
// ----------------------------------------------------------------------------
showFootprintRows       = input.bool(true,  "Show footprint table rows", group = "Footprint", display = display.none)
showCompactFootprintRow = input.bool(true,  "Show compact footprint row", group = "Footprint", display = display.none, tooltip = "Shows the Footprint row when the Compact table layout is selected.")
showPhaseGap            = input.bool(false, "Show phase gap line",       group = "Footprint", display = display.none)
showEpisodeDuration     = input.bool(false, "Show episode duration plot", group = "Footprint", display = display.none)
phaseGapScaleDivisor    = input.float(45.0, "Phase gap scale divisor", minval = 1.0, step = 1.0, group = "Footprint", display = display.none, tooltip = "Divides the phase gap before plotting so it shares the slope pane without dominating the scale.")
phaseGapColor           = input.color(#9b7fd5, "Phase gap line color",     group = "Footprint", display = display.none)
durationColor           = input.color(#6b7280, "Disagreement bars color",  group = "Footprint", display = display.none)

// ----------------------------------------------------------------------------
// 5. Display inputs
// ----------------------------------------------------------------------------
showHelperLines     = input.bool(true,  "Show helper lines",     group = "Display", display = display.none)
showSpreadHist      = input.bool(true,  "Show spread histogram", group = "Display", display = display.none)
showBgTint          = input.bool(false, "Show background tint",  group = "Display", display = display.none)
showThresholdGuides = input.bool(true,  "Show threshold guides", group = "Display", display = display.none)

// ----------------------------------------------------------------------------
// 6. Dashboard readability inputs
// ----------------------------------------------------------------------------
showTable           = input.bool(true, "Show dashboard table", group = "Dashboard readability", display = display.none)
tableLayout         = input.string("Compact", "Table layout", options = ["Compact", "Standard", "Detailed"], group = "Dashboard readability", display = display.none)
tablePosInput       = input.string("Top right", "Table position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = "Dashboard readability", display = display.none)
txtSizeInput        = input.string("Normal", "Dashboard text size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard readability", display = display.none, tooltip = "Controls the text size used in the dashboard table.")
headerSizeInput     = input.string("Normal", "Header text size",    options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard readability", display = display.none, tooltip = "Controls the text size used in the dashboard header row.")
useFixedTableSizing = input.bool(false, "Use fixed table cell sizing", group = "Dashboard readability", display = display.none, tooltip = "When enabled, the label/value column width and row height inputs are applied. When disabled, the dashboard uses automatic sizing.")
labelColWidth       = input.int(0, "Label column width", minval = 0, maxval = 100, group = "Dashboard readability", display = display.none, tooltip = "Optional relative table width, only used with fixed sizing. Use 0 for automatic sizing.")
valueColWidth       = input.int(0, "Value column width", minval = 0, maxval = 100, group = "Dashboard readability", display = display.none, tooltip = "Optional relative table width, only used with fixed sizing. Use 0 for automatic sizing.")
rowHeight           = input.int(0, "Row height",        minval = 0, maxval = 20,  group = "Dashboard readability", display = display.none, tooltip = "Optional row height, only used with fixed sizing. Use 0 for automatic sizing.")
headerRowHeight     = input.int(0, "Header row height", minval = 0, maxval = 20,  group = "Dashboard readability", display = display.none, tooltip = "Optional header row height, only used with fixed sizing. Use 0 for automatic sizing.")
tableFrameWidth     = input.int(1, "Table frame width",  minval = 0, maxval = 5, group = "Dashboard readability", display = display.none)
tableBorderWidth    = input.int(1, "Table border width", minval = 0, maxval = 5, group = "Dashboard readability", display = display.none)
useAltRowBg         = input.bool(true, "Use alternating row background", group = "Dashboard readability", display = display.none, tooltip = "Adds subtle alternating row backgrounds to improve readability.")
highlightStateRow   = input.bool(true, "Highlight current state row",  group = "Dashboard readability", display = display.none, tooltip = "Highlights the current state row for easier scanning.")
showBarStatusCompact = input.bool(false, "Show bar status in compact layout", group = "Dashboard readability", display = display.none, tooltip = "Adds the Bar status row to the Compact layout. Off by default to keep Compact short.")

// ----------------------------------------------------------------------------
// 7. Visual customization inputs
// ----------------------------------------------------------------------------
priceColor       = input.color(#5b9cf6, "Price slope line color",   group = "Visual customization", display = display.none)
rsiColor         = input.color(#e0883c, "RSI slope line color",     group = "Visual customization", display = display.none)
spreadColor      = input.color(#4db6ac, "Spread color",             group = "Visual customization", display = display.none)
upperTintColor   = input.color(#d98880, "Upper disagreement color", group = "Visual customization", display = display.none)
lowerTintColor   = input.color(#7fb3d5, "Lower disagreement color", group = "Visual customization", display = display.none)
zeroColor        = input.color(#787b86, "Zero line color",          group = "Visual customization", display = display.none)
thresholdColor   = input.color(#5d606b, "Threshold line color",     group = "Visual customization", display = display.none)
markerColor      = input.color(#b2b5be, "Marker color",             group = "Visual customization", display = display.none)
markerTextColor  = input.color(#d1d4dc, "Marker text color",        group = "Visual customization", display = display.none)
headerBg         = input.color(#2a2e39, "Table header background",        group = "Visual customization", display = display.none)
cellBg           = input.color(#1e222d, "Table cell background",          group = "Visual customization", display = display.none)
altRowBg         = input.color(#232733, "Table alternate row background", group = "Visual customization", display = display.none)
stateBg          = input.color(#33384a, "Table state highlight background", group = "Visual customization", display = display.none)
tableTextColor   = input.color(#d1d4dc, "Table text color",         group = "Visual customization", display = display.none)
stateTextColor   = input.color(#ffffff, "Table state text color",   group = "Visual customization", display = display.none)
headerTextColor  = input.color(#d1d4dc, "Table header text color",  group = "Visual customization", display = display.none)
tableBorderColor = input.color(#3a3e4a, "Table border color",       group = "Visual customization", display = display.none)
tableFrameColor  = input.color(#3a3e4a, "Table frame color",        group = "Visual customization", display = display.none)
histTransp       = input.int(50, "Histogram transparency",          minval = 0, maxval = 100, group = "Visual customization", display = display.none)
bgTransp         = input.int(90, "Background tint transparency",     minval = 0, maxval = 100, group = "Visual customization", display = display.none)
markerTransp     = input.int(0,  "Marker transparency",             minval = 0, maxval = 100, group = "Visual customization", display = display.none)
headerBgTransp   = input.int(0,  "Header background transparency",  minval = 0, maxval = 100, group = "Visual customization", display = display.none)
cellBgTransp     = input.int(0,  "Cell background transparency",    minval = 0, maxval = 100, group = "Visual customization", display = display.none)
altRowTransp     = input.int(0,  "Alternate row transparency",      minval = 0, maxval = 100, group = "Visual customization", display = display.none)
stateBgTransp    = input.int(0,  "State highlight transparency",    minval = 0, maxval = 100, group = "Visual customization", display = display.none)

// ----------------------------------------------------------------------------
// Derived colors and effective table sizing (built from inputs)
// ----------------------------------------------------------------------------
color headerBgFinal = color.new(headerBg, headerBgTransp)
color cellBgFinal   = color.new(cellBg,   cellBgTransp)
color altRowBgFinal = color.new(altRowBg, altRowTransp)
color stateBgFinal  = color.new(stateBg,  stateBgTransp)

// Effective cell sizing. With fixed sizing off (default), these are unused and
// table cells are written without width/height so the table auto-sizes to its
// content and never spans the full pane. A width/height of 0 also means auto.
int effLabelW  = useFixedTableSizing ? labelColWidth   : 0
int effValueW  = useFixedTableSizing ? valueColWidth   : 0
int effRowH    = useFixedTableSizing ? rowHeight       : 0
int effHeaderH = useFixedTableSizing ? headerRowHeight : 0

// ----------------------------------------------------------------------------
// Helper functions
// ----------------------------------------------------------------------------
// Map the table-position string to a Pine position constant.
f_tablePos(string s) =>
    switch s
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Top right"     => position.top_right
        "Middle left"   => position.middle_left
        "Middle center" => position.middle_center
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        "Bottom right"  => position.bottom_right
        => position.top_right

// Map the text-size string to a Pine size constant. Fallback is size.normal.
f_txtSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

// Format a value with two decimals, or "n/a" when undefined.
f_num(float x) =>
    na(x) ? "n/a" : str.tostring(x, "0.00")

// Format a signed value with an explicit leading +/-, or "n/a" when undefined.
f_sig(float x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, "0.00")

// Format an integer count, or "n/a" when undefined.
f_intOrNa(float x) =>
    na(x) ? "n/a" : str.tostring(int(x))

// Format a signed angle in degrees, or "n/a" when undefined.
f_deg(float x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, "0.0") + "°"

// Event-mode text.
f_modeText(bool confirmMode) =>
    confirmMode ? "Confirmed close" : "Intrabar allowed"

// Current bar status text.
f_barStatus() =>
    barstate.isconfirmed ? "Confirmed" : "Realtime"

// Write a label/value pair into one table row. By default (fixed sizing off)
// the cells are written WITHOUT width/height so the table auto-sizes. Reads
// dashboard-readability globals; returns a value so it can be a statement.
f_row(table tbl, int row, string label, string value, color txt, color bg, string sz, bool highlight) =>
    bool  useAlt = useAltRowBg and (row % 2 == 0)
    color rowBg  = highlight ? stateBgFinal : (useAlt ? altRowBgFinal : bg)
    color cTxt   = highlight ? stateTextColor : txt
    if useFixedTableSizing
        table.cell(tbl, 0, row, label, text_color = cTxt, bgcolor = rowBg, text_size = sz, text_halign = text.align_left,  width = effLabelW, height = effRowH)
        table.cell(tbl, 1, row, value, text_color = cTxt, bgcolor = rowBg, text_size = sz, text_halign = text.align_right, width = effValueW, height = effRowH)
    else
        table.cell(tbl, 0, row, label, text_color = cTxt, bgcolor = rowBg, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 1, row, value, text_color = cTxt, bgcolor = rowBg, text_size = sz, text_halign = text.align_right)
    true

// Write the two-cell header row, auto-sized by default.
f_header(table tbl, string sz) =>
    if useFixedTableSizing
        table.cell(tbl, 0, 0, "RSI Slope", text_color = headerTextColor, bgcolor = headerBgFinal, text_size = sz, text_halign = text.align_left,  width = effLabelW, height = effHeaderH)
        table.cell(tbl, 1, 0, "Helper",    text_color = headerTextColor, bgcolor = headerBgFinal, text_size = sz, text_halign = text.align_right, width = effValueW, height = effHeaderH)
    else
        table.cell(tbl, 0, 0, "RSI Slope", text_color = headerTextColor, bgcolor = headerBgFinal, text_size = sz, text_halign = text.align_left)
        table.cell(tbl, 1, 0, "Helper",    text_color = headerTextColor, bgcolor = headerBgFinal, text_size = sz, text_halign = text.align_right)
    true

// ----------------------------------------------------------------------------
// Core calculations
// ----------------------------------------------------------------------------
float tiny = 1e-10

// Price slope.
// ta.linreg(src, len, offset) returns the value of the linear-regression line
// at the requested offset. The difference between offset 0 and offset 1 equals
// the per-bar slope of that regression line. Expressing it as a percent of the
// previous fitted value yields a scale-independent price slope (no ATR used).
float priceFitNow   = ta.linreg(priceSource, slopeLength, 0)
float priceFitPrev  = ta.linreg(priceSource, slopeLength, 1)
bool  priceDenomOk  = not na(priceFitPrev) and math.abs(priceFitPrev) > tiny
float priceSlopePct = priceDenomOk ? 100.0 * (priceFitNow - priceFitPrev) / math.abs(priceFitPrev) : na

// RSI slope.
// RSI is already bounded 0..100, so its slope is taken directly in RSI points.
float rsi         = ta.rsi(rsiSource, rsiLength)
float rsiFitNow   = ta.linreg(rsi, slopeLength, 0)
float rsiFitPrev  = ta.linreg(rsi, slopeLength, 1)
float rsiSlopePts = (not na(rsiFitNow) and not na(rsiFitPrev)) ? rsiFitNow - rsiFitPrev : na

// Normalization.
// Each slope series is divided by its own rolling standard deviation, so the
// two different units (percent vs RSI points) become comparable unitless
// lines. Denominators are guarded against na and near-zero values.
float priceSlopeDenom   = ta.stdev(priceSlopePct, normalizationLength)
float rsiSlopeDenom     = ta.stdev(rsiSlopePts,   normalizationLength)
float normPriceSlopeRaw = (not na(priceSlopeDenom) and priceSlopeDenom > tiny) ? priceSlopePct / priceSlopeDenom : na
float normRsiSlopeRaw   = (not na(rsiSlopeDenom)   and rsiSlopeDenom   > tiny) ? rsiSlopePts  / rsiSlopeDenom   : na

// Optional display smoothing. smoothingLength has minval 1, so it is a safe
// simple int length for ta.ema. ta.ema is evaluated every bar for stable state.
float normPriceSlopeEma = ta.ema(normPriceSlopeRaw, smoothingLength)
float normRsiSlopeEma   = ta.ema(normRsiSlopeRaw,   smoothingLength)
float normPriceSlope    = smoothingLength > 1 ? normPriceSlopeEma : normPriceSlopeRaw
float normRsiSlope      = smoothingLength > 1 ? normRsiSlopeEma   : normRsiSlopeRaw

// Spread between the two normalized slopes.
float slopeSpread = (not na(normPriceSlope) and not na(normRsiSlope)) ? normPriceSlope - normRsiSlope : na
float absSpread   = na(slopeSpread) ? na : math.abs(slopeSpread)

// Warm-up floor. The automatic floor covers the lengths that must fill before
// the normalized slopes are meaningful, so classification cannot begin too
// early when Minimum bars is set low. This is stability handling, not tuning.
int derivedWarmup = rsiLength + slopeLength + normalizationLength + smoothingLength
int activeMinBars = useAutoWarmup ? math.max(minBars, derivedWarmup) : minBars

// ----------------------------------------------------------------------------
// State classification (sign + magnitude based, neutral wording only)
// ----------------------------------------------------------------------------
bool enoughHistory = bar_index >= activeMinBars and not na(normPriceSlope) and not na(normRsiSlope) and not na(slopeSpread)

bool priceUp   = enoughHistory and normPriceSlope >  minSlopeMagnitude
bool priceDown = enoughHistory and normPriceSlope < -minSlopeMagnitude
bool rsiUp     = enoughHistory and normRsiSlope   >  minSlopeMagnitude
bool rsiDown   = enoughHistory and normRsiSlope   < -minSlopeMagnitude

bool upperDisagreement = priceUp   and rsiDown   // price slope up while RSI slope down
bool lowerDisagreement = priceDown and rsiUp     // price slope down while RSI slope up
bool alignedUp         = priceUp   and rsiUp
bool alignedDown       = priceDown and rsiDown
bool alignedState      = alignedUp or alignedDown
bool flatOrLow         = enoughHistory and math.abs(normPriceSlope) <= minSlopeMagnitude and math.abs(normRsiSlope) <= minSlopeMagnitude

string state = not enoughHistory     ? "Warming up"          : upperDisagreement   ? "Upper disagreement"  : lowerDisagreement   ? "Lower disagreement"  : alignedUp           ? "Aligned upward"     : alignedDown         ? "Aligned downward"   : flatOrLow           ? "Flat / low slope"   : "Mixed slopes"

// Strength-aware "active" disagreement also requires the spread magnitude to
// reach the disagreement threshold. Used for the tint only.
bool upperActive = upperDisagreement and not na(absSpread) and absSpread >= disagreementThreshold
bool lowerActive = lowerDisagreement and not na(absSpread) and absSpread >= disagreementThreshold

// ----------------------------------------------------------------------------
// Event qualification and persistence
// ----------------------------------------------------------------------------
// Markers and alerts can optionally require the spread to reach the threshold,
// while the state model above stays purely directional.
bool eventFilterOk = disagreementEventFilter == "Direction only" ? true : (not na(absSpread) and absSpread >= disagreementThreshold)
bool upperQualified = upperDisagreement and eventFilterOk
bool lowerQualified = lowerDisagreement and eventFilterOk

// Count consecutive qualified disagreement bars for persistence filtering.
var int upperQualifiedBars = 0
var int lowerQualifiedBars = 0
upperQualifiedBars := upperQualified ? upperQualifiedBars + 1 : 0
lowerQualifiedBars := lowerQualified ? lowerQualifiedBars + 1 : 0

bool upperEventReady = enoughHistory and enoughHistory[1] and upperQualifiedBars >= minDisagreementBarsForEvent and upperQualifiedBars[1] < minDisagreementBarsForEvent
bool lowerEventReady = enoughHistory and enoughHistory[1] and lowerQualifiedBars >= minDisagreementBarsForEvent and lowerQualifiedBars[1] < minDisagreementBarsForEvent

// ----------------------------------------------------------------------------
// Divergence Footprint (descriptive context only, no prediction)
// ----------------------------------------------------------------------------
bool disagreementCore     = upperDisagreement or lowerDisagreement
bool qualifiedDisagreement = upperQualified or lowerQualified

// Episode latch: a qualified disagreement episode must occur before "agreement
// restored" can fire.
var bool hadDisagreementEpisode = false
if not enoughHistory
    hadDisagreementEpisode := false
if qualifiedDisagreement
    hadDisagreementEpisode := true
// restoredNow only detects the directional transition; the latch is consumed
// later, when the Align event actually fires (so cooldown/gating cannot silently
// drop a restoration).
bool restoredNow = enoughHistory and enoughHistory[1] and hadDisagreementEpisode[1] and alignedState and not alignedState[1]

// Episode duration and peak absolute spread within the current directional
// disagreement episode.
var int   disagreementBars     = 0
var float episodePeakAbsSpread = na
if not enoughHistory or not disagreementCore
    disagreementBars     := 0
    episodePeakAbsSpread := na
else
    disagreementBars     += 1
    episodePeakAbsSpread := na(episodePeakAbsSpread) ? absSpread : math.max(episodePeakAbsSpread, absSpread)

// Spread motion: how the absolute spread is changing bar to bar.
float absSpreadDelta = (enoughHistory and not na(absSpread) and not na(absSpread[1])) ? absSpread - absSpread[1] : na
string spreadMotion = (not enoughHistory or na(absSpreadDelta)) ? "n/a" : absSpreadDelta > spreadMotionThreshold ? "Expanding" : absSpreadDelta < -spreadMotionThreshold ? "Cooling" : "Holding"

// Phase gap: angle-transformed comparison of the two normalized slopes. The
// arctangent bounds each slope to a readable degree range before subtracting.
float priceAngleDeg = not na(normPriceSlope) ? math.atan(normPriceSlope) * 180.0 / math.pi : na
float rsiAngleDeg   = not na(normRsiSlope)   ? math.atan(normRsiSlope)   * 180.0 / math.pi : na
float phaseGapDeg   = (not na(priceAngleDeg) and not na(rsiAngleDeg)) ? priceAngleDeg - rsiAngleDeg : na

// Footprint state text. Describes the spread only, never future price.
string footprintState = not enoughHistory ? "Warming up" : not disagreementCore ? "No active disagreement" : disagreementBars <= 2 ? "Forming" : spreadMotion == "Expanding" ? "Expanding" : spreadMotion == "Cooling" ? "Cooling" : "Holding"

// ----------------------------------------------------------------------------
// Events (persistence-filtered, optional cooldown, confirmed-bar gating)
// ----------------------------------------------------------------------------
bool gate = confirmOnClose ? barstate.isconfirmed : true

bool upperCand     = upperEventReady and gate
bool lowerCand     = lowerEventReady and gate
bool alignCand     = restoredNow and gate
bool spreadUpCand  = enoughHistory and ta.crossover(slopeSpread, disagreementThreshold)   and gate
bool spreadDnCand  = enoughHistory and ta.crossunder(slopeSpread, -disagreementThreshold) and gate

// Cooldown counter. Read before decrementing each bar; an event re-arms it to
// block the next N bars. Only markers and alerts are affected; the table state
// is never suppressed.
var int eventCooldown = 0
bool canFire = eventCooldown == 0
eventCooldown := math.max(eventCooldown - 1, 0)

// Priority when several candidates land on one bar: disagreement onset, then
// agreement restored, then spread-threshold crosses.
bool upperEvent      = upperCand and canFire
bool lowerEvent      = lowerCand and canFire and not upperEvent
bool alignEvent      = alignCand and canFire and not upperEvent and not lowerEvent
// Consume the disagreement-episode latch once a gated restoration transition is
// observed. Cooldown may suppress the marker or alert, but it should not leave a
// stale prior episode.
if alignCand
    hadDisagreementEpisode := false
bool spreadCrossUp   = spreadUpCand and canFire and not upperEvent and not lowerEvent and not alignEvent
bool spreadCrossDown = spreadDnCand and canFire and not upperEvent and not lowerEvent and not alignEvent and not spreadCrossUp

bool anyEvent = upperEvent or lowerEvent or alignEvent or spreadCrossUp or spreadCrossDown
if anyEvent and eventCooldownBars > 0
    eventCooldown := eventCooldownBars

// Marker visibility (default Off keeps the pane clean).
bool showDisagMarkers   = markerMode == "Disagreement only" or markerMode == "All events"
bool showAlignMarkerEff = markerMode == "All events" and showAlignMarker

// ----------------------------------------------------------------------------
// Plots
// ----------------------------------------------------------------------------
plot(showHelperLines ? normPriceSlope : na, title = "Normalized price slope", color = priceColor, linewidth = 2)
plot(showHelperLines ? normRsiSlope   : na, title = "Normalized RSI slope",   color = rsiColor,   linewidth = 2)
plot(showSpreadHist  ? slopeSpread    : na, title = "Slope spread",           color = color.new(spreadColor, histTransp), style = plot.style_columns)

// Zero line (constant) plus plot-based threshold guides (avoids dynamic hline).
hline(0.0, title = "Zero", color = zeroColor, linestyle = hline.style_dotted)
plot(showThresholdGuides ?  disagreementThreshold : na, title = "Upper threshold", color = thresholdColor, style = plot.style_linebr)
plot(showThresholdGuides ? -disagreementThreshold : na, title = "Lower threshold", color = thresholdColor, style = plot.style_linebr)

// Optional footprint plots, off by default to keep the pane clean.
float phaseGapDivSafe = phaseGapScaleDivisor >= 1.0 ? phaseGapScaleDivisor : 45.0
plot(showPhaseGap        ? phaseGapDeg / phaseGapDivSafe : na, title = "Phase gap (scaled)", color = phaseGapColor, linewidth = 1)
plot(showEpisodeDuration ? disagreementBars : na, title = "Disagreement bars", color = color.new(durationColor, 60), style = plot.style_columns)

// Background tint when a disagreement is active (off by default).
color tintColor = upperActive ? color.new(upperTintColor, bgTransp) : lowerActive ? color.new(lowerTintColor, bgTransp) : na
bgcolor(showBgTint ? tintColor : na, title = "Disagreement tint")

// Markers are plotted globally; visibility is controlled by the series value so
// no objects accumulate. ASCII-neutral text, no arrow glyphs. Off by default.
plotshape(showDisagMarkers and upperEvent ? 1 : na, title = "Price slope positive / RSI slope negative", style = shape.circle, location = location.top,    color = color.new(markerColor, markerTransp), text = "P+ R-", textcolor = markerTextColor, size = size.tiny)
plotshape(showDisagMarkers and lowerEvent ? 1 : na, title = "Price slope negative / RSI slope positive", style = shape.circle, location = location.bottom, color = color.new(markerColor, markerTransp), text = "P- R+", textcolor = markerTextColor, size = size.tiny)
plotshape(showAlignMarkerEff and alignEvent ? 1 : na, title = "Slope agreement restored", style = shape.cross, location = location.top, color = color.new(color.gray, markerTransp), text = "Align", textcolor = markerTextColor, size = size.tiny)

// ----------------------------------------------------------------------------
// Alerts (factual, neutral wording only)
// ----------------------------------------------------------------------------
alertcondition(upperEvent,      title = "Upper slope disagreement",       message = "Price slope is positive while RSI slope is negative.")
alertcondition(lowerEvent,      title = "Lower slope disagreement",       message = "Price slope is negative while RSI slope is positive.")
alertcondition(alignEvent,      title = "Slope agreement restored",       message = "Price and RSI slopes returned to the same direction after a slope-disagreement episode.")
alertcondition(spreadCrossUp,   title = "Spread crossed above threshold", message = "The slope spread crossed above the positive threshold.")
alertcondition(spreadCrossDown, title = "Spread crossed below threshold", message = "The slope spread crossed below the negative threshold.")

// ----------------------------------------------------------------------------
// Context table (informational only, fixed dimensions, auto-sized by default)
// ----------------------------------------------------------------------------
var table t = table.new(position = f_tablePos(tablePosInput), columns = 2, rows = 15, bgcolor = na, frame_color = tableFrameColor, frame_width = tableFrameWidth, border_color = tableBorderColor, border_width = tableBorderWidth)

// Clear stale cells if the table is turned off.
if not showTable and barstate.islast
    table.clear(t, 0, 0, 1, 14)

if showTable and barstate.islast
    string tsz = f_txtSize(txtSizeInput)
    string hsz = f_txtSize(headerSizeInput)
    table.clear(t, 0, 0, 1, 14)
    f_header(t, hsz)

    bool isCompact  = tableLayout == "Compact"
    bool isDetailed = tableLayout == "Detailed"
    bool showFpHere = isCompact ? showCompactFootprintRow : showFootprintRows
    bool showBarRow = showRealtimeStatus and (not isCompact or showBarStatusCompact)

    int rr = 1
    f_row(t, rr, "State",       state,                 tableTextColor, cellBgFinal, tsz, highlightStateRow)
    rr += 1
    f_row(t, rr, "Price slope", f_sig(normPriceSlope), tableTextColor, cellBgFinal, tsz, false)
    rr += 1
    f_row(t, rr, "RSI slope",   f_sig(normRsiSlope),   tableTextColor, cellBgFinal, tsz, false)
    rr += 1
    f_row(t, rr, "Spread",      f_sig(slopeSpread),    tableTextColor, cellBgFinal, tsz, false)
    rr += 1
    if not isCompact
        f_row(t, rr, "RSI value", f_num(rsi), tableTextColor, cellBgFinal, tsz, false)
        rr += 1
    if showFpHere
        f_row(t, rr, "Footprint", footprintState, tableTextColor, cellBgFinal, tsz, false)
        rr += 1
    if not isCompact and showFootprintRows
        f_row(t, rr, "Spread motion", spreadMotion, tableTextColor, cellBgFinal, tsz, false)
        rr += 1
    if isDetailed and showFootprintRows
        f_row(t, rr, "Disagreement bars", f_intOrNa(enoughHistory ? disagreementBars : na), tableTextColor, cellBgFinal, tsz, false)
        rr += 1
        f_row(t, rr, "Episode peak spread", f_num(episodePeakAbsSpread), tableTextColor, cellBgFinal, tsz, false)
        rr += 1
    if not isCompact and showFootprintRows
        f_row(t, rr, "Phase gap", f_deg(phaseGapDeg), tableTextColor, cellBgFinal, tsz, false)
        rr += 1
    if isDetailed
        f_row(t, rr, "Active warm-up bars", f_intOrNa(activeMinBars), tableTextColor, cellBgFinal, tsz, false)
        rr += 1
    f_row(t, rr, "Event mode", f_modeText(confirmOnClose), tableTextColor, cellBgFinal, tsz, false)
    rr += 1
    if showBarRow
        f_row(t, rr, "Bar status", f_barStatus(), tableTextColor, cellBgFinal, tsz, false)
        rr += 1
````
