# Liquidity Sniper

- url: https://www.tradingview.com/script/2wFE1pXU-Liquidity-Sniper/
- type: indicator
- pine_id: PUB;31e1b34b90804c6dafe0d6d4ee95f764
- version: 1.0

## Description

liquidity sniper is a market liquidity mapping tool designed to visualize estimated liquidation zones, stop-liquidity pools, active liquidity walls, historical sweeps, directional magnets, synthetic market depth and volume delta directly on the chart.

the indicator builds a dynamic liquidity map from price, volume, volatility, leverage assumptions and confirmed market structure. active liquidity zones evolve over time, lose intensity through decay and are removed or archived when price reaches them.

the objective is to provide a clearer view of where liquidity may be concentrated around current price and where the market could encounter important pools during expansion, squeezes, flushes or stop-hunt movements.

### liquidation engine

the liquidation engine continuously creates estimated liquidity levels above and below price using several leverage tiers.

available leverage profiles are:

**crypto degen**

places more weight on high-leverage exposure, especially 100x and 50x structures.

**balanced**

uses a more distributed weighting across 100x, 50x, 25x and 10x leverage.

**conservative**

places greater emphasis on lower leverage such as 25x and 10x.

the profile does not represent actual exchange liquidation data. it changes the assumed leverage distribution used by the internal liquidity model.

### maintenance margin

**maintenance margin %** adjusts the margin assumption used when calculating estimated liquidation locations.

changing this value shifts the theoretical liquidation levels generated around the reference price.

### volume baseline length

the indicator compares current volume with a moving volume baseline.

**volume baseline length** controls the number of bars used for this reference.

higher relative volume increases the weight of newly generated liquidity structures.

this allows unusually active periods to contribute more strongly to the liquidity map than low-volume periods.

### cluster merge distance

liquidity levels that appear very close to each other can be combined into a single wall.

**cluster merge distance** defines this distance using atr.

a smaller value keeps nearby liquidity levels more separated.

a larger value combines more levels into common liquidity walls.

when several levels stack together, their intensity accumulates.

### intensity half-life

liquidity does not remain equally important forever.

**intensity half-life** controls how quickly active walls lose strength as new bars appear.

a shorter half-life makes the map adapt faster and removes old liquidity more aggressively.

a longer half-life keeps older structures relevant for longer.

### stop-hunt pivot length

the indicator also detects confirmed pivot highs and lows as potential stop-liquidity locations.

**stop-hunt pivot length** controls the sensitivity of this structure detection.

smaller values detect more local pivots.

larger values focus on broader and more established swing points.

### stop liquidity weight

**stop liquidity weight** controls how much intensity is assigned to liquidity generated from confirmed pivot highs and lows.

increasing this value makes structural stop pools more influential relative to the continuously generated leverage-based walls.

### purge on wick touch

when enabled, a liquidity wall is considered reached as soon as the candle wick touches its price.

when disabled, the calculation uses the candle body instead.

this option changes how aggressively liquidity is considered consumed.

wick mode reacts faster to intrabar price excursions, while body mode requires deeper price acceptance.

### active and historical walls

**max active walls** controls the maximum number of live liquidity structures maintained by the engine.

when the limit is exceeded, weaker active walls are removed first.

**max historical bands** controls how much consumed or expired liquidity can remain in the historical mosaic.

this provides a visual record of where liquidity previously existed and where price interacted with it.

### liquidity heatmap

the heatmap transforms the liquidity model into horizontal intensity bands.

stronger concentrations receive more visual emphasis while weaker liquidity remains more subtle.

two visual themes are available:

**coinglass inferno**

uses a progression from deep purple through violet, teal and green toward yellow-hot liquidity.

**wizard neon**

uses an alternative neon-style liquidity palette.

### grid window

**grid window** defines the rolling price window used to calculate the vertical heatmap structure.

a larger value gives the map a broader historical context.

a smaller value concentrates the visualization on more recent market conditions.

### grid rows

**grid rows** controls the vertical resolution of the liquidity mosaic.

more rows create thinner and more precise bands.

fewer rows create broader visual zones.

increasing resolution can produce a more detailed map but also increases visual density.

### heat gamma

**heat gamma** changes how liquidity intensity is translated into heatmap color.

values below 1 increase the visibility of medium-strength liquidity.

higher values place more visual emphasis on the strongest concentrations.

this setting is useful for adjusting the map when moderate liquidity walls are difficult to distinguish.

### hot-wall glow threshold

the strongest active walls can receive an additional glow and horizontal highlight.

**hot-wall glow threshold** determines how strong a wall must be relative to the current maximum intensity before this effect appears.

higher values reserve the glow for only the most dominant walls.

### synthetic order book

the indicator can display a synthetic depth profile beside current price.

the active liquidity map is divided into price bins above and below the market and converted into horizontal depth bars.

this creates a compact visualization of where the model detects the greatest concentration of liquidity.

this is a synthetic structure derived from the indicator's liquidity model. it is not a direct exchange level 2 order book.

### cumulative depth

when **cumulative depth** is enabled, liquidity is progressively accumulated across the depth bins.

when disabled, each bin represents its own local concentration.

