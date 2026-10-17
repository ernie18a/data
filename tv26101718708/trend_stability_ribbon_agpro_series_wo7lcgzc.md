# Trend Stability Ribbon [AGPro Series]

- url: https://www.tradingview.com/script/wO7lCGZC-Trend-Stability-Ribbon-AGPro-Series/
- type: indicator
- pine_id: PUB;bfb98a7f6417450ca58f56f463f6ceba
- version: 8.0

## Description

Trend Stability Ribbon [AGPro Series]

🔹 OVERVIEW

Most trend tools tell you WHICH WAY price is going. Trend Stability Ribbon tells you HOW WELL it is getting there. By pairing an ATR-normalized slope engine with a Kaufman path-efficiency score, it projects every bar into one of four rules-based states — Stable Up, Noisy Up, Stable Down, Noisy Down — and paints them onto a clean, adaptive ribbon that stays out of the candles' way. The result is a context layer that separates decisive trending from directional-but-choppy travel, without adding a second indicator pane.


🧭 UNIQUE EDGE — WHY THIS IS NOT "JUST ANOTHER TREND INDICATOR"

Direction alone is cheap. Every moving-average cross, every supertrend, every slope color tells you "up" or "down" — and then leaves you holding the bag when the trend is technically up but structurally a mess.

Trend Stability Ribbon adds the missing second dimension: path quality. The same 34-bar window that defines direction also feeds a Kaufman efficiency calculation (net travel divided by total path travel). An ER near 1.00 means price walked a near-straight line; an ER near 0.00 means it zig-zagged its way to the same point. Mapping that score against a calibrated threshold band produces the four composite states — and a visual language that finally distinguishes "trend worth trusting" from "trend worth fading".

Additional design choices that set it apart:

• Dual-layer event engine — direction flips, stability upgrades, and stability downgrades are tracked as independent transitions, each with its own alert.
• Badge/alert separation — on-chart badges are throttled by a cooldown for visual hygiene, but alerts are always raw so automation pipelines never miss an event.
• Reset state — when the slope-confirmation filter rejects a direction, the ribbon goes neutral instead of flipping false. Chop gets ignored, not misreported.


🧪 METHODOLOGY

1. TREND DIRECTION ENGINE
   • A slow EMA (default length 34) anchors the trend path and serves as the ribbon centerline.
   • Slope is measured over a 3-bar lookback and normalized by a 14-period ATR, making it instrument-agnostic across crypto, FX, equities, and futures.
   • With Slope Confirmation enabled (default), direction is only accepted when price position AND slope agree. Disagreement returns a Reset state.

2. PATH EFFICIENCY (STABILITY) ENGINE
   • ER = |close − close[N]| ÷ Σ|close[i] − close[i-1]| over the same trend window.
   • Three classes: Stable (ER ≥ 0.45), Noisy (ER ≤ 0.25), Mixed (between). Thresholds scale with the Stability Sensitivity input.
   • The Mixed zone is a deliberate dead-band — during uncertain phases the previous state persists rather than flickering.

3. COMPOSITE STATE MACHINE
   • Direction × Stability yields five possible states: Stable Up, Noisy Up, Stable Down, Noisy Down, Reset.
   • Bars-in-state is tracked live, giving a simple persistence read on each state.

4. RIBBON RENDERING
   • Ribbon is anchored to the EMA centerline with height driven by ATR × a user-selected multiplier (Thin / ATR-Adaptive / Thick).
   • Fill opacity and border weight shift by state — Stable states are saturated, Noisy states are faded, Reset is a soft amber.


🔔 SIGNALS & ALERTS

Three transition events are detected and exposed as separate, user-toggled alerts:

• Trend State Flipped — direction changed (Up ↔ Down). Raw, never throttled.
• Stability Improved — path upgraded from Noisy to Stable while direction held. Raw — delivered regardless of badge cooldown.
• Stability Degraded — path downgraded from Stable to Noisy while direction held. Raw — delivered regardless of badge cooldown.

Matching on-chart badges appear at the same moments, subject to the Stability Badge Cooldown for visual cleanliness. Direction-flip badges are never throttled.


