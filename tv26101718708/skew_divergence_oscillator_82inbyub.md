# Skew Divergence Oscillator

- url: https://www.tradingview.com/script/82iNbYUb-Skew-Divergence-Oscillator/
- type: indicator
- pine_id: PUB;a32d18bc64f24171b0c6db9f5c668a83
- version: 5.0

## Description

Skew Divergence Oscillator

A bounded oscillator built from the rolling skewness (asymmetry) of returns — whether recent moves lean toward big up-days or big down-days — with a divergence engine that compares that asymmetry against price. The read most tools miss: when price makes a new high but return skew is turning down (large down-moves creeping in), the advance is quietly losing its character before price confirms it. It estimates skew from higher-resolution realized data, confirms divergences on a higher timeframe, and forward-calibrates whether they pay on the chart you're viewing — in plain language.

Why these parts are combined (not a mashup for show). Each fixes a flaw in the previous one. Skewness is a distributional read price action alone doesn't show — it captures which tail is getting heavier, a leading change in market character. Realized estimation measures skew from intrabar returns instead of one value per bar, so short-window skew isn't jumpy — the standard approach in modern risk research. Divergence relates that asymmetry back to price, turning a statistic into a timing read. Higher-timeframe confirmation and forward calibration remove single-timeframe noise and blind faith respectively. Together they form one coherent tool.

How it works. Returns feed a rolling third standardized moment (skew = m3/sd³). With realized estimation on, skew is computed from a lower-timeframe return stream (confirmed only). It's standardized and soft-bounded to ±100. Divergence is detected from confirmed price pivots versus the skew line (regular and optional hidden); with MTF on, it counts only if the higher timeframe agrees. Each signal is labelled by a triple barrier — a profit target and equal stop in ATR units plus a time limit — split into in-sample and recent out-of-sample, with a confidence interval and a multiple-testing check.

How to use. Read the Verdict (Bull/Bear skew divergence confirmed, unconfirmed, or Wait) and the Conviction, which reads "High" only when that divergence type shows a positive edge that survives the test on this symbol — otherwise it openly says "context only" or "no proven edge here." A skew divergence is an early character warning, not a trend signal — pair it with your own entry trigger and risk plan.

What's original. The realized-skew engine as a divergence source, the higher-timeframe confirmation layer, the triple-barrier forward calibration with an out-of-sample split, and a conviction read that admits when an apparent edge isn't statistically real.

Honesty & limitations. Skew from short windows is noisy. Edge figures are computed on this chart's own history with overlapping windows and no costs — context, not a guaranteed backtest; past behaviour doesn't predict the future. Non-repainting: pivots confirm late and never move; realized and HTF reads use confirmed data only.

