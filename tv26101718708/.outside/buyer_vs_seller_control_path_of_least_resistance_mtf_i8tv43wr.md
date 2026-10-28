# Buyer vs Seller Control & Path of Least Resistance (MTF)

- url: https://www.tradingview.com/script/I8Tv43WR-Buyer-vs-Seller-Control-Path-of-Least-Resistance-MTF/
- type: indicator
- pine_id: PUB;553ddb099ed642e9beb15c4de27053a5
- version: 5.0

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

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// BUYER vs SELLER CONTROL & PATH OF LEAST RESISTANCE (MTF)                                     v2.4
// ────────────────────────────────────────────────────────────────────────────────────────────
// CHANGELOG
//   v2.4 — The three features deferred for library availability are now WIRED (ml_session/2, ml_rs/1,
//          ml_paramscan/1 are published). All additive and measure-first; adaptive gain is OFF by
//          default so the default path is byte-for-byte v2.3 on NIFTY.
//     • SESSION AWARENESS (ml_session) — time-of-day RVOL (slotRatio: "heavy for THIS time of day",
//       not vs a flat average) and the opening-auction INITIAL BALANCE (high/low + break state) for
//       NIFTY's 09:15 open. ToD-RVOL optionally nudges signal STRENGTH (a signal on time-of-day-heavy
//       volume grades higher); IB high/low can be drawn. New SESSION row (Pro). Direction/firing unchanged.
//     • INTERMARKET CONTEXT (ml_rs) — Mansfield relative strength, leadership state and RS slope of the
//       charted symbol vs a benchmark (default NSE:NIFTY). Leadership optionally nudges signal strength
//       (a long grades higher when the symbol is LEADING the benchmark; a short when lagging). New
//       INTERMKT row (Pro). On a NIFTY-futures chart vs NIFTY spot this reads the basis drift.
//     • ADAPTIVE FUSION GAIN (ml_paramscan, OPT-IN, default OFF) — scans five candidate log-odds gains,
//       scores each by a confidence-weighted hit score (reward confident-and-right, penalise confident-
//       and-wrong), and selects the STABLE PLATEAU (mean − λ·std) rather than the single best. Note the
//       path DIRECTION is gain-invariant; adaptive gain only tunes how fast clarity saturates — a
//       calibration aid, never a direction change.
//     • No change to the existing ml_flow/2 · ml_vsa/2 · ml_calib/2 calls. Compact table unchanged and
//       still the default; the new reads live in Pro rows.
//   v2.3 — Three additive, measure-first upgrades. Every default reproduces v2.2 behaviour on NIFTY
//          until you opt in; no library signatures changed (still ml_flow/2 · ml_vsa/2 · ml_calib/2).
//     • NEW — REVERSAL signal class (measure-first): a SEPARATE signal for turns, independent of the
//       trend-continuation signal. It fires when an accumulation/distribution DIVERGENCE coincides
//       with a VSA EXHAUSTION event (selling/buying climax, shakeout, upthrust, no-demand/no-supply)
//       AND your-TF control MOMENTUM flips the other way. Each carries a 0-100 strength and is
//       forward-resolved by strength bucket (cal.bucketWilsonLo) over the signal horizon — it draws
//       SOLID and fires the "proven" alert only once its bucket beats coin-flip on your symbol; until
//       then it draws faint and is measure-only. Circles (vs the continuation triangles). This is the
//       v2.3 REVERSAL item from the roadmap, built from primitives already in the script.
//     • NEW — TURBULENCE damp (Kritzman–Li financial turbulence): the squared standardized return,
//       self-calibrated to its own percentile. When turbulence is extreme (above the percentile
//       threshold) the PATH conviction is damped — unusual volatility makes the directional read less
//       reliable. Damps smoothly, never below 0.3×, and only above the threshold. This is the v2.3
//       turbulence/volatility-regime term. Shown in the Pro STATS row.
//     • NEW — BUY/SELL SPLIT METHOD selector: BVC (default, unchanged — Easley/López de Prado/O'Hara
//       bulk-volume classification from the standardized return) or TRIANGULAR (a bar-geometry CDF
//       from where open & close sit in the bar's range — no return-stdev, often a cleaner within-bar
//       read on gappy or thin instruments). Additive/opt-in: BVC keeps v2.2 output byte-for-byte.
//     • PERF/ROBUSTNESS: the external-symbol request.security sites are now gated to the chart symbol
//       when Volume source = Chart (no foreign data subscription in the default path). Edge cases on
//       the new reads hardened; Compact table is unchanged and stays the default.
//     • STILL DEFERRED (hard-blocked on unpublished libraries — would not compile today): adaptive
//       fusion gain (ml_paramscan), session awareness (ml_session), intermarket context (ml_rs).
//       These land once those libraries are published; the hooks are intentionally not wired yet.
//   v2.2 — Any asset class (one switch). NEW "Volume source" input (group 0): Chart (default) keeps
//          the chart instrument's own OHLCV — byte-for-byte the v2.1 behaviour on NIFTY futures and
//          any volume-bearing symbol. External (futures) borrows the whole order-flow read from a
//          matching futures symbol (e.g. NSE:BANKNIFTY1! under a BANKNIFTY spot chart) and overlays
//          it here, so the BVC delta, per-TF VSA, VPIN toxicity, Amihud and the LTF true-delta keep
//          working on a volume-less or thin spot chart — a cash index, spot FX, some stocks. The
//          per-TF control dispatch and the LTF sub-bar pulls follow the selected symbol; the chart
//          VPIN / Amihud flow reads follow its volume & price; the price you SEE is never changed.
//          Every default is unchanged and set for NIFTY — nothing differs until you switch assets.
//   v2.1 — Graded signal layer + responsive consensus + plan completion.
//     • CONSENSUS SCOPE + WEIGHTING: the path can use a chart-relative NESTED set — your TF plus the
//       2-5 nearest-higher rungs (default chart + 2) with EQUAL weighting (default) instead of the
//       full 7-TF √sec ladder, so the slow TFs no longer anchor the path and it flips closer to turns.
//     • GRADED BUY/SELL SIGNALS with STRENGTH (measure-first), forward-resolved by bucket; per-TF VSA
//       tag; Amihud illiquidity readout; VPIN gate + LTF validation enabled by default; signal cooldown.
//   v2.0 — Library rewire (ml_flow / ml_vsa / ml_calib v2): fitted Kyle-λ R², effort-result absorption,
//          shared efficiency ratio; HONEST forward-test (Wilson LB, edge-vs-null, runs-test z);
//          reliability calibration of clarity; control–price divergence; VPIN toxicity; LTF true-delta.
//   v1.1 — Control momentum (ctrlAccel), MOMENTUM row, FLIP-RISK alert, EXP_ export bus.
// ────────────────────────────────────────────────────────────────────────────────────────────
//  OVERVIEW
//  A multi-timeframe order-flow dashboard and graded signal engine for any asset class. Defaults are
//  set for NIFTY futures; on a volume-less or thin chart (a cash index, spot FX, some stocks) a single
//  "Volume source" input borrows the order flow from a matching futures symbol (group 0 · Data).
//  For each timeframe on a shared ladder (1/2/3/5/15/30/60 by default) it measures WHO is in control —
//  buyers or sellers — and HOW STRONGLY, on one comparable self-calibrating scale, then fuses the
//  timeframes into a single PATH OF LEAST RESISTANCE, a measure-first CONTINUATION signal, and (v2.3)
//  a measure-first REVERSAL signal.
//
//  METHODOLOGY  (every output is non-repainting and forward-tested before it is trusted)
//  • CONTROL SCORE — per timeframe, a signed order-pressure read in [-1,+1] fused from five lenses:
//       1 Order-flow delta (fast)   signed volume (BVC or triangular split), net ÷ gross balance.
//       2 CVD (slow)                the same signed volume over a longer accumulation window.
//       3 VWAP                      location vs session VWAP (ATR-normalised) + VWAP slope.
//       4 MA stack                  fast / mid / slow EMA interrelation + fast-EMA slope.
//       5 Volume pressure           close-location-weighted money flow (CMF-style).
//     Two microstructure damps refine it: an EFFORT-vs-RESULT absorption check (ml_vsa) and a
//     KYLE-λ R² price-impact scale (ml_flow) — flow that actually explains price counts for more.
//  • STRENGTH (0-100) — percentile rank of |control| in EACH timeframe's own recent history.
//  • PATH OF LEAST RESISTANCE — timeframes fused in LOG-ODDS into a probability P↑, discounted when
//     they merely echo one another (ρ), gated by a regime efficiency ratio (choppy → CHOP), and
//     (v2.3) damped in extreme turbulence.
//  • CONTINUATION SIGNAL (triangles) — fires when your chart-TF control NEWLY aligns with the path.
//  • REVERSAL SIGNAL (circles, v2.3) — fires on divergence + VSA exhaustion + control-momentum flip.
//     Both are strength-graded and forward-resolved (Wilson-floored); solid/proven only once the band
//     beats a coin-flip on your symbol, otherwise faint and measure-only.
//
//  DASHBOARD LEGEND
//    PATH      cross-TF path · clarity % · meter        (▲ UP / ▼ DOWN / = CHOP)  (Pro: ρ · freeze)
//    SIGNAL    continuation entry · str 0-100 · proven / measuring
//    YOUR TF   your chart timeframe's own control, strength and meter
//    STATS     agree n/N (nest|all) · P↑ · reg regime %   (Pro: turbulence pct)
//    per-TF    Control (BUY/SELL/WAIT) · Strength % · meter   (• = member of the path)
//    FLOW      MOMENTUM · DIVERGENCE · VPIN                (Pro: expanded to rows + REVERSAL)
//    TEST      path forward-test — hit % · LB · edge vs null · n · runs-z  (Pro)
//    CALIB     reliability of the current clarity band — LB % · n · VSA state  (Pro)
//    LTF Δ     lower-timeframe true signed delta — agrees / conflicts        (Pro)
//    REVERSAL  last reversal signal — dir · str · proven · LB · n            (Pro)
//    SESSION   time-of-day RVOL ×  · Initial-Balance break · opening window · slot   (Pro, v2.4)
//    INTERMKT  RS leadership vs benchmark · Mansfield RS · RS slope          (Pro, v2.4)
//    VSA       UT upthrust · SO shakeout · SV stopping-volume · ND no-demand · NS no-supply ·
//              Bclx / Sclx buy / sell climax · Abs absorption
//
//  LIMITATIONS — OHLCV-based. The buy/sell split (BVC or triangular), VPIN and the LTF delta are
//  bar-level ESTIMATES, not the true tape; they cannot see resting limit orders or the real intrabar
//  footprint. With Volume source = External the engine reads the FUTURES' flow (overlaid on your
//  chart); it assumes the future is a faithful proxy for the charted instrument's participation.
//  Continuation signals confirm an established move and will NOT mark the exact turn; reversal signals
//  attempt the turn and are inherently lower-base-rate — trust the forward-test, not the arrow.
//  Educational tool for context and study — NOT financial advice, NOT a signal service. Past behaviour
//  does not predict future results.
// ══════════════════════════════════════════════════════════════════════════════════════════════
import Market_Logic_India/ml_flow/2      as flow
import Market_Logic_India/ml_vsa/2       as vsa
import Market_Logic_India/ml_calib/2     as cal
import Market_Logic_India/ml_session/2   as sess
import Market_Logic_India/ml_rs/1        as rsx
import Market_Logic_India/ml_paramscan/1 as ps

