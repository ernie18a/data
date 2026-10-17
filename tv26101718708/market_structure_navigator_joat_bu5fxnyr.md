# Market Structure Navigator [JOAT]

- url: https://www.tradingview.com/script/BU5FxNyR-Market-Structure-Navigator-JOAT/
- type: indicator
- pine_id: PUB;8e81349e822a4eb9a4a8c2d00c649f76
- version: 1.0

## Description

[b]Market Structure Navigator [JOAT][/b]

[b]Introduction[/b]

Market structure is one of the most widely discussed concepts in technical analysis, yet most tools that attempt to visualize it reduce swing highs and swing lows to single price points. In practice, price rarely reverses at a precise tick level — it reacts within a [i]zone[/i], which may span several ATR units depending on the instrument and timeframe. This distinction matters: treating a level as a point rather than a zone leads to false breaks being mistaken for genuine structural shifts.

The Market Structure Navigator [JOAT] addresses this by modeling every significant swing high and swing low as an ATR-based zone with measurable thickness. It tracks two layers of structure simultaneously — external (major) pivots that define the larger-degree trend, and internal (minor) pivots that provide context within that trend. Each zone passes through a three-state lifecycle, and structural breaks are automatically classified as either Break of Structure (BOS) or Change of Character (CHoCH), giving you an immediate read on whether a break confirms the existing trend or signals a potential reversal.

This is an [i]overlay[/i] indicator — all elements are drawn directly on the price chart.

[image]https://www.tradingview.com/x/bXUZHtTu/[/image]
---

[b]Core Concepts[/b]

[b]Dual-Layer Structure: External and Internal[/b]

The indicator identifies two categories of structural pivots using TradingView's built-in pivot functions:

[list]
[*][b]External structure (major):[/b] Pivots requiring a configurable number of bars on each side (default 20). These are the significant swing highs and lows that define the broader trend context. They update less frequently and represent the higher-degree market structure.
[*][b]Internal structure (minor):[/b] Pivots requiring fewer bars on each side (default 7). These fire more frequently and capture the sub-swings that occur within the larger structural moves.
[/list]

This dual-layer approach mirrors how institutional analysis treats structure: external levels define the direction of the larger trend; internal levels provide precision context for entries and exits within that trend.

[b]Zone Geometry and ATR Thickness[/b]

Rather than marking a pivot as a single horizontal line, each pivot is rendered as a rectangular zone. The zone's top and bottom are calculated as:

[pine]
zoneTop = pivotPrice + (ATR * zoneAtrMult)
zoneBottom = pivotPrice - (ATR * zoneAtrMult)
[/pine]

The default ATR multiplier is 0.5, meaning the zone extends half an ATR above and below the pivot price. This thickness is dynamic — it adjusts to the current volatility of the instrument rather than using a fixed pip or point value. Zones extend to the right as new bars form, keeping them visible as price approaches.

[b]Three-State Zone Lifecycle[/b]

Every zone passes through three possible states:

[list]
[*][b]Active (State 0):[/b] The zone has formed and not yet been tested. It extends to the right as bars pass, representing untested support or resistance. This is the most significant state — an active zone has not had its interest absorbed.
[*][b]Swept (State 1):[/b] Price has reached the midpoint of the zone (configurable as either a wick touch or a close through the midpoint). A swept zone has been tested and shows that some activity occurred at that level. It may have weakened but is not yet confirmed as broken.
[*][b]Broken (State 2):[/b] Price has closed decisively beyond the zone boundary (above the top for a resistance zone, below the bottom for a support zone). A broken zone stops extending. This state marks the structural failure of that level.
[/list]

This lifecycle gives actionable information that a single horizontal line cannot. An active zone is very different from a swept zone even if they appear at the same price level.

[b]BOS and CHoCH Classification[/b]

When price breaks through the last significant external high or low, the indicator determines whether the break is:

