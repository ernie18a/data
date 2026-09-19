<!-- tradingview-pine-id: PUB;2649f58f72064d038bc10aaf62dd001d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# LG9k StochSlow Zone-Cross (tiered)

Source: https://www.tradingview.com/script/1jtVJlku-LG9k-StochSlow-Zone-Cross-tiered/

## Description

StochSlow Zone-Cross (Tiered + EXTREME)

A ThinkorSwim-accurate StochasticSlow that ranks its own crossover signals instead of firing an arrow at every one. Built for 3-minute futures scalping, works on any symbol or timeframe.

WHAT PROBLEM IT SOLVES

A plain stochastic crossover indicator fires constantly. On a 3-minute /ES chart a single overnight session can produce a dozen-plus arrows, and several of them are the same swing signalling repeatedly — the oscillator dips back under 20, crosses, ticks up, dips again, crosses again. This script keeps every one of those crosses visible but sorts them into ranked tiers, and only alerts on the higher ranks.

THE STOCHASTIC MATH

This reproduces ThinkorSwim's StochasticSlow, which is a three-stage calculation. Most TradingView stochastics use two stages, which is why their values differ from a ToS chart.

Stage 1 — rawK = 100 × (close − lowest low over K) ÷ (highest high over K − lowest low over K)
Stage 2 — SlowK = SMA(rawK, Slowing)
Stage 3 — SlowD = SMA(SlowK, D)
Defaults: K period 10, D period 3, Slowing 3, SMA averaging. Set these to match your ToS chart and the lines will overlay bar for bar.

TWO OVERBOUGHT/OVERSOLD PAIRS

Pair 1 (default 80 / 20) — the ordinary zone. A crossover only counts as a signal if SlowK was inside this zone within the last N bars (default 5).
Pair 2 (default 95 / 5) — the EXTREME zone, drawn as a dotted line with its own shaded band.
Both pairs are set in the Inputs tab, not Style. That is deliberate: Pine only allows a Style-editable horizontal line value if it is a fixed constant, and a constant is invisible to the script. If the levels lived in Style, changing 95 to 97 would move the line while the alerts kept firing at 95. Driven from Inputs, the line and the alert can never disagree.

THE EXCURSION GATE (the main noise filter)

After a signal fires, SlowK must climb back out of the zone before that same direction is allowed to fire again. This collapses repeat-fire clusters on a single swing down to one signal. It is on by default.

THE TIERS

EXTREME — SlowK reached the deep zone (≤5 for a long, ≥95 for a short) within the lookback AND is still inside the ordinary 20/80 zone on the crossover bar. Drawn as a labelled "X" marker with a background flash. That second condition matters: without it, a cross at SlowK 78 would qualify as "extreme" merely because SlowK tagged 95 five bars earlier.
A — a zone cross occurring within the proximity setting of one of your levels. Large bright triangle.
B — a zone cross with no level nearby. Smaller, darker triangle. Same event, lower rank.
C — a cross that failed the trend gate. Tiny grey X-cross, never alerts. With default settings the trend gate is off, so tier C does not appear unless you enable it.
THE LEVEL GATE

Paste your own levels as a comma-separated list. Any levels work — pivots, prior day high/low, VWAP bands, a newsletter's numbers. A cross within the proximity distance of one of them is promoted to tier A. Proximity is session-aware: separate values for RTH (09:30–16:00 New York) and overnight, because a level that is meaningful within 8 points in a liquid session is usually not within 8 points in thin overnight trade.

THE TREND GATE — OFF BY DEFAULT, AND WHY

There is an optional 8 EMA + Parabolic SAR filter requiring longs above the EMA with bullish SAR and shorts below with bearish SAR. It is disabled by default because it is structurally at odds with this signal: a stochastic zone cross happens at a local price extreme, which is almost by definition on the wrong side of a short EMA. In testing on /ES 3-minute data it passed 0 of 16 signals on one overnight session and 2 of 28 across all available 3-minute history. Turn it on if you want a momentum-confirmation reading, but expect it to silence most signals.

ALERTS

