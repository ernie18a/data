# KP56 Multi-Symbol Candles

- url: https://www.tradingview.com/script/iIz5tAgf-KP56-Multi-Symbol-Candles/
- type: indicator
- pine_id: PUB;6ee017cfcae241c0b8be2e6612a9b82a
- version: 1.0

## Description

OVERVIEW
This indicator draws mini candle blocks for several symbols and several timeframes in the empty space to the right of the current price, so you can watch related markets without leaving your main chart. It was built for gold traders who want to keep an eye on instruments such as the US Dollar Index or US 10-year yield, but it works with any symbols.

WHAT IT SHOWS
- Up to 5 symbols: the chart's own symbol plus 4 user-selectable symbols, each with its own on/off switch.
- Up to 4 timeframes, each with its own on/off switch.
- Each symbol is one row, each timeframe is one block of candles in that row.
- A label above every block with the symbol, timeframe, and the percent change of the current candle (close vs. open).
- A countdown under every block showing the time left until the current candle of that symbol and timeframe closes.
- An optional summary table with the last price and the current-candle percent change per timeframe for every enabled symbol.

HOW IT WORKS
The script requests open, high, low, close, time and close time for every enabled symbol/timeframe pair with request.security() using lookahead off. Completed higher-timeframe candles are stored as they appear, and the forming candle is updated on every tick. On the last bar the stored candles are drawn with boxes and lines.

The rows are placed inside the price range currently visible on the chart, so the blocks stay on screen when you scroll or zoom. Each block is scaled to its own high-low range to fit its row.

HOW TO USE
1. Add the indicator to your chart and scroll left to leave free space to the right of the last bar.
2. In Inputs, choose the symbols and timeframes and tick the ones you want to see.
3. Adjust the number of candles per block, the distance from the last bar, colors, text size and table position.
4. Candle blocks, countdowns and the table can each be turned off separately.

LIMITATIONS
- Every block uses its own vertical scale. The blocks show candle shape and direction only; their position does not correspond to the chart's price axis and cannot be used to compare price levels between symbols.
- Timeframes lower than the chart timeframe are hidden.
- History is built from the chart's loaded bars, so a high timeframe on a very low chart timeframe may show fewer candles than requested.
- The script only recalculates when the chart symbol receives a tick. The countdown and the other symbols' candles do not update between ticks.
- If another symbol's market is closed, its last candle stays as is and the countdown shows it as closed.
- Data for other symbols depends on your data plan; some feeds may be delayed.

This script is a visual monitoring tool. It does not generate trading signals and is not financial advice.

## Source Code

````pine
//@version=6
indicator("KP56 Multi-Symbol Candles", "KP MultiSym", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100)

// ───────── Inputs ─────────
gS = "Symbols (tick = on)"
onC  = input.bool(true, "Chart symbol", group = gS)
on1  = input.bool(true, "", inline = "s1", group = gS)
sym1 = input.symbol("CAPITALCOM:DXY", "", inline = "s1", group = gS)
on2  = input.bool(true, "", inline = "s2", group = gS)
sym2 = input.symbol("TVC:US10Y", "", inline = "s2", group = gS)
on3  = input.bool(false, "", inline = "s3", group = gS)
sym3 = input.symbol("OANDA:XAGUSD", "", inline = "s3", group = gS)
on4  = input.bool(false, "", inline = "s4", group = gS)
sym4 = input.symbol("CAPITALCOM:US100", "", inline = "s4", group = gS)

gT = "Timeframes (tick = on)"
tOn1 = input.bool(true, "", inline = "t1", group = gT)
tf1  = input.timeframe("15", "", inline = "t1", group = gT)
tOn2 = input.bool(true, "", inline = "t2", group = gT)
tf2  = input.timeframe("60", "", inline = "t2", group = gT)
tOn3 = input.bool(true, "", inline = "t3", group = gT)
tf3  = input.timeframe("240", "", inline = "t3", group = gT)
tOn4 = input.bool(false, "", inline = "t4", group = gT)
tf4  = input.timeframe("1D", "", inline = "t4", group = gT)