⚙️ KEY INPUTS

Engine
• Trend Length (default 34) — lookback for both direction and path-efficiency windows.
• Stability Sensitivity (default 1.0) — scales the Stable / Noisy thresholds.
• Require Slope Confirmation (default on) — enforces price-and-slope agreement; rejects chop.

Ribbon & Badge
• Ribbon Height — Thin / ATR-Adaptive / Thick.
• Show State Badge — toggle on-chart transition labels.
• Label Font Size — tiny / small / normal / large (default normal).
• Minimal Mode — hides panel and badges for pairing with other overlays.
• Stability Badge Cooldown (default 5 bars) — visual throttle for stability transitions.

Info Panel
• Panel Position, Panel Font Size, Efficiency Ratio display, Active Thresholds display.

Alerts
• Independent toggles for each of the three transition events.


🧠 HOW TO USE

• CONTEXT FILTER — use Stable states as a "green light" for continuation setups on your primary system; treat Noisy states as a headwind.
• REGIME BREAKS — a Stability Degraded event mid-trend is often an early warning that the move is maturing, even before price has flipped.
• CLEAN ENTRIES — pair a direction flip (Trend Up / Trend Down) with an immediate Stable classification to filter out whipsaw-prone breakouts.
• CHOP AVOIDANCE — when the ribbon sits in a Reset or Mixed state, the script is telling you the underlying path is not tradeable as a trend. Stand aside or switch to range tactics.
• PAIRING — with Minimal Mode on, the ribbon layers cleanly under structure tools, VWAPs, or S/R zones without visual conflict.


⚠️ LIMITATIONS & TRANSPARENCY

• This is an indicator, NOT a strategy. It does not generate buy or sell orders, has no backtest, and makes no claim of performance.
• Efficiency Ratio is a lagging measure — it describes the path already travelled. The ribbon should be read as context, not as a leading signal.
• The Mixed zone is intentional persistence; expect the composite state to hold through brief chop rather than flipping on every bar.
• Lower timeframes (<5m on thin-liquidity markets) can push ER values into erratic ranges. Start with the defaults on 15m–4h and tune from there.
• All calculations are closed-bar. Intra-bar values may shift until the bar confirms.


🛡️ RISK DISCLOSURE

This script is published for educational and analytical purposes only. It is not financial advice, not a signal service, and not a solicitation to buy or sell any instrument. Past behavior of markets does not predict future results. Always do your own research, apply proper risk management, and consult a licensed professional before making trading decisions. The author assumes no responsibility for losses incurred through use of this indicator.

## Source Code

````pine
// -------------------------------------------------
// Trend Stability Ribbon [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7.1
//
// Trend Stability Ribbon classifies not only trend direction, but the quality
// of that trend path. It combines Kaufman-style path efficiency with an
// ATR-normalized slope engine, then maps stable up, noisy up, stable down,
// noisy down, and mixed conditions onto a clean adaptive price ribbon, and adds
// a confirmation-anchored proof layer (Follow, Hold, React, Flip rates) that
// shows how past directional calls on this symbol followed through and held.
// -------------------------------------------------

//@version=6
indicator("Trend Stability Ribbon [AGPro Series]",
     shorttitle = "AG Pro TSR",
     overlay = true,
     max_labels_count = 100,
     max_lines_count = 20,
     max_boxes_count = 10)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Input groups
// -------------------------------------------------
string gEngine = "Engine"
string gVisual = "Visual Layer"
string gLabels = "Labels"
string gPanel  = "Panel"
string gProof  = "Proof"
string gAlerts = "Alerts"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
int trendLen = input.int(34, "Trend Length", minval = 5, maxval = 200, group = gEngine, tooltip = "Lookback used for the trend direction engine and path-efficiency window.")
float stabSens = input.float(1.0, "Stability Sensitivity", minval = 0.4, maxval = 2.0, step = 0.1, group = gEngine, tooltip = "Scales the stable and noisy thresholds used by the path-efficiency classifier.")
bool useSlopeConfirm = input.bool(true, "Require Slope Confirmation", group = gEngine, tooltip = "Requires EMA slope to agree with price position before a trend direction is accepted.")
int slopeLookback = input.int(3, "Slope Lookback", minval = 1, maxval = 20, group = gEngine, tooltip = "Bars used to measure the ATR-normalized EMA slope.")

