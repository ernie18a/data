# Orderflow Suite [martineye15]

- url: https://www.tradingview.com/script/eZnsyK2g-Orderflow-Suite-martineye15/
- type: indicator
- pine_id: PUB;0fd0bc759068432f970728230d8e855d
- version: 1.0

## Description

Orderflow Suite — four order-flow tools in one indicator: Cumulative Volume Delta, footprint bars, imbalance / absorption signals, and a volume profile. Each module toggles independently, so you can run the full suite or just the part you need. CVD gets its own pane; the footprint, signals and profile draw directly on the price chart, so no second script is required.

MODULES
- Cumulative Volume Delta (CVD): running buy-minus-sell volume, with Session / Day / Week / None reset anchoring and a Line, Columns or Candle display (candles show open = previous CVD, close = new CVD, wicks from the intrabar delta extremes). Optional price-CVD divergence: bearish when price makes a higher high while CVD makes a lower high, bullish when price makes a lower low while CVD makes a higher low.
- Footprint bars: the most recent bars are split into price bins, each showing aggregated buy x sell volume, shaded by its net delta, with the bar's highest-volume bin (VPOC) framed.
- Imbalance & absorption: delta-imbalance triangles when |delta| / volume passes a threshold, stacked-imbalance zones when several same-direction imbalance bars line up, plus absorption labels (heavy volume in a tight range near a swing) and exhaustion labels (a new swing high on negative delta, or a new swing low on positive delta).
- Volume profile: a volume-at-price histogram over a lookback window with POC, value-area high / low and the 70% value area, in total-volume or delta-coloured mode.

DELTA ENGINE (please read)
TradingView does not provide a true bid/ask tick feed, so delta here is an approximation, not exchange order flow. Historical delta is estimated from lower-timeframe intrabars: an intrabar counts as buy volume when it closes above its open, sell volume when below, and is split evenly on an unchanged close. On the live bar you can optionally accumulate tick-based delta instead (uptick = buy, downtick = sell). Because TradingView does not store ticks, realtime values built this way can differ from what the same bar shows after a chart refresh. Treat every delta value as an estimate.

ALERTS
Ten conditions: CVD bullish / bearish divergence, bullish / bearish imbalance, stacked bullish / bearish imbalance, absorption at highs / lows, and exhaustion top / bottom.

HOW TO USE
Add it to a symbol that has volume (crypto, futures or stocks — spot forex usually has no real volume, and the tool will tell you so). Intraday timeframes from about 1 minute to 1 hour work best. Turn on the modules you want, set the delta engine (lower-timeframe auto / manual, and optional realtime tick mode), and adjust the per-module thresholds and sizes. Use CVD and its divergences for momentum and non-confirmation, the footprint and profile to see where volume actually traded, and the imbalance / absorption / exhaustion signals as context around swings. Set alerts on any of the ten conditions.

WHAT MAKES IT DIFFERENT
It combines CVD, footprint, imbalance / absorption and a volume profile in a single indicator, sharing one delta engine and drawing the price-chart modules through force_overlay from a lower pane — a combined order-flow view without stacking several scripts. Drawing counts are budgeted internally so the modules together stay within TradingView's object limits.

REPAINTING & LIMITATIONS
Confirmed-bar behaviour is stable: footprints are built on closed bars, CVD divergences use confirmed pivots (so they appear a few bars after the pivot — normal pivot lag, not repainting), and the profile is computed over completed bars. The delta approximation is the main caveat: the live bar's delta is an estimate, and if you enable realtime tick mode, the live values will not match the same bar's historical lower-timeframe values after a refresh — this is inherent to how TradingView exposes data and is noted in the input tooltips. One-second intrabars need a plan with seconds data; without it the tool uses a one-minute fallback, and very old bars beyond the intrabar budget fall back to whole-bar classification. A symbol with no volume cannot produce delta and will show a notice instead.

This is a visual, decision-support tool. It is not a strategy, it places no orders and reports no performance statistics, and it is not financial advice.

## Source Code

