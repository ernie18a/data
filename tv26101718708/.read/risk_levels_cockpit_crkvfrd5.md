# Risk & Levels Cockpit

- url: https://www.tradingview.com/script/crkvfrD5-Risk-Levels-Cockpit/
- type: indicator
- pine_id: PUB;6014a6aaa2fc47fea0832add89fe6213
- version: 3.0

## Description

Risk & Levels Cockpit

Risk & Levels Cockpit answers one question on any market and any timeframe: if I take this trade, where is my stop, what size should I trade, and what can I lose? It is a risk-and-levels tool, not a buy/sell signal — it does not predict direction, it bounds risk around a trade you have already decided to take.

HOW IT WORKS

Three components chain one-way:

Theil-Sen robust channel — fits a trend line as the median of all pairwise slopes over the lookback. Being a median, it cannot be tilted by a single spike or wick the way ordinary regression can, so the rails give you a stable structure to trade against.
Extreme Value Theory tail model (Peaks-Over-Threshold, Generalized Pareto) — estimates how far price can realistically move against you at a chosen tail quantile, replacing a guessed 2xATR stop with a distance grounded in the actual tail of the return distribution. The channel rail acts as a structural floor, so your stop is never tighter than the channel edge.
Fixed-fractional sizer — turns that stop into a position size: units = floor(risk-budget / (risk distance x point value)). When the stop is wider than your risk budget, size correctly floors to zero and the panel shows what one unit would cost and the capital that would make one unit equal your target risk, so a zero is a decision, not a dead end.

TWO SIZING BASES

Stop distance risks your fraction at the drawn stop. Expected Shortfall risks your fraction at the mean loss beyond the stop (McNeil-Frey POT form, from the same tail fit) — wider, so fewer units, so that gapping through your stop still respects your budget. The panel always shows both the at-stop and at-tail loss per unit, so gap risk is visible in either mode. An optional vol-target overlay (on by default) scales size to keep portfolio volatility steadier across regimes; the Size-mode row always shows the live multiplier.

WORKS ON ANY MARKET, ANY TIMEFRAME

No session, expiry, or clock anchors; every lookback is in bars and volatility annualization self-scales — identical behavior from 1-minute scalping to daily positional, on stocks, futures, forex, crypto, and indices worldwide. Set the currency symbol and point value (money per point per unit) to your instrument: stocks/crypto/spot = 1; index and futures = the contract multiplier (for example NIFTY 65, S&P E-mini 50, Nikkei 1000, DAX 25); forex = point value per lot; options = point value x delta.
A Scalp/Intraday, Positional, or Custom preset adjusts the tail horizon and quantile. Scalp/Intraday is the default (tighter stops); positional traders should switch to the Positional preset for wider, conservative stops.

ON THE CHART

A slope-colored robust trend line with a TREND pill and a channel band, plus solid, pill-labeled decision levels — red STOP, amber BREAK (invalidation), and green T1 and T2 TARGET, each showing price and R-multiple. The panel gives the full sizing and risk readout, including a daily-loss-budget line.

LIMITATIONS (read before use)

Not a signal and not investment advice. Stops and targets are model references, not guarantees — gaps and slippage can exceed them. The tail quantile is scaled to the holding horizon by square-root-of-time, a deliberate approximation chosen over overlapping h-bar fitting which violates independence. The daily-loss cap is a display aid; a single-chart indicator cannot track or enforce live fills. The vol-target overlay multiplies the fixed-fractional size and can nudge per-trade risk above the nominal percent in calm markets — set Size clamp max to 1.0 to only reduce size, or turn it off for a strict fixed-percent rule. Position sizing does not create an edge; it bounds risk.

CREDITS

