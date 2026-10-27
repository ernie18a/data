# Foundry Range Ledger [JOAT]

- url: https://www.tradingview.com/script/aBiaG05I-Foundry-Range-Ledger-JOAT/
- type: indicator
- pine_id: PUB;5bc1c30cee27464ebfd3570c0d8a8703
- version: 1.0

## Description

[b]Foundry Range Ledger [JOAT][/b]

[b]Introduction[/b]

Foundry Range Ledger is an open-source range and auction-structure indicator that maps active supply, active demand, and the live auction corridor between them.

The script is built for traders who need to know where the market is being offered, where it is being defended, and whether price is rotating cleanly between those two points or breaking away from them.

Instead of relying on a large dashboard to explain everything, Foundry is designed so the main value is visible directly on the chart.

The indicator draws split supply and demand boxes, top and bottom rails, an equilibrium reference, an auction corridor, and candle-state coloring so the structure can be read without hunting through text.

The problem Foundry solves is range readability.

Many range indicators either mark too little and disappear once the first break occurs, or they mark too much and become unreadable.

Foundry focuses on a smaller number of cleaner, higher-visibility structures so the trader can immediately understand whether the market is boxed, rotating, absorbing, rejecting, or releasing through an active zone.

[image]https://www.tradingview.com/x/MJOTgRUA/[/image]

[b]Core Concepts[/b]

[b]1. Pivot-Derived Supply and Demand Seeding[/b]

Foundry begins with confirmed pivot highs and pivot lows.

Each confirmed pivot can seed a new zone.

If a new pivot forms close enough to the prior pivot of the same type, the zone is treated as a stronger cluster rather than as unrelated noise.

This lets the script represent repeated defense or repeated supply more clearly than a single-touch model.

[b]2. Split-Zone Construction[/b]

Each zone is drawn as a body with two internal halves.

For supply, the upper half represents the more aggressive offer side and the lower half represents the response pocket below it.

For demand, the lower half represents the more aggressive bid side and the upper half represents the response pocket above it.

This creates a cleaner institutional-style visual than a single flat rectangle.

[b]3. Top, Bottom, and Equilibrium Rails[/b]

Foundry does not leave the zone as only a filled box.

Each active zone has clear rails at its boundary and a dashed equilibrium line through its center.

These rails make it easier to judge exactly where price is entering, holding, or releasing from the zone.

[b]4. Participation Inside the Zone[/b]

The indicator tracks directional participation inside the active zone.

Touches are counted only when price actually interacts with the zone.

Buy-side and sell-side participation are then compared to determine whether the zone is absorbing or rejecting.

This information drives both state text and the internal color emphasis of the split halves.

[b]5. Auction Corridor Logic[/b]

When both an active supply zone and an active demand zone exist at the same time, Foundry calculates the live auction corridor between them.

That corridor is the space where price is rotating between opposing areas of interest.

The script highlights that corridor directly on the chart and adds an equilibrium reference so range traders can see where the market is most balanced.

[b]6. Release and Post-Break Behavior[/b]

A zone is not immediately forgotten once price breaks it.

Foundry can keep released zones visible as post-break context, allowing the trader to study whether price is cleanly escaping or coming back to retest the released area.

This is important because the first break is often only part of the story.

The retest frequently matters more than the break itself.

[b]7. Candle-State Coloring[/b]

Candles are recolored based on where price is interacting.

If price is trading inside active supply, the candles reflect offer pressure.

If price is trading inside active demand, the candles reflect bid pressure.

If price is rotating in the live corridor, the candles shift toward the neutral response color.

This creates immediate chart feedback without cluttered shapes.

[image]https://www.tradingview.com/x/Gn1hvmhw/[/image]

[b]Features[/b]

[list]
[*][b]Confirmed supply and demand zones:[/b] Zones are seeded from confirmed pivots rather than unconfirmed intrabar motion
[*][b]Cluster-aware strengthening:[/b] Repeated pivots near the same level strengthen the visual and informational quality of the zone
[*][b]Split zone bodies:[/b] Each supply and demand box is divided internally for cleaner auction reading
[*][b]Boundary rails and midpoint rail:[/b] Top, bottom, and equilibrium references remain visible directly on the chart
[*][b]Auction corridor cloud:[/b] When both sides are active, the space between them is highlighted as a live range environment
[*][b]Stateful release behavior:[/b] Broken zones can remain visible as post-break structure instead of vanishing instantly
[*][b]Retest labels:[/b] Optional tags mark when price revisits released structure
[*][b]Zone interaction candle coloring:[/b] Price bars reflect supply interaction, demand interaction, or corridor rotation state
[*][b]Six-row dashboard:[/b] Only the highest-value summary fields remain, keeping the chart as the primary information surface
[*][b]Confirmed-bar alerts:[/b] Alerts are available for releases, retests, active auction states, and balanced corridor conditions
[/list]

[b]Input Parameters[/b]

