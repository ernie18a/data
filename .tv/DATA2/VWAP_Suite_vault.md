<!-- tradingview-pine-id: PUB;1611349e89d542ebbd28c841c991ab88 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP Suite [vault]

Source: https://www.tradingview.com/script/lGKd6yDO-VWAP-Suite-vault/

## Description

VWAP Suite [vault]

Most traders treat VWAP like a single line. This tool treats it the way Auction Market Theory treats it: as a developing value area with a center, an upper edge and a lower edge, tracked across every timeframe that matters, with the previous period frozen next to the current one so you always know where price sits relative to value.

Everything is inside one indicator. Session VWAPs from daily to yearly, standard deviation bands that form the value area, previous period levels, right side labels for every higher timeframe level, and rolling VWAPs over 7, 30, 90 and 365 days.

WHAT IT PLOTS

1. Session VWAPs (Daily, Weekly, Monthly, Quarterly, Yearly)

Each period has its own anchored VWAP that resets at the start of the period. The reset follows the exchange session of the symbol, not midnight UTC, so on CME futures a new daily VWAP starts at 18:00 New York, on OANDA gold at 17:00 New York, and so on. Weekly, monthly, quarterly and yearly resets follow the same logic.

You can enable any combination of these, each with its own color. By default the VWAP lines are drawn dotted so they do not compete visually with the bands and rolling lines. A "Dotted VWAP Lines" toggle switches them back to solid.

The lines break at the period change instead of drawing a vertical jump to the new starting level, so every session or week or month shows as its own clean block.

2. Standard Deviation Bands (Value Area)

Pick one period under "Anchored to Period" and the indicator draws its standard deviation bands around that VWAP:

- VWAP plus 1 SD = VAH (value area high)
- VWAP minus 1 SD = VAL (value area low)
- optional plus and minus 2 SD outer bands

The area between VAH and VAL is filled. Fill transparency is adjustable and defaults to a very subtle 95 so the band reads as a shadow behind price rather than a colored block.

The deviation is calculated with volume weighting from the same cumulative data as the VWAP itself, so VAH and VAL are the true volume weighted 1 SD edges of the developing value area. Bands also break at the period change.

3. Previous Period Levels

At the start of every new period the indicator freezes the VWAP and standard deviation of the period that just closed. Those frozen values are carried forward as flat lines through the current period:

- previous VWAP
- previous VAH and VAL (plus and minus 1 SD)
- optional previous plus and minus 2 SD

These are the levels that matter most from an Auction Market Theory point of view. Price opening inside the previous value area, above it, or below it tells you what kind of day or week you are likely dealing with. The previous value area can be filled as well, with a separate "Fill Prev Bands" toggle.

Each of the five periods keeps its own frozen values, so the previous weekly VAH is genuinely the VAH of last week, not of the last day.

4. HTF Labels (Weekly, Monthly, Quarterly, Yearly)

This is the part that keeps the chart clean. Instead of plotting eight or ten extra lines you get labels on the right side of the chart for the higher timeframe levels:

- current VWAP, VAH, VAL for each of W, M, Q, Y
- previous VWAP, VAH, VAL for each of W, M, Q, Y

Every single label has its own checkbox, so you can show exactly the ones you use and nothing else. Each period has its own color, and previous period labels are automatically dimmed so you can tell them apart at a glance. Two group switches, "Show Current Labels" and "Show Previous Labels", turn whole sets on and off.

Each label comes with a short horizontal tick line drawn at the price level, so you can see where the level sits even when the line itself is not plotted.

5. Rolling VWAPs (7, 30, 90, 365 day)

Rolling VWAPs do not reset. They always look back a fixed number of days and give you the volume weighted average of that whole window. They are calculated by time, not by bar count, so a 30 day rolling VWAP is the same 30 days whether you are on a 5 minute chart or a 4 hour chart. Each one has its own toggle, color and label.

Note on history: the 365 day line needs roughly a year of bars on your chart. On low timeframes with limited history it will be calculated from the first available bar. It is off by default for that reason.

LABEL CONTROLS

