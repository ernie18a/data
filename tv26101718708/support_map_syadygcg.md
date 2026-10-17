# Support Map

- url: https://www.tradingview.com/script/sYaDygcg-Support-Map/
- type: indicator
- pine_id: PUB;d82bbcdcfab74acd9331282830f12449
- version: 1.0

## Description

SUPPORT MAP — flat support zones and inclined support, graded by durability

Most support tools mark every swing low and leave you to guess which ones matter. This one answers a different question: how long has this floor actually been respected, and is the structure above it opening up or closing in?

It draws two things.

1. FLAT SUPPORT ZONES

Support is not a line, it is a band. Price reverses across a range, not at a single tick.

Each zone is built from a swing low. The band runs from the wick low, which is the deepest point sellers reached, up to the body bottom of that same candle, where the buying finished and the candle closed. That is the price area where demand actually appeared.

Two guards keep the band sensible, both measured in ATR so the same settings work on a large cap and on a volatile small cap: the band is never thinner than a set fraction of ATR and never thicker than a set multiple of it.

Swing lows close to each other are treated as the same shelf and merged into one zone, with a touch count.

2. RISK GRADING — the core idea

Zones are not graded by how many times they were touched. They are graded by how long the touches span.

Green, LOW risk: first to last touch spans 180 bars or more, roughly three quarters
Amber, MID risk: 120 bars or more, roughly two quarters
Red, HIGH risk: 60 bars or more, roughly one quarter
Below 60 bars: not drawn

A floor that has held across three quarters has survived three earnings cycles and whatever the sector did in between. Touch count alone measures nothing like that. A zone is also discarded if price closed below it between its first and last touch, with a small allowance for noise.

3. INCLINED SUPPORT AND THE UPPER BOUNDARY

The rising support line is not drawn through two chosen points. Two-point trendlines are hostage to a single spike low: one bad anchor and the whole angle is wrong.

Instead the angle is fitted across all the swing lows in the window. The worst spikes are ignored while measuring the angle, then the line is placed so about 20% of lows sit below it. That mirrors what the eye does when you glance at a chart and see the general direction of the lows without checking each wick.

A window only qualifies if the line starts on a real low and if a minimum number of lows actually sit on it. The line must also be within a set ATR distance below current price, so it stays relevant rather than drifting off into old history.

The dashed upper line is fitted independently, never parallel. It is anchored from the highest high in the window and fitted through the highs that followed it, placed so it sits on the highs rather than through them. This matters: a parallel upper line makes every chart look like a healthy channel, which hides the one structure you most need to see.

READING THE OUTPUT

FLAT · LOW · 210d · ×3 845.5–880.8
A flat zone, low risk, touches spanning 210 bars, three touches, band from 845.5 to 880.8

INCLINED · MID · 169d · ×6 on line · base + / highs +
A rising support, mid risk, 169 bars long, six lows sitting on it, base rising and highs rising

When the highs slope down, both lines turn grey and the label adds CONVERGING. Rising lows into falling highs is a closing structure. It resolves one way or the other and the odds are not in the buyer's favour.

INPUTS WORTH ADJUSTING

Swing strength: larger values give fewer, more major levels
Risk thresholds: 180 / 120 / 60 bars, adjust to your own definition of a quarter
Merge within: raise it on high-priced stocks so nearby shelves combine
Minimum lows on the line: 4 by default, drop to 3 if no inclined line appears
Minimum span: lower it if you trade shorter horizons
Lookback: 750 bars, about three years of daily data

NOTES

Built for the daily chart, but it works on any timeframe. On the weekly it finds genuinely long-term floors, which is the right scale for positional work.

One honest limitation: it measures how many bars a low dominated, not how much time or volume price spent at that price. A long consolidation traps far more inventory than a single sharp V-bottom, and both can produce the same swing low. Your eye can tell them apart; the script cannot.

This indicator marks where buyers previously appeared. It does not generate buy or sell signals and it does not predict. Use it alongside your own trend, volume and fundamental checks.

For education only. Not investment advice.

## Source Code

````pine
//@version=6
indicator("Support Map", "SupMap", overlay = true,
     max_boxes_count = 60, max_lines_count = 60, max_labels_count = 60)

gF     = "Flat supports"
pvLen  = input.int(5,     "Swing strength",            minval = 1,    group = gF)
atrLen = input.int(14,    "ATR length",                minval = 1,    group = gF)
minH   = input.float(0.25,"Min zone height (x ATR)",   minval = 0.05, step = 0.05, group = gF)
maxH   = input.float(1.0, "Max zone height (x ATR)",   minval = 0.2,  step = 0.1,  group = gF)
mergeK = input.float(0.6, "Merge within (x ATR)",      minval = 0.1,  step = 0.1,  group = gF)
zViol  = input.int(3,     "Zone: max closes below",    minval = 0,    group = gF)
showN  = input.int(4,     "Flat zones to show",        minval = 1, maxval = 10, group = gF)