Disclaimer: for research and education only. Not financial advice. Trading carries risk of loss; manage your own positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// SKEW DIVERGENCE OSCILLATOR — Realized Asymmetry, MTF-Confirmed & Forward-Calibrated        v1.5
//   v1.5 (R1 · honest-stats standardization) — the reliability scoring is now backed by the published
//     calibration libraries: robust-z via ml_robuststats (byte-identical, so the oscillator/signal are
//     UNCHANGED), Wilson floor + stars + deflated "survives" via ml_calib, and a NEW optional
//     time-of-day significance gate via ml_session (group 7). Same engine across the divergence family.
//     Imports are pinned to the published v2 libraries (ml_calib/2, ml_robuststats/2, ml_session/2) —
//     v2 is additive over v1, so the robust-z read is unchanged; the pin just makes slotSignificant,
//     stars and edgeProven resolve. Pinned exactly (never floating) so a later library update can't
//     silently change this script.
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Correctness + house-standard pass:
//        • Hoisted the HTF-divergence ta.valuewhen calls out of a short-circuiting `and` so they
//          run on every bar (Pine requirement for series functions; clears CW10004 and removes
//          wrong higher-timeframe confirmations that the skipped calls could produce).
//        • Clamped the auto HTF map so Daily/Weekly charts still request a genuinely higher frame.
//        • Added the MPL-2.0 licence header, an EXP_ Data-Window export bus, and a round-trip COST
//          model: a Net-R read where conviction now requires the edge to survive costs.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A bounded oscillator built from the rolling SKEWNESS (asymmetry) of returns — whether recent
//   moves lean toward big up-days or big down-days — and a divergence engine that compares that
//   asymmetry against price. The idea most tools miss: when price makes a new high but return
//   skew is turning DOWN (large down-moves creeping in), the advance is quietly losing its
//   character before price confirms it. It estimates skew from higher-resolution "realized" data,
//   confirms divergences on a higher timeframe, and forward-calibrates whether they pay on the
//   chart you are viewing — in plain language.
//
// WHY THIS CONSTRUCTION (read this if you think it is a mashup)
//   Each part fixes a flaw in the previous one:
//     • Skewness is a distributional read price action alone does not show — it captures WHICH
//       tail is getting heavier, a leading change in market character.
//     • Realized estimation (optional) measures skew from intrabar returns instead of one value
//       per bar — far less noisy, the standard approach in modern risk research, which matters
//       because short-window skew is otherwise jumpy.
//     • Divergence relates that asymmetry back to price, turning a statistic into a timing read.
//     • Higher-timeframe confirmation and forward calibration remove single-timeframe noise and
//       blind faith respectively.
//   The realized-skew engine, the divergence layer, the MTF check and the calibration form one
//   coherent tool — none alone is sufficient.
//
// HOW IT WORKS
//   Returns feed a rolling third standardized moment (skew = m3/sd^3). With "Realized" on, skew is
//   computed from a lower-timeframe return stream (confirmed only). The skew is standardized and
//   soft-bounded to +/-100. Divergence is detected from CONFIRMED price pivots versus the skew
//   line (regular and optional hidden); with MTF confirmation on, it counts only if the higher
//   timeframe agrees. Each signal is labelled by a TRIPLE BARRIER (profit target + equal stop in
//   ATR units, plus a time limit), split into in-sample and recent out-of-sample, with a
//   confidence interval and a multiple-testing check.
//
// HOW TO USE (plain language)
//   • Read the VERDICT row: Bull/Bear skew divergence (confirmed) = asymmetry diverging from price
//     with HTF agreement; "unconfirmed" = chart timeframe only; Wait = none.
//   • The CONVICTION row says whether that divergence type has a positive, statistically-surviving
//     edge on THIS chart. Low conviction = treat as context only.
//   • A skew divergence is an early WARNING about changing character, not a trend signal — pair it
//     with your own entry trigger and risk plan.
//
// NON-REPAINT  Pivots confirm pivot-length bars after the fact and never move. The realized read
//   and the HTF read use confirmed values only (no lookahead). Calibration logs and resolves on
//   barstate.isconfirmed only.
//
// CONCEPT CREDIT (technical attributions)
//   This script combines established, public-domain techniques: the standardized third moment
//   (skewness); realized higher-moment estimation from intraperiod returns as used in modern
//   quantitative risk research; price-versus-oscillator divergence; multi-timeframe confirmation;
//   triple-barrier outcome labelling from standard supervised-labelling practice; the Wilson score
//   interval for the proportion bound; and the Bonferroni adjustment for multiple testing. Credit
//   is due to the originators of each technique. This is an original implementation combining them
//   into one MTF-confirmed, forward-calibrated tool.
//
// CHANGELOG
//   v1.4 (Wave D · U8) — Optional 3-WINDOW CONSENSUS normalization (group 2). The skew z can be
//     taken as the MEDIAN of the z at half, one and double the Normalization window, so a reading
//     counts as extreme only when short, medium and long windows agree — removing the arbitrariness
//     of a single lookback. Selectable via "Extreme normalization"; defaults to "Single window" so
//     behaviour is identical to v1.3 unless you opt in. Divergence, MTF and calibration unchanged.
//   v1.3 (Wave C) — Optional shared REGIME GATE. A Kaufman efficiency-ratio filter (group 8) can
//     restrict actionable Buy/Sell marks (and their forward-test scoring) to a chosen regime:
//     "Favor reverting" fires only when the market is ranging — the natural home for reversal
//     divergences — or "Favor trending" for the opposite. Defaults to "Off" so behaviour is
//     identical to v1.2 unless you opt in. The divergence detection, drawing, MTF confirm and
//     calibration math are unchanged; only the final signal passes through the gate. Dashboard
//     group renumbered 8→9.
//   v1.2 (Wave A) — Optional ROBUST normalization. The skew series can be standardized with a
//     MEDIAN / MAD z-score (median absolute deviation × 1.4826) instead of mean / stdev. Skewness
//     is itself an outlier-driven statistic — a single fat-tailed bar can dominate it — so a
//     mean/stdev z on top double-counts those extremes; MAD-z keeps the sigma scale stable and the
//     divergences comparable across regimes. Selectable via "Normalization" (group 2); defaults to
//     Robust (MAD). Set it to "Classic (mean/stdev)" for the exact v1.1 behaviour. Also pins
//     max_bars_back = 5000 so the deeper history the median/MAD window needs is reserved up front.
//     No divergence, MTF or calibration logic changed.
//
// DISCLAIMER  For research and education only. Skew from short windows is noisy. Edge figures are
//   computed on this chart's own history with overlapping windows and no costs — context, not a
//   guaranteed backtest, and past behaviour does not predict the future. Nothing here is financial
//   advice. Trading carries risk of loss; size and manage your own positions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Skew Divergence Oscillator", "Skew Div", overlay = false, max_lines_count = 200, max_labels_count = 300, max_bars_back = 5000)

