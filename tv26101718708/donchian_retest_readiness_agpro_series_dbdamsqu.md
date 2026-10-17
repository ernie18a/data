# Donchian Retest Readiness [AGPro Series]

- url: https://www.tradingview.com/script/dbdAmSQU-Donchian-Retest-Readiness-AGPro-Series/
- type: indicator
- pine_id: PUB;8ad1f698f4fe4f26b6c86842f8fbfbe2
- version: 4.0

## Description

# Donchian Retest Readiness [AGPro Series]

🧠 Core Idea

After price breaks a Donchian Channel boundary, is the broken edge ready to act as a clean retest and continuation reference?


📌 Overview / What it does

Donchian Retest Readiness is a breakout-boundary decision-support script built around Donchian Channels.

The script maps the rolling Donchian high, low, and midpoint, detects channel breaks, builds a retest pocket around the broken edge, scores retest quality from 0 to 100, and projects continuation lanes with target rails.

It does not predict price direction, automate trades, or provide guaranteed signals. It organizes Donchian break context, retest quality, channel edge, risk, and action state into a clean visual workflow.


🎯 Purpose & Design Philosophy

Many breakout tools mark the moment price leaves a range, but the difficult part often comes after the break: deciding whether the broken edge is being respected.

This script was built for traders who want to evaluate Donchian breakout retests without treating every new high or new low as a complete trading idea.

The design supports structured observation: break first, retest pocket second, hold quality third.


⚡ Why This Script Is Different

Most Donchian tools focus on channel highs and lows.

This script does NOT stop at drawing the Donchian Channel.

Instead, it converts the broken channel edge into a decision zone, evaluates whether price returns to that area, measures hold quality, and summarizes readiness with a clear 0-100 score.


⚙️ Methodology

1. Donchian Channel Mapping
2. Breakout Boundary Detection
3. Retest Pocket Construction
4. Hold / Failure Evaluation
5. 0-100 Retest Readiness Score
6. Panel And Alert Output


🗺️ How to Read the Chart

The Donchian Channel shows the rolling high, low, and midpoint.

The retest pocket appears around the broken channel edge after a breakout.

READY RETEST labels appear when price interacts with the broken edge and holds with enough quality.

Continuation lanes and target rails show the projected area beyond the accepted retest context.

The panel summarizes Break State, Retest Score, Channel Edge, Risk, and Action.


🚦 Signals & States

• READY → A qualified Donchian retest has formed.

• MONITOR → A Donchian break is active and retest behavior is being evaluated.

• WAIT → The channel is valid, but no active break / retest context is present.

• INVALIDATED → Price failed back through the broken channel edge.

• BLOCKED → The Donchian channel is not suitable for evaluation under current settings.


🔔 Alerts Logic

Bullish Donchian Retest Ready triggers when price breaks above the Donchian high, returns to the broken edge, and holds with enough score quality.

Bearish Donchian Retest Ready triggers when price breaks below the Donchian low, returns to the broken edge, and holds with enough score quality.

Donchian Break Watch alerts mark the first boundary break when enabled.

Donchian Retest Invalidated triggers when price fails back through the broken edge.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The retest score combines wick response, close pressure beyond the broken edge, proximity to the retest pocket, breakout impulse, relative volume, and channel width quality.

When several of these conditions align, the retest context becomes stronger.


📊 When to Use

• Breakout markets

• Trend continuation setups

• Pullbacks after new highs or new lows

• Donchian Channel structure analysis

• Intraday or swing contexts where retest behavior matters


⚠️ When NOT to Use

• Very low-liquidity symbols

• Extremely noisy chop

• Abnormal spread conditions

• News spikes where retest behavior is unstable

• Markets where every boundary break immediately reverses


🎛️ Key Inputs

• Donchian Length → controls the rolling channel high and low.

• ATR Length → controls retest pocket depth, buffers, targets, and label spacing.

• Minimum Channel Width → blocks weak channels that are too narrow.

• Retest Pocket ATR → controls how wide the broken-edge retest pocket is.

• Minimum Ready Score → controls how selective READY states are.

• Projection Bars → controls how far pockets and targets extend.

• Visual settings → control channel, fill, pocket, lane, labels, tags, and panel.


🖥️ Interface & Visual Design

The script uses a clean AG Pro panel to summarize the current Donchian context.

