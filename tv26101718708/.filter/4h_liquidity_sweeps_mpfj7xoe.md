# 4H Liquidity Sweeps

- url: https://www.tradingview.com/script/MpFj7XoE-4H-Liquidity-Sweeps/
- type: indicator
- pine_id: PUB;259f3306ba41456e9d63dfb46c07d8dd
- version: 1.0

## Description

═══════════════════════════════════════════════════════════════════════
[b]4H Liquidity Sweeps — graded, with target and R:R
[/b]
═══════════════════════════════════════════════════════════════════════


WHAT IT DOES

Marks higher-timeframe swing highs and lows that get wicked through and
rejected, then scores each one and projects where the resulting move is
aimed. Most sweep indicators stop at "a level was taken." This one asks
the two questions that decide whether the sweep is worth anything: how
long had that level been sitting there, and is there anything on the
other side to trade toward.


THE IDEA

A swing high or low is a shelf of resting orders — protective stops from
traders positioned into the swing, and breakout orders from traders
waiting for it to give way. When price trades through that shelf and
closes back inside, the move through it found no continuation, and every
order filled beyond the level is immediately offside.

That makes the sweep itself the setup's trigger, not the trade. The trade
is the return leg, and its natural destination is the nearest untouched
shelf on the opposite side. The indicator tracks both ends of that: the
level being taken, and the level being aimed at.


HOW IT WORKS

Levels
  Swing highs and lows are confirmed on the sweep timeframe (default 4H,
  independent of your chart timeframe) using a configurable pivot
  strength. Equal highs and lows resolve to the first of the pair, so
  double tops and bottoms still produce a level. Up to N unswept levels
  per side are tracked and drawn as dotted lines.

Sweep detection
  A level is swept when an HTF bar trades through it and closes back
  inside. Three optional filters refine this:

  • Minimum penetration — the wick must exceed the level by a set
    fraction of ATR(14), so one-tick clips are ignored.

  • Displacement rejection — the sweep bar must also close back inside
    the PREVIOUS HTF bar's range (Loose) or beyond its midpoint
    (Strict). This is what separates a genuine rejection from the first
    bar of a breakout that happened to clip an old level on its way
    past. Without it, a strongly trending bar can satisfy the level test
    while price is plainly still expanding.

  • Killzone — sweeps outside your chosen sessions are either dropped
    entirely, or capped at B-grade.

  A level that is CLOSED through rather than wicked through is deleted,
  not marked. That is a break, not a sweep, and it is the main reason
  the chart stays readable.

Grading
  Every sweep is scored A, B or C from two measurements:

  • Level age — how many HTF bars the level survived before it was
    taken. This does most of the work. A level that sat for two days
    accumulated orders; one from six hours ago did not.

  • Reward — R:R from the projected entry to the nearest unswept level
    on the opposite side.

  A-grade needs both thresholds (default: 12 bars, 3.0R), B-grade the
  looser pair (6 bars, 2.0R). Anything else is C and is hidden by
  default, including any sweep with no unswept level to aim at.

Trade plan
  On each qualifying sweep the indicator projects:

  • Entry — an optimal-trade-entry retracement (default 0.705) of the
    sweep bar, or the swept level itself if you prefer.
  • Stop  — beyond the sweep wick, buffered by a fraction of ATR(14).
  • Target — the nearest unswept HTF level on the opposite side.

  Each is drawn and labelled with its price, and the resulting R:R is
  printed on the sweep label. Hover any label for the full breakdown:
  grade, level age, killzone status, entry, stop, target, exact R:R.


WHAT YOU SEE

  Dotted grey line :  an unswept level, extending to the current bar
  Solid line  :  a swept level, drawn from the swing to the bar that took it (thicker for A-grade)
  Red zone / the sweep : level to wick extreme
  Green zone / the reaction leg : level to the running extreme since the sweep, growing bar by bar until price loses back through the level or the window expires
  Dashed line : the target
  Dotted lines  :  entry and stop


