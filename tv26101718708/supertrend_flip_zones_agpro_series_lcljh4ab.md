# SuperTrend Flip Zones [AGPro Series]

- url: https://www.tradingview.com/script/lcljH4Ab-SuperTrend-Flip-Zones-AGPro-Series/
- type: indicator
- pine_id: PUB;bb69f3090e004322a44c067a73a55259
- version: 4.0

## Description

# SuperTrend Flip Zones [AGPro Series]

🔷 OVERVIEW

SuperTrend Flip Zones is a trend-following overlay designed for traders who appreciate the clarity of SuperTrend, but want a more selective and more structured version of it on the chart.

Traditional SuperTrend tools are popular because they are simple: the line flips, the color changes, and the chart immediately prints a directional signal. That simplicity is useful, but it also creates a familiar weakness. In many market conditions, raw SuperTrend flips can appear too early, too close to noise, or without enough expansion to show that a genuine directional transition is taking hold.

This script was built to solve that exact problem.

Instead of treating every SuperTrend direction change as equally meaningful, SuperTrend Flip Zones evaluates the quality of the flip itself. Only qualified flips are promoted into visible BUY / SELL events, and each accepted signal creates a forward-projecting support or resistance zone built around the new SuperTrend structure.

The result is not just another SuperTrend clone with different colors. It is a more selective, more chart-aware framework that helps traders judge whether a flip is worth paying attention to, and where the new trend should continue to defend itself after that flip occurs.

🔷 WHAT MAKES THIS DIFFERENT

The biggest difference is that this script does not stop at the flip.

Most SuperTrend indicators on the platform focus on one task only:
detect the directional switch and mark it immediately.

SuperTrend Flip Zones takes a broader view. It asks two additional questions:

1. Was the flip strong enough to deserve attention?
2. After the flip, where is the live structural zone that the new trend is expected to protect?

That design choice creates a very different chart experience.

Instead of receiving every mechanical transition equally, the user sees a filtered signal environment. Weak flips can be ignored, while stronger flips remain visible and are reinforced by an ATR-based zone that extends forward. This makes the tool useful not only at the exact moment of the flip, but also in the bars that follow, when traders are deciding whether the move is still being respected.

It also creates clear separation from other AGProLabs tools in the same family.

This is not a pullback-quality script.
It is not focused on grading retracements inside an already established trend.
It is focused on the transition point itself, and on the acceptance zone created by that transition.

🔷 CORE LOGIC

The script is built around a custom SuperTrend engine using the selected ATR model, source, and multiplier.

When the direction flips, the script does not blindly trust the event. The flip is scored through a multi-factor quality model that examines:

- candle body efficiency,
- range expansion relative to ATR,
- price separation from the active SuperTrend line,
- alignment with a trend EMA,
- maturity of the prior trend leg before the reversal occurred.

Only flips that meet the minimum quality threshold are accepted.

Once a bullish or bearish flip qualifies:

- a BUY or SELL signal is printed,
- the signal can be promoted to BUY+ or SELL+ when the score is stronger,
- a rectangular support or resistance zone is created around the new SuperTrend level,
- that zone is extended forward to provide ongoing structure.

This makes the indicator useful both as a signal filter and as a post-signal map.

🔷 WHY THE ZONES MATTER

A standard SuperTrend line tells you where the trailing stop or directional boundary currently sits.

This script adds another layer by converting qualified flips into live zones. Those zones are important because they help visualize where the market should continue to accept price if the new directional phase is healthy.

In bullish conditions, the zone behaves like a dynamic support belt around the fresh SuperTrend structure.
In bearish conditions, the zone behaves like a dynamic resistance belt.

If price continues to respect that zone, the flip remains structurally valid.
If price loses the zone, the chart communicates that the new directional state is weakening or failing.

This produces a more practical read than a line alone, especially for traders who do not always enter on the exact signal bar and instead evaluate continuation quality after the move begins.

🔷 VISUAL DESIGN

The script is designed to look polished and organized without overloading the chart.

Visual elements include:

- bullish and bearish SuperTrend line states,
- restrained BUY / SELL labels,
- right-extending flip zones,
- soft trend cloud for directional context,
- compact AGPro panel with merged header row,
- configurable panel placement,
- dark and light theme support,
- adjustable label and panel text sizing.

