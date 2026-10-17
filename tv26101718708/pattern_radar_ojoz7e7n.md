# Pattern Radar

- url: https://www.tradingview.com/script/oJoz7E7N-Pattern-Radar/
- type: indicator
- pine_id: PUB;5c7aa407448c49e993f9a8c6739530ed
- version: 1.0

## Description

═════════════════════════════════════════════════════════════
 PATTERN RADAR  —  Broadening & Wedge family (8 patterns)
═════════════════════════════════════════════════════════════
DISCLAIMER
 This indicator is for study and knowledge purposes only. It is not trading
 or investment advice. Always apply your own entry, exit and risk rules.

  WHAT IT DOES
  ------------
  Scans the chart for the eight megaphone / wedge formations described in
  Thomas Bulkowski's pattern research, paints EVERY occurrence in the loaded
  history, and names the pattern price is building RIGHT NOW on whatever
  timeframe the chart is set to (the engine runs on chart bars, 1m … Monthly).

  THE EIGHT PATTERNS  (one geometry engine + one classifier)
  ---------------------------------------------------------------------------
   #  Pattern                              Upper line   Lower line    Gap
   1  Ascending Broadening Wedge           up           up (shallow)  widening   needs 3 peaks + 3 valleys
   2  Descending Broadening Wedge          down(shal.)  down          widening   needs 5 touches (3+2)
   3  Rising Wedge                         up           up (steeper)  narrowing  needs 5 touches (3+2)
   4  Falling Wedge                        down         down(steeper) narrowing  needs 5 touches (3+2)
   5  Broadening Top                       up           down          widening   after an up-move
  6  Broadening Bottom                    up           down          widening   after a down-move
   7  Broadening Right-Angled Ascending    up           flat          widening
 8  Broadening Right-Angled Descending   flat         down          widening

  HOW A PATTERN IS FOUND (confirmed pivots + bar close → no repainting)
  ---------------------------------------------------------------------------
   1. Swing pivots are collected at two scales: MINOR (small) and MAJOR (large).
   2. On every new pivot, the last 3 highs + last 3 lows (or 3+2 / 2+3) are
     fitted with least-squares trendlines.
   3. Validation: each pivot must sit within tolerance of its line, closes must
      stay inside the lines (max N exceptions), minimum length and height (ATR).
  4. Classification uses only the slope of the upper line, the slope of the
      lower line, and whether the gap between them widens or narrows.
   5. Resolution: first close beyond a trendline = breakout (▲/▼). If the lines
      cross or the pattern outlives its allowed time, it closes as "no breakout".
   6. Targets:
       • Ascending Broadening Wedge  — published measure rule: down = lowest
         valley; up = breakout + 61% × (highest peak − lowest valley).
        • Descending Broadening Wedge — published measure rule: up = highest
         peak; down = lowest valley − 32% × (highest peak − lowest valley).
       • Other patterns              — generic height projection from the
         breakout close (multiplier is an input).

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//  PATTERN RADAR  —  Broadening & Wedge family (8 patterns)
// ═══════════════════════════════════════════════════════════════════════════════
//
//  DISCLAIMER
//  This indicator is for study and knowledge purposes only. It is not trading
//  or investment advice. Always apply your own entry, exit and risk rules.
//
//  WHAT IT DOES
//  ------------
//  Scans the chart for the eight megaphone / wedge formations described in
//  Thomas Bulkowski's pattern research, paints EVERY occurrence in the loaded
//  history, and names the pattern price is building RIGHT NOW on whatever
//  timeframe the chart is set to (the engine runs on chart bars, 1m … Monthly).
//
//  THE EIGHT PATTERNS  (one geometry engine + one classifier)
//  ---------------------------------------------------------------------------
//   #  Pattern                              Upper line   Lower line    Gap
//   1  Ascending Broadening Wedge           up           up (shallow)  widening   needs 3 peaks + 3 valleys
//   2  Descending Broadening Wedge          down(shal.)  down          widening   needs 5 touches (3+2)
//   3  Rising Wedge                         up           up (steeper)  narrowing  needs 5 touches (3+2)
//   4  Falling Wedge                        down         down(steeper) narrowing  needs 5 touches (3+2)
//   5  Broadening Top                       up           down          widening   after an up-move
//   6  Broadening Bottom                    up           down          widening   after a down-move
//   7  Broadening Right-Angled Ascending    up           flat          widening
//   8  Broadening Right-Angled Descending   flat         down          widening
//
//  HOW A PATTERN IS FOUND (confirmed pivots + bar close → no repainting)
//  ---------------------------------------------------------------------------
//   1. Swing pivots are collected at two scales: MINOR (small) and MAJOR (large).
//   2. On every new pivot, the last 3 highs + last 3 lows (or 3+2 / 2+3) are
//      fitted with least-squares trendlines.
//   3. Validation: each pivot must sit within tolerance of its line, closes must
//      stay inside the lines (max N exceptions), minimum length and height (ATR).
//   4. Classification uses only the slope of the upper line, the slope of the
//      lower line, and whether the gap between them widens or narrows.
//   5. Resolution: first close beyond a trendline = breakout (▲/▼). If the lines
//      cross or the pattern outlives its allowed time, it closes as "no breakout".
//   6. Targets:
//        • Ascending Broadening Wedge  — published measure rule: down = lowest
//          valley; up = breakout + 61% × (highest peak − lowest valley).
//        • Descending Broadening Wedge — published measure rule: up = highest
//          peak; down = lowest valley − 32% × (highest peak − lowest valley).
//        • Other patterns              — generic height projection from the
//          breakout close (multiplier is an input).
//
//  DISPLAY
//  ---------------------------------------------------------------------------
//   • One horizontal dashboard, 9 placements, auto / dark / light theme.
//   • Pattern line width (minor / major) and line type are user inputs.
//   • Breakout marker size: Nano · Micro · Tiny · Small.
//   • Pine keeps at most 500 lines / 500 labels, so very long histories keep the
//     most recent ~150 completed patterns drawn. The history strip counts all.
// ═══════════════════════════════════════════════════════════════════════════════
indicator("Pattern Radar", shorttitle="PatRadar", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=2000)

