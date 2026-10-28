# Order Flow Imbalance Regime Engine

- url: https://www.tradingview.com/script/oTVgRHwN-Order-Flow-Imbalance-Regime-Engine/
- type: indicator
- pine_id: PUB;fc298a0de83f4cf48b5e62fc63133b38
- version: 3.0

## Description

# Order Flow Imbalance Regime Engine

## OVERVIEW

The Order Flow Imbalance Regime Engine reconstructs a proxy for **order-flow imbalance** (net aggressive buying vs selling) directly from price and volume, scales it into an **expected price move**, and turns it into a connected set of read-outs: directional pressure, price impact, multi-horizon conviction, self-excitation (cascade) intensity, a three-lens liquidity-stress score, optional cross-asset confirmation, and a probability distribution over five market regimes. It runs on **any symbol and any market** — equities, futures, forex, crypto, indices — including instruments without reliable volume.

A charting platform exposes no Level-2 order book, so true exchange-grade OFI is not computable. This engine is an honest **approximation** that rebuilds buy/sell pressure from intrabar tick direction, probabilistic bulk classification, or candle geometry — not from limit-order placements and cancellations.

## WHY THE COMPONENTS BELONG IN ONE SCRIPT (not a mashup of unrelated tools)

Every stage is derived from **one underlying quantity** — reconstructed buy-vs-sell pressure — and each stage consumes the previous stage's output, all feeding a single end product (the regime probabilities). They are dependencies in a chain, not independent indicators placed side by side:

1. **Classification** reconstructs buy/sell pressure (tick rule, bulk volume, or geometry).
2. **Stationarization** standardizes that exact series so values compare across assets.
3. **Price impact (Kyle λ)** scales the standardized flow into an expected price move — large imbalance against thin depth implies a bigger move.
4. **Multi-horizon consensus** measures the same series across timescales for conviction.
5. **Self-excitation (Hawkes)** tests whether the imbalance is clustering — flow that triggers more flow.
6. **Liquidity stress** estimates fragility (the *context* that makes impact larger or smaller).
7. **Cross-asset confirmation** checks whether a correlated instrument agrees.
8. **Regime classifier** is a softmax that takes features 1–7 as inputs and outputs probabilities. Remove any earlier stage and the classifier loses an input — that dependency is the justification for combining them.

## HOW EACH STAGE WORKS

- **Classification (choose one):**
  - *Intrabar Tick Rule* — pulls lower-timeframe bars inside each candle and tags each buy or sell by its own open/close.
  - *Bulk Volume Classification (BVC)* — splits each bar's volume probabilistically using the normal CDF of its standardized return; designed for bar-aggregated data and consistent with the VPIN liquidity layer.
  - *Candle Geometry* — splits volume by where the close sits within the bar's range.
  - On volume-less instruments it falls back to a tick count, so the imbalance stays meaningful.
- **Stationarized OFI (z-score):** standardizes raw imbalance over a lookback so +2 means "two standard deviations of buying" on any asset.
- **Price impact (Kyle λ):** estimates λ by regressing bar return on signed flow; market depth ≈ 1/λ. The dashboard's **Expected Move** is λ · OFI, expressed in ATR units — this reproduces the founding result that price impact scales inversely with depth.
- **Multi-horizon consensus:** three EMAs of the z-score; agreement of their signs (shown as n/3) gauges conviction.
- **Self-excitation (Hawkes):** an intensity that jumps on strong imbalance events and decays exponentially — λ(t) = λ(t-1)·e^(-β) + α·event. Reported as a 0–100 percentile (Cascade Strength) plus direction.
- **Liquidity stress:** the mean percentile of three orthogonal lenses — VPIN-style flow toxicity, a thin-book "vacuum" term (price travelling far on thin relative volume), and Amihud illiquidity (|return|/volume). Using three independent estimators avoids resting the read on any single one.
- **Cross-asset confirmation:** a lagged imbalance proxy on a user-chosen correlated symbol; used only to confirm, never as a stand-alone signal.
- **Round-level magnet (optional, heuristic):** distance to the nearest auto-scaled round level as a crude pinning gauge. **This is explicitly not options dealer gamma**, which needs options open-interest data unavailable on a price chart.
- **Regime classifier:** a softmax over the above producing probabilities for Trend Continuation, Squeeze, Cascade Blast, Mean Reversion, and Liquidity Shock; the dominant one is highlighted.

## HOW TO USE IT

- Works best on intraday timeframes where intrabar data exists (1m–1h); it also runs higher via the geometry/BVC paths.
- **Dashboard:** read Buy/Sell pressure for direction, OFI z-score and consensus for strength/conviction, **Expected Move** for the impact-scaled magnitude, Cascade for clustering, Liquidity Stress for fragility, and the highlighted Regime for context.
- **Signals:** a triangle prints on the first bar of a buy or sell cascade (strong, directionally-aligned self-excitation, optionally confirmed by the cross-asset). Treat these as context/timing aids, not stand-alone entries.
- **Tuning:** switch Classification method to compare tick-rule vs BVC; lower Squeeze sensitivity on compression-prone instruments; set the Volume source and cross-asset reference to suit your instrument.

## WHAT MAKES IT ORIGINAL

Most published "order flow" tools stop at a single buy-minus-sell histogram. This engine (a) offers **three interchangeable classification methods** including probabilistic bulk classification, (b) **stationarizes** the imbalance for cross-asset comparability, (c) scales it into a **Kyle-λ expected move** rather than leaving it as a raw count, (d) adds an explicit **self-exciting (Hawkes) cascade** layer, (e) fuses **three orthogonal liquidity lenses** into one stress score, and (f) routes everything through a **softmax regime classifier** that outputs a probability distribution rather than a binary signal. The volume-agnostic fallback and theme-adaptive dashboard make it genuinely universal. The code is an independent implementation and reuses no third-party scripts.

## DATA, UNIVERSALITY & SETTINGS

