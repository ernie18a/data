# Volume Absorption Zones [AGPro Series]

- url: https://www.tradingview.com/script/10Fk4mJY-Volume-Absorption-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;2765fbba52764b8fbc17d316501a91fb
- version: 4.0

## Description

Volume Absorption Zones [AGPro Series]

🔷 Overview

Volume Absorption Zones [AGPro Series] is a chart-overlay volume analysis tool built around one specific market condition: high effort with limited price result.

Instead of marking every high-volume candle as important, the script looks for candles where participation expands while the candle range stays compressed, the close location shows directional control, and the resulting price area can be tracked as a forward absorption zone.

When a valid event appears, the script draws a rectangular bullish or bearish absorption box, projects it forward, adds an invalidation level, and continues monitoring whether the zone is defended, failed, or left as active context.

The goal is to make absorption visible as a lifecycle on the chart rather than a one-bar marker.

🔹 Core Idea

Absorption is not the same thing as a volume spike.

A volume spike can appear during expansion, exhaustion, liquidation, news reactions, or ordinary session activity. This script focuses on a narrower structure:

- Volume expands relative to its recent baseline.
- Candle spread remains compressed relative to its recent range baseline.
- The close location shows directional control.
- The wick/body structure leaves a usable absorption range.
- The zone remains visible after the event so later defense or failure can be evaluated.

Bullish absorption is modeled as high participation absorbed near the lower side of the candle while the close finishes with upper-side control.

Bearish absorption is modeled as high participation absorbed near the upper side of the candle while the close finishes with lower-side control.

This makes the script an effort-versus-result zone model, not a generic volume highlight.

💎 What Makes This Script Different

Most volume absorption scripts and high-volume tools stop at one of three outputs:

- A candle color.
- A triangle or label.
- A simple high-volume marker.

Volume Absorption Zones goes further by converting the detected event into a managed chart zone.

The script keeps asking questions after the first signal:

- Where is the absorption range?
- Is the zone still active?
- Has price defended the zone?
- Has price closed beyond the invalidation level?
- Is follow-through improving or fading?
- How old is the zone?
- Is the current context bullish absorption, bearish absorption, defended, failed, or mature?

This lifecycle approach is the main design difference. The first event creates the zone; the later candles tell the story.

🧭 Difference From Other AGPro Scripts

This script was designed to sit in a separate lane from existing AGPro volume and price-action tools.

It is not Volume Climax Detector.
Volume Climax Detector focuses on extreme participation and climax-style events. Volume Absorption Zones focuses on compressed effort: elevated volume with limited spread and a forward zone that can later defend or fail.

It is not Relative Volume Pressure Map.
Relative Volume Pressure Map classifies broader relative-volume pressure and pressure efficiency. Volume Absorption Zones does not try to build a broad pressure regime. It isolates concrete absorption ranges and follows their lifecycle.

It is not Volume Delta Imbalance Map.
Volume Delta Imbalance Map is built around flow imbalance behavior. Volume Absorption Zones does not estimate bid/ask delta, CVD, or directional transaction flow. It stays OHLCV-native and uses candle structure plus relative volume effort.

It is not Volume Profile Acceptance Ladder or a POC tool.
This script does not build volume profile bins, value area, POC magnets, acceptance ladders, or auction distribution zones. Its zones come only from absorption-candle conditions.

It is not a general support/resistance drawer.
The boxes are not swing highs, swing lows, pivots, order blocks, or manually projected support/resistance areas. A box appears only when the absorption engine detects high effort, compressed result, close-location control, and sufficient quality.

That separation is important: the script is not a renamed version of another AGPro concept. Its role is absorption-zone lifecycle tracking.

⚙️ How The Engine Works

The script evaluates each candle through a structured sequence:

1. Volume Effort
Current volume is compared with a rolling volume baseline. The event must show elevated participation before any absorption zone can be created.

2. Spread Compression
The candle range is compared with a recent spread baseline. A qualifying event needs limited price travel relative to normal range behavior.

3. Close Location
Bullish absorption requires the close to finish in the upper part of the candle. Bearish absorption requires the close to finish in the lower part of the candle.

4. Absorbed Wick Share
The script checks whether the candle leaves enough absorbed-side structure to define a useful zone.

5. Absorption Quality
Effort, compression, and close-location behavior are blended into a quality score. This helps filter weaker events and keeps the chart focused on stronger absorption structures.

6. Zone Projection
When the event qualifies, the script draws a rectangular zone and extends it forward for the selected number of bars.

7. Invalidation Level
Each zone receives an ATR-buffered invalidation line beyond the absorption range.

8. Defense / Failure Tracking
After the zone is created, the script tracks whether price defends the range or closes beyond invalidation.

📦 Zone States

Active
The zone has been created and remains unresolved.

Defended
Price interacts with the zone and closes back in favor of the zone direction.

Failed
Price closes beyond the ATR-buffered invalidation level.

Mature
The zone remains active beyond the selected age threshold.

These states help the user understand whether an absorption zone is still relevant, has been respected, or has lost its structure.

📊 AGPro Panel

