<!-- tradingview-pine-id: PUB;8ec2673cc72b47b1ae2bde97f419e880 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_flow

Source: https://www.tradingview.com/script/9PqnB9Zp-ml-flow/

## Description

ml_flow is a dependency-free library for Pine v6 that gives every order-flow study two things it usually approximates badly: measured intrabar direction and volume, and microstructure estimators specified the way the literature actually defines them. Import one shared implementation and "signed volume", "price impact" and "effective spread" mean the same, correct thing across every script you build.

Measured flow (the U1 upgrade)

Most indicators infer buying vs selling from a single bar's shape. These functions measure it from the sub-bar tape instead.

tickDir(c, cPrev, o) — the tick-rule aggressor sign for a bar: an up-tick (close above the prior close) is a buy, a down-tick a sell, and an unchanged close falls back to close-vs-open. Returns +1 / −1 / 0.
signedVolLTF(vols, closes, opens) — aggregates lower-timeframe sub-bar arrays into [buyVol, sellVol, delta] for the current bar, signing each sub-bar by its own close-vs-open. This is measured intrabar flow rather than a whole-bar estimate. Fetch the sub-bar arrays in your script with request.security_lower_tf and pass them in — that call cannot nest inside request.security, so the true read is valid on the chart timeframe; keep a disclosed tick-rule/BVC estimate for any higher-timeframe dashboard rows.
Corrected microstructure estimators (the U4 upgrade)
kyleLambda(dPrice, flow, len) — Kyle's price-impact λ as a proper rolling OLS slope: cov(Δprice, flow) / var(flow). A high λ means thin/illiquid — flow moves price more. This replaces the crude per-bar |Δprice| / |flow| ratio, which is a single noisy observation rather than a fitted coefficient (and is self-correlated by construction).
kyleR2(dPrice, flow, len) — the R² of that same impact regression: how much of this window's price movement the signed flow actually explains. A λ with a low R² is not a trustworthy impact read.
amihud(ret, value, len) — Amihud illiquidity: the mean of |return| / traded value. High = a lot of price move per unit of turnover = illiquid. Pass rupee/dollar volume (price × volume) as value.
roll(price, len) — the Roll effective spread from the negative serial covariance of price changes: S = 2·√(−cov(Δpₜ, Δpₜ₋₁)). Returns zero when the covariance is non-negative (no detectable bid-ask bounce).
corwinSchultz(high, low) — the Corwin-Schultz high-low effective spread from single- and two-bar ranges, returned as a fraction of price (multiply by price for absolute), clamped at zero.
abdiRanaldo(high, low, close, len) — the Abdi-Ranaldo (2017) effective spread from close vs the mid of log-high/log-low, evaluated one bar back so nothing future is referenced (non-repainting). len is the averaging window.
parkinson(high, low, len) — Parkinson volatility from the high-low range: √( mean(ln(h/l)²) / (4·ln2) ). Uses the full bar range, so it is more efficient than a close-to-close estimate.
How to use

Fetch the sub-bar tape on the chart timeframe, then measure flow and impact from it:

//@version=6
indicator("Example — measured flow", overlay = false)
import Market_Logic_India/ml_flow/1 as flow

len = input.int(20, "Impact window")

// true intrabar signed volume (chart TF only) with a bar-shape fallback
[vs, cs, os] = request.security_lower_tf(syminfo.tickerid, "1", [volume, close, open])
[buy, sell, delta] = flow.signedVolLTF(vs, cs, os)
onChartTf = timeframe.period == timeframe.period   // gate true-LTF to the chart TF in your host

signed = na(delta) or delta == 0 ? (close > open ? volume : -volume) : delta
lambda = flow.kyleLambda(close - close[1], signed, len)   // proper OLS price impact
r2     = flow.kyleR2(close - close[1], signed, len)

