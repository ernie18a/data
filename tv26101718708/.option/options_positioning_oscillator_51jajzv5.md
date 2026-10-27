# Options Positioning Oscillator

- url: https://www.tradingview.com/script/51JAjZv5-Options-Positioning-Oscillator/
- type: indicator
- pine_id: PUB;b0303d46d1764dccb08b76bb8b3b84ac
- version: 2.0

## Description

Options Positioning Oscillator

What it does

The Options Positioning Oscillator is a single bounded line, scaled in standard-deviation (σ) units, that reads where derivatives positioning is leaning — risk-on (bullish) versus risk-off / hedged (bearish).

Most oscillators read price (RSI, Stochastic, MACD, etc.). This one deliberately does not. It reads the implied-volatility and futures-basis structure that sits underneath price, because hedging and positioning leave their footprint in the volatility surface and the cash-and-carry basis before they fully show up in price momentum. The output is one easy-to-read line with σ-banded extremes, so you can see at a glance whether positioning is neutral, leaning, or stretched.

Why these components are combined (mashup rationale)

This is not a bundle of unrelated indicators stacked for the sake of it. The three core legs are complementary, research-documented measurements of the same underlying quantity — the price of variance risk and the market's appetite for risk:


Implied-Volatility Rank — the level of implied vol within its own range (where fear sits historically).
Volatility Term-Structure — implied vol versus its own trend (the slope: calm/contango vs stressed/backwardation).
Futures Basis — the cash-and-carry premium or discount (demand and carry vs hedging pressure).


Each leg, on its own, is a noisy proxy for risk appetite. The academic literature shows each carries genuine information: implied volatility systematically exceeds subsequent realized volatility, producing a variance risk premium (Bakshi & Kapadia 2003; Carr & Wu 2009), and the shape/slope of the volatility term structure carries information about the price of variance risk that predicts volatility-asset returns incrementally to other proxies (Johnson 2017). Combining several noisy-but-informative proxies of one latent variable, on a common standardized scale, denoises any single proxy — a textbook signal-combination, which is exactly why the mashup is justified rather than arbitrary.

Two optional legs — Put-Call Ratio and Option Skew — extend the read for users who can supply that data as an external series. They are off by default because TradingView cannot natively pull live option-chain data; turning them on without a real source would feed price in their place, which would be wrong. The composite automatically re-balances around whatever legs are active.

How the components work together

Every leg is converted to a z-score on its native timeframe so they share one scale (the volatility legs are measured on a stable Daily timeframe by default, so "IV-rank" means the same thing whether you run a 5-minute or daily chart). The legs are sign-aligned so that up = bullish lean in every case:


high implied-vol level → bearish (subtracted)
steep/stressed term slope → bearish (subtracted)
premium futures basis → bullish (added)


They are then combined as a weighted average and lightly smoothed. The result is one line where positive = crowd leaning bullish/risk-on, negative = leaning bearish/hedged, and the dotted Extreme bands flag stretched positioning prone to mean-reversion.

How to use it


Read the level, not only the crosses. Above the +Lean band = bullish lean; below the −Lean band = bearish/hedged lean; beyond the dotted Extreme bands = stretched.
Turns out of an extreme (the triangles) are the actionable events — positioning unwinding from a stretched state.
Divergences (circles) warn when price and positioning disagree — e.g. price makes a higher high while positioning makes a lower high.
Read the EDGE row. The dashboard runs a live forward-return harness: for each turn it checks whether a favourable move (≥ k×ATR within the horizon) actually occurred, and compares that Hit % against the unconditional Base %. EDGE = Hit − Base is the only honest measure of whether the signal is doing anything on your instrument. If EDGE is near zero, the signal is not adding information on that market/timeframe — and the script tells you so.


Why it is original

It is not a re-skinned price oscillator. It is an options/volatility-native positioning gauge that (a) fuses the implied-vol level, term-structure slope, and futures basis into one standardized composite, (b) measures the volatility legs on a stable higher timeframe so the read is timeframe-consistent, and (c) ships with a built-in forward-return calibration harness that reports its own live edge instead of asking you to trust it. I am not aware of a published TradingView oscillator that combines these specific volatility-structure components with self-calibration.

