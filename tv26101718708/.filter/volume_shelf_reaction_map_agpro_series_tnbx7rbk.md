# Volume Shelf Reaction Map [AGPro Series]

- url: https://www.tradingview.com/script/tnbX7RBK-Volume-Shelf-Reaction-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;fb2d3c797ce44c7084364cae74400b98
- version: 5.0

## Description

Volume Shelf Reaction Map [AGPro Series]

🔷 OVERVIEW

Volume Shelf Reaction Map is a structural price-action tool that identifies horizontal zones where volume has historically stacked — "volume shelves" — and classifies, in real time, how price reacts each time it returns to them. Instead of showing a static S/R line, it answers a sharper question: when price revisits this level, does it hold, get reclaimed, get rejected, or lose the level entirely? Fresh shelves (never revisited) are visually separated from reused ones, so the chart communicates not just where the levels are, but which ones still carry unused participation behind them.


🧭 UNIQUE EDGE

Most support/resistance and volume tools stop at drawing a zone. This script adds a reaction-state layer on top of shelf detection:

• Five reaction states per shelf: TOUCH, HELD, RECL (reclaimed), REJ (rejected), LOST
• Fresh vs Reused classification — shelves that have already been tested at least once are faded, so untouched structural levels stand out immediately
• Sticky state logic — a shelf keeps its reaction color until a new transition actually occurs, preventing flicker between bars
• Passive-window coloring — shelves whose last reaction is older than the user-defined active window fade to the neutral accent color, keeping old/stale levels visible without dominating the chart
• Strongest-shelf-only reaction tags with cooldown — reaction labels are printed only for the highest-strength shelf and only on actual state transitions, producing a clean chart even on long histories

The result is a volume-aware reaction map rather than a crowded S/R overlay.


🧪 METHODOLOGY

1. Pivot detection — standard pivot highs and lows over a configurable pivot length act as shelf candidates.
2. Volume qualification — each pivot bar is checked against a rolling 20-bar volume average; bars above the Volume Filter multiplier contribute extra weight to shelf strength.
3. ATR-based clustering — candidates within a configurable ATR multiple of an existing shelf are merged using a touches-weighted mean price, stabilizing the shelf location as evidence accumulates.
4. Confirmation — a shelf must reach the Minimum Touches threshold before it is rendered; weak candidates are pruned after one-third of the lookback window.
5. State machine — on every confirmed bar, a shelf's reaction is updated against the prior close's side (support vs resistance context), using an ATR-scaled buffer to distinguish genuine holds and losses from noise.
6. Ranking and rendering — on the last bar, shelves are sorted by strength; only the top N are drawn, with fresh shelves rendered solid and reused shelves rendered thinner and faded.


🔔 SIGNALS & ALERTS

Three alert types, each debounced per shelf so the same state cannot spam consecutive bars:

• Shelf Touched — price range intersects a confirmed shelf for the first time since its last transition
• Shelf Respected — price HELDs, RECLs, or REJs at a shelf (reaction in favor of the shelf)
• Shelf Lost — price closes through a shelf with the required ATR buffer

Reaction tags on the chart (HELD / RECL / REJ / LOST) are printed only for the strongest shelf and only on a true state transition, with a user-adjustable cooldown for historical cleanliness.


⚙️ KEY INPUTS

Shelf Detection
• Lookback Window (bars) — how far back the pivot scan reaches
• Pivot Strength — bars required on each side of a pivot
• Cluster Distance (x ATR) — how tightly nearby pivots merge
• Minimum Touches — confirmation threshold

Filters & Cleanup
• Volume Filter (x average) — participation threshold for strength weighting
• Show Fresh Shelves Only — hide already-revisited shelves
• Max Shelves to Display — cap visible shelves for chart cleanliness
• Fade Reused Shelves — dim reused shelves so fresh ones stand out
• Reaction Sensitivity (x ATR) — ATR buffer used by the state machine
• Active Window (bars) — how recently a reaction must have occurred to show in full color

