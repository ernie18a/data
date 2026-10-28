# Nambou Structure Radar: BOS & CHoCH with Multi-Timeframe Trend

- url: https://www.tradingview.com/script/gxUFeCm7-Nambou-Structure-Radar-BOS-CHoCH-with-Multi-Timeframe-Trend/
- type: indicator
- pine_id: PUB;df1d7297a0c24f2bb3a3dd4b22d79204
- version: 1.0

## Description

Ever been sure the trend was up, only to realise price broke the last higher low two days ago? Market structure tells you which way the trend really points, but reading it by eye on every timeframe is slow and easy to get wrong. So I built a radar for it 📡

🎯 What it does
Structure Radar marks every swing high and low, then watches what price does with them. When price closes beyond the last swing in the direction of the trend, that's a break of structure (BOS): the trend continues. When it closes beyond the swing against the trend, that's a change of character (CHoCH): the trend has turned. It does this on your chart and, at the same time, on the three timeframes above it.

👀 What you see on the chart
🟢 Green is bullish and 🔴 red is bearish.
Swings are labelled HH, HL, LH and LL (higher high, higher low, lower high, lower low).
A BOS is a dashed line from the swing to the bar that broke it. A CHoCH is a solid line with a filled tag, so trend changes stand out at a glance.
The two live swings run past the last candle with their price and distance. The one that would flip the trend is the strong one (solid line); the other is the next break in the trend's direction (dotted line).
Between them, a faint zone shades the current range, with a dashed line at its middle.

⏫ The trend on four timeframes
The table shows the structure on your chart plus the three timeframes above it: 1H, 4H and Daily below one hour, up to Weekly, Monthly and 3 months on a daily chart. For each one: the trend, the last break (BOS or CHoCH) and when it happened, the level where the trend would flip, and how far price is from it. A line underneath sums it up, for example "2 of 4 timeframes bullish, 2 bearish". You can pick the timeframes yourself in the settings.

📋 Where the table goes
By default it sits at the top or the bottom of the chart, wherever the candles leave more room. If it lands on your candles, pick another position in the settings.

🔔 Alerts
Create an alert on the indicator with "Any alert() function call" and you get a message on every BOS and CHoCH on your chart, and when one of the higher timeframes flips its trend. Each kind can be switched off in the settings.

⚙️ Settings worth knowing
"Swing size" is how many bars on each side make a swing (5 by default). Bigger numbers give fewer, bigger swings and a slower trend.
"A swing is broken by a" close (default) or a wick.
The swing labels, the break lines, the live levels, the range shading, candle colouring by trend and the table each have their own switch.

⚠️ Worth knowing
A swing is only confirmed after the "Swing size" number of bars, so swing labels show up late. Breaks are judged on closed bars, alerts included, and the higher timeframes are read from their last closed bar, so nothing repaints.
A BOS or CHoCH describes what price did to a swing. It doesn't tell you what happens next, and trends flip back more often than you'd think.

