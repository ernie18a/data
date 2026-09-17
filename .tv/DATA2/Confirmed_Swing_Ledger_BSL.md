<!-- tradingview-pine-id: PUB;7c10755876d24b81a634c529b85f62ee -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# Confirmed Swing Ledger [BSL]

Source: https://www.tradingview.com/script/GXcd6hp5-Confirmed-Swing-Ledger-BSL/

## Description

Confirmed Swing Ledger [BSL] is a confirmation-aware market-structure ledger
for studying how swings become known in real time.

WHAT IT DOES

- Detects pivot highs and lows only after the configured right-side
  confirmation window has closed.
- Separates the pivot's historical origin bar from the later confirmation bar.
  Confirmation markers are the default; optional hollow origin dots are
  retrospective and clearly labelled.
- Maintains an alternating ledger of accepted highs and lows, classifying them
  as HH/LH and HL/LL.
- Applies an optional ATR-distance filter to reduce near-duplicate swings.
  Same-side candidates may replace an existing extreme without inventing a new
  alternating swing.
- Tracks the latest confirmed upper and lower levels.
- Distinguishes strict close breaks from wick rejections. A break requires the
  close to cross a known confirmed level; a wick through the level that closes
  back inside is counted separately.
- Freezes state on non-standard chart types instead of presenting synthetic
  bars as ordinary OHLC evidence.
- Exposes hidden numeric streams for confirmed swings, level updates, breaks,
  rejections, dual rejections and bias. These are selectable sources in Signal
  Audit Lab [BSL].
- Includes alert conditions for accepted swings, confirmed-level close breaks
  and confirmed-level wick rejections.

TIMING MODEL

With the default 3/3 left/right settings, a candidate that originates at bar
`t` can only become a usable event at `t + 3`. The script never relocates a
tradeable event back to the origin bar. Optional origin dots are visual
context, not realtime signals.

DEFAULTS

- Pivot left/right: 3 / 3
- ATR length: 14
- Minimum alternating swing distance: 0.5 ATR
- Panel: Compact

DESIGNED FOR AUDITABILITY

The panel reports current confirmed levels, classification, structural bias,
accepted/replaced/filter/ambiguity counts, break/rejection totals, chart-type
guard status and open-bar hold state. Historical state changes occur only on
confirmed bars.

This tool describes confirmed structure; it does not predict future price,
guarantee performance or provide trading advice. Validate behavior on your own
symbols, timeframes and execution assumptions before making decisions.

Open-source Pine Script® v6. Educational use only.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © BarState Labs
//@version=6
indicator("Confirmed Swing Ledger [BSL]", shorttitle = "BSL Swing Ledger", overlay = true, max_bars_back = 150)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_PIVOT = "01 · Confirm pivots"
string GROUP_FILTER = "02 · Filter swings"
string GROUP_DISPLAY = "03 · Display"

int leftBars = input.int(3, "Bars before pivot", minval = 1, maxval = 20, group = GROUP_PIVOT,
     tooltip = "Requires this many earlier bars on the pivot's left side. With the 3/3 default, an event prints three closed bars after its pivot origin.")
int rightBars = input.int(3, "Bars to confirm pivot", minval = 1, maxval = 20, group = GROUP_PIVOT,
     tooltip = "A pivot becomes knowable only after this many later bars close. Labels print on that confirmation bar, never back on the origin.")
int atrLength = input.int(14, "ATR filter length", minval = 2, maxval = 100, group = GROUP_FILTER)
float minimumSwingAtr = input.float(0.50, "Minimum opposite swing, ATR", minval = 0.0,
     maxval = 10.0, step = 0.05, group = GROUP_FILTER,
     tooltip = "Rejects alternating swings closer than 0.50 ATR. Same-side extremes may still replace the current ledger level.")

bool showLevels = input.bool(true, "Show confirmed levels", group = GROUP_DISPLAY)
bool showSwingLabels = input.bool(true, "Show swing labels (HH/LH/HL/LL)", group = GROUP_DISPLAY,
     tooltip = "Core confirmed-structure labels. They print on the confirmation bar, not retrospectively on the pivot origin.")
