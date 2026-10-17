# Hidden Divergence Continuation Zones [AGPro Series]

- url: https://www.tradingview.com/script/KlbXe0Q9-Hidden-Divergence-Continuation-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;1b4404d413cd4f1c8a12a9f206e07c83
- version: 4.0

## Description

Hidden Divergence Continuation Zones [AGPro Series]

🟦 Overview

Hidden Divergence Continuation Zones [AGPro Series] is a focused trend-continuation indicator built around one specific market behavior: hidden divergence that forms during a structured pullback inside an existing directional move.

Most divergence tools are built to search for reversals. They scan regular bullish and bearish divergence, print many labels, and often mix every oscillator event into the same visual map. This script intentionally takes a narrower lane. It does not try to be a general divergence scanner. It looks only for hidden bullish and hidden bearish divergence, because hidden divergence is most useful when the question is not "is the trend ending?" but "is the trend trying to continue after a controlled pullback?"

The result is a cleaner continuation framework:
- confirmed price swing structure
- RSI momentum displacement
- EMA and DMI trend filtering
- ATR-normalized quality scoring
- lower-intensity HDC Watch labels
- forward continuation pockets
- swing connectors
- trigger labels
- compact AGPro dashboard

The purpose is to make hidden continuation structure visible without filling the chart with every possible divergence mark.

🔹 What Makes This Different

This script is separated from both common public divergence tools and our existing AGPro divergence family by design.

It is not a multi-oscillator regular divergence stack. It does not score RSI, MACD, CCI, MFI, and OBV together. That lane is already covered by broader stack-style divergence tools.

It is not an OBV pressure divergence map. It does not study price-versus-participation disagreement through cumulative volume pressure.

It is not a trend dashboard with divergence added as a side feature.

Hidden Divergence Continuation Zones focuses on a single continuation workflow:
1. Confirm that the market has an active directional side.
2. Wait for a valid pullback swing.
3. Compare the new swing against the previous swing.
4. Accept only hidden divergence that supports continuation.
5. Draw a forward pocket from the continuation pivot.
6. Track whether price later triggers from that structure.

That narrow scope is the edge. The script is designed to avoid visual noise and avoid conceptual overlap.

🧭 Core Logic

Bullish hidden continuation:
- the trend filter must support a bullish continuation environment
- price must form a confirmed higher low
- RSI must form a lower low against that higher price low
- the two compared swings must be separated by enough bars
- the structure must be large enough relative to ATR
- the RSI displacement must clear the minimum threshold
- the final continuation score must pass the display threshold

Bearish hidden continuation:
- the trend filter must support a bearish continuation environment
- price must form a confirmed lower high
- RSI must form a higher high against that lower price high
- the two compared swings must be separated by enough bars
- the structure must be large enough relative to ATR
- the RSI displacement must clear the minimum threshold
- the final continuation score must pass the display threshold

The script uses confirmed pivots, so events appear only after the pivot is structurally available. This keeps the logic stable and prevents premature labels from appearing on incomplete swings.

📐 Continuation Score

Each qualified setup is graded with a 0 to 100 continuation score.

The score combines:
- ADX strength above the selected minimum
- ATR-normalized distance between the compared swings
- RSI displacement between the two pivot points
- whether the pullback sits in a continuation-relevant EMA area
- whether the fast and slow EMA structure remains aligned

The default thresholds are designed to keep the chart selective. Normal qualified events are shown as HDC+ or HDC-. Stronger events are shown as PRIME HDC+ or PRIME HDC-.

Lower-intensity confirmed hidden divergence candidates can also be displayed as HDC WATCH labels. These marks are intentionally softer: they add visual context and keep the chart informative, but they do not create continuation pockets or trigger tracking unless the full continuation threshold is reached.

🧩 Continuation Pockets

When a hidden continuation event qualifies, the script projects a forward pocket from the pivot area.

These pockets are not generic support and resistance boxes. They are continuation context zones tied directly to the hidden divergence pivot. Their job is to preserve the important pullback area on the chart after the label appears, so the user can see where the continuation structure was created.

Pocket height is ATR-based, which helps the zones adapt across symbols and timeframes. The number of visible pockets is capped, so older structures are automatically removed and the chart remains clean.

🎯 Trigger Labels

After a hidden divergence pocket is created, the script monitors a limited trigger window.

For bullish continuation, a trigger is printed only when price confirms above the pivot candle reference with the selected ATR buffer.

For bearish continuation, a trigger is printed only when price confirms below the pivot candle reference with the selected ATR buffer.

This keeps the workflow organized:
- hidden divergence creates the continuation pocket
- the pocket defines the structure
- the trigger label marks follow-through from that structure

⚙️ Dashboard

The AGPro panel is built for quick reading:
- Oscillator: current RSI value
- Trend Side: bullish continuation, bearish continuation, or neutral
- Swing Quality: none, building, qualified, or prime
- Continuation Score: latest event score
- Active Pocket: current pocket state and freshness

The first panel row follows the AGPro standard: one merged blue header row with only the script title. Panel location, panel theme, label font size, and panel font size are all adjustable from settings.

🧪 Practical Reading

A clean bullish continuation sequence usually looks like this:
1. Trend Side shows Bull Continuation.
2. Price pulls back and forms a confirmed higher low.
3. RSI makes a lower low at that swing.
4. A continuation pocket appears below/around the pullback area.
5. A trigger label appears only if price follows through during the trigger window.

A clean bearish continuation sequence usually looks like this:
1. Trend Side shows Bear Continuation.
2. Price pulls back and forms a confirmed lower high.
3. RSI makes a higher high at that swing.
4. A continuation pocket appears above/around the pullback area.
5. A trigger label appears only if price follows through during the trigger window.

The best use case is structured trend continuation study, especially when a trader wants to separate controlled pullbacks from random oscillator divergence noise.

