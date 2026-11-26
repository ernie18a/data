# Liquidity Fracture [JOAT]

- url: https://www.tradingview.com/script/OPEoQFhp-Liquidity-Fracture-JOAT/
- type: indicator
- pine_id: PUB;34a98386a45e4674b1e903a6b3f22711
- version: 1.0

## Description

[b]Liquidity Fracture [JOAT][/b]

[b]Introduction[/b]

Liquidity Fracture is an open-source stop-hunt and liquidity sweep detection engine that identifies, classifies, and visualizes four distinct types of liquidity events in real time. The four types are: Swing Cluster Zones where retail stop orders accumulate, Wick Rejection Traps where engineered wick candles are designed to trigger stops, Sweep Events where price spikes through a level and recovers inside, and Volume Reversal Zones where institutional footprints appear as high-volume directional rejections.

The problem liquidity analysis solves is that the most reliable entry locations are not at obvious support and resistance levels — they are just beyond them, at the price points where the greatest concentration of stop-loss orders sit. When institutional order flow needs to fill large positions, it engineers moves into those stop clusters to provide the liquidity required. Liquidity Fracture maps those clusters, labels the sweep events when they occur, and records volume-backed reversal zones where the institutional absorption is visible in the data.

[image]https://www.tradingview.com/x/GW7dL94B/[/image]

[b]Core Concepts[/b]

[b]1. Four Zone Types and Their Rationale[/b]

Each zone type targets a different category of liquidity event:

Swing Cluster Zones mark recent pivot highs and lows — the locations where the majority of retail stop-loss orders are placed. Price regularly engineers moves into these clusters to trigger stops before reversing. These zones are drawn as boxes above pivot highs (sell-side liquidity above) and below pivot lows (buy-side liquidity below).

Wick Rejection Traps identify candles where the wick-to-body ratio exceeds a configurable threshold. A candle with a dominant upper wick closing near its lows is an engineered candle designed to trigger buy stops above the high before rejecting. The wick ratio determines whether a candle qualifies as a trap:

[pine]
wickUp   = high - math.max(open, close)
bodySize = math.abs(close - open)
isWickTrap = wickUp / (high - low) > wickThreshold
[/pine]

Sweep Events capture the core liquidity hunt pattern: price wicks through a tracked zone level and closes back inside. The sweep label fires at the closing bar of the event with a styled label indicating the direction (SWEEP up or down).

Volume Reversal Zones identify bars where volume exceeds a configurable multiple of the 20-bar average volume, price reversal is confirmed by a close in the opposite half of the candle, and the move represents a statistically significant displacement. These are the bars where institutional absorption of the sweep is most likely visible.

[b]2. Zone Distance and Deduplication[/b]

To prevent the chart from becoming cluttered with overlapping zones at the same price level, a minimum zone distance filter measured in ATR multiples prevents new zones from being drawn within that distance of an existing zone of the same type:

[pine]
minDist = atr * minZoneDist
// New zone only drawn if > minDist from any existing zone
[/pine]

The maximum zones per type setting caps how many of each zone type can exist simultaneously. When the cap is reached, the oldest zone is automatically removed as new ones are added.

[b]3. Heatmap Intensity[/b]

Each zone carries a heat intensity value based on how many times price has revisited it without sweeping through. Zones that price has respected multiple times increase in visual intensity — a darker, more opaque zone represents a higher-tested liquidity cluster that has proved significant. This provides immediate visual ranking of zone importance without requiring the trader to manually assess each zone.

[b]4. Sweep Event Detection and Labeling[/b]

A sweep is detected when price penetrates a zone's boundary and closes back inside during the same bar. The sweep label appears directly at the sweep bar using styled labels (SWEEP) with directional styling — label pointing up for bullish sweep (price wicked below a low zone and closed above it), label pointing down for bearish sweep (price wicked above a high zone and closed below it):

[pine]
bullSweep = low < zoneBottom and close > zoneBottom
bearSweep = high > zoneTop   and close < zoneTop
[/pine]

[b]5. Zone Type Labels[/b]

Each box drawn on the chart receives a text label in its upper corner identifying its zone type: SWING HI, SWING LO, WICK TRAP, or VOL REV. This allows traders to immediately understand what category of liquidity event they are looking at without needing to remember color assignments.

