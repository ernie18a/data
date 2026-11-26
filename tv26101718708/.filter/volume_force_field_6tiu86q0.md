# Volume Force Field

- url: https://www.tradingview.com/script/6tIU86q0-Volume-Force-Field/
- type: indicator
- pine_id: PUB;d5ec2a8645d944b88ab34ee5e8d0cdb3
- version: 3.0

## Description

Volume Force Field — TradingView publication kit


Volume Force Field turns a volume profile into a force map. A normal profile shows you where value is. This overlay shows you the net pull on price at every level — the slope of the volume landscape toward the nearest magnet — and then it measures, on your own history, whether that pull actually leads price. One plain-language panel tells a non-technical trader what it means at a glance.

What it plots


The force field — coloured bands across price. Green means price at that level is being drawn up toward a high-volume magnet; red means drawn down. Band opacity scales with how much volume sits there.
POC and magnets — the yellow line is the Point of Control (the single strongest magnet); green lines are secondary magnets; dashed red lines are low-volume ridges that price tends to cross quickly.
Value Area — the shaded band holding your chosen % of volume around the POC: the range where trade has been accepted.
Value centre ± band — a moving equilibrium (rolling VWAP / adaptive MA / EMA) with a σ band: the drift level price is pulled back toward.
Guidance panel — plain English: the current bias (pulling up / down / balanced), location vs value (inside / stretched above / stretched below), the nearest magnet and distance, and one line on what to watch.
Past signal marks — small triangles wherever the net pull historically turned strongly up or down, so you can eyeball how the field has behaved.


Why these components are one tool (not several indicators stacked)

Each part answers a question the others cannot, and removing any one breaks the read:


Volume kernel density builds a smooth value landscape whose peaks are magnets. Optional lower-timeframe slicing distributes each bar's volume across its true intrabar path; an optional half-life lets recent volume outweigh old, so the field is a living map, not a flat lookback.
The density gradient turns that landscape into a force — the direction and steepness of attraction at each level, which a plain density cloud never exposes.
The Value Area frames where price is accepted versus stretched, so the force is read in context.
The moving value centre adds the mean-reversion pull toward equilibrium.
The calibration harness back-measures the whole thesis: when the pull is strong, did price actually travel toward the magnet more often than the base rate? It reports Hit %, Base % and Edge.


Density is a picture; the gradient makes it a force; the Value Area frames it; the centre adds drift; the harness keeps it honest. Together they are one decision object.

How to use it

Read the guidance panel first — it states the bias, where price sits versus value, the nearest magnet, and what to watch. On the chart, treat green bands as upward pull toward the magnet above and red as downward pull; the POC and magnet lines are targets; dashed lines are fast low-volume gaps; the Value Area is the accepted range; the centre ± band is the drift equilibrium. Turn on the Calibration table and read Edge: a strong pull with a positive, matured Edge is the context this tool is built to surface. An Edge near zero means the attraction is not exploitable on that symbol/timeframe — that is useful information, not a trade trigger. This is a context map, not a signal generator; combine it with your own risk and execution rules.

Universal across markets

Price source and volume feed are inputs, so it runs on any symbol. Instruments without real volume fall back automatically to a price-density field. Default settings target an index-futures 1-minute chart; change the lookback, centre and slice resolution to suit other assets and timeframes.

Originality

The building blocks are standard and credited below; the original work is the coupling and the rendering — a volume kernel density whose gradient is drawn as a directional force field, fused with a Value Area and a moving value centre, with magnet/ridge extraction and a forward base-rate harness that reports each strong-pull setup's realised Edge instead of asserting that magnets work. No third-party Pine code is reused.

Concept credit

Kernel density estimation — Emanuel Parzen (1962) and Murray Rosenblatt (1956); bandwidth rule — B. W. Silverman (1986). Point of Control / Value Area / Market Profile — J. Peter Steidlmayer. Moving-equilibrium ("price in a moving potential") market models — Hideki Takayasu, Takayuki Mizuno and Tsutomu Watanabe. Not affiliated with, nor endorsed by, any third party.

Honesty / limitations

No tick or order-book tape is available to scripts, so the density is built from OHLCV and optional lower-timeframe slices — a proxy, not the true traded distribution. Lower-timeframe slices exist only for recent bars; older bars use bar price automatically. "Force" is a hypothesis the Edge stat exists to falsify. The harness uses a light proxy of the field (the full grid cannot be recomputed on every bar), so it tests the idea rather than the exact drawn object. Like any volume profile, the last (forming) bar's field refreshes in real time; on closed bars it is fixed. Edge figures are in-sample, close-to-close, without costs — a study aid, not a verified backtest. Nothing here predicts price.

Disclaimer

