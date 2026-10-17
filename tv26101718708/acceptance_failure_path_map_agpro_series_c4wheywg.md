# Acceptance Failure Path Map [AGPro Series]

- url: https://www.tradingview.com/script/C4WHEYwg-Acceptance-Failure-Path-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;3642de0ad5544da188fd978c34e89e20
- version: 4.0

## Description

Acceptance Failure Path Map [AGPro Series]

🧠 Core Idea

Did price truly accept beyond a market boundary, or did that acceptance fail and create a new reaction path?


📌 Overview / What it does

Acceptance Failure Path Map [AGPro Series] is a market-structure visualization tool designed to study acceptance, failed acceptance, reclaim attempts, and continuation behavior around a defined reference range.

The script maps an acceptance band, detects whether price holds above or below that band, and highlights when accepted price fails back through the boundary. It produces compact labels, a centered path zone, right-side state tags, and an AG Pro panel that summarizes the current acceptance context.

It does not predict price direction, automate decisions, or claim that any acceptance event must continue. Its purpose is to make acceptance quality easier to read.


🎯 Purpose & Design Philosophy

This script was built for traders who want to understand whether a move is being accepted by the market or rejected after a temporary push beyond structure.

Many breakout tools mark only the breakout event. This script focuses on what happens after the breakout: acceptance, failure, reclaim pressure, and continuation risk.

The design supports a patient, context-first workflow where the trader reads the path of price around a boundary instead of reacting to a single candle.


⚡ Why This Script Is Different

Most tools focus on breakout signals, support and resistance touches, or simple range breaks.

This script does NOT treat every break as meaningful acceptance.

Instead, it builds a path map around acceptance quality, failure timing, reclaim behavior, and current risk state. The result is a cleaner view of whether price is holding acceptance or losing it.


⚙️ Methodology

1. Context Detection
The script builds a reference range from recent market structure and applies an ATR-based buffer to reduce noise.

2. Reference Mapping
It defines upper and lower acceptance boundaries and tracks whether price closes beyond them for the required number of bars.

3. Reaction Evaluation
After acceptance appears, the script monitors whether price fails back through the boundary, attempts reclaim, or holds continuation.

4. Visual Output
The chart displays an acceptance path zone, event labels, right-side state tags, and a panel summarizing the current condition.


🗺️ How to Read the Chart

Zones show the current acceptance path area around the active boundary.

Labels highlight acceptance above, acceptance below, acceptance failure, reclaim tests, and held acceptance.

Colors separate bullish acceptance, bearish acceptance, neutral failure risk, and reclaim context.

The panel shows the current path state, acceptance side, failure risk, path quality, reference range, active boundary, and next context.


🚦 Signals & States

• ACCEPT ABOVE → Price has accepted above the reference boundary.

• ACCEPT BELOW → Price has accepted below the reference boundary.

• ACCEPT FAIL → Accepted price failed back through the boundary within the failure window.

• RECLAIM TEST → Price is testing reclaim after a failed acceptance event.

• ACCEPT HELD → Acceptance remained valid after the failure window.


🔔 Alerts Logic

Alerts trigger when the script detects acceptance above, acceptance below, acceptance failure, or reclaim testing.

These alerts are attention markers. They are not trade instructions, entry signals, or guaranteed outcomes.


🧩 Confluence Logic

The context becomes stronger when acceptance quality, distance from the reference range, participation, and follow-through direction align.

If acceptance appears without follow-through or quickly returns through the boundary, the failure context becomes more important.


📊 When to Use

• After range breaks

• Around support and resistance transitions

• During breakout retests

• When price is attempting to hold above or below a major boundary

• When evaluating whether market structure is accepted or rejected


⚠️ When NOT to Use

• Extremely illiquid markets

• Very noisy low-timeframe candles

• News-driven spikes with unstable spreads

• Markets with no meaningful reference range

• Situations where a single indicator is being used without broader context


🎛️ Key Inputs

