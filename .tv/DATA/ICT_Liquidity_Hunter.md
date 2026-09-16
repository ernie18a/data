<!-- tradingview-pine-id: PUB;c6d80d3728284f4fbdbd89d343beb445 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Liquidity Hunter

Source: https://www.tradingview.com/script/S6WIBYjY/

## Description

ICT Liquidity Hunter

OVERVIEW

ICT Liquidity Hunter is not another "trade the CHoCH" indicator. It is built on the same Inner Circle Trader (ICT) / Smart Money Concepts structure that most ICT traders use to enter a trade, but it uses that structure for the opposite purpose: to locate where those traders end up placing their stop-loss orders, so that level can be marked as a probable liquidity target instead of an entry signal.

CONCEPT

The vast majority of retail ICT traders execute the same textbook sequence: wait for a Change of Character (CHoCH), wait for price to return to the Order Block (OB) or Fair Value Gap (FVG) left behind by that break, and enter when price shows a clean, obvious rejection at that zone. Because this sequence is taught everywhere and followed by a huge number of traders in exactly the same way, the stop-loss orders from all those entries cluster tightly just beyond the extreme of that rejection candle - a very predictable, crowded pool of resting liquidity.

This script does not stop at marking the OB/FVG zone the way a conventional ICT indicator would. It goes one step further: it waits for the same rejection the crowd is trading, then marks the exact high or low left by that rejection candle as a "Liquidity Level" - the level where the stops of everyone who just entered on that textbook retest are most likely resting. That level, not the zone itself, is the actual point of interest: it is a probable target for a subsequent liquidity run/stop hunt, either before price resumes in the "expected" direction or as the setup for a reversal against the crowd that just entered.

In short: conventional ICT tools show you where to copy the crowd's entry. This one shows you where the crowd's stops are sitting once they've already entered - so you can plan around that liquidity instead of trading the same obvious retest everyone else is watching.

WHAT IT'S MADE OF

1. Market structure / CHoCH
The script builds an alternating (zig-zag) sequence of swing highs and lows from pivot points, filtered by a minimum size (in ATR) so minor internal noise doesn't count as real structure. A CHoCH is flagged the first time price closes back through the currently active opposite swing level since the trend last flipped - the same first break of structure a traditional ICT trader would use as their starting signal.

2. Order Blocks and Fair Value Gaps
Once a CHoCH fires, the script looks back over a configurable number of bars for:
- Order Block: the last candle of the opposite color before the impulse that caused the break.
- Fair Value Gap: a 3-candle imbalance (a gap between candle 1 and candle 3) formed during that same impulse.
Both are drawn as shaded zones - above the breakout candle for a bearish CHoCH, below it for a bullish CHoCH - exactly where a conventional ICT trader would be watching for their own entry. Only a small number of zones are kept on the chart at once, and each one expires automatically if price never returns to it within a set number of bars.

3. Rejection detection
When price returns and touches an active OB/FVG zone, the script checks the candle that touches it (or the one immediately after) for a strong, obvious rejection: a candle whose range is a multiple of the recent average range, closing decisively away from the zone - the exact kind of clean reaction that convinces the crowd to enter and place stops just beyond it.

4. Liquidity Level
A valid rejection prints a solid horizontal line - the Liquidity Level - starting at the exact high (bearish rejection) or low (bullish rejection) of that candle, extending forward in time. This is not the entry the crowd took; it is the resting-stop level just beyond it, and therefore the level most likely to get run before or instead of continuation in the "obvious" direction. Liquidity lines expire automatically after a set number of bars if price never reaches them.

5. Alerts
Two alert conditions are built in: one for a bullish rejection (liquidity marked below) and one for a bearish rejection (liquidity marked above), so alerts can be set directly from the TradingView alert dialog the moment a new Liquidity Level appears.

HOW TO USE IT

