# Breakout Participation Gate [AGPro Series]

- url: https://www.tradingview.com/script/Dbaye4fI-Breakout-Participation-Gate-AGPro-Series/
- type: indicator
- pine_id: PUB;488208448dd54d2d83dea384cdfb3563
- version: 4.0

## Description

Breakout Participation Gate [AGPro Series]

🧠 Core Idea

Does the breakout have enough participation and structure to deserve attention?


📌 Overview / What it does

Breakout Participation Gate is a breakout validation tool built to separate structured breakouts from weak breaks and fakeout-prone moves.

The script builds upper and lower breakout gate levels from recent structure, evaluates breakout candle quality, checks relative volume, body commitment, close location, trend context, retest behavior, expansion potential, and fakeout risk.

It does not predict price direction, automate trades, or claim that a gate-open event must continue. It is a structured visualization and decision-support tool for breakout participation review.

[image]https://www.tradingview.com/x/AEfdbpdn/[/image]

🎯 Purpose & Design Philosophy

Breakouts are among the most searched and most misunderstood market events.

Many tools mark every move above resistance or below support.

This script was built to ask a stricter question:

Did the breakout pass the participation gate?

The design goal is to help traders avoid treating every structural break as equally meaningful.


⚡ Why This Script Is Different

Most breakout tools focus on the break itself.

This script does NOT mark every breakout as valid.

Instead, it checks whether the breakout had enough relative volume, body commitment, close location, range expansion, trend context, and retest behavior. It also keeps the active gate visible so users can watch whether the breakout holds, expands, or fails back inside the structure.


⚙️ Methodology

1. Context Detection

The script identifies recent upper and lower gate levels using a structure lookback.

2. Breakout Qualification

When price closes beyond a gate, the script scores participation through volume, candle body, close location, range expansion, and trend context.

3. Gate Classification

High-quality breakouts can become GATE OPEN events. Lower-quality breaks can be classified as WEAK BREAK.

4. Retest Evaluation

After a gate opens, the script projects a retest shelf and watches whether price defends the shelf.

5. Fakeout and Expansion Review

The script tracks whether price closes back inside the gate shelf or expands beyond the active gate with acceptable participation.

6. Visual Output

The chart displays breakout gate lines, retest shelf, event labels, right-side tags, alerts, and a compact AG Pro panel.


🗺️ How to Read the Chart

Upper Gate = recent upper structure level that price must break to start an upside gate evaluation.

Lower Gate = recent lower structure level that price must break to start a downside gate evaluation.

Breakout Retest Shelf = the active zone around the gate where retest behavior is evaluated.

GATE OPEN = breakout passed the participation gate.

WEAK BREAK = price broke the gate but participation quality was not strong enough.

RETEST HOLD = price defended the active retest shelf after the breakout.

FAKEOUT RISK = price closed back inside the gate shelf after the breakout.

EXPANSION READY = price expanded beyond the gate while participation remained acceptable.

Panel = summarizes gate status, quality score, direction, relative volume, body commitment, retest health, fakeout risk, and next context.


🚦 Signals & States

• GATE OPEN → breakout passed the participation gate.

• WEAK BREAK → price broke structure but did not show enough participation quality.

• GATE WATCH → active gate is being monitored after a breakout.

• RETEST HOLD → active retest shelf was defended.

• FAKEOUT RISK → price closed back through the gate shelf.

• EXPANSION READY → price expanded beyond the gate with acceptable participation.

• WAIT BREAKOUT → no active gate has been triggered.


🔔 Alerts Logic

Alerts trigger when a major breakout-gate state appears.

• Breakout Gate Open → breakout passed the participation gate.

• Weak Breakout → price broke a gate level without enough participation quality.

• Breakout Retest Hold → active retest shelf was defended.

• Breakout Fakeout Risk → price closed back inside the gate shelf after the breakout.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• Price closes beyond a defined structure gate
• Relative volume is above normal
• Candle body commitment is strong
• Close location supports the breakout direction
• Range expands versus ATR
• The breakout direction agrees with trend context
• Retest behavior respects the active gate shelf

