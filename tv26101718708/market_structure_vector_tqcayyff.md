# Market Structure Vector 

- url: https://www.tradingview.com/script/TQcayYFF-Market-Structure-Vector/
- type: indicator
- pine_id: PUB;9ca2a7f06cf4422d9f0cc5a7c0c12fbb
- version: 1.0

## Description

Market Structure Vector is a free, open-source market structure indicator that maps confirmed swing highs, swing lows and structural breaks, with a simple two-colour directional display.

It helps answer three questions:
• What structure has price confirmed?
• Where are the current support and resistance boundaries?
• Has a closed candle broken beyond those boundaries?

HOW IT WORKS

Vector identifies pivot highs and lows using a configurable confirmation window. The default is three bars on each side, so a swing becomes known three bars after its turning point.

An alternating swing must meet a minimum distance requirement, set to 0.75 ATR(14) by default. More extreme same-side swings can update the latest endpoint while preserving the previous completed swing for comparison.

Higher highs and higher lows form bullish structure. Lower highs and lower lows form bearish structure. Disagreement or equal swing prices produce mixed structure.

The step lines begin when a swing is confirmed. They are not drawn backwards onto the original turning point.

STRUCTURE LINES AND BREAKS

The lower line uses the bullish theme colour and marks the latest accepted swing low. The upper line uses the bearish colour and marks the latest accepted swing high.

A structural break requires a candle to close beyond a buffered boundary. The default buffer is 0.10 ATR(14), frozen when the level is accepted, with a minimum of one tick. A wick through the level alone does not qualify.

Each active boundary can trigger once before being consumed. Consumed levels lose their glow. Breaks are classified as continuation, opposing or mixed according to the structure known before the break.

Existing boundaries are checked before new swings are accepted. This prevents a newly recognised pivot from erasing or reclassifying an older break on the same bar.

TWO-COLOUR CANDLE DISPLAY

In the default Directional bias mode, candles use only the selected bullish or bearish colour.

A confirmed break sets direction. New directional structure or failure of the controlling structure can also change bias. During mixed periods, the last direction is retained.

This is a simplified directional reading: bullish colouring does not necessarily mean both swing sequences currently agree. Check SWING PAIR and the panel tooltip for the underlying evidence.

Before sufficient structure exists, direction is seeded from the first valid closed candle. An initial doji seeds bullish. This initial colour is not confirmed market structure.

The optional Candle direction mode colours candles by close versus open instead.

DASHBOARD

• BIAS — current two-colour directional reading.
• SWING PAIR — confirmed high/low relationships.
• RESISTANCE / SUPPORT — buffered break thresholds.
• LAST BREAK — latest structural break classification.
• DATA / DELAY — data readiness and pivot confirmation delay.
• BIAS AGE — completed bars since the displayed bias changed.

Panel boundary values include the buffer, so they can differ slightly from the main swing lines.


ALERTS

Alerts cover continuation breaks up/down, opposing breaks, mixed breaks and structure-state changes. Dynamic alerts include confirmation time and frozen break details.

Alerts describe the underlying structure, which can remain mixed or transitional while candle colouring retains a directional bias.

USE AND LIMITATIONS

Use standard OHLC charts. Begin with data readiness, then compare directional bias, swing evidence and nearby boundaries.

Confirmation introduces delay. Larger swing widths increase that delay, and retained bias can become stale during reversals or sideways markets. Breaks can fail.

Structural calculations and default bias changes occur on closed bars. Live candle prices still move intrabar; Candle direction mode can change colour with the live close. Settings and data changes can alter recalculated results.

Vector provides structural context. It does not generate a complete trading strategy, automatic entries, stop-loss levels or profit targets, and makes no claim of predictive accuracy or profitability.

## Source Code

````pine
//@version=6
indicator("Confirmed Market Structure Map - Glassline Vector", shorttitle="Glassline Vector", overlay=true, max_lines_count=100, max_labels_count=100, max_bars_back=100, behind_chart=false, explicit_plot_zorder=true)