indicator("Buyer vs Seller Control & Path of Least Resistance (MTF)", "Ctrl+Path", overlay = true, max_bars_back = 1000, max_labels_count = 500)

// ═══════════════════════════════════ INPUTS ═══════════════════════════════════
gData   = "0 · Data / asset class"
volSrc  = input.string("Chart", "Volume source", options = ["Chart", "External (futures)"], group = gData, tooltip = "Chart (default): use the chart instrument's own OHLCV — correct for NIFTY futures and any instrument with real volume. External (futures): borrow the whole order-flow read from a matching futures symbol below and overlay it on this chart — use it on a volume-less or thin-volume chart (a cash index, spot FX, some stocks) so the BVC delta, VSA, VPIN and the LTF true-delta keep working. Every default is set for NIFTY; change this only for other assets.")
volExtSym = input.symbol("NSE:NIFTY1!", "External volume symbol", group = gData, tooltip = "The futures (or other volume-bearing) symbol whose order flow drives the engine when Volume source = External. Pick the future that matches your chart — e.g. NSE:BANKNIFTY1! under a BANKNIFTY spot chart, or the lead future for an FX/commodity. Ignored when Volume source = Chart.")

gS = "1 · Score"
useVol  = input.bool(true, "Weight by relative volume", group = gS)
volLen  = input.int(20, "Volume MA length", minval = 1, maxval = 200, group = gS)
splitMethod = input.string("BVC (Bulk Volume Classification)", "Buy/sell split method", options = ["BVC (Bulk Volume Classification)", "Triangular (bar-geometry CDF)"], group = gS, tooltip = "How each bar's volume is split into buy vs sell. BVC (default, unchanged): Easley–López de Prado–O'Hara bulk-volume classification from the standardized return — robust, the v2.2 behaviour. Triangular: a bar-geometry CDF from where open & close sit in the bar's range (no return-stdev needed) — often a cleaner within-bar read on gappy or thin instruments. A/B them with the forward-test.")
bvcLen  = input.int(20, "BVC return-stdev window", minval = 5, maxval = 200, group = gS, tooltip = "Window for the standardized-return volatility used by the BVC buy/sell split. Ignored when the split method is Triangular.")
normLen = input.int(100, "Strength normalization window", minval = 20, maxval = 300, group = gS, tooltip = "Strength = percentile rank of |control| over this window, in each TF's own context — self-calibrating and comparable across timeframes.")
bandPct = input.int(15, "Per-TF neutral band (%)", minval = 0, maxval = 60, group = gS, tooltip = "A TF's strength below this reads WAIT / balance instead of BUY / SELL.")
chopPct = input.int(15, "Path chop threshold (clarity %)", minval = 0, maxval = 60, group = gS, tooltip = "Cross-TF path clarity below this reads = CHOP.")
accLen  = input.int(3, "Control-momentum lookback (bars)", minval = 1, maxval = 50, group = gS, tooltip = "Bars over which YOUR-TF control change is measured for the MOMENTUM row, the flip-risk alert and the reversal signal. Shorter = more reactive.")

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
enAbsorb  = input.bool(true, "Absorption damp (effort vs result)", group = gL, tooltip = "When control is strong but price has barely progressed OR the bar is a high-volume compression (vsa.effortResultState), halve the score — the winning side is being absorbed.")
absLen    = input.int(5, "Absorption progress window", minval = 2, maxval = 50, group = gL)
absK      = input.float(0.5, "Absorption: progress < × ATR", minval = 0.1, step = 0.1, group = gL)
enKyle    = input.bool(true, "Kyle-λ R² impact scaling", group = gL, tooltip = "Price-impact proxy: the R² of Δprice regressed on signed flow over the window (flow.kyleR2). High = flow actually explains price moves (impactful), so the score counts for more; low = flow with little explanatory power, so it counts for less.")
kyleLen   = input.int(50, "Kyle-λ window", minval = 10, maxval = 300, group = gL)
enAmihud  = input.bool(true, "Amihud illiquidity readout (Pro)", group = gL, tooltip = "flow.amihud: mean |return| ÷ traded value — a second, non-redundant price-impact lens, shown self-calibrated to its own percentile.")
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
consScope = input.string("Chart + 2 higher (nest 3)", "Consensus scope", options = ["Chart + 2 higher (nest 3)", "Chart + 3 higher (nest 4)", "Chart + 4 higher (nest 5)", "Chart + 5 higher (nest 6)", "All 7 (fixed)"], group = gP, tooltip = "How many timeframes feed the path: your chart TF plus the N nearest-higher ladder rungs. Smaller nests are more responsive and chart-relative; larger nests / All-7 give more cross-confirmation but lag more on fast charts. Default chart + 2 higher. A/B them with the forward-test.")
wMode     = input.string("Equal", "TF weighting", options = ["Equal", "Horizon (√sec)"], group = gP, tooltip = "Equal: every included timeframe counts the same — removes the slow-TF domination that made the path lag. Horizon: weight by √(timeframe seconds) so higher TFs dominate (the v2.0 behaviour).")
discK     = input.float(0.5, "Correlation discount", minval = 0.0, maxval = 1.0, step = 0.1, group = gP, tooltip = "Shrinks path conviction when timeframes merely echo each other (are highly correlated) instead of agreeing independently. 0 = off, 1 = full discount.")
corrLen   = input.int(50, "Inter-TF correlation window", minval = 10, maxval = 200, group = gP)
regimeLen = input.int(20, "Regime window (efficiency ratio)", minval = 5, maxval = 100, group = gP, tooltip = "Kaufman efficiency ratio on your chart (cal.efficiencyRatio): |net move| ÷ total path over this window. Low = choppy/mean-reverting, high = trending.")
erLo      = input.float(0.30, "Chop at/below ER", minval = 0.0, maxval = 1.0, step = 0.05, group = gP, tooltip = "Efficiency ratio at or below this = fully choppy: path conviction gated to zero (= CHOP).")
erHi      = input.float(0.60, "Trend at/above ER", minval = 0.0, maxval = 1.0, step = 0.05, group = gP, tooltip = "Efficiency ratio at or above this = fully trending: no regime damping.")
enTurb    = input.bool(true, "Turbulence damp (volatility regime)", group = gP, tooltip = "Kritzman–Li financial turbulence: the squared standardized return, self-calibrated to its own percentile. When turbulence is extreme (above the percentile threshold) the path conviction is damped — unusual volatility makes the directional read less reliable. Damps smoothly, never below 0.3×, and only above the threshold.")
turbLen   = input.int(100, "Turbulence window", minval = 20, maxval = 300, group = gP)
turbThrP  = input.int(85, "Damp above turbulence percentile", minval = 50, maxval = 99, group = gP)
enCalib   = input.bool(true, "Forward-test the path (Pro table)", group = gP, tooltip = "Rolling hit-rate: how often the path direction from N bars ago was followed by price actually moving that way. A self-audit shown in the Pro table — uses only confirmed PAST bars, no future leak.")
calibN    = input.int(10, "Forward-test horizon (bars)", minval = 1, maxval = 50, group = gP)
calibWin  = input.int(300, "Forward-test window (bars)", minval = 20, maxval = 500, group = gP)

gX = "5 · Divergence, toxicity & reliability (v2.0)"
enDiv    = input.bool(true, "Control–price divergence (row + alerts)", group = gX, tooltip = "Price makes a higher high while YOUR-TF control is falling (distribution), or a lower low while control rises (accumulation). Forward-tested like the path. Also feeds the v2.3 reversal signal.")
divLen   = input.int(10, "Divergence lookback (bars)", minval = 2, maxval = 100, group = gX)
enVPIN   = input.bool(true, "VPIN toxicity readout (chart)", group = gX, tooltip = "Σ|buy−sell| ÷ Σvolume over the window, then ranked as a percentile of its own recent history — a self-calibrating estimate of order-flow toxicity. High percentile = informed/toxic flow (your read is less reliable); low = benign.")
vpinLen  = input.int(50, "VPIN smoothing window", minval = 10, maxval = 300, group = gX)
vpinThrP = input.int(80, "Toxic at/above VPIN percentile", minval = 50, maxval = 99, group = gX, tooltip = "VPIN is ranked over the strength-normalization window; readings at/above this percentile of their own history read ⚠ toxic.")
vpinGate = input.bool(true, "Stand aside when toxic (YOUR-TF verdict only)", group = gX, tooltip = "Display-only: when toxic, the YOUR-TF verdict reads WAIT·tox. Never alters the path fusion or any other TF. Enabled by default in v2.1.")
enLTF    = input.bool(true, "LTF true-delta validation (chart TF)", group = gX, tooltip = "Drops to a lower timeframe's sub-bars for a truer signed delta than the bar-level BVC estimate (flow.signedVolLTF). Shown as a validation row and folded into the signal strength; the stricter 'require agreement' gate below is still off by default. Enabled by default in v2.1.")
ltfRes   = input.timeframe("1", "LTF resolution for true delta", group = gX)
ltfGate  = input.bool(false, "Require LTF agreement for YOUR-TF verdict", group = gX, tooltip = "Display-only: when the LTF true delta disagrees with the chart control, the YOUR-TF verdict reads WAIT·ltf. Never alters the path.")
enRelCal = input.bool(true, "Reliability calibration of clarity (Pro)", group = gX, tooltip = "Buckets the path clarity and forward-resolves each bucket (cal.bucketWilsonLo), so the conviction % can be checked against how often that clarity band actually wins.")
zWil     = input.float(1.0, "Wilson z (forward-test floor)", minval = 0.5, maxval = 2.6, step = 0.1, group = gX, tooltip = "z for the Wilson lower bound on the forward-test hit-rate and the calibration buckets. 1.0 ≈ 68%, 1.64 ≈ 90%, 1.96 ≈ 95%.")
enVSAlab = input.bool(true, "Chart VSA state tag (Pro)", group = gX, tooltip = "vsa.vsaLabel on the chart TF: no demand / upthrust / stopping volume / climax context.")

