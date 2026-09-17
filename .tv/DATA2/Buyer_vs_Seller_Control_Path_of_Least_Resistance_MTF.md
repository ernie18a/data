<!-- tradingview-pine-id: PUB;553ddb099ed642e9beb15c4de27053a5 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Buyer vs Seller Control & Path of Least Resistance (MTF)

Source: https://www.tradingview.com/script/I8Tv43WR-Buyer-vs-Seller-Control-Path-of-Least-Resistance-MTF/

## Description

Buyer vs Seller Control & Path of Least Resistance (MTF)

WHAT IT DOES
For every timeframe you care about (1 / 2 / 3 / 5 / 15 / 30 / 60 minutes by default) this overlay answers three questions on one comparable scale, right on your price chart:
• WHO is in control — buyers or sellers?
• HOW STRONGLY — a 0-100 strength meter per timeframe.
• Which way is the PATH OF LEAST RESISTANCE across all of them — UP, DOWN, or CHOP?

Your current chart timeframe is highlighted as "YOUR TF", so at a glance you see whether to be hunting longs or shorts on the exact screen you are trading — and the same read for every other timeframe beside it.

THE CONTROL SCORE — FIVE LENSES, ONE NUMBER
Each timeframe's control is a single signed value in [-1, +1] (+ = buyers, − = sellers), fused from five independent lenses so no single measure dominates:

1. ORDER-FLOW DELTA (fast) — a Bulk-Volume-Classification (BVC) buy/sell split. Each bar's volume is divided into buying and selling using the standardized bar return through a normal CDF (Easley / López de Prado / O'Hara), then expressed as a net-over-gross balance ratio. Bounded, so it is comparable across symbols and timeframes.
2. CVD (slow) — the same signed-volume idea over a longer window, capturing persistent accumulation or distribution rather than the latest impulse.
3. VWAP — location of price relative to session VWAP (measured in ATR) plus the slope of VWAP.
4. MA STACK — the interrelation (stacking order) of a fast / mid / slow EMA plus the slope of the fast EMA.
5. VOLUME PRESSURE — close-location-weighted money flow (CMF-style).

Two microstructure adjustments then sharpen conviction:
• EFFORT vs RESULT (absorption) — when control is strong but price has barely progressed, the score is damped: the winning side is being absorbed.
• KYLE-λ IMPACT — a price-impact proxy (correlation of the size of the move with volume). Flow that actually moves price counts for more; volume that moves nothing counts for less.

STRENGTH — SELF-CALIBRATING, COMPARABLE ACROSS TIMEFRAMES
Strength (0-100) is the percentile rank of |control| within each timeframe's OWN recent history. A 1-minute chart and a 1-hour chart are therefore on the same scale: a high % means control is strong RELATIVE to what that timeframe normally does — not an absolute claim. This is what makes the seven rows directly comparable.

PATH OF LEAST RESISTANCE — A CALIBRATED, HONEST FUSION
The headline "PATH" is not a naïve vote count. It is built to avoid the classic multi-timeframe trap where several fast, highly-correlated timeframes all lean the same way and manufacture false confidence:

• LOG-ODDS FUSION — each timeframe's signed control, scaled by its own strength and by a √(timeframe-seconds) horizon weight, is combined as a weighted-mean in log-odds and mapped to a probability P↑ that buyers win the path. Because it is a mean, redundant timeframes form a consensus instead of stacking up.
• CORRELATION DISCOUNT — the average correlation between the timeframe control series is measured live; when the timeframes are merely echoing each other (highly correlated) rather than agreeing independently, the path conviction is shrunk.
• REGIME GATE — a Kaufman efficiency ratio on your chart measures trend vs chop; in a choppy, mean-reverting tape the path is gated toward CHOP so you are not handed a confident direction when the market has none.

The result is reported as ▲ UP / ▼ DOWN / = CHOP with a calibrated conviction %, how many timeframes agree, P↑ (probability up), ρ (inter-TF correlation) and the regime %.

FORWARD-TEST SELF-AUDIT (Pro table)
Turn on the "Pro" detail mode and the table shows a rolling HIT-RATE: how often the path direction from N bars ago was actually followed by price moving that way. It is computed only from confirmed PAST bars — no future leak — so it is an honest, symbol-and-settings-specific audit of the path, not a marketing number. Use it to sanity-check the settings on your instrument before you trust the signal.

REPAINT — READ THIS
• Default (live): higher-timeframe reads update intrabar as each higher-TF bar forms — the normal behaviour of any live multi-timeframe tool.
• "Freeze to last closed bar" (optional): every row shows the last CONFIRMED bar of its timeframe — non-repainting, but one bar behind.
• request.security is called with lookahead OFF (no future data is ever pulled back in time).
• Alerts evaluate on confirmed CHART bars; for fully non-repainting alerts (confirmed higher-TF reads), keep Freeze ON.

HOW TO USE IT
• Add it to any liquid, volume-bearing symbol and intraday timeframe.
• Read YOUR TF first — it is the actionable line for the screen you are on. BUY / SELL / WAIT with a strength meter.
• Then glance up at PATH: trade with the path, be cautious against it, stand aside on CHOP.
• Use AGREE (x/7) and the Pro ρ / regime / hit-rate stats to gauge how much to trust the read.
• Alerts: "Path flips UP", "Path flips DOWN", "Path goes CHOP".

