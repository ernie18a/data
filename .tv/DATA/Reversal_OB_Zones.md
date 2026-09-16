<!-- tradingview-pine-id: PUB;6a09d6e77a9441d095b55967e380c11c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Reversal OB Zones

Source: https://www.tradingview.com/script/UpDcQdvL/

## Description

REVERSAL OB ZONES

Reversal OB Zones locates the first Break of Structure in a trend and marks the Order Block and rebound zone that come with it - one setup at a time, drawn the moment the break confirms, using only price structure that already exists on the chart.

THE IDEA BEHIND IT

The indicator is built on the Smart Money Concepts / ICT idea that a trend doesn't reverse randomly: it reverses at the last point where "smart money" was still positioned in the direction of the old trend before structure broke. That point is the Order Block - the last opposing candle before the move that produced the reversal - and it tends to act as support or resistance the first time price returns to it.

To find that moment, the script tracks a trailing key level: the support (in an uptrend) or resistance (in a downtrend) left behind by the most recent genuine higher high or lower low. A pullback that doesn't make a new extreme never moves this level - only an actual new high or low does. The first candle to close back through that level is the first Break of Structure (BOS). Everything else - the Order Block and the rebound zone - is already sitting in the chart's history at that exact moment, so both are drawn immediately, on the same candle as the break, with no repainting and no waiting for future bars to "confirm" anything further.

Swing highs and lows themselves come from a pure, zero-threshold structure detector (a point counts the moment the next candle confirms it was a local extreme) - there is no ATR filter or fixed lookback window involved, so the logic behaves the same in quiet and in noisy price action.

WHAT'S ON THE CHART

Each setup is made of three parts, always drawn together:

- First BOS line and label: marks the level that broke and the candle that broke it.
- Order Block zone (teal for longs, maroon for shorts): the last opposite-colored candle before the trend's real high/low, with a small ATR buffer added beyond that extreme.
- Rebound zone (gray box): the two prior structural support/resistance levels immediately behind the Order Block. This is the room price is expected to use while retracing back up (or down) into the Order Block; it is not a level to be traded on its own - see below.

Only one setup is ever active at a time: while an Order Block and its rebound zone are on the chart, the indicator will not flag a new BOS in either direction. A setup stays on the chart until it is invalidated - there is no time-based expiry.

HOW TO USE IT

The Order Block is the only zone you trade. A bearish (maroon) Order Block is a level to look for shorts; a bullish (teal) Order Block is a level to look for longs - the trade direction always matches the color of the Order Block, not the gray zone.

The gray rebound zone is not tradable. It exists purely to define how far price is allowed to retrace before the setup is considered dead: it marks the boundary between "price is still reasonably retracing toward the Order Block" and "price has gone too far and the level no longer means anything." It is a boundary, not an entry.

A setup is invalidated - and both zones disappear together - under exactly two conditions:

1. Price closes back through the far side of the Order Block (the old trend has genuinely resumed).
2. Price closes through the far side of the gray rebound zone (support/resistance failed with no bounce, so the Order Block is no longer valid either).

If neither happens, the zones simply stay on the chart - there's no bar-count expiry to worry about.

A practical read: wait for the BOS, then watch for price to retrace back into the Order Block zone. The gray zone underneath (or above, for longs) is your line in the sand - if price closes beyond it before ever tagging the Order Block, treat the setup as invalidated rather than waiting for a reaction that structurally shouldn't be expected anymore.

INPUTS

- Look for bearish / bullish setups: enable or disable each direction independently.
- Order Block lookback: how many bars back to search for the Order Block candle.
- Pivot history to remember: how many structural key levels to keep for rebound-zone lookups.
- ATR length / buffer: controls the small buffer added beyond the Order Block's originating extreme.
- Style: colors and label size for both zones and the BOS marker.

NOTES

Because everything is built from confirmed structure rather than fixed-length pivots or volatility thresholds, the indicator works the same way across instruments and timeframes without needing to be re-tuned. As with any structural/SMC tool, treat it as a way to frame where price is likely to react, not as a standalone signal - combine it with your own confirmation and risk management.

---

## Source Code