bool showStructureMarkers = input.bool(false, "Show break/rejection markers", group = GROUP_DISPLAY,
     tooltip = "Optional high-frequency B/X markers. Keep these off for a cleaner default chart.")
bool showOrigins = input.bool(false, "Show retrospective origins", group = GROUP_DISPLAY,
     tooltip = "Visual only. Origin dots are drawn into the past after confirmation and never feed events or alerts.")
string panelDensity = input.string("Compact", "Panel detail", options = ["Compact", "Full"], group = GROUP_DISPLAY,
     tooltip = "Compact preserves price space. Full adds separate break/rejection rows, origin index, last swing distance and bars since break.")
string panelPositionInput = input.string("Auto", "Panel position", options = ["Auto", "Top right", "Bottom right"],
     group = GROUP_DISPLAY, tooltip = "Auto keeps the panel opposite the latest price within the visible chart range.")

// ─────────────────────────────────────────────────────────────────────────────
// Palette and helpers
// ─────────────────────────────────────────────────────────────────────────────
color COLOR_BG = color.rgb(11, 14, 13)
color COLOR_TEXT = color.rgb(242, 239, 232)
color COLOR_MUTED = color.rgb(156, 161, 154)
color COLOR_GREEN = color.rgb(82, 211, 151)
color COLOR_RED = color.rgb(239, 107, 107)
color COLOR_AMBER = color.rgb(235, 184, 87)
color COLOR_BLUE = color.rgb(104, 167, 255)
color COLOR_UPPER = color.rgb(239, 107, 107)
color COLOR_LOWER = color.rgb(82, 211, 151)

int UPPER = -1
int LOWER = 1

f_class(float value, float previous) =>
    int result = na
    if not na(previous)
        result := value > previous ? 1 : value < previous ? -1 : 0
    result

f_upper_class(int code) =>
    na(code) ? "FIRST" : code > 0 ? "HH" : code < 0 ? "LH" : "EH"

f_lower_class(int code) =>
    na(code) ? "FIRST" : code > 0 ? "HL" : code < 0 ? "LL" : "EL"

f_price(float value) =>
    na(value) ? "N/A" : str.tostring(value, format.mintick)

f_number(float value, string formatString) =>
    na(value) ? "N/A" : str.tostring(value, formatString)

f_bias(int value) =>
    value > 0 ? "UP BREAK" : value < 0 ? "DOWN BREAK" : "UNSET"

// ─────────────────────────────────────────────────────────────────────────────
// Candidate detection and committed state
// ─────────────────────────────────────────────────────────────────────────────
bool configValid = leftBars >= 1 and leftBars <= 20 and rightBars >= 1 and rightBars <= 20 and
     atrLength >= 2 and atrLength <= 100 and minimumSwingAtr >= 0.0 and minimumSwingAtr <= 10.0
bool standardChart = chart.is_standard
float atr = ta.atr(atrLength)
float pivotHigh = ta.pivothigh(high, leftBars, rightBars)
float pivotLow = ta.pivotlow(low, leftBars, rightBars)
float originAtr = atr[rightBars]
bool calculationReady = not na(originAtr) and originAtr > 0.0

var int pivotType = 0
var float pivotPrice = na
var int pivotOriginIndex = na

var float upperLevel = na
var float previousUpper = na
var int upperClass = na
var float lowerLevel = na
var float previousLower = na
var int lowerClass = na

var int alternatingSwings = 0
var int replacementCount = 0
var int distanceRejected = 0
var int ambiguousCandidates = 0
var int upBreakCount = 0
var int downBreakCount = 0
var int upperRejectionCount = 0
var int lowerRejectionCount = 0
var int dualRejectionCount = 0
var int structureBias = 0
var int lastBreakIndex = na
var float lastDistanceAtr = na

int swingEvent = 0
int levelUpdate = 0
int breakEvent = 0
int rejectionEvent = 0
int dualRejection = 0
bool acceptedUpper = false
bool acceptedLower = false
bool replacedUpper = false
bool replacedLower = false