Inputs are grouped: Score, Lenses & microstructure, Timeframes, Path fusion, Repaint, Display (Dark/Light theme, table position, Compact/Pro detail, background tint). All seven timeframes are user-selectable.

ORIGINALITY / WHY IT IS NOT A MASH-UP
The five lenses are deliberately chosen to measure control from independent angles (order flow, longer-horizon flow, value location, trend structure, money-flow pressure) and are fused with an absorption and price-impact overlay so that "loud but ineffective" pressure is discounted. The cross-timeframe path is a probabilistic log-odds consensus with an explicit correlation discount and a regime gate — specifically designed so that a cluster of correlated fast timeframes cannot fake a high-conviction reading, and so that chop is reported as chop. The built-in forward-test lets each user verify the behaviour on their own instrument.

LIMITATIONS / DISCLAIMER
This is an OHLCV-based study. The buy/sell split is a bar-level statistical estimate, not the true tape: it cannot see resting limit orders, the intrabar footprint, or off-book liquidity. Percentile strength is relative to recent history, not an absolute force. Multi-timeframe reads update intrabar unless Freeze is on. Works best on liquid, volume-bearing instruments; illiquid symbols or timeframes with little history may show "—".

This indicator is a decision-support study for context and education. It is NOT financial advice, NOT a signal service, and NOT a guarantee of future results. Markets involve risk; you are responsible for your own decisions and risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// BUYER vs SELLER CONTROL & PATH OF LEAST RESISTANCE (MTF)                                     v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// CHANGELOG
//   v1.1 — Control momentum (additive; the score, path fusion and forward-test maths are unchanged):
//     • New read: is YOUR-TF control BUILDING or FADING? ctrlAccel is the change in your chart
//       timeframe's control over a short window — the derivative of the buy/sell balance. A control
//       that is high but fading warns a verdict may be about to flip BEFORE the path itself turns.
//     • MOMENTUM row on the dashboard: ▲ buyers building / ▼ sellers building / • steady, with value.
//     • FLIP-RISK alert: fires once when your-TF control momentum turns hard AGAINST the current
//       path direction — an early caution the path may be about to flip.
//     • New EXP_ Data-Window export bus (chart control, control momentum, path state, path clarity,
//       P↑, chart strength) so other scripts can consume this engine.
//     • The five-lens fusion, microstructure damps, log-odds path and calibration are byte-for-byte v1.0.
// ────────────────────────────────────────────────────────────────────────────────────────────
// For every timeframe (1/2/3/5/15/30/60 by default) it shows WHO is in control (buyers/sellers) and
// HOW STRONGLY, on ONE comparable scale, plus the cross-TF PATH OF LEAST RESISTANCE. Your current
// chart timeframe is highlighted as YOUR TF, so at a glance you see whether to look for buys or sells
// on the screen you are trading — and the same read for every other TF, with a strength meter.
//
//  CONTROL SCORE (per bar, per TF) — a fused, signed order-pressure read in [-1,+1] from five lenses:
//    1 ORDER-FLOW DELTA (fast)  — Bulk-Volume-Classification signed volume, net÷gross balance ratio.
//    2 CVD (slow)               — the same signed volume over a longer window (persistent accumulation).
//    3 VWAP                      — location vs session VWAP (in ATR) + VWAP slope.
//    4 MA STACK                 — fast/mid/slow EMA interrelation (stacking) + fast-EMA slope.
//    5 VOLUME PRESSURE          — close-location-weighted money flow (CMF-style).
//    Microstructure conviction: an EFFORT-vs-RESULT absorption damp (strong pressure, no progress →
//    halve it) and a KYLE-λ price-impact scale (flow that actually moves price counts for more).
//  STRENGTH (0-100) — RELATIVE strength: the PERCENTILE RANK of |control| over a rolling window,
//    computed IN EACH TF's OWN context, so it is self-calibrating and comparable across timeframes
//    (a high % means control is strong *relative to that TF's own recent history*, not absolutely).
//  PATH OF LEAST RESISTANCE — a probabilistic fusion of all TFs: each TF's signed control (scaled by
//    its own strength and √(timeframe-seconds) horizon) is combined in LOG-ODDS (a weighted-mean
//    consensus, so redundant TFs can't accumulate), then DISCOUNTED when the TFs are merely
//    correlated rather than independently agreeing, then GATED by a chart efficiency-ratio regime
//    (choppy → CHOP). Reports ▲ UP / ▼ DOWN / = CHOP with a calibrated conviction % and how many
//    TFs agree, plus P↑ (probability up), ρ (inter-TF correlation) and regime %.
//
//  FORWARD TEST (Pro table) — a rolling hit-rate: how often the path direction from N bars ago was
//    followed by price actually moving that way. Computed only from confirmed PAST bars (no future
//    leak). A self-audit of the path on your symbol/settings — not a performance promise.
//
//  REPAINT — "Freeze to last closed bar" is ON by default: each TF shows its last CONFIRMED bar
//    (one bar behind, non-repainting) — the accurate, settled read to trade from. Turn it OFF for
//    the live developing value, which updates intrabar as each higher-TF bar forms (responsive but
//    provisional). Alerts evaluate on confirmed CHART bars; request.security uses lookahead OFF.
//
//  LIMITATIONS — OHLCV-based: the buy/sell split is a bar-level estimate (not the true tape) and
//    cannot see resting limit orders or true intrabar footprint. A study for context — NOT financial
//    advice, NOT a signal service.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Buyer vs Seller Control & Path of Least Resistance (MTF)", "Ctrl+Path", overlay = true, max_bars_back = 1000)

