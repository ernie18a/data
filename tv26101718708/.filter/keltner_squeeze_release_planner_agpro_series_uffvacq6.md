# Keltner Squeeze Release Planner [AGPro Series]

- url: https://www.tradingview.com/script/UffvACQ6-Keltner-Squeeze-Release-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;f7ff1ad590834c03a3e9c2be6672f3be
- version: 4.0

## Description

# Keltner Squeeze Release Planner [AGPro Series]

🧠 Core Idea

Is volatility compression turning into a clean Keltner Channel release, or is price still trapped inside the squeeze?


📌 Overview / What it does

Keltner Squeeze Release Planner is a volatility compression and expansion decision-support script built around Keltner Channels.

The script detects compressed Keltner width, evaluates whether price releases beyond the channel with enough expansion quality, scores the release from 0 to 100, and maps an expansion corridor with target rails and failure context.

It does not predict price direction, automate trading, or provide guaranteed signals. It organizes squeeze, release quality, volatility rank, direction bias, and action state into a cleaner workflow.


🎯 Purpose & Design Philosophy

Many traders can see a breakout after it happens, but the difficult part is separating real volatility expansion from a weak push outside the channel.

This script was built for traders who want a structured way to read Keltner squeeze behavior, release strength, and early failure risk.

The design supports patience during compression and cleaner observation when price finally leaves the channel.


⚡ Why This Script Is Different

Most Keltner tools draw the channel and leave interpretation to the user.

This script does NOT treat every channel break as meaningful.

Instead, it evaluates compression depth, expansion ratio, close pressure, candle body quality, relative volume, and basis slope before marking a release as READY.


⚙️ Methodology

1. Keltner Channel Mapping
2. Compression Detection
3. Release Edge Evaluation
4. Expansion Quality Scoring
5. Corridor And Failure Mapping
6. Panel And Alert Output


🗺️ How to Read the Chart

The Keltner Channel shows the active volatility envelope around price.

Compression shading marks periods where channel width is low relative to recent history.

BULL RELEASE and BEAR RELEASE labels appear when price leaves the channel with enough release quality.

The release corridor projects possible expansion space after a qualified release.

The panel summarizes Squeeze, Release Score, Volatility, Direction Bias, and Action.


🚦 Signals & States

• READY → A qualified Keltner squeeze release has formed.

• MONITOR → A release context is active and should be observed.

• WAIT → Compression may exist, but release quality is not confirmed.

• INVALIDATED → A release failed back into the channel context.

• BLOCKED → The script cannot define a valid Keltner context.


🔔 Alerts Logic

Bullish Keltner Squeeze Release Ready triggers when price releases above the upper Keltner Channel after compression with enough score quality.

Bearish Keltner Squeeze Release Ready triggers when price releases below the lower Keltner Channel after compression with enough score quality.

Keltner Compression Active triggers when channel width is low enough to qualify as squeeze context.

Keltner Squeeze Release Failed triggers when an active release loses quality and moves back into the failure area.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The release score combines compression depth, expansion ratio, close pressure beyond the channel, candle body quality, relative volume, and basis slope.

When these conditions align, the release context becomes stronger.


📊 When to Use

• Markets moving from low volatility to expansion

• Breakout environments

• Consolidation-to-trend transitions

• Intraday or swing contexts where volatility contraction matters


⚠️ When NOT to Use

• Extremely illiquid symbols

• Random high-noise chop

• News spikes with unstable spreads

• Symbols where Keltner width is distorted by abnormal candles


🎛️ Key Inputs

• Keltner Basis Length → controls the EMA basis of the channel.

• ATR Length → controls channel width and volatility normalization.

• Keltner ATR Multiplier → adjusts how wide the channel is.

• Squeeze Threshold → defines how deep compression must be.

• Minimum Ready Score → controls how selective READY releases are.

• Projection Bars → controls how far the corridor extends.

• Visual settings → control labels, channels, zones, panel, and chart density.


🖥️ Interface & Visual Design

The script uses a compact AG Pro panel to make the current state readable at a glance.

The visual hierarchy is designed to keep the chart clean: channel context first, release label second, corridor and targets third.

Default settings are tuned for readable publication screenshots without hiding the core volatility story.


🧪 Practical Usage Workflow

1. Read the panel state.
2. Check whether compression is active.
3. Wait for a qualified release label.
4. Review the corridor and target rails.
5. Watch whether price holds or fails back into the channel.


🔍 Interpretation Guidelines

A READY release means volatility expansion conditions aligned according to the script rules.

It does not mean price must continue.

A weak or failed release means the channel break lost quality and should be interpreted within broader market context.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a buy or sell signal generator.

It is not an automated trading system.

It does not guarantee breakouts, continuation, or reversals.


⚠️ Limitations & Transparency

Keltner behavior can change across symbols, sessions, and timeframes.

Compression may last longer than expected.

Strong news events can create release signals that behave differently from normal volatility expansion.

