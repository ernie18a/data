<!-- tradingview-pine-id: PUB;0c828d8311b84dd3ad732eea6c14cd7c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweep Quality Engine [algotim]

Source: https://www.tradingview.com/script/zD4GqLWC-Liquidity-Sweep-Quality-Engine-algotim/

## Description

Liquidity Sweep Engine with Quality Scoring is a liquidity-based market structure indicator designed to identify confirmed sweep events around previously established swing highs and swing lows.

Rather than treating every sweep as equally important, the script evaluates each event through a multi-factor validation framework that measures penetration depth, rejection quality, participation, and displacement. The result is a ranked sweep signal that helps separate meaningful liquidity events from routine market noise.

In addition to sweep detection, the indicator creates post-sweep memory zones that allow traders to monitor areas where significant liquidity interactions previously occurred.

Problem Statement
Many liquidity sweep tools generate signals whenever price briefly trades beyond a recent high or low. While these events occur frequently, a large percentage are minor volatility spikes that provide little analytical value.

This script was created to address that problem by introducing a structured quality assessment process.

Instead of asking:

"Did price sweep a level?"

the indicator asks:

"How meaningful was the sweep?"

Only sweeps that demonstrate sufficient penetration, rejection, participation, and displacement receive higher quality scores and stronger visual emphasis.

Methodology
The indicator begins by identifying confirmed swing highs and swing lows using pivot-based structure detection. These levels are stored as active liquidity levels and remain valid until they are swept or expire due to age.

When price interacts with one of these levels, the script evaluates whether a valid liquidity sweep has occurred:

Buy-Side Liquidity Sweep (BSL)
A buy-side sweep occurs when price trades above a confirmed swing high but closes back below that level.

Sell-Side Liquidity Sweep (SSL)
A sell-side sweep occurs when price trades below a confirmed swing low but closes back above that level.

Each detected sweep is then evaluated using the Sweep Quality Score engine.

Signal Workflow
Step 1 — Liquidity Level Registration
Confirmed pivot highs and lows are stored as active liquidity levels. Older levels automatically expire after the user-defined memory period.

Step 2 — Sweep Detection
The script monitors active liquidity levels for sweep conditions:
High exceeds swing high and closes back below.
Low exceeds swing low and closes back above.

Step 3 — Quality Scoring
Each sweep receives a score from 0 to 4.
The score consists of four independent components:
ATR-normalized wick penetration.
ATR-normalized rejection strength.
Volume confirmation above a moving-average threshold.
Body displacement confirmation relative to the prior candle.

Step 4 — Classification
Sweeps are classified as:
Weak
Qualified
Elite (SQS = 4)
depending on their final score.

Step 5 — Memory Zone Creation

After a sweep is confirmed, optional memory zones can be created and extended forward to highlight areas where liquidity was previously taken. These zones can gradually fade as they age.

Why This Indicator Is Different
Many liquidity indicators stop at detecting whether a level was breached.
This script adds a validation framework that attempts to measure the quality of the breach itself.

Key differences include:
Multi-factor sweep ranking instead of binary detection.
ATR-normalized measurements for penetration and rejection.
Optional volume participation validation.
Body displacement confirmation.
Active liquidity level lifecycle management.
Post-sweep memory zones for future reference.

The objective is not simply to show where liquidity was taken, but to highlight which sweep events displayed stronger evidence of rejection and participation.

Inputs
Liquidity Pool Detection
Swing Length
Level Memory
Sweep Quality Filters
Minimum Quality Score
ATR Length
Minimum Wick Penetration
Minimum Rejection Strength
Volume Confirmation
Volume Threshold
Volume Moving Average Length
Memory Zones
Show Memory Zones
Zone Depth
Zone Lifespan
Fade Zones
Visual Settings
Active Liquidity Levels
Sweep Labels
Weak Sweep Display
Level Extension
Colors

Separate color controls for:
Buy-side sweeps
Sell-side sweeps
Active levels
Memory zones

Alerts
The script includes alert conditions for:
Buy-Side Liquidity Sweep
Sell-Side Liquidity Sweep
Highest Quality Sweep (SQS = 4)
Any Qualified Sweep