gD = "Display"
showCandles = input.bool(true, "Show candle blocks", group = gD)
nC          = input.int(8, "Candles per block", minval = 3, maxval = 15, group = gD)
offs        = input.int(6, "Distance from last bar (bars)", minval = 1, maxval = 100, group = gD)
bullC       = input.color(#26a69a, "Up", inline = "c", group = gD)
bearC       = input.color(#ef5350, "Down", inline = "c", group = gD)
txtSizeIn   = input.string("small", "Text size", options = ["tiny", "small", "normal"], group = gD)
showCd      = input.bool(true, "Show countdown to candle close (under each block)", group = gD)
showTable   = input.bool(true, "Show summary table", group = gD)
tblPosIn    = input.string("top right", "Table position", options = ["top right", "top center", "top left", "middle right", "middle left", "bottom right", "bottom center", "bottom left"], group = gD)

txtSize = txtSizeIn == "tiny" ? size.tiny : txtSizeIn == "normal" ? size.normal : size.small
tblPos = switch tblPosIn
    "top center"    => position.top_center
    "top left"      => position.top_left
    "middle right"  => position.middle_right
    "middle left"   => position.middle_left
    "bottom right"  => position.bottom_right
    "bottom center" => position.bottom_center
    "bottom left"   => position.bottom_left
    => position.top_right

// ───────── Data ─────────
type Candle
    float o
    float h
    float l
    float c
    int   t
    int   tc

// Timeframes lower than the chart timeframe are skipped (candles would be incomplete)
tfUse(string tf, bool on) =>
    on and timeframe.in_seconds(tf) >= timeframe.in_seconds()

u1 = tfUse(tf1, tOn1)
u2 = tfUse(tf2, tOn2)
u3 = tfUse(tf3, tOn3)
u4 = tfUse(tf4, tOn4)

feed(string sym, string tf, bool on) =>
    var array<Candle> a = array.new<Candle>()
    [o, h, l, c, t, tc] = request.security(sym, tf, [open, high, low, close, time, time_close], ignore_invalid_symbol = true)
    if on and not na(t) and not na(c)
        if a.size() == 0
            a.push(Candle.new(o, h, l, c, t, tc))
        else
            Candle k = a.last()
            if k.t != t
                a.push(Candle.new(o, h, l, c, t, tc))
                if a.size() > 20
                    a.shift()
            else
                a.set(a.size() - 1, Candle.new(o, h, l, c, t, tc))
    a

rowFeed(string sym, bool on) =>
    a = feed(sym, tf1, on and u1)
    b = feed(sym, tf2, on and u2)
    c = feed(sym, tf3, on and u3)
    d = feed(sym, tf4, on and u4)
    [a, b, c, d]

symOr(string s) =>
    s == "" ? syminfo.tickerid : s

shortName(string s) =>
    parts = str.split(s, ":")
    parts.last()

// Time left until the current candle closes
cdTxt(int tc) =>
    int ms = tc - timenow
    string r = "closed"
    if not na(tc) and ms > 0
        int sec = int(ms / 1000)
        int dd = int(sec / 86400)
        int hh = int((sec % 86400) / 3600)
        int mm = int((sec % 3600) / 60)
        int ss = sec % 60
        r := (dd > 0 ? str.tostring(dd) + "d " : "") + str.tostring(hh, "00") + ":" + str.tostring(mm, "00") + ":" + str.tostring(ss, "00")
    r

tfTxt(string tf) =>
    s = timeframe.in_seconds(tf)
    s < 3600 ? str.tostring(s / 60, "#") + "m" : s < 86400 ? str.tostring(s / 3600, "#.#") + "h" : s == 86400 ? "D" : s == 604800 ? "W" : tf

s1 = symOr(sym1)
s2 = symOr(sym2)
s3 = symOr(sym3)
s4 = symOr(sym4)

[aC, bC, cC, dC] = rowFeed(syminfo.tickerid, onC)
[a1, b1, c1, d1] = rowFeed(s1, on1)
[a2, b2, c2, d2] = rowFeed(s2, on2)
[a3, b3, c3, d3] = rowFeed(s3, on3)
[a4, b4, c4, d4] = rowFeed(s4, on4)

// ───────── Visible price range (used to place the rows) ─────────
var float vh = na
var float vl = na
if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    vh := na(vh) ? high : math.max(vh, high)
    vl := na(vl) ? low : math.min(vl, low)

// ───────── Layout index ─────────
iC = 0
i1 = iC + (onC ? 1 : 0)
i2 = i1 + (on1 ? 1 : 0)
i3 = i2 + (on2 ? 1 : 0)
i4 = i3 + (on3 ? 1 : 0)
nRows = i4 + (on4 ? 1 : 0)

k1 = 0
k2 = k1 + (u1 ? 1 : 0)
k3 = k2 + (u2 ? 1 : 0)
k4 = k3 + (u3 ? 1 : 0)

var table tbl = table.new(tblPos, 6, 6, bgcolor = color.new(#131722, 15), border_color = color.new(color.gray, 70), border_width = 1, frame_color = color.new(color.gray, 50), frame_width = 1)

// ───────── Drawing ─────────
drawBlock(array<Candle> a, int row, int col, string name, string tf) =>
    int sz = a.size()
    if sz > 0 and not na(vh) and vh > vl
        int n = math.min(sz, nC)
        int from = sz - n
        float gmax = na
        float gmin = na
        for j = from to sz - 1
            Candle k = a.get(j)
            gmax := na(gmax) ? k.h : math.max(gmax, k.h)
            gmin := na(gmin) ? k.l : math.min(gmin, k.l)
        float band = (vh - vl) / nRows
        float top = vh - row * band - band * 0.24
        float bot = vh - (row + 1) * band + band * 0.14
        float span = gmax - gmin
        float mid = (top + bot) / 2
        int x0 = bar_index + offs + col * (nC * 3 + 5)
        for j = from to sz - 1
            Candle k = a.get(j)
            float yo = span > 0 ? bot + (k.o - gmin) / span * (top - bot) : mid
            float yh = span > 0 ? bot + (k.h - gmin) / span * (top - bot) : mid
            float yl = span > 0 ? bot + (k.l - gmin) / span * (top - bot) : mid
            float yc = span > 0 ? bot + (k.c - gmin) / span * (top - bot) : mid
            color cc = k.c >= k.o ? bullC : bearC
            int x = x0 + (j - from) * 3
            line.new(x + 1, yh, x + 1, yl, color = cc)
            box.new(x, math.max(yo, yc), x + 2, math.min(yo, yc), border_color = cc, bgcolor = cc)
        Candle cur = a.last()
        float pct = (cur.c - cur.o) / cur.o * 100
        string txt = name + " " + tfTxt(tf) + "  " + (pct >= 0 ? "▲ +" : "▼ ") + str.tostring(pct, "0.00") + "%"
        label.new(x0, vh - row * band - band * 0.10, txt, style = label.style_label_left, color = color.new(color.white, 100), textcolor = pct >= 0 ? bullC : bearC, size = txtSize)
        if showCd
            label.new(x0, vh - (row + 1) * band + band * 0.06, "⏱ " + cdTxt(cur.tc), style = label.style_label_left, color = color.new(color.white, 100), textcolor = color.gray, size = txtSize)
    0

tblCell(array<Candle> a, int col, int row) =>
    if a.size() > 0
        Candle cur = a.last()
        float pct = (cur.c - cur.o) / cur.o * 100
        table.cell(tbl, col, row, (pct >= 0 ? "▲ +" : "▼ ") + str.tostring(pct, "0.00") + "%", text_color = pct >= 0 ? bullC : bearC, text_size = txtSize)
    else
        table.cell(tbl, col, row, "–", text_color = color.gray, text_size = txtSize)
    0

lastOf(array<Candle> a) =>
    float r = na
    if a.size() > 0
        Candle cur = a.last()
        r := cur.c
    r

drawRow(array<Candle> a, array<Candle> b, array<Candle> c, array<Candle> d, int row, string name) =>
    if showCandles
        if u1
            drawBlock(a, row, k1, name, tf1)
        if u2
            drawBlock(b, row, k2, name, tf2)
        if u3
            drawBlock(c, row, k3, name, tf3)
        if u4
            drawBlock(d, row, k4, name, tf4)
    if showTable
        float lastP = u1 ? lastOf(a) : u2 ? lastOf(b) : u3 ? lastOf(c) : lastOf(d)
        table.cell(tbl, 0, row + 1, name, text_color = color.white, text_size = txtSize, text_halign = text.align_left)
        table.cell(tbl, 1, row + 1, na(lastP) ? "–" : str.tostring(lastP, "#,##0.00#"), text_color = color.white, text_size = txtSize, text_halign = text.align_right)
        if u1
            tblCell(a, 2 + k1, row + 1)
        if u2
            tblCell(b, 2 + k2, row + 1)
        if u3
            tblCell(c, 2 + k3, row + 1)
        if u4
            tblCell(d, 2 + k4, row + 1)
    0

if barstate.islast
    for bx in box.all
        box.delete(bx)
    for ln in line.all
        line.delete(ln)
    for lb in label.all
        label.delete(lb)
    table.clear(tbl, 0, 0, 5, 5)
    table.set_position(tbl, tblPos)

    if nRows > 0
        if showTable
            table.cell(tbl, 0, 0, "Symbol", text_color = color.gray, text_size = txtSize, text_halign = text.align_left)
            table.cell(tbl, 1, 0, "Last", text_color = color.gray, text_size = txtSize)
            if u1
                table.cell(tbl, 2 + k1, 0, tfTxt(tf1), text_color = color.gray, text_size = txtSize)
            if u2
                table.cell(tbl, 2 + k2, 0, tfTxt(tf2), text_color = color.gray, text_size = txtSize)
            if u3
                table.cell(tbl, 2 + k3, 0, tfTxt(tf3), text_color = color.gray, text_size = txtSize)
            if u4
                table.cell(tbl, 2 + k4, 0, tfTxt(tf4), text_color = color.gray, text_size = txtSize)
        if onC
            drawRow(aC, bC, cC, dC, iC, shortName(syminfo.tickerid))
        if on1
            drawRow(a1, b1, c1, d1, i1, shortName(s1))
        if on2
            drawRow(a2, b2, c2, d2, i2, shortName(s2))
        if on3
            drawRow(a3, b3, c3, d3, i3, shortName(s3))
        if on4
            drawRow(a4, b4, c4, d4, i4, shortName(s4))
````
