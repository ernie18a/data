# Liquidity Gravity SMC Engine [Jayadev Rana]

- url: https://www.tradingview.com/script/I7oRCYgP-Liquidity-Gravity-SMC-Engine-Jayadev-Rana/
- type: indicator
- pine_id: PUB;5028289a9ea64e07a936a7bfb4c023ac
- version: 1.0

## Description

LIQUIDITY GRAVITY SMC ENGINE

WHAT IT IS

An experimental Smart Money Concepts toolkit that does not treat every order block and fair value gap as equal. Each unmitigated zone is modeled as a gravitational mass acting on price: heavy zones (born from strong displacement on high relative volume) matter more, old zones fade away, and the combined pull of all active zones is compressed into a single bounded bias reading. On top of that field sit a composite trend engine, a quality-scored buy/sell signal engine, and a pyramid re-add engine that only accepts fresh continuation zones.

THE GRAVITY MODEL (CORE ORIGINAL IDEA)

Every zone is minted with a mass at birth:

  mass = displacement impulse (in ATR units) x (0.5 + volume percentile / 100)

The mass decays exponentially with a configurable half-life, so a zone that sits unmitigated for a long time gradually loses influence:

  effective mass = mass x 0.5 ^ (age in bars / half-life)

Each bar, the script sums the pull of every active bullish zone and every active bearish zone on the current close using a softened inverse-square law (the softening epsilon prevents the value from exploding when price trades inside a zone):

  pull = effective mass / (distance in ATR ^ 2 + epsilon ^ 2)

The two fields collapse into a bounded oscillator:

  gravity bias = 100 x (bull field - bear field) / (bull field + bear field)

A reading near +100 means the active demand field dominates; near -100 means overhead supply dominates. The raw bull/bear field values, zone counts, and the bias are all exposed in the data window and on the dashboard.

ZONE DETECTION

- Order blocks: a break of a confirmed swing pivot with a displacement candle (body larger than a configurable ATR multiple) anoints the most recent opposite-color candle as the origin. Body-only or full-range zones are selectable.
- Fair value gaps: classic three-candle imbalance, filtered by a minimum gap height in ATR units and an optional minimum displacement body on the middle candle.
- Lifecycle: zones are marked on first touch, removed on a decisive close through the far side, expired after a maximum age, and capped per side (oldest dropped first).

TREND ENGINE

A composite score in -100..+100 blends three independent measurements with user weights:
1. Market structure regime from a BOS / CHoCH state machine on confirmed swing pivots.
2. Signed Kaufman efficiency ratio (how directional the recent path is versus noise).
3. ATR-normalized Hull MA slope, clamped to -1..+1.
The score passes through a hysteresis gate with separate entry and exit thresholds, so the published trend state (LONG / SHORT / NEUTRAL) does not flicker around zero.

SIGNALS AND THE RE-ADD ENGINE

A primary BUY prints when price trades into an active bullish zone and closes back above its top (a sweep and reject), while the trend state and, optionally, the gravity bias agree. Every candidate is scored with a 0-100 confluence quality:

  quality = 100 x (0.35 x trend alignment + 0.25 x gravity alignment + 0.20 x zone mass rank + 0.20 x rejection strength)

Only candidates above the quality threshold print. After a primary entry, the re-add engine arms: an ADD signal requires a FRESH zone (born after the previous entry bar), the same trend direction, and a reduced quality threshold, with a hard cap on adds per leg. Legs terminate on an opposing trend flip or an opposing CHoCH, which prints an EXIT marker. SELL logic mirrors the buy side.

INPUT GROUPS

1. Market Structure - pivot length, BOS/CHoCH lines, swing labels.
2. Order Blocks - lookback, body-only toggle, displacement filter.
3. Fair Value Gaps - minimum gap size, middle-candle displacement filter.
4. Gravity Model - mass half-life, softening epsilon, volume percentile lookback, zone expiry, zone cap.
5. Trend Engine - efficiency ratio length, Hull MA length and slope lookback, component weights, entry/exit thresholds.
6. Signals and Re-Add - primary and re-add quality thresholds, max adds per leg, cooldown, gravity alignment toggle, bar-close confirmation.
7. Visuals - zone boxes, signal labels, trend ribbon, gravity gradient bar coloring, colors.
8. Dashboard - position and text size.

ALERTS

Ten alert conditions: primary BUY, primary SELL, re-add long, re-add short, trend flip long, trend flip short, bullish zone created, bearish zone created, bullish zone touched, bearish zone touched.

INTENDED MARKETS AND TIMEFRAMES

Any symbol with volume data (crypto, futures, liquid stocks, major forex pairs). The volume percentile term falls back gracefully where volume is absent, but zone masses become less differentiated. Designed for intraday through daily timeframes; defaults were chosen on 5-minute to 1-hour charts.

NON-REPAINTING BEHAVIOR

Swing pivots confirm after the pivot length (standard pivot lag). BOS/CHoCH events are evaluated on closes against already-confirmed pivots. With "confirm on bar close" enabled (default), signals and alerts fire only on confirmed bars. No security() calls and no lookahead are used.

LIMITATIONS

- The gravity model is a heuristic, not a physical law; the inverse-square form and the half-life are modeling choices you can tune.
- Zone quality depends on the displacement and volume filters; thin or gappy instruments produce fewer, noisier zones.
- Signals are informational markers, not orders; the leg/adds bookkeeping is a visual state machine, not broker position tracking.

This is an educational tool, not financial advice. Test any settings on your own market and timeframe before relying on them.

## Source Code

