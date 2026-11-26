# Event Probability Engine [Quantum Algo]

- url: https://www.tradingview.com/script/rnTVDYSe-Event-Probability-Engine-Quantum-Algo/
- type: indicator
- pine_id: PUB;d96eac032b604ea3a30d2d3bd30dd24b
- version: 1.0

## Description

Event Probability Engine [Quantum Algo]
====================================================

🔶 OVERVIEW

Event Probability Engine is a statistical probability indicator that answers one question at the close of every bar: based on the measurable conditions active right now, what is the historical probability that price closes higher one, three, and five days from today? Instead of subjective pattern reading, the script builds and maintains a live rolling database of forward returns conditioned on eighteen observable market events — day-of-week seasonality, oversold and overbought readings, volume spikes, streaks, range position, volatility regime, pivot touches, and an optional lunar control — then pools the currently active events into a single composite probability, displayed as a TODAY headline, a full per-event statistics table, and a shaded forecast cone projected on the chart.

It is designed for the daily timeframe. On other timeframes, the one, three, and five day horizons become one, three, and five bars.

🔶 WHAT IS AN EVENT STUDY?

An event study measures what a market historically did after a defined, observable condition occurred — for example, what happened over the next five days every time the Relative Strength Index closed oversold, or every Monday, or every time volume spiked two standard deviations above normal. This indicator runs eighteen such studies continuously, in real time, on the chart's own data, and keeps every study honest with the statistical safeguards described below.

🔶 WHY THIS SCRIPT IS ORIGINAL

1. A live event database in Pine. Each of the eighteen events maintains its own rolling, capped sample of forward returns at three horizons, tagged with the market regime at the moment the event fired — a self-updating event-study framework, not a fixed backtest.

2. Shrinkage estimation. Every win rate is pulled toward fifty percent by a configurable number of pseudo-samples. An event with fifteen samples cannot display an extreme probability, because fifteen samples cannot justify one.

3. Overlap correction. State-based events (for example, an oversold reading persisting for a week) generate autocorrelated, overlapping samples that inflate apparent sample size. The effective sample size is deflated by the horizon length before any confidence calculation.

4. Wilson score bounds. Next to each five-day win rate, the table shows the Wilson confidence lower bound computed on the corrected sample size — the number an event must clear before its edge deserves trust, not its raw point estimate.

5. Regime conditioning with fallback. When enough samples exist in the current regime (bull or bear, defined by the two-hundred period exponential moving average), statistics are computed on regime-matched samples only, marked ® in the table. A bear-market Thursday is not assumed to behave like a bull-market Thursday.

6. Quality-weighted log-odds pooling. Active events are combined by weighted log-odds — a method related to Bayesian evidence combination — rather than naive win-rate averaging, so one strong, well-sampled edge is not diluted by three weak ones.

7. A built-in falsification control. Lunar phase events are included deliberately so the engine can audit a popular claim empirically: if full and new moons carry no edge, their quality scores sit near zero and they contribute nothing to the composite. A probability framework should be able to demonstrate which inputs fail, not only which appear to work.

🔶 HOW IT WORKS

Event detection: On every bar close the script evaluates all eighteen conditions — Monday through Friday, adaptive or fixed oversold and overbought thresholds, volume z-score spikes, up and down streaks, range-low and range-high position, volatility expansion and compression by percentile rank, confirmed pivot support and resistance touches within an Average True Range distance, and the optional lunar events.

Database recording: Whenever an event was active one, three, or five bars ago, the realized forward return is stored in that event's arrays, first-in-first-out at a configurable cap, together with the regime tag from the moment the event fired.

Per-event statistics: The table reports, for every event, the shrinkage-adjusted win rate at each horizon, the Wilson lower bound, sample count, average forward return, profit factor, a zero-to-one-hundred quality score blending edge magnitude, sample sufficiency, and recent consistency, and the resulting directional bias.

Composite probability: Active events passing the minimum-sample filter are pooled by quality-weighted log-odds into the TODAY headline (next-day probability of an up close with a visual meter), the one, three, and five day composite row with expected returns and a strength grade, and a projected forecast path with a shaded plus-and-minus one standard deviation cone drawn from the current close.

Chart layer: Optional regime background tint, the regime line, live pivot support and resistance rails with prices, and historical event markers on the candles so past occurrences of every event can be reviewed directly on the chart.

🔶 HOW TO USE IT