• Reference Range Length → controls how much structure is used to build the acceptance boundary.

• Acceptance Bars → controls how many closes are required before acceptance is recognized.

• Failure Window → controls how quickly accepted price must fail back through the boundary.

• Boundary Buffer ATR → adjusts the buffer around the reference range.

• Label and Panel Font Size → adjust chart readability.

• Visible Band Bars and Band Projection Bars → control how the acceptance zone appears on the chart.


🖥️ Interface & Visual Design

The interface is designed for a premium, clean chart view.

The panel provides the current summary. The acceptance zone carries the main story. Labels are compact and spaced to avoid hiding candles.

The visual hierarchy is intentionally simple: zone first, current state second, event labels third.


🧪 Practical Usage Workflow

1. Read the AG Pro panel to identify the current path state.

2. Check whether price is above, below, or inside the acceptance path zone.

3. Review recent labels to understand whether acceptance held, failed, or reclaimed.

4. Compare the current failure risk and path quality with broader market context.

5. Use alerts only as attention markers for further review.


🔍 Interpretation Guidelines

Acceptance is stronger when price remains outside the boundary with follow-through.

Acceptance failure is more meaningful when price quickly returns through the boundary after appearing accepted.

Reclaim tests should be interpreted as context changes, not automatic reversal signals.

Held acceptance suggests the market is continuing to respect the accepted side, but it still requires confirmation from broader structure.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not provide guaranteed buy or sell signals.

It does not replace risk management, market context, or independent analysis.


⚠️ Limitations & Transparency

Acceptance behavior can look different across timeframes.

High volatility can create temporary false readings.

Low-liquidity markets may produce unstable boundary behavior.

The script is rule-based and depends on the selected settings, symbol behavior, and chart timeframe.


🧠 Market Context Notes

Acceptance and failure are closely related to market structure, liquidity reaction, and participant commitment.

When price breaks a boundary but cannot hold it, the failed side may become the more important context.

When price accepts and holds, the market may be showing stronger directional commitment.


🧾 Use Case Examples

When price accepts above a range and holds beyond the failure window, the chart may show an ACCEPT HELD context.

When price accepts above a boundary but quickly closes back below it, the script may mark ACCEPT FAIL.

When price returns back toward a failed boundary, the script may show a RECLAIM TEST state.


🧱 System Philosophy

AGPro Series tools are built to visualize market context without turning analysis into prediction.

The goal is to make structure, risk, and reaction quality easier to observe in real time.


🔐 Non-Promise Statement

No script can guarantee market direction, timing, or outcome.

This tool provides structured visual context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and position sizing.

This script does not provide financial advice or guaranteed trading results.


📚 Educational Note

Use this script as a learning and analysis tool for studying acceptance, failed acceptance, reclaim pressure, and continuation behavior around market boundaries.

## Source Code

````pine
// --------------------------------------------------
// Acceptance Failure Path Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Acceptance Failure Path Map is an acceptance failure and path-mapping tool
// that studies whether price has held acceptance beyond a reference boundary
// or failed back through it. The script maps acceptance bands, failed acceptance
// paths, reclaim pressure, and continuation risk for traders who want to read
// acceptance quality without using a basic breakout marker or reversal claim.
// --------------------------------------------------

//@version=6
indicator("Acceptance Failure Path Map [AGPro Series]",
     shorttitle = "AG Pro AFP",
     overlay = true,
     max_labels_count = 140,
     max_boxes_count = 12,
     max_lines_count = 50)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_CORE = "Core Logic"
int rangeLength = input.int(64, "Reference Range Length", minval = 20, maxval = 260, group = G_CORE,
     tooltip = "Defines the reference range used to judge acceptance above or below market structure.")
int acceptBars = input.int(3, "Acceptance Bars", minval = 1, maxval = 10, group = G_CORE,
     tooltip = "Number of consecutive closes beyond the reference boundary required for acceptance.")
