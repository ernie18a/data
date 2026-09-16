<!-- tradingview-pine-id: PUB;a47c9e203549427689e600e69aed0e42 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Expansion Score (0-4) v2.4

Source: https://www.tradingview.com/script/r4ChVA9t-Volatility-Expansion-Score-0-4-v2-2-TotoMazter/

## Description

Volatility Expansion Score (0-4)

WHAT IT IS

This indicator detects one specific market state: a compressed market whose calm is starting to break. It scores every closed bar from 0 to 4, one point per condition:

Compressed regime — ATR% in the lower tercile of its own last 500 bars
Expansion starting — ATR% higher than on the previous bar
Narrow Bollinger Bands — band width in the lower tercile of its last 120 bars
Volume waking up — tick volume above its 100-bar mean (z-score > 0)

Score 3 (orange) is the signal threshold; score 4 (red) is a full trigger. Everything is self-normalized (rolling percentiles and z-scores, no absolute levels), so the indicator needs no recalibration across price regimes: in our research it behaved the same with gold at 1,800 and at 4,800.

WHAT IT DOES NOT DO — READ THIS FIRST

It does NOT predict direction. In the research program behind this script, the directional question was tested three separate ways on 14 years of XAUUSD minute data — 132 technical variables, a dedicated 40-feature study (intraday synthetic dollar index, gold/silver lead-lag, compression context, M1 microstructure, path features), and real aggressor order flow from COMEX gold futures — and all three came back null. A 4/4 score says "an impulse is more likely than usual", never which way. Any use of this tool as a bullish/bearish signal is outside what was validated.

It also does not promise big moves in dollar terms. The signal fires when ATR is compressed (about 0.83x its normal level), and the subsequent move measured in % of price is slightly SMALLER than average (about 0.97x). What increases is the move relative to current volatility. If you size stops and targets in ATR units (R multiples), the historical edge is real; if you think in dollars, there is none.

MEASURED RESULTS (all historical, XAUUSD 1h, 2013-2026, ~79,000 bars)

Out-of-sample validation on a pre-registered 2023-2026 holdout, opened once: bars with score >= 3 were followed by a 2-ATR impulse 1.95x more often than the base rate (95% CI 1.76-2.03). Score = 4: 2.73x (CI 2.09-2.94).
Honest base rates: with a ~5% base impulse rate, 2.7x lift means roughly 13-14% of full triggers are followed by an impulse. Most signals are NOT followed by a large move. Position sizing must assume this.
The follow-through advantage, measured in ATR units and controlled for time of day, is about x1.106, favorable in all 21 measurable hourly buckets and in 13 of 14 years. Without the time-of-day control the raw number is x1.139 — the control matters, and the built-in table applies it for you.
Where signals cluster on gold: the New York morning (13:00-15:00 UTC) and the London open (08:00-09:00 UTC). The most volatile hour of gold's day in this dataset is 14:00 UTC (about 1.8x the daily average hourly range).

STOCKS (NVDA, AMD, TSLA — high-volume, high-volatility test set)

The signal transfers, but with roughly half the strength: x1.04-1.08 in ATR units after the same time-of-day control (below 1 in dollar terms). Three structural rules came out of that validation and are enforced by the script's guards:

Do not use 5-minute charts: intraday volume is U-shaped and the signal degenerates into a closing-auction detector (a fake x1.68 "edge" came entirely from the last 30 minutes of the session).
Do not use 1-hour charts on RTH equities: the session's partial bar has a smaller range by construction and concentrates signals. The script excludes partial bars automatically (marked with a dot).
Use 15m or 30m, and keep the characterization horizon inside the session (H <= 12 on 15m, H <= 11 on 30m). Windows containing long closures (overnight gaps, weekends) are excluded by the gap guard.

Earnings are not the driver: excluding extreme-gap days does not change the result.

THE BUILT-IN CHARACTERIZATION TABLE