The script should be used with broader structure, liquidity, and risk context.


🧠 Market Context Notes

Keltner squeeze behavior is most useful when volatility has contracted enough to create a visible transition point.

The best contexts often combine compression, clean channel release, participation, and enough room for expansion.


🧾 Use Case Examples

When price compresses inside the Keltner Channel and then closes beyond the upper band with strong expansion, the script may mark a bullish release.

When price breaks below the lower band after compression and the release score is strong enough, the script may mark a bearish release.

When price breaks out but quickly moves back into the channel, the release can lose quality.


🧱 System Philosophy

This script is part of the AGPro Series approach: clean visual context, practical scoring, and decision-support states instead of noisy prediction labels.


🔐 Non-Promise Statement

No script can provide certainty.

No signal should be treated as guaranteed.

All outputs are rule-based analytical markers.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions, risk management, and position sizing.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

The purpose of this script is to help users study volatility compression and release behavior through a structured Keltner Channel framework.

## Source Code

````pine
// -------------------------------------------------
// Keltner Squeeze Release Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Keltner Squeeze Release Planner is a volatility compression and expansion
// decision engine built around Keltner Channels. It detects squeeze context,
// evaluates release quality with a 0-100 score, maps expansion corridors and
// failed release shelves, and organizes volatility, directional bias, failure
// risk, and action state inside a clean AG Pro panel.
// Version 1.8 isolates the owned release rail lane beyond the corridor edge,
// preventing price tags from colliding with centered zone identities.
// -------------------------------------------------

//@version=6
indicator("Keltner Squeeze Release Planner [AGPro Series]",
     shorttitle = "AG Pro KSR",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 140,
     max_lines_count = 100)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
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
f_clamp(_v, _lo, _hi) =>
    math.max(_lo, math.min(_v, _hi))