Visuals
• Label & Panel Size — Tiny / Small / Normal / Large (default: Normal)
• Show Reaction Tags — toggle on-chart state labels
• Tag Cooldown (bars) — minimum bars between tags on the same shelf

Panel
• Show Info Panel, Panel Location (6 anchors), Panel Theme (Dark / Light)

Alerts
• Shelf Touched, Shelf Respected, Shelf Lost


🧰 HOW TO USE

1. Add the indicator to any liquid symbol and timeframe. Volume-aware markets (crypto, index futures, major FX) and timeframes from 15m upward tend to produce the most structured shelves.
2. Start with defaults. The Active Window of 30 bars is a reasonable middle-ground; reduce it on intraday charts (around 20) or raise it on daily/weekly (30–60).
3. Read the panel:
   • Active Shelves — how many of the eligible shelves are currently drawn
   • Strongest Shelf — the top-ranked shelf by strength
   • Current State — live reaction state of the top shelf
   • Fresh / Reused — how the displayed shelves split between untested and already-tested levels
4. Use fresh shelves as higher-quality reaction candidates; treat reused shelves as context, not primary triggers.
5. Combine the HELD / RECL / REJ / LOST reactions with your own trigger logic (e.g. break-retest, liquidity sweeps, momentum shifts). This script is a location and reaction tool — not a standalone trade system.


🧱 LIMITATIONS & TRANSPARENCY

• This indicator describes historical structure and live reactions; it does not forecast price direction.
• Pivot-based detection requires the Pivot Strength window to complete on both sides, so fresh pivots appear with a natural lag equal to the pivot length.
• On very low-volume symbols or illiquid timeframes, shelves may be sparse or unstable.
• The state machine is bar-close based; intrabar wicks can temporarily intersect a shelf without changing its state until the bar confirms.
• Max drawing limits (max_lines_count, max_labels_count, max_boxes_count) are set to 120; extremely long histories combined with large lookbacks may drop the oldest drawings.


⚠️ RISK DISCLOSURE

This script is provided for educational and analytical purposes only. It is not a strategy, not a buy/sell signal generator, and not financial advice. Trading involves substantial risk of loss. Past behavior of levels, volume, or reactions does not guarantee future outcomes. Always apply your own risk management, position sizing, and independent judgment. The author and AGProLabs accept no responsibility for decisions made based on this indicator.

## Source Code

````pine
// -------------------------------------------------
// Volume Shelf Reaction Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Volume Shelf Reaction Map detects horizontal price zones where volume and
// pivot activity repeatedly stack, then classifies how price reacts when those
// shelves are revisited. It separates fresh and reused shelves, maps touch,
// hold, reclaim, reject, and lost reactions, scores the strongest shelf 0-100,
// surfaces a clear next-action stance, and proves the structure with a live
// Shelf Respect Rate, all through ranked shelf zones, owned reaction badges,
// and an AG Pro panel.
// -------------------------------------------------

//@version=6
indicator("Volume Shelf Reaction Map [AGPro Series]",
     shorttitle = "AG VSRM",
     overlay = true,
     max_bars_back = 1500,
     max_lines_count = 80,
     max_labels_count = 180,
     max_boxes_count = 120)

// Drawings that use historical bar-index coordinates require an explicit time
// buffer. The cap covers the maximum 1,200-bar shelf memory plus pivot context.
max_bars_back(time, 1500)

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
// Input groups
// -------------------------------------------------
gDetect = "Shelf Detection"
gFilter = "Filters & Cleanup"
gVisual = "Visual Layer"
gLabels = "Labels"
gPanel  = "Panel"
gAlerts = "Alerts"