1. Apply it to a daily chart of any liquid symbol — cryptocurrency, stocks, indices, forex, gold, futures. Let it load its history; sample counts grow with available bars.
2. Read the TODAY headline first: the next-day probability, the meter, and the expected one-day return.
3. Scan the table for the highlighted rows — those events are active right now. Judge each by its Wilson lower bound and quality score, not the raw win rate.
4. Use the composite row and forecast cone as context: STRONG requires both a meaningful probability distance from fifty percent and high average quality.
5. Treat readings near fifty percent as exactly what they are: weak evidence. This engine is intentionally built to display small honest numbers rather than large misleading ones.
6. Combine with your own analysis — the engine measures conditional history; it does not know tomorrow's news.

🔶 SETTINGS

- Database: sample cap per event, minimum samples for composite inclusion, minimum regime-matched samples, shrinkage strength.
- Events: oscillator length and thresholds (fixed or adaptive percentile), volume z-score, streak length, range lookback, pivot lookback and touch distance, lunar events on or off.
- Statistics: Wilson z-score (default 1.645, a ninety percent one-sided bound).
- Display: dashboard position and five text sizes, forecast cone, regime tint, regime line, pivot rails, candle markers.

🔶 ALERTS

- Composite Bias Change — fires once per bar close whenever the five-day composite bias flips state, with the current one-day and five-day probabilities in the message.

🔶 FREQUENTLY ASKED QUESTIONS

Does the indicator repaint? Statistics are recorded and evaluated on closed bars, and pivot events use confirmed pivots with their standard confirmation lag. The dashboard and forecast update on the live bar by design, as a dashboard should.

Why do most probabilities sit near fifty percent? Because genuine conditional edges in daily data are small, and the shrinkage and overlap corrections are built to say so. Extreme displayed probabilities on thin samples are the signature of a dishonest tool.

What does the ® mark mean? That event currently has enough regime-matched samples, so its statistics are computed only from the current bull or bear regime rather than the full history.

Why are moon phases in a statistics tool? As a falsification control. The engine should be able to show which inputs carry no edge — and the user can watch it do exactly that.

Can I use it intraday? Yes, but the horizons become bars instead of days, and day-of-week events lose their meaning. The design intent is the daily timeframe.

🔶 CREDITS

This script stands on standard, publicly documented statistical methods, gratefully credited: the Wilson score interval by Edwin B. Wilson (1927), Laplace-style shrinkage estimation, and the event-study methodology long established in quantitative finance. Their combination into a live, regime-conditional, overlap-corrected event database with quality-weighted log-odds composite pooling, implemented entirely in Pine Script with capped arrays and user-defined types, is original work — no third-party or open-source script code was reused.

🔶 LIMITATIONS

Probabilities derived from historical conditioning are estimates, not guarantees, and conditional edges in daily data are typically small. Sample databases need history to mature; young charts produce thin, heavily shrunk statistics by design. Day-of-week events assume a five-day session calendar. Regime conditioning depends on the two-hundred period regime definition. This is a research and confluence tool, not a standalone trading system.

🔶 DISCLAIMER

This script is provided strictly for educational and informational purposes. It is not financial advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Past statistical behavior does not assure future results. Trading involves substantial risk. Always do your own research and manage risk independently.

## Source Code

````pine
//@version=6
indicator("Event Probability Engine [Quantum Algo]", overlay = true, max_lines_count = 60, max_labels_count = 30)

// ═══════════════════════════════════════════════════════════════════════════
//  EVENT PROBABILITY ENGINE
//
//  A live event-study dashboard. The script maintains a rolling database of
//  forward returns (1 / 3 / 5 bars ahead) conditioned on measurable market
//  events: day of week, RSI zones, volume spikes, up/down streaks, range
//  position, volatility regime, pivot level touches, and (optionally) lunar
//  phase. For each event it reports shrinkage-adjusted win rates, Wilson
//  confidence bounds corrected for sample overlap, average forward return,
//  and profit factor. Statistics are computed regime-conditionally
//  (bull/bear via EMA 200) whenever enough regime-matched samples exist.
//
//  Currently active events are pooled into a composite directional
//  probability using quality-weighted log-odds — not naive averaging —
//  shown as a TODAY headline (next-day probability) plus 1/3/5 bar
//  probabilities and a projected forecast path with a shaded ±1 sigma cone.
//
//  Key statistical safeguards (vs. typical "win rate" dashboards):
//   • Shrinkage: win rates are pulled toward 50% by k pseudo-samples,
//     so thin samples cannot show fake extreme probabilities.
//   • Overlap correction: state-based events produce autocorrelated
//     samples; effective sample size is deflated by the horizon length
//     before confidence bounds are computed.
//   • Wilson score interval: the lower bound is what an event must clear,
//     not its raw point estimate.
//   • Regime conditioning with fallback: bear-market Thursdays are not
//     assumed to behave like bull-market Thursdays.
//
//  Credits: Wilson score interval (E. B. Wilson, 1927), Laplace/shrinkage
//  estimation, and event-study methodology are standard public statistics.
//  Implementation is original.
//
//  Designed for the daily timeframe. On other timeframes the 1/3/5 day
//  horizons become 1/3/5 bars.
// ═══════════════════════════════════════════════════════════════════════════