````pine
//@version=6
// ═════════════════════════════════════════════════════════════════════════════
// ORDERFLOW SUITE — CVD · Footprint · Imbalance/Absorption · Volume Profile
// -----------------------------------------------------------------------------
// Modules (each toggled independently in the "Modules" input group):
//   1. CVD            — cumulative buy-minus-sell volume shown in THIS pane,
//                       with Session/Day/Week/None anchoring, Line/Columns/
//                       delta-candle display and price↔CVD divergence signals.
//   2. Footprint      — the last N confirmed bars are split into K price bins;
//                       each bin shows aggregated buy × sell volume, colored by
//                       bin delta; the bar's max-volume bin (VPOC) is framed.
//   3. Imbalance      — |delta|/volume imbalance triangles, stacked-imbalance
//                       zones, absorption and exhaustion labels, all alertable.
//   4. Volume profile — volume-at-price histogram over a lookback window with
//                       POC, VAH/VAL and 70% value area; total or delta mode.
//
// DELTA APPROXIMATION CAVEAT
//   TradingView provides no true bid/ask tick feed. Historical delta is
//   approximated from lower-timeframe (LTF) intrabars: an intrabar counts as
//   buy volume when it closes above its open, sell volume when below, and is
//   split 50/50 on dojis. On the live bar you may optionally accumulate
//   tick-based delta instead (uptick = buy, downtick = sell). Tick history is
//   not stored by TradingView, so realtime values can differ from what the
//   same bar shows after a refresh. Treat all delta values as estimates, not
//   exchange orderflow.
//
// RECOMMENDED CHART TIMEFRAMES
//   1m – 1h works best. Charts ≤ 5m try 1-second intrabars, which require a
//   TradingView plan with seconds data; if unavailable, switch the delta
//   engine to Manual "1", or rely on the built-in 1-minute fallback request.
//   Intrabar history is capped (~100k intrabars), so bars beyond that budget
//   silently fall back to whole-bar classification.
//
// NOTE: this indicator is overlay=false so the CVD gets its own pane.
//   Footprint, signals and the profile are drawn on the PRICE chart through
//   force_overlay — no second script needed.
// ═════════════════════════════════════════════════════════════════════════════
indicator("Orderflow Suite", "OF Suite", overlay = false, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 1000)

// ─────────────────────────────── Inputs ──────────────────────────────────────
const string G_MOD   = "Modules"
const string G_DELTA = "Delta engine"
const string G_STYLE = "Colors"
const string G_CVD   = "Module 1 — CVD"
const string G_FP    = "Module 2 — Footprint"
const string G_IMB   = "Module 3 — Imbalance & absorption"
const string G_VP    = "Module 4 — Volume profile"

bool showCvd = input.bool(true, "Cumulative Volume Delta (CVD)", group = G_MOD, tooltip = "Cumulative sum of per-bar buy volume minus sell volume, plotted in this pane.")
bool showFp  = input.bool(true, "Footprint bars", group = G_MOD, tooltip = "Per-bar price bins with aggregated buy/sell volume, drawn on the price chart.")
bool showImb = input.bool(true, "Imbalance / absorption signals", group = G_MOD, tooltip = "Delta-imbalance triangles, stacked-imbalance zones, absorption and exhaustion labels on the price chart.")
bool showVp  = input.bool(true, "Volume profile", group = G_MOD, tooltip = "Volume-at-price histogram with POC and value area, drawn to the right of the last bar.")

string ltfModeIn   = input.string("Auto", "Lower-timeframe selection", options = ["Auto", "Manual"], group = G_DELTA, tooltip = "Auto picks 1S for charts ≤ 5m, 1m for charts ≤ 1h, 5m above. 1-second data requires a plan that supports seconds bars; a parallel 1-minute request is used as fallback when the primary LTF returns no intrabars.")
string ltfManualIn = input.timeframe("1", "Manual lower timeframe", group = G_DELTA, tooltip = "Used only when selection is Manual. Must be lower than the chart timeframe; otherwise the Auto value is used instead.")
string rtModeIn    = input.string("LTF only", "Realtime delta source", options = ["LTF only", "LTF + realtime ticks"], group = G_DELTA, tooltip = "LTF only: the live bar uses the same intrabar approximation as history. LTF + realtime ticks: the live bar accumulates tick-based delta (uptick = buy, downtick = sell, unchanged = 50/50). Ticks are not stored by TradingView, so realtime and post-refresh historical values CAN differ.")

color colUp = input.color(color.teal, "Buy / positive delta", group = G_STYLE, tooltip = "Used for buy volume, positive delta and bullish signals.")
color colDn = input.color(color.red, "Sell / negative delta", group = G_STYLE, tooltip = "Used for sell volume, negative delta and bearish signals.")

string cvdAnchorIn = input.string("Day", "Anchor (reset)", options = ["Session", "Day", "Week", "None"], group = G_CVD, tooltip = "Where the cumulative sum resets. Session is intended for intraday charts. None = rolling, never resets.")
string cvdStyleIn  = input.string("Candles", "Display style", options = ["Line", "Columns", "Candles"], group = G_CVD, tooltip = "Candles plot open = previous CVD, close = new CVD; wicks come from the intrabar delta extremes.")
bool   cvdDivOn    = input.bool(true, "Divergence detection", group = G_CVD, tooltip = "Bearish: price higher high while CVD makes a lower high. Bullish: price lower low while CVD makes a higher low.")
int    divLenIn    = input.int(5, "Divergence pivot length", minval = 2, maxval = 20, group = G_CVD, tooltip = "Bars to the left/right required to confirm a pivot. Signals therefore appear this many bars after the pivot.")

