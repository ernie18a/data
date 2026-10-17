# Stop Loss Optimizer Engine [AGPro Series]

- url: https://www.tradingview.com/script/83r6UNxK-Stop-Loss-Optimizer-Engine-AGPro-Series/
- type: indicator
- pine_id: PUB;fce33af92d0a4573bdfb41d4c20ffbe7
- version: 2.0

## Description

Stop Loss Optimizer Engine [AGPro Series]

🔹 OVERVIEW

Stop Loss Optimizer Engine compares four independent stop-loss methodologies side by side on a single chart, so traders can see at a glance where each approach would place protection and which one has historically held up best on the current symbol and timeframe. Every method is calculated for both LONG and SHORT, giving eight reference levels plus a compact panel with distance-to-price and a historical hold-rate statistic per method. A Risk Zone highlights the area between current price and the method with the strongest historical hold-rate, providing a clean S/R-style visual anchor for position sizing and R-multiple planning.

🔹 UNIQUE EDGE

Most stop-loss indicators on the platform commit to a single philosophy — pure ATR, pure Chandelier, or pure structure. Traders who want to compare approaches end up loading multiple scripts and eyeballing the differences. Stop Loss Optimizer Engine is built around a different premise: volatility, structure, trailing and recent-extreme stops each have environments in which they work well, and the trader should decide based on evidence rather than habit. The indicator renders all four on one chart, adds a per-method hold-rate measured on the active instrument, and flags the highest-hold-rate method with a star marker so the comparison is always a single glance away. The Risk Zone is drawn using the current-best method, which means the visual anchor adapts to whichever approach is statistically holding up best on that symbol and timeframe right now.

🔹 METHODOLOGY

The four engines are independent and each produces a LONG and a SHORT level:

ATR-SL — close minus or plus ATR × multiplier. Volatility-adaptive, widens in turbulent markets, tightens in calm ones.

Pivot-SL — the most recent confirmed pivot low or pivot high. Respects market structure, places the stop beyond the last reversal point rather than at an arithmetic distance.

Chandelier-SL — highest high minus ATR × multiplier for LONG, lowest low plus ATR × multiplier for SHORT. The classic Le Beau / Elder trailing stop, designed to follow strong trends without premature exits.

Swing-SL — the lowest low or highest high over a short lookback. A simple, robust baseline that works well for shorter trades and scalping.

Hold Rate — for every historical bar in the lookback window, the indicator records the SL level that each method would have produced at that bar, then checks whether price breached that level within a fixed forward window. Hold Rate is the percentage of evaluated bars in which the SL was not breached. This is a pure historical observation, not a forward performance projection.

🔹 SIGNALS & ALERTS

Visual — dotted lines for LONG stops (plotted below price), dashed lines for SHORT stops (plotted above price). Each method uses a distinct color. Labels sit at the right edge of each line with the method name and exact price. A dedicated anti-overlap resolver repositions labels vertically whenever two or more methods produce near-identical levels, so the rightmost chart panel stays readable in tight clusters.

Risk Zone — a shaded rectangle between current close and the highest-hold-rate SL on the trend-dominant side, extending forward from the current bar. Color matches the selected best method.

Panel — four-column layout showing method, LONG price (and distance %), SHORT price (and distance %), and Hold Rate, with a star marker beside the method currently holding the highest rate. A trend footer reports Bullish or Bearish based on the EMA50 filter.

Alerts — four pre-configured conditions for price breaching the ATR and Chandelier SL levels on either side.

🔹 KEY INPUTS

Method toggles for each of the four engines. Length and multiplier inputs per method, with balanced defaults (ATR 1.5× / 14, Pivot length 5, Chandelier 2.5× / 22, Swing lookback 7). Hold-rate statistics lookback and forward window, defaulting to 1000 and 10 bars. Visual controls for long-side lines, short-side lines, labels, the Risk Zone and a trend-based dimming of the counter-trend side. Panel location (six positions), panel theme (Dark or Light), and adjustable font sizes for panel and labels, all defaulting to Normal.

🔹 HOW TO USE

Open the indicator on any symbol and any timeframe. Read the panel first — the starred method is the one with the best historical hold-rate on the current chart. Pick a method that matches the trade plan: ATR for volatility-aware scalps, Pivot for structural setups, Chandelier for trend-following swings, Swing for simple quick trades. Use the Hold Rate column as secondary evidence, not as a standalone forecast. Read the SL price and the distance percentage next to it to size position accordingly — a 2% stop and a 6% stop are not the same trade, even on the same entry. The Risk Zone is a convenience visual for the trend-dominant side and should be interpreted together with the other levels, not in isolation.

🔹 LIMITATIONS & TRANSPARENCY