[image]https://www.tradingview.com/x/aIecG9Z4/[/image]

[b]Features[/b]

[list]
[*][b]Four liquidity zone types:[/b] Swing Cluster Zones, Wick Rejection Traps, Sweep Events, and Volume Reversal Zones — each independently togglable
[*][b]Styled sweep labels:[/b] SWEEP labels with directional pointing arrows at the exact bar where the wick-and-close confirmation occurs
[*][b]Zone type text labels:[/b] Every box labeled with its zone type (SWING HI, SWING LO, WICK TRAP, VOL REV) in the upper corner
[*][b]Heatmap intensity:[/b] Zone color opacity increases with each price revisit, visually ranking zone significance
[*][b]ATR-based zone distance filter:[/b] Minimum ATR distance between zones of the same type prevents overlapping or duplicate zones
[*][b]Volume spike detection:[/b] Configurable volume multiplier threshold for Volume Reversal Zone qualification
[*][b]Wick ratio threshold:[/b] Configurable wick-to-candle-range fraction for Wick Rejection Trap qualification
[*][b]Maximum zones per type:[/b] Cap on simultaneous zones per category with automatic oldest-zone removal
[*][b]Zone base transparency:[/b] Configurable transparency for all zone fills simultaneously
[*][b]Institutional dashboard (top right):[/b] Sweep count, active zone counts by type, ATR, and volume ratio
[*][b]Fully configurable colors:[/b] Each zone type has its own independent color input
[*][b]Sweep alerts:[/b] Separate alertconditions for bullish and bearish sweep events
[/list]

[b]Input Parameters[/b]

[b]Detection:[/b]
[list]
[*]Swing Lookback: Left/right pivot bars for swing zone detection (default: 20)
[*]Swing Threshold %: Minimum price move % for swing qualification (default: 2.0)
[*]Volume Spike Multiplier: Multiple of average volume required for Volume Reversal Zone (default: 2.0)
[*]Wick Ratio Threshold: Wick-to-range fraction for Wick Trap qualification (default: 0.6)
[*]ATR Length: ATR period for buffer and distance calculations (default: 14)
[*]ATR Buffer Multiplier: Zone size extension as ATR multiple (default: 0.5)
[*]Max Zones Per Type: Maximum simultaneous zones of each type (default: 5)
[*]Min Zone Distance (ATR): Minimum ATR distance between same-type zones (default: 2.0)
[/list]

[b]Display:[/b]
[list]
[*]Individual zone type toggles: Swing Cluster Zones, Wick Rejection Traps, Sweep Events, Volume Reversal Zones
[*]Heatmap Intensity toggle
[*]Show Zone Labels toggle
[*]Show Dashboard toggle
[*]Zone Base Transparency: 30-92 (default: 75)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify Active Liquidity Clusters[/b]
Swing Cluster Zones (red above, green below) mark where the nearest stop clusters sit. The most saturated (darkest) zones have been tested most frequently and represent the highest-concentration liquidity pools. These are the primary targets for engineered price moves.

[b]Step 2: Watch for Wick Trap Formations[/b]
Wick Rejection Trap zones appear when a candle forms with a disproportionately large wick. These candles are the mechanism by which stops are triggered — the wick penetrates the stop cluster while the close retreats. A Wick Trap zone followed by a Sweep event on the same level is a high-probability combination.

[b]Step 3: React to Sweep Labels[/b]
When a SWEEP label appears, a stop cluster has been penetrated and price has recovered inside in a single bar. This is the liquidity hunt completion pattern. A bullish sweep (below a low zone, close above) suggests buy-side liquidity was provided and a reversal is possible. Confirm with volume.

[b]Step 4: Use Volume Reversal Zones as Confirmation[/b]
Volume Reversal Zones mark where institutional absorption is most likely visible. A sweep into a cluster followed by a Volume Reversal Zone on the recovery bar provides the highest-confidence combination this indicator can produce.

[b]Step 5: Assess Zone Freshness[/b]
Freshly created zones (lighter color) have not been tested. Heavily revisited zones (darker) have withstood multiple price touches. Focus attention on the darkest zones — they represent the most significant concentration of resting orders.

[b]Indicator Limitations[/b]