The goal is to keep the chart premium and readable rather than dense and noisy.

🔷 HOW TO USE IT

SuperTrend Flip Zones is most useful for traders who want a higher-quality directional read rather than every raw SuperTrend crossover.

A typical workflow is:

- use the line and cloud to identify the active directional state,
- wait for a qualified BUY or SELL rather than reacting to every raw flip,
- monitor the projected zone as a live support or resistance area,
- observe whether price continues to defend that zone or loses it.

This makes the script suitable for discretionary trend-following, continuation analysis, and cleaner overlay-based chart reading.

🔷 BEST FIT

This tool is especially useful for:

- traders who already use SuperTrend but want cleaner signal selection,
- traders who prefer support / resistance style context after the flip,
- users who want a premium visual overlay without excessive label density,
- trend traders who want a more selective buy sell workflow.

🔷 TRANSPARENCY

This is an analytical indicator, not a trading strategy.

Like all trend-following tools, it can become less effective in highly compressed or directionless market conditions. The filtering logic is designed to reduce weak transitions, but it does not replace chart context, timeframe awareness, or risk management.

All logic is based on confirmed bar data inside the script framework. The purpose is to organize price action more clearly, not to guarantee future market behavior.

## Source Code

````pine
// -------------------------------------------------
// SuperTrend Flip Zones [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// SuperTrend Flip Zones is a premium trend-following overlay built to upgrade the
// classic ATR trailing stop into a cleaner buy sell workflow. Instead of marking
// every raw SuperTrend color change, it scores each flip through displacement,
// candle thrust, trend alignment, and prior leg stability. Qualified BUY and SELL
// badges stay visually dominant while internal flip levels preserve risk context.
// -------------------------------------------------

//@version=6
indicator("SuperTrend Flip Zones [AGPro Series]", shorttitle = "AG Pro STFZ", overlay = true, max_labels_count = 200)

// -------------------------------------------------
// Constants
// -------------------------------------------------
BULL = 1
BEAR = -1

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

lightPanelBg       = color.rgb(248, 250, 252)
lightPanelBorder   = color.rgb(203, 213, 225)
lightPanelLabelCol = color.rgb(71, 85, 105)
lightPanelValueCol = color.rgb(15, 23, 42)

// -------------------------------------------------
// Input Groups
// -------------------------------------------------
groupCore    = "Core Engine"
groupQuality = "Signal Quality"
groupZones   = "Flip Level Engine"
groupVisual  = "Visuals"
groupPanel   = "Panel"

// -------------------------------------------------
// Logical Flip Level Object
// -------------------------------------------------
type FlipZone
    float top
    float bottom
    int direction
    bool active
    int birthBar

// -------------------------------------------------
// Utility Functions
// -------------------------------------------------
clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

scoreTo100(float value, float fullScoreAt) =>
    fullScoreAt <= 0.0 ? 0.0 : clamp(value / fullScoreAt * 100.0, 0.0, 100.0)

sizeFromInput(string sizeInput) =>
    switch sizeInput
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        => size.normal

positionFromInput(string positionInput) =>
    switch positionInput
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Left"  => position.middle_left
        => position.middle_right

qualityBucket(float score) =>
    score >= 80.0 ? "Elite" : score >= 70.0 ? "Strong" : score >= 60.0 ? "Qualified" : "Weak"