if barstate.isconfirmed and configValid and standardChart
    // Known-level events are evaluated before this bar's pivot candidate can
    // update a level. This prevents retrospective same-bar break creation.
    bool upBreak = not na(upperLevel) and close > upperLevel and close[1] <= upperLevel
    bool downBreak = not na(lowerLevel) and close < lowerLevel and close[1] >= lowerLevel

    if upBreak
        upBreakCount += 1
        structureBias := 1
        lastBreakIndex := bar_index
        breakEvent := 1
    else if downBreak
        downBreakCount += 1
        structureBias := -1
        lastBreakIndex := bar_index
        breakEvent := -1

    bool upperRejection = not na(upperLevel) and not upBreak and high > upperLevel and close <= upperLevel
    bool lowerRejection = not na(lowerLevel) and not downBreak and low < lowerLevel and close >= lowerLevel
    if upperRejection
        upperRejectionCount += 1
    if lowerRejection
        lowerRejectionCount += 1
    if upperRejection and lowerRejection
        dualRejectionCount += 1
        dualRejection := 1
    else if upperRejection
        rejectionEvent := -1
    else if lowerRejection
        rejectionEvent := 1

    bool readyHigh = not na(pivotHigh) and calculationReady
    bool readyLow = not na(pivotLow) and calculationReady

    if readyHigh and readyLow
        ambiguousCandidates += 1
    else if readyHigh or readyLow
        int candidateType = readyHigh ? UPPER : LOWER
        float candidatePrice = readyHigh ? pivotHigh : pivotLow
        int candidateOrigin = bar_index - rightBars

        if pivotType == 0
            if candidateType == UPPER
                previousUpper := upperLevel
                upperLevel := candidatePrice
                upperClass := f_class(candidatePrice, previousUpper)
                acceptedUpper := true
            else
                previousLower := lowerLevel
                lowerLevel := candidatePrice
                lowerClass := f_class(candidatePrice, previousLower)
                acceptedLower := true
            pivotType := candidateType
            pivotPrice := candidatePrice
            pivotOriginIndex := candidateOrigin
            alternatingSwings += 1
            swingEvent := candidateType
        else if candidateType == pivotType
            bool moreExtreme = candidateType == UPPER ? candidatePrice > pivotPrice : candidatePrice < pivotPrice
            if moreExtreme
                if candidateType == UPPER
                    upperLevel := candidatePrice
                    upperClass := f_class(candidatePrice, previousUpper)
                    replacedUpper := true
                else
                    lowerLevel := candidatePrice
                    lowerClass := f_class(candidatePrice, previousLower)
                    replacedLower := true
                pivotPrice := candidatePrice
                pivotOriginIndex := candidateOrigin
                replacementCount += 1
                levelUpdate := candidateType
        else
            float distance = math.abs(candidatePrice - pivotPrice)
            float threshold = minimumSwingAtr * originAtr
            if distance >= threshold
                if candidateType == UPPER
                    previousUpper := upperLevel
                    upperLevel := candidatePrice
                    upperClass := f_class(candidatePrice, previousUpper)
                    acceptedUpper := true
                else
                    previousLower := lowerLevel
                    lowerLevel := candidatePrice
                    lowerClass := f_class(candidatePrice, previousLower)
                    acceptedLower := true
                pivotType := candidateType
                pivotPrice := candidatePrice
                pivotOriginIndex := candidateOrigin
                alternatingSwings += 1
                lastDistanceAtr := distance / originAtr
                swingEvent := candidateType
            else
                distanceRejected += 1

bool upperAction = acceptedUpper or replacedUpper
bool lowerAction = acceptedLower or replacedLower
bool swingAccepted = swingEvent != 0
bool closeBreak = breakEvent != 0
bool wickRejection = rejectionEvent != 0 or dualRejection == 1

// ─────────────────────────────────────────────────────────────────────────────
// Visual and machine-readable outputs
// ─────────────────────────────────────────────────────────────────────────────
plot(showLevels ? upperLevel : na, "Confirmed upper level", color = color.new(COLOR_UPPER, 10),
     linewidth = 2, style = plot.style_stepline)
plot(showLevels ? lowerLevel : na, "Confirmed lower level", color = color.new(COLOR_LOWER, 10),
     linewidth = 2, style = plot.style_stepline)