The table answers, for THE SYMBOL AND TIMEFRAME ON YOUR CHART, whether the signal has historically preceded larger moves, using three measures: raw MFE in ATR (inflated by the denominator and by time of day — reference only), MFE in % of price (immune to the denominator), and the intra-hour advantage (computed within each hour of day, then aggregated — the one that decides, highlighted in yellow). It also reports the ATR-at-signal ratio (~0.8 expected) and the maximum hourly concentration of signals (if it exceeds ~8 pp, part of what you see is the clock, not the market). If it says "short sample", the guards are refusing to output a number that cannot be measured cleanly on your chart — that is a feature.

WHY IT IS ORIGINAL

Rolling percentiles converted to the exact convention of pandas rolling rank, so the script reproduces the research module it was ported from (practical parity check: on XAUUSD 1h, score >= 3 should fire on roughly 17% of bars, score = 4 on roughly 3.7%).
Wilder ATR (RMA), population standard deviations, closed-bar evaluation with alerts on bar close, and an entry reference at the next bar's open — no repainting of the validated signal.
Session guards: partial-bar exclusion (any intraday bar shorter than its timeframe) and a data-measured gap guard (characterization windows may not contain a closure longer than 3x the timeframe), so equity overnight gaps and weekends do not contaminate the statistics while gold's 1-hour daily break does not block them.
A self-auditing characterization table with denominator-aware and time-of-day-controlled measures. It will happily tell you the signal does NOT work on your chart.

SETTINGS

Signal windows (14 / 500 / 120 / 100) and tercile cuts are the canonical values of the validated module; changing them invalidates every reference number above. "Confirm on bar close" keeps the indicator inside its validated definition. The alert message includes the score breakdown and states that the entry reference is the next bar's open. The characterization table can be displayed in English or Spanish via the "Table language" setting.

LIMITATIONS

All figures are historical measurements from the research program described above; past behavior does not guarantee future behavior. The stock characterization is in-sample (no reserved validation window). This is a statistical tool for regime awareness — when to pay attention — not a trading system: it provides no direction, no entries, and no risk management.

---

## Source Code

````pine
//@version=6
// =============================================================================
// VOLATILITY EXPANSION SCORE (0-4) — v2.2
// =============================================================================
// Faithful port of the validated research module (vol_expansion_signal.py).
// Validated on XAUUSD 1h: 1.95x lift for "will a 2-ATR impulse follow?"
// (train 2013-2022, 10/10 years; pre-registered holdout 2023-2026,
// 95% CI [1.76-2.03]). It does NOT predict direction (refuted three separate
// ways: 132 technical variables, a dedicated 40-feature study, and real
// aggressor order flow from COMEX gold futures).
//
// Measured references (intra-hour MFE edge, in ATR units):
//      XAUUSD 1h ........ x1.106   21/21 hourly buckets · 13/14 years
//      NVDA/AMD/TSLA .... x1.04-1.08 on 15m/30m · 5m and 1h ruled out
//
// v2 (2026-08-27) — lessons from the NVDA/AMD/TSLA validation:
//   1. The table also measures MFE in % OF PRICE (the signal selects low-ATR
//      bars, 0.79-0.88x, which inflates the ATR-denominated version).
//   2. The table controls FOR TIME OF DAY (on stocks the clock was ~65% of the
//      raw effect; on gold, ~3%).
//   3. Partial-bar and long-closure guards.
// v2.1 — two bugs fixed (partial bar = ANY intraday bar shorter than its
//   timeframe, since TV anchors bars to the session open; session guard
//   replaced by a data-measured gap guard) plus an arm-comparability fix.
// v2.1b — CE10156: table functions moved to global scope.
// v2.2 (2026-08-28) — full English UI for publication + table language
//   selector (English/Español). Pine has no locale API, so automatic language
//   detection is impossible; inputs/tooltips/alertconditions are compile-time
//   constants and stay in English. No logic changes.
// v2.3 (2026-08-29) — CRITICAL table fix, found on a live chart: in comma-
//   separated declarations (var int a = 0, b = 0) only the FIRST variable kept
//   `var` persistence; the rest re-initialized every bar. Effect: every "all"
//   column of the table showed one-bar values (e.g. n=1, "296200% of total")
//   while "signal" columns were fine, making all edge ratios except the
//   intra-hour row (array-based, unaffected) meaningless. Present since v2.
//   Fix: one declaration per line. If you used v2.0-v2.2, ignore any table
//   number you saw except the intra-hour edge row.
// v2.3b (2026-08-29) — diagnostic reason in the table when there are no
//   measurable bars: distinguishes a feed without volume data (the signal
//   requires tick volume and stays na without it), an insufficient warm-up
//   history (505 bars + horizon), and a genuinely short sample. Found when a
//   feed switch (no volume on the new symbol) silently blanked everything.
// v2.4 (2026-08-30) — user-configurable colors (score histogram, trigger
//   marker, threshold line, table) with the original palette as defaults.
//   No changes to signal logic or table math.
//
// Parity pending vs the Python module: stdev ddof (population here),
// percentrank tie handling, RMA seed. Practical check: on XAUUSD 1h,
// score >= 3 should fire on ~17% of bars and score = 4 on ~3.7%.
// =============================================================================

