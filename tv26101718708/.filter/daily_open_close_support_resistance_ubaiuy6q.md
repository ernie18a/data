# Daily Open Close Support & Resistance 

- url: https://www.tradingview.com/script/ubAIuy6q-Daily-Open-Close-Support-Resistance/
- type: indicator
- pine_id: PUB;894d344f9f9740d8a0d8d7c63c41f8d4
- version: 1.0

## Description

Plots support and resistance built from the OPENS and CLOSES of recent daily bars — not from pivots. The idea: price areas where the market repeatedly opened or closed tend to act as support and resistance.

HOW IT WORKS
Every daily open and close in the lookback window (default 84 bars ≈ 4 months) is collected and then clustered. Opens/closes that fall within an ATR-scaled band merge into a single level, and the number that merge in becomes that level's strength. Stronger levels draw as heavier, more opaque lines and carry a ×count tag. Because the merge band scales with ATR, it auto-widens on volatile symbols and tightens on calm ones — no fixed dollar tolerance to tune.

AUTO-TIMEFRAME
Apply it on the daily chart and it reads native daily bars. Apply it on any intraday chart (3-min, 5-min, etc.) and it automatically pulls the daily opens/closes, so the same daily levels appear on your execution chart with no timeframe setting to change. The info table shows whether the current source is "native" or "pulled" so you can confirm at a glance.

ALERTS
Five conditions: price touching nearest support, nearest resistance, or any level (within an ATR-scaled tolerance), plus a close breaking through support or resistance. Touch alerts fire once on the transition, not on every following bar.

SETTINGS
Lookback (84 ≈ 4 months, 63 ≈ 3 months), merge distance in ATR, minimum cluster count to display, max levels per side, a near-price window to hide distant levels, touch tolerance, and full styling control. Optional toggles to also include daily highs and lows.

NOTE ON INTRADAY HISTORY
On a sub-daily chart the lookback only reaches as far back as the intraday history your TradingView plan loads, so the level set there may be shorter than on the daily chart. The daily chart always shows the full lookback. This is a chart-data limitation, not a script setting.

Repainting is avoided via lookahead_off and by referencing only completed higher-timeframe bars.

## Source Code