- Label Offset: how many bars to the right of the current bar the labels sit
- Label Size: tiny, small, normal or large
- Label Tick Length: length of the short line drawn in front of each label
- Show Right-Side Labels: one master switch that hides every label on the right in one click. Lines and fills stay. Useful when you want to screenshot a clean chart or when the labels start stacking up during a tight range.

HOW WE USE IT

The core idea is that VWAP is fair value for the period and the 1 SD bands are the edges of value. Price accepted inside the bands is balance. Price outside the bands is either an imbalance that will be faded back to value or the start of a trend that leaves the old value area behind.

A few things to watch for:

- Price opening the day or week outside the previous value area and holding there. That is acceptance away from old value and usually the start of a directional move.
- Price opening outside the previous value area and coming straight back inside. Failed breakout, look for a rotation to the other side of the value area.
- Daily VAH or VAL lining up with a weekly or monthly VWAP or value area edge. Stacked value edges from multiple timeframes are where the strongest reactions happen.
- Rolling 7D and 30D crossing or converging. That is medium term value shifting and it often precedes a larger move on the session timeframes.

The labels on the right are there so you never have to guess which level a line represents or scroll around to find the monthly VWAP.

CALCULATION NOTES

- Source is hlc3 by default and can be changed.
- VWAP is the volume weighted average of the source since the period start. Standard deviation is the volume weighted deviation of the source around that VWAP.
- Session boundaries come from the symbol's own exchange calendar.
- On symbols without volume (some CFDs and spot pairs), the indicator falls back to equal weighting so it still plots a time weighted average and bands rather than nothing.
- No repainting. Every value is computed from closed data and a period's frozen levels never change once the period has ended.
- Written in Pine Script v6.

INPUTS OVERVIEW

General: source, label offset, label size, label tick length, right side labels master switch
Session VWAPs: Daily / Weekly / Monthly / Quarterly / Yearly with colors, line width, dotted or solid
Standard Deviation Bands: on/off, anchored period, fill on/off, 2 SD bands on/off, colors, fill transparency
Previous Period Levels: prev 1 SD levels, prev 2 SD levels, prev labels, fill prev bands, color
HTF Labels: current / previous group switches, then per period color and six individual checkboxes (VWAP, VAH, VAL, pVWAP, pVAH, pVAL)
Rolling VWAPs: 7 / 30 / 90 / 365 day with colors

Works on any market and any timeframe. Built for futures and gold on intraday charts but the logic is the same on crypto, forex and stocks.

---

## Source Code

````pine
//@version=6
// VWAP Suite [vault]
// Auction Market Theory VWAP toolkit: session VWAPs (D/W/M/Q/Y), SD value area bands,
// previous period levels, HTF level labels (VWAP / VAH / VAL) and rolling VWAPs (7/30/90/365 day).
indicator("VWAP Suite [vault]", "VWAP Suite [vault]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ───────────────────────────── GENERAL ─────────────────────────────
gG        = "General"
src       = input.source(hlc3, "Source", group = gG)
lblOff    = input.int(45, "Label Offset", minval = 5, maxval = 490, group = gG)
lblSizeS  = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gG)
lblSize   = lblSizeS == "Tiny" ? size.tiny : lblSizeS == "Small" ? size.small : lblSizeS == "Large" ? size.large : size.normal
tickLen   = input.int(25, "Label Tick Length (bars)", minval = 0, maxval = 200, group = gG)
showLbls  = input.bool(true, "Show Right-Side Labels (master switch)", group = gG)

