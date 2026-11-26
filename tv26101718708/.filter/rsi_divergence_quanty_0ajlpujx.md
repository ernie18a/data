# RSI Divergence [Quanty]

- url: https://www.tradingview.com/script/0aJLpUJX-RSI-Divergence-Quanty/
- type: indicator
- pine_id: PUB;6a42999605f84c0b92b69fa55e027847
- version: 1.0

## Description

Most divergence scripts draw the line back to the pivot and put the signal there, so in hindsight every divergence looks perfectly timed. In real time you only know about it a few bars later, once the pivot is confirmed. This script alerts on, and measures, each divergence from the bar where it actually becomes known, and its stats table tests that moment against chance.

[b]WHAT IT FINDS[/b]

Only the classic case. Price makes a lower low while RSI makes a higher low (upward), or price makes a higher high while RSI makes a lower high (downward). Hidden divergences are not searched.

[b]HOW IT IS CALCULATED[/b]

RSI (14 by default). The anchors are RSI's own troughs and peaks: a trough is confirmed once 5 bars have closed on each side of it. For each anchor, price is read from a small window around it (5 bars either side), because price often bottoms or tops a few bars before or after RSI.

A new trough is compared with the deepest trough of the last 60 bars, not only with the one just before it, so smaller wiggles between two lows do not hide a divergence. Peaks are compared with the highest peak in the same way.

Filters, all adjustable: the two RSI values must differ by at least 2 points; by default the first RSI low must be at or below 35 and the second still below 50 (upward), and the first RSI high at or above 65 with the second still above 50 (downward). When a later trough or peak diverges from the same anchor, the older line is replaced instead of fanning out.

[b]READING IT[/b]

A thin line joins the two RSI troughs or peaks, and a faint line joins the matching price lows or highs on the main chart. The RSI line shifts from grey near 30 to mint near 70; light bands mark 20 to 30 and 70 to 80.

[b]SETTINGS[/b]

Source, RSI length, pivot bars left and right, minimum and maximum bars between pivots, minimum RSI difference, the oversold and overbought filter and its levels. Appearance: the two divergence colours, the RSI line colours, and whether to draw on the price chart. Two alerts: upward divergence and downward divergence, both firing on the bar where the divergence becomes known.

[b]NOTES AND LIMITATIONS[/b]

A divergence is known only after its second pivot is confirmed, 5 bars later by default; the lines are drawn back to the pivots for reference, but nothing is triggered there. RSI and price pivots are read on closed bars, so lines and alerts do not repaint. A divergence describes momentum that is weaker than price; on its own it says nothing about what comes next, which is why the table is there. We tested this exact definition offline across more than 500 crypto perpetuals and will publish the full results separately once they are verified.

[b]HOW TO READ THE STATS TABLE[/b]

The table in the corner measures this indicator's own past signals on the chart you are viewing: how many signals fired (the number after the slash), and in how many of them price moved at least 1 ATR (14 bars) in the signal's direction within the next 10 bars. It is a measurement of history on this symbol and timeframe, not a prediction and not a promise. Change the symbol or the timeframe and the numbers change with it. Past results do not guarantee future results.

It opens collapsed to one line: the share that moved in the signal's direction, the share that moved the same distance the opposite way, and what any bar on the chart scored in a random direction (a coin toss). Untick "collapsed" in the settings to see the full table, including the median moves and a split by volume (signals whose candle volume was at least 2 times the average of the previous 50 bars, and the rest). When one side has only a handful of signals, read it as a handful, not as a rate. Pending signals are too recent to be measured and are not counted.

Here a signal is the closed bar on which a divergence becomes known: price at a lower low with RSI at a higher low (upward), or price at a higher high with RSI at a lower high (downward).

[b]Not investment advice.[/b]

## Source Code

````pine
//@version=6
// RSI Divergence [Quanty] - v0.13 - 2026-10-03 - publication copy (Dreamer for Ata; Engineer to sync source), awaiting first compile
// Stats block v0.3 (collapsed view included).
indicator("RSI Divergence [Quanty]", shorttitle="Quanty RSI DIV", overlay=false, max_lines_count=300)

// Finds the classic divergence (price makes a new low or high, RSI does not)
// and measures it from the bar on which it becomes known. A pivot is only confirmed once the bars to its
// right have closed, so every divergence is known some bars after its pivot.
// The marks, the alerts and the stats table all sit on that later bar; the
// line is drawn back to the pivots only to show where the divergence is.

// ===========================================================================
// Inputs
// ===========================================================================
const string G_RSI = "1. RSI and pivots"
const string G_LK  = "2. Appearance"

