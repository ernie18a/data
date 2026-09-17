<!-- tradingview-pine-id: PUB;91c5991c954e4cd0bd0b84547d699d75 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_india

Source: https://www.tradingview.com/script/YQc1Y2tR-ml-india/

## Description

ml_india is a dependency-free library for Pine v6 that packages the two pieces of context every India-market study should gate on but generic tools ignore: the India VIX regime and the NIFTY spot–futures basis. Import one shared implementation and "fear regime" and "premium / discount" mean the same thing across every script you build.

What it gives
VIX regime — where India VIX sits in its own recent range: fearful (risk-off), complacent, or normal.
VIX term-structure proxy — short-term vs longer-term implied vol, as a stand-in for the futures curve when that isn't on your feed.
Spot–futures basis — the NIFTY futures premium/discount, raw and annualized, plus a self-calibrating regime.
riskState — the VIX regime and basis regime combined into a single risk-on / risk-off number.
Design — host-fed

The statistics are host-fed: you fetch India VIX (e.g. NSE:INDIAVIX) and NIFTY spot versus the futures you're charting with request.security / input.source, and pass the series in. So the library carries no hard-wired tickers and works whatever your feed calls them. A fetch helper is included for convenience. Every read is a pure function of the series you pass — nothing repaints.

The functions
fetch(sym) — a symbol's close on the chart timeframe. For wiring VIX / spot inputs.
vixRegime(vix, len, hiPct, loPct) — VIX percentile over len: +1 high fear (risk-off), −1 complacent, 0 normal.
vixTermProxy(vix, fastLen, slowLen) — (fast EMA − slow EMA) / slow EMA of the index: >0 backwardation (short-term stress building), <0 contango (calm). A single-series stand-in for a genuine VIX-futures curve.
basis(spot, fut) — (fut − spot) / spot. Positive = futures premium (carry / bullish lean); negative = discount / backwardation.
basisAnn(spot, fut, dte) — the basis annualized by days-to-expiry (× 365 / dte), so different expiries are comparable.
basisRegime(spot, fut, len, z) — the basis z-scored against its own history: +1 rich premium, −1 discount/backwardation, 0 normal. Self-calibrating to each symbol's typical carry.
riskState(vix, spot, fut, len, hiPct, loPct, z) — one context read: +1 risk-ON (VIX complacent and futures at a premium), −1 risk-OFF (VIX fearful or basis in discount — either alone is enough to de-risk), 0 mixed.
How to use

Fetch the context and gate a signal by it:

//@version=6
indicator("Example — India context", overlay = false)
import Market_Logic_India/ml_india/1 as ind

vix  = ind.fetch("NSE:INDIAVIX")
spot = ind.fetch("NSE:NIFTY")
fut  = close                       // the futures you are charting (e.g. NIFTY1!)

vReg  = ind.vixRegime(vix, 100, 80, 20)          // +1 fear / -1 calm / 0
bReg  = ind.basisRegime(spot, fut, 100, 1.0)     // +1 premium / -1 discount / 0
risk  = ind.riskState(vix, spot, fut, 100, 80, 20, 1.0)   // +1 risk-on / -1 risk-off / 0

bgcolor(risk < 0 ? color.new(color.red, 88) : risk > 0 ? color.new(color.green, 88) : na)
plot(ind.basisAnn(spot, fut, 7), "Annualized basis")
Scope / honesty

NSE open-interest (OI-delta) is deliberately not here — Pine does not expose index-futures OI on retail feeds, so any "OI" read would be fabricated. The VIX and basis reads are the genuinely-available NIFTY-native context; pair them with your own OI source if you have one. India VIX itself is a 30-day model index, so vixTermProxy is a single-series proxy, not a true two-point curve — treat it as a fast "stress building" flag.

Concept credits

