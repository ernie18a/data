# Volume Clock MA [Quanty]

- url: https://www.tradingview.com/script/4F9yhPG2-Volume-Clock-MA-Quanty/
- type: indicator
- pine_id: PUB;4e42bebb625843cdbbf8721a075e3cbb
- version: 1.0

## Description

Moving averages count bars. This one counts volume.

[b]HOW IT IS CALCULATED[/b]

Normal volume is the average volume of the previous 200 bars. The line is the volume-weighted average price of the most recent W bars' worth of that normal volume (W = 30 by default). The script walks back from the current bar and adds bars until their volume reaches 30 times normal volume; the oldest bar enters only with the part of its volume that is still needed.

When a few bars trade heavily, that much volume fits into those few bars, the window shrinks and the line catches up with price. When the market is quiet, the window reaches further back and the line barely moves. In very quiet stretches the window stops at 5 x W bars and the line becomes a plain VWMA of those bars. Only closed bars shape the line; nothing repaints.

[b]WHAT WE MEASURED[/b]

On 135 OKX series (40 coins, 15m to 1D) we compared the line with the SMA and EMA lengths that have the same overall smoothness: a median 70-bar SMA and 62-bar EMA. After a high-volume move (volume at least 2x normal, candle body at least 1 ATR), the volume clock covered half of the move in a median 6 bars. The SMA took 29 and the EMA 22. The volume clock was ahead on all 135 series and on every timeframe.

In quiet stretches (volume under 0.7x normal) it moved less per bar than both: 0.032 ATR against 0.048 and 0.042. After low-volume moves of at least 1 ATR it was not slower: 14 bars against 22 and 20.

We repeated the test on 60 Binance perpetuals (4h) that were not in the first set: 6 bars against 28 for the SMA and 21 for the EMA, ahead on all 60.
[b]
WHAT IT IS NOT[/b]

Crossing the line is not a trading signal. On 141 OKX series, within 10 bars of the first close beyond the line, price moved at least 1 ATR in that direction in a median 59.2% of cases and at least 1 ATR the other way in 59.4%. After any bar the figure was 59.3%. That is a coin toss, and SMA 20 and VWMA 20 scored the same. The Quanty Stats table runs this test on your chart.

[b]READING IT[/b]

The line is mint while it rises, grey while it falls and dim when its slope is under 0.01 ATR per bar.

The clock table (bottom right) shows how many bars the window spans now and its median over the last 500 bars. It also shows, on this chart, how many bars this line and a comparison SMA needed to cover half of each high-volume move. The comparison SMA (70 bars by default) can be drawn on the chart.

[b]SETTINGS[/b]

Window (W): how many bars of normal volume to average, 30 by default. Normal volume: average of the last 200 bars. Longest window: 5 x W bars. Source, colours, the flat threshold and the comparison SMA are adjustable.

[b]HOW TO READ THE STATS TABLE[/b]

The table in the corner measures this indicator's own past signals on the chart you are viewing: how many signals fired (the number after the slash), and in how many of them price moved at least 1 ATR (14 bars) in the signal's direction within the next 10 bars. It is a measurement of history on this symbol and timeframe, not a prediction and not a promise. Change the symbol or the timeframe and the numbers change with it. Past results do not guarantee future results.

The next row tests the same signals in the opposite direction: if both directions score about the same, the signal marked a volatile moment, not a direction. The row after that runs the same test on every bar of the chart in a random direction, so you can see what a coin toss would have scored here. Two more rows split the count by volume: signals whose candle volume was at least 2 times the average of the previous 50 bars, and the rest. When one side has only a handful of signals, read it as a handful, not as a rate. Pending signals are too recent to be measured and are not counted. The threshold can be set in ATR or in percent, and the number of bars ahead is a setting.

Here a signal is the first close beyond the line, tested in its own direction.

[b]Not investment advice.[/b]

## Source Code

````pine
//@version=6
// Volume Clock MA [Quanty] - v0.1 - 2026-10-04 - publication copy - 2026-10-04
indicator("Volume Clock MA [Quanty]", shorttitle="Quanty VCMA", overlay=true, max_bars_back=5000)