[list]
[*]Swing zone detection uses pivot logic with a right-bar offset. Zones are confirmed several bars after the actual pivot, creating a slight lag in zone creation
[*]The volume spike filter relies on exchange-reported volume. On synthetic instruments, indices, or assets with thin or unreliable volume reporting, Volume Reversal Zones will not be accurate
[*]Zone distance filtering prevents duplicate zones, but in volatile, fast-moving markets, zones can form rapidly and crowd the chart before the maximum zone cap removes old ones
[*]Sweep detection requires the close to recover inside the zone on the same bar as the wick penetration. Multi-bar sweeps (where recovery takes multiple bars) are not detected as sweep events — the level simply becomes the new zone boundary
[*]This indicator identifies liquidity events. It does not provide directional entry signals or determine the probability that a reversal after a sweep will be sustained
[/list]

[b]Originality Statement[/b]

Liquidity Fracture is original in its simultaneous, unified detection and visualization of four distinct liquidity event types within a single indicator with a unified heatmap intensity system. This indicator is published because:

[list]
[*]The classification of four independent liquidity event types (swing cluster, wick trap, sweep, volume reversal) — each with its own detection logic, independent toggle, and color — into a single, unified zone management system is uncommon in published open-source Pine Script
[*]The heatmap intensity system that increases zone visual weight with each price revisit provides automatic, data-driven zone importance ranking without any manual assessment
[*]The zone deduplication system using ATR-based minimum distance prevents the false signal accumulation that occurs in naive pivot-based zone indicators that draw every pivot regardless of proximity
[*]The zone type labeling system (SWING HI, SWING LO, WICK TRAP, VOL REV) inside each box allows instant identification of event type without relying solely on color memory
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Liquidity zone detection and sweep signals are based on historical price and volume patterns. The identification of a sweep event does not guarantee a reversal, and zone levels can be violated without producing the expected reaction. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Liquidity Fracture [JOAT]", shorttitle="Liq Fracture [JOAT]", overlay=true,
     max_boxes_count=500, max_labels_count=500, max_lines_count=200)
// ─── INPUTS ────────────────────────────────────────────────────────────────────
grpDetect = "Detection"
lookback       = input.int(20,   "Swing Lookback",           minval=5,  maxval=100, group=grpDetect)
swingThreshold = input.float(2.0,"Swing Threshold %",        minval=0.5, maxval=10.0, step=0.1, group=grpDetect)
volumeMult     = input.float(2.0,"Volume Spike Multiplier",  minval=1.0, maxval=5.0, step=0.1, group=grpDetect)
wickThreshold  = input.float(0.6,"Wick Ratio Threshold",     minval=0.3, maxval=0.9, step=0.05, group=grpDetect)
atrLength      = input.int(14,   "ATR Length",               minval=1,  maxval=50,  group=grpDetect)
atrMult        = input.float(0.5,"ATR Buffer Multiplier",    minval=0.1, maxval=2.0, step=0.1, group=grpDetect)
maxZones       = input.int(5,    "Max Zones Per Type",       minval=2,  maxval=20,  group=grpDetect)
minZoneDist    = input.float(2.0,"Min Zone Distance (ATR)",  minval=1.0, maxval=10.0, step=0.5, group=grpDetect)

grpDisplay = "Display"
showSwing    = input.bool(true, "Swing Cluster Zones",   group=grpDisplay)
showWick     = input.bool(true, "Wick Rejection Traps",  group=grpDisplay)
showSweep    = input.bool(true, "Sweep Events",          group=grpDisplay)
showVolRev   = input.bool(true, "Volume Reversal Zones", group=grpDisplay)
showHeatmap  = input.bool(true, "Heatmap Intensity",     group=grpDisplay)
showDash     = input.bool(true, "Show Dashboard",        group=grpDisplay)
showZoneLbls = input.bool(true, "Show Zone Labels",      group=grpDisplay,
     tooltip="Show zone type text label inside each zone box.")
transp       = input.int(75,    "Zone Base Transparency", minval=30, maxval=92, group=grpDisplay)