indicator("Volatility Expansion Score (0-4) v2.4", shorttitle="VOL-EXP", overlay=false)

// ------------------------------------------------------------------- inputs
grpS = "Signal (canonical values of the validated module)"
atrLen   = input.int(14,  "ATR length", minval=2, group=grpS)
bbLen    = input.int(20,  "Bollinger: length", minval=2, group=grpS)
bbMult   = input.float(2.0, "Bollinger: std devs", group=grpS)
bbPctWin = input.int(120, "BB width percentile window", minval=10, group=grpS)
regWin   = input.int(500, "ATR regime window", minval=20, group=grpS)
volZWin  = input.int(100, "Volume z-score window", minval=10, group=grpS)
qReg     = input.float(0.3333333, "Compressed-regime cut", step=0.01, group=grpS)
qBbw     = input.float(0.3333333, "Narrow-bands cut", step=0.01, group=grpS)

grpA = "Alerts"
scoreMin  = input.int(3, "Minimum score to alert", minval=1, maxval=4, group=grpA)
confirmar = input.bool(true, "Confirm on bar close (recommended)", group=grpA,
     tooltip="The signal is defined on the closed bar. Turning this off makes the " +
             "score flicker intrabar and is no longer the validated signal.")

grpG = "Guards (essential on stocks; harmless on 24h markets)"
sinParcial = input.bool(true, "Do not fire on partial bars", group=grpG,
     tooltip="Any intraday bar shorter than its timeframe. On RTH equities the last " +
             "1h bar lasts 30 min (TV anchors bars to the session open): its range is " +
             "smaller by arithmetic and it overlaps the closing auction. Also covers " +
             "half days and early closes.")
sinHueco = input.bool(true, "Horizon must not cross long closures", group=grpG,
     tooltip="Excludes from the characterization any window containing a closure " +
             "longer than N x the timeframe: equity overnights (17.5h) and weekends " +
             "(49h) are out; gold's 1-hour daily break is in. Without this, the " +
             "overnight gap dominates the measure (x1.25 -> x0.96 in the stocks " +
             "validation).")
gapMult = input.int(3, "A closure counts as a gap above N x timeframe",
     minval=2, maxval=12, group=grpG)

grpC = "Characterization"
verTabla = input.bool(true, "Show table", group=grpC)
H        = input.int(24, "Horizon in bars", minval=2, maxval=200, group=grpC,
     tooltip="Gold 1h: 24. Stocks: keep the window inside the session — " +
             "H <= 12 on 15m, H <= 11 on 30m.")
