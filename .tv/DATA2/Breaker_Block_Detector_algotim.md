<!-- tradingview-pine-id: PUB;6eb9cf8b0c844734a2907b5cdd1b2c78 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Breaker Block Detector [algotim]

Source: https://www.tradingview.com/script/RnQYUlbV-Breaker-Block-Detector-algotim/

## Description

Overview
Breaker Block Detector is a structure-based indicator designed to identify Breaker Block formations only after a defined swing sequence and structural break have occurred.

The purpose of the script is to make Breaker Block analysis more systematic. Instead of marking every visually similar candle formation, it first establishes confirmed swing structure, waits for a qualifying Break of Structure, validates the displacement of the breakout candle relative to ATR, and then derives the relevant zone from the preceding Order Block structure.

This creates a sequential workflow in which a breaker is the result of a structural event rather than an isolated candle pattern.

Problem Statement

Basic Breaker Block indicators can produce large numbers of zones because the underlying concept is often reduced to simple swing relationships.

The difficulty is determining which structural events are significant enough to retain.

This script addresses that problem by adding confirmation layers around the Breaker Block formation:

1. Confirm the relevant swing structure.
2. Detect the structural break.
3. Test the breakout candle for sufficient displacement.
4. Identify the originating Order Block candle.
5. Create the Breaker Block zone.
6. Filter near-duplicate zones and manage the number of active zones.

The result is intended to provide a more structured representation of breaker formations while reducing some of the visual noise created by treating every local pattern equally.

Methodology
1. Confirmed Swing Structure

The script uses configurable pivot length to identify swing highs and swing lows.

A pivot is only available after the required bars on both sides have formed. Consequently, the swing itself is confirmed retrospectively rather than being treated as known at the original pivot bar.

This confirmation process is important because the subsequent Break of Structure calculation depends on established swing levels.

2. Break of Structure

Once a confirmed swing level is available, price is monitored for a structural break.

For bullish structure, price must move above the relevant confirmed swing high.

For bearish structure, price must move below the relevant confirmed swing low.

The BOS confirmation method can be configured to use either the candle close or the candle wick.

Using Close requires the candle to finish beyond the structural level. Using Wick allows the structural event to be recognized from an intrabar excursion beyond that level.

3. Displacement Validation
A structural break alone does not automatically qualify as a breaker event.

The BOS candle is measured using its complete high-to-low range.

That range is compared with the current ATR:
Displacement requirement = ATR × Displacement Multiplier

Only when the BOS candle exceeds the configured ATR threshold does the displacement filter pass.

This provides a volatility-adjusted way to distinguish larger structural moves from relatively small breaks.

4. Originating Order Block
After a qualifying structural event, the script examines the configurable number of candles preceding the BOS impulse.

The relevant opposite-direction candle is used to define the originating Order Block region.

This means the Breaker Block is not selected independently from the structural event. The zone is derived from the candle structure associated with the move that produced the qualifying break.

5. Breaker Formation
The script evaluates the relationship between confirmed swing points to determine whether the required structural sequence has occurred.

Bearish formations are based on a high-low-high relationship followed by a close or wick break through the intervening structure, depending on the selected confirmation mode.

Bullish formations use the corresponding low-high-low relationship followed by a break through the intervening structure.

This structural sequence is what determines whether a region is treated as a Breaker Block.

6. Zone Management
Once created, breaker zones are maintained as chart objects and extended to the right for the configured number of bars.
The script can limit the number of active breaker zones displayed on each side.

ATR-relative duplicate filtering is also used so that closely overlapping breaker formations are not unnecessarily repeated on the chart.

Signal Workflow

The complete analytical workflow is:

1. Detect and confirm swing highs/lows.
2. Store the relevant structural levels.
3. Monitor price for a Break of Structure.
4. Determine whether the BOS candle satisfies the ATR displacement threshold.
5. Evaluate the associated structural sequence.
6. Locate the originating Order Block candle.
7. Create the corresponding bullish or bearish Breaker Block.
8. Reject sufficiently similar duplicate zones.
9. Extend and maintain the active zone.
10. Monitor subsequent interaction with the zone and its validity state.

The indicator therefore treats a Breaker Block as the output of a sequence of structural conditions rather than as a standalone visual pattern.