// ─── Inputs ────────────────────────────────────────────────────────────────
gDB = "Event Database"
cap     = input.int(500, "Max samples per event (FIFO cap)", minval = 100, maxval = 2000, group = gDB)
minN    = input.int(30,  "Min samples to include event in composite", minval = 5, group = gDB)
minRegN = input.int(40,  "Min regime-matched samples", minval = 10, group = gDB, tooltip = "If at least this many samples were recorded in the current regime (bull/bear), statistics are computed regime-conditionally. Otherwise the full sample is used as a fallback.")
shrinkK = input.int(20,  "Shrinkage strength k", minval = 0, maxval = 200, group = gDB, tooltip = "Win rates are pulled toward 50% by k pseudo-samples. Prevents small-sample overconfidence.")

gEV = "Events"
rsiLen   = input.int(14, "RSI length", group = gEV)
adaptTh  = input.bool(true, "Adaptive RSI thresholds (15th / 85th percentile)", group = gEV)
pctLB    = input.int(480, "Percentile lookback", minval = 100, group = gEV)
osFix    = input.int(30, "RSI oversold (fixed fallback)", group = gEV)
obFix    = input.int(70, "RSI overbought (fixed fallback)", group = gEV)
volZth   = input.float(2.0, "Volume spike z-score", step = 0.1, group = gEV)
streakN  = input.int(3, "Streak length", minval = 2, group = gEV)
rangeLen = input.int(20, "Range position lookback", minval = 5, group = gEV)
pivLB    = input.int(10, "Pivot lookback (bars each side)", minval = 3, group = gEV)
pivATR   = input.float(0.5, "Pivot touch distance (× ATR)", step = 0.1, group = gEV)
useMoon  = input.bool(true, "Include lunar phase events", group = gEV, tooltip = "Included so the engine can audit the claim empirically. If lunar phases carry no edge, their quality score will sit near zero — which is the point.")

gSG = "Statistics"
zConf = input.float(1.645, "Wilson z-score (1.645 = 90% one-sided)", step = 0.005, group = gSG)

