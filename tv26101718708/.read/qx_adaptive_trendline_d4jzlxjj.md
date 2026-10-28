# QX Adaptive Trendline

- url: https://www.tradingview.com/script/d4jzLXJJ-QX-Adaptive-Trendline/
- type: indicator
- pine_id: PUB;41b64630aa4b47e1b8fcf9f42505e959
- version: 1.0

## Description

QX Adaptive Trendline

## Short description

Confirmed-pivot support and resistance trendlines with adaptive strength styling, break handling, and active-line alerts.

 Full TradingView description

Overview

QX Adaptive Trendline detects rising support and falling resistance from confirmed swing pivots. It filters and ranks pivot-to-pivot candidates using configurable slope, candle-intersection, touch, and break rules, then displays primary and secondary trendlines with adaptive strength styling. Optional higher-timeframe lines and alerts help you monitor active or strong trendline structures.

Pivot confirmation introduces a delay, and the strength display is a visual heuristic—not a probability or guarantee. QX is an analysis and alerting indicator; it does not generate trade entries or exits, manage positions, or provide price targets.

### How the trendlines are calculated

1. **Confirm swing points.** Pivot highs and lows are detected using the selected left and right pivot strengths. A pivot is only available after the required right-side bars have closed, so a new line can appear several bars after its anchor formed.
2. **Build candidate lines.** Rising pairs of pivot lows are tested as support; falling pairs of pivot highs are tested as resistance.
3. **Filter candidates.** Lines must meet the minimum bar length and selected slope range. The script also checks candle bodies between the anchors against the configured ATR tolerance and body-cut allowance.
4. **Measure contacts.** Confirmed pivots near a projected line count as touches when they meet the touch tolerance and spacing rules.
5. **Rank and display.** Candidates are ranked using touch count, last-touch recency, and line span. The best and second-best eligible lines are displayed for each direction when enabled.
6. **Handle breaks.** By default, a line is removed from the active set after a confirmed wrong-side break beyond the configured buffer. You can instead keep it visible until price reclaims its original side.

### Adaptive visual strength

Support uses cyan and resistance uses purple. Each line's opacity is based on a QX strength estimate that considers additional pivot contacts, contact precision, candle-body path cleanliness, recency, rejection, and line maturity. This score is separate from the candidate ranking score.

- Stronger lines remain more vivid and can receive a wider matching-color glow.
- Weak primary lines become faint and dashed. Lines at or below the weak-strength threshold also receive a faint dashed yellow halo.
- Second-best lines are always faint and dashed, with a subtle yellow pulse to distinguish them from the primary structure.
- The yellow halo pulses on live charts as new market ticks cause the script to recalculate. Historical bars show a static faint halo.

These visual treatments describe the indicator's own heuristic estimate. They are not probabilities, forecasts, or guarantees that a line will hold. The strength estimate and visual effects do not change which candidate lines are selected or trigger alerts.

### Main settings

- **Scan Lookback Bars:** How far back to search for pivots and candidate anchors; default 500.
- **Pivot Strength Left / Right:** Bars required on either side to confirm a swing; defaults 3 / 3.
- **Slope Calculation Mode:** ATR-relative or absolute slope filtering. The default ATR-relative range is 0.015 to 0.5.
- **Minimum Line Length:** Minimum distance between anchor pivots; default 16 bars.
- **Body Intersection Tolerance / Allowed Body Cuts:** Controls how many candle-body violations are accepted between anchors. The default tolerance is 0.015 × ATR, with three allowed cuts.
- **Touch Tolerance:** Distance from a projected line at which a confirmed pivot can count as a contact; default 0.08 × ATR.
- **Broken-Line Handling:** Invalidate on a confirmed break, or show the line until price reclaims its original side.
- **Break Buffer / Minimum Break Size:** A break must exceed the greater of the ATR-based buffer and the minimum tick distance. Defaults are 0.02 × ATR and 10 ticks.
- **Break/Reclaim Basis:** Close, mid-body, or candle body edge.
- **Adaptive Strength Transparency:** Sets the opacity range for weak and strong lines; enabled by default, from 12 transparency for the strongest line to 88 for the weakest.
- **Glow Strength Threshold:** Minimum estimated strength for the matching-color glow; default 65/100.
- **Weak-Line Threshold:** Maximum estimated strength for the yellow halo; default 45/100.
- **Weak / Secondary Line Transparency:** Minimum transparency applied to weak primary and second-best lines; default 74/100.
- **Strong Trendline Alert Threshold:** Minimum QX strength score for the strong-line alerts; default 65/100. A line must also exceed the weak-line threshold. Only primary lines qualify.
- **Show Active Trendlines / Show 2nd Best Lines:** Controls the primary and secondary displayed candidates.

### Higher-timeframe trendlines

Enable **HTF Trendlines** to calculate an independent primary support and resistance line from a higher timeframe, such as 1-hour lines on a 1-minute chart. The default HTF is 1 hour. The selected timeframe must be strictly higher than the chart timeframe; otherwise the overlay stays inactive.

The HTF engine uses confirmed HTF candles and its own pivot, OHLC, ATR, touch, body-path, slope, ranking, and break history. It applies the same configurable rules as the chart-timeframe engine, with bar-based measurements made in HTF bars. HTF lines are drawn separately as dashed, translucent red resistance and green support with a soft color-matched glow. HTF lines do not change chart-timeframe candidate selection. HTF active states, projected levels, touch counts, strengths, and anchors are exposed in the Data Window.

Pivots are confirmed only after the configured right-side HTF bars close, so HTF lines can appear later than the pivot candle that forms their anchor. This confirmation delay avoids using an unfinished HTF candle in line selection.

### Alerts and scanning

Choose one of the alert frequencies:

- **Every bar close while active:** Sends a notification at each confirmed bar close while the selected line is active.
- **On line activation/change:** Sends a notification when a primary chart-timeframe or HTF line's anchor pair changes.

Alert messages identify the chart symbol and timeframe and include the active direction, projected line level, touch count, and QX strength estimate. Dynamic `alert()` messages also include the selected HTF timeframe and any active HTF lines. Create an alert using **Any alert() function call** for the dynamic message, or select one of the bullish, bearish, HTF bullish, HTF bearish, or any-line alert conditions. The HTF alert conditions direct you to the indicator inputs for the selected HTF value.

For a repeating alert that excludes weak and second-best lines, select **Strong trendline active (bullish or bearish)**. This condition is true at each confirmed chart-bar close while a primary chart-timeframe or enabled HTF line is active at or above the strong threshold and above the weak threshold. Set the alert frequency to **Once Per Bar Close**. Direction-specific strong bullish and strong bearish conditions are also available. The strong alert conditions can be added to TradingView multi-condition alerts alongside other supported conditions on the same symbol; all selected conditions must be true for the combined alert to fire. Multi-condition alerts do not use the script's `alert()` calls. [TradingView multi-condition alerts](https://www.tradingview.com/support/solutions/43000761492-multi-condition-alerts/)

The Data Window also exposes active-line state, projected price, touch count, strength, and anchor information for side-by-side chart review.

The script calculates the symbol on the chart where it is running; one instance does not continuously scan every symbol in a watchlist. Its active-state plots can be used with TradingView's Pine Screener to find symbols with a current bullish or bearish line.

### Timeframes

QX Adaptive Trendline works on the chart's selected timeframe, including 1-hour and 4-hour charts. On those charts, pivot strengths, minimum line length, lookback, and other bar-based settings are measured in 1-hour or 4-hour bars.

The HTF overlay is optional and disabled by default. On a 1-minute chart, enable it and select 1 hour or 4 hours to draw independently calculated higher-timeframe trendlines.

### Important notes

- Confirmed-pivot detection introduces an expected delay equal to the right-side pivot strength.
- New confirmed pivots can change which candidates rank first or second as the chart develops.
- HTF trendlines require the selected HTF to be higher than the chart timeframe and use confirmed HTF bars, adding the expected right-pivot confirmation delay.
- Touch, slope, body-cut, break-buffer, ranking, and strength calculations are configurable QX rules; they are not a guarantee of future support or resistance.
- This indicator is a chart-analysis and alerting tool, not investment advice. Always verify the chart context and manage risk independently.

## Source Code

````pine
//@version=6
indicator("QX Adaptive Trendline", overlay = true, max_lines_count = 20, max_bars_back = 5000)

// QX Adaptive Trendline independently reconstructs the disclosed core of
// TradeAxis Trendlines: confirmed pivots, filtered pivot-to-pivot candidates,
// touch scoring, and active-line alerts. The original source is invite-only.