gSig = "6 · Signal layer"
enSig        = input.bool(true, "Graded BUY/SELL continuation signals", group = gSig, tooltip = "A signal fires when your chart TF's control NEWLY aligns with the path of least resistance. Each carries a 0-100 strength and is forward-tested by strength bucket — it draws solid / fires the proven alert only once its bucket beats coin-flip (Wilson-floored) on your symbol. Triangles.")
enRev        = input.bool(true, "Reversal signals (measure-first, v2.3)", group = gSig, tooltip = "A SEPARATE signal class for turns: fires when an accumulation/distribution divergence coincides with a VSA exhaustion event (climax / shakeout / upthrust / no-demand-supply) AND your-TF control momentum flips the other way. Forward-tested by strength bucket exactly like the continuation signal — solid / proven only once its bucket beats coin-flip. Circles (vs the continuation triangles).")
sigHorizon   = input.int(10, "Signal forward-test horizon (bars)", minval = 1, maxval = 50, group = gSig, tooltip = "Horizon used to forward-resolve BOTH the continuation and reversal strength buckets.")
minSamp      = input.int(20, "Min samples before a grade is 'proven'", minval = 5, maxval = 200, group = gSig)
sigDrawUnp   = input.bool(true, "Draw unproven signals (faint)", group = gSig, tooltip = "On: unproven signals draw faint (measure-only). Off: only grade-proven signals draw at all. Applies to both continuation and reversal.")
sigLabels    = input.bool(true, "Show strength number on signals", group = gSig)
sigMinGap    = input.int(3, "Signal cooldown (min bars between signals)", minval = 0, maxval = 100, group = gSig, tooltip = "Suppresses a new signal within this many bars of the previous one of the same class, to de-clutter consecutive-bar firing. 0 = off.")

gR = "7 · Repaint"
freeze = input.bool(true, "Freeze to last closed bar (non-repaint)", group = gR, tooltip = "ON (default): each row shows the last CONFIRMED bar of its timeframe — non-repainting but one bar behind, and alerts use confirmed higher-TF reads. OFF: the live developing value, which updates intrabar (responsive but provisional). Alerts always evaluate on confirmed CHART bars.")

gD = "8 · Display"
theme    = input.string("Dark", "Theme", options = ["Dark", "Light"], group = gD)
tblPos   = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)
dashMode = input.string("Compact", "Detail", options = ["Compact", "Pro"], group = gD, tooltip = "Compact (default): verdict + strength meter per TF. Pro adds the raw control value, lenses agreeing, ρ / regime / turbulence path stats, the honest forward-test, reliability calibration, chart VSA state and the reversal row.")
tintBg   = input.bool(true, "Tint background by path", group = gD, tooltip = "A faint full-chart wash coloured by the path of least resistance.")

gC = "9 · Session · Intermarket · Adaptive (v2.4)"
enSess    = input.bool(true, "Session awareness (ml_session)", group = gC, tooltip = "Time-of-day RVOL (how heavy this bar is FOR THIS TIME OF DAY, not vs a flat average) + the opening-auction Initial Balance (high/low + break state). Defaults suit NIFTY's 09:15 open. Display + optional strength nudge; never changes direction or firing.")
slotMin   = input.int(5, "Time-of-day slot (min)", minval = 1, maxval = 60, group = gC, tooltip = "Granularity of the time-of-day baseline. 5 = a fresh RVOL baseline every 5 minutes of the session.")
nSessMem  = input.int(20, "Sessions of memory", minval = 3, maxval = 100, group = gC, tooltip = "How many past sessions the per-slot EMA baselines remember (alpha ≈ 2/(N+1)).")
ibStartH  = input.int(9,  "Initial Balance start hour", minval = 0, maxval = 23, group = gC, tooltip = "Opening-window start hour in the symbol's exchange time. NIFTY = 9.")
ibStartM  = input.int(15, "Initial Balance start min", minval = 0, maxval = 59, group = gC, tooltip = "Opening-window start minute. NIFTY = 15 (09:15 open).")
ibWinMin  = input.int(60, "Initial Balance window (min)", minval = 5, maxval = 240, group = gC, tooltip = "Length of the opening auction that defines the Initial Balance. NIFTY default 60 min = 09:15–10:15.")
showIB    = input.bool(false, "Draw Initial Balance high/low", group = gC, tooltip = "Plots the opening-range high and low as stepped lines on the chart. Off by default to keep the chart clean.")
enSessStr = input.bool(true, "Fold ToD-RVOL into signal strength", group = gC, tooltip = "Measure-first: scales a signal's 0-100 strength by how heavy volume is for this time of day (0.9×–1.1×). Grading only — forward-tested like everything else; never changes direction or firing.")
enRS      = input.bool(true, "Intermarket RS (ml_rs)", group = gC, tooltip = "Relative strength of the charted symbol vs a benchmark (Mansfield RS, leadership state, RS slope). On a stock chart vs NIFTY this is leadership; on NIFTY futures vs NIFTY spot it reads the basis drift.")
rsBench   = input.symbol("NSE:NIFTY", "RS benchmark", group = gC, tooltip = "Benchmark the charted symbol is measured against. Default NSE:NIFTY. Fetched on the chart timeframe; non-repainting.")
rsLen     = input.int(50, "RS / Mansfield length", minval = 5, maxval = 300, group = gC)
rsSlopeLen= input.int(10, "RS slope lookback", minval = 2, maxval = 100, group = gC)
enRSStr   = input.bool(true, "Fold RS leadership into signal strength", group = gC, tooltip = "Measure-first: a long signal grades higher (×1.08) when the symbol is LEADING the benchmark and lower (×0.92) when lagging; vice-versa for shorts. Grading only; never changes direction or firing.")
enAdaptG  = input.bool(false, "Adaptive fusion gain (ml_paramscan)", group = gC, tooltip = "OFF by default (path = exactly v2.3). ON: scan five candidate log-odds gains, score each by a confidence-weighted hit score, and pick the stable plateau (mean − λ·std) instead of the single best. The path DIRECTION is gain-invariant, so this only tunes how fast clarity saturates — a calibration aid.")
agLambda  = input.float(0.5, "Plateau risk-aversion λ", minval = 0.0, maxval = 3.0, step = 0.1, group = gC, tooltip = "Higher λ penalises variance more when choosing the gain (more conservative plateau).")

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

// ═══════════════════════════════════ DATA SOURCE (asset class) ════════════════
// One switch makes the engine asset-agnostic. "Chart" = the chart's own OHLCV (NIFTY-default,
// identical to v2.1). "External (futures)" = run the whole order-flow read on a matching futures
// symbol and overlay it here. The request.security symbol is gated to the chart symbol when
// Volume source = Chart, so the default path subscribes to no foreign data (v2.3 perf).
bool   _extVol  = volSrc == "External (futures)"
string _flowSym = _extVol ? volExtSym : syminfo.tickerid
float  _vExtRaw = request.security(_flowSym, timeframe.period, volume, lookahead = barmerge.lookahead_off)
float  _cExtRaw = request.security(_flowSym, timeframe.period, close,  lookahead = barmerge.lookahead_off)
float  vSrc     = _extVol ? nz(_vExtRaw) : volume
float  cFlow    = _extVol ? nz(_cExtRaw) : close