[list]
[*][b]Break of Structure (BOS):[/b] The break occurs in the [i]same direction[/i] as the current trend. A bullish BOS is a higher high that extends a confirmed uptrend; a bearish BOS is a lower low extending a downtrend. BOS signals trend continuation.
[*][b]Change of Character (CHoCH):[/b] The break occurs [i]against[/i] the current trend direction. A CHoCH in a downtrend means price has broken above the last significant swing high — a structural signal that the trend may be reversing. CHoCH signals a potential regime shift, not a confirmed reversal.
[/list]

Both external and internal structural breaks are tracked separately. An internal CHoCH during an external downtrend, for example, may represent a short-term countertrend move within a larger bearish structure — context that a single-layer tool would miss.

[b]Momentum Normalization[/b]

Momentum is calculated as the normalized price change:

[pine]
momentum = priceChange / stdev(close, lookback)
[/pine]

This expresses the size of recent price movement in terms of its own standard deviation, making the momentum reading comparable across different instruments and volatility regimes.

[b]Target Arrows[/b]

When an internal structural break occurs, the indicator draws a directional arrow label pointing toward the next significant external level. This provides a visual read on where price may be targeting within the larger structural context.

---

[b]Features[/b]

[list]
[*]Dual-layer structure detection: external major pivots and internal minor pivots tracked independently
[*]ATR-dynamic zone thickness — zones adapt to current instrument volatility
[*]Three-state zone lifecycle: Active, Swept, Broken — each visually distinct
[*]Automatic BOS vs. CHoCH classification for both external and internal breaks
[*]Configurable sweep mode: wick-based (high/low touches midpoint) or close-based (close through midpoint)
[*]Equal high/low detection with configurable ATR tolerance to flag double tops/bottoms
[*]Target arrows on internal breaks pointing toward the next external level
[*]Dashboard table showing trend state, momentum, active zone counts, last known structural levels, and last break type
[*]Full visual toggle controls for all overlay elements
[*]Maximum zone count cap per type to maintain chart performance
[/list]

---

[b]Dashboard Table[/b]

A table displayed at the top-right of the chart provides a live summary of structural conditions:

[list]
[*][b]Ext Trend:[/b] Current external trend direction (Bullish / Bearish)
[*][b]Int Trend:[/b] Current internal trend direction
[*][b]Momentum:[/b] Normalised momentum value
[*][b]Ext Zones Active:[/b] Number of currently active external zones
[*][b]Int Zones Active:[/b] Number of currently active internal zones
[*][b]Last Ext High / Low:[/b] Price level of the most recent significant external pivot high and low
[*][b]Last Break:[/b] The most recent break type (eBOS, eCHoCH, iBOS, iCHoCH)
[/list]

---

[b]Color System[/b]

[list]
[*]External high zones: red
[*]External low zones: white
[*]Internal high zones: teal
[*]Internal low zones: blue
[*]BOS labels: green
[*]CHoCH labels: red
[/list]

This color separation allows you to immediately distinguish between the two structural layers without reading labels.

---

[image]https://www.tradingview.com/x/qAt5jpFZ/[/image]

[b]Input Parameters[/b]

[list]
[*][b]External Pivot Length[/b] (default 20) — bars required on each side for a major pivot to confirm
[*][b]Internal Pivot Length[/b] (default 7) — bars required on each side for a minor pivot to confirm
[*][b]ATR Length[/b] (default 14) — ATR period used for zone thickness calculation
[*][b]Zone ATR Multiplier[/b] (default 0.5) — controls how wide each zone is relative to ATR
[*][b]Equal H/L Tolerance[/b] (default 0.3 ATR) — how close two pivots must be to be considered equal highs or lows
[*][b]Sweep Mode[/b] (Wick / Close) — whether zone sweeps are triggered by wick touch or candle close through the midpoint
[*][b]Max Zones Per Type[/b] (default 40) — caps the number of active zones drawn per category to preserve chart performance
[*][b]BOS Lookback[/b] (default 30) — bars looked back when checking for structural breaks
[*][b]Visual Toggles[/b] — individual controls for zones, BOS/CHoCH labels, target arrows, and the dashboard table
[/list]