plotshape(showSwingLabels and upperAction and na(upperClass), title = "Upper confirmation FIRST",
     style = shape.labeldown, location = location.abovebar, color = color.new(COLOR_UPPER, 15),
     textcolor = COLOR_TEXT, text = "H", size = size.tiny)
plotshape(showSwingLabels and upperAction and upperClass == 1, title = "Upper confirmation HH",
     style = shape.labeldown, location = location.abovebar, color = color.new(COLOR_UPPER, 15),
     textcolor = COLOR_TEXT, text = "HH", size = size.tiny)
plotshape(showSwingLabels and upperAction and upperClass == -1, title = "Upper confirmation LH",
     style = shape.labeldown, location = location.abovebar, color = color.new(COLOR_UPPER, 15),
     textcolor = COLOR_TEXT, text = "LH", size = size.tiny)
plotshape(showSwingLabels and upperAction and upperClass == 0, title = "Upper confirmation EH",
     style = shape.labeldown, location = location.abovebar, color = color.new(COLOR_UPPER, 15),
     textcolor = COLOR_TEXT, text = "EH", size = size.tiny)

plotshape(showSwingLabels and lowerAction and na(lowerClass), title = "Lower confirmation FIRST",
     style = shape.labelup, location = location.belowbar, color = color.new(COLOR_LOWER, 15),
     textcolor = COLOR_BG, text = "L", size = size.tiny)
plotshape(showSwingLabels and lowerAction and lowerClass == 1, title = "Lower confirmation HL",
     style = shape.labelup, location = location.belowbar, color = color.new(COLOR_LOWER, 15),
     textcolor = COLOR_BG, text = "HL", size = size.tiny)
plotshape(showSwingLabels and lowerAction and lowerClass == -1, title = "Lower confirmation LL",
     style = shape.labelup, location = location.belowbar, color = color.new(COLOR_LOWER, 15),
     textcolor = COLOR_BG, text = "LL", size = size.tiny)
plotshape(showSwingLabels and lowerAction and lowerClass == 0, title = "Lower confirmation EL",
     style = shape.labelup, location = location.belowbar, color = color.new(COLOR_LOWER, 15),
     textcolor = COLOR_BG, text = "EL", size = size.tiny)

plotshape(showOrigins and upperAction ? pivotHigh : na, title = "Retrospective upper origin",
     style = shape.circle, location = location.absolute, offset = -rightBars,
     color = color.new(COLOR_UPPER, 35), size = size.tiny)
plotshape(showOrigins and lowerAction ? pivotLow : na, title = "Retrospective lower origin",
     style = shape.circle, location = location.absolute, offset = -rightBars,
     color = color.new(COLOR_LOWER, 35), size = size.tiny)

plotshape(showStructureMarkers and breakEvent == 1, title = "Up close break marker", style = shape.triangleup,
     location = location.belowbar, color = COLOR_GREEN, text = "B", textcolor = COLOR_BG, size = size.tiny)
plotshape(showStructureMarkers and breakEvent == -1, title = "Down close break marker", style = shape.triangledown,
     location = location.abovebar, color = COLOR_RED, text = "B", textcolor = COLOR_TEXT, size = size.tiny)
plotshape(showStructureMarkers and rejectionEvent == -1, title = "Upper wick rejection marker", style = shape.xcross,
     location = location.abovebar, color = COLOR_AMBER, size = size.tiny)
plotshape(showStructureMarkers and rejectionEvent == 1, title = "Lower wick rejection marker", style = shape.xcross,
     location = location.belowbar, color = COLOR_AMBER, size = size.tiny)
plotshape(showStructureMarkers and dualRejection == 1, title = "Dual wick rejection marker", style = shape.diamond,
     location = location.top, color = COLOR_AMBER, text = "2", textcolor = COLOR_BG, size = size.tiny)

color biasBackground = structureBias > 0 ? color.new(COLOR_GREEN, 94) : structureBias < 0 ? color.new(COLOR_RED, 94) : na
bgcolor(biasBackground, title = "Post-break structure bias")

plot(float(swingEvent), "Confirmed swing event", display = display.none)
plot(float(levelUpdate), "Confirmed level update", display = display.none)
plot(float(breakEvent), "Confirmed break event", display = display.none)
plot(float(rejectionEvent), "Confirmed rejection event", display = display.none)
plot(float(dualRejection), "Dual rejection", display = display.none)
plot(float(structureBias), "Structure bias", display = display.none)