The visual hierarchy is designed to keep the channel visible while making the active retest pocket and READY label easy to see.

Default settings keep failed and early watch labels off so publication screenshots remain clean.


🧪 Practical Usage Workflow

1. Read the panel state.
2. Check the Donchian channel boundary.
3. Wait for a break and retest pocket.
4. Evaluate whether price holds the broken edge.
5. Review target rails and failure risk.


🔍 Interpretation Guidelines

A READY retest means the broken Donchian edge is being respected according to the script rules.

It does not mean price must continue.

An invalidated retest means price failed back through the broken edge and the breakout context lost quality.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a buy or sell signal generator.

It is not an automated trading system.

It does not guarantee breakouts, continuation, or reversals.


⚠️ Limitations & Transparency

Donchian behavior can vary by symbol, timeframe, volatility, and liquidity.

Shorter timeframes may produce more noise.

Longer Donchian lengths may react more slowly.

The script should be interpreted within broader structure, market regime, and risk context.


🧠 Market Context Notes

Donchian edges often become meaningful when market participants react to new highs, new lows, and breakout continuation attempts.

The strongest contexts usually combine a clean boundary break, controlled retest, and enough continuation room.


🧾 Use Case Examples

When price breaks above the Donchian high and later retests the broken edge without closing back through it, the script may mark a bullish READY RETEST.

When price breaks below the Donchian low and retests the edge from below with enough quality, the script may mark a bearish READY RETEST.

When price breaks out and then closes back through the broken edge, the retest can become invalidated.


🧱 System Philosophy

This script follows the AGPro Series approach: structured context, practical scoring, clean visuals, and decision-support states instead of noisy prediction claims.


🔐 Non-Promise Statement

No script can provide certainty.

No output should be treated as guaranteed.

All states are rule-based analytical markers.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and position sizing.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

The purpose of this script is to help users study Donchian Channel breakout and retest behavior through a structured visual framework.

## Source Code

````pine
// -------------------------------------------------
// Donchian Retest Readiness [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Donchian Retest Readiness is a breakout-boundary decision engine built
// around Donchian Channels. It detects channel breaks, maps the broken edge
// as a retest pocket, scores hold quality from 0-100, and organizes break
// state, channel edge, retest quality, risk, target room, and action context
// in a compact AG Pro panel without turning the chart into a prediction board.
// A confirmed lifecycle keeps each break, retest, invalidation, alert, and
// proof sample tied to closed bars while preserving the original Donchian
// decision workflow and its non-predictive character.
// -------------------------------------------------

//@version=6
indicator("Donchian Retest Readiness [AGPro Series]",
     shorttitle = "AG Pro DRT",
     overlay = true,
     max_boxes_count = 90,
     max_labels_count = 160,
     max_lines_count = 120)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
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
f_clamp(float value, float low, float high) =>
    math.max(low, math.min(value, high))

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_table_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Right" => position.middle_right
        "Middle Center" => position.middle_center
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Center" => position.bottom_center
        "Bottom Left" => position.bottom_left
        => position.top_right

f_grade(float score) =>
    score >= 85.0 ? "A+" : score >= 75.0 ? "A" : score >= 65.0 ? "B" : score >= 55.0 ? "C" : "D"

f_score_text(float score) =>
    na(score) ? "n/a" : str.tostring(math.round(score)) + "/100  " + f_grade(score)

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float luminance = 0.299 * r + 0.587 * g + 0.114 * b
    luminance >= 145.0 ? color.rgb(15, 23, 42) : color.white

f_action_color(string action) =>
    action == "Ready" ? bullColor :
     action == "Monitor" ? accentColor :
     action == "Wait" ? neutralColor :
     action == "Invalidated" ? bearColor :
     action == "Expired" ? panelBorder :
     action == "Blocked" ? panelBorder : panelBg

f_set_box(box boxRef, int leftValue, int rightValue, float topValue, float bottomValue, color bg, color border, int borderWidth) =>
    box.set_left(boxRef, leftValue)
    box.set_right(boxRef, rightValue)
    box.set_top(boxRef, topValue)
    box.set_bottom(boxRef, bottomValue)
    box.set_bgcolor(boxRef, bg)
    box.set_border_color(boxRef, border)
    box.set_border_width(boxRef, borderWidth)

