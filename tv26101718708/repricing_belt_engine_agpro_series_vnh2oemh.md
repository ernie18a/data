# Repricing Belt Engine [AGPro Series]

- url: https://www.tradingview.com/script/Vnh2OeMh-Repricing-Belt-Engine-AGPro-Series/
- type: indicator
- pine_id: PUB;d7d8a83f135f4d5d85b86d5a961b13d4
- version: 5.0

## Description

Repricing Belt Engine [AGPro Series]

🔹 OVERVIEW

Repricing Belt Engine identifies qualifying displacement impulses and constructs ATR-scaled repricing belts around the impulse body, then tracks each belt's first-revisit lifecycle through three discrete outcomes: Held, Rejected, and Broken. The engine turns raw impulse candles into structured, evaluable reaction zones — giving traders a clean framework for studying how price behaves when it returns to the scene of a decisive move.

Unlike generic supply/demand or order block tools, this indicator does not simply mark impulse zones and leave them on the chart indefinitely. Every belt has a full state machine: Active → first qualifying touch → terminal outcome. A top-right status panel summarizes active belts, current belt context, 50-bar directional bias, and outcome counts so the chart context is always one glance away.


🔸 UNIQUE EDGE

Most displacement or supply/demand indicators stop at drawing a box. Repricing Belt Engine differentiates itself with four specific mechanics:

• ATR-scaled geometry — Belt width is normalized by ATR (not raw body size), producing consistently visible zones across volatility regimes and symbols. Optional "Auto (Body)" and "Body 70%" modes are available for traders who prefer tighter constructions.

• Three-outcome lifecycle model — Every belt resolves into one of five states (Active, Held, Rejected, Broken, Expired) based on penetration depth and close position. No more static zones cluttering the chart after price has decisively moved on.

• Depth-gated touch qualification — Wick-grazing does not trigger state transitions. A revisit must penetrate the belt by a configurable minimum depth (ATR-relative) before it counts, filtering noise from meaningful reactions.

• Excursion-tolerant hold detection — A belt can be marked Held even when price briefly dips beyond it, as long as the close respects the belt and the excursion stays within the Hold Tolerance band. This matches how institutional levels actually react in live markets.


🔹 METHODOLOGY

1. Impulse Qualification: A bar qualifies as an impulse when its body magnitude exceeds Impulse Threshold × ATR AND its body-to-range ratio is at least Min Body / Range Ratio. Both gates must pass — this filters out long-wick bars that look decisive but are not.

2. Belt Construction: On a qualifying impulse, a belt is drawn using the selected Width Mode. In ATR Scaled mode (default), the belt is centered on the impulse body midpoint and spans ±ATR Width Half-Span × ATR. A mid-line is drawn through the belt center.

3. Cooldown: A minimum bar gap (Cooldown Between Belts) is enforced between consecutive belt formations, preventing rapid clustering in extended trends.

4. Lifecycle Tracking: On every confirmed close, each active belt is evaluated:
   • If close breaches the belt with excursion beyond Reject Tolerance → Broken
   • If close recovers but excursion exceeded Hold Tolerance → Rejected
   • If close respects the belt after a qualifying touch → Held
   • If no resolution within Belt Max Lifetime bars → Expired

5. Active Cap: A maximum number of concurrent active belts is enforced (Max Active Belts). When the cap is reached, the oldest active belt is auto-expired to keep the chart focused on the current narrative.


🔸 SIGNALS & ALERTS

On-chart visuals:
• Bull/Bear belt zones with ATR-scaled width and mid-line
• Impulse origin markers (small triangles) anchoring each belt to its source bar
• State-colored labels at resolution: Held OK (state color), Broken X (opposite state color), Rejected (neutral, shown only in Detailed label mode)
• Faded rendering for resolved belts so the active story stays visually dominant

Top-right status panel:
• Active belt count
• Current belt context (side, position, held flag)
• 50-bar directional bias (Bull UP / Bear DN / Neutral)
• 50-bar outcome counts (Held / Rejected / Broken)

Alert conditions:
• Repricing Belt Formed
• Belt Touched (first qualifying revisit)
• Belt Held
• Belt Rejected
• Belt Broken


🔹 KEY INPUTS

