# Chandelier Trend [Quanty]

- url: https://www.tradingview.com/script/5VTUAJNV-Chandelier-Trend-Quanty/
- type: indicator
- pine_id: PUB;4663c1aef9154ff7a8521fb8d1fe8044
- version: 1.0

## Description

The Chandelier Exit, drawn as one glowing trend line, with a shade between the line and price, candles coloured by the current trend and a dot at every turn. Underneath it, a table that tests the last turns on your chart against chance.

[b]HOW IT WORKS[/b]

The idea comes from Chuck LeBeau's Chandelier Exit: a trailing level hangs a multiple of ATR away from the extreme reached since the trade began. Here it runs both ways. In an up trend the level sits below the highest high since the last turn and can only rise; in a down trend it sits above the lowest low since the last turn and can only fall. When a candle closes through the level the trend turns, and the new level starts from that candle. Everything is read on closed candles: the line, the colours and the dots do not change on the live candle. The default preset is the classic setting (ATR 22, multiplier 3). "Faster" (ATR 10, multiplier 2.5) turns sooner and more often: it scored best on hourly bitcoin in one year of our test and did not beat chance in the following year, so it is a style choice, not an edge. "Custom" lets you set both. Switch off "Measure from highs and lows" to measure from closes instead.

Teal is the up trend, violet the down trend. The shade fades in three layers from the line toward price, so a wide shade means price is far from its trailing level and a thin one means it is close. Candle colouring and the turn dots can be switched off, and the colours and shade strength can be changed.

[b]HOW TO READ THE STATS TABLE[/b]

The table in the corner takes the last 50 turns on the chart you are viewing (the number after the slash) and counts in how many of them price moved at least 1 ATR (14 bars) in the new trend's direction within the next 10 bars. It is a measurement of history on this symbol and timeframe, not a prediction and not a promise. Change the symbol or the timeframe and the numbers change with it. Past results do not guarantee future results.

The next row tests the same turns in the opposite direction: if both directions score about the same, the turn marked a volatile moment, not a direction. The row after that runs the same test on every one of the last 500 bars in a random direction, so you can see what a coin toss would have scored here. Two more rows split the count by volume: turns whose candle volume was at least 2 times the average of the previous 50 bars, and the rest. When one side has only a handful of turns, read it as a handful, not as a rate. Turns that are too recent to be measured are not counted. The threshold can be set in ATR or in percent, and the number of bars ahead is a setting. The table can be collapsed to one line, and its colours follow your chart theme.

We tested these turns against chance on hourly crypto charts, with the rules written down before the run. Against a random hour they pointed the way a little more often in the latest year, on the coins the script was built on and on coins it never saw. But other coins at the same hours did about as well, and in the year before there was no difference at all. So a turn follows the market's move rather than adding to it: read it as a description of the trend, not a forecast, and check it on your own symbol and timeframe.

Alerts: "Trend turned up" and "Trend turned down", both on the close of the candle.

Our own state machine on the textbook idea; no code from other scripts is used.

[b]Not investment advice.[/b]

## Source Code

````pine
//@version=6
// Chandelier Trend, Tested [Quanty] - v0.2 - written by Dreamer for Ata
//
// "Is this trend still alive, and did the last turn on this chart mean anything?"
// After Chuck LeBeau's Chandelier Exit: a trailing level hangs a multiple of ATR away from
// the extreme reached since the trend began. In an up trend it sits below the highest high
// since the turn and can only rise; in a down trend it sits above the lowest low since the
// turn and can only fall. When a candle closes through the level the trend turns, and the
// new level starts from that candle.
// The script draws the level as one glowing line, shades the space between the line and
// price in three fading layers, colours the candles by the trend and marks every turn.
//
// Its Stats table asks the question most trend tools skip: after a turn, did price travel
// further in the new direction than in the opposite one, and further than any bar on this
// chart in a random direction? In our own offline test on hourly crypto charts the turns
// pointed the way a little more often than a random hour in the latest year, but no more
// often than other coins at the same hours, and not at all in the year before: a turn
// follows the market's move rather than adding to it. Check it on your symbol and timeframe.
// History, not a forecast. Not investment advice.
//
// Everything is read on closed candles: the line, the colours and the dots do not change
// on the live candle. Our own state machine on the textbook idea; no code from other
// scripts is used.
indicator("Chandelier Trend, Tested [Quanty]", shorttitle="Quanty Chandelier", overlay=true)

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
const string G_C = "1. Chandelier"
const string G_A = "2. Appearance"
string preset  = input.string("Classic (22 / 3)", "Preset", options=["Classic (22 / 3)", "Faster (10 / 2.5)", "Custom"], group=G_C,
     tooltip="Classic is LeBeau's setting. Faster turns sooner and more often; it scored best on hourly bitcoin in one year of our test and did not beat chance in the next one, so treat it as a style choice, not an edge. Custom uses the two fields below.")