---

[b]How to Use[/b]

[list]
[*]Apply to any chart. The indicator will begin plotting zones as enough bars form to confirm pivots at the chosen lengths.
[*]Allow sufficient historical bars to load so that the external pivots have time to confirm — with extLen set to 20, a pivot requires 20 bars after the swing point before it is officially plotted.
[*]Read the external layer first. The external trend (eBOS/eCHoCH sequence) tells you the larger-degree direction. Trade in alignment with this unless you have strong reason to fade it.
[*]Use the internal layer for timing. Internal CHoCH events within an external uptrend can signal pullback entries; internal BOS events in the direction of the external trend can confirm continuation.
[*]Active zones are the most significant. A first-touch of an active zone is generally more meaningful than a return to a swept or broken zone.
[*]When price approaches a zone, check the sweep mode setting and monitor whether price is reaching the midpoint (sweep) or closing through the boundary (break).
[*]The target arrow on an internal break shows the next external level — this is a reference, not a guaranteed target.
[/list]

---

[b]Limitations[/b]

[list]
[*]Pivot detection is inherently lagging. A pivot at bar N is only confirmed after N + extLen (or intLen) additional bars have formed. This means zones appear after the fact — the exact pivot price was in the past by the time the zone is drawn.
[*]With longer pivot lengths, the indicator requires more historical bars to display meaningful structure. On short lookback windows or when first applied to a chart, the initial display may show few or no zones until sufficient pivot confirmation has accumulated.
[*]ATR-based zone thickness means zone width changes with volatility. During high-volatility periods, zones become wider and may overlap. During compressed volatility, zones are narrower. Adjust the ATR multiplier if zones are too wide or too narrow for your preferred trading style.
[*]The BOS/CHoCH classification is based on the direction of the [i]previous break[/i] relative to the current one. In choppy, range-bound markets, rapid BOS/CHoCH alternation is possible and does not necessarily indicate a trend — it may simply reflect noise.
[*]Zone lifecycle states reflect price behavior relative to the zone midpoint and boundary. They do not predict whether a swept zone will hold or whether a broken zone will become a new support/resistance level.
[*]Maximum zone count limits (default 40 per type) are necessary to maintain chart performance. On instruments or timeframes with many pivot formations, older zones will be removed as new ones are added.
[*]No indicator can classify market structure with certainty in real time. CHoCH signals a potential reversal; it does not confirm one. Always apply additional judgment.
[/list]

---

[b]Originality Statement[/b]

The distinguishing design decisions in this indicator are: zone-based pivot modeling, the three-state lifecycle, and the integrated dual-layer structure system.

Most structure tools mark a swing high or low as a horizontal line at a single price. This indicator models each pivot as a zone with ATR-derived thickness, acknowledging that price reactions do not occur at a tick but within a range that varies with the instrument's current volatility. A 0.5 ATR zone around a pivot is a more honest representation of where liquidity and interest are likely to cluster.

The three-state lifecycle (Active → Swept → Broken) adds information that static horizontal lines cannot convey. An active zone that has never been tested is categorically different from one that has seen a wick test — and both are different from a zone that has been fully broken. Treating these three states identically discards relevant context.

The dual-layer architecture (external major + internal minor) is not simply running the same algorithm twice at different sensitivities. The external layer provides the trend framework; the internal layer provides the tactical sub-structure within it. The BOS/CHoCH classification connects these two layers — an internal CHoCH is interpreted in the context of the external trend direction, not in isolation.

---

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any security. All trading involves risk, including the possible loss of principal. Past indicator performance does not guarantee future results. Always conduct your own research and consult a qualified financial professional before making any trading decisions.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Market Structure Navigator [JOAT]", shorttitle="MSN [JOAT]", overlay=true,
  max_boxes_count=500, max_labels_count=300, max_lines_count=300)

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM TYPES
// ─────────────────────────────────────────────────────────────────────────────
type StructurePoint
    float price
    int   barIdx
    bool  isBroken

