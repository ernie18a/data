# Opening Range Failure Zones [AGPro Series]

- url: https://www.tradingview.com/script/y9779NQ9-Opening-Range-Failure-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;c26b6245678f420da28141125bbc7518
- version: 6.0

## Description

📌 Bollinger Walk Quality [AGPro Series]

Bollinger Walk Quality [AGPro Series] is built for one specific question: when price starts walking the outer Bollinger Band, is that walk strong enough to support continuation, or is the structure beginning to fail?

Many Bollinger Band tools focus on band touches, volatility contraction, width percentiles, or squeeze-style expansion setups. This script takes a different approach. It studies the behavior that comes after expansion: persistent upper-band or lower-band walking, directional pressure around the outer lane, pullback quality inside the band structure, and the point where the walk begins to lose control.

The goal is to make Bollinger Band continuation easier to read directly on the chart. Instead of treating every band touch as meaningful, the script scores whether price is staying in the correct outer lane, whether the Bollinger basis supports the active direction, whether pressure is persisting across multiple bars, and whether a pullback is holding in a healthy continuation pocket.

🧭 What The Script Measures

1. Walk Side
The panel identifies whether the active environment is an Upper Walk, Lower Walk, Cooling Walk, or Neutral state.

Upper Walk means price is persistently operating near the upper Bollinger lane while the basis supports upward continuation pressure.

Lower Walk means price is persistently operating near the lower Bollinger lane while the basis supports downward continuation pressure.

Cooling states appear when a recent walk is no longer fully active, but the script is still monitoring pullback quality and failure risk for a limited memory window.

2. Band Pressure
Band Pressure is a quality score for the active or developing walk. It combines outer-lane position, persistence, band contact behavior, basis slope support, and candle direction. A higher score means the walk has stronger structural pressure. A lower score means price is no longer showing durable outer-band control.

This keeps the script focused on continuation quality instead of simple band interaction. The chart can show a band touch, but the panel helps separate a weak touch from a real band-walk environment.

3. Pullback Quality
Healthy band walks often reset toward the middle of the Bollinger structure before continuing. Bollinger Walk Quality tracks that reset through a concept-native pullback pocket.

The pullback pocket is not a generic support or resistance rectangle. It is projected from the current Bollinger structure and represents the area where a band walk can cool off while still keeping its continuation profile intact.

The panel can show states such as Awaiting Pullback, Testing Pocket, Clean Hold, or Weak Reset. This helps distinguish a controlled continuation reset from a walk that is losing quality.

4. Failure Risk
Failure Risk is designed to catch the moment when an active or recently active band walk starts to break down. It rises when price loses the outer lane, pressure falls, the basis slope weakens, or price begins to threaten the Bollinger basis.

The failure label is intentionally restrained. It appears only on fresh failure events, so the chart remains clean and readable instead of filling with repeated warnings.

🎯 Core Features

- Outer-band walk detection for upper and lower Bollinger continuation phases
- Band pressure scoring based on lane position, persistence, slope support, and band contact behavior
- Pullback-to-band quality state for continuation resets
- Projected pullback pockets that show where a healthy walk can reset without losing structure
- Failure warning labels when the active walk loses pressure or threatens the basis
- Clean AG Pro panel with walk side, band pressure, pullback quality, and failure risk
- Adjustable panel location, theme, font sizes, label spacing, label clearance, zone projection, and visual density

📊 Visual Design

The default view is designed for a clean public TradingView chart.

The script displays Bollinger Bands, highlights the active walk track, projects a limited number of pullback zones, and uses event labels with spacing controls. Labels are anchored outside the local candle envelope so they do not disappear inside candles or cover important price action.

The chart remains active enough to be visually informative, but the object count and label density are controlled by default. This keeps the indicator suitable for repeated use across different symbols and timeframes.

🧩 Panel

The AG Pro panel summarizes the current state in four compact rows:

- Walk Side
- Band Pressure
- Pullback Quality
- Failure Risk

Panel location, panel theme, panel font size, label font size, label spacing, label clearance, zone projection, zone opacity, and object limits are all adjustable from the settings menu.

🔎 How This Is Different

Bollinger Walk Quality is not a squeeze map and does not rely on compression logic. It does not use Keltner confirmation, volatility percentile ranking, or width contraction states.

Its lane is continuation after expansion:

- Is price walking the band?
- Which side controls the walk?
- Is the walk supported by pressure and basis slope?
- Is the pullback still healthy?
- Is the walk beginning to fail?

That makes it a separate Bollinger Band workflow from squeeze-focused tools. It is designed for traders who want to evaluate trend continuation rhythm, pullback behavior, and outer-band pressure in a more structured way.

✅ Best Use Cases

- Studying Bollinger Band walk continuation
- Reviewing trend pressure after expansion
- Identifying controlled pullbacks inside active band-walk environments
- Monitoring when a walk is cooling or losing quality
- Comparing upper-band and lower-band pressure across market phases
- Keeping Bollinger Band continuation analysis clean and visual

⚙️ Settings Overview

Engine settings control the Bollinger length, multiplier, source, basis slope lookback, and ATR normalization.

Band Walk Logic settings control the outer-lane depth, minimum walk persistence, minimum walk score, pullback memory, and failure warning threshold.

Visual settings control Bollinger Bands, walk highlight, pullback zones, event labels, label spacing, label count, label offset, label clearance, and label font size.

Pullback Zone settings control zone projection length, maximum visible zones, and opacity.

Panel settings control the information panel, location, theme, and font size.

🏁 Design Intent

Bollinger Walk Quality [AGPro Series] is designed to make Bollinger Band continuation more readable without turning the chart into a crowded signal dashboard.

The script focuses on structure, persistence, pullback quality, and failure behavior. It gives the chart a clear visual rhythm while keeping the panel concise and the labels controlled.

This makes the script useful as a premium public Bollinger continuation tool and keeps it clearly differentiated from Bollinger squeeze, compression, and volatility expansion maps.

## Source Code