The Volume source input, three classification methods, and automatic tick/geometry fallbacks let the engine run on any market, including volume-less instruments. The cross-asset reference defaults to a NIFTY-family symbol (BANKNIFTY) but is freely editable to any correlated instrument, and the round-level spacing auto-scales or accepts manual values, so the engine adapts to any exchange or instrument.

## REPAINTING DISCLOSURE

Intrabar and cross-asset requests update on the live (forming) bar, so live read-outs can change until the bar closes. The "Confirm signals on bar close" option (ON by default) makes all plotted signals and alerts evaluate only on closed bars, so historical signals are fixed and non-repainting.

## ACADEMIC CREDIT

This script is an original implementation of concepts from public research, with thanks to their authors: Cont, Kukanov & Stoikov (order-flow imbalance and linear price impact, 2014); Kyle (the λ price-impact coefficient and market depth, 1985); Xu, Gould & Howison (multi-level order flow, 2018); Cont, Cucuringu & Zhang (integrated and cross-asset OFI, 2023); the Generalized/Stationarized OFI literature; Lee & Ready (tick-rule trade classification, 1991); Easley, López de Prado & O'Hara (Bulk Volume Classification and VPIN flow toxicity, 2012); Amihud (the illiquidity measure, 2002); the Hawkes self-exciting process literature (Bacry, Muzy, and others); and Kolm, Turiel & Westray (multi-horizon order-flow alpha, 2023).

## DISCLAIMER

This indicator is provided for research and educational purposes only. It is not financial, investment, or trading advice and makes no promise of profitability. Order-flow imbalance here is an approximation, not exchange-grade Level-2 data. Trading involves substantial risk of loss; past behaviour does not guarantee future results. You are solely responsible for your own decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ============================================================================
//  © Market_Logic_India                                              MPL-2.0 · v2.0
//  ORDER FLOW IMBALANCE REGIME ENGINE
//  A single, self-consistent engine that reconstructs a proxy for order-flow
//  imbalance from price/volume and turns it into price-impact, liquidity,
//  self-excitation and market-regime read-outs. Works on any symbol, any market.
// ----------------------------------------------------------------------------
//  CHANGELOG
//    v2.0 — Three additive layers; the regime, impact and dashboard maths are unchanged:
//      • Robust standardization (default ON): the imbalance is now z-scored with
//        median / median-absolute-deviation (×1.4826) instead of mean/stdev. OFI
//        spikes hard on sweeps; MAD ignores those outliers so the pressure read and
//        the multi-horizon consensus stay calibrated. "Stationarization mode" =
//        "Classic (mean/stdev)" reproduces the original v1 output exactly.
//      • VSA bar events (optional, alert-only): named Wyckoff / effort-vs-result
//        events — Upthrust, Shakeout, Stopping Volume, Buying/Selling Climax —
//        plus an optional time-of-day volume baseline. Alerts only; no new plots.
//      • Absorption consensus (optional, alert-only): "a large imbalance that fails
//        to move price," measured FOUR independent ways on the same imbalance spine,
//        firing only when ≥ N of 4 agree. One alert; no new plots.
//    Both alert layers are alert-only by design because this pane is already
//    plot-dense — the softmax regime classifier and every dashboard read-out are
//    byte-for-byte unchanged from v1.
// ----------------------------------------------------------------------------
//  WHY A UNIFIED ENGINE (not a mashup of unrelated tools):
//  Every block is derived from ONE underlying quantity — reconstructed buy vs
//  sell pressure (synthetic OFI) — and each stage consumes the previous one,
//  all feeding ONE output: a probability distribution over market regimes.
//    classify -> standardize -> scale to price impact (Kyle λ) -> measure
//    across horizons -> test self-excitation -> assess liquidity fragility ->
//    optional cross-asset confirmation -> regime probabilities.
//  Remove any stage and the classifier loses an input; that dependency is the
//  reason the components live in one script rather than side by side.
// ----------------------------------------------------------------------------
//  HOW TO READ IT (lower pane + a dashboard)
//    Columns = the standardized order-flow imbalance (green up / red down);
//    the orange line is the multi-horizon consensus; dotted lines are z-score
//    reference bands. A background tint marks an active self-excitation cascade.
//    Triangles on PRICE mark the first bar of a buy/sell cascade. The dashboard
//    states, in plain language, the ACTION the current read implies, the market
//    REGIME, buy/sell pressure, an expected move in ATR (Kyle λ), cascade
//    strength, liquidity stress, the regime probabilities and cross-asset check.
//  HOW TO USE IT
//    A CONTEXT engine, not a buy/sell system: use the REGIME + ACTION line to
//    decide which of your own tools to trust — go with flow in TREND, await the
//    break in SQUEEZE, fade extremes in MEAN REVERSION, respect momentum in
//    CASCADE BLAST, and reduce size in LIQUIDITY SHOCK. Defaults are tuned for
//    liquid index futures (e.g. NIFTY / BankNifty); change "Price source" and
//    "Volume source" to run it on any instrument in any market.
// ----------------------------------------------------------------------------
//  ACADEMIC CREDIT (public concepts this engine approximates on OHLCV data):
//    - Cont, Kukanov & Stoikov (2014) — OFI & linear price impact (slope ∝ 1/depth)
//    - Kyle (1985)                     — λ price-impact coefficient / market depth
//    - Xu, Gould & Howison (2018)      — Multi-level / net order-flow imbalance
//    - Cont, Cucuringu & Zhang (2023)  — Integrated & lagged cross-asset OFI
//    - Stationarized / Generalized OFI (arXiv:2112.02947)
//    - Lee & Ready (1991)              — tick-rule trade classification
//    - Easley, López de Prado & O'Hara (2012) — Bulk Volume Classification & VPIN
//    - Easley, Kiefer, O'Hara & Paperman (1996) — PIN (structural parent of VPIN)
//    - Amihud (2002)                   — illiquidity (|return|/volume)
//    - Hawkes self-exciting point processes (Bacry, Muzy, et al.)
//    - Kolm, Turiel & Westray (2023)   — Multi-horizon order-flow alpha
//    - Sirignano & Cont (2019)         — order flow drives price formation
//  Independent, original implementation; no third-party code reused.
// ----------------------------------------------------------------------------
//  IMPORTANT / HONESTY: A charting platform exposes no Level-2 order book. True
//  OFI is a book quantity, so this is a disciplined PROXY from intrabar volume /
//  candle geometry / bulk classification — an approximation, not exchange-grade
//  flow. Note: against tick-level benchmarks Bulk Volume Classification can be
//  inferior to a true tick rule, and VPIN's content partly reflects trading
//  intensity — both are exposed as options so the read is comparable, not
//  claimed as ground truth.
//  REPAINTING: intrabar and cross-asset requests update on the live bar.
//  "Confirm signals on bar close" (default ON) makes plotted signals & alerts
//  evaluate only on closed bars (non-repainting).
//  DISCLAIMER: Research/education only. Not financial advice. Markets carry
//  risk; past behaviour does not guarantee future results.
// ============================================================================

