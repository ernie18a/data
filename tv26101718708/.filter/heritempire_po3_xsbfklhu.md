# HeritEmpire PO3

- url: https://www.tradingview.com/script/xSbFKLhU-HeritEmpire-PO3/
- type: indicator
- pine_id: PUB;93ed2266988e40cfa78589502097985f
- version: 5.0

## Description

[b]HeritEmpire PO3 — Higher-Timeframe Candle Projection[/b]

PO3 draws a compact mini-chart of higher-timeframe candles to the right of live price, so you can read HTF structure without leaving your current chart. Each higher timeframe is rendered as real candle shapes (body + wick), colored by direction, with the rightmost candle in every block being the current, still-developing HTF candle that updates as price moves.

[b]What it does[/b]
For each enabled timeframe, the script requests OHLC data and keeps a rolling buffer of the most recently completed candles. On every new HTF period it captures the just-closed candle's final OHLC and appends it to the buffer, trimming to your chosen count. The block is then redrawn on the last bar: closed candles to the left, the live candle on the right. Because completed candles are only stored after they close, the closed portion of each block does not repaint; only the rightmost (live) candle changes intrabar, exactly as it would on the native chart.

[b]How it works[/b]
[list]
[*]Candle bodies are drawn as boxes between open and close; wicks are lines from low to high.
[*]Data is pulled with request.security using lookahead_off, so no future information is used.
[*]Up to three independent timeframes can be projected side by side, each as its own block.
[/list]

[b]How to use[/b]
Add it to any intraday chart. Read each block like a normal candlestick chart to judge higher-timeframe trend, momentum, and where current price sits relative to recent HTF opens and closes. Useful for keeping multi-timeframe context (for example 1H, 4H and Daily) visible while you work on a lower timeframe.

[b]Settings[/b]
[list]
[*]Timeframes — Three independent slots (TF 1 / TF 2 / TF 3), each with its own on/off toggle and timeframe. Defaults: 1H (off), 4H (on), Daily (off).
[*]Candles to Show — Number of candles per block, from 1 to 10 (default 3 = 2 closed + 1 live).
[*]Offset (bars right) — Distance between live price and the first block.
[*]Gap Between Candles — Spacing between candles inside a block.
[*]Gap Between TF Blocks — Spacing between each timeframe block.
[*]Show TF Label — Displays the timeframe name above each block.
[*]Show Open Line — Extends each live candle's open across the chart as a reference level.
[*]Colors — Separate bullish/bearish colors for body, borders, and wicks.
[/list]

[b]Notes[/b]
This is a visualization tool, not a signal or strategy. It does not generate buy/sell alerts and makes no performance claims — it simply mirrors higher-timeframe candles next to your chart for context.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeritK

//@version=6
indicator("HeritEmpire PO3", "HeritEmpire PO3 [v1.0.3]", overlay=true, max_boxes_count=50, max_lines_count=50, max_labels_count=100)

import n00btraders/Timezone/1 as tz

// --- Constants ---
const color BULL_COLOR    = #089981
const color BEAR_COLOR    = #f23645
const int   CANDLE_HALF   = 2          // body half-width in bars (full width = 2x)

// --- Input Groups ---
const string GRP_HTF  = "Timeframes"
const string GRP_PROJ = "Projection"
const string GRP_COL  = "Styling"
const string GRP_VIS  = "Visual Toggles"