[b]Range Construction:[/b]
[list]
[*]Pivot Length: Number of bars required on each side to confirm a pivot
[*]Cluster Tolerance ATR: Distance allowed between repeated pivots before they are treated as one stronger cluster
[*]Zone Width ATR: ATR-scaled depth of each zone
[*]Forward Extend Bars: Number of bars the active zone projects forward on the chart
[*]Minimum Zone Age: Minimum number of bars before a break qualifies as a meaningful release
[/list]

[b]Context and Behavior:[/b]
[list]
[*]Show Auction Cloud toggle
[*]Keep Broken Zones toggle
[*]Show Retest Tags toggle
[*]Show Zone Labels toggle
[*]Recolor Candles toggle
[*]Broken Zone Fade Bars: Controls how long released zones remain visible when historical persistence is disabled
[*]Break Body Quality and filter toggle: Prevents weak-body candles from being treated as high-quality releases
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Whether Supply, Demand, or Both Are Active[/b]

If only supply is active, the market is currently capped from above.

If only demand is active, the market is currently supported from below.

If both are active, price is trading inside a live auction corridor.

That is the first and most important read.

[b]Step 2: Read the Box Geometry, Not Just the Labels[/b]

The top and bottom rails define the actual interaction edges.

The dashed midpoint shows the local equilibrium of the zone.

When price enters the zone, watch where it spends time, where it rejects, and whether the candles recolor in the expected direction.

[b]Step 3: Use the Corridor as a Rotation Map[/b]

When both zones are active, the space between demand top and supply bottom becomes the tradable balance corridor.

That space is where mean-reversion and auction-style logic are most relevant.

A clean release out of that corridor changes the context immediately.

[b]Step 4: Watch Release Quality[/b]

Foundry does not treat every poke outside a zone as equally important.

Body quality can be used as a filter so weak noise does not count the same as committed expansion.

This helps reduce false structural releases.

[b]Step 5: Retests Matter[/b]

A released zone that price retests cleanly can be more informative than the initial break itself.

Use the retest labels and the remaining zone structure to judge whether the prior range is truly being left behind or simply probed.

[b]Indicator Limitations[/b]

[list]
[*]Pivot-based zones confirm only after the pivot is complete, so the script will always favor non-repainting structure over earliest possible marking
[*]If price trends strongly without forming relevant repeat pivots, the indicator may show fewer zones than a more aggressive retail-style detector
[*]A zone is contextual, not predictive; price can ignore supply or demand completely when momentum is strong enough
[*]Balanced corridor conditions do not guarantee rotation and can still resolve into directional continuation
[*]The recolored candle state is contextual feedback, not an entry signal by itself
[/list]

[b]Originality Statement[/b]

Foundry Range Ledger is original in the way it combines pivot-seeded supply and demand bodies, split internal zone construction, visible auction corridor rendering, participation-aware state handling, and post-break structural persistence into one chart-first overlay.

The script is designed to make range structure visually readable, not to hide it behind a large panel or reduce it to generic rectangles.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only.

It does not provide financial advice or trading recommendations.

Supply and demand zones can fail, release, or be ignored entirely by price.

Balanced ranges can break violently without warning.

Always use independent confirmation and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Foundry Range Ledger [JOAT]", overlay = true, max_boxes_count = 300, max_labels_count = 150, max_lines_count = 250)

//------------------------------------------------------------------------------
// Foundry Range Ledger
// Range and auction map using pivot-derived supply/demand boxes, split halves,
// visible range rails, live equilibrium, and cleaner chart-first presentation.
//------------------------------------------------------------------------------

string groupRange = "Range"
string groupContext = "Context"
string groupStyle = "Style"
string groupDashboard = "Dashboard"
string groupAlerts = "Alerts"

int pivotLength = input.int(5, "Pivot Length", minval = 2, group = groupRange)
float toleranceAtr = input.float(0.22, "Cluster Tolerance ATR", minval = 0.05, step = 0.05, group = groupRange)
float zoneWidthAtr = input.float(0.70, "Zone Width ATR", minval = 0.2, step = 0.05, group = groupRange)
int extendBars = input.int(20, "Forward Extend Bars", minval = 5, maxval = 80, group = groupRange)
int agingBars = input.int(8, "Minimum Zone Age", minval = 1, maxval = 100, group = groupRange)
int maxScanBars = input.int(250, "Participation Lookback", minval = 25, maxval = 600, group = groupRange)
bool bodyBreakOnly = input.bool(true, "Breakout Uses Body Close", group = groupRange)

bool showRangeCloud = input.bool(true, "Show Auction Cloud", group = groupContext)
bool showHistoricBroken = input.bool(true, "Keep Broken Zones", group = groupContext)
bool showRetestTags = input.bool(true, "Show Retest Tags", group = groupContext)
bool showZoneLabels = input.bool(true, "Show Zone Labels", group = groupContext)
bool recolorCandles = input.bool(true, "Recolor Candles", group = groupContext)
int rangeFadeBars = input.int(24, "Broken Zone Fade Bars", minval = 1, maxval = 150, group = groupContext)
float bodyQualityMin = input.float(0.55, "Break Body Quality", minval = 0.1, maxval = 1.0, step = 0.05, group = groupContext)
bool useBodyQualityFilter = input.bool(true, "Use Body Quality Filter", group = groupContext)

