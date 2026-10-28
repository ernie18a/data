# Nambou FVG Radar: Fair Value Gaps with Live Fill Tracking

- url: https://www.tradingview.com/script/zmA79xxj-Nambou-FVG-Radar-Fair-Value-Gaps-with-Live-Fill-Tracking/
- type: indicator
- pine_id: PUB;7dbb4fa719a1422ba470fabd823d375c
- version: 3.0

## Description

A fair value gap is the hole a fast candle leaves behind: the wicks of the candles on either side don't overlap, so a stretch of price was skipped. Price often comes back to those holes. The question is always the same: how much of the gap is still open, and did it hold? That's what this radar answers 📡

🎯 What it does
FVG Radar finds every gap as it forms and then follows it, bar by bar. It shows how much of each gap price has filled, whether the gap held, and when it finally broke. On top of the gaps from your own chart, it also tracks the gaps from the next timeframe up, the zones most traders treat as the important ones.

👀 What you see on the chart
🟢 Green zones are bullish gaps (price left them going up). 🔴 Red zones are bearish gaps (price left them going down).
The bright part of a zone is what is still open. As price fills a gap, the bright part shrinks and the filled part stays behind as a faint shadow, so you can see at a glance how much of each gap is used up.
Each zone runs past the last candle and carries its own tag, for example "Bearish FVG 39% filled".
A dashed line marks the middle of each gap, as it was when it formed.
A completely filled gap that hasn't been broken stays as a faint dashed outline. A gap that price closes beyond turns grey and stops.
▲ and ▼ mark the first time a gap held: a bar reached it and closed back out on the side it came from.

⏫ Higher-timeframe gaps
The radar also follows gaps from the next timeframe up: 1H gaps on charts below an hour, 4H on 1H, Daily on 4H, Weekly on Daily. They get a thicker border and their own tag ("Bullish 4H FVG"), and they behave exactly like the others. A higher-timeframe gap appears only once its candle has closed, so it never shows up and then disappears. You can pick the timeframe yourself or switch them off.

📋 The table
The open gaps nearest to price, from the highest to the lowest, with the current price slotted in between. For each one: the zone, the type, a fill meter (▰▰▰▰▱▱▱▱▱▱ 39%), how many times it has held, and its distance from price.
By default the table sits in the middle of the chart, at the top or the bottom, wherever the candles leave more room. If it lands on your candles, pick another position in the settings.

🔔 Alerts
Create an alert on the indicator with "Any alert() function call" and you get a message when price first reaches a gap, the first time a gap holds, when a gap is completely filled, and when a bar closes beyond one. An alert for every new gap is there too, off by default. Each kind can be switched on or off in the settings.

⚙️ Settings worth knowing
"Ignore gaps smaller than this many ATR" keeps tiny gaps off the chart (0.3 by default).
"Merge a gap into the one formed just before it" turns a run of gaps from one strong move into a single zone.
"Keep a gap after it is completely filled" decides whether a filled gap stays until it breaks or goes as soon as it is filled.
How many gaps are tracked, how far the zones run past the last bar, the text, the markers and the table all have their own settings.

⚠️ Worth knowing
Everything is judged on closed bars, alerts included, so nothing repaints. A gap is confirmed when its third candle closes.
"Held" means a bar reached the gap and closed back out of it. It describes what price did, not what it will do next, and plenty of gaps that held once are broken on the next visit.
The radar tracks a limited number of gaps per side, newest first, so very old gaps far from price drop off.