int failureWindow = input.int(10, "Failure Window", minval = 3, maxval = 40, group = G_CORE,
     tooltip = "Maximum number of bars allowed for accepted price to fail back through the boundary.")
float bufferAtr = input.float(0.18, "Boundary Buffer ATR", minval = 0.02, maxval = 1.0, step = 0.01, group = G_CORE,
     tooltip = "Adds a small ATR buffer around the reference range to reduce noisy acceptance readings.")
int qualityLength = input.int(34, "Quality Length", minval = 10, maxval = 160, group = G_CORE,
     tooltip = "Measures background volatility and participation for acceptance quality.")
int proofWindowBars = input.int(20, "Proof Window Bars", minval = 5, maxval = 80, group = G_CORE,
     tooltip = "Number of bars an acceptance failure is tracked to see whether the failure follows through before price reclaims the boundary. Tests that resolve neither way time out and stay uncounted.")
float proofReachAtr = input.float(1.0, "Proof Follow-Through ATR", minval = 0.3, maxval = 4.0, step = 0.1, group = G_CORE,
     tooltip = "How far price must travel in the failure direction, in ATR, before a failure counts as following through. The same distance in the opposite direction counts as the invalidation, so the proof stays balanced.")

string G_VISUAL = "Visual Design"
bool showAcceptanceBand = input.bool(true, "Show Acceptance Band", group = G_VISUAL,
     tooltip = "Displays the current acceptance or failure reference band.")
bool showBandHalo = input.bool(true, "Show Band Halo", group = G_VISUAL,
     tooltip = "Adds a soft outer halo around the active acceptance path for better first-glance visibility.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows compact acceptance, failure, reclaim, and continuation labels.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows current path state and failure quality tags on the right side of the chart.")
bool showBarColors = input.bool(false, "Color Bars by Path State", group = G_VISUAL,
     tooltip = "Optionally colors bars when failure pressure or late failure context is active.")
int visibleBandBars = input.int(82, "Visible Band Bars", minval = 24, maxval = 220, group = G_VISUAL,
     tooltip = "Controls how many recent bars are covered by the visible acceptance band.")
int projectionBars = input.int(24, "Band Projection Bars", minval = 8, maxval = 80, group = G_VISUAL,
     tooltip = "Controls how far the acceptance band is projected to the right.")
float minBandHeightAtr = input.float(0.72, "Minimum Band Height ATR", minval = 0.10, maxval = 2.00, step = 0.01, group = G_VISUAL,
     tooltip = "Keeps the acceptance band visually readable when the calculated structure is very thin.")
int labelCooldownBars = input.int(26, "Event Label Cooldown", minval = 8, maxval = 140, group = G_VISUAL,
     tooltip = "Minimum number of bars between event labels. Higher values reduce label density.")
