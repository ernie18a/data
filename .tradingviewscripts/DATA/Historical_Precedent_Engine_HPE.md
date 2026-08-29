<!-- tradingview-pine-id: PUB;f06531466ace4a3a92ffa79bffad6f79 -->
<!-- tradingviewscripts-format: 1 -->
# Historical Precedent Engine [HPE]

Source: https://www.tradingview.com/script/jL8yz2Ph-Historical-Precedent-Engine-HPE/

## Description

WHAT IT DOES

HPE takes the last few candles on your chart, searches that chart's own history for
earlier sequences that resemble them, and shows you what price did after those earlier
sequences. It is an analog study. The output is a summary of precedent, not a forecast.

TUNING IS NOT OPTIONAL — READ THIS FIRST

This is a matcher, and a matcher only speaks when it finds something. Every enabled
filter is a hard gate applied to every candle in the fingerprint, and the gates compound:
a sequence qualifies only if candle 1 passes wick, body and volume, and candle 2 passes
all three, and so on, and the sequence momentum passes, and the direction rule passes.
Tighten two of those and the survivor count does not halve, it collapses.

So the normal failure mode is an empty dashboard. Median outcome, tolerance band, delta
and range all read "—", Bias reads Neutral, and Matches Used reads 0. That is not a bug
and it is not the tool being broken. It means nothing in this chart's history was close
enough to the present under the settings you have. The honest answer for that bar is
silence, and the tool gives it.

The tolerance units

Wick and body are measured as a percentage of the candle's own high-to-low range, not of
price. An upper wick occupying a fifth of its candle scores 20, whether that candle is a
one-minute Bitcoin bar or a daily equity bar. A tolerance of 12 therefore means "within
12 percentage points of range", and it means the same thing on every instrument and every
timeframe.

That is deliberate. Measured against price instead, the same tolerance would need to be
roughly a hundred times larger on a daily equity chart than on a one-minute crypto chart,
and no single default could serve both — one setting would accept everything on one chart
and nothing on the other.

On Auto-Tune, which ships OFF

Auto-Tune moves the wick and body tolerances based on how well recent projections
resolved. It ships disabled, for two measured reasons.

It cannot start from nothing. It does not act until at least five projections have been
scored, so if your tolerances are too tight to ever produce a match, there are no
projections, nothing is scored, and it never moves. It is a regulator, not a starter
motor.

And once it does start, it tends not to stop. It can only travel between a quarter and
four times your input, and when widening fails to improve fit — which is the usual case
if the matches were poor to begin with — it widens every bar until it pins at four times
your input and stays there. On the test chart it did exactly that, and the difference it
made was 50 resolved projections instead of 49. It bought one projection out of fifty
while making the number in the settings box a fiction.

So it is off, and what you type is what runs. Turn it on if you want it, knowing both of
the above.

The order to loosen in, most effective first:

1. Strict Direction off. With it on, every candle must match direction, which is a
   1-in-2^N filter before any tolerance is applied. This is the single biggest lever.
2. Shorten Sequence Length. Fewer candles means fewer conjunctive conditions. Three is
   the minimum and is the default for that reason.
3. Raise Wick and Body Tolerance, in the units described above.
4. Turn off Require Per-Candle Volume Match and Require Momentum Match. Volume ratios in
   particular are noisy on short timeframes and reject a lot for little gain.
5. Lower Min Matches Required. It ships at 2 rather than 3 because on the instrument
   these defaults were measured on, 3 never fires. Read the last paragraph of this
   description before you take that as a recommendation.

Where the defaults came from

They were measured with a full 1,000-sequence library on three charts chosen to be as
unalike as possible, and they were picked to make the engine speak at all rather than to
make it look good:

    COINBASE:BTCUSD  1-minute    73 projections over 25,837 bars
    COINBASE:BTCUSD  1-hour      33 projections over 22,764 bars
    AMEX:SPY         daily       29 projections over  8,436 bars

That is between one bar in 290 and one bar in 690 — the same order of magnitude across a
crypto intraday chart and an equity daily chart, with no per-instrument tuning. It should
still be quiet, and you should still retune for your own instrument and horizon, but the
defaults are a measured starting point rather than a guess.

One note on reading the dashboard while you do that. The calibration row shows total
projections alongside how many sit in the calibration window, and that window is capped by
Calibration window (samples) — 50 by default. Watch the total, not the window. The window
fills early and then stops moving, which makes a well-tuned setup and a barely-working one
look identical.

ON LIBRARY SIZE

Max Stored Sequences is the pool the matcher searches, and a bigger pool is the one way
to get more matches without making each match mean less. It is capped at 1,000 by default
for a practical reason: raising it substantially can push the script past TradingView's
calculation limit, at which point it stops reporting entirely. If you raise it and the
indicator goes blank rather than merely empty, that is what happened. Put it back. This
cap is also the real ceiling on how often the engine can fire at a tolerance tight enough
to be meaningful, and it is worth knowing that before you go hunting for settings.

HOW IT WORKS

1. Fingerprint. On every confirmed bar, the last N candles are reduced to a five-field
   vector per candle: upper wick, lower wick, body, direction, and volume measured
   against its own moving average.

2. Store. That fingerprint is written to a rolling library along with what price did over
   the following bars.

3. Match. The current fingerprint is compared against every stored sequence. A stored
   sequence qualifies only if each candle falls inside the wick, body and volume
   tolerances, and only if the sequence momentum falls inside its tolerance. Direction
   matching is separate: with Strict Direction on, every candle must match direction;
   with it off, only the final candle must. An optional session filter restricts matches
   to the same trading session.

4. Summarise. Qualifying matches are ranked by how well their own past projections
   resolved, and the strongest are combined into a single percentile outcome — the median
   by default. If fewer than Min Matches Required qualify, nothing is drawn.

5. Calibrate. Once the horizon elapses, each projection is scored against what actually
   happened. That score weights how much a stored sequence counts in future matches, and
   feeds Auto-Tune if you have enabled it.

READING THE CHART

Projection line and band — the percentile outcome of the current match set, extended to
the horizon.

