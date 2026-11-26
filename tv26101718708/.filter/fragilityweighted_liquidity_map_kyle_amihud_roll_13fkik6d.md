# Fragility-Weighted Liquidity Map  Kyle  Amihud  Roll

- url: https://www.tradingview.com/script/13fkik6d-Fragility-Weighted-Liquidity-Map-Kyle-Amihud-Roll/
- type: indicator
- pine_id: PUB;f51f23829c1a43438d6d943f5a4dc7fb
- version: 3.0

## Description

Fragility-Weighted Liquidity Map — Kyle · Amihud · Roll

What it is

A move of the same size means opposite things depending on the book beneath it. Into a thin book, a move is mostly price impact — mechanical, fragile, prone to snap back. Into a deep book, the same move took real participation and is more likely informed. This tool estimates how impact-driven the tape is right now from three classic microstructure measures, fuses them into one fragility read, and tints recent liquidity levels by it. It scales conviction and risk — it never picks a direction.

The three measures (all from OHLCV, peer-reviewed)

Kyle's lambda (Kyle 1985) — price impact per unit of signed volume: |price change over a window| ÷ |Σ sign(Δclose)·volume|. High λ = each unit of flow moves price a lot = thin, impactable.

Amihud illiquidity (Amihud 2002) — the average of |return| ÷ dollar-volume. High = small volume moves price a lot. (Empirically ~0.8 correlated with Kyle, so the two are blended, not double-counted.)
Roll implied spread (Roll 1984) — the effective spread implied by the bid-ask bounce: c = 2·√(−Cov(Δp, Δp₋₁)) when that covariance is negative. When it is positive — common in trends — the Roll model does not apply, so the estimate is shown as not measurable here rather than forced to a number. That honesty is deliberate.

Fusion → fragility

Each measure is ranked against its own recent history (a percentile), so the read self-tunes to the symbol and timeframe. The fragility index is the weighted blend of whichever measures are currently available (Roll drops out in trends, and the blend adapts). High fragility = impact-driven, reversible tape; low = deep, informed. A plain-language read suggests trusting breakouts less and fades more when fragility is high — as context, not a signal.

The map

Bars that trade unusually large volume leave a horizontal liquidity level where size changed hands. Each level is tinted by the fragility state at the moment it formed: warm = it printed in a thin/impact-driven tape (a weaker level, more likely to be swept); cool = it printed in a deep/informed tape (sturdier). So the map shows not just where liquidity sits but how trustworthy each pocket is.

How to use it

Add to any liquid symbol/timeframe; defaults suit index futures — change the price/volume sources for other markets.
Glance at the fragility lane — the thin strip at the pane bottom: red = thin/fragile, green = deep/solid, gray = normal. Risk-semantic colors (danger/safe), never direction. That strip alone answers "how careful should I be" for a non-technical user.
States are dwell-filtered (standard anti-chattering): a new THIN/DEEP/NORMAL is announced only after surviving a set number of bars, so the read doesn't flip-flop. STABILITY shows how settled it is; PENDING shows a forming state with a countdown. The cost is a few bars of lag — stated and adjustable.
The HTF STACK row shows the raw fragility state on three higher timeframes derived as multiples of the chart (defaults 3×, 5×, 15× — a 5m chart reads 15m/25m/75m automatically). ✓ green = all timeframes agree on the same actionable state; ⚠ amber = a higher timeframe reads the opposite state.
Read the dashboard: DEEP / NORMAL / THIN, the three measures' ranks, and a suggested size factor. As it turns THIN, treat moves as more reversible: size down, favour fades over breakout-chasing.
Use the rails as liquidity references coloured by trust — a warm rail formed in fragile conditions; a cool rail in solid ones.
Pairs with Order-Flow Criticality: that tool asks whether flow is self-exciting (endogenous); this asks whether the book is thin (impactable). Both elevated together is the genuinely fragile state.

What makes it original

Retail liquidity tools draw where volume traded. This one weights each level and the whole tape by how impactable it is, using three peer-reviewed microstructure estimators computed from bar data, self-calibrated, and — crucially — honest about when the Roll model doesn't apply. Reframing a liquidity map from "where is liquidity" to "how fragile is liquidity" is the contribution.

Concept credits

Price impact of order flow (lambda) — A. S. Kyle (1985). Illiquidity ratio — Y. Amihud (2002). Implied effective spread from serial covariance — R. Roll (1984). Square-root impact refinement — J. Hasbrouck. Fragility framing — general market-microstructure literature. Implementation and charting design are the author's own.

Important disclaimer