plot(delta, "Signed volume", color = delta >= 0 ? color.teal : color.red, style = plot.style_columns)
plot(lambda, "Kyle λ", color = color.orange)
Notes
Non-repainting: every estimator uses closed-bar values and rolling history only; abdiRanaldo is evaluated one bar back so it references no future value. Resolve any host-side accumulation on barstate.isconfirmed.
True-LTF limits: request.security_lower_tf has limited intraday history and adds load, and cannot nest inside request.security — so genuine per-timeframe delta isn't available on an MTF dashboard. Give the measured read on the chart timeframe and a disclosed bar-estimate for HTF rows. It remains an estimate of the true tape.
Types: pass series for the price/flow inputs and simple int for the windows; signedVolLTF takes the three array<float> sub-bar series from request.security_lower_tf.
Concept credits

The tick rule follows Lee & Ready (1991). Price impact λ is Albert Kyle (1985). The illiquidity ratio is Amihud (2002). Effective-spread estimators are Roll (1984), Corwin & Schultz (2012) and Abdi & Ranaldo (2017); the range volatility is Parkinson (1980). This library is an original, dependency-free Pine v6 packaging of those public techniques; it is not affiliated with, nor endorsed by, any originator.

License

Mozilla Public License 2.0 — as required for TradingView libraries (open source). Free to import and build on.

Library  "ml_flow"

tickDir(c, cPrev, o)
  Parameters:
    c (float)
    cPrev (float)
    o (float)

signedVolLTF(vols, closes, opens)
  Parameters:
    vols (array<float>)
    closes (array<float>)
    opens (array<float>)

kyleLambda(dPrice, flow, len)
  Parameters:
    dPrice (float)
    flow (float)
    len (simple int)

kyleR2(dPrice, flow, len)
  Parameters:
    dPrice (float)
    flow (float)
    len (simple int)

amihud(ret, value, len)
  Parameters:
    ret (float)
    value (float)
    len (simple int)

roll(price, len)
  Parameters:
    price (float)
    len (simple int)

corwinSchultz(high, low)
  Parameters:
    high (float)
    low (float)

abdiRanaldo(high, low, close, len)
  Parameters:
    high (float)
    low (float)
    close (float)
    len (simple int)

parkinson(high, low, len)
  Parameters:
    high (float)
    low (float)
    len (simple int)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_flow — Measured-flow & microstructure toolkit  (Wave B foundation library)
// Tick-rule direction · true-LTF signed volume aggregation · corrected estimators:
// Kyle-λ (proper OLS), Amihud illiquidity, Roll / Corwin-Schultz / Abdi-Ranaldo
// effective spread, Parkinson volatility.
// Import once, reuse across the order-flow suite:
//   import Market_Logic_India/ml_flow/2 as flow
// v2 (Batch-2) ADDS: CVD acceleration (order-flow momentum), cost-per-tick percentile
// (effort-to-move / absorption ratio), and size-stratified signed volume (large-order
// flow). Additive — every v1 export is unchanged.
// NOTE on true LTF: request.security_lower_tf cannot nest inside request.security,
// so fetch the sub-bar arrays in your SCRIPT (chart TF) and pass them to
// signedVolLTF(). Keep a disclosed tick-rule/BVC estimate for any HTF dashboard rows.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_flow", overlay = false)

// ── DIRECTION ─────────────────────────────────────────────────────────────────
// Tick-rule aggressor sign for a bar: prefer close-vs-prior-close (up/down tick);
// on an unchanged close fall back to close-vs-open. Returns +1 buy / -1 sell / 0.
export tickDir(series float c, series float cPrev, series float o) =>
    int s = na(c) ? 0 : (not na(cPrev) and c > cPrev) ? 1 : (not na(cPrev) and c < cPrev) ? -1 : (not na(o) and c > o) ? 1 : (not na(o) and c < o) ? -1 : 0
    s

