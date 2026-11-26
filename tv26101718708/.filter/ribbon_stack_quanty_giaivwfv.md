# Ribbon Stack [Quanty]

- url: https://www.tradingview.com/script/GiaIvWfV-Ribbon-Stack-Quanty/
- type: indicator
- pine_id: PUB;7eff4a065d1a439ab020579b70ed9750
- version: 1.0

## Description

Everyone uses an EMA ribbon. Almost nobody checks what happens after it lines up.

This script draws the ribbon and then measures it. When all eight EMAs fall into order, it records the bar, waits ten bars, and counts how often price kept moving that way. It puts that count next to two yardsticks: the same signals tested in the opposite direction, and a random bar on the same chart. If a full stack is no better than a coin toss on your symbol and timeframe, the table says so.

WHAT MAKES IT DIFFERENT

The measurement. The ribbon itself is familiar; what is added is a stats table that tests the ribbon's own moment against chance, on the chart you are viewing, with the sample size always shown.

The colour reads the whole ribbon, not one crossover. Each of the seven neighbouring pairs is checked, so a ribbon that is only partly ordered looks partly ordered instead of flipping between two colours.

The width is measured. The distance between the fastest and the slowest line is shown in ATR, and bars where the ribbon is unusually tight are shaded.

WHAT IT SHOWS

Eight EMAs between a fastest and a slowest length (8 and 89 by default), coloured by the stack: one colour when the lines are in rising order, another when they are in falling order, and a neutral tone when they are mixed. The colour moves gradually, so a ribbon that is only partly ordered looks partly ordered. Optional: a fill between the fastest and the slowest line, a light shade on bars where the ribbon is compressed, a small mark on the bar where the ribbon becomes fully stacked, and a small readout in the bottom-right corner ("Stack +5/7 | width 1.8 ATR").

HOW IT IS CALCULATED

Lengths: the six lengths in between are spaced geometrically, so each one is the same multiple of the one before it (about 1.4x with the defaults: 8, 11, 16, 22, 32, 45, 63, 89). Evenly spaced ribbons (20, 25, 30...) crowd their slow end and leave their fast end sparse; geometric spacing keeps the steps even.

Stack: each of the seven neighbouring pairs scores +1 when the faster line is above the slower one and -1 when it is below. The sum runs from -7 to +7. Full stack means all seven pairs agree.

Width: the distance between the highest and the lowest of the eight lines, divided by the ATR (14 bars by default). In ATR units a width reads the same on a 15-minute chart and a daily one.

Compression: a bar is shaded when the width is in the lowest 10% of the last 200 bars. A compressed ribbon means the averages have converged; it says nothing about what comes next.

SETTINGS

Source, fastest and slowest length, ATR length, compression lookback and threshold. Appearance: the three colours, the fill, the compression shade, the full-stack marks and the readout. Three alerts: full stack in rising order, full stack in falling order, and the ribbon entering compression.

NOTES AND LIMITATIONS

Moving averages are built from past prices, so the ribbon always lags. A full stack confirms what price has already done; it is not a forecast. Marks and alerts are read on closed bars, so they do not repaint. The slowest length must be at least seven bars longer than the fastest.

HOW TO READ THE STATS TABLE

The table in the corner measures this indicator's own past signals on the chart you are viewing: how many signals fired (the number after the slash), and in how many of them price moved at least 1 ATR (14 bars) in the signal's direction within the next 10 bars. It is a measurement of history on this symbol and timeframe, not a prediction and not a promise. Change the symbol or the timeframe and the numbers change with it. Past results do not guarantee future results.

The next row tests the same signals in the opposite direction: if both directions score about the same, the signal marked a volatile moment, not a direction. The row after that runs the same test on every one of the last 500 bars in a random direction, so you can see what a coin toss would have scored here. Two more rows split the count by volume: signals whose candle volume was at least 2 times the average of the previous 50 bars, and the rest. When one side has only a handful of signals, read it as a handful, not as a rate. Pending signals are too recent to be measured and are not counted. The threshold can be set in ATR or in percent, and the number of bars ahead is a setting. The table can be shown in full or collapsed to one line.

Here a signal is the closed bar on which the ribbon becomes fully stacked: all eight EMAs in rising order (upward) or in falling order (downward).

Not investment advice.

## Source Code

````pine
//@version=6
// Ribbon Stack [Quanty] - v0.1.3 - 2026-10-03 - publication copy (Dreamer for Ata; Engineer to sync source), awaiting first compile
// Stats block v0.3 (collapsed view included).
indicator("Ribbon Stack [Quanty]", shorttitle="Quanty RIBBON", overlay=true)

// Eight exponential moving averages, spaced geometrically between a fast and a
// slow length, coloured by how ordered they are. The script reads two things
// from the ribbon: its stack (how many neighbouring lines are in order) and its
// width in ATR (how far apart the fastest and slowest lines are). It draws and
// measures; it does not call anything.