Volatility-index term structure (contango / backwardation) and the cost-of-carry spot–futures basis are standard derivatives concepts; India VIX is NSE's volatility index. This library is an original, dependency-free Pine v6 packaging of those public techniques; it is not affiliated with, nor endorsed by, NSE or any originator.

License

Mozilla Public License 2.0 — as required for TradingView libraries (open source). Free to import and build on.

Library  "ml_india"

fetch(sym)
  Parameters:
    sym (simple string)

vixRegime(vix, len, hiPct, loPct)
  Parameters:
    vix (float)
    len (simple int)
    hiPct (simple float)
    loPct (simple float)

vixTermProxy(vix, fastLen, slowLen)
  Parameters:
    vix (float)
    fastLen (simple int)
    slowLen (simple int)

basis(spot, fut)
  Parameters:
    spot (float)
    fut (float)

basisAnn(spot, fut, dte)
  Parameters:
    spot (float)
    fut (float)
    dte (simple float)

basisRegime(spot, fut, len, z)
  Parameters:
    spot (float)
    fut (float)
    len (simple int)
    z (simple float)

riskState(vix, spot, fut, len, hiPct, loPct, z)
  Parameters:
    vix (float)
    spot (float)
    fut (float)
    len (simple int)
    hiPct (simple float)
    loPct (simple float)
    z (simple float)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_india — India-market context  (Wave D foundation library)
// The context no generic library carries: India VIX regime and the NIFTY spot–futures basis,
// as one shared read every India study can gate on. Import once so "fear regime" and "premium /
// discount" mean the same thing across the suite.
//   import Market_Logic_India/ml_india/2 as ind
// v2 (Batch-3) ADDS the OPTIONS-BUYER RISK LAYER — VIX premium tier/bias, gap-shock,
// expiry theta weighting, liquidity-void, false-momentum trap, and a composite buy-guard.
// All need only India VIX + price (NO OI), so they ship independently of any OI feed.
// (OI POSITIONING is still deliberately absent — see the SCOPE/HONESTY note; it awaits a
//  real strike-wise NIFTY OI data path and will land in a dedicated ml_oi library.)
//
// WHAT IT GIVES
//   • VIX regime — where India VIX sits in its own recent range (risk-off when fearful).
//   • VIX term-structure proxy — short-term vs longer-term implied vol (stress building vs calm).
//   • Spot–futures basis — the NIFTY futures premium/discount, raw and annualized, and its regime.
//   • riskState — VIX regime and basis regime combined into one risk-on / risk-off read.
//
// DESIGN  The stats are HOST-FED: fetch India VIX (e.g. NSE:INDIAVIX) and NIFTY spot vs the futures
// you are charting with request.security / input.source, and pass the series in — so the library
// carries no hard-wired tickers and works whatever your feed calls them. A `fetch` helper is
// provided for convenience. Everything is a pure function of the series you pass; nothing repaints.
//
// SCOPE / HONESTY  NSE open-interest (OI-delta) is deliberately NOT here — Pine does not expose
// index-futures OI on retail feeds, so any "OI" read would be fabricated. The VIX and basis reads
// are the genuinely-available NIFTY-native context; pair them with your own OI source if you have one.
//
// CONCEPT CREDIT  Volatility-index term structure (contango / backwardation) and the cost-of-carry
// spot–futures basis are standard derivatives concepts. Original, dependency-free Pine v6 packaging.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_india", overlay = false)

// ── FETCH HELPER ────────────────────────────────────────────────────────────────
// Convenience: a symbol's close on the chart timeframe (for VIX / spot inputs). Non-repainting.
export fetch(simple string sym) =>
    request.security(sym, timeframe.period, close, lookahead = barmerge.lookahead_off)

// ── INDIA VIX ───────────────────────────────────────────────────────────────────
// VIX regime from its own percentile over `len`: +1 = high fear (risk-off), −1 = complacent, 0 = normal.
export vixRegime(series float vix, simple int len, simple float hiPct, simple float loPct) =>
    float pr = ta.percentrank(vix, len)
    na(pr) ? 0 : pr >= hiPct ? 1 : pr <= loPct ? -1 : 0