// ── Trendline detection ─────────────────────────────────────────────────────
int scanBars       = input.int(500, "Scan Lookback Bars", minval = 50, maxval = 2000, group = "Trendline Detection")
int pivotLeft      = input.int(3, "Pivot Strength Left", minval = 1, maxval = 20, group = "Trendline Detection")
int pivotRight     = input.int(3, "Pivot Strength Right", minval = 1, maxval = 20, group = "Trendline Detection")
int minLineBars    = input.int(16, "Min Line Length (Bars)", minval = 2, maxval = 1000, group = "Line Filters")
string slopeMode   = input.string("ATR Relative", "Slope Calculation Mode", options = ["ATR Relative", "Absolute"], group = "Line Filters")
float minSlope     = input.float(0.015, "Min Slope", minval = 0.0, step = 0.005, group = "Line Filters")
float maxSlope     = input.float(0.5, "Max Slope", minval = 0.001, step = 0.01, group = "Line Filters")
float bodyTolAtr   = input.float(0.015, "Body Intersection Tol (×ATR)", minval = 0.0, step = 0.005, group = "Line Filters")
int maxBodyCuts    = input.int(3, "Allowed Body Cuts (QX heuristic)", minval = 0, maxval = 10, group = "Line Filters", tooltip = "QX-only approximation; this control is not shown in the TradeAxis settings supplied for comparison.")
float touchTolAtr  = input.float(0.08, "Touch Tolerance (×ATR)", minval = 0.0, step = 0.01, group = "Line Filters")
string brokenLineHandling = input.string("Invalidate on confirmed break", "Broken-Line Handling", options = ["Invalidate on confirmed break", "Show until break + reclaim"], group = "Line Filters", tooltip = "A confirmed close through a line removes it from the active set by default. The alternate mode keeps the line visible until price reclaims its original side.")
float breakBufferAtr = input.float(0.02, "Break Buffer (×ATR)", minval = 0.0, step = 0.01, group = "Line Filters")
int minBreakTicks = input.int(10, "Minimum Break Size (ticks)", minval = 0, maxval = 1000, group = "Line Filters")
string invalidationMode = input.string("Close", "Break/Reclaim Basis", options = ["Close", "Mid-body", "Body edge"], group = "Line Filters")

// ── Display ─────────────────────────────────────────────────────────────────
bool showActive    = input.bool(true, "Show Active Trendlines", group = "Visuals")
bool showSecond    = input.bool(true, "Show 2nd Best Lines", group = "Visuals")
color resistanceColor  = input.color(color.rgb(170, 0, 255), "Resistance Color", group = "Visuals")
color supportColor     = input.color(color.rgb(0, 188, 212), "Support Color", group = "Visuals")
color resistance2Color = input.color(color.rgb(170, 0, 255), "Resistance 2 Color", group = "Visuals")
color support2Color    = input.color(color.rgb(0, 188, 212), "Support 2 Color", group = "Visuals")
bool adaptiveTransparency = input.bool(true, "Adaptive Strength Transparency", group = "Visuals", tooltip = "Strong lines stay vivid; weak lines become faint. This QX-only 0–100 heuristic blends additional confirmed pivot touches, contact precision, candle-body path cleanliness, rejection, recency, span, and a penalty for a broken line. It is not a probability or TradeAxis score.")
int strongestTransparency = input.int(12, "Strong Line Transparency", minval = 0, maxval = 90, group = "Visuals")
int weakestTransparency = input.int(88, "Weak Line Transparency", minval = 10, maxval = 100, group = "Visuals")
bool glowEnabled = input.bool(true, "Glow Strong Trendlines", group = "Visuals", tooltip = "Draws a soft, wider halo behind lines whose QX strength reaches the threshold. This is visual emphasis only; it does not affect line selection or alerts.")
int glowThreshold = input.int(65, "Glow Strength Threshold", minval = 0, maxval = 100, group = "Visuals")
bool weakPulseEnabled = input.bool(true, "Weak / Secondary Yellow Pulse", group = "Visuals", tooltip = "Adds a faint yellow halo to low-strength primary lines and all second-best lines. For a primary line this marks low estimated strength, not a prediction that strength is falling. Live pulsing updates on incoming chart ticks; historical bars show a steady faint halo. It does not affect selection or alerts.")
int weakStrengthThreshold = input.int(45, "Weak-Line Threshold", minval = 0, maxval = 100, group = "Visuals")
int secondaryTransparency = input.int(74, "Weak / Secondary Line Transparency", minval = 40, maxval = 95, group = "Visuals", tooltip = "Secondary lines and weak primary lines use at least this much transparency and switch to dashed styling.")
int lineWidth      = input.int(2, "Line Width", minval = 1, maxval = 4, group = "Visuals")

// ── Higher-timeframe trendlines ────────────────────────────────────────────
bool showHtfLines = input.bool(false, "Enable HTF Trendlines", group = "HTF Trendlines", tooltip = "Calculates one primary support and resistance line from confirmed bars on the selected higher timeframe. HTF calculation uses the same pivot, slope, body-path, touch, ranking, and break rules as the chart-timeframe engine.")
string htfTimeframe = input.timeframe("60", "HTF Timeframe", group = "HTF Trendlines")
color htfResistanceColor = input.color(color.rgb(220, 92, 100), "HTF Resistance Color", group = "HTF Trendlines")
color htfSupportColor = input.color(color.rgb(86, 184, 126), "HTF Support Color", group = "HTF Trendlines")
int htfLineTransparency = input.int(52, "HTF Line Transparency", minval = 20, maxval = 90, group = "HTF Trendlines")
int htfGlowTransparency = input.int(88, "HTF Glow Transparency", minval = 65, maxval = 98, group = "HTF Trendlines")
int htfLineWidth = input.int(2, "HTF Line Width", minval = 1, maxval = 4, group = "HTF Trendlines")

// ── Alerts ──────────────────────────────────────────────────────────────────
string alertMode = input.string("Every bar close while active", "Alert Frequency", options = ["On line activation/change", "Every bar close while active"], group = "Alerts")
int strongAlertThreshold = input.int(65, "Strong Trendline Alert Threshold", minval = 0, maxval = 100, group = "Alerts", tooltip = "A primary chart or enabled HTF line must meet this QX strength score and be above the Weak-Line Threshold. Second-best lines never trigger this alert.")

float atrSeries = ta.atr(14)
float pivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)
float pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)

var array<int> lowPivotBars = array.new_int()
var array<float> lowPivotPrices = array.new_float()
var array<int> highPivotBars = array.new_int()
var array<float> highPivotPrices = array.new_float()
// The prior 60-pivot cap could silently shorten the effective lookback well
// below Scan Lookback Bars on dense 1-minute charts. Keep more candidates so
// older eligible anchors remain in the pair search while bounding runtime.
int maxStoredPivots = math.min(scanBars, 100)

// Keep confirmed pivots inside the user-selected scan window. The pivot index
// is the actual turning bar; the pivot only becomes available after Right bars.
if not na(pivotLow)
    array.unshift(lowPivotBars, bar_index - pivotRight)
    array.unshift(lowPivotPrices, pivotLow)
    if array.size(lowPivotBars) > maxStoredPivots
        array.pop(lowPivotBars)
        array.pop(lowPivotPrices)
if not na(pivotHigh)
    array.unshift(highPivotBars, bar_index - pivotRight)
    array.unshift(highPivotPrices, pivotHigh)
    if array.size(highPivotBars) > maxStoredPivots
        array.pop(highPivotBars)
        array.pop(highPivotPrices)

while array.size(lowPivotBars) > 0 and bar_index - array.get(lowPivotBars, array.size(lowPivotBars) - 1) > scanBars
    array.pop(lowPivotBars)
    array.pop(lowPivotPrices)
while array.size(highPivotBars) > 0 and bar_index - array.get(highPivotBars, array.size(highPivotBars) - 1) > scanBars
    array.pop(highPivotBars)
    array.pop(highPivotPrices)

// HTF state is collected from the prior completed HTF candle. The offset plus
// lookahead_on keeps the line state stable throughout the next HTF candle.
f_confirmedHtfSamples() =>
    float sampleAtr = ta.atr(14)
    float samplePivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
    float samplePivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
    int sampleLowPivotTime = not na(samplePivotLow) ? time[pivotRight] : na
    int sampleHighPivotTime = not na(samplePivotHigh) ? time[pivotRight] : na
    [time[1], open[1], high[1], low[1], close[1], sampleAtr[1], samplePivotLow[1], samplePivotHigh[1], sampleLowPivotTime[1], sampleHighPivotTime[1]]