int  fpBarsIn = input.int(20, "Bars to draw", minval = 1, maxval = 60, group = G_FP, tooltip = "Footprints are kept for the most recent N confirmed bars. Automatically capped so all modules together stay under the 500-box drawing limit.")
int  fpBinsIn = input.int(10, "Price bins per bar", minval = 2, maxval = 20, group = G_FP, tooltip = "Each bar's high–low range is split into this many price rows.")
bool fpTextIn = input.bool(true, "Show buy × sell text", group = G_FP, tooltip = "Prints aggregated buy × sell volume inside each bin.")

float imbThreshIn    = input.float(0.6, "Imbalance threshold |delta| / volume", minval = 0.1, maxval = 1.0, step = 0.05, group = G_IMB, tooltip = "A bar is an imbalance bar when |delta| divided by total volume exceeds this ratio.")
int   stackLenIn     = input.int(3, "Stacked imbalance count", minval = 2, maxval = 10, group = G_IMB, tooltip = "This many consecutive same-direction imbalance bars draw a horizontal zone over their price area.")
float absVolMultIn   = input.float(2.0, "Absorption volume multiplier", minval = 1.0, step = 0.1, group = G_IMB, tooltip = "Absorption requires volume above SMA(volume, 20) × this multiplier.")
float absRangeMultIn = input.float(0.5, "Absorption range × ATR(14)", minval = 0.1, step = 0.1, group = G_IMB, tooltip = "Absorption requires the bar range to be smaller than ATR(14) × this factor, near a recent swing high/low.")
int   pivLenIn       = input.int(5, "Swing pivot length", minval = 2, maxval = 20, group = G_IMB, tooltip = "Pivot length for the swing highs/lows used by absorption and exhaustion detection.")

int    vpLookIn  = input.int(200, "Lookback bars", minval = 10, maxval = 500, group = G_VP, tooltip = "Number of chart bars aggregated into the profile.")
int    vpRowsIn  = input.int(50, "Price rows", minval = 5, maxval = 100, group = G_VP, tooltip = "Number of horizontal price rows in the profile (capped at 100 to respect drawing limits).")
string vpModeIn  = input.string("Total volume", "Profile mode", options = ["Total volume", "Delta"], group = G_VP, tooltip = "Total volume shades rows uniformly; Delta colors each row by its net buy-minus-sell volume.")
int    vpWidthIn = input.int(30, "Histogram width (bars)", minval = 5, maxval = 50, group = G_VP, tooltip = "Maximum row length, in bars, drawn to the right of the last bar.")

// Drawing budget (rule: never exceed 500 boxes total):
//   footprint ≤ 300, profile ≤ 100, stacked zones ≤ 20  →  worst case 420.
int fpBinsEff = fpBinsIn
int fpBarsEff = math.min(fpBarsIn, math.max(1, int(math.floor(300.0 / fpBinsEff))))
int vpRowsEff = math.min(vpRowsIn, 100)
int vpLookEff = math.min(vpLookIn, 500)
int MAX_ZONES      = 20
int MAX_SIG_LABELS = 60

// ─────────────────────────────── Helpers ─────────────────────────────────────
// Delete oldest labels until the array holds at most maxN.
f_pruneLabels(array<label> arr, int maxN) =>
    while array.size(arr) > maxN
        label.delete(array.shift(arr))

// Classify one bar's intrabar arrays into buy/sell volume and the running
// intrabar-delta extremes (used for CVD candle wicks).
f_classify(array<float> cArr, array<float> oArr, array<float> vArr) =>
    float buyV  = 0.0
    float sellV = 0.0
    float run   = 0.0
    float dMax  = 0.0
    float dMin  = 0.0
    int n = array.size(cArr)
    if n > 0 and n == array.size(oArr) and n == array.size(vArr)
        for i = 0 to n - 1
            float c = array.get(cArr, i)
            float o = array.get(oArr, i)
            float v = nz(array.get(vArr, i))
            if c > o
                buyV += v
            else if c < o
                sellV += v
            else
                buyV  += v * 0.5
                sellV += v * 0.5
            run  := buyV - sellV
            dMax := math.max(dMax, run)
            dMin := math.min(dMin, run)
    [buyV, sellV, dMax, dMin]