Seven separate alert conditions — EXTREME long, EXTREME short, EXTREME either-way, A long, A short, B long, B short. They are separate so each can be given its own sound. Note that Pine cannot select an alert sound; that is chosen per-alert in TradingView's Notifications tab when you create the alert.

THE ON-CHART COUNTER

A label in the corner shows EXTREME / A / B / C counts across loaded history. Use it to sanity-check your settings: if A reads zero over thousands of bars, your proximity is too tight or your level list is stale.

USING IT ON A 3-MINUTE CHART

Rough expectations on /ES with default settings: raw zone crosses run around 30 per day, and EXTREME fires roughly 14 times per day. EXTREME is therefore a "look at this now" prompt, not a rare event. If you want it rarer, tighten pair 2 to 3/97, raise the excursion requirement, or run the indicator on 5m or 15m.

Update your level list daily — a stale list silently demotes every genuine tier A signal to tier B. Start proximity around 5 points overnight and 8 during RTH on /ES, then adjust to how tightly your instrument respects levels.

HONEST LIMITATIONS — PLEASE READ

This script ranks and de-duplicates signals. It does not claim an edge, and my own testing says the underlying trigger does not have one on /ES.

Across 4,694 zone crosses over nine months of 5-minute /ES data, with exits walked forward from each entry using a 1×ATR stop, the win rate tracked the geometric breakeven line 1÷(1+R) within about one percentage point at every target tested from 0.5R to 3.0R — 65.6% at 0.5R against a 66.7% breakeven, 40.1% at 1.5R against 40.0%, and so on. Extreme-depth crosses behaved the same. That pattern means the strike rate is determined by the reward-to-risk you choose, not by the setup.

Treat the tiers as a way to reduce alert spam and organize what you are looking at. Any decision to trade or size off these signals needs your own testing on your own instrument and timeframe.

---

## Source Code

````pine
//@version=6
// LG9k — ToS StochasticSlow zone-cross, TIERED + EXTREME (Bill 2026-09-17)
//
// Four tiers on one trigger, drawn always, alerting selectively:
//
//   EXTREME  cross out of a DEEP zone -- SlowK <= 5 for a long, >= 95 for a short.
//            Its own loud alert. Not trend-gated (see below).
//   A        zone cross AT a Mancini major (within `prox`). Large bright triangle.
//            Also requires trend alignment IF the trend gate is on (it defaults off).
//   B        zone cross that passed the enabled gates but is NOT near a major.
//            Small, darker triangle -- same event, lower rank.
//   C        zone cross that failed the trend gate (only reachable with that gate
//            on). Tiny blue-grey x. Never alerts.
//
// Gates:
//   EXCURSION  SlowK must climb back out of the zone before the same side can fire
//              again. On the overnight /ES chart of 2026-09-17 one elevated swing
//              produced four bearish arrows (02:30/02:45/03:10/03:35); this
//              collapses runs like that. Measured on the real bars of that window
//              it removed 3 of 16 -- helpful, not a cure.
//   TREND      8 EMA + PSAR, mirroring `require_trend=True` in the live Python
//              alerter. NOTE: on that same 16-signal window it passed 0, and only
//              2 of 28 across all available 3m history. That is structural, not a
//              bug -- a zone cross happens AT a local extreme, which is by
//              definition the wrong side of the 8 EMA. The trend gate and this
//              signal are anti-correlated by construction, which is why EXTREME
//              deliberately bypasses it.
//   LEVEL      within `prox` points of a Mancini major (majors are regenerated
//              daily into pine/mancini_levels.pine -- paste them below).
//
// ══ WHAT THE DATA SAYS — READ BEFORE TRADING THIS ════════════════════════════
// Measured on 4,694 zone crosses over 9 months of native 5m /ES bars, exits
// forward-walked from each entry (stop 1.0xATR, ties scored as stops):
//
//     target    breakeven    NORMAL(<=20/>=80)    EXTREME(<=5/>=95)
//      0.5R       66.7%          65.6%                65.6%
//      1.0R       50.0%          49.7%                51.1%
//      1.5R       40.0%          40.1%                40.7%
//      2.0R       33.3%          34.3%                35.1%
//      3.0R       25.0%          27.3%                29.4%
//
// The win rate tracks the geometric breakeven line within ~1pp at every target,
// for both depths. That is the signature of a signal carrying NO directional
// information -- the strike rate is set by the reward:risk you pick, not by the
// setup. Depth does not help (EXTREME avgR +0.012 on n=659). Level confluence
// looked strong at n<30 but was a period artifact. The live paper book agrees:
// 170 tracked trades, -1,011 points, and star rank did not rank.
//
// So this script is a SPAM FILTER and a RANKING FOR THE EYE. It is not an edge,
// and nothing in it should be sized off without a separate, positive study.
// ═════════════════════════════════════════════════════════════════════════════

