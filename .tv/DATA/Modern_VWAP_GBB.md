<!-- tradingview-pine-id: PUB;9bc0338b1b594dd1b9f5e0ccaf44d99c -->
<!-- tradingviewscripts-format: 1 -->
# Modern VWAP [GBB]

Source: https://www.tradingview.com/script/eNmPfTmZ-Modern-VWAP-GBB/

## Description

What does VWAP actually mean on an asset that never closes?

That question is why I decided to give the good old VWAP a bit of an update for 2026 markets. VWAP is the average price actually paid since some starting point — the anchor. On stocks the anchor is obvious: the opening bell. Bitcoin has no bell. What your chart calls
"the session" is midnight UTC — a timezone convention, not a market
event.

Modern VWAP [GBB] is an anchored VWAP with sigma bands that anchors itself, runs up to three instances at once, and only fires each signal family in the regime that family was designed for.

THE FOUR LAYERS

L0 — Baseline. VWAP of hlc3 accumulated from the anchor, with bands at one, two and three sigma, where sigma is the volume-weighted deviation of price around the VWAP itself — not a standard deviation of closes. On the same anchor this matches TradingView's built-in VWAP.

L1 — Auto-anchoring. This replaces the click-to-anchor workflow. Anchors are either periodic — Session, Week, Month — or Swing, which re-anchors at a confirmed pivot high or low (pivot length 10 by default, 5 to 50). When a pivot confirms, the accumulators are rebuilt from the pivot bar itself, so the swing VWAP includes the heavy volume around the turn instead of starting after it. Composite mode runs up to three anchored VWAPs together.

L2 — Adaptive bands. The sigma multiplier is scaled by the Kaufman Efficiency Ratio: choppy tape widens the bands, trending tape tightens them. Off by default.

L3 — Regime-gated signals. A KER and ATR quadrant decides whether the tape is trending or ranging, and each family only fires in its own regime. Mean reversion fires in ranging only: price closes outside the two-sigma band, then closes back inside — inside both bands, so a
candle that crosses the entire channel fires nothing. Trend continuation fires in trending only: a pullback to VWAP that holds within three bars. Direction comes from side occupancy, 8 of the last 10 closes above or below VWAP, deliberately not from VWAP slope.

HOW TO READ THE CHART

Instance A is the one that matters. Its line, its bands, and its colour: the band colour is the regime readout. Purple is trending, yellow is ranging, grey is undefined and still warming up. 

Instances B and C are context. They draw their VWAP line and the two-sigma pair only, in their own colours, so a weekly or swing anchor can sit behind your primary one without burying the chart.

Signals are labelled: MR pills for mean reversion, TC triangles for trend continuation, green for long and red for short, on confirmed bars only. There are four alert conditions, one per family.

One thing to know: the signals and the regime colour always read Instance A, whatever B and C happen to be anchored to.

SETTINGS

Composite — turn instances A, B and C on or off, each with its own anchor: Session, Week, Month or Swing. Defaults are A on Session, B on Swing, C off on Week.

Swing pivot length — 10 by default, range 5 to 50. Longer means fewer and larger swings, and a longer confirmation lag.

KER-adaptive bands, and KER weight — the L2 toggle, off by default, weight 0.5 on a 0 to 1 range.

Signal markers — turn the markers off and keep the alerts.

Colours — seven inputs. The defaults are tuned for a dark chart; adjust the accents if you trade on white.

Parity mode — leave this off. It replaces the display with the raw numeric fields I used to verify the Pine build against my reference

If you are starting out: leave everything at defaults.

---

## Source Code

````pine
//@version=6
indicator("Modern VWAP [GBB]", overlay = true, max_bars_back = 500)

// ---------------- inputs ----------------
int    pivotLen  = input.int(10, "Swing pivot length", minval = 5, maxval = 50)
bool   adaptive  = input.bool(false, "KER-adaptive bands (L2)")
float  kerWeight = input.float(0.5, "KER weight", minval = 0.0, maxval = 1.0)
bool   parityMode = input.bool(false, "Parity mode (plot CSV fields)")

bool   iAon = input.bool(true, "Instance A", group = "Composite")
string iAmode = input.string("Session", "A anchor",
     options = ["Session", "Week", "Month", "Swing"], group = "Composite")
bool   iBon = input.bool(true, "Instance B", group = "Composite")
string iBmode = input.string("Swing", "B anchor",
     options = ["Session", "Week", "Month", "Swing"], group = "Composite")
