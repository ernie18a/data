# Candlestick Edge  Auto-Preset  MTF  Self-Calibrating

- url: https://www.tradingview.com/script/KUzvgHd9-Candlestick-Edge-Auto-Preset-MTF-Self-Calibrating/
- type: indicator
- pine_id: PUB;07300a2472494a5698aeb929888711d1
- version: 3.0

## Description

Candlestick Edge only fires a candlestick pattern when it is "rightly placed" — confirmed by a higher-timeframe trend AND by where price sits in the developing volume profile. Then it does what most pattern tools don't: it forward-tests every signal and reports the MEASURED edge per pattern, so you read realized performance instead of a marketing claim.

WHY THIS IS ONE TOOL (not a bundle)

The parts answer one question about one candle: "is this pattern in a place that has historically paid, and does it beat a coin-flip here?"

PATTERN detection says WHAT printed (24 classic candlestick patterns).
HTF ALIGNMENT says whether the bigger trend agrees.
VOLUME-PROFILE POSITIONING says WHERE it printed — reversals only at value-area edges, naked POC, HVN support/resistance, or liquidity sweeps; continuations only through low-volume voids or on a value breakout.

The CALIBRATION SPINE forward-resolves each signal with a triple barrier and reports Hit% vs a matched Base% (Edge) with a Wilson confidence interval, so a placed-and-confirmed pattern can be told apart from a small-sample fluke.
One pattern substrate, one location read, one calibration spine.

MEASUREMENT (the differentiator)

Each signal opens at close with target = ±TP·ATR, stop = ∓SL·ATR, over a fixed horizon. The first barrier touched decides win/loss (same-bar tie counts as the stop — conservative). Base% is the unconditional same-barrier win-rate for that direction. Edge = Hit% − Base%; a "*" marks rows whose Wilson 95% lower bound clears the base rate. A leave-one-out row prices each filter's marginal contribution, and a footer lists only the patterns that are green AND have enough samples to trust in the current configuration.

AUTO PRESET (default on)

Candlestick edges are timeframe-specific. Auto Preset reads the chart's timeframe and switches on the pattern subset plus higher-timeframe distance that performed best for that timeframe in the author's study of NSE index futures, and forces the two filters on. Turn it OFF for full manual research mode: all 24 patterns selectable, filters and HTF distance (3x / 5x / 15x / custom) under your control. Nothing is ever removed — the preset only curates which patterns are active by default per timeframe.

HOW TO USE

Leave Auto Preset on and read the labelled signals (teal = bullish, red = bearish, each tagged with the pattern name). Open "Show scoreboard" to see measured Edge per pattern — trust the EDGE column and the "*", never a raw hit-rate. Best behaviour is on intraday timeframes (1H and below).

ORIGINALITY

Standard techniques are credited below. What is original is the combination: a location-gated pattern engine whose every signal is forward-calibrated, a timeframe-adaptive auto-preset, a leave-one-out filter attribution, and an auto-surfaced tradeable set — measured edge, not asserted.

NON-REPAINT

Signals open on confirmed bars; triple-barrier outcomes resolve on bars AFTER the trigger; all higher-timeframe / lower-timeframe / prior-day-POC requests use lookahead_off and confirmed intrabars. Pivots used by sweeps confirm first.

DATA & MARKETS

Runs on any symbol that reports volume; the developing profile needs volume to be meaningful. Defaults are tuned for intraday index futures. On the Enhanced data tier the delta read uses intrabar aggregation (richer on paid plans) and auto-falls-back to an OHLCV proxy when intrabars aren't served — safe to leave on for any plan.

CONCEPT CREDITS (methods operationalized — original Pine re-derivations)

Candlestick patterns — Nison; pattern-performance framing per Bulkowski
Market / auction profile, POC / Value Area — Steidlmayer; Dalton
Bulk Volume Classification — Easley, Lopez de Prado & O'Hara (2012)
Triple-barrier labelling — Lopez de Prado
Wilson score interval — Wilson (1927)

HONESTY / LIMITS

The profile is an ATR-binned developing session profile (not tick POC). Delta is an estimate (proxy or intrabar reconstruction), not true bid/ask. Reported edge is context measured on loaded history — not a prediction or a promise. The preset defaults were tuned on one instrument over a recent window, so treat them as a well-measured hypothesis, not proven alpha.

Educational tool. Not financial advice — you alone are responsible for your trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
//  CANDLESTICK EDGE — Auto-Preset · MTF · Self-Calibrating                     v1.2
//  v1.2 — Correctness + house-standard finish:
//         • Hoisted stateful ta.lowest / ta.highest out of the `ready and …` guard so they run on
//           every bar (Pine requirement for series functions; clears CW10004).
//         • Added the MPL-2.0 licence header.
//         • Added an adaptive dark/light theme driven by chart.bg_color — the scoreboard stays
//           legible on either background.
//         • Added an EXP_ Data-Window export bus (signal, regime, HTF bias, delta, CVD, POC/VAH/VAL).
//         • Added a round-trip COST model: a Net-R column and a cost-gated tradeable footer, because
//           a gross win-rate edge that does not survive costs is not tradeable.
// ──────────────────────────────────────────────────────────────────────────────
//  WHAT THIS IS
//    A candlestick-pattern engine that does two things most pattern tools don't:
//    (1) it only fires a pattern when it is "rightly placed" — confirmed by a
//    higher-timeframe trend and by where price sits in the volume profile — and
//    (2) it FORWARD-TESTS every signal it emits and reports the MEASURED edge per
//    pattern, so you read realized performance instead of a marketing claim.
//
//  WHY THIS IS ONE TOOL, NOT A BUNDLE (component rationale)
//    The parts are not independent indicators stacked for show — they answer one
//    question about one candle: "is this pattern in a place that has historically
//    paid, and does it beat a coin-flip here?"
//      • PATTERN detection says WHAT printed (26 candlestick patterns: 24 classic
//        plus 2 research-added bullish reversals — Inverted Hammer, Black Paper
//        Umbrella — measured, not assumed).
//      • HTF ALIGNMENT says whether the bigger trend agrees.
//      • VOLUME-PROFILE POSITIONING says WHERE it printed — reversals only at
//        value-area edges / naked POC / HVN support-resistance / liquidity sweeps;
//        continuations only through low-volume voids or breaking value.
//      • The CALIBRATION SPINE forward-resolves each signal with a triple barrier
//        and reports Hit% vs a matched Base% (Edge) with a Wilson interval, so a
//        placed-and-confirmed pattern can be told apart from a small-sample fluke.
//      One pattern substrate, one location read, one calibration spine.
//
//  AUTO PRESET (default ON)
//    Candlestick edges are timeframe-specific. Auto Preset reads the chart's
//    timeframe and switches on the pattern subset + higher-timeframe distance that
//    scored best for that timeframe in the author's forward-test on NSE index
//    futures, and forces all three filters on. Turn it OFF for full manual research
//    mode: all 26 patterns selectable, filters and HTF distance under your control.
//    Every pattern stays in the code either way — the preset only curates which are
//    active by default per timeframe; nothing is removed. The curated set is a
//    description of one measured sample, NOT a guarantee of future performance —
//    validate out-of-sample before trading it.
//
//  MEASUREMENT (the differentiator)
//    Each signal opens at close with target = ±TP·ATR, stop = ∓SL·ATR, horizon = H
//    bars. The first barrier touched decides win/loss (same-bar tie counts as the
//    stop — conservative). Base% is the UNCONDITIONAL same-barrier win-rate for that
//    direction, sampled continuously. Edge = Hit% − Base%; "*" marks rows whose
//    Wilson 95% lower bound clears the base rate. A leave-one-out row prices each
//    filter's marginal contribution, and a footer lists only the patterns that are
//    green AND have enough samples to trust in the current configuration.
//
//  HOW TO USE
//    Leave Auto Preset on and read the labelled signals on the chart (teal = bull,
//    red = bear, each tagged with the pattern name). Open the scoreboard (Show
//    scoreboard) to see measured Edge per pattern; trust the EDGE column and the
//    "*", never a raw hit-rate. Best behaviour is on intraday timeframes (≤ 1H).
//
//  ORIGINALITY
//    Standard techniques are credited below. What is original here is the
//    combination: a location-gated pattern engine whose every signal is
//    forward-calibrated, a timeframe-adaptive auto-preset, a leave-one-out filter
//    attribution, and an auto-surfaced tradeable set — measured edge, not asserted.
//
//  NON-REPAINT
//    Signals open on CONFIRMED bars; triple-barrier outcomes resolve on bars AFTER
//    the trigger; higher-timeframe / lower-timeframe / prior-day-POC requests use
//    lookahead_off and confirmed intrabars. The intrabar request is issued on every
//    bar (not inside a branch) for a consistent series. Pivots used by sweeps
//    confirm first (pivotLen bars each side).
//
//  DATA & MARKETS
//    Runs on any symbol that reports volume; the developing profile needs volume to
//    be meaningful. Defaults are tuned for intraday index futures. On the Enhanced
//    data tier the delta read uses intrabar aggregation (richer on paid plans) and
//    AUTO-FALLS-BACK to an OHLCV proxy when intrabars aren't served — safe to leave
//    on for any plan.
//
//  CONCEPT CREDITS (methods operationalized — original Pine re-derivations)
//    Candlestick patterns .......... Nison; pattern performance framing per Bulkowski
//    Inverted Hammer / umbrella lines  Nison (single-bar reversal geometry)
//    Market / auction profile ...... Steidlmayer (POC / Value Area); Dalton
//    Bulk Volume Classification .... Easley, Lopez de Prado & O'Hara (2012)
//    Triple-barrier labelling ...... Lopez de Prado
//    Wilson score interval ......... Wilson (1927)
//
//  HONESTY / LIMITS
//    The profile is an ATR-binned DEVELOPING session profile (not tick POC). Delta
//    is an ESTIMATE (proxy or intrabar reconstruction), not true bid/ask. Reported
//    edge is CONTEXT measured on loaded history — not a prediction or a promise.
//    Educational tooling. Not financial advice; you alone are responsible for your
//    trading decisions.
// ══════════════════════════════════════════════════════════════════════════════