When these elements do not align, the script avoids treating the breakout as automatically valid.


📊 When to Use

• Breakout validation
• Failed breakout review
• Retest planning
• Trend continuation review
• Crypto, stocks, futures, forex, and liquid markets
• 15m, 30m, 1H, 4H, and 1D charts


⚠️ When NOT to Use

• Very low-liquidity assets
• Extremely noisy micro timeframes
• Symbols with unreliable volume
• News-driven spikes where structure can be distorted
• Markets where every wick break is being over-interpreted
• Situations where a single breakout label is expected to act as a guaranteed signal


🎛️ Key Inputs

• Gate Structure Lookback → defines the recent structure window used for upper and lower gates.

• Breakout Close Buffer ATR → controls how far beyond the gate price must close.

• Minimum Breakout Relative Volume → defines how much participation is required for strong volume credit.

• Minimum Body Commitment % → controls how much candle body participation is required.

• Gate Quality Threshold → separates gate-open breakouts from weak breaks.

• Retest Evaluation Window → defines how long the active gate shelf remains under review.

• Retest Shelf Width ATR → controls the thickness of the retest shelf around the active gate.

• Expansion Ready Distance ATR → defines when a breakout has expanded far enough to be monitored as continuation-ready.

• Event Label Mode → Premium focuses on higher-quality gate states. Detailed allows more weak-break labels.


🖥️ Interface & Visual Design

The visual hierarchy is built around the gate:

Gate lines define the structure.

The retest shelf shows where the breakout should hold.

Event labels mark gate-open, weak-break, retest-hold, fakeout-risk, and expansion-ready states.

Right-side tags keep the active gate context visible.

The AG Pro panel compresses the current breakout context into a fast, readable summary.


🧪 Practical Usage Workflow

1. Read the panel gate status.

2. Check whether price has broken the upper or lower gate.

3. Compare quality score with the event label.

4. Watch the active retest shelf.

5. Check whether price holds, expands, or fails back inside the gate.

6. Confirm with broader market structure, liquidity, volume, and risk planning.


🔍 Interpretation Guidelines

A gate-open label does not guarantee continuation.

A weak-break label does not guarantee reversal.

A retest-hold label means the active shelf was defended according to the script's rules.

A fakeout-risk label means the breakout structure weakened.

The script is best used as a breakout-quality layer, not as a standalone trading system.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a simple support/resistance breakout marker.


⚠️ Limitations & Transparency

Breakout quality depends on market structure and liquidity.

Volume behavior can differ across crypto, futures, stocks, and forex.

Choppy ranges can create repeated weak-break and fakeout states.

Different timeframes may show different gate behavior.

Highly volatile news events can distort breakout quality.


🧠 Market Context Notes

Breakouts are strongest when structure, candle commitment, participation, and retest behavior align.

The first break is only one part of the story.

The active gate shelf helps users watch whether the market accepts the breakout after the first impulse.


🧾 Use Case Examples

If price closes above the upper gate with strong participation, the script may mark GATE OPEN.

If price breaks a gate but quality is weak, the script may mark WEAK BREAK.

If price returns to the active shelf and defends it, the script may mark RETEST HOLD.

If price closes back through the shelf, the script may mark FAKEOUT RISK.


🧱 System Philosophy

The goal is not to chase every breakout.

The goal is to filter breakout attention.

This script treats breakout quality as a sequence:

structure break → participation gate → retest shelf → expansion or failure.


🔐 Non-Promise Statement

No breakout label guarantees continuation.

No weak-break label guarantees reversal.

No retest label guarantees a successful trend move.

All outputs should be interpreted as analytical context.


📉 Risk Disclosure

Trading involves risk.

This script is for educational and analytical purposes only.

It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users are fully responsible for their own decisions, risk management, and trade execution.


📚 Educational Note

Use the script to study which breakouts attract real participation and which breaks fail to hold their gate.

The most useful question is not only whether price broke structure.