bool   iCon = input.bool(false, "Instance C", group = "Composite")
string iCmode = input.string("Week", "C anchor",
     options = ["Session", "Week", "Month", "Swing"], group = "Composite")
bool   showSignals = input.bool(true, "Signal markers", group = "Signals")
// display palette: dark-theme defaults, exposed as inputs so
// light-theme users can adjust
color cVwapA = input.color(#FFB000, "VWAP A line", group = "Colors")
color cTrend = input.color(#B84DFF, "Trending accent", group = "Colors")
color cRange = input.color(#FFE600, "Ranging accent", group = "Colors")
color cInstB = input.color(#00FFAA, "Instance B", group = "Colors")
color cInstC = input.color(#FF3EB5, "Instance C", group = "Colors")
color cLong = input.color(#00E676, "Long signals", group = "Colors")
color cShort = input.color(#FF3D71, "Short signals", group = "Colors")
color GRAY_NEUTRAL = #787B86

// fixed constructions — constants, not inputs
int KER_LEN = 20
int ATR_LEN = 14
int REGIME_LEN = 200
int OCC_WINDOW = 10
int OCC_MIN = 8
int HOLD_BARS = 3

// the parity export expects UTC bar-opens
if parityMode and syminfo.timezone != "Etc/UTC"
    runtime.error("Parity mode requires an Etc/UTC feed (BINANCE perps)")

// ---------------- KER(20): anchor-independent, computed once --------
float kerPath = math.sum(math.abs(ta.change(close)), KER_LEN)
float kerV = na(close[KER_LEN]) ? na :
     kerPath == 0.0 ? 0.0 :
     math.abs(close - close[KER_LEN]) / kerPath

// ---------------- ATR% (ta.atr = Wilder RMA seeded with SMA) --------
float atrPct = ta.atr(ATR_LEN) / close

// ---------------- trailing 200-bar medians ----------------
// Exact even-window median = mean of the two middle order statistics
// (ta.median is nearest-rank and diverges on even windows).
f_median(float src) =>
    float result = na
    var arr = array.new_float()
    array.clear(arr)
    bool anyNa = false
    for i = 0 to REGIME_LEN - 1
        float v = src[i]
        if na(v)
            anyNa := true
            break
        array.push(arr, v)
    if not anyNa
        array.sort(arr)
        int m = REGIME_LEN / 2
        result := (array.get(arr, m - 1) + array.get(arr, m)) / 2.0
    result
float medK = f_median(kerV)
float medA = f_median(atrPct)

// ---------------- regime quadrant: strictly greater = high, ties =
// low; -1 undefined; no anchor reset ----------------
int regime = na(medK) or na(medA) ? -1 :
     2 * (kerV > medK ? 1 : 0) + (atrPct > medA ? 1 : 0)
bool ranging = regime == 0 or regime == 1
bool trending = regime == 2 or regime == 3

// ---------------- timeframe changes hoisted: stateful ta calls must
// run every bar, never inside a ternary ----------------
bool chD = timeframe.change("D")
bool chW = timeframe.change("W")
bool chM = timeframe.change("M")

// ---------------- engine: one call per composite instance; Pine gives
// each call site its own var state ----------------
f_engine(simple string mode, simple int pl) =>
    // Explicit strict-inequality pivot check: the centre must beat all
    // 2*pl neighbours strictly (ta.pivothigh/low are not strict on the
    // left). Window is fully populated at bar_index >= 2*pl.
    bool phConf = false
    bool plConf = false
    if bar_index >= 2 * pl
        float ch = high[pl]
        float cl = low[pl]
        phConf := true
        plConf := true
        for i = 0 to 2 * pl
            if i != pl
                phConf := phConf and ch > high[i]
                plConf := plConf and cl < low[i]
    // simultaneous high+low = ONE event
    bool swingEvent = phConf or plConf
    bool periodicEvent = mode == "Session" ? chD :
         mode == "Week" ? chW : chM
    bool anchorEvent = barstate.isfirst or
         (mode == "Swing" ? swingEvent : periodicEvent)
    // L0/L1 accumulators
    var float sPv = 0.0
    var float sV = 0.0
    var float sP2v = 0.0
    float tp = hlc3
    if anchorEvent
        sPv := 0.0
        sV := 0.0
        sP2v := 0.0
        if mode == "Swing" and swingEvent
            // Backfill covers pivot bar .. confirmation bar inclusive
            // (pl+1 bars): offsets pl..1 here, offset 0 joins below.
            for i = 1 to pl
                float tpi = hlc3[i]
                float vi = volume[i]
                sPv := sPv + tpi * vi
                sV := sV + vi
                sP2v := sP2v + tpi * tpi * vi
    sPv := sPv + tp * volume
    sV := sV + volume
    sP2v := sP2v + tp * tp * volume
    float vwapV = sV > 0 ? sPv / sV : na
    // variance clamped at 0 before sqrt
    float sigmaV = sV > 0 ?
         math.sqrt(math.max(sP2v / sV - vwapV * vwapV, 0.0)) : na
    [vwapV, sigmaV, anchorEvent]

[vwapA, sigmaA, evA] = f_engine(iAmode, pivotLen)
[vwapB, sigmaB, evB] = f_engine(iBmode, pivotLen)
[vwapC, sigmaC, evC] = f_engine(iCmode, pivotLen)

// ---------------- bands: L2 scaling k*(1 + kerWeight*(1-KER)) when
// adaptive. Signals, context, gates and parity read instance A only.
float adapt = adaptive ? 1.0 + kerWeight * (1.0 - kerV) : 1.0
float mult1 = 1.0 * adapt
float mult2 = 2.0 * adapt
float mult3 = 3.0 * adapt
float upper1 = vwapA + mult1 * sigmaA
float lower1 = vwapA - mult1 * sigmaA
float upper2 = vwapA + mult2 * sigmaA
float lower2 = vwapA - mult2 * sigmaA
float upper3 = vwapA + mult3 * sigmaA
float lower3 = vwapA - mult3 * sigmaA
float upper2B = vwapB + mult2 * sigmaB
float lower2B = vwapB - mult2 * sigmaB
float upper2C = vwapC + mult2 * sigmaC
float lower2C = vwapC - mult2 * sigmaC

// ---------------- L3 side-occupancy context: window = the OCC_WINDOW
// bars preceding the current one, requires >= OCC_WINDOW bars since
// the anchor; na vwap counts toward the below side ----------------
var int anchorBarA = 0
if evA
    anchorBarA := bar_index
int ctx = 0
if bar_index - anchorBarA >= OCC_WINDOW
    int cnt = 0
    for i = 1 to OCC_WINDOW
        if close[i] > vwapA[i]
            cnt := cnt + 1
    ctx := cnt >= OCC_MIN ? 1 : (OCC_WINDOW - cnt) >= OCC_MIN ? -1 : 0

// ---------------- L3.1 mean reversion: close-only on both legs;
// re-entry inside both bands inclusive, so a full-channel traversal
// fires nothing ----------------
bool mrLong = false
bool mrShort = false
if not (na(upper2) or na(upper2[1]) or na(lower2) or na(lower2[1]))
    if close[1] < lower2[1] and close >= lower2 and close <= upper2
        mrLong := true
    if close[1] > upper2[1] and close <= upper2 and close >= lower2
        mrShort := true

// ---------------- L3.2 trend continuation: deadline = touch bar +
// HOLD_BARS inclusive (the touch bar may hold itself); overlapping
// touches merge; an episode dies on a context flip or a vwap reset;
// one signal per episode ----------------
var int longDl = -1
var int shortDl = -1
bool tcLong = false
bool tcShort = false
if na(vwapA)
    longDl := -1
    shortDl := -1
else
    if ctx != 1
        longDl := -1
    if ctx != -1
        shortDl := -1
    if ctx == 1 and low <= vwapA
        longDl := math.max(longDl, bar_index + HOLD_BARS)
    if ctx == -1 and high >= vwapA
        shortDl := math.max(shortDl, bar_index + HOLD_BARS)
    if longDl >= bar_index and close > vwapA
        tcLong := true
        longDl := -1
    if shortDl >= bar_index and close < vwapA
        tcShort := true
        shortDl := -1

// ---------------- gates: MR in ranging {0,1}, TC in trending {2,3} --
bool mrLongG = mrLong and ranging
bool mrShortG = mrShort and ranging
bool tcLongG = tcLong and trending
bool tcShortG = tcShort and trending

// ---------------- parity plots: CSV field names, gated flags as 0/1,
// instance A; hidden outside parity mode ----------------
parityDisp = parityMode ? display.all : display.none
plot(parityMode ? vwapA : na, "vwap", display = parityDisp)
plot(parityMode ? upper2 : na, "upper2", display = parityDisp)
plot(parityMode ? lower2 : na, "lower2", display = parityDisp)
plot(parityMode ? kerV : na, "ker", display = parityDisp)
plot(parityMode ? regime : na, "regime", display = parityDisp)
plot(parityMode ? (mrLongG ? 1 : 0) : na, "mr_long", display = parityDisp)
plot(parityMode ? (mrShortG ? 1 : 0) : na, "mr_short", display = parityDisp)
plot(parityMode ? (tcLongG ? 1 : 0) : na, "tc_long", display = parityDisp)
plot(parityMode ? (tcShortG ? 1 : 0) : na, "tc_short", display = parityDisp)

// ---------------- composite display: accentA is a per-bar colour read
// of the already-computed regime booleans ----------------
bool showA = iAon and not parityMode
bool showB = iBon and not parityMode
bool showC = iCon and not parityMode
color accentA = trending ? cTrend : ranging ? cRange : GRAY_NEUTRAL

plot(showA ? vwapA : na, "VWAP A", color = cVwapA, linewidth = 2)
pAu1 = plot(showA ? upper1 : na, "A +1sigma", color = color.new(accentA, 60))
pAl1 = plot(showA ? lower1 : na, "A -1sigma", color = color.new(accentA, 60))
pAu2 = plot(showA ? upper2 : na, "A +2sigma", color = color.new(accentA, 35))
pAl2 = plot(showA ? lower2 : na, "A -2sigma", color = color.new(accentA, 35))
pAu3 = plot(showA ? upper3 : na, "A +3sigma", color = color.new(accentA, 75))
pAl3 = plot(showA ? lower3 : na, "A -3sigma", color = color.new(accentA, 75))
// stepped-transparency fills, innermost lightest; regime-reactive
fill(pAu1, pAl1, color = color.new(accentA, 90), title = "A 1sigma fill")
fill(pAu2, pAu1, color = color.new(accentA, 83), title = "A upper 2sigma fill")
fill(pAl1, pAl2, color = color.new(accentA, 83), title = "A lower 2sigma fill")
fill(pAu3, pAu2, color = color.new(accentA, 75), title = "A upper 3sigma fill")
fill(pAl2, pAl3, color = color.new(accentA, 75), title = "A lower 3sigma fill")

plot(showB ? vwapB : na, "VWAP B", color = cInstB, linewidth = 2)
plot(showB ? upper2B : na, "B +2sigma", color = color.new(cInstB, 60))
plot(showB ? lower2B : na, "B -2sigma", color = color.new(cInstB, 60))

plot(showC ? vwapC : na, "VWAP C", color = cInstC, linewidth = 2)
plot(showC ? upper2C : na, "C +2sigma", color = color.new(cInstC, 60))
plot(showC ? lower2C : na, "C -2sigma", color = color.new(cInstC, 60))

// ---------------- signal markers + alerts: gated flags, instance A,
// confirmed bars only (the guard stops realtime-tick flicker) --------
bool sigBar = barstate.isconfirmed and not parityMode and showSignals
plotshape(sigBar and mrLongG, "MR long", shape.labelup,
     location.belowbar, cLong, text = "MR",
     textcolor = color.white, size = size.small)
plotshape(sigBar and mrShortG, "MR short", shape.labeldown,
     location.abovebar, cShort, text = "MR",
     textcolor = color.white, size = size.small)
plotshape(sigBar and tcLongG, "TC long", shape.triangleup,
     location.belowbar, cLong, text = "TC",
     textcolor = cLong, size = size.tiny)
plotshape(sigBar and tcShortG, "TC short", shape.triangledown,
     location.abovebar, cShort, text = "TC",
     textcolor = cShort, size = size.tiny)
alertcondition(mrLongG and barstate.isconfirmed, "MR long (gated)",
     "Modern VWAP [GBB]: mean-reversion long re-entry")
alertcondition(mrShortG and barstate.isconfirmed, "MR short (gated)",
     "Modern VWAP [GBB]: mean-reversion short re-entry")
alertcondition(tcLongG and barstate.isconfirmed, "TC long (gated)",
     "Modern VWAP [GBB]: trend-continuation long")
alertcondition(tcShortG and barstate.isconfirmed, "TC short (gated)",
     "Modern VWAP [GBB]: trend-continuation short")
````