Original implementation. Theil (1950) and Sen (1968) robust slope; Pickands-Balkema-de Haan / Peaks-Over-Threshold Generalized Pareto tail estimation and Expected Shortfall (McNeil-Frey); fixed-fractional position sizing (Tharp / Vince).

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0
// © Market_Logic_India
//
// ============================================================================
//  RISK & LEVELS COCKPIT   v1.4
// ============================================================================
//  WHAT IT IS
//  A risk-and-levels tool, not a signal. It answers one question on any
//  timeframe: "if I take this trade, where is my stop, what is my size, and
//  what can I lose?" Three engines chained one-way:
//
//    Theil-Sen robust channel  -> outlier-proof trend line + rails to trade against
//    EVT tail (POT / GPD)       -> stop distance (VaR) + Expected-Shortfall tail loss
//    Volume Profile (POC / VA)  -> structural stop floor + target references
//    Fixed-fractional sizer     -> lots = floor(risk_budget / (risk_pts x point_value))
//    Transaction costs          -> targets and R reported NET of round-trip cost
//
//  SIZING BASIS
//  Stop distance (default): risk your fraction at the drawn stop (VaR quantile).
//  Expected Shortfall: risk your fraction at the mean loss BEYOND the stop
//  (McNeil-Frey POT form ES = [VaR + sigma - xi*u] / (1 - xi)); wider, so fewer
//  lots, accounting for gapping through the stop. The stop line stays at VaR
//  either way; the panel always shows both the at-stop and at-tail loss per lot.
//
//  ORIGINALITY / MASHUP JUSTIFICATION
//  The combination is the contribution: a median-slope (Theil 1950 / Sen 1968)
//  channel supplies a structural stop floor; a Peaks-Over-Threshold Generalized
//  Pareto fit (Pickands-Balkema-de Haan) converts "how far can it run against
//  me" from a guessed ATR multiple into a tail quantile; the classic
//  fixed-fractional rule turns that exact stop into a lot count. Implemented as
//  an indicator (not a strategy) so lot sizing is computed and displayed
//  manually, sidestepping percent-of-equity notional errors on futures.
//
//  ALL-TIMEFRAME, ALL-ASSET BY DESIGN
//  No session / expiry / clock anchors and no fixed price thresholds. Every
//  lookback is in bars; volatility annualisation self-scales via
//  timeframe.in_seconds(), so scalping (1m) and positional (1D) need no changes.
//  Works on any market worldwide - stocks, futures, forex, crypto, indices.
//  Set the currency symbol and the point value (money per point per unit) to
//  your instrument: stocks/crypto/spot = 1, index/futures = contract multiplier
//  (e.g. NIFTY 65, S&P E-mini 50, Nikkei 1000, DAX 25), forex = point value/lot.
//
//  NON-REPAINT
//  All levels, tails and sizes are computed from the current bar's OHLC and
//  finalise at bar close. No request.security, no future reference, no lookahead.
//
//  PRESETS
//  Scalp/Intraday (default): horizon 3,  tailQ 0.95 -> tighter stops, sizeable
//                            on fast timeframes.
//  Positional:               horizon 10, tailQ 0.99 -> wide, conservative stops.
//  Custom:                   use the sliders. When a stop is wider than the risk
//  budget, lots floors to 0 and the panel shows the 1-lot cost + the capital
//  that would make one lot equal the target risk (the 0 becomes a decision).
//
//  CHART LEGEND
//  Colored mid-line = Theil-Sen robust trend (green up / red down) with a TREND
//  pill; faint band = channel rails. Solid pill-labelled levels: red STOP,
//  amber BREAK (invalidation), green T1 / T2 TARGET. Panel = full sizing + risk.
//
//  CREDITS
//  Theil (1950) / Sen (1968) robust slope; Pickands-Balkema-de Haan / Peaks-
//  Over-Threshold Generalized Pareto tail estimation; fixed-fractional position
//  sizing (Tharp / Vince). All implementations are original.
//
//  LIMITATIONS (read before use)
//  - Not a buy/sell signal and not investment advice. It sizes and bounds risk;
//    it does not claim a directional edge.
//  - Stop/target are references from a tail model + robust channel, not
//    guarantees; gaps and slippage can exceed them.
//  - sqrt-time scaling of the tail quantile to the holding horizon is an
//    approximation (chosen over overlapping h-bar fitting, which violates
//    independence).
//  - The daily-loss cap is a display aid; a single-chart indicator cannot track
//    live fills or enforce it. Options sizing uses a static delta input.
//  - Vol-target overlay (on by default) multiplies the fixed-fractional size;
//    in calm markets it can raise per-trade risk slightly above the nominal %.
//    Set 'Size clamp max' = 1.0 to only reduce size, or turn it off for a
//    strict fixed-% rule. The Size-mode row always shows the live multiplier.
//
//  COSTS AND NET R
//  Gross R flatters every setup. Round-trip cost (brokerage, exchange, taxes,
//  expected slippage) is converted to PRICE POINTS and applied on both sides:
//  it shrinks the distance you capture and widens the loss you actually take,
//  so R_net = (target - cost) / (stop + cost). On tight intraday stops this can
//  turn a 1.5R setup into something materially less, which is exactly the
//  decision the panel should surface rather than hide. Three cost models are
//  provided (percent of turnover, fixed per unit, ticks per side); the panel
//  shows cost as a share of R, and both net and gross R are displayed.
//
//  ALERTS
//  Stop touched, Target 1, Target 2, break/invalidation crossed, trend bias
//  flipped, and size falling to zero. Levels finalise at bar close; alerts fire
//  on the touch.
//
//  NOTE: sqrt-time scaling of the tail quantile to the holding horizon is an
//  approximation. Sizing / stops make NO directional claim and are exempt from
//  edge-validation; any directional use of the channel break is not.
//
//  Not investment advice. Position sizing does not create an edge; it bounds risk.
// ============================================================================

//@version=6
indicator("Risk & Levels Cockpit", shorttitle = "RLC", overlay = true, max_bars_back = 520, max_lines_count = 60, max_labels_count = 20)