string ribbonMode = input.string("ATR-Adaptive", "Ribbon Height", options = ["Thin", "ATR-Adaptive", "Thick"], group = gVisual, tooltip = "Controls the vertical thickness of the stability ribbon.")
bool showRibbonCore = input.bool(true, "Show Ribbon Core Line", group = gVisual, tooltip = "Displays a thin center line through the stability ribbon.")
bool showRibbonFill = input.bool(true, "Show Ribbon Fill", group = gVisual, tooltip = "Displays the filled stability ribbon around the trend basis.")
bool showGlow = input.bool(true, "Show Ribbon Glow", group = gVisual, tooltip = "Adds a soft outer glow around the stability ribbon for better first-glance readability.")
bool showBarTint = input.bool(true, "Tint Bars by State", group = gVisual, tooltip = "Applies a subtle candle tint according to the current stability state.")
bool showLiveTags = input.bool(true, "Show Live Status Card", group = gVisual, tooltip = "Shows a single right-edge status card with the current trend stability state, stability score, and efficiency ratio.")
int rightTagOffset = input.int(5, "Right Tag Offset", minval = 2, maxval = 24, group = gVisual, tooltip = "Controls how far the live status card is placed from the latest candle.")

bool showStateLabels = input.bool(true, "Show State Labels", group = gLabels, tooltip = "Prints labels on meaningful direction or stability transitions.")
string labelDensity = input.string("Detailed", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gLabels, tooltip = "Controls how many state labels are retained on the chart.")
string labelTextInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLabels, tooltip = "Text size for on-chart state labels.")
float labelOffsetATR = input.float(1.05, "Label Offset (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = gLabels, tooltip = "ATR-based spacing used to keep labels away from candles.")
int stabilityCooldown = input.int(14, "Stability Label Cooldown", minval = 0, maxval = 100, group = gLabels, tooltip = "Minimum bars between repeated stability labels. Direction flips are not throttled.")

bool showPanel = input.bool(true, "Show Panel", group = gPanel, tooltip = "Displays the AG Pro trend stability panel.")
string panelPos = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel, tooltip = "Panel placement on the chart.")
string panelTheme = input.string("Auto", "Panel Theme", options = ["Auto", "Dark", "Light"], group = gPanel, tooltip = "Panel theme. Auto adapts to the chart background.")
string panelTextInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = gPanel, tooltip = "Text size used inside the panel.")
bool showThresholds = input.bool(false, "Show Thresholds", group = gPanel, tooltip = "Displays the active stable and noisy thresholds in the panel.")

bool showProof = input.bool(true, "Show Proof Layer", group = gProof, tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across past directional calls on the current symbol and timeframe. These are historical outcome rates, not predictions.")
int proofHorizonBars = input.int(20, "Proof Horizon Bars", minval = 5, maxval = 200, group = gProof, tooltip = "Number of bars each new directional call is tracked forward to measure whether the direction held and followed through.")
float proofFollowAtr = input.float(1.20, "Proof Follow-Through ATR", minval = 0.30, maxval = 8.0, step = 0.05, group = gProof, tooltip = "Favorable distance, in ATR from the call's close, that counts as a follow-through (Follow).")
int reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 40, group = gProof, tooltip = "Number of bars after a directional call used to detect an immediate favorable reaction.")
float reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = gProof, tooltip = "Minimum favorable progress toward the follow-through distance, within the reaction window, required to count as an early React.")

bool alertFlip = input.bool(true, "Alert: Trend Flip", group = gAlerts, tooltip = "Triggers when trend direction flips between up and down.")
bool alertImproved = input.bool(true, "Alert: Stability Improved", group = gAlerts, tooltip = "Triggers when stability improves from noisy or mixed into stable while direction persists.")
bool alertDegraded = input.bool(true, "Alert: Stability Degraded", group = gAlerts, tooltip = "Triggers when stability degrades into noisy while direction persists.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_dark_mode(string mode) =>
    lum = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
    mode == "Dark" ? true : mode == "Light" ? false : lum < 140

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)