minHora  = input.int(30, "Minimum signals per hourly bucket", minval=5, group=grpC,
     tooltip="Buckets with fewer signals than this are excluded from the intra-hour " +
             "control.")
idioma   = input.string("English", "Table language / Idioma de la tabla",
     options=["English", "Español"], group=grpC)

grpK = "Colors"
colS4  = input.color(color.new(color.red, 0),     "Score 4", group=grpK, inline="cs")
colS3  = input.color(color.new(color.orange, 15), "3", group=grpK, inline="cs")
colS2  = input.color(color.new(color.blue, 55),   "2", group=grpK, inline="cs")
colS01 = input.color(color.new(color.gray, 70),   "0-1", group=grpK, inline="cs")
colTrig = input.color(color.new(color.red, 0),    "Trigger marker", group=grpK, inline="ct")
colThr  = input.color(color.new(color.red, 50),   "Threshold line", group=grpK, inline="ct")
colTblHead = input.color(color.new(color.black, 25), "Table: header", group=grpK, inline="cta")
colTblBody = input.color(color.new(color.black, 60), "body", group=grpK, inline="cta")
colTblText = input.color(color.white,  "Table: text", group=grpK, inline="ctb")
colTblHi   = input.color(color.yellow, "highlight", group=grpK, inline="ctb")

// ---------------------------------------------------------------- indicators
tr  = ta.tr(true)
atr = ta.rma(tr, atrLen)              // Wilder RMA. NOT ta.ema.
atrPct = close > 0 ? atr / close : na

// Rolling percentile with the pandas .rolling(N).rank(pct=True) convention.
pctRankPandas(src, N) =>
    pr = ta.percentrank(src, N - 1)
    na(pr) ? na : (pr / 100.0 * (N - 1) + 1.0) / N

atrPctRegimen = pctRankPandas(atrPct, regWin)
basis    = ta.sma(close, bbLen)
dev      = ta.stdev(close, bbLen, true)      // population = ddof 0 (verify vs .py)
bbWidth  = basis != 0 ? (2.0 * bbMult * dev) / basis : na
bbPctile = pctRankPandas(bbWidth, bbPctWin)
volMean  = ta.sma(volume, volZWin)
volSd    = ta.stdev(volume, volZWin, true)
volZ     = volSd > 0 ? (volume - volMean) / volSd : na
var bool volSeen = false
volSeen := volSeen or (not na(volume) and volume > 0)

// -------------------------------------------------------------------- score
warmup = math.max(regWin, bbPctWin, 200) + 5
listo  = bar_index >= warmup and not na(atrPctRegimen) and not na(bbPctile) and not na(volZ)

c1 = atrPctRegimen < qReg
c2 = atrPct - atrPct[1] > 0
c3 = bbPctile < qBbw
c4 = volZ > 0
scoreRaw = listo ? (c1 ? 1 : 0) + (c2 ? 1 : 0) + (c3 ? 1 : 0) + (c4 ? 1 : 0) : na

// Guard: partial = any intraday bar shorter than its timeframe. TV anchors bars
// to the session open, so on RTH equities the partial bar is the LAST of the
// session, not the first.
esParcial = timeframe.isintraday and (time_close - time) < timeframe.in_seconds() * 1000
barraValida = not (sinParcial and esParcial)
score   = barraValida ? scoreRaw : na
dispara = listo and barraValida and score >= scoreMin

// ----------------------------------------------------------------- plotting
col = na(score) ? color.new(color.gray, 80) :
      score == 4 ? colS4 :
      score == 3 ? colS3 :
      score == 2 ? colS2 : colS01
plot(score, "score", color=col, style=plot.style_columns, linewidth=3)
hline(scoreMin, "threshold", color=colThr, linestyle=hline.style_dashed)
plotshape(dispara and (not confirmar or barstate.isconfirmed) and not dispara[1],
     "first trigger", shape.triangleup, location.bottom,
     color=colTrig, size=size.tiny)
