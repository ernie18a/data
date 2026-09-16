<!-- tradingview-pine-id: PUB;39de7523f93241adb3493b510ee45056 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Daily Levels + Score

Source: https://www.tradingview.com/script/cbnRgPOO/

## Description

# Daily Levels + Score (DHL×2)

---

## WHAT IT DOES

Most support/resistance scripts draw every level they find and leave you to guess which ones matter. DHL×2 finds the daily highs and lows that cluster together, draws them on your intraday chart, and then **grades each level with a statistical effectiveness score** based on how price actually reacted to it — evaluated strictly out-of-sample, so a level never "confirms itself". It also maps the current premium/discount context of the range with a time-at-price profile (POC / VAH / VAL).

## HOW IT WORKS

**1. Level detection — density clustering (KDE).**
Daily highs and lows over the lookback window are grouped with a kernel density estimate (triangular kernel, bandwidth = tolerance). Levels are the peaks of that density, so the result does not depend on the order in which candles are scanned, unlike the usual greedy grouping. Each touch is weighted by recency, and the final level is the weighted average of its touches. Tolerance adapts to volatility: Parkinson (default, converges faster after regime changes) or ATR.

**2. No self-confirmation bias.**
The touches that *form* a cluster do not count as tests. A cluster is "born" once it gathers the minimum number of touches; everything after that candle is out-of-sample evaluation. This is the key difference from scripts that count the same touches twice — once to build the level and again to "prove" it works.

**3. Effectiveness score.**
From its birth onward, every approach to the level is classified as respected or broken (consecutive candles in the zone count as one event). Three score modes:
- **Wilson 95%** — lower bound of the confidence interval; small samples are pushed toward 0 instead of showing a misleading "100% (2/2)".
- **Bayes (shrinkage)** — empirical Bayes: each level's score is pulled toward the base rate of all levels on the chart, with a configurable prior strength.
- **Raw %** — no correction, for comparison.

On top of that:
- **Time decay** — a respect from 30 days ago weighs less than yesterday's (configurable half-life).
- **Liquidity-consumption penalty** — consecutive respected tests progressively weaken the score, mimicking how resting orders get consumed at a real level.
- **Bounce magnitude (MFE)** — the average favorable excursion after each respect, expressed in daily-volatility multiples (σ), shown next to the score.

**4. Confluence.**
Round numbers (●, step configurable: e.g. 100 for NQ, 25 for ES) and proximity to the range equilibrium (◆) add a score bonus.

**5. Premium / Discount + time-at-price profile.**
The selected range (previous day, last N days, or full lookback) is split with fib lines (0 / 25 / 50 / 75 / 100) and an equilibrium line. A TPO-style **time-at-price profile** (no volume needed) is built from chart-resolution bars inside the range and plots the **POC, VAH and VAL**. When the POC sits meaningfully away from the geometric equilibrium (threshold as % of the range), the status label flags the imbalance with its direction: **POC>EQ** (p-shaped, value built in premium) or **POC<EQ** (b-shaped, value built in discount).

**6. Ranking table.**
Every level — including the EQ — is ranked in a table with its type, role (S / R / S+R / broken), respected/total tests, score, average bounce in σ, and distance to price. Sort by score or by proximity.

## HOW TO READ IT

- Line color intensity follows the score (configurable gradient); distant levels fade out so the chart stays clean near price.
- Labels show price, score and the average bounce (e.g. `23150  62% ~1.4σ`), plus ● / ◆ confluence marks.
- Status label: PREMIUM/DISCOUNT %, range direction, and the POC≠EQ flag when the profile is out of balance.
- A level with a high score, several out-of-sample respects and a decent σ bounce is a meaningful reaction zone; a level marked ✕ has been traded through and is better read as a target/liquidity draw than as support or resistance.

## SETTINGS WORTH KNOWING

- **Score mode + gradient:** with Wilson use floor 10 / ceiling 55; with Bayes ~40/70; with Raw % ~40/90.
- **Round number step:** 100 for NQ/MNQ, 25 for ES/MES.
- **POC≠EQ threshold:** default 10% of the range; raise it if the flag fires too often on your instrument.
- Designed for intraday charts (1m–30m) reading daily levels; works on any symbol with daily data.

## ORIGINALITY

What sets this apart from typical S/R scripts: order-independent KDE clustering, strict out-of-sample scoring (no self-confirmation), Wilson/empirical-Bayes correction for small samples, time decay and liquidity-consumption penalty, Parkinson volatility, bounce magnitude in σ, and a volume-free time-at-price profile with a directional POC-vs-EQ imbalance flag.

## DISCLAIMER

For educational purposes only. The score measures how the level behaved in the past; it is not a prediction and not financial advice. Always manage your risk.

---

## Source Code