f_set_line(line lineRef, int x1, float y1, int x2, float y2, color lineColor, string lineStyle, int lineWidth) =>
    line.set_xy1(lineRef, x1, y1)
    line.set_xy2(lineRef, x2, y2)
    line.set_color(lineRef, lineColor)
    line.set_style(lineRef, lineStyle)
    line.set_width(lineRef, lineWidth)

f_set_tag(label tag, int x, float y, string txt, color bg, string labelStyle, string sizeInput) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, txt)
    label.set_color(tag, bg)
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, labelStyle)
    label.set_size(tag, f_size(sizeInput))
    label.set_textalign(tag, text.align_center)

f_push_label(array<label> store, label newLabel, int limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

f_panel_cell(table panelRef, int col, int row, string txt, color bg, color txtColor, string txtSize, string alignValue) =>
    table.cell(panelRef, col, row, txt, bgcolor = bg, text_color = txtColor, text_size = f_table_size(txtSize), text_halign = alignValue)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
G_DON    = "Donchian Engine"
G_SCORE  = "Retest Engine"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

donchianLength = input.int(40, "Donchian Length", minval = 5, maxval = 500, group = G_DON,
     tooltip = "Lookback used to define the Donchian high and low boundaries.")
atrLength = input.int(14, "ATR Length", minval = 2, maxval = 200, group = G_DON,
     tooltip = "ATR normalizes break buffers, retest pocket depth, target rails, and label spacing.")
minChannelAtr = input.float(1.10, "Minimum Channel Width (x ATR)", minval = 0.10, maxval = 20.0, step = 0.05, group = G_DON,
     tooltip = "Blocks analysis when the Donchian channel is too narrow relative to current ATR.")
breakBufferAtr = input.float(0.03, "Break Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = G_DON,
     tooltip = "ATR-based close distance beyond the Donchian edge required before a break context starts.")

confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = G_SCORE,
     tooltip = "Fast reacts earlier, Balanced requires cleaner hold quality, and Strict demands stronger retest structure.")
minReadyScore = input.int(62, "Minimum Ready Score", minval = 1, maxval = 100, group = G_SCORE,
     tooltip = "Minimum 0-100 retest score required before Ready appears.")