// ─────────────────────────── Volume guard ────────────────────────────────────
var bool volSeen = false
volSeen := volSeen or not na(volume)
if barstate.islast and not volSeen
    runtime.error("Orderflow Suite: this symbol provides no volume data, so delta cannot be computed. Choose a symbol with volume.")
float volSafe = nz(volume)

// ─────────────────────────── Delta engine ────────────────────────────────────
int chartSec = timeframe.in_seconds()
// Auto LTF: 1S for charts ≤ 5m, 1m for charts ≤ 1h, 5m above.
string autoLtf   = chartSec <= 300 ? "1S" : chartSec <= 3600 ? "1" : "5"
string ltfWanted = ltfModeIn == "Manual" ? ltfManualIn : autoLtf
// A LTF that is not lower than the chart TF would raise a runtime error → clamp
// to the Auto value, and ultimately to the chart TF itself (equal is allowed).
string ltfPrimary = timeframe.in_seconds(ltfWanted) < chartSec ? ltfWanted : timeframe.in_seconds(autoLtf) <= chartSec ? autoLtf : timeframe.period
// Parallel 1-minute request: fallback for symbols/plans without seconds data.
string ltfFallback = chartSec > 60 ? "1" : timeframe.period

// Both requests run at GLOBAL scope on EVERY bar (compile-safety rule 2).
// Each returns one array element per intrabar; arrays are EMPTY when the
// ~100k-intrabar budget is exceeded or the LTF has no data for this bar.
[ltfC1, ltfO1, ltfV1] = request.security_lower_tf(syminfo.tickerid, ltfPrimary, [close, open, volume])
[ltfC2, ltfO2, ltfV2] = request.security_lower_tf(syminfo.tickerid, ltfFallback, [close, open, volume])

[buyA, sellA, dMaxA, dMinA] = f_classify(ltfC1, ltfO1, ltfV1)
[buyB, sellB, dMaxB, dMinB] = f_classify(ltfC2, ltfO2, ltfV2)
bool haveA = array.size(ltfC1) > 0
bool haveB = array.size(ltfC2) > 0

// Whole-bar fallback when no intrabar data exists at all.
float wbBuy  = close > open ? volSafe : close < open ? 0.0 : volSafe * 0.5
float wbSell = volSafe - wbBuy

float histBuy   = haveA ? buyA : haveB ? buyB : wbBuy
float histSell  = haveA ? sellA : haveB ? sellB : wbSell
float histDelta = histBuy - histSell
float histDMax  = haveA ? dMaxA : haveB ? dMaxB : math.max(histDelta, 0.0)
float histDMin  = haveA ? dMinA : haveB ? dMinB : math.min(histDelta, 0.0)

// Realtime tick engine (varip = updates on every tick; behaves like var on
// historical bars). NOTE: ticks are not stored by TradingView, so a bar built
// from ticks in realtime will NOT match its own historical LTF value after a
// refresh — this is expected and documented in the input tooltip.
varip float rtBuy       = 0.0
varip float rtSell      = 0.0
varip float rtPrevVol   = 0.0
varip float rtPrevPrice = na
varip float rtDMax      = 0.0
varip float rtDMin      = 0.0
bool useTicks = rtModeIn == "LTF + realtime ticks"
if useTicks and barstate.isrealtime
    if barstate.isnew
        rtBuy     := 0.0
        rtSell    := 0.0
        rtPrevVol := 0.0
        rtDMax    := 0.0
        rtDMin    := 0.0
    // Per-tick volume = increase of the bar's cumulative volume since last tick.
    float tickVol = math.max(volSafe - rtPrevVol, 0.0)
    if tickVol > 0
        if na(rtPrevPrice) or close == rtPrevPrice
            rtBuy  += tickVol * 0.5
            rtSell += tickVol * 0.5
        else if close > rtPrevPrice
            rtBuy += tickVol
        else
            rtSell += tickVol
        float rtRun = rtBuy - rtSell
        rtDMax := math.max(rtDMax, rtRun)
        rtDMin := math.min(rtDMin, rtRun)
    rtPrevVol   := volSafe
    rtPrevPrice := close

bool  rtActive = useTicks and barstate.isrealtime and rtBuy + rtSell > 0
float barBuy   = rtActive ? rtBuy : histBuy
float barSell  = rtActive ? rtSell : histSell
float barDelta = barBuy - barSell
float barDMax  = rtActive ? rtDMax : histDMax
float barDMin  = rtActive ? rtDMin : histDMin