int maxEventLabels = input.int(5, "Maximum Event Labels", minval = 4, maxval = 30, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
float labelOffsetAtr = input.float(0.82, "Label Offset ATR", minval = 0.20, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Distance between event labels and candles, measured in ATR.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label, band badge, and right-side tag font size.")

string G_PANEL = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro information panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_PANEL,
     tooltip = "Controls where the AG Pro panel is placed.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls the panel color theme.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls the font size of the panel.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBg = color.rgb(15, 23, 42)
color panelBorder = color.rgb(86, 103, 130)
color panelLabelCol = color.rgb(190, 202, 220)
color panelValueCol = color.rgb(245, 247, 250)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_size(string sizeName) =>
    sizeName == "Tiny" ? size.tiny :
     sizeName == "Small" ? size.small :
     sizeName == "Large" ? size.large : size.normal

f_panel_pos(string posName) =>
    posName == "Top Left" ? position.top_left :
     posName == "Top Center" ? position.top_center :
     posName == "Middle Right" ? position.middle_right :
     posName == "Middle Left" ? position.middle_left :
     posName == "Middle Center" ? position.middle_center :
     posName == "Bottom Right" ? position.bottom_right :
     posName == "Bottom Left" ? position.bottom_left :
     posName == "Bottom Center" ? position.bottom_center : position.top_right

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_dir_text(int direction) =>
    direction > 0 ? "Upside" : direction < 0 ? "Downside" : "Neutral"

f_text_on(color bgColor) =>
    float brightness = 0.299 * color.r(bgColor) + 0.587 * color.g(bgColor) + 0.114 * color.b(bgColor)
    brightness > 145.0 ? color.rgb(17, 24, 39) : headerText

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeName) =>
    themeName == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_set_line(line lineRef, int x1, float y1, int x2, float y2, color lineColor, bool dotted, int widthValue) =>
    line.set_xy1(lineRef, x1, y1)
    line.set_xy2(lineRef, x2, y2)
    line.set_color(lineRef, lineColor)
    line.set_style(lineRef, dotted ? line.style_dotted : line.style_solid)
    line.set_width(lineRef, widthValue)

f_set_tag(label tag, int x, float y, string labelText, color bg, bool leftStyle, string textSize) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, labelText)
    label.set_color(tag, color.new(bg, 0))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, leftStyle ? label.style_label_left : label.style_label_center)
    label.set_size(tag, f_size(textSize))

f_event_label(array<label> store, array<line> connectorStore, int x, float anchorY, float y, string txt, color bg, bool upward, string sizeInput, int limit) =>
    label newLabel = label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = upward ? label.style_label_up : label.style_label_down, textcolor = f_text_on(bg), color = color.new(bg, 0), size = f_size(sizeInput), textalign = text.align_center)
    line newConnector = line.new(x, anchorY, x, y, xloc = xloc.bar_index, color = color.new(bg, 34), style = line.style_solid, width = 1)
    array.push(store, newLabel)
    array.push(connectorStore, newConnector)
    if array.size(store) > limit
        label oldLabel = array.shift(store)
        line oldConnector = array.shift(connectorStore)
        label.delete(oldLabel)
        line.delete(oldConnector)

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeInput) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, bgcolor = rowBg, text_color = f_panel_label(themeName), text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, bgcolor = rowBg, text_color = rightColor, text_size = f_size(sizeInput), text_halign = text.align_right)

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
float atrRaw = ta.atr(14)
float atr = math.max(nz(atrRaw), ta.tr(true), syminfo.mintick)
float buffer = atr * bufferAtr
float rangeHigh = ta.highest(high, rangeLength)[1]
float rangeLow = ta.lowest(low, rangeLength)[1]
float safeRangeHigh = nz(rangeHigh, high)
float safeRangeLow = nz(rangeLow, low)
float upperBoundary = safeRangeHigh + buffer
float lowerBoundary = safeRangeLow - buffer
float rangeMid = (safeRangeHigh + safeRangeLow) * 0.5
float volBase = ta.sma(nz(volume, 1.0), qualityLength)
float volRank = volBase > 0.0 ? f_clamp(nz(volume, 1.0) / volBase * 50.0, 0.0, 100.0) : 50.0

bool aboveAcceptance = close > upperBoundary
bool belowAcceptance = close < lowerBoundary
float aboveCount = math.sum(aboveAcceptance ? 1.0 : 0.0, acceptBars)
float belowCount = math.sum(belowAcceptance ? 1.0 : 0.0, acceptBars)
bool newAcceptUp = aboveCount == acceptBars and nz(aboveCount[1], 0.0) < acceptBars
bool newAcceptDown = belowCount == acceptBars and nz(belowCount[1], 0.0) < acceptBars

var int acceptDir = 0
var int acceptBar = na
var float acceptBoundary = na
var float pathQualityMemory = na
var string pathMemory = "Wait Acceptance"

