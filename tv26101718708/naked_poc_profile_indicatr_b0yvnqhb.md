# Naked POC Profile [Indicatr]

- url: https://www.tradingview.com/script/b0YVNQhB-Naked-POC-Profile-Indicatr/
- type: indicator
- pine_id: PUB;5b4ff09bdaee4bed986ef818d00d8232
- version: 1.0

## Description

[b]Naked POC Profile[/b] builds a volume profile for every day (or week / month), keeps track of each Point of Control that price has not traded back to yet - the so called naked POCs - and shows how often such levels were revisited on the symbol you are looking at.

[b]WHAT IT DOES[/b]
The Point of Control (POC) is the price with the most traded volume of a period. When the next periods move away without trading back through it, the level stays "naked" and is often watched as a magnet or reaction area. This script draws the profiles of the last periods with value area and POC, extends every naked POC to the right until it is touched, and measures the historical revisit rate.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Profile period:[/b] Auto uses Day on intraday charts, Week on daily charts and Month on weekly charts (or choose manually).
[*][b]Volume profile:[/b] the period's high-low range is split into 30 price rows. Each bar's volume is spread evenly across the rows its range covers.
[*][b]POC and value area:[/b] the row with the most volume is the POC; the value area grows from the POC towards the side with more volume until 70 percent of the period volume is included (VAH / VAL).
[*][b]Naked POCs:[/b] each completed POC is stored. As soon as a later bar trades through it, it is removed. Up to 15 naked POCs are kept; levels far away (more than 2 x the average period range) are counted but not drawn, so the chart scale stays readable.
[*][b]Statistics:[/b] the table shows the share of POCs that were revisited within 5 periods, with the sample size.
[/list]

[b]HOW TO USE[/b]
[list]
[*]Gold lines = naked POCs, labelled with their age (e.g. nPOC 3d). Blue histograms = profiles of the last 6 periods, darker inside the value area, gold row = POC.
[*]Naked POCs above and below price can serve as targets or reaction areas - for long and short alike.
[*]The revisit rate tells you how reliable this behaviour has been on the current symbol and timeframe.
[*]Alerts: naked POC touched, new period profile.
[/list]

[b]THE CHART[/b]
Gold (XAUUSD) 1 hour with daily profiles. The blue histograms show the daily volume profiles of the last sessions with value area and POC, the gold lines are naked POCs from earlier days that price has not traded back to yet. The table shows the number of naked POCs, the nearest one above and below in percent, the revisit rate and yesterday's POC / VAH / VAL.

[b]WHAT IS ORIGINAL[/b]
TradingView offers volume profiles. This script focuses on what happens after the period: it tracks the untouched POCs over many periods, filters them by distance, and measures how often they were revisited, so the idea of "naked POCs act as magnets" can be checked on each market instead of assumed.