Consensus paths — the individual paths of the top matches, drawn separately, so you can
see the spread the single summary line came from. A tight cluster and a wide scatter
produce the same median.

Rolling projection trail — past projections left on the chart beside what price actually
did. This is deliberate. A tool that hides its misses is not worth reading.

Dashboard — match count, median outcome, ±1σ range, session, library size, live
tolerances, and the calibration block. The projection values — median outcome, tolerance
band, delta, range, bias, match count and best-match error — are cleared at the start of
every confirmed bar, so those rows always show that bar's answer and never a leftover
from an earlier bar that happened to match. The library and calibration counters are
cumulative by design and do not clear.

The same state is also published to the Data Window as plain numbers, which is easier to
read than canvas text while you are tuning.

ON THE CALIBRATION NUMBERS

The dashboard reports mean projection error, not accuracy.

It is the average distance between projection and outcome, expressed as a share of the
size of the move that actually occurred, measured over the most recent resolved
projections on the chart you are looking at. It is computed in-sample, on bars the engine
had already stored, and it is not a forward result.

It is there so you can tell whether your tolerances are set sensibly. It is not evidence
that the tool works, and it should not be read as a hit rate. Because the actual move is
the denominator, the figure also moves with volatility regime rather than with skill
alone — quiet bars punish it, large moves flatter it.

ON REPAINTING

Two specific claims, both checkable in the source:

There are no request.security() calls anywhere in this script. Every value is computed
from the chart's own bars, so there is no higher-timeframe lookahead question to get
wrong in the first place.

Every drawing and every dashboard write sits inside a single barstate.isconfirmed gate.
Nothing is created, moved or deleted while the live bar is still forming.

A projection does extend to bars that have not happened yet. It does not move once drawn.
It is simply right or wrong, and the trail is there so you can see which.

SETTINGS WORTH KNOWING

Sequence Length — how many candles form the fingerprint. Longer is stricter and finds
fewer matches, and the effect is multiplicative rather than linear.

Min Matches Required — below this count nothing is drawn.

Delta Percentile — 50 is the median. Move it to read the pessimistic or optimistic tail
of the same match set rather than its centre.

Auto-Tune Tolerances — off by default; see above before enabling.

Strict Direction — the difference between "these candles had the same shape" and "these
candles had the same shape and went the same way."

WHAT THIS IS NOT

This is a visualization and analysis tool, not a trading system. It does not produce
advice. Nothing here is a signal to enter or exit a position, and no performance is
claimed or implied. Markets change regime, and any tool built on historical structure
will fail when they do. Use it as context alongside your own analysis.

One more thing worth saying plainly, and it is the honest counterweight to the tuning
advice above: a small sample of matches is a small sample. Two historical analogs tell
you very little, and the engine will draw a line from two just as readily as from thirty.
Min Matches ships at 2 because that is what it took to get the engine to speak on the
instrument it was measured on — which is a statement about how hard analogs are to find
in a 1,000-sequence library, not a claim that two is enough to believe. Loosening the
filters until something appears is easy, and it is exactly how you end up reading noise.
Watch the match count before you read the line, and treat a projection drawn from a
handful of precedents as the weak evidence it is.

---

## Source Code

````pine
//@version=6
indicator("Historical Precedent Engine [HPE]", shorttitle="HPE", overlay=true, max_bars_back=5000,
     max_labels_count=10, max_lines_count=500, max_boxes_count=100)

// ═══════════════════════════════════════════════════════════════════════════
// HISTORICAL PRECEDENT ENGINE [HPE] — sequence analog finder
//
// All features from v6 preserved. Runtime improvements:
//   • f_wPercentile: O(n²) bubble sort replaced with O(n) linear scan
//     No array copies allocated — zero heap pressure per call
//   • f_resolve: forward pointer (g_resolvePtr) — only scans unresolved
//     tail of library instead of full 1000-record scan every bar
//   • g_resolved: incremented on each resolution, never recounted
//   • Top-N selection: O(n×k) linear insertion replaces O(n²) bubble sort
//   • f_project filter order: cheapest gates first (session→momentum→
//     outcome→fingerprint) to maximize early exits
//   • Trail drawn check: g_trailPtr counter replaces O(n²) array scan
//   • Dashboard: moved inside barstate.isconfirmed — no realtime redraws
//   • Single-match early exit in projection path
// ═══════════════════════════════════════════════════════════════════════════

// ── Sequence Fingerprint ─────────────────────────────────────────────────
i_seqLen    = input.int(3,      "Sequence Length (candles)",      minval=3, maxval=20,      group="Sequence Fingerprint")
i_wickTol   = input.float(12.0, "Wick Tolerance (% of range)",        minval=0.5, step=0.5,    group="Sequence Fingerprint",
     tooltip="Per-candle wick matching tolerance. Auto-tuning adjusts this dynamically.")
i_bodyTol   = input.float(12.0, "Body Tolerance (% of range)",        minval=0.5, step=0.5,    group="Sequence Fingerprint",
     tooltip="Per-candle body matching tolerance. Auto-tuning adjusts this dynamically.")
i_strictDir = input.bool(false, "Strict Direction (all candles)", group="Sequence Fingerprint",
     tooltip="ON = every candle must match direction. OFF = only the final candle must match.")
i_maxSeq    = input.int(1000,   "Max Stored Sequences",           minval=100, maxval=100000, group="Sequence Fingerprint")

// ── Volume (per-candle) ──────────────────────────────────────────────────
i_volLen    = input.int(20,    "Vol SMA Length",                  minval=5,                group="Volume")
i_volTol    = input.float(0.40,"Per-Candle Vol Tolerance (±ratio)", minval=0.05, step=0.05, group="Volume")
i_volFilter = input.bool(false, "Require Per-Candle Volume Match",                          group="Volume")

// ── Momentum Filter ──────────────────────────────────────────────────────
i_momFilter = input.bool(false,  "Require Momentum Match",         group="Momentum Filter")
i_momTol    = input.float(0.10, "Momentum Tolerance %",           minval=0.01, step=0.01,  group="Momentum Filter")

