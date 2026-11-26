# Leverage Pressure Map [BOSWaves]

- url: https://www.tradingview.com/script/8U8OMlEE-Leverage-Pressure-Map-BOSWaves/
- type: indicator
- pine_id: PUB;b33f94ed11f74cb2a634eb513f5198e3
- version: 1.0

## Description

[b]Leverage Pressure Map [BOSWaves] - Volume-Weighted Liquidation Level Projection with Thermal Heatmap Visualization[/b]

[b]Overview[/b]

Leverage Pressure Map [BOSWaves] is a leveraged position liquidation estimation system that projects where open leveraged positions would be force-liquidated based on current price and volume activity, where heatmap intensity, level density, and distribution sidebar are driven by accumulated volume-weighted contract estimates at each price band rather than arbitrary fixed grid overlays or static percentage calculations.

[image]https://www.tradingview.com/x/qsRoK3v7/[/image]

Instead of displaying a generic liquidation grid at fixed intervals, the system builds its heatmap organically from price action, projecting liquidation zones from each bar's close in the direction that would liquidate the positions opened on that bar, weighting each level by the bar's volume and by the leverage multiple configured, and accumulating contract estimates over time to reveal where the greatest concentration of leveraged exposure has built up relative to current price.

This creates a continuously evolving pressure map where bands closest to price reflect the most recently opened leveraged positions, higher-leverage bands cluster tighter to price than lower-leverage equivalents, thermal coloring from the base color through yellow to white reveals the most dangerous liquidation clusters at a glance, and a sidebar distribution profile summarizes the full pressure landscape across the visible price range in a compact bar chart.

Price is therefore evaluated not just directionally but against a constantly updating picture of where forced selling and forced buying from leveraged liquidations is likely to cascade if price reaches those levels.

[b]Conceptual Framework[/b]

Leverage Pressure Map is founded on the principle that leveraged market participation leaves a predictable spatial footprint in price space, and that estimating the distribution of that footprint from volume and price data provides actionable information about where cascading liquidation events are most likely to concentrate.

In leveraged markets, positions opened at any given price carry a liquidation distance determined by their leverage multiple. A 100x long position opened at the close of a bullish bar will liquidate approximately one percent below that close. A 10x position will liquidate approximately ten percent below. By projecting these distances from the close of each bar, weighting by volume as a proxy for participation size, and accumulating those estimates across all recent bars, the map builds a statistical picture of where the most leveraged exposure is concentrated without requiring access to exchange order book data.

Three core principles guide the design:
[list=1]
[*]Liquidation levels should be projected from the close of each directional bar at the mathematically correct distance for each configured leverage multiple, weighted by volume to reflect the relative size of participation at each price point.
[*]Thermal coloring should normalize all levels against the global maximum contract estimate, producing a relative intensity map that immediately identifies the highest-pressure clusters regardless of absolute contract values.
[*]A sidebar distribution profile should aggregate the full heatmap into a compact price-by-pressure bar chart, providing a summary view of the total liquidation landscape without requiring the full heatmap to be analyzed row by row.
[/list]
This shifts market analysis from directional price reading into leveraged exposure mapping where the spatial distribution of forced liquidation risk is continuously estimated and visualized alongside price action.

[b]Theoretical Foundation[/b]

The indicator combines per-bar liquidation price calculation for configurable leverage multiples, volume-weighted contract accumulation at snapped price bands, global maximum normalization for thermal color mapping, sweep detection for removing levels that price has already passed through, and a sidebar bin aggregation system that compresses all active levels into a configurable number of price rows for distribution visualization.

Liquidation prices for long positions are calculated as close multiplied by one minus one divided by leverage, projecting below the close at a distance inversely proportional to the leverage multiple. Short liquidation prices are calculated as close multiplied by one plus one divided by leverage, projecting above the close. Each projected price is snapped to the nearest band boundary defined by the tick-scaled level height, ensuring levels accumulate at consistent grid positions rather than scattering across continuous price space. Leverage weights are assigned proportionally, with higher leverage multiples receiving greater weight reflecting their more aggressive risk profile.