````pine
// -------------------------------------------------
// Opening Range Failure Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6.1
//
// Opening Range Failure Zones maps failed opening range breakouts, session
// trap behavior, reclaim quality, ATR volatility context, and cooldown states.
// It keeps the Opening Range as the primary reference structure, then highlights
// failed upside and downside probes with centered reclaim zones, premium labels,
// and a compact AG Pro panel for intraday opening range failure analysis.
// Version 1.6.1 refines panel workflow hierarchy and terminology so active,
// completed, lost, cooldown, and watch states remain semantically consistent
// with the failure-side and reclaim-status rows. Analytical logic is unchanged.
// -------------------------------------------------

//@version=6
indicator("Opening Range Failure Zones [AGPro Series]",
     shorttitle       = "ORF",
     overlay          = true,
     max_boxes_count  = 60,
     max_labels_count = 100,
     max_lines_count  = 30,
     max_bars_back    = 700)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgD      = color.rgb(15, 23, 42)
panelBorderD  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelValueD   = color.rgb(226, 232, 240)
panelBgL      = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(203, 213, 225)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupSession = "Session"
groupEngine = "Failure Engine"
groupVisual = "Visuals"
groupPanel = "Panel"
groupProof = "Proof"
groupAlerts = "Alerts"

enginePreset = input.string("15m Intraday", "Engine Preset", options = ["15m Intraday", "5m Active", "Custom"], group = groupSession,
     tooltip = "Selects the behavior profile. 15m Intraday is the clean publication default. 5m Active keeps more frequent intraday trap mapping. Custom uses the raw inputs below.")
sessionLabel = input.string("Daily OR", "Session Label", group = groupSession,
     tooltip = "Short label shown in the panel for the active opening range model.")
rangeMode = input.string("First Bars Of Day", "Opening Range Mode", options = ["First Bars Of Day", "Session Window"], group = groupSession,
     tooltip = "Controls whether the Opening Range is built from the first chart bars of each day or from an exact intraday session window.")
openingRangeBars = input.int(1, "Opening Range Bars", minval = 1, maxval = 12, group = groupSession,
     tooltip = "Number of chart bars used to build the Opening Range when First Bars Of Day mode is selected.")
orSession = input.session("0930-0945", "Opening Range Session", group = groupSession,
     tooltip = "Defines the exact time window used to build the locked Opening Range when Session Window mode is selected.")
trackSession = input.session("0930-1600", "Failure Tracking Session", group = groupSession,
     tooltip = "Defines the session window during which failed opening range breaks can be tracked when Session Window mode is selected.")
sessionTimezone = input.string("America/New_York", "Session Timezone", options = ["America/New_York", "Etc/UTC", "Europe/London", "Europe/Istanbul", "Asia/Tokyo"], group = groupSession,
     tooltip = "Timezone used by the Opening Range and failure tracking sessions.")
failureWatchBars = input.int(64, "Failure Watch Bars", minval = 5, maxval = 500, group = groupSession,
     tooltip = "Maximum number of bars after the Opening Range locks during which failure events can be detected.")

atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine,
     tooltip = "ATR length used to normalize break depth, reclaim buffers, label offsets, and zone padding.")
atrBaselineLength = input.int(55, "ATR Baseline Length", minval = 10, maxval = 300, group = groupEngine,
     tooltip = "ATR baseline used to classify the current context as active, cooldown, noisy, quiet, or balanced.")
breakBufferAtr = input.float(0.08, "Break Buffer ATR", minval = 0.0, maxval = 2.0, step = 0.01, group = groupEngine,
     tooltip = "Minimum ATR-scaled penetration beyond the Opening Range boundary required to start a failure watch.")
reclaimBufferAtr = input.float(0.03, "Reclaim Buffer ATR", minval = 0.0, maxval = 1.0, step = 0.01, group = groupEngine,
     tooltip = "ATR-scaled buffer required for price to close back inside the Opening Range after a break attempt.")
reclaimWindowBars = input.int(12, "Reclaim Window Bars", minval = 1, maxval = 80, group = groupEngine,
     tooltip = "Maximum number of bars allowed between the outside probe and the reclaim close.")
maxFailureDepthAtr = input.float(1.25, "Maximum Failure Depth ATR", minval = 0.10, maxval = 6.0, step = 0.05, group = groupEngine,
     tooltip = "Outside moves deeper than this ATR multiple are treated as expanded breaks unless they reclaim quickly with enough quality.")
minFailureScore = input.int(58, "Minimum Failure Quality", minval = 1, maxval = 100, group = groupEngine,
     tooltip = "Minimum 0-100 quality score required before a failed opening range event is printed.")
useVolumeScore = input.bool(true, "Use Relative Volume In Score", group = groupEngine,
     tooltip = "Adds relative volume context to the failure quality score when volume data is available.")
volumeLength = input.int(20, "Relative Volume Length", minval = 2, maxval = 200, group = groupEngine,
     tooltip = "Lookback used to compare current volume against recent average participation.")

showOrBox = input.bool(true, "Show Opening Range Box", group = groupVisual,
     tooltip = "Displays the locked Opening Range as the main session reference box.")
showMidline = input.bool(true, "Show Opening Range Midline", group = groupVisual,
     tooltip = "Shows the midpoint of the active Opening Range for fade and reclaim state context.")
showFailureZones = input.bool(true, "Show Reclaim Zones", group = groupVisual,
     tooltip = "Draws a rectangle between the failed break extreme and the reclaimed Opening Range boundary.")
showZoneLabels = input.bool(true, "Show Centered Zone Labels", group = groupVisual,
     tooltip = "Places premium labels in the vertical and horizontal center of Opening Range and failed-break reclaim zones.")
showFailureMarkers = input.bool(false, "Show Extra Failed Break Markers", group = groupVisual,
     tooltip = "Prints additional event labels when a failed opening range break passes the quality threshold. Disabled by default because centered reclaim-zone labels already identify the main event.")
showProbeMarkers = input.bool(false, "Show Probe Watch Markers", group = groupVisual,
     tooltip = "Prints optional watch markers when price probes beyond the Opening Range before reclaim confirmation. Disabled by default to avoid stacked labels.")
probeCooldownBars = input.int(28, "Probe Marker Cooldown Bars", minval = 5, maxval = 200, group = groupVisual,
     tooltip = "Minimum spacing between optional probe markers. This only applies when Probe Watch Markers are enabled.")
orExtendBars = input.int(96, "OR Box Extension Bars", minval = 10, maxval = 600, group = groupVisual,
     tooltip = "Number of bars used to extend the locked Opening Range box to the right.")