// ===========================================================================
// Inputs
// ===========================================================================
const string G_RB  = "1. Ribbon"
const string G_LK  = "2. Appearance"

float  src     = input.source(close, "Source", group=G_RB)
int    fastLen = input.int(8, "Fastest EMA", minval=2, maxval=100, group=G_RB)
int    slowLen = input.int(89, "Slowest EMA", minval=10, maxval=400, group=G_RB,
     tooltip="The six lengths in between are spaced geometrically: each one is the same multiple of the one before it.")
int    atrLen  = input.int(14, "ATR length (ribbon width)", minval=1, maxval=200, group=G_RB)
int    cmpLen  = input.int(200, "Compression lookback (bars)", minval=20, maxval=2000, group=G_RB)
float  cmpPct  = input.float(10.0, "Compression: width in the lowest (%)", minval=1.0, maxval=50.0, step=1.0, group=G_RB,
     tooltip="A bar is shaded as compressed when the ribbon width (in ATR) is in the lowest share of the lookback window.")

color  cUp     = input.color(#00D269, "Rising order", group=G_LK, inline="c")
color  cDn     = input.color(#F52841, "Falling order", group=G_LK, inline="c")
color  cMid    = input.color(#F2EBDC, "Mixed", group=G_LK, inline="c")
bool   showFill = input.bool(true, "Fill between fastest and slowest", group=G_LK)
bool   showCmp  = input.bool(true, "Shade compression", group=G_LK)
bool   showMark = input.bool(true, "Mark full stacks", group=G_LK)
bool   showRead = input.bool(true, "Readout (bottom right)", group=G_LK)

if slowLen < fastLen + 7
    runtime.error("Slowest EMA must be at least 7 longer than the fastest EMA.")

// ===========================================================================
// Ribbon
// ===========================================================================
// Lengths are computed inline (not in a function) so they stay "simple int", which ta.ema requires.
float ratio = float(slowLen) / fastLen
int len1 = fastLen
int len2 = math.max(len1 + 1, math.round(fastLen * math.pow(ratio, 1.0 / 7.0)))
int len3 = math.max(len2 + 1, math.round(fastLen * math.pow(ratio, 2.0 / 7.0)))
int len4 = math.max(len3 + 1, math.round(fastLen * math.pow(ratio, 3.0 / 7.0)))
int len5 = math.max(len4 + 1, math.round(fastLen * math.pow(ratio, 4.0 / 7.0)))
int len6 = math.max(len5 + 1, math.round(fastLen * math.pow(ratio, 5.0 / 7.0)))
int len7 = math.max(len6 + 1, math.round(fastLen * math.pow(ratio, 6.0 / 7.0)))
int len8 = math.max(len7 + 1, slowLen)

float e1 = ta.ema(src, len1)
float e2 = ta.ema(src, len2)
float e3 = ta.ema(src, len3)
float e4 = ta.ema(src, len4)
float e5 = ta.ema(src, len5)
float e6 = ta.ema(src, len6)
float e7 = ta.ema(src, len7)
float e8 = ta.ema(src, len8)

// Stack: how many of the seven neighbouring pairs are in rising order (faster
// above slower) minus how many are in falling order, divided by seven.
f_ord(float a, float b) =>
    a > b ? 1 : a < b ? -1 : 0
int   ordSum = f_ord(e1, e2) + f_ord(e2, e3) + f_ord(e3, e4) + f_ord(e4, e5) + f_ord(e5, e6) + f_ord(e6, e7) + f_ord(e7, e8)
float stack  = ordSum / 7.0
bool  fullUp = ordSum == 7
bool  fullDn = ordSum == -7

// Width: distance between the highest and the lowest line, in ATR.
float atrV     = ta.atr(atrLen)
float hiE      = math.max(e1, e2, e3, e4, e5, e6, e7, e8)
float loE      = math.min(e1, e2, e3, e4, e5, e6, e7, e8)
float widthAtr = atrV > 0 ? (hiE - loE) / atrV : na
float widthRk  = ta.percentrank(widthAtr, cmpLen)
bool  compressed = not na(widthRk) and widthRk <= cmpPct

// ===========================================================================
// Drawing
// ===========================================================================
color ribCol = stack >= 0 ? color.from_gradient(stack, 0.0, 1.0, cMid, cUp) : color.from_gradient(stack, -1.0, 0.0, cDn, cMid)

p1 = plot(e1, "EMA 1 (fastest)", color.new(ribCol, 0), 2)
plot(e2, "EMA 2", color.new(ribCol, 15), 1, display=display.pane + display.data_window)
plot(e3, "EMA 3", color.new(ribCol, 25), 1, display=display.pane + display.data_window)
plot(e4, "EMA 4", color.new(ribCol, 35), 1, display=display.pane + display.data_window)
plot(e5, "EMA 5", color.new(ribCol, 45), 1, display=display.pane + display.data_window)
plot(e6, "EMA 6", color.new(ribCol, 55), 1, display=display.pane + display.data_window)
plot(e7, "EMA 7", color.new(ribCol, 62), 1, display=display.pane + display.data_window)
p8 = plot(e8, "EMA 8 (slowest)", color.new(ribCol, 50), 2)
fill(p1, p8, color=showFill ? color.new(ribCol, 88) : na, title="Ribbon fill")
bgcolor(showCmp and compressed ? color.new(#A9B4C2, 90) : na, title="Compression")

// ===========================================================================
// Signals handed to the stats block: the closed bar on which the ribbon
// becomes fully stacked, all eight lines in rising order (sigUp) or in
// falling order (sigDn). Read on closed bars only, so nothing repaints.
// ===========================================================================
bool sigUp = barstate.isconfirmed and fullUp and not fullUp[1]
bool sigDn = barstate.isconfirmed and fullDn and not fullDn[1]
plotshape(showMark and sigUp, "Full stack, rising order", shape.diamond, location.belowbar, cUp, size=size.tiny, display=display.pane)
plotshape(showMark and sigDn, "Full stack, falling order", shape.diamond, location.abovebar, cDn, size=size.tiny, display=display.pane)

alertcondition(sigUp, "Ribbon fully stacked, rising order", "Ribbon Stack: all eight EMAs in rising order on {{ticker}} {{interval}}")
alertcondition(sigDn, "Ribbon fully stacked, falling order", "Ribbon Stack: all eight EMAs in falling order on {{ticker}} {{interval}}")
alertcondition(compressed and not compressed[1], "Ribbon compressed", "Ribbon Stack: ribbon width entered its compression zone on {{ticker}} {{interval}}")

// Readout in the bottom-right corner: stack and width. A table, not a label, so the
// price line never runs through it.
var table rdT = table.new(position.bottom_right, 1, 1, bgcolor=#10171E, frame_color=#202B35, frame_width=1)
if showRead and barstate.islast
    string txt = "Stack " + (ordSum > 0 ? "+" : "") + str.tostring(ordSum) + "/7 | width " + (na(widthAtr) ? "-" : str.tostring(widthAtr, "#.#")) + " ATR" + (compressed ? " | compressed" : "")
    table.cell(rdT, 0, 0, txt, text_color=ribCol, text_size=size.small)

// ===========================================================================
// Quanty Stats - paste from here to the end into the host script
// ===========================================================================
const string G_ST = "Quanty Stats"
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

var table stT = table.new(f_stPos(stPos), 2, 10, bgcolor=#10171E, frame_color=#202B35, frame_width=1, border_color=#202B35, border_width=1)
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
        table.cell(stT, 1, 0, f_stFrac(hits, n) + " moved " + thr + " | opposite " + stOpp + (na(stBase) ? "" : " | any bar " + str.tostring(math.round(100.0 * stBase)) + "%"), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        for r = 1 to 9
            table.cell(stT, 0, r, "", text_size=size.tiny)
            table.cell(stT, 1, r, "", text_size=size.tiny)
    else
        table.cell(stT, 0, 0, "Quanty Stats", text_color=#65E1C6, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 0, "last " + str.tostring(stN) + " signals", text_color=#707C8A, text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 1, "Signals measured", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 1, str.tostring(n) + (stPending > 0 ? " (" + str.tostring(stPending) + " pending)" : ""), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 2, "Moved at least " + thr, text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 2, f_stFrac(hits, n), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 3, "Opposite direction, same signals", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 3, f_stFrac(opps, n), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 4, "Any bar, same test (last " + str.tostring(stBaseLen) + ")", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 4, na(stBase) ? "-" : str.tostring(math.round(100.0 * stBase)) + "%", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 5, "Median peak move", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 5, n > 0 ? f_stPct(stPeaks.median()) : "-", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        table.cell(stT, 0, 6, "Median move at bar " + str.tostring(stK), text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 6, n > 0 ? f_stPct(stEnds.median()) : "-", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        if stVolOn
            table.cell(stT, 0, 7, "With volume >= " + str.tostring(stVolMin, "#.#") + "x", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
            table.cell(stT, 1, 7, f_stFrac(hV, nV), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
            table.cell(stT, 0, 8, "Without", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
            table.cell(stT, 1, 8, f_stFrac(hits - hV, n - nV), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
        else
            table.cell(stT, 0, 7, "", text_size=size.tiny)
            table.cell(stT, 1, 7, "", text_size=size.tiny)
            table.cell(stT, 0, 8, "", text_size=size.tiny)
            table.cell(stT, 1, 8, "", text_size=size.tiny)
        table.cell(stT, 0, 9, "History on this chart, not a forecast", text_color=#707C8A, text_size=size.tiny, text_halign=text.align_left)
        table.cell(stT, 1, 9, "", text_size=size.tiny)
````