// ═══════════════════════════════════ INPUTS ═══════════════════════════════════
gS = "1 · Score"
useVol  = input.bool(true, "Weight by relative volume", group = gS)
volLen  = input.int(20, "Volume MA length", minval = 1, maxval = 200, group = gS)
bvcLen  = input.int(20, "BVC return-stdev window", minval = 5, maxval = 200, group = gS, tooltip = "Window for the standardized-return volatility used by the Bulk-Volume-Classification buy/sell split.")
normLen = input.int(100, "Strength normalization window", minval = 20, maxval = 300, group = gS, tooltip = "Strength = percentile rank of |control| over this window, in each TF's own context — self-calibrating and comparable across timeframes.")
bandPct = input.int(15, "Per-TF neutral band (%)", minval = 0, maxval = 60, group = gS, tooltip = "A TF's strength below this reads WAIT / balance instead of BUY / SELL.")
chopPct = input.int(15, "Path chop threshold (clarity %)", minval = 0, maxval = 60, group = gS, tooltip = "Cross-TF path clarity below this reads = CHOP.")
accLen  = input.int(3, "Control-momentum lookback (bars)", minval = 1, maxval = 50, group = gS, tooltip = "Bars over which YOUR-TF control change is measured for the MOMENTUM row and the flip-risk alert. Shorter = more reactive.")

gL = "2 · Lenses & microstructure"
dFast     = input.int(5,  "Order-flow delta window (fast)", minval = 2, maxval = 100, group = gL)
dSlow     = input.int(50, "CVD window (slow)", minval = 5, maxval = 300, group = gL)
enVWAP    = input.bool(true, "VWAP location + slope", group = gL)
vwSlopeLen= input.int(10, "VWAP slope lookback", minval = 2, maxval = 100, group = gL)
enMA      = input.bool(true, "MA stack (slopes + interrelation)", group = gL)
maFast    = input.int(9,  "EMA fast", minval = 2, maxval = 100, group = gL)
maMid     = input.int(21, "EMA mid", minval = 3, maxval = 200, group = gL)
maSlow    = input.int(50, "EMA slow", minval = 5, maxval = 300, group = gL)
maSlopeLen= input.int(10, "EMA slope lookback", minval = 2, maxval = 100, group = gL)
enVol     = input.bool(true, "Volume pressure (money-flow)", group = gL)
volPLen   = input.int(20, "Volume-pressure window", minval = 2, maxval = 200, group = gL)
enAbsorb  = input.bool(true, "Absorption damp (effort vs result)", group = gL, tooltip = "When control is strong but price has barely progressed, halve the score — the winning side is being absorbed.")
absLen    = input.int(5, "Absorption progress window", minval = 2, maxval = 50, group = gL)
absK      = input.float(0.5, "Absorption: progress < × ATR", minval = 0.1, step = 0.1, group = gL)
enKyle    = input.bool(true, "Kyle-λ impact scaling", group = gL, tooltip = "Price-impact proxy: correlation of |price move| with volume over the window. High = volume actually moves price (impactful), so the score counts for more; low = volume with little movement (absorption), so it counts for less.")
kyleLen   = input.int(50, "Kyle-λ window", minval = 10, maxval = 300, group = gL)
atrLen    = input.int(14, "ATR length", minval = 2, maxval = 100, group = gL)

gTF = "3 · Timeframes"
tf1 = input.timeframe("1",  "TF 1", group = gTF)
tf2 = input.timeframe("2",  "TF 2", group = gTF)
tf3 = input.timeframe("3",  "TF 3", group = gTF)
tf4 = input.timeframe("5",  "TF 4", group = gTF)
tf5 = input.timeframe("15", "TF 5", group = gTF)
tf6 = input.timeframe("30", "TF 6", group = gTF)
tf7 = input.timeframe("60", "TF 7", group = gTF)