// ============================================================================
//  01 · INPUTS
// ============================================================================
gCap = "01 · Capital & Risk"
capital  = input.float(100000, "Trading capital", minval = 1, step = 1000, group = gCap, tooltip = "In your account currency.")
curSym   = input.string("$", "Currency symbol", group = gCap, tooltip = "Shown in the panel. Set to $, €, £, ₹, ¥, etc.")
riskPct  = input.float(1.0, "Risk per trade (%)", minval = 0.05, maxval = 10, step = 0.05, group = gCap, tooltip = "Fixed-fractional rule. 1% is a common default.")
dailyLossPct = input.float(3.0, "Daily loss cap (%)", minval = 0.5, maxval = 20, step = 0.5, group = gCap, tooltip = "Portfolio-level kill-switch. Panel shows how many full-risk stops reach this cap. Enforce it yourself; a single-chart indicator can't track live fills.")
instr    = input.string("Futures / Index", "Instrument", options = ["Futures / Index", "Stock / Crypto / Spot", "Options"], group = gCap, tooltip = "How position size is interpreted (contracts / shares-units / option lots).")
ptValue  = input.float(1.0, "Point value (money / point / unit)", minval = 0.0000001, group = gCap, tooltip = "Money gained or lost per 1.0 price point, per 1 unit/lot/contract/share. Stocks, crypto & spot = 1. Index & futures = the contract multiplier (e.g. NIFTY 65, S&P E-mini 50, Nikkei 1000, DAX 25). Forex = point/pip value per lot.")
optDelta = input.float(0.5, "Option delta (Options mode)", minval = 0.05, maxval = 1.0, step = 0.05, group = gCap, tooltip = "Point value = delta × contract point value, since Pine can't read Greeks on the chart.")

gTS = "02 · Theil-Sen channel"
L      = input.int(60, "Lookback (bars)", minval = 10, maxval = 120, group = gTS, tooltip = "Robust median-slope window. Cost grows ~L²; keep ≤120.")
kRail  = input.float(2.0, "Rail width (× MAD)", minval = 0.5, maxval = 6, step = 0.25, group = gTS)
kBreak = input.float(3.0, "Break level (× MAD)", minval = 1.0, maxval = 8, step = 0.25, group = gTS)

gEV = "03 · EVT tail (POT-GPD)"
preset  = input.string("Scalp/Intraday", "Preset", options = ["Positional", "Scalp/Intraday", "Custom"], group = gEV, tooltip = "Scalp/Intraday (default): horizon 3, tailQ 0.95 (tighter stops, sizeable on fast TFs). Positional: horizon 10, tailQ 0.99 (wide stops). Custom: use the sliders below.")
evtWin  = input.int(250, "Return window (bars)", minval = 50, maxval = 500, group = gEV)
thrPct  = input.float(92.0, "Threshold percentile", minval = 80, maxval = 98, step = 0.5, group = gEV)
tailQ   = input.float(0.99, "Tail quantile for stop (Custom)", minval = 0.90, maxval = 0.999, step = 0.005, group = gEV)
horizon = input.int(10, "Holding horizon bars (Custom)", minval = 1, maxval = 200, group = gEV)
atrLen  = input.int(14, "ATR fallback length", minval = 2, maxval = 100, group = gEV)
atrMult = input.float(2.0, "ATR fallback (× ATR)", minval = 0.5, maxval = 8, step = 0.25, group = gEV)

gTG = "04 · Targets"
r1 = input.float(1.5, "Target 1 (R)", minval = 0.5, step = 0.25, group = gTG)
r2 = input.float(3.0, "Target 2 (R)", minval = 0.5, step = 0.25, group = gTG)

gSz = "05 · Sizing"
sizeBasis = input.string("Stop distance", "Sizing basis", options = ["Stop distance", "Expected Shortfall"], group = gSz, tooltip = "Stop distance: risk 1% at the drawn stop. Expected Shortfall: risk 1% at the mean tail loss beyond the stop (wider -> fewer lots; accounts for gapping through the stop). The stop line stays at the VaR level either way.")
useVT  = input.bool(true, "Vol-target overlay", group = gSz, tooltip = "ON (default): scale lots by target/current vol — smaller size in high vol, larger in calm (clamped). In calm markets this can nudge per-trade risk slightly above the nominal %. Set 'Size clamp max' to 1.0 to only ever reduce size; turn OFF for a strict fixed-fractional rule.")
tgtVol = input.float(15.0, "Target annual vol (%)", minval = 1, maxval = 100, group = gSz)
volLen = input.int(20, "Vol length (bars)", minval = 5, maxval = 200, group = gSz)
clLo   = input.float(0.25, "Size clamp min (×)", minval = 0.1, maxval = 1, step = 0.05, group = gSz)
clHi   = input.float(3.0, "Size clamp max (×)", minval = 1, maxval = 10, step = 0.25, group = gSz)

gUI = "06 · Display"
themeOpt = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = gUI)
tblPos   = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gUI)
showChan = input.bool(true, "Show Theil-Sen channel", group = gUI)
showStop = input.bool(true, "Show stop/target lines", group = gUI)

gCost = "07 · Transaction costs"
useCost   = input.bool(true, "Apply costs to R", group = gCost, tooltip = "ON: targets and R multiples are reported NET of round-trip cost. A 1.5R gross target is worth less after costs, and on tight intraday stops the difference decides whether a trade is worth taking.")
costMode  = input.string("Percent of turnover", "Cost model", options = ["Percent of turnover", "Fixed per unit", "Ticks per side"], group = gCost)
costPct   = input.float(0.06, "Round-trip cost (% of turnover)", minval = 0.0, maxval = 2.0, step = 0.01, group = gCost, tooltip = "Brokerage + exchange + taxes + expected slippage, both legs combined, as a percent of traded value.")
costUnit  = input.float(0.0, "Round-trip cost (money per unit)", minval = 0.0, step = 0.5, group = gCost)
costTicks = input.float(1.0, "Slippage (ticks per side)", minval = 0.0, maxval = 50, step = 0.5, group = gCost)

