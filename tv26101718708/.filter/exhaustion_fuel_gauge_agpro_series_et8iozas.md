# Exhaustion Fuel Gauge [AGPro Series]

- url: https://www.tradingview.com/script/et8iOzaS-Exhaustion-Fuel-Gauge-AGPro-Series/
- type: indicator
- pine_id: PUB;7bd95493d4d74dfd9909db48d495527a
- version: 3.0

## Description

Exhaustion Fuel Gauge [AGPro Series]

🧠 Core Idea

Is the current move still powered by real participation, or is the trend running on exhausted fuel?


📌 Overview / What it does

Exhaustion Fuel Gauge [AGPro Series] is a premium TradingView overlay that evaluates trend fuel, participation strength, extension pressure, wick reaction, and momentum efficiency to map whether a directional move is still active, fading, or entering exhaustion territory.

The script produces a forward-projected fuel zone, compact state labels, current context tags, and an AGPro-style panel that summarizes the active gauge state. It is designed to help users read whether a move has enough internal fuel to continue or whether the chart is showing signs of weakening participation and exhaustion risk.

It does not predict price direction, automate trades, or provide guaranteed signals. It is a visual decision-support map for market context.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between simple momentum indicators and real chart context. Many tools show whether price is moving fast, but they do not clearly explain whether the move still has fuel or whether the movement is becoming fragile.

Exhaustion Fuel Gauge helps discretionary traders, swing traders, intraday traders, and market-structure readers evaluate the quality of a move before overreacting to a single candle.

The design philosophy is simple: trend continuation should be judged by fuel, participation, efficiency, and reaction quality together.


⚡ Why This Script Is Different

Most tools focus on overbought or oversold readings.

This script does NOT treat exhaustion as a single oscillator value or a generic reversal signal.

Instead, it combines directional persistence, participation strength, range behavior, move efficiency, wick pressure, and extension risk into a clean overlay that explains whether the current move still has usable fuel.


⚙️ Methodology

1. Context Detection

The script identifies the active directional context using recent price movement and trend baseline behavior.

2. Fuel Evaluation

It measures persistence, participation, range expansion, and efficiency to estimate how much usable fuel remains in the move.

3. Exhaustion Risk Mapping

It evaluates extension, fuel fade, wick pressure, and participation fade to estimate whether the move is becoming vulnerable.

4. Visual Output

The script displays a forward-projected fuel zone, event labels, right-side context tags, and a structured AGPro panel.


🗺️ How to Read the Chart

Zones represent the current fuel reference area where the active move should be evaluated.

Labels mark important changes such as fuel activation, fuel fading, exhaustion watch, exhaustion hit, or reset build.

Colors represent state context:

• Green = active fuel
• Pink = exhaustion risk or exhaustion hit
• Yellow = caution / watch state
• Indigo = fading or reset context

The panel summarizes the current gauge state, direction, fuel score, exhaustion risk, participation, extension, and next context.


🚦 Signals & States

• FUEL ACTIVE → directional move still has usable internal fuel

• FUEL FADING → move is still present, but internal support is weakening

• EXHAUSTION WATCH → extension and reaction pressure are elevated

• EXHAUSTION HIT → exhaustion evidence is strong and fuel has weakened

• RESET BUILD → no clean directional fuel is currently confirmed


🔔 Alerts Logic

Alerts trigger when the script detects a new fuel-active state, fuel-fading state, exhaustion-watch state, exhaustion-hit state, or reset-build state.

Alerts are attention markers only. They are not trade instructions and should not be interpreted as guaranteed outcomes.


🧩 Confluence Logic

The strongest exhaustion context appears when extension pressure, participation fade, wick reaction, and weak fuel score align.

The strongest continuation context appears when fuel score remains high while exhaustion risk stays contained.


📊 When to Use

• Trending markets where continuation quality matters

• Extended moves where exhaustion risk needs to be evaluated

• Breakout follow-through analysis

• Swing-trading context review

• Intraday movement quality checks


⚠️ When NOT to Use

• Extremely low-liquidity markets

• Randomly choppy symbols with poor structure

• News spikes where normal participation behavior is distorted

• Very low timeframes with excessive noise


🎛️ Key Inputs

• Trend Length → adjusts the baseline used to define directional context

• Fuel Lookback → controls how many bars are used for fuel evaluation

• Exhaustion Threshold → adjusts how strict exhaustion detection is