zoneExtendBars = input.int(48, "Reclaim Zone Extension Bars", minval = 10, maxval = 400, group = groupVisual,
     tooltip = "Number of bars used to extend each failed break reclaim zone after confirmation.")
maxHistoricalSessions = input.int(3, "Max Historical OR Boxes", minval = 1, maxval = 20, group = groupVisual,
     tooltip = "Limits the number of prior Opening Range boxes retained on the chart.")
maxFailureZones = input.int(4, "Max Reclaim Zones", minval = 1, maxval = 25, group = groupVisual,
     tooltip = "Limits the number of failed break reclaim zones retained on the chart.")
labelCooldownBars = input.int(22, "Label Cooldown Bars", minval = 0, maxval = 100, group = groupVisual,
     tooltip = "Minimum spacing in bars between printed failure labels to keep the chart readable.")
maxEventLabels = input.int(6, "Max Event Labels", minval = 1, maxval = 40, group = groupVisual,
     tooltip = "Maximum number of failed break and probe labels retained on the chart.")
labelOffsetAtr = input.float(0.62, "Label Offset ATR", minval = 0.05, maxval = 3.0, step = 0.05, group = groupVisual,
     tooltip = "ATR-scaled vertical offset used to keep failure labels clear of candle bodies and wicks.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual,
     tooltip = "Controls the font size of failed break event labels and centered zone badges.")
bullZoneColor = input.color(color.rgb(34, 197, 166), "Downside Failure Color", group = groupVisual,
     tooltip = "Color used when a downside Opening Range probe fails and reclaims back inside.")
bearZoneColor = input.color(color.rgb(244, 114, 182), "Upside Failure Color", group = groupVisual,
     tooltip = "Color used when an upside Opening Range probe fails and fades back inside.")

showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Displays the compact AG Pro state panel with workflow, volatility state, failure side, quality, and reclaim context.")
panelPositionInput = input.string("Top Right", "Panel Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = groupPanel,
     tooltip = "Controls where the AG Pro state panel is placed on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Controls the panel color theme while preserving the AGPro blue header row.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Controls the panel text size. Normal is the default for balanced chart readability.")
panelMemoryBars = input.int(120, "Panel Memory Bars", minval = 10, maxval = 500, group = groupPanel,
     tooltip = "Controls how long the panel keeps the last failed opening range event visible after the active state resolves.")

showProof = input.bool(true, "Show Proof Layer", group = groupProof,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across failed opening range breaks on the current symbol and timeframe. Follow means a failed break faded one risk unit (1R) back toward the range midline before the failed-break extreme was exceeded again. These are historical outcome rates, not predictions.")
proofHorizonBars = input.int(32, "Proof Horizon Bars", minval = 5, maxval = 300, group = groupProof,
     tooltip = "Maximum number of bars each failed break is tracked for the proof measurement before it resolves at its current outcome.")
reactBars = input.int(4, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof,
     tooltip = "Number of bars after a failure is confirmed used to detect an immediate favorable fade reaction.")
reactProgressPct = input.float(33.0, "Reaction Progress %", minval = 5.0, maxval = 80.0, step = 1.0, group = groupProof,
     tooltip = "Minimum favorable fade progress toward the 1R target, within the reaction window, required to count as an early React.")

alertUpsideFailure = input.bool(true, "Alert on Upside Failure", group = groupAlerts,
     tooltip = "Enables alerts when an upside Opening Range break fails and reclaims back inside.")
alertDownsideFailure = input.bool(true, "Alert on Downside Failure", group = groupAlerts,
     tooltip = "Enables alerts when a downside Opening Range break fails and reclaims back inside.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string positionName) =>
    switch positionName
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : panelBgL) : (alt ? color.rgb(24, 35, 55) : panelBgD)

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_trim_boxes(array<box> idArray, int limit) =>
    while array.size(idArray) > limit
        box oldBox = array.shift(idArray)
        if not na(oldBox)
            box.delete(oldBox)

f_trim_or_pairs(array<box> boxArray, array<label> labelArray, int limit) =>
    while array.size(boxArray) > limit
        box oldBox = array.shift(boxArray)
        if not na(oldBox)
            box.delete(oldBox)
        label oldLabel = array.size(labelArray) > 0 ? array.shift(labelArray) : na
        if not na(oldLabel)
            label.delete(oldLabel)
    while array.size(labelArray) > array.size(boxArray)
        label extraLabel = array.shift(labelArray)
        if not na(extraLabel)
            label.delete(extraLabel)

f_trim_failure_pairs(array<box> boxArray, array<label> labelArray, int limit) =>
    while array.size(boxArray) > limit
        box oldBox = array.shift(boxArray)
        if not na(oldBox)
            box.delete(oldBox)
        label oldLabel = array.size(labelArray) > 0 ? array.shift(labelArray) : na
        if not na(oldLabel)
            label.delete(oldLabel)
    while array.size(labelArray) > array.size(boxArray)
        label extraLabel = array.shift(labelArray)
        if not na(extraLabel)
            label.delete(extraLabel)

f_trim_lines(array<line> idArray, int limit) =>
    while array.size(idArray) > limit
        line oldLine = array.shift(idArray)
        if not na(oldLine)
            line.delete(oldLine)

f_trim_labels(array<label> idArray, int limit) =>
    while array.size(idArray) > limit
        label oldLabel = array.shift(idArray)
        if not na(oldLabel)
            label.delete(oldLabel)

f_quality_color(float score) =>
    na(score) ? panelValueD : score >= 75.0 ? bullColor : score >= 58.0 ? neutralColor : panelLabelD

f_vol_color(string modeText) =>
    modeText == "Active ATR" ? bullColor :
     modeText == "Cooldown ATR" ? accentColor :
     modeText == "Noisy ATR" ? bearColor :
     modeText == "Quiet ATR" ? neutralColor :
     accentColor

f_failure_quality(int dir, float extremePrice, float boundaryPrice, float closePrice, float openPrice,
     float highPrice, float lowPrice, int barsToReclaim, int outsideCloses, float atrValue,
     float orSpanValue, float relVolume, bool includeVolume) =>
    float depth = dir == 1 ? extremePrice - boundaryPrice : boundaryPrice - extremePrice
    float depthAtr = atrValue > 0.0 ? depth / atrValue : 0.0
    float depthScore = f_clamp(100.0 - math.abs(depthAtr - 0.42) * 85.0, 0.0, 100.0)
    float barSpan = math.max(highPrice - lowPrice, syminfo.mintick)
    float upperWick = highPrice - math.max(openPrice, closePrice)
    float lowerWick = math.min(openPrice, closePrice) - lowPrice
    float wickScore = dir == 1 ? f_clamp((upperWick / barSpan) * 145.0, 0.0, 100.0) : f_clamp((lowerWick / barSpan) * 145.0, 0.0, 100.0)
    float insideDistance = dir == 1 ? boundaryPrice - closePrice : closePrice - boundaryPrice
    float reclaimScore = f_clamp(insideDistance / math.max(orSpanValue * 0.35, syminfo.mintick) * 100.0, 0.0, 100.0)
    float speedScore = f_clamp(100.0 - barsToReclaim * 8.0, 0.0, 100.0)
    float outsideScore = f_clamp(100.0 - outsideCloses * 18.0, 0.0, 100.0)
    float volumeScore = f_clamp(relVolume / 1.35 * 100.0, 0.0, 100.0)
    float baseScore = depthScore * 0.20 + wickScore * 0.25 + reclaimScore * 0.25 + speedScore * 0.20 + outsideScore * 0.10
    includeVolume ? baseScore * 0.86 + volumeScore * 0.14 : baseScore

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, panelTextSize) =>
    color bg = f_panel_bg(isLight, row % 2 == 0)
    color labelCol = isLight ? panelLabelL : panelLabelD
    table.cell(target, 0, row, leftText, text_color = labelCol, bgcolor = bg, text_size = panelTextSize, text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = bg, text_size = panelTextSize, text_halign = text.align_right)