Hold Rate is a backward-looking statistic computed on historical bars of the active chart. It describes what would have happened under a fixed forward-window assumption on past data and does not guarantee any future behavior. The forward-window length, lookback size and method parameters all influence the resulting numbers; changing inputs changes the statistic. The Pivot-SL method depends on the availability of confirmed pivots in the lookback window and will fall back to a conservative ATR-based placeholder when a pivot is not yet confirmed. Risk Zone selection is based on hold-rate ranking, which can switch between methods as markets evolve. This script is a decision-support tool for discretionary risk management, not a trade-entry signal generator. Always combine with independent analysis and sound position sizing. Past performance of any stop-loss method does not guarantee future results.

🔒 RISK DISCLOSURE

This script is provided for educational and informational purposes only. It is not financial, investment or trading advice. Trading involves substantial risk of loss; use at your own discretion and risk.

## Source Code

````pine
// -------------------------------------------------
// Stop Loss Optimizer Engine [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.1
//
// Side-by-side comparison of four independent stop-loss methodologies:
// ATR-SL (volatility), Pivot-SL (structure), Chandelier-SL (trailing),
// Swing-SL (recent extreme). Each method plots long & short levels with
// a historical hold-rate statistic so traders can compare how often
// each method would have survived a fixed forward window on the active
// symbol and timeframe. Hold-rate statistics are validity-gated: only
// stops on the correct side of price at placement time enter the sample,
// and every rate is reported with its sample size. Built for disciplined
// risk management, position sizing and R-multiple planning.
// -------------------------------------------------

//@version=6
indicator("Stop Loss Optimizer Engine [AGPro Series]",
     shorttitle = "AG Pro SLOpt",
     overlay    = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 500)

// =================================================
// INPUTS
// =================================================

// -- Method toggles --------------------------------
grpMethods = "Methods"
useATR   = input.bool(true,  "ATR-SL",        group = grpMethods, tooltip = "Volatility-based stop. SL distance = ATR(length) x multiplier. Widens in volatile markets, tightens in calm ones.")
useP     = input.bool(true,  "Pivot-SL",      group = grpMethods, tooltip = "Structure-based stop. SL is placed at the most recent confirmed pivot high/low. Respects market structure.")
useCh    = input.bool(true,  "Chandelier-SL", group = grpMethods, tooltip = "Trailing stop. LONG SL = highest high(N) - ATR x mult. SHORT SL = lowest low(N) + ATR x mult. Classic Le Beau/Elder method.")
useSw    = input.bool(true,  "Swing-SL",      group = grpMethods, tooltip = "Recent extreme stop. LONG SL = lowest low over N bars. SHORT SL = highest high over N bars. Simple, robust, scalper-friendly.")

// -- ATR-SL ----------------------------------------
grpATR = "ATR-SL"
atrLen   = input.int(14,     "ATR Length",     minval = 1, group = grpATR, tooltip = "ATR period used for volatility stop calculation.")
atrMult  = input.float(1.5,  "ATR Multiplier", minval = 0.1, step = 0.1, group = grpATR, tooltip = "Multiplier applied to ATR. 1.5x is the balanced default (1.0 tight, 2.0 conservative).")

// -- Pivot-SL --------------------------------------
grpP = "Pivot-SL"
pivLen   = input.int(5,      "Pivot Length",   minval = 1, group = grpP, tooltip = "Bars left & right required to confirm a pivot high/low. Higher = fewer but stronger pivots.")

// -- Chandelier-SL ---------------------------------
grpCh = "Chandelier-SL"
chLen    = input.int(22,     "Chandelier Length",     minval = 1, group = grpCh, tooltip = "Lookback period for highest-high / lowest-low extremes used in the Chandelier trail.")
chMult   = input.float(2.5,  "Chandelier Multiplier", minval = 0.1, step = 0.1, group = grpCh, tooltip = "ATR multiplier applied to the extreme. 2.5x is the balanced default.")

// -- Swing-SL --------------------------------------
grpSw = "Swing-SL"
swLen    = input.int(7,      "Swing Lookback", minval = 1, group = grpSw, tooltip = "Bars to look back for recent low (long SL) or high (short SL).")

// -- Statistics ------------------------------------
grpStats = "Hold-Rate Statistics"
statLook = input.int(1000,   "Statistics Lookback (bars)", minval = 100, maxval = 5000, group = grpStats, tooltip = "Total bars used to compute hold-rate. 1000 = balanced sample size.")
statWin  = input.int(10,     "Forward Window (bars)",      minval = 5,   maxval = 200,  group = grpStats, tooltip = "Forward-looking window to test whether SL level was hit. 10 bars matches typical short-to-medium trade duration. Raise for swing, lower for scalp.")