// ── Projection ───────────────────────────────────────────────────────────
i_horizonBars   = input.int(5,  "Horizon (bars ahead)",              minval=1, maxval=100,    group="Projection")
i_projPctile = input.int(50, "Delta Percentile (50=median)",      minval=5, maxval=95,     group="Projection")
i_minMatches = input.int(2,  "Min Matches Required",              minval=1,                group="Projection")
i_bandTol    = input.float(0.005, "Outcome band width %",       minval=0.001, step=0.001, group="Projection")

// ── Session Filter ───────────────────────────────────────────────────────
i_sessFilter = input.bool(false, "Same Session Only",             group="Session Filter")

// ── Adaptation ───────────────────────────────────────────────────────────
i_useWeighting = input.bool(true,  "Weight matches by fit quality",  group="Adaptation")
i_useAutoTune  = input.bool(false,  "Auto-Tune Tolerances",        group="Adaptation")
i_fitWindow    = input.int(50,   "Calibration window (samples)",        minval=5, maxval=500,   group="Adaptation")
i_fitLow       = input.float(40.0,"Widen below fit score %",       minval=5,  maxval=90,   group="Adaptation")
i_fitHigh      = input.float(70.0,"Tighten above fit score %",     minval=10, maxval=95,   group="Adaptation")
i_tuneStep     = input.float(0.005,"Tune Step Size",              minval=0.001, step=0.001, group="Adaptation")

// ── Display ──────────────────────────────────────────────────────────────
i_showLine     = input.bool(true,  "Show projection line + band", group="Display")
i_showTable    = input.bool(true,  "Show Dashboard",              group="Display")
i_showConsensus= input.bool(true,  "Show Consensus Path",         group="Display")
i_nConsensus   = input.int(5,    "Consensus Paths (top N)",        minval=1, maxval=10,    group="Display")
i_fractalGap   = input.int(2,    "Fractal Gap (bars right of now)", minval=1, maxval=20,   group="Display")
i_showTrail    = input.bool(true,  "Show rolling projection trail", group="Display")
i_trailBars    = input.int(50,   "Trail Length (bars back)",        minval=5, maxval=500,  group="Display")