// -------------------------------------------------
// Preset Resolution
// -------------------------------------------------
bool activePreset = enginePreset == "5m Active"
int usedFailureWatchBars = activePreset ? math.max(failureWatchBars, 96) : failureWatchBars
int usedLabelCooldown = activePreset ? math.min(labelCooldownBars, 10) : labelCooldownBars
int usedMaxFailureZones = activePreset ? math.min(maxFailureZones, 8) : maxFailureZones
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))

chartSeconds = timeframe.in_seconds(timeframe.period)
bool mapTimeframeOk = timeframe.isintraday and not na(chartSeconds) and chartSeconds >= 300 and chartSeconds <= 1800
bool aboveBestView = not mapTimeframeOk
string bestViewText = aboveBestView ? "Use 15m" : activePreset ? "5m / 15m" : "15m chart"

// -------------------------------------------------
// Session State
// -------------------------------------------------
bool useFirstBarsMode = rangeMode == "First Bars Of Day"
bool inSessionWindow = not na(time(timeframe.period, orSession, sessionTimezone))
bool inTrackWindow = not na(time(timeframe.period, trackSession, sessionTimezone))
dailyStamp = time("D", "0000-2359", sessionTimezone)
bool newDailyRange = barstate.isfirst or ta.change(dailyStamp) != 0
bool wasInSessionWindow = bar_index > 0 ? inSessionWindow[1] : false
bool sessionRangeStarted = not useFirstBarsMode and inSessionWindow and not wasInSessionWindow
bool sessionRangeEnded = not useFirstBarsMode and not inSessionWindow and wasInSessionWindow

int engineWarmup = math.max(atrBaselineLength, volumeLength) + atrLength + 5
bool engineReady = bar_index > engineWarmup
bool proofConfirmedBar = barstate.isconfirmed

float atrValue = ta.atr(atrLength)
float atrSafe = math.max(nz(atrValue, 0.0), syminfo.mintick)
float atrBase = ta.sma(atrSafe, atrBaselineLength)
float atrRatio = not na(atrBase) and atrBase > 0.0 ? atrSafe / atrBase : 1.0
float volumeAverage = ta.sma(volume, volumeLength)
float relativeVolume = not na(volumeAverage) and volumeAverage > 0.0 ? volume / volumeAverage : 1.0

var float orHigh = na
var float orLow = na
var int orStartBar = na
var int orEndBar = na
var bool rangeLocked = false
var int firstBarsBuilt = 0

bool dailyRangeStarted = useFirstBarsMode and newDailyRange
bool dailyRangeContinues = useFirstBarsMode and not dailyRangeStarted and firstBarsBuilt > 0 and firstBarsBuilt < openingRangeBars
bool orStarted = sessionRangeStarted or dailyRangeStarted
bool inOrSession = useFirstBarsMode ? dailyRangeStarted or dailyRangeContinues : inSessionWindow
bool inTrackSession = useFirstBarsMode ? true : inTrackWindow
bool dailyLockNow = false

var int attemptDir = 0
var int attemptBar = na
var float attemptExtreme = na
var int outsideCloseCount = 0
var int lastProbeBar = na
var int lastProbeDir = 0

var int activeFailureDir = 0
var int activeFailureStartBar = na
var float activeFailureExtreme = na
var float activeFailureTop = na
var float activeFailureBottom = na
var box activeFailureBox = na
var int lastFailureBar = na
var float lastFailureScore = na
var string lastFailureSide = "None"
var int lastPanelEventBar = na
var string reclaimStatus = "Waiting"
var bool upsideFailurePrinted = false
var bool downsideFailurePrinted = false

var box activeOrBox = na
var line activeMidLine = na
var label activeOrLabel = na
var label activeFailureLabel = na
var array<box> orBoxes = array.new<box>()
var array<line> midLines = array.new<line>()
var array<label> orLabels = array.new<label>()
var array<box> failureBoxes = array.new<box>()
var array<label> zoneLabels = array.new<label>()
var array<label> eventLabels = array.new<label>()

bool upsideFailureEvent = false
bool downsideFailureEvent = false
labelSize = f_size(labelSizeInput)
panelSize = f_size(panelFontSizeInput)

