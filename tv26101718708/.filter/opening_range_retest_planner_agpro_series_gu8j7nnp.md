# Opening Range Retest Planner [AGPro Series]

- url: https://www.tradingview.com/script/GU8j7NNP-Opening-Range-Retest-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;ee58d5266c0542b89fdc059ccf7d3303
- version: 4.0

## Description

# Opening Range Retest Planner [AGPro Series]

## Core Idea

Did the opening range breakout return to its boundary and hold with enough quality to deserve attention?

## Overview / What It Does

Opening Range Retest Planner is an intraday opening range decision-support script built for traders who want to evaluate the quality of the first meaningful retest after an opening range breakout.

The script builds the opening range, tracks the first bullish or bearish breakout, maps a focused retest pocket around the broken boundary, grades the retest from 0 to 100, and displays a clear action state in a compact AG Pro panel.

It does not predict price direction, automate execution, or provide guaranteed outcomes. Its purpose is to organize structure, acceptance, invalidation, and retest quality in a clean visual workflow.

## Purpose & Design Philosophy

Many opening range tools focus only on the initial break. In practice, the first retest after the break is often where the structure becomes more meaningful.

This script was built for traders who want to separate a clean retest hold from a weak pullback, failed breakout, or expired setup. The design supports structured observation instead of impulsive reaction.

## Why This Script Is Different

Most opening range tools stop at the range or breakout itself.

This script does not stop there.

Instead, it focuses on what happens after the break: whether price returns to the broken boundary, respects it, fails back inside the range, or runs out of time before a qualified retest appears.

## Methodology

1. Opening Range Mapping
2. Breakout Detection
3. Retest Pocket Construction
4. Retest Quality Scoring
5. Acceptance, Invalidation, or Expiration State
6. Panel and Alert Output

## How To Read The Chart

The opening range remains the main session reference.

The retest pocket marks the area where the script evaluates whether the broken boundary is being respected or rejected.

Labels highlight qualified retests, invalidations, and key state changes.

Target rails project possible continuation space after a qualified retest.

The panel summarizes OR state, retest score, acceptance side, failure risk, and current action.

## Signals & States

READY -> A retest touched the pocket, held the broken boundary, and met the minimum quality threshold.

MONITOR -> A breakout occurred and the script is tracking whether a qualified retest develops.

WAIT -> The opening range is still building, has just locked, or is waiting for a valid post-break condition.

INVALIDATED -> Price failed back inside the opening range after the breakout.

EXPIRED -> The retest window closed without a qualified retest.

BLOCKED -> The opening range is not valid enough to evaluate.

## Alerts Logic

Bullish Opening Range Retest Ready triggers when a bullish breakout retest holds the broken range high with enough score.

Bearish Opening Range Retest Ready triggers when a bearish breakout retest holds the broken range low with enough score.

Opening Range Retest Invalidated triggers when price fails back inside the opening range after a breakout.

Opening Range Retest Expired triggers when the retest window expires without a qualified hold.

Alerts are attention markers, not trade instructions.

## Confluence Logic

The retest score combines pocket touch quality, close response, retest timing, relative volume, opening range volatility fit, and available target room.

When these conditions align, the context becomes stronger. When they do not align, the panel remains in MONITOR, WAIT, INVALIDATED, or EXPIRED state.

## When To Use

This script is most useful in liquid intraday markets where the opening range matters and session structure is clear.

It fits breakout-retest workflows, opening drive continuation, failed breakout monitoring, and structured intraday planning.

## When NOT To Use

Avoid relying on this script in very low-liquidity symbols, extremely noisy sessions, holiday trading, or chart conditions where the opening range session cannot be represented cleanly.

## Key Inputs

Opening Range Mode controls whether the script uses an exact session window or the first chart bars of each day.

Auto mode uses session-window logic on lower intraday charts and switches to first-bars-of-day logic on higher timeframes.

Retest Pocket ATR controls the depth of the retest zone around the broken boundary.

Minimum Ready Score controls how strong the 0-100 retest score must be before READY appears.

Panel and label controls let users adjust position, theme, and visual density.

## Interface & Visual Design

The visual design is chart-first.

The opening range stays readable, the active retest pocket becomes the focus area, and the panel provides compact decision context without covering the whole chart.

The first panel row uses the AG Pro blue header style and shows only the script name.

## Practical Usage Workflow

1. Wait for the opening range to lock.
2. Watch for a breakout beyond the range boundary.
3. Observe whether price returns to the retest pocket.
4. Check the retest score and action state.
5. Treat alerts as attention markers and confirm context with your broader process.

## What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not guarantee outcomes.

It does not replace independent risk management or market context.

## Limitations & Transparency

Opening range behavior changes across markets, sessions, liquidity conditions, and timeframes.

The score is rule-based and depends on the configured session, ATR normalization, volume behavior, and retest window.

Different chart timeframes may display session structure differently.

## Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions.

This script is for educational and analytical purposes only and does not provide financial advice or guaranteed trading outcomes.

## Source Code

````pine
// -------------------------------------------------
// Opening Range Retest Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Opening Range Retest Planner is an intraday opening range decision
// engine built to evaluate whether a post-breakout retest is being
// accepted, rejected, invalidated, or left in a monitor state. It maps
// the opening range, builds a focused retest pocket, scores the retest
// from 0-100, and displays a clear action state for traders who want
// structure-first context instead of generic breakout arrows.
//
// Version 1.4: boundary-owned OR and target badges, short price connectors,
// font-aware ATR spacing, connector-backed historical event lanes, exact
// retest-pocket centering, and atomic label/connector cleanup.
// -------------------------------------------------