plotchar(esParcial and sinParcial and listo, "partial bar excluded", "·",
     location.top, color=color.new(color.gray, 40), size=size.tiny)

// ------------------------------------------------------------ dynamic alerts
msg = str.format("VOL-EXP {0} {1} · score {2}/4 · entry reference: next bar open · " +
     "ATR {3} · compressed:{4} expanding:{5} bands:{6} volume:{7}",
     syminfo.ticker, timeframe.period, str.tostring(score),
     str.tostring(atr, format.mintick),
     c1 ? "y" : "n", c2 ? "y" : "n", c3 ? "y" : "n", c4 ? "y" : "n")
if dispara and (not confirmar or barstate.isconfirmed)
    alert(msg, alert.freq_once_per_bar_close)

alertcondition(score >= 3, "Score >= 3",
     "Volatility expansion: score >= 3. Entry reference: next bar open. No direction implied.")
alertcondition(score == 4, "Score == 4 (full trigger)",
     "Volatility expansion: all 4 conditions met. Entry reference: next bar open. No direction implied.")

// =============================================================================
// CHARACTERIZATION — does the signal precede larger moves ON THIS symbol?
// =============================================================================
// Three measures; the third one decides:
//   raw, in ATR      -> inflated by the denominator AND by time of day
//   in % of price    -> immune to the denominator; moves more in money terms?
//   intra-hour       -> controls time of day; comparable with the references

// Gap guard: bars since the last long closure. A window of H bars may not
// contain a closure longer than gapMult x the timeframe.
cierreMs = time - nz(time_close[1], time)
esHueco  = timeframe.isintraday and cierreMs > gapMult * timeframe.in_seconds() * 1000
var int desdeHueco = 0
desdeHueco := esHueco ? 0 : desdeHueco + 1
ventanaLimpia = not sinHueco or desdeHueco >= H - 1

entrada = open[H - 1]
atrRef  = atr[H]
mfeUp   = atrRef > 0 ? (ta.highest(high, H) - entrada) / atrRef : na
mfeDn   = atrRef > 0 ? (entrada - ta.lowest(low, H)) / atrRef : na
mfeMax  = math.max(mfeUp, mfeDn)
mfeUpPct = entrada > 0 ? (ta.highest(high, H) - entrada) / entrada * 100 : na
mfeDnPct = entrada > 0 ? (entrada - ta.lowest(low, H)) / entrada * 100 : na

// Both arms share the same universe: t0-1 must have a defined score.
t0Valido  = not na(score[H])
huboSenal = t0Valido and score[H] >= scoreMin
medible   = not na(mfeUp) and not na(mfeDn) and not na(atrRef) and t0Valido and
     barstate.isconfirmed and ventanaLimpia

var int   nSig = 0
var int   nAll = 0
var float sSigUp = 0.0
var float sAllUp = 0.0
var float sSigDn = 0.0
var float sAllDn = 0.0
var float sSigUpP = 0.0
var float sAllUpP = 0.0
var float sSigAtr = 0.0
var float sAllAtr = 0.0
var int   nSig2 = 0
var int   nAll2 = 0
var int   nSig4 = 0
var int   nAll4 = 0

// Per-hour accumulators (0-23) for the intra-hour control.
var array<float> hSigSum = array.new_float(24, 0.0)
var array<float> hAllSum = array.new_float(24, 0.0)
var array<int>   hSigN   = array.new_int(24, 0)
var array<int>   hAllN   = array.new_int(24, 0)
var array<float> hSigSumP = array.new_float(24, 0.0)
var array<float> hAllSumP = array.new_float(24, 0.0)