indicator("Candlestick Edge — Auto-Preset · MTF · Self-Calibrating", shorttitle = "Candle Edge", overlay = true,
     max_bars_back = 1000, max_labels_count = 500, max_lines_count = 60)


// ─────────────────────────────── INPUTS ──────────────────────────────────────
gPre = "0) Auto preset"
autoPreset = input.bool(true, "Auto preset: trade the winners for THIS timeframe", group = gPre, tooltip = "ON = overrides pattern selection + HTF with the per-timeframe winning set from the author's NSE index-futures study, and forces all filters on. OFF = manual research mode using the toggles below.")

gF = "1) Filters  (all off = plain candlesticks)"
useHTF = input.bool(true,  "HTF alignment filter",      group = gF)
useVP  = input.bool(true,  "Volume-profile positioning", group = gF)
useOF  = input.bool(true,  "Order-flow (delta) filter",  group = gF)
regimeMode = input.string("Both", "Market regime (gates the WHOLE scoreboard)", options = ["Both", "Calm only", "Panic only"], group = gF, tooltip = "Restricts every signal AND the base-rate sample AND the filter-lift attribution to one regime, so the main Edge column, the '*' significance, the lift row and the tradeable footer all speak for that regime alone. Workflow: set Calm only (or Panic only), then sweep HTF basis 3x -> 5x -> 15x and read the scoreboard each time — that gives a clean per-regime x per-HTF edge for every pattern. 'Both' = original pooled behaviour. Independent of the preset. Panic = ATR percentrank >= the '9) Regime tag' percentile.")

gT = "2) Data tier"
dataTier = input.string("Enhanced (intrabar · paid)", "Delta accuracy",
     options = ["Standard (all plans)", "Enhanced (intrabar · paid)"], group = gT)
ltf = input.timeframe("1", "Intrabar timeframe (Enhanced)", group = gT)

gH = "3) HTF alignment"
htfBasis  = input.string("3x chart", "HTF basis", options = ["3x chart", "5x chart", "15x chart", "Custom TF"], group = gH)
htfCustom = input.timeframe("D", "  Custom HTF (used only if basis = Custom TF)", group = gH)
htfEmaLen = input.int(20, "HTF trend EMA", minval = 2, group = gH)
useSlope  = input.bool(true, "Require HTF EMA slope to agree", group = gH)

gP = "4) Volume profile (developing, session)"
nBins     = input.int(48, "Profile bins", minval = 12, maxval = 120, group = gP)
rangeMult = input.float(2.5, "Half-span = daily ATR ×", minval = 0.5, group = gP)
tolATR    = input.float(0.15, "POC/VA proximity (× ATR)", minval = 0.02, group = gP)
hvnFactor = input.float(1.5, "HVN = bin vol > mean ×", minval = 1.0, group = gP)
lvnFactor = input.float(0.5, "LVN = bin vol < mean ×", minval = 0.05, group = gP)
showProf  = input.bool(false, "Plot POC / VAH / VAL", group = gP)

gO = "5) Order flow / sweeps"
divLen    = input.int(10, "CVD divergence lookback", minval = 3, group = gO)
pivotLen  = input.int(5, "Swing pivot length", minval = 2, group = gO)
spikeMult = input.float(1.3, "Volume-spike × SMA", minval = 1.0, group = gO)
reqSweep  = input.bool(false, "VP reversals require a sweep", group = gO)

gPat = "6) Patterns"
enHammer = input.bool(true, "Hammer / Shooting Star", group = gPat)
enEng    = input.bool(true, "Bull / Bear Engulfing",  group = gPat)
enStar   = input.bool(true, "Morning / Evening Star",  group = gPat)
enPierce = input.bool(true, "Piercing / Dark Cloud",   group = gPat)
enHar    = input.bool(true, "Harami (break)",          group = gPat)
enWin    = input.bool(true, "Rising / Falling Window",  group = gPat)
enMar    = input.bool(true, "Bull / Bear Marubozu",    group = gPat)
enTLS    = input.bool(true, "Three-Line Strike (rare, 84%)",     group = gPat)
enTWS    = input.bool(true, "Three Soldiers / Crows (82/78%)",   group = gPat)
enAB     = input.bool(true, "Abandoned Baby (rare, 70%)",        group = gPat)
enGap    = input.bool(true, "Two White / Black Gapping (68%)",   group = gPat)
enMat    = input.bool(true, "Mat Hold (continuation)",           group = gPat)
enBPU    = input.bool(true, "Black Paper Umbrella (bullish · red-body hammer)", group = gPat, tooltip = "Research add (2025): a hammer-shaped candle with a BLACK/red body, fired LONG. Measured statistically-significant but small returns in the literature. Overlaps Hammer when a hammer prints red — keep only one of the two on if you want clean, non-double-counted samples.")
enInvH   = input.bool(true, "Inverted Hammer (bullish)",         group = gPat, tooltip = "Research add: shooting-star geometry (long upper wick) but fired LONG in a bullish context. The bullish bottom-reversal twin of Shooting Star; context (HTF up + VP support) decides which side fires.")

gSh = "7) Pattern shape tolerances"
wickMult = input.float(2.0, "Hammer/Star wick / body",  group = gSh)
smWick   = input.float(0.5, "Opposite wick / body max", group = gSh)
maruWick = input.float(0.10,"Marubozu wick / body max", group = gSh)
starMax  = input.float(0.5, "Star middle / prior body", group = gSh)
bodyLen  = input.int(14, "Avg-body length", group = gSh)