// -- Visuals ---------------------------------------
grpVis = "Visuals"
showLong    = input.bool(true,  "Show LONG SL Lines",  group = grpVis, tooltip = "Display the four LONG stop-loss levels (dotted lines below price).")
showShort   = input.bool(true,  "Show SHORT SL Lines", group = grpVis, tooltip = "Display the four SHORT stop-loss levels (dashed lines above price).")
showLabels  = input.bool(true,  "Show Level Labels",   group = grpVis, tooltip = "Display method name & price at the right edge of each SL line.")
showZone    = input.bool(true,  "Show Risk Zone",      group = grpVis, tooltip = "Display a shaded rectangle from current close to the highest-hold-rate SL (premium S/R-style zone).")
useTrend    = input.bool(true,  "Dim Counter-Trend Side", group = grpVis, tooltip = "Uses EMA50 trend filter to fade lines on the non-dominant side for a cleaner look. Disable to see both sides at full opacity.")
lineLen     = input.int(30,     "Line Length (bars)",  minval = 5, maxval = 200, group = grpVis, tooltip = "How many bars to the right each SL line extends.")

// -- Panel -----------------------------------------
grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel)
panelPos  = input.string("Top Right", "Panel Location",
     options = ["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group = grpPanel)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark","Light"], group = grpPanel)

// -- Font sizes ------------------------------------
grpFont = "Font Sizes"
panelFontStr = input.string("Normal", "Panel Font Size",  options = ["Tiny","Small","Normal","Large","Huge"], group = grpFont)
labelFontStr = input.string("Normal", "Label Font Size",  options = ["Tiny","Small","Normal","Large","Huge"], group = grpFont)

f_size(s) =>
    result = size.normal
    if s == "Tiny"
        result := size.tiny
    else if s == "Small"
        result := size.small
    else if s == "Large"
        result := size.large
    else if s == "Huge"
        result := size.huge
    result
panelFont = f_size(panelFontStr)
labelFont = f_size(labelFontStr)

// =================================================
// AGPRO COLOR PALETTE
// =================================================
headerBg      = color.rgb(37, 99, 235)      // #2563EB
headerText    = color.rgb(245, 247, 250)    // #F5F7FA
panelBg       = color.rgb(15, 23, 42)       // #0F172A
panelBorder   = color.rgb(51, 65, 85)       // #334155
panelLabelCol = color.rgb(148, 163, 184)    // #94A3B8
panelValueCol = color.rgb(226, 232, 240)    // #E2E8F0
bullColor     = color.rgb(34, 197, 166)     // #22C5A6
bearColor     = color.rgb(244, 114, 182)    // #F472B6
neutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
accentColor   = color.rgb(129, 140, 248)    // #818CF8

// Light-theme overrides for panel only
panelBgUse       = panelTheme == "Light" ? color.rgb(248, 250, 252) : panelBg
panelBorderUse   = panelTheme == "Light" ? color.rgb(203, 213, 225) : panelBorder
panelLabelUse    = panelTheme == "Light" ? color.rgb(71, 85, 105)   : panelLabelCol
panelValueUse    = panelTheme == "Light" ? color.rgb(15, 23, 42)    : panelValueCol

// Method -> color mapping
atrCol = accentColor
pCol   = neutralColor
chCol  = bearColor
swCol  = bullColor

// =================================================
// CORE CALCULATIONS
// =================================================

atrVal = ta.atr(atrLen)

// ATR-SL
atrSL_L = close - atrVal * atrMult
atrSL_S = close + atrVal * atrMult

// Pivot-SL (most recent confirmed pivot)
pivH = ta.pivothigh(high, pivLen, pivLen)
pivL = ta.pivotlow(low,  pivLen, pivLen)
var float lastPivL = na
var float lastPivH = na
if not na(pivL)
    lastPivL := pivL
if not na(pivH)
    lastPivH := pivH
pSL_L = nz(lastPivL, close - atrVal)
pSL_S = nz(lastPivH, close + atrVal)

// Chandelier-SL
chSL_L = ta.highest(high, chLen) - atrVal * chMult
chSL_S = ta.lowest(low,   chLen) + atrVal * chMult

// Swing-SL
swSL_L = ta.lowest(low,   swLen)
swSL_S = ta.highest(high, swLen)

// Trend filter
emaTrend = ta.ema(close, 50)
isBull   = close > emaTrend