🔍 Key Inputs

Trend Continuation Filter:
- Fast EMA Length
- Slow EMA Length
- EMA Slope Lookback
- DMI Length
- ADX Smoothing
- Minimum ADX

Hidden Divergence Engine:
- RSI Length
- Confirmed Pivot Length
- Minimum Pivot Separation
- Minimum Price Swing (ATR)
- Minimum RSI Displacement
- Minimum Continuation Score
- Prime Score Threshold
- Show HDC Watch Labels
- Watch Label Score

Continuation Pockets:
- Show Continuation Pockets
- Pocket Extension Bars
- Pocket Height (ATR)
- Maximum Visible Pockets
- Trigger Window Bars
- Trigger Buffer (ATR)

Visual Layout:
- EMA Backbone
- Swing Connectors
- Event Labels
- Same-Side Label Cooldown
- Label Offset
- Label Font Size
- Maximum Visible Labels
- Maximum Visible Connectors

Panel:
- Show Panel
- Panel Location
- Panel Theme
- Panel Font Size

🟣 Design Notes

The visual design is intentionally restrained:
- no regular divergence clutter
- no multi-oscillator table overload
- no unnecessary signal spam
- no permanent background wash
- no oversized dashboard
- no generic zone engine detached from the core concept

The chart should stay readable while still feeling active and premium. Swing connectors explain where the hidden divergence came from. Pockets preserve the continuation area. Labels are offset from candles and controlled by cooldown settings.

✨ Summary

Hidden Divergence Continuation Zones [AGPro Series] is built for traders who want a cleaner way to study trend continuation through hidden divergence.

Instead of asking whether every oscillator disagreement matters, this tool asks a more specific question:

Is there a confirmed hidden divergence pullback inside a real trend, and did that structure create a continuation pocket worth tracking?

That focused question is what keeps the script distinct, lightweight, and visually clean.

## Source Code

````pine
// -------------------------------------------------
// Hidden Divergence Continuation Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Hidden Divergence Continuation Zones identifies trend-aligned hidden
// divergence structures where price forms continuation-friendly higher lows
// or lower highs while RSI momentum displaces against the pullback. The script
// combines EMA trend filtering, DMI/ADX pressure, RSI displacement, swing
// quality scoring, continuation pockets, trigger tracking, centered zone
// labels and a compact AGPro panel for hidden divergence continuation analysis.
// Version 1.3 couples every visible pocket with its centered identity, adds
// confirmed trend-context badges, and separates live pocket state from stale
// event memory in the panel.
// -------------------------------------------------

//@version=6
indicator("Hidden Divergence Continuation Zones [AGPro Series]",
     shorttitle       = "AG Pro HDC",
     overlay          = true,
     max_labels_count = 220,
     max_lines_count  = 220,
     max_boxes_count  = 160)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
// Brand
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
// Panel
panelBgD      = color.rgb(15, 23, 42)
panelBorderD  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelValueD   = color.rgb(226, 232, 240)
panelBgL      = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
// States
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupTrend = "Trend Continuation Filter"
groupDiv = "Hidden Divergence Engine"
groupZones = "Continuation Pockets"
groupVisual = "Visual Layout"
groupPanel = "Panel"
groupAlerts = "Alerts"

enginePreset = input.string("Swing / 4H", "Engine Preset", options = ["Swing / 4H", "Daily Selective", "Custom"], group = groupTrend,
     tooltip = "Selects the default behavior profile. Swing / 4H balances signal frequency and clarity. Daily Selective is cleaner and more selective. Custom uses the raw inputs below.")

src = input.source(close, "Source", group = groupTrend,
     tooltip = "Price source used by the RSI continuation oscillator and the EMA trend backbone.")

fastLen = input.int(34, "Fast EMA Length", minval = 5, maxval = 200, group = groupTrend,
     tooltip = "Fast EMA used to define the active continuation side and the pullback area.")

slowLen = input.int(89, "Slow EMA Length", minval = 10, maxval = 400, group = groupTrend,
     tooltip = "Slow EMA used as the structural trend backbone. Hidden bullish events require the fast EMA above this line, while hidden bearish events require the opposite.")

slopeBars = input.int(5, "EMA Slope Lookback", minval = 1, maxval = 50, group = groupTrend,
     tooltip = "Number of bars used to confirm that the fast EMA is still advancing or declining in the direction of the continuation setup.")

dmiLen = input.int(14, "DMI Length", minval = 5, maxval = 50, group = groupTrend,
     tooltip = "Directional Movement length used to confirm that the continuation side is supported by directional pressure.")

adxSmooth = input.int(14, "ADX Smoothing", minval = 5, maxval = 50, group = groupTrend,
     tooltip = "Smoothing length for the ADX value returned by the DMI engine.")

minAdx = input.float(12.5, "Minimum ADX", minval = 5.0, maxval = 50.0, step = 0.5, group = groupTrend,
     tooltip = "Minimum directional strength required before a hidden divergence can qualify as a continuation event.")

showBackbone = input.bool(true, "Show EMA Backbone", group = groupTrend,
     tooltip = "Displays the fast and slow EMA continuation backbone with restrained colors.")

oscLen = input.int(14, "RSI Length", minval = 3, maxval = 100, group = groupDiv,
     tooltip = "RSI length used as the hidden divergence oscillator. The engine is intentionally focused on one oscillator to avoid becoming a generic divergence stack scanner.")

pivotLen = input.int(5, "Confirmed Pivot Length", minval = 2, maxval = 20, group = groupDiv,
     tooltip = "Bars to the left and right of a swing pivot. Larger values reduce noise but confirm later.")

minPivotGap = input.int(5, "Minimum Pivot Separation", minval = 2, maxval = 80, group = groupDiv,
     tooltip = "Minimum bar distance between compared pivots. This prevents tightly packed micro-swings from crowding the chart.")