gC = "8) Calibration"
horizon   = input.int(20, "Horizon (bars)", minval = 3, group = gC)
tpATR     = input.float(1.5, "Target = ATR ×", minval = 0.2, group = gC)
slATR     = input.float(1.0, "Stop = ATR ×", minval = 0.2, group = gC)
baseStride= input.int(5, "Base-rate sample every N bars", minval = 1, group = gC)
minN      = input.int(8, "Min N to trust a row", minval = 1, group = gC)
costR     = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gC, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) expressed in R — i.e. as a fraction of the trade's risk (Stop × ATR). The Net R column and the 'TRADEABLE after cost' footer subtract this from each pattern's gross R. On 1m NIFTY futures round-trip costs eat a large share of R, so a gross win-rate edge that does not survive them is not tradeable. Set to your own measured per-trade cost.")
showTable = input.bool(false, "Show scoreboard", group = gC)

gReg = "9) Regime tag (research)"
volLen   = input.int(200, "Volatility lookback (bars)", minval = 20, group = gReg)
volPctl  = input.float(60, "Panic = ATR percentile ≥", minval = 50, maxval = 95, group = gReg)
trendLen = input.int(50, "Trend EMA length", minval = 5, group = gReg)

// ─────────────────────────────── CONTEXT ─────────────────────────────────────
atr   = ta.atr(14)
dATR  = request.security(syminfo.tickerid, "D", ta.atr(14), lookahead = barmerge.lookahead_off)
dATRv = na(dATR) ? atr : dATR
newDay = nz(ta.change(time("D")), 0) != 0
ready  = bar_index > math.max(bodyLen, divLen) + pivotLen * 2 + 5
// regime tag: 0 Calm-Down, 1 Calm-Up, 2 Panic-Down, 3 Panic-Up
volHigh = nz(ta.percentrank(atr, volLen), 50) >= volPctl
trendUp = close > ta.ema(close, trendLen)
regIdx  = (volHigh ? 2 : 0) + (trendUp ? 1 : 0)
calmOK  = regimeMode == "Both" or (regimeMode == "Calm only" and not volHigh) or (regimeMode == "Panic only" and volHigh)

// ── AUTO PRESET: per-timeframe winners (author study, NSE index futures) ──
sSec_ = timeframe.in_seconds()
is1m  = sSec_ <= 90
is2m  = sSec_ > 90   and sSec_ <= 150
is3m  = sSec_ > 150  and sSec_ <= 240
is5m  = sSec_ > 240  and sSec_ <= 420
is15m = sSec_ > 420  and sSec_ <= 1200
is30m = sSec_ > 1200 and sSec_ <= 2700
is1h  = sSec_ > 2700
// per-TF HTF distance (measured best for that TF's winner set)
presetMult = is1m ? 15 : is2m ? 3 : is3m ? 3 : is5m ? 3 : is15m ? 15 : is30m ? 3 : 5
// ── per-TF winners (from the full measured HTF x pattern sweep, Both regime) ──
//  1m :15x  Inverted Hammer *        (Wilson-significant, N129)
//  2m :3x   Dark Cloud
//  3m :3x   Inverted Hammer * + Three Black Crows + Shooting Star
//  5m :3x   Inverted Hammer + Dark Cloud
//  15m:15x  Inverted Hammer + Two Black Gapping
//  30m:3x   Dark Cloud + Bear Engulfing + Piercing + Two White Gapping
//  1h :5x   Dark Cloud
pInvH    = is1m or is3m or is5m or is15m
pDark    = is2m or is5m or is30m or is1h
pTBC     = is3m
pShoot   = is3m
pTBG     = is15m
pBearEng = is30m
pPierce  = is30m
pTWG     = is30m
// forced filters in preset mode (winners require the full stack)
eUseHTF = autoPreset ? true : useHTF
eUseVP  = autoPreset ? true : useVP
eUseOF  = autoPreset ? true : useOF
// effective per-pattern enables
eDark    = autoPreset ? pDark    : enPierce
ePierce  = autoPreset ? pPierce  : enPierce
eBearEng = autoPreset ? pBearEng : enEng
eBullEng = autoPreset ? false    : enEng
eBearHar = autoPreset ? false    : enHar
eBullHar = autoPreset ? false    : enHar
eTBC     = autoPreset ? pTBC     : enTWS
eTWS     = autoPreset ? false    : enTWS
eTWG     = autoPreset ? pTWG     : enGap
eTBG     = autoPreset ? pTBG     : enGap
eHammer  = autoPreset ? false    : enHammer
eShoot   = autoPreset ? pShoot   : enHammer
eMorning = autoPreset ? false    : enStar
eEvening = autoPreset ? false    : enStar
eRW      = autoPreset ? false    : enWin
eFW      = autoPreset ? false    : enWin
eBullMar = autoPreset ? false    : enMar
eBearMar = autoPreset ? false    : enMar
eBullTLS = autoPreset ? false    : enTLS
eBearTLS = autoPreset ? false    : enTLS
eBullAB  = autoPreset ? false    : enAB
eBearAB  = autoPreset ? false    : enAB
eMatBull = autoPreset ? false    : enMat
eMatBear = autoPreset ? false    : enMat
eBPU     = autoPreset ? false    : enBPU
eInvH    = autoPreset ? pInvH    : enInvH
htfMultN = autoPreset ? presetMult : htfBasis == "3x chart" ? 3 : htfBasis == "5x chart" ? 5 : htfBasis == "15x chart" ? 15 : 1
htf = (not autoPreset and htfBasis == "Custom TF") ? htfCustom : timeframe.from_seconds(timeframe.in_seconds() * htfMultN)

// ───────────────────────── DELTA ENGINE (tiered) ─────────────────────────────
f_ibDelta(string tf) =>
    [oA, cA, vA] = request.security_lower_tf(syminfo.tickerid, tf, [open, close, volume])
    d = 0.0
    sz = array.size(cA)
    if sz > 0
        for k = 0 to sz - 1
            ic = array.get(cA, k)
            io = array.get(oA, k)
            iv = array.get(vA, k)
            d += ic > io ? iv : ic < io ? -iv : 0.0
    [d, sz]

useIB = dataTier == "Enhanced (intrabar · paid)"
// Call intrabar aggregation UNCONDITIONALLY (request.* must run every bar for a
// consistent series); its result is only USED on the Enhanced tier. On plans that
// don't serve intrabars the arrays come back empty (ibN = 0) and we fall back to
// the OHLCV proxy — safe on any plan.
[ibD, ibN] = f_ibDelta(ltf)
clv   = (high == low) ? 0.0 : ((close - low) - (high - close)) / (high - low)
delta = nz((useIB and ibN > 0) ? ibD : clv * volume)

// ─────────────────────── DEVELOPING VOLUME PROFILE ───────────────────────────
var array<float> bins = array.new_float(nBins, 0.0)
var float lowRef = na
var float bsize  = na
var float prevPOC = na
var bool  prevPOCtouched = false
var float cvd = 0.0
var float pocPrice = na
var float vahPrice = na
var float valPrice = na
var bool  isHVN = false
var bool  isLVN = false

if newDay or barstate.isfirst
    prevPOC := pocPrice
    array.fill(bins, 0.0)
    lowRef := open - rangeMult * dATRv
    bsize  := (2.0 * rangeMult * dATRv) / nBins
    cvd := 0.0
    prevPOCtouched := false
cvd += delta

f_bin(float p) =>
    idx = int(math.floor((p - lowRef) / bsize))
    math.max(0, math.min(nBins - 1, idx))
f_price(int idx) =>
    lowRef + (idx + 0.5) * bsize

if barstate.isconfirmed and not na(bsize) and bsize > 0
    loB = f_bin(low)
    hiB = f_bin(high)
    span = hiB - loB + 1
    vPer = volume / math.max(span, 1)
    for b = loB to hiB
        array.set(bins, b, array.get(bins, b) + vPer)