// Side validity: a long stop is only meaningful below current price and a
// short stop only above it. Trailing formulas (Chandelier in particular)
// can place a level on the wrong side after sharp moves; such levels are
// not placeable stops, so they are hidden from the chart, shown as "-" in
// the panel, and excluded from the hold-rate sample.
atrOkL = not na(atrSL_L) and atrSL_L < close
atrOkS = not na(atrSL_S) and atrSL_S > close
pOkL   = not na(pSL_L)   and pSL_L   < close
pOkS   = not na(pSL_S)   and pSL_S   > close
chOkL  = not na(chSL_L)  and chSL_L  < close
chOkS  = not na(chSL_S)  and chSL_S  > close
swOkL  = not na(swSL_L)  and swSL_L  < close
swOkS  = not na(swSL_S)  and swSL_S  > close

// =================================================
// HOLD-RATE STATISTICS
// For every historical bar, we know the SL level that
// WOULD have been placed at that bar (based on the
// method's formula at bar offset statWin back).
// We check whether it was breached within the next
// statWin bars. Hit = breached. Hold = survived.
// Hold Rate = holdCount / totalEvaluated x 100.
//
// Evaluation at bar t (current): uses SL[statWin]
// (the level statWin bars ago) and compares vs
// ta.lowest(low, statWin) / ta.highest(high, statWin)
// over the window that follows it.
// =================================================

// Per-bar hit booleans (true = SL was hit within the forward window)
atrHitL = ta.lowest(low,  statWin) <= atrSL_L[statWin]
atrHitS = ta.highest(high, statWin) >= atrSL_S[statWin]
pHitL   = ta.lowest(low,  statWin) <= pSL_L[statWin]
pHitS   = ta.highest(high, statWin) >= pSL_S[statWin]
chHitL  = ta.lowest(low,  statWin) <= chSL_L[statWin]
chHitS  = ta.highest(high, statWin) >= chSL_S[statWin]
swHitL  = ta.lowest(low,  statWin) <= swSL_L[statWin]
swHitS  = ta.highest(high, statWin) >= swSL_S[statWin]

// Placement-time validity: an evaluation only enters the sample when the
// stop was on the correct side of price at the bar where it would have
// been placed. Early bars where the offset level is not yet defined are
// excluded as well, so the rate is never inflated by undefined history.
atrValL = not na(atrSL_L[statWin]) and not na(close[statWin]) and atrSL_L[statWin] < close[statWin]
atrValS = not na(atrSL_S[statWin]) and not na(close[statWin]) and atrSL_S[statWin] > close[statWin]
pValL   = not na(pSL_L[statWin])   and not na(close[statWin]) and pSL_L[statWin]   < close[statWin]
pValS   = not na(pSL_S[statWin])   and not na(close[statWin]) and pSL_S[statWin]   > close[statWin]
chValL  = not na(chSL_L[statWin])  and not na(close[statWin]) and chSL_L[statWin]  < close[statWin]
chValS  = not na(chSL_S[statWin])  and not na(close[statWin]) and chSL_S[statWin]  > close[statWin]
swValL  = not na(swSL_L[statWin])  and not na(close[statWin]) and swSL_L[statWin]  < close[statWin]
swValS  = not na(swSL_S[statWin])  and not na(close[statWin]) and swSL_S[statWin]  > close[statWin]

// Each bar produces a boolean; we convert to 1/0 and take the rolling
// sum over the lookback window using math.sum() - this is O(1) per bar
// in Pine (built-in) and vastly cheaper than a manual for-loop. The
// function returns both the hold percentage and the valid sample size.
f_holdStat(hitCond, validCond) =>
    hitSum = math.sum(validCond and hitCond ? 1 : 0, statLook)
    nSum   = math.sum(validCond ? 1 : 0, statLook)
    pct    = nSum > 0 ? (nSum - hitSum) / nSum * 100.0 : na
    [pct, nSum]

// Per-method hold rates and sample sizes (long & short)
[hr_atrL_s, n_atrL_s] = f_holdStat(atrHitL, atrValL)
[hr_atrS_s, n_atrS_s] = f_holdStat(atrHitS, atrValS)
[hr_pL_s,   n_pL_s]   = f_holdStat(pHitL,   pValL)
[hr_pS_s,   n_pS_s]   = f_holdStat(pHitS,   pValS)
[hr_chL_s,  n_chL_s]  = f_holdStat(chHitL,  chValL)
[hr_chS_s,  n_chS_s]  = f_holdStat(chHitS,  chValS)
[hr_swL_s,  n_swL_s]  = f_holdStat(swHitL,  swValL)
[hr_swS_s,  n_swS_s]  = f_holdStat(swHitS,  swValS)

// Snapshot values on the last bar (for panel display)
var float hr_atrL = na
var float hr_atrS = na
var float hr_pL = na
var float hr_pS = na
var float hr_chL = na
var float hr_chS = na
var float hr_swL = na
var float hr_swS = na
var float n_atrL = na
var float n_atrS = na
var float n_pL = na
var float n_pS = na
var float n_chL = na
var float n_chS = na
var float n_swL = na
var float n_swS = na