f_trim_labels(array<label> items, int keep) =>
    while array.size(items) > keep
        label oldItem = array.shift(items)
        if not na(oldItem)
            label.delete(oldItem)

f_state_text(int state) =>
    switch state
        1 => "Stable Up"
        2 => "Noisy Up"
        -1 => "Stable Down"
        -2 => "Noisy Down"
        => "Mixed"

f_state_short(int state) =>
    f_state_text(state)

f_state_color(int state) =>
    switch state
        1 => bullColor
        2 => color.new(bullColor, 28)
        -1 => bearColor
        -2 => color.new(bearColor, 28)
        => neutralColor

f_state_score(int state, float erValue, float stableTh, float noisyTh) =>
    state == 1 or state == -1 ? int(math.round(math.min(100.0, erValue / stableTh * 100.0))) : state == 2 or state == -2 ? int(math.round(math.max(0.0, erValue / math.max(noisyTh, 0.01) * 45.0))) : int(math.round(erValue * 100.0))

f_workflow_text(int state) =>
    switch state
        1 => "Stable Path"
        -1 => "Stable Path"
        2 => "Noisy Path"
        -2 => "Noisy Path"
        => "Mixed Path"

f_dir_tag(int state) =>
    switch state
        1 => "Up"
        2 => "Up"
        -1 => "Down"
        -2 => "Down"
        => "Mixed"

// -------------------------------------------------
// Engine
// -------------------------------------------------
labelSize = f_size(labelTextInput)
panelSize = f_size(panelTextInput)

emaSlow = ta.ema(close, trendLen)
atr = math.max(nz(ta.atr(14), syminfo.mintick * 20.0), syminfo.mintick)
slopeRaw = emaSlow - nz(emaSlow[slopeLookback], emaSlow)
slopeNorm = slopeRaw / atr

priceAbove = close > emaSlow
priceBelow = close < emaSlow
slopeUp = slopeNorm > 0.0
slopeDown = slopeNorm < 0.0
dirUp = useSlopeConfirm ? priceAbove and slopeUp : priceAbove
dirDown = useSlopeConfirm ? priceBelow and slopeDown : priceBelow
dirCode = dirUp ? 1 : dirDown ? -1 : 0

netMove = math.abs(close - nz(close[trendLen], close))
sumMove = nz(math.sum(math.abs(close - nz(close[1], close)), trendLen), 0.0)
er = sumMove > 0.0 ? f_clamp(netMove / sumMove, 0.0, 1.0) : 0.0

baseStable = 0.45
baseNoisy = 0.25
thStable = math.max(0.05, math.min(0.95, baseStable / stabSens))
thNoisy = math.max(0.0, math.min(thStable - 0.05, baseNoisy / stabSens))
stabClass = er >= thStable ? 2 : er <= thNoisy ? 0 : 1

// Assign every bar explicitly. Intermediate efficiency is Mixed rather than
// inheriting a stale stable/noisy state from an earlier bar.
var int state = 0
state := dirCode == 1 ? (stabClass == 2 ? 1 : stabClass == 0 ? 2 : 0) :
         dirCode == -1 ? (stabClass == 2 ? -1 : stabClass == 0 ? -2 : 0) : 0

prevState = nz(state[1], 0)
var int barsInState = 0
barsInState := state == prevState ? barsInState + 1 : 1

// Track the last confirmed non-zero direction so flips are detected even when
// price passes through a temporary Mixed/neutral state.
var int lastConfirmedDirection = 0
bool directionCall = barstate.isconfirmed and dirCode != 0 and dirCode != lastConfirmedDirection
bool dirFlip = directionCall and lastConfirmedDirection != 0
bool stabImproved = barstate.isconfirmed and dirCode != 0 and dirCode == nz(dirCode[1], dirCode) and stabClass == 2 and nz(stabClass[1], stabClass) != 2
bool stabDegraded = barstate.isconfirmed and dirCode != 0 and dirCode == nz(dirCode[1], dirCode) and stabClass == 0 and nz(stabClass[1], stabClass) != 0