// ── TRUE-LTF SIGNED VOLUME ───────────────────────────────────────────────────
// Aggregate lower-timeframe sub-bar arrays (fetched by the host via
// request.security_lower_tf) into [buyVol, sellVol, delta] for the current bar.
// Each sub-bar is signed by close-vs-open (its own aggressor proxy). This is the
// U1 upgrade: measured intrabar flow instead of a whole-bar shape estimate.
export signedVolLTF(array<float> vols, array<float> closes, array<float> opens) =>
    float buy  = 0.0
    float sell = 0.0
    int n = math.min(array.size(vols), math.min(array.size(closes), array.size(opens)))
    if n > 0
        for i = 0 to n - 1
            float v = nz(array.get(vols, i), 0.0)
            float c = array.get(closes, i)
            float o = array.get(opens, i)
            int s = (na(c) or na(o)) ? 0 : c > o ? 1 : c < o ? -1 : 0
            if s > 0
                buy += v
            else if s < 0
                sell += v
    [buy, sell, buy - sell]

// ── KYLE'S LAMBDA (price impact) — proper rolling OLS slope ───────────────────
// λ = slope of Δprice regressed on signed order flow over `len` bars
//   = cov(Δprice, flow) / var(flow).  Positive λ = thin/illiquid (flow moves price
// more). This replaces the crude per-bar |Δprice| / |flow| ratio, which is a noisy
// single-observation estimate rather than a fitted impact coefficient.
export kyleLambda(series float dPrice, series float flow, simple int len) =>
    float mx  = ta.sma(flow, len)
    float my  = ta.sma(dPrice, len)
    float cov = ta.sma(flow * dPrice, len) - mx * my
    float vx  = ta.sma(flow * flow, len) - mx * mx
    vx > 1e-12 ? cov / vx : na

// R² of that same impact regression (how well flow explains price moves this window).
export kyleR2(series float dPrice, series float flow, simple int len) =>
    float mx  = ta.sma(flow, len)
    float my  = ta.sma(dPrice, len)
    float cov = ta.sma(flow * dPrice, len) - mx * my
    float vx  = ta.sma(flow * flow, len) - mx * mx
    float vy  = ta.sma(dPrice * dPrice, len) - my * my
    (vx > 1e-12 and vy > 1e-12) ? (cov * cov) / (vx * vy) : na

// ── AMIHUD ILLIQUIDITY ────────────────────────────────────────────────────────
// Mean of |return| / traded value over the window. High = price moves a lot per
// unit turnover = illiquid. Pass dollar/rupee volume (price × volume) as `value`.
export amihud(series float ret, series float value, simple int len) =>
    float ill = value > 0.0 ? math.abs(ret) / value : na
    ta.sma(ill, len)

// ── ROLL EFFECTIVE SPREAD ─────────────────────────────────────────────────────
// From the negative serial covariance of price changes: S = 2·√(−cov(Δp_t, Δp_{t-1})).
// Zero when the covariance is non-negative (no bid-ask bounce detectable).
export roll(series float price, simple int len) =>
    float dp  = price - nz(price[1], price)
    float dp1 = nz(dp[1], 0.0)
    float cov = ta.sma(dp * dp1, len) - ta.sma(dp, len) * ta.sma(dp1, len)
    cov < 0.0 ? 2.0 * math.sqrt(-cov) : 0.0

// ── CORWIN-SCHULTZ SPREAD (high-low, 2-bar) ──────────────────────────────────
// Effective spread from single- and two-bar high/low ranges. Returns a fraction
// of price (multiply by price for absolute). Clamped at 0.
export corwinSchultz(series float high, series float low) =>
    float hl2   = math.pow(math.log(high / low), 2.0)
    float beta  = hl2 + nz(hl2[1], hl2)
    float h2    = math.max(high, nz(high[1], high))
    float l2    = math.min(low,  nz(low[1],  low))
    float gamma = math.pow(math.log(h2 / l2), 2.0)
    float k     = 3.0 - 2.0 * math.sqrt(2.0)
    float alpha = (math.sqrt(2.0 * beta) - math.sqrt(beta)) / k - math.sqrt(gamma / k)
    float s     = 2.0 * (math.exp(alpha) - 1.0) / (1.0 + math.exp(alpha))
    math.max(s, 0.0)