if barstate.islast
    hr_atrL := hr_atrL_s
    hr_atrS := hr_atrS_s
    hr_pL   := hr_pL_s
    hr_pS   := hr_pS_s
    hr_chL  := hr_chL_s
    hr_chS  := hr_chS_s
    hr_swL  := hr_swL_s
    hr_swS  := hr_swS_s
    n_atrL  := n_atrL_s
    n_atrS  := n_atrS_s
    n_pL    := n_pL_s
    n_pS    := n_pS_s
    n_chL   := n_chL_s
    n_chS   := n_chS_s
    n_swL   := n_swL_s
    n_swS   := n_swS_s

// Combined hold rate per method: weighted by each side's valid sample
// size, so a side with few valid placements cannot distort the average.
f_combine(rl, nl, rs, ns) =>
    wl = nz(nl, 0.0)
    ws = nz(ns, 0.0)
    wl + ws > 0 ? (nz(rl, 0.0) * wl + nz(rs, 0.0) * ws) / (wl + ws) : na
hr_atr = f_combine(hr_atrL, n_atrL, hr_atrS, n_atrS)
hr_p   = f_combine(hr_pL,   n_pL,   hr_pS,   n_pS)
hr_ch  = f_combine(hr_chL,  n_chL,  hr_chS,  n_chS)
hr_sw  = f_combine(hr_swL,  n_swL,  hr_swS,  n_swS)
n_atr  = nz(n_atrL, 0.0) + nz(n_atrS, 0.0)
n_p    = nz(n_pL, 0.0)   + nz(n_pS, 0.0)
n_ch   = nz(n_chL, 0.0)  + nz(n_chS, 0.0)
n_sw   = nz(n_swL, 0.0)  + nz(n_swS, 0.0)

// Determine best method (highest hold rate among enabled).
// If no method is enabled or all rates are na, bestIdx stays -1.
f_rate(enabled, r) => enabled and not na(r) ? r : -1.0
rates = array.from(f_rate(useATR, hr_atr), f_rate(useP, hr_p), f_rate(useCh, hr_ch), f_rate(useSw, hr_sw))
maxRate = array.max(rates)
bestIdx = maxRate > -1.0 ? array.indexof(rates, maxRate) : -1
// bestIdx: 0=ATR, 1=Pivot, 2=Chand, 3=Swing, -1=none

// =================================================
// DRAWING - SL LINES & LABELS
// =================================================

// Opacity: dim counter-trend side if useTrend enabled
longOpacity  = useTrend and not isBull ? 55 : 0
shortOpacity = useTrend and     isBull ? 55 : 0

f_col(base, opac) => color.new(base, opac)

// Persistent line & label IDs - updated on last bar only for efficiency
var line ln_atrL = na
var line ln_atrS = na
var line ln_pL = na
var line ln_pS = na
var line ln_chL = na
var line ln_chS = na
var line ln_swL = na
var line ln_swS = na
var label lb_atrL = na
var label lb_atrS = na
var label lb_pL = na
var label lb_pS = na
var label lb_chL = na
var label lb_chS = na
var label lb_swL = na
var label lb_swS = na
var box    bx_zone = na

f_drawLine(oldLn, show, pr, dir, col, opac) =>
    line.delete(oldLn)
    line newLn = na
    if show and not na(pr)
        stl = dir == "L" ? line.style_dotted : line.style_dashed
        newLn := line.new(bar_index, pr, bar_index + lineLen, pr,
             color = f_col(col, opac), style = stl, width = 2)
    newLn

// Label draws at labelY (may differ from priceY after anti-overlap resolution).
// A short leader line connects labelY back to the actual SL price.
f_drawLabel(oldLb, show, priceY, labelY, txt, col, opac) =>
    label.delete(oldLb)
    label newLb = na
    if show and showLabels and not na(priceY)
        newLb := label.new(bar_index + lineLen, labelY, txt + "  " + str.tostring(priceY, format.mintick),
             xloc      = xloc.bar_index,
             style     = label.style_label_left,
             color     = f_col(col, opac + 20),
             textcolor = headerText,
             size      = labelFont)
    newLb