// --- Timeframe Slots (toggle + timeframe per row) ---
bool   en1  = input.bool(false, "TF 1", inline="tf1", group=GRP_HTF)
string tf1  = input.timeframe("60",  "", inline="tf1", group=GRP_HTF)
int    cnt1 = input.int(3, "Candles", inline="tf1", group=GRP_HTF, minval=1, maxval=10)
bool   en2  = input.bool(true,  "TF 2", inline="tf2", group=GRP_HTF)
string tf2  = input.timeframe("240", "", inline="tf2", group=GRP_HTF)
int    cnt2 = input.int(3, "Candles", inline="tf2", group=GRP_HTF, minval=1, maxval=10)
bool   en3  = input.bool(false, "TF 3", inline="tf3", group=GRP_HTF)
string tf3  = input.timeframe("D",   "", inline="tf3", group=GRP_HTF)
int    cnt3 = input.int(3, "Candles", inline="tf3", group=GRP_HTF, minval=1, maxval=10)
tzIn        = input.enum(tz.TimezoneID.NEW_YORK, "Timezone", group=GRP_HTF,
     tooltip="Timezone the candle timestamps are printed in, on intraday and weekly slots. " +
     "Daily and monthly stamps are session dates, not clock times, so they always print in UTC.")
string labelTz = tz.tostring(tzIn)

// --- Projection Inputs ---
int    offset    = input.int(15, "Offset (bars right)", minval=0, group=GRP_PROJ,
     tooltip="Gap in bars between live price and the first projection block.")
int    gap       = input.int(2, "Gap Between Candles (bars)", minval=0, group=GRP_PROJ)
int    blockGap  = input.int(10, "Gap Between TF Blocks (bars)", minval=0, group=GRP_PROJ)

// --- Visual Toggles (label rows are toggle + color + font size) ---
color textColor = color.new(chart.fg_color, 15)
const string SZ_TINY  = "Tiny"
const string SZ_SMALL = "Small"
const string SZ_NORM  = "Normal"
const string SZ_LARGE = "Large"
const string SZ_HUGE  = "Huge"
bool   showTfLabel  = input.bool(true,       "TF Label",    inline="tflab", group=GRP_VIS)
string tfLabSzIn    = input.string(SZ_SMALL,  "",           inline="tflab", group=GRP_VIS,
     options=[SZ_TINY, SZ_SMALL, SZ_NORM, SZ_LARGE, SZ_HUGE])
bool   showStamp    = input.bool(true,        "Timestamp",   inline="stamp", group=GRP_VIS)
string stampSzIn    = input.string(SZ_SMALL,   "",           inline="stamp", group=GRP_VIS,
     options=[SZ_TINY, SZ_SMALL, SZ_NORM, SZ_LARGE, SZ_HUGE],
     tooltip="Open time of each projected candle, printed below it.")
bool   showOpenLine = input.bool(false,      "Open Line",   inline="opln",  group=GRP_VIS)

toSize(string s) =>
    switch s
        SZ_TINY  => size.tiny
        SZ_SMALL => size.small
        SZ_NORM  => size.normal
        SZ_LARGE => size.large
        =>          size.huge

string tfLabSize = toSize(tfLabSzIn)
string stampSize = toSize(stampSzIn)

// --- Styling (bull swatch, bear swatch per row) ---
color  bodyBull = input.color(BULL_COLOR, "Body",    inline="body",   group=GRP_COL)
color  bodyBear = input.color(BEAR_COLOR, "",        inline="body",   group=GRP_COL)
color  bordBull = input.color(BULL_COLOR, "Borders", inline="border", group=GRP_COL)
color  bordBear = input.color(BEAR_COLOR, "",        inline="border", group=GRP_COL)
color  wickBull = input.color(BULL_COLOR, "Wick",    inline="wick",   group=GRP_COL)
color  wickBear = input.color(BEAR_COLOR, "",        inline="wick",   group=GRP_COL)

// --- HTF Data ---
// Two clocks per bar: `time` is the bar's open instant, `time_tradingday` is 00:00 UTC of a
// session day — the bar's own day on 1D, but the period's LAST trading day on anything longer.
// Daily needs the tradingday clock (a gold/FX session opens 17:00 the previous calendar day,
// so the open instant would label the Friday candle "Thu"), and monthly needs it too (the same
// session roll puts a month's open instant in the previous month). Weekly must use the open
// instant instead, or the stamp dates the end of the week rather than its start.
[o1, h1, l1, c1, t1, d1] = request.security(syminfo.tickerid, tf1, [open, high, low, close, time, time_tradingday], lookahead=barmerge.lookahead_off)
[o2, h2, l2, c2, t2, d2] = request.security(syminfo.tickerid, tf2, [open, high, low, close, time, time_tradingday], lookahead=barmerge.lookahead_off)
[o3, h3, l3, c3, t3, d3] = request.security(syminfo.tickerid, tf3, [open, high, low, close, time, time_tradingday], lookahead=barmerge.lookahead_off)