retestPocketAtr = input.float(0.24, "Retest Pocket ATR", minval = 0.03, maxval = 4.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based pocket around the broken Donchian edge where retest quality is evaluated.")
holdBufferAtr = input.float(0.04, "Hold Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based close distance back on the continuation side required for a valid hold.")
failBufferAtr = input.float(0.12, "Failure Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based close distance beyond the pocket that invalidates retest quality.")
retestWindowBars = input.int(90, "Retest Window Bars", minval = 5, maxval = 600, group = G_SCORE,
     tooltip = "Maximum bars after a Donchian break where retest readiness remains active.")
proofWindowBars = input.int(40, "Retest Proof Window Bars", minval = 10, maxval = 300, group = G_SCORE,
     tooltip = "Bars allowed for a ready retest to reach its one-risk target or fail back through the edge before the sample is left unresolved (uncounted) in the Retest Win Rate.")
targetOneAtr = input.float(1.20, "Target 1 ATR", minval = 0.10, maxval = 20.0, step = 0.05, group = G_SCORE,
     tooltip = "First continuation target projected from the broken channel edge.")
targetTwoAtr = input.float(2.10, "Target 2 ATR", minval = 0.10, maxval = 30.0, step = 0.05, group = G_SCORE,
     tooltip = "Second continuation target projected from the broken channel edge.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = G_SCORE,
     tooltip = "Adds relative volume participation to retest score.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_SCORE,
     tooltip = "Lookback used to compare current volume against recent average participation.")

showChannel = input.bool(true, "Show Donchian Channel", group = G_VISUAL,
     tooltip = "Shows Donchian high, mid, low, and a subtle channel fill.")
showChannelFill = input.bool(true, "Show Channel Fill", group = G_VISUAL,
     tooltip = "Adds a subtle fill between Donchian boundaries.")
showRetestPocket = input.bool(true, "Show Retest Pocket", group = G_VISUAL,
     tooltip = "Shows the retest pocket around the broken Donchian edge.")
showPocketBadge = input.bool(true, "Show Pocket Badge", group = G_VISUAL,
     tooltip = "Shows a centered badge inside the active retest pocket.")
showContinuationLane = input.bool(true, "Show Continuation Lane", group = G_VISUAL,
     tooltip = "Shows a projected continuation lane after a qualified retest.")
showTargetRails = input.bool(true, "Show Target Rails", group = G_VISUAL,
     tooltip = "Shows T1 and T2 continuation target rails.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows Ready Retest, break watch, and invalidation labels.")
showBreakWatchLabels = input.bool(false, "Show Break Watch Labels", group = G_VISUAL,
     tooltip = "Shows early Donchian break-watch labels. Disabled by default for cleaner screenshots.")
showInvalidLabels = input.bool(false, "Show Invalidation Labels", group = G_VISUAL,
     tooltip = "Shows failed retest labels. Disabled by default to avoid clutter.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for broken edge and targets.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly when a Donchian retest state is active.")
projectionBars = input.int(110, "Projection Bars", minval = 10, maxval = 800, group = G_VISUAL,
     tooltip = "How far the retest pocket, lane, and target rails project to the right.")
rightTagOffset = input.int(4, "Right Tag Offset", minval = 1, maxval = 40, group = G_VISUAL,
     tooltip = "Controls how far right-side tags sit from the latest bar.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag size.")
labelOffsetAtr = input.float(0.45, "Label Offset ATR", minval = 0.05, maxval = 5.00, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based vertical spacing used to keep labels away from candles.")
maxEventLabels = input.int(5, "Max Event Labels", minval = 2, maxval = 60, group = G_VISUAL,
     tooltip = "Maximum number of confirmed lifecycle event badges retained on chart. The default preserves a premium, readable history.")
labelCooldownBars = input.int(10, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum bars between repeated event labels. Higher values reduce clustering.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Displays the AG Pro decision panel. Enabled by default.")
panelPositionInput = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls where the panel appears on chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Selects the AGPro dark theme, a softer slate theme, or a light chart-friendly theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls text size inside the decision panel.")

alertReady = input.bool(true, "Alert: Donchian Retest Ready", group = G_ALERTS,
     tooltip = "Creates an alert condition when a Donchian retest becomes ready.")
alertBreak = input.bool(false, "Alert: Donchian Break Watch", group = G_ALERTS,
     tooltip = "Creates an alert condition when price breaks beyond a Donchian boundary.")
alertInvalidated = input.bool(true, "Alert: Retest Invalidated", group = G_ALERTS,
     tooltip = "Creates an alert condition when retest quality fails back through the broken boundary.")

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_table_size(panelFontSizeInput)
atr = ta.atr(atrLength)
atrSafe = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(nz(volume, 1.0), volumeLength)
rvol = volAvg > 0.0 ? nz(volume, 1.0) / volAvg : 1.0

donHigh = ta.highest(high, donchianLength)[1]
donLow = ta.lowest(low, donchianLength)[1]
donMid = (donHigh + donLow) * 0.50
channelWidth = donHigh - donLow
channelValid = not na(donHigh) and not na(donLow) and atrSafe > 0.0 and channelWidth >= atrSafe * minChannelAtr

plotHigh = plot(showChannel and channelValid ? donHigh : na, title = "Donchian High", color = color.new(bullColor, 25), linewidth = 1)
plotMid = plot(showChannel and channelValid ? donMid : na, title = "Donchian Mid", color = color.new(neutralColor, 45), linewidth = 1)
plotLow = plot(showChannel and channelValid ? donLow : na, title = "Donchian Low", color = color.new(bearColor, 25), linewidth = 1)
fill(plotHigh, plotLow, title = "Donchian Channel Fill", color = showChannel and showChannelFill and channelValid ? color.new(panelBorder, 95) : na)

breakBuffer = atrSafe * breakBufferAtr
breakUp = channelValid and close > donHigh + breakBuffer and close[1] <= donHigh
breakDown = channelValid and close < donLow - breakBuffer and close[1] >= donLow
breakEvent = barstate.isconfirmed and (breakUp or breakDown)
breakDirNow = breakUp ? 1 : breakDown ? -1 : 0

var int activeDir = 0
var int breakBar = na
var float brokenEdge = na
var float breakAtr = na
var float activeScore = na
var bool activeBreak = false
var bool readyLatched = false
var int lastReadyLabelBar = na
var int lastBreakLabelBar = na
var int lastInvalidLabelBar = na

if breakEvent
    activeDir := breakDirNow
    breakBar := bar_index
    brokenEdge := breakDirNow == 1 ? donHigh : donLow
    breakAtr := atrSafe
    activeScore := na
    activeBreak := true
    readyLatched := false

barsFromBreak = activeBreak and not na(breakBar) ? bar_index - breakBar : na
withinWindow = activeBreak and not na(barsFromBreak) and barsFromBreak <= retestWindowBars
pocketTop = activeDir != 0 and not na(brokenEdge) ? brokenEdge + breakAtr * retestPocketAtr : na
pocketBottom = activeDir != 0 and not na(brokenEdge) ? brokenEdge - breakAtr * retestPocketAtr : na
pocketMid = not na(pocketTop) and not na(pocketBottom) ? (pocketTop + pocketBottom) * 0.50 : na
enteredPocket = withinWindow and high >= pocketBottom and low <= pocketTop
holdClose = withinWindow and ((activeDir == 1 and close >= brokenEdge + breakAtr * holdBufferAtr) or (activeDir == -1 and close <= brokenEdge - breakAtr * holdBufferAtr))
failClose = withinWindow and ((activeDir == 1 and close < brokenEdge - breakAtr * failBufferAtr) or (activeDir == -1 and close > brokenEdge + breakAtr * failBufferAtr))
expired = activeBreak and not withinWindow

barRange = math.max(high - low, syminfo.mintick)
wickSupport = activeDir == 1 ? (math.min(open, close) - low) / barRange : activeDir == -1 ? (high - math.max(open, close)) / barRange : 0.0
closePressure = activeDir == 1 ? (close - brokenEdge) / atrSafe : activeDir == -1 ? (brokenEdge - close) / atrSafe : 0.0
proximity = withinWindow ? f_clamp(1.0 - math.abs(close - brokenEdge) / math.max(breakAtr * 1.6, syminfo.mintick), 0.0, 1.0) : 0.0
breakImpulse = activeDir == 1 ? (close - donHigh) / atrSafe : activeDir == -1 ? (donLow - close) / atrSafe : 0.0

wickScore = f_clamp(wickSupport / 0.55, 0.0, 1.0) * 22.0
closeScore = f_clamp(closePressure / 0.75, 0.0, 1.0) * 24.0
proximityScore = proximity * 18.0
impulseScore = f_clamp(breakImpulse / 0.80, 0.0, 1.0) * 14.0
volumeScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 10.0 : 7.0
channelScore = f_clamp(channelWidth / math.max(atrSafe * 4.0, syminfo.mintick), 0.0, 1.0) * 12.0
candidateScore = f_clamp(wickScore + closeScore + proximityScore + impulseScore + volumeScore + channelScore, 0.0, 100.0)
confirmBonus = confirmationMode == "Fast" ? 5.0 : confirmationMode == "Balanced" ? 0.0 : -8.0
requiredScore = f_clamp(minReadyScore - confirmBonus, 1.0, 100.0)
readyState = withinWindow and enteredPocket and holdClose and candidateScore >= requiredScore and not failClose
readyEvent = barstate.isconfirmed and readyState and not readyLatched
invalidatedEvent = barstate.isconfirmed and failClose

if readyEvent
    activeScore := candidateScore
    readyLatched := true

t1 = activeDir == 1 ? brokenEdge + breakAtr * targetOneAtr : activeDir == -1 ? brokenEdge - breakAtr * targetOneAtr : na
t2 = activeDir == 1 ? brokenEdge + breakAtr * targetTwoAtr : activeDir == -1 ? brokenEdge - breakAtr * targetTwoAtr : na
roomToT1 = withinWindow and activeDir != 0 and not na(t1) ? activeDir == 1 ? f_clamp((t1 - close) / math.max(t1 - brokenEdge, syminfo.mintick), 0.0, 1.5) : f_clamp((close - t1) / math.max(brokenEdge - t1, syminfo.mintick), 0.0, 1.5) : na
riskScore = withinWindow ? f_clamp((failClose ? 50.0 : 0.0) + (enteredPocket ? 12.0 : 28.0) + (100.0 - candidateScore) * 0.22, 0.0, 100.0) : na

if invalidatedEvent or expired
    activeBreak := false

// -------------------------------------------------
// Retest-Win-Rate Proof
// On a ready retest, a win is recorded when price reaches one risk-distance in
// the continuation direction (a balanced one-risk target) before closing back
// through the failure level beyond the broken edge. Samples that resolve neither
// inside the proof window are left unresolved and uncounted. Updated only on
// confirmed bars so the statistic does not repaint.
// -------------------------------------------------
var int   proofWins    = 0
var int   proofTotal   = 0
var bool  proofPending = false
var int   proofDir     = 0
var float proofTarget  = na
var float proofStop    = na
var int   proofStartBar = na

bool readyArm = readyEvent

if barstate.isconfirmed
    if proofPending
        favHit  = proofDir == 1 ? high >= proofTarget : low <= proofTarget
        stopHit = proofDir == 1 ? close < proofStop : close > proofStop
        expiredProof = bar_index - proofStartBar >= proofWindowBars
        if favHit and stopHit
            proofTotal += 1
            proofPending := false
        else if favHit
            proofWins += 1
            proofTotal += 1
            proofPending := false
        else if stopHit
            proofTotal += 1
            proofPending := false
        else if expiredProof
            proofPending := false
    if readyArm and activeDir != 0 and not na(brokenEdge) and not proofPending
        failLevel = activeDir == 1 ? brokenEdge - breakAtr * failBufferAtr : brokenEdge + breakAtr * failBufferAtr
        riskDist = math.max(math.abs(close - failLevel), breakAtr * 0.10)
        proofDir := activeDir
        proofTarget := close + activeDir * riskDist
        proofStop := failLevel
        proofStartBar := bar_index
        proofPending := true

float proofRate = proofTotal > 0 ? proofWins / proofTotal * 100.0 : na

var string actionState = "Wait"
var string breakState = "No Break"
var string retestState = "n/a"
var string edgeText = "n/a"
var float panelScore = na

if not channelValid
    actionState := "Blocked"
    breakState := "Channel Blocked"
    retestState := "n/a"
    edgeText := "n/a"
    panelScore := na
else if invalidatedEvent
    actionState := "Invalidated"
    breakState := "Retest Failed"
    retestState := "Back Through Edge"
    edgeText := f_price(brokenEdge)
    panelScore := candidateScore
else if withinWindow and readyLatched
    actionState := "Ready"
    breakState := activeDir == 1 ? "Bull Retest Accepted" : "Bear Retest Accepted"
    retestState := "Hold Accepted"
    edgeText := f_price(brokenEdge)
    panelScore := activeScore
else if withinWindow
    actionState := "Monitor"
    breakState := activeDir == 1 ? "Bull Break Watch" : "Bear Break Watch"
    retestState := enteredPocket ? "Testing Pocket" : "Waiting Retest"
    edgeText := f_price(brokenEdge)
    panelScore := na(activeScore) ? candidateScore : activeScore
else
    actionState := "Wait"
    breakState := "Channel Ready"
    retestState := "n/a"
    edgeText := activeDir == 1 ? f_price(donHigh) : activeDir == -1 ? f_price(donLow) : "n/a"
    panelScore := na

// -------------------------------------------------
// Visuals
// -------------------------------------------------
var box pocketBox = na
var box laneBox = na
var line edgeLine = na
var line t1Line = na
var line t2Line = na
var label pocketBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = color.white, size = labelSize)
var label tagEdge = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = color.white, size = labelSize)
var label tagT1 = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = color.white, size = labelSize)
var label tagT2 = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = color.white, size = labelSize)
var array<label> eventLabels = array.new<label>()