// A moving average that keeps time in volume, not in bars. The line is the
// volume-weighted average price of the last W bars' worth of NORMAL volume
// (W = 30), where normal volume is the average of the previous 200 bars. When volume
// surges, that amount of volume fits into a few bars and the line catches up
// fast. When the market is quiet, it reaches further back and barely moves.
//
// Measured on 135 OKX series (40 coins, 15m to 1D). At the same overall
// smoothness as a 70-bar SMA (62-bar EMA), the line covered half of a
// high-volume move (volume at least 2x normal, candle body at least 1 ATR) in
// a median 6 bars, against 29 for the SMA and 22 for the EMA, ahead on every
// series. In quiet stretches it moved less, and it was not slower on
// low-volume moves. Checked again on 60 Binance perpetuals (4h): 6 bars
// against 28 and 21.
//
// Crossing the line is not a signal: the first close beyond it moved 1 ATR
// its way as often as the other way, the same as SMA 20 and VWMA 20. The
// Stats table shows that test on your chart. Nothing repaints.

// ===========================================================================
// Inputs
// ===========================================================================
const string G_MA   = "1. Volume clock"
const string G_LOOK = "2. Appearance"

int   win     = input.int(30, "Window (bars of normal volume)", minval=2, maxval=200, group=G_MA,
     tooltip="The line averages the last W x normal volume. 30 means: as much volume as 30 ordinary bars trade.")
int   unitLen = input.int(200, "Normal volume = average of the last (bars)", minval=20, maxval=1000, group=G_MA)
int   capMult = input.int(5, "Longest window (x window, in bars)", minval=1, maxval=20, group=G_MA,
     tooltip="In very quiet stretches the window stops at this many times W bars and the line becomes a plain VWMA of those bars.")
float src     = input.source(close, "Source", group=G_MA)