color supplyCol = input.color(color.rgb(231, 99, 133), "Supply Fill", group = groupStyle, inline = "c1")
color demandCol = input.color(color.rgb(41, 214, 165), "Demand Fill", group = groupStyle, inline = "c1")
color supplyEdge = input.color(color.rgb(248, 136, 162), "Supply Edge", group = groupStyle, inline = "c2")
color demandEdge = input.color(color.rgb(110, 232, 191), "Demand Edge", group = groupStyle, inline = "c2")
color responseCol = input.color(color.rgb(255, 185, 58), "Response", group = groupStyle)
color eqCol = input.color(color.rgb(126, 138, 165), "Equilibrium", group = groupStyle)
color corridorCol = input.color(color.rgb(104, 113, 136), "Auction Cloud", group = groupStyle)
int fillOpacity = input.int(86, "Zone Transparency", minval = 10, maxval = 95, group = groupStyle)
int tagOpacity = input.int(84, "Label Transparency", minval = 10, maxval = 95, group = groupStyle)

bool showDashboard = input.bool(true, "Show Dashboard", group = groupDashboard)
string dashSize = input.string("Normal", "Dashboard Size", options = ["Small", "Normal", "Large"], group = groupDashboard)

bool enableAlerts = input.bool(true, "Enable Alerts", group = groupAlerts)

f_size(string sizeName) =>
    switch sizeName
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_clamp(float value, float lo, float hi) =>
    math.min(math.max(value, lo), hi)

f_state(bool active, bool broken, float deltaPct, int touches, int hits) =>
    active ? (deltaPct >= 0 ? "Absorb" : "Reject") : broken ? "Released" : hits >= 2 ? "Seeded" : touches >= 4 ? "Rotating" : "Idle"

f_alpha(float ratio, int lo, int hi) =>
    int(math.round(f_clamp(hi - ratio * (hi - lo), lo, hi)))

float ph = ta.pivothigh(high, pivotLength, pivotLength)
float pl = ta.pivotlow(low, pivotLength, pivotLength)
float atrBase = ta.atr(200)
float tolerance = atrBase * toleranceAtr
float zoneWidth = atrBase * zoneWidthAtr
float currentBodyQuality = math.abs(close - open) / math.max(high - low, syminfo.mintick)
bool breakoutQualityOk = not useBodyQualityFilter or currentBodyQuality >= bodyQualityMin

var float lastHighPivot = na
var float lastLowPivot = na
var int lastHighIndex = na
var int lastLowIndex = na
var int upperHits = 0
var int lowerHits = 0

var box upperBody = na
var box upperUpperHalf = na
var box upperLowerHalf = na
var line upperTopRail = na
var line upperBottomRail = na
var line upperEqRail = na
var line upperTagRail = na
var label upperTag = na
var int upperBirth = na
var int upperBrokenAt = na
var bool upperActive = false
var int upperTouchTotal = na
var float upperDeltaPct = na
var float upperBuyShare = na
var float upperSellShare = na

var box lowerBody = na
var box lowerUpperHalf = na
var box lowerLowerHalf = na
var line lowerTopRail = na
var line lowerBottomRail = na
var line lowerEqRail = na
var line lowerTagRail = na
var label lowerTag = na
var int lowerBirth = na
var int lowerBrokenAt = na
var bool lowerActive = false
var int lowerTouchTotal = na
var float lowerDeltaPct = na
var float lowerBuyShare = na
var float lowerSellShare = na