• Fuel Fade Threshold → defines when a move is considered fuel-fading

• Zone Projection Bars → keeps the active zone visible for publication screenshots

• Panel and label settings → control visual readability


🖥️ Interface & Visual Design

The interface is built for quick visual interpretation.

The panel provides structured context without dominating the chart. The fuel zone gives the main story visually, while compact labels and right-side tags provide the current state without clutter.

The goal is a premium, publication-ready TradingView chart.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether fuel is active, fading, or exhausted.

3. Observe the active fuel zone and current right-side tags.

4. Compare exhaustion risk with participation and extension.

5. Use broader market structure before making any decision.


🔍 Interpretation Guidelines

High fuel with low exhaustion risk suggests the move still has internal support.

High exhaustion risk with weak fuel suggests the move may be vulnerable to reaction or reset.

Fuel fading does not mean reversal. It means continuation quality is weakening.

Exhaustion hit does not guarantee a top or bottom. It marks a context that deserves caution.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It does not provide guaranteed buy or sell signals.

It does not replace risk management or independent analysis.


⚠️ Limitations & Transparency

The script is rule-based and depends on market conditions.

Different timeframes may produce different readings.

Volatility, liquidity, gaps, and news-driven moves may affect signal quality.

Outputs should always be interpreted with broader market context.


🧠 Market Context Notes

Exhaustion is not only about price distance.

It also depends on whether participation remains strong, whether candles still close efficiently, and whether wick pressure begins to appear against the current direction.

This script is designed to make those conditions easier to read visually.


🧾 Use Case Examples

When price extends strongly but fuel remains high and exhaustion risk is contained, the move may still have continuation quality.

When price extends while participation fades and wick pressure increases, the chart may be entering exhaustion-watch territory.

When exhaustion risk rises while fuel drops, the context becomes more fragile.


🧱 System Philosophy

AGPro Series tools are designed as professional visual maps, not signal machines.

The goal is to make complex market context easier to interpret without reducing it to a simplistic buy or sell label.


🔐 Non-Promise Statement

No script can guarantee future price movement.

This tool provides structured context, not certainty.


📉 Risk Disclosure

Trading involves risk.

Past behavior does not guarantee future results.

Users are responsible for their own decisions, position sizing, and risk management.

This script does not provide financial advice.


📚 Educational Note