gVP = "08 · Volume Profile"
showVP      = input.bool(true, "Show volume profile", group = gVP, tooltip = "POC / value area as structural stop & target references. Auto-disables when the instrument has no volume.")
vpLen       = input.int(150, "Profile window (bars)", minval = 20, maxval = 300, group = gVP)
vpBins      = input.int(24, "Bins", minval = 6, maxval = 40, group = gVP)
vaPct       = input.float(70.0, "Value area (%)", minval = 50, maxval = 90, step = 1, group = gVP)
vpStopAnchor = input.bool(true, "VP as stop floor", group = gVP, tooltip = "Stop sits at least beyond VAL (long) / VAH (short), capped so a far value area can't blow up the stop.")
vpCapMult   = input.float(2.0, "VP stop cap (× EVT stop)", minval = 1.0, maxval = 5.0, step = 0.25, group = gVP)
vpTargetMode = input.string("R-multiple", "Target mode", options = ["R-multiple", "VP levels"], group = gVP, tooltip = "R-multiple (default): R drives targets, VP drawn as context. VP levels: T1/T2 anchor to POC / VAH-VAL.")
showVPband  = input.bool(true, "Value-area band", group = gVP)

// ============================================================================
//  02 · THEME
// ============================================================================
bg     = chart.bg_color
lum    = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
darkBG = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : lum < 128
txtCol = darkBG ? color.white : color.black
colUp  = #26a69a
colDn  = #ef5350
colMid = color.gray

// ============================================================================
//  03 · THEIL-SEN ROBUST CHANNEL  (median of pairwise slopes)
// ============================================================================
f_theilsen(int len, float w) =>
    ys = array.new<float>()
    for k = 0 to len - 1
        array.push(ys, close[len - 1 - k])
    slopes = array.new<float>()
    for a = 0 to len - 2
        ya = array.get(ys, a)
        for b = a + 1 to len - 1
            array.push(slopes, (array.get(ys, b) - ya) / (b - a))
    sl = array.median(slopes)
    inters = array.new<float>()
    for k = 0 to len - 1
        array.push(inters, array.get(ys, k) - sl * k)
    ic = array.median(inters)
    resid = array.new<float>()
    for k = 0 to len - 1
        array.push(resid, math.abs(array.get(ys, k) - (ic + sl * k)))
    md  = array.median(resid)
    mid = ic + sl * (len - 1)
    [sl, mid, mid + w * md, mid - w * md, md]

[tsSlope, tsMid, tsUp, tsLo, tsMad] = f_theilsen(L, kRail)
brkUp   = tsMid + kBreak * tsMad
brkLo   = tsMid - kBreak * tsMad
trendUp = tsSlope > 0

// ============================================================================
//  04 · EVT TAIL  (Peaks-Over-Threshold, GPD via method of moments)
// ============================================================================
// preset -> effective horizon / tail quantile (Custom uses the sliders)
hzEff = preset == "Scalp/Intraday" ? 3 : preset == "Positional" ? 10 : horizon
tqEff = preset == "Scalp/Intraday" ? 0.95 : preset == "Positional" ? 0.99 : tailQ

ret    = math.log(close / close[1])
absArr = array.new<float>()
for i = 0 to evtWin - 1
    array.push(absArr, math.abs(ret[i]))
u   = array.percentile_linear_interpolation(absArr, thrPct)
exc = array.new<float>()
for i = 0 to evtWin - 1
    v = array.get(absArr, i)
    if v > u
        array.push(exc, v - u)
nu = array.size(exc)

float tailRet = na
float esRet   = na
if nu >= 8
    m  = array.avg(exc)
    vv = array.variance(exc)
    if vv > 0 and m > 0
        rr = m * m / vv
        xi = math.max(-0.4, math.min(0.4, 0.5 * (1 - rr)))   // clamp for stability
        sg = 0.5 * m * (1 + rr)
        pf = (evtWin / nu) * (1 - tqEff)
        tailRet := math.abs(xi) > 1e-6 ? u + (sg / xi) * (math.pow(pf, -xi) - 1) : u - sg * math.log(pf)
        // Expected Shortfall (mean loss beyond the quantile), McNeil-Frey POT form
        esRet   := (tailRet + sg - xi * u) / (1 - xi)

// unconditional ta.* (house lint rule)
atrV  = ta.atr(atrLen)
rvBar = ta.stdev(ret, volLen)

atrStopPts = atrMult * atrV
evtStopPts = (not na(tailRet) and tailRet > 0) ? tailRet * close * math.sqrt(hzEff) : atrStopPts
esRawPts   = (not na(esRet) and esRet > 0) ? esRet * close * math.sqrt(hzEff) : evtStopPts