// ─────────────────────── Module 1 — CVD (this pane) ──────────────────────────
// Anchor reset: Session uses session.isfirstbar; Day/Week use timeframe.change().
// The change/session calls are hoisted to globals so they run on EVERY bar.
bool sessFirst  = session.isfirstbar
bool dayChange  = timeframe.change("D")
bool weekChange = timeframe.change("W")
bool anchorReset = cvdAnchorIn == "Session" ? sessFirst : cvdAnchorIn == "Day" ? dayChange : cvdAnchorIn == "Week" ? weekChange : false

var float cvd = 0.0
float cvdOpen = anchorReset ? 0.0 : cvd            // previous CVD (0 after reset)
cvd := cvdOpen + barDelta
// Candle wicks from the intrabar cumulative-delta extremes within this bar.
float cvdHi = cvdOpen + math.max(barDMax, math.max(barDelta, 0.0))
float cvdLo = cvdOpen + math.min(barDMin, math.min(barDelta, 0.0))

bool  cvdLineOn = showCvd and cvdStyleIn == "Line"
bool  cvdColsOn = showCvd and cvdStyleIn == "Columns"
bool  cvdCndlOn = showCvd and cvdStyleIn == "Candles"
color cvdBull   = cvd >= cvdOpen ? colUp : colDn
plot(cvdLineOn ? cvd : na, "CVD line", color = colUp, linewidth = 2)
plot(cvdColsOn ? cvd : na, "CVD columns", style = plot.style_columns, color = cvd >= 0 ? color.new(colUp, 40) : color.new(colDn, 40))
plotcandle(cvdCndlOn ? cvdOpen : na, cvdCndlOn ? cvdHi : na, cvdCndlOn ? cvdLo : na, cvdCndlOn ? cvd : na, "CVD candles", color = cvdBull, wickcolor = cvdBull, bordercolor = cvdBull)
hline(0, "CVD zero line", color = color.new(color.gray, 50), linestyle = hline.style_dotted)

// Divergence: compare consecutive confirmed price pivots with CVD at the same bars.
float divPh = ta.pivothigh(high, divLenIn, divLenIn)
float divPl = ta.pivotlow(low, divLenIn, divLenIn)
var float lastPhPrice = na
var float lastPhCvd   = na
var float lastPlPrice = na
var float lastPlCvd   = na
bool bearDiv = false
bool bullDiv = false
if not na(divPh)
    float cvdAtPh = cvd[divLenIn]
    bearDiv := not na(lastPhPrice) and divPh > lastPhPrice and cvdAtPh < lastPhCvd
    lastPhPrice := divPh
    lastPhCvd   := cvdAtPh
if not na(divPl)
    float cvdAtPl = cvd[divLenIn]
    bullDiv := not na(lastPlPrice) and divPl < lastPlPrice and cvdAtPl > lastPlCvd
    lastPlPrice := divPl
    lastPlCvd   := cvdAtPl

var array<label> divLabels = array.new<label>()
if showCvd and cvdDivOn and bearDiv
    array.push(divLabels, label.new(bar_index - divLenIn, cvd[divLenIn], "Bear div", style = label.style_label_down, color = color.new(colDn, 20), textcolor = color.white, size = size.small))
if showCvd and cvdDivOn and bullDiv
    array.push(divLabels, label.new(bar_index - divLenIn, cvd[divLenIn], "Bull div", style = label.style_label_up, color = color.new(colUp, 20), textcolor = color.white, size = size.small))
f_pruneLabels(divLabels, MAX_SIG_LABELS)

alertcondition(showCvd and cvdDivOn and bearDiv, "OF Suite: CVD bearish divergence", "Orderflow Suite: price made a higher high while CVD made a lower high.")
alertcondition(showCvd and cvdDivOn and bullDiv, "OF Suite: CVD bullish divergence", "Orderflow Suite: price made a lower low while CVD made a higher low.")

// ───────────────── Module 2 — Footprint bars (price chart) ───────────────────
var array<box> fpBoxes = array.new<box>()

