# Order Block Finder, Tested [Quanty]

- url: https://www.tradingview.com/script/wxxBqWid-Order-Block-Finder-Tested-Quanty/
- type: indicator
- pine_id: PUB;725e831a1a1046138e877fb77ff889ae
- version: 1.0

## Description

Order blocks drawn as plain boxes, teal support below price and violet resistance above it: watch the first return to a box, and let the table show whether such returns have held on your chart.

Order Block Finder marks the candle where a strong move started, as one simple box. A small dot marks the first time price comes back to a box. In the corner, a table tests those returns against chance.

[b]HOW IT WORKS[/b]

The rules for a box below price (support); a box above price (resistance) is the mirror image.

1. Swing high. A high that is the highest of the 7 candles around it (3 on each side; a setting). It is confirmed 3 candles later.
2. Break of structure. A candle closes above the last confirmed swing high, at most 450 candles after it. Each swing high is used once: if the first close above it is not strong, that swing makes no box. The breaking candle must be strong: a body of at least 1 ATR (14), or a fair value gap (its low above the high of two candles earlier). The strength filter can be switched off.
3. Order block. The move started at the lowest low between that swing high and the breaking candle (the first one, if two lows are equal). The box is the full range (high to low, wicks included) of the last down candle among the 6 candles ending at that low.
4. A new box that overlaps a live box on the same side is not drawn.
5. A box ends, and disappears, when a candle closes below its bottom. A resistance box ends when a candle closes above its top.
6. The first time a candle's low reaches the top of a support box (or its high reaches the bottom of a resistance box), a dot marks it. After that touch the box extends for 50 more bars and then stops, so old boxes do not stretch across the chart.

A box appears on the close of the candle that breaks structure. It is drawn back to the candle it comes from, but it never appears before that close. Everything is read on closed candles. The 3 newest live boxes per side are shown (a setting); the Stats table counts every box, up to 100 per side, not only the ones on screen.

[b]VOLUME SHADING[/b]

Each box is cut into 10 horizontal bands. A band is darker where more volume traded, from 20 candles before the order block candle to the candle that broke structure, with each candle's volume spread evenly over its high-low range. The darkest band is where most of the trading in that move happened. This is drawing only: it does not change the boxes, the dots or the Stats table, and the shading itself has not been tested against chance. It can be switched off.

[b]WHAT WE FOUND[/b]

We tested the first return to a box offline on crypto perpetual futures, on 1-hour and 4-hour charts over the last year and on 4-hour charts from 2021 to 2025, against a random candle on the same coin and against all coins at the same hour. The test was written down before it was run. We ran it twice, for two box shapes: the candle body and the full candle with its wicks (this version draws the full candle). Both gave the same answer. Price did not move away from the box first (up from support, down from resistance) more often than chance. On 1-hour charts over the last year it did so slightly less often; the 2021 to 2025 data did not confirm it. The size of the move after a touch was what the coin's own volatility predicted. Breaks of structure also did not beat a coin toss in our earlier tests. Treat a box as a place to watch, not as a level that holds, and check it on your own symbol and timeframe.

[b]HOW TO READ THE STATS TABLE[/b]

The table in the corner takes the last 50 first returns to a box on the chart you are viewing (the number after the slash) and counts in how many of them price moved at least 1 ATR (14 bars) away from the box within the next 10 bars: up from support, down from resistance. A candle that touches boxes on both sides is not counted. It is a measurement of history on this symbol and timeframe, not a prediction and not a promise. Change the symbol or the timeframe and the numbers change with it. Past results do not guarantee future results.

The next row tests the same returns in the opposite direction: if both directions score about the same, the box marked a volatile moment, not a direction. The row after that runs the same test on every one of the last 500 bars in a random direction, so you can see what a coin toss would have scored here. Two more rows split the count by volume: returns whose candle volume was at least 2 times the average of the previous 50 bars, and the rest. When one side has only a handful of returns, read it as a handful, not as a rate. Returns that are too recent to be measured are not counted. The threshold can be set in ATR or in percent, and the number of bars ahead is a setting. The table can be collapsed to one line, and its colours follow your chart theme.

Alerts: "Order block: touch of a box below" and "Order block: touch of a box above", both on the close of the candle.