// ----- Volume Profile: POC / value area (structural levels) -----
f_volprofile(bool enabled, int vlen, int vbins, float vapct, float hi, float lo) =>
    float poc = na
    float vah = na
    float val = na
    bool  hasVol = false
    rng = hi - lo
    if enabled and rng > 0 and vbins > 0
        bins = array.new<float>(vbins, 0.0)
        totV = 0.0
        for i = 0 to vlen - 1
            vv2 = volume[i]
            if not na(vv2) and vv2 > 0
                tp = (high[i] + low[i] + close[i]) / 3.0
                bi = int((tp - lo) / rng * vbins)
                bi := math.max(0, math.min(vbins - 1, bi))
                array.set(bins, bi, array.get(bins, bi) + vv2)
                totV := totV + vv2
        if totV > 0
            hasVol := true
            pocIdx = 0
            pocVol = array.get(bins, 0)
            for b = 1 to vbins - 1
                bv = array.get(bins, b)
                if bv > pocVol
                    pocVol := bv
                    pocIdx := b
            binW = rng / vbins
            poc := lo + (pocIdx + 0.5) * binW
            target = vapct / 100.0 * totV
            cum = array.get(bins, pocIdx)
            loI = pocIdx
            hiI = pocIdx
            steps = 0
            while cum < target and (loI > 0 or hiI < vbins - 1) and steps < vbins * 2
                steps := steps + 1
                belowV = loI > 0 ? array.get(bins, loI - 1) : -1.0
                aboveV = hiI < vbins - 1 ? array.get(bins, hiI + 1) : -1.0
                if aboveV >= belowV and hiI < vbins - 1
                    hiI := hiI + 1
                    cum := cum + array.get(bins, hiI)
                else if loI > 0
                    loI := loI - 1
                    cum := cum + array.get(bins, loI)
                else if hiI < vbins - 1
                    hiI := hiI + 1
                    cum := cum + array.get(bins, hiI)
            vah := lo + (hiI + 1) * binW
            val := lo + loI * binW
    [poc, vah, val, hasVol]

vpHi = ta.highest(high, vpLen)
vpLo = ta.lowest(low, vpLen)
[vpPOC, vpVAH, vpVAL, vpHasVol] = f_volprofile(showVP, vpLen, vpBins, vaPct, vpHi, vpLo)
vpPos = not vpHasVol ? na : close > vpVAH ? 1 : close < vpVAL ? -1 : 0

// rail + VP as structural floors: stop at least beyond channel edge / value area
railFloorLong  = math.max(0.0, close - tsLo)
railFloorShort = math.max(0.0, tsUp - close)
vpActive = showVP and vpStopAnchor and vpHasVol
vpFloorLong  = (vpActive and not na(vpVAL) and vpVAL < close and (close - vpVAL) <= vpCapMult * evtStopPts) ? (close - vpVAL) : 0.0
vpFloorShort = (vpActive and not na(vpVAH) and vpVAH > close and (vpVAH - close) <= vpCapMult * evtStopPts) ? (vpVAH - close) : 0.0
stopDistLong   = math.max(evtStopPts, railFloorLong, vpFloorLong)
stopDistShort  = math.max(evtStopPts, railFloorShort, vpFloorShort)

longStop  = close - stopDistLong
shortStop = close + stopDistShort

// targets: R-multiple by default; VP-levels mode anchors to POC / value edges when valid
vpTgt = vpTargetMode == "VP levels" and vpHasVol
useVPlong  = vpTgt and not na(vpVAH) and vpVAH > close
useVPshort = vpTgt and not na(vpVAL) and vpVAL < close
longT1    = useVPlong  ? (vpPOC > close ? vpPOC : vpVAH) : close + r1 * stopDistLong
longT2    = useVPlong  ? vpVAH : close + r2 * stopDistLong
shortT1   = useVPshort ? (vpPOC < close ? vpPOC : vpVAL) : close - r1 * stopDistShort
shortT2   = useVPshort ? vpVAL : close - r2 * stopDistShort

// Expected-Shortfall distances: tail mean, never less conservative than drawn stop
esDistLong  = math.max(esRawPts, stopDistLong)
esDistShort = math.max(esRawPts, stopDistShort)

// ============================================================================
//  05 · SIZER  (fixed-fractional risk-budget -> lots)
// ============================================================================
pointVal  = instr == "Options" ? optDelta * ptValue : ptValue
riskBudget = capital * riskPct / 100.0
tfSec     = timeframe.in_seconds()
barsYr    = tfSec > 0 ? 31557600.0 / tfSec : na
annVol    = rvBar * math.sqrt(barsYr) * 100.0
sizeMult  = useVT and annVol > 0 ? math.max(clLo, math.min(clHi, tgtVol / annVol)) : 1.0

// which distance the sizer risks against
useES        = sizeBasis == "Expected Shortfall"
sizeDistLong  = useES ? esDistLong  : stopDistLong
sizeDistShort = useES ? esDistShort : stopDistShort

lotsLong  = sizeDistLong  > 0 ? math.floor(riskBudget * sizeMult / (sizeDistLong  * pointVal)) : 0
lotsShort = sizeDistShort > 0 ? math.floor(riskBudget * sizeMult / (sizeDistShort * pointVal)) : 0
// loss booked at the DRAWN stop (where the order sits), whatever the sizing basis
maxLossLong  = lotsLong  * stopDistLong  * pointVal
maxLossShort = lotsShort * stopDistShort * pointVal

// trend-side selection for the primary readout
lots     = trendUp ? lotsLong : lotsShort
stopPx   = trendUp ? longStop : shortStop
stopDist = trendUp ? stopDistLong : stopDistShort
esDist   = trendUp ? esDistLong : esDistShort
t1Px     = trendUp ? longT1 : shortT1
t2Px     = trendUp ? longT2 : shortT2
maxLoss  = trendUp ? maxLossLong : maxLossShort

