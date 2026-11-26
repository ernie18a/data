# HTF Candles [Quanty]

- url: https://www.tradingview.com/script/OEDpB4Ye-HTF-Candles-Quanty/
- type: indicator
- pine_id: PUB;051e3d4bdd7742a991a4aa39ea9ebe09
- version: 1.0

## Description

Trading a 15m or 1h chart while keeping an eye on the daily or weekly candle usually means switching charts or squinting at a small multi-timeframe widget. This script draws the higher-timeframe candle itself, large, to the right of the current price, so the bigger picture sits next to the bars you are trading.

WHAT IT SHOWS

Up to three higher timeframes, side by side (4H, 1D and 1W by default). For each one, the candle that is forming now, updated live, and optionally up to six previous candles to its left; the number of candles is set separately for each timeframe. Each block carries its timeframe label centred above it and the time left in the live candle centred below it. A thin separator sits between the blocks. The high and low prices and a 50% line are optional.

HOW IT WORKS

The values come from the exchange's own higher-timeframe candles, not from an approximation built out of chart bars, so the open, high, low and close match what you see when you switch the chart to that timeframe. The drawing is placed a set number of bars to the right of the last bar and redrawn on every update.

SETTINGS

Three timeframes, each with its own on/off switch and candle count (1 to 7). Layout: distance from the last bar, candle width, gap between candles and gap between timeframes. Appearance: rising and falling colours, wick and text colour, the timeframe label, the time-left label, the separator (colour, width, style), high and low prices and the 50% line. The stats table can be shown in full or collapsed to one line.

NOTES AND LIMITATIONS

A timeframe equal to or lower than the chart's own is skipped: it adds nothing. The current higher-timeframe candle is still forming, so its high, low and close change until it closes. The script only displays prices; it does not forecast anything.

HOW TO READ THE STATS TABLE

The script draws candles and makes no calls, so the table measures the one event a higher-timeframe candle offers: a Timeframe 1 candle (4H by default) that closed beyond the range of the candle before it. The table in the corner counts how many such closes happened on the chart you are viewing (the number after the slash), and in how many of them price moved at least 1 ATR (14 bars) further in the same direction within the next 10 chart bars. It is a measurement of history on this symbol and timeframe, not a prediction and not a promise. Change the symbol or the timeframe and the numbers change with it. Past results do not guarantee future results.

The next row tests the same signals in the opposite direction: if both directions score about the same, the signal marked a volatile moment, not a direction. The row after that runs the same test on every bar of the chart in a random direction, so you can see what a coin toss would have scored here. Two more rows split the count by volume: signals whose candle volume was at least 2 times the average of the previous 50 bars, and the rest. When one side has only a handful of signals, read it as a handful, not as a rate. Pending signals are too recent to be measured and are not counted. The threshold can be set in ATR or in percent, and the number of bars ahead is a setting.

Here a signal is a Timeframe 1 candle that closed above the previous candle's high (upward) or below its low (downward), read once both candles are final.

Not investment advice.

## Source Code

````pine
//@version=6
// HTF Candles [Quanty] - v0.3 - 2026-10-02 - publication copy (Dreamer, Ata's request; Engineer to sync source)
// v0.3: three timeframes, candles-per-timeframe set separately, gap between timeframes, label centred on the block,
//       dotted separator between timeframes, Trend Candles green/red for direction (Ata, 2 Oct)
// v0.2: Quanty Stats table (a Timeframe 1 candle that closed beyond the candle before it)
indicator("HTF Candles [Quanty]", shorttitle="Quanty HTF", overlay=true,
     max_boxes_count=100, max_lines_count=300, max_labels_count=100)

// Draws the candles of up to three higher timeframes, large, to the right of
// the chart: the one forming now (live) and, optionally, the ones before it.
// Useful to read a 1D or 1W candle while trading a 15m or 1h chart.
// Nothing here forecasts anything; it is the same OHLC the exchange prints.

// ===========================================================================
// Inputs
// ===========================================================================
const string G_TF   = "1. Timeframes"
const string G_LAY  = "2. Layout"
const string G_LOOK = "3. Appearance"

bool   on1   = input.bool(true, "", group=G_TF, inline="t1")
string tf1   = input.timeframe("240", "Timeframe 1", group=G_TF, inline="t1")
int    cnt1  = input.int(7, "candles", minval=1, maxval=7, group=G_TF, inline="t1",
     tooltip="1 shows only the candle that is forming now. More adds the previous ones to its left.")