if not na(ph)
    float pivotHigh = high[pivotLength]
    int pivotHighIndex = bar_index[pivotLength]
    bool upperCluster = not na(lastHighPivot) and math.abs(lastHighPivot - pivotHigh) <= tolerance
    float upperAnchor = upperCluster ? math.avg(lastHighPivot, pivotHigh) : pivotHigh
    float upperTopSeed = upperAnchor
    float upperBottomSeed = upperAnchor - zoneWidth
    upperHits := upperCluster ? upperHits + 1 : 1
    if not na(upperBody)
        box.delete(upperBody)
        box.delete(upperUpperHalf)
        box.delete(upperLowerHalf)
        if not na(upperTopRail)
            line.delete(upperTopRail)
        if not na(upperBottomRail)
            line.delete(upperBottomRail)
        if not na(upperEqRail)
            line.delete(upperEqRail)
        if not na(upperTagRail)
            line.delete(upperTagRail)
        if not na(upperTag)
            label.delete(upperTag)
    upperBody := box.new(left = pivotHighIndex, top = upperTopSeed, right = bar_index + extendBars, bottom = upperBottomSeed, bgcolor = color.new(chart.bg_color, 100), border_color = supplyEdge, border_width = upperCluster ? 3 : 2)
    upperUpperHalf := box.new(left = pivotHighIndex, top = upperTopSeed, right = bar_index + extendBars, bottom = math.avg(upperTopSeed, upperBottomSeed), bgcolor = color.new(supplyCol, fillOpacity - 6), border_color = color.new(chart.bg_color, 100))
    upperLowerHalf := box.new(left = pivotHighIndex, top = math.avg(upperTopSeed, upperBottomSeed), right = bar_index + extendBars, bottom = upperBottomSeed, bgcolor = color.new(responseCol, fillOpacity + 2), border_color = color.new(chart.bg_color, 100))
    upperTopRail := line.new(pivotHighIndex, upperTopSeed, bar_index + extendBars, upperTopSeed, color = supplyEdge, width = 2)
    upperBottomRail := line.new(pivotHighIndex, upperBottomSeed, bar_index + extendBars, upperBottomSeed, color = color.new(supplyEdge, 20), width = 1)
    upperEqRail := line.new(pivotHighIndex, math.avg(upperTopSeed, upperBottomSeed), bar_index + extendBars, math.avg(upperTopSeed, upperBottomSeed), color = color.new(eqCol, 10), style = line.style_dashed, width = 1)
    if showZoneLabels
        upperTagRail := line.new(pivotHighIndex, upperTopSeed, pivotHighIndex + 3, upperTopSeed, color = color.new(supplyEdge, 20), width = 1)
        upperTag := label.new(pivotHighIndex, upperTopSeed, upperCluster ? "SUPPLY x" + str.tostring(upperHits) : "SUPPLY", style = label.style_label_down, color = color.new(chart.bg_color, tagOpacity), textcolor = supplyEdge, size = size.tiny)
    upperBirth := bar_index
    upperBrokenAt := na
    upperActive := true
    lastHighPivot := pivotHigh
    lastHighIndex := pivotHighIndex

if not na(pl)
    float pivotLow = low[pivotLength]
    int pivotLowIndex = bar_index[pivotLength]
    bool lowerCluster = not na(lastLowPivot) and math.abs(lastLowPivot - pivotLow) <= tolerance
    float lowerAnchor = lowerCluster ? math.avg(lastLowPivot, pivotLow) : pivotLow
    float lowerBottomSeed = lowerAnchor
    float lowerTopSeed = lowerAnchor + zoneWidth
    lowerHits := lowerCluster ? lowerHits + 1 : 1
    if not na(lowerBody)
        box.delete(lowerBody)
        box.delete(lowerUpperHalf)
        box.delete(lowerLowerHalf)
        if not na(lowerTopRail)
            line.delete(lowerTopRail)
        if not na(lowerBottomRail)
            line.delete(lowerBottomRail)
        if not na(lowerEqRail)
            line.delete(lowerEqRail)
        if not na(lowerTagRail)
            line.delete(lowerTagRail)
        if not na(lowerTag)
            label.delete(lowerTag)
    lowerBody := box.new(left = pivotLowIndex, top = lowerTopSeed, right = bar_index + extendBars, bottom = lowerBottomSeed, bgcolor = color.new(chart.bg_color, 100), border_color = demandEdge, border_width = lowerCluster ? 3 : 2)
    lowerUpperHalf := box.new(left = pivotLowIndex, top = lowerTopSeed, right = bar_index + extendBars, bottom = math.avg(lowerTopSeed, lowerBottomSeed), bgcolor = color.new(responseCol, fillOpacity + 2), border_color = color.new(chart.bg_color, 100))
    lowerLowerHalf := box.new(left = pivotLowIndex, top = math.avg(lowerTopSeed, lowerBottomSeed), right = bar_index + extendBars, bottom = lowerBottomSeed, bgcolor = color.new(demandCol, fillOpacity - 6), border_color = color.new(chart.bg_color, 100))
    lowerTopRail := line.new(pivotLowIndex, lowerTopSeed, bar_index + extendBars, lowerTopSeed, color = color.new(demandEdge, 20), width = 1)
    lowerBottomRail := line.new(pivotLowIndex, lowerBottomSeed, bar_index + extendBars, lowerBottomSeed, color = demandEdge, width = 2)
    lowerEqRail := line.new(pivotLowIndex, math.avg(lowerTopSeed, lowerBottomSeed), bar_index + extendBars, math.avg(lowerTopSeed, lowerBottomSeed), color = color.new(eqCol, 10), style = line.style_dashed, width = 1)
    if showZoneLabels
        lowerTagRail := line.new(pivotLowIndex, lowerBottomSeed, pivotLowIndex + 3, lowerBottomSeed, color = color.new(demandEdge, 20), width = 1)
        lowerTag := label.new(pivotLowIndex, lowerBottomSeed, lowerCluster ? "DEMAND x" + str.tostring(lowerHits) : "DEMAND", style = label.style_label_up, color = color.new(chart.bg_color, tagOpacity), textcolor = demandEdge, size = size.tiny)
    lowerBirth := bar_index
    lowerBrokenAt := na
    lowerActive := true
    lastLowPivot := pivotLow
    lastLowIndex := pivotLowIndex