// -------------------------------------------------
// Inputs
// -------------------------------------------------
lookbackBars = input.int(320, "Lookback Window", minval = 50, maxval = 1200, group = gDetect, tooltip = "Number of recent bars kept in the shelf memory engine.")
pivotLen = input.int(5, "Pivot Strength", minval = 2, maxval = 20, group = gDetect, tooltip = "Pivot confirmation strength used to collect shelf candidates.")
clusterAtr = input.float(0.34, "Cluster Distance (ATR)", minval = 0.10, maxval = 1.50, step = 0.05, group = gDetect, tooltip = "ATR-scaled distance used to merge nearby pivot candidates into one shelf.")
minTouches = input.int(2, "Minimum Touches", minval = 1, maxval = 8, group = gDetect, tooltip = "Minimum number of pivot touches required before a shelf becomes eligible for display.")
volumeLen = input.int(20, "Volume Average Length", minval = 1, maxval = 200, group = gDetect, tooltip = "Smoothing length used for the participation filter.")
volFilter = input.float(1.15, "Volume Filter (x Average)", minval = 0.50, maxval = 5.00, step = 0.05, group = gDetect, tooltip = "Pivot bars must show at least this volume multiple to receive extra shelf strength.")

maxShelves = input.int(3, "Max Visible Shelves", minval = 1, maxval = 8, group = gFilter, tooltip = "Maximum number of strongest shelves drawn on the chart. Three shelves is the default publication setting for a cleaner first impression.")
showFreshOnly = input.bool(false, "Show Fresh Shelves Only", group = gFilter, tooltip = "Hides reused shelves from the visual layer while keeping the memory engine intact.")
fadeReused = input.bool(true, "Fade Reused Shelves", group = gFilter, tooltip = "Dims shelves that have already been revisited.")
passiveBars = input.int(32, "Active Reaction Window", minval = 3, maxval = 500, group = gFilter, tooltip = "Number of bars a shelf reaction remains visually active before becoming neutral again.")
reactAtr = input.float(0.24, "Reaction Sensitivity (ATR)", minval = 0.05, maxval = 1.00, step = 0.05, group = gFilter, tooltip = "ATR buffer used to classify hold, reclaim, reject, and lost reactions.")

showShelfZones = input.bool(true, "Show Shelf Zones", group = gVisual, tooltip = "Draws horizontal shelf zones around each displayed shelf.")
showZoneText = input.bool(false, "Show Detailed Edge Badges", group = gVisual, tooltip = "Adds touch and strength evidence to the filled right-side shelf badges. No bare text is placed inside shelf zones.")
zoneWidthATR = input.float(0.10, "Shelf Zone Width (ATR)", minval = 0.02, maxval = 0.80, step = 0.01, group = gVisual, tooltip = "Vertical thickness of shelf zones.")
zoneOpacity = input.int(90, "Shelf Zone Transparency", minval = 60, maxval = 96, group = gVisual, tooltip = "Transparency used for shelf zones. Higher values make the zones more subtle.")
zoneProjectionBars = input.int(24, "Zone Projection Bars", minval = 5, maxval = 200, group = gVisual, tooltip = "How far shelf zones project to the right.")
showShelfLines = input.bool(true, "Show Shelf Midlines", group = gVisual, tooltip = "Draws a thin center line through each displayed shelf.")

showReactionTags = input.bool(true, "Show Reaction Tags", group = gLabels, tooltip = "Prints compact reaction labels when the strongest eligible shelf changes state.")
labelDensity = input.string("Minimal", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = gLabels, tooltip = "Controls how many reaction labels are retained on the chart. Minimal is the default publication setting.")
labelTextInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gLabels, tooltip = "Text size used for all shelf badges and reaction tags. Normal is the publication default.")
tagCooldown = input.int(28, "Reaction Tag Cooldown", minval = 0, maxval = 300, group = gLabels, tooltip = "Minimum number of bars before a new reaction tag can be printed.")
labelOffsetATR = input.float(0.52, "Reaction Label Offset (ATR)", minval = 0.05, maxval = 3.00, step = 0.05, group = gLabels, tooltip = "ATR-based spacing used for reaction labels.")

