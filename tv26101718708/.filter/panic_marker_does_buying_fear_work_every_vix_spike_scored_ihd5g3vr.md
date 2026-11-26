# Panic Marker: Does Buying Fear Work? Every VIX Spike Scored

- url: https://www.tradingview.com/script/ihD5G3VR-Panic-Marker-Does-Buying-Fear-Work-Every-VIX-Spike-Scored/
- type: indicator
- pine_id: PUB;52bbe61b5a2d47ab9485352eb06bb3f4
- version: 1.0

## Description

Everyone says "buy when there's blood in the streets". I wanted to know if that actually worked, so I built this to check 📊

😱 What it does
Every time the VIX (the market's fear gauge) closes at 30 or higher after a calm stretch, the script drops a number on your chart. Then it tells you what happened next: where price was about 3 months later, where it was about a year later, and how bad it got along the way.

Nothing is hidden. The panics that kept falling are listed right next to the ones that turned out to be great entries.

👀 How to read it
🟢 Green number: price was higher a year later
🔴 Red number: price was lower a year later
🟡 Yellow number: that one is still playing out
The red bands show how long fear stayed at 30 or above.
The table has every episode with its date, the VIX reading that day and the three results.

⚖️ The part most people skip
Under the table there are two lines. The first is the record after panics. The second is the same test run on every single day, panic or not.

Look at both. Stocks go up most years, so "higher a year later" is true most of the time anyway. The panic record only tells you something when you put it next to the normal one.

🔧 How it counts
One long scare counts once. A new panic needs 60 calm sessions before it.
Results start from the next day's open. The VIX closes after the stock market, so that's the first price you could really have traded.
It counts daily sessions on any timeframe. Put it on a weekly chart to see decades at once and you get the same numbers as on a daily chart.

⚙️ Settings
You can swap the fear gauge, change the level, the calm period and both time horizons, hide the headline, the table or the colour key, and move the table to any corner.

📈 What I found on the S&P 500
Weekly chart, at the time of posting: 21 panics since 1990. Of the 20 that have had a full year, 13 ended higher.
The losers came in clusters. Three panics in 2000 and 2001 and three in 2007 and 2008 were all lower a year later. Buying the first scare of a real bear market hurt.

⚠️ Please keep in mind
This shows what happened. It doesn't know what happens next, and it's not a buy or sell signal.
About twenty episodes is a small sample, so treat the percentages as rough.
Use it on a daily, weekly or monthly chart of something with a long history.

Try it on your own market and see how it compares 🔍

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nambou_Signals
//@version=6
indicator("Panic Marker", shorttitle = "Panic Marker", overlay = true, max_labels_count = 200, max_lines_count = 200)

gR = "Rule"
fearSym = input.symbol("TVC:VIX", "Fear gauge", group = gR)
level   = input.float(30.0, "Panic level: a close at or above", minval = 1.0, step = 1.0, group = gR)
quiet   = input.int(60, "A new episode needs this many sessions below the level first", minval = 1, group = gR)
h1      = input.int(63, "First horizon (sessions)", minval = 1, group = gR, tooltip = "63 sessions is about three months.")
h2      = input.int(252, "Second horizon (sessions)", minval = 2, group = gR, tooltip = "252 sessions is about twelve months.")

gD = "Display"
showHead  = input.bool(true, "Show the headline", group = gD)
showTable = input.bool(true, "Show the table of episodes", group = gD)
tablePosIn = input.string("Bottom right", "Table position", options = ["Top left", "Top right", "Bottom left", "Bottom right"], group = gD)
showKey   = input.bool(true, "Show the colour key under the table", group = gD)
txtSizeIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gD)
shade   = input.bool(true, "Shade the sessions spent at or above the level", group = gD)
crowd   = input.int(400, "Number tags: episodes closer than this many sessions alternate above and below", minval = 1, group = gD)
cUp     = input.color(#00E5A0, "Higher after the second horizon", group = gD)
cDn     = input.color(#FF3D71, "Lower after the second horizon", group = gD)
cOpen   = input.color(#F5C518, "Still running", group = gD)
cTxt    = input.color(#D1D4DC, "Text", group = gD)

txtSize = txtSizeIn == "Tiny" ? size.tiny : txtSizeIn == "Normal" ? size.normal : size.small

[dOpen, dClose, dLow, dTime] = request.security_lower_tf(syminfo.tickerid, "D", [open, close, low, time])
[fClose, fTime]       = request.security_lower_tf(fearSym, "D", [close, time])

var array<int>   sBar   = array.new<int>()
var array<int>   sSess  = array.new<int>()
var array<int>   sTime  = array.new<int>()
var array<float> sPrice = array.new<float>()
var array<float> sFear  = array.new<float>()
var array<float> r1     = array.new<float>()
var array<float> r2     = array.new<float>()
var array<float> worst  = array.new<float>()

var int sess = 0
var int lastPanic = na
var bool  pending     = false
var int   pendingTime = na
var float pendingFear = na
bool panicBar = false
var array<float> opens = array.new<float>()
var array<float> baseR = array.new<float>()
var int baseUp = 0
var bool fearSeen = false
dayOf(int t) => math.floor(t / 86400000.0)

if array.size(dClose) > 0
    for j = 0 to array.size(dClose) - 1
        sess += 1
        float c = array.get(dClose, j)
        float l = array.get(dLow, j)
        int   t = array.get(dTime, j)
        float f = na
        if array.size(fTime) > 0
            for k = 0 to array.size(fTime) - 1
                if dayOf(array.get(fTime, k)) == dayOf(t)
                    f := array.get(fClose, k)
        if not na(f)
            fearSeen := true
        if fearSeen
            array.push(opens, array.get(dOpen, j))
        if array.size(opens) > h2
            float e0 = array.get(opens, array.size(opens) - 1 - h2)
            array.push(baseR, c / e0 - 1.0)
            baseUp += c >= e0 ? 1 : 0
        if pending
            array.push(sBar, bar_index)
            array.push(sSess, sess)
            array.push(sTime, pendingTime)
            array.push(sPrice, array.get(dOpen, j))
            array.push(sFear, pendingFear)
            array.push(r1, na)
            array.push(r2, na)
            array.push(worst, 0.0)
            pending := false
        int m = array.size(sSess)
        if m > 0
            for i = 0 to m - 1
                int age = sess - array.get(sSess, i)
                float p0 = array.get(sPrice, i)
                if age >= 0 and age <= h2
                    array.set(worst, i, math.min(array.get(worst, i), l / p0 - 1.0))
                if age == h1
                    array.set(r1, i, c / p0 - 1.0)
                if age == h2
                    array.set(r2, i, c / p0 - 1.0)
        bool panic = not na(f) and f >= level
        if panic
            panicBar := true
            if na(lastPanic) or sess - lastPanic > quiet
                pending     := true
                pendingTime := t
                pendingFear := f
            lastPanic := sess

int n = array.size(sBar)

bgcolor(shade and panicBar ? color.new(cDn, 82) : na)

pct(float v) => na(v) ? "running" : (v >= 0.0 ? "+" : "") + str.tostring(v * 100.0, "0.0") + "%"

tPos = switch tablePosIn
    "Top right"    => position.top_right
    "Bottom left"  => position.bottom_left
    "Bottom right" => position.bottom_right
    => position.top_left

var table tbl = table.new(tPos, 5, 60, bgcolor = color.new(#131722, 10), border_color = color.new(#787B86, 85), border_width = 1, frame_color = color.new(#787B86, 60), frame_width = 1)
var table head = table.new(position.top_left, 1, 4, bgcolor = chart.bg_color)
var array<line>  marks = array.new<line>()
var array<label> tags  = array.new<label>()

cell(int c, int r, string v, color col) =>
    table.cell(tbl, c, r, v, text_color = col, text_halign = c <= 1 ? text.align_left : text.align_right, text_size = txtSize)

if barstate.islast
    for l in marks
        line.delete(l)
    array.clear(marks)
    for t in tags
        label.delete(t)
    array.clear(tags)
    table.clear(tbl, 0, 0, 4, 59)
    table.clear(head, 0, 0, 0, 3)

    if n > 0
        done = array.new<float>()
        int up = 0
        bool below = false
        for i = 0 to n - 1
            float a = array.get(r1, i)
            float b = array.get(r2, i)
            int age = sess - array.get(sSess, i)
            float nowR = close / array.get(sPrice, i) - 1.0
            color c = na(b) ? cOpen : b >= 0.0 ? cUp : cDn
            if not na(b)
                array.push(done, b)
                up += b >= 0.0 ? 1 : 0
            array.push(marks, line.new(array.get(sBar, i), array.get(sPrice, i), array.get(sBar, i), array.get(sPrice, i) * 1.0001, color = color.new(c, 35), width = 1, extend = extend.both))
            bool near = i > 0 and array.get(sSess, i) - array.get(sSess, i - 1) < crowd
            below := near ? not below : false
            array.push(tags, label.new(array.get(sBar, i), array.get(sPrice, i), str.tostring(i + 1), yloc = below ? yloc.belowbar : yloc.abovebar, style = below ? label.style_label_up : label.style_label_down, color = c, textcolor = #0B0E1A, size = txtSize))
            if showTable and i < 56
                cell(0, i + 1, str.tostring(i + 1), c)
                cell(1, i + 1, str.format_time(array.get(sTime, i), "d MMM yyyy", "UTC") + "  (" + str.tostring(array.get(sFear, i), "0.0") + ")", cTxt)
                cell(2, i + 1, na(a) ? "now " + pct(nowR) : pct(a), na(a) ? cOpen : a >= 0.0 ? cUp : cDn)
                cell(3, i + 1, na(b) ? (age > h1 ? "now " + pct(nowR) : "running") : pct(b), c)
                cell(4, i + 1, pct(array.get(worst, i)), cDn)
        if showTable
            cell(0, 0, "#", cTxt)
            cell(1, 0, "First close at " + str.tostring(level, "#.#") + "+  (reading)", cTxt)
            cell(2, 0, str.tostring(h1) + " sessions on", cTxt)
            cell(3, 0, str.tostring(h2) + " sessions on", cTxt)
            cell(4, 0, "Worst point on the way", cTxt)
            int r = math.min(n, 56) + 1
            int d = array.size(done)
            string summary = d == 0 ? "No episode has run its full course yet." : "After a panic: higher " + str.tostring(up) + " of " + str.tostring(d) + " times (" + str.tostring(100.0 * up / d, "0") + "%) " + str.tostring(h2) + " sessions on.   Middle case " + pct(array.median(done)) + ",  best " + pct(array.max(done)) + ",  worst " + pct(array.min(done)) + "."
            table.cell(tbl, 0, r, summary, text_color = cTxt, text_halign = text.align_left, text_size = txtSize)
            table.merge_cells(tbl, 0, r, 4, r)
            int nb = array.size(baseR)
            if nb > 0
                string yard = "Any session, panic or not: higher " + str.tostring(100.0 * baseUp / nb, "0") + "% of the time.   Middle case " + pct(array.median(baseR)) + ",  worst " + pct(array.min(baseR)) + "."
                table.cell(tbl, 0, r + 1, yard, text_color = color.new(cTxt, 25), text_halign = text.align_left, text_size = txtSize)
                table.merge_cells(tbl, 0, r + 1, 4, r + 1)
            int rk = r + 2
            if showKey
                table.cell(tbl, 0, rk, "", text_size = txtSize)
                table.cell(tbl, 1, rk, "●  higher after " + str.tostring(h2) + " sessions", text_color = cUp, text_halign = text.align_left, text_size = txtSize)
                table.cell(tbl, 2, rk, "●  lower", text_color = cDn, text_halign = text.align_left, text_size = txtSize)
                table.cell(tbl, 3, rk, "●  still running", text_color = cOpen, text_halign = text.align_left, text_size = txtSize)
                table.cell(tbl, 4, rk, "", text_size = txtSize)
                rk += 1
            table.cell(tbl, 0, rk, "", height = 4)
            table.merge_cells(tbl, 0, rk, 4, rk)
        if showHead
            int dn = array.size(done)
            string later = h2 == 252 ? "a year later" : str.tostring(h2) + " sessions later"
            table.cell(head, 0, 0, "", height = 9)
            table.cell(head, 0, 1, syminfo.ticker + "   fear gauge at " + str.tostring(level, "#.#") + " or above", text_color = cTxt, text_size = 16, text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(head, 0, 2, str.tostring(n) + " market panics since " + str.tostring(year(array.get(sTime, 0))) + ".", text_color = color.white, text_size = 28, text_halign = text.align_left, text_formatting = text.format_bold)
            if dn > 0
                table.cell(head, 0, 3, "Higher " + later + " " + str.tostring(up) + " of " + str.tostring(dn) + " times.", text_color = cUp, text_size = 28, text_halign = text.align_left, text_formatting = text.format_bold)

alertcondition(n > n[1], "A new panic episode began", "Panic Marker: the fear gauge closed at or above the level after a quiet stretch.")
````