// Acceptance quality is a balanced 0-100 blend of body efficiency, volume
// participation, and how decisively price sits beyond the range mid. Each
// component is normalized so the score spans a meaningful range instead of
// pinning at 100 on every acceptance.
float bodyShareQ = math.abs(close - open) / math.max(high - low, syminfo.mintick)
float distMidAtr = math.abs(close - rangeMid) / atr
float bodyScoreQ = f_clamp((bodyShareQ - 0.15) / 0.50 * 100.0, 0.0, 100.0)
float locScoreQ = f_clamp((distMidAtr - 0.50) / 2.50 * 100.0, 0.0, 100.0)
float acceptQuality = f_clamp(bodyScoreQ * 0.34 + volRank * 0.33 + locScoreQ * 0.33, 0.0, 100.0)

if newAcceptUp or newAcceptDown
    acceptDir := newAcceptUp ? 1 : -1
    acceptBar := bar_index
    acceptBoundary := newAcceptUp ? upperBoundary : lowerBoundary
    pathQualityMemory := acceptQuality
    pathMemory := newAcceptUp ? "Accept Above" : "Accept Below"

bool failedUp = acceptDir > 0 and not na(acceptBar) and bar_index - acceptBar <= failureWindow and close < acceptBoundary
bool failedDown = acceptDir < 0 and not na(acceptBar) and bar_index - acceptBar <= failureWindow and close > acceptBoundary
bool failedNow = failedUp or failedDown
bool failureEvent = failedNow and not failedNow[1]

if failureEvent
    pathMemory := acceptDir > 0 ? "Upside Failed" : "Downside Failed"
    pathQualityMemory := f_clamp(acceptQuality + math.min(math.abs(close - acceptBoundary) / atr * 18.0, 25.0), 0.0, 100.0)

bool failedState = pathMemory == "Upside Failed" or pathMemory == "Downside Failed"
bool heldUp = pathMemory == "Accept Held" and acceptDir > 0
bool heldDown = pathMemory == "Accept Held" and acceptDir < 0
bool reclaimEvent = (pathMemory == "Upside Failed" and close > acceptBoundary) or (pathMemory == "Downside Failed" and close < acceptBoundary)
bool continuationEvent = acceptDir != 0 and not failureEvent and not na(acceptBar) and bar_index - acceptBar > failureWindow and (acceptDir > 0 ? close > acceptBoundary : close < acceptBoundary)
bool continuationStart = continuationEvent and not continuationEvent[1]

if reclaimEvent
    pathMemory := "Reclaim Test"
    pathQualityMemory := f_clamp(acceptQuality + 12.0, 0.0, 100.0)
if continuationStart
    pathMemory := "Accept Held"
    pathQualityMemory := f_clamp(acceptQuality + 8.0, 0.0, 100.0)

float failureRisk = acceptDir == 0 or na(acceptBoundary) ? 0.0 : acceptDir > 0 ? f_clamp((acceptBoundary - close) / atr * 28.0 + 35.0, 0.0, 100.0) : f_clamp((close - acceptBoundary) / atr * 28.0 + 35.0, 0.0, 100.0)
bool pressureEvent = acceptDir != 0 and failureRisk >= 62.0 and nz(failureRisk[1], 0.0) < 62.0
bool lateFailureNow = acceptDir != 0 and not failureEvent and not na(acceptBar) and not na(acceptBoundary) and bar_index - acceptBar > failureWindow and (acceptDir > 0 ? close < acceptBoundary : close > acceptBoundary)
bool lateFailureEvent = lateFailureNow and not lateFailureNow[1]

if lateFailureEvent
    pathMemory := acceptDir > 0 ? "Late Up Fail" : "Late Down Fail"
    pathQualityMemory := f_clamp(acceptQuality + failureRisk * 0.28, 0.0, 100.0)

