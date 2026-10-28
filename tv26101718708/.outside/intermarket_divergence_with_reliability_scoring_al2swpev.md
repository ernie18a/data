# Intermarket Divergence with Reliability Scoring

- url: https://www.tradingview.com/script/Al2SWpEv-Intermarket-Divergence-with-Reliability-Scoring/
- type: indicator
- pine_id: PUB;10265a2af00e4f218c84653b109e48cf
- version: 7.0

## Description

Intermarket Divergence with Reliability Scoring

Related markets tend to move together. When your chart pushes to a new high but a market that usually tracks it does not confirm, that non-confirmation can precede a turn. This script measures divergence between your chart and a chosen leader market — but only when the leader is actually correlated to price, because a decoupled market's "divergence" is meaningless — and then scores, in real time, whether those divergences have been worth trading on your symbol.

WHAT IT PLOTS

A normalised oscillator built from a chosen leader market, its stretch bands, divergence markers and connecting pivot lines, plus a plain-language verdict panel. By default the chart stays minimal — the oscillator and the verdict panel — with optional key-info and per-class tables you can switch on in settings.

WHY THESE COMPONENTS ARE COMBINED, AND HOW THEY WORK TOGETHER

Three classical pieces are fused into one pipeline, not stacked as independent signals:

A z-scored leader series — optionally inverted, optionally lead-lag shifted — the cross-market line your price is compared against.
A live correlation gate — the leader only votes when its trailing correlation to price clears a threshold, so non-confirmations from a decoupled market are ignored.
A binomial-proportion confidence test — asks, for each divergence class, whether the expected move followed more often than a same-zone baseline would deliver.

Part 1 builds the comparison, part 2 keeps only the meaningful divergences, part 3 decides whether the survivors have actually paid on this instrument, by direction. The parts are interdependent — remove any one and the script can no longer answer its core question: is this intermarket divergence worth trading here, and which way?

HOW TO READ IT

The verdict panel translates the statistics into four states:

GREEN, edge confirmed: these divergences have beaten a same-spot baseline here. Worth acting on.
RED, no edge here: they have lost to a coin-flip. Skip them, pick a leader that genuinely leads, or change the timeframe.
AMBER, unproven: edge not statistically established yet; treat as low-confidence.
GREY, learning: still collecting completed samples.

It also shows:

Best signal — names a direction only once that direction is individually proven (its edge lower-bound clears zero). Otherwise it says "none confirmed", so you are never lured by a single noisy number.
Leader link — how tightly the leader currently tracks price (strong, moderate or weak). A weak link means the leader has decoupled and its divergences are unreliable.
Reward : risk — the average best move versus the average worst move after a signal, in ATR. Below 1:1 means signals have hurt more than they helped.
Market regime — reverting markets suit divergence; strong trends punish it.

A divergence is simply price making a higher high or lower low while the leader line does the opposite, counted only when the leader is correlated enough to matter.

CHOOSING A LEADER

Pick a market that genuinely leads — a currency, a global risk proxy, a sector index — not one that merely co-moves with your chart. The lead-lag offset lets you test whether it leads. A co-moving index will usually show no edge, which the panel will tell you plainly.

WHAT IS ORIGINAL

Standard intermarket tools just overlay two symbols. This one fuses a live correlation gate into the divergence filter, then keeps a self-updating, confidence-scored, per-class track record against a same-zone baseline — so you see not just that a non-confirmation printed, but whether and how it has paid, and you only trust a direction once it is statistically proven.

UNIVERSAL ACROSS MARKETS

Reads the chart's own price (the source is configurable in settings) plus one leader symbol. Defaults target NIFTY futures with Bank Nifty as the leader. Change the leader to USD/INR (inverse), a sector or overseas index, or any related market for other instruments, in any market.

OUTPUTS FOR OTHER SCRIPTS

Generic EXP_ values — oscillator, signal, probability, edge, edge lower-bound, sample count, regime, leader value and leader correlation — are published to the Data Window so other indicators can read them via input.source().

CONCEPT CREDITS

Average true range — J. W. Wilder. Binomial score confidence interval — E. B. Wilson. Trend-efficiency regime measure — P. Kaufman. Intermarket analysis and divergence — classical technical analysis.

DISCLAIMER