// ─────────────────────────────── INPUTS ─────────────────────────────────────
G1 = "① Detection engine"
G2 = "② Pattern filters"
G3 = "③ Lines, markers & targets"
G4 = "④ Dashboard & theme"
G5 = "⑤ Pattern colours"

useMinor = input.bool(true, "Minor scale", inline="mn", group=G1, tooltip="Catches smaller formations.")
pvMinor  = input.int(4, "pivot bars", minval=2, maxval=30, inline="mn", group=G1)
useMajor = input.bool(true, "Major scale", inline="mj", group=G1, tooltip="Catches larger formations.")
pvMajor  = input.int(10, "pivot bars", minval=3, maxval=60, inline="mj", group=G1)
tolMult  = input.float(0.6, "Touch tolerance (× ATR)", minval=0.1, step=0.1, group=G1, tooltip="How far a pivot may sit from its trendline and still count as a touch.")
maxViol  = input.int(2, "Max closes outside lines", minval=0, maxval=20, group=G1)
minLen   = input.int(20, "Min pattern length (bars)", minval=8, group=G1)
maxLen   = input.int(300, "Max pattern length (bars)", minval=30, maxval=500, group=G1)
minHgt   = input.float(2.0, "Min pattern height (× ATR)", minval=0.5, step=0.5, group=G1)

flatFrac = input.float(0.25, "Flat line = moves < (× pattern height)", minval=0.05, maxval=1.0, step=0.05, group=G2, tooltip="Used to recognise the flat side of right-angled broadening patterns.")
divPct   = input.float(12.0, "Gap change to call widen / narrow (%)", minval=1.0, maxval=60.0, step=1.0, group=G2) / 100.0
expMult  = input.float(1.0, "Expire after (× pattern length)", minval=0.25, step=0.25, group=G2, tooltip="A pattern with no breakout inside this window is closed as 'no breakout'.")
brkBuf   = input.float(0.0, "Breakout buffer (× ATR)", minval=0.0, step=0.1, group=G2)