indicator("Order Flow Imbalance Regime Engine", shorttitle="OFI Regime", overlay=false, max_bars_back=3000)

// ============================================================================
//  INPUTS — organised by engine stage
// ============================================================================
gData = "▸ Data & Engine"
src_price  = input.source(close, "Price source", group=gData, tooltip="Price series for the return / impact / regime calculations. Change it to run the engine on any instrument. Candle-geometry classification and the round-level feature still use the chart's own OHLC.")
src_vol    = input.source(volume, "Volume source", group=gData, tooltip="Use 'volume' for most assets. On instruments with no real volume the engine auto-falls back to a tick-based proxy so it still works.")
classMethod= input.string("Intrabar Tick Rule", "Classification method", options=["Intrabar Tick Rule","Bulk Volume Classification","Candle Geometry"], group=gData, tooltip="Intrabar Tick Rule: tags lower-TF bars buy/sell (most faithful when intrabar data exists). Bulk Volume Classification (Easley-López de Prado-O'Hara): probabilistically splits each bar's volume via a normal CDF of its standardized return — designed for bar-aggregated data and consistent with the VPIN layer. Candle Geometry: splits by close position within range.")
ltf        = input.timeframe("1", "Intrabar resolution", group=gData)
antiRep    = input.bool(true, "Confirm signals on bar close (non-repainting)", group=gData, tooltip="When ON, plotted signals and alerts only evaluate on closed bars. Dashboard read-outs still update live.")

gOFI = "▸ Order Flow Imbalance"
zLen   = input.int(50, "Stationarization lookback (z-score)", minval=10, maxval=500, group=gOFI, tooltip="Raw imbalance is non-stationary. It is standardized over this window so values compare across assets and sessions.")
zMode  = input.string("Robust (MAD)", "Stationarization mode", options=["Robust (MAD)","Classic (mean/stdev)"], group=gOFI, tooltip="Robust (MAD) standardizes OFI with median / median-absolute-deviation (×1.4826), so sweep-driven spikes don't distort the read. Classic reproduces the original v1 mean/stdev z.")
bvcLen = input.int(30, "BVC volatility lookback", minval=5, maxval=300, group=gOFI, tooltip="Only used by Bulk Volume Classification: window for the standard deviation of bar returns inside the normal CDF.")

gImp = "▸ Price Impact (Kyle λ)"
kyleLen = input.int(50, "Kyle λ regression window", minval=10, maxval=500, group=gImp, tooltip="Estimates λ by regressing bar return on signed flow (Kyle 1985). Expected move = λ · OFI; market depth ≈ 1/λ. Reproduces the founding result that impact scales inversely with depth.")

gHor = "▸ Multi-Horizon Consensus"
fastL = input.int(5,  "Fast horizon",  minval=2, inline="h", group=gHor)
midL  = input.int(20, "Mid",   minval=3, inline="h", group=gHor)
slowL = input.int(50, "Slow",  minval=5, inline="h", group=gHor)

gHawk = "▸ Self-Excitation (Hawkes)"
hAlpha = input.float(1.0, "Excitation gain (α)", minval=0.1, maxval=5.0, step=0.1, group=gHawk, tooltip="How strongly a flow event boosts further same-side flow.")
hBeta  = input.float(0.35,"Decay rate (β)",      minval=0.05, maxval=2.0, step=0.05, group=gHawk, tooltip="How fast self-excitation fades. Higher = shorter memory.")
hThr   = input.float(0.6, "Event trigger |imbalance|", minval=0.1, maxval=1.0, step=0.05, group=gHawk)
prWin  = input.int(200, "Percentile-rank window", minval=50, maxval=1000, group=gHawk, tooltip="Cascade strength and liquidity stress are ranked over this window for a stable, comparable 0-100 reading.")

gLiq = "▸ Liquidity Stress"
vpinWin = input.int(50, "Toxicity window (bars)", minval=10, group=gLiq, tooltip="Flow-toxicity (VPIN-style) accumulation window.")
atrLen  = input.int(14, "ATR length", minval=5, group=gLiq)
volLen  = input.int(50, "Relative-volume baseline", minval=10, group=gLiq, tooltip="Liquidity Stress is the mean percentile of three orthogonal lenses: VPIN toxicity, thin-book vacuum, and Amihud illiquidity (|return|/volume).")

gCross = "▸ Cross-Asset Confirmation"
useX = input.bool(true, "Enable cross-asset confirmation", group=gCross)
xSym = input.symbol("NSE:BANKNIFTY", "Correlated reference symbol", group=gCross, tooltip="Default is BANKNIFTY (correlated with NIFTY). Change to any asset correlated with your chart instrument — NIFTY-family options include BANKNIFTY, FINNIFTY and INDIA VIX; for other markets use a sector index, lead future, or benchmark. Lagged cross-asset imbalance is short-horizon predictive only; used here purely as confirmation.")