This is a charting tool, not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nambou_Signals
//@version=6
indicator("Nambou Structure Radar", "Structure Radar", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

gS = "Structure"
len     = input.int(5, "Swing size: bars on each side of a swing", minval = 2, maxval = 50, group = gS, tooltip = "A swing high needs this many lower highs on each side of it. Bigger numbers give fewer, bigger swings.")
breakOn = input.string("Close", "A swing is broken by a", options = ["Close", "Wick"], group = gS, tooltip = "Close: a bar has to close beyond the swing. Wick: touching beyond it is enough.")

gT = "Higher timeframes"
showHtf = input.bool(true, "Read the structure on higher timeframes too", group = gT)
tfMode  = input.string("Auto", "Which timeframes", options = ["Auto", "Manual"], group = gT, tooltip = "Auto takes the three timeframes above the chart: 1H, 4H and Daily below one hour, 4H, Daily and Weekly on 1H to 3H, Daily, Weekly and Monthly on 4H to 12H, Weekly, Monthly and 3 months on Daily. Higher timeframes are read from their last closed bar, so they never repaint.")
tfIn1   = input.timeframe("60", "Manual timeframe 1", group = gT)
tfIn2   = input.timeframe("240", "Manual timeframe 2", group = gT)
tfIn3   = input.timeframe("D", "Manual timeframe 3", group = gT, tooltip = "A timeframe at or below the chart's is skipped.")

gD = "Display"
showSwings = input.bool(true, "Label the swings (HH, HL, LH, LL)", group = gD)
showEvents = input.bool(true, "Draw the breaks (BOS and CHoCH)", group = gD)
maxEv      = input.int(12, "Breaks kept on the chart", minval = 1, maxval = 100, group = gD)
showLevels = input.bool(true, "Show the live swing high and low", group = gD, tooltip = "The swing that would flip the trend is the strong one; the other is the next break in the trend's direction.")
showRange  = input.bool(true, "Shade the range between the live swing high and low", group = gD, tooltip = "A faint zone with a dashed line at its middle. Above the middle is the upper half of the range, below it the lower half.")
extBars    = input.int(20, "Levels run this many bars past the last bar", minval = 1, maxval = 200, group = gD)
barTint    = input.bool(false, "Colour the candles by trend", group = gD)
showTable  = input.bool(true, "Show the structure table", group = gD)
tablePosIn = input.string("Auto", "Table position", options = ["Auto", "Top center", "Bottom center", "Top right", "Bottom right", "Bottom left", "Top left"], group = gD, tooltip = "Auto looks at the left, middle and right of the visible chart and puts the table at the top or the bottom where the candles leave the most room.")
txtSizeIn  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gD)
cBull = input.color(#00E5A0, "Bullish", group = gD)
cBear = input.color(#FF3D71, "Bearish", group = gD)
cTxt  = input.color(#D1D4DC, "Neutral text", group = gD)

gA = "Alerts"
aBos   = input.bool(true, "Alert on a break of structure (BOS)", group = gA)
aChoch = input.bool(true, "Alert on a change of character (CHoCH)", group = gA)
aHtf   = input.bool(true, "Alert when a higher timeframe's trend flips", group = gA)

txtSize = txtSizeIn == "Tiny" ? size.tiny : txtSizeIn == "Normal" ? size.normal : size.small
bigSize = txtSizeIn == "Tiny" ? size.small : txtSizeIn == "Normal" ? size.large : size.normal
clear = color.new(#000000, 100)

structure() =>
    var int t = 0
    var float h = na
    var float l = na
    var bool hx = true
    var bool lx = true
    var int ev = 0
    var int evT = na
    float p1 = ta.pivothigh(high, len, len)
    float p2 = ta.pivotlow(low, len, len)
    if not na(p1)
        h := p1
        hx := false
    if not na(p2)
        l := p2
        lx := false
    float up = breakOn == "Close" ? close : high
    float dn = breakOn == "Close" ? close : low
    if not hx and up > h
        ev := t == -1 ? 2 : 1
        t := 1
        hx := true
        evT := time
    if not lx and dn < l
        ev := t == 1 ? -2 : -1
        t := -1
        lx := true
        evT := time
    [t, ev, evT, hx ? float(na) : h, lx ? float(na) : l]

closedState() =>
    [t, ev, evT, h, l] = structure()
    [t[1], ev[1], evT[1], h[1], l[1]]

tfSec = timeframe.in_seconds()
auto1 = tfSec < 3600 ? "60" : tfSec < 14400 ? "240" : tfSec < 86400 ? "D" : tfSec < 604800 ? "W" : "M"
auto2 = tfSec < 3600 ? "240" : tfSec < 14400 ? "D" : tfSec < 86400 ? "W" : tfSec < 604800 ? "M" : "3M"
auto3 = tfSec < 3600 ? "D" : tfSec < 14400 ? "W" : tfSec < 86400 ? "M" : tfSec < 604800 ? "3M" : "12M"
tf1 = tfMode == "Auto" ? auto1 : tfIn1
tf2 = tfMode == "Auto" ? auto2 : tfIn2
tf3 = tfMode == "Auto" ? auto3 : tfIn3
useTf(string tf) => showHtf and timeframe.in_seconds(tf) > tfSec

[t1, e1, et1, h1, l1] = request.security(syminfo.tickerid, tf1, closedState(), lookahead = barmerge.lookahead_on)
[t2, e2, et2, h2, l2] = request.security(syminfo.tickerid, tf2, closedState(), lookahead = barmerge.lookahead_on)
[t3, e3, et3, h3, l3] = request.security(syminfo.tickerid, tf3, closedState(), lookahead = barmerge.lookahead_on)

ph = ta.pivothigh(high, len, len)
pl = ta.pivotlow(low, len, len)

var int   trend  = 0
var float swH    = na
var int   swHb   = na
var bool  hDone  = true
var float prevH  = na
var float swL    = na
var int   swLb   = na
var bool  lDone  = true
var float prevL  = na
var int   lastEv = 0
var int   evTime = na
var int   evBar  = na

var array<label> swingTags = array.new<label>()
var array<line>  evLines   = array.new<line>()
var array<label> evTags    = array.new<label>()

keepLast(array<label> a, int n) =>
    while a.size() > n
        label.delete(a.shift())

if not na(ph)
    string tag = na(prevH) ? "H" : ph > prevH ? "HH" : "LH"
    prevH := ph
    swH := ph
    swHb := bar_index - len
    hDone := false
    if showSwings
        swingTags.push(label.new(swHb, ph, tag, style = label.style_label_down, color = clear, textcolor = color.new(tag == "HH" ? cBull : tag == "LH" ? cBear : cTxt, 15), size = size.tiny))
        keepLast(swingTags, 60)

if not na(pl)
    string tag = na(prevL) ? "L" : pl < prevL ? "LL" : "HL"
    prevL := pl
    swL := pl
    swLb := bar_index - len
    lDone := false
    if showSwings
        swingTags.push(label.new(swLb, pl, tag, style = label.style_label_up, color = clear, textcolor = color.new(tag == "HL" ? cBull : tag == "LL" ? cBear : cTxt, 15), size = size.tiny))
        keepLast(swingTags, 60)

mark(int x0, float y, bool bull, bool choch) =>
    color c = bull ? cBull : cBear
    if showEvents
        evLines.push(line.new(x0, y, bar_index, y, color = color.new(c, choch ? 0 : 25), width = choch ? 2 : 1, style = choch ? line.style_solid : line.style_dashed))
        int mid = int(math.round((x0 + bar_index) / 2.0))
        if choch
            evTags.push(label.new(mid, y, "CHoCH", style = bull ? label.style_label_down : label.style_label_up, color = c, textcolor = #0B0E1A, size = txtSize))
        else
            evTags.push(label.new(mid, y, "BOS", style = bull ? label.style_label_down : label.style_label_up, color = color.new(c, 78), textcolor = c, size = txtSize))
        while evLines.size() > maxEv
            line.delete(evLines.shift())
        keepLast(evTags, maxEv)

float upSrc = breakOn == "Close" ? close : high
float dnSrc = breakOn == "Close" ? close : low

if barstate.isconfirmed
    if not hDone and upSrc > swH
        bool ch = trend == -1
        trend := 1
        hDone := true
        lastEv := ch ? 2 : 1
        evTime := time
        evBar := bar_index
        mark(swHb, swH, true, ch)
        if ch and aChoch
            alert("Structure Radar: " + syminfo.ticker + " " + timeframe.period + " CHoCH up: closed above the swing high at " + str.tostring(swH, format.mintick) + ", the trend turned bullish", alert.freq_once_per_bar_close)
        if not ch and aBos
            alert("Structure Radar: " + syminfo.ticker + " " + timeframe.period + " BOS up: closed above the swing high at " + str.tostring(swH, format.mintick), alert.freq_once_per_bar_close)
    if not lDone and dnSrc < swL
        bool ch = trend == 1
        trend := -1
        lDone := true
        lastEv := ch ? -2 : -1
        evTime := time
        evBar := bar_index
        mark(swLb, swL, false, ch)
        if ch and aChoch
            alert("Structure Radar: " + syminfo.ticker + " " + timeframe.period + " CHoCH down: closed below the swing low at " + str.tostring(swL, format.mintick) + ", the trend turned bearish", alert.freq_once_per_bar_close)
        if not ch and aBos
            alert("Structure Radar: " + syminfo.ticker + " " + timeframe.period + " BOS down: closed below the swing low at " + str.tostring(swL, format.mintick), alert.freq_once_per_bar_close)

tfName(string tf) =>
    int s = timeframe.in_seconds(tf)
    int mo = int(math.round(s / 2629746.0))
    s < 3600 ? str.tostring(int(s / 60)) + "m" : s < 86400 ? str.tostring(int(s / 3600)) + "H" : s == 86400 ? "Daily" : s == 604800 ? "Weekly" : s >= 2419200 ? (mo <= 1 ? "Monthly" : mo == 12 ? "Yearly" : str.tostring(mo) + " months") : str.tostring(int(s / 86400)) + "D"

flipAlert(string tf, int t) =>
    if aHtf and barstate.isconfirmed and useTf(tf) and t != t[1] and t != 0 and not na(t[1])
        alert("Structure Radar: " + syminfo.ticker + " " + tfName(tf) + " trend turned " + (t == 1 ? "bullish" : "bearish"), alert.freq_once_per_bar_close)

flipAlert(tf1, t1)
flipAlert(tf2, t2)
flipAlert(tf3, t3)

barcolor(barTint ? (trend == 1 ? cBull : trend == -1 ? cBear : na) : na)

var box   rangeBox = na
var line  midLine  = na
var label midTag   = na
var line  hiLine = na
var line  loLine = na
var label hiTag  = na
var label loTag  = na

pctTo(float lvl) => (lvl >= close ? "+" : "") + str.tostring((lvl - close) / close * 100.0, "0.00") + "%"

level(line ln, label lb, int x0, float y, bool isHigh) =>
    line.delete(ln)
    label.delete(lb)
    bool strong = isHigh ? trend == -1 : trend == 1
    color c = isHigh ? cBear : cBull
    string name = (strong ? "Strong " : "Weak ") + (isHigh ? "high" : "low")
    int left = math.max(x0, bar_index - math.min(bar_index, 200))
    line nl = line.new(left, y, bar_index + extBars, y, color = color.new(c, strong ? 0 : 35), width = strong ? 2 : 1, style = strong ? line.style_solid : line.style_dotted)
    label nb = label.new(bar_index + extBars, y, name + "  " + str.tostring(y, format.mintick) + "  (" + pctTo(y) + ")", style = label.style_label_left, color = strong ? c : color.new(c, 82), textcolor = strong ? #0B0E1A : c, size = txtSize, textalign = text.align_left)
    [nl, nb]

trendText(int t) => t == 1 ? "▲ BULLISH" : t == -1 ? "▼ BEARISH" : "– NO BREAK"
evText(int e) => math.abs(e) == 2 ? "CHoCH" : math.abs(e) == 1 ? "BOS" : "–"
whenText(int t, string tf) => na(t) ? "" : str.format_time(t, timeframe.in_seconds(tf) >= 86400 ? "d MMM yyyy" : "d MMM HH:mm", syminfo.timezone)

tPos = switch tablePosIn
    "Top center"    => position.top_center
    "Bottom center" => position.bottom_center
    "Top right"     => position.top_right
    "Bottom right"  => position.bottom_right
    "Bottom left"   => position.bottom_left
    "Top left"      => position.top_left
    => position.top_center

tblBg = color.new(#131722, 8)
var table tbl = table.new(tPos, 5, 12, border_width = 0, frame_width = 0)

cell(int c, int r, string v, color tc) =>
    table.cell(tbl, c, r, v, text_color = tc, text_halign = c >= 3 ? text.align_right : text.align_left, text_size = txtSize, bgcolor = tblBg)

row(int r, string name, int t, int e, int et, float h, float l, string tf) =>
    color c = t == 1 ? cBull : t == -1 ? cBear : cTxt
    float flip = t == 1 ? l : t == -1 ? h : na
    cell(0, r, name, cTxt)
    table.cell(tbl, 1, r, trendText(t), text_color = t == 0 ? cTxt : #0B0E1A, text_halign = text.align_center, text_size = txtSize, bgcolor = t == 0 ? tblBg : color.new(c, 5))
    cell(2, r, e == 0 ? "–" : evText(e) + "  " + whenText(et, tf), color.new(c, 10))
    cell(3, r, na(flip) ? "–" : str.tostring(flip, format.mintick), c)
    cell(4, r, na(flip) ? "" : pctTo(flip), color.new(c, 10))

if barstate.islast
    if showLevels
        if not hDone
            [a, b] = level(hiLine, hiTag, swHb, swH, true)
            hiLine := a
            hiTag := b
        else
            line.delete(hiLine)
            label.delete(hiTag)
        if not lDone
            [a, b] = level(loLine, loTag, swLb, swL, false)
            loLine := a
            loTag := b
        else
            line.delete(loLine)
            label.delete(loTag)

    box.delete(rangeBox)
    line.delete(midLine)
    label.delete(midTag)
    if showRange and not hDone and not lDone and swH > swL
        int left = math.max(math.max(swHb, swLb), bar_index - math.min(bar_index, 200))
        color rc = trend == 1 ? cBull : trend == -1 ? cBear : cTxt
        float m = (swH + swL) / 2.0
        rangeBox := box.new(left, swH, bar_index + extBars, swL, border_color = color.new(rc, 100), bgcolor = color.new(rc, 93))
        midLine := line.new(left, m, bar_index + extBars, m, color = color.new(cTxt, 55), style = line.style_dashed, width = 1)
        midTag := label.new(bar_index + extBars, m, "50%  " + str.tostring(m, format.mintick), style = label.style_label_left, color = clear, textcolor = color.new(cTxt, 30), size = txtSize)
    table.clear(tbl, 0, 0, 4, 11)
    if showTable
        float vHi = high
        float vLo = low
        int vj = 0
        while vj < 999 and time[vj] >= chart.left_visible_bar_time
            vHi := math.max(vHi, high[vj])
            vLo := math.min(vLo, low[vj])
            vj += 1
        bool atTop = tablePosIn == "Top center" or tablePosIn == "Top left" or tablePosIn == "Top right"
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
                if up > best and part < 2
                    best := up
                    pick := part == 0 ? position.top_right : position.top_center
                if dn > best
                    best := dn
                    pick := part == 0 ? position.bottom_right : part == 1 ? position.bottom_center : position.bottom_left
            atTop := pick == position.top_center or pick == position.top_left or pick == position.top_right
            table.set_position(tbl, pick)

        int off = atTop ? 2 : 0
        if off > 0
            for k = 0 to off - 1
                table.cell(tbl, 0, k, " ", text_size = txtSize)
                table.merge_cells(tbl, 0, k, 4, k)
        color hc = trend == 1 ? cBull : trend == -1 ? cBear : cTxt
        table.cell(tbl, 0, off, "◆  NAMBOU STRUCTURE RADAR", text_color = hc, text_halign = text.align_left, text_size = bigSize, bgcolor = tblBg)
        table.merge_cells(tbl, 0, off, 4, off)
        cell(0, off + 1, "Timeframe", color.new(cTxt, 40))
        cell(1, off + 1, "Trend", color.new(cTxt, 40))
        cell(2, off + 1, "Last break", color.new(cTxt, 40))
        cell(3, off + 1, "Flips at", color.new(cTxt, 40))
        cell(4, off + 1, "Distance", color.new(cTxt, 40))
        int r = off + 2
        int bulls = 0
        int shown = 0
        row(r, tfName(timeframe.period) + " (chart)", trend, lastEv, evTime, hDone ? float(na) : swH, lDone ? float(na) : swL, timeframe.period)
        r += 1
        shown += 1
        bulls += trend == 1 ? 1 : 0
        if useTf(tf1)
            row(r, tfName(tf1), t1, e1, et1, h1, l1, tf1)
            r += 1
            shown += 1
            bulls += t1 == 1 ? 1 : 0
        if useTf(tf2)
            row(r, tfName(tf2), t2, e2, et2, h2, l2, tf2)
            r += 1
            shown += 1
            bulls += t2 == 1 ? 1 : 0
        if useTf(tf3)
            row(r, tfName(tf3), t3, e3, et3, h3, l3, tf3)
            r += 1
            shown += 1
            bulls += t3 == 1 ? 1 : 0
        int bears = 0
        bears += trend == -1 ? 1 : 0
        bears += useTf(tf1) and t1 == -1 ? 1 : 0
        bears += useTf(tf2) and t2 == -1 ? 1 : 0
        bears += useTf(tf3) and t3 == -1 ? 1 : 0
        string verdict = shown == 1 ? (bulls == 1 ? "Bullish structure" : bears == 1 ? "Bearish structure" : "No break yet") : bulls == shown ? "All " + str.tostring(shown) + " timeframes bullish" : bears == shown ? "All " + str.tostring(shown) + " timeframes bearish" : str.tostring(bulls) + " of " + str.tostring(shown) + " timeframes bullish, " + str.tostring(bears) + " bearish"
        color vc = bulls > bears ? cBull : bears > bulls ? cBear : cTxt
        string meter = ""
        for k = 1 to shown
            meter += k <= math.max(bulls, bears) ? "▰" : "▱"
        table.cell(tbl, 0, r, meter + "   " + str.upper(verdict), text_color = vc, text_halign = text.align_left, text_size = bigSize, bgcolor = color.new(vc, 85))
        table.merge_cells(tbl, 0, r, 4, r)
        r += 1
        table.cell(tbl, 0, r, "BOS = trend continues  ·  CHoCH = trend turns", text_color = color.new(cTxt, 30), text_halign = text.align_left, text_size = txtSize, bgcolor = tblBg)
        table.merge_cells(tbl, 0, r, 4, r)
        if not atTop
            table.cell(tbl, 0, r + 1, " ", text_size = txtSize)
            table.merge_cells(tbl, 0, r + 1, 4, r + 1)
            table.cell(tbl, 0, r + 2, " ", text_size = txtSize)
            table.merge_cells(tbl, 0, r + 2, 4, r + 2)
````