bool lateFailedState = pathMemory == "Late Up Fail" or pathMemory == "Late Down Fail"
bool pressureState = not lateFailedState and not failedState and acceptDir != 0 and failureRisk >= 62.0
string displayState = pressureState ? "Failure Pressure" : pathMemory
color displayColor = pressureState or lateFailedState ? neutralColor : pathMemory == "Accept Above" or heldUp ? bullColor : pathMemory == "Accept Below" or heldDown ? bearColor : failedState ? neutralColor : pathMemory == "Reclaim Test" ? accentColor : accentColor
color stateColor = displayColor
string nextContext = displayState == "Wait Acceptance" ? "Wait clean accept" : displayState == "Accept Above" or displayState == "Accept Below" ? "Watch failure path" : displayState == "Failure Pressure" ? "Failure path active" : failedState or lateFailedState ? "Monitor reclaim" : displayState == "Reclaim Test" ? "Confirm reclaim" : "Acceptance held"

// --------------------------------------------------
// Stop-aware acceptance-failure follow-through proof
// Confirmed-bar gated. Resolve any open test first, then open a new one.
// When acceptance fails, the planner tests whether price extends one ATR step in
// the failure direction before it travels the same distance against it. The
// symmetric band keeps the test balanced rather than deflated by the boundary
// sitting right next to the failure close. Tests that resolve neither way inside
// the window time out and stay uncounted.
// --------------------------------------------------
var int   proofWins     = 0
var int   proofTotal    = 0
var bool  proofPending  = false
var int   proofDir      = 0
var float proofTarget   = na
var float proofInvalid  = na
var int   proofBarsLeft = 0

if barstate.isconfirmed
    if proofPending
        proofBarsLeft := proofBarsLeft - 1
        if proofDir == -1
            if close <= proofTarget
                proofWins  := proofWins + 1
                proofTotal := proofTotal + 1
                proofPending := false
            else if close >= proofInvalid
                proofTotal := proofTotal + 1
                proofPending := false
            else if proofBarsLeft <= 0
                proofPending := false
        else if proofDir == 1
            if close >= proofTarget
                proofWins  := proofWins + 1
                proofTotal := proofTotal + 1
                proofPending := false
            else if close <= proofInvalid
                proofTotal := proofTotal + 1
                proofPending := false
            else if proofBarsLeft <= 0
                proofPending := false
    if not proofPending and failureEvent
        proofPending  := true
        proofDir      := failedUp ? -1 : 1
        proofTarget   := failedUp ? close - atr * proofReachAtr : close + atr * proofReachAtr
        proofInvalid  := failedUp ? close + atr * proofReachAtr : close - atr * proofReachAtr
        proofBarsLeft := proofWindowBars

float proofRate = proofTotal > 0 ? proofWins / proofTotal * 100.0 : 0.0
bool proofReady = proofTotal >= 6
string proofText = proofReady ? str.tostring(proofRate, "#") + "%" : "Building (" + str.tostring(proofTotal) + ")"
color proofFill = not proofReady ? neutralColor : proofRate >= 55.0 ? bullColor : proofRate >= 45.0 ? neutralColor : bearColor


float activeBoundary = acceptDir > 0 ? upperBoundary : acceptDir < 0 ? lowerBoundary : rangeMid
float pathCenterRaw = not na(acceptBoundary) and math.abs(close - acceptBoundary) <= atr * 9.0 ? acceptBoundary : activeBoundary
float pathCenter = na(pathCenterRaw) ? close : pathCenterRaw
float rangeWidth = math.max(nz(safeRangeHigh - safeRangeLow, atr * 2.0), syminfo.mintick)
float bandHalfRaw = math.max(atr * 0.72, math.abs(rangeWidth) * 0.035)
float bandHalf = math.max(bandHalfRaw, atr * minBandHeightAtr)
float bandTop = pathCenter + bandHalf
float bandBottom = pathCenter - bandHalf
float bandTopSafe = math.max(bandTop, bandBottom + syminfo.mintick)
float bandBottomSafe = math.min(bandBottom, bandTop - syminfo.mintick)

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
color hiddenColor = color.new(color.black, 100)
var box pathHalo = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = hiddenColor, border_color = hiddenColor, border_width = 1)
var box pathBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = hiddenColor, border_color = hiddenColor, border_width = 1)
var line upperRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line midRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_dotted, width = 2)
var line lowerRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line leftRail = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line rightRail = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var label pathLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = color.white, size = size.normal)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = color.white, size = size.normal)
var label qualityTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = color.white, size = size.normal)

