# Nambou Sweep Radar: Liquidity Sweeps and Equal Highs/Lows

- url: https://www.tradingview.com/script/fPMyiq6a-Nambou-Sweep-Radar-Liquidity-Sweeps-and-Equal-Highs-Lows/
- type: indicator
- pine_id: PUB;35adc1064ba24b13bcbdf199e3e7f80c
- version: 1.0

## Description

Ever watched price poke above a high, pull everyone in, and then close right back under it? That's a sweep, and I got tired of spotting them by eye. So I built a radar for it 📡

🎯 What it does
Sweep Radar tracks the levels where stops tend to sit: recent swing highs and lows, the previous day's high and low, and the previous week's high and low. Then it watches each one.
When price trades through a level and the bar closes back on the side it came from, that's a sweep, and it gets marked. When a bar closes beyond the level, the level is broken and retired.

👀 What you see on the chart
🔴 Red lines are highs and 🟢 green lines are lows. The thin ones are the previous day and week.
▼ above a bar means a high was swept. ▲ below a bar means a low was swept. A bigger marker means the sweep was deep or came on high volume.
A line turns dashed once it has been swept. It stays on the chart, because a level can be swept more than once.
A broken level becomes a thin grey dotted line that stops at the bar where it broke.
The levels closest to price carry a label with the price, what the level is and how far away it is. If two labels would overlap, one is dropped from the chart and stays in the table.

🧲 Equal highs and lows
When two or more swing levels sit at almost the same price, they are grouped, shaded and named, for example "2 equal highs". Stops tend to pile up behind these, so they are worth seeing at a glance.

💪 How strong was the sweep?
Each sweep gets a short description: shallow, medium or deep (how far price went beyond the level, measured in ATR), plus "high volume" when the bar's volume was well above its 20-bar average. You can tell the indicator to ignore shallow sweeps.

📋 The table
Every live level from the highest to the lowest, with the current price slotted in between. For each one: what it is, whether it is untouched or swept (how many times, how long ago, how strong), and its distance from price.
By default the table moves to whichever right-hand corner the price is not in, so it stays off your candles.

🔔 Alerts
Create an alert on the indicator with "Any alert() function call" and you get a message when a level is swept or broken. Either kind can be switched off in the settings.

⚙️ Settings worth knowing
Pivot left and Pivot right: how many bars on each side make a swing. Higher numbers mean fewer, stronger levels.
"A sweep must close back within this many bars": 1 means the same bar. With 2 or 3, a bar that closes beyond the level still counts as a sweep if one of the next bars closes back.
Previous day and week levels, equal levels, sweep strength, the markers and the table each have their own switch.

⚠️ Worth knowing
The marks do not repaint, but there is a delay: a swing is only confirmed after the "Pivot right" number of bars, so new swing levels show up late. Sweeps and breaks are judged on closed bars only, and so are the alerts.
Previous-day levels show on intraday charts. Previous-week levels show on intraday and daily charts.
On forex and CFDs the volume is tick volume, so "high volume" there means high activity, not traded size.
A sweep describes what price did at a level. It does not tell you what happens next, and plenty of sweeps are followed by a clean break on the next try.

This is a charting tool, not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nambou_Signals
//@version=6
indicator("Nambou Sweep Radar", "Sweep Radar", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100, max_bars_back = 1000)

gP = "Swing levels"
lenL = input.int(8, "Pivot left",  minval = 1, group = gP)
lenR = input.int(8, "Pivot right", minval = 1, group = gP)
maxN = input.int(6, "Max swing levels tracked per side", minval = 1, maxval = 25, group = gP)
winN = input.int(1, "A sweep must close back within this many bars", minval = 1, maxval = 5, group = gP, tooltip = "1 means the same bar: price trades through the level and that bar closes back on the original side. With 2 or more, a bar that closes beyond the level still counts as a sweep if one of the next bars closes back in time.")