The dashboard summarizes the latest absorption context without requiring the user to inspect every box manually.

Panel fields:

- Absorption Side
- Effort Score
- Spread Compression
- Follow-through
- Zone Status
- Zone Age

The panel follows the AGPro publication layout:

- Single merged blue header row.
- Header contains only the script panel title.
- Adjustable panel location.
- Adjustable panel theme.
- Adjustable panel font size.

🎯 Visual Design

The script is designed to be readable on clean publication charts:

- Bullish zones use the AGPro teal state color.
- Bearish zones use the AGPro pink state color.
- Failed zones shift to the neutral state color.
- Defended zones shift to the accent state color.
- Invalidation lines are dotted and subtle.
- Event labels are offset from candles so they remain visible.
- Label cooldown and maximum-label settings keep density under control.
- Active zone count is capped for performance and readability.

The default visual style is intentionally active, because absorption is easier to understand when the zone lifecycle is visible on the chart.

🔔 Alerts

Included alert conditions:

- Bullish Absorption Zone
- Bearish Absorption Zone
- Absorption Zone Defended
- Absorption Zone Failed

These alerts are tied to the same lifecycle states shown on the chart.

🛠 Key Inputs

Volume Baseline Length
Controls the lookback used to normalize current volume.

High Effort Threshold
Defines how much relative volume expansion is required before a candle can qualify.

Spread Baseline Length
Controls the range baseline used for spread compression.

Maximum Spread Ratio
Defines how compressed the candle must be relative to its baseline.

Strong Close Location
Controls how strongly the candle must close toward the active side.

Minimum Absorbed Wick Share
Requires visible absorbed-side candle structure before a zone can be accepted.

Minimum Absorption Quality
Filters events by the combined effort, compression, and close-location score.

Zone Extension Bars
Controls how far absorption boxes project forward.

Max Active Zones
Caps the number of active boxes retained on the chart.

Invalidation Buffer ATR
Controls the ATR buffer used for each zone's invalidation level.

Mature Zone Age
Defines when an unresolved zone is considered mature.

Max Zone Memory Bars
Removes older zones so the chart remains focused on recent, visible absorption context.

Label Cooldown Bars
Controls spacing between event labels.

Max Event Labels
Controls the maximum number of retained labels.

Label Font Size / Panel Font Size
Both default to Normal and can be adjusted from settings.

🧩 Best Use

Volume Absorption Zones is designed for traders who want to study:

- High-effort, low-result candles.
- Absorption zones that remain visible after the initial event.
- Whether later price action defends or fails those zones.
- Market areas where volume expands but price travel remains compressed.
- Weekly, daily, and intraday absorption structures without needing a lower-pane volume dashboard.

The script can be used across symbols and timeframes where TradingView volume data is available. The quality of results depends on the instrument, session structure, liquidity, and reliability of the volume feed.

🔍 Limitations & Transparency

This script uses standard TradingView OHLCV data.

It does not access order book data, bid/ask data, footprint data, true delta, or exchange-native transaction flow.

The absorption model is rule-based. It approximates absorption through relative volume effort, spread compression, close-location behavior, wick/body structure, and later zone interaction.

It does not predict future price movement and it does not issue buy or sell commands. It organizes absorption context on the chart so users can evaluate how price behaves around those zones.

Different instruments and timeframes may require input adjustments. Thin markets, irregular volume feeds, major gaps, and unusual sessions can affect event quality.

✅ Chart Reading Guide

For the clearest view, use a clean chart with only this script loaded. The boxes, labels, dotted invalidation lines, and panel are designed to explain the absorption lifecycle without requiring additional overlays.

## Source Code

````pine
// -----------------------------------------------------------------------------
// Volume Absorption Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Volume Absorption Zones detects high-effort, low-result price-volume events
// where elevated participation is absorbed inside a compressed candle range.
// It projects lifecycle-owned absorption boxes, continuously curates overlapping
// footprint identities from live box geometry, and summarizes effort,
// compression, follow-through, status, and age in a clean AGPro dashboard.
// -----------------------------------------------------------------------------

//@version=6
indicator("Volume Absorption Zones [AGPro Series]",
     shorttitle = "AG Pro VAZ",
     overlay = true,
     max_boxes_count = 120,
     max_lines_count = 120,
     max_labels_count = 120)

// -----------------------------------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
string groupCore = "Absorption Engine"
int volLen = input.int(50, "Volume Baseline Length", minval = 10, maxval = 300, group = groupCore,
     tooltip = "Lookback used to normalize current volume against its recent participation baseline.")
float effortThreshold = input.float(1.28, "High Effort Threshold", minval = 1.05, maxval = 5.00, step = 0.05, group = groupCore,
     tooltip = "Minimum volume-to-average-volume ratio required before an absorption zone can form.")
int spreadLen = input.int(34, "Spread Baseline Length", minval = 10, maxval = 300, group = groupCore,
     tooltip = "Lookback used to compare the current candle range against its recent spread baseline.")