total = array.sum(bins)
if total > 0
    pocIdx = 0
    pocVol = -1.0
    for b = 0 to nBins - 1
        v = array.get(bins, b)
        if v > pocVol
            pocVol := v
            pocIdx := b
    accum = array.get(bins, pocIdx)
    lo = pocIdx
    hi = pocIdx
    tgt = 0.7 * total
    while accum < tgt and (lo > 0 or hi < nBins - 1)
        loV = lo > 0 ? array.get(bins, lo - 1) : -1.0
        hiV = hi < nBins - 1 ? array.get(bins, hi + 1) : -1.0
        if hiV >= loV
            hi += 1
            accum += math.max(hiV, 0.0)
        else
            lo -= 1
            accum += math.max(loV, 0.0)
    pocPrice := f_price(pocIdx)
    vahPrice := f_price(hi)
    valPrice := f_price(lo)
    nonEmpty = 0
    sumV = 0.0
    for b = 0 to nBins - 1
        v = array.get(bins, b)
        if v > 0
            nonEmpty += 1
            sumV += v
    meanV = nonEmpty > 0 ? sumV / nonEmpty : 0.0
    curV = array.get(bins, f_bin(close))
    isHVN := meanV > 0 and curV > hvnFactor * meanV
    isLVN := meanV > 0 and curV < lvnFactor * meanV

if not na(prevPOC) and low <= prevPOC and high >= prevPOC
    prevPOCtouched := true

// ─────────────────────────── LOCATION FLAGS ──────────────────────────────────
tol      = tolATR * atr
atPOC    = not na(pocPrice) and math.abs(close - pocPrice) <= tol
atVAL    = not na(valPrice) and math.abs(close - valPrice) <= tol
atVAH    = not na(vahPrice) and math.abs(close - vahPrice) <= tol
belowVA  = not na(valPrice) and close < valPrice
aboveVA  = not na(vahPrice) and close > vahPrice
nakedPOC = not na(prevPOC) and not prevPOCtouched and math.abs(close - prevPOC) <= tol

// ─────────────────────────── ORDER FLOW / SWEEPS ─────────────────────────────
volSMA   = nz(ta.sma(volume, 20), volume)
volSpike = volume > volSMA * spikeMult
// STATEFUL HOIST: ta.lowest / ta.highest are stateful and MUST run every bar. Behind the
// short-circuiting `ready and ...` they were skipped on warmup bars, leaving their rolling
// extrema buffers inconsistent. Compute unconditionally at top level, then mask with `ready`.
lowDiv   = ta.lowest(low, divLen)
highDiv  = ta.highest(high, divLen)
bullDiv  = ready and low  <= lowDiv  and cvd > cvd[divLen]
bearDiv  = ready and high >= highDiv and cvd < cvd[divLen]
bullConfirm = delta > 0 or bullDiv
bearConfirm = delta < 0 or bearDiv

var float lastPL = na
var float lastPH = na
pl = ta.pivotlow(pivotLen, pivotLen)
ph = ta.pivothigh(pivotLen, pivotLen)
lastPL := na(pl) ? lastPL : pl
lastPH := na(ph) ? lastPH : ph
sweptLow  = not na(lastPL) and low  < lastPL and close > lastPL and volSpike
sweptHigh = not na(lastPH) and high > lastPH and close < lastPH and volSpike

// ─────────────────────────── VP SUITABILITY ──────────────────────────────────
locBull = atVAL or belowVA or nakedPOC or sweptLow or (isHVN and not na(pocPrice) and close <= pocPrice)
locBear = atVAH or aboveVA or nakedPOC or sweptHigh or (isHVN and not na(pocPrice) and close >= pocPrice)
if reqSweep
    locBull := locBull and sweptLow
    locBear := locBear and sweptHigh
validContUp = (isLVN or aboveVA) and not (isHVN and not na(vahPrice) and close < vahPrice)
validContDn = (isLVN or belowVA) and not (isHVN and not na(valPrice) and close > valPrice)
coilNode = atPOC[1] or isHVN[1]

// ─────────────────────────── HTF ALIGNMENT ───────────────────────────────────
htfEma  = request.security(syminfo.tickerid, htf, ta.ema(close, htfEmaLen),    lookahead = barmerge.lookahead_off)
htfEmaP = request.security(syminfo.tickerid, htf, ta.ema(close, htfEmaLen)[1], lookahead = barmerge.lookahead_off)
htfC    = request.security(syminfo.tickerid, htf, close,                       lookahead = barmerge.lookahead_off)
htfBull = not na(htfC) and not na(htfEma) and htfC > htfEma and (not useSlope or htfEma >= htfEmaP)
htfBear = not na(htfC) and not na(htfEma) and htfC < htfEma and (not useSlope or htfEma <= htfEmaP)

// ─────────────────────────── PATTERN GEOMETRY ────────────────────────────────
body   = math.abs(close - open)
upWick = high - math.max(open, close)
dnWick = math.min(open, close) - low
avgBody = nz(ta.sma(body, bodyLen), body)
mid1 = (open[1] + close[1]) / 2.0
mid2 = (open[2] + close[2]) / 2.0
g1 = not na(close[1])
g2 = not na(close[2])

hammer   = g1 and body > 0 and dnWick >= wickMult * body and upWick <= smWick * body
shooting = g1 and body > 0 and upWick >= wickMult * body and dnWick <= smWick * body
bullEng  = g1 and close[1] < open[1] and close > open and close >= open[1] and open <= close[1]
bearEng  = g1 and close[1] > open[1] and close < open and open >= close[1] and close <= open[1]
bullHar  = g1 and open[1] > close[1] and math.max(open, close) < open[1] and math.min(open, close) > close[1] and body < body[1]
bearHar  = g1 and close[1] > open[1] and math.max(open, close) < close[1] and math.min(open, close) > open[1] and body < body[1]
risingWin= g1 and low > high[1]
fallWin  = g1 and high < low[1]
bullMar  = close > open and upWick <= maruWick * body and dnWick <= maruWick * body and body > avgBody
bearMar  = open > close and upWick <= maruWick * body and dnWick <= maruWick * body and body > avgBody
morning  = g2 and close[2] < open[2] and body[2] > avgBody and body[1] < body[2] * starMax and close > open and close > mid2
evening  = g2 and close[2] > open[2] and body[2] > avgBody and body[1] < body[2] * starMax and close < open and close < mid2
piercing = g1 and close[1] < open[1] and open < close[1] and close > mid1 and close < open[1]
darkCloud= g1 and close[1] > open[1] and open > close[1] and close < mid1 and close > open[1]