// -- ANTI-OVERLAP RESOLVER --
// Sort visible labels by price; whenever two adjacent labels are within
// minGap ATR units, nudge the later one further in its direction so their
// text no longer stacks. Returns a map of adjusted Y per method.
f_resolveOverlap(float[] prices, bool[] visible, float minGap) =>
    n = array.size(prices)
    // Build a working copy of adjusted Y values.
    adj = array.copy(prices)
    // Build index array sorted by price ascending (only visible items matter).
    idxs = array.new<int>()
    for i = 0 to n - 1
        if array.get(visible, i) and not na(array.get(prices, i))
            array.push(idxs, i)
    // Sort idxs by their price.
    if array.size(idxs) > 1
        for i = 0 to array.size(idxs) - 2
            for j = 0 to array.size(idxs) - i - 2
                a = array.get(idxs, j)
                b = array.get(idxs, j + 1)
                if array.get(adj, a) > array.get(adj, b)
                    array.set(idxs, j, b)
                    array.set(idxs, j + 1, a)
        // Walk sorted list low->high; push overlapping labels UP.
        for k = 1 to array.size(idxs) - 1
            prev = array.get(idxs, k - 1)
            cur  = array.get(idxs, k)
            gap  = array.get(adj, cur) - array.get(adj, prev)
            if gap < minGap
                array.set(adj, cur, array.get(adj, prev) + minGap)
    adj

// Price arrays (fixed order: 0=ATR-L, 1=P-L, 2=Ch-L, 3=Sw-L, 4=ATR-S, 5=P-S, 6=Ch-S, 7=Sw-S)
pricesAll  = array.from(atrSL_L, pSL_L, chSL_L, swSL_L, atrSL_S, pSL_S, chSL_S, swSL_S)
visibleAll = array.from(useATR and showLong and atrOkL, useP and showLong and pOkL, useCh and showLong and chOkL, useSw and showLong and swOkL,
                         useATR and showShort and atrOkS, useP and showShort and pOkS, useCh and showShort and chOkS, useSw and showShort and swOkS)
// Minimum vertical gap between label Y positions - based on visible chart
// RANGE, not ATR. Chart range scales with zoom and is proportional to
// label pixel height, so this gap is consistent across all timeframes
// and zoom levels. 4.5% of the 500-bar visible range leaves a small
// but visible space between stacked label boxes in tight clusters.
visHigh   = ta.highest(high, 500)
visLow    = ta.lowest(low,  500)
minLblGap = (visHigh - visLow) * 0.045
adjustedY = f_resolveOverlap(pricesAll, visibleAll, minLblGap)

if barstate.islast
    // LONG lines (drawn at real SL price)
    ln_atrL := f_drawLine(ln_atrL, useATR and showLong and atrOkL, atrSL_L, "L", atrCol, longOpacity)
    ln_pL   := f_drawLine(ln_pL,   useP   and showLong and pOkL, pSL_L,   "L", pCol,   longOpacity)
    ln_chL  := f_drawLine(ln_chL,  useCh  and showLong and chOkL, chSL_L,  "L", chCol,  longOpacity)
    ln_swL  := f_drawLine(ln_swL,  useSw  and showLong and swOkL, swSL_L,  "L", swCol,  longOpacity)
    // SHORT lines
    ln_atrS := f_drawLine(ln_atrS, useATR and showShort and atrOkS, atrSL_S, "S", atrCol, shortOpacity)
    ln_pS   := f_drawLine(ln_pS,   useP   and showShort and pOkS, pSL_S,   "S", pCol,   shortOpacity)
    ln_chS  := f_drawLine(ln_chS,  useCh  and showShort and chOkS, chSL_S,  "S", chCol,  shortOpacity)
    ln_swS  := f_drawLine(ln_swS,  useSw  and showShort and swOkS, swSL_S,  "S", swCol,  shortOpacity)

    // LONG labels (Y resolved to avoid overlap; still shows true SL price in text)
    lb_atrL := f_drawLabel(lb_atrL, useATR and showLong and atrOkL, atrSL_L, array.get(adjustedY, 0), "ATR-SL L",   atrCol, longOpacity)
    lb_pL   := f_drawLabel(lb_pL,   useP   and showLong and pOkL, pSL_L,   array.get(adjustedY, 1), "Pivot-SL L", pCol,   longOpacity)
    lb_chL  := f_drawLabel(lb_chL,  useCh  and showLong and chOkL, chSL_L,  array.get(adjustedY, 2), "Chand-SL L", chCol,  longOpacity)
    lb_swL  := f_drawLabel(lb_swL,  useSw  and showLong and swOkL, swSL_L,  array.get(adjustedY, 3), "Swing-SL L", swCol,  longOpacity)
    // SHORT labels
    lb_atrS := f_drawLabel(lb_atrS, useATR and showShort and atrOkS, atrSL_S, array.get(adjustedY, 4), "ATR-SL S",   atrCol, shortOpacity)
    lb_pS   := f_drawLabel(lb_pS,   useP   and showShort and pOkS, pSL_S,   array.get(adjustedY, 5), "Pivot-SL S", pCol,   shortOpacity)
    lb_chS  := f_drawLabel(lb_chS,  useCh  and showShort and chOkS, chSL_S,  array.get(adjustedY, 6), "Chand-SL S", chCol,  shortOpacity)
    lb_swS  := f_drawLabel(lb_swS,  useSw  and showShort and swOkS, swSL_S,  array.get(adjustedY, 7), "Swing-SL S", swCol,  shortOpacity)

    // -- RISK ZONE (between close and best-method SL on dominant side) --
    // Starts at current bar (no past extension) for a cleaner S/R-style zone.
    box.delete(bx_zone)
    if showZone and bestIdx >= 0
        bestSL_L = bestIdx == 0 ? atrSL_L : bestIdx == 1 ? pSL_L : bestIdx == 2 ? chSL_L : swSL_L
        bestSL_S = bestIdx == 0 ? atrSL_S : bestIdx == 1 ? pSL_S : bestIdx == 2 ? chSL_S : swSL_S
        bestCol  = bestIdx == 0 ? atrCol  : bestIdx == 1 ? pCol   : bestIdx == 2 ? chCol  : swCol
        zTop = isBull ? close : bestSL_S
        zBot = isBull ? bestSL_L : close
        if not na(zTop) and not na(zBot) and zTop > zBot
            bx_zone := box.new(bar_index, zTop, bar_index + lineLen, zBot,
                 border_color = f_col(bestCol, 25),
                 bgcolor      = f_col(bestCol, 85),
                 border_width = 1)