Four internal systems operate in tandem:
[list]
[*][i]Liquidation Projection Engine[/i]: On each bar with volume, calculates liquidation prices for all configured leverage multiples in both directions, snaps each price to the nearest level band, and either adds contract weight to an existing band or creates a new band at that position.
[*][i]Sweep and Extension System[/i]: On each bar, extends all active level bands rightward to the current bar and removes any long liquidation bands that price has fallen through or short liquidation bands that price has risen through, keeping the heatmap current with price movement.
[*][i]Thermal Color Engine[/i]: Normalizes each level's accumulated contracts against the global maximum and maps the result through a four-stage thermal gradient that progresses from a transparent base color at low concentration through the full base color to yellow and finally to near-white at peak concentration.
[*][i]Sidebar Distribution System[/i]: On the last bar, aggregates all active long and short liquidation levels into configurable price bins spanning the recent high-low range extended to cover all active levels, draws proportional horizontal bars for each bin based on its relative contract sum, and plots a peak level line at the highest-concentration bin.
[/list]
This design allows the heatmap to build organically from price action while the sidebar provides a continuous summary view of the full liquidation pressure distribution.

[b]How It Works[/b]

Leverage Pressure Map evaluates price through a sequence of projection and accumulation processes:
[list=1]
[*][i]Level Band Sizing[/i]: The minimum tick multiplied by the configured level scale produces the height of each liquidation band, controlling the granularity of the pressure grid relative to the instrument's tick size.
[*][i]Leverage Table Construction[/i]: On the first bar, enabled leverage multiples are loaded into arrays with their corresponding weights calculated as the leverage value divided by 25, giving higher leverage multiples proportionally greater contract weight.
[*][i]Long Liquidation Projection[/i]: On each bullish bar with volume, the liquidation price for each enabled leverage multiple is calculated as close multiplied by one minus one divided by leverage. Each price is snapped to its level band and the bar's volume multiplied by the leverage weight is added to the band's contract accumulation.
[*][i]Short Liquidation Projection[/i]: On each bearish bar with volume, the liquidation price for each enabled leverage multiple is calculated as close multiplied by one plus one divided by leverage. Each price is snapped and weighted identically to the long projection process.
[*][i]Band Deduplication[/i]: When projecting to a band that already exists in the active level array, contracts are added to the existing band rather than creating a duplicate, building cumulative pressure at each price level over time.
[*][i]Sweep Removal[/i]: Long liquidation levels with their bottom boundary at or below the current bar's low are deleted and removed from the array. Short liquidation levels with their top boundary at or above the current bar's high are deleted, reflecting that those positions have already been liquidated.
[*][i]Global Maximum Normalization[/i]: The maximum contract accumulation across all active long and short levels is calculated and used to normalize every level's contracts to a 0-1 range for thermal color assignment.
[*][i]Thermal Color Assignment[/i]: Normalized values above 0.85 receive near-white coloring. Values between 0.65 and 0.85 gradient from yellow to white. Values between 0.35 and 0.65 gradient from the base color to yellow. Values below 0.35 graduate from a highly transparent base color to the full base color, producing a four-stage thermal effect that intensifies with concentration.
[*][i]Sidebar Construction[/i]: On the last bar, the price range spanning the 200-bar high-low extended to cover all active level extremes is divided into the configured number of rows. Each active level's midpoint determines its bin assignment and its contracts are added to that bin's sum. Bins are drawn as horizontal bars proportional to their relative sum, colored by whether they sit below or above current price.
[*][i]Peak Level Rendering[/i]: The sidebar bin with the maximum contract sum has a horizontal line drawn across the full visible range and a price label placed to the right, marking the single level of highest total liquidation pressure across all active levels.
[/list]
Together, these elements form a continuously updating liquidation pressure landscape where the heatmap exposes per-level concentration and the sidebar summarizes the full distribution in a single compact view.

[b]Interpretation[/b]