Research and education only. Not financial advice, not a signal service, not a guarantee of future results. These are proxies estimated from bar data, not order-book truth, and they do not predict direction. Validate independently and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// =============================================================================
//  © Market_Logic_India                                                 MPL-2.0
//  FRAGILITY-WEIGHTED LIQUIDITY MAP                                         v1.2
//  v1.2 — three additive layers, all optional and reversible; the Amihud and Roll estimators,
//         the fusion, the dwell-debounce, the liquidity map and the MTF stack are unchanged:
//    • U4 (microstructure): Kyle's lambda is now a proper rolling OLS slope — cov(Δprice, signed flow)
//      / var(flow) — instead of the |Σ price change| / |Σ signed volume| aggregate ratio.
//      Selectable via "Kyle method" (default "Rolling OLS").
//    • U1 (microstructure): the signed-volume input can be TRUE measured intrabar flow (net delta
//      summed from lower-timeframe sub-bars) instead of sign(return) × volume. Selectable via
//      "Flow sign source", with automatic fallback to the bar-return sign on bars with no sub-bar data.
//    • U9 (bar character): names the current bar's dominant Wyckoff / VSA effort-vs-result event —
//      Upthrust, Shakeout, Stopping Volume, Buying/Selling Climax, No-Demand/No-Supply — on a new
//      dashboard row and as EXP_VSABias (+1/0/−1). Optional on-price markers, off by default.
//    Set Kyle method = "Ratio (original)" and Flow sign source = "Bar return sign" for the v1.1 read;
//    the VSA layer only reads bar data and never feeds back into the fragility engine.
//  v1.1 — House-standard pass (no engine change): a seed-on-first-valid EMA replaces two conditional
//         ta.ema calls (clears CW10004; output unchanged after warm-up); added the MPL-2.0 header and
//         an EXP_ export bus. No cost model — this is a descriptive liquidity/risk map, not a signal.
//  Reads whether price moves are IMPACT-driven (thin, reversible) or INFORMED
//  (deep, to be trusted) — and marks liquidity levels weighted by that state.
// -----------------------------------------------------------------------------
//  THE IDEA
//    A move of the same size means opposite things depending on the book beneath
//    it. Into a THIN book, a move is mostly price impact — mechanical, fragile,
//    prone to snap back. Into a DEEP book, the same move took real participation —
//    it is more likely informed and worth trusting. This tool estimates how
//    impact-driven the tape is right now from three classic microstructure
//    measures, fuses them into one fragility read, and tints recent liquidity
//    levels by it. It scales conviction and risk; it never picks a direction.
//
//  THE THREE MEASURES (all from OHLCV, peer-reviewed)
//    • KYLE'S LAMBDA (Kyle 1985) — price impact per unit of signed volume:
//        lambda = |price change over window| / Σ sign(Δclose)·volume.
//      High lambda = each unit of flow moves price a lot = thin / impactable.
//    • AMIHUD ILLIQUIDITY (Amihud 2002) — average of |return| / dollar-volume.
//      High = small volume moves price a lot = illiquid. (Empirically ~0.8
//      correlated with Kyle, so the two are blended, not double-counted.)
//    • ROLL IMPLIED SPREAD (Roll 1984) — effective spread from the bid-ask
//        bounce:  c = 2·sqrt( −Cov(Δp_t, Δp_{t−1}) )  when the covariance is
//      negative. When it is POSITIVE (common in trends) the Roll model does not
//      apply, so the estimate is treated as unavailable rather than forced to
//      zero — an honest 'not measurable here' instead of a fake number.
//
//  FUSION → FRAGILITY
//    Each measure is ranked against its own recent history (percentile), so the
//    read self-tunes per symbol and timeframe. The fragility index is the blend
//    of the available ranks. High fragility = impact-driven / reversible tape;
//    low = deep / informed. A companion 'how to act' line suggests trusting
//    breakouts less and fades more when fragility is high — as context, not a
//    signal.
//
//  THE MAP
//    Bars with unusually large volume leave a horizontal liquidity level (where
//    size traded). Each level is tinted by the fragility state at the time it
//    formed: warm = it printed in a thin/impact-driven tape (weaker level, more
//    likely to be swept); cool = it printed in a deep/informed tape (sturdier).
//
//  PAIRS WITH ORDER-FLOW CRITICALITY
//    Criticality asks if flow is self-exciting (endogenous); this asks if the
//    book is thin (impactable). Both high together is the genuine fragile state.
//
//  HOW TO READ IT (price overlay)
//    Background tint intensifies as fragility rises; liquidity rails are coloured
//    by the regime they formed in; the dashboard states DEEP / NORMAL / THIN with
//    the three measures and a suggested size factor. Risk read, not direction.
//
//  NON-REPAINT
//    All measures, ranks and levels resolve on CONFIRMED bars. The live bar is
//    provisional.
//
//  USE ON ANY MARKET
//    Price and volume sources and every window are inputs; measures are relative.
//    Defaults suit liquid intraday futures — change sources for other markets.
//
//  CONCEPT CREDITS (original authors of the ideas synthesised here)
//    • Price impact of order flow (lambda) — A. S. Kyle (1985).
//    • Illiquidity ratio — Y. Amihud (2002).
//    • Implied effective spread from serial covariance — R. Roll (1984).
//    • Square-root impact refinement — J. Hasbrouck. Fragility framing — general
//      market-microstructure literature. Implementation is the author's own.
//
//  DISCLAIMER
//    Research and education only. NOT financial advice, NOT a signal service,
//    NOT a guarantee of future results. These are proxies estimated from bar
//    data, not order-book truth, and they do not predict direction. Validate
//    independently and manage your own risk.
// =============================================================================
indicator("Fragility-Weighted Liquidity Map — Kyle · Amihud · Roll", "Liquidity Fragility",
     overlay = true, max_lines_count = 300, max_labels_count = 200, max_bars_back = 5000, dynamic_requests = true)