gP = "4 · Path fusion"
loGain    = input.float(3.0, "Fusion gain (log-odds)", minval = 0.5, maxval = 8.0, step = 0.5, group = gP, tooltip = "Steepness of the logistic that maps the cross-TF consensus control to a probability. Higher = the path reaches high conviction faster.")
discK     = input.float(0.5, "Correlation discount", minval = 0.0, maxval = 1.0, step = 0.1, group = gP, tooltip = "Shrinks path conviction when timeframes merely echo each other (are highly correlated) instead of agreeing independently. 0 = off, 1 = full discount.")
corrLen   = input.int(50, "Inter-TF correlation window", minval = 10, maxval = 200, group = gP)
regimeLen = input.int(20, "Regime window (efficiency ratio)", minval = 5, maxval = 100, group = gP, tooltip = "Kaufman efficiency ratio on your chart: |net move| ÷ total path over this window. Low = choppy/mean-reverting, high = trending.")
erLo      = input.float(0.30, "Chop at/below ER", minval = 0.0, maxval = 1.0, step = 0.05, group = gP, tooltip = "Efficiency ratio at or below this = fully choppy: path conviction gated to zero (= CHOP).")
erHi      = input.float(0.60, "Trend at/above ER", minval = 0.0, maxval = 1.0, step = 0.05, group = gP, tooltip = "Efficiency ratio at or above this = fully trending: no regime damping.")
enCalib   = input.bool(true, "Forward-test the path (Pro table)", group = gP, tooltip = "Rolling hit-rate: how often the path direction from N bars ago was followed by price actually moving that way. A self-audit shown in the Pro table — uses only confirmed PAST bars, no future leak.")
calibN    = input.int(10, "Forward-test horizon (bars)", minval = 1, maxval = 50, group = gP)
calibWin  = input.int(300, "Forward-test window (bars)", minval = 20, maxval = 500, group = gP)

gR = "5 · Repaint"
freeze = input.bool(true, "Freeze to last closed bar (non-repaint)", group = gR, tooltip = "ON (default): each row shows the last CONFIRMED bar of its timeframe — non-repainting but one bar behind, and alerts use confirmed higher-TF reads. This is the accurate, settled read to trade from. OFF: the live developing value, which updates intrabar (responsive but provisional). Alerts always evaluate on confirmed CHART bars.")

gD = "6 · Display"
theme    = input.string("Dark", "Theme", options = ["Dark", "Light"], group = gD)
tblPos   = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)
dashMode = input.string("Compact", "Detail", options = ["Compact", "Pro"], group = gD, tooltip = "Compact: verdict + strength meter per TF. Pro adds the raw control value, the count of lenses agreeing, the ρ / regime path stats, and the forward-test hit-rate row.")
tintBg   = input.bool(true, "Tint background by path", group = gD, tooltip = "A faint full-chart wash coloured by the path of least resistance.")