Engine
• Impulse Threshold (x ATR) — impulse size gate [default 1.8]
• Min Body / Range Ratio — decisive-close gate [default 0.60]
• ATR Length — volatility normalization period [default 14]
• Cooldown Between Belts — anti-clustering filter [default 6]

Belt
• Width Mode — ATR Scaled / Auto (Body) / Body 70% [default ATR Scaled]
• ATR Width Half-Span — belt half-width in ATR units [default 0.35]
• Belt Max Lifetime — auto-expiry age [default 150]
• Max Active Belts — concurrent belt cap [default 2]

State Thresholds
• Min Touch Depth (x ATR) — qualifying penetration [default 0.15]
• Hold Tolerance (x ATR) — clean-hold excursion ceiling [default 0.20]
• Reject Tolerance (x ATR) — rejected-vs-broken threshold [default 0.50]

Visuals
• Label Mode — Clean / Detailed
• Panel Font Size, Label Font Size
• Show Impulse Markers toggle


🔸 HOW TO USE

1. Apply to any symbol and timeframe. The engine is timeframe-agnostic and self-calibrates via ATR.
2. Watch for new belt formations on displacement impulses. The impulse marker confirms the origin bar.
3. When price returns, observe the lifecycle resolution: Held reactions often mark continuation points; Broken reactions frequently signal structural shifts.
4. Use the 50-bar Bias readout for directional context — sustained one-sided belt formation suggests an active trend.
5. Combine with structure tools (swing highs/lows, trendlines) for confluence. The belt is a reaction zone, not a standalone entry system.
6. Tune Impulse Threshold per timeframe: lower values (1.5–1.7) for intraday, higher (1.8–2.2) for swing.


🔹 LIMITATIONS & TRANSPARENCY

• This indicator is not a strategy and does not generate buy/sell signals. It is an analytical visualization tool.
• Belt outcomes are historical observations, not predictions. Past Held/Broken patterns do not guarantee future reactions.
• Performance varies by symbol, timeframe, and market regime. Always test parameter settings on the instruments you trade.
• Very low-liquidity or gappy symbols may produce noisy impulses. Increase Impulse Threshold or Min Body Ratio for cleaner selection.
• The Max Active Belts cap intentionally limits chart information to keep focus on the current context — raise it only if your workflow benefits from longer belt history.


⚠️ RISK DISCLOSURE

This script is provided for educational and analytical purposes only. It is not financial advice and does not constitute a recommendation to buy, sell, or hold any asset. Trading involves substantial risk of loss. Always conduct your own analysis, manage risk responsibly, and never trade with capital you cannot afford to lose. Past performance of any pattern or setup is not indicative of future results.

Published as Public / Open-source under Mozilla Public License 2.0.

## Source Code

````pine
// -------------------------------------------------
// Repricing Belt Engine [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.6
//
// Detects repricing belts formed after qualifying displacement impulses and
// tracks their first-revisit lifecycle across Active, Held, Rejected, Broken,
// and Expired states. Belts are rendered as ATR-scaled zones anchored to the
// impulse body, with centered zone labels, right-edge context, recent outcome
// stats, a lifetime hold rate that proves how often belts held on first
// revisit, and a compact panel for post-impulse reaction analysis. It is an
// analytical visualization tool, not a prediction engine, not an automated
// strategy, and not financial advice.
// -------------------------------------------------

//@version=6
indicator("Repricing Belt Engine [AGPro Series]",
     shorttitle       = "AG Pro RBE",
     overlay          = true,
     max_boxes_count  = 220,
     max_lines_count  = 220,
     max_labels_count = 260,
     max_bars_back    = 600)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpEngine = "Engine"
impulseMult = input.float(1.8, "Impulse Threshold (x ATR)", minval = 0.5, maxval = 5.0, step = 0.1, group = grpEngine,
     tooltip = "Minimum displacement magnitude required to qualify a bar as an impulse, expressed as a multiple of ATR. Higher values create fewer but stronger repricing belts.")
minBodyRatio = input.float(0.60, "Minimum Body / Range Ratio", minval = 0.3, maxval = 0.95, step = 0.05, group = grpEngine,
     tooltip = "Minimum candle body ratio required for an impulse. This filters weak displacement bars with large opposing wicks.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 50, group = grpEngine,
     tooltip = "ATR period used for impulse qualification, belt width, touch depth, and lifecycle tolerances.")