// ═════════════════════════ 00 · DATA SOURCE ═════════════════════════════════
g0 = "00 · Data source"
srcPrice = input.source(close,  "Price source", group = g0,
     tooltip = "Series the measures run on. Default close; change for spreads / custom symbols.")
volSrc   = input.source(volume, "Volume source", group = g0,
     tooltip = "Volume for dollar-volume and order-flow. On no-volume symbols the measures degrade gracefully.")

// ═════════════════════════ 01 · MICROSTRUCTURE WINDOWS ══════════════════════
g1 = "01 · Measures"
impWin  = input.int(20, "Impact window (Kyle / Roll)", minval = 5, maxval = 200, group = g1,
     tooltip = "Window for Kyle's lambda (price change over signed volume) and the Roll covariance.")
kyleMethod = input.string("Rolling OLS (Wave B)", "Kyle method", options = ["Rolling OLS (Wave B)", "Ratio (original)"], group = g1, tooltip = "Rolling OLS = Kyle's lambda as the regression slope of price change on signed flow, cov(Δp,flow)/var(flow) — a fitted impact coefficient. Ratio = the original |Σ price change| / |Σ signed volume| aggregate.")
flowSign   = input.string("True LTF (measured)", "Flow sign source", options = ["True LTF (measured)", "Bar return sign"], group = g1, tooltip = "Signed volume fed to Kyle. True LTF sums lower-timeframe sub-bars (signed close-vs-open) into measured net delta; falls back to sign(return) × volume on bars with no sub-bar data. Bar return sign = original.")
ltfRes     = input.string("Auto (finest)", "Sub-bar resolution", options = ["Auto (finest)", "Seconds", "1 minute"], group = g1, tooltip = "Lower timeframe used to measure intrabar flow. Recent bars only.")
amiWin  = input.int(20, "Amihud window", minval = 5, maxval = 200, group = g1,
     tooltip = "Averaging window for the Amihud illiquidity ratio.")
rankLook= input.int(300, "Self-calibration lookback", minval = 50, maxval = 2000, group = g1,
     tooltip = "Each measure is ranked against this many recent bars, so the fragility read self-tunes per symbol / timeframe.")
wKyle   = input.float(1.0, "Weight · Kyle", minval = 0.0, maxval = 3.0, step = 0.1, group = g1)
wAmihud = input.float(1.0, "Weight · Amihud", minval = 0.0, maxval = 3.0, step = 0.1, group = g1)
wRoll   = input.float(1.0, "Weight · Roll", minval = 0.0, maxval = 3.0, step = 0.1, group = g1)

// ═════════════════════════ 02 · FRAGILITY STATE ═════════════════════════════
g2 = "02 · Fragility state"
thinLevel = input.float(70.0, "Thin / fragile above (percentile)", minval = 50.0, maxval = 95.0, step = 5.0, group = g2,
     tooltip = "Fragility percentile above which the tape is flagged THIN (impact-driven, moves more reversible).")
deepLevel = input.float(30.0, "Deep / informed below (percentile)", minval = 5.0, maxval = 50.0, step = 5.0, group = g2,
     tooltip = "Fragility percentile below which the tape is flagged DEEP (informed, moves more trustworthy).")
fragSmooth= input.int(3, "Fragility smoothing", minval = 1, maxval = 20, group = g2)

// ═════════════════════════ 03 · LIQUIDITY MAP ═══════════════════════════════
g3 = "03 · Liquidity levels"
showLevels = input.bool(true, "Draw liquidity levels", group = g3)
volPct   = input.float(85.0, "Level volume percentile", minval = 50.0, maxval = 99.0, step = 1.0, group = g3,
     tooltip = "A bar leaves a liquidity level when its volume ranks above this percentile of recent volume (a size print).")
volPctWin= input.int(100, "Level volume lookback", minval = 20, maxval = 500, group = g3)
keepLevels=input.int(12, "Levels to keep", minval = 2, maxval = 60, group = g3)
levelLen = input.int(60, "Level length (bars, 0 = extend)", minval = 0, maxval = 500, group = g3)

// ═════════════════════════ 04 · STABILITY & OUTPUT ══════════════════════════
g4 = "04 · Stability & output"
minDwell = input.int(5, "Confirm state after (bars)", minval = 1, maxval = 50, group = g4,
     tooltip = "Minimum-dwell debounce (standard anti-chattering design): a new THIN/DEEP/NORMAL state is ANNOUNCED only after it survives this many confirmed bars. Removes flicker and tag spam at the cost of this many bars of lag — both stated.")
showLane = input.bool(true, "Fragility lane (strip at pane bottom)", group = g4,
     tooltip = "A thin colored strip along the bottom: red = thin/fragile, green = deep/solid, gray = normal. Risk-semantic colors (danger/safe), never direction.")