// ═══════════════════════════════════ HELPERS ══════════════════════════════════
f_sgn(float x) => x > 0 ? 1 : x < 0 ? -1 : 0
f_npdf(float x) => 0.3989422804014327 * math.exp(-x * x / 2.0)
f_ncdf(float x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float poly = t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    float p = f_npdf(x) * poly
    x >= 0 ? 1.0 - p : p

// Triangular bar-geometry CDF → buy fraction in [0,1] (v2.3 optional split). Pure OHLC, no stdev.
// Integrates where open & close sit in the bar's range; robust to range == 0.
f_triFrac(float o, float h, float l, float c) =>
    float rng = h - l
    float cdf = na
    if rng == 0
        cdf := c > o ? 0.0 : (c < o ? 1.0 : 0.5)
    else
        float op = math.max(math.min(o, h), l)
        float md = math.max(math.min(c, h), l)
        if md == l
            cdf := op <= l ? 0.0 : 1.0 - math.pow((h - op) / rng, 2)
        else if md == h
            cdf := op >= h ? 1.0 : math.pow((op - l) / rng, 2)
        else
            float lw = md - l
            float rw = h - md
            if op <= l
                cdf := 0.0
            else if op <= md
                cdf := math.pow(op - l, 2) / (rng * lw)
            else if op < h
                cdf := 1.0 - math.pow(h - op, 2) / (rng * rw)
            else
                cdf := 1.0
    1.0 - cdf

bool _useTri = splitMethod == "Triangular (bar-geometry CDF)"

// number of enabled lenses (delta + cvd always on)
int nLens = 2 + (enVWAP ? 1 : 0) + (enMA ? 1 : 0) + (enVol ? 1 : 0)

// ── five-lens fused control in [-1,+1] (+ = buyers) + count of lenses agreeing + VSA code ──
// All ta.*/math.sum/library calls are UNCONDITIONAL (v6-safe); toggles gate only the fused weights.
f_lenses() =>
    float atr = ta.atr(atrLen)
    float rng = high - low
    float r   = close - close[1]
    float sd  = ta.stdev(close - close[1], bvcLen)
    float bf  = _useTri ? f_triFrac(open, high, low, close) : (sd > 0 ? f_ncdf(r / sd) : 0.5)
    float vma = ta.sma(volume, volLen)
    float vadj= (useVol and not na(vma) and vma > 0) ? math.min(volume / vma, 3.0) : 1.0
    float dv  = volume * (2.0 * bf - 1.0) * vadj          // signed volume (rel-vol weighted)
    float clv = rng > 0 ? ((close - low) - (high - close)) / rng : 0.0
    float ef  = ta.ema(close, maFast)
    float em  = ta.ema(close, maMid)
    float es  = ta.ema(close, maSlow)
    float vw  = ta.vwap
    float kr2 = flow.kyleR2(r, dv, kyleLen)               // fitted impact R² (replaces correlation proxy)
    int   erS = vsa.effortResultState(high, low, close, volume, absLen)  // validated compression/absorption state
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
    // microstructure conviction — absorption (progress OR vsa compression) + impact R² scaling
    float prog   = atr > 0 ? math.abs(close - close[absLen]) / atr : 0.0
    bool  absorb = enAbsorb and math.abs(ctrl) > 0.4 and (prog < absK or erS == 1)
    float impact = (enKyle and not na(kr2)) ? math.max(0.0, math.min(1.0, kr2)) : 1.0
    float ctrlAdj = ctrl * (absorb ? 0.5 : 1.0) * (enKyle ? (0.6 + 0.4 * impact) : 1.0)
    ctrlAdj := math.max(-1.0, math.min(1.0, ctrlAdj))
    // how many enabled lenses agree with the fused direction
    int dir = f_sgn(ctrlAdj)
    int ag = (dir != 0 and f_sgn(lDelta) == dir ? 1 : 0) + (dir != 0 and f_sgn(lCVD) == dir ? 1 : 0) + (enVWAP and dir != 0 and f_sgn(lVWAP) == dir ? 1 : 0) + (enMA and dir != 0 and f_sgn(lMA) == dir ? 1 : 0) + (enVol and dir != 0 and f_sgn(lVol) == dir ? 1 : 0)
    int vcode = vsa.vsaCode(high, low, close, volume, 20, 5)   // per-TF VSA event code
    [ctrlAdj, ag, vcode]

int _off = freeze ? 1 : 0

// control + self-calibrating strength + lens-agreement + VSA code, computed once, offset by _off
f_pack() =>
    [c, ag, vc] = f_lenses()
    float s = ta.percentrank(math.abs(c), normLen)
    [c[_off], s[_off], ag[_off], vc[_off]]

// one dispatch per TF — on _flowSym (chart symbol, or the external futures when selected)
f_get(simple string tf) =>
    request.security(_flowSym, tf, f_pack(), lookahead = barmerge.lookahead_off)

[c1, z1, a1, v1] = f_get(tf1)
[c2, z2, a2, v2] = f_get(tf2)
[c3, z3, a3, v3] = f_get(tf3)
[c4, z4, a4, v4] = f_get(tf4)
[c5, z5, a5, v5] = f_get(tf5)
[c6, z6, a6, v6] = f_get(tf6)
[c7, z7, a7, v7] = f_get(tf7)

// your current chart timeframe — local (live) read for Chart mode; dispatched on the external
// futures when Volume source = External, so the YOUR-TF row matches the per-TF rows and the flow reads.
[cChartL, zChartL, aChartL, vcChartL] = f_pack()
[cChartX, zChartX, aChartX, vcChartX] = request.security(_flowSym, timeframe.period, f_pack(), lookahead = barmerge.lookahead_off)
float cChart  = _extVol ? cChartX  : cChartL
float zChart  = _extVol ? zChartX  : zChartL
float aChart  = _extVol ? aChartX  : aChartL
int   vcChart = _extVol ? vcChartX : vcChartL

// VSA short tag for a cell
f_vsaShort(int code) => code == 3 ? "Bclx" : code == -3 ? "Sclx" : code == 2 ? "UT" : code == -2 ? "SO" : code == -1 ? "SV" : code == 4 ? "ND" : code == -4 ? "NS" : code == 5 ? "Abs" : ""

// ═══════════════════════════════════ VERDICT / DISPLAY HELPERS ═════════════════
f_verdict(float c, float z) => (na(c) or na(z)) ? "—" : z < bandPct ? "WAIT" : c > 0 ? "BUY" : c < 0 ? "SELL" : "WAIT"
f_strTxt(float z) => na(z) ? "—" : str.tostring(int(math.round(z))) + "%"
f_dircol(float c, float z) =>
    int tr = 15 + int(math.min(70.0, nz(z) * 0.7))
    (na(c) or na(z) or z < bandPct) ? color.new(color.gray, 55) : c > 0 ? color.new(C_UP, 100 - tr) : color.new(C_DN, 100 - tr)
f_meter(float z) =>
    int n = na(z) ? 0 : int(math.max(0, math.min(8, math.round(z / 12.5))))
    na(z) ? "—" : str.repeat("▰", n) + str.repeat("▱", 8 - n)
f_agTxt(float a) => na(a) ? "—" : str.tostring(int(a)) + "/" + str.tostring(nLens)

// ═══════════════════════════════════ PATH OF LEAST RESISTANCE ══════════════════
// horizon-weighted LOG-ODDS fusion  →  CORRELATION discount  →  REGIME gate  →  TURBULENCE damp.
f_w(simple string tf) => math.sqrt(math.max(timeframe.in_seconds(tf), 1))
f_nestInc(float si, float cs, float s1, float s2, float s3, float s4, float s5, float s6, float s7, int keepN, bool hiN) =>
    int above     = (s1 > si ? 1 : 0) + (s2 > si ? 1 : 0) + (s3 > si ? 1 : 0) + (s4 > si ? 1 : 0) + (s5 > si ? 1 : 0) + (s6 > si ? 1 : 0) + (s7 > si ? 1 : 0)
    int eligBelow = ((s1 >= cs and s1 < si) ? 1 : 0) + ((s2 >= cs and s2 < si) ? 1 : 0) + ((s3 >= cs and s3 < si) ? 1 : 0) + ((s4 >= cs and s4 < si) ? 1 : 0) + ((s5 >= cs and s5 < si) ? 1 : 0) + ((s6 >= cs and s6 < si) ? 1 : 0) + ((s7 >= cs and s7 < si) ? 1 : 0)
    hiN ? (above < keepN) : (si >= cs and eligBelow < keepN)
f_wUsed(bool inc, float wH) => not inc ? 0.0 : (wMode == "Equal" ? 1.0 : wH)
float w1 = f_w(tf1)
float w2 = f_w(tf2)
float w3 = f_w(tf3)
float w4 = f_w(tf4)
float w5 = f_w(tf5)
float w6 = f_w(tf6)
float w7 = f_w(tf7)
float sc1 = w1 * w1
float sc2 = w2 * w2
float sc3 = w3 * w3
float sc4 = w4 * w4
float sc5 = w5 * w5
float sc6 = w6 * w6
float sc7 = w7 * w7
float csec = math.max(timeframe.in_seconds(timeframe.period), 1)
int  nElig = (sc1>=csec?1:0)+(sc2>=csec?1:0)+(sc3>=csec?1:0)+(sc4>=csec?1:0)+(sc5>=csec?1:0)+(sc6>=csec?1:0)+(sc7>=csec?1:0)
int  _nestN = consScope == "Chart + 2 higher (nest 3)" ? 3 : consScope == "Chart + 3 higher (nest 4)" ? 4 : consScope == "Chart + 4 higher (nest 5)" ? 5 : consScope == "Chart + 5 higher (nest 6)" ? 6 : 7
bool _nest = consScope != "All 7 (fixed)"
bool _hiN  = nElig < _nestN
bool inc1 = not _nest or f_nestInc(sc1, csec, sc1,sc2,sc3,sc4,sc5,sc6,sc7, _nestN, _hiN)
bool inc2 = not _nest or f_nestInc(sc2, csec, sc1,sc2,sc3,sc4,sc5,sc6,sc7, _nestN, _hiN)
bool inc3 = not _nest or f_nestInc(sc3, csec, sc1,sc2,sc3,sc4,sc5,sc6,sc7, _nestN, _hiN)
bool inc4 = not _nest or f_nestInc(sc4, csec, sc1,sc2,sc3,sc4,sc5,sc6,sc7, _nestN, _hiN)
bool inc5 = not _nest or f_nestInc(sc5, csec, sc1,sc2,sc3,sc4,sc5,sc6,sc7, _nestN, _hiN)
bool inc6 = not _nest or f_nestInc(sc6, csec, sc1,sc2,sc3,sc4,sc5,sc6,sc7, _nestN, _hiN)
bool inc7 = not _nest or f_nestInc(sc7, csec, sc1,sc2,sc3,sc4,sc5,sc6,sc7, _nestN, _hiN)
int  nUsed = (inc1?1:0)+(inc2?1:0)+(inc3?1:0)+(inc4?1:0)+(inc5?1:0)+(inc6?1:0)+(inc7?1:0)
float wu1 = f_wUsed(inc1, w1)
float wu2 = f_wUsed(inc2, w2)
float wu3 = f_wUsed(inc3, w3)
float wu4 = f_wUsed(inc4, w4)
float wu5 = f_wUsed(inc5, w5)
float wu6 = f_wUsed(inc6, w6)
float wu7 = f_wUsed(inc7, w7)

// gain-free weighted consensus control (Bbase); the log-odds gain is applied AFTER adaptive
// selection below, so a candidate scan can reuse Bbase. Direction = sign(Bbase), gain-invariant.
f_ctrlW(float c, float z) => (na(c) or na(z)) ? 0.0 : c * (z / 100.0)
f_aw(float c, float z, float w) => (na(c) or na(z)) ? 0.0 : w
float bNum  = f_ctrlW(c1,z1)*f_aw(c1,z1,wu1) + f_ctrlW(c2,z2)*f_aw(c2,z2,wu2) + f_ctrlW(c3,z3)*f_aw(c3,z3,wu3) + f_ctrlW(c4,z4)*f_aw(c4,z4,wu4) + f_ctrlW(c5,z5)*f_aw(c5,z5,wu5) + f_ctrlW(c6,z6)*f_aw(c6,z6,wu6) + f_ctrlW(c7,z7)*f_aw(c7,z7,wu7)
float loDen = f_aw(c1,z1,wu1) + f_aw(c2,z2,wu2) + f_aw(c3,z3,wu3) + f_aw(c4,z4,wu4) + f_aw(c5,z5,wu5) + f_aw(c6,z6,wu6) + f_aw(c7,z7,wu7)
float Bbase = loDen > 0 ? bNum / loDen : 0.0
int   dirBase = Bbase > 0 ? 1 : Bbase < 0 ? -1 : 0

// CORRELATION DISCOUNT
float r12 = ta.correlation(c1, c2, corrLen)
float r23 = ta.correlation(c2, c3, corrLen)
float r34 = ta.correlation(c3, c4, corrLen)
float r45 = ta.correlation(c4, c5, corrLen)
float r56 = ta.correlation(c5, c6, corrLen)
float r67 = ta.correlation(c6, c7, corrLen)
int   rC  = (na(r12)?0:1)+(na(r23)?0:1)+(na(r34)?0:1)+(na(r45)?0:1)+(na(r56)?0:1)+(na(r67)?0:1)
float rS  = nz(r12)+nz(r23)+nz(r34)+nz(r45)+nz(r56)+nz(r67)
float rhoBar = rC > 0 ? rS / rC : 0.0
float disc = 1.0 - discK * math.max(0.0, rhoBar)

// REGIME GATE — shared efficiency ratio (ml_calib)
float er    = cal.efficiencyRatio(close, regimeLen)
float reg   = math.max(0.0, math.min(1.0, (er - erLo) / math.max(erHi - erLo, 0.0001)))

// TURBULENCE DAMP (v2.3) — Kritzman–Li financial turbulence, self-calibrated percentile.
float _tRet = close / close[1] - 1.0
float _tMu  = ta.sma(_tRet, turbLen)
float _tSd  = ta.stdev(_tRet, turbLen)
float _tRaw = _tSd > 0 ? math.pow((_tRet - _tMu) / _tSd, 2) : 0.0
float _tSm  = ta.sma(_tRaw, 5)
float turbPct  = ta.percentrank(_tSm, normLen)
float turbDamp = (enTurb and not na(turbPct)) ? math.max(0.3, 1.0 - 0.5 * math.max(0.0, (turbPct - turbThrP) / math.max(100.0 - turbThrP, 1.0))) : 1.0

// ADAPTIVE FUSION GAIN (v2.4, ml_paramscan) — scan candidate gains, score each by a confidence-
// weighted hit (reward confident-and-right, penalise confident-and-wrong), pick the stable plateau.
var array<float> _agGains = array.from(1.5, 2.0, 3.0, 4.0, 5.0)
f_convCand(float g) => math.abs(2.0 * (1.0 / (1.0 + math.exp(-g * Bbase))) - 1.0) * disc * reg * turbDamp
float cvK1 = f_convCand(1.5)
float cvK2 = f_convCand(2.0)
float cvK3 = f_convCand(3.0)
float cvK4 = f_convCand(4.0)
float cvK5 = f_convCand(5.0)
var array<float> _agMean = array.new<float>(5, na)
var array<float> _agM2   = array.new<float>(5, na)
var array<float> _agStd  = array.new<float>(5, na)
float _agAlpha = 2.0 / (calibWin + 1.0)
float _agFwd = close - close[calibN]
if barstate.isconfirmed and enAdaptG and not na(dirBase[calibN]) and dirBase[calibN] != 0 and not na(_agFwd)
    bool _agWin = (dirBase[calibN] == 1 and _agFwd > 0) or (dirBase[calibN] == -1 and _agFwd < 0)
    array<float> _agPast = array.from(cvK1[calibN], cvK2[calibN], cvK3[calibN], cvK4[calibN], cvK5[calibN])
    for _k = 0 to 4
        float _sc = nz(array.get(_agPast, _k)) * (_agWin ? 1.0 : -1.0)
        float _pm = array.get(_agMean, _k)
        float _pv = array.get(_agM2, _k)
        array.set(_agMean, _k, na(_pm) ? _sc : _pm + _agAlpha * (_sc - _pm))
        array.set(_agM2,   _k, na(_pv) ? _sc * _sc : _pv + _agAlpha * (_sc * _sc - _pv))
if enAdaptG
    for _k = 0 to 4
        float _m = array.get(_agMean, _k)
        float _e = array.get(_agM2, _k)
        array.set(_agStd, _k, (na(_m) or na(_e)) ? na : math.sqrt(math.max(_e - _m * _m, 0.0)))
int   _agBest = enAdaptG ? ps.stablePlateau(_agMean, _agStd, agLambda) : -1
float adaptiveGain = (enAdaptG and _agBest >= 0) ? array.get(_agGains, _agBest) : loGain
float loGainEff = enAdaptG ? adaptiveGain : loGain

float LO   = loGainEff * Bbase
float pUp  = 1.0 / (1.0 + math.exp(-LO))
float convBase = math.abs(2.0 * pUp - 1.0)
float conv    = convBase * disc * reg * turbDamp
int   clarity = int(math.round(conv * 100))
bool  plrUp   = pUp >= 0.5
string plrDir = clarity < chopPct ? "= CHOP" : plrUp ? "▲ UP" : "▼ DOWN"
color  plrCol = clarity < chopPct ? color.new(color.gray, 45) : plrUp ? color.new(C_UP, 100 - (20 + int(clarity * 0.6))) : color.new(C_DN, 100 - (20 + int(clarity * 0.6)))
int    plrState = clarity < chopPct ? 0 : plrUp ? 1 : -1

f_agree(float c, float z, bool up) => (na(c) or na(z) or z < bandPct) ? 0 : (up ? (c > 0 ? 1 : 0) : (c < 0 ? 1 : 0))
int aligned = (inc1?f_agree(c1,z1,plrUp):0) + (inc2?f_agree(c2,z2,plrUp):0) + (inc3?f_agree(c3,z3,plrUp):0) + (inc4?f_agree(c4,z4,plrUp):0) + (inc5?f_agree(c5,z5,plrUp):0) + (inc6?f_agree(c6,z6,plrUp):0) + (inc7?f_agree(c7,z7,plrUp):0)

// ═══════════════════════════════════ CONTROL MOMENTUM (v1.1) ═══════════════════
float accThr    = 0.05
float ctrlAccel = (not na(cChart) and not na(cChart[accLen])) ? cChart - cChart[accLen] : na
bool  buyBuild  = not na(ctrlAccel) and ctrlAccel >  accThr
bool  sellBuild = not na(ctrlAccel) and ctrlAccel < -accThr
string momTxt = na(ctrlAccel) ? "—" : buyBuild ? "▲ buyers building" : sellBuild ? "▼ sellers building" : "• steady"
color  momCol = na(ctrlAccel) ? C_MUTED : buyBuild ? C_UP : sellBuild ? C_DN : C_MUTED
bool  flipRisk = plrState != 0 and not na(ctrlAccel) and ((plrState == 1 and ctrlAccel < -accThr * 2.0) or (plrState == -1 and ctrlAccel > accThr * 2.0))
var bool flipRiskPrev = false
bool  flipRiskNew = barstate.isconfirmed and flipRisk and not flipRiskPrev
if barstate.isconfirmed
    flipRiskPrev := flipRisk
color C_WARN = isLight ? #b56a00 : #ffa94d

// ═══════════════════════════════════ CONTROL–PRICE DIVERGENCE (v2.0) ═══════════
bool bearDiv = enDiv and not na(cChart) and not na(cChart[divLen]) and close > close[divLen] and cChart < cChart[divLen]
bool bullDiv = enDiv and not na(cChart) and not na(cChart[divLen]) and close < close[divLen] and cChart > cChart[divLen]
int  divState = bearDiv ? -1 : bullDiv ? 1 : 0
string divTxt = bearDiv ? "▼ bear div" : bullDiv ? "▲ bull div" : "—"
color  divCol = bearDiv ? C_DN : bullDiv ? C_UP : C_MUTED
var bool divBearPrev = false
var bool divBullPrev = false
bool divBearNew = barstate.isconfirmed and bearDiv and not divBearPrev
bool divBullNew = barstate.isconfirmed and bullDiv and not divBullPrev
if barstate.isconfirmed
    divBearPrev := bearDiv
    divBullPrev := bullDiv
float fwdRetD  = close - close[calibN]
int   divPast  = divState[calibN]
float divHit   = (na(divPast) or divPast == 0) ? na : ((divPast == 1 and fwdRetD > 0) or (divPast == -1 and fwdRetD < 0)) ? 1.0 : 0.0
float divHitSum= math.sum(nz(divHit), calibWin)
float divHitCnt= math.sum(na(divHit) ? 0.0 : 1.0, calibWin)
float divRate  = divHitCnt > 0 ? divHitSum / divHitCnt * 100.0 : na

// ═══════════════════════════════════ VPIN TOXICITY (v2.0, chart) ═══════════════
float rCh  = cFlow - cFlow[1]
float sdCh = ta.stdev(cFlow - cFlow[1], bvcLen)
float bfCh = (_useTri and not _extVol) ? f_triFrac(open, high, low, close) : (sdCh > 0 ? f_ncdf(rCh / sdCh) : 0.5)
float dvCh = vSrc * (2.0 * bfCh - 1.0)
float _vpNum = ta.sma(math.abs(dvCh), vpinLen)       // hoisted (ta.* must run every bar — v6)
float _vpDen = ta.sma(vSrc, vpinLen)
float _vpRaw = _vpNum / math.max(_vpDen, 1e-9)
float _vpPct = ta.percentrank(_vpRaw, normLen)       // self-calibrating: percentile vs its own history
float vpin = enVPIN ? _vpPct : na
bool  toxic = enVPIN and not na(vpin) and vpin >= vpinThrP

// chart VSA state tag — reuse the chart TF's dispatched VSA code (one fewer library call)
string vsaChart = enVSAlab ? (f_vsaShort(vcChart) == "" ? "—" : f_vsaShort(vcChart)) : "—"

// ── LTF TRUE-DELTA validation (v2.0, chart TF) — request.security_lower_tf is top-level ──
array<float> _ltfV = request.security_lower_tf(_flowSym, ltfRes, volume)
array<float> _ltfC = request.security_lower_tf(_flowSym, ltfRes, close)
array<float> _ltfO = request.security_lower_tf(_flowSym, ltfRes, open)
[_lBuy, _lSell, _lDelta] = flow.signedVolLTF(_ltfV, _ltfC, _ltfO)
float _lTot     = _lBuy + _lSell
float ltfSigned = (enLTF and _lTot > 0) ? _lDelta / _lTot : na          // [-1,+1] true signed delta
int   ltfDir    = na(ltfSigned) ? 0 : ltfSigned > 0.05 ? 1 : ltfSigned < -0.05 ? -1 : 0
bool  ltfAgree  = enLTF and not na(ltfSigned) and not na(cChart) and f_sgn(cChart) != 0 and f_sgn(cChart) == f_sgn(ltfSigned)
bool  ltfConfl  = enLTF and not na(ltfSigned) and not na(cChart) and f_sgn(cChart) != 0 and ltfDir != 0 and f_sgn(cChart) != ltfDir
string ltfTxt   = na(ltfSigned) ? "—" : ltfDir > 0 ? "▲ LTF buy" : ltfDir < 0 ? "▼ LTF sell" : "• flat"
color  ltfCol   = na(ltfSigned) ? C_MUTED : ltfDir > 0 ? C_UP : ltfDir < 0 ? C_DN : C_MUTED
var bool ltfConflPrev = false
bool ltfConflNew = barstate.isconfirmed and ltfConfl and not ltfConflPrev
if barstate.isconfirmed
    ltfConflPrev := ltfConfl

// ═══════════════════════════════════ FORWARD CALIBRATION (v2.0 honest) ═════════
int   pastDir = plrState[calibN]
float fwdRet  = close - close[calibN]
float hit     = (na(pastDir) or pastDir == 0) ? na : ((pastDir == 1 and fwdRet > 0) or (pastDir == -1 and fwdRet < 0)) ? 1.0 : 0.0
float hitSum  = math.sum(nz(hit), calibWin)
float hitCnt  = math.sum(na(hit) ? 0.0 : 1.0, calibWin)
float hitRate = (enCalib and hitCnt > 0) ? hitSum / hitCnt * 100.0 : na
float hitLo   = (enCalib and hitCnt > 0) ? cal.wilsonLo(hitSum, hitCnt, zWil) : na
float upMoves = math.sum((close - close[calibN] > 0) ? 1.0 : 0.0, calibWin)
float totMove = math.sum((close - close[calibN] != 0) ? 1.0 : 0.0, calibWin)
float pUpBase = totMove > 0 ? upMoves / totMove : 0.5
float baseRate= math.max(pUpBase, 1.0 - pUpBase) * 100.0
float edgeNull= na(hitRate) ? na : hitRate - baseRate
var array<bool> hitRing = array.new<bool>()
if barstate.isconfirmed and not na(hit)
    array.push(hitRing, hit > 0.5)
    if array.size(hitRing) > calibWin
        array.shift(hitRing)
float runsZ = array.size(hitRing) >= 10 ? cal.runsTestZ(hitRing) : na

// reliability calibration — clarity buckets forward-resolved
var array<float> calWins = array.new<float>(5, 0.0)
var array<float> calN    = array.new<float>(5, 0.0)
if barstate.isconfirmed and enRelCal and not na(hit)
    int bidxPast = cal.bucketOf(clarity[calibN], 0.0, 100.0, 5)
    cal.bucketRecord(calWins, calN, bidxPast, hit > 0.5)
int   calIdxNow = cal.bucketOf(clarity, 0.0, 100.0, 5)
float calLoNow  = enRelCal ? cal.bucketWilsonLo(calWins, calN, calIdxNow, zWil) : na
float calNNow   = enRelCal ? cal.bucketN(calN, calIdxNow) : na

// ═══════════════════════════════════ AMIHUD ILLIQUIDITY (v2.1, chart) ══════════
float _amRet = cFlow / cFlow[1] - 1.0
float _amVal = vSrc * cFlow
float _amRaw = flow.amihud(_amRet, _amVal, kyleLen)
float _amPct = ta.percentrank(_amRaw, normLen)       // self-calibrating percentile
float amhPct = enAmihud ? _amPct : na

// ═══════════════════════════════════ SESSION AWARENESS (v2.4, ml_session) ══════
// Time-of-day RVOL + Initial Balance. All library calls are UNCONDITIONAL (they carry var state),
// toggles gate only the display/strength usage. ToD baselines run on the flow symbol's volume.
int   _slot    = sess.slotOf(slotMin)
int   _nSlots  = sess.slotCount(slotMin)
float _sAlpha  = sess.sessionAlpha(nSessMem)
float _todRvol = sess.slotRatio(vSrc, _slot, _nSlots, _sAlpha)   // 1.0 = normal for this time of day
bool  _newDay  = sess.isNewDay()
bool  _inIB    = sess.inOpeningWindow(ibStartH, ibStartM, ibWinMin)
[ibHigh, ibLow] = sess.initialBalance(_newDay, _inIB, high, low)
int   ibBrk    = enSess ? sess.ibBreak(close, ibHigh, ibLow) : 0
string _slotLbl = sess.slotLabel(_slot, slotMin)
// ToD-RVOL strength factor (0.9×–1.1×): a signal on time-of-day-heavy volume grades higher.
float _sessF = (enSess and enSessStr and not na(_todRvol)) ? math.max(0.9, math.min(1.1, 0.9 + 0.2 * math.min(1.0, (_todRvol - 0.7) / 0.8))) : 1.0
var bool _ibBrkUpPrev = false
var bool _ibBrkDnPrev = false
bool ibBreakUpNew = enSess and barstate.isconfirmed and ibBrk == 1  and not _ibBrkUpPrev
bool ibBreakDnNew = enSess and barstate.isconfirmed and ibBrk == -1 and not _ibBrkDnPrev
if barstate.isconfirmed
    _ibBrkUpPrev := ibBrk == 1
    _ibBrkDnPrev := ibBrk == -1

// ═══════════════════════════════════ INTERMARKET RS (v2.4, ml_rs) ══════════════
// Charted symbol vs a benchmark (default NSE:NIFTY). Price you SEE is used (chart close).
float _benchClose = request.security(rsBench, timeframe.period, close, lookahead = barmerge.lookahead_off)
float rsMans = enRS ? rsx.mansfield(close, _benchClose, rsLen) : na
int   rsLead = enRS ? rsx.rsLeading(close, _benchClose, rsLen) : 0
float rsSlp  = enRS ? rsx.rsSlope(close, _benchClose, rsSlopeLen) : na
string _rsBenchShort = str.replace_all(rsBench, "NSE:", "")
var int _rsLeadPrev = 0
bool rsLeadFlipUp = enRS and barstate.isconfirmed and rsLead == 1  and _rsLeadPrev != 1
bool rsLeadFlipDn = enRS and barstate.isconfirmed and rsLead == -1 and _rsLeadPrev != -1
if barstate.isconfirmed
    _rsLeadPrev := rsLead
// RS leadership strength factor, direction-aware.
f_rsF(int dir) => (enRS and enRSStr and rsLead != 0 and dir != 0) ? (rsLead == dir ? 1.08 : 0.92) : 1.0

// ═══════════════════════════════════ CONTINUATION SIGNAL (measure-first) ═══════
// A signal fires when YOUR-TF control NEWLY aligns with the path. Strength 0-100 = confluence.
bool _longAlign  = plrState == 1  and cChart > 0 and zChart >= bandPct
bool _shortAlign = plrState == -1 and cChart < 0 and zChart >= bandPct
bool _longRaw  = enSig and barstate.isconfirmed and _longAlign  and not _longAlign[1]
bool _shortRaw = enSig and barstate.isconfirmed and _shortAlign and not _shortAlign[1]
var int _lastSigBar = na
bool _gapOk = na(_lastSigBar) or (bar_index - _lastSigBar) >= sigMinGap
bool longTrig  = _longRaw  and _gapOk
bool shortTrig = _shortRaw and _gapOk
if longTrig or shortTrig
    _lastSigBar := bar_index
int  sigDir = longTrig ? 1 : shortTrig ? -1 : 0
float _sgClar = nz(clarity) / 100.0
float _sgAgr  = nUsed > 0 ? aligned / float(nUsed) : 0.0
float _sgConv = math.abs(2.0 * pUp - 1.0)
float _sgStr  = nz(zChart) / 100.0
float _sgLTF  = (enLTF and ltfAgree) ? 1.0 : (enLTF and ltfConfl) ? 0.0 : 0.5
float _sgRaw  = 0.30 * _sgClar + 0.25 * _sgAgr + 0.20 * _sgConv + 0.15 * _sgStr + 0.10 * _sgLTF
float _sgTox  = toxic ? 0.6 : 1.0
float sigStrength = sigDir != 0 ? math.max(0.0, math.min(100.0, 100.0 * _sgRaw * _sgTox * _sessF * f_rsF(sigDir))) : na
int   sigBkt = sigDir != 0 ? cal.bucketOf(sigStrength, 0.0, 100.0, 5) : na
var array<float> sgWins = array.new<float>(5, 0.0)
var array<float> sgN    = array.new<float>(5, 0.0)
int   _sigDirPast = sigDir[sigHorizon]
float _fwdRetS    = close - close[sigHorizon]
if barstate.isconfirmed and not na(_sigDirPast) and _sigDirPast != 0
    bool _sgWin   = (_sigDirPast == 1 and _fwdRetS > 0) or (_sigDirPast == -1 and _fwdRetS < 0)
    int  _sgBktPast = sigBkt[sigHorizon]
    cal.bucketRecord(sgWins, sgN, _sgBktPast, _sgWin)
float sigLo = sigDir != 0 ? cal.bucketWilsonLo(sgWins, sgN, sigBkt, zWil) : na
float sigNN = sigDir != 0 ? cal.bucketN(sgN, sigBkt) : na
bool  sigProven = not na(sigLo) and sigLo > 50.0 and not na(sigNN) and sigNN >= minSamp
color _sigUpCol = sigProven ? color.new(C_UP, 0) : color.new(C_UP, 60)
color _sigDnCol = sigProven ? color.new(C_DN, 0) : color.new(C_DN, 60)
plotshape(longTrig  and (sigProven or sigDrawUnp) ? low  : na, "BUY signal",  style = shape.triangleup,   location = location.belowbar, color = _sigUpCol, size = size.tiny)
plotshape(shortTrig and (sigProven or sigDrawUnp) ? high : na, "SELL signal", style = shape.triangledown, location = location.abovebar, color = _sigDnCol, size = size.tiny)
if enSig and sigLabels and (longTrig or shortTrig) and (sigProven or sigDrawUnp)
    label.new(bar_index, longTrig ? low : high, str.tostring(int(math.round(sigStrength))) + (sigProven ? "✓" : ""), yloc = longTrig ? yloc.belowbar : yloc.abovebar, style = longTrig ? label.style_label_up : label.style_label_down, color = longTrig ? _sigUpCol : _sigDnCol, textcolor = color.white, size = size.tiny)
var int   lastSigDir = 0
var float lastSigStr = na
var bool  lastSigPrv = false
if sigDir != 0
    lastSigDir := sigDir
    lastSigStr := sigStrength
    lastSigPrv := sigProven

// ═══════════════════════════════════ REVERSAL SIGNAL (v2.3, measure-first) ═════
// Divergence (accumulation/distribution) + VSA exhaustion + control-momentum flip the other way.
bool _vsaTop = vcChart == 2 or vcChart == 3 or vcChart == 4      // upthrust / buy climax / no-demand
bool _vsaBot = vcChart == -1 or vcChart == -2 or vcChart == -3 or vcChart == -4   // SV / shakeout / sell climax / no-supply
bool _revBullRaw = enRev and barstate.isconfirmed and bullDiv and _vsaBot and buyBuild
bool _revBearRaw = enRev and barstate.isconfirmed and bearDiv and _vsaTop and sellBuild
var int _lastRevBar = na
bool _revGapOk = na(_lastRevBar) or (bar_index - _lastRevBar) >= sigMinGap
bool revBull = _revBullRaw and _revGapOk
bool revBear = _revBearRaw and _revGapOk
if revBull or revBear
    _lastRevBar := bar_index
int revDir = revBull ? 1 : revBear ? -1 : 0
float _rvMom  = math.min(1.0, math.abs(nz(ctrlAccel)) / (accThr * 4.0))
float _rvStr  = nz(zChart) / 100.0
float _rvConv = math.abs(2.0 * pUp - 1.0)
float _rvRaw  = 0.40 * _rvMom + 0.30 * _rvStr + 0.30 * _rvConv
float revStrength = revDir != 0 ? math.max(0.0, math.min(100.0, 100.0 * _rvRaw * _sgTox * _sessF * f_rsF(revDir))) : na
int   revBkt = revDir != 0 ? cal.bucketOf(revStrength, 0.0, 100.0, 5) : na
var array<float> rvWins = array.new<float>(5, 0.0)
var array<float> rvN    = array.new<float>(5, 0.0)
int   _revDirPast = revDir[sigHorizon]
if barstate.isconfirmed and not na(_revDirPast) and _revDirPast != 0
    bool _rvWin = (_revDirPast == 1 and _fwdRetS > 0) or (_revDirPast == -1 and _fwdRetS < 0)
    int  _rvBktPast = revBkt[sigHorizon]
    cal.bucketRecord(rvWins, rvN, _rvBktPast, _rvWin)
float revLo = revDir != 0 ? cal.bucketWilsonLo(rvWins, rvN, revBkt, zWil) : na
float revNN = revDir != 0 ? cal.bucketN(rvN, revBkt) : na
bool  revProven = not na(revLo) and revLo > 50.0 and not na(revNN) and revNN >= minSamp
color _revUpCol = revProven ? color.new(C_UP, 0) : color.new(C_UP, 60)
color _revDnCol = revProven ? color.new(C_DN, 0) : color.new(C_DN, 60)
plotshape(revBull and (revProven or sigDrawUnp) ? low  : na, "Reversal BUY",  style = shape.circle, location = location.belowbar, color = _revUpCol, size = size.tiny)
plotshape(revBear and (revProven or sigDrawUnp) ? high : na, "Reversal SELL", style = shape.circle, location = location.abovebar, color = _revDnCol, size = size.tiny)
if enRev and sigLabels and (revBull or revBear) and (revProven or sigDrawUnp)
    label.new(bar_index, revBull ? low : high, "R" + str.tostring(int(math.round(revStrength))) + (revProven ? "✓" : ""), yloc = revBull ? yloc.belowbar : yloc.abovebar, style = revBull ? label.style_label_up : label.style_label_down, color = revBull ? _revUpCol : _revDnCol, textcolor = color.white, size = size.tiny)
var int   lastRevDir = 0
var float lastRevStr = na
var bool  lastRevPrv = false
if revDir != 0
    lastRevDir := revDir
    lastRevStr := revStrength
    lastRevPrv := revProven

// ═══════════════════════════════════ BACKGROUND TINT ══════════════════════════
bgcolor(tintBg and clarity >= chopPct ? color.new(plrUp ? C_UP : C_DN, 94) : na, title = "Path tint")

// Initial Balance lines (v2.4, optional)
plot(showIB and enSess and not na(ibHigh) ? ibHigh : na, "IB High", color = color.new(C_UP, 0), style = plot.style_stepline, linewidth = 1)
plot(showIB and enSess and not na(ibLow)  ? ibLow  : na, "IB Low",  color = color.new(C_DN, 0), style = plot.style_stepline, linewidth = 1)

// ═══════════════════════════════════ TABLE ════════════════════════════════════
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right
bool proDash = dashMode == "Pro"
int  nCols = proDash ? 6 : 4
var table t = table.new(f_pos(tblPos), nCols, 21, border_width = 1, frame_width = 1, frame_color = C_GRID)

f_row(int rr, string tf, float c, float z, float a, int vc, bool inc, color rbg) =>
    bool isChart = tf == timeframe.period
    table.cell(t, 0, rr, (isChart ? "▶ " : inc ? "• " : "  ") + tf, text_color = isChart ? C_TEXT : inc ? C_TEXT : C_MUTED, text_size = size.tiny, bgcolor = isChart ? C_HEAD : rbg)
    table.cell(t, 1, rr, f_verdict(c, z), text_color = color.white, text_size = size.tiny, bgcolor = f_dircol(c, z))
    table.cell(t, 2, rr, f_strTxt(z), text_color = C_TEXT, text_size = size.tiny, bgcolor = rbg)
    table.cell(t, 3, rr, f_meter(z), text_color = (na(c) ? C_MUTED : c > 0 ? C_UP : C_DN), text_size = size.tiny, bgcolor = rbg)
    if proDash
        table.cell(t, 4, rr, na(c) ? "—" : str.tostring(c, "0.00"), text_color = C_TEXT, text_size = size.tiny, bgcolor = rbg)
        string _lensTxt = f_agTxt(a) + (enVSAlab and f_vsaShort(vc) != "" ? " " + f_vsaShort(vc) : "")
        table.cell(t, 5, rr, _lensTxt, text_color = C_MUTED, text_size = size.tiny, bgcolor = rbg)

if barstate.islast
    // ── PATH (headline) ──
    table.cell(t, 0, 0, "PATH", text_color = color.white, text_size = size.small, bgcolor = plrCol)
    table.cell(t, 1, 0, plrDir, text_color = color.white, text_size = size.small, bgcolor = plrCol)
    table.cell(t, 2, 0, str.tostring(clarity) + "%", text_color = color.white, text_size = size.small, bgcolor = plrCol)
    table.cell(t, 3, 0, f_meter(clarity), text_color = color.white, text_size = size.small, bgcolor = plrCol)
    if proDash
        table.cell(t, 4, 0, "ρ " + str.tostring(rhoBar, "0.00"), text_color = color.white, text_size = size.tiny, bgcolor = plrCol)
        table.cell(t, 5, 0, (enAdaptG ? "g" + str.tostring(loGainEff, "0.0") + " " : "") + (freeze ? "frz" : "live"), text_color = color.white, text_size = size.tiny, bgcolor = plrCol)
    // ── SIGNAL (promoted headline) ──
    color _sigBg = lastSigDir == 1 ? color.new(C_UP, 20) : lastSigDir == -1 ? color.new(C_DN, 20) : color.new(color.gray, 55)
    table.cell(t, 0, 1, "SIGNAL", text_color = color.white, text_size = size.small, bgcolor = C_HEAD)
    table.cell(t, 1, 1, lastSigDir == 1 ? "▲ BUY" : lastSigDir == -1 ? "▼ SELL" : "—", text_color = color.white, text_size = size.small, bgcolor = _sigBg)
    table.cell(t, 2, 1, na(lastSigStr) ? "str —" : "str " + str.tostring(int(math.round(lastSigStr))), text_color = color.white, text_size = size.small, bgcolor = _sigBg)
    table.cell(t, 3, 1, lastSigDir == 0 ? "—" : lastSigPrv ? "✓ proven" : "measuring", text_color = lastSigPrv ? C_UP : C_MUTED, text_size = size.tiny, bgcolor = C_HEAD)
    if proDash
        table.cell(t, 4, 1, na(sigLo) ? "" : "LB " + str.tostring(int(math.round(sigLo))) + "%", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_HEAD)
        table.cell(t, 5, 1, na(sigNN) ? "" : "n=" + str.tostring(int(sigNN)), text_color = C_MUTED, text_size = size.tiny, bgcolor = C_HEAD)
    // ── YOUR TF ──
    string _baseVerd = f_verdict(cChart, zChart)
    string chartVerd = (vpinGate and toxic) ? "WAIT·tox" : (ltfGate and enLTF and ltfConfl and _baseVerd != "WAIT") ? "WAIT·ltf" : _baseVerd
    color  chartVcol = ((vpinGate and toxic) or (ltfGate and enLTF and ltfConfl and _baseVerd != "WAIT")) ? color.new(color.gray, 45) : f_dircol(cChart, zChart)
    table.cell(t, 0, 2, "TF " + timeframe.period, text_color = C_TEXT, text_size = size.tiny, bgcolor = C_HEAD)
    table.cell(t, 1, 2, chartVerd, text_color = color.white, text_size = size.tiny, bgcolor = chartVcol)
    table.cell(t, 2, 2, f_strTxt(zChart), text_color = C_TEXT, text_size = size.tiny, bgcolor = C_HEAD)
    table.cell(t, 3, 2, f_meter(zChart), text_color = (na(cChart) ? C_MUTED : cChart > 0 ? C_UP : C_DN), text_size = size.tiny, bgcolor = C_HEAD)
    if proDash
        table.cell(t, 4, 2, na(cChart) ? "—" : str.tostring(cChart, "0.00"), text_color = C_TEXT, text_size = size.tiny, bgcolor = C_HEAD)
        table.cell(t, 5, 2, f_agTxt(aChart) + (enVSAlab and f_vsaShort(vcChart) != "" ? " " + f_vsaShort(vcChart) : ""), text_color = C_TEXT, text_size = size.tiny, bgcolor = C_HEAD)
    // ── STATS ──
    table.cell(t, 0, 3, "STATS", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
    table.cell(t, 1, 3, str.tostring(aligned) + "/" + str.tostring(nUsed) + (_nest ? " nest" : " all"), text_color = C_TEXT, text_size = size.tiny, bgcolor = C_ALT)
    table.cell(t, 2, 3, "P↑ " + str.tostring(int(math.round(pUp * 100))) + "%", text_color = pUp >= 0.5 ? C_UP : C_DN, text_size = size.tiny, bgcolor = C_ALT)
    table.cell(t, 3, 3, "reg " + str.tostring(int(math.round(reg * 100))) + "%", text_color = C_TEXT, text_size = size.tiny, bgcolor = C_ALT)
    if proDash
        table.cell(t, 4, 3, (enTurb and not na(turbPct)) ? "turb " + str.tostring(int(math.round(turbPct))) : "", text_color = (enTurb and turbDamp < 0.95) ? C_WARN : C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
        table.cell(t, 5, 3, _useTri ? "tri" : "bvc", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
    // ── per-TF header ──
    table.cell(t, 0, 4, "TF", text_color = color.white, text_size = size.tiny, bgcolor = C_GRID)
    table.cell(t, 1, 4, "Control", text_color = color.white, text_size = size.tiny, bgcolor = C_GRID)
    table.cell(t, 2, 4, "Str", text_color = color.white, text_size = size.tiny, bgcolor = C_GRID)
    table.cell(t, 3, 4, "Meter", text_color = color.white, text_size = size.tiny, bgcolor = C_GRID)
    if proDash
        table.cell(t, 4, 4, "Raw", text_color = color.white, text_size = size.tiny, bgcolor = C_GRID)
        table.cell(t, 5, 4, "Lens·VSA", text_color = color.white, text_size = size.tiny, bgcolor = C_GRID)
    // ── per-TF rows (• = path member) ──
    f_row(5,  tf1, c1, z1, a1, v1, inc1, C_BG)
    f_row(6,  tf2, c2, z2, a2, v2, inc2, C_ALT)
    f_row(7,  tf3, c3, z3, a3, v3, inc3, C_BG)
    f_row(8,  tf4, c4, z4, a4, v4, inc4, C_ALT)
    f_row(9,  tf5, c5, z5, a5, v5, inc5, C_BG)
    f_row(10, tf6, c6, z6, a6, v6, inc6, C_ALT)
    f_row(11, tf7, c7, z7, a7, v7, inc7, C_BG)
    // ── context ──
    string _momShort = na(ctrlAccel) ? "—" : buyBuild ? "▲ build" : sellBuild ? "▼ fade" : "• steady"
    if not proDash
        // COMPACT — one merged FLOW row: momentum · divergence · VPIN
        table.cell(t, 0, 12, "FLOW", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
        table.cell(t, 1, 12, _momShort + (flipRisk ? " ⚠" : ""), text_color = color.white, text_size = size.tiny, bgcolor = na(ctrlAccel) ? C_BG : color.new(momCol, 25))
        table.cell(t, 2, 12, enDiv ? divTxt : "—", text_color = (enDiv and divState != 0) ? color.white : C_MUTED, text_size = size.tiny, bgcolor = (enDiv and divState != 0) ? color.new(divCol, 30) : C_BG)
        table.cell(t, 3, 12, enVPIN ? (toxic ? "⚠ toxic" : "benign") : "—", text_color = color.white, text_size = size.tiny, bgcolor = (enVPIN and toxic) ? color.new(C_WARN, 25) : color.new(C_UP, 60))
    else
        // PRO — expanded context + honest statistics
        table.cell(t, 0, 12, "MOMENTUM", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
        table.cell(t, 1, 12, _momShort + (flipRisk ? "  ⚠ flip" : ""), text_color = color.white, text_size = size.tiny, bgcolor = na(ctrlAccel) ? C_BG : color.new(momCol, 25))
        table.cell(t, 2, 12, na(ctrlAccel) ? "—" : str.tostring(ctrlAccel, "+0.00"), text_color = momCol, text_size = size.tiny, bgcolor = C_BG)
        table.cell(t, 3, 12, "acc " + str.tostring(accLen) + "b", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
        table.cell(t, 4, 12, "", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
        table.cell(t, 5, 12, "", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
        if enDiv
            table.cell(t, 0, 13, "DIVERG", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 1, 13, divTxt, text_color = color.white, text_size = size.tiny, bgcolor = divState == 0 ? C_ALT : color.new(divCol, 25))
            table.cell(t, 2, 13, na(divRate) ? "—" : "hit " + str.tostring(int(math.round(divRate))) + "%", text_color = (na(divRate) ? C_MUTED : divRate >= 50 ? C_UP : C_DN), text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 3, 13, na(divHitCnt) ? "" : "n=" + str.tostring(int(divHitCnt)), text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 4, 13, str.tostring(divLen) + "b", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 5, 13, "", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
        if enVPIN
            table.cell(t, 0, 14, "VPIN", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 1, 14, toxic ? "⚠ toxic" : "benign", text_color = color.white, text_size = size.tiny, bgcolor = toxic ? color.new(C_WARN, 20) : color.new(C_UP, 55))
            table.cell(t, 2, 14, na(vpin) ? "—" : "pct " + str.tostring(int(math.round(vpin))), text_color = C_TEXT, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 3, 14, vpinGate ? "gate" : "measure", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 4, 14, "thr " + str.tostring(vpinThrP), text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 5, 14, (enAmihud and not na(amhPct)) ? "Amh " + str.tostring(int(math.round(amhPct))) : "", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
        if enCalib
            table.cell(t, 0, 15, "TEST", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 1, 15, na(hitRate) ? "—" : "hit " + str.tostring(int(math.round(hitRate))) + "%", text_color = (na(hitRate) ? C_MUTED : hitRate >= 50 ? C_UP : C_DN), text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 2, 15, na(hitLo) ? "" : "LB " + str.tostring(int(math.round(hitLo))) + "%", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 3, 15, na(edgeNull) ? "" : "edge " + str.tostring(edgeNull, "+0") + "%", text_color = (na(edgeNull) ? C_MUTED : edgeNull > 0 ? C_UP : C_DN), text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 4, 15, "n=" + str.tostring(int(hitCnt)), text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 5, 15, na(runsZ) ? "" : "runs " + str.tostring(runsZ, "0.0"), text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
        if enRelCal
            table.cell(t, 0, 16, "CALIB", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 1, 16, "clarity " + str.tostring(calIdxNow + 1) + "/5", text_color = C_TEXT, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 2, 16, na(calLoNow) ? "—" : "LB " + str.tostring(int(math.round(calLoNow))) + "%", text_color = (na(calLoNow) ? C_MUTED : calLoNow >= 50 ? C_UP : C_DN), text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 3, 16, na(calNNow) ? "" : "n=" + str.tostring(int(calNNow)), text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 4, 16, "VSA", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 5, 16, vsaChart, text_color = C_TEXT, text_size = size.tiny, bgcolor = C_BG)
        if enLTF
            table.cell(t, 0, 17, "LTF Δ", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 1, 17, ltfTxt, text_color = color.white, text_size = size.tiny, bgcolor = ltfDir == 0 ? C_ALT : color.new(ltfCol, 25))
            table.cell(t, 2, 17, na(ltfSigned) ? "—" : str.tostring(ltfSigned, "+0.00"), text_color = ltfCol, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 3, 17, na(ltfSigned) ? "" : ltfConfl ? "⚠ confl" : ltfAgree ? "✓ agree" : "•", text_color = ltfConfl ? C_WARN : ltfAgree ? C_UP : C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 4, 17, ltfRes + " sub", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 5, 17, ltfGate ? "gate" : "measure", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
        if enRev
            color _rvBg = lastRevDir == 1 ? color.new(C_UP, 25) : lastRevDir == -1 ? color.new(C_DN, 25) : C_BG
            table.cell(t, 0, 18, "REVERSAL", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 1, 18, lastRevDir == 1 ? "▲ BUY" : lastRevDir == -1 ? "▼ SELL" : "—", text_color = color.white, text_size = size.tiny, bgcolor = _rvBg)
            table.cell(t, 2, 18, na(lastRevStr) ? "str —" : "str " + str.tostring(int(math.round(lastRevStr))), text_color = C_TEXT, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 3, 18, lastRevDir == 0 ? "—" : lastRevPrv ? "✓ proven" : "measuring", text_color = lastRevPrv ? C_UP : C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 4, 18, na(revLo) ? "" : "LB " + str.tostring(int(math.round(revLo))) + "%", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 5, 18, na(revNN) ? "" : "n=" + str.tostring(int(revNN)), text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
        if enSess
            color _ibBg = ibBrk == 1 ? color.new(C_UP, 30) : ibBrk == -1 ? color.new(C_DN, 30) : C_ALT
            table.cell(t, 0, 19, "SESSION", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 1, 19, na(_todRvol) ? "rvol —" : "rvol ×" + str.tostring(_todRvol, "0.0"), text_color = (not na(_todRvol) and _todRvol >= 1.3) ? C_WARN : C_TEXT, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 2, 19, ibBrk == 1 ? "IB ▲ brk" : ibBrk == -1 ? "IB ▼ brk" : "IB in", text_color = color.white, text_size = size.tiny, bgcolor = _ibBg)
            table.cell(t, 3, 19, _inIB ? "open" : "—", text_color = _inIB ? C_UP : C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 4, 19, "slot " + _slotLbl, text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
            table.cell(t, 5, 19, enSessStr ? "str" : "disp", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_ALT)
        if enRS
            color _rsBg = rsLead == 1 ? color.new(C_UP, 30) : rsLead == -1 ? color.new(C_DN, 30) : C_BG
            table.cell(t, 0, 20, "INTERMKT", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 1, 20, rsLead == 1 ? "▲ leading" : rsLead == -1 ? "▼ lagging" : "• flat", text_color = color.white, text_size = size.tiny, bgcolor = _rsBg)
            table.cell(t, 2, 20, na(rsMans) ? "RS —" : "RS " + str.tostring(rsMans, "+0.0"), text_color = (na(rsMans) ? C_MUTED : rsMans >= 0 ? C_UP : C_DN), text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 3, 20, na(rsSlp) ? "" : rsSlp > 0 ? "slp ▲" : rsSlp < 0 ? "slp ▼" : "slp •", text_color = (na(rsSlp) ? C_MUTED : rsSlp > 0 ? C_UP : C_DN), text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 4, 20, "vs " + _rsBenchShort, text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)
            table.cell(t, 5, 20, enRSStr ? "str" : "disp", text_color = C_MUTED, text_size = size.tiny, bgcolor = C_BG)

// ═══════════════════════════════════ EXPORTS (Data Window · generic names) ═════
plot(cChart,    "EXP_ChartControl",  display = display.data_window)
plot(ctrlAccel, "EXP_ControlAccel",  display = display.data_window)
plot(plrState,  "EXP_PathState",     display = display.data_window)
plot(clarity,   "EXP_PathClarity",   display = display.data_window)
plot(pUp,       "EXP_PathProbUp",    display = display.data_window)
plot(zChart,    "EXP_ChartStrength", display = display.data_window)
plot(divState,  "EXP_DivState",      display = display.data_window)
plot(vpin,      "EXP_VPINpct",       display = display.data_window)
plot(ltfSigned, "EXP_LTFDelta",      display = display.data_window)
plot(sigDir == 0 ? na : sigDir, "EXP_SignalDir", display = display.data_window)
plot(sigStrength, "EXP_SignalStrength", display = display.data_window)
plot(amhPct,    "EXP_AmihudPct",     display = display.data_window)
plot(turbPct,   "EXP_TurbulencePct", display = display.data_window)
plot(revDir == 0 ? na : revDir, "EXP_ReversalDir", display = display.data_window)
plot(revStrength, "EXP_ReversalStrength", display = display.data_window)
plot(_todRvol,  "EXP_ToD_RVOL",       display = display.data_window)
plot(ibBrk == 0 ? na : ibBrk, "EXP_IB_Break", display = display.data_window)
plot(rsMans,    "EXP_RS_Mansfield",   display = display.data_window)
plot(rsLead == 0 ? na : rsLead, "EXP_RS_Leadership", display = display.data_window)
plot(enAdaptG ? loGainEff : na, "EXP_AdaptiveGain", display = display.data_window)

// ═══════════════════════════════════ ALERTS (confirmed-bar only) ═══════════════
alertcondition(barstate.isconfirmed and plrState == 1  and plrState[1] != 1,  "Path flips UP",   "Buyer vs Seller: path of least resistance flipped UP")
alertcondition(barstate.isconfirmed and plrState == -1 and plrState[1] != -1, "Path flips DOWN", "Buyer vs Seller: path of least resistance flipped DOWN")
alertcondition(barstate.isconfirmed and plrState == 0  and plrState[1] != 0,  "Path goes CHOP",  "Buyer vs Seller: path of least resistance turned to chop")
alertcondition(flipRiskNew, "Control flip risk", "Buyer vs Seller: your-TF control momentum is turning against the path — flip risk rising")
alertcondition(divBearNew, "Bearish control divergence", "Buyer vs Seller: price higher but control falling — distribution / bearish divergence")
alertcondition(divBullNew, "Bullish control divergence", "Buyer vs Seller: price lower but control rising — accumulation / bullish divergence")
alertcondition(ltfConflNew, "LTF delta conflict", "Buyer vs Seller: the LTF true delta disagrees with the chart control — bar-level read may be misleading")
alertcondition(longTrig,                "BUY signal (any)",     "Buyer vs Seller: BUY continuation signal fired (check strength)")
alertcondition(shortTrig,               "SELL signal (any)",    "Buyer vs Seller: SELL continuation signal fired (check strength)")
alertcondition(longTrig  and sigProven, "BUY signal (proven)",  "Buyer vs Seller: PROVEN BUY continuation — strength grade has a Wilson-floored edge on this symbol")
alertcondition(shortTrig and sigProven, "SELL signal (proven)", "Buyer vs Seller: PROVEN SELL continuation — strength grade has a Wilson-floored edge on this symbol")
alertcondition(revBull,                 "Reversal BUY (any)",   "Buyer vs Seller: bullish REVERSAL setup — accumulation divergence + VSA bottom exhaustion + control flipping up")
alertcondition(revBear,                 "Reversal SELL (any)",  "Buyer vs Seller: bearish REVERSAL setup — distribution divergence + VSA top exhaustion + control flipping down")
alertcondition(revBull and revProven,   "Reversal BUY (proven)","Buyer vs Seller: PROVEN bullish REVERSAL — strength grade has a Wilson-floored edge on this symbol")
alertcondition(revBear and revProven,   "Reversal SELL (proven)","Buyer vs Seller: PROVEN bearish REVERSAL — strength grade has a Wilson-floored edge on this symbol")
alertcondition(ibBreakUpNew, "Initial Balance break UP",   "Buyer vs Seller: price broke ABOVE the opening-range (Initial Balance) high")
alertcondition(ibBreakDnNew, "Initial Balance break DOWN", "Buyer vs Seller: price broke BELOW the opening-range (Initial Balance) low")
alertcondition(rsLeadFlipUp, "RS turns leading", "Buyer vs Seller: the symbol turned LEADING its benchmark (Mansfield RS crossed above 0)")
alertcondition(rsLeadFlipDn, "RS turns lagging", "Buyer vs Seller: the symbol turned LAGGING its benchmark (Mansfield RS crossed below 0)")
````