Leverage Pressure Map should be interpreted as a probabilistic liquidation pressure distribution tool rather than a precise order book representation:
[list]
[*][i]Heatmap Bands (Long, Teal)[/i]: Horizontal bands below price representing estimated long position liquidation levels. These levels would trigger forced selling if price declines to them, potentially amplifying downside momentum.
[*][i]Heatmap Bands (Short, Red)[/i]: Horizontal bands above price representing estimated short position liquidation levels. These levels would trigger forced buying if price rises to them, potentially amplifying upside momentum.
[*][i]Thermal Intensity[/i]: Band color intensity reflects the relative concentration of estimated contracts at each level. Near-white bands represent the highest-pressure clusters. Yellow bands represent elevated but secondary concentrations. Dimmer base-colored bands represent lower-pressure background levels.
[*][i]Band Density Near Price[/i]: Higher leverage multiples project their liquidation distances closer to price, producing denser band clustering near current price. Wider spacing further from price reflects the lower leverage multiples that require larger adverse moves to trigger liquidation.
[*][i]Sidebar Distribution[/i]: The horizontal bar chart to the right of price summarizes total liquidation pressure at each price level across both long and short levels, providing an immediate overview of where the greatest cumulative exposure sits without analyzing individual heatmap bands.
[*][i]Peak Level Line[/i]: The horizontal white line drawn across the chart at the sidebar's maximum-pressure bin marks the single most concentrated liquidation level across the entire active heatmap, representing the price at which the greatest estimated volume of leveraged positions would be forced to close.
[*][i]Swept Levels[/i]: When price passes through a band, the band is removed from the display, reflecting that those positions have already been liquidated and no longer represent pending pressure.
[/list]
Heatmap thermal intensity, peak level proximity to current price, and sidebar distribution shape collectively provide more information about leveraged market risk than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

Leverage Pressure Map does not generate discrete buy or sell signals. Instead it provides a continuous spatial representation of estimated liquidation pressure with two primary reference outputs:
[list=1]
[*][i]Peak Level Line[/i]: The highest-concentration liquidation level across the full active heatmap, updated on every bar, marking where a price move is most likely to encounter cascading forced position closures.
[*][i]Thermal Intensity Clusters[/i]: Near-white or yellow bands identify areas of elevated liquidation pressure that price is approaching, providing anticipatory context for potential momentum amplification or absorption events as price enters high-concentration zones.
[/list]
The sidebar distribution provides a continuous summary reference for assessing whether liquidation pressure is concentrated near price or distributed across a wide range, informing both directional bias and risk management decisions.

[b]Strategy Integration[/b]