showTint  = input.bool(true, "Background fragility tint", group = g4)
showTag   = input.bool(true, "Tags on state change (THIN / DEEP)", group = g4)

// ═════════════════════════ 05 · DASHBOARD ═══════════════════════════════════
g5 = "05 · Dashboard"
showDash  = input.bool(true, "Show main dashboard", group = g5)
compactTbl= input.bool(false, "Compact dashboard", group = g5)
dashPos   = input.string("Top Right", "Dashboard position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g5)
showId    = input.bool(false, "Show name / symbol / timeframe label (separate table)", group = g5)

// ═════════════════════════ 06 · MULTI-TIMEFRAME ═════════════════════════════
g6m = "06 · Multi-timeframe stack"
mtfOn = input.bool(true, "Show higher-timeframe fragility", group = g6m,
     tooltip = "Computes the RAW fragility state (no dwell — higher timeframes are inherently slower) on three higher timeframes derived as MULTIPLES of the chart, so the stack adapts to any chart (5m → 15/25/75m). Standard higher-timeframe requests — available on every plan and symbol.")
mtfM1 = input.int(3,  "HTF multiple 1 (× chart)", minval = 2, maxval = 100, group = g6m)
mtfM2 = input.int(5,  "HTF multiple 2 (× chart)", minval = 2, maxval = 200, group = g6m)
mtfM3 = input.int(15, "HTF multiple 3 (× chart)", minval = 2, maxval = 500, group = g6m)

// ═════════════════════════ 07 · STYLE ═══════════════════════════════════════
g6 = "07 · Style"
themeOpt = input.string("Auto (match chart)", "Theme",
     options = ["Auto (match chart)", "Dark", "Light"], group = g6)

// ───────────────────────── PALETTE / THEME (adaptive, institution) ──────────
var color COL_MID  = #f7c948
var color COL_INFO = #3d6cf0
var color COL_COOL = #2ebd85
var color COL_WARM = #f6465d

f_lumaDark(color c) =>
    na(c) ? true : (0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)) < 140