For research and educational purposes only. This script is not financial advice, not a recommendation, and not a guarantee of future results. Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss. Test on out-of-sample data and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                   MPL-2.0
// VOLUME FORCE FIELD                                                                          v2.2
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   Volume profiles show you WHERE value is. This overlay shows you the PULL — the net force acting
//   on price at each level — and then TESTS whether that pull actually leads price. A volume-weighted
//   kernel density over price builds a smooth "value" landscape: deep wells at high-volume magnets,
//   ridges at low-volume gaps. The FORCE at a level is the slope of that landscape toward the nearest
//   magnet, blended with a restoring pull toward a moving value centre. The field is coloured by pull
//   DIRECTION (green = drawn up, red = drawn down), the Value Area frames where trade is accepted,
//   and a plain-language panel says what it means at a glance. It is a context map, not a signal.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool, not several overlays)
//   - VALUE GRAVITY (volume KDE): a smooth density; peaks are magnets (the POC is the strongest).
//     Optional intrabar precision distributes each bar's volume across its true traded range, and an
//     optional half-life lets recent volume outweigh old, so the field is a LIVING map.
//   - THE FORCE (density gradient): price is drawn toward higher density; the field renders the SLOPE
//     — direction and steepness of that attraction — which a plain density "cloud" never shows.
//   - VALUE AREA: the price band holding the chosen % of volume around the POC — the accepted range.
//   - DRIFT RESTORING (moving value centre): a mean-reversion pull toward a moving equilibrium.
//   - CALIBRATION HARNESS: when the net pull is strong, did price actually travel toward the magnet
//     over a fixed horizon, more than the base rate? Reports Hit / Base / EDGE. Density is a picture;
//     the gradient makes it a force; the value area frames it; the harness keeps it honest.
//
// HOW IT WORKS
//   Over the lookback, every bar (or its intrabar slices) drops its volume into a price histogram,
//   which is smoothed once by a Gaussian to give the density D(p). Peaks are magnets (POC = global
//   peak); the Value Area grows outward from the POC to the chosen % of volume; valleys below a
//   threshold are low-volume ridges. The value force at a level is dD/dp (toward the nearest peak);
//   the drift force is -(p - centre); their weighted blend is the net field. A light per-bar proxy of
//   the same field feeds the harness so the attraction idea can be back-measured across history.
//
// HOW TO USE
//   Read the guidance panel first — it states the bias, where price sits vs value, the nearest magnet,
//   and one plain line on what to watch. On the chart: green bands pull up toward the magnet above, red
//   pull down; the yellow POC and green magnet lines are targets; dashed lines are low-volume gaps price
//   crosses fast; the centre ± band is the drift equilibrium; the Value Area is the accepted range.
//   Watch the EDGE stat: a strong pull with a positive, matured Edge is the context this tool surfaces;
//   an Edge near zero means the attraction is not exploitable here — information, not a trigger.
//
// UNIVERSAL ACROSS MARKETS
//   Price source and volume feed are inputs. Symbols without real volume fall back to a price-density
//   field automatically. Default settings target an index-futures 1-minute chart; change them per asset.
//
//
// EDGE IS NOW BOUNDED, NOT ASSERTED  (v2.1)
//   The Edge figure is a POINT ESTIMATE, and on a modest sample a +4 pt reading
//   and pure noise look identical. Every Edge now carries a WILSON 95% LOWER
//   BOUND beside it:  Edge LB = wilsonLo(hit rate) - base rate.  The panel turns
//   green ONLY when that lower bound clears zero with an adequate sample - a
//   positive point estimate alone is no longer coloured as though it were
//   evidence. Expect the bound to sit below zero far more often than the point
//   estimate does; that is the honest picture of a modest sample, not a fault in
//   the measurement.
//   Edge figures remain IN-SAMPLE and without costs - a study aid, not a backtest.
// NON-REPAINT NOTE
//   Centre, bands and the harness use confirmed closed bars with no higher-timeframe lookahead. Like any
//   volume profile, the last (forming) bar's field refreshes in real time; on closed bars it is fixed.
//   Edge figures are in-sample, close-to-close, no costs — a study aid, not a verified backtest.
//
// CONCEPT CREDIT
//   Built on standard, published quantitative techniques, each named so it can be checked:
//     • Kernel density estimation — Rosenblatt (1956), Parzen (1962); Silverman's rule-of-thumb bandwidth.
//     • Volume-at-price / Value-Area & POC — J. Peter Steidlmayer's Market Profile (CBOT, 1980s).
//     • Moving-equilibrium ("restoring pull") — standard mean-reversion / Ornstein–Uhlenbeck intuition.
//     • Wilson score interval (1927) — the honest lower bound on the calibration hit-rate.
//   These are public-domain statistical methods. What is ORIGINAL here — and why this is one tool, not a
//   mashup of them — is the COUPLING: taking the SLOPE (gradient) of a volume KDE as a directional
//   "force", blending it with a drift-restoring term into a single signed field, and then subjecting that
//   field to a self-calibrating Wilson-bounded in-sample edge test. No third-party Pine code is reused;
//   the implementation, coupling and rendering are entirely original. Not affiliated with, nor endorsed
//   by, any third party.
//
// CHANGELOG
//   v2.2 — Force-acceleration layer: fAccel = Δ of the net pull, EMA-smoothed (fAccelS), reported as a
//          "Pull trend" panel row (building / fading-into-absorption / steady) and exported as
//          EXP_ForceAccel for other scripts. Three new alerts: pull accelerating up, accelerating down,
//          and pull fading (a strong attraction being absorbed at the level). Optional VSA bar-event
//          alerts (Upthrust / Shakeout / Stopping / Climax) and time-of-day volume baseline. No change
//          to the density engine, value area, centre or calibration maths.
//   v2.1 — Every Edge figure now carries a Wilson 95% lower bound; the panel greens only when that bound
//          clears zero on an adequate sample. Point estimates are no longer coloured as evidence.
//
// HONESTY / LIMITATIONS
//   No tick/L2 tape is exposed to scripts, so density is built from OHLCV (and optional lower-timeframe
//   slices) — a proxy, not the true traded distribution. "Force" is a hypothesis the Edge stat exists
//   to falsify. The harness uses a light proxy of the field (the full grid can't run every bar), so it
//   tests the thesis, not the exact drawn object. Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NO recommendation, NO guarantee of results.
//   Indicators describe past behaviour; they do not predict the future. Trading carries risk of loss.
//   Test out-of-sample and make your own decisions. The author accepts no liability for any use.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Volume Force Field", "Force Fld", overlay = true, max_bars_back = 1000, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ── 01 · Data & source ─────────────────────────────────────────────────────────────────────
g0       = "01 · Data & source"
src      = input.source(hlc3,   "Price source",  group = g0, tooltip = "Series the density is built on. hlc3 is a bar's proxy traded price.")
volMode  = input.string("Auto", "Volume feed",   options = ["Auto","Force on","Force off (price-only)"], group = g0, tooltip = "Auto uses real volume when present and falls back to a price-density field when it isn't.")