gVX = "Display"
tblPosS  = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gVX)
txtSizeS = input.string("Normal", "Table size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gVX)
showCone = input.bool(true, "Show forecast cone (shaded)", group = gVX)
showEMA  = input.bool(true, "Show regime line (EMA 200)", group = gVX)
showBG   = input.bool(true, "Tint background by regime", group = gVX)
showPiv  = input.bool(true, "Show live pivot support / resistance rails", group = gVX)
showMark = input.bool(true, "Mark events on candles", group = gVX)

// ─── Theme ─────────────────────────────────────────────────────────────────
COL_BG   = color.new(#0b1220, 6)
COL_HD   = color.new(#122038, 0)
COL_TTL  = #7dd3fc
COL_TXT  = #cbd5e1
COL_DIM  = #64748b
COL_UP   = #22c55e
COL_DN   = #ef4444
COL_NEU  = #94a3b8
COL_ACC  = #38bdf8
COL_GLD  = #f59e0b
COL_VIO  = #a78bfa

// ─── Regime & context ──────────────────────────────────────────────────────
ema200 = ta.ema(close, 200)
[diP, diM, adxV] = ta.dmi(14, 14)
bullReg = close > ema200
regime  = bullReg ? 1 : -1
wEma    = request.security(syminfo.tickerid, "W", ta.ema(close, 30), lookahead = barmerge.lookahead_off)
mtfBull = close > wEma

// ─── Event conditions (state-based, evaluated at bar close) ────────────────
rsiV  = ta.rsi(close, rsiLen)
osPct = ta.percentile_linear_interpolation(rsiV, pctLB, 15)
obPct = ta.percentile_linear_interpolation(rsiV, pctLB, 85)
osTh  = adaptTh and not na(osPct) ? osPct : osFix
obTh  = adaptTh and not na(obPct) ? obPct : obFix

volMa = ta.sma(volume, 50)
volSd = ta.stdev(volume, 50)
volZ  = volSd > 0 ? (volume - volMa) / volSd : 0.0

var int upStk = 0
var int dnStk = 0
upStk := close > close[1] ? upStk + 1 : 0
dnStk := close < close[1] ? dnStk + 1 : 0

rHi    = ta.highest(high, rangeLen)
rLo    = ta.lowest(low, rangeLen)
rngPos = rHi > rLo ? (close - rLo) / (rHi - rLo) : 0.5

atrV  = ta.atr(14)
atrPr = ta.percentrank(atrV, 100)

// Confirmed swing pivots (lag = pivLB bars, standard)
pl = ta.pivotlow(low, pivLB, pivLB)
ph = ta.pivothigh(high, pivLB, pivLB)
var float lastPL = na
var float lastPH = na
if not na(pl)
    lastPL := pl
if not na(ph)
    lastPH := ph

// Lunar phase from Julian date (synodic month, reference new moon 2000-01-06)
jd    = time / 86400000.0 + 2440587.5
moonP = math.abs((jd - 2451550.1) % 29.530588853) / 29.530588853

aMon = dayofweek == dayofweek.monday
aTue = dayofweek == dayofweek.tuesday
aWed = dayofweek == dayofweek.wednesday
aThu = dayofweek == dayofweek.thursday
aFri = dayofweek == dayofweek.friday
aOS  = rsiV < osTh
aOB  = rsiV > obTh
aVS  = volZ > volZth
aDS  = dnStk >= streakN
aUS  = upStk >= streakN
aRL  = rngPos < 0.20
aRH  = rngPos > 0.80
aVE  = atrPr > 80
aVC  = atrPr < 20
aFM  = useMoon and moonP > 0.47 and moonP < 0.53
aNM  = useMoon and (moonP < 0.03 or moonP > 0.97)
aPS  = not na(lastPL) and math.abs(close - lastPL) <= atrV * pivATR
aPR  = not na(lastPH) and math.abs(close - lastPH) <= atrV * pivATR

// ─── Chart visuals: regime tint, regime line, event markers ────────────────
bgcolor(showBG ? (bullReg ? color.new(COL_UP, 96) : color.new(COL_DN, 96)) : na, title = "Regime tint")
plot(showEMA ? ema200 : na, "Regime line (EMA 200)", color = bullReg ? color.new(COL_UP, 25) : color.new(COL_DN, 25), linewidth = 2)

plotshape(showMark and aVS,                 "Volume Spike",   shape.diamond,      location.belowbar, color.new(COL_GLD, 15), size = size.tiny)
plotshape(showMark and aOS and not aOS[1],  "RSI Oversold",   shape.triangleup,   location.belowbar, color.new(COL_UP, 0),   size = size.tiny)
plotshape(showMark and aOB and not aOB[1],  "RSI Overbought", shape.triangledown, location.abovebar, color.new(COL_DN, 0),   size = size.tiny)
plotshape(showMark and dnStk == streakN,    "Down Streak",    shape.circle,       location.belowbar, color.new(COL_VIO, 15), size = size.tiny)
plotshape(showMark and upStk == streakN,    "Up Streak",      shape.circle,       location.abovebar, color.new(COL_VIO, 15), size = size.tiny)

// ─── Event database ────────────────────────────────────────────────────────
type EventDB
    array<float> r1
    array<float> r3
    array<float> r5
    array<int>   g1
    array<int>   g3
    array<int>   g5

newDB() =>
    EventDB.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<int>(), array.new<int>(), array.new<int>())

var array<EventDB> dbs   = array.new<EventDB>()
var array<string>  names = array.new<string>()
if barstate.isfirst
    for nm in array.from("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "RSI Oversold", "RSI Overbought", "Volume Spike", "Down Streak", "Up Streak", "Range Low Zone", "Range High Zone", "Volatility Expansion", "Volatility Compression", "Full Moon", "New Moon", "Pivot Support Touch", "Pivot Resistance Touch")
        names.push(nm)
        dbs.push(newDB())

pushF(array<float> a, float v) =>
    a.push(v)
    if a.size() > cap
        a.shift()

pushI(array<int> a, int v) =>
    a.push(v)
    if a.size() > cap
        a.shift()

// Record forward returns for an event that was active 1/3/5 bars ago.
feed(EventDB db, bool cond, int reg) =>
    bool c1 = cond[1]
    bool c3 = cond[3]
    bool c5 = cond[5]
    if c1 and bar_index > 1
        pushF(db.r1, close / close[1] - 1)
        pushI(db.g1, na(reg[1]) ? 0 : reg[1])
    if c3 and bar_index > 3
        pushF(db.r3, close / close[3] - 1)
        pushI(db.g3, na(reg[3]) ? 0 : reg[3])
    if c5 and bar_index > 5
        pushF(db.r5, close / close[5] - 1)
        pushI(db.g5, na(reg[5]) ? 0 : reg[5])

feed(dbs.get(0),  aMon, regime)
feed(dbs.get(1),  aTue, regime)
feed(dbs.get(2),  aWed, regime)
feed(dbs.get(3),  aThu, regime)
feed(dbs.get(4),  aFri, regime)
feed(dbs.get(5),  aOS,  regime)
feed(dbs.get(6),  aOB,  regime)
feed(dbs.get(7),  aVS,  regime)
feed(dbs.get(8),  aDS,  regime)
feed(dbs.get(9),  aUS,  regime)
feed(dbs.get(10), aRL,  regime)
feed(dbs.get(11), aRH,  regime)
feed(dbs.get(12), aVE,  regime)
feed(dbs.get(13), aVC,  regime)
feed(dbs.get(14), aFM,  regime)
feed(dbs.get(15), aNM,  regime)
feed(dbs.get(16), aPS,  regime)
feed(dbs.get(17), aPR,  regime)

// ─── Statistics ────────────────────────────────────────────────────────────
wilson(float p, float n) =>
    n <= 0 ? 0.5 : (p + zConf * zConf / (2 * n) - zConf * math.sqrt(math.max(p * (1 - p) / n + zConf * zConf / (4 * n * n), 0.0))) / (1 + zConf * zConf / n)

// Regime-conditional stats with fallback + overlap-corrected effective n.
statsFor(array<float> rets, array<int> regs, int curReg, int hDiv) =>
    int   nAll   = rets.size()
    float pS     = 0.5
    float wLB    = 0.5
    int   nU     = 0
    float avg    = 0.0
    float pf     = 1.0
    float sd     = 0.0
    bool  regUse = false
    float wrRec  = 0.5
    if nAll > 0
        int nR = 0
        for i = 0 to nAll - 1
            if regs.get(i) == curReg
                nR += 1
        regUse := nR >= minRegN
        int   wins = 0
        float s    = 0.0
        float ss   = 0.0
        float sw   = 0.0
        float sl   = 0.0
        for i = 0 to nAll - 1
            if not regUse or regs.get(i) == curReg
                float r = rets.get(i)
                nU += 1
                s  += r
                ss += r * r
                if r > 0
                    wins += 1
                    sw   += r
                else
                    sl -= r
        if nU > 0
            float pHat = wins * 1.0 / nU
            float nEff = math.max(nU * 1.0 / hDiv, 1.0)
            pS  := (pHat * nEff + 0.5 * shrinkK) / (nEff + shrinkK)
            wLB := wilson(pHat, nEff)
            avg := s / nU
            pf  := sl > 0 ? sw / sl : (sw > 0 ? 9.99 : 1.0)
            sd  := nU > 1 ? math.sqrt(math.max(ss / nU - avg * avg, 0.0)) : 0.0
        int rw = 0
        int rn = 0
        for i = math.max(nAll - 20, 0) to nAll - 1
            rn += 1
            if rets.get(i) > 0
                rw += 1
        wrRec := rn > 0 ? rw * 1.0 / rn : pS
    [pS, wLB, nU, avg, pf, sd, regUse, wrRec]

// Quality 0–100: edge magnitude × sample sufficiency × recent consistency.
qualOf(float pS, int nU, float wrRec) =>
    float edge = math.abs(pS - 0.5) * 2
    float ssc  = math.min(nU / 150.0, 1.0)
    float cons = math.max(1.0 - math.abs(wrRec - pS) * 2.0, 0.3)
    100.0 * math.pow(edge, 0.6) * ssc * cons

fw(float p) => str.tostring(p * 100, "#.#") + "%"
fr(float r) => (r >= 0 ? "+" : "") + str.tostring(r * 100, "#.##") + "%"
meter(float p) =>
    int filled = int(math.round(p * 10))
    string m = ""
    for i = 1 to 10
        m += i <= filled ? "▰" : "▱"
    m

// ─── Dashboard, composite, forecast (last bar only) ────────────────────────
posT = tblPosS == "Top Right" ? position.top_right : tblPosS == "Top Left" ? position.top_left : tblPosS == "Bottom Right" ? position.bottom_right : position.bottom_left
tsz  = txtSizeS == "Tiny" ? size.tiny : txtSizeS == "Small" ? size.small : txtSizeS == "Normal" ? size.normal : txtSizeS == "Large" ? size.large : size.huge
tszHead = txtSizeS == "Tiny" ? size.small : txtSizeS == "Small" ? size.normal : txtSizeS == "Normal" ? size.large : size.huge

var table dash = table.new(posT, 10, 25, bgcolor = COL_BG, border_width = 1, border_color = color.new(#1e293b, 40), frame_width = 1, frame_color = color.new(#334155, 0))
var array<line>  vizLn  = array.new<line>()
var array<label> vizLb  = array.new<label>()
var linefill coneFill = na
var string lastBias = ""
var bool   merged   = false

if barstate.islast
    if not merged
        table.merge_cells(dash, 0, 0, 9, 0)
        table.merge_cells(dash, 0, 1, 9, 1)
        table.merge_cells(dash, 0, 2, 9, 2)
        table.merge_cells(dash, 0, 24, 9, 24)
        merged := true

    array<bool> actArr = array.from(aMon, aTue, aWed, aThu, aFri, aOS, aOB, aVS, aDS, aUS, aRL, aRH, aVE, aVC, aFM, aNM, aPS, aPR)

    // Header
    table.cell(dash, 0, 0, "EVENT PROBABILITY ENGINE  ·  " + syminfo.ticker + "  ·  " + timeframe.period, text_color = COL_TTL, text_size = tsz, bgcolor = COL_HD)
    string moonIco = moonP > 0.47 and moonP < 0.53 ? "  ·  🌕" : moonP < 0.03 or moonP > 0.97 ? "  ·  🌑" : ""
    string ctx = "Regime: " + (bullReg ? "BULL" : "BEAR") + "  ·  ADX " + str.tostring(adxV, "#.#") + "  ·  RSI " + str.tostring(rsiV, "#.#") + "  ·  MTF " + (mtfBull ? "UP" : "DOWN") + "  ·  Cap " + str.tostring(cap) + "/event" + moonIco
    table.cell(dash, 0, 1, ctx, text_color = COL_TXT, text_size = tsz, bgcolor = COL_HD)

    string[] hdr = array.from("EVENT", "ACT", "WR 1d", "WR 3d", "WR 5d", "n", "AVG 5d", "PF 5d", "Q", "BIAS")
    for c = 0 to 9
        table.cell(dash, c, 3, hdr.get(c), text_color = COL_ACC, text_size = tsz, bgcolor = COL_HD)

    // Composite accumulators (log-odds pooling per horizon)
    float lo1 = 0.0
    float lo3 = 0.0
    float lo5 = 0.0
    float er1 = 0.0
    float er3 = 0.0
    float er5 = 0.0
    float sd5p = 0.0
    float wT   = 0.0
    float qSum = 0.0
    int   nAct = 0

    for i = 0 to 17
        EventDB db = dbs.get(i)
        [p1, w1, n1, a1, f1, s1, ru1, rr1] = statsFor(db.r1, db.g1, regime, 1)
        [p3, w3, n3, a3, f3, s3, ru3, rr3] = statsFor(db.r3, db.g3, regime, 3)
        [p5, w5, n5, a5, f5, s5, ru5, rr5] = statsFor(db.r5, db.g5, regime, 5)
        float q    = qualOf(p5, n5, rr5)
        bool  act  = actArr.get(i)
        bool  skip = not useMoon and (i == 14 or i == 15)
        int   row  = 4 + i

        color rowTx = skip ? COL_DIM : act ? color.white : COL_TXT
        color rowBg = act and not skip ? color.new(#1a2b4a, 30) : na
        color biasC = p5 > 0.55 ? COL_UP : p5 < 0.45 ? COL_DN : COL_NEU
        string bTxt = skip ? "—" : p5 > 0.55 ? "▲ UP" : p5 < 0.45 ? "▼ DOWN" : "—"

        table.cell(dash, 0, row, names.get(i) + (ru5 ? " ®" : ""), text_color = rowTx, text_size = tsz, text_halign = text.align_left, bgcolor = rowBg)
        table.cell(dash, 1, row, skip ? "" : act ? "●" : "", text_color = COL_ACC, text_size = tsz, bgcolor = rowBg)
        table.cell(dash, 2, row, skip ? "—" : fw(p1), text_color = p1 > 0.5 ? COL_UP : COL_DN, text_size = tsz, bgcolor = rowBg)
        table.cell(dash, 3, row, skip ? "—" : fw(p3), text_color = p3 > 0.5 ? COL_UP : COL_DN, text_size = tsz, bgcolor = rowBg)
        table.cell(dash, 4, row, skip ? "—" : fw(p5) + " (" + fw(w5) + ")", text_color = p5 > 0.5 ? COL_UP : COL_DN, text_size = tsz, bgcolor = rowBg)
        table.cell(dash, 5, row, skip ? "—" : str.tostring(n5), text_color = COL_DIM, text_size = tsz, bgcolor = rowBg)
        table.cell(dash, 6, row, skip ? "—" : fr(a5), text_color = a5 >= 0 ? COL_UP : COL_DN, text_size = tsz, bgcolor = rowBg)
        table.cell(dash, 7, row, skip ? "—" : str.tostring(f5, "#.##"), text_color = f5 >= 1 ? COL_UP : COL_DN, text_size = tsz, bgcolor = rowBg)
        table.cell(dash, 8, row, skip ? "—" : str.tostring(q, "#"), text_color = q >= 40 ? COL_ACC : COL_DIM, text_size = tsz, bgcolor = rowBg)
        table.cell(dash, 9, row, bTxt, text_color = biasC, text_size = tsz, bgcolor = rowBg)

        if act and not skip and n5 >= minN
            float w  = math.max(q, 1.0) / 100.0
            float c1 = math.min(math.max(p1, 0.01), 0.99)
            float c3 = math.min(math.max(p3, 0.01), 0.99)
            float c5 = math.min(math.max(p5, 0.01), 0.99)
            lo1  += w * math.log(c1 / (1 - c1))
            lo3  += w * math.log(c3 / (1 - c3))
            lo5  += w * math.log(c5 / (1 - c5))
            er1  += w * a1
            er3  += w * a3
            er5  += w * a5
            sd5p += w * s5
            wT   += w
            qSum += q
            nAct += 1

    // Composite: quality-weighted mean log-odds, mild agreement boost
    float boost = math.min(math.sqrt(math.max(nAct, 1) * 1.0), 2.0)
    float pUp1  = wT > 0 ? 1 / (1 + math.exp(-(lo1 / wT) * boost)) : 0.5
    float pUp3  = wT > 0 ? 1 / (1 + math.exp(-(lo3 / wT) * boost)) : 0.5
    float pUp5  = wT > 0 ? 1 / (1 + math.exp(-(lo5 / wT) * boost)) : 0.5
    er1 := wT > 0 ? er1 / wT : 0.0
    er3 := wT > 0 ? er3 / wT : 0.0
    er5 := wT > 0 ? er5 / wT : 0.0
    float sd5   = wT > 0 ? sd5p / wT : 0.0
    float qAvg  = nAct > 0 ? qSum / nAct : 0.0

    string bias1 = pUp1 > 0.55 ? "UP" : pUp1 < 0.45 ? "DOWN" : "NEUTRAL"
    string bias5 = pUp5 > 0.55 ? "UP" : pUp5 < 0.45 ? "DOWN" : "NEUTRAL"
    color  bC1   = bias1 == "UP" ? COL_UP : bias1 == "DOWN" ? COL_DN : COL_NEU
    color  bC5   = bias5 == "UP" ? COL_UP : bias5 == "DOWN" ? COL_DN : COL_NEU
    string strength = math.abs(pUp5 - 0.5) > 0.12 and qAvg > 45 ? "STRONG" : math.abs(pUp5 - 0.5) > 0.05 ? "LEAN" : "WEAK"

    // TODAY headline: overall next-day probability with meter
    string dayLine = wT > 0 ? "TODAY ▸ P(UP) next day: " + fw(pUp1) + "  " + meter(pUp1) + "  · Expected 1d: " + fr(er1) + " · " + bias1 : "TODAY ▸ No qualified events active — NEUTRAL (50%)  " + meter(0.5)
    table.cell(dash, 0, 2, dayLine, text_color = bC1, text_size = tszHead, bgcolor = color.new(#0f1a30, 0))

    table.cell(dash, 0, 22, "COMPOSITE " + meter(pUp5), text_color = COL_TTL, text_size = tsz, text_halign = text.align_left, bgcolor = COL_HD)
    table.cell(dash, 1, 22, str.tostring(nAct) + "●", text_color = COL_ACC, text_size = tsz, bgcolor = COL_HD)
    table.cell(dash, 2, 22, fw(pUp1), text_color = pUp1 > 0.5 ? COL_UP : COL_DN, text_size = tsz, bgcolor = COL_HD)
    table.cell(dash, 3, 22, fw(pUp3), text_color = pUp3 > 0.5 ? COL_UP : COL_DN, text_size = tsz, bgcolor = COL_HD)
    table.cell(dash, 4, 22, fw(pUp5), text_color = pUp5 > 0.5 ? COL_UP : COL_DN, text_size = tsz, bgcolor = COL_HD)
    table.cell(dash, 5, 22, "", bgcolor = COL_HD)
    table.cell(dash, 6, 22, fr(er5), text_color = er5 >= 0 ? COL_UP : COL_DN, text_size = tsz, bgcolor = COL_HD)
    table.cell(dash, 7, 22, strength, text_color = COL_TXT, text_size = tsz, bgcolor = COL_HD)
    table.cell(dash, 8, 22, str.tostring(qAvg, "#"), text_color = COL_ACC, text_size = tsz, bgcolor = COL_HD)
    table.cell(dash, 9, 22, bias5, text_color = bC5, text_size = tsz, bgcolor = COL_HD)

    float fp1 = close * (1 + er1)
    float fp3 = close * (1 + er3)
    float fp5 = close * (1 + er5)
    float up5 = close * (1 + er5 + sd5)
    float dn5 = close * (1 + er5 - sd5)

    table.cell(dash, 0, 23, "FORECAST", text_color = COL_TTL, text_size = tsz, text_halign = text.align_left)
    table.cell(dash, 1, 23, "", text_size = tsz)
    table.cell(dash, 2, 23, wT > 0 ? str.tostring(fp1, format.mintick) : "—", text_color = COL_TXT, text_size = tsz)
    table.cell(dash, 3, 23, wT > 0 ? str.tostring(fp3, format.mintick) : "—", text_color = COL_TXT, text_size = tsz)
    table.cell(dash, 4, 23, wT > 0 ? str.tostring(fp5, format.mintick) : "—", text_color = COL_TXT, text_size = tsz)
    table.cell(dash, 5, 23, "±1σ", text_color = COL_DIM, text_size = tsz)
    table.cell(dash, 6, 23, wT > 0 ? str.tostring(dn5, format.mintick) : "—", text_color = COL_DN, text_size = tsz)
    table.cell(dash, 7, 23, wT > 0 ? str.tostring(up5, format.mintick) : "—", text_color = COL_UP, text_size = tsz)
    table.cell(dash, 8, 23, "", text_size = tsz)
    table.cell(dash, 9, 23, "", text_size = tsz)

    table.cell(dash, 0, 24, "Shrunk win rates · Wilson bound (overlap-corrected) · ® = regime-conditional · designed for 1D", text_color = COL_DIM, text_size = size.tiny)

    // Chart drawings: wipe and redraw
    for ln in vizLn
        line.delete(ln)
    vizLn.clear()
    for lb in vizLb
        label.delete(lb)
    vizLb.clear()
    if not na(coneFill)
        linefill.delete(coneFill)

    // Forecast path + shaded cone
    if showCone and wT > 0
        int x0 = bar_index
        vizLn.push(line.new(x0, close, x0 + 1, fp1, xloc = xloc.bar_index, color = COL_ACC, width = 2))
        vizLn.push(line.new(x0 + 1, fp1, x0 + 3, fp3, xloc = xloc.bar_index, color = COL_ACC, width = 2))
        vizLn.push(line.new(x0 + 3, fp3, x0 + 5, fp5, xloc = xloc.bar_index, color = COL_ACC, width = 2))
        line upL = line.new(x0, close, x0 + 5, up5, xloc = xloc.bar_index, color = color.new(COL_UP, 45), style = line.style_dashed)
        line dnL = line.new(x0, close, x0 + 5, dn5, xloc = xloc.bar_index, color = color.new(COL_DN, 45), style = line.style_dashed)
        vizLn.push(upL)
        vizLn.push(dnL)
        coneFill := linefill.new(upL, dnL, color.new(COL_ACC, 88))
        vizLb.push(label.new(x0 + 5, fp5, "P(up) 1d: " + fw(pUp1) + "\nP(up) 5d: " + fw(pUp5) + "\n" + str.tostring(fp5, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#122038, 20), textcolor = bC5, size = size.small))

    // Live pivot support / resistance rails
    if showPiv
        if not na(lastPL)
            vizLn.push(line.new(bar_index - 40, lastPL, bar_index + 5, lastPL, xloc = xloc.bar_index, extend = extend.right, color = color.new(COL_UP, 45), style = line.style_dotted, width = 1))
            vizLb.push(label.new(bar_index + 5, lastPL, "Pivot S " + str.tostring(lastPL, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#122038, 40), textcolor = COL_UP, size = size.tiny))
        if not na(lastPH)
            vizLn.push(line.new(bar_index - 40, lastPH, bar_index + 5, lastPH, xloc = xloc.bar_index, extend = extend.right, color = color.new(COL_DN, 45), style = line.style_dotted, width = 1))
            vizLb.push(label.new(bar_index + 5, lastPH, "Pivot R " + str.tostring(lastPH, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(#122038, 40), textcolor = COL_DN, size = size.tiny))

    // Alert on composite bias change
    if barstate.isconfirmed and lastBias != "" and bias5 != lastBias
        alert("Event Probability Engine: composite bias changed to " + bias5 + " · P(up) 1d = " + fw(pUp1) + " · P(up) 5d = " + fw(pUp5) + " · " + syminfo.ticker, alert.freq_once_per_bar_close)
    lastBias := bias5
````