````pine
//@version=6
// Daily Levels v2.1 — "the works":
//  1) Self-confirmation bias fix: the touches that FORM a cluster don't count as tests.
//     The cluster is "born" once it gathers minTouch touches; everything after is out-of-sample evaluation.
//  2) Magnitude-aware score: besides the respect rate, the average bounce (MFE) is measured in volatility multiples.
//  3) Score modes: Wilson 95% / empirical Bayes (shrinkage toward the base rate) / raw %.
//  4) Time decay of tests (half-life) + liquidity-consumption penalty
//     (consecutive respected tests weaken the level, like a real order book).
//  5) Parkinson volatility as an alternative to ATR for tolerance, fade and normalization.
//  6) Density clustering (KDE with triangular kernel): levels are density peaks,
//     not the output of an order-dependent greedy pass.
//  7) Confluence: round numbers (●) and proximity to EQ (◆) add a score bonus.
//  8) Premium/Discount: geometric fib + time-at-price profile (POC / VAH / VAL, TPO-style).
//
//  v2.1 changes:
//  a) The time-at-price profile is now built from chart-resolution bars inside the range window
//     (true time-at-price), instead of assuming a uniform distribution inside each daily H-L range.
//     Falls back to daily H/L when no chart bars cover the window (e.g. on a Daily chart).
//  b) POC≠EQ is flagged with a threshold relative to the range size (not the level tolerance),
//     and the status label now shows the direction: POC>EQ (p-shaped) or POC<EQ (b-shaped).
indicator("Daily Levels + Score", "DHL×2", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 100)

// ═══════════ Inputs ═══════════
lookback  = input.int(42, "Daily candles to analyze", minval = 2, maxval = 250)
minTouch  = input.int(2, "Minimum touches to form a level", minval = 2)
inclToday = input.bool(true, "Include current daily candle")

grpT = "Tolerance & volatility"
volMode  = input.string("Parkinson", "Volatility measure", options = ["Parkinson", "ATR"], tooltip = "Parkinson uses ln(H/L)² and converges ~5x faster than ATR after regime changes. Used for the tolerance, the fade and to normalize the bounce (σ).", group = grpT)
useATRtol = input.bool(true, "Volatility-based tolerance", group = grpT)
atrMult  = input.float(0.10, "Volatility multiplier", step = 0.05, minval = 0.01, group = grpT)
tolTicks = input.float(20, "Tolerance in ticks (if not using volatility)", minval = 0, group = grpT)

grpM = "Mitigation"
hideMitig = input.bool(true, "Hide mitigated H/L clusters", tooltip = "A cluster is mitigated once a later daily close trades through it.", group = grpM)

grpF = "Proximity fade"
useFade  = input.bool(true, "Fade distant levels", group = grpF)
fadeATR  = input.float(1.5, "Fade distance (daily σ)", step = 0.25, minval = 0.1, group = grpF)
nearT    = input.int(0,  "Transparency when near", minval = 0, maxval = 100, group = grpF)
farT     = input.int(88, "Transparency when far", minval = 0, maxval = 100, group = grpF)
fadeCurve = input.float(1.6, "Fade curve", step = 0.1, minval = 0.2, maxval = 4, group = grpF)

grpS = "Effectiveness"
scoreMode = input.string("Wilson 95%", "Score mode", options = ["Wilson 95%", "Bayes (shrinkage)", "Raw %"], tooltip = "Wilson: lower bound of the confidence interval, pushes small samples toward 0.\nBayes: pulls the score toward the base rate of ALL levels on the chart (empirical Bayes). A 2/2 doesn't give 100% or 34%: it lands near the mean, nudged slightly up.\nRaw %: no correction.", group = grpS)
priorK    = input.float(5, "Prior strength (Bayes)", minval = 1, maxval = 20, step = 1, tooltip = "Equivalent to how many 'imaginary' tests at the base rate are added to each level. Higher = more shrinkage.", group = grpS)
useDecay  = input.bool(true, "Time decay of tests", tooltip = "A respect from 30 days ago weighs less than yesterday's.", group = grpS)
halfLife  = input.int(14, "Half-life (days)", minval = 2, maxval = 120, group = grpS)
liqPenal  = input.bool(true, "Penalize liquidity consumption", tooltip = "Each respected test consumes the orders defending the level. From the N-th consecutive respect on, the score is multiplied by the factor.", group = grpS)
penFree   = input.int(3, "Free tests before penalty", minval = 1, maxval = 10, group = grpS)
penFactor = input.float(0.93, "Factor per extra test", minval = 0.5, maxval = 1.0, step = 0.01, group = grpS)
mfeHor    = input.int(10, "Bounce horizon (daily candles)", minval = 2, maxval = 30, tooltip = "How many candles are inspected after a respect to measure the bounce (MFE). Cut short if price re-touches the level.", group = grpS)
minScore  = input.float(0, "Hide levels with score below (%)", minval = 0, maxval = 100, step = 5, tooltip = "Only affects levels with at least one test. Levels without history are always shown.", group = grpS)
colorByScore = input.bool(true, "Color by effectiveness", group = grpS)
gradLo    = input.float(10, "Gradient: floor (%)", minval = 0, maxval = 100, step = 5, tooltip = "With Wilson use 10; with Bayes ~40 (scores gravitate around the base rate); with Raw %, 40.", group = grpS)
gradHi    = input.float(55, "Gradient: ceiling (%)", minval = 0, maxval = 100, step = 5, tooltip = "With Wilson 55; with Bayes ~70; with Raw % 90.", group = grpS)