int rightX = bar_index + projectionBars
int leftX = math.max(bar_index - visibleBandBars, 0)
int labelX = int(math.round(leftX + (rightX - leftX) * 0.62))
float bandMid = (bandTopSafe + bandBottomSafe) * 0.5

if barstate.islast
    if showAcceptanceBand and not na(bandTopSafe) and not na(bandBottomSafe)
        float haloPad = math.max(atr * 0.14, (bandTopSafe - bandBottomSafe) * 0.16)
        box.set_left(pathHalo, leftX)
        box.set_right(pathHalo, rightX)
        box.set_top(pathHalo, bandTopSafe + haloPad)
        box.set_bottom(pathHalo, bandBottomSafe - haloPad)
        box.set_bgcolor(pathHalo, showBandHalo ? color.new(stateColor, 93) : hiddenColor)
        box.set_border_color(pathHalo, showBandHalo ? color.new(stateColor, 64) : hiddenColor)
        box.set_border_width(pathHalo, 1)
        box.set_left(pathBox, leftX)
        box.set_right(pathBox, rightX)
        box.set_top(pathBox, bandTopSafe)
        box.set_bottom(pathBox, bandBottomSafe)
        box.set_bgcolor(pathBox, color.new(stateColor, 74))
        box.set_border_color(pathBox, color.new(stateColor, 0))
        box.set_border_width(pathBox, 3)
        f_set_line(upperRail, leftX, bandTopSafe, rightX, bandTopSafe, color.new(stateColor, 0), false, 4)
        f_set_line(midRail, leftX, bandMid, rightX, bandMid, color.new(stateColor, 10), true, 2)
        f_set_line(lowerRail, leftX, bandBottomSafe, rightX, bandBottomSafe, color.new(stateColor, 0), false, 4)
        f_set_line(leftRail, leftX, bandTopSafe, leftX, bandBottomSafe, color.new(stateColor, 2), false, 3)
        f_set_line(rightRail, rightX, bandTopSafe, rightX, bandBottomSafe, color.new(stateColor, 2), false, 3)
        f_set_tag(pathLabel, labelX, bandMid, "ACCEPT PATH | Q" + f_score(pathQualityMemory), stateColor, false, labelSizeInput)
    else
        box.set_bgcolor(pathHalo, hiddenColor)
        box.set_border_color(pathHalo, hiddenColor)
        box.set_bgcolor(pathBox, hiddenColor)
        box.set_border_color(pathBox, hiddenColor)
        f_set_line(upperRail, bar_index, close, bar_index + 1, close, hiddenColor, false, 1)
        f_set_line(midRail, bar_index, close, bar_index + 1, close, hiddenColor, false, 1)
        f_set_line(lowerRail, bar_index, close, bar_index + 1, close, hiddenColor, false, 1)
        f_set_line(leftRail, bar_index, close, bar_index, close, hiddenColor, false, 1)
        f_set_line(rightRail, bar_index, close, bar_index, close, hiddenColor, false, 1)
        label.set_text(pathLabel, "")
        label.set_color(pathLabel, hiddenColor)

    if showRightTags
        float tagOffset = atr * 0.86
        float qualityBase = not na(bandTopSafe) and not na(bandBottomSafe) ? (acceptDir >= 0 ? bandTopSafe + tagOffset : bandBottomSafe - tagOffset) : close + tagOffset
        f_set_tag(stateTag, rightX + 4, close, displayState, stateColor, true, labelSizeInput)
        f_set_tag(qualityTag, rightX + 4, qualityBase, "Risk " + f_score(failureRisk), stateColor, true, labelSizeInput)
    else
        label.set_text(stateTag, "")
        label.set_text(qualityTag, "")
        label.set_color(stateTag, hiddenColor)
        label.set_color(qualityTag, hiddenColor)

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var array<line> eventConnectors = array.new<line>()
var int lastEventBar = na
var int eventLaneSeed = 0
bool canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
bool eventCandidate = newAcceptUp or newAcceptDown or failureEvent or lateFailureEvent or reclaimEvent or pressureEvent or continuationStart
string eventText = failureEvent or lateFailureEvent ? "ACCEPT FAIL | Q" + f_score(pathQualityMemory) : pressureEvent ? "FAIL PRESSURE | Q" + f_score(failureRisk) : reclaimEvent ? "RECLAIM TEST | Q" + f_score(pathQualityMemory) : continuationEvent ? "ACCEPT HELD | Q" + f_score(pathQualityMemory) : newAcceptUp ? "ACCEPT ABOVE | Q" + f_score(acceptQuality) : "ACCEPT BELOW | Q" + f_score(acceptQuality)
color eventColor = failureEvent or lateFailureEvent or pressureEvent ? neutralColor : reclaimEvent ? accentColor : (newAcceptUp or acceptDir > 0 ? bullColor : bearColor)
bool eventUp = acceptDir >= 0
int eventLane = eventLaneSeed % 3
float eventFontBonus = labelSizeInput == "Large" ? 0.34 : labelSizeInput == "Normal" ? 0.20 : labelSizeInput == "Small" ? 0.10 : 0.0
float eventDistance = atr * (labelOffsetAtr + eventFontBonus + eventLane * 0.38)
float eventAnchorY = eventUp ? low : high
float eventY = eventUp ? eventAnchorY - eventDistance : eventAnchorY + eventDistance