Leverage Pressure Map fits within liquidity-aware and leveraged market structure approaches:
[list]
[*][i]Liquidation Cascade Target Identification[/i]: Use high-intensity heatmap clusters as anticipatory targets for directional moves, particularly in leveraged crypto or futures markets where cascade events frequently drive price to liquidation cluster levels before reversing.
[*][i]Peak Level Reference[/i]: Monitor the peak level line as a dynamic reference for the single highest-concentration liquidation zone. Directional moves approaching this level may accelerate as they trigger forced closures and then reverse sharply once the liquidation cascade exhausts.
[*][i]Pressure Asymmetry Analysis[/i]: Compare the density and intensity of long liquidation bands below price against short liquidation bands above price using the sidebar distribution. Greater pressure on one side suggests a directional bias toward the path that would trigger the larger cascade.
[*][i]Momentum Amplification Context[/i]: Use thermal cluster proximity as a context layer for evaluating whether a developing directional move is approaching a zone that would amplify momentum through forced closures or whether the path ahead is relatively clear of concentrated liquidation pressure.
[*][i]Leverage Multiple Configuration[/i]: Configure leverage multiples to reflect the typical leverage profile of the target market. Crypto perpetual markets with common 100x and 50x usage benefit from the default configuration while futures markets with lower typical leverage may be better represented by adjusting multiples toward 20x, 10x, and 5x.
[*][i]Multi-Timeframe Pressure Context[/i]: Apply the indicator on a higher timeframe to establish the broader liquidation pressure landscape while using a lower timeframe for entry timing, ensuring directional decisions are informed by the macro liquidation distribution rather than only the immediate price vicinity.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Projection Engine[/i]: Per-leverage close-derived liquidation price calculation with mintick-scaled band snapping and volume-weighted contract accumulation
[*][i]Data Structure[/i]: Custom type array management for long and short level arrays with deduplication on existing band addresses
[*][i]Sweep System[/i]: Per-bar directional price breach testing with immediate band deletion and array removal for swept levels
[*][i]Thermal Color[/i]: Four-stage normalized gradient from transparent base through full base color to yellow to near-white
[*][i]Sidebar[/i]: Last-bar price-range bin aggregation with proportional width bars and peak bin identification
[*][i]Peak Level[/i]: Highest sidebar bin horizontal line with price label updated on every last bar render
[*][i]Performance Profile[/i]: Configurable maximum level count per side with oldest level removal enforcing object count management
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday liquidation pressure mapping for scalping in high-leverage crypto markets with responsive level accumulation and fine level scale for precise cluster identification
[*][i]15 - 60 min[/i]: Session-level pressure distribution monitoring with balanced level count and moderate scale for intraday cascade target identification
[*][i]4H - Daily[/i]: Swing-level liquidation landscape mapping with higher level scale for broader band visibility across larger price ranges
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Max Levels Per Side[/i]: 100
[*][i]Level Scale[/i]: 50
[*][i]Leverage 1[/i]: 100
[*][i]Leverage 2[/i]: 50
[*][i]Leverage 3[/i]: 25
[*][i]Leverage 4[/i]: 10
[*][i]Show Distribution[/i]: Enabled
[*][i]Show Peak Level[/i]: Enabled
[*][i]Sidebar Width[/i]: 20
[*][i]Sidebar Rows[/i]: 75
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the typical leverage profile of the target market, instrument tick size, and preferred heatmap granularity, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Bands too thin to see[/i]: Increase Level Scale to produce taller bands that are more visible at normal zoom levels, accepting reduced price resolution in exchange for improved visual clarity.
[*][i]Bands too thick and overlapping[/i]: Decrease Level Scale toward 10 for finer band resolution, producing a more precise pressure grid at the cost of reduced visual prominence per band.
[*][i]Too many levels cluttering the chart[/i]: Reduce Max Levels Per Side to limit the number of active bands per direction, with the oldest levels removed first as the cap is enforced.
[*][i]Heatmap not reflecting market's leverage profile[/i]: Adjust the four leverage multiples to match the typical leverage tiers used by participants in the target market. Setting a leverage multiple to zero disables that tier entirely.
[*][i]Sidebar too narrow to read[/i]: Increase Sidebar Width to extend the maximum bar length of the distribution profile, making the relative pressure differences between price levels more visually distinguishable.
[*][i]Sidebar resolution too coarse[/i]: Increase Sidebar Rows for finer price-level resolution in the distribution profile, producing more granular pressure mapping across the visible range.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]High-leverage perpetual crypto markets where 25x to 100x positions are common and liquidation cascade events regularly drive price to cluster levels before reversing
[*]Futures markets with identifiable leverage tier participation where volume-weighted projection produces meaningful pressure estimates relative to actual open interest distribution
[*]Momentum trading approaches where liquidation cluster proximity provides anticipatory context for potential acceleration or reversal around high-pressure zones
[*]Risk management frameworks that benefit from understanding where cascading forced closures are most likely to amplify directional moves beyond fundamental price drivers
[/list]
Reduced Effectiveness:
[list]
[*]Spot-only markets without leverage participation where liquidation mechanics are absent and the projection model loses its theoretical basis
[*]Low-volume instruments where volume-weighted contract estimates become unreliable due to thin and erratic participation
[*]Markets with very low typical leverage where default leverage multiples project liquidation distances beyond the normal trading range, producing bands that are rarely relevant to near-term price action
[*]Instruments with extreme tick sizes relative to their price where mintick-scaled band heights produce either excessively coarse or excessively granular level grids that do not align with meaningful price structure
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves order flow tools, structural indicators, or momentum oscillators to validate whether price approaching a high-intensity liquidation cluster is doing so with the participation and conviction needed to trigger a cascade
[*][i]Peak Level Respect[/i]: Monitor price behavior approaching the peak level line as the highest-probability cascade trigger zone. Price reaching this level may accelerate sharply through it as cascading liquidations fire, then reverse once the forced closure sequence exhausts.
[*][i]Pressure Side Awareness[/i]: Assess whether greater pressure sits above or below current price using the sidebar. A heavier distribution of short liquidation pressure above price suggests upside moves may be self-amplifying, while heavier long liquidation pressure below suggests downside moves may cascade further than directional indicators alone would imply.
[*][i]Level Sweep Interpretation[/i]: When price sweeps through a concentration of bands and they are removed, interpret the clearing as a liquidation event having occurred. The subsequent behavior of price after clearing a major cluster is often directionally informative about whether the move was primarily liquidation-driven or backed by genuine directional conviction.
[*][i]Model Limitations[/i]: This indicator estimates liquidation pressure from volume and price data and does not access exchange-level open interest, funding rates, or actual leveraged position data. All readings represent probabilistic estimates rather than verified exposure measurements and should be treated as context rather than precise quantitative inputs.
[/list]
[b]Disclaimer[/b]