For research and education only. This is not financial advice, not a recommendation to buy or sell, and not a guarantee of future results. All performance shown is in-sample and past-only. Markets carry risk — do your own research and manage your own risk.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════════════════════
//  © Market_Logic_India                                                        INVITE-ONLY · v1.4
//  INTERMARKET DIVERGENCE WITH RELIABILITY SCORING
// ----------------------------------------------------------------------------------------------
//  v1.4 (R2 · multiple-comparison DEFLATION) — the one honest-stats gap left in v1.3 is closed.
//    The reliability test judges FOUR divergence classes and then reports the BEST one; testing
//    many things and keeping the winner inflates false "edges" (the classic multiple-comparisons /
//    data-snooping trap). The Wilson confidence half-width is now widened by (1 + 0.25·ln(trials))
//    before the edge lower-bound and the "best signal" floor are judged, so a class reads CONFIRMED
//    only if it clears the HARDER bar. Default ON ("Deflate for multiple comparisons"); turn it off
//    to reproduce v1.3 exactly. Engine, divergence detection, correlation gate, zones and the OOS
//    walk-forward are UNCHANGED. The on-price (overlay) signals are restyled as clean map-pin tags
//    (a "B" pin below the bar for bullish, an "S" pin above for bearish), confirmed pins drawn at
//    the chosen size and not-yet-proven pins one size smaller. Published invite-only (closed
//    source); reliability stats stay backed by the published calibration libraries, version-pinned.
//  v1.3 (R1 · honest-stats standardization): the reliability scoring is now backed by the published
//    calibration libraries — robust-z via ml_robuststats/2 (byte-identical, so the oscillator/signals
//    are UNCHANGED), Wilson confidence half-width + hit-rate via ml_calib/2 — and a NEW optional
//    time-of-day significance gate via ml_session/2 (group 05, default OFF). Imports are pinned to the
//    exact published v2 versions. Same calibration engine now shared across the divergence family.
//  v1.2 — Three additive layers, all optional and reversible; the leader engine, the correlation
//    gate, the divergence detection and the existing scoring are otherwise unchanged:
//    • Robust MAD z-score + Ehlers UltimateSmoother (default ON), via "Z-score mode" / "Output
//      smoother"; set "Classic (mean/stdev)" / "EMA" for the original v1.1 output.
//    • 3-window extreme-consensus normalization ("Extreme normalization", default off) — z as the
//      MEDIAN of the z at half/one/double the window, extreme only when short/medium/long agree.
//    • Walk-forward OUT-OF-SAMPLE reliability — the first N resolved signals train, every one after
//      is scored out-of-sample, shown on a new "OOS edge (walk-fwd)" panel row and exported as
//      EXP_OOSEdge (the trustworthy read).
//    Also pins max_bars_back = 5000 (this script requests external data) so the robust median/MAD
//    window's history is reserved up front. No divergence-detection logic changed.
// ----------------------------------------------------------------------------------------------
//  v1.1 — Correctness pass:
//         • Hoisted the same-zone baseline ta.sma calls out of a ternary branch so they run on
//           every bar (Pine requirement for series functions; clears CW10004 and fixes a baseline
//           that could drift because the averages were skipped on bars where the guard was false).
//         • Added optional on-price (overlay) signal markers. The engine, the EXP_* export bus, the
//           cost-aware reliability scoring (costs subtracted ×ATR) and the adaptive theme are unchanged.
// ----------------------------------------------------------------------------------------------
//  WHAT IT PLOTS
//    A normalised oscillator built from a chosen LEADER market, its stretch bands and divergence
//    markers, plus a plain-language panel that scores — in real time — whether divergences between
//    your chart and that leader have actually been worth acting on, and which direction is proven.
//
//  THE IDEA
//    Related markets tend to move together. When your chart pushes to a new high but a market that
//    usually tracks it does not confirm (a lower high), that non-confirmation can precede a turn.
//    The script measures divergence between your chart and a configurable leader — but only counts
//    it when the leader is actually correlated to price right now, because a decoupled market's
//    "divergence" is meaningless.
//
//  WHY THESE PARTS ARE COMBINED (mashup rationale)
//    Three components form ONE pipeline, not three separate signals:
//      1. A z-scored leader series (optionally inverted, optionally lead-lag shifted) → the
//         cross-market line your price is compared against.
//      2. A live correlation gate → the leader only votes when its trailing correlation to price
//         clears a threshold, so non-confirmations from a decoupled market are ignored.
//      3. A binomial-proportion confidence test → whether each class of gated divergence has
//         preceded a favourable move more often than a same-zone baseline.
//    Part 1 builds the comparison, part 2 keeps only the divergences that are meaningful, part 3
//    decides whether the survivors have actually paid on THIS instrument, by direction. Remove any
//    one and the script can no longer answer "is this intermarket divergence worth trading here?"
//
//  HOW TO USE
//    • Read the verdict panel first. GREEN = these divergences have beaten a same-spot baseline
//      here; RED = they've lost to it (skip / pick a better leader / change timeframe); AMBER =
//      not established yet; GREY = still gathering data.
//    • "Best signal" only names a direction once that direction is individually proven (its edge
//      lower-bound clears zero); otherwise it says "none confirmed". "Leader link" shows how tightly
//      the leader currently tracks price. "Reward : risk" is the average best vs worst move, in ATR.
//    • Pick a leader that genuinely LEADS (a currency, a global risk proxy, a sector index), not a
//      market that merely co-moves — the lead-lag offset lets you test whether it leads.
//
//  ORIGINALITY
//    Standard intermarket tools just overlay two symbols. This one fuses a live correlation gate
//    into the divergence filter and then keeps a self-updating, confidence-scored, per-class track
//    record against a same-zone baseline — so you see not just that a non-confirmation printed, but
//    whether and how it has paid, and only trust a direction once it is statistically proven.
//
//  DATA / UNIVERSALITY
//    Reads the chart's own price (configurable source) plus one leader symbol, both set in inputs.
//    Defaults target NIFTY futures with Bank Nifty as the leader. Change the leader to USD/INR
//    (inverse), a sector or overseas index, or any related market for other instruments / markets.
//
//  OUTPUTS FOR OTHER SCRIPTS
//    Generic EXP_* plots (oscillator, signal, probability, edge, edge lower-bound, sample count,
//    regime, leader value, leader correlation) are published to the Data Window for use via
//    input.source().
//
//  CONCEPT CREDITS
//    Average true range — J. W. Wilder. Binomial score confidence interval — E. B. Wilson. Trend-
//    efficiency regime measure — P. Kaufman. Robust median / MAD standardization — classical robust
//    statistics (F. Hampel). Low-lag smoothing — J. Ehlers (UltimateSmoother). Multiple-comparison /
//    data-snooping deflation — spirit of H. White's Reality Check and M. López de Prado's deflated
//    performance metrics. Intermarket analysis and divergence — classical technical analysis.
//    (Named for attribution; the UI uses generic terms only.)
//
//  NON-REPAINT / DISCLAIMER
//    For research and education only. NOT financial advice, NOT a recommendation, and NOT a
//    guarantee of future results, with NO performance promise. Divergences settle on confirmed
//    pivots (a few bars after the pivot) and do not repaint thereafter; the leader is read with
//    lookahead OFF; the live, unclosed bar is provisional. Track-record figures accumulate over
//    time — the OUT-OF-SAMPLE (walk-forward) edge is the trustworthy read, and it uses overlapping
//    windows, so treat it as guidance, not proof. Markets carry risk; do your own research and
//    manage your own risk.
// ════════════════════════════════════════════════════════════════════════════════════════════
indicator("Intermarket Divergence with Reliability Scoring", "Intermkt", overlay = false, max_labels_count = 500, max_lines_count = 300, max_bars_back = 5000, dynamic_requests = true)

// R1 · honest-stats standardization — reliability scoring backed by the published calibration libraries
// (one engine across the divergence family). Robust-z is byte-identical to the prior local f_robZ, so the
// oscillator/signals are unchanged; only the stats plumbing + an optional time-of-day gate are new. Pinned
// to the exact published v2 versions so a later library update can't silently change this script.
import Market_Logic_India/ml_calib/2        as calib
import Market_Logic_India/ml_robuststats/2  as rstat
import Market_Logic_India/ml_session/2      as sess

// ════ 01 · DATA SOURCE ═════════════════════════════════════════════════════════
g1 = "01 · Data Source"
srcPrice = input.source(close, "Price source", group = g1, display = display.none, tooltip = "The chart price that the leader is diverged against. Defaults to close; runs on any symbol or timeframe.")
cmpSym   = input.symbol("NSE:BANKNIFTY", "Leader symbol", group = g1, display = display.none, tooltip = "The related market to compare against. Default Bank Nifty (for NIFTY). Change to USD/INR, a sector index, an overseas index, etc. for other instruments. Pick a market that genuinely leads, not one that just co-moves.")
invLead  = input.bool(false, "Leader is inverse (e.g. USD/INR)", group = g1, display = display.none, tooltip = "Flip the leader when it normally moves OPPOSITE to price (a stronger currency usually means a weaker index).")

