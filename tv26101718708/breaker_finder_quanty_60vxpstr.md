# Breaker Finder [Quanty]

- url: https://www.tradingview.com/script/60VxpSTR-Breaker-Finder-Quanty/
- type: indicator
- pine_id: PUB;4d88e59590c74225a80adea753d46043
- version: 1.0

## Description

Breaker blocks drawn from confirmed swings, with a table that tests the first return to each zone against chance on the chart you are viewing.

[b]HOW IT WORKS[/b]

A breaker is a level that failed and flipped. The script finds it in three steps:

1. Sweep. Price trades beyond a liquidity swing: a swing low (or high) with 10 bars on each side, the kind of level many traders can see. The extreme of that run is marked with a small x.

2. Shift. A candle then closes beyond the last structure swing (3 bars on each side) on the other side of the run: the last swing high after a sweep below, the last swing low after a sweep above. This is the market structure shift (MSS), drawn as a dotted line from the swing to the closing candle. That candle has to show displacement: it leaves a fair value gap or has a body of at least 1 ATR (14 bars) in the direction of the shift. A shift without displacement is ignored and the script waits for the next sweep.

3. Breaker. The body of the last candle at the broken swing that closed in the new direction, before the run into the sweep (an up candle for a shift up, a down candle for a shift down), becomes the breaker zone. Its midpoint, the mean threshold, is drawn as a dashed line. Teal zones sit below price after a shift up; violet zones sit above price after a shift down.

A zone stays live and extends to the right until a candle closes through its far side. Then it is broken and removed from the chart (or kept as a faint dotted box, if you switch that on). The first time price comes back into a live zone, a circle marks the touch. That return is the moment the Stats table measures.

Swings are confirmed a fixed number of bars after they form, so nothing is drawn in hindsight and everything is read on closed candles. Raise the liquidity swing to see fewer, larger breakers; lower it to see more. The structure swing, the displacement filter and the number of zones kept on the chart are also settings, and the Stats table counts every zone, not only the ones on screen. The script works on any timeframe and any symbol.

[b]HOW TO READ THE STATS TABLE[/b]

The table in the corner takes the last 50 returns to a breaker zone on the chart you are viewing (the number after the slash) and counts in how many of them price moved at least 1 ATR (14 bars) in the expected direction within the next 10 bars: up from a teal zone, down from a violet zone. It is a measurement of history on this symbol and timeframe, not a prediction and not a promise. Change the symbol or the timeframe and the numbers change with it. Past results do not guarantee future results.

The next row tests the same returns in the opposite direction: if both directions score about the same, the zone marked a volatile moment, not a direction. The row after that runs the same test on every one of the last 500 bars in a random direction, so you can see what a coin toss would have scored here. Two more rows split the count by volume. When one side has only a handful of returns, read it as a handful, not as a rate. The threshold can be set in ATR or in percent, and the number of bars ahead is a setting. The table can be collapsed to one line, and its colours follow your chart theme.

Breaks of structure and liquidity sweeps did not beat a coin toss in our own earlier tests. Check breakers on your own symbol and timeframe before you trust them.

Alerts: price returns to a live breaker zone below, and to a live breaker zone above.

Written from the concept; no code from other scripts is used.

[b]Not investment advice.[/b]

## Source Code