Use this script as a learning and analysis tool to better understand momentum quality, trend fuel, and exhaustion behavior across different market conditions.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Exhaustion Fuel Gauge [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Exhaustion Fuel Gauge maps trend exhaustion, momentum fuel, participation fade,
// extension pressure, and wick reaction into a clean TradingView overlay.
// It is designed to show whether a directional move still has usable fuel,
// is fading, or has moved into exhaustion-watch territory. A cumulative
// Reaction Race engine measures, on this chart and timeframe, whether the
// one-ATR counter-reaction or one-ATR trend continuation tends to win the
// race after a confirmed exhaustion hit, and a clear next-action line turns
// the gauge into a decision tool. This release preserves the original model
// while tightening event anchoring, zone ownership, tag semantics, and alerts.
// ─────────────────────────────────────────────────

//@version=6
indicator("Exhaustion Fuel Gauge [AGPro Series]",
     shorttitle = "AGP EFG",
     overlay = true,
     max_labels_count = 120,
     max_boxes_count = 20,
     max_lines_count = 20)

// ─────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────
grpCore = "Core Logic"
trendLength = input.int(34, "Trend Length", minval = 10, maxval = 150, group = grpCore, tooltip = "Defines the medium-term trend baseline used to estimate directional fuel and extension.")
fuelLength = input.int(21, "Fuel Lookback", minval = 8, maxval = 80, group = grpCore, tooltip = "Controls how many bars are used to evaluate persistence, participation, range expansion, and move efficiency.")
exhaustionThreshold = input.float(68.0, "Exhaustion Threshold", minval = 45.0, maxval = 90.0, step = 1.0, group = grpCore, tooltip = "Higher values require stronger evidence before exhaustion watch or exhaustion hit states appear.")
fadeThreshold = input.float(43.0, "Fuel Fade Threshold", minval = 20.0, maxval = 70.0, step = 1.0, group = grpCore, tooltip = "Lower fuel readings below this level move the script into a fuel-fading state.")
eventCooldown = input.int(16, "Event Cooldown", minval = 3, maxval = 80, group = grpCore, tooltip = "Minimum bar spacing between historical event labels.")
reactTargetAtr = input.float(1.0, "Reaction Target ATR", minval = 0.25, maxval = 5.0, step = 0.25, group = grpCore, tooltip = "Distance, in ATR from the exhaustion-hit close, used on both sides of the Reaction Edge race. The episode is a hit when the counter-reaction reaches this distance before trend continuation does.")
reactWindow = input.int(30, "Reaction Window", minval = 5, maxval = 200, group = grpCore, tooltip = "Maximum number of bars a Reaction Edge episode may stay open. If neither side of the race reaches the target inside this window, the episode counts as a miss.")

grpVisual = "Visual Design"
showZone = input.bool(true, "Show Fuel Zone", group = grpVisual, tooltip = "Displays the active exhaustion/fuel reference zone with a centered label.")
showPanel = input.bool(true, "Show Panel", group = grpVisual, tooltip = "Shows or hides the AG Pro status panel. Enabled by default for publication screenshots.")
showEventLabels = input.bool(true, "Show Event Labels", group = grpVisual, tooltip = "Shows compact historical labels for fuel-active, fuel-fade, exhaustion-hit, and reset-build events. Two controlled ATR bands separate nearby events without detaching them from their candles.")
showRightTags = input.bool(true, "Show Right Tags", group = grpVisual, tooltip = "Shows current-state tags projected to the right side of the chart.")
showFuelTrail = input.bool(true, "Show Fuel Trail", group = grpVisual, tooltip = "Displays a lightweight trail line around the current trend fuel baseline.")
zoneLookback = input.int(45, "Zone Lookback", minval = 12, maxval = 160, group = grpVisual, tooltip = "Defines the recent visible range used to anchor the active fuel zone.")
zoneProjection = input.int(42, "Zone Projection Bars", minval = 12, maxval = 120, group = grpVisual, tooltip = "Projects the active zone forward so all zone edges remain visible in publication screenshots.")
visibleBars = input.int(95, "Visible Zone Width", minval = 35, maxval = 260, group = grpVisual, tooltip = "Controls how much recent chart history the active zone covers.")
labelLimit = input.int(9, "Historical Label Limit", minval = 4, maxval = 24, group = grpVisual, tooltip = "Limits historical labels to keep the chart premium and readable.")
rightTagGapAtr = input.float(1.5, "Right Tag Spacing ATR", minval = 0.5, maxval = 4.0, step = 0.1, group = grpVisual, tooltip = "Vertical ATR spacing between the three right-side tags. Increase if the tags overlap on your zoom level.")
panelPosition = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpVisual)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpVisual)
labelFontInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual)
panelFontInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual)

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBorderDark = color.rgb(51, 65, 85)
panelLabelDark = color.rgb(148, 163, 184)
panelValueDark = color.rgb(226, 232, 240)
panelBgLight = color.rgb(241, 245, 249)
panelBorderLight = color.rgb(148, 163, 184)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

labelSize = switch labelFontInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Large" => size.large
    => size.normal

panelSize = switch panelFontInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Large" => size.large
    => size.normal

panelPos = switch panelPosition
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

panelBg = panelTheme == "Dark" ? panelBgDark : panelBgLight
panelBorder = panelTheme == "Dark" ? panelBorderDark : panelBorderLight
panelLabelCol = panelTheme == "Dark" ? panelLabelDark : panelLabelLight
panelValueCol = panelTheme == "Dark" ? panelValueDark : panelValueLight

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────
f_clamp(value, minValue, maxValue) =>
    math.max(minValue, math.min(value, maxValue))

f_text_on(fillColor) =>
    brightness = 0.299 * color.r(fillColor) + 0.587 * color.g(fillColor) + 0.114 * color.b(fillColor)
    brightness > 145 ? color.rgb(17, 24, 39) : headerText

f_round(value) =>
    int(math.round(value))