// -------------------------------------------------
// Opening Range Construction
// -------------------------------------------------
if orStarted
    if useFirstBarsMode and not na(activeOrBox)
        box.set_right(activeOrBox, bar_index - 1)
    if useFirstBarsMode and not na(activeMidLine)
        line.set_x2(activeMidLine, bar_index - 1)
    if useFirstBarsMode and not na(activeFailureBox)
        box.set_right(activeFailureBox, bar_index - 1)
    orHigh := high
    orLow := low
    orStartBar := bar_index
    orEndBar := na
    rangeLocked := false
    firstBarsBuilt := useFirstBarsMode ? 1 : 0
    attemptDir := 0
    attemptBar := na
    attemptExtreme := na
    outsideCloseCount := 0
    lastProbeBar := na
    lastProbeDir := 0
    activeFailureDir := 0
    activeFailureStartBar := na
    activeFailureExtreme := na
    activeFailureTop := na
    activeFailureBottom := na
    activeFailureBox := na
    activeFailureLabel := na
    lastFailureScore := na
    lastFailureSide := "None"
    reclaimStatus := "Build OR"
    upsideFailurePrinted := false
    downsideFailurePrinted := false
    if showOrBox and mapTimeframeOk
        activeOrBox := box.new(bar_index, high, bar_index, low, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 90), border_color = color.new(accentColor, 28), border_width = 1)
        array.push(orBoxes, activeOrBox)
    else
        activeOrBox := na
    if showMidline and mapTimeframeOk
        activeMidLine := line.new(bar_index, hl2, bar_index, hl2, xloc = xloc.bar_index, color = color.new(neutralColor, 15), style = line.style_dotted, width = 1)
        array.push(midLines, activeMidLine)
        f_trim_lines(midLines, maxHistoricalSessions)
    else
        activeMidLine := na
    if showZoneLabels and showOrBox and mapTimeframeOk
        activeOrLabel := label.new(bar_index, hl2, sessionLabel, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 0), textcolor = headerText, size = labelSize, textalign = text.align_center)
        array.push(orLabels, activeOrLabel)
        f_trim_or_pairs(orBoxes, orLabels, maxHistoricalSessions)
    else
        activeOrLabel := na
        if showOrBox and mapTimeframeOk
            f_trim_boxes(orBoxes, maxHistoricalSessions)

if inOrSession
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)
    float liveMid = (orHigh + orLow) * 0.5
    if not na(activeOrBox)
        box.set_right(activeOrBox, bar_index)
        box.set_top(activeOrBox, orHigh)
        box.set_bottom(activeOrBox, orLow)
    if not na(activeMidLine)
        line.set_x2(activeMidLine, bar_index)
        line.set_y1(activeMidLine, liveMid)
        line.set_y2(activeMidLine, liveMid)
    if not na(activeOrLabel)
        int liveOrStart = nz(orStartBar, bar_index)
        int liveOrLabelX = liveOrStart + int(math.round((bar_index - liveOrStart) * 0.72))
        label.set_xy(activeOrLabel, liveOrLabelX, liveMid)
        label.set_size(activeOrLabel, labelSize)
    if useFirstBarsMode and not dailyRangeStarted
        firstBarsBuilt += 1
    dailyLockNow := useFirstBarsMode and firstBarsBuilt >= openingRangeBars

if (sessionRangeEnded or dailyLockNow) and not na(orHigh) and not na(orLow)
    rangeLocked := true
    orEndBar := useFirstBarsMode ? bar_index : bar_index - 1
    float lockedMid = (orHigh + orLow) * 0.5
    if not na(activeOrBox)
        box.set_right(activeOrBox, bar_index + orExtendBars)
        box.set_top(activeOrBox, orHigh)
        box.set_bottom(activeOrBox, orLow)
    if not na(activeMidLine)
        line.set_x2(activeMidLine, bar_index + orExtendBars)
        line.set_y1(activeMidLine, lockedMid)
        line.set_y2(activeMidLine, lockedMid)
    if not na(activeOrLabel)
        int lockedOrStart = nz(orStartBar, bar_index)
        int lockedOrRight = bar_index + orExtendBars
        int lockedOrLabelX = lockedOrStart + int(math.round((lockedOrRight - lockedOrStart) * 0.74))
        label.set_xy(activeOrLabel, lockedOrLabelX, lockedMid)
        label.set_text(activeOrLabel, sessionLabel)
        label.set_color(activeOrLabel, color.new(accentColor, 4))
        label.set_textcolor(activeOrLabel, headerText)
        label.set_size(activeOrLabel, labelSize)
    reclaimStatus := "Range Locked"

float orSpan = not na(orHigh) and not na(orLow) ? math.max(orHigh - orLow, syminfo.mintick) : na
float orMid = not na(orHigh) and not na(orLow) ? (orHigh + orLow) * 0.5 : na
int barsAfterLock = rangeLocked and not na(orEndBar) ? bar_index - orEndBar : 100000
bool trackingActive = engineReady and mapTimeframeOk and rangeLocked and inTrackSession and not inOrSession and barsAfterLock >= 0 and barsAfterLock <= usedFailureWatchBars
float breakBuffer = atrSafe * breakBufferAtr
float reclaimBuffer = atrSafe * reclaimBufferAtr

// -------------------------------------------------
// Failure Detection
// -------------------------------------------------
if trackingActive and attemptDir == 0 and not na(orHigh) and not na(orLow)
    float upsideDepth = high - orHigh
    float downsideDepth = orLow - low
    bool upsideProbe = upsideDepth > breakBuffer and not upsideFailurePrinted
    bool downsideProbe = downsideDepth > breakBuffer and not downsideFailurePrinted
    bool canProbeMarker = showProbeMarkers and (na(lastProbeBar) or bar_index - lastProbeBar >= probeCooldownBars)
    if upsideProbe and upsideDepth >= downsideDepth
        attemptDir := 1
        attemptBar := bar_index
        attemptExtreme := high
        outsideCloseCount := close > orHigh ? 1 : 0
        reclaimStatus := "Upside Probe"
        if canProbeMarker and lastProbeDir != 1
            label probeLabel = label.new(bar_index, high + atrSafe * labelOffsetAtr, "Probe", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(bearZoneColor, 28), textcolor = headerText, size = labelSize)
            array.push(eventLabels, probeLabel)
            f_trim_labels(eventLabels, maxEventLabels)
            lastProbeBar := bar_index
            lastProbeDir := 1
    else if downsideProbe
        attemptDir := -1
        attemptBar := bar_index
        attemptExtreme := low
        outsideCloseCount := close < orLow ? 1 : 0
        reclaimStatus := "Downside Probe"
        if canProbeMarker and lastProbeDir != -1
            label probeLabel = label.new(bar_index, low - atrSafe * labelOffsetAtr, "Probe", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(bullZoneColor, 28), textcolor = headerText, size = labelSize)
            array.push(eventLabels, probeLabel)
            f_trim_labels(eventLabels, maxEventLabels)
            lastProbeBar := bar_index
            lastProbeDir := -1