````pine
//@version=6
// =============================================================================================
//
//   LIQUIDITY GRAVITY SMC ENGINE  [Jayadev Rana]
//
// =============================================================================================
//
//   CONCEPT
//   ---------------------------------------------------------------------------------------
//   This indicator models unmitigated Smart Money zones (Order Blocks and Fair Value Gaps)
//   as gravitational masses acting on price. Instead of treating every zone as equally
//   important, each zone is assigned a MASS at birth:
//
//       mass = displacement_impulse (in ATR units) * (0.5 + volume_percentile / 100)
//
//   The mass then DECAYS exponentially with a configurable half-life, so old zones lose
//   influence the longer they sit unmitigated:
//
//       effective_mass = mass * 0.5 ^ (age_in_bars / half_life)
//
//   Every bar, the script sums the pull of all active bullish zones and all active bearish
//   zones on the current price using a softened inverse-square law (Plummer softening, to
//   avoid a singularity when price sits inside a zone):
//
//       pull(zone) = effective_mass / (distance_atr^2 + epsilon^2)
//
//   The two fields are combined into a bounded oscillator:
//
//       gravity_bias = 100 * (bull_field - bear_field) / (bull_field + bear_field)
//
//   which reads like a liquidity-weighted bias meter: +100 means the entire active liquidity
//   field below price dominates (supportive), -100 means overhead supply dominates.
//
//   TREND ENGINE
//   ---------------------------------------------------------------------------------------
//   A composite Trend Score in [-100, +100] fuses three independent measurements:
//     1. Market structure regime  - BOS / CHoCH state machine on confirmed swing pivots.
//     2. Signed Kaufman Efficiency Ratio - how directional (vs noisy) the recent path is.
//     3. ATR-normalized slope of a Hull MA - low-lag drift measurement.
//   The score passes through a hysteresis gate (separate entry and exit thresholds) so the
//   published trend state does not flicker around the zero line.
//
//   SIGNALS AND THE RE-ADD (PYRAMID) ENGINE
//   ---------------------------------------------------------------------------------------
//   A PRIMARY BUY prints when price trades down into an active bullish zone and closes back
//   above its top (a mitigation + rejection), while the trend state and gravity bias agree.
//   Each candidate is scored with a 0-100 confluence QUALITY:
//
//       quality = 100 * ( 0.35 * trend_alignment
//                       + 0.25 * gravity_alignment
//                       + 0.20 * zone_mass_rank
//                       + 0.20 * rejection_strength )
//
//   After a primary entry, the RE-ADD engine arms. It fires an ADD signal only when a FRESH
//   zone (one born AFTER the previous entry bar) is mitigated in the same direction, with a
//   reduced quality threshold and a hard cap on the number of adds. This mirrors how a
//   discretionary SMC trader pyramids a trending leg: never re-enter off the same stale
//   zone, only off newly printed continuation zones.
//
//   ZONE LIFECYCLE
//   ---------------------------------------------------------------------------------------
//   created -> (optionally touched) -> consumed by a signal OR broken by a close-through
//   OR expired by age OR displaced by newer zones when the zone cap is reached.
//
//   NON-REPAINTING NOTES
//   ---------------------------------------------------------------------------------------
//   - Swing pivots confirm after `structure length` bars (standard pivot lag), and BOS /
//     CHoCH events are evaluated on closes against already-confirmed pivots.
//   - Signals evaluate close-based conditions; with "confirm on bar close" enabled they
//     only print once the bar is final.
//   - No security() calls, no lookahead, no future references anywhere.
//
//   DISCLAIMER: educational tool, not financial advice. Test before using with real funds.
//
// =============================================================================================

indicator("Liquidity Gravity SMC Engine [Jayadev Rana]",
     shorttitle = "LG-SMC",
     overlay    = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_lines_count  = 500)

// =============================================================================================
//   SECTION 1 - INPUT GROUPS
// =============================================================================================

// ---------------------------------------------------------------------------------------------
// 1.1  Market structure
// ---------------------------------------------------------------------------------------------
grpStruct = "1) Market Structure"

structLen = input.int(8, "Swing pivot length", minval = 2, maxval = 50, group = grpStruct,
     tooltip = "Bars on each side required to confirm a swing pivot. Larger = fewer, more " +
               "significant swings. The pivot confirms this many bars after it forms " +
               "(standard, non-repainting pivot lag).")

showStructLines = input.bool(true, "Show BOS / CHoCH lines", group = grpStruct,
     tooltip = "Draw a horizontal ray from the broken swing to the breaking bar, tagged " +
               "BOS (continuation break) or CHoCH (first break against the prior regime).")

showSwingLabels = input.bool(false, "Show HH / HL / LH / LL labels", group = grpStruct,
     tooltip = "Label every confirmed swing with its structural classification relative to " +
               "the previous swing of the same kind.")

// ---------------------------------------------------------------------------------------------
// 1.2  Order blocks
// ---------------------------------------------------------------------------------------------
grpOB = "2) Order Blocks"

obEnabled = input.bool(true, "Detect order blocks", group = grpOB)

obLookback = input.int(15, "Origin candle lookback", minval = 3, maxval = 50, group = grpOB,
     tooltip = "How far back (bars) to search for the origin candle (the last opposite-color " +
               "candle) when a structure break confirms an impulse.")

obBodyOnly = input.bool(true, "Use candle body only", group = grpOB,
     tooltip = "ON: the zone spans the origin candle body (open to close). " +
               "OFF: the zone spans the full candle range including wicks.")

obDispMult = input.float(1.2, "Min displacement (x ATR)", minval = 0.1, maxval = 5.0,
     step = 0.1, group = grpOB,
     tooltip = "The breaking candle body must exceed this many ATRs for the move to qualify " +
               "as displacement. Filters weak, low-conviction breaks.")

// ---------------------------------------------------------------------------------------------
// 1.3  Fair value gaps
// ---------------------------------------------------------------------------------------------
grpFVG = "3) Fair Value Gaps"

fvgEnabled = input.bool(true, "Detect fair value gaps", group = grpFVG)

fvgMinAtr = input.float(0.30, "Min gap size (x ATR)", minval = 0.05, maxval = 3.0,
     step = 0.05, group = grpFVG,
     tooltip = "A three-candle imbalance must be at least this many ATRs tall to register. " +
               "Filters micro-gaps that fill instantly.")

fvgDispMult = input.float(0.8, "Min middle-candle body (x ATR)", minval = 0.0, maxval = 5.0,
     step = 0.1, group = grpFVG,
     tooltip = "The middle (displacement) candle of the three-bar pattern must have a body " +
               "of at least this many ATRs. Set 0 to disable this filter.")

// ---------------------------------------------------------------------------------------------
// 1.4  Gravity model
// ---------------------------------------------------------------------------------------------
grpGrav = "4) Gravity Model"

gravHalfLife = input.int(120, "Mass half-life (bars)", minval = 10, maxval = 1000,
     group = grpGrav,
     tooltip = "Every this-many bars, an unmitigated zone loses half its gravitational mass. " +
               "Lower = the field is dominated by fresh zones; higher = old zones stay " +
               "influential for longer.")