gI      = "Inclined support"
useInc  = input.bool(true, "Show inclined support / channel", group = gI)
minLows = input.int(4,     "Minimum lows ON the line", minval = 3, group = gI)
bandK   = input.float(1.0, "Low counts as on the line within (x ATR)", minval = 0.3, step = 0.1, group = gI)
pokePct = input.float(20,  "% of lows allowed below the base line", minval = 0, maxval = 40, step = 5, group = gI)
topPoke = input.float(5,   "% of highs allowed above the top line", minval = 0, maxval = 30, step = 5, group = gI)
trimPct = input.float(15,  "% worst spikes ignored when fitting angle", minval = 0, maxval = 40, step = 5, group = gI)
maxDist = input.float(6.0, "Line must be within (x ATR) below price", minval = 1.0, step = 0.5, group = gI)
minSpan = input.int(60,    "Minimum span (bars)", minval = 20, group = gI)
minHi   = input.int(3,     "Minimum highs to fit the top line", minval = 2, group = gI)

gS   = "Risk grading (both)"
dLow = input.int(180, "LOW risk  : span >= bars", minval = 20, group = gS)
dMid = input.int(120, "MID risk  : span >= bars", minval = 10, group = gS)
dHigh= input.int(60,  "HIGH risk : span >= bars", minval = 5,  group = gS)

gG     = "General"
lookbk = input.int(750, "Lookback (bars)", minval = 100, group = gG)
tolATR = input.float(0.25, "Zone dip tolerance (x ATR)", minval = 0.0, step = 0.05, group = gG)
cLow   = input.color(color.green,  "LOW risk",  group = gG)
cMid   = input.color(color.orange, "MID risk",  group = gG)
cHigh  = input.color(color.red,    "HIGH risk", group = gG)
cConv  = input.color(color.gray,   "Converging (no trade)", group = gG)

plot(close, "ref", color = color.new(color.gray, 100), display = display.pane, editable = false)

atr = ta.atr(atrLen)
ph  = ta.pivothigh(high, pvLen, pvLen)
pl  = ta.pivotlow(low,  pvLen, pvLen)

var array<float> cls  = array.new<float>()
var int          bas0 = na
if na(bas0)
    bas0 := bar_index
array.push(cls, close)
if array.size(cls) > lookbk
    array.shift(cls)
    bas0 += 1

f_close(int b) =>
    int i = b - bas0
    i >= 0 and i < array.size(cls) ? array.get(cls, i) : na

var array<float> plP = array.new<float>()
var array<int>   plB = array.new<int>()
var array<float> phP = array.new<float>()
var array<int>   phB = array.new<int>()

var array<float> zLo = array.new<float>()
var array<float> zHi = array.new<float>()
var array<int>   zTc = array.new<int>()
var array<int>   zF  = array.new<int>()
var array<int>   zL  = array.new<int>()

var array<box>   bxs = array.new<box>()
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()

if not na(pl) and not na(atr)
    int   pb   = bar_index - pvLen
    float lo   = pl
    float body = math.min(open[pvLen], close[pvLen])
    float hi   = math.max(lo + atr * minH, math.min(body, lo + atr * maxH))

    array.push(plP, lo)
    array.push(plB, pb)

    int hit = -1
    if array.size(zLo) > 0
        for i = 0 to array.size(zLo) - 1
            float a = array.get(zLo, i)
            float b = array.get(zHi, i)
            if lo <= b + atr * mergeK and hi >= a - atr * mergeK
                hit := i
    if hit >= 0
        array.set(zLo, hit, math.min(array.get(zLo, hit), lo))
        array.set(zHi, hit, math.max(array.get(zHi, hit), hi))
        array.set(zTc, hit, array.get(zTc, hit) + 1)
        array.set(zL,  hit, pb)
    else
        array.push(zLo, lo)
        array.push(zHi, hi)
        array.push(zTc, 1)
        array.push(zF,  pb)
        array.push(zL,  pb)

if not na(ph)
    array.push(phP, ph)
    array.push(phB, bar_index - pvLen)

if array.size(plB) > 0
    if array.get(plB, 0) < bar_index - lookbk
        array.shift(plP)
        array.shift(plB)
if array.size(phB) > 0
    if array.get(phB, 0) < bar_index - lookbk
        array.shift(phP)
        array.shift(phB)
if array.size(zLo) > 0
    for i = array.size(zLo) - 1 to 0
        if array.get(zL, i) < bar_index - lookbk
            array.remove(zLo, i)
            array.remove(zHi, i)
            array.remove(zTc, i)
            array.remove(zF,  i)
            array.remove(zL,  i)