priceText(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

scoreText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0")

barsText(int value) =>
    na(value) ? "n/a" : str.tostring(value)

atrDistanceText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.00") + " ATR"

// -------------------------------------------------
// Inputs: Core Engine
// -------------------------------------------------
atrLength = input.int(
    10,
    "ATR Length",
    minval = 1,
    group = groupCore,
    tooltip = "Sets the volatility lookback used by the SuperTrend core and all ATR-based spacing."
)

atrMethod = input.string(
    "RMA",
    "ATR Smoothing",
    options = ["RMA", "EMA", "SMA", "WMA"],
    group = groupCore,
    tooltip = "Chooses how True Range is smoothed. RMA is closest to the classic SuperTrend response."
)

factor = input.float(
    3.0,
    "Multiplier",
    minval = 0.5,
    step = 0.1,
    group = groupCore,
    tooltip = "Widens or tightens the trailing band. Higher values reduce noise but react later."
)

sourceInput = input.source(
    hlc3,
    "Source",
    group = groupCore,
    tooltip = "Selects the base price used to build the SuperTrend bands."
)

emaLength = input.int(
    34,
    "Trend EMA Length",
    minval = 1,
    group = groupCore,
    tooltip = "The EMA used for flip-alignment scoring. It qualifies the SuperTrend; it does not replace it."
)

slopeLookback = input.int(
    5,
    "EMA Slope Lookback",
    minval = 1,
    group = groupCore,
    tooltip = "Measures how decisively the EMA is leaning into the new flip direction."
)

// -------------------------------------------------
// Inputs: Signal Quality
// -------------------------------------------------
signalThreshold = input.float(
    75.0,
    "Minimum Flip Score",
    minval = 10.0,
    maxval = 95.0,
    step = 1.0,
    group = groupQuality,
    tooltip = "Only confirmed flips scoring at or above this premium threshold create a BUY/SELL badge, logical flip level, and alert."
)

stabilityTarget = input.int(
    18,
    "Leg Stability Target",
    minval = 2,
    maxval = 100,
    group = groupQuality,
    tooltip = "Defines how many completed bars the previous trend leg needs for full stability credit."
)

signalGapBars = input.int(
    4,
    "Minimum Bars Between Signals",
    minval = 0,
    maxval = 100,
    group = groupQuality,
    tooltip = "Adds a cooldown between qualified signals so choppy sequences do not overcrowd the chart."
)

// -------------------------------------------------
// Inputs: Logical Flip Level Engine
// -------------------------------------------------
zoneWidthAtr = input.float(
    1.15,
    "Flip Level Width (ATR)",
    minval = 0.2,
    maxval = 5.0,
    step = 0.05,
    group = groupZones,
    tooltip = "Controls the internal invalidation envelope around each qualified SuperTrend flip level. No chart zone is drawn."
)

zoneLifeBars = input.int(
    140,
    "Flip Level Max Age",
    minval = 10,
    maxval = 1000,
    group = groupZones,
    tooltip = "Defines how many elapsed bars an internal flip level can remain active before it expires on a confirmed close."
)

maxZones = input.int(
    5,
    "Tracked Flip Levels",
    minval = 1,
    maxval = 20,
    group = groupZones,
    tooltip = "Caps recent logical flip levels used by the panel and confirmed level-loss alerts."
)

// -------------------------------------------------
// Inputs: Visuals
// -------------------------------------------------
showSignals = input.bool(
    true,
    "Show BUY / SELL Labels",
    group = groupVisual,
    tooltip = "Displays one high-contrast premium BUY or SELL badge for each qualified flip."
)

signalHistory = input.int(
    12,
    "Visible Signal History",
    minval = 5,
    maxval = 50,
    group = groupVisual,
    tooltip = "Controls how many recent qualified BUY/SELL badges remain visible. This is independent from the logical flip-level memory."
)

showCloud = input.bool(
    true,
    "Show Trend Cloud",
    group = groupVisual,
    tooltip = "Adds a soft cloud between price and the active SuperTrend line for faster trend recognition."
)

labelSizeInput = input.string(
    "Normal",
    "Label Size",
    options = ["Tiny", "Small", "Normal", "Large", "Huge"],
    group = groupVisual,
    tooltip = "Adjusts every visible BUY/SELL badge."
)

labelOffsetAtr = input.float(
    1.0,
    "Label Offset (ATR)",
    minval = 0.1,
    maxval = 4.0,
    step = 0.05,
    group = groupVisual,
    tooltip = "Moves BUY/SELL labels away from candles in ATR units."
)

// -------------------------------------------------
// Inputs: Panel
// -------------------------------------------------
showPanel = input.bool(
    true,
    "Show Info Panel",
    group = groupPanel,
    tooltip = "Displays a compact dashboard with trend state, last signal, logical flip-level status, and key distances."
)

panelPositionInput = input.string(
    "Top Right",
    "Panel Position",
    options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"],
    group = groupPanel,
    tooltip = "Chooses where the information panel is anchored."
)

panelThemeInput = input.string(
    "Dark",
    "Panel Theme",
    options = ["Dark", "Light"],
    group = groupPanel,
    tooltip = "Switches the panel between the AGPro dark style and a brighter light variant."
)

panelSizeInput = input.string(
    "Normal",
    "Panel Font Size",
    options = ["Tiny", "Small", "Normal", "Large", "Huge"],
    group = groupPanel,
    tooltip = "Adjusts the information-panel text size."
)

// -------------------------------------------------
// Resolved Settings
// -------------------------------------------------
labelSize = sizeFromInput(labelSizeInput)
panelTextSize = sizeFromInput(panelSizeInput)
panelPosition = positionFromInput(panelPositionInput)
useDarkPanel = panelThemeInput == "Dark"

panelBgColor = useDarkPanel ? panelBg : lightPanelBg
panelBorderColor = useDarkPanel ? panelBorder : lightPanelBorder
panelLabelColor = useDarkPanel ? panelLabelCol : lightPanelLabelCol
panelValueColor = useDarkPanel ? panelValueCol : lightPanelValueCol

psBull = useDarkPanel ? bullColor : color.rgb(13, 148, 136)
psBear = useDarkPanel ? bearColor : color.rgb(219, 39, 119)
psNeut = useDarkPanel ? neutralColor : color.rgb(180, 83, 9)
psAcc  = useDarkPanel ? accentColor : color.rgb(79, 70, 229)

// -------------------------------------------------
// ATR Engine
// -------------------------------------------------
trValue = ta.tr(true)
atrValue = switch atrMethod
    "EMA" => ta.ema(trValue, atrLength)
    "SMA" => ta.sma(trValue, atrLength)
    "WMA" => ta.wma(trValue, atrLength)
    => ta.rma(trValue, atrLength)

atrUnit = math.max(nz(atrValue, syminfo.mintick), syminfo.mintick)
engineReady = not na(atrValue)
engineWasReady = not na(atrValue[1])

// -------------------------------------------------
// SuperTrend Core
// -------------------------------------------------
rawBullBand = sourceInput - factor * atrValue
rawBearBand = sourceInput + factor * atrValue

var float bullBand = na
var float bearBand = na

bullBandPrev = nz(bullBand[1], rawBullBand)
bearBandPrev = nz(bearBand[1], rawBearBand)

bullBand := close[1] > bullBandPrev ? math.max(rawBullBand, bullBandPrev) : rawBullBand
bearBand := close[1] < bearBandPrev ? math.min(rawBearBand, bearBandPrev) : rawBearBand

var int trendDir = BULL
trendPrev = nz(trendDir[1], BULL)
trendDir := trendPrev == BEAR and close > bearBandPrev ? BULL : trendPrev == BULL and close < bullBandPrev ? BEAR : trendPrev

stLine = trendDir == BULL ? bullBand : bearBand

// One-based trend-leg length. Warm-up bars are excluded.
var int trendAge = 0
trendAgePrev = nz(trendAge[1], 0)
trendAge := not engineReady ? 0 : not engineWasReady ? 1 : trendDir == trendPrev ? trendAgePrev + 1 : 1
priorLegBars = engineReady and engineWasReady and trendDir != trendPrev ? trendAgePrev : na

rawBullFlip = engineReady and trendDir == BULL and trendPrev == BEAR
rawBearFlip = engineReady and trendDir == BEAR and trendPrev == BULL

// -------------------------------------------------
// Flip Quality Engine
// -------------------------------------------------
// EMA must execute on every bar; the remaining score math runs only on flip bars.
emaBasis = ta.ema(close, emaLength)

float bullFlipScore = na
float bearFlipScore = na

if rawBullFlip or rawBearFlip
    emaSlopeAtr = (emaBasis - nz(emaBasis[slopeLookback], emaBasis)) / atrUnit
    rangeValue = math.max(high - low, syminfo.mintick)
    bodyValue = math.abs(close - open)
    bodyRatio = bodyValue / rangeValue
    rangeAtr = rangeValue / atrUnit

    bodyScore = scoreTo100(bodyRatio, 0.78)
    rangeScore = scoreTo100(rangeAtr, 1.60)
    stabilityScore = scoreTo100(float(priorLegBars), float(stabilityTarget))

    if rawBullFlip
        bullSeparation = (close - stLine) / atrUnit
        bullAlignment = ((close - emaBasis) / atrUnit + emaSlopeAtr) * 0.5
        bullBandScore = scoreTo100(bullSeparation, 1.20)
        bullAlignScore = scoreTo100(bullAlignment, 0.80)
        bullFlipScore := bodyScore * 0.20 + rangeScore * 0.15 + bullBandScore * 0.25 + bullAlignScore * 0.20 + stabilityScore * 0.20
    else
        bearSeparation = (stLine - close) / atrUnit
        bearAlignment = ((emaBasis - close) / atrUnit - emaSlopeAtr) * 0.5
        bearBandScore = scoreTo100(bearSeparation, 1.20)
        bearAlignScore = scoreTo100(bearAlignment, 0.80)
        bearFlipScore := bodyScore * 0.20 + rangeScore * 0.15 + bearBandScore * 0.25 + bearAlignScore * 0.20 + stabilityScore * 0.20

// -------------------------------------------------
// Confirmed Signal State
// -------------------------------------------------
var int lastSignalBar = na
var float lastSignalScore = na
var string lastSignalText = "None"

bullQualityPass = barstate.isconfirmed and rawBullFlip and bullFlipScore >= signalThreshold
bearQualityPass = barstate.isconfirmed and rawBearFlip and bearFlipScore >= signalThreshold
signalGapOk = na(lastSignalBar) or bar_index - lastSignalBar >= signalGapBars

newBullSignal = bullQualityPass and signalGapOk
newBearSignal = bearQualityPass and signalGapOk

// -------------------------------------------------
// Logical Flip-Level and Signal Storage
// -------------------------------------------------
var array<FlipZone> zones = array.new<FlipZone>()
var array<label> signalLabels = array.new<label>()

// -------------------------------------------------
// Confirmed Bullish Signal
// -------------------------------------------------
if newBullSignal
    lastSignalBar := bar_index
    lastSignalScore := bullFlipScore
    lastSignalText := "BUY"

    bullZoneTop = stLine + atrUnit * zoneWidthAtr * 0.35
    bullZoneBottom = stLine - atrUnit * zoneWidthAtr

    if showSignals
        label bullBadge = label.new(
            bar_index,
            low - atrUnit * labelOffsetAtr,
            "BUY",
            style = label.style_label_up,
            size = labelSize,
            color = bullColor,
            textcolor = headerText,
            tooltip = "Qualified bullish SuperTrend flip\nQuality: " + scoreText(bullFlipScore) + " / 100"
        )
        array.unshift(signalLabels, bullBadge)

    FlipZone bullZone = FlipZone.new(
        top = bullZoneTop,
        bottom = bullZoneBottom,
        direction = BULL,
        active = true,
        birthBar = bar_index
    )

    array.unshift(zones, bullZone)

// -------------------------------------------------
// Confirmed Bearish Signal
// -------------------------------------------------
if newBearSignal
    lastSignalBar := bar_index
    lastSignalScore := bearFlipScore
    lastSignalText := "SELL"

    bearZoneTop = stLine + atrUnit * zoneWidthAtr
    bearZoneBottom = stLine - atrUnit * zoneWidthAtr * 0.35

    if showSignals
        label bearBadge = label.new(
            bar_index,
            high + atrUnit * labelOffsetAtr,
            "SELL",
            style = label.style_label_down,
            size = labelSize,
            color = bearColor,
            textcolor = headerText,
            tooltip = "Qualified bearish SuperTrend flip\nQuality: " + scoreText(bearFlipScore) + " / 100"
        )
        array.unshift(signalLabels, bearBadge)

    FlipZone bearZone = FlipZone.new(
        top = bearZoneTop,
        bottom = bearZoneBottom,
        direction = BEAR,
        active = true,
        birthBar = bar_index
    )

    array.unshift(zones, bearZone)

// -------------------------------------------------
// Retention Limit
// -------------------------------------------------
while array.size(zones) > maxZones
    array.pop(zones)

while array.size(signalLabels) > signalHistory
    label.delete(array.pop(signalLabels))

// -------------------------------------------------
// Confirmed Logical Flip-Level Lifecycle
// -------------------------------------------------
bullZoneLost = false
bearZoneLost = false
activeBullZones = 0
activeBearZones = 0
int activeZoneAge = na

if array.size(zones) > 0
    for zone in zones
        if zone.active
            // Quality and cooldown are separated: a score-qualified opposite flip
            // invalidates the old level even when signalGapBars suppresses its badge.
            zoneExpired = barstate.isconfirmed and bar_index - zone.birthBar >= zoneLifeBars
            zoneOpposed = zone.direction == BULL ? bearQualityPass : bullQualityPass
            zoneBroken = barstate.isconfirmed and (zone.direction == BULL ? close < zone.bottom : close > zone.top)
            zoneInvalidated = zoneExpired or zoneOpposed or zoneBroken

            if zoneInvalidated
                zone.active := false

                if zoneBroken
                    bullZoneLost := bullZoneLost or zone.direction == BULL
                    bearZoneLost := bearZoneLost or zone.direction == BEAR
            else if barstate.islast
                if zone.direction == BULL
                    activeBullZones += 1
                else
                    activeBearZones += 1

                // Newest levels are first; select the latest level aligned with trend.
                if na(activeZoneAge) and zone.direction == trendDir
                    activeZoneAge := bar_index - zone.birthBar

// -------------------------------------------------
// Plots
// -------------------------------------------------
bullPlot = plot(
    trendDir == BULL ? stLine : na,
    "Bull SuperTrend",
    color.new(bullColor, 38),
    2,
    plot.style_linebr
)

bearPlot = plot(
    trendDir == BEAR ? stLine : na,
    "Bear SuperTrend",
    color.new(bearColor, 38),
    2,
    plot.style_linebr
)

priceProxy = plot(
    ohlc4,
    "Price Proxy",
    color.new(color.white, 100),
    display = display.none
)

fill(
    priceProxy,
    bullPlot,
    title = "Bull Trend Cloud",
    color = showCloud ? color.new(bullColor, 96) : na
)

fill(
    priceProxy,
    bearPlot,
    title = "Bear Trend Cloud",
    color = showCloud ? color.new(bearColor, 96) : na
)

// -------------------------------------------------
// Information Panel
// -------------------------------------------------
var table infoPanel = table.new(
    panelPosition,
    2,
    8,
    frame_color = panelBorderColor,
    frame_width = 1,
    border_color = panelBorderColor,
    border_width = 1
)
var bool infoPanelBuilt = false

// The full panel structure is rebuilt after any hide/clear path.
if barstate.isfirst or (barstate.islast and showPanel and not infoPanelBuilt)
    table.cell(infoPanel, 0, 0, "AG Pro SuperTrend Flip Zones", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize)
    table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelTextSize)
    table.merge_cells(infoPanel, 0, 0, 1, 0)

    table.cell(infoPanel, 0, 1, "Trend", text_color = panelLabelColor, bgcolor = panelBgColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 1, "", text_color = panelValueColor, bgcolor = panelBgColor, text_size = panelTextSize)

    table.cell(infoPanel, 0, 2, "SuperTrend", text_color = panelLabelColor, bgcolor = panelBgColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 2, "", text_color = panelValueColor, bgcolor = panelBgColor, text_size = panelTextSize)

    table.cell(infoPanel, 0, 3, "Last Signal", text_color = panelLabelColor, bgcolor = panelBgColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 3, "", text_color = panelValueColor, bgcolor = panelBgColor, text_size = panelTextSize)

    table.cell(infoPanel, 0, 4, "Signal Quality", text_color = panelLabelColor, bgcolor = panelBgColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 4, "", text_color = panelValueColor, bgcolor = panelBgColor, text_size = panelTextSize)

    table.cell(infoPanel, 0, 5, "Active Level", text_color = panelLabelColor, bgcolor = panelBgColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 5, "", text_color = panelValueColor, bgcolor = panelBgColor, text_size = panelTextSize)

    table.cell(infoPanel, 0, 6, "Distance", text_color = panelLabelColor, bgcolor = panelBgColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 6, "", text_color = panelValueColor, bgcolor = panelBgColor, text_size = panelTextSize)

    table.cell(infoPanel, 0, 7, "Trend Age", text_color = panelLabelColor, bgcolor = panelBgColor, text_size = panelTextSize)
    table.cell(infoPanel, 1, 7, "", text_color = panelValueColor, bgcolor = panelBgColor, text_size = panelTextSize)
    infoPanelBuilt := true