gK = "Previous day and week"
showDay  = input.bool(true, "Track the previous day's high and low", group = gK, tooltip = "Shown on intraday charts only.")
showWeek = input.bool(true, "Track the previous week's high and low", group = gK, tooltip = "Shown on intraday and daily charts.")

gE = "Equal highs and lows"
showEq = input.bool(true, "Group swing levels that sit at nearly the same price", group = gE)
eqAtr  = input.float(0.15, "Nearly the same means within this many ATR", minval = 0.01, maxval = 2.0, step = 0.05, group = gE, tooltip = "ATR is the average true range of the last 14 bars.")

gS = "Sweep strength"
showStr = input.bool(true, "Describe each sweep: how deep, and on what volume", group = gS)
deepAt  = input.float(0.75, "A sweep is deep from this many ATR beyond the level", minval = 0.3, maxval = 5.0, step = 0.05, group = gS, tooltip = "Below 0.25 ATR a sweep is called shallow, from this value it is called deep, and medium in between.")
volMult = input.float(1.5, "High volume means this many times the 20-bar average", minval = 1.0, maxval = 10.0, step = 0.1, group = gS)
minDep  = input.float(0.0, "Do not mark or alert sweeps shallower than this many ATR", minval = 0.0, maxval = 5.0, step = 0.05, group = gS, tooltip = "0 marks every sweep. A sweep that is not marked still shows in the table.")