rightX = bar_index + projectionBars
tagX = bar_index + rightTagOffset
visualColor = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : accentColor

if showRetestPocket and withinWindow and not na(brokenEdge)
    if na(pocketBox)
        pocketBox := box.new(breakBar, pocketTop, rightX, pocketBottom, xloc = xloc.bar_index, bgcolor = color.new(visualColor, 89), border_color = color.new(visualColor, 18), border_width = 2)
    else
        f_set_box(pocketBox, breakBar, rightX, pocketTop, pocketBottom, color.new(visualColor, 89), color.new(visualColor, 18), 2)
    if na(edgeLine)
        edgeLine := line.new(breakBar, brokenEdge, rightX, brokenEdge, xloc = xloc.bar_index, color = color.new(neutralColor, 8), width = 2, style = line.style_dotted)
    else
        f_set_line(edgeLine, breakBar, brokenEdge, rightX, brokenEdge, color.new(neutralColor, 8), line.style_dotted, 2)
    if showPocketBadge
        badgeX = int(math.round(breakBar + (rightX - breakBar) * 0.50))
        f_set_tag(pocketBadge, badgeX, pocketMid, "Retest Pocket\nQ " + f_score_text(na(activeScore) ? candidateScore : activeScore), visualColor, label.style_label_center, labelSizeInput)
    else
        label.set_text(pocketBadge, "")