// --- extended high-reliability set (standard approximations) ---
g3 = not na(close[3])
g4 = not na(close[4])
tallBody = body > avgBody * 0.6
// Three White Soldiers / Three Black Crows
tws = g2 and close > open and close[1] > open[1] and close[2] > open[2] and close > close[1] and close[1] > close[2] and open <= close[1] and open >= open[1] and open[1] <= close[2] and open[1] >= open[2] and tallBody
tbc = g2 and close < open and close[1] < open[1] and close[2] < open[2] and close < close[1] and close[1] < close[2] and open >= close[1] and open <= open[1] and open[1] >= close[2] and open[1] <= open[2] and tallBody
// Three-Line Strike (4-candle): three trend candles then a wide engulfing reversal
bullTLS = g3 and close[3] < open[3] and close[2] < open[2] and close[1] < open[1] and close[2] < close[3] and close[1] < close[2] and close > open and open < close[1] and close > open[3]
bearTLS = g3 and close[3] > open[3] and close[2] > open[2] and close[1] > open[1] and close[2] > close[3] and close[1] > close[2] and close < open and open > close[1] and close < open[3]
// Abandoned Baby (doji island reversal)
dojiBody1 = g1 and math.abs(close[1] - open[1]) <= (high[1] - low[1]) * 0.1
bullAB = g2 and close[2] < open[2] and dojiBody1 and high[1] < low[2] and low > high[1] and close > open
bearAB = g2 and close[2] > open[2] and dojiBody1 and low[1] > high[2] and high < low[1] and close < open
// Two White / Black Gapping (gap + confirming candle, continuation)
twoWhiteGap = g2 and low[1] > high[2] and close[1] > open[1] and close > open and low > low[1]
twoBlackGap = g2 and high[1] < low[2] and close[1] < open[1] and close < open and high < high[1]
// Mat Hold (5-candle continuation) — tightened: tall drive, small contained pullback, breakout
midMaxBody = math.max(body[1], math.max(body[2], body[3]))
matBull = g4 and close[4] > open[4] and body[4] > avgBody * 1.2 and midMaxBody < body[4] * 0.6 and close[1] < close[4] and math.min(low[1], math.min(low[2], low[3])) > low[4] and math.max(high[1], math.max(high[2], high[3])) < high[4] and close > open and close > high[4] and body > avgBody
matBear = g4 and close[4] < open[4] and body[4] > avgBody * 1.2 and midMaxBody < body[4] * 0.6 and close[1] > close[4] and math.max(high[1], math.max(high[2], high[3])) < high[4] and math.min(low[1], math.min(low[2], low[3])) > low[4] and close < open and close < low[4] and body > avgBody
// --- research additions (2025 literature): bullish single-bar reversals, fired LONG ---
// Inverted Hammer: shooting-star geometry (long upper wick) taken as a bottom reversal
invHammer = g1 and body > 0 and upWick >= wickMult * body and dnWick <= smWick * body
// Black Paper Umbrella: hammer geometry (long lower wick) with a BLACK / down-close body
bpu       = g1 and body > 0 and close < open and dnWick >= wickMult * body and upWick <= smWick * body

// ─────────────── FILTER PASSES (forced on in preset mode) ─────────────────────
hL = not eUseHTF or htfBull
hS = not eUseHTF or htfBear
vRevL = not eUseVP or locBull
vRevS = not eUseVP or locBear
vConU = not eUseVP or validContUp
vConD = not eUseVP or validContDn
vHar  = not eUseVP or coilNode
oRevL = not eUseOF or bullConfirm
oRevS = not eUseOF or bearConfirm
oConU = not eUseOF or delta > 0
oConD = not eUseOF or delta < 0
oMarU = not eUseOF or (delta > 0 and volSpike)
oMarD = not eUseOF or (delta < 0 and volSpike)

// ─────────────────────────── SIGNALS ─────────────────────────────────────────
sHammer  = ready and eHammer and hammer   and hL and vRevL and oRevL and calmOK                       // 0  L
sShoot   = ready and eShoot and shooting   and hS and vRevS and oRevS and calmOK                       // 1  S
sBullEng = ready and eBullEng and bullEng  and hL and vRevL and oRevL and calmOK                       // 2  L
sBearEng = ready and eBearEng and bearEng  and hS and vRevS and oRevS and calmOK                       // 3  S
sMorning = ready and eMorning and morning  and hL and vRevL and oRevL and calmOK                       // 4  L
sEvening = ready and eEvening and evening  and hS and vRevS and oRevS and calmOK                       // 5  S
sPierce  = ready and ePierce and piercing  and hL and vRevL and oRevL and calmOK                       // 6  L
sDark    = ready and eDark and darkCloud   and hS and vRevS and oRevS and calmOK                       // 7  S
sBullHar = ready and eBullHar and bullHar[1] and vHar and close > high[1] and hL and oRevL and calmOK  // 8  L
sBearHar = ready and eBearHar and bearHar[1] and vHar and close < low[1]  and hS and oRevS and calmOK  // 9  S
sRW      = ready and eRW and risingWin and hL and vConU and oConU and calmOK                           // 10 L
sFW      = ready and eFW and fallWin    and hS and vConD and oConD and calmOK                          // 11 S
sBullMar = ready and eBullMar and bullMar and hL and vConU and oMarU and calmOK                        // 12 L
sBearMar = ready and eBearMar and bearMar and hS and vConD and oMarD and calmOK                        // 13 S
sTWS     = ready and eTWS and tws     and hL and vRevL and oRevL and calmOK                            // 14 L
sTBC     = ready and eTBC and tbc     and hS and vRevS and oRevS and calmOK                            // 15 S
sBullTLS = ready and eBullTLS and bullTLS and hL and vRevL and oRevL and calmOK                        // 16 L
sBearTLS = ready and eBearTLS and bearTLS and hS and vRevS and oRevS and calmOK                        // 17 S
sBullAB  = ready and eBullAB and bullAB  and hL and vRevL and oRevL and calmOK                         // 18 L
sBearAB  = ready and eBearAB and bearAB  and hS and vRevS and oRevS and calmOK                         // 19 S
sTWG     = ready and eTWG and twoWhiteGap and hL and vConU and oConU and calmOK                        // 20 L
sTBG     = ready and eTBG and twoBlackGap and hS and vConD and oConD and calmOK                        // 21 S
sMatBull = ready and eMatBull and matBull and hL and vConU and oConU and calmOK                        // 22 L
sMatBear = ready and eMatBear and matBear and hS and vConD and oConD and calmOK                        // 23 S
sBPU     = ready and eBPU  and bpu       and hL and vRevL and oRevL and calmOK                          // 24 L
sInvH    = ready and eInvH and invHammer and hL and vRevL and oRevL and calmOK                          // 25 L

longSig  = sHammer or sBullEng or sMorning or sPierce or sBullHar or sRW or sBullMar or sTWS or sBullTLS or sBullAB or sTWG or sMatBull or sBPU or sInvH
shortSig = sShoot  or sBearEng or sEvening or sDark   or sBearHar or sFW or sBearMar or sTBC or sBearTLS or sBearAB or sTBG or sMatBear

// ─────────────────────────── CALIBRATION SPINE ───────────────────────────────
type Trade
    float entry
    int   dir
    int   opened
    float tgt
    float stp
    int   cls
    float rdist
    float mfe
    float mae
    bool  resolved
    int   vtag
    int   reg

var array<Trade> trades = array.new<Trade>()
var array<int>   cN   = array.new_int(26, 0)
var array<int>   cW   = array.new_int(26, 0)
var array<int>   cOcc = array.new_int(26, 0)
var int          barsSeen = 0
var array<float> cMFE = array.new_float(26, 0.0)
var array<float> cMAE = array.new_float(26, 0.0)
var array<int>   bN   = array.new_int(2, 0)
var array<int>   bW   = array.new_int(2, 0)
var array<float> vExc = array.new_float(3, 0.0)   // leave-one-out rejected-set excess (HTF,VP,OF)
var array<int>   vNr  = array.new_int(3, 0)
var array<int>   cCalmN  = array.new_int(26, 0)
var array<float> cCalmE  = array.new_float(26, 0.0)
var array<int>   cPanicN = array.new_int(26, 0)
var array<float> cPanicE = array.new_float(26, 0.0)

f_open(int cls, int dir) =>
    e = close
    rd = slATR * atr
    t = dir > 0 ? e + tpATR * atr : e - tpATR * atr
    s = dir > 0 ? e - slATR * atr : e + slATR * atr
    array.push(trades, Trade.new(e, dir, bar_index, t, s, cls, rd, 0.0, 0.0, false, -1, regIdx))
    if cls >= 0
        array.set(cOcc, cls, array.get(cOcc, cls) + 1)
    0

f_openV(int v, int dir) =>
    e = close
    rd = slATR * atr
    t = dir > 0 ? e + tpATR * atr : e - tpATR * atr
    s = dir > 0 ? e - slATR * atr : e + slATR * atr
    array.push(trades, Trade.new(e, dir, bar_index, t, s, -1, rd, 0.0, 0.0, false, v, regIdx))
    0