gD = "Display"
labN       = input.int(3, "Label this many levels on each side of the price", minval = 0, maxval = 10, group = gD, tooltip = "The nearest levels are labelled first. 0 hides the labels. Every level stays in the table. Broken levels are not labelled.")
gapPct     = input.float(4.0, "Level labels: minimum spacing (% of the visible price range)", minval = 0.5, maxval = 20.0, step = 0.5, group = gD, tooltip = "A level whose label would sit closer than this to one already placed gets no label. It stays in the table.")
showMarks  = input.bool(true, "Mark sweeps on the bars", group = gD)
showTable  = input.bool(true, "Show the level table", group = gD)
showGone   = input.bool(false, "List broken levels in the table", group = gD)
tablePosIn = input.string("Auto", "Table position", options = ["Auto", "Top right", "Bottom right", "Bottom left", "Top left"], group = gD, tooltip = "Auto keeps the table on the right, in the corner the price is not in: bottom right while the price is in the upper half of the visible chart, top right otherwise.")
txtSizeIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gD)
offBars    = input.int(3, "Level labels: bars to the right of the last bar", minval = 1, maxval = 50, group = gD)
cHigh = input.color(#FF3D71, "Highs", group = gD)
cLow  = input.color(#00E5A0, "Lows", group = gD)
cGone = input.color(#787B86, "Broken levels", group = gD)
cTxt  = input.color(#D1D4DC, "Neutral text", group = gD)

gA = "Alerts"
aSweep = input.bool(true, "Alert on a sweep", group = gA)
aBreak = input.bool(true, "Alert when a level breaks", group = gA)

txtSize = txtSizeIn == "Tiny" ? size.tiny : txtSizeIn == "Normal" ? size.normal : size.small

type Level
    float  price
    line   ln
    int    x1
    string tag
    int    st  = 0
    int    cnt = 0
    int    ev  = 0
    int    pend
    float  dep
    float  vr

var array<Level> hs = array.new<Level>()
var array<Level> ls = array.new<Level>()
var array<Level> kh = array.new<Level>(2)
var array<Level> kl = array.new<Level>(2)

atr    = ta.atr(14)
volAvg = ta.sma(volume, 20)
vRatio = volAvg > 0 ? volume / volAvg : na
extH   = ta.highest(high, winN)
extL   = ta.lowest(low, winN)

newLevel(float price, int x1, string tag, color c, int w) =>
    Level.new(price, line.new(x1, price, bar_index, price, color = c, width = w, extend = extend.right), x1, tag, 0, 0, bar_index)

track(array<Level> a, float price, color c) =>
    a.push(newLevel(price, bar_index - lenR, "", c, 2))
    while a.size() > maxN
        Level old = a.shift()
        line.delete(old.ln)

setKey(array<Level> a, int slot, float price, string tag, color c) =>
    Level old = a.get(slot)
    if not na(old)
        line.delete(old.ln)
    Level fresh = na
    if not na(price) and bar_index > 0
        fresh := newLevel(price, bar_index - 1, tag, c, 1)
    a.set(slot, fresh)

depthWord(float d) => na(d) ? "" : d < 0.25 ? "shallow" : d < deepAt ? "medium" : "deep"

scan(array<Level> a, bool isHigh, float ext) =>
    bool swept = false
    bool strong = false
    if a.size() > 0
        for i = 0 to a.size() - 1
            Level v = a.get(i)
            if not na(v)
                if v.st != 2
                    float lvl = v.price
                    string what = v.tag != "" ? str.lower(v.tag) : isHigh ? "high" : "low"
                    bool through = isHigh ? high > lvl : low < lvl
                    bool back = isHigh ? close <= lvl : close >= lvl
                    bool isSweep = false
                    bool isBreak = false
                    if na(v.pend)
                        if through
                            if back
                                isSweep := true
                            else if winN <= 1
                                isBreak := true
                            else
                                v.pend := bar_index
                    else
                        if back
                            isSweep := true
                        else if bar_index - v.pend >= winN - 1
                            isBreak := true
                    if isSweep
                        bool again = v.st == 1 and v.ev == bar_index - 1
                        float d = atr > 0 ? math.abs(ext - lvl) / atr : na
                        v.st := 1
                        v.ev := bar_index
                        v.pend := na
                        line.set_style(v.ln, line.style_dashed)
                        if again
                            v.dep := math.max(nz(v.dep), nz(d))
                        else
                            v.cnt += 1
                            v.dep := d
                            v.vr := vRatio
                            if na(d) or d >= minDep
                                swept := true
                                bool big = (not na(d) and d >= deepAt) or (not na(vRatio) and vRatio >= volMult)
                                if big
                                    strong := true
                                if aSweep
                                    alert("Sweep Radar: " + syminfo.ticker + " swept the " + what + " at " + str.tostring(lvl, format.mintick) + " and closed back" + (showStr and depthWord(d) != "" ? " (" + depthWord(d) + ")" : ""), alert.freq_once_per_bar_close)
                    if isBreak
                        v.st := 2
                        v.ev := bar_index
                        v.pend := na
                        line.set_color(v.ln, cGone)
                        line.set_style(v.ln, line.style_dotted)
                        line.set_width(v.ln, 1)
                        line.set_extend(v.ln, extend.none)
                        line.set_x2(v.ln, bar_index)
                        if aBreak
                            alert("Sweep Radar: " + syminfo.ticker + " closed beyond the " + what + " at " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar_close)
    [swept, strong]

ph = ta.pivothigh(lenL, lenR)
pl = ta.pivotlow(lenL, lenR)

if not na(ph)
    track(hs, ph, cHigh)
if not na(pl)
    track(ls, pl, cLow)

[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
bool newDay  = timeframe.change("D")
bool newWeek = timeframe.change("W")

if showDay and timeframe.isintraday and newDay
    setKey(kh, 0, pdh, "Prev day high", cHigh)
    setKey(kl, 0, pdl, "Prev day low", cLow)
if showWeek and (timeframe.isintraday or timeframe.isdaily) and newWeek
    setKey(kh, 1, pwh, "Prev week high", cHigh)
    setKey(kl, 1, pwl, "Prev week low", cLow)

bool hiSwept  = false
bool loSwept  = false
bool hiStrong = false
bool loStrong = false

if barstate.isconfirmed
    [a1, b1] = scan(hs, true, extH)
    [a2, b2] = scan(kh, true, extH)
    [a3, b3] = scan(ls, false, extL)
    [a4, b4] = scan(kl, false, extL)
    hiSwept  := a1 or a2
    hiStrong := b1 or b2
    loSwept  := a3 or a4
    loStrong := b3 or b4

if showMarks
    if hiSwept
        label.new(bar_index, high, "▼", yloc = yloc.abovebar, style = label.style_none, textcolor = cHigh, size = hiStrong ? size.large : size.normal)
    if loSwept
        label.new(bar_index, low, "▲", yloc = yloc.belowbar, style = label.style_none, textcolor = cLow, size = loStrong ? size.large : size.normal)

times(int n) => n == 1 ? "once" : n == 2 ? "twice" : str.tostring(n) + " times"
ago(int b) => b <= 0 ? "on this bar" : b == 1 ? "1 bar ago" : str.tostring(b) + " bars ago"

strength(Level v) =>
    string s = ""
    if showStr and not na(v.dep)
        s := depthWord(v.dep)
        if not na(v.vr) and v.vr >= volMult
            s += ", high volume"
    s

stateText(Level v) =>
    int b = bar_index - v.ev
    string s = strength(v)
    v.st == 0 ? "untouched" : v.st == 1 ? "swept " + times(v.cnt) + ", last " + ago(b) + (s != "" ? " (" + s + ")" : "") : "broken " + ago(b)

eqCount(Level v, array<Level> peers, float tol) =>
    int n = 0
    if showEq and v.tag == "" and v.st != 2 and peers.size() > 0
        for i = 0 to peers.size() - 1
            Level o = peers.get(i)
            if o.st != 2 and math.abs(o.price - v.price) <= tol
                n += 1
    n

var array<label> tags  = array.new_label()
var array<box>   bands = array.new_box()

tag(float price, string txt, color c) =>
    array.push(tags, label.new(bar_index + offBars, price, txt, style = label.style_label_left, color = chart.bg_color, textcolor = c, size = txtSize, textalign = text.align_left))

band(Level v, array<Level> peers, float tol, color c) =>
    float top = v.price
    float bot = v.price
    int left = v.x1
    bool isTop = true
    for i = 0 to peers.size() - 1
        Level o = peers.get(i)
        if o.st != 2 and math.abs(o.price - v.price) <= tol
            if o.price > v.price or (o.price == v.price and o.x1 < v.x1)
                isTop := false
            top := math.max(top, o.price)
            bot := math.min(bot, o.price)
            left := math.min(left, o.x1)
    if isTop
        array.push(bands, box.new(left, top, bar_index, bot, border_color = na, bgcolor = color.new(c, 82), extend = extend.right))

tPos = switch tablePosIn
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    "Top left"     => position.top_left
    => position.top_right

var table ladder = table.new(tPos, 4, 60, bgcolor = color.new(#131722, 10), border_color = color.new(#787B86, 85), border_width = 1, frame_color = color.new(#787B86, 60), frame_width = 1)

cell(int c, int r, string v, color col) =>
    table.cell(ladder, c, r, v, text_color = col, text_halign = c == 0 or c == 3 ? text.align_right : text.align_left, text_size = txtSize)

pctFrom(float p) => (p >= close ? "+" : "") + str.tostring((p - close) / close * 100.0, "0.00") + "%"

priceRow(int r) =>
    cell(0, r, str.tostring(close, format.mintick), cTxt)
    cell(1, r, "◀ price now", cTxt)
    cell(2, r, "", cTxt)
    cell(3, r, "", cTxt)

if barstate.islast
    for t in tags
        label.delete(t)
    array.clear(tags)
    for b in bands
        box.delete(b)
    array.clear(bands)
    table.clear(ladder, 0, 0, 3, 59)

    float vHi = high
    float vLo = low
    int vj = 0
    while vj < 999 and time[vj] >= chart.left_visible_bar_time
        vHi := math.max(vHi, high[vj])
        vLo := math.min(vLo, low[vj])
        vj += 1
    if tablePosIn == "Auto"
        table.set_position(ladder, close > (vHi + vLo) / 2.0 ? position.bottom_right : position.top_right)

    float tol = nz(atr) * eqAtr

    px = array.new_float()
    nm = array.new_string()
    sx = array.new_string()
    sw = array.new_string()
    cl = array.new_color()
    lv = array.new_bool()
    hi = array.new_bool()

    for side = 0 to 1
        bool isHigh = side == 0
        color sc = isHigh ? cHigh : cLow
        array<Level> swings = isHigh ? hs : ls
        array<Level> keys = isHigh ? kh : kl
        for part = 0 to 1
            array<Level> a = part == 0 ? keys : swings
            if a.size() > 0
                for i = 0 to a.size() - 1
                    Level v = a.get(i)
                    if not na(v)
                        int dup = -1
                        if array.size(px) > 0
                            for q = 0 to array.size(px) - 1
                                if array.get(hi, q) == isHigh and math.abs(array.get(px, q) - v.price) < syminfo.mintick / 2.0
                                    dup := q
                        if dup >= 0
                            if part == 0
                                array.set(nm, dup, "Prev day and week " + (isHigh ? "high" : "low"))
                        else
                            int g = part == 1 ? eqCount(v, swings, tol) : 0
                            string name = v.tag != "" ? v.tag : g >= 2 ? str.tostring(g) + " equal " + (isHigh ? "highs" : "lows") : isHigh ? "High" : "Low"
                            if g >= 2
                                band(v, swings, tol, sc)
                            array.push(px, v.price)
                            array.push(nm, name)
                            array.push(sx, stateText(v))
                            array.push(sw, v.st == 1 ? ", swept " + times(v.cnt) : "")
                            array.push(cl, v.st == 2 ? cGone : sc)
                            array.push(lv, v.st != 2)
                            array.push(hi, isHigh)

    int n = array.size(px)
    if n > 0
        idx = array.sort_indices(px, order.descending)

        if labN > 0
            float gap = (vHi - vLo) * gapPct / 100.0
            dist = array.new_float()
            for k = 0 to n - 1
                array.push(dist, math.abs(array.get(px, k) - close))
            near = array.sort_indices(dist, order.ascending)
            placed = array.new_float()
            int nUp = 0
            int nDn = 0
            for k = 0 to n - 1
                i = array.get(near, k)
                pi = array.get(px, i)
                bool isUp = pi > close
                bool room = isUp ? nUp < labN : nDn < labN
                bool clear = array.get(lv, i)
                if array.size(placed) > 0
                    for q = 0 to array.size(placed) - 1
                        if math.abs(array.get(placed, q) - pi) < gap
                            clear := false
                if room and clear
                    tag(pi, str.tostring(pi, format.mintick) + "  " + array.get(nm, i) + array.get(sw, i) + "  " + pctFrom(pi), array.get(cl, i))
                    array.push(placed, pi)
                    if isUp
                        nUp += 1
                    else
                        nDn += 1

        if showTable
            int r = 0
            bool priceDone = false
            for k = 0 to n - 1
                i = array.get(idx, k)
                pi = array.get(px, i)
                if not showGone and not array.get(lv, i)
                    continue
                if not priceDone and pi <= close
                    priceRow(r)
                    priceDone := true
                    r += 1
                color c = array.get(cl, i)
                cell(0, r, str.tostring(pi, format.mintick), c)
                cell(1, r, array.get(nm, i), c)
                cell(2, r, array.get(sx, i), c)
                cell(3, r, pctFrom(pi), c)
                r += 1
            if not priceDone
                priceRow(r)
                r += 1
            if showMarks
                table.cell(ladder, 0, r, "▼ ▲  a sweep: price traded through a level and closed back", text_color = color.new(cTxt, 30), text_halign = text.align_left, text_size = txtSize)
                table.merge_cells(ladder, 0, r, 3, r)
````