f_fmt(value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_pct(value) =>
    na(value) ? "n/a" : str.tostring(math.round(value)) + "%"

f_dir_text(direction) =>
    direction > 0 ? "BULLISH" : direction < 0 ? "BEARISH" : "NEUTRAL"

f_set_box(boxRef, leftValue, rightValue, topValue, bottomValue, bg, border) =>
    box.set_left(boxRef, leftValue)
    box.set_right(boxRef, rightValue)
    box.set_top(boxRef, topValue)
    box.set_bottom(boxRef, bottomValue)
    box.set_bgcolor(boxRef, bg)
    box.set_border_color(boxRef, border)
    box.set_border_width(boxRef, 2)

f_set_line(lineRef, x1, y1, x2, y2, col, styleValue, widthValue) =>
    line.set_xy1(lineRef, x1, y1)
    line.set_xy2(lineRef, x2, y2)
    line.set_color(lineRef, col)
    line.set_style(lineRef, styleValue)
    line.set_width(lineRef, widthValue)

f_set_tag(tag, x, y, labelText, bg, styleValue, textSize) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, labelText)
    label.set_color(tag, bg)
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, textSize)

f_keep_label(store, newLabel, limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        oldLabel = array.shift(store)
        label.delete(oldLabel)

f_panel_cell(panelRef, col, row, txt, bg, txtColor, txtSize, alignValue) =>
    table.cell(panelRef, col, row, txt, bgcolor = bg, text_color = txtColor, text_size = txtSize, text_halign = alignValue)

// Reaction Race display helpers. The row reports both sides of the
// race: R = counter-reaction wins, T = trend-continuation wins
// (timeouts and same-bar ties resolve to neither side). Color is
// applied only once the sample is sufficient (n >= 8): green when the
// reaction side leads by 10 points or more (fading exhaustion is being
// rewarded), pink when the trend side leads by 10 or more (fading is
// being punished), neutral when the race is balanced.
f_rxText(int _r, int _t, int _n) =>
    _n > 0 ? "R " + str.tostring(math.round(100.0 * _r / _n)) + "% / T " + str.tostring(math.round(100.0 * _t / _n)) + "%  (n=" + str.tostring(_n) + ")" : "-  (n=0)"

f_rxColor(int _r, int _t, int _n, color _fb) =>
    _rp = _n > 0 ? math.round(100.0 * _r / _n) : 0
    _tp = _n > 0 ? math.round(100.0 * _t / _n) : 0
    _n >= 8 ? (_rp - _tp >= 10 ? bullColor : _tp - _rp >= 10 ? bearColor : neutralColor) : _fb

// ─────────────────────────────────────────────────
// Core Logic
// ─────────────────────────────────────────────────
atr = ta.atr(14)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

emaFast = ta.ema(close, trendLength)
emaSlow = ta.ema(close, trendLength * 2)
move = close - close[fuelLength]
moveDir = move > safeAtr * 0.22 ? 1 : move < -safeAtr * 0.22 ? -1 : emaFast > emaSlow ? 1 : emaFast < emaSlow ? -1 : 0

dirBar = moveDir > 0 ? close > close[1] : moveDir < 0 ? close < close[1] : false
persistence = f_clamp(math.sum(dirBar ? 1.0 : 0.0, fuelLength) / fuelLength * 100.0, 0.0, 100.0)
volBase = math.max(ta.sma(nz(volume, 1.0), fuelLength), 1.0)
participation = f_clamp(nz(volume, 1.0) / volBase * 50.0, 0.0, 100.0)
rangeBase = math.max(ta.sma(barRange, fuelLength), syminfo.mintick)
rangeExpansion = f_clamp(barRange / rangeBase * 50.0, 0.0, 100.0)
travel = math.max(math.sum(math.abs(ta.change(close)), fuelLength), syminfo.mintick)
efficiency = f_clamp(math.abs(move) / travel * 100.0, 0.0, 100.0)
fuelScore = f_clamp(persistence * 0.32 + participation * 0.24 + rangeExpansion * 0.18 + efficiency * 0.26, 0.0, 100.0)

extension = f_clamp(math.abs(close - emaSlow) / safeAtr * 18.0, 0.0, 100.0)
wickPressure = moveDir > 0 ? f_clamp(upperWick / barRange * 100.0, 0.0, 100.0) : moveDir < 0 ? f_clamp(lowerWick / barRange * 100.0, 0.0, 100.0) : 45.0
fuelFade = f_clamp(100.0 - fuelScore, 0.0, 100.0)
participationFade = participation < participation[1] ? f_clamp(participation[1] - participation + 22.0, 0.0, 100.0) : 0.0
exhaustionRisk = f_clamp(extension * 0.35 + fuelFade * 0.25 + wickPressure * 0.24 + participationFade * 0.16, 0.0, 100.0)

resetBuild = moveDir == 0
exhaustionHit = moveDir != 0 and exhaustionRisk >= exhaustionThreshold and fuelScore < 56.0
exhaustionWatch = moveDir != 0 and exhaustionRisk >= exhaustionThreshold and not exhaustionHit
fuelFading = moveDir != 0 and fuelScore < fadeThreshold and not exhaustionHit and not exhaustionWatch
fuelActive = moveDir != 0 and fuelScore >= fadeThreshold and not exhaustionHit and not exhaustionWatch

gaugeState = exhaustionHit ? "EXHAUSTION HIT" : exhaustionWatch ? "EXHAUSTION WATCH" : fuelFading ? "FUEL FADING" : fuelActive ? "FUEL ACTIVE" : "RESET BUILD"
stateColor = exhaustionHit ? bearColor : exhaustionWatch ? neutralColor : fuelFading ? accentColor : fuelActive ? bullColor : accentColor
stateTextColor = exhaustionHit ? bearColor : exhaustionWatch ? neutralColor : fuelFading ? accentColor : fuelActive ? bullColor : accentColor

fuelLeft = f_clamp(100.0 - exhaustionRisk * 0.45 + fuelScore * 0.45, 0.0, 100.0)

// State-change events (used by the proof engine, labels, and alerts)
newFuelActive = fuelActive and not (fuelActive[1] == true)
newFuelFading = fuelFading and not (fuelFading[1] == true)
newExhaustionWatch = exhaustionWatch and not (exhaustionWatch[1] == true)
newExhaustionHit = exhaustionHit and not (exhaustionHit[1] == true)
newResetBuild = resetBuild and not (resetBuild[1] == true)
eventCandidate = newFuelActive or newFuelFading or newExhaustionWatch or newExhaustionHit or newResetBuild

// ─────────────────────────────────────────────────
// REACTION RACE ENGINE (cumulative, non-repaint)
// Every confirmed exhaustion hit opens one tracking episode with the
// event close, ATR, and trend direction frozen at the event bar. The
// episode is a symmetric race between the one-ATR counter-reaction and
// one-ATR trend continuation. The panel reports both sides: how often
// the reaction won and how often continuation won. Timeouts and
// same-bar double touches (order unverifiable) resolve to neither
// side. In a random market the two sides settle near each other, so a
// clear lead on either side is genuine information: a reaction lead
// means fading exhaustion is being rewarded on this chart, a trend
// lead means it is being punished. Episodes open and resolve on
// confirmed bars only, so the statistic never repaints. All confirmed
// exhaustion hits are tracked, including those the label cooldown
// keeps off the chart.
// ─────────────────────────────────────────────────
var bool  rxOn = false
var int   rxTrendDir = 0
var float rxEntry = na
var float rxAtr = na
var int   rxStart = na
var int   rxWin = 0
var int   rxReactWins = 0
var int   rxTrendWins = 0
var int   rxN = 0

bool rxHitEv = false

if rxOn and barstate.isconfirmed
    bool counterTouch = rxTrendDir == 1 ? low <= rxEntry - rxAtr * reactTargetAtr : high >= rxEntry + rxAtr * reactTargetAtr
    bool trendTouch = rxTrendDir == 1 ? high >= rxEntry + rxAtr * reactTargetAtr : low <= rxEntry - rxAtr * reactTargetAtr
    bool rxTimeout = not na(rxStart) and bar_index - rxStart >= rxWin
    if counterTouch and not trendTouch
        rxN += 1
        rxReactWins += 1
        rxOn := false
        rxHitEv := true
    else if trendTouch and not counterTouch
        rxN += 1
        rxTrendWins += 1
        rxOn := false
    else if (counterTouch and trendTouch) or rxTimeout
        rxN += 1
        rxOn := false

if newExhaustionHit and barstate.isconfirmed and not na(atr) and atr > 0.0 and moveDir != 0
    if rxOn
        rxN += 1
        rxOn := false
    rxOn := true
    rxTrendDir := moveDir
    rxEntry := close
    rxAtr := atr
    rxStart := bar_index
    rxWin := reactWindow

// Next-action line, always consistent with the gauge state
string actionTxt = "> reset building - wait for direction"
if exhaustionHit
    actionTxt := "> exhaustion hit - watch the reaction"
else if exhaustionWatch
    actionTxt := "> exhaustion risk high - tighten risk"
else if fuelFading
    actionTxt := "> fuel fading - avoid fresh entries"
else if fuelActive
    actionTxt := "> fuel active - trend continuation ok"

// ─────────────────────────────────────────────────
// Visual Objects
// ─────────────────────────────────────────────────
var box fuelBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 88), border_color = accentColor)
var line fuelLine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var label zoneTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
var label fuelScoreTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
var label riskTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = labelSize)
var array<label> eventStore = array.new_label()