if trackingActive and attemptDir != 0 and not na(attemptBar) and not na(orSpan)
    int barsInAttempt = bar_index - attemptBar
    float boundaryPrice = attemptDir == 1 ? orHigh : orLow
    attemptExtreme := attemptDir == 1 ? math.max(attemptExtreme, high) : math.min(attemptExtreme, low)
    if barstate.isconfirmed and bar_index > attemptBar
        outsideCloseCount += attemptDir == 1 and close > boundaryPrice ? 1 : attemptDir == -1 and close < boundaryPrice ? 1 : 0
    float depthFromBoundary = attemptDir == 1 ? attemptExtreme - boundaryPrice : boundaryPrice - attemptExtreme
    bool reclaimedInside = attemptDir == 1 ? close < boundaryPrice - reclaimBuffer : close > boundaryPrice + reclaimBuffer
    bool expandedTooFar = depthFromBoundary > atrSafe * maxFailureDepthAtr and not reclaimedInside
    bool attemptExpired = barsInAttempt > reclaimWindowBars
    if reclaimedInside and barstate.isconfirmed
        float failureScore = f_failure_quality(attemptDir, attemptExtreme, boundaryPrice, close, open, high, low, barsInAttempt, outsideCloseCount, atrSafe, orSpan, relativeVolume, useVolumeScore)
        bool markerCooldownReady = na(lastFailureBar) or bar_index - lastFailureBar >= usedLabelCooldown
        bool scoreReady = failureScore >= minFailureScore

        // Label cooldown must never suppress a valid failure event, its zone,
        // panel state, Proof sample, or alert. It applies only to optional
        // standalone event markers.
        if scoreReady
            lastFailureBar := bar_index
            lastPanelEventBar := bar_index
            lastFailureScore := failureScore
            lastFailureSide := attemptDir == 1 ? "Upside Failure" : "Downside Failure"
            activeFailureDir := attemptDir
            activeFailureStartBar := attemptBar
            activeFailureExtreme := attemptExtreme
            reclaimStatus := attemptDir == 1 ? "Fade Active" : "Reclaim Active"

            if attemptDir == 1
                upsideFailurePrinted := true
                upsideFailureEvent := true
            else
                downsideFailurePrinted := true
                downsideFailureEvent := true

            if showFailureZones
                float zoneTop = attemptDir == 1 ? attemptExtreme : boundaryPrice
                float zoneBottom = attemptDir == 1 ? boundaryPrice : attemptExtreme
                color zoneColor = attemptDir == 1 ? bearZoneColor : bullZoneColor
                string zoneText = attemptDir == 1 ? "UP FAIL\nQ " + str.tostring(math.round(failureScore)) : "DOWN FAIL\nQ " + str.tostring(math.round(failureScore))

                activeFailureTop := zoneTop
                activeFailureBottom := zoneBottom
                activeFailureBox := box.new(
                     attemptBar,
                     zoneTop,
                     bar_index + zoneExtendBars,
                     zoneBottom,
                     xloc = xloc.bar_index,
                     bgcolor = color.new(zoneColor, 85),
                     border_color = color.new(zoneColor, 18),
                     border_width = 1)

                activeFailureLabel := na
                if showZoneLabels
                    float labelPct = attemptDir == 1 ? 0.28 : 0.72
                    int failureLabelX = attemptBar + int(math.round((bar_index + zoneExtendBars - attemptBar) * labelPct))
                    float centerY = (zoneTop + zoneBottom) * 0.5
                    float zoneHeight = math.max(zoneTop - zoneBottom, syminfo.mintick)
                    float labelNudge = math.min(zoneHeight * 0.18, atrSafe * 0.12)
                    float failureLabelY = centerY + (attemptDir == 1 ? labelNudge : -labelNudge)
                    activeFailureLabel := label.new(
                         failureLabelX,
                         failureLabelY,
                         zoneText,
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = label.style_label_center,
                         color = color.new(zoneColor, 0),
                         textcolor = headerText,
                         size = labelSize,
                         textalign = text.align_center)

                array.push(failureBoxes, activeFailureBox)
                array.push(zoneLabels, activeFailureLabel)
                f_trim_failure_pairs(failureBoxes, zoneLabels, usedMaxFailureZones)

            if showFailureMarkers and markerCooldownReady
                float markerY = attemptDir == 1 ? high + atrSafe * labelOffsetAtr : low - atrSafe * labelOffsetAtr
                string markerText = attemptDir == 1 ? "Up Fail " + str.tostring(math.round(failureScore)) : "Down Fail " + str.tostring(math.round(failureScore))
                label eventLabel = label.new(
                     bar_index,
                     markerY,
                     markerText,
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     style = attemptDir == 1 ? label.style_label_down : label.style_label_up,
                     color = color.new(attemptDir == 1 ? bearZoneColor : bullZoneColor, 0),
                     textcolor = headerText,
                     size = labelSize,
                     textalign = text.align_center)
                array.push(eventLabels, eventLabel)
                f_trim_labels(eventLabels, maxEventLabels)
        else
            reclaimStatus := "Weak Reclaim"

        attemptDir := 0
        attemptBar := na
        attemptExtreme := na
        outsideCloseCount := 0
    else if expandedTooFar
        reclaimStatus := attemptDir == 1 ? "Upside Holds" : "Downside Holds"
        attemptDir := 0
        attemptBar := na
        attemptExtreme := na
        outsideCloseCount := 0
    else if attemptExpired
        reclaimStatus := "Reclaim Missed"
        attemptDir := 0
        attemptBar := na
        attemptExtreme := na
        outsideCloseCount := 0
    else
        reclaimStatus := attemptDir == 1 ? "Watch Up Fail" : "Watch Down Fail"