float upperTop = not na(upperBody) ? box.get_top(upperBody) : na
float upperBottom = not na(upperBody) ? box.get_bottom(upperBody) : na
float upperMid = not na(upperBody) ? math.avg(upperTop, upperBottom) : na
float lowerTop = not na(lowerBody) ? box.get_top(lowerBody) : na
float lowerBottom = not na(lowerBody) ? box.get_bottom(lowerBody) : na
float lowerMid = not na(lowerBody) ? math.avg(lowerTop, lowerBottom) : na

if upperActive and not na(upperBody)
    int upperScanBars = int(math.min(math.max(bar_index - box.get_left(upperBody), 0), maxScanBars))
    float upperBuyVol = 0.0
    float upperSellVol = 0.0
    int upperTouches = 0
    box.set_right(upperBody, bar_index + extendBars)
    box.set_right(upperUpperHalf, bar_index + extendBars)
    box.set_right(upperLowerHalf, bar_index + extendBars)
    line.set_x2(upperTopRail, bar_index + extendBars)
    line.set_x2(upperBottomRail, bar_index + extendBars)
    line.set_x2(upperEqRail, bar_index + extendBars)
    if not na(upperTagRail)
        line.set_x2(upperTagRail, box.get_left(upperBody) + 3)
    for i = 0 to upperScanBars
        bool touchedUpper = high[i] >= upperBottom and low[i] <= upperTop
        if touchedUpper
            upperTouches += 1
            upperBuyVol += close[i] > open[i] ? volume[i] : 0.0
            upperSellVol += close[i] <= open[i] ? volume[i] : 0.0
    float upperTotal = math.max(upperBuyVol + upperSellVol, 1.0)
    upperBuyShare := upperBuyVol / upperTotal
    upperSellShare := upperSellVol / upperTotal
    upperDeltaPct := (upperBuyVol - upperSellVol) / upperTotal * 100.0
    upperTouchTotal := upperTouches
    int upperAlpha = f_alpha(math.abs(upperDeltaPct) / 100.0, 76, 92)
    box.set_bgcolor(upperUpperHalf, color.new(supplyCol, upperDeltaPct <= 0 ? upperAlpha : upperAlpha + 6))
    box.set_bgcolor(upperLowerHalf, color.new(responseCol, upperDeltaPct > 0 ? upperAlpha : upperAlpha + 6))
    box.set_border_color(upperBody, upperHits >= 2 ? supplyCol : supplyEdge)
    box.set_text(upperBody, "SUPPLY | " + (upperDeltaPct <= 0 ? "Reject" : "Absorb"))
    box.set_text_color(upperBody, upperDeltaPct <= 0 ? supplyEdge : responseCol)
    line.set_color(upperTopRail, upperDeltaPct <= 0 ? supplyCol : supplyEdge)
    line.set_color(upperBottomRail, color.new(supplyEdge, 20))
    line.set_y1(upperEqRail, upperMid)
    line.set_y2(upperEqRail, upperMid)

if lowerActive and not na(lowerBody)
    int lowerScanBars = int(math.min(math.max(bar_index - box.get_left(lowerBody), 0), maxScanBars))
    float lowerBuyVol = 0.0
    float lowerSellVol = 0.0
    int lowerTouches = 0
    box.set_right(lowerBody, bar_index + extendBars)
    box.set_right(lowerUpperHalf, bar_index + extendBars)
    box.set_right(lowerLowerHalf, bar_index + extendBars)
    line.set_x2(lowerTopRail, bar_index + extendBars)
    line.set_x2(lowerBottomRail, bar_index + extendBars)
    line.set_x2(lowerEqRail, bar_index + extendBars)
    if not na(lowerTagRail)
        line.set_x2(lowerTagRail, box.get_left(lowerBody) + 3)
    for i = 0 to lowerScanBars
        bool touchedLower = high[i] >= lowerBottom and low[i] <= lowerTop
        if touchedLower
            lowerTouches += 1
            lowerBuyVol += close[i] > open[i] ? volume[i] : 0.0
            lowerSellVol += close[i] <= open[i] ? volume[i] : 0.0
    float lowerTotal = math.max(lowerBuyVol + lowerSellVol, 1.0)
    lowerBuyShare := lowerBuyVol / lowerTotal
    lowerSellShare := lowerSellVol / lowerTotal
    lowerDeltaPct := (lowerBuyVol - lowerSellVol) / lowerTotal * 100.0
    lowerTouchTotal := lowerTouches
    int lowerAlpha = f_alpha(math.abs(lowerDeltaPct) / 100.0, 76, 92)
    box.set_bgcolor(lowerUpperHalf, color.new(responseCol, lowerDeltaPct < 0 ? lowerAlpha : lowerAlpha + 6))
    box.set_bgcolor(lowerLowerHalf, color.new(demandCol, lowerDeltaPct >= 0 ? lowerAlpha : lowerAlpha + 6))
    box.set_border_color(lowerBody, lowerHits >= 2 ? demandCol : demandEdge)
    box.set_text(lowerBody, "DEMAND | " + (lowerDeltaPct >= 0 ? "Absorb" : "Fail"))
    box.set_text_color(lowerBody, lowerDeltaPct >= 0 ? demandEdge : responseCol)
    line.set_color(lowerBottomRail, lowerDeltaPct >= 0 ? demandCol : demandEdge)
    line.set_color(lowerTopRail, color.new(demandEdge, 20))
    line.set_y1(lowerEqRail, lowerMid)
    line.set_y2(lowerEqRail, lowerMid)