// Draws one confirmed bar's footprint: fpBinsEff boxes between low and high.
f_footprint(array<float> cArr, array<float> oArr, array<float> vArr) =>
    float step = (high - low) / fpBinsEff
    if step > 0
        array<float> binBuy  = array.new<float>(fpBinsEff, 0.0)
        array<float> binSell = array.new<float>(fpBinsEff, 0.0)
        int n = array.size(cArr)
        if n > 0
            for i = 0 to n - 1
                float c = array.get(cArr, i)
                float o = array.get(oArr, i)
                float v = nz(array.get(vArr, i))
                // Bin index from the intrabar close, clamped into [0, bins-1].
                int bIdx = int(math.max(0, math.min(fpBinsEff - 1, math.floor((c - low) / step))))
                if c > o
                    array.set(binBuy, bIdx, array.get(binBuy, bIdx) + v)
                else if c < o
                    array.set(binSell, bIdx, array.get(binSell, bIdx) + v)
                else
                    array.set(binBuy, bIdx, array.get(binBuy, bIdx) + v * 0.5)
                    array.set(binSell, bIdx, array.get(binSell, bIdx) + v * 0.5)
        else
            // No intrabar data: place the whole-bar approximation in the close bin.
            int bIdx = int(math.max(0, math.min(fpBinsEff - 1, math.floor((close - low) / step))))
            array.set(binBuy, bIdx, barBuy)
            array.set(binSell, bIdx, barSell)
        // Bar VPOC (max total volume bin) and gradient scale (max |bin delta|).
        int vpocBin = 0
        float vpocVol = -1.0
        float dScale = 0.0
        for j = 0 to fpBinsEff - 1
            float tot = array.get(binBuy, j) + array.get(binSell, j)
            if tot > vpocVol
                vpocVol := tot
                vpocBin := j
            dScale := math.max(dScale, math.abs(array.get(binBuy, j) - array.get(binSell, j)))
        // Prune: drop the oldest bar's boxes so ≤ fpBarsEff bars remain drawn.
        while array.size(fpBoxes) > fpBinsEff * (fpBarsEff - 1)
            box.delete(array.shift(fpBoxes))
        for j = 0 to fpBinsEff - 1
            float bBuy  = array.get(binBuy, j)
            float bSell = array.get(binSell, j)
            float d = bBuy - bSell
            color bg = dScale > 0 ? color.from_gradient(d, -dScale, dScale, color.new(colDn, 55), color.new(colUp, 55)) : color.new(color.gray, 80)
            bool isVpoc = j == vpocBin
            string txt = fpTextIn ? str.tostring(bBuy, format.volume) + " × " + str.tostring(bSell, format.volume) : ""
            array.push(fpBoxes, box.new(bar_index - 1, low + (j + 1) * step, bar_index, low + j * step, border_color = isVpoc ? chart.fg_color : color.new(color.gray, 70), border_width = isVpoc ? 2 : 1, bgcolor = bg, text = txt, text_size = size.tiny, text_color = color.new(chart.fg_color, 25), force_overlay = true))

// Footprints are drawn once per CONFIRMED bar (live bar gets its footprint at close).
if showFp and barstate.isconfirmed
    f_footprint(haveA ? ltfC1 : ltfC2, haveA ? ltfO1 : ltfO2, haveA ? ltfV1 : ltfV2)

// ───────── Module 3 — Imbalance & absorption signals (price chart) ───────────
// All ta.* calls at global scope, every bar (compile-safety rule 3).
float volSma  = ta.sma(volSafe, 20)
float atrVal  = ta.atr(14)
float swingPh = ta.pivothigh(high, pivLenIn, pivLenIn)
float swingPl = ta.pivotlow(low, pivLenIn, pivLenIn)
float stackHi = ta.highest(high, stackLenIn)
float stackLo = ta.lowest(low, stackLenIn)

// Delta imbalance: |delta| / volume beyond threshold.
float deltaRatio = volSafe > 0 ? barDelta / volSafe : 0.0
bool bullImb = deltaRatio > imbThreshIn
bool bearImb = deltaRatio < -imbThreshIn

// Stacked imbalance: X consecutive same-direction imbalance bars.
var int bullRun = 0
var int bearRun = 0
bullRun := bullImb ? bullRun + 1 : 0
bearRun := bearImb ? bearRun + 1 : 0
bool bullStackSig = bullRun == stackLenIn
bool bearStackSig = bearRun == stackLenIn

// Track the most recent confirmed swing levels for the absorption filter.
var float lastSwingHi = na
var float lastSwingLo = na
if not na(swingPh)
    lastSwingHi := swingPh
if not na(swingPl)
    lastSwingLo := swingPl

// Absorption: heavy volume, tight range, near a swing level. All comparisons
// are na-safe (nz / not na guards) so conditions are always plain bools.
float atrN    = nz(atrVal)
float volSmaN = nz(volSma)
bool highVol     = volSmaN > 0 and volSafe > volSmaN * absVolMultIn
bool tightRange  = atrN > 0 and (high - low) < atrN * absRangeMultIn
bool nearSwingHi = atrN > 0 and not na(lastSwingHi) and math.abs(high - nz(lastSwingHi)) <= atrN
bool nearSwingLo = atrN > 0 and not na(lastSwingLo) and math.abs(low - nz(lastSwingLo)) <= atrN
bool absHighSig = highVol and tightRange and nearSwingHi
bool absLowSig  = highVol and tightRange and nearSwingLo