int   ceLenIn  = input.int(22, "ATR length (Custom)", minval=2, maxval=300, group=G_C)
float ceMultIn = input.float(3.0, "ATR multiplier (Custom)", minval=0.5, maxval=10.0, step=0.1, group=G_C)
int   ceLen    = preset == "Classic (22 / 3)" ? 22 : preset == "Faster (10 / 2.5)" ? 10 : ceLenIn
float ceMult   = preset == "Classic (22 / 3)" ? 3.0 : preset == "Faster (10 / 2.5)" ? 2.5 : ceMultIn
bool  ceWicks = input.bool(true, "Measure from highs and lows (off: closes)", group=G_C)
color cUp     = input.color(#0FA88A, "Up trend", group=G_A, inline="c")
color cDn     = input.color(#8C7BD6, "Down trend", group=G_A, inline="c")
int   glowT   = input.int(50, "Shade strength (transparency at the line)", minval=0, maxval=90, group=G_A)
bool  paint   = input.bool(true, "Colour candles by trend", group=G_A)
bool  dots    = input.bool(true, "Mark trend turns", group=G_A)

// ---------------------------------------------------------------------------
// Trailing level: a small state machine
// ---------------------------------------------------------------------------
float span  = ta.atr(ceLen) * ceMult
float upX   = ceWicks ? high : close
float dnX   = ceWicks ? low : close
bool  ready = not na(span)

var int   trend = 0
var float ext   = na   // extreme since the last turn
var float lvl   = na
if ready
    if trend == 0
        trend := 1
        ext   := upX
        lvl   := ext - span
    else if trend == 1
        ext := math.max(ext, upX)
        lvl := math.max(lvl, ext - span)
        if close < lvl
            trend := -1
            ext   := dnX
            lvl   := ext + span
    else
        ext := math.min(ext, dnX)
        lvl := math.min(lvl, ext + span)
        if close > lvl
            trend := 1
            ext   := upX
            lvl   := ext - span

// turns, confirmed on the close of the candle
bool sigUp = barstate.isconfirmed and trend == 1 and trend[1] == -1
bool sigDn = barstate.isconfirmed and trend == -1 and trend[1] == 1

// what is shown: the live candle shows the state of the last closed candle
int   tShow = barstate.isconfirmed ? trend : trend[1]
float lShow = barstate.isconfirmed ? lvl : lvl[1]

// ---------------------------------------------------------------------------
// Drawing
// ---------------------------------------------------------------------------
color lineCol   = tShow == 1 ? cUp : cDn
bool  same      = tShow != 0 and tShow == tShow[1]
float drawLevel = same ? lShow : na
float m1 = drawLevel + (hl2 - drawLevel) * 0.33
float m2 = drawLevel + (hl2 - drawLevel) * 0.66

plot(drawLevel, "Glow", color=color.new(lineCol, 82), linewidth=8, style=plot.style_linebr)
pLevel = plot(drawLevel, "Chandelier level", color=lineCol, linewidth=3, style=plot.style_linebr)
pM1    = plot(m1, "Shade step 1", color=na, display=display.none)
pM2    = plot(m2, "Shade step 2", color=na, display=display.none)
pPrice = plot(same ? hl2 : na, "Price reference", color=na, display=display.none)

// three layers, strongest at the line, fading toward price
bool  upT = tShow == 1
color c0 = color.new(lineCol, glowT)
color c1 = color.new(lineCol, math.min(glowT + 20, 100))
color c2 = color.new(lineCol, math.min(glowT + 35, 100))
color c3 = color.new(lineCol, 100)
fill(pLevel, pM1, upT ? m1 : drawLevel, upT ? drawLevel : m1, upT ? c1 : c0, upT ? c0 : c1, "Shade 1")
fill(pM1, pM2, upT ? m2 : m1, upT ? m1 : m2, upT ? c2 : c1, upT ? c1 : c2, "Shade 2")
fill(pM2, pPrice, upT ? hl2 : m2, upT ? m2 : hl2, upT ? c3 : c2, upT ? c2 : c3, "Shade 3")

barcolor(paint and tShow != 0 ? color.new(lineCol, close >= open ? 0 : 35) : na, title="Trend candles")

plotshape(dots and sigUp ? lvl : na, "Turn up (halo)", shape.circle, location.absolute, color.new(cUp, 75), size=size.normal)
plotshape(dots and sigUp ? lvl : na, "Turn up", shape.circle, location.absolute, cUp, size=size.tiny)
plotshape(dots and sigDn ? lvl : na, "Turn down (halo)", shape.circle, location.absolute, color.new(cDn, 75), size=size.normal)
plotshape(dots and sigDn ? lvl : na, "Turn down", shape.circle, location.absolute, cDn, size=size.tiny)

alertcondition(sigUp, "Trend turned up", "Chandelier: trend turned up on {{ticker}} {{interval}}")
alertcondition(sigDn, "Trend turned down", "Chandelier: trend turned down on {{ticker}} {{interval}}")

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