type TrendScore
    float momentum
    int   direction

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpExt  = "External Structure (Major)"
extLen  = input.int(20, "External Pivot Lookback", minval=5, maxval=100, group=grpExt)
showExt = input.bool(true, "Show External Zones", group=grpExt)

grpInt  = "Internal Structure (Minor)"
intLen  = input.int(7, "Internal Pivot Lookback", minval=2, maxval=30, group=grpInt)
showInt = input.bool(true, "Show Internal Zones", group=grpInt)

grpZone = "Zone Settings"
atrLen      = input.int(14, "ATR Length", minval=1, maxval=50, group=grpZone)
zoneAtrMult = input.float(0.5, "Zone Height (ATR mult)", minval=0.1, maxval=3.0, step=0.05, group=grpZone)
eqTolAtr    = input.float(0.3, "Equal H/L Tolerance (ATR)", minval=0.05, maxval=2.0, step=0.05, group=grpZone)
sweepMode   = input.string("Wick", "Sweep Mode", options=["Wick","Close"], group=grpZone)
maxZones    = input.int(40, "Max Zones Per Type", minval=5, maxval=100, group=grpZone)

grpBOS  = "BOS / CHoCH"
showBOS = input.bool(true, "Show BOS / CHoCH Labels", group=grpBOS)
bosLen  = input.int(30, "Structure Trend Lookback", minval=5, maxval=100, group=grpBOS)

grpVis  = "Visual"
showTgt = input.bool(true, "Show Target Arrows (Internal→External)", group=grpVis)
showTbl = input.bool(true, "Show Dashboard Table", group=grpVis)

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────
extHighC   = color.rgb(230, 30, 60)     // Red — external high zone
extLowC    = color.rgb(255, 255, 255)   // White — external low zone
intHighC   = color.rgb(77, 209, 224)    // Teal — internal high zone
intLowC    = color.rgb(9, 143, 222)     // Blue — internal low zone
bullStrC   = color.rgb(45, 255, 48)     // Green — bullish BOS/CHoCH
bearStrC   = color.rgb(255, 3, 3)       // Red — bearish BOS/CHoCH
bgDark     = color.rgb(10, 14, 22)
textLight  = color.rgb(220, 225, 235)
textDim    = color.rgb(100, 110, 130)
neutralCol = color.rgb(130, 140, 160)
bullColor  = color.rgb(92, 240, 215)
bearColor  = color.rgb(179, 42, 195)

// ─────────────────────────────────────────────────────────────────────────────
// CORE ATR
// ─────────────────────────────────────────────────────────────────────────────
atr = ta.atr(atrLen)
zoneH = atr * zoneAtrMult

// ─────────────────────────────────────────────────────────────────────────────
// PIVOT DETECTION
// ─────────────────────────────────────────────────────────────────────────────
extPH = ta.pivothigh(high, extLen, extLen)
extPL = ta.pivotlow(low,  extLen, extLen)
intPH = ta.pivothigh(high, intLen, intLen)
intPL = ta.pivotlow(low,  intLen, intLen)

// ─────────────────────────────────────────────────────────────────────────────
// ZONE STORAGE ARRAYS
// ─────────────────────────────────────────────────────────────────────────────
// External zones
var box[]   extBoxes  = array.new<box>()
var bool[]  extIsHigh = array.new<bool>()
var int[]   extState  = array.new<int>()    // 0=active, 1=swept, 2=broken
var float[] extTop    = array.new<float>()
var float[] extBot    = array.new<float>()
var int[]   extBarIdx = array.new<int>()

// Internal zones
var box[]   intBoxes  = array.new<box>()
var bool[]  intIsHigh = array.new<bool>()
var int[]   intState  = array.new<int>()
var float[] intTop    = array.new<float>()
var float[] intBot    = array.new<float>()
var int[]   intBarIdx = array.new<int>()