showPanel = input.bool(true, "Show Panel", group = gPanel, tooltip = "Displays the AG Pro shelf reaction panel.")
panelPos = input.string("Top Right", "Panel Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = gPanel, tooltip = "Panel placement on the chart.")
panelTheme = input.string("Auto", "Panel Theme", options = ["Auto", "Dark", "Light"], group = gPanel, tooltip = "Panel theme. Auto adapts to the chart background.")
panelTextInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gPanel, tooltip = "Text size used inside the panel. Normal is the publication default.")

alertTouch = input.bool(true, "Alert: Shelf Touch", group = gAlerts, tooltip = "Triggers when price touches an eligible shelf.")
alertRespect = input.bool(true, "Alert: Shelf Respect", group = gAlerts, tooltip = "Triggers on held, reclaimed, or rejected shelf reactions.")
alertLost = input.bool(true, "Alert: Shelf Lost", group = gAlerts, tooltip = "Triggers when price closes through an eligible shelf.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left"     => position.top_left
        "Top Center"   => position.top_center
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.top_right

f_dark_mode(string mode) =>
    lum = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
    mode == "Dark" ? true : mode == "Light" ? false : lum < 140

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)

f_trim_labels(array<label> items, int keep) =>
    while array.size(items) > keep
        oldItem = array.shift(items)
        if not na(oldItem)
            label.delete(oldItem)

f_state_text(int state) =>
    switch state
        1 => "TOUCH"
        2 => "HELD"
        3 => "RECLAIM"
        4 => "REJECT"
        5 => "LOST"
        => "IDLE"

f_state_color(int state) =>
    switch state
        1 => neutralColor
        2 => bullColor
        3 => bullColor
        4 => bearColor
        5 => bearColor
        => accentColor

// -------------------------------------------------
// Shelf type
// -------------------------------------------------
type Shelf
    float price
    float strength
    int touches
    int bornBar
    int lastPivotBar
    int state
    int stateBar
    int lastTaggedState
    int lastTaggedBar
    int lastAlertedState
    int proofClass
    bool reused
    box zone
    line midline
    label edgeLabel