leftX = math.max(bar_index - visibleBars, 0)
rightX = bar_index + zoneProjection
recentHigh = ta.highest(high, zoneLookback)
recentLow = ta.lowest(low, zoneLookback)
recentMid = (recentHigh + recentLow) * 0.5
zoneCenter = moveDir > 0 ? math.max(emaFast, recentMid) : moveDir < 0 ? math.min(emaFast, recentMid) : recentMid
zoneHalf = math.max(safeAtr * 1.15, (recentHigh - recentLow) * 0.075)
zoneTop = zoneCenter + zoneHalf
zoneBottom = zoneCenter - zoneHalf
zoneMid = (zoneTop + zoneBottom) * 0.5
zoneLabelX = int(math.round((leftX + rightX) * 0.5))
rightTagX = rightX + 5
tagGap = safeAtr * rightTagGapAtr

if barstate.islast
    if showZone
        f_set_box(fuelBox, leftX, rightX, zoneTop, zoneBottom, color.new(stateColor, 86), stateColor)
        box.set_extend(fuelBox, extend.none)
        f_set_tag(zoneTag, zoneLabelX, zoneMid, "FUEL GAUGE | Q " + str.tostring(f_round(fuelScore)), stateColor, label.style_label_center, labelSize)
    else
        box.set_bgcolor(fuelBox, color.new(color.black, 100))
        box.set_border_color(fuelBox, color.new(color.black, 100))
        label.set_text(zoneTag, "")

    if showFuelTrail
        trailY = moveDir > 0 ? zoneTop : moveDir < 0 ? zoneBottom : zoneMid
        f_set_line(fuelLine, leftX, trailY, rightX, trailY, color.new(stateColor, 8), line.style_dotted, 2)
    else
        line.set_color(fuelLine, color.new(color.black, 100))

    if showRightTags
        fuelTagColor = fuelScore >= 60.0 ? bullColor : fuelScore < fadeThreshold ? accentColor : neutralColor
        riskTagColor = exhaustionRisk >= exhaustionThreshold ? bearColor : exhaustionRisk >= exhaustionThreshold * 0.75 ? neutralColor : accentColor
        f_set_tag(stateTag, rightTagX, zoneMid, gaugeState, stateColor, label.style_label_left, labelSize)
        f_set_tag(fuelScoreTag, rightTagX, zoneMid + tagGap, "FUEL " + str.tostring(f_round(fuelScore)) + "/100", fuelTagColor, label.style_label_left, labelSize)
        f_set_tag(riskTag, rightTagX, zoneMid - tagGap, "EXH RISK " + str.tostring(f_round(exhaustionRisk)) + "/100", riskTagColor, label.style_label_left, labelSize)
    else
        label.set_text(stateTag, "")
        label.set_text(fuelScoreTag, "")
        label.set_text(riskTag, "")