// Luminance-aware contrast text (target luminance 145)
f_lum(_c)      => 0.299 * color.r(_c) + 0.587 * color.g(_c) + 0.114 * color.b(_c)
f_text_on(_bg) => f_lum(_bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_size(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Large" ? size.large :
     _s == "Huge" ? size.huge : size.normal

f_lane_mult(_s) =>
    _s == "Tiny" ? 0.75 :
     _s == "Small" ? 0.90 :
     _s == "Large" ? 1.25 :
     _s == "Huge" ? 1.55 : 1.00

f_panel_position(_p) =>
    _p == "Top Left" ? position.top_left :
     _p == "Top Center" ? position.top_center :
     _p == "Middle Right" ? position.middle_right :
     _p == "Middle Left" ? position.middle_left :
     _p == "Middle Center" ? position.middle_center :
     _p == "Bottom Right" ? position.bottom_right :
     _p == "Bottom Center" ? position.bottom_center :
     _p == "Bottom Left" ? position.bottom_left : position.top_right

f_panel_bg(_theme) =>
    _theme == "Clean Light" ? color.rgb(248, 250, 252) : _theme == "Slate" ? color.rgb(30, 41, 59) : color.rgb(15, 23, 42)

f_panel_border(_theme) =>
    _theme == "Clean Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(_theme) =>
    _theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(_theme) =>
    _theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_grade(_score) =>
    _score >= 85 ? "A+" :
     _score >= 75 ? "A" :
     _score >= 65 ? "B" :
     _score >= 55 ? "C" : "D"

f_score_text(_score) =>
    na(_score) ? "n/a" : str.tostring(math.round(_score)) + " / 100  " + f_grade(_score)

f_action_color(_action) =>
    _action == "READY" ? color.new(bullColor, 8) :
     _action == "MONITOR" ? color.new(accentColor, 10) :
     _action == "WAIT" ? color.new(neutralColor, 16) :
     _action == "INVALIDATED" ? color.new(bearColor, 8) :
     _action == "EXPIRED" ? color.new(panelBorder, 8) :
     _action == "BLOCKED" ? color.new(panelBorder, 0) : color.rgb(15, 23, 42)

f_action_base(_action) =>
    _action == "READY" ? bullColor :
     _action == "MONITOR" ? accentColor :
     _action == "WAIT" ? neutralColor :
     _action == "INVALIDATED" ? bearColor : panelBorder

f_set_tag(label _id, int _x, float _y, string _text, color _bg, string _size) =>
    label _result = _id
    if na(_result)
        _result := label.new(_x, _y, _text, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(_bg, 0), textcolor = f_text_on(_bg), size = f_size(_size))
    else
        label.set_xy(_result, _x, _y)
        label.set_text(_result, _text)
        label.set_color(_result, color.new(_bg, 0))
        label.set_textcolor(_result, f_text_on(_bg))
        label.set_size(_result, f_size(_size))
    _result

f_set_connector(line _id, int _x1, float _y1, int _x2, float _y2, color _lineColor, bool _dashed) =>
    line _result = _id
    if na(_result)
        _result := line.new(_x1, _y1, _x2, _y2, xloc = xloc.bar_index, extend = extend.none, color = color.new(_lineColor, 15), width = 2, style = _dashed ? line.style_dashed : line.style_solid)
    else
        line.set_xy1(_result, _x1, _y1)
        line.set_xy2(_result, _x2, _y2)
        line.set_color(_result, color.new(_lineColor, 15))
        line.set_style(_result, _dashed ? line.style_dashed : line.style_solid)
    _result

// -------------------------------------------------
// Inputs
// -------------------------------------------------
G_KC     = "Keltner Engine"
G_SCORE  = "Release Engine"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

maLength = input.int(20, "Keltner Basis Length", minval = 2, maxval = 300, group = G_KC,
     tooltip = "EMA length used as the Keltner Channel basis.")
atrLength = input.int(20, "ATR Length", minval = 2, maxval = 300, group = G_KC,
     tooltip = "ATR length used for Keltner Channel width, squeeze depth, target corridor, and label offset.")
kcMult = input.float(1.50, "Keltner ATR Multiplier", minval = 0.10, maxval = 10.0, step = 0.05, group = G_KC,
     tooltip = "ATR multiplier used to build the upper and lower Keltner Channel.")
squeezeLookback = input.int(120, "Squeeze Lookback", minval = 30, maxval = 800, group = G_KC,
     tooltip = "Lookback used to compare current Keltner width against recent width history.")
squeezeThreshold = input.int(42, "Squeeze Threshold", minval = 5, maxval = 80, group = G_KC,
     tooltip = "Maximum width rank accepted as a squeeze. Lower values require deeper compression.")
minSqueezeBars = input.int(3, "Minimum Squeeze Bars", minval = 1, maxval = 80, group = G_KC,
     tooltip = "Minimum number of recent squeeze bars required before a release can become READY.")

confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Fast", "Balanced", "Strict"], group = G_SCORE,
     tooltip = "Fast reacts earlier, Balanced requires cleaner release quality, and Strict demands stronger expansion.")
minReadyScore = input.int(60, "Minimum Ready Score", minval = 1, maxval = 100, group = G_SCORE,
     tooltip = "Minimum 0-100 release score required before READY appears.")
releaseBufferAtr = input.float(0.00, "Release Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.01, group = G_SCORE,
     tooltip = "ATR-based close distance beyond the Keltner Channel required to confirm release.")
expansionNeed = input.float(1.02, "Expansion Ratio Needed", minval = 1.00, maxval = 3.00, step = 0.01, group = G_SCORE,
     tooltip = "Current Keltner width must expand by this ratio compared with the prior bar to support release quality.")
failureBufferAtr = input.float(1.00, "Failure Give-Back ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = G_SCORE,
     tooltip = "How far price must give back from the release edge, in ATR, before the release is marked failed. Frozen at the release bar so a normal retest of the channel does not invalidate a valid release.")
releaseWindowBars = input.int(80, "Release Window Bars", minval = 5, maxval = 500, group = G_SCORE,
     tooltip = "Maximum number of bars after a release during which the script keeps evaluating continuation and failure risk.")
targetOneAtr = input.float(1.00, "Target 1 ATR", minval = 0.10, maxval = 10.0, step = 0.05, group = G_SCORE,
     tooltip = "First projected expansion target from the release edge.")
targetTwoAtr = input.float(1.80, "Target 2 ATR", minval = 0.10, maxval = 20.0, step = 0.05, group = G_SCORE,
     tooltip = "Second projected expansion target from the release edge.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = G_SCORE,
     tooltip = "Adds relative volume participation to the release score.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = G_SCORE,
     tooltip = "Lookback used to compare current volume against recent average participation.")

showChannels = input.bool(true, "Show Keltner Channels", group = G_VISUAL,
     tooltip = "Shows the Keltner basis and channel boundaries.")
showChannelFill = input.bool(true, "Show Channel Fill", group = G_VISUAL,
     tooltip = "Adds a subtle fill between Keltner boundaries so compression and expansion are easier to see.")
showChannelProjection = input.bool(false, "Show Channel Projection", group = G_VISUAL,
     tooltip = "Projects the current Keltner boundaries to the right.")
showSqueezeZone = input.bool(true, "Show Compression Zone", group = G_VISUAL,
     tooltip = "Highlights the Keltner channel area during active compression.")
showReleaseCorridor = input.bool(true, "Show Release Corridor", group = G_VISUAL,
     tooltip = "Shows the projected expansion corridor after a valid release.")
showFailureShelf = input.bool(true, "Show Failure Shelf", group = G_VISUAL,
     tooltip = "Shows the area where a release loses quality.")
showZoneBadges = input.bool(true, "Show Centered Zone Badges", group = G_VISUAL,
     tooltip = "Adds separate centered badges inside compression, release corridor, and failure shelf zones.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows READY RELEASE and FAILED RELEASE labels.")
showSqueezeLabels = input.bool(false, "Show Squeeze Labels", group = G_VISUAL,
     tooltip = "Shows compression labels. Disabled by default for cleaner publication screenshots.")
showFailedLabels = input.bool(false, "Show Failed Release Labels", group = G_VISUAL,
     tooltip = "Shows failed release labels. Disabled by default to keep screenshots focused.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for release edge and targets.")
rightTagOffset = input.int(6, "Right Tag Edge Offset Bars", minval = 2, maxval = 40, group = G_VISUAL,
     tooltip = "Places the owned Release Edge, T1, and T2 badge lane this many bars beyond the active corridor boundary, fully separating it from centered zone identities.")
rightTagGapAtr = input.float(0.48, "Right Tag Minimum Gap ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = G_VISUAL,
     tooltip = "Minimum ATR-based vertical separation between Release Edge, T1, and T2 badges. The selected font size also adjusts the gap.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly when squeeze or release states are active.")
projectionBars = input.int(90, "Projection Bars", minval = 10, maxval = 600, group = G_VISUAL,
     tooltip = "How far the active release corridor projects to the right.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label, zone badge, and right-side tag size.")
labelOffsetAtr = input.float(0.70, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based vertical spacing used to keep labels away from candles. Larger values push labels further from price, reducing the chance that later candles reach a past label.")
maxEventLabels = input.int(10, "Max Event Labels", minval = 2, maxval = 60, group = G_VISUAL,
     tooltip = "Maximum number of event labels retained on chart.")
labelCooldownBars = input.int(10, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum bars between repeated event labels. Higher values reduce clustering.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Displays the AG Pro decision panel. Enabled by default.")
panelPositionInput = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group = G_PANEL,
     tooltip = "Controls where the panel appears on chart.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL,
     tooltip = "Controls whether the panel uses the AGPro dark theme, slate theme, or a light chart-friendly theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls text size inside the decision panel.")

alertReady = input.bool(true, "Alert: Squeeze Release Ready", group = G_ALERTS,
     tooltip = "Creates an alert condition when a squeeze release becomes READY.")
alertSqueeze = input.bool(false, "Alert: Compression Active", group = G_ALERTS,
     tooltip = "Creates an alert condition when Keltner compression is active.")
alertInvalidated = input.bool(true, "Alert: Release Failed", group = G_ALERTS,
     tooltip = "Creates an alert condition when a release loses quality and fails back inside the channel.")

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelFontSizeInput)
atr = ta.atr(atrLength)
atrSafe = na(atr) or atr <= 0 ? syminfo.mintick * 10 : atr
basis = ta.ema(close, maLength)
upper = basis + atr * kcMult
lower = basis - atr * kcMult
width = upper - lower
widthPct = basis != 0 ? width / math.abs(basis) * 100.0 : na
widthLow = ta.lowest(widthPct, squeezeLookback)
widthHigh = ta.highest(widthPct, squeezeLookback)
widthRange = math.max(widthHigh - widthLow, 0.0000001)
widthRank = not na(widthPct) ? f_clamp((widthPct - widthLow) / widthRange * 100.0, 0.0, 100.0) : na
isCompressed = not na(widthRank) and widthRank <= squeezeThreshold
squeezeBars = nz(ta.sma(isCompressed ? 1.0 : 0.0, minSqueezeBars) * minSqueezeBars, 0.0)
hadSqueeze = squeezeBars >= minSqueezeBars

volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0 ? volume / volAvg : 1.0
expansionRatio = width[1] > 0 ? width / width[1] : 1.0
releaseBuffer = atrSafe * releaseBufferAtr
bullRelease = hadSqueeze[1] and close > upper + releaseBuffer and expansionRatio >= expansionNeed
bearRelease = hadSqueeze[1] and close < lower - releaseBuffer and expansionRatio >= expansionNeed
releaseDir = bullRelease ? 1 : bearRelease ? -1 : 0

var int activeDir = 0
var int releaseBar = na
var float releaseEdge = na
var float releaseAtr = na
var float activeScore = na
var bool activeReleased = false
var float failLevel = na
var bool t1Reached = false
var bool outcomeLogged = false
var array<int> ftArr = array.new<int>()

rangeSize = math.max(high - low, syminfo.mintick)
locLow  = ta.lowest(low, 5)
locHigh = ta.highest(high, 5)
closePressure = releaseDir == 1 ? (close - upper) / atrSafe : releaseDir == -1 ? (lower - close) / atrSafe : 0.0
bodyRatio = math.abs(close - open) / rangeSize
compressionScore = f_clamp((squeezeThreshold - widthRank + 10.0) / math.max(squeezeThreshold + 10.0, 1.0), 0.0, 1.0) * 24.0
expansionScore = f_clamp((expansionRatio - 1.0) / 0.45, 0.0, 1.0) * 22.0
closeScore = f_clamp(closePressure / 0.75, 0.0, 1.0) * 22.0
bodyScore = f_clamp(bodyRatio / 0.70, 0.0, 1.0) * 14.0
volumeScore = useVolumeScore ? f_clamp(rvol / 1.6, 0.0, 1.0) * 10.0 : 7.0
slopeScore = f_clamp(math.abs(basis - basis[3]) / atrSafe, 0.0, 1.0) * 8.0
candidateScore = f_clamp(compressionScore + expansionScore + closeScore + bodyScore + volumeScore + slopeScore, 0.0, 100.0)
requiredScore = confirmationMode == "Fast" ? math.max(minReadyScore - 5, 1) : confirmationMode == "Strict" ? math.min(minReadyScore + 8, 100) : minReadyScore
readyEvent = releaseDir != 0 and candidateScore >= requiredScore

if readyEvent
    activeDir := releaseDir
    releaseBar := bar_index
    releaseEdge := releaseDir == 1 ? upper : lower
    releaseAtr := atrSafe
    activeScore := candidateScore
    activeReleased := true
    failLevel := releaseDir == 1 ? releaseEdge - releaseAtr * failureBufferAtr : releaseEdge + releaseAtr * failureBufferAtr
    t1Reached := false
    outcomeLogged := false

barsFromRelease = activeReleased and not na(releaseBar) ? bar_index - releaseBar : na
withinReleaseWindow = activeReleased and not na(barsFromRelease) and barsFromRelease <= releaseWindowBars
target1 = activeDir == 1 ? releaseEdge + releaseAtr * targetOneAtr : activeDir == -1 ? releaseEdge - releaseAtr * targetOneAtr : na
target2 = activeDir == 1 ? releaseEdge + releaseAtr * targetTwoAtr : activeDir == -1 ? releaseEdge - releaseAtr * targetTwoAtr : na
failureLine = withinReleaseWindow ? failLevel : na
failedRelease = withinReleaseWindow and ((activeDir == 1 and close < failureLine) or (activeDir == -1 and close > failureLine))
expiredRelease = activeReleased and not withinReleaseWindow

// Follow-through tracking: did price tag T1 before the release resolved?
if activeReleased and withinReleaseWindow and not na(target1)
    if (activeDir == 1 and high >= target1) or (activeDir == -1 and low <= target1)
        t1Reached := true

// Resolution commits on confirmed bars: log the outcome once (T1 reached before failure/expiry), then close the release
if (failedRelease or expiredRelease) and barstate.isconfirmed
    if not outcomeLogged
        array.push(ftArr, t1Reached ? 1 : 0)
        if array.size(ftArr) > 30
            array.shift(ftArr)
        outcomeLogged := true
    activeReleased := false

continuationProgress = withinReleaseWindow and activeDir != 0 and not na(target1) ? activeDir == 1 ? f_clamp((close - releaseEdge) / math.max(target1 - releaseEdge, syminfo.mintick), 0.0, 1.5) : f_clamp((releaseEdge - close) / math.max(releaseEdge - target1, syminfo.mintick), 0.0, 1.5) : na
failureRisk = withinReleaseWindow ? f_clamp((failedRelease ? 50.0 : 0.0) + (1.0 - nz(continuationProgress, 0.0)) * 28.0 + (100.0 - nz(activeScore, 50.0)) * 0.18, 0.0, 100.0) : na

// -------------------------------------------------
// Keltner channel plots
// -------------------------------------------------
plotUpper = plot(showChannels ? upper : na, title = "Keltner Upper", color = color.new(accentColor, 28), linewidth = 1)
plotBasis = plot(showChannels ? basis : na, title = "Keltner Basis", color = color.new(neutralColor, 42), linewidth = 1)
plotLower = plot(showChannels ? lower : na, title = "Keltner Lower", color = color.new(accentColor, 28), linewidth = 1)
fill(plotUpper, plotLower, title = "Keltner Channel Fill", color = showChannels and showChannelFill ? color.new(isCompressed ? accentColor : panelBorder, isCompressed ? 90 : 96) : na)

var string actionState = "WAIT"
var string squeezeState = "No Squeeze"
var string releaseState = "Neutral"
var float panelScore = na
var float panelVolatility = na

if readyEvent
    actionState := "READY"
    squeezeState := "Release Accepted"
    releaseState := releaseDir == 1 ? "Bullish" : "Bearish"
    panelScore := candidateScore
    panelVolatility := widthRank
else if failedRelease
    actionState := "INVALIDATED"
    squeezeState := "Failed Release"
    releaseState := activeDir == 1 ? "Bull Failed" : "Bear Failed"
    panelScore := activeScore
    panelVolatility := widthRank
else if withinReleaseWindow
    actionState := "MONITOR"
    squeezeState := "Expansion Active"
    releaseState := activeDir == 1 ? "Bullish" : activeDir == -1 ? "Bearish" : "Neutral"
    panelScore := activeScore
    panelVolatility := widthRank
else if isCompressed
    actionState := "WAIT"
    squeezeState := "Compression"
    releaseState := "Neutral"
    panelScore := candidateScore
    panelVolatility := widthRank
else
    actionState := "WAIT"
    squeezeState := "No Squeeze"
    releaseState := "Neutral"
    panelScore := na
    panelVolatility := widthRank

// -------------------------------------------------
// Visuals
// -------------------------------------------------
var line basisLine = na
var line upperLine = na
var line lowerLine = na
var box squeezeBox = na
var box corridorBox = na
var box failBox = na
var label squeezeBadge = na
var label corridorBadge = na
var label failBadge = na
var line targetOneLine = na
var line targetTwoLine = na
var label tagEdge = na
var label tagT1 = na
var label tagT2 = na
var line tagEdgeConnector = na
var line tagT1Connector = na
var line tagT2Connector = na
var label[] eventLabels = array.new_label()
var int lastReadyLabelBar = na
var int lastSqueezeLabelBar = na
var int lastFailedLabelBar = na

rightX = bar_index + projectionBars
stateColor = actionState == "READY" or actionState == "MONITOR" ? (releaseState == "Bearish" or releaseState == "Bear Failed" ? bearColor : bullColor) : isCompressed ? accentColor : neutralColor
zoneBadgeRankText = na(widthRank) ? "RANK n/a" : "RANK " + str.tostring(math.round(widthRank))
zoneBadgeScoreText = na(activeScore) ? "SCORE n/a" : "SCORE " + str.tostring(math.round(activeScore))

if showChannels and showChannelProjection
    if na(basisLine)
        basisLine := line.new(bar_index, basis, rightX, basis, color = color.new(neutralColor, 58), width = 1, style = line.style_dotted)
    else
        line.set_xy1(basisLine, bar_index, basis)
        line.set_xy2(basisLine, rightX, basis)
    if na(upperLine)
        upperLine := line.new(bar_index, upper, rightX, upper, color = color.new(accentColor, 36), width = 1, style = line.style_dashed)
    else
        line.set_xy1(upperLine, bar_index, upper)
        line.set_xy2(upperLine, rightX, upper)
    if na(lowerLine)
        lowerLine := line.new(bar_index, lower, rightX, lower, color = color.new(accentColor, 36), width = 1, style = line.style_dashed)
    else
        line.set_xy1(lowerLine, bar_index, lower)
        line.set_xy2(lowerLine, rightX, lower)
else
    if not na(basisLine)
        line.delete(basisLine)
        basisLine := na
    if not na(upperLine)
        line.delete(upperLine)
        upperLine := na
    if not na(lowerLine)
        line.delete(lowerLine)
        lowerLine := na

if not na(squeezeBadge)
    label.delete(squeezeBadge)
    squeezeBadge := na
if not na(corridorBadge)
    label.delete(corridorBadge)
    corridorBadge := na
if not na(failBadge)
    label.delete(failBadge)
    failBadge := na

if showSqueezeZone and isCompressed
    if na(squeezeBox)
        squeezeBox := box.new(bar_index, upper, rightX, lower, bgcolor = color.new(accentColor, 92), border_color = color.new(accentColor, 42), border_width = 1)
    else
        box.set_lefttop(squeezeBox, bar_index, upper)
        box.set_rightbottom(squeezeBox, rightX, lower)
    if showZoneBadges and barstate.islast
        squeezeBadge := label.new(bar_index + int(math.round(projectionBars * 0.5)), (upper + lower) / 2.0, "KELTNER SQUEEZE | " + zoneBadgeRankText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = labelSize)
else
    if not na(squeezeBox)
        box.delete(squeezeBox)
        squeezeBox := na

corridorTop = activeDir == 1 ? target2 : releaseEdge
corridorBottom = activeDir == 1 ? releaseEdge : target2
if showReleaseCorridor and withinReleaseWindow and not na(corridorTop) and not na(corridorBottom)
    corridorColor = activeDir == 1 ? bullColor : bearColor
    if na(corridorBox)
        corridorBox := box.new(releaseBar, corridorTop, rightX, corridorBottom, bgcolor = color.new(corridorColor, 90), border_color = color.new(corridorColor, 30), border_width = 1)
    else
        box.set_lefttop(corridorBox, releaseBar, corridorTop)
        box.set_rightbottom(corridorBox, rightX, corridorBottom)
        box.set_bgcolor(corridorBox, color.new(corridorColor, 90))
        box.set_border_color(corridorBox, color.new(corridorColor, 30))
    if showZoneBadges and barstate.islast
        corridorBadge := label.new(releaseBar + int(math.round((rightX - releaseBar) * 0.5)), (corridorTop + corridorBottom) / 2.0, (activeDir == 1 ? "BULL RELEASE" : "BEAR RELEASE") + " | " + zoneBadgeScoreText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(corridorColor, 0), textcolor = f_text_on(corridorColor), size = labelSize)
else
    if not na(corridorBox)
        box.delete(corridorBox)
        corridorBox := na

failTop = activeDir == 1 ? releaseEdge : failureLine
failBottom = activeDir == 1 ? failureLine : releaseEdge
if showFailureShelf and withinReleaseWindow and not na(failTop) and not na(failBottom)
    if na(failBox)
        failBox := box.new(releaseBar, failTop, rightX, failBottom, bgcolor = color.new(bearColor, 92), border_color = color.new(bearColor, 40), border_width = 1)
    else
        box.set_lefttop(failBox, releaseBar, failTop)
        box.set_rightbottom(failBox, rightX, failBottom)
    if showZoneBadges and barstate.islast
        failBadge := label.new(releaseBar + int(math.round((rightX - releaseBar) * 0.5)), (failTop + failBottom) / 2.0, "FAILURE SHELF | RISK " + (na(failureRisk) ? "n/a" : str.tostring(math.round(failureRisk))), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bearColor, 0), textcolor = f_text_on(bearColor), size = labelSize)