if barstate.islast
    if showPanel
        int signalAge = na(lastSignalBar) ? na : bar_index - lastSignalBar
        distanceToStAtr = na(stLine) ? na : math.abs(close - stLine) / atrUnit

        trendText = not engineReady ? "Initializing" : trendDir == BULL ? "Bullish" : "Bearish"
        trendColor = not engineReady ? psNeut : trendDir == BULL ? psBull : psBear

        zoneText = activeBullZones > 0 ? "Bull Flip Support" : activeBearZones > 0 ? "Bear Flip Resistance" : "None"
        zoneTextColor = activeBullZones > 0 ? psBull : activeBearZones > 0 ? psBear : psNeut

        lastSignalValue = na(lastSignalBar) ? "None" : lastSignalText + " | " + barsText(signalAge) + " bars"
        lastSignalColor = str.contains(lastSignalText, "BUY") ? psBull : str.contains(lastSignalText, "SELL") ? psBear : panelValueColor

        qualityValue = na(lastSignalScore) ? "n/a" : qualityBucket(lastSignalScore) + " | " + scoreText(lastSignalScore)
        qualityColor = na(lastSignalScore) ? panelValueColor : psAcc

        ageSuffix = na(activeZoneAge) ? "" : " | Level " + barsText(activeZoneAge)
        trendAgeValue = engineReady ? barsText(trendAge) + " bars" + ageSuffix : "n/a"

        table.cell_set_text(infoPanel, 1, 1, trendText)
        table.cell_set_text_color(infoPanel, 1, 1, trendColor)

        table.cell_set_text(infoPanel, 1, 2, priceText(stLine))
        table.cell_set_text_color(infoPanel, 1, 2, panelValueColor)

        table.cell_set_text(infoPanel, 1, 3, lastSignalValue)
        table.cell_set_text_color(infoPanel, 1, 3, na(lastSignalBar) ? panelValueColor : lastSignalColor)

        table.cell_set_text(infoPanel, 1, 4, qualityValue)
        table.cell_set_text_color(infoPanel, 1, 4, qualityColor)

        table.cell_set_text(infoPanel, 1, 5, zoneText)
        table.cell_set_text_color(infoPanel, 1, 5, zoneTextColor)

        table.cell_set_text(infoPanel, 1, 6, atrDistanceText(distanceToStAtr))
        table.cell_set_text_color(infoPanel, 1, 6, panelValueColor)

        table.cell_set_text(infoPanel, 1, 7, trendAgeValue)
        table.cell_set_text_color(infoPanel, 1, 7, panelValueColor)
    else
        table.clear(infoPanel, 0, 0, 1, 7)
        infoPanelBuilt := false

// -------------------------------------------------
// Confirmed Alerts
// -------------------------------------------------
alertcondition(
    newBullSignal,
    title = "BUY Signal",
    message = "AGPro SuperTrend Flip Zones BUY on {{ticker}} ({{interval}}) at {{close}}."
)

alertcondition(
    newBearSignal,
    title = "SELL Signal",
    message = "AGPro SuperTrend Flip Zones SELL on {{ticker}} ({{interval}}) at {{close}}."
)

alertcondition(
    newBullSignal or newBearSignal,
    title = "Any Qualified Flip",
    message = "AGPro SuperTrend Flip Zones qualified flip on {{ticker}} ({{interval}}) at {{close}}."
)

alertcondition(
    bullZoneLost,
    title = "Bullish Flip Level Lost",
    message = "AGPro bullish flip level was lost on a confirmed close for {{ticker}} ({{interval}}) at {{close}}."
)

alertcondition(
    bearZoneLost,
    title = "Bearish Flip Level Lost",
    message = "AGPro bearish flip level was lost on a confirmed close for {{ticker}} ({{interval}}) at {{close}}."
)
````