upperTop := not na(upperBody) ? box.get_top(upperBody) : na
upperBottom := not na(upperBody) ? box.get_bottom(upperBody) : na
upperMid := not na(upperBody) ? math.avg(upperTop, upperBottom) : na
lowerTop := not na(lowerBody) ? box.get_top(lowerBody) : na
lowerBottom := not na(lowerBody) ? box.get_bottom(lowerBody) : na
lowerMid := not na(lowerBody) ? math.avg(lowerTop, lowerBottom) : na

bool inUpperZone = upperActive and not na(upperTop) and high >= upperBottom and low <= upperTop
bool inLowerZone = lowerActive and not na(lowerTop) and high >= lowerBottom and low <= lowerTop
bool dualRange = upperActive and lowerActive and not na(upperBottom) and not na(lowerTop) and upperBottom > lowerTop
float auctionCeiling = dualRange ? upperBottom : na
float auctionFloor = dualRange ? lowerTop : na
float auctionMid = dualRange ? math.avg(auctionCeiling, auctionFloor) : na
bool inAuction = dualRange and close <= auctionCeiling and close >= auctionFloor

bool upperBreak = upperActive and not na(upperTop) and barstate.isconfirmed and breakoutQualityOk and (bodyBreakOnly ? close > upperTop : high > upperTop) and bar_index - nz(upperBirth, bar_index) >= agingBars
bool lowerBreak = lowerActive and not na(lowerBottom) and barstate.isconfirmed and breakoutQualityOk and (bodyBreakOnly ? close < lowerBottom : low < lowerBottom) and bar_index - nz(lowerBirth, bar_index) >= agingBars
bool upperRetest = showRetestTags and not upperActive and not na(upperBody) and not na(upperBrokenAt) and low <= upperTop and close >= upperBottom
bool lowerRetest = showRetestTags and not lowerActive and not na(lowerBody) and not na(lowerBrokenAt) and high >= lowerBottom and close <= lowerTop

if upperBreak and not na(upperBody)
    upperActive := false
    upperBrokenAt := bar_index
    box.set_bgcolor(upperBody, color.new(supplyCol, 95))
    box.set_border_color(upperBody, color.new(supplyEdge, 55))
    box.set_text(upperBody, "SUPPLY RELEASED")
    box.set_bgcolor(upperUpperHalf, color.new(supplyCol, 94))
    box.set_bgcolor(upperLowerHalf, color.new(responseCol, 95))
    line.set_color(upperTopRail, color.new(supplyEdge, 55))
    line.set_color(upperBottomRail, color.new(supplyEdge, 75))
    line.set_color(upperEqRail, color.new(eqCol, 70))
    if not na(upperTag)
        label.set_text(upperTag, "SUPPLY OFF")
        label.set_textcolor(upperTag, color.new(supplyEdge, 20))
    if showRetestTags
        label.new(bar_index, upperTop, "Release", style = label.style_label_up, color = color.new(chart.bg_color, tagOpacity), textcolor = supplyEdge, size = size.tiny)

if lowerBreak and not na(lowerBody)
    lowerActive := false
    lowerBrokenAt := bar_index
    box.set_bgcolor(lowerBody, color.new(demandCol, 95))
    box.set_border_color(lowerBody, color.new(demandEdge, 55))
    box.set_text(lowerBody, "DEMAND RELEASED")
    box.set_bgcolor(lowerUpperHalf, color.new(responseCol, 95))
    box.set_bgcolor(lowerLowerHalf, color.new(demandCol, 94))
    line.set_color(lowerTopRail, color.new(demandEdge, 75))
    line.set_color(lowerBottomRail, color.new(demandEdge, 55))
    line.set_color(lowerEqRail, color.new(eqCol, 70))
    if not na(lowerTag)
        label.set_text(lowerTag, "DEMAND OFF")
        label.set_textcolor(lowerTag, color.new(demandEdge, 20))
    if showRetestTags
        label.new(bar_index, lowerBottom, "Release", style = label.style_label_down, color = color.new(chart.bg_color, tagOpacity), textcolor = demandEdge, size = size.tiny)