// Structure tracking for BOS/CHoCH
var float lastExtHigh = na
var float lastExtLow  = na
var int   lastExtHighBar = 0
var int   lastExtLowBar  = 0
var int   extTrend    = 0     // 1=bull, -1=bear, 0=neutral

// BOS / CHoCH line arrays
var line[] bosLines   = array.new<line>()
var label[] bosLabels = array.new<label>()

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: ZONE TRANSPARENCY BY STATE
// ─────────────────────────────────────────────────────────────────────────────
get_fill_transp(state) =>
    state == 0 ? 86 : state == 1 ? 93 : 97

get_border_transp(state) =>
    state == 0 ? 45 : state == 1 ? 65 : 80

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: ADD ZONE BOX
// ─────────────────────────────────────────────────────────────────────────────
add_zone(isHigh, topP, botP, pivBar, isExt) =>
    zColor = isExt ? (isHigh ? extHighC : extLowC) : (isHigh ? intHighC : intLowC)
    bx = box.new(pivBar, topP, bar_index + 20, botP,
      border_color=color.new(zColor, 45),
      border_width=1,
      bgcolor=color.new(zColor, 86),
      extend=extend.right)
    bx

// ─────────────────────────────────────────────────────────────────────────────
// ADD NEW EXTERNAL ZONES
// ─────────────────────────────────────────────────────────────────────────────
if not na(extPH) and showExt
    pivBar = bar_index - extLen
    topP   = extPH + zoneH
    botP   = extPH
    bx     = add_zone(true, topP, botP, pivBar, true)
    array.push(extBoxes,  bx)
    array.push(extIsHigh, true)
    array.push(extState,  0)
    array.push(extTop,    topP)
    array.push(extBot,    botP)
    array.push(extBarIdx, pivBar)
    // Update last high for BOS tracking
    lastExtHigh    := extPH
    lastExtHighBar := pivBar
    if extTrend == 1
        extTrend := 1
    // Manage array size
    if array.size(extBoxes) > maxZones
        box.delete(array.shift(extBoxes))
        array.shift(extIsHigh)
        array.shift(extState)
        array.shift(extTop)
        array.shift(extBot)
        array.shift(extBarIdx)

if not na(extPL) and showExt
    pivBar = bar_index - extLen
    topP   = extPL
    botP   = extPL - zoneH
    bx     = add_zone(false, topP, botP, pivBar, true)
    array.push(extBoxes,  bx)
    array.push(extIsHigh, false)
    array.push(extState,  0)
    array.push(extTop,    topP)
    array.push(extBot,    botP)
    array.push(extBarIdx, pivBar)
    lastExtLow    := extPL
    lastExtLowBar := pivBar
    if array.size(extBoxes) > maxZones
        box.delete(array.shift(extBoxes))
        array.shift(extIsHigh)
        array.shift(extState)
        array.shift(extTop)
        array.shift(extBot)
        array.shift(extBarIdx)

// ─────────────────────────────────────────────────────────────────────────────
// ADD NEW INTERNAL ZONES
// ─────────────────────────────────────────────────────────────────────────────
if not na(intPH) and showInt
    pivBar = bar_index - intLen
    topP   = intPH + zoneH * 0.7
    botP   = intPH
    bx     = add_zone(true, topP, botP, pivBar, false)
    array.push(intBoxes,  bx)
    array.push(intIsHigh, true)
    array.push(intState,  0)
    array.push(intTop,    topP)
    array.push(intBot,    botP)
    array.push(intBarIdx, pivBar)
    if array.size(intBoxes) > maxZones
        box.delete(array.shift(intBoxes))
        array.shift(intIsHigh)
        array.shift(intState)
        array.shift(intTop)
        array.shift(intBot)
        array.shift(intBarIdx)