// Leave-one-out: for a present pattern, log the signals that pass the OTHER two
// enabled filters but are REJECTED by exactly one — so we can price each filter's
// marginal contribution to the stacked edge.
f_attr(int dir, bool rawok, bool vpPass, bool ofPass) =>
    if rawok and calmOK
        hOK = not eUseHTF or (dir > 0 ? htfBull : htfBear)
        vOK = not eUseVP or vpPass
        oOK = not eUseOF or ofPass
        if eUseHTF and vOK and oOK and not hOK
            f_openV(0, dir)
        if eUseVP and hOK and oOK and not vOK
            f_openV(1, dir)
        if eUseOF and hOK and vOK and not oOK
            f_openV(2, dir)
    0

if barstate.isconfirmed
    barsSeen += 1
    if sHammer
        f_open(0, 1)
    if sShoot
        f_open(1, -1)
    if sBullEng
        f_open(2, 1)
    if sBearEng
        f_open(3, -1)
    if sMorning
        f_open(4, 1)
    if sEvening
        f_open(5, -1)
    if sPierce
        f_open(6, 1)
    if sDark
        f_open(7, -1)
    if sBullHar
        f_open(8, 1)
    if sBearHar
        f_open(9, -1)
    if sRW
        f_open(10, 1)
    if sFW
        f_open(11, -1)
    if sBullMar
        f_open(12, 1)
    if sBearMar
        f_open(13, -1)
    if sTWS
        f_open(14, 1)
    if sTBC
        f_open(15, -1)
    if sBullTLS
        f_open(16, 1)
    if sBearTLS
        f_open(17, -1)
    if sBullAB
        f_open(18, 1)
    if sBearAB
        f_open(19, -1)
    if sTWG
        f_open(20, 1)
    if sTBG
        f_open(21, -1)
    if sMatBull
        f_open(22, 1)
    if sMatBear
        f_open(23, -1)
    if sBPU
        f_open(24, 1)
    if sInvH
        f_open(25, 1)
    if bar_index % baseStride == 0 and calmOK
        f_open(-1, 1)
        f_open(-2, -1)
    // leave-one-out attribution (rejected-set logging)
    f_attr(1,  ready and eHammer and hammer,       locBull, bullConfirm)
    f_attr(-1, ready and eShoot and shooting,      locBear, bearConfirm)
    f_attr(1,  ready and eBullEng and bullEng,     locBull, bullConfirm)
    f_attr(-1, ready and eBearEng and bearEng,     locBear, bearConfirm)
    f_attr(1,  ready and eMorning and morning,     locBull, bullConfirm)
    f_attr(-1, ready and eEvening and evening,     locBear, bearConfirm)
    f_attr(1,  ready and ePierce and piercing,     locBull, bullConfirm)
    f_attr(-1, ready and eDark and darkCloud,      locBear, bearConfirm)
    f_attr(1,  ready and eBullHar and bullHar[1] and close > high[1], coilNode, bullConfirm)
    f_attr(-1, ready and eBearHar and bearHar[1] and close < low[1],  coilNode, bearConfirm)
    f_attr(1,  ready and eRW and risingWin,        validContUp, delta > 0)
    f_attr(-1, ready and eFW and fallWin,          validContDn, delta < 0)
    f_attr(1,  ready and eBullMar and bullMar,     validContUp, delta > 0 and volSpike)
    f_attr(-1, ready and eBearMar and bearMar,     validContDn, delta < 0 and volSpike)
    f_attr(1,  ready and eTWS and tws,             locBull, bullConfirm)
    f_attr(-1, ready and eTBC and tbc,             locBear, bearConfirm)
    f_attr(1,  ready and eBullTLS and bullTLS,     locBull, bullConfirm)
    f_attr(-1, ready and eBearTLS and bearTLS,     locBear, bearConfirm)
    f_attr(1,  ready and eBullAB and bullAB,       locBull, bullConfirm)
    f_attr(-1, ready and eBearAB and bearAB,       locBear, bearConfirm)
    f_attr(1,  ready and eTWG and twoWhiteGap,     validContUp, delta > 0)
    f_attr(-1, ready and eTBG and twoBlackGap,     validContDn, delta < 0)
    f_attr(1,  ready and eMatBull and matBull,     validContUp, delta > 0)
    f_attr(-1, ready and eMatBear and matBear,     validContDn, delta < 0)
    f_attr(1,  ready and eBPU  and bpu,            locBull, bullConfirm)
    f_attr(1,  ready and eInvH and invHammer,      locBull, bullConfirm)

if barstate.isconfirmed and array.size(trades) > 0
    for i = 0 to array.size(trades) - 1
        tr = array.get(trades, i)
        // Resolve only from the bar AFTER entry — never against the entry bar's own
        // high/low (whose extremes printed before the close-entry). Enforces the
        // non-repaint / true triple-barrier claim.
        if not tr.resolved and bar_index > tr.opened
            fav = tr.dir > 0 ? high - tr.entry : tr.entry - low
            adv = tr.dir > 0 ? tr.entry - low  : high - tr.entry
            tr.mfe := math.max(tr.mfe, fav)
            tr.mae := math.max(tr.mae, adv)
            hitT = tr.dir > 0 ? high >= tr.tgt : low <= tr.tgt
            hitS = tr.dir > 0 ? low <= tr.stp : high >= tr.stp
            done = false
            win = false
            if hitT and hitS
                win := false
                done := true
            else if hitT
                win := true
                done := true
            else if hitS
                win := false
                done := true
            else if bar_index - tr.opened >= horizon
                win := tr.dir > 0 ? close > tr.entry : close < tr.entry
                done := true
            if done
                tr.resolved := true
                mfeR = tr.rdist > 0 ? tr.mfe / tr.rdist : 0.0
                maeR = tr.rdist > 0 ? tr.mae / tr.rdist : 0.0
                if tr.vtag >= 0
                    bp = tr.dir > 0 ? (array.get(bN, 0) > 0 ? float(array.get(bW, 0)) / array.get(bN, 0) : 0.4) : (array.get(bN, 1) > 0 ? float(array.get(bW, 1)) / array.get(bN, 1) : 0.4)
                    array.set(vExc, tr.vtag, array.get(vExc, tr.vtag) + ((win ? 1.0 : 0.0) - bp))
                    array.set(vNr, tr.vtag, array.get(vNr, tr.vtag) + 1)
                else if tr.cls < 0
                    bi = tr.cls == -1 ? 0 : 1
                    array.set(bN, bi, array.get(bN, bi) + 1)
                    if win
                        array.set(bW, bi, array.get(bW, bi) + 1)
                else
                    array.set(cN, tr.cls, array.get(cN, tr.cls) + 1)
                    if win
                        array.set(cW, tr.cls, array.get(cW, tr.cls) + 1)
                    array.set(cMFE, tr.cls, array.get(cMFE, tr.cls) + mfeR)
                    array.set(cMAE, tr.cls, array.get(cMAE, tr.cls) + maeR)
                    bpr = tr.dir > 0 ? (array.get(bN, 0) > 0 ? float(array.get(bW, 0)) / array.get(bN, 0) : 0.4) : (array.get(bN, 1) > 0 ? float(array.get(bW, 1)) / array.get(bN, 1) : 0.4)
                    exc = (win ? 1.0 : 0.0) - bpr
                    if tr.reg >= 2
                        array.set(cPanicN, tr.cls, array.get(cPanicN, tr.cls) + 1)
                        array.set(cPanicE, tr.cls, array.get(cPanicE, tr.cls) + exc)
                    else
                        array.set(cCalmN, tr.cls, array.get(cCalmN, tr.cls) + 1)
                        array.set(cCalmE, tr.cls, array.get(cCalmE, tr.cls) + exc)
    keep = array.new<Trade>()
    for j = 0 to array.size(trades) - 1
        tj = array.get(trades, j)
        if not tj.resolved
            array.push(keep, tj)
    trades := keep