color cUp     = input.color(#65E1C6, "Rising", group=G_LOOK, inline="c")
color cDn     = input.color(#A9B4C2, "Falling", group=G_LOOK, inline="c")
color cFlat   = input.color(#707C8A, "Flat", group=G_LOOK, inline="c")
int   lineW   = input.int(2, "Line width", minval=1, maxval=4, group=G_LOOK)
float flatAtr = input.float(0.01, "Flat when the slope is under (ATR per bar)", minval=0.0, maxval=1.0, step=0.005, group=G_LOOK)
bool  showCmp = input.bool(false, "Compare with an SMA", group=G_LOOK, inline="cmp")
int   cmpLen  = input.int(70, "length", minval=2, maxval=500, group=G_LOOK, inline="cmp",
     tooltip="On our data a 70-bar SMA had the same overall smoothness as the volume clock with W = 30.")
bool  showClock = input.bool(true, "Show clock table", group=G_LOOK,
     tooltip="How many bars the window spans now, and how fast this line and the comparison SMA caught up with high-volume moves on this chart.")

// ===========================================================================
// The volume clock
// ===========================================================================
float vol    = nz(volume)
float unit   = ta.sma(vol, unitLen)[1]
float target = win * unit
int   maxBars = win * capMult

float vcma     = na
float barsUsed = na
if not na(target) and target > 0
    float cum  = 0.0
    float num  = 0.0
    bool  done = false
    for i = 0 to maxBars - 1
        float vi = nz(volume[i])
        float pi = src[i]
        if cum + vi >= target
            // the oldest bar enters only with the volume still needed
            num += (target - cum) * pi
            barsUsed := i + 1
            done := true
            break
        cum += vi
        num += vi * pi
    if done
        vcma := num / target
    else
        // quiet cap: plain VWMA of the longest window
        vcma := cum > 0 ? num / cum : na
        barsUsed := maxBars

float atr14  = ta.atr(14)
float slope  = vcma - vcma[1]
color lineCol = na(slope) or na(atr14) ? cFlat : slope > flatAtr * atr14 ? cUp : slope < -flatAtr * atr14 ? cDn : cFlat
plot(vcma, "Volume Clock MA", color=lineCol, linewidth=lineW)
plot(barsUsed, "Window now (bars)", display=display.data_window)

float cmpMa = ta.sma(src, cmpLen)
plot(showCmp ? cmpMa : na, "SMA (comparison)", color=color.new(#707C8A, 25), linewidth=1, style=plot.style_linebr)

// ===========================================================================
// Clock table: catch-up after high-volume moves, measured on this chart.
// An event is a candle with volume at least 2x normal and a body of at least
// 1 ATR. For each event, count the bars until the line covers half of the
// distance from its previous value to that candle's close (at most 30).
// ===========================================================================
const int CATCH_MAX = 30
bool isEvent = not na(vcma[1]) and not na(cmpMa[1]) and not na(unit) and unit > 0 and vol >= 2.0 * unit and math.abs(close - open) >= atr14

var array<int>   evStart = array.new<int>()
var array<bool>  evUp    = array.new<bool>()
var array<float> evTgtV  = array.new<float>()
var array<float> evTgtS  = array.new<float>()
var array<int>   evDoneV = array.new<int>()
var array<int>   evDoneS = array.new<int>()
var array<int>   resV    = array.new<int>()
var array<int>   resS    = array.new<int>()

if barstate.isconfirmed
    if isEvent
        evStart.push(bar_index)
        evUp.push(close > vcma[1])
        evTgtV.push(vcma[1] + 0.5 * (close - vcma[1]))
        evTgtS.push(cmpMa[1] + 0.5 * (close - cmpMa[1]))
        evDoneV.push(-1)
        evDoneS.push(-1)
    int k = evStart.size() - 1
    while k >= 0
        int age = bar_index - evStart.get(k)
        bool up = evUp.get(k)
        if evDoneV.get(k) < 0 and not na(vcma) and (up ? vcma >= evTgtV.get(k) : vcma <= evTgtV.get(k))
            evDoneV.set(k, age)
        if evDoneS.get(k) < 0 and not na(cmpMa) and (up ? cmpMa >= evTgtS.get(k) : cmpMa <= evTgtS.get(k))
            evDoneS.set(k, age)
        if (evDoneV.get(k) >= 0 and evDoneS.get(k) >= 0) or age >= CATCH_MAX
            resV.push(evDoneV.get(k) >= 0 ? evDoneV.get(k) : CATCH_MAX)
            resS.push(evDoneS.get(k) >= 0 ? evDoneS.get(k) : CATCH_MAX)
            if resV.size() > 100
                resV.shift()
                resS.shift()
            evStart.remove(k)
            evUp.remove(k)
            evTgtV.remove(k)
            evTgtS.remove(k)
            evDoneV.remove(k)
            evDoneS.remove(k)
        k -= 1

float winMed = ta.median(barsUsed, 500)

var table clockT = table.new(position.bottom_right, 2, 5, bgcolor=#10171E, frame_color=#202B35, frame_width=1, border_color=#202B35, border_width=1)
if showClock and barstate.islast
    table.cell(clockT, 0, 0, "Volume clock, W = " + str.tostring(win), text_color=#707C8A, text_size=size.small, text_halign=text.align_left)
    table.cell(clockT, 1, 0, "this chart", text_color=#707C8A, text_size=size.small, text_halign=text.align_right)
    table.cell(clockT, 0, 1, "Window now", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(clockT, 1, 1, na(barsUsed) ? "-" : str.tostring(barsUsed, "#") + " bars", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
    table.cell(clockT, 0, 2, "Window, median of last 500", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(clockT, 1, 2, na(winMed) ? "-" : str.tostring(winMed, "#") + " bars", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
    string nEv = str.tostring(resV.size())
    table.cell(clockT, 0, 3, "Half of a high-volume move, this line", text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(clockT, 1, 3, resV.size() > 0 ? str.tostring(resV.median(), "#.#") + " bars (" + nEv + " moves)" : "-", text_color=#65E1C6, text_size=size.small, text_halign=text.align_right)
    table.cell(clockT, 0, 4, "Same, SMA " + str.tostring(cmpLen), text_color=#A9B4C2, text_size=size.small, text_halign=text.align_left)
    table.cell(clockT, 1, 4, resS.size() > 0 ? str.tostring(resS.median(), "#.#") + " bars" : "-", text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)

// ===========================================================================
// Alerts
// ===========================================================================
bool aboveNow = not na(vcma) and close > vcma
bool belowNow = not na(vcma) and close < vcma
alertcondition(aboveNow and not aboveNow[1], "Close above the volume clock", "{{ticker}} {{interval}}: close above the Quanty volume clock line")
alertcondition(belowNow and not belowNow[1], "Close below the volume clock", "{{ticker}} {{interval}}: close below the Quanty volume clock line")

// ===========================================================================
// Signals handed to the stats block: the FIRST close beyond the line, in its
// direction. On our data this is a coin toss; the table shows it on yours.
// ===========================================================================
bool sigUp = aboveNow and not aboveNow[1]
bool sigDn = belowNow and not belowNow[1]

// ===========================================================================
// Quanty Stats - paste from here to the end into the host script
// ===========================================================================
const string G_ST = "3. Quanty Stats"
bool  stOn     = input.bool(true, "Stats table", group=G_ST,
     tooltip="Measures this script's own past signals on this chart. History, not a forecast.")
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