- Structure group: controls how strict the swing/CHoCH detection is (pivot lookback, minimum swing size in ATR) and how long an OB/FVG zone stays valid before it expires unused.
- Order Block / FVG group: toggle Order Blocks and/or FVGs independently, set how far back to search for them after a CHoCH, and optionally require a minimum FVG size.
- Rejection candle group: controls what counts as a "strong" rejection candle (size relative to average range, how close the close must be to the extreme of the candle) and how many liquidity lines/zones stay visible at once.
- Style group: colors for bullish/bearish OB, FVG and liquidity lines, and an optional display of the raw swing pivot points.

A typical read: let the CHoCH and the OB/FVG zone form exactly as a conventional ICT trader would expect. Once a rejection candle prints and a "Liquidity Level" line appears, treat that line - not the zone - as the point of interest: the resting liquidity from everyone who just entered on the retest. Whether you plan a position through that level, tighten risk ahead of it, or simply use it as a warning that the "obvious" move may get run first, always combine it with your own higher-timeframe context, confirmation and risk management.

NOTES

This is an educational tool for visualizing where ICT-style retest liquidity is likely to build up, based on standard market structure, order blocks and FVGs. It does not constitute financial advice and does not guarantee any outcome. Like any structure-based tool, back-test it on the instrument and timeframe you intend to trade before using it live.

---

## Source Code