cooldownBars = input.int(6, "Cooldown Between Belts", minval = 0, maxval = 50, group = grpEngine,
     tooltip = "Minimum bars between new belt formations. This prevents rapid zone stacking during extended displacement runs.")

grpBelt = "Belt Construction"
widthMode = input.string("ATR Scaled", "Width Mode", options = ["Auto Body", "ATR Scaled", "Body 70%"], group = grpBelt,
     tooltip = "Controls how belt thickness is built. ATR Scaled creates consistent zones across symbols, Auto Body uses the impulse body, and Body 70% focuses on the inner body.")
beltATRMult = input.float(0.35, "ATR Width Half-Span", minval = 0.1, maxval = 1.5, step = 0.05, group = grpBelt,
     tooltip = "Half-span of the belt when Width Mode is ATR Scaled. The zone extends this many ATR units above and below the impulse body midpoint.")
maxBars = input.int(150, "Belt Max Lifetime", minval = 20, maxval = 500, group = grpBelt,
     tooltip = "Maximum age in bars before an unresolved belt is marked Expired.")
maxActive = input.int(3, "Max Active Belts", minval = 1, maxval = 5, group = grpBelt,
     tooltip = "Maximum active or held belts displayed at the same time. Oldest active belts are faded when the cap is reached.")

grpState = "State Thresholds"
minTouchDepth = input.float(0.15, "Minimum Touch Depth (x ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = grpState,
     tooltip = "Minimum penetration into the belt before a revisit qualifies. This avoids treating wick grazing as a real reaction.")
holdTol = input.float(0.20, "Hold Tolerance (x ATR)", minval = 0.0, maxval = 1.0, step = 0.05, group = grpState,
     tooltip = "Maximum excursion beyond the belt that can still qualify as a Held reaction.")
rejectTol = input.float(0.50, "Reject Tolerance (x ATR)", minval = 0.1, maxval = 2.0, step = 0.05, group = grpState,
     tooltip = "Excursions above Hold Tolerance and within this threshold can qualify as Rejected when price recovers to the correct side.")

grpVisual = "Visuals"
showBelts = input.bool(true, "Show Belts", group = grpVisual,
     tooltip = "Displays repricing belt zones and their center lines.")
showZoneLabels = input.bool(true, "Show Belt Labels", group = grpVisual,
     tooltip = "Places a compact label at the right edge of each active belt zone.")
showEventLabels = input.bool(true, "Show Event Labels", group = grpVisual,
     tooltip = "Shows outcome labels for Held, Rejected, Broken, and Expired events. Label density controls how many are kept visible.")
showLiveTag = input.bool(true, "Show Live Belt Tag", group = grpVisual,
     tooltip = "Shows a live right-edge tag for current repricing context and reaction quality.")
showImpulseMarkers = input.bool(true, "Show Impulse Markers", group = grpVisual,
     tooltip = "Shows small markers on bars that create new repricing belts.")
labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = grpVisual,
     tooltip = "Controls the amount of historical event annotation. Balanced is designed for clean public screenshots with enough context.")
projectionBars = input.int(28, "Right Projection Bars", minval = 8, maxval = 90, group = grpVisual,
     tooltip = "How far active belt boxes and right-edge labels extend beyond the latest bar.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual,
     tooltip = "Controls on-chart label size.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel,
     tooltip = "Shows the compact panel with current belt context, action state, reaction score, lifetime hold rate, bias, active belts, and recent outcome counts.")
panelPosition = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpPanel,
     tooltip = "Controls where the panel is anchored on the chart.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel,
     tooltip = "Switches panel colors for dark or light chart backgrounds.")
panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel,
     tooltip = "Controls panel text size.")

grpAlerts = "Alerts"
enableAlerts = input.bool(true, "Enable Alerts", group = grpAlerts,
     tooltip = "Master toggle for new belt, revisit, held, rejected, broken, and expired alert conditions.")

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgLight = color.rgb(248, 250, 252)
panelBorderD = color.rgb(51, 65, 85)
panelBorderL = color.rgb(203, 213, 225)
panelLabelD = color.rgb(148, 163, 184)
panelLabelL = color.rgb(71, 85, 105)
panelValueD = color.rgb(226, 232, 240)
panelValueL = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