Written from the concept; no code from other scripts is used.
[b]
Not investment advice.
[/b]

## Source Code

````pine
//@version=6
// Order Block Finder, Tested [Quanty] - v0.6 - volume shading inside the box; v0.5 default price scale; v0.4 full-candle box; v0.2 compile fix
//
// Draws order blocks as plain boxes: the last opposite candle before a strong move that broke
// structure. Teal boxes sit below price (support), violet boxes above it (resistance). A box
// disappears when a candle closes through its far side. The first time price comes back to a
// box, a small dot marks it; those touches are what the Stats table measures. After that touch
// the box extends for 50 more bars (a setting) and then stops.
//
// Rules (from the concept; no code from other scripts):
//   - Swings need a set number of bars on each side (3 by default) and are confirmed that many
//     bars later.
//   - A strong candle (a body of at least 1 ATR, or a fair value gap) closes above the last swing
//     high: the move broke structure upward. The move started at the lowest low between that
//     swing high and the breaking candle. The order block is the full range (wicks included) of the last down candle
//     among the 6 candles ending at that low. The other side is the mirror image.
//   - A new box that overlaps a live box on the same side is not drawn. At most 3 live boxes per
//     side are shown; the Stats table counts every box, not only the ones on screen.
// Everything is read on closed candles. History, not a forecast. Not investment advice.
indicator("Order Block Finder, Tested [Quanty]", shorttitle="Quanty OB", overlay=true,
     max_boxes_count=500, max_labels_count=500, max_bars_back=500)

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
const string G_B = "1. Order blocks"
const string G_A = "2. Appearance"
int   pk    = input.int(3, "Swing strength (bars each side)", minval=1, maxval=10, group=G_B)
bool  needD = input.bool(true, "Require a strong breaking candle (1 ATR body or FVG)", group=G_B)
int   keep  = input.int(3, "Boxes shown per side", minval=1, maxval=20, group=G_A)
int   ext   = input.int(50, "Box length after the first touch (bars)", minval=1, maxval=500, group=G_A,
     tooltip="After price first comes back to a box, the box keeps extending for this many bars and then stops, so old boxes do not stretch across the whole chart. Drawing only: the Stats table is not affected.")