[htfSampleTime, htfSampleOpen, htfSampleHigh, htfSampleLow, htfSampleClose, htfSampleAtr, htfSamplePivotLow, htfSamplePivotHigh, htfSampleLowPivotTime, htfSampleHighPivotTime] = request.security(syminfo.tickerid, htfTimeframe, f_confirmedHtfSamples(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, calc_bars_count = scanBars + pivotLeft + pivotRight + 20)
int chartTimeframeSeconds = timeframe.in_seconds(timeframe.period)
int selectedHtfSeconds = timeframe.in_seconds(htfTimeframe)
bool htfIsHigher = not na(chartTimeframeSeconds) and not na(selectedHtfSeconds) and selectedHtfSeconds > chartTimeframeSeconds

var array<int> htfBarTimes = array.new_int()
var array<float> htfOpens = array.new_float()
var array<float> htfHighs = array.new_float()
var array<float> htfLows = array.new_float()
var array<float> htfCloses = array.new_float()
var array<float> htfAtrs = array.new_float()
var array<int> htfLowPivotSerials = array.new_int()
var array<float> htfLowPivotPrices = array.new_float()
var array<int> htfLowPivotTimes = array.new_int()
var array<int> htfHighPivotSerials = array.new_int()
var array<float> htfHighPivotPrices = array.new_float()
var array<int> htfHighPivotTimes = array.new_int()
var int htfCurrentSerial = na
var int lastHtfSampleTime = na

if showHtfLines and htfIsHigher and not na(htfSampleTime) and (na(lastHtfSampleTime) or htfSampleTime != lastHtfSampleTime)
    htfCurrentSerial := na(htfCurrentSerial) ? 0 : htfCurrentSerial + 1
    lastHtfSampleTime := htfSampleTime
    array.push(htfBarTimes, htfSampleTime)
    array.push(htfOpens, htfSampleOpen)
    array.push(htfHighs, htfSampleHigh)
    array.push(htfLows, htfSampleLow)
    array.push(htfCloses, htfSampleClose)
    array.push(htfAtrs, htfSampleAtr)

    if not na(htfSamplePivotLow) and not na(htfSampleLowPivotTime)
        array.unshift(htfLowPivotSerials, htfCurrentSerial - pivotRight)
        array.unshift(htfLowPivotPrices, htfSamplePivotLow)
        array.unshift(htfLowPivotTimes, htfSampleLowPivotTime)
    if not na(htfSamplePivotHigh) and not na(htfSampleHighPivotTime)
        array.unshift(htfHighPivotSerials, htfCurrentSerial - pivotRight)
        array.unshift(htfHighPivotPrices, htfSamplePivotHigh)
        array.unshift(htfHighPivotTimes, htfSampleHighPivotTime)

    while array.size(htfBarTimes) > scanBars + 1
        array.shift(htfBarTimes)
        array.shift(htfOpens)
        array.shift(htfHighs)
        array.shift(htfLows)
        array.shift(htfCloses)
        array.shift(htfAtrs)
    while array.size(htfLowPivotSerials) > 0 and htfCurrentSerial - array.get(htfLowPivotSerials, array.size(htfLowPivotSerials) - 1) > scanBars
        array.pop(htfLowPivotSerials)
        array.pop(htfLowPivotPrices)
        array.pop(htfLowPivotTimes)
    while array.size(htfHighPivotSerials) > 0 and htfCurrentSerial - array.get(htfHighPivotSerials, array.size(htfHighPivotSerials) - 1) > scanBars
        array.pop(htfHighPivotSerials)
        array.pop(htfHighPivotPrices)
        array.pop(htfHighPivotTimes)
    int maxHtfPivots = math.min(scanBars, 100)
    if array.size(htfLowPivotSerials) > maxHtfPivots
        array.pop(htfLowPivotSerials)
        array.pop(htfLowPivotPrices)
        array.pop(htfLowPivotTimes)
    if array.size(htfHighPivotSerials) > maxHtfPivots
        array.pop(htfHighPivotSerials)
        array.pop(htfHighPivotPrices)
        array.pop(htfHighPivotTimes)

// ── Candidate validation helpers ────────────────────────────────────────────
// These helpers isolate structural validation, pivot contact counting, and
// lifecycle handling. Their thresholds remain QX approximations of the private
// TradeAxis implementation.
f_checkBodyPath(int x1, float y1, int x2, float slope, bool isSupport) =>
    int bodyCuts = 0
    if x2 - x1 > 1
        for x = x1 + 1 to x2 - 1
            int offset = bar_index - x
            float projected = y1 + slope * (x - x1)
            float tol = nz(atrSeries[offset], syminfo.mintick) * bodyTolAtr
            float bodyBottom = math.min(open[offset], close[offset])
            float bodyTop = math.max(open[offset], close[offset])
            bool cut = isSupport ? bodyBottom < projected - tol : bodyTop > projected + tol
            if cut
                bodyCuts += 1
                if bodyCuts > maxBodyCuts
                    break
    [bodyCuts <= maxBodyCuts, bodyCuts]

f_countTouches(array<int> pivotBars, array<float> pivotPrices, int x1, float y1, int x2, float slope, bool isSupport, int endBarExclusive) =>
    int touches = 0
    int nonAnchorTouches = 0
    int lastTouch = x1 - math.max(2, pivotLeft + pivotRight)
    int lastTouchBar = na
    float totalNonAnchorTouchError = 0.0
    float totalNonAnchorRejection = 0.0
    int pivotCount = array.size(pivotBars)
    int minSpacing = math.max(2, pivotLeft + pivotRight)
    if pivotCount > 0
        // Pivots are stored newest first; count chronologically so contacts
        // are separated consistently and lastTouchBar is truly the latest.
        for touchOrdinal = 0 to pivotCount - 1
            int touchIndex = pivotCount - 1 - touchOrdinal
            int touchBar = array.get(pivotBars, touchIndex)
            float touchPrice = array.get(pivotPrices, touchIndex)
            int offset = bar_index - touchBar
            float projected = y1 + slope * (touchBar - x1)
            float tol = math.max(nz(atrSeries[offset], syminfo.mintick) * touchTolAtr, syminfo.mintick * 2.0)
            bool contact = touchBar >= x1 and touchBar < endBarExclusive and math.abs(touchPrice - projected) <= tol
            if contact and touchBar - lastTouch >= minSpacing
                touches += 1
                lastTouch := touchBar
                lastTouchBar := touchBar
                // The two anchor pivots define the line by construction.
                // Exclude them from strength precision/rejection so a
                // two-point line does not get perfect-contact credit. Keep
                // non-anchor contacts both between and after the anchors.
                if touchBar != x1 and touchBar != x2
                    nonAnchorTouches += 1
                    totalNonAnchorTouchError += math.min(math.abs(touchPrice - projected) / tol, 1.0)
                    float candleRange = math.max(high[offset] - low[offset], syminfo.mintick)
                    float rejection = isSupport ? (close[offset] - projected) / candleRange : (projected - close[offset]) / candleRange
                    totalNonAnchorRejection += math.max(0.0, math.min(rejection, 1.0))
    float averageTouchError = nonAnchorTouches > 0 ? totalNonAnchorTouchError / nonAnchorTouches : 1.0
    float averageRejection = nonAnchorTouches > 0 ? totalNonAnchorRejection / nonAnchorTouches : 0.0
    [touches, lastTouchBar, averageTouchError, averageRejection]

f_lineLifecycle(int x2, float y2, float slope, bool isSupport) =>
    bool wasBroken = false
    bool reclaimed = false
    int breakBar = na
    int confirmedEndBar = barstate.isconfirmed ? bar_index : bar_index - 1
    if x2 < confirmedEndBar
        for x = x2 + 1 to confirmedEndBar
            int offset = bar_index - x
            float projected = y2 + slope * (x - x2)
            float tol = math.max(nz(atrSeries[offset], syminfo.mintick) * breakBufferAtr, syminfo.mintick * minBreakTicks)
            float evalPrice = invalidationMode == "Close" ? close[offset] : invalidationMode == "Mid-body" ? (open[offset] + close[offset]) * 0.5 : isSupport ? math.min(open[offset], close[offset]) : math.max(open[offset], close[offset])
            bool wrongSide = isSupport ? evalPrice < projected - tol : evalPrice > projected + tol
            bool originalSide = isSupport ? evalPrice > projected + tol : evalPrice < projected - tol
            if not wasBroken and wrongSide
                wasBroken := true
                breakBar := x
            else if wasBroken and originalSide
                reclaimed := true
                break
    [wasBroken, reclaimed, breakBar]

// HTF helpers address the retained HTF candle arrays by sequential HTF bar
// number. They deliberately use HTF OHLC and ATR rather than chart-timeframe
// series, while keeping the chart engine's candidate rules and defaults.
f_htfDataIndex(int currentSerial, int targetSerial) =>
    int idx = array.size(htfBarTimes) - 1 - (currentSerial - targetSerial)
    idx >= 0 and idx < array.size(htfBarTimes) ? idx : na

f_htfFloatAt(array<float> values, int currentSerial, int targetSerial) =>
    int idx = f_htfDataIndex(currentSerial, targetSerial)
    not na(idx) and idx < array.size(values) ? array.get(values, idx) : na

f_htfBodyPath(int x1, float y1, int time1, int x2, float y2, int time2, bool isSupport, int currentSerial) =>
    int bodyCuts = 0
    bool validTimeSpan = time2 > time1
    if validTimeSpan and x2 - x1 > 1
        for x = x1 + 1 to x2 - 1
            int dataIndex = f_htfDataIndex(currentSerial, x)
            if not na(dataIndex)
                int sampleTime = array.get(htfBarTimes, dataIndex)
                float projected = y1 + (y2 - y1) / float(time2 - time1) * float(sampleTime - time1)
                float tol = nz(array.get(htfAtrs, dataIndex), syminfo.mintick) * bodyTolAtr
                float bodyBottom = math.min(array.get(htfOpens, dataIndex), array.get(htfCloses, dataIndex))
                float bodyTop = math.max(array.get(htfOpens, dataIndex), array.get(htfCloses, dataIndex))
                bool cut = isSupport ? bodyBottom < projected - tol : bodyTop > projected + tol
                if cut
                    bodyCuts += 1
                    if bodyCuts > maxBodyCuts
                        break
    [validTimeSpan and bodyCuts <= maxBodyCuts, bodyCuts]

f_countHtfTouches(array<int> pivotSerials, array<float> pivotPrices, array<int> pivotTimes, int x1, float y1, int time1, int x2, float y2, int time2, bool isSupport, int endSerialExclusive, int currentSerial) =>
    int touches = 0
    int nonAnchorTouches = 0
    int lastTouch = x1 - math.max(2, pivotLeft + pivotRight)
    int lastTouchSerial = na
    float totalNonAnchorTouchError = 0.0
    float totalNonAnchorRejection = 0.0
    int pivotCount = array.size(pivotSerials)
    int minSpacing = math.max(2, pivotLeft + pivotRight)
    if pivotCount > 0
        for touchOrdinal = 0 to pivotCount - 1
            int touchIndex = pivotCount - 1 - touchOrdinal
            int touchSerial = array.get(pivotSerials, touchIndex)
            float touchPrice = array.get(pivotPrices, touchIndex)
            int touchTime = array.get(pivotTimes, touchIndex)
            int dataIndex = f_htfDataIndex(currentSerial, touchSerial)
            if not na(dataIndex)
                float projected = y1 + (y2 - y1) / float(time2 - time1) * float(touchTime - time1)
                float tol = math.max(nz(array.get(htfAtrs, dataIndex), syminfo.mintick) * touchTolAtr, syminfo.mintick * 2.0)
                bool contact = touchSerial >= x1 and touchSerial < endSerialExclusive and math.abs(touchPrice - projected) <= tol
                if contact and touchSerial - lastTouch >= minSpacing
                    touches += 1
                    lastTouch := touchSerial
                    lastTouchSerial := touchSerial
                    if touchSerial != x1 and touchSerial != x2
                        nonAnchorTouches += 1
                        totalNonAnchorTouchError += math.min(math.abs(touchPrice - projected) / tol, 1.0)
                        float candleRange = math.max(array.get(htfHighs, dataIndex) - array.get(htfLows, dataIndex), syminfo.mintick)
                        float closePrice = array.get(htfCloses, dataIndex)
                        float rejection = isSupport ? (closePrice - projected) / candleRange : (projected - closePrice) / candleRange
                        totalNonAnchorRejection += math.max(0.0, math.min(rejection, 1.0))
    float averageTouchError = nonAnchorTouches > 0 ? totalNonAnchorTouchError / nonAnchorTouches : 1.0
    float averageRejection = nonAnchorTouches > 0 ? totalNonAnchorRejection / nonAnchorTouches : 0.0
    [touches, lastTouchSerial, averageTouchError, averageRejection]

f_htfLineLifecycle(int x1, float y1, int time1, int x2, float y2, int time2, bool isSupport, int currentSerial) =>
    bool wasBroken = false
    bool reclaimed = false
    int breakSerial = na
    if x2 < currentSerial
        for x = x2 + 1 to currentSerial
            int dataIndex = f_htfDataIndex(currentSerial, x)
            if not na(dataIndex)
                int sampleTime = array.get(htfBarTimes, dataIndex)
                float projected = y2 + (y2 - y1) / float(time2 - time1) * float(sampleTime - time2)
                float tol = math.max(nz(array.get(htfAtrs, dataIndex), syminfo.mintick) * breakBufferAtr, syminfo.mintick * minBreakTicks)
                float barOpen = array.get(htfOpens, dataIndex)
                float barClose = array.get(htfCloses, dataIndex)
                float evalPrice = invalidationMode == "Close" ? barClose : invalidationMode == "Mid-body" ? (barOpen + barClose) * 0.5 : isSupport ? math.min(barOpen, barClose) : math.max(barOpen, barClose)
                bool wrongSide = isSupport ? evalPrice < projected - tol : evalPrice > projected + tol
                bool originalSide = isSupport ? evalPrice > projected + tol : evalPrice < projected - tol
                if not wasBroken and wrongSide
                    wasBroken := true
                    breakSerial := x
                else if wasBroken and originalSide
                    reclaimed := true
                    break
    [wasBroken, reclaimed, breakSerial]

// Returns the two highest-scoring eligible lines and their separate strength
// grades. Strength changes line opacity, not candidate eligibility or ranking.
f_selectLines(array<int> pivotBars, array<float> pivotPrices, bool isSupport) =>
    int bestX1 = na
    float bestY1 = na
    int bestX2 = na
    float bestY2 = na
    float bestScore = -1.0
    int bestTouches = 0
    float bestStrength = 0.0
    int secondX1 = na
    float secondY1 = na
    int secondX2 = na
    float secondY2 = na
    float secondScore = -1.0
    int secondTouches = 0
    float secondStrength = 0.0
    int pivotCount = array.size(pivotBars)

    if barstate.islast and pivotCount >= 2
        // Pivots are newest first. Cheap contact scoring bounds candidates
        // before expensive body-path and break-history scans.
        for newerIndex = 0 to pivotCount - 2
            int x2 = array.get(pivotBars, newerIndex)
            float y2 = array.get(pivotPrices, newerIndex)
            for olderIndex = newerIndex + 1 to pivotCount - 1
                int x1 = array.get(pivotBars, olderIndex)
                float y1 = array.get(pivotPrices, olderIndex)
                int span = x2 - x1

                if span >= minLineBars and span <= scanBars
                    float slope = (y2 - y1) / span
                    bool directionOk = isSupport ? slope > 0 : slope < 0
                    int atrOffset = bar_index - x2
                    float atrAtAnchor = atrSeries[atrOffset]
                    float slopeMetric = slopeMode == "ATR Relative" ? math.abs(slope) / math.max(nz(atrAtAnchor, syminfo.mintick), syminfo.mintick) : math.abs(slope)
                    bool slopeOk = slopeMetric >= minSlope and slopeMetric <= maxSlope
                    if directionOk and slopeOk
                        // Contact scoring is cheaper than walking every candle
                        // between anchors. Use its raw score as an upper bound:
                        // break handling can only remove touches / recency, so
                        // candidates that cannot beat the current second line
                        // do not need a body-path scan or lifecycle walk.
                        int touches = 0
                        int lastTouchBar = na
                        float averageTouchError = 1.0
                        float averageRejection = 0.0
                        [countedTouches, countedLastTouchBar, countedTouchError, countedRejection] = f_countTouches(pivotBars, pivotPrices, x1, y1, x2, slope, isSupport, bar_index + 1)
                        touches := countedTouches
                        lastTouchBar := countedLastTouchBar
                        averageTouchError := countedTouchError
                        averageRejection := countedRejection

                        if touches >= 2
                            int mostRecentTouch = na(lastTouchBar) ? x2 : lastTouchBar
                            float recencyScore = 1.0 - math.min(float(bar_index - mostRecentTouch) / scanBars, 1.0)
                            float spanScore = math.min(float(span) / scanBars, 1.0)
                            float scoreUpperBound = touches * 100.0 + recencyScore * 20.0 + spanScore * 10.0

                            if scoreUpperBound > secondScore
                                [bodyPathValid, bodyCuts] = f_checkBodyPath(x1, y1, x2, slope, isSupport)
                                if bodyPathValid
                                    bool broken = false
                                    bool reclaimed = false
                                    int breakBar = na
                                    [candidateBroken, candidateReclaimed, candidateBreakBar] = f_lineLifecycle(x2, y2, slope, isSupport)
                                    broken := candidateBroken
                                    reclaimed := candidateReclaimed
                                    breakBar := candidateBreakBar

                                    // A line that has broken but has not yet reclaimed may
                                    // remain visible, but later pivot contacts must not
                                    // improve its ranking. Otherwise stale/broken geometry
                                    // can outrank a currently respected candidate.
                                    int scoredTouches = touches
                                    int lastScoredTouchBar = lastTouchBar
                                    if broken and not na(breakBar)
                                        [preBreakTouches, preBreakLastTouchBar, preBreakTouchError, preBreakRejection] = f_countTouches(pivotBars, pivotPrices, x1, y1, x2, slope, isSupport, breakBar)
                                        scoredTouches := preBreakTouches
                                        lastScoredTouchBar := preBreakLastTouchBar
                                        averageTouchError := preBreakTouchError
                                        averageRejection := preBreakRejection

                                    int finalMostRecentTouch = na(lastScoredTouchBar) ? x2 : lastScoredTouchBar
                                    float finalRecencyScore = 1.0 - math.min(float(bar_index - finalMostRecentTouch) / scanBars, 1.0)
                                    float finalScore = scoredTouches * 100.0 + finalRecencyScore * 20.0 + spanScore * 10.0
                                    // The two endpoint pivots define the line but
                                    // are not repeat-contact evidence.
                                    float touchCountStrength = math.min(float(math.max(scoredTouches - 2, 0)) / 4.0, 1.0)
                                    float touchPrecisionStrength = 1.0 - math.max(0.0, math.min(averageTouchError, 1.0))
                                    float pathCleanlinessStrength = maxBodyCuts == 0 ? 1.0 : 1.0 - float(bodyCuts) / (maxBodyCuts + 1.0)
                                    float recencyStrength = 1.0 - math.min(float(bar_index - finalMostRecentTouch) / math.max(float(scanBars) * 0.5, 1.0), 1.0)
                                    float rejectionStrength = math.max(0.0, math.min(averageRejection, 1.0))
                                    float spanMaturityStrength = math.min(float(span) / math.max(float(minLineBars) * 4.0, 1.0), 1.0)
                                    float lineStrength = 100.0 * (touchCountStrength * 0.30 + touchPrecisionStrength * 0.20 + pathCleanlinessStrength * 0.20 + recencyStrength * 0.15 + rejectionStrength * 0.10 + spanMaturityStrength * 0.05)
                                    if not na(breakBar)
                                        lineStrength *= 0.70

                                    bool lifecycleValid = brokenLineHandling == "Invalidate on confirmed break" ? not broken : not reclaimed
                                    if lifecycleValid and scoredTouches >= 2
                                        if finalScore > bestScore
                                            secondX1 := bestX1
                                            secondY1 := bestY1
                                            secondX2 := bestX2
                                            secondY2 := bestY2
                                            secondScore := bestScore
                                            secondTouches := bestTouches
                                            secondStrength := bestStrength
                                            bestX1 := x1
                                            bestY1 := y1
                                            bestX2 := x2
                                            bestY2 := y2
                                            bestScore := finalScore
                                            bestTouches := scoredTouches
                                            bestStrength := lineStrength
                                        else if finalScore > secondScore
                                            secondX1 := x1
                                            secondY1 := y1
                                            secondX2 := x2
                                            secondY2 := y2
                                            secondScore := finalScore
                                            secondTouches := scoredTouches
                                            secondStrength := lineStrength

    [bestX1, bestY1, bestX2, bestY2, bestTouches, bestStrength, secondX1, secondY1, secondX2, secondY2, secondTouches, secondStrength]

// Select one primary HTF line per direction using the same configurable rules
// as the chart engine, but with HTF candle arrays and HTF-bar units throughout.
f_selectHtfPrimary(array<int> pivotSerials, array<float> pivotPrices, array<int> pivotTimes, bool isSupport, int currentSerial) =>
    int bestSerial1 = na
    float bestPrice1 = na
    int bestTime1 = na
    int bestSerial2 = na
    float bestPrice2 = na
    int bestTime2 = na
    int bestTouches = 0
    float bestStrength = 0.0
    float bestScore = -1.0
    int pivotCount = array.size(pivotSerials)

    if barstate.islast and not na(currentSerial) and pivotCount >= 2
        for newerIndex = 0 to pivotCount - 2
            int x2 = array.get(pivotSerials, newerIndex)
            float y2 = array.get(pivotPrices, newerIndex)
            int time2 = array.get(pivotTimes, newerIndex)
            for olderIndex = newerIndex + 1 to pivotCount - 1
                int x1 = array.get(pivotSerials, olderIndex)
                float y1 = array.get(pivotPrices, olderIndex)
                int time1 = array.get(pivotTimes, olderIndex)
                int span = x2 - x1

                if span >= minLineBars and span <= scanBars and time2 > time1
                    float slope = (y2 - y1) / span
                    bool directionOk = isSupport ? slope > 0 : slope < 0
                    float atrAtAnchor = f_htfFloatAt(htfAtrs, currentSerial, x2)
                    float slopeMetric = slopeMode == "ATR Relative" ? math.abs(slope) / math.max(nz(atrAtAnchor, syminfo.mintick), syminfo.mintick) : math.abs(slope)
                    bool slopeOk = slopeMetric >= minSlope and slopeMetric <= maxSlope
                    if directionOk and slopeOk
                        // Bound the candidate with its current touch score
                        // before scanning its full HTF body path. Removing
                        // post-break contacts can only lower this score.
                        int touches = 0
                        int lastTouchSerial = na
                        float averageTouchError = 1.0
                        float averageRejection = 0.0
                        [countedTouches, countedLastTouchSerial, countedTouchError, countedRejection] = f_countHtfTouches(pivotSerials, pivotPrices, pivotTimes, x1, y1, time1, x2, y2, time2, isSupport, currentSerial + 1, currentSerial)
                        touches := countedTouches
                        lastTouchSerial := countedLastTouchSerial
                        averageTouchError := countedTouchError
                        averageRejection := countedRejection

                        if touches >= 2
                            int mostRecentTouch = na(lastTouchSerial) ? x2 : lastTouchSerial
                            float recencyScore = 1.0 - math.min(float(currentSerial - mostRecentTouch) / scanBars, 1.0)
                            float spanScore = math.min(float(span) / scanBars, 1.0)
                            float scoreUpperBound = touches * 100.0 + recencyScore * 20.0 + spanScore * 10.0

                            if scoreUpperBound > bestScore
                                [bodyPathValid, bodyCuts] = f_htfBodyPath(x1, y1, time1, x2, y2, time2, isSupport, currentSerial)
                                if bodyPathValid
                                    bool broken = false
                                    bool reclaimed = false
                                    int breakSerial = na
                                    [candidateBroken, candidateReclaimed, candidateBreakSerial] = f_htfLineLifecycle(x1, y1, time1, x2, y2, time2, isSupport, currentSerial)
                                    broken := candidateBroken
                                    reclaimed := candidateReclaimed
                                    breakSerial := candidateBreakSerial

                                    int scoredTouches = touches
                                    int lastScoredTouchSerial = lastTouchSerial
                                    if broken and not na(breakSerial)
                                        [preBreakTouches, preBreakLastTouchSerial, preBreakTouchError, preBreakRejection] = f_countHtfTouches(pivotSerials, pivotPrices, pivotTimes, x1, y1, time1, x2, y2, time2, isSupport, breakSerial, currentSerial)
                                        scoredTouches := preBreakTouches
                                        lastScoredTouchSerial := preBreakLastTouchSerial
                                        averageTouchError := preBreakTouchError
                                        averageRejection := preBreakRejection

                                    int finalMostRecentTouch = na(lastScoredTouchSerial) ? x2 : lastScoredTouchSerial
                                    float finalRecencyScore = 1.0 - math.min(float(currentSerial - finalMostRecentTouch) / scanBars, 1.0)
                                    float finalScore = scoredTouches * 100.0 + finalRecencyScore * 20.0 + spanScore * 10.0
                                    float touchCountStrength = math.min(float(math.max(scoredTouches - 2, 0)) / 4.0, 1.0)
                                    float touchPrecisionStrength = 1.0 - math.max(0.0, math.min(averageTouchError, 1.0))
                                    float pathCleanlinessStrength = maxBodyCuts == 0 ? 1.0 : 1.0 - float(bodyCuts) / (maxBodyCuts + 1.0)
                                    float recencyStrength = 1.0 - math.min(float(currentSerial - finalMostRecentTouch) / math.max(float(scanBars) * 0.5, 1.0), 1.0)
                                    float rejectionStrength = math.max(0.0, math.min(averageRejection, 1.0))
                                    float spanMaturityStrength = math.min(float(span) / math.max(float(minLineBars) * 4.0, 1.0), 1.0)
                                    float lineStrength = 100.0 * (touchCountStrength * 0.30 + touchPrecisionStrength * 0.20 + pathCleanlinessStrength * 0.20 + recencyStrength * 0.15 + rejectionStrength * 0.10 + spanMaturityStrength * 0.05)
                                    if not na(breakSerial)
                                        lineStrength *= 0.70

                                    bool lifecycleValid = brokenLineHandling == "Invalidate on confirmed break" ? not broken : not reclaimed
                                    if lifecycleValid and scoredTouches >= 2 and finalScore > bestScore
                                        bestSerial1 := x1
                                        bestPrice1 := y1
                                        bestTime1 := array.get(pivotTimes, olderIndex)
                                        bestSerial2 := x2
                                        bestPrice2 := y2
                                        bestTime2 := array.get(pivotTimes, newerIndex)
                                        bestTouches := scoredTouches
                                        bestStrength := lineStrength
                                        bestScore := finalScore

    [bestSerial1, bestPrice1, bestTime1, bestSerial2, bestPrice2, bestTime2, bestTouches, bestStrength]

[supportX1, supportY1, supportX2, supportY2, supportTouches, supportStrength, support2X1, support2Y1, support2X2, support2Y2, support2Touches, support2Strength] = f_selectLines(lowPivotBars, lowPivotPrices, true)
[resistanceX1, resistanceY1, resistanceX2, resistanceY2, resistanceTouches, resistanceStrength, resistance2X1, resistance2Y1, resistance2X2, resistance2Y2, resistance2Touches, resistance2Strength] = f_selectLines(highPivotBars, highPivotPrices, false)

[htfSupportSerial1, htfSupportPrice1, htfSupportTime1, htfSupportSerial2, htfSupportPrice2, htfSupportTime2, htfSupportTouches, htfSupportStrength] = f_selectHtfPrimary(htfLowPivotSerials, htfLowPivotPrices, htfLowPivotTimes, true, htfCurrentSerial)
[htfResistanceSerial1, htfResistancePrice1, htfResistanceTime1, htfResistanceSerial2, htfResistancePrice2, htfResistanceTime2, htfResistanceTouches, htfResistanceStrength] = f_selectHtfPrimary(htfHighPivotSerials, htfHighPivotPrices, htfHighPivotTimes, false, htfCurrentSerial)

bool hasBullish = not na(supportX1)
bool hasBearish = not na(resistanceX1)
bool hasBullish2 = not na(support2X1)
bool hasBearish2 = not na(resistance2X1)
bool hasHtfBullish = showHtfLines and htfIsHigher and not na(htfSupportSerial1)
bool hasHtfBearish = showHtfLines and htfIsHigher and not na(htfResistanceSerial1)
float bullishLevel = hasBullish ? supportY2 + (supportY2 - supportY1) / (supportX2 - supportX1) * (bar_index - supportX2) : na
float bearishLevel = hasBearish ? resistanceY2 + (resistanceY2 - resistanceY1) / (resistanceX2 - resistanceX1) * (bar_index - resistanceX2) : na
// The selected HTF state is anchored at the last completed HTF candle. Build
// a fractional bar coordinate from the actual current HTF open/close times;
// a fixed seconds divisor is inaccurate for calendar bars and partial sessions.
int currentHtfOpenTime = time(htfTimeframe)
int currentHtfCloseTime = time_close(htfTimeframe)
float currentHtfDuration = not na(currentHtfOpenTime) and not na(currentHtfCloseTime) ? float(currentHtfCloseTime - currentHtfOpenTime) : na
float currentHtfProgress = not na(currentHtfDuration) and currentHtfDuration > 0 ? math.max(0.0, math.min(float(time - currentHtfOpenTime) / currentHtfDuration, 1.0)) : na
float htfCurrentBarPosition = not na(htfCurrentSerial) and not na(currentHtfProgress) ? float(htfCurrentSerial) + 1.0 + currentHtfProgress : na

// HTF drawings use xloc.bar_time, so alert/Data Window levels use the same
// timestamp-based line equation. This keeps reported prices on the drawn line.
float htfBullishTimeSpan = hasHtfBullish ? float(htfSupportTime2 - htfSupportTime1) : na
float htfBearishTimeSpan = hasHtfBearish ? float(htfResistanceTime2 - htfResistanceTime1) : na
float htfBullishLevel = hasHtfBullish and not na(htfBullishTimeSpan) and htfBullishTimeSpan > 0 ? htfSupportPrice2 + (htfSupportPrice2 - htfSupportPrice1) / htfBullishTimeSpan * float(time - htfSupportTime2) : na
float htfBearishLevel = hasHtfBearish and not na(htfBearishTimeSpan) and htfBearishTimeSpan > 0 ? htfResistancePrice2 + (htfResistancePrice2 - htfResistancePrice1) / htfBearishTimeSpan * float(time - htfResistanceTime2) : na

// Strong alerts deliberately consider only the primary line in each direction.
// Keep the alert floor above the visual weak threshold so changing either input
// cannot accidentally make a line classified as weak qualify as strong.
int effectiveStrongThreshold = math.max(strongAlertThreshold, weakStrengthThreshold + 1)
bool strongChartBullish = hasBullish and supportStrength >= effectiveStrongThreshold
bool strongChartBearish = hasBearish and resistanceStrength >= effectiveStrongThreshold
bool strongHtfBullish = hasHtfBullish and htfSupportStrength >= effectiveStrongThreshold
bool strongHtfBearish = hasHtfBearish and htfResistanceStrength >= effectiveStrongThreshold
bool strongBullishActive = strongChartBullish or strongHtfBullish
bool strongBearishActive = strongChartBearish or strongHtfBearish
bool strongTrendlineActive = strongBullishActive or strongBearishActive

// Draw only the currently ranked candidates, extending each line to the right.
var line supportLine = na
var line resistanceLine = na
var line support2Line = na
var line resistance2Line = na
var line supportGlowLine = na
var line resistanceGlowLine = na
var line support2GlowLine = na
var line resistance2GlowLine = na
var line supportWeakPulseLine = na
var line resistanceWeakPulseLine = na
var line support2WeakPulseLine = na
var line resistance2WeakPulseLine = na
var line htfSupportLine = na
var line htfResistanceLine = na
var line htfSupportGlowLine = na
var line htfResistanceGlowLine = na

f_strengthColor(color baseColor, float strength, bool forceFaint) =>
    float boundedStrength = math.max(0.0, math.min(strength, 100.0))
    float weakAlpha = float(math.max(weakestTransparency, strongestTransparency))
    float strongAlpha = float(math.min(weakestTransparency, strongestTransparency))
    int rawTransparency = adaptiveTransparency ? int(math.round(weakAlpha - boundedStrength / 100.0 * (weakAlpha - strongAlpha))) : 0
    bool isWeak = forceFaint or strength <= weakStrengthThreshold
    int transparency = isWeak ? math.max(rawTransparency, secondaryTransparency) : rawTransparency
    color.new(baseColor, math.max(0, math.min(transparency, 100)))

f_syncLine(line currentLine, bool enabled, int x1, float y1, int x2, float y2, color lineColor, float strength, int width, bool secondary) =>
    line result = currentLine
    if enabled and not na(x1) and not na(y1) and not na(x2) and not na(y2)
        color displayColor = f_strengthColor(lineColor, strength, secondary)
        bool dashed = secondary or strength <= weakStrengthThreshold
        if na(result)
            result := line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = extend.right, color = displayColor, width = width, style = dashed ? line.style_dashed : line.style_solid)
        else
            line.set_xy1(result, x1, y1)
            line.set_xy2(result, x2, y2)
            line.set_extend(result, extend.right)
            line.set_color(result, displayColor)
            line.set_width(result, width)
            line.set_style(result, dashed ? line.style_dashed : line.style_solid)
    else if not na(result)
        line.delete(result)
        result := na
    result