if activeFailureDir != 0 and not na(activeFailureBox)
    box.set_right(activeFailureBox, bar_index + zoneExtendBars)
    if not na(activeFailureLabel) and not na(activeFailureStartBar) and not na(activeFailureTop) and not na(activeFailureBottom)
        float activeLabelPct = activeFailureDir == 1 ? 0.28 : 0.72
        int activeLabelX = activeFailureStartBar + int(math.round((bar_index + zoneExtendBars - activeFailureStartBar) * activeLabelPct))
        float activeCenterY = (activeFailureTop + activeFailureBottom) * 0.5
        float activeZoneHeight = math.max(activeFailureTop - activeFailureBottom, syminfo.mintick)
        float activeLabelNudge = math.min(activeZoneHeight * 0.18, atrSafe * 0.12)
        float activeLabelY = activeCenterY + (activeFailureDir == 1 ? activeLabelNudge : -activeLabelNudge)
        label.set_x(activeFailureLabel, activeLabelX)
        label.set_y(activeFailureLabel, activeLabelY)
        label.set_size(activeFailureLabel, labelSize)

if activeFailureDir == 1 and not na(activeFailureExtreme) and not na(orMid)
    reclaimStatus := close > activeFailureExtreme + reclaimBuffer ? "Zone Lost" : close < orLow ? "Full Range Fade" : close < orMid ? "Fade Below Mid" : reclaimStatus
    activeFailureDir := close > activeFailureExtreme + reclaimBuffer ? 0 : activeFailureDir

if activeFailureDir == -1 and not na(activeFailureExtreme) and not na(orMid)
    reclaimStatus := close < activeFailureExtreme - reclaimBuffer ? "Zone Lost" : close > orHigh ? "Full Range Reclaim" : close > orMid ? "Reclaim Above Mid" : reclaimStatus
    activeFailureDir := close < activeFailureExtreme - reclaimBuffer ? 0 : activeFailureDir

if not trackingActive and not inOrSession and rangeLocked and inTrackSession
    reclaimStatus := barsAfterLock > usedFailureWatchBars ? "Watch Expired" : reclaimStatus

// -------------------------------------------------
// Confirmation-anchored proof (failed breaks, Follow = faded 1R toward range mid before extreme exceeded)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var int proofAmbiguous = 0
var bool pEvalActive = false
var int pEvalDir = 0
var int pEvalStart = na
var float pEvalEntry = na
var float pEvalStop = na
var float pEvalTarget = na
var bool pReacted = false
var bool pFollowed = false

bool failureEventNow = upsideFailureEvent or downsideFailureEvent

if proofConfirmedBar and engineReady
    if pEvalActive
        int heldBars = bar_index - pEvalStart
        float followDist = math.max(math.abs(pEvalTarget - pEvalEntry), syminfo.mintick)
        float favorableExcursion = pEvalDir == 1 ? high - pEvalEntry : pEvalEntry - low
        bool targetTouched = heldBars >= 1 and favorableExcursion >= followDist
        bool stopTouched = pEvalDir == 1 ? low <= pEvalStop : high >= pEvalStop
        bool ambiguousNow = targetTouched and stopTouched

        if heldBars >= 1 and heldBars <= effectiveReactBars and favorableExcursion >= followDist * reactProgressPct / 100.0
            pReacted := true
        if targetTouched and not stopTouched
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        bool resolveNow = ambiguousNow or targetTouched or stopTouched or horizonDone

        if resolveNow
            if ambiguousNow
                proofAmbiguous := proofAmbiguous + 1
            else
                proofTotal := proofTotal + 1
                if pFollowed
                    proofFollow := proofFollow + 1
                if not stopTouched
                    proofHold := proofHold + 1
                if pReacted
                    proofReact := proofReact + 1
                if stopTouched
                    proofFlip := proofFlip + 1
            pEvalActive := false

    // Open one non-overlapping Proof sample for each available confirmed
    // failure call. Later calls are ignored until the current sample resolves.
    if failureEventNow and not pEvalActive and not na(activeFailureExtreme) and not na(orMid)
        pEvalActive := true
        pEvalDir := activeFailureDir == 1 ? -1 : 1
        pEvalEntry := close
        pEvalStop := activeFailureExtreme

        float pStopDist = math.max(math.abs(close - activeFailureExtreme), syminfo.mintick)
        float pRoomDist = math.max(math.abs(orMid - close), syminfo.mintick)
        float pFollowDist = math.min(pStopDist, pRoomDist)
        pEvalTarget := close + pEvalDir * pFollowDist
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Panel State
// -------------------------------------------------
bool panelFresh = not na(lastPanelEventBar) and bar_index - lastPanelEventBar <= panelMemoryBars
bool cooldownActive = panelFresh and not trackingActive and activeFailureDir == 0
bool noisyAtr = atrRatio >= 1.85
bool quietAtr = atrRatio <= 0.75
string volatilityMode = noisyAtr ? "Noisy ATR" : trackingActive or activeFailureDir != 0 ? "Active ATR" : cooldownActive ? "Cooldown ATR" : quietAtr ? "Quiet ATR" : "Balanced ATR"
string workflowText =
     not mapTimeframeOk ? "Use 15m Map" :
     inOrSession ? "Build Opening Range" :
     reclaimStatus == "Zone Lost" ? "Reset Failure Map" :
     str.contains(reclaimStatus, "Full Range") ? "Review Completed Move" :
     activeFailureDir == 1 ? "Review Fade" :
     activeFailureDir == -1 ? "Review Reclaim" :
     attemptDir != 0 ? "Monitor Probe" :
     noisyAtr ? "Reduce Noise" :
     cooldownActive ? "Cooldown Review" :
     trackingActive ? "Failed-Break Watch" :
     rangeLocked ? "Wait for Probe" :
     "Wait for Range"
string sideText = not mapTimeframeOk ? "Map Paused" : attemptDir == 1 ? "Upside Probe" : attemptDir == -1 ? "Downside Probe" : panelFresh ? lastFailureSide : "None"
string qualityText = not mapTimeframeOk ? "15m only" : attemptDir != 0 ? "Pending" : na(lastFailureScore) or not panelFresh ? "No failure" : str.tostring(math.round(lastFailureScore)) + " / 100"
color qualityColor = f_quality_color(panelFresh ? lastFailureScore : na)
string reclaimText = not mapTimeframeOk ? "Paused / " + str.tostring(atrRatio, "#.##") + "x" : reclaimStatus + " / " + str.tostring(atrRatio, "#.##") + "x"
color workflowColor =
     str.contains(workflowText, "Reset") ? bearColor :
     str.contains(workflowText, "Completed") ? bullColor :
     workflowText == "Review Fade" ? bearZoneColor :
     workflowText == "Review Reclaim" ? bullZoneColor :
     str.contains(workflowText, "Monitor") ? neutralColor :
     str.contains(workflowText, "Reduce") ? bearColor :
     str.contains(workflowText, "Cooldown") ? accentColor :
     str.contains(workflowText, "Watch") ? neutralColor :
     str.contains(workflowText, "Build") or str.contains(workflowText, "Use") ? accentColor :
     panelThemeInput == "Light" ? panelValueL : panelValueD