````pine
//@version=6
indicator("Reversal OB Zones", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =========================================================================
// Sequence (bearish case shown, bullish is the mirror):
//
//  1. FIRST BOS: STRUCTURE-based, from real price swings (no fixed-length
//     pivot window). A TRAILING support level tracks the low that came right
//     before the most recent genuine higher high (it only moves forward when
//     price makes an ACTUAL new high -- a lower high during a pullback never
//     moves it, since that pullback is exactly what's testing it). The first
//     BOS is simply the moment price CLOSES BELOW that level. This survives
//     noisy pullbacks (a lower high/low mid-retracement doesn't reset
//     anything) and fires right on the break candle itself, NOT on some
//     later second/lower rally high.
//  2. The moment that happens, everything else is ALREADY computable from
//     EXISTING chart history -- nothing waits for future bars to form:
//       - REBOUND ZONE: two prior STRUCTURAL support/resistance levels --
//         not raw swing-low/high wicks. These come from the same trailing
//         key-level history used for the BOS itself (armed only by a
//         genuine new high/low, locked on the very next swing), so a
//         cluster of small wiggles inside a chop is already filtered out.
//         Pivot 1 = the level right before the one that just broke, pivot 2
//         = the next one further back that is genuinely below pivot 1.
//       - ORDER BLOCK: the last bullish candle at/before the REAL peak of
//         the uptrend that just ended.
//     Both zones are drawn immediately, together, on the same bar as the
//     BOS.
//  3. They stay active until price either closes back above the Order
//     Block zone (the old trend genuinely resumed -- thesis invalidated) or
//     closes below the rebound zone's lower edge (support failed with no
//     bounce). Nothing else removes them -- no time-based expiry.
//  4. While a zone from step 2 is still active, NO new first BOS is
//     detected at all -- in either direction -- so every Order Block that
//     ever appears on the chart always has its own BOS marker and rebound
//     zone drawn together with it, and there is never more than one Order
//     Block on screen at once.
// =========================================================================

grpPivot   = "Trend / Structure"
showBear   = input.bool(true, "Look for bearish setups (first bearish BOS -> shorts)", group = grpPivot)
showBull   = input.bool(true, "Look for bullish setups (first bullish BOS -> longs)", group = grpPivot)

grpOb      = "Order Block / Rebound Zone"
maxObLookback = input.int(30, "Search for Order Block up to N bars back", minval = 1, group = grpOb)
maxHistPivots = input.int(300, "Pivot history to remember", minval = 20, group = grpOb)
atrLen     = input.int(14, "ATR length (for the buffer)", minval = 1, group = grpOb)
bufferAtrMult = input.float(0.2, "Buffer over the trend high/low (x ATR)", minval = 0.0, step = 0.05, group = grpOb)

grpStyle   = "Style"
bosColorBull = input.color(color.new(color.lime, 0), "First BOS line (bullish)", group = grpStyle)
bosColorBear = input.color(color.new(color.red, 0), "First BOS line (bearish)", group = grpStyle)
minZoneColor = input.color(color.new(color.gray, 75), "Rebound zone (lows/highs after BOS)", group = grpStyle)
minZoneBorder = input.color(color.new(color.gray, 30), "Rebound zone border", group = grpStyle)
obColorBull  = input.color(color.new(color.teal, 75), "Order Block zone (bullish / longs)", group = grpStyle)
obColorBear  = input.color(color.new(color.maroon, 75), "Order Block zone (bearish / shorts)", group = grpStyle)
obBorderBull = input.color(color.new(color.teal, 20), "Order Block border (bullish)", group = grpStyle)
obBorderBear = input.color(color.new(color.maroon, 20), "Order Block border (bearish)", group = grpStyle)
labelSizeInput = input.string("Normal", "Label size", options = ["Small", "Normal", "Large", "Huge"], group = grpStyle)

labelSize = labelSizeInput == "Small" ? size.small : labelSizeInput == "Normal" ? size.normal : labelSizeInput == "Large" ? size.large : size.huge

atrVal = ta.atr(atrLen)

// ---------------------------- Structural swings / trend / first BOS -------
// Swing highs/lows come from PURE price structure: a bar is a swing high the
// moment the NEXT bar confirms it was a local peak (its high is higher than
// the bar right before AND the bar right after it), and a swing low the
// moment the next bar confirms it was a local trough (mirror). This is a
// plain ZERO-THRESHOLD zigzag -- there is no minimum size and nothing is
// filtered by volatility/ATR, so it reacts the exact same way to a tiny
// wiggle or a huge impulsive move: "con ruido y sin ruido". The only
// unavoidable delay is 1 bar (it has to see the bar AFTER a point to know
// that point was really a local extreme) -- there is no larger fixed-length
// pivot window involved anywhere in this.
var bool  dirUp     = true   // true: currently building an up-leg (looking for the next swing HIGH); false: building a down-leg (looking for the next swing LOW)
var float legTop    = na     // running highest wick of the current up-leg
var int   legTopBar = na
var float legBot    = na     // running lowest wick of the current down-leg
var int   legBotBar = na

if na(legTop)
    legTop := high
    legTopBar := bar_index
    legBot := low
    legBotBar := bar_index

float swingHigh    = na   // non-na only on the bar a new swing high just confirmed -- the REAL wick price
int   swingHighBar = na   // the ACTUAL bar of that peak (not the later confirmation bar)
float swingLow     = na   // non-na only on the bar a new swing low just confirmed -- the REAL wick price
int   swingLowBar  = na   // the ACTUAL bar of that trough (not the later confirmation bar)

if dirUp
    if high > legTop
        legTop := high
        legTopBar := bar_index
    if low[1] < low[2] and low[1] < low
        // the previous bar was a local trough -- the up-leg just ended
        swingHigh := legTop
        swingHighBar := legTopBar
        dirUp := false
        legBot := low[1]
        legBotBar := bar_index - 1
else
    if low < legBot
        legBot := low
        legBotBar := bar_index
    if high[1] > high[2] and high[1] > high
        // the previous bar was a local peak -- the down-leg just ended
        swingLow := legBot
        swingLowBar := legBotBar
        dirUp := true
        legTop := high[1]
        legTopBar := bar_index - 1

// most recently CONFIRMED swing high/low (and the bar each happened on) --
// needed below to know "the low right before this new high" (and mirror),
// and to anchor the BOS line to where the broken level actually started.
var float lastSwingHigh    = na
var int   lastSwingHighBar = na
var float lastSwingLow     = na
var int   lastSwingLowBar  = na
var string trend           = "none"
var line  bosLine          = na  // only the MOST RECENT first BOS marker is ever shown -- old ones are deleted, not left piled up on chop.
var label bosLabel         = na  // drawn ONLY together with a successfully-created zone (see drawBosMarker below) -- never orphaned from its Order Block

// 0 = idle, 1 = zone active. Declared here (not further down where the rest
// of the zone state lives) because primerBosDown/primerBosUp below gate on
// it directly: while EITHER is 1, no new first BOS is detected at all, in
// either direction -- "mientras haya un order block activo no debe
// detectar mas".
var int bearSeq = 0
var int bullSeq = 0

// CONTINUOUS tracking (bar by bar) of the real extreme of the current trend
// leg -- this is what anchors the Order Block later, not the swing value
// itself. Tracked whenever we are NOT in the opposite confirmed trend (so it
// also runs during "none", i.e. from the very start of the chart, instead of
// only after a formal opposite-direction BOS has already happened once).
var float curBullHigh    = na
var int   curBullHighBar = na
var float curBearLow     = na
var int   curBearLowBar  = na

if trend != "bear"
    if na(curBullHigh) or high > curBullHigh
        curBullHigh := high
        curBullHighBar := bar_index
if trend != "bull"
    if na(curBearLow) or low < curBearLow
        curBearLow := low
        curBearLowBar := bar_index

// The level that actually matters for the first BOS: a TRAILING support
// (bearish case) / resistance (bullish case). Every time price confirms a
// swing high that is a genuine NEW high (higher than the one being
// tracked), that ARMS the tracker -- and the very NEXT confirmed swing low,
// whatever it is, is immediately LOCKED IN as the support to watch (no
// need to wait for yet another, later high to "notice" it in hindsight).
// A further lower high during the same consolidation does NOT re-arm or
// move it -- that consolidation IS the test of this exact level. The first
// close below it is the first bearish BOS, full stop, on that very candle.
// Mirror for the bullish case.
var float runningHighBear   = na   // highest CONFIRMED swing high since the last reset
var bool  bearArmed         = false // true right after a fresh peak -- next swing low locks in
var float keyLowBear        = na   // support: close below it = first bearish BOS
var int   keyLowBearBar     = na
var float runningLowBull    = na   // lowest CONFIRMED swing low since the last reset
var bool  bullArmed         = false // true right after a fresh trough -- next swing high locks in
var float keyHighBull       = na   // resistance: close above it = first bullish BOS
var int   keyHighBullBar    = na

// EVERY value keyLowBear/keyHighBull has ever locked onto, in chronological
// order -- each one is already a STRUCTURALLY SIGNIFICANT trailing
// support/resistance (armed only by a genuine new high/low, locked on the
// very next swing), not a raw swing-low/high wiggle from inside a chop.
// This is what the rebound zone's two pivots are read from below: real
// prior support/resistance levels, not noise. Kept across trend flips
// (never cleared) so "already existing" history is never artificially
// bounded to the current leg.
var keyLowBearHist  = array.new_float()
var keyHighBullHist = array.new_float()

if not na(swingHigh) and trend != "bear"
    if na(runningHighBear) or swingHigh > runningHighBear
        runningHighBear := swingHigh
        bearArmed := true
if not na(swingLow) and trend != "bear" and bearArmed
    keyLowBear := swingLow
    keyLowBearBar := swingLowBar
    bearArmed := false
    array.push(keyLowBearHist, keyLowBear)
    if array.size(keyLowBearHist) > maxHistPivots
        array.remove(keyLowBearHist, 0)

if not na(swingLow) and trend != "bull"
    if na(runningLowBull) or swingLow < runningLowBull
        runningLowBull := swingLow
        bullArmed := true
if not na(swingHigh) and trend != "bull" and bullArmed
    keyHighBull := swingHigh
    keyHighBullBar := swingHighBar
    bullArmed := false
    array.push(keyHighBullHist, keyHighBull)
    if array.size(keyHighBullHist) > maxHistPivots
        array.remove(keyHighBullHist, 0)

// "first BOS" = the moment price CLOSES BELOW/ABOVE the trailing key level
// above -- no extra confirmation bars needed beyond the swing detection
// itself: the SAME candle that breaks the level is the one that counts,
// immediately.
primerBosDown = showBear and trend != "bear" and not na(keyLowBear) and close < keyLowBear and bearSeq == 0 and bullSeq == 0
primerBosUp   = showBull and trend != "bull" and not na(keyHighBull) and close > keyHighBull and bearSeq == 0 and bullSeq == 0

// REAL peak/trough of the leg that is ending right now -- this is what
// anchors the Order Block search and the edge of its zone. Captured BEFORE
// the trend-flip block below resets them.
trendPeakForBearOb    = curBullHigh
trendPeakForBearObBar = curBullHighBar
trendTroughForBullOb    = curBearLow
trendTroughForBullObBar = curBearLowBar

// roll the swing-high/low history forward (after using the pre-update
// values above for both the key-level tracking and the captured references)
if not na(swingHigh)
    lastSwingHigh := swingHigh
    lastSwingHighBar := swingHighBar
if not na(swingLow)
    lastSwingLow := swingLow
    lastSwingLowBar := swingLowBar

if primerBosUp
    trend := "bull"
    curBearLow := na
    curBearLowBar := na
    curBullHigh := high
    curBullHighBar := bar_index
    // the bearish tracker restarts clean for the next cycle
    keyLowBear := na
    keyLowBearBar := na
    runningHighBear := na
    bearArmed := false
if primerBosDown
    trend := "bear"
    curBullHigh := na
    curBullHighBar := na
    curBearLow := low
    curBearLowBar := bar_index
    // the bullish tracker restarts clean for the next cycle
    keyHighBull := na
    keyHighBullBar := na
    runningLowBull := na
    bullArmed := false

// The first-BOS marker (line + label) is drawn ONLY when its zone actually
// gets created successfully, from inside the bearish/bullish blocks further
// below -- never unconditionally -- so it can never end up pointing away
// from the Order Block it belongs to. The line runs from the bar the broken
// level was originally set (its swing bar) to the break bar itself, at that
// level's price -- a real structure line, not just a point.
// NOTE: a Pine function cannot reassign (`:=`) a global `var` -- it can only
// read it -- so this returns the new line/label instead of writing bosLine/
// bosLabel itself; the two call sites below do `bosLine := ...` with the
// result.
drawBosMarker(isBear) =>
    if not na(bosLine)
        line.delete(bosLine)
    if not na(bosLabel)
        label.delete(bosLabel)
    bosLineColor = isBear ? bosColorBear : bosColorBull
    bosLevel     = isBear ? keyLowBear : keyHighBull
    bosOriginBar = isBear ? keyLowBearBar : keyHighBullBar
    newBosLine  = line.new(bosOriginBar, bosLevel, bar_index, bosLevel, xloc = xloc.bar_index, color = bosLineColor, width = 2)
    newBosLabel = label.new(bar_index, bosLevel, isBear ? "First bearish BOS" : "First bullish BOS", xloc = xloc.bar_index, style = isBear ? label.style_label_down : label.style_label_up, color = color.new(bosLineColor, 80), textcolor = bosLineColor, size = labelSize)
    [newBosLine, newBosLabel]

// PIVOT pair for the rebound zone, read from keyLowBearHist/keyHighBullHist
// (declared up above, next to keyLowBear/keyHighBull) -- these are already
// filtered, structurally-significant support/resistance levels, not raw
// swing-low/high wicks:
//   pivot 1 = the support level right before the one that just broke (the
//             array's last entry IS the one that just broke, so pivot 1 is
//             one slot back from the end).
//   pivot 2 = continuing further back, the next one that is actually below
//             pivot 1 (skips over anything that isn't genuinely lower).
pivotPairBear() =>
    p1 = float(na)
    p2 = float(na)
    n = array.size(keyLowBearHist)
    if n >= 2
        p1 := array.get(keyLowBearHist, n - 2)
        idx = n - 3
        while idx >= 0 and na(p2)
            v = array.get(keyLowBearHist, idx)
            if v < p1
                p2 := v
            idx -= 1
    [p1, p2]

// mirror of pivotPairBear, for the bullish case (keyHighBullHist).
pivotPairBull() =>
    p1 = float(na)
    p2 = float(na)
    n = array.size(keyHighBullHist)
    if n >= 2
        p1 := array.get(keyHighBullHist, n - 2)
        idx = n - 3
        while idx >= 0 and na(p2)
            v = array.get(keyHighBullHist, idx)
            if v > p1
                p2 := v
            idx -= 1
    [p1, p2]

// ---------------------------- BEARISH sequence (for shorts) ----------------
// As soon as the first bearish BOS fires, BOTH zones are drawn immediately
// (0 = idle, 1 = both zones active) -- see the header comment at the top of
// the file for why nothing here waits for future bars. bearSeq/bullSeq
// themselves are declared further up, next to `trend`, because
// primerBosDown/primerBosUp need to read them.
var float bearMinTop    = na
var float bearMinBot    = na
var box   bearMinBox    = na
var float bearObZoneTop = na
var float bearObZoneBot = na
var box   bearObBox     = na
var label bearObLabel   = na
var int   bearStartBar  = na

// ---------------------------- BULLISH sequence (for longs) -----------------
var float bullMaxTop    = na
var float bullMaxBot    = na
var box   bullMaxBox    = na
var float bullObZoneTop = na
var float bullObZoneBot = na
var box   bullObBox     = na
var label bullObLabel   = na
var int   bullStartBar  = na

// (No cross-cancellation block needed: primerBosDown/primerBosUp now
// require bearSeq == 0 AND bullSeq == 0 to fire at all, so a fresh BOS can
// never appear while the opposite sequence -- or this same one -- is still
// active.)

// ---- Bearish: BOS fires -> draw both zones immediately, together ---------
if primerBosDown and bearSeq == 0 and bullSeq == 0
    // The order block is the LAST bullish candle AT/BEFORE the REAL peak of
    // the uptrend leg that just ended.
    obBot = float(na)
    obBotBar = int(na)
    if not na(trendPeakForBearObBar)
        peakOffset = bar_index - trendPeakForBearObBar
        for i = peakOffset to peakOffset + maxObLookback
            if na(obBot) and close[i] > open[i]
                obBot := low[i]
                obBotBar := bar_index - i
    // Rebound zone: the two prior structural support levels (see
    // pivotPairBear above) -- not raw swing-low wicks.
    [m1, m2] = pivotPairBear()
    if not na(obBot) and not na(m1) and not na(m2)
        bearMinTop := m1
        bearMinBot := m2
        // left edge anchored to keyLowBearBar (same origin as the BOS line)
        // so the box is already visibly wide the instant it's created --
        // starting it at bar_index (zero width) left it invisible until the
        // NEXT bar widened it, which is why it kept looking like it never
        // got drawn at all.
        bearMinBox := box.new(keyLowBearBar, bearMinTop, bar_index, bearMinBot, border_color = minZoneBorder, bgcolor = minZoneColor)
        bearObZoneBot := obBot
        bearObZoneTop := trendPeakForBearOb + bufferAtrMult * atrVal
        // anchored to the ACTUAL order block candle, not to the BOS bar
        bearObBox := box.new(obBotBar, bearObZoneTop, bar_index, bearObZoneBot, border_color = obBorderBear, bgcolor = obColorBear)
        bearObLabel := label.new(obBotBar, bearObZoneTop, "Order Block (short)", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(obBorderBear, 70), textcolor = obBorderBear, size = labelSize)
        bearStartBar := bar_index
        bearSeq := 1
        [newBosLine, newBosLabel] = drawBosMarker(true)
        bosLine := newBosLine
        bosLabel := newBosLabel

if bearSeq == 1 and bar_index > bearStartBar
    // invalidated ONLY if price closes back above the Order Block zone (old
    // trend genuinely resumed) or closes below the rebound zone's lower
    // edge (support failed, no bounce) -- nothing else removes the zones,
    // no time-based expiry. Only checked STARTING THE BAR AFTER creation --
    // the trigger bar's own close is, by definition, already below the
    // broken level, so checking it on that same bar could self-invalidate a
    // zone the instant it's born before you ever get to see it.
    if close > bearObZoneTop or close < bearMinBot
        box.delete(bearMinBox)
        box.delete(bearObBox)
        label.delete(bearObLabel)
        bearSeq := 0
    else
        box.set_right(bearMinBox, bar_index)
        box.set_right(bearObBox, bar_index)

// ---- Bullish: BOS fires -> draw both zones immediately, together ---------
if primerBosUp and bullSeq == 0 and bearSeq == 0
    // Mirror of the bearish case: the order block is the LAST bearish
    // candle AT/BEFORE the REAL trough of the downtrend leg that just
    // ended.
    obTop = float(na)
    obTopBar = int(na)
    if not na(trendTroughForBullObBar)
        peakOffset = bar_index - trendTroughForBullObBar
        for i = peakOffset to peakOffset + maxObLookback
            if na(obTop) and close[i] < open[i]
                obTop := high[i]
                obTopBar := bar_index - i
    // Rebound zone: the two prior structural resistance levels (see
    // pivotPairBull above) -- not raw swing-high wicks.
    [m1, m2] = pivotPairBull()
    if not na(obTop) and not na(m1) and not na(m2)
        bullMaxTop := m2
        bullMaxBot := m1
        // (see the bearish block above for why this is anchored to
        // keyHighBullBar instead of bar_index)
        bullMaxBox := box.new(keyHighBullBar, bullMaxTop, bar_index, bullMaxBot, border_color = minZoneBorder, bgcolor = minZoneColor)
        bullObZoneTop := obTop
        bullObZoneBot := trendTroughForBullOb - bufferAtrMult * atrVal
        bullObBox := box.new(obTopBar, bullObZoneTop, bar_index, bullObZoneBot, border_color = obBorderBull, bgcolor = obColorBull)
        bullObLabel := label.new(obTopBar, bullObZoneBot, "Order Block (long)", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(obBorderBull, 70), textcolor = obBorderBull, size = labelSize)
        bullStartBar := bar_index
        bullSeq := 1
        [newBosLine2, newBosLabel2] = drawBosMarker(false)
        bosLine := newBosLine2
        bosLabel := newBosLabel2

if bullSeq == 1 and bar_index > bullStartBar
    // (see the bearish block above for why this only starts checking the
    // bar AFTER creation, not on the trigger bar itself, and why there is
    // no time-based expiry)
    if close < bullObZoneBot or close > bullMaxTop
        box.delete(bullMaxBox)
        box.delete(bullObBox)
        label.delete(bullObLabel)
        bullSeq := 0
    else
        box.set_right(bullMaxBox, bar_index)
        box.set_right(bullObBox, bar_index)
````