// ----- transaction costs -> NET R -----
// Round-trip cost expressed in PRICE POINTS, so it subtracts directly from the
// move you capture and adds to the loss you take.
costPts = not useCost ? 0.0 :
   costMode == "Percent of turnover" ? close * costPct / 100.0 :
   costMode == "Fixed per unit"      ? (pointVal > 0 ? costUnit / pointVal : 0.0) :
                                       2.0 * costTicks * syminfo.mintick
// gross distances
t1Gross = math.abs(t1Px - close)
t2Gross = math.abs(t2Px - close)
// net: costs shrink the gain and widen the realised loss
t1Net   = math.max(0.0, t1Gross - costPts)
t2Net   = math.max(0.0, t2Gross - costPts)
stopNet = stopDist + costPts
r1eff   = stopNet > 0 ? t1Net / stopNet : na
r2eff   = stopNet > 0 ? t2Net / stopNet : na
r1Gross = stopDist > 0 ? t1Gross / stopDist : na
r2Gross = stopDist > 0 ? t2Gross / stopDist : na
costR   = stopDist > 0 ? costPts / stopDist : na      // cost expressed in R
costMoney = costPts * pointVal                         // per unit, in account currency
srcLong  = vpFloorLong  > railFloorLong  and vpFloorLong  > evtStopPts ? "VP (VAL)" : railFloorLong  > evtStopPts ? "Rail floor" : "EVT tail"
srcShort = vpFloorShort > railFloorShort and vpFloorShort > evtStopPts ? "VP (VAH)" : railFloorShort > evtStopPts ? "Rail floor" : "EVT tail"
stopSrc  = trendUp ? srcLong : srcShort

// what one lot actually costs at this stop, and the capital that makes 1 lot = target risk
oneLotRisk    = stopDist * pointVal
oneLotRiskPct = oneLotRisk / capital * 100.0
capFor1Lot    = riskPct > 0 ? oneLotRisk / (riskPct / 100.0) : na
// expected loss per lot if stopped in a tail gap (Expected Shortfall)
oneLotES      = esDist * pointVal
oneLotESPct   = oneLotES / capital * 100.0

// ============================================================================
//  06 · CHART VISUALS
// ============================================================================
midCol   = trendUp ? colUp : colDn
brkLevel = trendUp ? brkLo : brkUp   // invalidation line for the active bias

// role colors (trend-agnostic: green = target, red = stop, amber = invalidation)
colStop = colDn
colBrk  = #ff9800
colTgt  = colUp

// Theil-Sen channel: colored mid, rails + band tuned to the 4-stack look
pMid = plot(showChan ? tsMid : na, "TS Mid", color = color.new(midCol, 0), linewidth = 2)
pUp  = plot(showChan ? tsUp  : na, "TS Upper", color = color.new(colMid, 37))
pLo  = plot(showChan ? tsLo  : na, "TS Lower", color = color.new(colMid, 37))
fill(pUp, pLo, color = showChan ? color.new(midCol, 75) : na)

f_px(float x) => str.tostring(math.round_to_mintick(x))

// uniform pill label: solid role color, white text, pointer toward the level
f_pill(label lb, float y, string txt, color col) =>
    label.delete(lb)
    label.new(bar_index, y, txt, style = label.style_label_left, color = col, textcolor = color.white, size = size.tiny)

var line  lS  = na
var line  lT1 = na
var line  lT2 = na
var line  lBk = na
var label bS  = na
var label bT1 = na
var label bT2 = na
var label bBk = na
var label bTr = na

if barstate.islast and showStop
    line.delete(lS)
    line.delete(lT1)
    line.delete(lT2)
    line.delete(lBk)
    x1 = bar_index - 5
    lS  := line.new(x1, stopPx,   bar_index, stopPx,   color = colStop, width = 2, style = line.style_solid, extend = extend.right)
    lBk := line.new(x1, brkLevel, bar_index, brkLevel, color = colBrk,  width = 2, style = line.style_solid, extend = extend.right)
    lT1 := line.new(x1, t1Px,     bar_index, t1Px,     color = colTgt,  width = 2, style = line.style_solid, extend = extend.right)
    lT2 := line.new(x1, t2Px,     bar_index, t2Px,     color = colTgt,  width = 2, style = line.style_solid, extend = extend.right)
    sgn = trendUp ? -1 : 1
    bS  := f_pill(bS,  stopPx,   "STOP  " + f_px(stopPx) + "  (" + str.tostring(sgn * stopDist, "#") + ")", colStop)
    bBk := f_pill(bBk, brkLevel, "BREAK ▸ INVALIDATION  " + f_px(brkLevel), colBrk)
    bT1 := f_pill(bT1, t1Px,     "T1 ▸ TARGET  " + f_px(t1Px) + "  (" + str.tostring(r1eff, "#.##") + "R" + (useCost ? " net" : "") + ")", colTgt)
    bT2 := f_pill(bT2, t2Px,     "T2 ▸ TARGET  " + f_px(t2Px) + "  (" + str.tostring(r2eff, "#.##") + "R" + (useCost ? " net" : "") + ")", colTgt)