// ─────────────────────── SESSION VWAPS (D/W/M/Q/Y) ─────────────────
gS    = "Session VWAPs (D/W/M/Q/Y)"
showD = input.bool(true,  "Daily",     inline = "d", group = gS)
colD  = input.color(#e6e9ee, "",       inline = "d", group = gS)
showW = input.bool(false, "Weekly",    inline = "w", group = gS)
colW  = input.color(#a3adba, "",       inline = "w", group = gS)
showM = input.bool(false, "Monthly",   inline = "m", group = gS)
colM  = input.color(#b8c0cc, "",       inline = "m", group = gS)
showQ = input.bool(false, "Quarterly", inline = "q", group = gS)
colQ  = input.color(#8f99a8, "",       inline = "q", group = gS)
showY = input.bool(false, "Yearly",    inline = "y", group = gS)
colY  = input.color(#7a8494, "",       inline = "y", group = gS)
lineW  = input.int(1, "Line Width", minval = 1, maxval = 4, group = gS)
dotted = input.bool(true, "Dotted VWAP Lines", group = gS)

// ─────────────────────── STANDARD DEVIATION BANDS ──────────────────
gB     = "Standard Deviation Bands"
showSD = input.bool(true, "Show SD Bands", group = gB)
anchor = input.string("Daily", "Anchored to Period", options = ["Daily", "Weekly", "Monthly", "Quarterly", "Yearly"], group = gB)
fillB  = input.bool(true, "Fill Bands", group = gB)
show2  = input.bool(false, "Show ±2σ Bands", group = gB)
colB1  = input.color(#c9d1dc, "±1σ (VAH / VAL)", group = gB)
colB2  = input.color(#6f7a8a, "±2σ", group = gB)
fillT  = input.int(95, "Fill Transparency", minval = 0, maxval = 100, group = gB)

// ─────────────────────── PREVIOUS PERIOD LEVELS ────────────────────
gP     = "Previous Period Levels"
showP1 = input.bool(false, "Show Prev ±1 Levels", group = gP)
showP2 = input.bool(false, "Show Prev ±2 Levels", group = gP)
showPL = input.bool(true,  "Show Prev Labels", group = gP)
fillP  = input.bool(true,  "Fill Prev Bands", group = gP)
colP   = input.color(#8a94a3, "Prev Levels Color", group = gP)

// ─────────────────────── HTF LABELS (W/M/Q/Y) ──────────────────────
// labels only (no lines): VWAP / VAH / VAL of each HTF period, current and previous
gH       = "HTF Labels (W/M/Q/Y)"
showCur  = input.bool(true, "Show Current Labels", group = gH)
showPrev = input.bool(true, "Show Previous Labels", group = gH)
// weekly
hcW   = input.color(#aab3c0, "Weekly", inline = "hw", group = gH)
wLv   = input.bool(true,  "VWAP",  inline = "hw",  group = gH)
wLa   = input.bool(false, "VAH",   inline = "hw",  group = gH)
wLl   = input.bool(true,  "VAL",   inline = "hw",  group = gH)
pwLv  = input.bool(true,  "pVWAP", inline = "hw2", group = gH)
pwLa  = input.bool(true,  "pVAH",  inline = "hw2", group = gH)
pwLl  = input.bool(true,  "pVAL",  inline = "hw2", group = gH)
// monthly
hcM   = input.color(#9aa4b2, "Monthly", inline = "hm", group = gH)
mLv   = input.bool(true,  "VWAP",  inline = "hm",  group = gH)
mLa   = input.bool(false, "VAH",   inline = "hm",  group = gH)
mLl   = input.bool(false, "VAL",   inline = "hm",  group = gH)
pmLv  = input.bool(true,  "pVWAP", inline = "hm2", group = gH)
pmLa  = input.bool(false, "pVAH",  inline = "hm2", group = gH)
pmLl  = input.bool(false, "pVAL",  inline = "hm2", group = gH)
// quarterly
hcQ   = input.color(#8791a0, "Quarterly", inline = "hq", group = gH)
qLv   = input.bool(true,  "VWAP",  inline = "hq",  group = gH)
qLa   = input.bool(false, "VAH",   inline = "hq",  group = gH)
qLl   = input.bool(true,  "VAL",   inline = "hq",  group = gH)
pqLv  = input.bool(true,  "pVWAP", inline = "hq2", group = gH)
pqLa  = input.bool(false, "pVAH",  inline = "hq2", group = gH)
pqLl  = input.bool(false, "pVAL",  inline = "hq2", group = gH)
// yearly
hcY   = input.color(#75808f, "Yearly", inline = "hy", group = gH)
yLv   = input.bool(true,  "VWAP",  inline = "hy",  group = gH)
yLa   = input.bool(false, "VAH",   inline = "hy",  group = gH)
yLl   = input.bool(false, "VAL",   inline = "hy",  group = gH)
pyLv  = input.bool(false, "pVWAP", inline = "hy2", group = gH)
pyLa  = input.bool(false, "pVAH",  inline = "hy2", group = gH)
pyLl  = input.bool(false, "pVAL",  inline = "hy2", group = gH)

// ─────────────────────── ROLLING VWAPS (7/30/90/365) ───────────────
gR       = "Rolling VWAPs (7/30/90/365 Day)"
showR7   = input.bool(true,  "7 Day",   inline = "r7",   group = gR)
colR7    = input.color(#d0d6df, "",     inline = "r7",   group = gR)
showR30  = input.bool(true,  "30 Day",  inline = "r30",  group = gR)
colR30   = input.color(#aab3c0, "",     inline = "r30",  group = gR)
showR90  = input.bool(true,  "90 Day",  inline = "r90",  group = gR)
colR90   = input.color(#8791a0, "",     inline = "r90",  group = gR)
showR365 = input.bool(false, "365 Day", inline = "r365", group = gR)
colR365  = input.color(#65707f, "",     inline = "r365", group = gR)

// ───────────────────────────── HELPERS ─────────────────────────────
vol = nz(volume, 0) > 0 ? volume : 1.0   // fallback for symbols without volume

// anchored vwap + standard deviation, resets when isNew is true
f_anchored(float s, bool isNew) =>
    var float pv  = 0.0
    var float vv  = 0.0
    var float pv2 = 0.0
    if isNew
        pv  := 0.0
        vv  := 0.0
        pv2 := 0.0
    pv  += s * vol
    vv  += vol
    pv2 += s * s * vol
    v   = pv / vv
    varr = pv2 / vv - v * v
    sd  = math.sqrt(math.max(varr, 0.0))
    [v, sd]

// vwap + sd frozen at the close of the previous period
f_prev(float v, float sd, bool isNew) =>
    var float p  = na
    var float ps = na
    if isNew and bar_index > 0
        p  := v[1]
        ps := sd[1]
    [p, ps]

// time based rolling vwap over N days (running sums)
f_rolling(float s, int days) =>
    var pvA = array.new_float()
    var vA  = array.new_float()
    var tA  = array.new_int()
    var float sPV = 0.0
    var float sV  = 0.0
    pvNow = s * vol
    array.push(pvA, pvNow)
    array.push(vA, vol)
    array.push(tA, time)
    sPV += pvNow
    sV  += vol
    cutoff = time - days * 86400000
    while array.size(tA) > 0 and array.get(tA, 0) < cutoff
        sPV -= array.shift(pvA)
        sV  -= array.shift(vA)
        array.shift(tA)
    sV > 0 ? sPV / sV : na

// persistent label + short horizontal tick line at the right side of the chart
f_label(bool show, float y, string txt, color c) =>
    var label lb = na
    var line  ln = na
    if show and barstate.islast and not na(y)
        x2 = bar_index + lblOff
        x1 = x2 - tickLen
        if na(lb)
            lb := label.new(x2, y, txt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = c, size = lblSize)
            ln := line.new(x1, y, x2, y, xloc = xloc.bar_index, color = color.new(c, 40), width = 1)
        else
            label.set_xy(lb, x2, y)
            label.set_text(lb, txt)
            label.set_textcolor(lb, c)
            label.set_size(lb, lblSize)
            line.set_xy1(ln, x1, y)
            line.set_xy2(ln, x2, y)
            line.set_color(ln, color.new(c, 40))
    if (not show or na(y)) and not na(lb)
        label.delete(lb)
        line.delete(ln)
        lb := na
        ln := na

// ───────────────────────────── PERIODS ─────────────────────────────
newD = timeframe.change("D")
newW = timeframe.change("W")
newM = timeframe.change("M")
newQ = timeframe.change("3M")
newY = timeframe.change("12M")

[dV, dS] = f_anchored(src, newD)
[wV, wS] = f_anchored(src, newW)
[mV, mS] = f_anchored(src, newM)
[qV, qS] = f_anchored(src, newQ)
[yV, yS] = f_anchored(src, newY)

[pdV, pdS] = f_prev(dV, dS, newD)
[pwV, pwS] = f_prev(wV, wS, newW)
[pmV, pmS] = f_prev(mV, mS, newM)
[pqV, pqS] = f_prev(qV, qS, newQ)
[pyV, pyS] = f_prev(yV, yS, newY)

// anchored period for bands / prev levels
aV   = anchor == "Daily" ? dV   : anchor == "Weekly" ? wV   : anchor == "Monthly" ? mV   : anchor == "Quarterly" ? qV   : yV
aS   = anchor == "Daily" ? dS   : anchor == "Weekly" ? wS   : anchor == "Monthly" ? mS   : anchor == "Quarterly" ? qS   : yS
pV   = anchor == "Daily" ? pdV  : anchor == "Weekly" ? pwV  : anchor == "Monthly" ? pmV  : anchor == "Quarterly" ? pqV  : pyV
pS   = anchor == "Daily" ? pdS  : anchor == "Weekly" ? pwS  : anchor == "Monthly" ? pmS  : anchor == "Quarterly" ? pqS  : pyS
aNew = anchor == "Daily" ? newD : anchor == "Weekly" ? newW : anchor == "Monthly" ? newM : anchor == "Quarterly" ? newQ : newY
aPre = anchor == "Daily" ? "d"  : anchor == "Weekly" ? "w"  : anchor == "Monthly" ? "m"  : anchor == "Quarterly" ? "q"  : "y"

brk = aNew ? na : 1.0

// current bands
aU1 = aV + aS
aL1 = aV - aS
aU2 = aV + 2 * aS
aL2 = aV - 2 * aS

// previous period bands
pU1 = (pV + pS) * brk
pL1 = (pV - pS) * brk
pU2 = (pV + 2 * pS) * brk
pL2 = (pV - 2 * pS) * brk

// rolling
r7   = f_rolling(src, 7)
r30  = f_rolling(src, 30)
r90  = f_rolling(src, 90)
r365 = f_rolling(src, 365)

// ───────────────────────────── PLOTS ───────────────────────────────
vStyle = dotted ? plot.style_circles : plot.style_linebr
plot(showD ? dV * (newD ? na : 1.0) : na, "Daily VWAP",     colD, lineW, vStyle)
plot(showW ? wV * (newW ? na : 1.0) : na, "Weekly VWAP",    colW, lineW, vStyle)
plot(showM ? mV * (newM ? na : 1.0) : na, "Monthly VWAP",   colM, lineW, vStyle)
plot(showQ ? qV * (newQ ? na : 1.0) : na, "Quarterly VWAP", colQ, lineW, vStyle)
plot(showY ? yV * (newY ? na : 1.0) : na, "Yearly VWAP",    colY, lineW, vStyle)

// current sd bands (anchored period)
u1 = plot(showSD ? aU1 * brk : na, "VAH (+1σ)", colB1, 1, plot.style_linebr)
l1 = plot(showSD ? aL1 * brk : na, "VAL (-1σ)", colB1, 1, plot.style_linebr)
u2 = plot(showSD and show2 ? aU2 * brk : na, "+2σ", colB2, 1, plot.style_linebr)
l2 = plot(showSD and show2 ? aL2 * brk : na, "-2σ", colB2, 1, plot.style_linebr)
fill(u1, l1, showSD and fillB ? color.new(colB1, fillT) : na, "Value Area Fill")
fill(u2, u1, showSD and show2 and fillB ? color.new(colB2, fillT + 4) : na, "+2σ Fill")
fill(l1, l2, showSD and show2 and fillB ? color.new(colB2, fillT + 4) : na, "-2σ Fill")

// previous period sd bands (anchored period)
pu1 = plot(showP1 ? pU1 : na, "Prev VAH (+1σ)", colP, 1, plot.style_linebr)
pl1 = plot(showP1 ? pL1 : na, "Prev VAL (-1σ)", colP, 1, plot.style_linebr)
pu2 = plot(showP2 ? pU2 : na, "Prev +2σ", color.new(colP, 40), 1, plot.style_linebr)
pl2 = plot(showP2 ? pL2 : na, "Prev -2σ", color.new(colP, 40), 1, plot.style_linebr)
fill(pu1, pl1, showP1 and fillP ? color.new(colP, fillT) : na, "Prev Value Area Fill")
fill(pu2, pu1, showP2 and fillP ? color.new(colP, fillT + 4) : na, "Prev +2σ Fill")
fill(pl1, pl2, showP2 and fillP ? color.new(colP, fillT + 4) : na, "Prev -2σ Fill")

// rolling vwaps
plot(showR7   ? r7   : na, "7D Rolling VWAP",   colR7,   1)
plot(showR30  ? r30  : na, "30D Rolling VWAP",  colR30,  1)
plot(showR90  ? r90  : na, "90D Rolling VWAP",  colR90,  1)
plot(showR365 ? r365 : na, "365D Rolling VWAP", colR365, 1)

// ───────────────────────────── LABELS ──────────────────────────────
L  = showLbls
C  = L and showCur
P  = L and showPrev

// anchored period: current value area
f_label(C and showD, dV, "dVWAP", colD)
f_label(C and showSD, aU1, aPre + "VAH", colB1)
f_label(C and showSD, aL1, aPre + "VAL", colB1)
f_label(C and showSD and show2, aU2, aPre + "+2σ", colB2)
f_label(C and showSD and show2, aL2, aPre + "-2σ", colB2)

// anchored period: previous value area
f_label(L and showPL and showD, pdV, "pdVWAP", color.new(colD, 30))
f_label(L and showPL and showP1, pV + pS,     "p" + aPre + "VAH", colP)
f_label(L and showPL and showP1, pV - pS,     "p" + aPre + "VAL", colP)
f_label(L and showPL and showP2, pV + 2 * pS, "p" + aPre + "+2σ", color.new(colP, 40))
f_label(L and showPL and showP2, pV - 2 * pS, "p" + aPre + "-2σ", color.new(colP, 40))

// HTF labels (labels only, no lines) - each one toggled individually
cW = hcW
dW = color.new(hcW, 30)
f_label(C and wLv,  wV,        "wVWAP",  cW)
f_label(C and wLa,  wV + wS,   "wVAH",   cW)
f_label(C and wLl,  wV - wS,   "wVAL",   cW)
f_label(P and pwLv, pwV,       "pwVWAP", dW)
f_label(P and pwLa, pwV + pwS, "pwVAH",  dW)
f_label(P and pwLl, pwV - pwS, "pwVAL",  dW)

cM = hcM
dM = color.new(hcM, 30)
f_label(C and mLv,  mV,        "mVWAP",  cM)
f_label(C and mLa,  mV + mS,   "mVAH",   cM)
f_label(C and mLl,  mV - mS,   "mVAL",   cM)
f_label(P and pmLv, pmV,       "pmVWAP", dM)
f_label(P and pmLa, pmV + pmS, "pmVAH",  dM)
f_label(P and pmLl, pmV - pmS, "pmVAL",  dM)

cQ = hcQ
dQ = color.new(hcQ, 30)
f_label(C and qLv,  qV,        "qVWAP",  cQ)
f_label(C and qLa,  qV + qS,   "qVAH",   cQ)
f_label(C and qLl,  qV - qS,   "qVAL",   cQ)
f_label(P and pqLv, pqV,       "pqVWAP", dQ)
f_label(P and pqLa, pqV + pqS, "pqVAH",  dQ)
f_label(P and pqLl, pqV - pqS, "pqVAL",  dQ)

cY = hcY
dY = color.new(hcY, 30)
f_label(C and yLv,  yV,        "yVWAP",  cY)
f_label(C and yLa,  yV + yS,   "yVAH",   cY)
f_label(C and yLl,  yV - yS,   "yVAL",   cY)
f_label(P and pyLv, pyV,       "pyVWAP", dY)
f_label(P and pyLa, pyV + pyS, "pyVAH",  dY)
f_label(P and pyLl, pyV - pyS, "pyVAL",  dY)

// rolling
f_label(L and showR7,   r7,   "7D",   colR7)
f_label(L and showR30,  r30,  "30D",  colR30)
f_label(L and showR90,  r90,  "90D",  colR90)
f_label(L and showR365, r365, "365D", colR365)
````