else
    if not na(failBox)
        box.delete(failBox)
        failBox := na

if withinReleaseWindow and not na(target1) and not na(target2)
    if na(targetOneLine)
        targetOneLine := line.new(releaseBar, target1, rightX, target1, color = color.new(neutralColor, 12), width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetOneLine, releaseBar, target1)
        line.set_xy2(targetOneLine, rightX, target1)
    if na(targetTwoLine)
        targetTwoLine := line.new(releaseBar, target2, rightX, target2, color = color.new(accentColor, 18), width = 1, style = line.style_dashed)
    else
        line.set_xy1(targetTwoLine, releaseBar, target2)
        line.set_xy2(targetTwoLine, rightX, target2)
else
    if not na(targetOneLine)
        line.delete(targetOneLine)
        targetOneLine := na
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
        targetTwoLine := na

canReadyLabel = na(lastReadyLabelBar) or bar_index - lastReadyLabelBar >= labelCooldownBars
canSqueezeLabel = na(lastSqueezeLabelBar) or bar_index - lastSqueezeLabelBar >= labelCooldownBars
canFailedLabel = na(lastFailedLabelBar) or bar_index - lastFailedLabelBar >= labelCooldownBars

if showEventLabels and readyEvent and canReadyLabel
    label releaseLabel = label.new(bar_index, releaseDir == 1 ? locLow - atrSafe * labelOffsetAtr : locHigh + atrSafe * labelOffsetAtr,
         (releaseDir == 1 ? "BULL RELEASE" : "BEAR RELEASE") + " | Q " + str.tostring(math.round(candidateScore)),
         style = releaseDir == 1 ? label.style_label_up : label.style_label_down,
         textcolor = f_text_on(releaseDir == 1 ? bullColor : bearColor),
         color = color.new(releaseDir == 1 ? bullColor : bearColor, 0),
         size = labelSize)
    lastReadyLabelBar := bar_index
    array.push(eventLabels, releaseLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if showEventLabels and showSqueezeLabels and isCompressed and canSqueezeLabel
    label squeezeLabel = label.new(bar_index, basis,
         "SQUEEZE | RANK " + str.tostring(math.round(widthRank)),
         style = label.style_label_left,
         textcolor = f_text_on(accentColor),
         color = color.new(accentColor, 8),
         size = labelSize)
    lastSqueezeLabelBar := bar_index
    array.push(eventLabels, squeezeLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if showEventLabels and showFailedLabels and failedRelease and canFailedLabel
    label failLabel = label.new(bar_index, activeDir == 1 ? locHigh + atrSafe * labelOffsetAtr : locLow - atrSafe * labelOffsetAtr,
         "FAILED RELEASE | BACK INSIDE",
         style = activeDir == 1 ? label.style_label_down : label.style_label_up,
         textcolor = f_text_on(bearColor),
         color = color.new(bearColor, 0),
         size = labelSize)
    lastFailedLabelBar := bar_index
    array.push(eventLabels, failLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if barstate.islast and showRightTags and withinReleaseWindow
    tagX = rightX + rightTagOffset
    connectorX = rightX
    laneGap = atrSafe * rightTagGapAtr * f_lane_mult(labelSizeInput)
    edgeTagY = releaseEdge
    t1TagY = target1
    t2TagY = target2
    if activeDir == 1
        t1TagY := math.max(t1TagY, edgeTagY + laneGap)
        t2TagY := math.max(t2TagY, t1TagY + laneGap)
    else
        t1TagY := math.min(t1TagY, edgeTagY - laneGap)
        t2TagY := math.min(t2TagY, t1TagY - laneGap)
    edgeColor = activeDir == 1 ? bullColor : bearColor
    tagEdge := f_set_tag(tagEdge, tagX, edgeTagY, "RELEASE EDGE | " + str.tostring(releaseEdge, format.mintick), edgeColor, labelSizeInput)
    tagT1 := f_set_tag(tagT1, tagX, t1TagY, "T1 | " + str.tostring(target1, format.mintick), neutralColor, labelSizeInput)
    tagT2 := f_set_tag(tagT2, tagX, t2TagY, "T2 | " + str.tostring(target2, format.mintick), accentColor, labelSizeInput)
    tagEdgeConnector := f_set_connector(tagEdgeConnector, connectorX, releaseEdge, tagX, edgeTagY, edgeColor, false)
    tagT1Connector := f_set_connector(tagT1Connector, connectorX, target1, tagX, t1TagY, neutralColor, true)
    tagT2Connector := f_set_connector(tagT2Connector, connectorX, target2, tagX, t2TagY, accentColor, true)
else if barstate.islast
    if not na(tagEdge)
        label.delete(tagEdge)
        tagEdge := na
    if not na(tagT1)
        label.delete(tagT1)
        tagT1 := na
    if not na(tagT2)
        label.delete(tagT2)
        tagT2 := na
    if not na(tagEdgeConnector)
        line.delete(tagEdgeConnector)
        tagEdgeConnector := na
    if not na(tagT1Connector)
        line.delete(tagT1Connector)
        tagT1Connector := na
    if not na(tagT2Connector)
        line.delete(tagT2Connector)
        tagT2Connector := na

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelBgFinal = f_panel_bg(panelTheme)
panelTextFinal = f_panel_value(panelTheme)
panelLabelFinal = f_panel_label(panelTheme)
squeezeText = squeezeState
scoreText = f_score_text(panelScore)
volText = na(panelVolatility) ? "n/a" : str.tostring(math.round(panelVolatility)) + " rank"
riskText = na(failureRisk) ? "n/a" : str.tostring(math.round(failureRisk)) + "/100"

ftN = array.size(ftArr)
ftWins = nz(array.sum(ftArr))
ftText = ftN > 0 ? str.tostring(math.round(ftWins / ftN * 100)) + "%  (" + str.tostring(ftN) + ")" : "n/a"

biasBase = releaseState == "Bullish" ? bullColor : releaseState == "Bearish" ? bearColor : neutralColor

var table panel = na

if showPanel and barstate.islast
    if na(panel)
        panel := table.new(f_panel_position(panelPositionInput), 2, 7, border_width = 1, border_color = f_panel_border(panelTheme), frame_color = f_panel_border(panelTheme), frame_width = 1, bgcolor = panelBgFinal)
    table.set_position(panel, f_panel_position(panelPositionInput))
    table.clear(panel, 0, 0, 1, 6)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Keltner Squeeze Release Planner", text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 0, 1, "Squeeze", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 1, squeezeText, text_color = panelTextFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 2, "Release Score", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 2, scoreText, text_color = panelTextFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 3, "Follow-Through", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 3, ftText, text_color = panelTextFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 4, "Volatility", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 4, volText, text_color = panelTextFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 0, 5, "Direction Bias", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 5, releaseState, text_color = f_text_on(biasBase), bgcolor = color.new(biasBase, releaseState == "Neutral" ? 16 : 8), text_size = panelSize)
    table.cell(panel, 0, 6, "Action", text_color = panelLabelFinal, bgcolor = panelBgFinal, text_size = panelSize)
    table.cell(panel, 1, 6, actionState, text_color = f_text_on(f_action_base(actionState)), bgcolor = f_action_color(actionState), text_size = panelSize)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

// -------------------------------------------------
// Bar color and alerts
// -------------------------------------------------
barStateColor = actionState == "READY" ? color.new(activeDir == 1 ? bullColor : bearColor, 76) :
     actionState == "MONITOR" ? color.new(activeDir == 1 ? bullColor : bearColor, 84) :
     isCompressed ? color.new(accentColor, 88) :
     actionState == "INVALIDATED" ? color.new(bearColor, 80) : na
barcolor(showBarColors ? barStateColor : na)

alertcondition(alertReady and readyEvent and releaseDir == 1, "Bullish Keltner Squeeze Release Ready",
     "AG Pro KSR | BULLISH KELTNER SQUEEZE RELEASE READY | {{ticker}} | {{interval}}")
alertcondition(alertReady and readyEvent and releaseDir == -1, "Bearish Keltner Squeeze Release Ready",
     "AG Pro KSR | BEARISH KELTNER SQUEEZE RELEASE READY | {{ticker}} | {{interval}}")
alertcondition(alertSqueeze and isCompressed, "Keltner Compression Active",
     "AG Pro KSR | KELTNER COMPRESSION ACTIVE | {{ticker}} | {{interval}}")
alertcondition(alertInvalidated and failedRelease, "Keltner Squeeze Release Failed",
     "AG Pro KSR | KELTNER SQUEEZE RELEASE FAILED | {{ticker}} | {{interval}}")
````