var array<Shelf> shelves = array.new<Shelf>()
var label[] reactionLabels = array.new_label()
var int shelfRespected = 0
var int shelfLost = 0

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
atr = math.max(nz(ta.atr(14), ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volumeLen)
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
hiVolPivot = not na(volAvg[pivotLen]) and volume[pivotLen] >= volAvg[pivotLen] * volFilter

f_register_pivot(float px, int pivotBar, bool highParticipation) =>
    if not na(px) and atr > 0
        bool merged = false
        if array.size(shelves) > 0
            for i = 0 to array.size(shelves) - 1
                item = array.get(shelves, i)
                if math.abs(item.price - px) <= atr * clusterAtr
                    newTouches = item.touches + 1
                    item.price := (item.price * item.touches + px) / newTouches
                    item.touches := newTouches
                    item.strength += highParticipation ? 1.7 : 1.0
                    item.lastPivotBar := pivotBar
                    array.set(shelves, i, item)
                    merged := true
                    break
        if not merged
            newShelf = Shelf.new(
                 price = px,
                 strength = highParticipation ? 1.7 : 1.0,
                 touches = 1,
                 bornBar = pivotBar,
                 lastPivotBar = pivotBar,
                 state = 0,
                 stateBar = pivotBar,
                 lastTaggedState = 0,
                 lastTaggedBar = -9999,
                 lastAlertedState = 0,
                 proofClass = 0,
                 reused = false,
                 zone = na,
                 midline = na,
                 edgeLabel = na)
            array.push(shelves, newShelf)

if not na(ph)
    f_register_pivot(ph, bar_index - pivotLen, hiVolPivot)
if not na(pl)
    f_register_pivot(pl, bar_index - pivotLen, hiVolPivot)

// -------------------------------------------------
// Cleanup old shelves
// -------------------------------------------------
if barstate.isconfirmed and array.size(shelves) > 0
    int i = array.size(shelves) - 1
    while i >= 0
        item = array.get(shelves, i)
        tooOld = bar_index - item.lastPivotBar > lookbackBars
        tooWeak = item.touches < minTouches and bar_index - item.bornBar > int(math.round(lookbackBars / 3.0))
        if tooOld or tooWeak
            if not na(item.zone)
                box.delete(item.zone)
            if not na(item.midline)
                line.delete(item.midline)
            if not na(item.edgeLabel)
                label.delete(item.edgeLabel)
            array.remove(shelves, i)
        i -= 1

// -------------------------------------------------
// Shelf reaction state machine + respect-rate proof
//   A respected reaction (held, reclaimed, or rejected) and a lost reaction
//   (price closed through the shelf) are each counted once per regime on
//   eligible shelves, on confirmed bars only, so the Shelf Respect Rate is an
//   honest, non-repainting measure of how often tracked shelves hold.
// -------------------------------------------------
bool touchEvent = false
bool respectEvent = false
bool lostEvent = false

if barstate.isconfirmed and array.size(shelves) > 0
    for i = 0 to array.size(shelves) - 1
        item = array.get(shelves, i)
        buffer = atr * reactAtr
        inShelf = low <= item.price + buffer * 0.25 and high >= item.price - buffer * 0.25
        wasAbove = close[1] > item.price
        wasBelow = close[1] < item.price
        int desired = item.state
        if inShelf
            desired := 1
            if wasAbove and close >= item.price + buffer
                desired := 2
            else if wasAbove and close < item.price - buffer
                desired := 5
            else if wasBelow and close <= item.price - buffer
                desired := 4
            else if wasBelow and close > item.price + buffer
                desired := item.reused ? 3 : 5
        else
            if wasAbove and close < item.price - buffer
                desired := 5
            else if wasBelow and close > item.price + buffer
                desired := item.reused ? 3 : 5

        if desired != item.state
            item.state := desired
            item.stateBar := bar_index
            item.reused := item.reused or desired == 3 or desired == 5
            if item.touches >= minTouches
                touchEvent := touchEvent or desired == 1
                respectEvent := respectEvent or desired == 2 or desired == 3 or desired == 4
                lostEvent := lostEvent or desired == 5
                if (desired == 2 or desired == 3 or desired == 4) and item.proofClass != 1
                    shelfRespected += 1
                    item.proofClass := 1
                else if desired == 5 and item.proofClass != 2
                    shelfLost += 1
                    item.proofClass := 2
        else if desired == 1 and inShelf
            item.stateBar := bar_index
        array.set(shelves, i, item)

// -------------------------------------------------
// Ranking and rendering
// -------------------------------------------------
var float topPrice = na
var float topStrength = na
var float topScore = na
var int topState = 0
var bool topReused = false
var int displayedCount = 0
var int freshCount = 0
var int reusedCount = 0
var int totalEligible = 0
var int strongestIdx = -1

if barstate.islast
    topPrice := na
    topStrength := na
    topScore := na
    topState := 0
    topReused := false
    displayedCount := 0
    freshCount := 0
    reusedCount := 0
    totalEligible := 0
    strongestIdx := -1

    n = array.size(shelves)
    if n > 0
        idx = array.new_int()
        for i = 0 to n - 1
            array.push(idx, i)
            item = array.get(shelves, i)
            if not na(item.zone)
                box.delete(item.zone)
                item.zone := na
            if not na(item.midline)
                line.delete(item.midline)
                item.midline := na
            if not na(item.edgeLabel)
                label.delete(item.edgeLabel)
                item.edgeLabel := na
            array.set(shelves, i, item)

        if n > 1
            for i = 1 to n - 1
                key = array.get(idx, i)
                keyShelf = array.get(shelves, key)
                j = i - 1
                bool done = false
                while j >= 0 and not done
                    compareShelf = array.get(shelves, array.get(idx, j))
                    if compareShelf.strength < keyShelf.strength
                        array.set(idx, j + 1, array.get(idx, j))
                        j -= 1
                    else
                        done := true
                array.set(idx, j + 1, key)

        for rank = 0 to n - 1
            shelfIndex = array.get(idx, rank)
            item = array.get(shelves, shelfIndex)
            eligible = item.touches >= minTouches and (not showFreshOnly or not item.reused)
            if eligible
                totalEligible += 1
            if eligible and displayedCount < maxShelves
                if strongestIdx == -1
                    strongestIdx := shelfIndex
                activeReaction = bar_index - item.stateBar <= passiveBars and item.state > 0
                displayState = activeReaction ? item.state : 0
                shelfColor = f_state_color(displayState)
                shelfAlpha = fadeReused and item.reused ? zoneOpacity + 5 : zoneOpacity
                shelfAlpha := math.min(shelfAlpha, 96)
                halfWidth = atr * zoneWidthATR
                top = item.price + halfWidth
                bottom = item.price - halfWidth
                int renderLeft = math.max(item.bornBar, bar_index - lookbackBars)
                if showShelfZones
                    item.zone := box.new(left = renderLeft, top = top, right = bar_index + zoneProjectionBars, bottom = bottom, xloc = xloc.bar_index, bgcolor = color.new(shelfColor, shelfAlpha), border_color = color.new(shelfColor, item.reused ? 55 : 28), border_width = item.reused ? 1 : 2)
                if showShelfLines
                    item.midline := line.new(renderLeft, item.price, bar_index + zoneProjectionBars, item.price, xloc = xloc.bar_index, extend = extend.none, color = color.new(shelfColor, item.reused ? 42 : 18), width = item.reused ? 1 : 2)
                int shelfRank = displayedCount + 1
                string shelfIdentity = displayState == 0 ? (item.reused ? "REUSED SHELF" : "FRESH SHELF") : f_state_text(displayState)
                string shelfEvidence = showZoneText ? "\n" + str.tostring(item.price, format.mintick) + " | T " + str.tostring(item.touches) + " | STR " + str.tostring(item.strength, "#.0") : "\n" + str.tostring(item.price, format.mintick)
                string tagText = "#" + str.tostring(shelfRank) + " " + shelfIdentity + shelfEvidence
                string shelfTooltip = "Ranked volume shelf | " + (item.reused ? "Reused" : "Fresh") + " | Touches " + str.tostring(item.touches) + " | Strength " + str.tostring(item.strength, "#.0")
                item.edgeLabel := label.new(bar_index + zoneProjectionBars, item.price, tagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(shelfColor, 6), textcolor = f_text_on(shelfColor), size = f_size(labelTextInput), textalign = text.align_center, tooltip = shelfTooltip)
                array.set(shelves, shelfIndex, item)

                if item.reused
                    reusedCount += 1
                else
                    freshCount += 1
                if displayedCount == 0
                    topPrice := item.price
                    topStrength := item.strength
                    topState := displayState
                    topReused := item.reused
                    tchS = math.min(item.touches / 5.0, 1.0) * 40.0
                    strgS = math.min(item.strength / 10.0, 1.0) * 30.0
                    recS = math.max(0.0, math.min(1.0, 1.0 - (bar_index - item.lastPivotBar) / math.max(lookbackBars, 1))) * 20.0
                    rstS = (displayState == 2 or displayState == 3 or displayState == 4) ? 10.0 : 0.0
                    topScore := math.min(tchS + strgS + recS + rstS, 100.0)
                displayedCount += 1

// -------------------------------------------------
// Reaction tags
// -------------------------------------------------
if barstate.isconfirmed and showReactionTags and array.size(shelves) > 0
    int bestIdx = -1
    float bestStrength = na
    for i = 0 to array.size(shelves) - 1
        item = array.get(shelves, i)
        eligible = item.touches >= minTouches and (not showFreshOnly or not item.reused)
        if eligible and (na(bestStrength) or item.strength > bestStrength)
            bestStrength := item.strength
            bestIdx := i
    if bestIdx >= 0
        item = array.get(shelves, bestIdx)
        isReaction = item.state == 2 or item.state == 3 or item.state == 4 or item.state == 5
        cooldownOk = tagCooldown == 0 or bar_index - item.lastTaggedBar >= tagCooldown
        if isReaction and item.stateBar == bar_index and item.state != item.lastTaggedState and cooldownOk
            tagColor = f_state_color(item.state)
            tagY = item.state == 4 or item.state == 5 ? low - atr * labelOffsetATR : high + atr * labelOffsetATR
            tagStyle = item.state == 4 or item.state == 5 ? label.style_label_up : label.style_label_down
            tag = label.new(bar_index, tagY, f_state_text(item.state), xloc = xloc.bar_index, yloc = yloc.price, style = tagStyle, color = color.new(tagColor, 0), textcolor = f_text_on(tagColor), size = f_size(labelTextInput))
            array.push(reactionLabels, tag)
            f_trim_labels(reactionLabels, labelDensity == "Detailed" ? 10 : labelDensity == "Balanced" ? 6 : 4)
            item.lastTaggedState := item.state
            item.lastTaggedBar := bar_index
            array.set(shelves, bestIdx, item)

// -------------------------------------------------
// Panel
// -------------------------------------------------
darkPanel = f_dark_mode(panelTheme)
panelFrame = darkPanel ? panelBorder : color.rgb(203, 213, 225)
leftBg = darkPanel ? color.rgb(13, 22, 38) : color.rgb(241, 245, 249)
rightBg = darkPanel ? color.rgb(8, 15, 28) : color.rgb(255, 255, 255)
leftTxt = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
rightTxt = darkPanel ? panelValueCol : color.rgb(15, 23, 42)
stateBg = color.new(f_state_color(topState), topState == 0 ? (darkPanel ? 38 : 86) : (darkPanel ? 28 : 84))
activeText = str.tostring(displayedCount) + " / " + str.tostring(totalEligible)
topPriceText = na(topPrice) ? "n/a" : "#1 " + str.tostring(topPrice, format.mintick) + (topReused ? " | REUSED" : " | FRESH")
scoreText = na(topScore) ? "n/a" : str.tostring(math.round(topScore)) + " / 100"
scoreCol = na(topScore) ? rightTxt : topScore >= 70 ? bullColor : topScore >= 45 ? neutralColor : bearColor
freshText = str.tostring(freshCount) + " fresh / " + str.tostring(reusedCount) + " reused"

totalProof = shelfRespected + shelfLost
respRate = totalProof > 0 ? shelfRespected / totalProof * 100.0 : na
respText = totalProof > 0 ? str.tostring(math.round(nz(respRate, 0.0))) + "% (" + str.tostring(totalProof) + ")" : "Building"
respCol = na(respRate) ? leftTxt : respRate >= 55 ? bullColor : respRate >= 45 ? neutralColor : bearColor

distAtr = na(topPrice) ? na : math.abs(close - topPrice) / atr
actionTxt = topState == 2 or topState == 3 ? "Respected - track hold" :
     topState == 4 ? "Rejected - fade from shelf" :
     topState == 5 ? "Lost - wait for re-accept" :
     topState == 1 ? "Testing - watch reaction" :
     not na(distAtr) and distAtr <= 0.5 ? "At shelf - watch reaction" :
     not na(distAtr) and distAtr <= 1.5 ? "Approaching shelf" : "Wait for shelf test"
actionBase = topState == 2 or topState == 3 ? bullColor :
     topState == 4 or topState == 5 ? bearColor :
     topState == 1 ? neutralColor :
     not na(distAtr) and distAtr <= 1.5 ? accentColor : panelLabelCol
actionBg = color.new(actionBase, darkPanel ? 28 : 84)

var table panel = na
var string lastPanelPos = ""
var string lastPanelTheme = ""
var bool lastPanelVisible = false

panelNeedsReset = na(panel) or panelPos != lastPanelPos or panelTheme != lastPanelTheme or showPanel != lastPanelVisible
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    if showPanel
        panel := table.new(f_panel_pos(panelPos), 2, 8, frame_color = panelFrame, border_color = panelFrame, border_width = 1)
        table.cell(panel, 0, 0, "AG Pro Volume Shelf Reaction Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelTextInput), text_halign = text.align_center)
        table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelTextInput))
        table.merge_cells(panel, 0, 0, 1, 0)
    else
        panel := na
    lastPanelPos := panelPos
    lastPanelTheme := panelTheme
    lastPanelVisible := showPanel