grpColors = "Colors"
colSwingHi = input.color(color.new(#B71C1C, 0), "Swing High Zones",  group=grpColors)
colSwingLo = input.color(color.new(#1B5E20, 0), "Swing Low Zones",   group=grpColors)
colWick    = input.color(color.new(#6A1B9A, 0), "Wick Trap Zones",   group=grpColors)
colSweep   = input.color(color.new(#E65100, 0), "Sweep Events",      group=grpColors)
colVolRev  = input.color(color.new(#01579B, 0), "Volume Reversals",  group=grpColors)

// ─── CALCULATIONS ──────────────────────────────────────────────────────────────
atr       = ta.atr(atrLength)
buffer    = atr * atrMult
minDist   = atr * minZoneDist
avgVolume = ta.sma(volume, 20)

// Pivot detection (offset by rightBars to avoid lookahead)
leftBars  = math.floor(lookback / 2)
rightBars = math.floor(lookback / 2)
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low,   leftBars, rightBars)

// ─── CONSOLIDATION DETECTION ───────────────────────────────────────────────────
var float consHigh  = na
var float consLow   = na
var int   consStart = na
var bool  inCons    = false

rangePercent = (high - low) / close * 100
if rangePercent < swingThreshold / 2
    if not inCons
        consHigh  := high
        consLow   := low
        consStart := bar_index
        inCons    := true
    else
        consHigh := math.max(consHigh, high)
        consLow  := math.min(consLow, low)
else
    if inCons and (bar_index - consStart) > 3
        inCons := false
    else
        inCons := false

// ─── SWEEP DETECTION ───────────────────────────────────────────────────────────
var float lastPivHi    = na
var float lastPivLo    = na
var int   lastPivHiBar = na
var int   lastPivLoBar = na
var bool  hiSwept      = false
var bool  loSwept      = false

if not na(ph)
    lastPivHi    := ph
    lastPivHiBar := bar_index - rightBars
    hiSwept      := false
if not na(pl)
    lastPivLo    := pl
    lastPivLoBar := bar_index - rightBars
    loSwept      := false

bullSweep = not loSwept and not na(lastPivLo) and low < lastPivLo and close > lastPivLo and volume >= avgVolume and barstate.isconfirmed
bearSweep = not hiSwept and not na(lastPivHi) and high > lastPivHi and close < lastPivHi and volume >= avgVolume and barstate.isconfirmed

if bullSweep
    loSwept := true
if bearSweep
    hiSwept := true

// ─── WICK TRAP DETECTION ───────────────────────────────────────────────────────
bodySize   = math.abs(close - open)
upperWick  = high - math.max(open, close)
lowerWick  = math.min(open, close) - low
totalRange = high - low

isUpWickTrap   = totalRange > atr * 0.5 and totalRange > 0
     and upperWick / totalRange > wickThreshold
     and close < open
     and bodySize < totalRange * 0.3
     and volume > avgVolume
     and barstate.isconfirmed

isDownWickTrap = totalRange > atr * 0.5 and totalRange > 0
     and lowerWick / totalRange > wickThreshold
     and close > open
     and bodySize < totalRange * 0.3
     and volume > avgVolume
     and barstate.isconfirmed

// ─── VOLUME REVERSAL DETECTION ─────────────────────────────────────────────────
isHighVol      = volume > avgVolume * volumeMult
isReversalUp   = isHighVol and close[1] < open[1] and close > open and close > close[1] and (close - low) > (high - close) * 2 and barstate.isconfirmed
isReversalDown = isHighVol and close[1] > open[1] and close < open and close < close[1] and (high - close) > (close - low) * 2 and barstate.isconfirmed

// ─── ZONE MANAGEMENT ───────────────────────────────────────────────────────────
var array<float> swingHiZones = array.new<float>()
var array<float> swingLoZones = array.new<float>()
var array<float> wickZones    = array.new<float>()
var array<float> volRevZones  = array.new<float>()

// Lifetime counters for dashboard
var int totalSwingHiZones = 0
var int totalSwingLoZones = 0
var int totalWickTraps    = 0
var int totalSweeps       = 0
var int totalVolRevs      = 0

isTooClose(float price, array<float> zones) =>
    result = false
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            if math.abs(price - array.get(zones, i)) < minDist
                result := true
                break
    result

addToZone(array<float> zones, float price, int cap) =>
    added = false
    if not isTooClose(price, zones)
        array.push(zones, price)
        if array.size(zones) > cap
            array.shift(zones)
        added := true
    added

// Heatmap intensity: proportion of recent bars that touched this level
calcIntensity(float price, int scanLen) =>
    int hits    = 0
    int maxScan = math.min(scanLen - 1, bar_index)
    for i = 0 to maxScan
        if math.abs(price - high[i]) < buffer or math.abs(price - low[i]) < buffer
            hits += 1
    float(hits) / float(scanLen)

// ─── SWING CLUSTER ZONES ───────────────────────────────────────────────────────
if showSwing and not na(ph) and barstate.isconfirmed
    if addToZone(swingHiZones, ph, maxZones)
        totalSwingHiZones += 1
        intensity  = showHeatmap ? calcIntensity(ph, 20) : 0.0
        zoneAlpha  = showHeatmap ? math.round(transp - intensity * 35) : transp
        int zStart = bar_index - rightBars - 3
        int zEnd   = bar_index + 20
        box.new(zStart, ph + buffer, zEnd, ph - buffer,
             bgcolor=color.new(colSwingHi, zoneAlpha),
             border_color=color.new(colSwingHi, math.max(zoneAlpha - 20, 0)), border_width=1)
        if showZoneLbls
            label.new(zStart + 1, ph + buffer * 0.4, "SWING HI",
                 style=label.style_none, textcolor=color.new(colSwingHi, 20), size=size.tiny)

if showSwing and not na(pl) and barstate.isconfirmed
    if addToZone(swingLoZones, pl, maxZones)
        totalSwingLoZones += 1
        intensity  = showHeatmap ? calcIntensity(pl, 20) : 0.0
        zoneAlpha  = showHeatmap ? math.round(transp - intensity * 35) : transp
        int zStart = bar_index - rightBars - 3
        int zEnd   = bar_index + 20
        box.new(zStart, pl + buffer, zEnd, pl - buffer,
             bgcolor=color.new(colSwingLo, zoneAlpha),
             border_color=color.new(colSwingLo, math.max(zoneAlpha - 20, 0)), border_width=1)
        if showZoneLbls
            label.new(zStart + 1, pl - buffer * 0.4, "SWING LO",
                 style=label.style_none, textcolor=color.new(colSwingLo, 20), size=size.tiny)

// ─── WICK TRAP ZONES ───────────────────────────────────────────────────────────
if showWick and isUpWickTrap
    if addToZone(wickZones, high, maxZones)
        totalWickTraps += 1
        box.new(bar_index - 1, high + buffer, bar_index + 12, high - buffer,
             bgcolor=color.new(colWick, transp),
             border_color=color.new(colWick, math.max(transp - 15, 0)), border_width=1)
        if showZoneLbls
            label.new(bar_index - 1, high + buffer * 0.4, "WICK TRAP",
                 style=label.style_none, textcolor=color.new(colWick, 20), size=size.tiny)

if showWick and isDownWickTrap
    if addToZone(wickZones, low, maxZones)
        totalWickTraps += 1
        box.new(bar_index - 1, low + buffer, bar_index + 12, low - buffer,
             bgcolor=color.new(colWick, transp),
             border_color=color.new(colWick, math.max(transp - 15, 0)), border_width=1)
        if showZoneLbls
            label.new(bar_index - 1, low - buffer * 0.4, "WICK TRAP",
                 style=label.style_none, textcolor=color.new(colWick, 20), size=size.tiny)

// ─── SWEEP EVENT MARKERS ───────────────────────────────────────────────────────
// Bull sweep = sell-side liquidity grabbed below swing low, price recovers up.
// Bear sweep = buy-side liquidity grabbed above swing high, price recovers down.
if showSweep and bullSweep
    totalSweeps += 1
    label.new(bar_index, low,
         "SWEEP",
         style=label.style_label_up,
         color=color.new(#E65100, 35),
         textcolor=color.white,
         size=size.small)

if showSweep and bearSweep
    totalSweeps += 1
    label.new(bar_index, high,
         "SWEEP",
         style=label.style_label_down,
         color=color.new(#E65100, 35),
         textcolor=color.white,
         size=size.small)

// ─── VOLUME REVERSAL ZONES ─────────────────────────────────────────────────────
if showVolRev and isReversalUp
    if addToZone(volRevZones, low, maxZones)
        totalVolRevs += 1
        box.new(bar_index - 1, low + buffer, bar_index + 12, low - buffer,
             bgcolor=color.new(colVolRev, transp),
             border_color=color.new(colVolRev, math.max(transp - 15, 0)), border_width=1)
        if showZoneLbls
            label.new(bar_index - 1, low - buffer * 0.4, "VOL REV",
                 style=label.style_none, textcolor=color.new(colVolRev, 20), size=size.tiny)

if showVolRev and isReversalDown
    if addToZone(volRevZones, high, maxZones)
        totalVolRevs += 1
        box.new(bar_index - 1, high + buffer, bar_index + 12, high - buffer,
             bgcolor=color.new(colVolRev, transp),
             border_color=color.new(colVolRev, math.max(transp - 15, 0)), border_width=1)
        if showZoneLbls
            label.new(bar_index - 1, high + buffer * 0.4, "VOL REV",
                 style=label.style_none, textcolor=color.new(colVolRev, 20), size=size.tiny)

// ─── DASHBOARD ─────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 11,
     bgcolor=color.new(#0D1117, 5),
     border_color=color.new(#1A2332, 0),
     border_width=1,
     frame_color=color.new(#E65100, 50),
     frame_width=1)

if barstate.islast and showDash
    color DARK_BG = color.new(#0D1117, 0)
    color SEP_BG  = color.new(#080D13, 0)
    color LBL_C   = color.new(#546E7A, 0)

    int   totActive  = array.size(swingHiZones) + array.size(swingLoZones) + array.size(wickZones) + array.size(volRevZones)
    int   totLifetime = totalSwingHiZones + totalSwingLoZones + totalWickTraps + totalVolRevs

    // Row 0: Header
    table.cell(dash, 0, 0, "LIQUIDITY FRACTURE", text_color=color.new(#ECEFF1, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[JOAT]",             text_color=color.new(#E65100, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 1: Separator
    table.cell(dash, 0, 1, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 1, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 2: Swing Hi Zones
    table.cell(dash, 0, 2, "Swing Hi Zones",  text_color=LBL_C, text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 2,
         str.tostring(array.size(swingHiZones)) + " active / " + str.tostring(totalSwingHiZones) + " total",
         text_color=color.new(colSwingHi, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 3: Swing Lo Zones
    table.cell(dash, 0, 3, "Swing Lo Zones",  text_color=LBL_C, text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 3,
         str.tostring(array.size(swingLoZones)) + " active / " + str.tostring(totalSwingLoZones) + " total",
         text_color=color.new(colSwingLo, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 4: Wick Traps
    table.cell(dash, 0, 4, "Wick Traps",      text_color=LBL_C, text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(totalWickTraps),
         text_color=color.new(colWick, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 5: Sweeps
    table.cell(dash, 0, 5, "Sweeps",          text_color=LBL_C, text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(totalSweeps),
         text_color=color.new(colSweep, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 6: Vol Reversals
    table.cell(dash, 0, 6, "Vol Reversals",   text_color=LBL_C, text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(totalVolRevs),
         text_color=color.new(colVolRev, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 7: Separator
    table.cell(dash, 0, 7, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 7, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 8: Active / Total summary
    table.cell(dash, 0, 8, "Active Zones",    text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(totActive) + " / " + str.tostring(totLifetime) + " lifetime",
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 9: ATR Buffer
    table.cell(dash, 0, 9, "ATR Buffer",      text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(buffer, format.mintick),
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 10: Volume Mult
    table.cell(dash, 0, 10, "Vol Threshold",  text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(volumeMult, "#.#") + "x avg",
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(bullSweep,      "Bullish Liquidity Sweep",  "Liquidity Fracture: Sell-side swept — potential reversal up")
alertcondition(bearSweep,      "Bearish Liquidity Sweep",  "Liquidity Fracture: Buy-side swept — potential reversal down")
alertcondition(isUpWickTrap,   "Bearish Wick Trap",        "Liquidity Fracture: Upper wick rejection trap formed")
alertcondition(isDownWickTrap, "Bullish Wick Trap",        "Liquidity Fracture: Lower wick rejection trap formed")
alertcondition(isReversalUp,   "Bullish Volume Reversal",  "Liquidity Fracture: High-volume bullish reversal")
alertcondition(isReversalDown, "Bearish Volume Reversal",  "Liquidity Fracture: High-volume bearish reversal")
````