var int lastEventBar = na
var bool eventTall = false
canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= eventCooldown
if showEventLabels and eventCandidate and canPrintEvent and barstate.isconfirmed
    eventText = newExhaustionHit ? "EXHAUSTION HIT" : newExhaustionWatch ? "EXHAUSTION WATCH" : newFuelFading ? "FUEL FADE" : newFuelActive ? "FUEL ACTIVE" : "RESET BUILD"
    eventCol = newExhaustionHit ? bearColor : newExhaustionWatch ? neutralColor : newFuelFading ? accentColor : newFuelActive ? bullColor : accentColor
    eventStyle = moveDir >= 0 ? label.style_label_down : label.style_label_up
    // Alternate between two vertical bands so consecutive labels never
    // stack on the same level when price is moving sideways.
    float eventOffsetMult = eventTall ? 1.35 : 0.85
    eventTall := not eventTall
    eventY = moveDir >= 0 ? high + safeAtr * eventOffsetMult : low - safeAtr * eventOffsetMult
    eventLabel = label.new(bar_index, eventY, eventText + " | Q " + str.tostring(f_round(exhaustionHit or exhaustionWatch ? exhaustionRisk : fuelScore)), xloc = xloc.bar_index, style = eventStyle, color = eventCol, textcolor = f_text_on(eventCol), size = labelSize)
    f_keep_label(eventStore, eventLabel, labelLimit)
    lastEventBar := bar_index