SETTINGS WORTH KNOWING

  Pivot strength  :2 by default. Raise to 3–4 for fewer, more significant levels.
  Level age  :the filter to adjust first. Loosen this before you :touch the R:R thresholds.
  Displacement : Loose is a sensible default; Strict will roughly halve your A-grade count.
  Hide historical  : keeps only the last N sweeps on the chart and erases everything older — useful for a live chart where only what is still in play matters.


ALERTS

  Graded sweep (A or B) — fires only on setups that pass both filters
  4H high swept / 4H low swept — directional
  4H sweep (any)


NOTES AND LIMITATIONS

  • Chart timeframe must be equal to or lower than the sweep timeframe.
    The script raises an error otherwise.

  • Nothing repaints. Higher-timeframe data is requested with lookahead
    disabled, and every sweep is evaluated only against completed HTF
    bars. A sweep therefore prints when its HTF bar closes, and a level
    is confirmed a few bars after the swing that formed it — that is
    confirmation lag, not repainting, and it is inherent to pivots.

  • The green reaction zone updates as the move develops. It is live
    state, not a signal.

  • The R:R shown is calculated from an entry proxy taken on the sweep
    bar itself. If you enter from a lower-timeframe structure shift
    instead, your actual entry — and therefore your actual R:R — will
    differ. Treat the printed figure as a screening number.

  • Killzone membership is decided by the HTF bar's OPEN time. On a 4H
    chart that means the session setting selects the bar CONTAINING the
    killzone rather than the killzone itself, so the defaults are
    deliberately widened. Narrow them if you lower the sweep timeframe.

  • This is an analysis tool, not a strategy, and it is not backtested
    within TradingView. It marks structure and projects levels; it makes
    no claim about outcomes. Nothing here is financial advice — do your
    own testing and manage your own risk.

## Source Code