Settings guide


01 · Data Sources — Cash, Futures and Implied-Vol-Index symbols (default NIFTY / NSE; change for any market), the timeframe for the volatility legs (default Daily), and a universal price source.
02 · Engine — IV-rank lookback, term mean length, normalization window, output smoothing.
03 · Component Weights — weight each leg; set a leg to 0 to drop it. Optional PCR / Skew legs (off by default; require external data).
04 · Calibration — horizon, favourable-move threshold (×ATR), base-rate window.
05 · Bands — Lean and Extreme σ bands; divergence pivot.
06 · Display & Theme — visual style (gradient area + glow / histogram / line), background regime tint, dashboard, colors.


Non-repaint

The volatility legs are requested with lookahead_off and settle on their bar's close — there is no future leak. Higher-timeframe values develop through the forming bar and confirm at its close, which is standard, intended behaviour.

Concept credit


Variance risk premium and its predictive content — Bakshi & Kapadia (2003); Carr & Wu (2009); Bollerslev, Tauchen & Zhou (2009).
Volatility term-structure slope and return predictability — Johnson, Risk Premia and the VIX Term Structure (2017).
Cash-and-carry futures basis — standard cost-of-carry theory.
Implied-volatility rank / percentile — established options-desk practice.


Disclaimer

For research and education only. This script is not financial advice, not a recommendation, and not a guarantee of future results. All statistics shown are in-sample, close-to-close, and exclude costs and slippage — a study aid, not a backtest. Do your own research and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
//@version=6
// ═════════════════════════════════════════════════════════════════════════════════════════════════
//  OPTIONS POSITIONING OSCILLATOR
// ─────────────────────────────────────────────────────────────────────────────────────────────────
//  OVERVIEW
//    One bounded line, in standard-deviation units, that reads where derivatives positioning is
//    leaning — risk-on (bullish) versus risk-off / hedged (bearish). Instead of reading price like a
//    momentum oscillator, it reads the VOLATILITY and FUTURES-BASIS structure that sits underneath
//    price, where hedging and positioning leave their footprint first.
//
//  WHY THESE PARTS ARE COMBINED (mashup rationale)
//    The three core legs are not arbitrary indicators bolted together — they are complementary,
//    research-documented facets of the SAME latent variable: the price of variance risk / the market's
//    appetite for risk.
//      • IMPLIED-VOL RANK  — the LEVEL of implied volatility (where fear sits in its own range).
//      • VOL TERM-STRUCTURE — the SLOPE of implied vol versus its own trend (stress vs calm).
//      • FUTURES BASIS      — the cash-and-carry premium/discount (demand vs hedging pressure).
//    Each is a noisy proxy for the same thing. Standardising them to one scale and averaging them
//    DENOISES any single proxy — a classic signal-combination, not a coincidental overlay. Two
//    optional legs (Put-Call Ratio, option Skew) extend the read where you can supply that data.
//
//  HOW IT WORKS
//    Each leg is converted to a standard-deviation (z) score on its NATIVE timeframe so they share one
//    scale, sign-aligned (high vol / steep term = bearish; premium basis = bullish), then combined as a
//    weighted average and lightly smoothed. Volatility legs are measured on a stable higher timeframe
//    (Daily by default) so the read means the same thing on any chart timeframe.
//
//  HOW TO USE
//    Read the line, not just its crosses: above +Lean band = crowd leaning bullish, below −Lean band =
//    leaning bearish/hedged; the dotted Extreme bands flag stretched positioning prone to reversal.
//    Turns OUT of an extreme (triangles) are the actionable events. Price-vs-line divergences warn when
//    price and positioning disagree. The dashboard's EDGE row measures, live, whether those turns
//    actually preceded a favourable move versus a random bar — read EDGE, not the signal.
//
//  UNIVERSAL / SOURCES
//    Every symbol, length, weight and the price source is an input. Defaults target NIFTY (NSE), but
//    point the symbols at any cash/futures/vol-index triplet to use it on any market. Legs you cannot
//    source can be weighted to zero and the composite re-balances automatically.
//
//  CONCEPT CREDIT (full references in the published description)
//    Variance-risk-premium and vol term-structure return predictability — Bakshi & Kapadia (2003),
//    Carr & Wu (2009), Bollerslev–Tauchen–Zhou (2009), Johnson (2017). Cash-and-carry basis — standard
//    cost-of-carry theory. Implied-vol rank/percentile — options-desk practice.
//
//  HONESTY
//    This is a DESCRIPTIVE positioning gauge, not a directional guarantee. Statistics are in-sample,
//    close-to-close, without costs — a study aid, not a backtest. Read the Edge row.
//
//  DISCLAIMER
//    For research and education only. NOT financial advice, NOT a recommendation, NOT a guarantee of
//    future results. Do your own research and manage your own risk.
//
//  Non-repaint: higher-timeframe legs use lookahead_off and settle on their bar's close; no future leak.
// ═════════════════════════════════════════════════════════════════════════════════════════════════
indicator("Options Positioning Oscillator", "Options Positioning", overlay = false, max_labels_count = 500)