// A single wide, strength-gated stroke beneath the crisp line approximates a
// soft glow. Weak candidates retain only their faint adaptive-color centerline.
f_syncGlow(line currentGlow, bool enabled, int x1, float y1, int x2, float y2, color baseColor, float strength, int width) =>
    line result = currentGlow
    bool valid = enabled and not na(x1) and not na(y1) and not na(x2) and not na(y2)
    bool lit = glowEnabled and strength >= glowThreshold
    if valid and lit
        float glowStrength = glowThreshold >= 100 ? (strength >= 100 ? 1.0 : 0.0) : math.max(0.0, math.min((strength - glowThreshold) / (100.0 - glowThreshold), 1.0))
        int glowTransparency = int(math.round(92.0 - glowStrength * 36.0))
        color glowColor = color.new(baseColor, glowTransparency)
        if na(result)
            result := line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = extend.right, color = glowColor, width = width + 6)
        else
            line.set_xy1(result, x1, y1)
            line.set_xy2(result, x2, y2)
            line.set_extend(result, extend.right)
            line.set_color(result, glowColor)
            line.set_width(result, width + 6)
    else if not na(result)
        line.delete(result)
        result := na
    result

// Faint warning halo for weak candidates. timenow advances only when the
// realtime indicator recalculates on incoming ticks; historical charts remain
// steady instead of pretending to replay an animation.
f_syncWeakPulse(line currentPulse, bool enabled, int x1, float y1, int x2, float y2, float strength, int width, bool forcePulse) =>
    line result = currentPulse
    bool valid = enabled and not na(x1) and not na(y1) and not na(x2) and not na(y2)
    bool weak = weakPulseEnabled and (strength <= weakStrengthThreshold or forcePulse)
    if valid and weak
        float measuredWeakness = weakStrengthThreshold <= 0 ? (strength <= 0 ? 1.0 : 0.0) : math.max(0.0, math.min((weakStrengthThreshold - strength) / weakStrengthThreshold, 1.0))
        float weakness = forcePulse ? math.max(measuredWeakness, 0.35) : measuredWeakness
        float pulseWave = barstate.isrealtime ? (math.sin(float(timenow) / 700.0) + 1.0) * 0.5 : 0.35
        int pulseTransparency = int(math.round(96.0 - weakness * (5.0 + 8.0 * pulseWave)))
        color pulseColor = color.new(color.yellow, math.max(0, math.min(pulseTransparency, 100)))
        if na(result)
            result := line.new(x1, y1, x2, y2, xloc = xloc.bar_index, extend = extend.right, color = pulseColor, width = width + 3, style = line.style_dashed)
        else
            line.set_xy1(result, x1, y1)
            line.set_xy2(result, x2, y2)
            line.set_extend(result, extend.right)
            line.set_color(result, pulseColor)
            line.set_width(result, width + 3)
            line.set_style(result, line.style_dashed)
    else if not na(result)
        line.delete(result)
        result := na
    result