bool   on2   = input.bool(true, "", group=G_TF, inline="t2")
string tf2   = input.timeframe("D", "Timeframe 2", group=G_TF, inline="t2")
int    cnt2  = input.int(4, "candles", minval=1, maxval=7, group=G_TF, inline="t2")
bool   on3   = input.bool(true, "", group=G_TF, inline="t3")
string tf3   = input.timeframe("W", "Timeframe 3", group=G_TF, inline="t3")
int    cnt3  = input.int(1, "candles", minval=1, maxval=7, group=G_TF, inline="t3")

int offset = input.int(12, "Distance from the last bar", minval=2, maxval=100, group=G_LAY)
int width  = input.int(2, "Candle width (bars)", minval=2, maxval=20, group=G_LAY)
int gap    = input.int(3, "Gap between candles (bars)", minval=1, maxval=10, group=G_LAY)
int tfGap  = input.int(9, "Gap between timeframes (bars)", minval=1, maxval=60, group=G_LAY,
     tooltip="Space between one timeframe's block and the next. TradingView draws at most 500 bars to the right of the last bar; these limits keep every layout inside that.")

// Direction colours follow Trend Candles [Quanty] (strong up / strong down), Ata, 2 Oct 2026.
color cUp    = input.color(color.new(#00D269, 70), "Rising body", group=G_LOOK, inline="u")
color cUpB   = input.color(#00D269, "border", group=G_LOOK, inline="u")
color cDn    = input.color(color.new(#F52841, 70), "Falling body", group=G_LOOK, inline="d")
color cDnB   = input.color(#F52841, "border", group=G_LOOK, inline="d")
color cWick  = input.color(#A9B4C2, "Wicks and text", group=G_LOOK)
bool  showTf   = input.bool(true, "Timeframe label", group=G_LOOK)
bool  showSep  = input.bool(true, "Separator between timeframes", group=G_LOOK, inline="s")
color cSep     = input.color(color.new(#A9B4C2, 55), "", group=G_LOOK, inline="s")
int   sepW     = input.int(1, "width", minval=1, maxval=4, group=G_LOOK, inline="s")
string sepStyle = input.string("Dotted", "style", options=["Dotted", "Dashed", "Solid"], group=G_LOOK, inline="s")
bool  showLeft = input.bool(true, "Time left in the candle", group=G_LOOK)
bool  showHL   = input.bool(false, "High and low prices", group=G_LOOK)
bool  showMid  = input.bool(false, "50% line", group=G_LOOK)

// ===========================================================================
// Data: current candle [0] and up to six previous ones, per timeframe (three timeframes)
// ===========================================================================
f_req(string tf) =>
    request.security(syminfo.tickerid, tf,
         [open, high, low, close, time_close,
          open[1], high[1], low[1], close[1],
          open[2], high[2], low[2], close[2],
          open[3], high[3], low[3], close[3],
          open[4], high[4], low[4], close[4],
          open[5], high[5], low[5], close[5],
          open[6], high[6], low[6], close[6]],
         lookahead=barmerge.lookahead_off)

[a0o, a0h, a0l, a0c, aEnd, a1o, a1h, a1l, a1c, a2o, a2h, a2l, a2c, a3o, a3h, a3l, a3c, a4o, a4h, a4l, a4c, a5o, a5h, a5l, a5c, a6o, a6h, a6l, a6c] = f_req(tf1)
[b0o, b0h, b0l, b0c, bEnd, b1o, b1h, b1l, b1c, b2o, b2h, b2l, b2c, b3o, b3h, b3l, b3c, b4o, b4h, b4l, b4c, b5o, b5h, b5l, b5c, b6o, b6h, b6l, b6c] = f_req(tf2)
[c0o, c0h, c0l, c0c, cEnd, c1o, c1h, c1l, c1c, c2o, c2h, c2l, c2c, c3o, c3h, c3l, c3c, c4o, c4h, c4l, c4c, c5o, c5h, c5l, c5c, c6o, c6h, c6l, c6c] = f_req(tf3)

// A timeframe at or below the chart's own has nothing to add.
bool ok1 = on1 and timeframe.in_seconds(tf1) > timeframe.in_seconds(timeframe.period)
bool ok2 = on2 and timeframe.in_seconds(tf2) > timeframe.in_seconds(timeframe.period)
bool ok3 = on3 and timeframe.in_seconds(tf3) > timeframe.in_seconds(timeframe.period)

// ===========================================================================
// Helpers
// ===========================================================================
f_tfText(string tf) =>
    int s = timeframe.in_seconds(tf)
    string out = tf
    if str.contains(tf, "M")
        out := str.replace(tf, "M", "") + "M"
        out := out == "M" ? "1M" : out
    else if s % 604800 == 0
        out := str.tostring(int(s / 604800)) + "W"
    else if s % 86400 == 0
        out := str.tostring(int(s / 86400)) + "D"
    else if s % 3600 == 0
        out := str.tostring(int(s / 3600)) + "H"
    else
        out := str.tostring(int(s / 60)) + "m"
    out

f_left(int endMs) =>
    int ms = math.max(0, endMs - timenow)
    int d = int(ms / 86400000)
    int h = int((ms % 86400000) / 3600000)
    int m = int((ms % 3600000) / 60000)
    d > 0 ? str.tostring(d) + "d " + str.tostring(h) + "h" : h > 0 ? str.tostring(h) + "h " + str.tostring(m) + "m" : str.tostring(m) + "m"

var array<box>   boxes  = array.new<box>()
var array<line>  lines  = array.new<line>()
var array<label> labels = array.new<label>()

// One candle at x (left edge). Returns nothing; drawings go into the arrays.
f_candle(int x, float o, float h, float l, float c) =>
    if not na(o) and not na(c) and not na(h) and not na(l)
        bool  up  = c >= o
        float top = math.max(o, c)
        float bot = math.min(o, c)
        int   xc  = x + int(width / 2)
        lines.push(line.new(xc, h, xc, top, color=cWick, width=1))
        lines.push(line.new(xc, bot, xc, l, color=cWick, width=1))
        boxes.push(box.new(x, top, x + width, bot, border_color=up ? cUpB : cDnB, border_width=1, bgcolor=up ? cUp : cDn))
        if showMid
            lines.push(line.new(x, (h + l) / 2, x + width, (h + l) / 2, color=color.new(cWick, 40), style=line.style_dotted))
        if showHL
            labels.push(label.new(xc, h, str.tostring(h, format.mintick), style=label.style_label_down, color=color.new(#10171E, 100), textcolor=cWick, size=size.tiny))
            labels.push(label.new(xc, l, str.tostring(l, format.mintick), style=label.style_label_up, color=color.new(#10171E, 100), textcolor=cWick, size=size.tiny))

// A block: the previous candles (oldest first) then the current one on the right.
f_block(int x0, string tf, int endMs, int count,
         float o0, float h0, float l0, float c0, float o1, float h1, float l1, float c1,
         float o2, float h2, float l2, float c2, float o3, float h3, float l3, float c3,
         float o4, float h4, float l4, float c4, float o5, float h5, float l5, float c5,
         float o6, float h6, float l6, float c6) =>
    int step = width + gap
    int x = x0
    if count >= 7
        f_candle(x, o6, h6, l6, c6)
        x += step
    if count >= 6
        f_candle(x, o5, h5, l5, c5)
        x += step
    if count >= 5
        f_candle(x, o4, h4, l4, c4)
        x += step
    if count >= 4
        f_candle(x, o3, h3, l3, c3)
        x += step
    if count >= 3
        f_candle(x, o2, h2, l2, c2)
        x += step
    if count >= 2
        f_candle(x, o1, h1, l1, c1)
        x += step
    f_candle(x, o0, h0, l0, c0)
    int xm = int((x0 + x + width) / 2)         // middle of the whole block: timeframe label above, time left below
    float hi = math.max(h0, count >= 2 ? h1 : h0, count >= 3 ? h2 : h0, count >= 4 ? h3 : h0, count >= 5 ? h4 : h0, count >= 6 ? h5 : h0, count >= 7 ? h6 : h0)
    float lo = math.min(l0, count >= 2 ? l1 : l0, count >= 3 ? l2 : l0, count >= 4 ? l3 : l0, count >= 5 ? l4 : l0, count >= 6 ? l5 : l0, count >= 7 ? l6 : l0)
    if showTf and not na(hi)
        labels.push(label.new(xm, hi, f_tfText(tf), style=label.style_label_down, color=color.new(#10171E, 100), textcolor=cWick, size=size.normal))
    if showLeft and not na(lo)
        labels.push(label.new(xm, lo, f_left(endMs) + " left", style=label.style_label_up, color=color.new(#10171E, 100), textcolor=color.new(cWick, 30), size=size.small))
    [x + width, hi, lo]

f_mx(float a, float b) => na(a) ? b : na(b) ? a : math.max(a, b)
f_mn(float a, float b) => na(a) ? b : na(b) ? a : math.min(a, b)

// ===========================================================================
// Drawing, on the last bar only
// ===========================================================================
if barstate.islast
    for b in boxes
        b.delete()
    boxes.clear()
    for ln in lines
        ln.delete()
    lines.clear()
    for lb in labels
        lb.delete()
    labels.clear()
    int x = bar_index + offset
    float hiAll = na
    float loAll = na
    bool drawn = false
    array<int> seps = array.new<int>()
    if ok1
        [endX, h1b, l1b] = f_block(x, tf1, aEnd, cnt1, a0o, a0h, a0l, a0c, a1o, a1h, a1l, a1c, a2o, a2h, a2l, a2c, a3o, a3h, a3l, a3c, a4o, a4h, a4l, a4c, a5o, a5h, a5l, a5c, a6o, a6h, a6l, a6c)
        hiAll := f_mx(hiAll, h1b)
        loAll := f_mn(loAll, l1b)
        x := endX + tfGap
        drawn := true
    if ok2
        if drawn
            seps.push(x - int(tfGap / 2))
        [endX2, h2b, l2b] = f_block(x, tf2, bEnd, cnt2, b0o, b0h, b0l, b0c, b1o, b1h, b1l, b1c, b2o, b2h, b2l, b2c, b3o, b3h, b3l, b3c, b4o, b4h, b4l, b4c, b5o, b5h, b5l, b5c, b6o, b6h, b6l, b6c)
        hiAll := f_mx(hiAll, h2b)
        loAll := f_mn(loAll, l2b)
        x := endX2 + tfGap
        drawn := true
    if ok3
        if drawn
            seps.push(x - int(tfGap / 2))
        [endX3, h3b, l3b] = f_block(x, tf3, cEnd, cnt3, c0o, c0h, c0l, c0c, c1o, c1h, c1l, c1c, c2o, c2h, c2l, c2c, c3o, c3h, c3l, c3c, c4o, c4h, c4l, c4c, c5o, c5h, c5l, c5c, c6o, c6h, c6l, c6c)
        hiAll := f_mx(hiAll, h3b)
        loAll := f_mn(loAll, l3b)
    // thin dotted separator between timeframe blocks, spanning the tallest block
    if showSep and not na(hiAll) and not na(loAll)
        for sx in seps
            lines.push(line.new(sx, loAll, sx, hiAll, color=cSep, width=sepW, style=sepStyle == "Solid" ? line.style_solid : sepStyle == "Dashed" ? line.style_dashed : line.style_dotted))

// ===========================================================================
// Signals handed to the stats block. The script draws candles, it does not
// call anything; the one event worth measuring is a Timeframe 1 candle that
// CLOSED beyond the range of the candle before it. It is read on the first
// chart bar of the next candle, when both are final, so nothing repaints.
// ===========================================================================
bool htfNew   = ok1 and timeframe.change(tf1)
bool sigUp  = htfNew and not na(a1c) and not na(a2h) and a1c > a2h
bool sigDn = htfNew and not na(a1c) and not na(a2l) and a1c < a2l

// ===========================================================================
// Quanty Stats - paste from here to the end into the host script
// ===========================================================================
const string G_ST = "4. Quanty Stats"
bool  stOn     = input.bool(true, "Stats table", group=G_ST, inline="st",
     tooltip="Measures this script's own past signals on this chart. History, not a forecast.")
bool  stMini   = input.bool(false, "collapsed (one line)", group=G_ST, inline="st",
     tooltip="Collapsed shows only the headline: signals measured, hit rate and the any-bar baseline.")
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
string stPos   = input.string("Bottom left", "Table position", options=["Top right", "Top left", "Bottom right", "Bottom left"], group=G_ST)

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
        table.cell(stT, 0, 0, "Quanty Stats", text_color=#65E1C6, text_size=size.small, text_halign=text.align_left)
        table.cell(stT, 1, 0, f_stFrac(hits, n) + " moved " + thr + (na(stBase) ? "" : " · any bar " + str.tostring(math.round(100.0 * stBase)) + "%"), text_color=#F2EFE6, text_size=size.small, text_halign=text.align_right)
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