// ═════ Z · IDENTITY & EXPORTS ════════════════════════════════════════════════════════════════
gZ = "Z · Identity & exports"
showId  = input.bool(true, "Show identity strip", group = gZ)
showEXP = input.bool(true, "Publish EXP_* outputs (Data Window)", group = gZ, tooltip = "Generic export bus: surfaces in the Data Window and in other scripts via input.source().")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if barstate.islast and showId
    bool idDark = (0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)) < 140
    table.cell(idT, 0, 0, "OPTIONS POSITIONING · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = idDark ? color.white : color.black, bgcolor = color.new(idDark ? color.black : color.white, 15))

// ─── 01 · DATA SOURCES ─────────────────────────────────────────────────────────────────────────
g1 = "01 · Data Sources"
spotSym = input.symbol("NSE:NIFTY",    "Cash / Spot Symbol", group = g1, tooltip = "Underlying cash index for the futures-basis leg. Change for other markets.")
futSym  = input.symbol("NSE:NIFTY1!",  "Futures Symbol",     group = g1, tooltip = "Continuous futures for the basis leg.")
vixSym  = input.symbol("NSE:INDIAVIX", "Implied-Vol Index",  group = g1, tooltip = "Implied-volatility index for the IV-rank and term-structure legs (e.g. INDIAVIX, VIX, VXN).")
statsTF = input.timeframe("D", "Vol-Leg Timeframe",          group = g1, tooltip = "Timeframe for the implied-vol legs so IV-rank/term mean the same thing on any chart. Daily is standard.")
srcPrice= input.source(close, "Price Source",                group = g1, tooltip = "Price series used for divergences and the Edge harness. Universal across assets.")

// ─── 02 · ENGINE ───────────────────────────────────────────────────────────────────────────────
g2 = "02 · Engine"
ivLen    = input.int(252, "IV-Rank Lookback",     minval = 20, group = g2, tooltip = "Window (on the vol-leg timeframe) for the implied-vol percentile rank.")
termLen  = input.int(50,  "Vol Term Mean Length", minval = 5,  group = g2, tooltip = "Implied vol vs its own mean = term-structure stress proxy.")
normLen  = input.int(100, "Normalization Window", minval = 20, group = g2, tooltip = "Z-score window so every leg shares one standard-deviation scale.")
smoothLen= input.int(3,   "Output Smoothing (EMA)",minval = 1,  group = g2)

// ─── 03 · COMPONENT WEIGHTS ────────────────────────────────────────────────────────────────────
g3 = "03 · Component Weights"
wIV    = input.float(1.0, "Weight · Implied-Vol Rank", minval = 0, step = 0.1, group = g3)
wTerm  = input.float(1.0, "Weight · Vol Term-Structure",minval = 0, step = 0.1, group = g3)
wBasis = input.float(1.0, "Weight · Futures Basis",     minval = 0, step = 0.1, group = g3)
incPCR = input.bool(false, "Use Put-Call Ratio leg", inline = "pcr", group = g3, tooltip = "OFF by default: requires a real external PCR series. Leaving it off is correct unless you feed one — the default source is price, which is NOT PCR.")
wPCR   = input.float(1.0,  "w",                      inline = "pcr", minval = 0, step = 0.1, group = g3)
pcrSrc = input.source(close,"  Put-Call Ratio source", group = g3, tooltip = "Feed an external Put-Call-Ratio plot here. Ignored unless the PCR leg is on.")
pcrBull= input.bool(true,  "  High PCR = bullish lean", group = g3, tooltip = "Contrarian put-writing read. Flip if you treat high PCR as bearish.")
incSkew= input.bool(false, "Use Option-Skew leg", inline = "skw", group = g3, tooltip = "OFF by default: requires a real external skew series.")
wSkew  = input.float(1.0,  "w",                   inline = "skw", minval = 0, step = 0.1, group = g3)
skewSrc= input.source(close,"  Option-Skew source", group = g3, tooltip = "Feed an external put-call skew plot here. Steeper put skew = more fear.")

// ─── 04 · CALIBRATION (Hit / Base / EDGE) ──────────────────────────────────────────────────────
g4 = "04 · Calibration Harness"
calcCal = input.bool(true, "Measure Edge",            group = g4, tooltip = "Did a positioning turn actually precede a favourable move versus a random bar?")
calH    = input.int(10,  "Horizon (bars)",            minval = 1, group = g4)
calK    = input.float(1.0,"Favourable move (×ATR)",   minval = 0.1, step = 0.1, group = g4)
calWin  = input.int(500, "Base-rate window",          minval = 50, group = g4)

// ─── 05 · BANDS ────────────────────────────────────────────────────────────────────────────────
g5 = "05 · Bands"
obSigma  = input.float(1.5, "Lean Band (σ)",    minval = 0.5, step = 0.1, group = g5)
extSigma = input.float(2.5, "Extreme Band (σ)", minval = 0.5, step = 0.1, group = g5)
showDiv  = input.bool(true, "Show Price Divergences", group = g5)
divLb    = input.int(5, "Divergence Pivot", minval = 2, group = g5)

// ─── 06 · DISPLAY & THEME ──────────────────────────────────────────────────────────────────────
g6 = "06 · Display & Theme"
vizStyle = input.string("Gradient area + glow", "Visual style", options = ["Gradient area + glow", "Histogram", "Line"], group = g6, tooltip = "Gradient area + glow: filled area between the line and the zero balance line, opacity scaling with conviction, under a neon line. Histogram: saturated columns. Line: glow line only.")
showRegime = input.bool(true, "Background regime tint", group = g6)
showDash   = input.bool(true, "Show Dashboard",         group = g6)
bullCol  = input.color(#2ebd85, "Bullish Lean", group = g6)
bearCol  = input.color(#f6465d, "Bearish Lean", group = g6)
midCol   = input.color(#f7c948, "Midline Glow", group = g6)
bandCol  = input.color(#2ebd85, "Extreme Zone Band", group = g6, display = display.none)
upperBandCol = input.color(#f6465d, "Upper Band (overbought)", group = g6, tooltip = "Top extreme zone — red by default (stretched-bullish, prone to fade).")
lowerBandCol = input.color(#2ebd85, "Lower Band (oversold)",   group = g6, tooltip = "Bottom extreme zone — green by default (stretched-bearish, prone to bounce).")

// ─── HELPERS ──────────────────────────────────────────────────────────────────────────────────
f_z(float v, float m, float s) => s > 0 ? (v - m) / s : 0.0
// ─── Wilson interval (significance of the Edge) ───────────────────────────────────────────────
f_wilson(float w, float n, float zc) =>
    if n <= 0
        na
    else
        float p = w / n
        float z2 = zc * zc
        float c = (p + z2 / (2.0 * n)) / (1.0 + z2 / n)
        float hw = (zc * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / (1.0 + z2 / n)
        hw

legCalc(simple int ivL, simple int tL, simple int nL) =>
    float ivR  = ta.percentrank(close, ivL)
    float trm  = close - ta.ema(close, tL)
    float sd   = ta.stdev(trm, nL)
    float mn   = ta.sma(trm, nL)
    float trmZ = sd > 0 ? (trm - mn) / sd : 0.0
    [ivR, trmZ, close]

// ─── DATA ─────────────────────────────────────────────────────────────────────────────────────
spot = request.security(spotSym, timeframe.period, close, lookahead = barmerge.lookahead_off)
fut  = request.security(futSym,  timeframe.period, close, lookahead = barmerge.lookahead_off)
[ivRankD, zTermD, vixD] = request.security(vixSym, statsTF, legCalc(ivLen, termLen, normLen), lookahead = barmerge.lookahead_off)

// ─── LEGS (each standardized, sign-aligned: + = bullish lean) ──────────────────────────────────
basis  = spot > 0 ? (fut - spot) / spot * 100.0 : na
zIV    = (ivRankD - 50.0) / 28.8675                                   // percentile → ~σ units
zTerm  = zTermD                                                       // already z on the vol timeframe
zBasis = f_z(basis, ta.sma(basis, normLen), ta.stdev(basis, normLen))
zPCR   = f_z(pcrSrc, ta.sma(pcrSrc, normLen), ta.stdev(pcrSrc, normLen))
zSkew  = f_z(skewSrc,ta.sma(skewSrc,normLen), ta.stdev(skewSrc,normLen))

float num = 0.0
float den = 0.0
num := num - wIV   * zIV
den := den + wIV
num := num - wTerm * zTerm
den := den + wTerm
num := num + wBasis * nz(zBasis)
den := den + wBasis
if incPCR and not na(zPCR)
    num := num + (pcrBull ? 1.0 : -1.0) * wPCR * zPCR
    den := den + wPCR
if incSkew and not na(zSkew)
    num := num - wSkew * zSkew
    den := den + wSkew

comp = den > 0 ? num / den : 0.0
osc  = ta.ema(comp, smoothLen)
// per-topic: leg-agreement (how many standardized legs share the composite's sign)
int legAgree = (math.sign(-zIV) == math.sign(osc) ? 1 : 0) + (math.sign(-zTerm) == math.sign(osc) ? 1 : 0) + (math.sign(nz(zBasis)) == math.sign(osc) ? 1 : 0)

// ─── DIVERGENCE (oscillator vs price) ─────────────────────────────────────────────────────────
ph = ta.pivothigh(osc, divLb, divLb)
pl = ta.pivotlow(osc, divLb, divLb)
var float pOscH = na, var float pOscL = na, var float pPrcH = na, var float pPrcL = na
bool bullDiv = false, bool bearDiv = false, bool hBull = false, bool hBear = false
if not na(pl)
    float pr = low[divLb]
    if not na(pOscL)
        bullDiv := pl > pOscL and pr < pPrcL
        hBull   := pl < pOscL and pr > pPrcL
    pOscL := pl
    pPrcL := pr
if not na(ph)
    float pr = high[divLb]
    if not na(pOscH)
        bearDiv := ph < pOscH and pr > pPrcH
        hBear   := ph > pOscH and pr < pPrcH
    pOscH := ph
    pPrcH := pr

// ─── SIGNALS ──────────────────────────────────────────────────────────────────────────────────
bullTurn = ta.crossover(osc, -obSigma)    // leaving bearish extreme upward
bearTurn = ta.crossunder(osc,  obSigma)   // leaving bullish extreme downward
var int lastSigBar = na
var int lastSigDir = 0
if bullTurn
    lastSigBar := bar_index
    lastSigDir := 1
if bearTurn
    lastSigBar := bar_index
    lastSigDir := -1

// ─── CALIBRATION HARNESS (na-safe) ─────────────────────────────────────────────────────────────
atr     = ta.atr(14)
upEvt   = srcPrice >= srcPrice[calH] + calK * atr[calH]
dnEvt   = srcPrice <= srcPrice[calH] - calK * atr[calH]
baseUp  = ta.sma(upEvt ? 1.0 : 0.0, calWin) * 100.0
baseDn  = ta.sma(dnEvt ? 1.0 : 0.0, calWin) * 100.0

var int[]   cBar  = array.new_int()
var int[]   cDir  = array.new_int()
var float[] cEnt  = array.new_float()
var float[] cAtr  = array.new_float()
var float[] cBase = array.new_float()
var int hits = 0, var int tot = 0, var int baseN = 0
var float sumBase = 0.0
var int rtRuns = 0
var int rtLast = -1
var int rtN = 0
var int rtN1 = 0
var int rtN0 = 0

if calcCal and bullTurn and not na(baseUp)
    cBar.push(bar_index), cDir.push(1),  cEnt.push(srcPrice), cAtr.push(atr), cBase.push(baseUp)
if calcCal and bearTurn and not na(baseDn)
    cBar.push(bar_index), cDir.push(-1), cEnt.push(srcPrice), cAtr.push(atr), cBase.push(baseDn)

if cBar.size() > 0
    for i = cBar.size() - 1 to 0
        if bar_index - cBar.get(i) >= calH
            int d = cDir.get(i)
            float fav = d == 1 ? srcPrice - cEnt.get(i) : cEnt.get(i) - srcPrice
            if fav >= calK * cAtr.get(i)
                hits += 1
            tot += 1
            int rtO = fav >= calK * cAtr.get(i) ? 1 : 0
            if rtN > 0 and rtO != rtLast
                rtRuns += 1
            rtLast := rtO
            rtN += 1
            if rtO == 1
                rtN1 += 1
            else
                rtN0 += 1
            float b = cBase.get(i)
            if not na(b)
                sumBase += b
                baseN += 1
            cBar.remove(i), cDir.remove(i), cEnt.remove(i), cAtr.remove(i), cBase.remove(i)

float hitPct  = tot   > 0 ? hits / tot * 100.0 : na
float basePct = baseN > 0 ? sumBase / baseN     : na
float edge    = not na(hitPct) and not na(basePct) ? hitPct - basePct : na

// ─── Wilson significance + edge-floor + runs-test ────────────────────────────────────────────
float ciPct  = f_wilson(hits, tot, 1.96) * 100.0
bool  sigStar = not na(ciPct) and not na(edge) and (edge - ciPct) > 0
float edgeLB = not na(hitPct) and not na(ciPct) and not na(basePct) ? (hitPct - ciPct) - basePct : na
float rtMu  = rtN > 1 ? 2.0 * rtN1 * rtN0 / rtN + 1.0 : na
float rtVar = rtN > 1 ? 2.0 * rtN1 * rtN0 * (2.0 * rtN1 * rtN0 - rtN) / (rtN * rtN * (rtN - 1.0)) : na
float runsZ = not na(rtVar) and rtVar > 0 ? (rtRuns - rtMu) / math.sqrt(rtVar) : na

// ─── RENDER STYLE ──────────────────────────────────────────────────────────────────────────────
isGrad = vizStyle == "Gradient area + glow"
isHist = vizStyle == "Histogram"
isLine = vizStyle == "Line"
oscCol = color.from_gradient(osc, -extSigma, extSigma, bearCol, bullCol)
float intensity = math.min(math.abs(osc) / math.max(extSigma, 0.0001), 1.0)

// Background regime tint
bgcolor(showRegime and osc >=  extSigma ? color.new(bullCol, 90) : showRegime and osc <= -extSigma ? color.new(bearCol, 90) : na, title = "Regime tint")

hline(0, "Zero", color.new(chart.fg_color, 70))

pBullLean = plot(obSigma,   "Upper Lean Line",    color.new(upperBandCol, 55), 1, display = display.pane, editable = false)
pBullExt  = plot(extSigma,  "Upper Extreme Line", color.new(upperBandCol, 70), 1, display = display.pane, editable = false)
pBearLean = plot(-obSigma,  "Lower Lean Line",    color.new(lowerBandCol, 55), 1, display = display.pane, editable = false)
pBearExt  = plot(-extSigma, "Lower Extreme Line", color.new(lowerBandCol, 70), 1, display = display.pane, editable = false)
fill(pBullExt, pBullLean,  extSigma,  obSigma,  color.new(upperBandCol, 55), color.new(upperBandCol, 90), title = "Upper Band (red)")
fill(pBearLean, pBearExt, -obSigma, -extSigma, color.new(lowerBandCol, 90), color.new(lowerBandCol, 55), title = "Lower Band (green)")

plot(0, "Midline glow", color.new(midCol, 80), 3, display = display.pane)
plot(0, "Midline",      color.new(midCol, 45), 1, display = display.pane)

mid = plot(0, "base", display = display.none, editable = false)
op  = plot(isGrad ? osc : na, "area", display = display.none, editable = false)
fill(op, mid, color.new(oscCol, 92 - int(intensity * 55)), title = "Gradient area")

plot(isHist ? osc : na, "Histogram", color.new(oscCol, 35), style = plot.style_columns)

plot(not isHist ? osc : na, "glow outer", color.new(oscCol, 88), 6, display = display.pane)
plot(not isHist ? osc : na, "glow inner", color.new(oscCol, 70), 3, display = display.pane)
plot(not isHist ? osc : na, "Positioning", oscCol, 2)

plotshape(bullTurn, "Bullish Turn", shape.triangleup,   location.bottom, bullCol, size = size.tiny)
plotshape(bearTurn, "Bearish Turn", shape.triangledown, location.top,    bearCol, size = size.tiny)
plotshape(showDiv and bullDiv ? osc[divLb] : na, "Bull Div", shape.circle, location.absolute, bullCol, -divLb, size = size.tiny)
plotshape(showDiv and bearDiv ? osc[divLb] : na, "Bear Div", shape.circle, location.absolute, bearCol, -divLb, size = size.tiny)
plotshape(showDiv and hBull ? osc[divLb] : na, "Hidden Bull", shape.cross, location.absolute, color.new(bullCol, 30), -divLb, size = size.tiny)
plotshape(showDiv and hBear ? osc[divLb] : na, "Hidden Bear", shape.cross, location.absolute, color.new(bearCol, 30), -divLb, size = size.tiny)

// ─── DASHBOARD (theme-adaptive, zebra) ─────────────────────────────────────────────────────────
f_row(int r) => color.new(chart.fg_color, r % 2 == 0 ? 92 : 96)
var table dash = table.new(position.top_right, 2, 12, frame_color = color.new(chart.fg_color, 60), frame_width = 1, border_color = color.new(chart.fg_color, 80), border_width = 1)
if barstate.islast and showDash
    string zone = osc >= extSigma ? "Extreme Bull" : osc >= obSigma ? "Bull Lean" : osc <= -extSigma ? "Extreme Bear" : osc <= -obSigma ? "Bear Lean" : "Neutral"
    color  lc   = osc >= obSigma ? bullCol : osc <= -obSigma ? bearCol : color.new(chart.fg_color, 25)
    string sigTxt = na(lastSigBar) ? "—" : (lastSigDir == 1 ? "Bull " : "Bear ") + str.tostring(bar_index - lastSigBar) + "b"
    table.cell(dash, 0, 0, "OPTIONS POSITIONING", text_color = chart.bg_color, bgcolor = lc, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 0, zone, text_color = chart.bg_color, bgcolor = lc, text_size = size.tiny)
    table.cell(dash, 0, 1, "Value (σ)", text_color = chart.fg_color, bgcolor = f_row(1), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 1, str.tostring(osc, "#.##"), text_color = lc, bgcolor = f_row(1), text_size = size.tiny)
    table.cell(dash, 0, 2, "Implied-Vol Rank", text_color = chart.fg_color, bgcolor = f_row(2), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 2, str.tostring(ivRankD, "#") + "%", text_color = chart.fg_color, bgcolor = f_row(2), text_size = size.tiny)
    table.cell(dash, 0, 3, "Vol Term (σ)", text_color = chart.fg_color, bgcolor = f_row(3), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 3, str.tostring(zTerm, "#.##"), text_color = zTerm <= 0 ? bullCol : bearCol, bgcolor = f_row(3), text_size = size.tiny)
    table.cell(dash, 0, 4, "Futures Basis", text_color = chart.fg_color, bgcolor = f_row(4), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 4, na(basis) ? "—" : str.tostring(basis, "#.##") + "%", text_color = nz(basis) >= 0 ? bullCol : bearCol, bgcolor = f_row(4), text_size = size.tiny)
    table.cell(dash, 0, 5, "Implied Vol", text_color = chart.fg_color, bgcolor = f_row(5), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 5, str.tostring(vixD, "#.##"), text_color = chart.fg_color, bgcolor = f_row(5), text_size = size.tiny)
    table.cell(dash, 0, 6, "Last Signal", text_color = chart.fg_color, bgcolor = f_row(6), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 6, sigTxt, text_color = na(lastSigBar) ? color.new(chart.fg_color, 30) : (lastSigDir == 1 ? bullCol : bearCol), bgcolor = f_row(6), text_size = size.tiny)
    table.cell(dash, 0, 7, "Hit %", text_color = chart.fg_color, bgcolor = f_row(7), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 7, na(hitPct) ? "—" : str.tostring(hitPct, "#.#") + "%", text_color = chart.fg_color, bgcolor = f_row(7), text_size = size.tiny)
    table.cell(dash, 0, 8, "Base %", text_color = chart.fg_color, bgcolor = f_row(8), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 8, na(basePct) ? "—" : str.tostring(basePct, "#.#") + "%", text_color = color.new(chart.fg_color, 30), bgcolor = f_row(8), text_size = size.tiny)
    table.cell(dash, 0, 9, "EDGE", text_color = chart.fg_color, bgcolor = f_row(9), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 9, na(edge) ? "—" : (edge >= 0 ? "+" : "") + str.tostring(edge, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edge) ? f_row(9) : (edge > 0 ? bullCol : bearCol), text_size = size.tiny)
    table.cell(dash, 0, 10, "Leg agreement", text_color = chart.fg_color, bgcolor = f_row(10), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 10, str.tostring(legAgree) + "/3", text_color = legAgree >= 2 ? (osc >= 0 ? bullCol : bearCol) : color.new(chart.fg_color, 25), bgcolor = f_row(10), text_size = size.tiny)
    table.cell(dash, 0, 11, "Edge floor", text_color = chart.fg_color, bgcolor = f_row(11), text_halign = text.align_left, text_size = size.tiny)
    table.cell(dash, 1, 11, na(edgeLB) ? "—" : (sigStar ? "★ " : "") + (edgeLB >= 0 ? "+" : "") + str.tostring(edgeLB, "#.#") + "%", text_color = chart.bg_color, bgcolor = na(edgeLB) ? f_row(11) : (edgeLB > 0 ? bullCol : bearCol), text_size = size.tiny)

// ─── EXP_* EXPORT BUS (generic; Data Window) ─────────────────────────────────────────────────
plot(showEXP ? osc     : na, "EXP_Bias",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? ivRankD : na, "EXP_IVrank", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? zTerm   : na, "EXP_Term",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? nz(zBasis): na, "EXP_Basis", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? legAgree: na, "EXP_LegAgree",color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edge    : na, "EXP_Edge",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edgeLB  : na, "EXP_EdgeLB", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? runsZ   : na, "EXP_RunsZ",  color = color.new(color.gray, 100), display = display.data_window)

// ─── ALERTS ───────────────────────────────────────────────────────────────────────────────────
alertcondition(bullTurn, "Bullish positioning turn", "Options positioning turned bullish (left bearish extreme)")
alertcondition(bearTurn, "Bearish positioning turn", "Options positioning turned bearish (left bullish extreme)")
alertcondition(bullDiv,  "Bullish divergence", "Price made a lower low; positioning made a higher low")
alertcondition(bearDiv,  "Bearish divergence", "Price made a higher high; positioning made a lower high")
````