if showPanel and not na(panel) and barstate.islast
    table.clear(panel, 0, 1, 1, 7)
    table.cell(panel, 0, 0, "AG Pro Volume Shelf Reaction Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelTextInput), text_halign = text.align_center)
    table.cell(panel, 0, 1, "State", text_color = leftTxt, bgcolor = leftBg, text_size = f_size(panelTextInput))
    table.cell(panel, 1, 1, f_state_text(topState), text_color = f_text_on(stateBg), bgcolor = stateBg, text_size = f_size(panelTextInput))
    table.cell(panel, 0, 2, "Visible Shelves", text_color = leftTxt, bgcolor = leftBg, text_size = f_size(panelTextInput))
    table.cell(panel, 1, 2, activeText, text_color = rightTxt, bgcolor = rightBg, text_size = f_size(panelTextInput))
    table.cell(panel, 0, 3, "Strongest Shelf", text_color = leftTxt, bgcolor = leftBg, text_size = f_size(panelTextInput))
    table.cell(panel, 1, 3, topPriceText, text_color = rightTxt, bgcolor = rightBg, text_size = f_size(panelTextInput))
    table.cell(panel, 0, 4, "Shelf Score", text_color = leftTxt, bgcolor = leftBg, text_size = f_size(panelTextInput))
    table.cell(panel, 1, 4, scoreText, text_color = scoreCol, bgcolor = rightBg, text_size = f_size(panelTextInput))
    table.cell(panel, 0, 5, "Fresh / Reused", text_color = leftTxt, bgcolor = leftBg, text_size = f_size(panelTextInput))
    table.cell(panel, 1, 5, freshText, text_color = rightTxt, bgcolor = rightBg, text_size = f_size(panelTextInput))
    table.cell(panel, 0, 6, "Shelf Respect Rate", text_color = leftTxt, bgcolor = leftBg, text_size = f_size(panelTextInput))
    table.cell(panel, 1, 6, respText, text_color = respCol, bgcolor = rightBg, text_size = f_size(panelTextInput))
    table.cell(panel, 0, 7, "Action", text_color = leftTxt, bgcolor = leftBg, text_size = f_size(panelTextInput))
    table.cell(panel, 1, 7, actionTxt, text_color = f_text_on(actionBg), bgcolor = actionBg, text_size = f_size(panelTextInput))

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertTouch and touchEvent, "Shelf Touched", "Volume Shelf Reaction Map: price touched an eligible volume shelf.")
alertcondition(alertRespect and respectEvent, "Shelf Respected", "Volume Shelf Reaction Map: a shelf was held, reclaimed, or rejected.")
alertcondition(alertLost and lostEvent, "Shelf Lost", "Volume Shelf Reaction Map: price closed through an eligible volume shelf.")
````