// ════ 02 · LEADER RELATIONSHIP ═════════════════════════════════════════════════
g2 = "02 · Leader Relationship"
leadLag  = input.int(0, "Lead-lag offset (bars leader leads)", minval = 0, maxval = 50, group = g2, display = display.none, tooltip = "Shift the leader forward N bars to test whether it genuinely leads price rather than moving in lockstep.")
corrGate = input.bool(true, "Correlation gate", group = g2, display = display.none, tooltip = "Only let the leader vote when its trailing correlation to price is strong enough. A decoupled leader is silenced.")
corrLen  = input.int(50, "Correlation window", minval = 5, group = g2, display = display.none)
corrMin  = input.float(0.3, "Min |correlation| to vote", minval = 0.0, maxval = 1.0, step = 0.05, group = g2, display = display.none)

// ════ 03 · DIVERGENCE ENGINE ═══════════════════════════════════════════════════
g3 = "03 · Divergence Engine"
divLb     = input.int(5, "Pivot length", minval = 2, group = g3, display = display.none)
maxGap    = input.int(60, "Max bars between pivots", minval = 5, group = g3, display = display.none)
magThr    = input.float(0.3, "Min leader gap (×σ)", minval = 0.0, step = 0.05, group = g3, display = display.none)
showHidden= input.bool(true, "Include hidden divergence", group = g3, display = display.none)
pivotsReq = input.int(2, "Pivots required (2 = standard, 3 = triple)", minval = 2, maxval = 3, group = g3, display = display.none, tooltip = "3 = triple divergence: rarer, stronger — the disagreement must hold across three pivots.")
recentBars= input.int(5, "Treat a signal as 'live' for N bars", minval = 1, group = g3, display = display.none)