if barstate.isconfirmed and dirCode != 0
    lastConfirmedDirection := dirCode

stateColor = f_state_color(state)
stateText = f_state_text(state)
stateScore = f_state_score(state, er, thStable, thNoisy)
workflowText = f_workflow_text(state)

// -------------------------------------------------
// Confirmation-anchored proof (directional follow-through)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool evalActive = false
var int evalDir = 0
var int evalStartBar = na
var float evalEntry = na
var float evalTarget = na
var bool evalReacted = false
var bool evalFollowed = false

int proofWarmup = trendLen + math.max(slopeLookback, 14) + 5
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

if barstate.isconfirmed and bar_index > proofWarmup
    if evalActive
        int heldBars = bar_index - evalStartBar
        float followDist = math.max(math.abs(evalTarget - evalEntry), syminfo.mintick)
        float favorableExcursion = evalDir == 1 ? high - evalEntry : evalEntry - low
        bool hitTarget = heldBars >= 1 and favorableExcursion >= followDist
        bool reversed = directionCall and dirCode == -evalDir
        bool ambiguousNow = hitTarget and reversed

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            evalReacted := true
        if hitTarget and not reversed
            evalFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or hitTarget or reversed or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if evalFollowed
                    proofFollow := proofFollow + 1
                if not reversed
                    proofHold := proofHold + 1
                if evalReacted
                    proofReact := proofReact + 1
                if reversed
                    proofFlip := proofFlip + 1
            evalActive := false

    // Start exactly one evaluation for each confirmed non-zero directional call.
    if directionCall and not evalActive
        evalActive := true
        evalDir := dirCode
        evalEntry := close
        evalTarget := close + dirCode * atr * proofFollowAtr
        evalStartBar := bar_index
        evalReacted := false
        evalFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Ribbon rendering
// -------------------------------------------------
ribAtrMult = ribbonMode == "Thin" ? 0.08 : ribbonMode == "ATR-Adaptive" ? 0.18 : 0.32
ribHeight = atr * ribAtrMult
ribCenter = emaSlow
ribTop = ribCenter + ribHeight
ribBot = ribCenter - ribHeight
glowTop = ribCenter + ribHeight * 1.85
glowBot = ribCenter - ribHeight * 1.85

pGlowTop = plot(showGlow ? glowTop : na, "Outer Ribbon Top", color = color.new(stateColor, 100), linewidth = 1)
pGlowBot = plot(showGlow ? glowBot : na, "Outer Ribbon Bottom", color = color.new(stateColor, 100), linewidth = 1)
pTop = plot(showRibbonFill ? ribTop : na, "Ribbon Top", color = color.new(stateColor, 78), linewidth = 1)
pBot = plot(showRibbonFill ? ribBot : na, "Ribbon Bottom", color = color.new(stateColor, 78), linewidth = 1)
pCore = plot(showRibbonCore ? ribCenter : na, "Ribbon Core", color = color.new(stateColor, state == 0 ? 48 : 12), linewidth = 2)

fill(pGlowTop, pGlowBot, color = showGlow ? color.new(stateColor, state == 0 ? 97 : 94) : na, title = "Ribbon Glow")
fill(pTop, pBot, color = showRibbonFill ? color.new(stateColor, state == 0 ? 92 : state == 1 or state == -1 ? 80 : 88) : na, title = "Ribbon Fill")

barcolor(showBarTint ? color.new(stateColor, state == 0 ? 88 : 78) : na)