if not upperActive and not na(upperBody) and not na(upperBrokenAt) and not showHistoricBroken and bar_index - upperBrokenAt > rangeFadeBars
    box.delete(upperBody)
    box.delete(upperUpperHalf)
    box.delete(upperLowerHalf)
    if not na(upperTopRail)
        line.delete(upperTopRail)
    if not na(upperBottomRail)
        line.delete(upperBottomRail)
    if not na(upperEqRail)
        line.delete(upperEqRail)
    if not na(upperTagRail)
        line.delete(upperTagRail)
    if not na(upperTag)
        label.delete(upperTag)
    upperBody := na
    upperUpperHalf := na
    upperLowerHalf := na
    upperTopRail := na
    upperBottomRail := na
    upperEqRail := na
    upperTagRail := na
    upperTag := na
    upperBrokenAt := na

if not lowerActive and not na(lowerBody) and not na(lowerBrokenAt) and not showHistoricBroken and bar_index - lowerBrokenAt > rangeFadeBars
    box.delete(lowerBody)
    box.delete(lowerUpperHalf)
    box.delete(lowerLowerHalf)
    if not na(lowerTopRail)
        line.delete(lowerTopRail)
    if not na(lowerBottomRail)
        line.delete(lowerBottomRail)
    if not na(lowerEqRail)
        line.delete(lowerEqRail)
    if not na(lowerTagRail)
        line.delete(lowerTagRail)
    if not na(lowerTag)
        label.delete(lowerTag)
    lowerBody := na
    lowerUpperHalf := na
    lowerLowerHalf := na
    lowerTopRail := na
    lowerBottomRail := na
    lowerEqRail := na
    lowerTagRail := na
    lowerTag := na
    lowerBrokenAt := na

if upperRetest and not na(upperTop)
    label.new(bar_index, upperTop, "Supply Retest", style = label.style_label_down, color = color.new(chart.bg_color, tagOpacity), textcolor = supplyEdge, size = size.tiny)
if lowerRetest and not na(lowerBottom)
    label.new(bar_index, lowerBottom, "Demand Retest", style = label.style_label_up, color = color.new(chart.bg_color, tagOpacity), textcolor = demandEdge, size = size.tiny)

upperTop := not na(upperBody) ? box.get_top(upperBody) : na
upperBottom := not na(upperBody) ? box.get_bottom(upperBody) : na
upperMid := not na(upperBody) ? math.avg(upperTop, upperBottom) : na
lowerTop := not na(lowerBody) ? box.get_top(lowerBody) : na
lowerBottom := not na(lowerBody) ? box.get_bottom(lowerBody) : na
lowerMid := not na(lowerBody) ? math.avg(lowerTop, lowerBottom) : na
inUpperZone := upperActive and not na(upperTop) and high >= upperBottom and low <= upperTop
inLowerZone := lowerActive and not na(lowerTop) and high >= lowerBottom and low <= lowerTop
dualRange := upperActive and lowerActive and not na(upperBottom) and not na(lowerTop) and upperBottom > lowerTop
auctionCeiling := dualRange ? upperBottom : na
auctionFloor := dualRange ? lowerTop : na
auctionMid := dualRange ? math.avg(auctionCeiling, auctionFloor) : na
inAuction := dualRange and close <= auctionCeiling and close >= auctionFloor

float upperAge = not na(upperBirth) ? bar_index - upperBirth : na
float lowerAge = not na(lowerBirth) ? bar_index - lowerBirth : na
float upperBalance = na(upperDeltaPct) ? na : 1.0 - math.abs(upperDeltaPct) / 100.0
float lowerBalance = na(lowerDeltaPct) ? na : 1.0 - math.abs(lowerDeltaPct) / 100.0
float rangeBalance = dualRange and not na(upperBalance) and not na(lowerBalance) ? math.avg(upperBalance, lowerBalance) : na
string upperState = f_state(upperActive, not upperActive and not na(upperBody), nz(upperDeltaPct, 0.0), nz(upperTouchTotal, 0), upperHits)
string lowerState = f_state(lowerActive, not lowerActive and not na(lowerBody), nz(lowerDeltaPct, 0.0), nz(lowerTouchTotal, 0), lowerHits)
string stateText = dualRange ? "Auction Boxed" : upperActive ? "Supply In Force" : lowerActive ? "Demand In Force" : not na(upperBody) or not na(lowerBody) ? "Post Break" : "Scanning"
string biasText = dualRange ? "Rotation Bias" : inUpperZone ? "Offer Response" : inLowerZone ? "Bid Response" : upperActive ? "Offer Above" : lowerActive ? "Bid Below" : "Neutral"

color candleColor = recolorCandles ? inUpperZone ? supplyEdge : inLowerZone ? demandEdge : inAuction ? responseCol : dualRange ? corridorCol : na : na
color zoneBg = showRangeCloud ? inAuction ? color.new(corridorCol, 92) : inUpperZone ? color.new(supplyCol, 95) : inLowerZone ? color.new(demandCol, 95) : na : na
bgcolor(zoneBg, title = "Range Context")
barcolor(candleColor)
plotcandle(recolorCandles ? open : na, recolorCandles ? high : na, recolorCandles ? low : na, recolorCandles ? close : na, color = candleColor, wickcolor = candleColor, bordercolor = candleColor)