gravSoften = input.float(0.75, "Softening epsilon (x ATR)", minval = 0.1, maxval = 5.0,
     step = 0.05, group = grpGrav,
     tooltip = "Plummer softening term in the inverse-square law. Prevents the pull from " +
               "exploding to infinity when price trades inside a zone, and sets how sharply " +
               "influence falls off with distance.")

gravVolLook = input.int(100, "Volume percentile lookback", minval = 20, maxval = 500,
     group = grpGrav,
     tooltip = "Window used to rank the volume of the zone-forming candle. A zone born on " +
               "99th-percentile volume carries roughly 1.5x the mass of one born on dead " +
               "volume, all else equal.")

zoneMaxAge = input.int(500, "Zone expiry age (bars)", minval = 50, maxval = 2000,
     group = grpGrav,
     tooltip = "Zones older than this are removed regardless of mitigation state. Keeps the " +
               "field relevant and the object count bounded.")

maxZonesPerSide = input.int(20, "Max active zones per side", minval = 3, maxval = 50,
     group = grpGrav,
     tooltip = "Hard cap on simultaneously tracked bullish (and, separately, bearish) zones. " +
               "When exceeded, the oldest zone is dropped first.")

// ---------------------------------------------------------------------------------------------
// 1.5  Trend engine
// ---------------------------------------------------------------------------------------------
grpTrend = "5) Trend Engine"

erLen = input.int(20, "Efficiency ratio length", minval = 5, maxval = 100, group = grpTrend,
     tooltip = "Kaufman Efficiency Ratio window: |net change| divided by the sum of absolute " +
               "bar-to-bar changes. 1 = perfectly directional path, 0 = pure noise. The sign " +
               "of the net change gives the ratio its direction.")

slopeMaLen = input.int(34, "Hull MA length (slope)", minval = 5, maxval = 200, group = grpTrend,
     tooltip = "Length of the Hull moving average whose ATR-normalized slope forms the " +
               "drift component of the trend score.")

slopeLookback = input.int(5, "Slope lookback (bars)", minval = 1, maxval = 20, group = grpTrend,
     tooltip = "Slope is measured as (HMA now - HMA this many bars ago), normalized by ATR " +
               "over the same span, then clamped to [-1, +1].")

wStruct = input.float(0.40, "Weight: structure regime", minval = 0.0, maxval = 1.0,
     step = 0.05, group = grpTrend)
wEff = input.float(0.30, "Weight: efficiency ratio", minval = 0.0, maxval = 1.0,
     step = 0.05, group = grpTrend)
wSlope = input.float(0.30, "Weight: normalized slope", minval = 0.0, maxval = 1.0,
     step = 0.05, group = grpTrend,
     tooltip = "The three weights are re-normalized internally, so they only need to be " +
               "proportionally meaningful - they do not have to sum to exactly 1.")

trendEnterTh = input.float(25.0, "Trend entry threshold", minval = 5.0, maxval = 90.0,
     step = 1.0, group = grpTrend,
     tooltip = "The composite score must exceed +threshold (or fall below -threshold) for " +
               "the trend state to switch to LONG (or SHORT).")

trendExitTh = input.float(10.0, "Trend exit threshold", minval = 0.0, maxval = 50.0,
     step = 1.0, group = grpTrend,
     tooltip = "Hysteresis: once in a trend state, the score must shrink inside +/- this " +
               "value before the state releases to NEUTRAL. Must be below the entry " +
               "threshold to have any effect.")

// ---------------------------------------------------------------------------------------------
// 1.6  Signals and re-add engine
// ---------------------------------------------------------------------------------------------
grpSig = "6) Signals & Re-Add Engine"

qualityTh = input.float(55.0, "Primary signal min quality", minval = 0.0, maxval = 100.0,
     step = 1.0, group = grpSig,
     tooltip = "Minimum 0-100 confluence quality for a PRIMARY buy or sell to print.")

reAddQualityTh = input.float(40.0, "Re-add min quality", minval = 0.0, maxval = 100.0,
     step = 1.0, group = grpSig,
     tooltip = "Reduced quality bar for pyramid ADD signals. Adds already require an " +
               "established position, an aligned trend, and a FRESH zone, so the bar can " +
               "sit lower than the primary threshold.")

maxReAdds = input.int(3, "Max re-adds per leg", minval = 0, maxval = 10, group = grpSig,
     tooltip = "Hard cap on ADD signals after each primary entry. 0 disables the re-add " +
               "engine entirely.")

signalCooldown = input.int(5, "Signal cooldown (bars)", minval = 0, maxval = 100,
     group = grpSig,
     tooltip = "Minimum bars between any two printed signals. Suppresses clusters when " +
               "price chews through several stacked zones at once.")

requireGravity = input.bool(true, "Require gravity alignment", group = grpSig,
     tooltip = "ON: a buy requires gravity bias > 0 and a sell requires gravity bias < 0. " +
               "OFF: gravity only contributes to the quality score.")

confirmOnClose = input.bool(true, "Confirm signals on bar close", group = grpSig,
     tooltip = "ON: signals and alerts fire only when the bar is confirmed (recommended, " +
               "fully non-repainting in real time). OFF: they can fire intrabar and may " +
               "disappear if the bar closes differently.")

// ---------------------------------------------------------------------------------------------
// 1.7  Visuals
// ---------------------------------------------------------------------------------------------
grpVis = "7) Visuals"

showOB = input.bool(true, "Show order block boxes", group = grpVis)
showFVG = input.bool(true, "Show fair value gap boxes", group = grpVis)
showSignals = input.bool(true, "Show BUY / SELL / ADD labels", group = grpVis)
showRibbon = input.bool(true, "Show trend ribbon", group = grpVis,
     tooltip = "Fills the space between the Hull MA and a slower EMA, colored by the " +
               "current trend state.")
gravityBarColor = input.bool(false, "Color bars by gravity bias", group = grpVis,
     tooltip = "Gradient-tints candles from bearish color (bias -100) to bullish color " +
               "(bias +100). Turn off other bar coloring in chart settings to see it.")