isLightTheme = panelTheme == "Light"
panelBg = isLightTheme ? panelBgLight : panelBgDark
panelBorder = isLightTheme ? panelBorderL : panelBorderD
panelLabelCol = isLightTheme ? panelLabelL : panelLabelD
panelValueCol = isLightTheme ? panelValueL : panelValueD
panelAltBg = isLightTheme ? color.rgb(226, 232, 240) : color.rgb(30, 41, 59)
darkText = color.rgb(17, 24, 39)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
STATE_ACTIVE = 0
STATE_HELD = 1
STATE_REJECTED = 2
STATE_BROKEN = 3
STATE_EXPIRED = 4

f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(p) =>
    switch p
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_text_on(_bg) =>
    brightness = color.r(_bg) + color.g(_bg) + color.b(_bg)
    brightness >= 360 ? color.rgb(15, 23, 42) : color.white

f_state_text(st) =>
    st == STATE_ACTIVE ? "Active" :
     st == STATE_HELD ? "Held" :
     st == STATE_REJECTED ? "Rejected" :
     st == STATE_BROKEN ? "Broken" :
     "Expired"

f_state_slug(st) =>
    st == STATE_ACTIVE ? "Active" :
     st == STATE_HELD ? "Held" :
     st == STATE_REJECTED ? "Rejected" :
     st == STATE_BROKEN ? "Broken" :
     "Expired"

f_state_color(st, dir) =>
    st == STATE_ACTIVE ? (dir == 1 ? bullColor : bearColor) :
     st == STATE_HELD ? (dir == 1 ? bullColor : bearColor) :
     st == STATE_REJECTED ? neutralColor :
     st == STATE_BROKEN ? accentColor :
     panelLabelCol

f_action_text(st, score) =>
    st == STATE_HELD and score >= 70 ? "MONITOR" :
     st == STATE_ACTIVE ? "READY" :
     st == STATE_REJECTED ? "WAIT" :
     st == STATE_BROKEN ? "INVALIDATED" :
     "EXPIRED"

f_action_color(action) =>
    action == "MONITOR" ? bullColor :
     action == "READY" ? neutralColor :
     action == "INVALIDATED" ? bearColor :
     action == "EXPIRED" ? panelLabelCol :
     neutralColor

f_clamp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

f_price(v) =>
    str.tostring(v, format.mintick)

panelSize = f_size(panelSizeInput)
labelSize = f_size(labelSizeInput)
maxEventLabels = labelDensity == "Detailed" ? 22 : labelDensity == "Balanced" ? 12 : 7

// -------------------------------------------------
// Core Signals
// -------------------------------------------------
atr = ta.atr(atrLen)
body = math.abs(close - open)
rng = math.max(high - low, syminfo.mintick)
bodyRatio = body / rng

impulseOK = atr > 0.0 and body >= impulseMult * atr and bodyRatio >= minBodyRatio
bullImpulse = impulseOK and close > open
bearImpulse = impulseOK and close < open

// -------------------------------------------------
// Belt Storage
// -------------------------------------------------
var array<box> beltBox = array.new<box>()
var array<line> beltMid = array.new<line>()
var array<float> beltTop = array.new<float>()
var array<float> beltBot = array.new<float>()
var array<int> beltDir = array.new<int>()
var array<int> beltStart = array.new<int>()
var array<int> beltState = array.new<int>()
var array<bool> beltTouch = array.new<bool>()
var array<label> beltCenterLbl = array.new<label>()
var array<label> beltEventLbl = array.new<label>()
var array<label> eventLabels = array.new<label>()
var label liveTag = na
var line liveConnector = na

var int lastFormedBar = -10000

// Lifetime first-revisit outcome counters (Hold Rate proof)
var int beltHeldCount = 0
var int beltRejCount = 0
var int beltBrokCount = 0

// -------------------------------------------------
// Belt Geometry And Object Helpers
// -------------------------------------------------
f_belt_bounds() =>
    mid = (open + close) / 2.0
    bodyTop = math.max(open, close)
    bodyBot = math.min(open, close)
    top = bodyTop
    bot = bodyBot
    if widthMode == "ATR Scaled"
        top := mid + atr * beltATRMult
        bot := mid - atr * beltATRMult
    else if widthMode == "Body 70%"
        half = (bodyTop - bodyBot) * 0.35
        top := mid + half
        bot := mid - half
    [top, bot]

