<!-- tradingview-pine-id: PUB;b22407089d774df4a5df4ce877819557 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Camarilla S6-R6 + Day Type

Source: https://www.tradingview.com/script/9mKuYxdE-Camarilla-S6-R6-Day/

## Description

# Camarilla S6–R6 + Day Type

## Short title
Camarilla S6-R6 + Day Type

---

## Description

Camarilla pivots plotted with the full six-level set (S6 through R6 plus the central pivot), using the level naming most execution platforms display, with a session-locked calculation and a dashboard that classifies the developing period as a rotation day or a breakout day.

**Levels**

All levels derive from the previous completed period's high, low and close:

Range = prior High − prior Low
PP = (H + L + C) / 3
R1 = C + Range × 1.1/12    S1 = C − Range × 1.1/12
R2 = C + Range × 1.1/6     S2 = C − Range × 1.1/6
R3 = C + Range × 1.1/4     S3 = C − Range × 1.1/4
R4 = C + Range × 1.1/2     S4 = C − Range × 1.1/2
R5 = R4 + 1.168 × (R4 − R3)    S5 = S4 − 1.168 × (S3 − S4)
R6 = (High / Low) × C          S6 = C − (R6 − C)

Note for anyone comparing against other Camarilla scripts: in the five-level version, the (H/L) × C calculation is labelled H5. In the six-level set used here it is R6, and R5 is the separate 1.168 extension of the R3–R4 leg. If the outer line looks misnamed against another indicator, this is why.

**Session basis — the part that usually causes mismatched levels**

Camarilla levels are only as good as the prior high, low and close feeding them, and on an intraday chart with extended hours enabled it is easy to end up mixing sessions without noticing. This script pins the calculation explicitly. The Session basis input rebuilds the data request on regular-hours data (the default, matching most execution platforms), extended-hours data, or whatever your chart is currently set to. The levels stay on that basis regardless of your chart's extended-hours toggle.

The developing period's open, high and low are requested from that same source, so both sides of every inside/outside comparison are measured on one session. The period boundary is taken from the higher-timeframe bar's own timestamp rather than the chart's calendar-day roll, which matters on extended-hours charts where the chart day rolls before the daily bar has advanced.

A Prior H/L/C row in the dashboard shows the three numbers actually being used. Check those against your broker or platform for the same date — if they match, every level below them matches by construction.

**Timeframe handling**

Auto resolves to daily levels on every intraday chart and on the daily chart itself, weekly on a weekly chart, yearly on monthly. Keeping daily pivots on the daily chart is deliberate: each daily candle is then drawn against the prior day's level set, so a run of inside and outside days reads directly off the staircase. Raise "Periods shown" to 10–20 for that view and leave it at 1–2 intraday. Daily, weekly, monthly and a free custom timeframe can also be selected manually.

**Opacity gradient**

Transparency steps down as levels move away from the pivot. The inner S3–R3 band is the most transparent so price action stays readable through it, R4/S4 and R5/S5 grow progressively more solid, and R6/S6 are the darkest and heaviest lines on the chart. Starting transparency and the per-band step are both inputs, so the gradient can be flattened or exaggerated. R and S levels have separate colour inputs.

**Day type dashboard**

Open type — where the period opened relative to the prior band. Inside S3–R3 suggests rotation and levels worth fading; between R3 and R4 (or S3 and S4) marks a gap that often reverts to the band; beyond R4/S4 flags a breakout open that should not be faded.

Range — the containment read. INSIDE when the developing high and low sit within the prior range, OUTSIDE when they engulf it, otherwise a one-sided extension.

Range vs prior — developing range as a percentage of the previous one. A contraction and expansion gauge: a low reading through the middle of the session supports mean reversion at the bands, above 100% says the session is in expansion.

Price in — which band price currently occupies, from above R6 down to below S6.

An optional background tint marks inside and outside periods on the chart itself.

**Alerts**

Crossings of R3/S3 and R4/S4 in both directions, rejection back inside the R3/S3 band, and tags of R6/S6.

**Notes on repainting**