color sideColor = str.contains(sideText, "Upside") ? bearZoneColor : str.contains(sideText, "Downside") ? bullZoneColor : panelThemeInput == "Light" ? panelValueL : panelValueD

// -------------------------------------------------
// Panel
// -------------------------------------------------
string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) + (proofAmbiguous > 0 ? " | x = " + str.tostring(proofAmbiguous) : "") : proofAmbiguous > 0 ? "x = " + str.tostring(proofAmbiguous) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "-"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "-"
color panelDefaultVal = panelThemeInput == "Light" ? panelValueL : panelValueD
color followColPanel = proofTotal > 0 ? f_rate_color(followRate) : panelDefaultVal
color holdColPanel = proofTotal > 0 ? f_rate_color(holdRate) : panelDefaultVal
color reactColPanel = proofTotal > 0 ? f_rate_color(reactRate) : panelDefaultVal
color flipColPanel = proofTotal > 0 ? f_flip_color(flipRate) : panelDefaultVal

int panelRowCount = showProof ? 11 : 6
bool isLightPanel = panelThemeInput == "Light"
color activePanelBg = f_panel_bg(isLightPanel, false)
color activePanelBorder = isLightPanel ? panelBorderL : panelBorderD

var table statePanel = na
var string prevPanelPosition = ""
var string prevPanelTheme = ""
var bool prevProofMode = false

bool panelNeedsRebuild = showPanel and (na(statePanel) or prevPanelPosition != panelPositionInput or prevPanelTheme != panelThemeInput or prevProofMode != showProof)
if panelNeedsRebuild
    if not na(statePanel)
        table.delete(statePanel)
    statePanel := table.new(f_pos(panelPositionInput), 2, panelRowCount, bgcolor = activePanelBg, border_color = activePanelBorder, border_width = 1, frame_color = activePanelBorder, frame_width = 1)
    table.cell(statePanel, 0, 0, "AG Pro Opening Range Failure Zones", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(statePanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(statePanel, 0, 0, 1, 0)
    prevPanelPosition := panelPositionInput
    prevPanelTheme := panelThemeInput
    prevProofMode := showProof

if not showPanel and not na(statePanel)
    table.delete(statePanel)
    statePanel := na
    prevPanelPosition := ""
    prevPanelTheme := ""

if showPanel and not na(statePanel) and barstate.islast
    table.set_position(statePanel, f_pos(panelPositionInput))
    table.clear(statePanel, 0, 1, 1, panelRowCount - 1)
    table.cell(statePanel, 0, 0, "AG Pro Opening Range Failure Zones", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    f_panel_row(statePanel, 1, "Workflow", workflowText, workflowColor, isLightPanel, panelSize)
    f_panel_row(statePanel, 2, "Volatility State", volatilityMode + " / " + str.tostring(atrRatio, "#.##") + "x", f_vol_color(volatilityMode), isLightPanel, panelSize)
    f_panel_row(statePanel, 3, "Failure Side", sideText, sideColor, isLightPanel, panelSize)
    f_panel_row(statePanel, 4, "Quality Score", qualityText, qualityColor, isLightPanel, panelSize)
    f_panel_row(statePanel, 5, "Reclaim / ATR", reclaimText, reclaimStatus == "Zone Lost" ? bearColor : str.contains(reclaimStatus, "Full Range") ? bullColor : f_vol_color(volatilityMode), isLightPanel, panelSize)
    if showProof
        color proofHeadBg = f_panel_bg(isLightPanel, 6 % 2 == 0)
        color proofHeadLabel = isLightPanel ? panelLabelL : panelLabelD
        table.cell(statePanel, 0, 6, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = panelSize, text_halign = text.align_left)
        table.cell(statePanel, 1, 6, proofSampleText, text_color = proofHeadLabel, bgcolor = proofHeadBg, text_size = panelSize, text_halign = text.align_right)
        f_panel_row(statePanel, 7, "Follow Rate", followTextPanel, followColPanel, isLightPanel, panelSize)
        f_panel_row(statePanel, 8, "Hold Rate", holdTextPanel, holdColPanel, isLightPanel, panelSize)
        f_panel_row(statePanel, 9, "React Rate", reactTextPanel, reactColPanel, isLightPanel, panelSize)
        f_panel_row(statePanel, 10, "Flip Rate", flipTextPanel, flipColPanel, isLightPanel, panelSize)

// -------------------------------------------------
// Alerts and Exports
// -------------------------------------------------
alertcondition(alertUpsideFailure and upsideFailureEvent, "Opening Range Upside Failure", "Opening Range Failure Zones: upside opening range break failed and reclaimed back inside. This is an attention marker, not a trade instruction.")
alertcondition(alertDownsideFailure and downsideFailureEvent, "Opening Range Downside Failure", "Opening Range Failure Zones: downside opening range break failed and reclaimed back inside. This is an attention marker, not a trade instruction.")

plot(lastFailureScore, "ORF Last Failure Score", display = display.none)
plot(activeFailureDir, "ORF Active Failure Direction", display = display.none)
plot(followRate, "ORF Follow Rate", display = display.none)
plot(holdRate, "ORF Hold Rate", display = display.none)
plot(reactRate, "ORF React Rate", display = display.none)
plot(flipRate, "ORF Flip Rate", display = display.none)
plot(proofAmbiguous, "ORF Ambiguous Proof Count", display = display.none)
plot(atrRatio, "ORF ATR Ratio", display = display.none)
plot(rangeLocked ? 1 : 0, "ORF Range Locked State", display = display.none)
plot(activeFailureDir, "ORF Failure Side Code", display = display.none)
````