````pine
//@version=6
indicator("Daily O/C Support-Resistance", "O/C S/R", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────── Inputs ───────────
gW = "Lookback / Source"
lookback = input.int(84, "Lookback (daily bars)", minval = 10, group = gW, tooltip = "How many source bars of opens/closes to scan. 84 ≈ 4 months, 63 ≈ 3 months.")
srcTF    = input.timeframe("D", "Level source timeframe", group = gW, tooltip = "Levels are built from THIS timeframe's opens/closes. Default Daily. On a 3-min chart it auto-pulls Daily levels; on the Daily chart it uses them directly. No manual switching.")
useOpen  = input.bool(true,  "Use opens",  inline = "src", group = gW)
useClose = input.bool(true,  "Use closes", inline = "src", group = gW)
useHigh  = input.bool(false, "+ highs", inline = "src2", group = gW)
useLow   = input.bool(false, "+ lows",  inline = "src2", group = gW)

gC = "Clustering / Filter"
atrLen   = input.int(14, "ATR length", minval = 1, group = gC)
mergeM   = input.float(0.40, "Merge distance (× ATR)", minval = 0.05, step = 0.05, group = gC, tooltip = "Opens/closes within this band collapse into one level; count grows = stronger.")
minTouch = input.int(2, "Min count to show", minval = 1, group = gC)
maxLvl   = input.int(6, "Max levels per side", minval = 1, maxval = 30, group = gC)
useWin   = input.bool(true, "Only show levels near price", group = gC)
winAtr   = input.float(10.0, "Window (± × ATR)", minval = 1.0, step = 0.5, group = gC)

gA = "Alerts"
touchTol = input.float(0.05, "Touch tolerance (× ATR)", minval = 0.0, step = 0.01, group = gA, tooltip = "How close price must come to count as 'trading at' the line.")

gS = "Style"
resCol  = input.color(color.red,   "Resistance", inline = "c", group = gS)
supCol  = input.color(color.green, "Support",    inline = "c", group = gS)
wide    = input.int(2, "Line width", minval = 1, maxval = 5, group = gS)
showLbl = input.bool(true, "Price labels", group = gS)
showTbl = input.bool(true, "Info table",   group = gS)

// ─────────── Auto source resolution ───────────
chartSec = timeframe.in_seconds(timeframe.period)
srcSec   = timeframe.in_seconds(srcTF)
pullHTF  = srcSec > chartSec          // chart is intraday & finer than source → pull. Else use native.

atr = ta.atr(atrLen)
[htfO, htfC, htfH, htfL] = request.security(syminfo.tickerid, srcTF, [open, close, high, low], lookahead = barmerge.lookahead_off)
newSrc = ta.change(time(srcTF)) != 0
doPush = pullHTF ? (newSrc and not na(htfO[1])) : true

// ─────────── Raw level store ───────────
var array<float> rawP   = array.new<float>()
var array<int>   rawSeq = array.new<int>()
var int          pSeq   = 0

pushRaw(float p) =>
    if not na(p)
        array.push(rawP, p)
        array.push(rawSeq, pSeq)

if doPush
    pSeq += 1
    o = pullHTF ? htfO[1] : open
    c = pullHTF ? htfC[1] : close
    h = pullHTF ? htfH[1] : high
    l = pullHTF ? htfL[1] : low
    if useOpen
        pushRaw(o)
    if useClose
        pushRaw(c)
    if useHigh
        pushRaw(h)
    if useLow
        pushRaw(l)
    cutoff = pSeq - lookback
    k = 0
    while k < array.size(rawP)
        if array.get(rawSeq, k) <= cutoff
            array.remove(rawP, k)
            array.remove(rawSeq, k)
        else
            k += 1

// ─────────── Cluster into levels ───────────
cp = array.new<float>()
ct = array.new<int>()
band = atr * mergeM
nraw = array.size(rawP)
if nraw > 0
    for i = 0 to nraw - 1
        p   = array.get(rawP, i)
        idx = -1
        best = band
        if array.size(cp) > 0
            for j = 0 to array.size(cp) - 1
                d = math.abs(array.get(cp, j) - p)
                if d <= best
                    best := d
                    idx  := j
        if idx >= 0
            t  = array.get(ct, idx) + 1
            np = (array.get(cp, idx) * (t - 1) + p) / t
            array.set(cp, idx, np)
            array.set(ct, idx, t)
        else
            array.push(cp, p)
            array.push(ct, 1)

// ─────────── Nearest level each side ───────────
nRes = float(na)
nSup = float(na)
if array.size(cp) > 0
    for i = 0 to array.size(cp) - 1
        if array.get(ct, i) >= minTouch
            p = array.get(cp, i)
            if p >= close
                nRes := na(nRes) ? p : math.min(nRes, p)
            else
                nSup := na(nSup) ? p : math.max(nSup, p)

tband  = atr * touchTol
inRes  = not na(nRes) and high >= nRes - tband and low <= nRes + tband
inSup  = not na(nSup) and high >= nSup - tband and low <= nSup + tband
atRes  = inRes and not inRes[1]
atSup  = inSup and not inSup[1]
brkRes = not na(nRes[1]) and close > nRes[1] and close[1] <= nRes[1]
brkSup = not na(nSup[1]) and close < nSup[1] and close[1] >= nSup[1]

alertcondition(atSup,          "Price at support",       "Price is trading at nearest support")
alertcondition(atRes,          "Price at resistance",    "Price is trading at nearest resistance")
alertcondition(atSup or atRes, "Price at any S/R level", "Price is trading at a key daily level")
alertcondition(brkSup,         "Support broken",         "Close pierced nearest support")
alertcondition(brkRes,         "Resistance broken",      "Close pierced nearest resistance")

// ─────────── Drawing ───────────
var array<line>  Ls = array.new<line>()
var array<label> Lb = array.new<label>()

drawSide(bool isRes) =>
    ix = array.new<int>()
    dd = array.new<float>()
    if array.size(cp) > 0
        for i = 0 to array.size(cp) - 1
            t = array.get(ct, i)
            if t >= minTouch
                p    = array.get(cp, i)
                side = p >= close
                ok   = isRes ? side : not side
                near = not useWin or math.abs(p - close) <= atr * winAtr
                if ok and near
                    array.push(ix, i)
                    array.push(dd, math.abs(p - close))
    drawn = 0
    while array.size(ix) > 0 and drawn < maxLvl
        mi = 0
        if array.size(dd) > 1
            for j = 1 to array.size(dd) - 1
                if array.get(dd, j) < array.get(dd, mi)
                    mi := j
        i = array.get(ix, mi)
        array.remove(ix, mi)
        array.remove(dd, mi)
        p   = array.get(cp, i)
        t   = array.get(ct, i)
        col = isRes ? resCol : supCol
        tr  = math.max(0, 70 - (t - 1) * 12)
        ln  = line.new(bar_index - 1, p, bar_index, p, xloc.bar_index, extend.both, color.new(col, tr), line.style_solid, wide)
        array.push(Ls, ln)
        if showLbl
            lab = label.new(bar_index + 6, p, str.tostring(p, format.mintick) + "  ×" + str.tostring(t), xloc.bar_index, yloc.price, color.new(col, 60), label.style_label_left, chart.fg_color, size.small)
            array.push(Lb, lab)
        drawn += 1

if barstate.islast
    for l in Ls
        line.delete(l)
    array.clear(Ls)
    for b in Lb
        label.delete(b)
    array.clear(Lb)
    drawSide(true)
    drawSide(false)

// ─────────── Info table ───────────
resTxt = na(nRes) ? "—" : str.tostring(nRes, format.mintick)
supTxt = na(nSup) ? "—" : str.tostring(nSup, format.mintick)
resD   = na(nRes) ? "—" : str.tostring((nRes - close) / close * 100, "0.00") + "%  •  " + str.tostring((nRes - close) / atr, "0.0") + "×"
supD   = na(nSup) ? "—" : str.tostring((close - nSup) / close * 100, "0.00") + "%  •  " + str.tostring((close - nSup) / atr, "0.0") + "×"
srcLbl = srcTF + (pullHTF ? "  (pulled)" : "  (native)")

var table tb = table.new(position.top_right, 2, 5, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)
if showTbl and barstate.islast
    table.cell(tb, 0, 0, "Source", text_color = chart.fg_color, text_size = size.small, bgcolor = color.new(color.gray, 85))
    table.cell(tb, 1, 0, srcLbl,   text_color = chart.fg_color, text_size = size.small, bgcolor = color.new(color.gray, 85))
    table.cell(tb, 0, 1, "Res", text_color = resCol, text_size = size.small)
    table.cell(tb, 1, 1, resTxt + "  " + resD, text_color = resCol, text_size = size.small)
    table.cell(tb, 0, 2, "Now", text_color = chart.fg_color, text_size = size.small)
    table.cell(tb, 1, 2, str.tostring(close, format.mintick), text_color = chart.fg_color, text_size = size.small)
    table.cell(tb, 0, 3, "Sup", text_color = supCol, text_size = size.small)
    table.cell(tb, 1, 3, supTxt + "  " + supD, text_color = supCol, text_size = size.small)
    table.cell(tb, 0, 4, "Bars", text_color = chart.fg_color, text_size = size.small)
    table.cell(tb, 1, 4, str.tostring(array.size(cp)) + " lvls", text_color = chart.fg_color, text_size = size.small)
````