// ─────────────────────────── VISUALS ─────────────────────────────────────────
plot(showProf and not na(pocPrice) ? pocPrice : na, "POC", color.new(color.orange, 0), 2, plot.style_stepline)
plot(showProf and not na(vahPrice) ? vahPrice : na, "VAH", color.new(color.gray, 30), 1, plot.style_stepline)
plot(showProf and not na(valPrice) ? valPrice : na, "VAL", color.new(color.gray, 30), 1, plot.style_stepline)

// per-signal identity label (legend against each signal)
sigName = ""
sigDir  = 0
if sHammer
    sigName := "Hammer"
    sigDir := 1
if sBullEng
    sigName := "Bull Engulf"
    sigDir := 1
if sMorning
    sigName := "Morning Star"
    sigDir := 1
if sPierce
    sigName := "Piercing"
    sigDir := 1
if sBullHar
    sigName := "Bull Harami"
    sigDir := 1
if sRW
    sigName := "Rising Win"
    sigDir := 1
if sBullMar
    sigName := "Bull Maru"
    sigDir := 1
if sTWS
    sigName := "3 Wht Soldiers"
    sigDir := 1
if sBullTLS
    sigName := "Bull 3-Line"
    sigDir := 1
if sBullAB
    sigName := "Bull Aband Baby"
    sigDir := 1
if sTWG
    sigName := "2 White Gap"
    sigDir := 1
if sMatBull
    sigName := "Bull Mat Hold"
    sigDir := 1
if sBPU
    sigName := "Blk Umbrella"
    sigDir := 1
if sInvH
    sigName := "Inv Hammer"
    sigDir := 1
if sShoot
    sigName := "Shooting Star"
    sigDir := -1
if sBearEng
    sigName := "Bear Engulf"
    sigDir := -1
if sEvening
    sigName := "Evening Star"
    sigDir := -1
if sDark
    sigName := "Dark Cloud"
    sigDir := -1
if sBearHar
    sigName := "Bear Harami"
    sigDir := -1
if sFW
    sigName := "Falling Win"
    sigDir := -1
if sBearMar
    sigName := "Bear Maru"
    sigDir := -1
if sTBC
    sigName := "3 Blk Crows"
    sigDir := -1
if sBearTLS
    sigName := "Bear 3-Line"
    sigDir := -1
if sBearAB
    sigName := "Bear Aband Baby"
    sigDir := -1
if sTBG
    sigName := "2 Black Gap"
    sigDir := -1
if sMatBear
    sigName := "Bear Mat Hold"
    sigDir := -1

if sigName != "" and barstate.isconfirmed
    label.new(bar_index, sigDir > 0 ? low : high, sigName,
         yloc      = sigDir > 0 ? yloc.belowbar : yloc.abovebar,
         style     = sigDir > 0 ? label.style_label_up : label.style_label_down,
         color     = sigDir > 0 ? color.new(color.teal, 0) : color.new(color.red, 0),
         textcolor = color.white, size = size.small)

alertcondition(longSig,  "Edge Lab long",  "Bullish candlestick signal")
alertcondition(shortSig, "Edge Lab short", "Bearish candlestick signal")

// ─────────────────────────── SCOREBOARD ──────────────────────────────────────
// Wilson 95% score interval — returns [lower%, upper%] in one pass (computed once
// per row instead of twice).
f_wilson(int w, int n) =>
    if n == 0
        [0.0, 0.0]
    else
        p = float(w) / float(n)
        z = 1.96
        d = 1.0 + z * z / n
        c = (p + z * z / (2 * n)) / d
        h = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n)) / d
        [100.0 * (c - h), 100.0 * (c + h)]

var array<string> nm = array.from(
     "Hammer","Shooting Star","Bull Engulfing","Bear Engulfing","Morning Star","Evening Star",
     "Piercing","Dark Cloud","Bull Harami","Bear Harami","Rising Window","Falling Window",
     "Bull Marubozu","Bear Marubozu","Three Wht Soldiers","Three Blk Crows","Bull 3-Line Strike",
     "Bear 3-Line Strike","Bull Abandoned Baby","Bear Abandoned Baby","Two White Gapping",
     "Two Black Gapping","Bull Mat Hold","Bear Mat Hold","Blk Paper Umbrella","Inverted Hammer")