else
    if not na(pocketBox)
        box.delete(pocketBox)
        pocketBox := na
    if not na(edgeLine)
        line.delete(edgeLine)
        edgeLine := na
    label.set_text(pocketBadge, "")

laneTop = activeDir == 1 ? t1 : brokenEdge
laneBottom = activeDir == 1 ? brokenEdge : t1
if showContinuationLane and withinWindow and not na(laneTop) and not na(laneBottom)
    if na(laneBox)
        laneBox := box.new(breakBar, laneTop, rightX, laneBottom, xloc = xloc.bar_index, bgcolor = color.new(visualColor, 94), border_color = color.new(visualColor, 55), border_width = 1)
    else
        f_set_box(laneBox, breakBar, rightX, laneTop, laneBottom, color.new(visualColor, 94), color.new(visualColor, 55), 1)
else
    if not na(laneBox)
        box.delete(laneBox)
        laneBox := na

if showTargetRails and withinWindow and not na(t1) and not na(t2)
    if na(t1Line)
        t1Line := line.new(breakBar, t1, rightX, t1, xloc = xloc.bar_index, color = color.new(neutralColor, 10), width = 1, style = line.style_dashed)
    else
        f_set_line(t1Line, breakBar, t1, rightX, t1, color.new(neutralColor, 10), line.style_dashed, 1)
    if na(t2Line)
        t2Line := line.new(breakBar, t2, rightX, t2, xloc = xloc.bar_index, color = color.new(accentColor, 12), width = 1, style = line.style_dashed)
    else
        f_set_line(t2Line, breakBar, t2, rightX, t2, color.new(accentColor, 12), line.style_dashed, 1)