// ── 02 · Intrabar precision ────────────────────────────────────────────────────────────────
g1       = "02 · Intrabar precision"
useLTF   = input.bool(true, "Use lower-timeframe slices", group = g1, tooltip = "Distributes each bar's volume across its real intrabar path for a sharper field. Lower-timeframe data is only available for recent bars; older bars fall back to bar price automatically.")
ltfMode  = input.string("Auto (finest available)", "Slice resolution", options = ["Auto (finest available)","1 tick","1 second","1 minute"], group = g1, tooltip = "Auto picks the finest broadly-available slice. Use 1 tick only where tick data is available on your plan.")

// ── 03 · Field (kernel density) ──────────────────────────────────────────────────────────
g2       = "03 · Field (kernel density)"
lookback = input.int(250, "Lookback (bars)", minval = 40, maxval = 1000, group = g2, tooltip = "How much history builds the field.")
bins     = input.int(100, "Grid resolution", minval = 20, maxval = 300,  group = g2, tooltip = "Number of price levels. Higher = finer; the grid is built on the last bar only.")
bwMult   = input.float(1.0,"Smoothing ×",     minval = 0.2, maxval = 4.0, step = 0.1, group = g2, tooltip = "Multiplies the auto bandwidth. Higher = smoother, fewer magnets.")
halfLife = input.int(0,   "Volume half-life (bars, 0 = flat)", minval = 0, maxval = 1000, group = g2, tooltip = "Bars over which a bar's volume weight halves. 0 = classic flat profile; >0 = a living field that favours recent volume.")

// ── 04 · Value centre & area ─────────────────────────────────────────────────────────────
g3       = "04 · Value centre & area"
ctrType  = input.string("Rolling VWAP","Value centre", options = ["Rolling VWAP","Adaptive MA","EMA"], group = g3, tooltip = "The moving equilibrium price is pulled toward.")
ctrLen   = input.int(100, "Centre length",     minval = 10, maxval = 1000, group = g3)
sigMult  = input.float(2.0,"Band width (× σ)",  minval = 0.5, maxval = 4.0, step = 0.5, group = g3)
vaPct    = input.float(70, "Value Area (% vol)", minval = 30, maxval = 95, step = 5, group = g3, tooltip = "Percentage of volume held inside the Value Area, grown outward from the POC.")

// ── 05 · Force & signals ─────────────────────────────────────────────────────────────────
g4       = "05 · Force & signals"
wVal     = input.float(0.6,"Value-gravity weight", minval = 0.0, maxval = 1.0, step = 0.05, group = g4)
wDrift   = input.float(0.4,"Drift weight",         minval = 0.0, maxval = 1.0, step = 0.05, group = g4)
fSmooth  = input.int(3,    "Force smoothing",      minval = 1,  maxval = 50,  group = g4)
memWin   = input.int(20,   "Recent-cluster window",minval = 3,  maxval = 200, group = g4, tooltip = "Window for the recent volume cluster used by the per-bar force proxy / harness.")
fGate    = input.float(0.55,"Strong-pull gate",    minval = 0.05, maxval = 0.95, step = 0.05, group = g4, tooltip = "Net force magnitude (0..1) above which a bar counts as a strong-pull signal. Higher = fewer, more selective signals.")
showSig  = input.bool(true,"Show past signal marks", group = g4, tooltip = "Marks every historical bar where the net pull turned strongly up or down.")

// ── 06 · Magnets & ridges ────────────────────────────────────────────────────────────────
g5       = "06 · Magnets & ridges"
nAttr    = input.int(3,    "Secondary magnets", minval = 0, maxval = 8, group = g5)
lvnFrac  = input.float(0.30,"Ridge threshold (× POC)", minval = 0.05, maxval = 0.8, step = 0.05, group = g5, tooltip = "A valley below this fraction of peak density is drawn as a low-volume ridge.")