float maxSpreadRatio = input.float(0.92, "Maximum Spread Ratio", minval = 0.20, maxval = 1.00, step = 0.01, group = groupCore,
     tooltip = "Current spread must be below this fraction of its baseline. Lower values require tighter compression.")
float strongCloseLocation = input.float(0.60, "Strong Close Location", minval = 0.55, maxval = 0.90, step = 0.01, group = groupCore,
     tooltip = "Bullish absorption requires a close near the upper part of the candle. Bearish absorption mirrors this near the lower part.")
float minAbsorbedWick = input.float(0.04, "Minimum Absorbed Wick Share", minval = 0.00, maxval = 0.45, step = 0.01, group = groupCore,
     tooltip = "Requires a minimum wick share on the absorbed side: lower wick for bullish absorption, upper wick for bearish absorption.")
float minQuality = input.float(50.0, "Minimum Absorption Quality", minval = 20.0, maxval = 95.0, step = 1.0, group = groupCore,
     tooltip = "Combined threshold for effort, compression, and close-location quality before a zone is accepted.")
bool confirmedBarsOnly = input.bool(true, "Use Confirmed Bars Only", group = groupCore,
     tooltip = "When enabled, new absorption zones are created only after the candle closes.")

string groupZones = "Zone Lifecycle"
int zoneExtensionBars = input.int(60, "Active Zone Extension Bars", minval = 15, maxval = 300, group = groupZones,
     tooltip = "Forward projection length for active absorption boxes and invalidation lines.")
int resolvedTailBars = input.int(12, "Resolved Zone Tail Bars", minval = 2, maxval = 50, group = groupZones,
     tooltip = "Final projection length retained after a zone is first defended or failed. This prevents resolved zones from expanding indefinitely.")
int maxActiveZones = input.int(5, "Max Visible Zones", minval = 2, maxval = 12, group = groupZones,
     tooltip = "Maximum number of absorption zones kept on the chart. Older zones are removed first.")
bool showZoneBadges = input.bool(true, "Show Zone Center Badges", group = groupZones,
     tooltip = "Shows contrast-safe centered labels inside absorption zones so zone identity stays readable on dark and white chart backgrounds.")
int maxVisibleZoneBadges = input.int(5, "Visible Zone Badges", minval = 0, maxval = 12, group = groupZones,
     tooltip = "Maximum number of zone center badges shown at once. Older zones remain visible, but their text is hidden to reduce overlap.")
float invalidationAtrBuffer = input.float(0.18, "Invalidation Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupZones,
     tooltip = "ATR-based distance used to place the invalidation line beyond the absorption range.")
int matureZoneAge = input.int(80, "Mature Zone Age", minval = 20, maxval = 500, group = groupZones,
     tooltip = "Active zones older than this value are marked as mature so the panel can distinguish fresh and aged context.")
int maxZoneMemoryBars = input.int(300, "Max Zone Memory Bars", minval = 120, maxval = 3000, group = groupZones,
     tooltip = "Removes old zones after this many bars so the chart stays focused on visible, actionable absorption context.")
bool showInvalidationLines = input.bool(true, "Show Invalidation Lines", group = groupZones,
     tooltip = "Shows the price level that invalidates the active absorption zone.")
bool colorAbsorptionBars = input.bool(true, "Color Absorption Bars", group = groupZones,
     tooltip = "Highlights newly detected bullish and bearish absorption candles with restrained AGPro colors.")

string groupLabels = "Labels"
bool showLabels = input.bool(true, "Show Defense / Failure Event Badges", group = groupLabels,
     tooltip = "Adds secondary defense and failure badges. Disabled by default because the centered zone badge already reports lifecycle status.")
int labelCooldown = input.int(30, "Event Badge Cooldown Bars", minval = 0, maxval = 150, group = groupLabels,
     tooltip = "Minimum spacing between printed event labels to keep the chart readable.")
int maxEventLabels = input.int(6, "Max Event Badges", minval = 1, maxval = 20, group = groupLabels,
     tooltip = "Maximum number of recent event labels retained on the chart.")
float labelOffsetAtr = input.float(0.80, "Event Badge Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels,
     tooltip = "ATR-based vertical distance used to keep labels clear of candle bodies and wicks.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels,
     tooltip = "Controls the size of chart event labels. Normal is the publication default.")

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Displays the AGPro absorption status panel.")
string panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = groupPanel,
     tooltip = "Selects where the status panel appears on the chart.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Controls the panel color theme.")
string panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls the size of the panel text. Normal is the publication default.")

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