````pine
//@version=6
// 4H Liquidity Sweeps — marks HTF swing highs/lows that get wicked and rejected,
// grades them by level age + reward, and projects the trade plan.
//   line   : from the swing that was taken → the bar that took it
//   red    : the sweep itself (level → wick extreme)
//   green  : the reaction leg (level → running extreme since the sweep)
//   dashed : target — nearest unswept HTF level on the opposite side
//   label  : grade + R:R measured from the OTE entry to that target
indicator("4H Liquidity Sweeps", "4H Sweeps", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ─── Inputs ──────────────────────────────────────────────────────────────
gS = "Sweep detection"
htf      = input.timeframe("240", "Timeframe",                                      group = gS)
pivLen   = input.int(2, "Pivot strength", minval = 1, maxval = 10,                  group = gS, tooltip = "Bars required either side of a swing high/low on the sweep timeframe. Higher = fewer, more significant levels.")
needBack = input.bool(true, "Require close back inside",                            group = gS, tooltip = "On: the wick takes the level but the bar must close back below (high) / above (low) it. Off: any tap counts.")
useMin   = input.bool(false, "Minimum penetration",                                 group = gS, tooltip = "Ignore sweeps that barely clip the level.")
minMult  = input.float(0.10, "    × ATR(14)", minval = 0.0, step = 0.05,            group = gS)
dispFilt = input.string("Loose", "Displacement rejection", options = ["Off", "Loose", "Strict"], group = gS, tooltip = "Suppresses sweeps that were really the first bar of a breakout: the wick clips an old level but the bar closes having expanded the range, not given it back.\n\nLoose  — the sweep bar must close inside the PREVIOUS HTF bar's range.\nStrict — it must close beyond that bar's midpoint.\n\nEither way the level is consumed and removed: the stops above it ran, sweep or not.")
maxLvl   = input.int(8, "Levels tracked per side", minval = 1, maxval = 25,         group = gS)

gK = "Killzone"
kzMode   = input.string("Off", "Mode", options = ["Off", "Filter out", "A-grade only"], group = gK, tooltip = "Filter out    — sweeps landing outside both sessions are dropped entirely.\nA-grade only  — they still print, but can never grade better than B.\n\nMembership is decided by the HTF bar's OPEN time, so on 4H it selects the bar that CONTAINS the killzone. The defaults are widened to match: 0200-0600 catches the London bar, 0600-1400 the New York bars. Narrow them if you drop to a lower sweep timeframe.")
kz1      = input.session("0200-0600", "Session 1 · London",                         group = gK)
kz2      = input.session("0600-1400", "Session 2 · New York",                       group = gK)
kzTz     = input.string("America/New_York", "Timezone", options = ["America/New_York", "Europe/London", "UTC", "Asia/Tokyo", "Asia/Shanghai", "Australia/Sydney"], group = gK)

gG = "Grading"
ageA     = input.int(12, "A-grade  min level age (HTF bars)", minval = 1,           group = gG, tooltip = "How long the level survived before it was taken. The single most important filter — a level that sat for two days accumulated orders, one from six hours ago did not.")
rrA      = input.float(3.0, "A-grade  min R:R", minval = 0.5, step = 0.1,           group = gG)
ageB     = input.int(6,  "B-grade  min level age (HTF bars)", minval = 1,           group = gG)
rrB      = input.float(2.0, "B-grade  min R:R", minval = 0.5, step = 0.1,           group = gG)
showC    = input.bool(false, "Show C-grade (unqualified) sweeps",                   group = gG, tooltip = "Sweeps failing both grades, or with no unswept level to aim at.")

gT = "Trade plan"
entryOTE = input.bool(true, "Entry at OTE of sweep bar", group = gT, tooltip = "Off: entry = the swept level itself. This is a proxy for the real 15m displacement leg, which does not exist yet when the sweep bar closes.")
oteFib   = input.float(0.705, "    Retracement", minval = 0.5, maxval = 0.9, step = 0.005, group = gT)
stopMult = input.float(0.25, "Stop buffer × ATR(14)", minval = 0.0, step = 0.05,    group = gT)
projBars = input.int(6, "Project right (HTF bars)", minval = 1, maxval = 50,        group = gT)

gH = "History"
hideHist = input.bool(false, "Hide historical sweeps", group = gH, tooltip = "Keeps only the most recent sweeps on the chart. Older ones are erased completely — line, label, zones and trade plan — so you only ever see what is still in play.")
histKeep = input.int(3, "    Keep last", minval = 1, maxval = 20,                   group = gH)

gD = "Display"
showPend = input.bool(true,  "Show unswept levels",                                 group = gD)
lblTxt   = input.string("4h sweep", "Label text",                                   group = gD)
showZone = input.bool(true,  "Sweep zone (red)",                                    group = gD)
showReac = input.bool(true,  "Reaction zone (green)",                               group = gD)
showTgt  = input.bool(true,  "Target line",                                         group = gD)
showPlan = input.bool(true,  "Entry / stop lines",                                  group = gD)
showPlLb = input.bool(true,  "Label entry / stop / target",                         group = gD)
zoneBars = input.int(12, "Max zone extension (HTF bars)", minval = 1, maxval = 100, group = gD)
lineCol  = input.color(#363a45, "Sweep line",                                       group = gD)
redCol   = input.color(#ef5350, "Sweep zone / stop",                                group = gD)
grnCol   = input.color(#26a69a, "Reaction zone",                                    group = gD)
tgtCol   = input.color(#2962ff, "Target",                                           group = gD)
pendCol  = input.color(color.new(#787b86, 35), "Unswept level",                     group = gD)

if timeframe.in_seconds() > timeframe.in_seconds(htf)
    runtime.error("Chart timeframe must be equal to or lower than the sweep timeframe (" + htf + ").")

// ─── State ───────────────────────────────────────────────────────────────
type Lvl
    float p
    int   t
    int   born     // HTF bar count when the swing formed
    line  ln

type Swp
    int   dir      // +1 = low swept (bullish), -1 = high swept (bearish)
    float lvl
    float ext      // running extreme of the reaction
    int   age
    bool  live
    box   zone
    box   react
    array<line>  lns
    array<label> lbs

var array<Lvl>   highs   = array.new<Lvl>()
var array<Lvl>   lows    = array.new<Lvl>()
var array<Swp>   swps    = array.new<Swp>()
var array<float> bH      = array.new<float>()
var array<float> bL      = array.new<float>()
var array<int>   bT      = array.new<int>()
var int          htfBars = 0

tfMs = timeframe.in_seconds(htf) * 1000

[sH, sL, sC, sT, sA, sK1, sK2] = request.security(syminfo.tickerid, htf, [high, low, close, time, ta.atr(14), not na(time(timeframe.period, kz1, kzTz)), not na(time(timeframe.period, kz2, kzTz))], lookahead = barmerge.lookahead_off)
newBar = ta.change(sT) != 0

bool sweptHigh = false
bool sweptLow  = false
bool sweptAB   = false

addLvl(array<Lvl> arr, float p, int t) =>
    line ln = na
    if showPend
        ln := line.new(t, p, t, p, xloc = xloc.bar_time, color = pendCol, style = line.style_dotted, width = 1)
    array.push(arr, Lvl.new(p, t, htfBars - pivLen, ln))
    if array.size(arr) > maxLvl
        Lvl old = array.shift(arr)
        if not na(old.ln)
            line.delete(old.ln)

// erases everything a sweep drew
purge(Swp s) =>
    if not na(s.zone)
        box.delete(s.zone)
    if not na(s.react)
        box.delete(s.react)
    if array.size(s.lns) > 0
        for i = 0 to array.size(s.lns) - 1
            line.delete(array.get(s.lns, i))
    if array.size(s.lbs) > 0
        for i = 0 to array.size(s.lbs) - 1
            label.delete(array.get(s.lbs, i))

// Grades a confirmed sweep and draws it. Returns the grade.
mark(int dir, Lvl l, float bh, float bl, int bt, float atr, bool inKz) =>
    rng   = bh - bl
    ext   = dir == 1 ? bl : bh
    entry = not entryOTE ? l.p : dir == 1 ? ext + (1.0 - oteFib) * rng : ext - (1.0 - oteFib) * rng
    stopP = dir == 1 ? ext - stopMult * atr : ext + stopMult * atr
    risk  = math.abs(entry - stopP)

    // nearest unswept level on the opposite side, beyond this bar's reach
    float tgt = na
    if dir == 1
        if array.size(highs) > 0
            for i = 0 to array.size(highs) - 1
                p = array.get(highs, i).p
                if p > bh
                    tgt := na(tgt) ? p : math.min(tgt, p)
    else
        if array.size(lows) > 0
            for i = 0 to array.size(lows) - 1
                p = array.get(lows, i).p
                if p < bl
                    tgt := na(tgt) ? p : math.max(tgt, p)

    rr  = na(tgt) or risk <= 0 ? na : math.abs(tgt - entry) / risk
    age = htfBars - l.born
    string g = "C"
    if not na(rr)
        if age >= ageA and rr >= rrA
            g := "A"
        else if age >= ageB and rr >= rrB
            g := "B"
    if kzMode == "A-grade only" and not inKz and g == "A"
        g := "B"
    blocked = kzMode == "Filter out" and not inKz

    if not blocked and (g != "C" or showC)
        tr    = g == "A" ? 0 : g == "B" ? 20 : 55
        right = bt + tfMs * projBars
        array<line>  lns = array.new<line>()
        array<label> lbs = array.new<label>()

        line ln = l.ln
        if na(ln)
            ln := line.new(l.t, l.p, bt + tfMs, l.p, xloc = xloc.bar_time)
        else
            line.set_x2(ln, bt + tfMs)
        line.set_color(ln, color.new(lineCol, tr))
        line.set_style(ln, line.style_solid)
        line.set_width(ln, g == "A" ? 2 : 1)
        array.push(lns, ln)

        txt = lblTxt + (na(rr) ? "" : (lblTxt == "" ? "" : "  ") + g + " " + str.tostring(rr, "#.0") + "R")
        tip = g + "-grade" + "\nlevel age  " + str.tostring(age) + " bars" + "\nkillzone   " + (inKz ? "yes" : "no") + "\nentry  " + str.tostring(entry, format.mintick) + "\nstop   " + str.tostring(stopP, format.mintick) + "\ntarget " + (na(tgt) ? "none" : str.tostring(tgt, format.mintick)) + "\nR:R    " + (na(rr) ? "n/a" : str.tostring(rr, "#.00"))
        array.push(lbs, label.new(bt, l.p, txt, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = color.new(lineCol, tr), size = size.tiny, tooltip = tip))

        if showTgt and not na(tgt)
            array.push(lns, line.new(bt, tgt, right, tgt, xloc = xloc.bar_time, color = color.new(tgtCol, tr), style = line.style_dashed, width = 1))
            if showPlLb
                array.push(lbs, label.new(right + tfMs, tgt, "TARGET " + str.tostring(tgt, format.mintick) + (na(rr) ? "" : "  " + str.tostring(rr, "#.0") + "R"), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = color.new(tgtCol, tr), size = size.tiny, tooltip = "Nearest unswept " + htf + " level"))
        if showPlan
            array.push(lns, line.new(bt, entry, right, entry, xloc = xloc.bar_time, color = color.new(lineCol, tr + 25), style = line.style_dotted, width = 1))
            array.push(lns, line.new(bt, stopP, right, stopP, xloc = xloc.bar_time, color = color.new(redCol,  tr + 25), style = line.style_dotted, width = 1))
            if showPlLb
                array.push(lbs, label.new(right + tfMs, entry, "ENTRY " + str.tostring(entry, format.mintick), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = color.new(lineCol, tr), size = size.tiny, tooltip = entryOTE ? "OTE " + str.tostring(oteFib) + " of the sweep bar" : "The swept level"))
                array.push(lbs, label.new(right + tfMs, stopP, "STOP " + str.tostring(stopP, format.mintick), xloc = xloc.bar_time, yloc = yloc.price, style = label.style_none, textcolor = color.new(redCol, tr), size = size.tiny, tooltip = "Wick tip ∓ " + str.tostring(stopMult) + " × ATR(14)"))

        box zb = na
        box rb = na
        if showZone
            zb := box.new(bt, dir == 1 ? l.p : bh, bt + tfMs, dir == 1 ? bl : l.p, xloc = xloc.bar_time, border_color = color.new(redCol, 70 + tr / 4), bgcolor = color.new(redCol, 88 + tr / 10))
        if showReac
            rb := box.new(bt, dir == 1 ? bh : l.p, bt + tfMs, dir == 1 ? l.p : bl, xloc = xloc.bar_time, border_color = color.new(grnCol, 70 + tr / 4), bgcolor = color.new(grnCol, 88 + tr / 10))

        array.push(swps, Swp.new(dir, l.p, dir == 1 ? bh : bl, 0, true, zb, rb, lns, lbs))
        if hideHist
            while array.size(swps) > histKeep
                Swp old = array.shift(swps)
                purge(old)
        else if array.size(swps) > 40
            array.shift(swps)
    else if not na(l.ln)
        line.delete(l.ln)
    blocked ? "X" : g    // X = killzone-filtered: not drawn, and no alert at all

// ─── Main: runs once per completed HTF bar ───────────────────────────────
if newBar and bar_index > 0 and not na(sH[1])
    cH = sH[1]
    cL = sL[1]
    cC = sC[1]
    cT = sT[1]
    inKz   = sK1[1] or sK2[1]
    atrV   = nz(sA[1])
    minPen = useMin ? minMult * atrV : 0.0
    htfBars := htfBars + 1

    array.push(bH, cH)
    array.push(bL, cL)
    array.push(bT, cT)
    if array.size(bH) > 60
        array.shift(bH)
        array.shift(bL)
        array.shift(bT)

    // 1. grow / close out the zones of sweeps already on the chart
    if array.size(swps) > 0
        for i = 0 to array.size(swps) - 1
            Swp s = array.get(swps, i)
            if s.live
                s.age := s.age + 1
                if s.dir == 1
                    s.ext := math.max(s.ext, cH)
                    if not na(s.react)
                        box.set_top(s.react, s.ext)
                    if cC < s.lvl
                        s.live := false
                else
                    s.ext := math.min(s.ext, cL)
                    if not na(s.react)
                        box.set_bottom(s.react, s.ext)
                    if cC > s.lvl
                        s.live := false
                if s.age >= zoneBars
                    s.live := false
                if not na(s.zone)
                    box.set_right(s.zone, cT + tfMs)
                if not na(s.react)
                    box.set_right(s.react, cT + tfMs)

    // 2. confirm a new swing high / low pivLen bars back
    n = array.size(bH)
    if n >= pivLen * 2 + 1
        ci = n - 1 - pivLen
        ph = array.get(bH, ci)
        pl = array.get(bL, ci)
        bool isPH = true
        bool isPL = true
        for i = ci - pivLen to ci + pivLen
            if i != ci
                // left side strict, right side inclusive → the first of two equal highs is the level
                if i < ci
                    isPH := isPH and array.get(bH, i) <  ph
                    isPL := isPL and array.get(bL, i) >  pl
                else
                    isPH := isPH and array.get(bH, i) <= ph
                    isPL := isPL and array.get(bL, i) >= pl
        if isPH
            addLvl(highs, ph, array.get(bT, ci))
        if isPL
            addLvl(lows, pl, array.get(bT, ci))

    // 3. displacement rejection — did this bar give the range back, or expand it?
    bool dispUp = true      // clears a HIGH sweep (bearish)
    bool dispDn = true      // clears a LOW sweep (bullish)
    if dispFilt != "Off" and n >= 2
        prvH = array.get(bH, n - 2)
        prvL = array.get(bL, n - 2)
        prvM = (prvH + prvL) / 2
        dispUp := cC <= (dispFilt == "Strict" ? prvM : prvH)
        dispDn := cC >= (dispFilt == "Strict" ? prvM : prvL)

    // 4. test the bar that just closed against every live level
    if array.size(highs) > 0
        for i = array.size(highs) - 1 to 0
            Lvl l = array.get(highs, i)
            if cH > l.p + minPen
                if (not needBack or cC < l.p) and dispUp
                    g = mark(-1, l, cH, cL, cT, atrV, inKz)
                    sweptHigh := sweptHigh or g != "X"
                    sweptAB   := sweptAB or g == "A" or g == "B"
                else if not na(l.ln)
                    line.delete(l.ln)   // closed through it — level is broken, not swept
                array.remove(highs, i)

    if array.size(lows) > 0
        for i = array.size(lows) - 1 to 0
            Lvl l = array.get(lows, i)
            if cL < l.p - minPen
                if (not needBack or cC > l.p) and dispDn
                    g = mark(1, l, cH, cL, cT, atrV, inKz)
                    sweptLow := sweptLow or g != "X"
                    sweptAB  := sweptAB or g == "A" or g == "B"
                else if not na(l.ln)
                    line.delete(l.ln)
                array.remove(lows, i)

// 5. keep unswept levels drawn up to the current bar
if barstate.islast and showPend
    if array.size(highs) > 0
        for i = 0 to array.size(highs) - 1
            l = array.get(highs, i)
            if not na(l.ln)
                line.set_x2(l.ln, time)
    if array.size(lows) > 0
        for i = 0 to array.size(lows) - 1
            l = array.get(lows, i)
            if not na(l.ln)
                line.set_x2(l.ln, time)

// ─── Alerts ──────────────────────────────────────────────────────────────
alertcondition(sweptAB,   "Graded sweep (A or B)", "Qualified 4H sweep — check the 15m for an MSS")
alertcondition(sweptHigh, "4H high swept",         "4H buy-side liquidity swept and rejected")
alertcondition(sweptLow,  "4H low swept",          "4H sell-side liquidity swept and rejected")
alertcondition(sweptHigh or sweptLow, "4H sweep (any)", "4H liquidity sweep")

plotshape(sweptHigh, "High sweep marker", shape.triangledown, location.abovebar, redCol, size = size.tiny, display = display.none)
plotshape(sweptLow,  "Low sweep marker",  shape.triangleup,   location.belowbar,  grnCol, size = size.tiny, display = display.none)
````