Prior-period values use a bar offset so the levels lock in when the period closes and do not repaint. The developing period is requested without lookahead, so it updates bar by bar without using future data. That does mean the Range and Range-vs-prior rows are live reads that can change until the period closes — a day showing INSIDE at midday can finish as an outside day. When regular-hours levels are selected and the session has not opened yet, the dashboard reports that state rather than computing a range against the prior day's own numbers.

Works on any symbol and any chart timeframe at or below the pivot timeframe; a warning label appears if the chart timeframe is higher than the selected pivot timeframe.

Open source. The level maths is the standard published Camarilla set; the code is commented throughout for anyone who wants to adapt it.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  Camarilla Pivots S6–R6 + Day Type   (DAS Trader level convention)
//  R6 = (H/L) x C          S6 = C - (R6 - C)
//  R5 = R4 + 1.168(R4-R3)  S5 = S4 - 1.168(S3-S4)
//  R4 = C + R x 1.1/2      S4 = C - R x 1.1/2
//  R3 = C + R x 1.1/4      S3 = C - R x 1.1/4
//  R2 = C + R x 1.1/6      S2 = C - R x 1.1/6
//  R1 = C + R x 1.1/12     S1 = C - R x 1.1/12
// ═══════════════════════════════════════════════════════════════════════════
indicator("Camarilla S6-R6 + Day Type", "Camarilla", overlay = true, max_lines_count = 500, max_labels_count = 100)

// ────────────────────────────── Inputs ──────────────────────────────
gT = "Pivot timeframe & session"
tfMode = input.string("Auto", "Mode", options = ["Auto", "Daily", "Weekly", "Monthly", "Custom"], group = gT,
     tooltip = "Auto = Daily pivots on intraday AND daily charts, Weekly on weekly, Yearly on monthly.")
tfCust = input.timeframe("D", "Custom timeframe", group = gT)
sessMode = input.string("Regular hours", "Session basis", options = ["Regular hours", "Extended hours", "Chart setting"], group = gT,
     tooltip = "Which session builds the prior H/L/C. 'Regular hours' matches most execution platforms and stays correct even with extended hours showing on your chart. Use 'Chart setting' only if you want levels to follow your ETH toggle.")
nHist  = input.int(2, "Periods shown", minval = 1, maxval = 25, group = gT,
     tooltip = "1 = current period only. On a DAILY chart raise this to 10-20 to see the staircase of prior-day levels.")

gL = "Levels"
show12  = input.bool(false, "R1 / R2 / S1 / S2", group = gL)
show3   = input.bool(true,  "R3 / S3   (reversal band)", group = gL)
show4   = input.bool(true,  "R4 / S4   (breakout band)", group = gL)
show5   = input.bool(true,  "R5 / S5   (extension)", group = gL)
show6   = input.bool(true,  "R6 / S6   (outer extreme)", group = gL)
showPP  = input.bool(true,  "PP   (pivot)", group = gL)
showLbl = input.bool(true,  "Level labels", group = gL)
lblOff  = input.int(4, "Label offset (bars)", minval = 0, maxval = 60, group = gL)