// Exhaustion: a fresh swing high whose bar had NEGATIVE delta (and inverse).
bool exhTopSig = not na(swingPh) and nz(barDelta[pivLenIn]) < 0
bool exhBotSig = not na(swingPl) and nz(barDelta[pivLenIn]) > 0

plotshape(showImb and bullImb, "Bullish imbalance", style = shape.triangleup, location = location.belowbar, color = colUp, size = size.tiny, force_overlay = true)
plotshape(showImb and bearImb, "Bearish imbalance", style = shape.triangledown, location = location.abovebar, color = colDn, size = size.tiny, force_overlay = true)

var array<box> zoneBoxes = array.new<box>()
if showImb and bullStackSig
    array.push(zoneBoxes, box.new(bar_index - stackLenIn + 1, stackHi, bar_index + 10, stackLo, border_color = color.new(colUp, 40), border_width = 1, bgcolor = color.new(colUp, 85), force_overlay = true))
if showImb and bearStackSig
    array.push(zoneBoxes, box.new(bar_index - stackLenIn + 1, stackHi, bar_index + 10, stackLo, border_color = color.new(colDn, 40), border_width = 1, bgcolor = color.new(colDn, 85), force_overlay = true))
while array.size(zoneBoxes) > MAX_ZONES
    box.delete(array.shift(zoneBoxes))

var array<label> sigLabels = array.new<label>()
if showImb and absHighSig
    array.push(sigLabels, label.new(bar_index, high, "Absorption", style = label.style_label_down, color = color.new(colDn, 30), textcolor = color.white, size = size.small, force_overlay = true))
if showImb and absLowSig
    array.push(sigLabels, label.new(bar_index, low, "Absorption", style = label.style_label_up, color = color.new(colUp, 30), textcolor = color.white, size = size.small, force_overlay = true))
if showImb and exhTopSig
    array.push(sigLabels, label.new(bar_index - pivLenIn, swingPh, "Exhaustion", style = label.style_label_down, color = color.new(color.orange, 30), textcolor = color.white, size = size.small, force_overlay = true))
if showImb and exhBotSig
    array.push(sigLabels, label.new(bar_index - pivLenIn, swingPl, "Exhaustion", style = label.style_label_up, color = color.new(color.orange, 30), textcolor = color.white, size = size.small, force_overlay = true))
f_pruneLabels(sigLabels, MAX_SIG_LABELS)

alertcondition(showImb and bullImb, "OF Suite: bullish imbalance", "Orderflow Suite: bullish delta imbalance (delta/volume above threshold).")
alertcondition(showImb and bearImb, "OF Suite: bearish imbalance", "Orderflow Suite: bearish delta imbalance (delta/volume below negative threshold).")
alertcondition(showImb and bullStackSig, "OF Suite: stacked bullish imbalance", "Orderflow Suite: consecutive bullish imbalance bars formed a stacked zone.")
alertcondition(showImb and bearStackSig, "OF Suite: stacked bearish imbalance", "Orderflow Suite: consecutive bearish imbalance bars formed a stacked zone.")
alertcondition(showImb and absHighSig, "OF Suite: absorption at highs", "Orderflow Suite: high volume with tight range near a swing high (potential absorption).")
alertcondition(showImb and absLowSig, "OF Suite: absorption at lows", "Orderflow Suite: high volume with tight range near a swing low (potential absorption).")
alertcondition(showImb and exhTopSig, "OF Suite: exhaustion top", "Orderflow Suite: new swing high with negative delta (buyer exhaustion).")
alertcondition(showImb and exhBotSig, "OF Suite: exhaustion bottom", "Orderflow Suite: new swing low with positive delta (seller exhaustion).")

// ──────────── Module 4 — Volume profile with POC / VA (price chart) ──────────
var array<box>  vpBoxes = array.new<box>()
var array<line> vpLines = array.new<line>()