// =================================================
// PANEL
// =================================================

f_pos(p) =>
    result = position.top_right
    if p == "Top Left"
        result := position.top_left
    else if p == "Middle Right"
        result := position.middle_right
    else if p == "Middle Left"
        result := position.middle_left
    else if p == "Bottom Right"
        result := position.bottom_right
    else if p == "Bottom Left"
        result := position.bottom_left
    result

var table pnl = na

// Helper: combined "price (dist%)" string for compact 4-column layout
f_slCombo(sl) =>
    na(sl) or close == 0 ? "-" : str.tostring(sl, format.mintick) + "  (" + str.tostring(math.abs((close - sl) / close * 100.0), "#.##") + "%)"

// Helper: hold-rate formatter with valid sample size
f_rateStr(r, n) => na(r) or r < 0 or nz(n, 0.0) <= 0 ? "-" : str.tostring(r, "#.#") + "%  n=" + str.tostring(int(n))

if barstate.islast and showPanel
    table.delete(pnl)
    pnl := table.new(f_pos(panelPos), 4, 7,
         bgcolor     = panelBgUse,
         border_color = panelBorderUse,
         border_width = 1,
         frame_color  = panelBorderUse,
         frame_width  = 1)

    // Row 0 - merged blue header across all 4 columns
    table.cell(pnl, 0, 0, "AG Pro Stop Loss Optimizer",
         bgcolor = headerBg, text_color = headerText, text_size = panelFont)
    table.merge_cells(pnl, 0, 0, 3, 0)

    // Row 1 - column headers (compact)
    hdrs = array.from("Method", "LONG  (dist)", "SHORT  (dist)", "Hold Rate")
    for i = 0 to 3
        table.cell(pnl, i, 1, array.get(hdrs, i),
             bgcolor = panelBgUse, text_color = panelLabelUse, text_size = panelFont,
             tooltip = i == 3 ? "Share of valid historical placements that survived the forward window, with the valid sample size n. Only stops on the correct side of price at placement time are sampled." : "")

    // Row 2 - ATR-SL
    atrMark = bestIdx == 0 ? " *" : ""
    atrRowBg = bestIdx == 0 ? color.new(accentColor, 78) : panelBgUse
    table.cell(pnl, 0, 2, "ATR-SL" + atrMark, bgcolor = atrRowBg, text_color = atrCol, text_size = panelFont)
    table.cell(pnl, 1, 2, useATR ? (atrOkL ? f_slCombo(atrSL_L) : "-") : "off", bgcolor = atrRowBg, text_color = panelValueUse, text_size = panelFont)
    table.cell(pnl, 2, 2, useATR ? (atrOkS ? f_slCombo(atrSL_S) : "-") : "off", bgcolor = atrRowBg, text_color = panelValueUse, text_size = panelFont)
    table.cell(pnl, 3, 2, useATR ? f_rateStr(hr_atr, n_atr) : "-",    bgcolor = atrRowBg, text_color = panelValueUse, text_size = panelFont)

    // Row 3 - Pivot-SL
    pMark = bestIdx == 1 ? " *" : ""
    pRowBg = bestIdx == 1 ? color.new(accentColor, 78) : panelBgUse
    table.cell(pnl, 0, 3, "Pivot-SL" + pMark, bgcolor = pRowBg, text_color = pCol, text_size = panelFont)
    table.cell(pnl, 1, 3, useP ? (pOkL ? f_slCombo(pSL_L) : "-") : "off", bgcolor = pRowBg, text_color = panelValueUse, text_size = panelFont)
    table.cell(pnl, 2, 3, useP ? (pOkS ? f_slCombo(pSL_S) : "-") : "off", bgcolor = pRowBg, text_color = panelValueUse, text_size = panelFont)
    table.cell(pnl, 3, 3, useP ? f_rateStr(hr_p, n_p) : "-",    bgcolor = pRowBg, text_color = panelValueUse, text_size = panelFont)

    // Row 4 - Chand-SL
    chMark = bestIdx == 2 ? " *" : ""
    chRowBg = bestIdx == 2 ? color.new(accentColor, 78) : panelBgUse
    table.cell(pnl, 0, 4, "Chand-SL" + chMark, bgcolor = chRowBg, text_color = chCol, text_size = panelFont)
    table.cell(pnl, 1, 4, useCh ? (chOkL ? f_slCombo(chSL_L) : "-") : "off", bgcolor = chRowBg, text_color = panelValueUse, text_size = panelFont)
    table.cell(pnl, 2, 4, useCh ? (chOkS ? f_slCombo(chSL_S) : "-") : "off", bgcolor = chRowBg, text_color = panelValueUse, text_size = panelFont)
    table.cell(pnl, 3, 4, useCh ? f_rateStr(hr_ch, n_ch) : "-",    bgcolor = chRowBg, text_color = panelValueUse, text_size = panelFont)

    // Row 5 - Swing-SL
    swMark = bestIdx == 3 ? " *" : ""
    swRowBg = bestIdx == 3 ? color.new(accentColor, 78) : panelBgUse
    table.cell(pnl, 0, 5, "Swing-SL" + swMark, bgcolor = swRowBg, text_color = swCol, text_size = panelFont)
    table.cell(pnl, 1, 5, useSw ? (swOkL ? f_slCombo(swSL_L) : "-") : "off", bgcolor = swRowBg, text_color = panelValueUse, text_size = panelFont)
    table.cell(pnl, 2, 5, useSw ? (swOkS ? f_slCombo(swSL_S) : "-") : "off", bgcolor = swRowBg, text_color = panelValueUse, text_size = panelFont)
    table.cell(pnl, 3, 5, useSw ? f_rateStr(hr_sw, n_sw) : "-",    bgcolor = swRowBg, text_color = panelValueUse, text_size = panelFont)

    // Row 6 - Trend context footer (merged across all 4 columns)
    trendTxt = isBull ? "Trend: Bullish (EMA50)" : "Trend: Bearish (EMA50)"
    trendCol = isBull ? bullColor : bearColor
    table.cell(pnl, 0, 6, trendTxt, bgcolor = panelBgUse, text_color = trendCol, text_size = panelFont)
    table.merge_cells(pnl, 0, 6, 3, 6)