float  src       = input.source(close, "Source", group=G_RSI)
int    rsiLen    = input.int(14, "RSI length", minval=2, maxval=100, group=G_RSI)
int    lbL       = input.int(5, "Pivot bars left", minval=1, maxval=50, group=G_RSI)
int    lbR       = input.int(5, "Pivot bars right", minval=1, maxval=50, group=G_RSI,
     tooltip="An RSI peak or trough is confirmed only after this many bars have closed to its right. The divergence becomes known on that bar, not on the pivot. Price is read from the same window around the pivot.")
int    rangeMin  = input.int(5, "Bars between pivots: min", minval=1, maxval=200, group=G_RSI, inline="r")
int    rangeMax  = input.int(60, "max", minval=2, maxval=500, group=G_RSI, inline="r")
float  minDiff   = input.float(2.0, "Min RSI difference", minval=0.0, maxval=30.0, step=0.5, group=G_RSI,
     tooltip="RSI must hold at least this many points above its previous low (or below its previous high). Filters near-flat pairs.")
bool   zoneOn    = input.bool(true, "Only from oversold / overbought", group=G_RSI, inline="z",
     tooltip="Upward: the first RSI low must be at or below the lower level and the second one below 50. Downward: the first RSI high must be at or above the upper level and the second one above 50.")
float  zoneLo    = input.float(35, "", minval=5, maxval=50, group=G_RSI, inline="z")
float  zoneHi    = input.float(65, "", minval=50, maxval=95, group=G_RSI, inline="z")