f_count_active() =>
    c = 0
    n = array.size(beltState)
    if n > 0
        for i = 0 to n - 1
            st = array.get(beltState, i)
            if st == STATE_ACTIVE or st == STATE_HELD
                c += 1
    c

f_state_count(stWanted, lookbackBars) =>
    c = 0
    n = array.size(beltState)
    if n > 0
        for i = 0 to n - 1
            if array.get(beltState, i) == stWanted and bar_index - array.get(beltStart, i) <= lookbackBars
                c += 1
    c

f_keep_event_label(lb) =>
    array.push(eventLabels, lb)
    while array.size(eventLabels) > maxEventLabels
        old = array.shift(eventLabels)
        if not na(old)
            label.delete(old)

f_retire_belt(idx) =>
    bx = array.get(beltBox, idx)
    ln = array.get(beltMid, idx)
    centerLbl = array.get(beltCenterLbl, idx)
    box.delete(bx)
    line.delete(ln)
    if not na(centerLbl)
        label.delete(centerLbl)
        array.set(beltCenterLbl, idx, label(na))

f_close_oldest_active() =>
    idx = -1
    n = array.size(beltState)
    if n > 0
        for i = 0 to n - 1
            st = array.get(beltState, i)
            if (st == STATE_ACTIVE or st == STATE_HELD) and idx < 0
                idx := i
    if idx >= 0
        array.set(beltState, idx, STATE_EXPIRED)
        f_retire_belt(idx)

// -------------------------------------------------
// New Belt Formation
// -------------------------------------------------
newBeltFormed = false
newBeltDir = 0

if (bullImpulse or bearImpulse) and (bar_index - lastFormedBar) >= cooldownBars and barstate.isconfirmed
    dir = bullImpulse ? 1 : -1
    [top, bot] = f_belt_bounds()
    while f_count_active() >= maxActive
        f_close_oldest_active()
    base = dir == 1 ? bullColor : bearColor
    fillCol = showBelts ? color.new(base, 78) : color.new(base, 100)
    edgeCol = showBelts ? color.new(base, 22) : color.new(base, 100)
    lineCol = showBelts ? color.new(base, 32) : color.new(base, 100)
    bx = box.new(bar_index, top, bar_index + projectionBars, bot, xloc = xloc.bar_index, border_color = edgeCol, border_width = 1, bgcolor = fillCol, extend = extend.none)
    ln = line.new(bar_index, (top + bot) / 2.0, bar_index + projectionBars, (top + bot) / 2.0, xloc = xloc.bar_index, color = lineCol, width = 2, style = line.style_solid, extend = extend.none)
    array.push(beltBox, bx)
    array.push(beltMid, ln)
    array.push(beltTop, top)
    array.push(beltBot, bot)
    array.push(beltDir, dir)
    array.push(beltStart, bar_index)
    array.push(beltState, STATE_ACTIVE)
    array.push(beltTouch, false)
    array.push(beltCenterLbl, label(na))
    array.push(beltEventLbl, label(na))
    lastFormedBar := bar_index
    newBeltFormed := true
    newBeltDir := dir

// -------------------------------------------------
// Lifecycle Update
// -------------------------------------------------
justHeldIdx = -1
justRejectedIdx = -1
justBrokenIdx = -1
justExpiredIdx = -1
touchedThisBar = false