gC = "Colors & opacity"
cR = input.color(#26a69a, "R levels", group = gC)
cS = input.color(#ef5350, "S levels", group = gC)
cP = input.color(#9598a1, "Pivot", group = gC)
tInner = input.int(66, "Inner band transparency (R3/S3)", minval = 0, maxval = 95, group = gC)
tStep  = input.int(22, "Darkening per band outward", minval = 0, maxval = 40, group = gC)
wBase  = input.int(2, "Line width", minval = 1, maxval = 4, group = gC)
wOuter = input.bool(true, "Thicken R6 / S6", group = gC)

gD = "Day type"
showTbl = input.bool(true, "Dashboard", group = gD)
tblPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = gD)
rngSrc  = input.string("Pivot session", "Developing range from", options = ["Pivot session", "Chart bars"], group = gD,
     tooltip = "'Pivot session' measures today's range on the same session that built the levels - apples to apples. 'Chart bars' uses whatever your chart displays, so on an extended-hours chart it includes overnight.")
showAudit = input.bool(true, "Show prior H/L/C used", group = gD,
     tooltip = "Cross-check these three numbers against your execution platform. If they match, every level matches.")
tint    = input.bool(false, "Tint inside / outside periods", group = gD)

t123 = tInner
t4   = math.max(0, tInner - tStep)
t5   = math.max(0, tInner - tStep * 2)
t6   = math.max(0, tInner - tStep * 3)

// ───────────────────────── Timeframe & ticker ─────────────────────────
autoTF = timeframe.isintraday or timeframe.isdaily ? "D" : timeframe.isweekly ? "W" : "12M"
pivotTF = switch tfMode
    "Daily"   => "D"
    "Weekly"  => "W"
    "Monthly" => "M"
    "Custom"  => tfCust
    => autoTF

// Force the level source onto one session so the prior period and the developing
// period can never be measured on different bases.
tkr = sessMode == "Chart setting" ? syminfo.tickerid :
     ticker.new(syminfo.prefix, syminfo.ticker, sessMode == "Regular hours" ? session.regular : session.extended)

tfTooLow = timeframe.in_seconds() > timeframe.in_seconds(pivotTF)

// ───────────────── Prior completed period (lookahead_on + [1] = non-repainting) ─────────────────
[pH, pL, pC] = request.security(tkr, pivotTF, [high[1], low[1], close[1]],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

// ───────────────── Developing period, same source (lookahead_off = no future data) ─────────────────
[dO, dH, dL, dT] = request.security(tkr, pivotTF, [open, high, low, time],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Period boundary comes from the HTF bar itself, NOT the chart's calendar-day roll.
// This is the bug fix: on an extended-hours chart the chart day rolls at 20:00 while
// the daily bar has not advanced yet, which used to draw levels off the wrong day.
newPeriod = not na(dT) and (na(dT[1]) or dT != dT[1])

// Optional: developing range measured from chart bars instead of the pivot session
var float chO = na
var float chH = na
var float chL = na
if newPeriod or na(chH)
    chO := open
    chH := high
    chL := low
else
    chH := math.max(chH, high)
    chL := math.min(chL, low)

curO = rngSrc == "Chart bars" ? chO : dO
curH = rngSrc == "Chart bars" ? chH : dH
curL = rngSrc == "Chart bars" ? chL : dL

// ───────────────────────── Camarilla math ─────────────────────────
rng = pH - pL
pp  = (pH + pL + pC) / 3
r1  = pC + rng * 1.1 / 12
r2  = pC + rng * 1.1 / 6
r3  = pC + rng * 1.1 / 4
r4  = pC + rng * 1.1 / 2
r5  = r4 + 1.168 * (r4 - r3)
r6  = pL > 0 ? (pH / pL) * pC : na
s1  = pC - rng * 1.1 / 12
s2  = pC - rng * 1.1 / 6
s3  = pC - rng * 1.1 / 4
s4  = pC - rng * 1.1 / 2
s5  = s4 - 1.168 * (s3 - s4)
s6  = na(r6) ? na : pC - (r6 - pC)

valid = not na(pH) and not na(pL) and not na(pC) and not tfTooLow

// ───────────────────────── Drawing engine ─────────────────────────
perPeriod = (showPP ? 1 : 0) + (show12 ? 4 : 0) + (show3 ? 2 : 0) + (show4 ? 2 : 0) + (show5 ? 2 : 0) + (show6 ? 2 : 0)

var line[]  lines  = array.new<line>()
var label[] labels = array.new<label>()
var float drawnPC = na

mkLine(float px, color col, int transp, int wid, string sty) =>
    line.new(bar_index, px, bar_index + 1, px, xloc = xloc.bar_index,
       color = color.new(col, transp), width = wid, style = sty)

mkLabel(float px, string txt, color col, int transp) =>
    label.new(bar_index + lblOff, px, txt, xloc = xloc.bar_index, style = label.style_label_left,
       color = color.new(col, 100), textcolor = color.new(col, math.round(transp / 2)), size = size.small)

fmt(string nm, float px) => nm + "  " + str.tostring(px, format.mintick)

// Safety net: if the underlying prior close ever shifts mid-period, tear down the
// stale set and redraw so the lines can never disagree with the dashboard again.
staleLevels = valid and not na(drawnPC) and pC != drawnPC
redraw = valid and perPeriod > 0 and (newPeriod or lines.size() == 0 or staleLevels)

if redraw
    if staleLevels and not newPeriod and lines.size() >= perPeriod
        for i = 1 to perPeriod
            line.delete(lines.pop())
    for lb in labels
        label.delete(lb)
    labels.clear()

    if showPP
        lines.push(mkLine(pp, cP, t123, 1, line.style_dashed))
        if showLbl
            labels.push(mkLabel(pp, fmt("PP", pp), cP, t123))
    if show12
        lines.push(mkLine(r1, cR, t123, 1, line.style_dotted))
        lines.push(mkLine(r2, cR, t123, 1, line.style_dotted))
        lines.push(mkLine(s1, cS, t123, 1, line.style_dotted))
        lines.push(mkLine(s2, cS, t123, 1, line.style_dotted))
        if showLbl
            labels.push(mkLabel(r1, fmt("R1", r1), cR, t123))
            labels.push(mkLabel(r2, fmt("R2", r2), cR, t123))
            labels.push(mkLabel(s1, fmt("S1", s1), cS, t123))
            labels.push(mkLabel(s2, fmt("S2", s2), cS, t123))
    if show3
        lines.push(mkLine(r3, cR, t123, wBase, line.style_solid))
        lines.push(mkLine(s3, cS, t123, wBase, line.style_solid))
        if showLbl
            labels.push(mkLabel(r3, fmt("R3", r3), cR, t123))
            labels.push(mkLabel(s3, fmt("S3", s3), cS, t123))
    if show4
        lines.push(mkLine(r4, cR, t4, wBase, line.style_solid))
        lines.push(mkLine(s4, cS, t4, wBase, line.style_solid))
        if showLbl
            labels.push(mkLabel(r4, fmt("R4", r4), cR, t4))
            labels.push(mkLabel(s4, fmt("S4", s4), cS, t4))
    if show5
        lines.push(mkLine(r5, cR, t5, wBase, line.style_solid))
        lines.push(mkLine(s5, cS, t5, wBase, line.style_solid))
        if showLbl
            labels.push(mkLabel(r5, fmt("R5", r5), cR, t5))
            labels.push(mkLabel(s5, fmt("S5", s5), cS, t5))
    if show6 and not na(r6)
        lines.push(mkLine(r6, cR, t6, wOuter ? wBase + 1 : wBase, line.style_solid))
        lines.push(mkLine(s6, cS, t6, wOuter ? wBase + 1 : wBase, line.style_solid))
        if showLbl
            labels.push(mkLabel(r6, fmt("R6", r6), cR, t6))
            labels.push(mkLabel(s6, fmt("S6", s6), cS, t6))

    drawnPC := pC

    while lines.size() > nHist * perPeriod
        line.delete(lines.shift())

if lines.size() > 0
    int n = lines.size()
    for i = math.max(0, n - perPeriod) to n - 1
        line.set_x2(lines.get(i), bar_index + 1)
    for lb in labels
        label.set_x(lb, bar_index + lblOff)

// ───────────────────────── Day-type analysis ─────────────────────────
// The developing period has not opened yet if its O/H/L still equal the prior bar's.
preSession = valid and not na(curH) and curH == pH and curL == pL

openType = not valid or na(curO) ? "n/a" : preSession ? "session not open yet" :
     curO > r4 or curO < s4 ? "Outside R4/S4  ->  breakout / trend day" :
     curO > r3 or curO < s3 ? "Outside R3/S3  ->  gap, fade back to R3/S3" :
     "Inside S3-R3  ->  rotation / range day"

insideDay  = valid and not preSession and curH <= pH and curL >= pL
outsideDay = valid and not preSession and curH > pH and curL < pL
rangeType = not valid ? "n/a" : preSession ? "session not open yet" :
     insideDay  ? "INSIDE  (contained by prior range)" :
     outsideDay ? "OUTSIDE  (engulfs prior range)" :
     curH > pH  ? "Higher high, higher low" :
     curL < pL  ? "Lower low, lower high" : "n/a"

expPct = rng > 0 and not preSession ? (curH - curL) / rng * 100 : na

zone = not valid ? "n/a" :
     not na(r6) and close > r6 ? "above R6" :
     close > r5 ? "R5 - R6" :
     close > r4 ? "R4 - R5" :
     close > r3 ? "R3 - R4" :
     close > pp ? "PP - R3" :
     close > s3 ? "S3 - PP" :
     close > s4 ? "S4 - S3" :
     close > s5 ? "S5 - S4" :
     na(s6) or close > s6 ? "S6 - S5" : "below S6"

bgcolor(tint and insideDay ? color.new(color.blue, 92) : tint and outsideDay ? color.new(color.orange, 90) : na)

// ───────────────────────── Dashboard ─────────────────────────
tPos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left :
       tblPos == "Bottom right" ? position.bottom_right : position.bottom_left

var table dash = table.new(tPos, 2, 7, border_width = 1, frame_width = 1,
     frame_color = color.new(color.gray, 60), border_color = color.new(color.gray, 70))

if showTbl and barstate.islast
    bg = color.new(color.gray, 90)
    hd = color.new(color.gray, 70)
    dash.cell(0, 0, "Camarilla", bgcolor = hd, text_color = color.gray, text_size = size.small)
    dash.cell(1, 0, pivotTF + " · " + (sessMode == "Regular hours" ? "RTH" : sessMode == "Extended hours" ? "ETH" : "chart"),
         bgcolor = hd, text_color = color.gray, text_size = size.small)

    dash.cell(0, 1, "Open type", bgcolor = bg, text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 1, openType, bgcolor = bg, text_size = size.small, text_halign = text.align_left,
         text_color = str.contains(openType, "Inside") ? cR : str.contains(openType, "R4") ? cS : color.orange)

    dash.cell(0, 2, "Range", bgcolor = bg, text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 2, rangeType, bgcolor = bg, text_size = size.small, text_halign = text.align_left,
         text_color = insideDay ? cR : outsideDay ? cS : color.gray)

    dash.cell(0, 3, "Range vs prior", bgcolor = bg, text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 3, na(expPct) ? "n/a" : str.tostring(expPct, "#") + "%", bgcolor = bg, text_size = size.small,
         text_halign = text.align_left, text_color = expPct > 100 ? color.orange : color.new(color.gray, 0))

    dash.cell(0, 4, "Price in", bgcolor = bg, text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 4, zone, bgcolor = bg, text_size = size.small, text_halign = text.align_left, text_color = color.new(color.gray, 0))

    dash.cell(0, 5, "Prior range", bgcolor = bg, text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 5, valid ? str.tostring(rng, format.mintick) : "n/a", bgcolor = bg, text_size = size.small,
         text_halign = text.align_left, text_color = color.new(color.gray, 0))

    if showAudit
        dash.cell(0, 6, "Prior H/L/C", bgcolor = bg, text_color = color.gray, text_size = size.small, text_halign = text.align_left)
        dash.cell(1, 6, valid ? str.tostring(pH, format.mintick) + " / " + str.tostring(pL, format.mintick) + " / " + str.tostring(pC, format.mintick) : "n/a",
             bgcolor = bg, text_size = size.small, text_halign = text.align_left, text_color = color.new(color.gray, 0))

if tfTooLow and barstate.islast
    label.new(bar_index, high, "Chart timeframe is higher than the pivot timeframe - switch Mode to Auto",
       style = label.style_label_down, color = color.red, textcolor = color.white, size = size.small)

// ───────────────────────── Alerts ─────────────────────────
alertcondition(ta.crossover(close, r3),  "Cross above R3", "Camarilla: close crossed above R3")
alertcondition(ta.crossunder(close, s3), "Cross below S3", "Camarilla: close crossed below S3")
alertcondition(ta.crossover(close, r4),  "Cross above R4", "Camarilla: breakout above R4")
alertcondition(ta.crossunder(close, s4), "Cross below S4", "Camarilla: breakdown below S4")
alertcondition(ta.crossunder(close, r3), "Rejection at R3", "Camarilla: close back below R3")
alertcondition(ta.crossover(close, s3),  "Rejection at S3", "Camarilla: close back above S3")
alertcondition(ta.crossover(close, r6),  "Tag R6", "Camarilla: price reached R6")
alertcondition(ta.crossunder(close, s6), "Tag S6", "Camarilla: price reached S6")
````