if showEventLabels and eventCandidate and canPrintEvent
    f_event_label(eventLabels, eventConnectors, bar_index, eventAnchorY, eventY, eventText, eventColor, eventUp, labelSizeInput, maxEventLabels)
    lastEventBar := bar_index
    eventLaneSeed += 1

barcolor(showBarColors and (failedState or lateFailedState or pressureState) ? color.new(neutralColor, 72) : na)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 8, bgcolor = f_panel_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if barstate.islast
    if showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 7)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Acceptance Failure Path Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Path State", displayState + " / " + f_score(pathQualityMemory), stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Accept Side", f_dir_text(acceptDir), stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Failure Risk", f_score(failureRisk), failureRisk >= 62.0 ? neutralColor : f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        color proofRowBg = f_row_bg(panelThemeInput, 4)
        table.cell(panel, 0, 4, "Failure Proof", bgcolor = proofRowBg, text_color = f_panel_label(panelThemeInput), text_size = f_size(panelFontSizeInput), text_halign = text.align_left)
        table.cell(panel, 1, 4, proofText, bgcolor = proofFill, text_color = f_text_on(proofFill), text_size = f_size(panelFontSizeInput), text_halign = text.align_right)
        f_panel_row(panel, 5, "Reference", f_fmt(safeRangeLow) + " / " + f_fmt(safeRangeHigh), f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Boundary", f_fmt(pathCenter), f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 7, "Action", nextContext, stateColor, panelThemeInput, panelFontSizeInput)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelPosMemory := ""
            panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(newAcceptUp, "Acceptance Above", "Price accepted above the reference boundary.")
alertcondition(newAcceptDown, "Acceptance Below", "Price accepted below the reference boundary.")
alertcondition(failureEvent, "Acceptance Failure", "Accepted price failed back through the reference boundary.")
alertcondition(reclaimEvent, "Acceptance Reclaim Test", "Price is testing reclaim after acceptance failure.")
alertcondition(pressureEvent, "Acceptance Failure Pressure", "Failure pressure is increasing around the active acceptance path.")
alertcondition(lateFailureEvent, "Late Acceptance Failure", "Accepted price failed after the initial failure window.")
````