// ═══════════════════════════════════ PALETTE ══════════════════════════════════
bool  isLight = theme == "Light"
color C_TEXT  = isLight ? color.new(#111318, 0) : color.new(#e8eaed, 0)
color C_MUTED = isLight ? color.new(#5f6368, 0) : color.new(#9aa0a6, 0)
color C_BG    = isLight ? color.new(#ffffff, 6) : color.new(#0e1116, 8)
color C_ALT   = isLight ? color.new(#eef1f4, 6) : color.new(#171b21, 8)
color C_HEAD  = color.new(#2962ff, 0)
color C_GRID  = color.new(color.gray, 40)
color C_UP    = #26a69a
color C_DN    = #ef5350

// ═══════════════════════════════════ HELPERS ══════════════════════════════════
f_sgn(float x) => x > 0 ? 1 : x < 0 ? -1 : 0
f_npdf(float x) => 0.3989422804014327 * math.exp(-x * x / 2.0)
f_ncdf(float x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float poly = t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    float p = f_npdf(x) * poly
    x >= 0 ? 1.0 - p : p

// number of enabled lenses (delta + cvd always on)
int nLens = 2 + (enVWAP ? 1 : 0) + (enMA ? 1 : 0) + (enVol ? 1 : 0)

// ── five-lens fused control in [-1,+1] (+ = buyers) + count of lenses agreeing ──
// All ta.*/math.sum are called UNCONDITIONALLY (v6-safe); toggles gate only the fused weights.
f_lenses() =>
    float atr = ta.atr(atrLen)
    float rng = high - low
    float r   = close - close[1]
    float sd  = ta.stdev(close - close[1], bvcLen)
    float bf  = sd > 0 ? f_ncdf(r / sd) : 0.5
    float vma = ta.sma(volume, volLen)
    float vadj= (useVol and not na(vma) and vma > 0) ? math.min(volume / vma, 3.0) : 1.0
    float dv  = volume * (2.0 * bf - 1.0) * vadj          // BVC signed volume (rel-vol weighted)
    float clv = rng > 0 ? ((close - low) - (high - close)) / rng : 0.0
    float ef  = ta.ema(close, maFast)
    float em  = ta.ema(close, maMid)
    float es  = ta.ema(close, maSlow)
    float vw  = ta.vwap
    float lam = ta.correlation(math.abs(r), volume, kyleLen)   // effort-vs-result impact: |move| vs volume (NOT derived from r's sign → no self-correlation)
    float sDvF = math.sum(dv, dFast)
    float sVF  = math.sum(volume, dFast)
    float sDvS = math.sum(dv, dSlow)
    float sVS  = math.sum(volume, dSlow)
    float sClv = math.sum(clv * volume, volPLen)
    float sVP  = math.sum(volume, volPLen)
    // lenses, each in [-1,+1]
    float lDelta = sVF > 0 ? sDvF / sVF : 0.0
    float lCVD   = sVS > 0 ? sDvS / sVS : 0.0
    float vloc = (not na(vw) and atr > 0) ? math.max(-1.0, math.min(1.0, (close - vw) / (2.0 * atr))) : 0.0
    float vslp = (not na(vw) and atr > 0) ? math.max(-1.0, math.min(1.0, (vw - vw[vwSlopeLen]) / atr)) : 0.0
    float lVWAP  = (vloc + vslp) / 2.0
    float stack  = ((ef > em ? 1.0 : -1.0) + (em > es ? 1.0 : -1.0) + (close > es ? 1.0 : -1.0)) / 3.0
    float mslp   = atr > 0 ? math.max(-1.0, math.min(1.0, (ef - ef[maSlopeLen]) / atr)) : 0.0
    float lMA    = 0.6 * stack + 0.4 * mslp
    float lVol   = sVP > 0 ? sClv / sVP : 0.0
    // weighted fuse (weights zero out disabled lenses, then renormalize)
    float wD = 0.30
    float wC = 0.20
    float wV = enVWAP ? 0.20 : 0.0
    float wM = enMA   ? 0.20 : 0.0
    float wL = enVol  ? 0.10 : 0.0
    float wsum = wD + wC + wV + wM + wL
    float ctrl = wsum > 0 ? (wD * lDelta + wC * lCVD + wV * lVWAP + wM * lMA + wL * lVol) / wsum : 0.0
    // microstructure conviction
    float prog   = atr > 0 ? math.abs(close - close[absLen]) / atr : 0.0
    bool  absorb = enAbsorb and math.abs(ctrl) > 0.4 and prog < absK
    float impact = (enKyle and not na(lam)) ? math.abs(lam) : 1.0
    float ctrlAdj = ctrl * (absorb ? 0.5 : 1.0) * (enKyle ? (0.6 + 0.4 * impact) : 1.0)
    ctrlAdj := math.max(-1.0, math.min(1.0, ctrlAdj))
    // how many enabled lenses agree with the fused direction
    int dir = f_sgn(ctrlAdj)
    int ag = (dir != 0 and f_sgn(lDelta) == dir ? 1 : 0) + (dir != 0 and f_sgn(lCVD) == dir ? 1 : 0) + (enVWAP and dir != 0 and f_sgn(lVWAP) == dir ? 1 : 0) + (enMA and dir != 0 and f_sgn(lMA) == dir ? 1 : 0) + (enVol and dir != 0 and f_sgn(lVol) == dir ? 1 : 0)
    [ctrlAdj, ag]

int _off = freeze ? 1 : 0

// control + self-calibrating strength + lens-agreement, computed once, offset by _off
f_pack() =>
    [c, ag] = f_lenses()
    float s = ta.percentrank(math.abs(c), normLen)
    [c[_off], s[_off], ag[_off]]

// one dispatch per TF
f_get(simple string tf) =>
    request.security(syminfo.tickerid, tf, f_pack(), lookahead = barmerge.lookahead_off)

[c1, z1, a1] = f_get(tf1)
[c2, z2, a2] = f_get(tf2)
[c3, z3, a3] = f_get(tf3)
[c4, z4, a4] = f_get(tf4)
[c5, z5, a5] = f_get(tf5)
[c6, z6, a6] = f_get(tf6)
[c7, z7, a7] = f_get(tf7)

// your current chart timeframe (computed locally — no extra dispatch)
[cChart, zChart, aChart] = f_pack()

// ═══════════════════════════════════ VERDICT / DISPLAY HELPERS ═════════════════
f_verdict(float c, float z) => (na(c) or na(z)) ? "—" : z < bandPct ? "WAIT" : c > 0 ? "BUY" : c < 0 ? "SELL" : "WAIT"
f_strTxt(float z) => na(z) ? "—" : str.tostring(int(math.round(z))) + "%"
f_dircol(float c, float z) =>
    int tr = 15 + int(math.min(70.0, nz(z) * 0.7))
    (na(c) or na(z) or z < bandPct) ? color.new(color.gray, 55) : c > 0 ? color.new(C_UP, 100 - tr) : color.new(C_DN, 100 - tr)
f_meter(float z) =>
    int n = na(z) ? 0 : int(math.max(0, math.min(10, math.round(z / 10.0))))
    na(z) ? "—" : str.repeat("█", n) + str.repeat("░", 10 - n)
f_agTxt(float a) => na(a) ? "—" : str.tostring(int(a)) + "/" + str.tostring(nLens)

// ═══════════════════════════════════ PATH OF LEAST RESISTANCE ══════════════════
// horizon-weighted LOG-ODDS fusion  →  CORRELATION discount  →  REGIME gate.
f_w(simple string tf) => math.sqrt(math.max(timeframe.in_seconds(tf), 1))
float w1 = f_w(tf1)
float w2 = f_w(tf2)
float w3 = f_w(tf3)
float w4 = f_w(tf4)
float w5 = f_w(tf5)
float w6 = f_w(tf6)
float w7 = f_w(tf7)

// per-TF signed log-odds evidence (0 if na); combined as a horizon-weighted MEAN so that
// redundant/correlated TFs form a consensus rather than accumulating.
f_lo(float c, float z) => (na(c) or na(z)) ? 0.0 : loGain * c * (z / 100.0)
f_aw(float c, float z, float w) => (na(c) or na(z)) ? 0.0 : w
float loNum = f_lo(c1,z1)*f_aw(c1,z1,w1) + f_lo(c2,z2)*f_aw(c2,z2,w2) + f_lo(c3,z3)*f_aw(c3,z3,w3) + f_lo(c4,z4)*f_aw(c4,z4,w4) + f_lo(c5,z5)*f_aw(c5,z5,w5) + f_lo(c6,z6)*f_aw(c6,z6,w6) + f_lo(c7,z7)*f_aw(c7,z7,w7)
float loDen = f_aw(c1,z1,w1) + f_aw(c2,z2,w2) + f_aw(c3,z3,w3) + f_aw(c4,z4,w4) + f_aw(c5,z5,w5) + f_aw(c6,z6,w6) + f_aw(c7,z7,w7)
float LO   = loDen > 0 ? loNum / loDen : 0.0
float pUp  = 1.0 / (1.0 + math.exp(-LO))            // probability buyers win the path
float convBase = math.abs(2.0 * pUp - 1.0)          // 0 (coin-flip) .. 1 (certain)

// CORRELATION DISCOUNT — when the TFs merely echo each other, their agreement is less informative.
// Average adjacent inter-TF control correlation (chart-timeline series) → shrink conviction.
float r12 = ta.correlation(c1, c2, corrLen)
float r23 = ta.correlation(c2, c3, corrLen)
float r34 = ta.correlation(c3, c4, corrLen)
float r45 = ta.correlation(c4, c5, corrLen)
float r56 = ta.correlation(c5, c6, corrLen)
float r67 = ta.correlation(c6, c7, corrLen)
int   rC  = (na(r12)?0:1)+(na(r23)?0:1)+(na(r34)?0:1)+(na(r45)?0:1)+(na(r56)?0:1)+(na(r67)?0:1)
float rS  = nz(r12)+nz(r23)+nz(r34)+nz(r45)+nz(r56)+nz(r67)
float rhoBar = rC > 0 ? rS / rC : 0.0
float disc = 1.0 - discK * math.max(0.0, rhoBar)    // ∈ [1-discK , 1]

// REGIME GATE — Kaufman efficiency ratio on the chart: choppy market → gate the path toward CHOP.
float erNum = math.abs(close - close[regimeLen])
float erDen = math.sum(math.abs(close - close[1]), regimeLen)
float er    = erDen > 0 ? erNum / erDen : 0.0
float reg   = math.max(0.0, math.min(1.0, (er - erLo) / math.max(erHi - erLo, 0.0001)))

float conv    = convBase * disc * reg
int   clarity = int(math.round(conv * 100))
bool  plrUp   = pUp >= 0.5
string plrDir = clarity < chopPct ? "= CHOP" : plrUp ? "▲ UP" : "▼ DOWN"
color  plrCol = clarity < chopPct ? color.new(color.gray, 45) : plrUp ? color.new(C_UP, 100 - (20 + int(clarity * 0.6))) : color.new(C_DN, 100 - (20 + int(clarity * 0.6)))
int    plrState = clarity < chopPct ? 0 : plrUp ? 1 : -1

f_agree(float c, float z, bool up) => (na(c) or na(z) or z < bandPct) ? 0 : (up ? (c > 0 ? 1 : 0) : (c < 0 ? 1 : 0))
int aligned = f_agree(c1,z1,plrUp) + f_agree(c2,z2,plrUp) + f_agree(c3,z3,plrUp) + f_agree(c4,z4,plrUp) + f_agree(c5,z5,plrUp) + f_agree(c6,z6,plrUp) + f_agree(c7,z7,plrUp)

// ═══════════════════════════════════ CONTROL MOMENTUM (v1.1) ═══════════════════
// ctrlAccel = change in YOUR-TF control over accLen bars — is the buy/sell balance
// building or fading? accThr is the "steady" dead-band. Flip-risk = strong control
// momentum AGAINST the current path (early warning the path may turn).
float accThr    = 0.05
float ctrlAccel = (not na(cChart) and not na(cChart[accLen])) ? cChart - cChart[accLen] : na
bool  buyBuild  = not na(ctrlAccel) and ctrlAccel >  accThr
bool  sellBuild = not na(ctrlAccel) and ctrlAccel < -accThr
string momTxt = na(ctrlAccel) ? "—" : buyBuild ? "▲ buyers building" : sellBuild ? "▼ sellers building" : "• steady"
color  momCol = na(ctrlAccel) ? C_MUTED : buyBuild ? C_UP : sellBuild ? C_DN : C_MUTED
// flip-risk: control momentum turning hard against the path (needs 2× the dead-band)
bool  flipRisk = plrState != 0 and not na(ctrlAccel) and ((plrState == 1 and ctrlAccel < -accThr * 2.0) or (plrState == -1 and ctrlAccel > accThr * 2.0))
var bool flipRiskPrev = false
bool  flipRiskNew = barstate.isconfirmed and flipRisk and not flipRiskPrev
if barstate.isconfirmed
    flipRiskPrev := flipRisk
color C_WARN = isLight ? #b56a00 : #ffa94d

// ═══════════════════════════════════ FORWARD CALIBRATION ═══════════════════════
// Rolling hit-rate of the PATH direction: did the path from calibN bars ago precede a move that way?
// Uses only confirmed past bars (plrState[calibN] vs realized close change) — no future leak.
int   pastDir = plrState[calibN]
float fwdRet  = close - close[calibN]
float hit     = (na(pastDir) or pastDir == 0) ? na : ((pastDir == 1 and fwdRet > 0) or (pastDir == -1 and fwdRet < 0)) ? 1.0 : 0.0
float hitSum  = math.sum(nz(hit), calibWin)
float hitCnt  = math.sum(na(hit) ? 0.0 : 1.0, calibWin)
float hitRate = (enCalib and hitCnt > 0) ? hitSum / hitCnt * 100.0 : na

// ═══════════════════════════════════ BACKGROUND TINT ══════════════════════════
bgcolor(tintBg and clarity >= chopPct ? color.new(plrUp ? C_UP : C_DN, 94) : na, title = "Path tint")

// ═══════════════════════════════════ TABLE ════════════════════════════════════
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right
bool proDash = dashMode == "Pro"
int  nCols = proDash ? 6 : 4
var table t = table.new(f_pos(tblPos), nCols, 13, border_width = 1, frame_width = 1, frame_color = C_GRID)

f_row(int rr, string tf, float c, float z, float a, color rbg) =>
    bool isChart = tf == timeframe.period
    table.cell(t, 0, rr, (isChart ? "▶ " : "") + tf, text_color = isChart ? C_TEXT : C_MUTED, text_size = size.small, bgcolor = isChart ? C_HEAD : rbg)
    table.cell(t, 1, rr, f_verdict(c, z), text_color = color.white, text_size = size.small, bgcolor = f_dircol(c, z))
    table.cell(t, 2, rr, f_strTxt(z), text_color = C_TEXT, text_size = size.small, bgcolor = rbg)
    table.cell(t, 3, rr, f_meter(z), text_color = (na(c) ? C_MUTED : c > 0 ? C_UP : C_DN), text_size = size.small, bgcolor = rbg)
    if proDash
        table.cell(t, 4, rr, na(c) ? "—" : str.tostring(c, "0.00"), text_color = C_TEXT, text_size = size.small, bgcolor = rbg)
        table.cell(t, 5, rr, f_agTxt(a), text_color = C_MUTED, text_size = size.small, bgcolor = rbg)

if barstate.islast
    // headline: PATH
    table.cell(t, 0, 0, "PATH", text_color = color.white, text_size = size.normal, bgcolor = plrCol)
    table.cell(t, 1, 0, plrDir, text_color = color.white, text_size = size.normal, bgcolor = plrCol)
    table.cell(t, 2, 0, str.tostring(clarity) + "%", text_color = color.white, text_size = size.normal, bgcolor = plrCol)
    table.cell(t, 3, 0, f_meter(clarity), text_color = color.white, text_size = size.normal, bgcolor = plrCol)
    if proDash
        table.cell(t, 4, 0, "agree", text_color = color.white, text_size = size.normal, bgcolor = plrCol)
        table.cell(t, 5, 0, str.tostring(aligned) + "/7", text_color = color.white, text_size = size.normal, bgcolor = plrCol)
    // YOUR TF — the actionable line
    table.cell(t, 0, 1, "YOUR TF " + timeframe.period, text_color = C_TEXT, text_size = size.small, bgcolor = C_HEAD)
    table.cell(t, 1, 1, f_verdict(cChart, zChart), text_color = color.white, text_size = size.small, bgcolor = f_dircol(cChart, zChart))
    table.cell(t, 2, 1, f_strTxt(zChart), text_color = C_TEXT, text_size = size.small, bgcolor = C_HEAD)
    table.cell(t, 3, 1, f_meter(zChart), text_color = (na(cChart) ? C_MUTED : cChart > 0 ? C_UP : C_DN), text_size = size.small, bgcolor = C_HEAD)
    if proDash
        table.cell(t, 4, 1, na(cChart) ? "—" : str.tostring(cChart, "0.00"), text_color = C_TEXT, text_size = size.small, bgcolor = C_HEAD)
        table.cell(t, 5, 1, f_agTxt(aChart), text_color = C_TEXT, text_size = size.small, bgcolor = C_HEAD)
    // AGREE + path stats (P↑ / regime / ρ)
    table.cell(t, 0, 2, "AGREE", text_color = C_MUTED, text_size = size.small, bgcolor = C_ALT)
    table.cell(t, 1, 2, str.tostring(aligned) + "/7 TFs", text_color = C_TEXT, text_size = size.small, bgcolor = C_ALT)
    table.cell(t, 2, 2, "P↑ " + str.tostring(int(math.round(pUp * 100))) + "%", text_color = pUp >= 0.5 ? C_UP : C_DN, text_size = size.small, bgcolor = C_ALT)
    table.cell(t, 3, 2, "reg " + str.tostring(int(math.round(reg * 100))) + "%", text_color = C_TEXT, text_size = size.small, bgcolor = C_ALT)
    if proDash
        table.cell(t, 4, 2, "ρ " + str.tostring(rhoBar, "0.00"), text_color = C_MUTED, text_size = size.small, bgcolor = C_ALT)
        table.cell(t, 5, 2, freeze ? "frozen" : "live", text_color = C_MUTED, text_size = size.small, bgcolor = C_ALT)
    // column header
    table.cell(t, 0, 3, "TF", text_color = color.white, text_size = size.small, bgcolor = C_GRID)
    table.cell(t, 1, 3, "Control", text_color = color.white, text_size = size.small, bgcolor = C_GRID)
    table.cell(t, 2, 3, "Strength", text_color = color.white, text_size = size.small, bgcolor = C_GRID)
    table.cell(t, 3, 3, "Meter", text_color = color.white, text_size = size.small, bgcolor = C_GRID)
    if proDash
        table.cell(t, 4, 3, "Raw", text_color = color.white, text_size = size.small, bgcolor = C_GRID)
        table.cell(t, 5, 3, "Lenses", text_color = color.white, text_size = size.small, bgcolor = C_GRID)
    // per-TF rows
    f_row(4,  tf1, c1, z1, a1, C_BG)
    f_row(5,  tf2, c2, z2, a2, C_ALT)
    f_row(6,  tf3, c3, z3, a3, C_BG)
    f_row(7,  tf4, c4, z4, a4, C_ALT)
    f_row(8,  tf5, c5, z5, a5, C_BG)
    f_row(9,  tf6, c6, z6, a6, C_ALT)
    f_row(10, tf7, c7, z7, a7, C_BG)
    // MOMENTUM — YOUR-TF control acceleration (both modes)
    table.cell(t, 0, 11, "MOMENTUM", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
    table.cell(t, 1, 11, momTxt, text_color = color.white, text_size = size.small, bgcolor = na(ctrlAccel) ? C_BG : color.new(momCol, 20))
    table.cell(t, 2, 11, na(ctrlAccel) ? "—" : str.tostring(ctrlAccel, "+0.00"), text_color = momCol, text_size = size.small, bgcolor = C_BG)
    table.cell(t, 3, 11, flipRisk ? "⚠ flip risk" : "", text_color = C_WARN, text_size = size.small, bgcolor = C_BG)
    if proDash
        table.cell(t, 4, 11, "acc " + str.tostring(accLen) + "b", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
        table.cell(t, 5, 11, "", text_color = C_MUTED, text_size = size.small, bgcolor = C_BG)
    // forward-test self-audit (Pro)
    if proDash and enCalib
        table.cell(t, 0, 12, "TEST", text_color = C_MUTED, text_size = size.small, bgcolor = C_ALT)
        table.cell(t, 1, 12, na(hitRate) ? "—" : "hit " + str.tostring(int(math.round(hitRate))) + "%", text_color = (na(hitRate) ? C_MUTED : hitRate >= 50 ? C_UP : C_DN), text_size = size.small, bgcolor = C_ALT)
        table.cell(t, 2, 12, "n=" + str.tostring(int(hitCnt)), text_color = C_MUTED, text_size = size.small, bgcolor = C_ALT)
        table.cell(t, 3, 12, str.tostring(calibN) + "b fwd", text_color = C_MUTED, text_size = size.small, bgcolor = C_ALT)
        table.cell(t, 4, 12, "", text_color = C_MUTED, text_size = size.small, bgcolor = C_ALT)
        table.cell(t, 5, 12, "", text_color = C_MUTED, text_size = size.small, bgcolor = C_ALT)

// ═══════════════════════════════════ EXPORTS (Data Window · generic names) ═════
plot(cChart,    "EXP_ChartControl",  display = display.data_window)
plot(ctrlAccel, "EXP_ControlAccel",  display = display.data_window)
plot(plrState,  "EXP_PathState",     display = display.data_window)
plot(clarity,   "EXP_PathClarity",   display = display.data_window)
plot(pUp,       "EXP_PathProbUp",    display = display.data_window)
plot(zChart,    "EXP_ChartStrength", display = display.data_window)

// ═══════════════════════════════════ ALERTS (confirmed-bar only) ═══════════════
alertcondition(barstate.isconfirmed and plrState == 1  and plrState[1] != 1,  "Path flips UP",   "Buyer vs Seller: path of least resistance flipped UP")
alertcondition(barstate.isconfirmed and plrState == -1 and plrState[1] != -1, "Path flips DOWN", "Buyer vs Seller: path of least resistance flipped DOWN")
alertcondition(barstate.isconfirmed and plrState == 0  and plrState[1] != 0,  "Path goes CHOP",  "Buyer vs Seller: path of least resistance turned to chop")
alertcondition(flipRiskNew, "Control flip risk", "Buyer vs Seller: your-TF control momentum is turning against the path — flip risk rising")
````