Leverage Pressure Map [BOSWaves] is a professional-grade liquidation pressure estimation and visualization tool. It uses volume-weighted leverage projection with thermal heatmap rendering but does not access real exchange open interest data or actual leveraged position information. All liquidation level estimates are approximations derived from OHLCV data and configured leverage multiples. Results depend on market leverage profile, instrument volume characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

// © BOSWaves
//@version=6
indicator("Leverage Pressure Map [BOSWaves]", overlay = true, max_boxes_count = 500, max_lines_count = 50, max_labels_count = 50)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gCore = "Heatmap Engine"
const string gLev  = "Leverage"
const string gVis  = "Display"

int    maxLvls    = input.int(100, "Max Levels Per Side", minval = 50, maxval = 220, group = gCore, tooltip = "Maximum liquidation levels tracked per direction. Lower = faster, higher = smoother heatmap.")
int    scaleInput = input.int(50, "Level Scale", minval = 50, maxval = 5000, step = 50, group = gCore, tooltip = "Height of each level band in ticks (mintick × this value). Higher = thicker bands, lower = finer detail.")

int    lev1 = input.int(100, "Leverage 1", minval = 0, maxval = 200, inline = "lv1", group = gLev)
int    lev2 = input.int(50, "Leverage 2", minval = 0, maxval = 200, inline = "lv1", group = gLev)
int    lev3 = input.int(25, "Leverage 3", minval = 0, maxval = 200, inline = "lv2", group = gLev)
int    lev4 = input.int(10, "Leverage 4", minval = 0, maxval = 200, inline = "lv2", group = gLev, tooltip = "Set to 0 to disable a leverage level. Higher leverage projects closer to price and gets more weight.")

bool   showSidebar = input.bool(true, "Show Distribution", group = gVis)
bool   showPeak    = input.bool(true, "Show Peak Level", group = gVis)
int    sideW       = input.int(20, "Sidebar Width", minval = 3, maxval = 25, group = gVis)
int    sideRows    = input.int(75, "Sidebar Rows", group = gVis)