cumulative mode can make larger liquidity imbalances easier to visualize, while non-cumulative mode provides a more granular view of individual zones.

### bins per side

**bins per side** controls the resolution of the synthetic order book above and below current price.

more bins provide finer price segmentation.

fewer bins produce larger aggregated depth zones.

### max wall width

**max wall width** controls the maximum horizontal size of the synthetic depth bars.

stronger depth concentrations produce longer bars relative to weaker ones.

### order book offset

**offset from last bar** controls how far the synthetic order book is positioned from the latest candle.

this can be increased when additional visual space is needed between price action and the depth profile.

### liquidity magnets

the magnet engine searches for important active liquidity concentrations within a configurable distance from current price.

the strongest qualifying wall above price becomes the **short magnet**.

the strongest qualifying wall below price becomes the **long magnet**.

the chart displays these areas using horizontal beams together with their estimated intensity and dominant leverage classification.

a magnet generated from structural stop liquidity is identified as **stops** instead of a leverage tier.

### max magnet distance

**max magnet distance %** limits how far the engine searches for relevant liquidity magnets.

a smaller percentage focuses on nearby liquidity.

a larger percentage allows more distant walls to participate in the calculation.

this also defines the surrounding area used for several liquidity-pool calculations.

### major sweeps

a major sweep occurs when price consumes a sufficiently strong active liquidity wall.

**major sweep threshold** defines how strong the wall must be relative to the maximum current liquidity intensity.

when a qualifying wall is consumed, the indicator can display a sweep flash on the chart.

the number of visible major sweep flashes is intentionally limited to keep the chart readable.

major short-wall sweeps and major long-wall sweeps can also trigger dedicated alerts.

### delta engine

liquidity sniper includes a signed volume delta engine.

when **lower-tf signed volume delta** is enabled, the indicator automatically selects a lower timeframe and analyzes the direction of its candles.

volume from bullish lower-timeframe candles is treated as positive.

volume from bearish lower-timeframe candles is treated as negative.

the resulting values are combined into the current chart bar.

the automatically selected lower timeframe changes according to the chart timeframe.

this provides more granular directional volume information than using only the chart candle.

the calculation is based on lower-timeframe candle direction. it is not exchange bid/ask aggressor delta.

### bar delta

**bar delta** represents the signed volume calculation for the current chart bar.

positive values indicate that the internal lower-timeframe calculation contains more positively signed volume.

negative values indicate more negatively signed volume.

### cumulative delta

the indicator also maintains a daily cumulative delta.

the value resets when a new trading day begins and accumulates confirmed bar delta throughout the session.

a zero-line crossover can generate a cumulative delta flip alert.

### liquidity pull bias

the dashboard compares nearby modeled liquidity above and below current price.

from this distribution it calculates a **pull bias**.

the result can display:

**up**

**down**

**neutral**

this is a liquidity imbalance reading rather than a guaranteed directional forecast.

it can be used to quickly see which side currently contains the larger modeled liquidity pool within the selected search area.

### dashboard

the integrated dashboard provides a compact summary of the current liquidity environment.

it displays:

bar delta

daily cumulative delta

long and short liquidity estimates

liquidity pull bias

nearest short magnet

nearest long magnet

active and historical wall counts

selected leverage profile

automatically selected lower timeframe

currently enabled visualization modes

the dashboard can be positioned in any chart corner.

available text sizes are tiny, small and normal.

it can also be completely disabled when a cleaner chart is preferred.

### alerts

liquidity sniper includes alerts for important liquidity events.

**major short wall swept**

fires when a sufficiently important liquidity wall above price is consumed.

**major long wall swept**

fires when a sufficiently important liquidity wall below price is consumed.

**cumulative delta flip**

fires when the daily cumulative delta crosses zero.

these alerts can be combined with the visual heatmap and magnet structure to monitor important changes without continuously watching the chart.

### quick start

start with the default settings and allow the indicator to build enough history to populate the liquidity map.

first, choose the leverage profile that best matches the type of market being analyzed.

for highly leveraged crypto perpetual markets, **crypto degen** gives greater importance to high-leverage structures.

use **balanced** when a more neutral distribution is preferred.

use **conservative** when lower leverage assumptions are more appropriate.

keep the heatmap enabled and identify the brightest liquidity concentrations around current price.

stronger and hotter bands represent larger modeled liquidity concentrations.

next, compare the closest **short magnet** above price with the closest **long magnet** below price.

the dashboard provides their exact locations while the magnet beams make them visible directly on the chart.

check **pull bias** to compare the total modeled liquidity on both sides of price.

then use **bar delta** and **cumulative delta** as additional context for current directional volume pressure.

watch for major sweep flashes when price reaches a strong wall. a sweep indicates that an important modeled liquidity area has been consumed and should be interpreted in the context of the reaction that follows.

finally, use the synthetic order book to quickly compare how modeled depth is distributed above and below current price.

### adjusting the map

if the chart contains too many small liquidity walls, increase **cluster merge distance** so nearby levels combine more aggressively.

if old liquidity remains visible for too long, reduce **intensity half-life**.

if the map changes too quickly, increase the half-life.

increase **stop-hunt pivot length** when only larger structural highs and lows should contribute stop liquidity.