Practical Usage
A common workflow is:
Allow the indicator to build a map of active liquidity levels.
Monitor sweeps occurring at those levels.
Prioritize higher SQS events over lower-quality sweeps.
Use memory zones to track future interactions around previously swept areas.
Combine sweep information with broader market structure, trend analysis, or risk management frameworks.

Limitations
Pivot-based levels require confirmation and therefore appear after the pivot has formed.
Liquidity sweeps do not guarantee reversals.
Volume-based scoring may behave differently on instruments with limited volume data.
High-volatility environments can still generate additional sweep activity.
Memory zones highlight historical reactions and should not be interpreted as future price predictions.

Notes
This indicator is a chart analysis tool designed to evaluate liquidity sweep behavior through a structured scoring framework. The output is intended to help organize and rank liquidity events, not to provide standalone trade recommendations.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator(
     title            = "Liquidity Sweep Quality Engine [algotim]",
     overlay          = true,
     max_lines_count  = 300,
     max_labels_count = 200,
     max_boxes_count  = 150
 )

// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 1  ▸  CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════
//  Hard limits govern pool sizes. Tuned for performance within TradingView's
//  object-count caps while supporting generous visual density.

MAX_LEVELS        = 12   // max active liquidity levels tracked
MAX_DISPLAY_LEVELS= 10   // max level lines rendered simultaneously
MAX_ZONES         = 10   // max concurrent memory zone boxes in pool


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 2  ▸  INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Liquidity Pool Detection ─────────────────────────────────────────────────
var string GRP_POOL = "⚙  Liquidity Pool Detection"

i_swingLen    = input.int  (10,  "Swing Length",
     minval=3, maxval=50, group=GRP_POOL,
     tooltip="Pivot confirmation bars. Higher = fewer but more significant levels.")
i_levelMemory = input.int  (100, "Level Memory (bars)",
     minval=20, maxval=500, group=GRP_POOL,
     tooltip="Maximum age of a level before it expires unswept.")

// ── Sweep Quality Filter ─────────────────────────────────────────────────────
var string GRP_FILTER = "🔬  Sweep Quality Filter"

i_minSQS      = input.int  (2,    "Minimum Quality Score (1–4)",
     minval=1, maxval=4, group=GRP_FILTER,
     tooltip="Only display sweeps meeting this threshold. 3–4 = highest quality.")
i_atrLen      = input.int  (14,   "ATR Length",
     minval=5, maxval=50, group=GRP_FILTER,
     tooltip="ATR period for normalising wick penetration and displacement.")
i_atrMult     = input.float(0.25, "Min Wick Penetration (× ATR)",
     minval=0.05, maxval=2.0, step=0.05, group=GRP_FILTER,
     tooltip="Minimum wick breach beyond level, as ATR multiple. Filters micro-wicks.")
i_rejMult     = input.float(0.50, "Min Rejection Strength (× ATR)",
     minval=0.1, maxval=3.0, step=0.05, group=GRP_FILTER,
     tooltip="Minimum close-to-extreme distance relative to ATR.")
i_volEnable   = input.bool (true, "Volume Confirmation",
     group=GRP_FILTER,
     tooltip="Require above-average volume on the sweep candle for a higher quality score.")
i_volMult     = input.float(1.2,  "Volume Surge Threshold (× MA)",
     minval=1.0, maxval=5.0, step=0.1, group=GRP_FILTER, inline="vol",
     tooltip="Volume must exceed this multiple of its moving average.")
i_volMaLen    = input.int  (20,   "  Vol MA Length",
     minval=5, maxval=100, group=GRP_FILTER, inline="vol")

// ── Memory Zone Settings ─────────────────────────────────────────────────────
var string GRP_ZONE = "💧  Liquidity Memory Zones"

i_showZones   = input.bool (true, "Show Memory Zones",            group=GRP_ZONE)
i_zoneDepth   = input.float(0.5,  "Zone Depth (× ATR)",
     minval=0.1, maxval=3.0, step=0.1, group=GRP_ZONE,
     tooltip="Vertical height of the post-sweep memory zone, as ATR multiple.")