alertcondition(swingAccepted, "Confirmed swing accepted",
     "Confirmed Swing Ledger accepted a new swing on the closed confirmation bar.")
alertcondition(closeBreak, "Confirmed level close break",
     "Confirmed Swing Ledger recorded a strict close break of a previously known level.")
alertcondition(wickRejection, "Confirmed level wick rejection",
     "Confirmed Swing Ledger recorded a wick beyond a known level with the close back inside.")

// ─────────────────────────────────────────────────────────────────────────────
// Evidence panel
// ─────────────────────────────────────────────────────────────────────────────
int panelRows = panelDensity == "Full" ? 15 : 9
bool inVisibleWindow = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
var float visibleWindowHigh = na
var float visibleWindowLow = na
var float visibleWindowRightClose = na
if inVisibleWindow
    visibleWindowHigh := na(visibleWindowHigh) ? high : math.max(visibleWindowHigh, high)
    visibleWindowLow := na(visibleWindowLow) ? low : math.min(visibleWindowLow, low)
    visibleWindowRightClose := close

float visibleWindowMid = not na(visibleWindowHigh) and not na(visibleWindowLow) ?
     (visibleWindowHigh + visibleWindowLow) / 2.0 : na
string automaticPanelPosition = not na(visibleWindowMid) and visibleWindowRightClose > visibleWindowMid ?
     position.bottom_right : position.top_right
string resolvedPanelPosition = panelPositionInput == "Top right" ? position.top_right :
     panelPositionInput == "Bottom right" ? position.bottom_right : automaticPanelPosition

var table panel = table.new(position.top_right, 2, panelRows, bgcolor = color.new(COLOR_BG, 3),
     border_color = color.new(COLOR_MUTED, 65), border_width = 1)