// =================================================
// ALERTS
// =================================================

alertcondition(ta.crossunder(low, atrSL_L), title = "Price breached ATR-SL (Long)",   message = "Stop Loss Optimizer: Price breached ATR-SL long level.")
alertcondition(ta.crossover(high,  atrSL_S), title = "Price breached ATR-SL (Short)",  message = "Stop Loss Optimizer: Price breached ATR-SL short level.")
alertcondition(ta.crossunder(low,  chSL_L),  title = "Price breached Chand-SL (Long)", message = "Stop Loss Optimizer: Price breached Chandelier-SL long level.")
alertcondition(ta.crossover(high,  chSL_S),  title = "Price breached Chand-SL (Short)",message = "Stop Loss Optimizer: Price breached Chandelier-SL short level.")
alertcondition(ta.crossunder(low,  pSL_L),   title = "Price breached Pivot-SL (Long)", message = "Stop Loss Optimizer: Price breached Pivot-SL long level.")
alertcondition(ta.crossover(high,  pSL_S),   title = "Price breached Pivot-SL (Short)",message = "Stop Loss Optimizer: Price breached Pivot-SL short level.")
alertcondition(ta.crossunder(low,  swSL_L),  title = "Price breached Swing-SL (Long)", message = "Stop Loss Optimizer: Price breached Swing-SL long level.")
alertcondition(ta.crossover(high,  swSL_S),  title = "Price breached Swing-SL (Short)",message = "Stop Loss Optimizer: Price breached Swing-SL short level.")
````