indicator("LG9k StochSlow Zone-Cross (tiered)", overlay = false, precision = 2, max_labels_count = 500)

// ── Stochastic (ToS StochasticSlow 3-stage: rawK -> slowing -> FullK -> FullD) ─
grpS = "Stochastic (ToS StochasticSlow)"
kPeriod  = input.int(10,  "K period",         group = grpS, minval = 1)
dPeriod  = input.int(3,   "D period",         group = grpS, minval = 1)
slowing  = input.int(3,   "Slowing (smooth)", group = grpS, minval = 1)
obLevel  = input.float(80, "Overbought 1",    group = grpS, inline = "ob1")
osLevel  = input.float(20, "Oversold 1",      group = grpS, inline = "os1")
zoneBars = input.int(5, "Cross counts if K was in the zone within N bars", group = grpS, minval = 1)

hh  = ta.highest(high, kPeriod)
ll  = ta.lowest(low, kPeriod)
rng = hh - ll
rawK  = rng == 0 ? 50.0 : 100.0 * (close - ll) / rng
fullK = ta.sma(rawK, slowing)
fullD = ta.sma(fullK, dPeriod)

// ── EXTREME ───────────────────────────────────────────────────────────────────
grpE = "EXTREME tier"
useExtreme   = input.bool(true, "Enable EXTREME tier", group = grpE)
// Second OB/OS pair (Bill 2026-09-17). These live in INPUTS, not Style, on purpose:
// an hline whose value box is editable in the Style tab must be a Pine CONSTANT, and
// a constant is invisible to the script -- so editing 95 -> 97 there would MOVE THE
// LINE while the alerts kept firing at 95. A band that disagrees with its own alert
// is worse than no band. Driven from here, the line and the alert cannot drift.
extremeOb    = input.float(95, "Overbought 2 (EXTREME)", group = grpE, inline = "ob2")
extremeOs    = input.float(5,  "Oversold 2 (EXTREME)",   group = grpE, inline = "os2")
extremeTrend = input.bool(false, "EXTREME must also pass the trend gate", group = grpE, tooltip = "Off by default: the trend gate passed 0 of 16 signals on the 2026-09-17 overnight window and 2 of 28 across all 3m history, because a zone cross sits on the wrong side of the 8 EMA by construction. Turning this on will silence EXTREME almost entirely.")
extremeLevel = input.bool(false, "EXTREME must also be near a major",     group = grpE)

// ── Gates ─────────────────────────────────────────────────────────────────────
grpG = "Gates"
useExcursion = input.bool(true, "Excursion gate (one signal per zone visit)",   group = grpG)
// Default OFF (Bill 2026-09-17). With it ON, A/B need 8EMA+PSAR alignment, which
// passed 0 of 7 signals on his overnight window and ~5% overall -- a zone cross
// sits on the wrong side of the 8 EMA by construction -- so every non-EXTREME
// signal collapsed into tier C and the A/B arrows never appeared. With it OFF,
// tiering falls back to level proximity and actually spreads the signals out.
useTrend     = input.bool(false, "Trend gate (8 EMA + PSAR) for tiers A/B",     group = grpG)
useLevel     = input.bool(true, "Level gate (near a Mancini major) for tier A", group = grpG)
emaLen       = input.int(8, "EMA length", group = grpG, minval = 1)
showCounter  = input.bool(true, "Show tier counter", group = grpG)
showC        = input.bool(true, "Draw tier C (the lowest-ranked crosses)", group = grpG)
// NOTE (Bill 2026-09-17): every plot colour here is a compile-time CONSTANT on
// purpose. Pine only renders the Style-tab colour picker for constant colours --
// the moment a colour is computed from an input or a series, TradingView removes
// the picker, since the script would overwrite whatever you chose. A short-lived
// "dimRejects" input did exactly that and cost the pickers on B and C. Opacity is
// already part of the Style picker, so the input bought nothing. Do not
// reintroduce a colour that depends on an input.