// ─────────────────────────────────────────────────
// Panel
// ─────────────────────────────────────────────────
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPosition or panelThemeMemory != panelTheme)
    if not na(panel)
        table.delete(panel)
    panel := table.new(panelPos, 2, 10, border_color = panelBorder, frame_color = panelBorder, frame_width = 1, border_width = 1)
    f_panel_cell(panel, 0, 0, "AG Pro Exhaustion Fuel Gauge", headerBg, headerText, panelSize, text.align_center)
    f_panel_cell(panel, 1, 0, "", headerBg, headerText, panelSize, text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.merge_cells(panel, 0, 7, 1, 7)
    table.merge_cells(panel, 0, 9, 1, 9)
    panelPosMemory := panelPosition
    panelThemeMemory := panelTheme

if showPanel and not na(panel) and barstate.islast
    f_panel_cell(panel, 0, 1, "Gauge State", panelBg, panelLabelCol, panelSize, text.align_center)
    f_panel_cell(panel, 1, 1, gaugeState, panelBg, stateTextColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 2, "Direction", panelBg, panelLabelCol, panelSize, text.align_center)
    f_panel_cell(panel, 1, 2, f_dir_text(moveDir), panelBg, moveDir > 0 ? bullColor : moveDir < 0 ? bearColor : neutralColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 3, "Fuel Score", panelBg, panelLabelCol, panelSize, text.align_center)
    f_panel_cell(panel, 1, 3, str.tostring(f_round(fuelScore)), panelBg, panelValueCol, panelSize, text.align_center)
    f_panel_cell(panel, 0, 4, "Exhaustion Risk", panelBg, panelLabelCol, panelSize, text.align_center)
    f_panel_cell(panel, 1, 4, str.tostring(f_round(exhaustionRisk)), panelBg, exhaustionRisk >= exhaustionThreshold ? bearColor : panelValueCol, panelSize, text.align_center)
    f_panel_cell(panel, 0, 5, "Participation", panelBg, panelLabelCol, panelSize, text.align_center)
    f_panel_cell(panel, 1, 5, str.tostring(f_round(participation)), panelBg, panelValueCol, panelSize, text.align_center)
    f_panel_cell(panel, 0, 6, "Extension", panelBg, panelLabelCol, panelSize, text.align_center)
    f_panel_cell(panel, 1, 6, str.tostring(f_round(extension)), panelBg, panelValueCol, panelSize, text.align_center)
    f_panel_cell(panel, 0, 7, "-- EXHAUSTION PROOF --", panelBg, accentColor, panelSize, text.align_center)
    f_panel_cell(panel, 0, 8, "Reaction Race", panelBg, panelLabelCol, panelSize, text.align_center)
    f_panel_cell(panel, 1, 8, f_rxText(rxReactWins, rxTrendWins, rxN), panelBg, f_rxColor(rxReactWins, rxTrendWins, rxN, panelLabelCol), panelSize, text.align_center)
    f_panel_cell(panel, 0, 9, actionTxt, panelBg, accentColor, panelSize, text.align_left)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// ─────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────
fuelActiveAlert = barstate.isconfirmed and newFuelActive
fuelFadingAlert = barstate.isconfirmed and newFuelFading
exhaustionWatchAlert = barstate.isconfirmed and newExhaustionWatch
exhaustionHitAlert = barstate.isconfirmed and newExhaustionHit
resetBuildAlert = barstate.isconfirmed and newResetBuild

alertcondition(fuelActiveAlert, "Fuel Active", "Exhaustion Fuel Gauge: trend fuel is active.")
alertcondition(fuelFadingAlert, "Fuel Fading", "Exhaustion Fuel Gauge: trend fuel is fading.")
alertcondition(exhaustionWatchAlert, "Exhaustion Watch", "Exhaustion Fuel Gauge: exhaustion watch is active.")
alertcondition(exhaustionHitAlert, "Exhaustion Hit", "Exhaustion Fuel Gauge: exhaustion hit detected.")
alertcondition(resetBuildAlert, "Reset Build", "Exhaustion Fuel Gauge: reset build state detected.")
alertcondition(rxHitEv, "Reaction Race Won", "Exhaustion Fuel Gauge: the counter-reaction won the race after a confirmed exhaustion hit.")
````