// -------------------------------------------------
// State labels
// -------------------------------------------------
var label[] stateLabels = array.new_label()
var int lastStabilityLabelBar = na
labelKeep = labelDensity == "Detailed" ? 8 : labelDensity == "Balanced" ? 5 : 3
stabilityCooldownOk = stabilityCooldown == 0 or na(lastStabilityLabelBar) or bar_index - lastStabilityLabelBar >= stabilityCooldown
fireFlip = dirFlip
fireImproved = not dirFlip and stabImproved and stabilityCooldownOk
fireDegraded = not dirFlip and not stabImproved and stabDegraded and stabilityCooldownOk
placeLabel = showStateLabels and barstate.isconfirmed and (fireFlip or fireImproved or fireDegraded)

if placeLabel
    labelText = fireFlip ? (dirCode == 1 ? "Trend Up" : "Trend Down") : fireImproved ? (dirCode == 1 ? "Stable Up" : "Stable Down") : (dirCode == 1 ? "Noisy Up" : "Noisy Down")
    labelColor = fireFlip ? (dirCode == 1 ? bullColor : bearColor) : stateColor
    labelY = dirCode >= 0 ? high + atr * (labelOffsetATR + 0.28) : low - atr * (labelOffsetATR + 0.28)
    labelStyle = dirCode >= 0 ? label.style_label_down : label.style_label_up
    lb = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(labelColor, 0), textcolor = headerText, size = labelSize)
    array.push(stateLabels, lb)
    f_trim_labels(stateLabels, labelKeep)
    if fireImproved or fireDegraded
        lastStabilityLabelBar := bar_index

var label liveStatusTag = na
var line liveConnector = na

if showLiveTags and barstate.islast
    tagX = bar_index + rightTagOffset
    anchorY = dirCode == -1 ? ribBot : ribTop
    statusText = workflowText + " | " + f_dir_tag(state) + "\nStability " + str.tostring(stateScore) + "\nEfficiency " + str.tostring(er, "#.00")
    tagTextColor = f_text_on(stateColor)

    if na(liveStatusTag)
        liveStatusTag := label.new(tagX, anchorY, statusText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 0), textcolor = tagTextColor, size = labelSize, textalign = text.align_left)
    else
        label.set_xy(liveStatusTag, tagX, anchorY)
        label.set_text(liveStatusTag, statusText)
        label.set_color(liveStatusTag, color.new(stateColor, 0))
        label.set_textcolor(liveStatusTag, tagTextColor)
        label.set_size(liveStatusTag, labelSize)
        label.set_textalign(liveStatusTag, text.align_left)

    if na(liveConnector)
        liveConnector := line.new(bar_index, anchorY, tagX, anchorY, xloc = xloc.bar_index, extend = extend.none, color = color.new(stateColor, 35), style = line.style_solid, width = 1)
    else
        line.set_xy1(liveConnector, bar_index, anchorY)
        line.set_xy2(liveConnector, tagX, anchorY)
        line.set_color(liveConnector, color.new(stateColor, 35))
else if not showLiveTags
    if not na(liveStatusTag)
        label.delete(liveStatusTag)
        liveStatusTag := na
    if not na(liveConnector)
        line.delete(liveConnector)
        liveConnector := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
darkPanel = f_dark_mode(panelTheme)
panelFrame = darkPanel ? panelBorder : color.rgb(203, 213, 225)
leftBg = darkPanel ? color.rgb(13, 22, 38) : color.rgb(241, 245, 249)
rightBg = darkPanel ? color.rgb(8, 15, 28) : color.rgb(255, 255, 255)
leftTxt = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
rightTxt = darkPanel ? panelValueCol : color.rgb(15, 23, 42)
stateBg = color.new(stateColor, darkPanel ? 28 : 84)
scoreBg = stateScore >= 70 ? color.new(stateColor, darkPanel ? 30 : 84) : stateScore >= 35 ? color.new(neutralColor, darkPanel ? 32 : 86) : rightBg
dirText = dirCode == 1 ? "Up" : dirCode == -1 ? "Down" : "Reset"
stabText = stabClass == 2 ? "Stable" : stabClass == 0 ? "Noisy" : "Mixed"
thresholdText = str.tostring(thStable, "#.00") + " / " + str.tostring(thNoisy, "#.00")