````pine
//@version=6
// Breaker Finder, Tested [Quanty] - v0.2 - written by Dreamer for Ata
//
// Finds breaker blocks and tests them against chance on your own chart.
//   1. Sweep: price trades beyond a liquidity swing, a swing low (or high) with 10 bars on each side.
//   2. Shift: a candle then closes beyond the last structure swing (3 bars on each side) on the
//      other side of the run, with displacement on that candle: a fair value gap or a body of at
//      least 1 ATR in its direction (market structure shift, MSS).
//   3. Breaker: the body of the last candle at the broken swing that closed in the new direction
//      (an up candle for a shift up) becomes the zone. Its midpoint (the mean threshold) is a dashed line.
// A zone stays live until a candle closes through its far side. The first return of price into
// a live zone is marked with a circle; those returns are what the Stats table measures.
// Everything is read on closed candles. History, not a forecast. Not investment advice.
// Written from the concept; no code from other scripts is used.
indicator("Breaker Finder, Tested [Quanty]", shorttitle="Quanty Breaker", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
const string G_B = "1. Breakers"
const string G_A = "2. Appearance"
int   pkl     = input.int(10, "Liquidity swing (bars each side)", minval=2, maxval=30, group=G_B,
     tooltip="The swing that has to be swept. Higher = only sweeps of more obvious highs and lows, fewer breakers.")
int   pk      = input.int(3, "Structure swing (bars each side)", minval=1, maxval=10, group=G_B,
     tooltip="The swing whose break is the shift. A swing is confirmed this many bars after it forms.")
bool  needD   = input.bool(true, "Require displacement on the shift candle", group=G_B,
     tooltip="The candle that closes beyond the swing must leave a fair value gap or have a body of at least 1 ATR (14).")
int   keep    = input.int(4, "Zones kept on chart (each side)", minval=1, maxval=40, group=G_A)
bool  showBrk = input.bool(false, "Keep broken zones on chart", group=G_A)
bool  showMss = input.bool(true, "Show MSS lines", group=G_A)
bool  showSw  = input.bool(true, "Show sweep marks", group=G_A)
color cUp     = input.color(#0FA88A, "Zone below price (expected up)", group=G_A)
color cDn     = input.color(#8C7BD6, "Zone above price (expected down)", group=G_A)
color cSw     = input.color(#E6EDF3, "Sweep mark", group=G_A)

// ---------------------------------------------------------------------------
// Swings: structure (pk) and liquidity (pkl)
// ---------------------------------------------------------------------------
float hiWin  = ta.highest(high, 2 * pk + 1)
float loWin  = ta.lowest(low, 2 * pk + 1)
float hiWinL = ta.highest(high, 2 * pkl + 1)
float loWinL = ta.lowest(low, 2 * pkl + 1)
float atr14  = ta.atr(14)
var float lastPH  = na
var int   lastPHb = na
var float lastPL  = na
var int   lastPLb = na
var float liqPH   = na
var int   liqPHb  = na
var float liqPL   = na
var int   liqPLb  = na

// ---------------------------------------------------------------------------
// Zones
// ---------------------------------------------------------------------------
type Zone
    int   d
    float top
    float bot
    bool  act
    bool  ret
    box   bx
    line  mid
    line  mss
    label mssL
    label sw
    label rH
    label rD
    bool  drawn

const int ZMAX = 100   // zones tracked per side for the returns; "Zones kept on chart" only limits drawings

var array<Zone> zUp = array.new<Zone>()
var array<Zone> zDn = array.new<Zone>()

dropZone(Zone z) =>
    z.drawn := false
    box.delete(z.bx)
    line.delete(z.mid)
    line.delete(z.mss)
    label.delete(z.mssL)
    label.delete(z.sw)
    label.delete(z.rH)
    label.delete(z.rD)

newZone(int d, float lvl, int lvlB, float ext, int extB, int bk, float top, float bot) =>
    color col = d == 1 ? cUp : cDn
    box   bx  = box.new(bk, top, bar_index, bot, border_color=col, border_width=1, bgcolor=color.new(col, 70),
         text="Breaker", text_size=size.small, text_color=col, text_halign=text.align_right, text_valign=text.align_center)
    line  md  = line.new(bk, (top + bot) / 2, bar_index, (top + bot) / 2, color=col, style=line.style_dashed, width=1)
    line  ms  = showMss ? line.new(lvlB, lvl, bar_index, lvl, color=col, style=line.style_dotted, width=2) : na
    label ml  = showMss ? label.new(math.round((lvlB + bar_index) / 2), lvl, "MSS", style=d == 1 ? label.style_label_down : label.style_label_up,
         color=color.new(col, 100), textcolor=col, size=size.small) : na
    label sl  = showSw ? label.new(extB, ext, "", style=label.style_xcross, color=cSw, size=size.tiny) : na
    Zone.new(d, top, bot, true, false, bx, md, ms, ml, sl, na, na, true)

markReturn(Zone z, float p) =>
    color col = z.d == 1 ? cUp : cDn
    if z.drawn
        z.rH := label.new(bar_index, p, "", style=label.style_circle, color=color.new(col, 75), size=size.small)
        z.rD := label.new(bar_index, p, "", style=label.style_circle, color=col, size=size.tiny)

breakZone(Zone z) =>
    color col = z.d == 1 ? cUp : cDn
    z.act := false
    if z.drawn
        if showBrk
            box.set_right(z.bx, bar_index)
            box.set_bgcolor(z.bx, color.new(col, 90))
            box.set_border_color(z.bx, color.new(col, 50))
            box.set_border_style(z.bx, line.style_dotted)
            box.set_text(z.bx, "")
            line.delete(z.mid)
        else
            dropZone(z)

// d = 1: sweep below a liquidity swing low, shift up. d = -1: sweep above a liquidity swing high, shift down.
var int   uSt   = 0
var int   uUsed = na
var float uExt  = na
var int   uExtB = na
var float uLvl  = na
var int   uLvlB = na
var int   dSt   = 0
var int   dUsed = na
var float dExt  = na
var int   dExtB = na
var float dLvl  = na
var int   dLvlB = na

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
    if not na(hiWinL) and high[pkl] == hiWinL
        liqPH  := high[pkl]
        liqPHb := bar_index - pkl
    if not na(loWinL) and low[pkl] == loWinL
        liqPL  := low[pkl]
        liqPLb := bar_index - pkl

    // live zones first: a close through the far side breaks the zone, the first touch is the return
    for z in zUp
        if z.act
            if close < z.bot
                breakZone(z)
            else
                if z.drawn
                    box.set_right(z.bx, bar_index)
                    line.set_x2(z.mid, bar_index)
                if not z.ret and low <= z.top
                    z.ret := true
                    markReturn(z, z.top)
                    sigUp := true
    for z in zDn
        if z.act
            if close > z.top
                breakZone(z)
            else
                if z.drawn
                    box.set_right(z.bx, bar_index)
                    line.set_x2(z.mid, bar_index)
                if not z.ret and high >= z.bot
                    z.ret := true
                    markReturn(z, z.bot)
                    sigDn := true

    // setup after a sweep below a liquidity swing low
    if not na(liqPL) and (na(uUsed) or liqPLb != uUsed) and low < liqPL
        uSt   := 1
        uUsed := liqPLb
        uExt  := low
        uExtB := bar_index
        uLvl  := lastPH
        uLvlB := lastPHb
    else if uSt == 1 and low < uExt
        uExt  := low
        uExtB := bar_index
        uLvl  := lastPH
        uLvlB := lastPHb
    else if uSt == 1 and not na(lastPHb) and not na(uLvlB) and lastPHb > uLvlB and lastPHb <= uExtB
        uLvl  := lastPH
        uLvlB := lastPHb
    if uSt == 1 and not na(uLvl) and close > uLvl
        bool disp = (not na(atr14) and close - open >= atr14) or low > high[2]
        if disp or not needD
            int bk = na
            for q = 0 to 5
                int b = uLvlB - q
                int off = bar_index - b
                if na(bk) and off >= 0 and off <= 450
                    if close[off] > open[off]
                        bk := b
            if na(bk) and bar_index - uLvlB <= 450
                bk := uLvlB
            if not na(bk)
                int bo = bar_index - bk
                zUp.push(newZone(1, uLvl, uLvlB, uExt, uExtB, bk, math.max(open[bo], close[bo]), math.min(open[bo], close[bo])))
                if zUp.size() > keep
                    dropZone(zUp.get(zUp.size() - keep - 1))
                if zUp.size() > ZMAX
                    dropZone(zUp.shift())
        uSt := 0

    // setup after a sweep above a liquidity swing high
    if not na(liqPH) and (na(dUsed) or liqPHb != dUsed) and high > liqPH
        dSt   := 1
        dUsed := liqPHb
        dExt  := high
        dExtB := bar_index
        dLvl  := lastPL
        dLvlB := lastPLb
    else if dSt == 1 and high > dExt
        dExt  := high
        dExtB := bar_index
        dLvl  := lastPL
        dLvlB := lastPLb
    else if dSt == 1 and not na(lastPLb) and not na(dLvlB) and lastPLb > dLvlB and lastPLb <= dExtB
        dLvl  := lastPL
        dLvlB := lastPLb
    if dSt == 1 and not na(dLvl) and close < dLvl
        bool disp = (not na(atr14) and open - close >= atr14) or high < low[2]
        if disp or not needD
            int bk = na
            for q = 0 to 5
                int b = dLvlB - q
                int off = bar_index - b
                if na(bk) and off >= 0 and off <= 450
                    if close[off] < open[off]
                        bk := b
            if na(bk) and bar_index - dLvlB <= 450
                bk := dLvlB
            if not na(bk)
                int bo = bar_index - bk
                zDn.push(newZone(-1, dLvl, dLvlB, dExt, dExtB, bk, math.max(open[bo], close[bo]), math.min(open[bo], close[bo])))
                if zDn.size() > keep
                    dropZone(zDn.get(zDn.size() - keep - 1))
                if zDn.size() > ZMAX
                    dropZone(zDn.shift())
        dSt := 0

alertcondition(sigUp, "Breaker: return to a zone below", "Breaker: price returned to a breaker zone below on {{ticker}} {{interval}}")
alertcondition(sigDn, "Breaker: return to a zone above", "Breaker: price returned to a breaker zone above on {{ticker}} {{interval}}")

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