colBull = input.color(color.new(#26a69a, 0), "Bull accent", group = grpVis, inline = "c1")
colBear = input.color(color.new(#ef5350, 0), "Bear accent", group = grpVis, inline = "c1")
colOBBullFill = input.color(color.new(#26a69a, 82), "OB fill (bull)", group = grpVis, inline = "c2")
colOBBearFill = input.color(color.new(#ef5350, 82), "OB fill (bear)", group = grpVis, inline = "c2")
colFVGBullFill = input.color(color.new(#26a69a, 90), "FVG fill (bull)", group = grpVis, inline = "c3")
colFVGBearFill = input.color(color.new(#ef5350, 90), "FVG fill (bear)", group = grpVis, inline = "c3")

// ---------------------------------------------------------------------------------------------
// 1.8  Dashboard
// ---------------------------------------------------------------------------------------------
grpDash = "8) Dashboard"

showDash = input.bool(true, "Show dashboard", group = grpDash)

dashPos = input.string("Top right", "Position", group = grpDash,
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"])

dashSize = input.string("Small", "Text size", group = grpDash,
     options = ["Tiny", "Small", "Normal"])

// =============================================================================================
//   SECTION 2 - TYPES AND GLOBAL STATE
// =============================================================================================

// A single Smart Money zone. kind: 0 = order block, 1 = fair value gap.
// dir: +1 bullish (demand), -1 bearish (supply).
type Zone
    float top
    float bottom
    float mass
    int   birthBar
    int   kind
    int   dir
    bool  touched
    bool  used
    box   bx

// Zone stores, one array per side so the field sums stay simple and fast.
var array<Zone> bullZones = array.new<Zone>()
var array<Zone> bearZones = array.new<Zone>()

// Structure state.
var float lastPH      = na      // last confirmed pivot high price
var float lastPL      = na      // last confirmed pivot low price
var int   lastPHBar   = na      // bar index where that pivot high formed
var int   lastPLBar   = na      // bar index where that pivot low formed
var float prevPH      = na      // the pivot high before lastPH (for HH/LH tagging)
var float prevPL      = na      // the pivot low  before lastPL (for HL/LL tagging)
var bool  phBroken    = false   // has lastPH already been broken by a close?
var bool  plBroken    = false   // has lastPL already been broken by a close?
var int   structDir   = 0       // +1 bullish regime, -1 bearish regime, 0 undetermined

// Position / re-add state (signal bookkeeping, not broker orders).
var int   posDir       = 0      // +1 long leg active, -1 short leg active, 0 flat
var int   addCount     = 0      // adds taken in the current leg
var int   lastSigBar   = -99999 // bar index of the most recent printed signal
var int   lastEntryBar = -99999 // bar index of the most recent PRIMARY entry
var float lastQuality  = na     // quality of the most recent signal
var string lastSigTxt  = "-"    // dashboard text for the most recent signal

// Per-bar event flags consumed by alerts at the end of the script.
bool evBuy        = false
bool evSell       = false
bool evAddLong    = false
bool evAddShort   = false
bool evTrendUp    = false
bool evTrendDown  = false
bool evBullZone   = false
bool evBearZone   = false
bool evBullMitig  = false
bool evBearMitig  = false

// =============================================================================================
//   SECTION 3 - CORE SERIES (ALL GLOBAL, NEVER CONDITIONAL)
// =============================================================================================

atrVal = ta.atr(14)
safeAtr = math.max(atrVal, syminfo.mintick)          // never divide by zero on flat symbols

// Volume percentile of the current bar within the configured lookback (0..100).
volPct = ta.percentrank(nz(volume), gravVolLook)

// ATR regime percentile: where does current volatility sit vs its own recent history?
atrPct = ta.percentrank(atrVal, 200)

// Kaufman efficiency ratio, signed by the direction of the net move.
erNet   = close - close[erLen]
erPath  = math.sum(math.abs(ta.change(close)), erLen)
erRaw   = erPath > 0 ? math.abs(erNet) / erPath : 0.0
erSigned = erNet > 0 ? erRaw : erNet < 0 ? -erRaw : 0.0

// Low-lag drift: ATR-normalized Hull MA slope, clamped to [-1, +1].
hmaLine   = ta.hma(close, slopeMaLen)
slopeRaw  = (hmaLine - hmaLine[slopeLookback]) / (safeAtr * slopeLookback)
slopeClmp = math.max(-1.0, math.min(1.0, slopeRaw))

// Ribbon companion line.
emaSlow = ta.ema(close, slopeMaLen * 2)

// Pivots (confirmed structLen bars after the extreme - standard non-repainting lag).
ph = ta.pivothigh(high, structLen, structLen)
pl = ta.pivotlow(low, structLen, structLen)

// Candle body sizes used by displacement filters.
bodyNow  = math.abs(close - open)
bodyPrev = math.abs(close[1] - open[1])

// =============================================================================================
//   SECTION 4 - HELPER FUNCTIONS
// =============================================================================================

// Exponential half-life decay factor for a zone of the given age.
zoneDecay(int age) =>
    math.pow(0.5, math.max(age, 0) / math.max(gravHalfLife, 1))

// Effective (decayed) mass of a zone right now.
zoneEffMass(Zone z) =>
    z.mass * zoneDecay(bar_index - z.birthBar)

// Softened inverse-square pull of a zone on the given price.
// Distance is measured center-to-price in ATR units; epsilon prevents a singularity.
zonePull(Zone z, float price) =>
    mid  = (z.top + z.bottom) * 0.5
    dAtr = math.abs(price - mid) / safeAtr
    eps  = gravSoften
    zoneEffMass(z) / (dAtr * dAtr + eps * eps)

// Delete a zone's drawing object safely.
zoneEraseBox(Zone z) =>
    if not na(z.bx)
        box.delete(z.bx)

// Drop the oldest zone when a side exceeds its cap.
zoneTrim(array<Zone> arr) =>
    if array.size(arr) > maxZonesPerSide
        Zone old = array.get(arr, 0)
        zoneEraseBox(old)
        array.shift(arr)

// Map the dashboard position input to a table position constant.
dashPosition() =>
    switch dashPos
        "Top right"    => position.top_right
        "Top left"     => position.top_left
        "Bottom right" => position.bottom_right
        "Bottom left"  => position.bottom_left
        => position.middle_right

// Map the dashboard size input to a text size constant.
dashTextSize() =>
    switch dashSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        => size.normal

// Format a signed score like "+37.2" / "-8.4" without str.format brace pitfalls.
fmtSigned(float v) =>
    (v >= 0 ? "+" : "") + str.tostring(v, "#.0")

// =============================================================================================
//   SECTION 5 - MARKET STRUCTURE STATE MACHINE
// =============================================================================================
//   Confirmed pivots feed a BOS / CHoCH state machine:
//     - close above the last unbroken pivot high  -> bullish break
//         * regime was already bullish  -> BOS  (continuation)
//         * regime was bearish/neutral  -> CHoCH (character change)
//     - mirror logic for closes below the last unbroken pivot low.
//   Each pivot can be broken at most once, which stops repeated BOS spam on the same level.
// =============================================================================================

// Register newly confirmed pivots.
if not na(ph)
    prevPH := lastPH
    lastPH := ph
    lastPHBar := bar_index - structLen
    phBroken := false
    if showSwingLabels
        swingTxt = na(prevPH) ? "H" : ph > prevPH ? "HH" : "LH"
        label.new(lastPHBar, ph, swingTxt, style = label.style_label_down,
             color = color.new(colBear, 70), textcolor = colBear, size = size.tiny)

if not na(pl)
    prevPL := lastPL
    lastPL := pl
    lastPLBar := bar_index - structLen
    plBroken := false
    if showSwingLabels
        swingTxt = na(prevPL) ? "L" : pl > prevPL ? "HL" : "LL"
        label.new(lastPLBar, pl, swingTxt, style = label.style_label_up,
             color = color.new(colBull, 70), textcolor = colBull, size = size.tiny)

// Bullish break of structure.
bool bullBreak = false
if not na(lastPH) and not phBroken and close > lastPH
    bullBreak := true
    phBroken := true
    isChoch = structDir < 0
    if showStructLines
        line.new(lastPHBar, lastPH, bar_index, lastPH,
             color = color.new(colBull, isChoch ? 0 : 35),
             width = isChoch ? 2 : 1,
             style = isChoch ? line.style_solid : line.style_dashed)
        label.new(bar_index, lastPH, isChoch ? "CHoCH" : "BOS",
             style = label.style_label_down, size = size.tiny,
             color = color.new(colBull, isChoch ? 15 : 45), textcolor = color.white)
    structDir := 1

// Bearish break of structure.
bool bearBreak = false
if not na(lastPL) and not plBroken and close < lastPL
    bearBreak := true
    plBroken := true
    isChoch = structDir > 0
    if showStructLines
        line.new(lastPLBar, lastPL, bar_index, lastPL,
             color = color.new(colBear, isChoch ? 0 : 35),
             width = isChoch ? 2 : 1,
             style = isChoch ? line.style_solid : line.style_dashed)
        label.new(bar_index, lastPL, isChoch ? "CHoCH" : "BOS",
             style = label.style_label_up, size = size.tiny,
             color = color.new(colBear, isChoch ? 15 : 45), textcolor = color.white)
    structDir := -1

// =============================================================================================
//   SECTION 6 - ZONE CREATION: ORDER BLOCKS
// =============================================================================================
//   A structure break with sufficient displacement anoints an origin candle: the most
//   recent opposite-color candle inside the lookback window. Its range (or body) becomes
//   the order block. Mass is minted from the breaking candle's ATR-normalized body times
//   a volume-percentile multiplier, so blocks born from high-effort displacement start
//   heavy and blocks born from drift start light.
// =============================================================================================

// Displacement gate for the breaking candle.
bool dispOkNow = bodyNow >= obDispMult * safeAtr

if obEnabled and bullBreak and dispOkNow
    // Find the most recent down-close candle before this bar.
    int originOff = -1
    for i = 1 to obLookback
        if close[i] < open[i]
            originOff := i
            break
    if originOff > 0
        zTop = obBodyOnly ? math.max(open[originOff], close[originOff]) : high[originOff]
        zBot = obBodyOnly ? math.min(open[originOff], close[originOff]) : low[originOff]
        if zTop - zBot > syminfo.mintick
            zMass = (bodyNow / safeAtr) * (0.5 + volPct / 100.0)
            b = showOB ? box.new(bar_index - originOff, zTop, bar_index, zBot,
                 border_color = color.new(colBull, 45), border_width = 1,
                 bgcolor = colOBBullFill, extend = extend.none) : box(na)
            array.push(bullZones, Zone.new(zTop, zBot, zMass, bar_index, 0, 1, false, false, b))
            zoneTrim(bullZones)
            evBullZone := true

if obEnabled and bearBreak and dispOkNow
    // Find the most recent up-close candle before this bar.
    int originOff = -1
    for i = 1 to obLookback
        if close[i] > open[i]
            originOff := i
            break
    if originOff > 0
        zTop = obBodyOnly ? math.max(open[originOff], close[originOff]) : high[originOff]
        zBot = obBodyOnly ? math.min(open[originOff], close[originOff]) : low[originOff]
        if zTop - zBot > syminfo.mintick
            zMass = (bodyNow / safeAtr) * (0.5 + volPct / 100.0)
            b = showOB ? box.new(bar_index - originOff, zTop, bar_index, zBot,
                 border_color = color.new(colBear, 45), border_width = 1,
                 bgcolor = colOBBearFill, extend = extend.none) : box(na)
            array.push(bearZones, Zone.new(zTop, zBot, zMass, bar_index, 0, -1, false, false, b))
            zoneTrim(bearZones)
            evBearZone := true

// =============================================================================================
//   SECTION 7 - ZONE CREATION: FAIR VALUE GAPS
// =============================================================================================
//   Classic three-candle imbalance, gated by a minimum gap height and (optionally) a
//   minimum displacement body on the middle candle. FVG mass uses the gap height itself
//   as the impulse term, scaled by the middle candle's volume percentile.
// =============================================================================================

// Bullish FVG: current low gaps above the high two bars back.
bullGap = low - high[2]
bool bullFvgOk = fvgEnabled and bullGap >= fvgMinAtr * safeAtr and
     (fvgDispMult <= 0 or bodyPrev >= fvgDispMult * safeAtr)

if bullFvgOk
    zMass = (bullGap / safeAtr) * (0.5 + nz(volPct[1]) / 100.0)
    b = showFVG ? box.new(bar_index - 2, low, bar_index, high[2],
         border_color = color.new(colBull, 65), border_width = 1,
         bgcolor = colFVGBullFill, extend = extend.none) : box(na)
    array.push(bullZones, Zone.new(low, high[2], zMass, bar_index, 1, 1, false, false, b))
    zoneTrim(bullZones)
    evBullZone := true

// Bearish FVG: current high gaps below the low two bars back.
bearGap = low[2] - high
bool bearFvgOk = fvgEnabled and bearGap >= fvgMinAtr * safeAtr and
     (fvgDispMult <= 0 or bodyPrev >= fvgDispMult * safeAtr)

if bearFvgOk
    zMass = (bearGap / safeAtr) * (0.5 + nz(volPct[1]) / 100.0)
    b = showFVG ? box.new(bar_index - 2, low[2], bar_index, high,
         border_color = color.new(colBear, 65), border_width = 1,
         bgcolor = colFVGBearFill, extend = extend.none) : box(na)
    array.push(bearZones, Zone.new(low[2], high, zMass, bar_index, 1, -1, false, false, b))
    zoneTrim(bearZones)
    evBearZone := true

// =============================================================================================
//   SECTION 8 - ZONE LIFECYCLE MANAGEMENT
// =============================================================================================
//   One downward sweep per side per bar:
//     - expire zones older than the max age,
//     - remove zones broken by a decisive close through the far side,
//     - mark first touches (mitigations),
//     - keep each surviving box's right edge pinned to the current bar.
//   Downward iteration keeps indices valid while removing (see Pine runtime rules), and
//   every sweep is guarded against empty arrays.
// =============================================================================================

// --- bullish zones -------------------------------------------------------------------------
if array.size(bullZones) > 0
    for i = array.size(bullZones) - 1 to 0
        Zone z = array.get(bullZones, i)
        age = bar_index - z.birthBar
        brokenDown = close < z.bottom
        if age > zoneMaxAge or brokenDown
            zoneEraseBox(z)
            array.remove(bullZones, i)
        else
            if not z.touched and low <= z.top and z.birthBar < bar_index
                z.touched := true
                evBullMitig := true
            if not na(z.bx)
                box.set_right(z.bx, bar_index)
                if z.touched
                    box.set_bgcolor(z.bx, color.new(color.rgb(color.r(colBull),
                         color.g(colBull), color.b(colBull)), z.kind == 0 ? 88 : 93))

// --- bearish zones -------------------------------------------------------------------------
if array.size(bearZones) > 0
    for i = array.size(bearZones) - 1 to 0
        Zone z = array.get(bearZones, i)
        age = bar_index - z.birthBar
        brokenUp = close > z.top
        if age > zoneMaxAge or brokenUp
            zoneEraseBox(z)
            array.remove(bearZones, i)
        else
            if not z.touched and high >= z.bottom and z.birthBar < bar_index
                z.touched := true
                evBearMitig := true
            if not na(z.bx)
                box.set_right(z.bx, bar_index)
                if z.touched
                    box.set_bgcolor(z.bx, color.new(color.rgb(color.r(colBear),
                         color.g(colBear), color.b(colBear)), z.kind == 0 ? 88 : 93))

// =============================================================================================
//   SECTION 9 - THE GRAVITY FIELD
// =============================================================================================
//   Sum the softened inverse-square pull of every surviving zone on the current close,
//   split by side, then collapse into the bounded bias oscillator. Also capture the
//   heaviest effective mass per side (used to rank a triggering zone's mass in the
//   signal quality formula).
// =============================================================================================

float bullField   = 0.0
float bearField   = 0.0
float maxBullMass = 0.0
float maxBearMass = 0.0
int   nBull       = array.size(bullZones)
int   nBear       = array.size(bearZones)

if nBull > 0
    for i = 0 to nBull - 1
        Zone z = array.get(bullZones, i)
        bullField += zonePull(z, close)
        em = zoneEffMass(z)
        if em > maxBullMass
            maxBullMass := em

if nBear > 0
    for i = 0 to nBear - 1
        Zone z = array.get(bearZones, i)
        bearField += zonePull(z, close)
        em = zoneEffMass(z)
        if em > maxBearMass
            maxBearMass := em

fieldTotal = bullField + bearField
gravBias = fieldTotal > 0 ? 100.0 * (bullField - bearField) / fieldTotal : 0.0

// =============================================================================================
//   SECTION 10 - COMPOSITE TREND SCORE WITH HYSTERESIS
// =============================================================================================

wSum = math.max(wStruct + wEff + wSlope, 0.0001)

trendScore = 100.0 * (wStruct * structDir + wEff * erSigned + wSlope * slopeClmp) / wSum

var int trendState = 0
if trendState <= 0 and trendScore > trendEnterTh
    trendState := 1
    evTrendUp := true
else if trendState >= 0 and trendScore < -trendEnterTh
    trendState := -1
    evTrendDown := true
else if trendState != 0 and math.abs(trendScore) < trendExitTh
    trendState := 0

// =============================================================================================
//   SECTION 11 - SIGNAL ENGINE (PRIMARY + RE-ADD)
// =============================================================================================
//   Mitigation trigger (long side): this bar's low pierced into an active, unused bullish
//   zone AND the bar closed back at or above the zone top - a sweep-and-reject of the zone.
//   The heaviest qualifying zone on the bar is the one that gets scored and consumed.
//   Short side mirrors. The re-add engine only accepts zones born after the last entry.
// =============================================================================================

barOk = confirmOnClose ? barstate.isconfirmed : true
cooldownOk = bar_index - lastSigBar >= signalCooldown

// --- scan for the best qualifying zone this bar, per side -----------------------------------
float longTrigMass  = -1.0
int   longTrigIdx   = -1
bool  longTrigFresh = false

if array.size(bullZones) > 0
    for i = array.size(bullZones) - 1 to 0
        Zone z = array.get(bullZones, i)
        if not z.used and z.birthBar < bar_index and low <= z.top and close >= z.top
            em = zoneEffMass(z)
            if em > longTrigMass
                longTrigMass := em
                longTrigIdx := i
                longTrigFresh := z.birthBar > lastEntryBar

float shortTrigMass  = -1.0
int   shortTrigIdx   = -1
bool  shortTrigFresh = false

if array.size(bearZones) > 0
    for i = array.size(bearZones) - 1 to 0
        Zone z = array.get(bearZones, i)
        if not z.used and z.birthBar < bar_index and high >= z.bottom and close <= z.bottom
            em = zoneEffMass(z)
            if em > shortTrigMass
                shortTrigMass := em
                shortTrigIdx := i
                shortTrigFresh := z.birthBar > lastEntryBar

// --- confluence quality --------------------------------------------------------------------
// quality = 100 * ( 0.35*trend + 0.25*gravity + 0.20*mass rank + 0.20*rejection )
barRange = math.max(high - low, syminfo.mintick)

longQuality() =>
    tA = trendState == 1 ? 1.0 : trendState == 0 ? 0.4 : 0.0
    gA = math.max(0.0, math.min(1.0, gravBias / 100.0))
    mR = maxBullMass > 0 ? math.max(0.0, math.min(1.0, longTrigMass / maxBullMass)) : 0.0
    rJ = (close - low) / barRange
    100.0 * (0.35 * tA + 0.25 * gA + 0.20 * mR + 0.20 * rJ)

shortQuality() =>
    tA = trendState == -1 ? 1.0 : trendState == 0 ? 0.4 : 0.0
    gA = math.max(0.0, math.min(1.0, -gravBias / 100.0))
    mR = maxBearMass > 0 ? math.max(0.0, math.min(1.0, shortTrigMass / maxBearMass)) : 0.0
    rJ = (high - close) / barRange
    100.0 * (0.35 * tA + 0.25 * gA + 0.20 * mR + 0.20 * rJ)

gravLongOk  = not requireGravity or gravBias > 0
gravShortOk = not requireGravity or gravBias < 0

// --- long side decisions ---------------------------------------------------------------------
if longTrigIdx >= 0 and barOk and cooldownOk and gravLongOk and trendState >= 0
    q = longQuality()
    isPrimary = posDir <= 0
    isReAdd = posDir == 1 and addCount < maxReAdds and longTrigFresh
    if isPrimary and q >= qualityTh and trendState == 1
        Zone z = array.get(bullZones, longTrigIdx)
        z.used := true
        posDir := 1
        addCount := 0
        lastSigBar := bar_index
        lastEntryBar := bar_index
        lastQuality := q
        lastSigTxt := "BUY " + str.tostring(q, "#") + "%"
        evBuy := true
        if showSignals
            label.new(bar_index, low, "BUY\n" + str.tostring(q, "#") + "%",
                 style = label.style_label_up, color = colBull,
                 textcolor = color.white, size = size.small)
    else if isReAdd and q >= reAddQualityTh
        Zone z = array.get(bullZones, longTrigIdx)
        z.used := true
        addCount += 1
        lastSigBar := bar_index
        lastEntryBar := bar_index
        lastQuality := q
        lastSigTxt := "ADD-L " + str.tostring(addCount) + " (" + str.tostring(q, "#") + "%)"
        evAddLong := true
        if showSignals
            label.new(bar_index, low, "ADD " + str.tostring(addCount),
                 style = label.style_triangleup, color = color.new(colBull, 20),
                 textcolor = colBull, size = size.tiny)

// --- short side decisions --------------------------------------------------------------------
if shortTrigIdx >= 0 and barOk and cooldownOk and gravShortOk and trendState <= 0
    q = shortQuality()
    isPrimary = posDir >= 0
    isReAdd = posDir == -1 and addCount < maxReAdds and shortTrigFresh
    if isPrimary and q >= qualityTh and trendState == -1
        Zone z = array.get(bearZones, shortTrigIdx)
        z.used := true
        posDir := -1
        addCount := 0
        lastSigBar := bar_index
        lastEntryBar := bar_index
        lastQuality := q
        lastSigTxt := "SELL " + str.tostring(q, "#") + "%"
        evSell := true
        if showSignals
            label.new(bar_index, high, "SELL\n" + str.tostring(q, "#") + "%",
                 style = label.style_label_down, color = colBear,
                 textcolor = color.white, size = size.small)
    else if isReAdd and q >= reAddQualityTh
        Zone z = array.get(bearZones, shortTrigIdx)
        z.used := true
        addCount += 1
        lastSigBar := bar_index
        lastEntryBar := bar_index
        lastQuality := q
        lastSigTxt := "ADD-S " + str.tostring(addCount) + " (" + str.tostring(q, "#") + "%)"
        evAddShort := true
        if showSignals
            label.new(bar_index, high, "ADD " + str.tostring(addCount),
                 style = label.style_triangledown, color = color.new(colBear, 20),
                 textcolor = colBear, size = size.tiny)

// --- leg termination -------------------------------------------------------------------------
// A leg dies when the trend state flips against it (hysteresis already de-noises this),
// or when structure prints a CHoCH against the position.
if posDir == 1 and (trendState == -1 or (bearBreak and structDir == -1))
    if showSignals and barOk
        label.new(bar_index, high, "EXIT L", style = label.style_label_down,
             color = color.new(color.gray, 30), textcolor = color.white, size = size.tiny)
    posDir := 0
    addCount := 0
    lastSigTxt := "EXIT LONG"
else if posDir == -1 and (trendState == 1 or (bullBreak and structDir == 1))
    if showSignals and barOk
        label.new(bar_index, low, "EXIT S", style = label.style_label_up,
             color = color.new(color.gray, 30), textcolor = color.white, size = size.tiny)
    posDir := 0
    addCount := 0
    lastSigTxt := "EXIT SHORT"

// =============================================================================================
//   SECTION 12 - VISUALS: RIBBON, BAR COLOR, PLOTS
// =============================================================================================

ribbonUp = trendState == 1
ribbonDn = trendState == -1

pHma = plot(showRibbon ? hmaLine : na, "Hull MA", color = color.new(color.gray, 60),
     linewidth = 1, editable = false)
pEma = plot(showRibbon ? emaSlow : na, "Slow EMA", color = color.new(color.gray, 75),
     linewidth = 1, editable = false)

fill(pHma, pEma,
     color = ribbonUp ? color.new(colBull, 85) : ribbonDn ? color.new(colBear, 85)
          : color.new(color.gray, 92),
     title = "Trend ribbon")

barcolor(gravityBarColor ? color.from_gradient(gravBias, -100, 100, colBear, colBull) : na,
     title = "Gravity gradient bars")

// Data-window / alert-template exposure (not drawn on the price scale).
plot(trendScore, "Trend Score", display = display.data_window, editable = false)
plot(gravBias, "Gravity Bias", display = display.data_window, editable = false)
plot(bullField, "Bull Field", display = display.data_window, editable = false)
plot(bearField, "Bear Field", display = display.data_window, editable = false)
plot(nBull, "Active Bull Zones", display = display.data_window, editable = false)
plot(nBear, "Active Bear Zones", display = display.data_window, editable = false)
plot(posDir, "Position Dir", display = display.data_window, editable = false)
plot(addCount, "Adds This Leg", display = display.data_window, editable = false)

// =============================================================================================
//   SECTION 13 - DASHBOARD
// =============================================================================================

var table dash = na

if showDash
    if na(dash)
        dash := table.new(dashPosition(), 2, 10, bgcolor = color.new(color.black, 25),
             border_width = 1, border_color = color.new(color.gray, 70),
             frame_width = 1, frame_color = color.new(color.gray, 55))
    if barstate.islast
        txtSz = dashTextSize()
        hdrBg = color.new(color.black, 0)

        table.cell(dash, 0, 0, "LIQUIDITY GRAVITY SMC", text_color = color.white,
             text_size = txtSz, bgcolor = hdrBg)
        table.cell(dash, 1, 0, "", bgcolor = hdrBg)

        trendTxt = trendState == 1 ? "LONG" : trendState == -1 ? "SHORT" : "NEUTRAL"
        trendCol = trendState == 1 ? colBull : trendState == -1 ? colBear : color.gray
        table.cell(dash, 0, 1, "Trend state", text_color = color.silver, text_size = txtSz)
        table.cell(dash, 1, 1, trendTxt + "  " + fmtSigned(trendScore),
             text_color = trendCol, text_size = txtSz)

        gravCol = gravBias > 15 ? colBull : gravBias < -15 ? colBear : color.gray
        table.cell(dash, 0, 2, "Gravity bias", text_color = color.silver, text_size = txtSz)
        table.cell(dash, 1, 2, fmtSigned(gravBias), text_color = gravCol, text_size = txtSz)

        table.cell(dash, 0, 3, "Bull field / zones", text_color = color.silver, text_size = txtSz)
        table.cell(dash, 1, 3, str.tostring(bullField, "#.00") + "  (" +
             str.tostring(nBull) + ")", text_color = colBull, text_size = txtSz)

        table.cell(dash, 0, 4, "Bear field / zones", text_color = color.silver, text_size = txtSz)
        table.cell(dash, 1, 4, str.tostring(bearField, "#.00") + "  (" +
             str.tostring(nBear) + ")", text_color = colBear, text_size = txtSz)

        table.cell(dash, 0, 5, "Efficiency ratio", text_color = color.silver, text_size = txtSz)
        table.cell(dash, 1, 5, fmtSigned(erSigned * 100) , text_color = color.white,
             text_size = txtSz)

        volTxt = atrPct > 70 ? "EXPANSION" : atrPct < 30 ? "COMPRESSION" : "NORMAL"
        table.cell(dash, 0, 6, "Volatility regime", text_color = color.silver, text_size = txtSz)
        table.cell(dash, 1, 6, volTxt + " (" + str.tostring(atrPct, "#") + "%)",
             text_color = color.white, text_size = txtSz)

        posTxt = posDir == 1 ? "LONG +" + str.tostring(addCount) + " adds"
             : posDir == -1 ? "SHORT +" + str.tostring(addCount) + " adds" : "FLAT"
        posCol = posDir == 1 ? colBull : posDir == -1 ? colBear : color.gray
        table.cell(dash, 0, 7, "Signal leg", text_color = color.silver, text_size = txtSz)
        table.cell(dash, 1, 7, posTxt, text_color = posCol, text_size = txtSz)

        table.cell(dash, 0, 8, "Last signal", text_color = color.silver, text_size = txtSz)
        table.cell(dash, 1, 8, lastSigTxt, text_color = color.white, text_size = txtSz)

        table.cell(dash, 0, 9, "Structure", text_color = color.silver, text_size = txtSz)
        structTxt = structDir == 1 ? "BULLISH" : structDir == -1 ? "BEARISH" : "FORMING"
        structCol = structDir == 1 ? colBull : structDir == -1 ? colBear : color.gray
        table.cell(dash, 1, 9, structTxt, text_color = structCol, text_size = txtSz)

// =============================================================================================
//   SECTION 14 - ALERTS
// =============================================================================================

alertcondition(evBuy, "LG-SMC: Primary BUY",
     "Liquidity Gravity SMC: primary BUY signal - bullish zone mitigated with trend and gravity alignment.")
alertcondition(evSell, "LG-SMC: Primary SELL",
     "Liquidity Gravity SMC: primary SELL signal - bearish zone mitigated with trend and gravity alignment.")
alertcondition(evAddLong, "LG-SMC: Re-Add LONG",
     "Liquidity Gravity SMC: pyramid ADD on the long leg - fresh bullish zone mitigated.")
alertcondition(evAddShort, "LG-SMC: Re-Add SHORT",
     "Liquidity Gravity SMC: pyramid ADD on the short leg - fresh bearish zone mitigated.")
alertcondition(evTrendUp, "LG-SMC: Trend flip LONG",
     "Liquidity Gravity SMC: composite trend state flipped to LONG.")
alertcondition(evTrendDown, "LG-SMC: Trend flip SHORT",
     "Liquidity Gravity SMC: composite trend state flipped to SHORT.")
alertcondition(evBullZone, "LG-SMC: Bullish zone created",
     "Liquidity Gravity SMC: new bullish order block or fair value gap registered.")
alertcondition(evBearZone, "LG-SMC: Bearish zone created",
     "Liquidity Gravity SMC: new bearish order block or fair value gap registered.")
alertcondition(evBullMitig, "LG-SMC: Bullish zone touched",
     "Liquidity Gravity SMC: price traded into an active bullish zone for the first time.")
alertcondition(evBearMitig, "LG-SMC: Bearish zone touched",
     "Liquidity Gravity SMC: price traded into an active bearish zone for the first time.")

// =============================================================================================
//   END OF SCRIPT
// =============================================================================================
````