// VIX term-structure PROXY from fast vs slow EMA of the index: >0 = backwardation (short-term stress
// building, risk-off), <0 = contango (calm). A single-series stand-in when a genuine VIX-futures
// curve is not on the feed. Returns the fractional gap (fastEMA − slowEMA) / slowEMA.
export vixTermProxy(series float vix, simple int fastLen, simple int slowLen) =>
    float f = ta.ema(vix, fastLen)
    float s = ta.ema(vix, slowLen)
    (not na(s) and s > 0.0) ? (f - s) / s : 0.0

// ── SPOT–FUTURES BASIS ──────────────────────────────────────────────────────────
// Basis as a fraction of spot: (fut − spot) / spot. Positive = futures premium (carry / bullish lean),
// negative = discount / backwardation (bearish lean). Pass NIFTY spot and the futures you chart.
export basis(series float spot, series float fut) =>
    spot != 0.0 ? (fut - spot) / spot : na

// Annualized basis given days-to-expiry: basis × (365 / dte). Comparable across expiries.
export basisAnn(series float spot, series float fut, simple float dte) =>
    float b = spot != 0.0 ? (fut - spot) / spot : na
    (not na(b) and dte > 0.0) ? b * (365.0 / dte) : na

// Basis REGIME: z-score of the basis vs its own history → +1 rich premium, −1 discount / backwardation,
// 0 normal. Self-calibrating, so it adapts to each symbol's typical carry.
export basisRegime(series float spot, series float fut, simple int len, simple float z) =>
    float b  = spot != 0.0 ? (fut - spot) / spot : na
    float m  = ta.sma(b, len)
    float sd = ta.stdev(b, len)
    float zz = (not na(b) and not na(m) and sd > 0.0) ? (b - m) / sd : 0.0
    na(zz) ? 0 : zz >= z ? 1 : zz <= -z ? -1 : 0

// ── COMBINED RISK STATE ─────────────────────────────────────────────────────────
// One NIFTY-native context read: +1 risk-ON (VIX complacent AND futures at a premium), −1 risk-OFF
// (VIX fearful OR basis in discount — either alone is enough to de-risk), 0 mixed / neutral.
export riskState(series float vix, series float spot, series float fut, simple int len, simple float hiPct, simple float loPct, simple float z) =>
    // VIX regime
    float pr = ta.percentrank(vix, len)
    int vr = na(pr) ? 0 : pr >= hiPct ? 1 : pr <= loPct ? -1 : 0
    // basis regime
    float b  = spot != 0.0 ? (fut - spot) / spot : na
    float m  = ta.sma(b, len)
    float sd = ta.stdev(b, len)
    float zz = (not na(b) and not na(m) and sd > 0.0) ? (b - m) / sd : 0.0
    int br = na(zz) ? 0 : zz >= z ? 1 : zz <= -z ? -1 : 0
    // combine: fear or discount → risk-off; complacent and premium → risk-on
    (vr == 1 or br == -1) ? -1 : (vr == -1 and br == 1) ? 1 : 0

// ══════════════════════════════════════════════════════════════════════════════
// v2 ▸ INDIA OPTIONS-BUYER RISK LAYER  (VIX premium regime · expiry theta · gap shock ·
// liquidity void · false-momentum trap). Protects an OPTION BUYER from theta/IV-crush
// traps — needs only India VIX + price (no OI). Host toggles which filters apply.
// ══════════════════════════════════════════════════════════════════════════════

// India VIX TIER by absolute level (buyer's premium regime):
//  0 LOW (<13) · 1 NORMAL (<18) · 2 HIGH (<25) · 3 EXTREME (≥25, options richly priced).
export vixTierCode(series float vix) =>
    na(vix) ? na : vix < 13.0 ? 0 : vix < 18.0 ? 1 : vix < 25.0 ? 2 : 3