if not na(intPL) and showInt
    pivBar = bar_index - intLen
    topP   = intPL
    botP   = intPL - zoneH * 0.7
    bx     = add_zone(false, topP, botP, pivBar, false)
    array.push(intBoxes,  bx)
    array.push(intIsHigh, false)
    array.push(intState,  0)
    array.push(intTop,    topP)
    array.push(intBot,    botP)
    array.push(intBarIdx, pivBar)
    if array.size(intBoxes) > maxZones
        box.delete(array.shift(intBoxes))
        array.shift(intIsHigh)
        array.shift(intState)
        array.shift(intTop)
        array.shift(intBot)
        array.shift(intBarIdx)

// ─────────────────────────────────────────────────────────────────────────────
// ZONE STATE MACHINE — EXTERNAL ZONES
// ─────────────────────────────────────────────────────────────────────────────
update_zones(boxes, isHighArr, stateArr, topArr, botArr) =>
    n = array.size(boxes)
    if n > 0
        for i = 0 to n - 1
            st    = array.get(stateArr, i)
            if st == 2
                continue
            topP  = array.get(topArr, i)
            botP  = array.get(botArr, i)
            isH   = array.get(isHighArr, i)
            bx    = array.get(boxes, i)
            mid   = (topP + botP) * 0.5

            // Sweep detection
            if st == 0
                swept = false
                if sweepMode == "Wick"
                    swept := isH ? high >= mid : low <= mid
                else
                    swept := isH ? close >= mid : close <= mid
                if swept
                    array.set(stateArr, i, 1)
                    zColor = isH ? extHighC : extLowC
                    box.set_border_color(bx, color.new(zColor, get_border_transp(1)))
                    box.set_bgcolor(bx, color.new(zColor, get_fill_transp(1)))

            // Break detection (close beyond zone)
            if st == 1
                broken = isH ? close > topP : close < botP
                if broken
                    array.set(stateArr, i, 2)
                    zColor = isH ? extHighC : extLowC
                    box.set_border_color(bx, color.new(zColor, get_border_transp(2)))
                    box.set_bgcolor(bx, color.new(zColor, get_fill_transp(2)))
                    box.set_extend(bx, extend.none)
                    box.set_right(bx, bar_index)

update_zones(extBoxes, extIsHigh, extState, extTop, extBot)
update_zones(intBoxes, intIsHigh, intState, intTop, intBot)

// ─────────────────────────────────────────────────────────────────────────────
// BOS / CHoCH DETECTION
// ─────────────────────────────────────────────────────────────────────────────
calcTrendMomentum(lookback) =>
    priceChg = close - close[lookback]
    vol      = math.max(ta.stdev(close, lookback), syminfo.mintick)
    priceChg / vol

trendMomentum = calcTrendMomentum(bosLen)
prevTrend     = extTrend

// Update trend direction from momentum
if trendMomentum > 0.5
    extTrend := 1
else if trendMomentum < -0.5
    extTrend := -1

// BOS: break in direction of current trend
// CHoCH: break against current trend (character change)
bullishBreak = not na(lastExtHigh) and ta.crossover(close, lastExtHigh) and barstate.isconfirmed
bearishBreak = not na(lastExtLow)  and ta.crossunder(close, lastExtLow)  and barstate.isconfirmed

if showBOS and bullishBreak
    isBOS    = prevTrend == 1
    brkLabel = isBOS ? "eBOS" : "eCHoCH"
    brkColor = isBOS ? bullStrC : bearStrC
    ln = line.new(lastExtHighBar, lastExtHigh, bar_index, lastExtHigh,
      xloc=xloc.bar_index,
      color=color.new(brkColor, 30),
      style=line.style_dashed,
      width=1)
    lbl = label.new(bar_index, lastExtHigh,
      text=brkLabel,
      style=label.style_label_left,
      color=color.new(brkColor, 20),
      textcolor=color.white,
      size=size.tiny)
    array.push(bosLines,  ln)
    array.push(bosLabels, lbl)
    if array.size(bosLines) > 100
        line.delete(array.shift(bosLines))
        label.delete(array.shift(bosLabels))
    extTrend := 1