// Glassline Vector 1.4.1 | Free structure instrument, not a trade-entry engine.
// Engine: GMI Product Strategy (2026-10-02), F02. Visuals: user-approved neon redesign.
// v1.4: two-colour directional display; Prism saturated palettes plus Glassline.
// Swing calculations, structural events and existing alerts retain the v1.0 engine.
// Every state mutation is close-only. Rails start at knowledge time, never at the pivot origin.
// No external library, volume dependency, request.security(), scoring or order logic.

string G_MODEL = "Structure"
int width = input.int(3, "Swing width (bars each side)", minval=1, maxval=10, group=G_MODEL, tooltip="A swing becomes known this many bars after its extreme. Larger widths add delay and remove smaller turns.")
float separation = input.float(0.75, "Minimum alternating swing (ATR)", minval=0.25, maxval=3.0, step=0.05, group=G_MODEL, tooltip="Measured with ATR(14) on the confirmation bar. Rejects trivial opposite turns; not a confidence score.")
float breakBuffer = input.float(0.10, "Close-break buffer (ATR)", minval=0.0, maxval=0.5, step=0.05, group=G_MODEL, tooltip="Frozen when a distinct rail is recognised, at least one tick. A strict close beyond the boundary consumes that rail once.")
string G_VIEW = "Appearance"
string theme = input.string("Classic", "Theme", options=["Classic", "Glassline", "Crystal", "Arctic", "Aurora", "Cobalt"], group=G_VIEW)
bool halo = input.bool(true, "Neon rail glow", group=G_VIEW, tooltip="Two translucent strokes behind the crisp rail core approximate glow. Used rails lose their glow.")
bool themeCandles = input.bool(true, "Theme candles", group=G_VIEW)
int candleTransparency = input.int(35, "Candle transparency", minval=0, maxval=80, step=5, group=G_VIEW, tooltip="0 = solid; higher values are more transparent. Wick and border stay 15 points stronger than the body for readability.")
int structureTransparency = input.int(30, "Structure transparency", minval=0, maxval=80, step=5, group=G_VIEW, tooltip="0 = solid rail cores; higher values soften the structure. Glow and threshold bands fade proportionally.")
string candleBasis = input.string("Directional bias", "Candle colour basis", options=["Directional bias", "Candle direction"], group=G_VIEW, tooltip="Directional bias: two colours only. Fresh confirmed breaks or structural changes set bias; mixed periods retain it. Initial seed follows the first valid closed candle. Candle direction: close versus open, dojis retain the last non-doji direction.")
bool swingLabels = input.bool(false, "Swing audit labels", group=G_VIEW, tooltip="Labels occur on recognition bars. Tooltips disclose the earlier extreme's time and whether this is a same-side replacement.")
bool breakTags = input.bool(false, "Break audit labels", group=G_VIEW)
int historyLimit = input.int(40, "Retained drawing events", minval=10, maxval=80, group=G_VIEW, tooltip="Bounded tick and audit-label history. Older drawings retire; historical plots and event codes remain in the chart series.")
bool showPanel = input.bool(true, "Show panel", group=G_VIEW)
string panelLocation = input.string("Top right", "Panel placement", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=G_VIEW)
string panelSize = input.string("Compact", "Panel text size", options=["Compact", "Standard", "Large"], group=G_VIEW)
int panelTransparency = input.int(0, "Panel transparency", minval=0, maxval=35, group=G_VIEW)
string G_ALERT = "Dynamic alerts"
bool alertBreaks = input.bool(true, "Structural breaks", group=G_ALERT)
bool alertState = input.bool(false, "Structure state changes", group=G_ALERT, tooltip="Applies to Any alert() function call. Named alert conditions are independently selectable in TradingView.")