if medible
    hr = hour(time[H], syminfo.timezone)         // hour of the triggering bar
    nAll += 1
    sAllUp += mfeUp
    sAllDn += mfeDn
    sAllUpP += mfeUpPct
    sAllAtr += atrRef
    nAll2 += mfeMax >= 2.0 ? 1 : 0
    nAll4 += mfeMax >= 4.0 ? 1 : 0
    array.set(hAllSum, hr, array.get(hAllSum, hr) + mfeUp)
    array.set(hAllSumP, hr, array.get(hAllSumP, hr) + mfeUpPct)
    array.set(hAllN, hr, array.get(hAllN, hr) + 1)
    if huboSenal
        nSig += 1
        sSigUp += mfeUp
        sSigDn += mfeDn
        sSigUpP += mfeUpPct
        sSigAtr += atrRef
        nSig2 += mfeMax >= 2.0 ? 1 : 0
        nSig4 += mfeMax >= 4.0 ? 1 : 0
        array.set(hSigSum, hr, array.get(hSigSum, hr) + mfeUp)
        array.set(hSigSumP, hr, array.get(hSigSumP, hr) + mfeUpPct)
        array.set(hSigN, hr, array.get(hSigN, hr) + 1)

// Intra-hour edge: computed within each hour of day, then aggregated weighting
// by signal count. Removes the time-of-day confound at the root.
f_intrahour(sumSig, nSigA, sumAll, nAllA) =>
    float num = 0.0
    float den = 0.0
    int fav = 0
    int tot = 0
    for i = 0 to 23
        ns = array.get(nSigA, i)
        na_ = array.get(nAllA, i)
        if ns >= minHora and na_ >= minHora * 4
            v = (array.get(sumSig, i) / ns) / (array.get(sumAll, i) / na_)
            num := num + v * ns
            den := den + ns
            tot := tot + 1
            fav := fav + (v > 1 ? 1 : 0)
    [den > 0 ? num / den : na, fav, tot]

f_pct(a, b) => b > 0 ? str.tostring(a / b * 100, "#.0") + "%" : "—"
f_x(a, b)   => b > 0 and a > 0 ? "x" + str.tostring(a / b, "#.000") : "—"

// Table language: runtime-selectable strings (Pine has no locale detection;
// inputs/tooltips/alertconditions are compile-time constants and stay English).
f_txt(string en, string es) => idioma == "Español" ? es : en

var table t = table.new(position.top_right, 4, 11, border_width=1)
TBL_BG  = colTblHead
TBL_BG2 = colTblBody

f_hdr(int c, string txt) =>
    table.cell(t, c, 0, txt, text_color=colTblText, bgcolor=TBL_BG, text_size=size.small)

f_fila(int r, string etq, string v1, string v2, string v3, bool resalta) =>
    table.cell(t, 0, r, etq, text_size=size.small,
         text_color=resalta ? colTblHi : colTblText, bgcolor=TBL_BG2)
    table.cell(t, 1, r, v1, text_size=size.small, text_color=colTblText, bgcolor=TBL_BG2)
    table.cell(t, 2, r, v2, text_size=size.small, text_color=colTblText, bgcolor=TBL_BG2)
    table.cell(t, 3, r, v3, text_size=size.small,
         text_color=resalta ? colTblHi : colTblText, bgcolor=TBL_BG2)