ema8 = ta.ema(close, emaLen)
psar = ta.sar(0.02, 0.02, 0.2)
trendLong  = close > ema8 and psar < close
trendShort = close < ema8 and psar > close

// ── Levels + session-aware proximity ──────────────────────────────────────────
grpL = "Mancini levels"
majorsCsv  = input.string("7469,7526,7584,7604,7622,7663,7687,7695,7714,7728,7759,7782", "MAJORS (comma separated)", group = grpL)
proxRth    = input.float(8.0, "Proximity, RTH (points)",    group = grpL, step = 0.25)
proxGlobex = input.float(5.0, "Proximity, Globex (points)", group = grpL, step = 0.25)

var float[] majors = array.new_float(0)
if barstate.isfirst
    parts = str.split(str.replace_all(majorsCsv, " ", ""), ",")
    for i = 0 to array.size(parts) - 1
        v = str.tonumber(array.get(parts, i))
        if not na(v)
            array.push(majors, v)

nearestMajor(float px) =>
    float best = na
    if array.size(majors) > 0
        for i = 0 to array.size(majors) - 1
            d = math.abs(px - array.get(majors, i))
            best := na(best) or d < best ? d : best
    best

inRth     = not na(time(timeframe.period, "0930-1600:23456", "America/New_York"))
prox      = inRth ? proxRth : proxGlobex
dist      = nearestMajor(close)
nearLevel = not na(dist) and dist <= prox

// ── Signals ───────────────────────────────────────────────────────────────────
bullCross = ta.crossover(fullK, fullD)
bearCross = ta.crossunder(fullK, fullD)
kLo = ta.lowest(fullK, zoneBars)
kHi = ta.highest(fullK, zoneBars)

bullRaw = bullCross and kLo <= osLevel
bearRaw = bearCross and kHi >= obLevel
// The deep touch may be up to `zoneBars` back, so ALSO require K to still be in
// the ordinary zone as it crosses. Without this a cross at K=78.9 qualified as
// "EXTREME" because K had tagged 95 five bars (15 min on 3m) earlier -- true to
// the lookback, misleading on the chart.
bullDeep = bullCross and kLo <= extremeOs and fullK <= osLevel
bearDeep = bearCross and kHi >= extremeOb and fullK >= obLevel

// Excursion: after a signal, K must leave the zone before the same side re-arms.
var bool bullArmed = true
var bool bearArmed = true
bullSig = bullRaw and (not useExcursion or bullArmed)
bearSig = bearRaw and (not useExcursion or bearArmed)
if bullSig
    bullArmed := false
else if fullK > osLevel
    bullArmed := true
if bearSig
    bearArmed := false
else if fullK < obLevel
    bearArmed := true

trendOkL = not useTrend or trendLong
trendOkS = not useTrend or trendShort
levelOk  = not useLevel or nearLevel

// EXTREME outranks A. Its gates are independent and default to off.
xLong  = useExtreme and bullSig and bullDeep and (not extremeTrend or trendLong)  and (not extremeLevel or nearLevel)
xShort = useExtreme and bearSig and bearDeep and (not extremeTrend or trendShort) and (not extremeLevel or nearLevel)

aLong  = bullSig and not xLong  and trendOkL and levelOk
aShort = bearSig and not xShort and trendOkS and levelOk
bLong  = bullSig and not xLong  and trendOkL and not aLong
bShort = bearSig and not xShort and trendOkS and not aShort
cLong  = bullSig and not xLong  and not trendOkL
cShort = bearSig and not xShort and not trendOkS