f_syncHtfLine(line currentLine, bool enabled, int time1, float price1, int time2, float price2, color baseColor, int width) =>
    line result = currentLine
    if enabled and not na(time1) and not na(price1) and not na(time2) and not na(price2)
        color lineColor = color.new(baseColor, htfLineTransparency)
        if na(result)
            result := line.new(time1, price1, time2, price2, xloc = xloc.bar_time, extend = extend.right, color = lineColor, width = width, style = line.style_dashed)
        else
            line.set_xy1(result, time1, price1)
            line.set_xy2(result, time2, price2)
            line.set_extend(result, extend.right)
            line.set_color(result, lineColor)
            line.set_width(result, width)
            line.set_style(result, line.style_dashed)
    else if not na(result)
        line.delete(result)
        result := na
    result

f_syncHtfGlow(line currentGlow, bool enabled, int time1, float price1, int time2, float price2, color baseColor, int width) =>
    line result = currentGlow
    if enabled and not na(time1) and not na(price1) and not na(time2) and not na(price2)
        color glowColor = color.new(baseColor, htfGlowTransparency)
        if na(result)
            result := line.new(time1, price1, time2, price2, xloc = xloc.bar_time, extend = extend.right, color = glowColor, width = width + 6, style = line.style_solid)
        else
            line.set_xy1(result, time1, price1)
            line.set_xy2(result, time2, price2)
            line.set_extend(result, extend.right)
            line.set_color(result, glowColor)
            line.set_width(result, width + 6)
            line.set_style(result, line.style_solid)
    else if not na(result)
        line.delete(result)
        result := na
    result