// Recomputed only on the last bar; deletes its previous drawings first.
f_profile() =>
    while array.size(vpBoxes) > 0
        box.delete(array.shift(vpBoxes))
    while array.size(vpLines) > 0
        line.delete(array.shift(vpLines))
    int lb = math.min(vpLookEff, bar_index + 1)
    // Price range of the window.
    float hi = high
    float lo = low
    for i = 0 to lb - 1
        hi := math.max(hi, high[i])
        lo := math.min(lo, low[i])
    float rowH = (hi - lo) / vpRowsEff
    if rowH > 0
        array<float> rowVol   = array.new<float>(vpRowsEff, 0.0)
        array<float> rowDelta = array.new<float>(vpRowsEff, 0.0)
        // Spread each bar's volume/delta evenly across the rows it overlaps.
        for i = 0 to lb - 1
            float bv = nz(volume[i])
            float bd = nz(barDelta[i])
            int r1 = int(math.max(0, math.min(vpRowsEff - 1, math.floor((low[i] - lo) / rowH))))
            int r2 = int(math.max(0, math.min(vpRowsEff - 1, math.floor((high[i] - lo) / rowH))))
            int span = r2 - r1 + 1
            float vPer = bv / span
            float dPer = bd / span
            for r = r1 to r2
                array.set(rowVol, r, array.get(rowVol, r) + vPer)
                array.set(rowDelta, r, array.get(rowDelta, r) + dPer)
        // POC = max-volume row; also total volume and delta gradient scale.
        int pocRow = 0
        float pocVol = -1.0
        float totVol = 0.0
        float dScale = 0.0
        for q = 0 to vpRowsEff - 1
            float rv = array.get(rowVol, q)
            totVol += rv
            dScale := math.max(dScale, math.abs(array.get(rowDelta, q)))
            if rv > pocVol
                pocVol := rv
                pocRow := q
        // 70% value area: expand row by row from the POC toward the larger side.
        int vaUp = pocRow
        int vaDn = pocRow
        float vaVol = pocVol
        while vaVol < totVol * 0.7
            float upV = vaUp < vpRowsEff - 1 ? array.get(rowVol, vaUp + 1) : -1.0
            float dnV = vaDn > 0 ? array.get(rowVol, vaDn - 1) : -1.0
            if dnV > upV
                vaDn -= 1
                vaVol += dnV
            else if upV >= 0
                vaUp += 1
                vaVol += upV
            else
                break
        // Draw the histogram to the right of the last bar.
        int xLeft = bar_index + 2
        if pocVol > 0
            for s = 0 to vpRowsEff - 1
                float rv = array.get(rowVol, s)
                if rv > 0
                    int rowLen = math.max(1, math.round(rv / pocVol * vpWidthIn))
                    float yB = lo + s * rowH
                    float yT = yB + rowH
                    bool inVa = s >= vaDn and s <= vaUp     // value-area rows shaded darker
                    float rd = array.get(rowDelta, s)
                    color rowCol = vpModeIn == "Delta" and dScale > 0 ? color.from_gradient(rd, -dScale, dScale, color.new(colDn, inVa ? 35 : 65), color.new(colUp, inVa ? 35 : 65)) : color.new(color.blue, inVa ? 55 : 78)
                    array.push(vpBoxes, box.new(xLeft, yT, xLeft + rowLen, yB, border_color = color.new(color.gray, 80), border_width = 1, bgcolor = rowCol, force_overlay = true))
            float pocY = lo + (pocRow + 0.5) * rowH
            float vahY = lo + (vaUp + 1) * rowH
            float valY = lo + vaDn * rowH
            array.push(vpLines, line.new(bar_index - lb + 1, pocY, xLeft + vpWidthIn, pocY, color = color.orange, width = 2, force_overlay = true))
            array.push(vpLines, line.new(bar_index - lb + 1, vahY, xLeft + vpWidthIn, vahY, color = color.new(color.blue, 20), style = line.style_dashed, force_overlay = true))
            array.push(vpLines, line.new(bar_index - lb + 1, valY, xLeft + vpWidthIn, valY, color = color.new(color.blue, 20), style = line.style_dashed, force_overlay = true))

if showVp and barstate.islast
    f_profile()

// ═════════════════════════════════════════════════════════════════════════════
// USAGE
//   • Pine Editor → paste → "Add to chart". The script opens in its own pane
//     (CVD); footprint, signals and the profile appear on the price chart.
//   • Key inputs: Modules (turn parts on/off), Delta engine (LTF + realtime
//     tick mode), per-module thresholds and sizes.
//   • Alerts: "Create alert" → condition "Orderflow Suite" → pick any of the
//     10 signal conditions.
// LIMITATIONS
//   • Delta is an approximation (see caveat at the top). Realtime tick delta
//     differs from historical LTF delta after a refresh — by design.
//   • 1-second intrabars need a plan with seconds data; otherwise use Manual
//     "1" or rely on the built-in 1-minute fallback. Old bars beyond the
//     ~100k-intrabar budget fall back to whole-bar classification.
//   • Footprints draw on bar close (confirmed bars) and are auto-capped so
//     footprint (≤300) + profile (≤100) + zones (≤20) stay under 500 boxes.
// ═════════════════════════════════════════════════════════════════════════════
````