grpC = "Confluence"
useRound  = input.bool(true, "Round number bonus (●)", group = grpC)
roundStep = input.float(100, "Round number step", minval = 0, tooltip = "NQ/MNQ: 100 (where strikes and stops live). ES/MES: 25. Marks ● and adds the bonus if the level sits within one tolerance of the multiple.", group = grpC)
useEQconf = input.bool(true, "EQ confluence bonus (◆)", group = grpC)
confBonus = input.float(8, "Confluence bonus (%)", minval = 0, maxval = 25, step = 1, group = grpC)

grpPD = "Premium / Discount"
usePD    = input.bool(true, "Show Premium / Discount", group = grpPD)
pdMode   = input.string("Last N days", "Range to measure", options = ["Full lookback", "Last N days", "Previous day"], group = grpPD)
pdDays   = input.int(5, "N days (for 'Last N days')", minval = 2, maxval = 60, group = grpPD)
showEQ   = input.bool(true, "Equilibrium line (50%)", group = grpPD)
eqSty    = input.string("Solid", "EQ line style", options = ["Solid", "Dotted", "Dashed"], group = grpPD)
eqW      = input.int(2, "EQ line width", minval = 1, maxval = 4, group = grpPD)
showZones = input.bool(true, "Shade zones", group = grpPD)
pdStyle  = input.string("Extremes only (fib)", "Zone style", options = ["Extremes only (fib)", "Full halves"], group = grpPD)
pdExt    = input.float(25, "Extreme threshold (%)", minval = 5, maxval = 50, step = 5, group = grpPD)
showFib  = input.bool(true, "Level lines (0 / 25 / 50 / 75 / 100)", group = grpPD)
fibW     = input.int(2, "Fib line width", minval = 1, maxval = 4, group = grpPD)
showFibLbl = input.bool(true, "Right-side % labels", group = grpPD)
colFib   = input.color(color.new(color.gray, 20), "Mid-line color", group = grpPD)
showPDLbl = input.bool(true, "Status label (PREMIUM / DISCOUNT)", group = grpPD)
colPrem  = input.color(color.new(#e91e63, 92), "Premium color", group = grpPD)
colDisc  = input.color(color.new(#089981, 92), "Discount color", group = grpPD)
colEQ    = input.color(color.new(#ff9800, 0), "Equilibrium color", group = grpPD)

grpTPO = "Time-at-price profile (POC / VAH / VAL)"
showTPO  = input.bool(true, "Show POC & Value Area", tooltip = "Time-at-price histogram over the same range as the premium/discount (TPO-style, no volume), built from chart-resolution bars for true time-at-price (falls back to daily H/L on a Daily chart). The POC is where price spent the most time. If POC ≠ EQ the market is out of balance and the direction is flagged in the status label.", group = grpTPO)
vaPct    = input.float(70, "Value Area (%)", minval = 50, maxval = 95, step = 5, group = grpTPO)
pocGapPct = input.float(10, "POC≠EQ threshold (% of range)", minval = 1, maxval = 50, step = 1, tooltip = "The imbalance flag fires when |POC − EQ| exceeds this fraction of the range. Relative to the range (not the level tolerance) so it isn't triggered by the profile's own bin resolution.", group = grpTPO)
colPOC   = input.color(color.new(#ffee58, 0), "POC color", group = grpTPO)

grpTb = "Ranking table"
showTbl  = input.bool(true, "Show table", group = grpTb)
tblSort  = input.string("Distance to price", "Sort by", options = ["Score", "Distance to price"], group = grpTb)
tblRows  = input.int(10, "Max rows", minval = 1, maxval = 25, group = grpTb)
tblPos   = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = grpTb)
tblSize  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpTb)
tblBg    = input.color(color.new(color.black, 20), "Background", group = grpTb)

grpV = "Visual"
lblMode  = input.string("Price + %", "Label content", options = ["Price", "Price + %", "Full", "None"], group = grpV)
lblStyle = input.string("Minimal", "Label style", options = ["Minimal", "Chip"], group = grpV)
lblOff   = input.int(4, "Label offset (bars)", minval = 0, maxval = 60, group = grpV)
extRight = input.bool(true, "Extend lines to the right", group = grpV)
colH     = input.color(color.new(color.red, 0), "Highs color", group = grpV)
colL     = input.color(color.new(color.teal, 0), "Lows color", group = grpV)
lw       = input.int(1, "Width", minval = 1, maxval = 4, group = grpV)
styIn    = input.string("Solid", "Line style", options = ["Solid", "Dotted", "Dashed"], group = grpV)

toSty(s) => s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed
lSty  = toSty(styIn)
eSty  = toSty(eqSty)
tPos  = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom left" ? position.bottom_left : position.middle_right
tSz   = tblSize == "Tiny" ? size.tiny : tblSize == "Small" ? size.small : size.normal

// ═══════════ Daily data ═══════════
getDaily(n) =>
    hs = array.new_float()
    ls = array.new_float()
    cs = array.new_float()
    ts = array.new_int()
    cnt = math.min(n, bar_index + 1)
    for i = 0 to cnt - 1
        array.push(hs, high[i])
        array.push(ls, low[i])
        array.push(cs, close[i])
        array.push(ts, time[i])
    // Parkinson: sigma² = mean(ln(H/L)²) / (4·ln2). Converted to price with the close.
    park = close * math.sqrt(ta.sma(math.pow(math.log(high / low), 2), 14) / (4.0 * math.log(2)))
    [hs, ls, cs, ts, ta.atr(14), park]

// index 0 = most recent daily candle
[dH, dL, dC, dT, dATR, dPark] = request.security(syminfo.tickerid, "D", getDaily(lookback + 1), lookahead = barmerge.lookahead_off)

volD = volMode == "Parkinson" and not na(dPark) and dPark > 0 ? dPark : dATR

// ═══════════ Chart-resolution bars (for the time-at-price profile) ═══════════
// Every chart bar is stored so the profile can be built at chart resolution:
// each bar contributes 1 unit of time spread across the bins its H-L covers.
// On a Daily chart this degenerates into the daily H/L fallback (same data).
var ibH = array.new_float()
var ibL = array.new_float()
var ibT = array.new_int()
array.push(ibH, high)
array.push(ibL, low)
array.push(ibT, time)

// ═══════════ Storage ═══════════
var lns = array.new_line()
var lbs = array.new_label()
var bxs = array.new_box()

// candidates (pass 1: gather; pass 2: stats; pass 3: score + draw)
var cLvl  = array.new_float()
var cTim  = array.new_int()
var cEval = array.new_int()
var cCol  = array.new_color()
var cTag  = array.new_string()
var cIsEQ = array.new_bool()
var cWdt  = array.new_int()
var cLbl  = array.new_bool()

// per-candidate stats
var sT   = array.new_int()      // tests (events)
var sS   = array.new_int()      // respects as support
var sR   = array.new_int()      // respects as resistance
var sWT  = array.new_float()    // decay-weighted tests
var sWR  = array.new_float()    // decay-weighted respects
var sPen = array.new_float()    // liquidity-consumption multiplier
var sMFE = array.new_float()    // average bounce in price (na if none)

// ranking (for the table)
var rLvl   = array.new_float()
var rScore = array.new_float()
var rTests = array.new_int()
var rResp  = array.new_int()
var rTag   = array.new_string()
var rRole  = array.new_string()
var rCol   = array.new_color()
var rMFE   = array.new_float()

// ═══════════ Helpers ═══════════
decayW(k) => useDecay ? math.pow(0.5, k / math.max(1, halfLife)) : 1.0

// Lower bound of the Wilson 95% confidence interval. Accepts fractional (weighted) counts.
wilsonLB(k, n) =>
    float res = 0.0
    if n > 0
        z = 1.96
        p = k / n
        d = 1.0 + z * z / n
        c = p + z * z / (2.0 * n)
        m = z * math.sqrt(math.max(0.0, (p * (1.0 - p) + z * z / (4.0 * n)) / n))
        res := math.max(0.0, (c - m) / d) * 100.0
    res

// Empirical Bayes: shrinkage toward the global base rate with priorK equivalent tests.
bayesScore(wr, wt, base) => (wr + priorK * base) / (wt + priorK) * 100.0

roleTxt(tests, respS, respR) =>
    respS > 0 and respR > 0 ? "S+R" : respR > 0 ? "R" : respS > 0 ? "S" : tests > 0 ? "✕" : "—"

isRound(lvl, tol) => useRound and roundStep > 0 and math.abs(lvl - math.round(lvl / roundStep) * roundStep) <= tol

fade(c, lvl) =>
    color res = c
    if useFade and not na(volD) and volD > 0
        d = math.abs(lvl - close)
        r = math.min(1.0, d / (fadeATR * volD))
        r := math.pow(r, fadeCurve)
        res := color.new(c, math.round(nearT + (farT - nearT) * r))
    res

mute(c) => color.from_gradient(0.5, 0, 1, color.new(color.gray, 0), c)

scoreCol(baseCol, sc, tests) =>
    colorByScore and tests > 0 ? color.from_gradient(sc, gradLo, gradHi, mute(baseCol), baseCol) : baseCol

addCand(lvl, t, ev, colr, tag, isEQ, wdt, wantLbl) =>
    array.push(cLvl, lvl)
    array.push(cTim, t)
    array.push(cEval, ev)
    array.push(cCol, colr)
    array.push(cTag, tag)
    array.push(cIsEQ, isEQ)
    array.push(cWdt, wdt)
    array.push(cLbl, wantLbl)

// ═══════════ Out-of-sample statistics ═══════════
// Evaluates the level ONLY from evalStart (the candle after the cluster's birth) to today.
// The touches that formed the cluster don't count: no self-confirmation.
// side = +1 -> came from above (support) · side = -1 -> came from below (resistance).
// Consecutive candles touching the zone = a single event. Each event weighs decayW(age).
// After each respect the MFE is measured: favorable excursion until a re-touch or mfeHor candles.
levelStats2(highs, lows, closes, lvl, tol, evalStart) =>
    int nT = 0
    int nS = 0
    int nRr = 0
    float wT = 0.0
    float wR = 0.0
    float penM = 1.0
    int consec = 0
    float mfeSum = 0.0
    int mfeN = 0
    bool inTest = false
    bool broken = false
    int side = 0
    float evW = 1.0
    nBars = array.size(closes)
    if evalStart >= 0
        for k = evalStart to 0
            h = array.get(highs, k)
            l = array.get(lows, k)
            c = array.get(closes, k)
            touch = h >= lvl - tol and l <= lvl + tol
            if touch
                if not inTest
                    inTest := true
                    broken := false
                    evW := decayW(k)
                    nT += 1
                    wT += evW
                    prevC = k < nBars - 1 ? array.get(closes, k + 1) : c
                    side := prevC >= lvl ? 1 : -1
                if (side == 1 and c < lvl - tol) or (side == -1 and c > lvl + tol)
                    broken := true
            else if inTest
                if not broken
                    wR += evW
                    if side == 1
                        nS += 1
                    else
                        nRr += 1
                    consec += 1
                    if liqPenal and consec > penFree
                        penM *= penFactor
                    // MFE from the first post-event candle until a re-touch or mfeHor candles
                    float ext = 0.0
                    stopJ = math.max(0, k - mfeHor + 1)
                    for j = k to stopJ
                        hj = array.get(highs, j)
                        lj = array.get(lows, j)
                        if j != k and hj >= lvl - tol and lj <= lvl + tol
                            break
                        ext := side == 1 ? math.max(ext, hj - lvl) : math.max(ext, lvl - lj)
                    mfeSum += ext
                    mfeN += 1
                else
                    consec := 0
                inTest := false
        if inTest and not broken
            // event still open as of today: counts as a respect, no MFE (in progress)
            wR += evW
            if side == 1
                nS += 1
            else
                nRr += 1
    [nT, nS, nRr, wT, wR, penM, mfeN > 0 ? mfeSum / mfeN : float(na)]

// ═══════════ Density clustering (KDE) ═══════════
// Histogram of H (or L) weighted by recency, triangular kernel of width = tolerance.
// Density peaks are the levels: order-independent.
// The level is the weighted average of the touches assigned to the peak.
clusterSide(levels, closes, times, tol, isHigh, start) =>
    n = array.size(levels)
    endIdx = math.min(start + lookback - 1, n - 1)
    if endIdx > start and tol > 0
        float lo = array.get(levels, start)
        float hi = lo
        for i = start to endIdx
            v = array.get(levels, i)
            lo := math.min(lo, v)
            hi := math.max(hi, v)
        bw = math.max(tol / 2.0, syminfo.mintick)
        nb = int(math.min(500, math.floor((hi - lo) / bw) + 3))
        if nb >= 3
            dens = array.new_float(nb, 0.0)
            for i = start to endIdx
                v = array.get(levels, i)
                w = decayW(i)
                b0 = math.max(0, int(math.floor((v - tol - lo) / bw)))
                b1 = math.min(nb - 1, int(math.floor((v + tol - lo) / bw)))
                for b = b0 to b1
                    x = lo + b * bw
                    kk = 1.0 - math.abs(x - v) / tol
                    if kk > 0
                        array.set(dens, b, array.get(dens, b) + w * kk)
            // local density peaks
            pkB = array.new_int()
            pkD = array.new_float()
            for b = 1 to nb - 2
                d0 = array.get(dens, b)
                if d0 > 0 and d0 > array.get(dens, b - 1) and d0 >= array.get(dens, b + 1)
                    array.push(pkB, b)
                    array.push(pkD, d0)
            if array.size(pkB) > 0
                ordP = array.sort_indices(pkD, order.descending)
                usedPt = array.new_bool(n, false)
                for p in ordP
                    center = lo + array.get(pkB, p) * bw
                    mem = array.new_int()          // members, ascending index order (new -> old)
                    float sw = 0.0
                    float swv = 0.0
                    for i = start to endIdx
                        if not array.get(usedPt, i)
                            v = array.get(levels, i)
                            if math.abs(v - center) <= tol
                                array.push(mem, i)
                                w = decayW(i)
                                sw += w
                                swv += w * v
                    cnt = array.size(mem)
                    if cnt >= minTouch
                        for i in mem
                            array.set(usedPt, i, true)
                        lvl = swv / sw
                        newest = array.get(mem, 0)
                        oldest = array.get(mem, cnt - 1)
                        mitig = false
                        if newest > 0
                            for k = 0 to newest - 1
                                c = array.get(closes, k)
                                if (isHigh and c > lvl + tol) or (not isHigh and c < lvl - tol)
                                    mitig := true
                                    break
                        if not (mitig and hideMitig)
                            // cluster birth = its minTouch-th oldest touch.
                            // Evaluation starts on the next candle (out-of-sample).
                            birth = array.get(mem, cnt - minTouch)
                            addCand(lvl, array.get(times, oldest), birth - 1, isHigh ? colH : colL, (isHigh ? "H×" : "L×") + str.tostring(cnt), false, lw, true)

// ═══════════ Table ═══════════
var table tbl = table.new(tPos, 7, 26, bgcolor = tblBg, border_width = 1, border_color = color.new(color.gray, 70))

// ═══════════ Execution ═══════════
if barstate.islast and not na(volD)
    for l in lns
        line.delete(l)
    array.clear(lns)
    for b in lbs
        label.delete(b)
    array.clear(lbs)
    for bx in bxs
        box.delete(bx)
    array.clear(bxs)
    array.clear(cLvl), array.clear(cTim), array.clear(cEval), array.clear(cCol)
    array.clear(cTag), array.clear(cIsEQ), array.clear(cWdt), array.clear(cLbl)
    array.clear(sT), array.clear(sS), array.clear(sR)
    array.clear(sWT), array.clear(sWR), array.clear(sPen), array.clear(sMFE)
    array.clear(rLvl), array.clear(rScore), array.clear(rTests), array.clear(rResp)
    array.clear(rTag), array.clear(rRole), array.clear(rCol), array.clear(rMFE)

    tol = useATRtol ? volD * atrMult : tolTicks * syminfo.mintick
    start = inclToday ? 0 : 1

    // ── Premium / Discount: range, EQ and time-at-price profile ──
    float eqLvl = na
    bool pocGap = false
    string pocSide = ""
    if usePD and array.size(dH) > 1
        int pdLo = start
        int pdHi = start
        if pdMode == "Previous day"
            pdLo := math.min(1, array.size(dH) - 1)
            pdHi := pdLo
        else
            span = pdMode == "Full lookback" ? lookback : pdDays
            pdHi := math.min(start + span - 1, array.size(dH) - 1)
        float rHigh = array.get(dH, pdLo)
        float rLow  = array.get(dL, pdLo)
        int iHigh = pdLo
        int iLow  = pdLo
        for k = pdLo to pdHi
            if array.get(dH, k) > rHigh
                rHigh := array.get(dH, k)
                iHigh := k
            if array.get(dL, k) < rLow
                rLow := array.get(dL, k)
                iLow := k
        rng = rHigh - rLow
        if rng > 0
            eq = (rHigh + rLow) / 2.0
            eqLvl := eq
            bullish = iLow > iHigh
            oTime = array.get(dT, pdHi)
            if showZones
                pTop = pdStyle == "Full halves" ? eq : rLow + rng * (100.0 - pdExt) / 100.0
                pBot = pdStyle == "Full halves" ? eq : rLow + rng * pdExt / 100.0
                array.push(bxs, box.new(oTime, rHigh, time, pTop, xloc = xloc.bar_time, extend = extend.right, bgcolor = colPrem, border_color = color.new(color.gray, 100)))
                array.push(bxs, box.new(oTime, pBot, time, rLow, xloc = xloc.bar_time, extend = extend.right, bgcolor = colDisc, border_color = color.new(color.gray, 100)))
            if showFib
                fibs = array.from(0.0, pdExt, 50.0, 100.0 - pdExt, 100.0)
                for p in fibs
                    py   = rLow + rng * p / 100.0
                    isEQf = math.abs(p - 50.0) < 0.01
                    fc   = p >= 99.99 ? color.new(colPrem, 0) : p <= 0.01 ? color.new(colDisc, 0) : isEQf ? colEQ : colFib
                    if not (isEQf and showEQ)
                        array.push(lns, line.new(oTime, py, time, py, xloc = xloc.bar_time, extend = extRight ? extend.right : extend.none, color = fc, width = fibW, style = line.style_solid))
                    if showFibLbl
                        array.push(lbs, label.new(bar_index + lblOff, py, str.tostring(p, "#.00") + "%", xloc = xloc.bar_index, style = label.style_none, textcolor = fc, size = size.small, textalign = text.align_left))
            // ── Time-at-price profile (simplified TPO) ──
            if showTPO
                tnb = 40
                tdens = array.new_float(tnb, 0.0)
                // v2.1: build from chart-resolution bars inside the range window (true time-at-price).
                // Each chart bar contributes 1 unit of time spread across the bins its H-L covers.
                tEnd = pdLo == 0 ? time + 1 : array.get(dT, pdLo - 1)
                int used = 0
                if array.size(ibT) > 0
                    for j = array.size(ibT) - 1 to 0
                        tj = array.get(ibT, j)
                        if tj < oTime
                            break
                        if tj < tEnd
                            hk = array.get(ibH, j)
                            lk = array.get(ibL, j)
                            b0 = math.max(0, math.min(tnb - 1, int(math.floor((lk - rLow) / rng * tnb))))
                            b1 = math.max(0, math.min(tnb - 1, int(math.floor((hk - rLow) / rng * tnb))))
                            w = 1.0 / (b1 - b0 + 1)
                            for b = b0 to b1
                                array.set(tdens, b, array.get(tdens, b) + w)
                            used += 1
                // Fallback: daily H/L with uniform in-bar distribution (e.g. on a Daily chart,
                // or when stored chart history doesn't reach back to the range start).
                if used == 0
                    for k = pdLo to pdHi
                        hk = array.get(dH, k)
                        lk = array.get(dL, k)
                        b0 = math.max(0, math.min(tnb - 1, int(math.floor((lk - rLow) / rng * tnb))))
                        b1 = math.max(0, math.min(tnb - 1, int(math.floor((hk - rLow) / rng * tnb))))
                        w = 1.0 / (b1 - b0 + 1)
                        for b = b0 to b1
                            array.set(tdens, b, array.get(tdens, b) + w)
                int pocB = 0
                float mx = 0.0
                float tot = 0.0
                for b = 0 to tnb - 1
                    d0 = array.get(tdens, b)
                    tot += d0
                    if d0 > mx
                        mx := d0
                        pocB := b
                target = tot * vaPct / 100.0
                acc = mx
                int up = pocB + 1
                int dn = pocB - 1
                while acc < target and (up < tnb or dn >= 0)
                    du = up < tnb ? array.get(tdens, up) : -1.0
                    dd = dn >= 0 ? array.get(tdens, dn) : -1.0
                    if du >= dd
                        acc += du
                        up += 1
                    else
                        acc += dd
                        dn -= 1
                poc = rLow + (pocB + 0.5) * rng / tnb
                vah = rLow + math.min(tnb, up) * rng / tnb
                val_ = rLow + (dn + 1) * rng / tnb
                // v2.1: imbalance threshold relative to the range size, with direction.
                pocGap := math.abs(poc - eq) > rng * pocGapPct / 100.0
                pocSide := poc > eq ? "POC>EQ" : "POC<EQ"
                colVA = color.new(colPOC, 55)
                array.push(lns, line.new(oTime, poc, time, poc, xloc = xloc.bar_time, extend = extRight ? extend.right : extend.none, color = colPOC, width = 2, style = line.style_solid))
                array.push(lns, line.new(oTime, vah, time, vah, xloc = xloc.bar_time, extend = extRight ? extend.right : extend.none, color = colVA, width = 1, style = line.style_dotted))
                array.push(lns, line.new(oTime, val_, time, val_, xloc = xloc.bar_time, extend = extRight ? extend.right : extend.none, color = colVA, width = 1, style = line.style_dotted))
                if showFibLbl
                    array.push(lbs, label.new(bar_index + lblOff, poc, "POC", xloc = xloc.bar_index, style = label.style_none, textcolor = colPOC, size = size.small, textalign = text.align_left))
                    array.push(lbs, label.new(bar_index + lblOff, vah, "VAH", xloc = xloc.bar_index, style = label.style_none, textcolor = colVA, size = size.small, textalign = text.align_left))
                    array.push(lbs, label.new(bar_index + lblOff, val_, "VAL", xloc = xloc.bar_index, style = label.style_none, textcolor = colVA, size = size.small, textalign = text.align_left))
            if showEQ
                // the EQ joins the ranking as one more level; evaluated from the range start.
                addCand(eq, oTime, pdHi - 1, colEQ, "EQ", true, eqW, not (showFib and showFibLbl))
            if showPDLbl
                pos = (close - rLow) / rng * 100.0
                inPrem = close > eq
                stTxt = (inPrem ? "PREMIUM " : "DISCOUNT ") + str.tostring(math.round(pos)) + "%" + (bullish ? "  ↑" : "  ↓") + (showTPO and pocGap ? "  ·  " + pocSide : "")
                array.push(lbs, label.new(bar_index + lblOff, close, stTxt, xloc = xloc.bar_index, style = label.style_none, textcolor = inPrem ? color.new(#e91e63, 0) : color.new(#089981, 0), size = size.small, textalign = text.align_left))

    // ── H/L density clusters ──
    clusterSide(dH, dC, dT, tol, true, start)
    clusterSide(dL, dC, dT, tol, false, start)

    // ── Stats pass + global base rate (for the Bayes prior) ──
    float sumWT = 0.0
    float sumWR = 0.0
    nC = array.size(cLvl)
    if nC > 0
        for i = 0 to nC - 1
            [nT, nS, nRr, wT, wR, penM, mfe] = levelStats2(dH, dL, dC, array.get(cLvl, i), tol, array.get(cEval, i))
            array.push(sT, nT)
            array.push(sS, nS)
            array.push(sR, nRr)
            array.push(sWT, wT)
            array.push(sWR, wR)
            array.push(sPen, penM)
            array.push(sMFE, mfe)
            sumWT += wT
            sumWR += wR
    baseRate = sumWT > 0 ? sumWR / sumWT : 0.5

    // ── Score + draw pass ──
    if nC > 0
        for i = 0 to nC - 1
            lvl  = array.get(cLvl, i)
            nT   = array.get(sT, i)
            nS   = array.get(sS, i)
            nRr  = array.get(sR, i)
            wT   = array.get(sWT, i)
            wR   = array.get(sWR, i)
            penM = array.get(sPen, i)
            mfe  = array.get(sMFE, i)
            isEQc = array.get(cIsEQ, i)
            baseCol = array.get(cCol, i)
            resp = nS + nRr
            float score = scoreMode == "Wilson 95%" ? wilsonLB(wR, wT) : scoreMode == "Bayes (shrinkage)" ? bayesScore(wR, wT, baseRate) : wT > 0 ? wR / wT * 100.0 : 0.0
            score := score * penM
            // confluence
            string conf = ""
            if isRound(lvl, tol)
                conf += "●"
                score += confBonus
            if useEQconf and not isEQc and not na(eqLvl) and math.abs(lvl - eqLvl) <= tol
                conf += "◆"
                score += confBonus
            score := math.min(100.0, score)
            if nT == 0 or score >= minScore
                col = fade(scoreCol(baseCol, score, nT), lvl)
                sty = isEQc ? eSty : lSty
                ln = line.new(array.get(cTim, i), lvl, time, lvl, xloc = xloc.bar_time, extend = extRight ? extend.right : extend.none, color = col, width = array.get(cWdt, i), style = sty)
                array.push(lns, ln)
                mfeS = not na(mfe) and volD > 0 ? mfe / volD : na
                if lblMode != "None" and array.get(cLbl, i)
                    pxTxt = str.tostring(lvl, format.mintick)
                    scTxt = nT > 0 ? str.tostring(math.round(score)) + "%" : "—"
                    rbTxt = not na(mfeS) ? "  ~" + str.tostring(mfeS, "#.#") + "σ" : ""
                    txt = switch lblMode
                        "Price"     => pxTxt + (conf != "" ? " " + conf : "")
                        "Price + %" => pxTxt + "  " + scTxt + (conf != "" ? " " + conf : "")
                        =>             array.get(cTag, i) + conf + "  " + pxTxt + "\n" + scTxt + "  (" + str.tostring(resp) + "/" + str.tostring(nT) + ")  " + roleTxt(nT, nS, nRr) + rbTxt
                    isMin = lblStyle == "Minimal"
                    lb = label.new(bar_index + lblOff, lvl, txt, xloc = xloc.bar_index, style = isMin ? label.style_none : label.style_label_left, color = isMin ? color.new(color.black, 100) : color.new(col, 85), textcolor = col, size = size.small, textalign = text.align_left)
                    array.push(lbs, lb)
                array.push(rLvl, lvl)
                array.push(rScore, score)
                array.push(rTests, nT)
                array.push(rResp, resp)
                array.push(rTag, array.get(cTag, i) + conf)
                array.push(rRole, roleTxt(nT, nS, nRr))
                array.push(rCol, baseCol)
                array.push(rMFE, mfeS)

    // ── Table ──
    table.clear(tbl, 0, 0, 6, 25)
    if showTbl and array.size(rLvl) > 0
        keys = array.new_float()
        for i = 0 to array.size(rLvl) - 1
            if tblSort == "Score"
                array.push(keys, array.get(rScore, i))
            else
                array.push(keys, -math.abs(array.get(rLvl, i) - close))
        ord = array.sort_indices(keys, order.descending)
        rows = math.min(tblRows, array.size(ord))

        hCol = color.new(color.gray, 30)
        table.cell(tbl, 0, 0, "Level", text_color = hCol, text_size = tSz)
        table.cell(tbl, 1, 0, "Type",  text_color = hCol, text_size = tSz)
        table.cell(tbl, 2, 0, "Role",  text_color = hCol, text_size = tSz)
        table.cell(tbl, 3, 0, "Tests", text_color = hCol, text_size = tSz)
        table.cell(tbl, 4, 0, "Score", text_color = hCol, text_size = tSz)
        table.cell(tbl, 5, 0, "MFE",   text_color = hCol, text_size = tSz)
        table.cell(tbl, 6, 0, "Dist.", text_color = hCol, text_size = tSz)

        for r = 0 to rows - 1
            i    = array.get(ord, r)
            lvl  = array.get(rLvl, i)
            sc   = array.get(rScore, i)
            ts   = array.get(rTests, i)
            cCol2 = array.get(rCol, i)
            mfeS = array.get(rMFE, i)
            dist = (lvl - close) / close * 100.0
            scCol2 = ts > 0 ? color.from_gradient(sc, gradLo, gradHi, mute(cCol2), cCol2) : color.new(color.gray, 40)
            table.cell(tbl, 0, r + 1, str.tostring(lvl, format.mintick), text_color = cCol2, text_size = tSz)
            table.cell(tbl, 1, r + 1, array.get(rTag, i), text_color = cCol2, text_size = tSz)
            table.cell(tbl, 2, r + 1, array.get(rRole, i), text_color = color.new(color.silver, 0), text_size = tSz)
            table.cell(tbl, 3, r + 1, ts > 0 ? str.tostring(array.get(rResp, i)) + "/" + str.tostring(ts) : "—", text_color = color.new(color.silver, 0), text_size = tSz)
            table.cell(tbl, 4, r + 1, ts > 0 ? str.tostring(math.round(sc)) + "%" : "—", text_color = scCol2, text_size = tSz)
            table.cell(tbl, 5, r + 1, not na(mfeS) ? str.tostring(mfeS, "#.#") + "σ" : "—", text_color = color.new(color.silver, 0), text_size = tSz)
            table.cell(tbl, 6, r + 1, (dist >= 0 ? "+" : "") + str.tostring(dist, "#.##") + "%", text_color = color.new(color.silver, 0), text_size = tSz)
````