if barstate.islast
    // Draw the broader HTF glow first, then the HTF dashed strokes behind QX lines.
    htfSupportGlowLine := f_syncHtfGlow(htfSupportGlowLine, hasHtfBullish, htfSupportTime1, htfSupportPrice1, htfSupportTime2, htfSupportPrice2, htfSupportColor, htfLineWidth)
    htfResistanceGlowLine := f_syncHtfGlow(htfResistanceGlowLine, hasHtfBearish, htfResistanceTime1, htfResistancePrice1, htfResistanceTime2, htfResistancePrice2, htfResistanceColor, htfLineWidth)
    htfSupportLine := f_syncHtfLine(htfSupportLine, hasHtfBullish, htfSupportTime1, htfSupportPrice1, htfSupportTime2, htfSupportPrice2, htfSupportColor, htfLineWidth)
    htfResistanceLine := f_syncHtfLine(htfResistanceLine, hasHtfBearish, htfResistanceTime1, htfResistancePrice1, htfResistanceTime2, htfResistancePrice2, htfResistanceColor, htfLineWidth)

    // Primary lines can use the matching-color glow; secondary lines remain
    // deliberately dashed/faint and use the yellow pulse as their distinction.
    supportGlowLine := f_syncGlow(supportGlowLine, showActive and hasBullish, supportX1, supportY1, supportX2, supportY2, supportColor, supportStrength, lineWidth)
    resistanceGlowLine := f_syncGlow(resistanceGlowLine, showActive and hasBearish, resistanceX1, resistanceY1, resistanceX2, resistanceY2, resistanceColor, resistanceStrength, lineWidth)
    support2GlowLine := f_syncGlow(support2GlowLine, false, support2X1, support2Y1, support2X2, support2Y2, support2Color, support2Strength, math.max(1, lineWidth - 1))
    resistance2GlowLine := f_syncGlow(resistance2GlowLine, false, resistance2X1, resistance2Y1, resistance2X2, resistance2Y2, resistance2Color, resistance2Strength, math.max(1, lineWidth - 1))
    supportWeakPulseLine := f_syncWeakPulse(supportWeakPulseLine, showActive and hasBullish, supportX1, supportY1, supportX2, supportY2, supportStrength, lineWidth, false)
    resistanceWeakPulseLine := f_syncWeakPulse(resistanceWeakPulseLine, showActive and hasBearish, resistanceX1, resistanceY1, resistanceX2, resistanceY2, resistanceStrength, lineWidth, false)
    support2WeakPulseLine := f_syncWeakPulse(support2WeakPulseLine, showActive and showSecond and hasBullish2, support2X1, support2Y1, support2X2, support2Y2, support2Strength, math.max(1, lineWidth - 1), true)
    resistance2WeakPulseLine := f_syncWeakPulse(resistance2WeakPulseLine, showActive and showSecond and hasBearish2, resistance2X1, resistance2Y1, resistance2X2, resistance2Y2, resistance2Strength, math.max(1, lineWidth - 1), true)
    supportLine := f_syncLine(supportLine, showActive and hasBullish, supportX1, supportY1, supportX2, supportY2, supportColor, supportStrength, lineWidth, false)
    resistanceLine := f_syncLine(resistanceLine, showActive and hasBearish, resistanceX1, resistanceY1, resistanceX2, resistanceY2, resistanceColor, resistanceStrength, lineWidth, false)
    support2Line := f_syncLine(support2Line, showActive and showSecond and hasBullish2, support2X1, support2Y1, support2X2, support2Y2, support2Color, support2Strength, math.max(1, lineWidth - 1), true)
    resistance2Line := f_syncLine(resistance2Line, showActive and showSecond and hasBearish2, resistance2X1, resistance2Y1, resistance2X2, resistance2Y2, resistance2Color, resistance2Strength, math.max(1, lineWidth - 1), true)