int secs1 = timeframe.in_seconds(tf1)
int secs2 = timeframe.in_seconds(tf2)
int secs3 = timeframe.in_seconds(tf3)

useTradingDay(int secs) => secs == 86400 or secs >= 2592000

int ts1 = useTradingDay(secs1) ? d1 : t1
int ts2 = useTradingDay(secs2) ? d2 : t2
int ts3 = useTradingDay(secs3) ? d3 : t3

// --- Rolling buffer of completed candles per timeframe ---
type HtfBuf
    array<float> o
    array<float> h
    array<float> l
    array<float> c
    array<int>   t

newBuf() =>
    HtfBuf.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<int>())

var HtfBuf b1 = newBuf()
var HtfBuf b2 = newBuf()
var HtfBuf b3 = newBuf()

// On a new HTF period, the previous candle just completed: capture its final OHLC.
capture(HtfBuf b, bool changed, float fo, float fh, float fl, float fc, int ft, int count) =>
    if changed
        b.o.push(fo)
        b.h.push(fh)
        b.l.push(fl)
        b.c.push(fc)
        b.t.push(ft)
        while b.o.size() > count
            b.o.shift()
            b.h.shift()
            b.l.shift()
            b.c.shift()
            b.t.shift()

bool ch1 = timeframe.change(tf1)
bool ch2 = timeframe.change(tf2)
bool ch3 = timeframe.change(tf3)

capture(b1, ch1, o1[1], h1[1], l1[1], c1[1], ts1[1], cnt1)
capture(b2, ch2, o2[1], h2[1], l2[1], c2[1], ts2[1], cnt2)
capture(b3, ch3, o3[1], h3[1], l3[1], c3[1], ts3[1], cnt3)

// Chart bar on which the live HTF candle opened — anchors that candle's open line.
openBar(bool changed) =>
    var int ob = bar_index
    if changed
        ob := bar_index
    ob

int ob1 = openBar(ch1)
int ob2 = openBar(ch2)
int ob3 = openBar(ch3)

// --- Pretty timeframe label ---
prettyTf(string tf) =>
    float mins = str.tonumber(tf)
    na(mins) ? (tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf) :
         mins >= 60 and mins % 60 == 0 ? str.tostring(mins / 60) + "H" : str.tostring(mins) + "m"

// --- Timestamp format and rendering zone, chosen once per timeframe from its length ---
// Zone follows the clock the stamp was built from, not the format. Intraday and weekly stamp
// a real open instant, so they honour the user's timezone and shift with the dropdown. Daily
// and monthly stamp `time_tradingday`, which is a date pinned to 00:00 UTC rather than a
// moment — rendering it anywhere west of UTC lands on the previous evening and rolls the date
// back a day, so those two are locked to UTC and ignore the dropdown by design.
stampSpec(int secs) =>
    string fmt  = "HH:mm"
    string zone = labelTz
    if secs >= 2592000            // monthly — the day within the month is meaningless
        fmt  := "MMM"
        zone := "UTC"
    else if secs > 86400          // weekly — dated by the day the week opened, in local terms
        fmt  := "dd MMM"
    else if secs == 86400
        fmt  := "EEE dd"
        zone := "UTC"
    [fmt, zone]

[fmt1, zone1] = stampSpec(secs1)
[fmt2, zone2] = stampSpec(secs2)
[fmt3, zone3] = stampSpec(secs3)