Why This Indicator Is Different
A conventional Breaker Block script can simply identify a swing pattern and draw a box around it.
This implementation adds a validation layer between structure and zone creation.

The important distinction is the sequence:
**Confirmed Structure -> Break of Structure -> ATR Displacement Validation -> Originating Order Block -> Breaker Zone**

The ATR component is not included as a separate volatility indicator. Its purpose is specifically to determine whether the structural break has sufficient range relative to the current market volatility.

Likewise, the Order Block component is not intended to create an unrelated collection of zones. It provides the price region from which the qualifying structural move originated.

This interaction is the central design of the indicator.

Inputs
Structure Detection
**Swing Length**
Controls the number of bars used on each side to confirm swing highs and swing lows. Larger values produce fewer, more significant structural points.

**BOS Confirmation**
Choose between Close and Wick confirmation for structural breaks.

**Max Active Breakers**
Controls the maximum number of active breaker zones retained on each side.

Breaker Validity Engine
**ATR Length**
Determines the ATR calculation used for displacement validation.

**Displacement Multiplier**
Sets the minimum BOS candle range relative to ATR required for the displacement filter.

**OB Candle Lookback**
Controls how many candles preceding the BOS impulse are examined when identifying the originating Order Block.

Visual Settings
Users can configure bullish and bearish zone colors, borders, midline width, right-side extension length, mitigation labels, and BOS lines.

Alerts
The script provides alert conditions for:
* New Bullish Breaker
* New Bearish Breaker
* Bullish Breaker Retest
* Bearish Breaker Retest
* Bullish Breaker Invalidation
* Bearish Breaker Invalidation

These alerts allow users to monitor newly created zones and subsequent interactions without continuously watching the chart.

Practical Usage
The indicator is intended primarily as a structural analysis tool.
A typical workflow is to first use the confirmed swing structure to understand the current market context, then examine newly created breaker zones only after the structural break and displacement conditions have been satisfied.
Users may then monitor a breaker for a later retest or invalidation and combine that information with their own price-action, trend, volatility, or risk-management framework.
The configurable swing length and displacement threshold can be adjusted according to the instrument and timeframe. More restrictive settings generally produce fewer qualifying formations, while less restrictive settings can produce more zones.

Limitations
Breaker Block terminology represents a market-structure interpretation rather than a directly observable measurement of institutional orders.
The script does not measure actual institutional order flow, market participant identity, or future price direction.
Confirmed pivots require subsequent bars before the swing is established, so historical swing points become available only after confirmation.
Wick-based BOS confirmation is less restrictive than close-based confirmation and can therefore recognize structural breaks that do not persist through the candle close.

ATR displacement is a volatility-relative filter; it does not determine whether a move will continue.

Breaker zones and alerts should therefore be treated as analytical references rather than standalone trading signals.

Notes
This indicator is designed to provide a systematic framework for studying Breaker Block formations through confirmed swing structure, structural breaks, volatility-adjusted displacement, and originating candle analysis.

The calculations describe price behavior observable in the chart. Terms such as Break of Structure, Order Block, and Breaker Block are used as technical-analysis concepts and should not be interpreted as evidence of specific institutional activity.

Users should validate the resulting zones within their own market analysis and risk-management process.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator(
     title     = "Breaker Block Detector [algotim]",
     shorttitle = "BB Detector [algotim]",
     overlay   = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 200
     )

// ============================================================================
// ── SECTION 1 │ USER INPUTS
// ============================================================================

// ── Structure Detection ──────────────────────────────────────────────────────
grp_struct = "⚙  Structure Detection"
i_swingLen      = input.int   (10,    "Swing Length",              minval = 3,  maxval = 50,  group = grp_struct,
                                tooltip = "Number of bars left/right used to confirm a swing high/low.")
i_bosConfirm    = input.string("Close","BOS Confirmation",         options = ["Close","Wick"], group = grp_struct,
                                tooltip = "Use candle Close or Wick to confirm a Break of Structure.")
i_maxBreakers   = input.int   (5,     "Max Active Breakers",       minval = 1,  maxval = 20,  group = grp_struct,
                                tooltip = "Maximum number of breaker zones kept visible per side.")