if array.size(beltState) > 0
    for i = 0 to array.size(beltState) - 1
        st = array.get(beltState, i)
        if st == STATE_REJECTED or st == STATE_BROKEN or st == STATE_EXPIRED
            continue
        top = array.get(beltTop, i)
        bot = array.get(beltBot, i)
        dir = array.get(beltDir, i)
        born = array.get(beltStart, i)
        wasTouched = array.get(beltTouch, i)
        bx = array.get(beltBox, i)
        ln = array.get(beltMid, i)
        base = dir == 1 ? bullColor : bearColor
        if showBelts
            box.set_right(bx, bar_index + projectionBars)
            line.set_x2(ln, bar_index + projectionBars)
            box.set_bgcolor(bx, color.new(base, st == STATE_HELD ? 84 : 78))
            box.set_border_color(bx, color.new(base, st == STATE_HELD ? 35 : 22))
            line.set_color(ln, color.new(base, st == STATE_HELD ? 48 : 32))
        else
            box.set_bgcolor(bx, color.new(base, 100))
            box.set_border_color(bx, color.new(base, 100))
            line.set_color(ln, color.new(base, 100))
        if bar_index <= born
            continue
        if bar_index - born > maxBars
            array.set(beltState, i, STATE_EXPIRED)
            justExpiredIdx := i
            f_retire_belt(i)
            continue
        depthInto = math.max(0.0, math.min(top, high) - math.max(bot, low))
        excursion = dir == 1 ? math.max(0.0, bot - low) : math.max(0.0, high - top)
        minDepth = math.max(minTouchDepth * atr, (top - bot) * 0.25)
        qualifies = depthInto >= minDepth or excursion > holdTol * atr
        if qualifies and not wasTouched
            array.set(beltTouch, i, true)
            wasTouched := true
            touchedThisBar := true
        closeBack = (dir == 1 and close >= bot) or (dir == -1 and close <= top)
        closeAwry = (dir == 1 and close < bot) or (dir == -1 and close > top)
        if wasTouched and barstate.isconfirmed
            if closeAwry and excursion > rejectTol * atr and (st == STATE_ACTIVE or st == STATE_HELD)
                array.set(beltState, i, STATE_BROKEN)
                justBrokenIdx := i
                if st == STATE_ACTIVE
                    beltBrokCount += 1
                f_retire_belt(i)
            else if closeBack and excursion > holdTol * atr and excursion <= rejectTol * atr and (st == STATE_ACTIVE or st == STATE_HELD)
                array.set(beltState, i, STATE_REJECTED)
                justRejectedIdx := i
                if st == STATE_ACTIVE
                    beltRejCount += 1
                f_retire_belt(i)
            else if closeBack and depthInto >= minDepth and excursion <= holdTol * atr and st == STATE_ACTIVE
                array.set(beltState, i, STATE_HELD)
                justHeldIdx := i
                beltHeldCount += 1

// -------------------------------------------------
// Hold-rate proof (Confirm Rate)
// -------------------------------------------------
reactionTotal = beltHeldCount + beltRejCount + beltBrokCount
holdRate = reactionTotal > 0 ? beltHeldCount / reactionTotal * 100.0 : na

// -------------------------------------------------
// Belt Labels And Live Visuals
// -------------------------------------------------
f_center_label_text(idx) =>
    dir = array.get(beltDir, idx)
    st = array.get(beltState, idx)
    side = dir == 1 ? "Bull Belt" : "Bear Belt"
    side + " | " + f_state_slug(st)

f_event_label(idx, txt, bg, txtColor, above) =>
    top = array.get(beltTop, idx)
    bot = array.get(beltBot, idx)
    y = above ? top + atr * 0.72 : bot - atr * 0.72
    old = array.get(beltEventLbl, idx)
    if not na(old)
        label.delete(old)
    lb = label.new(bar_index + 2, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = above ? label.style_label_down : label.style_label_up, color = color.new(bg, 4), textcolor = txtColor, size = labelSize)
    array.set(beltEventLbl, idx, lb)
    f_keep_event_label(lb)

if array.size(beltState) > 0 and barstate.islast
    for i = 0 to array.size(beltState) - 1
        top = array.get(beltTop, i)
        bot = array.get(beltBot, i)
        dir = array.get(beltDir, i)
        st = array.get(beltState, i)
        born = array.get(beltStart, i)
        oldCenter = array.get(beltCenterLbl, i)
        activeLike = st == STATE_ACTIVE or st == STATE_HELD
        if showZoneLabels and showBelts and activeLike
            rightEdge = bar_index + projectionBars
            badgeX = born + int(math.round((rightEdge - born) * 0.5))
            centerY = (top + bot) / 2.0
            stColor = f_state_color(st, dir)
            bg = color.new(stColor, 8)
            txtCol = f_text_on(stColor)
            if na(oldCenter)
                newCenter = label.new(badgeX, centerY, f_center_label_text(i), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = bg, textcolor = txtCol, size = labelSize, textalign = text.align_center)
                array.set(beltCenterLbl, i, newCenter)
            else
                label.set_xy(oldCenter, badgeX, centerY)
                label.set_text(oldCenter, f_center_label_text(i))
                label.set_color(oldCenter, bg)
                label.set_textcolor(oldCenter, txtCol)
                label.set_size(oldCenter, labelSize)
                label.set_style(oldCenter, label.style_label_center)
        else if not na(oldCenter)
            label.delete(oldCenter)
            array.set(beltCenterLbl, i, label(na))