// ════ 04 · ZONES & NORMALIZATION ═══════════════════════════════════════════════
g4 = "04 · Zones & Normalization"
normLen   = input.int(100, "Z-Score window", minval = 20, group = g4, display = display.none, tooltip = "Standardises the leader so bands and zones mean the same on every asset.")
smoothLen = input.int(2, "Output smoothing", minval = 1, group = g4, display = display.none)
zMode     = input.string("Robust (MAD)", "Z-score mode", options = ["Robust (MAD)","Classic (mean/stdev)"], group = g4, display = display.none, tooltip = "Robust (MAD) standardizes with median / median-absolute-deviation (×1.4826), so outlier bars don't distort the σ bands. Classic reproduces the original.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = g4, tooltip = "Single window = the one Normalization window above (original). 3-window consensus = z is the MEDIAN of the z at half, one and double that window, so a reading is extreme only when short, medium and long agree. Default Single so nothing changes unless you opt in.")
smootherType = input.string("UltimateSmoother (Wave A)", "Output smoother", options = ["UltimateSmoother (Wave A)","EMA"], group = g4, display = display.none, tooltip = "Applies when smoothing > 1. UltimateSmoother (Ehlers) is lag-minimal; EMA reproduces the original.")
obSigma   = input.float(1.5, "Stretch band (σ)", minval = 0.5, step = 0.1, group = g4, display = display.none)
extSigma  = input.float(2.5, "Extreme band (σ)", minval = 0.5, step = 0.1, group = g4, display = display.none)

// ════ 05 · RELIABILITY SCORING & REGIME ════════════════════════════════════════
g5 = "05 · Reliability Scoring & Regime"
calcCal  = input.bool(true, "Measure track record", group = g5, display = display.none)
calH     = input.int(10, "Look-ahead (bars)", minval = 1, group = g5, display = display.none, tooltip = "How long after a signal we check whether the favourable move happened.")
calK     = input.float(1.0, "Favourable move (×ATR)", minval = 0.1, step = 0.1, group = g5, display = display.none)
costK    = input.float(0.0, "Costs subtracted (×ATR)", minval = 0.0, step = 0.05, group = g5, display = display.none, tooltip = "Raises the bar a signal must clear, so the score is NET of costs / slippage.")
calWin   = input.int(500, "Baseline window", minval = 50, group = g5, display = display.none)
minN     = input.int(20, "Minimum samples before judging", minval = 1, group = g5, display = display.none)
useDeflate = input.bool(true, "Deflate for multiple comparisons (R2)", group = g5, display = display.none, tooltip = "Widens the confidence bar to correct for judging four divergence classes and then reporting the BEST one — the multiple-comparisons / data-snooping trap. The Wilson half-width is scaled by (1 + 0.25·ln(trials)), so a class reads CONFIRMED only if it clears the harder bar. Off reproduces v1.3 exactly.")
wfTrainN = input.int(30, "In-sample signals before out-of-sample (walk-forward)", minval = 5, group = g5, display = display.none, tooltip = "Wave E honesty: the first N resolved signals TRAIN (in-sample); every one after is scored OUT-OF-SAMPLE. The OOS edge is the trustworthy one.")
regimeMode = input.string("Off", "Only count signals in regime", options = ["Off", "Favor reverting", "Favor trending"], group = g5, display = display.none, tooltip = "Optional filter. Reverting markets suit divergence; strong trends punish it.")
erLen    = input.int(20, "Regime window", minval = 3, group = g5, display = display.none)
erThr    = input.float(0.35, "Regime threshold", minval = 0.05, maxval = 0.95, step = 0.05, group = g5, display = display.none)
todOn    = input.bool(false, "Time-of-day significance gate (R1)", group = g5, display = display.none, tooltip = "When ON, a divergence only counts / marks if its intraday time-slot is statistically significant (ml_session.slotSignificant, |slot-z| ≥ threshold) — filters the dead hours. Off by default so nothing changes unless you opt in.")
todSlotM = input.int(30, "ToD slot size (min)", minval = 5, maxval = 120, group = g5, display = display.none)
todZ     = input.float(1.0, "ToD significance |z|", minval = 0.0, maxval = 4.0, step = 0.1, group = g5, display = display.none)

// ════ 06 · VISUALS & TABLES ════════════════════════════════════════════════════
g6 = "06 · Visuals & Tables"
themeOpt   = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = g6, display = display.none, tooltip = "Auto reads the chart background and adapts table colours for contrast.")
showVerdict= input.bool(true, "Show verdict panel", group = g6, display = display.none)
showKey    = input.bool(false, "Show key-info table", group = g6, display = display.none)
showGrid   = input.bool(false, "Show per-class table", group = g6, display = display.none)
showLines  = input.bool(true, "Draw connecting pivot lines", group = g6, display = display.none)
lineWidth  = input.int(2, "Divergence line width", minval = 1, maxval = 5, group = g6, display = display.none, tooltip = "Thickness of the pivot-to-pivot divergence lines.")
showTint   = input.bool(true, "Tint extreme zones", group = g6, display = display.none)
showSigOv  = input.bool(true, "Signals on price chart (overlay)", group = g6, display = display.none, tooltip = "Also mark each divergence on the main price chart, not just this pane: a map-pin tag with the buy/sell letter inside — a green pin below the bar for bullish, a red pin above for bearish. Confirmed-edge signals print at the chosen size; not-yet-proven ones print one size smaller.")
buyTag     = input.string("B", "Buy pin text", group = g6, display = display.none)
sellTag    = input.string("S", "Sell pin text", group = g6, display = display.none)
sigSize    = input.string("Small", "Pin size", options = ["Small","Normal","Large","Huge"], group = g6, display = display.none)
showId     = input.bool(true, "Show name tag", group = g6, display = display.none)
showEXP    = input.bool(true, "Publish EXP_* outputs", group = g6, display = display.none)
bullCol    = input.color(#17c784, "Bullish", group = g6, display = display.none)
bearCol    = input.color(#ff4d5e, "Bearish", group = g6, display = display.none)
midColr    = input.color(#f7b500, "Caution", group = g6, display = display.none)

// ─── HELPERS (pure: arguments + built-ins only) ───────────────────────────────
f_z(float v, float m, float s) => s > 0 ? (v - m) / s : 0.0
// robust z is now rstat.robZ (byte-identical formula: median / MAD ×1.4826) — see the R1 imports above.
// Ehlers UltimateSmoother (Wave A) — lag-minimal; no ta.* inside, safe under a selector.
ml_ultimateSmoother(series float src, simple int period) =>
    float q  = math.exp(-1.414 * math.pi / period)
    float c1 = 2.0 * q * math.cos(1.414 * math.pi / period)
    float c2 = q * q
    float a0 = (1.0 + c1 + c2) / 4.0
    float us = src
    if bar_index >= 4
        us := (1.0 - a0) * src + (2.0 * a0 - c1) * nz(src[1]) + (c2 - a0) * nz(src[2]) + c1 * nz(us[1]) - c2 * nz(us[2])
    us
// f_ci → calib.wilsonHalf (Wilson interval half-width %, byte-identical) and f_hit → calib.hitRate —
// see the R1 imports above. calib.wilsonHalf already returns a PERCENT, so the ×100 is dropped at the call sites.
f_luma(color c) => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_sz(string s) => s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Huge" ? size.huge : size.large

// ─── ENGINE ───────────────────────────────────────────────────────────────────
atr = ta.atr(14)
float lRaw = request.security(cmpSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool  leaderOK = not na(lRaw)
float lLag = leadLag > 0 ? lRaw[leadLag] : lRaw
float cmpRaw = (invLead ? -1.0 : 1.0) * nz(lLag, close)
float corrPx = ta.correlation(srcPrice, cmpRaw, corrLen)
bool corrOK = not corrGate or (not na(corrPx) and math.abs(corrPx) >= corrMin)
// Wave A: compute both z-scores + both smoothers unconditionally (Pine v6: ta.* must not sit in a branch), then select
// U8 (Wave D): z at three windows (unconditional), select by mode, optional median consensus.
int   _wS = math.max(5, int(normLen / 2))
int   _wL = int(normLen * 2)
float _zcS = f_z(cmpRaw, ta.sma(cmpRaw, _wS), ta.stdev(cmpRaw, _wS)), _zcM = f_z(cmpRaw, ta.sma(cmpRaw, normLen), ta.stdev(cmpRaw, normLen)), _zcL = f_z(cmpRaw, ta.sma(cmpRaw, _wL), ta.stdev(cmpRaw, _wL))
float _zrS = rstat.robZ(cmpRaw, _wS), _zrM = rstat.robZ(cmpRaw, normLen), _zrL = rstat.robZ(cmpRaw, _wL)
bool  _uCl = zMode == "Classic (mean/stdev)"
float _zS = _uCl ? _zcS : _zrS
float _zM = _uCl ? _zcM : _zrM
float _zL = _uCl ? _zcL : _zrL
float _zMed = _zS + _zM + _zL - math.min(_zS, math.min(_zM, _zL)) - math.max(_zS, math.max(_zM, _zL))
float cmpZ = zWinMode == "Single window" ? _zM : _zMed
float cmpEma   = ta.ema(cmpZ, smoothLen)
float cmpUlt   = ml_ultimateSmoother(cmpZ, math.max(smoothLen, 2))
float cmp = smoothLen > 1 ? (smootherType == "EMA" ? cmpEma : cmpUlt) : cmpZ
float cmpStd = ta.stdev(cmp, normLen)

// internal regime (trend-efficiency ratio)
float erNum = math.abs(srcPrice - srcPrice[erLen])
float erDen = math.sum(math.abs(srcPrice - srcPrice[1]), erLen)
float erVal = erDen > 0 ? erNum / erDen : na
bool  trending = not na(erVal) and erVal >= erThr
bool  regimeOK = regimeMode == "Off" ? true : regimeMode == "Favor reverting" ? (na(erVal) ? true : erVal < erThr) : (na(erVal) ? true : erVal >= erThr)
int   regimeCode = na(erVal) ? 0 : trending ? 1 : -1
// R1 time-of-day significance gate — a divergence counts / marks only in a statistically live slot.
int   todSlot = sess.slotOf(todSlotM)
int   todNs   = sess.slotCount(todSlotM)
bool  todOK   = (not todOn) or sess.slotSignificant(srcPrice - nz(srcPrice[1], srcPrice), todSlot, todNs, 0.10, todZ)

// ─── DIVERGENCE DETECTION (confirmed pivots, regular + hidden, 2- or 3-pivot) ──
ph = ta.pivothigh(cmp, divLb, divLb)
pl = ta.pivotlow(cmp, divLb, divLb)
var float pOscH = na
var float pOscL = na
var float pPrcH = na
var float pPrcL = na
var float pOscH2 = na
var float pOscL2 = na
var float pPrcH2 = na
var float pPrcL2 = na
var int   pBarH = na
var int   pBarL = na
bool bullDiv = false
bool bearDiv = false
bool hBull = false
bool hBear = false
if not na(pl)
    float pr = srcPrice[divLb]
    int curBar = bar_index - divLb
    bool gap2 = not na(pOscL) and (curBar - pBarL) <= maxGap and math.abs(pl - pOscL) >= magThr * nz(cmpStd)
    bool reg2 = gap2 and pl > pOscL and pr < pPrcL
    bool hid2 = gap2 and showHidden and pl < pOscL and pr > pPrcL
    bullDiv := pivotsReq == 3 ? (reg2 and not na(pOscL2) and pOscL > pOscL2 and pPrcL < pPrcL2) : reg2
    hBull   := pivotsReq == 3 ? (hid2 and not na(pOscL2) and pOscL < pOscL2 and pPrcL > pPrcL2) : hid2
    if showLines and (bullDiv or hBull)
        line.new(pBarL, pOscL, curBar, pl, xloc = xloc.bar_index, color = bullDiv ? color.new(bullCol, 0) : color.new(bullCol, 40), style = hBull ? line.style_dashed : line.style_solid, width = lineWidth)
    pOscL2 := pOscL
    pPrcL2 := pPrcL
    pOscL := pl
    pPrcL := pr
    pBarL := curBar
if not na(ph)
    float pr = srcPrice[divLb]
    int curBar = bar_index - divLb
    bool gap2 = not na(pOscH) and (curBar - pBarH) <= maxGap and math.abs(ph - pOscH) >= magThr * nz(cmpStd)
    bool reg2 = gap2 and ph < pOscH and pr > pPrcH
    bool hid2 = gap2 and showHidden and ph > pOscH and pr < pPrcH
    bearDiv := pivotsReq == 3 ? (reg2 and not na(pOscH2) and pOscH < pOscH2 and pPrcH > pPrcH2) : reg2
    hBear   := pivotsReq == 3 ? (hid2 and not na(pOscH2) and pOscH > pOscH2 and pPrcH < pPrcH2) : hid2
    if showLines and (bearDiv or hBear)
        line.new(pBarH, pOscH, curBar, ph, xloc = xloc.bar_index, color = bearDiv ? color.new(bearCol, 0) : color.new(bearCol, 40), style = hBear ? line.style_dashed : line.style_solid, width = lineWidth)
    pOscH2 := pOscH
    pPrcH2 := pPrcH
    pOscH := ph
    pPrcH := pr
    pBarH := curBar
bullDiv := bullDiv and corrOK and todOK
bearDiv := bearDiv and corrOK and todOK
hBull := hBull and corrOK and todOK
hBear := hBear and corrOK and todOK
bool longSig  = bullDiv or hBull
bool shortSig = bearDiv or hBear

// recency of last signal (any class)
var int lastDir = 0
var int lastBarSig = na
if bullDiv or hBull
    lastDir := 1
    lastBarSig := bar_index
if bearDiv or hBear
    lastDir := -1
    lastBarSig := bar_index
int barsSince = na(lastBarSig) ? na : bar_index - lastBarSig
bool live = not na(barsSince) and barsSince <= recentBars

// ─── ZONE-CONDITIONAL BASELINE ────────────────────────────────────────────────
bool upEvt  = srcPrice >= srcPrice[calH] + (calK + costK) * atr[calH]
bool dnEvt  = srcPrice <= srcPrice[calH] - (calK + costK) * atr[calH]
bool wasOS  = cmp[calH] <= -obSigma
bool wasOB  = cmp[calH] >=  obSigma
float upHit = wasOS and upEvt ? 1.0 : 0.0
float upTot = wasOS ? 1.0 : 0.0
float dnHit = wasOB and dnEvt ? 1.0 : 0.0
float dnTot = wasOB ? 1.0 : 0.0
// ta.sma must run every bar — hoisted out of the ternary so the rolling averages never skip a bar.
float smaUpHit = ta.sma(upHit, calWin)
float smaUpTot = ta.sma(upTot, calWin)
float smaDnHit = ta.sma(dnHit, calWin)
float smaDnTot = ta.sma(dnTot, calWin)
float baseUp = smaUpTot > 0 ? smaUpHit / smaUpTot * 100.0 : na
float baseDn = smaDnTot > 0 ? smaDnHit / smaDnTot * 100.0 : na

// ─── TRACK-RECORD HARNESS (1 Bull · 2 Bear · 3 Hidden-Bull · 4 Hidden-Bear) ───
var int[]   cBar = array.new_int()
var int[]   cCls = array.new_int()
var int[]   cDir = array.new_int()
var int[]   cGat = array.new_int()
var float[] cEnt = array.new_float()
var float[] cAtr = array.new_float()
var float[] cBase= array.new_float()
var float[] cMfe = array.new_float()
var float[] cMae = array.new_float()
var float[] kW  = array.new_float(5, 0.0)
var float[] kN  = array.new_float(5, 0.0)
var float[] kBs = array.new_float(5, 0.0)
var float[] kBn = array.new_float(5, 0.0)
var float[] kFe = array.new_float(5, 0.0)
var float[] kAe = array.new_float(5, 0.0)
// Wave E — walk-forward out-of-sample split (trustworthy reliability, additive)
var int   wfResolved = 0
var float wfIsW = 0.0, var float wfIsN = 0.0
var float wfOosW = 0.0, var float wfOosN = 0.0
var int gW = 0
var int gN = 0
var float gBs = 0.0
var int gBn = 0
var int rgW = 0
var int rgN = 0
if calcCal and bullDiv
    cBar.push(bar_index)
    cCls.push(1)
    cDir.push(1)
    cGat.push(regimeOK ? 1 : 0)
    cEnt.push(srcPrice)
    cAtr.push(atr)
    cBase.push(baseUp)
    cMfe.push(0.0)
    cMae.push(0.0)
if calcCal and bearDiv
    cBar.push(bar_index)
    cCls.push(2)
    cDir.push(-1)
    cGat.push(regimeOK ? 1 : 0)
    cEnt.push(srcPrice)
    cAtr.push(atr)
    cBase.push(baseDn)
    cMfe.push(0.0)
    cMae.push(0.0)
if calcCal and hBull
    cBar.push(bar_index)
    cCls.push(3)
    cDir.push(1)
    cGat.push(regimeOK ? 1 : 0)
    cEnt.push(srcPrice)
    cAtr.push(atr)
    cBase.push(baseUp)
    cMfe.push(0.0)
    cMae.push(0.0)
if calcCal and hBear
    cBar.push(bar_index)
    cCls.push(4)
    cDir.push(-1)
    cGat.push(regimeOK ? 1 : 0)
    cEnt.push(srcPrice)
    cAtr.push(atr)
    cBase.push(baseDn)
    cMfe.push(0.0)
    cMae.push(0.0)
if cBar.size() > 0
    for i = cBar.size() - 1 to 0
        int dir = cDir.get(i)
        float cur = dir == 1 ? srcPrice - cEnt.get(i) : cEnt.get(i) - srcPrice
        if cur > cMfe.get(i)
            cMfe.set(i, cur)
        if cur < cMae.get(i)
            cMae.set(i, cur)
        if bar_index - cBar.get(i) >= calH
            int cls = cCls.get(i)
            float a = cAtr.get(i)
            bool win = cur >= (calK + costK) * a
            kN.set(cls, kN.get(cls) + 1.0)
            if win
                kW.set(cls, kW.get(cls) + 1.0)
            wfResolved += 1
            if wfResolved <= wfTrainN
                wfIsN += 1.0
                wfIsW := wfIsW + (win ? 1.0 : 0.0)
            else
                wfOosN += 1.0
                wfOosW := wfOosW + (win ? 1.0 : 0.0)
            float b = cBase.get(i)
            if not na(b)
                kBs.set(cls, kBs.get(cls) + b)
                kBn.set(cls, kBn.get(cls) + 1.0)
            if a > 0
                kFe.set(cls, kFe.get(cls) + cMfe.get(i) / a)
                kAe.set(cls, kAe.get(cls) + cMae.get(i) / a)
            rgN += 1
            if win
                rgW += 1
            if cGat.get(i) == 1
                gN += 1
                if win
                    gW += 1
                if not na(b)
                    gBs += b
                    gBn += 1
            cBar.remove(i)
            cCls.remove(i)
            cDir.remove(i)
            cGat.remove(i)
            cEnt.remove(i)
            cAtr.remove(i)
            cBase.remove(i)
            cMfe.remove(i)
            cMae.remove(i)

float totW = kW.get(1) + kW.get(2) + kW.get(3) + kW.get(4)
float totN = kN.get(1) + kN.get(2) + kN.get(3) + kN.get(4)
float totBs= kBs.get(1) + kBs.get(2) + kBs.get(3) + kBs.get(4)
float totBn= kBn.get(1) + kBn.get(2) + kBn.get(3) + kBn.get(4)
float totFe= kFe.get(1) + kFe.get(2) + kFe.get(3) + kFe.get(4)
float totAe= kAe.get(1) + kAe.get(2) + kAe.get(3) + kAe.get(4)
// R2 · multiple-comparison deflation — widen the confidence bar for testing 4 classes + best-of-4.
int   defTrials  = (kN.get(1) >= minN ? 1 : 0) + (kN.get(2) >= minN ? 1 : 0) + (kN.get(3) >= minN ? 1 : 0) + (kN.get(4) >= minN ? 1 : 0)
float defFactor  = useDeflate ? (1.0 + 0.25 * math.log(math.max(1.0, float(defTrials)))) : 1.0  // widen the Wilson half-width; wilsonHalf's z must stay a simple 1.96, so scale its result instead
float hitPct  = calib.hitRate(totW, totN)
float basePct = totBn > 0 ? totBs / totBn : na
// Wave E — out-of-sample walk-forward reliability (trustworthy read)
float wfOosHit  = wfOosN > 0 ? wfOosW / wfOosN * 100.0 : na
float wfOosEdge = (not na(wfOosHit) and not na(basePct)) ? wfOosHit - basePct : na
float edge    = not na(hitPct) and not na(basePct) ? hitPct - basePct : na
float ciPct   = calib.wilsonHalf(totW, totN, 1.96) * defFactor
bool  enoughN = totN >= minN
bool  sigStar = enoughN and not na(ciPct) and not na(edge) and (edge - ciPct) > 0
float edgeLB  = not na(hitPct) and not na(ciPct) and not na(basePct) ? (hitPct - ciPct) - basePct : na
float mfeAll  = totN > 0 ? totFe / totN : na
float maeAll  = totN > 0 ? totAe / totN : na
float rr      = (not na(mfeAll) and not na(maeAll) and maeAll < 0) ? mfeAll / (-maeAll) : na

// best-performing class — selected and confirmed by its edge LOWER BOUND (honest attribution)
float bestFloor = na
int   bestC = 0
float bestPoint = na
for c = 1 to 4
    float n = kN.get(c)
    float w = kW.get(c)
    float h = calib.hitRate(w, n)
    float bb = kBn.get(c) > 0 ? kBs.get(c) / kBn.get(c) : na
    float e = not na(h) and not na(bb) ? h - bb : na
    float cc = calib.wilsonHalf(w, n, 1.96) * defFactor
    float lb = not na(e) and not na(cc) ? e - cc : na
    if n >= minN and not na(lb) and (na(bestFloor) or lb > bestFloor)
        bestFloor := lb
        bestC := c
        bestPoint := e
bool bestConfirmed = not na(bestFloor) and bestFloor > 0
string bestName = bestConfirmed ? (bestC == 1 ? "Bullish" : bestC == 2 ? "Bearish" : bestC == 3 ? "Bullish (hidden)" : "Bearish (hidden)") : "—"

// ─── VERDICT (plain language) ─────────────────────────────────────────────────
// tier: 0 learning · 1 no edge · 2 unproven · 3 confirmed
int tier = not enoughN ? 0 : (not na(edgeLB) and edgeLB > 0) ? 3 : (not na(edge) and edge < 0) ? 1 : 2
string verdict  = tier == 3 ? "✓ EDGE CONFIRMED" : tier == 1 ? "✗ NO EDGE HERE" : tier == 2 ? "• UNPROVEN" : "… LEARNING"
string actShort = tier == 3 ? "Act on signals" : tier == 1 ? "Skip — no edge" : tier == 2 ? "Low confidence" : "Gathering data"
string actLong  = tier == 3 ? "Divergences from your leader have beaten a same-spot baseline here, net of the multiple-comparison correction. Favour the direction in 'Best signal' when it is confirmed." : tier == 1 ? "These intermarket divergences have not beaten a coin-flip here — often because the leader co-moves rather than leads. Skip them, pick a leader that genuinely leads, or change the timeframe." : tier == 2 ? "Edge isn't statistically established yet. Treat signals as low-confidence until the sample grows." : "Still collecting completed signals. The verdict appears once there are enough to judge (need " + str.tostring(minN) + ", have " + str.tostring(totN, "0") + ")."
string nowTxt = not leaderOK ? "no leader data" : live ? (lastDir == 1 ? "Bullish" : "Bearish") + " signal" + (barsSince == 0 ? " — now" : " — " + str.tostring(barsSince) + " bars ago") : "No live signal"
string zone = cmp >= extSigma ? "Stretched high" : cmp >= obSigma ? "High" : cmp <= -extSigma ? "Stretched low" : cmp <= -obSigma ? "Low" : "Neutral"
float acorr = na(corrPx) ? na : math.abs(corrPx)
string linkTxt = na(corrPx) ? "—" : str.tostring(corrPx, "0.00") + (acorr >= 0.6 ? "  strong" : acorr >= 0.3 ? "  moderate" : "  weak")

// ─── THEME (adaptive to chart background) ─────────────────────────────────────
bool dark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_luma(chart.bg_color) < 140
color panelBg = dark ? color.rgb(17, 22, 28)  : color.rgb(244, 246, 248)
color rowAlt  = dark ? color.rgb(25, 31, 39)  : color.rgb(232, 236, 240)
color pTxt    = dark ? color.rgb(154,166,178) : color.rgb(74, 82, 91)
color pStr    = dark ? color.white            : color.rgb(16, 20, 24)
color frameC  = dark ? color.rgb(58, 70, 84)  : color.rgb(196,204,212)
color tierCol = tier == 3 ? bullCol : tier == 1 ? bearCol : tier == 2 ? midColr : color.gray
color tierTxt = f_luma(tierCol) > 150 ? color.black : color.white
color zc_     = cmp >= obSigma ? bullCol : cmp <= -obSigma ? bearCol : color.new(chart.fg_color, 25)
color zcTxt   = f_luma(zc_) > 150 ? color.black : color.white
color linkCol = na(corrPx) ? pTxt : acorr >= 0.6 ? pStr : acorr >= 0.3 ? midColr : bearCol

// ─── PLOTS (kept out of status line / price scale for a clean chart) ──────────
bgcolor(showTint ? (cmp >= extSigma ? color.new(bullCol, 92) : cmp <= -extSigma ? color.new(bearCol, 92) : na) : na, title = "Extreme tint")
hline(0, "Zero", color.new(chart.fg_color, 70))
pU  = plot(obSigma,   "+Band", color.new(bullCol, 65), 1, display = display.pane, editable = false)
pUe = plot(extSigma,  "+Ext",  color.new(bullCol, 80), 1, display = display.pane, editable = false)
pL  = plot(-obSigma,  "-Band", color.new(bearCol, 65), 1, display = display.pane, editable = false)
pLe = plot(-extSigma, "-Ext",  color.new(bearCol, 80), 1, display = display.pane, editable = false)
fill(pUe, pU,  extSigma,  obSigma,  color.new(bullCol, 82), color.new(bullCol, 95), title = "Upper band")
fill(pL, pLe, -obSigma, -extSigma, color.new(bearCol, 95), color.new(bearCol, 82), title = "Lower band")
color cmpCol = cmp >= 0 ? bullCol : bearCol
plot(cmp, "Leader glow", color.new(cmpCol, 80), 5, display = display.pane)
plot(cmp, "Leader", cmpCol, 2, display = display.pane)
int strT = sigStar ? 0 : 45
plotshape(bullDiv ? cmp : na, "Bullish signal", shape.circle, location.absolute, color.new(bullCol, strT), 0, size = size.tiny, display = display.pane)
plotshape(bearDiv ? cmp : na, "Bearish signal", shape.circle, location.absolute, color.new(bearCol, strT), 0, size = size.tiny, display = display.pane)
plotshape(showHidden and hBull ? cmp : na, "Hidden bullish", shape.cross, location.absolute, color.new(bullCol, 30), 0, size = size.tiny, display = display.pane)
plotshape(showHidden and hBear ? cmp : na, "Hidden bearish", shape.cross, location.absolute, color.new(bearCol, 30), 0, size = size.tiny, display = display.pane)

// ─── OVERLAY SIGNALS (CSM-style map-pin tags on the MAIN PRICE CHART) ──────────
// A green "B" pin below the bar for a bullish divergence, a red "S" pin above the bar for bearish
// (regular and hidden share the pin; the pane below still shows circle vs ✕ for the exact class).
// The size, not the colour, carries the confirmation cue: confirmed edge → chosen size, not-yet-
// proven → one size smaller. label.new's size accepts a series, so a single call per side suffices.
bool ovBull = showSigOv and (bullDiv or (showHidden and hBull))
bool ovBear = showSigOv and (bearDiv or (showHidden and hBear))
if ovBull
    label.new(bar_index, low,  buyTag,  xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_label_up,   color = color.new(bullCol, 0), textcolor = color.white, size = sigStar ? f_sz(sigSize) : size.tiny, force_overlay = true)
if ovBear
    label.new(bar_index, high, sellTag, xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(bearCol, 0), textcolor = color.white, size = sigStar ? f_sz(sigSize) : size.tiny, force_overlay = true)

// ─── VERDICT PANEL (top-right) ────────────────────────────────────────────────
var table pan = table.new(position.top_right, 2, 9, frame_width = 1, border_width = 1)
f_pan(int r, string k, string v, color vc, string tip) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(pan, 0, r, k, text_color = pTxt, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left, tooltip = tip)
    table.cell(pan, 1, r, v, text_color = vc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right, tooltip = tip)
if barstate.islast and showVerdict
    table.set_frame_color(pan, frameC)
    table.set_border_color(pan, frameC)
    table.cell(pan, 0, 0, "INTERMKT DIV", text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_left)
    table.cell(pan, 1, 0, verdict, text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_right)
    f_pan(1, "Do this", actShort, tierCol, actLong)
    f_pan(2, "Right now", nowTxt, not leaderOK ? bearCol : live ? (lastDir == 1 ? bullCol : bearCol) : pTxt, "Whether a fresh signal has printed in the last few bars.")
    f_pan(3, "Best signal", bestConfirmed ? bestName + "  " + (bestPoint >= 0 ? "+" : "") + str.tostring(bestPoint, "#.#") + "%" : "none confirmed", bestConfirmed ? (bestC == 1 or bestC == 3 ? bullCol : bearCol) : pTxt, "A direction is named only once it is individually proven — its edge lower-bound clears zero AFTER the multiple-comparison deflation. Otherwise no single side is trustworthy yet.")
    f_pan(4, "Leader link", linkTxt, linkCol, "How tightly the leader currently tracks price. A weak link means the leader has decoupled and its divergences are unreliable.")
    f_pan(5, "Track record", na(hitPct) ? "warming up" : "won " + str.tostring(hitPct, "#.#") + "% vs " + str.tostring(basePct, "#.#") + "% base", pStr, "How often the favourable move followed, vs a same-spot baseline, over " + str.tostring(totN, "0") + " completed signals.")
    f_pan(6, "Reward : risk", na(rr) ? "—" : str.tostring(rr, "0.0") + " : 1" + (rr >= 1.2 ? "  good" : rr < 0.8 ? "  poor" : ""), na(rr) ? pTxt : rr >= 1.2 ? bullCol : rr < 0.8 ? bearCol : pStr, "Average best move vs average worst move after a signal, in ATR. Below 1:1 means signals hurt more than they help.")
    f_pan(7, "Market regime", regimeCode == 1 ? "Trending" : regimeCode == -1 ? "Reverting" : "—", regimeCode == 1 ? bullCol : regimeCode == -1 ? midColr : pTxt, "Reverting markets suit divergence; strong trends punish it.")
    string wfTxt = wfOosN < minN ? "warming (" + str.tostring(wfOosN, "0") + "/" + str.tostring(minN) + ")" : (wfOosEdge >= 0 ? "+" : "") + str.tostring(wfOosEdge, "#.#") + "pp"
    f_pan(8, "OOS edge (walk-fwd)", wfTxt, wfOosN < minN ? pTxt : wfOosEdge > 0 ? bullCol : midColr, "Out-of-sample walk-forward: the edge measured ONLY on signals AFTER the first " + str.tostring(wfTrainN) + " (in-sample). The trustworthy read — an in-sample edge can flatter because the settings were tuned on that same data.")

// ─── KEY-INFO TABLE (top-left) ────────────────────────────────────────────────
var table keyT = table.new(position.top_left, 2, 6, frame_width = 1, border_width = 1)
f_key(int r, string k, string v, color vc) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(keyT, 0, r, k, text_color = pTxt, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyT, 1, r, v, text_color = vc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)
if barstate.islast and showKey
    table.set_frame_color(keyT, frameC)
    table.set_border_color(keyT, frameC)
    table.cell(keyT, 0, 0, "KEY INFO", text_color = zcTxt, bgcolor = zc_, text_size = size.tiny, text_halign = text.align_left)
    table.cell(keyT, 1, 0, zone, text_color = zcTxt, bgcolor = zc_, text_size = size.tiny, text_halign = text.align_right)
    f_key(1, "Instrument", syminfo.ticker + " · " + timeframe.period, pStr)
    f_key(2, "Leader", leaderOK ? str.tostring(cmpSym) + (invLead ? " (inv)" : "") : "missing", leaderOK ? pStr : bearCol)
    f_key(3, "Leader link", linkTxt, linkCol)
    f_key(4, "Samples", str.tostring(totN, "0") + (enoughN ? " (ready)" : " (warming)"), enoughN ? pStr : midColr)
    f_key(5, "Value (σ)", str.tostring(cmp, "#.##"), zc_)

// ─── PER-CLASS TABLE (bottom-right) ───────────────────────────────────────────
var table grid = table.new(position.bottom_right, 7, 7, frame_width = 1, border_width = 1)
f_grid(int r, int cls, string nm, color nc) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    float w = kW.get(cls)
    float n = kN.get(cls)
    float h = calib.hitRate(w, n)
    float bb = kBn.get(cls) > 0 ? kBs.get(cls) / kBn.get(cls) : na
    float e = not na(h) and not na(bb) ? h - bb : na
    float fe = n > 0 ? kFe.get(cls) / n : na
    float ae = n > 0 ? kAe.get(cls) / n : na
    float r2r = not na(fe) and not na(ae) and ae < 0 ? fe / (-ae) : na
    table.cell(grid, 0, r, nm, text_color = nc, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(grid, 1, r, str.tostring(n, "0"), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 2, r, na(h) ? "—" : str.tostring(h, "#.#"), text_color = pStr, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 3, r, na(bb) ? "—" : str.tostring(bb, "#.#"), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 4, r, na(e) ? "—" : (e >= 0 ? "+" : "") + str.tostring(e, "#.#"), text_color = na(e) ? pTxt : e > 0 ? bullCol : bearCol, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 5, r, na(r2r) ? "—" : str.tostring(r2r, "0.0"), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
    table.cell(grid, 6, r, na(ae) ? "—" : str.tostring(ae, "#.#"), text_color = pTxt, bgcolor = bg, text_size = size.tiny)
if barstate.islast and showGrid
    table.set_frame_color(grid, frameC)
    table.set_border_color(grid, frameC)
    table.cell(grid, 0, 0, "Signal",  text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny, text_halign = text.align_left)
    table.cell(grid, 1, 0, "n",     text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 2, 0, "Win%",  text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 3, 0, "Base",  text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 4, 0, "Edge",  text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 5, 0, "R:R",   text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    table.cell(grid, 6, 0, "MAE",   text_color = tierTxt, bgcolor = tierCol, text_size = size.tiny)
    f_grid(1, 1, "Bullish",    bullCol)
    f_grid(2, 2, "Bearish",    bearCol)
    f_grid(3, 3, "Bull (hid)", color.new(bullCol, 35))
    f_grid(4, 4, "Bear (hid)", color.new(bearCol, 35))
    table.cell(grid, 0, 5, "All", text_color = pStr, bgcolor = panelBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(grid, 1, 5, str.tostring(totN, "0"), text_color = pTxt, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 2, 5, na(hitPct) ? "—" : str.tostring(hitPct, "#.#"), text_color = pStr, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 3, 5, na(basePct) ? "—" : str.tostring(basePct, "#.#"), text_color = pTxt, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 4, 5, na(edge) ? "—" : (sigStar ? "★" : "") + (edge >= 0 ? "+" : "") + str.tostring(edge, "#.#"), text_color = na(edge) ? pTxt : edge > 0 ? bullCol : bearCol, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 5, 5, na(rr) ? "—" : str.tostring(rr, "0.0"), text_color = pTxt, bgcolor = panelBg, text_size = size.tiny)
    table.cell(grid, 6, 5, "", bgcolor = panelBg)
    table.cell(grid, 0, 6, "Edge floor", text_color = pTxt, bgcolor = rowAlt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(grid, 1, 6, "", bgcolor = rowAlt)
    table.cell(grid, 2, 6, "", bgcolor = rowAlt)
    table.cell(grid, 3, 6, "", bgcolor = rowAlt)
    table.cell(grid, 4, 6, na(edgeLB) ? "—" : (edgeLB >= 0 ? "+" : "") + str.tostring(edgeLB, "#.#"), text_color = na(edgeLB) ? pTxt : edgeLB > 0 ? bullCol : bearCol, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(grid, 5, 6, "", bgcolor = rowAlt)
    table.cell(grid, 6, 6, "", bgcolor = rowAlt)

// ─── NAME TAG (bottom-center) ─────────────────────────────────────────────────
var table idT = table.new(position.bottom_center, 1, 1)
if barstate.islast and showId
    table.cell(idT, 0, 0, "Intermarket Div · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = dark ? color.white : color.black, bgcolor = color.new(dark ? color.black : color.white, 15))

// ─── EXP_* EXPORT BUS (generic names for cross-script access) ──────────────────
float expProb = na(hitPct) ? na : hitPct / 100.0
plot(showEXP ? cmp : na,        "EXP_Osc",    color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? (longSig ? 1 : shortSig ? -1 : 0) : na, "EXP_Signal", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? expProb : na,    "EXP_Prob",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edge : na,       "EXP_Edge",   color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? edgeLB : na,     "EXP_EdgeLB", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? totN : na,       "EXP_N",      color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? regimeCode : na, "EXP_Regime", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? cmpRaw : na,     "EXP_Leader", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? corrPx : na,     "EXP_LeaderCorr", color = color.new(color.gray, 100), display = display.data_window)
plot(showEXP ? wfOosEdge : na, "EXP_OOSEdge", color = color.new(color.gray, 100), display = display.data_window)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(bullDiv or hBull, "Bullish divergence", "Intermarket Div: bullish divergence")
alertcondition(bearDiv or hBear, "Bearish divergence", "Intermarket Div: bearish divergence")
alertcondition((bullDiv or hBull) and tier == 3, "Bullish (edge confirmed)", "Intermarket Div: bullish divergence with confirmed edge")
alertcondition((bearDiv or hBear) and tier == 3, "Bearish (edge confirmed)", "Intermarket Div: bearish divergence with confirmed edge")
````