// Luminance-aware contrast text (AGPro standard: luminance 145)
f_lum(color c) => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(color bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_position(string value) =>
    switch value
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_side(int value) =>
    switch value
        1 => "Bullish Absorption"
        -1 => "Bearish Absorption"
        => "Waiting"

f_status(int value) =>
    switch value
        1 => "Defended"
        -1 => "Failed"
        2 => "Mature"
        => "Active"

f_right_edge(int desiredRight) =>
    math.min(desiredRight, bar_index + 450)

f_price_floor(float value, float anchorPrice) =>
    math.max(value, math.max(syminfo.mintick, anchorPrice * 0.85))

f_zone_color(int sideValue, int statusValue) =>
    color result = color.new(bearColor, 78)
    if statusValue == -1
        result := color.new(neutralColor, 82)
    else if statusValue == 1
        result := color.new(accentColor, 78)
    else if sideValue == 1
        result := color.new(bullColor, 78)
    result

f_zone_border(int sideValue, int statusValue) =>
    color result = color.new(bearColor, 0)
    if statusValue == -1
        result := color.new(neutralColor, 10)
    else if statusValue == 1
        result := color.new(accentColor, 0)
    else if sideValue == 1
        result := color.new(bullColor, 0)
    result

f_zone_badge_text(int sideValue, int statusValue, float qualityValue) =>
    string sideText = sideValue == 1 ? "BULL ABS" : "BEAR ABS"
    string statusText = statusValue == 1 ? "HELD" : statusValue == -1 ? "FAIL" : statusValue == 2 ? "AGED" : "LIVE"
    sideText + " | " + statusText + " | Q" + str.tostring(math.round(qualityValue))

f_mid_bar(int leftValue, int rightValue) =>
    int(math.round((leftValue + rightValue) / 2.0))

f_zone_badge_y(float topValue, float bottomValue) =>
    (topValue + bottomValue) / 2.0

f_badge_collision_bars(string value) =>
    switch value
        "Tiny" => 24
        "Small" => 34
        "Large" => 64
        => 48

f_badge_collision_atr(string value) =>
    switch value
        "Tiny" => 1.10
        "Small" => 1.40
        "Large" => 2.30
        => 1.80

// Push an optional event badge with vertical anti-collision and an owned guide
// back to the exact source candle. Badge and guide share one FIFO lifecycle.
f_push_event(array<label> badges, array<line> guides, int x, float anchorY, float baseY, string txt, color bg, bool up, float gap, string szName) =>
    float adjY = baseY
    int guard = 0
    bool moved = true
    while moved and guard < 14
        moved := false
        if array.size(badges) > 0
            for i = 0 to array.size(badges) - 1
                label ex = array.get(badges, i)
                if math.abs(label.get_x(ex) - x) <= 8 and math.abs(label.get_y(ex) - adjY) < gap
                    adjY := up ? adjY - gap : adjY + gap
                    moved := true
                    break
        guard += 1
    label lb = label.new(x, adjY, txt, xloc = xloc.bar_index, yloc = yloc.price, style = up ? label.style_label_up : label.style_label_down, textcolor = f_text_on(bg), color = bg, size = f_size(szName))
    line guide = line.new(x, anchorY, x, adjY, xloc = xloc.bar_index, color = color.new(bg, 45), width = 1)
    array.push(badges, lb)
    array.push(guides, guide)

// -----------------------------------------------------------------------------
// Core measurements
// -----------------------------------------------------------------------------
float candleRange = high - low
float safeRange = math.max(candleRange, syminfo.mintick)
float atrValue = ta.atr(14)
float safeAtr = math.max(nz(atrValue, safeRange), syminfo.mintick)

float volBase = ta.sma(volume, volLen)
float volStd = ta.stdev(volume, volLen)
float effortRatio = volBase > 0.0 ? volume / volBase : 0.0
float effortZ = volStd > 0.0 ? (volume - volBase) / volStd : 0.0
float effortRatioScore = (effortRatio - 1.0) / (effortThreshold - 1.0) * 70.0
float effortZScore = f_clamp(effortZ, 0.0, 3.0) / 3.0 * 30.0
float effortScore = f_clamp(effortRatioScore + effortZScore, 0.0, 100.0)

float spreadBase = ta.sma(safeRange, spreadLen)
float spreadRatio = spreadBase > 0.0 ? safeRange / spreadBase : 1.0
float compressionScore = f_clamp((1.0 - spreadRatio) / (1.0 - maxSpreadRatio) * 100.0, 0.0, 100.0)

float closeLocation = (close - low) / safeRange
float bullCloseScore = f_clamp((closeLocation - 0.50) * 200.0, 0.0, 100.0)
float bearCloseScore = f_clamp((0.50 - closeLocation) * 200.0, 0.0, 100.0)

float bodyTop = math.max(open, close)
float bodyBottom = math.min(open, close)
float upperWickShare = (high - bodyTop) / safeRange
float lowerWickShare = (bodyBottom - low) / safeRange

float bullQuality = effortScore * 0.38 + compressionScore * 0.34 + bullCloseScore * 0.28
float bearQuality = effortScore * 0.38 + compressionScore * 0.34 + bearCloseScore * 0.28

bool enoughHistory = not na(volBase) and not na(spreadBase)
bool signalTimingOk = confirmedBarsOnly ? barstate.isconfirmed : true
bool effortOk = effortRatio >= effortThreshold
bool spreadOk = spreadRatio <= maxSpreadRatio
bool bullAbsorption = enoughHistory and signalTimingOk and effortOk and spreadOk and closeLocation >= strongCloseLocation and lowerWickShare >= minAbsorbedWick and bullQuality >= minQuality
bool bearAbsorption = enoughHistory and signalTimingOk and effortOk and spreadOk and closeLocation <= (1.0 - strongCloseLocation) and upperWickShare >= minAbsorbedWick and bearQuality >= minQuality

// -----------------------------------------------------------------------------
// Zone storage
// -----------------------------------------------------------------------------
var array<box> zoneBoxes = array.new<box>()
var array<line> zoneLines = array.new<line>()
var array<label> zoneBadges = array.new<label>()
var array<int> zoneSides = array.new<int>()
var array<int> zoneBirths = array.new<int>()
var array<int> zoneStatuses = array.new<int>()
var array<int> zoneResolvedBars = array.new<int>()
var array<int> zoneLastLabels = array.new<int>()
var array<float> zoneTops = array.new<float>()
var array<float> zoneBottoms = array.new<float>()
var array<float> zoneInvalidations = array.new<float>()
var array<float> zoneEfforts = array.new<float>()
var array<float> zoneCompressions = array.new<float>()
var array<float> zoneQualities = array.new<float>()
var array<label> eventLabels = array.new<label>()
var array<line> eventGuides = array.new<line>()
var int lastPrintedLabelBar = na

bool zoneDefended = false
bool zoneFailed = false

// -----------------------------------------------------------------------------
// Remove zones before their bar-index coordinates fall outside TradingView limits.
// -----------------------------------------------------------------------------
int staleZoneCount = array.size(zoneBoxes)
if staleZoneCount > 0
    int staleLimit = math.min(maxZoneMemoryBars, 9500)
    for staleLoop = 0 to staleZoneCount - 1
        int staleIdx = staleZoneCount - 1 - staleLoop
        int staleBirth = array.get(zoneBirths, staleIdx)
        bool staleZone = bar_index - staleBirth > staleLimit
        if staleZone
            box staleBox = array.get(zoneBoxes, staleIdx)
            line staleLine = array.get(zoneLines, staleIdx)
            label staleBadge = array.get(zoneBadges, staleIdx)
            box.delete(staleBox)
            line.delete(staleLine)
            label.delete(staleBadge)
            array.remove(zoneBoxes, staleIdx)
            array.remove(zoneLines, staleIdx)
            array.remove(zoneBadges, staleIdx)
            array.remove(zoneSides, staleIdx)
            array.remove(zoneBirths, staleIdx)
            array.remove(zoneStatuses, staleIdx)
            array.remove(zoneResolvedBars, staleIdx)
            array.remove(zoneLastLabels, staleIdx)
            array.remove(zoneTops, staleIdx)
            array.remove(zoneBottoms, staleIdx)
            array.remove(zoneInvalidations, staleIdx)
            array.remove(zoneEfforts, staleIdx)
            array.remove(zoneCompressions, staleIdx)
            array.remove(zoneQualities, staleIdx)

// -----------------------------------------------------------------------------
// Update active zones
// -----------------------------------------------------------------------------
int zoneCount = array.size(zoneBoxes)
if zoneCount > 0
    for idx = 0 to zoneCount - 1
        box activeBox = array.get(zoneBoxes, idx)
        line activeLine = array.get(zoneLines, idx)
        int sideNow = array.get(zoneSides, idx)
        int birthNow = array.get(zoneBirths, idx)
        int statusNow = array.get(zoneStatuses, idx)
        int resolvedBarNow = array.get(zoneResolvedBars, idx)
        int lastZoneLabel = array.get(zoneLastLabels, idx)
        float topNow = array.get(zoneTops, idx)
        float bottomNow = array.get(zoneBottoms, idx)
        float invalidationNow = array.get(zoneInvalidations, idx)
        int ageNow = bar_index - birthNow

        if statusNow == 0 and ageNow >= matureZoneAge
            statusNow := 2
            array.set(zoneStatuses, idx, statusNow)

        bool touchedZone = high >= bottomNow and low <= topNow
        bool failedZone = sideNow == 1 ? close < invalidationNow : close > invalidationNow
        bool defendedZone = sideNow == 1 ? touchedZone and close > topNow and close > open : touchedZone and close < bottomNow and close < open

        if bar_index > birthNow and failedZone and statusNow != -1
            statusNow := -1
            array.set(zoneStatuses, idx, statusNow)
            resolvedBarNow := bar_index
            array.set(zoneResolvedBars, idx, resolvedBarNow)
            zoneFailed := true
            if showLabels and (na(lastPrintedLabelBar) or bar_index - lastPrintedLabelBar >= labelCooldown) and (na(lastZoneLabel) or bar_index - lastZoneLabel >= labelCooldown)
                float failY = sideNow == 1 ? f_price_floor(low - safeAtr * labelOffsetAtr, low) : high + safeAtr * labelOffsetAtr
                float failAnchor = sideNow == 1 ? low : high
                f_push_event(eventLabels, eventGuides, bar_index, failAnchor, failY, "ZONE FAILED", color.new(neutralColor, 0), sideNow == 1, safeAtr * 0.9, labelSizeInput)
                array.set(zoneLastLabels, idx, bar_index)
                lastPrintedLabelBar := bar_index
        else if bar_index > birthNow and defendedZone and statusNow != 1 and statusNow != -1
            statusNow := 1
            array.set(zoneStatuses, idx, statusNow)
            resolvedBarNow := bar_index
            array.set(zoneResolvedBars, idx, resolvedBarNow)
            zoneDefended := true
            if showLabels and (na(lastPrintedLabelBar) or bar_index - lastPrintedLabelBar >= labelCooldown) and (na(lastZoneLabel) or bar_index - lastZoneLabel >= labelCooldown)
                float defenseY = sideNow == 1 ? f_price_floor(low - safeAtr * labelOffsetAtr, low) : high + safeAtr * labelOffsetAtr
                float defenseAnchor = sideNow == 1 ? low : high
                f_push_event(eventLabels, eventGuides, bar_index, defenseAnchor, defenseY, "ZONE DEFENDED", sideNow == 1 ? color.new(bullColor, 0) : color.new(bearColor, 0), sideNow == 1, safeAtr * 0.9, labelSizeInput)
                array.set(zoneLastLabels, idx, bar_index)
                lastPrintedLabelBar := bar_index

        bool zoneResolved = statusNow == 1 or statusNow == -1
        int resolvedEdge = na(resolvedBarNow) ? bar_index + resolvedTailBars : resolvedBarNow + resolvedTailBars
        int rawRightEdge = zoneResolved ? math.min(resolvedEdge, birthNow + zoneExtensionBars) : bar_index + zoneExtensionBars
        int rightEdge = f_right_edge(rawRightEdge)
        box.set_right(activeBox, rightEdge)
        box.set_bgcolor(activeBox, f_zone_color(sideNow, statusNow))
        box.set_border_color(activeBox, f_zone_border(sideNow, statusNow))
        line.set_x2(activeLine, rightEdge)
        line.set_color(activeLine, showInvalidationLines ? f_zone_border(sideNow, statusNow) : color.new(f_zone_border(sideNow, statusNow), 100))
        label activeBadge = array.get(zoneBadges, idx)
        int visibleRank = zoneCount - 1 - idx
        bool showThisBadge = showZoneBadges and maxVisibleZoneBadges > 0 and visibleRank < maxVisibleZoneBadges
        if showThisBadge
            int badgeX = f_mid_bar(box.get_left(activeBox), box.get_right(activeBox))
            float badgeY = f_zone_badge_y(topNow, bottomNow)
            color badgeBg = statusNow == -1 ? color.new(neutralColor, 18) : f_zone_border(sideNow, statusNow)
            label.set_x(activeBadge, badgeX)
            label.set_y(activeBadge, badgeY)
            label.set_text(activeBadge, f_zone_badge_text(sideNow, statusNow, array.get(zoneQualities, idx)))
            label.set_color(activeBadge, badgeBg)
            label.set_textcolor(activeBadge, f_text_on(badgeBg))
            label.set_size(activeBadge, f_size(labelSizeInput))
        else
            label.set_text(activeBadge, "")
            label.set_color(activeBadge, color.new(panelBg, 100))
            label.set_textcolor(activeBadge, color.new(panelBg, 100))

// -----------------------------------------------------------------------------
// Create new zones
// -----------------------------------------------------------------------------
bool newZone = bullAbsorption or bearAbsorption
if newZone
    int newSide = bullAbsorption ? 1 : -1
    float newTop = high
    float newBottom = low
    float newInvalidation = newSide == 1 ? f_price_floor(newBottom - safeAtr * invalidationAtrBuffer, newBottom) : newTop + safeAtr * invalidationAtrBuffer
    float newQuality = newSide == 1 ? bullQuality : bearQuality
    color newFill = newSide == 1 ? color.new(bullColor, 78) : color.new(bearColor, 78)
    color newBorder = newSide == 1 ? color.new(bullColor, 0) : color.new(bearColor, 0)
    int newRightEdge = f_right_edge(bar_index + zoneExtensionBars)
    int newBadgeX = f_mid_bar(bar_index, newRightEdge)
    float newBadgeY = f_zone_badge_y(newTop, newBottom)

    box newBox = box.new(left = bar_index, top = newTop, right = newRightEdge, bottom = newBottom, border_color = newBorder, border_width = 2, bgcolor = newFill)
    line newLine = line.new(x1 = bar_index, y1 = newInvalidation, x2 = newRightEdge, y2 = newInvalidation, color = showInvalidationLines ? newBorder : color.new(newBorder, 100), width = 1, style = line.style_dotted)
    bool newBadgeVisible = showZoneBadges and maxVisibleZoneBadges > 0
    label newBadge = label.new(newBadgeX, newBadgeY, newBadgeVisible ? f_zone_badge_text(newSide, 0, newQuality) : "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = newBadgeVisible ? f_text_on(newBorder) : color.new(panelBg, 100), color = newBadgeVisible ? newBorder : color.new(panelBg, 100), size = f_size(labelSizeInput))

    array.push(zoneBoxes, newBox)
    array.push(zoneLines, newLine)
    array.push(zoneBadges, newBadge)
    array.push(zoneSides, newSide)
    array.push(zoneBirths, bar_index)
    array.push(zoneStatuses, 0)
    array.push(zoneResolvedBars, na)
    array.push(zoneLastLabels, na)
    array.push(zoneTops, newTop)
    array.push(zoneBottoms, newBottom)
    array.push(zoneInvalidations, newInvalidation)
    array.push(zoneEfforts, effortScore)
    array.push(zoneCompressions, compressionScore)
    array.push(zoneQualities, newQuality)

while array.size(zoneBoxes) > maxActiveZones
    box oldBox = array.shift(zoneBoxes)
    line oldLine = array.shift(zoneLines)
    label oldBadge = array.shift(zoneBadges)
    array.shift(zoneSides)
    array.shift(zoneBirths)
    array.shift(zoneStatuses)
    array.shift(zoneResolvedBars)
    array.shift(zoneLastLabels)
    array.shift(zoneTops)
    array.shift(zoneBottoms)
    array.shift(zoneInvalidations)
    array.shift(zoneEfforts)
    array.shift(zoneCompressions)
    array.shift(zoneQualities)
    box.delete(oldBox)
    line.delete(oldLine)
    label.delete(oldBadge)

// Re-evaluate badge spacing from the current box geometry on every bar. Active
// and resolved boxes can move their horizontal centers after creation, so a
// creation-only preflight cannot prevent later superposition. Newer footprints
// win; an older colliding footprint is removed as one complete owned object.
int liveCollisionCount = array.size(zoneBoxes)
if showZoneBadges and maxVisibleZoneBadges > 0 and liveCollisionCount > 1
    int liveCollisionBars = f_badge_collision_bars(labelSizeInput)
    float liveCollisionPriceGap = safeAtr * f_badge_collision_atr(labelSizeInput)
    for oldLoop = 0 to liveCollisionCount - 2
        int oldIdx = liveCollisionCount - 2 - oldLoop
        int currentZoneCount = array.size(zoneBoxes)
        bool removeOld = false
        if oldIdx >= 0 and oldIdx < currentZoneCount - 1
            int oldRank = currentZoneCount - 1 - oldIdx
            bool oldBadgeVisible = oldRank < maxVisibleZoneBadges
            if oldBadgeVisible
                box oldCollisionBox = array.get(zoneBoxes, oldIdx)
                int oldCenterX = f_mid_bar(box.get_left(oldCollisionBox), box.get_right(oldCollisionBox))
                float oldCenterY = f_zone_badge_y(array.get(zoneTops, oldIdx), array.get(zoneBottoms, oldIdx))
                int newerLast = currentZoneCount - 1
                for newerIdx = oldIdx + 1 to newerLast
                    int newerRank = currentZoneCount - 1 - newerIdx
                    bool newerBadgeVisible = newerRank < maxVisibleZoneBadges
                    box newerCollisionBox = array.get(zoneBoxes, newerIdx)
                    int newerCenterX = f_mid_bar(box.get_left(newerCollisionBox), box.get_right(newerCollisionBox))
                    float newerCenterY = f_zone_badge_y(array.get(zoneTops, newerIdx), array.get(zoneBottoms, newerIdx))
                    bool liveXCollision = math.abs(oldCenterX - newerCenterX) <= liveCollisionBars
                    bool liveYCollision = math.abs(oldCenterY - newerCenterY) <= liveCollisionPriceGap
                    if newerBadgeVisible and liveXCollision and liveYCollision
                        removeOld := true
                if removeOld
                    box.delete(oldCollisionBox)
                    line.delete(array.get(zoneLines, oldIdx))
                    label.delete(array.get(zoneBadges, oldIdx))
                    array.remove(zoneBoxes, oldIdx)
                    array.remove(zoneLines, oldIdx)
                    array.remove(zoneBadges, oldIdx)
                    array.remove(zoneSides, oldIdx)
                    array.remove(zoneBirths, oldIdx)
                    array.remove(zoneStatuses, oldIdx)
                    array.remove(zoneResolvedBars, oldIdx)
                    array.remove(zoneLastLabels, oldIdx)
                    array.remove(zoneTops, oldIdx)
                    array.remove(zoneBottoms, oldIdx)
                    array.remove(zoneInvalidations, oldIdx)
                    array.remove(zoneEfforts, oldIdx)
                    array.remove(zoneCompressions, oldIdx)
                    array.remove(zoneQualities, oldIdx)

while array.size(eventLabels) > maxEventLabels
    label oldLabel = array.shift(eventLabels)
    line oldGuide = array.shift(eventGuides)
    label.delete(oldLabel)
    line.delete(oldGuide)

// -----------------------------------------------------------------------------
// Panel values
// -----------------------------------------------------------------------------
int panelSide = 0
int panelStatus = 0
int panelAge = 0
float panelEffort = na
float panelCompression = na
float panelFollowThrough = na
float panelQuality = na

int panelZoneCount = array.size(zoneBoxes)
if panelZoneCount > 0
    int lastIndex = panelZoneCount - 1
    panelSide := array.get(zoneSides, lastIndex)
    panelStatus := array.get(zoneStatuses, lastIndex)
    panelAge := bar_index - array.get(zoneBirths, lastIndex)
    panelEffort := array.get(zoneEfforts, lastIndex)
    panelCompression := array.get(zoneCompressions, lastIndex)
    panelQuality := array.get(zoneQualities, lastIndex)
    float lastTop = array.get(zoneTops, lastIndex)
    float lastBottom = array.get(zoneBottoms, lastIndex)
    float followRaw = panelSide == 1 ? (close - lastTop) / safeAtr : (lastBottom - close) / safeAtr
    panelFollowThrough := f_clamp(50.0 + followRaw * 40.0, 0.0, 100.0)

bool darkPanel = panelThemeInput == "Dark"
color activePanelBg = darkPanel ? panelBg : color.rgb(248, 250, 252)
color activeLabelCol = darkPanel ? panelLabelCol : color.rgb(71, 85, 105)
color activeValueCol = darkPanel ? panelValueCol : color.rgb(15, 23, 42)
color rowBg = darkPanel ? color.new(panelBg, 0) : color.rgb(248, 250, 252)
color altRowBg = darkPanel ? color.rgb(20, 31, 52) : color.rgb(241, 245, 249)
color blankCol = color.new(panelBg, 100)
string panelTitle = "AG Pro Volume Absorption Zones"
var table dashboard = table.new(f_position(panelLocationInput), 2, 7, bgcolor = activePanelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 1, 0)

if barstate.islast
    if showPanel
        table.cell(dashboard, 0, 0, panelTitle, text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = f_size(panelSizeInput), text_halign = text.align_center)
        table.cell(dashboard, 0, 1, "Absorption Side", text_color = activeLabelCol, bgcolor = rowBg, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 1, f_side(panelSide), text_color = panelSide == 1 ? bullColor : panelSide == -1 ? bearColor : activeValueCol, bgcolor = rowBg, text_size = f_size(panelSizeInput), text_halign = text.align_right)
        table.cell(dashboard, 0, 2, "Effort Score", text_color = activeLabelCol, bgcolor = altRowBg, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 2, f_pct(panelEffort), text_color = panelEffort >= 80.0 ? accentColor : activeValueCol, bgcolor = altRowBg, text_size = f_size(panelSizeInput), text_halign = text.align_right)
        table.cell(dashboard, 0, 3, "Spread Compression", text_color = activeLabelCol, bgcolor = rowBg, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 3, f_pct(panelCompression), text_color = panelCompression >= 80.0 ? neutralColor : activeValueCol, bgcolor = rowBg, text_size = f_size(panelSizeInput), text_halign = text.align_right)
        table.cell(dashboard, 0, 4, "Follow-through", text_color = activeLabelCol, bgcolor = altRowBg, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 4, f_pct(panelFollowThrough), text_color = panelFollowThrough >= 65.0 ? bullColor : panelFollowThrough <= 35.0 ? bearColor : activeValueCol, bgcolor = altRowBg, text_size = f_size(panelSizeInput), text_halign = text.align_right)
        table.cell(dashboard, 0, 5, "Zone Status", text_color = activeLabelCol, bgcolor = rowBg, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 5, f_status(panelStatus), text_color = panelStatus == 1 ? bullColor : panelStatus == -1 ? bearColor : panelStatus == 2 ? neutralColor : activeValueCol, bgcolor = rowBg, text_size = f_size(panelSizeInput), text_halign = text.align_right)
        table.cell(dashboard, 0, 6, "Zone Age", text_color = activeLabelCol, bgcolor = altRowBg, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 6, panelZoneCount > 0 ? str.tostring(panelAge) + " bars" : "n/a", text_color = panelQuality >= minQuality ? activeValueCol : panelLabelCol, bgcolor = altRowBg, text_size = f_size(panelSizeInput), text_halign = text.align_right)
    else
        table.cell(dashboard, 0, 0, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 0, 1, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 1, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 0, 2, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 2, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 0, 3, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 3, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 0, 4, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 4, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 0, 5, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 5, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 0, 6, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))
        table.cell(dashboard, 1, 6, "", text_color = blankCol, bgcolor = blankCol, text_size = f_size(panelSizeInput))

// -----------------------------------------------------------------------------
// Visuals and alerts
// -----------------------------------------------------------------------------
barcolor(colorAbsorptionBars and bullAbsorption ? color.new(bullColor, 35) : colorAbsorptionBars and bearAbsorption ? color.new(bearColor, 35) : na)

alertcondition(bullAbsorption, title = "Bullish Absorption Zone", message = "Bullish absorption zone detected on {{ticker}} {{interval}}.")
alertcondition(bearAbsorption, title = "Bearish Absorption Zone", message = "Bearish absorption zone detected on {{ticker}} {{interval}}.")
alertcondition(zoneDefended, title = "Absorption Zone Defended", message = "Absorption zone defense detected on {{ticker}} {{interval}}.")
alertcondition(zoneFailed, title = "Absorption Zone Failed", message = "Absorption zone failure detected on {{ticker}} {{interval}}.")
````