int panelRowCount = showProof ? 12 : 7
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
string followText = proofTotal > 0 ? f_pct(followRate) : "-"
string holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
color followCol = proofTotal > 0 ? f_rate_color(followRate) : rightTxt
color holdCol = proofTotal > 0 ? f_rate_color(holdRate) : rightTxt
color reactCol = proofTotal > 0 ? f_rate_color(reactRate) : rightTxt
color flipCol = proofTotal > 0 ? f_flip_color(flipRate) : rightTxt

var table panel = table.new(position.top_right, 2, panelRowCount, frame_color = panelFrame, border_color = panelFrame, border_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_pos(panelPos))
    table.set_frame_color(panel, panelFrame)
    table.set_border_color(panel, panelFrame)
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Trend Stability Ribbon", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(panel, 0, 1, "State", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 1, f_state_short(state), text_color = f_text_on(stateBg), bgcolor = stateBg, text_size = panelSize)
        table.cell(panel, 0, 2, "Workflow", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 2, workflowText, text_color = f_text_on(stateBg), bgcolor = stateBg, text_size = panelSize)
        table.cell(panel, 0, 3, "Direction", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 3, dirText, text_color = stateColor, bgcolor = rightBg, text_size = panelSize)
        table.cell(panel, 0, 4, "Efficiency Ratio", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 4, str.tostring(er, "#.00"), text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
        table.cell(panel, 0, 5, "Stability", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 5, stabText + " / " + str.tostring(stateScore) + "/100", text_color = f_text_on(scoreBg), bgcolor = scoreBg, text_size = panelSize)
        table.cell(panel, 0, 6, showThresholds ? "Thresholds" : "Mode", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
        table.cell(panel, 1, 6, showThresholds ? thresholdText : ribbonMode + " / " + str.tostring(barsInState) + " Bars", text_color = rightTxt, bgcolor = rightBg, text_size = panelSize)
        if showProof
            table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_left)
            table.cell(panel, 1, 7, proofSampleText, text_color = leftTxt, bgcolor = leftBg, text_size = panelSize, text_halign = text.align_right)
            table.cell(panel, 0, 8, "Follow Rate", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
            table.cell(panel, 1, 8, followText, text_color = followCol, bgcolor = rightBg, text_size = panelSize, text_halign = text.align_right)
            table.cell(panel, 0, 9, "Hold Rate", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
            table.cell(panel, 1, 9, holdText, text_color = holdCol, bgcolor = rightBg, text_size = panelSize, text_halign = text.align_right)
            table.cell(panel, 0, 10, "React Rate", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
            table.cell(panel, 1, 10, reactText, text_color = reactCol, bgcolor = rightBg, text_size = panelSize, text_halign = text.align_right)
            table.cell(panel, 0, 11, "Flip Rate", text_color = leftTxt, bgcolor = leftBg, text_size = panelSize)
            table.cell(panel, 1, 11, flipText, text_color = flipCol, bgcolor = rightBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertFlip and dirFlip, "Trend State Flipped", "Trend Stability Ribbon: TREND STATE attention marker. Review direction, stability, and broader context.")
alertcondition(alertImproved and stabImproved, "Stability Improved", "Trend Stability Ribbon: STABILITY IMPROVED attention marker. Review the trend path and efficiency ratio.")
alertcondition(alertDegraded and stabDegraded, "Stability Degraded", "Trend Stability Ribbon: STABILITY DEGRADED attention marker. Review noisy trend conditions before interpreting context.")

// -------------------------------------------------
// Hidden Exports
// -------------------------------------------------
plot(stateScore, "TSR Stability Score", display = display.none)
plot(er, "TSR Efficiency Ratio", display = display.none)
plot(followRate, "TSR Follow Rate", display = display.none)
plot(holdRate, "TSR Hold Rate", display = display.none)
plot(reactRate, "TSR React Rate", display = display.none)
plot(flipRate, "TSR Flip Rate", display = display.none)
plot(proofAmbiguous, "TSR Ambiguous Proof Count", display = display.none)
plot(state, "TSR State ID", display = display.none)
plot(dirCode, "TSR Direction Code", display = display.none)
plot(barsInState, "TSR Bars In State", display = display.none)
````