// volume-profile structural levels (POC / VAH / VAL) + value-area band
var line  lPOC = na
var line  lVAH = na
var line  lVAL = na
var label bPOC = na
var label bVAH = na
var label bVAL = na
var box   vaBox = na
colPOC = #ffd700
colVA  = #b39ddb
if barstate.islast and showVP and vpHasVol
    line.delete(lPOC)
    line.delete(lVAH)
    line.delete(lVAL)
    box.delete(vaBox)
    x1v = bar_index - 5
    lPOC := line.new(x1v, vpPOC, bar_index, vpPOC, color = colPOC, width = 1, style = line.style_solid, extend = extend.right)
    lVAH := line.new(x1v, vpVAH, bar_index, vpVAH, color = color.new(colVA, 25), width = 1, style = line.style_dashed, extend = extend.right)
    lVAL := line.new(x1v, vpVAL, bar_index, vpVAL, color = color.new(colVA, 25), width = 1, style = line.style_dashed, extend = extend.right)
    bPOC := f_pill(bPOC, vpPOC, "POC  " + f_px(vpPOC), colPOC)
    bVAH := f_pill(bVAH, vpVAH, "VAH  " + f_px(vpVAH), colVA)
    bVAL := f_pill(bVAL, vpVAL, "VAL  " + f_px(vpVAL), colVA)
    if showVPband
        vaBox := box.new(bar_index - 4, vpVAH, bar_index + 8, vpVAL, border_color = na, bgcolor = color.new(colVA, 90))

// trend pill on the mid-line, colored by slope
if barstate.islast and showChan
    bTr := f_pill(bTr, tsMid, (trendUp ? "TREND ▲  " : "TREND ▼  ") + f_px(tsMid), color.new(midCol, 0))

// ============================================================================
//  07 · EXP_ BUS  (read by Regime Gate #2 and Jump overlay #3)
// ============================================================================
plot(tsSlope, "EXP_Slope",   display = display.data_window)
plot(tsUp,    "EXP_ChanHi",  display = display.data_window)
plot(tsLo,    "EXP_ChanLo",  display = display.data_window)
plot(brkUp,   "EXP_BreakUp", display = display.data_window)
plot(brkLo,   "EXP_BreakDn", display = display.data_window)
plot(stopPx,  "EXP_Stop",    display = display.data_window)
plot(t1Px,    "EXP_Target1", display = display.data_window)
plot(t2Px,    "EXP_Target2", display = display.data_window)
plot(lots,    "EXP_Lots",    display = display.data_window)
plot(annVol,  "EXP_Vol",     display = display.data_window)
plot(riskPct, "EXP_RiskPct", display = display.data_window)
plot(esDist,  "EXP_ES_Dist", display = display.data_window)
plot(vpPOC,   "EXP_POC",     display = display.data_window)
plot(vpVAH,   "EXP_VAH",     display = display.data_window)
plot(vpVAL,   "EXP_VAL",     display = display.data_window)
plot(vpPos,   "EXP_VPpos",   display = display.data_window)
plot(costPts, "EXP_CostPts", display = display.data_window)
plot(r1eff,   "EXP_R1net",   display = display.data_window)

// ============================================================================
//  08 · ALERTS
//  Levels are computed on confirmed bars; alerts fire on the touch. Add them
//  once per chart from the alert dialog and pick the condition you want.
// ============================================================================
touchStop  = trendUp ? (low <= stopPx and low[1] > stopPx[1]) : (high >= stopPx and high[1] < stopPx[1])
touchT1    = trendUp ? (high >= t1Px and high[1] < t1Px[1])   : (low <= t1Px and low[1] > t1Px[1])
touchT2    = trendUp ? (high >= t2Px and high[1] < t2Px[1])   : (low <= t2Px and low[1] > t2Px[1])
crossBreak = trendUp ? (low <= brkLevel and low[1] > brkLevel[1]) : (high >= brkLevel and high[1] < brkLevel[1])
biasFlip   = trendUp != trendUp[1]
noSize     = lots < 1 and lots[1] >= 1

alertcondition(touchStop,  "Stop touched",         "RLC: stop level touched")
alertcondition(touchT1,    "Target 1 reached",     "RLC: Target 1 reached")
alertcondition(touchT2,    "Target 2 reached",     "RLC: Target 2 reached")
alertcondition(crossBreak, "Break / invalidation", "RLC: break level crossed - structure invalidated")
alertcondition(biasFlip,   "Trend bias flipped",   "RLC: robust slope changed direction")
alertcondition(noSize,     "Size fell to zero",    "RLC: stop now too wide to size at your risk budget")

// ============================================================================
//  09 · DASHBOARD
// ============================================================================
pos = switch tblPos
    "Top Left"      => position.top_left
    "Top Right"     => position.top_right
    "Bottom Left"   => position.bottom_left
    "Bottom Right"  => position.bottom_right
    "Middle Right"  => position.middle_right
    => position.top_right

var table tbl = table.new(pos, 2, 18, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 40))