// --- Drawing objects (persist so we can delete/redraw) ---
var array<box>   boxes   = array.new<box>()
var array<line>  wicks   = array.new<line>()
var array<label> tfLabs  = array.new<label>()
var array<line>  opLines = array.new<line>()
var array<label> stamps  = array.new<label>()

// Draw one timeframe block starting at center bar `startMid`; returns the start for the next block.
drawBlock(HtfBuf b, float lo, float lh, float ll, float lc, int lt, string tf, string fmt, string zone, int startMid, int count, int openBarIdx) =>
    array<float> dO = array.new<float>()
    array<float> dH = array.new<float>()
    array<float> dL = array.new<float>()
    array<float> dC = array.new<float>()
    array<int>   dT = array.new<int>()

    int nDone    = b.o.size()
    int wantDone = int(math.min(count - 1, nDone))
    // count == 1 means live candle only — skip the loop, since `for a to b` counts
    // backwards when a > b and would read past the end of the buffer.
    if wantDone > 0
        for i = nDone - wantDone to nDone - 1
            dO.push(b.o.get(i))
            dH.push(b.h.get(i))
            dL.push(b.l.get(i))
            dC.push(b.c.get(i))
            dT.push(b.t.get(i))
    // Rightmost column is always the live developing candle
    dO.push(lo)
    dH.push(lh)
    dL.push(ll)
    dC.push(lc)
    dT.push(lt)

    int nDisp = dO.size()
    int pitch = 2 * CANDLE_HALF + gap
    for k = 0 to nDisp - 1
        float o = dO.get(k)
        float h = dH.get(k)
        float l = dL.get(k)
        float c = dC.get(k)
        bool  up      = c >= o
        color bodyCol = up ? bodyBull : bodyBear
        color bordCol = up ? bordBull : bordBear
        color wickCol = up ? wickBull : wickBear
        int colMid   = startMid + k * pitch
        boxes.push(box.new(colMid - CANDLE_HALF, math.max(o, c), colMid + CANDLE_HALF, math.min(o, c),
             border_color=bordCol, border_width=1, bgcolor=bodyCol))
        wicks.push(line.new(colMid, l, colMid, h, color=wickCol, width=1))
        // Open time below the candle
        if showStamp
            stamps.push(label.new(colMid, l, str.format_time(dT.get(k), fmt, zone),
                 style=label.style_label_up, color=color.new(color.gray, 100),
                 textcolor=textColor, size=stampSize))

    // Timeframe label above the block
    if showTfLabel
        int labX = startMid + ((nDisp - 1) * pitch) / 2
        tfLabs.push(label.new(labX, dH.max(), prettyTf(tf), style=label.style_label_down,
             color=color.new(color.gray, 100), textcolor=textColor, size=tfLabSize))

    // Live candle open line, anchored where this timeframe's candle actually opened
    if showOpenLine
        int liveMid = startMid + (nDisp - 1) * pitch
        opLines.push(line.new(openBarIdx, lo, liveMid, lo,
             color=textColor, style=line.style_dotted, width=1))

    // Next block starts past this one's right edge plus the block gap
    startMid + (nDisp - 1) * pitch + 2 * CANDLE_HALF + blockGap

if barstate.islast
    // Clear previous frame
    for x in boxes
        box.delete(x)
    boxes.clear()
    for x in wicks
        line.delete(x)
    wicks.clear()
    for x in tfLabs
        label.delete(x)
    tfLabs.clear()
    for x in opLines
        line.delete(x)
    opLines.clear()
    for x in stamps
        label.delete(x)
    stamps.clear()

    int cursor = bar_index + offset
    if en1
        cursor := drawBlock(b1, o1, h1, l1, c1, ts1, tf1, fmt1, zone1, cursor, cnt1, ob1)
    if en2
        cursor := drawBlock(b2, o2, h2, l2, c2, ts2, tf2, fmt2, zone2, cursor, cnt2, ob2)
    if en3
        cursor := drawBlock(b3, o3, h3, l3, c3, ts3, tf3, fmt3, zone3, cursor, cnt3, ob3)
````