// Chart themes retain their directional semantics; panel shell uses Canon neutrals.
// Exact saturated directional colours from the saved Prism 2.6 source.
// Glassline is the user's retained cyan/rose pair; it is an additional theme, not a Prism alias.
color upColor = switch theme
    "Glassline" => #16DCEB
    "Crystal" => #77D9FF
    "Arctic" => #35E3FF
    "Aurora" => #5AFFC4
    "Cobalt" => #4D91FF
    => #20F58A
color downColor = switch theme
    "Glassline" => #FF527D
    "Crystal" => #9A86F7
    "Arctic" => #FF528F
    "Aurora" => #C77DFF
    "Cobalt" => #FF746C
    => #FF304F
// Prism-style Glassline chassis. Opaque by default for reliable text contrast.
color panelColor = color.new(#10151D, panelTransparency)
color panelHeader = color.new(#151C26, panelTransparency)
color panelText = #E6F1FF
color panelMuted = #98A4B3
color panelEdge = #3B4655
int panelFont = panelSize == "Large" ? 14 : panelSize == "Standard" ? 12 : 10

// Scale every structure layer's opacity together; preserve its existing hierarchy.
f_structureInk(color hue, float baseTransparency = 0) =>
    color.new(hue, 100 - (100 - baseTransparency) * (100 - structureTransparency) / 100)

type Rail
    float price = na
    float previous = na
    float buffer = na
    int originTime = na
    int knownTime = na
    bool spent = true

// A same-side extension revises only the latest endpoint, not its preceding completed swing.
// Equal-price new swings retain the old buffer/spent flag: an unchanged rail cannot re-alert.
method accept(Rail this, float candidate, bool replacement, float atr, int origin, bool upper) =>
    if not replacement
        this.previous := this.price
    bool distinctPrice = na(this.price) or candidate != this.price
    if distinctPrice
        this.buffer := math.max(syminfo.mintick, atr * breakBuffer)
        this.spent := upper ? close > candidate + this.buffer : close < candidate - this.buffer
    this.price := candidate
    this.originTime := origin
    this.knownTime := time_close

f_topology(Rail upper, Rail lower) =>
    bool complete = not na(upper.previous) and not na(lower.previous)
    int direction = not complete ? 0 : upper.price > upper.previous and lower.price > lower.previous ? 1 : upper.price < upper.previous and lower.price < lower.previous ? -1 : 0
    [complete, direction]

f_stateName(int state) =>
    switch state
        1 => "BULLISH"
        -1 => "BEARISH"
        2 => "TRANSITION / BULL"
        -2 => "TRANSITION / BEAR"
        0 => "MIXED"
        => "BUILDING"

f_breakName(int eventCode) =>
    int category = math.abs(eventCode)
    string kind = category == 1 ? "Continuation break" : category == 2 ? "Opposing structure break" : "Mixed-structure break"
    kind + (eventCode > 0 ? " UP" : " DOWN")

f_keepLabel(array<label> history, label item) =>
    array.push(history, item)
    if array.size(history) > historyLimit
        label.delete(array.shift(history))

f_keepLine(array<line> history, line item) =>
    array.push(history, item)
    if array.size(history) > historyLimit
        line.delete(array.shift(history))

f_cell(table panel, int column, int row, string value, color ink, string tip) =>
    table.cell(panel, column, row, " " + value + " ", text_color=ink, bgcolor=row == 0 ? panelHeader : panelColor, text_size=row == 0 ? panelFont + 1 : panelFont, text_halign=column == 0 ? text.align_left : text.align_right, text_formatting=column == 1 or row == 0 ? text.format_bold : text.format_none, tooltip=tip)

var Rail upper = Rail.new()
var Rail lower = Rail.new()
var int lastSide = 0
var int lastOrigin = na
var int state = 9
var int stateSince = na
var int lastInputTime = na
var int dataState = 0
var string reason = "Waiting for ATR and swings"
var string lastEvent = "No structural break"
var float lastBreakLevel = na
var float lastBreakBoundary = na
var float lastBreakDistance = na
var int lastBreakTime = na
var float confirmedAtr = na
var array<label> labels = array.new<label>()
var array<line> ticks = array.new<line>()

float atr = ta.atr(14)
float candidateHigh = ta.pivothigh(high, width, width)
float candidateLow = ta.pivotlow(low, width, width)
bool validBar = not na(open) and not na(high) and not na(low) and not na(close) and high >= math.max(open, close) and low <= math.min(open, close) and high >= low
bool eligible = chart.is_standard and validBar and not na(atr) and atr > 0 and bar_index >= width * 2
int eventCode = 0
bool stateChanged = false
bool dualPivot = false

if barstate.isconfirmed
    int oldState = state
    if eligible
        confirmedAtr := atr
        lastInputTime := time_close
        [completeBefore, topologyBefore] = f_topology(upper, lower)

        // Consume previously known rails BEFORE recognising this bar's candidates.
        // This prevents a new pivot from deleting, reclassifying or fabricating an older break.
        bool upperBreak = not na(upper.price) and not upper.spent and close > upper.price + upper.buffer
        bool lowerBreak = not na(lower.price) and not lower.spent and close < lower.price - lower.buffer
        if upperBreak
            upper.spent := true
        if lowerBreak
            lower.spent := true
        // If independently aged rails cross, a close can satisfy both tests. Consume both,
        // disclose conflict, and withhold a directional event rather than inventing priority.
        if completeBefore and upperBreak != lowerBreak
            bool upward = upperBreak
            int category = topologyBefore == 0 ? 3 : topologyBefore == (upward ? 1 : -1) ? 1 : 2
            eventCode := category * (upward ? 1 : -1)
            lastBreakLevel := upward ? upper.price : lower.price
            lastBreakBoundary := upward ? upper.price + upper.buffer : lower.price - lower.buffer
            lastBreakDistance := math.abs(close - lastBreakBoundary) / atr
            lastBreakTime := time_close
            lastEvent := f_breakName(eventCode)
            color eventColor = upward ? upColor : downColor
            f_keepLine(ticks, line.new(bar_index, lastBreakBoundary - atr * 0.12, bar_index, lastBreakBoundary + atr * 0.12, color=f_structureInk(eventColor), width=2))
            if breakTags
                string shortTag = (category == 1 ? "CB" : category == 2 ? "OB" : "MB") + (upward ? "+" : "-")
                f_keepLabel(labels, label.new(bar_index, lastBreakBoundary, shortTag, style=upward ? label.style_label_down : label.style_label_up, color=color.new(eventColor, 90), textcolor=eventColor, size=size.tiny, tooltip=lastEvent + "\nFrozen boundary: " + str.tostring(lastBreakBoundary, format.mintick) + "\nConfirmed: " + str.format_time(time_close, "yyyy-MM-dd HH:mm", "UTC") + " UTC"))

        // A bar can be both a pivot high and low. OHLC does not reveal their order.
        // Skip both, without resetting history or backfilling an imagined sequence.
        dualPivot := not na(candidateHigh) and not na(candidateLow)
        int candidateSide = dualPivot ? 0 : not na(candidateHigh) ? 1 : not na(candidateLow) ? -1 : 0
        float candidate = candidateSide == 1 ? candidateHigh : candidateLow
        int originIndex = bar_index - width
        bool replacement = candidateSide == lastSide
        bool chronological = na(lastOrigin) or originIndex > lastOrigin
        bool acceptCandidate = false
        if candidateSide != 0 and chronological
            if lastSide == 0
                acceptCandidate := true
            else if replacement
                acceptCandidate := candidateSide == 1 ? candidate > upper.price : candidate < lower.price
            else
                float legDistance = candidateSide == 1 ? candidate - lower.price : upper.price - candidate
                acceptCandidate := legDistance >= math.max(syminfo.mintick, separation * atr)
        if acceptCandidate
            Rail selected = candidateSide == 1 ? upper : lower
            selected.accept(candidate, replacement, atr, time[width], candidateSide == 1)
            lastSide := candidateSide
            lastOrigin := originIndex
            if swingLabels
                string relation = na(selected.previous) ? (candidateSide == 1 ? "H" : "L") : candidateSide == 1 ? (candidate > selected.previous ? "HH" : candidate < selected.previous ? "LH" : "EH") : (candidate > selected.previous ? "HL" : candidate < selected.previous ? "LL" : "EL")
                f_keepLabel(labels, label.new(bar_index, candidate, relation + (replacement ? "*" : ""), style=candidateSide == 1 ? label.style_label_down : label.style_label_up, color=color.new(candidateSide == 1 ? downColor : upColor, 92), textcolor=candidateSide == 1 ? downColor : upColor, size=size.tiny, tooltip="Known: " + str.format_time(time_close, "yyyy-MM-dd HH:mm", "UTC") + " UTC\nExtreme: " + str.format_time(time[width], "yyyy-MM-dd HH:mm", "UTC") + " UTC\n" + (replacement ? "Prospective same-side replacement; old records retained." : "Accepted alternating swing.")))

        [completeAfter, topologyAfter] = f_topology(upper, lower)
        state := not completeAfter ? 9 : topologyAfter == 1 ? (lower.spent ? 2 : 1) : topologyAfter == -1 ? (upper.spent ? -2 : -1) : 0
        dataState := completeAfter ? 2 : 1
        reason := not completeAfter ? "Need two highs and two lows" : state == 1 ? "HH + HL; low boundary intact" : state == -1 ? "LH + LL; high boundary intact" : state == 2 ? "Bull sequence; low boundary consumed" : state == -2 ? "Bear sequence; high boundary consumed" : "Swing sequences disagree or are equal"
        if dualPivot
            reason := "Dual pivot skipped; order unknown"
        if upperBreak and lowerBreak
            reason := "Conflicting rail breaks; event withheld"
        stateChanged := completeBefore and state != oldState
        if state != oldState or na(stateSince)
            stateSince := bar_index
    else
        dataState := 0
        reason := not chart.is_standard ? "Use standard OHLC candles" : "Missing data, flat ATR or warm-up"

    // One dynamic message per closed bar, with frozen event facts and final state together.
    bool dynamicBreak = alertBreaks and eventCode != 0
    bool dynamicState = alertState and stateChanged
    if dynamicBreak or dynamicState
        string message = "Glassline Vector | " + syminfo.tickerid + " | " + timeframe.period + " | " + str.format_time(time_close, "yyyy-MM-dd HH:mm", "UTC") + " UTC | "
        message += dynamicBreak ? lastEvent + " | level=" + str.tostring(lastBreakLevel, format.mintick) + " | boundary=" + str.tostring(lastBreakBoundary, format.mintick) + " | beyond=" + str.tostring(lastBreakDistance, "#.###") + " ATR | " : "Structure changed | "
        message += f_stateName(state) + " | " + reason
        alert(message, alert.freq_once_per_bar_close)

// Binary display, separate from the audited swing state. No neutral/transition colour.
// Only NEW evidence changes bias: a persistent transition cannot undo a later breakout.
var int binaryBias = 0
var int biasSince = na
var string biasReason = "Waiting for first valid closed candle"
var int lastCandleDirection = 0
if barstate.isconfirmed and chart.is_standard and validBar
    int priorBias = binaryBias
    if close != open
        lastCandleDirection := close > open ? 1 : -1
    if eventCode != 0
        binaryBias := eventCode > 0 ? 1 : -1
        biasReason := "Latest confirmed break " + (binaryBias == 1 ? "UP" : "DOWN")
    else if stateChanged and math.abs(state) == 1
        binaryBias := state
        biasReason := "Newly confirmed " + (binaryBias == 1 ? "HH + HL" : "LH + LL")
    else if stateChanged and math.abs(state) == 2
        binaryBias := state == 2 ? -1 : 1
        biasReason := "New structure failure favours " + (binaryBias == 1 ? "UP" : "DOWN")
    else if binaryBias == 0 or (dataState == 2 and dataState[1] != 2 and math.abs(state) == 1)
        binaryBias := dataState == 2 and math.abs(state) == 1 ? state : close >= open ? 1 : -1
        biasReason := dataState == 2 and math.abs(state) == 1 ? "First complete directional structure" : "Initial candle seed; no confirmed structure yet"
    if binaryBias != priorBias or na(biasSince)
        biasSince := bar_index

bool visible = dataState > 0
color biasInk = binaryBias == -1 ? downColor : upColor
// The normal chart background stays under the user's TradingView settings.
float upperPrice = visible ? upper.price : na
float lowerPrice = visible ? lower.price : na
// Resistance always uses the bearish theme; support always uses the bullish theme.
// Two glow shells preserve sharp geometry. Consumption removes glow, keeping the core hue.
plot(halo and not upper.spent ? upperPrice : na, "Resistance outer glow", f_structureInk(downColor, 94), 9, plot.style_stepline, display=display.pane)
plot(halo and not lower.spent ? lowerPrice : na, "Support outer glow", f_structureInk(upColor, 94), 9, plot.style_stepline, display=display.pane)
plot(halo and not upper.spent ? upperPrice : na, "Resistance inner glow", f_structureInk(downColor, 82), 5, plot.style_stepline, display=display.pane)
plot(halo and not lower.spent ? lowerPrice : na, "Support inner glow", f_structureInk(upColor, 82), 5, plot.style_stepline, display=display.pane)
upperPlot = plot(upperPrice, "Known swing high", f_structureInk(downColor), 2, plot.style_stepline, display=display.pane)
lowerPlot = plot(lowerPrice, "Known swing low", f_structureInk(upColor), 2, plot.style_stepline, display=display.pane)
upperEdge = plot(visible and not upper.spent ? upper.price + upper.buffer : na, "Upper buffered boundary", f_structureInk(downColor, 65), 1, plot.style_stepline, display=display.pane)
lowerEdge = plot(visible and not lower.spent ? lower.price - lower.buffer : na, "Lower buffered boundary", f_structureInk(upColor, 65), 1, plot.style_stepline, display=display.pane)
fill(upperPlot, upperEdge, f_structureInk(downColor, 91), title="Upper break threshold band", fillgaps=false)
fill(lowerPlot, lowerEdge, f_structureInk(upColor, 91), title="Lower break threshold band", fillgaps=false)

bool paintCandles = themeCandles and chart.is_standard and validBar and binaryBias != 0
int liveCandleDirection = close > open ? 1 : close < open ? -1 : lastCandleDirection != 0 ? lastCandleDirection : binaryBias
color candleInk = candleBasis == "Directional bias" ? biasInk : liveCandleDirection == -1 ? downColor : upColor
// Same directional hue with adjustable alpha; edges remain slightly stronger than bodies.
barcolor(paintCandles ? color.new(candleInk, 100) : na, title="Hide native bars when themed")
plotcandle(paintCandles ? open : na, paintCandles ? high : na, paintCandles ? low : na, paintCandles ? close : na, title="Glassline theme candles", color=color.new(candleInk, candleTransparency), wickcolor=color.new(candleInk, math.max(0, candleTransparency - 15)), bordercolor=color.new(candleInk, math.max(0, candleTransparency - 15)), editable=false, display=display.pane)

// Numeric audit series preserve history beyond the bounded drawing queue.
plot(dataState, "Data: 0 unavailable / 1 limited / 2 ready", display=display.data_window)
plot(dataState == 2 ? state : na, "State: 1 bull / -1 bear / +/-2 transition / 0 mixed", display=display.data_window)
plot(barstate.isconfirmed ? eventCode : 0, "Event: +/-1 continuation / +/-2 opposing / +/-3 mixed", display=display.data_window)
plot(eventCode != 0 ? lastBreakLevel : na, "Event frozen level", display=display.data_window)
plot(eventCode != 0 ? lastBreakBoundary : na, "Event frozen boundary", display=display.data_window)
plot(eventCode != 0 ? lastBreakDistance : na, "Event distance beyond boundary (ATR)", display=display.data_window)
plot(visible ? confirmedAtr : na, "Confirmed ATR(14)", display=display.data_window)
plot(visible ? upper.previous : na, "Previous completed high", display=display.data_window)
plot(visible ? lower.previous : na, "Previous completed low", display=display.data_window)
plot(visible and upper.spent ? 1 : 0, "High boundary consumed", display=display.data_window)
plot(visible and lower.spent ? 1 : 0, "Low boundary consumed", display=display.data_window)
plot(lastInputTime, "Last valid closed input (UNIX ms)", display=display.data_window)
plot(binaryBias, "Display bias: 1 bullish / -1 bearish / 0 unseeded", display=display.data_window)
plot(visible ? upper.originTime : na, "High extreme time (UNIX ms)", display=display.data_window)
plot(visible ? upper.knownTime : na, "High recognition close (UNIX ms)", display=display.data_window)
plot(visible ? lower.originTime : na, "Low extreme time (UNIX ms)", display=display.data_window)
plot(visible ? lower.knownTime : na, "Low recognition close (UNIX ms)", display=display.data_window)

string positionValue = switch panelLocation
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right
// Compact 2 x 8 Prism-style panel. Quiet shell, aligned values, semantic colour.
// Explanations and full timestamps remain available on hover and in the Data Window.
var table dashboard = table.new(positionValue, 2, 8, frame_color=panelEdge, frame_width=1, border_width=0)
if barstate.islast
    if showPanel
        string stateText = binaryBias == 0 ? "WAIT" : binaryBias == 1 ? "BULLISH" : "BEARISH"
        string highText = na(upper.price) or dataState == 0 ? "--" : str.tostring(upper.price + upper.buffer, format.mintick) + (upper.spent ? " / USED" : "")
        string lowText = na(lower.price) or dataState == 0 ? "--" : str.tostring(lower.price - lower.buffer, format.mintick) + (lower.spent ? " / USED" : "")
        int closedIndex = barstate.isconfirmed ? bar_index : bar_index - 1
        string ageText = dataState == 0 or na(biasSince) ? "--" : str.tostring(math.max(0, closedIndex - biasSince)) + " BARS"
        string closeStamp = na(lastInputTime) ? "No valid closed input" : str.format_time(lastInputTime, "yyyy-MM-dd HH:mm", "UTC") + " UTC"
        string dataText = (dataState == 2 ? "READY" : dataState == 1 ? "LIMITED" : "UNAVAILABLE") + " / " + str.tostring(width) + "-BAR"
        string visualReason = biasReason + "\nSwing state: " + (dataState == 0 ? "UNAVAILABLE" : f_stateName(state)) + "\n" + reason + "\nMixed periods retain the last bias; candle colour is not a confirmed swing claim."
        string highRelation = upper.price > upper.previous ? "HH" : upper.price < upper.previous ? "LH" : "EH"
        string lowRelation = lower.price > lower.previous ? "HL" : lower.price < lower.previous ? "LL" : "EL"
        string evidenceText = dataState == 2 ? highRelation + " + " + lowRelation : "INCOMPLETE"
        string eventText = lastEvent == "No structural break" ? "NONE" : str.contains(lastEvent, "Opposing") ? "OPPOSING" : str.contains(lastEvent, "Mixed") ? "MIXED BREAK" : "CONTINUATION"
        eventText += lastEvent == "No structural break" ? "" : str.contains(lastEvent, "UP") ? " UP" : " DOWN"
        string eventTip = lastEvent + (na(lastBreakTime) ? "" : "\n" + str.format_time(lastBreakTime, "yyyy-MM-dd HH:mm", "UTC") + " UTC")
        color lastEventInk = lastEvent == "No structural break" ? panelMuted : str.contains(lastEvent, "UP") ? upColor : downColor
        // Quiet table labels remain neutral; all directional values use one of the two hues.
        color panelStateInk = biasInk
        f_cell(dashboard, 0, 0, "GLASSLINE", panelText, "Confirmed Market Structure Map - Glassline Vector")
        f_cell(dashboard, 1, 0, "VECTOR 1.4.1", panelMuted, syminfo.tickerid + " / " + timeframe.period)
        f_cell(dashboard, 0, 1, "BIAS", panelMuted, visualReason)
        f_cell(dashboard, 1, 1, stateText, panelStateInk, visualReason)
        f_cell(dashboard, 0, 2, "SWING PAIR", panelMuted, "Latest two accepted highs and lows; the original confirmed topology.")
        f_cell(dashboard, 1, 2, evidenceText, panelText, reason)
        string highTip = "Upper buffered break boundary. Requires a strict close ABOVE.\n" + (upper.spent ? "Consumed; will not alert again for this active rail." : "Unconsumed.")
        string lowTip = "Lower buffered break boundary. Requires a strict close BELOW.\n" + (lower.spent ? "Consumed; will not alert again for this active rail." : "Unconsumed.")
        f_cell(dashboard, 0, 3, "RESISTANCE", panelMuted, highTip)
        f_cell(dashboard, 1, 3, highText, panelText, highTip)
        f_cell(dashboard, 0, 4, "SUPPORT", panelMuted, lowTip)
        f_cell(dashboard, 1, 4, lowText, panelText, lowTip)
        f_cell(dashboard, 0, 5, "LAST BREAK", panelMuted, eventTip)
        f_cell(dashboard, 1, 5, eventText, lastEventInk, eventTip)
        f_cell(dashboard, 0, 6, "DATA / DELAY", panelMuted, "Last valid closed input: " + closeStamp + "\nPivot recognition delay: " + str.tostring(width) + " chart bars.")
        f_cell(dashboard, 1, 6, dataText, panelText, "Last valid closed input: " + closeStamp)
        f_cell(dashboard, 0, 7, "BIAS AGE", panelMuted, "Completed chart bars since the binary bias last changed.")
        f_cell(dashboard, 1, 7, ageText, panelText, visualReason)
    else
        table.clear(dashboard, 0, 0, 1, 7)

alertcondition(eventCode == 1, "Vector: Structure - Continuation UP", "Glassline Vector | {{ticker}} | {{interval}} | Confirmed continuation break UP; see frozen event boundary in Data Window.")
alertcondition(eventCode == -1, "Vector: Structure - Continuation DOWN", "Glassline Vector | {{ticker}} | {{interval}} | Confirmed continuation break DOWN; see frozen event boundary in Data Window.")
alertcondition(eventCode == 2 or eventCode == -2, "Vector: Structure - Opposing break", "Glassline Vector | {{ticker}} | {{interval}} | Confirmed opposing structure break. This does not establish a complete reversal.")
alertcondition(eventCode == 3 or eventCode == -3, "Vector: Structure - Mixed break", "Glassline Vector | {{ticker}} | {{interval}} | Confirmed break from mixed swing structure; no directional sequence agreement.")
alertcondition(stateChanged, "Vector: Structure - State changed", "Glassline Vector | {{ticker}} | {{interval}} | Confirmed structure state changed; inspect current state and reason.")
````