else
    if not na(t1Line)
        line.delete(t1Line)
        t1Line := na
    if not na(t2Line)
        line.delete(t2Line)
        t2Line := na

canReadyLabel = na(lastReadyLabelBar) or bar_index - lastReadyLabelBar >= labelCooldownBars
canBreakLabel = na(lastBreakLabelBar) or bar_index - lastBreakLabelBar >= labelCooldownBars
canInvalidLabel = na(lastInvalidLabelBar) or bar_index - lastInvalidLabelBar >= labelCooldownBars

if showEventLabels and showBreakWatchLabels and breakEvent and canBreakLabel
    label breakLabel = label.new(bar_index, breakDirNow == 1 ? high + atrSafe * labelOffsetAtr : low - atrSafe * labelOffsetAtr, "Break Watch\nRetest path", xloc = xloc.bar_index, style = breakDirNow == 1 ? label.style_label_down : label.style_label_up, textcolor = f_text_on(visualColor), color = visualColor, size = labelSize, textalign = text.align_center)
    lastBreakLabelBar := bar_index
    f_push_label(eventLabels, breakLabel, maxEventLabels)

if showEventLabels and readyEvent and canReadyLabel
    label readyLabel = label.new(bar_index, activeDir == 1 ? low - breakAtr * labelOffsetAtr : high + breakAtr * labelOffsetAtr, "RETEST READY\nQ " + str.tostring(math.round(candidateScore)), xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_up : label.style_label_down, textcolor = f_text_on(visualColor), color = visualColor, size = labelSize, textalign = text.align_center)
    lastReadyLabelBar := bar_index
    f_push_label(eventLabels, readyLabel, maxEventLabels)

if showEventLabels and showInvalidLabels and invalidatedEvent and canInvalidLabel
    label invalidLabel = label.new(bar_index, activeDir == 1 ? high + breakAtr * labelOffsetAtr : low - breakAtr * labelOffsetAtr, "Invalidated\nBack through edge", xloc = xloc.bar_index, style = activeDir == 1 ? label.style_label_down : label.style_label_up, textcolor = f_text_on(bearColor), color = bearColor, size = labelSize, textalign = text.align_center)
    lastInvalidLabelBar := bar_index
    f_push_label(eventLabels, invalidLabel, maxEventLabels)