The better question is whether the breakout deserved attention after the break.

## Source Code

````pine
// --------------------------------------------------
// Breakout Participation Gate [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Breakout Participation Gate studies whether a breakout has enough structure,
// body commitment, relative volume, and retest behavior to deserve attention.
// It maps breakout gate levels, participation shelves, retest quality, fakeout
// risk, event labels, alerts, and an AG Pro panel for breakout validation.
// Version 1.4 gives the active retest shelf one centered, state-aware identity
// and adds lifecycle-safe source connectors to a tighter event history while
// preserving the complete breakout, participation, retest, and fakeout engine.
// --------------------------------------------------

//@version=6
indicator("Breakout Participation Gate [AGPro Series]",
     shorttitle = "AG Pro BPG",
     overlay = true,
     max_labels_count = 160,
     max_lines_count = 80,
     max_boxes_count = 50)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
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

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_GATE   = "Breakout Gate Engine"
G_RETEST = "Retest and Fakeout Logic"
G_VISUAL = "Visuals"
G_PANEL  = "Panel"
G_ALERTS = "Alerts"

rangeLookback = input.int(48, "Gate Structure Lookback", minval = 10, maxval = 400, group = G_GATE,
     tooltip = "Lookback used to define the upper and lower breakout gate levels from recent structure.")
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G_GATE,
     tooltip = "ATR length used for gate buffers, retest shelf width, and label offsets.")
volumeLen = input.int(30, "Relative Volume Length", minval = 5, maxval = 300, group = G_GATE,
     tooltip = "Lookback used to compare current volume with recent participation.")
breakAtr = input.float(0.10, "Breakout Close Buffer ATR", minval = 0.0, maxval = 2.0, step = 0.01, group = G_GATE,
     tooltip = "Minimum close distance beyond the gate level before a breakout can be evaluated.")
minRelVol = input.float(1.15, "Minimum Breakout Relative Volume", minval = 0.10, maxval = 6.0, step = 0.05, group = G_GATE,
     tooltip = "Minimum relative volume required for a breakout to receive strong participation credit.")
minBodyPct = input.float(42.0, "Minimum Body Commitment %", minval = 5.0, maxval = 95.0, step = 1.0, group = G_GATE,
     tooltip = "Minimum candle body share of range. Higher values require stronger breakout commitment.")
gateQualityThreshold = input.int(62, "Gate Quality Threshold", minval = 1, maxval = 100, group = G_GATE,
     tooltip = "Minimum quality needed before a breakout is classified as gate-open instead of weak-break.")
trendLen = input.int(55, "Trend Context Length", minval = 5, maxval = 300, group = G_GATE,
     tooltip = "EMA length used as a lightweight context filter for breakout direction.")

retestWindowBars = input.int(36, "Retest Evaluation Window", minval = 3, maxval = 250, group = G_RETEST,
     tooltip = "Number of bars after the breakout where retest-hold and fakeout behavior are evaluated.")
retestShelfAtr = input.float(0.35, "Retest Shelf Width ATR", minval = 0.05, maxval = 3.0, step = 0.05, group = G_RETEST,
     tooltip = "Thickness of the retest shelf around the active breakout gate level.")
expansionAtr = input.float(1.10, "Expansion Ready Distance ATR", minval = 0.20, maxval = 6.0, step = 0.05, group = G_RETEST,
     tooltip = "Distance beyond the gate where the move is treated as expansion-ready if participation remains acceptable.")
fakeoutCloseAtr = input.float(0.18, "Fakeout Close Back ATR", minval = 0.01, maxval = 2.0, step = 0.01, group = G_RETEST,
     tooltip = "Distance back inside the gate shelf required before fakeout risk is highlighted.")
minRetestQuality = input.int(48, "Minimum Retest Quality", minval = 1, maxval = 100, group = G_RETEST,
     tooltip = "Minimum retest quality needed before a retest-hold label appears in Premium mode.")

showGateLines = input.bool(true, "Show Breakout Gate Lines", group = G_VISUAL,
     tooltip = "Displays the current upper and lower breakout gate levels.")