if showBOS and bearishBreak
    isBOS    = prevTrend == -1
    brkLabel = isBOS ? "eBOS" : "eCHoCH"
    brkColor = isBOS ? bearStrC : bullStrC
    ln = line.new(lastExtLowBar, lastExtLow, bar_index, lastExtLow,
      xloc=xloc.bar_index,
      color=color.new(brkColor, 30),
      style=line.style_dashed,
      width=1)
    lbl = label.new(bar_index, lastExtLow,
      text=brkLabel,
      style=label.style_label_left,
      color=color.new(brkColor, 20),
      textcolor=color.white,
      size=size.tiny)
    array.push(bosLines,  ln)
    array.push(bosLabels, lbl)
    if array.size(bosLines) > 100
        line.delete(array.shift(bosLines))
        label.delete(array.shift(bosLabels))
    extTrend := -1

// ─────────────────────────────────────────────────────────────────────────────
// INTERNAL STRUCTURE BOS/CHoCH (smaller labels)
// ─────────────────────────────────────────────────────────────────────────────
var float lastIntHigh = na
var float lastIntLow  = na
var int   lastIntHighBar = 0
var int   lastIntLowBar  = 0
var int   intTrend    = 0

if not na(intPH)
    lastIntHigh    := intPH
    lastIntHighBar := bar_index - intLen

if not na(intPL)
    lastIntLow    := intPL
    lastIntLowBar := bar_index - intLen

intMomentum = calcTrendMomentum(math.max(intLen * 2, 5))
if intMomentum > 0.3
    intTrend := 1
else if intMomentum < -0.3
    intTrend := -1

intBullBreak = not na(lastIntHigh) and ta.crossover(close, lastIntHigh) and barstate.isconfirmed
intBearBreak = not na(lastIntLow)  and ta.crossunder(close, lastIntLow)  and barstate.isconfirmed

if showBOS and intBullBreak
    isIntBOS = intTrend == 1
    lbl = label.new(bar_index, lastIntHigh,
      text=isIntBOS ? "iBOS" : "iCHoCH",
      style=label.style_label_left,
      color=color.new(isIntBOS ? bullStrC : bearStrC, 40),
      textcolor=color.white,
      size=size.tiny)
    array.push(bosLabels, lbl)
    if array.size(bosLabels) > 200
        label.delete(array.shift(bosLabels))
    intTrend := 1

if showBOS and intBearBreak
    isIntBOS = intTrend == -1
    lbl = label.new(bar_index, lastIntLow,
      text=isIntBOS ? "iBOS" : "iCHoCH",
      style=label.style_label_left,
      color=color.new(isIntBOS ? bearStrC : bullStrC, 40),
      textcolor=color.white,
      size=size.tiny)
    array.push(bosLabels, lbl)
    if array.size(bosLabels) > 200
        label.delete(array.shift(bosLabels))
    intTrend := -1