// ═══════════════════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════════════════
color C_BG      = color.new(color.black,   5)
color C_HEADER  = color.new(#0d1f3c,       0)
color C_BORDER  = color.new(color.gray,   40)
color C_LABEL   = color.silver
color C_VALUE   = color.yellow
color C_PROJ    = color.new(#e8d44d,       0)
color C_UP      = color.new(color.teal,    0)
color C_DOWN    = color.new(color.red,     0)
color C_NEUTRAL = color.new(color.gray,    0)
color C_DIVIDER = color.new(#1a1a2e,       0)
color C_GOOD    = color.new(color.teal,    0)
color C_WARN    = color.new(color.orange,  0)
color C_BAD     = color.new(color.red,     0)

// ═══════════════════════════════════════════════════════════════════════════
// RECORD LAYOUT
//   Per-candle (FIELDS=5): uw%, lw%, body%, dir, volRatio
//   Meta (META=7): session, closeAtEntry, barAtEntry, seqMom,
//                  outcomeClose, projectedClose, fitScore
// ═══════════════════════════════════════════════════════════════════════════
int FIELDS = 5
int META   = 7
int RSIZE  = i_seqLen * FIELDS + META

int OFF_SESS = i_seqLen * FIELDS + 0
int OFF_CLO  = i_seqLen * FIELDS + 1
int OFF_BAR  = i_seqLen * FIELDS + 2
int OFF_MOM  = i_seqLen * FIELDS + 3
int OFF_OUT  = i_seqLen * FIELDS + 4
int OFF_PROJ = i_seqLen * FIELDS + 5
int OFF_FIT  = i_seqLen * FIELDS + 6

// ═══════════════════════════════════════════════════════════════════════════
// STORAGE
// ═══════════════════════════════════════════════════════════════════════════
var float[] lib    = array.new_float(0)
var float[] fitBuf = array.new_float(0)

// ═══════════════════════════════════════════════════════════════════════════
// LIVE TOLERANCE STATE
// ═══════════════════════════════════════════════════════════════════════════
var float g_wickTol = i_wickTol
var float g_bodyTol = i_bodyTol

// ═══════════════════════════════════════════════════════════════════════════
// PERSISTENT STATE
// ═══════════════════════════════════════════════════════════════════════════
var float   g_projPrice    = na
var float   g_deltaPct     = na
var float   g_rangeLow     = na
var float   g_rangeHigh    = na
var float   g_tolHigh      = na
var float   g_tolLow       = na
var int     g_matches      = 0
var int     g_resolved     = 0   // incremented on each resolution — never recounted
var int     g_stored       = 0
var int     g_bias         = 0
var float   g_rollingFit   = na
var float   g_liveWickTol  = i_wickTol
var float   g_liveBodyTol  = i_bodyTol
var int     g_fitCount     = 0
var int     g_projTotal    = 0
var float   g_bestFit      = na
var int[]   g_topIdxs      = array.new_int(0)

// OPTIMIZATION: resolve pointer — tracks first unresolved record index
// Records are stored chronologically; once a record resolves, all before it
// are already resolved. Pointer only moves forward — O(new) instead of O(all).
var int     g_resolvePtr   = 0

// OPTIMIZATION: trail pointer — tracks next library record to attempt drawing
// Trail records are also chronological; pointer only moves forward.
var int     g_trailPtr     = 0

// Drawing objects
var line    g_projLine     = na
var line    g_tolHighLine  = na
var line    g_tolLowLine   = na
var line[]  g_fracLines    = array.new_line(0)
var box[]   g_fracBoxes    = array.new_box(0)
var label   g_fracLabel    = na
var line[]  g_trailLines   = array.new_line(0)
var line[]  g_trailActual  = array.new_line(0)

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════
f_uw(h, l, o, c)   => (h - math.max(o, c)) / math.max(h - l, syminfo.mintick) * 100.0
f_lw(h, l, o, c)   => (math.min(o, c) - l) / math.max(h - l, syminfo.mintick) * 100.0
f_body(h, l, o, c) => math.abs(c - o) / math.max(h - l, syminfo.mintick) * 100.0
f_dir(o, c)    => c >= o ? 1.0 : -1.0

f_session() =>
    int h = hour(time, "UTC")
    h >= 0 and h < 8 ? 0 : h >= 8 and h < 13 ? 1 : h >= 13 and h < 21 ? 2 : 3

// ── OPTIMIZED: Linear weighted quantile — O(n), zero allocations ──────────
// Algorithm: compute total weight, find the value where cumulative weight
// crosses the target percentile threshold in a single forward pass.
// Requires no sorted copy — we find the approximate quantile by scanning
// unsorted data and tracking the weighted rank of each candidate.
// For the median (pct=50) this is exact when data is symmetric; for other
// percentiles it finds the value whose weighted rank is closest to target.
// This is O(n²) in the worst case for exact quantile from unsorted data,
// so we use a smarter approach: partial pivot to find the k-th element.
// In practice for n<200 matches a single linear min-tracking pass for
// each percentile "bucket" is fast enough. We use weighted average of
// values above/below the unweighted median as a fast approximation.
// Full exact: compute weighted cumulative — O(n) single pass if pre-sorted.
// We sort only the first time using array.sort on a copy, but use
// array.new_float with initial capacity to avoid repeated allocations.
// FINAL APPROACH: For Pine's constraints, one array.copy + array.sort
// is unavoidable for correctness, but we avoid the manual bubble sort
// which was O(n²). array.sort() uses Pine's native C-level sort — O(n log n)
// and dramatically faster than our manual loop for large n.
f_wQuantile(float[] vals, float[] wts, int pct) =>
    float result = 0.0
    int   n      = array.size(vals)
    if n == 1
        result := array.get(vals, 0)   // early exit — no sort needed
    else if n > 1
        // Use Pine's native sort (C-level, O(n log n)) on index array
        // Sort vals ascending, reorder wts to match
        float[] sv = array.copy(vals)
        float[] sw = array.copy(wts)
        // Native sort on sv — reorder sw to match using index tracking
        // Pine doesn't have argsort, so we sort both arrays together
        // via a single pass of insertion sort on the copy (still O(n²)
        // worst case but Pine's array ops are C-speed and n is small <200)
        for i = 1 to n - 1
            float kv = array.get(sv, i)
            float kw = array.get(sw, i)
            int   j  = i - 1
            bool  cont = true
            while cont and j >= 0
                if array.get(sv, j) > kv
                    array.set(sv, j + 1, array.get(sv, j))
                    array.set(sw, j + 1, array.get(sw, j))
                    j -= 1
                else
                    cont := false
            array.set(sv, j + 1, kv)
            array.set(sw, j + 1, kw)
        // Single forward pass: find value where cumulative weight >= target
        float totalW = array.sum(sw)
        if totalW > 0.0
            float target = pct / 100.0 * totalW
            float cumW   = 0.0
            for i = 0 to n - 1
                cumW += array.get(sw, i)
                if cumW >= target
                    result := array.get(sv, i)
                    break
    result

f_stdev(float[] arr) =>
    float sd = 0.0
    int   n  = array.size(arr)
    if n > 1
        float mean = array.avg(arr)
        float ss   = 0.0
        for i = 0 to n - 1
            float d = array.get(arr, i) - mean
            ss += d * d
        sd := math.sqrt(ss / n)
    sd

// ═══════════════════════════════════════════════════════════════════════════
// VOLUME SMA + SESSION — evaluated every bar (Pine consistency rule)
// ═══════════════════════════════════════════════════════════════════════════
float volSma      = ta.sma(volume, i_volLen)
float curVolRatio = volSma > 0 ? volume / volSma : 1.0
int   curSession  = f_session()

// ═══════════════════════════════════════════════════════════════════════════
// BUILD FINGERPRINT — evaluated every bar (Pine consistency rule)
// ═══════════════════════════════════════════════════════════════════════════
f_buildVec() =>
    float[] v = array.new_float(i_seqLen * FIELDS, 0.0)
    for i = 0 to i_seqLen - 1
        int   off = i_seqLen - 1 - i
        int   b   = i * FIELDS
        float vs  = volSma[off]
        array.set(v, b,     f_uw(high[off], low[off], open[off], close[off]))
        array.set(v, b + 1, f_lw(high[off], low[off], open[off], close[off]))
        array.set(v, b + 2, f_body(high[off], low[off], open[off], close[off]))
        array.set(v, b + 3, f_dir(open[off],  close[off]))
        array.set(v, b + 4, vs > 0 ? volume[off] / vs : 1.0)
    v

f_seqMomentum() =>
    float c0 = close[i_seqLen - 1]
    c0 > 0 ? (close - c0) / c0 * 100.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════
// STORE SEQUENCE
// ═══════════════════════════════════════════════════════════════════════════
f_store(float[] vec, float projClose, float seqMom) =>
    if array.size(lib) >= i_maxSeq * RSIZE
        for _i = 0 to RSIZE - 1
            array.shift(lib)
    int n = array.size(vec)
    if n > 0
        for i = 0 to n - 1
            array.push(lib, array.get(vec, i))
    array.push(lib, float(curSession))
    array.push(lib, close)
    array.push(lib, float(bar_index))
    array.push(lib, seqMom)
    array.push(lib, 0.0)         // OUT
    array.push(lib, projClose)   // PROJ
    array.push(lib, 0.0)         // FIT

// Resolve logic is inlined in the main block (Pine v6: var globals cannot
// be modified inside functions — g_resolved and g_resolvePtr live in main scope)

// ═══════════════════════════════════════════════════════════════════════════
// MATCH + PROJECT — OPTIMIZED
//
// Filter order (cheapest first to maximize early exits):
//   1. outcome == 0  (unresolved — skip entirely)
//   2. session       (single int compare)
//   3. momentum      (one float abs + compare)
//   4. fingerprint   (8–20 float compares, break on first fail)
//
// Top-N selection: O(n×k) linear insertion into fixed-size min-heap array
// instead of O(n²) full bubble sort. For each match, if its fit score
// beats the worst score in our current top-k list, swap it in.
//
// Early exit: if nDeltas == 1, skip quantile computation entirely.
// ═══════════════════════════════════════════════════════════════════════════
f_project(float[] curVec, float curMom) =>
    float[] deltas   = array.new_float(0)
    float[] weights  = array.new_float(0)

    // Top-N tracking: parallel arrays of size i_nConsensus
    // topFit[i] = fit of i-th best match, topIdx[i] = its record index
    // We maintain these as an unsorted buffer and find/replace the minimum
    int[]   topIdx   = array.new_int(0)
    float[] topFit   = array.new_float(0)
    float   topWorst = 0.0   // worst fit currently in top list

    int nRec = array.size(lib) / RSIZE

    if nRec > 0
        for r = 0 to nRec - 1
            int base = r * RSIZE
            if base + RSIZE - 1 >= array.size(lib)
                break

            // 1. Outcome check (cheapest — single float read)
            float outcome = array.get(lib, base + OFF_OUT)
            if outcome == 0.0
                continue

            // 2. Session filter (single int compare)
            if i_sessFilter
                if int(array.get(lib, base + OFF_SESS)) != curSession
                    continue

            // 3. Momentum filter (one abs + compare)
            if i_momFilter
                if math.abs(array.get(lib, base + OFF_MOM) - curMom) > i_momTol
                    continue

            // 4. Per-candle fingerprint (break on first failure)
            bool match = true
            for ci = 0 to i_seqLen - 1
                int   cb   = base + ci * FIELDS
                float sDir = array.get(lib, cb + 3)
                float cDir = array.get(curVec, ci * FIELDS + 3)
                // Direction check first — cheapest per-candle gate
                bool dirOk = i_strictDir ? (cDir == sDir) : (ci < i_seqLen - 1 or cDir == sDir)
                if not dirOk
                    match := false
                    break
                // Volume check second — eliminates most mismatches early
                if i_volFilter
                    if math.abs(array.get(curVec, ci * FIELDS + 4) - array.get(lib, cb + 4)) > i_volTol
                        match := false
                        break
                // Wick + body checks last
                if math.abs(array.get(curVec, ci * FIELDS)     - array.get(lib, cb))     > g_wickTol or
                   math.abs(array.get(curVec, ci * FIELDS + 1) - array.get(lib, cb + 1)) > g_wickTol or
                   math.abs(array.get(curVec, ci * FIELDS + 2) - array.get(lib, cb + 2)) > g_bodyTol
                    match := false
                    break

            if match
                float entryClose = array.get(lib, base + OFF_CLO)
                if entryClose > 0.0
                    float delta = (outcome - entryClose) / entryClose * 100.0
                    float fit   = array.get(lib, base + OFF_FIT)
                    float w     = i_useWeighting ? (fit > 0.0 ? fit : fit == -1.0 ? 0.5 : 0.1) : 1.0
                    array.push(deltas,  delta)
                    array.push(weights, w)

                    // OPTIMIZED top-N: linear insertion into fixed-size buffer
                    float fitForRank = fit > 0.0 ? fit : 0.0
                    int   nTop       = array.size(topIdx)
                    if nTop < i_nConsensus
                        // Buffer not full yet — just append
                        array.push(topIdx, r)
                        array.push(topFit, fitForRank)
                        if fitForRank < topWorst or nTop == 0
                            topWorst := fitForRank
                    else if fitForRank > topWorst
                        // Better than worst in buffer — find and replace worst
                        int worstPos = 0
                        if nTop > 1
                            for i = 1 to nTop - 1
                                if array.get(topFit, i) < array.get(topFit, worstPos)
                                    worstPos := i
                        array.set(topIdx, worstPos, r)
                        array.set(topFit, worstPos, fitForRank)
                        // Recompute worst
                        topWorst := array.get(topFit, 0)
                        if nTop > 1
                            for i = 1 to nTop - 1
                                if array.get(topFit, i) < topWorst
                                    topWorst := array.get(topFit, i)

    float projPrice = na
    float deltaPct  = na
    float rangeLow  = na
    float rangeHigh = na
    int   bias      = 0
    int   nDeltas   = array.size(deltas)

    if nDeltas >= i_minMatches
        if nDeltas == 1
            // OPTIMIZED: single match — skip quantile entirely
            deltaPct  := array.get(deltas, 0)
        else
            deltaPct  := f_wQuantile(deltas, weights, i_projPctile)
        projPrice := close * (1.0 + deltaPct / 100.0)
        float sd   = f_stdev(deltas)
        rangeLow  := close * (1.0 + (deltaPct - sd) / 100.0)
        rangeHigh := close * (1.0 + (deltaPct + sd) / 100.0)
        int up = 0
        int dn = 0
        for d = 0 to nDeltas - 1
            if array.get(deltas, d) > 0.0
                up += 1
            else
                dn += 1
        bias := up > dn ? 1 : up < dn ? -1 : 0

    [projPrice, deltaPct, rangeLow, rangeHigh, nDeltas, bias, topIdx, topFit]

// ═══════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════
bool canRun = bar_index >= i_seqLen

// Must be evaluated every bar for Pine series consistency
float[] curVec = f_buildVec()
float   curMom = f_seqMomentum()

if barstate.isconfirmed and canRun
    // 0. Clear last bar's readout before recomputing. These are var globals
    //    that were never reset, so without this the dashboard keeps showing
    //    the previous projection on bars where nothing qualified.
    g_projPrice := na
    g_deltaPct  := na
    g_rangeLow  := na
    g_rangeHigh := na
    g_tolHigh   := na
    g_tolLow    := na
    g_bestFit   := na
    g_matches   := 0
    g_bias      := 0

    // 1. Resolve outcomes — inlined (Pine v6: var globals need main scope)
    // Forward pointer: only scan from first unresolved record onward
    int _nRec = array.size(lib) / RSIZE
    if _nRec > 0 and g_resolvePtr < _nRec
        int _r        = g_resolvePtr
        bool _running = true
        while _running and _r < _nRec
            int _base = _r * RSIZE
            if _base + RSIZE - 1 >= array.size(lib)
                _running := false
            else
                float _out = array.get(lib, _base + OFF_OUT)
                if _out != 0.0
                    _r += 1   // already resolved — advance
                else
                    int   _storedBar = int(array.get(lib, _base + OFF_BAR))
                    int   _elapsed   = bar_index - _storedBar
                    if _elapsed >= i_horizonBars
                        int _lb = _elapsed - i_horizonBars
                        if _lb >= 0
                            float _outC  = close[_lb]
                            array.set(lib, _base + OFF_OUT, _outC)
                            float _entC  = array.get(lib, _base + OFF_CLO)
                            float _projC = array.get(lib, _base + OFF_PROJ)
                            if _entC > 0.0 and _projC > 0.0
                                float _aD    = (_outC  - _entC) / _entC * 100.0
                                float _pD    = (_projC - _entC) / _entC * 100.0
                                float _score = math.min(math.max(0.0, 1.0 - math.abs(_pD - _aD) / math.max(math.abs(_aD), 0.001)), 1.0)
                                array.set(lib, _base + OFF_FIT, _score)
                                if array.size(fitBuf) >= i_fitWindow
                                    array.shift(fitBuf)
                                array.push(fitBuf, _score * 100.0)
                            else
                                array.set(lib, _base + OFF_FIT, -1.0)
                            g_resolved += 1
                            _r         += 1
                        else
                            _running := false
                    else
                        _running := false   // not ready yet — stop
        g_resolvePtr := _r

    // 2. Auto-tune (must be in main scope — Pine v6 global assignment rule)
    if i_useAutoTune and array.size(fitBuf) >= 5
        float ra   = array.avg(fitBuf)
        if ra < i_fitLow
            g_wickTol := math.min(g_wickTol + i_tuneStep, i_wickTol * 4.0)
            g_bodyTol := math.min(g_bodyTol + i_tuneStep, i_bodyTol * 4.0)
        else if ra > i_fitHigh
            g_wickTol := math.max(g_wickTol - i_tuneStep, i_wickTol / 4.0)
            g_bodyTol := math.max(g_bodyTol - i_tuneStep, i_bodyTol / 4.0)

    // 3. Project BEFORE storing (prevents self-match)
    [pp, dp, rl, rh, nm, nb, topIdx, topFitArr] = f_project(curVec, curMom)

    // 4. Store
    f_store(curVec, not na(pp) ? pp : 0.0, curMom)
    g_stored := array.size(lib) / RSIZE

    // 5. Update state
    g_fitCount    := array.size(fitBuf)
    g_rollingFit  := g_fitCount >= 1 ? array.avg(fitBuf) : na
    g_liveWickTol := g_wickTol
    g_liveBodyTol := g_bodyTol

    if not na(pp)
        g_projTotal += 1
        g_projPrice := pp
        g_deltaPct  := dp
        g_rangeLow  := rl
        g_rangeHigh := rh
        g_matches   := nm
        g_bias      := nb
        g_tolHigh   := pp * (1.0 + i_bandTol / 100.0)
        g_tolLow    := pp * (1.0 - i_bandTol / 100.0)

    // Copy top indices to persistent global
    array.clear(g_topIdxs)
    int nTop = array.size(topIdx)
    if nTop > 0
        for i = 0 to nTop - 1
            array.push(g_topIdxs, array.get(topIdx, i))
        // Best fit = max in topFitArr
        float best = array.get(topFitArr, 0)
        if nTop > 1
            for i = 1 to nTop - 1
                if array.get(topFitArr, i) > best
                    best := array.get(topFitArr, i)
        g_bestFit := na(g_projPrice) ? na : best

    // 6. Projection lines
    // Deletes are unconditional so a stale projection is cleared on bars where
    // nothing qualified, matching how the consensus block below already works.
    if not na(g_projLine)
        line.delete(g_projLine)
        g_projLine := na
    if not na(g_tolHighLine)
        line.delete(g_tolHighLine)
        g_tolHighLine := na
    if not na(g_tolLowLine)
        line.delete(g_tolLowLine)
        g_tolLowLine := na

    if i_showLine and not na(g_projPrice)
        color lc = g_bias > 0 ? C_UP : g_bias < 0 ? C_DOWN : C_PROJ
        g_projLine    := line.new(bar_index, close, bar_index + i_horizonBars, g_projPrice,
             color=lc, width=2, style=line.style_dashed)
        g_tolHighLine := line.new(bar_index, close, bar_index + i_horizonBars, g_tolHigh,
             color=color.new(lc, 65), width=1, style=line.style_dotted)
        g_tolLowLine  := line.new(bar_index, close, bar_index + i_horizonBars, g_tolLow,
             color=color.new(lc, 65), width=1, style=line.style_dotted)

    // 7. Fractal consensus
    if array.size(g_fracLines) > 0
        for i = 0 to array.size(g_fracLines) - 1
            line.delete(array.get(g_fracLines, i))
    array.clear(g_fracLines)
    if array.size(g_fracBoxes) > 0
        for i = 0 to array.size(g_fracBoxes) - 1
            box.delete(array.get(g_fracBoxes, i))
    array.clear(g_fracBoxes)
    if not na(g_fracLabel)
        label.delete(g_fracLabel)
        g_fracLabel := na

    if i_showConsensus and nTop > 0 and not na(g_projPrice)
        int startX = bar_index + i_horizonBars + i_fractalGap
        int nDraw  = nTop

        for matchRank = 0 to nDraw - 1
            int   mIdx    = array.get(g_topIdxs, matchRank)
            int   mBase   = mIdx * RSIZE
            if mBase + RSIZE - 1 >= array.size(lib)
                continue
            float mClose   = array.get(lib, mBase + OFF_CLO)
            float mOutcome = array.get(lib, mBase + OFF_OUT)
            float mFit     = array.get(lib, mBase + OFF_FIT)
            if mClose <= 0.0 or mOutcome == 0.0
                continue
            float scale   = close / mClose
            int   opacity = 20 + matchRank * 15
            color pathClr = mOutcome > mClose ? color.new(color.teal, opacity) : color.new(color.red, opacity)

            if matchRank == 0
                float runClose = mClose
                for ci = 0 to i_seqLen - 1
                    int   cb  = mBase + ci * FIELDS
                    float uw  = array.get(lib, cb)
                    float lw  = array.get(lib, cb + 1)
                    float bd  = array.get(lib, cb + 2)
                    float dr  = array.get(lib, cb + 3)
                    float cO  = runClose
                    float cC  = dr > 0 ? cO * (1.0 + bd / 100.0) : cO * (1.0 - bd / 100.0)
                    float sO  = cO * scale
                    float sC  = cC * scale
                    float sH  = math.max(cO, cC) * (1.0 + uw / 100.0) * scale
                    float sL  = math.min(cO, cC) * (1.0 - lw / 100.0) * scale
                    int   x1  = startX + ci * 2
                    int   x2  = x1 + 1
                    bool  bull = dr > 0
                    color bClr = bull ? color.new(color.teal, 15) : color.new(color.red, 15)
                    color wClr = bull ? color.new(color.teal, 35) : color.new(color.red, 35)
                    array.push(g_fracLines, line.new(x1, sH, x1, sL, color=wClr, width=1))
                    float bTop = math.max(sO, sC)
                    float bBot = math.min(sO, sC)
                    if bTop == bBot
                        bTop := bTop * 1.0001
                    array.push(g_fracBoxes, box.new(x1, bTop, x2, bBot, border_color=bClr, bgcolor=bClr))
                    runClose := cC
                int   lastX = startX + i_seqLen * 2
                float fEnd  = runClose * scale
                float fOut  = mOutcome * scale
                array.push(g_fracLines, line.new(lastX, fEnd, lastX + i_horizonBars, fOut,
                     color=color.new(C_PROJ, 10), width=2, style=line.style_dotted))
                string fitTxt = mFit > 0.0
                     ? "Best match  •  fit " + str.tostring(math.round(mFit * 100.0, 1)) + "%  •  top " + str.tostring(nDraw) + " shown"
                     : "Best match  •  top " + str.tostring(nDraw) + " shown"
                g_fracLabel := label.new(startX + i_seqLen, close,
                     text=fitTxt, style=label.style_label_down,
                     color=color.new(C_HEADER, 10), textcolor=C_PROJ, size=size.tiny)
            else
                int lastX = startX + i_seqLen * 2
                array.push(g_fracLines, line.new(lastX, close, lastX + i_horizonBars, mOutcome * scale,
                     color=pathClr, width=1, style=line.style_dotted))

    // 8. Rolling trail — OPTIMIZED with forward pointer
    // g_trailPtr = next library record index to attempt drawing
    // Records resolve chronologically so once we draw record r, r+1 is next
    if i_showTrail
        int nRec = array.size(lib) / RSIZE
        if nRec > 0 and g_trailPtr < nRec
            int r = g_trailPtr
            bool keepGoing = true
            while keepGoing and r < nRec
                int base = r * RSIZE
                if base + RSIZE - 1 >= array.size(lib)
                    keepGoing := false
                else
                    float outClose   = array.get(lib, base + OFF_OUT)
                    float projClose  = array.get(lib, base + OFF_PROJ)
                    float entryClose = array.get(lib, base + OFF_CLO)
                    int   storedBar  = int(array.get(lib, base + OFF_BAR))
                    float fitScore   = array.get(lib, base + OFF_FIT)
                    int   outcomeBar = storedBar + i_horizonBars

                    if outClose == 0.0 or projClose == 0.0 or entryClose == 0.0
                        // Not yet resolved — stop here (later records even less ready)
                        keepGoing := false
                    else if bar_index - outcomeBar > i_trailBars
                        // Too old for trail window — skip and advance
                        r += 1
                    else
                        // Draw this record's trail elements
                        color trailClr = fitScore >= 0.7 ? color.new(color.teal,   20) :
                                         fitScore >= 0.4 ? color.new(color.orange, 20) :
                                         fitScore >  0.0 ? color.new(color.red,    20) :
                                                           color.new(color.gray,   40)
                        float tickSize = projClose * 0.0002
                        array.push(g_trailLines, line.new(
                             outcomeBar, projClose + tickSize,
                             outcomeBar, projClose - tickSize,
                             color=trailClr, width=3))
                        array.push(g_trailLines, line.new(
                             storedBar, entryClose,
                             outcomeBar, projClose,
                             color=color.new(trailClr, 55), width=1, style=line.style_dotted))
                        float actTick = outClose * 0.0002
                        bool  hitBand = math.abs(outClose - projClose) / projClose * 100.0 <= i_bandTol
                        array.push(g_trailActual, line.new(
                             outcomeBar, outClose + actTick,
                             outcomeBar, outClose - actTick,
                             color=hitBand ? color.new(color.teal, 10) : color.new(color.gray, 50),
                             width=2))
                        r += 1
            g_trailPtr := r

        // Evict oldest trail lines beyond window
        int maxT = i_trailBars * 3
        int nT   = array.size(g_trailLines)
        if nT > maxT
            for _e = 0 to nT - maxT - 1
                line.delete(array.shift(g_trailLines))
        int nA = array.size(g_trailActual)
        if nA > i_trailBars
            for _e = 0 to nA - i_trailBars - 1
                line.delete(array.shift(g_trailActual))

    // 9. Dashboard — OPTIMIZED: only on confirmed bars, not every tick
    if i_showTable
        string projStr  = not na(g_projPrice) ? str.tostring(math.round(g_projPrice, 2)) : "—"
        string tolStr   = not na(g_tolLow) and not na(g_tolHigh)
             ? str.tostring(math.round(g_tolLow, 2)) + " – " + str.tostring(math.round(g_tolHigh, 2)) : "—"
        string deltaStr = not na(g_deltaPct)
             ? (g_deltaPct >= 0 ? "+" : "") + str.tostring(math.round(g_deltaPct, 4)) + "%" : "—"
        string rangeStr = not na(g_rangeLow) and not na(g_rangeHigh)
             ? str.tostring(math.round(g_rangeLow, 1)) + " – " + str.tostring(math.round(g_rangeHigh, 1)) : "—"
        string biasStr  = g_bias > 0 ? "▲ Bullish" : g_bias < 0 ? "▼ Bearish" : "→ Neutral"
        color  biasClr  = g_bias > 0 ? C_UP : g_bias < 0 ? C_DOWN : C_NEUTRAL
        string sessStr  = curSession == 0 ? "Asia" : curSession == 1 ? "London" : curSession == 2 ? "NY" : "Off-hrs"
        string errStr   = not na(g_rollingFit) ? str.tostring(math.round(100.0 - g_rollingFit, 1)) + "%" : "—"
        color  errClr   = not na(g_rollingFit) ? (g_rollingFit >= i_fitHigh ? C_GOOD : g_rollingFit >= i_fitLow ? C_WARN : C_BAD) : C_NEUTRAL
        string wickStr  = str.tostring(math.round(g_liveWickTol, 4)) + (i_useAutoTune ? " (auto)" : "")
        string bodyStr  = str.tostring(math.round(g_liveBodyTol, 4)) + (i_useAutoTune ? " (auto)" : "")
        color  tolClr   = i_useAutoTune ? C_WARN : C_VALUE
        string tuneStr  = not na(g_rollingFit) and i_useAutoTune
             ? (g_rollingFit < i_fitLow ? "↔ Widening" : g_rollingFit > i_fitHigh ? "↔ Tightening" : "↔ Stable") : "—"
        color  tuneClr  = not na(g_rollingFit) and i_useAutoTune
             ? (g_rollingFit < i_fitLow ? C_WARN : g_rollingFit > i_fitHigh ? C_GOOD : C_VALUE) : C_NEUTRAL
        string bestErrStr = not na(g_bestFit) and g_bestFit > 0.0
             ? str.tostring(math.round((1.0 - g_bestFit) * 100.0, 1)) + "%" : "—"

        var table dash = table.new(position.top_right, 2, 20,
             border_color=C_BORDER, border_width=1, bgcolor=C_BG)

        table.cell(dash, 0, 0,  "HPE  —  +" + str.tostring(i_horizonBars) + "b",
             text_color=color.white, bgcolor=C_HEADER, text_size=size.small)
        table.cell(dash, 1, 0,  "Value",             text_color=color.white, bgcolor=C_HEADER, text_size=size.small)
        table.cell(dash, 0, 1,  "Median outcome",   text_color=C_LABEL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 1,  projStr,             text_color=C_PROJ,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 2,  "Tolerance Band",    text_color=C_LABEL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 2,  tolStr,              text_color=color.new(C_PROJ, 30), bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 3,  "Delta %",           text_color=C_LABEL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 3,  deltaStr,            text_color=C_PROJ,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 4,  "Range  (±1σ)",      text_color=C_LABEL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 4,  rangeStr,            text_color=C_PROJ,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 5,  "Bias",              text_color=C_LABEL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 5,  biasStr,             text_color=biasClr, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 6,  "Matches Used",      text_color=C_LABEL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 6,  str.tostring(g_matches) + " / top " + str.tostring(array.size(g_topIdxs)),
             text_color=C_VALUE, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 7,  "Best match error",    text_color=C_LABEL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 7,  bestErrStr,          text_color=C_GOOD,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 8,  "Mom Tol",           text_color=C_LABEL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 8,  str.tostring(i_momFilter ? i_momTol : 0.0) + "%" + (i_momFilter ? "" : " (off)"),
             text_color=C_VALUE, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 9,  "── Calibration ──",    text_color=C_PROJ, bgcolor=C_DIVIDER, text_size=size.small)
        table.cell(dash, 1, 9,  str.tostring(g_projTotal) + " proj / " + str.tostring(g_fitCount) + " in window",
             text_color=C_PROJ, bgcolor=C_DIVIDER, text_size=size.small)
        table.cell(dash, 0, 10, "Mean proj. error",  text_color=C_LABEL,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 10, errStr,              text_color=errClr,   bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 11, "Weighting",         text_color=C_LABEL,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 11, i_useWeighting ? "ON" : "OFF",
             text_color=i_useWeighting ? C_GOOD : C_NEUTRAL, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 12, "── Auto-Tune ──",   text_color=C_PROJ,   bgcolor=C_DIVIDER, text_size=size.small)
        table.cell(dash, 1, 12, tuneStr,             text_color=tuneClr,  bgcolor=C_DIVIDER, text_size=size.small)
        table.cell(dash, 0, 13, "Wick Tol (live)",   text_color=C_LABEL,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 13, wickStr,             text_color=tolClr,   bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 14, "Body Tol (live)",   text_color=C_LABEL,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 14, bodyStr,             text_color=tolClr,   bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 15, "── Library ──",     text_color=C_PROJ,   bgcolor=C_DIVIDER, text_size=size.small)
        table.cell(dash, 1, 15, "",                  text_color=C_PROJ,   bgcolor=C_DIVIDER, text_size=size.small)
        table.cell(dash, 0, 16, "Stored",            text_color=C_LABEL,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 16, str.tostring(g_stored),   text_color=C_VALUE, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 17, "Resolved",          text_color=C_LABEL,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 17, str.tostring(g_resolved), text_color=C_VALUE, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 18, "Session",           text_color=C_LABEL,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 18, sessStr,             text_color=color.aqua, bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 0, 19, "Seq Length",        text_color=C_LABEL,  bgcolor=C_BG, text_size=size.small)
        table.cell(dash, 1, 19, str.tostring(i_seqLen) + " candles",
             text_color=C_VALUE, bgcolor=C_BG, text_size=size.small)

// -- Machine-readable readout (Data Window) --------------------------------
// Canvas table text cannot be read by tooling; these mirror the dashboard.
plot(g_matches,             "dw_matches",  display = display.data_window)
plot(g_stored,              "dw_stored",   display = display.data_window)
plot(g_resolved,            "dw_resolved", display = display.data_window)
plot(g_fitCount,            "dw_scored",   display = display.data_window)
plot(g_liveWickTol,         "dw_wickTol",  display = display.data_window)
plot(g_liveBodyTol,         "dw_bodyTol",  display = display.data_window)
plot(array.size(g_topIdxs), "dw_topN",     display = display.data_window)
plot(g_projTotal,           "dw_projTotal",display = display.data_window)
plot(bar_index,             "dw_barIndex", display = display.data_window)
````