bool isDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lumaDark(chart.bg_color)
color tBord  = isDark ? color.new(#3a4250, 0)  : color.new(#c2c8d0, 0)
color tLbl   = isDark ? #9aa3b2 : #515a67
color tVal   = isDark ? #f2f4f8 : #10151d
color cBull  = isDark ? #2dd4bf : #0e9e76
color cWarn  = isDark ? #ffa94d : #b56a00
color cMute  = isDark ? #6b7480 : #98a0ab
color zebraA = isDark ? color.new(#141a26, 0) : color.new(#eef1f6, 0)
color zebraB = isDark ? color.new(#0e131d, 0) : color.new(#f8fafc, 0)
color frameCl = tBord

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

// EMA that seeds on the first valid input and holds through gaps. Runs every bar (no conditional
// ta.*), so it clears CW10004 and replicates the intended `na(x) ? na : ta.ema(x, len)` behaviour
// exactly — the average never sees the pre-warm-up na values.
f_emaSeed(float x, simple int len) =>
    var float e = na
    float a = 2.0 / (len + 1)
    e := na(x) ? e : na(e) ? x : e + a * (x - e)
    e

// ───────────────────────── MTF RAW FRAGILITY (higher timeframes) ────────────
// Same Kyle/Amihud/Roll fusion evaluated in a higher-timeframe context. Raw
// (no dwell): HTF bars are already slow. Unconditional top-level requests.
f_fragStateMTF() =>
    float r_ = srcPrice - nz(srcPrice[1], srcPrice)
    float sv = math.sign(r_) * nz(volSrc, 0.0)
    float dv = nz(volSrc, 0.0) * srcPrice
    float ssv = math.sum(sv, impWin)
    float pxc = srcPrice - srcPrice[impWin]
    float ky = math.abs(ssv) > 0 ? math.abs(pxc) / math.abs(ssv) : na
    float ab = dv > 0 ? math.abs(r_) / dv : na
    float am = ta.sma(ab, amiWin)
    float dl = r_[1]
    float cv = ta.sma(r_ * dl, impWin) - ta.sma(r_, impWin) * ta.sma(dl, impWin)
    float rl = cv < 0 ? 2.0 * math.sqrt(-cv) : na
    float kR = ta.percentrank(nz(ky, 0.0), rankLook)
    float aR = ta.percentrank(nz(am, 0.0), rankLook)
    float rR = ta.percentrank(nz(rl, 0.0), rankLook)
    float ws = 0.0
    float ac = 0.0
    if not na(ky)
        ac += wKyle * kR
        ws += wKyle
    if not na(am)
        ac += wAmihud * aR
        ws += wAmihud
    if not na(rl)
        ac += wRoll * rR
        ws += wRoll
    float fr0 = ws > 0 ? ac / ws : na
    float fr = f_emaSeed(fr0, fragSmooth)
    bool rdy = not na(fr) and bar_index > rankLook
    int st = not rdy ? -1 : fr >= thinLevel ? 2 : fr <= deepLevel ? 0 : 1
    st

f_tfFromMult(int m) =>
    int secs = timeframe.in_seconds() * m
    secs % 604800 == 0 ? str.tostring(secs / 604800) + "W" : secs % 86400 == 0 ? str.tostring(secs / 86400) + "D" : secs % 60 == 0 ? str.tostring(secs / 60) : str.tostring(secs) + "S"
string htfTf1 = f_tfFromMult(mtfM1)
string htfTf2 = f_tfFromMult(mtfM2)
string htfTf3 = f_tfFromMult(mtfM3)
int htfFrag1 = request.security(syminfo.tickerid, htfTf1, f_fragStateMTF(), lookahead = barmerge.lookahead_off)
int htfFrag2 = request.security(syminfo.tickerid, htfTf2, f_fragStateMTF(), lookahead = barmerge.lookahead_off)
int htfFrag3 = request.security(syminfo.tickerid, htfTf3, f_fragStateMTF(), lookahead = barmerge.lookahead_off)
f_stShort(int r) =>
    r == 2 ? "THIN" : r == 0 ? "DEEP" : r == 1 ? "NORM" : "—"

// ───────────────────────── MICROSTRUCTURE MEASURES (from OHLCV) ─────────────
float ret   = srcPrice - nz(srcPrice[1], srcPrice)
float dp    = ret
// Wave B (U1): TRUE measured net signed volume from lower-timeframe sub-bars; bar-sign fallback.
string fSubTf = ltfRes == "Seconds" ? "1S" : ltfRes == "1 minute" ? "1" : (timeframe.in_seconds() >= 3600 ? "1" : timeframe.in_seconds() >= 300 ? "5S" : "1S")
[fC, fO, fV] = request.security_lower_tf(syminfo.tickerid, fSubTf, [close, open, volume])
float fBuy = 0.0
float fSell = 0.0
int fN = math.min(array.size(fV), math.min(array.size(fC), array.size(fO)))
if fN > 0
    for i = 0 to fN - 1
        float sv = nz(array.get(fV, i), 0.0)
        float sc = array.get(fC, i)
        float so = array.get(fO, i)
        int ss = (na(sc) or na(so)) ? 0 : sc > so ? 1 : sc < so ? -1 : 0
        if ss > 0
            fBuy  += sv
        else if ss < 0
            fSell += sv
bool fTrue = flowSign == "True LTF (measured)" and fN > 0 and (fBuy + fSell) > 0.0
float signV = fTrue ? (fBuy - fSell) : math.sign(ret) * nz(volSrc, 0.0)
float dollarVol = nz(volSrc, 0.0) * srcPrice

// Kyle's lambda — Wave B (U4): proper rolling OLS slope of Δprice on signed flow,
//   λ = cov(dp, signV) / var(signV); original aggregate ratio kept as an option.
float sumSignV = math.sum(signV, impWin)
float pxChg    = srcPrice - srcPrice[impWin]
float kMx  = ta.sma(signV, impWin)
float kMy  = ta.sma(dp, impWin)
float kCov = ta.sma(signV * dp, impWin) - kMx * kMy
float kVar = ta.variance(signV, impWin)
float kyleOls   = kVar > 1e-12 ? math.abs(kCov / kVar) : na
float kyleRatio = math.abs(sumSignV) > 0 ? math.abs(pxChg) / math.abs(sumSignV) : na
float kyle = kyleMethod == "Ratio (original)" ? kyleRatio : kyleOls

// Amihud: average of |return| / dollar volume
float amiBar = dollarVol > 0 ? math.abs(ret) / dollarVol : na
float amihud = ta.sma(amiBar, amiWin)

// Roll implied spread: 2*sqrt(-cov(dp_t, dp_{t-1})) when cov<0, else not applicable
// covariance computed from moments (ta.sma) to avoid relying on a covariance builtin
float dpL     = dp[1]
float covRoll = ta.sma(dp * dpL, impWin) - ta.sma(dp, impWin) * ta.sma(dpL, impWin)
float roll = covRoll < 0 ? 2.0 * math.sqrt(-covRoll) : na

// ───────────────────────── SELF-CALIBRATION (percentile ranks) ─────────────
// note: ta.percentrank must run every bar (not inside a ternary); feed nz to keep the series continuous
float kyleRank = ta.percentrank(nz(kyle, 0.0), rankLook)
float amiRank  = ta.percentrank(nz(amihud, 0.0), rankLook)
float rollRank = ta.percentrank(nz(roll, 0.0), rankLook)

// weighted blend of AVAILABLE ranks (Roll drops out in trends)
float wsum = 0.0
float acc  = 0.0
if not na(kyle)
    acc += wKyle * kyleRank
    wsum += wKyle
if not na(amihud)
    acc += wAmihud * amiRank
    wsum += wAmihud
if not na(roll)
    acc += wRoll * rollRank
    wsum += wRoll
float fragRaw = wsum > 0 ? acc / wsum : na
float frag = f_emaSeed(fragRaw, fragSmooth)

bool readyF = not na(frag) and bar_index > rankLook
int rawState = not readyF ? -1 : frag >= thinLevel ? 2 : frag <= deepLevel ? 0 : 1
// minimum-dwell debounce: a new state is announced only after it survives
// minDwell confirmed bars (anti-chattering; lag = dwell bars, stated)
var int fstate = -1
var int fcand  = -1
var int fcAge  = 0
if barstate.isconfirmed
    if rawState == fstate
        fcand := fstate
        fcAge := 0
    else
        if rawState == fcand
            fcAge += 1
        else
            fcand := rawState
            fcAge := 1
        if fcAge >= minDwell or fstate == -1
            fstate := rawState
            fcand := rawState
            fcAge := 0
bool ready = fstate != -1
bool thin  = fstate == 2
bool deep  = fstate == 0
bool thinNew = barstate.isconfirmed and thin and nz(fstate[1], -2) != 2
bool deepNew = barstate.isconfirmed and deep and nz(fstate[1], -2) != 0
var int stateAge = 0
if barstate.isconfirmed
    stateAge := fstate == nz(fstate[1], -2) ? stateAge + 1 : 0
int stabWin = 50
int stabSame = 0
for k = 0 to stabWin - 1
    if nz(fstate[k], -9) == fstate
        stabSame += 1
float stabPct = ready ? stabSame * 100.0 / stabWin : na
float sizeMult = ready ? math.max(0.2, 1.0 - frag / 100.0) : na
string stateTxt = not ready ? "WARMING" : thin ? "THIN" : deep ? "DEEP" : "NORMAL"
string actTxt = not ready ? "-" : thin ? "moves reversible · fade > breakout" : deep ? "moves informed · trust breakouts" : "neutral"

// ───────────────────────── LIQUIDITY LEVELS (size prints) ───────────────────
float volRank = ta.percentrank(nz(volSrc, 0.0), volPctWin)
bool sizePrint = showLevels and not na(volRank) and volRank >= volPct

var line[]  levLines  = array.new<line>()
if sizePrint and barstate.isconfirmed
    // level colour reflects the fragility state when it formed
    color lc = not ready ? color.new(COL_MID, 40) : thin ? color.new(COL_WARM, 25) : deep ? color.new(COL_COOL, 25) : color.new(COL_MID, 35)
    int x2 = levelLen == 0 ? bar_index + 2 : bar_index + levelLen
    ln = line.new(bar_index, srcPrice, x2, srcPrice, xloc.bar_index, extend = levelLen == 0 ? extend.right : extend.none, color = lc, width = 1)
    array.push(levLines, ln)
    if array.size(levLines) > keepLevels
        line.delete(array.shift(levLines))

// ───────────────────────── PLOTS (price overlay) ────────────────────────────
// subtle tint: the lane and tags carry the state; the tint is background context
// only, so it stays in a light 90–95 transparency band on both themes
int tintTransp = ready ? int(math.max(90.0, 97.0 - frag * 0.07)) : 100
color tintC = not ready ? na : thin ? color.new(COL_WARM, tintTransp) : deep ? color.new(COL_COOL, 93) : na
bgcolor(showTint ? tintC : na, title = "Fragility tint")

// fragility lane: thin colored strip at the pane bottom (risk glance-read)
color laneC = thin ? color.new(COL_WARM, 0) : deep ? color.new(COL_COOL, 0) : color.new(cMute, 30)
plotshape(showLane and ready, "Fragility lane", style = shape.square, location = location.bottom, color = laneC, size = size.tiny)

var label[] tags = array.new<label>()
if showTag and thinNew
    lb = label.new(bar_index, high, "THIN", style = label.style_label_down, color = color.new(COL_WARM, 10), textcolor = color.white, size = size.small, tooltip = "Tape is impact-driven: moves are more mechanical and reversible. Size down; favour fades over breakouts. Not a direction.")
    array.push(tags, lb)
if showTag and deepNew
    lb = label.new(bar_index, low, "DEEP", style = label.style_label_up, color = color.new(COL_COOL, 10), textcolor = color.white, size = size.small, tooltip = "Tape is deep: moves took real participation and are more trustworthy. Normal risk; breakouts carry more weight. Not a direction.")
    array.push(tags, lb)
if array.size(tags) > 50
    label.delete(array.shift(tags))

// ───────────────────────── DASHBOARD (institution, adaptive) ─────────────────
f_setRow(table t, int r, string lbl, string val, color vc, color lc, color bg) =>
    table.cell(t, 0, r, lbl, text_color = lc, text_size = size.tiny,  text_halign = text.align_left,  bgcolor = bg)
    table.cell(t, 1, r, val, text_color = vc, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

// ─── VSA BAR EVENTS (Wave D · U9 — ml_vsa effort-vs-result taxonomy, inlined) ───
gVsa     = "Z · VSA bar events (Wave D)"
vsaRow   = input.bool(true,  "Name the VSA event on the dashboard", group = gVsa, tooltip = "Names the current bar's dominant Wyckoff/VSA effort-vs-result event (Upthrust, Shakeout, Stopping Volume, Buying/Selling Climax, No-Demand/Supply) using the shared ml_vsa vocabulary — bar character alongside the fragility read. Shown in the full (non-compact) dashboard. Additive; the fragility engine is unchanged.")
vsaMarks = input.bool(false, "Mark VSA events on price", group = gVsa)
vsaLen   = input.int(50, "VSA history window", minval = 10, maxval = 300, group = gVsa)
vsaPiv   = input.int(5,  "New-extreme lookback", minval = 2, maxval = 50, group = gVsa)
bool  vsaHasVol = not na(volume) and volume > 0
float vsaSp   = ta.percentrank(high - low, vsaLen)
float vsaVp   = ta.percentrank(volume,     vsaLen)
float vsaVpk  = ta.highest(volume, vsaLen)
float vsaRngX = high - low
float vsaCp   = vsaRngX > 0.0 ? (close - low) / vsaRngX : 0.5
float vsaPHi  = ta.highest(high, vsaPiv)[1]
float vsaPLo  = ta.lowest(low,  vsaPiv)[1]
bool  vsaUpB  = close > close[1]
bool  vsaDnB  = close < close[1]
bool  vUpthrust = vsaHasVol and (high >= vsaPHi) and vsaCp <= 0.35 and vsaVp >= 60.0
bool  vShakeout = vsaHasVol and (low  <= vsaPLo) and vsaCp >= 0.65 and vsaVp >= 60.0
bool  vStopping = vsaHasVol and vsaDnB and vsaSp >= 60.0 and vsaVp >= 80.0 and vsaCp >= 0.45
bool  vClimaxUp = vsaHasVol and vsaUpB and volume >= vsaVpk and vsaSp >= 70.0
bool  vClimaxDn = vsaHasVol and vsaDnB and volume >= vsaVpk and vsaSp >= 70.0
bool  vNoDemand = vsaHasVol and vsaUpB and vsaSp <= 35.0 and vsaVp <= 35.0
bool  vNoSupply = vsaHasVol and vsaDnB and vsaSp <= 35.0 and vsaVp <= 35.0
string vsaEvt = vClimaxUp ? "Buying climax" : vClimaxDn ? "Selling climax" : vUpthrust ? "Upthrust" : vShakeout ? "Shakeout" : vStopping ? "Stopping volume" : vNoDemand ? "No demand" : vNoSupply ? "No supply" : "—"
int    vsaBiasVal = (vClimaxDn or vShakeout or vStopping or vNoSupply) ? 1 : (vClimaxUp or vUpthrust or vNoDemand) ? -1 : 0

var table dash = na
if showDash and barstate.islast
    color stBg = not ready ? color.new(cMute, 0) : thin ? color.new(cWarn, 0) : deep ? color.new(cBull, 0) : color.new(COL_INFO, 0)
    if na(dash)
        dash := table.new(f_pos(dashPos), 2, compactTbl ? 4 : (vsaRow ? 12 : 11), border_width = 1, frame_color = frameCl, frame_width = 1)
    table.set_frame_color(dash, frameCl)
    table.set_border_color(dash, frameCl)
    table.cell(dash, 0, 0, " LIQUIDITY FRAGILITY", text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = stBg, tooltip = "Kyle lambda + Amihud + Roll fused into an impact/fragility read. THIN = impact-driven / reversible; DEEP = informed / trustworthy. A risk read from bar-data proxies, not a direction.")
    table.cell(dash, 1, 0, stateTxt + " ", text_color = color.white, text_size = size.small, text_halign = text.align_right, bgcolor = stBg)
    f_setRow(dash, 1, "FRAGILITY", not ready ? "warming" : "p" + str.tostring(math.round(frag)), not ready ? cMute : thin ? cWarn : deep ? cBull : tVal, tLbl, zebraA)
    f_setRow(dash, 2, "SUGGESTED SIZE", na(sizeMult) ? "-" : "× " + str.tostring(sizeMult, "0.00"), na(sizeMult) ? cMute : sizeMult >= 0.6 ? cBull : cWarn, tLbl, zebraB)
    if compactTbl
        f_setRow(dash, 3, "READ", actTxt, ready ? tVal : cMute, tLbl, zebraA)
    else
        f_setRow(dash, 3, "READ", actTxt, ready ? tVal : cMute, tLbl, zebraA)
        f_setRow(dash, 4, "STABILITY", na(stabPct) ? "-" : str.tostring(math.round(stabPct)) + "% of last " + str.tostring(stabWin), na(stabPct) ? cMute : stabPct >= 80 ? cBull : stabPct >= 50 ? tVal : cWarn, tLbl, zebraB)
        string pendTxt = ready and fcand != fstate and fcAge > 0 ? f_stShort(fcand) + " in " + str.tostring(minDwell - fcAge) + " bars" : "none"
        f_setRow(dash, 5, "PENDING", pendTxt, pendTxt == "none" ? cMute : cWarn, tLbl, zebraA)
        f_setRow(dash, 6, "KYLE λ (rank)", na(kyle) ? "n/a" : "p" + str.tostring(math.round(kyleRank)), na(kyle) ? cMute : tVal, tLbl, zebraB)
        f_setRow(dash, 7, "AMIHUD (rank)", na(amihud) ? "n/a" : "p" + str.tostring(math.round(amiRank)), na(amihud) ? cMute : tVal, tLbl, zebraA)
        f_setRow(dash, 8, "ROLL (rank)", na(roll) ? "n/a (trend)" : "p" + str.tostring(math.round(rollRank)), na(roll) ? cMute : tVal, tLbl, zebraB)
        f_setRow(dash, 9, "LEVELS", str.tostring(array.size(levLines)) + " / " + str.tostring(keepLevels), tVal, tLbl, zebraA)
        if mtfOn
            bool actionable = fstate == 2 or fstate == 0
            bool mtfAgree = actionable and htfFrag1 == fstate and htfFrag2 == fstate and htfFrag3 == fstate
            bool mtfOppose = actionable and (((htfFrag1 == 0 or htfFrag1 == 2) and htfFrag1 != fstate) or ((htfFrag2 == 0 or htfFrag2 == 2) and htfFrag2 != fstate) or ((htfFrag3 == 0 or htfFrag3 == 2) and htfFrag3 != fstate))
            string mtfTxt = str.tostring(mtfM1) + "× " + f_stShort(htfFrag1) + " · " + str.tostring(mtfM2) + "× " + f_stShort(htfFrag2) + " · " + str.tostring(mtfM3) + "× " + f_stShort(htfFrag3) + (mtfAgree ? "  ✓" : mtfOppose ? "  ⚠" : "")
            f_setRow(dash, 10, "HTF STACK", mtfTxt, mtfAgree ? cBull : mtfOppose ? cWarn : tVal, tLbl, zebraB)
        else
            f_setRow(dash, 10, "HTF STACK", "off", cMute, tLbl, zebraB)
        if vsaRow
            color vsaEvtCol = vsaBiasVal > 0 ? cBull : vsaBiasVal < 0 ? cWarn : cMute
            f_setRow(dash, 11, "VSA EVENT", vsaEvt, vsaEvtCol, tLbl, zebraA)

// identity label (separate toggle)
var table idTbl = na
if showId and barstate.islast
    if na(idTbl)
        idTbl := table.new(position.bottom_center, 1, 1)
    table.cell(idTbl, 0, 0, "Liquidity Fragility  ·  " + syminfo.ticker + "  " + timeframe.period, text_color = color.new(tLbl, 15), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ───────────────────────── EXPORTS (Data Window · generic names) ────────────
plot(frag,     "EXP_FragilityIndex",  display = display.data_window)
plot(kyleRank, "EXP_KyleRank",        display = display.data_window)
plot(amiRank,  "EXP_AmihudRank",      display = display.data_window)
plot(rollRank, "EXP_RollRank",        display = display.data_window)
plot(sizeMult, "EXP_SuggestedSize",   display = display.data_window)
plot(ready ? fstate : na, "EXP_LiquidityState", display = display.data_window)
plot(stabPct, "EXP_FragilityStability", display = display.data_window)
plot(mtfOn ? htfFrag1 : na, "EXP_FragilityHTF1", display = display.data_window)
plot(mtfOn ? htfFrag2 : na, "EXP_FragilityHTF2", display = display.data_window)
plot(mtfOn ? htfFrag3 : na, "EXP_FragilityHTF3", display = display.data_window)
plot(vsaBiasVal, "EXP_VSABias", display = display.data_window)

// VSA event markers on price (Wave D) — off by default; one marker per bar by priority
plotshape(vsaMarks and vClimaxUp, "VSA Buying climax",  shape.triangledown, location.abovebar, color.new(#ff6d00,0), text = "BC", textcolor = color.new(#ff6d00,0), size = size.tiny, force_overlay = true)
plotshape(vsaMarks and vClimaxDn, "VSA Selling climax", shape.triangleup,   location.belowbar, color.new(#ff6d00,0), text = "SC", textcolor = color.new(#ff6d00,0), size = size.tiny, force_overlay = true)
plotshape(vsaMarks and vUpthrust and not (vClimaxUp or vClimaxDn), "VSA Upthrust", shape.triangledown, location.abovebar, color.new(cWarn,0), text = "UT", textcolor = color.new(cWarn,0), size = size.tiny, force_overlay = true)
plotshape(vsaMarks and vShakeout and not (vClimaxUp or vClimaxDn), "VSA Shakeout", shape.triangleup,   location.belowbar, color.new(cBull,0), text = "SO", textcolor = color.new(cBull,0), size = size.tiny, force_overlay = true)
plotshape(vsaMarks and vStopping and not (vClimaxUp or vClimaxDn or vShakeout), "VSA Stopping Vol", shape.square, location.belowbar, color.new(cBull,0), text = "SV", textcolor = color.new(cBull,0), size = size.tiny, force_overlay = true)

// ───────────────────────── ALERTS ───────────────────────────────────────────
alertcondition(thinNew, "Turned thin / fragile", "Liquidity Fragility: tape turned impact-driven (thin) — moves more reversible, consider sizing down")
alertcondition(deepNew, "Turned deep / informed", "Liquidity Fragility: tape turned deep — moves more trustworthy")
````