reduce it when more local swing structures are required.

increase **stop liquidity weight** when confirmed pivot liquidity should have more influence.

reduce it when leverage-derived liquidity should dominate the model.

if the heatmap appears too uniform, adjust **heat gamma** and **hot-wall glow threshold** to create greater separation between moderate and extreme liquidity.

for a cleaner synthetic depth display, reduce the number of order-book bins.

for greater detail, increase the number of bins.

### reading the chart

liquidity above current price represents modeled short-liquidation and stop-liquidity structures.

liquidity below current price represents modeled long-liquidation and stop-liquidity structures.

bright walls indicate stronger relative concentration inside the current map.

magnet beams isolate the strongest nearby qualifying walls.

historical bands show liquidity structures that previously existed before being consumed or removed from the active map.

major sweep flashes mark recent interactions with sufficiently strong walls.

the synthetic order book summarizes the current active map into a compact depth representation.

the dashboard combines these elements with delta and liquidity imbalance information.

### how liquidity sniper can help

liquidity sniper can help organize several forms of market context into a single chart:

mapping estimated liquidation concentrations above and below price

locating potential stop-liquidity pools around confirmed swing highs and lows

identifying the strongest nearby liquidity magnets

visualizing how liquidity develops, decays and disappears over time

distinguishing active liquidity from previously consumed liquidity

highlighting major liquidity sweeps

comparing modeled liquidity above and below current price

monitoring lower-timeframe signed volume delta

tracking daily cumulative delta

visualizing synthetic depth without adding a separate panel

identifying areas where several modeled liquidity levels have merged into stronger walls

reducing the need to manually track multiple liquidity references across the chart

the tool can be particularly useful for studying liquidity around breakouts, stop hunts, squeezes, flushes, range boundaries and high-volatility expansion.

liquidity walls should be treated as areas of interest rather than automatic entry or reversal signals. the liquidation map is an estimation model built from chart data and leverage assumptions, while the synthetic order book is derived from that model rather than direct exchange order-book data.

the strongest use of the indicator is therefore contextual: observe where liquidity is concentrated, how price approaches it, whether the wall is consumed or rejected, what the delta is doing during the interaction, and how the remaining liquidity distribution changes afterward.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6