// String label for the tier (dashboard).
export vixTierLabel(series float vix) =>
    int t = vixTierCode(vix)
    t == 0 ? "LOW" : t == 1 ? "NORMAL" : t == 2 ? "HIGH" : t == 3 ? "EXTREME" : "—"

// VIX PREMIUM bias for option BUYERS: rising VIX = IV expanding = premium tailwind (+1);
// falling VIX = IV crush = headwind (−1); flat = 0. (Buying into rising IV helps; into
// falling IV it hurts even when the direction is right.)
export vixPremiumBias(series float vix) =>
    (na(vix) or na(vix[1])) ? 0 : vix > vix[1] ? 1 : vix < vix[1] ? -1 : 0

// Buying options sane right now? False when VIX is EXTREME (premium massively inflated).
export vixBuyOk(series float vix) =>
    vixTierCode(vix) != 3

// GAP-SHOCK: an overnight gap larger than mult×ATR means the move is already priced into
// premium — chasing it buys inflated options with limited upside. Pass the day's open, the
// prior day's close, and ATR. True = shock (block/attenuate).
export gapShock(series float openPx, series float prevClose, series float atr, simple float mult) =>
    (na(openPx) or na(prevClose) or na(atr)) ? false : math.abs(openPx - prevClose) > atr * mult

// EXPIRY THETA weight: signal-quality multiplier for theta decay. afterCutoff (expiry
// afternoon) = 0.3 (theta destroys premium), expiry day otherwise = 0.6, normal day = 1.0.
export expiryRiskMult(series bool isExpiryDay, series bool afterCutoff) =>
    afterCutoff ? 0.3 : isExpiryDay ? 0.6 : 1.0

// LIQUIDITY VOID: low volume AND dead range = no direction = options decay without moving.
// True = void (block). Pass volume, its average, the bar range, ATR; fractions ~0.6 / 0.4.
export liquidityVoid(series float vol, series float avgVol, series float rng, series float atr, simple float volFrac, simple float rangeFrac) =>
    (na(vol) or na(avgVol) or na(rng) or na(atr)) ? false : (vol < avgVol * volFrac) and (rng < atr * rangeFrac)

// FALSE-MOMENTUM TRAP: a momentum (ROC) spike that immediately fails follow-through =
// market-maker stop-hunt at peak IV — the worst option entry. True = trap (block).
export falseMomTrap(series float roc, series float rocAvg, series float c, series float cPrev, simple float spikeMult) =>
    bool spike    = math.abs(roc) > math.abs(rocAvg) * spikeMult
    bool noFollow = (roc > 0.0 and c < cPrev) or (roc < 0.0 and c > cPrev)
    spike and noFollow

// COMPOSITE option-buy permission: true only when NONE of the passed blockers fire. Pass
// each blocker already evaluated; pass `false` for any filter you are not using.
export optionBuyOk(series bool vixExtreme, series bool gapShockF, series bool liqVoidF, series bool falseTrapF, series bool expiryBlockedF) =>
    not (vixExtreme or gapShockF or liqVoidF or falseTrapF or expiryBlockedF)

// OPTION signal-QUALITY multiplier (0..1): folds expiry theta and VIX tier into one
// confidence scale — expiryMult × (EXTREME VIX ? 0.5 : 1.0). Multiply your signal score by it.
export optionQualityMult(series float vix, series bool isExpiryDay, series bool afterCutoff) =>
    float em = expiryRiskMult(isExpiryDay, afterCutoff)
    float vm = vixTierCode(vix) == 3 ? 0.5 : 1.0
    em * vm

// ── demo output (library preview only) ──
// India VIX regime if the symbol is on your feed; plots flat/na otherwise (stand-in preview).
plot(vixRegime(fetch("NSE:INDIAVIX"), 100, 80.0, 20.0), "India VIX regime (demo)", color = color.new(#6f9bd8, 0))
````