color cUp   = input.color(#0FA88A, "Box below price (support)", group=G_A, inline="c")
color cDn   = input.color(#8C7BD6, "Box above price (resistance)", group=G_A, inline="c")
bool  shade = input.bool(true, "Shade each box by the volume traded at each price", group=G_A,
     tooltip="The box is cut into 10 bands. A band is darker where more volume traded, from 20 bars before the order block candle to the candle that broke structure. Each candle's volume is spread evenly over its high-low range. Drawing only: the Stats table is not affected, and the shading itself has not been tested against chance.")
const int NS = 10      // volume bands per box

const int ZMAX = 100   // boxes tracked per side for the Stats table; "Boxes shown" only limits drawings

// ---------------------------------------------------------------------------
// Swings
// ---------------------------------------------------------------------------
float hiWin = ta.highest(high, 2 * pk + 1)
float loWin = ta.lowest(low, 2 * pk + 1)
float atr14 = ta.atr(14)
var float lastPH  = na
var int   lastPHb = na
var float lastPL  = na
var int   lastPLb = na
var int   usedH   = na
var int   usedL   = na

// ---------------------------------------------------------------------------
// Boxes
// ---------------------------------------------------------------------------
type Zone
    int   d
    float top
    float bot
    int   b0
    bool  act
    bool  ret
    int   retB
    float retP
    box   bx
    label rH
    label rD
    bool  drawn
    array<box>   sl     // volume bands
    array<float> pv     // volume per band, bottom to top

var array<Zone> zUp = array.new<Zone>()
var array<Zone> zDn = array.new<Zone>()

undraw(Zone z) =>
    z.drawn := false
    box.delete(z.bx)
    for b in z.sl
        box.delete(b)
    z.sl.clear()
    label.delete(z.rH)
    label.delete(z.rD)
    true

drawMark(Zone z) =>
    color col = z.d == 1 ? cUp : cDn
    z.rH := label.new(z.retB, z.retP, "", style=label.style_circle, color=color.new(col, 75), size=size.small)
    z.rD := label.new(z.retB, z.retP, "", style=label.style_circle, color=col, size=size.tiny)
    true

// right edge: the current bar, or at most `ext` bars after the first touch
rightEdge(Zone z) =>
    z.ret ? math.min(bar_index, z.retB + ext) : bar_index

// volume profile of the formation: from 20 bars before the order block candle to the breaking candle,
// each candle's volume spread evenly over its high-low range, counted in NS equal bands of the box
profile(float top, float bot, int b0) =>
    array<float> pv = array.new<float>(NS, 0.0)
    float hgt = (top - bot) / NS
    int   frm = math.min(bar_index - (b0 - 20), 470)
    if hgt > 0
        for off = frm to 0
            if bar_index - off >= 0
                float hi  = high[off]
                float lo  = low[off]
                float v   = nz(volume[off])
                float rng = hi - lo
                if v > 0 and hi >= bot and lo <= top
                    for k = 0 to NS - 1
                        float sb = bot + k * hgt
                        float st = sb + hgt
                        if rng > 0
                            float ov = math.min(hi, st) - math.max(lo, sb)
                            if ov > 0
                                pv.set(k, pv.get(k) + v * ov / rng)
                        else if lo >= sb and lo <= st
                            pv.set(k, pv.get(k) + v)
    pv

draw(Zone z) =>
    color col = z.d == 1 ? cUp : cDn
    int   r   = rightEdge(z)
    if shade
        float mx  = z.pv.max()
        float hgt = (z.top - z.bot) / NS
        for k = 0 to NS - 1
            float w  = mx > 0 ? z.pv.get(k) / mx : 0.0
            int   tr = int(math.round(92 - 52 * w))
            z.sl.push(box.new(z.b0, z.bot + (k + 1) * hgt, r, z.bot + k * hgt, border_color=color.new(col, 100), border_width=0, bgcolor=color.new(col, tr)))
    z.bx := box.new(z.b0, z.top, r, z.bot, border_color=col, border_width=1, bgcolor=shade ? color.new(col, 100) : color.new(col, 72),
         text="OB", text_size=size.small, text_color=col, text_halign=text.align_right, text_valign=text.align_center)
    z.drawn := true
    if z.ret
        drawMark(z)
    true

setRight(Zone z) =>
    int r = rightEdge(z)
    box.set_right(z.bx, r)
    for b in z.sl
        box.set_right(b, r)
    true

overlaps(array<Zone> zs, float top, float bot) =>
    bool hit = false
    for z in zs
        if z.act and z.bot <= top and bot <= z.top
            hit := true
    hit

// keep only the newest `keep` live boxes drawn on one side
showNewest(array<Zone> zs) =>
    int live = 0
    int n = zs.size()
    if n > 0
        for i = n - 1 to 0
            Zone z = zs.get(i)
            if z.act
                live += 1
                if live <= keep and not z.drawn
                    draw(z)
                else if live > keep and z.drawn
                    undraw(z)

bool sigUp = false
bool sigDn = false

if barstate.isconfirmed
    // swings
    if not na(hiWin) and high[pk] == hiWin
        lastPH  := high[pk]
        lastPHb := bar_index - pk
    if not na(loWin) and low[pk] == loWin
        lastPL  := low[pk]
        lastPLb := bar_index - pk

    // live boxes: a close through the far side ends the box; the first touch is the event
    for z in zUp
        if z.act
            if close < z.bot
                z.act := false
                undraw(z)
            else
                if z.drawn
                    setRight(z)
                if not z.ret and low <= z.top
                    z.ret  := true
                    z.retB := bar_index
                    z.retP := z.top
                    sigUp  := true
                    if z.drawn
                        drawMark(z)
    for z in zDn
        if z.act
            if close > z.top
                z.act := false
                undraw(z)
            else
                if z.drawn
                    setRight(z)
                if not z.ret and high >= z.bot
                    z.ret  := true
                    z.retB := bar_index
                    z.retP := z.bot
                    sigDn  := true
                    if z.drawn
                        drawMark(z)

    bool dispU = (not na(atr14) and close - open >= atr14) or low > high[2]
    bool dispD = (not na(atr14) and open - close >= atr14) or high < low[2]

    // structure broken upward: order block = last down candle at the low where the move started
    if not na(lastPH) and (na(usedH) or usedH != lastPHb) and close > lastPH and bar_index - lastPHb <= 450
        usedH := lastPHb
        if dispU or not needD
            int   span = bar_index - lastPHb
            float mn   = na
            int   k0   = na
            for q = span to 0
                if na(mn) or low[q] < mn
                    mn := low[q]
                    k0 := bar_index - q
            int bk = na
            for j = 0 to 5
                int b = k0 - j
                int off = bar_index - b
                if na(bk) and close[off] < open[off]
                    bk := b
            if not na(bk)
                int   bo = bar_index - bk
                float tp = high[bo]
                float bt = low[bo]
                if not overlaps(zUp, tp, bt)
                    zUp.push(Zone.new(1, tp, bt, bk, true, false, na, na, na, na, na, false, array.new<box>(), profile(tp, bt, bk)))
                    if zUp.size() > ZMAX
                        undraw(zUp.shift())

    // structure broken downward: order block = last up candle at the high where the move started
    if not na(lastPL) and (na(usedL) or usedL != lastPLb) and close < lastPL and bar_index - lastPLb <= 450
        usedL := lastPLb
        if dispD or not needD
            int   span = bar_index - lastPLb
            float mx   = na
            int   k0   = na
            for q = span to 0
                if na(mx) or high[q] > mx
                    mx := high[q]
                    k0 := bar_index - q
            int bk = na
            for j = 0 to 5
                int b = k0 - j
                int off = bar_index - b
                if na(bk) and close[off] > open[off]
                    bk := b
            if not na(bk)
                int   bo = bar_index - bk
                float tp = high[bo]
                float bt = low[bo]
                if not overlaps(zDn, tp, bt)
                    zDn.push(Zone.new(-1, tp, bt, bk, true, false, na, na, na, na, na, false, array.new<box>(), profile(tp, bt, bk)))
                    if zDn.size() > ZMAX
                        undraw(zDn.shift())

    showNewest(zUp)
    showNewest(zDn)

alertcondition(sigUp, "Order block: touch of a box below", "Order Block Finder: price touched an order block below on {{ticker}} {{interval}}")
alertcondition(sigDn, "Order block: touch of a box above", "Order Block Finder: price touched an order block above on {{ticker}} {{interval}}")

// ===========================================================================
// Signals handed to the stats block: the first touch of a live box. A box below
// price is read as support (measured up), a box above price as resistance
// (measured down). A candle that touches boxes on both sides is not counted.
// ===========================================================================
bool stBoth = sigUp and sigDn
sigUp := sigUp and not stBoth
sigDn := sigDn and not stBoth

// ===========================================================================
// Quanty Stats - paste from here to the end into the host script
// ===========================================================================
const string G_ST = "3. Quanty Stats"
bool  stOn     = input.bool(true, "Stats table", group=G_ST, inline="st",
     tooltip="Measures this script's own past signals on this chart. History, not a forecast.")
bool  stMini   = input.bool(false, "collapsed (one line)", group=G_ST, inline="st",
     tooltip="Collapsed shows one line: how many signals moved the threshold, the same count in the opposite direction, and any bar.")
int   stK      = input.int(10, "Bars ahead (K)", minval=1, maxval=200, group=G_ST)
float stX      = input.float(1.0, "Move threshold (X)", minval=0.05, maxval=50.0, step=0.05, group=G_ST, inline="x",
     tooltip="A signal counts as reached when price moves at least this much in the signal's direction within K bars. In ATR units the test means the same thing on a 15m memecoin chart and a daily BTC chart; in percent it does not.")
string stUnit  = input.string("ATR", "", options=["ATR", "%"], group=G_ST, inline="x")
int   stAtrLen = input.int(14, "ATR length for the threshold", minval=1, maxval=200, group=G_ST)
int   stN      = input.int(50, "Signals measured (last N)", minval=5, maxval=500, group=G_ST)
bool  stVolOn  = input.bool(true, "Split by volume confirmation", group=G_ST)
float stVolMin = input.float(2.0, "Volume confirmation (x baseline)", minval=1.0, maxval=50.0, step=0.5, group=G_ST)
int   stVolLen = input.int(50, "Volume baseline (bars)", minval=5, maxval=1000, group=G_ST,
     tooltip="Baseline is the average volume of the bars before the signal bar. The percentile column ranks the signal bar's volume against the same window.")
string stPos   = input.string("Bottom right", "Table position", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=G_ST)

// --- Relative volume module (also usable on its own by the host script) ---
// ratio: this bar's volume against the average of the previous stVolLen bars.
// pct:   the share of the previous stVolLen bars with volume at or below this one.
float stVolBase = ta.sma(volume[1], stVolLen)
float stVolRatio = not na(stVolBase) and stVolBase > 0 ? volume / stVolBase : na
float stVolPct   = ta.percentrank(volume, stVolLen)
bool  stVolOk    = not na(stVolRatio) and stVolRatio >= stVolMin

// --- Outcome of the signal that fired K bars ago (its K bars are now closed) ---
bool  stSigL = sigUp[stK]
bool  stSigS = sigDn[stK]
float stEntry = close[stK]
float stHi = ta.highest(high, stK)   // bars signal+1 .. signal+K
float stLo = ta.lowest(low, stK)
// Moves are kept in percent of the entry price; the threshold is converted to
// percent on the signal bar when it is given in ATR units.
float stAtrPct = ta.atr(stAtrLen) / close * 100.0
float stThr  = stUnit == "ATR" ? stX * stAtrPct[stK] : stX
float stPeak = stSigL ? (stHi / stEntry - 1.0) * 100.0 : stSigS ? (1.0 - stLo / stEntry) * 100.0 : na
float stEnd  = stSigL ? (close / stEntry - 1.0) * 100.0 : stSigS ? (1.0 - close / stEntry) * 100.0 : na
// The same signals, tested the other way: did price move the threshold AGAINST them?
float stAdv  = stSigL ? (1.0 - stLo / stEntry) * 100.0 : stSigS ? (stHi / stEntry - 1.0) * 100.0 : na
bool  stVolAtSig = stVolOk[stK]

// --- Baseline: the same test on every bar, in a random direction ---
// Gives the number a yardstick. On a volatile coin almost any bar moves 1% in
// 10 bars; the signal only says something if it beats this row.
int   stBaseLen = input.int(500, "Baseline window (bars)", minval=50, maxval=2000, group=G_ST,
     tooltip="Share of all recent bars after which price moved at least the threshold up, averaged with the share that moved at least the threshold down. What a coin toss would have scored.")
bool  stBaseUp = not na(stEntry) and stEntry > 0 and not na(stThr) and (stHi / stEntry - 1.0) * 100.0 >= stThr
bool  stBaseDn = not na(stEntry) and stEntry > 0 and not na(stThr) and (1.0 - stLo / stEntry) * 100.0 >= stThr
float stBase   = ta.sma((stBaseUp ? 0.5 : 0.0) + (stBaseDn ? 0.5 : 0.0), stBaseLen)

var array<float> stPeaks  = array.new<float>()
var array<float> stEnds   = array.new<float>()
var array<int>   stHits   = array.new<int>()
var array<int>   stVols   = array.new<int>()
var array<int>   stOpps   = array.new<int>()

if stOn and barstate.isconfirmed and (stSigL or stSigS) and not na(stEntry) and stEntry > 0 and not na(stPeak) and not na(stThr)
    stPeaks.push(stPeak)
    stEnds.push(stEnd)
    stHits.push(stPeak >= stThr ? 1 : 0)
    stVols.push(stVolAtSig ? 1 : 0)
    stOpps.push(not na(stAdv) and stAdv >= stThr ? 1 : 0)
    if stPeaks.size() > stN
        stPeaks.shift()
        stEnds.shift()
        stHits.shift()
        stVols.shift()
        stOpps.shift()

// Signals fired in the last K bars are still open: counted as pending, not measured.
int stPending = 0
for i = 0 to stK - 1
    if sigUp[i] or sigDn[i]
        stPending += 1

f_stFrac(int hits, int n) =>
    n == 0 ? "0/0" : str.tostring(hits) + "/" + str.tostring(n) + " (" + str.tostring(math.round(100.0 * hits / n)) + "%)"

f_stPct(float v) =>
    na(v) ? "-" : (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

f_stPos(string p) =>
    p == "Top left" ? position.top_left : p == "Bottom right" ? position.bottom_right : p == "Bottom left" ? position.bottom_left : position.top_right

var table stT = table.new(f_stPos(stPos), 2, 10, bgcolor=color.new(chart.bg_color, 0), frame_color=color.new(chart.fg_color, 85), frame_width=1, border_color=color.new(chart.fg_color, 92), border_width=1)
if stOn and barstate.islast
    int n = stHits.size()
    int hits = n > 0 ? int(stHits.sum()) : 0
    int opps = n > 0 ? int(stOpps.sum()) : 0
    int nV = 0
    int hV = 0
    if n > 0
        for i = 0 to n - 1
            if stVols.get(i) == 1
                nV += 1
                hV += stHits.get(i)
    string thr = (stUnit == "ATR" ? str.tostring(stX, "#.##") + " ATR" : str.tostring(stX, "#.##") + "%") + " within " + str.tostring(stK) + " bars"
    if stMini
        // collapsed: one line, the rest of the table is emptied
        string stOpp = n == 0 ? "-" : str.tostring(math.round(100.0 * opps / n)) + "%"
        table.cell(stT, 0, 0, "Quanty Stats", text_color=#65E1C6, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 0, f_stFrac(hits, n) + " moved " + thr + " | opposite " + stOpp + (na(stBase) ? "" : " | any bar " + str.tostring(math.round(100.0 * stBase)) + "%"), text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
        table.clear(stT, 0, 1, 1, 9)   // remove the other rows so the box shrinks to one line
    else
        table.cell(stT, 0, 0, "Quanty Stats", text_color=#65E1C6, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 0, "last " + str.tostring(stN) + " signals", text_color=color.new(chart.fg_color, 55), text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 1, "Signals measured", text_color=color.new(chart.fg_color, 40), text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 1, str.tostring(n) + (stPending > 0 ? " (" + str.tostring(stPending) + " pending)" : ""), text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 2, "Moved at least " + thr, text_color=color.new(chart.fg_color, 40), text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 2, f_stFrac(hits, n), text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 3, "Opposite direction, same signals", text_color=color.new(chart.fg_color, 40), text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 3, f_stFrac(opps, n), text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 4, "Any bar, same test (last " + str.tostring(stBaseLen) + ")", text_color=color.new(chart.fg_color, 40), text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 4, na(stBase) ? "-" : str.tostring(math.round(100.0 * stBase)) + "%", text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 5, "Median peak move", text_color=color.new(chart.fg_color, 40), text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 5, n > 0 ? f_stPct(stPeaks.median()) : "-", text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 6, "Median move at bar " + str.tostring(stK), text_color=color.new(chart.fg_color, 40), text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 6, n > 0 ? f_stPct(stEnds.median()) : "-", text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
        if stVolOn
            table.cell(stT, 0, 7, "With volume >= " + str.tostring(stVolMin, "#.#") + "x", text_color=color.new(chart.fg_color, 40), text_size=size.small, text_halign=text.align_left)
            table.cell(stT, 1, 7, f_stFrac(hV, nV), text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
            table.cell(stT, 0, 8, "Without", text_color=color.new(chart.fg_color, 40), text_size=size.small, text_halign=text.align_left)
            table.cell(stT, 1, 8, f_stFrac(hits - hV, n - nV), text_color=color.new(chart.fg_color, 10), text_size=size.small, text_halign=text.align_right)
        else
            table.cell(stT, 0, 7, "", text_size=size.tiny)
            table.cell(stT, 1, 7, "", text_size=size.tiny)
            table.cell(stT, 0, 8, "", text_size=size.tiny)
            table.cell(stT, 1, 8, "", text_size=size.tiny)
        table.cell(stT, 0, 9, "History on this chart, not a forecast", text_color=color.new(chart.fg_color, 55), text_size=size.tiny, text_halign=text.align_left)
        table.cell(stT, 1, 9, "", text_size=size.tiny)
````