This is a charting tool, not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nambou_Signals
//@version=6
indicator("Nambou FVG Radar", "FVG Radar", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

gG = "Gaps"
minAtr     = input.float(0.3, "Ignore gaps smaller than this many ATR", minval = 0.0, maxval = 5.0, step = 0.05, group = gG, tooltip = "ATR is the average true range of the last 14 bars. 0 keeps every gap.")
maxN       = input.int(8, "Max open gaps tracked per side", minval = 1, maxval = 40, group = gG)
mergeOn    = input.bool(true, "Merge a gap into the one formed just before it", group = gG, tooltip = "A strong move can leave a gap on several bars in a row. Merged, they show as one zone.")
keepFilled = input.bool(true, "Keep a gap after it is completely filled", group = gG, tooltip = "On keeps a filled gap until a bar closes beyond its far edge. Off removes it as soon as price reaches that edge.")

gH = "Higher-timeframe gaps"
htfIn = input.string("Auto", "Also track gaps from", options = ["Auto", "Off", "1H", "4H", "Daily", "Weekly"], group = gH, tooltip = "Auto picks the next timeframe up: 1H on charts below one hour, 4H on 1H to 3H, Daily on 4H to 12H, Weekly on Daily. A gap is added when its higher-timeframe bar has closed, so it never repaints.")
maxH  = input.int(4, "Max higher-timeframe gaps tracked per side", minval = 1, maxval = 20, group = gH)

gD = "Display"
extBars    = input.int(25, "Zones run this many bars past the last bar", minval = 1, maxval = 200, group = gD, tooltip = "Higher-timeframe zones run 24 bars further, so their text sits beyond the others.")
showText   = input.bool(true, "Write the gap and how much of it is filled inside each zone", group = gD)
showCE     = input.bool(true, "Show the middle of each gap", group = gD, tooltip = "A dashed line halfway through the gap, as it was when it formed.")
showMarks  = input.bool(true, "Mark the first time each gap holds", group = gD, tooltip = "A gap holds when a bar reaches it and closes back out of it on the side it was approached from. Only the first hold is marked; the table counts them all.")
showTable  = input.bool(true, "Show the gap table", group = gD)
rowsN      = input.int(8, "Table: gaps listed on each side of the price", minval = 1, maxval = 40, group = gD, tooltip = "The nearest gaps above and below the price.")
showGone   = input.bool(false, "List broken and removed gaps in the table", group = gD)
tablePosIn = input.string("Auto", "Table position", options = ["Auto", "Top center", "Bottom center", "Top right", "Bottom right", "Bottom left", "Top left"], group = gD, tooltip = "Auto looks at the left, middle and right of the visible chart and puts the table at the top or the bottom where the candles leave the most room.")
txtSizeIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gD)
cBull = input.color(#00E5A0, "Bullish gaps", group = gD)
cBear = input.color(#FF3D71, "Bearish gaps", group = gD)
cGone = input.color(#787B86, "Broken gaps", group = gD)
cTxt  = input.color(#D1D4DC, "Neutral text", group = gD)

gA = "Alerts"
aNew   = input.bool(false, "Alert when a new gap forms", group = gA)
aEnter = input.bool(true, "Alert when price first reaches a gap", group = gA)
aHold  = input.bool(true, "Alert the first time a gap holds", group = gA, tooltip = "A gap holds when a bar reaches it and closes back out of it on the side it was approached from.")
aFill  = input.bool(true, "Alert when a gap is completely filled", group = gA)
aBreak = input.bool(true, "Alert when a bar closes beyond a gap", group = gA)

txtSize = txtSizeIn == "Tiny" ? size.tiny : txtSizeIn == "Normal" ? size.normal : size.small

type Gap
    float top
    float bot
    float reach
    box   bx
    box   gh
    line  ce
    int   x1
    bool  bull
    int   born
    int   st     = 0
    int   ev     = 0
    int   holds  = 0
    bool  inside = false
    int   touch  = -2
    bool  heldVisit = false
    string tf = ""

var array<Gap> bulls = array.new<Gap>()
var array<Gap> bears = array.new<Gap>()
var array<Gap> gone  = array.new<Gap>()
var array<Gap> hBulls = array.new<Gap>()
var array<Gap> hBears = array.new<Gap>()

atr = ta.atr(14)

col(Gap g) => g.bull ? cBull : cBear

zoneText(Gap g) => str.tostring(g.bot, format.mintick) + " to " + str.tostring(g.top, format.mintick)

kind(Gap g) => (g.bull ? "bullish " : "bearish ") + (g.tf != "" ? g.tf + " " : "") + "gap"

fillPct(Gap g) =>
    float h = g.top - g.bot
    h <= 0 ? 0.0 : g.bull ? (g.top - math.max(g.reach, g.bot)) / h * 100.0 : (math.min(g.reach, g.top) - g.bot) / h * 100.0

paint(Gap g) =>
    color c = col(g)
    if g.st == 2
        box.set_top(g.bx, g.top)
        box.set_bottom(g.bx, g.bot)
        box.set_bgcolor(g.bx, color.new(c, 90))
        box.set_border_color(g.bx, color.new(c, 45))
        box.set_border_style(g.bx, line.style_dashed)
        box.set_bgcolor(g.gh, color.new(c, 100))
        box.set_border_color(g.gh, color.new(c, 100))
    else
        float edge = g.bull ? math.max(g.reach, g.bot) : math.min(g.reach, g.top)
        box.set_top(g.bx, g.bull ? edge : g.top)
        box.set_bottom(g.bx, g.bull ? g.bot : edge)
        box.set_bgcolor(g.bx, color.new(c, 70))
        box.set_border_color(g.bx, color.new(c, 20))
        box.set_border_style(g.bx, line.style_solid)
        box.set_top(g.gh, g.bull ? g.top : edge)
        box.set_bottom(g.gh, g.bull ? edge : g.bot)
        box.set_bgcolor(g.gh, color.new(c, g.st == 1 ? 92 : 100))
        box.set_border_color(g.gh, color.new(c, g.st == 1 ? 70 : 100))

retire(Gap g) =>
    if g.tf == ""
        box.set_right(g.bx, bar_index)
    else
        box.set_right(g.bx, time)
    box.set_top(g.bx, g.top)
    box.set_bottom(g.bx, g.bot)
    box.set_text(g.bx, "")
    box.set_bgcolor(g.bx, color.new(cGone, 90))
    box.set_border_color(g.bx, color.new(cGone, 60))
    box.set_border_style(g.bx, line.style_dotted)
    box.delete(g.gh)
    if not na(g.ce)
        line.delete(g.ce)
    gone.push(g)
    while gone.size() > maxN * 2
        Gap old = gone.shift()
        box.delete(old.bx)

drop(Gap g) =>
    box.delete(g.bx)
    box.delete(g.gh)
    if not na(g.ce)
        line.delete(g.ce)

add(array<Gap> a, bool bull, float top, float bot, string tf, int lt) =>
    bool merged = false
    if mergeOn and tf == "" and a.size() > 0
        Gap last = a.last()
        if last.st == 0 and bar_index - last.born <= 1 and bot <= last.top and top >= last.bot
            last.top := math.max(last.top, top)
            last.bot := math.min(last.bot, bot)
            last.reach := bull ? last.top : last.bot
            last.born := bar_index
            paint(last)
            if not na(last.ce)
                float m = (last.top + last.bot) / 2.0
                line.set_y1(last.ce, m)
                line.set_y2(last.ce, m)
            merged := true
    if not merged
        color c = bull ? cBull : cBear
        float m = (top + bot) / 2.0
        bool hi = tf != ""
        int x0 = hi ? lt : bar_index - 1
        int x9 = hi ? time : bar_index
        string xl = hi ? xloc.bar_time : xloc.bar_index
        box b = box.new(x0, top, x9, bot, border_color = color.new(c, 20), border_width = hi ? 2 : 1, bgcolor = color.new(c, 70), text_halign = text.align_right, text_valign = text.align_center, text_size = txtSize, xloc = xl)
        box gb = box.new(x0, top, x9, top, border_color = color.new(c, 100), bgcolor = color.new(c, 100), xloc = xl)
        line l = showCE ? line.new(x0, m, x9, m, color = color.new(c, 40), style = line.style_dashed, width = 1, xloc = xl) : na
        Gap g = Gap.new(top, bot, bull ? top : bot, b, gb, l, x0, bull, bar_index)
        g.tf := tf
        a.push(g)
        while a.size() > (hi ? maxH : maxN)
            drop(a.shift())
        if aNew
            alert("FVG Radar: " + syminfo.ticker + " formed a " + (bull ? "bullish " : "bearish ") + (hi ? tf + " " : "") + "gap, " + str.tostring(bot, format.mintick) + " to " + str.tostring(top, format.mintick), alert.freq_once_per_bar_close)

scan(array<Gap> a) =>
    bool held = false
    int i = 0
    while i < a.size()
        Gap g = a.get(i)
        bool removed = false
        if g.born < bar_index
            bool reached = g.bull ? low <= g.top : high >= g.bot
            if reached
                g.reach := g.bull ? math.min(g.reach, low) : math.max(g.reach, high)
                if bar_index - g.touch > 1
                    g.heldVisit := false
                g.touch := bar_index
                if not g.inside
                    g.inside := true
                    if aEnter
                        alert("FVG Radar: " + syminfo.ticker + " reached the " + kind(g) + " at " + zoneText(g), alert.freq_once_per_bar_close)
                bool broke = g.bull ? close < g.bot : close > g.top
                bool full = g.bull ? low <= g.bot : high >= g.top
                if broke
                    g.st := 3
                    g.ev := bar_index
                    retire(g)
                    a.remove(i)
                    removed := true
                    if aBreak
                        alert("FVG Radar: " + syminfo.ticker + " closed beyond the " + kind(g) + " at " + zoneText(g), alert.freq_once_per_bar_close)
                else
                    if full and g.st < 2
                        g.st := 2
                        g.ev := bar_index
                        if aFill
                            alert("FVG Radar: " + syminfo.ticker + " completely filled the " + kind(g) + " at " + zoneText(g), alert.freq_once_per_bar_close)
                        if not keepFilled
                            retire(g)
                            a.remove(i)
                            removed := true
                    else if g.st == 0
                        g.st := 1
                        g.ev := bar_index
                    bool closedOut = g.bull ? close > g.top : close < g.bot
                    if closedOut and not g.heldVisit
                        g.heldVisit := true
                        g.holds += 1
                        if g.holds == 1
                            held := true
                        if aHold and g.holds == 1
                            alert("FVG Radar: " + syminfo.ticker + " reached the " + kind(g) + " at " + zoneText(g) + " and closed back out of it", alert.freq_once_per_bar_close)
                    if not removed
                        paint(g)
        if not removed
            i += 1
    held

tfSec  = timeframe.in_seconds()
autoTf = tfSec < 3600 ? "60" : tfSec < 14400 ? "240" : tfSec < 86400 ? "D" : tfSec < 604800 ? "W" : ""
htf    = htfIn == "Auto" ? autoTf : htfIn == "1H" ? "60" : htfIn == "4H" ? "240" : htfIn == "Daily" ? "D" : htfIn == "Weekly" ? "W" : ""
useH   = htf != "" and timeframe.in_seconds(htf == "" ? timeframe.period : htf) > tfSec
reqTf  = useH ? htf : timeframe.period
htfTag = reqTf == "60" ? "1H" : reqTf == "240" ? "4H" : reqTf == "D" ? "Daily" : reqTf == "W" ? "Weekly" : reqTf
[hH1, hL1, hH3, hL3, hT2] = request.security(syminfo.tickerid, reqTf, [high[1], low[1], high[3], low[3], time[2]], lookahead = barmerge.lookahead_on)
bool hNew = useH and timeframe.change(reqTf)

bool bullHeld = false
bool bearHeld = false

if barstate.isconfirmed and bar_index >= 2
    bool b1 = scan(bulls)
    bool b2 = scan(hBulls)
    bool s1 = scan(bears)
    bool s2 = scan(hBears)
    bullHeld := b1 or b2
    bearHeld := s1 or s2
    float minSize = nz(atr) * minAtr
    if low > high[2] and low - high[2] >= minSize
        add(bulls, true, low, high[2], "", 0)
    if high < low[2] and low[2] - high >= minSize
        add(bears, false, low[2], high, "", 0)

if hNew and not na(hH3)
    float minSize = nz(atr) * minAtr
    if hL1 > hH3 and hL1 - hH3 >= minSize
        add(hBulls, true, hL1, hH3, htfTag, hT2)
    if hH1 < hL3 and hL3 - hH1 >= minSize
        add(hBears, false, hL3, hH1, htfTag, hT2)

if showMarks
    if bullHeld
        label.new(bar_index, low, "", yloc = yloc.belowbar, style = label.style_triangleup, color = cBull, size = size.tiny)
    if bearHeld
        label.new(bar_index, high, "", yloc = yloc.abovebar, style = label.style_triangledown, color = cBear, size = size.tiny)

times(int n) => n == 1 ? "once" : n == 2 ? "twice" : str.tostring(n) + " times"
ago(int b) => b <= 0 ? "on this bar" : b == 1 ? "1 bar ago" : str.tostring(b) + " bars ago"

meter(float pct) =>
    int n = int(math.round(math.max(0.0, math.min(100.0, pct)) / 10.0))
    string s = ""
    for k = 1 to 10
        s += k <= n ? "▰" : "▱"
    s

stateText(Gap g) =>
    string h = g.holds > 0 ? ", held " + times(g.holds) : ""
    g.st == 0 ? meter(0) + "  untouched" : g.st == 1 ? meter(fillPct(g)) + "  " + str.tostring(math.round(fillPct(g))) + "%" + h : g.st == 2 ? meter(100) + "  filled" + h : "broken " + ago(bar_index - g.ev)

zoneTag(Gap g) =>
    (g.bull ? "Bullish " : "Bearish ") + (g.tf != "" ? g.tf + " " : "") + "FVG  " + (g.st == 0 ? "untouched" : g.st == 1 ? str.tostring(math.round(fillPct(g))) + "% filled" : "filled")

distText(Gap g) =>
    close > g.top ? str.tostring((g.top - close) / close * 100.0, "0.00") + "%" : close < g.bot ? "+" + str.tostring((g.bot - close) / close * 100.0, "0.00") + "%" : "inside"

tPos = switch tablePosIn
    "Top center"    => position.top_center
    "Bottom center" => position.bottom_center
    "Top right"    => position.top_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    "Top left"     => position.top_left
    => position.top_right

tblBg = color.new(#131722, 8)

var table ladder = table.new(tPos, 4, 100, border_width = 0, frame_width = 0)

cell(int c, int r, string v, color tc) =>
    table.cell(ladder, c, r, v, text_color = tc, text_halign = c == 0 or c == 3 ? text.align_right : text.align_left, text_size = txtSize, bgcolor = tblBg)

priceRow(int r) =>
    cell(0, r, str.tostring(close, format.mintick), #FFFFFF)
    cell(1, r, "◀ price now", #FFFFFF)
    cell(2, r, "", cTxt)
    cell(3, r, "", cTxt)

stretch(array<Gap> a) =>
    int back = math.min(bar_index, 200)
    for g in a
        int right = g.tf == "" ? bar_index + extBars : time + (extBars + 24) * tfSec * 1000
        int left = g.tf == "" ? math.max(g.x1, bar_index - back) : math.max(g.x1, time[back])
        box.set_left(g.bx, left)
        box.set_left(g.gh, left)
        box.set_right(g.bx, right)
        box.set_right(g.gh, right)
        if not na(g.ce)
            line.set_x1(g.ce, left)
            line.set_x2(g.ce, right)
        box.set_text(g.bx, showText ? zoneTag(g) : "")
        box.set_text_color(g.bx, g.st == 2 ? color.new(col(g), 25) : #FFFFFF)
        box.set_text_size(g.bx, txtSize)
        box.set_text_halign(g.bx, text.align_right)
        box.set_text_valign(g.bx, text.align_center)

if barstate.islast
    stretch(bulls)
    stretch(bears)
    stretch(hBulls)
    stretch(hBears)
    table.clear(ladder, 0, 0, 3, 99)

    float vHi = high
    float vLo = low
    int vj = 0
    while vj < 999 and time[vj] >= chart.left_visible_bar_time
        vHi := math.max(vHi, high[vj])
        vLo := math.min(vLo, low[vj])
        vj += 1
    bool atTop = tablePosIn == "Top center" or tablePosIn == "Top left"
    if tablePosIn == "Auto"
        float span = math.max(vHi - vLo, syminfo.mintick)
        float best = -1.0
        string pick = position.top_center
        for part = 0 to 2
            int a = int(vj * part / 3.0)
            int b = math.max(a, math.min(999, int(vj * (part + 1) / 3.0) - 1))
            float sHi = high[a]
            float sLo = low[a]
            for j = a to b
                sHi := math.max(sHi, high[j])
                sLo := math.min(sLo, low[j])
            float bonus = part == 1 ? 0.03 : 0.0
            float up = (vHi - sHi) / span + bonus
            float dn = (sLo - vLo) / span + bonus
            if up > best
                best := up
                pick := part == 0 ? position.top_right : part == 1 ? position.top_center : position.top_left
            if dn > best
                best := dn
                pick := part == 0 ? position.bottom_right : part == 1 ? position.bottom_center : position.bottom_left
        atTop := pick == position.top_center or pick == position.top_left
        table.set_position(ladder, pick)

    rows = array.new<Gap>()
    for g in bulls
        rows.push(g)
    for g in bears
        rows.push(g)
    for g in hBulls
        rows.push(g)
    for g in hBears
        rows.push(g)
    if showGone
        for g in gone
            rows.push(g)

    int n = rows.size()
    if showTable
        int off = atTop ? 2 : 0
        if off > 0
            for k = 0 to off - 1
                table.cell(ladder, 0, k, " ", text_size = txtSize)
                table.merge_cells(ladder, 0, k, 3, k)
        table.cell(ladder, 0, off, "◆  NAMBOU FVG RADAR", text_color = #FFFFFF, text_halign = text.align_left, text_size = txtSize, bgcolor = tblBg)
        table.merge_cells(ladder, 0, off, 3, off)
        cell(0, off + 1, "Zone", color.new(cTxt, 40))
        cell(1, off + 1, "Gap", color.new(cTxt, 40))
        cell(2, off + 1, "Filled", color.new(cTxt, 40))
        cell(3, off + 1, "Distance", color.new(cTxt, 40))
        int r = off + 2
        bool priceDone = false
        if n > 0
            mids = array.new_float()
            for g in rows
                mids.push((g.top + g.bot) / 2.0)
            idx = array.sort_indices(mids, order.descending)
            int above = 0
            for k = 0 to n - 1
                if mids.get(k) > close
                    above += 1
            for k = 0 to n - 1
                Gap g = rows.get(idx.get(k))
                bool up = mids.get(idx.get(k)) > close
                int rank = up ? above - k : k - above + 1
                if rank > rowsN
                    continue
                if not priceDone and mids.get(idx.get(k)) <= close
                    priceRow(r)
                    priceDone := true
                    r += 1
                color c = g.st == 3 ? cGone : col(g)
                cell(0, r, zoneText(g), c)
                cell(1, r, (g.bull ? "Bullish" : "Bearish") + (g.tf != "" ? " " + g.tf : ""), c)
                cell(2, r, stateText(g), c)
                cell(3, r, distText(g), c)
                r += 1
        if not priceDone
            priceRow(r)
            r += 1
        if showMarks
            table.cell(ladder, 0, r, "▲ ▼  first hold: a bar reached the gap and closed back out", text_color = color.new(cTxt, 30), text_halign = text.align_left, text_size = txtSize, bgcolor = tblBg)
            table.merge_cells(ladder, 0, r, 3, r)
````