upperTopPlot = plot(not na(upperTop) ? upperTop : na, "Supply Top", color = color.new(supplyEdge, upperActive ? 0 : 50), linewidth = 2, style = plot.style_linebr)
upperBottomPlot = plot(not na(upperBottom) ? upperBottom : na, "Supply Bottom", color = color.new(supplyEdge, upperActive ? 15 : 65), linewidth = 1, style = plot.style_linebr)
lowerTopPlot = plot(not na(lowerTop) ? lowerTop : na, "Demand Top", color = color.new(demandEdge, lowerActive ? 15 : 65), linewidth = 1, style = plot.style_linebr)
lowerBottomPlot = plot(not na(lowerBottom) ? lowerBottom : na, "Demand Bottom", color = color.new(demandEdge, lowerActive ? 0 : 50), linewidth = 2, style = plot.style_linebr)
auctionCeilingPlot = plot(showRangeCloud and not na(auctionCeiling) ? auctionCeiling : na, "Auction Ceiling", color = color.new(responseCol, 25), linewidth = 1, style = plot.style_linebr)
auctionFloorPlot = plot(showRangeCloud and not na(auctionFloor) ? auctionFloor : na, "Auction Floor", color = color.new(responseCol, 25), linewidth = 1, style = plot.style_linebr)
eqPlot = plot(showRangeCloud and not na(auctionMid) ? auctionMid : not na(upperMid) and upperActive ? upperMid : not na(lowerMid) and lowerActive ? lowerMid : na, "Equilibrium", color = color.new(eqCol, 5), linewidth = 1, style = plot.style_linebr)
fill(upperTopPlot, upperBottomPlot, color = not na(upperTop) ? color.new(supplyCol, upperActive ? 88 : 94) : na, title = "Supply Body")
fill(lowerTopPlot, lowerBottomPlot, color = not na(lowerTop) ? color.new(demandCol, lowerActive ? 88 : 94) : na, title = "Demand Body")
fill(auctionCeilingPlot, auctionFloorPlot, color = dualRange and showRangeCloud ? color.new(corridorCol, 90) : na, title = "Auction Corridor")

var table dash = table.new(position.top_right, 2, 6, bgcolor = color.new(color.rgb(8, 10, 17), 0), frame_color = color.new(chart.fg_color, 75), frame_width = 1, border_color = color.new(chart.fg_color, 90), border_width = 1)
if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Foundry", text_color = chart.fg_color, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 1, 0, stateText, text_color = dualRange ? responseCol : upperActive ? supplyEdge : lowerActive ? demandEdge : chart.fg_color, bgcolor = color.new(color.rgb(25, 30, 44), 0), text_size = f_size(dashSize))
    table.cell(dash, 0, 1, "Supply", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 1, upperState + " | x" + str.tostring(upperHits), text_color = upperActive ? supplyEdge : color.new(supplyEdge, 20), text_size = f_size(dashSize))
    table.cell(dash, 0, 2, "Demand", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 2, lowerState + " | x" + str.tostring(lowerHits), text_color = lowerActive ? demandEdge : color.new(demandEdge, 20), text_size = f_size(dashSize))
    table.cell(dash, 0, 3, "Balance", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 3, na(rangeBalance) ? biasText : str.tostring(rangeBalance * 100.0, "#.0") + "% | " + biasText, text_color = dualRange ? responseCol : chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 0, 4, "Delta", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 4, (na(upperDeltaPct) ? "na" : str.tostring(upperDeltaPct, "#.0")) + " / " + (na(lowerDeltaPct) ? "na" : str.tostring(lowerDeltaPct, "#.0")), text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 0, 5, "Touches", text_color = chart.fg_color, text_size = f_size(dashSize))
    table.cell(dash, 1, 5, (na(upperTouchTotal) ? "na" : str.tostring(upperTouchTotal)) + " / " + (na(lowerTouchTotal) ? "na" : str.tostring(lowerTouchTotal)), text_color = responseCol, text_size = f_size(dashSize))

alertcondition(enableAlerts and upperBreak, "Foundry Supply Release", "Price has released through the active supply zone.")
alertcondition(enableAlerts and lowerBreak, "Foundry Demand Release", "Price has released through the active demand zone.")
alertcondition(enableAlerts and upperRetest, "Foundry Supply Retest", "Price has retested a released supply zone.")
alertcondition(enableAlerts and lowerRetest, "Foundry Demand Retest", "Price has retested a released demand zone.")
alertcondition(enableAlerts and dualRange, "Foundry Auction Active", "Supply and demand are both active, forming a live auction corridor.")
alertcondition(enableAlerts and inUpperZone, "Foundry In Supply", "Price is interacting with the active supply zone.")
alertcondition(enableAlerts and inLowerZone, "Foundry In Demand", "Price is interacting with the active demand zone.")
alertcondition(enableAlerts and dualRange and not na(rangeBalance) and rangeBalance >= 0.65, "Foundry Balanced Auction", "The auction corridor is balanced enough to favor rotation.")
````