if barstate.islast and showRightTags and withinWindow
    f_set_tag(tagEdge, tagX, brokenEdge, "Break Edge " + f_price(brokenEdge), visualColor, label.style_label_left, labelSizeInput)
    f_set_tag(tagT1, tagX, t1, "T1 " + f_price(t1), neutralColor, label.style_label_left, labelSizeInput)
    f_set_tag(tagT2, tagX, t2, "T2 " + f_price(t2), accentColor, label.style_label_left, labelSizeInput)
else if barstate.islast
    label.set_text(tagEdge, "")
    label.set_text(tagT1, "")
    label.set_text(tagT2, "")

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBgFinal = panelTheme == "Dark" ? panelBg : panelTheme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(248, 250, 252)
panelLeftFinal = panelTheme == "Dark" ? color.rgb(30, 41, 59) : panelTheme == "Slate" ? color.rgb(51, 65, 85) : color.rgb(226, 232, 240)
panelTextFinal = panelTheme == "Light" ? color.rgb(15, 23, 42) : panelValueCol
panelLabelFinal = panelTheme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol
scoreText = f_score_text(panelScore)
riskText = na(riskScore) ? "n/a" : str.tostring(math.round(riskScore)) + "/100"
roomText = na(roomToT1) ? "n/a" : str.tostring(roomToT1, "#.##") + "x T1"
actionColor = f_action_color(actionState)
proofText = proofTotal > 0 ? str.tostring(math.round(nz(proofRate, 0.0))) + "% (" + str.tostring(proofTotal) + ")" : "Building"
proofCol = na(proofRate) ? panelTextFinal : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor

var table panel = table.new(position.top_right, 2, 8, bgcolor = panelBgFinal, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if showPanel and barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.clear(panel, 0, 0, 1, 7)
    table.merge_cells(panel, 0, 0, 1, 0)
    f_panel_cell(panel, 0, 0, "AG Pro Donchian Retest Readiness", headerBg, headerText, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 0, 1, "Break State", panelLeftFinal, panelLabelFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 1, 1, breakState, panelBgFinal, panelTextFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 0, 2, "Retest Score", panelLeftFinal, panelLabelFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 1, 2, scoreText, panelBgFinal, panelTextFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 0, 3, "Channel Edge", panelLeftFinal, panelLabelFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 1, 3, edgeText, panelBgFinal, panelTextFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 0, 4, "Retest State", panelLeftFinal, panelLabelFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 1, 4, retestState, panelBgFinal, panelTextFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 0, 5, "Risk / Room", panelLeftFinal, panelLabelFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 1, 5, riskText + " / " + roomText, panelBgFinal, panelTextFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 0, 6, "Retest Win Rate", panelLeftFinal, panelLabelFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 1, 6, proofText, panelBgFinal, proofCol, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 0, 7, "Action", panelLeftFinal, panelLabelFinal, panelFontSizeInput, text.align_center)
    f_panel_cell(panel, 1, 7, actionState, actionColor, f_text_on(actionColor), panelFontSizeInput, text.align_center)

if not showPanel and barstate.islast
    table.clear(panel, 0, 0, 1, 7)

barStateColor = actionState == "Ready" ? color.new(activeDir == 1 ? bullColor : bearColor, 76) :
     actionState == "Monitor" ? color.new(activeDir == 1 ? bullColor : bearColor, 84) :
     actionState == "Invalidated" ? color.new(bearColor, 80) : na
barcolor(showBarColors ? barStateColor : na)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertReady and readyEvent and activeDir == 1, "Bullish Donchian Retest Ready", "Donchian Retest Readiness: confirmed bullish retest readiness on {{ticker}}.")
alertcondition(alertReady and readyEvent and activeDir == -1, "Bearish Donchian Retest Ready", "Donchian Retest Readiness: confirmed bearish retest readiness on {{ticker}}.")
alertcondition(alertBreak and breakEvent and breakDirNow == 1, "Bullish Donchian Break Watch", "Donchian Retest Readiness: bullish Donchian break watch on {{ticker}}.")
alertcondition(alertBreak and breakEvent and breakDirNow == -1, "Bearish Donchian Break Watch", "Donchian Retest Readiness: bearish Donchian break watch on {{ticker}}.")
alertcondition(alertInvalidated and invalidatedEvent, "Donchian Retest Invalidated", "Donchian Retest Readiness: retest quality invalidated on {{ticker}}.")
````