color  longCol     = input.color(#00ffcc, "Long Liq", inline = "c", group = gVis)
color  shortCol    = input.color(#ff4444, "Short Liq", inline = "c", group = gVis)

// ┌────────────────────────────── BOSWaves ─ Level Type ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
type LiqLvl
    box   bx
    float top
    float bot
    float contracts

var LiqLvl[] longLiq  = array.new<LiqLvl>()
var LiqLvl[] shortLiq = array.new<LiqLvl>()
var box[]    sideBoxes = array.new<box>()

// ┌────────────────────────────── BOSWaves ─ Scale & Leverage ───────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float levelH = syminfo.mintick * scaleInput

// Build leverage table
var levArr = array.new<float>()
var wtArr  = array.new<float>()

if barstate.isfirst
    levArr.clear()
    wtArr.clear()
    if lev1 > 0
        levArr.push(float(lev1))
        wtArr.push(float(lev1) / 25.)
    if lev2 > 0
        levArr.push(float(lev2))
        wtArr.push(float(lev2) / 25.)
    if lev3 > 0
        levArr.push(float(lev3))
        wtArr.push(float(lev3) / 25.)
    if lev4 > 0
        levArr.push(float(lev4))
        wtArr.push(float(lev4) / 25.)

int levCount = levArr.size()

// ┌────────────────────────────── BOSWaves ─ Snap Function ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
f_snap(float price) =>
    float b = math.floor(price / levelH) * levelH
    float t = b + levelH
    [t, b]

// ┌────────────────────────────── BOSWaves ─ Thermal Color ──────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
f_thermal(float norm, color baseCol) =>
    norm > 0.85 ? color.new(#ffffff, 10) :
     norm > 0.65 ? color.from_gradient(norm, 0.65, 0.85, color.new(#ffff00, 20), color.new(#ffffff, 15)) :
     norm > 0.35 ? color.from_gradient(norm, 0.35, 0.65, baseCol, color.new(#ffff00, 25)) :
     color.from_gradient(norm, 0.0, 0.35, color.new(baseCol, 88), baseCol)

// ┌────────────────────────────── BOSWaves ─ Project Liquidations ───────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float bVol = nz(volume, 0.)
bool  isUp = close > open
bool  isDn = close < open

if bVol > 0 and levCount > 0
    // ── Bullish bars → long positions → project long liquidation below ──
    if isUp
        for j = 0 to levCount - 1
            float lev = levArr.get(j)
            float wt  = wtArr.get(j)
            float liqP = close * (1. - 1. / lev)
            [snapT, snapB] = f_snap(liqP)
            float cts = bVol * wt

            bool found = false
            if longLiq.size() > 0
                for k = 0 to longLiq.size() - 1
                    LiqLvl lv = longLiq.get(k)
                    if lv.top == snapT
                        lv.contracts += cts
                        lv.bx.set_right(bar_index + 1)
                        found := true
                        break

            if not found
                while longLiq.size() >= maxLvls
                    LiqLvl old = longLiq.shift()
                    old.bx.delete()

                color initCol = color.new(longCol, 85)
                box bx = box.new(bar_index, snapT, bar_index + 1, snapB,
                     bgcolor = initCol, border_color = initCol, border_width = 1)
                longLiq.push(LiqLvl.new(bx, snapT, snapB, cts))

    // ── Bearish bars → short positions → project short liquidation above ──
    if isDn
        for j = 0 to levCount - 1
            float lev = levArr.get(j)
            float wt  = wtArr.get(j)
            float liqP = close * (1. + 1. / lev)
            [snapT, snapB] = f_snap(liqP)
            float cts = bVol * wt

            bool found = false
            if shortLiq.size() > 0
                for k = 0 to shortLiq.size() - 1
                    LiqLvl lv = shortLiq.get(k)
                    if lv.top == snapT
                        lv.contracts += cts
                        lv.bx.set_right(bar_index + 1)
                        found := true
                        break

            if not found
                while shortLiq.size() >= maxLvls
                    LiqLvl old = shortLiq.shift()
                    old.bx.delete()

                color initCol = color.new(shortCol, 85)
                box bx = box.new(bar_index, snapT, bar_index + 1, snapB,
                     bgcolor = initCol, border_color = initCol, border_width = 1)
                shortLiq.push(LiqLvl.new(bx, snapT, snapB, cts))

// ┌────────────────────────────── BOSWaves ─ Sweep & Extend ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
// Long liq levels are below price — swept when price drops through them
if longLiq.size() > 0
    for i = longLiq.size() - 1 to 0
        LiqLvl lv = longLiq.get(i)
        if low <= lv.bot
            lv.bx.delete()
            longLiq.remove(i)
            continue
        lv.bx.set_right(bar_index + 1)

// Short liq levels are above price — swept when price rises through them
if shortLiq.size() > 0
    for i = shortLiq.size() - 1 to 0
        LiqLvl lv = shortLiq.get(i)
        if high >= lv.top
            lv.bx.delete()
            shortLiq.remove(i)
            continue
        lv.bx.set_right(bar_index + 1)

// ┌────────────────────────────── BOSWaves ─ Color Update ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
// Find global max contracts for normalization
float maxCts = 0.
if longLiq.size() > 0
    for i = 0 to longLiq.size() - 1
        maxCts := math.max(maxCts, longLiq.get(i).contracts)
if shortLiq.size() > 0
    for i = 0 to shortLiq.size() - 1
        maxCts := math.max(maxCts, shortLiq.get(i).contracts)

// Update all box colors
if longLiq.size() > 0
    for i = 0 to longLiq.size() - 1
        LiqLvl lv = longLiq.get(i)
        float norm = maxCts > 0 ? lv.contracts / maxCts : 0.
        color c = f_thermal(norm, longCol)
        lv.bx.set_bgcolor(c)
        lv.bx.set_border_color(c)

if shortLiq.size() > 0
    for i = 0 to shortLiq.size() - 1
        LiqLvl lv = shortLiq.get(i)
        float norm = maxCts > 0 ? lv.contracts / maxCts : 0.
        color c = f_thermal(norm, shortCol)
        lv.bx.set_bgcolor(c)
        lv.bx.set_border_color(c)

// ┌────────────────────────────── BOSWaves ─ Sidebar & Peak ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var line  peakLn  = na
var label peakLbl = na

if barstate.islast
    // ── Cleanup sidebar ──
    for b in sideBoxes
        b.delete()
    sideBoxes.clear()
    if not na(peakLn)
        peakLn.delete()
    if not na(peakLbl)
        peakLbl.delete()

    if showSidebar
        // Build sidebar bins
        float sHi = ta.highest(high, 200)
        float sLo = ta.lowest(low, 200)

        // Extend to cover all active levels
        if longLiq.size() > 0
            for i = 0 to longLiq.size() - 1
                sLo := math.min(sLo, longLiq.get(i).bot)
        if shortLiq.size() > 0
            for i = 0 to shortLiq.size() - 1
                sHi := math.max(sHi, shortLiq.get(i).top)

        float sSpan = sHi - sLo
        float sBinH = sSpan / sideRows

        sideSums = array.new<float>(sideRows, 0.)

        // Accumulate long levels
        if longLiq.size() > 0
            for i = 0 to longLiq.size() - 1
                float mid = math.avg(longLiq.get(i).top, longLiq.get(i).bot)
                int idx = int(math.floor((mid - sLo) / sBinH))
                idx := math.max(0, math.min(sideRows - 1, idx))
                sideSums.set(idx, sideSums.get(idx) + longLiq.get(i).contracts)

        // Accumulate short levels
        if shortLiq.size() > 0
            for i = 0 to shortLiq.size() - 1
                float mid = math.avg(shortLiq.get(i).top, shortLiq.get(i).bot)
                int idx = int(math.floor((mid - sLo) / sBinH))
                idx := math.max(0, math.min(sideRows - 1, idx))
                sideSums.set(idx, sideSums.get(idx) + shortLiq.get(i).contracts)

        // Draw sidebar
        float sMax  = sideSums.max()
        int   sLeft = bar_index + 3
        int   peakR = 0
        float peakV = 0.

        for i = 0 to sideRows - 1
            float s    = sideSums.get(i)
            float norm = sMax > 0 ? s / sMax : 0.

            if s > peakV
                peakV := s
                peakR := i

            if norm < 0.05
                continue

            float rBot = sLo + sBinH * i
            float rTop = rBot + sBinH
            float mid  = math.avg(rBot, rTop)

            int   barW    = math.max(1, int(math.round(norm * sideW)))
            color baseCol = mid < close ? longCol : shortCol

            // Soft gradient — no thermal, just transparency scaling
            int   transp  = int(math.max(30, 88 - norm * 58))
            color barCol  = color.new(baseCol, transp)

            sideBoxes.push(box.new(sLeft, rTop, sLeft + barW, rBot,
                 bgcolor = barCol,
                 border_color = na))

        // ── Peak level ──
        if showPeak and peakV > 0
            float peakPrice = sLo + sBinH * peakR + sBinH * 0.5

            peakLn := line.new(bar_index - 200, peakPrice, bar_index + 2, peakPrice,
                 color = color.new(#ffffff, 25), width = 2, style = line.style_solid)

            peakLbl := label.new(sLeft + sideW + 2, peakPrice,
                 str.tostring(peakPrice, format.mintick),
                 style = label.style_none,
                 textcolor = color.new(#ffffff, 20),
                 size = size.normal)
````