indicator("LIQUIDITY SNIPER", "LIQS",
     overlay = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

// Explicit drawing-time buffer for deep 1m history.
max_bars_back(time, 5000)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
const string G1 = "⚙️  LIQUIDATION ENGINE"
const string G2 = "🔥  HEATMAP RENDER"
const string G3 = "📊  ORDER BOOK DEPTH"
const string G4 = "🧲  MAGNETS & SWEEPS"
const string G5 = "⚡  DELTA ENGINE"
const string G6 = "🖥️  DASHBOARD"

string levProfile   = input.string("Crypto Degen", "Leverage Profile", options = ["Crypto Degen", "Balanced", "Conservative"], group = G1, tooltip = "Assumed leverage distribution.\nDegen = 100x/50x heavy (crypto perps)\nBalanced = 50x/25x\nConservative = 25x/10x (indices, FX, stocks)")
float  mmrPct       = input.float(0.50, "Maintenance Margin %", minval = 0.0, step = 0.05, group = G1)
int    volLen       = input.int(50, "Volume Baseline Length", minval = 10, group = G1)
float  mergeMult    = input.float(0.30, "Cluster Merge Distance (ATR x)", minval = 0.05, step = 0.05, group = G1, tooltip = "Levels closer than this stack into one wall.")
int    halfLife     = input.int(200, "Intensity Half-Life (bars)", minval = 20, group = G1)
int    pivLen       = input.int(8, "Stop-Hunt Pivot Length", minval = 2, group = G1)
float  stopW        = input.float(1.50, "Stop Liquidity Weight", minval = 0.0, step = 0.05, group = G1)
bool   purgeWick    = input.bool(true, "Purge On Wick Touch", group = G1)
int    maxActive    = input.int(150, "Max Active Walls", minval = 40, maxval = 200, group = G1)
int    maxDead      = input.int(290, "Max Historical Bands (mosaic depth)", minval = 60, maxval = 320, group = G1)

bool   showHeat     = input.bool(true, "Show Heatmap", group = G2)
string heatTheme    = input.string("Coinglass Inferno", "Color Theme", options = ["Coinglass Inferno", "Wizard Neon"], group = G2)
int    winLen       = input.int(400, "Grid Window (bars)", minval = 100, maxval = 1000, group = G2, tooltip = "Rolling window used to size the uniform grid rows.")
int    gridRows     = input.int(70, "Grid Rows", minval = 30, maxval = 120, group = G2, tooltip = "Vertical resolution of the mosaic. Higher = thinner bands.")
float  gammaHeat    = input.float(0.65, "Heat Gamma", minval = 0.3, maxval = 1.5, step = 0.05, group = G2, tooltip = "Below 1.0 boosts mid-intensity bands → richer Coinglass texture.")
float  glowCut      = input.float(0.82, "Hot-Wall Glow Threshold", minval = 0.5, maxval = 0.98, step = 0.02, group = G2)

bool   showBook     = input.bool(true, "Show Synthetic Order Book", group = G3)
bool   bookCum      = input.bool(true, "Cumulative Depth", group = G3)
int    bookBins     = input.int(16, "Bins Per Side", minval = 6, maxval = 24, group = G3)
int    bookWidth    = input.int(22, "Max Wall Width (bars)", minval = 6, maxval = 40, group = G3)
int    bookOffset   = input.int(7, "Offset From Last Bar", minval = 3, group = G3)

bool   showMagnets  = input.bool(true, "Show Magnets", group = G4)
float  magDistPct   = input.float(12.0, "Max Magnet Distance %", minval = 1.0, step = 0.5, group = G4)
bool   showSweeps   = input.bool(true, "Major Sweep Flashes (capped at 4)", group = G4)
float  sweepCut     = input.float(0.55, "Major Sweep Threshold (x max intensity)", minval = 0.2, maxval = 0.95, step = 0.05, group = G4)

bool   useLtfDelta  = input.bool(true, "Lower-TF Signed Volume Delta", group = G5, tooltip = "Uses lower-timeframe candle-direction signed volume. This is not exchange bid/ask aggressor delta.")

string dashPos      = input.string("Bottom Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G6, tooltip = "Selects the dashboard location on the chart.")
string dashSize     = input.string("Tiny", "Text Size", options = ["Tiny", "Small", "Normal"], group = G6, tooltip = "Controls dashboard text density. Tiny is the compact institutional default.")
bool   showDash     = input.bool(true, "Show Dashboard", group = G6, tooltip = "Shows or hides the institutional liquidity dashboard.")

// ─────────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────────
color CY  = #00FFD1
color MG  = #FF3B5C
color GD  = #FFD23F
color BGD = #0B0E17

// Institutional dashboard palette
color P_BG     = #0B0F14
color P_CELL   = #111820
color P_BORDER = #27313D
color P_TEXT   = #E6EDF3
color P_MUTED  = #8B98A8
color P_ACCENT = #B8C4D4

bool  isInferno = heatTheme == "Coinglass Inferno"
color cL0 = isInferno ? #1B1445 : #130F33     // deep purple  (faint liquidity)
color cL1 = isInferno ? #5B2A86 : #241A5E     // violet
color cL2 = isInferno ? #00A9A0 : CY          // teal
color cL3 = isInferno ? #7ED957 : #7DFFE5     // green
color cL4 = isInferno ? #FFE600 : GD          // yellow-hot   (max liquidity)

// ─────────────────────────────────────────────────────────────────────────────
//  STATE — ACTIVE walls (parallel arrays)
// ─────────────────────────────────────────────────────────────────────────────
var float[] aP = array.new_float()    // price
var float[] aI = array.new_float()    // intensity
var int[]   aS = array.new_int()      // +1 short-liq above / -1 long-liq below
var int[]   aL = array.new_int()      // dominant leverage (0 = stop pool)
var int[]   aB = array.new_int()      // birth bar

//  STATE — DEAD bands (the historical mosaic: birth → death, frozen)
var float[] dP  = array.new_float()
var float[] dI  = array.new_float()
var int[]   dB0 = array.new_int()
var int[]   dB1 = array.new_int()

//  Major sweep flashes (hard cap 4)
var float[] swP = array.new_float()
var int[]   swB = array.new_int()
var int[]   swS = array.new_int()

//  Drawing pools
var box[]   rBx = array.new<box>()
var line[]  rLn = array.new<line>()
var label[] rLb = array.new<label>()

//  Leverage tiers + profile weights
var int[]   LEVS = array.from(100, 50, 25, 10)
var float[] WTS  = array.new_float()
if barstate.isfirst
    if levProfile == "Crypto Degen"
        array.push(WTS, 1.00)
        array.push(WTS, 0.85)
        array.push(WTS, 0.60)
        array.push(WTS, 0.35)
    else if levProfile == "Balanced"
        array.push(WTS, 0.65)
        array.push(WTS, 1.00)
        array.push(WTS, 0.80)
        array.push(WTS, 0.50)
    else
        array.push(WTS, 0.35)
        array.push(WTS, 0.65)
        array.push(WTS, 1.00)
        array.push(WTS, 0.80)

// ─────────────────────────────────────────────────────────────────────────────
//  CORE SERIES
// ─────────────────────────────────────────────────────────────────────────────
float atrV   = ta.atr(14)
float volSma = ta.sma(volume, volLen)
float rvol   = volSma > 0 ? volume / volSma : 1.0
float mm     = mmrPct / 100.0
float decayF = math.pow(0.5, 1.0 / halfLife)
float ph     = ta.pivothigh(pivLen, pivLen)
float pl     = ta.pivotlow(pivLen, pivLen)
float winHi  = ta.highest(high, winLen)
float winLo  = ta.lowest(low, winLen)

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS (global scope only)
// ─────────────────────────────────────────────────────────────────────────────
f_fmt(float v) =>
    float a = math.abs(v)
    a >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" : a >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : a >= 1e3 ? str.tostring(v / 1e3, "#.#") + "K" : str.tostring(v, "#.##")

// 5-stop Coinglass gradient with gamma boost
f_heat(float t) =>
    float tg = math.pow(math.max(0.0, math.min(1.0, t)), gammaHeat)
    tg < 0.25 ? color.from_gradient(tg, 0.00, 0.25, cL0, cL1) :
     tg < 0.50 ? color.from_gradient(tg, 0.25, 0.50, cL1, cL2) :
     tg < 0.75 ? color.from_gradient(tg, 0.50, 0.75, cL2, cL3) :
     color.from_gradient(tg, 0.75, 1.00, cL3, cL4)

f_txtSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

f_dashPos(string s) =>
    s == "Top Right" ? position.top_right : s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : position.bottom_left

// add-or-stack an active wall
f_addLevel(float p, float inten, int side, int lev, float mergeDist) =>
    bool found = false
    int sz = array.size(aP)
    if sz > 0
        for i = 0 to sz - 1
            if not found
                if array.get(aS, i) == side and math.abs(array.get(aP, i) - p) <= mergeDist
                    array.set(aI, i, array.get(aI, i) + inten)
                    if lev > array.get(aL, i)
                        array.set(aL, i, lev)
                    found := true
    if not found
        array.push(aP, p)
        array.push(aI, inten)
        array.push(aS, side)
        array.push(aL, lev)
        array.push(aB, bar_index)

// evict weakest active wall
f_evictWeakest() =>
    int sz = array.size(aP)
    if sz > 0
        int wk = 0
        float wv = array.get(aI, 0)
        if sz > 1
            for i = 1 to sz - 1
                if array.get(aI, i) < wv
                    wv := array.get(aI, i)
                    wk := i
        array.remove(aP, wk)
        array.remove(aI, wk)
        array.remove(aS, wk)
        array.remove(aL, wk)
        array.remove(aB, wk)

// freeze a swept wall into the historical mosaic
f_freezeBand(float p, float inten, int b0) =>
    array.push(dP, p)
    array.push(dI, inten)
    array.push(dB0, b0)
    array.push(dB1, bar_index)
    while array.size(dP) > maxDead
        array.shift(dP)
        array.shift(dI)
        array.shift(dB0)
        array.shift(dB1)

// register a MAJOR sweep flash (hard cap 4)
f_majorSweep(float p, int side) =>
    array.push(swP, p)
    array.push(swB, bar_index)
    array.push(swS, side)
    while array.size(swP) > 4
        array.shift(swP)
        array.shift(swB)
        array.shift(swS)

f_wipe() =>
    while array.size(rBx) > 0
        box.delete(array.pop(rBx))
    while array.size(rLn) > 0
        line.delete(array.pop(rLn))
    while array.size(rLb) > 0
        label.delete(array.pop(rLb))

// ─────────────────────────────────────────────────────────────────────────────
//  DELTA ENGINE
// ─────────────────────────────────────────────────────────────────────────────
int tfSec = timeframe.in_seconds(timeframe.period)
string autoLtf = tfSec <= 300 ? "1" : tfSec <= 3600 ? "5" : tfSec <= 14400 ? "15" : "60"
float[] ltfD = request.security_lower_tf(syminfo.tickerid, autoLtf, close > open ? volume : close < open ? -volume : 0.0)

float barDelta = 0.0
int dsz = array.size(ltfD)
if useLtfDelta and dsz > 0
    for i = 0 to dsz - 1
        barDelta := barDelta + array.get(ltfD, i)
else
    barDelta := close > open ? volume : close < open ? -volume : 0.0

var float cumDelta = 0.0
if timeframe.change("D")
    cumDelta := 0.0
if barstate.isconfirmed
    cumDelta := cumDelta + barDelta

// ─────────────────────────────────────────────────────────────────────────────
//  STATE UPDATE — confirmed bars only
// ─────────────────────────────────────────────────────────────────────────────
bool majorSweepUp = false
bool majorSweepDn = false
var float gMaxI = 0.0

float purgeHi = purgeWick ? high : math.max(open, close)
float purgeLo = purgeWick ? low  : math.min(open, close)

if barstate.isconfirmed
    // ── 1. DECAY + PURGE → FREEZE INTO MOSAIC ────────────────────────────────
    int sz0 = array.size(aP)
    if sz0 > 0
        int[] rmIdx = array.new_int()
        for i = 0 to sz0 - 1
            float p  = array.get(aP, i)
            int   sd = array.get(aS, i)
            float it = array.get(aI, i) * decayF
            bool hit = sd == 1 ? purgeHi >= p : purgeLo <= p
            if hit
                float itNow = array.get(aI, i)
                if itNow >= volSma * 0.08
                    f_freezeBand(p, itNow, array.get(aB, i))
                if gMaxI > 0 and itNow >= gMaxI * sweepCut
                    f_majorSweep(p, sd)
                    if sd == 1
                        majorSweepUp := true
                    else
                        majorSweepDn := true
                array.push(rmIdx, i)
            else if it < volSma * 0.04
                if it >= volSma * 0.03 and bar_index - array.get(aB, i) > 10
                    f_freezeBand(p, array.get(aI, i), array.get(aB, i))
                array.push(rmIdx, i)
            else
                array.set(aI, i, it)
        int rsz = array.size(rmIdx)
        if rsz > 0
            for j = 0 to rsz - 1
                int k = array.get(rmIdx, rsz - 1 - j)
                array.remove(aP, k)
                array.remove(aI, k)
                array.remove(aS, k)
                array.remove(aL, k)
                array.remove(aB, k)

    // ── 2. CONTINUOUS SEEDING (every bar, volume-scaled) ─────────────────────
    float mergeDist = atrV * mergeMult
    if volSma > 0 and volume > 0
        float E    = hlc3
        float base = volume * (0.35 + math.min(rvol, 4.0) * 0.65)
        for j = 0 to 3
            int   L = array.get(LEVS, j)
            float w = array.get(WTS, j)
            f_addLevel(E * (1.0 - 1.0 / L + mm), base * w, -1, L, mergeDist)
            f_addLevel(E * (1.0 + 1.0 / L - mm), base * w,  1, L, mergeDist)

    // ── 3. STOP-HUNT LIQUIDITY ───────────────────────────────────────────────
    if not na(ph)
        f_addLevel(ph, nz(volume[pivLen]) * stopW, 1, 0, mergeDist)
    if not na(pl)
        f_addLevel(pl, nz(volume[pivLen]) * stopW, -1, 0, mergeDist)

    // ── 4. CAPACITY + RUNNING MAX ────────────────────────────────────────────
    while array.size(aP) > maxActive
        f_evictWeakest()
    float mx = 0.0
    int szM = array.size(aI)
    if szM > 0
        for i = 0 to szM - 1
            if array.get(aI, i) > mx
                mx := array.get(aI, i)
    gMaxI := mx

// ─────────────────────────────────────────────────────────────────────────────
//  MAGNET SCAN
// ─────────────────────────────────────────────────────────────────────────────
float magUpP = na
float magUpI = 0.0
int   magUpL = 0
int   magUpB = 0
float magDnP = na
float magDnI = 0.0
int   magDnL = 0
int   magDnB = 0
float poolUp = 0.0
float poolDn = 0.0

int szA = array.size(aP)
if szA > 0
    for i = 0 to szA - 1
        float p  = array.get(aP, i)
        float it = array.get(aI, i)
        int   sd = array.get(aS, i)
        float distPct = math.abs(p / close - 1.0) * 100.0
        if distPct <= magDistPct
            if sd == 1 and p > close
                poolUp := poolUp + it
                if it > magUpI
                    magUpI := it
                    magUpP := p
                    magUpL := array.get(aL, i)
                    magUpB := array.get(aB, i)
            if sd == -1 and p < close
                poolDn := poolDn + it
                if it > magDnI
                    magDnI := it
                    magDnP := p
                    magDnL := array.get(aL, i)
                    magDnB := array.get(aB, i)

// ─────────────────────────────────────────────────────────────────────────────
//  RENDER — barstate.islast, hard budget guard
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    f_wipe()
    int budget = 0
    // Pine historical buffers support up to 5000 bars. Keep drawings safely inside it.
    int safeLeft = math.max(0, bar_index - 4990)
    float rowH = (winHi - winLo) / gridRows
    if na(rowH) or rowH <= 0
        rowH := atrV * 0.25

    // global normalization across active + dead
    float maxI = 0.0
    int szAc = array.size(aP)
    int szDd = array.size(dP)
    if szAc > 0
        for i = 0 to szAc - 1
            if array.get(aI, i) > maxI
                maxI := array.get(aI, i)
    if szDd > 0
        for i = 0 to szDd - 1
            if array.get(dI, i) > maxI
                maxI := array.get(dI, i)

    if showHeat and maxI > 0
        // ── HISTORICAL MOSAIC (dead bands, newest first) ─────────────────────
        if szDd > 0
            for j = 0 to szDd - 1
                int i = szDd - 1 - j
                if budget < 300
                    float p  = array.get(dP, i)
                    float t  = array.get(dI, i) / maxI
                    int   b0Raw = array.get(dB0, i)
                    int   b1Raw = array.get(dB1, i)
                    // Dead bands entirely outside the safe history window are not rendered.
                    if b1Raw >= safeLeft
                        int b0 = math.max(b0Raw, safeLeft)
                        int b1 = math.max(b1Raw, safeLeft)
                        color hc = f_heat(t)
                        int   tr = int(88.0 - math.pow(t, gammaHeat) * 58.0)
                        array.push(rBx, box.new(b0, p + rowH * 0.5, b1, p - rowH * 0.5, border_color = na, bgcolor = color.new(hc, tr)))
                        budget := budget + 1

        // ── ACTIVE WALLS (birth → right edge) ────────────────────────────────
        if szAc > 0
            for i = 0 to szAc - 1
                if budget < 440
                    float p  = array.get(aP, i)
                    float t  = array.get(aI, i) / maxI
                    int   b0Raw = array.get(aB, i)
                    int   b0 = math.max(b0Raw, safeLeft)
                    int   rt = bar_index + 4
                    color hc = f_heat(t)
                    int   tr = int(86.0 - math.pow(t, gammaHeat) * 66.0)
                    array.push(rBx, box.new(b0, p + rowH * 0.5, rt, p - rowH * 0.5, border_color = na, bgcolor = color.new(hc, tr)))
                    budget := budget + 1
                    if t >= glowCut and budget < 440
                        array.push(rBx, box.new(b0, p + rowH * 1.3, rt, p - rowH * 1.3, border_color = na, bgcolor = color.new(hc, 92)))
                        array.push(rLn, line.new(math.max(b0, bar_index - winLen), p, rt, p, color = color.new(cL4, 0), width = 1))
                        budget := budget + 1

    // ── MAGNET BEAMS ─────────────────────────────────────────────────────────
    if showMagnets
        int rt = bar_index + 4
        if not na(magUpP)
            int magUpX = math.max(magUpB, safeLeft)
            array.push(rLn, line.new(magUpX, magUpP, rt, magUpP, color = color.new(MG, 85), width = 6))
            array.push(rLn, line.new(magUpX, magUpP, rt, magUpP, color = color.new(MG, 60), width = 3))
            array.push(rLn, line.new(magUpX, magUpP, rt, magUpP, color = color.new(MG, 0),  width = 1))
            string upLev = magUpL == 0 ? "STOPS" : str.tostring(magUpL) + "x"
            array.push(rLb, label.new(bar_index + 5, magUpP, "◤ SHORT LIQ  ≈$" + f_fmt(magUpI * close) + " • " + upLev, style = label.style_label_left, color = color.new(BGD, 25), textcolor = MG, size = size.tiny))
        if not na(magDnP)
            int magDnX = math.max(magDnB, safeLeft)
            array.push(rLn, line.new(magDnX, magDnP, rt, magDnP, color = color.new(CY, 85), width = 6))
            array.push(rLn, line.new(magDnX, magDnP, rt, magDnP, color = color.new(CY, 60), width = 3))
            array.push(rLn, line.new(magDnX, magDnP, rt, magDnP, color = color.new(CY, 0),  width = 1))
            string dnLev = magDnL == 0 ? "STOPS" : str.tostring(magDnL) + "x"
            array.push(rLb, label.new(bar_index + 5, magDnP, "◣ LONG LIQ  ≈$" + f_fmt(magDnI * close) + " • " + dnLev, style = label.style_label_left, color = color.new(BGD, 25), textcolor = CY, size = size.tiny))

    // ── SYNTHETIC ORDER BOOK ─────────────────────────────────────────────────
    if showBook and szAc > 0 and maxI > 0
        float spanUp = 0.0
        float spanDn = 0.0
        for i = 0 to szAc - 1
            float p = array.get(aP, i)
            float distPct = math.abs(p / close - 1.0) * 100.0
            if distPct <= magDistPct
                if p > close and p - close > spanUp
                    spanUp := p - close
                if p < close and close - p > spanDn
                    spanDn := close - p
        float[] binUp = array.new_float(bookBins, 0.0)
        float[] binDn = array.new_float(bookBins, 0.0)
        if spanUp > 0 or spanDn > 0
            for i = 0 to szAc - 1
                float p  = array.get(aP, i)
                float it = array.get(aI, i)
                if p > close and spanUp > 0 and p - close <= spanUp
                    int bu = int(math.min(bookBins - 1, (p - close) / spanUp * bookBins))
                    array.set(binUp, bu, array.get(binUp, bu) + it)
                if p < close and spanDn > 0 and close - p <= spanDn
                    int bd = int(math.min(bookBins - 1, (close - p) / spanDn * bookBins))
                    array.set(binDn, bd, array.get(binDn, bd) + it)
            if bookCum
                float cu = 0.0
                float cd = 0.0
                for k = 0 to bookBins - 1
                    cu := cu + array.get(binUp, k)
                    array.set(binUp, k, cu)
                    cd := cd + array.get(binDn, k)
                    array.set(binDn, k, cd)
            float normB = 0.0
            for k = 0 to bookBins - 1
                if array.get(binUp, k) > normB
                    normB := array.get(binUp, k)
                if array.get(binDn, k) > normB
                    normB := array.get(binDn, k)
            if normB > 0
                int x0 = bar_index + bookOffset
                float bhU = spanUp > 0 ? spanUp / bookBins : 0.0
                float bhD = spanDn > 0 ? spanDn / bookBins : 0.0
                for k = 0 to bookBins - 1
                    float vu = array.get(binUp, k)
                    if vu > 0 and bhU > 0 and budget < 470
                        float cU = close + (k + 0.5) * bhU
                        int   wU = int(1 + vu / normB * bookWidth)
                        array.push(rBx, box.new(x0, cU + bhU * 0.42, x0 + wU, cU - bhU * 0.42, border_color = na, bgcolor = color.new(MG, int(80.0 - vu / normB * 55.0))))
                        budget := budget + 1
                    float vd = array.get(binDn, k)
                    if vd > 0 and bhD > 0 and budget < 470
                        float cD = close - (k + 0.5) * bhD
                        int   wD = int(1 + vd / normB * bookWidth)
                        array.push(rBx, box.new(x0, cD + bhD * 0.42, x0 + wD, cD - bhD * 0.42, border_color = na, bgcolor = color.new(CY, int(80.0 - vd / normB * 55.0))))
                        budget := budget + 1
                array.push(rLn, line.new(x0, close, x0 + bookWidth + 1, close, color = color.new(GD, 30), width = 1, style = line.style_dotted))

    // ── MAJOR SWEEP FLASHES (max 4 on screen) ────────────────────────────────
    if showSweeps
        int ssz = array.size(swP)
        if ssz > 0
            for i = 0 to ssz - 1
                int age = bar_index - array.get(swB, i)
                if age <= 30
                    int   sd = array.get(swS, i)
                    color fc = sd == 1 ? MG : CY
                    array.push(rLb, label.new(array.get(swB, i), array.get(swP, i), "⚡", style = sd == 1 ? label.style_label_down : label.style_label_up, color = color.new(BGD, 100), textcolor = color.new(fc, math.min(70, age * 3)), size = size.small))

// ─────────────────────────────────────────────────────────────────────────────
//  INSTITUTIONAL DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table tb = table.new(f_dashPos(dashPos), 2, 10, bgcolor = P_BG, border_width = 1, border_color = P_BORDER, frame_width = 1, frame_color = P_BORDER)

if barstate.islast and showDash
    float imbal = poolUp + poolDn > 0 ? poolDn / (poolUp + poolDn) * 100.0 : 50.0
    color imbC = imbal >= 55 ? CY : imbal <= 45 ? MG : GD
    string biasTxt = imbal >= 55 ? "DOWN " + str.tostring(imbal, "#.#") + "%" : imbal <= 45 ? "UP " + str.tostring(100.0 - imbal, "#.#") + "%" : "NEUTRAL"

    table.cell(tb, 0, 0, "LIQUIDITY MAP v2", text_color = P_ACCENT, text_size = f_txtSize(dashSize), bgcolor = P_BG)
    table.cell(tb, 1, 0, "ALPHA WIZARD", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_BG)

    table.cell(tb, 0, 1, "BAR DELTA", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 1, (barDelta >= 0 ? "+" : "") + f_fmt(barDelta), text_color = barDelta >= 0 ? CY : MG, text_size = size.tiny, bgcolor = P_CELL)

    table.cell(tb, 0, 2, "CUM DELTA D", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 2, (cumDelta >= 0 ? "+" : "") + f_fmt(cumDelta), text_color = cumDelta >= 0 ? CY : MG, text_size = size.tiny, bgcolor = P_CELL)

    table.cell(tb, 0, 3, "LONG / SHORT LIQ", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 3, "$" + f_fmt(poolDn * close) + " / $" + f_fmt(poolUp * close), text_color = P_TEXT, text_size = size.tiny, bgcolor = P_CELL)

    table.cell(tb, 0, 4, "PULL BIAS", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 4, biasTxt, text_color = imbC, text_size = size.tiny, bgcolor = P_CELL)

    table.cell(tb, 0, 5, "SHORT MAGNET", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 5, na(magUpP) ? "—" : str.tostring(magUpP, format.mintick) + " +" + str.tostring((magUpP / close - 1.0) * 100.0, "#.##") + "%", text_color = MG, text_size = size.tiny, bgcolor = P_CELL)

    table.cell(tb, 0, 6, "LONG MAGNET", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 6, na(magDnP) ? "—" : str.tostring(magDnP, format.mintick) + " -" + str.tostring((1.0 - magDnP / close) * 100.0, "#.##") + "%", text_color = CY, text_size = size.tiny, bgcolor = P_CELL)

    table.cell(tb, 0, 7, "WALLS A / H", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 7, str.tostring(array.size(aP)) + " / " + str.tostring(array.size(dP)), text_color = P_TEXT, text_size = size.tiny, bgcolor = P_CELL)

    table.cell(tb, 0, 8, "PROFILE / LTF", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 8, levProfile + " / " + autoLtf + "m", text_color = P_TEXT, text_size = size.tiny, bgcolor = P_CELL)

    table.cell(tb, 0, 9, "MODE", text_color = P_MUTED, text_size = size.tiny, bgcolor = P_CELL)
    table.cell(tb, 1, 9, (showHeat ? "HEAT " : "") + (showBook ? "BOOK " : "") + (showMagnets ? "MAG " : "") + (useLtfDelta ? "LTF" : "BAR"), text_color = P_ACCENT, text_size = size.tiny, bgcolor = P_CELL)

if barstate.islast and not showDash
    table.clear(tb, 0, 0, 1, 9)

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS + HIDDEN OUTPUTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(majorSweepUp, "MAJOR Short Wall Swept ▲", "LIQMAP v2: major short-liquidation wall consumed above — squeeze fuel spent.")
alertcondition(majorSweepDn, "MAJOR Long Wall Swept ▼",  "LIQMAP v2: major long-liquidation wall consumed below — flush event.")
alertcondition(ta.cross(cumDelta, 0), "Cumulative Delta Flip", "LIQMAP v2: session cumulative delta flipped sign.")

plot(cumDelta, "CumDelta",    display = display.none)
plot(barDelta, "BarDelta",    display = display.none)
plot(magUpP,   "ShortMagnet", display = display.none)
plot(magDnP,   "LongMagnet",  display = display.none)
````