// Quanty design tokens: mint for upward, slate for downward (red is kept for volume only).
color  cUp       = input.color(#65E1C6, "Upward", group=G_LK, inline="c")
color  cDn       = input.color(#8796A5, "Downward", group=G_LK, inline="c")
color  cRsiLo    = input.color(#A9B4C2, "RSI line: low", group=G_LK, inline="r")
color  cRsiHi    = input.color(#65E1C6, "high", group=G_LK, inline="r")
bool   showLines = input.bool(true, "Draw divergence lines", group=G_LK)
bool   onPrice   = input.bool(true, "Also draw on the price chart", group=G_LK)

// ===========================================================================
// RSI peaks and troughs, checked against price
// The anchors are RSI's own pivots (the peaks and troughs you see on the RSI
// line). For each one, the price extreme is taken from a small window around
// it, because price often tops or bottoms a few bars before or after RSI.
//   price makes a lower low, RSI makes a higher low   -> upward
//   price makes a higher high, RSI makes a lower high -> downward
// ===========================================================================
float rsiV = ta.rsi(src, rsiLen)
float plV  = ta.pivotlow(rsiV, lbL, lbR)
float phV  = ta.pivothigh(rsiV, lbL, lbR)
int   win  = 2 * lbR + 1                       // pivot bar +/- lbR bars
float wLo  = ta.lowest(low, win)
float wHi  = ta.highest(high, win)
int   wLoB = bar_index + ta.lowestbars(low, win)
int   wHiB = bar_index + ta.highestbars(high, win)

// Recent RSI troughs and peaks are kept in arrays. A new trough is compared
// with the deepest trough in range (not just the one before it), so a
// divergence is still found when smaller wiggles sit between the two lows.
var array<int>   aLoBar = array.new<int>()
var array<float> aLoRsi = array.new<float>()
var array<float> aLoPx  = array.new<float>()
var array<int>   aLoPxB = array.new<int>()
var array<int>   aHiBar = array.new<int>()
var array<float> aHiRsi = array.new<float>()
var array<float> aHiPx  = array.new<float>()
var array<int>   aHiPxB = array.new<int>()

bool regUp = false
bool regDn = false

// One line per anchor: when a later trough or peak diverges from the same anchor,
// the older line is replaced, so the chart shows one divergence, not a fan.
var line  lastUpR  = na
var line  lastUpP  = na
var int   lastUpA  = na
var line  lastDnR  = na
var line  lastDnP  = na
var int   lastDnA  = na

// RSI troughs: price lower low, RSI higher low (against the deepest trough in range)
if barstate.isconfirmed and not na(plV)
    int   cBar = bar_index - lbR
    float cRs  = plV
    int   best = -1
    float bRs  = na
    int   nLo  = aLoBar.size()
    if nLo > 0
        for k = nLo - 1 to 0
            int gap = cBar - aLoBar.get(k)
            if gap > rangeMax
                break
            if gap >= rangeMin and (na(bRs) or aLoRsi.get(k) < bRs)
                best := k
                bRs  := aLoRsi.get(k)
    if best >= 0
        float pPx = aLoPx.get(best)
        if wLo < pPx and cRs >= bRs + minDiff and (not zoneOn or (bRs <= zoneLo and cRs < 50))
            regUp := true
            if showLines
                int anc = aLoBar.get(best)
                if anc == lastUpA
                    if not na(lastUpR)
                        line.delete(lastUpR)
                    if not na(lastUpP)
                        line.delete(lastUpP)
                lastUpR  := line.new(anc, bRs, cBar, cRs, color=color.new(cUp, 15), width=1)
                lastUpP  := onPrice ? line.new(aLoPxB.get(best), pPx, wLoB, wLo, color=color.new(cUp, 40), width=1, force_overlay=true) : na
                lastUpA  := anc
    aLoBar.push(cBar)
    aLoRsi.push(cRs)
    aLoPx.push(wLo)
    aLoPxB.push(wLoB)
    if aLoBar.size() > 40
        aLoBar.shift()
        aLoRsi.shift()
        aLoPx.shift()
        aLoPxB.shift()

// RSI peaks: price higher high, RSI lower high (against the highest peak in range)
if barstate.isconfirmed and not na(phV)
    int   cBar = bar_index - lbR
    float cRs  = phV
    int   best = -1
    float bRs  = na
    int   nHi  = aHiBar.size()
    if nHi > 0
        for k = nHi - 1 to 0
            int gap = cBar - aHiBar.get(k)
            if gap > rangeMax
                break
            if gap >= rangeMin and (na(bRs) or aHiRsi.get(k) > bRs)
                best := k
                bRs  := aHiRsi.get(k)
    if best >= 0
        float pPx = aHiPx.get(best)
        if wHi > pPx and cRs <= bRs - minDiff and (not zoneOn or (bRs >= zoneHi and cRs > 50))
            regDn := true
            if showLines
                int anc = aHiBar.get(best)
                if anc == lastDnA
                    if not na(lastDnR)
                        line.delete(lastDnR)
                    if not na(lastDnP)
                        line.delete(lastDnP)
                lastDnR  := line.new(anc, bRs, cBar, cRs, color=color.new(cDn, 15), width=1)
                lastDnP  := onPrice ? line.new(aHiPxB.get(best), pPx, wHiB, wHi, color=color.new(cDn, 40), width=1, force_overlay=true) : na
                lastDnA  := anc
    aHiBar.push(cBar)
    aHiRsi.push(cRs)
    aHiPx.push(wHi)
    aHiPxB.push(wHiB)
    if aHiBar.size() > 40
        aHiBar.shift()
        aHiRsi.shift()
        aHiPx.shift()
        aHiPxB.shift()

// ===========================================================================
// Drawing
// ===========================================================================
// RSI line moves from slate (30 and below) to mint (70 and above).
color rsiCol = color.from_gradient(rsiV, 30, 70, cRsiLo, cRsiHi)
plot(rsiV, "RSI", color.new(rsiCol, 15), 1)
h70 = hline(70, "70", color=#65E1C680, linestyle=hline.style_dotted)
hline(50, "50", color=#A9B4C266, linestyle=hline.style_dotted)
h30 = hline(30, "30", color=#5B687880, linestyle=hline.style_dotted)
fill(h70, h30, color=#65E1C608, title="RSI band")
// Thin zones: 70-80 (mint) and 20-30 (slate)
h80 = hline(80, "80", color=#65E1C633, linestyle=hline.style_dotted)
h20 = hline(20, "20", color=#5B687833, linestyle=hline.style_dotted)
fill(h80, h70, color=#65E1C618, title="70-80 zone")
fill(h30, h20, color=#5B687814, title="20-30 zone")

// ===========================================================================
// Signals handed to the stats block: the closed bar on which a divergence
// becomes known (lbR bars after its pivot). Nothing is back-dated.
// ===========================================================================
bool sigUp = regUp
bool sigDn = regDn

alertcondition(regUp, "Upward divergence", "RSI Divergence: upward divergence known on {{ticker}} {{interval}}")
alertcondition(regDn, "Downward divergence", "RSI Divergence: downward divergence known on {{ticker}} {{interval}}")

// ===========================================================================
// Quanty Stats - paste from here to the end into the host script
// ===========================================================================
const string G_ST = "Quanty Stats"
bool  stOn     = input.bool(true, "Stats table", group=G_ST, inline="st",
     tooltip="Measures this script's own past signals on this chart. History, not a forecast.")
bool  stMini   = input.bool(true, "collapsed (one line)", group=G_ST, inline="st",
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
string stPos   = input.string("Top right", "Table position", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=G_ST)

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