// ── 07 · Calibration harness ─────────────────────────────────────────────────────────────
g6       = "07 · Calibration harness"
horizon  = input.int(10,   "Forward horizon (bars)", minval = 2, maxval = 100, group = g6)
kATR     = input.float(1.0,"Move threshold (× ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = g6)

// ── 08 · Field display ───────────────────────────────────────────────────────────────────
g7       = "08 · Field display"
showField= input.bool(true,"Show force field",   group = g7)
fldWidth = input.int(70,   "Field width (bars)",  minval = 10, maxval = 500, group = g7, tooltip = "How many bars back the field is drawn (density is still computed over the full lookback).")
fldOpac  = input.int(70,   "Field max opacity",   minval = 10, maxval = 95, group = g7)
rightExt = input.int(20,   "Project right (bars)",minval = 0,  maxval = 100, group = g7)
showCtr  = input.bool(true,"Show centre & band",  group = g7)
showBand = input.bool(false,"Fill σ band",        group = g7, tooltip = "Off by default — the fill can muddy dark themes. Centre and band lines still show.")
showVA   = input.bool(true,"Show Value Area",     group = g7)
showNode = input.bool(true,"Show POC / magnets / ridges", group = g7)

// ── 09 · Tables & theme ──────────────────────────────────────────────────────────────────
g8       = "09 · Tables & theme"
showGuide= input.bool(true, "Guidance panel (main)", group = g8, tooltip = "Plain-language read: bias, location vs value, nearest magnet, what to watch.")
showLvls = input.bool(false,"Key levels table",      group = g8, tooltip = "Prices of POC, Value Area, centre and bands.")
showStat = input.bool(false,"Calibration table",     group = g8, tooltip = "Signals, Hit %, Base %, Edge and settings.")
posGuide = input.string("Top right","Guidance position", options = ["Top right","Middle right","Bottom right","Top left","Bottom left"], group = g8)
posLvls  = input.string("Top left", "Levels position",   options = ["Top right","Middle right","Bottom right","Top left","Bottom left"], group = g8)
posStat  = input.string("Bottom right","Calibration position", options = ["Top right","Middle right","Bottom right","Top left","Bottom left"], group = g8)
theme    = input.string("Auto","Theme", options = ["Auto","Dark","Light"], group = g8)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                      PALETTE / THEME
// ═════════════════════════════════════════════════════════════════════════════════════════
GRN = #2ebd85
RED = #f6465d
YEL = #ffd600

f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
isLight  = theme == "Light" or (theme == "Auto" and f_luma(chart.bg_color) > 140)
txtCol   = isLight ? color.new(#0b0f14, 0)  : color.new(#e8edf2, 0)
mutCol   = isLight ? color.new(#5b6673, 0)  : color.new(#8b95a1, 0)
rowA     = isLight ? color.new(#f2f4f7, 0)  : color.new(#11161c, 0)
rowB     = isLight ? color.new(#e7ebf0, 0)  : color.new(#171d24, 0)
hdrCol   = isLight ? color.new(#d9dee5, 0)  : color.new(#0c1116, 0)
frameCol = isLight ? color.new(#c8cfd8, 0)  : color.new(#2a323c, 0)

f_pos(string s) => s == "Top right" ? position.top_right : s == "Middle right" ? position.middle_right : s == "Bottom right" ? position.bottom_right : s == "Top left" ? position.top_left : position.bottom_left
f_tanh(float x) =>
    xc = math.max(math.min(x, 10.0), -10.0)
    (2.0 / (1.0 + math.exp(-2.0 * xc))) - 1.0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                      CORE SERIES
// ═════════════════════════════════════════════════════════════════════════════════════════
useVol = volMode == "Force on" ? true : volMode == "Force off (price-only)" ? false : (not na(volume) and volume > 0)
vSafe  = useVol ? nz(volume, 0.0) : 1.0
atr    = ta.atr(14)

// value centre
f_ama(series float s, simple int len) =>
    er = math.abs(s - s[len]) / math.max(math.sum(math.abs(s - s[1]), len), 1e-9)
    sc = math.pow(er * (2.0 / 3.0 - 2.0 / 31.0) + 2.0 / 31.0, 2)
    var float a = na
    a := na(a[1]) ? s : a[1] + sc * (s - a[1])
    a
rollVwap = ta.sma(src * vSafe, ctrLen) / math.max(ta.sma(vSafe, ctrLen), 1e-9)
emaCtr   = ta.ema(src, ctrLen)   // hoisted: keep stateful calls out of ternaries
centre   = ctrType == "Rolling VWAP" ? rollVwap : ctrType == "Adaptive MA" ? f_ama(src, ctrLen) : emaCtr
sigma    = math.max(math.sqrt(ta.sma(math.pow(src - centre, 2.0), ctrLen)), atr * 0.1)
upper    = centre + sigMult * sigma
lower    = centre - sigMult * sigma

// per-bar force proxy (drives the harness / signals)
wS   = math.max(wVal + wDrift, 1e-9)
wVn  = wVal / wS
wDn  = wDrift / wS
aRec = ta.sma(src * vSafe, memWin) / math.max(ta.sma(vSafe, memWin), 1e-9)
fRaw = wVn * (aRec - close) / math.max(atr, 1e-9) + wDn * (centre - close) / math.max(atr, 1e-9)
fNet = f_tanh(ta.ema(fRaw, fSmooth))                 // net pull now, (-1..1): + up, - down

// ── Force acceleration (Wave E): is the pull INTENSIFYING or FADING? ─────────
// fAccel > 0 while fNet > 0 (or < 0 while fNet < 0) = the magnet's pull is building,
// price more likely to travel. Same magnitude but OPPOSITE-sign accel = the pull is
// fading — a strong attraction being absorbed into the level, the move may stall.
float fAccel  = fNet - nz(fNet[1])
float fAccelS = ta.ema(fAccel, fSmooth)              // ta.* unconditional
bool  pullBuilding = math.abs(fNet) >= fGate and fNet * fAccelS > 0.0
bool  pullFading   = math.abs(fNet) >= fGate and fNet * fAccelS < 0.0
var bool fadePrev = false
bool  fadeNew = pullFading and not fadePrev
fadePrev := pullFading

// lower-timeframe slices (recent bars only; empty on older bars → fallback)
ltfTF = ltfMode == "1 tick" ? "1T" : ltfMode == "1 second" ? "1S" : ltfMode == "1 minute" ? "1" : (timeframe.in_seconds() >= 3600 ? "1" : "1S")
arrC  = request.security_lower_tf(syminfo.tickerid, ltfTF, src)
arrV  = request.security_lower_tf(syminfo.tickerid, ltfTF, volume)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  CALIBRATION HARNESS
// ═════════════════════════════════════════════════════════════════════════════════════════
var int sigN = 0
var int hitN = 0
var int baseTot = 0
var int baseUp = 0
var int baseDn = 0
warm = bar_index > lookback + horizon + ctrLen
if warm and not na(close[horizon]) and not na(atr[horizon])
    thr   = kATR * atr[horizon]
    moved = close - close[horizon]
    baseTot += 1
    baseUp  += moved >=  thr ? 1 : 0
    baseDn  += -moved >= thr ? 1 : 0
    fPast = fNet[horizon]
    if not na(fPast) and math.abs(fPast) >= fGate
        sigN += 1
        hitN += (fPast > 0 and moved >= thr) or (fPast < 0 and -moved >= thr) ? 1 : 0
hitP  = sigN    > 0 ? hitN * 100.0 / sigN : na
baseP = baseTot > 0 ? (baseUp + baseDn) * 100.0 / (2.0 * baseTot) : na
edge  = (not na(hitP) and not na(baseP)) ? hitP - baseP : na

// WILSON 95% LOWER BOUND on the hit rate. The Edge above is a POINT ESTIMATE:
// on a small sample a +4 pt reading and pure noise are indistinguishable. The
// lower bound answers the question that actually matters - what is the WORST
// the hit rate plausibly is, given this many observations? Edge LB = the lower
// bound minus the base rate. Only a POSITIVE lower bound is evidence; a
// positive point estimate on its own is not.
f_wilsonLo(int hits, int n) =>
    float outv = na
    if n > 0
        float ph  = hits / float(n)
        float z   = 1.96
        float ctr = ph + z * z / (2.0 * n)
        float hlf = z * math.sqrt((ph * (1.0 - ph) + z * z / (4.0 * n)) / n)
        outv := math.max(0.0, (ctr - hlf) / (1.0 + z * z / n)) * 100.0
    outv
float edgeLo   = f_wilsonLo(hitN, sigN)
float edgeLB   = (not na(edgeLo) and not na(baseP)) ? edgeLo - baseP : na
bool  edgeProven = not na(edgeLB) and edgeLB > 0 and sigN >= 20


// ═════════════════════════════════════════════════════════════════════════════════════════
//                            FIELD ENGINE (histogram → Gaussian blur)
// ═════════════════════════════════════════════════════════════════════════════════════════
rngHi = ta.highest(high, lookback)
rngLo = ta.lowest(low,  lookback)
hAuto = 0.9 * ta.stdev(src, lookback) * math.pow(lookback, -0.2)

var array<box>   fBoxes = array.new<box>()
var array<line>  fLines = array.new<line>()
var array<label> fLabs  = array.new<label>()
var float pocP = na
var float vahP = na
var float valP = na
var string bias = "—"
var string tip = "—"
var string loc = "—"

f_clear() =>
    while array.size(fBoxes) > 0
        box.delete(array.pop(fBoxes))
    while array.size(fLines) > 0
        line.delete(array.pop(fLines))
    while array.size(fLabs) > 0
        label.delete(array.pop(fLabs))

if barstate.islast
    f_clear()
    int   lb   = int(math.min(lookback, bar_index))
    float rng  = math.max(rngHi - rngLo, syminfo.mintick)
    float binW = rng / bins
    float h    = math.max(hAuto * bwMult, binW * 0.75)
    int   span = int(math.max(math.ceil(3.0 * h / binW), 1))
    float lam  = halfLife > 0 ? math.log(2.0) / halfLife : 0.0

    // 1) raw volume-at-price histogram (O(1) per point; intrabar slices when available)
    raw = array.new<float>(bins, 0.0)
    for j = 0 to lb - 1
        float dcy  = lam > 0 ? math.exp(-lam * j) : 1.0
        array<float> ac = arrC[j]
        array<float> av = arrV[j]
        int nsub = useLTF ? array.size(ac) : 0
        if nsub > 0
            for m = 0 to nsub - 1
                float pm = array.get(ac, m)
                float vm = (useVol ? nz(array.get(av, m), 0.0) : 1.0) * dcy
                int bi = int((pm - rngLo) / binW)
                if bi >= 0 and bi < bins and vm > 0
                    array.set(raw, bi, array.get(raw, bi) + vm)
        else
            float pj = src[j]
            float wj = (useVol ? nz(volume[j], 0.0) : 1.0) * dcy
            int bi = int((pj - rngLo) / binW)
            if bi >= 0 and bi < bins and wj > 0
                array.set(raw, bi, array.get(raw, bi) + wj)

    // 2) Gaussian blur → KDE density
    gw = array.new<float>(2 * span + 1, 0.0)
    for k = -span to span
        array.set(gw, k + span, math.exp(-0.5 * math.pow(k * binW / h, 2)))
    gPrice = array.new<float>(bins, 0.0)
    gDens  = array.new<float>(bins, 0.0)
    float total = 0.0
    for i = 0 to bins - 1
        array.set(gPrice, i, rngLo + (i + 0.5) * binW)
        float s = 0.0
        for k = -span to span
            int ii = i + k
            if ii >= 0 and ii < bins
                s += array.get(raw, ii) * array.get(gw, k + span)
        array.set(gDens, i, s)
        total += s
    total := math.max(total, 1e-12)

    // 3) POC + Value Area (grow outward from POC to vaPct% of volume)
    float maxD = 0.0
    int   pocI = 0
    for i = 0 to bins - 1
        if array.get(gDens, i) > maxD
            maxD := array.get(gDens, i)
            pocI := i
    maxD := math.max(maxD, 1e-12)
    pocP := array.get(gPrice, pocI)
    float target = total * vaPct / 100.0
    float acc = array.get(gDens, pocI)
    int vaLo = pocI
    int vaHi = pocI
    while acc < target and (vaLo > 0 or vaHi < bins - 1)
        float dLo = vaLo > 0 ? array.get(gDens, vaLo - 1) : -1.0
        float dHi = vaHi < bins - 1 ? array.get(gDens, vaHi + 1) : -1.0
        if dHi >= dLo
            vaHi += 1
            acc += array.get(gDens, vaHi)
        else
            vaLo -= 1
            acc += array.get(gDens, vaLo)
    vahP := array.get(gPrice, vaHi)
    valP := array.get(gPrice, vaLo)

    int xL = bar_index - int(math.min(fldWidth, lookback))
    int xR = bar_index + rightExt

    // 4) Value Area shading
    if showVA
        array.push(fBoxes, box.new(xL, vahP, xR, valP, border_color = color.new(YEL, 70), bgcolor = color.new(YEL, 93), xloc = xloc.bar_index))

    // 5) force field bands (colour = local pull direction, opacity = density)
    if showField
        for i = 0 to bins - 1
            float dN = array.get(gDens, i) / maxD
            if dN > 0.04
                float gL   = i == 0 ? array.get(gDens, 1) - array.get(gDens, 0) : i == bins - 1 ? array.get(gDens, bins - 1) - array.get(gDens, bins - 2) : (array.get(gDens, i + 1) - array.get(gDens, i - 1)) / 2.0
                float fDrf = f_tanh((centre - array.get(gPrice, i)) / sigma)
                float fLoc = wVn * f_tanh(gL / (maxD * 0.2)) + wDn * fDrf
                color bc   = fLoc >= 0 ? GRN : RED
                int   tp   = int(math.max(100 - fldOpac * dN, 100 - fldOpac))
                array.push(fBoxes, box.new(xL, array.get(gPrice, i) + binW / 2.0, xR, array.get(gPrice, i) - binW / 2.0, border_color = color.new(bc, 100), bgcolor = color.new(bc, tp), xloc = xloc.bar_index))

    // 6) POC, secondary magnets, low-volume ridges
    if showNode
        array.push(fLines, line.new(xL, pocP, xR, pocP, xloc = xloc.bar_index, color = YEL, width = 2))
        array.push(fLabs,  label.new(xR, pocP, "POC", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(YEL, 15), textcolor = #0b0f14, size = size.small))
        idxArr = array.new<int>()
        valArr = array.new<float>()
        for i = 2 to bins - 3
            float d = array.get(gDens, i)
            if d > array.get(gDens, i - 1) and d > array.get(gDens, i + 1) and i != pocI and d / maxD > 0.15
                array.push(idxArr, i)
                array.push(valArr, d)
        int drawn = 0
        while drawn < nAttr and array.size(valArr) > 0
            int bi = array.indexof(valArr, array.max(valArr))
            if bi < 0
                break
            float ap = array.get(gPrice, array.get(idxArr, bi))
            array.push(fLines, line.new(xL, ap, xR, ap, xloc = xloc.bar_index, color = color.new(GRN, 25), width = 1))
            array.remove(valArr, bi)
            array.remove(idxArr, bi)
            drawn += 1
        for i = 2 to bins - 3
            float d = array.get(gDens, i) / maxD
            if d < array.get(gDens, i - 1) / maxD and d < array.get(gDens, i + 1) / maxD and d < lvnFrac
                float rp = array.get(gPrice, i)
                array.push(fLines, line.new(xL, rp, xR, rp, xloc = xloc.bar_index, color = color.new(RED, 55), width = 1, style = line.style_dashed))

    // 7) plain-language read
    bool pullUp = fNet > fGate
    bool pullDn = fNet < -fGate
    bool nearP  = math.abs(close - pocP) / math.max(atr, 1e-9) < 0.5
    bias := pullUp ? "▲ PULLING UP" : pullDn ? "▼ PULLING DOWN" : "■ BALANCED"
    loc  := close > vahP ? "Above value (stretched)" : close < valP ? "Below value (stretched)" : "Inside value"
    tip  := nearP and not pullUp and not pullDn ? "On a magnet — expect chop" : close > vahP and pullDn ? "Stretched high — pull back likely" : close < valP and pullUp ? "Below value — pull up likely" : pullUp ? "Drawn up to level above" : pullDn ? "Drawn down to level below" : "Balanced — no strong pull"

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          PLOTS (clean titles → usable from other scripts)
// ═════════════════════════════════════════════════════════════════════════════════════════
cCol = color.new(YEL, showCtr ? 0 : 100)
bCol = color.new(mutCol, showCtr ? 40 : 100)
pC = plot(centre, "Value Centre", color = cCol, linewidth = 2)
pU = plot(showCtr ? upper : na, "Upper Band", color = bCol)
pL = plot(showCtr ? lower : na, "Lower Band", color = bCol)
fill(pU, pL, color = color.new(YEL, showBand and showCtr ? 92 : 100), title = "Band fill")
plot(fNet, "Net Force", color = color.new(color.gray, 100), display = display.data_window)
plot(pocP, "POC",             color = color.new(color.gray, 100), display = display.data_window)
plot(vahP, "Value Area High", color = color.new(color.gray, 100), display = display.data_window)
plot(valP, "Value Area Low",  color = color.new(color.gray, 100), display = display.data_window)
plot(fAccelS, "EXP_ForceAccel", color = color.new(color.gray, 100), display = display.data_window)   // + pull building / − fading (signed vs fNet)

// past signal marks
longSig  = ta.crossover(fNet,  fGate)
shortSig = ta.crossunder(fNet, -fGate)
plotshape(showSig and longSig,  "Strong up pull",   shape.triangleup,   location.belowbar, color.new(GRN, 0), size = size.tiny)
plotshape(showSig and shortSig, "Strong down pull", shape.triangledown, location.abovebar, color.new(RED, 0), size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        TABLES
// ═════════════════════════════════════════════════════════════════════════════════════════
f_cell(table t, int c, int r, string s, color tc, color bg, string ha) =>
    table.cell(t, c, r, s, text_size = size.small, text_color = tc, text_halign = ha, bgcolor = bg)

// Guidance (main) — plain language
var table gT = table.new(f_pos(posGuide), 2, 7, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
if showGuide and barstate.islast
    color bCl  = fNet > fGate ? GRN : fNet < -fGate ? RED : mutCol
    float pocD = na(pocP) ? na : pocP - close
    string mag = na(pocP) ? "—" : str.tostring(pocP, format.mintick) + "  (" + str.tostring(pocD, "+0;-0") + ")"
    string barS= str.repeat("█", int(math.round(math.abs(fNet) * 8)))
    f_cell(gT, 0, 0, "VOLUME FORCE FIELD", txtCol, hdrCol, text.align_left)
    f_cell(gT, 1, 0, syminfo.ticker,       txtCol, hdrCol, text.align_right)
    f_cell(gT, 0, 1, "Bias",          mutCol, rowA, text.align_left)
    f_cell(gT, 1, 1, bias, bCl, rowA, text.align_right)
    f_cell(gT, 0, 2, "Strength",      mutCol, rowB, text.align_left)
    f_cell(gT, 1, 2, str.tostring(math.abs(fNet), "0.00") + " " + barS, bCl, rowB, text.align_right)
    f_cell(gT, 0, 3, "Location",      mutCol, rowA, text.align_left)
    f_cell(gT, 1, 3, loc, txtCol, rowA, text.align_right)
    f_cell(gT, 0, 4, "Nearest magnet",mutCol, rowB, text.align_left)
    f_cell(gT, 1, 4, mag, txtCol, rowB, text.align_right)
    f_cell(gT, 0, 5, "Watch",         mutCol, rowA, text.align_left)
    f_cell(gT, 1, 5, tip, txtCol, rowA, text.align_right)
    string pullTrTxt = pullBuilding ? "▲ building" : pullFading ? "▼ fading (absorbing)" : "• steady"
    color  pullTrCol = pullBuilding ? (fNet > 0 ? GRN : RED) : pullFading ? YEL : mutCol
    f_cell(gT, 0, 6, "Pull trend",    mutCol, rowB, text.align_left)
    f_cell(gT, 1, 6, pullTrTxt, pullTrCol, rowB, text.align_right)

// Key levels
var table lT = table.new(f_pos(posLvls), 2, 7, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
if showLvls and barstate.islast
    f_cell(lT, 0, 0, "KEY LEVELS", txtCol, hdrCol, text.align_left)
    f_cell(lT, 1, 0, syminfo.ticker, txtCol, hdrCol, text.align_right)
    f_cell(lT, 0, 1, "POC",         mutCol, rowA, text.align_left)
    f_cell(lT, 1, 1, na(pocP) ? "—" : str.tostring(pocP, format.mintick), YEL,   rowA, text.align_right)
    f_cell(lT, 0, 2, "Value High",  mutCol, rowB, text.align_left)
    f_cell(lT, 1, 2, na(vahP) ? "—" : str.tostring(vahP, format.mintick), txtCol, rowB, text.align_right)
    f_cell(lT, 0, 3, "Value Low",   mutCol, rowA, text.align_left)
    f_cell(lT, 1, 3, na(valP) ? "—" : str.tostring(valP, format.mintick), txtCol, rowA, text.align_right)
    f_cell(lT, 0, 4, "Centre",      mutCol, rowB, text.align_left)
    f_cell(lT, 1, 4, str.tostring(centre, format.mintick), txtCol, rowB, text.align_right)
    f_cell(lT, 0, 5, "Upper band",  mutCol, rowA, text.align_left)
    f_cell(lT, 1, 5, str.tostring(upper, format.mintick), mutCol, rowA, text.align_right)
    f_cell(lT, 0, 6, "Lower band",  mutCol, rowB, text.align_left)
    f_cell(lT, 1, 6, str.tostring(lower, format.mintick), mutCol, rowB, text.align_right)

// Calibration
var table sT = table.new(f_pos(posStat), 2, 6, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
if showStat and barstate.islast
    color eCol = na(edge) ? mutCol : edgeProven ? GRN : edgeLB < -3 ? RED : mutCol
    f_cell(sT, 0, 0, "CALIBRATION", txtCol, hdrCol, text.align_left)
    f_cell(sT, 1, 0, "tested", txtCol, hdrCol, text.align_right)
    f_cell(sT, 0, 1, "Signals (n)", mutCol, rowA, text.align_left)
    f_cell(sT, 1, 1, str.tostring(sigN), txtCol, rowA, text.align_right)
    f_cell(sT, 0, 2, "Hit %",  mutCol, rowB, text.align_left)
    f_cell(sT, 1, 2, sigN < 20 ? "warming…" : str.tostring(hitP, "0") + "%", sigN < 20 ? mutCol : txtCol, rowB, text.align_right)
    f_cell(sT, 0, 3, "Base %", mutCol, rowA, text.align_left)
    f_cell(sT, 1, 3, baseTot < 20 ? "warming…" : str.tostring(baseP, "0") + "%", mutCol, rowA, text.align_right)
    f_cell(sT, 0, 4, "Edge",   mutCol, rowB, text.align_left)
    f_cell(sT, 1, 4, sigN < 20 ? "warming…" : str.tostring(edge, "+0.0;-0.0") + " / LB " + str.tostring(edgeLB, "+0.0;-0.0") + " (n" + str.tostring(sigN) + ")", eCol, rowB, text.align_right)
    f_cell(sT, 0, 5, "Horizon / gate", mutCol, rowA, text.align_left)
    f_cell(sT, 1, 5, str.tostring(horizon) + "b / " + str.tostring(fGate, "0.00"), mutCol, rowA, text.align_right)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(longSig,  "Strong upward pull",   "Force Field: net pull turned strongly UP toward a magnet above.")
alertcondition(shortSig, "Strong downward pull", "Force Field: net pull turned strongly DOWN toward a magnet below.")
alertcondition(ta.cross(fNet, 0), "Pull flip",   "Force Field: net force flipped direction.")
// Wave E — force acceleration & absorption
alertcondition(ta.crossover(fAccelS, 0.0),  "Pull accelerating up",   "Force Field: upward pull is intensifying — attraction to the magnet above is building.")
alertcondition(ta.crossunder(fAccelS, 0.0), "Pull accelerating down", "Force Field: downward pull is intensifying — attraction to the magnet below is building.")
alertcondition(fadeNew, "Pull fading (absorption)", "Force Field: a strong pull is weakening into the magnet — attraction being absorbed, the move may stall.")

// ═══════════════════════════════════════════════════════════════════════════════
// VSA BAR EVENTS (Wave D · U9 — ml_vsa taxonomy, inlined) + U11 time-of-day volume — OPTIONAL.
//   This pane is plot-dense, so VSA is exposed via ALERTS ONLY (no marker/export plots). Names the
//   dominant Wyckoff/VSA effort-vs-result event; all ta.* unconditional; engine/dashboard untouched.
// ═══════════════════════════════════════════════════════════════════════════════
gVSA_wd   = "VSA bar events (Wave D)"
vsaLen    = input.int(50, "VSA history window", minval = 10, maxval = 300, group = gVSA_wd, tooltip = "Named Wyckoff/VSA events (Upthrust / Shakeout / Stopping Volume / Climax) available as alertconditions.")
vsaPiv    = input.int(5,  "New-extreme lookback", minval = 2, maxval = 50, group = gVSA_wd)
vsaTod    = input.bool(false, "Time-of-day volume (U11)", group = gVSA_wd, tooltip = "ON: judge volume against the same time-of-day slot on prior sessions (ml_session baseline, inlined). Default off.")
vsaTodMin = input.int(5,  "  Slot size (minutes)", minval = 1, maxval = 60, group = gVSA_wd)
vsaTodSes = input.int(20, "  Session memory", minval = 3, maxval = 200, group = gVSA_wd)
bool  vsaHasVol = not na(volume) and volume > 0
int   vsaNSlots = math.max(1, int(math.ceil(1440.0 / math.max(vsaTodMin, 1))))
float vsaTodA   = 2.0 / (math.max(vsaTodSes, 1) + 1.0)
int   vsaSlot   = vsaTodMin > 0 ? int((hour * 60 + minute) / vsaTodMin) : 0
var array<float> vsaSlotVol = array.new<float>(vsaNSlots, na)
int   vsaSlotI  = (vsaSlot >= 0 and vsaSlot < vsaNSlots) ? vsaSlot : 0
float vsaSlotPv = array.get(vsaSlotVol, vsaSlotI)
float vsaSlotCv = na(volume) ? vsaSlotPv : na(vsaSlotPv) ? volume : vsaSlotPv + vsaTodA * (volume - vsaSlotPv)
array.set(vsaSlotVol, vsaSlotI, vsaSlotCv)
float vsaVolRatio = (not na(vsaSlotCv) and vsaSlotCv > 0.0) ? volume / vsaSlotCv : 1.0
float vsaVolUse   = vsaTod ? vsaVolRatio : volume
float vsaSp   = ta.percentrank(high - low, vsaLen)
float vsaVp   = ta.percentrank(vsaVolUse,  vsaLen)
float vsaVpk  = ta.highest(vsaVolUse, vsaLen)
float vsaRngX = high - low
float vsaCp   = vsaRngX > 0.0 ? (close - low) / vsaRngX : 0.5
float vsaPHi  = ta.highest(high, vsaPiv)[1]
float vsaPLo  = ta.lowest(low,  vsaPiv)[1]
bool  vsaUpB  = close > close[1]
bool  vsaDnB  = close < close[1]
bool  vUpthrust = vsaHasVol and (high >= vsaPHi) and vsaCp <= 0.35 and vsaVp >= 60.0
bool  vShakeout = vsaHasVol and (low  <= vsaPLo) and vsaCp >= 0.65 and vsaVp >= 60.0
bool  vStopping = vsaHasVol and vsaDnB and vsaSp >= 60.0 and vsaVp >= 80.0 and vsaCp >= 0.45
bool  vClimaxUp = vsaHasVol and vsaUpB and vsaVolUse >= vsaVpk and vsaSp >= 70.0
bool  vClimaxDn = vsaHasVol and vsaDnB and vsaVolUse >= vsaVpk and vsaSp >= 70.0
alertcondition(vUpthrust,  "VSA Upthrust",        "Upthrust - new high rejected on volume (bearish trap).")
alertcondition(vShakeout,  "VSA Shakeout",        "Shakeout - new low reclaimed on volume (bullish trap).")
alertcondition(vStopping,  "VSA Stopping Volume", "Stopping Volume - wide down-bar closing off the low (bullish).")
alertcondition(vClimaxUp,  "VSA Buying climax",   "Buying climax - peak-volume wide up-bar (bearish exhaustion).")
alertcondition(vClimaxDn,  "VSA Selling climax",  "Selling climax - peak-volume wide down-bar (bullish exhaustion).")
````