//@version=6
indicator("Opening Range Retest Planner [AGPro Series]",
     shorttitle = "AG Pro ORR",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 120,
     max_lines_count = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
darkInk       = color.rgb(17, 24, 39)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
// Luminance-145 contrast ink: bright badge fills get dark ink, dark fills get header text.
f_text_on(_bg) =>
    lum = math.round(0.299 * color.r(_bg) + 0.587 * color.g(_bg) + 0.114 * color.b(_bg))
    lum >= 145 ? darkInk : headerText

f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_v, _hi))

f_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal :
     _s == "Large" ? size.large : size.huge

f_label_lane_mult(_s) =>
    _s == "Tiny" ? 0.75 :
     _s == "Small" ? 0.90 :
     _s == "Large" ? 1.25 :
     _s == "Huge" ? 1.55 : 1.00

f_table_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal : size.large

f_panel_position(_p) =>
    _p == "Top Right" ? position.top_right :
     _p == "Top Left" ? position.top_left :
     _p == "Middle Right" ? position.middle_right :
     _p == "Middle Left" ? position.middle_left :
     _p == "Bottom Right" ? position.bottom_right : position.bottom_left

f_grade(_score) =>
    _score >= 85 ? "A+" :
     _score >= 75 ? "A" :
     _score >= 65 ? "B" :
     _score >= 55 ? "C" : "D"

f_action_color(_action) =>
    _action == "READY" ? color.new(bullColor, 8) :
     _action == "MONITOR" ? color.new(accentColor, 12) :
     _action == "WAIT" ? color.new(neutralColor, 16) :
     _action == "BLOCKED" ? color.new(panelBorder, 0) :
     _action == "INVALIDATED" ? color.new(bearColor, 8) :
     _action == "EXPIRED" ? color.new(panelBorder, 6) : color.new(panelBg, 0)

f_score_text(_score) =>
    na(_score) ? "n/a" : str.tostring(math.round(_score)) + "/100  " + f_grade(_score)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
G_SESSION = "Opening Range"
G_ENGINE  = "Retest Engine"
G_VISUAL  = "Visuals"
G_PANEL   = "Panel"
G_ALERTS  = "Alerts"

sessionLabel = input.string("New York OR", "Session Label", group = G_SESSION,
     tooltip = "Short name shown in the panel for the opening range model.")
rangeMode = input.string("Auto", "Opening Range Mode",
     options = ["Auto", "Session Window", "First Bars Of Day"],
     group = G_SESSION,
     tooltip = "Auto uses the exact session window on lower intraday charts and switches to first-bars-of-day logic on 1h, 4h, and daily charts. Session Window forces an exact intraday time window. First Bars Of Day builds the range from the first chart bars of each day.")
openingRangeBars = input.int(1, "Opening Range Bars", minval = 1, maxval = 12, group = G_SESSION,
     tooltip = "Number of first chart bars used to build the opening range when First Bars Of Day mode is selected.")
orSession = input.session("0930-0945", "Opening Range Session", group = G_SESSION,
     tooltip = "Session window used to build the opening range. Format: HHMM-HHMM.")
trackSession = input.session("0930-1600", "Retest Tracking Session", group = G_SESSION,
     tooltip = "Session window during which breakouts and retests are evaluated.")
sessionTimezone = input.string("America/New_York", "Session Timezone",
     options = ["America/New_York", "Europe/London", "Europe/Istanbul", "Etc/UTC", "Asia/Tokyo", "Asia/Hong_Kong"],
     group = G_SESSION,
     tooltip = "Timezone applied to the opening range and retest tracking sessions.")

confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = G_ENGINE,
     tooltip = "Fast reacts quickly to the first hold, Balanced requires cleaner close response, and Strict demands stronger score and less failed acceptance risk.")
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G_ENGINE,
     tooltip = "ATR length used to normalize buffers, label offsets, pocket padding, and volatility fit.")
breakBufferAtr = input.float(0.08, "Break Buffer ATR", minval = 0.0, maxval = 2.0, step = 0.01, group = G_ENGINE,
     tooltip = "Minimum ATR-scaled close beyond the opening range boundary required before a retest watch starts.")
retestToleranceAtr = input.float(0.18, "Retest Pocket ATR", minval = 0.02, maxval = 2.0, step = 0.01, group = G_ENGINE,
     tooltip = "ATR-scaled depth around the broken opening range boundary used to define the retest pocket.")
failBufferAtr = input.float(0.10, "Invalidation Buffer ATR", minval = 0.0, maxval = 2.0, step = 0.01, group = G_ENGINE,
     tooltip = "ATR-scaled close back inside the range required to invalidate a retest context.")
retestWindowBars = input.int(28, "Retest Window Bars", minval = 3, maxval = 200, group = G_ENGINE,
     tooltip = "Maximum number of bars after a breakout during which the first valid retest can be accepted.")
minRetestScore = input.int(62, "Minimum Ready Score", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum 0-100 retest quality score required before the panel moves into READY state.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = G_ENGINE,
     tooltip = "Adds relative volume participation to the retest score when volume data is available.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_ENGINE,
     tooltip = "Lookback used to compare current volume against recent average participation.")

showOpeningRange = input.bool(true, "Show Opening Range Box", group = G_VISUAL,
     tooltip = "Displays the active opening range as the main session reference.")
showZoneBadges = input.bool(true, "Show Center Zone Badges", group = G_VISUAL,
     tooltip = "Shows contrast-safe centered badges inside the opening range and active retest pocket for dark and light chart readability.")