minStructureAtr = input.float(0.22, "Minimum Price Swing (ATR)", minval = 0.05, maxval = 5.0, step = 0.05, group = groupDiv,
     tooltip = "Minimum ATR-normalized distance between the two price pivots used for the hidden divergence comparison.")

minOscDelta = input.float(1.8, "Minimum RSI Displacement", minval = 0.5, maxval = 30.0, step = 0.1, group = groupDiv,
     tooltip = "Minimum RSI difference between the two compared swing pivots. Higher values keep only cleaner momentum displacement.")

minScore = input.int(54, "Minimum Continuation Score", minval = 40, maxval = 95, group = groupDiv,
     tooltip = "Minimum composite score required before a hidden divergence event creates a continuation pocket.")

primeScore = input.int(78, "Prime Score Threshold", minval = 55, maxval = 100, group = groupDiv,
     tooltip = "Score level used for the strongest visual classification. Prime events receive brighter labels and zones.")

showWatchLabels = input.bool(true, "Show HDC Watch Labels", group = groupDiv,
     tooltip = "Shows softer labels for confirmed hidden divergence candidates that are below the main zone threshold but still support the continuation lane.")

watchScore = input.int(46, "Watch Label Score", minval = 30, maxval = 85, group = groupDiv,
     tooltip = "Minimum score for a lower-intensity HDC Watch label. These labels do not create continuation pockets or trigger tracking.")

showZones = input.bool(true, "Show Continuation Pockets", group = groupZones,
     tooltip = "Draws a forward rectangle from qualified hidden divergence pivots. These pockets are continuation context zones, not generic support or resistance boxes.")

showZoneLabels = input.bool(true, "Show Labeled Continuation Pockets", group = groupZones,
     tooltip = "Keeps every visible continuation pocket paired with a centered identity label. Disabling this option hides both the pocket and its label.")

zoneExtendBars = input.int(42, "Pocket Extension Bars", minval = 10, maxval = 160, group = groupZones,
     tooltip = "How far each continuation pocket extends to the right from the confirmed swing pivot.")

zoneAtrHeight = input.float(0.62, "Pocket Height (ATR)", minval = 0.15, maxval = 2.5, step = 0.05, group = groupZones,
     tooltip = "ATR-based height of each continuation pocket. The default keeps the zone visible without dominating the chart.")

maxActiveZones = input.int(12, "Maximum Visible Pockets", minval = 3, maxval = 40, group = groupZones,
     tooltip = "Maximum number of continuation pockets kept on the chart. Older pockets are automatically removed.")

triggerWindow = input.int(26, "Trigger Window Bars", minval = 3, maxval = 80, group = groupZones,
     tooltip = "Number of bars after a confirmed hidden divergence during which a continuation trigger can be marked. This window is also used by the Continuation Rate proof.")

triggerBufferAtr = input.float(0.05, "Trigger Buffer (ATR)", minval = 0.0, maxval = 0.5, step = 0.01, group = groupZones,
     tooltip = "Small ATR buffer added beyond the pivot candle before a continuation trigger label is printed.")

confirmTriggersOnClose = input.bool(true, "Confirm Triggers on Close", group = groupZones,
     tooltip = "Requires the trigger bar to close before a continuation trigger is confirmed. This reduces intrabar state changes in alerts and chart labels.")

showConnectors = input.bool(true, "Show Swing Connectors", group = groupVisual,
     tooltip = "Draws a clean connector between the two price pivots that produced the hidden divergence.")

showLabels = input.bool(true, "Show Event Labels", group = groupVisual,
     tooltip = "Shows qualified hidden divergence, trigger and confirmed trend-context labels with controlled density.")

showTrendLabels = input.bool(true, "Show Trend Context Labels", group = groupVisual,
     tooltip = "Marks confirmed changes into bullish or bearish continuation context. These are context badges, not hidden-divergence signals.")

trendLabelCooldown = input.int(28, "Trend Context Cooldown", minval = 8, maxval = 160, group = groupVisual,
     tooltip = "Minimum bars between trend-context badges. The default adds useful chart coverage without turning normal trend changes into label clutter.")

lowTfCleanMode = input.bool(true, "Auto Clean Sub-4H View", group = groupVisual,
     tooltip = "Automatically reduces watch-only labels, connector intensity and retained historical structures below 4H so the publication view stays readable. Core trigger logic remains active.")

labelCooldown = input.int(8, "Same-Side Label Cooldown", minval = 0, maxval = 80, group = groupVisual,
     tooltip = "Minimum bars between same-direction labels. This keeps the overlay premium and avoids excessive clustering.")

labelOffsetAtr = input.float(0.92, "Label Offset (ATR)", minval = 0.15, maxval = 4.0, step = 0.05, group = groupVisual,
     tooltip = "ATR-based vertical offset used so labels do not sit inside candles.")

labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls the size of chart labels. Normal is the default for publication readability.")

labelDetail = input.string("Balanced", "Label Detail", options = ["Compact", "Balanced", "Detailed"], group = groupVisual,
     tooltip = "Controls the amount of information printed inside event labels.")

maxLabels = input.int(28, "Maximum Visible Labels", minval = 8, maxval = 80, group = groupVisual,
     tooltip = "Maximum event and trigger labels kept on the chart.")

maxConnectors = input.int(30, "Maximum Visible Connectors", minval = 8, maxval = 80, group = groupVisual,
     tooltip = "Maximum swing connector lines kept on the chart.")

bullZoneColor = input.color(color.rgb(34, 197, 166), "Bull Pocket Color", group = groupVisual,
     tooltip = "Color used for bullish hidden divergence continuation pockets.")

bearZoneColor = input.color(color.rgb(244, 114, 182), "Bear Pocket Color", group = groupVisual,
     tooltip = "Color used for bearish hidden divergence continuation pockets.")

showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Shows the AG Pro summary panel with oscillator, trend side, swing quality, continuation score and continuation rate.")

panelLocation = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = groupPanel,
     tooltip = "Selects the dashboard anchor location.")

panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Switches the panel between a dark AGPro theme and a lighter publication theme.")

panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls the dashboard text size. Normal is the default AGPro publication setting.")

panelMemoryBars = input.int(120, "Panel Memory Bars", minval = 10, maxval = 500, group = groupPanel,
     tooltip = "Controls how long the panel keeps the last completed continuation event after no active pocket remains.")

alertBullPocket = input.bool(true, "Alert on Bullish Pocket", group = groupAlerts,
     tooltip = "Enables alerts when a bullish hidden divergence continuation pocket is detected.")

alertBearPocket = input.bool(true, "Alert on Bearish Pocket", group = groupAlerts,
     tooltip = "Enables alerts when a bearish hidden divergence continuation pocket is detected.")

alertTriggers = input.bool(true, "Alert on Continuation Trigger", group = groupAlerts,
     tooltip = "Enables alerts when an active hidden divergence pocket confirms a continuation trigger.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
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

f_panel_bg(isLight, alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : panelBgL) : (alt ? color.rgb(24, 35, 55) : panelBgD)

f_quality(scoreValue, minQ, primeQ) =>
    na(scoreValue) ? "None" :
     scoreValue >= primeQ ? "Prime" :
     scoreValue >= minQ ? "Qualified" :
     "Building"

f_score(float adxPivot, float priceAtr, float oscDelta, bool pullbackOk, bool emaAligned) =>
    score = 0.0
    score += math.min(26.0, math.max(0.0, 8.0 + (adxPivot - minAdx) * 1.25))
    score += math.min(24.0, priceAtr * 18.0)
    score += math.min(24.0, oscDelta * 2.2)
    score += pullbackOk ? 16.0 : 6.0
    score += emaAligned ? 10.0 : 0.0
    math.min(100.0, score)

f_push_box(array<box> store, box item, int limit) =>
    array.push(store, item)
    while array.size(store) > limit
        oldItem = array.shift(store)
        if not na(oldItem)
            box.delete(oldItem)

f_push_line(array<line> store, line item, int limit) =>
    array.push(store, item)
    while array.size(store) > limit
        oldItem = array.shift(store)
        if not na(oldItem)
            line.delete(oldItem)

f_push_label(array<label> store, label item, int limit) =>
    array.push(store, item)
    while array.size(store) > limit
        oldItem = array.shift(store)
        if not na(oldItem)
            label.delete(oldItem)

// -------------------------------------------------
// Preset Resolution
// -------------------------------------------------
dailyPreset = enginePreset == "Daily Selective"
usedMinScore = dailyPreset ? math.max(minScore, 62) : minScore
usedPrimeScore = dailyPreset ? math.max(primeScore, 82) : primeScore
usedWatchScore = dailyPreset ? math.max(watchScore, 54) : watchScore
usedMaxZones = dailyPreset ? math.min(maxActiveZones, 10) : maxActiveZones
usedMaxLabels = dailyPreset ? math.min(maxLabels, 22) : maxLabels
usedMaxConnectors = dailyPreset ? math.min(maxConnectors, 24) : maxConnectors
chartSeconds = timeframe.in_seconds(timeframe.period)
belowBestView = timeframe.isintraday and not na(chartSeconds) and chartSeconds < 14400
cleanLowTf = lowTfCleanMode and belowBestView
showWatchLabelsEff = showWatchLabels and not cleanLowTf
showConnectorsEff = showConnectors and not cleanLowTf
usedMaxZonesEff = cleanLowTf ? math.min(usedMaxZones, 6) : usedMaxZones
usedMaxLabelsEff = cleanLowTf ? math.min(usedMaxLabels, 16) : usedMaxLabels
usedMaxConnectorsEff = cleanLowTf ? math.min(usedMaxConnectors, 12) : usedMaxConnectors

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
panelTextSize = f_size(panelSizeInput)

emaFast = ta.ema(src, fastLen)
emaSlow = ta.ema(src, slowLen)
[dmiPlus, dmiMinus, adxValue] = ta.dmi(dmiLen, adxSmooth)
atrValue = ta.atr(14)
atrSafe = math.max(nz(atrValue, 0.0), syminfo.mintick)
oscValue = ta.rsi(src, oscLen)

trendUp = close > emaFast and emaFast > emaSlow and emaFast > nz(emaFast[slopeBars], emaFast) and dmiPlus > dmiMinus and adxValue >= minAdx
trendDown = close < emaFast and emaFast < emaSlow and emaFast < nz(emaFast[slopeBars], emaFast) and dmiMinus > dmiPlus and adxValue >= minAdx
trendSide = trendUp ? "Bull Continuation" : trendDown ? "Bear Continuation" : "Neutral"

pivotLowPrice = ta.pivotlow(low, pivotLen, pivotLen)
pivotHighPrice = ta.pivothigh(high, pivotLen, pivotLen)
hasLowPivot = not na(pivotLowPrice)
hasHighPivot = not na(pivotHighPrice)

plot(showBackbone ? emaFast : na, "Fast EMA", color = color.new(accentColor, 18), linewidth = 2)
plot(showBackbone ? emaSlow : na, "Slow EMA", color = color.new(panelLabelD, 45), linewidth = 2)

// -------------------------------------------------
// State
// -------------------------------------------------
var float lastLowPrice = na
var float lastLowOsc = na
var int lastLowBar = na
var float lastHighPrice = na
var float lastHighOsc = na
var int lastHighBar = na

var int lastBullLabelBar = na
var int lastBearLabelBar = na
var int lastBullWatchBar = na
var int lastBearWatchBar = na
var string lastEvent = "None"
var string lastState = "Idle"
var float lastScore = na
var int lastEventBar = na
var int lastTrendContextBar = na

var int activeDirection = 0
var float activeTrigger = na
var float activeInvalid = na
var int activeStartBar = na
var bool activeTriggered = false

var array<box> zoneBoxes = array.new<box>()
var array<line> connectorLines = array.new<line>()
var array<label> eventLabels = array.new<label>()
var array<label> zoneLabels = array.new<label>()

newBullEvent = false
newBearEvent = false
bullTrigger = false
bearTrigger = false

// Per-bar event capture for the continuation-rate proof
float evtTrigger = na
float evtInvalid = na
int evtDir = 0

// -------------------------------------------------
// Hidden Bullish Continuation
// -------------------------------------------------
if hasLowPivot
    currentLowBar = bar_index - pivotLen
    currentLowPrice = pivotLowPrice
    currentLowOsc = oscValue[pivotLen]
    atrPivot = math.max(nz(atrValue[pivotLen], atrSafe), syminfo.mintick)
    adxPivot = nz(adxValue[pivotLen], adxValue)
    emaFastPivot = emaFast[pivotLen]
    emaSlowPivot = emaSlow[pivotLen]
    trendAtPivot = trendUp[pivotLen]
    enoughHistory = not na(lastLowPrice) and not na(lastLowOsc) and not na(lastLowBar) and not na(currentLowOsc)
    if enoughHistory
        pivotGap = currentLowBar - lastLowBar
        priceSwingAtr = math.abs(currentLowPrice - lastLowPrice) / atrPivot
        oscDelta = lastLowOsc - currentLowOsc
        hiddenBull = currentLowPrice > lastLowPrice and currentLowOsc < lastLowOsc
        enoughGap = pivotGap >= minPivotGap
        enoughSwing = priceSwingAtr >= minStructureAtr
        enoughOsc = oscDelta >= minOscDelta
        emaAligned = emaFastPivot > emaSlowPivot and currentLowPrice >= emaSlowPivot - atrPivot * 0.8
        pullbackOk = currentLowPrice <= emaFastPivot + atrPivot * 1.2 and currentLowPrice >= emaSlowPivot - atrPivot * 1.1
        score = f_score(adxPivot, priceSwingAtr, oscDelta, pullbackOk, emaAligned)
        passesDensity = na(lastBullLabelBar) or currentLowBar - lastBullLabelBar >= labelCooldown or score >= usedPrimeScore
        passesWatchDensity = na(lastBullWatchBar) or currentLowBar - lastBullWatchBar >= labelCooldown
        qualified = hiddenBull and trendAtPivot and enoughGap and enoughSwing and enoughOsc and score >= usedMinScore and passesDensity
        watchCandidate = hiddenBull and enoughGap and priceSwingAtr >= minStructureAtr * 0.70 and oscDelta >= minOscDelta * 0.70 and emaAligned and score >= usedWatchScore and passesWatchDensity
        if qualified
            newBullEvent := true
            lastBullLabelBar := currentLowBar
            lastEvent := score >= usedPrimeScore ? "Prime Bull HDC" : "Bull HDC"
            lastState := "Watching"
            lastScore := score
            lastEventBar := currentLowBar
            zoneBottom = currentLowPrice - atrPivot * zoneAtrHeight * 0.28
            zoneTop = currentLowPrice + atrPivot * zoneAtrHeight
            zoneMid = (zoneTop + zoneBottom) * 0.5
            zoneCenterX = currentLowBar + int(math.round(zoneExtendBars / 2.0))
            activeDirection := 1
            activeTrigger := high[pivotLen] + atrPivot * triggerBufferAtr
            activeInvalid := zoneBottom
            activeStartBar := bar_index
            activeTriggered := false
            evtTrigger := activeTrigger
            evtInvalid := activeInvalid
            evtDir := 1
            drawPocket = showZones and showZoneLabels
            scoreText = str.tostring(math.round(score))
            if drawPocket
                zoneColor = score >= usedPrimeScore ? color.new(bullZoneColor, 80) : color.new(bullZoneColor, 87)
                zone = box.new(currentLowBar, zoneTop, currentLowBar + zoneExtendBars, zoneBottom,
                     xloc = xloc.bar_index,
                     bgcolor = zoneColor,
                     border_color = color.new(bullZoneColor, score >= usedPrimeScore ? 18 : 35),
                     border_width = score >= usedPrimeScore ? 2 : 1)
                f_push_box(zoneBoxes, zone, usedMaxZonesEff)
                zoneText = score >= usedPrimeScore ? "PRIME HDC+\n" + scoreText : "HDC+\n" + scoreText
                zoneLabel = label.new(zoneCenterX, zoneMid, zoneText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_center,
                     color = color.new(bullZoneColor, 10),
                     textcolor = headerText,
                     size = labelSize,
                     textalign = text.align_center)
                f_push_label(zoneLabels, zoneLabel, usedMaxZonesEff)
            else if showLabels
                labelText = labelDetail == "Compact" ? "HDC+ " + scoreText :
                     labelDetail == "Detailed" ? "BULL HDC\nScore " + scoreText + "\nRSI Delta " + str.tostring(oscDelta, "#.#") :
                     (score >= usedPrimeScore ? "PRIME HDC+\n" : "BULL HDC\n") + scoreText
                eventLabel = label.new(currentLowBar, currentLowPrice - atrPivot * labelOffsetAtr, labelText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_up,
                     color = score >= usedPrimeScore ? color.new(bullZoneColor, 0) : color.new(bullZoneColor, 16),
                     textcolor = headerText,
                     size = labelSize)
                f_push_label(eventLabels, eventLabel, usedMaxLabelsEff)
            if showConnectorsEff
                connector = line.new(lastLowBar, lastLowPrice, currentLowBar, currentLowPrice,
                     xloc = xloc.bar_index,
                     color = color.new(bullZoneColor, score >= usedPrimeScore ? 6 : 22),
                     width = score >= usedPrimeScore ? 3 : 2)
                f_push_line(connectorLines, connector, usedMaxConnectorsEff)
        else if showWatchLabelsEff and showLabels and watchCandidate
            lastBullWatchBar := currentLowBar
            bullWatchText = labelDetail == "Compact" ? "WATCH+" : "HDC WATCH+\n" + str.tostring(math.round(score))
            bullWatchLabel = label.new(currentLowBar, currentLowPrice - atrPivot * labelOffsetAtr * 0.72, bullWatchText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_up,
                 color = color.new(bullZoneColor, 34),
                 textcolor = headerText,
                 size = labelSize)
            f_push_label(eventLabels, bullWatchLabel, usedMaxLabelsEff)
            if showConnectorsEff
                bullWatchConnector = line.new(lastLowBar, lastLowPrice, currentLowBar, currentLowPrice,
                     xloc = xloc.bar_index,
                     color = color.new(bullZoneColor, 48),
                     width = 1)
                f_push_line(connectorLines, bullWatchConnector, usedMaxConnectorsEff)
    lastLowPrice := currentLowPrice
    lastLowOsc := currentLowOsc
    lastLowBar := currentLowBar

// -------------------------------------------------
// Hidden Bearish Continuation
// -------------------------------------------------
if hasHighPivot
    currentHighBar = bar_index - pivotLen
    currentHighPrice = pivotHighPrice
    currentHighOsc = oscValue[pivotLen]
    atrPivot = math.max(nz(atrValue[pivotLen], atrSafe), syminfo.mintick)
    adxPivot = nz(adxValue[pivotLen], adxValue)
    emaFastPivot = emaFast[pivotLen]
    emaSlowPivot = emaSlow[pivotLen]
    trendAtPivot = trendDown[pivotLen]
    enoughHistory = not na(lastHighPrice) and not na(lastHighOsc) and not na(lastHighBar) and not na(currentHighOsc)
    if enoughHistory
        pivotGap = currentHighBar - lastHighBar
        priceSwingAtr = math.abs(currentHighPrice - lastHighPrice) / atrPivot
        oscDelta = currentHighOsc - lastHighOsc
        hiddenBear = currentHighPrice < lastHighPrice and currentHighOsc > lastHighOsc
        enoughGap = pivotGap >= minPivotGap
        enoughSwing = priceSwingAtr >= minStructureAtr
        enoughOsc = oscDelta >= minOscDelta
        emaAligned = emaFastPivot < emaSlowPivot and currentHighPrice <= emaSlowPivot + atrPivot * 0.8
        pullbackOk = currentHighPrice >= emaFastPivot - atrPivot * 1.2 and currentHighPrice <= emaSlowPivot + atrPivot * 1.1
        score = f_score(adxPivot, priceSwingAtr, oscDelta, pullbackOk, emaAligned)
        passesDensity = na(lastBearLabelBar) or currentHighBar - lastBearLabelBar >= labelCooldown or score >= usedPrimeScore
        passesWatchDensity = na(lastBearWatchBar) or currentHighBar - lastBearWatchBar >= labelCooldown
        qualified = hiddenBear and trendAtPivot and enoughGap and enoughSwing and enoughOsc and score >= usedMinScore and passesDensity
        watchCandidate = hiddenBear and enoughGap and priceSwingAtr >= minStructureAtr * 0.70 and oscDelta >= minOscDelta * 0.70 and emaAligned and score >= usedWatchScore and passesWatchDensity
        if qualified
            newBearEvent := true
            lastBearLabelBar := currentHighBar
            lastEvent := score >= usedPrimeScore ? "Prime Bear HDC" : "Bear HDC"
            lastState := "Watching"
            lastScore := score
            lastEventBar := currentHighBar
            zoneTop = currentHighPrice + atrPivot * zoneAtrHeight * 0.28
            zoneBottom = currentHighPrice - atrPivot * zoneAtrHeight
            zoneMid = (zoneTop + zoneBottom) * 0.5
            zoneCenterX = currentHighBar + int(math.round(zoneExtendBars / 2.0))
            activeDirection := -1
            activeTrigger := low[pivotLen] - atrPivot * triggerBufferAtr
            activeInvalid := zoneTop
            activeStartBar := bar_index
            activeTriggered := false
            evtTrigger := activeTrigger
            evtInvalid := activeInvalid
            evtDir := -1
            drawPocket = showZones and showZoneLabels
            scoreText = str.tostring(math.round(score))
            if drawPocket
                zoneColor = score >= usedPrimeScore ? color.new(bearZoneColor, 80) : color.new(bearZoneColor, 87)
                zone = box.new(currentHighBar, zoneTop, currentHighBar + zoneExtendBars, zoneBottom,
                     xloc = xloc.bar_index,
                     bgcolor = zoneColor,
                     border_color = color.new(bearZoneColor, score >= usedPrimeScore ? 18 : 35),
                     border_width = score >= usedPrimeScore ? 2 : 1)
                f_push_box(zoneBoxes, zone, usedMaxZonesEff)
                zoneText = score >= usedPrimeScore ? "PRIME HDC-\n" + scoreText : "HDC-\n" + scoreText
                zoneLabel = label.new(zoneCenterX, zoneMid, zoneText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_center,
                     color = color.new(bearZoneColor, 10),
                     textcolor = headerText,
                     size = labelSize,
                     textalign = text.align_center)
                f_push_label(zoneLabels, zoneLabel, usedMaxZonesEff)
            else if showLabels
                labelText = labelDetail == "Compact" ? "HDC- " + scoreText :
                     labelDetail == "Detailed" ? "BEAR HDC\nScore " + scoreText + "\nRSI Delta " + str.tostring(oscDelta, "#.#") :
                     (score >= usedPrimeScore ? "PRIME HDC-\n" : "BEAR HDC\n") + scoreText
                eventLabel = label.new(currentHighBar, currentHighPrice + atrPivot * labelOffsetAtr, labelText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = label.style_label_down,
                     color = score >= usedPrimeScore ? color.new(bearZoneColor, 0) : color.new(bearZoneColor, 16),
                     textcolor = headerText,
                     size = labelSize)
                f_push_label(eventLabels, eventLabel, usedMaxLabelsEff)
            if showConnectorsEff
                connector = line.new(lastHighBar, lastHighPrice, currentHighBar, currentHighPrice,
                     xloc = xloc.bar_index,
                     color = color.new(bearZoneColor, score >= usedPrimeScore ? 6 : 22),
                     width = score >= usedPrimeScore ? 3 : 2)
                f_push_line(connectorLines, connector, usedMaxConnectorsEff)
        else if showWatchLabelsEff and showLabels and watchCandidate
            lastBearWatchBar := currentHighBar
            bearWatchText = labelDetail == "Compact" ? "WATCH-" : "HDC WATCH-\n" + str.tostring(math.round(score))
            bearWatchLabel = label.new(currentHighBar, currentHighPrice + atrPivot * labelOffsetAtr * 0.72, bearWatchText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_down,
                 color = color.new(bearZoneColor, 34),
                 textcolor = headerText,
                 size = labelSize)
            f_push_label(eventLabels, bearWatchLabel, usedMaxLabelsEff)
            if showConnectorsEff
                bearWatchConnector = line.new(lastHighBar, lastHighPrice, currentHighBar, currentHighPrice,
                     xloc = xloc.bar_index,
                     color = color.new(bearZoneColor, 48),
                     width = 1)
                f_push_line(connectorLines, bearWatchConnector, usedMaxConnectorsEff)
    lastHighPrice := currentHighPrice
    lastHighOsc := currentHighOsc
    lastHighBar := currentHighBar

// -------------------------------------------------
// Confirmed Trend Context
// -------------------------------------------------
newBullContext = barstate.isconfirmed and trendUp and not trendUp[1]
newBearContext = barstate.isconfirmed and trendDown and not trendDown[1]
contextGapOk = na(lastTrendContextBar) or bar_index - lastTrendContextBar >= trendLabelCooldown

if showLabels and showTrendLabels and contextGapOk and not newBullEvent and not newBearEvent
    if newBullContext
        contextLabel = label.new(bar_index, low - atrSafe * labelOffsetAtr, "BULL\nCONTINUATION",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_up,
             color = color.new(bullColor, 8),
             textcolor = headerText,
             size = labelSize)
        f_push_label(eventLabels, contextLabel, usedMaxLabelsEff)
        lastTrendContextBar := bar_index
    else if newBearContext
        contextLabel = label.new(bar_index, high + atrSafe * labelOffsetAtr, "BEAR\nCONTINUATION",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_down,
             color = color.new(bearColor, 8),
             textcolor = headerText,
             size = labelSize)
        f_push_label(eventLabels, contextLabel, usedMaxLabelsEff)
        lastTrendContextBar := bar_index

// -------------------------------------------------
// Trigger Tracking
// -------------------------------------------------
hasActive = activeDirection != 0 and not na(activeStartBar)
activeWindowOpen = hasActive and bar_index > activeStartBar and bar_index - activeStartBar <= triggerWindow
activeExpired = hasActive and not activeTriggered and bar_index - activeStartBar > triggerWindow
activeResolved = hasActive and activeTriggered and bar_index - activeStartBar > triggerWindow
activeInvalidated = hasActive and not activeTriggered and ((activeDirection == 1 and low < activeInvalid) or (activeDirection == -1 and high > activeInvalid))
triggerConfirmed = not confirmTriggersOnClose or barstate.isconfirmed

if activeWindowOpen and activeDirection == 1 and not activeTriggered and not activeInvalidated and triggerConfirmed and close > activeTrigger
    bullTrigger := true
    activeTriggered := true
    lastState := "Triggered"
    if showLabels
        trig = label.new(bar_index, low - atrSafe * (labelOffsetAtr + 0.7), "BULL HDC\nTRIGGER",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_up,
             color = color.new(bullZoneColor, 0),
             textcolor = headerText,
             size = labelSize)
        f_push_label(eventLabels, trig, usedMaxLabelsEff)

if activeWindowOpen and activeDirection == -1 and not activeTriggered and not activeInvalidated and triggerConfirmed and close < activeTrigger
    bearTrigger := true
    activeTriggered := true
    lastState := "Triggered"
    if showLabels
        trig = label.new(bar_index, high + atrSafe * (labelOffsetAtr + 0.7), "BEAR HDC\nTRIGGER",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_down,
             color = color.new(bearZoneColor, 0),
             textcolor = headerText,
             size = labelSize)
        f_push_label(eventLabels, trig, usedMaxLabelsEff)

if activeInvalidated
    lastState := "Invalidated"
    activeDirection := 0
    activeTrigger := na
    activeInvalid := na
    activeStartBar := na
    activeTriggered := false
else if activeExpired
    lastState := "Expired"
    activeDirection := 0
    activeTrigger := na
    activeInvalid := na
    activeStartBar := na
    activeTriggered := false
else if activeResolved
    lastState := "Triggered"
    activeDirection := 0
    activeTrigger := na
    activeInvalid := na
    activeStartBar := na
    activeTriggered := false

// -------------------------------------------------
// Continuation-rate proof (Confirm Rate)
// -------------------------------------------------
var int   hdcTotal = 0
var int   hdcWon    = 0
var bool  hdcPend   = false
var int   hdcDir    = 0
var float hdcTrig   = na
var float hdcInv    = na
var int   hdcLeft   = 0

if barstate.isconfirmed
    if hdcPend and not na(hdcTrig)
        bool lostHit = hdcDir == 1 ? low < hdcInv : high > hdcInv
        bool wonHit = hdcDir == 1 ? close > hdcTrig : close < hdcTrig
        if lostHit
            hdcTotal += 1
            hdcPend := false
        else if wonHit
            hdcTotal += 1
            hdcWon += 1
            hdcPend := false
        else
            hdcLeft -= 1
            if hdcLeft <= 0
                hdcTotal += 1
                hdcPend := false
    if (newBullEvent or newBearEvent) and evtDir != 0 and not hdcPend
        hdcPend := true
        hdcDir := evtDir
        hdcTrig := evtTrigger
        hdcInv := evtInvalid
        hdcLeft := triggerWindow

float hdcRate = hdcTotal > 0 ? hdcWon / hdcTotal * 100.0 : na

// -------------------------------------------------
// Panel
// -------------------------------------------------
isLightPanel = panelTheme == "Light"
panelMainBg = f_panel_bg(isLightPanel, false)
panelAltBg = f_panel_bg(isLightPanel, true)
panelBorder = isLightPanel ? panelBorderL : panelBorderD
panelLabelText = isLightPanel ? panelLabelL : panelLabelD
panelValueText = isLightPanel ? panelValueL : panelValueD

oscText = "RSI " + str.tostring(oscValue, "#.0")
memoryFresh = not na(lastEventBar) and bar_index - lastEventBar <= panelMemoryBars
panelScore = activeDirection != 0 or memoryFresh ? lastScore : na
qualityText = f_quality(panelScore, usedMinScore, usedPrimeScore)
scoreTextPanel = na(panelScore) ? "n/a" : str.tostring(math.round(panelScore)) + " / 100"
activeText = activeDirection == 1 ? "Bull pocket" : activeDirection == -1 ? "Bear pocket" : "No active pocket"
activeText := activeDirection != 0 and activeTriggered ? activeText + " / Triggered" : activeText
lastEventText = na(lastEventBar) ? "None" : lastEvent + " / " + str.tostring(bar_index - lastEventBar) + " bars ago"
contText = hdcTotal > 0 ? str.tostring(math.round(hdcRate)) + "% (" + str.tostring(hdcTotal) + ")" : "Building"

trendColor = trendUp ? bullColor : trendDown ? bearColor : neutralColor
scoreColor = na(panelScore) ? panelValueText : panelScore >= usedPrimeScore ? accentColor : panelScore >= usedMinScore ? neutralColor : panelValueText
activeColor = activeDirection == 1 ? bullColor : activeDirection == -1 ? bearColor : panelValueText
lastEventColor = memoryFresh ? accentColor : panelLabelText
contColor = na(hdcRate) ? panelValueText : hdcRate >= 60.0 ? bullColor : hdcRate >= 45.0 ? neutralColor : bearColor

var table panel = na
var string prevPanelLocation = ""
var string prevPanelTheme = ""

panelNeedsRebuild = showPanel and (na(panel) or prevPanelLocation != panelLocation or prevPanelTheme != panelTheme)
if panelNeedsRebuild
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelLocation), 2, 8,
         bgcolor = panelMainBg,
         frame_color = panelBorder,
         frame_width = 1,
         border_color = panelBorder,
         border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Hidden Divergence Continuation Zones", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize)
    table.merge_cells(panel, 0, 0, 1, 0)
    prevPanelLocation := panelLocation
    prevPanelTheme := panelTheme

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    prevPanelLocation := ""
    prevPanelTheme := ""

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelLocation))
    table.clear(panel, 0, 1, 1, 7)
    table.cell(panel, 0, 0, "AG Pro Hidden Divergence Continuation Zones", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize, text_halign = text.align_center)
    table.cell(panel, 0, 1, "Oscillator", text_color = panelLabelText, bgcolor = panelMainBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, oscText, text_color = panelValueText, bgcolor = panelMainBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Trend Side", text_color = panelLabelText, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, trendSide, text_color = trendColor, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Swing Quality", text_color = panelLabelText, bgcolor = panelMainBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, qualityText, text_color = scoreColor, bgcolor = panelMainBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Score", text_color = panelLabelText, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, scoreTextPanel, text_color = scoreColor, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Pocket State", text_color = panelLabelText, bgcolor = panelMainBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, activeText, text_color = activeColor, bgcolor = panelMainBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 6, "Last Event", text_color = panelLabelText, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, lastEventText, text_color = lastEventColor, bgcolor = panelAltBg, text_size = panelTextSize, text_halign = text.align_right)
    table.cell(panel, 0, 7, "Continuation Rate", text_color = panelLabelText, bgcolor = panelMainBg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, contText, text_color = contColor, bgcolor = panelMainBg, text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertBullPocket and newBullEvent, "Bullish Hidden Continuation Pocket", "Bullish hidden divergence continuation pocket detected on {{ticker}} {{interval}}.")
alertcondition(alertBearPocket and newBearEvent, "Bearish Hidden Continuation Pocket", "Bearish hidden divergence continuation pocket detected on {{ticker}} {{interval}}.")
alertcondition(alertTriggers and bullTrigger, "Bullish Continuation Trigger", "Bullish hidden divergence continuation trigger confirmed on {{ticker}} {{interval}}.")
alertcondition(alertTriggers and bearTrigger, "Bearish Continuation Trigger", "Bearish hidden divergence continuation trigger confirmed on {{ticker}} {{interval}}.")

plot(lastScore, "HDC Last Score", display = display.none)
plot(activeDirection, "HDC Active Direction", display = display.none)
plot(oscValue, "HDC RSI", display = display.none)
plot(hdcRate, "HDC Continuation Rate", display = display.none)
````