// ── ABDI-RANALDO SPREAD (2017) ───────────────────────────────────────────────
// S = 2·√(max(0, E[(c−η)(c−η_next)])), η = (log-high + log-low)/2, evaluated one
// bar back so no future value is referenced (non-repaint). `len` = averaging window.
export abdiRanaldo(series float high, series float low, series float close, simple int len) =>
    float h = math.log(high)
    float l = math.log(low)
    float c = math.log(close)
    float eta = (h + l) / 2.0
    float prod = (nz(c[1]) - nz(eta[1])) * (nz(c[1]) - nz(eta))
    float s2 = 4.0 * ta.sma(prod, len)
    math.sqrt(math.max(s2, 0.0))

// ── PARKINSON VOLATILITY (high-low range) ────────────────────────────────────
// σ from the high-low range: √( mean( ln(h/l)² ) / (4·ln2) ). Uses the full bar
// range, so it is more efficient than a close-to-close estimate.
export parkinson(series float high, series float low, simple int len) =>
    float r2 = math.pow(math.log(high / low), 2.0)
    float m  = ta.sma(r2, len)
    math.sqrt(math.max(m, 0.0) / (4.0 * math.log(2.0)))

// ══════════════════════════════════════════════════════════════════════════════
// v2 ▸ ORDER-FLOW MOMENTUM · ABSORPTION RATIO · SIZE-STRATIFIED FLOW
// ══════════════════════════════════════════════════════════════════════════════

// CVD ACCELERATION — 2nd difference of the per-bar signed delta = how fast net
// pressure is CHANGING. Inflects before CVD itself turns. Feed your signed delta
// (e.g. the third output of signedVolLTF). Early order-flow-momentum read.
export deltaAccel(series float delta) =>
    delta - nz(delta[1])

// COST-PER-TICK (effort-to-move) percentile — |signed flow| per tick of price move,
// percentile-ranked over `len`. HIGH percentile = lots of flow, little movement =
// ABSORPTION; LOW = price moved on little flow = vacuum/efficient trend. Self-
// calibrating (percentile). `dPrice` in price units; converted to ticks internally.
export costPerTickPct(series float dPrice, series float flow, simple int len) =>
    float ticks = math.abs(dPrice) / syminfo.mintick
    float cost  = math.abs(flow) / math.max(ticks, 1e-9)
    ta.percentrank(cost, len)

// SIZE-STRATIFIED signed volume — like signedVolLTF, but only sub-bars whose traded
// VALUE (pass price×vol, or your own value array) clears `minVal` are counted, isolating
// large-order flow from small. Returns [buyVol, sellVol, delta] for the qualifying tier.
// HONEST CAVEAT: on 1-min LTF this is big-BAR (not big-TRADE) flow; true per-trade
// stratification needs tick data.
export signedVolLTFFiltered(array<float> vols, array<float> closes, array<float> opens, array<float> values, simple float minVal) =>
    float buy  = 0.0
    float sell = 0.0
    int n = math.min(array.size(vols), math.min(array.size(closes), array.size(opens)))
    if n > 0
        for i = 0 to n - 1
            float val = i < array.size(values) ? nz(array.get(values, i), 0.0) : 0.0
            if val >= minVal
                float v = nz(array.get(vols, i), 0.0)
                float c = array.get(closes, i)
                float o = array.get(opens, i)
                int s = (na(c) or na(o)) ? 0 : c > o ? 1 : c < o ? -1 : 0
                if s > 0
                    buy += v
                else if s < 0
                    sell += v
    [buy, sell, buy - sell]

// ── demo output (library preview only) ──
plot(kyleLambda(close - close[1], (close > open ? volume : -volume), 20), "Kyle λ (demo)", color = color.new(#e8a33d, 0))
````