gPin = "▸ Round-Level Magnet"
usePin  = input.bool(true, "Enable round-level magnet", group=gPin, tooltip="Proximity-to-round-level heuristic flagging potential pinning. NOT options dealer gamma (which needs options open-interest data unavailable on a price chart).")
pinAuto = input.bool(true, "Auto-scale level spacing", group=gPin, tooltip="Derives sensible round-level spacing from price so it works on any asset.")
pinStep = input.float(100.0, "Manual level spacing", minval=0.0, group=gPin)

gReg = "▸ Regime Classifier"
sqzSens = input.float(1.4, "Squeeze sensitivity", minval=0.2, maxval=3.0, step=0.1, group=gReg, tooltip="Lower if the Squeeze regime dominates on compression-prone instruments (e.g. index futures).")

gUI = "▸ Dashboard & Visuals"
showOsc  = input.bool(true, "Plot OFI oscillator", group=gUI)
showSig  = input.bool(true, "Plot cascade signals on price", group=gUI)
showHeat = input.bool(true, "Cascade background heat", group=gUI)
showBands= input.bool(true, "Z-score reference bands", group=gUI)
tblPos = input.string("Top Right", "Dashboard position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gUI)
tblSz  = input.string("Small", "Dashboard size", options=["Tiny","Small","Normal","Large"], group=gUI, tooltip="If the panel is clipped, drag the indicator pane taller.")

// ============================================================================
//  HELPERS
// ============================================================================
sgn(x)    => x > 0 ? 1 : x < 0 ? -1 : 0
squash(x) => x / (1.0 + math.abs(x))
prank(s, l) =>
    p = ta.percentrank(s, l)
    na(p) ? 50.0 : p
// Standard normal CDF (Abramowitz-Stegun erf approximation) — used by BVC
ncdf(x) =>
    z = x / math.sqrt(2.0)
    t = 1.0 / (1.0 + 0.3275911 * math.abs(z))
    y = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * math.exp(-z * z)
    erf = z >= 0 ? y : -y
    0.5 * (1.0 + erf)

// Precomputed (unconditional) series so historical state stays consistent
effVol = na(src_vol) or src_vol == 0 ? 1.0 : src_vol
atrv   = ta.atr(atrLen)
chg    = src_price - src_price[1]
bvcSig = ta.stdev(chg, bvcLen)

// ============================================================================
//  STAGE 1 · SYNTHETIC OFI  — reconstruct buy vs sell pressure
//  Method 1 Intrabar tick rule · Method 2 Bulk Volume Classification · Method 3 Geometry
// ============================================================================
float buyV  = 0.0
float sellV = 0.0

if classMethod == "Intrabar Tick Rule"
    [aO, aC, aV] = request.security_lower_tf(syminfo.tickerid, ltf, [open, close, src_vol])
    if array.size(aC) > 0
        for i = 0 to array.size(aC) - 1
            o = array.get(aO, i)
            c = array.get(aC, i)
            v = array.get(aV, i)
            vv = na(v) or v == 0 ? 1.0 : v
            if c > o
                buyV  += vv
            else if c < o
                sellV += vv
            else
                buyV  += vv * 0.5
                sellV += vv * 0.5

if classMethod == "Bulk Volume Classification"
    zb = bvcSig > 0 ? chg / bvcSig : 0.0
    bf = ncdf(zb)                                   // probability bar is buyer-initiated
    buyV  := effVol * bf
    sellV := effVol * (1.0 - bf)

if classMethod == "Candle Geometry" or (buyV + sellV == 0.0)
    rng0 = high - low
    if rng0 > 0
        buyV  := effVol * (close - low) / rng0
        sellV := effVol * (high - close) / rng0
    else
        buyV  := effVol * 0.5
        sellV := effVol * 0.5

totV   = buyV + sellV
rawOFI = buyV - sellV
imb    = totV > 0 ? rawOFI / totV : 0.0

// v2.0: compute classic and robust standardization unconditionally, then select
ofiMean = ta.sma(rawOFI, zLen)
ofiSd   = ta.stdev(rawOFI, zLen)
ofiMed  = ta.median(rawOFI, zLen)
ofiMad  = ta.median(math.abs(rawOFI - ofiMed), zLen)
ofiZc   = ofiSd > 0 ? (rawOFI - ofiMean) / ofiSd : 0.0
ofiZr   = ofiMad > 1e-10 ? (rawOFI - ofiMed) / (1.4826 * ofiMad) : 0.0
ofiZ    = zMode == "Classic (mean/stdev)" ? ofiZc : ofiZr
ofiZ   := math.max(math.min(ofiZ, 4.0), -4.0)

press     = 50.0 * (1.0 + squash(ofiZ * 0.9))
buyPress  = press
sellPress = 100.0 - press

// ============================================================================
//  STAGE 1b · PRICE IMPACT (Kyle λ)  — scale OFI into an expected price move
//  λ = slope of bar return on signed flow; depth ≈ 1/λ; expMove = λ · OFI
// ============================================================================
svStd  = ta.stdev(rawOFI, kyleLen)
dpStd  = ta.stdev(chg, kyleLen)
corrSd = ta.correlation(rawOFI, chg, kyleLen)
kyleLambda = svStd > 0 and not na(corrSd) ? corrSd * dpStd / svStd : 0.0
kyleLambda := math.max(kyleLambda, 0.0)            // impact is non-negative
expMove    = kyleLambda * rawOFI                   // expected move, price units
expMoveATR = atrv > 0 ? expMove / atrv : 0.0       // scale-free (ATR units)

// ============================================================================
//  STAGE 2 · MULTI-HORIZON CONSENSUS
// ============================================================================
zFast = ta.ema(ofiZ, fastL)
zMid  = ta.ema(ofiZ, midL)
zSlow = ta.ema(ofiZ, slowL)
agree = sgn(zFast) + sgn(zMid) + sgn(zSlow)
consensus   = (zFast + zMid + zSlow) / 3.0
consAligned = math.abs(agree) == 3

// ============================================================================
//  STAGE 3 · SELF-EXCITATION (Hawkes)
// ============================================================================
var float lamBuy  = 0.0
var float lamSell = 0.0
decay   = math.exp(-hBeta)
buyEvt  = imb >  hThr ?  imb : 0.0
sellEvt = imb < -hThr ? -imb : 0.0
lamBuy  := lamBuy  * decay + hAlpha * buyEvt
lamSell := lamSell * decay + hAlpha * sellEvt
cascRaw = lamBuy + lamSell
cascStr = prank(cascRaw, prWin)
cascDir = lamBuy - lamSell
cascNet = (lamBuy + lamSell) > 0 ? (lamBuy - lamSell) / (lamBuy + lamSell) : 0.0

// ============================================================================
//  STAGE 4 · LIQUIDITY STRESS — three orthogonal lenses, percentile-averaged
//  (1) VPIN toxicity  (2) thin-book vacuum  (3) Amihud illiquidity
// ============================================================================
absImb  = math.abs(rawOFI)
sumTotV = math.sum(totV, vpinWin)
vpin    = sumTotV > 0 ? math.sum(absImb, vpinWin) / sumTotV : 0.0
rangeExp= atrv > 0 ? ta.tr / atrv : 1.0
baseVol = ta.sma(effVol, volLen)
relVol  = baseVol > 0 ? effVol / baseVol : 1.0
vacuum  = rangeExp / math.max(relVol, 0.2)
ret     = src_price[1] != 0 ? math.abs(chg / src_price[1]) : 0.0
amihud  = (src_price * effVol) > 0 ? ret / (src_price * effVol) : 0.0
liqStress = (prank(vpin, prWin) + prank(vacuum, prWin) + prank(amihud, prWin)) / 3.0

// ============================================================================
//  STAGE 5 · CROSS-ASSET CONFIRMATION (lagged geometry proxy)
// ============================================================================
xDeltaExpr = (high - low) > 0 ? (na(volume) ? 1.0 : volume) * ((close - low) - (high - close)) / (high - low) : 0.0
xRaw   = useX ? request.security(xSym, timeframe.period, xDeltaExpr, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true) : na
xMean  = useX ? ta.sma(xRaw, zLen) : na
xSd    = useX ? ta.stdev(xRaw, zLen) : na
xZ     = useX and not na(xSd) and xSd > 0 ? (xRaw - xMean) / xSd : na
xZlag  = useX ? xZ[1] : na
xConfirm = useX and not na(xZlag) ? (sgn(xZlag) == sgn(ofiZ) and math.abs(xZlag) > 0.5) : false

// ============================================================================
//  STAGE 6 · ROUND-LEVEL MAGNET (proximity heuristic — not dealer gamma)
// ============================================================================
stepAuto = math.pow(10, math.round(math.log10(math.max(close, 1e-8) * 0.005)))
effStep  = pinAuto ? stepAuto : pinStep
pinDist  = usePin and effStep > 0 ? math.abs(close - math.round(close / effStep) * effStep) / effStep : na
pinMag   = usePin and not na(pinDist) ? 100.0 * (1.0 - math.min(pinDist * 2.0, 1.0)) : na

// ============================================================================
//  STAGE 7 · REGIME CLASSIFIER (softmax over flow-derived features)
// ============================================================================
// squeeze = Bollinger width (4σ) compressed inside Keltner width (2 × 1.5·ATR)
bbW   = 4.0 * ta.stdev(src_price, 20)
kcW   = 3.0 * atrv
squeezeOn = bbW < kcW

vw      = ta.vwap(hlc3)
stretch = atrv > 0 ? (src_price - vw) / atrv : 0.0
rsi     = ta.rsi(src_price, 14)
rsiExt  = math.max(rsi - 70.0, 30.0 - rsi) / 30.0
ofiDiv  = sgn(ta.change(src_price, 3)) != sgn(consensus) and math.abs(consensus) > 0.3

sTrend  = 0.9 * math.abs(consensus) + (consAligned ? 0.8 : 0.0) + 0.5 * math.abs(cascNet) * (sgn(cascDir) == sgn(consensus) ? 1.0 : 0.0) + 0.4 * math.min(math.abs(expMoveATR), 1.5)
sSqueeze= (squeezeOn ? sqzSens : 0.0) + 0.6 * math.max(0.0, 1.2 - rangeExp)
sBlast  = 0.012 * cascStr + (not squeezeOn and squeezeOn[3] ? 1.0 : 0.0) + 0.6 * math.abs(cascNet)
sRevert = (ofiDiv ? 1.0 : 0.0) + 0.5 * math.abs(stretch) + 0.6 * math.max(0.0, rsiExt)
sShock  = 0.018 * liqStress + 0.5 * math.max(0.0, rangeExp - 1.5)

e1 = math.exp(sTrend)
e2 = math.exp(sSqueeze)
e3 = math.exp(sBlast)
e4 = math.exp(sRevert)
e5 = math.exp(sShock)
eS = e1 + e2 + e3 + e4 + e5
pTrend   = 100.0 * e1 / eS
pSqueeze = 100.0 * e2 / eS
pBlast   = 100.0 * e3 / eS
pRevert  = 100.0 * e4 / eS
pShock   = 100.0 * e5 / eS

pMax = math.max(pTrend, math.max(pSqueeze, math.max(pBlast, math.max(pRevert, pShock))))
regime = pMax == pTrend ? "TREND CONTINUE" : pMax == pSqueeze ? "SQUEEZE" : pMax == pBlast ? "CASCADE BLAST" : pMax == pRevert ? "MEAN REVERSION" : "LIQUIDITY SHOCK"
regCol = pMax == pTrend ? #26a69a : pMax == pSqueeze ? #fbc02d : pMax == pBlast ? #ab47bc : pMax == pRevert ? #42a5f5 : #ef5350
regTxt = pMax == pSqueeze ? color.black : color.white

// ============================================================================
//  PLOTS — decluttered oscillator
// ============================================================================
absZ   = math.abs(ofiZ)
colUp  = color.from_gradient(absZ, 0, 3, color.new(#26a69a,72), color.new(#26a69a,0))
colDn  = color.from_gradient(absZ, 0, 3, color.new(#ef5350,72), color.new(#ef5350,0))
ofiCol = ofiZ >= 0 ? colUp : colDn
plot(showOsc ? ofiZ : na, "OFI z-score", color=ofiCol, style=plot.style_columns)
plot(showOsc ? consensus : na, "Consensus", color=color.new(#ffa726,0), linewidth=2)

hline(showOsc and showBands ?  0 : na, "Zero", color=color.new(chart.fg_color, 55))
hb1 = hline(showOsc and showBands ?  1 : na, "+1", color=color.new(chart.fg_color, 80), linestyle=hline.style_dotted)
hbm1= hline(showOsc and showBands ? -1 : na, "-1", color=color.new(chart.fg_color, 80), linestyle=hline.style_dotted)
hline(showOsc and showBands ?  2 : na, "+2", color=color.new(chart.fg_color, 88), linestyle=hline.style_dotted)
hline(showOsc and showBands ? -2 : na, "-2", color=color.new(chart.fg_color, 88), linestyle=hline.style_dotted)
fill(hb1, hbm1, color=color.new(chart.fg_color, 95), title="Neutral zone")

heatTransp = 100 - int(math.min((cascStr / 100.0) * 45.0, 45.0))
cascCol = cascDir >= 0 ? color.new(#26a69a, heatTransp) : color.new(#ef5350, heatTransp)
bgcolor(showOsc and showHeat and cascStr > 55 ? cascCol : na, title="Cascade heat")

// ============================================================================
//  SIGNALS — first bar of each cascade, on the price chart (force-overlay)
// ============================================================================
gate        = not antiRep or barstate.isconfirmed
buyCascade  = gate and cascDir > 0 and cascStr > 60 and ofiZ > 0.5 and (not useX or xConfirm)
sellCascade = gate and cascDir < 0 and cascStr > 60 and ofiZ < -0.5 and (not useX or xConfirm)
buyTrig  = buyCascade  and not buyCascade[1]
sellTrig = sellCascade and not sellCascade[1]
plotshape(showSig and buyTrig,  title="Buy Cascade",  style=shape.triangleup,   location=location.belowbar, color=color.new(#26a69a,0), size=size.small, force_overlay=true)
plotshape(showSig and sellTrig, title="Sell Cascade", style=shape.triangledown, location=location.abovebar, color=color.new(#ef5350,0), size=size.small, force_overlay=true)
plotchar(showSig and buyTrig  ? ofiZ : na, title="Buy mark",  char="▲", location=location.absolute, color=color.new(#26a69a,0), size=size.tiny)
plotchar(showSig and sellTrig ? ofiZ : na, title="Sell mark", char="▼", location=location.absolute, color=color.new(#ef5350,0), size=size.tiny)

// ============================================================================
//  ALERTS
// ============================================================================
alertcondition(buyTrig,  "Buy Cascade",      "OFI Regime: buy-side self-excitation cascade")
alertcondition(sellTrig, "Sell Cascade",     "OFI Regime: sell-side self-excitation cascade")
alertcondition(gate and pShock > 40, "Liquidity Shock", "OFI Regime: liquidity stress elevated")
alertcondition(gate and not squeezeOn and squeezeOn[1], "Squeeze Fire", "OFI Regime: volatility squeeze released")

// ============================================================================
//  DASHBOARD — adaptive to chart background, plain-language at the top
// ============================================================================
posV = tblPos == "Top Right" ? position.top_right : tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : position.middle_right
szV  = tblSz == "Tiny" ? size.tiny : tblSz == "Small" ? size.small : tblSz == "Large" ? size.large : size.normal

// theme: a solid panel that stays readable on ANY chart background (auto light/dark)
f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
bool dashDark = f_luma(chart.bg_color) < 140
color cPanel = dashDark ? color.rgb(17, 22, 28)   : color.rgb(244, 246, 248)
color cRowA  = dashDark ? color.rgb(24, 30, 38)   : color.rgb(236, 239, 243)
color cRowB  = dashDark ? color.rgb(17, 22, 28)   : color.rgb(248, 250, 252)
color cTxt   = dashDark ? color.rgb(232, 238, 244) : color.rgb(20, 26, 32)
color cDim   = dashDark ? color.rgb(150, 162, 174) : color.rgb(96, 106, 116)
color cFrame = dashDark ? color.rgb(52, 60, 70)   : color.rgb(200, 206, 212)
color cUp    = dashDark ? #2dd4bf : #0e9e76
color cDn    = dashDark ? #ff6b6b : #d32f2f
color cWarn  = dashDark ? #ffb050 : #b06800
color cInfo  = dashDark ? #42a5f5 : #1565c0
color cPurp  = dashDark ? #ab7cf0 : #7b1fa2
color cMute  = dashDark ? #6b7480 : #98a0ab

heat(v) => v >= 65 ? cUp : v >= 45 ? cDim : cDn
bar(v)  => v >= 80 ? "██████" : v >= 65 ? "█████░" : v >= 50 ? "████░░" : v >= 35 ? "███░░░" : v >= 20 ? "██░░░░" : v >= 10 ? "█░░░░░" : "░░░░░░"
modeLbl = classMethod == "Intrabar Tick Rule" ? "tick " + ltf : classMethod == "Bulk Volume Classification" ? "BVC" : "geom"

// plain-language ACTION (what the current read means) — for non-technical users
int flowBias = consensus > 0.25 or buyPress >= 58 ? 1 : consensus < -0.25 or sellPress >= 58 ? -1 : 0
string actTxt = buyTrig ? "BUY CASCADE ▲" : sellTrig ? "SELL CASCADE ▼" : regime == "LIQUIDITY SHOCK" ? "REDUCE · STRESS" : regime == "SQUEEZE" ? "COILED · AWAIT BREAK" : regime == "MEAN REVERSION" ? (flowBias > 0 ? "FADE THE RALLY" : flowBias < 0 ? "FADE THE DIP" : "FADE EXTREMES") : regime == "CASCADE BLAST" ? (flowBias > 0 ? "MOMENTUM ▲" : flowBias < 0 ? "MOMENTUM ▼" : "MOMENTUM BURST") : flowBias > 0 ? "WITH TREND ▲" : flowBias < 0 ? "WITH TREND ▼" : "BALANCED · WAIT"
color actCol = buyTrig ? cUp : sellTrig ? cDn : regime == "LIQUIDITY SHOCK" ? cDn : regime == "SQUEEZE" ? cWarn : regime == "MEAN REVERSION" ? cInfo : regime == "CASCADE BLAST" ? cPurp : flowBias > 0 ? cUp : flowBias < 0 ? cDn : cMute
color actTxtC = (not buyTrig and not sellTrig and regime == "SQUEEZE") ? color.black : color.white

var table dash = table.new(posV, 2, 12, border_width=1, frame_color=cFrame, frame_width=1)

if barstate.islast
    table.set_frame_color(dash, cFrame)
    table.set_border_color(dash, cFrame)
    table.cell(dash, 0, 0, " ORDER FLOW REGIME", text_color=cTxt, text_size=szV, text_halign=text.align_left,  bgcolor=cPanel)
    table.cell(dash, 1, 0, modeLbl, text_color=cDim, text_size=szV, text_halign=text.align_right, bgcolor=cPanel)
    table.cell(dash, 0, 1, " " + actTxt + " ", text_color=actTxtC, text_size=szV, text_halign=text.align_left,  bgcolor=color.new(actCol, 0))
    table.cell(dash, 1, 1, (flowBias > 0 ? "bias ▲ " : flowBias < 0 ? "bias ▼ " : "bias — "), text_color=actTxtC, text_size=szV, text_halign=text.align_right, bgcolor=color.new(actCol, 0))
    table.cell(dash, 0, 2, "REGIME", text_color=cTxt, text_size=szV, text_halign=text.align_left,  bgcolor=cRowA)
    table.cell(dash, 1, 2, regime, text_color=regTxt, text_size=szV, text_halign=text.align_right, bgcolor=color.new(regCol, 0))
    table.cell(dash, 0, 3, "BUY PRESS",  text_color=cTxt, text_size=szV, text_halign=text.align_left,  bgcolor=cRowB)
    table.cell(dash, 1, 3, str.tostring(buyPress, "#") + " " + bar(buyPress), text_color=heat(buyPress), text_size=szV, text_halign=text.align_right, bgcolor=cRowB)
    table.cell(dash, 0, 4, "SELL PRESS", text_color=cTxt, text_size=szV, text_halign=text.align_left,  bgcolor=cRowA)
    table.cell(dash, 1, 4, str.tostring(sellPress, "#") + " " + bar(sellPress), text_color=heat(100 - sellPress), text_size=szV, text_halign=text.align_right, bgcolor=cRowA)
    table.cell(dash, 0, 5, "OFI z · cons", text_color=cTxt, text_size=szV, text_halign=text.align_left,  bgcolor=cRowB)
    table.cell(dash, 1, 5, str.tostring(ofiZ, "0.00") + "  " + (agree > 0 ? "+" : "") + str.tostring(agree) + "/3" + (consAligned ? "✓" : ""), text_color=ofiZ >= 0 ? cUp : cDn, text_size=szV, text_halign=text.align_right, bgcolor=cRowB)
    table.cell(dash, 0, 6, "EXP MOVE (λ)", text_color=cTxt, text_size=szV, text_halign=text.align_left,  bgcolor=cRowA)
    table.cell(dash, 1, 6, str.tostring(expMoveATR, "0.00") + " ATR " + (expMove > 0 ? "▲" : expMove < 0 ? "▼" : "—"), text_color=expMove > 0 ? cUp : expMove < 0 ? cDn : cDim, text_size=szV, text_halign=text.align_right, bgcolor=cRowA)
    table.cell(dash, 0, 7, "CASCADE", text_color=cTxt, text_size=szV, text_halign=text.align_left,  bgcolor=cRowB)
    table.cell(dash, 1, 7, str.tostring(cascStr, "#") + " " + (cascDir > 0 ? "▲BUY" : cascDir < 0 ? "▼SELL" : "—"), text_color=cascDir > 0 ? cUp : cascDir < 0 ? cDn : cDim, text_size=szV, text_halign=text.align_right, bgcolor=cRowB)
    table.cell(dash, 0, 8, "LIQ STRESS", text_color=cTxt, text_size=szV, text_halign=text.align_left,  bgcolor=cRowA)
    table.cell(dash, 1, 8, str.tostring(liqStress, "#") + " " + bar(liqStress), text_color=heat(100 - liqStress), text_size=szV, text_halign=text.align_right, bgcolor=cRowA)
    table.cell(dash, 0, 9, "Trend / Squz", text_color=cDim, text_size=szV, text_halign=text.align_left,  bgcolor=cRowB)
    table.cell(dash, 1, 9, str.tostring(pTrend, "#") + "% / " + str.tostring(pSqueeze, "#") + "%", text_color=cTxt, text_size=szV, text_halign=text.align_right, bgcolor=cRowB)
    table.cell(dash, 0, 10, "Blst/Rev/Shk", text_color=cDim, text_size=szV, text_halign=text.align_left,  bgcolor=cRowA)
    table.cell(dash, 1, 10, str.tostring(pBlast, "#") + "/" + str.tostring(pRevert, "#") + "/" + str.tostring(pShock, "#") + "%", text_color=cTxt, text_size=szV, text_halign=text.align_right, bgcolor=cRowA)
    xtxt = useX ? (xConfirm ? "confirm ✓" : "no confirm") : (usePin and not na(pinMag) ? "pin " + str.tostring(pinMag, "#") : "off")
    table.cell(dash, 0, 11, "CROSS-ASSET", text_color=cDim, text_size=szV, text_halign=text.align_left,  bgcolor=cRowB)
    table.cell(dash, 1, 11, xtxt, text_color=useX and xConfirm ? cUp : cDim, text_size=szV, text_halign=text.align_right, bgcolor=cRowB)

// ═══════════════════════════════════════════════════════════════════════════════
// VSA BAR EVENTS (v2.0 · Wyckoff effort-vs-result taxonomy, inlined) + time-of-day volume — OPTIONAL.
//   This pane is plot-dense, so VSA is exposed via ALERTS ONLY (no marker/export plots). Names the
//   dominant Wyckoff/VSA effort-vs-result event; all ta.* unconditional; engine/dashboard untouched.
// ═══════════════════════════════════════════════════════════════════════════════
gVSA_wd   = "VSA bar events"
vsaLen    = input.int(50, "VSA history window", minval = 10, maxval = 300, group = gVSA_wd, tooltip = "Named Wyckoff/VSA events (Upthrust / Shakeout / Stopping Volume / Climax) available as alertconditions.")
vsaPiv    = input.int(5,  "New-extreme lookback", minval = 2, maxval = 50, group = gVSA_wd)
vsaTod    = input.bool(false, "Time-of-day volume", group = gVSA_wd, tooltip = "ON: judge volume against the same time-of-day slot on prior sessions. Default off.")
vsaTodMin = input.int(5,  "  Slot size (minutes)", minval = 1, maxval = 60, group = gVSA_wd)
vsaTodSes = input.int(20, "  Session memory", minval = 3, maxval = 200, group = gVSA_wd)

gABS = "Absorption consensus"
absLen     = input.int(50,   "Absorption window", minval = 10, maxval = 300, group = gABS, tooltip = "Effort-vs-result ABSORPTION measured four independent ways on the imbalance spine — (1) OLS residual of Δprice on OFI, (2) cost-per-tick percentile, (3) dominance−result, (4) high-effort/narrow-spread — firing only when ≥ N of 4 agree. Absorption = a large imbalance that fails to move price. Exposed via the 'Absorption consensus' alert (this pane is plot-dense). Additive — the engine is unchanged.")
absZThr    = input.float(2.0,  "Residual-z threshold", minval = 0.5, step = 0.1, group = gABS)
absCostThr = input.float(90.0, "Cost-per-tick pct threshold", minval = 50, maxval = 99.9, group = gABS)
absDomThr  = input.float(0.30, "Dominance−result threshold", minval = 0.0, maxval = 1.0, step = 0.05, group = gABS)
absMinAgree= input.int(3,    "Methods needed to confirm (of 4)", minval = 1, maxval = 4, group = gABS)
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

// ── ABSORPTION CONSENSUS (v2.0 · 4-way effort-vs-result, inlined) ──────────
// Consumes the imbalance spine (rawOFI / buyV / sellV) + VSA percentiles (vsaVp / vsaSp). Four
// independent absorption measures; only "absorption" when >= absMinAgree agree. Alert-only
// (this pane is plot-dense, matching the VSA precedent). All ta.* unconditional; engine unchanged.
float abChg   = close - close[1]
float abMx    = ta.sma(rawOFI, absLen)
float abMy    = ta.sma(abChg, absLen)
float abCov   = ta.sma(rawOFI * abChg, absLen) - abMx * abMy
float abVx    = ta.sma(rawOFI * rawOFI, absLen) - abMx * abMx
float abB     = abVx > 1e-12 ? abCov / abVx : na
float abA     = na(abB) ? abMy : abMy - abB * abMx
float abResid = (na(abA) or na(abB)) ? na : abChg - (abA + abB * rawOFI)
float abRMu   = ta.sma(abResid, absLen)
float abRSd   = ta.stdev(abResid, absLen)
float abResidZ= abRSd > 1e-12 ? (abResid - abRMu) / abRSd : na
float abTicks = math.abs(abChg) / syminfo.mintick
float abCost  = math.abs(rawOFI) / math.max(abTicks, 1e-9)
float abCostP = ta.percentrank(abCost, absLen)
float abNet   = totV > 0.0 ? (buyV - sellV) / totV : 0.0
float abBuyD  = math.max(abNet, 0.0)
float abSellD = math.max(-abNet, 0.0)
float abRng   = high - low
float abClvU  = abRng > 0.0 ? (close - low) / abRng : 0.5
float abBodU  = abRng > 0.0 ? math.max(close - open, 0.0) / abRng : 0.0
float abBodD  = abRng > 0.0 ? math.max(open - close, 0.0) / abRng : 0.0
float abDomSc = math.max(abBuyD - (abBodU + abClvU) / 2.0, abSellD - (abBodD + (1.0 - abClvU)) / 2.0)
bool  abQual  = vsaVp >= 70.0 and vsaSp <= 35.0
int   abC     = (not na(abResidZ) and math.abs(abResidZ) >= absZThr ? 1 : 0) + (not na(abCostP) and abCostP >= absCostThr ? 1 : 0) + (abDomSc >= absDomThr ? 1 : 0) + (abQual ? 1 : 0)
bool  abIs    = abC >= absMinAgree
alertcondition(abIs, "Absorption consensus", "OFI Regime: absorption consensus — large imbalance failing to move price.")
````