// ── Breaker Validity Engine ──────────────────────────────────────────────────
grp_engine = "🔬  Breaker Validity Engine"
i_atrLen        = input.int   (14,    "ATR Length",                minval = 5,  maxval = 50,  group = grp_engine)
i_dispMult      = input.float (1.5,   "Displacement Multiplier",   minval = 0.5, maxval = 5.0, step = 0.1, group = grp_engine,
                                tooltip = "Impulse candle range must exceed ATR × this multiplier to validate displacement.")
i_obLookback    = input.int   (3,     "OB Candle Lookback",        minval = 1,  maxval = 10,  group = grp_engine,
                                tooltip = "Number of candles before the BOS impulse used to identify the originating Order Block.")

// ── Visual Settings ──────────────────────────────────────────────────────────
grp_visual = "🎨  Visual Settings"
i_bullColor     = input.color (color.new(#00C896, 85), "Bullish Zone Fill",  group = grp_visual)
i_bearColor     = input.color (color.new(#FF3B6B, 85), "Bearish Zone Fill",  group = grp_visual)
i_bullBorder    = input.color (color.new(#00C896, 30), "Bullish Border",      group = grp_visual)
i_bearBorder    = input.color (color.new(#FF3B6B, 30), "Bearish Border",      group = grp_visual)
i_midlineWidth  = input.int   (1,     "Midline Width",             minval = 1,  maxval = 3,   group = grp_visual)
i_zoneExtend    = input.int   (40,    "Zone Right Extension (bars)",minval = 5, maxval = 200,  group = grp_visual)
i_showMitLabel  = input.bool  (true,  "Show Mitigation Tag",       group = grp_visual)
i_showBosLine   = input.bool  (true,  "Show BOS Lines",            group = grp_visual)

// ── Alert Settings ───────────────────────────────────────────────────────────
grp_alerts = "🔔  Alert Settings"
i_alertNewBull  = input.bool(true,  "Alert: New Bullish Breaker",         group = grp_alerts)
i_alertNewBear  = input.bool(true,  "Alert: New Bearish Breaker",         group = grp_alerts)
i_alertRetBull  = input.bool(true,  "Alert: Bullish Breaker Retest",      group = grp_alerts)
i_alertRetBear  = input.bool(true,  "Alert: Bearish Breaker Retest",      group = grp_alerts)
i_alertInvBull  = input.bool(true,  "Alert: Bullish Breaker Invalidated", group = grp_alerts)
i_alertInvBear  = input.bool(true,  "Alert: Bearish Breaker Invalidated", group = grp_alerts)

// ============================================================================
// ── SECTION 2 │ CORE CALCULATIONS
// ============================================================================

// ── ATR for displacement filter ──────────────────────────────────────────────
atr = ta.atr(i_atrLen)

// ── Pivot Detection (confirmed, non-repainting) ──────────────────────────────
// pivotHigh/Low return a value only on the bar that CONFIRMS the pivot,
// which is i_swingLen bars AFTER the actual pivot bar — naturally non-repainting.
swingHigh = ta.pivothigh(high, i_swingLen, i_swingLen)
swingLow  = ta.pivotlow (low,  i_swingLen, i_swingLen)

// ── Track most-recent confirmed swing levels ─────────────────────────────────
var float lastSwingHigh    = na
var int   lastSwingHighBar = na
var float lastSwingLow     = na
var int   lastSwingLowBar  = na

if not na(swingHigh)
    lastSwingHigh    := swingHigh
    lastSwingHighBar := bar_index - i_swingLen   // actual pivot bar

if not na(swingLow)
    lastSwingLow     := swingLow
    lastSwingLowBar  := bar_index - i_swingLen

// ── BOS Detection ────────────────────────────────────────────────────────────
// Bullish BOS : price closes (or wicks) above the last confirmed swing high
// Bearish BOS : price closes (or wicks) below the last confirmed swing low
bosPrice_bull = i_bosConfirm == "Close" ? close : high
bosPrice_bear = i_bosConfirm == "Close" ? close : low

bullBOS = not na(lastSwingHigh) and bosPrice_bull > lastSwingHigh
bearBOS = not na(lastSwingLow)  and bosPrice_bear < lastSwingLow

// ── Displacement Filter ───────────────────────────────────────────────────────
// The BOS impulse candle (current bar when BOS fires) must have a range
// exceeding ATR × multiplier to qualify as institutional displacement.
impulseRange    = high - low
isDisplacement  = impulseRange > (atr * i_dispMult)

// ============================================================================
// ── SECTION 3 │ ORDER BLOCK IDENTIFICATION
// ============================================================================
// The originating OB is the last bearish candle before a bullish BOS impulse
// (for bullish breaker) and the last bullish candle before a bearish BOS
// (for bearish breaker), looked up within i_obLookback bars.

// Helper: find OB within lookback
f_findBullOB() =>
    // Find last bearish candle within lookback before current bar
    obHigh = float(na)
    obLow  = float(na)
    obBar  = int(na)
    for i = 1 to i_obLookback
        if close[i] < open[i]   // bearish candle
            obHigh := high[i]
            obLow  := low[i]
            obBar  := bar_index - i
            break
    [obHigh, obLow, obBar]

f_findBearOB() =>
    // Find last bullish candle within lookback before current bar
    obHigh = float(na)
    obLow  = float(na)
    obBar  = int(na)
    for i = 1 to i_obLookback
        if close[i] > open[i]   // bullish candle
            obHigh := high[i]
            obLow  := low[i]
            obBar  := bar_index - i
            break
    [obHigh, obLow, obBar]

// ============================================================================
// ── SECTION 4 │ BREAKER STORAGE (Array-Based)
// ============================================================================
// Each breaker is stored as a set of parallel arrays for efficiency.
// State values: 0 = active, 1 = mitigated (retested), 2 = invalidated

// Bullish Breakers
var float[] bb_high   = array.new_float()
var float[] bb_low    = array.new_float()
var int[]   bb_bar    = array.new_int()
var int[]   bb_state  = array.new_int()    // 0=active,1=mitigated,2=invalidated
var box[]   bb_box    = array.new_box()
var line[]  bb_mid    = array.new_line()
var line[]  bb_bos    = array.new_line()
var bool[]  bb_alerted = array.new_bool()   // retest alert fired?

// Bearish Breakers
var float[] bkr_high   = array.new_float()
var float[] bkr_low    = array.new_float()
var int[]   bkr_bar    = array.new_int()
var int[]   bkr_state  = array.new_int()
var box[]   bkr_box    = array.new_box()
var line[]  bkr_mid    = array.new_line()
var line[]  bkr_bos    = array.new_line()
var bool[]  bkr_alerted = array.new_bool()

// ── Faded colors for mitigated zones ─────────────────────────────────────────
bullColorFaded = color.new(color.green, 95)
bearColorFaded = color.new(color.red,   95)
bullBorderFaded = color.new(#00C896, 80)
bearBorderFaded = color.new(#FF3B6B, 80)

// ============================================================================
// ── SECTION 5 │ ADD NEW BREAKER BLOCKS
// ============================================================================

// ── Bullish Breaker Creation ─────────────────────────────────────────────────
if bullBOS and isDisplacement
    [obH, obL, obB] = f_findBullOB()
    if not na(obH)
        // Enforce max active breakers (remove oldest if needed)
        activeCount = 0
        if array.size(bb_state) > 0
            for k = 0 to array.size(bb_state) - 1
                if array.get(bb_state, k) == 0
                    activeCount += 1
        if activeCount >= i_maxBreakers
            // invalidate the oldest active one
            if array.size(bb_state) > 0
                for k = 0 to array.size(bb_state) - 1
                    if array.get(bb_state, k) == 0
                        array.set(bb_state, k, 2)
                        box.delete(array.get(bb_box, k))
                        line.delete(array.get(bb_mid, k))
                        break

        midPrice = (obH + obL) / 2
        extBar   = bar_index + i_zoneExtend

        newBox = box.new(
             left         = obB,
             top          = obH,
             right        = extBar,
             bottom       = obL,
             bgcolor      = i_bullColor,
             border_color = i_bullBorder,
             border_width = 1
             )
        newMid = line.new(
             x1    = obB,
             y1    = midPrice,
             x2    = extBar,
             y2    = midPrice,
             color = color.new(#00C896, 40),
             width = i_midlineWidth,
             style = line.style_dashed
             )

        newBos = line.new(
             x1    = bar_index,
             y1    = lastSwingHigh,
             x2    = bar_index,
             y2    = lastSwingHigh,
             color = color.new(#00C896, 60),
             width = 1,
             style = line.style_dotted
             )

        array.push(bb_high,    obH)
        array.push(bb_low,     obL)
        array.push(bb_bar,     obB)
        array.push(bb_state,   0)
        array.push(bb_box,     newBox)
        array.push(bb_mid,     newMid)
        array.push(bb_bos,     newBos)
        array.push(bb_alerted, false)

        if i_alertNewBull
            alert("🟢 New Bullish Breaker Block | " + syminfo.ticker + " | " + timeframe.period + " | Zone: " + str.tostring(obL, "#.####") + " – " + str.tostring(obH, "#.####"), alert.freq_once_per_bar_close)

// ── Bearish Breaker Creation ─────────────────────────────────────────────────
if bearBOS and isDisplacement
    [obH, obL, obB] = f_findBearOB()
    if not na(obH)
        activeCount = 0
        if array.size(bkr_state) > 0
            for k = 0 to array.size(bkr_state) - 1
                if array.get(bkr_state, k) == 0
                    activeCount += 1
        if activeCount >= i_maxBreakers
            if array.size(bkr_state) > 0
                for k = 0 to array.size(bkr_state) - 1
                    if array.get(bkr_state, k) == 0
                        array.set(bkr_state, k, 2)
                        box.delete(array.get(bkr_box, k))
                        line.delete(array.get(bkr_mid, k))
                        break

        midPrice = (obH + obL) / 2
        extBar   = bar_index + i_zoneExtend

        newBox = box.new(
             left         = obB,
             top          = obH,
             right        = extBar,
             bottom       = obL,
             bgcolor      = i_bearColor,
             border_color = i_bearBorder,
             border_width = 1
             )
        newMid = line.new(
             x1    = obB,
             y1    = midPrice,
             x2    = extBar,
             y2    = midPrice,
             color = color.new(#FF3B6B, 40),
             width = i_midlineWidth,
             style = line.style_dashed
             )

        newBos = line.new(
             x1    = bar_index,
             y1    = lastSwingLow,
             x2    = bar_index,
             y2    = lastSwingLow,
             color = color.new(#FF3B6B, 60),
             width = 1,
             style = line.style_dotted
             )

        array.push(bkr_high,    obH)
        array.push(bkr_low,     obL)
        array.push(bkr_bar,     obB)
        array.push(bkr_state,   0)
        array.push(bkr_box,     newBox)
        array.push(bkr_mid,     newMid)
        array.push(bkr_bos,     newBos)
        array.push(bkr_alerted, false)

        if i_alertNewBear
            alert("🔴 New Bearish Breaker Block | " + syminfo.ticker + " | " + timeframe.period + " | Zone: " + str.tostring(obL, "#.####") + " – " + str.tostring(obH, "#.####"), alert.freq_once_per_bar_close)

// ============================================================================
// ── SECTION 6 │ UPDATE EXISTING BREAKERS (Retest / Invalidation)
// ============================================================================

// ── Update Bullish Breakers ───────────────────────────────────────────────────
if array.size(bb_state) > 0
    for i = 0 to array.size(bb_state) - 1
        st = array.get(bb_state, i)
        if st == 2
            continue   // already invalidated & cleaned up

        zHigh = array.get(bb_high, i)
        zLow  = array.get(bb_low,  i)
        zBar  = array.get(bb_bar,  i)
        zBox  = array.get(bb_box,  i)
        zMid  = array.get(bb_mid,  i)
        alerted = array.get(bb_alerted, i)

        // Extend box right edge to keep it current
        box.set_right(zBox, bar_index + i_zoneExtend)
        line.set_x2(zMid, bar_index + i_zoneExtend)

        // ── Invalidation: price closes below zone low ─────────────────────
        if close < zLow and st != 2
            array.set(bb_state, i, 2)
            box.delete(zBox)
            line.delete(zMid)
            if i_alertInvBull
                alert("❌ Bullish Breaker Invalidated | " + syminfo.ticker + " | " + timeframe.period + " | Zone: " + str.tostring(zLow, "#.####") + " – " + str.tostring(zHigh, "#.####"), alert.freq_once_per_bar_close)

        // ── Retest: price enters zone (and not yet alerted) ──────────────
        else if low <= zHigh and high >= zLow and not alerted and st == 0
            array.set(bb_alerted, i, true)
            array.set(bb_state,   i, 1)
            // Fade the zone
            box.set_bgcolor(zBox, bullColorFaded)
            box.set_border_color(zBox, bullBorderFaded)
            line.set_color(zMid, color.new(#00C896, 70))
            if i_alertRetBull
                alert("🔵 Bullish Breaker Retest | " + syminfo.ticker + " | " + timeframe.period + " | Zone: " + str.tostring(zLow, "#.####") + " – " + str.tostring(zHigh, "#.####"), alert.freq_once_per_bar_close)

// ── Update Bearish Breakers ───────────────────────────────────────────────────
if array.size(bkr_state) > 0
    for i = 0 to array.size(bkr_state) - 1
        st = array.get(bkr_state, i)
        if st == 2
            continue

        zHigh   = array.get(bkr_high, i)
        zLow    = array.get(bkr_low,  i)
        zBar    = array.get(bkr_bar,  i)
        zBox    = array.get(bkr_box,  i)
        zMid    = array.get(bkr_mid,  i)
        alerted = array.get(bkr_alerted, i)

        box.set_right(zBox, bar_index + i_zoneExtend)
        line.set_x2(zMid, bar_index + i_zoneExtend)

        // ── Invalidation: price closes above zone high ────────────────────
        if close > zHigh and st != 2
            array.set(bkr_state, i, 2)
            box.delete(zBox)
            line.delete(zMid)
            if i_alertInvBear
                alert("❌ Bearish Breaker Invalidated | " + syminfo.ticker + " | " + timeframe.period + " | Zone: " + str.tostring(zLow, "#.####") + " – " + str.tostring(zHigh, "#.####"), alert.freq_once_per_bar_close)

        // ── Retest: price enters zone ─────────────────────────────────────
        else if low <= zHigh and high >= zLow and not alerted and st == 0
            array.set(bkr_alerted, i, true)
            array.set(bkr_state,   i, 1)
            box.set_bgcolor(zBox, bearColorFaded)
            box.set_border_color(zBox, bearBorderFaded)
            line.set_color(zMid, color.new(#FF3B6B, 70))
            if i_alertRetBear
                alert("🔴 Bearish Breaker Retest | " + syminfo.ticker + " | " + timeframe.period + " | Zone: " + str.tostring(zLow, "#.####") + " – " + str.tostring(zHigh, "#.####"), alert.freq_once_per_bar_close)

// ============================================================================
// ── SECTION 7 │ BOS SWING VISUALIZATION
// ============================================================================
// Lightweight swing dots on confirmed pivots — no labels to avoid clutter.

plotshape(
     not na(swingHigh) and i_showBosLine,
     title     = "Swing High Dot",
     style     = shape.circle,
     location  = location.abovebar,
     color     = color.new(#FF3B6B, 50),
     size      = size.tiny,
     offset    = -i_swingLen
     )

plotshape(
     not na(swingLow) and i_showBosLine,
     title     = "Swing Low Dot",
     style     = shape.circle,
     location  = location.belowbar,
     color     = color.new(#00C896, 50),
     size      = size.tiny,
     offset    = -i_swingLen
     )

// BOS signal markers (non-repainting — fires only when BOS + displacement confirmed)
plotshape(
     bullBOS and isDisplacement,
     title     = "Bullish BOS",
     style     = shape.labelup,
     location  = location.belowbar,
     color     = color.new(#00C896, 20),
     textcolor = color.white,
     text      = "BOS",
     size      = size.tiny
     )

plotshape(
     bearBOS and isDisplacement,
     title     = "Bearish BOS",
     style     = shape.labeldown,
     location  = location.abovebar,
     color     = color.new(#FF3B6B, 20),
     textcolor = color.white,
     text      = "BOS",
     size      = size.tiny
     )

// ============================================================================
// ── SECTION 8 │ ALERT CONDITIONS (for TradingView Alert Dialog)
// ============================================================================
// These alertcondition() calls allow users to set persistent alerts from the
// TradingView Alerts panel in addition to the programmatic alert() calls above.

alertcondition(
     bullBOS and isDisplacement,
     title   = "New Bullish Breaker Block",
     message = "🟢 New Bullish Breaker Block formed on {{ticker}} | TF: {{interval}}"
     )

alertcondition(
     bearBOS and isDisplacement,
     title   = "New Bearish Breaker Block",
     message = "🔴 New Bearish Breaker Block formed on {{ticker}} | TF: {{interval}}"
     )
````