// Scanner-friendly numeric outputs. Add this indicator to Pine Screener and
// filter either Active plot to 1 to find symbols with a valid current line.
plot(hasBullish ? 1 : 0, "Bullish Trendline Active", display = display.data_window)
plot(hasBearish ? 1 : 0, "Bearish Trendline Active", display = display.data_window)
plot(hasHtfBullish ? 1 : 0, "HTF Bullish Trendline Active", display = display.data_window)
plot(hasHtfBearish ? 1 : 0, "HTF Bearish Trendline Active", display = display.data_window)
plot(strongBullishActive ? 1 : 0, "Strong Bullish Trendline Active", display = display.data_window)
plot(strongBearishActive ? 1 : 0, "Strong Bearish Trendline Active", display = display.data_window)
plot(strongTrendlineActive ? 1 : 0, "Strong Trendline Active", display = display.data_window)
plot(strongChartBullish ? bullishLevel : na, "Strong Chart Bullish Level", display = display.data_window)
plot(strongChartBearish ? bearishLevel : na, "Strong Chart Bearish Level", display = display.data_window)
plot(strongHtfBullish ? htfBullishLevel : na, "Strong HTF Bullish Level", display = display.data_window)
plot(strongHtfBearish ? htfBearishLevel : na, "Strong HTF Bearish Level", display = display.data_window)
plot(bullishLevel, "Bullish Trendline Price", display = display.data_window)
plot(bearishLevel, "Bearish Trendline Price", display = display.data_window)
plot(htfBullishLevel, "HTF Bullish Trendline Price", display = display.data_window)
plot(htfBearishLevel, "HTF Bearish Trendline Price", display = display.data_window)
plot(hasBullish ? supportTouches : na, "Bullish Touch Count", display = display.data_window)
plot(hasBearish ? resistanceTouches : na, "Bearish Touch Count", display = display.data_window)
plot(hasBullish ? supportStrength : na, "Bullish Trendline Strength", display = display.data_window)
plot(hasBearish ? resistanceStrength : na, "Bearish Trendline Strength", display = display.data_window)
plot(hasHtfBullish ? htfSupportTouches : na, "HTF Bullish Touch Count", display = display.data_window)
plot(hasHtfBearish ? htfResistanceTouches : na, "HTF Bearish Touch Count", display = display.data_window)
plot(hasHtfBullish ? htfSupportStrength : na, "HTF Bullish Trendline Strength", display = display.data_window)
plot(hasHtfBearish ? htfResistanceStrength : na, "HTF Bearish Trendline Strength", display = display.data_window)
plot(hasBullish2 ? support2Strength : na, "Bullish 2nd Trendline Strength", display = display.data_window)
plot(hasBearish2 ? resistance2Strength : na, "Bearish 2nd Trendline Strength", display = display.data_window)
// Anchor values stay in the Data Window so side-by-side review can compare
// the exact selected bars/prices without adding an on-chart analysis panel.
plot(hasBullish ? bar_index - supportX1 : na, "Bullish Anchor 1 Bars Ago", display = display.data_window)
plot(hasBullish ? supportY1 : na, "Bullish Anchor 1 Price", display = display.data_window)
plot(hasBullish ? bar_index - supportX2 : na, "Bullish Anchor 2 Bars Ago", display = display.data_window)
plot(hasBullish ? supportY2 : na, "Bullish Anchor 2 Price", display = display.data_window)
plot(hasBearish ? bar_index - resistanceX1 : na, "Bearish Anchor 1 Bars Ago", display = display.data_window)
plot(hasBearish ? resistanceY1 : na, "Bearish Anchor 1 Price", display = display.data_window)
plot(hasBearish ? bar_index - resistanceX2 : na, "Bearish Anchor 2 Bars Ago", display = display.data_window)
plot(hasBearish ? resistanceY2 : na, "Bearish Anchor 2 Price", display = display.data_window)
plot(hasHtfBullish ? htfCurrentBarPosition - htfSupportSerial1 : na, "HTF Bullish Anchor 1 Bars Ago", display = display.data_window)
plot(hasHtfBullish ? htfSupportPrice1 : na, "HTF Bullish Anchor 1 Price", display = display.data_window)
plot(hasHtfBullish ? htfCurrentBarPosition - htfSupportSerial2 : na, "HTF Bullish Anchor 2 Bars Ago", display = display.data_window)
plot(hasHtfBullish ? htfSupportPrice2 : na, "HTF Bullish Anchor 2 Price", display = display.data_window)
plot(hasHtfBearish ? htfCurrentBarPosition - htfResistanceSerial1 : na, "HTF Bearish Anchor 1 Bars Ago", display = display.data_window)
plot(hasHtfBearish ? htfResistancePrice1 : na, "HTF Bearish Anchor 1 Price", display = display.data_window)
plot(hasHtfBearish ? htfCurrentBarPosition - htfResistanceSerial2 : na, "HTF Bearish Anchor 2 Bars Ago", display = display.data_window)
plot(hasHtfBearish ? htfResistancePrice2 : na, "HTF Bearish Anchor 2 Price", display = display.data_window)
plot(hasBullish2 ? bar_index - support2X1 : na, "Bullish 2nd Anchor 1 Bars Ago", display = display.data_window)
plot(hasBullish2 ? support2Y1 : na, "Bullish 2nd Anchor 1 Price", display = display.data_window)
plot(hasBullish2 ? bar_index - support2X2 : na, "Bullish 2nd Anchor 2 Bars Ago", display = display.data_window)
plot(hasBullish2 ? support2Y2 : na, "Bullish 2nd Anchor 2 Price", display = display.data_window)
plot(hasBearish2 ? bar_index - resistance2X1 : na, "Bearish 2nd Anchor 1 Bars Ago", display = display.data_window)
plot(hasBearish2 ? resistance2Y1 : na, "Bearish 2nd Anchor 1 Price", display = display.data_window)
plot(hasBearish2 ? bar_index - resistance2X2 : na, "Bearish 2nd Anchor 2 Bars Ago", display = display.data_window)
plot(hasBearish2 ? resistance2Y2 : na, "Bearish 2nd Anchor 2 Price", display = display.data_window)