// ─────────────────────────── ADAPTIVE THEME ──────────────────────────────────
// House standard: read chart-background luminance and flip the TEXT colour so the scoreboard stays
// legible on dark OR light charts. The semantic cell backgrounds (green edge / red / gray heat-map)
// are kept — only the text on the semi-transparent cells needs to adapt (white on dark, dark on light).
f_lum(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
bool  darkUI = f_lum(chart.bg_color) < 140
color thTxt  = darkUI ? color.white : color.rgb(16, 20, 24)

if showTable and barstate.islast
    var table t = table.new(position.top_right, 12, 32, border_width = 1)
    hb = color.new(color.blue, 0)
    cfg = (autoPreset ? "PRESET " : "Manual ") + timeframe.period + "  HTF:" + (eUseHTF ? "on " + str.tostring(htfMultN) + "x(" + htf + ")" : "off") + "  VP:" + (eUseVP ? "on" : "off") + "  OF:" + (eUseOF ? "on" : "off") + "  Reg:" + regimeMode + "  |  " + (useIB ? "Enh" : "Std")
    table.cell(t, 0, 0, cfg, text_color = color.white, bgcolor = color.new(color.purple, 0), text_size = size.tiny)
    for cc = 1 to 11
        table.cell(t, cc, 0, "", bgcolor = color.new(color.purple, 0))
    table.cell(t, 0, 1, "Pattern", text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 1, 1, "N",    text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 2, 1, "Hit%", text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 3, 1, "±95",  text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 4, 1, "Base%",text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 5, 1, "Edge", text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 6, 1, "Net R",text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 7, 1, "MFE R",text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 8, 1, "MAE R",text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 9, 1, "Rare/1k", text_color = color.white, bgcolor = hb, text_size = size.tiny)
    table.cell(t, 10, 1, "Calm E(N)",  text_color = color.white, bgcolor = color.new(color.teal, 0), text_size = size.tiny)
    table.cell(t, 11, 1, "Panic E(N)", text_color = color.white, bgcolor = color.new(color.maroon, 0), text_size = size.tiny)
    baseLP = array.get(bN, 0) > 0 ? float(array.get(bW, 0)) / array.get(bN, 0) : 0.4
    baseSP = array.get(bN, 1) > 0 ? float(array.get(bW, 1)) / array.get(bN, 1) : 0.4
    float tpR = slATR > 0 ? tpATR / slATR : 0.0          // barrier reward:risk, in R (win = +tpR, loss = −1R)
    fullExcW = 0.0
    fullNsum = 0
    tradeStr = ""
    for i = 0 to 25
        n = array.get(cN, i)
        w = array.get(cW, i)
        isL = i < 24 ? (i % 2 == 0) : true   // indices 24 (BPU) & 25 (Inv Hammer) are both LONG
        baseN = isL ? array.get(bN, 0) : array.get(bN, 1)
        baseW = isL ? array.get(bW, 0) : array.get(bW, 1)
        hit = n > 0 ? 100.0 * w / n : 0.0
        bas = baseN > 0 ? 100.0 * baseW / baseN : 0.0
        edge = hit - bas
        [loW, hiW] = f_wilson(w, n)
        sig = n >= minN and loW > bas
        mfe = n > 0 ? array.get(cMFE, i) / n : 0.0
        mae = n > 0 ? array.get(cMAE, i) / n : 0.0
        // NET-OF-COST expectancy in R, from the barrier win rate: win → +tpR, loss → −1R, then − cost.
        float winR   = n > 0 ? float(w) / n : na
        float grossR = na(winR) ? na : winR * tpR - (1.0 - winR) * 1.0
        float netR   = na(grossR) ? na : grossR - costR
        col = n < minN ? color.new(color.gray, 55) : edge > 0 ? color.new(color.green, 55) : color.new(color.red, 55)
        r = i + 2
        table.cell(t, 0, r, array.get(nm, i) + (sig ? " *" : ""), text_color = thTxt, bgcolor = col, text_size = size.tiny)
        table.cell(t, 1, r, str.tostring(n), text_color = thTxt, bgcolor = col, text_size = size.tiny)
        table.cell(t, 2, r, n > 0 ? str.tostring(hit, "#.0") : "-", text_color = thTxt, bgcolor = col, text_size = size.tiny)
        table.cell(t, 3, r, n > 0 ? str.tostring((hiW - loW) / 2.0, "#.0") : "-", text_color = thTxt, bgcolor = col, text_size = size.tiny)
        table.cell(t, 4, r, baseN > 0 ? str.tostring(bas, "#.0") : "-", text_color = thTxt, bgcolor = col, text_size = size.tiny)
        table.cell(t, 5, r, n > 0 ? (edge >= 0 ? "+" : "") + str.tostring(edge, "#.0") : "-", text_color = thTxt, bgcolor = col, text_size = size.tiny)
        ncol = n < minN ? color.new(color.gray, 55) : (not na(netR) and netR > 0) ? color.new(color.green, 45) : color.new(color.red, 55)
        table.cell(t, 6, r, (n >= minN and not na(netR)) ? (netR >= 0 ? "+" : "") + str.tostring(netR, "#.00") : "-", text_color = thTxt, bgcolor = ncol, text_size = size.tiny)
        table.cell(t, 7, r, n > 0 ? str.tostring(mfe, "#.00") : "-", text_color = thTxt, bgcolor = col, text_size = size.tiny)
        table.cell(t, 8, r, n > 0 ? str.tostring(mae, "#.00") : "-", text_color = thTxt, bgcolor = col, text_size = size.tiny)
        occ = array.get(cOcc, i)
        rare = barsSeen > 0 ? 1000.0 * occ / barsSeen : 0.0
        rcol = occ == 0 ? color.new(color.gray, 55) : rare < 0.5 ? color.new(color.orange, 45) : color.new(color.teal, 55)
        table.cell(t, 9, r, occ > 0 ? str.tostring(rare, "#.00") : "-", text_color = thTxt, bgcolor = rcol, text_size = size.tiny)
        cN_ = array.get(cCalmN, i)
        pN_ = array.get(cPanicN, i)
        cE_ = cN_ > 0 ? 100.0 * array.get(cCalmE, i) / cN_ : 0.0
        pE_ = pN_ > 0 ? 100.0 * array.get(cPanicE, i) / pN_ : 0.0
        ccol = cN_ == 0 ? color.new(color.gray, 55) : cE_ > 0 ? color.new(color.green, 45) : color.new(color.red, 55)
        pcol = pN_ == 0 ? color.new(color.gray, 55) : pE_ > 0 ? color.new(color.green, 45) : color.new(color.red, 55)
        table.cell(t, 10, r, cN_ > 0 ? (cE_ >= 0 ? "+" : "") + str.tostring(cE_, "#.0") + "(" + str.tostring(cN_) + ")" : "-", text_color = thTxt, bgcolor = ccol, text_size = size.tiny)
        table.cell(t, 11, r, pN_ > 0 ? (pE_ >= 0 ? "+" : "") + str.tostring(pE_, "#.0") + "(" + str.tostring(pN_) + ")" : "-", text_color = thTxt, bgcolor = pcol, text_size = size.tiny)
        bp = isL ? baseLP : baseSP
        fullExcW += w - n * bp
        fullNsum += n
        // TRADEABLE = clears the base rate (Wilson) AND survives cost (net R > 0).
        if sig and not na(netR) and netR > 0
            tradeStr := tradeStr + (tradeStr == "" ? "" : ", ") + array.get(nm, i) + " (" + (netR >= 0 ? "+" : "") + str.tostring(netR, "#.00") + "R)"
    table.cell(t, 0, 28, "Base N L/S: " + str.tostring(array.get(bN, 0)) + "/" + str.tostring(array.get(bN, 1)) + "   * = edge clears base (95%)", text_color = thTxt, bgcolor = color.new(color.gray, 30), text_size = size.tiny)
    fullEdge = fullNsum > 0 ? 100.0 * fullExcW / fullNsum : 0.0
    nH = array.get(vNr, 0)
    nV = array.get(vNr, 1)
    nO = array.get(vNr, 2)
    dropH = (fullNsum + nH) > 0 ? 100.0 * (fullExcW + array.get(vExc, 0)) / (fullNsum + nH) : fullEdge
    dropV = (fullNsum + nV) > 0 ? 100.0 * (fullExcW + array.get(vExc, 1)) / (fullNsum + nV) : fullEdge
    dropO = (fullNsum + nO) > 0 ? 100.0 * (fullExcW + array.get(vExc, 2)) / (fullNsum + nO) : fullEdge
    margH = fullEdge - dropH
    margV = fullEdge - dropV
    margO = fullEdge - dropO
    sH = eUseHTF and nH > 0 ? (margH >= 0 ? "+" : "") + str.tostring(margH, "#.0") : "n/a"
    sV = eUseVP  and nV > 0 ? (margV >= 0 ? "+" : "") + str.tostring(margV, "#.0") : "n/a"
    sO = eUseOF  and nO > 0 ? (margO >= 0 ? "+" : "") + str.tostring(margO, "#.0") : "n/a"
    attr = "Filter lift (pp, +=helps):  HTF " + sH + "   VP " + sV + "   OF " + sO + "    |  full edge " + (fullEdge >= 0 ? "+" : "") + str.tostring(fullEdge, "#.0")
    table.cell(t, 0, 29, attr, text_color = color.white, bgcolor = color.new(color.blue, 15), text_size = size.tiny)
    table.cell(t, 0, 30, "TRADEABLE after cost (clears base & net R>0):  " + (tradeStr == "" ? "none yet" : tradeStr), text_color = thTxt, bgcolor = color.new(color.green, 25), text_size = size.tiny)
    table.cell(t, 0, 31, "Cost model: " + str.tostring(costR, "#.00") + "R round-trip subtracted  ·  Net R = Hit×(TP÷SL) − (1−Hit) − cost  ·  TP÷SL = " + str.tostring(tpR, "#.0") + ":1", text_color = thTxt, bgcolor = color.new(color.gray, 40), text_size = size.tiny)

// ─────────────────────────── EXPORTS (Data Window — consume via input.source()) ──────────────
color exC = color.new(color.gray, 100)
plot(longSig ? 1 : shortSig ? -1 : 0, "EXP_Signal",  exC, display = display.data_window)   // +1 long · -1 short · 0
plot(regIdx,                          "EXP_Regime",  exC, display = display.data_window)    // 0 CalmDn · 1 CalmUp · 2 PanicDn · 3 PanicUp
plot(htfBull ? 1 : htfBear ? -1 : 0,  "EXP_HTFbias", exC, display = display.data_window)    // +1 HTF up · -1 HTF down · 0
plot(volHigh ? 1 : 0,                 "EXP_Panic",   exC, display = display.data_window)    // 1 = panic regime (ATR pctile ≥ threshold)
plot(delta,                           "EXP_Delta",   exC, display = display.data_window)
plot(cvd,                             "EXP_CVD",     exC, display = display.data_window)
plot(na(pocPrice) ? na : pocPrice,    "EXP_POC",     exC, display = display.data_window)
plot(na(vahPrice) ? na : vahPrice,    "EXP_VAH",     exC, display = display.data_window)
plot(na(valPrice) ? na : valPrice,    "EXP_VAL",     exC, display = display.data_window)
plot(atr,                             "EXP_ATR",     exC, display = display.data_window)

// (Bottom-right regime panel removed by request. Per-pattern Calm E(N) / Panic E(N)
//  columns remain in the scoreboard above; the regime split still gates via 'Market regime'.)
// ══════════════════════════════════════════════════════════════════════════════
````