if barstate.islast
    biasTxt = trendUp ? "▲ Long bias" : "▼ Short bias"
    biasCol = trendUp ? colUp : colDn
    hdrCol  = color.new(color.gray, 70)

    table.cell(tbl, 0, 0, "RISK & LEVELS COCKPIT", text_color = txtCol, text_size = size.small, bgcolor = hdrCol)
    table.cell(tbl, 1, 0, str.tostring(timeframe.period), text_color = txtCol, text_size = size.small, bgcolor = hdrCol)

    table.cell(tbl, 0, 1, "Trend", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 1, biasTxt, text_color = biasCol, text_size = size.small)

    table.cell(tbl, 0, 2, "Entry ref", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 2, f_px(close), text_color = txtCol, text_size = size.small)

    table.cell(tbl, 0, 3, "Stop", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 3, f_px(stopPx) + "  (" + str.tostring(stopDist, "#.#") + " pts / " + str.tostring(stopDist / close * 100, "#.##") + "%)", text_color = colDn, text_size = size.small)

    table.cell(tbl, 0, 4, "Target 1", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 4, f_px(t1Px) + "  (" + str.tostring(r1eff, "#.##") + "R net" + (useCost ? " / " + str.tostring(r1Gross, "#.##") + " gross" : "") + ")", text_color = colUp, text_size = size.small)

    table.cell(tbl, 0, 5, "Target 2", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 5, f_px(t2Px) + "  (" + str.tostring(r2eff, "#.##") + "R net" + (useCost ? " / " + str.tostring(r2Gross, "#.##") + " gross" : "") + ")", text_color = colUp, text_size = size.small)

    lotsCol = lots >= 1 ? color.new(biasCol, 75) : color.new(colDn, 55)
    table.cell(tbl, 0, 6, "Suggested size", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 6, str.tostring(lots) + (lots < 1 ? "  (too wide)" : "") + " units", text_color = txtCol, text_size = size.normal, bgcolor = lotsCol)

    // always show what one unit costs — turns a bare 0 into a decision
    oneLotOverBudget = oneLotRiskPct > riskPct
    table.cell(tbl, 0, 7, "1 unit @ stop", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 7, curSym + str.tostring(oneLotRisk, "#,###") + "  (" + str.tostring(oneLotRiskPct, "#.##") + "%)", text_color = oneLotOverBudget ? colDn : txtCol, text_size = size.small)

    // expected loss per unit if the stop is gapped through (tail mean)
    esOverBudget = oneLotESPct > riskPct
    table.cell(tbl, 0, 8, "1 unit @ tail (ES)", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 8, curSym + str.tostring(oneLotES, "#,###") + "  (" + str.tostring(oneLotESPct, "#.##") + "%)", text_color = esOverBudget ? colDn : txtCol, text_size = size.small)

    table.cell(tbl, 0, 9, "Cap for 1 unit @" + str.tostring(riskPct, "#.##") + "%", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 9, curSym + str.tostring(capFor1Lot, "#,###"), text_color = txtCol, text_size = size.small)

    table.cell(tbl, 0, 10, "Max loss", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 10, curSym + str.tostring(maxLoss, "#,###") + "  (" + str.tostring(maxLoss / capital * 100, "#.##") + "%)", text_color = colDn, text_size = size.small)

    stopsToCap = riskPct > 0 ? math.floor(dailyLossPct / riskPct) : 0
    table.cell(tbl, 0, 11, "Daily budget", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 11, str.tostring(dailyLossPct, "#.##") + "%  ·  up to " + str.tostring(stopsToCap) + " stops", text_color = txtCol, text_size = size.small)

    table.cell(tbl, 0, 12, "Ann. vol", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 12, str.tostring(annVol, "#.#") + "%", text_color = txtCol, text_size = size.small)

    table.cell(tbl, 0, 13, "Stop source", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 13, stopSrc + "  ·  " + preset, text_color = txtCol, text_size = size.small)

    basisTxt = (useES ? "ES" : "Stop") + (useVT ? " + VolTgt ×" + str.tostring(sizeMult, "#.##") : " · Fixed " + str.tostring(riskPct, "#.##") + "%")
    table.cell(tbl, 0, 14, "Size mode", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 14, basisTxt, text_color = txtCol, text_size = size.small)

    table.cell(tbl, 0, 15, "Instrument", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 15, instr + "  · pt " + str.tostring(ptValue) + (instr == "Options" ? "  Δ" + str.tostring(optDelta, "#.##") : ""), text_color = txtCol, text_size = size.small)

    costTxt = not useCost ? "off" : curSym + str.tostring(costMoney, "#,###.##") + "/unit  ·  " + str.tostring(costR * 100, "#.#") + "% of R"
    costCol = not useCost ? txtCol : (na(costR) ? txtCol : costR > 0.15 ? colDn : costR > 0.07 ? #ffa726 : colUp)
    table.cell(tbl, 0, 16, "Cost drag", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 16, costTxt, text_color = costCol, text_size = size.small)

    vpPosTxt = not vpHasVol ? "no volume" : vpPos == 1 ? "above VAH (premium)" : vpPos == -1 ? "below VAL (discount)" : "in value"
    vpPosCol = not vpHasVol ? txtCol : vpPos == 0 ? colUp : txtCol
    table.cell(tbl, 0, 17, "Value area", text_color = txtCol, text_size = size.small)
    table.cell(tbl, 1, 17, vpPosTxt, text_color = vpPosCol, text_size = size.small)
````