// ── Plot ──────────────────────────────────────────────────────────────────────
plot(fullK, "SlowK", color = #26C6DA, linewidth = 2)
plot(fullD, "SlowD", color = #EF5350, linewidth = 2)
hline(obLevel, "Over Bought 1", color = color.new(color.gray, 50), linestyle = hline.style_dashed)
hline(osLevel, "Over Sold 1",   color = color.new(color.gray, 50), linestyle = hline.style_dashed)
xo = hline(extremeOb, "Over Bought 2", color = color.new(#FF1744, 40), linestyle = hline.style_dotted)
xs = hline(extremeOs, "Over Sold 2",   color = color.new(#00E676, 40), linestyle = hline.style_dotted)
fill(hline(100), xo, color = color.new(#FF1744, 88))
fill(xs, hline(0),  color = color.new(#00E676, 88))

// Everything is drawn; only EXTREME/A/B alert — so the filter stays auditable.
plotshape(xLong  ? fullK : na, "EXTREME LONG",  shape.labelup,      location.absolute, #00E676, text = "X", textcolor = color.black, size = size.normal)
plotshape(xShort ? fullK : na, "EXTREME SHORT", shape.labeldown,    location.absolute, #FF1744, text = "X", textcolor = color.white, size = size.normal)
plotshape(aLong  ? fullK : na, "A LONG",        shape.triangleup,   location.absolute, #00E676, size = size.normal)
plotshape(aShort ? fullK : na, "A SHORT",       shape.triangledown, location.absolute, #FF1744, size = size.normal)
plotshape(bLong  ? fullK : na, "B LONG",        shape.triangleup,   location.absolute, #00B85C, size = size.small)
plotshape(bShort ? fullK : na, "B SHORT",       shape.triangledown, location.absolute, #C4142F, size = size.small)
plotshape(showC and cLong  ? fullK : na, "C LONG",  shape.xcross,   location.absolute, #B0BEC5, size = size.tiny)
plotshape(showC and cShort ? fullK : na, "C SHORT", shape.xcross,   location.absolute, #B0BEC5, size = size.tiny)
bgcolor(xLong ? color.new(#00E676, 88) : xShort ? color.new(#FF1744, 88) : na, title = "EXTREME flash")

// ── Alerts (one per condition so each takes its own sound in Notifications) ───
alertcondition(xLong,          "🔥 EXTREME LONG  (K<=5)",   "EXTREME LONG {{ticker}} {{close}} — StochSlow crossed up out of <=5. Deep oversold reversal.")
alertcondition(xShort,         "🔥 EXTREME SHORT (K>=95)",  "EXTREME SHORT {{ticker}} {{close}} — StochSlow crossed down out of >=95. Deep overbought reversal.")
alertcondition(xLong or xShort, "🔥 EXTREME either way",    "EXTREME {{ticker}} {{close}} — StochSlow reversed out of a deep zone.")
alertcondition(aLong,          "A LONG  — cross AT a level",  "A LONG {{ticker}} {{close}} — stoch zone cross AT a Mancini major")
alertcondition(aShort,         "A SHORT — cross AT a level",  "A SHORT {{ticker}} {{close}} — stoch zone cross AT a Mancini major")
alertcondition(bLong,          "B LONG  — cross, no level",          "B LONG {{ticker}} {{close}} — stoch zone cross, no level nearby")
alertcondition(bShort,         "B SHORT — cross, no level",          "B SHORT {{ticker}} {{close}} — stoch zone cross, no level nearby")

// ── Diagnostics: is the filter too strict today? ──────────────────────────────
var int nX = 0
var int nA = 0
var int nB = 0
var int nC = 0
if xLong or xShort
    nX += 1
if aLong or aShort
    nA += 1
if bLong or bShort
    nB += 1
if cLong or cShort
    nC += 1
if showCounter and barstate.islast
    var label lab = na
    label.delete(lab)
    lab := label.new(bar_index, 100, str.format("EXTREME {0} · A {1} · B {2} · C {3}", nX, nA, nB, nC), style = label.style_label_left, color = color.new(color.black, 20), textcolor = color.white, size = size.small)
````