// R1 · honest-stats standardization — the reliability scoring is backed by the published calibration
// libraries (one engine across the divergence family). Robust-z is byte-identical to the prior local
// version, so the oscillator/signal are unchanged; only the stats layer + a time-of-day gate are new.
import Market_Logic_India/ml_calib/2        as calib
import Market_Logic_India/ml_robuststats/2  as rstat
import Market_Logic_India/ml_session/2      as sess

// INPUTS  (defaults tuned for NSE:NIFTY1! intraday; change the sources to use any market)
gMain    = "1 · General"
srcPrice = input.source(close, "Price source", group = gMain, tooltip = "Returns are built from this. Change the sources for any symbol/market — this script is asset-agnostic.")
srcHigh  = input.source(high,  "High source",  group = gMain)
srcLow   = input.source(low,   "Low source",   group = gMain)
useLog   = input.bool(true, "Use log returns", group = gMain)
audience = input.string("Simple (plain language)", "Reading mode", options = ["Simple (plain language)", "Pro (full detail)"], group = gMain, tooltip = "Simple shows a verdict and conviction in words. Pro shows every number.")

gEng     = "2 · Skew engine"
mLen     = input.int(50,  "Skew window", minval = 10, maxval = 300, group = gEng)
normLen  = input.int(100, "Normalization window", minval = 20, maxval = 500, group = gEng)
zMode    = input.string("Robust (MAD)", "Normalization", options = ["Robust (MAD)","Classic (mean/stdev)"], group = gEng, tooltip = "Robust (MAD) standardizes skew with median / median-absolute-deviation (×1.4826). Skew is already outlier-driven, so a mean/stdev z double-counts fat-tail bars; MAD keeps the sigma scale stable. Classic reproduces the original.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = gEng, tooltip = "Single window = the standardization uses the one Normalization window above (original behaviour). 3-window consensus = the z is the MEDIAN of the z computed at half, one, and double that window — so a reading is only 'extreme' when short, medium and long windows agree, which removes the arbitrariness of a single lookback. Default Single so nothing changes unless you opt in.")

gReal    = "3 · Realized estimation"
useReal  = input.bool(true, "Use realized (intrabar) returns", group = gReal, tooltip = "Estimate skew from a lower-timeframe return stream instead of one return per bar — far less noisy. On by default.")
realTf   = input.string("Auto (≈1/5×)", "Sub-timeframe", options = ["Auto (≈1/5×)","1","2","3","5","15"], group = gReal, tooltip = "Lower timeframe whose returns build realized skew.")

gDiv     = "4 · Divergence"
pivLen   = input.int(5,  "Pivot length", minval = 1, maxval = 50, group = gDiv, tooltip = "Bars left and right that define a swing pivot.")
divLook  = input.int(60, "Max bars between pivots", minval = 5, maxval = 300, group = gDiv)
showHid  = input.bool(true, "Hidden divergences", group = gDiv, tooltip = "Also detect hidden (continuation) divergence, not just regular (reversal).")
drawLines= input.bool(true, "Draw divergence lines", group = gDiv)

gMTF     = "5 · Higher-timeframe confirm"
useMTF   = input.bool(true, "Require HTF agreement", group = gMTF, tooltip = "A divergence counts only if the higher timeframe also shows same-direction skew divergence. On by default.")
htfMode  = input.string("Auto (≈4–6×)", "Higher timeframe", options = ["Auto (≈4–6×)","Chart","5","15","30","60","120","240","D","W"], group = gMTF)

gSig     = "6 · Zones"
obLvl    = input.float(50, "Positive-skew zone", minval = 10, maxval = 95, group = gSig)
osLvl    = input.float(-50, "Negative-skew zone", minval = -95, maxval = -10, group = gSig)

gCal     = "7 · Forward calibration"
calOn    = input.bool(true, "Run forward calibration", group = gCal, tooltip = "Score divergences forward on this chart. On by default — the core honesty feature.")
calHor   = input.int(15, "Time limit (bars)", minval = 2, maxval = 200, group = gCal)
barrierK = input.float(1.0, "Profit/stop size × ATR", minval = 0.1, maxval = 10.0, step = 0.1, group = gCal, tooltip = "A divergence wins if price reaches the profit target (this many ATRs) before the equal-sized stop, within the time limit.")
atrLen   = input.int(14, "ATR length", minval = 2, maxval = 100, group = gCal)
oosBars  = input.int(1500, "Out-of-sample window (recent bars)", minval = 100, maxval = 20000, group = gCal)
uniqOn   = input.bool(true, "Non-overlapping sampling", group = gCal)
calMinN  = input.int(15, "Min sample for rating", minval = 5, maxval = 500, group = gCal)
costR    = input.float(0.30, "Round-trip cost (R) — subtracted for NET", minval = 0.0, maxval = 3.0, step = 0.05, group = gCal, tooltip = "Round-trip cost (brokerage + STT + slippage + optimistic fill) as a fraction of the barrier risk (Profit/stop × ATR). The barrier is symmetric 1:1, so gross expectancy in R = 2·hit% − 1; Net R subtracts this cost, and CONVICTION now requires the edge to survive it. On 1m NIFTY futures costs eat a large share of R, so a gross edge that ignores them is not tradeable.")
todOn    = input.bool(false, "Time-of-day significance gate (R1)", group = gCal, tooltip = "When ON, a divergence only counts / marks if its intraday time-slot is statistically significant (ml_session.slotSignificant) — filters the dead hours. Off by default so nothing changes unless you opt in.")
todSlotM = input.int(30, "  ToD slot size (min)", minval = 5, maxval = 120, group = gCal)
todZ     = input.float(1.0, "  ToD significance |z|", minval = 0.0, maxval = 4.0, step = 0.1, group = gCal)

gReg     = "8 · Regime gate (Wave C)"
regGate  = input.string("Off", "Regime gate", options = ["Off","Favor reverting","Favor trending"], group = gReg, tooltip = "Optional Kaufman efficiency-ratio filter on confirmed divergences. Off = no filter (original behaviour). Favor reverting = fire only when the market is ranging (ER below threshold) — the natural home for reversal divergences. Favor trending = fire only when trending. Default Off so nothing changes unless you opt in.")
regErLen = input.int(20, "Efficiency-ratio window", minval = 5, maxval = 200, group = gReg)
regErThr = input.float(0.40, "Trend threshold", minval = 0.05, maxval = 0.95, step = 0.05, group = gReg, tooltip = "ER at or above this = trending; below = ranging.")

gUI      = "9 · Dashboard & appearance"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
tblPos   = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Color theme", options = ["Auto (match chart)","Dark","Light"], group = gUI, tooltip = "Auto adapts table, text and line colors to the chart background for visibility on any theme.")
colUp    = input.color(#2ebd85, "Up color",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Down color", inline = "c", group = gUI)

// THEME
bgc        = chart.bg_color
lumaV      = na(bgc) ? 0.0 : color.r(bgc)*0.299 + color.g(bgc)*0.587 + color.b(bgc)*0.114
darkUI     = dashTheme=="Dark" ? true : dashTheme=="Light" ? false : (na(bgc) or lumaV < 140)
panelBg    = darkUI ? color.rgb(17,22,28)    : color.rgb(244,246,248)
rowAlt     = darkUI ? color.rgb(25,31,39)    : color.rgb(232,236,240)
txtMain    = darkUI ? color.rgb(236,239,243) : color.rgb(16,20,24)
txtSub     = darkUI ? color.rgb(154,166,178) : color.rgb(74,82,91)
frameC     = darkUI ? color.rgb(58,70,84)    : color.rgb(196,204,212)
upC        = darkUI ? colUp : color.rgb(22,151,106)
dnC        = darkUI ? colDn : color.rgb(200,42,64)
flatC      = darkUI ? color.rgb(120,130,140) : color.rgb(122,130,139)
gridC      = darkUI ? color.new(color.gray, 55) : color.new(color.gray, 45)

// HELPERS
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_zscore(float s, int len) =>
    sd = ta.stdev(s, len)
    mn = ta.sma(s, len)
    sd == 0 ? 0.0 : (s - mn) / sd
// robust z is now rstat.robZ (byte-identical formula) — see the R1 imports above.
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, float k) => 100.0 * f_tanh(x / math.max(k, 0.0001))
// Wilson floor + stars are now calib.wilsonLo / calib.stars (see R1 imports) — one engine family-wide.
f_firstHit(float up, float lo, int hor) =>
    int fh = 0
    bool done = false
    for i = 0 to hor - 1
        off = hor - 1 - i
        if not done
            hi = high[off]
            ll = low[off]
            bu = hi >= up
            bd = ll <= lo
            if bu and bd
                fh := 2
                done := true
            else if bu
                fh := 1
                done := true
            else if bd
                fh := -1
                done := true
    fh
f_htf() =>
    float tfm = timeframe.in_seconds(timeframe.period) / 60.0
    htfMode != "Auto (≈4–6×)" ? (htfMode=="Chart"?timeframe.period:htfMode) : tfm<=1?"5" : tfm<=2?"10" : tfm<=3?"15" : tfm<=5?"15" : tfm<=15?"60" : tfm<=30?"120" : tfm<=60?"240" : tfm<=240?"D" : tfm<=1440?"W" : "M"
f_htfSub() =>
    float tfm = timeframe.in_seconds(timeframe.period) / 60.0
    realTf != "Auto (≈1/5×)" ? realTf : tfm<=2 ? "1" : tfm<=5 ? "1" : tfm<=15 ? "3" : tfm<=60 ? "5" : "15"
f_skew(float src, simple int win, simple bool logr) =>
    r = logr ? math.log(src / src[1]) : (src - src[1])
    mean = ta.sma(r, win)
    dev  = r - mean
    m2   = ta.sma(dev*dev, win)
    m3   = ta.sma(dev*dev*dev, win)
    sd   = math.sqrt(math.max(m2, 0.0))
    sd > 0 ? m3 / (sd*sd*sd) : 0.0

// OSCILLATOR (realized or bar-return skew)
subTf = f_htfSub()
skR = request.security(syminfo.tickerid, subTf, f_skew(close, mLen, useLog), lookahead = barmerge.lookahead_off)
skB = f_skew(srcPrice, mLen, useLog)
skew = useReal ? skR : skB
// compute both z-scores unconditionally (Pine v6: ta.* must not sit in a branch), then select
// U8 (Wave D): compute the z at three windows unconditionally, select by mode, and (optionally)
// take the median so short/medium/long must agree before a reading counts as extreme.
int   wS = math.max(5, int(normLen / 2))
int   wL = int(normLen * 2)
float zc_s = f_zscore(skew, wS), zc_m = f_zscore(skew, normLen), zc_l = f_zscore(skew, wL)
float zr_s = rstat.robZ(skew, wS),  zr_m = rstat.robZ(skew, normLen),  zr_l = rstat.robZ(skew, wL)
bool  useClassic = zMode == "Classic (mean/stdev)"
float zS = useClassic ? zc_s : zr_s
float zM = useClassic ? zc_m : zr_m
float zL = useClassic ? zc_l : zr_l
float zMed = zS + zM + zL - math.min(zS, math.min(zM, zL)) - math.max(zS, math.max(zM, zL))
skewZ = zWinMode == "Single window" ? zM : zMed
osc = f_squash(skewZ * 33, 100)

// DIVERGENCE (chart timeframe) — detect on skewZ (stable), draw on osc
ph = ta.pivothigh(srcHigh, pivLen, pivLen)
pl = ta.pivotlow(srcLow, pivLen, pivLen)
phC = not na(ph)
plC = not na(pl)
curX = bar_index - pivLen
oH=skewZ[pivLen], pHh=srcHigh[pivLen], oHy=osc[pivLen]
poH=ta.valuewhen(phC, skewZ[pivLen],1), ppH=ta.valuewhen(phC, srcHigh[pivLen],1), pxH=ta.valuewhen(phC, bar_index-pivLen,1)
poHy=ta.valuewhen(phC, osc[pivLen],1)
bearReg = phC and pHh>ppH and oH<poH and (curX-pxH<=divLook)
bearHid = showHid and phC and pHh<ppH and oH>poH and (curX-pxH<=divLook)
oL=skewZ[pivLen], pLl=srcLow[pivLen], oLy=osc[pivLen]
poL=ta.valuewhen(plC, skewZ[pivLen],1), ppL=ta.valuewhen(plC, srcLow[pivLen],1), pxL=ta.valuewhen(plC, bar_index-pivLen,1)
poLy=ta.valuewhen(plC, osc[pivLen],1)
bullReg = plC and pLl<ppL and oL>poL and (curX-pxL<=divLook)
bullHid = showHid and plC and pLl>ppL and oL<poL and (curX-pxL<=divLook)

// HTF DIVERGENCE STATE (confirmed values only)
htfTf = f_htf()
[hSkew, hHigh, hLow] = request.security(syminfo.tickerid, htfTf, [skewZ, srcHigh, srcLow], lookahead = barmerge.lookahead_off)
hph = ta.pivothigh(hHigh, 2, 2)
hpl = ta.pivotlow(hLow, 2, 2)
hphC = not na(hph)
hplC = not na(hpl)
// STATEFUL HOIST: ta.valuewhen must run every bar. Behind the short-circuiting `and` (hphC/hplC are
// true only on the HTF pivot bars) it was skipped on most bars, corrupting its series. Evaluate the
// four calls unconditionally at top level, then use the results in the boolean.
float vwHiHigh = ta.valuewhen(hphC, hHigh[2], 1)
float vwHiSkew = ta.valuewhen(hphC, hSkew[2], 1)
float vwLoLow  = ta.valuewhen(hplC, hLow[2], 1)
float vwLoSkew = ta.valuewhen(hplC, hSkew[2], 1)
hBearRaw = hphC and hHigh[2] > vwHiHigh and hSkew[2] < vwHiSkew
hBullRaw = hplC and hLow[2]  < vwLoLow  and hSkew[2] > vwLoSkew
var bool htfBear = false
var bool htfBull = false
htfBear := hBearRaw ? true : hBullRaw ? false : htfBear
htfBull := hBullRaw ? true : hBearRaw ? false : htfBull

// COMBINE
bullDivRaw = bullReg or bullHid
bearDivRaw = bearReg or bearHid
bullConf = bullDivRaw and (not useMTF or htfBull)
bearConf = bearDivRaw and (not useMTF or htfBear)
// REGIME GATE (Wave C) — optional Kaufman efficiency-ratio filter, default Off.
float regErNet  = math.abs(srcPrice - srcPrice[regErLen])
float regErPath = math.sum(math.abs(srcPrice - srcPrice[1]), regErLen)
float regER     = regErPath > 0.0 ? regErNet / regErPath : 0.0
bool  regTrend  = regER >= regErThr
bool  regOK     = regGate == "Off" ? true : regGate == "Favor reverting" ? not regTrend : regTrend
// R1 time-of-day significance gate — a divergence counts / marks only in a statistically live slot.
int  todSlot = sess.slotOf(todSlotM)
int  todNs   = sess.slotCount(todSlotM)
bool todOK   = (not todOn) or sess.slotSignificant(close - nz(close[1], close), todSlot, todNs, 0.10, todZ)
buySig  = bullConf and regOK and todOK
sellSig = bearConf and regOK and todOK

var line[] divLines = array.new_line()
if drawLines and bearConf
    ln = line.new(int(pxH), poHy, curX, oHy, color = color.new(dnC,25), width = 2)
    array.push(divLines, ln)
if drawLines and bullConf
    ln = line.new(int(pxL), poLy, curX, oLy, color = color.new(upC,25), width = 2)
    array.push(divLines, ln)
if array.size(divLines) > 14
    line.delete(array.shift(divLines))

phaseTxt = osc > obLvl ? "Positive skew" : osc < osLvl ? "Negative skew" : osc >= 0 ? "Mild positive" : "Mild negative"
wCol = osc >= 0 ? upC : dnC

// CALIBRATION
atrSeries = ta.atr(atrLen)
var int buyN = 0
var int buyW = 0
var int buyNo = 0
var int buyWo = 0
var int sellN = 0
var int sellW = 0
var int sellNo = 0
var int sellWo = 0
var int baseN = 0
var int baseW = 0
var int lastBuyBar = -1000000
var int lastSellBar = -1000000

canEval = calOn and barstate.isconfirmed and not na(close[calHor]) and not na(atrSeries[calHor])
if canEval
    entryB = close[calHor]
    aB = atrSeries[calHor]
    fhB = f_firstHit(entryB + barrierK*aB, entryB - barrierK*aB, calHor)
    baseN += 1
    baseW += (fhB == 1 or (fhB == 0 and close > entryB)) ? 1 : 0
    if buySig[calHor]
        sigBar = bar_index[calHor]
        okB = (not uniqOn) or (sigBar - lastBuyBar >= calHor)
        if okB
            win = fhB == 1 or (fhB == 0 and close > entryB)
            buyN += 1
            buyW += win ? 1 : 0
            if sigBar >= last_bar_index - oosBars
                buyNo += 1
                buyWo += win ? 1 : 0
            lastBuyBar := sigBar
    if sellSig[calHor]
        sigBarS = bar_index[calHor]
        okS = (not uniqOn) or (sigBarS - lastSellBar >= calHor)
        if okS
            winS = fhB == -1 or (fhB == 0 and close < entryB)
            sellN += 1
            sellW += winS ? 1 : 0
            if sigBarS >= last_bar_index - oosBars
                sellNo += 1
                sellWo += winS ? 1 : 0
            lastSellBar := sigBarS

baseUp  = baseN > 0 ? baseW / baseN * 100.0 : na
baseDn  = baseN > 0 ? 100.0 - baseUp : na
buyHit  = buyN  > 0 ? buyW  / buyN  * 100.0 : na
sellHit = sellN > 0 ? sellW / sellN * 100.0 : na
buyHitO = buyNo  > 0 ? buyWo  / buyNo  * 100.0 : na
sellHitO= sellNo > 0 ? sellWo / sellNo * 100.0 : na
buyEdge  = (not na(buyHit)  and not na(baseUp)) ? buyHit  - baseUp : na
sellEdge = (not na(sellHit) and not na(baseDn)) ? sellHit - baseDn : na
buyStars  = calib.stars(buyW,  buyN,  baseUp, calMinN, 1.96)
sellStars = calib.stars(sellW, sellN, baseDn, calMinN, 1.96)
buySurv  = calib.edgeProven(buyW,  buyN,  baseUp, calMinN, 2.24)   // Wilson-floored edge > 0 (deflated z)
sellSurv = calib.edgeProven(sellW, sellN, baseDn, calMinN, 2.24)

// NET-OF-COST expectancy in R. The barrier is symmetric 1:1, so gross R = 2·hit% − 1; subtract cost.
float buyNetR  = na(buyHit)  ? na : (2.0 * buyHit  / 100.0 - 1.0) - costR
float sellNetR = na(sellHit) ? na : (2.0 * sellHit / 100.0 - 1.0) - costR

// VERDICT + CONVICTION — now requires the edge to clear the base rate (Wilson) AND survive cost.
longConv  = buyN  >= calMinN and not na(buyEdge)  and buyEdge  > 0 and buySurv  and not na(buyNetR)  and buyNetR  > 0
shortConv = sellN >= calMinN and not na(sellEdge) and sellEdge > 0 and sellSurv and not na(sellNetR) and sellNetR > 0
verdict = bullConf ? "BULL SKEW DIVERGENCE" : bearConf ? "BEAR SKEW DIVERGENCE" : (bullDivRaw and useMTF) ? "Bull div — unconfirmed" : (bearDivRaw and useMTF) ? "Bear div — unconfirmed" : "WAIT"
vCol    = bullConf ? upC : bearConf ? dnC : bullDivRaw ? upC : bearDivRaw ? dnC : flatC
convTxt = (bullConf and longConv) or (bearConf and shortConv) ? "High — edge survives test" : (bullConf or bearConf) ? "Low — context only" : longConv or shortConv ? "Divergences have edge here" : "No proven edge here"
convCol = ((bullConf and longConv) or (bearConf and shortConv)) ? upC : flatC

// PLOTS
pObIn  = plot(obLvl,  "Pos edge", color.new(upC, 45), 1)
pObOut = plot(100.0,  "Pos cap",  color.new(upC, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(upC, 30), color.new(upC, 95), title = "Positive-skew zone")
pOsIn  = plot(osLvl,  "Neg edge", color.new(dnC, 45), 1)
pOsOut = plot(-100.0, "Neg cap",  color.new(dnC, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(dnC, 95), color.new(dnC, 30), title = "Negative-skew zone")
plot(0, "Zero", gridC, 1)

plot(osc, "Skew glow", color.new(wCol, 70), 8)
plot(osc, "Skew", color.new(wCol, 0), 2)

plotshape(bullConf ? oLy : na, "Bull div", shape.circle, location.absolute, color.new(upC,0), offset = -pivLen, size = size.tiny)
plotshape(bearConf ? oHy : na, "Bear div", shape.circle, location.absolute, color.new(dnC,0), offset = -pivLen, size = size.tiny)
plotshape(buySig,  "Buy mark",  shape.triangleup,   location.belowbar, color.new(upC,0), size = size.tiny, force_overlay = true)
plotshape(sellSig, "Sell mark", shape.triangledown, location.abovebar, color.new(dnC,0), size = size.tiny, force_overlay = true)

// DASHBOARD
simple = audience == "Simple (plain language)"
var table st = table.new(f_pos(tblPos), 2, 13, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color hdr   = color.new(upC, 0)
    color phCol = osc>=0?upC:dnC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    int r = 0
    table.cell(st, 0, r, "Skew Divergence", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, r, str.upper(phaseTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Verdict", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, verdict, text_color = vCol, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "Conviction", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, calOn ? convTxt : "calibration off", text_color = convCol, bgcolor = panelBg, text_size = size.tiny)
    r += 1
    table.cell(st, 0, r, "HTF confirm", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, r, useMTF ? (str.upper(htfTf) + (htfBull ? " · bull" : htfBear ? " · bear" : " · none")) : "off", text_color = htfBull?upC:htfBear?dnC:txtMain, bgcolor = rowAlt, text_size = size.tiny)
    r += 1
    if not simple
        table.cell(st, 0, r, "Skew", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, str.tostring(skew,"0.00") + (useReal?" · realized":""), text_color = phCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming up" : "up " + str.tostring(baseUp,"0") + "%  dn " + str.tostring(baseDn,"0") + "%"
        string buyTxt  = buyN  < calMinN ? "warming " + str.tostring(buyN)  : "win " + str.tostring(buyHit,"0")  + "%  edge " + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warming " + str.tostring(sellN) : "win " + str.tostring(sellHit,"0") + "%  edge " + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, r, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, baseTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Bull " + buyStars, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        table.cell(st, 0, r, "Bear " + sellStars, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, r, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = rowAlt, text_size = size.tiny)
        r += 1
        string netTxt = (na(buyNetR) or na(sellNetR)) ? "warming" : "L " + (buyNetR>=0?"+":"") + str.tostring(buyNetR,"0.00") + " · S " + (sellNetR>=0?"+":"") + str.tostring(sellNetR,"0.00") + " R  (cost " + str.tostring(costR,"0.00") + ")"
        color netCol = (na(buyNetR) or na(sellNetR)) ? flatC : (buyNetR > 0 or sellNetR > 0) ? upC : dnC
        table.cell(st, 0, r, "Net R", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, r, netTxt, text_color = netCol, bgcolor = panelBg, text_size = size.tiny)
        r += 1
        if not simple
            string buyOTxt = buyNo  < calMinN ? "warming " + str.tostring(buyNo)  : "win " + str.tostring(buyHitO,"0")  + "%  (" + str.tostring(buyNo) + ")"
            string selOTxt = sellNo < calMinN ? "warming " + str.tostring(sellNo) : "win " + str.tostring(sellHitO,"0") + "%  (" + str.tostring(sellNo) + ")"
            table.cell(st, 0, r, "Out-of-sample", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
            table.cell(st, 1, r, "Bu " + buyOTxt + " · Be " + selOTxt, text_color = txtMain, bgcolor = panelBg, text_size = size.tiny)
            r += 1
            table.cell(st, 0, r, "Multi-test", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
            table.cell(st, 1, r, "bull " + (buySurv?"survives":"no") + " · bear " + (sellSurv?"survives":"no") + (todOn ? " · ToD " + (todOK?"✓":"·") : ""), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
            r += 1
    table.cell(st, 0, r, "Note", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, r, "character warning, not advice", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)

// EXPORTS (Data Window — consume from other scripts via input.source())
plot(skew,      "EXP_Skew",        color.new(color.gray,100), display = display.data_window)
plot(osc,       "EXP_SkewBounded", color.new(color.gray,100), display = display.data_window)
plot(bullConf ? 1 : bearConf ? -1 : 0, "EXP_Signal", color.new(color.gray,100), display = display.data_window)   // +1 bull div · -1 bear div · 0
plot(bullConf?1:0, "EXP_BullDiv",  color.new(color.gray,100), display = display.data_window)
plot(bearConf?1:0, "EXP_BearDiv",  color.new(color.gray,100), display = display.data_window)
plot(htfBull?1:htfBear?-1:0, "EXP_HtfBias", color.new(color.gray,100), display = display.data_window)
plot(buyEdge,   "EXP_BullEdge",    color.new(color.gray,100), display = display.data_window)
plot(sellEdge,  "EXP_BearEdge",    color.new(color.gray,100), display = display.data_window)
plot(na(buyNetR)  ? na : buyNetR,  "EXP_BullNetR", color.new(color.gray,100), display = display.data_window)
plot(na(sellNetR) ? na : sellNetR, "EXP_BearNetR", color.new(color.gray,100), display = display.data_window)

alertcondition(bullConf, "Bull skew divergence", "Skew Divergence: confirmed bullish skew divergence")
alertcondition(bearConf, "Bear skew divergence", "Skew Divergence: confirmed bearish skew divergence")
alertcondition(ta.crossover(osc, 0),  "Skew turned positive", "Skew Divergence crossed above zero")
alertcondition(ta.crossunder(osc, 0), "Skew turned negative", "Skew Divergence crossed below zero")
````