i_zoneBars    = input.int  (60,   "Zone Lifespan (bars)",
     minval=10, maxval=200, group=GRP_ZONE,
     tooltip="How many bars the memory zone remains visible after a sweep.")
i_fadeZones   = input.bool (true, "Fade Zones with Age",          group=GRP_ZONE,
     tooltip="Zones become progressively more transparent as they age.")

// ── Visual Settings ──────────────────────────────────────────────────────────
var string GRP_VIS = "🎨  Visual Settings"

i_showLevels  = input.bool (true, "Show Active Liquidity Levels", group=GRP_VIS)
i_showLabels  = input.bool (true, "Show Sweep Labels",            group=GRP_VIS)
i_showWeak    = input.bool (true, "Show Weak Sweeps (Ghost Mode)",group=GRP_VIS,
     tooltip="Display low-quality sweeps as ghost signals. Disable for strong-only view.")
i_extendRight = input.bool (true, "Extend Levels Right",         group=GRP_VIS)

// ── Colour Palette ────────────────────────────────────────────────────────────
var string GRP_COL = "🖌  Colour Palette"

i_colBSL      = input.color(color.new(#00D4AA, 0),  "BSL (Bullish Sweep)",  group=GRP_COL, inline="c1")
i_colSSL      = input.color(color.new(#FF4D6D, 0),  "SSL (Bearish Sweep)",  group=GRP_COL, inline="c1")
i_colLevel    = input.color(color.new(#90A4AE, 60), "Active Levels",        group=GRP_COL, inline="c2")
i_colMemBSL   = input.color(color.new(#00D4AA, 80), "BSL Memory Zone",      group=GRP_COL, inline="c2")
i_colMemSSL   = input.color(color.new(#FF4D6D, 80), "SSL Memory Zone",      group=GRP_COL, inline="c3")

// ── Alerts ────────────────────────────────────────────────────────────────────
var string GRP_ALERT = "🔔  Alerts"
i_alertBSL    = input.bool(true, "Alert: Buy-Side Liquidity Sweep",       group=GRP_ALERT)
i_alertSSL    = input.bool(true, "Alert: Sell-Side Liquidity Sweep",      group=GRP_ALERT)
i_alertElite  = input.bool(true, "Alert: Highest Quality Sweep (SQS = 4)",group=GRP_ALERT)


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 3  ▸  CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════════

// ── ATR & Volume baseline ────────────────────────────────────────────────────
atr   = ta.atr(i_atrLen)
volMA = ta.sma(volume, i_volMaLen)

// ── Confirmed non-repainting pivots ─────────────────────────────────────────
// Pivots are confirmed after i_swingLen bars of right-side confirmation.
// Prices are captured at bar_index - i_swingLen: zero repainting.
pivotHigh = ta.pivothigh(high, i_swingLen, i_swingLen)
pivotLow  = ta.pivotlow (low,  i_swingLen, i_swingLen)

// ── Liquidity Level Registry ─────────────────────────────────────────────────
// Parallel arrays, capped at MAX_LEVELS. Oldest entry evicted when full.
var float[] lvl_price = array.new_float(0)
var int[]   lvl_bar   = array.new_int(0)   // bar index of pivot formation
var int[]   lvl_type  = array.new_int(0)   // 1 = swing high (BSL), -1 = swing low (SSL)

// Register new pivot, evicting oldest if registry is full
if not na(pivotHigh)
    if array.size(lvl_price) >= MAX_LEVELS
        array.shift(lvl_price)
        array.shift(lvl_bar)
        array.shift(lvl_type)
    array.push(lvl_price, pivotHigh)
    array.push(lvl_bar,   bar_index - i_swingLen)
    array.push(lvl_type,  1)

if not na(pivotLow)
    if array.size(lvl_price) >= MAX_LEVELS
        array.shift(lvl_price)
        array.shift(lvl_bar)
        array.shift(lvl_type)
    array.push(lvl_price, pivotLow)
    array.push(lvl_bar,   bar_index - i_swingLen)
    array.push(lvl_type, -1)

// Expire levels beyond the memory window
if array.size(lvl_price) > 0
    for idx = array.size(lvl_price) - 1 to 0
        if bar_index - array.get(lvl_bar, idx) > i_levelMemory
            array.remove(lvl_price, idx)
            array.remove(lvl_bar,   idx)
            array.remove(lvl_type,  idx)


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 4  ▸  SWEEP QUALITY SCORE ENGINE  (SQS 0–4)
// ═══════════════════════════════════════════════════════════════════════════════
//
//  Four independent components, each worth 1 point:
//
//  [1] ATR Wick Penetration
//      The wick beyond the swept level must exceed i_atrMult × ATR.
//      Ensures only meaningful breaches qualify — removes micro-noise wicks.
//
//  [2] ATR Rejection Strength
//      Distance from the sweep extreme to the close must exceed i_rejMult × ATR.
//      Confirms the candle aggressively rejected the swept level.
//
//  [3] Volume-Confirmed Sweep
//      Sweep candle volume ≥ i_volMult × volume moving average.
//      Volume-confirmed sweeps show elevated participation at the level.
//
//  [4] Body Displacement Confirmation
//      The close must re-enter at least 50% of the prior candle's body.
//      Validates that price has genuinely reversed, not merely stalled.
//
// ═══════════════════════════════════════════════════════════════════════════════

calcSQS(isBullSweep, lvlPx) =>
    // [1] Wick penetration depth beyond the swept level
    wickBeyond = isBullSweep ? (lvlPx - low)   // SSL: how far below level
                             : (high  - lvlPx)  // BSL: how far above level
    wickScore  = wickBeyond >= i_atrMult * atr ? 1 : 0

    // [2] Rejection strength (sweep extreme to close)
    rejection  = isBullSweep ? close - low   // bullish: close above wick low
                             : high  - close  // bearish: close below wick high
    rejScore   = rejection >= i_rejMult * atr ? 1 : 0

    // [3] Volume-confirmed sweep
    volScore   = i_volEnable and volume >= i_volMult * volMA ? 1 : 0

    // [4] Body displacement: close ≥ 50% back into prior candle's body
    priorMid   = (math.max(close[1], open[1]) + math.min(close[1], open[1])) / 2.0
    dispScore  = isBullSweep ? (close >= priorMid ? 1 : 0)
                              : (close <= priorMid ? 1 : 0)

    wickScore + rejScore + volScore + dispScore


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 5  ▸  SWEEP DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

// Per-bar best sweep state — reset every bar
var int   detectedType  = 0
var int   detectedSQS   = 0
var float detectedLevel = float(na)

detectedType  := 0
detectedSQS   := 0
detectedLevel := float(na)

if array.size(lvl_price) > 0
    for idx = array.size(lvl_price) - 1 to 0
        lPx  = array.get(lvl_price, idx)
        lTyp = array.get(lvl_type,  idx)

        // ── BSL Sweep: price sweeps above a swing HIGH, closes back below ─────
        if lTyp == 1
            if high > lPx and close < lPx
                sqs      = calcSQS(false, lPx)
                isStrong = sqs >= i_minSQS
                isWeak   = sqs < i_minSQS and i_showWeak and sqs >= 1
                if (isStrong or isWeak) and sqs > detectedSQS
                    detectedType  := 1
                    detectedSQS   := sqs
                    detectedLevel := lPx
                // Level is consumed regardless of display threshold
                array.remove(lvl_price, idx)
                array.remove(lvl_bar,   idx)
                array.remove(lvl_type,  idx)

        // ── SSL Sweep: price sweeps below a swing LOW, closes back above ──────
        else if lTyp == -1
            if low < lPx and close > lPx
                sqs      = calcSQS(true, lPx)
                isStrong = sqs >= i_minSQS
                isWeak   = sqs < i_minSQS and i_showWeak and sqs >= 1
                if (isStrong or isWeak) and sqs > detectedSQS
                    detectedType  := -1
                    detectedSQS   := sqs
                    detectedLevel := lPx
                array.remove(lvl_price, idx)
                array.remove(lvl_bar,   idx)
                array.remove(lvl_type,  idx)

// Convenience booleans derived from detection state
isBSL         = detectedType ==  1
isSSL         = detectedType == -1
sweepDetected = isBSL or isSSL
isStrong      = sweepDetected and detectedSQS >= i_minSQS
isElite       = sweepDetected and detectedSQS == 4


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 6  ▸  VISUAL RENDERING
// ═══════════════════════════════════════════════════════════════════════════════

// ── Colour & opacity by quality ──────────────────────────────────────────────
//  Strong sweep (SQS ≥ i_minSQS) → full opacity, vivid
//  Weak sweep   (SQS < i_minSQS) → 72% transparent, ghost appearance
//  Natural visual hierarchy — no mode toggle required

sweepBaseCol = isBSL ? i_colBSL : i_colSSL
markerAlpha  = isStrong ? 0 : 72
markerCol    = color.new(sweepBaseCol, markerAlpha)
lineCol      = color.new(sweepBaseCol, isStrong ? 20 : 82)

// ── SQS bar glyph ─────────────────────────────────────────────────────────────
sqsBar(sqs) =>
    sqs == 4 ? "████" :
     sqs == 3 ? "███░" :
     sqs == 2 ? "██░░" :
     sqs == 1 ? "█░░░" : "░░░░"

// ── Sweep label ───────────────────────────────────────────────────────────────
if sweepDetected and i_showLabels
    labelTxt   = (isBSL ? "BSL" : "SSL") + "  " + sqsBar(detectedSQS)
    labelStyle = isBSL ? label.style_label_up : label.style_label_down
    labelY     = isBSL ? low  - atr * 0.8 : high + atr * 0.8
    lblSize    = isElite ? size.normal : size.small
    txtCol     = isStrong ? color.white : color.new(color.white, 55)

    label.new(
         x         = bar_index,
         y         = labelY,
         text      = labelTxt,
         style     = labelStyle,
         color     = color.new(sweepBaseCol, markerAlpha + 5),
         textcolor = txtCol,
         size      = lblSize
     )

// ── Sweep origin line at the swept level ─────────────────────────────────────
if sweepDetected and not na(detectedLevel)
    line.new(
         x1    = bar_index - 1,
         y1    = detectedLevel,
         x2    = bar_index,
         y2    = detectedLevel,
         color = lineCol,
         style = line.style_solid,
         width = isStrong ? 2 : 1
     )

// ── Candle highlight ─────────────────────────────────────────────────────────
barcolor(
     isBSL and isStrong      ? color.new(i_colBSL, 82) :
     isSSL and isStrong      ? color.new(i_colSSL, 82) :
     isBSL and not isStrong  ? color.new(i_colBSL, 93) :
     isSSL and not isStrong  ? color.new(i_colSSL, 93) :
     na
 )


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 7  ▸  LIQUIDITY MEMORY ZONES  (box pool)
// ═══════════════════════════════════════════════════════════════════════════════
//  After a sweep, the level persists as a soft shaded zone so traders can
//  monitor future price reactions at the swept level.
//
//  PERFORMANCE: Fixed-size box pool (MAX_ZONES slots) allocated once at bar 0.
//  Each slot is either ACTIVE (birth ≥ 0) or FREE (birth = -1).
//  On new sweep: find a free slot, or evict the oldest active slot.
//  Rendering: box.set_* updates in place — no allocation after startup.
// ═══════════════════════════════════════════════════════════════════════════════

// Pool metadata — parallel fixed-size arrays of length MAX_ZONES
var float[] mz_top    = array.new_float(MAX_ZONES, float(na))
var float[] mz_bot    = array.new_float(MAX_ZONES, float(na))
var int[]   mz_birth  = array.new_int  (MAX_ZONES, -1)  // -1 = free slot
var int[]   mz_type   = array.new_int  (MAX_ZONES,  0)  // 1=BSL, -1=SSL
var box[]   mz_pool   = array.new_box  (MAX_ZONES, box(na))

// Initialise box pool on the very first bar
if barstate.isfirst
    for s = 0 to MAX_ZONES - 1
        // Create invisible placeholder box; will be configured on first use
        mz_pool.set(s, box.new(
             left         = 0,
             top          = 0.0,
             right        = 0,
             bottom       = 0.0,
             bgcolor      = color.new(color.white, 100),
             border_color = color.new(color.white, 100),
             border_width = 0
         ))

// ── Helpers: find free slot / oldest active slot ──────────────────────────────
findFreeSlot() =>
    result = -1
    for s = 0 to MAX_ZONES - 1
        if array.get(mz_birth, s) == -1
            result := s
            break
    result

findOldestSlot() =>
    oldest     = 0
    oldestBirth= array.get(mz_birth, 0)
    for s = 1 to MAX_ZONES - 1
        b = array.get(mz_birth, s)
        if b != -1 and b < oldestBirth
            oldestBirth := b
            oldest      := s
    oldest

// ── Register new memory zone on qualifying strong sweep ───────────────────────
if sweepDetected and i_showZones and isStrong
    zHalf  = atr * i_zoneDepth * 0.5
    zTop   = detectedLevel + zHalf
    zBot   = detectedLevel - zHalf
    zCol   = isBSL ? i_colMemBSL : i_colMemSSL
    zType  = isBSL ? 1 : -1

    slot = findFreeSlot()
    if slot == -1
        slot := findOldestSlot()  // evict oldest when pool is full

    // Write metadata into pool arrays
    array.set(mz_top,   slot, zTop)
    array.set(mz_bot,   slot, zBot)
    array.set(mz_birth, slot, bar_index)
    array.set(mz_type,  slot, zType)

    // Configure the pre-allocated box object in place
    bx = array.get(mz_pool, slot)
    box.set_left   (bx, bar_index - 1)
    box.set_right  (bx, bar_index + 1)
    box.set_top    (bx, zTop)
    box.set_bottom (bx, zBot)
    box.set_bgcolor(bx, zCol)
    box.set_border_color(bx, color.new(color.white, 100))

// ── Update all active zone boxes each bar ────────────────────────────────────
for s = 0 to MAX_ZONES - 1
    birth = array.get(mz_birth, s)
    if birth != -1
        age = bar_index - birth
        bx  = array.get(mz_pool, s)

        if age > i_zoneBars
            // Expire: hide box and free slot
            box.set_bgcolor(bx, color.new(color.white, 100))
            box.set_border_color(bx, color.new(color.white, 100))
            array.set(mz_birth, s, -1)
        else
            // Extend right edge to current bar
            box.set_right(bx, bar_index + 1)

            // Age-based fade: alpha 80 → 95 over zone lifespan
            if i_fadeZones
                fadeAlpha = math.round(80 + 15 * age / i_zoneBars)
                mzCol     = array.get(mz_type, s) == 1 ? i_colMemBSL : i_colMemSSL
                box.set_bgcolor(bx, color.new(mzCol, math.min(fadeAlpha, 95)))


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 8  ▸  ACTIVE LEVEL LINES  (line pool)
// ═══════════════════════════════════════════════════════════════════════════════
//  Thin level lines at each unswept liquidity pool.
//  Dashed = swing high (BSL pool) | Dotted = swing low (SSL pool)
//
//  PERFORMANCE: Fixed-size line pool of MAX_DISPLAY_LEVELS objects allocated
//  once at bar 0. Each bar: write visible levels into pool slots via set_*;
//  hide unused slots by collapsing them to a zero-height segment off-screen.
//  No line.new() or line.delete() is ever called after initialisation.
// ═══════════════════════════════════════════════════════════════════════════════

var line[] ln_pool = array.new_line(MAX_DISPLAY_LEVELS, line(na))

// Initialise line pool on first bar
if barstate.isfirst
    for s = 0 to MAX_DISPLAY_LEVELS - 1
        ln_pool.set(s, line.new(
             x1    = 0,
             y1    = 0.0,
             x2    = 0,
             y2    = 0.0,
             color = color.new(color.white, 100),
             width = 1
         ))

// Update line pool each bar
if i_showLevels
    extMode  = i_extendRight ? extend.right : extend.none
    nLevels  = math.min(array.size(lvl_price), MAX_DISPLAY_LEVELS)

    // Write active levels into pool slots
    for s = 0 to MAX_DISPLAY_LEVELS - 1
        ln = array.get(ln_pool, s)
        if s < nLevels
            lPx   = array.get(lvl_price, s)
            lBar  = array.get(lvl_bar,   s)
            lTyp  = array.get(lvl_type,  s)
            lStyle= lTyp == 1 ? line.style_dashed : line.style_dotted

            line.set_x1    (ln, lBar)
            line.set_y1    (ln, lPx)
            line.set_x2    (ln, bar_index)
            line.set_y2    (ln, lPx)
            line.set_color (ln, i_colLevel)
            line.set_style (ln, lStyle)
            line.set_extend(ln, extMode)
            line.set_width (ln, 1)
        else
            // Hide unused pool slot (collapse to invisible)
            line.set_color(ln, color.new(color.white, 100))
            line.set_x1   (ln, bar_index)
            line.set_x2   (ln, bar_index)


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 9  ▸  PLOTSHAPE SIGNALS
//  Pine v6 requires const string for size= and location=.
//  Dynamic direction resolved by splitting each into two calls.
// ═══════════════════════════════════════════════════════════════════════════════

// ── BSL signals ───────────────────────────────────────────────────────────────
plotshape(
     series   = isBSL and isStrong,
     title    = "BSL — Strong",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = i_colBSL,
     size     = size.small,
     offset   = 0
 )
plotshape(
     series   = isBSL and not isStrong and i_showWeak,
     title    = "BSL — Weak",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = color.new(i_colBSL, 72),
     size     = size.tiny,
     offset   = 0
 )

// ── SSL signals ───────────────────────────────────────────────────────────────
plotshape(
     series   = isSSL and isStrong,
     title    = "SSL — Strong",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = i_colSSL,
     size     = size.small,
     offset   = 0
 )
plotshape(
     series   = isSSL and not isStrong and i_showWeak,
     title    = "SSL — Weak",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = color.new(i_colSSL, 72),
     size     = size.tiny,
     offset   = 0
 )

// ── Highest Quality Sweep diamond accent (SQS = 4) ───────────────────────────
plotshape(
     series   = isBSL and isElite,
     title    = "Highest Quality BSL (SQS 4)",
     style    = shape.diamond,
     location = location.belowbar,
     color    = color.new(#FFD700, 0),
     size     = size.tiny,
     offset   = 0
 )
plotshape(
     series   = isSSL and isElite,
     title    = "Highest Quality SSL (SQS 4)",
     style    = shape.diamond,
     location = location.abovebar,
     color    = color.new(#FFD700, 0),
     size     = size.tiny,
     offset   = 0
 )


// ═══════════════════════════════════════════════════════════════════════════════
//  SECTION 10  ▸  ALERT CONDITIONS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(
     condition = i_alertBSL and isBSL and isStrong,
     title     = "[algotim] BSL Sweep Confirmed",
     message   = "✅ Buy-Side Liquidity Sweep | {{ticker}} | {{interval}} | SQS: Confirmed | {{time}}"
 )

alertcondition(
     condition = i_alertSSL and isSSL and isStrong,
     title     = "[algotim] SSL Sweep Confirmed",
     message   = "✅ Sell-Side Liquidity Sweep | {{ticker}} | {{interval}} | SQS: Confirmed | {{time}}"
 )

alertcondition(
     condition = i_alertElite and isElite,
     title     = "[algotim] Highest Quality Sweep — SQS 4",
     message   = "⭐ Highest Quality Sweep (SQS 4) | {{ticker}} | {{interval}} | Highest SQS Rating | {{time}}"
 )

alertcondition(
     condition = (i_alertBSL or i_alertSSL) and sweepDetected and isStrong,
     title     = "[algotim] Any Qualified Sweep",
     message   = "Liquidity Sweep | {{ticker}} | {{interval}} | {{time}}"
 )
````