var string lastAlertKey = ""
string currentAlertKey = (hasBullish ? "B:" + str.tostring(supportX1) + ":" + str.tostring(supportX2) : "") + "|" + (hasBearish ? "R:" + str.tostring(resistanceX1) + ":" + str.tostring(resistanceX2) : "") + "|" + (hasHtfBullish ? "HTFB:" + str.tostring(htfSupportTime1) + ":" + str.tostring(htfSupportTime2) : "") + "|" + (hasHtfBearish ? "HTFR:" + str.tostring(htfResistanceTime1) + ":" + str.tostring(htfResistanceTime2) : "")
string currentBullishKey = hasBullish ? str.tostring(supportX1) + ":" + str.tostring(supportX2) : ""
string currentBearishKey = hasBearish ? str.tostring(resistanceX1) + ":" + str.tostring(resistanceX2) : ""
string currentHtfBullishKey = hasHtfBullish ? str.tostring(htfSupportTime1) + ":" + str.tostring(htfSupportTime2) : ""
string currentHtfBearishKey = hasHtfBearish ? str.tostring(htfResistanceTime1) + ":" + str.tostring(htfResistanceTime2) : ""
var string lastBullishKey = ""
var string lastBearishKey = ""
var string lastHtfBullishKey = ""
var string lastHtfBearishKey = ""
bool repeatWhileActive = alertMode == "Every bar close while active"
bool bullishAlertState = hasBullish and (repeatWhileActive or currentBullishKey != lastBullishKey)
bool bearishAlertState = hasBearish and (repeatWhileActive or currentBearishKey != lastBearishKey)
bool htfBullishAlertState = hasHtfBullish and (repeatWhileActive or currentHtfBullishKey != lastHtfBullishKey)
bool htfBearishAlertState = hasHtfBearish and (repeatWhileActive or currentHtfBearishKey != lastHtfBearishKey)

alertcondition(bullishAlertState and barstate.isconfirmed, "Bullish trendline exists", 'QX Adaptive Trendline: bullish support active on {{exchange}}:{{ticker}} ({{interval}}). Level={{plot("Bullish Trendline Price")}}, touches={{plot("Bullish Touch Count")}}, strength={{plot("Bullish Trendline Strength")}}/100.')
alertcondition(bearishAlertState and barstate.isconfirmed, "Bearish trendline exists", 'QX Adaptive Trendline: bearish resistance active on {{exchange}}:{{ticker}} ({{interval}}). Level={{plot("Bearish Trendline Price")}}, touches={{plot("Bearish Touch Count")}}, strength={{plot("Bearish Trendline Strength")}}/100.')
alertcondition(htfBullishAlertState and barstate.isconfirmed, "HTF bullish trendline exists", 'QX Adaptive Trendline: HTF bullish support active on {{exchange}}:{{ticker}} (chart {{interval}}; timeframe is set in the indicator inputs). Level={{plot("HTF Bullish Trendline Price")}}, touches={{plot("HTF Bullish Touch Count")}}, strength={{plot("HTF Bullish Trendline Strength")}}/100.')
alertcondition(htfBearishAlertState and barstate.isconfirmed, "HTF bearish trendline exists", 'QX Adaptive Trendline: HTF bearish resistance active on {{exchange}}:{{ticker}} (chart {{interval}}; timeframe is set in the indicator inputs). Level={{plot("HTF Bearish Trendline Price")}}, touches={{plot("HTF Bearish Touch Count")}}, strength={{plot("HTF Bearish Trendline Strength")}}/100.')
alertcondition((bullishAlertState or bearishAlertState or htfBullishAlertState or htfBearishAlertState) and barstate.isconfirmed, "Any trendline exists", 'QX Adaptive Trendline: line active on {{exchange}}:{{ticker}} ({{interval}}). Bull={{plot("Bullish Trendline Price")}}; Bear={{plot("Bearish Trendline Price")}}; HTF Bull={{plot("HTF Bullish Trendline Price")}}; HTF Bear={{plot("HTF Bearish Trendline Price")}}.')
alertcondition(strongBullishActive and barstate.isconfirmed, "Strong bullish trendline active", 'QX Adaptive Trendline: strong bullish primary trendline active on {{exchange}}:{{ticker}} ({{interval}}). Chart level={{plot("Strong Chart Bullish Level")}}; HTF level={{plot("Strong HTF Bullish Level")}}. The selected HTF is in the indicator inputs.')
alertcondition(strongBearishActive and barstate.isconfirmed, "Strong bearish trendline active", 'QX Adaptive Trendline: strong bearish primary trendline active on {{exchange}}:{{ticker}} ({{interval}}). Chart level={{plot("Strong Chart Bearish Level")}}; HTF level={{plot("Strong HTF Bearish Level")}}. The selected HTF is in the indicator inputs.')
alertcondition(strongTrendlineActive and barstate.isconfirmed, "Strong trendline active (bullish or bearish)", 'QX Adaptive Trendline: strong primary trendline active on {{exchange}}:{{ticker}} ({{interval}}). Bullish chart={{plot("Strong Chart Bullish Level")}}; bullish HTF={{plot("Strong HTF Bullish Level")}}; bearish chart={{plot("Strong Chart Bearish Level")}}; bearish HTF={{plot("Strong HTF Bearish Level")}}. The selected HTF is in the indicator inputs.')

if barstate.isconfirmed
    if hasBullish or hasBearish or hasHtfBullish or hasHtfBearish
        bool shouldSend = repeatWhileActive or currentAlertKey != lastAlertKey
        if shouldSend
            string message = "QX Adaptive Trendline | " + syminfo.tickerid + " | " + timeframe.period + " | "
            if hasBullish
                message += "BULLISH support active @ " + str.tostring(bullishLevel, format.mintick) + " (" + str.tostring(supportTouches) + " touches, strength " + str.tostring(supportStrength, "#.0") + "/100) "
            if hasBearish
                message += "BEARISH resistance active @ " + str.tostring(bearishLevel, format.mintick) + " (" + str.tostring(resistanceTouches) + " touches, strength " + str.tostring(resistanceStrength, "#.0") + "/100)"
            if hasHtfBullish
                message += " HTF " + htfTimeframe + " BULLISH support @ " + str.tostring(htfBullishLevel, format.mintick) + " (" + str.tostring(htfSupportTouches) + " touches, strength " + str.tostring(htfSupportStrength, "#.0") + "/100)"
            if hasHtfBearish
                message += " HTF " + htfTimeframe + " BEARISH resistance @ " + str.tostring(htfBearishLevel, format.mintick) + " (" + str.tostring(htfResistanceTouches) + " touches, strength " + str.tostring(htfResistanceStrength, "#.0") + "/100)"
            alert(message, alert.freq_once_per_bar_close)
    lastAlertKey := currentAlertKey
    lastBullishKey := currentBullishKey
    lastBearishKey := currentBearishKey
    lastHtfBullishKey := currentHtfBullishKey
    lastHtfBearishKey := currentHtfBearishKey
````