````pine
//@version=6
indicator("ICT Liquidity Hunter", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =========================================================================
// INPUTS
// =========================================================================
grpStruct = "Structure"
swingLen       = input.int(8, "Swing lookback (pivot)", minval=1, group=grpStruct, tooltip="Bars on each side used to confirm a swing high/low. Market structure (and therefore CHoCH) is confirmed with this delay.")
maxZoneAge     = input.int(50, "Expire zone after (bars)", minval=1, group=grpStruct, tooltip="If price does not return to the OB/FVG zone within this many bars since it was drawn, the zone is invalidated and removed.")
maxActiveZones = input.int(3, "Max. OB/FVG zones visible at once", minval=1, group=grpStruct, tooltip="Once this number is exceeded, the oldest zone is removed. Lower it for a cleaner chart.")
minSwingATRmult = input.float(1.0, "Min. swing size (x ATR14)", minval=0, step=0.1, group=grpStruct, tooltip="A new swing high/low only counts as real structure if it moved at least this many ATR14 away from the previous opposite swing. Raise it to ignore minor noise; 0 disables the filter.")

grpZones = "Order Block / FVG"
showOB        = input.bool(true, "Show Order Blocks", group=grpZones)
showFVG       = input.bool(true, "Show FVG", group=grpZones)
zoneLookback  = input.int(20, "Search OB/FVG up to X bars back from CHoCH", minval=3, group=grpZones)
minGapATRmult = input.float(0.0, "Minimum FVG filter (x ATR14)", minval=0, step=0.05, group=grpZones, tooltip="0 = no minimum size filter")
extendZones   = input.bool(true, "Extend active zones until mitigated", group=grpZones)

grpRej = "Rejection candle"
rejMultiplier = input.float(2.0, "Multiple of average range", minval=1.0, step=0.1, group=grpRej)
rejLookback   = input.int(20, "Average range period", minval=5, group=grpRej)
closeRatio    = input.float(0.66, "Minimum close within % of candle range", minval=0.5, maxval=1.0, step=0.01, group=grpRej)
onceReject    = input.bool(true, "Only 1 rejection per zone", group=grpRej)
maxLiqLines   = input.int(3, "Max. liquidity lines visible", minval=1, group=grpRej, tooltip="Once this number is exceeded, the oldest liquidity line is removed.")
maxLiqAge     = input.int(200, "Liquidity line max length (bars)", minval=1, group=grpRej, tooltip="A liquidity line is deleted once it has extended this many bars to the right without being replaced.")

grpStyle = "Style"
showSwings = input.bool(false, "Show swing points", group=grpStyle)
colBullOB  = input.color(color.new(color.teal, 80),   "Bullish OB color",  group=grpStyle)
colBearOB  = input.color(color.new(color.red, 80),    "Bearish OB color",  group=grpStyle)
colBullFVG = input.color(color.new(color.blue, 85),   "Bullish FVG color", group=grpStyle)
colBearFVG = input.color(color.new(color.orange, 85), "Bearish FVG color", group=grpStyle)
colLiqBuy  = input.color(color.lime, "Liquidity color (bullish rejection)", group=grpStyle)
colLiqSell = input.color(color.red,  "Liquidity color (bearish rejection)", group=grpStyle)

// =========================================================================
// DATA TYPES
// =========================================================================
type Zone
    float top
    float bottom
    int   dir          // 1 = bullish (support, below) / -1 = bearish (resistance, above)
    box   b
    bool  rejected
    int   createdBar
    int   lastTouchBar // bar_index of the most recent bar that touched this zone (na if none yet)

var Zone[] zones = array.new<Zone>()

type LiqMark
    line  l
    label lbl
    int   createdBar

var LiqMark[] liqMarks = array.new<LiqMark>()

f_pushLiq(l, lbl) =>
    array.push(liqMarks, LiqMark.new(l, lbl, bar_index))
    if array.size(liqMarks) > maxLiqLines
        old = array.shift(liqMarks)
        line.delete(old.l)
        label.delete(old.lbl)

// delete liquidity lines that have extended more than maxLiqAge bars to the
// right; otherwise keep their label riding the line's right edge so it
// travels forward with it instead of staying pinned to the rejection candle
f_expireLiq() =>
    if array.size(liqMarks) > 0
        for i = array.size(liqMarks) - 1 to 0
            m = array.get(liqMarks, i)
            if (bar_index - m.createdBar) > maxLiqAge
                line.delete(m.l)
                label.delete(m.lbl)
                array.remove(liqMarks, i)
            else
                label.set_x(m.lbl, bar_index)
    true

// =========================================================================
// MARKET STRUCTURE / CHoCH
// =========================================================================
ph = ta.pivothigh(swingLen, swingLen)
pl = ta.pivotlow(swingLen, swingLen)
atr14 = ta.atr(14)

// Alternating (zigzag-style) swing structure: a new pivot only becomes the
// active swing point if it alternates with the previously confirmed one
// (high -> low -> high -> low ...), AND it moved far enough (in ATR) from
// that previous opposite swing to count as real structure rather than
// internal noise. Consecutive pivots on the same side just replace the
// reference with the more extreme value.
//
// The CHoCH itself is checked live, every bar: it is simply the first time
// price closes back through the currently active opposite swing level
// since the trend last flipped. This live check (rather than retroactively
// matching a multi-swing pattern) is what a streaming indicator needs -
// waiting to "resolve" a pattern first inevitably means checking for the
// break only after price has already moved past the level, which fires on
// an unrelated, much later, essentially random crossing instead.
var float lastSwingHigh = na
var float lastSwingLow  = na
var int   lastPivotDir  = 0   // 1 = last confirmed swing was a high, -1 = a low

if not na(ph)
    bigEnoughH = na(lastSwingLow) or na(atr14) or minSwingATRmult <= 0 or math.abs(ph - lastSwingLow) >= atr14 * minSwingATRmult
    if lastPivotDir <= 0
        if na(lastSwingHigh) or bigEnoughH
            lastSwingHigh := ph
            lastPivotDir := 1
    else
        lastSwingHigh := math.max(lastSwingHigh, ph)

if not na(pl)
    bigEnoughL = na(lastSwingHigh) or na(atr14) or minSwingATRmult <= 0 or math.abs(pl - lastSwingHigh) >= atr14 * minSwingATRmult
    if lastPivotDir >= 0
        if na(lastSwingLow) or bigEnoughL
            lastSwingLow := pl
            lastPivotDir := -1
    else
        lastSwingLow := math.min(lastSwingLow, pl)

var int trend = 0   // 1 bullish, -1 bearish, 0 undefined

bool chochUp = false
bool chochDn = false

// first bullish break of the active swing high while trend was not already bullish
if not na(lastSwingHigh) and ta.crossover(close, lastSwingHigh) and trend <= 0
    chochUp := true
    trend := 1

// first bearish break of the active swing low while trend was not already bearish
if not na(lastSwingLow) and ta.crossunder(close, lastSwingLow) and trend >= 0
    chochDn := true
    trend := -1

plotshape(showSwings ? ph : na, title="Swing High", style=shape.triangledown, location=location.abovebar, color=color.gray, size=size.tiny, offset=-swingLen)
plotshape(showSwings ? pl : na, title="Swing Low",  style=shape.triangleup,   location=location.belowbar, color=color.gray, size=size.tiny, offset=-swingLen)

if chochUp
    label.new(bar_index, low, "CHoCH▲", style=label.style_label_up, color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny)
if chochDn
    label.new(bar_index, high, "CHoCH▼", style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)

// =========================================================================
// FUNCTIONS: FIND OB / FVG, CREATE ZONE, CLEAR ZONES
// =========================================================================
f_findOB(bullish, maxLookback) =>
    float obHigh = na
    float obLow  = na
    int   obOff  = na
    if bullish
        for i = 1 to maxLookback
            if close[i] < open[i]   // last bearish candle before the bullish impulse
                obHigh := high[i]
                obLow  := low[i]
                obOff  := i
                break
    else
        for i = 1 to maxLookback
            if close[i] > open[i]   // last bullish candle before the bearish impulse
                obHigh := high[i]
                obLow  := low[i]
                obOff  := i
                break
    [obHigh, obLow, obOff]

f_findFVG(bullish, maxLookback) =>
    float top    = na
    float bottom = na
    int   offL   = na
    if bullish
        for i = 1 to maxLookback
            if low[i] > high[i + 2]
                top    := low[i]
                bottom := high[i + 2]
                offL   := i + 2
                break
    else
        for i = 1 to maxLookback
            if high[i] < low[i + 2]
                top    := low[i + 2]
                bottom := high[i]
                offL   := i + 2
                break
    [top, bottom, offL]

f_pushZone(top, bottom, dir, boxRef) =>
    array.push(zones, Zone.new(top, bottom, dir, boxRef, false, bar_index, na))
    if array.size(zones) > maxActiveZones
        old = array.shift(zones)
        box.delete(old.b)

f_clearZones() =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            z = array.get(zones, i)
            box.delete(z.b)
        array.clear(zones)

// =========================================================================
// 1) FIRST: check rejection/mitigation on the zones that ALREADY EXIST
//    (created by the previous CHoCH). This runs BEFORE anything related to
//    this bar's own CHoCH, so a zone can never be "rejected" on the same
//    bar it is created — only on a future bar, once price truly returns.
// =========================================================================
rng      = high - low
avgRange = ta.sma(high - low, rejLookback)

f_expireLiq()

var bool liqBullSignal = false
var bool liqBearSignal = false
liqBullSignal := false
liqBearSignal := false

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        zone = array.get(zones, i)

        if extendZones
            box.set_right(zone.b, bar_index)

        touched = low <= zone.top and high >= zone.bottom
        if touched
            zone.lastTouchBar := bar_index

        // the rejection candle can be the one that touches the zone, or the
        // very next bar after a touch - not strictly only the touching bar
        recentTouch = touched or (not na(zone.lastTouchBar) and (bar_index - zone.lastTouchBar) == 1)

        bigCandle = rng >= avgRange * rejMultiplier
        canReject = recentTouch and bigCandle and (not onceReject or not zone.rejected)

        // SUPPORT zone (below, dir=1): rejection = strong bullish candle
        if canReject and zone.dir == 1 and close > open and rng > 0 and (close - low) / rng >= closeRatio
            lnBuy  = line.new(bar_index - 1, low, bar_index, low, extend=extend.right, color=colLiqBuy, style=line.style_solid, width=2)
            lblBuy = label.new(bar_index, low, "Liquidity Level", style=label.style_label_up, color=color.new(colLiqBuy, 0), textcolor=color.black, size=size.tiny)
            f_pushLiq(lnBuy, lblBuy)
            zone.rejected := true
            liqBullSignal := true

        // RESISTANCE zone (above, dir=-1): rejection = strong bearish candle
        if canReject and zone.dir == -1 and close < open and rng > 0 and (high - close) / rng >= closeRatio
            lnSell  = line.new(bar_index - 1, high, bar_index, high, extend=extend.right, color=colLiqSell, style=line.style_solid, width=2)
            lblSell = label.new(bar_index, high, "Liquidity Level", style=label.style_label_down, color=color.new(colLiqSell, 0), textcolor=color.white, size=size.tiny)
            f_pushLiq(lnSell, lblSell)
            zone.rejected := true
            liqBearSignal := true

        mitigated = (zone.dir == 1 and close < zone.bottom) or (zone.dir == -1 and close > zone.top)
        expired   = (bar_index - zone.createdBar) > maxZoneAge

        if mitigated or expired
            box.delete(zone.b)
            array.remove(zones, i)

// =========================================================================
// 2) THEN: if this bar produces a new CHoCH, clear the remaining zones and
//    mark the OB/FVG zone on the correct side — ABOVE the breakout candle
//    if the CHoCH is bearish (price is expected to return and get rejected
//    downward there), BELOW it if the CHoCH is bullish. If no OB/FVG is
//    found within the lookback, nothing is drawn.
// =========================================================================
if chochUp or chochDn
    f_clearZones()

if chochUp
    if showOB
        [obH, obL, obOff] = f_findOB(true, zoneLookback)
        if not na(obH)
            b = box.new(left=bar_index[obOff], top=obH, right=bar_index, bottom=obL, border_color=color.teal, bgcolor=colBullOB, extend=extend.none, text="OB", text_color=color.white, text_size=size.tiny)
            f_pushZone(obH, obL, 1, b)
    if showFVG
        [fT, fB, fOff] = f_findFVG(true, zoneLookback)
        if not na(fT) and (minGapATRmult <= 0 or (fT - fB) >= atr14 * minGapATRmult)
            b2 = box.new(left=bar_index[fOff], top=fT, right=bar_index, bottom=fB, border_color=color.blue, bgcolor=colBullFVG, extend=extend.none, text="FVG", text_color=color.white, text_size=size.tiny)
            f_pushZone(fT, fB, 1, b2)

if chochDn
    if showOB
        [obH, obL, obOff] = f_findOB(false, zoneLookback)
        if not na(obH)
            b = box.new(left=bar_index[obOff], top=obH, right=bar_index, bottom=obL, border_color=color.red, bgcolor=colBearOB, extend=extend.none, text="OB", text_color=color.white, text_size=size.tiny)
            f_pushZone(obH, obL, -1, b)
    if showFVG
        [fT, fB, fOff] = f_findFVG(false, zoneLookback)
        if not na(fT) and (minGapATRmult <= 0 or (fT - fB) >= atr14 * minGapATRmult)
            b2 = box.new(left=bar_index[fOff], top=fT, right=bar_index, bottom=fB, border_color=color.orange, bgcolor=colBearFVG, extend=extend.none, text="FVG", text_color=color.white, text_size=size.tiny)
            f_pushZone(fT, fB, -1, b2)

// =========================================================================
// ALERTS
// =========================================================================
alertcondition(liqBullSignal, title="Bullish rejection -> liquidity marked", message="Rejection candle at bullish OB/FVG zone (below). Liquidity marked at the low.")
alertcondition(liqBearSignal, title="Bearish rejection -> liquidity marked", message="Rejection candle at bearish OB/FVG zone (above). Liquidity marked at the high.")
````