showRetestShelf = input.bool(true, "Show Active Retest Shelf", group = G_VISUAL,
     tooltip = "Displays the active retest shelf after a breakout gate is triggered.")
showEventLabels = input.bool(true, "Show Gate Event Labels", group = G_VISUAL,
     tooltip = "Prints controlled labels for gate-open, weak-break, retest-hold, fakeout-risk, and expansion-ready states.")
eventLabelMode = input.string("Premium", "Event Label Mode", options = ["Premium", "Detailed"], group = G_VISUAL,
     tooltip = "Premium mode focuses on high-quality gate states. Detailed mode also prints more weak-break labels.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for gate levels, active retest shelf, and gate quality.")
rightTagDetail = input.string("Compact", "Right Tag Detail", options = ["Compact", "Full"], group = G_VISUAL,
     tooltip = "Compact keeps right-side tags short for publication screenshots. Full adds price values to gate tags.")
projectionBars = input.int(80, "Projection Bars", minval = 10, maxval = 500, group = G_VISUAL,
     tooltip = "How far gate lines, retest shelf, and right-side tags project to the right.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL,
     tooltip = "Shortens projections on daily, weekly, and monthly charts so high-timeframe screenshots stay readable.")
labelCooldownBars = input.int(24, "Event Label Cooldown", minval = 1, maxval = 120, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels so the chart remains readable and premium.")
minGateLabelQuality = input.int(75, "Minimum Gate Label Quality", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum gate quality required before gate-open labels are printed in Premium mode.")
maxGateOpenLabels = input.int(2, "Max Gate-Open Labels", minval = 1, maxval = 10, group = G_VISUAL,
     tooltip = "Maximum number of gate-open labels kept in Premium mode between fakeout or new gate resets.")
maxRetainedEvents = input.int(5, "Maximum Retained Events", minval = 3, maxval = 12, group = G_VISUAL,
     tooltip = "Maximum number of historical event badge-and-connector pairs retained on the chart.")
eventLabelOffsetAtr = input.float(1.15, "Event Label Offset ATR", minval = 0.20, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves event labels away from candles and gate zones to reduce overlap.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Text size used by event labels, gate labels, and right-side tags.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro breakout participation panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between dark, slate, and clean light surfaces.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Text size used inside the panel.")

alertGateOpen = input.bool(true, "Alert: Gate Open", group = G_ALERTS,
     tooltip = "Enables alerts when a breakout passes the participation gate.")
alertWeakBreak = input.bool(true, "Alert: Weak Break", group = G_ALERTS,
     tooltip = "Enables alerts when price breaks a gate level without enough participation quality.")
alertRetestHold = input.bool(true, "Alert: Retest Hold", group = G_ALERTS,
     tooltip = "Enables alerts when the active retest shelf is defended after a breakout.")
alertFakeoutRisk = input.bool(true, "Alert: Fakeout Risk", group = G_ALERTS,
     tooltip = "Enables alerts when price closes back inside the gate shelf after a breakout.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
// Luminance-aware contrast text (target luminance 145)
f_lum(color c)      => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(color bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_max, _value))

f_size(_size) =>
    _result = size.normal
    if _size == "Tiny"
        _result := size.tiny
    else if _size == "Small"
        _result := size.small
    else if _size == "Large"
        _result := size.large
    else if _size == "Huge"
        _result := size.huge
    _result

f_panel_pos(_pos) =>
    _result = position.top_right
    if _pos == "Top Left"
        _result := position.top_left
    else if _pos == "Top Center"
        _result := position.top_center
    else if _pos == "Middle Right"
        _result := position.middle_right
    else if _pos == "Middle Center"
        _result := position.middle_center
    else if _pos == "Middle Left"
        _result := position.middle_left
    else if _pos == "Bottom Right"
        _result := position.bottom_right
    else if _pos == "Bottom Center"
        _result := position.bottom_center
    else if _pos == "Bottom Left"
        _result := position.bottom_left
    _result

f_fmt(_value) =>
    na(_value) ? "n/a" : str.tostring(_value, format.mintick)

f_score_text(_value) =>
    na(_value) ? "n/a" : str.tostring(math.round(_value))

f_panel_bg(_theme) =>
    _theme == "Light" ? color.rgb(248, 250, 252) : _theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_border(_theme) =>
    _theme == "Light" ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(_theme) =>
    _theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(_theme) =>
    _theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_event_text(_text, _score) =>
    _text + " | Q " + f_score_text(_score)

f_keep_event(array<label> _labels, array<line> _guides, label _label, line _guide, int _limit) =>
    array.push(_labels, _label)
    array.push(_guides, _guide)
    if array.size(_labels) > _limit
        label.delete(array.shift(_labels))
        line.delete(array.shift(_guides))

// Vertical anti-collision: shift a new event label's y away from recent labels
// that sit near the same bar, so labels never stack on compressed/HTF views.
f_event_y(array<label> _array, int _x, float _baseY, bool _up, float _gap) =>
    float _adjY = _baseY
    int _guard = 0
    bool _moved = true
    while _moved and _guard < 14
        _moved := false
        if array.size(_array) > 0
            for _i = 0 to array.size(_array) - 1
                label _ex = array.get(_array, _i)
                if math.abs(label.get_x(_ex) - _x) <= 10 and math.abs(label.get_y(_ex) - _adjY) < _gap
                    _adjY := _up ? _adjY + _gap : _adjY - _gap
                    _moved := true
                    break
        _guard += 1
    _adjY

// --------------------------------------------------
// Breakout Gate Engine
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelFontSizeInput)

atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
volBase = ta.sma(volume, volumeLen)
relVol = not na(volBase) and volBase > 0.0 ? volume / volBase : 1.0
trendRef = ta.ema(close, trendLen)

upperGate = ta.highest(high[1], rangeLookback)
lowerGate = ta.lowest(low[1], rangeLookback)
gateRange = math.max(upperGate - lowerGate, syminfo.mintick)

barRange = math.max(high - low, syminfo.mintick)
bodyPct = math.abs(close - open) / barRange * 100.0
closePos = f_clamp((close - low) / barRange * 100.0, 0.0, 100.0)

breakUpRaw = barstate.isconfirmed and not na(upperGate) and close > upperGate + safeAtr * breakAtr
breakDownRaw = barstate.isconfirmed and not na(lowerGate) and close < lowerGate - safeAtr * breakAtr
breakDir = breakUpRaw ? 1 : breakDownRaw ? -1 : 0

volumeScore = f_clamp(relVol / minRelVol * 100.0, 0.0, 150.0)
bodyScore = f_clamp(bodyPct / minBodyPct * 100.0, 0.0, 140.0)
locationScore = breakDir == 1 ? closePos : breakDir == -1 ? 100.0 - closePos : 50.0
rangeScore = f_clamp(barRange / safeAtr * 55.0, 0.0, 120.0)
trendScore = breakDir == 1 ? close > trendRef ? 100.0 : 35.0 : breakDir == -1 ? close < trendRef ? 100.0 : 35.0 : 50.0
gateQualityRaw = f_clamp(volumeScore * 0.32 + bodyScore * 0.27 + locationScore * 0.18 + rangeScore * 0.13 + trendScore * 0.10, 0.0, 100.0)

gateOpenEvent = breakDir != 0 and gateQualityRaw >= gateQualityThreshold
weakBreakEvent = breakDir != 0 and gateQualityRaw < gateQualityThreshold

var float activeGate = na
var float activeGateHigh = na
var float activeGateLow = na
var float activeGateQ = na
var int activeDir = 0
var int activeGateBar = na
var bool retestMemory = false
var bool fakeoutMemory = false
var bool expansionMemory = false
var int gateOpenLabelCount = 0
var label[] eventLabels = array.new<label>()
var line[] eventGuides = array.new<line>()

if gateOpenEvent or weakBreakEvent
    activeDir := breakDir
    activeGate := breakDir == 1 ? upperGate : lowerGate
    activeGateHigh := activeGate + safeAtr * retestShelfAtr
    activeGateLow := activeGate - safeAtr * retestShelfAtr
    activeGateQ := gateQualityRaw
    activeGateBar := bar_index
    retestMemory := false
    fakeoutMemory := false
    expansionMemory := false
    if weakBreakEvent
        gateOpenLabelCount := 0

hasActiveGate = not na(activeGate) and activeDir != 0
barsFromGate = hasActiveGate ? bar_index - activeGateBar : na
withinRetestWindow = hasActiveGate and barsFromGate > 0 and barsFromGate <= retestWindowBars

retestTouch = withinRetestWindow and low <= activeGateHigh and high >= activeGateLow
retestHoldUp = retestTouch and activeDir == 1 and close > activeGate and close > open
retestHoldDown = retestTouch and activeDir == -1 and close < activeGate and close < open
retestQuality = retestTouch ? f_clamp(activeGateQ * 0.50 + volumeScore * 0.20 + bodyScore * 0.15 + (100.0 - math.min(barsFromGate / retestWindowBars * 100.0, 100.0)) * 0.15, 0.0, 100.0) : na
retestHoldEvent = barstate.isconfirmed and (retestHoldUp or retestHoldDown) and retestQuality >= minRetestQuality and not retestMemory

fakeoutUp = withinRetestWindow and activeDir == 1 and close < activeGate - safeAtr * fakeoutCloseAtr
fakeoutDown = withinRetestWindow and activeDir == -1 and close > activeGate + safeAtr * fakeoutCloseAtr
fakeoutEvent = barstate.isconfirmed and (fakeoutUp or fakeoutDown) and not fakeoutMemory

expansionUp = withinRetestWindow and activeDir == 1 and close > activeGate + safeAtr * expansionAtr and relVol >= minRelVol * 0.85 and not expansionMemory
expansionDown = withinRetestWindow and activeDir == -1 and close < activeGate - safeAtr * expansionAtr and relVol >= minRelVol * 0.85 and not expansionMemory
expansionEvent = barstate.isconfirmed and (expansionUp or expansionDown)

if retestHoldEvent
    retestMemory := true

if fakeoutEvent
    fakeoutMemory := true
    retestMemory := false
    gateOpenLabelCount := 0

if expansionEvent
    expansionMemory := true

gateStatus = fakeoutMemory ? "FAKEOUT RISK" : retestMemory ? "RETEST HOLD" : expansionMemory ? "EXPANSION READY" : hasActiveGate and withinRetestWindow ? "GATE WATCH" : gateOpenEvent ? "GATE OPEN" : weakBreakEvent ? "WEAK BREAK" : "WAIT BREAKOUT"
gateColor = fakeoutMemory ? bearColor : retestMemory ? bullColor : expansionMemory ? accentColor : activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : panelValueCol
participationText = hasActiveGate ? f_score_text(activeGateQ) : f_score_text(gateQualityRaw)
retestText = fakeoutMemory ? "Failed" : retestMemory ? "Held" : withinRetestWindow ? "Watching" : "No active gate"
fakeoutText = fakeoutMemory ? "Active" : weakBreakEvent ? "Elevated" : withinRetestWindow ? "Not confirmed" : "Low"
directionText = activeDir == 1 ? "Upside gate" : activeDir == -1 ? "Downside gate" : "No active gate"
nextContext = fakeoutMemory ? "Respect failed gate" : retestMemory ? "Track continuation" : expansionMemory ? "Manage expansion" : weakBreakEvent ? "Wait confirmation" : withinRetestWindow ? "Watch retest shelf" : "Wait structure break"

// --------------------------------------------------
// Visual Structure
// --------------------------------------------------
var line upperLine = na
var line lowerLine = na
var box retestBox = na
var label shelfLabel = na
var label upperTag = na
var label lowerTag = na

adaptiveProjectionBars = adaptiveProjection ? timeframe.ismonthly ? math.min(projectionBars, 8) : timeframe.isweekly ? math.min(projectionBars, 26) : timeframe.isdaily ? math.min(projectionBars, 55) : projectionBars : projectionBars
visualLeft = math.max(bar_index - math.min(rangeLookback, 160), 0)
visualRight = bar_index + adaptiveProjectionBars
centerX = int(math.round((visualLeft + visualRight) * 0.5))
shelfCenterX = hasActiveGate ? activeGateBar + int(math.round((visualRight - activeGateBar) * 0.5)) : centerX

if barstate.islast and showGateLines
    if na(upperLine)
        upperLine := line.new(visualLeft, upperGate, visualRight, upperGate, xloc = xloc.bar_index, color = color.new(bearColor, 10), width = 2)
        lowerLine := line.new(visualLeft, lowerGate, visualRight, lowerGate, xloc = xloc.bar_index, color = color.new(bullColor, 10), width = 2)
    else
        line.set_xy1(upperLine, visualLeft, upperGate)
        line.set_xy2(upperLine, visualRight, upperGate)
        line.set_xy1(lowerLine, visualLeft, lowerGate)
        line.set_xy2(lowerLine, visualRight, lowerGate)

if barstate.islast and not showGateLines
    if not na(upperLine)
        line.delete(upperLine)
        line.delete(lowerLine)
        upperLine := na
        lowerLine := na

if barstate.islast and showRetestShelf and hasActiveGate
    shelfCol = activeDir == 1 ? bullColor : bearColor
    if na(retestBox)
        retestBox := box.new(activeGateBar, activeGateHigh, visualRight, activeGateLow, xloc = xloc.bar_index, bgcolor = color.new(shelfCol, 86), border_color = color.new(shelfCol, 30))
    else
        box.set_lefttop(retestBox, activeGateBar, activeGateHigh)
        box.set_rightbottom(retestBox, visualRight, activeGateLow)
        box.set_bgcolor(retestBox, color.new(shelfCol, 86))
        box.set_border_color(retestBox, color.new(shelfCol, 30))
    if na(shelfLabel)
        shelfLabel := label.new(shelfCenterX, activeGate, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(shelfCol), color = color.new(shelfCol, 0), size = labelSize)
    else
        label.set_x(shelfLabel, shelfCenterX)
        label.set_y(shelfLabel, activeGate)
        label.set_color(shelfLabel, color.new(shelfCol, 0))
        label.set_textcolor(shelfLabel, f_text_on(shelfCol))
        label.set_size(shelfLabel, labelSize)
    shelfSideText = activeDir == 1 ? "UPSIDE RETEST" : "DOWNSIDE RETEST"
    label.set_text(shelfLabel, shelfSideText + " | " + gateStatus + " | Q " + participationText)

if barstate.islast and (not showRetestShelf or not hasActiveGate)
    if not na(retestBox)
        box.delete(retestBox)
        retestBox := na
    if not na(shelfLabel)
        label.delete(shelfLabel)
        shelfLabel := na

// --------------------------------------------------
// Labels and Right Tags
// --------------------------------------------------
eventCandidate = gateOpenEvent or weakBreakEvent or retestHoldEvent or fakeoutEvent or expansionEvent
var int lastEventBar = na
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
eventAbove = breakDir == -1 or activeDir == -1 or fakeoutEvent
eventY = eventAbove ? high + safeAtr * eventLabelOffsetAtr : low - safeAtr * eventLabelOffsetAtr
eventStyle = eventAbove ? label.style_label_down : label.style_label_up
eventText = gateOpenEvent ? f_event_text("Gate Open", gateQualityRaw) : weakBreakEvent ? f_event_text("Weak Break", gateQualityRaw) : retestHoldEvent ? f_event_text("Retest Hold", retestQuality) : fakeoutEvent ? f_event_text("Fakeout Risk", activeGateQ) : f_event_text("Expansion Ready", activeGateQ)
eventCol = gateOpenEvent or retestHoldEvent ? bullColor : weakBreakEvent ? neutralColor : fakeoutEvent ? bearColor : accentColor
gateOpenAllowance = eventLabelMode == "Detailed" or (gateQualityRaw >= minGateLabelQuality and gateOpenLabelCount < maxGateOpenLabels)
weakBreakAllowance = eventLabelMode == "Detailed" or gateQualityRaw >= gateQualityThreshold - 8
allowEvent = gateOpenEvent ? gateOpenAllowance : weakBreakEvent ? weakBreakAllowance : true

if showEventLabels and eventCandidate and allowEvent and canPrintEvent
    float adjEventY = f_event_y(eventLabels, bar_index, eventY, eventAbove, safeAtr * 0.7)
    _newLabel = label.new(bar_index, adjEventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = eventStyle, textcolor = f_text_on(eventCol), color = eventCol, size = labelSize)
    float eventAnchorY = eventAbove ? high : low
    _newGuide = line.new(bar_index, eventAnchorY, bar_index, adjEventY, xloc = xloc.bar_index, color = color.new(eventCol, 38), width = 1)
    f_keep_event(eventLabels, eventGuides, _newLabel, _newGuide, maxRetainedEvents)
    lastEventBar := bar_index
    if gateOpenEvent
        gateOpenLabelCount += 1

if barstate.islast and showRightTags
    if not na(upperTag)
        label.delete(upperTag)
    if not na(lowerTag)
        label.delete(lowerTag)
    tagX = bar_index + adaptiveProjectionBars
    upperTagText = rightTagDetail == "Full" ? "Upper Break Gate  " + f_fmt(upperGate) : "Upper Break Gate"
    lowerTagText = rightTagDetail == "Full" ? "Lower Break Gate  " + f_fmt(lowerGate) : "Lower Break Gate"
    upperTag := label.new(tagX, upperGate, upperTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bearColor), color = bearColor, size = labelSize)
    lowerTag := label.new(tagX, lowerGate, lowerTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textcolor = f_text_on(bullColor), color = bullColor, size = labelSize)

if barstate.islast and not showRightTags
    if not na(upperTag)
        label.delete(upperTag)
        upperTag := na
    if not na(lowerTag)
        label.delete(lowerTag)
        lowerTag := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBgActive = f_panel_bg(panelTheme)
panelBorderActive = f_panel_border(panelTheme)
panelLabelActive = f_panel_label(panelTheme)
panelValueActive = f_panel_value(panelTheme)

var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelTheme)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 8, border_width = 1, border_color = panelBorderActive, frame_color = panelBorderActive, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Breakout Participation Gate", text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelTheme

if showPanel and not na(panel)
    table.cell(panel, 0, 1, "Gate Status", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 1, gateStatus, text_color = gateColor, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 2, "Quality Score", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 2, participationText, text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 3, "Gate Direction", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 3, directionText, text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 4, "RelVol / Body", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 4, str.tostring(relVol, "#.##") + " / " + f_score_text(bodyPct) + "%", text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 5, "Retest Health", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 5, retestText, text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 6, "Fakeout Risk", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 6, fakeoutText, text_color = fakeoutMemory ? bearColor : panelValueActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 0, 7, "Next Context", text_color = panelLabelActive, bgcolor = panelBgActive, text_size = panelSize)
    table.cell(panel, 1, 7, nextContext, text_color = panelValueActive, bgcolor = panelBgActive, text_size = panelSize)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertGateOpen and gateOpenEvent, "Breakout Gate Open", "Breakout Participation Gate: breakout passed the participation gate.")
alertcondition(alertWeakBreak and weakBreakEvent, "Weak Breakout", "Breakout Participation Gate: price broke a gate level without enough participation quality.")
alertcondition(alertRetestHold and retestHoldEvent, "Breakout Retest Hold", "Breakout Participation Gate: active retest shelf was defended after a breakout.")
alertcondition(alertFakeoutRisk and fakeoutEvent, "Breakout Fakeout Risk", "Breakout Participation Gate: price closed back inside the gate shelf after a breakout.")
````