// ─────────────────────────────────────────────────────────────────────────────
// TARGET ARROWS: Internal zone swept → point to next external level
// ─────────────────────────────────────────────────────────────────────────────
if showTgt
    // Internal high swept — potential target: next external high
    intSweptHigh = array.size(intState) > 0 and
      array.size(intIsHigh) > 0 and
      intBullBreak and not na(lastExtHigh)
    if intSweptHigh
        label.new(bar_index, high + atr * 0.8,
          text="▲ Ext: " + str.tostring(lastExtHigh, "#.####"),
          style=label.style_label_down,
          color=color.new(intHighC, 20),
          textcolor=bgDark,
          size=size.tiny)

    intSweptLow = array.size(intState) > 0 and
      array.size(intIsHigh) > 0 and
      intBearBreak and not na(lastExtLow)
    if intSweptLow
        label.new(bar_index, low - atr * 0.8,
          text="▼ Ext: " + str.tostring(lastExtLow, "#.####"),
          style=label.style_label_up,
          color=color.new(intLowC, 20),
          textcolor=color.white,
          size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD TABLE
// ─────────────────────────────────────────────────────────────────────────────
var table dash = na
if showTbl
    if na(dash)
        dash := table.new(position.top_right, 2, 9,
          bgcolor=color.new(bgDark, 15),
          border_color=color.new(neutralCol, 70),
          border_width=1,
          frame_color=color.new(neutralCol, 50),
          frame_width=1)

    extTrendStr = extTrend == 1 ? "BULL" : extTrend == -1 ? "BEAR" : "NEUTRAL"
    extTrendCol = extTrend == 1 ? bullColor : extTrend == -1 ? bearColor : neutralCol
    intTrendStr = intTrend == 1 ? "BULL" : intTrend == -1 ? "BEAR" : "NEUTRAL"
    intTrendCol = intTrend == 1 ? bullColor : intTrend == -1 ? bearColor : neutralCol

    extActiveCount = 0
    if array.size(extState) > 0
        for ei = 0 to array.size(extState) - 1
            if array.get(extState, ei) == 0
                extActiveCount += 1
    intActiveCount = 0
    if array.size(intState) > 0
        for ii = 0 to array.size(intState) - 1
            if array.get(intState, ii) == 0
                intActiveCount += 1

    momentumStr = trendMomentum > 0.5 ? "STRONG ▲" : trendMomentum < -0.5 ? "STRONG ▼" :
      trendMomentum > 0 ? "WEAK ▲" : "WEAK ▼"
    momentumCol = trendMomentum > 0 ? bullColor : bearColor

    table.cell(dash, 0, 0, "MSN [JOAT]", text_color=textLight,
      bgcolor=color.new(bgDark, 5), text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker, text_color=bullColor,
      bgcolor=color.new(bgDark, 5), text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(dash, 0, 1, "Ext Trend", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 1, extTrendStr, text_color=extTrendCol, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Int Trend", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 2, intTrendStr, text_color=intTrendCol, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Momentum", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 3, momentumStr, text_color=momentumCol, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Ext Zones", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(extActiveCount) + " active", text_color=textLight,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Int Zones", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(intActiveCount) + " active", text_color=textLight,
      text_size=size.small, text_font_family=font.family_monospace, text_halign=text.align_right)

    extHStr = na(lastExtHigh) ? "---" : str.tostring(lastExtHigh, "#.####")
    table.cell(dash, 0, 6, "Last Ext H", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 6, extHStr, text_color=extHighC, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    extLStr = na(lastExtLow) ? "---" : str.tostring(lastExtLow, "#.####")
    table.cell(dash, 0, 7, "Last Ext L", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 7, extLStr, text_color=extLowC, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    lastBOSStr = bullishBreak ? (extTrend == 1 ? "eBOS ▲" : "eCHoCH ▲") :
      bearishBreak ? (extTrend == -1 ? "eBOS ▼" : "eCHoCH ▼") : "---"
    lastBOSCol = bullishBreak ? bullStrC : bearishBreak ? bearStrC : textDim
    table.cell(dash, 0, 8, "Last Break", text_color=textDim, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(dash, 1, 8, lastBOSStr, text_color=lastBOSCol, text_size=size.small,
      text_font_family=font.family_monospace, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(bullishBreak and barstate.isconfirmed, title="MSN [JOAT] Ext Bull Break", message="MSN [JOAT]: External bullish BOS/CHoCH on {{ticker}} — price closed above key level.")
alertcondition(bearishBreak and barstate.isconfirmed, title="MSN [JOAT] Ext Bear Break", message="MSN [JOAT]: External bearish BOS/CHoCH on {{ticker}} — price closed below key level.")
alertcondition(intBullBreak, title="MSN [JOAT] Int Bull Break", message="MSN [JOAT]: Internal bullish structure break on {{ticker}}.")
alertcondition(intBearBreak, title="MSN [JOAT] Int Bear Break", message="MSN [JOAT]: Internal bearish structure break on {{ticker}}.")
````