if showEventLabels
    if justHeldIdx >= 0
        bg = f_state_color(STATE_HELD, array.get(beltDir, justHeldIdx))
        f_event_label(justHeldIdx, "Held", bg, f_text_on(bg), array.get(beltDir, justHeldIdx) == 1)
    if justRejectedIdx >= 0 and labelDensity != "Minimal"
        f_event_label(justRejectedIdx, "Rejected", neutralColor, f_text_on(neutralColor), array.get(beltDir, justRejectedIdx) == 1)
    if justBrokenIdx >= 0
        f_event_label(justBrokenIdx, "Broken", accentColor, f_text_on(accentColor), array.get(beltDir, justBrokenIdx) == -1)
    if justExpiredIdx >= 0 and labelDensity == "Detailed"
        f_event_label(justExpiredIdx, "Expired", panelLabelCol, f_text_on(panelLabelCol), array.get(beltDir, justExpiredIdx) == 1)

// -------------------------------------------------
// Current Context
// -------------------------------------------------
currentIdx = -1
if array.size(beltState) > 0
    scan = array.size(beltState) - 1
    while scan >= 0 and currentIdx < 0
        st = array.get(beltState, scan)
        if st == STATE_ACTIVE or st == STATE_HELD
            currentIdx := scan
        scan -= 1

currentState = currentIdx >= 0 ? array.get(beltState, currentIdx) : STATE_EXPIRED
currentDir = currentIdx >= 0 ? array.get(beltDir, currentIdx) : 0
currentTop = currentIdx >= 0 ? array.get(beltTop, currentIdx) : na
currentBot = currentIdx >= 0 ? array.get(beltBot, currentIdx) : na
currentAge = currentIdx >= 0 ? bar_index - array.get(beltStart, currentIdx) : 0
currentMid = currentIdx >= 0 ? (currentTop + currentBot) / 2.0 : close
insideCurrent = currentIdx >= 0 and close >= currentBot and close <= currentTop
distanceAtr = currentIdx >= 0 and atr > 0.0 ? math.abs(close - currentMid) / atr : 9.0
stateScore = currentState == STATE_HELD ? 1.0 : currentState == STATE_ACTIVE ? 0.72 : 0.20
locationScore = insideCurrent ? 1.0 : f_clamp(1.0 - distanceAtr / 3.0, 0.0, 1.0)
ageScore = currentIdx >= 0 ? f_clamp(1.0 - currentAge / math.max(maxBars, 1), 0.0, 1.0) : 0.0
reactionScore = int(math.round((stateScore * 0.46 + locationScore * 0.34 + ageScore * 0.20) * 100.0))
actionText = f_action_text(currentState, reactionScore)
actionColor = f_action_color(actionText)

heldRecent = f_state_count(STATE_HELD, 50)
rejectedRecent = f_state_count(STATE_REJECTED, 50)
brokenRecent = f_state_count(STATE_BROKEN, 50)
activeCount = f_count_active()
biasText = heldRecent > brokenRecent ? "Bullish Hold" : brokenRecent > heldRecent ? "Belt Risk" : activeCount > 0 ? "Watching" : "Neutral"
biasColor = heldRecent > brokenRecent ? bullColor : brokenRecent > heldRecent ? bearColor : neutralColor