[b]CREDITS[/b]
Volume profile, Point of Control and value area are standard market profile concepts (originating from J. Peter Steidlmayer's Market Profile work).

[b]LIMITATIONS[/b]
[list]
[*]Pine Script has no tick-level volume at price. Volume is spread evenly across each bar's range, so the profile is an approximation - use a lower chart timeframe for more precise profiles.
[*]Requires volume data; on symbols without volume the profile is not meaningful.
[*]A naked POC is only confirmed after its period has ended.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Naked POC Profile [Indicatr]", shorttitle="Naked POC [Indicatr]", overlay=true, max_lines_count=200, max_labels_count=100, max_boxes_count=400)

// ===== Inputs =====
grpP = "Profile"
perIn  = input.string("Auto", "Profile period", options=["Auto", "Day", "Week", "Month"], group=grpP, tooltip="Auto: Day on intraday charts, Week on daily charts, Month on weekly charts")
rows   = input.int(30, "Price rows per profile", minval=10, maxval=100, group=grpP)
vaPct  = input.float(70, "Value area (%)", minval=10, maxval=95, group=grpP) / 100

grpN = "Naked POCs"
maxKeep = input.int(15, "Maximum naked POCs on chart", minval=1, maxval=60, group=grpN)
statN   = input.int(5, "Statistics: touched within N periods", minval=1, maxval=50, group=grpN)
drawDist = input.float(2.0, "Draw naked POCs within (x average period range)", minval=0.5, step=0.5, group=grpN, tooltip="Keeps the chart scale readable. Naked POCs further away are still counted in the table.")

grpD = "Display"
showPrev = input.bool(true, "Show previous period POC / VAH / VAL", group=grpD)
showHist = input.bool(true, "Show volume profiles", group=grpD)
histN    = input.int(6, "Number of past profiles", minval=1, maxval=12, group=grpD)
histW    = input.int(60, "Profile width (% of period)", minval=10, maxval=100, group=grpD)
showTbl  = input.bool(true, "Show table", group=grpD)
colPoc   = input.color(#D9A21B, "Naked POC", group=grpD, inline="c")
colVA    = input.color(#2962FF, "Previous value area", group=grpD, inline="c")

// ===== Period =====
tf = switch perIn
    "Day"   => "D"
    "Week"  => "W"
    "Month" => "M"
    => timeframe.isintraday ? "D" : timeframe.isdaily ? "W" : "M"
newP = timeframe.change(tf)
var array<float> pRanges = array.new_float()

// ===== Volume profile from the bars of one period =====
// Each bar's volume is spread evenly across the price rows its high-low range covers.
profile(array<float> hs, array<float> ls, array<float> vs, int nRows, float pct) =>
    float poc = na
    float vah = na
    float val = na
    bins = array.new_float(nRows, 0.0)
    float pLo = na
    float step = na
    int vaLo = 0
    int vaHi = 0
    if hs.size() > 0
        pHi = hs.max()
        pLo := ls.min()
        if pHi > pLo
            step := (pHi - pLo) / nRows
            for i = 0 to hs.size() - 1
                r0 = math.max(0, math.min(nRows - 1, int(math.floor((ls.get(i) - pLo) / step))))
                r1 = math.max(0, math.min(nRows - 1, int(math.floor((hs.get(i) - pLo) / step))))
                share = vs.get(i) / (r1 - r0 + 1)
                for r = r0 to r1
                    bins.set(r, bins.get(r) + share)
            maxI = 0
            for r = 1 to nRows - 1
                if bins.get(r) > bins.get(maxI)
                    maxI := r
            total = bins.sum()
            if total > 0
                lo = maxI
                hi = maxI
                acc = bins.get(maxI)
                while acc < total * pct and (lo > 0 or hi < nRows - 1)
                    up = hi < nRows - 1 ? bins.get(hi + 1) : -1.0
                    dn = lo > 0 ? bins.get(lo - 1) : -1.0
                    if up >= dn
                        hi += 1
                        acc += up
                    else
                        lo -= 1
                        acc += dn
                poc := pLo + (maxI + 0.5) * step
                vah := pLo + (hi + 1) * step
                val := pLo + lo * step
                vaLo := lo
                vaHi := hi
    [poc, vah, val, bins, pLo, step, vaLo, vaHi]

// ===== State =====
var bH = array.new_float()
var bL = array.new_float()
var bV = array.new_float()
var nPoc   = array.new_float()
var nStart = array.new_int()
var nAge   = array.new_int()
var int perStart = 0
var int prevStart = 0
var float lastPoc = na
var float lastVah = na
var float lastVal = na
var array<float> lastBins = array.new_float()
var float lastLo = na
var float lastStep = na
var int lastVaLo = 0
var int lastVaHi = 0
var int lastLen = 0
// history of completed profiles (bins stored flat, rows per profile)
var array<float> hB  = array.new_float()
var array<int>   hS  = array.new_int()
var array<int>   hLn = array.new_int()
var array<float> hLo = array.new_float()
var array<float> hSt = array.new_float()
var array<int>   hVl = array.new_int()
var array<int>   hVh = array.new_int()
var array<float> hP  = array.new_float()
var int touchedN = 0
var int expiredN = 0

if newP and bH.size() > 0
    [p, vh, vl, bns, plo, stp, vlo, vhi] = profile(bH, bL, bV, rows, vaPct)
    lastPoc := p
    lastVah := vh
    lastVal := vl
    lastBins := bns
    lastLo := plo
    lastStep := stp
    lastVaLo := vlo
    lastVaHi := vhi
    lastLen := bar_index - perStart
    if not na(p) and bns.size() == rows
        hB.concat(bns)
        hS.push(perStart)
        hLn.push(lastLen)
        hLo.push(plo)
        hSt.push(stp)
        hVl.push(vlo)
        hVh.push(vhi)
        hP.push(p)
        while hS.size() > histN
            for q = 0 to rows - 1
                hB.shift()
            hS.shift()
            hLn.shift()
            hLo.shift()
            hSt.shift()
            hVl.shift()
            hVh.shift()
            hP.shift()
    pRanges.push(bH.max() - bL.min())
    if pRanges.size() > 20
        pRanges.shift()
    prevStart := perStart
    // age existing naked POCs by one period
    if nAge.size() > 0
        for i = 0 to nAge.size() - 1
            a = nAge.get(i) + 1
            nAge.set(i, a)
            if a == statN
                expiredN += 1
    if not na(p)
        nPoc.push(p)
        nStart.push(perStart)
        nAge.push(0)
    while nPoc.size() > maxKeep
        nPoc.shift()
        nStart.shift()
        nAge.shift()
    bH.clear()
    bL.clear()
    bV.clear()
if newP
    perStart := bar_index
bH.push(high)
bL.push(low)
bV.push(nz(volume))

// ===== Touch check: a naked POC is "filled" once a later bar trades through it =====
touchedNow = false
if nPoc.size() > 0
    for i = nPoc.size() - 1 to 0
        p = nPoc.get(i)
        if low <= p and high >= p
            if nAge.get(i) < statN
                touchedN += 1
            nPoc.remove(i)
            nStart.remove(i)
            nAge.remove(i)
            touchedNow := true

// ===== Drawing (last bar) =====
var array<line>  lns = array.new_line()
var array<label> lbs = array.new_label()
var array<box>   hbx = array.new_box()
var table tb = table.new(position.top_right, 2, 5, bgcolor=color.new(color.white, 5), frame_color=color.new(color.gray, 70), frame_width=1, border_color=color.new(color.gray, 88), border_width=1)

perName = tf == "D" ? "d" : tf == "W" ? "w" : "m"

if barstate.islast
    for l in lns
        l.delete()
    for l in lbs
        l.delete()
    for b in hbx
        b.delete()
    lns.clear()
    lbs.clear()
    hbx.clear()
    xr = bar_index + 3
    apr = pRanges.size() > 0 ? pRanges.avg() : na
    // previous period: volume profile histogram, value area and POC
    if showPrev and not na(lastPoc)
        x1 = math.max(prevStart, bar_index - 4900)
        if showHist and hS.size() > 0
            for k = 0 to hS.size() - 1
                st = hS.get(k)
                if st > bar_index - 4900
                    lo0 = hLo.get(k)
                    stp0 = hSt.get(k)
                    mx = 0.0
                    for r = 0 to rows - 1
                        mx := math.max(mx, hB.get(k * rows + r))
                    w = math.max(3, int(hLn.get(k) * histW / 100))
                    newest = k == hS.size() - 1
                    for r = 0 to rows - 1
                        len = mx > 0 ? int(math.round(hB.get(k * rows + r) / mx * w)) : 0
                        if len > 0
                            inVA = r >= hVl.get(k) and r <= hVh.get(k)
                            isPoc = math.abs(lo0 + (r + 0.5) * stp0 - hP.get(k)) < stp0 / 2
                            tVA = newest ? 60 : 70
                            col = isPoc ? color.new(colPoc, 20) : inVA ? color.new(colVA, tVA) : color.new(colVA, tVA + 18)
                            hbx.push(box.new(st, lo0 + (r + 1) * stp0, st + len, lo0 + r * stp0, border_color=color.new(color.white, 100), bgcolor=col))
        lns.push(line.new(x1, lastVah, xr, lastVah, color=color.new(colVA, 35), style=line.style_dashed))
        lns.push(line.new(x1, lastVal, xr, lastVal, color=color.new(colVA, 35), style=line.style_dashed))
        lbs.push(label.new(xr, lastVah, "VAH", style=label.style_label_left, color=color.new(color.white, 100), textcolor=colVA, size=size.small))
        lbs.push(label.new(xr, lastVal, "VAL", style=label.style_label_left, color=color.new(color.white, 100), textcolor=colVA, size=size.small))
    // naked POCs
    float nearUp = na
    float nearDn = na
    if nPoc.size() > 0
        for i = 0 to nPoc.size() - 1
            p = nPoc.get(i)
            x1 = math.max(nStart.get(i), bar_index - 4900)
            age = nAge.get(i) + 1
            if na(apr) or math.abs(p - close) <= drawDist * apr
                lns.push(line.new(x1, p, xr, p, color=color.new(colPoc, age > statN ? 45 : 0), width=2))
                lbs.push(label.new(xr, p, "nPOC " + str.tostring(age) + perName, style=label.style_label_left, color=color.new(colPoc, 10), textcolor=color.white, size=size.small))
            if p > close and (na(nearUp) or p < nearUp)
                nearUp := p
            if p < close and (na(nearDn) or p > nearDn)
                nearDn := p
    if showTbl
        hdr = color.new(color.gray, 10)
        done = touchedN + expiredN
        rate = done > 0 ? 100.0 * touchedN / done : na
        table.cell(tb, 0, 0, "Naked POCs (" + (tf == "D" ? "daily" : tf == "W" ? "weekly" : "monthly") + ")", text_color=hdr, text_size=size.small, text_halign=text.align_left)
        table.cell(tb, 1, 0, str.tostring(nPoc.size()), text_color=colPoc, text_size=size.small)
        table.cell(tb, 0, 1, "Nearest above", text_color=hdr, text_size=size.small, text_halign=text.align_left)
        table.cell(tb, 1, 1, na(nearUp) ? "-" : str.tostring(nearUp, format.mintick) + "  (+" + str.tostring((nearUp - close) / close * 100, "0.00") + " %)", text_color=color.black, text_size=size.small)
        table.cell(tb, 0, 2, "Nearest below", text_color=hdr, text_size=size.small, text_halign=text.align_left)
        table.cell(tb, 1, 2, na(nearDn) ? "-" : str.tostring(nearDn, format.mintick) + "  (-" + str.tostring((close - nearDn) / close * 100, "0.00") + " %)", text_color=color.black, text_size=size.small)
        table.cell(tb, 0, 3, "Revisited within " + str.tostring(statN) + perName, text_color=hdr, text_size=size.small, text_halign=text.align_left)
        table.cell(tb, 1, 3, na(rate) ? "-" : str.tostring(rate, "0") + " %  (n = " + str.tostring(done) + ")", text_color=color.black, text_size=size.small)
        table.cell(tb, 0, 4, "Prev POC / VAH / VAL", text_color=hdr, text_size=size.small, text_halign=text.align_left)
        table.cell(tb, 1, 4, na(lastPoc) ? "-" : str.tostring(lastPoc, format.mintick) + " / " + str.tostring(lastVah, format.mintick) + " / " + str.tostring(lastVal, format.mintick), text_color=color.black, text_size=size.small)

// ===== Alerts =====
alertcondition(touchedNow, "Naked POC touched", "Naked POC {{ticker}} {{interval}}: price traded through a naked POC ({{close}})")
alertcondition(newP, "New period profile", "Naked POC {{ticker}} {{interval}}: new profile period started, previous POC added ({{close}})")
````