if barstate.islast and not na(atr)
    if array.size(bxs) > 0
        for i = 0 to array.size(bxs) - 1
            box.delete(array.get(bxs, i))
    if array.size(lns) > 0
        for i = 0 to array.size(lns) - 1
            line.delete(array.get(lns, i))
    if array.size(lbs) > 0
        for i = 0 to array.size(lbs) - 1
            label.delete(array.get(lbs, i))
    array.clear(bxs)
    array.clear(lns)
    array.clear(lbs)

    array<int> cand = array.new<int>()
    if array.size(zLo) > 0
        for i = 0 to array.size(zLo) - 1
            float zl   = array.get(zLo, i)
            float zh   = array.get(zHi, i)
            int   span = array.get(zL, i) - array.get(zF, i)
            if array.get(zTc, i) >= 2 and span >= dHigh and zh < close
                int v = 0
                for b = array.get(zF, i) to array.get(zL, i)
                    float c = f_close(b)
                    if not na(c) and c < zl - atr * tolATR
                        v += 1
                if v <= zViol
                    array.push(cand, i)

    int n = math.min(showN, array.size(cand))
    if n > 0
        for c = 1 to n
            int   pick = -1
            float top  = -1e20
            for k = 0 to array.size(cand) - 1
                int   id = array.get(cand, k)
                float t  = array.get(zHi, id)
                if t > top
                    top  := t
                    pick := k
            int id = array.get(cand, pick)
            array.remove(cand, pick)

            int    span = array.get(zL, id) - array.get(zF, id)
            color  gc   = span >= dLow ? cLow : span >= dMid ? cMid : cHigh
            string gt   = span >= dLow ? "LOW" : span >= dMid ? "MID" : "HIGH"

            box b = box.new(array.get(zF, id), array.get(zHi, id),
                 bar_index + 20, array.get(zLo, id),
                 xloc = xloc.bar_index, border_color = color.new(gc, 40),
                 border_width = 1, bgcolor = color.new(gc, 85), force_overlay = true)
            array.push(bxs, b)

            label l = label.new(bar_index + 20 + (c - 1) * 22, array.get(zHi, id),
                 "FLAT · " + gt + " · " + str.tostring(span) + "d · ×" +
                 str.tostring(array.get(zTc, id)) + "  " +
                 str.tostring(array.get(zLo, id), format.mintick) + "–" +
                 str.tostring(array.get(zHi, id), format.mintick),
                 xloc = xloc.bar_index, style = label.style_label_left,
                 color = color.new(gc, 85), textcolor = gc, size = size.small,
                 force_overlay = true)
            array.push(lbs, l)

    int m = array.size(plB)
    if useInc and m >= minLows
        int   bS  = -1
        float bSl = na
        float bIc = na
        int   bN  = 0
        float bSc = -1e20
        array<float> res = array.new<float>()

        for s = 0 to m - minLows
            int   b0 = array.get(plB, s)
            int   cN = m - s
            float sx = 0.0
            float sy = 0.0
            float sxy = 0.0
            float sxx = 0.0
            for k = s to m - 1
                float x = array.get(plB, k) - b0
                float y = array.get(plP, k)
                sx  += x
                sy  += y
                sxy += x * y
                sxx += x * x
            float den = cN * sxx - sx * sx
            if den != 0
                float sl1 = (cN * sxy - sx * sy) / den
                float ic1 = (sy - sl1 * sx) / cN

                array.clear(res)
                for k = s to m - 1
                    float x = array.get(plB, k) - b0
                    array.push(res, array.get(plP, k) - (ic1 + sl1 * x))
                float cut = array.percentile_linear_interpolation(res, trimPct)

                float tx  = 0.0
                float ty  = 0.0
                float txy = 0.0
                float txx = 0.0
                int   tN  = 0
                for k = s to m - 1
                    float x = array.get(plB, k) - b0
                    float y = array.get(plP, k)
                    if y - (ic1 + sl1 * x) >= cut
                        tx  += x
                        ty  += y
                        txy += x * y
                        txx += x * x
                        tN  += 1
                float den2 = tN * txx - tx * tx
                float sl2  = (tN >= 2 and den2 != 0) ? (tN * txy - tx * ty) / den2 : sl1

                array.clear(res)
                for k = s to m - 1
                    float x = array.get(plB, k) - b0
                    array.push(res, array.get(plP, k) - sl2 * x)
                float ic2 = array.percentile_linear_interpolation(res, pokePct)

                float d0 = array.get(plP, s) - ic2
                bool startsOnLow = d0 >= -atr * 0.5 and d0 <= atr * bandK

                int onLine = 0
                for k = s to m - 1
                    float d = array.get(plP, k) - (ic2 + sl2 * (array.get(plB, k) - b0))
                    if d >= -atr * 0.5 and d <= atr * bandK
                        onLine += 1

                float now  = ic2 + sl2 * (bar_index - b0)
                int   span = bar_index - b0
                if sl2 > 0 and startsOnLow and onLine >= minLows and span >= minSpan and now < close and close - now <= atr * maxDist
                    if span > bSc
                        bSc := span
                        bS  := s
                        bSl := sl2
                        bIc := ic2
                        bN  := onLine

        if bS >= 0
            int    b0   = array.get(plB, bS)
            int    span = bar_index - b0
            color  rc   = span >= dLow ? cLow : span >= dMid ? cMid : cHigh
            string gt   = span >= dLow ? "LOW" : span >= dMid ? "MID" : "HIGH"

            array<float> hxs = array.new<float>()
            array<float> hys = array.new<float>()
            array<int>   hbs = array.new<int>()
            if array.size(phB) > 0
                for k = 0 to array.size(phB) - 1
                    int bk = array.get(phB, k)
                    if bk >= b0
                        array.push(hxs, bk - b0)
                        array.push(hys, array.get(phP, k))
                        array.push(hbs, bk)

            int hStart = 0
            int hTot   = array.size(hys)
            if hTot > 0
                int   pkI = 0
                float pkV = -1e20
                for k = 0 to hTot - 1
                    if array.get(hys, k) > pkV
                        pkV := array.get(hys, k)
                        pkI := k
                if hTot - pkI >= minHi
                    hStart := pkI

            float hSl   = na
            float hIc   = na
            int   hFrom = hTot > 0 ? array.get(hbs, hStart) : b0
            int   hN    = hTot - hStart

            if hN >= minHi
                array<float> hres = array.new<float>()
                float ax  = 0.0
                float ay  = 0.0
                float axy = 0.0
                float axx = 0.0
                for k = hStart to hTot - 1
                    float x = array.get(hxs, k)
                    float y = array.get(hys, k)
                    ax  += x
                    ay  += y
                    axy += x * y
                    axx += x * x
                float aden = hN * axx - ax * ax
                if aden != 0
                    float hs1 = (hN * axy - ax * ay) / aden
                    float hi1 = (ay - hs1 * ax) / hN

                    // drop the WEAK highs, keep the peak
                    array.clear(hres)
                    for k = hStart to hTot - 1
                        array.push(hres, array.get(hys, k) - (hi1 + hs1 * array.get(hxs, k)))
                    float hcut = array.percentile_linear_interpolation(hres, trimPct)

                    float bx  = 0.0
                    float bsy = 0.0
                    float bxy = 0.0
                    float bxx = 0.0
                    int   bN2 = 0
                    for k = hStart to hTot - 1
                        float x = array.get(hxs, k)
                        float y = array.get(hys, k)
                        if y - (hi1 + hs1 * x) >= hcut
                            bx  += x
                            bsy += y
                            bxy += x * y
                            bxx += x * x
                            bN2 += 1
                    float bden = bN2 * bxx - bx * bx
                    hSl := (bN2 >= 2 and bden != 0) ? (bN2 * bxy - bx * bsy) / bden : hs1

                    // sit the line ON the highs
                    array.clear(hres)
                    for k = hStart to hTot - 1
                        array.push(hres, array.get(hys, k) - hSl * array.get(hxs, k))
                    hIc := array.percentile_linear_interpolation(hres, 100 - topPoke)

            float  thr  = atr * 0.5 / 100
            bool   conv = not na(hSl) and hSl < -thr
            color  gc   = conv ? cConv : rc

            line lb = line.new(b0, bIc, bar_index + 20, bIc + bSl * (bar_index + 20 - b0),
                 xloc = xloc.bar_index, color = gc, width = 2, force_overlay = true)
            array.push(lns, lb)

            if not na(hSl)
                line lt = line.new(hFrom, hIc + hSl * (hFrom - b0), bar_index + 20,
                     hIc + hSl * (bar_index + 20 - b0),
                     xloc = xloc.bar_index, color = gc, width = 2,
                     style = line.style_dashed, force_overlay = true)
                array.push(lns, lt)

            string bTx = bSl > thr ? "base +" : "base flat"
            string tTx = na(hSl) ? "highs ?" : hSl > thr ? "highs +" : hSl < -thr ? "highs −" : "highs flat"
            string sTx = conv ? "  CONVERGING" : ""

            label lc = label.new(bar_index + 20, bIc + bSl * (bar_index + 20 - b0),
                 "INCLINED · " + gt + " · " + str.tostring(span) + "d · ×" +
                 str.tostring(bN) + " on line · " + bTx + " / " + tTx + sTx,
                 xloc = xloc.bar_index, style = label.style_label_left,
                 color = color.new(gc, 85), textcolor = gc, size = size.small,
                 force_overlay = true)
            array.push(lbs, lc)
````