if barstate.islast
    table.set_position(panel, resolvedPanelPosition)
    bool fullPanel = panelDensity == "Full"
    string status = "OPEN BAR · HELD"
    if not configValid
        status := "CONFIG ERROR"
    else if not standardChart
        status := "NON-STANDARD · FROZEN"
    else if not calculationReady
        status := "WARM-UP"
    else if barstate.isconfirmed
        status := "CONFIRMED"
    color statusColor = not configValid or not standardChart ? COLOR_RED :
         not calculationReady or not barstate.isconfirmed ? COLOR_AMBER : COLOR_GREEN
    string upperText = f_price(upperLevel) + " · " + f_upper_class(upperClass)
    string lowerText = f_price(lowerLevel) + " · " + f_lower_class(lowerClass)
    string breakText = str.tostring(upBreakCount) + " UP / " + str.tostring(downBreakCount) + " DN"
    string rejectionText = str.tostring(upperRejectionCount) + " U / " + str.tostring(lowerRejectionCount) + " L"

    table.cell(panel, 0, 0, "BSL / SWING LEDGER", text_color = COLOR_TEXT,
         bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small)
    table.cell(panel, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = COLOR_MUTED,
         bgcolor = color.new(COLOR_BLUE, 70), text_size = size.small)

    if fullPanel
        table.cell(panel, 0, 1, "STATUS", text_color = COLOR_MUTED)
        table.cell(panel, 1, 1, status, text_color = statusColor)
        table.cell(panel, 0, 2, "TIMING", text_color = COLOR_MUTED)
        table.cell(panel, 1, 2, "ORIGIN → CONFIRM +" + str.tostring(rightBars) + "B", text_color = COLOR_AMBER)
        table.cell(panel, 0, 3, "UPPER", text_color = COLOR_MUTED)
        table.cell(panel, 1, 3, upperText, text_color = COLOR_UPPER)
        table.cell(panel, 0, 4, "LOWER", text_color = COLOR_MUTED)
        table.cell(panel, 1, 4, lowerText, text_color = COLOR_LOWER)
        table.cell(panel, 0, 5, "BIAS", text_color = COLOR_MUTED)
        table.cell(panel, 1, 5, f_bias(structureBias), text_color = structureBias > 0 ? COLOR_GREEN : structureBias < 0 ? COLOR_RED : COLOR_MUTED)
        table.cell(panel, 0, 6, "SWINGS · REPL", text_color = COLOR_MUTED)
        table.cell(panel, 1, 6, str.tostring(alternatingSwings) + " · " + str.tostring(replacementCount), text_color = COLOR_TEXT)
        table.cell(panel, 0, 7, "FILTERED · AMBIG", text_color = COLOR_MUTED)
        table.cell(panel, 1, 7, str.tostring(distanceRejected) + " · " + str.tostring(ambiguousCandidates), text_color = COLOR_TEXT)
        table.cell(panel, 0, 8, "BREAKS", text_color = COLOR_MUTED)
        table.cell(panel, 1, 8, breakText, text_color = COLOR_TEXT)
        table.cell(panel, 0, 9, "REJECTIONS", text_color = COLOR_MUTED)
        table.cell(panel, 1, 9, rejectionText, text_color = COLOR_TEXT)
        table.cell(panel, 0, 10, "DUAL REJECT", text_color = COLOR_MUTED)
        table.cell(panel, 1, 10, str.tostring(dualRejectionCount), text_color = dualRejectionCount > 0 ? COLOR_AMBER : COLOR_TEXT)
        table.cell(panel, 0, 11, "PIVOT ORIGIN", text_color = COLOR_MUTED)
        table.cell(panel, 1, 11, na(pivotOriginIndex) ? "N/A" : "BAR #" + str.tostring(pivotOriginIndex), text_color = COLOR_TEXT)
        table.cell(panel, 0, 12, "LAST DIST", text_color = COLOR_MUTED)
        table.cell(panel, 1, 12, f_number(lastDistanceAtr, "#.00") + " ATR", text_color = COLOR_TEXT)
        table.cell(panel, 0, 13, "BARS SINCE BREAK", text_color = COLOR_MUTED)
        table.cell(panel, 1, 13, na(lastBreakIndex) ? "N/A" : str.tostring(bar_index - lastBreakIndex), text_color = COLOR_TEXT)
    else
        table.cell(panel, 0, 1, "STATUS · TIMING", text_color = COLOR_MUTED)
        table.cell(panel, 1, 1, status + " · +" + str.tostring(rightBars) + "B", text_color = statusColor)
        table.cell(panel, 0, 2, "UPPER", text_color = COLOR_MUTED)
        table.cell(panel, 1, 2, upperText, text_color = COLOR_UPPER)
        table.cell(panel, 0, 3, "LOWER", text_color = COLOR_MUTED)
        table.cell(panel, 1, 3, lowerText, text_color = COLOR_LOWER)
        table.cell(panel, 0, 4, "BIAS", text_color = COLOR_MUTED)
        table.cell(panel, 1, 4, f_bias(structureBias), text_color = structureBias > 0 ? COLOR_GREEN : structureBias < 0 ? COLOR_RED : COLOR_MUTED)
        table.cell(panel, 0, 5, "SWINGS · REPL", text_color = COLOR_MUTED)
        table.cell(panel, 1, 5, str.tostring(alternatingSwings) + " · " + str.tostring(replacementCount), text_color = COLOR_TEXT)
        table.cell(panel, 0, 6, "FILTER · AMBIG", text_color = COLOR_MUTED)
        table.cell(panel, 1, 6, str.tostring(distanceRejected) + " · " + str.tostring(ambiguousCandidates), text_color = COLOR_TEXT)
        table.cell(panel, 0, 7, "BREAK · REJECT", text_color = COLOR_MUTED)
        table.cell(panel, 1, 7, breakText + " · " + rejectionText, text_color = COLOR_TEXT)

    int footerRow = fullPanel ? 14 : 8
    table.cell(panel, 0, footerRow, "ORIGINS ARE RETROSPECTIVE", text_color = COLOR_MUTED,
         bgcolor = color.new(COLOR_BG, 0), text_size = size.tiny)
    table.cell(panel, 1, footerRow, "EVENTS COMMIT AT CONFIRMATION", text_color = COLOR_AMBER,
         bgcolor = color.new(COLOR_BG, 0), text_size = size.tiny)
````