if verTabla and barstate.islast
    [vIntra, favIntra, totIntra] = f_intrahour(hSigSum, hSigN, hAllSum, hAllN)
    [vIntraP, _f, _t] = f_intrahour(hSigSumP, hSigN, hAllSumP, hAllN)
    // hourly concentration: excess of the most over-represented bucket
    float excesoMax = 0.0
    for i = 0 to 23
        if array.get(hAllN, i) > 0 and nSig > 0 and nAll > 0
            e = array.get(hSigN, i) / nSig * 100 - array.get(hAllN, i) / nAll * 100
            excesoMax := math.max(excesoMax, e)

    f_hdr(0, f_txt("Characterization · H=", "Caracterización · H=") + str.tostring(H))
    f_hdr(1, f_txt("signal", "señal"))
    f_hdr(2, f_txt("all", "todas"))
    f_hdr(3, f_txt("edge", "ventaja"))

    f_fila(1, f_txt("n events", "n eventos"), str.tostring(nSig), str.tostring(nAll),
         f_pct(nSig, nAll) + f_txt(" of total", " del total"), false)
    f_fila(2, f_txt("Bullish MFE (ATR) — raw", "MFE alcista (ATR) — bruta"),
         nSig > 0 ? str.tostring(sSigUp / nSig, "#.00") : "—",
         nAll > 0 ? str.tostring(sAllUp / nAll, "#.00") : "—",
         f_x(sSigUp / math.max(nSig, 1), sAllUp / math.max(nAll, 1)), false)
    f_fila(3, f_txt("MFE in % of price", "MFE en % de precio"),
         nSig > 0 ? str.tostring(sSigUpP / nSig, "#.000") + "%" : "—",
         nAll > 0 ? str.tostring(sAllUpP / nAll, "#.000") + "%" : "—",
         f_x(sSigUpP / math.max(nSig, 1), sAllUpP / math.max(nAll, 1)), false)
    string motivo = f_txt("short sample", "muestra corta")
    if nAll == 0
        if not volSeen
            motivo := f_txt("feed has no volume data", "este feed no da volumen")
        else if bar_index + 1 < warmup + H
            motivo := f_txt("warming up: ", "calentando: ") + str.tostring(bar_index + 1) +
                 "/" + str.tostring(warmup + H) + f_txt(" bars", " barras")
        else
            motivo := f_txt("no measurable bars", "sin barras medibles")
    f_fila(4, f_txt("► INTRA-HOUR EDGE (ATR)", "► VENTAJA INTRA-FRANJA (ATR)"), "—", "—",
         na(vIntra) ? motivo :
         "x" + str.tostring(vIntra, "#.000") + "  (" + str.tostring(favIntra) + "/" +
         str.tostring(totIntra) + ")", true)
    f_fila(5, f_txt("  same, in % of price", "  ídem, en % de precio"), "—", "—",
         na(vIntraP) ? "—" : "x" + str.tostring(vIntraP, "#.000"), false)
    f_fila(6, f_txt("ATR signal / base  (denominator)", "ATR señal / base  (denominador)"),
         nSig > 0 ? str.tostring(sSigAtr / nSig, format.mintick) : "—",
         nAll > 0 ? str.tostring(sAllAtr / nAll, format.mintick) : "—",
         f_x(sSigAtr / math.max(nSig, 1), sAllAtr / math.max(nAll, 1)), false)
    f_fila(7, f_txt("% with MFE >= 2 ATR (ATR metric)", "% con MFE >= 2 ATR (métrica en ATR)"),
         f_pct(nSig2, nSig), f_pct(nAll2, nAll),
         f_txt("see denominator row", "ver fila denominador"), false)
    f_fila(8, f_txt("% with MFE >= 4 ATR (ATR metric)", "% con MFE >= 4 ATR (métrica en ATR)"),
         f_pct(nSig4, nSig), f_pct(nAll4, nAll),
         f_txt("see denominator row", "ver fila denominador"), false)
    f_fila(9, f_txt("bullish/bearish symmetry", "simetría alcista/bajista"),
         nSig > 0 and sSigDn > 0 ? str.tostring(sSigUp / sSigDn, "#.000") : "—",
         nAll > 0 and sAllDn > 0 ? str.tostring(sAllUp / sAllDn, "#.000") : "—",
         f_txt("1.00 = no bias", "1,00 = sin sesgo"), false)
    f_fila(10, f_txt("max hourly concentration", "concentración horaria máx."), "—", "—",
         "+" + str.tostring(excesoMax, "#.0") + " pp", excesoMax > 8)
````