if showLiveTag and showBelts and currentIdx >= 0 and barstate.islast
    liveAnchorX = bar_index + projectionBars
    liveX = liveAnchorX + 8
    liveLane = atr * (labelSizeInput == "Large" ? 1.05 : labelSizeInput == "Normal" ? 0.85 : labelSizeInput == "Small" ? 0.70 : 0.58)
    liveY = currentDir == 1 ? currentTop + liveLane : currentBot - liveLane
    liveBg = f_state_color(currentState, currentDir)
    liveSide = currentDir == 1 ? "BULL" : "BEAR"
    liveTxt = "LIVE " + liveSide + " | " + f_state_slug(currentState) + " " + str.tostring(reactionScore) + " | MID " + f_price(currentMid)
    if na(liveConnector)
        liveConnector := line.new(liveAnchorX, currentMid, liveX - 1, liveY, xloc = xloc.bar_index, color = color.new(liveBg, 4), width = 2)
    else
        line.set_xy1(liveConnector, liveAnchorX, currentMid)
        line.set_xy2(liveConnector, liveX - 1, liveY)
        line.set_color(liveConnector, color.new(liveBg, 4))
        line.set_width(liveConnector, 2)
    if na(liveTag)
        liveTag := label.new(liveX, liveY, liveTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(liveBg, 0), textcolor = f_text_on(liveBg), size = labelSize)
    else
        label.set_xy(liveTag, liveX, liveY)
        label.set_text(liveTag, liveTxt)
        label.set_style(liveTag, label.style_label_left)
        label.set_color(liveTag, color.new(liveBg, 0))
        label.set_textcolor(liveTag, f_text_on(liveBg))
        label.set_size(liveTag, labelSize)
else if barstate.islast
    if not na(liveTag)
        label.delete(liveTag)
        liveTag := na
    if not na(liveConnector)
        line.delete(liveConnector)
        liveConnector := na

// -------------------------------------------------
// Impulse Markers
// -------------------------------------------------
plotshape(showImpulseMarkers and newBeltFormed and newBeltDir == 1, title = "Bull Impulse", location = location.belowbar, style = shape.triangleup, color = bullColor, size = size.tiny)
plotshape(showImpulseMarkers and newBeltFormed and newBeltDir == -1, title = "Bear Impulse", location = location.abovebar, style = shape.triangledown, color = bearColor, size = size.tiny)

// -------------------------------------------------
// Panel
// -------------------------------------------------
currentText = currentIdx >= 0 ? (currentDir == 1 ? "Bull " : "Bear ") + f_state_text(currentState) : "No Active Belt"
currentColor = currentIdx >= 0 ? f_state_color(currentState, currentDir) : panelLabelCol
holdRateText = reactionTotal > 0 ? str.tostring(int(math.round(holdRate))) + "% (" + str.tostring(reactionTotal) + ")" : "Building"
holdRateColor = na(holdRate) ? panelValueCol : holdRate >= 55.0 ? bullColor : holdRate >= 45.0 ? neutralColor : bearColor

var table panel = na

if showPanel and na(panel)
    panel := table.new(f_pos(panelPosition), 2, 8, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Repricing Belt Engine", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 1, 1, 7)
    table.cell(panel, 0, 1, "Current", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, currentText, text_color = f_text_on(currentColor), bgcolor = currentColor, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Action", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, actionText, text_color = f_text_on(actionColor), bgcolor = actionColor, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Score", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, str.tostring(reactionScore) + " / 100", text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Hold Rate", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, holdRateText, text_color = holdRateColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Bias (50b)", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, biasText, text_color = f_text_on(biasColor), bgcolor = biasColor, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 6, "Active", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, str.tostring(activeCount) + " / " + str.tostring(maxActive), text_color = panelValueCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)
    table.cell(panel, 0, 7, "H/R/B 50b", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, str.tostring(heldRecent) + " / " + str.tostring(rejectedRecent) + " / " + str.tostring(brokenRecent), text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(enableAlerts and newBeltFormed, "Repricing Belt Formed", "Repricing Belt Engine: a new repricing belt formed.")
alertcondition(enableAlerts and touchedThisBar, "Belt Revisited", "Repricing Belt Engine: price revisited an active belt.")
alertcondition(enableAlerts and justHeldIdx >= 0, "Belt Held", "Repricing Belt Engine: first revisit held the belt.")
alertcondition(enableAlerts and justRejectedIdx >= 0, "Belt Rejected", "Repricing Belt Engine: price penetrated and recovered the belt.")
alertcondition(enableAlerts and justBrokenIdx >= 0, "Belt Broken", "Repricing Belt Engine: repricing belt was broken.")
alertcondition(enableAlerts and justExpiredIdx >= 0, "Belt Expired", "Repricing Belt Engine: unresolved belt expired.")
````