wMinor    = input.int(1, "Line width · minor", minval=1, maxval=6, inline="lw", group=G3)
wMajor    = input.int(2, "major", minval=1, maxval=6, inline="lw", group=G3)
lineStyleIn = input.string("Solid", "Line type", options=["Solid", "Dashed", "Dotted"], group=G3)
mkIn      = input.string("Micro", "Breakout marker size", options=["Nano", "Micro", "Tiny", "Small"], group=G3, tooltip="Nano and Micro use point sizes smaller than Pine's Tiny.")
tgtMult   = input.float(1.0, "Generic target multiplier (patterns 3-8)", minval=0.1, step=0.1, group=G3)
tgtLen    = input.int(30, "Target line length (bars)", minval=5, maxval=100, group=G3)

showPanel = input.bool(true, "Show dashboard", group=G4)
dashPosIn = input.string("Top Right", "Dashboard position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=G4)
dashSzIn  = input.string("Small", "Dashboard text size", options=["Tiny", "Small", "Normal"], group=G4)
showHist  = input.bool(true, "Show history strip", group=G4)
themeSel  = input.string("Auto", "Theme", options=["Auto", "Dark", "Light"], group=G4, tooltip="Auto follows the chart background.")

kOn1 = input.bool(true, "1 Ascending Broadening Wedge", inline="k1", group=G5)
kC1  = input.color(#E8B04A, "", inline="k1", group=G5)
kOn2 = input.bool(true, "2 Descending Broadening Wedge", inline="k2", group=G5)
kC2  = input.color(#35C2B0, "", inline="k2", group=G5)
kOn3 = input.bool(true, "3 Rising Wedge", inline="k3", group=G5)
kC3  = input.color(#E5533D, "", inline="k3", group=G5)
kOn4 = input.bool(true, "4 Falling Wedge", inline="k4", group=G5)
kC4  = input.color(#4CC38A, "", inline="k4", group=G5)
kOn5 = input.bool(true, "5 Broadening Top", inline="k5", group=G5)
kC5  = input.color(#C46BDB, "", inline="k5", group=G5)
kOn6 = input.bool(true, "6 Broadening Bottom", inline="k6", group=G5)
kC6  = input.color(#5AA9FF, "", inline="k6", group=G5)
kOn7 = input.bool(true, "7 Right-Angled Ascending", inline="k7", group=G5)
kC7  = input.color(#F0883E, "", inline="k7", group=G5)
kOn8 = input.bool(true, "8 Right-Angled Descending", inline="k8", group=G5)
kC8  = input.color(#A3D14B, "", inline="k8", group=G5)

// ──────────────────────── THEME, STYLE & PLACEMENT ──────────────────────────
color bgC = chart.bg_color
float luma = 0.0
if not na(bgC)
    luma := (0.299 * color.r(bgC) + 0.587 * color.g(bgC) + 0.114 * color.b(bgC)) / 255.0
bool isDark = themeSel == "Dark" or (themeSel == "Auto" and luma < 0.5)

color cBg    = isDark ? color.new(#141A3C, 4) : color.new(#F7F8FC, 4)
color cHdr   = isDark ? #1F2860 : #E3E7F4
color cGold  = isDark ? #E8B04A : #A8730F
color cText  = isDark ? #E7EAF5 : #141A3C
color cMute  = isDark ? #8E98BC : #5B6485
color cVerm  = isDark ? #E5533D : #C93A26
color cGreen = isDark ? #4CC38A : #1B8A5A

string lsPat = switch lineStyleIn
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid
string lsExp = lsPat == line.style_dotted ? line.style_dashed : line.style_dotted

int mkPt = switch mkIn
    "Nano"  => 4
    "Micro" => 6
    "Tiny"  => 8
    => 10

string dashPos = switch dashPosIn
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

string dashSz = switch dashSzIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

// Pattern colours are darkened a little on light backgrounds for contrast.
f_adj(color c) =>
    isDark ? c : color.rgb(color.r(c) * 0.78, color.g(c) * 0.78, color.b(c) * 0.78)

// ─────────────────────────── CONSTANT TABLES ────────────────────────────────
var array<bool>   kindOn    = array.from(kOn1, kOn2, kOn3, kOn4, kOn5, kOn6, kOn7, kOn8)
var array<color>  kindCol   = array.from(f_adj(kC1), f_adj(kC2), f_adj(kC3), f_adj(kC4), f_adj(kC5), f_adj(kC6), f_adj(kC7), f_adj(kC8))
var array<string> kindName  = array.from("Ascending Broadening Wedge", "Descending Broadening Wedge", "Rising Wedge", "Falling Wedge", "Broadening Top", "Broadening Bottom", "Broadening Right-Angled Ascending", "Broadening Right-Angled Descending")
var array<string> kindShort = array.from("ABW", "DBW", "RW", "FW", "BT", "BB", "RAA", "RAD")
var array<string> kindBias  = array.from("Bulkowski: breaks down 52% / up 48%", "Bulkowski: breaks up 72% / down 28%", "Bias not set", "Bias not set", "Bias not set", "Bias not set", "Bias not set", "Bias not set")

var array<int> sCnt = array.new<int>(8, 0)
var array<int> sUp  = array.new<int>(8, 0)
var array<int> sDn  = array.new<int>(8, 0)
var array<int> sNb  = array.new<int>(8, 0)

float atrV = ta.atr(14)

// ─────────────────────────────── TYPES ──────────────────────────────────────
type Pat
    bool     on  = false
    int      kind = 0
    int      x0
    int      x1
    float    slU
    float    icU
    float    slL
    float    icL
    float    hi
    float    lo
    int      nH
    int      nL
    line     lnU
    line     lnL
    linefill fl
    label    tag

type Eng
    int          p
    array<int>   hiBar
    array<float> hiPx
    array<int>   loBar
    array<float> loPx
    int          lock
    Pat          act
    int          w
    bool         major

// ───────────────────────────── GEOMETRY ─────────────────────────────────────
// Least-squares line through (x, y) points. x is taken relative to xRef.
// Returns [slope per bar, value of the line at xRef].
f_fit(array<int> xs, array<float> ys, int xRef) =>
    int n = array.size(xs)
    float mx = 0.0
    float my = 0.0
    for i = 0 to n - 1
        mx += array.get(xs, i) - xRef
        my += array.get(ys, i)
    mx /= n
    my /= n
    float sxx = 0.0
    float sxy = 0.0
    for i = 0 to n - 1
        float dx = (array.get(xs, i) - xRef) - mx
        sxx += dx * dx
        sxy += dx * (array.get(ys, i) - my)
    float sl = sxx > 0 ? sxy / sxx : 0.0
    [sl, my - sl * mx]

// Store newly confirmed pivots in the engine. Returns true if anything was added.
f_ingest(Eng e, float ph, float pl) =>
    bool added = false
    if not na(ph)
        array.push(e.hiBar, bar_index - e.p)
        array.push(e.hiPx, ph)
        if array.size(e.hiBar) > 30
            array.shift(e.hiBar)
            array.shift(e.hiPx)
        added := true
    if not na(pl)
        array.push(e.loBar, bar_index - e.p)
        array.push(e.loPx, pl)
        if array.size(e.loBar) > 30
            array.shift(e.loBar)
            array.shift(e.loPx)
        added := true
    added

// Price target for a pattern that broke out in direction d (1 up, -1 down) at close brk.
f_target(Pat p, int d, float brk) =>
    float h = p.hi - p.lo
    float t = na
    if p.kind == 1
        t := d == -1 ? p.lo : brk + 0.61 * h
    else if p.kind == 2
        t := d == 1 ? p.hi : p.lo - 0.32 * h
    else
        t := d == 1 ? brk + tgtMult * h : brk - tgtMult * h
    t

// Try to build a pattern from the last nH highs and nL lows.
f_detect(Eng e, int nH, int nL) =>
    Pat res = Pat.new()
    int szH = array.size(e.hiBar)
    int szL = array.size(e.loBar)
    if szH >= nH and szL >= nL and not na(atrV)
        array<int>   xh = array.new<int>()
        array<float> yh = array.new<float>()
        array<int>   xl = array.new<int>()
        array<float> yl = array.new<float>()
        for i = szH - nH to szH - 1
            array.push(xh, array.get(e.hiBar, i))
            array.push(yh, array.get(e.hiPx, i))
        for i = szL - nL to szL - 1
            array.push(xl, array.get(e.loBar, i))
            array.push(yl, array.get(e.loPx, i))
        int x0 = math.min(array.get(xh, 0), array.get(xl, 0))
        int x1 = math.max(array.get(xh, nH - 1), array.get(xl, nL - 1))
        int span = x1 - x0
        if x0 > e.lock and span >= minLen and span <= maxLen
            [sU, cU] = f_fit(xh, yh, x0)
            [sL, cL] = f_fit(xl, yl, x0)
            float tol = tolMult * atrV
            bool ok = true
            // every pivot must touch its line
            for i = 0 to nH - 1
                if math.abs(array.get(yh, i) - (cU + sU * (array.get(xh, i) - x0))) > tol
                    ok := false
            for i = 0 to nL - 1
                if math.abs(array.get(yl, i) - (cL + sL * (array.get(xl, i) - x0))) > tol
                    ok := false
            float gS = cU - cL
            float gE = (cU + sU * span) - (cL + sL * span)
            float avgG = (gS + gE) / 2.0
            if ok and (gS <= 0 or gE <= 0 or avgG < minHgt * atrV)
                ok := false
            // closes must stay inside the lines
            if ok
                int viol = 0
                for b = x0 to x1
                    float cl = close[bar_index - b]
                    float uV = cU + sU * (b - x0)
                    float lV = cL + sL * (b - x0)
                    if cl > uV + tol or cl < lV - tol
                        viol += 1
                if viol > maxViol
                    ok := false
            if ok
                float dU = sU * span
                float dL = sL * span
                float flt = flatFrac * avgG
                bool uUp = dU > flt
                bool uDn = dU < -flt
                bool uFl = not uUp and not uDn
                bool lUp = dL > flt
                bool lDn = dL < -flt
                bool lFl = not lUp and not lDn
                bool widen = gE > gS * (1.0 + divPct)
                bool conv  = gE < gS * (1.0 - divPct)
                int pre = x0 - span
                float c0 = close[bar_index - x0]
                float cPre = c0
                if pre >= 0
                    cPre := close[bar_index - pre]
                bool priorUp = c0 >= cPre
                int kind = 0
                if widen
                    if uUp and lDn
                        kind := priorUp ? 5 : 6
                    else if uUp and lUp
                        kind := 1
                    else if uDn and lDn
                        kind := 2
                    else if uUp and lFl
                        kind := 7
                    else if uFl and lDn
                        kind := 8
                else if conv
                    if uUp and lUp
                        kind := 3
                    else if uDn and lDn
                        kind := 4
                if kind == 1 and not (nH == 3 and nL == 3)
                    kind := 0
                if kind > 0
                    if not array.get(kindOn, kind - 1)
                        kind := 0
                if kind > 0
                    res.on := true
                    res.kind := kind
                    res.x0 := x0
                    res.x1 := x1
                    res.slU := sU
                    res.icU := cU
                    res.slL := sL
                    res.icL := cL
                    res.hi := array.max(yh)
                    res.lo := array.min(yl)
                    res.nH := nH
                    res.nL := nL
    res

// Scan bars fromBar … bar_index for a close beyond a trendline.
// Returns [dir, bar]: 1 = up breakout, -1 = down breakout, 2 = expired / lines crossed, 0 = still developing.
f_scan(Pat p, int fromBar) =>
    int dir = 0
    int bb = bar_index
    if fromBar <= bar_index
        float bt = brkBuf * atrV
        for b = fromBar to bar_index
            float uV = p.icU + p.slU * (b - p.x0)
            float lV = p.icL + p.slL * (b - p.x0)
            float cl = close[bar_index - b]
            if cl > uV + bt
                dir := 1
                bb := b
                break
            else if cl < lV - bt
                dir := -1
                bb := b
                break
            else if uV - lV <= 0 or (b - p.x1) > expMult * (p.x1 - p.x0)
                dir := 2
                bb := b
                break
    [dir, bb]

// ───────────────────────────── DRAWING ──────────────────────────────────────
f_draw(Pat p, int xEnd, Eng e) =>
    color col = array.get(kindCol, p.kind - 1)
    float yU1 = p.icU + p.slU * (xEnd - p.x0)
    float yL1 = p.icL + p.slL * (xEnd - p.x0)
    p.lnU := line.new(x1=p.x0, y1=p.icU, x2=xEnd, y2=yU1, xloc=xloc.bar_index, extend=extend.none, color=col, style=lsPat, width=e.w)
    p.lnL := line.new(x1=p.x0, y1=p.icL, x2=xEnd, y2=yL1, xloc=xloc.bar_index, extend=extend.none, color=col, style=lsPat, width=e.w)
    p.fl  := linefill.new(p.lnU, p.lnL, color.new(col, 88))
    int xm = math.round((p.x0 + xEnd) / 2.0)
    float ym = p.icU + p.slU * (xm - p.x0)
    string nm = array.get(kindName, p.kind - 1)
    if e.major
        p.tag := label.new(x=xm, y=ym, text=nm + "\n(developing)", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(col, 15), style=label.style_label_down, textcolor=color.white, size=size.small)
    else
        p.tag := label.new(x=xm, y=ym, text=nm + "\n(developing)", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(col, 15), style=label.style_label_down, textcolor=color.white, size=size.tiny)

f_upd(Pat p) =>
    float yU = p.icU + p.slU * (bar_index - p.x0)
    float yL = p.icL + p.slL * (bar_index - p.x0)
    line.set_xy2(p.lnU, bar_index, yU)
    line.set_xy2(p.lnL, bar_index, yL)
    int xm = math.round((p.x0 + bar_index) / 2.0)
    float ym = p.icU + p.slU * (xm - p.x0)
    label.set_xy(p.tag, xm, ym)

f_finish(Pat p, int d, int bb) =>
    color col = array.get(kindCol, p.kind - 1)
    int k = p.kind - 1
    float yU = p.icU + p.slU * (bb - p.x0)
    float yL = p.icL + p.slL * (bb - p.x0)
    line.set_xy2(p.lnU, bb, yU)
    line.set_xy2(p.lnL, bb, yL)
    int xm = math.round((p.x0 + bb) / 2.0)
    float ym = p.icU + p.slU * (xm - p.x0)
    label.set_xy(p.tag, xm, ym)
    string nm = array.get(kindName, k)
    array.set(sCnt, k, array.get(sCnt, k) + 1)
    if d == 2
        line.set_style(p.lnU, lsExp)
        line.set_style(p.lnL, lsExp)
        linefill.delete(p.fl)
        label.set_text(p.tag, nm + "\n(no breakout)")
        label.set_color(p.tag, color.new(color.gray, 25))
        array.set(sNb, k, array.get(sNb, k) + 1)
    else
        float cl = close[bar_index - bb]
        float tgt = f_target(p, d, cl)
        label.set_text(p.tag, nm + (d == 1 ? "\n▲ Up breakout" : "\n▼ Down breakout"))
        label.set_tooltip(p.tag, "Touches: " + str.tostring(p.nH) + " highs / " + str.tostring(p.nL) + " lows\nHeight: " + str.tostring(p.hi - p.lo, format.mintick) + "\nTarget: " + str.tostring(tgt, format.mintick))
        float my = d == 1 ? low[bar_index - bb] : high[bar_index - bb]
        if d == 1
            label.new(x=bb, y=my, text="", xloc=xloc.bar_index, yloc=yloc.price, color=col, style=label.style_triangleup, size=mkPt)
        else
            label.new(x=bb, y=my, text="", xloc=xloc.bar_index, yloc=yloc.price, color=col, style=label.style_triangledown, size=mkPt)
        line.new(x1=bb, y1=tgt, x2=bb + tgtLen, y2=tgt, xloc=xloc.bar_index, extend=extend.none, color=col, style=line.style_dashed, width=1)
        label.new(x=bb + tgtLen, y=tgt, text="T " + str.tostring(tgt, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, color=color.new(col, 100), style=label.style_label_left, textcolor=col, size=size.tiny)
        if d == 1
            array.set(sUp, k, array.get(sUp, k) + 1)
        else
            array.set(sDn, k, array.get(sDn, k) + 1)

// One engine step per confirmed bar. Returns [newKind, breakoutDir] for alerts.
f_step(Eng e, float ph, float pl, bool go) =>
    int newK = 0
    int boD = 0
    if go
        bool fresh = f_ingest(e, ph, pl)
        // 1) manage the developing pattern
        if e.act.on
            [d, bb] = f_scan(e.act, bar_index)
            if d != 0
                f_finish(e.act, d, bb)
                if d != 2
                    boD := d
                e.lock := bb
                e.act := Pat.new()
            else
                f_upd(e.act)
        // 2) look for a new pattern when a fresh pivot appeared
        if fresh and not e.act.on
            Pat c = f_detect(e, 3, 3)
            if not c.on
                c := f_detect(e, 3, 2)
            if not c.on
                c := f_detect(e, 2, 3)
            if c.on
                e.act := c
                newK := c.kind
                f_draw(c, bar_index, e)
                // the pattern may already have resolved while its last pivot was confirming
                [d2, bb2] = f_scan(c, c.x1 + 1)
                if d2 != 0
                    f_finish(c, d2, bb2)
                    if d2 != 2
                        boD := d2
                    e.lock := bb2
                    e.act := Pat.new()
    [newK, boD]

// ─────────────────────────────── ENGINES ────────────────────────────────────
var Eng eMin = Eng.new(p=pvMinor, hiBar=array.new<int>(), hiPx=array.new<float>(), loBar=array.new<int>(), loPx=array.new<float>(), lock=-1, act=Pat.new(), w=wMinor, major=false)
var Eng eMaj = Eng.new(p=pvMajor, hiBar=array.new<int>(), hiPx=array.new<float>(), loBar=array.new<int>(), loPx=array.new<float>(), lock=-1, act=Pat.new(), w=wMajor, major=true)

float phMin = ta.pivothigh(high, pvMinor, pvMinor)
float plMin = ta.pivotlow(low, pvMinor, pvMinor)
float phMaj = ta.pivothigh(high, pvMajor, pvMajor)
float plMaj = ta.pivotlow(low, pvMajor, pvMajor)

[nkMin, bdMin] = f_step(eMin, phMin, plMin, useMinor and barstate.isconfirmed)
[nkMaj, bdMaj] = f_step(eMaj, phMaj, plMaj, useMajor and barstate.isconfirmed)

// ─────────────────────────────── ALERTS ─────────────────────────────────────
alertcondition(nkMin > 0 or nkMaj > 0, "Pattern developing", "Pattern Radar: a new broadening / wedge pattern started developing.")
alertcondition(bdMin == 1 or bdMaj == 1, "Breakout up", "Pattern Radar: pattern broke out to the upside.")
alertcondition(bdMin == -1 or bdMaj == -1, "Breakout down", "Pattern Radar: pattern broke out to the downside.")

// ───────────────────────────── DASHBOARD ────────────────────────────────────
// Layout (11 columns, horizontal):
//   row 0  labels      RADAR | FOCUS | MINOR | MAJOR | STATUS | TOUCHES | UPPER | LOWER | GAP | ▲ ABOVE | ▼ BELOW
//   row 1  values
//   row 2  history codes   (optional)
//   row 3  history counts  (optional)
//   last   disclaimer (merged across the full width)
f_code(Eng e, bool use) =>
    string s = "off"
    if use
        s := "—"
        if e.act.on
            s := array.get(kindShort, e.act.kind - 1)
    s

f_c(table t, int c, int r, string txt, color tc, color bg, string tip) =>
    table.cell(t, c, r, txt, text_color=tc, text_halign=text.align_center, text_size=dashSz, bgcolor=bg, tooltip=tip)

f_dash(table t, Eng a, Eng b) =>
    Pat p = Pat.new()
    string scale = ""
    if b.act.on
        p := b.act
        scale := "Major"
    else if a.act.on
        p := a.act
        scale := "Minor"
    // row 0 — labels
    f_c(t, 0, 0, "PATTERN RADAR", cGold, cHdr, "For study and knowledge only. Use your own entry and exit rules.")
    f_c(t, 1, 0, "FOCUS", cMute, cHdr, "")
    f_c(t, 2, 0, "MINOR", cMute, cHdr, "")
    f_c(t, 3, 0, "MAJOR", cMute, cHdr, "")
    f_c(t, 4, 0, "STATUS", cMute, cHdr, "")
    f_c(t, 5, 0, "TOUCHES", cMute, cHdr, "")
    f_c(t, 6, 0, "UPPER", cMute, cHdr, "")
    f_c(t, 7, 0, "LOWER", cMute, cHdr, "")
    f_c(t, 8, 0, "GAP", cMute, cHdr, "")
    f_c(t, 9, 0, "▲ ABOVE → TARGET", cGreen, cHdr, "")
    f_c(t, 10, 0, "▼ BELOW → TARGET", cVerm, cHdr, "")
    // row 1 — values
    f_c(t, 0, 1, syminfo.ticker + " · " + timeframe.period, cText, cBg, "")
    f_c(t, 2, 1, f_code(a, useMinor), a.act.on ? cGold : cMute, cBg, "")
    f_c(t, 3, 1, f_code(b, useMajor), b.act.on ? cGold : cMute, cBg, "")
    if p.on
        float uNow = p.icU + p.slU * (bar_index - p.x0)
        float lNow = p.icL + p.slL * (bar_index - p.x0)
        int span = p.x1 - p.x0
        float avgPx = (p.icU + p.icL) / 2.0
        float pU = p.slU * span / avgPx * 100.0
        float pL = p.slL * span / avgPx * 100.0
        float gS = p.icU - p.icL
        float gChg = ((uNow - lNow) / gS - 1.0) * 100.0
        int barsLeft = math.round(expMult * span - (bar_index - p.x1))
        string nm = array.get(kindName, p.kind - 1)
        f_c(t, 1, 1, nm + " · " + scale, array.get(kindCol, p.kind - 1), cBg, array.get(kindBias, p.kind - 1))
        f_c(t, 4, 1, "Developing · " + str.tostring(math.max(barsLeft, 0)) + " bars left", cGold, cBg, "")
        f_c(t, 5, 1, str.tostring(p.nH) + "H · " + str.tostring(p.nL) + "L", cText, cBg, "")
        f_c(t, 6, 1, (pU >= 0 ? "+" : "") + str.tostring(pU, "#.#") + "% / " + str.tostring(span) + " bars", pU >= 0 ? cGreen : cVerm, cBg, "")
        f_c(t, 7, 1, (pL >= 0 ? "+" : "") + str.tostring(pL, "#.#") + "% / " + str.tostring(span) + " bars", pL >= 0 ? cGreen : cVerm, cBg, "")
        f_c(t, 8, 1, (gChg >= 0 ? "+" : "") + str.tostring(gChg, "#") + "% " + (gChg >= 0 ? "widening" : "narrowing"), cText, cBg, "")
        f_c(t, 9, 1, str.tostring(uNow, format.mintick) + " → " + str.tostring(f_target(p, 1, uNow), format.mintick), cGreen, cBg, "")
        f_c(t, 10, 1, str.tostring(lNow, format.mintick) + " → " + str.tostring(f_target(p, -1, lNow), format.mintick), cVerm, cBg, "")
    else
        f_c(t, 1, 1, "No pattern developing", cMute, cBg, "")
        for c = 4 to 10
            f_c(t, c, 1, "—", cMute, cBg, "")
    int dr = 2
    if showHist
        dr := 4
        f_c(t, 0, 2, "HISTORY", cGold, cHdr, "Completed patterns on this chart: total ▲ up ▼ down")
        f_c(t, 0, 3, "done ▲ ▼", cMute, cBg, "")
        for i = 0 to 7
            f_c(t, i + 1, 2, array.get(kindShort, i), array.get(kindCol, i), cHdr, array.get(kindName, i))
            f_c(t, i + 1, 3, str.tostring(array.get(sCnt, i)) + "  ▲" + str.tostring(array.get(sUp, i)) + " ▼" + str.tostring(array.get(sDn, i)), cText, cBg, "")
        f_c(t, 9, 2, "TOTAL", cMute, cHdr, "")
        f_c(t, 9, 3, str.tostring(array.sum(sCnt)) + "  ▲" + str.tostring(array.sum(sUp)) + " ▼" + str.tostring(array.sum(sDn)), cText, cBg, "")
        f_c(t, 10, 2, "NO BREAKOUT", cMute, cHdr, "")
        f_c(t, 10, 3, str.tostring(array.sum(sNb)), cMute, cBg, "")
    // last row — disclaimer
    table.cell(t, 0, dr, "For study and knowledge only, not trading advice. Use your own entry and exit rules.", text_color=cMute, text_halign=text.align_center, text_size=size.tiny, bgcolor=cHdr)
    table.merge_cells(t, 0, dr, 10, dr)

var table tDash = na
if barstate.isfirst and showPanel
    tDash := table.new(dashPos, 11, showHist ? 5 : 3, bgcolor=cBg, frame_color=cGold, frame_width=1, border_color=cHdr, border_width=1)

if barstate.islast and showPanel
    f_dash(tDash, eMin, eMaj)
````