showMidline = input.bool(true, "Show OR Midline", group = G_VISUAL,
     tooltip = "Displays the midpoint of the opening range after the range is locked.")
showRetestPocket = input.bool(true, "Show Retest Pocket", group = G_VISUAL,
     tooltip = "Draws the focused retest pocket around the broken opening range boundary.")
showTargetRails = input.bool(true, "Show Target Rails", group = G_VISUAL,
     tooltip = "Draws projected target rails after a valid retest is confirmed.")
targetOneRange = input.float(0.75, "Target 1 x OR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "First projected target distance measured in opening range units from the broken boundary.")
targetTwoRange = input.float(1.25, "Target 2 x OR", minval = 0.10, maxval = 8.0, step = 0.05, group = G_VISUAL,
     tooltip = "Second projected target distance measured in opening range units from the broken boundary.")
rangeExtendBars = input.int(180, "OR Extension Bars", minval = 10, maxval = 450, group = G_VISUAL,
     tooltip = "Number of bars the opening range box and reference lines extend to the right.")
pocketExtendBars = input.int(60, "Retest Pocket Extension Bars", minval = 5, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars each retest pocket projects after the breakout.")
targetExtendBars = input.int(80, "Target Rail Extension Bars", minval = 5, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars target rails extend after a valid retest.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Displays opening range, breakout, retest, invalidation, and target labels.")
showRangeLockLabels = input.bool(false, "Show OR Lock Labels", group = G_VISUAL,
     tooltip = "Displays a label when the opening range locks. Disabled by default to keep publication screenshots cleaner.")
showBreakWatchLabels = input.bool(false, "Show Break Watch Labels", group = G_VISUAL,
     tooltip = "Displays early breakout watch labels before a qualified retest is confirmed. Disabled by default so READY and invalidation labels remain the visual focus.")
showFailureLabels = input.bool(false, "Show Failure / Expiry Labels", group = G_VISUAL,
     tooltip = "Displays invalidated and expired retest labels. Disabled by default to keep publication screenshots focused on the active retest structure.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows filled OR and target badges beyond their owned rail boundaries.")
rightTagOffsetBars = input.int(7, "Right Tag Connector Bars", minval = 2, maxval = 40, group = G_VISUAL,
     tooltip = "Controls the short connector distance between each rail boundary and its owned badge.")
rightTagMinGapAtr = input.float(0.55, "Right Tag Minimum Gap ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = G_VISUAL,
     tooltip = "Minimum font-aware ATR spacing used to separate nearby OR and target badges.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly when the retest context enters READY, MONITOR, INVALIDATED, or EXPIRED state.")
maxEventLabels = input.int(6, "Max Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Maximum number of event labels retained on the chart.")
labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 200, group = G_VISUAL,
     tooltip = "Minimum bars between repeated ready labels. Higher values create a cleaner hourly publication view.")
labelOffsetAtr = input.float(0.45, "Label Offset ATR", minval = 0.05, maxval = 3.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-scaled vertical offset used to keep labels clear of candle bodies and wicks.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls the size of chart labels and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Displays the AG Pro decision panel. Enabled by default for publication-ready chart context.")
panelPositionInput = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = G_PANEL,
     tooltip = "Controls where the decision panel is anchored on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls whether the panel uses the AGPro dark theme or a light chart-friendly theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls text size inside the decision panel.")

alertReady = input.bool(true, "Alert: Ready Retest", group = G_ALERTS,
     tooltip = "Creates an alert condition when a retest meets the minimum quality threshold.")
alertInvalidated = input.bool(true, "Alert: Invalidated Retest", group = G_ALERTS,
     tooltip = "Creates an alert condition when price fails back inside the opening range after a breakout.")
alertExpired = input.bool(false, "Alert: Expired Retest", group = G_ALERTS,
     tooltip = "Creates an alert condition when the retest window expires without a qualified hold.")

// -------------------------------------------------
// Session and engine state
// -------------------------------------------------
atr = ta.atr(atrLength)
atrSafe = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0 ? volume / volAvg : 1.0
labelSize = f_size(labelSizeInput)
labelLaneMult = f_label_lane_mult(labelSizeInput)
panelSize = f_table_size(panelFontSizeInput)

inOr = not na(time(timeframe.period, orSession, sessionTimezone))
inTrack = not na(time(timeframe.period, trackSession, sessionTimezone))
newDay = ta.change(time("D")) != 0
var int dayBarCount = 0
dayBarCount := newDay ? 1 : dayBarCount + 1
tfSeconds = timeframe.in_seconds(timeframe.period)
autoFirstBars = rangeMode == "Auto" and tfSeconds >= 3600
useFirstBars = rangeMode == "First Bars Of Day" or autoFirstBars
firstBarsActive = dayBarCount <= openingRangeBars
inOrEffective = useFirstBars ? firstBarsActive : inOr
inTrackEffective = useFirstBars ? dayBarCount > openingRangeBars : inTrack
inOrPrev = bar_index > 0 ? inOrEffective[1] : false
orStarts = inOrEffective and not inOrPrev
orEnds = not inOrEffective and inOrPrev

confirmBonus = confirmationMode == "Fast" ? 4.0 : confirmationMode == "Balanced" ? 0.0 : -6.0
requiredScore = f_clamp(minRetestScore - confirmBonus, 1, 100)

var float orHigh = na
var float orLow = na
var float orMid = na
var int orStartBar = na
var int orEndBar = na
var bool orLocked = false

var int breakDir = 0
var int breakBar = na
var float breakLevel = na
var bool retestResolved = false
var string retestState = "Waiting OR"
var string actionState = "WAIT"
var float lastScore = na
var float lastFailureRisk = na
var int lastReadyLabelBar = na

// Stop-aware target-proof engine state
var int proofDir = 0
var float proofTarget = na
var float proofStop = na
var int proofOpenBar = na
var bool proofPending = false
var int proofWins = 0
var int proofTotal = 0
var bool armReady = false
var int armDir = 0
var float armTarget = na
var float armStop = na

var box orBox = na
var box retestBox = na
var line orHighLine = na
var line orLowLine = na
var line orMidLine = na
var line targetOneLine = na
var line targetTwoLine = na
var line tagHighConnector = na
var line tagLowConnector = na
var line tagMidConnector = na
var line tagT1Connector = na
var line tagT2Connector = na
var label tagHigh = na
var label tagLow = na
var label tagMid = na
var label tagT1 = na
var label tagT2 = na
var label orCenterBadge = na
var label pocketCenterBadge = na
var label[] eventLabels = array.new_label()
var line[] eventConnectors = array.new_line()
var int eventLaneCounter = 0

f_add_owned_event(array<label> _labels, array<line> _connectors, int _eventX, float _ownerY, int _side, string _text, color _badgeBg, int _laneSeed, int _maxCount) =>
    lane = _laneSeed % 3
    badgeX = _eventX + lane * 2
    laneOffset = atrSafe * (labelOffsetAtr + lane * 0.35) * labelLaneMult
    badgeY = _ownerY + _side * laneOffset
    connector = line.new(_eventX, _ownerY, badgeX, badgeY,
         xloc = xloc.bar_index,
         color = color.new(_badgeBg, 35),
         width = 1)
    badge = label.new(badgeX, badgeY, _text,
         xloc = xloc.bar_index,
         style = _side > 0 ? label.style_label_down : label.style_label_up,
         textcolor = f_text_on(_badgeBg),
         color = color.new(_badgeBg, 0),
         size = labelSize)
    array.push(_labels, badge)
    array.push(_connectors, connector)
    if array.size(_labels) > _maxCount
        label.delete(array.shift(_labels))
        line.delete(array.shift(_connectors))
    badge

// -------------------------------------------------
// Session reset and opening range build
// -------------------------------------------------
if orStarts
    orHigh := high
    orLow := low
    orMid := hl2
    orStartBar := bar_index
    orEndBar := na
    orLocked := false
    breakDir := 0
    breakBar := na
    breakLevel := na
    retestResolved := false
    retestState := "Building OR"
    actionState := "WAIT"
    lastScore := na
    lastFailureRisk := na
    lastReadyLabelBar := na
    if not na(orBox)
        box.delete(orBox)
    if not na(retestBox)
        box.delete(retestBox)
    if not na(orHighLine)
        line.delete(orHighLine)
    if not na(orLowLine)
        line.delete(orLowLine)
    if not na(orMidLine)
        line.delete(orMidLine)
    if not na(targetOneLine)
        line.delete(targetOneLine)
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
    orBox := na
    retestBox := na
    orHighLine := na
    orLowLine := na
    orMidLine := na
    targetOneLine := na
    targetTwoLine := na
    if not na(tagHigh)
        label.delete(tagHigh)
        tagHigh := na
    if not na(tagLow)
        label.delete(tagLow)
        tagLow := na
    if not na(tagMid)
        label.delete(tagMid)
        tagMid := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    if not na(tagHighConnector)
        line.delete(tagHighConnector)
        tagHighConnector := na
    if not na(tagLowConnector)
        line.delete(tagLowConnector)
        tagLowConnector := na
    if not na(tagMidConnector)
        line.delete(tagMidConnector)
        tagMidConnector := na
    if not na(tagT1Connector)
        line.delete(tagT1Connector)
        tagT1Connector := na
    if not na(tagT2Connector)
        line.delete(tagT2Connector)
        tagT2Connector := na
    if not na(orCenterBadge)
        label.delete(orCenterBadge)
        orCenterBadge := na
    if not na(pocketCenterBadge)
        label.delete(pocketCenterBadge)
        pocketCenterBadge := na

if inOrEffective
    orHigh := math.max(nz(orHigh, high), high)
    orLow := math.min(nz(orLow, low), low)
    orMid := (orHigh + orLow) * 0.5

if orEnds and not na(orHigh) and not na(orLow)
    orEndBar := bar_index - 1
    orLocked := true
    retestState := "Range Locked"
    actionState := "WAIT"
    if showEventLabels and showRangeLockLabels
        f_add_owned_event(eventLabels, eventConnectors, bar_index, orHigh, 1,
             "OR LOCKED | " + sessionLabel, accentColor, eventLaneCounter, maxEventLabels)
        eventLaneCounter += 1

rangeSize = orLocked ? orHigh - orLow : na
rangeValid = orLocked and not na(rangeSize) and rangeSize > syminfo.mintick * 5
breakBuffer = atrSafe * breakBufferAtr
retestTol = atrSafe * retestToleranceAtr
failBuffer = atrSafe * failBufferAtr
canTrack = rangeValid and inTrackEffective and not inOrEffective

// -------------------------------------------------
// Opening range visuals
// -------------------------------------------------
orBoxBg = color.new(accentColor, 88)
orBorder = color.new(accentColor, 15)

if showOpeningRange and rangeValid
    if na(orBox)
        orBox := box.new(orStartBar, orHigh, bar_index + rangeExtendBars, orLow,
             xloc = xloc.bar_index,
             bgcolor = orBoxBg,
             border_color = orBorder,
             border_width = 1)
    else
        box.set_lefttop(orBox, orStartBar, orHigh)
        box.set_rightbottom(orBox, bar_index + rangeExtendBars, orLow)
    if showZoneBadges
        int orBadgeX = int(math.round((orStartBar + bar_index + rangeExtendBars) * 0.5))
        string orBadgeText = "OR | " + sessionLabel
        if na(orCenterBadge)
            orCenterBadge := label.new(orBadgeX, orMid, orBadgeText,
                 style = label.style_label_center,
                 textcolor = f_text_on(accentColor),
                 color = color.new(accentColor, 0),
                 size = labelSize)
        else
            label.set_xy(orCenterBadge, orBadgeX, orMid)
            label.set_text(orCenterBadge, orBadgeText)
            label.set_textcolor(orCenterBadge, f_text_on(accentColor))
            label.set_color(orCenterBadge, color.new(accentColor, 0))
            label.set_size(orCenterBadge, labelSize)
    else if not na(orCenterBadge)
        label.delete(orCenterBadge)
        orCenterBadge := na

    if na(orHighLine)
        orHighLine := line.new(orEndBar, orHigh, bar_index + rangeExtendBars, orHigh,
             xloc = xloc.bar_index,
             color = color.new(bullColor, 18),
             width = 1)
    else
        line.set_xy1(orHighLine, orEndBar, orHigh)
        line.set_xy2(orHighLine, bar_index + rangeExtendBars, orHigh)

    if na(orLowLine)
        orLowLine := line.new(orEndBar, orLow, bar_index + rangeExtendBars, orLow,
             xloc = xloc.bar_index,
             color = color.new(bearColor, 18),
             width = 1)
    else
        line.set_xy1(orLowLine, orEndBar, orLow)
        line.set_xy2(orLowLine, bar_index + rangeExtendBars, orLow)

    if showMidline
        if na(orMidLine)
            orMidLine := line.new(orEndBar, orMid, bar_index + rangeExtendBars, orMid,
                 xloc = xloc.bar_index,
                 color = color.new(neutralColor, 30),
                 width = 1,
                 style = line.style_dotted)
        else
            line.set_xy1(orMidLine, orEndBar, orMid)
            line.set_xy2(orMidLine, bar_index + rangeExtendBars, orMid)

// -------------------------------------------------
// Breakout and retest engine
// -------------------------------------------------
bullBreakEvent = canTrack and breakDir == 0 and close > orHigh + breakBuffer
bearBreakEvent = canTrack and breakDir == 0 and close < orLow - breakBuffer

if bullBreakEvent or bearBreakEvent
    breakDir := bullBreakEvent ? 1 : -1
    breakBar := bar_index
    breakLevel := bullBreakEvent ? orHigh : orLow
    retestResolved := false
    retestState := bullBreakEvent ? "Bull Break Watch" : "Bear Break Watch"
    actionState := "MONITOR"
    lastScore := na
    lastFailureRisk := na
    if not na(retestBox)
        box.delete(retestBox)
        retestBox := na
    pocketTop = breakDir == 1 ? breakLevel + retestTol : breakLevel + retestTol
    pocketBottom = breakDir == 1 ? breakLevel - retestTol : breakLevel - retestTol
    if showRetestPocket
        retestBox := box.new(bar_index, pocketTop, bar_index + pocketExtendBars, pocketBottom,
             xloc = xloc.bar_index,
             bgcolor = color.new(breakDir == 1 ? bullColor : bearColor, 88),
             border_color = color.new(breakDir == 1 ? bullColor : bearColor, 30),
             border_width = 1)
    if showEventLabels and showBreakWatchLabels
        eventOwnerY = breakDir == 1 ? high : low
        eventSide = breakDir == 1 ? 1 : -1
        eventBg = breakDir == 1 ? bullColor : bearColor
        f_add_owned_event(eventLabels, eventConnectors, bar_index, eventOwnerY, eventSide,
             breakDir == 1 ? "BULL BREAK | WATCH" : "BEAR BREAK | WATCH", eventBg, eventLaneCounter, maxEventLabels)
        eventLaneCounter += 1

barsSinceBreak = breakDir != 0 and not na(breakBar) ? bar_index - breakBar : na
touchPocket = breakDir == 1 ? low <= breakLevel + retestTol and high >= breakLevel - retestTol :
     breakDir == -1 ? high >= breakLevel - retestTol and low <= breakLevel + retestTol : false
holdRetest = breakDir == 1 ? touchPocket and close >= breakLevel :
     breakDir == -1 ? touchPocket and close <= breakLevel : false
failRetest = breakDir == 1 ? close < breakLevel - failBuffer :
     breakDir == -1 ? close > breakLevel + failBuffer : false
expiredRetest = breakDir != 0 and not retestResolved and not na(barsSinceBreak) and barsSinceBreak > retestWindowBars

timeScore = breakDir != 0 and not na(barsSinceBreak) ? f_clamp(18.0 * (1.0 - barsSinceBreak / math.max(retestWindowBars, 1)), 0.0, 18.0) : 0.0
touchScore = touchPocket ? 18.0 : 0.0
closeScore = holdRetest ? 24.0 : touchPocket ? 10.0 : 0.0
rvolScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 14.0 : 11.0
rangeAtrRatio = rangeValid and atrSafe > 0 ? rangeSize / atrSafe : 0.0
rangeScore = f_clamp(1.0 - math.abs(rangeAtrRatio - 1.0) / 1.5, 0.0, 1.0) * 12.0
targetOne = breakDir == 1 ? breakLevel + rangeSize * targetOneRange :
     breakDir == -1 ? breakLevel - rangeSize * targetOneRange : na
targetTwo = breakDir == 1 ? breakLevel + rangeSize * targetTwoRange :
     breakDir == -1 ? breakLevel - rangeSize * targetTwoRange : na
targetRoom = breakDir == 1 and not na(targetOne) ? (targetOne - close) / atrSafe :
     breakDir == -1 and not na(targetOne) ? (close - targetOne) / atrSafe : 0.0
roomScore = f_clamp(targetRoom / 1.2, 0.0, 1.0) * 14.0
candidateScore = f_clamp(touchScore + closeScore + timeScore + rvolScore + rangeScore + roomScore, 0.0, 100.0)
candidateRisk = f_clamp(100.0 - candidateScore + (failRetest ? 25.0 : 0.0), 0.0, 100.0)

readyEvent = canTrack and breakDir != 0 and not retestResolved and bar_index > breakBar and holdRetest and candidateScore >= requiredScore
weakTouchEvent = canTrack and breakDir != 0 and not retestResolved and bar_index > breakBar and touchPocket and not holdRetest and not failRetest
invalidatedEvent = canTrack and breakDir != 0 and not retestResolved and bar_index > breakBar and failRetest
expiredEvent = canTrack and expiredRetest

if breakDir != 0 and not retestResolved and (touchPocket or failRetest)
    lastScore := candidateScore
    lastFailureRisk := candidateRisk

if weakTouchEvent
    retestState := "Testing Pocket"
    actionState := "MONITOR"

if readyEvent
    retestResolved := true
    retestState := breakDir == 1 ? "Bull Retest Accepted" : "Bear Retest Accepted"
    actionState := "READY"
    lastScore := candidateScore
    lastFailureRisk := candidateRisk
    armReady := true
    armDir := breakDir
    armTarget := breakDir == 1 ? close + atrSafe : close - atrSafe
    armStop := breakDir == 1 ? close - atrSafe : close + atrSafe
    canReadyLabel = na(lastReadyLabelBar) or bar_index - lastReadyLabelBar >= labelCooldownBars
    if showEventLabels and canReadyLabel
        eventOwnerY = breakDir == 1 ? low : high
        eventSide = breakDir == 1 ? -1 : 1
        eventBg = breakDir == 1 ? bullColor : bearColor
        f_add_owned_event(eventLabels, eventConnectors, bar_index, eventOwnerY, eventSide,
             "READY | Q " + str.tostring(math.round(candidateScore)), eventBg, eventLaneCounter, maxEventLabels)
        eventLaneCounter += 1
        lastReadyLabelBar := bar_index
    if showTargetRails and not na(targetOne) and not na(targetTwo)
        if not na(targetOneLine)
            line.delete(targetOneLine)
        if not na(targetTwoLine)
            line.delete(targetTwoLine)
        targetOneLine := line.new(bar_index, targetOne, bar_index + targetExtendBars, targetOne,
             xloc = xloc.bar_index,
             color = color.new(neutralColor, 10),
             width = 1,
             style = line.style_dashed)
        targetTwoLine := line.new(bar_index, targetTwo, bar_index + targetExtendBars, targetTwo,
             xloc = xloc.bar_index,
             color = color.new(accentColor, 10),
             width = 1,
             style = line.style_dashed)

if invalidatedEvent
    retestResolved := true
    retestState := "Retest Invalidated"
    actionState := "INVALIDATED"
    lastScore := candidateScore
    lastFailureRisk := candidateRisk
    if showEventLabels and showFailureLabels
        eventOwnerY = breakDir == 1 ? low : high
        eventSide = breakDir == 1 ? -1 : 1
        f_add_owned_event(eventLabels, eventConnectors, bar_index, eventOwnerY, eventSide,
             "INVALIDATED | BACK INSIDE OR", bearColor, eventLaneCounter, maxEventLabels)
        eventLaneCounter += 1

if expiredEvent
    retestResolved := true
    retestState := "Retest Expired"
    actionState := "EXPIRED"
    lastFailureRisk := 70.0
    if showEventLabels and showFailureLabels
        eventOwnerY = breakDir == 1 ? low : high
        eventSide = breakDir == 1 ? -1 : 1
        f_add_owned_event(eventLabels, eventConnectors, bar_index, eventOwnerY, eventSide,
             "EXPIRED | NO CLEAN RETEST", panelBorder, eventLaneCounter, maxEventLabels)
        eventLaneCounter += 1

if not rangeValid and not inOrEffective
    actionState := "BLOCKED"
    retestState := "No Valid OR"

// -------------------------------------------------
// Stop-aware target-proof engine (confirmed bars only)
// Of accepted READY retests, the share that reach Target 1 before failing back
// inside the opening range. Resolve the open slot first, then arm a new one.
// -------------------------------------------------
if barstate.isconfirmed
    if proofPending
        proofWin = proofDir == 1 ? high >= proofTarget : low <= proofTarget
        proofLoss = proofDir == 1 ? low <= proofStop : high >= proofStop
        proofTimeout = not na(proofOpenBar) and (bar_index - proofOpenBar) > retestWindowBars * 3
        if proofWin
            proofWins += 1
            proofTotal += 1
            proofPending := false
        else if proofLoss
            proofTotal += 1
            proofPending := false
        else if proofTimeout
            proofPending := false
    if armReady and not proofPending and not na(armTarget)
        proofDir := armDir
        proofTarget := armTarget
        proofStop := armStop
        proofOpenBar := bar_index
        proofPending := true
    armReady := false

if showZoneBadges and showRetestPocket and breakDir != 0 and not na(retestBox)
    int pocketBadgeX = int(math.round((box.get_left(retestBox) + box.get_right(retestBox)) * 0.5))
    float pocketBadgeY = (box.get_top(retestBox) + box.get_bottom(retestBox)) * 0.5
    string pocketScoreText = na(lastScore) ? "" : " | Q " + str.tostring(math.round(lastScore))
    string pocketBadgeText = (breakDir == 1 ? "BULL RETEST" : "BEAR RETEST") + " | " + actionState + pocketScoreText
    if na(pocketCenterBadge)
        pocketCenterBadge := label.new(pocketBadgeX, pocketBadgeY, pocketBadgeText,
             style = label.style_label_center,
             textcolor = f_text_on(breakDir == 1 ? bullColor : bearColor),
             color = color.new(breakDir == 1 ? bullColor : bearColor, 0),
             size = labelSize)
    else
        label.set_xy(pocketCenterBadge, pocketBadgeX, pocketBadgeY)
        label.set_text(pocketCenterBadge, pocketBadgeText)
        label.set_textcolor(pocketCenterBadge, f_text_on(breakDir == 1 ? bullColor : bearColor))
        label.set_color(pocketCenterBadge, color.new(breakDir == 1 ? bullColor : bearColor, 0))
        label.set_size(pocketCenterBadge, labelSize)
else if not na(pocketCenterBadge)
    label.delete(pocketCenterBadge)
    pocketCenterBadge := na

// -------------------------------------------------
// Boundary-owned OR and target badges
// -------------------------------------------------
if barstate.islast and showRightTags and rangeValid
    orRight = bar_index + rangeExtendBars
    orTagX = orRight + rightTagOffsetBars
    gap = math.max(atrSafe * rightTagMinGapAtr * labelLaneMult, syminfo.mintick * 20.0)
    yMid = orMid
    yHigh = math.max(orHigh, yMid + gap)
    yLow = math.min(orLow, yMid - gap)
    showTargets = showTargetRails and retestResolved and actionState == "READY" and not na(targetOne) and not na(targetTwo) and not na(targetOneLine) and not na(targetTwoLine)
    targetAnchorX = showTargets ? line.get_x2(targetOneLine) : bar_index + targetExtendBars
    targetTagX = targetAnchorX + rightTagOffsetBars
    yT1 = targetOne
    yT2 = targetTwo
    if showTargets and breakDir == 1 and yT2 - yT1 < gap
        yT2 := yT1 + gap
    else if showTargets and breakDir == -1 and yT1 - yT2 < gap
        yT2 := yT1 - gap

    if not na(tagHigh)
        label.delete(tagHigh)
    if not na(tagLow)
        label.delete(tagLow)
    if not na(tagMid)
        label.delete(tagMid)
    if not na(tagT1)
        label.delete(tagT1)
    if not na(tagT2)
        label.delete(tagT2)
    if not na(tagHighConnector)
        line.delete(tagHighConnector)
    if not na(tagLowConnector)
        line.delete(tagLowConnector)
    if not na(tagMidConnector)
        line.delete(tagMidConnector)
    if not na(tagT1Connector)
        line.delete(tagT1Connector)
    if not na(tagT2Connector)
        line.delete(tagT2Connector)
    tagHigh := na
    tagLow := na
    tagMid := na
    tagT1 := na
    tagT2 := na
    tagHighConnector := na
    tagLowConnector := na
    tagMidConnector := na
    tagT1Connector := na
    tagT2Connector := na

    highBg = color.new(bullColor, 12)
    lowBg = color.new(bearColor, 12)
    midBg = color.new(neutralColor, 12)
    tagHighConnector := line.new(orRight, orHigh, orTagX, yHigh,
         xloc = xloc.bar_index,
         color = color.new(bullColor, 25),
         width = 1)
    tagLowConnector := line.new(orRight, orLow, orTagX, yLow,
         xloc = xloc.bar_index,
         color = color.new(bearColor, 25),
         width = 1)
    tagHigh := label.new(orTagX, yHigh,
         "OR HIGH | " + str.tostring(orHigh, format.mintick),
         style = label.style_label_left,
         textcolor = f_text_on(highBg),
         color = highBg,
         size = labelSize)
    tagLow := label.new(orTagX, yLow,
         "OR LOW | " + str.tostring(orLow, format.mintick),
         style = label.style_label_left,
         textcolor = f_text_on(lowBg),
         color = lowBg,
         size = labelSize)
    if showMidline
        tagMidConnector := line.new(orRight, orMid, orTagX, yMid,
             xloc = xloc.bar_index,
             color = color.new(neutralColor, 25),
             width = 1)
        tagMid := label.new(orTagX, yMid,
             "OR MID | " + str.tostring(orMid, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(midBg),
             color = midBg,
             size = labelSize)
    if showTargets
        tagT1Connector := line.new(targetAnchorX, targetOne, targetTagX, yT1,
             xloc = xloc.bar_index,
             color = color.new(neutralColor, 25),
             width = 1)
        tagT2Connector := line.new(targetAnchorX, targetTwo, targetTagX, yT2,
             xloc = xloc.bar_index,
             color = color.new(accentColor, 25),
             width = 1)
        tagT1 := label.new(targetTagX, yT1,
             "T1 | " + str.tostring(targetOne, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(neutralColor),
             color = color.new(neutralColor, 8),
             size = labelSize)
        tagT2 := label.new(targetTagX, yT2,
             "T2 | " + str.tostring(targetTwo, format.mintick),
             style = label.style_label_left,
             textcolor = f_text_on(accentColor),
             color = color.new(accentColor, 8),
             size = labelSize)
else if barstate.islast
    if not na(tagHigh)
        label.delete(tagHigh)
        tagHigh := na
    if not na(tagLow)
        label.delete(tagLow)
        tagLow := na
    if not na(tagMid)
        label.delete(tagMid)
        tagMid := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    if not na(tagHighConnector)
        line.delete(tagHighConnector)
        tagHighConnector := na
    if not na(tagLowConnector)
        line.delete(tagLowConnector)
        tagLowConnector := na
    if not na(tagMidConnector)
        line.delete(tagMidConnector)
        tagMidConnector := na
    if not na(tagT1Connector)
        line.delete(tagT1Connector)
        tagT1Connector := na
    if not na(tagT2Connector)
        line.delete(tagT2Connector)
        tagT2Connector := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBgFinal = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
panelLeftFinal = panelTheme == "Dark" ? color.new(panelBorder, 0) : color.rgb(226, 232, 240)
panelTextFinal = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
panelLabelFinal = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
rangeText = rangeValid ? str.tostring(rangeSize, format.mintick) : "n/a"
sideText = breakDir == 1 ? "Bullish" : breakDir == -1 ? "Bearish" : "Neutral"
scoreText = f_score_text(lastScore)
riskText = na(lastFailureRisk) ? "n/a" : str.tostring(math.round(lastFailureRisk)) + "/100"
acceptanceText = retestState
acceptanceBg = breakDir == 1 ? color.new(bullColor, 12) : breakDir == -1 ? color.new(bearColor, 12) : color.new(neutralColor, 18)
acceptanceInk = f_text_on(breakDir == 1 ? bullColor : breakDir == -1 ? bearColor : neutralColor)
actionBg = f_action_color(actionState)
actionInk = f_text_on(actionBg)

proofReadyPanel = proofTotal >= 6
proofRatePanel = proofTotal > 0 ? proofWins / proofTotal * 100.0 : na
proofColPanel = not proofReadyPanel ? panelLabelFinal : proofRatePanel >= 55.0 ? bullColor : proofRatePanel >= 45.0 ? neutralColor : bearColor
proofTxtPanel = not proofReadyPanel ? "Building (" + str.tostring(proofTotal) + ")" : str.tostring(math.round(proofRatePanel)) + "% (n=" + str.tostring(proofTotal) + ")"
proofBgPanel = proofReadyPanel ? color.new(proofColPanel, 12) : panelBgFinal
proofInkPanel = proofReadyPanel ? f_text_on(proofColPanel) : panelLabelFinal

var table panel = table.new(position.top_right, 2, 8, border_width = 1)

if showPanel and barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.set_border_color(panel, panelBorder)
    table.set_frame_color(panel, panelBorder)
    table.cell(panel, 0, 0, "AG Pro Opening Range Retest Planner",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelSize)
    table.cell(panel, 1, 0, "",
         text_color = headerText,
         bgcolor = headerBg,
         text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 1, "OR State",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 1, retestState,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 2, "Retest Score",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 2, scoreText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 3, "Acceptance",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 3, sideText,
         text_color = acceptanceInk,
         bgcolor = acceptanceBg,
         text_size = panelSize)
    table.cell(panel, 0, 4, "Failure Risk",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 4, riskText,
         text_color = panelTextFinal,
         bgcolor = panelBgFinal,
         text_size = panelSize)
    table.cell(panel, 0, 5, "Action",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 5, actionState,
         text_color = actionInk,
         bgcolor = actionBg,
         text_size = panelSize)
    table.merge_cells(panel, 0, 6, 1, 6)
    table.cell(panel, 0, 6, "— RETEST PROOF —",
         text_color = accentColor,
         bgcolor = panelBgFinal,
         text_size = panelSize,
         text_halign = text.align_center)
    table.cell(panel, 0, 7, "Follow-Through",
         text_color = panelLabelFinal,
         bgcolor = panelLeftFinal,
         text_size = panelSize)
    table.cell(panel, 1, 7, proofTxtPanel,
         text_color = proofInkPanel,
         bgcolor = proofBgPanel,
         text_size = panelSize)

if not showPanel and barstate.islast
    table.clear(panel, 0, 0, 1, 7)

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
barStateColor = actionState == "READY" ? color.new(breakDir == 1 ? bullColor : bearColor, 72) :
     actionState == "MONITOR" ? color.new(accentColor, 82) :
     actionState == "INVALIDATED" ? color.new(bearColor, 76) :
     actionState == "EXPIRED" ? color.new(panelBorder, 78) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertReady and readyEvent and breakDir == 1, "Bullish Opening Range Retest Ready",
     "AG Pro ORR | BULL RETEST READY | {{ticker}} | {{interval}}")
alertcondition(alertReady and readyEvent and breakDir == -1, "Bearish Opening Range Retest Ready",
     "AG Pro ORR | BEAR RETEST READY | {{ticker}} | {{interval}}")
alertcondition(alertInvalidated and invalidatedEvent, "Opening Range Retest Invalidated",
     "AG Pro ORR | RETEST INVALIDATED | {{ticker}} | {{interval}}")
alertcondition(alertExpired and expiredEvent, "Opening Range Retest Expired",
     "AG Pro ORR | RETEST EXPIRED | {{ticker}} | {{interval}}")
````
